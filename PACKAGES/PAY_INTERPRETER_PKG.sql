--------------------------------------------------------
--  DDL for Package PAY_INTERPRETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INTERPRETER_PKG" AUTHID DEFINER AS
/* $Header: pyinterp.pkh 120.3.12010000.5 2009/05/08 13:08:47 ckesanap ship $ */
/*
 +======================================================================+
 |                Copyright (c) 2000 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package File Name   : pyinterp.pkh
 Description :

 Change List:
 ------------
 Name           Date        Version Bug     Text
 -------------- ----------- ------- ------- -----------------------------
 jvaradra       06-May-2009 115.33  8359083 Removed the dependency of penserver
                                            package.
							  Introduced function get_penserver_date
 salogana       06-Nov-2008 115.32  7525608 Introduced the following globalds for
                                            penserver.
				            g_pen_lapp_date
					    g_pen_from_date
					    g_pen_prev_ass_id
 salogana       03-Oct-2008 115.30  7443747 Added the global variable
                                            g_pen_collect_reports
                                            for penserver issue.
 ayegappa       28-MAY-2008 115.29  7120770 Commented set_internal_cache
                                            procedure
 ayegappa       09-MAY-2008 115.28  6992642 Added penserver flag to
                                            entries, entry affected and
                                            event_group_table_affected
                                            procedures.
 nbristow       05-JUL-2007 115.27          Added set_internal_cache.
 SuSivasu       02-Nov-2005 115.26          Added creation date to
                                            t_detailed_output_tab_rec
                                            and process_mode to entries_affected.
 nbristow       13-JUN-2005 115.25          Using valid_group_event_for_asg
                                            to prequalify events
 nbristow       28-APR-2005 115.24          Performance changes for
                                            RetroNotification.
 nbristow       23-FEB-2005 115.23          Changes for Period Allocation.
 nbristow       29-APR-2004 115.22          Previous change had issues on
                                            8.1.7 Db version.
 nbristow       20-APR-2004 115.21          Fixed GCSS warnings.
 nbristow       20-APR-2004 115.20          Added entries_affected procedure.
 jford          10-MAR-2004 115.19          Add global types
 jford          16-FEB-2004 115.18  3446200 Add get_subset_given_new_evg
 jford          01-FEB-2004 115.17          Get pde.dyt_type
 jford          03-JAN-2004 115.16  3329824 Change date dfts, guarantee not null
 jford          05-DEC-2003 115.15          Get pde.column_name
 jford          25-NOV-2003 115.14  3257307 New entry_affected for ADV_RETRONOT
 jford          06-SEP-2003 115.12          Make largest entry_affected allow
                                            IN OUT tables, eg half full results
 nbristow       02-MAY-2003 115.11          Added functions to return values
 nbristow       02-MAY-2003 115.10          Added g_asg_id and g_ee_id.
 jford          01-FEB-2003 115.9           Major alterations so Continuous
                                            Calculation can use this interpreter.
 nbristow       18-JUL-2002 115.6           Changes for Run proration.
 Ed Jones       14-JUN-2002 115.5           Changes to support the
                                            portal summarisation wrapper
                                            Made a couple of extra routines
                                            and types public, added owner
                                            to the detailed output record.
 T Battoo       05-MAR-2001 115.4           Unknown (comment added by exjones)
 Ashu Gupta     06-FEB-2001 115.3           Changed the name of the table
                                            from pay_tables to
                                            pay_dated_tables.
 nbristow       26-JAN-2001 115.2           Added the prorate_start_date
                                            function.
 Ashu GUPTA     15-JAN-2001 115.0           Initial version.
 ========================================================================
*/
--
--Global Variables
--
g_effective_date date;
g_object_key varchar2(2000);
g_parent_key varchar2(2000);
g_asg_id     number;
g_ee_id      number;
--
-- Record Types
--bug 7443747:Start
g_pen_collect_reports   VARCHAR2(5);
--bug 7443747:Stop
--
-- Bug 7525608:Start
-- Varibles For holding penserver data

