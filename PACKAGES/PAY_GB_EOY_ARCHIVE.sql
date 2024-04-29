--------------------------------------------------------
--  DDL for Package PAY_GB_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EOY_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pygbeoya.pkh 120.3 2006/11/06 22:34:28 rmakhija noship $ */
--
------------------------------- FUNCTIONS -------------------------------------
--
-- FUNCTION get_nearest_scon
-- This function searches for a SCON number to associate with the SCON balance
-- Balance initialization creates run results prior to the NI row that records
-- the SCON number. So find a row for the same category after the effective
-- date of the owning payroll action.
-- Priority is next latest SCON input with the same Category
-- down to next latest SCON input regardless of Category
FUNCTION get_nearest_scon(p_element_entry_id       IN number ,
                          p_assignment_action_id   IN number,
                          p_category               IN varchar2 ,
                          p_effective_date         IN date)
                          return varchar2;
pragma restrict_references (get_nearest_scon, WNDS);
--
-- FUNCTION canonical_to_date
-- Cover on the fnd_date function, but with exception handling
FUNCTION canonical_to_date(p_chardate   IN VARCHAR2)
                           RETURN DATE;
PRAGMA restrict_references(canonical_to_date, WNDS, WNPS);
--
-- FUNCTION canonical_to_number
-- Cover on the fnd_number function, but with exception handling
FUNCTION canonical_to_number(p_charnum   IN VARCHAR2)
                             RETURN NUMBER;
PRAGMA restrict_references(canonical_to_number, WNDS, WNPS);
--
-- FUNCTION get_arch_str
-- Overloaded Pure Public Function which returns a value from the archive,
-- given the action id (ff_archive_items.context1), user entity name or id
-- and up to three additional contexts.
-- No validation is performed on the input parameters.
-- If a matching item does not exist, null is returned.
-- The additional context parameters must be populated in order.
FUNCTION get_arch_str(p_action_id        IN NUMBER,
                      p_user_entity_id   IN NUMBER,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2;
PRAGMA restrict_references(get_arch_str, WNDS, WNPS);
FUNCTION get_arch_str(p_action_id        IN NUMBER,
                      p_user_entity_name IN VARCHAR2,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2;
PRAGMA restrict_references(get_arch_str, WNDS, WNPS);
--
-- FUNCTION get_arch_num
-- Pure Public Function which returns a value from the archive
-- using get_arch_str, then formats it to a number
FUNCTION get_arch_num(p_action_id        IN NUMBER,
                      p_user_entity_name IN VARCHAR2,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN NUMBER;
PRAGMA restrict_references(get_arch_num, WNDS, WNPS);
--
-- FUNCTION get_arch_date
-- Pure Public Function which returns a value from the archive
-- using get_arch_str, then formats it to a date
FUNCTION get_arch_date(p_action_id        IN NUMBER,
                       p_user_entity_name IN VARCHAR2,
                       p_context_value1   IN VARCHAR2 DEFAULT NULL,
                       p_context_value2   IN VARCHAR2 DEFAULT NULL,
                       p_context_value3   IN VARCHAR2 DEFAULT NULL)
                       RETURN DATE;
PRAGMA restrict_references(get_arch_date, WNDS, WNPS);
--
--
-- FUNCTION get_parameter
-- Pure Public Function which returns a specific legislative parameter,
-- given a string of parameters and a token.
-- Optional segment_number parameter indicates which segment of the parameter
-- to return where the parameter contains segments separated by colons
--   eg. SORT_OPTIONS=segment1:segment2:segment3
-- Now caters for spaces in parameter values (so can be used to retrieve
-- canonical dates) where the parameter is delimited with pipe chars
--   eg.  |START_DATE=1999/04/06 00:00:00|
FUNCTION get_parameter(p_parameter_string IN VARCHAR2,
                       p_token            IN VARCHAR2,
                       p_segment_number   IN NUMBER DEFAULT NULL)
                       RETURN VARCHAR2;
PRAGMA restrict_references(get_parameter, WNDS);
FUNCTION get_cached_value(p_payroll_action_id   IN NUMBER,
                          p_user_entity_name    IN VARCHAR2,
                          p_payroll_id          IN NUMBER)
RETURN VARCHAR2;
PRAGMA restrict_references(get_cached_value, WNDS, WNPS);
--
FUNCTION get_agg_active_start(p_asg_id        IN NUMBER,
                              p_tax_ref       IN VARCHAR2,
                              p_proll_eff_date IN DATE)
RETURN DATE;
PRAGMA restrict_references(get_agg_active_start, WNDS, WNPS);
--
FUNCTION get_agg_active_end(p_asg_id        IN NUMBER,
                            p_tax_ref       IN VARCHAR2,
                            p_proll_eff_date IN DATE)
RETURN DATE;
PRAGMA restrict_references(get_agg_active_end, WNDS, WNPS);
------------------------------- PROCEDURES ----------------------------------
--
-- PROCEDURE range_cursor
-- Procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL Statement to select all the people that may be
-- eligible for Year End reporting.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2);
--
PROCEDURE action_creation(pactid IN NUMBER,
                          stperson IN NUMBER,
                          endperson IN NUMBER,
                          chunk IN NUMBER);
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER);
--
PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE);
--
-- PROCEDURE extract_item_report_format
-- This procedure inserts the necessary data into the
-- PAY_REPORT_FORMAT_ITEMS_F table, FOR GB EXTRACT ARCHIVE ITEMS ONLY.
-- This distinction must be made as the procedure contains hard-
-- coded data, only relevant for extract items, ie those DBI/
-- User Entities starting 'X_'. Do not use this utility for
-- entering other data into these tables.
-- The Datetracking is 'handled' in this case by entering
-- start of time and end of time for all records. Again, this
-- is specific to GB Extract Items.
PROCEDURE extract_item_report_format(p_user_entity_name IN VARCHAR2,
                                     p_archive_type     IN VARCHAR2);
--
-- Function to write error or warning messages to the output and the log files
FUNCTION write_output(p_assignment_number IN VARCHAR2,
                       p_full_name IN VARCHAR2,
                       p_message_type IN VARCHAR2,
                       p_message IN VARCHAR2) RETURN NUMBER;
--
FUNCTION write_output_footer RETURN NUMBER;
--
END pay_gb_eoy_archive;

/
