--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_GRP" AS
/* $Header: ozfgclab.pls 120.14.12010000.4 2010/05/18 10:44:08 bkunjan ship $ */
-- Start of Comments
-- Package name     : OZF_CLAIM_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME                 CONSTANT  VARCHAR2(20) := 'OZF_CLAIM_GRP';
G_FILE_NAME                CONSTANT  VARCHAR2(12) := 'ozfgclab.pls';

OZF_DEBUG_HIGH_ON          CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON           CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

G_LOG_LEVEL                CONSTANT NUMBER        := FND_LOG.LEVEL_STATEMENT;

G_DEDUCTION_CLASS          CONSTANT  VARCHAR2(20) := 'DEDUCTION';
G_OVERPAYMENT_CLASS        CONSTANT  VARCHAR2(20) := 'OVERPAYMENT';
G_DEDUC_OBJ_TYPE           CONSTANT  VARCHAR2(6)  := 'DEDU';
G_CLAIM_OBJECT_TYPE        CONSTANT  VARCHAR2(30) := 'CLAM';
G_CLAIM_STATUS             CONSTANT  VARCHAR2(30) := 'OZF_CLAIM_STATUS';

G_OPEN_STATUS              CONSTANT  VARCHAR2(30) := 'OPEN';
G_CANCELLED_STATUS         CONSTANT  VARCHAR2(30) := 'CANCELLED';
G_UPDATE_EVENT             CONSTANT  VARCHAR2(30) := 'UPDATE';
G_SUBSEQUENT_APPLY_EVENT   CONSTANT  VARCHAR2(30) := 'SUBSEQUENT_APPLY';
G_SUBSEQUENT_UNAPPLY_EVENT CONSTANT  VARCHAR2(30) := 'SUBSEQUENT_UNAPPLY';
G_INVOICE                  CONSTANT  VARCHAR2(30) := 'INVOICE';




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Build_Note
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_message_name      IN   VARCHAR2  Required
--       p_token_1           IN   VARCHAR2  Optional Default:= null
--       p_token_2           IN   VARCHAR2  Optional Default:= null
--       p_token_3           IN   VARCHAR2  Optional Default:= null
--       p_token_4           IN   VARCHAR2  Optional Default:= null
--       p_token_5           IN   VARCHAR2  Optional Default:= null
--       p_token_6           IN   VARCHAR2  Optional Default:= null

--   Version : Current version 1.0
--
--   Note: This function builds a message given the name of the message and tokens
--   bugfix 4869928
--   End of Comments
--  *******************************************************

FUNCTION Build_Note (
  p_message_name IN    VARCHAR2
, p_token_1        IN    VARCHAR2:= NULL
, p_token_2        IN    VARCHAR2:= NULL
, p_token_3        IN    VARCHAR2:= NULL
, p_token_4        IN    VARCHAR2:= NULL
, p_token_5        IN    VARCHAR2:= NULL
, p_token_6        IN    VARCHAR2:= NULL
)
RETURN VARCHAR2
IS
BEGIN

IF p_message_name = 'OZF_CLAM_NOTES_STATUS_CHANGE' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_STATUS_CHANGE');
	fnd_message.set_token('STATUS_CODE', p_token_1);
	fnd_message.set_token('NEW_STATUS_CODE', p_token_2);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_STATUS_SAME' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_STATUS_SAME');
	fnd_message.set_token('STATUS_CODE', p_token_1);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_RCPT_CHANGE' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_RCPT_CHANGE');
	fnd_message.set_token('RECEIPT_NUMBER', p_token_1);
	fnd_message.set_token('NEW_RECEIPT_NUMBER', p_token_2);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_RCPT_SAME' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_RCPT_SAME');
	fnd_message.set_token('RECEIPT_NUMBER', p_token_1);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_APPLY_CHANGE' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_APPLY_CHANGE');
	fnd_message.set_token('OLD_AMOUNT', p_token_1);
	fnd_message.set_token('NEW_AMOUNT', p_token_2);
	fnd_message.set_token('AMOUNT_APPLIED_L', p_token_3);
	fnd_message.set_token('AMOUNT_APPLIED', p_token_4);
	fnd_message.set_token('RECEIPT_NUMBER', p_token_5);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_UNAPPLY_CHANGE' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_UNAPPLY_CHANGE');
	fnd_message.set_token('OLD_AMOUNT', p_token_1);
	fnd_message.set_token('NEW_AMOUNT', p_token_2);
	fnd_message.set_token('AMOUNT_APPLIED', p_token_3);
	fnd_message.set_token('RECEIPT_NUMBER', p_token_4);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_AR_BAL_ZERO' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_AR_BAL_ZERO');
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_RCPTS_UNAPPLIED' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_RCPTS_UNAPPLIED');
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_NO_SUBS_APPLY' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_NO_SUBS_APPLY');
	fnd_message.set_token('RECEIPT_NUMBER', p_token_1);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_NO_SUBS_UNAPPLY' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_NO_SUBS_UNAPPLY');
	fnd_message.set_token('RECEIPT_NUMBER', p_token_1);
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_CLAIM_PENDING' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_CLAIM_PENDING');
END IF;

IF p_message_name = 'OZF_CLAM_NOTES_CLAIM_CLOSED' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_CLAIM_CLOSED');
END IF;

IF p_message_name = 'OZF_CLAIM_NOTES_AMOUNT_UNAPPLY' THEN
	fnd_message.set_name('OZF', 'OZF_CLAIM_NOTES_AMOUNT_UNAPPLY');
	fnd_message.set_token('RECEIPT_NUMBER', p_token_1);
END IF;


IF p_message_name = 'OZF_CLAIM_NOTES_AMOUNT_ADJUST' THEN
	fnd_message.set_name('OZF', 'OZF_CLAIM_NOTES_AMOUNT_ADJUST');
	fnd_message.set_token('CLAIM_NUMBER', p_token_1);
	fnd_message.set_token('STATUS_CODE', p_token_2);
	fnd_message.set_token('NEW_CLAIM_NUMBER', p_token_3);
	fnd_message.set_token('AMOUNT_APPLIED', p_token_4);
	fnd_message.set_token('AMOUNT', p_token_5);
	fnd_message.set_token('NEW_AMOUNT', p_token_6);
END IF;

IF p_message_name = 'OZF_CLAIM_NOTES_AMOUNT_SPLIT' THEN
	fnd_message.set_name('OZF', 'OZF_CLAIM_NOTES_AMOUNT_SPLIT');
	fnd_message.set_token('OLD_AMOUNT', p_token_1);
	fnd_message.set_token('NEW_AMOUNT', p_token_2);
	fnd_message.set_token('SPLIT_AMOUNT', p_token_3);

END IF;

IF p_message_name = 'OZF_CLAM_NOTES_AFFECTED' THEN
	fnd_message.set_name('OZF', 'OZF_CLAM_NOTES_AFFECTED');
	fnd_message.set_token('CLAIM_NUMBER', p_token_1);
	fnd_message.set_token('AMOUNT_APPLIED', p_token_2);
END IF;

RETURN fnd_message.get;

END Build_Note;

---------------------------------------------------------------------
--   PROCEDURE:  Write_Log
--
--   PURPOSE: Populate log message
--
--   PARAMETERS:
--     IN:
--       p_module_name           IN   VARCHAR2              Required
--       p_log_message           IN   VARCHAR2              Required
--
--   NOTES:
--
---------------------------------------------------------------------

PROCEDURE Write_Log (
      p_module_name         IN VARCHAR2,
      p_log_message         IN VARCHAR2
)
IS
 --PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   IF OZF_DEBUG_HIGH_ON OR
      OZF_CLAIM_GRP.G_DEBUG_MODE THEN
      OZF_Utility_PVT.debug_message(p_module_name||':'||p_log_message);
   END IF;

   OZF_Utility_PVT.debug_message(
      p_log_level     => G_LOG_LEVEL,
      p_module_name   => p_module_name,
      p_text          => p_log_message
   );

    --INSERT INTO LOG_TEST VALUES(p_module_name, p_log_message);
     --COMMIT;

--EXCEPTION
-- currently no exception handled

END Write_Log;

---------------------------------------------------------------------
--   PROCEDURE:  update_parent_amounts
--
--   PURPOSE: Updates the adjusted amounts on the parent
--
--   NOTES:
--   Sahana  Created for 4969147
---------------------------------------------------------------------
PROCEDURE update_parent_amounts(
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_deduction_rec              IN  DEDUCTION_REC_TYPE
) IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Perform_Subsequent_Apply';
l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);

l_deduction_rec           DEDUCTION_REC_TYPE := p_deduction_rec;
l_pvt_claim_rec           OZF_CLAIM_PVT.claim_Rec_Type;
l_notes                   VARCHAR2(2000);
l_object_version_number   NUMBER;
l_x_note_id               NUMBER;

-- get all the parent claims
CURSOR parent_claim_csr(p_claim_id in number) IS
   SELECT root_claim_id
   ,      claim_id
   ,      object_version_number
   ,      claim_number
   ,      amount
   ,      amount_adjusted
   ,      amount_remaining
   ,      amount_settled
   ,      status_code
   ,      receipt_number
   ,      claim_class
   ,      split_from_claim_id
   FROM   ozf_claims
   WHERE  split_from_claim_id IS NULL
   AND    root_claim_id = p_claim_id
   ORDER BY claim_id desc;

CURSOR child_claim_csr(p_claim_id in number) IS
   SELECT SUM(amount)
   FROM   ozf_claims
   WHERE  split_from_claim_id = p_claim_id;

l_change_in_amount NUMBER;
l_tot_child_amt    NUMBER;
BEGIN
Write_Log(l_full_name, 'start');

x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Now sync the amount_adjusted for each parent
FOR ref_parent_claim IN parent_claim_csr(l_deduction_rec.claim_id)
LOOP
     OPEN   child_claim_csr(ref_parent_claim.claim_id);
     FETCH  child_claim_csr INTO l_tot_child_amt;
     CLOSE  child_claim_csr;

     l_change_in_amount := ref_parent_claim.amount_adjusted - NVL(l_tot_child_amt,0);

      IF l_change_in_amount <> 0 THEN
                    l_pvt_claim_rec.claim_id               := ref_parent_claim.claim_id;
                    l_pvt_claim_rec.object_version_number  := ref_parent_claim.object_version_number;
                    l_pvt_claim_rec.status_code            := ref_parent_claim.status_code;
                    l_pvt_claim_rec.amount                 := ref_parent_claim.amount - l_change_in_amount ;
                    l_pvt_claim_rec.amount_adjusted        := l_tot_child_amt;
                    l_pvt_claim_rec.amount_applied         := l_deduction_rec.amount_applied;
                    l_pvt_claim_rec.history_event_date     := l_deduction_rec.applied_date;
                    l_pvt_claim_rec.applied_receipt_id     := l_deduction_rec.applied_receipt_id;
                    l_pvt_claim_rec.applied_receipt_number := l_deduction_rec.applied_receipt_number;

                    l_notes := 'Claim Amount is changed '||
                       ' From '|| ref_parent_claim.amount ||' To '||l_pvt_claim_rec.amount||
                       ' due to Application of amount '||l_deduction_rec.amount_applied||
                       ' from Receipt Number:'||l_deduction_rec.applied_receipt_number||'.';

                   --Call Update_Claim to reflect the changes.
                   OZF_claim_PVT.Update_claim(
                    p_api_version            => 1.0,
                    p_init_msg_list          => FND_API.G_FALSE,
                    p_commit                 => FND_API.G_FALSE,
                    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status          => l_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data,
                    p_claim                  => l_pvt_claim_Rec,
                    p_event                  => G_SUBSEQUENT_APPLY_EVENT,  --G_UPDATE_EVENT
                    p_mode                   => OZF_CLAIM_UTILITY_PVT.G_AUTO_MODE,
                    x_object_version_number  => l_object_version_number
                  );
                  IF l_return_status = FND_API.G_RET_STS_ERROR then
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  Write_log(l_full_name,l_notes);
                  JTF_NOTES_PUB.create_note(
                       p_api_version        => 1.0
                      ,x_return_status      => l_return_status
                      ,x_msg_count          => x_msg_count
                      ,x_msg_data           => x_msg_data
                      ,p_source_object_id   => l_pvt_claim_rec.claim_id
                      ,p_source_object_code => 'AMS_CLAM'
                      ,p_notes              => l_notes
                      ,p_note_status        => NULL
                      ,p_entered_by         =>  FND_GLOBAL.user_id
                      ,p_entered_date       => SYSDATE
                      ,p_last_updated_by    => FND_GLOBAL.user_id
                      ,x_jtf_note_id        => l_x_note_id
                      ,p_note_type          => 'AMS_JUSTIFICATION'
                      ,p_last_update_date   => SYSDATE
                      ,p_creation_date      => SYSDATE
                  );

      END IF;
  END LOOP; -- Now sync the amount_adjusted for each parent
Write_Log(l_full_name, 'end');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
      );
END update_parent_amounts;

---------------------------------------------------------------------
--   PROCEDURE:  Create_Deduction
--
--   PURPOSE: This procedure checks information passed from AR to Claim module and then
--            calls Creat_claim function in the private package to create a claim record.
--            It returns a claim_id, cliam_number, claim reason code id and name as the result.

--   PARAMETERS:
--     IN:
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       P_deduction_Rec           IN   DEDUCTION_REC_TYPE  Required
--
--     OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER
--       x_claim_number            OUT  VARCHAR2
--
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Create_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_commit                     IN   VARCHAR2,

    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,

    P_deduction                  IN   DEDUCTION_REC_TYPE,
    x_claim_id                   OUT  NOCOPY  NUMBER,
    x_claim_number               OUT  NOCOPY  VARCHAR2
)
IS
x_claim_reason_code_id    NUMBER;
x_claim_reason_name       VARCHAR2(80);

BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OZF_CLAIM_GRP.Create_Deduction(
                   p_api_version_number,
                   p_init_msg_list,
                   p_validation_level,
                   p_commit,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_deduction,
                   x_claim_id,
                   x_claim_number,
                   x_claim_reason_code_id,
                   x_claim_reason_name
   );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
End Create_Deduction;


---------------------------------------------------------------------
--   PROCEDURE:  Create_Deduction
--
--   PURPOSE: This is modification to existing Create_Deduction procedure with two new
--            addtional parameters to return claim_reason_code_id and claim_reason_name
--            to the calling procedure.
--            This procedure checks information passed from AR to Claim module and then
--            calls Creat_claim function in the private package to create a claim record.
--            It returns a claim_id and cliam_number and cliam_reason_code and
--            claim_reason_nameas the result.
--
--   PARAMETERS:
--     IN
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       P_deduction_Rec           IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--       x_claim_id                OUT NOCOPY NUMBER,
--       x_claim_number            OUT NOCOPY VARCHAR2
--       x_claim_reason_code_id    OUT NOCOPY NUMBER
--       x_claim_reason_name       OUT NOCOPY VARCHAR2
--
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Create_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_commit                     IN   VARCHAR2,

    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE,
    x_claim_id                   OUT  NOCOPY  NUMBER,
    x_claim_number               OUT  NOCOPY  VARCHAR2,
    x_claim_reason_code_id       OUT  NOCOPY  NUMBER,
    x_claim_reason_name          OUT  NOCOPY  VARCHAR2
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Create_Deduction';
l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);
l_dummy_number            NUMBER;
--
l_deduction_rec           DEDUCTION_REC_TYPE             := p_deduction;
l_pvt_claim_rec           OZF_CLAIM_PVT.claim_rec_type;
l_cre_claim_rec           OZF_CLAIM_PVT.claim_rec_type;
l_claim_line_rec          OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_qualifier               OZF_ASSIGNMENT_QUALIFIER_PUB.qualifier_rec_type;
l_qual_deduction_rec      OZF_ASSIGNMENT_QUALIFIER_PUB.deduction_rec_type;
l_sql_stmt                VARCHAR2(1000);

