--------------------------------------------------------
--  DDL for Package OZF_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_GL_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvglis.pls 120.1.12010000.3 2010/03/20 13:46:15 kpatro ship $ */

TYPE gl_interface_rec_type IS RECORD (
    EVENT_TYPE_CODE         VARCHAR2(30)
  , EVENT_STATUS_CODE       VARCHAR2(30)
  , SOURCE_ID               NUMBER
  , SOURCE_TABLE            VARCHAR2(30)
  , ADJUSTMENT_TYPE         VARCHAR2(1)  := 'P'
  , DR_CODE_COMBINATION_ID  NUMBER       := NULL
  , CR_CODE_COMBINATION_ID  NUMBER       := NULL
--  , SKIP_ACCOUNT_GEN_FLAG   VARCHAR2(1)  := 'F' --//BKUNJAN -Removed for TM SLA Uptake
);

TYPE gl_interface_tbl_type is TABLE OF gl_interface_rec_type;

/*TYPE amount_rec_type IS RECORD (
    ACCOUNTED_CR        NUMBER
   ,ACCOUNTED_DR        NUMBER
   ,CURR_CODE_FC        VARCHAR2(15)
   ,ENTERED_CR       NUMBER
   ,ENTERED_DR       NUMBER
   ,CURR_CODE_TC        VARCHAR2(15)
   ,LINE_TYPE_CODE         VARCHAR2(30)
   ,CODE_COMBINATION_ID    NUMBER
   ,UTILIZATION_ID      NUMBER
   ,LINE_UTIL_ID        NUMBER
);

TYPE amount_tbl_type is TABLE OF amount_rec_type;
*/

---------------------------------------------------------------------
TYPE CC_ID_REC is RECORD (
                          amount              number,
                          acctd_amount        number,
                          currency_code       varchar2(15),
                          code_combination_id number,
                          utilization_id      number,
                          line_util_id        number
                         );

TYPE CC_ID_TBL is TABLE of CC_ID_REC;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_GL_Account
--
-- PURPOSE
--    gets the GL Account codes for a account type
--       currently supported account types in OMO
--       1. EXPENSE_ACCOUNT
--       2. ACCRUAL_LIABILITY
--       3. VEN_CLEARING
--       4. REC_CLEARING
--       transaction tables
--       1. OZF_CLAIMS_ALL
--       2. OZF_FUNDS_UTILIZED_ALL_B
--
-- PARAMETERS
--    p_source_id   : transaction record pk
--    p_source_table: transaction table
--    p_account_type: GL account type code
--    x_cc_id_tbl   : table of code combination ids
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_GL_Account(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_source_id         IN  NUMBER
   ,p_source_table      IN  VARCHAR2
   ,p_account_type      IN  VARCHAR2
   ,p_event_type        IN  VARCHAR2 DEFAULT NULL
   ,x_cc_id_tbl         OUT NOCOPY CC_ID_TBL);
---------------------------------------------------------------------
-- PROCEDURE
--    set_accounting_rules
--
-- PURPOSE
--    sets accounting rule records
--
-- PARAMETERS
--    p_gl_rec   : the new record to be inserted
--    x_accounting_event_rec  : returns the record for accounting event table
--    x_ae_header_rec         : returns the record for ae header table
--    x_ae_line_rec           : returns the record for ae line table
--
-- NOTES
---------------------------------------------------------------------
/*PROCEDURE  Set_Accounting_Rules(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_return_status     OUT NOCOPY VARCHAR2

   ,p_gl_rec            IN  gl_interface_rec_type
   ,p_acctng_entries    IN varchar2
   ,x_accounting_event_rec  OUT NOCOPY OZF_acctng_events_PVT.acctng_event_rec_type
   ,x_ae_header_rec     OUT NOCOPY OZF_ae_header_PVT.ae_header_rec_type
   ,x_ae_line_tbl       OUT NOCOPY OZF_ae_line_PVT.ae_line_tbl_type );
   */
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Gl_Entry
--
-- PURPOSE
--    Create a gl entry.
--
-- PARAMETERS
--    p_gl_rec   : the new record to be inserted
--    x_event_id  : return the claim_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
-- HISTORY
-- 05/03/2010  kpatro    Updated for ER#9382547 ChRM-SLA Uptake

