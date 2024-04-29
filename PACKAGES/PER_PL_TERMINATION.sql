--------------------------------------------------------
--  DDL for Package PER_PL_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_TERMINATION" AUTHID CURRENT_USER as
/* $Header: peplterp.pkh 120.0 2006/03/01 22:33:47 mseshadr noship $ */

PROCEDURE ACTUAL_TERMINATION_EMP(p_period_of_service_id    per_periods_of_service.period_of_service_id%TYPE
                                ,p_actual_termination_date per_periods_of_service.actual_termination_date%TYPE
                                ,p_business_group_id       NUMBER);


PROCEDURE REVERSE(p_period_of_service_id      per_periods_of_service.period_of_service_id%TYPE
                  ,p_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE
                  ,p_leaving_reason           per_periods_of_service.leaving_reason%TYPE);
End PER_PL_TERMINATION;


 

/
