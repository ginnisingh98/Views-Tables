--------------------------------------------------------
--  DDL for Package OZF_AR_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AR_PAYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvarps.pls 120.2.12010000.2 2009/07/23 19:01:09 kpatro ship $ */

------------------------------------------------------------------
-- PROCEDURE
--    Pay_Deduction
--
-- PURPOSE
--    An API to handle all kinds of payment for deduction.
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Create_AR_Payment(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
);




PROCEDURE Query_Claim(
    p_claim_id           IN    NUMBER
   ,x_claim_rec          OUT NOCOPY   OZF_Claim_PVT.claim_rec_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
);


PROCEDURE Unapply_Claim_Investigation(
       p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
      ,p_reapply_amount        IN  NUMBER

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
);


PROCEDURE Apply_On_Account_Credit(
       p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
      ,p_credit_amount         IN  NUMBER DEFAULT NULL

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
);

PROCEDURE Unapply_from_Receipt(
       p_cash_receipt_id       IN  NUMBER
      ,p_customer_trx_id       IN  NUMBER

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
);

PROCEDURE Apply_on_Receipt(
       p_cash_receipt_id              IN  NUMBER
      ,p_receipt_number               IN  VARCHAR2   DEFAULT NULL
      ,p_customer_trx_id              IN  NUMBER
      ,p_trx_number                   IN  VARCHAR2   DEFAULT NULL
      ,p_new_applied_amount           IN  NUMBER
      ,p_new_applied_from_amount      IN  NUMBER     DEFAULT NULL     --Bug4684931
      ,p_comments                     IN  VARCHAR2   DEFAULT NULL
      ,p_payment_set_id               IN  NUMBER     DEFAULT NULL
      ,p_application_ref_type         IN  VARCHAR2   DEFAULT NULL
      ,p_application_ref_id           IN  NUMBER     DEFAULT NULL
      ,p_application_ref_num          IN  VARCHAR2   DEFAULT NULL
      ,p_secondary_application_ref_id IN  NUMBER     DEFAULT NULL
      ,p_application_ref_reason       IN  VARCHAR2   DEFAULT NULL
      ,p_customer_reference           IN  VARCHAR2   DEFAULT NULL
      ,p_apply_date                   IN  DATE       DEFAULT NULL -- Fix for Bug 3091401. TM passes old apply date
      ,p_claim_id                     IN NUMBER -- Added For Rule Based Settlement
      ,x_return_status                OUT NOCOPY VARCHAR2
      ,x_msg_data                     OUT NOCOPY VARCHAR2
      ,x_msg_count                    OUT NOCOPY NUMBER
);

PROCEDURE Update_dispute_amount(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_dispute_amount         IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Create_AR_Credit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_customer_trx_id        IN    NUMBER
   ,p_deduction_type         IN    VARCHAR2
   ,p_line_remaining         IN    NUMBER      := 0
   ,p_tax_remaining          IN    NUMBER      := 0
   ,p_freight_remaining      IN    NUMBER      := 0
   ,p_line_credit            IN    NUMBER      := 0
   ,p_tax_credit             IN    NUMBER      := 0
   ,p_freight_credit         IN    NUMBER      := 0
   ,p_total_credit           IN    NUMBER
   ,p_cm_line_tbl            IN    AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE
   ,p_upd_dispute_flag       IN    VARCHAR2    := FND_API.g_false
   ,x_cm_customer_trx_id     OUT NOCOPY   NUMBER
   ,x_cm_amount              OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Create_AR_Write_Off(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_write_off_amount       IN    NUMBER
   ,p_gl_date                IN    DATE        := NULL
   ,p_wo_rec_trx_id          IN    NUMBER      := NULL

   ,x_wo_adjust_id           OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Pay_by_Invoice_Credit(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Pay_by_Credit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_payment_reference_id   IN    NUMBER
   ,p_credit_memo_amount     IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Pay_by_On_Account_Credit(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Pay_by_Chargeback(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Pay_by_Write_Off(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

PROCEDURE Pay_by_Debit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_payment_reference_id   IN    NUMBER
   ,p_debit_memo_amount      IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Pay_by_Contra_Charge(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Create_AR_Chargeback(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_chargeback_amount      IN    NUMBER
   ,p_gl_date                IN    DATE         := NULL

   ,x_cb_customer_trx_id     OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Process_Settlement_WF(
    p_claim_id               IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


PROCEDURE Pay_by_RMA_Inv_CM(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_credit_memo_amount     IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


END OZF_AR_PAYMENT_PVT;

/
