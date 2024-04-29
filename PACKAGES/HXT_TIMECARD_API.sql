--------------------------------------------------------
--  DDL for Package HXT_TIMECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIMECARD_API" AUTHID CURRENT_USER AS
/* $Header: hxttapi.pkh 115.6 2002/11/28 01:38:46 fassadi ship $ */

PROCEDURE obtain_accrual_balance(--HXT11i1 i_employee_number IN VARCHAR2,
                                 i_employee_id IN NUMBER,  --HXT11i1
                                 i_calculation_date IN DATE,
                                 i_accrual_plan_name IN VARCHAR2,
                                 o_net_accrual OUT NOCOPY NUMBER,
                                 o_otm_error OUT NOCOPY VARCHAR2,
                                 o_oracle_error OUT NOCOPY VARCHAR2);

PROCEDURE accrual_plan_name   (p_element_type_id        IN  NUMBER,
                               p_date_worked            IN  DATE,
                               p_assignment_id          IN  NUMBER,
                               o_accrual_plan_name      OUT NOCOPY VARCHAR2,
                               o_return_code            OUT NOCOPY NUMBER,
                               o_otm_error              OUT NOCOPY VARCHAR2,
                               o_oracle_error           OUT NOCOPY VARCHAR2);

PROCEDURE total_accrual_for_week(p_tim_id                IN  NUMBER
                                ,p_edit_date             IN  DATE
                             -- ,HXT11i1 p_empl_number   IN  VARCHAR2
                                ,p_empl_id               IN  NUMBER  --HXT11i1
                                ,o_tot_hours             OUT NOCOPY NUMBER
                                ,o_accrual_plan_name     OUT NOCOPY VARCHAR2
                                ,o_return_code           OUT NOCOPY NUMBER
                                ,o_otm_error             OUT NOCOPY VARCHAR2
                                ,o_oracle_error          OUT NOCOPY VARCHAR2
                                ,o_lookup_code           OUT NOCOPY VARCHAR2);

END HXT_TIMECARD_API;

 

/
