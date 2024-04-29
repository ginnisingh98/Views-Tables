--------------------------------------------------------
--  DDL for Package Body PON_CONSOLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CONSOLE_PVT" AS
/* $Header: PONVCONB.pls 120.3 2006/03/14 15:08:14 rbairraj noship $ */

---
--- +=======================================================================+
--- |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
--- |                         All rights reserved.                          |
--- +=======================================================================+
--- |
--- | FILENAME
--- |     PONVCONB.pls
--- |
--- |
--- | DESCRIPTION
--- |     This package contains procedures called from the live console
--- |     the Supplier activities function
--- |
--- | HISTORY
--- |
--- |     14-Jun-2004 sparames   Created.
--- |     30-Jun-2004 sahegde    Added procedrues for supplier activities,
--- |                            debugging
--- |
--- +=======================================================================+
---

-- The external procedure returns the dates individually in separate
-- columns since Java does not understand arrays.  Internally, the
-- procedures pass around an array of dates

TYPE datetbltype IS TABLE OF DATE         INDEX BY BINARY_INTEGER;

-- Since the console plots all dates as numbers, it is required to
-- convert a given date to a number. It is assumed that the total
-- range of the graph in numbers is 2882880 (12*24*60*11*12*13*14).
-- Hence for plotting a value, one has to take the difference between
-- the date (bid published date) and the starting date of the graph
-- and factor it according to the total range which equals 2882880

g_graph_range   CONSTANT PLS_INTEGER := 2882880;

-- The user will see a maximum of 13 divisions. 14 is used to include
-- the start and end ticks

g_max_no_ticks  CONSTANT PLS_INTEGER := 14;

-- private package variable for debugging purpose
g_pkg_name      CONSTANT varchar2(30) := 'PON_CONSOLE_PVT';

--------------------------------------------------------------------------------
--                 Private procedure definitions                              --
--------------------------------------------------------------------------------
-- private function to determine if debug level is enabled at statement level
FUNCTION is_debug_statement_on
RETURN BOOLEAN IS
  l_debug_statement BOOLEAN;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug_statement := TRUE;
  ELSE
      l_debug_statement := FALSE;
  END IF;
  RETURN l_debug_statement;
END;


-- private function to determine if debug level is enabled at unexpected level
FUNCTION is_debug_unexpected_on
RETURN BOOLEAN IS
  l_debug_unexpected BOOLEAN;
BEGIN

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug_unexpected := TRUE;
  ELSE
      l_debug_unexpected := FALSE;
  END IF;
  RETURN l_debug_unexpected;
END;
--
-- Comments for get_date_ params - see detailed definition lower in
-- the package body
--

PROCEDURE get_date_params(  p_start_date         IN         DATE,
			    p_end_date           IN         DATE,
			    x_graph_start_date   OUT NOCOPY DATE,
			    x_graph_duration     OUT NOCOPY NUMBER,
			    x_number_of_ticks    OUT NOCOPY PLS_INTEGER,
			    x_tick_duration_days OUT NOCOPY NUMBER,
			    x_start_offset_value OUT NOCOPY VARCHAR2,
			    x_start_offset_unit  OUT NOCOPY VARCHAR2,
			    x_output_date_format OUT NOCOPY VARCHAR2);

--
-- Comments for get_tick_values - see detailed definition lower in
-- the package body
--

PROCEDURE get_tick_values (
                  p_start_date         IN         DATE,
                  p_end_date           IN         DATE,
		  p_graph_duration     IN         NUMBER,
		  p_number_of_ticks    IN         PLS_INTEGER,
		  p_tick_duration_days IN         NUMBER,
		  p_start_offset_value IN         PLS_INTEGER,
		  p_start_offset_unit  IN         VARCHAR2,
		  p_output_date_format IN         VARCHAR2,
		  x_graph_start_date   OUT NOCOPY DATE,
                  x_graph_end_date     OUT NOCOPY DATE,
		  x_graph_duration     OUT NOCOPY NUMBER,
		  x_number_of_ticks    OUT NOCOPY NUMBER,
		  x_tick_date_values   OUT NOCOPY dateTblType
	         );

-----------------------------------------------------------------
--              get_date_params                              ----
-----------------------------------------------------------------
--
-- Start of Comments
--
-- API Name: get_date_params
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called internally within this package and
--           is used to get the parameters for a given set of dates
--
-- Parameters:
--
--       p_start_date         IN  DATE
--            Required - start date for determining the range
--
--       p_end_date           IN  DATE
--            Required - end date of the range
--
--       x_graph_start_date   OUT DATE
--            If the start date was less than an hour earlier than
--            the end date, then the new start date for the graph
--            will be an hour earlier than the end date
--
--       x_graph_duration     OUT NUMBER
--            This is the duration of the graph in days
--
--       x_number_of_ticks    OUT PLS_INTEGER
--            This is the number of ticks.  The actual number of ticks
--            will be one more than what is given here
--
--       x_tick_duration_days OUT NUMBER
--            This is the duration of each tick in days
--
--       x_start_offset_value OUT VARCHAR2
--            Since in most cases, it would not be wise to start the
--            graph exactly on the start date, we round down to the
--            nearest time unit based on the scale of the graph.  This
--            contains the value e.g 5 if the rounding is to the nearest
--            5 mins
--
--       x_start_offset_unit  OUT VARCHAR2
--            This contains the unit of rounding as explained above
--
--       x_output_date_format OUT VARCHAR2
--            This contains the format in which the ticks are
--            labelled.  Depending on the scale of the graph, only
--            the date, or the date+time or only the time is shown
--
-----------------------------------------------------------------
--
--  The following table shows the logic that is used to determine
--  the parameters for each time range.   The first two entries can
--  be ignored since we will not have a range of less than 1 hour.
--  e.g. If the duration is between 60 and 90 mins, the fourth row
--  will be used, resulting in 12 ticks, 5 minutes apart, starting
--  at the nearest 5 minutes before the start time.  i.e. if the
--  start time is 11:43, the graph will start at 11:40.  This
--  downward rounding may cause an extra tick to be added but this
--  will be done in the procedure that calls this one


