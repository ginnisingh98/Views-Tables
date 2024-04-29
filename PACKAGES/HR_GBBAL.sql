--------------------------------------------------------
--  DDL for Package HR_GBBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GBBAL" AUTHID CURRENT_USER AS
/* $Header: pygbbal.pkh 120.2.12010000.2 2009/07/30 09:30:03 jvaradra ship $ */
----------------------------------------------------------------------
FUNCTION span_start(
      p_input_date      IN DATE,
      p_frequency     IN NUMBER DEFAULT 1,
      p_start_dd_mm  IN VARCHAR2 DEFAULT '06-04-')
RETURN date ;
PRAGMA RESTRICT_REFERENCES (span_start, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION span_end(
        p_input_date   IN DATE,
        p_frequency    IN NUMBER DEFAULT 1,
        p_start_dd_mm  IN VARCHAR2 DEFAULT '06-04-')
RETURN date ;
PRAGMA RESTRICT_REFERENCES (span_end, WNDS, WNPS);
-----------------------------------------------------------------------
-- what is the latest reset date for a particular dimension
FUNCTION dimension_reset_date(
      p_dimension_name        IN VARCHAR2,
      p_user_date                   IN DATE,
      p_business_group_id     IN NUMBER)
RETURN date;
PRAGMA RESTRICT_REFERENCES (dimension_reset_date, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION start_director(
        p_assignment_id         NUMBER,
        p_start_date            DATE  ,
        p_end_date              DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (start_director, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION balance (
      p_assignment_action_id  IN NUMBER,
        p_defined_balance_id    IN NUMBER,
      p_effective_date        IN DATE DEFAULT NULL) -- For D.M. Calls
RETURN number ;
-----------------------------------------------------------------------
FUNCTION calc_per_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id       IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_per_ptd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_per_ptd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_proc_ytd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_proc_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id       IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_proc_ytd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_qtd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_qtd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER
)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_qtd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_all_balances(
         p_assignment_action_id IN NUMBER,
         p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_all_balances(
         p_effective_date       IN DATE,
         p_assignment_id        IN NUMBER,
         p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_ytd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_ytd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_stat_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_stat_ytd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_stat_ytd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_proc_ptd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_proc_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_proc_ptd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_run_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_run(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_run_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date      IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_payment_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_payment(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_payment_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_itd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_itd(
      p_assignment_id         IN NUMBER,
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_itd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_itd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_itd(
      p_assignment_id         IN NUMBER,
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_td_itd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_tfr_ptd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_tfr_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_tfr_ptd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_ytd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
      p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--date mode function
FUNCTION calc_asg_td_ytd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
-- added by skutteti
--
FUNCTION calc_asg_td_odd_two_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_odd_two_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_odd_two_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--
FUNCTION calc_asg_td_even_two_ytd_actio(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE DEFAULT NULL)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_even_two_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_asg_td_even_two_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id         IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
FUNCTION calc_balance(
      p_assignment_id   IN NUMBER,
      p_balance_type_id IN NUMBER,  -- balance
      p_period_from_date      IN DATE,    -- since regular pay date of period
      p_event_from_date IN DATE,    -- since effective date of
      p_to_date         IN DATE,    -- sum up to this date
      p_action_sequence       IN NUMBER)  -- sum up to this sequence
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calc_balance, WNDS, WNPS);
-----------------------------------------------------------------------
FUNCTION calc_element_itd_bal(p_assignment_action_id IN NUMBER,
                              p_balance_type_id      IN NUMBER,
                              p_source_id            IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_element_co_itd_bal(p_assignment_action_id IN NUMBER,
                                 p_balance_type_id      IN NUMBER,
                                 p_source_id            IN NUMBER,
                                 p_source_text          IN VARCHAR2)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION calc_element_ptd_bal(p_assignment_action_id IN NUMBER,
                              p_balance_type_id      IN NUMBER,
                              p_source_id            IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------
FUNCTION get_element_reference(p_run_result_id        IN NUMBER,
                         p_database_item_suffix IN VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------
FUNCTION get_context_references(p_context_value        IN VARCHAR2,
                          p_database_item_suffix IN VARCHAR2)
RETURN VARCHAR2;
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
PROCEDURE check_expiry(
            p_owner_payroll_action_id     IN    NUMBER,
            p_user_payroll_action_id      IN    NUMBER,
            p_owner_assignment_action_id  IN    NUMBER,
            p_user_assignment_action_id   IN    NUMBER,
            p_owner_effective_date        IN    DATE,
            p_user_effective_date         IN    DATE,
            p_dimension_name        IN    VARCHAR2,
            p_expiry_information     OUT NOCOPY NUMBER);
-----------------------------------------------------------------------
-- For 115.19 Overloaded function to prevent loss of latest balances when
-- Balance Adjustments are performed */
PROCEDURE check_expiry(
            p_owner_payroll_action_id     IN    NUMBER,
            p_user_payroll_action_id      IN    NUMBER,
            p_owner_assignment_action_id  IN    NUMBER,
            p_user_assignment_action_id   IN    NUMBER,
            p_owner_effective_date        IN    DATE,
            p_user_effective_date         IN    DATE,
            p_dimension_name              IN    VARCHAR2,
            p_expiry_information          OUT NOCOPY DATE);
-----------------------------------------------------------------------
function ni_category_exists_in_year (p_assignment_action_id in number,
                                     p_category in varchar2)
RETURN number;
PRAGMA RESTRICT_REFERENCES(ni_category_exists_in_year, WNDS);
-----------------------------------------------------------------------
FUNCTION get_master_action_id(p_action_type IN VARCHAR2,
                              p_action_id   IN NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(get_master_action_id, WNDS);
-----------------------------------------------------------------------
END hr_gbbal;

/
