--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_BO_PVT" AS
/*$Header: ARHBCAVB.pls 120.12.12010000.2 2009/06/25 22:14:05 awu ship $ */

  -- PRIVATE PROCEDURE assign_bank_acct_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from bank account use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_bank_acct_use_obj  Bank account use object.
  --     p_party_id           Party Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_payer_context_rec Payer context plsql record.
  --     px_pmtinstrument_rec Payment instrument plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_bank_acct_use_rec(
    p_bank_acct_use_obj          IN            HZ_BANK_ACCT_USE_OBJ,
    p_party_id                   IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_payer_context_rec         IN OUT NOCOPY IBY_FNDCPT_COMMON_PUB.PayerContext_Rec_Type,
    px_pmtinstrument_rec         IN OUT NOCOPY IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_Rec_Type
  );

  -- PRIVATE PROCEDURE assign_payment_method_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from payment method object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_payment_method_rec Payment method plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_payment_method_rec(
    p_payment_method_obj         IN            HZ_PAYMENT_METHOD_OBJ,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_payment_method_rec        IN OUT NOCOPY HZ_PAYMENT_METHOD_PUB.PAYMENT_METHOD_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_profile_amt_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer profile amount object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_profile_amt_obj Customer profile amount object.
  --     p_cust_profile_id    Customer profile Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_cust_profile_amt_rec  Customer profile amount plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_profile_amt_rec(
    p_cust_profile_amt_obj       IN            HZ_CUST_PROFILE_AMT_OBJ,
    p_cust_profile_id            IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_cust_profile_amt_rec      IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_relate_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account relationship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_relate_obj   Customer account relationship object.
  --     p_cust_acct_id           Customer account Id.
  --     p_related_cust_acct_id   Related customer account Id.
  --   IN/OUT:
  --     px_cust_acct_relate_rec  Customer account relationship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_acct_relate_rec(
    p_cust_acct_relate_obj       IN            HZ_CUST_ACCT_RELATE_OBJ,
    p_cust_acct_id               IN            NUMBER,
    p_related_cust_acct_id       IN            NUMBER,
    px_cust_acct_relate_rec      IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_bank_acct_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from bank account use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_bank_acct_use_obj  Bank account use object.
  --     p_party_id           Party Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_payer_context_rec Payer context plsql record.
  --     px_pmtinstrument_rec Payment instrument plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_bank_acct_use_rec(
    p_bank_acct_use_obj          IN            HZ_BANK_ACCT_USE_OBJ,
    p_party_id                   IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_payer_context_rec         IN OUT NOCOPY IBY_FNDCPT_COMMON_PUB.PayerContext_Rec_Type,
    px_pmtinstrument_rec         IN OUT NOCOPY IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_Rec_Type
  ) IS
  BEGIN
    px_pmtinstrument_rec.assignment_id := p_bank_acct_use_obj.bank_acct_use_id;
    px_payer_context_rec.payment_function := p_bank_acct_use_obj.payment_function;
    IF(p_site_use_id IS NOT NULL) THEN
      px_payer_context_rec.org_type := p_bank_acct_use_obj.org_type;
      px_payer_context_rec.org_id := p_bank_acct_use_obj.org_id;
    ELSE
      px_payer_context_rec.org_type := NULL;
      px_payer_context_rec.org_id := NULL;
    END IF;
    px_payer_context_rec.party_id := p_party_id;
    px_payer_context_rec.cust_account_id := p_cust_acct_id;
    px_payer_context_rec.account_site_id := p_site_use_id;
    px_pmtinstrument_rec.instrument.instrument_id := p_bank_acct_use_obj.instrument_id;
    px_pmtinstrument_rec.instrument.instrument_type := p_bank_acct_use_obj.instrument_type;
    px_pmtinstrument_rec.priority := p_bank_acct_use_obj.priority;
    px_pmtinstrument_rec.start_date := p_bank_acct_use_obj.start_date;
    px_pmtinstrument_rec.end_date := p_bank_acct_use_obj.end_date;
  END assign_bank_acct_use_rec;

  -- PRIVATE PROCEDURE assign_payment_method_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from payment method object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_payment_method_rec Payment method plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_payment_method_rec(
    p_payment_method_obj         IN            HZ_PAYMENT_METHOD_OBJ,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_payment_method_rec        IN OUT NOCOPY HZ_PAYMENT_METHOD_PUB.PAYMENT_METHOD_REC_TYPE
  ) IS
  BEGIN
    px_payment_method_rec.cust_receipt_method_id := p_payment_method_obj.payment_method_id;
    px_payment_method_rec.cust_account_id := p_cust_acct_id;
    px_payment_method_rec.receipt_method_id := p_payment_method_obj.receipt_method_id;
    px_payment_method_rec.primary_flag := p_payment_method_obj.primary_flag;
    px_payment_method_rec.site_use_id := p_site_use_id;
    px_payment_method_rec.start_date := p_payment_method_obj.start_date;
    px_payment_method_rec.end_date := p_payment_method_obj.end_date;
    px_payment_method_rec.attribute_category := p_payment_method_obj.attribute_category;
    px_payment_method_rec.attribute1 := p_payment_method_obj.attribute1;
    px_payment_method_rec.attribute2 := p_payment_method_obj.attribute2;
    px_payment_method_rec.attribute3 := p_payment_method_obj.attribute3;
    px_payment_method_rec.attribute4 := p_payment_method_obj.attribute4;
    px_payment_method_rec.attribute5 := p_payment_method_obj.attribute5;
    px_payment_method_rec.attribute6 := p_payment_method_obj.attribute6;
    px_payment_method_rec.attribute7 := p_payment_method_obj.attribute7;
    px_payment_method_rec.attribute8 := p_payment_method_obj.attribute8;
    px_payment_method_rec.attribute9 := p_payment_method_obj.attribute9;
    px_payment_method_rec.attribute10 := p_payment_method_obj.attribute10;
    px_payment_method_rec.attribute11 := p_payment_method_obj.attribute11;
    px_payment_method_rec.attribute12 := p_payment_method_obj.attribute12;
    px_payment_method_rec.attribute13 := p_payment_method_obj.attribute13;
    px_payment_method_rec.attribute14 := p_payment_method_obj.attribute14;
    px_payment_method_rec.attribute15 := p_payment_method_obj.attribute15;
  END assign_payment_method_rec;

  -- PRIVATE PROCEDURE assign_cust_profile_amt_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer profile amount object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_profile_amt_obj Customer profile amount object.
  --     p_cust_profile_id    Customer profile Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_cust_profile_amt_rec  Customer profile amount plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_profile_amt_rec(
    p_cust_profile_amt_obj       IN            HZ_CUST_PROFILE_AMT_OBJ,
    p_cust_profile_id            IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_cust_profile_amt_rec      IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE
  ) IS
  BEGIN
    px_cust_profile_amt_rec.cust_acct_profile_amt_id := p_cust_profile_amt_obj.cust_acct_profile_amt_id;
    px_cust_profile_amt_rec.cust_account_profile_id  := p_cust_profile_id;
    px_cust_profile_amt_rec.cust_account_id       := p_cust_acct_id;
    px_cust_profile_amt_rec.currency_code         := p_cust_profile_amt_obj.currency_code;
    px_cust_profile_amt_rec.trx_credit_limit := p_cust_profile_amt_obj.trx_credit_limit;
    px_cust_profile_amt_rec.overall_credit_limit  := p_cust_profile_amt_obj.overall_credit_limit;
    px_cust_profile_amt_rec.min_dunning_amount    := p_cust_profile_amt_obj.min_dunning_amount;
    px_cust_profile_amt_rec.min_dunning_invoice_amount  := p_cust_profile_amt_obj.min_dunning_invoice_amount;
    px_cust_profile_amt_rec.max_interest_charge   := p_cust_profile_amt_obj.max_interest_charge;
    px_cust_profile_amt_rec.min_statement_amount  := p_cust_profile_amt_obj.min_statement_amount;
    px_cust_profile_amt_rec.auto_rec_min_receipt_amount := p_cust_profile_amt_obj.auto_rec_min_receipt_amount;
    px_cust_profile_amt_rec.interest_rate  := p_cust_profile_amt_obj.interest_rate;
    px_cust_profile_amt_rec.min_fc_balance_amount := p_cust_profile_amt_obj.min_fc_balance_amount;
    px_cust_profile_amt_rec.min_fc_invoice_amount := p_cust_profile_amt_obj.min_fc_invoice_amount;
    px_cust_profile_amt_rec.site_use_id           := p_site_use_id;
    px_cust_profile_amt_rec.expiration_date       := p_cust_profile_amt_obj.expiration_date;
    px_cust_profile_amt_rec.attribute_category    := p_cust_profile_amt_obj.attribute_category;
    px_cust_profile_amt_rec.attribute1            := p_cust_profile_amt_obj.attribute1;
    px_cust_profile_amt_rec.attribute2            := p_cust_profile_amt_obj.attribute2;
    px_cust_profile_amt_rec.attribute3            := p_cust_profile_amt_obj.attribute3;
    px_cust_profile_amt_rec.attribute4            := p_cust_profile_amt_obj.attribute4;
    px_cust_profile_amt_rec.attribute5            := p_cust_profile_amt_obj.attribute5;
    px_cust_profile_amt_rec.attribute6            := p_cust_profile_amt_obj.attribute6;
    px_cust_profile_amt_rec.attribute7            := p_cust_profile_amt_obj.attribute7;
    px_cust_profile_amt_rec.attribute8            := p_cust_profile_amt_obj.attribute8;
    px_cust_profile_amt_rec.attribute9            := p_cust_profile_amt_obj.attribute9;
    px_cust_profile_amt_rec.attribute10           := p_cust_profile_amt_obj.attribute10;
    px_cust_profile_amt_rec.attribute11           := p_cust_profile_amt_obj.attribute11;
    px_cust_profile_amt_rec.attribute12           := p_cust_profile_amt_obj.attribute12;
    px_cust_profile_amt_rec.attribute13           := p_cust_profile_amt_obj.attribute13;
    px_cust_profile_amt_rec.attribute14           := p_cust_profile_amt_obj.attribute14;
    px_cust_profile_amt_rec.attribute15           := p_cust_profile_amt_obj.attribute15;
    px_cust_profile_amt_rec.jgzz_attribute_category    := p_cust_profile_amt_obj.jgzz_attribute_category;
    px_cust_profile_amt_rec.jgzz_attribute1    := p_cust_profile_amt_obj.jgzz_attribute1;
    px_cust_profile_amt_rec.jgzz_attribute2    := p_cust_profile_amt_obj.jgzz_attribute2;
    px_cust_profile_amt_rec.jgzz_attribute3    := p_cust_profile_amt_obj.jgzz_attribute3;
    px_cust_profile_amt_rec.jgzz_attribute4    := p_cust_profile_amt_obj.jgzz_attribute4;
    px_cust_profile_amt_rec.jgzz_attribute5    := p_cust_profile_amt_obj.jgzz_attribute5;
    px_cust_profile_amt_rec.jgzz_attribute6    := p_cust_profile_amt_obj.jgzz_attribute6;
    px_cust_profile_amt_rec.jgzz_attribute7    := p_cust_profile_amt_obj.jgzz_attribute7;
    px_cust_profile_amt_rec.jgzz_attribute8    := p_cust_profile_amt_obj.jgzz_attribute8;
    px_cust_profile_amt_rec.jgzz_attribute9    := p_cust_profile_amt_obj.jgzz_attribute9;
    px_cust_profile_amt_rec.jgzz_attribute10   := p_cust_profile_amt_obj.jgzz_attribute10;
    px_cust_profile_amt_rec.jgzz_attribute11   := p_cust_profile_amt_obj.jgzz_attribute11;
    px_cust_profile_amt_rec.jgzz_attribute12   := p_cust_profile_amt_obj.jgzz_attribute12;
    px_cust_profile_amt_rec.jgzz_attribute13   := p_cust_profile_amt_obj.jgzz_attribute13;
    px_cust_profile_amt_rec.jgzz_attribute14   := p_cust_profile_amt_obj.jgzz_attribute14;
    px_cust_profile_amt_rec.jgzz_attribute15   := p_cust_profile_amt_obj.jgzz_attribute15;
    px_cust_profile_amt_rec.global_attribute_category    := p_cust_profile_amt_obj.global_attribute_category;
    px_cust_profile_amt_rec.global_attribute1  := p_cust_profile_amt_obj.global_attribute1;
    px_cust_profile_amt_rec.global_attribute2  := p_cust_profile_amt_obj.global_attribute2;
    px_cust_profile_amt_rec.global_attribute3  := p_cust_profile_amt_obj.global_attribute3;
    px_cust_profile_amt_rec.global_attribute4  := p_cust_profile_amt_obj.global_attribute4;
    px_cust_profile_amt_rec.global_attribute5  := p_cust_profile_amt_obj.global_attribute5;
    px_cust_profile_amt_rec.global_attribute6  := p_cust_profile_amt_obj.global_attribute6;
    px_cust_profile_amt_rec.global_attribute7  := p_cust_profile_amt_obj.global_attribute7;
    px_cust_profile_amt_rec.global_attribute8  := p_cust_profile_amt_obj.global_attribute8;
    px_cust_profile_amt_rec.global_attribute9  := p_cust_profile_amt_obj.global_attribute9;
    px_cust_profile_amt_rec.global_attribute10 := p_cust_profile_amt_obj.global_attribute10;
    px_cust_profile_amt_rec.global_attribute11 := p_cust_profile_amt_obj.global_attribute11;
    px_cust_profile_amt_rec.global_attribute12 := p_cust_profile_amt_obj.global_attribute12;
    px_cust_profile_amt_rec.global_attribute13 := p_cust_profile_amt_obj.global_attribute13;
    px_cust_profile_amt_rec.global_attribute14 := p_cust_profile_amt_obj.global_attribute14;
    px_cust_profile_amt_rec.global_attribute15 := p_cust_profile_amt_obj.global_attribute15;
    px_cust_profile_amt_rec.global_attribute16 := p_cust_profile_amt_obj.global_attribute16;
    px_cust_profile_amt_rec.global_attribute17 := p_cust_profile_amt_obj.global_attribute17;
    px_cust_profile_amt_rec.global_attribute18 := p_cust_profile_amt_obj.global_attribute18;
    px_cust_profile_amt_rec.global_attribute19 := p_cust_profile_amt_obj.global_attribute19;
    px_cust_profile_amt_rec.global_attribute20 := p_cust_profile_amt_obj.global_attribute20;
    px_cust_profile_amt_rec.created_by_module  := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_cust_profile_amt_rec.exchange_rate_type          := p_cust_profile_amt_obj.exchange_rate_type;
    px_cust_profile_amt_rec.min_fc_invoice_overdue_type := p_cust_profile_amt_obj.min_fc_invoice_overdue_type;
    px_cust_profile_amt_rec.min_fc_invoice_percent      := p_cust_profile_amt_obj.min_fc_invoice_percent;
    px_cust_profile_amt_rec.min_fc_balance_overdue_type := p_cust_profile_amt_obj.min_fc_balance_overdue_type;
    px_cust_profile_amt_rec.min_fc_balance_percent      := p_cust_profile_amt_obj.min_fc_balance_percent;
    px_cust_profile_amt_rec.interest_type               := p_cust_profile_amt_obj.interest_type;
    px_cust_profile_amt_rec.interest_fixed_amount       := p_cust_profile_amt_obj.interest_fixed_amount;
    px_cust_profile_amt_rec.interest_schedule_id        := p_cust_profile_amt_obj.interest_schedule_id;
    px_cust_profile_amt_rec.penalty_type                := p_cust_profile_amt_obj.penalty_type;
    px_cust_profile_amt_rec.penalty_rate                := p_cust_profile_amt_obj.penalty_rate;
    px_cust_profile_amt_rec.min_interest_charge         := p_cust_profile_amt_obj.min_interest_charge;
    px_cust_profile_amt_rec.penalty_fixed_amount        := p_cust_profile_amt_obj.penalty_fixed_amount;
    px_cust_profile_amt_rec.penalty_schedule_id         := p_cust_profile_amt_obj.penalty_schedule_id;
  END assign_cust_profile_amt_rec;

  -- PROCEDURE assign_cust_profile_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_profile_obj   Customer profile object.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_cust_profile_rec  Customer profile plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_profile_rec(
    p_cust_profile_obj           IN            HZ_CUSTOMER_PROFILE_BO,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_cust_profile_rec          IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
  ) IS
  BEGIN
    px_cust_profile_rec.cust_account_profile_id :=p_cust_profile_obj.cust_acct_profile_id;
    px_cust_profile_rec.cust_account_id :=p_cust_acct_id;
    IF(p_cust_profile_obj.status in ('A','I')) THEN
      px_cust_profile_rec.status :=p_cust_profile_obj.status;
    END IF;
    px_cust_profile_rec.collector_id :=p_cust_profile_obj.collector_id;
    px_cust_profile_rec.credit_analyst_id :=p_cust_profile_obj.credit_analyst_id;
    px_cust_profile_rec.credit_checking :=p_cust_profile_obj.credit_checking;
    px_cust_profile_rec.next_credit_review_date :=p_cust_profile_obj.next_credit_review_date;
    px_cust_profile_rec.tolerance :=p_cust_profile_obj.tolerance;
    IF(p_cust_profile_obj.discount_terms in ('Y','N')) THEN
      px_cust_profile_rec.discount_terms :=p_cust_profile_obj.discount_terms;
    END IF;
    px_cust_profile_rec.dunning_letters :=p_cust_profile_obj.dunning_letters;
    IF(p_cust_profile_obj.interest_charges in ('Y','N')) THEN
      px_cust_profile_rec.interest_charges :=p_cust_profile_obj.interest_charges;
    END IF;
    IF(p_cust_profile_obj.send_statements in ('Y','N')) THEN
      px_cust_profile_rec.send_statements :=p_cust_profile_obj.send_statements;
    END IF;
    IF(p_cust_profile_obj.credit_balance_statements in ('Y','N')) THEN
      px_cust_profile_rec.credit_balance_statements :=p_cust_profile_obj.credit_balance_statements;
    END IF;
    IF(p_cust_profile_obj.credit_hold in ('Y','N')) THEN
      px_cust_profile_rec.credit_hold :=p_cust_profile_obj.credit_hold;
    END IF;
    px_cust_profile_rec.profile_class_id :=p_cust_profile_obj.profile_class_id;
    px_cust_profile_rec.site_use_id :=p_site_use_id;
    px_cust_profile_rec.credit_rating :=p_cust_profile_obj.credit_rating;
    px_cust_profile_rec.risk_code :=p_cust_profile_obj.risk_code;
    px_cust_profile_rec.standard_terms :=p_cust_profile_obj.standard_terms;
    px_cust_profile_rec.override_terms :=p_cust_profile_obj.override_terms;
    px_cust_profile_rec.dunning_letter_set_id :=p_cust_profile_obj.dunning_letter_set_id;
    px_cust_profile_rec.interest_period_days :=p_cust_profile_obj.interest_period_days;
    px_cust_profile_rec.payment_grace_days :=p_cust_profile_obj.payment_grace_days;
    px_cust_profile_rec.discount_grace_days :=p_cust_profile_obj.discount_grace_days;
    px_cust_profile_rec.statement_cycle_id :=p_cust_profile_obj.statement_cycle_id;
    px_cust_profile_rec.account_status :=p_cust_profile_obj.account_status;
    px_cust_profile_rec.percent_collectable :=p_cust_profile_obj.percent_collectable;
    px_cust_profile_rec.autocash_hierarchy_id :=p_cust_profile_obj.autocash_hierarchy_id;
    px_cust_profile_rec.attribute_category :=p_cust_profile_obj.attribute_category;
    px_cust_profile_rec.attribute1 :=p_cust_profile_obj.attribute1;
    px_cust_profile_rec.attribute2 :=p_cust_profile_obj.attribute2;
    px_cust_profile_rec.attribute3 :=p_cust_profile_obj.attribute3;
    px_cust_profile_rec.attribute4 :=p_cust_profile_obj.attribute4;
    px_cust_profile_rec.attribute5 :=p_cust_profile_obj.attribute5;
    px_cust_profile_rec.attribute6 :=p_cust_profile_obj.attribute6;
    px_cust_profile_rec.attribute7 :=p_cust_profile_obj.attribute7;
    px_cust_profile_rec.attribute8 :=p_cust_profile_obj.attribute8;
    px_cust_profile_rec.attribute9 :=p_cust_profile_obj.attribute9;
    px_cust_profile_rec.attribute10 :=p_cust_profile_obj.attribute10;
    px_cust_profile_rec.attribute11 :=p_cust_profile_obj.attribute11;
    px_cust_profile_rec.attribute12 :=p_cust_profile_obj.attribute12;
    px_cust_profile_rec.attribute13 :=p_cust_profile_obj.attribute13;
    px_cust_profile_rec.attribute14 :=p_cust_profile_obj.attribute14;
    px_cust_profile_rec.attribute15 :=p_cust_profile_obj.attribute15;
    px_cust_profile_rec.auto_rec_incl_disputed_flag :=p_cust_profile_obj.auto_rec_incl_disputed_flag;
    px_cust_profile_rec.tax_printing_option :=p_cust_profile_obj.tax_printing_option;
    IF(p_cust_profile_obj.charge_on_fin_charge_flag in ('Y','N')) THEN
      px_cust_profile_rec.charge_on_finance_charge_flag :=p_cust_profile_obj.charge_on_fin_charge_flag;
    END IF;
    px_cust_profile_rec.grouping_rule_id :=p_cust_profile_obj.grouping_rule_id;
    px_cust_profile_rec.clearing_days :=p_cust_profile_obj.clearing_days;
    px_cust_profile_rec.jgzz_attribute_category :=p_cust_profile_obj.jgzz_attribute_category;
    px_cust_profile_rec.jgzz_attribute1 :=p_cust_profile_obj.jgzz_attribute1;
    px_cust_profile_rec.jgzz_attribute2 :=p_cust_profile_obj.jgzz_attribute2;
    px_cust_profile_rec.jgzz_attribute3 :=p_cust_profile_obj.jgzz_attribute3;
    px_cust_profile_rec.jgzz_attribute4 :=p_cust_profile_obj.jgzz_attribute4;
    px_cust_profile_rec.jgzz_attribute5 :=p_cust_profile_obj.jgzz_attribute5;
    px_cust_profile_rec.jgzz_attribute6 :=p_cust_profile_obj.jgzz_attribute6;
    px_cust_profile_rec.jgzz_attribute7 :=p_cust_profile_obj.jgzz_attribute7;
    px_cust_profile_rec.jgzz_attribute8 :=p_cust_profile_obj.jgzz_attribute8;
    px_cust_profile_rec.jgzz_attribute9 :=p_cust_profile_obj.jgzz_attribute9;
    px_cust_profile_rec.jgzz_attribute10 :=p_cust_profile_obj.jgzz_attribute10;
    px_cust_profile_rec.jgzz_attribute11 :=p_cust_profile_obj.jgzz_attribute11;
    px_cust_profile_rec.jgzz_attribute12 :=p_cust_profile_obj.jgzz_attribute12;
    px_cust_profile_rec.jgzz_attribute13 :=p_cust_profile_obj.jgzz_attribute13;
    px_cust_profile_rec.jgzz_attribute14 :=p_cust_profile_obj.jgzz_attribute14;
    px_cust_profile_rec.jgzz_attribute15 :=p_cust_profile_obj.jgzz_attribute15;
    px_cust_profile_rec.global_attribute1 :=p_cust_profile_obj.global_attribute1;
    px_cust_profile_rec.global_attribute2 :=p_cust_profile_obj.global_attribute2;
    px_cust_profile_rec.global_attribute3 :=p_cust_profile_obj.global_attribute3;
    px_cust_profile_rec.global_attribute4 :=p_cust_profile_obj.global_attribute4;
    px_cust_profile_rec.global_attribute5 :=p_cust_profile_obj.global_attribute5;
    px_cust_profile_rec.global_attribute6 :=p_cust_profile_obj.global_attribute6;
    px_cust_profile_rec.global_attribute7 :=p_cust_profile_obj.global_attribute7;
    px_cust_profile_rec.global_attribute8 :=p_cust_profile_obj.global_attribute8;
    px_cust_profile_rec.global_attribute9 :=p_cust_profile_obj.global_attribute9;
    px_cust_profile_rec.global_attribute10 :=p_cust_profile_obj.global_attribute10;
    px_cust_profile_rec.global_attribute11 :=p_cust_profile_obj.global_attribute11;
    px_cust_profile_rec.global_attribute12 :=p_cust_profile_obj.global_attribute12;
    px_cust_profile_rec.global_attribute13 :=p_cust_profile_obj.global_attribute13;
    px_cust_profile_rec.global_attribute14 :=p_cust_profile_obj.global_attribute14;
    px_cust_profile_rec.global_attribute15 :=p_cust_profile_obj.global_attribute15;
    px_cust_profile_rec.global_attribute16 :=p_cust_profile_obj.global_attribute16;
    px_cust_profile_rec.global_attribute17 :=p_cust_profile_obj.global_attribute17;
    px_cust_profile_rec.global_attribute18 :=p_cust_profile_obj.global_attribute18;
    px_cust_profile_rec.global_attribute19 :=p_cust_profile_obj.global_attribute19;
    px_cust_profile_rec.global_attribute20 :=p_cust_profile_obj.global_attribute20;
    px_cust_profile_rec.global_attribute_category :=p_cust_profile_obj.global_attribute_category;
    IF(p_cust_profile_obj.cons_inv_flag in ('Y','N')) THEN
      px_cust_profile_rec.cons_inv_flag :=p_cust_profile_obj.cons_inv_flag;
    END IF;
    px_cust_profile_rec.cons_inv_type :=p_cust_profile_obj.cons_inv_type;
    px_cust_profile_rec.autocash_hierarchy_id_for_adr :=p_cust_profile_obj.autocash_hier_id_for_adr;
    px_cust_profile_rec.lockbox_matching_option :=p_cust_profile_obj.lockbox_matching_option;
    px_cust_profile_rec.created_by_module :=HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_cust_profile_rec.review_cycle :=p_cust_profile_obj.review_cycle;
    px_cust_profile_rec.last_credit_review_date :=p_cust_profile_obj.last_credit_review_date;
    --px_cust_profile_rec.party_id :=p_cust_profile_obj.party_id;
    px_cust_profile_rec.credit_classification :=p_cust_profile_obj.credit_classification;
    px_cust_profile_rec.cons_bill_level :=p_cust_profile_obj.cons_bill_level;
    px_cust_profile_rec.late_charge_calculation_trx := p_cust_profile_obj.late_charge_calculation_trx;
    px_cust_profile_rec.credit_items_flag := p_cust_profile_obj.credit_items_flag;
    px_cust_profile_rec.disputed_transactions_flag := p_cust_profile_obj.disputed_transactions_flag;
    px_cust_profile_rec.late_charge_type := p_cust_profile_obj.late_charge_type;
    px_cust_profile_rec.late_charge_term_id := p_cust_profile_obj.late_charge_term_id;
    px_cust_profile_rec.interest_calculation_period := p_cust_profile_obj.interest_calculation_period;
    px_cust_profile_rec.hold_charged_invoices_flag := p_cust_profile_obj.hold_charged_invoices_flag;
    px_cust_profile_rec.message_text_id := p_cust_profile_obj.message_text_id;
    px_cust_profile_rec.multiple_interest_rates_flag := p_cust_profile_obj.multiple_interest_rates_flag;
    px_cust_profile_rec.charge_begin_date := p_cust_profile_obj.charge_begin_date;
  END assign_cust_profile_rec;

  -- PRIVATE PROCEDURE assign_cust_acct_relate_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account relationship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_relate_obj   Customer account relationship object.
  --     p_cust_acct_id           Customer account Id.
  --     p_related_cust_acct_id   Related customer account Id.
  --   IN/OUT:
  --     px_cust_acct_relate_rec  Customer account relationship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_acct_relate_rec(
    p_cust_acct_relate_obj       IN            HZ_CUST_ACCT_RELATE_OBJ,
    p_cust_acct_id               IN            NUMBER,
    p_related_cust_acct_id       IN            NUMBER,
    px_cust_acct_relate_rec      IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE
  ) IS
  BEGIN
    px_cust_acct_relate_rec.cust_account_id := p_cust_acct_id;
    px_cust_acct_relate_rec.related_cust_account_id := p_related_cust_acct_id;
    px_cust_acct_relate_rec.relationship_type := p_cust_acct_relate_obj.relationship_type;
    px_cust_acct_relate_rec.comments := p_cust_acct_relate_obj.comments;
    IF(p_cust_acct_relate_obj.customer_reciprocal_flag in ('Y','N')) THEN
      px_cust_acct_relate_rec.customer_reciprocal_flag := p_cust_acct_relate_obj.customer_reciprocal_flag;
    END IF;
    px_cust_acct_relate_rec.attribute_category := p_cust_acct_relate_obj.attribute_category;
    px_cust_acct_relate_rec.attribute1 := p_cust_acct_relate_obj.attribute1;
    px_cust_acct_relate_rec.attribute2 := p_cust_acct_relate_obj.attribute2;
    px_cust_acct_relate_rec.attribute3 := p_cust_acct_relate_obj.attribute3;
    px_cust_acct_relate_rec.attribute4 := p_cust_acct_relate_obj.attribute4;
    px_cust_acct_relate_rec.attribute5 := p_cust_acct_relate_obj.attribute5;
    px_cust_acct_relate_rec.attribute6 := p_cust_acct_relate_obj.attribute6;
    px_cust_acct_relate_rec.attribute7 := p_cust_acct_relate_obj.attribute7;
    px_cust_acct_relate_rec.attribute8 := p_cust_acct_relate_obj.attribute8;
    px_cust_acct_relate_rec.attribute9 := p_cust_acct_relate_obj.attribute9;
    px_cust_acct_relate_rec.attribute10 := p_cust_acct_relate_obj.attribute10;
    px_cust_acct_relate_rec.attribute11 := p_cust_acct_relate_obj.attribute11;
    px_cust_acct_relate_rec.attribute12 := p_cust_acct_relate_obj.attribute12;
    px_cust_acct_relate_rec.attribute13 := p_cust_acct_relate_obj.attribute13;
    px_cust_acct_relate_rec.attribute14 := p_cust_acct_relate_obj.attribute14;
    px_cust_acct_relate_rec.attribute15 := p_cust_acct_relate_obj.attribute15;
    IF(p_cust_acct_relate_obj.status in ('A','I')) THEN
      px_cust_acct_relate_rec.status := p_cust_acct_relate_obj.status;
    END IF;
    px_cust_acct_relate_rec.bill_to_flag := p_cust_acct_relate_obj.bill_to_flag;
    px_cust_acct_relate_rec.ship_to_flag := p_cust_acct_relate_obj.ship_to_flag;
    px_cust_acct_relate_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_cust_acct_relate_rec.org_id := p_cust_acct_relate_obj.org_id;
  END assign_cust_acct_relate_rec;

  -- PROCEDURE create_cust_profile
  --
  -- DESCRIPTION
  --     Create customer profile.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_obj             Customer profile object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_cp_id              Customer profile Id.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_cust_profile(
    p_cp_obj                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_BO,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_cp_id                   OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cp_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_cp_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create cust profile
    assign_cust_profile_rec(
      p_cust_profile_obj            => p_cp_obj,
      p_cust_acct_id                => p_ca_id,
      p_site_use_id                 => p_casu_id,
      px_cust_profile_rec           => l_cp_rec
    );

    HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
      p_customer_profile_rec        => l_cp_rec,
      p_create_profile_amt          => FND_API.G_FALSE,
      x_cust_account_profile_id     => x_cp_id,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.create_cust_profile, cust account id: '||p_ca_id||' cust site use id: '||p_casu_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- assign profile_id
    p_cp_obj.cust_acct_profile_id := x_cp_id;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_cust_profile;

  -- PROCEDURE update_cust_profile
  --
  -- DESCRIPTION
  --     Update customer profile.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_obj             Customer profile object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_cp_id              Customer profile Id.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_cust_profile(
    p_cp_obj                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_BO,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_cp_id                   OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cp_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_cp_ovn                  NUMBER;
    l_ca_id                   NUMBER;
    l_casu_id                 NUMBER;

    CURSOR get_ovn(l_ca_id NUMBER, l_casu_id NUMBER) IS
    SELECT cp.cust_account_profile_id, cp.object_version_number
    FROM HZ_CUSTOMER_PROFILES cp
    WHERE cp.cust_account_id = l_ca_id
    AND nvl(cp.site_use_id, -99) = nvl(l_casu_id, -99);

    CURSOR get_ovn_by_cpid(l_cp_id NUMBER) IS
    SELECT cp.cust_account_profile_id, cp.object_version_number, cp.cust_account_id, cp.site_use_id
    FROM HZ_CUSTOMER_PROFILES cp
    WHERE cp.cust_account_profile_id = l_cp_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT update_cp_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check if user pass in cust profile id but with different cust account id
    -- and/or site use id
    IF(p_cp_obj.cust_acct_profile_id IS NOT NULL) THEN
      OPEN get_ovn_by_cpid(p_cp_obj.cust_acct_profile_id);
      FETCH get_ovn_by_cpid INTO x_cp_id, l_cp_ovn, l_ca_id, l_casu_id;
      CLOSE get_ovn_by_cpid;
      IF(nvl(l_ca_id, -99) <> nvl(p_ca_id, -99)) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_account_id');
        FND_MSG_PUB.ADD();
        RAISE fnd_api.g_exc_error;
      END IF;
      IF(nvl(l_casu_id, -99) <> nvl(p_casu_id, -99)) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'site_use_id');
        FND_MSG_PUB.ADD();
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      OPEN get_ovn(p_ca_id, p_casu_id);
      FETCH get_ovn INTO x_cp_id, l_cp_ovn;
      CLOSE get_ovn;
    END IF;

    -- Create cust profile
    assign_cust_profile_rec(
      p_cust_profile_obj            => p_cp_obj,
      p_cust_acct_id                => p_ca_id,
      p_site_use_id                 => p_casu_id,
      px_cust_profile_rec           => l_cp_rec
    );

    l_cp_rec.cust_account_profile_id := x_cp_id;
    l_cp_rec.created_by_module := NULL;

    HZ_CUSTOMER_PROFILE_V2PUB.update_customer_profile (
      p_customer_profile_rec        => l_cp_rec,
      p_object_version_number       => l_cp_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.update_cust_profile, cust account id: '||p_ca_id||' cust site use id: '||p_casu_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- assign profile_id
    p_cp_obj.cust_acct_profile_id := x_cp_id;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO update_cp_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_CUSTOMER_PROFILES');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END update_cust_profile;

  -- PROCEDURE create_cust_profile_amts
  --
  -- DESCRIPTION
  --     Create customer profile amounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cpa_objs           List of customer profile amount objects.
  --     p_cp_id              Customer profile Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_cust_profile_amts(
    p_cpa_objs                IN OUT NOCOPY HZ_CUST_PROFILE_AMT_OBJ_TBL,
    p_cp_id                   IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cpa_rec                 HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE;
    l_cpa_id                  NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_cpa_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_cpa_objs.COUNT LOOP
      assign_cust_profile_amt_rec(
        p_cust_profile_amt_obj      => p_cpa_objs(i),
        p_cust_profile_id           => p_cp_id,
        p_cust_acct_id              => p_ca_id,
        p_site_use_id               => p_casu_id,
        px_cust_profile_amt_rec     => l_cpa_rec
      );

      HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
        p_check_foreign_key         => FND_API.G_FALSE,
        p_cust_profile_amt_rec      => l_cpa_rec,
        x_cust_acct_profile_amt_id  => l_cpa_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.create_cust_profile_amts, cust acct profile id: '||p_cp_id||' cust acct id: '||p_ca_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign profile amount id
      p_cpa_objs(i).cust_acct_profile_amt_id := l_cpa_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_cust_profile_amts;

  -- PROCEDURE save_cust_profile_amts
  --
  -- DESCRIPTION
  --     Create or update customer profile amounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cpa_objs           List of customer profile amount objects.
  --     p_cp_id              Customer profile Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_profile_amts(
    p_cpa_objs                IN OUT NOCOPY HZ_CUST_PROFILE_AMT_OBJ_TBL,
    p_cp_id                   IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cpa_rec                 HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE;
    l_cpa_id                  NUMBER;
    l_cpa_ovn                 NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_cpa_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_profile_amts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_cpa_objs.COUNT LOOP
    -- Update cust profile amount
      assign_cust_profile_amt_rec(
        p_cust_profile_amt_obj        => p_cpa_objs(i),
        p_cust_profile_id             => p_cp_id,
        p_cust_acct_id                => p_ca_id,
        p_site_use_id                 => p_casu_id,
        px_cust_profile_amt_rec       => l_cpa_rec
      );

      -- check if the role resp record is create or update
      hz_registry_validate_bo_pvt.check_cust_profile_amt_op(
        p_cust_profile_id          => p_cp_id,
        px_cust_acct_prof_amt_id   => l_cpa_rec.cust_acct_profile_amt_id,
        p_currency_code            => l_cpa_rec.currency_code,
        x_object_version_number => l_cpa_ovn
      );

      IF(l_cpa_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.check_cust_profile_amt_op, cust acct profile id: '||p_cp_id||' cust acct id: '||p_ca_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_cpa_ovn IS NULL) THEN
        HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt(
          p_check_foreign_key         => FND_API.G_FALSE,
          p_cust_profile_amt_rec      => l_cpa_rec,
          x_cust_acct_profile_amt_id  => l_cpa_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign profile amount id
        p_cpa_objs(i).cust_acct_profile_amt_id := l_cpa_id;
      ELSE
        -- clean up created_by_module for update
        l_cpa_rec.created_by_module := NULL;
        HZ_CUSTOMER_PROFILE_V2PUB.update_cust_profile_amt(
          p_cust_profile_amt_rec      => l_cpa_rec,
          p_object_version_number     => l_cpa_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign profile amount id
        p_cpa_objs(i).cust_acct_profile_amt_id := l_cpa_rec.cust_acct_profile_amt_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.save_cust_profile_amts, cust acct profile id: '||p_cp_id||' cust acct id: '||p_ca_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_cpa_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_PROFILE_AMTS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_profile_amts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_profile_amts;

  -- PROCEDURE create_cust_acct_relates
  --
  -- DESCRIPTION
  --     Create customer account relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_car_objs           List of customer account relationship objects.
  --     p_ca_id              Customer account Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_cust_acct_relates(
    p_car_objs                IN OUT NOCOPY HZ_CUST_ACCT_RELATE_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_car_rec                 HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;
    l_rca_id                  NUMBER;
    l_rca_os                  VARCHAR2(30);
    l_rca_osr                 VARCHAR2(255);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_car_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_relates(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create cust account relates
    FOR i IN 1..p_car_objs.COUNT LOOP
      -- get related cust account id
      -- check if related cust account os and osr is valid
      l_rca_id := p_car_objs(i).related_cust_acct_id;
      l_rca_os := p_car_objs(i).related_cust_acct_os;
      l_rca_osr := p_car_objs(i).related_cust_acct_osr;

      -- check cust_account_id and os+osr
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id              => l_rca_id,
        px_os              => l_rca_os,
        px_osr             => l_rca_osr,
        p_obj_type         => 'HZ_CUST_ACCOUNTS',
        p_create_or_update => 'U',
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

      -- proceed if cust_account_id and os+osr are valid
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        assign_cust_acct_relate_rec(
          p_cust_acct_relate_obj      => p_car_objs(i),
          p_cust_acct_id              => p_ca_id,
          p_related_cust_acct_id      => l_rca_id,
          px_cust_acct_relate_rec     => l_car_rec
        );

        HZ_CUST_ACCOUNT_V2PUB.create_cust_acct_relate(
          p_cust_acct_relate_rec      => l_car_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.create_cust_acct_relates, cust acct id: '||p_ca_id||' related cust acct id: '||l_rca_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.create_cust_acct_relates, cust acct id: '||p_ca_id||' related cust acct id: '||l_rca_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_cust_acct_relates;

  -- PROCEDURE save_cust_acct_relates
  --
  -- DESCRIPTION
  --     Create or update customer account relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_car_objs           List of customer account relationship objects.
  --     p_ca_id              Customer account Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_acct_relates(
    p_car_objs                IN OUT NOCOPY HZ_CUST_ACCT_RELATE_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_car_rec                  HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;
    l_rca_id                   NUMBER;
    l_rca_os                   VARCHAR2(30);
    l_rca_osr                  VARCHAR2(255);
    l_ovn                      NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_car_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_relates(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update cust account relate
    FOR i IN 1..p_car_objs.COUNT LOOP
      -- get related cust account id
      -- check if related cust account os and osr is valid
      l_rca_id := p_car_objs(i).related_cust_acct_id;
      l_rca_os := p_car_objs(i).related_cust_acct_os;
      l_rca_osr := p_car_objs(i).related_cust_acct_osr;

      -- check related cust_account_id and os+osr
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id              => l_rca_id,
        px_os              => l_rca_os,
        px_osr             => l_rca_osr,
        p_obj_type         => 'HZ_CUST_ACCOUNTS',
        p_create_or_update => 'U',
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

      -- proceed if cust_account_id and os+osr are valid
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        assign_cust_acct_relate_rec(
          p_cust_acct_relate_obj        => p_car_objs(i),
          p_cust_acct_id                => p_ca_id,
          p_related_cust_acct_id        => l_rca_id,
          px_cust_acct_relate_rec       => l_car_rec
        );

        -- check if the role resp record is create or update
        hz_registry_validate_bo_pvt.check_cust_acct_relate_op(
          p_cust_acct_id             => p_ca_id,
          p_related_cust_acct_id     => l_rca_id,
 	  p_org_id                   => l_car_rec.org_id,
          x_object_version_number => l_ovn
        );

        IF(l_ovn IS NULL) THEN
          HZ_CUST_ACCOUNT_V2PUB.create_cust_acct_relate(
            p_cust_acct_relate_rec      => l_car_rec,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );
        ELSE
          -- clean up created_by_module for update
          l_car_rec.created_by_module := NULL;
          HZ_CUST_ACCOUNT_V2PUB.update_cust_acct_relate(
            p_cust_acct_relate_rec      => l_car_rec,
            p_object_version_number     => l_ovn,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.save_cust_acct_relates, cust acct id: '||p_ca_id||' related cust acct id: '||l_rca_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.save_cust_acct_relates, cust acct id: '||p_ca_id||' related cust acct id: '||l_rca_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_car_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CUST_ACCT_RELATE_ALL');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_relates(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_acct_relates;

  -- PROCEDURE save_bank_acct_uses
  --
  -- DESCRIPTION
  --     Create or update bank account assignments.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_bank_acct_use_objs List of bank account assignment objects.
  --     p_party_id           Party Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_bank_acct_uses(
    p_bank_acct_use_objs      IN OUT NOCOPY HZ_BANK_ACCT_USE_OBJ_TBL,
    p_party_id                IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_payer_context_rec        IBY_FNDCPT_COMMON_PUB.PayerContext_Rec_Type;
    l_pmtinstrument_rec        IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_Rec_Type;
    l_assign_id                NUMBER;
    l_response                 IBY_FNDCPT_COMMON_PUB.Result_Rec_Type;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_bau_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_bank_acct_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_bank_acct_use_objs.COUNT LOOP
      assign_bank_acct_use_rec(
        p_bank_acct_use_obj          => p_bank_acct_use_objs(i),
        p_party_id                   => p_party_id,
        p_cust_acct_id               => p_ca_id,
        p_site_use_id                => p_casu_id,
        px_payer_context_rec         => l_payer_context_rec,
        px_pmtinstrument_rec         => l_pmtinstrument_rec
      );

      IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(
        p_api_version                => 1.0,
        p_commit                     => FND_API.G_FALSE,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        p_payer                      => l_payer_context_rec,
        p_assignment_attribs         => l_pmtinstrument_rec,
        x_assign_id                  => l_assign_id,
        x_response                   => l_response
      );

      -- assign bank_acct_use_id
      p_bank_acct_use_objs(i).bank_acct_use_id := l_assign_id;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.save_bank_acct_uses, cust acct id: '||p_ca_id||' cust site use id: '||p_casu_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_bank_acct_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_bau_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_bank_acct_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_bau_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_bank_acct_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_bau_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_bank_acct_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_bank_acct_uses;

  -- PROCEDURE create_payment_method
  --
  -- DESCRIPTION
  --     Create payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_payment_method(
    p_payment_method_obj      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix                 VARCHAR2(30) := '';
    l_payment_method_rec           HZ_PAYMENT_METHOD_PUB.PAYMENT_METHOD_REC_TYPE;
    l_pm_id                        NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_pm_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    assign_payment_method_rec(
      p_payment_method_obj         => p_payment_method_obj,
      p_cust_acct_id               => p_ca_id,
      p_site_use_id                => p_casu_id,
      px_payment_method_rec        => l_payment_method_rec
    );

    HZ_PAYMENT_METHOD_PUB.create_payment_method(
      p_payment_method_rec         => l_payment_method_rec,
      x_cust_receipt_method_id     => l_pm_id,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.create_payment_method, cust acct id: '||p_ca_id||' cust site use id: '||p_casu_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign payment_method_id
     p_payment_method_obj.payment_method_id := l_pm_id;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_payment_method;

  -- PROCEDURE save_payment_method
  --
  -- DESCRIPTION
  --     Create or update payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_payment_method(
    p_payment_method_obj      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix                 VARCHAR2(30) := '';
    l_payment_method_rec           HZ_PAYMENT_METHOD_PUB.PAYMENT_METHOD_REC_TYPE;
    l_lud                          DATE;
    l_pm_id                        NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_pm_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_method(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    assign_payment_method_rec(
      p_payment_method_obj         => p_payment_method_obj,
      p_cust_acct_id               => p_ca_id,
      p_site_use_id                => p_casu_id,
      px_payment_method_rec        => l_payment_method_rec
    );

    hz_registry_validate_bo_pvt.check_payment_method_op(
      p_cust_receipt_method_id     => l_payment_method_rec.cust_receipt_method_id,
      x_last_update_date           => l_lud
    );

    IF(l_lud IS NULL) THEN
      HZ_PAYMENT_METHOD_PUB.create_payment_method(
        p_payment_method_rec         => l_payment_method_rec,
        x_cust_receipt_method_id     => l_pm_id,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
      );

      -- assign payment_method_id
      p_payment_method_obj.payment_method_id := l_pm_id;
    ELSE
      HZ_PAYMENT_METHOD_PUB.update_payment_method(
        p_payment_method_rec         => l_payment_method_rec,
        px_last_update_date          => l_lud,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
      );

      -- assign payment_method_id
      p_payment_method_obj.payment_method_id := l_payment_method_rec.cust_receipt_method_id;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_bo_pvt.save_payment_method, cust acct id: '||p_ca_id||' cust site use id: '||p_casu_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_pm_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_method(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_payment_method;

  -- PROCEDURE save_cust_accts
  --
  -- DESCRIPTION
  --     Create or update customer accounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ca_objs            List of customer account objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_id          Parent Id.
  --     p_parent_os          Parent original system.
  --     p_parent_osr         Parent original system reference.
  --     p_parent_obj_type    Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_accts(
    p_ca_objs                 IN OUT NOCOPY HZ_CUST_ACCT_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_id               IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    p_parent_osr              IN            VARCHAR2,
    p_parent_obj_type         IN            VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_ca_id                   NUMBER;
    l_ca_os                   VARCHAR2(30);
    l_ca_osr                  VARCHAR2(255);
    l_parent_id               NUMBER;
    l_parent_os               VARCHAR2(30);
    l_parent_osr              VARCHAR2(255);
    l_parent_obj_type         VARCHAR2(30);
    l_cbm                     VARCHAR2(30);
  BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_id := p_parent_id;
    l_parent_os := p_parent_os;
    l_parent_osr := p_parent_osr;
    l_parent_obj_type := p_parent_obj_type;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -- Create cust accounts
      FOR i IN 1..p_ca_objs.COUNT LOOP
        HZ_CUST_ACCT_BO_PUB.do_create_cust_acct_bo(
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_obj           => p_ca_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_id            => l_ca_id,
          x_cust_acct_os            => l_ca_os,
          x_cust_acct_osr           => l_ca_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Create error occurred at hz_cust_acct_bo_pvt.save_cust_accts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -- Create/update cust accounts
      FOR i IN 1..p_ca_objs.COUNT LOOP
        HZ_CUST_ACCT_BO_PUB.do_save_cust_acct_bo(
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_obj           => p_ca_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_id            => l_ca_id,
          x_cust_acct_os            => l_ca_os,
          x_cust_acct_osr           => l_ca_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Save error occurred at hz_cust_acct_bo_pvt.save_cust_accts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_accts;

  -- PROCEDURE create_payment_methods
  --
  -- DESCRIPTION
  --     Create payment methods.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_objs Payment method objects.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008    vsegu          Created.

  PROCEDURE create_payment_methods(
    p_payment_method_objs      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
   l_debug_prefix                 VARCHAR2(30) := '';
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_pms_v2_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_payment_method_objs.COUNT LOOP

        HZ_CUST_ACCT_BO_PVT.create_payment_method(
        p_payment_method_obj => p_payment_method_objs(i),
        p_ca_id              => p_ca_id,
        p_casu_id            => p_casu_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_pms_v2_pvt;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_pms_v2_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_pms_v2_pvt;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_payment_methods;

-- PROCEDURE save_payment_methods
  --
  -- DESCRIPTION
  --     Create or update payment methods.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_objs Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008    vsegu          Created.

  PROCEDURE save_payment_methods(
    p_payment_method_objs      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix                 VARCHAR2(30) := '';
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_pm_v2_pvt;

	 -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_payment_method(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_payment_method_objs.COUNT LOOP

        HZ_CUST_ACCT_BO_PVT.save_payment_method(
        p_payment_method_obj => p_payment_method_objs(i),
        p_ca_id              => p_ca_id,
        p_casu_id            => p_casu_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_pm_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_pm_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_pm_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'RA_CUST_RECEIPT_METHODS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_payment_methods(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_payment_methods;

-- PROCEDURE save_cust_accts
  --
  -- DESCRIPTION
  --     Create or update customer accounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ca_v2_objs         List of customer account objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_id          Parent Id.
  --     p_parent_os          Parent original system.
  --     p_parent_osr         Parent original system reference.
  --     p_parent_obj_type    Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008   vsegu          Created.

  PROCEDURE save_cust_accts(
    p_ca_v2_objs                 IN OUT NOCOPY HZ_CUST_ACCT_V2_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_id               IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    p_parent_osr              IN            VARCHAR2,
    p_parent_obj_type         IN            VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_ca_id                   NUMBER;
    l_ca_os                   VARCHAR2(30);
    l_ca_osr                  VARCHAR2(255);
    l_parent_id               NUMBER;
    l_parent_os               VARCHAR2(30);
    l_parent_osr              VARCHAR2(255);
    l_parent_obj_type         VARCHAR2(30);
    l_cbm                     VARCHAR2(30);
  BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_id := p_parent_id;
    l_parent_os := p_parent_os;
    l_parent_osr := p_parent_osr;
    l_parent_obj_type := p_parent_obj_type;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -- Create cust accounts
      FOR i IN 1..p_ca_v2_objs.COUNT LOOP
        HZ_CUST_ACCT_BO_PUB.do_create_cust_acct_v2_bo(
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_v2_obj           => p_ca_v2_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_id            => l_ca_id,
          x_cust_acct_os            => l_ca_os,
          x_cust_acct_osr           => l_ca_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Create error occurred at hz_cust_acct_bo_pvt.save_cust_accts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -- Create/update cust accounts
      FOR i IN 1..p_ca_v2_objs.COUNT LOOP
        HZ_CUST_ACCT_BO_PUB.do_save_cust_acct_v2_bo(
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_v2_obj           => p_ca_v2_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_id            => l_ca_id,
          x_cust_acct_os            => l_ca_os,
          x_cust_acct_osr           => l_ca_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Save error occurred at hz_cust_acct_bo_pvt.save_cust_accts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_accts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_accts;


END hz_cust_acct_bo_pvt;

/