CURSOR csr_get_receipt_num(cv_cash_receipt_id IN NUMBER) IS
  SELECT receipt_number
  FROM ar_cash_receipts
  WHERE cash_receipt_id = cv_cash_receipt_id;

CURSOR csr_get_trx_num(cv_customer_trx_id IN NUMBER) IS
  SELECT trx_number
  FROM ra_customer_trx
  WHERE customer_trx_id = cv_customer_trx_id;

CURSOR csr_get_trx_class(cv_cust_trx_type_id IN NUMBER) IS
  SELECT type
  FROM ra_cust_trx_types
  WHERE cust_trx_type_id = cv_cust_trx_type_id;

CURSOR csr_get_claim_info(cv_claim_id IN NUMBER) IS
  SELECT c.claim_number
  ,      c.reason_code_id
  ,      r.name
  FROM ozf_claims c
  ,    ozf_reason_codes_vl r
  WHERE c.claim_id = cv_claim_id
  AND c.reason_code_id = r.reason_code_id;


BEGIN
   --------------------- initialize -----------------------
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_CLAIM_GRP;

   Write_Log(l_full_name, 'start');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------- start -------------------------------

   -----------------------------
   -- 1. Assignment Qualifier --
   -----------------------------
   -- First, construct the deduction rec to get assignment qualifiers
   l_qual_deduction_rec.claim_id                     := l_deduction_rec.claim_id;
   l_qual_deduction_rec.claim_number                 := l_deduction_rec.claim_number;
   l_qual_deduction_rec.claim_type_id                := l_deduction_rec.claim_type_id;
   l_qual_deduction_rec.claim_date                   := l_deduction_rec.claim_date;
   l_qual_deduction_rec.due_date                     := l_deduction_rec.due_date;
   l_qual_deduction_rec.owner_id                     := l_deduction_rec.owner_id;
   l_qual_deduction_rec.amount                       := l_deduction_rec.amount;
   l_qual_deduction_rec.currency_code                := l_deduction_rec.currency_code;
   l_qual_deduction_rec.exchange_rate_type           := l_deduction_rec.exchange_rate_type;
   l_qual_deduction_rec.exchange_rate_date           := l_deduction_rec.exchange_rate_date;
   l_qual_deduction_rec.exchange_rate                := l_deduction_rec.exchange_rate;
   l_qual_deduction_rec.set_of_books_id              := l_deduction_rec.set_of_books_id;
   l_qual_deduction_rec.source_object_id             := l_deduction_rec.source_object_id;
   l_qual_deduction_rec.source_object_class          := l_deduction_rec.source_object_class;
   l_qual_deduction_rec.source_object_type_id        := l_deduction_rec.source_object_type_id;
   l_qual_deduction_rec.source_object_number         := l_deduction_rec.source_object_number;
   l_qual_deduction_rec.cust_account_id              := l_deduction_rec.cust_account_id;
   l_qual_deduction_rec.cust_billto_acct_site_id     := l_deduction_rec.cust_billto_acct_site_id;
   l_qual_deduction_rec.cust_shipto_acct_site_id     := l_deduction_rec.cust_shipto_acct_site_id;
   l_qual_deduction_rec.location_id                  := l_deduction_rec.location_id;
   l_qual_deduction_rec.reason_code_id               := l_deduction_rec.reason_code_id;
   l_qual_deduction_rec.status_code                  := l_deduction_rec.status_code;
   l_qual_deduction_rec.user_status_id               := l_deduction_rec.user_status_id;
   l_qual_deduction_rec.sales_rep_id                 := l_deduction_rec.sales_rep_id;
   l_qual_deduction_rec.collector_id                 := l_deduction_rec.collector_id;
   l_qual_deduction_rec.contact_id                   := l_deduction_rec.contact_id;
   l_qual_deduction_rec.broker_id                    := l_deduction_rec.broker_id;
   l_qual_deduction_rec.customer_ref_date            := l_deduction_rec.customer_ref_date;
   l_qual_deduction_rec.customer_ref_number          := l_deduction_rec.customer_ref_number;
   l_qual_deduction_rec.receipt_id                   := l_deduction_rec.receipt_id;
   l_qual_deduction_rec.receipt_number               := l_deduction_rec.receipt_number;
   l_qual_deduction_rec.gl_date                      := l_deduction_rec.gl_date;
   l_qual_deduction_rec.comments                     := l_deduction_rec.comments;
   l_qual_deduction_rec.deduction_attribute_category := l_deduction_rec.deduction_attribute_category;
   l_qual_deduction_rec.deduction_attribute1         := l_deduction_rec.deduction_attribute1;
   l_qual_deduction_rec.deduction_attribute2         := l_deduction_rec.deduction_attribute2;
   l_qual_deduction_rec.deduction_attribute3         := l_deduction_rec.deduction_attribute3;
   l_qual_deduction_rec.deduction_attribute4         := l_deduction_rec.deduction_attribute4;
   l_qual_deduction_rec.deduction_attribute5         := l_deduction_rec.deduction_attribute5;
   l_qual_deduction_rec.deduction_attribute6         := l_deduction_rec.deduction_attribute6;
   l_qual_deduction_rec.deduction_attribute7         := l_deduction_rec.deduction_attribute7;
   l_qual_deduction_rec.deduction_attribute8         := l_deduction_rec.deduction_attribute8;
   l_qual_deduction_rec.deduction_attribute9         := l_deduction_rec.deduction_attribute9;
   l_qual_deduction_rec.deduction_attribute10        := l_deduction_rec.deduction_attribute10;
   l_qual_deduction_rec.deduction_attribute11        := l_deduction_rec.deduction_attribute11;
   l_qual_deduction_rec.deduction_attribute12        := l_deduction_rec.deduction_attribute12;
   l_qual_deduction_rec.deduction_attribute13        := l_deduction_rec.deduction_attribute13;
   l_qual_deduction_rec.deduction_attribute14        := l_deduction_rec.deduction_attribute14;
   l_qual_deduction_rec.deduction_attribute15        := l_deduction_rec.deduction_attribute15;
   l_qual_deduction_rec.org_id                       := l_deduction_rec.org_id;

   -- Get default value of assignment manager for a deduction record
   OZF_ASSIGNMENT_QUALIFIER_PUB.Get_Deduction_Value(
       p_api_version_number => l_api_version,
       p_init_msg_list      => FND_API.G_FALSE,
       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
       p_commit             => FND_API.G_FALSE,
       x_return_status      => l_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       p_deduction          => l_qual_deduction_rec,
       x_qualifier          => l_qualifier
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- assigned the changed values.
   l_deduction_rec.claim_date               := l_qualifier.claim_date;
   l_deduction_rec.due_date                 := l_qualifier.due_date;
   l_deduction_rec.owner_id                 := l_qualifier.owner_id;
   l_deduction_rec.cust_billto_acct_site_id := l_qualifier.cust_billto_acct_site_id;
   l_deduction_rec.cust_shipto_acct_site_id := l_qualifier.cust_shipto_acct_site_id;
   l_deduction_rec.sales_rep_id             := l_qualifier.sales_rep_id;
   l_deduction_rec.contact_id               := l_qualifier.contact_id;
   l_deduction_rec.broker_id                := l_qualifier.broker_id;
   l_deduction_rec.gl_date                  := l_qualifier.gl_date;
   l_deduction_rec.comments                 := l_qualifier.comments;
   l_deduction_rec.claim_type_id            := l_qualifier.claim_type_id;
   l_deduction_rec.reason_code_id           := l_qualifier.reason_code_id;
   l_deduction_rec.customer_ref_date        := l_qualifier.customer_ref_date;
   l_deduction_rec.customer_ref_number      := l_qualifier.customer_ref_number;


   -----------------------------------------
   -- 2. Minimum required fields checking --
   -----------------------------------------
   -- First, check whether all the required fields are filled for deductions.
   -- These fields are
   --                  cust_account_id
   --                  receipt_id
   --                  currency_code
   --                  amount
   --                  source_object_type_id  (required for transaction-related deduction)
   IF l_deduction_rec.cust_account_id IS NULL OR
      l_deduction_rec.receipt_id IS NULL OR
      l_deduction_rec.currency_code IS NULL OR
      l_deduction_rec.amount IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_REQUIRED_FIELDS_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_deduction_rec.source_object_id IS NOT NULL AND
         l_deduction_rec.source_object_type_id IS NULL THEN
      -- source_object_type_id is required for transaction-related deduction.
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SRC_INFO_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   ------------------------------------------
   -- 3. Default and derive column valude  --
   ------------------------------------------
   -- Claim Investigation
   IF l_deduction_rec.source_object_id IS NULL THEN
      -- If it's a claim investigation, change the sign of the amount
      l_deduction_rec.amount := p_deduction.amount * -1;

      -- derive receipt number from receipt id.
      IF l_deduction_rec.receipt_number IS NULL THEN
         OPEN csr_get_receipt_num(l_deduction_rec.receipt_id);
         FETCH csr_get_receipt_num INTO l_deduction_rec.receipt_number;
         CLOSE csr_get_receipt_num;
      END IF;

   ELSE
   -- Invoice Releated Deduction
      l_deduction_rec.amount := p_deduction.amount;

      -- derive source_object_number from source_object_id.
      IF l_deduction_rec.source_object_number IS NULL THEN
         OPEN csr_get_trx_num(l_deduction_rec.source_object_id);
         FETCH csr_get_trx_num INTO l_deduction_rec.source_object_number;
         CLOSE csr_get_trx_num;
      END IF;

      -- BUG 3680658 Fixing
      --IF l_deduction_rec.source_object_class IS NULL THEN
         OPEN csr_get_trx_class(l_deduction_rec.source_object_type_id);
         FETCH csr_get_trx_class INTO l_deduction_rec.source_object_class;
         CLOSE csr_get_trx_class;
      --END IF;

      IF l_deduction_rec.source_object_class = 'INV' THEN
         l_deduction_rec.source_object_class := 'INVOICE';
      END IF;
   END IF;

   -- set claim class
   IF (l_deduction_rec.amount < 0) THEN
      l_pvt_claim_rec.claim_class := G_OVERPAYMENT_CLASS;
   ELSE
      l_pvt_claim_rec.claim_class := G_DEDUCTION_CLASS;
   END IF;

   -- set user_status_id as 'OPEN'
   l_deduction_rec.user_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                           'OZF_CLAIM_STATUS'
                                          ,'OPEN'
                                     );

   ----------------------------------------------
   -- 4. populate claim record for private api --
   ----------------------------------------------
   l_pvt_claim_rec.claim_id                := l_deduction_rec.claim_id;
   l_pvt_claim_rec.claim_date              := l_deduction_rec.claim_date;
   l_pvt_claim_rec.due_date                := l_deduction_rec.due_date;
   l_pvt_claim_rec.gl_date                 := l_deduction_rec.gl_date;
   l_pvt_claim_rec.owner_id                := l_deduction_rec.owner_id;
   l_pvt_claim_rec.amount                  := l_deduction_rec.amount;
   l_pvt_claim_rec.currency_code           := l_deduction_rec.currency_code;
   l_pvt_claim_rec.exchange_rate_type      := l_deduction_rec.exchange_rate_type;
   l_pvt_claim_rec.exchange_rate_date      := l_deduction_rec.exchange_rate_date;
   l_pvt_claim_rec.exchange_rate           := l_deduction_rec.exchange_rate;
   l_pvt_claim_rec.set_of_books_id         := l_deduction_rec.set_of_books_id;
   l_pvt_claim_rec.receipt_id              := l_deduction_rec.receipt_id;
   l_pvt_claim_rec.receipt_number          := l_deduction_rec.receipt_number;
   l_pvt_claim_rec.source_object_id        := l_deduction_rec.source_object_id;
   l_pvt_claim_rec.source_object_class     := l_deduction_rec.source_object_class;
   l_pvt_claim_rec.source_object_type_id   := l_deduction_rec.source_object_type_id;
   l_pvt_claim_rec.source_object_number    := l_deduction_rec.source_object_number;
   l_pvt_claim_rec.cust_account_id         := l_deduction_rec.cust_account_id;
   l_pvt_claim_rec.ship_to_cust_account_id := l_deduction_rec.ship_to_cust_account_id;
   l_pvt_claim_rec.cust_billto_acct_site_id:=l_deduction_rec.cust_billto_acct_site_id;
   l_pvt_claim_rec.cust_shipto_acct_site_id:=l_deduction_rec.cust_shipto_acct_site_id;
   l_pvt_claim_rec.location_id             := l_deduction_rec.location_id;
   l_pvt_claim_rec.claim_type_id           := l_deduction_rec.claim_type_id;
   l_pvt_claim_rec.reason_code_id          := l_deduction_rec.reason_code_id;
   l_pvt_claim_rec.status_code             := l_deduction_rec.status_code;
   l_pvt_claim_rec.user_status_id          := l_deduction_rec.user_status_id;
   l_pvt_claim_rec.sales_rep_id            := l_deduction_rec.sales_rep_id;
   l_pvt_claim_rec.collector_id            := l_deduction_rec.collector_id;
   l_pvt_claim_rec.contact_id              := l_deduction_rec.contact_id;
   l_pvt_claim_rec.broker_id               := l_deduction_rec.broker_id;
   l_pvt_claim_rec.customer_ref_date       := l_deduction_rec.customer_ref_date;
   l_pvt_claim_rec.customer_ref_number     := l_deduction_rec.customer_ref_number;
   l_pvt_claim_rec.comments                := l_deduction_rec.comments;
   l_pvt_claim_rec.deduction_attribute_category := l_deduction_rec.deduction_attribute_category;
   l_pvt_claim_rec.deduction_attribute1    := l_deduction_rec.deduction_attribute1;
   l_pvt_claim_rec.deduction_attribute2    := l_deduction_rec.deduction_attribute2;
   l_pvt_claim_rec.deduction_attribute3    := l_deduction_rec.deduction_attribute3;
   l_pvt_claim_rec.deduction_attribute4    := l_deduction_rec.deduction_attribute4;
   l_pvt_claim_rec.deduction_attribute5    := l_deduction_rec.deduction_attribute5;
   l_pvt_claim_rec.deduction_attribute6    := l_deduction_rec.deduction_attribute6;
   l_pvt_claim_rec.deduction_attribute7    := l_deduction_rec.deduction_attribute7;
   l_pvt_claim_rec.deduction_attribute8    := l_deduction_rec.deduction_attribute8;
   l_pvt_claim_rec.deduction_attribute9    := l_deduction_rec.deduction_attribute9;
   l_pvt_claim_rec.deduction_attribute10   := l_deduction_rec.deduction_attribute10;
   l_pvt_claim_rec.deduction_attribute11   := l_deduction_rec.deduction_attribute11;
   l_pvt_claim_rec.deduction_attribute12   := l_deduction_rec.deduction_attribute12;
   l_pvt_claim_rec.deduction_attribute13   := l_deduction_rec.deduction_attribute13;
   l_pvt_claim_rec.deduction_attribute14   := l_deduction_rec.deduction_attribute14;
   l_pvt_claim_rec.deduction_attribute15   := l_deduction_rec.deduction_attribute15;
   l_pvt_claim_rec.org_id                  := l_deduction_rec.org_id;
   l_pvt_claim_rec.customer_reason         := l_deduction_rec.customer_reason;
   l_pvt_claim_rec.amount_applied          := l_deduction_rec.amount_applied;
   l_pvt_claim_rec.applied_receipt_id      := l_deduction_rec.applied_receipt_id;
   l_pvt_claim_rec.applied_receipt_number  := l_deduction_rec.applied_receipt_number;
   l_pvt_claim_rec.legal_entity_id  := l_deduction_rec.legal_entity_id;

   -------------------------------------------------------
   -- 5. Check claim common element thought private api --
   -------------------------------------------------------
   OZF_CLAIM_PVT.Check_Claim_Common_Element (
       p_api_version        => l_api_version,
       p_init_msg_list      => FND_API.g_false,
       p_validation_level   => FND_API.g_valid_level_full,
       x_return_status      => l_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       p_claim              => l_pvt_claim_rec,
       x_claim              => l_cre_claim_rec
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -------------------------------------------------------
   -- 6. Create claim
   -------------------------------------------------------
   OZF_CLAIM_PVT.Create_Claim(
         p_api_version        => l_api_version,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_claim              => l_cre_claim_rec,
         x_claim_id           => x_claim_id
   );
   -- Check return status from the above procedure call
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -------------------------------------------------------
   -- 7. Assign value to OUT parameters
   -------------------------------------------------------
   OPEN csr_get_claim_info(x_claim_id);
   FETCH csr_get_claim_info INTO x_claim_number
                               , x_claim_reason_code_id
                               , x_claim_reason_name;
   CLOSE csr_get_claim_info;

   -------------------------------------------------------
   -- 8. Populate claim line record
   -------------------------------------------------------
   -- Calling Private package: Create_claim_Line
   IF l_deduction_rec.source_object_id IS NULL THEN
      l_claim_line_rec.claim_id              := x_claim_id;
      l_claim_line_rec.comments              := l_deduction_rec.receipt_number;
      -- l_claim_line_rec.item_description      := l_deduction_rec.receipt_number;
      l_claim_line_rec.claim_currency_amount := l_deduction_rec.amount;
   ELSE
      l_claim_line_rec.claim_id              := x_claim_id;
      l_claim_line_rec.source_object_id      := l_deduction_rec.source_object_id;
      l_claim_line_rec.source_object_class   := l_deduction_rec.source_object_class;
      l_claim_line_rec.source_object_type_id := l_deduction_rec.source_object_type_id;
      l_claim_line_rec.claim_currency_amount := l_deduction_rec.amount;
   END IF;

   -------------------------------------------------------
   -- 9. Create claim line
   -------------------------------------------------------
   OZF_CLAIM_Line_PVT.Create_Claim_Line(
         p_api_version        => l_api_version,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_claim_line_rec     => l_claim_line_rec,
         x_claim_line_id      => l_dummy_number
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  ------------------------- finish -------------------------------
   Write_Log(l_full_name, 'end');


   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||'End');
      FND_MSG_PUB.Add;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_CLAIM_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_CLAIM_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_CLAIM_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

End Create_Deduction;


-- -------------------------------------------------------------------------------------------
-- PROCEDURE
--    Check_Update_Allowed
--
-- PURPOSE
--    This procedure Checks whether update is allowed on give claim id.
--
-- PARAMETERS
--    p_deduction_rec         : Deduction Record
--    x_Applicable_Claims_Tbl : Default OUT record.
--    x_Notes_Tbl             : Default OUT record.
--
-- NOTES
----------------------------------------------------------------------------------------------
PROCEDURE Check_Update_Allowed(
      p_deduction_rec          IN  DEDUCTION_REC_TYPE,
      x_applicable_claims_tbl  OUT NOCOPY DEDUCTION_TBL_TYPE,
      x_notes_tbl              OUT NOCOPY CLAIM_NOTES_TBL_TYPE,
      x_update_allowed_flag    OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Check_Update_Allowed';
l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);

l_deduction_rec           DEDUCTION_REC_TYPE := p_deduction_rec;
l_applicable_claims_tbl   DEDUCTION_TBL_TYPE;
l_notes_tbl               CLAIM_NOTES_TBL_TYPE;
l_notes                   VARCHAR2(2000);
l_record_count            NUMBER:=0;
l_ar_receipt_amount       NUMBER;
l_new_deduction_amount  NUMBER;
l_deduction_amount        NUMBER;
l_new_status_code         VARCHAR2(30);
l_amount_applied          NUMBER := 0;

l_root_amount             NUMBER;

-- get existing claim details.
CURSOR split_claim_csr(p_claim_id in number) IS
   SELECT root_claim_id
   ,      claim_id
   ,      object_version_number
   ,      claim_number
   ,      amount
   ,      amount_adjusted
   ,      amount_remaining
   ,      amount_settled
   ,      status_code
   ,      receipt_number
   ,      claim_class
   ,      appr_wf_item_key
   ,      split_from_claim_id
    FROM   ozf_claims
   WHERE  root_claim_id = p_claim_id
   ORDER BY claim_id desc;

     l_is_overpayment BOOLEAN := FALSE;

BEGIN
   --------------------- initialize -----------------------
   Write_Log(l_full_name, 'start');

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   l_ar_receipt_amount := l_deduction_rec.amount_applied;
   l_root_amount := ABS(l_deduction_rec.amount);

   x_update_allowed_flag := 'Y';
   l_record_count := 0;
   -- Loop through split claims - adjusting the amounts and setting status
   FOR ref_split_claim_csr IN split_claim_csr (l_deduction_rec.claim_id) LOOP
    l_notes := NULL;

    IF ref_split_claim_csr.status_code <> 'CLOSED' AND ref_split_claim_csr.amount_remaining <> 0 THEN

      l_record_count := l_record_count + 1;

      l_notes := 'Claim is affected due to application of Receipt:'||l_deduction_rec.applied_receipt_number||
                       ' with Applied Amount:'||l_deduction_rec.amount_applied || '.';
      l_new_deduction_amount := 0;
      l_deduction_amount := ABS(ref_split_claim_csr.amount_remaining);

      IF ref_split_claim_csr.claim_class = 'OVERPAYMENT' THEN
          l_is_overpayment := TRUE;
      END IF;

      IF l_root_amount > 0 THEN
          l_new_status_code         := 'OPEN';
          IF l_root_amount  < l_deduction_amount THEN
              l_new_deduction_amount  := l_root_amount;
              l_root_amount    := 0;

          ELSE  ---  l_root_amount  >= l_deduction_amount
              l_new_deduction_amount :=  l_deduction_amount;
              l_root_amount := l_root_amount - l_deduction_amount;
          END IF;

          IF l_is_overpayment THEN
              l_deduction_amount     := l_deduction_amount * -1;
              l_new_deduction_amount := l_new_deduction_amount * -1;
              l_ar_receipt_amount    := l_ar_receipt_amount * -1;
          END IF;

          l_notes := l_notes||' Amount is Changed '||
                          'From '||ref_split_claim_csr.AMOUNT||
                          ' To '||l_new_deduction_amount || '.';

          IF ref_split_claim_csr.status_code = 'OPEN' THEN
                   l_notes := l_notes||' Status is not Changed. ';
          ELSE
                   l_notes := l_notes|| ' Status is Changed '||
                             'From '|| ref_split_claim_csr.status_code ||' To OPEN. ';
          END IF;

       ELSE  --- l_root_amount <= 0

          --- Cancel Claims. Amounts are unchanged.
          l_deduction_amount      := 0;
          l_new_deduction_amount  := l_deduction_amount;
          l_new_status_code       := 'CANCELLED';

          IF l_is_overpayment THEN
              l_ar_receipt_amount    := l_ar_receipt_amount * -1;
          END IF;

          --Build Notes
          l_notes := l_notes||' Amount is Changed '||
                          'From '||ref_split_claim_csr.AMOUNT||
                          ' To '||l_new_deduction_amount || '.';

          IF ref_split_claim_csr.status_code = 'CANCELLED' THEN
                   l_notes := l_notes||' Status is not Changed. ';
          ELSE
             l_notes := l_notes|| ' Status is Changed '||
                         'From '|| ref_split_claim_csr.status_code ||' To CANCELLED. ';
          END IF;

     END IF;  --- l_root_amount > 0


     IF l_deduction_rec.source_object_id IS NOT NULL AND
         l_deduction_rec.source_object_id <> FND_API.G_MISS_NUM THEN
         -- Build Notes  :for transaction releated deduction

         IF l_deduction_rec.receipt_number <> ref_split_claim_csr.receipt_number THEN
            l_notes := l_notes||' Receipt Reference is Changed '||
                   'From '||ref_split_claim_csr.receipt_number||' To '||l_deduction_rec.receipt_number||'.';
         ELSE
            l_notes := l_notes||' Receipt Reference '||ref_split_claim_csr.RECEIPT_NUMBER||' is not Changed.';
         END IF;
         l_applicable_claims_tbl(l_record_count).receipt_id     := l_deduction_rec.receipt_id;
         l_applicable_claims_tbl(l_record_count).receipt_number := l_deduction_rec.receipt_number;
     ELSE
         -- Build Notes  :for claim investigation
         l_notes := l_notes||' Receipt Reference '||ref_split_claim_csr.RECEIPT_NUMBER||' is not Changed.';
     END IF;

     -- Populate table of deduction record as OUT parameter.
     -- Note: Used OWNER ID to store root cliam id
     l_applicable_claims_tbl(l_record_count).owner_id              := ref_split_claim_csr.split_from_claim_id;
     l_applicable_claims_tbl(l_record_count).claim_id              := ref_split_claim_csr.claim_id;
     l_applicable_claims_tbl(l_record_count).object_version_number := ref_split_claim_csr.object_version_number;
     l_applicable_claims_tbl(l_record_count).status_code           := l_new_status_code;
     l_applicable_claims_tbl(l_record_count).currency_code         := l_deduction_rec.currency_code;
     l_applicable_claims_tbl(l_record_count).exchange_rate_type    := l_deduction_rec.exchange_rate_type;
     l_applicable_claims_tbl(l_record_count).exchange_rate_date    := l_deduction_rec.exchange_rate_date;
     l_applicable_claims_tbl(l_record_count).exchange_rate         := l_deduction_rec.exchange_rate;
     l_applicable_claims_tbl(l_record_count).amount := l_new_deduction_amount + ref_split_claim_csr.amount_adjusted;
     l_applicable_claims_tbl(l_record_count).amount_adjusted := ref_split_claim_csr.amount_adjusted;
     l_applicable_claims_tbl(l_record_count).amount_settled := 0;
     l_applicable_claims_tbl(l_record_count).amount_remaining  := l_new_deduction_amount;
     l_applicable_claims_tbl(l_record_count).amount_applied := l_ar_receipt_amount;

     -- [Begin of Debug Message]
     Write_Log(l_full_name, '---------------------');
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').split_from_claim_id         = '||l_applicable_claims_tbl(l_record_count).owner_id);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').claim_id         = '||l_applicable_claims_tbl(l_record_count).claim_id);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount           = '||l_applicable_claims_tbl(l_record_count).amount);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount_adjusted  = '||l_applicable_claims_tbl(l_record_count).amount_adjusted);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount_remaining = '||l_applicable_claims_tbl(l_record_count).amount_remaining);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount_settled   = '||l_applicable_claims_tbl(l_record_count).amount_settled);
     Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').status_code      = '||l_applicable_claims_tbl(l_record_count).status_code);

     --Populate table of Notes record as OUT parameter.
     l_notes_tbl(l_record_count).claim_notes := l_notes;
     Write_Log(l_full_name, 'l_notes_tbl('||l_record_count||').claim_notes  = ' ||l_notes_tbl(l_record_count).claim_notes);

     --Bigfix : 9715132
    END IF; -- status <> CLOSED
  END LOOP;

      --//Bugfix : 7526516
      IF l_root_amount > 0 THEN
      --  This means receipt was unapplied and applied with lesser amount.
      --  Eg $10 was applied to $100 receipt. This was then changed to $5.
      --  Add the excess to the last claim in the table
      IF  l_is_overpayment THEN
         l_root_amount := l_root_amount * -1;
      END IF;
      l_applicable_claims_tbl(l_record_count).amount := l_applicable_claims_tbl(l_record_count).amount + l_root_amount ;
      l_applicable_claims_tbl(l_record_count).amount_remaining  := l_applicable_claims_tbl(l_record_count).amount_remaining + l_root_amount ;

      -- [Begin of Debug Message]
      Write_Log(l_full_name, '---------------------');
      Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').claim_id         = '||l_applicable_claims_tbl(l_record_count).claim_id);
      Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount           = '||l_applicable_claims_tbl(l_record_count).amount);
      Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount_adjusted  = '||l_applicable_claims_tbl(l_record_count).amount_adjusted);
      Write_Log(l_full_name, 'x_applicable_claims_tbl('||l_record_count||').amount_remaining = '||l_applicable_claims_tbl(l_record_count).amount_remaining);

   END IF;



   --Assign to OUT parameter
   x_applicable_claims_tbl := l_applicable_claims_tbl;
   x_notes_tbl             := l_notes_tbl;

   Write_Log(l_full_name, 'end');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.set_name('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_full_name||'An error happened in '||l_full_name);
      FND_MSG_PUB.add;

END Check_Update_Allowed;


-- -------------------------------------------------------------------------------------------
--   PROCEDURE:  Perform_Subsequent_Apply
--
--   PURPOSE  :
--   This procedure perform Subsequent Application.
--   It calls the Update_claim proceudre in the private package.
--
--   PARAMETERS:
--   IN:
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_object_version_number   OUT  NUMBER
--
--   Note:
--
----------------------------------------------------------------------------------------------
PROCEDURE Perform_Subsequent_Apply(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_deduction                  IN  DEDUCTION_REC_TYPE
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Perform_Subsequent_Apply';
l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);

l_object_version_number   NUMBER;
l_deduction_rec           DEDUCTION_REC_TYPE := p_deduction;
l_pvt_claim_rec           OZF_CLAIM_PVT.claim_Rec_Type;
l_applicable_claims_tbl   DEDUCTION_TBL_TYPE;
l_notes_tbl               CLAIM_NOTES_TBL_TYPE;
l_claim_obj_ver_num       NUMBER;
l_claim_count             NUMBER := 0;
l_claim_amount            NUMBER := 0;
l_receipt_number          VARCHAR2(30);
l_split_flag              VARCHAR2(3);
l_notes                   VARCHAR2(2000);
l_status_code             VARCHAR2(30);
l_new_status_code         VARCHAR2(30);
l_update_allowed_flag     VARCHAR2(1);
l_x_note_id               NUMBER;
l_claim_class             VARCHAR2(30);
l_amount_remaining        NUMBER:= 0;
l_new_amount_adjusted     NUMBER:= 0;
l_total_amount_applied    NUMBER:= 0;
l_source_object_id        NUMBER;

-- get Count for given claim_id
CURSOR get_claim_count_csr (p_claim_id in number) IS
   SELECT count(claim_id)
   FROM   ozf_claims
   WHERE  root_claim_id = p_claim_id;

-- get existing claim details.
CURSOR get_claim_detail_csr (p_claim_id in number) IS
   SELECT status_code
   ,      amount
   ,      receipt_number
   ,      claim_class
   ,      source_object_id
   FROM ozf_claims
   WHERE claim_id = p_claim_id;

-- get existing claim details.
CURSOR split_claim_csr(p_claim_id in number) IS
   SELECT root_claim_id
   ,      claim_id
   ,      object_version_number
   ,      claim_number
   ,      amount,amount_adjusted
   ,      amount_remaining
   ,      amount_settled
   ,      receipt_number
   ,      status_code
   FROM ozf_claims
   WHERE root_claim_id = p_claim_id
   AND status_code <> 'CLOSED'
   ORDER BY claim_id;

   -- get all the parent claims
CURSOR parent_claim_csr(p_claim_id in number) IS
   SELECT root_claim_id
   ,      claim_id
   ,      object_version_number
   ,      claim_number
   ,      amount
   ,      amount_adjusted
   ,      amount_remaining
   ,      amount_settled
   ,      status_code
   ,      receipt_number
   ,      claim_class
   ,      split_from_claim_id
   FROM   ozf_claims
   WHERE  split_from_claim_id IS NULL
   AND    root_claim_id = p_claim_id
   ORDER BY claim_id desc;

CURSOR child_claim_csr(p_claim_id in number) IS
   SELECT SUM(amount)
   FROM   ozf_claims
   WHERE  split_from_claim_id = p_claim_id;

l_change_in_amount NUMBER;
l_tot_child_amt    NUMBER;

BEGIN
   --------------------- initialize -----------------------
   Write_Log(l_full_name, 'start');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check if the claim has any splits.
   OPEN get_claim_count_csr(l_deduction_rec.claim_id);
   FETCH get_claim_count_csr INTO l_claim_count;
   CLOSE get_claim_count_csr;

   IF l_claim_count = 1 THEN
      l_split_flag := 'NO';
   ELSIF l_claim_count > 1 THEN
      l_split_flag := 'YES';
   ELSE
      l_split_flag := NULL;
   END IF;



   --Deal with amount sign in case of OVERPAYMENTS
   OPEN get_claim_detail_csr(l_deduction_rec.claim_id);
   FETCH get_claim_detail_csr INTO l_status_code
                                 , l_claim_amount
                                 , l_receipt_number
                                 , l_claim_class
                                 , l_source_object_id;
   CLOSE get_claim_detail_csr;

   IF l_claim_class = 'OVERPAYMENT' THEN
      IF l_deduction_rec.amount > 0 THEN
         l_deduction_rec.amount         := l_deduction_rec.amount * -1;
         l_deduction_rec.amount_applied := l_deduction_rec.amount_applied * -1;
      END IF;
   ELSIF l_claim_class = 'DEDUCTION' AND
        (l_source_object_id IS NULL OR l_source_object_id = FND_API.g_miss_num) THEN
      IF l_deduction_rec.amount < 0 THEN
         l_deduction_rec.amount         := l_deduction_rec.amount * -1;
      END IF;
   END IF;


   Write_Log(l_full_name, 'l_deduction_rec.amount = '||l_deduction_rec.amount);
   Write_Log(l_full_name, 'l_deduction_rec.amount_applied = '||l_deduction_rec.amount_applied);
   Write_Log(l_full_name, 'Split ? '||l_split_flag);


   -- -----------------
   -- No Split Scenario
   -- -----------------
   IF l_split_flag = 'NO' THEN

      IF l_status_code <> 'CLOSED' THEN
         IF l_status_code = 'PENDING_CLOSE' THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_STATUS_PENDING_CLOSE');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- ---------------------
         -- Fully Apply
         -- ---------------------
         IF l_deduction_rec.amount = 0 THEN
            --Build Notes. not required
            -- l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
	    -- Build Notes(29)
            --l_notes := l_notes||'New Balance Amount from AR is Zero, Current Status of cliam was changed From '||
            --          l_status_code||' To CANCELLED';

	    --bugfix 4869928
	    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_AR_BAL_ZERO');
	    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE',l_status_code,'CANCELLED' );

            l_new_status_code := 'CANCELLED';

            Write_Log(l_full_name, 'Full Apply - Cancelling Claim');

         -- ---------------------
         -- Partial Apply
         -- ---------------------
         ELSE
            -- Build Notes(30)
            IF l_status_code = 'OPEN' THEN
               --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
               --l_notes := l_notes||' Claim Remaining Balance is changed '||
               --           'From '||l_claim_amount||
               --           ' To '||l_deduction_rec.AMOUNT||
               --           ' due to Application of amount '||l_deduction_rec.AMOUNT_APPLIED||
               --           ' and Status is OPEN, remains the Same';

        	   --bugfix 4869928
	      l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_APPLY_CHANGE',
						TO_CHAR(l_claim_amount),
						TO_CHAR(l_deduction_rec.AMOUNT),
						TO_CHAR(l_deduction_rec.AMOUNT_APPLIED),
						TO_CHAR(l_deduction_rec.amount_applied),
						TO_CHAR(l_deduction_rec.applied_receipt_number)
						);
	      l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_STATUS_SAME', 'OPEN');




            ELSE
               --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
	       -- Build Notes(31)
               --l_notes := l_notes||' Claim Remaining Balance is changed '||
               --           'From '||l_claim_amount||
               --           ' To '||l_deduction_rec.AMOUNT||
               --           ' due to Application of amount '||l_deduction_rec.AMOUNT_APPLIED||
               --           ' (Receipt Number:'||l_deduction_rec.applied_receipt_number||')'||
               --           ' and Status is Changed '||
               --           'From '||l_status_code||' To OPEN';
 	      --bugfix 4869928
        	   l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_APPLY_CHANGE',
							TO_CHAR(l_claim_amount),
							TO_CHAR(l_deduction_rec.AMOUNT),
							TO_CHAR(l_deduction_rec.AMOUNT_APPLIED),
							TO_CHAR(l_deduction_rec.amount_applied),
							TO_CHAR(l_deduction_rec.applied_receipt_number)
							);
	           l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE', l_status_code, 'OPEN');


            END IF;
            l_new_status_code := 'OPEN';
             Write_Log(l_full_name, 'Partial Apply - Adjusting Amount');

         END IF;

         --Build Claim Rec.
         l_pvt_claim_rec.claim_id               := l_deduction_rec.claim_id;
         l_pvt_claim_rec.object_version_number  := l_deduction_rec.object_version_number;
         l_pvt_claim_rec.amount                 := l_deduction_rec.amount;
         l_pvt_claim_rec.currency_code          := l_deduction_rec.currency_code;
         l_pvt_claim_rec.exchange_rate_type     := l_deduction_rec.exchange_rate_type;
         l_pvt_claim_rec.exchange_rate_date     := l_deduction_rec.exchange_rate_date;
         l_pvt_claim_rec.exchange_rate          := l_deduction_rec.exchange_rate;
         l_pvt_claim_rec.status_code            := l_new_status_code;

         IF l_deduction_rec.source_object_id IS NOT NULL AND
            l_deduction_rec.source_object_id <> FND_API.G_MISS_NUM THEN
            --Transaction 8/22/2005Releated deduction
            l_pvt_claim_rec.receipt_id                   := l_deduction_rec.receipt_id;
            l_pvt_claim_rec.receipt_number               := l_deduction_rec.receipt_number;

            -- Build Notes (32)
            --l_notes := l_notes||' and Receipt Reference is Changed '||
            --           'From '||l_receipt_number||' To '||l_deduction_rec.RECEIPT_NUMBER||'.]';

	       -- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_CHANGE', TO_CHAR(l_receipt_number), TO_CHAR(l_deduction_rec.RECEIPT_NUMBER));

         ELSE
            -- Claim Investigation
            -- Build Notes(33)
            --l_notes := l_notes||' and Receipt Reference '||l_receipt_number||' is not Changed.]';

		-- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_SAME', TO_CHAR(l_receipt_number) );

         END IF;

         --Assign Applied Details
         l_pvt_claim_rec.history_event_date     := l_deduction_rec.applied_date;
         l_pvt_claim_rec.amount_applied         := l_deduction_rec.amount_applied;
         l_pvt_claim_rec.applied_receipt_id     := NVL(l_deduction_rec.applied_receipt_id,l_deduction_rec.receipt_id);
         l_pvt_claim_rec.applied_receipt_number := NVL(l_deduction_rec.applied_receipt_number,l_deduction_rec.receipt_number);

         -- [Begin of Debug Message]
         Write_Log(l_full_name, 'applicable claim.amount                 = '||l_pvt_claim_rec.amount);
         Write_Log(l_full_name, 'applicable claim.amount_applied         = '||l_pvt_claim_rec.amount_applied);
         Write_Log(l_full_name, 'applicable claim.status_code            = '||l_pvt_claim_rec.status_code);
         Write_Log(l_full_name, 'applicable claim.receipt_id             = '||l_pvt_claim_rec.receipt_id);
         Write_Log(l_full_name, 'applicable claim.receipt_number         = '||l_pvt_claim_rec.receipt_number);
         Write_Log(l_full_name, 'applicable claim.applied_receipt_id     = '||l_pvt_claim_rec.applied_receipt_id);
         Write_Log(l_full_name, 'applicable claim.applied_receipt_number = '||l_pvt_claim_rec.applied_receipt_number);
         -- [End of Debug Message]

         -- Call Update_Claim to reflect the changes.
         OZF_claim_PVT.Update_claim(
              p_api_version           => 1.0,
              p_init_msg_list         => FND_API.G_FALSE,
              p_commit                => FND_API.G_FALSE,
              p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
              x_return_status         => l_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
              p_claim                 => l_pvt_claim_rec,
              p_event                 => g_subsequent_apply_event, --g_update_event
              p_mode                  => OZF_CLAIM_UTILITY_PVT.G_AUTO_MODE,
              x_object_version_number => l_object_version_number
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      ELSE
         --Build Notes. (34)
         --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
         --l_notes := l_notes||'Status of the claim is CLOSED, NO Subsequent Receipt application'||
         --           ' for receipt number '||l_deduction_rec.RECEIPT_NUMBER||
         --           ' will be performed on this Claim.]';

	-- bugfix 4869928
        l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_CLAIM_CLOSED');
        l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_NO_SUBS_APPLY', TO_CHAR(l_deduction_rec.RECEIPT_NUMBER) );


      END IF;

      --Call Create Notes API.
      Write_log(l_full_name,l_notes);
      JTF_NOTES_PUB.create_note(
           p_api_version        => 1.0
          ,x_return_status      => l_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
          ,p_source_object_id   => l_deduction_rec.claim_id
          ,p_source_object_code => 'AMS_CLAM'
          ,p_notes              => l_notes
          ,p_note_status        => NULL
          ,p_entered_by         =>  FND_GLOBAL.user_id
          ,p_entered_date       => SYSDATE
          ,p_last_updated_by    => FND_GLOBAL.user_id
          ,x_jtf_note_id        => l_x_note_id
          ,p_note_type          => 'AMS_JUSTIFICATION'
          ,p_last_update_date   => SYSDATE
          ,p_creation_date      => SYSDATE
      );


   -- --------------
   -- Split Scenario
   -- --------------
   ELSIF l_split_flag = 'YES' THEN

         FOR ref_split_claim_csr in split_claim_csr(l_deduction_rec.claim_id) LOOP
            IF ref_split_claim_csr.status_code = 'PENDING_CLOSE' THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_STATUS_PENDING_CLOSE');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP;

         -- ---------------------
      -- Fully Apply
      -- ---------------------
      IF l_deduction_rec.amount = 0 THEN
         -- Update Status to CANCELLED for all Claims including root claim and set amount to zero.
         -- Select all claims for the root_claim except claim with CLOSED status.
         l_new_status_code := 'CANCELLED';

         Write_Log(l_full_name, 'Full Apply - Cancelling All Claims');
         -- Process Cancellation of claims and update remaining balance to Zero
         FOR ref_split_claim_csr in split_claim_csr(l_deduction_rec.CLAIM_ID) LOOP
            l_amount_remaining := (ref_split_claim_csr.AMOUNT_REMAINING + ref_split_claim_csr.AMOUNT_SETTLED);
            -- Build Notes (35)
            --l_notes := '[Claim:'||ref_split_claim_csr.CLAIM_NUMBER||' Remark:';
            --l_notes := l_notes||'Claim Remaining Balance is changed '||
            --           'From '||l_amount_remaining||' To '||l_deduction_rec.AMOUNT||
            --           ' due to Application of amount '||l_amount_remaining||
            --           ' (Out of AR applied amount '||l_deduction_rec.amount_applied||
            --           ' Receipt Number:'||l_deduction_rec.applied_receipt_number||')'||
            --           ' and Status is Changed '||'From '||ref_split_claim_csr.STATUS_CODE||
            --           ' To CANCELLED';

           --bugfix 4869928
	   l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_APPLY_CHANGE'
					     , TO_CHAR(l_amount_remaining),
					     TO_CHAR(l_deduction_rec.AMOUNT),
					     TO_CHAR(l_amount_remaining),
					     TO_CHAR(l_deduction_rec.amount_applied),
					     TO_CHAR(l_deduction_rec.applied_receipt_number)
					     );
	   l_notes := l_notes || Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE', ref_split_claim_csr.STATUS_CODE, 'CANCELLED');


            --build claim rec.
            l_pvt_claim_rec.claim_id              := ref_split_claim_csr.claim_id;
            l_pvt_claim_rec.object_version_number := ref_split_claim_csr.object_version_number;
            l_pvt_claim_rec.status_code           := l_new_status_code;
            l_pvt_claim_rec.amount                := 0;
            l_pvt_claim_rec.amount_adjusted       := 0;
            l_pvt_claim_rec.amount_remaining      := 0;
            l_pvt_claim_rec.amount_settled        := 0;
            --l_pvt_claim_rec.amount                := l_deduction_rec.amount;
            l_pvt_claim_rec.currency_code         := l_deduction_rec.currency_code;
            l_pvt_claim_rec.exchange_rate_type    := l_deduction_rec.exchange_rate_type;
            l_pvt_claim_rec.exchange_rate_date    := l_deduction_rec.exchange_rate_date;
            l_pvt_claim_rec.exchange_rate         := l_deduction_rec.exchange_rate;

            IF l_deduction_rec.source_object_id IS NOT NULL AND
               l_deduction_rec.source_object_id <> FND_API.G_MISS_NUM THEN
               --Transaction Releated deduction
               l_pvt_claim_rec.receipt_id                   := l_deduction_rec.receipt_id;
               l_pvt_claim_rec.receipt_number               := l_deduction_rec.receipt_number;

               -- Build Notes (36)
               --l_notes := l_notes||' and Receipt Reference is Changed '||
               --           'From '||l_receipt_number||' To '||l_deduction_rec.RECEIPT_NUMBER||'.]';

	       -- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_CHANGE', TO_CHAR(l_receipt_number), TO_CHAR(l_deduction_rec.RECEIPT_NUMBER));

            ELSE
               -- Claim Investigation
               -- Build Notes(37)
               --l_notes := l_notes||' and Receipt Reference '||l_receipt_number||' is not Changed.]';

		-- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_SAME', TO_CHAR(l_receipt_number) );

            END IF;

            --Assign Applied Details
            l_pvt_claim_rec.history_event_date     := l_deduction_rec.applied_date;
            l_pvt_claim_rec.amount_applied         := l_amount_remaining;
            l_pvt_claim_rec.applied_receipt_id     := NVL(l_deduction_rec.applied_receipt_id,l_deduction_rec.receipt_id);
            l_pvt_claim_rec.applied_receipt_number := NVL(l_deduction_rec.applied_receipt_number,l_deduction_rec.receipt_number);

            -- [Begin of Debug Message]
            Write_Log(l_full_name, 'applicable claim.claim_id                = '||l_pvt_claim_rec.claim_id);
            Write_Log(l_full_name, 'applicable claim.amount                = '||l_pvt_claim_rec.amount);
            Write_Log(l_full_name, 'applicable claim.amount_adjusted       = '||l_pvt_claim_rec.amount_adjusted);
            Write_Log(l_full_name, 'applicable claim.amount_remaining      = '||l_pvt_claim_rec.amount_remaining);
            Write_Log(l_full_name, 'applicable claim.amount_settled        = '||l_pvt_claim_rec.amount_settled);
            Write_Log(l_full_name, 'applicable claim.amount_applied        = '||l_pvt_claim_rec.amount_applied);
            Write_Log(l_full_name, 'applicable claim.status_code           = '||l_pvt_claim_rec.status_code);
            Write_Log(l_full_name, 'applicable claim.receipt_id            = '||l_pvt_claim_rec.receipt_id);
            Write_Log(l_full_name, 'applicable claim.receipt_number        = '||l_pvt_claim_rec.receipt_number);
            Write_Log(l_full_name, 'applicable claim.applied_receipt_id    = '||l_pvt_claim_rec.applied_receipt_id);
            Write_Log(l_full_name, 'applicable claim.applied_receipt_number= '||l_pvt_claim_rec.applied_receipt_number);
            -- [End of Debug Message]

            --Call Update_Claim to reflect the changes.
            OZF_claim_PVT.Update_claim(
                 p_api_version            => 1.0,
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_commit                 => FND_API.G_FALSE,
                 p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status          => l_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data,
                 p_claim                  => l_pvt_claim_Rec,
                 p_event                  => G_SUBSEQUENT_APPLY_EVENT,  --G_UPDATE_EVENT
                 p_mode                   => OZF_CLAIM_UTILITY_PVT.G_AUTO_MODE,
                 x_object_version_number  => l_object_version_number
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR then
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


            --Call Create Notes API.
            Write_log(l_full_name,l_notes);
            JTF_NOTES_PUB.create_note(
                 p_api_version        => 1.0
                ,x_return_status      => l_return_status
                ,x_msg_count          => x_msg_count
                ,x_msg_data           => x_msg_data
                ,p_source_object_id   => l_deduction_rec.claim_id
                ,p_source_object_code => 'AMS_CLAM'
                ,p_notes              => l_notes
                ,p_note_status        => NULL
                ,p_entered_by         =>  FND_GLOBAL.user_id
                ,p_entered_date       => SYSDATE
                ,p_last_updated_by    => FND_GLOBAL.user_id
                ,x_jtf_note_id        => l_x_note_id
                ,p_note_type          => 'AMS_JUSTIFICATION'
                ,p_last_update_date   => SYSDATE
                ,p_creation_date      => SYSDATE
            );

            l_notes := null;

         END LOOP;

      ELSIF l_deduction_rec.AMOUNT <> 0 THEN

         Write_Log(l_full_name, 'Partial Apply - Adjusting Amounts');
         Check_Update_Allowed(
                p_deduction_rec         => l_deduction_rec
               ,x_applicable_claims_tbl => l_Applicable_Claims_Tbl
               ,x_notes_tbl             => l_notes_tbl
               ,x_update_allowed_flag   => l_update_allowed_flag
               ,x_return_status         => l_return_status
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         write_log(l_full_name, l_applicable_claims_tbl.count);
            FOR i in 1..l_applicable_claims_tbl.count LOOP
               write_log(l_full_name, 'i'||i);
               --build claim rec.
               l_pvt_claim_rec.claim_id               := l_applicable_claims_tbl(i).claim_id;
               l_pvt_claim_rec.object_version_number  := l_applicable_claims_tbl(i).object_version_number;
               l_pvt_claim_rec.status_code            := l_applicable_claims_tbl(i).status_code;
               l_pvt_claim_rec.amount                 := l_applicable_claims_tbl(i).amount;
               l_pvt_claim_rec.amount_adjusted        := l_applicable_claims_tbl(i).amount_adjusted;
               l_pvt_claim_rec.amount_remaining       := l_applicable_claims_tbl(i).amount_remaining;
               l_pvt_claim_rec.amount_settled         := l_applicable_claims_tbl(i).amount_settled;
               l_pvt_claim_rec.amount_applied         := l_applicable_claims_tbl(i).amount_applied;
               l_pvt_claim_rec.currency_code          := l_applicable_claims_tbl(i).currency_code;
               l_pvt_claim_rec.exchange_rate_type     := l_applicable_claims_tbl(i).exchange_rate_type;
               l_pvt_claim_rec.exchange_rate_date     := l_applicable_claims_tbl(i).exchange_rate_date;
               l_pvt_claim_rec.exchange_rate          := l_applicable_claims_tbl(i).exchange_rate;
               l_pvt_claim_rec.receipt_id             := l_applicable_claims_tbl(i).receipt_id;
               l_pvt_claim_rec.receipt_number         := l_applicable_claims_tbl(i).receipt_number;
               l_pvt_claim_rec.history_event_date     := l_deduction_rec.applied_date;
               l_pvt_claim_rec.applied_receipt_id     := l_deduction_rec.applied_receipt_id;
               l_pvt_claim_rec.applied_receipt_number := l_deduction_rec.applied_receipt_number;


               -- [Begin of Debug Message]
               Write_Log(l_full_name, 'claims('||i||').CLAIM_ID         ='||l_pvt_claim_Rec.CLAIM_ID);
               Write_Log(l_full_name, 'claims('||i||').STATUS_CODE      ='||l_pvt_claim_Rec.STATUS_CODE);
               Write_Log(l_full_name, 'claims('||i||').AMOUNT           ='||l_pvt_claim_Rec.AMOUNT);
               Write_Log(l_full_name, 'claims('||i||').AMOUNT_ADJUSTED  ='||l_pvt_claim_Rec.AMOUNT_ADJUSTED);
               Write_Log(l_full_name, 'claims('||i||').AMOUNT_REMAINING ='||l_pvt_claim_Rec.AMOUNT_REMAINING);
               Write_Log(l_full_name, 'claims('||i||').AMOUNT_SETTLED   ='||l_pvt_claim_Rec.AMOUNT_SETTLED);
               Write_Log(l_full_name, 'claims('||i||').AMOUNT_APPLIED   ='||l_pvt_claim_Rec.AMOUNT_APPLIED);
               Write_Log(l_full_name, 'claims('||i||').RECEIPT_ID       ='||l_pvt_claim_Rec.RECEIPT_ID);
               Write_Log(l_full_name, 'claims('||i||').RECEIPT_NUMBER   ='||l_pvt_claim_Rec.RECEIPT_NUMBER);
               -- [End of Debug Message]

               --Call Update_Claim to reflect the changes.
               OZF_claim_PVT.Update_claim(
                    p_api_version            => 1.0,
                    p_init_msg_list          => FND_API.G_FALSE,
                    p_commit                 => FND_API.G_FALSE,
                    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status          => l_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data,
                    p_claim                  => l_pvt_claim_Rec,
                    p_event                  => G_SUBSEQUENT_APPLY_EVENT,  --G_UPDATE_EVENT
                    p_mode                   => OZF_CLAIM_UTILITY_PVT.G_AUTO_MODE,
                    x_object_version_number  => l_object_version_number
               );
               IF l_return_status = FND_API.G_RET_STS_ERROR then
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               IF i <= l_notes_tbl.COUNT THEN
                  --Call Create Notes API.
                  JTF_NOTES_PUB.create_note(
                       p_api_version        => 1.0
                      ,x_return_status      => l_return_status
                      ,x_msg_count          => x_msg_count
                      ,x_msg_data           => x_msg_data
                      ,p_source_object_id   => l_pvt_claim_rec.claim_id
                      ,p_source_object_code => 'AMS_CLAM'
                      ,p_notes              => l_notes_tbl(i).claim_notes
                      ,p_note_status        => NULL
                      ,p_entered_by         =>  FND_GLOBAL.user_id
                      ,p_entered_date       => SYSDATE
                      ,p_last_updated_by    => FND_GLOBAL.user_id
                      ,x_jtf_note_id        => l_x_note_id
                      ,p_note_type          => 'AMS_JUSTIFICATION'
                      ,p_last_update_date   => SYSDATE
                      ,p_creation_date      => SYSDATE
                  );
               END IF;
            END LOOP;
         END IF; --IF l_deduction_rec.AMOUNT <> 0 THEN

      -- Now sync adjustment amounts
      update_parent_amounts(
             x_return_status      => l_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            ,p_deduction_rec      => l_deduction_rec);
     IF l_return_status = FND_API.G_RET_STS_ERROR then
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   END IF;  --IF l_split_flag = 'YES' THEN


  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  Write_Log(l_full_name, 'end');


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
      );

End Perform_Subsequent_Apply;


----------------------------------------------------------------------------------------------
--   PROCEDURE:  Perform_Subsequent_Unpply
--
--   PURPOSE  :
--   This procedure perform Subsequent Un-Application.
--   It calls the Update_claim proceudre in the private package.
--
--   PARAMETERS:
--   IN:
--     p_api_version_number    IN   NUMBER     Required
--     p_init_msg_list         IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--     p_validation_level      IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_commit                IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     P_deduction             IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--     x_return_status         OUT  VARCHAR2
--     x_msg_count             OUT  NUMBER
--     x_msg_data              OUT  VARCHAR2
--     x_object_version_number OUT  NUMBER
--
--   Note:
--
----------------------------------------------------------------------------------------------
PROCEDURE Perform_Subsequent_Unapply(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Perform_Subsequent_Unpply';
l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);

l_object_version_number   NUMBER;
l_deduction_rec           DEDUCTION_REC_TYPE := p_deduction;
l_pvt_claim_rec           OZF_CLAIM_PVT.claim_Rec_Type;
l_Applicable_Claims_Tbl   DEDUCTION_REC_TYPE;
l_child_claim_tbl         OZF_SPLIT_CLAIM_PVT.Child_Claim_tbl_type;
l_claim_obj_ver_num       NUMBER;
l_claim_count             NUMBER := 0;
l_split_flag              VARCHAR2(3);
l_notes                   VARCHAR2(2000);
l_status_code             VARCHAR2(30);
l_new_status_code         VARCHAR2(30);
l_update_allowed_flag     VARCHAR2(1);
l_count_claim_on_receipt  NUMBER:=0;
l_new_amount              NUMBER:=0;
l_new_amount_adjusted     NUMBER:=0;
l_claim_class             VARCHAR2(30);
l_deduction_type          VARCHAR2(30);
l_reason_code_id          NUMBER;
l_receipt_number          VARCHAR2(30);
l_claim_amount            NUMBER := 0;
l_split_claim_id          NUMBER;
l_split_claim_number      VARCHAR2(30);
l_x_note_id               NUMBER;
l_amount_remaining        NUMBER:=0;
l_claim_type_id           NUMBER:=FND_API.g_miss_num;
l_source_object_id        NUMBER;
l_invoice_amount_due      NUMBER:=0;    --Added on 21-Apr-2003 (aadhawad)

-- get Count for given claim_id
CURSOR get_claim_count_csr (p_claim_id in number) IS
SELECT count(*)
FROM   ozf_claims_all
WHERE  root_claim_id = p_claim_id;

-- get existing claim details.
CURSOR get_claim_detail_csr (p_claim_id in number) IS
SELECT status_code,amount,receipt_number,claim_class,
       amount_remaining+amount_settled amount_remaining,
       source_object_id
FROM   ozf_claims_all
WHERE  claim_id = p_claim_id;

-- Added for Bug4872736
CURSOR get_split_claim_detail_csr (p_claim_id in number) IS
SELECT claim_class,
       sum(amount_remaining+amount_settled) amount_remaining,
       source_object_id
FROM   ozf_claims_all
WHERE  root_claim_id = p_claim_id
GROUP  BY claim_class, source_object_id;

-- get split claim details.
CURSOR split_claim_csr(p_claim_id in number) IS
SELECT root_claim_id,
       claim_id,
       object_version_number,
       claim_number,
       receipt_number,
       status_code,
       amount,
       amount_adjusted,
       amount_remaining,
       amount_settled
FROM   ozf_claims_all
WHERE  root_claim_id = p_claim_id
ORDER  BY claim_id;

-- get Claim_Class for claim_id
CURSOR get_claim_class_csr(p_claim_id IN NUMBER) IS
SELECT claim_class,reason_code_id,object_version_number,claim_type_id
FROM   ozf_claims_all
WHERE  claim_id = p_claim_id;

-- get Newly created split claim_id and claim_number
CURSOR   get_split_claim_ids_csr(p_claim_id IN NUMBER) IS
SELECT claim_id,claim_number
FROM   ozf_claims_all
WHERE  root_claim_id = p_claim_id
AND    claim_id      = (Select max(claim_id)
                       from ozf_claims_all
                       where root_claim_id = p_claim_id)
AND    trunc(creation_date) = trunc(sysdate);

-- get Amount Due on Invoice
CURSOR get_invoice_amount_due_csr (p_claim_id in NUMBER) IS
SELECT amount_due_original
FROM   ar_payment_schedules a, ozf_claims_all b
WHERE  customer_trx_id = b.source_object_id
AND    b.claim_id      = p_claim_id;

-- [BEGIN OF BUG 3775972 FIXING]
l_cancel_all_claim         VARCHAR2(1)   := 'N';
-- [END OF BUG 3775972 FIXING]

-- Added for Bug5102282
-- Get the payment_schedule_id
CURSOR csr_applied_ps_id( cv_customer_trx_id IN NUMBER, cv_receipt_id IN NUMBER, cv_claim_id IN NUMBER) IS
SELECT distinct applied_payment_schedule_id
 FROM  ar_receivable_applications_all
WHERE  cash_receipt_id = cv_receipt_id
  AND  applied_customer_trx_id = cv_customer_trx_id
  AND  application_ref_type = 'CLAIM'
  AND  secondary_application_ref_id = cv_claim_id
  AND  status = 'APP';
l_applied_ps_id NUMBER;

-- Added for Bug5102282
-- Get the count of applications
CURSOR csr_cnt_apply(cv_ps_id IN NUMBER, cv_receipt_id IN NUMBER, cv_claim_id IN NUMBER) IS
SELECT COUNT(*)
  FROM ar_receivable_applications_all
 WHERE applied_payment_schedule_id = cv_ps_id
  AND  cash_receipt_id <> cv_receipt_id
  AND  application_ref_type = 'CLAIM'
  AND  secondary_application_ref_id = cv_claim_id
  AND  status = 'APP'
  AND  display = 'Y';
l_cnt_apply_recs NUMBER := 0;
l_new_deduction_amount Number := 0;

BEGIN
   --------------------- initialize -----------------------
   Write_Log(l_full_name, 'start');

   x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Check if the claim has any splits.
  OPEN get_claim_count_csr(l_deduction_rec.claim_id);
  FETCH get_claim_count_csr INTO l_claim_count;
  CLOSE get_claim_count_csr;

  -- Get Details for root claimc
  OPEN  get_claim_detail_csr(l_deduction_rec.claim_id);
  FETCH get_claim_detail_csr INTO l_status_code,l_claim_amount,l_receipt_number,
                                  l_claim_class,l_amount_remaining,l_source_object_id;
  CLOSE get_claim_detail_csr;

  IF l_claim_count = 1 THEN
    l_split_flag := 'NO';
  ELSIF l_claim_count > 1 THEN
    l_split_flag := 'YES';
  ELSE
    l_split_flag := NULL;
  END IF;

  Write_Log(l_full_name, 'l_deduction_rec.amount = '||l_deduction_rec.amount);
  Write_Log(l_full_name, 'l_deduction_rec.amount_applied = '||l_deduction_rec.amount_applied);

  Write_Log(l_full_name, 'Split ? '||l_split_flag);

  -- Handling for Invoice Deductions
  IF p_deduction.source_object_id IS NOT NULL THEN

     -- Obtain the payment schedule id
     OPEN  csr_applied_ps_id(p_deduction.source_object_id, p_deduction.receipt_id, p_deduction.claim_id);
     FETCH csr_applied_ps_id INTO l_applied_ps_id;
     CLOSE csr_applied_ps_id;

     -- Check if there are any other applications
     OPEN  csr_cnt_apply(l_applied_ps_id, p_deduction.receipt_id, p_deduction.claim_id);
     FETCH csr_cnt_apply INTO l_cnt_apply_recs;
     CLOSE csr_cnt_apply;

  END IF;

  -- -----------------
  -- No Split Scenario
  -- -----------------
  IF l_split_flag = 'NO' THEN
    --Deal with amount sign
    IF l_claim_class = 'OVERPAYMENT' THEN
      IF l_deduction_rec.AMOUNT > 0 THEN
        l_deduction_rec.AMOUNT         := l_deduction_rec.AMOUNT * -1;
        l_deduction_rec.AMOUNT_APPLIED := l_deduction_rec.AMOUNT_APPLIED * -1;
      END IF;
    END IF;

    --Fixed:Date:12-Mar-2003. Partial application for claim investigation.
    IF ( l_claim_class = 'DEDUCTION' and
       (l_source_object_id is NULL or l_source_object_id = FND_API.g_miss_num)) THEN
      IF l_deduction_rec.AMOUNT < 0 THEN
        l_deduction_rec.AMOUNT         := l_deduction_rec.AMOUNT * -1;
        --l_deduction_rec.AMOUNT_APPLIED := l_deduction_rec.AMOUNT_APPLIED * -1;
      END IF;
    END IF;

      IF l_status_code = 'PENDING_CLOSE' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_STATUS_PENDING_CLOSE');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- BUG 4157743 FIXING
    IF l_status_code <> 'CLOSED' THEN

      -- Bug4300996/Bug4777500/Bug5102282:Cancel claim
      -- For invoice deductions, cancel if there are not other applications
      -- For non invoice deductions and overpayments, cancel if amount = 0
      IF l_deduction_rec.AMOUNT = 0 OR  l_cnt_apply_recs = 0 THEN

      Write_Log(l_full_name, 'Cancel ? Yes' );

        l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
        l_notes := l_notes||'For this Claim all receipts are fully Unapplied from AR '||
                             ' and Status is changed From '||l_status_code||' To CANCELLED';

        l_new_status_code := 'CANCELLED';
        l_notes := l_notes||' and Receipt Reference '||l_receipt_number||' is not Changed.]';

      ELSE
      -- Build Notes(39)
       -- l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
       -- l_notes := l_notes||' This Claim Balance is changed '||
       --                       'From '||l_amount_remaining||
       --                       ' To '||l_deduction_rec.AMOUNT||
       --                       ' due to Unapplication of amount '||l_deduction_rec.AMOUNT_APPLIED||
       --                       ' (Receipt Number:'||l_deduction_rec.applied_receipt_number||')';

	-- bugfix 4869928
        l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_UNAPPLY_CHANGE', TO_CHAR(l_amount_remaining), TO_CHAR(l_deduction_rec.AMOUNT),TO_CHAR(l_deduction_rec.AMOUNT_APPLIED),TO_CHAR(l_deduction_rec.applied_receipt_number) );

        IF l_status_code = 'OPEN' THEN
	  -- Build Notes(40)
          --  l_notes := l_notes||' and Status is '||l_status_code||', remains the Same';

	-- bugfix 4869928
        l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_SAME', l_status_code);
        l_new_status_code := l_status_code;


        ELSE
	  -- Build Notes(41)
            --l_notes := l_notes|| ' and Status is changed From '||l_status_code||' To OPEN';

	-- bugfix 4869928
        l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE', l_status_code, 'OPEN');


            l_new_status_code := 'OPEN';
        END IF;

        --Check for Transaction Related Claim.
        IF l_deduction_rec.SOURCE_OBJECT_ID is NOT NULL AND
           l_deduction_rec.SOURCE_OBJECT_ID <> FND_API.G_MISS_NUM THEN
          --Transaction Related Claim.
          l_pvt_claim_Rec.RECEIPT_ID          := l_deduction_rec.RECEIPT_ID;
          l_pvt_claim_Rec.RECEIPT_NUMBER      := nvl(l_deduction_rec.RECEIPT_NUMBER,l_receipt_number);

          --Build Event Description. Receipt is not changed because incoming recept number is NULL.
	    -- Build Notes(42)
          --l_notes := l_notes||' and Receipt Reference is Changed '||
          --                    'From '||l_receipt_number||
          --                    ' To '||l_deduction_rec.RECEIPT_NUMBER||'.]';

	       -- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_CHANGE', TO_CHAR(l_receipt_number), TO_CHAR(l_deduction_rec.RECEIPT_NUMBER));

        ELSE
          --Build Event Description
	    -- Build Notes(43)
          --l_notes := l_notes||' and Receipt Reference '||l_receipt_number||' is not Changed.]';

		-- bugfix 4869928
               l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_SAME', TO_CHAR(l_receipt_number) );

        END IF;
        l_pvt_claim_Rec.AMOUNT                 := l_deduction_rec.AMOUNT;

      END IF;

      --Build Claim_Rec.
      l_pvt_claim_Rec.CLAIM_ID               := l_deduction_rec.CLAIM_ID;
      l_pvt_claim_Rec.OBJECT_VERSION_NUMBER  := l_deduction_rec.OBJECT_VERSION_NUMBER;
      l_pvt_claim_Rec.CURRENCY_CODE          := l_deduction_rec.CURRENCY_CODE;
      l_pvt_claim_Rec.EXCHANGE_RATE_TYPE     := l_deduction_rec.EXCHANGE_RATE_TYPE;
      l_pvt_claim_Rec.EXCHANGE_RATE_DATE     := l_deduction_rec.EXCHANGE_RATE_DATE;
      l_pvt_claim_Rec.EXCHANGE_RATE          := l_deduction_rec.EXCHANGE_RATE;
      l_pvt_claim_Rec.STATUS_CODE            := l_new_status_code;

      --In case of Unapply need to update these fileds which will appear on History.
      l_pvt_claim_Rec.HISTORY_EVENT_DATE     := l_deduction_rec.APPLIED_DATE;
      l_pvt_claim_Rec.AMOUNT_APPLIED         := l_deduction_rec.AMOUNT_APPLIED;          --Unapplied Amount
      l_pvt_claim_Rec.APPLIED_RECEIPT_ID     := l_deduction_rec.APPLIED_RECEIPT_ID;
      l_pvt_claim_Rec.APPLIED_RECEIPT_NUMBER := l_deduction_rec.APPLIED_RECEIPT_NUMBER;

      --Call Update_Claim to reflect the changes.
      OZF_claim_PVT.Update_claim(
        P_Api_Version           => 1.0,
        P_Init_Msg_List         => FND_API.G_FALSE,
        P_Commit                => FND_API.G_FALSE,
        P_Validation_Level      => FND_API.G_VALID_LEVEL_FULL,
        X_Return_Status         => x_return_status,
        X_Msg_Count             => x_msg_count,
        X_Msg_Data              => x_msg_data,
        P_claim                 => l_pvt_claim_Rec,
        p_event                 => G_SUBSEQUENT_UNAPPLY_EVENT, --G_UPDATE_EVENT
        p_mode                  => OZF_claim_Utility_pvt.G_AUTO_MODE,
        X_Object_Version_Number => l_object_version_number );

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      --Build Notes.(44)
      --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
      --l_notes := l_notes||'The Status of the claim is CLOSED, NO Subsequent Receipt Unapplication'||
      --                    ' for receipt number '||l_deduction_rec.APPLIED_RECEIPT_NUMBER||
      --                    ' will be performed on this Claim.]';

      -- bugfix 4869928
      l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_CLAIM_CLOSED');
      l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_NO_SUBS_APPLY', TO_CHAR(l_deduction_rec.RECEIPT_NUMBER) );

    END IF;

    --Call Create Notes API.
    Write_log(l_full_name,l_notes);
    JTF_NOTES_PUB.create_note(
        p_api_version=> 1.0
       ,x_return_status=> x_return_status
       ,x_msg_count=> x_msg_count
       ,x_msg_data=> x_msg_data
       ,p_source_object_id=> l_deduction_rec.CLAIM_ID -- claim_id
       ,p_source_object_code=> 'AMS_CLAM'
       ,p_notes=> l_notes
       ,p_note_status=> NULL
       ,p_entered_by=> FND_GLOBAL.user_id
       ,p_entered_date=> SYSDATE
       ,p_last_updated_by=> FND_GLOBAL.user_id
       ,x_jtf_note_id=> l_x_note_id
       ,p_note_type=> 'AMS_JUSTIFICATION'  --'AMS_DEDU' Deduction Notes; use'AMS_JUSTIFICATION' for Justification
       ,p_last_update_date=> SYSDATE
       ,p_creation_date=> SYSDATE
       );

    --Initialize l_notes
    l_notes := null;
  END IF;  --IF l_split_flag = 'NO' THEN

  -- --------------
  -- Split Scenario
  -- --------------
  IF l_split_flag = 'YES' THEN

    IF l_claim_class = 'OVERPAYMENT' THEN
      IF l_deduction_rec.AMOUNT > 0 THEN
        l_deduction_rec.AMOUNT         := l_deduction_rec.AMOUNT * -1;
        l_deduction_rec.AMOUNT_APPLIED := l_deduction_rec.AMOUNT_APPLIED * -1;
      END IF;
    END IF;

    -- Bug4300996/Bug4777500/Bug5102282:Cancel claim
    -- For invoice deductions, cancel if there are not other applications
    -- For non invoice deductions and overpayments, cancel if amount = 0
    IF l_cnt_apply_recs = 0 OR l_deduction_rec.amount = 0 THEN
       l_cancel_all_claim := 'Y';
    END IF;

    Write_Log(l_full_name, 'Cancel All ? ' || l_cancel_all_claim );

    --Fixed:Date:12-Mar-2003. Partial application for claim investigation.
    IF ( l_claim_class = 'DEDUCTION' and
       (l_source_object_id is NULL or l_source_object_id = FND_API.g_miss_num)) THEN
      IF l_deduction_rec.AMOUNT < 0 THEN
        l_deduction_rec.AMOUNT         := l_deduction_rec.AMOUNT * -1;
        --l_deduction_rec.AMOUNT_APPLIED := l_deduction_rec.AMOUNT_APPLIED * -1;
      END IF;
    END IF;


    IF l_deduction_rec.receipt_id is NOT NULL then
      l_update_allowed_flag := 'Y';
      FOR ref_split_claim_csr in split_claim_csr(l_deduction_rec.CLAIM_ID) LOOP
        IF ref_split_claim_csr.STATUS_CODE = 'PENDING_CLOSE' THEN
          l_update_allowed_flag := 'N';
        END IF;
      END LOOP;
    ELSE
      l_update_allowed_flag := 'Y';
    END IF;

    Write_Log(l_full_name, 'Update Allowed ? ' || l_update_allowed_flag );

    IF l_update_allowed_flag = 'N' THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_STATUS_PENDING_CLOSE');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR ref_split_claim_csr in split_claim_csr(l_deduction_rec.CLAIM_ID) LOOP
        -- If cancel all claim flag is Y, then cancel all non closed claims
         IF l_cancel_all_claim = 'Y' THEN
            --//Bugfix : 7526516
           IF  ref_split_claim_csr.status_code NOT IN ('CLOSED', 'CANCELLED','PENDING_APPROVAL') THEN
               --Build Notes (46)
               --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';
               --l_notes := l_notes||' The Status of the Claim is changed From Open to Cancelled';

		-- bugfix 4869928
		l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE','OPEN', 'CANCELLED');

	       -- Build Notes (47)
               --l_notes := l_notes||' due to Unapplication of Amount '||l_deduction_rec.AMOUNT_APPLIED||
               --                  ' (Receipt Number:'||l_deduction_rec.applied_receipt_number||')';
		-- bugfix 4869928
		l_notes := l_notes|| Build_Note('OZF_CLAIM_NOTES_AMOUNT_UNAPPLY', TO_CHAR(l_deduction_rec.AMOUNT_APPLIED), TO_CHAR(l_deduction_rec.applied_receipt_number) );

               --Build Claim Rec.
               l_pvt_claim_rec.claim_id               := ref_split_claim_csr.claim_id;
               l_pvt_claim_rec.object_version_number  := ref_split_claim_csr.object_version_number;
               l_pvt_claim_rec.status_code            := 'CANCELLED';
               l_pvt_claim_rec.history_event_date     := l_deduction_rec.applied_date;
               l_pvt_claim_rec.amount_applied         := l_deduction_rec.amount_applied;          --unapplied amount
               l_pvt_claim_rec.applied_receipt_id     := l_deduction_rec.applied_receipt_id;
               l_pvt_claim_rec.applied_receipt_number := l_deduction_rec.applied_receipt_number;

               --Call Update_Claim to reflect the changes.
               OZF_claim_PVT.Update_claim(
                   p_api_version           => 1.0,
                   p_init_msg_list         => FND_API.G_FALSE,
                   p_commit                => FND_API.G_FALSE,
                   p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_claim                 => l_pvt_claim_Rec,
                   p_event                 => G_SUBSEQUENT_UNAPPLY_EVENT, --G_UPDATE_EVENT
                   p_mode                  => OZF_claim_Utility_pvt.G_AUTO_MODE,
                   x_object_version_number => l_object_version_number
               );
               -- Check return status from the above procedure call
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               --Call Create Notes API.
               Write_log(l_full_name,l_notes);
               JTF_NOTES_PUB.create_note(
                    p_api_version           => 1.0
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data
                   ,p_source_object_id      => ref_split_claim_csr.claim_id   --claim_id
                   ,p_source_object_code    => 'AMS_CLAM'
                   ,p_notes                 => l_notes
                   ,p_note_status           => NULL
                   ,p_entered_by            => FND_GLOBAL.user_id
                   ,p_entered_date          => SYSDATE
                   ,p_last_updated_by       => FND_GLOBAL.user_id
                   ,x_jtf_note_id           => l_x_note_id
                   ,p_note_type             => 'AMS_JUSTIFICATION'  --'AMS_DEDU' Deduction Notes; use'AMS_JUSTIFICATION' for Justification
                   ,p_last_update_date      => SYSDATE
                   ,p_creation_date         => SYSDATE
               );
            END IF;
        ELSE -- l_cancel_all_claim = 'N'

           -- Update the first open/complete/pending approval claim.

         l_new_deduction_amount := ref_split_claim_csr.AMOUNT + l_deduction_rec.AMOUNT_APPLIED;
          --//Bugfix : 7526516
          IF  ref_split_claim_csr.status_code NOT IN ('CLOSED', 'CANCELLED','PENDING_APPROVAL') THEN
             --Build Notes
             --l_notes := '[Claim:'||l_deduction_rec.CLAIM_NUMBER||' Remark:';

             IF ref_split_claim_csr.STATUS_CODE <> 'OPEN' THEN
               l_new_status_code := 'OPEN';
               --Build Notes(52)
               --l_notes := l_notes||'The Status of the Claim is changed From '||ref_split_claim_csr.STATUS_CODE||
               --                  ' To '||l_new_status_code;

	   --bugfix 4869928
	    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_CHANGE',ref_split_claim_csr.STATUS_CODE,l_status_code);

             ELSE
               l_new_status_code := ref_split_claim_csr.STATUS_CODE;
               --Build Notes (53)
               --l_notes := l_notes||'The Status of the Claim ('||l_new_status_code||
               --                    ') is NOT changed ';

	   --bugfix 4869928
	    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_STATUS_SAME',l_new_status_code);

             END IF;


             --Build Notes (54)
             --l_notes := l_notes||' and Amount is changed '||
             --                    'From '||ref_split_claim_csr.AMOUNT||' To '||l_deduction_rec.AMOUNT||
             --                    ' due to Unapplication of Amount '||l_deduction_rec.AMOUNT_APPLIED||
             --                    ' (Receipt Number:'||l_deduction_rec.applied_receipt_number||')';

	   --bugfix 4869928
	    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_UNAPPLY_CHANGE'
					    , TO_CHAR(ref_split_claim_csr.AMOUNT)
					    , TO_CHAR(l_deduction_rec.AMOUNT)
					    , TO_CHAR(l_deduction_rec.AMOUNT_APPLIED)
					    , TO_CHAR(l_deduction_rec.applied_receipt_number)
					    );

             --Build Claim Rec.
             l_pvt_claim_Rec.CLAIM_ID               := ref_split_claim_csr.CLAIM_ID;
             l_pvt_claim_Rec.OBJECT_VERSION_NUMBER  := ref_split_claim_csr.OBJECT_VERSION_NUMBER;
             l_pvt_claim_Rec.STATUS_CODE            := l_new_status_code;
             l_pvt_claim_Rec.AMOUNT                 := l_new_deduction_amount;
             l_pvt_claim_Rec.CURRENCY_CODE          := l_deduction_rec.CURRENCY_CODE;
             l_pvt_claim_Rec.EXCHANGE_RATE_TYPE     := l_deduction_rec.EXCHANGE_RATE_TYPE;
             l_pvt_claim_Rec.EXCHANGE_RATE_DATE     := l_deduction_rec.EXCHANGE_RATE_DATE;
             l_pvt_claim_Rec.EXCHANGE_RATE          := l_deduction_rec.EXCHANGE_RATE;


             IF l_deduction_rec.source_object_id IS NOT NULL AND
                    l_deduction_rec.source_object_id <> FND_API.G_MISS_NUM THEN
                -- Build Notes  :for transaction releated deduction

                IF l_deduction_rec.receipt_number <> ref_split_claim_csr.receipt_number THEN
                    l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_CHANGE', TO_CHAR(ref_split_claim_csr.RECEIPT_NUMBER), TO_CHAR(l_deduction_rec.RECEIPT_NUMBER));
                ELSE
                    l_notes := l_notes||' Receipt Reference '||ref_split_claim_csr.RECEIPT_NUMBER||' is not Changed.';
                END IF;
                l_pvt_claim_Rec.receipt_id     := l_deduction_rec.receipt_id;
                l_pvt_claim_Rec.receipt_number := l_deduction_rec.receipt_number;
             ELSE
                 -- Build Notes  :for claim investigation
                l_notes := l_notes|| Build_Note('OZF_CLAM_NOTES_RCPT_SAME', TO_CHAR(l_receipt_number) );
             END IF;

             --Assign Applied Details to l_pvt_claim_rec
             l_pvt_claim_Rec.HISTORY_EVENT_DATE     := l_deduction_rec.APPLIED_DATE;
             l_pvt_claim_Rec.AMOUNT_APPLIED         := l_deduction_rec.AMOUNT_APPLIED;          --Unapplied Amount
             l_pvt_claim_Rec.APPLIED_RECEIPT_ID     := l_deduction_rec.APPLIED_RECEIPT_ID;
             l_pvt_claim_Rec.APPLIED_RECEIPT_NUMBER := l_deduction_rec.APPLIED_RECEIPT_NUMBER;

             --Call Update_Claim to reflect the changes.
             OZF_claim_PVT.Update_claim(
                P_Api_Version           => 1.0,
                P_Init_Msg_List         => FND_API.G_FALSE,
                P_Commit                => FND_API.G_FALSE,
                P_Validation_Level      => FND_API.G_VALID_LEVEL_FULL,
                X_Return_Status         => x_return_status,
                X_Msg_Count             => x_msg_count,
                X_Msg_Data              => x_msg_data,
                P_claim                 => l_pvt_claim_Rec,
                p_event                 => G_SUBSEQUENT_UNAPPLY_EVENT, --G_UPDATE_EVENT
                p_mode                  => OZF_claim_Utility_pvt.G_AUTO_MODE,
                X_Object_Version_Number => l_object_version_number );

             -- Check return status from the above procedure call
             IF x_return_status = FND_API.G_RET_STS_ERROR then
               raise FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             --Call Create Notes API.
             Write_log(l_full_name,l_notes);
             JTF_NOTES_PUB.create_note(
                 p_api_version=> 1.0
                ,x_return_status=> x_return_status
                ,x_msg_count=> x_msg_count
                ,x_msg_data=> x_msg_data
                ,p_source_object_id=> l_deduction_rec.CLAIM_ID   --claim_id
                ,p_source_object_code=> 'AMS_CLAM'
                ,p_notes=> l_notes
                ,p_note_status=> NULL
                ,p_entered_by=> FND_GLOBAL.user_id
                ,p_entered_date=> SYSDATE
                ,p_last_updated_by=> FND_GLOBAL.user_id
                ,x_jtf_note_id=> l_x_note_id
                ,p_note_type=> 'AMS_JUSTIFICATION'  --'AMS_DEDU' Deduction Notes; use'AMS_JUSTIFICATION' for Justification
                ,p_last_update_date=> SYSDATE
                ,p_creation_date=> SYSDATE
                );

             -- Now sync adjustment amounts
              update_parent_amounts(
                    x_return_status      => l_return_status
                   ,x_msg_count          => x_msg_count
                   ,x_msg_data           => x_msg_data
                   ,p_deduction_rec      => l_deduction_rec);
              IF l_return_status = FND_API.G_RET_STS_ERROR then
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              EXIT; -- Work is done !
           END IF; -- Is claim open/complete/pending_approval?
       END IF; -- if l_cancel_claim = 'Y' */
    END LOOP;
  END IF;  --IF l_split_flag = 'YES' THEN

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
     );

  Write_Log(l_full_name, 'end');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
                              );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
       FND_MSG_PUB.add;
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data
                              );

