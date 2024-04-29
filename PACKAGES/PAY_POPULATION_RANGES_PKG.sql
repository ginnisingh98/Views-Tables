--------------------------------------------------------
--  DDL for Package PAY_POPULATION_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_POPULATION_RANGES_PKG" AUTHID CURRENT_USER as
/* $Header: pycoppr.pkh 120.0 2005/05/29 01:59:57 appldev noship $ */

--
-- Dynamic SQL generation Types
--
-- Cross refernce the C code defintions with the PL/SQL
--
PY_ALLASG constant number := 1;
PY_SPCINC constant number := 2;
PY_SPCEXC constant number := 3;
PY_RUNRGE constant number := 4;
PY_RESRGE constant number := 5;
PY_NONRGE constant number := 6;
PY_PURRGE constant number := 7;    -- Purge.
PY_RETRGE constant number := 8;    -- RetroPay By Element
PY_RETASG constant number := 9;
SQL_ALLASG constant number := PY_ALLASG; /* all assignments for payroll */
SQL_SPCINC constant number := PY_SPCINC; /* specific assignment inclusions */
SQL_SPCEXC constant number := PY_SPCEXC; /* all assignments - specific
                                            exclusions */
SQL_RUNRGE constant number := PY_RUNRGE; /* payroll run range rows */
SQL_RESRGE constant number := PY_RESRGE; /* restricted payroll action range
                                            rows */
SQL_NONRGE constant number := PY_NONRGE; /* unrestricted payroll action range
                                            rows */
SQL_PURRGE constant number := PY_PURRGE; /* range row for Purge */
SQL_RETRGE constant number := PY_RETRGE; /* range row for retropay by element
                                            with retro defn */
SQL_RETASG constant number := PY_RETASG; /* assignments for retropay by
                                            element with retro defn */

--
-- Population Status
--
APS_POP_RANGES  constant varchar2(2) := 'R';/* populating range table */
APS_POP_ACTIONS constant varchar2(2) := 'P';/* populating assignment actions */
APS_POP_ERROR   constant varchar2(2) := 'E';/* error in one or more chunks */
APS_POP_POSTINS constant varchar2(2) := 'A';/* post insert of AA       */
APS_COMPLETE    constant varchar2(2) := 'C';/* have completed population */

/*
   perform_range_creation

   This procedure generates the population ranges then executes a commit
*/
procedure perform_range_creation (p_payroll_action_id in number);

/*
   reset_errored_ranges

   This procedure resets errored population ranges, ready to be reloaded
   the issues a commit
*/

procedure reset_errored_ranges(p_payroll_action_id in number);

end pay_population_ranges_pkg;

 

/