---------------------------------------------------------------------
PROCEDURE  Create_Gl_Entry (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_gl_rec                 IN    gl_interface_rec_type
 );
---------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Acctng_Entries

--
-- PURPOSE
--    Create accounting headers and lines
--
-- PARAMETERS
--    p_gl_rec   : the new record to be inserted
--    x_event_id  : return the claim_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
/*PROCEDURE  Create_Acctng_Entries (
   p_api_version            IN    NUMBER
  ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,x_return_status          OUT NOCOPY   VARCHAR2
  ,x_msg_data               OUT NOCOPY   VARCHAR2
  ,x_msg_count              OUT NOCOPY   NUMBER

  ,p_event_id               IN    NUMBER
  ,p_gl_rec                 IN    gl_interface_rec_type
);
*/
---------------------------------------------------------------------

-- Start R12 Enhancements

---------------------------------------------------------------------
-- PROCEDURE
--    Revert_GL_Entry
--
-- PURPOSE
--    When promptional claims are cancelled, this API is called to
--      delete corresponding accounting entries. If the entries
--      are already interfaced to GL, entries in reverse will be
--      created to undo the posting.
--
-- PARAMETERS
--    p_claim_id : the claim that is cancelled
--
-- NOTES
---------------------------------------------------------------------
/*PROCEDURE Revert_GL_Entry (
    p_api_version         IN    NUMBER
   ,p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_claim_id            IN    NUMBER
);
*/
---------------------------------------------------------------------


---------------------------------------------------------------------
-- PROCEDURE
--    Post_Accrual_To_GL
--
-- PURPOSE
--    For budget adjustment/utilization, the API will be called.
--
-- PARAMETERS
--   p_utilization_id          Funds utilization_id
--   p_event_type_code         SLA Event type code
--   p_dr_code_combination_id   Debit code combination id
--   p_cr_code_combination_id   Credit code combination id
--   p_skip_acct_gen_flag       'F' to call OZF Account Generator worflow or
--                                not on top of above two gl accounts passed.
--                                'T' to bypass OZF Account Generator worflow
--                                to derive account.
--
-- NOTES
-- 8-Mar-10  BKUNJAN    ER#9382547 ChRM-SLA Uptake - Removed the OUT parameter
--                      x_event_id and  IN Parameter p_adjustment_type.
--                      renamed  p_utilization_type to p_event_type_code.
--                      removed p_skip_acct_gen_flag.
---------------------------------------------------------------------
PROCEDURE Post_Accrual_To_GL (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_utilization_id          IN  NUMBER
   ,p_event_type_code         IN  VARCHAR2
   ,p_dr_code_combination_id  IN  NUMBER   := NULL
   ,p_cr_code_combination_id  IN  NUMBER   := NULL
   );

---------------------------------------------------------------------
-- PROCEDURE
--    Post_Claim_To_GL

--
-- PURPOSE
--    For Claim settlement to be posted to GL, use this API.
--
-- PARAMETERS
--   p_claim_id                   Claim_id
--   p_claim_class                'CLAIM''CHARGE''DEDUCTION''OVERPAYMENT'
--   p_settlement_method          'CREDIT_MEMO''DEBIT_MEMO''CHECK''AP_DEBIT'
--   x_clear_code_combination_id  Code combination id of AR or AP clearing account
--
-- NOTES
-- HISTORY
-- 09-Mar-2010       KPATRO ER#9382547 ChRM-SLA Uptake -Removed the
--                                    OUT parameter x_event_id,
--                                        x_clear_code_combination_id
--                                    IN  p_claim_class
---------------------------------------------------------------------
PROCEDURE Post_Claim_To_GL (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_claim_id            IN  NUMBER
   ,p_settlement_method   IN  VARCHAR2
   );

---------------------------------------------------------------------
-- PROCEDURE
--    Defer_Claim_GL_Posting (Function)
--
-- PURPOSE
--    Function to be used by Claims to test if 'OZF: Claim
--     Settlement Workflow' should be called to defer GL posting
--
-- PARAMETERS
--    p_claim_id  : claim_id for which the check is done.
--
-- NOTES
---------------------------------------------------------------------
/*FUNCTION Defer_Claim_GL_Posting (
   p_claim_id          IN  NUMBER
) RETURN BOOLEAN;
*/
-- End R12 Enhancements

--SHOW ERRORS;

END OZF_GL_INTERFACE_PVT;


/
