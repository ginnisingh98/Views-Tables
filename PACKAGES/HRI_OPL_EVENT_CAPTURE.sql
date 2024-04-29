--------------------------------------------------------
--  DDL for Package HRI_OPL_EVENT_CAPTURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_EVENT_CAPTURE" AUTHID CURRENT_USER AS
/* $Header: hrioetcp.pkh 120.1 2005/09/28 06:16:45 ssherloc noship $ */
--
-- --------------------------------------------------------------
-- Public Declarations
--
  event_group_not_found           EXCEPTION;
  business_group_not_found        EXCEPTION;
  table_name_not_found            EXCEPTION;
  schema_name_not_set             EXCEPTION;
  --
  -- --------------------------------------------------------------------------
  --
  -- Global variables used to store parameter values:
  -- These variables are public so that they can accessed for debugging
  -- from external PLSQL scripts.
  --
  g_capture_from_date             DATE;    -- This should be either the end of
                                           -- the last successful run + 1 day,
                                           -- or DBI global start date.
                                           -- This parameter is used to
                                           -- indicate when to collect events
                                           -- for the event queues from.
                                           -- Events are always collected to
                                           -- hr_general.end_of_time
  g_master_event_group_id         NUMBER;  -- event group id of the master event
                                           -- group, used to track all
                                           -- changes that effect sub event
                                           -- groups.
  g_sprvsr_change_event_grp_id    NUMBER;  -- event group id of the sub event
                                           -- group, used to track supervisor
                                           -- hierarchy related changes
  g_assgnmnt_evnt_event_grp_id    NUMBER;  -- event group id of the sub event
                                           -- group, used to track assignment
                                           -- event fact related changes
  g_absence_dim_event_grp_id      NUMBER;  -- event group id of the sub event
                                           -- group, used to track absence
                                           -- changes.
  g_full_refresh_not_run          BOOLEAN; -- Used to switch to a clean
                                           -- failover mode in the range_cursor
                                           -- when a full refresh has not been
                                           -- run yet.
  --
  -- End of global variables used to store parameter values
  --
  -- --------------------------------------------------------------------------
--
-- End of Public Declarations
--
-- ----------------------------------------------------------------------------
--
--
PROCEDURE run_for_bg(p_business_group_id  IN NUMBER,
                     p_collect_from       IN DATE);

PROCEDURE run_for_asg(
                      p_assignment_id     IN NUMBER
                     ,p_capture_from_date IN DATE
                     );

PROCEDURE purge_queue(p_queue_table_name VARCHAR2);

FUNCTION get_event_group_id(p_event_group_name IN VARCHAR2)
RETURN NUMBER ;

PROCEDURE interpret_all_asgnmnt_changes
  (p_assignment_id IN NUMBER
  ,p_start_date IN DATE
  ,p_master_events_table
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type);

PROCEDURE Find_sub_event_group_events
  (
   p_assignment_id IN NUMBER    -- The assignment id that we are currently
                                -- processing.
  ,p_start_date IN DATE         -- Used for updating the event archive only.
                                -- Does not effect process flow in this
                                -- procedure.
  ,p_sub_event_grp_id IN NUMBER -- The event group id of the sub event group
                                -- that we are trying to find events for.
  ,p_comment_text VARCHAR2      -- Text used by debug comments to indicate
                                -- which queue's sub eveng group is being
                                -- processed.
  ,p_master_events_table        -- The Master Event Group PLSQL table.
    IN OUT nocopy pay_interpreter_pkg.t_detailed_output_table_type
  ,p_event_date OUT nocopy DATE -- Event date of the earliest sub event found
                                -- in the passed in event group and
                                -- master events table
  );
--
PROCEDURE empty_evnts_cptr_refresh_log;
--
PROCEDURE full_refresh (p_refresh_to_date IN DATE DEFAULT NULL);
--
PROCEDURE dbg(p_text  VARCHAR2);
--
PROCEDURE process_range(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_mthd_action_id            IN             NUMBER
  ,p_mthd_range_id             IN             NUMBER
  ,p_start_object_id           IN             NUMBER
  ,p_end_object_id             IN             NUMBER);
--
PROCEDURE PRE_PROCESS(
  p_mthd_action_id             IN             NUMBER,
  p_sqlstr                         OUT NOCOPY VARCHAR2);
--
PROCEDURE post_process (p_mthd_action_id NUMBER);
--
--
END HRI_OPL_EVENT_CAPTURE;

 

/