g_pen_lapp_date   date;            -- To Store latest approved date for each extract
g_pen_from_date   date;            -- To Store the actual from_date for each assignment
g_pen_prev_ass_id number := -1;    -- To store the processed assignment_id
-- Bug 7525608:End

-- Event Qualifier Caches
--
type t_child_evt_qual_rec is record
(
   from_value               pay_event_value_changes_f.from_value%type,
   to_value                 pay_event_value_changes_f.to_value%type,
   valid_event              pay_event_value_changes_f.valid_event%type,
   proration_style          pay_event_value_changes_f.proration_style%type,
   qualifier_value          pay_event_value_changes_f.qualifier_value%type,
   qualifier_definition     pay_event_qualifiers_f.qualifier_definition%type,
   comparison_column        pay_event_qualifiers_f.comparison_column%type,
   qualifier_where_clause   pay_event_qualifiers_f.qualifier_where_clause%type,
   multi_event_sql          pay_event_qualifiers_f.multi_event_sql%type
);
--
type t_child_evt_qual_tab is table of t_child_evt_qual_rec
            index by binary_integer;
--
type t_evt_qual_rec is record
(
   valid_event              pay_event_value_changes_f.valid_event%type,
   proration_style          pay_event_value_changes_f.proration_style%type,
   assignment_qualification pay_event_qualifiers_f.assignment_qualification%type,
   entry_qualification      pay_event_qualifiers_f.entry_qualification%type,
   start_qual_ptr           number,
   end_qual_ptr             number
);
--
type t_evt_qual_tab is table of t_evt_qual_rec
            index by binary_integer;
--
-- table columns
--
type t_table_columns_rec is record
(
   column_name        pay_event_procedures.column_name%type,
   evt_proc_start_ptr number,
   evt_proc_end_ptr   number,
   next_ptr           number
);

type t_table_columns_tab is table of t_table_columns_rec
            index by binary_integer;

-- Event Procedures
type t_event_procedure_rec is record
(
   procedure_name pay_event_procedures.procedure_name%type,
   next_ptr       number
);

type t_event_procedure_tab is table of t_event_procedure_rec
            index by binary_integer;

/***
*** The following type will hold the records from c_distinct_table. This will
*** be used in caching.
***/
    TYPE t_distinct_table_rec IS RECORD
    (
        table_id             pay_dated_tables.dated_table_id%TYPE     ,
        table_name           pay_dated_tables.table_name%TYPE         ,
        owner                pay_dated_tables.owner%TYPE              ,
        dyt_type             pay_dated_tables.dyn_trigger_type%TYPE   ,
        surrogate_key_name   pay_dated_tables.surrogate_key_name%TYPE ,
        start_date_name      pay_dated_tables.start_date_name%TYPE    ,
        end_date_name        pay_dated_tables.end_date_name%TYPE      ,
        datetracked_event_id pay_datetracked_events.datetracked_event_id%TYPE,
        column_name          pay_datetracked_events.column_name%TYPE  ,
        update_type          pay_datetracked_events.update_type%TYPE  ,
        proration_type       pay_datetracked_events.proration_style%TYPE
    );

    TYPE t_distinct_table IS TABLE OF t_distinct_table_rec
                      INDEX BY BINARY_INTEGER  ;
    t_distinct_tab         t_distinct_table                          ;

TYPE t_detailed_output_tab_rec IS RECORD
(
    dated_table_id       pay_dated_tables.dated_table_id%TYPE     ,
    datetracked_event    pay_datetracked_events.datetracked_event_id%TYPE  ,
    update_type          pay_datetracked_events.update_type%TYPE  ,
    surrogate_key        pay_process_events.surrogate_key%type    ,
    column_name          pay_event_updates.column_name%TYPE       ,
    effective_date       date,
    creation_date        date,
    old_value            varchar2(2000),
    new_value            varchar2(2000),
    change_values        varchar2(2000),
    proration_type       varchar2(10),
    change_mode          pay_process_events.change_type%type,--'DATE_PROCESSED' etc
    element_entry_id     pay_element_entries_f.element_entry_id%type,
    next_ee              number
);

