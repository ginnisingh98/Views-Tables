--------------------------------------------------------
--  DDL for Package Body PON_OEX_TIMEZONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_OEX_TIMEZONE_PKG" as
/* $Header: PONOEXTB.pls 120.4.12010000.2 2010/12/09 06:47:02 sgulkota ship $ */

g_module constant varchar2(200) := 'PON.PLSQL.PON_OEX_TIMEZONE_PKG';

/**
 * This function returns number because it used to be a java stored procedure
 * It now takes in HZ_TIMEZONES.TIMEZONE_ID as the timezone name
 * as per bug 3664385 - hz_timezones replaced by fnd_timezones
 */
FUNCTION valid_zone (p_timeZone VARCHAR2) RETURN NUMBER IS
    tz_id NUMBER;
    valid NUMBER;
BEGIN
    tz_id := TO_NUMBER(p_timeZone);

    SELECT COUNT(upgrade_tz_id) INTO valid
    FROM fnd_timezones_b
    WHERE upgrade_tz_id = tz_id
    and enabled_flag= 'Y';

    RETURN valid;
END valid_zone;

FUNCTION convert_time (p_fromDate DATE,
		       p_fromZone VARCHAR2,
		       p_toZone VARCHAR2) RETURN DATE IS
    toDate DATE;
    status VARCHAR2(100);
    msg_count NUMBER;
    msg_data VARCHAR2(2000); --Fix for bug 10384429 - modified the msg_data from 100 to 2000
BEGIN
    /* check if the timezones are the same */
    IF p_fromZone = p_toZone THEN
        RETURN p_fromDate;
    END IF;

    IF p_fromDate IS NULL THEN
       RETURN NULL;
    END IF;

    /* use AR's api to do the conversion */
    HZ_TIMEZONE_PUB.Get_Time(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_source_tz_id => TO_NUMBER(p_fromZone),
        p_dest_tz_id => TO_NUMBER(p_toZone),
        p_source_day_time => p_fromDate,
        x_dest_day_time => toDate,
        x_return_status => status,
        x_msg_count => msg_count,
        x_msg_data => msg_data);

    RETURN toDate;

END convert_time;

/*=========================================================================+
--
-- CONVERT_DATE_TO_USER_TZ will convert given set of dates to user timezone.
-- This procedure will be used mainly to covnert Negotiation Preview date,
-- Negotiation open date, and Negotiation Close Date to user timezone.
--
-- It will return user timezone based on userId passed. If value for
-- user timezone is null procedure will return timezone of the
-- Negotiation Creator.
--
-- This logic will be applicable to the date conversion as well. That is
-- it will convert the dates to Negotiation Creator's timezone if
-- value of user timezone is null.
--
-- This API can be used to retrieve formatted date for other dates also.
-- In that case user can pass
-- Parameters :
--		p_person_party_id		  IN - trading partner contact id of the user
--		p_auctioneer_user_name	  IN -  trading partner contact name of
--                                      the Negotiation Creator
--      x_date_value1	IN OUT NOCOPY - Negotication Preview Date and
--                                       New Date value in user timezone
--		x_date_value2   IN OUT NOCOPY - Negotication Open Date and
--                                       New Date value in user timezone
--		x_date_value3   IN OUT NOCOPY - Negotication Close Date and
--                                       New Date value in user timezone
--		x_date_value4   IN OUT NOCOPY - Other misc dates
--                                       New Date value in user timezone
--		x_date_value5   IN OUT NOCOPY - Other misc dates
--                                       New Date value in user timezone
--      x_timezone_disp  OUT  NOCOPY - Time zone value for display.
--
+=========================================================================*/

PROCEDURE CONVERT_DATE_TO_USER_TZ (
					p_person_party_id       IN NUMBER,
					p_auctioneer_user_name  IN VARCHAR2,
					x_date_value1     IN OUT NOCOPY DATE,
					x_date_value2     IN OUT NOCOPY DATE,
					x_date_value3     IN OUT NOCOPY DATE,
					x_date_value4     IN OUT NOCOPY DATE,
					x_date_value5     IN OUT NOCOPY DATE,
					x_timezone_disp	     OUT NOCOPY VARCHAR2)
IS
     l_module_name CONSTANT VARCHAR2(40) := 'CONVERT_DATE_TO_USER_TZ';
     l_oex_timezone VARCHAR2(80);
     l_timezone  VARCHAR2(80);
     l_language_code VARCHAR2(30);
     l_user_name VARCHAR2(100);
     l_progress VARCHAR2(3) := '000';
