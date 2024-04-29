--------------------------------------------------------
--  DDL for Package PAY_CA_BALANCE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_BALANCE_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: pycabalv.pkh 115.5 2004/02/17 03:46:45 sdahiya noship $ */
/* Copyright (c) Oracle Corporation 1998. All rights reserved. */
/*
--
Name           : pycabalv.pkh
Author         : JARTHURT
Date Created   : 23-MAR-1999
Description    : Canadian Balance Code
Date        BugNo     Author    Comment
-----------+---------+---------+--------------------------------------
23-MAR-1999           JARTHURT  Created.
11-FEB-2000           RThirlby  Added set_session_var, get_session_var
                                (2 overloaded versions), clear_session_vars
                                and clear_asgbal_cache.
21-OCT-2002  115.     tclewis   removed the pragmas on the get_value functions.
19-MAY-2003  115.4    kaverma   Moved code from US Tax Balance package
                                pay_us_balance_view_pkg to use core package directly.
17-FEB-2004  115.5    SDAHIYA   Deleted following sub-programs (Bug 3331035): -
                                 - goto_per_latest_balances
                                 - goto_asg_latest_balances
                                 - goto_route
                                 - run_route
*/

-- DATA STRUCTURE DEFINITIONS --
--------------------------------

--------------------
-- Latest Balance --
--------------------
type LatBal is record
(
-- latest_balance_id
--
lat_balid    pay_assignment_latest_balances.latest_balance_id%type,
--
-- latest balance
--
assactid     pay_assignment_latest_balances.assignment_action_id%type,
value        pay_assignment_latest_balances.value%type,
actseq       pay_assignment_actions.action_sequence%type,
effdate      date,
--
-- previous latest balance
--
-- prv_assactid pay_assignment_latest_balances.prev_assignment_action_id%type,
-- prv_value    pay_assignment_latest_balances.prev_balance_value%type,
-- prv_actseq   pay_assignment_actions.action_sequence%type,
-- prv_effdate  date,
--
-- expired balance
--
exp_assactid pay_assignment_latest_balances.expired_assignment_action_id%type,
exp_value    pay_assignment_latest_balances.expired_value%type,
exp_actseq   pay_assignment_actions.action_sequence%type,
exp_effdate  date
);

-----------------------------
-- List of Latest Balances --
-----------------------------
-- BHOMAN - can't PLSQL tables of records, so replace LatBalList
-- with individual tables for each element
-- type LatBalList is table of LatBal index by binary_integer;
type ListLatBalId is table of
        pay_assignment_latest_balances.latest_balance_id%type
        index by binary_integer;
type ListAssActId is table of
        pay_assignment_latest_balances.assignment_action_id%type
        index by binary_integer;
type ListValue is table of
        pay_assignment_latest_balances.value%type
        index by binary_integer;
type ListActSeq is table of
        pay_assignment_actions.action_sequence%type
        index by binary_integer;
type ListEffDate is table of
        date
        index by binary_integer;
type ListExpAssActID is table of
        pay_assignment_latest_balances.expired_assignment_action_id%type
        index by binary_integer;
type ListExpValue is table of
        pay_assignment_latest_balances.expired_value%type
        index by binary_integer;
type ListExpActSeq is table of
        pay_assignment_actions.action_sequence%type
        index by binary_integer;
type ListExpEffDate is table of
        date
        index by binary_integer;
------------------------------------------------------------------------------
-- Index for ranges of values in Latest Balance, and Context Values caches. --
------------------------------------------------------------------------------
type CacheIndex is record
(
index1 number,
index2 number
);

---------------------
-- List of Indexes --
---------------------
-- type CacheIndexList is table of CacheIndex index by binary_integer;

type SublistBounds is table of number index by binary_integer;

-------------
-- Context --
-------------
type Ctx is record
(
ctxid  ff_contexts.context_id%type,
ctxnam ff_contexts.context_name%type,
ctxval pay_balance_context_values.value%type
);

