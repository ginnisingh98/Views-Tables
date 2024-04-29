--------------------------------------------------------
--  DDL for Package Body FLM_TIMEZONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_TIMEZONE" AS
/* $Header: FLMTMZOB.pls 115.7 2004/08/18 23:20:11 hwenas noship $*/
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| FILE NAME    : FLMTMZOB.pls                                               |
| DESCRIPTION  : This package contains functions used to provide timezone   |
|                support                                                    |
| MODIFICATION HISTORY:                                                     |
|   Hadi Wenas         10/14/03          Created                            |
+===========================================================================*/

g_pkg_name CONSTANT VARCHAR2(30) := 'FLM_Timezone';

/*
  Removed global variables:
  - g_offset

  Removed the following procedures:
  - get_offset()
  - calendar_to_client()
  - client_to_calendar()
*/
--end of fix bug#3827600

FUNCTION is_init RETURN BOOLEAN IS
BEGIN
   return g_init;
END is_init;

/*
  init_timezone has to be called before using the following functions:
  - server_to_calendar
  - calendar_to_server
*/
PROCEDURE init_timezone(p_org_id NUMBER) IS
   l_client_offset NUMBER;
   l_server_offset NUMBER;
   l_start_time    NUMBER;
   l_offset        BOOLEAN;
   l_temp_date     DATE;	--fix bug#3827600
BEGIN

   IF g_enabled THEN

      SELECT gmt_deviation_hours
	INTO l_client_offset
	FROM hz_timezones
	WHERE timezone_id = g_client_id;

      SELECT gmt_deviation_hours
	INTO l_server_offset
	FROM hz_timezones
	WHERE timezone_id = g_server_id;

      IF p_org_id IS NOT NULL THEN

	 SELECT start_time
	   INTO l_start_time
	   FROM wip_lines
	   WHERE organization_id = p_org_id
	   AND (disable_date IS NULL
	     OR disable_date > Sysdate)
	     AND ROWNUM=1
           ORDER BY line_code;

         --fix bug#3827600
         --Init new global variables
         g_org_id := p_org_id;
         g_server_start_time := l_start_time;
         l_temp_date := trunc(sysdate);
         l_temp_date := l_temp_date + (l_start_time/86400);
         l_temp_date := server_to_client(l_temp_date);
         g_client_start_time := to_number(to_char(l_temp_date,'SSSSS'));
         --end of fix bug#3827600

       ELSE
         --fix bug#3827600
         --Init new global variables
         g_org_id := NULL;
	 g_client_start_time := 0;
         g_server_start_time := to_char(client_to_server(trunc(sysdate)),'SSSSS');
         --end of fix bug#3827600
      END IF;

   END IF;

   g_init := TRUE;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Init Timezone');
      END IF;
END init_timezone;

/*fix bug#3827600
  Modified the logic completely as follows:
  1. Convert server date to client
  2. Trunc it to get the 00:00:00 at client
  3. Add the client line start time
  4. Convert back to server
  5. Trunc it to get the calendar
*/
FUNCTION server_to_calendar(p_server_date IN DATE) RETURN DATE IS
   l_server_time NUMBER;
   l_server_date NUMBER;
   l_calendar_date DATE;
   e_not_init EXCEPTION;
BEGIN
   IF p_server_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF NOT g_init THEN
      RAISE e_not_init;
   END IF;

   IF g_enabled THEN
      l_calendar_date := server_to_client(p_server_date);
      l_calendar_date := trunc(l_calendar_date) + (g_client_start_time/86400);
      l_calendar_date := client_to_server(l_calendar_date);
      l_calendar_date := trunc(l_calendar_date);

   ELSE
      l_calendar_date := trunc(p_server_date);
   END IF;

   RETURN l_calendar_date;
EXCEPTION
   WHEN e_not_init THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'FLM Timezone is not initialized');
      END IF;
      RETURN Trunc(p_server_date);
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert server to CALENDAR Date');
      END IF;
      RETURN Trunc(p_server_date);
END server_to_calendar;


--fix bug#3840945:  Reinserted function client_to_calendar() since wipsfcbb.pls is using it.
FUNCTION client_to_calendar(p_client_date IN DATE) RETURN DATE IS
   l_server_date DATE;
   e_not_init EXCEPTION;
