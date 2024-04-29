--------------------------------------------------------
--  DDL for Package PA_AR_ADV_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AR_ADV_RECEIPT" AUTHID CURRENT_USER AS
--$Header: PAGARADS.pls 120.2 2006/12/20 09:07:58 rkchoudh noship $


PROCEDURE    Apply_receipt(
                           p_receipt_id         IN     NUMBER,
			   p_gl_date		IN     DATE,
                           p_agreement_id       IN     NUMBER,
                           p_agreement_number   IN     VARCHAR2,
                           x_payment_set_id     IN OUT NOCOPY   NUMBER,
                           x_return_status      IN OUT NOCOPY   VARCHAR2,
			   x_msg_count          IN OUT NOCOPY   NUMBER,
                           x_msg_data           IN OUT NOCOPY   VARCHAR2);


PROCEDURE    Unapply_receipt(
                           p_receipt_id         IN     NUMBER,
                           p_payment_set_id     IN     NUMBER,
                           x_return_status      IN OUT NOCOPY   VARCHAR2,
                           x_msg_count          IN OUT NOCOPY   NUMBER,
                           x_msg_data           IN OUT NOCOPY   VARCHAR2);

END PA_AR_ADV_RECEIPT;

/
