--------------------------------------------------------
--  DDL for Package PAY_EVENTS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENTS_WRAPPER" AUTHID DEFINER AS
/* $Header: pyevtwrp.pkh 115.10 2003/07/08 05:41:58 exjones noship $ */
/*
    +======================================================================+
    |               Copyright (c) 2002 Oracle Corporation UK               |
    |                    Thames Valley Park, Reading, UK                   |
    |                        All rights reserved.                          |
    +======================================================================+
    File Name   : pyevtwrp.pkh

    Description : A wrapper on top of the Payroll Events Model interpreter
                  for use with the summarisation collection programs which
                  are used to increase the performance of the Daily Business
                  Intelligence portlet queries.

    Change History
    --------------
    Name           Date        Version Bug     Text
    -------------- ----------- ------- ------- -----------------------------
    Ed Jones       31-May-2002 115.0           Initial (stub) version
    Ed Jones       31-May-2002 115.1           Added dbdrv lines
    Ed Jones       31-May-2002 115.2           Corrected invalid dbdrv lines
    Ed Jones       14-Jun-2002 115.3           Replaced stubs with proper
                                               code
    Ed Jones       02-Jul-2002 115.4           Added refresh period start
                                               and end dates to the
                                               get_refresh_periods routine
    Ed Jones       23-Jul-2002 115.5           Add debugging mode and allow
                                               messages to be sent to conc.
                                               manager log file
    Ed Jones       12-Aug-2002 115.6           Add new exception for when no
                                               supervisor changes are found
    Ed Jones       27-Mar-2003 115.7   2870801 Changes to cater for date
                                               track updates to supervisor
                                               as well as corrections
    Ed Jones       02-Jun-2003 115.8   2984406 Removed event group name as
                                               a parameter to internal modules.
					       Global ID is used instead.
    Ed Jones       07-Jul-2003 115.9           Move various cursors to be visible
                                               at package level, for use by
					       diagnostics routines.
					       Made dt update SQL building function
					       accesible for this reason too.
				       3033981 Add element_entry_id as parameter
					       to get_event_details and to
					       assignment table type.
    Ed Jones       07-Jul-2003 115.10          Remove 'show errors' for gscc
    ========================================================================
*/
    --
    -- < CONSTANTS > ---------------------------------------------------------
    --
    -- Global constant so that the supervisor_id which indicates
    -- "all supervisors" can be referenced consistently
    c_ALL_SUPERVISORS_ID    CONSTANT NUMBER(15)     := -1;
    c_BLANK_LOCATION_ID     CONSTANT NUMBER(15)     := -1;
    --
    -- < CUSTOM TYPE DEFINITIONS > -------------------------------------------
    --
    -- Table of records to return the time periods, by supervisor, which need
    -- refreshing
    TYPE t_summary_refresh_tab_rec IS RECORD(
        supervisor_id           per_all_assignments_f.supervisor_id%type,
        effective_start_date    DATE,
        effective_end_date      DATE,
        location_id             per_all_assignments_f.location_id%type
    );
    TYPE t_summary_refresh_tab_type IS
        TABLE OF t_summary_refresh_tab_rec
        INDEX BY BINARY_INTEGER;
    --
    -- Simple table to record a list of assignment ID and effective dates
    TYPE t_assignment_id_tab_rec IS RECORD(
        assignment_id           per_all_assignments_f.assignment_id%TYPE,
	element_entry_id        pay_element_entries_f.element_entry_id%TYPE,
        effective_start_date    DATE,
        effective_end_date      DATE
    );
    --
    TYPE t_assignment_id_tab_type IS
        TABLE OF t_assignment_id_tab_rec
        INDEX BY BINARY_INTEGER;
    --
    -- < CURSORS > -----------------------------------------------------------
    --
    -- Return types for packaged cursors and references
    TYPE csr_return IS RECORD (
        assignment_or_supervisor_id    NUMBER(9),
	table_or_location_id           NUMBER(9),
	generic_surrogate_key          VARCHAR2(2000),
	effective_start_date           DATE,
	effective_end_date             DATE
    );
    TYPE csr_dyn_ref IS REF CURSOR;
    --
    CURSOR csr_inserts_deletes(p_evt IN NUMBER,p_st IN DATE,p_en IN DATE) RETURN csr_return;
    CURSOR csr_dt_corrections(p_evt IN NUMBER,p_st IN DATE,p_en IN DATE) RETURN csr_return;
    CURSOR csr_supv_corrections(cp_evt IN NUMBER,cp_st IN DATE,cp_en IN DATE,cp_str IN VARCHAR2) RETURN csr_return;
    CURSOR csr_table_list(p_evt IN NUMBER) RETURN csr_return;
    --
    -- < EXCEPTIONS > --------------------------------------------------------
    --
    -- User defined exception to indicate various fatal errors
    feature_not_supported           EXCEPTION;
    mismatch_when_summarizing       EXCEPTION;
    event_group_not_found           EXCEPTION;
    no_assignments_supplied         EXCEPTION;
    dated_table_cache_miss          EXCEPTION;
    dated_table_cache_empty         EXCEPTION;
    no_assignment_events_found      EXCEPTION;
    missing_dates_in_all_record     EXCEPTION;
    missing_dates_for_specific      EXCEPTION;
    no_supervisor_corrections       EXCEPTION;
    --
    -- < MAIN TOP LEVEL PROCEDURE > -------------------------------------------
    --
    -- This is the procedure that normal developers should call.
    -- =========================================================
    -- Pass in the event group name, the start and end date of the desired
    -- refresh period (in real-time, not effective dates, e.g. the date the
    -- last refresh was run and the current system date)
    --
    -- It will pass back a list of supervisors and the date range across which
    -- each of those supervisors should be refreshed.
    --
    -- If there is a record passed back with a supervisor_id set to
    -- c_ALL_SUPERVISORS_ID then you should refresh your summary for all
    -- supervisors between the dates specified in that record.
    --
    -- A record like this will be passed back when some event occurrs on a
    -- table from which we cannot get back to a supervisor_id, e.g. the
    -- Workforce Measurement Value base metric (or whatever it's called these
    -- days), and it indicates that something's happened in this date range
    -- which affects the summary data values for all supervisors.
    --
    -- You can safely run through all records and process them discretely
    -- since any overlaps of specific supervisors with this "refresh all"
    -- time period will be removed before the summary refresh details are
    -- passed back.
    PROCEDURE get_summaries_affected(
        p_event_group     IN     VARCHAR2,
        p_start_date      IN     DATE,
        p_end_date        IN     DATE,
        p_summary_refresh IN OUT NOCOPY t_summary_refresh_tab_type,
        p_location_stripe IN     BOOLEAN DEFAULT FALSE,
        p_raise_no_data   IN     BOOLEAN DEFAULT FALSE
    );
    --
    -- < FUNCTIONS > ---------------------------------------------------------
    --
    -- Return the "all supervisors" id, for use in SQL statements
    FUNCTION all_supervisors_id RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(all_supervisors_id,WNDS,RNDS);
    --
    -- Return the "blank location" id, for use in SQL statements
    FUNCTION blank_location_id RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(blank_location_id,WNDS,RNDS);
    --
    -- Get the event group ID based on its name
    FUNCTION get_event_group_id(p_event_group_name IN VARCHAR2) RETURN NUMBER;
    --
    -- Return the ID of the element entries table
    FUNCTION get_element_entry_table_id RETURN NUMBER;
    --
    -- Build the SQL statement to get date track update information
    FUNCTION build_csr_dt_updates(p_dtid IN NUMBER,p_dtname IN VARCHAR2,p_eeid IN NUMBER) RETURN VARCHAR2;
    --
    -- Initialise the event group cache
    PROCEDURE init_event_group_cache(p_event_group_name IN VARCHAR2);
    --
    -- Get the elapsed time of the last run, in seconds to the nearest 100th
    FUNCTION get_elapsed_time RETURN NUMBER;
    FUNCTION get_elapsed_time_text RETURN VARCHAR2;
    --
    -- Functions to simplify looping over the last returned table of refresh records
    FUNCTION next_record RETURN BOOLEAN;
    FUNCTION current_record RETURN NUMBER;
    --
    -- < PROCEDURES > --------------------------------------------------------
    --
    -- Switch on or off client debugging.
    -- !! Stubbed out, since client debugging (i.e. dbms_output) isn't allowed !!
    PROCEDURE set_client_debugging(p_on IN BOOLEAN);
    --
    -- Replacement for the above - allow logging to concurrent manager log
    -- files (else hr_utility.trace) and switch debugging messages on
    PROCEDURE set_concurrent_logging(p_on IN BOOLEAN);
    PROCEDURE set_debugging(p_on IN BOOLEAN);
    --
    -- Write out a message, either by fnd_file.put_line, or hr_utility.trace
    -- depending on what's passed to set_concurrent_logging, dbg only writes
    -- a message if you've passed TRUE to set_debugging
    PROCEDURE msg(p_text IN VARCHAR2);
    PROCEDURE dbg(p_text IN VARCHAR2);
    --
    -- Get a list of the assignments that have events recorded for them.
    -- * See note 1
    PROCEDURE get_assignments_affected(
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_assignments       IN OUT NOCOPY t_assignment_id_tab_type
    );
    --
    -- Get the refresh summary data based on a list of assignment IDs
    -- * See note 1
    PROCEDURE get_refresh_periods(
        p_assignments       IN OUT NOCOPY t_assignment_id_tab_type,
        p_summary_refresh   IN OUT NOCOPY t_summary_refresh_tab_type,
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_location_stripe   IN      BOOLEAN DEFAULT FALSE
    );
    --
    -- Remove specific supervisor refresh records (or the portions of them)
    -- that overlap the "all" refresh period
    -- * See note 1
    PROCEDURE de_dupe_refresh_periods(
        p_summary_refresh_temp  IN OUT NOCOPY t_summary_refresh_tab_type,
        p_summary_refresh       IN OUT NOCOPY t_summary_refresh_tab_type,
        p_all_supv              IN OUT NOCOPY BOOLEAN,
        p_out_num               IN OUT NOCOPY NUMBER,
        p_all_start             IN OUT NOCOPY DATE,
        p_all_end               IN OUT NOCOPY DATE,
        p_want_location         IN     BOOLEAN DEFAULT FALSE
    );
    --
    -- Get the payroll event details based on an assignment ID
    -- * See note 1
    PROCEDURE get_event_details(
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_assignment_id     IN      NUMBER,
	p_element_entry_id  IN      NUMBER,
        p_detailed_output   IN OUT  NOCOPY pay_interpreter_pkg.t_detailed_output_table_type,
        p_proration_dates   IN OUT  NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
    );
    --
    -- Process the detailed information that get_event_details returned
    -- * See note 1
    PROCEDURE process_event_details(
        p_detailed_output   IN      pay_interpreter_pkg.t_detailed_output_table_type,
        p_proration_dates   IN      pay_interpreter_pkg.t_proration_dates_table_type,
        p_summary_refresh   IN OUT  NOCOPY t_summary_refresh_tab_type,
        p_location_stripe   IN      BOOLEAN DEFAULT FALSE
    );
    --
    -- < NOTES > -------------------------------------------------------------
    --
    -- Note 1:
    -- These are really a internal procedures and shouldn't be called by a
    -- normal developer. They're exposed here for debugging purposes and in
    -- case anyone needs to get more detailed information about the events
    --
END pay_events_wrapper;

 

/
