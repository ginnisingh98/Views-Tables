--------------------------------------------------------
--  DDL for Package XTR_FPS3_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FPS3_P" AUTHID CURRENT_USER as
/* $Header: xtrfps3s.pls 120.5 2005/06/29 07:53:34 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE CHK_DEAL_SUBTYPE (l_deal_type       IN VARCHAR2,
                            l_deal_subtype    IN VARCHAR2,
                            l_subtype_name    IN OUT NOCOPY VARCHAR2,
                            l_limit_weighting IN OUT NOCOPY NUMBER,
                            l_tolerance       IN OUT NOCOPY NUMBER,
                            l_err_code         OUT NOCOPY NUMBER,
                            l_level                OUT NOCOPY VARCHAR2);
PROCEDURE IMPORT_GL_HOLIDAYS(p_calendar_in     IN gl_transaction_calendar.name%TYPE,
                             p_currency_in     IN xtr_holidays.currency%TYPE);
PROCEDURE CHK_HOLIDAY (in_date    IN DATE,
                       l_currency IN VARCHAR2,
                       l_err_code OUT NOCOPY NUMBER,
                       l_level    OUT NOCOPY VARCHAR2);
PROCEDURE CHK_NO_PORTFOLIOS (l_company_code IN VARCHAR2,
                             l_deal_number  IN NUMBER,
                             l_err_code     OUT NOCOPY NUMBER,
                             l_level        OUT NOCOPY VARCHAR2);
PROCEDURE CHK_PORT_CODE (l_portfolio_code IN VARCHAR2,
                         l_company_code   IN VARCHAR2,
                         l_portfolio_name IN OUT NOCOPY VARCHAR2,
                         l_err_code       OUT NOCOPY NUMBER,
                         l_level          OUT NOCOPY VARCHAR2);
PROCEDURE CHK_PORT_CONST ( l_portfolio_code IN VARCHAR2,
                           l_deal_number    IN NUMBER,
                           l_err_code       OUT NOCOPY NUMBER,
                           l_level          OUT NOCOPY VARCHAR2);
PROCEDURE CHK_PRINCIPAL_BANK (l_company_code IN VARCHAR2,
                              l_currency     IN VARCHAR2,
                              l_prin_adjust  IN NUMBER,
                              l_prin_acct    IN VARCHAR2,
                              l_err_code     OUT NOCOPY NUMBER,
                              l_level        OUT NOCOPY VARCHAR2);
PROCEDURE CHK_PRINTER_NAME(l_p_name   IN VARCHAR2,
                           l_p_value  IN OUT NOCOPY VARCHAR2,
                           l_err_code OUT NOCOPY NUMBER,
                           l_level    OUT NOCOPY VARCHAR2);
PROCEDURE CHK_ROLLOVER (l_deal_number IN NUMBER,
                        l_start_date  IN DATE,
                        l_err_code    OUT NOCOPY NUMBER,
                        l_level       OUT NOCOPY VARCHAR2);
PROCEDURE CHK_STATUS_CODE (l_status_code         IN VARCHAR2,
                           l_deal_type           IN VARCHAR2,
                           l_record_status       IN VARCHAR2,
                           l_status_name         IN OUT NOCOPY VARCHAR2,
                           l_statcode_updateable IN OUT NOCOPY VARCHAR2,
                           l_err_code         OUT NOCOPY NUMBER,
                           l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_FX_TOLERANCE (l_rate       IN NUMBER,
                            l_currency_a IN VARCHAR2,
                            l_currency_b IN VARCHAR2,
                            l_tolerance  IN NUMBER,
                            l_err_code   OUT NOCOPY NUMBER,
                            l_level OUT NOCOPY  VARCHAR2);
PROCEDURE CHK_TOLERANCE (l_rate       IN NUMBER,
                         l_currency   IN VARCHAR2,
                         l_tolerance  IN NUMBER,
                         l_period     IN NUMBER,
                         l_unique_id  IN VARCHAR2,
                         l_err_code   OUT NOCOPY NUMBER,
                         l_level      OUT NOCOPY VARCHAR2);
PROCEDURE CHK_TIME_RESTRICTIONS (l_deal_type       IN VARCHAR2,
                                 l_deal_subtype    IN VARCHAR2,
                                 l_product_type    IN VARCHAR2,
                                 l_cparty_code     IN VARCHAR2,
                                 l_date            IN DATE,
                                 l_max_date        OUT NOCOPY DATE,
                                 l_err_code        OUT NOCOPY NUMBER,
                                 l_level           OUT NOCOPY VARCHAR2);

--start bug 2804548
FUNCTION previous_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE;

FUNCTION following_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE;

FUNCTION mod_following_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE;

FUNCTION mod_previous_bus_day(p_date IN DATE,
			p_ccy IN VARCHAR2) RETURN DATE;

TYPE settlementbasis_out_rec is record (date_out DATE);
TYPE settlementbasis_in_rec is record  (date_in DATE,
			settlement_basis xtr_bond_issues.settlement_basis%TYPE,
			ccy xtr_bond_issues.currency%TYPE);
PROCEDURE settlement_basis_calc(p_in_rec  IN settlementbasis_in_rec,
		       p_out_rec IN OUT NOCOPY settlementbasis_out_rec);

TYPE validation_out_rec is record (yes BOOLEAN);
TYPE validation_in_rec is record (deal_type xtr_deal_types.deal_type%TYPE,
			bond_issue_code xtr_bond_issues.bond_issue_code%TYPE,
			bond_coupon_date DATE);

PROCEDURE settled_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec);


PROCEDURE journaled_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec);


PROCEDURE reconciled_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec);


PROCEDURE accrued_validation(p_in_rec  IN validation_in_rec,
		       p_out_rec IN OUT NOCOPY validation_out_rec);

--end bug 2804548
----------------------------------------------------------------------------------------------------------------
end XTR_FPS3_P;

 

/
