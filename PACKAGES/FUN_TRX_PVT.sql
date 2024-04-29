--------------------------------------------------------
--  DDL for Package FUN_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRX_PVT" AUTHID CURRENT_USER AS
/* $Header: funtrxvalpvts.pls 120.12.12010000.6 2009/11/11 07:35:53 srampure ship $ */


   TYPE batch_rec_type IS RECORD (
      batch_id               NUMBER (15),
      batch_number           VARCHAR2 (20),
      initiator_id           NUMBER (15),
      from_le_id             NUMBER (15),
      from_ledger_id         NUMBER (15),
      control_total          NUMBER,
      currency_code          VARCHAR2 (15),
      exchange_rate_type     VARCHAR2 (30),
      status                 VARCHAR2 (15),
      description            VARCHAR2 (240),
      trx_type_id            NUMBER (15),
      trx_type_code          VARCHAR2 (15),
      gl_date                DATE,
      batch_date             DATE,
      reject_allowed         VARCHAR2 (1),
      from_recurring_batch   NUMBER (15),
      automatic_proration_flag VARCHAR2(1)
   );

   TYPE trx_rec_type IS RECORD (
      trx_id                  NUMBER (15),
      initiator_id            NUMBER (15),
      recipient_id            NUMBER (15),
      to_le_id                NUMBER (15),
      to_ledger_id            NUMBER (15),
      batch_id                NUMBER (15),
      status                  VARCHAR2 (15),
      init_amount_cr          NUMBER,
      init_amount_dr          NUMBER,
      reci_amount_cr          NUMBER,
      reci_amount_dr          NUMBER,
      ar_invoice_number       VARCHAR2 (50),
      invoicing_rule          VARCHAR2 (1),
      approver_id             NUMBER (15),
      approval_date           DATE,
      original_trx_id         NUMBER (15),
      reversed_trx_id         NUMBER (15),
      from_recurring_trx_id   NUMBER (15),
      initiator_instance      VARCHAR2 (1),
      recipient_instance      VARCHAR2 (1),
      automatic_proration_flag VARCHAR2(1),
      trx_number              VARCHAR2(15)
   );
   --Bug: 9104801
   TYPE trx_total_rec_type IS RECORD (
      trx_id                  NUMBER (15),
      total_amount_cr          NUMBER,
      total_amount_dr          NUMBER
   );

   TYPE line_rec_type IS RECORD (
      line_id          NUMBER (15),
      trx_id           NUMBER (15),
      line_number      NUMBER (15),
      line_type        VARCHAR2 (1),
      init_amount_cr   NUMBER,
      init_amount_dr   NUMBER,
      reci_amount_cr   NUMBER,
      reci_amount_dr   NUMBER
   );

   TYPE init_dist_rec_type IS RECORD (
      batch_dist_id   NUMBER (15),
      line_number     NUMBER (15),
      batch_id        NUMBER (15),
      ccid            NUMBER (15),
      amount_cr       NUMBER,
      amount_dr       NUMBER,
      description     VARCHAR2(240)
   );

   TYPE dist_line_rec_type IS RECORD (
      dist_id         NUMBER (15),
      dist_number     NUMBER (15),
      trx_id          NUMBER (15),
      line_id         NUMBER (15),
      party_id        NUMBER,
      party_type      VARCHAR2 (1),
      dist_type       VARCHAR2 (1),
      batch_dist_id   NUMBER (15),
      amount_cr       NUMBER,
      amount_dr       NUMBER,
      ccid            NUMBER (15),
      trx_number      VARCHAR2(15)
   );

   -- Index-By-Table definitions
   TYPE batch_tbl_type IS TABLE OF batch_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE trx_tbl_type IS TABLE OF trx_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE trx_total_tbl_type IS TABLE OF trx_total_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE line_tbl_type IS TABLE OF line_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE init_dist_tbl_type IS TABLE OF init_dist_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE dist_line_tbl_type IS TABLE OF dist_line_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE number_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

        /*-- Nested-Table definitions
        TYPE Batch_Tbl_Type IS TABLE OF Batch_Rec_Type;
        TYPE Trx_Tbl_Type IS TABLE OF Trx_Rec_Type;
        TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type;
        TYPE Init_Dist_Tbl_Type IS TABLE OF Init_Dist_Rec_Type;
        TYPE Dist_Line_Tbl_Type IS TABLE OF Dist_Line_Rec_Type;
        TYPE NUMBER_Type IS TABLE OF NUMBER;
        */
