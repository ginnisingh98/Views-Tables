--------------------------------------------------------
--  DDL for Package PON_OEX_TIMEZONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_OEX_TIMEZONE_PKG" AUTHID CURRENT_USER as
/* $Header: PONOEXTS.pls 120.1 2005/06/22 23:46:13 rpatel noship $ */


FUNCTION valid_zone(p_timeZone VARCHAR2) RETURN NUMBER;

FUNCTION convert_time(p_fromDate DATE,
		      p_fromZone VARCHAR2,
		      p_toZone   VARCHAR2)   RETURN DATE;


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
--		x_person_party_id		  IN - trading partner contact id of the user
--		x_auctioneer_user_name	  IN -  trading partner contact name of
--                                      the Negotiation Creator
--      x_date_value1	IN OUT NOCOPY - Negotication Preview Date and
--                                       New Date value in user timezone
--		x_date_value2   IN OUT NOCOPY - Negotication Open Date and
--                                       New Date value in user timezone
--		x_date_value3   IN OUT NOCOPY - Negotication Close Date and
--                                       New Date value in user timezone
--		x_date_value4   IN OUT NOCOPY - Other misc Dates
--                                       New Date value in user timezone
--		x_date_value5   IN OUT NOCOPY - Other misc Dates
--                                       New Date value in user timezone
--      x_timezone_dsp  OUT  NOCOPY - Time zone value for display.
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
					x_timezone_disp	     OUT NOCOPY VARCHAR2);

END PON_OEX_TIMEZONE_PKG;

 

/
