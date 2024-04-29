--------------------------------------------------------
--  DDL for Package PER_IE_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IE_TERMINATION" AUTHID CURRENT_USER as
/* $Header: peieterm.pkh 120.0.12000000.1 2007/01/21 23:22:43 appldev ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package header
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  15 SEP 2003 srkotwal  N/A       Created for bug 3134506
    24-oct-2003 vmkhande             bug fix for 3208777
-------------------------------------------------------------------------------
*/
--  -------------------------------------------------------------------
--  procedure REVERSE
--  -------------------------------------------------------------------
    PROCEDURE REVERSE (P_PERIOD_OF_SERVICE_ID per_periods_of_service.period_of_service_id%Type
                      ,P_ACTUAL_TERMINATION_DATE per_periods_of_service.actual_termination_date%Type
                      ,P_LEAVING_REASON per_periods_of_service.leaving_reason%Type);
--  -------------------------------------------------------------------
--  procedure ACTUAL_TERMINATION
--  -------------------------------------------------------------------
    PROCEDURE ACTUAL_TERMINATION(p_period_of_service_id per_periods_of_service.period_of_service_id%Type
                                 ,p_actual_termination_date per_periods_of_service.actual_termination_date%Type);
    PROCEDURE FINAL_TERMINATION(  p_period_of_service_id per_periods_of_service.period_of_service_id%Type
                                 ,p_final_process_date Date);

end PER_IE_TERMINATION;

 

/