-- +----------+-------+-----------+----------+
-- | Duration | Ticks | Tick Dur  | Start at |
-- |          +       +           + nearest  |
-- |----------+-------+-----------+----------|
-- | 15 mins  + 8     + 2 mins    + 1 min    |
-- |----------+-------+-----------+----------|
-- | 30 mins  + 10    + 3 mins    + 1 min    |
-- |----------+-------+-----------+----------|
-- | 60 mins  + 12    + 5 mins    + 5 min    |
-- |----------+-------+-----------+----------|
-- | 90 mins  + 10    + 10 mins   + 10 min   |
-- |----------+-------+-----------+----------|
-- | 2 hour   + 12    + 10 mins   + 10 min   |
-- |----------+-------+-----------+----------|
-- | 3 hour   + 12    + 15 mins   + 15 min   |
-- |----------+-------+-----------+----------|
-- | 6 hour   + 12    + 30 mins   + 30 min   |
-- |----------+-------+-----------+----------|
-- | 10 hour  + 10    + 60 mins   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 12 hour  + 12    + 60 mins   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 18 hour  + 12    + 90 mins   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 1 day    + 12    + 2 hours   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 1.5 days + 10    + 3 hours   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 2 days   + 12    + 4 hours   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 3 days   + 12    + 6 hours   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 4 days   + 12    + 8 hours   + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 5 days   + 12    + 10 hours  + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 6 days   + 12    + 12 hours  + 1 hour   |
-- |----------+-------+-----------+----------|
-- | 8 days   + 8     + 1 day     + 1 day    |
-- |----------+-------+-----------+----------|
-- | 9 days   + 9     + 1 day     + 1 day    |
-- |----------+-------+-----------+----------|
-- | 12 days  + 12    + 1 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 24 days  + 12    + 2 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 36 days  + 12    + 3 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 48 days  + 12    + 4 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 60 days  + 12    + 5 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 90 days  + 10    + 9 days    + 1 day    |
-- |----------+-------+-----------+----------|
-- | 120 days + 10    + 10 days   + 1 day    |
-- |----------+-------+-----------+----------|
-- | 150 days + 10    + 15 days   + 1 day    |
-- |----------+-------+-----------+----------|
-- | 180 days + 10    + 18 days   + 1 day    |
-- +----------+-------+-----------+----------+

PROCEDURE get_date_params(  p_start_date         IN         DATE,
			    p_end_date           IN         DATE,
			    x_graph_start_date   OUT NOCOPY DATE,
			    x_graph_duration     OUT NOCOPY NUMBER,
			    x_number_of_ticks    OUT NOCOPY PLS_INTEGER,
			    x_tick_duration_days OUT NOCOPY NUMBER,
			    x_start_offset_value OUT NOCOPY VARCHAR2,
			    x_start_offset_unit  OUT NOCOPY VARCHAR2,
			    x_output_date_format OUT NOCOPY VARCHAR2) IS


l_1_min  CONSTANT NUMBER := 1/24/60;  -- expressing 1 min in days
l_1_hour CONSTANT NUMBER := 1/24;     -- expressing 1 hour in days

l_start_date  DATE;
l_date_range  NUMBER;

i             PLS_INTEGER := 0;

invalid_date EXCEPTION;

BEGIN

-- The minimum to be displayed is 1 hour from the closing time. Set
-- the graph start date accordingly

IF p_end_date - p_start_date < l_1_hour
THEN
   l_start_date := p_end_date - l_1_hour;
---   dbms_output.put_line('Got less than 1 hour...resetting new start date = ' || to_char(l_start_date, 'hh24:mi:ss'));
ELSE
   l_start_date := p_start_date;
END IF;

  x_graph_start_date := l_start_date;

  l_date_range  := p_end_date - l_start_date;

--- dbms_output.put_line('11.01: l_date_range_days = ' || l_date_range);
--- dbms_output.put_line('11.01: l_date_range_hours = ' || l_date_range*24);
--- dbms_output.put_line('11.01: l_date_range_mins = ' || l_date_range*24*60);

  IF (l_date_range <= l_1_min*60)    -- 60 mins
  THEN
        x_graph_duration     := l_1_min*60;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*5;
        x_start_offset_value := 5;  x_start_offset_unit := 'MIN';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_min*90)    -- 90 mins
  THEN
        x_graph_duration     := l_1_min*90;
        x_number_of_ticks    := 10; x_tick_duration_days := l_1_min*10;
        x_start_offset_value := 10;  x_start_offset_unit := 'MIN';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_hour*2)    -- 2 hours
  THEN
        x_graph_duration     := l_1_hour*2;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*10;
        x_start_offset_value := 10;  x_start_offset_unit := 'MIN';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_hour*3)    -- 3 hours
  THEN
        x_graph_duration     := l_1_hour*3;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*15;
        x_start_offset_value := 15;  x_start_offset_unit := 'MIN';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_hour*6)    -- 6 hours
  THEN
        x_graph_duration     := l_1_hour*6;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*30;
        x_start_offset_value := 30;  x_start_offset_unit := 'MIN';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_hour*10)    -- 10 hours
  THEN
        x_graph_duration     := l_1_hour*10;
        x_number_of_ticks    := 10; x_tick_duration_days := l_1_min*60;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'hh24:mi';

  ELSIF (l_date_range <= l_1_hour*12)    -- 12 hours
  THEN
        x_graph_duration     := l_1_hour*12;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*60;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= l_1_hour*18)    -- 18 hours
  THEN
        x_graph_duration     := l_1_hour*18;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_min*90;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 1)    -- 1 days
  THEN
        x_graph_duration     := 1;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*2;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 1.5)    -- 1.5 days
  THEN
        x_graph_duration     := 1.5;
        x_number_of_ticks    := 10; x_tick_duration_days := l_1_hour*3;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 2)    -- 2 days
  THEN
        x_graph_duration     := 2;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*4;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 3)    -- 3 days
  THEN
        x_graph_duration     := 3;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*6;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 4)    -- 4 days
  THEN
        x_graph_duration     := 4;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*8;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 5)    -- 5 days
  THEN
        x_graph_duration     := 5;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*10;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 6)    -- 6 days
  THEN
        x_graph_duration     := 6;
        x_number_of_ticks    := 12; x_tick_duration_days := l_1_hour*12;
        x_start_offset_value := 1;  x_start_offset_unit := 'HOUR';
        x_output_date_format := 'ddmon hh24:mi';

  ELSIF (l_date_range <= 8)    -- 8 days
  THEN
        x_graph_duration     := 8;
        x_number_of_ticks    := 08; x_tick_duration_days := 1;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 9)    -- 9 days
  THEN
        x_graph_duration     := 9;
        x_number_of_ticks    := 09; x_tick_duration_days := 1;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 12)    -- 12 days
  THEN
        x_graph_duration     := 12;
        x_number_of_ticks    := 12; x_tick_duration_days := 1;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 24)    -- 24 days
  THEN
        x_graph_duration     := 24;
        x_number_of_ticks    := 12; x_tick_duration_days := 2;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 36)    -- 36 days
  THEN
        x_graph_duration     := 36;
        x_number_of_ticks    := 12; x_tick_duration_days := 3;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 48)    -- 48 days
  THEN
        x_graph_duration     := 48;
        x_number_of_ticks    := 12; x_tick_duration_days := 4;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 60)    -- 60 days
  THEN
        x_graph_duration     := 60;
        x_number_of_ticks    := 12; x_tick_duration_days := 5;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 90)    -- 90 days
  THEN
        x_graph_duration     := 90;
        x_number_of_ticks    := 10; x_tick_duration_days := 9;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 120)    -- 120 days
  THEN
        x_graph_duration     := 120;
        x_number_of_ticks    := 10; x_tick_duration_days := 10;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 150)    -- 150 days
  THEN
        x_graph_duration     := 150;
        x_number_of_ticks    := 10; x_tick_duration_days := 15;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';

  ELSIF (l_date_range <= 180)    -- 180 days
  THEN
        x_graph_duration     := 180;
        x_number_of_ticks    := 10; x_tick_duration_days := 18;
        x_start_offset_value := 1;  x_start_offset_unit := 'DAY';
        x_output_date_format := 'ddmon ';
  ELSE
	RAISE invalid_date;
 END IF; --}


