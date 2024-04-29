--------------------------------------------------------
--  DDL for Package IEX_COLL_IND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_COLL_IND_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpmtis.pls 120.0.12010000.3 2010/02/01 21:39:32 ehuh noship $ */
/*#
 * Public API for Metric functions.
 * @rep:scope internal
 * @rep:product IEX
 * @rep:displayname Public API for Metric functions
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/*#
 * Function GET_CREDIT_LIMIT.
 * @param p_party_id  party_id
 * @param p_cust_account_id  account_id
 * @param p_customer_site_use_id  site_use_id
 * @param p_org_id  org_id
 * @rep:scope internal
 * @rep:displayname GET_CREDIT_LIMIT
 * @rep:lifecycle active
 * @rep:compatibility S
 */

FUNCTION GET_CREDIT_LIMIT(p_party_id IN NUMBER,
                          p_cust_account_id IN NUMBER,
                          p_customer_site_use_id IN NUMBER,
                          p_org_id NUMBER) RETURN VARCHAR2;

/*#
 * Function GET_WTD_DAYS_TERMS.
 * @param p_party_id  party_id
 * @param p_cust_account_id  account_id
 * @param p_customer_site_use_id  site_use_id
 * @param p_org_id  org_id
 * @rep:scope internal
 * @rep:displayname WTD_DAYS_TERMS
 * @rep:lifecycle active
 * @rep:compatibility S
 */

FUNCTION GET_WTD_DAYS_TERMS(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER,
                     p_org_id NUMBER) RETURN VARCHAR2;

/*#
 * Function GET_WTD_DAYS_LATE.
 * @param p_party_id  party_id
 * @param p_cust_account_id  account_id
 * @param p_customer_site_use_id  site_use_id
 * @param p_org_id  org_id
 * @rep:scope internal
 * @rep:displayname GET_WTD_DAYS_LATE
 * @rep:lifecycle active
 * @rep:compatibility S
 */

FUNCTION GET_WTD_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER,
                     p_org_id NUMBER) RETURN VARCHAR2;

/*#
 * Function to get the real value of DSO.
 * @param p_party_id             party_id
 * @param p_cust_account_id      account_id
 * @param p_customer_site_use_id customer_site_use_id
 * @param p_org_id  org_id
 * @rep:scope internal
 * @rep:displayname GET_TRUE_DSO
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  FUNCTION GET_TRUE_DSO(p_party_id IN NUMBER,
                        p_cust_account_id IN NUMBER,
                        p_customer_site_use_id IN NUMBER,
                        p_org_id NUMBER) RETURN VARCHAR2;

/*#
 * Function to be used by GET_TRUE_DSO.
 * @param p_party_id             party_id
 * @param p_cust_account_id      account_id
 * @param p_customer_site_use_id customer_site_use_id
 * @rep:scope internal
 * @rep:displayname COMP_TOT_REC
 * @rep:lifecycle active
 * @rep:compatibility S
 */


  FUNCTION COMP_TOT_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER;


/*#
 * Procedure to get global variable values.
 * @param p_org_id   org_id
 * @rep:scope internal
 * @rep:displayname Get_Common
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  Procedure Get_Common(p_org_id number);


END;

/
