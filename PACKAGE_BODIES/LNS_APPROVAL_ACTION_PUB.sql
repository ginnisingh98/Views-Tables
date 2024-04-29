--------------------------------------------------------
--  DDL for Package Body LNS_APPROVAL_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_APPROVAL_ACTION_PUB" AS
/* $Header: LNS_APACT_PUBP_B.pls 120.44.12010000.10 2010/05/05 13:33:47 mbolli ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_APPROVAL_ACTION_PUB';
-- G_AF_DO_DEBUG 			     VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
 g_last_all_statements		     CLOB;

--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;

PROCEDURE do_create_approval_action (
    p_approval_action_rec  IN OUT NOCOPY APPROVAL_ACTION_REC_TYPE
   ,x_action_id            OUT NOCOPY    NUMBER
   ,x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_approval_action (
    p_approval_action_rec    IN OUT NOCOPY APPROVAL_ACTION_REC_TYPE
   ,p_object_version_number  IN OUT NOCOPY NUMBER
   ,x_return_status          IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_delete_approval_action (
    p_action_id        IN NUMBER
   ,x_return_status    IN OUT NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              do_create_approval_action
 |
 | DESCRIPTION
 |              Creates approval action.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_action_id
 |              IN/OUT:
 |                    p_approval_action_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_create_approval_action(
     p_approval_action_rec    IN OUT NOCOPY APPROVAL_ACTION_REC_TYPE
    ,x_action_id                 OUT NOCOPY NUMBER
    ,x_return_status          IN OUT NOCOPY VARCHAR2
) IS

    l_action_id             NUMBER;
    l_rowid                 ROWID := NULL;
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

BEGIN
    l_action_id         := p_approval_action_rec.action_id;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_create_approval_action procedure');

    -- if primary key value is passed, check for uniqueness.
    IF l_action_id IS NOT NULL AND
        l_action_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_APPROVAL_ACTIONS
            WHERE  action_id = l_action_id;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'action_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_approval_action procedure: Before call to LNS_APPROVAL_ACTIONS_PKG.Insert_Row');

    -- call table-handler.
    LNS_APPROVAL_ACTIONS_PKG.Insert_Row(X_ACTION_ID		          => p_approval_action_rec.action_id
																			 ,P_OBJECT_VERSION_NUMBER	=> 1
																			 ,P_LOAN_ID               => p_approval_action_rec.loan_id
																			 ,P_ACTION_TYPE           => p_approval_action_rec.action_type
																			 ,P_AMOUNT                => p_approval_action_rec.amount
																			 ,P_REASON_CODE           => p_approval_action_rec.reason_code
																			 ,P_ATTRIBUTE_CATEGORY    => p_approval_action_rec.attribute_category
																			 ,P_ATTRIBUTE1						=> p_approval_action_rec.attribute1
																			 ,P_ATTRIBUTE2						=> p_approval_action_rec.attribute2
																			 ,P_ATTRIBUTE3						=> p_approval_action_rec.attribute3
																			 ,P_ATTRIBUTE4						=> p_approval_action_rec.attribute4
																			 ,P_ATTRIBUTE5						=> p_approval_action_rec.attribute5
																			 ,P_ATTRIBUTE6						=> p_approval_action_rec.attribute6
																			 ,P_ATTRIBUTE7						=> p_approval_action_rec.attribute7
																			 ,P_ATTRIBUTE8						=> p_approval_action_rec.attribute8
																			 ,P_ATTRIBUTE9						=> p_approval_action_rec.attribute9
																			 ,P_ATTRIBUTE10						=> p_approval_action_rec.attribute10
																			 ,P_ATTRIBUTE11						=> p_approval_action_rec.attribute11
																			 ,P_ATTRIBUTE12						=> p_approval_action_rec.attribute12
																			 ,P_ATTRIBUTE13						=> p_approval_action_rec.attribute13
																			 ,P_ATTRIBUTE14						=> p_approval_action_rec.attribute14
																			 ,P_ATTRIBUTE15						=> p_approval_action_rec.attribute15
																			 ,P_ATTRIBUTE16						=> p_approval_action_rec.attribute16
																			 ,P_ATTRIBUTE17						=> p_approval_action_rec.attribute17
																			 ,P_ATTRIBUTE18						=> p_approval_action_rec.attribute18
																			 ,P_ATTRIBUTE19						=> p_approval_action_rec.attribute19
																			 ,P_ATTRIBUTE20						=> p_approval_action_rec.attribute20);

		x_action_id := p_approval_action_rec.action_id;

	  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_approval_action procedure: After call to LNS_APPROVAL_ACTION.Insert_Row');

END do_create_approval_action;

/*===========================================================================+
 | PROCEDURE
 |              do_update_approval_action
 |
 | DESCRIPTION
 |              Updates approval action.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_approval_action_rec
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_update_approval_action(
     p_approval_action_rec     IN OUT NOCOPY APPROVAL_ACTION_REC_TYPE
    ,p_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status           IN OUT NOCOPY VARCHAR2) IS

    l_object_version_number         NUMBER;
    l_rowid                         ROWID;
    ldup_rowid                      ROWID;

BEGIN

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_update_approval_action procedure');

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   LNS_APPROVAL_ACTIONS
        WHERE  ACTION_ID = p_approval_action_rec.action_id
        FOR UPDATE OF ACTION_ID NOWAIT;

        IF NOT
            (
             (p_object_version_number IS NULL AND l_object_version_number IS NULL)
             OR
             (p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_approval_actions');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'approval action_rec');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_approval_action_rec.action_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_approval_action procedure: Before call to LNS_APPROVAL_ACTIONS_PKG.Update_Row');

        -- log history
    LNS_LOAN_HISTORY_PUB.log_record_pre(p_approval_action_rec.action_id,
					'ACTION_ID',
					'LNS_APPROVAL_ACTIONS');

    --Call to table-handler
    LNS_APPROVAL_ACTIONS_PKG.Update_Row (X_ACTION_ID		          => p_approval_action_rec.action_id
																			  ,P_OBJECT_VERSION_NUMBER	=> p_OBJECT_VERSION_NUMBER
                                        ,P_LOAN_ID                => p_approval_action_rec.LOAN_ID
                                        ,P_ACTION_TYPE            => p_approval_action_rec.ACTION_TYPE
                                        ,P_AMOUNT                 => p_approval_action_rec.AMOUNT
                                        ,P_REASON_CODE            => p_approval_action_rec.REASON_CODE
                                        ,P_ATTRIBUTE_CATEGORY     => p_approval_action_rec.attribute_category
                                        ,P_ATTRIBUTE1             => p_approval_action_rec.attribute1
                                        ,P_ATTRIBUTE2             => p_approval_action_rec.attribute2
                                        ,P_ATTRIBUTE3             => p_approval_action_rec.attribute3
                                        ,P_ATTRIBUTE4             => p_approval_action_rec.attribute4
                                        ,P_ATTRIBUTE5             => p_approval_action_rec.attribute5
                                        ,P_ATTRIBUTE6             => p_approval_action_rec.attribute6
                                        ,P_ATTRIBUTE7             => p_approval_action_rec.attribute7
                                        ,P_ATTRIBUTE8             => p_approval_action_rec.attribute8
                                        ,P_ATTRIBUTE9             => p_approval_action_rec.attribute9
                                        ,P_ATTRIBUTE10            => p_approval_action_rec.attribute10
                                        ,P_ATTRIBUTE11            => p_approval_action_rec.attribute11
                                        ,P_ATTRIBUTE12            => p_approval_action_rec.attribute12
                                        ,P_ATTRIBUTE13            => p_approval_action_rec.attribute13
                                        ,P_ATTRIBUTE14            => p_approval_action_rec.attribute14
                                        ,P_ATTRIBUTE15            => p_approval_action_rec.attribute15
                                        ,P_ATTRIBUTE16            => p_approval_action_rec.attribute16
                                        ,P_ATTRIBUTE17            => p_approval_action_rec.attribute17
                                        ,P_ATTRIBUTE18            => p_approval_action_rec.attribute18
                                        ,P_ATTRIBUTE19            => p_approval_action_rec.attribute19
                                        ,P_ATTRIBUTE20            => p_approval_action_rec.attribute20);


    -- log record changes
    LNS_LOAN_HISTORY_PUB.log_record_post(p_approval_action_rec.action_id,
					'ACTION_ID',
					'LNS_APPROVAL_ACTIONS',
					p_approval_action_rec.loan_id);

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_approval_action procedure: After call to LNS_APPROVAL_ACTIONS_PKG.Update_Row');

END do_update_approval_action;

/*===========================================================================+
 | PROCEDURE
 |              do_delete_approval_action
 |
 | DESCRIPTION
 |              Deletes approval action.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_action_id
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_delete_approval_action(
    p_action_id           NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_dummy                 VARCHAR2(1);
BEGIN

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_delete_approval_action procedure');

    IF p_action_id IS NOT NULL AND
      p_action_id <> FND_API.G_MISS_NUM
    THEN
    -- check whether record has been deleted by another user. If not, lock it.
      BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   LNS_APPROVAL_ACTIONS
        WHERE  ACTION_ID = p_action_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'approval action_rec');
          FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_action_id), 'null'));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_approval_action procedure: Before call to LNS_APPROVAL_ACTIONS_PKG.Delete_Row');

    --Call to table-handler
    LNS_APPROVAL_ACTIONS_PKG.Delete_Row (P_ACTION_ID  => p_action_id);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_approval_action procedure: After call to LNS_APPROVAL_ACTIONS_PKG.Delete_Row');

END do_delete_approval_action;

PROCEDURE validate_loan (
       p_approval_action_rec   APPROVAL_ACTION_REC_TYPE
      ,x_return_status  IN OUT NOCOPY VARCHAR2) IS
	l_install_number	NUMBER;
	l_dummy			VARCHAR2(1);

	CURSOR C_Check_Fee_Violation (X_Loan_Id NUMBER, X_Install_Num NUMBER) IS
	SELECT 'X'
	FROM LNS_FEE_ASSIGNMENTS
	WHERE loan_id = X_LOAN_ID
	AND end_installment_number > x_install_num;

BEGIN

	IF (p_approval_action_rec.action_type in ('SUBMIT_FOR_APPR', 'APPROVE'))	THEN
	  l_install_number := LNS_FIN_UTILS.GETNUMBERINSTALLMENTS(p_approval_action_rec.loan_id);
	  OPEN C_Check_Fee_Violation (p_approval_action_rec.loan_id, l_install_number);
	  FETCH C_Check_Fee_Violation INTO l_dummy;
	  IF C_Check_Fee_Violation%FOUND THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
	        FND_MESSAGE.SET_NAME('LNS', 'LNS_NEGATIVE_NUMBER_ERROR');
		FND_MSG_PUB.ADD;
		CLOSE C_Check_Fee_Violation;
		RAISE FND_API.G_EXC_ERROR;

	  END IF;
	  CLOSE C_Check_Fee_Violation;
	END IF;

END validate_loan;

----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_approval_action
 |
 | DESCRIPTION
 |              Creates approval action.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_approval_action_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_action_id
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-Jan-2004     Bernice Lam       Created.
 |   18-JUL-2007     MBOLLI	       Bug#6169438 - Added new paramter to the API shiftLoanDates .
 +===========================================================================*/
