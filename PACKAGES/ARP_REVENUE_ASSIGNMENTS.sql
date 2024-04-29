--------------------------------------------------------
--  DDL for Package ARP_REVENUE_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_REVENUE_ASSIGNMENTS" AUTHID CURRENT_USER AS
/* $Header: ARREVUS.pls 120.2.12010000.2 2009/02/24 19:47:57 mraymond ship $ */

/* ==================================================================================
 | PROCEDURE build_for_credit
 |
 | DESCRIPTION
 |   This procedure populates ar_revenue_assignments_gt (a global temporary
 |   table) with rows from ar_revenue_assignments (the view).  In 11i apps,
 |   the CBO seems to have a lot of trouble with any sql containing this
 |   view.  So this is an effort to offload that work to a separate
 |   sql step.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_session_id         IN      session id from calling program
 |      p_period_set_name    IN      Period set name
 |      p_use_inv_acctg      IN      Profile for 'AR: Use Invoice Accounting for CM'
 |      p_request_id         IN      request_id (if coming from RAXTRX)
 |      p_customer_trx_id    IN      customer_trx_id
 |      p_customer_trx_line_id IN    customer_trx_line_id
 |
 *===================================================================================*/
   PROCEDURE build_for_credit(
      p_session_id         IN     NUMBER,
      p_period_set_name    IN     gl_periods.period_set_name%TYPE,
      p_use_inv_acctg      IN     varchar2,
      p_request_id         IN     ra_customer_trx_all.request_id%TYPE,
      p_customer_trx_id    IN     ra_customer_trx_all.customer_trx_id%TYPE,
      p_customer_trx_line_id  IN  ra_customer_trx_lines_all.customer_trx_line_id%TYPE
      );

END arp_revenue_assignments;

/
