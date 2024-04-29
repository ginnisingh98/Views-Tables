--------------------------------------------------------
--  DDL for Package PAY_GET_JOB_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GET_JOB_SEGMENT_PKG" AUTHID CURRENT_USER as
/* $Header: pygbjseg.pkh 115.1 2003/01/03 11:21:28 nsugavan noship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name
    PAY_GET_JOB_SEGMENT_PKG
  Purpose
    Function to pass on the value of the job segment selected in Tax Details
    References DFF or blank if no segment is selected. Function is moved here
    to a seperate package to facilitate call to the function in oracle 8.0
    as functions defined in the same package cannot be called in R8.0
--
REM Change List
REM -----------
REM Name          Date        Version Bug     Text
REM ------------- ----------- ------- ------- --------------------------
REM nsugavan      12/24/2002    115.0 2657976 Initial Version
REM nsugavan      01/03/2003    115.1 2657976 Removed parameter job name
============================================================================*/


-- EDI MES
--
function  get_job_segment(p_organization_id             in hr_organization_information.organization_id%type
                         ,p_job_definition_id           in number
                         ,p_payroll_action_id           in number)
                         return varchar2;
--
-- EDI MES
--
pragma restrict_references (get_job_segment,  WNDS, WNPS);

end pay_get_job_segment_pkg;

 

/