PROCEDURE create_approval_action (p_init_msg_list       IN  VARCHAR2
															   ,p_approval_action_rec IN  APPROVAL_ACTION_REC_TYPE
															   ,x_action_id           OUT NOCOPY     NUMBER
															   ,x_return_status       OUT NOCOPY     VARCHAR2
															   ,x_msg_count           OUT NOCOPY     NUMBER
															   ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'create_approval_action';
    l_approval_action_rec   APPROVAL_ACTION_REC_TYPE;
    l_loan_header_rec       LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
    l_object_version_number	NUMBER;
    l_resource_id           NUMBER;
    l_status                VARCHAR2(30);
    l_currency_code         VARCHAR2(15);
    l_loan_number           VARCHAR2(60);
    l_loan_class_code		    VARCHAR2(30);
    l_loan_type             VARCHAR2(30);
    l_gl_date               DATE;
    l_distribution_id       NUMBER;
    l_code_comb_id          NUMBER;
    l_index                 NUMBER := 1;
    l_percent               NUMBER;
    l_group_id              number;
    l_requested_amt         NUMBER;
    l_submit_request_id	    NUMBER;
    l_reference_type	      VARCHAR2(30);
    l_reference_id          NUMBER;
    l_cust_trx_id           NUMBER;
    l_invoice_amt           NUMBER;
    l_funding_advice_id	    NUMBER;
    l_request_id            number;
    l_notify                boolean;
    l_legal_entity_id       number;
    l_current_phase         varchar2(30);
    l_multiple_funding_flag varchar2(1);
    l_open_to_term_flag     varchar2(1);
    l_budget_req_approval   varchar2(1);
    l_loan_needs_approval   varchar2(1);
    l_term_rec              lns_terms_pub.loan_term_rec_type;
    l_loan_details          lns_financials.loan_details_rec; --used for shiftloandates api
    l_term_id               number;
    l_term_version_number   number;
    -- for xla accounting events
    l_budgetary_status      varchar2(30);
    l_last_api_called       varchar2(500); --Store the last api that was called before exception
	l_secondary_status      varchar2(30);
	l_prev_sec_status       varchar2(30);
	l_prev_loan_status      varchar2(30);
    l_xml_output            BOOLEAN;
    l_iso_language          FND_LANGUAGES.iso_language%TYPE;
    l_iso_territory         FND_LANGUAGES.iso_territory%TYPE;
    l_dates_shifted_flag    VARCHAR2(1);
    --Bug 6938125 - FP:11i-R12:ENHANCEMENTS TO CUSTOM AMORTIZATION SCHEDULE
    l_customized            varchar2(1);
    l_offset                        number(38);
    l_statement_xml                 clob;
    x_billed_yn             varchar2(1);
    l_fee_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);


    CURSOR C_Get_Loan_Info (X_Loan_Id NUMBER) IS
    SELECT H.OBJECT_VERSION_NUMBER
          ,H.LOAN_STATUS
          ,H.LOAN_CURRENCY
          ,H.LOAN_NUMBER
          ,H.LOAN_CLASS_CODE
          ,H.LOAN_TYPE
          ,H.GL_DATE
          ,H.REQUESTED_AMOUNT
          ,H.REFERENCE_TYPE
          ,H.REFERENCE_ID
          ,H.CURRENT_PHASE
          ,H.MULTIPLE_FUNDING_FLAG
          ,H.OPEN_TO_TERM_FLAG
          ,NVL(P.BDGT_REQ_FOR_APPR_FLAG, 'N') BDGT_REQ_FOR_APPR_FLAG
          ,NVL(P.LOAN_APPR_REQ_FLAG, 'Y') LOAN_APPR_REQ_FLAG
		  ,H.SECONDARY_STATUS
          ,nvl(custom_payments_flag, 'N')
    FROM LNS_LOAN_HEADERS_ALL H,
	LNS_LOAN_PRODUCTS_ALL P
    WHERE H.LOAN_ID = X_Loan_Id
      and H.product_id = P.loan_product_id(+);

    CURSOR C_Get_Resource_Id (X_User_Id NUMBER) IS
    SELECT RESOURCE_ID
      FROM JTF_RS_RESOURCE_EXTNS
     WHERE USER_ID = X_USER_ID;

    CURSOR C_Get_Distribution (X_Loan_Id NUMBER, X_Acct_Type VARCHAR2, X_Acct_Name VARCHAR2, X_Line_Type VARCHAR2) IS
    select DISTRIBUTION_ID
          ,CODE_COMBINATION_ID
          ,DISTRIBUTION_PERCENT
      from lns_distributions
     where LOAN_ID = x_loan_id
       and account_type = x_acct_type
       and account_name = x_acct_name
       and line_type = x_line_type
       and distribution_type = 'ORIGINATION';

    cursor c_sob_id is
    select so.set_of_books_id
      from lns_system_options sb,
           gl_sets_of_books so
     where sb.set_of_books_id = so.set_of_books_id;

    /* query term version */
    CURSOR term_version_cur(P_LOAN_ID number) IS
        select TERM_ID
              ,OBJECT_VERSION_NUMBER
        from LNS_TERMS
        where LOAN_ID = P_LOAN_ID;

    CURSOR loan_version_cur(P_LOAN_ID number) IS
    select OBJECT_VERSION_NUMBER
      from LNS_LOAN_HEADERS
     where LOAN_ID = P_LOAN_ID;

    -- getting loan previous secondary status to reset if Conversion request is rejected
    CURSOR prev_sec_status_cur(P_LOAN_ID number) IS
        select old_value
        from lns_loan_histories_h
        where table_name = 'LNS_LOAN_HEADERS_ALL' and
            column_name = 'SECONDARY_STATUS' and
            new_value = 'PENDING_CANCELLATION' and
            loan_id = P_LOAN_ID and
            loan_history_id =
                (select max(loan_history_id)
                from lns_loan_histories_h
                where table_name = 'LNS_LOAN_HEADERS_ALL' and
                column_name = 'SECONDARY_STATUS' and
                loan_id = P_LOAN_ID);

    /* get statement after its billed */
    CURSOR get_statement_cur(P_LOAN_ID number) IS
        select STATEMENT_XML
        from LNS_LOAN_HEADERS loan,
        lns_amortization_scheds am
        where loan.loan_id = am.loan_id	and
        am.AMORTIZATION_SCHEDULE_ID = loan.LAST_AMORTIZATION_ID	and
        am.PAYMENT_NUMBER = loan.LAST_PAYMENT_NUMBER and
        loan.loan_id = P_LOAN_ID;