----------------------
-- List of Contexts --
----------------------
-- BHOMAN - can't PLSQL tables of records, so replace CtxList
-- with individual tables for each element
-- type CtxList is table of Ctx index by binary_integer;
type ListCtxId is table of
        ff_contexts.context_id%type
        index by binary_integer;
type ListCtxName is table of
        ff_contexts.context_name%type
        index by binary_integer;
type ListCtxValue is table of
        pay_balance_context_values.value%type
        index by binary_integer;


---------------------
-- Defined Balance --
---------------------
type DefBal is record
(
bal_typid   pay_balance_types.balance_type_id%type,
juris_lvl   pay_balance_types.jurisdiction_level%type,
dbi_suffix  pay_balance_dimensions.database_item_suffix%type,
dim_type    pay_balance_dimensions.dimension_type%type,
dim_name    pay_balance_dimensions.dimension_name%type
);

------------------------------
-- List of Defined Balances --
------------------------------
-- BHOMAN - can't PLSQL tables of records, so replace DefBalList
-- with individual tables for each element
-- type DefBalList is table of DefBal index by binary_integer;
type ListBalTypeId is table of
        pay_balance_types.balance_type_id%type
        index by binary_integer;
type ListJurisLvl is table of
        pay_balance_types.jurisdiction_level%type
        index by binary_integer;
type ListDbiSuffix is table of
        pay_balance_dimensions.database_item_suffix%type
        index by binary_integer;
type ListDimType is table of
        pay_balance_dimensions.dimension_type%type
        index by binary_integer;
type ListDimName is table of
        pay_balance_dimensions.dimension_name%type
        index by binary_integer;

-- each PLSQL table type needs a NULL table with which
-- we can reset it, since we cannot use delete operator
-- in earlier versions of PLSQL
ZeroBounds      SublistBounds;
ZeroLatBalId    ListLatBalId;
ZeroAssActId    ListAssActId;
ZeroValue       ListValue;
ZeroActSeq      ListActSeq;
ZeroEffDate     ListEffDate;
ZeroExpAssActId ListExpAssActID;
ZeroExpValue    ListExpValue;
ZeroExpActSeq   ListExpActSeq;
ZeroExpEffDate  ListExpEffDate;
ZeroCtxId       ListCtxId;
ZeroCtxName     ListCtxName;
ZeroCtxValue    ListCtxValue;

--------------------------------
-- GRE RECORD AND TABLE TYPES --
--------------------------------

TYPE gre_record_type IS RECORD
    (tax_unit_id    number,
     tax_group_name varchar2(150));

TYPE gre_table_type is table of gre_record_type
     index by binary_integer;
--
-- this table contains the list of tax_units / tax_groups
session_gre_table gre_table_type;
--

------------------------------------------------------------------
-- Positions of context values in input context list. Supported --
-- contexts are ASSIGNMENT_ACTION_ID, TAX_UNIT_ID, TAX_GROUP,   --
-- JURISDICTION_CODE, DATE_EARNED, BUSINESS_GROUP_ID,           --
-- BALANCE_DATE and SOURCE_ID.                                  --
------------------------------------------------------------------

pos_invalid              constant number := -1;
pos_assignment_action_id constant number := 1;
pos_jurisdiction_code    constant number := 2;
pos_tax_unit_id          constant number := 3;
pos_tax_group            constant number := 4;
pos_date_earned          constant number := 5;
pos_business_group_id    constant number := 6;
pos_balance_date         constant number := 7;
pos_source_id            constant number := 8;

------------------
-- GLOBAL STATE --
------------------

--------------------------------------------------------
-- assignment_id for which latest balances are cached --
--------------------------------------------------------
cached_assignment_id number := -1;

----------------------------------------------------
-- person_id for which latest balances are cached --
----------------------------------------------------
cached_person_id number := -1;

----------------------------------------------------
-- Mode string used by high level functions called
-- called in views.  Set this to 'ASG', 'GRE',  or
-- and value willbe passed as param to balance
-- functions like us_tax_balance and us_named_balance
----------------------------------------------------
balance_view_mode varchar(3) := 'ASG';

