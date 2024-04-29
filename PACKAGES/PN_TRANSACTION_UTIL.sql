--------------------------------------------------------
--  DDL for Package PN_TRANSACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_TRANSACTION_UTIL" AUTHID CURRENT_USER AS
  -- $Header: PNLEASETRXS.pls 120.0.12010000.12 2019/04/19 12:21:50 vbkumar noship $
  FUNCTION get_transaction_amount(p_transaction_id NUMBER) RETURN NUMBER;

  FUNCTION get_calc_regime_code(p_org_id IN NUMBER,
                                p_accounting_method VARCHAR2,
                                p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP) RETURN VARCHAR2 ;

  FUNCTION get_nth_period_end_date(p_date   DATE,
                                   p_org_id NUMBER,
                                   p_month NUMBER) RETURN DATE ;

  FUNCTION get_accounting_status(p_transaction_id NUMBER,
                                 p_application_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_lease_status(p_lease_status VARCHAR2) RETURN VARCHAR2;

  PROCEDURE get_default_info(x_org_id         OUT NOCOPY NUMBER,
                             x_operating_unit OUT NOCOPY VARCHAR2,
                             x_leader_id      OUT NOCOPY NUMBER,
                             x_leader_name    OUT NOCOPY VARCHAR2,
                             x_currency_code  OUT NOCOPY VARCHAR2);
  FUNCTION get_transition_date(p_org_id NUMBER) RETURN DATE;
  FUNCTION get_liability_more(p_lease_id         NUMBER,
                              p_org_id           NUMBER,
                              p_currency         VARCHAR2,
                              p_as_of_date       DATE,
                              p_termination_date DATE,
                              p_month            NUMBER,
                              p_mode             VARCHAR2) RETURN NUMBER;
  FUNCTION get_lease_liability(p_lease_id         NUMBER,
                               p_org_id           NUMBER,
                               p_currency         VARCHAR2,
                               p_as_of_date       DATE,
                               p_termination_date DATE,
                               p_month            NUMBER,
                               p_mode             VARCHAR2) RETURN NUMBER;
  FUNCTION get_change_date(p_lease_id   NUMBER,
                           p_as_of_date DATE,
                           p_type       VARCHAR2) RETURN DATE;
  FUNCTION get_transaction_ledger(p_regime_code       VARCHAR2,
                                  p_org_id            NUMBER,
                                  p_accounting_method VARCHAR2) RETURN NUMBER;
  FUNCTION get_duration(p_payment_term_proration_rule VARCHAR2,
                        p_start_date                  DATE,
                        p_end_date                    DATE) RETURN NUMBER;

FUNCTION get_eqp_transaction_ledger(p_regime_code       VARCHAR2,
                                  p_org_id            NUMBER,
                                  p_accounting_method VARCHAR2) RETURN NUMBER;

-- Added the below function for bug 29545538
  FUNCTION get_period_name(p_date   DATE,
                           p_org_id NUMBER,
                           p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP) RETURN VARCHAR2 ;
 /* Function added for 29185724 */
  FUNCTION get_accnting_event_status(p_event_id NUMBER) RETURN VARCHAR2;

END pn_transaction_util;

/