-- Start of comments
--      API name : Init_Batch_Validate
--      Type : Private
--      Function : This procedure should only be called from the initiator UI,
--                 Web ADI and initiator workflow, and it would perform the
--                 validations on a specific batch.  Depending
--                 upon the validation level given, it would perform either
--                 the minimal validation for saving the record into the
--                 database, or it would perform full validations for the
--                 record to be sent out to the recipient.  Full validations
--                 should be called for all stages on or after the the
--                 transaction has been sent out.
--                 Minimal validations would be performed if
--                 p_validation_level = 50, and full validations
--                 would be performed if p_validation_level =
--                 FND_API.G_VALID_LEVEL_FULL (100).
--                 The default of this procedure is to perform
--                 full validations.
--                 It is the responsibility of the calling program to commit
--                 the record after performing the validations.  This API is
--                 not responsible to perform any commit.
--      Pre-reqs : None.
--      Parameters :
--      IN      :       p_api_version   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_insert IN VARCHAR2 Required
--                      p_batch_rec IN OUT NOCOPY BATCH_REC_TYPE Required
--                      p_trx_tbl IN OUT NOCOPY TRX_TBL_TYPE Required
--                      p_init_dist_tbl IN OUT NOCOPY INIT_DIST_TBL_TYPE Required
--                      p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE init_batch_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_insert             IN              VARCHAR2 default null,
      p_batch_rec          IN OUT NOCOPY   batch_rec_type,
      p_trx_tbl            IN OUT NOCOPY   trx_tbl_type,
      p_init_dist_tbl      IN OUT NOCOPY   init_dist_tbl_type,
      p_dist_lines_tbl     IN OUT NOCOPY   dist_line_tbl_type
   );

-- Start of comments
--      API name : Init_Trx_Validate
--      Type : Private
--      Function : This procedure should only be called from the initiator UI,
--                 Web ADI and initiator workflow, and it would perform the
--                 validations on a specific transaction.  Depending
--                 upon the validation level given, it would perform either
--                 the minimal validation for saving the record into the
--                 database, or it would perform full validations for the
--                 record to be sent out to the recipient.  Full validations
--                 should be called for all stages on or after the the
--                 transaction has been sent out.
--                 Minimal validations would be performed if
--                 p_validation_level = 50, and full validations
--                 would be performed if p_validation_level =
--                 FND_API.G_VALID_LEVEL_FULL (100).
--                 The default of this procedure is to perform
--                 full validations.
--                 It is the responsibility of the calling program to commit
--                 the record after performing the validations.  This API is
--                 not responsible to perform any commit.
--      Pre-reqs : None.
--      Parameters :
--      IN      :       p_api_version   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_trx_rec IN OUT NOCOPY TRX_REC_TYPE Required
--                      p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE init_trx_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null ,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_trx_rec            IN OUT NOCOPY   trx_rec_type,
      p_dist_lines_tbl     IN OUT NOCOPY   dist_line_tbl_type,
      p_currency_code      IN              VARCHAR2,
      p_gl_date            IN              DATE,
      p_trx_date           IN              DATE
   );