End Perform_Subsequent_Unapply;


---------------------------------------------------------------------
--   PROCEDURE: Update_Deduction
--
--   PURPOSE: This procedure update a Deduction. It calls the Update_claim function
--            in the private package.
--
--   PARAMETERS:
--   IN
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       P_deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_object_version_number   OUT  NUMBER
--
--   NOTE:
--
---------------------------------------------------------------------
PROCEDURE Update_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_commit                     IN   VARCHAR2,

    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE,
    x_object_version_number      OUT  NOCOPY  NUMBER
)
IS
x_claim_reason_code_id     NUMBER;
x_claim_reason_name        VARCHAR2(80);
x_claim_id                 NUMBER;
x_claim_number             VARCHAR2(30);

BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OZF_Claim_GRP.Update_Deduction(
             p_api_version_number,
             p_init_msg_list,
             p_validation_level,
             p_commit,
             x_return_status,
             x_msg_count,
             x_msg_data,
             p_deduction,
             x_object_version_number,
             x_claim_reason_code_id,
             x_claim_reason_name,
             x_claim_id,
             x_claim_number
   );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
End Update_Deduction;


---------------------------------------------------------------------
--   PROCEDURE: Update_Deduction
--
--   PURPOSE: This procedure update a Deduction. It calls the Update_claim function
--            in the private package.
--
--   PARAMETERS:
--   IN:
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       P_deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--       x_object_version_number   OUT NOCOPY NUMBER
--       X_CLAIM_REASON_CODE_ID    OUT NOCOPY NUMBER
--       X_CLAIM_REASON_NAME       OUT NOCOPY VARCHAR2
--       X_CLAIM_ID,               OUT NOCOPY NUMBER
--       X_CLAIM_NUMBER            OUT NOCOPY VARCHAR2
--
--   Note:
--
---------------------------------------------------------------------
PROCEDURE Update_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE,
    x_object_version_number      OUT  NOCOPY  NUMBER,
    x_claim_reason_code_id       OUT  NOCOPY  NUMBER,
    x_claim_reason_name          OUT  NOCOPY  VARCHAR2,
    x_claim_id                   OUT  NOCOPY  NUMBER,
    x_claim_number               OUT  NOCOPY  VARCHAR2
)
IS
l_api_version    CONSTANT NUMBER       := 1.0;
l_api_name       CONSTANT VARCHAR2(30) := 'Update_Deduction';
l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status           VARCHAR2(1);
--
l_deduction_rec           DEDUCTION_REC_TYPE    := p_deduction;