----------------------------------------------------
-- BOOLEAN flag used by high level functions called
-- called in views.  Set this to TRUE and balances
-- are calculated or retrieved by us_tax_balance_vm
-- and us_named_balance for p_time_types of
-- PYDATE and MONTH.   Set this to FALSE, and these
-- functions return NULL for these time types.
----------------------------------------------------
CalcAllTimeTypes number := 0;

-----------------------------------------------------------------------------
-- Assignment Latest Balance Cache                                         --
-- -------------------------------                                         --
-- ALBValues is a list of Latest Balance values for cached_assignment_id.  --
--                                                                         --
-- ALBIndex is indexed by defined_balance_id. ALBIndex.index1 and          --
-- ALBIndex.index2, respectively, point to the start and end of the        --
-- ALBValues corresponding to a given defined_balance_id. MaxALBIndex is   --
-- the next free slot in ALBValues.                                        --
--                                                                         --
-- ALB2CIndex is indexed by latest_balance_id. ALB2CIndex.index1 and       --
-- ALB2CIndex.index2, respectively, point to the start and end of the      --
-- ALB2CValues corresponding the a given latest_balance_id. MaxALB2CIndex  --
-- is the next free slot in ALB2CValues.                                   --
-----------------------------------------------------------------------------

MaxALBIndex             number := 0;
-- BHOMAN - can't PLSQL tables of records...
-- ALBIndex      CacheIndexList;
-- ALBValues     LatBalList;
ALBStart        SublistBounds;
ALBEnd          SublistBounds;
ALBLatBalId     ListLatBalId;
ALBAssActId     ListAssActId;
ALBValue        ListValue;
ALBActSeq       ListActSeq;
ALBEffDate      ListEffDate;
ALBExpAssActId  ListExpAssActID;
ALBExpValue     ListExpValue;
ALBExpActSeq    ListExpActSeq;
ALBExpEffDate   ListExpEffDate;

MaxALB2CIndex number := 0;
-- BHOMAN - can't PLSQL tables of records...
-- ALB2CIndex    CacheIndexList;
-- ALB2CValues   CtxList;
ALB2CStart      SublistBounds;
ALB2CEnd        SublistBounds;
ALB2CtxId       ListCtxId;
ALB2CtxName     ListCtxName;
ALB2CtxValue    ListCtxValue;

---------------------------------------------------------------------------
-- Person Latest Balance Cache                                           --
-- ---------------------------                                           --
-- Same as the Assignment Latest Balance Cache except that it caches     --
-- Latest Person Balance values for cached_person_id.                    --
-- There are two caches to simplify clearing out the cache when there is --
-- a change in person_id or assignment_id.                               --
---------------------------------------------------------------------------

MaxPLBIndex   number := 0;
-- BHOMAN - can't PLSQL tables of records...
-- PLBIndex             CacheIndexList;
-- PLBValues    LatBalList;
PLBStart        SublistBounds;
PLBEnd          SublistBounds;
PLBLatBalId     ListLatBalId;
PLBAssActId     ListAssActId;
PLBValue        ListValue;
PLBActSeq       ListActSeq;
PLBEffDate      ListEffDate;
PLBExpAssActId  ListExpAssActID;
PLBExpValue     ListExpValue;
PLBExpActSeq    ListExpActSeq;
PLBExpEffDate   ListExpEffDate;

MaxPLB2CIndex number := 0;
-- BHOMAN - can't PLSQL tables of records...
-- PLB2CIndex    CacheIndexList;
-- PLB2CValues   CtxList;
PLB2CStart              SublistBounds;
PLB2CEnd                SublistBounds;
PLB2CtxId               ListCtxId;
PLB2CtxName             ListCtxName;
PLB2CtxValue    ListCtxValue;

-----------------------------------------------------------------------
-- Defined Balance Cache                                             --
-- ---------------------                                             --
-- DBC is indexed by defined_balance_id. This cache is never cleared --
-- during a session.                                                 --
-----------------------------------------------------------------------
-- BHOMAN - can't PLSQL tables of records...
-- DBC          DefBalList;
DBCBalTypeId    ListBalTypeId;
DBCJurisLvl     ListJurisLvl;
DBCDbiSuffix    ListDbiSuffix;
DBCDimType      ListDimType;
DBCDimName      ListDimName;