-- Start of comments
--      API name : Init_Dist_Validate
--      Type : Private
--      Function : This procedure should only be called from the initiator UI,
--                 Web ADI and initiator workflow, and it would perform the
--                 validations on a specific distribution line.  Depending
--                 upon the validation level given, it would perform either
--                 the minimal validation for saving the record into the
--                 database, or it would perform full validations for the
--                 record to be sent out to the recipient.  Full validations
--                 should be called for all stages on or after the the
--                 transaction has been sent out.
--                 Minimal validations would be performed if
--                 p_validation_level = 50, and full validations
--                 would be performed if p_validation_level =
--                 FND_API.G_VALID_LEVEL_FULL (100).
--                 The default of this procedure is to perform
--                 full validations.
--                 It is the responsibility of the calling program to commit
--                 the record after performing the validations.  This API is
--                 not responsible to perform any commit.
--      Pre-reqs : None.
--      Parameters :
--      IN      :       p_api_version   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_init_dist_rec IN OUT NOCOPY INIT_DIST_REC_TYPE Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE init_dist_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      p_le_id          IN              NUMBER,
      p_ledger_id          IN              NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_init_dist_rec      IN OUT NOCOPY   init_dist_rec_type
   );

-- Start of comments
--      API name : Init_IC_Dist_Validate
--      Type : Private
--      Function : This procedure should only be called from the initiator UI,
--                 Web ADI and initiator workflow, and it would perform the
--                 validations on a specific distribution entry.  Depending
--                 upon the validation level given, it would perform either
--                 the minimal validation for saving the record into the
--                 database, or it would perform full validations for the
--                 record to be sent out to the recipient.  Full validations
--                 should be called for all stages on or after the the
--                 transaction has been sent out.
--                 Minimal validations would be performed if
--                 p_validation_level = 50, and full validations
--                 would be performed if p_validation_level =
--                 FND_API.G_VALID_LEVEL_FULL (100).
--                 The default of this procedure is to perform
--                 full validations.
--                 It is the responsibility of the calling program to commit
--                 the record after performing the validations.  This API is
--                 not responsible to perform any commit.
--      Pre-reqs : None.
--      Parameters :
--      IN      :       p_api_version   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_dist_line_rec_type  IN OUT NOCOPY
--                              DIST_LINE_REC_TYPE Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE init_ic_dist_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      p_le_id              IN              NUMBER,
      p_ledger_id          IN              NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_dist_line_rec      IN OUT NOCOPY   dist_line_rec_type
   );

