--------------------------------------------------------
--  DDL for Package IEX_TRX_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TRX_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: iexttvws.pls 120.2 2004/10/14 13:49:33 jypark ship $ */
TYPE postQueryRecType IS RECORD
(
  customer_trx_id NUMBER,
  payment_schedule_id NUMBER,
  delinquency_id NUMBER,
  promised_flag VARCHAR2(100),
  paid_flag VARCHAR2(100),
  sales_order VARCHAR2(50),
  trx_score NUMBER,
  strategy_name VARCHAR2(240)
);

TYPE postQueryTabType IS TABLE OF postQueryRecType INDEX BY BINARY_INTEGER;

FUNCTION is_paid(p_payment_schedule_id NUMBER) RETURN NUMBER;
FUNCTION is_promised(p_delinquency_id NUMBER) RETURN NUMBER;
FUNCTION get_sales_order(p_customer_trx_id NUMBER) RETURN VARCHAR2;
FUNCTION get_score(p_payment_schedule_id NUMBER) RETURN NUMBER;
FUNCTION get_strategy_name(p_delinquency_id NUMBER) RETURN VARCHAR2;

-- clchang added 11/11/2002
-- for IEX_DUNNINGS_ACCT_BALI_V
FUNCTION get_party_id(p_account_id NUMBER) RETURN NUMBER;

PROCEDURE post_query_trx(p_trx_tab IN OUT NOCOPY postQueryTabType, p_type IN VARCHAR2);

END;

 

/
