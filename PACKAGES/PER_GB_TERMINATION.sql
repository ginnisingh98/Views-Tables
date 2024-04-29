--------------------------------------------------------
--  DDL for Package PER_GB_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_TERMINATION" AUTHID CURRENT_USER as
/* $Header: pergbtem.pkh 120.0.12000000.1 2007/01/22 03:14:37 appldev noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  GB Term package header
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+------------------------------------
**  16-MAY-05   K.Thampan 4351635  Created.
**
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

end PER_GB_TERMINATION;

 

/
