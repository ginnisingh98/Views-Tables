--------------------------------------------------------
--  DDL for Package Body LNS_TERMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_TERMS_PUB" AS
 /*$Header: LNS_TERMS_PUBP_B.pls 120.8.12010000.12 2010/03/19 08:43:11 gparuchu ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'LNS_TERMS_PUB';

--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------

PROCEDURE do_create_term (p_loan_term_rec      IN OUT NOCOPY LOAN_TERM_REC_TYPE
                         ,x_term_id               OUT NOCOPY    NUMBER
                         ,x_return_status      IN OUT NOCOPY VARCHAR2);

PROCEDURE do_update_term (p_loan_term_rec          IN OUT NOCOPY LOAN_TERM_REC_TYPE
                         ,p_object_version_number  IN OUT NOCOPY NUMBER
                         ,x_return_status          IN OUT NOCOPY VARCHAR2);

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;


-----------------------------
-- body of private procedures
-----------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_term
 |
 | DESCRIPTION
 |              Creates term.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_term_id
 |              IN/OUT:
 |                    p_loan_term_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   21-Dec-2003     Karthik Ramachandran       Created.
 +===========================================================================*/
PROCEDURE do_create_term (p_loan_term_rec         IN OUT NOCOPY LOAN_TERM_REC_TYPE
                         ,x_term_id                  OUT NOCOPY    NUMBER
                         ,x_return_status         IN OUT NOCOPY VARCHAR2) IS

    l_term_id             NUMBER;
    l_rowid               ROWID := NULL;
    l_dummy               VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_loan_start_date	    DATE;
    l_pmt_start_date	    DATE;

    Cursor c_get_loan_start_date(p_loan_id number) is
    select loan_start_date from lns_loan_headers_all
    where loan_id=p_loan_id;