------------------------------------------------------
-- input context value list (indexed by context_id) --
------------------------------------------------------
-- BHOMAN - can't PLSQL tables of records...
-- CtxValsCtxId CtxList;
CtxIdById               ListCtxId;
CtxNameById             ListCtxName;
CtxValueById    ListCtxValue;

----------------------------------------------------------
-- input context value list (indexed by pos_ constants) --
----------------------------------------------------------
-- BHOMAN - can't PLSQL tables of records...
-- CtxValsPos   CtxList;
CtxIdByPos              ListCtxId;
CtxNameByPos    ListCtxName;
CtxValueByPos   ListCtxValue;


-------------------------
-- Debug Message State --
-------------------------
DebugOn       BOOLEAN;
DebugLineCount NUMBER;
DebugLineMax    NUMBER;
type ListLines is table of
        VARCHAR2(120)
        index by binary_integer;
DebugList       ListLines;

--------------------------------
-- SESSION VARIABLES --
--------------------------------
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
type VarTable is table of VARCHAR2(150)
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
SessionVarCount NUMBER;

-------------------------------------
-- PROCEDURE/FUNCTION DECLARATIONS --
-------------------------------------
--------------------------------------------------------------------------------
--
-- get_session_var - main function
FUNCTION get_session_var(p_name VARCHAR2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_session_var, WNDS);
--
-- get_session_var with default parameter; if value not set, returns default.
FUNCTION get_session_var(p_name VARCHAR2, p_default VARCHAR) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_session_var, WNDS);
--------------------------------------------------------------------------------
PROCEDURE set_session_var (p_name IN VARCHAR2, p_value IN VARCHAR2);
PRAGMA RESTRICT_REFERENCES(set_session_var, WNDS);
--------------------------------------------------------------------------------
PROCEDURE clear_session_vars;
PRAGMA RESTRICT_REFERENCES(clear_session_vars, WNDS);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE debug_init;
PROCEDURE debug_wrap;
PRAGMA RESTRICT_REFERENCES(debug_init, WNDS);
PRAGMA RESTRICT_REFERENCES(debug_wrap, WNDS);
--
-- following debug funcs not WNDS-pure, not called from this pkg
--
PROCEDURE debug_set_max( p_max IN NUMBER);
PROCEDURE debug_on;
PROCEDURE debug_off;
PROCEDURE debug_reset;
PROCEDURE debug_dump;
PROCEDURE debug_dump_to_trace(p_trace_id IN VARCHAR2 DEFAULT NULL);
PROCEDURE debug_dump_err;
PROCEDURE debug_dump_like(p_string_like IN VARCHAR2);
PROCEDURE debug_dump(p_start_line IN NUMBER,
                                                        p_end_line IN NUMBER);
FUNCTION debug_get_line(p_line_number IN NUMBER) return VARCHAR2;
FUNCTION debug_get_count return NUMBER;
--------------------------------------------------------------------------------
-- BHOMAN - moved debug_msg decl above debug_toggle decl
PROCEDURE debug_msg ( p_debug_message IN VARCHAR2);
PRAGMA RESTRICT_REFERENCES(debug_msg, WNDS);
--------------------------------------------------------------------------------
PROCEDURE debug_err ( p_debug_message IN VARCHAR2);
PRAGMA RESTRICT_REFERENCES(debug_err, WNDS);
--------------------------------------------------------------------------------
PROCEDURE debug_toggle;
PRAGMA RESTRICT_REFERENCES(debug_toggle, WNDS);
--------------------------------------------------------------------------------
-- view mode set and retrieve functions
--------------------------------------------------------------------------------
FUNCTION get_view_mode return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_view_mode, WNDS);
--------------------------------------------------------------------------------
PROCEDURE set_view_mode ( p_view_mode IN VARCHAR2);
PRAGMA RESTRICT_REFERENCES(set_view_mode, WNDS);

