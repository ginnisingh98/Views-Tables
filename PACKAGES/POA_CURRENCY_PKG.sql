--------------------------------------------------------
--  DDL for Package POA_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_CURRENCY_PKG" AUTHID CURRENT_USER AS
/* $Header: POACURS.pls 120.0 2005/06/01 13:41:54 appldev noship $ */

g_missing_cur BOOLEAN := FALSE;


  FUNCTION get_global_currency RETURN VARCHAR2;

  FUNCTION get_global_rate (x_trx_currency_code     VARCHAR2,
                          x_exchange_date         DATE,
                          x_exchange_rate_type    VARCHAR2 DEFAULT NULL)
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_global_rate, WNDS);

  FUNCTION get_global_currency_rate (p_rate_type      VARCHAR2,
                                     p_currency_code  VARCHAR2,
                                     p_rate_date      DATE,
                                     p_rate           NUMBER)  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_global_currency_rate, WNDS);

-- Added p_global_cur_type parameter for Secondary Global Currency
  FUNCTION get_display_currency(p_currency_code                IN VARCHAR2,
                                p_selected_operating_unit      IN VARCHAR2,
                                p_global_cur_type              IN VARCHAR2
                                                                    DEFAULT 'P'
                                ) RETURN VARCHAR2;

  FUNCTION get_dbi_global_rate (p_rate_type VARCHAR2,
				p_currency_code VARCHAR2,
				p_rate_date DATE,
                                p_txn_cur_code VARCHAR2) RETURN NUMBER parallel_enable;

  FUNCTION get_dbi_sglobal_rate (p_rate_type VARCHAR2,
				p_currency_code VARCHAR2,
				p_rate_date DATE,
                                p_txn_cur_code VARCHAR2) RETURN NUMBER parallel_enable;

-- Functions for Secondary Global Currency
  FUNCTION get_secondary_global_currency RETURN VARCHAR2;

  FUNCTION display_secondary_currency_yn RETURN BOOLEAN;

END POA_CURRENCY_PKG;

 

/