-- Start of comments
--      API name : Init_Generate_Distributions
--      Type : Public
--      Function : This procedure would perform the proration of the
--                 Initiator distribution lines.
--                 This procedure should only be called from the initiator UI or
--                 Web ADI only after Init_Batch_Validate procedure is called
--                 in full validation mode and the data has been committed to
--                 the database.
--      Pre-reqs : Init_Batch_Validate is called in full validation mode.
--      Parameters :
--      IN      :       p_api_version   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_dist_line_rec_type  IN OUT NOCOPY
--                              DIST_LINE_REC_TYPE Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE Init_Generate_Distributions (
      p_api_version      IN              NUMBER,
      p_init_msg_list    IN              VARCHAR2 default null,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_batch_rec        IN OUT NOCOPY   batch_rec_type,
      p_trx_tbl          IN OUT NOCOPY   trx_tbl_type,
      p_init_dist_tbl    IN OUT NOCOPY   init_dist_tbl_type,
      p_dist_lines_tbl   IN OUT NOCOPY   dist_line_tbl_type
   );

   PROCEDURE Init_Generate_Distributions (
      p_api_version      IN              NUMBER,
      p_init_msg_list    IN              VARCHAR2 default null,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_batch_id           IN              NUMBER
   );
   /*
-- Start of comments
--      API name        : Set_Return_Status
--      Type    : Private
--      Function        : This function returns the correct status given the
--                        status to be updated and the original status.  There are
--                        totally 3 possible return statuses:
--                        FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR,
--                        and FND_API.G_RET_STS_UNEXP_ERROR .  If the status to
--                        be updated to is more severe than
--                        the original status, then it would update the original
--                        status to new status.  If not, the original status would
--                        remain unchanged.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_new_status IN VARCHAR2(1)     Required
--      OUT     :       x_orig_status   IN OUT  VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE set_return_status (
      x_orig_status   IN OUT NOCOPY   VARCHAR2,
      p_new_status    IN              VARCHAR2
   );

-- Start of comments
--      API name        : Is_Party_Valid
--      Type    : Private
--      Function        : This function checks if the intercompany
--                        party is valid.  This procedure should only be called
--                        in the INITIATOR_VALIDATE and RECIPIENT_VALIDATE call.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_party_id IN NUMBER Required
--                      p_le_id IN NUMBER Required
--                      p_ledger_id IN NUMBER Required
--                      p_instance IN VARCHAR2 Required
--                      p_local IN VARCHAR2 Required
--                      p_type IN VARCHAR2 Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)

   --
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_party_valid (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_party_id        IN              NUMBER,
      p_le_id           IN              NUMBER,
      p_ledger_id       IN              NUMBER,
      p_instance        IN              VARCHAR2,
      p_local           IN              VARCHAR2,
      p_type            IN              VARCHAR2,
      p_batch_date        IN              DATE
   );

-- Start of comments
--      API name        : Is_Init_Trx_Amt_Valid
--      Type    : Private
--      Function        : This function checks whether the initiator transaction amounts are valid.
--                        This procedure should only be called by the Initiator_Validate call.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_trx_amount_cr IN NUMBER Required
--                      p_trx_amount_dr IN NUMBER Required
--                      p_dist_amount_cr IN NUMBER Required
--                      p_dist_amount_dr IN NUMBER Required
--                      p_currency_code IN VARCHAR2 Required
--                      p_trx_date IN DATE
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_init_trx_amt_valid (
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_trx_amount_cr    IN              NUMBER,
      p_trx_amount_dr    IN              NUMBER,
      p_dist_amount_cr   IN              NUMBER,
      p_dist_amount_dr   IN              NUMBER,
      p_currency_code    IN              VARCHAR2,
      p_trx_date         IN              DATE
   );

-- Start of comments
--      API name        : Is_Batch_Num_Unique
--      Type    : Private
--      Function        : This function checks if there are any batches with the same
--                        batch number and initiator id exist in the table.
--                        This procedure should only be called in the INITIATOR_VALIDATE and
--                        RECIPIENT_VALIDATE call.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_batch_number  IN      NUMBER Required
--                      P_initiator_id  IN NUMBER    Required
--      OUT     :       x_return_status OUT     VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_batch_num_unique (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_batch_number    IN              VARCHAR2,
      p_initiator_id    IN              NUMBER
   );
*/
-- Start of comments
--      API name        : Is_AR_Valid
--      Type    : Private
--      Function        : This function checks whether AR is valid or not in the initiator side.
--                        This procedure can be called by the Initiator_Validate call and initiator workflow.
--                        Please keep in mind that this function does not check whether AR period is open or not
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_initiator_id IN NUMBER Required
--                      p_invoicing_rule IN VARCHAR2 Required
--                      p_recipient_id IN NUMBER Required
--                      p_to_le_id IN NUMBER Required
--                      p_trx_date IN DATE Required
--      OUT     :       x_return_status OUT     VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_ar_valid (
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_initiator_id     IN              NUMBER,
      p_invoicing_rule   IN              VARCHAR2,
      p_recipient_id     IN              NUMBER,
      p_to_le_id         IN              NUMBER,
      p_trx_date         IN              DATE
   );
