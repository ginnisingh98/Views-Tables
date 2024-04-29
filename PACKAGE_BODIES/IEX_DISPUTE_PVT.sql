--------------------------------------------------------
--  DDL for Package Body IEX_DISPUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DISPUTE_PVT" AS
/* $Header: iexvdisb.pls 120.4.12010000.5 2008/11/14 13:08:48 pnaveenk ship $ */

--G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpimpb.pls';
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'IEX_DISPUTE_PVT';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
--Added parameters p_skip_workflow_flag and p_dispute_date
--for bug#6347547 by schekuri on 08-Nov-2007
-- Bug #6777367 bibeura 28-Jan-2008 Added parameter p_batch_source_name
PROCEDURE Create_Dispute(p_api_version     IN NUMBER,
                         p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
                         p_commit          IN VARCHAR2 := FND_API.G_FALSE,
                         p_disp_header_rec IN IEX_DISPUTE_PUB.DISP_HEADER_REC,
                         p_disp_line_tbl   IN IEX_DISPUTE_PUB.DISPUTE_LINE_TBL,
			 x_request_id      OUT NOCOPY NUMBER,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
			 p_skip_workflow_flag   IN VARCHAR2    DEFAULT 'N',
			 p_batch_source_name    IN VARCHAR2    DEFAULT NULL,
			 p_dispute_date	IN DATE	DEFAULT NULL) AS

l_api_name            VARCHAR2(50)  := 'create_dispute';
l_api_version_number  NUMBER := 1.0;
l_request_id          NUMBER;
l_status              VARCHAR2(20);
l_dis_id              NUMBER; -- using this for the sequence
x                     VARCHAR(20);
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(32767);
l_init_msg_list       VARCHAR2(25) := p_init_msg_list;
l_commit              VARCHAR2(25) := p_commit;

l_disp_header_rec     IEX_DISPUTE_PUB.DISP_HEADER_REC  := p_disp_header_rec;
lp_disp_line_tbl      IEX_DISPUTE_PUB.DISPUTE_LINE_TBL := p_disp_line_tbl;
l_disp_line_tbl       arw_cmreq_cover.Cm_line_Tbl_Type_cover;
l_cover_rec           arw_cmreq_cover.Cm_Line_Rec_Type_Cover;
i                     NUMBER;
lines_count           NUMBER;
l_line                NUMBER;
l_tax                 NUMBER;
l_freight             NUMBER;

l_multiplier          NUMBER := -1;
l_creationSign        VARCHAR2(5);
l_credit_memo_type_id NUMBER;

l_currency_code VARCHAR2(10) := 'USD';
l_request_url      VARCHAR2(1000);
l_transaction_url VARCHAR2(1000);
l_trans_act_url   VARCHAR2(1000);
l_org_id          NUMBER(15);
l_disp_component VARCHAR2(150);

Cursor Get_Currency_Code Is
   select invoice_currency_code, org_id
     from ra_customer_trx
    where customer_trx_id = l_disp_header_rec.cust_trx_id;

    BEGIN

      SAVEPOINT create_dispute_pvt;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'PVT: ' || l_api_name || ' start');
      END IF;
      --
      -- API body
      --          --------------------------------------------------------


