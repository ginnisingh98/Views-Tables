--------------------------------------------------------
--  DDL for Package AR_CMGT_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_AGING" AUTHID CURRENT_USER AS
/* $Header: ARCMAGES.pls 115.4 2003/06/21 01:54:50 msenthil noship $ */

PROCEDURE calc_aging_buckets (
        p_party_id              IN NUMBER,
        p_customer_id           IN NUMBER,
        p_site_use_id           IN NUMBER,
        p_currency_code         IN VARCHAR2,
        p_credit_option         IN VARCHAR2,
        p_bucket_name           IN VARCHAR2,
        p_org_id                IN NUMBER,
        p_exchange_rate_type    IN VARCHAR2,
        p_source                IN VARCHAR2 default NULL,
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

END AR_CMGT_AGING;

 

/
