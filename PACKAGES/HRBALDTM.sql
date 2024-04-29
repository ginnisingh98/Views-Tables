--------------------------------------------------------
--  DDL for Package HRBALDTM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRBALDTM" AUTHID CURRENT_USER as
/* $Header: pybaldtm.pkh 115.0 99/07/17 05:44:27 porting ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pybaldtm.pkh           - Payroll Balance for DaTe Mode
--
   DESCRIPTION
      This package is used to insert an assignment action so that a balance
      may be obtained for a given date.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   01-OCT-1993 - created.
*/
PROCEDURE get_bal_ass_action
(
    p_business_group_id     in  number,
    p_assignment_id         in  number,
    p_date                  in  date,
    p_ass_action_id         out number
);
--
end hrbaldtm;

 

/