BEGIN
    l_last_api_called := '';
    l_approval_action_rec  := p_approval_action_rec;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Begin');

    -- standard start of API savepoint
    SAVEPOINT create_approval_action;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- START OF BODY OF API
    /* init all_statements clob */
    dbms_lob.createtemporary(g_last_all_statements, FALSE, DBMS_LOB.CALL);
    dbms_lob.open(g_last_all_statements, dbms_lob.lob_readwrite);

    -- init;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to do_create_approval_action proc');

    -- call to business logic.
    do_create_approval_action(l_approval_action_rec
                             ,x_action_id
                             ,x_return_status);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After call to do_create_approval_action proc');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to LNS_LOAN_HEADER_PUB.update_loan proc');

    OPEN C_Get_Loan_Info(l_approval_action_rec.loan_id);
    FETCH C_Get_Loan_Info
     INTO l_object_version_number
         ,l_status
         ,l_currency_code
         ,l_loan_number
         ,l_loan_class_code
         ,l_loan_type
         ,l_gl_date
         ,l_requested_amt
         ,l_reference_type
         ,l_reference_id
         ,l_current_phase
         ,l_multiple_funding_flag
         ,l_open_to_term_flag
         ,l_budget_req_approval
         ,l_loan_needs_approval
		 ,l_secondary_status
		 ,l_customized;
    IF C_Get_Loan_Info%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'loan header');
      FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(l_loan_header_rec.loan_id), 'null'));
      FND_MSG_PUB.ADD;
      CLOSE C_Get_Loan_Info;
      l_last_api_called := 'C_Get_Loan_Info';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE C_Get_Loan_Info;
	l_prev_loan_status := l_status;

    OPEN C_Get_Resource_Id(LNS_UTILITY_PUB.Created_By);
    FETCH C_Get_Resource_Id INTO l_resource_id;
    CLOSE C_Get_Resource_Id;

    -- validate status transitions
    l_loan_header_rec.loan_id := l_approval_action_rec.loan_id;
    IF (l_approval_action_rec.action_type = 'SUBMIT_FOR_APPR') THEN
       IF l_status = 'INCOMPLETE' THEN
            l_loan_header_rec.loan_status := 'PENDING';
            l_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;

	    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to generate bill for SubmtForApproval Fee');

	    LNS_BILLING_BATCH_PUB.BILL_SING_LOAN_SUBMIT_APPR_FEE(P_API_VERSION      => 1.0
							     ,P_INIT_MSG_LIST    => FND_API.G_TRUE
						             ,P_COMMIT           => FND_API.G_FALSE
							     ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
							     ,P_LOAN_ID          => l_approval_action_rec.loan_id
                                                             ,X_BILLED_YN        => x_billed_yn
							     ,X_RETURN_STATUS    => x_return_status
							     ,X_MSG_COUNT        => x_msg_count
							     ,X_MSG_DATA         => x_msg_data);

	    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to LNS_BILLING_BATCH_PUB.BILL_SUBMIT_APPROVAL_FEE failed with status ' || x_return_status);
		l_last_api_called := 'LNS_BILLING_BATCH_PUB.BILL_SUBMIT_APPROVAL_FEE';
		RAISE FND_API.G_EXC_ERROR;

	    ELSE
                /* get statement after its billed */
                open get_statement_cur(l_approval_action_rec.loan_id);
                fetch get_statement_cur into l_statement_xml;
                close get_statement_cur;

                IF (l_statement_xml IS NULL)  THEN
                 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'There is no xml for Bill Statement');
                ELSE
                  /* remove xml header */
                  l_offset := DBMS_LOB.INSTR(lob_loc => l_statement_xml,
                                          pattern => '>',
                                          offset => 1,
                                          nth => 1);
                  LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Have removed header from the statement');
                  dbms_lob.Append(g_last_all_statements, l_statement_xml);
                END IF;

	    END IF;

       ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('VALUE', l_status);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
	   END IF;

    ELSIF (l_approval_action_rec.action_type = 'SUBMIT_FOR_CONV') THEN
		IF (l_status = 'ACTIVE' AND l_current_phase = 'OPEN' AND l_multiple_funding_flag = 'Y' AND l_open_to_term_flag = 'Y') THEN
             l_loan_header_rec.secondary_status := 'PENDING_CONVERSION';
		ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('VALUE', l_status);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
		END IF;

    ELSIF (l_approval_action_rec.action_type = 'SUBMIT_FOR_CNCL') THEN
		IF (l_loan_class_code = 'DIRECT') THEN
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to LNS_FUNDING_PUB.CANCEL_DISB_SCHEDULE');

            LNS_FUNDING_PUB.CANCEL_DISB_SCHEDULE(P_API_VERSION      =>  1.0
								        ,P_INIT_MSG_LIST    => FND_API.G_TRUE
								        ,P_COMMIT           => FND_API.G_FALSE
								        ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
								        ,P_LOAN_ID          => l_loan_header_rec.loan_id
									,X_RETURN_STATUS    => x_return_status
									,X_MSG_COUNT        => x_msg_count
									,X_MSG_DATA         => x_msg_data);

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AFTER call to LNS_FUNDING_PUB.CANCEL_DISB_SCHEDULE');

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to LNS_FUNDING_PUB.CANCEL_DISB_SCHEDULE failed with status ' || x_return_status);
				l_last_api_called := 'LNS_FUNDING_PUB.CANCEL_DISB_SCHEDULE';
				RAISE FND_API.G_EXC_ERROR;
			END IF;
   		 ELSE
			FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
			FND_MESSAGE.SET_TOKEN('VALUE', l_status);
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		 END IF;

    ELSIF (l_approval_action_rec.action_type = 'APPROVE') THEN

       -- approval action type = 'APPROVE'
       IF ( l_status = 'PENDING' OR (l_status = 'INCOMPLETE' AND l_loan_needs_approval = 'N') ) THEN

            if l_loan_class_code = 'ERS' then

                -- use resource ID
                l_loan_header_rec.loan_approved_by := l_resource_id;
                l_loan_header_rec.loan_approval_date := sysdate;
                --if (l_gl_date is null) then
                -- CMS requirement karamach bug5129367
                l_loan_header_rec.gl_date := sysdate;
                --end if;
                l_loan_header_rec.loan_status := 'APPROVED';
                l_loan_header_rec.secondary_status := 'UNACCOUNTED'; --- raverma added new secondary status
                l_loan_header_rec.funded_amount := l_requested_amt;
                l_loan_header_rec.initial_loan_balance := l_requested_amt;

            elsif l_loan_class_code = 'DIRECT' then

                l_loan_header_rec.loan_status := 'APPROVED';
                l_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;
                -- use resource ID
                l_loan_header_rec.loan_approved_by := l_resource_id;
                l_loan_header_rec.loan_approval_date := sysdate;
                --if (l_gl_date is null) then
                -- CMS requirement karamach bug5129367
    		   l_loan_header_rec.gl_date := sysdate;
        		--end if;

            end if;

       -- approval action type = 'APPROVE'
       ELSIF l_status = 'PENDING_CANCELLATION' THEN

           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to LNS_FUNDING_PUB.APPROVE_CANCEL_REM_DISB');

            LNS_FUNDING_PUB.APPROVE_CANCEL_REM_DISB(P_API_VERSION      => 1.0
	                                                 ,P_INIT_MSG_LIST    => FND_API.G_TRUE
	                                                 ,P_COMMIT           => FND_API.G_FALSE
	                                                 ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
	                                                 ,P_LOAN_ID          => l_loan_header_rec.loan_id
	                                                 ,X_RETURN_STATUS    => x_return_status
	                                                 ,X_MSG_COUNT        => x_msg_count
	                                                 ,X_MSG_DATA         => x_msg_data);

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AFTER call to LNS_FUNDING_PUB.APPROVE_CANCEL_REM_DISB');

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to LNS_FUNDING_PUB.APPROVE_CANCEL_REM_DISB failed with status ' || x_return_status);
                l_last_api_called := 'LNS_FUNDING_PUB.APPROVE_CANCEL_REM_DISB';
                RAISE FND_API.G_EXC_ERROR;
            END IF;

       -- approval action type = 'APPROVE'
       ELSIF (l_status = 'ACTIVE' AND l_current_phase = 'OPEN' AND l_multiple_funding_flag = 'Y' AND l_open_to_term_flag = 'Y') THEN

            /**********************Begin Permanent Conversion to Term Phase*************/
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calling LNS_FINANCIALS.shiftLoanDates');

						-- we are moving the loan to the TERM PHASE  -- first shift the dates based on conversion date
	        -- Bug#6169438 Added new parameter to the shiftLoanDates API Invocation
            LNS_FINANCIALS.shiftLoanDates(p_loan_id        => l_loan_header_rec.loan_id
                                         ,p_new_start_date => sysdate
                                         ,p_phase          => 'TERM'
                                         ,x_loan_details   => l_loan_details
					                     ,x_dates_shifted_flag => l_dates_shifted_flag
                                         ,x_return_status  => x_return_status
                                         ,x_msg_count      => x_msg_count
                                         ,x_msg_data       => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - LNS_FINANCIALS.shiftLoanDates failed with message: ' ||FND_MSG_PUB.Get(p_encoded => 'F'));
			        	l_last_api_called := 'LNS_FINANCIALS.shiftLoanDates';
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'New loan start date: ' || l_loan_details.loan_start_date);
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'New first payment date: ' || l_loan_details.first_payment_Date);
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'New maturity date: ' || l_loan_details.maturity_date);

            /* query term version */
            open term_version_cur(l_loan_header_rec.loan_id);
            fetch term_version_cur into l_TERM_ID, l_TERM_VERSION_NUMBER;
            close term_version_cur;

            /* setting term data for do term update */
            l_term_rec.TERM_ID := l_TERM_ID;
            l_term_rec.LOAN_ID := l_loan_header_rec.loan_id;
            l_term_rec.FIRST_PAYMENT_DATE := l_loan_details.first_payment_Date;
            l_term_rec.NEXT_PAYMENT_DUE_DATE := l_loan_details.first_payment_Date;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Updating lns_terms w following values:');
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'TERM_ID: ' || l_term_rec.TERM_ID);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LOAN_ID: ' || l_term_rec.LOAN_ID);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'FIRST_PAYMENT_DATE: ' || l_term_rec.FIRST_PAYMENT_DATE);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'NEXT_PAYMENT_DUE_DATE: ' || l_term_rec.NEXT_PAYMENT_DUE_DATE);

            LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_TERM_VERSION_NUMBER
	                                   ,p_init_msg_list 				=> FND_API.G_FALSE
	                                   ,p_loan_term_rec 				=> l_term_rec
	                                   ,X_RETURN_STATUS 				=> x_return_status
	                                   ,X_MSG_COUNT 						=> x_msg_count
	                                   ,X_MSG_DATA 							=> x_msg_data);

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'x_return_status: ' || x_return_status);

            IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Successfully update LNS_TERMS');
            ELSE
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_TERM_FAIL');
                FND_MSG_PUB.Add;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - LNS_TERMS_PUB.update_term failed with message: ' || FND_MSG_PUB.Get(p_encoded => 'F'));
                l_last_api_called := 'LNS_TERMS_PUB.update_term';
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            /* setting data for future loan update */
            l_loan_header_rec.LOAN_START_DATE       := l_loan_details.loan_start_date;
            l_loan_header_rec.LOAN_MATURITY_DATE    := l_loan_details.maturity_date;
            l_loan_header_rec.current_phase         := 'TERM';
            l_loan_header_rec.secondary_status      := 'CONVERTED_TO_TERM_PHASE';
            l_loan_header_rec.LAST_PAYMENT_NUMBER   := FND_API.G_MISS_NUM;
            l_loan_header_rec.LAST_AMORTIZATION_ID  := FND_API.G_MISS_NUM;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Data to Update loan header with during conversion...');
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'loan_id: ' || l_loan_header_rec.loan_id);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LOAN_START_DATE: ' || l_loan_header_rec.LOAN_START_DATE);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LOAN_MATURITY_DATE: ' || l_loan_header_rec.LOAN_MATURITY_DATE);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'current_phase: ' || l_loan_header_rec.current_phase);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'secondary_status: ' || l_loan_header_rec.secondary_status);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LAST_PAYMENT_NUMBER: ' || l_loan_header_rec.LAST_PAYMENT_NUMBER);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LAST_AMORTIZATION_ID: ' || l_loan_header_rec.LAST_AMORTIZATION_ID);

	     /* Bug#9255294 - No need to call this now, as the below method inserts records of conversionFees into feeSchds table
	       However, now the conversionFees insert into feeScheds when this fee is assigned to the loan

            --Process Conversion Fees
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Before calling lns_fee_engine.processDisbursementFees to process Conversion fees for permanent conversion to TERM phase');
            lns_fee_engine.processDisbursementFees(p_init_msg_list     => FND_API.G_TRUE
                                                ,p_commit            => FND_API.G_FALSE
                                                ,p_phase             => 'TERM'
                                                ,p_loan_id           => l_loan_header_rec.loan_id
                                                ,p_disb_head_id      => NULL
                                                ,x_return_status     => x_return_status
                                                ,x_msg_count         => x_msg_count
                                                ,x_msg_data          => x_msg_data);

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - lns_fee_engine.processDisbursementFees to process Conversion fees for permanent conversion to TERM phase');

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - lns_fee_engine.processDisbursementFees to process Conversion fees for TERM phase failed with message: ' ||FND_MSG_PUB.Get(p_encoded => 'F'));
			        	l_last_api_called := 'lns_fee_engine.processDisbursementFees';
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	  */
            /**********************End Permanent Conversion to Term Phase*************/

       ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('VALUE', l_status);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSIF (l_approval_action_rec.action_type = 'REJECT') THEN
       IF ( l_status = 'PENDING' OR (l_status = 'INCOMPLETE' AND l_loan_needs_approval = 'N') ) THEN
            l_loan_header_rec.loan_status := 'REJECTED';
            l_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;
       ELSIF (l_status = 'PENDING_CANCELLATION') THEN
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to LNS_FUNDING_PUB.REJECT_CANCEL_DISB');

            LNS_FUNDING_PUB.REJECT_CANCEL_DISB(P_API_VERSION      => 1.0
                                              ,P_INIT_MSG_LIST    => FND_API.G_TRUE
                                              ,P_COMMIT           => FND_API.G_FALSE
                                              ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
                                              ,P_LOAN_ID          => l_loan_header_rec.loan_id
                                              ,X_RETURN_STATUS    => x_return_status
                                              ,X_MSG_COUNT        => x_msg_count
                                              ,X_MSG_DATA         => x_msg_data);

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AFTER call to LNS_FUNDING_PUB.REJECT_CANCEL_DISB');

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - LNS_FUNDING_PUB.REJECT_CANCEL_DISB failed with status ' || x_return_status);
							l_last_api_called := 'LNS_FUNDING_PUB.REJECT_CANCEL_DISB';
							RAISE FND_API.G_EXC_ERROR;
						END IF;
       ELSIF (l_status = 'ACTIVE' and l_secondary_status = 'PENDING_CONVERSION') THEN
		    -- getting loan previous status
		    open prev_sec_status_cur(l_loan_header_rec.loan_id);
		    fetch prev_sec_status_cur into l_prev_sec_status;
		    close prev_sec_status_cur;
			l_loan_header_rec.secondary_status := nvl(l_prev_sec_status,FND_API.G_MISS_CHAR);
       ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('VALUE', l_status);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSIF (l_approval_action_rec.action_type = 'REQUEST_FOR_INFO') THEN

       IF (l_status = 'INCOMPLETE' AND l_loan_needs_approval = 'N') THEN
            --Loan is already in INCOMPLETE status, so do nothing
            null;
       ELSIF l_status = 'PENDING' THEN
            l_loan_header_rec.loan_status := 'INCOMPLETE';

            /* Bug#8937530get Billed and Reversed 'Submit For Approval' Fees  using getSubmitForApprFeeSchedule*/
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling Billed LNS_FEES_ENGINE.getSubmitForApprFeeSchedule...');

            LNS_FEE_ENGINE.getSubmitForApprFeeSchedule(p_init_msg_list => FND_API.G_TRUE,
                    p_loan_Id => l_approval_action_rec.loan_id,
                    p_billed_flag => 'Y',
                    x_fees_tbl => l_fee_tbl,
                    X_RETURN_STATUS => l_return_status,
                    X_MSG_COUNT => l_msg_count,
                    X_MSG_DATA => l_msg_data);

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || l_return_status);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_msg_data: ' || substr(l_msg_data,1,225));

            if l_return_status <> 'S' then
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Failed in API LNS_FEES_ENGINE.getSubmitForApprFeeSchedule');
                RAISE FND_API.G_EXC_ERROR;
            end if;

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Toal No. of Eligible Billed and Reversed SubmitApproval Fees are: ' || l_fee_tbl.count);

            FOR l_Count IN 1..l_fee_tbl.count LOOP
                LNS_FEE_SCHEDULES_PKG.UPDATE_ROW(P_FEE_SCHEDULE_ID       => l_fee_tbl(l_Count).fee_schedule_id
                                                ,P_FEE_ID                   			=> null
                                                ,P_LOAN_ID               			=> l_approval_action_rec.loan_id
                                                ,P_FEE_AMOUNT            			=> null
                                                ,P_FEE_INSTALLMENT       		=> null
                                                ,P_FEE_DESCRIPTION       		=> null
                                                ,P_ACTIVE_FLAG           			=> null
                                                ,P_BILLED_FLAG          			=> 'N'  -- Make BilledFlag to 'N'
                                                ,P_FEE_WAIVABLE_FLAG     		=> null
                                                ,P_WAIVED_AMOUNT        		=> null
                                                ,P_LAST_UPDATED_BY       		=> LNS_UTILITY_PUB.LAST_UPDATED_BY
                                                ,P_LAST_UPDATE_DATE     		=> LNS_UTILITY_PUB.LAST_UPDATE_DATE
                                                ,P_LAST_UPDATE_LOGIN     		=> LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
                                                ,P_PROGRAM_ID            			=> null
                                                ,P_REQUEST_ID            		   	=> null
                                                ,P_OBJECT_VERSION_NUMBER 	=> null);
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' fee_schedule_id : '|| l_fee_tbl(l_Count).fee_schedule_id||' updated succesfully ');

            END LOOP;
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Toal No. of Billed and Reversed SubmitApproval Fees are: ' || l_fee_tbl.count);

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Uncompleting all custom conditions...');
            update LNS_COND_ASSIGNMENTS
            set CONDITION_MET_FLAG = 'N',
                FULFILLMENT_DATE = null,
                FULFILLMENT_UPDATED_BY = null
            where LOAN_ID = l_approval_action_rec.loan_id
                and OWNER_OBJECT_ID is null
                and OWNER_TABLE is null
                and end_date_active is null
                and CONDITION_ID in
                    (select CONDITION_ID
                    from LNS_CONDITIONS
                    where CONDITION_TYPE = 'APPROVAL'
                    and CUSTOM_PROCEDURE is not null);
            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');


       ELSIF (l_status = 'PENDING_CANCELLATION') THEN
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to LNS_FUNDING_PUB.REJECT_CANCEL_DISB');

            LNS_FUNDING_PUB.REJECT_CANCEL_DISB(P_API_VERSION      => 1.0
                                              ,P_INIT_MSG_LIST    => FND_API.G_TRUE
                                              ,P_COMMIT           => FND_API.G_FALSE
                                              ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
                                              ,P_LOAN_ID          => l_loan_header_rec.loan_id
                                              ,X_RETURN_STATUS    => x_return_status
                                              ,X_MSG_COUNT        => x_msg_count
                                              ,X_MSG_DATA         => x_msg_data);

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AFTER call to LNS_FUNDING_PUB.REJECT_CANCEL_DISB');

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to LNS_FUNDING_PUB.REJECT_CANCEL_DISB failed with status ' || x_return_status);
              l_last_api_called := 'LNS_FUNDING_PUB.REJECT_CANCEL_DISB';
              RAISE FND_API.G_EXC_ERROR;
            END IF;

       --Loan Status change is already handled in the above procedure call. no need to update loan header again
       ELSIF l_status = 'ACTIVE' then
           if l_current_phase = 'OPEN' AND l_multiple_funding_flag = 'Y' AND l_open_to_term_flag = 'Y' THEN
             l_loan_header_rec.secondary_status := 'MORE_INFO_REQUESTED';
           end if;
       ELSE
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('VALUE', l_status);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    /* 08-12-2005 raverma added defaultDistributions call for DIRECT loan */
    --Question for Raj:
    --Do we need to check for l_prev_loan_status = 'PENDING' to call code below on initial loan approval only?
    IF (l_approval_action_rec.action_type = 'APPROVE' and
       (l_loan_header_rec.loan_status = 'ACTIVE' or l_loan_header_rec.loan_status = 'APPROVED') and
       l_loan_class_code = 'DIRECT')
    THEN

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - before default distributions');
        Lns_distributions_pub.defaultDistributions(p_api_version     => 1.0
                                                ,p_init_msg_list   => FND_API.G_TRUE
                                                ,p_commit          => FND_API.G_FALSE
                                                ,p_loan_id         => l_loan_header_rec.loan_id
                                                ,p_loan_class_code => l_loan_class_code
                                                ,x_return_status   => x_return_status
                                                ,x_msg_count       => x_msg_count
                                                ,x_msg_data        => x_msg_data);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after default distributions ' || x_return_status);

	-- Bug#9685116 - Only for federal customers, it should do the budgetary_control
	IF (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y') THEN
		begin
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'calling lns_distributions_pub.budgetary_control');
		lns_distributions_pub.budgetary_control(p_init_msg_list          => FND_API.G_FALSE
							,p_commit                 => FND_API.G_FALSE
							,p_loan_id                => l_approval_action_rec.loan_id
							,p_budgetary_control_mode => 'R'
							,x_budgetary_status_code  => l_budgetary_status
							,x_return_status          => x_return_status
							,x_msg_count              => x_msg_count
							,x_msg_data               => x_msg_data);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to Lns_distributions_pub.budgetary_control return status ' || x_return_status);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'l_budgetary_status' || l_budgetary_status);
		--FND_MSG_PUB.initialize;
		if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

			RAISE FND_API.G_EXC_ERROR;

		else  -- BC Call Returned 'S'
			if l_budgetary_status = 'ADVISORY' or l_budgetary_status = 'SUCCESS' then
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'budget reserved');
			l_loan_header_rec.secondary_status := 'BUDGET_RESERVED';

			elsif  l_budgetary_status = 'FAIL' or l_budgetary_status = 'PARTIAL' or l_budgetary_status = 'XLA_ERROR' then
			if l_budget_req_approval = 'Y' then
			-- continue as if nothing happen
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'budget required: NO BUDGET');
			RAISE FND_API.G_EXC_ERROR;
			else
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'NO BUDGET');
			FND_MSG_PUB.initialize;
			l_loan_header_rec.secondary_status := 'NO_BUDGET';
			end if;

			end if;

		end if;
		end;
	END IF; 	-- if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y')

    END IF;

    --if loan status is cancelled, the funding api to cancel remaining disbursements would have updated loan header already no need to do it again

    IF (l_approval_action_rec.action_type = 'APPROVE' and l_loan_header_rec.loan_status = 'APPROVED' and l_loan_header_rec.secondary_status = 'UNACCOUNTED' and l_loan_class_code = 'ERS') THEN

        -- fix for bug 6133313: if this loan is customized then set ORIG_PAY_CALC_METHOD to null
        if l_customized = 'Y' then

            -- getting terms version for future update
            select term_id, object_version_number into l_term_id, l_object_version_number
            from lns_terms
            where loan_id = l_loan_header_rec.loan_id;

            -- Updating terms
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_terms...');
            END IF;

            l_term_rec.TERM_ID := l_term_id;
            l_term_rec.LOAN_ID := l_loan_header_rec.loan_id;
            l_term_rec.ORIG_PAY_CALC_METHOD := FND_API.G_MISS_CHAR;

            LNS_TERMS_PUB.update_term(P_OBJECT_VERSION_NUMBER => l_object_version_number,
                                    p_init_msg_list => FND_API.G_FALSE,
                                    p_loan_term_rec => l_term_rec,
                                    X_RETURN_STATUS => x_return_status,
                                    X_MSG_COUNT => x_msg_count,
                                    X_MSG_DATA => x_msg_data);


            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || x_return_status);
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully update LNS_TERMS');
            END IF;

        end if;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to submit adjustment request');
        if (x_return_status = FND_API.G_RET_STS_SUCCESS) then

            LNS_BILLING_BATCH_PUB.ADJUST_ORIGINAL_RECEIVABLE(P_API_VERSION      => 1.0
                                                        ,P_INIT_MSG_LIST    => FND_API.G_TRUE
                                                        ,P_COMMIT           => FND_API.G_FALSE
                                                        ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
                                                        ,P_LOAN_ID          => l_loan_header_rec.loan_id
                                                        ,X_RETURN_STATUS    => x_return_status
                                                        ,X_MSG_COUNT        => x_msg_count
                                                        ,X_MSG_DATA         => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Call to LNS_BILLING_BATCH_PUB.ADJUST_ORIGINAL_RECEIVABLE failed with status ' || x_return_status);
                l_last_api_called := 'LNS_BILLING_BATCH_PUB.ADJUST_ORIGINAL_RECEIVABLE';
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        end if;

        if (x_return_status = FND_API.G_RET_STS_SUCCESS) then

            -- moved the defaultDistributions call to Concurrent Process
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before call to submit gen distributions request');
            l_notify := FND_REQUEST.ADD_NOTIFICATION(FND_GLOBAL.USER_NAME);
            --call fnd_request_api....
            FND_REQUEST.SET_ORG_ID(MO_GLOBAL.GET_CURRENT_ORG_ID());
            l_request_id := FND_REQUEST.SUBMIT_REQUEST('LNS'
                                                        ,'LNS_GEN_DIST'
                                                        ,'', '', FALSE
                                                        ,l_loan_header_rec.loan_id);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after call to submit gen distributions request ' || l_request_id);

        end if; --END if (x_return_status = FND_API.G_RET_STS_SUCCESS) then

    END IF; -- END IF (l_approval_action_rec.action_type = 'APPROVE' and l_loan_header_rec.loan_status = 'ACTIVE' and l_loan_class_code = 'ERS') THEN

    if (x_return_status = FND_API.G_RET_STS_SUCCESS AND
        l_approval_action_rec.action_type = 'APPROVE' and
        (l_loan_header_rec.loan_status = 'ACTIVE' or l_loan_header_rec.loan_status = 'APPROVED')) then

            -- generate Loan Agreement Report
            l_last_api_called := 'LNS_REP_UTILS.STORE_LOAN_AGREEMENT';
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Before call to LNS_REP_UTILS.STORE_LOAN_AGREEMENT');
            LNS_REP_UTILS.STORE_LOAN_AGREEMENT(l_loan_header_rec.loan_id);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'After call to LNS_REP_UTILS.STORE_LOAN_AGREEMENT');