EXCEPTION

 WHEN invalid_date
 THEN
     raise;
     --- dbms_output.put_line('Start date: ' || to_char(p_start_date, 'dd-Mon-yyyy hh24:mi'));
     --- dbms_output.put_line('End date  : ' || to_char(p_end_date, 'dd-Mon-yyyy hh24:mi'));
     --- dbms_output.put_line('Actual duration: ' || to_char(p_end_date - p_start_date));
      --- dbms_output.put_line('Exception - invalid date');
END get_date_params;


-----------------------------------------------------------------
----              get_tick_values                        ----
-----------------------------------------------------------------
--
-- Start of Comments
--
-- API Name: get_date_params
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called internally within this package and
--           is used to get calculate the dates with the parameters
--           from get_date_params
--           Most of the parameters are the out parameters of
--           get_date_params
--
-- Parameters:
--
--       p_start_date         IN  DATE
--            Required - start date for determining the range
--
--       p_end_date           IN  DATE
--            Required - end date of the range
--
--       p_graph_duration     OUT NUMBER
--            This is the duration of the graph in days
--
--       p_number_of_ticks    IN  PLS_INTEGER
--            This is the number of ticks.  The actual number of ticks
--            will be one more than what is given here
--
--       p_tick_duration_days IN  NUMBER
--            This is the duration of each tick in days
--
--       p_start_offset_value IN  VARCHAR2
--            Since in most cases, it would not be wise to start the
--            graph exactly on the start date, we round down to the
--            nearest time unit based on the scale of the graph.  This
--            contains the value e.g 5 if the rounding is to the nearest
--            5 mins
--
--       p_start_offset_unit  IN  VARCHAR2
--            This contains the unit of rounding as explained above
--
--       p_output_date_format OUT VARCHAR2
--            This contains the format in which the ticks are
--            labelled.  Depending on the scale of the graph, only
--            the date, or the date+time or only the time is shown
--
--       x_graph_start_date   OUT  DATE
--            If the start date was less than an hour earlier than
--            the end date, then the new start date for the graph
--            will be an hour earlier than the end date
--
-----------------------------------------------------------------
--
PROCEDURE get_tick_values (
                  p_start_date         IN         DATE,
                  p_end_date           IN         DATE,
		  p_graph_duration     IN         NUMBER,
		  p_number_of_ticks    IN         PLS_INTEGER,
		  p_tick_duration_days IN         NUMBER,
		  p_start_offset_value IN         PLS_INTEGER,
		  p_start_offset_unit  IN         VARCHAR2,
		  p_output_date_format IN         VARCHAR2,
		  x_graph_start_date   OUT NOCOPY DATE,
                  x_graph_end_date     OUT NOCOPY DATE,
		  x_graph_duration     OUT NOCOPY NUMBER,
		  x_number_of_ticks    OUT NOCOPY NUMBER,
		  x_tick_date_values   OUT NOCOPY dateTblType
	         ) IS

l_graph_duration     NUMBER;

l_start_format_num   NUMBER;
l_graph_start_date   DATE;
l_start_minutes      PLS_INTEGER;

l_round_date_format      VARCHAR2(20);
l_start_init_date_format VARCHAR2(20);
l_tick_server_date       DATE;
l_tick_client_date       DATE;

excp_invalid_timezone    EXCEPTION;
excp_invalid_data        EXCEPTION;

l_timezone_conversion_reqd  VARCHAR2(1);

l_client_timezone_id     NUMBER;
l_server_timezone_id     NUMBER;

l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(250);

l_number_of_ticks        PLS_INTEGER;


BEGIN

--- dbms_output.put_line('------------ Entering get_tick_values. Input parameters:');
--- dbms_output.put_line('p_start_date = ' || to_char(p_start_date, 'dd-mon-yyyy hh24:mi:ss'));
--- dbms_output.put_line('p_end_date = ' || to_char(p_end_date, 'dd-mon-yyyy hh24:mi:ss'));
--- dbms_output.put_line('p_number_of_ticks = ' || to_char(p_number_of_ticks));
--- dbms_output.put_line('p_tick_duration_days = ' || p_tick_duration_days);
--- dbms_output.put_line('  p_tick_duration_hours = ' || p_tick_duration_days*24);
--- dbms_output.put_line('  p_tick_duration_minutes = ' || p_tick_duration_days*24*60);
--- dbms_output.put_line('p_start_offset_value = '|| to_char(p_start_offset_value));
--- dbms_output.put_line('p_start_offset_unit   = '||p_start_offset_unit );
--- dbms_output.put_line('p_output_date_format  = '||p_output_date_format );
--- dbms_output.put_line('------------ End Input parameters');

-- Initialize output tick values. This is required to prevent a
-- no_data_found in the calling procedure

FOR i IN 1..g_max_no_ticks
LOOP
  x_tick_date_values(i) := NULL;
END LOOP;

-- This code does the rounding of the start date to the nearest
-- specified unit for the range being displayed. For example, if the
-- duration is 2 days, then the start time is rounded off to the
-- nearest hour i.e. the graph starts at the nearest hour before the
-- start date. The offset_unit indicates the degree to which it should
-- be rounded - nearest hour, min, day, etc. The round_date_format is
-- used to extract the part of the date that will be rounded. For
-- example, if we decide to round to the nearest 5 mins, then the
-- round_date_format will be 'mi' and the the start_offset_value will
-- be 5.

-- Note that though the term "rounding" is used in the code, this is
-- not true rounding. We always round down. i.e. rounding 10:55 to the
-- nearest hour will be 10:00 and not 11:00

-- The start_init_date_format gives the format of the rest of the
-- string. In the above example, the minutes will be rounded off say
-- :43 becomes :40 and then the :40 is appended to the rest of the
-- date. Hence 02-Jun-04 22:43 becomes 02-Jun-04 22:40

     IF p_start_offset_unit = 'MIN'
     THEN
	 l_round_date_format       := 'mi';
         l_start_init_date_format  := 'yyyy/mm/dd hh24:';
     ELSIF p_start_offset_unit = 'HOUR'
     THEN
	 l_round_date_format       := 'hh24';
         l_start_init_date_format  := 'yyyy/mm/dd ';
     ELSIF p_start_offset_unit = 'DAY'
     THEN
	 l_round_date_format       := 'dd';
         l_start_init_date_format  := 'yyyy/mm/dd';
     ELSE
       -- junk value, raise exception
	 RAISE excp_invalid_data;
     END IF;

--- dbms_output.put_line('20.2: l_round_date_format = ' || l_round_date_format);
--- dbms_output.put_line('20.3: l_start_init_date_format = ' || l_start_init_date_format);

