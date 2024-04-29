--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_HOURS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_HOURS_PKG" AUTHID CURRENT_USER as
/* $Header: hxchours.pkh 115.4 2002/06/10 00:37:13 pkm ship    $ */
--  get_hours
--
-- procedure
--  Gets the sum for a particular type of Hours
--
-- description
--
-- parameters
--       p_timecard_id    - timecard Id
--       p_timecard_ovn   - timecard  Ovn
--       p_lookup_type    - Hours Type Lookup
--
FUNCTION get_hours
            (
              p_timecard_id number,
              p_timecard_ovn number,
              p_lookup_type varchar2
            ) RETURN NUMBER;


FUNCTION get_hours(
  p_period_start_time  IN DATE,
  p_period_stop_time   IN DATE,
  p_resource_id        IN NUMBER,
  p_lookup_type        IN VARCHAR2
)
RETURN NUMBER;

FUNCTION get_total_hours(
  p_period_start_time  IN DATE,
  p_period_stop_time   IN DATE,
  p_resource_id        IN NUMBER,
  p_mode               IN VARCHAR2 DEFAULT 'DAYS_INCLUSIVE'
)
RETURN NUMBER;



--  get_total_hours
--
-- procedure
--  Gets the sum for a total Hours
--
-- description
--
-- parameters
--       p_timecard_id    - timecard Id
--       p_timecard_ovn   - timecard  Ovn
--

FUNCTION get_total_hours
            (
              p_timecard_id number,
              p_timecard_ovn number
            ) RETURN NUMBER;


END hxc_timecard_hours_pkg;

 

/