TYPE t_proration_dates_table_type IS TABLE OF DATE INDEX BY BINARY_INTEGER ;

TYPE t_proration_type_table_type  IS TABLE OF VARCHAR2(10) INDEX BY
                                                   BINARY_INTEGER          ;

TYPE t_detailed_output_table_type IS TABLE OF t_detailed_output_tab_rec
                                                    INDEX BY BINARY_INTEGER ;
TYPE t_datetrack_ee_rec IS RECORD
(
    datetracked_evt_id   pay_datetracked_events.datetracked_event_id%TYPE     ,
    element_entry_id     pay_element_entries_f.element_entry_id%type,
    next_ptr             number
);

TYPE t_datetrack_ee_tab IS TABLE OF t_datetrack_ee_rec
                          INDEX BY BINARY_INTEGER ;

TYPE t_hash_table_type IS TABLE OF number
                          INDEX BY BINARY_INTEGER ;
TYPE t_global_env_rec IS RECORD
(
    /* A number of entries in this record have been
       removed and replaced with glo_ variables.
       This is a restriction placed in the version
       of this db that we have to support. When this
       restriction is removed we should remove the
       glo_ versions
    */
--    ee_hash_table         t_hash_table_type,
--    datetrack_ee_tab      t_datetrack_ee_tab,
--    datetrack_ee_hash_tab t_hash_table_type,
    datetrack_ee_tab_use  boolean,
    validate_run_actions  boolean,
--    monitored_events      t_distinct_table,
    monitor_start_ptr     number,
    monitor_end_ptr       number
--,
    -- Values needed for the event
    -- procedures
--    column_hash_tab       t_hash_table_type,
--    table_columns         t_table_columns_tab,
--    event_procedures      t_event_procedure_tab,
    -- Values needed for the Event Qualifiers
--    event_qualifiers      t_evt_qual_tab,
--    child_event_qualifiers t_child_evt_qual_tab
);
    glo_ee_hash_table         t_hash_table_type;
    glo_datetrack_ee_tab      t_datetrack_ee_tab;
    glo_datetrack_ee_hash_tab t_hash_table_type;
    glo_monitored_events      t_distinct_table;
    glo_column_hash_tab       t_hash_table_type;
    glo_table_columns         t_table_columns_tab;
    glo_event_procedures      t_event_procedure_tab;
    glo_event_qualifiers      t_evt_qual_tab;
    glo_child_event_qualifiers t_child_evt_qual_tab;
--
/***
*** The following type will hold the records for a proration group id. This will
*** be used in caching.
***/
    TYPE t_proration_group_rec IS RECORD
    (
--        proration_group_id pay_element_types_f.proration_group_id%TYPE ,
        range_start        NUMBER                                      ,
        range_end          NUMBER
    );
    TYPE t_proration_group_table IS TABLE OF t_proration_group_rec
                      INDEX BY BINARY_INTEGER  ;

    t_proration_group_tab  t_proration_group_table                   ;

    TYPE t_process_event_rec IS RECORD
    (
        process_event_id  pay_process_events.process_event_id%TYPE
    );

    TYPE t_process_event_table IS TABLE OF t_process_event_rec;

   --< Required to be public for the pay_events_wrapper package
    -- The following type will hold the records that will contain the column_name,
    -- its old and new value.
   TYPE t_dynamic_sql_rec IS RECORD
   (
        date_tracked_id    pay_datetracked_events.datetracked_event_id%TYPE ,
        column_name        pay_datetracked_events.column_name%TYPE ,
        old_value          VARCHAR2(100)                           ,
        new_value          VARCHAR2(100) ,
        proration_style    pay_datetracked_events.proration_style%TYPE
   );
   TYPE t_dynamic_sql_tab IS TABLE OF t_dynamic_sql_rec INDEX BY BINARY_INTEGER;
   -->

/* The following procedure will be called from ADV_RETRONOT */
/* The following procedure will be called from CONT_CALC */
--
--procedure set_internal_cache;  Bug 7120770
--
procedure initialise_global(p_global_env IN OUT NOCOPY t_global_env_rec);
--
procedure add_datetrack_event_to_entry
               (p_datetracked_evt_id in            number,
                p_element_entry_id   in            number,
                p_global_env         in out nocopy t_global_env_rec);
