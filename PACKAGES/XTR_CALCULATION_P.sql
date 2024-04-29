--------------------------------------------------------
--  DDL for Package XTR_CALCULATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CALCULATION_P" AUTHID CURRENT_USER AS
/* $Header: xtrprc2s.pls 120.2 2005/06/29 10:37:07 rjose ship $ */
--
-- Stored procedures/functions
--
PROCEDURE CALC_OPTION_PRICES(time_in_days IN NUMBER,
                             int_rate IN NUMBER,
                             market_price IN NUMBER,
                             strike_price IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER);


PROCEDURE CALC_FX_OPTION_PRICES(
                             l_days         IN NUMBER,
                             l_base_int_rate IN NUMBER,
                             l_contra_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER,
                             l_fwd_rate IN OUT NOCOPY NUMBER  );

PROCEDURE CALC_RTM_ROLLOVER(
				errbuf                  OUT NOCOPY VARCHAR2,
                        retcode                 OUT NOCOPY NUMBER,
                        P_DEAL_SUBTYPE          IN VARCHAR2,
                        P_PRODUCT_TYPE          IN VARCHAR2,
                        P_PAYMENT_SCHEDULE_CODE IN VARCHAR2);

PROCEDURE EXTEND_RTM_ROLLOVER(
				errbuf                	OUT NOCOPY VARCHAR2,
                        retcode                 OUT NOCOPY NUMBER,
                        P_DEAL_SUBTYPE          IN VARCHAR2,
                        P_PRODUCT_TYPE          IN VARCHAR2,
                        P_PAYMENT_SCHEDULE_CODE IN VARCHAR2);


END XTR_CALCULATION_P;

 

/