-- An offset value of 1 indicates that rounding has to be done to the
-- nearest multiple of the start_offset_value. In our example, this
-- would be the nearest 5 mins
-- Extract the rounding factor (:43 in our example), round it and then
-- append it to the rest of the string as described above

     IF p_start_offset_value > 1
     THEN
       IF p_start_offset_unit = 'HOUR' OR
	  p_start_offset_unit = 'MIN'
       THEN
          l_start_format_num := to_number(to_char(p_start_date, l_round_date_format));
	  l_start_format_num := l_start_format_num - MOD(l_start_format_num, p_start_offset_value);
          l_graph_start_date := to_date(to_char(p_start_date, l_start_init_date_format) ||
				 to_char(l_start_format_num), l_start_init_date_format || l_round_date_format);
       ELSE
	  RAISE excp_invalid_data;
       END IF;
     ELSIF p_start_offset_unit = 'HOUR'
      THEN
           l_graph_start_date := to_date(to_char(p_start_date,'yyyy/mm/dd hh24'),'yyyy/mm/dd hh24');
     ELSIF p_start_offset_unit = 'MIN'
      THEN
           l_graph_start_date := to_date(to_char(p_start_date,'yyyy/mm/dd hh24:mi'),'yyyy/mm/dd hh24:mi');
     ELSIF p_start_offset_unit = 'DAY'
      THEN
	   l_graph_start_date := TRUNC(p_start_date);
      ELSE
	   RAISE excp_invalid_data;
     END IF;

--- dbms_output.put_line('20.4: l_graph_start_date = ' || to_char(l_graph_start_date,'dd-mon-yyyy hh24:mi:ss'));

-- Once the start date is obtained, we have to see whether we fell
-- short of the duration. This can happen as in the following example:

-- The start date is 7-Jun 11:23. The end date is 9-Jun 11:15. The
-- duration of the graph in the get_date_params procedure will be
-- determined to be 2 days.

-- When we apply rounding, we will round the start date to the nearest
-- hour: 07-Jun 11:00. We will then have ticks for every 4 hours,
-- resulting in a total of 48 hours. This will bring us to 09-Jun
-- 11:00. If we stop the graph here, this will mean that all points
-- after this will be left out (which is where most of the action for
-- an auction will be - towards the end).

-- The solution for this will be to add an extra tick to the graph to
-- take it to 10-Jun 03:00. The graph now spans a little more than 2
-- days. This will be better than bumping the entire graph to the next
-- higher range of 3 days which will cause the points to get clustered
-- together

     x_graph_start_date := l_graph_start_date;

-- Determine whether the end date of the graph with the duration is
-- still short. If yes, add an extra tick to the graph
-- The graph end date and duration can be determined after the last
-- tick is added

    --- dbms_output.put_line('Graph start_date = ' || to_char(l_graph_start_Date,'dd-mon-yyyy hh24:mi:ss'));
    --- dbms_output.put_line('Graph end_date = ' || to_char(p_end_date,'dd-mon-yyyy hh24:mi:ss'));
    --- dbms_output.put_line('Graph duration = ' || p_graph_duration);
    --- dbms_output.put_line('New end_date = ' || to_char(l_graph_start_date + p_graph_duration,'dd-mon-yyyy hh24:mi:ss'));
    IF p_end_date > l_graph_start_date + p_graph_duration
    THEN
        l_number_of_ticks  := p_number_of_ticks + 1;
    ELSE
	l_number_of_ticks  := p_number_of_ticks;
    END IF;

-- The dates have to be displayed in the timezone of the user. For
-- this, we first determine if timezones have been implemented
-- Per Kris Doherty, this can be determined by verifying if the
-- profiles for the client and server timezone are set. It should not
-- be determined by a call to fnd_timezones.get_timezone_conversion_reqd.
-- If the server and client timezones are the same, no conversion is
-- required

     l_client_timezone_id := fnd_profile.value('CLIENT_TIMEZONE_ID');
     l_server_timezone_id := fnd_profile.value('SERVER_TIMEZONE_ID');

     IF l_client_timezone_id IS NULL OR
	l_server_timezone_id IS NULL OR
	l_client_timezone_id = l_server_timezone_id
     THEN
	   l_timezone_conversion_reqd := 'N';
     ELSE
	   l_timezone_conversion_reqd := 'Y';
     END IF;

--- dbms_output.put_line('Client tiemzone : ' || l_client_timezone_id);
--- dbms_output.put_line('Server tiemzone : ' || l_server_timezone_id);

-- The l_number_of_ticks corresponds to the number of divisions of the
-- graph. However, we have to plot 1 more tick to include the start
-- and end ticks. Hence the addition of 1 in the loop below
-- For example, if there are two divisions Jan-Feb, Feb-Mar on the
-- graph, there are three ticks corresponding to Jan, Feb and Mar
-- respectively

     --- dbms_output.put_line('number of ticks =  '||l_number_of_ticks);

     FOR i IN 1..l_number_of_ticks + 1
     LOOP -- {

--- dbms_output.put_line('Entered for loop i = ' || i );
      l_tick_server_date :=  l_graph_start_date + (i-1) * p_tick_duration_days;

--- dbms_output.put_line('Tick server date  ' || i || ' : ' || to_char(l_tick_server_date,'dd-mon-yyyy hh24:mi:ss'));

     -- Convert the date to the client timezone if timezones
     -- are enabled.  Otherwise, return as is

     IF l_timezone_conversion_reqd = 'Y'
     THEN
     --- dbms_output.put_line('Timezone enabled - calling api');
     --- dbms_output.put_line('Timezone l_server_timezone_id = ' ||l_server_timezone_id);
     --- dbms_output.put_line('Timezone l_client_timezone_id = ' ||l_client_timezone_id);
     --- dbms_output.put_line('Timezone l_server_date = ' ||to_char(l_tick_server_date,'dd-mon-yyyy hh24:mi:ss'));
         hz_timezone_pub.get_time(
               p_api_version     => 1,
               p_init_msg_list   => 'F',
               p_source_tz_id    => l_server_timezone_id,
               p_dest_tz_id      => l_client_timezone_id,
               p_source_day_time => l_tick_server_date,
               x_dest_day_time   => l_tick_client_date,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data);

     --- dbms_output.put_line('After timezone api call');
--- dbms_output.put_line('Tick client date ' || i || ' : ' || to_char(l_tick_client_date,'dd-mon-yyyy hh24:mi:ss'));

	IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
	THEN
	  -- Temporary code...have better handling later on
	    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	x_tick_date_values(i) := l_tick_client_date;

     ELSE
        x_tick_date_values(i) := l_tick_server_date;
     END IF;

     END LOOP;  -- }

-- Now determine the end date in the server timezone. It should be the
-- last element added in the loop

     x_graph_end_date := l_tick_server_date;
     x_graph_duration := x_graph_end_date - x_graph_start_date;
     x_number_of_ticks:= l_number_of_ticks;

--- dbms_output.put_line('Number of ticks: ' || x_number_of_ticks);
--- dbms_output.put_line('Graph end date: ' || to_char(x_graph_end_date, 'dd-mon-yyyy hh24:mi:ss'));
--- dbms_output.put_line('Graph duration: ' || to_char(x_Graph_duration));

