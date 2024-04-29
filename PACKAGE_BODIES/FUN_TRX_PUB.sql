--------------------------------------------------------
--  DDL for Package Body FUN_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_PUB" AS
/*  $Header: funtrxvalinsb.pls 120.20.12010000.6 2009/01/12 04:40:29 srampure ship $ */
G_PKG_NAME CONSTANT      VARCHAR2(30) := 'FUN_TRX_VAL_AND_INS';
G_DEBUG VARCHAR2(5);


PROCEDURE Print
        (
               P_string                IN      VARCHAR2
        ) IS


BEGIN

IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, p_string);

END IF;

EXCEPTION
  WHEN OTHERS THEN
  APP_EXCEPTION.RAISE_EXCEPTION;
END Print;

PROCEDURE Set_Return_Status
(       x_orig_status IN OUT NOCOPY VARCHAR2,
        p_new_status  IN VARCHAR2
) IS
BEGIN
          -- API body
          IF (x_orig_status = FND_API.G_RET_STS_SUCCESS
                AND p_new_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 x_orig_status := p_new_status;
          ELSIF (x_orig_status = FND_API.G_RET_STS_ERROR
                 AND p_new_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_orig_status := p_new_status;
          END IF;

          Print ( 'Val and Insert >>>> '|| 'Setting the status '|| x_orig_status);
          -- End of API body.
EXCEPTION
   WHEN OTHERS THEN
   Print('Set return status - Unexpected error ');
   APP_EXCEPTION.RAISE_EXCEPTION;
END Set_Return_Status;



FUNCTION insert_rejections(
        p_batch_id                      IN      NUMBER,
        p_trx_id                        IN      NUMBER default null,
        p_dist_id                       IN      NUMBER default null,
        p_batch_dist_id                 IN      NUMBER default null,
        p_reject_code                   IN      VARCHAR2 default null,
        p_reject_reason                 IN      VARCHAR2
) RETURN BOOLEAN IS

  debug_info                    VARCHAR2(500);

BEGIN

  debug_info := '(Insert Rejections 1) Insert into FUN_INTERFACE_REJECTIONS, REJECT REASON: '||p_reject_reason;
  Print('Insert Rejections >>'||debug_info);

  Print('Insert Rejections >>'||'Btc id:' || to_char(p_batch_id));
  Print('Insert Rejections >>'||'gl_date:' || to_char(p_reject_code));
  INSERT INTO FUN_INTERFACE_REJECTIONS (
        batch_id,
        trx_id,
        dist_id,
        batch_dist_id,
        reject_code,
        reject_reason
               )
  VALUES(
        p_batch_id,
        nvl(p_trx_id,null),
        nvl(p_dist_id,null),
        nvl(p_batch_dist_id,null),
        p_reject_code,
        p_reject_reason
  );
  Print('Insert Rejections >>'||'Sucessfully inserted into Rejections');
  RETURN(TRUE);

EXCEPTION
 WHEN OTHERS then
    Print('Insert Rejections >>'||'Insert into Rejections Table Failed');
    IF (SQLCODE < 0) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END insert_rejections;


Procedure CREATE_BATCH(
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 ,
        p_commit                IN VARCHAR2 ,
        p_validation_level      IN  NUMBER  ,
        p_debug             IN VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_sent                  IN VARCHAR2,
        p_calling_sequence      IN VARCHAR2,
        p_insert                IN VARCHAR2 ,
        p_batch_rec             IN OUT NOCOPY   FULL_BATCH_REC_TYPE,
        p_trx_tbl               IN OUT NOCOPY   FULL_TRX_TBL_TYPE,
        p_init_dist_tbl         IN OUT NOCOPY   FULL_INIT_DIST_TBL_TYPE,
        p_dist_lines_tbl        IN OUT NOCOPY   FULL_DIST_LINE_TBL_TYPE
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_BATCH';
l_api_version           CONSTANT NUMBER := 1.0;
l_batch_rec             FUN_TRX_PVT.BATCH_REC_TYPE;
l_trx_tbl               FUN_TRX_PVT.TRX_TBL_TYPE;
l_init_dist_tbl         FUN_TRX_PVT.INIT_DIST_TBL_TYPE;
l_dist_lines_tbl        FUN_TRX_PVT.DIST_LINE_TBL_TYPE;
l_trx_rec_type          FUN_TRX_PVT.TRX_REC_TYPE;

l_init_dist_rec_type    FUN_TRX_PVT.INIT_DIST_REC_TYPE;

l_dist_lines_rec_type   FUN_TRX_PVT.DIST_LINE_REC_TYPE;

l_count                 NUMBER;  -- Index for trx_tbl
l_count_lines           NUMBER;  -- Index for dist_lines_tbl

l_return_status         varchar2(1);
-- Bug 7340636 Increased the size of l_msg_data from 80 to 2000.
l_msg_data              varchar2(2000);
l_msg_count             number;
l_msg                   varchar2(2000);
l_app                   varchar2(10);

	l_old_batch_rec         FULL_BATCH_REC_TYPE;
	l_old_trx_tbl           FULL_TRX_TBL_TYPE;
	l_old_init_dist_tbl     FULL_INIT_DIST_TBL_TYPE;
	l_old_dist_lines_tbl    FULL_DIST_LINE_TBL_TYPE;

	l_init_msg_list         VARCHAR2(1);

	l_seq_version_id                number;
	l_sequence_number               number;
	l_assignment_id                 number;
	l_error_code                    varchar2(15);

	l_user                          number;
	l_login                         number;
	l_wfkey			varchar2(1000);
	l_batch_id			number;
	l_trx_id			number;
        l_unique_batch_id               NUMBER;
	l_to_ledger_id                  NUMBER; -- Bug: 7695801

        -- 25-10-2007 MAKANSAL
        -- For Bug # 6527666 Introduced to keep the recipient party id and recipient legal entity id
        l_le_party_id Xle_Firstparty_Information_V.party_id%type;
        l_to_le_id GL_LEDGER_LE_BSV_SPECIFIC_V.LEGAL_ENTITY_ID%type;

        -- 25-10-2007 MAKANSAL
        -- For Bug # 6527666 Introduced the Cursor to fetch the Recipient Legal Entity Id
        Cursor C_Le_Id(cp_le_party_id In Xle_Entity_Profiles.party_id%type) Is
      	  Select legal_entity_id
      	  From Xle_Firstparty_Information_V
      	  Where party_id = cp_le_party_id;

	  BEGIN

	  -- Set the debug flag
	  G_DEBUG := p_debug;

	  Print('Val and Insert >>>>'||'Start of the API');
	  -- Storing Initial Values
	  l_old_batch_rec               := p_batch_rec;
	  l_old_trx_tbl         := p_trx_tbl;
	  l_old_init_dist_tbl   := p_init_dist_tbl;
	  l_old_dist_lines_tbl  := p_dist_lines_tbl;
	  -- Standard Start of API savepoint

	  SAVEPOINT             Fun_Trx_Val_And_Insert_PUB;

	  Print('Val and Insert >>>>'||'API Compatibilty Check');
	  -- Standard Call to check for API compatibility
	  IF NOT FND_API.Compatible_API_Call (l_api_version,
					      p_api_version,
					      l_api_name,
					      G_PKG_NAME)
	  THEN
	    Print('Val and Insert >>>>'||'Non compatible API call');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
	  -- Initialize API return status to success
	  x_return_status := FND_API.G_RET_STS_SUCCESS;

	  -- Initialize message list if p_init_msg_list is set to TRUE.
	  IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
		FND_MSG_PUB.initialize;
	  END IF;

	  /*Initialize the Stack of the Validation API's when calling_sequence is Intercompany Imort Programs*/
	  If (p_calling_sequence = 'Intercompany Import Program') then
		l_init_msg_list                   :=       FND_API.G_TRUE;
	  else
		l_init_msg_list                   :=       FND_API.G_FALSE;
  End If;

  Print('Val and Insert >>>>'||'Populating Parameters to be sent to Batch Validation API');
  Print('Val and Insert >>>>'||'Value of message list '||l_init_msg_list);
  --Populate the Parameters to be sent to Init_Batch_Validate
        l_batch_rec.batch_id                    := p_batch_rec.batch_id;
        l_batch_rec.batch_number                := p_batch_rec.batch_number;
        l_batch_rec.initiator_id                := p_batch_rec.initiator_id;
        l_batch_rec.from_le_id                  := p_batch_rec.from_le_id;
        l_batch_rec.from_ledger_id              := p_batch_rec.from_ledger_id;
        l_batch_rec.control_total               := p_batch_rec.control_total;
        l_batch_rec.currency_code               := p_batch_rec.currency_code;
        l_batch_rec.exchange_rate_type          := p_batch_rec.exchange_rate_type;
        l_batch_rec.status                      := p_batch_rec.status;
        l_batch_rec.description                 := p_batch_rec.description;
        l_batch_rec.trx_type_id                 := p_batch_rec.trx_type_id;
        l_batch_rec.trx_type_code               := p_batch_rec.trx_type_code;
        l_batch_rec.gl_date                     := p_batch_rec.gl_date;
        l_batch_rec.batch_date                  := p_batch_rec.batch_date;
        l_batch_rec.reject_allowed              := p_batch_rec.reject_allow_flag;
        l_batch_rec.from_recurring_batch        := p_batch_rec.from_recurring_batch_id;
        l_batch_rec.automatic_proration_flag    := 'N';


  Print('Val and Insert >>>>'||'Population of Trx_Tbl');

  l_count := 1;

  -- Populate l_trx_tbl, l_init_dist_tbl, l_dist_lines_tbl;
  for l_head_count in 1..p_trx_tbl.count
  LOOP
    l_trx_tbl(l_count).trx_id               := p_trx_tbl(l_head_count).trx_id;
    l_trx_tbl(l_count).trx_number           := p_trx_tbl(l_head_count).trx_number;
    l_trx_tbl(l_count).initiator_id       := p_trx_tbl(l_head_count).initiator_id;
    l_trx_tbl(l_count).recipient_id      := p_trx_tbl(l_head_count).recipient_id;
    l_trx_tbl(l_count).to_le_id            := p_trx_tbl(l_head_count).to_le_id;
    l_trx_tbl(l_count).to_ledger_id     := p_trx_tbl(l_head_count).to_ledger_id;
    l_trx_tbl(l_count).batch_id            := p_trx_tbl(l_head_count).batch_id;
    l_trx_tbl(l_count).status                 := p_trx_tbl(l_head_count).status;
    l_trx_tbl(l_count).init_amount_cr  := p_trx_tbl(l_head_count).init_amount_cr;
    l_trx_tbl(l_count).init_amount_dr  := p_trx_tbl(l_head_count).init_amount_dr;
    l_trx_tbl(l_count).reci_amount_cr  := p_trx_tbl(l_head_count).reci_amount_cr;
    l_trx_tbl(l_count).reci_amount_dr  := p_trx_tbl(l_head_count).reci_amount_dr;
    l_trx_tbl(l_count).invoicing_rule    := p_trx_tbl(l_head_count).invoice_flag;
    l_trx_tbl(l_count).approver_id        := p_trx_tbl(l_head_count).approver_id;
    l_trx_tbl(l_count).approval_date    := p_trx_tbl(l_head_count).approval_date;
    l_trx_tbl(l_count).original_trx_id   := p_trx_tbl(l_head_count).original_trx_id;
    l_trx_tbl(l_count).reversed_trx_id   := p_trx_tbl(l_head_count).reversed_trx_id;
    l_trx_tbl(l_count).from_recurring_trx_id   :=
                        p_trx_tbl(l_head_count).from_recurring_trx_id;
    l_trx_tbl(l_count).initiator_instance   := p_trx_tbl(l_head_count).initiator_instance_flag;
    l_trx_tbl(l_count).recipient_instance := p_trx_tbl(l_head_count).recipient_instance_flag;

    l_count := l_count+1;


  END LOOP;

  l_count_lines := 1;

  Print('Val and Insert >>>>'||'Populate Batch Dist');

  If p_init_dist_tbl is not null then
  Print('Val and Insert >>>>'||'BATCH DIST TBL NOT NULL '||P_INIT_dist_tbl.COUNT);
  for l_line_count in 1..p_init_dist_tbl.count
  LOOP
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).batch_dist_id);
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).line_number);
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).batch_id);
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).ccid);
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).amount_cr);
   Print('Val and Insert >>>>'||p_init_dist_tbl(l_line_count).amount_Dr);
   l_init_dist_tbl(l_count_lines).batch_dist_id        :=
                p_init_dist_tbl(l_line_count).batch_dist_id;
   l_init_dist_tbl(l_count_lines).line_number          :=
                p_init_dist_tbl(l_line_count).line_number;
   l_init_dist_tbl(l_count_lines).batch_id               :=
                p_init_dist_tbl(l_line_count).batch_id;
   l_init_dist_tbl(l_count_lines).ccid                        :=
                p_init_dist_tbl(l_line_count).ccid;
   l_init_dist_tbl(l_count_lines).amount_cr      :=
                p_init_dist_tbl(l_line_count).amount_cr;
   l_init_dist_tbl(l_count_lines).amount_dr      :=
                p_init_dist_tbl(l_line_count).amount_dr;

   l_count_lines := l_count_lines  + 1;
  END LOOP;
  End If;

  Print('Val and Insert >>>>'||'Dist Lines Tbl');

  l_count_lines := 1;

  If p_dist_lines_tbl is not null then
  Print('Val and Insert >>>>'||'Dist lines not null');
  for l_line_count in 1..p_dist_lines_tbl.count
  LOOP
   Print('Val and Insert >>>>'||'Record Details for '||l_line_count);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).trx_id);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).dist_id);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).line_id);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).party_id);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).party_type_flag);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).dist_type_flag);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).batch_dist_id);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).amount_cr);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).amount_dr);
   Print('Val and Insert >>>>'||p_dist_lines_tbl(l_line_count).ccid); --Bug 3603338
   Print('Val and Insert >>>>'|| 'End of Record Details');

        l_dist_lines_tbl(l_count_lines).trx_id           :=
                p_dist_lines_tbl(l_line_count).trx_id;
        l_dist_lines_tbl(l_count_lines).dist_id          :=
                p_dist_lines_tbl(l_line_count).dist_id;
        l_dist_lines_tbl(l_count_lines).line_id          :=
                p_dist_lines_tbl(l_line_count).line_id;
        l_dist_lines_tbl(l_count_lines).party_id         :=
                p_dist_lines_tbl(l_line_count).party_id;
        l_dist_lines_tbl(l_count_lines).party_type       :=
                p_dist_lines_tbl(l_line_count).party_type_flag;
        l_dist_lines_tbl(l_count_lines).dist_type        :=
                p_dist_lines_tbl(l_line_count).dist_type_flag;
        l_dist_lines_tbl(l_count_lines).batch_dist_id    :=
                p_dist_lines_tbl(l_line_count).batch_dist_id;
        l_dist_lines_tbl(l_count_lines).amount_cr        :=
                p_dist_lines_tbl(l_line_count).amount_cr;
        l_dist_lines_tbl(l_count_lines).amount_dr        :=
                p_dist_lines_tbl(l_line_count).amount_dr;
        l_dist_lines_tbl(l_count_lines).ccid             :=
                p_dist_lines_tbl(l_line_count).ccid;--Bug 3603338

        l_count_lines := l_count_lines  + 1;

   END LOOP;
  End if;

  Print('Val and Insert >>>>'||'Validating the Batch');

 IF (p_calling_sequence = 'Intercompany Import Program') then
        Print('Val and Insert >>>>'||'Validating Batch Id');
      BEGIN
        SELECT batch_id INTO l_unique_batch_id
        FROM fun_trx_batches
        WHERE batch_id=l_batch_rec.batch_id;
        -- IF batch_id exist
        l_return_status :=FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_DUPLICATE_BATCH_ID');
            FND_MESSAGE.SET_TOKEN('BATCH_ID',l_batch_rec.batch_id);
            l_msg := FND_Message.Get;
            IF (insert_rejections(p_batch_id          => l_batch_rec.batch_id,
                                  p_reject_reason          => l_msg) <> TRUE)  THEN
                Print('Val and Insert >>>>'||'insert_rejections of invalid batches failure');
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;
      EXCEPTION
      WHEN no_data_found THEN
          Print('Val and Insert >>>>'||'Batch Id is unique');
          l_return_status:=FND_API.G_RET_STS_SUCCESS;
      END;
  END IF;

 IF (l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN   --batch validation
      FUN_TRX_PVT.Init_Batch_Validate(
                p_api_version              =>   1.0,
                p_init_msg_list            =>   l_init_msg_list,
                p_validation_level         =>   nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL),
                x_return_status            =>   l_return_status,
                x_msg_count                =>   l_msg_count,
                x_msg_data                 =>   l_msg,
                p_insert                   =>   nvl(p_insert,FND_API.G_TRUE),
                p_batch_rec                =>   l_batch_rec,
                p_trx_tbl                  =>   l_trx_tbl,
                p_init_dist_tbl            =>   l_init_dist_tbl,
                p_dist_lines_tbl           =>   l_dist_lines_tbl
          );
    Print('Val and Insert >>>>'||'Batch Validation Complete'|| l_return_status|| 'message'||l_msg);

  /* Insert into Rejections Table with all the reason of error */
  If (l_return_status = FND_API.G_RET_STS_ERROR) then
   If (p_calling_sequence = 'Intercompany Import Program') then
       IF l_msg_count >= 1 THEN
          FOR i IN 1..l_msg_count
          LOOP
                l_msg   :=      FND_MSG_PUB.Get( p_msg_index => l_msg_count,
                                                 p_encoded => FND_API.G_FALSE);
                If (insert_rejections(
                                p_batch_id          => l_batch_rec.batch_id,
                                p_reject_reason          => l_msg
                                ) <> TRUE)
                        then
                    Print('Val and Insert >>>>'||'insert_rejections of invalid batches failure');
                              raise fnd_api.g_exc_unexpected_error;
                End if;         -- Insert Rejections
          END LOOP;  --msg count
       END IF;  -- l_msg_count > 1
    End if;  -- calling sequence
  End if; -- l_return_status

 END IF;  --batch validaion

  /* Set x_return_status according to l_return_status */
  Set_Return_Status(x_orig_status => x_return_status,
                  p_new_status  => l_return_status
                  );


  /* If l_return_status is Unexpected - Raise Unexpected Error*/

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        Print ('Val and Insert >>>> '|| 'Unexpected error after batch val');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Flush the  l_trx_tbl, l_init_dist_tbl, l_dist_lines_tbl tables

  l_trx_tbl.delete;
  l_init_dist_tbl.delete;
  l_dist_lines_tbl.delete;

  Print('Val and Insert >>>>'||'Populating Parameters to be sent to Trx Header Validation API');
  -- Population the Parameters to be sent with Init_Trx_Validate
  Print('Val and Insert >>>>'||p_trx_tbl.count);
  for l_head_count in 1..p_trx_tbl.count
  LOOP
  Print('Val and Insert >>>>'||'Populating trx_rec_type');
        l_trx_rec_type.trx_id                   := p_trx_tbl(l_head_count).trx_id;
        l_trx_rec_type.trx_number               := p_trx_tbl(l_head_count).trx_number;
        l_trx_rec_type.Initiator_id             := p_trx_tbl(l_head_count).Initiator_id;
        l_trx_rec_type.recipient_id             := p_trx_tbl(l_head_count).recipient_id;
        l_trx_rec_type.to_le_id                 := p_trx_tbl(l_head_count).to_le_id;
        l_trx_rec_type.to_ledger_id             := p_trx_tbl(l_head_count).to_ledger_id;
        l_trx_rec_type.batch_id                 := p_trx_tbl(l_head_count).batch_id;
        l_trx_rec_type.status                   := p_trx_tbl(l_head_count).status;
        l_trx_rec_type.init_amount_cr           := p_trx_tbl(l_head_count).init_amount_cr;
        l_trx_rec_type.init_amount_dr           := p_trx_tbl(l_head_count).init_amount_dr;
        l_trx_rec_type.reci_amount_cr           := p_trx_tbl(l_head_count).reci_amount_cr;
        l_trx_rec_type.reci_amount_dr           := p_trx_tbl(l_head_count).reci_amount_dr;
        l_trx_rec_type.invoicing_rule           := p_trx_tbl(l_head_count).invoice_flag;
        l_trx_rec_type.approver_id              := p_trx_tbl(l_head_count).approver_id;
        l_trx_rec_type.approval_date            := p_trx_tbl(l_head_count).approval_date;
        l_trx_rec_type.original_trx_id          := p_trx_tbl(l_head_count).original_trx_id;
        l_trx_rec_type.reversed_trx_id          := p_trx_tbl(l_head_count).reversed_trx_id;
        l_trx_rec_type.from_recurring_trx_id    := p_trx_tbl(l_head_count).from_recurring_trx_id;
        l_trx_rec_type.initiator_instance       := p_trx_tbl(l_head_count).initiator_instance_flag;
        l_trx_rec_type.recipient_instance       := p_trx_tbl(l_head_count).recipient_instance_flag;

  Print('Val and Insert >>>>'||'Populating Dist_Lines Tbl');
  If p_dist_lines_tbl is not null then
   l_count_lines := 1;
   for l_line_count in 1..p_dist_lines_tbl.count
   LOOP
      If (l_trx_rec_type.trx_id = p_dist_lines_tbl(l_line_count).trx_id) then

        l_dist_lines_tbl(l_count_lines).trx_id           :=
                p_dist_lines_tbl(l_line_count).trx_id;
        l_dist_lines_tbl(l_count_lines).dist_id          :=
                p_dist_lines_tbl(l_line_count).dist_id;
        l_dist_lines_tbl(l_count_lines).line_id          :=
                p_dist_lines_tbl(l_line_count).line_id;
        l_dist_lines_tbl(l_count_lines).party_id         :=
                p_dist_lines_tbl(l_line_count).party_id;
        l_dist_lines_tbl(l_count_lines).party_type       :=
                p_dist_lines_tbl(l_line_count).party_type_flag;
        l_dist_lines_tbl(l_count_lines).dist_type        :=
                p_dist_lines_tbl(l_line_count).dist_type_flag;
        l_dist_lines_tbl(l_count_lines).batch_dist_id    :=
                p_dist_lines_tbl(l_line_count).batch_dist_id;
        l_dist_lines_tbl(l_count_lines).amount_cr        :=
                p_dist_lines_tbl(l_line_count).amount_cr;
        l_dist_lines_tbl(l_count_lines).amount_dr        :=
                p_dist_lines_tbl(l_line_count).amount_dr;
        l_dist_lines_tbl(l_count_lines).ccid             :=
                p_dist_lines_tbl(l_line_count).ccid;--Bug 3603338
        l_count_lines := l_count_lines  + 1;
      End If;   -- l_trx_rec_type.trx_id = p_dist_lines_tbl.trx_id
    END LOOP;
  End if; -- p_dist_lines_tbl is not null


  Print('Val and Insert >>>>'||'Validating the Trx Header');
  FUN_TRX_PVT.Init_Trx_Validate(
                p_api_version              =>  1.0,
                p_init_msg_list            =>  l_init_msg_list,
                p_validation_level         =>  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL),
                x_return_status            =>  l_return_status,
                x_msg_count                =>  l_msg_count,
                x_msg_data                 =>  l_msg_data,
                p_trx_rec                  =>  l_trx_rec_type,
                p_dist_lines_tbl           =>  l_dist_lines_tbl,
                p_currency_code            =>  l_batch_rec.currency_code,
                p_gl_date                  =>  l_batch_rec.gl_date,
                p_trx_date                 =>  l_batch_rec.batch_date
         );

  Print('Val and Insert >>>>'||'Transaction Validation Complete');
  /* Set x_return_status according to l_return_status */
  Set_Return_Status(x_orig_status => x_return_status,
                                p_new_status => l_return_status);

  Print('Val and Insert >>>>'||'Return Staus from Txn validate '||l_return_status);

  /* If l_return_status is Unexpected - Raise Unexpected Error*/

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  If (l_return_status = FND_API.G_RET_STS_ERROR) then
        If (p_calling_sequence = 'Intercompany Import Program') then
             Print('Val and Insert >>>>'||'Inserting Trx Header Reject Reasons');
             UPDATE fun_interface_headers set import_status_code = 'R' Where trx_id = p_trx_tbl(l_head_count).trx_id;
             -- Insert into Rejections Table
             IF l_msg_count >= 1 THEN
                FOR i IN 1..l_msg_count
                LOOP
                     l_msg      :=      FND_MSG_PUB.Get( p_msg_index => l_msg_count,
                                                p_encoded => FND_API.G_FALSE );
                     If (insert_rejections(
                        p_batch_id              => p_trx_tbl(l_head_count).batch_id,
                        p_trx_id                   => p_trx_tbl(l_head_count).trx_id,
                        p_reject_reason          => l_msg
                        )<> TRUE)
                    then
                    Print('Val and Insert >>>>'||'insert_rejections of invalid transactions failure');
                                raise fnd_api.g_exc_unexpected_error;
                     End if;    -- Insert Rejections
               END LOOP;  --msg count
             END IF;  -- l_msg_count > 1
         End if;         -- Calling Sequence

        ELSE
         If (P_calling_sequence = 'Intercompany Import Program') then
             UPDATE fun_interface_headers set import_status_code = 'A'
                        Where trx_id = p_trx_tbl(l_head_count).trx_id;
        End if; -- Calling Sequence

   END IF; -- return_status

  -- Flush the  l_dist_lines_tbl table

  l_dist_lines_tbl.delete;

  END LOOP;  --- Next Transaction Record - For l_head_count
  Print('Val and Insert >>>>'||'Populating Parameters to be sent to Batch Dist Validation API');
  ---- Populate the Parameters to be sent with Init_Dist_Validate

  If p_init_dist_tbl is not null then

  for l_line_count in 1..p_init_dist_tbl.count
  LOOP
        l_init_dist_rec_type.batch_dist_id      := p_init_dist_tbl(l_line_count).batch_dist_id;
        l_init_dist_rec_type.line_number        := p_init_dist_tbl(l_line_count).line_number;
        l_init_dist_rec_type.batch_id           := p_init_dist_tbl(l_line_count).batch_id;
        l_init_dist_rec_type.ccid               := p_init_dist_tbl(l_line_count).ccid;
        l_init_dist_rec_type.amount_cr          := p_init_dist_tbl(l_line_count).amount_cr;
        l_init_dist_rec_type.amount_dr          := p_init_dist_tbl(l_line_count).amount_dr;

  --Validation Transaction API's
  Print('Val and Insert >>>>'||'Validating the Batch Distributions');
  FUN_TRX_PVT.Init_Dist_Validate(
                p_api_version              =>     1.0,
                p_init_msg_list            =>    l_init_msg_list,
                p_validation_level         =>    nvl( p_validation_level,FND_API.G_VALID_LEVEL_FULL),
                x_return_status            =>     l_return_status,
            p_le_id => p_batch_rec.from_le_id,
            p_ledger_id         => p_batch_rec.from_ledger_id,

                x_msg_count                =>     l_msg_count,
                x_msg_data                 =>     l_msg_data,
                p_init_dist_rec            =>     l_init_dist_rec_type
      );


  /* Set x_return_status according to l_return_status */
  Set_Return_Status(x_orig_status => x_return_status,
                  p_new_status => l_return_status);
  Print('Val and Insert >>>> '||' Status after Init_dist_validate 2'|| l_return_status);

  /* If l_return_status is Unexpected - Raise Unexpected Error*/
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Print('Val and Insert >>>> '||' Status after Init_dist_validate 3'|| l_return_status);
  If (l_return_status = FND_API.G_RET_STS_ERROR) then

  If (P_calling_sequence = 'Intercompany Import Program') then
      Print('Inserting Batch Distributions Reject Reasons');
      UPDATE fun_interface_batchdists set import_status_code = 'R'
                Where batch_dist_id = p_init_dist_tbl(l_line_count).batch_dist_id;

      IF l_msg_count >= 1 THEN
           FOR i IN 1..l_msg_count
           LOOP
               l_msg    :=      FND_MSG_PUB.Get( p_msg_index => l_msg_count,
                                                p_encoded => FND_API.G_FALSE );
               If (insert_rejections(
                        p_batch_id              => p_init_dist_tbl(l_line_count).batch_id,
                        p_batch_dist_id         => p_init_dist_tbl(l_line_count).batch_dist_id,
                        p_reject_reason          => l_msg
                   )<> TRUE) Then
                        Print('insert_rejections of invalid batch dist records failure');
                        raise fnd_api.g_exc_unexpected_error;
               End if;
             END LOOP;
     END IF;  -- l_msg_count > 1
   End If;

  ELSE
  If (P_calling_sequence = 'Intercompany Import Program') then
        UPDATE fun_interface_batchdists set import_status_code = 'A'
                        Where batch_dist_id = p_init_dist_tbl(l_line_count).batch_dist_id;
   End if;
  END IF;

  END LOOP; -- Next Batch_Dist recor
 End If;  -- p_init_dist_tbl is not null


  --- Populate the Parameters to be sent with Init_IC_Dist_Validate
  Print('Val and Insert >>>>'||'Populating Parameters to be sent to Dist Lines API');
  If p_dist_lines_tbl is not null then

  for l_line_count in 1..p_dist_lines_tbl.count
  LOOP
        l_dist_lines_rec_type.dist_id           := p_dist_lines_tbl(l_line_count).dist_id;
        l_dist_lines_rec_type.line_id           := p_dist_lines_tbl(l_line_count).line_id;
        l_dist_lines_rec_type.party_id          := p_dist_lines_tbl(l_line_count).party_id;
        l_dist_lines_rec_type.party_type        := p_dist_lines_tbl(l_line_count).party_type_flag;
        l_dist_lines_rec_type.dist_type         := p_dist_lines_tbl(l_line_count).dist_type_flag;
        l_dist_lines_rec_type.batch_dist_id     := p_dist_lines_tbl(l_line_count).batch_dist_id;
        l_dist_lines_rec_type.amount_cr         := p_dist_lines_tbl(l_line_count).amount_cr;
        l_dist_lines_rec_type.amount_dr         := p_dist_lines_tbl(l_line_count).amount_dr;
        l_dist_lines_rec_type.ccid                      := p_dist_lines_tbl(l_line_count).ccid;

  	-- 25-10-2007 Changes made by MAKANSAl for Bug # 6527666
  	-- If the distribution line has the party type as 'R' then the recipient
  	-- legal entity id is passed so that the validation for BSV linkage
  	-- is successfully.

  	If l_dist_lines_rec_type.party_type = 'R' Then

		--Fectch the recipient Legal Entity Id
		l_le_party_id := null;
		l_le_party_id := Fun_Tca_Pkg.Get_Le_Id(l_dist_lines_rec_type.party_id, sysdate);

		For C_Le_Id_Rec In C_Le_Id(l_le_party_id) Loop
			l_to_le_id := C_Le_Id_Rec.legal_entity_id;
		End Loop;
                -- Bug: 7695801
		select trxh.to_ledger_id
		into l_to_ledger_id
		from fun_interface_headers trxH,
		fun_interface_dist_lines dist
		where dist.trx_id = trxH.trx_id
		and dist.dist_id = l_dist_lines_rec_type.dist_id;

		-- Pass Recipient Legal entity Id

	/* Added for Debugging of Bug # 6670702 */
	Print('Val And Insert Debug >>> ' || l_init_msg_list );
	Print('Val And Insert Debug >>> ' || nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL));
	Print('Val And Insert Debug >>> ' || l_to_le_id);
	Print('Val And Insert Debug >>> ' || l_to_ledger_id);
	Print('Val And Insert Debug >>> ' || p_batch_rec.from_ledger_id);
	Print('Val And Insert Debug >>> ' || l_return_status);
	Print('Val And Insert Debug >>> ' || l_msg_count);
	Print('Val And Insert Debug >>> ' || l_msg_data);
	Print('Val And Insert Debug >>> ' || p_batch_rec.from_le_id);

		Fun_Trx_Pvt.Init_IC_Dist_Validate (
			p_api_version              =>      1.0,
                	p_init_msg_list        =>      l_init_msg_list,
                	p_validation_level         =>      nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL),
            		p_le_id 		=> l_to_le_id,
            		p_ledger_id         => l_to_ledger_id,
                	x_return_status            =>      l_return_status,
                	x_msg_count                =>      l_msg_count,
                	x_msg_data                 =>      l_msg_data,
                	p_dist_line_rec            =>         l_dist_lines_rec_type);
  	Else

		-- Changes complete for Bug # 6527666


              --Validation Transaction API's
        	Print('Val and Insert >>>>'||'Validating the Dist Lines');
        	FUN_TRX_PVT.Init_IC_Dist_Validate(
                	p_api_version              =>      1.0,
                	p_init_msg_list        =>      l_init_msg_list,
                	p_validation_level         =>      nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL),
            		p_le_id => p_batch_rec.from_le_id,
            		p_ledger_id         => p_batch_rec.from_ledger_id,
                	x_return_status            =>      l_return_status,
                	x_msg_count                =>      l_msg_count,
                	x_msg_data                 =>      l_msg_data,
                	p_dist_line_rec            =>         l_dist_lines_rec_type
                	);
	End If;

        Print('Val and Insert >>>> '||' Status after Init_dist_validate '|| l_return_status);

        /* Set x_return_status according to l_return_status */
        Set_Return_Status(x_orig_status => x_return_status,
                  p_new_status => l_return_status);


        /* If l_return_status is Unexpected - Raise Unexpected Error*/
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        If (l_return_status = FND_API.G_RET_STS_ERROR) then

         If (P_calling_sequence = 'Intercompany Import Program') then
          Print('Val and Insert >>>>'||'Inserting Dist Lines Reject Reasons');
             UPDATE fun_interface_dist_lines set import_status_code = 'R'
                        Where dist_id = p_dist_lines_tbl(l_line_count).dist_id;

             IF l_msg_count >= 1 THEN
               FOR i IN 1..l_msg_count
               LOOP
                      l_msg     :=      FND_MSG_PUB.Get( p_msg_index => l_msg_count,
                                                p_encoded => FND_API.G_FALSE );
                      If (insert_rejections(
                                p_batch_id               =>l_batch_rec.batch_id,
                                p_dist_id                => p_dist_lines_tbl(l_line_count).dist_id,
                                p_reject_reason                => l_msg
                        )<> TRUE) Then
            Print('Val and Insert >>>>'||'insert_rejections of invalid dist lines failure');
                                raise fnd_api.g_exc_unexpected_error;
                     End if;

               END LOOP;
             END IF;  -- l_msg_count > 1

      End if; -- p_calling_sequence
    ELSE
     If (P_calling_sequence = 'Intercompany Import Program') then

        UPDATE fun_interface_dist_lines set import_status_code = 'A'
                        Where dist_id = p_dist_lines_tbl(l_line_count).dist_id;
     End If;

    End if;  -- l_return_status

  END LOOP; -- Next Disttibution

  End If; -- dist_line_tbl is not null


  COMMIT WORK;

   IF p_batch_rec.batch_id is not null then
       l_batch_id :=p_batch_rec.batch_id;
   Else
      Select  fun_trx_batches_s.nextval INTO l_batch_id from dual;
   END IF;

  /* If all Validations pass then the record should be inserted into Fun Tables with status as New */
  If x_return_Status = FND_API.G_RET_STS_SUCCESS then

  If (nvl(p_insert, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
  Print ('Populating User Id');
  l_user        :=  fnd_global.user_id;
  l_login       :=  fnd_global.login_id;
  Print('Val and Insert >>>>'||'Inserting into fun_trx_batches Table');

/*  To be uncommented - when doc seq is ready

  If NOT(fun_system_options_pkg.is_manual_numbering ) then
        -- Generating batch Number
        Print('Generating Batch Number');
   fun_seq.get_sequence_number(
        P_CONTEXT_TYPE                  =>      'DB_INSTANCE',
        p_context_value                 =>      null,
        P_APPLICATION_ID                =>      435,
        P_TABLE_NAME                    =>      'FUN_TRX_BATCHES',
        P_EVENT_CODE                    =>      'CREATION',
        p_control_attribute_rec =>      null,
        p_control_date_tbl      =>      null,
        p_suppress_error        =>      null,
        x_seq_version_id                =>  l_seq_version_id,
        x_sequence_number               =>  l_sequence_number,
        x_assignment_id                 =>      l_assignment_id,
        x_error_code                    =>      l_error_code
        );

    If (l_error_code <> 'SUCCESS') then
        Print('Batch Number Generation errored out');
        Raise FND_API.G_EXC_ERROR;
    else
        l_batch_rec.batch_number := l_sequence_number;
    End If;
End If;
 To be uncommented - when doc seq is ready
 */

   -- Insertion into FUN_TRX_BATCHES TABLE

   INSERT into fun_trx_batches(
        batch_id,
        batch_number,
        initiator_id,
        from_le_id,
        from_ledger_id,
        control_total,
        running_total_cr,
        running_total_dr,
        currency_code,
        exchange_rate_type,
        status,
        description,
        note,
        trx_type_id,
        trx_type_code,
        gl_date,
        batch_date,
        reject_allow_flag,  -- changed
        original_batch_id,
        reversed_batch_id,
        from_recurring_batch_id,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute_category,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        auto_proration_flag )

    VALUES(
        l_batch_id,
        p_batch_rec.batch_number,
        p_batch_rec.initiator_id,
        p_batch_rec.from_le_id,
        p_batch_rec.from_ledger_id,
        p_batch_rec.control_total,
        p_batch_rec.running_total_cr,
        p_batch_rec.running_total_dr,
        p_batch_rec.currency_code,
        p_batch_rec. exchange_rate_type,
        p_batch_rec.status,
        p_batch_rec.description,
        p_batch_rec.note,
        p_batch_rec.trx_type_id,
        p_batch_rec. trx_type_code,
        p_batch_rec.gl_date,
        p_batch_rec.batch_date,
        p_batch_rec.reject_allow_flag,
        p_batch_rec.original_batch_id,
        p_batch_rec.reversed_batch_id,
        p_batch_rec.from_recurring_batch_id,
        p_batch_rec.attribute1,
        p_batch_rec.attribute2,
        p_batch_rec.attribute3,
        p_batch_rec.attribute4,
        p_batch_rec.attribute5,
        p_batch_rec.attribute6,
        p_batch_rec.attribute7,
        p_batch_rec.attribute8,
        p_batch_rec.attribute9,
        p_batch_rec.attribute10,
        p_batch_rec.attribute11,
        p_batch_rec.attribute12,
        p_batch_rec.attribute13,
        p_batch_rec.attribute14,
        p_batch_rec.attribute15,
        p_batch_rec.attribute_category,
        l_user,
        sysdate,
        l_user,
        sysdate,
        l_login,
        'N'
        );


  Print('Val and Insert >>>>'||'Inserting into fun_trx_headers  Table');


  -- Insertion into FUN_TRX_HEADERS and FUN_TRX_LINES TABLE
  for l_head_count in 1..p_trx_tbl.count
  LOOP

  /*  To be uncommented - when doc seq is ready

  If  NOT (fun_system_options_pkg.is_manual_numbering ) then
        -- Generating Trx  Number
        Print('Val and Insert >>>>>' ||'Generating Trx  Number');
   fun_seq.get_sequence_number(
        P_CONTEXT_TYPE                  =>      'DB_INSTANCE',
        p_context_value                 =>      null,
        P_APPLICATION_ID                =>      435,
        P_TABLE_NAME                    =>      'FUN_TRX_HEADERS',
        P_EVENT_CODE                    =>      'CREATION',
        p_control_attribute_rec         =>      null,
        p_control_date_tbl              =>      null,
        p_suppress_error                =>      null,
        x_seq_version_id                =>      l_seq_version_id,
        x_sequence_number               =>      l_sequence_number,
        x_assignment_id                 =>      l_assignment_id,
        x_error_code                    =>      l_error_code
        );

    If (l_error_code <> 'SUCCESS') then
        Print('Trx Number Generation errored out');
        Raise FND_API.G_EXC_ERROR;
    else
        p_trx_tbl(l_head_count).trx_number := l_sequence_number;
    End If;
  End If;

   To be uncommented - when doc seq is ready

   */

  INSERT into fun_trx_headers (
        trx_id,
        trx_number,
        initiator_id,
        recipient_id,
        to_le_id,
        to_ledger_id,
        batch_id,
        status,
        init_amount_cr,
        init_amount_dr,
        reci_amount_cr,
        reci_amount_dr,
        ar_invoice_number,
        invoice_flag,
        approver_id,
        approval_date,
        original_trx_id,
        reversed_trx_id,
        from_recurring_trx_id,
        initiator_instance_flag,
        recipient_instance_flag,
        description,
        reject_reason,
        init_wf_key,
        reci_wf_key,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute_category,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
        )
        VALUES(
        Fun_trx_headers_s.nextval,
        p_trx_tbl(l_head_count).trx_number,
        p_batch_rec.initiator_id,
        p_trx_tbl(l_head_count).recipient_id,
        p_trx_tbl(l_head_count).to_le_id,
        p_trx_tbl(l_head_count).to_ledger_id,
        l_batch_id,
        p_trx_tbl(l_head_count).status,
        p_trx_tbl(l_head_count).init_amount_cr,
        p_trx_tbl(l_head_count).init_amount_dr,
        p_trx_tbl(l_head_count).reci_amount_cr,
        p_trx_tbl(l_head_count).reci_amount_dr,
        p_trx_tbl(l_head_count).ar_invoice_number,
        p_trx_tbl(l_head_count).invoice_flag,
        p_trx_tbl(l_head_count).approver_id,
        p_trx_tbl(l_head_count).approval_date,
        p_trx_tbl(l_head_count).original_trx_id,
        p_trx_tbl(l_head_count).reversed_trx_id,
        p_trx_tbl(l_head_count).from_recurring_trx_id,
        p_trx_tbl(l_head_count).initiator_instance_flag,
        p_trx_tbl(l_head_count).recipient_instance_flag,
        p_trx_tbl(l_head_count).description,
        p_trx_tbl(l_head_count).reject_reason,
        p_trx_tbl(l_head_count).init_wf_key,
        p_trx_tbl(l_head_count).reci_wf_key,
        p_trx_tbl(l_head_count).attribute1,
        p_trx_tbl(l_head_count).attribute2,
        p_trx_tbl(l_head_count).attribute3,
        p_trx_tbl(l_head_count).attribute4,
        p_trx_tbl(l_head_count).attribute5,
        p_trx_tbl(l_head_count).attribute6,
        p_trx_tbl(l_head_count).attribute7,
        p_trx_tbl(l_head_count).attribute8,
        p_trx_tbl(l_head_count).attribute9,
        p_trx_tbl(l_head_count).attribute10,
        p_trx_tbl(l_head_count).attribute11,
        p_trx_tbl(l_head_count).attribute12,
        p_trx_tbl(l_head_count).attribute13,
        p_trx_tbl(l_head_count).attribute14,
        p_trx_tbl(l_head_count).attribute15,
        p_trx_tbl(l_head_count).attribute_category,
        l_user,
        sysdate,
        l_user,
        sysdate,
        l_login
        );

  Print('Val and Insert >>>>'||'Inserting into  fun_trx_lines Table');

  /*  To be uncommented - when doc seq is ready

  If  NOT (fun_system_options_pkg.is_manual_numbering ) then

        Print('Val and Insert >>>>>' ||'Generating Trx  Lines');
   fun_seq.get_sequence_number(
        P_CONTEXT_TYPE          =>      'DB_INSTANCE',
        p_context_value                 =>      null,
        P_APPLICATION_ID                =>      435,
        P_TABLE_NAME                    =>      'FUN_TRX_LINES',
        P_EVENT_CODE                    =>      'CREATION',
        p_control_attribute_rec =>      null,
        p_control_date_tbl      =>      null,
        p_suppress_error        =>      null,
        x_seq_version_id                =>      l_seq_version_id,
        x_sequence_number               =>      l_sequence_number,
        x_assignment_id                 =>      l_assignment_id,
        x_error_code                    =>      l_error_code
        );

    If (l_error_code <> 'SUCCESS') then
        Print('Val and Insert >>>>>' ||'Generating  trx line number errored out ');
        Raise FND_API.G_EXC_ERROR;

    End If;
  End If;
  To be uncommented - when doc seq is ready
  */


  INSERT into fun_trx_lines (
        line_id,
        trx_id,
        line_number,
        line_type_flag,
        init_amount_cr,
        init_amount_dr,
        reci_amount_cr,
        reci_amount_dr,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
  )
 VALUES(
        Fun_trx_lines_s.nextval,
        Fun_trx_headers_s.currval,
        --l_sequence_number,  commented out untill generation of doc seq
        --1234, Taking line_id as line_number instead of hardcoding it. Bug 3603338
        Fun_trx_lines_s.currval,
        'I',
        p_trx_tbl(l_head_count).init_amount_cr,
        p_trx_tbl(l_head_count).init_amount_dr,
        p_trx_tbl(l_head_count).reci_amount_cr,
        p_trx_tbl(l_head_count).reci_amount_dr,
        p_trx_tbl(l_head_count).description,
        l_user,
        sysdate,
        l_user,
        sysdate,
        l_login
        );


  -- Insertion into FUN_DIST_LINES
  Print('Val and Insert >>>>'||'Inserting into fun_trx_dist_lines Table');
  If p_dist_lines_tbl is not null then

  for l_line_count in 1..p_dist_lines_tbl.count
  LOOP
    IF p_dist_lines_tbl(l_line_count).trx_id = p_trx_tbl(l_head_count).trx_id THEN
        /*  To be uncommented - when doc seq is ready

    If  NOT (fun_system_options_pkg.is_manual_numbering ) then

    Print('Val and Insert >>>>>' ||'Generating Trx  dist Lines');
    fun_seq.get_sequence_number(
        P_CONTEXT_TYPE  =>      'DB_INSTANCE',
        p_context_value                 =>      null,
        P_APPLICATION_ID                =>      435,
        P_TABLE_NAME                    =>      'FUN_DIST_LINES',
        P_EVENT_CODE                    =>      'CREATION',
        p_control_attribute_rec         =>      null,
        p_control_date_tbl              =>      null,
        p_suppress_error                =>      null,
        x_seq_version_id                =>      l_seq_version_id,
        x_sequence_number               =>      l_sequence_number,
        x_assignment_id                 =>      l_assignment_id,
        x_error_code                    =>      l_error_code
        );

    If (l_error_code <> 'SUCCESS') then
    Print('Val and Insert >>>>>' ||'Generating  trx dist  line number errored out ');
        Raise FND_API.G_EXC_ERROR;
    else
        p_dist_lines_tbl(l_line_count).dist_number := l_sequence_number;
    End If;
  End If;

   To be uncommented - when doc seq is ready
   */
/*p_dist_lines_tbl(l_line_count).dist_number := 1234; --Bug 3603338 Hardcoded becoz seq num is not ready
Taking dist_id as dist_number instead of hardcoding it.
*/
  INSERT into fun_dist_lines
  (
        dist_id,
        line_id,
        dist_number,
        party_id,
        party_type_flag,
        dist_type_flag,
        batch_dist_id,
        amount_cr,
        amount_dr,
        ccid,
        description,
        auto_generate_flag,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute_category,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        trx_id
  )
  VALUES(
        Fun_dist_lines_s.nextval,
        Fun_trx_lines_s.CURRVAL,
        Fun_dist_lines_s.currval, --Bug 3603338
        p_dist_lines_tbl(l_line_count).party_id,
        p_dist_lines_tbl(l_line_count).party_type_flag,
        p_dist_lines_tbl(l_line_count).dist_type_flag,
        p_dist_lines_tbl(l_line_count).batch_dist_id,
        p_dist_lines_tbl(l_line_count).amount_cr,
        p_dist_lines_tbl(l_line_count).amount_dr,
        p_dist_lines_tbl(l_line_count).ccid,
        p_dist_lines_tbl(l_line_count).description,
        --p_dist_lines_tbl(l_line_count).auto_generate_flag, is not avl anywhere for now hardcoding to N Bug 3603338
        'N',
        p_dist_lines_tbl(l_line_count).attribute1,
        p_dist_lines_tbl(l_line_count).attribute2,
        p_dist_lines_tbl(l_line_count).attribute3,
        p_dist_lines_tbl(l_line_count).attribute4,
        p_dist_lines_tbl(l_line_count).attribute5,
        p_dist_lines_tbl(l_line_count).attribute6,
        p_dist_lines_tbl(l_line_count).attribute7,
        p_dist_lines_tbl(l_line_count).attribute8,
        p_dist_lines_tbl(l_line_count).attribute9,
        p_dist_lines_tbl(l_line_count).attribute10,
        p_dist_lines_tbl(l_line_count).attribute11,
        p_dist_lines_tbl(l_line_count).attribute12,
        p_dist_lines_tbl(l_line_count).attribute13,
        p_dist_lines_tbl(l_line_count).attribute14,
        p_dist_lines_tbl(l_line_count).attribute15,
        p_dist_lines_tbl(l_line_count).attribute_category,
        l_user,
        sysdate,
        l_user,
        sysdate,
        l_login,
        Fun_trx_headers_s.currval
      );
    END IF; --p_dist_lines_tbl.trx_id = p_trx_tbl.trx_id

   END LOOP; -- l_line_count
   End If; -- p_ dist_line_tbl not null

/* -- Send Batch not individual transactions
    --raise Workflow event if p_sent='Y'
   IF p_sent = 'Y' THEN
      Print('Val and Insert >>>>'||'Raise Business Event');
      select FUN_TRX_BATCHES_S.CURRVAL into l_batch_id from dual;
      select FUN_TRX_HEADERS_S.CURRVAL into l_trx_id from dual;
      l_wfkey := fun_initiator_wf_pkg.generate_key(l_batch_id, l_trx_id);
      fun_wf_common.raise_wf_bus_event(l_batch_id, l_trx_id, l_wfkey, 'oracle.apps.fun.manualtrx.batch.send');
   END IF;
*/

  END LOOP; --l_head_count

  Print('Val and Insert >>>>'||'Inserting into fun_trx_batch_dist Table');
  -- Insertion into FUN_BATCH_DISTS
  If p_init_dist_tbl is not null then
  for l_line_count in 1..p_init_dist_tbl.count
  LOOP

   INSERT into fun_batch_dists (
        batch_dist_id,
        line_number,
        batch_id,
        ccid,
        amount_cr,
        amount_dr,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
   )
   VALUES
   (
        fun_batch_dist_s.nextval,
        p_init_dist_tbl(l_line_count).line_number,
        l_batch_id,
        p_init_dist_tbl(l_line_count).ccid,
        p_init_dist_tbl(l_line_count).amount_cr,
        p_init_dist_tbl(l_line_count).amount_dr,
        p_init_dist_tbl(l_line_count).description,
        l_user,
        sysdate,
        l_user,
        sysdate,
        l_login
   );
  END LOOP; -- l_line_count
  End If; -- p_init_dist_tbl not null

   IF p_sent = 'Y' THEN
      Print('Val and Insert >>>>'||'Raise Business Event');

      UPDATE fun_trx_batches
      SET    status = 'SENT'
      WHERE  batch_id = l_batch_id;

      UPDATE fun_trx_headers
      SET    status = 'SENT'
      WHERE  batch_id = l_batch_id;

      l_wfkey := fun_initiator_wf_pkg.generate_key(l_batch_id, NULL);

      fun_wf_common.raise_wf_bus_event(l_batch_id,
                                       NULL,
                                       l_wfkey,
                                       'oracle.apps.fun.manualtrx.batch.send');
   END IF;-- p_sent ='Y'

   End if; -- p_insert true
  End If; -- Overall Status

  IF FND_API.To_Boolean( nvl(p_commit,FND_API.G_FALSE) ) THEN
        COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                          p_data  => x_msg_data);
  Print('Val and Insert >>>>'||'End of the API');

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
      Print('g_exc_error');
          p_batch_rec           := l_old_batch_rec;
          p_trx_tbl             := l_old_trx_tbl;
          p_init_dist_tbl       := l_old_init_dist_tbl;
          p_dist_lines_tbl      := l_old_dist_lines_tbl;
          ROLLBACK TO Fun_Trx_Val_And_Insert_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Print('Val and Insert >>>>'||'Unexpected error occurred -'||SQLERRM);
      p_batch_rec               := l_old_batch_rec;
          p_trx_tbl             := l_old_trx_tbl;
          p_init_dist_tbl       := l_old_init_dist_tbl;
          p_dist_lines_tbl      := l_old_dist_lines_tbl;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      Print('****************************************');
      Print('Val and Insert >>>>'||'Details of Error');
      Print('****************************************');
      IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count
           LOOP
               Print(FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ));
           END LOOP;
      ELSE
           Print(FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE ));
      END IF;
      ROLLBACK TO Fun_Trx_Val_And_Insert_PUB;

      WHEN OTHERS THEN
      Print('Val and Insert >>>>'||'When Other');
          p_batch_rec           := l_old_batch_rec;
          p_trx_tbl             := l_old_trx_tbl;
          p_init_dist_tbl       := l_old_init_dist_tbl;
          p_dist_lines_tbl      := l_old_dist_lines_tbl;
          ROLLBACK TO Fun_Trx_Val_And_Insert_PUB;
          Print('Val and Insert >>>>'||'Exception others- '||SQLERRM);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);


END CREATE_BATCH; -- Procedure



END FUN_TRX_PUB;  -- Package Body


/
