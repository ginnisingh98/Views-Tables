--------------------------------------------------------
--  DDL for Package PON_EMD_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_EMD_VALIDATION_PKG" AUTHID CURRENT_USER AS
  /* $Header: PONEMDVS.pls 120.0.12010000.5 2009/07/30 08:24:16 puppulur noship $ */
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     PONEMDVS.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     PL/SQL spec for package:  PON_EMD_VALIDATION_PKG                  |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE validate_credit_card_num                               |
  --|                                                                       |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     01/15/2009  Allen Yang       Created
  --|     04/01/2009  Lion Li       Add new  PROCEDURE getReceiptInfoOfTrx  |
  --+======================================================================*/
  -- Declare global variable for package name
  g_fnd_debug     CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),
                                              'N');
  g_pkg_name      CONSTANT VARCHAR2(50) := 'PON_EMD_VALIDATION_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

  -- Declare global constants
  GV_TRUE CONSTANT VARCHAR2(1) := 'T';

  -- Constant for invalid credit card number
  G_RC_INVALID_CCNUMBER CONSTANT VARCHAR2(50) := 'INVALID_CARD_NUMBER';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    validate_credit_card_num                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is to to validate if the credit card number is valid
  --
  --  PARAMETERS:
  --      In:  p_api_version                 API Version
  --           p_init_msg_list               Whether to initialize message list
  --           p_card_number                 Credit Card Number
  --
  --     Out:  x_return_status               Returned flag to show if CCNumber is valid
  --
  --
  --  DESIGN REFERENCES:
  --    EMD_TECHNICAL_DESIGN_ALLEN.doc
  --
  --  CHANGE HISTORY:
  --
  --          15-Jan-2009   Allen Yang  created

  PROCEDURE validate_credit_card_num(p_api_version   IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     p_card_number   IN VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2);
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    getReceiptInfoOfTrx                       Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is to to get the receipt information of transaction
  --
  --  PARAMETERS:
  --      In:  p_trx_id                 Transaction id
  --           p_trx_number             Transaction number
  --           p_org_id                 Org id
  --
  --     Out:  x_return_status               Returned flag to show if has receipt information of this transaction
  --           x_receipt_num                 Returned receipt number of this transacton
  --           x_cash_receipt_id             Returned cash receipt id of this transacton
  --           x_receivable_app_id           Returned receivable app id of this transaction
  --           x_receipt_status              Returned receipt status of this transaction
  --  DESIGN REFERENCES:
  --    EMD_TECHNICAL_DESIGN_ALLEN.doc
  --
  --  CHANGE HISTORY:
  --
  --     01-Apr-2009   Lion Li  created

PROCEDURE getReceiptInfoOfTrx(p_trx_id            IN NUMBER,
                                p_trx_number        IN VARCHAR2,
                                p_org_id            IN NUMBER,
                                x_receipt_num       OUT NOCOPY VARCHAR2,
                                x_cash_receipt_id   OUT NOCOPY NUMBER,
                                x_receivable_app_id OUT NOCOPY NUMBER,
                                x_receipt_status    OUT NOCOPY VARCHAR2,
                                x_receipt_status_code OUT NOCOPY VARCHAR2,
                                x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE ADD_EMD_BIDDING_PARTY
(
L_AUCTION_HEADER_ID    IN NUMBER,
L_LIST_ID              IN NUMBER,
L_SEQUENCE             IN NUMBER,
L_TRADING_PARTNER_ID   IN NUMBER,
L_TRADING_PARTNER_NAME IN VARCHAR2,
L_VENDOR_SITE_ID       IN NUMBER
);

FUNCTION get_user_name(P_USER_ID IN NUMBER ) RETURN VARCHAR2;

END PON_EMD_VALIDATION_PKG;


/
