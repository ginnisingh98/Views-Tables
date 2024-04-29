--------------------------------------------------------
--  DDL for Package PAY_MONITOR_BALANCE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MONITOR_BALANCE_RETRIEVAL" AUTHID CURRENT_USER AS
/* $Header: pymnblrt.pkh 120.0 2005/05/29 06:47:58 appldev noship $ */
--------------------------------------------------------------------------
-- SESSION VARIABLES --
--------------------------------------------------------------------------
-- The following code declares table type for storage of var names
-- and values; and function to set and retrieve values from those
-- tables..   We use two separate tables to store names and values
-- because the PLSQL provided with 10.7 apps does not support storing
-- records in PLSQL index by tables.  So, for the var named "COLOR"
-- with value "BLUE", we would store 'COLOR' at index x of table
-- SessionVarNames, and 'BLUE' at index x of SessionVarValues.
--
-- Names and values are limited to 64 characters.
--
-- The get and set functions force the name parameter to upper case
-- before storing in, or searching the table.  The value parameter
-- is not converted.
--
-- The set function does not store NULL names, but it will store
-- NULL values.   NOTE this level of PLSQL does not support the
-- NEXT .. LAST attributes on PLSQL index by tables in WNDS pure
-- functions.  So we just store a NULL value when p_value is NULL
-- (or tracking table count would be too messy).   This has
-- unfortunate implications for performance if we store a large
-- number of variables.
--
type VarTable is table of VARCHAR2(64)
        index by binary_integer;
--
-- this table contains the session var names
SessionVarNames VarTable;
--
-- this table contains the session var values
SessionVarValues VarTable;

-- The EmptyTable var is used to NULL other tables.  (PLSQL
-- that is certified with 10.7 APPS does not support
-- using delete on a PLSQL table.)   This table does
-- not get populated.
--
EmptyTable VarTable;

-- NOTE the level of PLSQL certified for 10.7 Apps does not support
-- the use of the NEXT or LAST attributes on PLSQL index by tables
-- in WNDS pure code.   So we must manually track the count of
-- table entries.
SessionVarCount NUMBER := 0;
-----------------------------------------------------------------------------
-- FUNCTION get_session_var (main function)
-----------------------------------------------------------------------------
FUNCTION get_session_var(p_name VARCHAR2) return VARCHAR2;
-----------------------------------------------------------------------------
-- FUNCTION get_session_var with default parameter; if value not set,
-- returns default.
-----------------------------------------------------------------------------
FUNCTION get_session_var(p_name VARCHAR2, p_default VARCHAR) return VARCHAR2;
-----------------------------------------------------------------------------
-- PROCEDURE set_session_var
-----------------------------------------------------------------------------
PROCEDURE set_session_var (p_name IN VARCHAR2, p_value IN VARCHAR2);
-----------------------------------------------------------------------------
-- PROCEDURE clear_session_vars
-----------------------------------------------------------------------------
PROCEDURE clear_session_vars;
-----------------------------------------------------------------------------
-- PROCEDURE monitor_balance_retrieval
-----------------------------------------------------------------------------
procedure monitor_balance_retrieval(p_defined_balance_id number
                                   ,p_assignment_action_id number
                                   ,p_reason varchar2);
-----------------------------------------------------------------------------
-- PROCEDURE output_bal_retrieval_data
-----------------------------------------------------------------------------
PROCEDURE output_bal_retrieval_data(p_module_name          varchar2
                                   ,p_date_monitored       date
                                   ,p_defined_balance_id   number
                                   ,p_assignment_action_id number
                                   ,p_reason               varchar2);
-----------------------------------------------------------------------------
END pay_monitor_balance_retrieval;

 

/
