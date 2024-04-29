--------------------------------------------------------
--  DDL for Package PA_AR_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AR_TRX_PURGE" AUTHID CURRENT_USER AS
-- $Header: PAXARPGS.pls 115.1 2002/07/22 04:30:29 mumohan ship $

  FUNCTION transaction_flex_context RETURN VARCHAR2;
  -- This function returns the context value for the transaction flex for PA
  -- If PA is not setup, it will return NULL.
  -- It should not be called if PA is not installed. If it is called it will
  -- return an error message.

  FUNCTION purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN;
  -- If this function returns TRUE, the purge should be allowed.
  -- False if the purge should not be allowed.

  FUNCTION client_purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN;
  -- The client can write this function to return TRUE (allow purge) or FALSE
  -- (prevent purge). The function template supplied with the Product returns
  -- FALSE.

END pa_ar_trx_purge;

 

/