/*
-- Start of comments
--      API name        : Is_Reci_Not_Duplicated
--      Type    : Private
--      Function        : This function ensures that there are no
--                        duplicate recipients in the batch.  This
--                        procedure should only be called in the Initiator_Validate call.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      : p_initiator_id IN NUMBER Required
--                p_trx_tbl     IN TRX_TAB_TYPE Required
--      OUT     : x_return_status       OUT     VARCHAR2
--
--      Version : Current version       1.0
--                Initial version       1.0
--
--      Notes   : None
--
-- End of comments
   PROCEDURE is_reci_not_duplicated (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_initiator_id    IN              NUMBER,
      p_trx_tbl         IN OUT NOCOPY   trx_tbl_type
   );

-- Start of comments
--      API name        : Is_Trx_Type_Valid
--      Type    : Private
--      Function        : This function checks whether the batch type
--                        entered is valid or not.  This
--                        procedure should only be called in
--                        Initiator_Validate and Recipient_Validate calls.
--                        This procedure assumes the message list has
--                        been initialized.  Initiator workflow
--                        should perform its own validations for
--                        checking whether the AR memo lines
--                        and AR transaction types associated with the
--                        batch type is valid, as this function
--                        only checks whether the batch type exists and valid.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_trx_type_id IN NUMBER Required
--      OUT     :       x_return_status OUT     VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_trx_type_valid (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_trx_type_id     IN              NUMBER
   );

-- Start of comments
--      API name        : Is_Init_GL_Date_Valid
--      Type    : Private
--      Function        : This function validates the GL date entered with the
--                        initiator setup.  This function does not validate
--                        the GL date with GL period, as the assumption here is that
--                        GL period must be open if IC period is open.
--                        This procedure should only be called by the Initiator_Validate call.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_from_le_id IN NUMBER Required
--              :       p_gl_date              IN DATE   Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_init_gl_date_valid (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_from_le_id      IN              NUMBER,
      p_gl_date         IN              DATE
   );

-- Start of comments
--      API name        : Is_Curr_Fld_Valid
--      Type    : Private
--      Function        : This function checks whether user has entered a valid currency code.
--                        This  procedure should only be called in Initiator_Validate and
--                        Recipient_Validate calls.
--                        This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_curr_code     IN VARCHAR2 Required
--                      p_trx_date      IN DATE Required
--      OUT     :       x_return_status OUT VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_curr_fld_valid (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_curr_code       IN              VARCHAR2,
      p_ledger_id       IN              NUMBER,
      p_trx_date        IN              DATE
   );
*/
-- Start of comments
--      API name        : Create_Reverse_Batch
--      Type    : Private
--      Function        : This procedure creates a new batch for reversal of the
--                        original batch.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_curr_code     IN VARCHAR2 Required
--                      p_trx_date      IN DATE Required
--      OUT     :       x_return_status OUT VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE create_reverse_batch (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2 default null,
      p_commit                  IN              VARCHAR2 default null,
      p_validation_level        IN              NUMBER default null,
      p_batch_id                IN              NUMBER,
      p_reversed_batch_number   IN              VARCHAR2,
      p_reversal_method         IN              VARCHAR2,
      -- 'SWITCH' OR 'SIGN'
      p_reversed_batch_date     IN              DATE,
      p_reversed_gl_date        IN              DATE,
      p_reversed_description    IN              VARCHAR2,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_reversed_batch_id       IN OUT NOCOPY   NUMBER
   );

   PROCEDURE create_reverse_trx (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2 default null,
      p_commit                  IN              VARCHAR2 default null,
      p_validation_level        IN              NUMBER default null,
      p_trx_tbl_id              IN              number_type,
      p_reversed_batch_number   IN              VARCHAR2,
      p_reversal_method         IN              VARCHAR2,
      -- 'SWITCH' OR 'SIGN'
      p_reversed_batch_date     IN              DATE,
      p_reversed_gl_date        IN              DATE,
      p_reversed_description    IN              VARCHAR2,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_reversed_batch_id       IN OUT NOCOPY   NUMBER
   );

-- Start of comments
--      API name        : Update_Trx_Status
--      Type    : Private
--      Function        : This procedure would update the
--                        status of the transaction as given.  Depending upon the
--                        validation level given, it would perform either no
--                        validations before updating the record into the database,
--                        or it would perform full validations for the record before
--                        the status can be updated.  The no validations should only be
--                        called only if the calling program is an intercompany
--                        procedure and is sure that the status can be updated as given.
--                        No validations would be performed if
--                        p_validation_level = FND_API.G_VALID_LEVEL_NONE, and
--                        full validations would be performed if
--                       p_validation_level = FND_API.G_VALID_LEVEL_FULL.
--                       The default of this procedure is to perform
--                       the full validations.
--                       Currently, p_api_version is not used and is not validated,
--                       but we would put this in the api  as this is a standard IN parameter.
--                       It is the responsibility of the calling program to commit the
--                       record after performing the validations.  This API is not responsible to
--                       perform any commit.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_api_version                   IN NUMBER Required
--                      p_init_msg_list IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--                      p_commit                IN VARCHAR2 Optional
--                              Default = FND_API.G_FALSE
--                      p_validation_level      IN NUMBER Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--                      p_trx_tbl_id                IN number_type Required
--                      p_update_status_to      IN VARCHAR(20) Required
--
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--                      x_msg_count     OUT     NUMBER
--                      x_msg_data      OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE update_trx_status (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_commit             IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_trx_id             IN              NUMBER,
      p_update_status_to   IN              VARCHAR2
   );
