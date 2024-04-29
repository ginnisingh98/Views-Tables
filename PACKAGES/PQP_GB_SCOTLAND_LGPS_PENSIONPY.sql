--------------------------------------------------------
--  DDL for Package PQP_GB_SCOTLAND_LGPS_PENSIONPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_SCOTLAND_LGPS_PENSIONPY" AUTHID CURRENT_USER AS
/* $Header: pqgbsclgps.pkh 120.4.12010000.1 2008/09/17 12:48:55 skpatil noship $ */


procedure DERIVE_PENSIONABLE_PAY(errbuf out nocopy varchar2,
                                 retcode out nocopy number,
                                 p_effective_start_dt IN varchar2,
                                 p_effective_end_dt IN varchar2,
                                 p_payroll_id IN NUMBER,
                                 p_assignment_set_id IN NUMBER,
                                 p_assignment_number IN varchar2,
                                 p_employee_no IN varchar2,
                                 p_business_group_id IN NUMBER,
                                 p_mode in varchar2 );
--
/*Function GET_PQP_LGPS_TRANSITIONAL_FLAG(p_assignment_id IN NUMBER, p_effective_date Date, p_business_group_id number)
return varchar2; */

Function GET_PQP_LGPS_PENSION_PAY(p_assignment_id IN NUMBER, p_effective_date Date, p_business_group_id number)
return number;

/*Function GET_PQP_LGPS_ELEMENT_NAME(p_assignment_id IN NUMBER, p_effective_date Date)
return varchar2; */

/*Function GET_FINANCIAL_YEAR(p_effective_date Date)
return number;/
--
/* 6666135 Begin
Function RUN_USER_FORMULA(p_assignment_id number,p_effective_date date, p_business_group_id number, p_payroll_id number)
return number;
6666135 End */


end PQP_GB_SCOTLAND_LGPS_PENSIONPY;

/
