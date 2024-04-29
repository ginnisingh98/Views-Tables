--------------------------------------------------------
--  DDL for Package FV_TBAL_BY_TS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_TBAL_BY_TS" AUTHID CURRENT_USER AS
    /* $Header: FVTBTRSS.pls 120.1.12010000.1 2008/07/28 06:32:05 appldev ship $ */
PROCEDURE main  (errbuf  OUT NOCOPY     VARCHAR2,
                 retcode OUT NOCOPY     NUMBER,
                 p_ledger_id            NUMBER,
	         p_treasury_symbol_low  VARCHAR2,
		 p_treasury_symbol_high VARCHAR2,
		 p_period_name          VARCHAR2,
	         p_amount_type	        VARCHAR2,
		 p_currency_code        VARCHAR2,
                 p_report_id            NUMBER,
                 p_attribute_set        VARCHAR2,
                 p_output_format        VARCHAR2);

END fv_tbal_by_ts;

/
