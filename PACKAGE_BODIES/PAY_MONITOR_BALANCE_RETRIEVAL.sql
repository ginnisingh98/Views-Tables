--------------------------------------------------------
--  DDL for Package Body PAY_MONITOR_BALANCE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MONITOR_BALANCE_RETRIEVAL" AS
/* $Header: pymnblrt.pkb 120.0 2005/05/29 06:47:48 appldev noship $ */
--
-------------------------------------------------------------------------
-- PROCEDURE monitor_balance_retrieval
-------------------------------------------------------------------------
-- Description:
-- The aim of this procedure is to output key data to a table, which can then
-- be interrogated, by users to determine which balances are being derived
-- from the route.
--
-- If the monitoring profile, HR_MONITOR_BALANCE_RETRIEVAL, has been set
-- the code searches for a value in the session variable 'MONITOR'. If the
-- value is null, then the default 'Monitoring all calls to route' is
-- set as the module name, otherwise the module name will be set to the value
-- in the session variable.
-- The code then calls output_bal_retrieval_data to insert monitoring data
-- into the table pay_monitor_balance_retrievals.
-------------------------------------------------------------------------
procedure monitor_balance_retrieval(p_defined_balance_id number
                                   ,p_assignment_action_id number
                                   ,p_reason varchar2) is
--
l_profile       varchar2(2);
l_proc  	varchar2(80);
l_module_name   pay_monitor_balance_retrievals.module_name%type;
--
BEGIN
l_proc := 'pay_monitor_balance_retrieval.monitor_balance_retrieval';
--
hr_utility.set_location('Entering: '||l_proc, 10);
--
-- this will be a call to get_profile once the profile is set up
--
l_profile := fnd_profile.value('HR_MONITOR_BALANCE_RETRIEVAL');
IF l_profile = 'Y' THEN
--
  hr_utility.set_location(l_proc, 20);
  --
  -- if the session variable MONITOR is null, return the default - 'Monitoring
  -- all calls to route'
  --
  l_module_name := nvl(get_session_var('MONITOR')
                                      , 'Monitoring all calls to route');
  BEGIN
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- call at to insert row into table
  --
    output_bal_retrieval_data(l_module_name
                             ,sysdate
                             ,p_defined_balance_id
                             ,p_assignment_action_id
                             ,p_reason
                             );
  END;
  --
ELSE -- profile HR_MONITOR_BALANCE_RETRIEVAL is not Y
--
  hr_utility.set_location(l_proc, 40);