/*
-- Start of comments
--        API name : Is_Batch_Balance
--        Type: Private
--        Function: This procedure checks to see if the
--                  total(intercompany_distributions_amounts) = total(dist_amounts)
--         Pre-reqs: None.
--         Parameters:
--         IN       :  p_init_dist_tbl IN OUT NOCOPY INIT_DIST_TBL_TYPE
--                     p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
--         OUT      :  x_return_status OUT VARCHAR2(1)
--
--         Version  :  Current version 1.0
--                     Initial version 1.0
--
--         Notes    :  None
--
-- End of comments
   PROCEDURE is_batch_balance (
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_init_dist_tbl    IN OUT NOCOPY   init_dist_tbl_type,
      p_dist_lines_tbl   IN OUT NOCOPY   dist_line_tbl_type
   );
*/
-- Start of comments
--        API name : Recipient_Validate
--        Type: Private
--        Function: This procedure should only be called from the recipient
--                  UI, and recipient workflow, and it would perform the validations
--                  on a specific transaction batch.  Depending upon the validation
--                  level given, it would perform either the minimal validation for
--                  saving the record into the database when receiving the message
--                  in XML Gateway, or it would perform full validations for
--                  the record to be transferred to AP or GL Minimal validations
--                  would be performed if p_validation_level = 50, and full validations
--                  would be performed if p_validation_level = FND_API.G_VALID_LEVEL_FULL (100).
--                  The default of this procedure is to perform the full validations.
--                  Currently, p_api_version is not used and is not validated, but we
--                  would put this in the api as this is a standard IN parameter.
--                  It is the responsibility of the calling program to commit the
--                  record after performing the validations.  This API is not
--                  responsible to perform any commit.
--         Pre-reqs: None.
--         Parameters:
--         IN       :  p_api_version   IN NUMBER Required
--                     p_init_msg_list IN VARCHAR2 Optional
--                             Default = FND_API.G_FALSE
--                     p_validation_level IN NUMBER  Optional
--                             Default = FND_API.G_VALID_LEVEL_FULL
--                     p_batch_rec IN OUT NOCOPY BATCH_REC_TYPE Required
--                     p_trx_rec IN OUT NOCOPY TRX_REC_TYPE Required
--                     p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE Required
--
--         OUT      :  x_return_status OUT VARCHAR2
--                     x_msg_count OUT NUMBER
--                     x_msg_data OUT VARCHAR2
--
--         Version  :  Current version 1.0
--                     Initial version 1.0
--
--         Notes    :  None
--
-- End of comments
   PROCEDURE recipient_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_batch_rec          IN OUT NOCOPY   batch_rec_type,
      p_trx_rec            IN OUT NOCOPY   trx_rec_type,
      p_dist_lines_tbl     IN OUT NOCOPY   dist_line_tbl_type
   );

