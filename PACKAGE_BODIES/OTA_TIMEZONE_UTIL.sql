--------------------------------------------------------
--  DDL for Package Body OTA_TIMEZONE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TIMEZONE_UTIL" as
/* $Header: ottznutl.pkb 120.6 2006/12/06 09:14:21 rmoolave noship $ */

g_package  varchar2(33) := 'ota_timezone_util.';  -- Global package name

/*
--This method will used in R12 code
FUNCTION convert_date_fnd(p_date in DATE
                        ,p_src_timezone_code IN VARCHAR2
                        ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE
IS
BEGIN

    RETURN fnd_timezones_pvt.adjust_datetime(
               date_time => p_date
		      ,from_tz   => p_src_timezone_code
		      ,to_tz     => p_dest_timezone_code);
END convert_date_fnd;
*/

FUNCTION convert_date_hz(p_date in DATE
                        ,p_src_timezone_code IN VARCHAR2
                        ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE
IS
  l_src_timezone_id HZ_TIMEZONES.TIMEZONE_ID%TYPE;
  l_dest_timezone_id HZ_TIMEZONES.TIMEZONE_ID%TYPE;
BEGIN
    l_src_timezone_id := Get_Timezone_ID(p_src_timezone_code);
    l_dest_timezone_id := Get_Timezone_ID(p_dest_timezone_code);
    RETURN HZ_TIMEZONE_PUB.Convert_DateTime(l_src_timezone_id, l_dest_timezone_id, p_date);
END convert_date_hz;

FUNCTION Get_Timezone_ID
(p_timezone_code       in	varchar2)
RETURN NUMBER
IS
  CURSOR csr_get_timezone_id IS
  SELECT UPGRADE_TZ_ID
  FROM fnd_timezones_b
  WHERE timezone_code = p_timezone_code;

l_timezone_id fnd_timezones_b.UPGRADE_TZ_ID%TYPE := NULL;
BEGIN
  OPEN csr_get_timezone_id;
  FETCH csr_get_timezone_id INTO l_timezone_id;
  CLOSE csr_get_timezone_id;

  RETURN l_timezone_id;
END  Get_Timezone_ID;

PROCEDURE get_client_timezone_vals(
        p_timezone_code OUT NOCOPY VARCHAR2
       ,p_timezone_name OUT NOCOPY VARCHAR2)
IS
   CURSOR csr_get_client_tzvals IS
   SELECT timezone_code
          ,name
   FROM fnd_timezones_vl
   WHERE UPGRADE_TZ_ID = fnd_profile.VALUE ('CLIENT_TIMEZONE_ID');
BEGIN
  p_timezone_code := NULL;
  p_timezone_name := NULL;
  OPEN csr_get_client_tzvals;
  FETCH csr_get_client_tzvals INTO p_timezone_code, p_timezone_name;
  CLOSE csr_get_client_tzvals;
END;

FUNCTION get_server_timezone_code
RETURN VARCHAR2
IS
  l_timezone_code VARCHAR2(50) := fnd_timezones.get_server_timezone_code;
/*
  l_db_timezone VARCHAR2(6) := NULL;
  l_offset NUMBER;

  CURSOR csr_timezone_code(p_offset NUMBER) IS
  SELECT timezone_code
  FROM FND_TIMEZONES_B
  WHERE GMT_OFFSET = p_offset
    AND enabled_flag = 'Y';
*/

BEGIN
/*
  IF l_timezone_code IS NULL THEN
    SELECT DBTIMEZONE INTO l_db_timezone FROM DUAL;
    l_offset := substr(l_db_timezone,1,3)
         + sign(substr(l_db_timezone,1,3)) * substr(l_db_timezone,5,6)/60;

    OPEN csr_timezone_code(l_offset);
    FETCH csr_timezone_code INTO l_timezone_code;
    CLOSE csr_timezone_code;

    RETURN l_timezone_code;

  ELSE
    RETURN l_timezone_code;
  END IF;
*/
  RETURN l_timezone_code;
END get_server_timezone_code;

PROCEDURE get_event_timezone_vals(
        p_event_id IN NUMBER
       ,p_timezone_code OUT NOCOPY VARCHAR2
       ,p_timezone_name OUT NOCOPY VARCHAR2)
IS
   CURSOR csr_get_evt_tzvals IS
   SELECT timezone_code
          ,name
   FROM  fnd_timezones_tl ftt
        ,ota_events evt
   WHERE event_id = p_event_id
     AND evt.timezone = ftt.timezone_code
     AND ftt.language = userenv('LANG');

BEGIN
  p_timezone_code := NULL;
  p_timezone_name := NULL;
  OPEN csr_get_evt_tzvals;
  FETCH csr_get_evt_tzvals INTO p_timezone_code, p_timezone_name;
  CLOSE csr_get_evt_tzvals;
END;


FUNCTION get_timezone_name(p_timezone_code in varchar2)
RETURN VARCHAR2
IS
   CURSOR csr_get_timezone_vals IS
   SELECT name
   FROM fnd_timezones_tl
   WHERE timezone_code = p_timezone_code
    AND LANGUAGE = userenv('LANG');

   l_timezone_name fnd_timezones_tl.name%TYPE := NULL;
BEGIN
   OPEN csr_get_timezone_vals;
   FETCH csr_get_timezone_vals INTO l_timezone_name;
   CLOSE csr_get_timezone_vals;

   RETURN l_timezone_name;
END;

FUNCTION convert_date(p_datevalue in DATE
                     ,p_timevalue IN VARCHAR2
                     ,p_src_timezone_code IN VARCHAR2
                     ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE
IS
l_timevalue VARCHAR2(10);
l_return_date date := NULL;
l_return_time VARCHAR2(5);

l_src_timezone_id HZ_TIMEZONES.TIMEZONE_ID%TYPE;
l_dest_timezone_id HZ_TIMEZONES.TIMEZONE_ID%TYPE;
--l_datevalue DATE;

BEGIN

    if p_datevalue is null then
    return null;
    end if;

 l_timevalue:=nvl(p_timevalue,'00:00:00');



        IF p_dest_timezone_code <> p_src_timezone_code THEN

            l_return_date:= convert_date_hz(
                                fnd_date.canonical_to_date(to_char(p_datevalue,'YYYY/MM/DD')||' '||l_timevalue)
                               ,p_src_timezone_code
                               ,p_dest_timezone_code);
        ELSE
            l_return_date:=  fnd_date.canonical_to_date(to_char(p_datevalue,'YYYY/MM/DD')||' '||l_timevalue);
        END IF;
 /*
        l_return_time := to_char(l_return_date,'HH24:MI');
        IF l_return_time = '00:00' THEN
           RETURN to_char(l_return_date);
        ELSE
           RETURN to_char(l_return_date) ||' ' ||l_return_time;
        END IF;
 */
 return l_return_date;

END convert_date;


FUNCTION convert_dateDT_time(p_datevalue in DATE
                            ,p_timevalue IN VARCHAR2
                            ,p_src_timezone_code IN VARCHAR2
                            ,p_dest_timezone_code IN VARCHAR2)
RETURN VARCHAR2
IS
  l_date DATE := convert_date(p_datevalue,p_timevalue,p_src_timezone_code,p_dest_timezone_code);
BEGIN
  IF l_date IS NOT NULL THEN   --Bug 5233939
     RETURN to_char(l_date,'HH24:MI');
  ELSE
     RETURN NULL;
  END IF;
END convert_dateDT_time;


FUNCTION get_DateDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2)
RETURN DATE
IS
l_timevalue VARCHAR2(10);
BEGIN
  IF p_datevalue IS NOT NULL
     -- Modified for bug#5532980
      AND to_char(p_datevalue, 'RRRR/MM/DD') <> '4712/12/31' THEN
     -- If there is no date, return NULL
     IF p_timevalue IS NULL THEN
           l_timevalue := '00:00:00';
     ELSE
	If ( length(p_timevalue) > 5 ) Then
		l_timevalue := p_timevalue;
	Else
		l_timevalue := p_timevalue ||':00';
	End If;
     END IF;
     IF p_online_flag = 'N' THEN
              -- Do not convert for Offline Classes
        RETURN convert_date(p_datevalue, p_timevalue, p_src_timezone, NULL);
     ELSE
        RETURN convert_date(p_datevalue, p_timevalue, p_src_timezone,fnd_timezones.get_client_timezone_code);
     END IF;
  ELSE
    RETURN NULL;
  END IF;

END get_DateDT;

FUNCTION get_dateDT_Time(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2)
RETURN VARCHAR2
IS
  l_converted_date DATE := get_DateDT(p_datevalue, p_timevalue, p_online_flag, p_src_timezone);
BEGIN
   IF l_converted_date IS NOT NULL THEN   --Bug 5233939
       RETURN to_char(l_converted_date,'HH24:MI');
   ELSE
       RETURN NULL;
   END IF;
END;

FUNCTION get_nls_language
RETURN varchar2
IS
   CURSOR csr_get_nls_lang IS
     SELECT NLS_LANGUAGE
     FROM fnd_languages
     WHERE language_code = userenv('LANG');
l_nls_language fnd_languages.NLS_LANGUAGE%TYPE;
BEGIN
   OPEN csr_get_nls_lang;
   FETCH csr_get_nls_lang INTO l_nls_language;
   CLOSE csr_get_nls_lang;

   RETURN l_nls_language;
END get_nls_language;

FUNCTION get_date_time(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2
	       ,p_time_format IN VARCHAR2 default 'HH24:MI')
RETURN VARCHAR2
IS
  l_converted_date DATE := get_DateDT(p_datevalue, p_timevalue, p_online_flag, p_src_timezone);
BEGIN
   IF l_converted_date IS NOT NULL THEN   --Bug 5233939
       RETURN to_char(trunc(l_converted_date)
		        ,hr_util_misc_web.get_nls_parameter('NLS_DATE_FORMAT')
		        , 'nls_date_language = ''' || get_nls_language()||'''') || ' ' ||to_char(l_converted_date, p_time_format);
   ELSE
       RETURN NULL;
   END IF;
END;

FUNCTION  get_Class_DateDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_event_id IN NUMBER)
RETURN DATE
IS
  l_online_flag ota_category_usages.online_flag%TYPE;
  l_evt_timezone ota_events.timezone%TYPE;
BEGIN
    OPEN get_class_info(p_event_id);
    FETCH get_class_info INTO l_online_flag, l_evt_timezone;
    CLOSE get_class_info;

    RETURN get_DateDT(p_datevalue, p_timevalue, l_online_flag, l_evt_timezone);

END  get_Class_DateDT;


FUNCTION get_resource_bookingDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_resource_booking_id IN NUMBER)
RETURN DATE
IS
   l_online_flag ota_category_usages.online_flag%TYPE;
   --l_trb_timezone ota_resource_bookings.timezone%TYPE;
   l_trb_timezone fnd_timezones_tl.timezone_code%TYPE;
   l_trb_timezone_name fnd_timezones_tl.name%TYPE;
BEGIN
  OPEN get_resource_booking_info(p_resource_booking_id);
  FETCH get_resource_booking_info INTO l_online_flag, l_trb_timezone, l_trb_timezone_name;
  CLOSE get_resource_booking_info;

  RETURN get_DateDT(p_datevalue, p_timevalue, l_online_flag, l_trb_timezone);
END get_resource_bookingDT;

end ota_timezone_util;


/
