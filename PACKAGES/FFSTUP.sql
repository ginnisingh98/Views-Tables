--------------------------------------------------------
--  DDL for Package FFSTUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FFSTUP" AUTHID CURRENT_USER as
/* $Header: ffstup.pkh 115.0 99/07/16 02:03:34 porting ship $ */
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
-------------------------------- check_change --------------------------------
/*
  NAME
    check_change
  DESCRIPTION
    Checks startup_mode, business group and legislation and determines
    whether a change is allowed. If allowed, returns TRUE otherwise
    returns FALSE.
*/
function check_change (p_startup_mode in varchar2,
                       p_bus_grp in number,
                       p_leg_code in varchar2) return boolean;
--
---------------------------------- get_mode ----------------------------------
/*
  NAME
    get_mode
  DESCRIPTION
    Returns mode based on business group and legislation.
*/
function get_mode(p_bus_grp in number,
                  p_leg_code in varchar2) return varchar2;
--
end ffstup;

 

/