EXCEPTION
WHEN excp_invalid_data
THEN
  -- set appropriate out parameters; temporary code below
   Raise;
WHEN excp_invalid_timezone
THEN
  -- set appropriate out parameters; temporary code below
   raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
   RAISE;
END get_tick_values;

-----------------------------------------------------------------
----              get_time_axis_tick_labels                  ----
-----------------------------------------------------------------
---- See specs for detailed procedure level comments

PROCEDURE  get_time_axis_tick_labels(
		 p_auction_header_id     IN        NUMBER,
		 p_graph_start_date      IN        DATE,
		 p_auction_close_date    IN        DATE,
                 x_graph_start_date     OUT NOCOPY DATE,
		 x_graph_end_date       OUT NOCOPY DATE,
		 x_number_of_ticks      OUT NOCOPY NUMBER,
		 x_multiplier           OUT NOCOPY NUMBER,
		 x_tick_length          OUT NOCOPY NUMBER,
                 x_tick_label_1         OUT NOCOPY VARCHAR2,
                 x_tick_label_2         OUT NOCOPY VARCHAR2,
                 x_tick_label_3         OUT NOCOPY VARCHAR2,
                 x_tick_label_4         OUT NOCOPY VARCHAR2,
                 x_tick_label_5         OUT NOCOPY VARCHAR2,
                 x_tick_label_6         OUT NOCOPY VARCHAR2,
                 x_tick_label_7         OUT NOCOPY VARCHAR2,
                 x_tick_label_8         OUT NOCOPY VARCHAR2,
                 x_tick_label_9         OUT NOCOPY VARCHAR2,
                 x_tick_label_10        OUT NOCOPY VARCHAR2,
                 x_tick_label_11        OUT NOCOPY VARCHAR2,
                 x_tick_label_12        OUT NOCOPY VARCHAR2,
                 x_tick_label_13        OUT NOCOPY VARCHAR2,
                 x_tick_label_14        OUT NOCOPY VARCHAR2)  IS

l_graph_start_date     DATE;
l_graph_new_start_date DATE;
l_number_of_ticks     PLS_INTEGER;
l_start_offset_value  PLS_INTEGER;
l_start_offset_unit   VARCHAR2(20);
l_output_date_format  VARCHAR2(20);
l_graph_duration      NUMBER;
l_tick_duration_days  NUMBER;
l_final_number_of_ticks  PLS_INTEGER;
l_final_graph_duration   NUMBER;

l_tick_date_values         dateTblType;


BEGIN  -- {

-- Initialize

x_number_of_ticks  := 0;
x_tick_label_1     := NULL;
x_tick_label_2     := NULL;
x_tick_label_3     := NULL;
x_tick_label_4     := NULL;
x_tick_label_5     := NULL;
x_tick_label_6     := NULL;
x_tick_label_7     := NULL;
x_tick_label_8     := NULL;
x_tick_label_9     := NULL;
x_tick_label_10    := NULL;
x_tick_label_11    := NULL;
x_tick_label_12    := NULL;
x_tick_label_13    := NULL;
x_tick_label_14    := NULL;

-- If the front end already knows the start date of the graph and is
-- just trying to get the tick labels, then we do not need to hit the
-- negotiation tables. This will happen when the user switches context
-- from one line to another. The front end does not store the ticks
-- for each line but will store the graph start date. This procedure
-- will be called to get the ticks

l_graph_start_date := p_graph_start_date;

--Commenting If condition as it is no longer required.
-- We may need this when we plan to implement zoom in live console
/*IF l_graph_start_date IS NULL -- {
THEN */

-- The procedure could be called to determine ticks for the entire
-- auction or for a particular line

-- If the context is header, check to see if any bids for the auctions
-- As part of the check, get the earliest publish date. This will be
-- the leftmost point of the graph. Only active/archived bids are
-- shown; disqualified bids are omitted from the graph


    SELECT MIN(bh.publish_date)
      INTO l_graph_start_date
      FROM pon_bid_headers bh
     WHERE bh.auction_header_id = p_auction_header_id
       AND bh.bid_status        IN ('ACTIVE', 'ARCHIVED');

-- If no bids were available for the context, then let the caller know
-- to not display the graph

  IF l_graph_start_date IS NULL  -- {
  THEN
      x_number_of_ticks := 0;  -- this indicates no data to the caller
      RETURN;
  ELSIF ((p_auction_close_date-l_graph_start_date) > 180)
  THEN
      l_graph_start_date := p_auction_close_date-180;
  END IF;  -- }

--END IF;  -- }


-- Now that the start and end dates are known, determine each tick and
-- other parameters

get_date_params(  p_start_date         => l_graph_start_date,
                  p_end_date           => p_auction_close_date,
                  x_graph_start_date   => l_graph_new_start_date,
                  x_graph_duration     => l_graph_duration,
                  x_number_of_ticks    => l_number_of_ticks,
                  x_tick_duration_days => l_tick_duration_days,
                  x_start_offset_value => l_start_offset_value,
                  x_start_offset_unit  => l_start_offset_unit,
                  x_output_date_format => l_output_date_format
		);

get_tick_values (
                  p_start_date         => l_graph_new_start_date,
                  p_end_date           => p_auction_close_date,
		  p_graph_duration     => l_graph_duration,
		  p_number_of_ticks    => l_number_of_ticks,
		  p_tick_duration_days => l_tick_duration_days,
		  p_start_offset_value => l_start_offset_value,
		  p_start_offset_unit  => l_start_offset_unit,
		  p_output_date_format => l_output_date_format,
                  x_graph_start_date   => x_graph_start_date,
                  x_graph_end_date     => x_graph_end_date,
		  x_graph_duration     => l_final_graph_duration,
		  x_number_of_ticks    => l_final_number_of_ticks,
		  x_tick_date_values   => l_tick_date_values
	         );

-- Return the scalar equivalents of l_tick_values. No need to check
-- for no_data_found as get_tick_values() will ensure that all values
-- are initialized

x_tick_label_1  := to_char(l_tick_date_values(1),  l_output_date_format);
x_tick_label_2  := to_char(l_tick_date_values(2),  l_output_date_format);
x_tick_label_3  := to_char(l_tick_date_values(3),  l_output_date_format);
x_tick_label_4  := to_char(l_tick_date_values(4),  l_output_date_format);
x_tick_label_5  := to_char(l_tick_date_values(5),  l_output_date_format);
x_tick_label_6  := to_char(l_tick_date_values(6),  l_output_date_format);
x_tick_label_7  := to_char(l_tick_date_values(7),  l_output_date_format);
x_tick_label_8  := to_char(l_tick_date_values(8),  l_output_date_format);
x_tick_label_9  := to_char(l_tick_date_values(9),  l_output_date_format);
x_tick_label_10 := to_char(l_tick_date_values(10), l_output_date_format);
x_tick_label_11 := to_char(l_tick_date_values(11), l_output_date_format);
x_tick_label_12 := to_char(l_tick_date_values(12), l_output_date_format);
x_tick_label_13 := to_char(l_tick_date_values(13), l_output_date_format);
x_tick_label_14 := to_char(l_tick_date_values(14), l_output_date_format);

