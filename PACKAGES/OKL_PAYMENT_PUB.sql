--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPAYS.pls 120.6 2007/09/07 12:29:36 nikshah noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Data Structures
  ----------------------------------------------------------------------------
  SUBTYPE receipt_rec_type IS OKL_PAYMENT_PVT.receipt_rec_type;
  SUBTYPE payment_tbl_type IS OKL_PAYMENT_PVT.payment_tbl_type;
  ---------------------------------------------------------------------------
  -- FUNCTION Get receipt Number
  ---------------------------------------------------------------------------
  FUNCTION get_ar_receipt_number(p_cash_receipt_id IN NUMBER)
  RETURN VARCHAR2;
  ---------------------------------------------------------------------------

  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_contract_id			        IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  );

  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_invoice_id			        IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  );

  PROCEDURE CREATE_PAYMENTS(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level             IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_receipt_rec                  IN  receipt_rec_type,
     p_payment_tbl                  IN  payment_tbl_type,
     x_payment_ref_number           OUT NOCOPY AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE,
     x_cash_receipt_id              OUT NOCOPY NUMBER
  );
END OKL_PAYMENT_PUB;

/