--------------------------------------------------------------------------------
-- CalcAllTimeTypes flag set and retrieve functions
--------------------------------------------------------------------------------
FUNCTION get_calc_all_timetypes_flag return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_calc_all_timetypes_flag, WNDS);
--------------------------------------------------------------------------------
PROCEDURE set_calc_all_timetypes_flag ( p_calc_all IN NUMBER);
PRAGMA RESTRICT_REFERENCES(set_calc_all_timetypes_flag, WNDS);
--------------------------------------------------------------------------------
-- balance functions
--------------------------------------------------------------------------------
FUNCTION get_value ( p_assignment_action_id IN NUMBER,
                     p_defined_balance_id   IN NUMBER,
                     p_dont_cache           IN NUMBER,
                     p_always_get_dbi       IN NUMBER,
                     p_date_mode            IN NUMBER,
                     p_effective_date       IN DATE )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_value, WNDS);
--------------------------------------------------------------------------------
FUNCTION get_value( p_assignment_action_id IN NUMBER,
                    p_defined_balance_id   IN NUMBER,
                    p_dont_cache           IN NUMBER,
                    p_always_get_dbi       IN NUMBER )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_value, WNDS);
--------------------------------------------------------------------------------
FUNCTION get_value( p_assignment_action_id IN NUMBER,
                    p_defined_balance_id   IN NUMBER )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_value, WNDS);
--------------------------------------------------------------------------------
FUNCTION get_value( p_assignment_id        IN NUMBER,
                    p_defined_balance_id   IN NUMBER,
                    p_effective_date       IN DATE )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_value, WNDS);
--------------------------------------------------------------------------------
FUNCTION get_value( p_assignment_id        IN NUMBER,
                    p_defined_balance_id   IN NUMBER,
                    p_effective_date       IN DATE,
                    p_dont_cache           IN NUMBER )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_value, WNDS);
--------------------------------------------------------------------------------
PROCEDURE clear_asgbal_cache;
PRAGMA RESTRICT_REFERENCES(clear_asgbal_cache, WNDS);
--------------------------------------------------------------------------------
PROCEDURE clear_perbal_cache;
PRAGMA RESTRICT_REFERENCES(clear_perbal_cache, WNDS);
--------------------------------------------------------------------------------
PROCEDURE set_context( p_context_name  IN VARCHAR2,
                       p_context_value IN VARCHAR2 );
PRAGMA RESTRICT_REFERENCES(set_context, WNDS);

--------------------------------------------------------------------------------
FUNCTION get_context ( p_context_name  IN VARCHAR2)
return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_context, WNDS);

--------------------------------------------------------------------------------
-- BHOMAN
PROCEDURE dump_context;
PROCEDURE dump_context( p_known_name  IN VARCHAR2,
                       p_pos IN NUMBER );
--------------------------------------------------------------------------------
PROCEDURE clear_contexts;
PRAGMA RESTRICT_REFERENCES(clear_contexts, WNDS);
--------------------------------------------------------------------------------
-- Expiry Checking Code (mostly taken from pyusexc.pkh)
--------------------------------------------------------------------------------
FUNCTION date_expired( p_owner_assignment_action_id IN  NUMBER,
                       p_user_assignment_action_id  IN  NUMBER,
                       p_owner_effective_date       IN  DATE,
                       p_user_effective_date        IN  DATE,
                       p_dimension_name             IN  VARCHAR2,
                       p_date_mode                  IN  NUMBER )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(date_expired, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_period( p_assactid IN NUMBER,
                      p_date     IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_period, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_month( p_date   IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_month, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_quarter( p_date   IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_quarter, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_year( p_date   IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_year, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_fiscal_year( p_beg_of_fiscal_year IN DATE,
                           p_date               IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_fiscal_year, WNDS);
--------------------------------------------------------------------------------
FUNCTION next_fiscal_quarter( p_beg_of_fiscal_year IN DATE,
                              p_date               IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(next_fiscal_quarter, WNDS);
--------------------------------------------------------------------------------
FUNCTION CurrentTime
RETURN INTEGER;
--------------------------------------------------------------------------------

END pay_ca_balance_view_pkg;

 

/