--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: getting creation_sign');
    END IF;
    -- added by ehuh for URL parameters
    Open Get_Currency_Code;
    Fetch Get_Currency_Code into l_currency_code, l_org_id;
    Close Get_Currency_Code;


    --Begin-fix bug #3817776-JYPARK-09/30/2005-change URL string to followin irec request

    IF l_disp_header_rec.dispute_section = 'LINES_SUBTOTAL' THEN
      l_disp_component := 'DISP_SUBTOTAL';
    ELSIF l_disp_header_rec.dispute_section = 'PERCENT' THEN
      l_disp_component := 'DISP_TOTAL';
    ELSIF l_disp_header_rec.dispute_section = 'SHIPPING' THEN
      l_disp_component := 'DISP_SHIPPING';
    ELSIF l_disp_header_rec.dispute_section = 'SPECIFIC_INVOICE_LINES' THEN
      l_disp_component := 'DISP_SPEC_LINE';
    ELSIF l_disp_header_rec.dispute_section = 'TAX' THEN
      l_disp_component := 'DISP_TAX';
    ELSIF l_disp_header_rec.dispute_section = 'TOTAL' THEN
      l_disp_component := 'DISP_TOTAL';
    END IF;

    l_request_url   := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARITEMPCMREQUESTDETAILSPAGE'||'&'||'akRegionApplicationId=222'||
                              '&'||'Irtransactiontype=REQ'||'&'||'Ircustomertrxid='||l_disp_header_rec.cust_trx_id||
                              -- '&'||'req_id='||'&'||'Ircurrencycode='||l_currency_code||'&'||'component=DISP_SPEC_LINE' ;
                              '&'||'req_id='||'&'||'Ircurrencycode='||l_currency_code||
                              '&'||'IcxPrintablePageButton=&OUnit='||l_org_id||'&NtfId=-&#NID-&' ||'component='||l_disp_component;

   l_transaction_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARITRANSACTIONDETAILSPAGE'||'&'||'akRegionApplicationId=222'||
                                '&'||'Irtransactiontype=INV'||'&'||'Ircustomertrxid='||l_disp_header_rec.cust_trx_id||'&'||'Irtermssequencenumber=1'||
                                --'&'||'Ircurrencycode='||l_currency_code;
                                '&'||'Ircurrencycode='||l_currency_code||'&IcxPrintablePageButton=&OUnit='||l_org_id||'&NtfId=-&#NID-';

    l_trans_act_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=ARITRANSACTIONDETAILSPAGE'||'&'||'akRegionApplicationId=222'||
                               '&'||'Irtransactiontype=INV'||'&'||'Ircustomertrxid='||l_disp_header_rec.cust_trx_id||'&'||'Irtermssequencenumber=1'||
                               --'&'||'Ircurrencycode='||l_currency_code||'&'||'AriInvDisplay=BOGUS_GO'||'&'||'AriInvDisplayType=INVOICE_ACTIVITIES';
                               '&'||'Ircurrencycode='||l_currency_code||'&IcxPrintablePageButton=&OUnit='||l_org_id||'&NtfId=-&#NID-&AriInvDisplay=BOGUS_GO'||'&'||'AriInvDisplayType=INVOICE_ACTIVITIES';
    --End-fix bug #3817776-JYPARK-09/30/2005-change URL string to followin irec request

    -- figure out NOCOPY creation sign
    select TRX_TYPE.creation_sign, TRX_TYPE.CREDIT_MEMO_TYPE_ID into l_creationSign, l_credit_memo_type_id
      from ra_cust_trx_types TRX_TYPE,
           ra_customer_trx TRX
     where TRX.CUST_TRX_TYPE_ID = TRX_TYPE.CUST_TRX_TYPE_ID and
           TRX.Customer_Trx_ID = l_disp_header_rec.cust_trx_id;

    if l_credit_memo_type_id is not null then

        if l_creationSign = 'P' then
            l_multiplier := -1;
        elsif l_creationSign = 'N' then
            l_multiplier := 1;
        end if;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: creation_sign is ' || l_creationSign);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: multiplier is ' || l_multiplier);
        END IF;

          -- add this to avoid bug# 2166002
         select decode(l_disp_header_rec.line_amt, FND_API.G_MISS_NUM, 0, l_disp_header_rec.line_amt) into l_line
           from dual;
         select decode(l_disp_header_rec.tax_amt, FND_API.G_MISS_NUM, 0, l_disp_header_rec.tax_amt) into l_tax
           from dual;
         select decode(l_disp_header_rec.freight_amt, FND_API.G_MISS_NUM, 0, l_disp_header_rec.freight_amt) into l_freight
           from dual;

          if lp_disp_line_tbl is not null then
              lines_count := lp_disp_line_tbl.count;
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'lines count is ' || lines_count);
              END IF;

              if lines_count >= 1 then
                  FOR  i in 1..lines_count
                  LOOP
                     BEGIN
                        l_disp_line_tbl(i).customer_trx_line_id := lp_disp_line_tbl(i).customer_trx_line_id;
                        l_disp_line_tbl(i).extended_amount      := lp_disp_line_tbl(i).extended_amount * l_multiplier;
                        l_disp_line_tbl(i).quantity_credited    := lp_disp_line_tbl(i).quantity_credited * l_multiplier;

                        -- price should be positive no matter what
                            SELECT UNIT_SELLING_PRICE
                              INTO l_disp_line_tbl(i).price
                              FROM ra_customer_trx_lines
                             WHERE customer_trx_line_id = l_disp_line_tbl(i).customer_trx_line_id;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_UNIT_PRICE');
                          FND_MSG_PUB.Add;
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          RAISE FND_API.G_EXC_ERROR;
                     END  ;
                     --   dbms_output.put_line('price for customer_trx_id is'||to_char(l_disp_line_tbl(i).price)) ;

                   END LOOP ;
              end if;
          end if;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: Calling AR Create Request API');
        END IF;
        AR_CREDIT_MEMO_API_PUB.create_request(
                p_api_version          => l_api_version_number,
                p_init_msg_list        => FND_API.G_TRUE,
                p_commit               => FND_API.G_TRUE,
                p_validation_level     => FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data,
                p_customer_trx_id      => l_disp_header_rec.cust_trx_id,
                p_line_credit_flag     => l_disp_header_rec.line_credit_flag,
                p_line_amount          => l_line * l_multiplier,
                p_tax_amount           => l_tax * l_multiplier,
                p_freight_amount       => l_freight * l_multiplier,
                p_cm_reason_code       => l_disp_header_rec.cm_reason_code,
                p_comments             => l_disp_header_rec.COMMENTS,
		p_internal_comment     => p_disp_header_rec.INTERNAL_COMMENT,   --Added for bug#7376422 by PNAVEENK on 4-sep-2008
                p_orig_trx_number      => l_disp_header_rec.orig_trx_number,
                p_tax_ex_cert_num      => l_disp_header_rec.tax_ex_cert_num,
                p_request_url          => l_request_url,     --'AR_CREDIT_MEMO_API_PUB.print_default_page',
                p_transaction_url      => l_transaction_url, --'AR_CREDIT_MEMO_API_PUB.print_default_page',
                p_trans_act_url        => l_trans_act_url,   --'AR_CREDIT_MEMO_API_PUB.print_default_page',
                p_cm_line_tbl          => l_disp_line_tbl,
                p_skip_workflow_flag   => p_skip_workflow_flag, --'N', --Modified for bug#6347547 by schekuri on 08-Nov-2007
		p_batch_source_name    => p_batch_source_name,  -- Bug #6777367 bibeura 28-Jan-2008
                x_request_id           => l_request_id,
		p_org_id               => l_org_id, --Bug4696678. Fix by LKKUMAR on 26-Oct-2005. Pass Org_id.
		p_dispute_date	       => p_dispute_date  --Added for bug#6347547 by schekuri on 08-Nov-2007
		);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            SELECT iex_disputes_s.nextval INTO l_dis_id FROM dual;

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: Inserting a dispute row in IEX_DISPUTES');
           END IF;
           IEX_DISPUTES_PKG.Insert_Row(x_rowid              => x,
                                       p_dispute_id         => l_dis_id,
                                       p_last_update_date   => sysdate,
                                       p_last_updated_by    => FND_GLOBAL.USER_ID,
                                       p_creation_date      => sysdate,
                                       p_created_by         => FND_GLOBAL.USER_ID,
                                       p_last_update_login  => FND_GLOBAL.USER_ID,
                                       p_cm_request_id      => l_request_id,
                                       p_dispute_section    => p_disp_header_rec.dispute_section,
                                       p_delinquency_id     => p_disp_header_rec.delinquency_id);
           ELSE
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: Insert Failed');
              END IF;
              FND_MESSAGE.SET_NAME('IEX', 'IEX_DISPUTE_FAILED');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;

          END IF ;

    else  -- no credit memo associated with transaction
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'IEX_DISPUTES_PVT: CreateDispute: Credit Memo Configuration failure');
          END IF;
          FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_CREDIT_MEMO');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

    end if;

       IF FND_API.to_Boolean( p_commit )
       THEN
        COMMIT WORK;
       END IF;

      x_request_id    := l_request_id;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
     -- End of API body

     -- Debug Message
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'PVT: ' || l_api_name || ' end');
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_count  => x_msg_count,
                                p_data   => x_msg_data);
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END create_dispute;