/*
            -- begin submit request to generate Loan Agreement Report
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Before calling FND_REQUEST.SUBMIT_REQUEST for LNS_AGREEMENT (Loan Agreement Report) for loan_id: ' || l_loan_header_rec.loan_id);
            l_notify := FND_REQUEST.ADD_NOTIFICATION(FND_GLOBAL.USER_NAME);
            FND_REQUEST.SET_ORG_ID(MO_GLOBAL.GET_CURRENT_ORG_ID());
            -- Bug#5936252 : Invoke the function add_layout to specify the template type,code etc., before submitting request
            SELECT
              lower(iso_language),iso_territory
            INTO
              l_iso_language,l_iso_territory
            FROM
              FND_LANGUAGES
            WHERE
              language_code = USERENV('LANG');


            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Before calling FND_REQUEST.ADD_LAYOUT for LNS_AGREEMENT (Loan Agreement Report) for loan_id: ' || l_loan_header_rec.loan_id);

            l_xml_output:=  fnd_request.add_layout(
      			      template_appl_name  => 'LNS',
		              template_code       => 'LNSRPTAG',
	  	              template_language   => l_iso_language,
		              template_territory  => l_iso_territory,
		              output_format       => 'PDF'
		            );
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' After calling FND_REQUEST.ADD_LAYOUT for LNS_AGREEMENT (Loan Agreement Report) for loan_id: ' || l_loan_header_rec.loan_id);


            l_request_id := FND_REQUEST.SUBMIT_REQUEST('LNS'
                                                      ,'LNS_AGREEMENT'
                                                      ,'', '', FALSE
                                                      ,l_loan_header_rec.loan_id);

            if l_request_id = 0 then
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_AGREEMENT_REQUEST_FAILED');
                    FND_MSG_PUB.Add;
                    l_last_api_called := 'FND_REQUEST.SUBMIT_REQUEST for Loan Agreement Report Generation';
                    RAISE FND_API.G_EXC_ERROR;
            else
                    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Successfully submited Loan Agreement Report Generation Concurrent Program. Request id: ' || l_request_id);
            end if;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' After calling FND_REQUEST.SUBMIT_REQUEST for LNS_AGREEMENT (Loan Agreement Report) for loan_id: ' || l_loan_header_rec.loan_id);
            -- end submit request to generate Loan Agreement Report
*/
    end if;

    IF (l_loan_header_rec.loan_status <> 'CANCELLED') then

        open loan_version_cur(l_loan_header_rec.loan_id);
        fetch loan_version_cur into l_object_version_number;
        close loan_version_cur;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Before call to LNS_LOAN_HEADER_PUB.update_loan');
        LNS_LOAN_HEADER_PUB.update_loan(p_init_msg_list         => FND_API.G_FALSE
                                       ,p_loan_header_rec       => l_loan_header_rec
                                       ,p_object_version_number => l_object_version_number
                                       ,x_return_status         => x_return_status
                                       ,x_msg_count             => x_msg_count
                                       ,x_msg_data              => x_msg_data);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'After call to LNS_LOAN_HEADER_PUB.update_loan');

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - LNS_LOAN_HEADER_PUB.update_loan failed with message: ' ||FND_MSG_PUB.Get(p_encoded => 'F'));
            l_last_api_called := 'LNS_LOAN_HEADER_PUB.update_loan';
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After call to LNS_LOAN_HEADER_PUB.update_loan proc');

    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - End ');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'before rollback');
        ROLLBACK TO create_approval_action;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'after rollback');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

