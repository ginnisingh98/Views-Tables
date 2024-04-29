--------------------------------------------------------
--  DDL for Package PAY_VOID_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_VOID_PAYMENTS" AUTHID CURRENT_USER AS
-- $Header: pyvoidpy.pkh 120.0 2005/05/29 10:16:09 appldev noship $

--
--==============================================================================
-- VOID_PAYMENTS
--
--
--==============================================================================
PROCEDURE void_run (p_errmsg            OUT NOCOPY VARCHAR2,
                    p_errcode           OUT NOCOPY NUMBER,
                    p_payroll_action_id NUMBER,
                    p_effective_date    VARCHAR2,
                    p_reason            VARCHAR2,
                    p_start_cheque      NUMBER default null,
                    p_end_cheque        NUMBER default null,
                    p_start_assignment  NUMBER default null,
                    p_end_assignment    NUMBER default null);
--
END pay_void_payments;
 

/
