--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_HEADER_PUB" AS
 /*$Header: LNS_LNHDR_PUBP_B.pls 120.13.12010000.5 2010/03/19 08:40:50 gparuchu ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------

 G_DEBUG_COUNT                       CONSTANT NUMBER := 0;
 G_DEBUG                             CONSTANT BOOLEAN := FALSE;

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_LOAN_HEADER_PUB';
--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------

PROCEDURE do_create_loan (
    p_loan_header_rec      IN OUT NOCOPY LOAN_HEADER_REC_TYPE,
    x_loan_id              OUT NOCOPY    NUMBER,
    x_loan_number          OUT NOCOPY    VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_loan (
    p_loan_header_rec        IN OUT NOCOPY LOAN_HEADER_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

-----------------------------
-- body of private procedures
-----------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_loan
 |
 | DESCRIPTION
 |              Creates loan.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_loan_id
 |                    x_loan_number
 |              IN/OUT:
 |                    p_loan_header_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   30-Nov-2003     Karthik Ramachandran       Created.
 |   13-Mar-2008     Madhu Bolli		Bug#6711399 - SubsidyRate defaulted
 |						from loanProduct at the time of loan Creation
 +===========================================================================*/
PROCEDURE do_create_loan (
    p_loan_header_rec         IN OUT NOCOPY LOAN_HEADER_REC_TYPE,
    x_loan_id                 OUT NOCOPY    NUMBER,
    x_loan_number             OUT NOCOPY    VARCHAR2,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_loan_id               NUMBER;
    l_loan_number           VARCHAR2(60);
    l_gen_loan_number       VARCHAR2(1);
    l_rowid                 ROWID := NULL;
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_amort_freq	    VARCHAR2(30);
    l_subsidy_rate          NUMBER;

    CURSOR c_subsidy_rate (p_loan_id number) IS
    SELECT disb_percent
    FROM
	lns_loan_product_lines prod_line
    WHERE prod_line.LOAN_PRODUCT_ID = p_loan_header_rec.product_id
        AND prod_line.LOAN_PRODUCT_LINE_TYPE = 'SUBSIDY_RATE'
        AND nvl(p_loan_header_rec.gl_date, sysdate) between prod_line.START_DATE_ACTIVE and nvl(prod_line.END_DATE_ACTIVE,nvl(p_loan_header_rec.gl_date, sysdate))
	AND rownum =1;

BEGIN
    l_loan_id               := p_loan_header_rec.loan_id;
    l_loan_number           := p_loan_header_rec.loan_number;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_create_loan procedure');
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_loan_id IS NOT NULL AND
        l_loan_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_LOAN_HEADERS_ALL
            WHERE  loan_id = l_loan_id;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'loan_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- if GENERATE_LOAN_NUMBER is 'N', then if LOAN_NUMBER is
    -- not passed or is a duplicate raise error.
    -- if GENERATE_LOAN_NUMBER is NULL or 'Y', generate LOAN_NUMBER
    -- from sequence till a unique value is obtained.

    l_gen_loan_number := fnd_profile.value('LNS_GENERATE_LOAN_NUMBER');

    IF l_gen_loan_number = 'N' THEN
        IF l_loan_number = FND_API.G_MISS_CHAR
           OR
           l_loan_number IS NULL
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'LOAN_NUMBER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_LOAN_HEADERS_ALL
            WHERE  LOAN_NUMBER = l_loan_number;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'LOAN_NUMBER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END IF;
    /*--Commenting out the else part for now as the auto loan_number generation
      --can happen from the UI itself
    ELSIF l_gen_loan_number = 'Y'
          OR
          l_gen_loan_number IS NULL
    THEN

        IF l_loan_number <> FND_API.G_MISS_CHAR
           AND
           l_loan_number IS NOT NULL
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_LOAN_NUM_AUTO_ON');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;
    */

    x_loan_number := l_loan_number;
    if (p_loan_header_rec.org_id is null) then
    	 p_loan_header_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    end if;

    --Update requested amount to funded amount
    --if ers loan, zero otherwise
     if (p_loan_header_rec.loan_class_code = 'ERS') then
	p_loan_header_rec.funded_amount := 0;
	p_loan_header_rec.initial_loan_balance := p_loan_header_rec.requested_amount;
     else
	p_loan_header_rec.funded_amount := 0;
	p_loan_header_rec.initial_loan_balance := 0;
     end if;


    --Calculate Maturity Date
    IF (p_loan_header_rec.loan_maturity_date is null) THEN
					select amortization_frequency into l_amort_freq from lns_terms
					where loan_id = l_loan_id;

					p_loan_header_rec.loan_maturity_date :=
						lns_fin_utils.getMaturityDate(
						p_term => p_loan_header_rec.loan_term,
						p_term_period => p_loan_header_rec.loan_term_period,
						p_frequency => l_amort_freq,
						p_start_date => p_loan_header_rec.loan_start_date
						);
    END IF;

    --Calculate Open phase Maturity Date
    IF (p_loan_header_rec.multiple_funding_flag = 'Y' AND
    		p_loan_header_rec.open_maturity_date is null) THEN
					select amortization_frequency into l_amort_freq from lns_terms
					where loan_id = l_loan_id;

					p_loan_header_rec.open_maturity_date :=
						lns_fin_utils.getMaturityDate(
						p_term => p_loan_header_rec.open_loan_term,
						p_term_period => p_loan_header_rec.open_loan_term_period,
						p_frequency => l_amort_freq,
						p_start_date => p_loan_header_rec.open_loan_start_date
						);
    END IF;

				--default funds_reserved_flag to No
				IF (p_loan_header_rec.FUNDS_RESERVED_FLAG is null) THEN
    	p_loan_header_rec.FUNDS_RESERVED_FLAG := 'N';
    END IF;


    -- Bug#6711399 - SubsidyRate defaulted from loanProduct for Direct Loans

    IF p_loan_header_rec.loan_class_code = 'DIRECT' THEN

	    open c_subsidy_rate(p_loan_header_rec.loan_id);
	    fetch c_subsidy_rate into l_subsidy_rate;
	    close c_subsidy_rate;

	    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_loan procedure: l_subsidy_rate ' || l_subsidy_rate);
	    END IF;

	    IF (l_subsidy_rate IS NOT NULL) THEN
		p_loan_header_rec.SUBSIDY_RATE := l_subsidy_rate;
	    END IF;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_loan procedure: Before call to LNS_LOAN_HEADER_ALL_PKG.Insert_Row');
    END IF;

    -- call table-handler.
    LNS_LOAN_HEADER_ALL_PKG.Insert_Row (
	X_LOAN_ID               => p_loan_header_rec.loan_id,
	X_ORG_ID                => p_loan_header_rec.org_id,
	X_LOAN_NUMBER       	=> p_loan_header_rec.loan_number,
	X_LOAN_DESCRIPTION	=> p_loan_header_rec.loan_description,
	X_OBJECT_VERSION_NUMBER => 1,
	X_LOAN_APPLICATION_DATE => p_loan_header_rec.loan_application_date,
	X_END_DATE              => p_loan_header_rec.end_date,
	X_INITIAL_LOAN_BALANCE  => p_loan_header_rec.initial_loan_balance,
	X_LAST_PAYMENT_DATE     => p_loan_header_rec.last_payment_date,
	X_LAST_PAYMENT_AMOUNT   => p_loan_header_rec.last_payment_amount,
	X_LOAN_TERM             => p_loan_header_rec.loan_term,
	X_LOAN_TERM_PERIOD      => p_loan_header_rec.loan_term_period,
	X_AMORTIZED_TERM        => p_loan_header_rec.amortized_term,
	X_AMORTIZED_TERM_PERIOD => p_loan_header_rec.amortized_term_period,
	X_LOAN_STATUS           => p_loan_header_rec.loan_status,
	X_LOAN_ASSIGNED_TO      => p_loan_header_rec.loan_assigned_to,
	X_LOAN_CURRENCY         => p_loan_header_rec.loan_currency,
	X_LOAN_CLASS_CODE       => p_loan_header_rec.loan_class_code,
	X_LOAN_TYPE             => p_loan_header_rec.loan_type,
	X_LOAN_SUBTYPE          => p_loan_header_rec.loan_subtype,
	X_LOAN_PURPOSE_CODE     => p_loan_header_rec.loan_purpose_code,
	X_CUST_ACCOUNT_ID       => p_loan_header_rec.cust_account_id,
	X_BILL_TO_ACCT_SITE_ID  => p_loan_header_rec.bill_to_acct_site_id,
	X_LOAN_MATURITY_DATE    => p_loan_header_rec.loan_maturity_date,
	X_LOAN_START_DATE     => p_loan_header_rec.loan_start_date,
	X_LOAN_CLOSING_DATE     => p_loan_header_rec.loan_closing_date,
	X_REFERENCE_ID		=> p_loan_header_rec.reference_id,
	X_REFERENCE_NUMBER      => p_loan_header_rec.reference_number,
	X_REFERENCE_DESCRIPTION => p_loan_header_rec.reference_description,
	X_REFERENCE_AMOUNT	=> p_loan_header_rec.reference_amount,
	X_PRODUCT_FLAG          => p_loan_header_rec.product_flag,
	X_PRIMARY_BORROWER_ID   => p_loan_header_rec.primary_borrower_id,
	X_PRODUCT_ID            => p_loan_header_rec.product_id,
	X_REQUESTED_AMOUNT      => p_loan_header_rec.requested_amount,
	X_FUNDED_AMOUNT         => p_loan_header_rec.funded_amount,
	X_LOAN_APPROVAL_DATE    => p_loan_header_rec.loan_approval_date,
	X_LOAN_APPROVED_BY      => p_loan_header_rec.loan_approved_by,
	X_ATTRIBUTE_CATEGORY    => p_loan_header_rec.attribute_category,
	X_ATTRIBUTE1            => p_loan_header_rec.attribute1,
	X_ATTRIBUTE2            => p_loan_header_rec.attribute2,
	X_ATTRIBUTE3            => p_loan_header_rec.attribute3,
	X_ATTRIBUTE4            => p_loan_header_rec.attribute4,
	X_ATTRIBUTE5            => p_loan_header_rec.attribute5,
	X_ATTRIBUTE6            => p_loan_header_rec.attribute6,
	X_ATTRIBUTE7            => p_loan_header_rec.attribute7,
	X_ATTRIBUTE8            => p_loan_header_rec.attribute8,
	X_ATTRIBUTE9            => p_loan_header_rec.attribute9,
	X_ATTRIBUTE10           => p_loan_header_rec.attribute10,
	X_ATTRIBUTE11           => p_loan_header_rec.attribute11,
	X_ATTRIBUTE12           => p_loan_header_rec.attribute12,
	X_ATTRIBUTE13           => p_loan_header_rec.attribute13,
	X_ATTRIBUTE14           => p_loan_header_rec.attribute14,
	X_ATTRIBUTE15           => p_loan_header_rec.attribute15,
	X_ATTRIBUTE16           => p_loan_header_rec.attribute16,
	X_ATTRIBUTE17           => p_loan_header_rec.attribute17,
	X_ATTRIBUTE18           => p_loan_header_rec.attribute18,
	X_ATTRIBUTE19           => p_loan_header_rec.attribute19,
	X_ATTRIBUTE20           => p_loan_header_rec.attribute20,
	X_LAST_BILLED_DATE      => p_loan_header_rec.last_billed_date,
	X_CUSTOM_PAYMENTS_FLAG  => p_loan_header_rec.custom_payments_flag,
	X_BILLED_FLAG           => p_loan_header_rec.billed_flag,
	X_REFERENCE_NAME	=> p_loan_header_rec.reference_name,
	X_REFERENCE_TYPE	=> p_loan_header_rec.reference_type,
	X_REFERENCE_TYPE_ID	=> p_loan_header_rec.reference_type_id,
	X_USSGL_TRANSACTION_CODE => p_loan_header_rec.ussgl_transaction_code,
	X_GL_DATE		=> p_loan_header_rec.gl_date,
	X_REC_ADJUSTMENT_NUMBER	=> p_loan_header_rec.REC_ADJUSTMENT_NUMBER,
	X_CONTACT_REL_PARTY_ID	=> p_loan_header_rec.CONTACT_REL_PARTY_ID,
	X_CONTACT_PERS_PARTY_ID	=> p_loan_header_rec.CONTACT_PERS_PARTY_ID,
	X_CREDIT_REVIEW_FLAG	=> p_loan_header_rec.CREDIT_REVIEW_FLAG,
	X_EXCHANGE_RATE_TYPE	=> p_loan_header_rec.EXCHANGE_RATE_TYPE,
	X_EXCHANGE_DATE		=> p_loan_header_rec.EXCHANGE_DATE,
	X_EXCHANGE_RATE		=> p_loan_header_rec.EXCHANGE_RATE,
	X_COLLATERAL_PERCENT	=> p_loan_header_rec.COLLATERAL_PERCENT,
	X_LAST_PAYMENT_NUMBER	=> p_loan_header_rec.LAST_PAYMENT_NUMBER,
	X_LAST_AMORTIZATION_ID	=> p_loan_header_rec.LAST_AMORTIZATION_ID,
	X_LEGAL_ENTITY_ID     	=> p_loan_header_rec.LEGAL_ENTITY_ID,
	X_OPEN_TO_TERM_FLAG  => p_loan_header_rec.OPEN_TO_TERM_FLAG,
	X_MULTIPLE_FUNDING_FLAG  => p_loan_header_rec.MULTIPLE_FUNDING_FLAG,
	X_LOAN_TYPE_ID   => p_loan_header_rec.LOAN_TYPE_ID,
	X_SECONDARY_STATUS  => p_loan_header_rec.SECONDARY_STATUS,
	X_OPEN_TO_TERM_EVENT  => p_loan_header_rec.OPEN_TO_TERM_EVENT,
	X_BALLOON_PAYMENT_TYPE  => p_loan_header_rec.BALLOON_PAYMENT_TYPE,
	X_BALLOON_PAYMENT_AMOUNT  => p_loan_header_rec.BALLOON_PAYMENT_AMOUNT,
	X_CURRENT_PHASE  => p_loan_header_rec.CURRENT_PHASE,
	X_OPEN_LOAN_START_DATE  => p_loan_header_rec.OPEN_LOAN_START_DATE,
	X_OPEN_LOAN_TERM  => p_loan_header_rec.OPEN_LOAN_TERM,
	X_OPEN_LOAN_TERM_PERIOD  => p_loan_header_rec.OPEN_LOAN_TERM_PERIOD,
	X_OPEN_MATURITY_DATE  => p_loan_header_rec.OPEN_MATURITY_DATE,
	X_FUNDS_RESERVED_FLAG  => p_loan_header_rec.FUNDS_RESERVED_FLAG,
	X_FUNDS_CHECK_DATE  => p_loan_header_rec.FUNDS_CHECK_DATE,
	X_SUBSIDY_RATE  => p_loan_header_rec.SUBSIDY_RATE,
	X_APPLICATION_ID  => p_loan_header_rec.APPLICATION_ID,
	X_CREATED_BY_MODULE  => p_loan_header_rec.CREATED_BY_MODULE,
	X_PARTY_TYPE  => p_loan_header_rec.PARTY_TYPE,
	X_FORGIVENESS_FLAG	=> p_loan_header_rec.FORGIVENESS_FLAG,
	X_FORGIVENESS_PERCENT	=> p_loan_header_rec.FORGIVENESS_PERCENT,
	X_DISABLE_BILLING_FLAG	=> p_loan_header_rec.DISABLE_BILLING_FLAG,
	X_ADD_REQUESTED_AMOUNT	=> p_loan_header_rec.ADD_REQUESTED_AMOUNT
 );

    x_loan_id := p_loan_header_rec.loan_id;
    x_loan_number := p_loan_header_rec.loan_number;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_loan procedure: After call to LNS_LOAN_HEADER_ALL_PKG.Insert_Row');
    END IF;

END do_create_loan;


/*===========================================================================+
 | PROCEDURE
 |              do_update_loan
 |
 | DESCRIPTION
 |              Updates loan.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_loan_header_rec
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   30-Nov-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE do_update_loan(
    p_loan_header_rec         IN OUT NOCOPY LOAN_HEADER_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_object_version_number         NUMBER;
    l_rowid                         ROWID;
    ldup_rowid                      ROWID;

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_update_loan procedure');
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   LNS_LOAN_HEADERS_ALL
        WHERE  LOAN_ID = p_loan_header_rec.loan_id
        FOR UPDATE OF LOAN_ID NOWAIT;

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
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_loan_header_all');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'loan header');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_loan_header_rec.loan_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF (p_loan_header_rec.loan_status='INCOMPLETE') THEN
    	--Update requested amount to funded amount for ERS loan
    	--Update requested amount to initial loan balance amount
	--if ers loan
	if (p_loan_header_rec.loan_class_code = 'ERS') then
		--p_loan_header_rec.funded_amount := p_loan_header_rec.requested_amount;
		p_loan_header_rec.initial_loan_balance := p_loan_header_rec.requested_amount;
	end if;
    END IF;

    --update secondary status to NULL if deleted or rejected loans
    IF (p_loan_header_rec.loan_status='DELETED' OR p_loan_header_rec.loan_status='REJECTED') THEN
	p_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_loan procedure: Before call to LNS_LOAN_HEADER_ALL_PKG.Update_Row');
    END IF;

    --Call to table-handler
    LNS_LOAN_HEADER_ALL_PKG.Update_Row (
    	X_Rowid                 => l_rowid,
	X_LOAN_ID               => p_loan_header_rec.loan_id,
	X_ORG_ID                => p_loan_header_rec.org_id,
	X_LOAN_NUMBER       	=> p_loan_header_rec.loan_number,
	X_LOAN_DESCRIPTION	=> p_loan_header_rec.loan_description,
	X_OBJECT_VERSION_NUMBER => p_object_version_number,
	X_LOAN_APPLICATION_DATE => p_loan_header_rec.loan_application_date,
	X_END_DATE              => p_loan_header_rec.end_date,
	X_INITIAL_LOAN_BALANCE  => p_loan_header_rec.initial_loan_balance,
	X_LAST_PAYMENT_DATE     => p_loan_header_rec.last_payment_date,
	X_LAST_PAYMENT_AMOUNT   => p_loan_header_rec.last_payment_amount,
	X_LOAN_TERM             => p_loan_header_rec.loan_term,
	X_LOAN_TERM_PERIOD      => p_loan_header_rec.loan_term_period,
	X_AMORTIZED_TERM        => p_loan_header_rec.amortized_term,
	X_AMORTIZED_TERM_PERIOD => p_loan_header_rec.amortized_term_period,
	X_LOAN_STATUS           => p_loan_header_rec.loan_status,
	X_LOAN_ASSIGNED_TO      => p_loan_header_rec.loan_assigned_to,
	X_LOAN_CURRENCY         => p_loan_header_rec.loan_currency,
	X_LOAN_CLASS_CODE       => p_loan_header_rec.loan_class_code,
	X_LOAN_TYPE             => p_loan_header_rec.loan_type,
	X_LOAN_SUBTYPE          => p_loan_header_rec.loan_subtype,
	X_LOAN_PURPOSE_CODE     => p_loan_header_rec.loan_purpose_code,
	X_CUST_ACCOUNT_ID       => p_loan_header_rec.cust_account_id,
	X_BILL_TO_ACCT_SITE_ID  => p_loan_header_rec.bill_to_acct_site_id,
	X_LOAN_MATURITY_DATE    => p_loan_header_rec.loan_maturity_date,
	X_LOAN_START_DATE     => p_loan_header_rec.loan_start_date,
	X_LOAN_CLOSING_DATE     => p_loan_header_rec.loan_closing_date,
	X_REFERENCE_ID		=> p_loan_header_rec.reference_id,
	X_REFERENCE_NUMBER      => p_loan_header_rec.reference_number,
	X_REFERENCE_DESCRIPTION => p_loan_header_rec.reference_description,
	X_REFERENCE_AMOUNT	=> p_loan_header_rec.reference_amount,
	X_PRODUCT_FLAG          => p_loan_header_rec.product_flag,
	X_PRIMARY_BORROWER_ID   => p_loan_header_rec.primary_borrower_id,
	X_PRODUCT_ID            => p_loan_header_rec.product_id,
	X_REQUESTED_AMOUNT      => p_loan_header_rec.requested_amount,
	X_FUNDED_AMOUNT         => p_loan_header_rec.funded_amount,
	X_LOAN_APPROVAL_DATE    => p_loan_header_rec.loan_approval_date,
	X_LOAN_APPROVED_BY      => p_loan_header_rec.loan_approved_by,
	X_ATTRIBUTE_CATEGORY    => p_loan_header_rec.attribute_category,
	X_ATTRIBUTE1            => p_loan_header_rec.attribute1,
	X_ATTRIBUTE2            => p_loan_header_rec.attribute2,
	X_ATTRIBUTE3            => p_loan_header_rec.attribute3,
	X_ATTRIBUTE4            => p_loan_header_rec.attribute4,
	X_ATTRIBUTE5            => p_loan_header_rec.attribute5,
	X_ATTRIBUTE6            => p_loan_header_rec.attribute6,
	X_ATTRIBUTE7            => p_loan_header_rec.attribute7,
	X_ATTRIBUTE8            => p_loan_header_rec.attribute8,
	X_ATTRIBUTE9            => p_loan_header_rec.attribute9,
	X_ATTRIBUTE10           => p_loan_header_rec.attribute10,
	X_ATTRIBUTE11           => p_loan_header_rec.attribute11,
	X_ATTRIBUTE12           => p_loan_header_rec.attribute12,
	X_ATTRIBUTE13           => p_loan_header_rec.attribute13,
	X_ATTRIBUTE14           => p_loan_header_rec.attribute14,
	X_ATTRIBUTE15           => p_loan_header_rec.attribute15,
	X_ATTRIBUTE16           => p_loan_header_rec.attribute16,
	X_ATTRIBUTE17           => p_loan_header_rec.attribute17,
	X_ATTRIBUTE18           => p_loan_header_rec.attribute18,
	X_ATTRIBUTE19           => p_loan_header_rec.attribute19,
	X_ATTRIBUTE20           => p_loan_header_rec.attribute20,
	X_LAST_BILLED_DATE      => p_loan_header_rec.last_billed_date,
	X_CUSTOM_PAYMENTS_FLAG  => p_loan_header_rec.custom_payments_flag,
	X_BILLED_FLAG           => p_loan_header_rec.billed_flag,
	X_REFERENCE_NAME	=> p_loan_header_rec.reference_name,
	X_REFERENCE_TYPE	=> p_loan_header_rec.reference_type,
	X_REFERENCE_TYPE_ID	=> p_loan_header_rec.reference_type_id,
	X_USSGL_TRANSACTION_CODE => p_loan_header_rec.ussgl_transaction_code,
	X_GL_DATE		=> p_loan_header_rec.gl_date,
	X_REC_ADJUSTMENT_NUMBER	=> p_loan_header_rec.REC_ADJUSTMENT_NUMBER,
	X_CONTACT_REL_PARTY_ID	=> p_loan_header_rec.CONTACT_REL_PARTY_ID,
	X_CONTACT_PERS_PARTY_ID	=> p_loan_header_rec.CONTACT_PERS_PARTY_ID,
	X_CREDIT_REVIEW_FLAG	=> p_loan_header_rec.CREDIT_REVIEW_FLAG,
	X_EXCHANGE_RATE_TYPE	=> p_loan_header_rec.EXCHANGE_RATE_TYPE,
	X_EXCHANGE_DATE		=> p_loan_header_rec.EXCHANGE_DATE,
	X_EXCHANGE_RATE		=> p_loan_header_rec.EXCHANGE_RATE,
	X_COLLATERAL_PERCENT	=> p_loan_header_rec.COLLATERAL_PERCENT,
	X_LAST_PAYMENT_NUMBER	=> p_loan_header_rec.LAST_PAYMENT_NUMBER,
	X_LAST_AMORTIZATION_ID	=> p_loan_header_rec.LAST_AMORTIZATION_ID,
	X_LEGAL_ENTITY_ID     	=> p_loan_header_rec.LEGAL_ENTITY_ID,
	X_OPEN_TO_TERM_FLAG  => p_loan_header_rec.OPEN_TO_TERM_FLAG,
	X_MULTIPLE_FUNDING_FLAG  => p_loan_header_rec.MULTIPLE_FUNDING_FLAG,
	X_LOAN_TYPE_ID   => p_loan_header_rec.LOAN_TYPE_ID,
	X_SECONDARY_STATUS  => p_loan_header_rec.SECONDARY_STATUS,
	X_OPEN_TO_TERM_EVENT  => p_loan_header_rec.OPEN_TO_TERM_EVENT,
	X_BALLOON_PAYMENT_TYPE  => p_loan_header_rec.BALLOON_PAYMENT_TYPE,
	X_BALLOON_PAYMENT_AMOUNT  => p_loan_header_rec.BALLOON_PAYMENT_AMOUNT,
	X_CURRENT_PHASE  => p_loan_header_rec.CURRENT_PHASE,
	X_OPEN_LOAN_START_DATE  => p_loan_header_rec.OPEN_LOAN_START_DATE,
	X_OPEN_LOAN_TERM  => p_loan_header_rec.OPEN_LOAN_TERM,
	X_OPEN_LOAN_TERM_PERIOD  => p_loan_header_rec.OPEN_LOAN_TERM_PERIOD,
	X_OPEN_MATURITY_DATE  => p_loan_header_rec.OPEN_MATURITY_DATE,
	X_FUNDS_RESERVED_FLAG  => p_loan_header_rec.FUNDS_RESERVED_FLAG,
	X_FUNDS_CHECK_DATE  => p_loan_header_rec.FUNDS_CHECK_DATE,
	X_SUBSIDY_RATE  => p_loan_header_rec.SUBSIDY_RATE,
	X_APPLICATION_ID  => p_loan_header_rec.APPLICATION_ID,
	X_CREATED_BY_MODULE  => p_loan_header_rec.CREATED_BY_MODULE,
	X_PARTY_TYPE  => p_loan_header_rec.PARTY_TYPE,
	X_FORGIVENESS_FLAG	=> p_loan_header_rec.FORGIVENESS_FLAG,
	X_FORGIVENESS_PERCENT	=> p_loan_header_rec.FORGIVENESS_PERCENT,
	X_DISABLE_BILLING_FLAG	=> p_loan_header_rec.DISABLE_BILLING_FLAG,
	X_ADD_REQUESTED_AMOUNT	=> p_loan_header_rec.ADD_REQUESTED_AMOUNT
    );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_loan procedure: After call to LNS_LOAN_HEADER_ALL_PKG.Update_Row for loan_id: '|| p_loan_header_rec.loan_id);
    END IF;

    IF (p_loan_header_rec.loan_status in ('DELETED','REJECTED','PAIDOFF')) THEN

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_loan procedure: Loan Status code is '|| p_loan_header_rec.loan_status || ' - Before call to LNS_LOAN_COLLATERAL_PUB.Release_Collaterals for loan_id: '||p_loan_header_rec.loan_id);
	END IF;

    	--Release all the collateral held against this loan
	LNS_LOAN_COLLATERAL_PUB.Release_Collaterals(p_loan_header_rec.loan_id);

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_loan procedure: Loan Status code is '|| p_loan_header_rec.loan_status || ' - After call to LNS_LOAN_COLLATERAL_PUB.Release_Collaterals for loan_id: '||p_loan_header_rec.loan_id);
	END IF;


    END IF;

END do_update_loan;

----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_loan
 |
 | DESCRIPTION
 |              Creates loan.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_header_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_loan_id
 |                    x_loan_number
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   30-Nov-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE create_loan (
    p_init_msg_list   IN      VARCHAR2,
    p_loan_header_rec IN      LOAN_HEADER_REC_TYPE,
    x_loan_id         OUT NOCOPY     NUMBER,
    x_loan_number     OUT NOCOPY     VARCHAR2,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_init_msg_list VARCHAR2(1);
    l_api_name        CONSTANT VARCHAR2(30) := 'create_loan';
    l_loan_header_rec LOAN_HEADER_REC_TYPE;
    l_loan_id NUMBER;
    l_loan_class_code VARCHAR2(30);

BEGIN
    l_loan_header_rec := p_loan_header_rec;

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
    	l_init_msg_list := FND_API.G_FALSE;
    end if;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Create_Loan procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_loan;

    -- initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_Loan procedure: Before call to do_create_loan proc');
    END IF;

    -- call to business logic.
    do_create_loan(
                   l_loan_header_rec,
                   x_loan_id,
                   x_loan_number,
                   x_return_status
                  );

    l_loan_id := x_loan_id;

    /*--This call is no longer needed since this is moved to
     --the accounting page for performance reasons
    if (x_return_status = FND_API.G_RET_STS_SUCCESS) then

	l_loan_class_code := l_loan_header_rec.loan_class_code;
	-- call to save default distributions to the loan
	LNS_DISTRIBUTIONS_PUB.defaultDistributions(
	 p_api_version	   => 1.0,
	 p_init_msg_list   => FND_API.G_TRUE,
	 p_commit	   => FND_API.G_FALSE,
	 p_loan_id	   => l_loan_id,
	 p_loan_class_code => l_loan_class_code,
	 x_return_status   => x_return_status,
	 x_msg_count 	   => x_msg_count,
	 x_msg_data	   => x_msg_data
	);

    end if;
    */

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_Loan procedure: After call to do_create_loan proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_loan;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_loan;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_loan;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Create_Loan procedure');
    END IF;

END create_loan;

/*===========================================================================+
 | PROCEDURE
 |              update_loan
 |
 | DESCRIPTION
 |              Updates loan.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_header_rec
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
 |   30-Nov-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE update_loan (
    p_init_msg_list         IN      VARCHAR2,
    p_loan_header_rec       IN      LOAN_HEADER_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS
    l_init_msg_list VARCHAR2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'update_loan';
    l_loan_header_rec     LOAN_HEADER_REC_TYPE;
    l_old_loan_header_rec LOAN_HEADER_REC_TYPE;

BEGIN
    l_loan_header_rec := p_loan_header_rec;

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
    	l_init_msg_list := FND_API.G_FALSE;
    end if;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Update_Loan procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT update_loan;

    -- initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old record. Will be used by history package and
    -- for updating loan desciption in credit mgmt credit request
    -- as needed .
    get_loan_header_rec (
    	p_init_msg_list   => FND_API.G_FALSE,
        p_loan_id         => l_loan_header_rec.loan_id,
        x_loan_header_rec => l_old_loan_header_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_Loan procedure: Before call to do_update_loan proc');
    END IF;

    -- call to business logic.
    do_update_loan(
                   l_loan_header_rec,
                   p_object_version_number,
                   x_return_status
                  );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_Loan procedure: After call to do_update_loan proc');
    END IF;

	--if the loan description has changed and credit request created
	--for this loan participants, update the credit request with the
	--new loan description information to fix bug#4930854
	IF (l_old_loan_header_rec.credit_review_flag = 'Y' and l_loan_header_rec.loan_description is not null and l_loan_header_rec.loan_description <> FND_API.G_MISS_CHAR and l_loan_header_rec.loan_description <> l_old_loan_header_rec.loan_description) THEN
		update ar_cmgt_credit_requests
		set SOURCE_COLUMN3 = l_loan_header_rec.loan_description
		where SOURCE_NAME = 'LNS' and
		SOURCE_COLUMN1 = to_char(l_loan_header_rec.loan_id) and
		SOURCE_COLUMN3 = l_old_loan_header_rec.loan_description;
	END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_loan;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_loan;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_loan;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Update_Loan procedure');
    END IF;

END update_loan;

/*===========================================================================+
 | PROCEDURE
 |              validate_loan
 |
 | DESCRIPTION
 |              Validates loan.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_header_rec
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
 |   17-Jan-2004     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE validate_loan (
    p_init_msg_list         IN      VARCHAR2,
    p_loan_header_rec       IN      LOAN_HEADER_REC_TYPE,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS
    l_init_msg_list VARCHAR2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'validate_loan';
    l_loan_header_rec     LOAN_HEADER_REC_TYPE;
    l_old_loan_header_rec LOAN_HEADER_REC_TYPE;

BEGIN
    l_loan_header_rec := p_loan_header_rec;

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
    	l_init_msg_list := FND_API.G_FALSE;
    end if;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Validate_Loan procedure');
    END IF;

    -- initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Call this only for update!
    -- Get old record if update.
    -- Will be used to validate value changes in fields.
    get_loan_header_rec (
        p_loan_id         => l_loan_header_rec.loan_id,
        x_loan_header_rec => l_old_loan_header_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );
    */

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Validate_Loan procedure');
    END IF;

END validate_loan;

/*===========================================================================+
 | PROCEDURE
 |              get_loan_header_rec
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_id
 |              OUT:
 |                    x_loan_header_rec
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
 |   30-Nov-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE get_loan_header_rec (
    p_init_msg_list   IN  VARCHAR2,
    p_loan_id         IN  NUMBER,
    x_loan_header_rec OUT NOCOPY LOAN_HEADER_REC_TYPE,
    x_return_status   OUT NOCOPY    VARCHAR2,
    x_msg_count       OUT NOCOPY    NUMBER,
    x_msg_data        OUT NOCOPY    VARCHAR2
) IS
    l_init_msg_list VARCHAR2(1);
    l_api_name  CONSTANT VARCHAR2(30) := 'get_loan_header_rec';

BEGIN

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
    	l_init_msg_list := FND_API.G_FALSE;
    end if;

    --Initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_loan_id IS NULL OR
       p_loan_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'loan_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_loan_header_rec.loan_id := p_loan_id;

    --Call to table-handler
    LNS_LOAN_HEADER_ALL_PKG.Select_Row (
	X_LOAN_ID               => x_loan_header_rec.loan_id,
	X_ORG_ID                => x_loan_header_rec.org_id,
	X_LOAN_NUMBER       	=> x_loan_header_rec.loan_number,
	X_LOAN_DESCRIPTION	=> x_loan_header_rec.loan_description,
	X_LOAN_APPLICATION_DATE => x_loan_header_rec.loan_application_date,
	X_END_DATE              => x_loan_header_rec.end_date,
	X_INITIAL_LOAN_BALANCE  => x_loan_header_rec.initial_loan_balance,
	X_LAST_PAYMENT_DATE     => x_loan_header_rec.last_payment_date,
	X_LAST_PAYMENT_AMOUNT   => x_loan_header_rec.last_payment_amount,
	X_LOAN_TERM             => x_loan_header_rec.loan_term,
	X_LOAN_TERM_PERIOD      => x_loan_header_rec.loan_term_period,
	X_AMORTIZED_TERM        => x_loan_header_rec.amortized_term,
	X_AMORTIZED_TERM_PERIOD => x_loan_header_rec.amortized_term_period,
	X_LOAN_STATUS           => x_loan_header_rec.loan_status,
	X_LOAN_ASSIGNED_TO      => x_loan_header_rec.loan_assigned_to,
	X_LOAN_CURRENCY         => x_loan_header_rec.loan_currency,
	X_LOAN_CLASS_CODE       => x_loan_header_rec.loan_class_code,
	X_LOAN_TYPE             => x_loan_header_rec.loan_type,
	X_LOAN_SUBTYPE          => x_loan_header_rec.loan_subtype,
	X_LOAN_PURPOSE_CODE     => x_loan_header_rec.loan_purpose_code,
	X_CUST_ACCOUNT_ID       => x_loan_header_rec.cust_account_id,
	X_BILL_TO_ACCT_SITE_ID  => x_loan_header_rec.bill_to_acct_site_id,
	X_LOAN_MATURITY_DATE    => x_loan_header_rec.loan_maturity_date,
	X_LOAN_START_DATE     => x_loan_header_rec.loan_start_date,
	X_LOAN_CLOSING_DATE     => x_loan_header_rec.loan_closing_date,
	X_REFERENCE_ID		=> x_loan_header_rec.reference_id,
	X_REFERENCE_NUMBER      => x_loan_header_rec.reference_number,
	X_REFERENCE_DESCRIPTION => x_loan_header_rec.reference_description,
	X_REFERENCE_AMOUNT	=> x_loan_header_rec.reference_amount,
	X_PRODUCT_FLAG          => x_loan_header_rec.product_flag,
	X_PRIMARY_BORROWER_ID   => x_loan_header_rec.primary_borrower_id,
	X_PRODUCT_ID            => x_loan_header_rec.product_id,
	X_REQUESTED_AMOUNT      => x_loan_header_rec.requested_amount,
	X_FUNDED_AMOUNT         => x_loan_header_rec.funded_amount,
	X_LOAN_APPROVAL_DATE    => x_loan_header_rec.loan_approval_date,
	X_LOAN_APPROVED_BY      => x_loan_header_rec.loan_approved_by,
	X_ATTRIBUTE_CATEGORY    => x_loan_header_rec.attribute_category,
	X_ATTRIBUTE1            => x_loan_header_rec.attribute1,
	X_ATTRIBUTE2            => x_loan_header_rec.attribute2,
	X_ATTRIBUTE3            => x_loan_header_rec.attribute3,
	X_ATTRIBUTE4            => x_loan_header_rec.attribute4,
	X_ATTRIBUTE5            => x_loan_header_rec.attribute5,
	X_ATTRIBUTE6            => x_loan_header_rec.attribute6,
	X_ATTRIBUTE7            => x_loan_header_rec.attribute7,
	X_ATTRIBUTE8            => x_loan_header_rec.attribute8,
	X_ATTRIBUTE9            => x_loan_header_rec.attribute9,
	X_ATTRIBUTE10           => x_loan_header_rec.attribute10,
	X_ATTRIBUTE11           => x_loan_header_rec.attribute11,
	X_ATTRIBUTE12           => x_loan_header_rec.attribute12,
	X_ATTRIBUTE13           => x_loan_header_rec.attribute13,
	X_ATTRIBUTE14           => x_loan_header_rec.attribute14,
	X_ATTRIBUTE15           => x_loan_header_rec.attribute15,
	X_ATTRIBUTE16           => x_loan_header_rec.attribute16,
	X_ATTRIBUTE17           => x_loan_header_rec.attribute17,
	X_ATTRIBUTE18           => x_loan_header_rec.attribute18,
	X_ATTRIBUTE19           => x_loan_header_rec.attribute19,
	X_ATTRIBUTE20           => x_loan_header_rec.attribute20,
	X_LAST_BILLED_DATE      => x_loan_header_rec.last_billed_date,
	X_CUSTOM_PAYMENTS_FLAG  => x_loan_header_rec.custom_payments_flag,
	X_BILLED_FLAG           => x_loan_header_rec.billed_flag,
	X_REFERENCE_NAME	=> x_loan_header_rec.reference_name,
	X_REFERENCE_TYPE	=> x_loan_header_rec.reference_type,
	X_REFERENCE_TYPE_ID	=> x_loan_header_rec.reference_type_id,
	X_USSGL_TRANSACTION_CODE => x_loan_header_rec.ussgl_transaction_code,
	X_GL_DATE		=> x_loan_header_rec.gl_date,
	X_REC_ADJUSTMENT_NUMBER	=> x_loan_header_rec.REC_ADJUSTMENT_NUMBER,
	X_CONTACT_REL_PARTY_ID	=> x_loan_header_rec.CONTACT_REL_PARTY_ID,
	X_CONTACT_PERS_PARTY_ID	=> x_loan_header_rec.CONTACT_PERS_PARTY_ID,
	X_CREDIT_REVIEW_FLAG	=> x_loan_header_rec.CREDIT_REVIEW_FLAG,
	X_EXCHANGE_RATE_TYPE	=> x_loan_header_rec.EXCHANGE_RATE_TYPE,
	X_EXCHANGE_DATE		=> x_loan_header_rec.EXCHANGE_DATE,
	X_EXCHANGE_RATE		=> x_loan_header_rec.EXCHANGE_RATE,
	X_COLLATERAL_PERCENT	=> x_loan_header_rec.COLLATERAL_PERCENT,
	X_LAST_PAYMENT_NUMBER	=> x_loan_header_rec.LAST_PAYMENT_NUMBER,
	X_LAST_AMORTIZATION_ID	=> x_loan_header_rec.LAST_AMORTIZATION_ID,
	X_LEGAL_ENTITY_ID     	=> x_loan_header_rec.LEGAL_ENTITY_ID,
	X_OPEN_TO_TERM_FLAG  => x_loan_header_rec.OPEN_TO_TERM_FLAG,
	X_MULTIPLE_FUNDING_FLAG  => x_loan_header_rec.MULTIPLE_FUNDING_FLAG,
	X_LOAN_TYPE_ID   => x_loan_header_rec.LOAN_TYPE_ID,
	X_SECONDARY_STATUS  => x_loan_header_rec.SECONDARY_STATUS,
	X_OPEN_TO_TERM_EVENT  => x_loan_header_rec.OPEN_TO_TERM_EVENT,
	X_BALLOON_PAYMENT_TYPE  => x_loan_header_rec.BALLOON_PAYMENT_TYPE,
	X_BALLOON_PAYMENT_AMOUNT  => x_loan_header_rec.BALLOON_PAYMENT_AMOUNT,
	X_CURRENT_PHASE  => x_loan_header_rec.CURRENT_PHASE,
	X_OPEN_LOAN_START_DATE  => x_loan_header_rec.OPEN_LOAN_START_DATE,
	X_OPEN_LOAN_TERM  => x_loan_header_rec.OPEN_LOAN_TERM,
	X_OPEN_LOAN_TERM_PERIOD  => x_loan_header_rec.OPEN_LOAN_TERM_PERIOD,
	X_OPEN_MATURITY_DATE  => x_loan_header_rec.OPEN_MATURITY_DATE,
	X_FUNDS_RESERVED_FLAG  => x_loan_header_rec.FUNDS_RESERVED_FLAG,
	X_FUNDS_CHECK_DATE  => x_loan_header_rec.FUNDS_CHECK_DATE,
	X_SUBSIDY_RATE  => x_loan_header_rec.SUBSIDY_RATE,
	X_APPLICATION_ID  => x_loan_header_rec.APPLICATION_ID,
	X_CREATED_BY_MODULE  => x_loan_header_rec.CREATED_BY_MODULE,
	X_PARTY_TYPE  => x_loan_header_rec.PARTY_TYPE,
	X_FORGIVENESS_FLAG	=> x_loan_header_rec.FORGIVENESS_FLAG,
	X_FORGIVENESS_PERCENT	=> x_loan_header_rec.FORGIVENESS_PERCENT,
	X_DISABLE_BILLING_FLAG	=> x_loan_header_rec.DISABLE_BILLING_FLAG,
	X_ADD_REQUESTED_AMOUNT	=> x_loan_header_rec.ADD_REQUESTED_AMOUNT
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_loan_header_rec;

END LNS_LOAN_HEADER_PUB;

/