CURSOR csr_claim_identifier(cv_source_object_id IN NUMBER) IS
-- [BEGIN OF BUG 4130258 FIXING]
--  SELECT claim_id
  SELECT root_claim_id
  FROM ozf_claims
  WHERE source_object_id = cv_source_object_id;
--  ORDER BY claim_id DESC;
-- [END OF BUG 4130258 FIXING]

CURSOR csr_claim_object_version(cv_claim_id IN NUMBER) IS
  SELECT claim_number
  ,      object_version_number
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_ar_receipt(cv_receipt_id IN NUMBER) IS
  SELECT receipt_number
  FROM ar_cash_receipts
  WHERE cash_receipt_id = cv_receipt_id;

CURSOR csr_return_claim_info(cv_claim_id IN NUMBER) IS
  SELECT c.claim_id
  ,      c.claim_number
  ,      c.object_version_number
  ,      c.reason_code_id
  ,      r.name
  FROM ozf_claims c
  , ozf_reason_codes_vl r
  WHERE c.claim_id = cv_claim_id
  AND c.reason_code_id = r.reason_code_id;

  -- Fix for 5182492
CURSOR csr_previous_claim_info(cv_claim_id IN NUMBER) IS
  SELECT amount ,
         due_date ,
         claim_date ,
         claim_type_id ,
         reason_code_id ,
         currency_code ,
         cust_account_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_object_version_number   NUMBER;