PROCEDURE is_delinquency_dispute(p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2 ,
                                 p_delinquency_id      IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2) AS

l_api_name           VARCHAR2(50)  := 'is_delinquency_dispute';
l_api_version_number NUMBER := 1.0;
l_delinquency_id     NUMBER := p_delinquency_id;
l_count              NUMBER := 0 ;
l_request_id         NUMBER ;
l_status             VARCHAR(20) ;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT is_delinquency_dispute_pvt;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('is_delinquency_dispute: ' || 'PVT: ' || l_api_name || ' start');
      END IF;

      --
      -- API body
      --

      select count(1) into l_count
      from   iex_disputes
      where  DELINQUENCY_ID = l_delinquency_id ;

      IF (l_count = 0 ) THEN
        --dbms_output.put_line('No dispute exist for this delinquency') ;
        FND_MESSAGE.Set_Name('IEX_NO_DISP_FOR_DEL', 'IEX_NO_DISP_FOR_DEL');
        FND_MSG_PUB.Add;
        x_return_status := 'F' ;
      ELSE
        select cm_request_id into l_request_id
        from   iex_disputes
        where  delinquency_id = l_delinquency_id ;

        select status into l_status
        from   ra_cm_requests
        where  request_id = l_request_id ;

        IF l_status = 'PENDING_APPROVAL' or l_status = 'APPROVED_PEND_COMP' then
            x_return_status := 'T' ;
        ELSIF l_status = 'COMPLETE' or l_status = 'NOT_APPROVED'  THEN
            FND_MESSAGE.Set_Name('IEX_STATUS_COMPLETE_DEL', 'IEX_STATUS_COMPLETE_DEL');
            FND_MSG_PUB.Add;
            x_return_status := 'F' ;
        ELSE
            FND_MESSAGE.Set_Name('IEX_STATUS_NOEXIST_DEL', 'IEX_STATUS_NOEXIST_DEL');
            FND_MSG_PUB.Add;
            x_return_status := 'F' ;
        END IF ;

      END IF ;

     -- End of API body

     -- Debug Message
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('is_delinquency_dispute: ' || 'PVT: ' || l_api_name || ' end');
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO is_delinquency_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO is_delinquency_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO is_delinquency_dispute_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);



