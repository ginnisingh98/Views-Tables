--------------------------------------------------------
--  DDL for Package Body CN_PREPOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PREPOST_PVT" AS
-- $Header: cnvpostb.pls 120.1 2005/08/08 09:57:36 ymao noship $

-- Posting_Status Values
C_POSTED         CONSTANT VARCHAR2(30) := 'POSTED';
C_UNPOSTED       CONSTANT VARCHAR2(30) := 'UNPOSTED';
C_REVERTED       CONSTANT VARCHAR2(30) := 'REVERTED';
-- Default Posting Detail.Status Value
C_UNLOADED       CONSTANT VARCHAR2(30) := 'UNLOADED';
-- Incentive Type Codes
C_COMMISSION     CONSTANT VARCHAR2(30) := 'COMMISSION';
C_BONUS          CONSTANT VARCHAR2(30) := 'BONUS';
C_MANUAL         CONSTANT VARCHAR2(30) := 'MANUAL';
-- Posting Types
C_NON_REC        CONSTANT VARCHAR2(30) := 'NON_REC';
C_REC            CONSTANT VARCHAR2(30) := 'REC';
C_TO_REC         CONSTANT VARCHAR2(30) := 'TO_REC';
C_EXPENSE        CONSTANT VARCHAR2(30) := 'EXPENSE';
-- Trx Types
C_COMM_NREC      CONSTANT VARCHAR2(30) := 'COMM_NREC';
C_COMM_REC       CONSTANT VARCHAR2(30) := 'COMM_REC';
C_COMM_TO_REC    CONSTANT VARCHAR2(30) := 'COMM_TO_REC';
C_BONUS_REC      CONSTANT VARCHAR2(30) := 'BONUS_REC';
C_BONUS_TO_REC   CONSTANT VARCHAR2(30) := 'BONUS_TO_REC';
C_MANUAL_EXPENSE CONSTANT VARCHAR2(30) := 'MANUAL_EXPENSE';
-- Designates creation by a system process
C_SYS_POST_PROCESS CONSTANT VARCHAR2(30) := 'SYS_PREPOST_PROCESS';

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'CN_PREPOST_PVT';
G_ROWID                   VARCHAR2(30) := NULL;
G_PROGRAM_TYPE            VARCHAR2(30);
-- ============================================================================
--  Procedure   : Initialize_Batch()
--  Description : This PUBLIC procedure is used to get the ID of the Posting
--                Batch. Each session may have one batch ID.  If this procedure
--                is called and one does not exist, then a batch ID must be
--                initialized privately.
--                The batch name is derived from date, session ID.
--  Calls       :
-- ============================================================================
PROCEDURE Initialize_Batch
(     p_api_version               IN      NUMBER                    ,
      p_init_msg_list             IN      VARCHAR2                  ,
      p_commit                    IN      VARCHAR2                  ,
      p_validation_level          IN      NUMBER                    ,
      x_return_status             OUT NOCOPY     VARCHAR2                  ,
      x_msg_count                 OUT NOCOPY     NUMBER                    ,
      x_msg_data                  OUT NOCOPY     VARCHAR2                  ,
      x_loading_status            OUT NOCOPY     VARCHAR2                  ,
      p_loading_status            IN      VARCHAR2                  ,
      p_posting_batch_rec         IN OUT NOCOPY  CN_PREPOSTBATCHES.posting_batch_rec_type,
      x_status                    OUT NOCOPY     VARCHAR2
)
IS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Initialize_Batch';
      l_api_version               CONSTANT NUMBER := 1.0;
      l_count                              NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT      Initialize_Batch;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version              ,
                                           p_api_version              ,
                                           l_api_name                 ,
                                           G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_loading_status := 'CN_INSERTED';
      -- API body
      -- Check a global batch ID exists for the session
      -- Do nothing if global batch ID already exists
      -- Create batch if global batch ID does not exist for session
      IF (CN_PREPOSTBATCHES.G_BATCH_ID is null) THEN
        -- Get next batch sequence ID
        CN_PREPOSTBATCHES.Get_UID( p_posting_batch_rec.posting_batch_id );
        -- Return and Set global batch ID
        CN_PREPOSTBATCHES.G_BATCH_ID := p_posting_batch_rec.posting_batch_id;
      ELSE
        x_status := 'BATCH ALREADY EXISTS';
        -- Validate the batch is not loaded
        IF p_posting_batch_rec.load_status = 'LOADED' THEN
           x_status := 'BATCH IS ALREADY LOADED';
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      -- End of API body.
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
          (   p_count               =>      x_msg_count           ,
              p_data                =>      x_msg_data
          );
EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Initialize_Batch;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                 );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Initialize_Batch;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                          );
      WHEN OTHERS THEN
            ROLLBACK TO Initialize_Batch;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg
                   (      G_PKG_NAME,
                          l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get
                   (        p_count               =>      x_msg_count,
                            p_data                =>      x_msg_data
                            );
END Initialize_Batch;
-- ============================================================================
--  Procedure      : Terminate_Batch
--  Description    : This PRIVATE procedure is used to terminate the current
--                   batch for a session.
--                   This is done by setting CN_PREPOSTBATCHES.G_BATCH_ID and
--                   G_BATCH_NAME to NULL.
--  Calls            :
-- ============================================================================
PROCEDURE Terminate_Batch IS
BEGIN
      -- Set CN_PREPOSTBATCHES.G_BATCH_ID to NULL
      CN_PREPOSTBATCHES.G_BATCH_ID := NULL;
END Terminate_Batch;
-- ============================================================================
--  Procedure      : Validate_PrePostDetails
--  Description    : This procedure is used to validate the parameters that
--                   have been passed to create a posting detail.
--                   This procedure assumes that information gathered from
--                   CN_COMMISSION_LINES is already valid.
--  Note           : Procedure has been overloaded to accommodate a
--                   commission_line_id and a posting detail record type.
--  Calls          :
-- CAN YOU REVERT A NON COMMISSION LINE BASED TRX?
-- ============================================================================
PROCEDURE Validate_PrePostDetails
(     x_return_status             OUT NOCOPY      VARCHAR2                ,
      x_msg_count                 OUT NOCOPY      NUMBER                  ,
      x_msg_data                  OUT NOCOPY      VARCHAR2                ,
      p_create_mode               IN       VARCHAR2 := 'NEW'       ,
      p_posting_detail_rec        IN       CN_PREPOSTDETAILS.posting_detail_rec_type ,
      p_loading_status            IN       VARCHAR2                ,
      x_loading_status            OUT NOCOPY      VARCHAR2                ,
      x_status                    OUT NOCOPY      VARCHAR2
)
IS
      l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_PrePostDetails';
      l_cl_status                 VARCHAR2(30);
      l_posting_status            VARCHAR2(30);
      CURSOR get_comm_line IS
        SELECT   status, NVL(posting_status, C_UNPOSTED)
        FROM     cn_commission_lines
        WHERE    commission_line_id = p_posting_detail_rec.commission_line_id;
BEGIN
      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Check for null parameters
      IF ( (cn_api.chk_null_num_para
            (p_num_para => p_posting_detail_rec.commission_line_id,
             p_obj_name => 'Commission Line ID',
             p_loading_status => x_loading_status,
             x_loading_status => x_loading_status) ) = FND_API.G_TRUE ) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 1. Validate commission line exists
      OPEN  get_comm_line;
      FETCH get_comm_line INTO l_cl_status, l_posting_status;
      IF    get_comm_line%ROWCOUNT = 0 THEN
        x_status := 'COMMISSION LINE DOES NOT EXIST';
        RAISE FND_API.G_EXC_ERROR;
      ELSIF get_comm_line%ROWCOUNT = 1 THEN
        x_status := 'A COMMISSION LINE EXISTS';
      END IF;
      CLOSE get_comm_line;
      -- 2. Check commission line has been calculated
      IF l_cl_status <> 'CALC' THEN
        x_status := 'COMMISSION LINE IS NOT OF STATUS CALC';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 3. Check p_create_mode valid choices
      IF p_create_mode NOT IN ('NEW', 'REVERT') THEN
        x_status := 'INVALID CREATE MODE';
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_status := 'CREATE MODE EXISTS';
      END IF;
      -- 4. Check commission line is not posted or reverted
      --    previously for a "New" transaction
      IF (l_posting_status in (C_POSTED, C_REVERTED) AND p_create_mode = 'NEW') THEN
        x_status := 'CANNOT CREATE NEW FOR COMMISSION LINE HAS BEEN POSTED OR REVERTED.';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 5. Check commission line is not posted or reverted
      --    previously for a "Revert" transaction
      IF (l_posting_status in (C_UNPOSTED, C_REVERTED) AND p_create_mode = 'REVERT') THEN
        x_status := 'CANNOT CREATE REVERT FOR COMMISSION LINE HAS BEEN POSTED OR REVERTED ALREADY.';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- End of Validate Posting
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
          ( p_count              =>      x_msg_count           ,
            p_data               =>      x_msg_data            ,
            p_encoded            =>      FND_API.G_FALSE
          );
EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_loading_status := 'UNEXPECTED_ERR';
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END IF;
END Validate_PrePostDetails;

-- ============================================================================
--  Procedure      : Create_From_CommLine
--  Description    : This PUBLIC procedure is used to create posting batches
--                   and details from a commission line id.
--                   NEW create mode will update commission line
--  Calls          : Validate_From_CommLines()
-- ============================================================================
PROCEDURE Create_From_CommLine
  (p_api_version            IN      NUMBER                           ,
   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE      ,
   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE      ,
   p_validation_level       IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status          OUT NOCOPY     VARCHAR2                         ,
   x_msg_count              OUT NOCOPY     NUMBER                           ,
   x_msg_data               OUT NOCOPY     VARCHAR2                         ,
   p_create_mode            IN      VARCHAR2 := 'NEW'                ,
   p_commission_line_id     IN      NUMBER) IS

   l_api_name               CONSTANT VARCHAR2(30)   := 'Create_From_CommLine';
   l_api_version            CONSTANT NUMBER         := 1.0;
   l_loading_status                  VARCHAR2(4000);
   l_status                          VARCHAR2(4000);
   l_pmt_trans_rec              CN_PMT_TRANS_PKG.pmt_trans_rec_type;
   l_posting_batch_rec               CN_PREPOSTBATCHES.posting_batch_rec_type;
   l_profile_value          VARCHAR2(1);

   CURSOR get_comm_line_rec IS
        (SELECT    CN_API.G_MISS_ID                  payment_transaction_id,
                  CN_PREPOSTBATCHES.G_BATCH_ID      posting_batch_id,
                  --C_EXPENSE                         posting_type,

                  cl.credited_salesrep_id,
		          cl.credited_salesrep_id payee_salesrep_id,
                  cl.quota_id,
                  cl.pay_period_id,
                  pe.incentive_type_code,
                  cl.credit_type_id,
                  NULL, -- payrun_id
                  nvl(cl.commission_amount,0)       amount,
                  nvl(cl.commission_amount,0)        payment_amount, -- default
                  'N'                                hold_flag, -- default N
 	              'N'                                paid_flag, -- default N
                  'N'                                waive_flag, -- default N
                  'N'                                recoverable_flag, -- default N
                  cl.commission_header_id,
                  cl.commission_line_id,
                  null, -- pay_element_type_id
                  cl.srp_plan_assign_id,
                  cl.processed_date,
                  cl.processed_period_id,
                  cl.quota_rule_id,
                  cl.event_factor,
                  cl.payment_factor,
                  cl.quota_factor,
                  cl.input_achieved,
                  cl.rate_tier_id,
                  cl.payee_line_id,
                  cl.commission_rate,
                  cl.trx_type,
                  cl.role_id,
                  pe.expense_account_id    expense_ccid,
                  pe.liability_account_id    liability_ccid,
                  NULL, --cl.attribute_category,
                  NULL, --cl.attribute1,
                  null, --cl.attribute2,
                  null, --cl.attribute3,
                  null, --cl.attribute4,
                  null, --cl.attribute5,
                  null, --cl.attribute6,
                  null, --cl.attribute7,
                  null, --cl.attribute8,
                  null, --cl.attribute9,
                  null, --cl.attribute10,
                  null, --cl.attribute11,
                  null, --cl.attribute12,
                  null, --cl.attribute13,
                  null, --cl.attribute14,
                  null, --cl.attribute15
                  cl.org_id,
				  0


                  /*C_UNLOADED                        status,  --default UNLOADED
                  FND_API.G_MISS_DATE               loaded_date,
                  cl.pending_status,
                  cl.status                          cl_status,
                  cl.created_during,
                  FND_GLOBAL.USER_ID                created_by,
                  SYSDATE                           creation_date,
                  FND_GLOBAL.LOGIN_ID               last_update_login,
                  SYSDATE                           last_update_date,
                  FND_GLOBAL.USER_ID                last_updated_by*/
        FROM      cn_commission_lines_all cl,
                  -- cn_srp_plan_assigns srcp,
                  --cn_srp_payee_assigns srpa, removed for payee assigns bug #2495614
                  -- cn_role_plans rcp,
                  cn_quotas_all  pe
        WHERE     cl.commission_line_id = p_commission_line_id
        AND       cl.quota_id = pe.quota_id
        AND	      cl.srp_payee_assign_id IS NULL)
        UNION     --this is added for assign payees for fixing bug#2495614
        (SELECT    CN_API.G_MISS_ID                  payment_transaction_id,
                  CN_PREPOSTBATCHES.G_BATCH_ID      posting_batch_id,
                  payee.payee_id credited_salesrep_id,
                  payee.payee_id payee_salesrep_id,
                  cl.quota_id,
                  cl.pay_period_id,
                  pe.incentive_type_code,
                  cl.credit_type_id,
                  NULL, -- payrun_id
                  nvl(cl.commission_amount,0)       amount,
                  nvl(cl.commission_amount,0)        payment_amount, -- default
                  'N'                                hold_flag, -- default N
 	              'N'                                paid_flag, -- default N
                  'N'                                waive_flag, -- default N
                  'N'                                recoverable_flag, -- default N
                  cl.commission_header_id,
                  cl.commission_line_id,
                  null, -- pay_element_type_id
                  cl.srp_plan_assign_id,
                  cl.processed_date,
                  cl.processed_period_id,
                  cl.quota_rule_id,
                  cl.event_factor,
                  cl.payment_factor,
                  cl.quota_factor,
                  cl.input_achieved,
                  cl.rate_tier_id,
                  cl.payee_line_id,
                  cl.commission_rate,
                  cl.trx_type,
                  54,--cl.role_id
                  pe.expense_account_id    expense_ccid,
                  pe.liability_account_id    liability_ccid,
                  NULL, --cl.attribute_category,
                  NULL, --cl.attribute1,
                  null, --cl.attribute2,
                  null, --cl.attribute3,
                  null, --cl.attribute4,
                  null, --cl.attribute5,
                  null, --cl.attribute6,
                  null, --cl.attribute7,
                  null, --cl.attribute8,
                  null, --cl.attribute9,
                  null, --cl.attribute10,
                  null, --cl.attribute11,
                  null, --cl.attribute12,
                  null, --cl.attribute13,
                  null, --cl.attribute14,
                  null, --cl.attribute15
                  cl.org_id,
                  0
        FROM      cn_commission_lines_all cl,
                  -- cn_srp_plan_assigns srcp,
                  cn_srp_payee_assigns_all payee,
                  -- cn_role_plans rcp,
                  cn_quotas_all pe
        WHERE     cl.commission_line_id = p_commission_line_id
        AND       cl.quota_id = pe.quota_id
        AND	  cl.srp_payee_assign_id IS NOT NULL
        AND	  payee.srp_payee_assign_id = cl.srp_payee_assign_id);


--      AND       cl.srp_plan_assign_id = srcp.srp_plan_assign_id
--	  AND     cl.srp_payee_assign_id = srpa.srp_payee_assign_id (+) removed for bug #2495614
--	  AND     srcp.role_id = cl.role_id
--	  AND     srcp.salesrep_id = cl.credited_salesrep_id
--	  AND     cl.processed_date BETWEEN srcp.start_date AND Nvl(srcp.end_date, cl.processed_date)
--        AND            srcp.role_plan_id = rcp.role_plan_id (+)

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT      Create_From_CommLine;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version              ,
                                           p_api_version              ,
                                           l_api_name                 ,
                                           G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_loading_status := 'CN_INSERTED';

      -- API body
      -- Validate incoming parameters

   l_profile_value := fnd_profile.value('CN_PAY_BY_TRANSACTION');

   If l_profile_value = 'Y' THEN


     IF l_posting_batch_rec.posting_batch_id IS NULL THEN
	-- Initialize batch is necessary since the batch ID is null
	Initialize_Batch
	  (p_api_version          => p_api_version,
	   p_init_msg_list        => p_init_msg_list,
	   p_commit               => p_commit,
	   p_validation_level     => p_validation_level,
	   x_return_status        => x_return_status,
	   x_msg_count            => x_msg_count,
	   x_msg_data             => x_msg_data,
	   x_loading_status       => l_loading_status,
	   p_loading_status       => l_loading_status,
	   p_posting_batch_rec    => l_posting_batch_rec,
	   x_status               => l_status
	   );
	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
     END IF;

     -- Build Payment Record record from Commission Line
     OPEN get_comm_line_rec;
     FETCH get_comm_line_rec INTO l_pmt_trans_rec;
     --dbms_output.put_line('after fetch, status is '||l_status);
     IF get_comm_line_rec%ROWCOUNT <> 1 THEN
	FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_COMMISSION_LINE');
	FND_MESSAGE.SET_TOKEN('COMMISSION_LINE_ID',
			      TO_CHAR(p_commission_line_id));
	FND_MSG_PUB.ADD;
	l_loading_status := 'CN_INVALID_COMMISSION_LINE';
	l_status := l_loading_status;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE get_comm_line_rec;

     -- Calculate a negative amount for revert transactions

     IF p_create_mode = 'REVERT' THEN
	l_pmt_trans_rec.amount := l_pmt_trans_rec.amount * -1;
	l_pmt_trans_rec.payment_amount := 0 - l_pmt_trans_rec.payment_amount;
     END IF;

     -- if nothing changes, delete the reversal created before this run of posting process
     -- clku, 5/13/2002, commented this part out because the create_payment_worksheet method
     -- takes care of deleting and creating NEW Payment Transaction already.

     /*IF (p_create_mode = 'NEW') THEN
	DELETE FROM cn_pmt_trans
	  WHERE posting_type = l_pmt_trans_rec.posting_type
	  AND payee_salesrep_id = l_pmt_trans_rec.payee_salesrep_id
	  AND role_id = l_pmt_trans_rec.role_id
	  AND credit_type_id = l_pmt_trans_rec.credit_type_id
	  AND pay_period_id = l_pmt_trans_rec.pay_period_id
	  AND amount = (0 - l_pmt_trans_rec.amount)
	  AND commission_header_id = l_pmt_trans_rec.commission_header_id
	  AND srp_plan_assign_id = l_pmt_trans_rec.srp_plan_assign_id
	  AND quota_id = l_pmt_trans_rec.quota_id
	  AND status = l_pmt_trans_rec.status
	  AND credited_salesrep_id = l_pmt_trans_rec.credited_salesrep_id
	  AND paid_flag = l_pmt_trans_rec.paid_flag
	  AND ROWNUM = 1;

	-- if something changes, keep the reversal and create a new posting line
	IF (SQL%notfound) THEN
	CN_PMT_TRANS_PKG.Begin_Record
	  (x_pmt_trans_rec       => l_pmt_trans_rec);
	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END IF;
      ELSE*/

    -- insert record into CN_PAYMENT_TRANSACTIONS
	CN_PMT_TRANS_PKG.Insert_Record(l_pmt_trans_rec);
	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
     --END IF;

     -- if NEW then Update commission line posting status to POSTED
   /*  IF p_create_mode = 'NEW' THEN
        UPDATE      cn_commission_lines
        SET         posting_status = C_POSTED
        WHERE       commission_line_id = p_commission_line_id;*/
--        REMOVE COMMENT WHEN UPDATED WITH COMM LINE API
--        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          RAISE FND_API.G_EXC_ERROR;
--        END IF;
      -- if REVERT then Update commission line posting status to REVERTED
      IF p_create_mode = 'REVERT' THEN
        UPDATE      cn_commission_lines_all
        SET         posting_status     = C_REVERTED
        WHERE       commission_line_id = p_commission_line_id;
      END IF;
    END IF;
      -- End of API body.
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info
      FND_MSG_PUB.Count_And_Get
	(        p_count               =>      x_msg_count           ,
		 p_data                =>      x_msg_data
         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      --dbms_output.put_line('EXP '||sqlerrm);
      ROLLBACK TO Create_From_CommLine;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(        p_count               =>      x_msg_count           ,
		 p_data                =>      x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --dbms_output.put_line('UNEXP '||sqlerrm);
      ROLLBACK TO Create_From_CommLine;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(        p_count               =>      x_msg_count           ,
		 p_data                =>      x_msg_data
	);
   WHEN OTHERS THEN
      --dbms_output.put_line('OTHERS '||sqlerrm);
      ROLLBACK TO Create_From_CommLine;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (      G_PKG_NAME            ,
		  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(        p_count               =>      x_msg_count           ,
		 p_data                =>      x_msg_data
	);
END Create_From_CommLine;


-- ============================================================================
--  Procedure       : Create_PrePostDetails
--  Description     : This PUBLIC procedure creates posting trx from a table of
--                    posting details.
--                    Specifically it is used to create posting details derived
--                    from a single "paid" payment worksheet e.g., called by
--                    PrePost_PayWorksheets().
--                    These posting details are not derived from commission
--                    lines. The source of posting is a posting_detail_rec_tbl.
--                    Assumes batch has already been created.
--  Calls           : Get_Batch_ID()
--                    Validate_PrePostDetails()
--                    CN_PREPOSTDETAILS.Begin_Record()
--  Note            : This procedure assumes that CN_PREPOSTBATCHES.G_BATCH_ID
--                    has already been set via the Initialize_Batch()
--                    public procedure.
-- ============================================================================
PROCEDURE Create_PrePostDetails
(     p_api_version             IN       NUMBER                        ,
      p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                  IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level        IN       NUMBER      :=
                                    FND_API.G_VALID_LEVEL_FULL      ,
      x_return_status           OUT NOCOPY      VARCHAR2                   ,
      x_msg_count               OUT NOCOPY      NUMBER                     ,
      x_msg_data                OUT NOCOPY      VARCHAR2                   ,
      p_posting_detail_rec_tbl  IN OUT NOCOPY   CN_PREPOSTDETAILS.posting_detail_rec_tbl_type
)
IS
      l_api_name                CONSTANT VARCHAR2(30)      := 'Create_PrePostDetails';
      l_api_version             CONSTANT NUMBER            := 1.0;
      l_loading_status                   VARCHAR2(30);
      l_status                           VARCHAR2(30);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT      Create_PrePostDetails;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (       l_api_version              ,
                                                   p_api_version              ,
                                             l_api_name                       ,
                                                    G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_loading_status := 'CN_INSERTED';
      -- API body
      -- Process a set of posting details
      FOR i IN 1 .. p_posting_detail_rec_tbl.COUNT LOOP
         SAVEPOINT Create_PayWorksheets_Loop;
         -- Validate incoming parameters
         /*Validate_PrePostDetails(
             x_return_status           => x_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data,
             p_loading_status          => l_loading_status,
             x_loading_status          => l_loading_status,
             p_posting_detail_rec      => p_posting_detail_rec_tbl(i),
             x_status                  => l_status
             );
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;*/

         -- Create Posting Detail through table handlers
         CN_PREPOSTDETAILS.Begin_Record(
           x_operation                => 'INSERT',
           x_rowid                    => G_ROWID,
           x_posting_detail_rec       => p_posting_detail_rec_tbl(i),
           x_program_type             => G_PROGRAM_TYPE
           );
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         l_status := 'CREATED POSTING DETAIL '||TO_CHAR(i);
      END LOOP;
      -- End of API body.
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
          (   p_count               =>      x_msg_count           ,
              p_data                =>      x_msg_data
          );
EXCEPTION  --create posting detail
      WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Create_PrePostDetails_Loop;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                 );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Create_PrePostDetails;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                          );
      WHEN OTHERS THEN
            ROLLBACK TO Create_PrePostDetails;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg
                   (      G_PKG_NAME            ,
                          l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get
                   (        p_count               =>      x_msg_count         ,
                            p_data                =>      x_msg_data
                            );
END Create_PrePostDetails;

-- ============================================================================
--  Procedure        : PrePost_PayWorksheets
--  Description      : This PUBLIC procedure creates processes the posting of
--                     all "paid" worksheets between a posting batch date range
--  Calls            : Create_PrePostDetails()
-- ============================================================================
PROCEDURE PrePost_PayWorksheets
(     p_api_version             IN       NUMBER                        ,
      p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                  IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level        IN       NUMBER      :=
                                    FND_API.G_VALID_LEVEL_FULL      ,
      x_return_status           OUT NOCOPY      VARCHAR2                    ,
      x_msg_count               OUT NOCOPY      NUMBER                      ,
      x_msg_data                OUT NOCOPY      VARCHAR2
)
IS
      l_api_name                CONSTANT VARCHAR2(30)      := 'PrePost_PayWorksheets';
      l_api_version             CONSTANT NUMBER            := 1.0;
      l_loading_status                   VARCHAR2(30);
      l_status                           VARCHAR2(30);
      l_pdet_rec_tbl                     CN_PREPOSTDETAILS.posting_detail_rec_tbl_type;
      l_tbl_empty                        CN_PREPOSTDETAILS.posting_detail_rec_tbl_type;
      i                                  NUMBER;

      -- Unposted worksheets belonging to PAID payruns are retrieved by
      -- posting batch start and end dates.

      CURSOR get_pay_ws IS
         SELECT ws.PAYMENT_WORKSHEET_ID   ,
  --              ws.PAYRUN_ID              ,
                ws.SALESREP_ID            , -- payee_salesrep_id
                ws.ROLE_ID                ,
                ws.CREDIT_TYPE_ID         ,
                pr.PAY_DATE               , -- posted_date
                pr.PAY_PERIOD_ID          ,
                ws.COMM_NREC              COMM_NREC,
                ws.DRAW_PAID              COMM_REC, -- comm rec
                ws.COMM_DRAW              COMM_TO_REC, -- to recov w pp
                ws.REG_BONUS_REC          BONUS_REC,
                ws.REG_BONUS_TO_REC       BONUS_TO_REC
--                ws.POSTING_STATUS
           FROM cn_payment_worksheets ws,
                cn_payruns pr,
                cn_posting_batches pb,
                cn_period_statuses pp
          WHERE pr.payrun_id = ws.payrun_id
            and pr.pay_period_id = pp.period_id
            AND pp.start_date BETWEEN pb.start_date AND pb.end_date
          AND ( pr.status = 'PAID'
             OR pr.status = 'PAID_WITH_RETURNS')
            AND ws.posting_status = C_UNPOSTED
            AND pb.load_status = C_UNLOADED
            AND pb.posting_batch_id = CN_PREPOSTBATCHES.G_BATCH_ID;

      --Manual Expense cursor declaration
      CURSOR get_ws_manual_exp ( v_payment_worksheet_id IN NUMBER ) IS
         SELECT wsb.quota_id           ,
                wsb.srp_plan_assign_id ,
                wsb.amount
           FROM cn_worksheet_bonuses wsb
          WHERE wsb.payment_worksheet_id = v_payment_worksheet_id;

      -- Cursor used to pick up payruns and update their posting statuses STATUS to
      -- POSTED if all the corresponding payment worksheets are posted successfully
      cursor get_posted_payruns is
         select pr.payrun_id
           from cn_payruns pr,
                cn_period_statuses ps,
                cn_posting_batches pb
          where pr.pay_period_id = ps.period_id
          and (pr.status = 'PAID' or pr.status = 'PAID_WITH_RETURNS')
          and pb.load_status = C_UNLOADED
          and pb.posting_batch_id = CN_PREPOSTBATCHES.G_BATCH_ID
          and ps.start_date between pb.start_date and pb.end_date
          and not exists ( select 1
                             from cn_payment_worksheets ws
                            where ws.payrun_id = pr.payrun_id
                              and ws.posting_status = C_UNPOSTED
                          );
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT      PrePost_PayWorksheets;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version              ,
                                           p_api_version              ,
                                           l_api_name                 ,
                                           G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- API body

      -- Validate a CN_PREPOSTBATCHES.G_BATCH_ID exists
      -- The assumption is that the batch already exists and with parameters
      -- to drive posting.

      IF CN_PREPOSTBATCHES.G_BATCH_ID is NULL THEN
         FND_MESSAGE.SET_NAME('CN', 'CN_POSTING_BATCH_UNINITIALIZED');
         --FND_MESSAGE.SET_TOKEN('COMMISSION_LINE_ID', TO_CHAR(p_commission_line_id));
         FND_MSG_PUB.ADD;
         l_loading_status := 'CN_POSTING_BATCH_UNINITIALIZED';
         l_status := 'EARLY EXIT BECAUSE POSTING BATCH NOT INITIALIZED';
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Get payment worksheets eligible for posting
      -- OPEN  get_pay_ws;
      FOR l_pay_ws_rec IN get_pay_ws LOOP
         --dbms_output.put_line('Loop depth '||i);
         SAVEPOINT PrePost_PayWorksheets_Loop;
         l_pdet_rec_tbl := l_tbl_empty;
         l_loading_status := 'CN_INSERTED';  -- Set worksheet as properly inserted
         i := 1;
         -- ===================================================================
         -- Payment worksheets have 6 types of posting transactions which may
         -- be derived outside of commission lines.These include the following:
         --         COMMISSION Incentive Type
         -- 1.  COMM NRec (Adjust to Pay)
         -- 2.  COMM Rec (only commission incentive types have PPs)
         -- 3.  COMM To Recover
         --         BONUS Incentive Type
         -- 4.  BONUS Rec
         -- 5.  BONUS To Recover (will recover from comm if possible)
         --         MANUAL Incentive Type
         -- 6.  MANUAL Expense e.g., Earned and should not be categorized as
         --                          "NRec" in the worksheet
         --            (e.g., Manual incentive type from CN_WORKSHEET_BONUSES
         --              thru a join from CN_WORKSHEETS)
         -- Identify each posting trx type from the many buckets in the worksheet
         -- and loop thru build posting details to match and committing a
         -- worksheet at a time.
         -- ===================================================================
         -- 1.  COMM NRec (Adjust to Pay)
         IF l_pay_ws_rec.COMM_NREC <> 0 THEN
            l_pdet_rec_tbl(i).posting_type          := C_NON_REC;
            l_pdet_rec_tbl(i).trx_type              := C_COMM_NREC;
            l_pdet_rec_tbl(i).incentive_type_code   := C_COMMISSION;
            l_pdet_rec_tbl(i).amount                := l_pay_ws_rec.COMM_NREC;
            l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
            l_pdet_rec_tbl(i).status                := C_UNLOADED;
            l_pdet_rec_tbl(i).loaded_date           := NULL;
            l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
            l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
            l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
            l_pdet_rec_tbl(i).creation_date         := SYSDATE;
            l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
            l_status := 'COMM Non Rec '||TO_CHAR(i)||' built';
            i := i + 1;
         END IF;

         -- 2.  COMM Rec (only commission incentive types have PPs)

         IF l_pay_ws_rec.COMM_REC <> 0 THEN
            l_pdet_rec_tbl(i).posting_type          := C_REC;
            l_pdet_rec_tbl(i).trx_type              := C_COMM_REC;
            l_pdet_rec_tbl(i).incentive_type_code   := C_COMMISSION;
            l_pdet_rec_tbl(i).amount                := l_pay_ws_rec.COMM_REC;
            l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
            l_pdet_rec_tbl(i).status                := C_UNLOADED;
            l_pdet_rec_tbl(i).loaded_date           := NULL;
            l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
            l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
            l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
            l_pdet_rec_tbl(i).creation_date         := SYSDATE;
            l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
            l_status := 'COMM Rec '||TO_CHAR(i)||' built';
            i := i + 1;
         END IF;

         -- 3.  COMM To Recover

         IF l_pay_ws_rec.COMM_TO_REC <> 0 THEN
            l_pdet_rec_tbl(i).posting_type          := C_TO_REC;
            l_pdet_rec_tbl(i).trx_type              := C_COMM_TO_REC;
            l_pdet_rec_tbl(i).incentive_type_code   := C_COMMISSION;
            l_pdet_rec_tbl(i).amount                := l_pay_ws_rec.COMM_TO_REC;
            l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
            l_pdet_rec_tbl(i).status                := C_UNLOADED;
            l_pdet_rec_tbl(i).loaded_date           := NULL;
            l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
            l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
            l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
            l_pdet_rec_tbl(i).creation_date         := SYSDATE;
            l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
            l_status := 'COMM To Recover '||TO_CHAR(i)||' built';
            i := i + 1;
         END IF;

         -- 4.  BONUS Rec

         IF l_pay_ws_rec.BONUS_REC <> 0 THEN
            l_pdet_rec_tbl(i).posting_type          := C_REC;
            l_pdet_rec_tbl(i).trx_type              := C_BONUS_REC;
            l_pdet_rec_tbl(i).incentive_type_code   := C_BONUS;
            l_pdet_rec_tbl(i).amount                := l_pay_ws_rec.BONUS_REC;
            l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
            l_pdet_rec_tbl(i).status                := C_UNLOADED;
            l_pdet_rec_tbl(i).loaded_date           := NULL;
            l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
            l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
            l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
            l_pdet_rec_tbl(i).creation_date         := SYSDATE;
            l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
            l_status := 'BONUS Rec '||TO_CHAR(i)||' built';
            i := i + 1;
         END IF;

         -- 5.  BONUS To Recover (will recover from comm if possible)

         IF l_pay_ws_rec.BONUS_TO_REC <> 0 THEN
            l_pdet_rec_tbl(i).posting_type          := C_TO_REC;
            l_pdet_rec_tbl(i).trx_type              := C_BONUS_TO_REC;
            l_pdet_rec_tbl(i).incentive_type_code   := C_BONUS;
            l_pdet_rec_tbl(i).amount                := l_pay_ws_rec.BONUS_TO_REC;
            l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
            l_pdet_rec_tbl(i).status                := C_UNLOADED;
            l_pdet_rec_tbl(i).loaded_date           := NULL;
            l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
            l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
            l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
            l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
            l_pdet_rec_tbl(i).creation_date         := SYSDATE;
            l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
            l_status := 'BONUS To Rec '||TO_CHAR(i)||' built';
            i := i + 1;
         END IF;

         -- 6.  MANUAL Expense e.g., Earned and should not be categorized as
         --                          "NRec" in the worksheet
         --            (e.g., Manual incentive type from CN_WORKSHEET_BONUSES
         --              thru a join from CN_WORKSHEETS)

         FOR l_manual_exp_rec IN get_ws_manual_exp(l_pay_ws_rec.payment_worksheet_id) LOOP
            IF l_manual_exp_rec.AMOUNT <> 0 THEN
               l_pdet_rec_tbl(i).posting_type          := C_EXPENSE;
               l_pdet_rec_tbl(i).trx_type              := C_MANUAL_EXPENSE;
               l_pdet_rec_tbl(i).incentive_type_code   := C_MANUAL;
               l_pdet_rec_tbl(i).amount                := l_manual_exp_rec.amount;
               l_pdet_rec_tbl(i).srp_plan_assign_id    := l_manual_exp_rec.srp_plan_assign_id;
               l_pdet_rec_tbl(i).quota_id              := l_manual_exp_rec.quota_id;
               l_pdet_rec_tbl(i).posting_batch_id      := CN_PREPOSTBATCHES.G_BATCH_ID;
               l_pdet_rec_tbl(i).status                := C_UNLOADED;
               l_pdet_rec_tbl(i).loaded_date           := NULL;
               l_pdet_rec_tbl(i).payee_salesrep_id     := l_pay_ws_rec.salesrep_id;
               l_pdet_rec_tbl(i).credited_salesrep_id  := l_pay_ws_rec.salesrep_id;
               l_pdet_rec_tbl(i).role_id               := l_pay_ws_rec.role_id;
               l_pdet_rec_tbl(i).credit_type_id        := l_pay_ws_rec.credit_type_id;
               l_pdet_rec_tbl(i).pay_period_id         := l_pay_ws_rec.pay_period_id;
               l_pdet_rec_tbl(i).creation_date         := SYSDATE;
               l_pdet_rec_tbl(i).created_by            := FND_GLOBAL.USER_ID;
               l_status := 'MANUAL Expense '||TO_CHAR(i)||' built';
               i := i + 1;
            END IF;
         END LOOP;

            -- Create Posting Detail through API
         Create_PrePostDetails(
               p_api_version              => p_api_version,
               p_init_msg_list            => p_init_msg_list,
               p_commit                   => p_commit,
               p_validation_level         => p_validation_level,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data,
               p_posting_detail_rec_tbl   => l_pdet_rec_tbl
               );
--dbms_output.put_line('It is here');
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_status := 'Error in creation of posting detail for worksheet';
            RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- Update posting status of POSTED worksheet
         -- Replace with table api

         --UPDATE cn_payment_worksheets
         --SET    posting_status = C_POSTED
         --WHERE  payment_worksheet_id = l_pay_ws_rec.payment_worksheet_id;

         cn_payment_worksheets_pkg.update_record
	   (
	    x_payment_worksheet_id => l_pay_ws_rec.payment_worksheet_id,
	    x_posting_status       => c_posted,
	    x_last_update_date     => SYSDATE,
	    x_last_updated_by      => FND_GLOBAL.USER_ID,
	    x_last_update_login    => FND_GLOBAL.LOGIN_ID);


         l_status := 'Posting Detail created for WS';

      END LOOP;      -- Get next payment worksheet

      -- Test if all worksheets of the payrun are posted and
      -- if so update the posting status of the pay run.
      -- You may want to make this independent of the l_pay_ws_rec loop
      -- and select pay runs based on the batch start and end dates.

      -- declare cursor to select from cn_payruns
      --   where pr.pay_period_id = pp.pay_period_id
      --   and   pp.start_date between pb.start_date and pb.end_date
      --   (DON'T FORGET TO MAKE SAME CHANGE FOR l_pay_ws_rec)

      -- declare cursor to count number of not posted worksheets

      -- for each payrun loop
      --   check # of not posted worksheets
      --   if 0 then
      --     update payrun's posting status
      --   end if
      -- end loop

      for l_posted_payrun in get_posted_payruns loop
         null;
         /*
         cn_payruns_pkg.update_record(x_payrun_id => l_posted_payrun.payrun_id,
                                      x_status => C_POSTED,
                                      x_last_updated_by => FND_GLOBAL.USER_ID,
                                      x_last_update_date => SYSDATE,
                                      x_last_update_login => FND_GLOBAL.LOGIN_ID);
         */
      end loop;

      -- End of API body.
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
          (   p_count               =>      x_msg_count           ,
              p_data                =>      x_msg_data
          );
EXCEPTION  -- post payws
      WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO PrePost_PayWorksheets;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                 );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO PrePost_PayWorksheets;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                 (        p_count               =>      x_msg_count           ,
                          p_data                =>      x_msg_data
                          );
      WHEN OTHERS THEN
            ROLLBACK TO PrePost_PayWorksheets;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg
                   (      G_PKG_NAME            ,
                          l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get
                   (        p_count               =>      x_msg_count           ,
                            p_data                =>      x_msg_data
                            );
END PrePost_PayWorksheets;
END CN_PREPOST_PVT;

/
