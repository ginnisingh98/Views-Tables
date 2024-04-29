--------------------------------------------------------
--  DDL for Package Body FFSTUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFSTUP" as
/* $Header: ffstup.pkb 115.0 99/07/16 02:03:31 porting ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   ffstup

  Description: Handles forms behaviour and validation in various modes such
               as startup and normal modes
  Change List
  -----------
  P Gowers       10-MAR-1993     Rename package to ffstup
  P Gowers       03-MAR-1993     Creation
  A Roussel      27-OCT-1994     Moved header to after create/replace
*/
------------------------------- PRIVATE GLOBALS -------------------------------
--
  MASTER_MODE CONSTANT varchar2(7)   := 'MASTER';
  SEED_MODE CONSTANT varchar2(5)     := 'SEED';
  NON_SEED_MODE CONSTANT varchar2(9) := 'NON-SEED';
--
-------------------------------- check_change --------------------------------
/*
  NAME
    check_change
  DESCRIPTION
    Checks startup_mode, business group and legislation and determines
    whether a change is allowed. Doesn't actually check values of business
    group or legislation (assumes you can only see legal combinations).
    If allowed, returns TRUE, otherwise returns FALSE.
*/
function check_change (p_startup_mode in varchar2,
                       p_bus_grp in number,
                       p_leg_code in varchar2) return boolean is
begin
  if (p_startup_mode = NON_SEED_MODE) then
    -- Can only allow change if record is non-seed (ie both are not null)
    if (p_bus_grp is null OR p_leg_code is null) then
      return FALSE;
    else
      return TRUE;
    end if;
  elsif (p_startup_mode = SEED_MODE) then
    -- Can only allow change if record is seed (ie legislation is not null)
    if (p_leg_code is null) then
      return FALSE;
    else
      return TRUE;
    end if;
  elsif (p_startup_mode = MASTER_MODE) then
    -- If in master mode, can only see master records, so delete must be OK
    return TRUE;
  else
    -- Trap logic error
    hr_utility.raise_error;
  end if;
end check_change;
--
---------------------------------- get_mode ----------------------------------
/*
  NAME
    get_mode
  DESCRIPTION
    Returns mode based on business group and legislation.
*/
function get_mode(p_bus_grp in number,
                  p_leg_code in varchar2) return varchar2 is
begin
  if (p_bus_grp is not null) then
    return NON_SEED_MODE;
  elsif (p_bus_grp is null and p_leg_code is not null) then
    return SEED_MODE;
  else
    return MASTER_MODE;
  end if;
end get_mode;
--
end ffstup;

/
