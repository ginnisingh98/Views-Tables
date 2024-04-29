--------------------------------------------------------
--  DDL for Package PY_ZA_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_ROUTES" AUTHID CURRENT_USER AS
/* $Header: pyzarout.pkh 120.3 2005/07/04 03:07:01 kapalani noship $ */
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX PERIOD balance dimension
--
FUNCTION ASG_TAX_PTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_TAX_PTD, WNDS, WNPS);
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX YEAR balance dimension
--
FUNCTION ASG_TAX_YTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_TAX_YTD, WNDS, WNPS);
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX QUARTER balance dimension
--
FUNCTION ASG_TAX_QTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_TAX_QTD, WNDS, WNPS);
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL TAX MONTH balance dimension
--
FUNCTION ASG_TAX_MTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_TAX_MTD, WNDS, WNPS);
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR PERIOD balance dimension
--
FUNCTION ASG_CAL_PTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_CAL_PTD, WNDS, WNPS);
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR YEAR balance dimension
--
FUNCTION ASG_CAL_YTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_CAL_YTD, WNDS, WNPS);
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL CALENDAR MONTH
-- balance dimension
--
FUNCTION ASG_CAL_MTD(p_assignment_action_id    NUMBER,
                     p_balance_type_id         NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_CAL_MTD, WNDS, WNPS);
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL INCEPTION-TO-DATE
-- balance dimension
--
FUNCTION ASG_ITD(p_assignment_action_id    NUMBER,
                     p_balance_type_id     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_ITD, WNDS, WNPS);
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYROLL RUN balance dimension
--
FUNCTION ASG_RUN(p_assignment_action_id    NUMBER,
                     p_balance_type_id     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ASG_RUN, WNDS, WNPS);
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Summed data for the ASSIGNMENT-LEVEL PAYMENTS balance dimension
--
FUNCTION PAYMENTS(p_assignment_action_id    NUMBER,
                     p_balance_type_id      NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (PAYMENTS, WNDS, WNPS);
-----------------------------------------------------------------------------
--
END py_za_routes;

 

/