BEGIN
	  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
		  FND_LOG.string (log_level => FND_LOG.level_procedure,
		  module => g_module || l_module_name,
		  message  => 'Start of Procedure ' || g_module || l_module_name
  				    || ', l_progress = '  || l_progress
				    || ', x_date_value1                = ' || x_date_value1
				    || ', x_date_value2                = ' || x_date_value2
				    || ', x_date_value3               = '  || x_date_value3
				    || ', x_date_value4                = ' || x_date_value4
				    || ', x_date_value5               = '  || x_date_value5
				    || ', p_person_party_id          = '  || p_person_party_id
				    || ', p_auctioneer_user_name  = '  || p_auctioneer_user_name);
	  END IF;

	  l_progress := '010';

      BEGIN       -- Fetch user name
	    select user_name
	    into l_user_name
	    from fnd_user
        where person_party_id = p_person_party_id
        and nvl(end_date,sysdate) >= sysdate;
        EXCEPTION
        WHEN TOO_MANY_ROWS THEN
		   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
			FND_LOG.string (log_level => FND_LOG.level_procedure,
			module => g_module || l_module_name,
			message  => 'In EXCEPTION BLOCK ' || g_module || l_module_name
  					|| ', l_progress = '  || l_progress
					|| ', p_person_party_id          = '  || p_person_party_id
				        || ', l_user_name  = '  || l_user_name);
           END IF;

	      select user_name
	      into l_user_name
	      from fnd_user
          where person_party_id = p_person_party_id
          and nvl(end_date,sysdate) >= sysdate
          and rownum=1;

       WHEN NO_DATA_FOUND THEN
 	      l_progress := '020';
          l_user_name := p_auctioneer_user_name;
	      IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
			FND_LOG.string (log_level => FND_LOG.level_procedure,
			module => g_module || l_module_name,
			message  => 'In EXCEPTION BLOCK ' || g_module || l_module_name
  					|| ', l_progress = '  || l_progress
					|| ', p_person_party_id          = '  || p_person_party_id
				        || ', l_user_name  = '  || l_user_name);
	      END IF;
      END;                -- End of Fetch User Name Block.

        l_progress := '030';

        -- Get oex timezone
        l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;


         -- Get the user's time zone
	    l_timezone := PON_AUCTION_PKG.Get_Time_Zone(p_person_party_id);

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
			FND_LOG.string (log_level => FND_LOG.level_procedure,
			module => g_module || l_module_name,
			message  => 'After getting oex and user timezone ' || g_module || l_module_name
  					|| ', l_progress = '  || l_progress
					|| ', l_oex_timezone   = '  || l_oex_timezone
				        || ', l_timezone  = '  || l_timezone);
	    END IF;

          l_progress := '040';

	  IF (l_timezone is null or l_timezone = '') THEN
		l_timezone := l_oex_timezone;
	  END IF;

	  IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(l_timezone) = 1) THEN
         l_progress := '050';
         IF (x_date_value1 is not null) THEN
	        x_date_value1 := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_date_value1,l_oex_timezone,l_timezone);
         END IF;

         IF (x_date_value2 is not null) THEN
	        x_date_value2 := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_date_value2,l_oex_timezone,l_timezone);
         END IF;

         IF (x_date_value3 is not null) THEN
	        x_date_value3 := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_date_value3,l_oex_timezone,l_timezone);
         END IF;

         IF (x_date_value4 is not null) THEN
	        x_date_value4 := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_date_value4,l_oex_timezone,l_timezone);
         END IF;

         IF (x_date_value5 is not null) THEN
	        x_date_value5 := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_date_value5,l_oex_timezone,l_timezone);
         END IF;
	  ELSE
         l_progress := '060';
	     l_timezone := l_oex_timezone;
      END IF;

	  PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_user_name,l_language_code);

          IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
 			FND_LOG.string (log_level => FND_LOG.level_procedure,
			module => g_module || l_module_name,
			message  => 'After Dates and User Languare ' || g_module || l_module_name
  					 || ', l_progress = '  || l_progress
					 || ', x_date_value1                = ' || x_date_value1
					 || ', x_date_value2                = ' || x_date_value2
				     || ', x_date_value3                = ' || x_date_value3
					 || ', x_date_value4                = ' || x_date_value4
				     || ', x_date_value5                = ' || x_date_value5
				     || ', l_language_code             = '  || l_language_code
					 || ', l_timezone  = '  || l_timezone);
	  END IF;

	  l_progress := '070';

	  x_timezone_disp := PON_AUCTION_PKG.Get_TimeZone_Description(l_timezone, l_language_code);

      IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
 			FND_LOG.string (log_level => FND_LOG.level_procedure,
			module => g_module || l_module_name,
			message  => 'End of Procedure ' || g_module || l_module_name
  					|| ', l_progress = '  || l_progress
					|| ', x_date_value1                = ' || x_date_value1
				    || ', x_date_value2                = ' || x_date_value2
				    || ', x_date_value3               = '  || x_date_value3
					 || ', x_date_value4                = ' || x_date_value4
				     || ', x_date_value5                = ' || x_date_value5
					|| ', x_timezone_disp  = '  || x_timezone_disp);
	  END IF;
END CONVERT_DATE_TO_USER_TZ;


END PON_OEX_TIMEZONE_PKG;

/