END create_approval_action;

/*===========================================================================+
 | PROCEDURE
 |              update_approval_action
 |
 | DESCRIPTION
 |              Updates approval action.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_approval_action_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |              IN/OUT:
 |		      p_object_version_number
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-Jan-2004     Bernice Lam		Created
 +===========================================================================*/

PROCEDURE update_approval_action (
    p_init_msg_list         IN      VARCHAR2,
    p_approval_action_rec        IN      APPROVAL_ACTION_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_approval_action';
    l_approval_action_rec     APPROVAL_ACTION_REC_TYPE;
    l_old_approval_action_rec APPROVAL_ACTION_REC_TYPE;
BEGIN
    l_approval_action_rec     := p_approval_action_rec;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Update_approval_action procedure');

    -- standard start of API savepoint
    SAVEPOINT update_approval_action;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
    -- Get old record. Will be used by history package.
    get_approval_action_rec (
        p_action_id         => l_approval_action_rec.action_id,
        x_approval_action_rec => l_old_approval_action_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );
*/
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_approval_action procedure: Before call to do_update_approval_action proc');

    -- call to business logic.
    do_update_approval_action(
                   l_approval_action_rec,
                   p_object_version_number,
                   x_return_status);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_approval_action procedure: After call to do_update_approval_action proc');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_approval_action;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Update_approval_action procedure');

