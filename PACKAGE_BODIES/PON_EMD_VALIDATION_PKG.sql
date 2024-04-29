--------------------------------------------------------
--  DDL for Package Body PON_EMD_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_EMD_VALIDATION_PKG" AS
  /* $Header: PONEMDVB.pls 120.0.12010000.6 2012/12/10 11:09:50 sgulkota noship $ */
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     PONEMDVB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     Use this package to validation EMD transactions                   |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE validate_credit_card_num                               |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     01/15/2009 Allen Yang       Created                               |
  --|     04/01/2009  Lion Li       Add new  PROCEDURE getReceiptInfoOfTrx  |
  --+======================================================================*/
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    validate_credit_card_num                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is to validate if the credit card number is valid
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
  --           15-Jan-2009   Allen Yang  created
  --

  PROCEDURE validate_credit_card_num(p_api_version   IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     p_card_number   IN VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_version NUMBER := 1.0;
    l_api_name    VARCHAR2(50) := 'validate_credit_card_num';
    l_dbg_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_proc_level  NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_card_number iby_creditcard.ccnumber%TYPE := NULL;

    lx_return_status VARCHAR2(1) := NULL;
    lx_msg_count     NUMBER := NULL;
    lx_msg_data      VARCHAR2(200) := NULL;
    lx_cc_number     iby_creditcard.ccnumber%TYPE := NULL;
    lx_card_issuer   iby_creditcard.card_issuer_code%TYPE := NULL;
    lx_issuer_range  iby_creditcard.cc_issuer_range_id%TYPE := NULL;
    lx_card_prefix   iby_cc_issuer_ranges.card_number_prefix%TYPE := NULL;
    lx_digit_check   iby_creditcard_issuers_b.digit_check_flag%TYPE := NULL;

  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_prefix || '.' || l_api_name || '.begin',
                     'Enter procedure');
    END IF; --l_proc_level>=l_dbg_level

    -- initializilation of variables
    l_card_number   := p_card_number;
    x_return_status := FND_API.G_RET_STS_SUCCESS; -- 'S'

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       l_api_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize();
    END IF;

    -- Start credit card number validation
    IF (l_card_number IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR; -- 'E'
      RETURN;
    END IF;

    -- using the same logic as iby package to validate the format of CCNumber
    iby_cc_validate.StripCC(p_api_version,
                            FND_API.G_FALSE,
                            l_card_number,
                            lx_return_status,
                            lx_msg_count,
                            lx_msg_data,
                            lx_cc_number);

    IF ((lx_cc_number IS NULL) OR
       (lx_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR; -- 'E'
      RETURN;
    END IF;

    iby_cc_validate.Get_CC_Issuer_Range(lx_cc_number,
                                        lx_card_issuer,
                                        lx_issuer_range,
                                        lx_card_prefix,
                                        lx_digit_check);

    IF (lx_digit_check = 'Y') THEN
      IF (MOD(iby_cc_validate.CheckCCDigits(lx_cc_number), 10) <> 0) THEN
        x_return_status := FND_API.G_RET_STS_ERROR; -- 'E'
        RETURN;
      END IF; -- MOD(iby_cc_validate.CheckCCDigits(lx_cc_number),10) <> 0
    END IF; -- lx_digit_check = 'Y'

    --logging for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_prefix || '.' || l_api_name || '.end',
                     'Exit procedure');
    END IF; -- (l_proc_level>=l_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.Other_Exception ',
                       Sqlcode || Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  END validate_credit_card_num;
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
                                x_return_status     OUT NOCOPY VARCHAR2) IS
    l_api_name VARCHAR2(50) := 'getReceiptInfoOfTrx';
    l_dbg_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;

  BEGIN
  --logging for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_prefix || '.' || l_api_name || '.begin',
                     'Enter procedure');
    END IF; -- (l_proc_level>=l_dbg_level)

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT Max(acr.cash_receipt_id), Max(arp.receivable_application_id)
        INTO x_cash_receipt_id, x_receivable_app_id
        from ar_receivable_applications_all arp,
             ra_customer_trx_all            rct,
             ra_cust_trx_types_all          ctyp,
             ar_cash_receipts_all           acr
       where arp.applied_customer_trx_id = p_trx_id
         AND arp.org_id = p_org_id
         AND arp.status = 'APP'
         AND arp.applied_customer_trx_id = rct.customer_trx_id
         AND arp.org_id = rct.org_id
         AND rct.CUST_TRX_TYPE_ID = ctyp.CUST_TRX_TYPE_ID
         AND rct.org_id = ctyp.org_id
         AND ctyp.type = 'DEP'
         AND arp.cash_receipt_id = acr.cash_receipt_id
         AND arp.amount_applied > 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON', 'RECEIPT_NOT_CRE_FOR_DEPOSIT');
        FND_MESSAGE.SET_TOKEN('DEPOSIT_TRX_NUM', p_trx_number);
        FND_MSG_PUB.ADD;
        x_receipt_num     := NULL;
        x_cash_receipt_id := NULL;
        x_receipt_status  := NULL;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.NO_DATA_FOUND_Exception ',
                       Sqlcode || Sqlerrm);
        END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        RETURN;
      WHEN TOO_MANY_ROWS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.TOO_MANY_ROWS_Exception ',
                       Sqlcode || Sqlerrm);
        END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        RETURN;
    END;
    IF (x_cash_receipt_id IS NOT NULL) THEN
      BEGIN
        SELECT acr.receipt_number, ARPT_SQL_FUNC_UTIL.get_lookup_meaning('RECEIPT_CREATION_STATUS',
                                       acrh.STATUS),acrh.STATUS
          INTO x_receipt_num, x_receipt_status,x_receipt_status_code
          FROM ar_cash_Receipt_history_all acrh, ar_cash_receipts_all acr
         WHERE acrh.cash_receipt_id = acr.cash_receipt_id
           AND acrh.current_record_flag = 'Y'
           AND acr.cash_receipt_id = x_cash_receipt_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('PON', 'RECEIPT_NOT_CLEARED');
          FND_MESSAGE.SET_TOKEN('DEPOSIT_TRX_NUM', p_trx_number);
          FND_MESSAGE.SET_TOKEN('RECEIPT_NUM', x_receipt_num);
          FND_MSG_PUB.ADD;
          x_receipt_num     := NULL;
          x_cash_receipt_id := NULL;
          x_receipt_status  := NULL;
          x_receipt_status_code := NULL;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.NO_DATA_FOUND_Exception ',
                       Sqlcode || Sqlerrm);
          END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          RETURN;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.TOO_MANY_ROWS_Exception ',
                       Sqlcode || Sqlerrm);
          END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          RETURN;
      END;
    END IF;
  --logging for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_prefix || '.' || l_api_name || '.end',
                     'Exit procedure');
    END IF; -- (l_proc_level>=l_dbg_level)
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status   := FND_API.G_RET_STS_ERROR;
      x_receipt_num     := NULL;
      x_cash_receipt_id := NULL;
      x_receipt_status  := NULL;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.NO_DATA_FOUND_Exception ',
                       Sqlcode || Sqlerrm);
     END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    WHEN TOO_MANY_ROWS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || '.' || l_api_name ||
                       '.TOO_MANY_ROWS_Exception ',
                       Sqlcode || Sqlerrm);
      END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  END getReceiptInfoOfTrx;

