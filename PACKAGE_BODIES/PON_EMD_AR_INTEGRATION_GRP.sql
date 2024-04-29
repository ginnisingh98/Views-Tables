--------------------------------------------------------
--  DDL for Package Body PON_EMD_AR_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_EMD_AR_INTEGRATION_GRP" AS
/* $Header: PONGARIB.pls 120.0.12010000.27 2012/11/22 10:13:28 sgulkota noship $ */

-----------------------------------------------------------------------
--Start of Comments
--Name: create_emd_deposit
--Description : Warpper on AR APIs to create emd deposit
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE create_emd_deposit
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         DEPOSIT_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY DEPOSIT_INFO_OUT_RECTYPE
  ) IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'create_emd_deposit';
  l_progress                        NUMBER;
  l_deposit_number                  ra_customer_trx.trx_number%TYPE  := NULL;
  l_deposit_date                    ra_customer_trx.trx_date%TYPE := NULL;
  l_currency_code                   ra_customer_trx.invoice_currency_code%TYPE := NULL;
  l_usr_currency_code               ra_customer_trx.invoice_currency_code%TYPE := NULL;
  l_exchange_rate_type              ra_customer_trx.exchange_rate_type%TYPE := NULL;
  l_usr_exchange_rate_type          ra_customer_trx.exchange_rate_type%TYPE := NULL;
  l_exchange_rate                   ra_customer_trx.exchange_rate%TYPE := NULL;
  l_exchange_date                   ra_customer_trx.exchange_date%TYPE := NULL;
  l_gl_date                         DATE := NULL;
  l_bill_to_customer_id             ra_customer_trx.bill_to_customer_id%TYPE := NULL;
  l_bill_to_customer_name           hz_parties.party_name%TYPE := NULL;
  l_bill_to_customer_number         hz_cust_accounts.account_number%TYPE := NULL;
  l_bill_to_location                hz_cust_site_uses.location%TYPE := NULL;
  l_bill_to_site_use_id             ra_customer_trx.bill_to_site_use_id%TYPE := NULL;
  l_bill_to_contact_id              ra_customer_trx.bill_to_contact_id%TYPE := NULL;
  l_bill_to_contact_first_name      hz_parties.person_first_name%TYPE := NULL;
  l_bill_to_contact_last_name       hz_parties.person_last_name%TYPE := NULL;
  l_ship_to_customer_id             ra_customer_trx.ship_to_customer_id%TYPE := NULL;
  l_ship_to_customer_name           hz_parties.party_name%TYPE := NULL;
  l_ship_to_customer_number         hz_cust_accounts.account_number%TYPE := NULL;
  l_ship_to_location                hz_cust_site_uses.location%TYPE := NULL;
  l_ship_to_site_use_id             ra_customer_trx.ship_to_site_use_id%TYPE := NULL;
  l_ship_to_contact_id              ra_customer_trx.ship_to_contact_id%TYPE := NULL;
  l_ship_to_contact_first_name      hz_parties.person_first_name%TYPE := NULL;
  l_ship_to_contact_last_name       hz_parties.person_last_name%TYPE := NULL;
  l_term_id                         ra_terms.term_id%TYPE := NULL;
  l_salesrep_id                     ra_salesreps.salesrep_id%TYPE := NULL;
  l_term_name                       ra_terms.name%TYPE := NULL;
  l_salesrep_name                   ra_salesreps.NAME%TYPE := NULL;
  l_interface_header_context        VARCHAR2(30) := NULL;
  l_interface_header_attribute1     VARCHAR2(150) := NULL;
  l_interface_header_attribute2     VARCHAR2(150) := NULL;
  l_interface_header_attribute3     VARCHAR2(150) := NULL;
  l_interface_header_attribute4     VARCHAR2(150) := NULL;
  l_interface_header_attribute5     VARCHAR2(150) := NULL;
  l_interface_header_attribute6     VARCHAR2(150) := NULL;
  l_interface_header_attribute7     VARCHAR2(150) := NULL;
  l_interface_header_attribute8     VARCHAR2(150) := NULL;
  l_interface_header_attribute9     VARCHAR2(150) := NULL;
  l_interface_header_attribute10    VARCHAR2(150) := NULL;
  l_interface_header_attribute11    VARCHAR2(150) := NULL;
  l_interface_header_attribute12    VARCHAR2(150) := NULL;
  l_interface_header_attribute13    VARCHAR2(150) := NULL;
  l_interface_header_attribute14    VARCHAR2(150) := NULL;
  l_interface_header_attribute15    VARCHAR2(150) := NULL;
  l_attribute_category              VARCHAR2(30) := NULL;
  l_attribute1                      VARCHAR2(150) := NULL;
  l_attribute2                      VARCHAR2(150) := NULL;
  l_attribute3                      VARCHAR2(150) := NULL;
  l_attribute4                      VARCHAR2(150) := NULL;
  l_attribute5                      VARCHAR2(150) := NULL;
  l_attribute6                      VARCHAR2(150) := NULL;
  l_attribute7                      VARCHAR2(150) := NULL;
  l_attribute8                      VARCHAR2(150) := NULL;
  l_attribute9                      VARCHAR2(150) := NULL;
  l_attribute10                     VARCHAR2(150) := NULL;
  l_attribute11                     VARCHAR2(150) := NULL;
  l_attribute12                     VARCHAR2(150) := NULL;
  l_attribute13                     VARCHAR2(150) := NULL;
  l_attribute14                     VARCHAR2(150) := NULL;
  l_attribute15                     VARCHAR2(150) := NULL;
  l_global_attr_cust_rec            ar_deposit_api_pub.global_attr_rec_type := NULL;
  l_document_number                 ra_customer_trx.doc_sequence_value%TYPE := NULL;
  l_ussgl_transaction_code          ra_customer_trx.default_ussgl_transaction_code%TYPE := NULL;
  l_printing_option                 ra_customer_trx.printing_option%TYPE := NULL;
  l_default_tax_exempt_flag         ra_customer_trx.default_tax_exempt_flag%TYPE := NULL;
  l_status_trx                      ra_customer_trx.status_trx%TYPE := NULL;
  l_financial_charges               ra_customer_trx.finance_charges%TYPE := NULL;
  l_agreement_id                    ra_customer_trx.agreement_id%TYPE := NULL;
  l_special_instructions            ra_customer_trx.special_instructions%TYPE := NULL;
  l_comments                        ra_customer_trx.comments%TYPE := NULL;
  l_purchase_order                  ra_customer_trx.purchase_order%TYPE := NULL;
  l_purchase_order_revision         ra_customer_trx.purchase_order_revision%TYPE := NULL;
  l_purchase_order_date             ra_customer_trx.purchase_order_date%TYPE := NULL;
  l_remit_to_address_id             ra_customer_trx.remit_to_address_id%TYPE := NULL;
  l_sold_to_customer_id             ra_customer_trx.bill_to_customer_id%TYPE := NULL;
  l_sold_to_customer_name           hz_parties.party_name%TYPE := NULL;
  l_sold_to_customer_number         hz_cust_accounts.account_number%TYPE := NULL;
  l_paying_customer_id              ra_customer_trx.ship_to_customer_id%TYPE := NULL;
  l_paying_customer_name            hz_parties.party_name%TYPE := NULL;
  l_paying_customer_number          hz_cust_accounts.account_number%TYPE := NULL;
  l_paying_location                 hz_cust_site_uses.location%TYPE := NULL;
  l_receipt_method_id               ra_customer_trx.receipt_method_id%TYPE := NULL;
  l_receipt_method_name             ar_receipt_methods.name%TYPE := NULL;
  l_cust_bank_account_id            ra_customer_trx.customer_bank_account_id%TYPE := NULL;
  l_cust_bank_account_name          ap_bank_accounts.bank_account_name%TYPE := NULL;
  l_cust_bank_account_number        ap_bank_accounts.bank_account_num%TYPE := NULL;
  l_start_date_commitment           DATE := NULL;
  l_end_date_commitment             DATE := NULL;
  l_amount                          NUMBER := NULL;
  l_inventory_id                    NUMBER := NULL;
  l_memo_line_id                    NUMBER := NULL;
  l_memo_line_name                  VARCHAR2(240) := NULL;
  l_description                     VARCHAR2(240) := NULL;
  l_comm_interface_line_context     VARCHAR2(30) := NULL;
  l_comm_interface_line_attr1       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr2       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr3       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr4       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr5       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr6       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr7       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr8       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr9       VARCHAR2(150) := NULL;
  l_comm_interface_line_attr10      VARCHAR2(150) := NULL;
  l_comm_interface_line_attr11      VARCHAR2(150) := NULL;
  l_comm_interface_line_attr12      VARCHAR2(150) := NULL;
  l_comm_interface_line_attr13      VARCHAR2(150) := NULL;
  l_comm_interface_line_attr14      VARCHAR2(150) := NULL;
  l_comm_interface_line_attr15      VARCHAR2(150) := NULL;
  l_global_attr_cust_lines_rec      ar_deposit_api_pub.global_attr_rec_type := NULL;
  l_org_id                          NUMBER := NULL;
  l_payment_trxn_extension_id       NUMBER := NULL;
  X_new_trx_number                  ra_customer_trx.trx_number%TYPE := NULL;
  X_new_customer_trx_id             ra_customer_trx.customer_trx_id%TYPE := NULL;
  X_new_customer_trx_line_id        ra_customer_trx_lines.customer_trx_line_id%TYPE := NULL;
  X_new_rowid                       VARCHAR2(18) := NULL;
  l_batch_source_id                 ra_batch_sources.batch_source_id%TYPE := NULL;
  l_batch_source_name               ra_batch_sources.NAME%TYPE := NULL;
  l_cust_trx_type_id                ra_cust_trx_types.cust_trx_type_id%TYPE := NULL;
  l_cust_trx_type_name              ra_cust_trx_types.NAME%TYPE := NULL;

  x_msg_data    VARCHAR2(1000);
  x_msg_count   NUMBER;

  BEGIN
  print_log('Inside create_emd_deposit procedure');
  -- initializilation of variables
  l_deposit_date := p_in_rec.deposit_date;
  l_currency_code := p_in_rec.deposit_currency;
  l_exchange_rate_type := p_in_rec.exchange_rate_type ;
  l_exchange_rate := p_in_rec.exchange_rate;
  l_exchange_date := p_in_rec.exchange_date;
  l_batch_source_id := p_in_rec.batch_source_id;
  l_memo_line_id := p_in_rec.memo_line_id;
  l_cust_trx_type_id := p_in_rec.trx_type_id;
  l_gl_date := p_in_rec.deposit_date;
  l_bill_to_customer_id  := p_in_rec.customer_id;
  l_paying_customer_id := p_in_rec.customer_id;
--  l_paying_location := p_in_rec.paying_location;
  l_printing_option := 'PRI';
  l_remit_to_address_id := NULL;
  l_receipt_method_id :=p_in_rec.receipt_method_id;
  l_cust_bank_account_id := p_in_rec.customer_bank_account_id;
  l_amount := p_in_rec.deposit_amount;
  l_org_id := p_in_rec.org_id;
  l_comm_interface_line_context := 'EMD TRANSACTIONS';
  l_comm_interface_line_attr1  := p_in_rec.document_number;
  l_comm_interface_line_attr2  := p_in_rec.party_id;
  l_comm_interface_line_attr3  := p_in_rec.party_site_id;
  l_comm_interface_line_attr4  := p_in_rec.party_contact_id;
  l_comm_interface_line_attr7  := p_in_rec.emd_trx_group_id;
  l_comm_interface_line_attr8  := p_in_rec.emd_transaction_id;
  IF (p_in_rec.payment_type_code = G_DEMAND_DRAFT) THEN
    l_comm_interface_line_attr5  := 'DD No:'||p_in_rec.demand_draft_num;
    l_comm_interface_line_attr6  := 'Bank:'||p_in_rec.bank_name ||','||'Pay At:'||p_in_rec.payable_at ;
  END IF;
  IF (p_in_rec.payment_type_code = G_CHECK) THEN
    l_comm_interface_line_attr5  := 'Check No:'||p_in_rec.cheque_number||','||'Acctnum:'||p_in_rec.bank_account_num;
    l_comm_interface_line_attr6  := 'Bank:'||p_in_rec.bank_name ||','||'Branch:'||p_in_rec.bank_branch_name;
  END IF;


  l_payment_trxn_extension_id  := p_in_rec.payment_trxn_extension_id;

  print_log('l_deposit_date: '||l_deposit_date);
  print_log('l_currency_code: '||l_currency_code);
  print_log('l_exchange_rate_type: '||l_exchange_rate_type);
  print_log('l_exchange_rate: '||l_exchange_rate);
  print_log('l_exchange_date: '||l_exchange_date);
  print_log('l_batch_source_id: '||l_batch_source_id);
  print_log('l_memo_line_id: '||l_memo_line_id);
  print_log('l_cust_trx_type_id: '||l_cust_trx_type_id);
  print_log('l_gl_date: '||l_gl_date);
  print_log('l_bill_to_customer_id: '||l_bill_to_customer_id);
  print_log('l_paying_customer_id: '||l_paying_customer_id);
  print_log('l_receipt_method_id: '||l_receipt_method_id);
  print_log('l_cust_bank_account_id: '||l_cust_bank_account_id);
  print_log('l_amount: '||l_amount );
  print_log('l_org_id: '||l_org_id);
  print_log('l_comm_interface_line_attr1: '||l_comm_interface_line_attr1);
  print_log('l_comm_interface_line_attr2: '||l_comm_interface_line_attr2);
  print_log('l_comm_interface_line_attr3: '||l_comm_interface_line_attr3);
  print_log('l_comm_interface_line_attr4: '||l_comm_interface_line_attr4);
  print_log('l_comm_interface_line_attr5: '||l_comm_interface_line_attr5);
  print_log('l_comm_interface_line_attr6: '||l_comm_interface_line_attr6);
  print_log('l_payment_trxn_extension_id: '||l_payment_trxn_extension_id);

  --Bug 14812557
  --Passing "Generic Commitment" as description as per the update from Receivables team in the bug
  print_log('Retrieving transaction description from ar_lookups');

  select meaning
  into   l_description
  from   ar_lookups
  where  lookup_type = 'COMMITMENT_DESCRIPTION'
  and    lookup_code = 'GENERIC'
  and    sysdate between start_date_active and nvl(end_date_active, sysdate)
  and    enabled_flag = 'Y';

  print_log('l_description: '||l_description);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for callcompatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  --Call to AR API
  l_progress := 100;
  AR_DEPOSIT_API_PUB.CREATE_DEPOSIT(
           -- Standard API parameters.
                 1,                                -- p_api_version
                 p_init_msg_list,                   -- p_init_msg_list
                 p_commit,                          -- p_commit
                 FND_API.G_VALID_LEVEL_FULL,       -- p_validation_level
                 x_return_status,                  -- return status(out)
                 x_msg_count,                       -- message count(out)
                 x_msg_data,                        -- message data(out)
                 l_deposit_number,                 -- deposit number
                 l_deposit_date,                   -- deposit date
                 l_usr_currency_code,              -- user currency code
                 l_currency_code,                  -- deposit currency code
                 l_usr_exchange_rate_type,         -- usr exchange rate type
                 l_exchange_rate_type,             -- exchange rate type
                 l_exchange_rate,                  -- exchange rate
                 l_exchange_date,                  -- exchange date
                 l_batch_source_id,                 -- Batch source id
                 l_batch_source_name,              -- Batch Source Name
                 l_cust_trx_type_id,            -- Transaction type id
                 l_cust_trx_type_name,          -- Transaction Type Name
                 'DEP',                            -- Transaction Class
                 l_gl_date,                        -- GL Date
                 l_bill_to_customer_id         ,
                 l_bill_to_customer_name       ,
                 l_bill_to_customer_number     ,
                 l_bill_to_location            ,
                 l_bill_to_contact_id          ,
                 l_bill_to_contact_first_name  ,
                 l_bill_to_contact_last_name   ,
                 l_ship_to_customer_id         ,
                 l_ship_to_customer_name       ,
                 l_ship_to_customer_number     ,
                 l_ship_to_location            ,
                 l_ship_to_contact_id          ,
                 l_ship_to_contact_first_name  ,
                 l_ship_to_contact_last_name   ,
                 l_term_id                     ,
                 l_term_name                   ,
                 l_salesrep_id                 ,
                 l_salesrep_name               ,
                 l_interface_header_context    ,
                 l_interface_header_attribute1 ,
                 l_interface_header_attribute2 ,
                 l_interface_header_attribute3 ,
                 l_interface_header_attribute4 ,
                 l_interface_header_attribute5 ,
                 l_interface_header_attribute6 ,
                 l_interface_header_attribute7 ,
                 l_interface_header_attribute8 ,
                 l_interface_header_attribute9 ,
                 l_interface_header_attribute10,
                 l_interface_header_attribute11,
                 l_interface_header_attribute12,
                 l_interface_header_attribute13,
                 l_interface_header_attribute14,
                 l_interface_header_attribute15,
                 l_attribute_category,
                 l_attribute1,
                 l_attribute2,
                 l_attribute3,
                 l_attribute4,
                 l_attribute5,
                 l_attribute6,
                 l_attribute7,
                 l_attribute8,
                 l_attribute9,
                 l_attribute10,
                 l_attribute11,
                 l_attribute12,
                 l_attribute13,
                 l_attribute14,
                 l_attribute15,
            -- ******* Global Flexfield parameters *******
                 l_global_attr_cust_rec,
                 l_document_number,
                 l_ussgl_transaction_code,
		             l_printing_option,
                 l_default_tax_exempt_flag,
                 l_status_trx,
                 l_financial_charges,
                 l_agreement_id,
                 l_special_instructions,
                 l_comments,
                 l_purchase_order,
                 l_purchase_order_revision,
                 l_purchase_order_date,
                 l_remit_to_address_id,
                 l_sold_to_customer_id,
                 l_sold_to_customer_name,
                 l_sold_to_customer_number,
                 l_paying_customer_id,
                 l_paying_customer_name,
                 l_paying_customer_number,
                 l_paying_location,
                 l_receipt_method_id,
                 l_receipt_method_name,
                 l_cust_bank_account_id,
                 l_cust_bank_account_name,
                 l_cust_bank_account_number,
                 l_start_date_commitment,
                 l_end_date_commitment,
                 l_amount,
                 l_inventory_id,
                 l_memo_line_id,
                 l_memo_line_name,
                 l_description,
                --flexfeild for Lines
                 l_comm_interface_line_context ,
                 l_comm_interface_line_attr1   ,
                 l_comm_interface_line_attr2   ,
                 l_comm_interface_line_attr3   ,
                 l_comm_interface_line_attr4   ,
                 l_comm_interface_line_attr5   ,
                 l_comm_interface_line_attr6   ,
                 l_comm_interface_line_attr7   ,
                 l_comm_interface_line_attr8   ,
                 l_comm_interface_line_attr9   ,
                 l_comm_interface_line_attr10  ,
                 l_comm_interface_line_attr11  ,
                 l_comm_interface_line_attr12  ,
                 l_comm_interface_line_attr13  ,
                 l_comm_interface_line_attr14  ,
                 l_comm_interface_line_attr15  ,
                 -- ******* Global Flexfield parameters *******
                 l_global_attr_cust_lines_rec,
                 l_org_id,
                 l_payment_trxn_extension_id,
                   --   ** OUT NOCOPY variables
                 x_new_trx_number,
                 x_new_customer_trx_id,
                 x_new_customer_trx_line_id,
                 x_new_rowid);

  print_log('After executing AR API AR_DEPOSIT_API_PUB.CREATE_DEPOSIT');
  print_log('x_new_trx_number: '||x_new_trx_number);
  print_log('x_new_customer_trx_id: '||x_new_customer_trx_id);
  print_log('x_new_customer_trx_line_id: '||x_new_customer_trx_line_id);
  print_log('x_return_status: '||x_return_status);

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.SET_NAME('PON','EMD_DEPOSIT_CREATION_FAILED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  IF (x_new_trx_number IS null) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','EMD_DEPOSIT_CREATION_FAILED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  --Setting out parameters
  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_out_rec.deposit_trx_number := x_new_trx_number;
    x_out_rec.deposit_trx_id := x_new_customer_trx_id;
    x_out_rec.deposit_trx_line_id :=x_new_customer_trx_line_id;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;


 EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END create_emd_deposit;

-----------------------------------------------------------------------
--Start of Comments
--Name: create_emd_receipt_and_apply
--Description : creates and applies receipt on emd deposit(not used this
--in the transaction flow eventhough procedure is created)
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_emd_receipt_and_apply
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         RECEIPT_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY RECEIPT_INFO_OUT_RECTYPE
  )IS
  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'create_emd_receipt_and_apply';
  l_progress NUMBER;
  l_usr_currency_code              ar_cash_receipts.currency_code%TYPE  DEFAULT NULL;
  l_currency_code                  ar_cash_receipts.currency_code%TYPE  DEFAULT NULL;
  l_usr_exchange_rate_type         ar_cash_receipts.exchange_rate_type%TYPE  DEFAULT NULL;
  l_exchange_rate_type             ar_cash_receipts.exchange_rate_type%TYPE  DEFAULT NULL;
  l_exchange_rate                  ar_cash_receipts.exchange_rate%TYPE    DEFAULT NULL;
  l_exchange_date                  ar_cash_receipts.exchange_date%TYPE    DEFAULT NULL;
  l_amount                         ar_cash_receipts.amount%TYPE   DEFAULT NULL;
  l_factor_discount_amount         ar_cash_receipts.factor_discount_amount%TYPE  DEFAULT NULL;
  l_receipt_number                 ar_cash_receipts.receipt_number%TYPE  DEFAULT NULL;
  l_receipt_date                   ar_cash_receipts.receipt_date%TYPE    DEFAULT NULL;
  l_gl_date                        ar_cash_receipt_history.gl_date%TYPE  DEFAULT NULL;
  l_maturity_date                  DATE      DEFAULT NULL;
  l_postmark_date                  DATE      DEFAULT NULL;
  l_customer_id                    ar_cash_receipts.pay_from_customer%TYPE   DEFAULT NULL;
  l_customer_name                  hz_parties.party_name%TYPE DEFAULT NULL;
  l_customer_number                hz_parties.party_number%TYPE  DEFAULT NULL;
  l_customer_bank_account_id       ar_cash_receipts.customer_bank_account_id%TYPE  DEFAULT NULL;
  l_customer_bank_account_num      iby_ext_bank_accounts_v.bank_account_number%TYPE    DEFAULT NULL;
  l_customer_bank_account_name     iby_ext_bank_accounts_v.bank_account_name%TYPE    DEFAULT NULL;
  l_payment_trxn_extension_id      ar_cash_receipts.payment_trxn_extension_id%TYPE    DEFAULT NULL; --payment uptake changes bichatte
  l_location                       hz_cust_site_uses.location%TYPE  DEFAULT NULL;
  l_customer_site_use_id           hz_cust_site_uses.site_use_id%TYPE    DEFAULT NULL;
  l_default_site_use               VARCHAR2(1) DEFAULT  'Y';
  l_customer_receipt_reference     ar_cash_receipts.customer_receipt_reference%TYPE    DEFAULT NULL;
  l_override_remit_account_flag    ar_cash_receipts.override_remit_account_flag%TYPE   DEFAULT NULL;
  l_remittance_bank_account_id     ar_cash_receipts.remit_bank_acct_use_id%TYPE    DEFAULT NULL;
  l_remittance_bank_account_num    ce_bank_accounts.bank_account_num%TYPE   DEFAULT NULL;
  l_remittance_bank_account_name   ce_bank_accounts.bank_account_name%TYPE  DEFAULT NULL;
  l_deposit_date                   ar_cash_receipts.deposit_date%TYPE   DEFAULT NULL;
  l_receipt_method_id              ar_cash_receipts.receipt_method_id%TYPE    DEFAULT NULL;
  l_receipt_method_name            ar_receipt_methods.name%TYPE   DEFAULT NULL;
  l_doc_sequence_value             NUMBER      DEFAULT NULL;
  l_ussgl_transaction_code         ar_cash_receipts.ussgl_transaction_code%TYPE    DEFAULT NULL;
  l_anticipated_clearing_date      ar_cash_receipts.ussgl_transaction_code%TYPE   DEFAULT NULL;
  l_called_from                    VARCHAR2(20)    DEFAULT NULL;
  l_attribute_rec                  AR_RECEIPT_API_PUB.attribute_rec_type   DEFAULT AR_RECEIPT_API_PUB.attribute_rec_const;
  l_global_attribute_rec           AR_RECEIPT_API_PUB.global_attribute_rec_type   DEFAULT AR_RECEIPT_API_PUB.global_attribute_rec_const;
  l_comments                       ar_cash_receipts.comments%TYPE    DEFAULT NULL;
  l_issuer_name                    ar_cash_receipts.issuer_name%TYPE   DEFAULT NULL;
  l_issue_date                     ar_cash_receipts.issue_date%TYPE    DEFAULT NULL;
  l_issuer_bank_branch_id          ar_cash_receipts.issuer_bank_branch_id%TYPE    DEFAULT NULL;
  l_cr_id                          NUMBER    DEFAULT NULL;
  l_customer_trx_id                ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL;
  l_trx_number                     ra_customer_trx.trx_number%TYPE DEFAULT NULL;
  l_installment                    ar_payment_schedules.terms_sequence_number%TYPE DEFAULT NULL;
  l_applied_payment_schedule_id    ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL;
  l_amount_applied                 ar_receivable_applications.amount_applied%TYPE DEFAULT NULL;
  l_amount_applied_from            ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL;
  l_trans_to_receipt_rate          ar_receivable_applications.trans_to_receipt_rate%TYPE DEFAULT NULL;
  l_discount                       ar_receivable_applications.earned_discount_taken%TYPE DEFAULT NULL;
  l_apply_date                     ar_receivable_applications.apply_date%TYPE DEFAULT NULL;
  l_apply_gl_date                  ar_receivable_applications.gl_date%TYPE DEFAULT NULL;
  app_ussgl_transaction_code       ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL;
  l_customer_trx_line_id	         ar_receivable_applications.applied_customer_trx_line_id%TYPE DEFAULT NULL;
  l_line_number                    ra_customer_trx_lines.line_number%TYPE DEFAULT NULL;
  l_show_closed_invoices           VARCHAR2(1) DEFAULT 'N';
  l_move_deferred_tax              VARCHAR2(1) DEFAULT 'Y';
  l_link_to_trx_hist_id            ar_receivable_applications.link_to_trx_hist_id%TYPE DEFAULT NULL;
  app_attribute_rec                AR_RECEIPT_API_PUB.attribute_rec_type DEFAULT AR_RECEIPT_API_PUB.attribute_rec_const;
  app_global_attribute_rec         AR_RECEIPT_API_PUB.global_attribute_rec_type DEFAULT AR_RECEIPT_API_PUB.global_attribute_rec_const;
  app_comments                     ar_receivable_applications.comments%TYPE DEFAULT NULL;
  l_call_payment_processor         VARCHAR2(1) DEFAULT FND_API.G_FALSE;
  l_org_id                         NUMBER      DEFAULT NULL;

  x_msg_data  VARCHAR2(1000);
  x_msg_count NUMBER;

  BEGIN

    l_progress := 100;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Call to AR create_cash API
  l_progress := 100;
  AR_RECEIPT_API_PUB.Create_and_apply(
                 1,                                -- p_api_version
                 FND_API.G_FALSE,                   -- p_init_msg_list
                 FND_API.G_FALSE,                  -- p_commit
                 FND_API.G_VALID_LEVEL_FULL,       -- p_validation_level
                 x_return_status,                  -- return status(out)
                 x_msg_count,                      -- message count(out)
                 x_msg_data,                       -- message data(out)
                 l_usr_currency_code ,
                 l_currency_code,
                 l_usr_exchange_rate_type,
                 l_exchange_rate_type,
                 l_exchange_rate,
                 l_exchange_date,
                 l_amount,
                 l_factor_discount_amount,
                 l_receipt_number,
                 l_receipt_date,
                 l_gl_date,
                 l_maturity_date,
                 l_postmark_date,
                 l_customer_id,
                 l_customer_name,
                 l_customer_number,
                 l_customer_bank_account_id,
                 l_customer_bank_account_num,
                 l_customer_bank_account_name,
                 l_payment_trxn_extension_id,
                 l_location,
                 l_customer_site_use_id,
                 l_default_site_use,
                 l_customer_receipt_reference,
                 l_override_remit_account_flag,
                 l_remittance_bank_account_id,
                 l_remittance_bank_account_num,
                 l_remittance_bank_account_name,
                 l_deposit_date,
                 l_receipt_method_id,
                 l_receipt_method_name,
                 l_doc_sequence_value,
                 l_ussgl_transaction_code,
                 l_anticipated_clearing_date,
                 l_called_from,
                 l_attribute_rec,
                 l_global_attribute_rec,
                 l_comments,
                 l_issuer_name,
                 l_issue_date,
                 l_issuer_bank_branch_id,
                 l_cr_id,
                 l_customer_trx_id,
                 l_trx_number,
                 l_installment,
                 l_applied_payment_schedule_id,
                 l_amount_applied,
                 l_amount_applied_from,
                 l_trans_to_receipt_rate,
                 l_discount,
                 l_apply_date,
                 l_apply_gl_date,
                 app_ussgl_transaction_code,
                 l_customer_trx_line_id,
                 l_line_number,
                 l_show_closed_invoices,
                 l_move_deferred_tax,
                 l_link_to_trx_hist_id,
                 app_attribute_rec,
                 app_global_attribute_rec,
                 app_comments,
                 l_call_payment_processor,
                 l_org_id);

  --Setting out parameters
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.SET_NAME('PON','RECEIPT_CRE_AND_APPLY_FAILED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_out_rec.receipt_id := l_cr_id;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;


 EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END create_emd_receipt_and_apply;

-----------------------------------------------------------------------
--Start of Comments
--Name: unapply_emd_receipt
--Description : unapplies emd receipt
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE unapply_emd_receipt
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         UNAPPLY_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY UNAPPLY_INFO_OUT_RECTYPE
  )IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'unapply_emd_receipt';
  l_progress NUMBER;
  l_receipt_number                 ar_cash_receipts.receipt_number%TYPE DEFAULT NULL;
  l_cash_receipt_id                ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL;
  l_trx_number                     ra_customer_trx.trx_number%TYPE DEFAULT NULL;
  l_customer_trx_id                ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL;
  l_installment                    ar_payment_schedules.terms_sequence_number%TYPE DEFAULT NULL;
  l_applied_payment_schedule_id    ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL;
  l_receivable_application_id      ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL;
  l_reversal_gl_date               ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL;
  l_called_from                    VARCHAR2(30) DEFAULT NULL;
  l_cancel_claim_flag              VARCHAR2(1)  DEFAULT 'Y';
  l_org_id                         NUMBER  DEFAULT NULL;

  x_msg_data  VARCHAR2(1000);
  x_msg_count NUMBER;

  BEGIN

  print_log('Inside unapply_emd_receipt procedure');

  l_progress := 100;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;


  l_cash_receipt_id := p_in_rec.cash_receipt_id;
  l_customer_trx_id := p_in_rec.deposit_trx_id;
  l_reversal_gl_date := p_in_rec.transaction_date;
  l_receivable_application_id := p_in_rec.receivable_app_id;
  l_org_id := p_in_rec.org_id;
  l_installment := 1;

  print_log('l_cash_receipt_id: '||l_cash_receipt_id);
  print_log('l_customer_trx_id: '||l_customer_trx_id);
  print_log('l_reversal_gl_date: '||l_reversal_gl_date);
  print_log('l_receivable_application_id: '||l_receivable_application_id);
  print_log('l_org_id: '||l_org_id);
  print_log('l_installment: '||l_installment);

  x_return_status := fnd_api.g_ret_sts_success;

  --Call to AR Unapply API
  AR_RECEIPT_API_PUB.Unapply(
                 1,                                -- p_api_version
                 p_init_msg_list,                  -- p_init_msg_list
                 p_commit,                         -- p_commit
                 FND_API.G_VALID_LEVEL_FULL,       -- p_validation_level
                 x_return_status,                  -- return status(out)
                 x_msg_count,                      -- message count(out)
                 x_msg_data,                       -- message data(out)
                 l_receipt_number,
                 l_cash_receipt_id,
                 l_trx_number,
                 l_customer_trx_id,
                 l_installment,
                 l_applied_payment_schedule_id,
                 l_receivable_application_id,
                 l_reversal_gl_date,
                 l_called_from,
                 l_cancel_claim_flag,
                 l_org_id);

  print_log('After executing AR procedure AR_RECEIPT_API_PUB.Unapply');
  print_log('x_return_status: '||x_return_status);

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    FND_MESSAGE.SET_NAME('PON','UNAPPLY_EMD_RECEIPT_FAILED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_out_rec.receipt_id := l_cash_receipt_id;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END unapply_emd_receipt;


-----------------------------------------------------------------------
--Start of Comments
--Name: refund_activity_on_emd_receipt
--Description : Applies refund activity on EMD receipt
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE refund_activity_on_emd_receipt
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         REFUND_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY REFUND_INFO_OUT_RECTYPE
  )IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'refund_activity_on_emd_receipt';
  l_progress NUMBER;
  l_cash_receipt_id               ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL;
  l_receipt_number                ar_cash_receipts.receipt_number%TYPE DEFAULT NULL;
  l_amount_applied                ar_receivable_applications.amount_applied%TYPE DEFAULT NULL;
  l_applied_payment_schedule_id   ar_payment_schedules.payment_schedule_id%TYPE; --this has no default
  l_link_to_customer_trx_id	      ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL;
  l_receivables_trx_id            ar_receivable_applications.receivables_trx_id%TYPE; --this has no default
  l_apply_date                    ar_receivable_applications.apply_date%TYPE DEFAULT NULL;
  l_apply_gl_date                 ar_receivable_applications.gl_date%TYPE DEFAULT NULL;
  l_ussgl_transaction_code        ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL;
  l_attribute_rec                 AR_RECEIPT_API_PUB.attribute_rec_type DEFAULT AR_RECEIPT_API_PUB.attribute_rec_const;
  l_global_attribute_rec          AR_RECEIPT_API_PUB.global_attribute_rec_type DEFAULT AR_RECEIPT_API_PUB.global_attribute_rec_const;
  l_comments                      ar_receivable_applications.comments%TYPE DEFAULT NULL;
  l_application_ref_type          ar_receivable_applications.application_ref_type%TYPE;
  l_application_ref_id            ar_receivable_applications.application_ref_id%TYPE;
  l_application_ref_num           ar_receivable_applications.application_ref_num%TYPE;
  l_secondary_application_ref_id  ar_receivable_applications.secondary_application_ref_id%TYPE;
  l_payment_set_id                ar_receivable_applications.payment_set_id%TYPE DEFAULT NULL;
  l_receivable_application_id     ar_receivable_applications.receivable_application_id%TYPE;
  l_customer_reference            ar_receivable_applications.customer_reference%TYPE DEFAULT NULL;
  l_val_writeoff_limits_flag      VARCHAR2(1);
  l_called_from		                VARCHAR2(30) DEFAULT NULL;
  l_netted_receipt_flag	          VARCHAR2(1) DEFAULT NULL;
  l_netted_cash_receipt_id        ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL;
  l_secondary_apl_ref_type        ar_receivable_applications.secondary_application_ref_type%TYPE := null;
  l_secondary_apl_ref_num         ar_receivable_applications.secondary_application_ref_num%TYPE := null;
  l_org_id                        NUMBER  DEFAULT NULL;
  l_customer_reason               ar_receivable_applications.customer_reason%TYPE DEFAULT NULL;
  l_pay_group_lookup_code	        FND_LOOKUPS.lookup_code%TYPE DEFAULT NULL;
  l_pay_alone_flag		            VARCHAR2(1) DEFAULT 'Y';
  l_payment_method_code	          ap_invoices.payment_method_code%TYPE DEFAULT NULL;
  l_payment_reason_code	          ap_invoices.payment_reason_code%TYPE DEFAULT NULL;
  l_payment_reason_comments	      ap_invoices.payment_reason_comments%TYPE DEFAULT NULL;
  l_delivery_channel_code	        ap_invoices.delivery_channel_code%TYPE DEFAULT NULL;
  l_remittance_message1	          ap_invoices.remittance_message1%TYPE DEFAULT NULL;
  l_remittance_message2	          ap_invoices.remittance_message2%TYPE DEFAULT NULL;
  l_remittance_message3	          ap_invoices.remittance_message3%TYPE DEFAULT NULL;
  l_party_id		                  hz_parties.party_id%TYPE DEFAULT NULL;
  l_party_site_id		              hz_party_sites.party_site_id%TYPE DEFAULT NULL;
  l_bank_account_id               ar_cash_receipts.customer_bank_account_id%TYPE DEFAULT NULL;
  x_msg_count                     NUMBER;
  x_msg_data                      VARCHAR2(1000);
  l_organization_name             hr_operating_units.NAME%TYPE;