-- The last tick is held in l_tick_server_date. Hence the duration for
-- the graph is from the start date until the last tick. This
-- corresponds to 1440 in numeric terms since the console plots all
-- date/time points as numbers. The total length of the x-axis between
-- all ticks is 1440. Hence, given a date to be plotted, the console
-- will determine its numeric value by:

-- Total graph range = 1440
-- Hence current date is: (Current date - graph start date)/total_graph_range * 1440

-- Current date - graph start date is determined by the console.
-- Current date will be the publish date of each bid being plotted

  --- dbms_output.put_line('20.25: l_graph_duration = ' || l_graph_duration);
  --- dbms_output.put_line('20.26: g_graph_range = ' || g_graph_range);

     x_multiplier     := g_graph_range/l_final_graph_duration;
     x_tick_length    := g_graph_range/l_final_number_of_ticks;
     x_number_of_ticks:= l_final_number_of_ticks;

  --- dbms_output.put_line('20.30: x_multiplier =  ' || x_multiplier);
  --- dbms_output.put_line('20.40: x_tick_length =  ' || x_tick_length);
  --- dbms_output.put_line('20.50: x_graph_end_date =  ' || to_char(x_graph_end_date,'dd-mon-yyyy hh24:mi:ss'));


EXCEPTION
WHEN NO_DATA_FOUND
 THEN
    x_number_of_ticks := 0;
    RETURN;

WHEN OTHERS
 THEN
   RAISE;

END get_time_axis_tick_labels;


-----------------------------------------------------------------
----              check_estimated_qty_available              ----
-----------------------------------------------------------------
---- See specs for detailed procedure level comments

PROCEDURE  check_estimated_qty_available(
			       p_auction_header_id       IN        NUMBER,
			       p_auction_line_number     IN        NUMBER,
			       x_est_qty_available_flag OUT NOCOPY VARCHAR2) IS

BEGIN

  x_est_qty_available_flag := 'Y';

-- If p_auction_line_number is -1, this indicates that the procedure is being
-- called at the header level. Check if any lines do not have
-- quantity. If a line number is provided, then query for the specific
-- line number

  IF NVL(p_auction_line_number, -1) = -1
  THEN
    SELECT 'N'
      INTO x_est_qty_available_flag
      FROM dual
     WHERE EXISTS (SELECT 1
		   FROM pon_auction_item_prices_all al
		  WHERE al.auction_header_id = p_auction_header_id
            AND al.group_type NOT IN ('GROUP','LOT_LINE')
            AND al.order_type_lookup_code <> 'FIXED PRICE'
		    AND NVL(quantity, 0)     = 0);
   ELSE
     SELECT 'N'
       INTO x_est_qty_available_flag
       FROM dual
      WHERE EXISTS (SELECT 1
		   FROM pon_auction_item_prices_all al
		  WHERE al.auction_header_id = p_auction_header_id
		    AND al.line_number       = p_auction_line_number
            AND al.group_type NOT IN ('GROUP','LOT_LINE')
            AND al.order_type_lookup_code <> 'FIXED PRICE'
		    AND NVL(quantity, 0)     = 0);
   END IF;

EXCEPTION

  WHEN NO_DATA_FOUND
   THEN
     x_est_qty_available_flag := 'Y';

  WHEN OTHERS THEN
       RAISE;

END check_estimated_qty_available;


-----------------------------------------------------------------
----              upgrade_bid_colors                         ----
-----------------------------------------------------------------
---- See specs for detailed procedure level comments

