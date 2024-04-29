--------------------------------------------------------
--  DDL for Package HRGETACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRGETACT" AUTHID CURRENT_USER as
/* $Header: pegetact.pkh 115.2 99/10/12 10:44:51 porting ship $ */
--
--
/* Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved */
/*
PRODUCT
    Oracle*Personnel
--
NAME
    pegetact.pkb   - calculate assignment budget values
--
DESCRIPTION
    calculate head count called from personnel screen PERBUDBU.
--
MODIFIED (DD-MON-YYYY)
    kkoh       11-SEP-1998 - Added PRAGMA RESTRICT_REFERENCES so that other
                             functions can call this package
    mwcallag   11-MAY-1993 - p_variance_percent changed to varchar2 to handle
                             percentage values that are too large
    mwcallag   10-MAY-1993 - created
    ccarter    15-OCT-1999   Bug 1027169, removed pragma restriction from get_actuals
*/
procedure get_actuals
(
    p_unit              in  varchar2,
    p_bus_group_id      in  number,
    p_organisation_id   in  number,
    p_job_id            in  number,
    p_position_id       in  number,
    p_grade_id          in  number,
    p_start_date        in  date,
    p_end_date          in  date,
    p_actual_val        in  number,
    p_actual_start_val  out number,
    p_actual_end_val    out number,
    p_variance_amount   out number,
    p_variance_percent  out varchar2
);
--PRAGMA RESTRICT_REFERENCES(get_actuals,WNDS);
end hrgetact;

 

/