BEGIN

  l_progress := 100;

  print_log('Inside procedure refund_activity_on_emd_receipt');

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  l_receipt_number := p_in_rec.receipt_num;
  l_cash_receipt_id := p_in_rec.cash_receipt_id;
  l_amount_applied  := p_in_rec.amount_applied;
  l_apply_date := p_in_rec.apply_date;
  l_apply_gl_date := p_in_rec.apply_gl_date;
  l_payment_method_code := p_in_rec.payment_method_code;
  l_applied_payment_schedule_id := p_in_rec.applied_payment_schedule_id;
  l_org_id := p_in_rec.org_id;
  BEGIN
      SELECT name
        INTO l_organization_name
        FROM hr_operating_units
       WHERE organization_id = l_org_id;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','ORG_NOT_FOUND_IN_HR');
    FND_MESSAGE.SET_TOKEN('ORG_ID',To_Char(l_org_id));
    RETURN;
  END;

  IF (l_applied_payment_schedule_id = -8 ) THEN
    BEGIN
      SELECT  RECEIVABLES_TRX_ID
        INTO  l_receivables_trx_id
        FROM  ar_receivables_trx_all
        WHERE status = 'A' AND
        TYPE ='CM_REFUND'AND ORG_ID = l_org_id;
    EXCEPTION
    WHEN No_Data_Found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('PON','REC_ACT_OF_REFUND_TYPE_NOT_DEF');
      fnd_message.set_token('ORG',l_organization_name);
      FND_MSG_PUB.ADD;
      RETURN;
    END;
  ELSIF(l_applied_payment_schedule_id = -6 ) THEN
    BEGIN
      SELECT  RECEIVABLES_TRX_ID
        INTO  l_receivables_trx_id
        FROM  ar_receivables_trx_all
        WHERE status = 'A' AND
        TYPE ='CCREFUND'AND ORG_ID = l_org_id;
    EXCEPTION
    WHEN No_Data_Found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('PON','REC_ACT_FOR_CCREFUND_NOT_DEF');
      fnd_message.set_token('ORG',l_organization_name);
      FND_MSG_PUB.ADD;
      RETURN;
    END;
  END IF;


  print_log('l_receipt_number: '||l_receipt_number);
  print_log('l_cash_receipt_id: '||l_cash_receipt_id);
  print_log('l_amount_applied: '||l_amount_applied);
  print_log('l_apply_date: '||l_apply_date);
  print_log('l_apply_gl_date: '||l_apply_gl_date);
  print_log('l_payment_method_code: '||l_payment_method_code);
  print_log('l_applied_payment_schedule_id: '||l_applied_payment_schedule_id);
  print_log('l_receivables_trx_id: '||l_receivables_trx_id);

  --Call to AR Activity_application API
  AR_RECEIPT_API_PUB.Activity_application(
                  1,                                -- p_api_version
                  p_init_msg_list,                  -- p_init_msg_list
                  p_commit,                         -- p_commit
                  FND_API.G_VALID_LEVEL_FULL,       -- p_validation_level
                  x_return_status,                  -- return status(out)
                  x_msg_count,                      -- message count(out)
                  x_msg_data,                       -- message data(out)
                  l_cash_receipt_id,
                  l_receipt_number,
                  l_amount_applied,
                  l_applied_payment_schedule_id,
                  l_link_to_customer_trx_id,
                  l_receivables_trx_id,
                  l_apply_date,
                  l_apply_gl_date,
                  l_ussgl_transaction_code,
                  l_attribute_rec,
                  l_global_attribute_rec,
                  l_comments,
                  l_application_ref_type,
                  l_application_ref_id,
                  l_application_ref_num,
                  l_secondary_application_ref_id,
                  l_payment_set_id,
                  l_receivable_application_id,
                  l_customer_reference,
                  l_val_writeoff_limits_flag,
                  l_called_from,
                  l_netted_receipt_flag,
                  l_netted_cash_receipt_id,
                  l_secondary_apl_ref_type,
                  l_secondary_apl_ref_num,
                  l_org_id,
                  l_customer_reason,
                  l_pay_group_lookup_code,
                  l_pay_alone_flag,
                  l_payment_method_code,
                  l_payment_reason_code,
                  l_payment_reason_comments,
                  l_delivery_channel_code,
                  l_remittance_message1,
                  l_remittance_message2,
                  l_remittance_message3,
                  l_party_id,
                  l_party_site_id,
                  l_bank_account_id);

  print_log('After executing AR procedure AR_RECEIPT_API_PUB.Activity_application');
  print_log('l_application_ref_id: '||l_application_ref_id);
  print_log('x_return_status: '||x_return_status);

  IF(l_application_ref_id IS null) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','EMD_REFUND_TRX_FAILED');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_out_rec.application_ref_id := l_application_ref_id;
    x_out_rec.application_ref_type := l_application_ref_type;
    x_out_rec.application_ref_num :=  l_application_ref_num;
  END IF;

  print_log('l_application_ref_type: '||l_application_ref_type);
  print_log('l_application_ref_num: '||l_application_ref_num);

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END refund_activity_on_emd_receipt;

-----------------------------------------------------------------------
--Start of Comments
--Name: create_cm_on_emd_deposit
--Description : Creates credit memo on deposit in AR
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE create_cm_on_emd_deposit
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         CM_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY CM_INFO_OUT_RECTYPE
  )IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'create_cm_on_emd_deposit';
  l_progress NUMBER;
  l_customer_trx_id             ra_customer_trx.customer_trx_id%type;
  l_line_credit_flag            ra_cm_requests.line_credits_flag%type;
  l_line_amount                 NUMBER 	:= NULL;
  l_tax_amount                  NUMBER	:= NULL;
  l_freight_amount              NUMBER	:= NULL;
  l_cm_reason_code              ra_cm_requests.cm_reason_code%TYPE;
  l_comments                    ra_cm_requests.comments%TYPE    DEFAULT NULL	;
  l_orig_trx_number             ra_cm_requests.orig_trx_number%TYPE    DEFAULT NULL;
  l_tax_ex_cert_num	            ra_cm_requests.tax_ex_cert_num%TYPE    DEFAULT NULL;
  l_request_url                 ra_cm_requests.url%TYPE    := 'AR_CREDIT_MEMO_API_PUB.print_default_page';
  l_transaction_url             ra_cm_requests.transaction_url%TYPE    := 'AR_CREDIT_MEMO_API_PUB.print_default_page';
  l_trans_act_url               ra_cm_requests.activities_url%TYPE  := 'AR_CREDIT_MEMO_API_PUB.print_default_page';
  l_cm_line_tbl                 arw_cmreq_cover.Cm_Line_Tbl_Type_Cover := ar_credit_memo_api_pub.cm_line_tbl_type_cover ;
  l_skip_workflow_flag          VARCHAR2(1)     DEFAULT 'N';
  l_credit_method_installments  ra_customer_trx.credit_method_for_installments%type     DEFAULT NULL;
  l_credit_method_rules         ra_customer_trx.credit_method_for_rules%type     DEFAULT NULL;
  l_batch_source_name           ra_batch_sources.NAME%TYPE     DEFAULT NULL;
  l_org_id                      NUMBER       DEFAULT NULL;
  x_request_id                  ra_cm_requests.request_id%type;
  l_attribute_rec               arw_cmreq_cover.pq_attribute_rec_type DEFAULT ar_credit_memo_api_pub.attribute_rec_const;
  l_interface_attribute_rec     arw_cmreq_cover.pq_interface_rec_type DEFAULT ar_credit_memo_api_pub.interface_rec_const;
  l_global_attribute_rec        arw_cmreq_cover.pq_global_attribute_rec_type DEFAULT  ar_credit_memo_api_pub.global_attribute_rec_const;
  l_dispute_date		            DATE	DEFAULT NULL;

--Request status parameters
  l_request_id            ra_cm_requests.request_id%TYPE;
  x_status_meaning        VARCHAR2(30);
  x_reason_meaning        VARCHAR2(30);
  x_customer_trx_id       ra_cm_requests.customer_trx_id%TYPE;
  x_cm_customer_trx_id    ra_cm_requests.cm_customer_trx_id%TYPE;
  x_line_amount           ra_cm_requests.line_amount%TYPE;
  x_tax_amount            ra_cm_requests.tax_amount%TYPE;
  x_freight_amount        ra_cm_requests.freight_amount%TYPE;
  x_line_credits_flag     ra_cm_requests.line_credits_flag%TYPE;
  x_created_by            NUMBER(15);
  x_creation_date         DATE;
  x_approval_date         DATE;
  x_comments              ra_cm_requests.comments%TYPE;
  x_cm_line_tbl           AR_CREDIT_MEMO_API_PUB.Cm_Line_Tbl_Type_Cover%type;
  x_cm_activity_tbl       AR_CREDIT_MEMO_API_PUB.x_cm_activity_tbl%type;
  x_cm_notes_tbl          AR_CREDIT_MEMO_API_PUB.x_cm_notes_tbl%type;

  x_msg_data              VARCHAR2(1000);
  x_msg_count             NUMBER;

BEGIN
  print_log('Inside create_cm_on_emd_deposit procedure');
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

  l_customer_trx_id :=  p_in_rec.customer_trx_id;
  l_line_amount := (-1) * p_in_rec.line_amount;
  l_line_credit_flag := 'Y';
  l_cm_reason_code := 'RETURN';
  l_skip_workflow_flag := 'Y';
  l_org_id := p_in_rec.org_id;

  l_cm_line_tbl(1).customer_trx_line_id := p_in_rec.customer_trx_line_id;
  l_cm_line_tbl(1).extended_amount := (-1) * p_in_rec.line_amount;
  l_cm_line_tbl(1).INTERFACE_LINE_CONTEXT := 'EMD TRANSACTIONS';
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE1 := p_in_rec.document_number;
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE2 := p_in_rec.party_id;
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE3 := p_in_rec.party_site_id;
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE4 := p_in_rec.party_contact_id;
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE7 := p_in_rec.emd_transaction_id;
  l_cm_line_tbl(1).INTERFACE_LINE_ATTRIBUTE8 := p_in_rec.emd_trx_group_id;


  print_log('l_customer_trx_id: '||l_customer_trx_id);
  print_log('l_line_amount: '||l_line_amount);
  print_log('l_line_credit_flag: '||l_line_credit_flag);
  print_log('l_skip_workflow_flag: '||l_skip_workflow_flag);
  print_log('l_org_id: '||l_org_id);
  print_log('p_in_rec.document_number : '||p_in_rec.document_number);
  print_log('p_in_rec.party_id : '||p_in_rec.party_id);
  print_log('p_in_rec.party_site_id : '||p_in_rec.party_contact_id);
  print_log('p_in_rec.party_contact_id : '||p_in_rec.party_contact_id);


  BEGIN
  SELECT name
  INTO l_batch_source_name
  FROM ra_batch_sources_all
  WHERE batch_source_id = p_in_rec.batch_source_id
  AND  org_id = l_org_id
  AND  Trunc(SYSDATE) BETWEEN start_date AND Nvl(end_date,Trunc(SYSDATE+1));
  EXCEPTION
  WHEN No_Data_Found THEN
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_DEF');
    FND_MESSAGE.SET_TOKEN('BATCH_SOURCE_ID',To_Char(p_in_rec.batch_source_id));
    FND_MSG_PUB.ADD;
    RETURN;
  END;

  print_log('l_batch_source_name: '||l_batch_source_name);


  --Call to AR Activity_application API
  AR_CREDIT_MEMO_API_PUB.create_request (
                  1,                                -- p_api_version
                  p_init_msg_list,                  -- p_init_msg_list
                  p_commit,                         -- p_commit
                  FND_API.G_VALID_LEVEL_FULL,       -- p_validation_level
                  x_return_status,                  -- return status(out)
                  x_msg_count,                      -- message count(out)
                  x_msg_data,                       -- message data(out)
                  l_customer_trx_id,
                  l_line_credit_flag,
                  l_line_amount,
                  l_tax_amount,
                  l_freight_amount,
                  l_cm_reason_code,
                  l_comments,
                  l_orig_trx_number,
                  l_tax_ex_cert_num,
                  l_request_url,
                  l_transaction_url,
                  l_trans_act_url,
                  l_cm_line_tbl,
                  l_skip_workflow_flag,
                  l_credit_method_installments,
                  l_credit_method_rules,
                  l_batch_source_name,
                  l_org_id,
                  x_request_id,
                  l_attribute_rec,
                  l_interface_attribute_rec,
                  l_global_attribute_rec,
                  l_dispute_date);


  IF (x_return_status = fnd_api.g_ret_sts_success)
      AND (x_request_id <> -1) THEN
      l_request_id := x_request_id;
      AR_CREDIT_MEMO_API_PUB.get_request_status( 1.0,
                                                 p_init_msg_list,
                                                 x_msg_count,
                                                 x_msg_data,
                                                 x_return_status,
                                                 l_request_id,
                                                 x_status_meaning,
                                                 x_reason_meaning,
                                                 x_customer_trx_id,
                                                 x_cm_customer_trx_id,
                                                 x_line_amount,
                                                 x_tax_amount,
                                                 x_freight_amount,
                                                 x_line_credits_flag,
                                                 x_created_by,
                                                 x_creation_date,
                                                 x_approval_date,
                                                 x_comments,
                                                 x_cm_line_tbl,
                                                 x_cm_activity_tbl,
                                                 x_cm_notes_tbl);

      print_log('After executing AR API AR_CREDIT_MEMO_API_PUB.create_request to create credit memo');
      print_log('x_cm_customer_trx_id: '||x_cm_customer_trx_id);
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN

          IF (x_cm_customer_trx_id IS NOT NULL) THEN
              SELECT rx.TRX_NUMBER,
                     rl.customer_trx_line_id
                INTO x_out_rec.cm_trx_number,
                     x_out_rec.cm_customer_trx_line_id
              FROM ra_customer_trx_all rx,
                   ra_customer_trx_lines_all rl
              WHERE rx.customer_trx_id = x_cm_customer_trx_id
              AND   rl.customer_trx_id = rx.customer_trx_id;
          END IF;
              x_out_rec.cm_customer_trx_id := x_cm_customer_trx_id;
      ELSE
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','CM_CREATION_FAILED');
          FND_MSG_PUB.ADD;
          RETURN;
      END IF;
  ELSE
      FND_MESSAGE.SET_NAME('PON','CM_CREATION_FAILED');
      FND_MSG_PUB.ADD;
      RETURN;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END create_cm_on_emd_deposit;

-----------------------------------------------------------------------
--Start of Comments
--Name: create_cust_account
--Description : Creates cust account for the supplier party
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_cust_account
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PARTY_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PARTY_INFO_OUT_RECTYPE
  )IS

  l_api_version           NUMBER := 1.0;
  l_api_name              VARCHAR2(50) := 'create_cust_account';
  l_progress              NUMBER;
  l_cust_account_rec      hz_cust_account_v2pub.CUST_ACCOUNT_REC_TYPE;
  l_organization_rec      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE := HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC;
  l_customer_profile_rec  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
  l_create_profile_amt    VARCHAR2(1) := FND_API.G_TRUE;
  x_cust_account_id       hz_cust_accounts.cust_account_id%TYPE;
  x_account_number        hz_cust_accounts.account_number%TYPE;
  x_party_id              hz_cust_accounts.party_id%TYPE;
  x_party_number          hz_parties.party_number%TYPE;
  x_profile_id            hz_customer_profiles.cust_account_profile_id%TYPE;
  l_party_rec             HZ_PARTY_V2PUB.party_rec_type := HZ_PARTY_V2PUB.G_MISS_PARTY_REC;
  l_cust_acct_site_rec    hz_cust_account_site_v2pub.cust_acct_site_rec_type;
  x_msg_data              VARCHAR2(1000);
  x_msg_count             NUMBER;
BEGIN

  l_progress := 100;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

-- Initializating the record types to pass to the API

/* Initializing l_organization_rec.Since we are creating supplier organization as customer we are passing it's party_id
  so that no new organization party is created */
  l_party_rec.party_id := p_in_rec.party_id;  /*Supplier party id */
  l_organization_rec.party_rec := l_party_rec;

  /* Initializing l_cust_account_rec */

  IF (Nvl(HZ_MO_GLOBAL_CACHE.Get_Generate_Customer_Number,'N') <> 'Y') THEN
  /* Bug 8784319 */
    SELECT HZ_ACCOUNT_NUM_S.NEXTVAL INTO l_cust_account_rec.account_number FROM DUAL;
  ELSE
    l_cust_account_rec.account_number := NULL;
  END IF;

  l_cust_account_rec.status := 'A';
  l_cust_account_rec.customer_type :='R';
  l_cust_account_rec.account_name  :=  p_in_rec.party_name; /*Supplier party name */
  l_cust_account_rec.application_id := 222;
  l_cust_account_rec.created_by_module := 'HZ_CPUI';

  l_customer_profile_rec.PARTY_ID := p_in_rec.party_id;
  l_customer_profile_rec.standard_terms := p_in_rec.terms_id;

 --Call to HZ customer account creation API
  HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
                          FND_API.G_FALSE,
                          l_cust_account_rec,
                          l_organization_rec,
                          l_customer_profile_rec,
                          l_create_profile_amt,
                          x_cust_account_id,
                          x_account_number,
                          x_party_id,
                          x_party_number,
                          x_profile_id,
                          x_return_status,
                          x_msg_count,
                          x_msg_data);


  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    FND_MESSAGE.SET_NAME('PON','CUST_ACC_CRE_FAILED');
    FND_MESSAGE.SET_TOKEN('SUPPLIER',p_in_rec.party_name);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_out_rec.party_id := x_party_id;
    x_out_rec.party_number  := x_party_number;
    x_out_rec.cust_account_id := x_cust_account_id;
    x_out_rec.account_number := x_account_number;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END create_cust_account;