END is_delinquency_dispute;

PROCEDURE CANCEL_DISPUTE (p_api_version     IN NUMBER,
                              p_commit          IN VARCHAR2,
			      p_dispute_id      IN NUMBER,
			      p_cancel_comments IN VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
                              x_msg_data        OUT NOCOPY VARCHAR2
			     )  IS

l_item_type			VARCHAR2(100);
l_result			VARCHAR2(100);
l_status			VARCHAR2(8);
l_action_id			NUMBER := 0;
l_function_mode			VARCHAR2(10);
l_debug_mesg			VARCHAR2(240);
l_approver_id			NUMBER;
l_reason_code			VARCHAR2(45);
l_currency_code			VARCHAR2(15);
l_total_credit_to_invoice	NUMBER;
l_result_flag			VARCHAR2(1);
l_customer_trx_id		NUMBER;

l_request_id			NUMBER;
new_dispute_date		DATE;
new_dispute_amt			NUMBER;
remove_from_dispute_amt		NUMBER;
l_org_id			NUMBER;
l_document_id			NUMBER;
l_approver_display_name		VARCHAR2(100);
l_note_id			NUMBER;
l_note_text			ar_notes.text%TYPE;
l_notes				wf_item_attribute_values.text_value%TYPE;

l_last_updated_by		NUMBER;
l_last_update_login		NUMBER;
l_last_update_date		DATE;
l_creation_date			DATE;
l_created_by			NUMBER;
errmsg                          VARCHAR2(32767);
l_default_note_type		varchar2(240) := FND_PROFILE.VALUE('AST_NOTES_DEFAULT_TYPE');
l_party_id			number;
l_cust_account_id		number;
l_customer_site_use_id		number;
l_payment_schedule_id		number;
i                               number;
l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
l_return_status             	VARCHAR2(1);
l_msg_count                 	NUMBER;
l_msg_data                  	VARCHAR2(32767);

