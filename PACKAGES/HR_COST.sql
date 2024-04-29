--------------------------------------------------------
--  DDL for Package HR_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COST" AUTHID CURRENT_USER as
/* $Header: pycostng.pkh 120.1.12010000.2 2008/09/15 12:23:58 pparate ship $ */
--
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993, 1994 All rights reserved.
--
/*
   NAME
      pycostng.pkh
--
   DESCRIPTION
      Package headers for the procedures used in the costing process.
      ie. called by file: pycos.lpc.
--
  MODIFIED (DD-MON-YYYY)
     alogue     23-FEB-2007 - Added p_element_type_id to get_context_value.
     alogue     20-MAY-2005 - New get_rr_date function.
     alogue     07-DEC-2004 - New get_context_value function.
     alogue     22-MAR-2004 - New cost_bal_adj function and remove
                              old obsolete code.
     mwcallag   20-MAR-1995 - Removed procedure get_suspense. Now
                              performed in the 'C' code.
     mwcallag   16-AUG-1994 - Major changes for new functionality.
                              See pycos.lpc for more information.
     mwcallag   24-MAR-1993 - Removed blank lines.
     H. Minton  11-MAR-1993 - Added copyright and exit line.
     mwcallag   03-MAR-1993 - created.
*/
    function cost_bal_adj
    (
        p_element_entry_id in number,
        p_baladj_date      in date
    ) return varchar2;
--
    function get_context_value
    (
        p_inp_val_name      in  varchar2,
        p_run_result_id     in  number,
        p_element_type_id   in number,
        p_eff_date          in  date
    ) return varchar2;
--
    function get_rr_date
    (
        p_source_id         in  number,
        p_source_type       in  varchar2,
        p_end_date          in  date,
        p_date_earned       in  date
    ) return date;
    function get_cost_date
    (
        p_source_id         in  number,
        p_source_type       in  varchar2,
        p_end_date          in  date,
        p_date_earned       in  date
    ) return date;
--
end hr_cost;

/