-----------------------------------------------------------------------
--Start of Comments
--Name: create_cust_acc_site_and_usage
--Description : Creates cust account site & usage for the cust account
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  p_in_rec
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--  x_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE create_cust_acc_site_and_usage
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PARTY_SITE_INFO_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PARTY_SITE_INFO_OUT_RECTYPE
  )IS

  l_api_version  NUMBER := 1.0;
  l_api_name                  VARCHAR2(50) := 'create_cust_acc_site_and_usage';
  l_progress                  NUMBER;
  l_cust_acct_site_rec        hz_cust_account_site_v2pub.CUST_ACCT_SITE_REC_TYPE;
  x_cust_acct_site_id         HZ_CUST_ACCT_SITES.cust_acct_site_id%TYPE;
  l_cust_site_use_rec         hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
  l_customer_profile_rec      HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
  l_create_profile            VARCHAR2(1) :=  FND_API.G_TRUE;
  l_create_profile_amt        VARCHAR2(1) :=  FND_API.G_TRUE;
  x_site_use_id               HZ_CUST_SITE_USES.site_use_id%TYPE;
  x_site_return_status        VARCHAR2(1);
  x_msg_data                  VARCHAR2(1000);
  x_msg_count                  NUMBER;
BEGIN

  l_progress := 100;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

/* Initializing l_cust_account_site_rec */
  l_cust_acct_site_rec.cust_account_id := p_in_rec.cust_account_id;
  l_cust_acct_site_rec.party_site_id := p_in_rec.party_site_id;
  l_cust_acct_site_rec.status := 'A';
  l_cust_acct_site_rec.org_id := p_in_rec.org_id;
  l_cust_acct_site_rec.created_by_module := 'HZ_CPUI';
  l_cust_acct_site_rec.application_id := 222;

--Call to HZ customer account site creation API
  hz_cust_account_site_v2pub.create_cust_acct_site (
                                        FND_API.G_FALSE,
                                        l_cust_acct_site_rec,
                                        x_cust_acct_site_id,
                                        x_site_return_status,
                                        x_msg_count,
                                        x_msg_data);

  IF (x_site_return_status = fnd_api.g_ret_sts_error) THEN
    x_return_status :=  fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','CUST_ACC_SITE_CRE_FAILED');
    FND_MESSAGE.SET_TOKEN('SUPPLIER',p_in_rec.party_name);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;


  IF (x_site_return_status = fnd_api.g_ret_sts_success) THEN
    x_msg_count := 0;
    x_msg_data := NULL;
    /* Initializing l_cust_account_site_rec,l_customer_profile_rec */
    l_cust_site_use_rec.cust_acct_site_id := x_cust_acct_site_id;
    l_cust_site_use_rec.site_use_code     := 'BILL_TO';
    l_cust_site_use_rec.status := 'A';
    l_cust_site_use_rec.created_by_module := 'HZ_CPUI';
    l_cust_site_use_rec.application_id := 222;
    l_cust_site_use_rec.location :=p_in_rec.location;

    l_customer_profile_rec.party_id := p_in_rec.party_id;
    l_customer_profile_rec.cust_account_id := p_in_rec.cust_account_id;
    l_customer_profile_rec.standard_terms := p_in_rec.terms_id;

    --Call to HZ customer account site use creation API
    hz_cust_account_site_v2pub.create_cust_site_use (
                                          FND_API.G_FALSE,
                                          l_cust_site_use_rec,
                                          l_customer_profile_rec,
                                          l_create_profile,
                                          l_create_profile_amt,
                                          x_site_use_id,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data);

    IF (x_site_return_status = fnd_api.g_ret_sts_error) THEN
      x_return_status :=  fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','CUST_ACC_SITE_USG_CRE_FAILED');
      FND_MESSAGE.SET_TOKEN('SUPPLIER',p_in_rec.party_name);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;

    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      x_out_rec.cust_acct_site_id :=x_cust_acct_site_id;
      x_out_rec.site_use_id := x_site_use_id;
    END IF;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
              Commit;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END create_cust_acc_site_and_usage;


-----------------------------------------------------------------------
--Start of Comments
--Name: post_emd_deposit_transactions
--Description : Creates emd deposit transactions in AR
--Parameters:
--IN:
--  p_api_version
--  p_emd_trx_group_id
--  p_auction_header_id
--OUT:
--  x_process_complete
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE post_emd_deposit_transactions(p_api_version        IN   NUMBER,
                                        p_emd_trx_group_id   IN   NUMBER,
                                        p_auction_header_id  IN   NUMBER,
                                        x_process_complete   OUT  NOCOPY VARCHAR2)
IS
l_org_id  NUMBER;
l_emd_transactions        pon_emd_trx_info_Tbl_Type;
l_payment_type_info       payment_type_info%ROWTYPE;
l_pon_emd_fin_parameters  pon_emd_fin_parameters%ROWTYPE;
l_org_return_status       VARCHAR2(1);
l_found                   BOOLEAN;
l_emd_transactions_info   pon_emd_trx_rec;
x_cust_account_id         hz_cust_accounts.cust_account_id%TYPE := NULL;
x_cust_acct_site_id       hz_cust_acct_sites.cust_acct_site_id%TYPE := NULL;
x_party_name              hz_parties.party_name%TYPE  := NULL;
x_party_site_id           hz_party_sites.party_site_id%TYPE := NULL;
x_party_site_name         hz_party_sites.party_site_name%TYPE := NULL;
x_site_use_id             hz_cust_site_uses.site_use_id%TYPE := NULL;
x_location                hz_locations.city%TYPE := NULL;
x_bank_id                 hz_parties.party_id%TYPE := NULL;
x_branch_id               hz_parties.party_id%TYPE := NULL;
x_acct_id                 IBY_EXT_BANK_ACCOUNTS.EXT_BANK_ACCOUNT_ID%TYPE := NULL;
x_account_assignment_id   NUMBER;
x_card_assignment_id      NUMBER;
l_instrument_assignment_id NUMBER;
l_payment_channel         iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE;
l_payer_rec               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_trxn_attribs_rec        IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
x_payment_trxn_extension_id   NUMBER;
x_response                    IBY_FNDCPT_COMMON_PUB.Result_rec_type;

l_cur_code                VARCHAR2(30);
l_trx_cur_code            VARCHAR2(30);
l_exchange_rate_type      VARCHAR2(30);

l_deposit_in_record       PON_EMD_AR_INTEGRATION_GRP.DEPOSIT_INFO_IN_RECTYPE;
l_deposit_out_record      PON_EMD_AR_INTEGRATION_GRP.DEPOSIT_INFO_OUT_RECTYPE;

l_api_version             CONSTANT NUMBER       := 1.0;
l_api_name                CONSTANT VARCHAR2(50) := 'post_emd_deposit_transactions';

l_progress                NUMBER;
l_count                   NUMBER;

x_msg_count               NUMBER;
x_msg_data                VARCHAR2(4000);
l_msg_data                VARCHAR2(4000);
x_return_status           VARCHAR2(1);

l_searched                VARCHAR2(1);

TRANSACTION_EXCEPTION EXCEPTION;
SETUP_EXCEPTION EXCEPTION;