-- Start of comments
--        API name : Ini_Recipient_Validate
--        Type: Private
--        Function: This procedure should only be called from the initiator
--                  UI, and it would perform the validations
--                  on a specific transaction batch.  Depending upon the validation
--                  level given, it would perform either the minimal validation for
--                  saving the record into the database when receiving the message
--                  in XML Gateway, or it would perform full validations for
--                  the record to be transferred to AP or GL Minimal validations
--                  would be performed if p_validation_level = 50, and full validations
--                  would be performed if p_validation_level = FND_API.G_VALID_LEVEL_FULL (100).
--                  The default of this procedure is to perform the full validations.
--                  Currently, p_api_version is not used and is not validated, but we
--                  would put this in the api as this is a standard IN parameter.
--                  It is the responsibility of the calling program to commit the
--                  record after performing the validations.  This API is not
--                  responsible to perform any commit.
--         Pre-reqs: None.
--         Parameters:
--         IN       :  p_api_version   IN NUMBER Required
--                     p_init_msg_list IN VARCHAR2 Optional
--                             Default = FND_API.G_FALSE
--                     p_validation_level IN NUMBER  Optional
--                             Default = FND_API.G_VALID_LEVEL_FULL
--                     p_batch_rec IN OUT NOCOPY BATCH_REC_TYPE Required
--                     p_trx_rec IN OUT NOCOPY TRX_REC_TYPE Required
--                     p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE Required
--
--         OUT      :  x_return_status OUT VARCHAR2
--                     x_msg_count OUT NUMBER
--                     x_msg_data OUT VARCHAR2
--
--         Version  :  Current version 1.0
--                     Initial version 1.0
--
--         Notes    :  None
--
-- End of comments
   PROCEDURE ini_recipient_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_batch_rec          IN OUT NOCOPY   batch_rec_type,
      p_trx_rec            IN OUT NOCOPY   trx_rec_type,
      p_dist_lines_tbl     IN OUT NOCOPY   dist_line_tbl_type
   );

-- Start of comments
--      API name        : Is_AP_Valid
--      Type    : Private
--      Function        : This function checks whether AP is valid or
--                        not in the Recipient side.
--                        This procedure can be called by the Recipient_Validate
--                        call and recipient workflow.  Please keep in mind that
--                        this function does not check whether AP period is open
--                        or not when using this function.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_initiator_id   IN NUMBER Required
--                      p_invoicing_rule  IN VARCHAR2 Required
--                      p_recipient_id  IN NUMBER Required
--                      p_to_le_id      IN NUMBER Required
--                      p_trx_date      IN NUMBER Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_ap_valid (
      x_return_status    OUT NOCOPY      VARCHAR2,
      p_initiator_id     IN              NUMBER,
      p_invoicing_rule   IN              VARCHAR2,
      p_recipient_id     IN              NUMBER,
      p_to_le_id         IN              NUMBER,
      p_trx_date         IN              DATE
   );

-- Start of comments
--      API name        : Is_Payable_Acct_Valid
--      Type    : Private
--      Function        : This procedure can be called by the Recipient_Validate
--                        call and recipient workflow.  It checks whether the
--                        payable account is valid for the recipient.
--
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_ccid   IN NUMBER Required
--      OUT     :       x_return_status OUT     VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE is_payable_acct_valid (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_ccid            IN              NUMBER
   );

-- Start of comments
--      API name        : Debug
--      Type    : Private
--      Function        : This is a helper procedure that checks if  the debug level defined and put a debug message in
--                        varchar2 into the stack.  Since these are debug messages, they would not be put into FND_MESSAGES
--                    for translation.  This procedure assumes the message list has been initialized.
--      Pre-reqs        : None.
--      Parameters      :
--      IN      :       p_message               IN      VARCHAR2        Required
--              p_message_level IN      NUMBER
--      Version :       Current version 1.0
--                      Initial version         1.0
--
--      Notes   :       None
--
-- End of comments
   PROCEDURE DEBUG (p_message IN VARCHAR2);

-- Start of comments
--        API name : Is_AR_Transfer_Valid
--        Type: Private
--        Function: This procedure should only be called from the initiator workflow
--                  to perform validations during the transaction import to AR.
--                  This procedure would perform the following validations:
--                  1. Check AR transaction type and memo line.
--                  2. Check customer information
--                  3. Check Operating unit
--                  4. Check AR period
--         Pre-reqs: None.
--         Parameters:
--         IN       :  p_api_version   IN NUMBER Required
--                     p_init_msg_list IN VARCHAR2 Optional
--                             Default = FND_API.G_FALSE
--                     p_validation_level IN NUMBER  Optional
--                             Default = FND_API.G_VALID_LEVEL_FULL
--                     p_batch_id IN NUMBER
--                     p_trx_id IN NUMBER
--
--         OUT      :  x_return_status OUT VARCHAR2
--                     x_msg_count OUT NUMBER
--                     x_msg_data OUT VARCHAR2
--
--         Version  :  Current version 1.0
--                     Initial version 1.0
--
--         Notes    :  None
--
-- End of comments
   PROCEDURE ar_transfer_validate (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 default null,
      p_validation_level   IN              NUMBER default null,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_batch_id           IN              NUMBER,
      p_trx_id             IN              NUMBER
   );


