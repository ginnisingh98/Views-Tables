--------------------------------------------------------
--  DDL for Package PAY_PAYFV_ELEMENT_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYFV_ELEMENT_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: payfvele.pkh 115.2 2003/01/16 13:08:15 adhunter noship $ */
-------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 2001 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
        Supporting functions for BIS view PAYFV_ELEMENT_ENTRIES
Purpose
        To return non-id table information where needed to enhance the
        performance of the view.
History
        115.0   15-Jan-2001  J.Tomkins    Created
        115.1   15-Jan-2001  J.Tomkins    Added Header Information.
*/
--------------------------------------------------------------------------------
FUNCTION get_job (p_job_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_position (p_pos_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_grade (p_grade_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_location (p_loc_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_pay_basis (p_pay_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_payroll (p_payroll_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
END PAY_PAYFV_ELEMENT_ENTRIES_PKG;

 

/