BEGIN
  -- Standard call to check for call compatibility.
  print_log('Before checking API compatibility');

  x_process_complete := 'FALSE';

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  print_log('After checking API compatibility');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  print_log('before executing mo_global');
  MO_GLOBAL.init('AR');
  print_log('after executing mo_global');


  OPEN emd_transactions_info(p_emd_trx_group_id,
                             p_auction_header_id,
                             G_EMD_DEPOSIT);
  FETCH emd_transactions_info BULK COLLECT INTO  l_emd_transactions;
  IF (l_emd_transactions.Count = 0) THEN
    CLOSE emd_transactions_info;
    x_process_complete :=  'FALSE';
    RETURN;
  ELSE
    CLOSE emd_transactions_info;
  END IF;

  FOR j IN 1 .. l_emd_transactions.Count
  LOOP
    BEGIN
      l_emd_transactions_info := l_emd_transactions(j);
      IF ((l_emd_transactions_info.STATUS_LOOKUP_CODE = 'RECEIVE_ERROR') OR
          (l_emd_transactions_info.ERROR_MESSAGE IS NOT NULL)) THEN
        print_log('Before updating errored record status to receiving');
        update_trx_status_lookup_code(l_emd_transactions_info.emd_transaction_id);
        print_log('After updating errored record status to receiving');
      END IF;

      FND_MSG_PUB.initialize();

      SAVEPOINT pon_emd_deposit_transaction;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      print_log('Started emd deposit transaction Processing of emd transaction id:
       '||l_emd_transactions_info.emd_transaction_id);

      l_progress := 100;

      l_org_id := l_emd_transactions_info.org_id;
      print_log('l_org_id: '||l_org_id);

      BEGIN
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','ORG_CONTEXT_CANNOT_SET');
        FND_MESSAGE.SET_TOKEN('ORG_ID',To_Char(l_org_id));
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END;

      l_progress := 110;
      BEGIN
        verify_finance_installation(x_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After procedure verify_finance_installation');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 120;
      OPEN pon_emd_fin_parameters(l_org_id);
      FETCH pon_emd_fin_parameters INTO l_pon_emd_fin_parameters;
      l_found := pon_emd_fin_parameters%FOUND;
      IF NOT l_found THEN
        CLOSE pon_emd_fin_parameters;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','PON_EMD_FIN_PARAMS_NOT_SETUP');
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      ELSE
        CLOSE pon_emd_fin_parameters;
      END IF;
      print_log('After executing cursor pon_emd_fin_parameters');
      print_log('x_return_status: '||x_return_status);

      l_progress := 130;
      BEGIN
        validate_pon_emd_fin(l_pon_emd_fin_parameters.EMD_FINANCE_INTEGRATION,
                             l_pon_emd_fin_parameters.RA_TRX_TYPE_ID,
                             l_pon_emd_fin_parameters.RA_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.RA_IMPORT_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_INVOICE_ID,
                             l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                             G_EMD_DEPOSIT,
                             l_org_id,
                             x_return_status);
      EXCEPTION
      WHEN OTHERS THEN
	    print_log('Other Exception in validate_pon_emd_fin');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After executing procedure validate_pon_emd_fin');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 140;
      OPEN payment_type_info(l_emd_transactions_info.payment_type_code,
                             l_org_id);
      FETCH payment_type_info INTO l_payment_type_info;
      l_found := payment_type_info%FOUND;
      IF l_found THEN
        CLOSE payment_type_info;
      ELSE
        CLOSE payment_type_info;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','EMD_PAYMENT_TYPE_NOT_SETUP');
        FND_MESSAGE.SET_TOKEN('PTYPE_CODE',l_emd_transactions_info.payment_type_code);
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END IF;
      print_log('After executing cursor payment_type_info');
      print_log('x_return_status: '||x_return_status);

      l_progress := 150;
      BEGIN
        validate_trx_payment_type_info(l_payment_type_info.RECEIPT_METHOD_ID,
                                      l_payment_type_info.REFUND_PAYMENT_METHOD,
                                      l_payment_type_info.PAYMENT_TYPE_CODE,
                                      G_EMD_DEPOSIT,
                                      l_emd_transactions_info.org_id,
                                      x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After executing procedure validate_trx_payment_type_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 160;
      BEGIN
          validate_trx_info(l_emd_transactions_info,
                            G_EMD_DEPOSIT,
                            x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      print_log('After executing procedure validate_trx_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;

      l_progress := 170;
      BEGIN
      get_customer_info(l_emd_transactions_info.trading_partner_id,
                        l_emd_transactions_info.vendor_site_id,
                        l_emd_transactions_info.org_id,
                        l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                        x_cust_account_id,
                        x_cust_acct_site_id,
                        x_party_name,
                        x_party_site_id,
                        x_party_site_name,
                        x_site_use_id,
                        x_location,
                        x_return_status);

      print_log('After executing get_customer_info');
      print_log('x_cust_account_id: '||x_cust_account_id);
      print_log('x_cust_acct_site_id: '||x_cust_acct_site_id);
      print_log('x_party_name: '||x_party_name);
      print_log('x_party_site_id: '||x_party_site_id);
      print_log('x_party_site_name: '||x_party_site_name);
      print_log('x_site_use_id: '||x_site_use_id);
      print_log('x_location: '||x_location);
      print_log('x_return_status: '||x_return_status);

      IF (x_cust_account_id IS NULL OR
          x_cust_acct_site_id IS NULL OR
          x_site_use_id IS NULL) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;

      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;

/*
   Payment methods G_BANK_ACCT_XFER,G_CREDIT_CARD scoped out in the intial release
      IF (l_emd_transactions_info.PAYMENT_TYPE_CODE = G_BANK_ACCT_XFER) THEN
        BEGIN
          l_progress := 180;
          get_bank_info(x_cust_account_id,
                        x_cust_acct_site_id,
                        x_site_use_id,
                        l_emd_transactions_info.org_id,
                        l_emd_transactions_info.trading_partner_id,
                        x_party_site_id,
                        l_emd_transactions_info.country_code,
                        l_emd_transactions_info.bank_name,
                        l_emd_transactions_info.bank_branch_name,
                        l_emd_transactions_info.bank_account_num,
                        l_emd_transactions_info.bank_account_currency,
                        x_bank_id,
                        x_branch_id,
                        x_acct_id,
                        x_account_assignment_id,
                        x_return_status);
          print_log('After excecuting get_bank_info');
          print_log('x_bank_id: '||x_bank_id);
          print_log('x_branch_id: '||x_branch_id);
          print_log('x_acct_id: '||x_acct_id);
          print_log('x_account_assignment_id: '||x_account_assignment_id);
          print_log('x_return_status: '||x_return_status);
          IF (x_account_assignment_id IS NULL) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;

    ELSIF (l_emd_transactions_info.PAYMENT_TYPE_CODE = G_CREDIT_CARD) THEN
      BEGIN
        l_progress := 190;
        get_credit_card_info(x_cust_account_id,
                            x_cust_acct_site_id,
                            x_site_use_id,
                            l_emd_transactions_info.trading_partner_id,
                            x_party_site_id,
                            l_emd_transactions_info.org_id,
                            l_emd_transactions_info.country_code,
                            l_emd_transactions_info.credit_card_num,
                            l_emd_transactions_info.expiry_date,
                            l_emd_transactions_info.name_on_card,
                            l_emd_transactions_info.card_issuer_code,
                            l_emd_transactions_info.purchase_card_flag,
                            l_emd_transactions_info.single_use_flag,
                            x_card_assignment_id,
                            x_return_status);

        print_log('After executing get_credit_card_info');
        print_log('x_card_assignment_id: '||x_card_assignment_id);
        print_log('x_return_status: '||x_return_status);

        IF (x_card_assignment_id IS NULL) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;
    END IF;
*/
    -- Building Record for creating Deposit transaction in Finance
    l_deposit_in_record.party_id := l_emd_transactions_info.trading_partner_id;
    l_deposit_in_record.party_site_id   := x_party_site_id;
    l_deposit_in_record.party_contact_id := l_emd_transactions_info.trading_partner_contact_id;
    l_deposit_in_record.deposit_date := l_emd_transactions_info.transaction_date;
    l_deposit_in_record.vendor_name := l_emd_transactions_info.TRADING_PARTNER_NAME;
    l_deposit_in_record.vendor_site_name := x_party_site_name;
    l_deposit_in_record.vendor_contact_name := l_emd_transactions_info.TRADING_PARTNER_CONTACT_NAME;
    l_deposit_in_record.paying_location := x_location;
    l_deposit_in_record.deposit_amount := l_emd_transactions_info.amount;
    l_deposit_in_record.deposit_currency := l_emd_transactions_info.transaction_currency_code;

    l_cur_code := l_emd_transactions_info.currency_code;
    l_trx_cur_code := l_emd_transactions_info.transaction_currency_code;

    IF (l_cur_code <> l_trx_cur_code) THEN
      l_deposit_in_record.exchange_date := l_emd_transactions_info.exchange_date;
      l_deposit_in_record.exchange_rate_type := l_emd_transactions_info.exchange_rate_type;
      IF (Nvl(UPPER(l_emd_transactions_info.exchange_rate_type),'DUMMY') = 'USER') THEN
        l_deposit_in_record.exchange_rate := l_emd_transactions_info.exchange_rate;
      END IF;
    END IF;

    l_deposit_in_record.receipt_method_id := l_payment_type_info.receipt_method_id;
    l_deposit_in_record.org_id := l_emd_transactions_info.org_id;
    l_deposit_in_record.customer_id := x_cust_account_id;
    l_deposit_in_record.bill_to_site_use_id := x_site_use_id;
    l_deposit_in_record.auction_header_id := l_emd_transactions_info.auction_header_id;
    l_deposit_in_record.document_number := l_emd_transactions_info.document_number;
    l_deposit_in_record.trx_type_id := l_pon_emd_fin_parameters.RA_TRX_TYPE_ID;
    l_deposit_in_record.batch_source_id := l_pon_emd_fin_parameters.RA_BATCH_SOURCE_ID;
    l_deposit_in_record.memo_line_id := l_pon_emd_fin_parameters.memo_line_id;
    l_deposit_in_record.emd_transaction_id := l_emd_transactions_info.emd_transaction_id;
    l_deposit_in_record.emd_trx_group_id := l_emd_transactions_info.emd_trx_group_id;
    l_deposit_in_record.payment_type_code := l_emd_transactions_info.payment_type_code;

    IF (l_emd_transactions_info.payment_type_code IN (G_CASH,G_DEMAND_DRAFT,G_CHECK)) THEN
      l_deposit_in_record.customer_bank_account_id := NULL;
      l_deposit_in_record.payment_trxn_extension_id := NULL;
    END IF;

    IF (l_emd_transactions_info.payment_type_code =G_CHECK)  THEN
      l_deposit_in_record.cheque_number  := l_emd_transactions_info.cheque_number;
      l_deposit_in_record.bank_name := l_emd_transactions_info.bank_name;
      l_deposit_in_record.bank_branch_name := l_emd_transactions_info.bank_branch_name;
      l_deposit_in_record.bank_account_num := l_emd_transactions_info.bank_account_num;
    END IF;
    IF (l_emd_transactions_info.payment_type_code =G_DEMAND_DRAFT)  THEN
      l_deposit_in_record.demand_draft_num  := l_emd_transactions_info.demand_draft_num;
      l_deposit_in_record.payable_at := l_emd_transactions_info.payable_at;
      l_deposit_in_record.bank_name := l_emd_transactions_info.bank_name;
    END IF;

/*
    IF (l_emd_transactions_info.payment_type_code = G_BANK_ACCT_XFER) THEN
      l_instrument_assignment_id := x_account_assignment_id;
      l_payment_channel := 'BANK_ACCT_XFER';
    ELSIF (l_emd_transactions_info.payment_type_code = G_CREDIT_CARD) THEN
      l_instrument_assignment_id := x_card_assignment_id;
      l_payment_channel := 'CREDIT_CARD';
    END IF;
*/
/*
    l_progress := 200;
    IF (l_emd_transactions_info.payment_type_code in (G_BANK_ACCT_XFER,G_CREDIT_CARD)) THEN

      --Building record for creating extension for payment instrument in iby
        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id  := l_emd_transactions_info.trading_partner_id;
        l_payer_rec.Org_Type  := 'OPERATING_UNIT';
        l_payer_rec.Org_Id    := l_emd_transactions_info.org_id;
        l_payer_rec.Cust_Account_Id :=  x_cust_account_id;
        l_payer_rec.Account_Site_Id :=  x_site_use_id;

        l_trxn_attribs_rec.Originating_Application_Id := 396;
        l_trxn_attribs_rec.Order_Id :=  l_emd_transactions_info.auction_header_id;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := l_emd_transactions_info.vendor_id;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := l_emd_transactions_info.vendor_site_id;

        BEGIN
          IBY_FNDCPT_TRXN_PUB.CREATE_TRANSACTION_EXTENSION(1.0,
                                                      FND_API.G_FALSE,
                                                      FND_API.G_FALSE,
                                                      x_return_status,
                                                      x_msg_count,
                                                      x_msg_data,
                                                      l_payer_rec,
                                                      IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                                                      l_payment_channel,
                                                      l_instrument_assignment_id,
                                                      l_trxn_attribs_rec,
                                                      x_payment_trxn_extension_id,
                                                      x_response);

          print_log('After executing create_transaction_extension procedure');
          print_log('x_payment_trxn_extension_id: '||x_payment_trxn_extension_id);
          print_log('x_return_status: '||x_return_status);

          IF (x_payment_trxn_extension_id IS NULL) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;

        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;

        IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
          (x_response.result_code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS)) THEN
          l_deposit_in_record.payment_trxn_extension_id := x_payment_trxn_extension_id;
        END IF;

    END IF;
*/

    l_progress := 210;
    BEGIN
      create_emd_deposit(1.0,
                        FND_API.G_FALSE,
                        FND_API.G_FALSE,
                        x_return_status,
                        l_deposit_in_record,
                        l_deposit_out_record);

      IF (l_deposit_out_record.deposit_trx_id IS NULL) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;
    EXCEPTION
    WHEN No_Data_Found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END;
    print_log('After Executing create_emd_deposit procedure');
    print_log('x_return_status: '||x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE TRANSACTION_EXCEPTION;
    END IF;

    l_progress := 220;
    IF (x_return_status =FND_API.G_RET_STS_SUCCESS AND
        l_deposit_out_record.deposit_trx_number IS NOT NULL AND
        l_deposit_out_record.deposit_trx_id IS NOT NULL) THEN

      -- updating results in pon_emd_transactions
        UPDATE pon_emd_transactions
        SET  CUST_TRX_NUMBER = l_deposit_out_record.deposit_trx_number,
            CUST_TRX_ID = l_deposit_out_record.deposit_trx_id,
            CUST_TRX_LINE_ID = l_deposit_out_record.deposit_trx_line_id,
            POSTED_TO_FINANCE = 'Y',
            STATUS_LOOKUP_CODE = 'RECEIVED'
        WHERE emd_transaction_id = l_emd_transactions_info.emd_transaction_id
        AND   auction_header_id =  l_emd_transactions_info.auction_header_id;
        COMMIT;
    END IF;
  EXCEPTION
  WHEN No_Data_Found THEN
    print_log('inside no data found exception');
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
    l_searched := fnd_msg_pub.delete_msg;
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
    print_log('x_msg_data: '||x_msg_data);
    ROLLBACK TO pon_emd_deposit_transaction;
    update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                x_msg_data);
  WHEN TRANSACTION_EXCEPTION THEN
    print_log('inside trx exception');
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
    l_searched := fnd_msg_pub.delete_msg;
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
    print_log('x_msg_data: '||x_msg_data);

    ROLLBACK TO pon_emd_deposit_transaction;
    update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                x_msg_data);

  WHEN SETUP_EXCEPTION THEN
    print_log('inside setup exception');
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
    l_searched := fnd_msg_pub.delete_msg;
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
    print_log('x_msg_data: '||x_msg_data);
    ROLLBACK TO pon_emd_deposit_transaction;
    update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                x_msg_data);
  WHEN OTHERS THEN
    print_log('inside others exception');
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
    l_searched := fnd_msg_pub.delete_msg;
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
    print_log('x_msg_data: '||x_msg_data);
    ROLLBACK TO pon_emd_deposit_transaction;
    update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                               x_msg_data);
  END;
  END LOOP;
x_process_complete := 'TRUE';
EXCEPTION
WHEN OTHERS THEN
print_log('Error: '||SQLERRM);
x_process_complete := 'FALSE';
END post_emd_deposit_transactions;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_emd_refund_trans
--Description : Creates emd refund transactions in AR
--Parameters:
--IN:
--  p_api_version
--  p_emd_trx_group_id,
--  p_auction_header_id
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE process_emd_refund_trans(p_api_version        IN   NUMBER,
                                   p_emd_trx_group_id   IN   NUMBER,
                                   p_auction_header_id  IN   NUMBER)
IS
l_org_id  NUMBER;
l_org_context             VARCHAR2(1);

l_emd_transactions        pon_emd_trx_info_Tbl_Type;
l_payment_type_info       payment_type_info%ROWTYPE;
l_pon_emd_fin_parameters  pon_emd_fin_parameters%ROWTYPE;
l_org_return_status       VARCHAR2(1);
l_found                   BOOLEAN;
l_emd_transactions_info   pon_emd_trx_rec;

x_parent_trx_number       pon_emd_transactions.CUST_TRX_NUMBER%TYPE;
x_parent_trx_id           pon_emd_transactions.CUST_TRX_ID%TYPE;
x_parent_trx_line_id      pon_emd_transactions.CUST_TRX_LINE_ID%TYPE;
x_org_id                  NUMBER;
l_parent_trx_number       pon_emd_transactions.CUST_TRX_NUMBER%TYPE;
l_parent_trx_id           pon_emd_transactions.CUST_TRX_ID%TYPE;
l_parent_trx_line_id      pon_emd_transactions.CUST_TRX_LINE_ID%TYPE;

x_cust_account_id         hz_cust_accounts.cust_account_id%TYPE := NULL;
x_cust_acct_site_id       hz_cust_acct_sites.cust_acct_site_id%TYPE := NULL;
x_party_name              hz_parties.party_name%TYPE  := NULL;
x_party_site_id           hz_party_sites.party_site_id%TYPE := NULL;
x_party_site_name         hz_party_sites.party_site_name%TYPE := NULL;
x_site_use_id             hz_cust_site_uses.site_use_id%TYPE := NULL;
x_location                hz_locations.city%TYPE := NULL;



x_receipt_num             ar_cash_receipts_all.receipt_number%TYPE;
x_cash_receipt_id         ar_cash_receipts_all.cash_receipt_id%TYPE;
x_receipt_status          ar_cash_receipts_all.status%TYPE;
l_unapply_in_rec          UNAPPLY_INFO_IN_RECTYPE;
l_unapply_out_rec         UNAPPLY_INFO_OUT_RECTYPE;
x_receivable_app_id       ar_receivable_applications.receivable_application_id%TYPE;
x_deposit_payment_type_code pon_emd_transactions.PAYMENT_TYPE_CODE%TYPE;
l_deposit_payment_type_code pon_emd_transactions.PAYMENT_TYPE_CODE%TYPE;

l_cm_in_record            CM_INFO_IN_RECTYPE;
l_cm_out_record           CM_INFO_OUT_RECTYPE;

l_refund_activity_in_rec  REFUND_INFO_IN_RECTYPE;
l_refund_activity_out_rec REFUND_INFO_OUT_RECTYPE;


l_api_version             CONSTANT  NUMBER       := 1.0;
l_api_name                CONSTANT  VARCHAR2(50) := 'process_emd_refund_trans';

x_msg_count               NUMBER;
x_msg_data                VARCHAR2(1000);
l_msg_data                VARCHAR2(1000);
l_count                   NUMBER;
x_return_status           VARCHAR2(1);
l_searched                VARCHAR2(1);

l_progress                NUMBER;

TRANSACTION_EXCEPTION EXCEPTION;
SETUP_EXCEPTION EXCEPTION;

BEGIN

  print_log('Before checking API compatibility');

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  print_log('After checking API compatibility');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  print_log('before executing mo_global');
  MO_GLOBAL.init('AR');
  print_log('after executing mo_global');


  OPEN emd_transactions_info(p_emd_trx_group_id,
                             p_auction_header_id,
                             G_EMD_REFUND);
  FETCH emd_transactions_info BULK COLLECT INTO  l_emd_transactions;
  IF (l_emd_transactions.Count = 0) THEN
    CLOSE emd_transactions_info;
    RETURN;
  ELSE
    CLOSE emd_transactions_info;
  END IF;


  FOR j IN 1 .. l_emd_transactions.Count
  LOOP
    BEGIN
      l_emd_transactions_info := l_emd_transactions(j);

      IF ((l_emd_transactions_info.STATUS_LOOKUP_CODE = 'REFUND_ERROR') OR
          (l_emd_transactions_info.ERROR_MESSAGE IS NOT NULL)) THEN
        print_log('Before updating errored record status to refunding');
        update_trx_status_lookup_code(l_emd_transactions_info.emd_transaction_id);
        print_log('After updating errored record status to refunding');
      END IF;

      FND_MSG_PUB.initialize();

      SAVEPOINT pon_emd_refund_transaction;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      print_log('Started emd refund transaction Processing of emd transaction id:
       '||l_emd_transactions_info.emd_transaction_id);

      l_progress := 100;
      l_org_id := l_emd_transactions_info.org_id;
      print_log('l_org_id: '||l_org_id);

      BEGIN
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','ORG_CONTEXT_CANNOT_SET');
        FND_MESSAGE.SET_TOKEN('ORG_ID',To_Char(l_org_id));
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END;

      l_progress := 110;
      BEGIN
        verify_finance_installation(x_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After procedure verify_finance_installation');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 120;
      OPEN pon_emd_fin_parameters(l_org_id);
      FETCH pon_emd_fin_parameters INTO l_pon_emd_fin_parameters;
      l_found := pon_emd_fin_parameters%FOUND;
      IF NOT l_found THEN
        CLOSE pon_emd_fin_parameters;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','PON_EMD_FIN_PARAMS_NOT_SETUP');
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      ELSE
        CLOSE pon_emd_fin_parameters;
      END IF;
      print_log('After executing cursor pon_emd_fin_parameters');
      print_log('x_return_status: '||x_return_status);

      l_progress := 130;
      BEGIN
        validate_pon_emd_fin(l_pon_emd_fin_parameters.EMD_FINANCE_INTEGRATION,
                             l_pon_emd_fin_parameters.RA_TRX_TYPE_ID,
                             l_pon_emd_fin_parameters.RA_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.RA_IMPORT_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_INVOICE_ID,
                             l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                             G_EMD_REFUND,
                             l_org_id,
                             x_return_status);

	  print_log('validate_pon_emd_fin x_return_status: '||x_return_status);
      EXCEPTION
      WHEN OTHERS THEN
	  print_log('validate_pon_emd_fin Exception');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 140;
	  print_log('l_emd_transactions_info.parent_emd_transaction_id:'||l_emd_transactions_info.parent_emd_transaction_id);
      IF (l_emd_transactions_info.parent_emd_transaction_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('PON','PARENT_EMD_TRX_ID_NULL');
        FND_MSG_PUB.ADD;
        RAISE TRANSACTION_EXCEPTION;
      ELSE
        BEGIN
		  print_log('Begin getTrxInfoFromParentTrx');
          getTrxInfoFromParentTrx(l_emd_transactions_info.parent_emd_transaction_id,
                                  x_parent_trx_number,
                                  x_parent_trx_id,
                                  x_parent_trx_line_id,
                                  x_deposit_payment_type_code,
                                  x_org_id,
                                  x_return_status);
          l_parent_trx_number := x_parent_trx_number;
          l_parent_trx_id := x_parent_trx_id;
          l_parent_trx_line_id := x_parent_trx_line_id;
          l_deposit_payment_type_code := x_deposit_payment_type_code;
          l_org_id := x_org_id;

          print_log('After executing getTrxInfoFromParentTrx procedure');
          print_log('l_parent_trx_number: '||l_parent_trx_number);
          print_log('l_parent_trx_id: '||l_parent_trx_id);
          print_log('l_parent_trx_line_id: '||l_parent_trx_line_id);
          print_log('l_deposit_payment_type_code: '||l_deposit_payment_type_code);
          print_log('l_org_id: '||l_org_id);

          IF (l_parent_trx_id IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE TRANSACTION_EXCEPTION;
          END IF;
        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;
      END IF;

      l_progress := 150;
      OPEN payment_type_info(l_deposit_payment_type_code,
                             l_emd_transactions_info.org_id);
      FETCH payment_type_info INTO l_payment_type_info;
      l_found := payment_type_info%FOUND;
      IF l_found THEN
        CLOSE payment_type_info;
      ELSE
        CLOSE payment_type_info;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','EMD_PAYMENT_TYPE_NOT_SETUP');
        FND_MESSAGE.SET_TOKEN('PTYPE_CODE',l_deposit_payment_type_code);
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END IF;
      print_log('After executing cursor payment_type_info');
      print_log('x_return_status: '||x_return_status);

      l_progress := 160;
      BEGIN
        validate_trx_payment_type_info(l_payment_type_info.RECEIPT_METHOD_ID,
                                       l_payment_type_info.REFUND_PAYMENT_METHOD,
                                       l_payment_type_info.PAYMENT_TYPE_CODE,
                                       G_EMD_REFUND,
                                       l_emd_transactions_info.org_id,
                                       x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After executing procedure validate_trx_payment_type_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 170;
      BEGIN
        validate_trx_info(l_emd_transactions_info,
                          G_EMD_REFUND,
                          x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      print_log('After executing procedure validate_trx_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;

      l_progress := 180;
      BEGIN
        get_customer_info(l_emd_transactions_info.trading_partner_id,
                          l_emd_transactions_info.vendor_site_id,
                          l_emd_transactions_info.org_id,
                          l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                          x_cust_account_id,
                          x_cust_acct_site_id,
                          x_party_name,
                          x_party_site_id,
                          x_party_site_name,
                          x_site_use_id,
                          x_location,
                          x_return_status);

        print_log('After executing get_customer_info');
        print_log('x_cust_account_id: '||x_cust_account_id);
        print_log('x_cust_acct_site_id: '||x_cust_acct_site_id);
        print_log('x_party_name: '||x_party_name);
        print_log('x_party_site_id: '||x_party_site_id);
        print_log('x_party_site_name: '||x_party_site_name);
        print_log('x_site_use_id: '||x_site_use_id);
        print_log('x_location: '||x_location);
        print_log('x_return_status: '||x_return_status);

          IF (x_cust_account_id IS NULL OR
              x_cust_acct_site_id IS NULL OR
              x_site_use_id IS NULL) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;



      l_progress := 190;
      IF ((l_parent_trx_number IS NOT NULL) AND
          (l_parent_trx_id IS NOT NULL) AND
          (l_emd_transactions_info.org_id = x_org_id)) THEN

        --Retriving Receipt Info of the parent transaction
        BEGIN
          getReceiptInfoOfParentTrx(l_parent_trx_id,
                                    l_parent_trx_number,
                                    l_org_id,
                                    x_receipt_num,
                                    x_cash_receipt_id,
                                    x_receivable_app_id,
                                    x_receipt_status,
                                    x_return_status);

          print_log('After executing getReceiptInfoOfParentTrx procedure');
          print_log('x_receipt_num: '||x_receipt_num);
          print_log('x_cash_receipt_id: '||x_cash_receipt_id);
          print_log('x_receivable_app_id: '||x_receivable_app_id);
          print_log('x_receipt_status: '||x_receipt_status);
          print_log('x_return_status: '||x_return_status);

          IF (x_receipt_num IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE TRANSACTION_EXCEPTION;
          END IF;
        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;
      END IF;

      l_progress := 200;
      IF ((x_receipt_num IS NOT NULL) AND
         (x_receipt_status = 'CLEARED')) THEN

      --Building record unapply receipt
        l_unapply_in_rec.cash_receipt_id := x_cash_receipt_id;
        l_unapply_in_rec.transaction_date := l_emd_transactions_info.transaction_date;
        l_unapply_in_rec.deposit_trx_id := x_parent_trx_id;
        l_unapply_in_rec.receivable_app_id := x_receivable_app_id;
        l_unapply_in_rec.org_id := x_org_id;

        BEGIN
          unapply_emd_receipt(1.0,
                              FND_API.G_FALSE,
                              FND_API.G_FALSE,
                              x_return_status,
                              l_unapply_in_rec,
                              l_unapply_out_rec);

          print_log('After executing procedure unapply_emd_receipt');
          print_log('x_return_status: '||x_return_status);

        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;

        l_progress := 210;
        IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        --Building record for creating Credit memo
          l_cm_in_record.document_number := l_emd_transactions_info.document_number;
          l_cm_in_record.customer_trx_id := x_parent_trx_id;
          l_cm_in_record.line_amount := l_emd_transactions_info.amount;
          l_cm_in_record.org_id := l_emd_transactions_info.org_id;
          l_cm_in_record.batch_source_id := l_pon_emd_fin_parameters.ra_batch_source_id;
          l_cm_in_record.customer_trx_line_id := x_parent_trx_line_id;
          l_cm_in_record.party_id := l_emd_transactions_info.trading_partner_id;
          l_cm_in_record.party_site_id := x_party_site_id;
          l_cm_in_record.party_contact_id := l_emd_transactions_info.trading_partner_contact_id;
          l_cm_in_record.emd_transaction_id := l_emd_transactions_info.emd_transaction_id;
          l_cm_in_record.emd_trx_group_id := l_emd_transactions_info.emd_trx_group_id;

          BEGIN
            create_cm_on_emd_deposit( 1.0,
                                      FND_API.G_FALSE,
                                      FND_API.G_FALSE,
                                      x_return_status,
                                      l_cm_in_record,
                                      l_cm_out_record);

            print_log('After executing create_cm_on_emd_deposit');
            print_log('x_return_status: '||x_return_status);

          EXCEPTION
          WHEN No_Data_Found THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE TRANSACTION_EXCEPTION;
        END IF;

        l_progress := 220;
        IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        --Building Record for applying refund activity on unapplied deposit receipt
          l_refund_activity_in_rec.receipt_num := x_receipt_num;
          l_refund_activity_in_rec.cash_receipt_id := x_cash_receipt_id;
          l_refund_activity_in_rec.apply_date := l_emd_transactions_info.transaction_date;
          l_refund_activity_in_rec.apply_gl_date := l_emd_transactions_info.transaction_date;
          l_refund_activity_in_rec.org_id := l_emd_transactions_info.org_id;
          l_refund_activity_in_rec.payment_method_code := l_payment_type_info.REFUND_PAYMENT_METHOD;
          l_refund_activity_in_rec.amount_applied := l_emd_transactions_info.amount;
          l_refund_activity_in_rec.applied_payment_schedule_id := -8;

/*
          IF ((l_payment_type_info.payment_type_code = G_CREDIT_CARD) AND
             (l_payment_type_info.REFUND_PAYMENT_METHOD IS NULL)) THEN
            l_refund_activity_in_rec.applied_payment_schedule_id := -6;
          END IF;
*/
          BEGIN
            refund_activity_on_emd_receipt( 1.0,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            x_return_status,
                                            l_refund_activity_in_rec,
                                            l_refund_activity_out_rec);

            print_log('After executing refund_activity_on_emd_receipt procedure');
            print_log('x_return_status: '||x_return_status);

          EXCEPTION
          WHEN No_Data_Found THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END;
          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;
        END IF;

        l_progress := 230;
        IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
          -- Updating results in pon_emd_transactions
            UPDATE pon_emd_transactions
               SET  CUST_TRX_NUMBER = l_cm_out_record.cm_trx_number,
                    CUST_TRX_ID = l_cm_out_record.cm_customer_trx_id,
                    CUST_TRX_LINE_ID = l_cm_out_record.cm_customer_trx_line_id,
                    APPLICATION_REF_ID   =l_refund_activity_out_rec.APPLICATION_REF_ID,
                    application_ref_type = l_refund_activity_out_rec.application_ref_type,
                    application_ref_num  = l_refund_activity_out_rec.application_ref_num,
                    POSTED_TO_FINANCE = 'Y',
                    STATUS_LOOKUP_CODE = 'REFUNDED'
             WHERE emd_transaction_id = l_emd_transactions_info.emd_transaction_id
               AND   auction_header_id =  l_emd_transactions_info.auction_header_id;
            COMMIT;
        END IF;
      END IF;
    EXCEPTION
    WHEN No_Data_Found THEN
      print_log('inside no data found exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_refund_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN TRANSACTION_EXCEPTION THEN
      print_log('inside trx exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_refund_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN SETUP_EXCEPTION THEN
      print_log('inside setup exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_refund_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN OTHERS THEN
      print_log('inside others exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_refund_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    END;
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
print_log('Error: '||SQLERRM);
END process_emd_refund_trans;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_emd_forfeit_trans
--Description : Creates emd frofeit transactions in AR
--Parameters:
--IN:
--  p_api_version
--  p_emd_trx_group_id
--  p_auction_header_id
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_emd_forfeit_trans(p_api_version        IN   NUMBER,
                                    p_emd_trx_group_id   IN   NUMBER,
                                    p_auction_header_id  IN   NUMBER)
IS
l_org_id  NUMBER;
l_org_context             VARCHAR2(1);

l_emd_transactions        pon_emd_trx_info_Tbl_Type;
l_payment_type_info       payment_type_info%ROWTYPE;
l_pon_emd_fin_parameters  pon_emd_fin_parameters%ROWTYPE;
l_org_return_status       VARCHAR2(1);
l_found                   BOOLEAN;
l_emd_transactions_info   pon_emd_trx_rec;

x_parent_trx_number       pon_emd_transactions.CUST_TRX_NUMBER%TYPE;
x_parent_trx_id           pon_emd_transactions.CUST_TRX_ID%TYPE;
x_parent_trx_line_id      pon_emd_transactions.CUST_TRX_LINE_ID%TYPE;
x_org_id                  NUMBER;
l_parent_trx_number       pon_emd_transactions.CUST_TRX_NUMBER%TYPE;
l_parent_trx_id           pon_emd_transactions.CUST_TRX_ID%TYPE;
l_parent_trx_line_id      pon_emd_transactions.CUST_TRX_LINE_ID%TYPE;

x_receipt_num             ar_cash_receipts_all.receipt_number%TYPE;
x_cash_receipt_id         ar_cash_receipts_all.cash_receipt_id%TYPE;
x_receipt_status          ar_cash_receipts_all.status%TYPE;
x_receivable_app_id       ar_receivable_applications.receivable_application_id%TYPE;

x_deposit_payment_type_code pon_emd_transactions.PAYMENT_TYPE_CODE%TYPE;
l_deposit_payment_type_code pon_emd_transactions.PAYMENT_TYPE_CODE%TYPE;

x_cust_account_id         hz_cust_accounts.cust_account_id%TYPE := NULL;
x_cust_acct_site_id       hz_cust_acct_sites.cust_acct_site_id%TYPE := NULL;
x_party_name              hz_parties.party_name%TYPE := NULL;
x_party_site_id           hz_party_sites.party_site_id%TYPE := NULL;
x_party_site_name         hz_party_sites.party_site_name%TYPE := NULL;
x_site_use_id             hz_cust_site_uses.site_use_id%TYPE := NULL;
x_location                hz_locations.city%TYPE := NULL;

l_inv_trx_type_id         NUMBER;

l_cur_code                VARCHAR2(30);
l_trx_cur_code            VARCHAR2(30);
l_exchange_rate_type      VARCHAR2(30);

l_forfeit_info_in_rec     FORFEIT_INFO_IN_RECTYPE;
l_forfeit_info_out_rec    FORFEIT_INFO_OUT_RECTYPE;

l_api_version             CONSTANT  NUMBER       := 1.0;
l_api_name                CONSTANT  VARCHAR2(50) := 'process_emd_forfeit_transactions';
l_progress                NUMBER;
x_return_status           VARCHAR2(1);

x_msg_count               NUMBER;
x_msg_data                VARCHAR2(1000);
l_msg_data                VARCHAR2(1000);
l_count                   NUMBER;
l_searched                VARCHAR2(1);
l_transactions_count      NUMBER;
l_current_trx_number      NUMBER  := 0;

TRANSACTION_EXCEPTION EXCEPTION;
SETUP_EXCEPTION EXCEPTION;

BEGIN

  print_log('Before checking API compatibility test');


  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  print_log('After checking API compatibility test');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  print_log('before executing mo_global');
  MO_GLOBAL.init('AR');
  print_log('after executing mo_global');


  OPEN emd_transactions_info(p_emd_trx_group_id,
                             p_auction_header_id,
                             G_EMD_FORFEIT);
  FETCH emd_transactions_info BULK COLLECT INTO  l_emd_transactions;
  IF (l_emd_transactions.Count = 0) THEN
    CLOSE emd_transactions_info;
    print_log('No Transactions to process');
    RETURN;
  ELSE
     l_transactions_count :=  l_emd_transactions.Count;
    CLOSE emd_transactions_info;
  END IF;


  FOR j IN 1 .. l_emd_transactions.Count
  LOOP
    BEGIN

      l_emd_transactions_info := l_emd_transactions(j);
      l_current_trx_number := l_current_trx_number + 1;

      IF ((l_emd_transactions_info.STATUS_LOOKUP_CODE = 'FORFEIT_ERROR') OR
         (l_emd_transactions_info.ERROR_MESSAGE IS NOT NULL)) THEN
        print_log('Before updating errored record status to forfeiting');
        update_trx_status_lookup_code(l_emd_transactions_info.emd_transaction_id);
        print_log('After updating errored record status to forfeiting');
      END IF;

      FND_MSG_PUB.initialize();

      SAVEPOINT pon_emd_forfeit_transaction;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      print_log('Started emd forfeit transaction Processing of emd transaction id:
       '||l_emd_transactions_info.emd_transaction_id);

      l_progress := 100;

      l_org_id := l_emd_transactions_info.org_id;
      print_log('l_org_id: '||l_org_id);

      BEGIN
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','ORG_CONTEXT_CANNOT_SET');
        FND_MESSAGE.SET_TOKEN('ORG_ID',To_Char(l_org_id));
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END;

      l_progress := 110;
      BEGIN
        verify_finance_installation(x_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      print_log('After procedure verify_finance_installation');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 120;
      OPEN pon_emd_fin_parameters(l_org_id);
      FETCH pon_emd_fin_parameters INTO l_pon_emd_fin_parameters;
      l_found := pon_emd_fin_parameters%FOUND;
      IF NOT l_found THEN
        CLOSE pon_emd_fin_parameters;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','PON_EMD_FIN_PARAMS_NOT_SETUP');
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      ELSE
        CLOSE pon_emd_fin_parameters;
      END IF;

      print_log('After executing cursor pon_emd_fin_parameters');
      print_log('x_return_status: '||x_return_status);

      l_progress := 130;
      BEGIN
        validate_pon_emd_fin(l_pon_emd_fin_parameters.EMD_FINANCE_INTEGRATION,
                             l_pon_emd_fin_parameters.RA_TRX_TYPE_ID,
                             l_pon_emd_fin_parameters.RA_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.RA_IMPORT_BATCH_SOURCE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_ID,
                             l_pon_emd_fin_parameters.MEMO_LINE_INVOICE_ID,
                             l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                             G_EMD_FORFEIT,
                             l_org_id,
                             x_return_status);

      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 140;
      IF (l_emd_transactions_info.parent_emd_transaction_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('PON','PARENT_EMD_TRX_ID_NULL');
        FND_MSG_PUB.ADD;
        RAISE TRANSACTION_EXCEPTION;
      ELSE
        BEGIN
          getTrxInfoFromParentTrx(l_emd_transactions_info.parent_emd_transaction_id,
                                  x_parent_trx_number,
                                  x_parent_trx_id,
                                  x_parent_trx_line_id,
                                  x_deposit_payment_type_code,
                                  x_org_id,
                                  x_return_status);
          l_parent_trx_number := x_parent_trx_number;
          l_parent_trx_id := x_parent_trx_id;
          l_parent_trx_line_id := x_parent_trx_line_id;
          l_deposit_payment_type_code := x_deposit_payment_type_code;
          l_org_id := x_org_id;

          print_log('After executing getTrxInfoFromParentTrx procedure');
          print_log('l_parent_trx_number: '||l_parent_trx_number);
          print_log('l_parent_trx_id: '||l_parent_trx_id);
          print_log('l_parent_trx_line_id: '||l_parent_trx_line_id);
          print_log('l_deposit_payment_type_code: '||l_deposit_payment_type_code);
          print_log('l_org_id: '||l_org_id);

          IF (l_parent_trx_id IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE TRANSACTION_EXCEPTION;
          END IF;
        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;
      END IF;

      l_progress := 150;
      OPEN payment_type_info(l_deposit_payment_type_code,
                             l_emd_transactions_info.org_id);
      FETCH payment_type_info INTO l_payment_type_info;
      l_found := payment_type_info%FOUND;
      IF l_found THEN
        CLOSE payment_type_info;
      ELSE
        CLOSE payment_type_info;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('PON','EMD_PAYMENT_TYPE_NOT_SETUP');
        FND_MESSAGE.SET_TOKEN('PTYPE_CODE',l_deposit_payment_type_code);
        FND_MSG_PUB.ADD;
        RAISE SETUP_EXCEPTION;
      END IF;

      print_log('After executing cursor payment_type_info');
      print_log('x_return_status: '||x_return_status);

      l_progress := 160;
      BEGIN
        validate_trx_payment_type_info(l_payment_type_info.RECEIPT_METHOD_ID,
                                       l_payment_type_info.REFUND_PAYMENT_METHOD,
                                       l_payment_type_info.PAYMENT_TYPE_CODE,
                                       G_EMD_FORFEIT,
                                       l_emd_transactions_info.org_id,
                                       x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      print_log('After executing procedure validate_trx_payment_type_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;


      l_progress := 170;
      BEGIN
          validate_trx_info(l_emd_transactions_info,
                            G_EMD_FORFEIT,
                            x_return_status);
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;

      print_log('After executing procedure validate_trx_info');
      print_log('x_return_status: '||x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;


      l_progress := 180;
      BEGIN
        get_customer_info(l_emd_transactions_info.trading_partner_id,
                          l_emd_transactions_info.vendor_site_id,
                          l_emd_transactions_info.org_id,
                          l_pon_emd_fin_parameters.PAYMENT_TERMS_ID,
                          x_cust_account_id,
                          x_cust_acct_site_id,
                          x_party_name,
                          x_party_site_id,
                          x_party_site_name,
                          x_site_use_id,
                          x_location,
                          x_return_status);

        print_log('After executing get_customer_info');
        print_log('x_cust_account_id: '||x_cust_account_id);
        print_log('x_cust_acct_site_id: '||x_cust_acct_site_id);
        print_log('x_party_name: '||x_party_name);
        print_log('x_party_site_id: '||x_party_site_id);
        print_log('x_party_site_name: '||x_party_site_name);
        print_log('x_site_use_id: '||x_site_use_id);
        print_log('x_location: '||x_location);
        print_log('x_return_status: '||x_return_status);

          IF (x_cust_account_id IS NULL OR
              x_cust_acct_site_id IS NULL OR
              x_site_use_id IS NULL) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE TRANSACTION_EXCEPTION;
      END IF;


      l_progress := 190;
      IF ((l_parent_trx_number IS NOT NULL) AND
          (l_parent_trx_id IS NOT NULL) AND
          (l_emd_transactions_info.org_id = x_org_id)) THEN

        --Retriving Receipt Info of the parent transaction
        BEGIN
          getReceiptInfoOfParentTrx(l_parent_trx_id,
                                    l_parent_trx_number,
                                    l_org_id,
                                    x_receipt_num,
                                    x_cash_receipt_id,
                                    x_receivable_app_id,
                                    x_receipt_status,
                                    x_return_status);

          print_log('After executing getReceiptInfoOfParentTrx procedure');
          print_log('x_receipt_num: '||x_receipt_num);
          print_log('x_cash_receipt_id: '||x_cash_receipt_id);
          print_log('x_receivable_app_id: '||x_receivable_app_id);
          print_log('x_receipt_status: '||x_receipt_status);
          print_log('x_return_status: '||x_return_status);

          IF (x_receipt_num IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE TRANSACTION_EXCEPTION;
          END IF;
        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE TRANSACTION_EXCEPTION;
        END IF;
      END IF;

      l_progress := 200;
      BEGIN
          SELECT SUBSEQUENT_TRX_TYPE_ID
            INTO l_inv_trx_type_id
            FROM ra_cust_trx_types_all
           WHERE CUST_TRX_TYPE_ID = l_pon_emd_fin_parameters.RA_TRX_TYPE_ID
             AND  org_id = l_org_id;
      EXCEPTION
        WHEN No_Data_Found THEN
          FND_MESSAGE.SET_NAME('PON','INV_TRX_TYPE_NOT_FOUND_IN_AR');
          FND_MESSAGE.SET_TOKEN('INV_TRX_TYPE_ID',To_Char(l_pon_emd_fin_parameters.RA_TRX_TYPE_ID));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('PON','INV_TRX_TYPE_NOT_FOUND_IN_AR');
          FND_MESSAGE.SET_TOKEN('INV_TRX_TYPE_ID',To_Char(l_pon_emd_fin_parameters.RA_TRX_TYPE_ID));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE SETUP_EXCEPTION;
      END IF;

      l_progress := 210;
      IF ((x_receipt_num IS NOT NULL) AND
         (x_receipt_status = 'CLEARED')) THEN
          l_forfeit_info_in_rec.trx_type_id :=  l_inv_trx_type_id;
          l_forfeit_info_in_rec.deposit_trx_id := x_parent_trx_id;
          l_forfeit_info_in_rec.transaction_currency_code := l_emd_transactions_info.transaction_currency_code;

          l_cur_code := l_emd_transactions_info.currency_code;
          l_trx_cur_code := l_emd_transactions_info.transaction_currency_code;
          l_forfeit_info_in_rec.exchange_rate_type := l_emd_transactions_info.exchange_rate_type;
          IF (l_cur_code <> l_trx_cur_code) THEN
            l_forfeit_info_in_rec.exchange_date := l_emd_transactions_info.transaction_date;
          END IF;

	  /* Forfeit Error Bug Start */
	  IF (UPPER(l_emd_transactions_info.exchange_rate_type) = 'USER') THEN
              l_forfeit_info_in_rec.exchange_rate := l_emd_transactions_info.exchange_rate;
          END IF;
  	  /* Forfeit Error Bug End */

          l_forfeit_info_in_rec.party_id := l_emd_transactions_info.trading_partner_id;
          l_forfeit_info_in_rec.party_site_id := x_party_site_id;
          l_forfeit_info_in_rec.site_use_id := x_site_use_id;
          l_forfeit_info_in_rec.party_contact_id := l_emd_transactions_info.trading_partner_contact_id;
          l_forfeit_info_in_rec.transaction_date := l_emd_transactions_info.transaction_date;
          l_forfeit_info_in_rec.cust_account_id  := x_cust_account_id;
          l_forfeit_info_in_rec.cust_acct_site_id := x_cust_acct_site_id;
          l_forfeit_info_in_rec.org_id  :=  l_emd_transactions_info.org_id;
          l_forfeit_info_in_rec.auction_header_id := l_emd_transactions_info.auction_header_id;
          l_forfeit_info_in_rec.document_number :=  l_emd_transactions_info.document_number;
          l_forfeit_info_in_rec.vendor_name  :=  l_emd_transactions_info.TRADING_PARTNER_NAME;
          l_forfeit_info_in_rec.vendor_site_name := x_party_site_name;
          l_forfeit_info_in_rec.vendor_contact_name := l_emd_transactions_info.TRADING_PARTNER_CONTACT_NAME;
          l_forfeit_info_in_rec.amount :=  l_emd_transactions_info.amount;
          l_forfeit_info_in_rec.memo_line_id  := l_pon_emd_fin_parameters.MEMO_LINE_INVOICE_ID;
          l_forfeit_info_in_rec.batch_source_id := l_pon_emd_fin_parameters.RA_IMPORT_BATCH_SOURCE_ID;
          l_forfeit_info_in_rec.payment_term_id := l_pon_emd_fin_parameters.PAYMENT_TERMS_ID;
          l_forfeit_info_in_rec.emd_trx_group_id := l_emd_transactions_info.emd_trx_group_id;
          l_forfeit_info_in_rec.emd_transaction_id := l_emd_transactions_info.emd_transaction_id;
          l_forfeit_info_in_rec.trx_count_in_group := l_transactions_count;
          l_forfeit_info_in_rec.current_trx_number := l_current_trx_number;


          BEGIN
            insert_and_call_autoinvoice(l_forfeit_info_in_rec,
                                        l_emd_transactions,
                                        x_return_status);

            print_log('After executing insert_and_call_autoinvoice');
            print_log('x_return_status: '||x_return_status);

          EXCEPTION
          WHEN No_Data_Found THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END;
          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE TRANSACTION_EXCEPTION;
          END IF;
      END IF;

    EXCEPTION
    WHEN No_Data_Found THEN
      print_log('inside no data found');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_forfeit_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN TRANSACTION_EXCEPTION THEN
      print_log('inside trx exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_forfeit_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN SETUP_EXCEPTION THEN
      print_log('inside setup exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_forfeit_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
    WHEN OTHERS THEN
      print_log('inside others exception');
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_msg_pub.set_search_name('AR','AR_DAPI_SOLD_CUST_DFT');
      l_searched := fnd_msg_pub.delete_msg;
      print_log('x_msg_count: '||x_msg_count);
      IF (x_msg_count > 1) THEN
        l_count := x_msg_count;
        x_msg_data := NULL;
        LOOP
          IF nvl(l_count, 0) > 0 THEN
            l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
            x_msg_data := x_msg_data ||' '|| l_msg_data;
            l_count    := nvl(l_count, 0) - 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      END IF;
      print_log('x_msg_data: '||x_msg_data);
      ROLLBACK TO pon_emd_forfeit_transaction;
      update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);

    END;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN
print_log('Error: '||SQLERRM);
END process_emd_forfeit_trans;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_customer_info
--Description : Retrieves cust account,cust account site,site usage info if
--exists else creates the same
--Parameters:
--IN:
--  p_party_id
--  p_vendor_site_id
--  p_org_id
--  p_payment_terms_id
--OUT:
--  x_cust_account_id
--  x_cust_acct_site_id
--  x_party_name
--  x_party_site_id
--  x_party_site_name
--  x_site_use_id
--  x_location
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_customer_info(p_party_id                  IN  NUMBER,
                            p_vendor_site_id            IN  NUMBER,
                            p_org_id                    IN  NUMBER,
                            p_payment_terms_id          IN  NUMBER,
                            x_cust_account_id           OUT NOCOPY NUMBER,
                            x_cust_acct_site_id         OUT NOCOPY NUMBER,
                            x_party_name                OUT NOCOPY VARCHAR2,
                            x_party_site_id             OUT NOCOPY NUMBER,
                            x_party_site_name           OUT NOCOPY VARCHAR2,
                            x_site_use_id               OUT NOCOPY NUMBER,
                            x_location                  OUT NOCOPY VARCHAR2,
                            x_return_status             OUT NOCOPY VARCHAR2)
IS
cust_in_rec               PARTY_INFO_IN_RECTYPE;
cust_out_rec              PARTY_INFO_OUT_RECTYPE;
cust_site_in_rec          PARTY_SITE_INFO_IN_RECTYPE;
cust_site_out_rec         PARTY_SITE_INFO_OUT_RECTYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    SELECT   hca.cust_account_id,
             hp.party_name
      INTO   x_cust_account_id,
             x_party_name
      FROM   hz_cust_accounts hca,
             hz_parties hp
     WHERE Nvl(hca.customer_type,'I') = 'R'
      AND  hca.party_id = hp.party_id
      AND  hca.account_name = hp.party_name
      AND  hca.party_id = p_party_id
      AND ROWNUM =1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_cust_account_id := NULL;
      SELECT party_name
      INTO x_party_name
      FROM hz_parties
      WHERE party_id =p_party_id;
  END;

  print_log('After verifying existance of cust account');
  print_log('x_cust_account_id'||x_cust_account_id);

IF (Nvl(p_vendor_site_id,-1) <> -1 ) THEN
BEGIN
  SELECT hps.party_site_id,
         hps.party_site_name,
         loc.city
    INTO  x_party_site_id,
          x_party_site_name,
          x_location
  FROM  hz_party_sites hps,
        ap_supplier_sites_all vs,
        hz_locations loc
  WHERE vs.vendor_site_id = p_vendor_site_id
  AND   vs.party_site_id = hps.party_site_id
  AND   hps.location_id = loc.location_id
  AND   hps.party_id = p_party_id
  AND   vs.org_id = p_org_id;
EXCEPTION
WHEN No_Data_Found THEN
   x_return_status := fnd_api.g_ret_sts_error;
   FND_MESSAGE.SET_NAME('PON','SUPPLIER_SITE_NOT_FOUND');

	 FND_MSG_PUB.ADD;
   RETURN;
END;

ELSE
  SELECT hps.party_site_id,
         hps.party_site_name,
         loc.city
    INTO  x_party_site_id,
          x_party_site_name,
          x_location
  FROM  hz_party_sites hps,
        hz_locations loc
  WHERE hps.party_id = p_party_id
  AND   hps.location_id = loc.location_id
  AND  hps.identifying_address_flag = 'Y'
  AND ROWNUM =1;
END IF;

print_log('After checking for existance of vendor site');
print_log('x_party_site_id'||x_party_site_id);
print_log('x_party_site_name'||x_party_site_name);
print_log('x_location'||x_location);

IF (x_cust_account_id IS NOT NULL) THEN

    BEGIN
    SELECT site.cust_acct_site_id,
           USE.site_use_id
    INTO   x_cust_acct_site_id,
           x_site_use_id
    FROM HZ_CUST_ACCT_SITES_ALL site,
         HZ_CUST_SITE_USES_ALL use
    WHERE cust_account_id = x_cust_account_id
    AND  site.org_id = p_org_id
    AND  site.party_site_id = x_party_site_id
    AND  site.cust_acct_site_id = USE.cust_acct_site_id
    AND  USE.org_id = site.org_id
    AND  USE.site_use_code = 'BILL_TO'
    AND  ROWNUM = 1 ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_cust_acct_site_id := NULL;
         x_site_use_id := NULL;
    END;

ELSE
    x_cust_acct_site_id := NULL;
    x_site_use_id := NULL;
END IF;

print_log('After trying to retrieve cust_account_site_id and usuage');
print_log('x_cust_acct_site_id'||x_cust_acct_site_id);
print_log('x_site_use_id'||x_site_use_id);


IF (x_cust_account_id IS NULL) THEN
            cust_in_rec.party_id := p_party_id;
            cust_in_rec.party_name := x_party_name;
            cust_in_rec.terms_id :=  p_payment_terms_id;
            create_cust_account( 1,
                             FND_API.G_FALSE,
                             FND_API.G_FALSE,
                             x_return_status,
                             cust_in_rec,
                             cust_out_rec);
    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
         RETURN;
    END IF;
    cust_site_in_rec.party_id  := p_party_id;
    cust_site_in_rec.party_name := x_party_name;
    cust_site_in_rec.party_site_id   := x_party_site_id;
    cust_site_in_rec.cust_account_id := cust_out_rec.cust_account_id;
    cust_site_in_rec.org_id          := p_org_id;
    cust_site_in_rec.location  := x_location;
    cust_site_in_rec.terms_id :=  p_payment_terms_id;

    print_log('After creating cust account id');
    print_log('cust_out_rec.cust_account_id'||cust_out_rec.cust_account_id);

    create_cust_acc_site_and_usage( 1,
                               FND_API.G_FALSE,
                               FND_API.G_FALSE,
                               x_return_status,
                               cust_site_in_rec,
                               cust_site_out_rec);
    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RETURN;
    END IF;
    x_cust_account_id := cust_out_rec.cust_account_id;
    x_cust_acct_site_id := cust_site_out_rec.cust_acct_site_id;
    x_site_use_id := cust_site_out_rec.site_use_id;

    print_log('After creating cust_acct_site_id and usuage');
    print_log('cust_site_out_rec.cust_acct_site_id'||cust_site_out_rec.cust_acct_site_id);
    print_log('cust_site_out_rec.site_use_id'||cust_site_out_rec.site_use_id);

ELSIF ((x_cust_account_id IS NOT NULL) AND (x_cust_acct_site_id IS NULL)) THEN
    cust_site_in_rec.party_id  := p_party_id;
    cust_site_in_rec.party_name := x_party_name;
    cust_site_in_rec.party_site_id   := x_party_site_id;
    cust_site_in_rec.cust_account_id := x_cust_account_id;
    cust_site_in_rec.org_id := p_org_id;
    cust_site_in_rec.location  := x_location;
    cust_site_in_rec.terms_id :=  p_payment_terms_id;
    create_cust_acc_site_and_usage( 1,
                             FND_API.G_FALSE,
                             FND_API.G_FALSE,
                             x_return_status,
                             cust_site_in_rec,
                             cust_site_out_rec);
    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RETURN;
    END IF;


    x_cust_acct_site_id := cust_site_out_rec.cust_acct_site_id;
    x_site_use_id := cust_site_out_rec.site_use_id;

    print_log('After creating cust_acct_site_id and usuage if cust_account_id is not null');
    print_log('cust_site_out_rec.cust_acct_site_id'||cust_site_out_rec.cust_acct_site_id);
    print_log('cust_site_out_rec.site_use_id'||cust_site_out_rec.site_use_id);


END IF;

IF ((x_cust_account_id IS NOT NULL) AND
    (x_cust_acct_site_id IS NOT NULL) AND
    (x_site_use_id IS NOT NULL)) THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
ELSE
     x_return_status := FND_API.G_RET_STS_ERROR;
END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END get_customer_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_bank_info
--Description : Retrieves bank,branch,bankaccount info if exists else creates the same
--Parameters:
--IN:
--  p_cust_account_id
--  p_cust_acct_site_id
--  p_site_use_id
--  p_org_id
--  p_party_id
--  p_party_site_id
--  p_country_code
--  p_bank_name
--  p_bank_branch_name
--  p_bank_account_num
--  p_accountcurrency
--OUT:
--  x_bank_id
--  x_branch_id
--  x_acct_id
--  x_account_assignment_id
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
/*
PROCEDURE get_bank_info(p_cust_account_id      IN     NUMBER,
                        p_cust_acct_site_id    IN     NUMBER,
                        p_site_use_id          IN     NUMBER,
                        p_org_id               IN     NUMBER,
                        p_party_id             IN     NUMBER,
                        p_party_site_id        IN     NUMBER,
                        p_country_code         IN     VARCHAR2,
                        p_bank_name            IN     VARCHAR2,
                        p_bank_branch_name     IN     VARCHAR2,
                        p_bank_account_num     IN     VARCHAR2,
                        p_accountcurrency      IN     VARCHAR2,
                        x_bank_id              OUT NOCOPY NUMBER,
                        x_branch_id            OUT NOCOPY NUMBER,
                        x_acct_id              OUT NOCOPY NUMBER,
                        x_account_assignment_id   OUT NOCOPY NUMBER,
                        x_return_status        OUT  NOCOPY VARCHAR2
                        )
IS
x_bank_end_date   DATE;
x_branch_end_date DATE;
x_acct_start_date DATE;
x_acct_end_date   DATE;
x_response              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
x_set_payer_response    IBY_FNDCPT_COMMON_PUB.Result_rec_type;
x_inst_response         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
x_pmt_channel_response  IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_ext_bank_rec        IBY_EXT_BANKACCT_PUB.ExtBank_rec_type;
l_ext_branch_rec  IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
l_ext_bank_acct_rec IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
l_profile_value             VARCHAR2(30);

l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
x_payer_attributes    iby_fndcpt_setup_pub.PayerAttributes_rec_type;
x_payer_attribs_id    NUMBER;
l_instrument_exists   VARCHAR2(1) := NULL;
l_assignment_attribs  iby_fndcpt_setup_pub.PmtInstrAssignment_rec_type;
l_instrument        iby_fndcpt_setup_pub.PmtInstrument_rec_type;
l_channel_assignment iby_fndcpt_setup_pub.PmtChannelAssignment_rec_type;
x_channel_assignment_id   NUMBER := NULL;
x_msg_data        VARCHAR2(1000);
x_msg_count       NUMBER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IBY_EXT_BANKACCT_PUB.check_bank_exist(1,
                                        FND_API.G_FALSE,
                                        p_country_code,
                                        p_bank_name,
                                        NULL,
                                        x_return_status,
                                        x_msg_count,
                                        x_msg_data,
                                        x_bank_id,
                                        x_bank_end_date,
                                        x_response);

  IF ((x_return_status =FND_API.G_RET_STS_SUCCESS) AND (x_bank_id IS NOT NULL))THEN
    IBY_EXT_BANKACCT_PUB.check_ext_bank_branch_exist(1,
                                                     FND_API.G_FALSE,
                                                     x_bank_id,
                                                     p_bank_branch_name,
                                                     NULL,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data,
                                                     x_branch_id,
                                                     x_branch_end_date,
                                                     x_response);

     IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND (x_branch_id IS NOT NULL))THEN
        IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(1,
                                                  FND_API.G_FALSE,
                                                  x_bank_id,
                                                  x_branch_id,
                                                  p_bank_account_num,
                                                  NULL,
                                                  NULL,
                                                  p_country_code,
                                                  x_acct_id,
                                                  x_acct_start_date,
                                                  x_acct_end_date,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data,
                                                  x_response);
    END IF;
  END IF;

  fnd_profile.get( name => 'HZ_GENERATE_PARTY_NUMBER', val  => l_profile_value);
  IF (l_profile_value = 'N') THEN
   fnd_profile.put( name => 'HZ_GENERATE_PARTY_NUMBER', val  => 'Y');
  END IF;
  IF (x_bank_id IS NULL) THEN
      l_ext_bank_rec.bank_id := NULL;
      l_ext_bank_rec.bank_name := p_bank_name;
      l_ext_bank_rec.country_code := p_country_code;
      l_ext_bank_rec.institution_type := 'BANK';
      IBY_EXT_BANKACCT_PUB.create_ext_bank(1,
                                           FND_API.G_FALSE,
                                           l_ext_bank_rec,
                                           x_bank_id,
                                           x_return_status,
                                           x_msg_count,
                                           x_msg_data,
                                           x_response);
  END IF;
  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    FND_MESSAGE.set_name( 'PON', 'BANK_CREATION_FAILED' );
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  IF ((x_return_status =FND_API.G_RET_STS_SUCCESS) AND (x_bank_id IS NOT NULL) AND (x_branch_id IS NULL)) THEN
      l_ext_branch_rec.branch_party_id := NULL;
      l_ext_branch_rec.bank_party_id   := x_bank_id;
      l_ext_branch_rec.branch_name     := p_bank_branch_name;
      l_ext_branch_rec.branch_type     := 'ABA';
      iby_ext_bankacct_pub.create_ext_bank_branch(
                                                  1,
                                                  FND_API.G_FALSE,
                                                  l_ext_branch_rec,
                                                  x_branch_id,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data,
                                                  x_response);
  END IF;
  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    FND_MESSAGE.set_name( 'PON', 'BANK_BRANCH_CREATION_FAILED' );
    FND_MESSAGE.SET_TOKEN('BANK',p_bank_name);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  IF ((x_return_status =FND_API.G_RET_STS_SUCCESS)
      AND (x_bank_id IS NOT NULL)
      AND (x_branch_id IS NOT NULL)
      AND (x_acct_id IS NULL)) THEN

    l_ext_bank_acct_rec.bank_account_num   := p_bank_account_num;
    l_ext_bank_acct_rec.bank_id            := x_bank_id;
    l_ext_bank_acct_rec.branch_id          := x_branch_id;
    l_ext_bank_acct_rec.acct_owner_party_id := p_party_id;
    l_ext_bank_acct_rec.country_code     :=  p_country_code;
    l_ext_bank_acct_rec.currency         :=  p_accountcurrency;

    iby_ext_bankacct_pub.create_ext_bank_acct(
                                              1,
                                              FND_API.G_FALSE,
                                              l_ext_bank_acct_rec,
                                              x_acct_id,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data,
                                              x_response);
  END IF;

  IF (l_profile_value = 'N') THEN
    fnd_profile.put(
          name => 'HZ_GENERATE_PARTY_NUMBER',
          val  => 'N');
  END IF;

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    FND_MESSAGE.set_name( 'PON', 'BANK_ACCOUNT_CREATION_FAILED' );
    FND_MESSAGE.SET_TOKEN('BANK', p_bank_name);
    FND_MESSAGE.SET_TOKEN('BRANCH',p_bank_branch_name);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  l_payer.Payment_Function := 'CUSTOMER_PAYMENT';
  l_payer.Party_Id  := p_party_id;
  l_payer.Org_Type  := 'OPERATING_UNIT';
  l_payer.Org_Id    :=  p_org_id;
  l_payer.Cust_Account_Id :=  p_cust_account_id;
  l_payer.Account_Site_Id := p_site_use_id;


  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes(1.0,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data,
                                            l_payer,
                                            x_payer_attributes,
                                            x_payer_attribs_id,
                                            x_set_payer_response);
  END IF;

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RETURN;
  END IF;

  IF (x_payer_attribs_id IS NULL) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
  END IF;


  IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
      (x_set_payer_response.result_code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS)) THEN
    l_channel_assignment.Pmt_Channel_Code := 'BANK_ACCT_XFER';
    IBY_FNDCPT_SETUP_PUB.Set_Payer_Default_Pmt_Channel
                                                ( 1.0,
                                                  FND_API.G_FALSE,
                                                  FND_API.G_FALSE,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data,
                                                  l_payer,
                                                  l_channel_assignment,
                                                  x_channel_assignment_id,
                                                  x_pmt_channel_response);
  END IF;

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    RETURN;
  END IF;

  IF (x_channel_assignment_id IS NULL) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
  END IF;


  IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
    (x_pmt_channel_response.result_code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS)) THEN
      BEGIN
                 SELECT instrument_payment_use_id
                   INTO x_account_assignment_id
                   FROM iby_pmt_instr_uses_all
                  WHERE payment_flow = 'FUNDS_CAPTURE'
                    AND ext_pmt_party_id = x_payer_attribs_id
                    AND instrument_id = x_acct_id;
     EXCEPTION
      WHEN No_Data_Found THEN
         l_instrument_exists := 'N';
     END;
  END IF;


  IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
       (NVL(l_instrument_exists,'N') = 'N')) THEN
    l_instrument.instrument_type := 'BANKACCOUNT';
    l_instrument.instrument_id := x_acct_id;
    l_assignment_attribs.instrument := l_instrument;
    l_assignment_attribs.start_date := Trunc(SYSDATE);

    IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(1.0,
                                                   FND_API.G_FALSE,
                                                   FND_API.G_FALSE,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data,
                                                   l_payer,
                                                   l_assignment_attribs,
                                                   x_account_assignment_id,
                                                   x_inst_response);
    END IF;

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RETURN;
  END IF;

  IF (x_account_assignment_id IS NULL) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END get_bank_info;
*/
-----------------------------------------------------------------------
--Start of Comments
--Name: get_credit_card_info
--Description : Retrieves credit card info if exists else creates the same
--Parameters:
--IN:
--  p_cust_account_id
--  p_cust_acct_site_id
--  p_site_use_id
--  p_party_id
--  p_party_site_id
--  p_org_id
--  p_country_code
--  p_credit_card_num
--  p_expiry_date
--  p_name_on_card
--  p_card_issuer_code
--  p_purchase_card_flag
--  p_single_use_flag
--OUT:
--  x_card_assignment_id
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
/*
PROCEDURE get_credit_card_info(p_cust_account_id      IN     NUMBER,
                               p_cust_acct_site_id    IN     NUMBER,
                               p_site_use_id          IN     NUMBER,
                               p_party_id             IN     NUMBER,
                               p_party_site_id        IN     NUMBER,
                               p_org_id               IN     NUMBER,
                               p_country_code         IN     VARCHAR2,
                               p_credit_card_num      IN     VARCHAR2,
                               p_expiry_date          IN     DATE,
                               p_name_on_card         IN     VARCHAR2,
                               p_card_issuer_code     IN     VARCHAR2,
                               p_purchase_card_flag   IN     VARCHAR2,
                               p_single_use_flag      IN     VARCHAR2,
                               x_card_assignment_id   OUT NOCOPY    NUMBER,
                               x_return_status        OUT NOCOPY   VARCHAR2)
IS
l_commit                      VARCHAR2(1);
l_owner_id                    iby_creditcard.card_owner_id%TYPE;
l_holder_name                 iby_creditcard.chname%TYPE;
l_billing_address_id          iby_creditcard.addressid%TYPE;
l_address_type                VARCHAR2(1);
l_billing_zip                 iby_creditcard.billing_addr_postal_code%TYPE;
l_billing_country             iby_creditcard.bill_addr_territory_code%TYPE;
l_card_number                 iby_creditcard.ccnumber%TYPE;
l_expiry_date                 iby_creditcard.expirydate%TYPE;
l_instr_type                  iby_creditcard.instrument_type%TYPE;
l_pcard_flag                  iby_creditcard.purchasecard_flag%TYPE;
l_pcard_type                  iby_creditcard.purchasecard_subtype%TYPE;
l_issuer                      iby_creditcard.card_issuer_code%TYPE;
l_fi_name                     iby_creditcard.finame%TYPE;
l_single_use                  iby_creditcard.single_use_flag%TYPE;
l_info_only                   iby_creditcard.information_only_flag%TYPE;
l_purpose                     iby_creditcard.card_purpose%TYPE;
l_desc                        iby_creditcard.description%TYPE;
l_active_flag                 iby_creditcard.active_flag%TYPE;
l_inactive_date               iby_creditcard.inactive_date%TYPE;
l_sys_sec_key                 iby_security_pkg.DES3_KEY_TYPE;
l_attribute_category          iby_creditcard.attribute_category%TYPE;
l_attribute1	               	iby_creditcard.attribute1%TYPE;
l_attribute2	               	iby_creditcard.attribute2%TYPE;
l_attribute3	              	iby_creditcard.attribute3%TYPE;
l_attribute4	               	iby_creditcard.attribute4%TYPE;
l_attribute5	               	iby_creditcard.attribute5%TYPE;
l_attribute6	               	iby_creditcard.attribute6%TYPE;
l_attribute7	               	iby_creditcard.attribute7%TYPE;
l_attribute8	               	iby_creditcard.attribute8%TYPE;
l_attribute9	               	iby_creditcard.attribute9%TYPE;
l_attribute10	              	iby_creditcard.attribute10%TYPE;
l_attribute11	              	iby_creditcard.attribute11%TYPE;
l_attribute12	              	iby_creditcard.attribute12%TYPE;
l_attribute13	              	iby_creditcard.attribute13%TYPE;
l_attribute14	              	iby_creditcard.attribute14%TYPE;
l_attribute15	              	iby_creditcard.attribute15%TYPE;
l_attribute16	              	iby_creditcard.attribute16%TYPE;
l_attribute17	              	iby_creditcard.attribute17%TYPE;
l_attribute18	              	iby_creditcard.attribute18%TYPE;
l_attribute19	              	iby_creditcard.attribute19%TYPE;
l_attribute20	              	iby_creditcard.attribute20%TYPE;
l_attribute21	              	iby_creditcard.attribute21%TYPE;
l_attribute22	              	iby_creditcard.attribute22%TYPE;
l_attribute23	              	iby_creditcard.attribute23%TYPE;
l_attribute24	              	iby_creditcard.attribute24%TYPE;
l_attribute25	              	iby_creditcard.attribute25%TYPE;
l_attribute26	                iby_creditcard.attribute26%TYPE;
l_attribute27	              	iby_creditcard.attribute27%TYPE;
l_attribute28	                iby_creditcard.attribute28%TYPE;
l_attribute29	              	iby_creditcard.attribute29%TYPE;
l_attribute30	              	iby_creditcard.attribute30%TYPE;
x_result_code                 VARCHAR2(1);
x_instr_id                    iby_creditcard.instrid%TYPE;

l_card_exists                 VARCHAR2(1);

l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
x_payer_attributes    iby_fndcpt_setup_pub.PayerAttributes_rec_type;
x_payer_attribs_id    NUMBER;
l_instrument_exists   VARCHAR2(1) := NULL;
l_assignment_attribs  iby_fndcpt_setup_pub.PmtInstrAssignment_rec_type;
l_instrument        iby_fndcpt_setup_pub.PmtInstrument_rec_type;
l_channel_assignment iby_fndcpt_setup_pub.PmtChannelAssignment_rec_type;
x_channel_assignment_id   NUMBER := NULL;

x_set_payer_response    IBY_FNDCPT_COMMON_PUB.Result_rec_type;
x_inst_response         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
x_pmt_channel_response  IBY_FNDCPT_COMMON_PUB.Result_rec_type;

l_instrument_assignment_id NUMBER;
x_msg_count   NUMBER;
x_msg_data    VARCHAR2(1000);

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
      SELECT cc.instrid,
             cc.expirydate,
             'Y'
      INTO x_instr_id,
           l_expiry_date,
           l_card_exists
      FROM IBY_CREDITCARD cc,
           HZ_PARTIES hzp,
           HZ_PARTY_SITES hzps,
           HZ_PARTY_SITE_USES hzpsu,
           IBY_CREDITCARD_ISSUERS_VL ccissuers
    WHERE ccissuers.card_issuer_code = cc.card_issuer_code
      AND cc.CARD_OWNER_ID = hzp.party_id
      AND cc.ADDRESSID = hzpsu.party_site_use_id(+)
      AND hzpsu.party_site_id = hzps.party_site_id(+)
      AND cc.CCNUMBER = p_credit_card_num
      AND cc.CARD_ISSUER_CODE = p_card_issuer_code
      AND cc.CHNAME = p_name_on_card
      AND cc.card_owner_id = p_party_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_card_exists := 'N';
  END;
IF (Nvl(l_card_exists,'N') = 'Y' AND
    Nvl(l_expiry_date,Trunc(SYSDATE)) <  Trunc(SYSDATE)) THEN
  x_return_status := fnd_api.g_ret_sts_error;
  FND_MESSAGE.set_name( 'PON', 'CREDIT_CARD_EXPIRED' );
  FND_MESSAGE.SET_TOKEN('CCNUM',To_Char(p_credit_card_num));
  FND_MSG_PUB.ADD;
  RETURN;
END IF;

IF (Nvl(l_card_exists,'N') = 'N') THEN
  l_owner_id := p_party_id;
  l_holder_name := p_name_on_card;
  l_billing_address_id := p_site_use_id;
  l_address_type := 'U';
  l_card_number := p_credit_card_num;
  l_expiry_date := p_expiry_date;
  l_instr_type := 'CREDITCARD';
  IF (Nvl(p_purchase_card_flag,'N') = 'N') THEN
    l_pcard_flag := 'N';
  ELSE
    l_pcard_flag := 'Y';
  END IF;

  IF (Nvl(l_single_use,'N') = 'N') THEN
    l_single_use := 'N';
  ELSE
    l_single_use := 'Y';
  END IF;
  l_active_flag := 'Y';
  l_issuer := p_card_issuer_code;

  IBY_CREDITCARD_PKG.Create_Card(FND_API.G_FALSE,
                                l_owner_id,
                                l_holder_name,
                                l_billing_address_id,
                                l_address_type,
                                l_billing_zip,
                                l_billing_country,
                                l_card_number,
                                l_expiry_date,
                                l_instr_type,
                                l_pcard_flag,
                                l_pcard_type,
                                l_issuer,
                                l_fi_name,
                                l_single_use,
                                l_info_only,
                                l_purpose,
                                l_desc,
                                l_active_flag,
                                l_inactive_date,
                                l_sys_sec_key,
                                l_attribute_category,
                                l_attribute1,
                                l_attribute2,
                                l_attribute3,
                                l_attribute4,
                                l_attribute5,
                                l_attribute6,
                                l_attribute7,
                                l_attribute8,
                                l_attribute9,
                                l_attribute10,
                                l_attribute11,
                                l_attribute12,
                                l_attribute13,
                                l_attribute14,
                                l_attribute15,
                                l_attribute16,
                                l_attribute17,
                                l_attribute18,
                                l_attribute19,
                                l_attribute20,
                                l_attribute21,
                                l_attribute22,
                                l_attribute23,
                                l_attribute24,
                                l_attribute25,
                                l_attribute26,
                                l_attribute27,
                                l_attribute28,
                                l_attribute29,
                                l_attribute30,
                                x_result_code,
                                x_instr_id);
END IF;


IF (x_instr_id IS NULL) THEN
  IF (x_result_code = iby_creditcard_pkg.G_RC_INVALID_CCNUMBER) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.set_name( 'PON', 'CREDIT_CARD_NUMBER_NOT_VALID' );
    FND_MESSAGE.SET_TOKEN('CCNUM',l_card_number);
    FND_MSG_PUB.ADD;
    RETURN;
  ELSIF (x_result_code = iby_creditcard_pkg.G_RC_INVALID_CCEXPIRY) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.set_name( 'PON', 'CREDIT_CARD_EXPIRED' );
    FND_MESSAGE.SET_TOKEN('CCNUM',l_card_number);
    FND_MSG_PUB.ADD;
    RETURN;
  ELSIF (x_result_code = iby_creditcard_pkg.G_RC_INVALID_CARD_ISSUER) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.set_name( 'PON', 'CREDIT_CARD_ISSUER_NOT_VALID' );
    FND_MESSAGE.SET_NAME('CCISSUER',l_issuer);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
END IF;

l_payer.Payment_Function := 'CUSTOMER_PAYMENT';
l_payer.Party_Id  := p_party_id;
l_payer.Org_Type  := 'OPERATING_UNIT';
l_payer.Org_Id    :=  p_org_id;
l_payer.Cust_Account_Id :=  p_cust_account_id;
l_payer.Account_Site_Id := p_site_use_id;

IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes(1.0,
                                          FND_API.G_FALSE,
                                          FND_API.G_FALSE,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          l_payer,
                                          x_payer_attributes,
                                          x_payer_attribs_id,
                                          x_set_payer_response);

IF (x_return_status = fnd_api.g_ret_sts_error) THEN
  RETURN;
END IF;
IF (x_payer_attribs_id IS NULL) THEN
  x_return_status := fnd_api.g_ret_sts_error;
  RETURN;
END IF;


IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
    (x_set_payer_response.result_code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS)) THEN
  l_channel_assignment.Pmt_Channel_Code := 'CREDIT_CARD';
  IBY_FNDCPT_SETUP_PUB.Set_Payer_Default_Pmt_Channel
                                              ( 1.0,
                                                FND_API.G_FALSE,
                                                FND_API.G_FALSE,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data,
                                                l_payer,
                                                l_channel_assignment,
                                                x_channel_assignment_id,
                                                x_pmt_channel_response);

END IF;

IF (x_return_status = fnd_api.g_ret_sts_error) THEN
  RETURN;
END IF;

IF (x_channel_assignment_id IS NULL) THEN
  x_return_status := fnd_api.g_ret_sts_error;
  RETURN;
END IF;


IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
    (x_pmt_channel_response.result_code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS)) THEN
      BEGIN
                 SELECT instrument_payment_use_id
                   INTO x_card_assignment_id
                   FROM iby_pmt_instr_uses_all
                  WHERE payment_flow = 'FUNDS_CAPTURE'
                    AND ext_pmt_party_id = x_payer_attribs_id
                    AND instrument_id = x_instr_id;
     EXCEPTION
      WHEN No_Data_Found THEN
         l_instrument_exists := 'N';
     END;
END IF;


IF ((x_return_status = FND_API.G_RET_STS_SUCCESS) AND
     (NVL(l_instrument_exists,'N') = 'N')) THEN
  l_instrument.instrument_type := 'CREDITCARD';
  l_instrument.instrument_id := x_instr_id;
  l_assignment_attribs.instrument := l_instrument;
  l_assignment_attribs.start_date := Trunc(SYSDATE);

 IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(1.0,
                                                 FND_API.G_FALSE,
                                                 FND_API.G_FALSE,
                                                 x_return_status,
                                                 x_msg_count,
                                                 x_msg_data,
                                                 l_payer,
                                                 l_assignment_attribs,
                                                 x_card_assignment_id,
                                                 x_inst_response);
END IF;

IF (x_return_status = fnd_api.g_ret_sts_error) THEN
  RETURN;
END IF;

IF (x_card_assignment_id IS NULL) THEN
  x_return_status := fnd_api.g_ret_sts_error;
  RETURN;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := fnd_api.g_ret_sts_error;
END get_credit_card_info;
*/
-----------------------------------------------------------------------
--Start of Comments
--Name: getTrxInfoFromParentTrx
--Description : Retrieves deposit transaction info
--Parameters:
--IN:
--  p_parent_emd_transaction_id
--  p_parent_trx_number
--  p_org_id
--OUT:
--  x_parent_trx_number
--  x_parent_trx_id
--  x_parent_trx_line_id
--  x_deposit_payment_type_code
--  x_org_id
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE getTrxInfoFromParentTrx(p_parent_emd_transaction_id IN   NUMBER,
                                  x_parent_trx_number         OUT NOCOPY pon_emd_transactions.CUST_TRX_NUMBER%TYPE,
                                  x_parent_trx_id             OUT NOCOPY pon_emd_transactions.CUST_TRX_ID%TYPE,
                                  x_parent_trx_line_id        OUT NOCOPY pon_emd_transactions.CUST_TRX_LINE_ID%TYPE,
                                  x_deposit_payment_type_code OUT NOCOPY VARCHAR2,
                                  x_org_id                    OUT NOCOPY NUMBER,
                                  x_return_status             OUT NOCOPY VARCHAR2)
IS

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  SELECT CUST_TRX_NUMBER,
         CUST_TRX_ID,
         CUST_TRX_LINE_ID,
         ORG_ID,
         PAYMENT_TYPE_CODE
  INTO  x_parent_trx_number,
        x_parent_trx_id,
        x_parent_trx_line_id,
        x_org_id,
        x_deposit_payment_type_code
  FROM pon_emd_transactions
  WHERE emd_transaction_id = p_parent_emd_transaction_id;

EXCEPTION
WHEN No_Data_Found THEN
  FND_MESSAGE.SET_NAME('PON','DEPOSIT_TRX_NOT_FOUND');
  FND_MSG_PUB.ADD;
  x_return_status := fnd_api.g_ret_sts_error;
END getTrxInfoFromParentTrx;

-----------------------------------------------------------------------
--Start of Comments
--Name: getReceiptInfoOfParentTrx
--Description : gets receipt info of the parent deposit transaction. Required to
-- decide whether to allow forfeit/refund transaction.
--Parameters:
--IN:
--  p_parent_trx_id
--  p_parent_trx_number
--  p_org_id
--OUT:
--  x_cash_receipt_id
--  x_receivable_app_id
--  x_receipt_status
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

------------------------------------------------------------------------

PROCEDURE getReceiptInfoOfParentTrx(p_parent_trx_id         IN    NUMBER,
                                    p_parent_trx_number   IN    VARCHAR2,
                                    p_org_id              IN    NUMBER,
                                    x_receipt_num         OUT NOCOPY  VARCHAR2,
                                    x_cash_receipt_id     OUT NOCOPY  NUMBER,
                                    x_receivable_app_id   OUT NOCOPY  NUMBER,
                                    x_receipt_status      OUT NOCOPY  VARCHAR2,
                                    x_return_status       OUT NOCOPY  VARCHAR2)
IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
  SELECT  Max(acr.cash_receipt_id),
          Max(arp.receivable_application_id)
    INTO  x_cash_receipt_id,
          x_receivable_app_id
    from  ar_receivable_applications_all  arp,
          ra_customer_trx_all rct,
          ra_cust_trx_types_all ctyp,
          ar_cash_receipts_all  acr
   where  arp.applied_customer_trx_id = p_parent_trx_id
     AND  arp.org_id = p_org_id
     AND  arp.status = 'APP'
     AND  arp.applied_customer_trx_id = rct.customer_trx_id
     AND  arp.org_id = rct.org_id
     AND  rct.CUST_TRX_TYPE_ID  = ctyp.CUST_TRX_TYPE_ID
     AND  rct.org_id = ctyp.org_id
     AND  ctyp.type = 'DEP'
     AND  arp.cash_receipt_id= acr.cash_receipt_id
     AND  arp.amount_applied > 0;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','RECEIPT_NOT_CRE_FOR_DEPOSIT');
    FND_MESSAGE.SET_TOKEN('DEPOSIT_TRX_NUM',p_parent_trx_number);
    FND_MSG_PUB.ADD;
    x_receipt_num := NULL;
    x_cash_receipt_id := NULL;
    x_receipt_status := NULL;
    RETURN;
  WHEN TOO_MANY_ROWS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END;
  IF (x_cash_receipt_id IS NOT NULL) THEN
    BEGIN
      SELECT  acr.receipt_number,
              acrh.status
        INTO  x_receipt_num,
              x_receipt_status
        FROM  ar_cash_Receipt_history_all acrh,
              ar_cash_receipts_all  acr
      WHERE   acrh.cash_receipt_id =acr.cash_receipt_id
        AND   acrh.current_record_flag = 'Y'
        AND   acrh.status = 'CLEARED'
        AND   acr.cash_receipt_id = x_cash_receipt_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('PON','RECEIPT_NOT_CLEARED');
      FND_MESSAGE.SET_TOKEN('DEPOSIT_TRX_NUM',p_parent_trx_number);
      FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',x_receipt_num);
      FND_MSG_PUB.ADD;
      x_receipt_num := NULL;
      x_cash_receipt_id := NULL;
      x_receipt_status := NULL;
      RETURN;
    WHEN TOO_MANY_ROWS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_receipt_num := NULL;
  x_cash_receipt_id := NULL;
  x_receipt_status := NULL;
WHEN TOO_MANY_ROWS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END getReceiptInfoOfParentTrx;

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_trx_info
--Description : Validates transaction info like transaction,currency
--Parameters:
--IN:
--  p_emd_transaction_rec
--  p_transaction_type_code
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_trx_info(p_emd_transaction_rec       IN  pon_emd_trx_rec,
                            p_transaction_type_code     IN  VARCHAR2,
                            x_return_status             OUT NOCOPY VARCHAR2)
IS
l_module_name VARCHAR2(20);
l_module_version VARCHAR2(1);
l_exchange_rate_type  ra_customer_trx.exchange_rate_type%TYPE;
l_exchange_rate       ra_customer_trx.exchange_rate%TYPE;
l_org_id    NUMBER;
l_period_name gl_period_statuses.period_name%TYPE;
l_auction_status pon_auction_headers_all.AUCTION_STATUS%TYPE;
l_document_num  pon_auction_headers_all.document_number%TYPE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        SELECT  ORG_ID,
                AUCTION_STATUS,
                DOCUMENT_NUMBER
          INTO  l_org_id,
                l_auction_status,
                l_document_num
          FROM  PON_AUCTION_HEADERS_ALL
         WHERE  AUCTION_HEADER_ID = p_emd_transaction_rec.auction_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.SET_NAME('PON','NEGOTIATION_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('AUCTION',l_document_num);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    IF (l_auction_status <> 'ACTIVE') THEN
    IF (p_transaction_type_code NOT IN (G_EMD_FORFEIT,G_EMD_REFUND))
    THEN
      FND_MESSAGE.SET_NAME('PON','NEGOTIATION_NOT_ACTIVE');
      FND_MESSAGE.SET_TOKEN('AUCTION',l_document_num);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    END IF;


    IF (p_emd_transaction_rec.transaction_date IS NULL ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name( 'PON', 'TRX_DATE_IS_NULL' );
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
/*
Relaxing the validation after discussing with PM
    IF (p_transaction_type_code = G_EMD_DEPOSIT) THEN
      IF (p_emd_transaction_rec.emd_due_date IS NOT null) THEN
        IF NOT (p_emd_transaction_rec.transaction_date <= p_emd_transaction_rec.emd_due_date) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.set_name( 'PON', 'TRX_DATE_EXC_EMD_DUE_DATE' );
          FND_MSG_PUB.ADD;
          RETURN;
        END IF;
      END IF;
    END IF;
*/
    IF (p_transaction_type_code = G_EMD_DEPOSIT) THEN
      IF (p_emd_transaction_rec.emd_amount IS null) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.set_name( 'PON', 'EMD_AMT_NULL_ON_NEG' );
          FND_MESSAGE.SET_TOKEN('AUCTION',l_document_num);
          FND_MSG_PUB.ADD;
          RETURN;
      END IF;
    END IF;

    print_log('Calling AR API arp_util.is_gl_date_valid to validate gl_date');
    print_log('Set of books id: '||ARP_GLOBAL.sysparam.set_of_books_id);
    print_log('transaction_date: '||To_Char(p_emd_transaction_rec.transaction_date));
    BEGIN
      IF NOT (arp_util.is_gl_date_valid(p_emd_transaction_rec.transaction_date)) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name( 'PON', 'TRX_DATE_NOT_IN_GL_PERIOD_O_F' );
        FND_MESSAGE.set_token('TRX_DATE',TO_CHAR(p_emd_transaction_rec.transaction_date));
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

    EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name( 'PON', 'TRX_DATE_NOT_IN_GL_PERIOD_O_F' );
        FND_MESSAGE.set_token('TRX_DATE',TO_CHAR(p_emd_transaction_rec.transaction_date));
        FND_MSG_PUB.ADD;
        RETURN;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name( 'PON', 'TRX_DATE_NOT_IN_GL_PERIOD_O_F' );
        FND_MESSAGE.set_token('TRX_DATE',TO_CHAR(p_emd_transaction_rec.transaction_date));
        FND_MSG_PUB.ADD;
        RETURN;
    END;
-- Checking AP open period also in the case of refund.
  IF (p_transaction_type_code = G_EMD_REFUND) THEN
    BEGIN
        SELECT period_name
        INTO l_period_name
        FROM gl_period_statuses
       WHERE application_id = 200
         AND set_of_books_id = ARP_GLOBAL.sysparam.set_of_books_id
         AND trunc(p_emd_transaction_rec.transaction_date)
             between start_date and END_date
         AND closing_status in ('O', 'F')
         AND NVL(adjustment_period_flag, 'N') = 'N';
    EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name( 'PON', 'TRX_DATE_NOT_IN_AP_PERIOD_O_F' );
        FND_MESSAGE.set_token('TRX_DATE',TO_CHAR(p_emd_transaction_rec.transaction_date));
        FND_MSG_PUB.ADD;
        RETURN;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name( 'PON', 'TRX_DATE_NOT_IN_AP_PERIOD_O_F' );
        FND_MESSAGE.set_token('TRX_DATE',TO_CHAR(p_emd_transaction_rec.transaction_date));
        FND_MSG_PUB.ADD;
        RETURN;
    END;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
x_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
x_return_status := FND_API.G_RET_STS_ERROR;
END validate_trx_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_pon_emd_fin
--Description : Verifies financial setup info
--Parameters:
--IN:
--  p_emd_fin_integration
--  p_ra_trx_type_id
--  p_ra_batch_source_id
--  p_ra_import_batch_source_id
--  p_memo_line_id
--  p_payment_terms_id
--  p_transaction_type_code
--  p_org_id
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE validate_pon_emd_fin(p_emd_fin_integration        IN  VARCHAR2,
                               p_ra_trx_type_id             IN  NUMBER,
                               p_ra_batch_source_id         IN  NUMBER,
                               p_ra_import_batch_source_id  IN  NUMBER,
                               p_memo_line_id               IN  NUMBER,
                               p_memo_line_invoice_id       IN  NUMBER,
                               p_payment_terms_id           IN  NUMBER,
                               p_transaction_type_code      IN  VARCHAR2,
                               p_org_id                     IN  NUMBER,
                               x_return_status              OUT NOCOPY VARCHAR2)
IS

l_type                            ra_cust_trx_types.TYPE%TYPE;
l_credit_memo_type_id             ra_cust_trx_types.credit_memo_type_id%TYPE;
l_subsequent_trx_type_id          ra_cust_trx_types.subsequent_trx_type_id%TYPE;
l_post_to_gl                      ra_cust_trx_types.post_to_gl%TYPE;
l_accounting_affect_flag          ra_cust_trx_types.accounting_affect_flag%TYPE;
l_creation_sign                   ra_cust_trx_types.creation_sign%TYPE;
l_natural_app_only_flag           ra_cust_trx_types.natural_application_only_flag%TYPE;
l_allow_overapplication_flag      ra_cust_trx_types.allow_overapplication_flag%TYPE;
l_default_status                  ra_cust_trx_types.default_status%TYPE;
l_tax_calculation_flag            ra_cust_trx_types.tax_calculation_flag%TYPE;
l_exclude_from_late_charges       ra_cust_trx_types.exclude_from_late_charges%TYPE;
l_gl_id_rec                       ra_cust_trx_types.gl_id_rec%TYPE;
l_gl_id_rev                       ra_cust_trx_types.gl_ID_rev%TYPE;
l_start_date                      ra_cust_trx_types.start_date%TYPE;
l_end_date                        ra_cust_trx_types.end_date%TYPE;
l_deposit_trx_name                ra_cust_trx_types.name%TYPE;
l_cm_trx_name                     ra_cust_trx_types.NAME%TYPE;
l_invoice_trx_name                ra_cust_trx_types.NAME%TYPE;

l_batch_source_name               ra_batch_sources.NAME%TYPE;
l_batch_source_status             ra_batch_sources.STATUS%TYPE;
l_auto_batch_numbering_flag       ra_batch_sources.AUTO_BATCH_NUMBERING_FLAG%TYPE;
l_auto_trx_numbering_flag         ra_batch_sources.AUTO_TRX_NUMBERING_FLAG%TYPE;
l_batch_source_type               ra_batch_sources.BATCH_SOURCE_TYPE%TYPE;
l_allow_dup_trx_num_flag          ra_batch_sources.ALLOW_DUPLICATE_TRX_NUM_FLAG%TYPE;
l_credit_memo_batch_source_id     ra_batch_sources.CREDIT_MEMO_BATCH_SOURCE_ID%TYPE;
l_credit_batch_source_name        ra_batch_sources.NAME%TYPE;
l_cr_batch_source_status          ra_batch_sources.STATUS%TYPE;
l_cr_auto_batch_numbering_flag    ra_batch_sources.AUTO_BATCH_NUMBERING_FLAG%TYPE;
l_cr_auto_trx_numbering_flag      ra_batch_sources.AUTO_TRX_NUMBERING_FLAG%TYPE;
l_cr_batch_source_type            ra_batch_sources.BATCH_SOURCE_TYPE%TYPE;
l_cr_allow_dup_trx_num_flag       ra_batch_sources.ALLOW_DUPLICATE_TRX_NUM_FLAG%TYPE;

l_memo_line_name                  ar_memo_lines.NAME%TYPE;
l_memo_line_type                  ar_memo_lines.line_type%TYPE;
l_memo_line_start_date            ar_memo_lines.start_date%TYPE;
l_memo_line_end_date              ar_memo_lines.end_date%TYPE;
l_memo_line_rev_acc               ar_memo_lines.gl_id_rev%TYPE;

l_term_name                       ra_terms_vl.NAME%TYPE;
l_term_start_date                 ra_terms_vl.START_DATE_ACTIVE%TYPE;
l_term_end_Date                   ra_terms_vl.END_DATE_ACTIVE%TYPE;
l_organization_name               hr_operating_units.NAME%TYPE;
l_ra_batch_source_id              NUMBER(15);

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
      SELECT name
        INTO l_organization_name
        FROM hr_operating_units
       WHERE organization_id = p_org_id;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','ORG_NOT_FOUND_IN_HR');
    FND_MESSAGE.SET_TOKEN('ORG_ID',To_Char(p_org_id));
    RETURN;
  END;

  IF (Nvl(p_emd_fin_integration,'N') <> 'Y') THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','PON_EMD_FIN_INTG_NOT_ENABLED');
    FND_MESSAGE.SET_TOKEN('ORG', l_organization_name);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;

  IF (p_ra_trx_type_id = NULL) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','TRX_TYPE_NOT_IN_DEFINED_SETUP');
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_log('p_transaction_type_code:'||p_transaction_type_code);
    IF (p_transaction_type_code = G_EMD_DEPOSIT) THEN
      BEGIN
      SELECT TYPE,
              CREDIT_MEMO_TYPE_ID,
              SUBSEQUENT_TRX_TYPE_ID,
              POST_TO_GL,
              ACCOUNTING_AFFECT_FLAG,
              CREATION_SIGN,
              NATURAL_APPLICATION_ONLY_FLAG,
              ALLOW_OVERAPPLICATION_FLAG,
              DEFAULT_STATUS,
              TAX_CALCULATION_FLAG,
              EXCLUDE_FROM_LATE_CHARGES,
              GL_ID_REC,
              GL_ID_REV,
              START_DATE,
              END_DATE,
              NAME
      INTO   l_type,
              l_credit_memo_type_id,
              l_subsequent_trx_type_id,
              l_post_to_gl,
              l_accounting_affect_flag,
              l_creation_sign,
              l_natural_app_only_flag,
              l_allow_overapplication_flag,
              l_default_status,
              l_tax_calculation_flag,
              l_exclude_from_late_charges,
              l_gl_id_rec,
              l_gl_id_rev,
              l_start_date,
              l_end_date,
              l_deposit_trx_name
      FROM ra_cust_trx_types_all
      WHERE CUST_TRX_TYPE_ID = p_ra_trx_type_id
        AND   org_id = p_org_id;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','RA_TRX_TYPE_NOT_FOUND_IN_AR');
        FND_MSG_PUB.ADD;
        RETURN;
      END;

      IF NOT((Trunc(SYSDATE) >= l_start_date) AND
          (Trunc(SYSDATE) < Nvl(l_end_date,Trunc(SYSDATE + 1)))) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','RA_TRX_TYPE_NOT_ACTIVE');
        FND_MESSAGE.set_token('TRX_TYPE',l_deposit_trx_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
      IF( (Nvl(l_post_to_gl,'N') <> 'Y') OR
          (Nvl(l_accounting_affect_flag,'N') <> 'Y') OR
          (Nvl(l_natural_app_only_flag,'N') <> 'Y') OR
          (Nvl(l_allow_overapplication_flag,'N') <> 'N') OR
          (l_type <> 'DEP') OR
          (Nvl(l_tax_calculation_flag,'N') <> 'N') OR
          (Nvl(l_exclude_from_late_charges,'N') <> 'N') OR
          l_gl_id_rec IS NULL  OR
          l_gl_id_rev IS NULL  OR
          l_credit_memo_type_id IS NULL OR
          l_creation_sign <> 'P' OR
          l_subsequent_trx_type_id IS NULL OR
          l_default_status <> 'OP') THEN

        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','TRX_TYPE_INFO_NOT_VALID');
        FND_MESSAGE.set_token('TRX_TYPE',l_deposit_trx_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    ELSIF (p_transaction_type_code = G_EMD_REFUND) THEN
          SELECT CREDIT_MEMO_TYPE_ID
            INTO l_credit_memo_type_id
            FROM ra_cust_trx_types_all
           WHERE CUST_TRX_TYPE_ID = p_ra_trx_type_id
             AND   org_id = p_org_id;
		print_log('l_credit_memo_type_id:'||l_credit_memo_type_id);
        IF  (l_credit_memo_type_id IS NULL) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','CM_TYPE_NOT_IN_DEP_TRX_TYPE');
          FND_MSG_PUB.ADD;
          RETURN;
        ELSE
          SELECT  TYPE,
                  POST_TO_GL,
                  ACCOUNTING_AFFECT_FLAG,
                  CREATION_SIGN,
                  NATURAL_APPLICATION_ONLY_FLAG,
                  ALLOW_OVERAPPLICATION_FLAG,
                  DEFAULT_STATUS,
                  TAX_CALCULATION_FLAG,
                  EXCLUDE_FROM_LATE_CHARGES,
                  GL_ID_REC,
                  GL_ID_REV,
                  START_DATE,
                  END_DATE,
                  NAME
           INTO   l_type,
                  l_post_to_gl,
                  l_accounting_affect_flag,
                  l_creation_sign,
                  l_natural_app_only_flag,
                  l_allow_overapplication_flag,
                  l_default_status,
                  l_tax_calculation_flag,
                  l_exclude_from_late_charges,
                  l_gl_id_rec,
                  l_gl_id_rev,
                  l_start_date,
                  l_end_date,
                  l_cm_trx_name
           FROM ra_cust_trx_types_all
           WHERE CUST_TRX_TYPE_ID = l_credit_memo_type_id
             AND   org_id = p_org_id;
			print_log('l_start_date:'||l_start_date||' l_end_date:'||l_end_date);
          IF NOT((Trunc(SYSDATE) >= l_start_date) AND
              (Trunc(SYSDATE) < Nvl(l_end_date,Trunc(SYSDATE + 1)))) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','RA_TRX_TYPE_NOT_ACTIVE');
            FND_MESSAGE.set_token('TRX_TYPE',l_cm_trx_name);
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;

          IF((Nvl(l_post_to_gl,'N') <> 'Y') OR
            (Nvl(l_accounting_affect_flag,'N') <> 'Y') OR
            (Nvl(l_natural_app_only_flag,'N') <> 'Y') OR
            (Nvl(l_allow_overapplication_flag,'N') <> 'N') OR
            (l_type <> 'CM') OR
            (Nvl(l_tax_calculation_flag,'N') <> 'N') OR
            (Nvl(l_exclude_from_late_charges,'N') <> 'N') OR
            l_gl_id_rec IS NULL  OR
            l_gl_id_rev IS NULL  OR
            l_creation_sign <> 'N' OR
            l_default_status <> 'OP') THEN

            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','CM_TRX_TYPE_INFO_NOT_VALID');
            FND_MESSAGE.set_token('TRX_TYPE',l_cm_trx_name);
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;
        END IF;
    ELSIF (p_transaction_type_code = G_EMD_FORFEIT) THEN
          SELECT SUBSEQUENT_TRX_TYPE_ID
            INTO l_subsequent_trx_type_id
            FROM ra_cust_trx_types_all
           WHERE CUST_TRX_TYPE_ID = p_ra_trx_type_id
             AND   org_id = p_org_id;

        IF  (l_subsequent_trx_type_id IS NULL) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','INV_TYP_NOT_IN_DEP_TRX_TYP');
          FND_MSG_PUB.ADD;
          RETURN;
        ELSE
          SELECT  TYPE,
                  POST_TO_GL,
                  ACCOUNTING_AFFECT_FLAG,
                  CREATION_SIGN,
                  NATURAL_APPLICATION_ONLY_FLAG,
                  ALLOW_OVERAPPLICATION_FLAG,
                  DEFAULT_STATUS,
                  TAX_CALCULATION_FLAG,
                  EXCLUDE_FROM_LATE_CHARGES,
                  GL_ID_REC,
                  GL_ID_REV,
                  START_DATE,
                  END_DATE,
                  NAME
           INTO   l_type,
                  l_post_to_gl,
                  l_accounting_affect_flag,
                  l_creation_sign,
                  l_natural_app_only_flag,
                  l_allow_overapplication_flag,
                  l_default_status,
                  l_tax_calculation_flag,
                  l_exclude_from_late_charges,
                  l_gl_id_rec,
                  l_gl_id_rev,
                  l_start_date,
                  l_end_date,
                  l_invoice_trx_name
           FROM ra_cust_trx_types_all
           WHERE CUST_TRX_TYPE_ID = l_subsequent_trx_type_id
             AND   org_id = p_org_id;

          IF NOT((Trunc(SYSDATE) >= l_start_date) AND
              (Trunc(SYSDATE) < Nvl(l_end_date,Trunc(SYSDATE + 1)))) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','RA_TRX_TYPE_NOT_ACTIVE');
            FND_MESSAGE.set_token('TRX_TYPE',l_invoice_trx_name);
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;

          IF((Nvl(l_post_to_gl,'N') <> 'Y') OR
            (Nvl(l_accounting_affect_flag,'N') <> 'Y') OR
            (Nvl(l_natural_app_only_flag,'N') <> 'Y') OR
            (Nvl(l_allow_overapplication_flag,'N') <> 'N') OR
            (l_type <> 'INV') OR
            (Nvl(l_tax_calculation_flag,'N') <> 'N') OR
            (Nvl(l_exclude_from_late_charges,'N') <> 'N') OR
            l_gl_id_rec IS NULL  OR
            l_gl_id_rev IS NULL  OR
            l_creation_sign NOT IN  ('P','A') OR
            l_default_status <> 'OP') THEN

            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','INV_TRX_TYPE_INFO_NOT_VALID');
            FND_MESSAGE.set_token('TRX_TYPE',l_invoice_trx_name);
            FND_MSG_PUB.ADD;
            RETURN;
          END IF;
        END IF;
    END IF;
  print_log('Done with p_transaction_type_code IFs');
  --Validate Batch Source
  IF (p_transaction_type_code in (G_EMD_DEPOSIT,G_EMD_REFUND)) THEN
    l_ra_batch_source_id := p_ra_batch_source_id;
	print_log('l_ra_batch_source_id:'||l_ra_batch_source_id);
  ELSIF (p_transaction_type_code = G_EMD_FORFEIT) THEN
    l_ra_batch_source_id := p_ra_import_batch_source_id;
  END IF;

  IF (l_ra_batch_source_id IS NULL) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOUR_NOT_IN_SETUP');
    FND_MSG_PUB.ADD;
    RETURN;
  ELSE
      BEGIN
        SELECT  NAME,
                STATUS,
                AUTO_BATCH_NUMBERING_FLAG,
                AUTO_TRX_NUMBERING_FLAG,
                BATCH_SOURCE_TYPE,
                ALLOW_DUPLICATE_TRX_NUM_FLAG,
                CREDIT_MEMO_BATCH_SOURCE_ID
        INTO   l_batch_source_name,
              l_batch_source_status,
              l_auto_batch_numbering_flag,
              l_auto_trx_numbering_flag,
              l_batch_source_type,
              l_allow_dup_trx_num_flag,
              l_credit_memo_batch_source_id
        FROM  RA_BATCH_SOURCES_ALL
        WHERE BATCH_SOURCE_ID = l_ra_batch_source_id
          AND ORG_ID = p_org_id;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_DEF');
        FND_MSG_PUB.ADD;
        RETURN;
      END;
	  print_log('End of Select block');

	  print_log('l_batch_source_name:'||l_batch_source_name);
	  print_log('l_batch_source_status:'||l_batch_source_status);
	  print_log('l_auto_batch_numbering_flag:'||l_auto_batch_numbering_flag);
	  print_log('l_auto_trx_numbering_flag:'||l_auto_trx_numbering_flag);
	  print_log('l_batch_source_type:'||l_batch_source_type);
	  print_log('l_allow_dup_trx_num_flag:'||l_allow_dup_trx_num_flag);
	  print_log('l_credit_memo_batch_source_id:'||l_credit_memo_batch_source_id);

	  IF (l_batch_source_status <> 'A') THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_ACTIVE');
        fnd_message.set_token('BATCH_SOURCE',l_batch_source_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

      IF  ( (Nvl(l_auto_batch_numbering_flag,'N') <> 'Y') OR
            (Nvl(l_auto_trx_numbering_flag,'N') <> 'Y') OR
            (Nvl(l_allow_dup_trx_num_flag,'N') <> 'N') OR
            ( ( (p_transaction_type_code in (G_EMD_DEPOSIT,G_EMD_REFUND)) AND
                (l_batch_source_type <> 'INV')  ) OR
              ( (p_transaction_type_code = G_EMD_FORFEIT) AND
                (l_batch_source_type <> 'FOREIGN')  ) )
          ) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','TRX_BATCH_INFO_NOT_VALID');
          FND_MESSAGE.SET_TOKEN('BATCH_SOURCE',l_batch_source_name);
          FND_MSG_PUB.ADD;
          RETURN;
      END IF;
      IF (l_credit_memo_batch_source_id  IS NOT NULL AND
       l_credit_memo_batch_source_id <>  l_ra_batch_source_id) THEN
        BEGIN
          SELECT  NAME,
                  STATUS,
                  AUTO_BATCH_NUMBERING_FLAG,
                  AUTO_TRX_NUMBERING_FLAG,
                  BATCH_SOURCE_TYPE,
                  ALLOW_DUPLICATE_TRX_NUM_FLAG
          INTO   l_credit_batch_source_name,
                l_cr_batch_source_status,
                l_cr_auto_batch_numbering_flag,
                l_cr_auto_trx_numbering_flag,
                l_cr_batch_source_type,
                l_cr_allow_dup_trx_num_flag
          FROM  RA_BATCH_SOURCES_ALL
          WHERE BATCH_SOURCE_ID = l_credit_memo_batch_source_id
            AND   ORG_ID = p_org_id;
        EXCEPTION
        WHEN No_Data_Found THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_DEF');
          FND_MSG_PUB.ADD;
          RETURN;
        END;

        IF (l_cr_batch_source_status <> 'A') THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_ACTIVE');
          fnd_message.set_token('BATCH_SOURCE',l_credit_batch_source_name);
          FND_MSG_PUB.ADD;
          RETURN;
        END IF;
        IF ((Nvl(l_cr_auto_batch_numbering_flag,'N') <> 'Y') OR
          (Nvl(l_cr_auto_trx_numbering_flag,'N') <> 'Y') OR
          (Nvl(l_cr_allow_dup_trx_num_flag,'N') <> 'N') OR
          (l_cr_batch_source_type <> 'INV')) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','TRX_BATCH_INFO_NOT_VALID');
          FND_MESSAGE.SET_TOKEN('BATCH_SOURCE',l_credit_batch_source_name);
          FND_MSG_PUB.ADD;
          RETURN;
        END IF;
      END IF;
  END IF;

print_log('Before G_EMD_DEPOSIT IF block');

  IF (p_transaction_type_code in (G_EMD_DEPOSIT)) THEN

    IF (p_memo_line_id IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','MEMO_LINE_NOT_IN_SETUP');
        FND_MSG_PUB.ADD;
        RETURN;
    ELSE
      BEGIN
        SELECT NAME,
                LINE_TYPE,
                START_DATE,
                END_DATE,
                GL_ID_REV
        INTO l_memo_line_name,
              l_memo_line_type,
              l_memo_line_start_date,
              l_memo_line_end_date,
              l_memo_line_rev_acc
        FROM AR_MEMO_LINES_VL
        WHERE ORG_ID = p_org_id
        AND  MEMO_LINE_ID = p_memo_line_id;
      EXCEPTION
      WHEN No_Data_Found THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','MEMO_LINE_NOT_DEF_IN_AR');
          FND_MSG_PUB.ADD;
          RETURN;
      END;

      IF NOT ((Trunc(SYSDATE) >= l_memo_line_start_date) AND
          (Trunc(SYSDATE) < Nvl(l_memo_line_end_date,Trunc(SYSDATE+1)))) THEN
              x_return_status := fnd_api.g_ret_sts_error;
              FND_MESSAGE.SET_NAME('PON','MEMO_LINE_TYPE_NOT_ACTIVE');
              FND_MESSAGE.set_token('MEMO_LINE',l_memo_line_name);
              FND_MSG_PUB.ADD;
              RETURN;
      END IF;

      IF (l_memo_line_type <> 'LINE' OR
          l_memo_line_rev_acc IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','MEMO_LINE_INFO_NOT_VALID');
            FND_MESSAGE.set_token('MEMO_LINE',l_memo_line_name);
            FND_MSG_PUB.ADD;
            RETURN;
      END IF;
    END IF;
  END IF;
print_log('Before G_EMD_FORFEIT IF block');
  IF (p_transaction_type_code in (G_EMD_FORFEIT)) THEN
    IF (p_memo_line_invoice_id IS NULL) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','MEMO_LINE_NOT_IN_SETUP');
        FND_MSG_PUB.ADD;
        RETURN;
    ELSE
      BEGIN
        SELECT NAME,
                LINE_TYPE,
                START_DATE,
                END_DATE,
                GL_ID_REV
        INTO l_memo_line_name,
              l_memo_line_type,
              l_memo_line_start_date,
              l_memo_line_end_date,
              l_memo_line_rev_acc
        FROM AR_MEMO_LINES_VL
        WHERE ORG_ID = p_org_id
        AND  MEMO_LINE_ID = p_memo_line_invoice_id;
      EXCEPTION
      WHEN No_Data_Found THEN
          x_return_status := fnd_api.g_ret_sts_error;
          FND_MESSAGE.SET_NAME('PON','MEMO_LINE_NOT_DEF_IN_AR');
          FND_MSG_PUB.ADD;
          RETURN;
      END;

      IF NOT ((Trunc(SYSDATE) >= l_memo_line_start_date) AND
          (Trunc(SYSDATE) < Nvl(l_memo_line_end_date,Trunc(SYSDATE+1)))) THEN
              x_return_status := fnd_api.g_ret_sts_error;
              FND_MESSAGE.SET_NAME('PON','MEMO_LINE_TYPE_NOT_ACTIVE');
              FND_MESSAGE.set_token('MEMO_LINE',l_memo_line_name);
              FND_MSG_PUB.ADD;
              RETURN;
      END IF;

      IF (l_memo_line_type <> 'LINE' OR
          l_memo_line_rev_acc IS NULL) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            FND_MESSAGE.SET_NAME('PON','MEMO_LINE_INFO_NOT_VALID');
            FND_MESSAGE.set_token('MEMO_LINE',l_memo_line_name);
            FND_MSG_PUB.ADD;
            RETURN;
      END IF;
    END IF;
  END IF;

  IF (p_transaction_type_code IN (G_EMD_DEPOSIT,G_EMD_FORFEIT)) THEN
    IF (p_payment_terms_id IS NULL) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','PAYMENT_TERM_NOT_IN_SETUP');
      FND_MSG_PUB.ADD;
      RETURN;
    ELSE
      BEGIN
        SELECT  rt.NAME,
                rt.START_DATE_ACTIVE,
                rt.END_DATE_ACTIVE
          INTO  l_term_name,
                l_term_start_date,
                l_term_end_Date
          FROM  ra_terms_vl rt
          WHERE 1 = (SELECT Count(*)
                       FROM ra_terms_lines rtl
                      WHERE rtl.term_id = rt.term_id
                        AND rtl.relative_amount = rt.base_amount
                        AND rtl.due_days = 0)
            AND  Nvl(rt.PARTIAL_DISCOUNT_FLAG,'N') = 'N'
            AND  Nvl(rt.PREPAYMENT_FLAG,'N') = 'N'
            AND  Nvl(rt.CREDIT_CHECK_FLAG,'N') = 'N'
            AND  rt.CALC_DISCOUNT_ON_LINES_FLAG = 'I'
            AND  rt.term_id = p_payment_terms_id;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','PAYMENT_TERM_NOT_DEF_IN_AR');
        FND_MSG_PUB.ADD;
        RETURN;
      END;
      IF NOT ((Trunc(SYSDATE) >= l_term_start_date) AND
            (Trunc(SYSDATE) < Nvl(l_term_end_Date,Trunc(SYSDATE+1)))) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','PAYMENT_TERM_NOT_ACTIVE');
        FND_MESSAGE.set_token('PAYMENT_TERM',l_term_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    END IF;
  END IF;
  print_log('End of validate_pon_emd_fin');
END validate_pon_emd_fin;

-----------------------------------------------------------------------
--Start of Comments
--Name:  validate_trx_payment_type_info
--Description : Verifies trx payment type info
--Parameters:
--IN:
--  p_receipt_method_id
--  p_refund_payment_method
--  p_payment_type_code
--  p_transaction_type_code
--  p_org_id
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE validate_trx_payment_type_info(p_receipt_method_id      IN   NUMBER,
                                         p_refund_payment_method  IN   VARCHAR2,
                                         p_payment_type_code      IN   VARCHAR2,
                                         p_transaction_type_code  IN   VARCHAR2,
                                         p_org_id                 IN   NUMBER,
                                         x_return_status          OUT  NOCOPY VARCHAR2)
IS
l_receipt_method_name             ar_receipt_methods.NAME%TYPE;
l_payment_channal_code            ar_receipt_methods.payment_channel_code%TYPE;
l_rm_start_date                   ar_receipt_methods.start_date%TYPE;
l_rm_end_date                     ar_receipt_methods.end_date%TYPE;
l_receipt_creation_method         ar_receipt_classes.creation_method_code%TYPE;
l_payment_type_name               pon_emd_payment_types_tl.NAME%TYPE;
l_refund_payment_method_name      iby_payment_methods_tl.payment_method_name%TYPE;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
    SELECT  NAME
      INTO  l_payment_type_name
      FROM  PON_EMD_PAYMENT_TYPES_VL
      WHERE PAYMENT_TYPE_CODE=p_payment_type_code
      AND   ORG_ID = p_org_id;
  EXCEPTION WHEN No_Data_Found then
      x_return_status := fnd_api.g_ret_sts_error;
      print_log('Payment types not found for the operating unit '||p_org_id);
      RETURN;
  END;


  IF (p_receipt_method_id IS NULL) THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('PON','REC_METH_NOT_DEF_FOR_PAY_TYP');
    FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',p_payment_type_code);
    FND_MSG_PUB.ADD;
    RETURN;
  ELSE
    BEGIN
      SELECT  RM.NAME,
              RM.PAYMENT_CHANNEL_CODE,
              RM.START_DATE,
              RM.END_DATE,
              RC.CREATION_METHOD_CODE
      INTO   l_receipt_method_name,
           l_payment_channal_code,
           l_rm_start_date,
           l_rm_end_date,
           l_receipt_creation_method
      FROM   AR_RECEIPT_METHODS RM,
           AR_RECEIPT_CLASSES RC
      WHERE RM.RECEIPT_CLASS_ID = RC.RECEIPT_CLASS_ID
      AND RM.RECEIPT_METHOD_ID = p_receipt_method_id;
    EXCEPTION
    WHEN No_Data_Found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','RECEIPT_METH_NOT_DEF_IN_AR');
      FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',p_payment_type_code);
      FND_MSG_PUB.ADD;
      RETURN;
    END;

    IF NOT ((Trunc(SYSDATE) >= l_rm_start_date) AND
        (Trunc(SYSDATE) < Nvl(l_rm_end_date,Trunc(SYSDATE+1)))) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','RECEIPT_METHOD_NOT_ACTIVE');
      FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;

    IF (p_payment_type_code IN (G_CASH,G_DEMAND_DRAFT,G_CHECK)) THEN
      IF (l_receipt_creation_method <> 'MANUAL') THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','RECEIPT_CRE_METH_NOT_VALID');
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

      IF (l_payment_channal_code IS NOT NULL) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','PAY_METH_FOR_NOT_VALID');
        FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',l_payment_type_name);
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    ELSIF (p_payment_type_code = 'BANK_EFT_XFER') THEN
      IF (l_receipt_creation_method <> 'AUTOMATIC') THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','RECEIPT_CRE_METH_NOT_VALID');
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

      IF (l_payment_channal_code <> G_BANK_ACCT_XFER) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','PAY_METH_NOT_VALID');
        FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',l_payment_type_name);
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    ELSIF (p_payment_type_code = G_CREDIT_CARD) THEN
      IF (l_receipt_creation_method <> 'AUTOMATIC') THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','RECEIPT_CRE_METH_NOT_VALID');
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

      IF (l_payment_channal_code <> G_CREDIT_CARD) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','PAY_METH_NOT_VALID');
        FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',l_payment_type_name);
        FND_MESSAGE.set_token('RECEIPT_METHOD',l_receipt_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    END IF;
  END IF;

  IF (p_transaction_type_code = G_EMD_REFUND) THEN
    IF ((p_payment_type_code <> G_CREDIT_CARD) AND
        (p_refund_payment_method IS NULL)) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','REF_PAY_METH_NOT_IN_SETUP');
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
    IF (p_refund_payment_method IS NOT NULL) THEN
      BEGIN
        SELECT  PAYMENT_METHOD_NAME
        INTO    l_refund_payment_method_name
        FROM IBY_PAYMENT_METHODS_VL
        WHERE  PAYMENT_METHOD_CODE = p_refund_payment_method;
      EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('PON','REF_PAY_METH_NOT_VALID');
        FND_MESSAGE.SET_TOKEN('PAYMENT_TYPE',l_payment_type_name);
        FND_MESSAGE.SET_TOKEN('PAY_METHOD',l_refund_payment_method_name);
        FND_MSG_PUB.ADD;
        RETURN;
      END;
    END IF;
  END IF;

END validate_trx_payment_type_info;

-----------------------------------------------------------------------
--Start of Comments
--Name:  verify_finance_installation
--Description : Verifies financial products installtion status
--Parameters:
--IN:
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE verify_finance_installation(x_return_status OUT NOCOPY VARCHAR2)
IS
l_return_value  BOOLEAN;
l_status        varchar2(1);
l_industry      varchar2(1);
l_oracle_schema varchar2(30);
BEGIN
x_return_status := fnd_api.g_ret_sts_success;

  --Validate AR installation
  BEGIN
  l_return_value := fnd_installation.get_app_info(
                         application_short_name => 'AR'
                        ,status                 => l_status
                        ,industry               => l_industry
                        ,oracle_schema          => l_oracle_schema
                        );


  if (l_return_value) THEN
    if l_status <> 'I' then
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AR_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
    end if;
  else
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AR_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  end if;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AR_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  END;
-- Validate AP Installation
  BEGIN
  l_return_value := fnd_installation.get_app_info(
                         application_short_name => 'SQLAP'
                        ,status                 => l_status
                        ,industry               => l_industry
                        ,oracle_schema          => l_oracle_schema
                        );

  if (l_return_value) THEN
    if l_status <> 'I' then
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AP_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
    end if;
  else
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AP_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  end if;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','AP_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  END;

-- Validate IBY Installation
  BEGIN
  l_return_value := fnd_installation.get_app_info(
                         application_short_name => 'IBY'
                        ,status                 => l_status
                        ,industry               => l_industry
                        ,oracle_schema          => l_oracle_schema
                        );

  if (l_return_value) then
    if l_status <> 'I' then
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','IBY_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
    end if;
  else
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','IBY_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  end if;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','IBY_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  END;

-- Validate IBY Installation
  BEGIN
  l_return_value := fnd_installation.get_app_info(
                         application_short_name => 'SQLGL'
                        ,status                 => l_status
                        ,industry               => l_industry
                        ,oracle_schema          => l_oracle_schema
                        );

  if (l_return_value) then
    if l_status <> 'I' then
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','GL_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
    end if;
  else
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','GL_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  end if;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','GL_NOT_INSTALLED');
      FND_MSG_PUB.ADD;
      RETURN;
  END;

END verify_finance_installation;
-----------------------------------------------------------------------
--Start of Comments
--Name:  update_emd_trx_error_status
--Description  : procedure to update the status_lookup_code in
-- pon_emd_transactions depending on the transaction_type_code when
-- the transaction errors out.
--Pre-reqs:
--Parameters:
--IN:  p_emd_transaction_id
--     p_msg_data
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------


PROCEDURE update_emd_trx_error_status(p_emd_transaction_id IN NUMBER,
                                      p_msg_data           IN VARCHAR2)

IS

BEGIN

  UPDATE pon_emd_transactions
  SET status_lookup_code = Decode(transaction_type_code, G_EMD_DEPOSIT, 'RECEIVE_ERROR',
                                                         G_EMD_REFUND,  'REFUND_ERROR',
                                                         G_EMD_FORFEIT, 'FORFEIT_ERROR'),
      error_message = p_msg_data
  WHERE emd_transaction_id = p_emd_transaction_id;

COMMIT;

END update_emd_trx_error_status;

-----------------------------------------------------------------------
--Start of Comments
--Name:  print_log
--Description  : updates the status_lookup_code of the previous errored
--transactions.
--Pre-reqs:
--Parameters:
--IN:  p_emd_transaction_id
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_trx_status_lookup_code(p_emd_transaction_id IN NUMBER)
IS
BEGIN
  UPDATE pon_emd_transactions
  SET status_lookup_code = Decode(transaction_type_code, G_EMD_DEPOSIT, 'RECEIVING',
                                                         G_EMD_REFUND,  'REFUNDING',
                                                         G_EMD_FORFEIT, 'FORFEITING'),
      error_message = NULL
  WHERE emd_transaction_id = p_emd_transaction_id;

END update_trx_status_lookup_code;

-----------------------------------------------------------------------
--Start of Comments
--Name:  insert_and_call_autoinvoice
--Description  : inserts the data into ra_interface_lines_all and
-- submits auto invoice concurrent request
--Pre-reqs:
--Parameters:
--IN:  p_in_rec
--OUT: p_out_rec
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_and_call_autoinvoice
( p_in_rec        IN         FORFEIT_INFO_IN_RECTYPE,
  p_in_emd_trx    IN         pon_emd_trx_info_Tbl_Type,
  x_return_status OUT NOCOPY  VARCHAR2)
IS

l_batch_source_name         ra_batch_sources.NAME%TYPE := NULL;
l_conc_req_id               NUMBER;
l_interface_line_id         NUMBER;
call_status                 BOOLEAN;
request_phase               VARCHAR2(80);
request_status              VARCHAR2(80);
dev_request_phase           VARCHAR2(80);
dev_request_status          VARCHAR2(80);
request_status_mesg         VARCHAR2(80);
l_error_count               NUMBER;
message_text                VARCHAR2(240);
invalid_value               VARCHAR2(240);
concat_err_msg              VARCHAR2(2000);
l_return_status             VARCHAR2(1);
l_cust_trx_name             ra_cust_trx_types.NAME%TYPE;
l_deposit_trx_line_id       ra_customer_trx_lines_all.customer_trx_line_id%TYPE;
l_emd_transactions_info     pon_emd_trx_rec;
l_customer_trx_id           ra_customer_trx.customer_trx_id%TYPE;
l_trx_number                ra_customer_trx.trx_number%TYPE;
l_memo_desc                 ar_memo_lines_all_tl.description%TYPE;
l_memo_name                 ar_memo_lines_all_tl.name%TYPE;  -- bug 8628651
l_term_name                 VARCHAR2(25);

CURSOR int_errors(x_interface_line_id NUMBER, x_org_id number) IS
SELECT message_text,invalid_value
FROM ra_interface_errors_all
WHERE org_id = x_org_id
AND interface_line_id = x_interface_line_id;

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  print_log('insert_and_call_autoinvoice');

  print_log('p_in_rec.trx_type_id: ' || p_in_rec.trx_type_id);
  print_log('p_in_rec.deposit_trx_id: '||p_in_rec.deposit_trx_id);
  print_log('p_in_rec.transaction_currency_code: '||p_in_rec.transaction_currency_code);
  print_log('p_in_rec.transaction_date: '||p_in_rec.transaction_date);
  print_log('p_in_rec.cust_account_id: '||p_in_rec.cust_account_id);
  print_log('p_in_rec.cust_acct_site_id: '||p_in_rec.cust_acct_site_id);
  print_log('p_in_rec.party_contact_id: '||p_in_Rec.party_contact_id);
  print_log('p_in_rec.exchange_rate_type: '||p_in_rec.exchange_rate_type);
  print_log('p_in_rec.exchange_date: '||p_in_rec.exchange_date);
  print_log('p_in_rec.exchange_rate: '||p_in_rec.exchange_rate);
  print_log('p_in_rec.receipt_method_id: '||p_in_rec.receipt_method_id);
  print_log('p_in_rec.org_id: '||p_in_rec.org_id);
  print_log('p_in_rec.auction_header_id: '||p_in_rec.auction_header_id);
  print_log('p_in_rec.document_number: '||p_in_rec.document_number);
  print_log('p_in_rec.vendor_name: '||p_in_rec.vendor_name);
  print_log('p_in_rec.vendor_site_name: '||p_in_rec.vendor_name);
  print_log('p_in_rec.vendor_contact_name: '||p_in_rec.vendor_contact_name);
  print_log('p_in_rec.amount: '||p_in_rec.amount);
  print_log('p_in_rec.memo_line_id: '||p_in_rec.memo_line_id);
  print_log('p_in_rec.batch_source_id: '||p_in_rec.batch_source_id);
  print_log('p_in_rec.payment_term_id: '||p_in_rec.payment_term_id);
  print_log('p_in_rec.emd_trx_group_id:'||p_in_rec.emd_trx_group_id);
  print_log('p_in_rec.emd_transaction_id: '||p_in_rec.emd_transaction_id);
  print_log('p_in_rec.trx_count_in_group: '||p_in_rec.trx_count_in_group);
  print_log('p_in_rec.current_trx_number: '||p_in_rec.current_trx_number);

  x_return_status := fnd_api.g_ret_sts_success;

  BEGIN
    SELECT name
    INTO l_batch_source_name
    FROM ra_batch_sources_all
    WHERE batch_source_id = p_in_rec.batch_source_id
    AND  org_id = p_in_rec.org_id
    AND  Trunc(SYSDATE) BETWEEN start_date AND Nvl(end_date,Trunc(SYSDATE+1));
  EXCEPTION
  WHEN No_Data_Found THEN
      x_return_status := fnd_api.g_ret_sts_success;
      FND_MESSAGE.SET_NAME('PON','TRX_BATCH_SOURCE_NOT_DEF');
      FND_MESSAGE.SET_TOKEN('BATCH_SOURCE_ID',To_Char(p_in_rec.batch_source_id));
      FND_MSG_PUB.ADD;
      RETURN;
  END;

  BEGIN
    SELECT NAME,
           DESCRIPTION
      INTO l_memo_name,
           l_memo_desc
      FROM AR_MEMO_LINES_VL
      WHERE ORG_ID = p_in_rec.org_id
        AND  MEMO_LINE_ID = p_in_rec.memo_line_id;
  EXCEPTION
    WHEN No_Data_Found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('PON','MEMO_LINE_NOT_DEF_IN_AR');
      FND_MSG_PUB.ADD;
      RETURN;
  END;

  BEGIN
    SELECT NAME
    INTO l_cust_trx_name
    FROM ra_cust_trx_types_all
   WHERE CUST_TRX_TYPE_ID = p_in_rec.trx_type_id
     AND org_id = p_in_rec.org_id;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  END;

  BEGIN
    SELECT customer_trx_line_id
    INTO  l_deposit_trx_line_id
    FROM ra_customer_trx_lines_all
    WHERE customer_trx_id = p_in_rec.deposit_trx_id
    AND org_id = p_in_rec.org_id
    AND ROWNUM =1;
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  END;

  /* Bug 8784319 */
  SELECT ra_customer_trx_lines_s.NEXTVAL INTO l_interface_line_id FROM DUAL;

  print_log('l_interface_line_id'||l_interface_line_id);
  --Inserting into ra_interface_lines_all before calling auto invoice program
  print_log('Before inserting records into ra_interface_lines');

  /* Inserting
     ORIG_SYSTEM_BILL_CONTACT_ID,
     ORIG_SYSTEM_BILL_CONTACT_REF as NULLs
     only as part of Forfeit Bug
    */

    /* Insert Payment Term Name also */

    SELECT  rt.NAME INTO  l_term_name
          FROM  ra_terms_vl rt
          WHERE rt.term_id = p_in_rec.payment_term_id;

  BEGIN
    INSERT INTO ra_interface_lines_all
      ( INTERFACE_LINE_ID,
        DESCRIPTION,
        BATCH_SOURCE_NAME,
        LINE_TYPE,
        CURRENCY_CODE,
        AMOUNT,
        CUST_TRX_TYPE_ID,
        CUST_TRX_TYPE_NAME,
        CONVERSION_TYPE,
        CONVERSION_DATE,
        CONVERSION_RATE,
        TRX_DATE,
        GL_DATE,
        PRINTING_OPTION,
        ORIG_SYSTEM_BILL_CUSTOMER_ID,
        ORIG_SYSTEM_BILL_CUSTOMER_REF,
        ORIG_SYSTEM_BILL_ADDRESS_ID,
        ORIG_SYSTEM_BILL_ADDRESS_REF,
	TERM_NAME,
        TERM_ID,
        RELATED_CUSTOMER_TRX_ID,
        REFERENCE_LINE_ID,
        MEMO_LINE_ID,
        PAYING_CUSTOMER_ID,
        PAYING_SITE_USE_ID,
        ORG_ID,
        INTERFACE_LINE_CONTEXT,
        INTERFACE_LINE_ATTRIBUTE1,
        INTERFACE_LINE_ATTRIBUTE2,
        INTERFACE_LINE_ATTRIBUTE3,
        INTERFACE_LINE_ATTRIBUTE4,
        INTERFACE_LINE_ATTRIBUTE5,
        INTERFACE_LINE_ATTRIBUTE6,
        INTERFACE_LINE_ATTRIBUTE7,
        INTERFACE_LINE_ATTRIBUTE8)
      VALUES(l_interface_line_id,
          Nvl(l_memo_desc,l_memo_name),
          l_batch_source_name,
          'LINE',
          p_in_rec.transaction_currency_code,
          p_in_rec.amount,
          p_in_rec.trx_type_id,
          l_cust_trx_name,
          p_in_rec.exchange_rate_type,
          p_in_rec.exchange_date,
          p_in_rec.exchange_rate,
          p_in_rec.transaction_date,
          p_in_rec.transaction_date,
          'PRI',
          p_in_rec.cust_account_id,
          p_in_rec.cust_account_id,
          p_in_rec.cust_acct_site_id,
          p_in_rec.cust_acct_site_id,
	  l_term_name,
          p_in_rec.payment_term_id,
          p_in_rec.deposit_trx_id,
          l_deposit_trx_line_id,
          p_in_rec.memo_line_id,
          p_in_rec.cust_account_id,
          p_in_rec.site_use_id,
          p_in_rec.org_id,
          'EMD TRANSACTIONS',
          p_in_rec.document_number,
          p_in_rec.party_id,
          p_in_rec.party_site_id,
          Nvl(p_in_rec.party_contact_id,'-9999'),
          'No Bill Number',
          'No Bill Info',
          p_in_rec.emd_trx_group_id,
          p_in_rec.emd_transaction_id);
  EXCEPTION
  WHEN OTHERS THEN
    print_log('exception while inserting'||SQLERRM);
    x_return_status := fnd_api.g_ret_sts_error;
    rollback;
    RETURN;
  END;

  commit;
  print_log('After inserting into interface lines table'||l_interface_line_id);

  IF (p_in_rec.current_trx_number = p_in_rec.trx_count_in_group) THEN

   BEGIN
    l_conc_req_id := FND_REQUEST.SUBMIT_REQUEST
        (
	          'AR'                                               -- Application
	          ,'RAXTRX'                                           -- Program : Autoinvoice Master Program
                  ,SYSDATE
	          ,NULL
	          ,FALSE                                              -- Sub_request
	          ,'MAIN'       			                                -- Parallel
                  ,'T'                                                -- Running Mode
	          ,p_in_rec.batch_source_id             	            -- Batch Source Id.
	          ,l_batch_source_name                                -- Batch Source Name.
	          ,SYSDATE                                            -- Default Date.
	          ,NULL                                               -- Trxn Flexfield.
	          ,NULL                                               -- Trxn Type.
	          ,NULL                                               -- Bill To Customer Number Low.
	          ,NULL                                               -- Bill To Customer Number High.
	          ,NULL                                               -- Bill To Customer Name Low.
	          ,NULL                                               -- Bill To Customer Name High.
	          ,NULL                                               -- GL Date Low.
	          ,NULL                                               -- GL Date High.
	          ,NULL                                               -- Ship Date Low.
	          ,NULL                                               -- Ship Date High.
	          ,NULL                                               -- Trx Number Low. l_trx_number_low
	          ,NULL                                               -- Trx Number High. l_trx_number_high
	          ,NULL                                               -- Sales Order Low.
	          ,NULL                                               -- Sales Order High.
	          ,NULL                                               -- Trx Date Low.
	          ,NULL                                               -- Trx Date High.
	          ,NULL                                               -- Ship To Customer Number Low.
	          ,NULL                                               -- Ship To Customer Number High.
	          ,NULL                                               -- Ship To Customer Name Low.
	          ,NULL                                               -- Ship To Customer Name High.
            	  ,'N'
	          ,'Y'                                                -- Base Due Date On Trx Date Flag.
	          ,NULL                                               -- Due Date Adjustment Days.
                  ,p_in_rec.org_id                                    -- Org Id.
	          ,CHR(0)                                             -- End of Parameter List Indicator.
	          ,'', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', ''
	          ,'', '', '', '', '', '', '', '', '', '');

    EXCEPTION
    WHEN OTHERS THEN
      print_log('Error submitting concurrent request'||SQLERRM);
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
    END;
    COMMIT;
    IF l_conc_req_id = 0 THEN
      print_log('l_conc_req_id'||l_conc_req_id);
      FND_MESSAGE.set_name('PON','AR_AUTO_INVOICE_SUBMIT_FAILED'); /*Concurrent program submission failed!!!!!*/
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;

      IF (p_in_rec.emd_trx_group_id IS NOT NULL) THEN
        DELETE FROM ra_interface_lines_all
        WHERE INTERFACE_LINE_CONTEXT = 'EMD TRANSACTIONS'
        AND  INTERFACE_LINE_ATTRIBUTE7 = to_char(p_in_rec.emd_trx_group_id);
        COMMIT;
      END IF;
    ELSE
      call_status := fnd_concurrent.wait_for_request
                      (l_conc_req_id,
                       20,
                       0,
                       request_phase,
                       request_status,
                       dev_request_phase,
                       dev_request_status,
                       request_status_mesg);
      print_log('l_conc_req_id'||l_conc_req_id);
      print_log('request_phase '||request_phase);
      print_log('request_status'||request_status);
      print_log('dev_request_status'||dev_request_status);
      print_log('dev_request_phase'||dev_request_phase);
      print_log('request_status_mesg'||request_status_mesg);
      IF call_status = TRUE THEN
        print_log('call status is true');
        IF dev_request_phase <> 'COMPLETE' OR
          dev_request_status IN ('CANCELLED','ERROR','TERMINATED') THEN
          print_log('Dev status phase is not Completed');
          FND_MESSAGE.set_name('PON','AR_AUTO_INVOICE_JOB_FAILED');
          FND_MESSAGE.set_token('REQUEST_ID',l_conc_req_id);
          FND_MSG_PUB.add;
          x_return_status := fnd_api.g_ret_sts_error;
          IF (p_in_rec.emd_trx_group_id IS NOT NULL) THEN
            DELETE FROM ra_interface_lines_all
            WHERE INTERFACE_LINE_CONTEXT = 'EMD TRANSACTIONS'
            AND  INTERFACE_LINE_ATTRIBUTE7 = to_char(p_in_rec.emd_trx_group_id);
          END IF;
          COMMIT;
        ELSE
          print_log('Dev status phase is Completed');
          print_log('count'||p_in_emd_trx.Count);
          FOR j IN 1 .. p_in_emd_trx.Count
          LOOP
            l_emd_transactions_info := p_in_emd_trx(j);
            l_customer_trx_id := NULL;
            l_trx_number := NULL;
            print_log('l_emd_transactions_info.emd_trx_group_id'||l_emd_transactions_info.emd_trx_group_id);
            print_log('l_emd_transactions_info.emd_transaction_id'||l_emd_transactions_info.emd_transaction_id);
            print_log('l_emd_transactions_info.org_id'||l_emd_transactions_info.org_id);
            BEGIN
              SELECT  rc.CUSTOMER_TRX_ID,
                      rc.TRX_NUMBER
                INTO  l_customer_trx_id,
                      l_trx_number
                FROM ra_customer_trx_all rc, ra_customer_trx_lines_all rcl
                WHERE rc.CUSTOMER_TRX_ID = rcl.CUSTOMER_TRX_ID
                      AND rcl.INTERFACE_LINE_CONTEXT = 'EMD TRANSACTIONS'
                      AND rcl.INTERFACE_LINE_ATTRIBUTE7 = to_char(l_emd_transactions_info.emd_trx_group_id)
                      AND rcl.INTERFACE_LINE_ATTRIBUTE8 = to_char(l_emd_transactions_info.emd_transaction_id)
                      AND rcl.org_id = l_emd_transactions_info.org_id;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_customer_trx_id :=  NULL;
              l_trx_number := NULL;
            END;
            print_log('l_customer_trx_id'||l_customer_trx_id);
            print_log('l_trx_number'||l_trx_number);

            IF (l_customer_trx_id IS NOT NULL ) THEN
                print_log('l_trx_number'||l_trx_number);
                  UPDATE    pon_emd_transactions
                      SET   CUST_TRX_ID =l_customer_trx_id,
                            CUST_TRX_NUMBER = l_trx_number,
                            POSTED_TO_FINANCE = 'Y',
                            STATUS_LOOKUP_CODE = 'FORFEITED'
                     WHERE  emd_transaction_id = l_emd_transactions_info.emd_transaction_id
                     AND    emd_transaction_group_id = l_emd_transactions_info.emd_trx_group_id
                     AND    auction_header_id =  l_emd_transactions_info.auction_header_id;
                  COMMIT;
            ELSE
                  BEGIN
		  /* Forfeit Error Bug */
                    SELECT ril.interface_line_id
                    INTO l_interface_line_id
                    FROM  ra_interface_lines_all ril
                    WHERE ril.INTERFACE_LINE_CONTEXT = 'EMD TRANSACTIONS'
                    AND ril.INTERFACE_LINE_ATTRIBUTE7 = to_char(l_emd_transactions_info.emd_trx_group_id)
                    AND ril.INTERFACE_LINE_ATTRIBUTE8 = to_char(l_emd_transactions_info.emd_transaction_id);

                    IF (l_interface_line_id IS NOT NULL) THEN
                      SELECT Count(*)
                      INTO l_error_count
                      FROM ra_interface_errors_all
                      WHERE interface_line_id = l_interface_line_id
                      AND  org_id = l_emd_transactions_info.org_id;

                      print_log('l_error_count'||l_error_count);
                      concat_err_msg:=null;
                      IF (l_error_count > 0) THEN
                        OPEN int_errors (l_interface_line_id,p_in_rec.org_id);
                        LOOP
                          FETCH int_errors INTO message_text,invalid_value;
                          IF (int_errors%NOTFOUND) THEN
                            CLOSE int_errors;
                            EXIT;
                          END IF;
                          concat_err_msg := concat_err_msg||fnd_global.local_chr(10)||message_text||':'||invalid_value;
                        END LOOP;
                      END IF;
                      UPDATE pon_emd_transactions
                        SET status_lookup_code = 'FORFEIT_ERROR',
                            error_message = concat_err_msg
                      WHERE emd_transaction_id = l_emd_transactions_info.emd_transaction_id
                        AND emd_transaction_group_id = l_emd_transactions_info.emd_trx_group_id
                        AND auction_header_id =  l_emd_transactions_info.auction_header_id;

                      DELETE FROM ra_interface_lines_all
                      WHERE interface_line_id =l_interface_line_id;

                      DELETE FROM ra_interface_errors_all
                      WHERE interface_line_id =l_interface_line_id;
                      COMMIT;
                    END IF;
                  EXCEPTION
                  WHEN No_Data_Found THEN
                    NULL;
                  END;
            END IF;
          END LOOP;
          x_return_status := fnd_api.g_ret_sts_success;

        END IF;
      ELSE
       IF (p_in_rec.emd_trx_group_id IS NOT NULL) THEN
          DELETE FROM ra_interface_lines_all
          WHERE INTERFACE_LINE_CONTEXT = 'EMD TRANSACTIONS'
            AND  INTERFACE_LINE_ATTRIBUTE7 = to_char(p_in_rec.emd_trx_group_id);
          COMMIT;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.set_name('PON','AR_AUTO_INVOICE_JOB_FAILED');
        FND_MESSAGE.set_token('REQUEST_ID',l_conc_req_id);
        FND_MSG_PUB.ADD;
      END IF;
    END IF;
    print_log('x_return_status: '||x_return_status);
  END IF;
END insert_and_call_autoinvoice;

-----------------------------------------------------------------------
--Start of Comments
--Name:  post_emd_forfeit_transactions
--Description  : Procedure that will be invoked from UI to process forfeit
--transactions
--Pre-reqs:
--Parameters:
--IN
--  p_api_version  API version
--  p_emd_trx_group_id  EMD transaction Group id
--  p_auction_header_id Auction header id
--OUT
--  x_process_complete  indicated process complete or not.
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE post_emd_forfeit_transactions(p_api_version        IN   NUMBER,
                                        p_emd_trx_group_id   IN   NUMBER,
                                        p_auction_header_id  IN   NUMBER,
                                        x_process_complete   OUT NOCOPY VARCHAR2)
IS

l_conc_req_id NUMBER;
l_emd_transactions        pon_emd_trx_info_Tbl_Type;
l_emd_transactions_info   pon_emd_trx_rec;

x_msg_data  	VARCHAR2(1000);
l_msg_data	VARCHAR2(1000);
x_msg_count 	NUMBER;
l_count		NUMBER;


BEGIN
  x_process_complete := 'TRUE';
  print_log('Inside post_emd forfiet transactions');
  OPEN emd_transactions_info(p_emd_trx_group_id,
                             p_auction_header_id,
                             G_EMD_FORFEIT);
  FETCH emd_transactions_info BULK COLLECT INTO  l_emd_transactions;
  IF (l_emd_transactions.Count = 0) THEN
    CLOSE emd_transactions_info;
    print_log('No Transactions to process');
    x_process_complete :=  'FALSE';
    RETURN;
  ELSE
    print_log('emd transaction count '|| l_emd_transactions.Count);
    CLOSE emd_transactions_info;
  END IF;

  l_conc_req_id :=  FND_REQUEST.submit_request(application    =>    'PON',
                                               program        =>    'EMD_REFUND_FORFEIT_CONC',
                                               description    =>    null,
                                               start_time     =>    null,
                                               sub_request    =>    FALSE,
                                               argument1      =>    to_char(p_api_version),
                                               argument2      =>    to_char(p_emd_trx_group_id),
                                               argument3      =>    to_char(p_auction_header_id),
                                               argument4      =>    G_EMD_FORFEIT);

  COMMIT;
  IF (l_conc_req_id = 0) THEN
    print_log('post_emd_transactions l_conc_req_id'||l_conc_req_id);
    fnd_message.set_name ('PON','PON_EMD_CONC_SUBMIT_FAILED');
    FND_MSG_PUB.add;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
   FOR j IN 1 .. l_emd_transactions.Count
   LOOP
     update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
   END LOOP;
   x_process_complete :=  'FALSE';
   RETURN;
  ELSE
    FOR j IN 1 .. l_emd_transactions.Count
      LOOP
        BEGIN
          l_emd_transactions_info := l_emd_transactions(j);
          UPDATE pon_emd_transactions
          SET request_id = l_conc_req_id,
              requested_by = fnd_global.user_id,
              status_lookup_code = 'FORFEITING',
              error_message = NULL
          WHERE emd_transaction_id = l_emd_transactions_info.emd_transaction_id
          AND   emd_transaction_group_id = p_emd_trx_group_id;
        END;
      END LOOP;
  END IF;
  COMMIT;

END post_emd_forfeit_transactions;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--Start of Comments
--Name:  post_emd_forfeit_transactions
--Description  : Procedure that will be invoked from UI to process refund
--transactions
--Pre-reqs:
--Parameters:
--IN
--  p_api_version  API version
--  p_emd_trx_group_id  EMD transaction Group id
--  p_auction_header_id Auction header id
--OUT
--  x_process_complete  indicated process complete or not.
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE post_emd_refund_transactions(p_api_version        IN   NUMBER,
                                       p_emd_trx_group_id   IN   NUMBER,
                                       p_auction_header_id  IN   NUMBER,
                                       x_process_complete   OUT NOCOPY VARCHAR2)
IS

l_conc_req_id NUMBER;
l_emd_transactions        pon_emd_trx_info_Tbl_Type;
l_emd_transactions_info   pon_emd_trx_rec;

x_msg_data      VARCHAR2(1000);
l_msg_data      VARCHAR2(1000);
x_msg_count     NUMBER;
l_count         NUMBER;

BEGIN
  x_process_complete := 'TRUE';
  print_log('Inside post_emd refund transactions');
  OPEN emd_transactions_info(p_emd_trx_group_id,
                             p_auction_header_id,
                             G_EMD_REFUND);
  FETCH emd_transactions_info BULK COLLECT INTO  l_emd_transactions;
  IF (l_emd_transactions.Count = 0) THEN
    CLOSE emd_transactions_info;
    print_log('No Transactions to process');
    x_process_complete :=  'FALSE';
    RETURN;
  ELSE
    print_log('emd transaction count '|| l_emd_transactions.Count);
    CLOSE emd_transactions_info;
  END IF;

  l_conc_req_id :=  FND_REQUEST.submit_request(application    =>    'PON',
                                               program        =>    'EMD_REFUND_FORFEIT_CONC',
                                               description    =>    null,
                                               start_time     =>    null,
                                               sub_request    =>    FALSE,
                                               argument1      =>    to_char(p_api_version),
                                               argument2      =>    to_char(p_emd_trx_group_id),
                                               argument3      =>    to_char(p_auction_header_id),
                                               argument4      =>    G_EMD_REFUND);


  COMMIT;
  IF (l_conc_req_id = 0) THEN
    print_log('post_emd_transactions l_conc_req_id'||l_conc_req_id);
    fnd_message.set_name ('PON','PON_EMD_CONC_SUBMIT_FAILED');
    FND_MSG_PUB.add;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    print_log('x_msg_count: '||x_msg_count);
    IF (x_msg_count > 1) THEN
      l_count := x_msg_count;
      x_msg_data := NULL;
      LOOP
        IF nvl(l_count, 0) > 0 THEN
          l_msg_data := FND_MSG_PUB.Get(l_count, FND_API.G_FALSE);
          x_msg_data := x_msg_data ||' '|| l_msg_data;
          l_count    := nvl(l_count, 0) - 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    END IF;
   FOR j IN 1 .. l_emd_transactions.Count
   LOOP
     update_emd_trx_error_status(l_emd_transactions_info.emd_transaction_id,
                                  x_msg_data);
   END LOOP;
   x_process_complete := 'FALSE';
   RETURN;
  ELSE
    FOR j IN 1 .. l_emd_transactions.Count
      LOOP
        BEGIN
          l_emd_transactions_info := l_emd_transactions(j);
          UPDATE pon_emd_transactions
          SET request_id = l_conc_req_id,
              requested_by = fnd_global.user_id,
              status_lookup_code = 'REFUNDING',
              error_message = NULL
          WHERE emd_transaction_id = l_emd_transactions_info.emd_transaction_id
          AND   emd_transaction_group_id = p_emd_trx_group_id;
        END;
      END LOOP;
  END IF;
  COMMIT;

END post_emd_refund_transactions;

-----------------------------------------------------------------------
--Start of Comments
--Name:  emd_refund_forfiet_conc
--Description  : Procedure that will be invoked by concurrent program.Based on the
--transaction type REFUND/FORFEIT respective procedure will be invoked.
--Pre-reqs:
--Parameters:
--IN
--  p_api_version  API version
--  p_emd_trx_group_id  EMD transaction Group id
--  p_auction_header_id Auction header id
--OUT
--  x_process_complete  indicated process complete or not.
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE emd_refund_forfeit_conc(errbuf            OUT NOCOPY VARCHAR2,
                                  retcode           OUT NOCOPY VARCHAR2,
                                  p_api_version        IN   NUMBER,
                                  p_emd_trx_group_id   IN   NUMBER,
                                  p_auction_header_id  IN   NUMBER,
                                  p_emd_trx_type       IN   VARCHAR2)
IS

BEGIN
  print_log('Inside procedure emd_refund_forfeit_conc');

  if (p_emd_trx_type = G_EMD_REFUND) THEN

     process_emd_refund_trans (p_api_version,
                               p_emd_trx_group_id,
                               p_auction_header_id);
  elsif (p_emd_trx_type = G_EMD_FORFEIT) THEN
     process_emd_forfeit_trans (p_api_version,
                                p_emd_trx_group_id,
                                p_auction_header_id);
  end if;


END emd_refund_forfeit_conc;





-----------------------------------------------------------------------

--Start of Comments
--Name:  print_log
--Description  : Helper procedure for logging
--Pre-reqs:
--Parameters:
--IN:  p_message
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE print_log (p_message  IN    VARCHAR2)
IS
BEGIN
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix,
                        message  => p_message);
      END IF;
    END IF;

END print_log;

END PON_EMD_AR_INTEGRATION_GRP;

/