PROCEDURE ADD_EMD_BIDDING_PARTY
(
L_AUCTION_HEADER_ID    IN NUMBER,
L_LIST_ID              IN NUMBER,
L_SEQUENCE             IN NUMBER,
L_TRADING_PARTNER_ID   IN NUMBER,
L_TRADING_PARTNER_NAME IN VARCHAR2,
L_VENDOR_SITE_ID       IN NUMBER
) IS
L_USER_ID NUMBER;
BEGIN


L_USER_ID:=FND_GLOBAL.USER_ID;

INSERT INTO PON_BIDDING_PARTIES
(
AUCTION_HEADER_ID,
LIST_ID,
SEQUENCE,
TRADING_PARTNER_NAME,
TRADING_PARTNER_ID,
VENDOR_SITE_ID,
VENDOR_SITE_CODE,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
ACCESS_TYPE,
FROM_EMD_FLAG
)
VALUES
(
L_AUCTION_HEADER_ID,
L_LIST_ID          ,
L_SEQUENCE         ,
L_TRADING_PARTNER_NAME,
L_TRADING_PARTNER_ID,
-1,
'-1',
SYSDATE,
L_USER_ID,
SYSDATE,
L_USER_ID,
'FULL',
'Y'
);
END;

FUNCTION get_user_name(P_USER_ID IN NUMBER ) RETURN VARCHAR2
IS

L_PERSON_FIRST_NAME HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
L_PERSON_MIDDLE_NAME HZ_PARTIES.PERSON_MIDDLE_NAME%TYPE;
L_PERSON_LAST_NAME HZ_PARTIES.PERSON_LAST_NAME%TYPE;
L_PERSON_PRE_NAME_ADJUNCT HZ_PARTIES.PERSON_PRE_NAME_ADJUNCT%TYPE;
L_PERSON_NAME_SUFFIX HZ_PARTIES.PERSON_NAME_SUFFIX%TYPE;
L_PARTY_ID NUMBER;

X_NAME VARCHAR2(1000);
BEGIN

SELECT PERSON_PARTY_ID INTI INTO L_PARTY_ID FROM FND_USER WHERE USER_ID=P_USER_ID;

SELECT
PERSON_FIRST_NAME,
PERSON_MIDDLE_NAME,
PERSON_LAST_NAME,
PERSON_PRE_NAME_ADJUNCT,
PERSON_NAME_SUFFIX
INTO
L_PERSON_FIRST_NAME,
L_PERSON_MIDDLE_NAME,
L_PERSON_LAST_NAME,
L_PERSON_PRE_NAME_ADJUNCT,
L_PERSON_NAME_SUFFIX
FROM
HZ_PARTIES
WHERE
PARTY_ID=L_PARTY_ID;

X_NAME:=PON_LOCALE_PKG.party_display_name (
  p_first_name	   => L_PERSON_FIRST_NAME
, p_last_name      => L_PERSON_LAST_NAME
, p_middle_name    => L_PERSON_MIDDLE_NAME
, p_prefix         => L_PERSON_PRE_NAME_ADJUNCT
, p_suffix         => L_PERSON_NAME_SUFFIX
, p_language       => UserEnv('LANG')
, p_party_id       => L_PARTY_ID);

RETURN X_NAME;

END;



END PON_EMD_VALIDATION_PKG;

/