-- Start of comments
--        API name : cancel_notifications
--        Type: Private
--        Function: This procedure is called to cancel open notifications
--                  -called from the Outbound Search page
--                   when a batch is deleted (p_batch_id is passed)
--                  -Or it will be called from the Outbound Create page when a
--                   transaction is deleted (p_batch_id and p_trx_id is passed)
--         Pre-reqs: None.
--         Parameters:
--         IN       :
--                     p_init_msg_list IN VARCHAR2 Optional
--                             Default = FND_API.G_FALSE
--                     p_batch_id IN NUMBER
--                     p_trx_id IN NUMBER
--
--         OUT      :  x_return_status OUT VARCHAR2
--                     x_msg_count OUT NUMBER
--                     x_msg_data OUT VARCHAR2
--
--
--         Notes    :  None
--
-- End of comments
PROCEDURE cancel_notifications (p_batch_id        IN NUMBER,
                              p_trx_id          IN NUMBER,
                              p_init_msg_list   IN VARCHAR2 ,
                              x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
                              x_msg_data        OUT NOCOPY VARCHAR2);


-- Start of comments
--        API name : check_invoice_reqd_flag
--        Type: Private
--        Function: This procedure is called to determine if invoice
--                  -is required for a transaction.
--         Pre-reqs: None.
--         Parameters:
--         IN       :
--                     p_init_party_id IN  NUMBER
--                     p_init_le_id         IN NUMBER,
--                     p_reci_party_id      IN NUMBER,
--                     p_reci_le_id         IN NUMBER,
--                     p_ttyp_invoice_flag  IN VARCHAR2,
--
--         OUT      :  x_invoice_required VARCHAR2
--                     x_return_status    VARCHAR2
--
--
--         Notes    :  None
--
-- End of comments
PROCEDURE check_invoice_reqd_flag(p_init_party_id      IN  NUMBER,
                                  p_init_le_id         IN NUMBER,
                                  p_reci_party_id      IN NUMBER,
                                  p_reci_le_id         IN NUMBER,
                                  p_ttyp_invoice_flag  IN VARCHAR2,
                                  x_invoice_required   OUT NOCOPY VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2);

-- Start of comments
--        API name : validate_org_assignment
--        Type: Private
--        Function: This procedure is called to check whether the oranization assignment is
--                  defined with all the options check for at least one user or not.
--                  Set an error message if there is no such organization assignment
--         Pre-reqs: None.
--         Parameters:
--         IN       :
--                     p_party_id IN NUMBER
--
--         OUT      :  x_return_status OUT VARCHAR2
--
--
--         Notes    :  None
--
-- End of comments
/*
PROCEDURE validate_org_assignment
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_party_id  IN      NUMBER
);
*/
-- Bug: 9104801
-- Start of comments
--        API name : adjust_dist_amount
--        Type: Private
--        Procedure: This procedure is the do the adjustment to the distrabution line for
--                   an unbalanced transaction.
--        Pre-reqs: None.
--        Parameters:
--        IN       :
--                     p_trx_id IN NUMBER
--		       p_init_amount_cr   IN              NUMBER
--		       p_init_amount_dr   IN              NUMBER
--
--        Notes    :  None
--
-- End of comments
/*
PROCEDURE adjust_dist_amount
(       p_trx_id          IN NUMBER,
        p_init_amount_cr   IN              NUMBER,
        p_init_amount_dr   IN              NUMBER
);
*/

END FUN_TRX_PVT;

/
