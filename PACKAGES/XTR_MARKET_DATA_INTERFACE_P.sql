--------------------------------------------------------
--  DDL for Package XTR_MARKET_DATA_INTERFACE_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_MARKET_DATA_INTERFACE_P" AUTHID CURRENT_USER AS
/*  $Header: xtrmdtrs.pls 120.2 2005/06/29 10:47:57 badiredd ship $  */
PROCEDURE archive_rates(p_called_from_trigger	IN	BOOLEAN,
			p_ask_price		IN	NUMBER,
			p_bid_price		IN	NUMBER,
			p_currency_a		IN	VARCHAR2,
			p_currency_b		IN	VARCHAR2,
			p_nos_of_days		IN	NUMBER,
			p_ric_code		IN	VARCHAR2,
			p_term_length		IN	NUMBER,
			p_term_type		IN	VARCHAR2,
			p_term_year		IN	NUMBER,
			p_last_download_time	IN	DATE,
			p_day_count_basis	IN	VARCHAR2);

PROCEDURE transfer_mp(p_ref IN NUMBER,p_ask IN NUMBER, p_bid IN NUMBER,
                      p_rowid IN ROWID );

PROCEDURE calc_ask_bid(p_ref IN NUMBER, p_ask IN OUT NOCOPY NUMBER,
                       p_bid IN OUT NOCOPY NUMBER,p_mid IN NUMBER, p_spread IN NUMBER,                       p_code IN NUMBER);

FUNCTION q_quote_compare(p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2,p_ask IN OUT NOCOPY NUMBER, p_bid IN OUT NOCOPY NUMBER,
  p_mid IN NUMBER, p_spread IN NUMBER, p_code IN NUMBER) RETURN BOOLEAN;

FUNCTION q_code_check(p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2) RETURN BOOLEAN;

FUNCTION q_date_check(p_date IN DATE, p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE put_header;

PROCEDURE market_data_transfer_cp(
errbuf                  OUT NOCOPY     VARCHAR2,
retcode                 OUT NOCOPY     VARCHAR2,
p_upd_date_missing  IN VARCHAR2,
p_upd_history  IN VARCHAR2);

PROCEDURE upload_rates_to_gl_cp(errbuf		OUT NOCOPY	VARCHAR2,
				retcode		OUT NOCOPY	VARCHAR2,
				p_rel_abs	IN		VARCHAR2,
				p_abs_start_date	IN	VARCHAR2,
				p_abs_end_date	IN		VARCHAR2,
				p_rel_end_date	IN		NUMBER,
				p_rel_start_date	IN	NUMBER,
				p_rate_calc	IN		VARCHAR2,
				p_bid_mid_ask	IN		VARCHAR2,
				p_conv_type	IN		VARCHAR2,
				p_overwrite	IN		VARCHAR2);

--------------------------------------------------------------------------------------------------------------------
PROCEDURE market_data_transfer (p_upd_date_missing  IN VARCHAR2,
                               p_upd_history  IN VARCHAR2);
--------------------------------------------------------------------------------------------------------------------
END xtr_market_data_interface_p;

 

/
