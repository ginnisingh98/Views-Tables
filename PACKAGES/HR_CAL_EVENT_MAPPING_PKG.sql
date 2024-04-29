--------------------------------------------------------
--  DDL for Package HR_CAL_EVENT_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_EVENT_MAPPING_PKG" AUTHID CURRENT_USER AS
  -- $Header: pecalmap.pkh 120.0 2005/05/31 06:24:16 appldev noship $

  --
  -----------------------------------------------------------------------------
  ---------------------------< build_event_cache >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure is invoked from the calendar map cache building program.
  -- It populates the two cache tables with all calendar events and their
  -- coverages based on the ORG and GEO hierarchies.
  --
  -- Once populated, the event coverage cache tables can be used to join to
  -- assignment over organization id, in order to derrive  the set of people
  -- eligible for each event or vice versa.
  --
  PROCEDURE build_event_cache(errbuf  IN OUT NOCOPY VARCHAR2
                             ,retcode IN OUT NOCOPY NUMBER
                             );

  --
  -----------------------------------------------------------------------------
  ----------------------------< get_cal_events >-------------------------------
  -----------------------------------------------------------------------------
  --
  -- This overloaded function returns a varray of all calendar events that are
  -- applicable to the person based upon the organization held on their primary
  -- assignment effective as of each calendar event's start date.
  --
  -- If the optional start_date parameter is supplied then only those events
  -- that the person is eligible for with a start_date >= the given start_date
  -- are returned.
  --
  -- If the optional end_date parameter is supplied then only those events
  -- that the person is eligible for with a end_date <= the given end_date
  -- are returned.
  --
  -- (Any combination of the optional parameters is allowed)
  --
  FUNCTION get_cal_events (p_person_id       IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          )
                          RETURN per_cal_event_varray;

  FUNCTION get_cal_events (p_assignment_id   IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          )
                          RETURN per_cal_event_varray;

  FUNCTION get_cal_events (p_hz_party_id     IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          )
                          RETURN per_cal_event_varray;

  --
  -----------------------------------------------------------------------------
  --------------------------< get_all_cal_events >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- This function returns all the calendar events in the system or filtered
  -- as per given criteria.
  --
  FUNCTION get_all_cal_events (p_event_type      IN VARCHAR2 DEFAULT NULL
                              ,p_start_date      IN DATE     DEFAULT NULL
                              ,p_end_date        IN DATE     DEFAULT NULL
                              )
                              RETURN per_cal_event_varray;

  --
  -----------------------------------------------------------------------------
  -------------------------< build_cal_map_cache >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure builds transient data into table PER_CAL_MAP_CACHE for
  -- use by the calendar mapping user interface.
  --
  PROCEDURE build_cal_map_cache (p_person_id     IN NUMBER
                                ,p_assignment_id IN NUMBER
                                ,p_event_type    IN VARCHAR2 DEFAULT NULL
                                ,p_start_date    IN DATE     DEFAULT NULL
                                ,p_end_date      IN DATE     DEFAULT NULL
                                );

END hr_cal_event_mapping_pkg;

 

/