END IF;
--
hr_utility.set_location('Leaving: '||l_proc, 50);
--
END monitor_balance_retrieval;
-------------------------------------------------------------------------
-- PROCEDURE output_bal_retrieval_data
-------------------------------------------------------------------------
-- Description:
-- output_bal_retrieval_data is an autonomous transaction, enabling data
-- to be written to table pay_monitor_balance_retrievals, and to be commited
-- independently of the package from which it is called.
--------------------------------------------------------------------------
PROCEDURE output_bal_retrieval_data(p_module_name          varchar2
                                   ,p_date_monitored       date
                                   ,p_defined_balance_id   number
                                   ,p_assignment_action_id number
                                   ,p_reason               varchar2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_proc varchar2(80);
--
BEGIN
--
l_proc := 'pay_monitor_balance_retrieval.output_bal_retrieval_data';
--
hr_utility.set_location('Entering: '||l_proc, 10);
--
-- insert values into table pay_monitor_balance_retrievals
--
insert into pay_monitor_balance_retrievals
(module_name
,date_monitored
,defined_balance_id
,assignment_action_id
,reason
)
values
(p_module_name
,p_date_monitored
,p_defined_balance_id
,p_assignment_action_id
,p_reason
);
--
commit;
--
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END output_bal_retrieval_data;
-------------------------------------------------------------------------
-- SESSION VARIABLE FUNCTIONS
-------------------------------------------------------------------------
--
-- The following functions use the PLSQL index by tables:
-- SessionVarNames, table of VARCHAR2(64); and SessionVarValues,
-- also index by table of VARCHAR2(64).
--      index by VARCHAR2;
--------------------------------------------------------------------------------
-- The Functions get and set session_var force the name parameter to upper case
-- before storing in, or searching the table.  The value is not converted.
--------------------------------------------------------------------------------
-- FUNCTION get_session_var
--
-- get_session_var performs a (dumb) linear search of the names table for
-- p_name.   If found, it returns the value from the values table at the
-- corresponding index.   This dumb method should be performant for small
-- amounts of variables (< 100 ?).   Larger amounts would require review
-- of alternative methods.   Of course, if PLSQL ever supports indexing
-- of PLSQL tables by VARCHAR, or other types besides BINARY INTEGER, this
-- would not be an issue.
--
-- NOTE the exception when a value is not found at the same index as
-- where a name is found.   Such an event would signal serious problems
-- with the state of the tables.   We should consider throwing an
-- HR or other exception if this ever happes.
--
-- NOTE that since we do not allow NULL values for session vars, the
-- get_session_var function can be used to test whether a var is set:
-- if it returns NULL, the var is not set.
--
FUNCTION get_session_var
        (p_name VARCHAR2)
return VARCHAR2 is
        l_temp_name VARCHAR2(64);
        l_temp_value VARCHAR2(64);
        l_loop_count NUMBER;
BEGIN

        -- no NULL names
        if p_name is NULL then
                return NULL;
        end if;

        -- check whether var tables are empty
        if SessionVarCount = 0 then
                return NULL;
        end if;

        -- force upper case name, remove leading/trailin spaces
        l_temp_name := rtrim(ltrim(upper(p_name)));

        -- search name table
        -- NOTE the level of PLSQL certified for 10.7 Apps does not support
        -- use of NEXT .. LAST attributes on PLSQL index by tables for WNDS
        -- pure code.  So we use hard coded table row count to drive our search.
        FOR l_loop_count IN 1 .. SessionVarCount LOOP
        if SessionVarNames(l_loop_count) = l_temp_name then
                      -- debug trace - found our var
                      -- use exception in case values is out of sync with names
                      -- NOTE: the level of PLSQL certified with 10.7 Apps does
                      -- not support using the exists attribute, so we must use
                      -- an exception here.
                        begin
                                l_temp_value := SessionVarValues(l_loop_count);
                exception
                when no_data_found then
                -- index not found, big problem here - should trhow exception
                --
                        return NULL;
                end;
                        return l_temp_value;
                end if;
        END LOOP;

        -- debug trace
        return NULL;
END get_session_var;
--------------------------------------------------------------------------------
-- FUNCTION get_session_var - overloaded with p_default.  Calls base
-- get_session_var; but if var is not set, returns p_default.
--------------------------------------------------------------------------------
FUNCTION get_session_var
        (p_name VARCHAR2,
        p_default VARCHAR)
return VARCHAR2 is
        l_temp_value VARCHAR2(64);
BEGIN
        l_temp_value := NULL;

        -- use base function to get value
        l_temp_value := get_session_var(p_name);

        -- if NULL value, return p_default
        if l_temp_value is NULL then
                return p_default;
        end if;
END get_session_var;
--------------------------------------------------------------------------------
-- PROCEDURE set_session_var
--
-- Sets name and value in session var tables.  Converts name to upper case,
-- does *not* convert value.
--
-- The set function does not store NULL names or values.  However,
-- an attempt to set a NULL value will result in the variable of
-- that name being deleted from both the names and values tables.
--
--------------------------------------------------------------------------------
PROCEDURE set_session_var
        (p_name IN VARCHAR2,
        p_value IN VARCHAR2)
IS
        l_temp_name VARCHAR2(64);
        l_temp_value VARCHAR2(64);
        l_loop_count NUMBER;
BEGIN
        -- no NULL names
        if p_name is NULL then
                return;
        end if;

        -- force upper case name, remove leading/trailin spaces
        l_temp_name := rtrim(ltrim(upper(p_name)));
        --
        if SessionVarCount > 0 then
        -- search name table, we may already have this var
        -- NOTE the level of PLSQL certified for 10.7 Apps does not support
        -- use of NEXT .. LAST attributes on PLSQL index by tables for WNDS
        -- pure code.  So we use hard coded table row count to drive our search.
                FOR l_loop_count IN 1 .. SessionVarCount LOOP
                if SessionVarNames(l_loop_count) = l_temp_name then
                                -- debug trace - found our var
                                -- set value table row to new value
                                SessionVarValues(l_loop_count) := p_value;
                                -- and return
                                return;
                        end if;
                END LOOP;
        end if;

        -- not found in names table, make new entries
        -- debug trace - log new var count
        SessionVarCount := SessionVarCount + 1;
        SessionVarNames(SessionVarCount) := l_temp_name;
        SessionVarValues(SessionVarCount) := p_value;

END set_session_var;
--------------------------------------------------------------------------------
-- PROCEDURE clear_session_vars
--------------------------------------------------------------------------------
PROCEDURE clear_session_vars
IS
BEGIN
        -- delete tavbles by assigning empty tables.  The level of PLSQL
        -- supported with 10.7 does not support the delete attribute on
        -- whole tables.
        SessionVarNames := EmptyTable;
        SessionVarValues := EmptyTable;
        SessionVarCount := 0;
END clear_session_vars;
--------------------------------------------------------------------------------
END pay_monitor_balance_retrieval;

/
