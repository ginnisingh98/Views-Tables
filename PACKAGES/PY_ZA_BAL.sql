--------------------------------------------------------
--  DDL for Package PY_ZA_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_BAL" AUTHID CURRENT_USER AS
/* $Header: pyzabal1.pkh 120.0 2005/05/29 10:21:01 appldev noship $ */
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION span_start(
        p_input_date   DATE,
        p_frequency    NUMBER   DEFAULT 1,
        p_start_dd_mm  VARCHAR2 DEFAULT '06-04-')
RETURN date ;
PRAGMA RESTRICT_REFERENCES (span_start, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- what is the latest reset date for a particular dimension
FUNCTION dimension_reset_date(
        p_dimension_name                IN VARCHAR2,
        p_user_date                             IN DATE,
        p_business_group_id     IN NUMBER)
RETURN date;
PRAGMA RESTRICT_REFERENCES (dimension_reset_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION start_director(
        p_assignment_id         NUMBER,
        p_start_date            DATE  ,
        p_end_date              DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (start_director, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION balance (
        p_assignment_action_id  IN NUMBER,
        p_defined_balance_id    IN NUMBER)
RETURN number ;
PRAGMA RESTRICT_REFERENCES (balance, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_all_balances(
         p_assignment_action_id IN NUMBER,
         p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_all_balances, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_all_balances(
         p_effective_date       IN DATE,
         p_assignment_id        IN NUMBER,
         p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_all_balances, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_asg_itd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_itd_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_asg_itd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_itd, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_itd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_itd_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_asg_run_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_run_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_asg_run(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_run, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_run_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_asg_run_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_payments_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_payments_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_payments(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id         IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_payments, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_payments_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_payments_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------




-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_PTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_PTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_PTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_PTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_TAX_PTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_PTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_YTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_YTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_YTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_YTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_TAX_YTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_YTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_MTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_MTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_MTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_MTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_TAX_MTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_MTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_QTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_QTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_TAX_QTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_QTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_TAX_QTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_TAX_QTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_PTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_PTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_PTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_PTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_CAL_PTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_PTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_YTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_YTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_YTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_YTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_CAL_YTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_YTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_MTD_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_MTD_action, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_ASG_CAL_MTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_MTD, WNDS, WNPS);
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_ASG_CAL_MTD_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_ASG_CAL_MTD_date, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------








-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION calc_balance(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,      -- balance
        p_period_from_date      IN DATE,        -- since regular pay date of period
        p_event_from_date       IN DATE,        -- since effective date of
        p_to_date               IN DATE,        -- sum up to this date
        p_action_sequence       IN NUMBER)      -- sum up to this sequence
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_balance, WNDS, WNPS);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
PROCEDURE create_dimension(
                errbuf                  OUT NOCOPY     VARCHAR2,
                retcode                 OUT NOCOPY     NUMBER,
                p_business_group_id     IN      NUMBER,
                p_suffix                IN      VARCHAR2,
                p_level                 IN      VARCHAR2,
                p_start_dd_mm           IN      VARCHAR2,
                p_frequency             IN      NUMBER,
                p_global_name           IN      VARCHAR2 DEFAULT NULL);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
PROCEDURE check_expiry(
                p_owner_payroll_action_id       IN      NUMBER,
                p_user_payroll_action_id        IN      NUMBER,
                p_owner_assignment_action_id    IN      NUMBER,
                p_user_assignment_action_id     IN      NUMBER,
                p_owner_effective_date          IN      DATE,
                p_user_effective_date           IN      DATE,
                p_dimension_name                IN      VARCHAR2,
                p_expiry_information            OUT NOCOPY     NUMBER);
-----------------------------------------------------------------------
-----------------------------------------------------------------------

--3491357
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION get_balance_value(
                 p_assignment_id       IN  NUMBER,
                 p_balance_type_id     IN  NUMBER,
                 p_dimension           IN  VARCHAR2,
                 p_effective_date      IN  DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION get_balance_value_action(
                 p_assignment_action_id  IN  NUMBER,
                 p_balance_type_id       IN  NUMBER,
                 p_dimension             IN  VARCHAR2)
RETURN NUMBER;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--Bug 4365925
FUNCTION get_balance_value(
                 p_defined_balance_id  IN NUMBER,
                 p_assignment_id       IN  NUMBER,
                 p_effective_date      IN  DATE)
RETURN NUMBER;
-----------------------------------------------------------------------

END py_za_bal;


 

/
