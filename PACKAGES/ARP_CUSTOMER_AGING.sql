--------------------------------------------------------
--  DDL for Package ARP_CUSTOMER_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CUSTOMER_AGING" AUTHID CURRENT_USER AS
/* $Header: ARCWAGES.pls 115.7 2002/11/15 02:30:24 anukumar ship $ */

PROCEDURE calc_aging_buckets (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_credit_option         IN VARCHAR2,
        p_invoice_type_low      IN VARCHAR2,
        p_invoice_type_high     IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_app_max_id            IN NUMBER DEFAULT 0,
        p_bucket_name           IN VARCHAR2,
	p_outstanding_balance	IN OUT NOCOPY NUMBER,
        p_bucket_titletop_0     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0  OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_1     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1  OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_2     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2  OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_3     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3  OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_4     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4  OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_5     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5  OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_6     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6  OUT NOCOPY VARCHAR2,
        p_bucket_amount_6       IN OUT NOCOPY NUMBER
);
--
PROCEDURE calc_credits (
        p_customer_id        	IN NUMBER,
        p_customer_site_use_id	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_credits            	OUT NOCOPY NUMBER
);
--
PROCEDURE calc_receipts (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_app_max_id            IN NUMBER DEFAULT 0,
        p_unapplied_cash        OUT NOCOPY NUMBER,
        p_onacct_cash           OUT NOCOPY NUMBER,
        p_cash_claims           OUT NOCOPY NUMBER,
        p_prepayments           OUT NOCOPY NUMBER
);
--
PROCEDURE calc_risk_receipts (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_risk_receipts         OUT NOCOPY NUMBER
);
--
PROCEDURE calc_dispute (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_dispute               OUT NOCOPY NUMBER
);
--
PROCEDURE calc_pending_adj (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_pending_adj           OUT NOCOPY NUMBER
);
--
END ARP_CUSTOMER_AGING;

 

/