l_pvt_claim_rec           OZF_CLAIM_PVT.claim_Rec_Type;
l_user_status_id          NUMBER :=FND_API.G_MISS_NUM;
l_custom_setup_id         NUMBER;
l_claim_obj_ver_num       NUMBER;

-- Fix for 5182492
l_claim_old_amount        NUMBER;
l_claim_old_duedate       DATE;
l_claim_old_typeId        NUMBER;
l_claim_old_reasonId      NUMBER;
l_claim_old_date          DATE;
l_claim_old_currencyCode  VARCHAR2(15);
l_claim_old_accId         NUMBER;
l_perform_subs_apply      BOOLEAN;

-- get object_version_number, claim_reason_code_id
CURSOR claim_number_csr(p_id in number) IS
SELECT object_version_number,
       reason_code_id,
       claim_id,
       claim_number
FROM   ozf_claims_all
WHERE  claim_id = p_id;

-- get claim_reason_name
CURSOR claim_name_csr(p_reason_code_id in number) IS
SELECT name
FROM   ozf_reason_codes_all_tl
WHERE  reason_code_id = p_reason_code_id;

-- get object_version_number
CURSOR claim_object_version_csr(p_id in number) IS
SELECT object_version_number
FROM   ozf_claims_all
WHERE  claim_id = p_id;