END update_approval_action;

/*===========================================================================+
 | PROCEDURE
 |              delete_approval_action
 |
 | DESCRIPTION
 |              Deletes approval action
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_action_id
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   06-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE delete_approval_action (
    p_init_msg_list   IN      VARCHAR2,
    p_action_id         IN     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'delete_approval_action';
    l_action_id   NUMBER;

BEGIN
    l_action_id   := p_action_id;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Delete_approval_action procedure');

    -- standard start of API savepoint
    SAVEPOINT delete_approval_action;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_approval_action procedure: Before call to do_delete_approval_action proc');

    -- call to business logic.
    do_delete_approval_action(
                   l_action_id,
                   x_return_status);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_approval_action procedure: After call to do_delete_approval_action proc');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_approval_action;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_approval_action;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Delete_approval_action procedure');

END delete_approval_action;



/*========================================================================
 | PUBLIC PROCEDURE APPROVE_ADD_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure executes all actions required during approval of loan additional receivable
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_LINE_ID          IN          Loan Line ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-05-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_ADD_RECEIVABLE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_LINE_ID          IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPROVE_ADD_RECEIVABLE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_trx_number                    varchar2(20);
    l_loan_id                       number;
--    l_xml_output                    BOOLEAN;
--    l_iso_language                  FND_LANGUAGES.iso_language%TYPE;
--    l_iso_territory                 FND_LANGUAGES.iso_territory%TYPE;
    l_agreement_reason              varchar2(500);
--    l_notify                        boolean;
--    l_request_id                    number;
    l_version_number                number;
    l_loan_status                   varchar2(30);
    l_adj_amount                    number;
    l_funded_amount                 number;
    l_add_req_amount                number;
    l_cond_count                    number;
    l_adj_date                      date;
    l_currency                      varchar2(15);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_info_cur(P_LOAN_LINE_ID number) IS
        select loan.loan_id,
               loan.LOAN_CURRENCY,
               line.REFERENCE_NUMBER,
               line.REQUESTED_AMOUNT,
               line.ADJUSTMENT_DATE,
               nvl(loan.FUNDED_AMOUNT, 0),
               nvl(loan.ADD_REQUESTED_AMOUNT, 0),
               loan.loan_status,
               loan.OBJECT_VERSION_NUMBER
        from lns_loan_lines line,
            lns_loan_headers_all loan
        where line.loan_line_id = P_LOAN_LINE_ID and
            line.loan_id = loan.loan_id;

    -- checking for conditions
    CURSOR conditions_cur(P_LOAN_LINE_ID number) IS
        select count(1)
        from LNS_COND_ASSIGNMENTS
        where
        OWNER_OBJECT_ID = P_LOAN_LINE_ID and
        OWNER_TABLE = 'LNS_LOAN_LINES' and
        MANDATORY_FLAG = 'Y' and
        (CONDITION_MET_FLAG is null or CONDITION_MET_FLAG = 'N') and
        (end_date_active is null or trunc(end_date_active) > trunc(sysdate));

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT APPROVE_ADD_RECEIVABLE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input P_LOAN_LINE_ID = ' || P_LOAN_LINE_ID);

    /* verify input parameters */
    if P_LOAN_LINE_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_LINE_ID' );
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- checking for conditions
    open conditions_cur(P_LOAN_LINE_ID);
    fetch conditions_cur into l_cond_count;
    close conditions_cur;

    if l_cond_count > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_ALL_COND_MET');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_BILLING_BATCH_PUB.ADJUST_ADD_RECEIVABLE...');
    LNS_BILLING_BATCH_PUB.ADJUST_ADD_RECEIVABLE(P_API_VERSION      => 1.0
                                                ,P_INIT_MSG_LIST    => FND_API.G_TRUE
                                                ,P_COMMIT           => FND_API.G_FALSE
                                                ,P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL
                                                ,P_LOAN_LINE_ID     => P_LOAN_LINE_ID
                                                ,X_RETURN_STATUS    => l_return_status
                                                ,X_MSG_COUNT        => l_msg_count
                                                ,X_MSG_DATA         => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);
    IF l_return_status <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    open loan_info_cur(P_LOAN_LINE_ID);
    fetch loan_info_cur into l_loan_id,
                             l_currency,
                             l_trx_number,
                             l_adj_amount,
                             l_adj_date,
                             l_funded_amount,
                             l_add_req_amount,
                             l_loan_status,
                             l_version_number;
    close loan_info_cur;

    -- create distributions for new approved additional receivable?
    LNS_DISTRIBUTIONS_PUB.createDistrForAddRec(P_API_VERSION      => 1.0
                                               ,P_INIT_MSG_LIST    => FND_API.G_TRUE
                                               ,P_COMMIT           => FND_API.G_FALSE
                                               ,P_LOAN_ID          => l_loan_id
                                               ,P_LOAN_LINE_ID     => P_LOAN_LINE_ID
                                               ,X_RETURN_STATUS    => l_return_status
                                               ,X_MSG_COUNT        => l_msg_count
                                               ,X_MSG_DATA         => l_msg_data);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_msg_count = ' || l_msg_count);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_msg_data = ' || l_msg_data);
    IF l_return_status <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* updating loan header table */
    l_loan_header_rec.loan_id := l_loan_id;
    l_loan_header_rec.funded_amount := (l_funded_amount + l_adj_amount);
    l_loan_header_rec.ADD_REQUESTED_AMOUNT := (l_add_req_amount + l_adj_amount);

    if l_loan_status <> 'ACTIVE' and
        l_loan_status <> 'DEFAULT' and
        l_loan_status <> 'DELINQUENT'
    then
        l_loan_header_rec.LOAN_STATUS := 'ACTIVE';
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating loan header info w following values:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_STATUS: ' || l_loan_header_rec.LOAN_STATUS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'funded_amount: ' || l_loan_header_rec.funded_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_REQUESTED_AMOUNT: ' || l_loan_header_rec.ADD_REQUESTED_AMOUNT);

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status: ' || l_return_status);

    IF l_return_status <> 'S' THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_MESSAGE.SET_NAME('LNS', 'LNS_ADD_REC_AGR_REASON');
    FND_MESSAGE.SET_TOKEN('REC', l_trx_number);
    FND_MESSAGE.SET_TOKEN('AMOUNT', to_char(l_adj_amount, FND_CURRENCY.SAFE_GET_FORMAT_MASK(l_currency,50)));
    FND_MESSAGE.SET_TOKEN('CURR', l_currency);
    FND_MESSAGE.SET_TOKEN('DATE', l_adj_date);
    FND_MSG_PUB.Add;
    l_agreement_reason := FND_MSG_PUB.Get(p_encoded => 'F');
    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

    LNS_REP_UTILS.STORE_LOAN_AGREEMENT_CP(l_loan_id, l_agreement_reason);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Successfully approved additional receivable ' || l_trx_number);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPROVE_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPROVE_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO APPROVE_ADD_RECEIVABLE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



