--------------------------------------------------------
--  DDL for Package PY_ZA_TAX_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TAX_REG" AUTHID CURRENT_USER AS
/* $Header: pyzatreg.pkh 120.2.12010000.2 2009/12/02 08:53:23 parusia ship $ */
/* Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA */
/*                       All rights reserved.
/*
Change List:
------------

Name           Date          Version   Bug       Text
-------------- -----------   -------   -------   -----------------------
P.Arusia       2/12/2009     115.9     9117260   Added pre_process_01032009
                                                 for use from 01-03-2009
J.N. Louw      04/02/2002    115.5               Removed OUT parameter
                                                 p_cmpy_tax_ref_num from
                                                 pre_process
J.N. Louw      04/02/2002    115.4               Added
                                                 include_assignment
J.N. Louw      25/01/2002    115.2     1756600   Register was updated to
                                       1756617   accommodate bug changes
                                       1858619   and merge of both
                                       2117507   current and terminated
                                       2132644   assignments reports
A vd Berg      22-Jan-2001   110.11              Amended Version Number
G. Fraser      24-May-2000   110.3               Speed improvements
L.J.Kloppers   23-FEB-2000   110.2               Added p_tax_register_id
                                                 IN OUT NOCOPY parameter
L.J.Kloppers   13-FEB-2000   110.1               Added p_total_employees
                                                 and p_total_assignments
                                                 IN OUT NOCOPY parameters
L.J.Kloppers   13-FEB-2000   110.0               Initial Version
*/
-------------------------------------------------------------------------------
--                           PACKAGE SPECIFICATION                           --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- include_assignment
-- It is called from the value set PY_SRS_ZA_TX_RGSTR_ASG
-------------------------------------------------------------------------------
FUNCTION include_assignment (
   p_asg_id          IN per_all_assignments_f.assignment_id%TYPE
 , p_period_end_date IN per_time_periods.end_date%TYPE
 , p_include_flag    IN VARCHAR2
 ) RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- pre_process
-------------------------------------------------------------------------------
PROCEDURE pre_process (
   p_payroll_id        IN     pay_all_payrolls_f.payroll_id%TYPE
 , p_start_period_id   IN     per_time_periods.time_period_id%TYPE     DEFAULT NULL
 , p_end_period_id     IN     per_time_periods.time_period_id%TYPE
 , p_include           IN     VARCHAR2
 , p_assignment_id     IN     per_all_assignments_f.assignment_id%TYPE DEFAULT NULL
 , p_retrieve_ptd      IN     VARCHAR2
 , p_retrieve_mtd      IN     VARCHAR2
 , p_retrieve_ytd      IN     VARCHAR2
 , p_tax_register_id      OUT NOCOPY pay_za_tax_registers.tax_register_id%TYPE
 , p_payroll_name         OUT NOCOPY pay_all_payrolls_f.payroll_name%TYPE
 , p_period_num           OUT NOCOPY per_time_periods.period_num%TYPE
 , p_period_start_date    OUT NOCOPY per_time_periods.start_date%TYPE
 , p_period_end_date      OUT NOCOPY per_time_periods.end_date%TYPE
 , p_tot_employees        OUT NOCOPY NUMBER
 , p_tot_assignments      OUT NOCOPY NUMBER
 );

-------------------------------------------------------------------------------
-- pre_process_01032009
-------------------------------------------------------------------------------
PROCEDURE pre_process_01032009 (
   p_payroll_id        IN     pay_all_payrolls_f.payroll_id%TYPE
 , p_start_period_id   IN     per_time_periods.time_period_id%TYPE     DEFAULT NULL
 , p_end_period_id     IN     per_time_periods.time_period_id%TYPE
 , p_include           IN     VARCHAR2
 , p_assignment_id     IN     per_all_assignments_f.assignment_id%TYPE DEFAULT NULL
 , p_retrieve_ptd      IN     VARCHAR2
 , p_retrieve_mtd      IN     VARCHAR2
 , p_retrieve_ytd      IN     VARCHAR2
 , p_tax_register_id      OUT NOCOPY pay_za_tax_registers.tax_register_id%TYPE
 , p_payroll_name         OUT NOCOPY pay_all_payrolls_f.payroll_name%TYPE
 , p_period_num           OUT NOCOPY per_time_periods.period_num%TYPE
 , p_period_start_date    OUT NOCOPY per_time_periods.start_date%TYPE
 , p_period_end_date      OUT NOCOPY per_time_periods.end_date%TYPE
 , p_tot_employees        OUT NOCOPY NUMBER
 , p_tot_assignments      OUT NOCOPY NUMBER
 );
-------------------------------------------------------------------------------
-- clear_register
-------------------------------------------------------------------------------
PROCEDURE clear_register (
   p_id IN pay_za_tax_registers.tax_register_id%TYPE
 );

end py_za_tax_reg;

/