-- get minimum required data
CURSOR claim_min_req_data_csr(p_id in number) IS
SELECT claim_number
FROM   ozf_claims_all
WHERE  claim_id = p_id;

-- get claim_id, claim_number incase it is not passed by AR.
CURSOR get_claim_identifier_csr(p_source_object_id in number) IS
SELECT root_claim_id,claim_number
FROM   ozf_claims_all
WHERE  source_object_id = p_source_object_id
AND    root_claim_id = claim_id;
--AND    status_code <> 'CLOSED';

--//Bugfix : 8262818
CURSOR cur_active_receipt (p_claim_id        IN NUMBER
                          ,p_cash_receipt_id IN NUMBER ) IS
   SELECT  ra.cash_receipt_id,
           cr.receipt_number
   FROM  ar_receivable_applications_all ra,
         ar_cash_receipts_all cr
   WHERE ra.cash_receipt_id              =  cr.cash_receipt_id
   AND   ra.cash_receipt_id              <>  p_cash_receipt_id
   AND   ra.application_ref_type         = 'CLAIM'
   AND   ra.secondary_application_ref_id = p_claim_id
   AND   ra.status                       = 'APP'
   AND   ra.display                      = 'Y';

l_active_rec_id       NUMBER       :=NULL;
l_active_rec_number   VARCHAR2(30) := NULL;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_CLAIM_GRP;

   Write_Log(l_full_name, 'start');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -----------------------------------------
   -- 1. Minimum required fields checking --
   -----------------------------------------
   -- "claim_id" or "source_object_id" is required field for updat_deduction
   IF l_deduction_rec.claim_id IS NULL AND
      l_deduction_rec.source_object_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INSUFFICIENT_VAL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_deduction_rec.applied_action_type IS NULL OR
      l_deduction_rec.applied_action_type NOT IN ('A','U') THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_ACTION');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      IF l_deduction_rec.applied_action_type = 'A' THEN
         IF l_deduction_rec.amount IS NULL OR
            l_deduction_rec.receipt_id IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_INSUFFICIENT_VAL_A');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF l_deduction_rec.applied_action_type = 'U' THEN
         IF l_deduction_rec.amount IS NULL OR
            l_deduction_rec.amount_applied IS NULL OR
            l_deduction_rec.applied_receipt_id IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_INSUFFICIENT_VAL_U');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;

   ------------------------------------------
   -- 2. Default and derive column valude  --
   ------------------------------------------
   --derive claim_id, claim_number from source_object_id
   IF l_deduction_rec.claim_id IS NULL THEN
      OPEN  csr_claim_identifier(l_deduction_rec.source_object_id);
      FETCH csr_claim_identifier INTO l_deduction_rec.claim_id;
      CLOSE csr_claim_identifier;
   END IF;

   -- Get latest object_version_number
   OPEN  csr_claim_object_version(l_deduction_rec.claim_id);
   FETCH csr_claim_object_version INTO l_deduction_rec.claim_number
                                     , l_deduction_rec.object_version_number;
   CLOSE csr_claim_object_version;

   --//Bugfix : 8262818
   --//Get the active receipt details from AR
   OPEN  cur_active_receipt(l_deduction_rec.claim_id,l_deduction_rec.receipt_id);
   FETCH cur_active_receipt INTO l_active_rec_id,l_active_rec_number;
   CLOSE  cur_active_receipt;

   l_deduction_rec.receipt_id       := NVL(l_active_rec_id,l_deduction_rec.receipt_id);
   l_deduction_rec.receipt_number   := NVL(l_active_rec_number,l_deduction_rec.receipt_number);

   -- derive receipt_number from receipt_id
   IF l_deduction_rec.receipt_id IS NOT NULL AND
      l_deduction_rec.receipt_number IS NULL THEN
      OPEN csr_ar_receipt(l_deduction_rec.receipt_id);
      FETCH csr_ar_receipt INTO l_deduction_rec.receipt_number;
      CLOSE csr_ar_receipt;
   END IF;

   -- switch amount sign for claim investigation
   IF l_deduction_rec.source_object_id IS NULL THEN
      l_deduction_rec.amount := l_deduction_rec.amount * -1;
   END IF;

   -- [Begin of Debug Message]
   Write_Log(l_full_name, 'claim_number      = '||l_deduction_rec.claim_number);
   Write_Log(l_full_name, 'amount            = '||l_deduction_rec.amount);
   Write_Log(l_full_name, 'action type       = '||l_deduction_rec.applied_action_type);
   Write_Log(l_full_name, 'apply receipt id  = '||l_deduction_rec.applied_receipt_id);
   Write_Log(l_full_name, 'reference receipt = '||l_deduction_rec.receipt_number);
   -- [Begin of Debug Message]


   ----------------------------------------------------------
   -- 3. Required Fields checking for Apply or Unapply Action
   ----------------------------------------------------------
   IF (l_deduction_rec.claim_id           IS NULL OR
       l_deduction_rec.claim_id           =  FND_API.G_MISS_NUM
      )  OR
      (l_deduction_rec.amount             IS NULL OR
       l_deduction_rec.amount             =  FND_API.G_MISS_NUM
      )  THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INSUF_VAL_UPD');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      IF l_deduction_rec.applied_action_type = 'A' THEN
         IF (l_deduction_rec.amount_applied     IS NULL OR
             l_deduction_rec.amount_applied     =  FND_API.G_MISS_NUM
            ) OR
            (l_deduction_rec.applied_receipt_id IS NULL OR
             l_deduction_rec.applied_receipt_id =  FND_API.G_MISS_NUM
            ) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INSUF_VAL_UPD');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF l_deduction_rec.applied_action_type = 'U' THEN
         IF (l_deduction_rec.amount_applied     IS NULL OR
             l_deduction_rec.amount_applied     =  FND_API.G_MISS_NUM
            ) OR
            (l_deduction_rec.applied_receipt_id IS NULL OR
             l_deduction_rec.applied_receipt_id =  FND_API.G_MISS_NUM
            ) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INSUF_VAL_UPD');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_ACTION_UPD');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF l_deduction_rec.applied_action_type = 'A' THEN
      ----------------
      -- 4.1. Apply --
      ----------------
    -- Fix for 5182492
    -- If invoice deduction, then perform subsequent apply always
    -- If claim investigation, then check if sign of amount has changed.
    -- If amount sign has changed, then a new claim has to be created.

    l_perform_subs_apply := TRUE;
    IF l_deduction_rec.source_object_id IS NULL THEN
       OPEN  csr_previous_claim_info(l_deduction_rec.claim_id);
       FETCH csr_previous_claim_info  INTO l_claim_old_amount,
                                           l_claim_old_duedate,
                                           l_claim_old_date,
                                           l_claim_old_typeId,
                                           l_claim_old_reasonId,
                                           l_claim_old_currencyCode,
                                           l_claim_old_accId;
       CLOSE csr_previous_claim_info;

       IF SIGN(l_deduction_rec.amount) <> SIGN(l_claim_old_amount  * -1) THEN

           Write_Log(l_full_name, 'Creating a new Claim');
           l_perform_subs_apply     :=  FALSE;
           l_deduction_rec.claim_id := FND_API.G_MISS_NUM;
           l_deduction_rec.claim_number := FND_API.G_MISS_CHAR;
           l_deduction_rec.claim_date := l_claim_old_date;
           l_deduction_rec.due_date := l_claim_old_duedate;
           l_deduction_rec.claim_type_id := l_claim_old_typeId;
           l_deduction_rec.reason_code_id :=  l_claim_old_reasonId;
           l_deduction_rec.currency_code := l_claim_old_currencyCode;
           l_deduction_rec.cust_account_id := l_claim_old_accId;

           Create_Deduction(
             p_api_version_number     => 1.0,
             p_init_msg_list          => FND_API.g_false,
             p_validation_level       => FND_API.g_valid_level_full,
             p_commit                 => FND_API.g_false,
             x_return_status          => x_return_status,
             x_msg_count              => x_msg_count,
             x_msg_data               => x_msg_data,
             p_deduction              => l_deduction_rec,
             x_claim_id               => x_claim_id,
             x_claim_number           => x_claim_number,
             x_claim_reason_code_id   => x_claim_reason_code_id,
             x_claim_reason_name      => x_claim_reason_name
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
        END IF; -- amount sign has changed
    END IF ; -- is inv deduction

    IF l_perform_subs_apply THEN
        Perform_Subsequent_Apply(
                p_api_version           => l_api_version
               ,p_init_msg_list         => FND_API.g_false
               ,p_validation_level      => FND_API.g_valid_level_full
               ,x_return_status    => l_return_status
               ,x_msg_count             => x_msg_count
               ,x_msg_data              => x_msg_data
               ,p_deduction             => l_deduction_rec
        );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

   ELSIF l_deduction_rec.applied_action_type = 'U' THEN
      -----------------
      -- 4.2. Unpply --
      -----------------
      Perform_Subsequent_Unapply(
              p_api_version           => l_api_version
             ,p_init_msg_list         => FND_API.g_false
             ,p_validation_level      => FND_API.g_valid_level_full
             ,x_return_status         => l_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
             ,p_deduction             => l_deduction_rec
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   ---------------------------------------
   -- 5. Assign value to OUT parameters --
   ---------------------------------------
   OPEN  csr_return_claim_info(l_deduction_rec.claim_id);
   FETCH csr_return_claim_info INTO x_claim_id
                                  , x_claim_number
                                  , x_object_version_number
                                  , x_claim_reason_code_id
                                  , x_claim_reason_name;
   CLOSE csr_return_claim_info;

   Write_Log(l_full_name, 'claim_id = '||x_claim_id);
   Write_Log(l_full_name, 'claim_number = '||x_claim_number);
   Write_Log(l_full_name, 'reason_code_id = '||x_claim_reason_code_id);
   Write_Log(l_full_name, 'claim_reason_name = '||x_claim_reason_name);


   Write_Log(l_full_name, 'end');

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count    => x_msg_count,
      p_data     => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_CLAIM_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_CLAIM_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_claim_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Update_Deduction;


---------------------------------------------------------------------
--   PROCEDURE: Check_Cancell_Deduction
--
--   PURPOSE: This function checks whether a claims can be cancelled or not.
--
--   PARAMETERS:
--       p_claim_id                IN   NUMBER              Required
--
--   Note:
---------------------------------------------------------------------
FUNCTION Check_Cancell_Deduction(
    p_claim_id       IN  NUMBER
) RETURN BOOLEAN
IS
l_return                 BOOLEAN := FALSE;
l_status_code            VARCHAR2(30);
l_amount_remaining       NUMBER;
l_open_flag              VARCHAR2(1) := 'T';
l_claim_mode             VARCHAR2(1) := 'A';
l_root_claim_id          NUMBER;
l_sql_stmt               VARCHAR2(1000);
idx                      NUMBER;
TYPE ClaimCurTyp IS REF CURSOR;
split_claims_csr         ClaimCurTyp;

BEGIN

   l_sql_stmt := 'SELECT root_claim_id, status_code '||
                 'FROM ozf_claims  '||
                 'WHERE claim_id = :1 ';

   EXECUTE IMMEDIATE l_sql_stmt
     INTO l_root_claim_id
        , l_status_code
     USING p_claim_id;

   -- for manual solution (when splits have individual applications)
   IF l_root_claim_id <> p_claim_id THEN
      l_claim_mode := 'M';
      IF l_status_code <> 'OPEN' THEN
         l_open_flag := 'F';
      END IF;
   END IF;

   -- for automated solution
   IF l_claim_mode = 'A' THEN

      l_sql_stmt := 'SELECT status_code, amount_remaining '||
                    'FROM ozf_claims '||
                    'WHERE root_claim_id = :1 ';

      OPEN split_claims_csr FOR l_sql_stmt USING p_claim_id;
      LOOP
         FETCH split_claims_csr INTO l_status_code
                                   , l_amount_remaining;
         EXIT WHEN split_claims_csr%NOTFOUND OR split_claims_csr%NOTFOUND IS NULL;

         IF l_status_code NOT IN ('OPEN', 'COMPETE', 'REJECTED', 'CLOSED') THEN
            IF l_status_code = 'CANCELLED' THEN
               IF l_amount_remaining <> 0 THEN
                  l_open_flag := 'F';
               END IF;
            ELSE
               l_open_flag := 'F';
            END IF;
         END IF;
         idx := idx + 1;
      END LOOP;
      CLOSE split_claims_csr;
   END IF;

   IF l_open_flag = 'T' THEN
      l_return := TRUE;
   ELSIF l_open_flag = 'F' THEN
      l_return := FALSE;
   END IF;

   RETURN l_return;

END Check_Cancell_Deduction ;


---------------------------------------------------------------------
--   PROCEDURE: Check_Cancell_Deduction
--
--   PURPOSE: This function checks whether a claims can be cancelled or not.
--
--   PARAMETERS:
--       p_customer_trx_id         IN   NUMBER
--       p_receipt_id              IN   NUMBER  Required
--
--   Note: This function checks whether a claim exists in TM in OPEN status.
---------------------------------------------------------------------
FUNCTION Check_Open_Claims(
    P_Customer_Trx_Id   NUMBER,
    P_Receipt_Id        NUMBER
) RETURN BOOLEAN
IS
l_open_claims_count     NUMBER  := 0;
l_sql_stmt              VARCHAR2(1000);

BEGIN
   IF p_customer_trx_id IS NOT NULL THEN
      l_sql_stmt := 'SELECT COUNT(claim_id) '||
                    'FROM ozf_claims  '||
                    'WHERE source_object_id = :1 '||
                    'AND status_code <> ''CLOSED'' ';

      EXECUTE IMMEDIATE l_sql_stmt
        INTO l_open_claims_count
        USING p_customer_trx_id;

  ELSIF p_customer_trx_id IS NULL AND p_receipt_id IS NOT NULL THEN
      l_sql_stmt := 'SELECT COUNT(claim_id) '||
                    'FROM ozf_claims  '||
                    'WHERE receipt_id = :1 '||
                    'AND status_code <> ''CLOSED'' ';

      EXECUTE IMMEDIATE l_sql_stmt
        INTO l_open_claims_count
        USING p_receipt_id;

  END IF;

  IF l_open_claims_count >= 1 THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END Check_Open_Claims;


---------------------------------------------------------------------
--   PROCEDURE: Get_Claim_Additional_Info
--
--   PURPOSE: The procedure will be used by AR to get additional of info.
--            for invoice related deduction.
--
--   PARAMETERS:
--     IN:
--       p_customer_trx_id         IN   NUMBER
--
--     OUT:
--       x_application_ref_num     OUT  VARCHAR2
--       x_secondary_appl_ref_id   OUT  NUMBER
--       x_customer_reference      OUT  VARCHAR2
--       x_customer_reason         OUT  VARCHAR2
--
--   Note:
---------------------------------------------------------------------
PROCEDURE Get_Claim_Additional_Info(
  p_customer_trx_id         IN   NUMBER,
  x_application_ref_num     OUT  NOCOPY  VARCHAR2,
  x_secondary_appl_ref_id   OUT  NOCOPY  NUMBER,
  x_customer_reference      OUT  NOCOPY  VARCHAR2
)
IS

CURSOR csr_get_claim_dtls (cv_customer_trx_id IN NUMBER) IS
   SELECT claim_id, claim_number, customer_ref_number FROM ozf_claims
     WHERE source_object_id = cv_customer_trx_id
     AND   claim_id = root_claim_id
     AND   root_claim_id IS NOT NULL
     AND   cust_account_id = (SELECT bill_to_customer_id from ra_customer_trx_all
                              WHERE customer_trx_id = cv_customer_trx_id);

BEGIN
/*
   l_sql_stmt := 'SELECT claim_id, claim_number, customer_ref_number '||
                 'FROM ozf_claims  '||
                 'WHERE source_object_id = :1 '||
                 'AND claim_id = root_claim_id ';

   EXECUTE IMMEDIATE l_sql_stmt
     INTO x_application_ref_num
        , x_secondary_appl_ref_id
        , x_customer_reference
     USING p_customer_trx_id;
*/
   OPEN csr_get_claim_dtls(p_customer_trx_id);
   FETCH csr_get_claim_dtls INTO x_application_ref_num
                               , x_secondary_appl_ref_id
                               , x_customer_reference;
   IF csr_get_claim_dtls%NOTFOUND THEN
      x_application_ref_num   := NULL;
      x_secondary_appl_ref_id := NULL;
      x_customer_reference    := NULL;
   END IF;
   CLOSE csr_get_claim_dtls;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF csr_get_claim_dtls%ISOPEN THEN
         CLOSE csr_get_claim_dtls;
      END IF;
      x_application_ref_num   := NULL;
      x_secondary_appl_ref_id := NULL;
      x_customer_reference    := NULL;

   WHEN OTHERS THEN
      IF csr_get_claim_dtls%ISOPEN THEN
         CLOSE csr_get_claim_dtls;
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      x_application_ref_num   := NULL;
      x_secondary_appl_ref_id := NULL;
      x_customer_reference    := NULL;

END Get_Claim_Additional_Info;

END OZF_CLAIM_GRP;

/