--
procedure clear_dt_event_for_entry
               ( p_global_env         in out nocopy t_global_env_rec);
--
procedure event_group_tables
(
 p_event_group_id IN NUMBER,
 p_distinct_tab   IN OUT NOCOPY t_distinct_table
);
--
procedure get_prorated_dates
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_time_definition_id     IN  NUMBER DEFAULT NULL          ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type
);
--
PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_process                IN  VARCHAR2 DEFAULT NULL        ,
    p_event_group_id         IN  NUMBER DEFAULT NULL          ,
    p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE' ,
    p_start_date             IN  DATE DEFAULT hr_api.g_sot,
    p_end_date               IN  DATE DEFAULT hr_api.g_eot,
    p_process_date           IN  DATE DEFAULT SYSDATE,
    p_unique_sort            IN  VARCHAR2 DEFAULT 'Y',
    p_business_group_id      IN  NUMBER DEFAULT null,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type,
    p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
);

/* The following procedure will be called from Payroll for Proration use*/
PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_process                IN  VARCHAR2 DEFAULT NULL        ,
    p_event_group_id         IN  NUMBER DEFAULT NULL          ,
    p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_EFFECTIVE_DATE' ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type,
    t_proration_type        OUT NOCOPY  t_proration_type_table_type
);

PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_process                IN  VARCHAR2 DEFAULT NULL        ,
    p_event_group_id         IN  NUMBER DEFAULT NULL          ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_change_type OUT NOCOPY  t_proration_type_table_type
);


PROCEDURE entry_affected
(
    p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
    p_assignment_action_id   IN  NUMBER DEFAULT NULL          ,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type ,
    t_proration_dates       OUT NOCOPY  t_proration_dates_table_type ,
    t_proration_type OUT NOCOPY  t_proration_type_table_type
);

FUNCTION time_fn(p_assignment_action_id IN  NUMBER   ,
                 p_proration_group_id   IN  NUMBER   ,
                 p_element_entry_id     IN  NUMBER   ) RETURN DATE;

/* The following procedure will be called from Payroll for Continous Calc use*/

PROCEDURE asg_action_affected(p_assignment_action_id   IN  NUMBER);

/* The following procedure will be called from Payroll for Continous Calc use*/

PROCEDURE asg_action_event(p_assignment_action_id   IN  NUMBER                ,
                           p_process_event_tab      IN  t_process_event_table ,
                           p_affected               OUT NOCOPY VARCHAR2              );
--
--< Required to be public for the pay_events_wrapper package
PROCEDURE event_group_tables_affected
(
     p_element_entry_id       IN  NUMBER DEFAULT NULL          ,
     p_assignment_action_id IN NUMBER,
     p_event_group_id         IN  NUMBER,
     p_assignment_id          IN  NUMBER,
     p_business_group_id      IN  NUMBER,
     p_start_date             IN  DATE,
     p_end_date               IN  DATE,
     p_mode                   IN  VARCHAR2,
     p_process                IN  VARCHAR2,
     p_process_mode           IN  VARCHAR2,
     t_dynamic_sql            IN OUT NOCOPY t_dynamic_sql_tab,
     t_proration_dates_temp  IN OUT NOCOPY  t_proration_dates_table_type ,
     t_proration_change_type IN OUT NOCOPY  t_proration_type_table_type,
     t_detailed_output       IN OUT NOCOPY  t_detailed_output_table_type,
     p_penserv_mode          IN VARCHAR2 DEFAULT 'N'
);
procedure event_group_tables
(
 p_event_group_id IN NUMBER
);
-->


/****************************************************************************
    Name      : prorate_start_date
    Purpose   : This function returns the start date of a proration period.
    Arguments :
      IN      :  p_assignment_action_id
                 p_proration_group_id
      OUT     :  p_start_date
    Notes     : Public
****************************************************************************/
FUNCTION prorate_start_date(p_assignment_action_id IN  NUMBER   ,
                 p_proration_group_id   IN  NUMBER
                ) RETURN DATE;
