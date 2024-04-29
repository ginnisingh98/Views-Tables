--------------------------------------------------------
--  DDL for Package AR_RECEIPT_UPDATE_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RECEIPT_UPDATE_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARXPREUS.pls 120.5 2008/06/19 13:48:04 mpsingh noship $           */

	PROCEDURE update_receipt_unid_to_unapp (
-- Standard API parameters.
                 p_api_version       IN  NUMBER,
                 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                 p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2,
-- Receipt info. parameters
                 p_cash_receipt_id   IN NUMBER,
		 p_pay_from_customer IN NUMBER,
		 p_comments          IN VARCHAR2 DEFAULT NULL,
		 p_payment_trxn_extension_id  IN NUMBER DEFAULT NULL,
		 x_status	     OUT NOCOPY VARCHAR2,
 		 p_customer_bank_account_id    IN NUMBER DEFAULT NULL
		 );

   PROCEDURE Validate_id(p_customer_id        IN NUMBER,
              p_cash_receipt_id    IN NUMBER,
	      p_payment_trxn_extension_id  IN NUMBER,
	      p_customer_bank_account_id    IN NUMBER,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              x_return_status      OUT NOCOPY VARCHAR2,
	      x_crv_rec	           OUT NOCOPY ar_cash_receipts_v%ROWTYPE
            );
END;

/
