--------------------------------------------------------
--  DDL for Package PAY_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DRT" AUTHID CURRENT_USER AS
/* $Header: pydrtut.pkh 120.0.12010000.5 2018/05/17 06:09:37 emunisek noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_drt
 Package File Name : pydrtut.pkh
 Description : Core Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 emunisek    08-Mar-2018   120.0   27660496  Created
 emunisek    12-Mar-2018   120.1   27660496  Modified parameters of function
                                             additional_filter
 emunisek    03-May-2018   120.2   27943094  Added new procedure pay_hr_post
 emunisek    16-May-2018   120.3   28025987  Modified signature of
                                             mask_value_udf to use ROWID
                                             instead of RAW for rowid
                                             parameter
 emunisek    17-May-2018   120.4   28038251  Modified signature of mask_value_udf
************************************************************************ */

    g_person_id           per_all_people_f.person_id%TYPE;
    g_assignment_id       per_all_assignments_f.assignment_id%TYPE;
    g_business_group_id   per_all_people_f.business_group_id%TYPE;
    g_legislation_code    per_business_groups.legislation_code%TYPE;

    -- Procedure to determine Business Group ID and Legislation Code
    PROCEDURE extract_details(p_person_id IN per_all_people_f.person_id%TYPE);

    -- Function to return if the Row needs to be filtered out.
    -- If Y is returned, row will be considered for further processing.

    FUNCTION additional_filter(p_person_id   IN  per_all_people_f.person_id%TYPE,
                               p_table_name  IN  VARCHAR2,
                               p_row_id      IN  VARCHAR2)
    RETURN VARCHAR2;

    -- User Defined Function to return the mask value

    FUNCTION mask_value_udf(rowid       ROWID,
                            table_name  VARCHAR2,
                            column_name VARCHAR2,
                            person_id   NUMBER)
    RETURN VARCHAR2;

    -- Procedure to clear data from PAY_PROCESS_EVENTS in Post Processing.

    PROCEDURE pay_hr_post(p_person_id NUMBER);

END pay_drt;

/