/*========================================================================
 | PUBLIC PROCEDURE APPROVE_ADD_RECEIVABLE
 |
 | DESCRIPTION
 |      This procedure executes actions required during approval of loan amount adjustment
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      init
 |      LogMessage
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_AMOUNT_ADJ_ID    IN          Loan amount adjutsment ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-05-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_LOAN_AM_ADJ(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_AMOUNT_ADJ_ID    IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'APPROVE_LOAN_AM_ADJ';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_loan_id                       number;
--    l_xml_output                    BOOLEAN;
--    l_iso_language                  FND_LANGUAGES.iso_language%TYPE;
--    l_iso_territory                 FND_LANGUAGES.iso_territory%TYPE;
    l_agreement_reason              varchar2(500);
--    l_notify                        boolean;
--    l_request_id                    number;
    l_cond_count                    number;
    l_adj_date                      date;
    l_adj_amount_str                varchar2(30);
    l_currency                      varchar2(15);
    l_DESCRIPTION                   VARCHAR2(250);

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR loan_am_adj_cur(P_LOAN_AMOUNT_ADJ_ID number) IS
        select loan.loan_id,
               loan.LOAN_CURRENCY,
               adj.DESCRIPTION,
               to_char(adj.ADJUSTMENT_AMOUNT, FND_CURRENCY.SAFE_GET_FORMAT_MASK(loan.LOAN_CURRENCY,50)),
               adj.EFFECTIVE_DATE
        from LNS_LOAN_AMOUNT_ADJS adj,
            lns_loan_headers_all loan
        where adj.LOAN_AMOUNT_ADJ_ID = P_LOAN_AMOUNT_ADJ_ID and
            adj.loan_id = loan.loan_id;

    -- checking for conditions
    CURSOR conditions_cur(P_LOAN_AMOUNT_ADJ_ID number) IS
        select count(1)
        from LNS_COND_ASSIGNMENTS
        where
        OWNER_OBJECT_ID = P_LOAN_AMOUNT_ADJ_ID and
        OWNER_TABLE = 'LNS_LOAN_AMOUNT_ADJS' and
        MANDATORY_FLAG = 'Y' and
        (CONDITION_MET_FLAG is null or CONDITION_MET_FLAG = 'N') and
        (end_date_active is null or trunc(end_date_active) > trunc(sysdate));

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT APPROVE_LOAN_AM_ADJ;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input P_LOAN_AMOUNT_ADJ_ID = ' || P_LOAN_AMOUNT_ADJ_ID);

    /* verify input parameters */
    if P_LOAN_AMOUNT_ADJ_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_AMOUNT_ADJ_ID' );
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    -- checking for conditions
    open conditions_cur(P_LOAN_AMOUNT_ADJ_ID);
    fetch conditions_cur into l_cond_count;
    close conditions_cur;

    if l_cond_count > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_ALL_COND_MET');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    open loan_am_adj_cur(P_LOAN_AMOUNT_ADJ_ID);
    fetch loan_am_adj_cur into l_loan_id,
                             l_currency,
                             l_DESCRIPTION,
                             l_adj_amount_str,
                             l_adj_date;
    close loan_am_adj_cur;

    FND_MESSAGE.SET_NAME('LNS', 'LNS_LOAN_AM_ADJ_AGR_REASON');
    FND_MESSAGE.SET_TOKEN('ADJ', l_DESCRIPTION);
    FND_MESSAGE.SET_TOKEN('AMOUNT', l_adj_amount_str);
    FND_MESSAGE.SET_TOKEN('CURR', l_currency);
    FND_MESSAGE.SET_TOKEN('DATE', l_adj_date);
    FND_MSG_PUB.Add;
    l_agreement_reason := FND_MSG_PUB.Get(p_encoded => 'F');
    FND_MSG_PUB.DELETE_MSG(FND_MSG_PUB.COUNT_MSG);

    LNS_REP_UTILS.STORE_LOAN_AGREEMENT_CP(l_loan_id, l_agreement_reason);

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Successfully loan amount adjustment ' || l_DESCRIPTION);

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPROVE_LOAN_AM_ADJ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPROVE_LOAN_AM_ADJ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO APPROVE_LOAN_AM_ADJ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Rollbacked');
END;



END LNS_APPROVAL_ACTION_PUB;

/