BEGIN
    l_term_id := p_loan_term_rec.term_id;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - Begin do_create_term procedure');
    -- if primary key value is passed, check for uniqueness.
    IF l_term_id IS NOT NULL AND
        l_term_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_TERMS
            WHERE  term_id = l_term_id;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'term_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- begin raverma 01-24-2006 add validation for day count
    validate_term (p_init_msg_list   => FND_API.G_FALSE
                  ,p_loan_term_rec   => p_loan_term_rec
                  ,x_return_status   => x_return_status
                  ,x_msg_count       => l_msg_count
                  ,x_msg_data        => l_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Set default values for billing
    IF (p_loan_term_rec.payment_application_order is null) THEN
        p_loan_term_rec.payment_application_order := 'INT_PRIN';
    END IF;
    IF (p_loan_term_rec.loan_payment_frequency is null) THEN
        p_loan_term_rec.loan_payment_frequency := 'MONTHLY';
    END IF;

    IF (p_loan_term_rec.first_payment_date is null) THEN
      open c_get_loan_start_date(p_loan_term_rec.loan_id);
      fetch c_get_loan_start_date into l_loan_start_date;
      close c_get_loan_start_date;
    	if (l_loan_start_date is not null) then
          l_pmt_start_date := lns_fin_utils.getNextDate(p_date          => l_loan_start_date
                                                       ,p_interval_type => p_loan_term_rec.loan_payment_frequency
                                                       ,p_direction     => 1);
    	end if;
      if (l_pmt_start_date is not null) then
        p_loan_term_rec.first_payment_date := l_pmt_start_date;
      end if;
    END IF;

    IF (p_loan_term_rec.next_payment_due_date is null) THEN
        p_loan_term_rec.next_payment_due_date := p_loan_term_rec.first_payment_date;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In do_create_term procedure: Before call to LNS_TERMS_PKG.Insert_Row');

    -- call table-handler.
    LNS_TERMS_PKG.Insert_Row (X_TERM_ID                        => p_loan_term_rec.term_id
                             ,X_LOAN_ID                        => p_loan_term_rec.loan_id
                             ,X_OBJECT_VERSION_NUMBER          => 1
                             ,X_DAY_COUNT_METHOD               => p_loan_term_rec.day_count_method
                             ,X_BASED_ON_BALANCE               => p_loan_term_rec.based_on_balance
                             ,X_FIRST_RATE_CHANGE_DATE         => p_loan_term_rec.first_rate_change_date
                             ,X_NEXT_RATE_CHANGE_DATE          => p_loan_term_rec.next_rate_change_date
                             ,X_PERCENT_INCREASE               => p_loan_term_rec.percent_increase
                             ,X_PERCENT_INCREASE_TERM          => p_loan_term_rec.percent_increase_term
                             ,X_PAYMENT_APPLICATION_ORDER      => p_loan_term_rec.payment_application_order
                             ,X_PREPAY_PENALTY_FLAG            => p_loan_term_rec.prepay_penalty_flag
                             ,X_PREPAY_PENALTY_DATE            => p_loan_term_rec.prepay_penalty_date
                             ,X_CEILING_RATE                   => p_loan_term_rec.ceiling_rate
                             ,X_FLOOR_RATE                     => p_loan_term_rec.floor_rate
                             ,X_DELINQUENCY_THRESHOLD_NUMBER   => p_loan_term_rec.delinquency_threshold_number
                             ,X_DELINQUENCY_THRESHOLD_AMOUNT   => p_loan_term_rec.delinquency_threshold_amount
                             ,X_CALCULATION_METHOD             => p_loan_term_rec.calculation_method
                             ,X_REAMORTIZE_UNDER_PAYMENT       => p_loan_term_rec.reamortize_under_payment
                             ,X_REAMORTIZE_OVER_PAYMENT        => p_loan_term_rec.reamortize_over_payment
                             ,X_REAMORTIZE_WITH_INTEREST       => p_loan_term_rec.reamortize_with_interest
                             ,X_LOAN_PAYMENT_FREQUENCY         => p_loan_term_rec.loan_payment_frequency
                             ,X_INTEREST_COMPOUNDING_FREQ      => p_loan_term_rec.interest_compounding_freq
                             ,X_AMORTIZATION_FREQUENCY         => p_loan_term_rec.amortization_frequency
                             ,X_NUMBER_GRACE_DAYS              => p_loan_term_rec.number_grace_days
                             ,X_RATE_TYPE                      => p_loan_term_rec.rate_type
                             ,X_INDEX_NAME                     => p_loan_term_rec.index_name
                             ,X_ADJUSTMENT_FREQUENCY           => p_loan_term_rec.adjustment_frequency
                             ,X_ADJUSTMENT_FREQUENCY_TYPE      => p_loan_term_rec.adjustment_frequency_type
                             ,X_FIXED_RATE_PERIOD              => p_loan_term_rec.fixed_rate_period
                             ,X_FIXED_RATE_PERIOD_TYPE         => p_loan_term_rec.fixed_rate_period_type
                             ,X_FIRST_PAYMENT_DATE             => p_loan_term_rec.first_payment_date
                             ,X_NEXT_PAYMENT_DUE_DATE          => p_loan_term_rec.next_payment_due_date
                             ,X_OPEN_FIRST_PAYMENT_DATE        => p_loan_term_rec.open_first_payment_date
                             ,X_OPEN_PAYMENT_FREQUENCY         => p_loan_term_rec.open_payment_frequency
                             ,X_OPEN_NEXT_PAYMENT_DATE         => p_loan_term_rec.open_next_payment_date
                             ,X_LOCK_IN_DATE                   => p_loan_term_rec.lock_in_date
                             ,X_LOCK_TO_DATE                   => p_loan_term_rec.lock_to_date
                             ,X_RATE_CHANGE_FREQUENCY          => p_loan_term_rec.rate_change_frequency
                             ,X_INDEX_RATE_ID                  => p_loan_term_rec.index_rate_id
                             ,X_PERCENT_INCREASE_LIFE          => p_loan_term_rec.PERCENT_INCREASE_LIFE
                             ,X_FIRST_PERCENT_INCREASE         => p_loan_term_rec.FIRST_PERCENT_INCREASE
                             ,X_OPEN_PERCENT_INCREASE          => p_loan_term_rec.OPEN_PERCENT_INCREASE
                             ,X_OPEN_PERCENT_INCREASE_LIFE     => p_loan_term_rec.OPEN_PERCENT_INCREASE_LIFE
                             ,X_OPEN_FIRST_PERCENT_INCREASE    => p_loan_term_rec.OPEN_FIRST_PERCENT_INCREASE
                             ,X_PMT_APPL_ORDER_SCOPE           => p_loan_term_rec.PMT_APPL_ORDER_SCOPE
                             ,X_OPEN_CEILING_RATE              => p_loan_term_rec.OPEN_CEILING_RATE
                             ,X_OPEN_FLOOR_RATE                => p_loan_term_rec.OPEN_FLOOR_RATE
                             ,X_OPEN_INDEX_DATE                => p_loan_term_rec.OPEN_INDEX_DATE
                             ,X_TERM_INDEX_DATE                => p_loan_term_rec.TERM_INDEX_DATE
                             ,X_OPEN_PROJECTED_RATE            => p_loan_term_rec.OPEN_PROJECTED_RATE
                             ,X_TERM_PROJECTED_RATE            => p_loan_term_rec.TERM_PROJECTED_RATE
                             ,X_PAYMENT_CALC_METHOD            => p_loan_term_rec.PAYMENT_CALC_METHOD
 			     ,X_CUSTOM_CALC_METHOD	       => p_loan_term_rec.CUSTOM_CALC_METHOD
        		     ,X_ORIG_PAY_CALC_METHOD	       => p_loan_term_rec.ORIG_PAY_CALC_METHOD
			     ,X_PRIN_FIRST_PAY_DATE            => p_loan_term_rec.PRIN_FIRST_PAY_DATE
                             ,X_PRIN_PAYMENT_FREQUENCY         => p_loan_term_rec.PRIN_PAYMENT_FREQUENCY
			     ,X_PENAL_INT_RATE		       => p_loan_term_rec.PENAL_INT_RATE
			     ,X_PENAL_INT_GRACE_DAYS           => p_loan_term_rec.PENAL_INT_GRACE_DAYS
			     ,X_CALC_ADD_INT_UNPAID_PRIN       => p_loan_term_rec.CALC_ADD_INT_UNPAID_PRIN
			     ,X_CALC_ADD_INT_UNPAID_INT	       => p_loan_term_rec.CALC_ADD_INT_UNPAID_INT
                             ,X_REAMORTIZE_ON_FUNDING	       => p_loan_term_rec.REAMORTIZE_ON_FUNDING
			     );

    x_term_id := p_loan_term_rec.term_id;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In do_create_term procedure: After call to LNS_TERMS.Insert_Row');

END do_create_term;


/*===========================================================================+
 | PROCEDURE
 |              do_update_term
 |
 | DESCRIPTION
 |              Updates term.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_loan_term_rec
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   21-Dec-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE do_update_term(p_loan_term_rec           IN OUT NOCOPY LOAN_TERM_REC_TYPE
                        ,p_object_version_number   IN OUT NOCOPY NUMBER
                        ,x_return_status           IN OUT NOCOPY VARCHAR2) IS

    l_object_version_number NUMBER;
    l_rowid                 ROWID;
    ldup_rowid              ROWID;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

BEGIN

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - Begin do_update_term procedure');

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   LNS_TERMS
        WHERE  TERM_ID = p_loan_term_rec.term_id
        FOR UPDATE OF TERM_ID NOWAIT;

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
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_terms');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'loan_term_rec');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_loan_term_rec.term_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- begin raverma 01-24-2006 add validation for day count
    validate_term (p_init_msg_list   => FND_API.G_FALSE
                  ,p_loan_term_rec   => p_loan_term_rec
                  ,x_return_status   => x_return_status
                  ,x_msg_count       => l_msg_count
                  ,x_msg_data        => l_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In do_update_term procedure: Before call to LNS_TERMS_PKG.Update_Row');

    p_object_version_number := nvl(l_object_version_number, 1) + 1;

    --Call to table-handler
    LNS_TERMS_PKG.Update_Row (
        X_Rowid                   => l_rowid,
        X_TERM_ID                   => p_loan_term_rec.term_id,
        X_LOAN_ID                   => p_loan_term_rec.loan_id,
        X_OBJECT_VERSION_NUMBER     => p_object_version_number,
        X_DAY_COUNT_METHOD          => p_loan_term_rec.day_count_method,
        X_BASED_ON_BALANCE          => p_loan_term_rec.based_on_balance,
        X_FIRST_RATE_CHANGE_DATE    => p_loan_term_rec.first_rate_change_date,
        X_NEXT_RATE_CHANGE_DATE     => p_loan_term_rec.next_rate_change_date,
        X_PERCENT_INCREASE          => p_loan_term_rec.percent_increase,
        X_PERCENT_INCREASE_TERM     => p_loan_term_rec.percent_increase_term,
        X_PAYMENT_APPLICATION_ORDER => p_loan_term_rec.payment_application_order,
        X_PREPAY_PENALTY_FLAG       => p_loan_term_rec.prepay_penalty_flag,
        X_PREPAY_PENALTY_DATE       => p_loan_term_rec.prepay_penalty_date,
        X_CEILING_RATE              => p_loan_term_rec.ceiling_rate,
        X_FLOOR_RATE                => p_loan_term_rec.floor_rate,
        X_DELINQUENCY_THRESHOLD_NUMBER  => p_loan_term_rec.delinquency_threshold_number,
        X_DELINQUENCY_THRESHOLD_AMOUNT  => p_loan_term_rec.delinquency_threshold_amount,
        X_CALCULATION_METHOD        => p_loan_term_rec.calculation_method,
        X_REAMORTIZE_UNDER_PAYMENT  => p_loan_term_rec.reamortize_under_payment,
        X_REAMORTIZE_OVER_PAYMENT   => p_loan_term_rec.reamortize_over_payment,
        X_REAMORTIZE_WITH_INTEREST  => p_loan_term_rec.reamortize_with_interest,
        X_LOAN_PAYMENT_FREQUENCY    => p_loan_term_rec.loan_payment_frequency,
        X_INTEREST_COMPOUNDING_FREQ => p_loan_term_rec.interest_compounding_freq,
        X_AMORTIZATION_FREQUENCY    => p_loan_term_rec.amortization_frequency,
        X_NUMBER_GRACE_DAYS         => p_loan_term_rec.number_grace_days,
        X_RATE_TYPE                 => p_loan_term_rec.rate_type,
        X_INDEX_NAME                => p_loan_term_rec.index_name,
        X_ADJUSTMENT_FREQUENCY      => p_loan_term_rec.adjustment_frequency,
        X_ADJUSTMENT_FREQUENCY_TYPE => p_loan_term_rec.adjustment_frequency_type,
        X_FIXED_RATE_PERIOD         => p_loan_term_rec.fixed_rate_period,
        X_FIXED_RATE_PERIOD_TYPE    => p_loan_term_rec.fixed_rate_period_type,
        X_FIRST_PAYMENT_DATE        => p_loan_term_rec.first_payment_date,
        X_NEXT_PAYMENT_DUE_DATE     => p_loan_term_rec.next_payment_due_date,
        X_OPEN_FIRST_PAYMENT_DATE   => p_loan_term_rec.open_first_payment_date,
        X_OPEN_PAYMENT_FREQUENCY    => p_loan_term_rec.open_payment_frequency,
        X_OPEN_NEXT_PAYMENT_DATE    => p_loan_term_rec.open_next_payment_date,
        X_LOCK_IN_DATE              => p_loan_term_rec.lock_in_date,
        X_LOCK_TO_DATE              => p_loan_term_rec.lock_to_date,
        X_RATE_CHANGE_FREQUENCY     => p_loan_term_rec.rate_change_frequency,
        X_INDEX_RATE_ID             => p_loan_term_rec.index_rate_id,
        X_PERCENT_INCREASE_LIFE     => p_loan_term_rec.PERCENT_INCREASE_LIFE,
        X_FIRST_PERCENT_INCREASE    => p_loan_term_rec.FIRST_PERCENT_INCREASE,
        X_OPEN_PERCENT_INCREASE     => p_loan_term_rec.OPEN_PERCENT_INCREASE,
        X_OPEN_PERCENT_INCREASE_LIFE    => p_loan_term_rec.OPEN_PERCENT_INCREASE_LIFE,
        X_OPEN_FIRST_PERCENT_INCREASE   => p_loan_term_rec.OPEN_FIRST_PERCENT_INCREASE,
        X_PMT_APPL_ORDER_SCOPE      => p_loan_term_rec.PMT_APPL_ORDER_SCOPE,
        X_OPEN_CEILING_RATE         => p_loan_term_rec.OPEN_CEILING_RATE,
        X_OPEN_FLOOR_RATE           => p_loan_term_rec.OPEN_FLOOR_RATE,
        X_OPEN_INDEX_DATE           => p_loan_term_rec.OPEN_INDEX_DATE,
        X_TERM_INDEX_DATE           => p_loan_term_rec.TERM_INDEX_DATE,
        X_OPEN_PROJECTED_RATE       => p_loan_term_rec.OPEN_PROJECTED_RATE,
        X_TERM_PROJECTED_RATE       => p_loan_term_rec.TERM_PROJECTED_RATE,
        X_PAYMENT_CALC_METHOD       => p_loan_term_rec.PAYMENT_CALC_METHOD,
        X_CUSTOM_CALC_METHOD	    => p_loan_term_rec.CUSTOM_CALC_METHOD,
        X_ORIG_PAY_CALC_METHOD	    => p_loan_term_rec.ORIG_PAY_CALC_METHOD,
	X_PRIN_FIRST_PAY_DATE	    => p_loan_term_rec.PRIN_FIRST_PAY_DATE,
        X_PRIN_PAYMENT_FREQUENCY    => p_loan_term_rec.PRIN_PAYMENT_FREQUENCY,
        X_PENAL_INT_RATE            => p_loan_term_rec.PENAL_INT_RATE,
        X_PENAL_INT_GRACE_DAYS      => p_loan_term_rec.PENAL_INT_GRACE_DAYS,
	X_CALC_ADD_INT_UNPAID_PRIN  => p_loan_term_rec.CALC_ADD_INT_UNPAID_PRIN,
        X_CALC_ADD_INT_UNPAID_INT   => p_loan_term_rec.CALC_ADD_INT_UNPAID_INT,
	X_REAMORTIZE_ON_FUNDING     => p_loan_term_rec.REAMORTIZE_ON_FUNDING

        );

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In do_update_term procedure: After call to LNS_TERMS_PKG.Update_Row');

END do_update_term;

PROCEDURE default_delinquency_amount(
    p_term_id               IN NUMBER,
    p_loan_id		    IN NUMBER,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
) IS

    l_amortization_tbl      LNS_FINANCIALS.AMORTIZATION_TBL;
    l_amortization_rec	        LNS_FINANCIALS.AMORTIZATION_REC;
    l_delinq_amt	            NUMBER := NULL;
    l_loan_term_rec	            LOAN_TERM_REC_TYPE;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    --l_fees_tbl                  LNS_FINANCIALS.FEES_TBL;
    l_object_version_number     number;

BEGIN

    -- fix for bug 8830789

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In default_delinquency_amount procedure: Before call to default_delinquency_amount');

    lns_financials.amortizeLoan(p_loan_Id            => p_loan_id
                            ,p_installment_number => 1
                            ,p_based_on_terms     => 'ORIGINAL'
                            ,x_loan_amort_tbl     => l_amortization_tbl);

    FOR i IN 1..l_amortization_tbl.COUNT LOOP
        if l_amortization_tbl(i).INSTALLMENT_NUMBER = 1 then
            l_amortization_rec := l_amortization_tbl(i);
            l_delinq_amt := nvl(l_amortization_rec.principal_amount, 0) + nvl(l_amortization_rec.interest_amount, 0) + nvl(l_amortization_rec.fee_amount, 0);
            exit;
        end if;
    END LOOP;

    l_loan_term_rec.delinquency_threshold_amount := l_delinq_amt;
    l_loan_term_rec.loan_id := p_loan_id;
    l_loan_term_rec.term_id := p_term_id;

    select OBJECT_VERSION_NUMBER
    into l_object_version_number
    from LNS_TERMS
    where term_id = p_term_id;

    LNS_TERMS_PUB.update_term(
            p_init_msg_list         => FND_API.G_FALSE,
            p_loan_term_rec         => l_loan_term_rec,
            p_object_version_number => l_object_version_number,
            X_RETURN_STATUS         => x_return_status,
            X_MSG_COUNT             => l_msg_count,
            X_MSG_DATA              => l_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In default_delinquency_amount procedure: After call to default_delinquency_amount');

END default_delinquency_amount;


PROCEDURE calculate_delinquency_amount(
    p_loan_id		    IN NUMBER,
    p_delinq_amt	    IN OUT NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
) IS

    l_amortization_tbl      LNS_FINANCIALS.AMORTIZATION_TBL;
    l_amortization_rec	    LNS_FINANCIALS.AMORTIZATION_REC;
    l_delinq_amt	    NUMBER := NULL;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_fees_tbl              LNS_FINANCIALS.FEES_TBL;

BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In calculate_delinquency_amount procedure');
      END IF;


     lns_financials.amortizeLoan(p_loan_Id       => p_loan_id
                            ,p_installment_number => 1
                            ,p_based_on_terms     => 'ORIGINAL'
                            ,x_loan_amort_tbl     => l_amortization_tbl);

      FOR i IN 1..l_amortization_tbl.COUNT LOOP
        if l_amortization_tbl(i).INSTALLMENT_NUMBER = 1 then
           l_amortization_rec := l_amortization_tbl(i);
           l_delinq_amt := nvl(l_amortization_rec.principal_amount, 0) + nvl(l_amortization_rec.interest_amount, 0) + nvl(l_amortization_rec.fee_amount, 0);
           exit;
        end if;
      END LOOP;
      p_delinq_amt := l_delinq_amt;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Exiting calculate_delinquency_amount procedure');
      END IF;

END calculate_delinquency_amount;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_term
 |
 | DESCRIPTION
 |              Creates term.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_term_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_term_id
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   21-Dec-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE create_term (
    p_init_msg_list   IN      VARCHAR2,
    p_loan_term_rec IN      LOAN_TERM_REC_TYPE,
    x_term_id         OUT NOCOPY     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'create_term';
    l_loan_term_rec LOAN_TERM_REC_TYPE;

BEGIN
    l_loan_term_rec := p_loan_term_rec;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - Begin Create_Term procedure');

    -- standard start of API savepoint
    SAVEPOINT create_term;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF (p_init_msg_list is not null and FND_API.to_Boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In Create_Term procedure: Before call to do_create_term proc');

    -- call to business logic.
    do_create_term(
                   l_loan_term_rec,
                   x_term_id,
                   x_return_status
                  );

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In Create_Term procedure: After call to do_create_term proc');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_term;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_term;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_term;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Create_Term procedure');
    END IF;

END create_term;

/*===========================================================================+
 | PROCEDURE
 |              update_term
 |
 | DESCRIPTION
 |              Updates term.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_term_rec
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
 |   21-Dec-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE update_term (
    p_init_msg_list         IN      VARCHAR2,
    p_loan_term_rec       IN      LOAN_TERM_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_term';
    l_loan_term_rec     LOAN_TERM_REC_TYPE;
    l_old_loan_term_rec LOAN_TERM_REC_TYPE;

BEGIN

    l_loan_term_rec := p_loan_term_rec;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - Begin Update_Term procedure');

    -- standard start of API savepoint
    SAVEPOINT update_term;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF (p_init_msg_list is not null and FND_API.to_Boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old record. Will be used by history package.
    get_loan_term_rec (
        p_init_msg_list   => FND_API.G_FALSE,
        p_term_id         => l_loan_term_rec.term_id,
        x_loan_term_rec   => l_old_loan_term_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In Update_Term procedure: Before call to do_update_term proc');

    -- call to business logic.
    do_update_term(
                   l_loan_term_rec,
                   p_object_version_number,
                   x_return_status
                  );

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - In Update_Term procedure: After call to do_update_term proc');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_term;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_term;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_term;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Update_Term procedure');
    END IF;

END update_term;

/*===========================================================================+
 | PROCEDURE
 |              validate_term
 |
 | DESCRIPTION
 |              Validates term.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_loan_term_rec
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
 |   18-Jan-2004     Karthik Ramachandran       Created.
||   22-Jan-2006     raverma                    implement day count validation
 +===========================================================================*/

PROCEDURE validate_term (
    p_init_msg_list   IN  VARCHAR2,
    p_loan_term_rec   IN  LOAN_TERM_REC_TYPE,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'validate_term';
    l_loan_term_rec   LOAN_TERM_REC_TYPE;

    /*
    cursor c_validate_day_count(p_loan_id in number) is
    select day_count_method
          ,amortization_frequency
      from lns_terms
     where loan_id = p_loan_id;
     */
BEGIN
    l_loan_term_rec := p_loan_term_rec;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - Begin Validate_Term procedure');

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- day count method must be ACTUAL/ACTUAL if less than MONTHLY AMORTIZATION
    --open c_validate_day_count(l_loan_term_rec.loan_id);
    --fetch c_validate_day_count into l_loan_term_rec.DAY_COUNT_METHOD, l_loan_term_rec.AMORTIZATION_FREQUENCY;
    --close c_validate_day_count;

    if ((p_loan_term_rec.payment_calc_method = 'SEPARATE_SCHEDULES' and
         (p_loan_term_rec.prin_payment_frequency = 'BIWEEKLY' or
          p_loan_term_rec.prin_payment_frequency = 'SEMI-MONTHLY' or
          p_loan_term_rec.prin_payment_frequency = 'WEEKLY')) or
        (p_loan_term_rec.AMORTIZATION_FREQUENCY = 'BIWEEKLY' or
         p_loan_term_rec.AMORTIZATION_FREQUENCY = 'SEMI-MONTHLY' or
         p_loan_term_rec.AMORTIZATION_FREQUENCY = 'WEEKLY')) AND
       (p_loan_term_rec.DAY_COUNT_METHOD <> 'ACTUAL_ACTUAL' AND
        p_loan_term_rec.DAY_COUNT_METHOD <> 'ACTUAL_360' AND
        p_loan_term_rec.DAY_COUNT_METHOD <> 'ACTUAL_365' AND
        p_loan_term_rec.DAY_COUNT_METHOD <> 'ACTUAL_365L')
    then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_DAY_COUNT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - End Validate_Term procedure');


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

END validate_term;

/*===========================================================================+
 | PROCEDURE
 |              get_loan_term_rec
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
 |                    p_term_id
 |              OUT:
 |                    x_loan_term_rec
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
 |   21-Dec-2003     Karthik Ramachandran       Created.
 +===========================================================================*/

PROCEDURE get_loan_term_rec (
    p_init_msg_list   IN  VARCHAR2,
    p_term_id         IN  NUMBER,
    x_loan_term_rec   OUT NOCOPY LOAN_TERM_REC_TYPE,
    x_return_status   OUT NOCOPY    VARCHAR2,
    x_msg_count       OUT NOCOPY    NUMBER,
    x_msg_data        OUT NOCOPY    VARCHAR2
) IS

    l_api_name  CONSTANT VARCHAR2(30) := 'get_loan_term_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF (p_init_msg_list is not null AND FND_API.to_Boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_term_id IS NULL OR p_term_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'term_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_loan_term_rec.term_id := p_term_id;

    --Call to table-handler
    LNS_TERMS_PKG.Select_Row (
                    X_TERM_ID           => x_loan_term_rec.term_id,
                    X_LOAN_ID           => x_loan_term_rec.loan_id,
                    X_DAY_COUNT_METHOD      => x_loan_term_rec.day_count_method,
                    X_BASED_ON_BALANCE      => x_loan_term_rec.based_on_balance,
                    X_FIRST_RATE_CHANGE_DATE    => x_loan_term_rec.first_rate_change_date,
                    X_NEXT_RATE_CHANGE_DATE     => x_loan_term_rec.next_rate_change_date,
                    X_PERCENT_INCREASE      => x_loan_term_rec.percent_increase,
                    X_PERCENT_INCREASE_TERM     => x_loan_term_rec.percent_increase_term,
                    X_PAYMENT_APPLICATION_ORDER => x_loan_term_rec.payment_application_order,
                    X_PREPAY_PENALTY_FLAG       => x_loan_term_rec.prepay_penalty_flag,
                    X_PREPAY_PENALTY_DATE       => x_loan_term_rec.prepay_penalty_date,
                    X_CEILING_RATE          => x_loan_term_rec.ceiling_rate,
                    X_FLOOR_RATE            => x_loan_term_rec.floor_rate,
                    X_DELINQUENCY_THRESHOLD_NUMBER  => x_loan_term_rec.delinquency_threshold_number,
                    X_DELINQUENCY_THRESHOLD_AMOUNT  => x_loan_term_rec.delinquency_threshold_amount,
                    X_CALCULATION_METHOD        => x_loan_term_rec.calculation_method,
                    X_REAMORTIZE_UNDER_PAYMENT  => x_loan_term_rec.reamortize_under_payment,
                    X_REAMORTIZE_OVER_PAYMENT   => x_loan_term_rec.reamortize_over_payment,
                    X_REAMORTIZE_WITH_INTEREST  => x_loan_term_rec.reamortize_with_interest,
                    X_LOAN_PAYMENT_FREQUENCY    => x_loan_term_rec.loan_payment_frequency,
                    X_INTEREST_COMPOUNDING_FREQ => x_loan_term_rec.interest_compounding_freq,
                    X_AMORTIZATION_FREQUENCY    => x_loan_term_rec.amortization_frequency,
                    X_NUMBER_GRACE_DAYS     => x_loan_term_rec.number_grace_days,
                    X_RATE_TYPE         => x_loan_term_rec.rate_type,
                    X_INDEX_NAME            => x_loan_term_rec.index_name,
                    X_ADJUSTMENT_FREQUENCY      => x_loan_term_rec.adjustment_frequency,
                    X_ADJUSTMENT_FREQUENCY_TYPE => x_loan_term_rec.adjustment_frequency_type,
                    X_FIXED_RATE_PERIOD     => x_loan_term_rec.fixed_rate_period,
                    X_FIXED_RATE_PERIOD_TYPE    => x_loan_term_rec.fixed_rate_period_type,
                    X_FIRST_PAYMENT_DATE        => x_loan_term_rec.first_payment_date,
                    X_NEXT_PAYMENT_DUE_DATE     => x_loan_term_rec.next_payment_due_date,
                    X_OPEN_FIRST_PAYMENT_DATE   => x_loan_term_rec.open_first_payment_date,
                    X_OPEN_PAYMENT_FREQUENCY    => x_loan_term_rec.open_payment_frequency,
                    X_OPEN_NEXT_PAYMENT_DATE    => x_loan_term_rec.open_next_payment_date,
                    X_LOCK_IN_DATE          => x_loan_term_rec.lock_in_date,
                    X_LOCK_TO_DATE          => x_loan_term_rec.lock_to_date,
                    X_RATE_CHANGE_FREQUENCY     => x_loan_term_rec.rate_change_frequency,
                    X_INDEX_RATE_ID         => x_loan_term_rec.index_rate_id,
                    X_PERCENT_INCREASE_LIFE     => x_loan_term_rec.PERCENT_INCREASE_LIFE,
                    X_FIRST_PERCENT_INCREASE    => x_loan_term_rec.FIRST_PERCENT_INCREASE,
                    X_OPEN_PERCENT_INCREASE     => x_loan_term_rec.OPEN_PERCENT_INCREASE,
                    X_OPEN_PERCENT_INCREASE_LIFE    => x_loan_term_rec.OPEN_PERCENT_INCREASE_LIFE,
                    X_OPEN_FIRST_PERCENT_INCREASE   => x_loan_term_rec.OPEN_FIRST_PERCENT_INCREASE,
                    X_PMT_APPL_ORDER_SCOPE      => x_loan_term_rec.PMT_APPL_ORDER_SCOPE,
                    X_OPEN_CEILING_RATE       => x_loan_term_rec.OPEN_CEILING_RATE,
                    X_OPEN_FLOOR_RATE         => x_loan_term_rec.OPEN_FLOOR_RATE,
                    X_OPEN_INDEX_DATE         => x_loan_term_rec.OPEN_INDEX_DATE,
                    X_TERM_INDEX_DATE         => x_loan_term_rec.TERM_INDEX_DATE,
                    X_OPEN_PROJECTED_RATE       => x_loan_term_rec.OPEN_PROJECTED_RATE,
                    X_TERM_PROJECTED_RATE       => x_loan_term_rec.TERM_PROJECTED_RATE,
                    X_PAYMENT_CALC_METHOD       => x_loan_term_rec.PAYMENT_CALC_METHOD,
                    X_CUSTOM_CALC_METHOD	=> x_loan_term_rec.CUSTOM_CALC_METHOD,
                    X_ORIG_PAY_CALC_METHOD	=> x_loan_term_rec.ORIG_PAY_CALC_METHOD,
		    X_PRIN_FIRST_PAY_DATE	=> x_loan_term_rec.prin_first_pay_date,
                    X_PRIN_PAYMENT_FREQUENCY	=> x_loan_term_rec.prin_payment_frequency,
		    X_PENAL_INT_RATE            => x_loan_term_rec.PENAL_INT_RATE,
		    X_PENAL_INT_GRACE_DAYS      => x_loan_term_rec.PENAL_INT_GRACE_DAYS,
		    X_CALC_ADD_INT_UNPAID_PRIN  => x_loan_term_rec.CALC_ADD_INT_UNPAID_PRIN,
		    X_CALC_ADD_INT_UNPAID_INT   => x_loan_term_rec.CALC_ADD_INT_UNPAID_INT,
		    X_REAMORTIZE_ON_FUNDING     => x_loan_term_rec.REAMORTIZE_ON_FUNDING

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

END get_loan_term_rec;


/*========================================================================+
 | PROCEDURE
 |              validate_rate_schedule
 |
 | DESCRIPTION
 |              validates rate schedule and terms
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_loan_id
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |
 | RETURNS    : NONE
 |
 | NOTES
 | #1 we will only allow the interest only period(s) to be on the beginning of
 | the loan.  once a row is found in the rate schedule(s) that is not interest
 | only, then subsequent rows MAY NOT be interest only
 |
 | #2 first payment date MUST be within the interest only period.  We will not
 | allow for negative amortization at this time
 |
 | #3 loans that are interest only shall not re-amortize in the case of
 | overpayments and vice-versa loans that re-amortize may not contain an
 | interest only period on the rate schedule
 |
 | MODIFICATION HISTORY
 |   3-Nov-2004     raverma             Created. BUSH2004
 +=======================================================================*/
PROCEDURE validate_rate_schedule(p_loan_id       IN NUMBER
                                ,x_return_status IN OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY    NUMBER
                                ,x_msg_data      OUT NOCOPY    VARCHAR2)
is
    l_rate_schedule                  LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_api_name                       varchar2(25);
    l_interest_only                  varchar2(1);
    l_disallow_interest_only         boolean;
    l_interest_only_rows             number;
    l_last_interest_inst             number;
    l_reamortize_overpay             varchar2(1);
    l_first_payment_date             date;

    cursor c_interest_only_exists (p_loan_id number) is
    select count(1)
      from lns_rate_schedules rs,
           lns_terms term
     where term.loan_id = p_loan_id
       and term.term_id = rs.term_id
       and rs.interest_only_flag = 'Y'
       and rs.phase <> 'OPEN';

    cursor c_max_int_installment(p_loan_id number) is
    select max(end_installment_number)
      from lns_rate_schedules rs,
           lns_terms term
     where term.loan_id = p_loan_id
       and term.term_id = rs.term_id
       and rs.interest_only_flag = 'Y'
       and rs.phase <> 'OPEN';

    cursor c_reamortization(p_loan_id number) is
    select nvl(reamortize_over_payment, 'N')
      from lns_terms
     where loan_id = p_loan_id;

    cursor c_first_payment_date(p_loan_id number) is
    select first_payment_date
      from lns_terms
     where loan_id = p_loan_id;

begin
     l_api_name   := 'validate_rate_schedule';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;


     open  c_interest_only_exists(p_loan_id);
     fetch c_interest_only_exists into l_interest_only_rows;
     close c_interest_only_exists;

     --dbms_output.put_line('interest only # ' || l_interest_only_rows);
     if l_interest_only_rows > 0 then

         -- check to see if there is a reamortization = 'Y'
         open c_reamortization(p_loan_id);
         fetch c_reamortization into l_reamortize_overpay;
         close c_reamortization;

         --dbms_output.put_line('reamortize ' || l_reamortize_overpay);
         if l_reamortize_overpay = 'Y' then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_REAMORTIZE');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         end if;

         /* removing this validation as per conversation with ravi on 11-3-2004
         || he wants users to be able to enter in funky interest only combinations
         */
         /*
         if l_interest_only_rows > 1 then

             l_rate_schedule      := lns_financials.getRateSchedule(p_loan_id);
             l_interest_only      := 'Y';

             -- this will ensure that interest only periods are on the begining
             -- of the loan and are contiguous
             for k in 1..l_rate_schedule.count
             loop
                if l_rate_schedule(k).interest_only_flag = 'Y' and l_interest_only = 'N' then
                    dbms_output.put_line('output non continuous');
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_INTEREST_ONLY_BREAK');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                end if;
                l_interest_only := l_rate_schedule(k).interest_only_flag;

             end loop;
         end if;
         */
     end if;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - End');


EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
     	     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             	FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
     	     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	     	FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             END IF;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
     	     IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             	FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             END IF;

end validate_rate_schedule;


END LNS_TERMS_PUB;

/
