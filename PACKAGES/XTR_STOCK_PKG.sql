--------------------------------------------------------
--  DDL for Package XTR_STOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_STOCK_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrstcks.pls 120.3.12010000.2 2008/08/06 10:45:07 srsampat ship $ */

  PROCEDURE INS_STOCK_DDA (p_deal_no IN NUMBER,
			   p_reverse_dda IN BOOLEAN DEFAULT NULL);

  PROCEDURE CANCEL_STOCK (p_deal_no IN NUMBER,
			  p_deal_subtype IN VARCHAR2,
			  p_currency IN VARCHAR2);

/*============================================================================*/
/*===================  BEGIN CASH DIVIDEND PROCEDURES  =======================*/
/*============================================================================*/

  FUNCTION  INVALID_DIV_DATE (p_declare_date IN DATE,
                              p_record_date  IN DATE,
                              p_payment_date IN DATE) return BOOLEAN;

  FUNCTION  UNIQUE_STOCK_DIV_EXIST(p_stock_issue  IN VARCHAR2,
                                   p_declare_date IN DATE,
                                   p_record_date  IN DATE,
                                   p_payment_date IN DATE) return BOOLEAN;

  /* Bug 3737048 Overloaded Function to check for uniqueness during update. */

  FUNCTION  UNIQUE_STOCK_DIV_EXIST(p_cash_dividend_id IN NUMBER,
				   p_stock_issue  IN VARCHAR2,
                                   p_declare_date IN DATE,
                                   p_record_date  IN DATE) return BOOLEAN;

  FUNCTION  DISABLE_DELETE (p_div_id  IN NUMBER) return BOOLEAN;

  FUNCTION  GENERATE_CNT(p_div_id         IN  NUMBER,
                         p_stock_issue    IN  VARCHAR2,
                         p_declare_date   IN  DATE,
                         p_record_date    IN  DATE,
                         p_payment_date   IN  DATE,
                         p_div_per_share  IN  NUMBER) return NUMBER;

  PROCEDURE GENERATE_DIV(p_div_id         IN  NUMBER,
                         p_stock_issue    IN  VARCHAR2,
                         p_currency       IN  VARCHAR2,
                         p_declare_date   IN  DATE,
                         p_record_date    IN  DATE,
                         p_payment_date   IN  DATE,
                         p_div_per_share  IN  NUMBER,
                         p_sys_user       IN  VARCHAR2,
                         p_sys_date       IN  DATE,
                         p_deal_no        IN  NUMBER DEFAULT NULL,
			 p_reverse	  IN  VARCHAR2 DEFAULT NULL);

  /* Bug 3737048 Added the last argument to GENERATE_DIV procedure. */

  FUNCTION  DELETE_CNT  (p_div_id         IN  NUMBER) return NUMBER;

  FUNCTION  DELETE_DIV  (p_div_id         IN  NUMBER) return BOOLEAN;

/*============================================================================*/
/*=====================  END CASH DIVIDEND PROCEDURES  =======================*/
/*============================================================================*/


END XTR_STOCK_PKG;

/