CURSOR ps_cur(p_customer_trx_id NUMBER) IS
SELECT payment_schedule_id,
  due_date,
  amount_in_dispute,
  dispute_date
FROM ar_payment_schedules ps
WHERE ps.customer_trx_id = p_customer_trx_id;

CURSOR c_item_type(l_item_key NUMBER) IS
SELECT item_type
FROM wf_items
WHERE item_key = l_item_key
 AND item_type IN('ARCMREQ',   'ARAMECM');

cursor get_partyid(p_cust_acct_id number) is
	select party_id
	from hz_cust_accounts
	where cust_account_id = p_cust_acct_id;

Cursor  Get_billto(p_cust_trx_id number) Is
            select bill_to_site_use_id
              from ra_customer_trx
              where customer_trx_id = p_cust_trx_id;

Cursor Get_paymentid(p_cust_trx_id number) Is
           select customer_id,payment_schedule_id
             from ar_payment_schedules
             where customer_trx_id = p_cust_trx_id;

BEGIN

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('**** BEGIN IEX_DISPUTE_PVT.CANCEL_DISPUTE ************');
  END IF;

  SAVEPOINT CANCEL_DISPUTE;

  -- Initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_item_type(p_dispute_id);
  FETCH c_item_type
  INTO l_item_type;
  CLOSE c_item_type;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_item_type : '|| l_item_type);
  END IF;

  IF l_item_type IS NOT NULL THEN

    l_function_mode := 'RUN';

    BEGIN

      BEGIN

        SELECT org_id
        INTO l_org_id
        FROM ra_cm_requests_all
        WHERE request_id = p_dispute_id;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_org_id: ' || l_org_id);
	END IF;
	----------------------------------------------------------
        l_debug_mesg := 'Get the org_id for the credit memo request';
        ----------------------------------------------------------

        mo_global.set_policy_context('S',   l_org_id);
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_org_id: ' || l_org_id);
	END IF;

      EXCEPTION
      WHEN others THEN
        ROLLBACK TO CANCEL_DISPUTE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
		errmsg := SQLERRM;
	        IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
	END IF;
	RAISE FND_API.G_EXC_ERROR;

      END;
      ---------------------------------------------------------
      l_debug_mesg := 'Remove Transaction from Dispute';
      ---------------------------------------------------------

      IF(l_function_mode = 'RUN') THEN

        l_customer_trx_id := wf_engine.getitemattrnumber(l_item_type,   p_dispute_id,   'CUSTOMER_TRX_ID');
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_customer_trx_id: ' || l_customer_trx_id);
	END IF;

        SELECT total_amount * -1
        INTO remove_from_dispute_amt
        FROM ra_cm_requests
        WHERE request_id = p_dispute_id;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: remove_from_dispute_amt: ' || remove_from_dispute_amt);
	END IF;

        BEGIN

          FOR ps_rec IN ps_cur(l_customer_trx_id)
          LOOP

            new_dispute_amt := ps_rec.amount_in_dispute -remove_from_dispute_amt;

            IF new_dispute_amt = 0 THEN
              new_dispute_date := NULL;
            ELSE
              new_dispute_date := ps_rec.dispute_date;
            END IF;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: new_dispute_date: '||new_dispute_date);
	    END IF;
            arp_process_cutil.update_ps(p_ps_id			=> ps_rec.payment_schedule_id,
					p_due_date		=> ps_rec.due_date,
					p_amount_in_dispute	=> new_dispute_amt,
					p_dispute_date		=> new_dispute_date,
					p_update_dff		=> 'N',
					p_attribute_category	=> NULL,
					p_attribute1		=> NULL,
					p_attribute2		=> NULL,
					p_attribute3		=> NULL,
					p_attribute4		=> NULL,
					p_attribute5		=> NULL,
					p_attribute6		=> NULL,
					p_attribute7		=> NULL,
					p_attribute8		=> NULL,
					p_attribute9		=> NULL,
					p_attribute10		=> NULL,
					p_attribute11		=> NULL,
					p_attribute12		=> NULL,
					p_attribute13		=> NULL,
					p_attribute14		=> NULL,
					p_attribute15		=> NULL);
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: After arp_process_cutil.update_ps for p_ps_id => ' || ps_rec.payment_schedule_id);
	    END IF;
          END LOOP;

          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: End of FOR LOOP');
	  END IF;
        END;

      END IF;  --IF(l_function_mode = 'RUN') THEN

    EXCEPTION
    WHEN others THEN
      ROLLBACK TO CANCEL_DISPUTE;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
		errmsg := SQLERRM;
	        IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
	END IF;
	RAISE FND_API.G_EXC_ERROR;

    END;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: Before calling wf_engine.itemstatus');
    END IF;
    wf_engine.itemstatus(itemtype => l_item_type,   itemkey => p_dispute_id,   status => l_status,   result => l_result);

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: after workflow status check ' || l_status || ' item key' || p_dispute_id);
    END IF;

    IF l_status <> wf_engine.eng_completed THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	  IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: process has not completed and status =>' || l_status);
	  IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: Calling wf_engine.abortprocess');
      END IF;
      BEGIN
        wf_engine.abortprocess(itemtype => l_item_type,   itemkey => p_dispute_id);
        wf_engine.itemstatus(itemtype => l_item_type,   itemkey => p_dispute_id,   status => l_status,   result => l_result);
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: Abort process has completed and status =>' || l_status);
	END IF;

      EXCEPTION
      WHEN others THEN
        ROLLBACK TO CANCEL_DISPUTE;
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: abort process ' || l_item_type || 'itemkey ' || p_dispute_id || 'has failed');
		errmsg := SQLERRM;
	        IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
	END IF;
	RAISE FND_API.G_EXC_ERROR;

      END;

      ---------------------------------------------------------------------
      l_debug_mesg := 'Insert Rejected Response notes';
      ---------------------------------------------------------------------
      BEGIN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: Insert Rejected Response notes');
	END IF;
        arp_global.init_global;

        l_last_updated_by := arp_global.user_id;
        l_last_update_login := arp_global.last_update_login;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_last_updated_by: ' || l_last_updated_by || ' l_last_update_login: '|| l_last_update_login);
	END IF;
        l_document_id := wf_engine.getitemattrnumber(l_item_type,   p_dispute_id,   'WORKFLOW_DOCUMENT_ID');
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_document_id: '||l_document_id);
	END IF;
        l_customer_trx_id := wf_engine.getitemattrnumber(l_item_type,   p_dispute_id,   'CUSTOMER_TRX_ID');
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_customer_trx_id: '||l_customer_trx_id);
	END IF;

        if l_customer_trx_id is null then
		SELECT customer_trx_id
		INTO l_customer_trx_id
		FROM ra_cm_requests
		WHERE request_id = l_document_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_customer_trx_id: '||l_customer_trx_id);
		END IF;
	end if;


        l_notes := wf_engine.getitemattrtext(l_item_type,   p_dispute_id,   'NOTES');

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_notes: '||l_notes);
	END IF;

        fnd_message.set_name('AR',   'AR_WF_REJECTED_RESPONSE');
        fnd_message.set_token('REQUEST_ID',   to_char(p_dispute_id));
        fnd_message.set_token('APPROVER',   fnd_global.user_id);

        l_note_text := fnd_message.GET;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: l_note_text: ' ||l_note_text);
	END IF;

        IF l_notes IS NOT NULL THEN
          l_note_text := substrb(l_note_text || ' "' || l_notes || '"',   1,   2000);
        END IF;

        BEGIN
          ---------------------------------------------------------------------------
          l_debug_mesg := 'Insert call topic notes';
          ---------------------------------------------------------------------------

          arp_global.init_global;

          l_created_by := fnd_global.user_id;
          l_creation_date := sysdate;
          l_last_update_login := arp_global.last_update_login;
          l_last_update_date := sysdate;
          l_last_updated_by := fnd_global.user_id;
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: Before calling arp_notes_pkg.insert_cover');
	  END IF;
          arp_notes_pkg.insert_cover(
		p_note_type              => 'MAINTAIN',
		p_text                   => l_note_text,
		p_customer_call_id       => null,
		p_customer_call_topic_id => null,
		p_call_action_id         => NULL,
		p_customer_trx_id        => l_customer_trx_id,
		p_note_id                => l_note_id,
		p_last_updated_by        => l_last_updated_by,
		p_last_update_date       => l_last_update_date,
		p_last_update_login      => l_last_update_login,
		p_created_by             => l_created_by,
		p_creation_date          => l_creation_date);

        EXCEPTION
        WHEN others THEN
          ROLLBACK TO CANCEL_DISPUTE;
	  x_return_status := FND_API.G_RET_STS_ERROR;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
			errmsg := SQLERRM;
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
		END IF;
	  RAISE FND_API.G_EXC_ERROR;
        END;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE: After calling arp_notes_pkg.insert_cover');
        END IF;

      END;
    END IF;  --IF l_status <> wf_engine.eng_completed THEN

   -- inserting a note
	if p_cancel_comments is not null then

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   iex_debug_pub.LogMessage('CANCEL_DISPUTE: Going to build context for note...');
                END IF;

		i := 1;
		l_context_tab(i).context_type := 'IEX_DISPUTE';
		l_context_tab(i).context_id := p_dispute_id;
		i := i + 1;

		Open Get_paymentid(l_customer_trx_id);
                Fetch Get_paymentid INTO l_cust_account_id,l_payment_schedule_id;
                Close Get_paymentid;

	        Open get_partyid(l_cust_account_id);
		Fetch get_partyid INTO l_party_id;
                Close get_partyid;

		l_context_tab(i).context_type := 'PARTY';
		l_context_tab(i).context_id := l_party_id;
		i := i + 1;

		/* adding account into note context */
		l_context_tab(i).context_type := 'IEX_ACCOUNT';
		l_context_tab(i).context_id := l_cust_account_id;
		i := i + 1;

		Open Get_billto(l_customer_trx_id);
                Fetch Get_billto INTO l_customer_site_use_id;
                Close Get_billto;

		l_context_tab(i).context_type := 'IEX_BILLTO';
		l_context_tab(i).context_id := l_customer_site_use_id;
		i := i + 1;

		l_context_tab(i).context_type := 'IEX_INVOICES';
		l_context_tab(i).context_id := l_payment_schedule_id;
		i := i + 1;

		FOR i IN 1..l_context_tab.COUNT LOOP
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('CANCEL_DISPUTE: l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage('CANCEL_DISPUTE: l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
                   END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage('CANCEL_DISPUTE: Calling IEX_NOTES_PVT.Create_Note...');
                END IF;

		IEX_NOTES_PVT.Create_Note(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => 'F',
			P_COMMIT => 'F',
			P_VALIDATION_LEVEL => 100,
			X_RETURN_STATUS => l_return_status,
			X_MSG_COUNT => l_msg_count,
			X_MSG_DATA => l_msg_data,
			p_source_object_id => p_dispute_id,
			p_source_object_code => 'IEX_DISPUTE',
			p_note_type => l_default_note_type,
			--p_note_type => 'IEX_DISPUTE',
			p_notes	=> p_cancel_comments,
			p_contexts_tbl => l_context_tab,
			x_note_id => l_note_id);

		--X_PRORESP_REC.NOTE_ID := l_note_id;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage('CANCEL_DISPUTE: After call to IEX_NOTES_PVT.Create_Note');
		      iex_debug_pub.LogMessage('CANCEL_DISPUTE: Status = ' || L_RETURN_STATUS);
                END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage('CANCEL_DISPUTE: IEX_NOTES_PVT.Create_Note failed');
                        END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	else
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage('CANCEL_DISPUTE: no note to save');
        END IF;
	end if;

  END IF;  --IF l_item_type IS NOT NULL THEN

  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      x_return_status := l_return_status;
      -- Standard call to get message count and if count is 1, get message info
   	FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('**** END IEX_DISPUTE_PVT.CANCEL_DISPUTE ************');
      END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CANCEL_DISPUTE;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
			errmsg := SQLERRM;
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	WHEN others THEN
          ROLLBACK TO CANCEL_DISPUTE;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
			errmsg := SQLERRM;
			IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
		END IF;

END CANCEL_DISPUTE;

END IEX_DISPUTE_PVT ;

/