procedure generic_data_validation(p_dated_table_id in number,
                                  p_datetracked_event_id in number,
                                  p_old_value in varchar2,
                                  p_new_value in varchar2,
                                  p_date in date,
                                  p_key in varchar2,
                                  p_ee_id in number,
                                  p_asg_id in number,
                                  p_valid OUT NOCOPY varchar2,
                                  p_type OUT NOCOPY varchar2,
                                  p_global_env IN OUT NOCOPY t_global_env_rec);
--
function get_object_key return varchar2;
function get_parent_key return varchar2;
function get_effective_date return date;
function get_assignment_id return number;
function get_element_entry_id return number;
--
TYPE t_mst_process_event_rec IS RECORD
  (
    updated_column_name  pay_event_updates.column_name%type,
    event_type           pay_event_updates.event_type%type,
    event_update_id      pay_event_updates.event_update_id%type,
    effective_date       pay_process_events.effective_date%type,
    assignment_id        pay_process_events.assignment_id%type,
    surrogate_key        pay_process_events.surrogate_key%type,
    process_event_id     pay_process_events.surrogate_key%type,
    change_values        pay_process_events.description%type,
    calculation_date     pay_process_events.calculation_date%type,
    creation_date        pay_process_events.creation_date%type,
    change_mode          pay_process_events.change_type%type,
    table_name           pay_dated_tables.table_name%TYPE
  );

--used in extra_tests_dbt_i and extra_tests_dbt_p
TYPE t_key_date_cache_rec is record
  (
    key      varchar2(240),
    min_date pay_process_events.creation_date%type,
    max_date pay_process_events.creation_date%type,
    got_flag varchar2(15) default 'N'
  );
TYPE t_key_date_cache is
  table of t_key_date_cache_rec INDEX BY BINARY_INTEGER;
--
/****************************************************************************
    Name      : get_subset_given_new_evg
    Purpose   : This procedure returns a new table of discovered events that
 match the given new event group.  Passed in is a table of events to compare.
 I.e. used when call the Interpreter once, get results, then want to filter
 this first results table with a new event group
    Arguments :
      IN      :  p_filter_event_group_id  --The event group of filtering events
                 p_complete_detail_tab    --The full table of events
      OUT     :  p_subset_detail_tab      --The resultant table
    Notes     : Public, created for HRI wrapper to call
****************************************************************************/
PROCEDURE get_subset_given_new_evg
(
    p_filter_event_group_id  IN  NUMBER ,
    p_complete_detail_tab    IN  t_detailed_output_table_type ,
    p_subset_detail_tab      IN OUT NOCOPY  t_detailed_output_table_type
);

PROCEDURE entries_affected
(
    p_assignment_id          IN  NUMBER DEFAULT NULL          ,
    p_mode                   IN  VARCHAR2 DEFAULT NULL        ,
    p_start_date             IN  DATE  DEFAULT hr_api.g_sot,
    p_end_date               IN  DATE  DEFAULT hr_api.g_eot,
    p_business_group_id      IN  NUMBER,
    p_global_env             IN OUT NOCOPY t_global_env_rec,
    t_detailed_output       OUT NOCOPY  t_detailed_output_table_type,
    p_process_mode           IN VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE',
    p_penserv_mode           IN VARCHAR2 DEFAULT 'N'
);
--
function valid_group_event_for_asg(p_table_name    in varchar2,
                                   p_assignment_id in number,
                                   p_surrogate_key in varchar2)
return varchar2;

 -- ----------------------------------------------------------------------------
 -- |-----------------------< get_penserver_date >--------------------------|
 -- Description: This function will fetch the least effective_date for each assignment
 --              from where the events needs to be processed for reporting.
 -- ----------------------------------------------------------------------------

   FUNCTION get_penserver_date
                (p_assignment_id     IN    NUMBER
                ,p_business_group_id IN   NUMBER
                ,p_lapp_date      IN date
                ,p_end_date       IN DATE
                ) RETURN date;

END pay_interpreter_pkg;

/