BEGIN
   IF p_client_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF NOT g_init THEN
      RAISE e_not_init;
   END IF;

   IF g_enabled THEN
      l_server_date := client_to_server(p_client_date);
    ELSE
      l_server_date := p_client_date;
   END IF;

   RETURN server_to_calendar(l_server_date);
EXCEPTION
   WHEN e_not_init THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'FLM Timezone is not initialized');
      END IF;
      RETURN Trunc(p_client_date);
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert client to CALENDAR date');
      END IF;
      RETURN Trunc(p_client_date);
END client_to_calendar;


/*fix bug#3827600
  Modified the logic completely as follows:
  1. If server_time parameter is null, default to client00_at_server
  2. Convert (sysdate+server_time) from server to calendar
  4. If the day shifts adjust (calendar_date+server_time) accordingly (-1 or +1)
*/
FUNCTION calendar_to_server(p_calendar_date IN DATE, p_server_time IN NUMBER DEFAULT NULL) RETURN DATE IS
   l_server_time NUMBER;
   l_calendar_date DATE;
   l_server_date DATE;
   e_not_init EXCEPTION;
   l_temp_num NUMBER;
   l_temp_server DATE;
   l_temp_calendar DATE;
BEGIN
   IF p_calendar_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF NOT g_init THEN
      RAISE e_not_init;
   END IF;

   IF g_enabled THEN
      IF (p_server_time IS NULL) THEN
        l_server_time := to_char(client_to_server(trunc(sysdate)),'SSSSS');
      ELSE
        l_server_time := p_server_time;
      END IF;

      l_temp_server := trunc(sysdate)+(l_server_time/86400);
      l_temp_calendar := server_to_calendar(l_temp_server);

      IF (trunc(l_temp_server) = l_temp_calendar) THEN
        l_server_date := p_calendar_date + (l_server_time/86400);
      ELSIF (trunc(l_temp_server) > l_temp_calendar) THEN
        l_server_date := p_calendar_date+1+(l_server_time/86400);
      ELSE
        l_server_date := p_calendar_date-1+(l_server_time/86400);
      END IF;

   ELSE
      l_server_date := p_calendar_date;
   END IF;

   RETURN l_server_date;
EXCEPTION
   WHEN e_not_init THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'FLM Timezone is not initialized');
      END IF;
      RETURN Trunc(p_calendar_date);
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert CALENDAR to server date');
      END IF;
      RETURN Trunc(p_calendar_date);
END calendar_to_server;


FUNCTION server_to_client(p_server_date IN DATE) RETURN DATE IS
   l_client_date DATE;
BEGIN
   IF p_server_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF g_enabled THEN
      l_client_date := hz_timezone_pub.convert_datetime(g_server_id,
							g_client_id,
							p_server_date);
    ELSE
      l_client_date := p_server_date;
   END IF;

   RETURN l_client_date;
EXCEPTION
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert server to client date');
      END IF;
      RETURN p_server_date;
END server_to_client;


FUNCTION client_to_server(p_client_date IN DATE) RETURN DATE IS
   l_server_date DATE;
BEGIN
   IF p_client_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF g_enabled THEN
      l_server_date := hz_timezone_pub.convert_datetime(g_client_id,
							g_server_id,
							p_client_date);
    ELSE
      l_server_date := p_client_date;
   END IF;

   RETURN l_server_date;
EXCEPTION
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert client to server');
      END IF;
      RETURN p_client_date;
END client_to_server;


FUNCTION client00_in_server(p_server_date IN DATE) RETURN DATE IS
   l_return_date DATE;
BEGIN
   IF p_server_date IS NULL THEN
      RETURN NULL;
   END IF;

   IF g_enabled THEN
      l_return_date := server_to_client(p_server_date);
      l_return_date := client_to_server(trunc(l_return_date));

    ELSE
      l_return_date := Trunc(p_server_date);
   END IF;

   RETURN l_return_date;
EXCEPTION
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Get client00 in server');
      END IF;
      RETURN p_server_date;
END client00_in_server;


FUNCTION sysdate00_in_server RETURN DATE IS
   l_return_date DATE;
BEGIN
   IF g_enabled THEN
      l_return_date := server_to_client(sysdate);
      l_return_date := client_to_server(trunc(l_return_date));

    ELSE
      l_return_date := Trunc(Sysdate);
   END IF;

   RETURN l_return_date;
EXCEPTION
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, 'Get sysdate00 in server');
      END IF;
      RETURN trunc(sysdate);
END sysdate00_in_server;


END flm_timezone;

/
