--------------------------------------------------------
--  DDL for Package XTR_CASHPOOL_UTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CASHPOOL_UTLS" AUTHID CURRENT_USER as
/* $Header: xtrpools.pls 120.0.12010000.2 2008/08/06 10:43:59 srsampat ship $ */

PROCEDURE INSERT_IAC_CASHPOOL (p_cashpool_id 	NUMBER,
			       p_party_code	VARCHAR2,
			       p_iac_portfolio  VARCHAR2,
			       p_iac_product_type VARCHAR2);

PROCEDURE INSERT_IG_CASHPOOL (p_cashpool_id    NUMBER,
                              p_portfolio  VARCHAR2,
                              p_product_type VARCHAR2,
			      p_rounding_type VARCHAR2,
			      p_day_count_type VARCHAR2,
			      p_pricing_model  VARCHAR2,
		              p_fund_limit	VARCHAR2,
			      p_invest_limit	VARCHAR2,
			      p_party_code	VARCHAR2,
			      p_party_portfolio VARCHAR2,
			      p_party_product_type	VARCHAR2,
			      p_party_pricing_model	VARCHAR2,
			      p_party_fund_limit	VARCHAR2,
			      p_party_invest_limit	VARCHAR2);

PROCEDURE UPDATE_IAC_CASHPOOL (p_cashpool_id    NUMBER,
                               p_iac_portfolio  VARCHAR2,
                               p_iac_product_type VARCHAR2);

PROCEDURE UPDATE_IG_CASHPOOL (p_cashpool_id    NUMBER,
                              p_portfolio  VARCHAR2,
                              p_product_type VARCHAR2,
                              p_rounding_type VARCHAR2,
                              p_day_count_type VARCHAR2,
                              p_pricing_model  VARCHAR2,
                              p_fund_limit      VARCHAR2,
                              p_invest_limit    VARCHAR2,
                              p_party_code      VARCHAR2,
                              p_party_portfolio VARCHAR2,
                              p_party_product_type      VARCHAR2,
                              p_party_pricing_model     VARCHAR2,
                              p_party_fund_limit        VARCHAR2,
                              p_party_invest_limit      VARCHAR2);

PROCEDURE UPDATE_IG_ROW_CASHPOOL (p_cashpool_id    NUMBER,
                              p_fund_limit      VARCHAR2,
                              p_invest_limit    VARCHAR2,
                              p_party_code      VARCHAR2,
                              p_party_portfolio VARCHAR2,
                              p_party_product_type      VARCHAR2,
                              p_party_pricing_model     VARCHAR2,
                              p_party_fund_limit        VARCHAR2,
                              p_party_invest_limit      VARCHAR2);

PROCEDURE DELETE_XTR_CASHPOOL (p_cashpool_id NUMBER,
			       p_party_code VARCHAR2);

PROCEDURE DEFAULT_IAC_IG_ATTRIBUTES (p_company_code NUMBER,
                                     x_iac_portfolio OUT NOCOPY VARCHAR2,
                                     x_iac_product_type OUT NOCOPY VARCHAR2,
                                     x_portfolio OUT NOCOPY VARCHAR2,
                                     x_product_type OUT NOCOPY VARCHAR2,
                                     x_rounding_type OUT NOCOPY VARCHAR2,
                                     x_day_count_type OUT NOCOPY VARCHAR2,
                                     x_pricing_model OUT NOCOPY VARCHAR2);
END XTR_CASHPOOL_UTLS;

/