PROCEDURE upgrade_bid_colors (p_auction_header_id IN NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

l_color_sequence_id  PLS_INTEGER;

TYPE rowidTblType IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

l_rowid_tbl rowidTblType;

-- Determine the latest bid for a combination of a supplier, supplier
-- site and contact. After identifying the latest bid, mark all the
-- bids from the same supplier/site/contact combination with the same
-- color so that they are shown as being related on the graph
-- Bids that don't have a site will have a site id of -1 hence no need
-- for an NVL

CURSOR c1 IS
  SELECT bh.trading_partner_id,
         bh.trading_partner_contact_id,
	 bh.vendor_site_id,
	 MAX(bid_number)
    FROM pon_bid_headers bh
   WHERE bh.auction_header_id = p_auction_header_id
  GROUP BY
         bh.trading_partner_id,
         bh.trading_partner_contact_id,
	 bh.vendor_site_id;

BEGIN -- {

-- Colors may have been partially assigned to some bids. This happens
-- if bidding for the negotiation had started before the upgrade for FPK.
-- However, we will ignore the assigned colors and reassign them for
-- simplicity - and because the possibility of this happening is rare,
-- since it is extremely unlikely that a company will perform its
-- upgrade in the middle of a negotiation

-- Only suppliers with some active bids are visible in the live
-- console. In the normal course of events, colors are assigned to the
-- first bid and are then carried forward to every subsequent bid (by
-- the same user, same supplier, same site combination; the old bid
-- becomes archived) i.e. all the bids in a "chain" will have the same
-- color. For our strategy, we will start with the latest bid,
-- assigning them a color in sequence. Since there is no column to
-- indicate the source of a rebid (unless it is from a previous
-- round), we will update all bids for the auction that have the same
-- supplier, site and contact since this combination has to be unique
-- for an active bid

l_color_sequence_id := -1;

FOR c IN c1
LOOP -- {

  l_color_sequence_id := l_color_sequence_id + 1;

-- Update all related bids with the same color
-- site_id is -1 if it is not there - hence no nvl
-- last_update_login field is missing in the table. Add the update to
-- that column after the column is introduced

  UPDATE pon_bid_headers bh
     SET bh.color_sequence_id = l_color_sequence_id,
	 bh.last_update_date = sysdate,
	 bh.last_updated_by  = fnd_global.user_id
   WHERE bh.trading_partner_id         = c.trading_partner_id
     AND bh.trading_partner_contact_id = c.trading_partner_contact_id
     AND bh.vendor_site_id             = c.vendor_site_id
	 AND bh.auction_header_id = p_auction_header_id;

END LOOP; -- }

-- Update the count on the negotiation to the last value
-- last_update_login field is missing in the table. Add the update to
-- that column after the column is introduced

UPDATE pon_auction_headers_all ah
   SET ah.max_bid_color_sequence_id = l_color_sequence_id,
       ah.last_update_date          = sysdate,
       ah.last_updated_by           = fnd_global.user_id
 WHERE ah.auction_header_id   = p_auction_header_id;

-- Commit because this is an autonomous transaction

COMMIT;

EXCEPTION
WHEN OTHERS
 THEN
    RAISE;
END upgrade_bid_colors; -- }


-----------------------------------------------------------------
----              record_supplier_activity                   ----
-----------------------------------------------------------------

PROCEDURE  record_supplier_activity(
                  p_auction_header_id            IN        NUMBER,
                  p_auction_header_id_orig_amend IN        NUMBER,
                  p_trading_partner_id           IN        NUMBER,
                  p_trading_partner_contact_id   IN        NUMBER,
                  p_session_id                   IN        NUMBER,
                  p_last_activity_code           IN        VARCHAR2,
                  x_record_status               OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;      -- {

  l_api_name      CONSTANT VARCHAR2(25)  := 'record_supplier_activity';
  l_progress      VARCHAR2 (3);

  l_sysdate       DATE;
  l_user_id       NUMBER;
  l_login_id      NUMBER;

  l_last_activity_code pon_supplier_activities.last_activity_code%TYPE;
  l_rowid ROWID;
  l_insert_flag VARCHAR2(1);

  CURSOR c_supplier_activity IS
  SELECT last_activity_code
         , rowid
  FROM   pon_supplier_activities
  WHERE  auction_header_id_orig_amend = p_auction_header_id_orig_amend
  AND    trading_partner_id = p_trading_partner_id
  AND    trading_partner_contact_id = p_trading_partner_contact_id
  AND    last_action_flag = 'Y';

  l_debug_statement  BOOLEAN;
  l_debug_unexpected BOOLEAN;


BEGIN

  -- initialize the out parameter
  x_record_status := FND_API.G_TRUE;

  -- Initialize other variables
  l_sysdate     := SYSDATE;
  l_user_id     := fnd_global.user_id;
  l_login_id    := fnd_global.login_id;
  l_insert_flag := 'N';

  l_debug_statement  := is_debug_statement_on;
  l_debug_unexpected := is_debug_unexpected_on;

  l_progress := '000';

  OPEN  c_supplier_activity;
  FETCH c_supplier_activity INTO l_last_activity_code, l_rowid;
  IF    c_supplier_activity%FOUND THEN
        l_progress := '001';

        -- check activity codes are same and update the record.
        IF l_last_activity_code = p_last_activity_code THEN
            l_progress := '002';
            -- activities are same just update the activity time
            UPDATE pon_supplier_activities
            SET    last_activity_time  = l_sysdate
                   , last_update_date  = l_sysdate
                   , last_updated_by   = l_user_id
                   , last_update_login = l_login_id
            WHERE  rowid = l_rowid;
        ELSE
            l_progress := '003';
            -- activities are different.
            -- disable previous record and set insert flag
            UPDATE pon_supplier_activities
            SET    last_action_flag    = 'N'
                   , last_update_date  = l_sysdate
                   , last_updated_by   = l_user_id
                   , last_update_login = l_login_id
            WHERE  rowid = l_rowid;

            l_insert_flag := 'Y';
        END IF;
  ELSE

        l_progress := '004';
            -- no records found, set insert flag
            l_insert_flag := 'Y';
  END IF;
  CLOSE c_supplier_activity;

  l_progress := '005';

  IF (l_insert_flag = 'Y') THEN

    l_progress := '006';
    INSERT INTO pon_supplier_activities
                ( auction_header_id
                , auction_header_id_orig_amend
                , trading_partner_id
                , trading_partner_contact_id
                , session_id
                , last_activity_code
                , last_activity_time
                , last_action_flag
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login)
    VALUES      ( p_auction_header_id
                , p_auction_header_id_orig_amend
                , p_trading_partner_id
                , p_trading_partner_contact_id
                , p_session_id
                , p_last_activity_code
                , l_sysdate
                , 'Y'
                , l_sysdate
                , l_user_id
                , l_sysdate
                , l_user_id
                , l_login_id);
  END IF;

  -- commit the autonomous transaction
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    x_record_status := FND_API.G_FALSE;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(log_level => FND_LOG.level_unexpected
                    ,module    => g_pkg_name||'.'||l_api_name
                    ,message   => 'unexpected error '||l_progress
                    );
    END IF;
    ROLLBACK;
    RETURN;
END record_supplier_activity; --}

-----------------------------------------------------------------
----              update_supplier_access                     ----
-----------------------------------------------------------------
PROCEDURE  update_supplier_access(p_auction_header_id             IN  NUMBER
	                         , p_auction_header_id_orig_amend IN NUMBER
	                         , p_supplier_trading_partner_id  IN NUMBER
	                         , p_buyer_tp_contact_id          IN NUMBER
	                         , p_lock_status                  IN VARCHAR2
	                         , p_lock_reason                  IN VARCHAR2
	                         , x_record_status                OUT NOCOPY VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;      -- {

  l_api_name      CONSTANT VARCHAR2(25)  := 'update_supplier_access';
  l_progress      VARCHAR2 (3);

  l_sysdate       DATE;
  l_user_id       NUMBER;
  l_login_id      NUMBER;

  l_debug_statement  BOOLEAN;
  l_debug_unexpected BOOLEAN;

BEGIN

  -- initialize the out parameter
  x_record_status := FND_API.G_TRUE;

  -- Initialize other variables
  l_sysdate     := SYSDATE;
  l_user_id     := fnd_global.user_id;
  l_login_id    := fnd_global.login_id;

  l_debug_statement  := is_debug_statement_on;
  l_debug_unexpected := is_debug_unexpected_on;

  l_progress := '000';

  -- update the record with the orig header id /trading partner id
  UPDATE pon_supplier_access
  SET    active_flag = 'N'
         , last_update_date  = l_sysdate
         , last_updated_by   = l_user_id
         , last_update_login = l_login_id
  WHERE  auction_header_id_orig_amend = p_auction_header_id_orig_amend
  AND    supplier_trading_partner_id = p_supplier_trading_partner_id;

  -- if not found error do nothing
  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  l_progress := '001';

  -- now insert the new record
  INSERT INTO pon_supplier_access(auction_header_id_orig_amend
                                 ,supplier_trading_partner_id
                                 ,lock_date
                                 ,buyer_tp_contact_id
                                 ,lock_status
                                 ,active_flag
                                 ,auction_header_id
                                 ,lock_reason
                                 ,creation_date
                                 ,created_by
                                 ,last_update_date
                                 ,last_updated_by
                                 ,last_update_login
                                 )
  VALUES                         (p_auction_header_id_orig_amend
                                 ,p_supplier_trading_partner_id
                                 ,l_sysdate
                                 ,p_buyer_tp_contact_id
                                 ,p_lock_status
                                 ,'Y'
                                 ,p_auction_header_id
                                 ,p_lock_reason
                                 ,l_sysdate
                                 ,l_user_id
                                 ,l_sysdate
                                 ,l_user_id
                                 ,l_login_id);

  l_progress := '002';
  -- commit the autonomous transaction
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
--DBMS_OUTPUT.PUT_LINE('error' ||SQLERRM ||' '||SQLCODE);
    x_record_status := FND_API.G_FALSE;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(log_level => FND_LOG.level_unexpected
                    ,module    => g_pkg_name||'.'||l_api_name
                    ,message   => 'unexpected error '||l_progress
                    );
    END IF;
    RETURN;
END update_supplier_access; --}

-----------------------------------------------------------------
----              calculate_console_summary                        ----
-----------------------------------------------------------------
--
-- Start of Comments
--
-- API Name: calculate_console_summary
--
-- Type    : public
--
-- Pre-reqs: None
--
-- Function: This API is called from ConsoleAMImpl.java to calculate
--           Auction Value, Current Value, Optimal Value(based on Auto
--           Award Recommendation), no bid value and num of lines without bids
--
-- Parameters:
--
--       P_AUCTION_ID         IN  NUMBER
--            Required - Auction_header_id of the negotiation
--
--       x_auction_value     OUT NUMBER
--            Total value of the negotiation, calculated based on
--            line qty and current price
--       x_current_value     OUT NUMBER
--            Total current value of the negotiation, calculated based on
--            awarded qty and current price
--       x_optimal_value     OUT NUMBER
--            Total Value of the negotiation, calculated based on
--            awarded qty and bid price
--       x_no_bid_value     OUT NUMBER
--            Total value of the lines that didn't receive bids, calculated
--            based on line qty and current price
--       x_no_bid_lines     OUT NUMBER
--            Number of lines without bids
-----------------------------------------------------------------

PROCEDURE calculate_console_summary( p_auction_id    IN NUMBER,
                                     x_auction_value OUT NOCOPY NUMBER,
                                     x_current_value OUT NOCOPY NUMBER,
                                     x_optimal_value OUT NOCOPY NUMBER,
                                     x_no_bid_value  OUT NOCOPY NUMBER,
                                     x_no_bid_lines  OUT NOCOPY NUMBER
                                     )
 IS

  TYPE line_number_tbl_type   IS TABLE OF pon_bid_item_prices.line_number%TYPE;
  TYPE bid_price_tbl_type     IS TABLE OF pon_bid_item_prices.price%TYPE;
  TYPE bid_qty_tbl_type       IS TABLE OF pon_bid_item_prices.quantity%TYPE;
  TYPE current_price_tbl_type IS TABLE OF pon_auction_item_prices_all.current_price%TYPE;
  TYPE auction_qty_tbl_type   IS TABLE OF pon_auction_item_prices_all.quantity%TYPE;

  l_line_number_tbl          line_number_tbl_type;
  l_bid_price_tbl            bid_price_tbl_type;
  l_bid_qty_tbl              bid_qty_tbl_type;
  l_current_price_tbl        current_price_tbl_type;
  l_auction_qty_tbl          auction_qty_tbl_type;
  l_line_number              PON_BID_ITEM_PRICES.line_number%TYPE;
  l_qty_remaining            NUMBER;
  l_current_value            NUMBER := 0;
  l_optimal_value            NUMBER := 0;
  l_no_bid_lines             NUMBER := 0;
  l_no_bid_value             NUMBER := 0;
  l_auction_value            NUMBER := 0;
  l_prev_line_number         NUMBER;

BEGIN
-- To calculate auction value
  BEGIN
       SELECT  SUM(nvl(current_price, 0)
             * decode (order_type_lookup_code, 'FIXED PRICE', 1, quantity)) AUCTION_VALUE,
             SUM(decode(nvl(number_of_bids,0),0,1,0)) NO_BID_LINES,
             SUM(decode(nvl(number_of_bids,0),0,
                   (nvl(current_price, 0) * decode(order_type_lookup_code, 'FIXED PRICE', 1, quantity)),0)) NO_BID_VALUE
         INTO l_auction_value,
              l_no_bid_lines,
              l_no_bid_value
         FROM PON_AUCTION_ITEM_PRICES_ALL
        WHERE group_type in ('LOT', 'LINE', 'GROUP_LINE')
          AND auction_header_id = P_AUCTION_ID;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_auction_value := 0;
        l_no_bid_value := 0;
        l_no_bid_lines := 0;
     WHEN OTHERS THEN
        RAISE;
  END;
  x_auction_value := l_auction_value;
  x_no_bid_value := l_no_bid_value;
  x_no_bid_lines := l_no_bid_lines;

-- To calculate current value and optimal value.
-- Used in potential savings calculation in ConsoleAMImpl.java
-- bid_quantity: For Blankets bid quantity will be null, so defaulting it to auction qty
-- Auction qty : For Fixed price lines auction qty will be null, so defaulting it to 1
 BEGIN
   SELECT
       bl.line_number,
       bl.price bid_price,
	   nvl(bl.quantity,nvl(ai.quantity,1)) bid_quantity,
	   ai.current_price,
	   nvl(ai.quantity,1) auction_qty
     BULK COLLECT INTO l_line_number_tbl, l_bid_price_tbl, l_bid_qty_tbl, l_current_price_tbl, l_auction_qty_tbl
      FROM pon_bid_headers bh,
           pon_bid_item_prices bl,
           pon_auction_headers_all ah,
           pon_auction_item_prices_all ai
     WHERE ah.auction_header_id = bh.auction_header_id
       and bh.auction_header_id = bl.auction_header_id
       and bh.bid_number = bl.bid_number
       and bh.bid_status = 'ACTIVE'
       and bh.auction_header_id = P_AUCTION_ID
       and nvl(bh.SHORTLIST_FLAG, 'Y') = 'Y'
       and ai.auction_header_id = ah.auction_header_id
       and ai.line_number = bl.line_number
       AND ai.group_type IN ('LOT', 'LINE', 'GROUP_LINE')
     ORDER BY bl.line_number, decode(ah.bid_ranking, 'PRICE_ONLY', 1/bl.price, nvl(bl.total_weighted_score,0)/bl.price) desc ,bl.publish_date asc;

   l_prev_line_number := -9999;
   IF l_line_number_tbl.COUNT > 0 THEN
     FOR j IN l_line_number_tbl.FIRST .. l_line_number_tbl.LAST
     LOOP
       IF l_prev_line_number <> l_line_number_tbl(j) THEN
         l_prev_line_number := l_line_number_tbl(j);
         l_qty_remaining := l_auction_qty_tbl(j);
       END IF;
       IF (l_qty_remaining > 0) THEN
         IF (l_bid_qty_tbl(j) <= l_qty_remaining) THEN
           l_current_value := l_current_value + (l_bid_qty_tbl(j) * nvl(l_current_price_tbl(j), l_bid_price_tbl(j)));
           l_optimal_value := l_optimal_value + (l_bid_qty_tbl(j) * l_bid_price_tbl(j));
           l_qty_remaining := l_qty_remaining - l_bid_qty_tbl(j);
         ELSE
           l_current_value := l_current_value + (l_qty_remaining * nvl(l_current_price_tbl(j), l_bid_price_tbl(j)));
           l_optimal_value := l_optimal_value + (l_qty_remaining * l_bid_price_tbl(j));
           l_qty_remaining := 0;
         END IF;
       END IF; --End of if l_qty_remaining > 0
     END LOOP; -- End of for loop
    END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_current_value := 0;
        l_optimal_value := 0;
     WHEN OTHERS THEN
        RAISE;
   END;

  x_current_value := nvl(l_current_value,0);
  x_optimal_value := nvl(l_optimal_value,0);

END calculate_console_summary;

END PON_CONSOLE_PVT;

/
