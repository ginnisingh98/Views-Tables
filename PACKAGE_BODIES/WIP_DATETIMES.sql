--------------------------------------------------------
--  DDL for Package Body WIP_DATETIMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DATETIMES" AS
/* $Header: wipdateb.pls 115.9 2003/10/31 22:37:26 rlohani ship $ */

  DATE_FMT       CONSTANT VARCHAR2(11) := WIP_CONSTANTS.DATE_FMT;
  DATETIME_FMT   CONSTANT VARCHAR2(22) := WIP_CONSTANTS.DATETIME_FMT;

/* canonical date varchar to user display date varchar */
FUNCTION Cchar_to_Uchar(Cchar IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN (fnd_date.date_to_chardate(to_date(Cchar, DATE_FMT)));
END Cchar_to_Uchar;

/* canonical datetime varchar to user display datetime varchar */
FUNCTION CcharDT_to_Uchar(CcharDT IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN (fnd_date.date_to_charDT(to_date(CcharDT, DATETIME_FMT)));
END CcharDT_to_Uchar;

/* canonical date varchar to date[time] varchar in Ofmt_mask format mask */
FUNCTION Cchar_to_char(Cchar IN VARCHAR2, Ofmt_mask IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN (to_char(to_date(Cchar, DATE_FMT), Ofmt_mask));
END Cchar_to_char;

/* canonical datetime varchar to date[time] varchar in Ofmt_mask format mask */
FUNCTION CcharDT_to_char(CcharDT IN VARCHAR2, Ofmt_mask IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN (to_char(to_date(CcharDT, DATETIME_FMT), Ofmt_mask));
END CcharDT_to_char;

/* canonical datetime varchar to date */
FUNCTION CcharDT_to_date(CcharDT IN VARCHAR2)
RETURN DATE
IS
BEGIN
    RETURN (to_date(CcharDT, DATETIME_FMT));
END CcharDT_to_date;

/* takes two datetimes and returns their difference in minutes*/
FUNCTION datetime_diff_to_mins(dt1 DATE, dt2 DATE)
  RETURN NUMBER
  IS
BEGIN
   -- dt1 - dt2 gives the difference in days. That * 1440 gives the diff in mins.
   RETURN to_number(round((dt1 - dt2)*1440));

END datetime_diff_to_mins;

/* this function takes a date and a number (seconds to represent the
   time since 00:00:00 of this date) and return a date */
FUNCTION Date_Timenum_to_DATE(dt dATE, time number)
  RETURN DATE
  IS
BEGIN
  return float_to_DT(DT_to_float(dt) + time/86400);
END Date_Timenum_to_DATE;

/* this function returns the julian date in floating point format */
FUNCTION DT_to_float(dt DATE)
  RETURN NUMBER
  IS
BEGIN
   RETURN to_number(dt - to_date(1,'J'))+1;

END DT_to_float;

/* this function takes a julian date in a floating point format and returns a date */
FUNCTION float_to_DT(fdt NUMBER)
  RETURN DATE
  IS
BEGIN
   RETURN to_date(1,'J')+(fdt-1);

END float_to_DT;

/* this function takes a  in a date only value in LE Timezone, appends 23:59:59
 and then returns date in server timezone */

FUNCTION le_date_to_server(p_le_date DATE,
                         p_org_id NUMBER) RETURN DATE
IS
   l_le_tz_code        VARCHAR2(50);
   l_le_tz_id          NUMBER;
   l_ret_date          DATE         := NULL;
   l_return_status     VARCHAR2(30) ;
   l_msg_count         NUMBER ;
   l_msg_data          VARCHAR2(2000) ;
   CURSOR c_tz_id(p_tz_code VARCHAR2) IS
   SELECT upgrade_tz_id
   FROM fnd_timezones_vl
   WHERE timezone_code = p_tz_code;

BEGIN
   l_le_tz_code := inv_le_timezone_pub.get_le_tz_code_for_inv_org(p_org_id);
   if (l_le_tz_code IS NOT NULL AND
      NVL(fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'),'N') = 'Y') THEN
       OPEN c_tz_id(l_le_tz_code);
       FETCH c_tz_id INTO l_le_tz_id;
       CLOSE c_tz_id;
       --
       -- Call the get_time API to convert the server timezone date
       -- to the LE timezone
       HZ_TIMEZONE_PUB.Get_Time
             (  p_api_version         => 1.0
              , p_init_msg_list       => FND_API.G_FALSE
              , p_source_tz_id        => l_le_tz_id
              , p_dest_tz_id          => fnd_profile.value('SERVER_TIMEZONE_ID')
              , p_source_day_time     => (p_le_date + 1 - 1/24/60/60)
              , x_dest_day_time       => l_ret_date
              , x_return_status       => l_return_status
              , x_msg_count           => l_msg_count
              , x_msg_data            => l_msg_data ) ;

       -- if any error occurs propagate as unexpected error
       IF l_return_status = FND_API.G_RET_STS_ERROR OR
       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF ;
   else
       l_ret_date := p_le_date + 1 - 1/24/60/60;
   end if;
   RETURN l_ret_date;
END le_date_to_server;


END WIP_DATETIMES;

/
