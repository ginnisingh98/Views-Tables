--------------------------------------------------------
--  DDL for Package HR_DIRBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DIRBAL" AUTHID CURRENT_USER AS
/* $Header: pydirbal.pkh 120.0.12000000.1 2007/01/17 18:21:39 appldev noship $ */
-------------------------------------------------------------------------------
-- Date Mode
FUNCTION get_balance (p_assignment_id   IN NUMBER,
                      p_defined_balance_id IN NUMBER,
                      p_effective_date     IN DATE)
RETURN NUMBER;
-------------------------------------------------------------------------------
-- Assignment Action Mode
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
                      p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
-------------------------------------------------------------------------------
-- This overload function can be used only in PAYGBTPL report in Q_SCON
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
                      p_defined_balance_id   IN NUMBER,
                      p_dimension_id         IN NUMBER,
                      p_period_id            IN NUMBER,
                      p_ptd_bal_dim_id       IN NUMBER)
RETURN NUMBER;
-------------------------------------------------------------------------------
FUNCTION balance_expired (p_assignment_action_id IN NUMBER,
                          p_owning_action_id     IN NUMBER DEFAULT NULL,
                          p_defined_balance_id   IN NUMBER,
                          p_database_item_suffix IN VARCHAR2 DEFAULT NULL,
                          p_effective_date       IN DATE,
                          p_action_effective_date IN DATE DEFAULT NULL)
--
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (balance_expired, WNDS);
-------------------------------------------------------------------------------
FUNCTION start_year_date(p_assignment_action_id  IN NUMBER,
                         p_database_item_suffix  IN VARCHAR2)
--
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (start_year_date, WNDS);
-------------------------------------------------------------------------------
FUNCTION expired_year_date(p_action_effective_date IN DATE)
--
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (expired_year_date, WNDS);
-------------------------------------------------------------------------------
FUNCTION expired_period_date(p_assignment_action_id IN NUMBER)
--
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (expired_period_date, WNDS);
-------------------------------------------------------------------------------
FUNCTION expired_quarter_date(p_action_effective_date IN DATE)
--
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (expired_quarter_date, WNDS);
-------------------------------------------------------------------------------
FUNCTION get_action_date(p_assignment_action_id IN NUMBER)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (get_action_date, WNDS);
-------------------------------------------------------------------------------
--
END hr_dirbal;
 

/
