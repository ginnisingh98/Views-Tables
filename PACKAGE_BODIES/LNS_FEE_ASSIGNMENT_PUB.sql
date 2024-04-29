--------------------------------------------------------
--  DDL for Package Body LNS_FEE_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FEE_ASSIGNMENT_PUB" AS
/* $Header: LNS_FASGM_PUBP_B.pls 120.9.12010000.10 2010/03/19 08:40:01 gparuchu ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
-- G_DEBUG_COUNT                       CONSTANT NUMBER := 0;
-- G_DEBUG                             CONSTANT BOOLEAN := FALSE;

 G_PKG_NAME                          CONSTANT VARCHAR(30) := 'LNS_FEE_ASSIGNMENT_PUB';
 G_AF_DO_DEBUG 			     CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

PROCEDURE Set_Defaults (p_FEE_ASSIGNMENT_rec IN OUT NOCOPY FEE_ASSIGNMENT_REC_TYPE
)
IS
BEGIN

      IF (p_FEE_ASSIGNMENT_rec.begin_installment_number IS NULL) THEN
        p_FEE_ASSIGNMENT_rec.begin_installment_number := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_FEE_ASSIGNMENT_REC.loan_id);
      END IF;

      IF (p_FEE_ASSIGNMENT_rec.end_installment_number IS NULL) THEN
        p_FEE_ASSIGNMENT_rec.end_installment_number := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_FEE_ASSIGNMENT_REC.loan_id);
      END IF;

      IF (p_FEE_ASSIGNMENT_rec.phase IS NULL) THEN
        	p_FEE_ASSIGNMENT_rec.phase := 'TERM';
      END IF;

END Set_Defaults;
--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------

PROCEDURE do_create_fee_assignment (
    p_fee_assignment_rec      IN OUT NOCOPY FEE_ASSIGNMENT_REC_TYPE,
    x_fee_assignment_id              OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_fee_assignment (
    p_fee_assignment_rec        IN OUT NOCOPY FEE_ASSIGNMENT_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_delete_fee_assignment (
    p_fee_assignment_id        IN NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              do_create_fee_assignment
 |
 | DESCRIPTION
 |              Creates assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_fee_assignment_id
 |              IN/OUT:
 |                    p_fee_assignment_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_create_fee_assignment(
    p_fee_assignment_rec      IN OUT NOCOPY FEE_ASSIGNMENT_REC_TYPE,
    x_fee_assignment_id              OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
) IS

    l_fee_assignment_id         NUMBER;
    l_rowid                 ROWID;
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

BEGIN

    l_fee_assignment_id         := p_fee_assignment_rec.fee_assignment_id;
    l_rowid                 := NULL;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_create_fee_assignment procedure');
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_fee_assignment_id IS NOT NULL AND
        l_fee_assignment_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_FEE_ASSIGNMENTS
            WHERE  fee_assignment_id = l_fee_assignment_id;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'fee_assignment_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_fee_assignment procedure: Before call to LNS_FEE_ASSIGNMENTS_PKG.Insert_Row');
    END IF;

    -- call table-handler.
    LNS_FEE_ASSIGNMENTS_PKG.Insert_Row (
	  X_FEE_ASSIGNMENT_ID		=> p_fee_assignment_rec.fee_assignment_id,
	  P_OBJECT_VERSION_NUMBER	=> 1,
	  P_LOAN_ID			=> p_fee_assignment_rec.loan_id,
	  P_FEE_ID		=> p_fee_assignment_rec.fee_id,
	  P_FEE				=> p_fee_assignment_rec.fee,
	  P_FEE_TYPE			=> p_fee_assignment_rec.fee_type,
	  P_FEE_BASIS			=> p_fee_assignment_rec.fee_basis,
	  P_NUMBER_GRACE_DAYS		=> p_fee_assignment_rec.number_grace_days,
	  P_START_DATE_ACTIVE		=> p_fee_assignment_rec.start_date_active,
	  P_END_DATE_ACTIVE		=> p_fee_assignment_rec.end_date_active,
	  P_CREATED_BY			=> p_fee_assignment_rec.created_by,
	  P_CREATION_DATE		=> p_fee_assignment_rec.creation_date,
	  P_LAST_UPDATED_BY		=> p_fee_assignment_rec.last_updated_by,
	  P_LAST_UPDATE_DATE		=> p_fee_assignment_rec.last_update_date,
	  P_LAST_UPDATE_LOGIN		=> p_fee_assignment_rec.last_update_login,
	  P_COLLECTED_THIRD_PARTY_FLAG 	=> p_fee_assignment_rec.collected_third_party_flag,
	  P_RATE_TYPE			=> p_fee_assignment_rec.rate_type,
	  P_BEGIN_INSTALLMENT_NUMBER 	=> p_fee_assignment_rec.begin_installment_number,
	  P_END_INSTALLMENT_NUMBER 	=> p_fee_assignment_rec.end_installment_number,
	  P_NUMBER_OF_PAYMENTS 		=> p_fee_assignment_rec.number_of_payments,
	  P_BILLING_OPTION 		=> p_fee_assignment_rec.billing_option,
          P_DISB_HEADER_ID		=> p_fee_assignment_rec.disb_header_id,
	  P_DELETE_DISABLED_FLAG	=> p_fee_assignment_rec.delete_disabled_flag,
	  P_OPEN_PHASE_FLAG	 	=> p_fee_assignment_rec.open_phase_flag,
	  P_PHASE	 			=> p_fee_assignment_rec.phase
	);

	x_fee_assignment_id := p_fee_assignment_rec.fee_assignment_id;

	If ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_fee_assignment procedure: After call to LNS_FEE_ASSIGNMENT.Insert_Row');
    END IF;

END do_create_fee_assignment;


/*===========================================================================+
 | PROCEDURE
 |              do_update_fee_assignment
 |
 | DESCRIPTION
 |              Updates assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_fee_assignment_rec
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_update_fee_assignment(
    p_fee_assignment_rec          IN OUT NOCOPY FEE_ASSIGNMENT_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_object_version_number         NUMBER;
    l_rowid                         ROWID;
    ldup_rowid                      ROWID;

BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_update_fee_assignment procedure');
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER
        INTO   l_object_version_number
        FROM   LNS_FEE_ASSIGNMENTS
        WHERE  FEE_ASSIGNMENT_ID = p_fee_assignment_rec.fee_assignment_id
        FOR UPDATE OF FEE_ASSIGNMENT_ID NOWAIT;

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
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_fee_assignments');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'assignment_rec');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_fee_assignment_rec.fee_assignment_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_fee_assignment procedure: Before call to LNS_FEE_ASSIGNMENTS_PKG.Update_Row');
    END IF;

    -- log history
    LNS_LOAN_HISTORY_PUB.log_record_pre(p_fee_assignment_rec.fee_assignment_id,
					'FEE_ASSIGNMENT_ID',
					'LNS_FEE_ASSIGNMENTS');

    --Call to table-handler
    LNS_FEE_ASSIGNMENTS_PKG.Update_Row (
	  P_FEE_ASSIGNMENT_ID		=> p_fee_assignment_rec.fee_assignment_id,
	  P_LOAN_ID			=> p_fee_assignment_rec.LOAN_ID,
	  P_FEE_ID		=> p_fee_assignment_rec.FEE_ID,
	  P_FEE				=> p_fee_assignment_rec.FEE,
	  P_FEE_TYPE			=> p_fee_assignment_rec.fee_type,
	  P_FEE_BASIS			=> p_fee_assignment_rec.fee_basis,
	  P_NUMBER_GRACE_DAYS		=> p_fee_assignment_rec.NUMBER_GRACE_DAYS,
	  P_LAST_UPDATED_BY		=> null,
	  P_LAST_UPDATE_DATE		=> null,
	  P_LAST_UPDATE_LOGIN		=> null,
	  P_OBJECT_VERSION_NUMBER	=> p_OBJECT_VERSION_NUMBER,
	  P_COLLECTED_THIRD_PARTY_FLAG 	=> p_fee_assignment_rec.collected_third_party_flag,
	  P_BILLING_OPTION 		=> p_fee_assignment_rec.billing_option,
	  P_RATE_TYPE			=> p_fee_assignment_rec.rate_type,
	  P_BEGIN_INSTALLMENT_NUMBER 	=> p_fee_assignment_rec.begin_installment_number,
	  P_END_INSTALLMENT_NUMBER 	=> p_fee_assignment_rec.end_installment_number,
	  P_NUMBER_OF_PAYMENTS 		=> p_fee_assignment_rec.number_of_payments,
	  P_START_DATE_ACTIVE		=> null,
	  P_END_DATE_ACTIVE		=> p_fee_assignment_rec.end_date_active,
	  P_DISB_HEADER_ID		=> p_fee_assignment_rec.disb_header_id,
	  P_DELETE_DISABLED_FLAG	=> p_fee_assignment_rec.delete_disabled_flag,
	  P_OPEN_PHASE_FLAG		=> p_fee_assignment_rec.open_phase_flag,
	  P_PHASE				=> p_fee_assignment_rec.phase
);

    -- log record changes
    LNS_LOAN_HISTORY_PUB.log_record_post(p_fee_assignment_rec.fee_assignment_id,
					'FEE_ASSIGNMENT_ID',
					'LNS_FEE_ASSIGNMENTS',
					p_fee_assignment_rec.loan_id);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_fee_assignment procedure: After call to LNS_FEE_ASSIGNMENTS_PKG.Update_Row');
    END IF;

END do_update_fee_assignment;

/*===========================================================================+
 | PROCEDURE
 |              do_delete_fee_assignment
 |
 | DESCRIPTION
 |              Deletes assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_fee_assignment_id
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_delete_fee_assignment(
    p_fee_assignment_id           NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_loan_id                 NUMBER;
    l_fee_id		      NUMBER;
    l_object_version_num      NUMBER;
BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_delete_fee_assignment procedure');
    END IF;

    IF p_fee_assignment_id IS NOT NULL AND
      p_fee_assignment_id <> FND_API.G_MISS_NUM
    THEN
    -- check whether record has been deleted by another user. If not, lock it.
      BEGIN
        SELECT loan_id, fee_id, object_version_number
        INTO   l_loan_id, l_fee_id, l_object_version_num
        FROM   LNS_FEE_ASSIGNMENTS
        WHERE  FEE_ASSIGNMENT_ID = p_fee_assignment_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'assignment_rec');
          FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_fee_assignment_id), 'null'));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_fee_assignment procedure: Before call to LNS_FEE_ASSIGNMENTS_PKG.Delete_Row');
    END IF;

    -- log history
    LNS_LOAN_HISTORY_PUB.log_record_pre(p_fee_assignment_id,
					'FEE_ASSIGNMENT_ID',
					'LNS_FEE_ASSIGNMENTS');

    BEGIN

       -- Update the end date active before physically deleting the record
       -- to record it in history table

       UPDATE LNS_FEE_ASSIGNMENTS
       SET END_DATE_ACTIVE = SYSDATE
       WHERE LOAN_ID = l_loan_id
       AND FEE_ASSIGNMENT_ID = p_fee_assignment_id;


     -- log record changes
         LNS_LOAN_HISTORY_PUB.log_record_post(p_fee_assignment_id,
    					'FEE_ASSIGNMENT_ID',
    					'LNS_FEE_ASSIGNMENTS',
    					l_loan_id);

       LNS_FEE_ASSIGNMENTS_PKG.Delete_Row(
          P_FEE_ASSIGNMENT_ID           => p_fee_assignment_id);


    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;



    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_fee_assignment procedure: After call to LNS_FEE_ASSIGNMENTS_PKG.Delete_Row');
    END IF;

END do_delete_fee_assignment;

----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_fee_assignment
 |
 | DESCRIPTION
 |              Creates assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_fee_assignment_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_fee_assignment_id
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE create_fee_assignment (
    p_init_msg_list   IN      VARCHAR2,
    p_fee_assignment_rec IN      FEE_ASSIGNMENT_REC_TYPE,
    x_fee_assignment_id         OUT NOCOPY     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'create_fee_assignment';
    l_fee_assignment_rec  FEE_ASSIGNMENT_REC_TYPE;

    l_fee_dtls_tbl        LNS_FEE_ENGINE.FEE_CALC_TBL ;
    l_loan_id              NUMBER ;

BEGIN

    l_fee_assignment_rec  := p_fee_assignment_rec;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Create_fee_assignment procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_fee_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_fee_assignment procedure: Before call to do_create_fee_assignment proc');
    END IF;

    Set_Defaults(l_fee_assignment_rec);

    -- call to business logic.
    do_create_fee_assignment(
                   l_fee_assignment_rec,
                   x_fee_assignment_id,
                   x_return_status
                  );
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_fee_assignment procedure: After call to do_create_fee_assignment proc');
     END IF;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'THe feeType is '||l_fee_assignment_rec.FEE_TYPE||' and loan_id is '||l_fee_assignment_rec.LOAN_ID);
     END IF;
    -- Bug # 4728114 - Insert Fee Record in lns_fee_schedules for Origination Fees
     IF( ('EVENT_ORIGINATION'=l_fee_assignment_rec.FEE_TYPE) OR ('EVENT_CONVERSION'=l_fee_assignment_rec.FEE_TYPE) ) THEN

        l_loan_id := l_fee_assignment_rec.LOAN_ID ;

        l_fee_dtls_tbl(1).FEE_ID := l_fee_assignment_rec.FEE_ID ;

	-- Bug#6830765, For Variable type, calculate the fee on the percentVal.
	IF (l_fee_assignment_rec.RATE_TYPE = 'VARIABLE') THEN
		l_fee_dtls_tbl(1).FEE_AMOUNT := lns_fee_engine.calculateFee(l_fee_assignment_rec.FEE_ID
													, l_fee_assignment_rec.LOAN_ID
													,l_fee_assignment_rec.PHASE);
	ELSE
		l_fee_dtls_tbl(1).FEE_AMOUNT :=  l_fee_assignment_rec.FEE;
	END IF;

        l_fee_dtls_tbl(1).FEE_INSTALLMENT := l_fee_assignment_rec.BEGIN_INSTALLMENT_NUMBER ;
        l_fee_dtls_tbl(1).BILLED_FLAG := 'N' ;
        l_fee_dtls_tbl(1).ACTIVE_FLAG := 'Y' ;
	l_fee_dtls_tbl(1).PHASE	      	:= l_fee_assignment_rec.PHASE;

	lns_fee_engine.writefeeschedule('T','T',l_loan_id,l_fee_dtls_tbl,x_return_status,x_msg_count,x_msg_data);


     END IF ;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_fee_assignment procedure: After call to do_create_fee_assignment proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_fee_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Create_fee_assignment procedure');
    END IF;

END create_fee_assignment;

/*===========================================================================+
 | PROCEDURE
 |              update_fee_assignment
 |
 | DESCRIPTION
 |              Updates assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_fee_assignment_rec
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
 |   22-APR-2004     Bernice Lam		Created
 +===========================================================================*/

PROCEDURE update_fee_assignment (
    p_init_msg_list         IN      VARCHAR2,
    p_fee_assignment_rec        IN      FEE_ASSIGNMENT_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_fee_assignment';
    l_fee_assignment_rec     FEE_ASSIGNMENT_REC_TYPE;
    l_old_fee_assignment_rec FEE_ASSIGNMENT_REC_TYPE;

BEGIN

    l_fee_assignment_rec     := p_fee_assignment_rec;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Update_fee_assignment procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT update_fee_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
    -- Get old record. Will be used by history package.
    get_fee_assignment_rec (
        p_fee_assignment_id         => l_fee_assignment_rec.fee_assignment_id,
        x_fee_assignment_rec => l_old_fee_assignment_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );
*/
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_fee_assignment procedure: Before call to do_update_fee_assignment proc');
    END IF;

    Set_Defaults(l_fee_assignment_rec);

    -- call to business logic.
    do_update_fee_assignment(
                   l_fee_assignment_rec,
                   p_object_version_number,
                   x_return_status
                  );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_fee_assignment procedure: After call to do_update_fee_assignment proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_fee_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Update_fee_assignment procedure');
    END IF;

END update_fee_assignment;

/*===========================================================================+
 | PROCEDURE
 |              delete_fee_assignment
 |
 | DESCRIPTION
 |              Deletes assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_fee_assignment_id
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
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE delete_fee_assignment (
    p_init_msg_list   IN      VARCHAR2,
    p_fee_assignment_id         IN     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'delete_fee_assignment';
    l_fee_assignment_id   NUMBER;

BEGIN

    l_fee_assignment_id   := p_fee_assignment_id;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Delete_fee_assignment procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT delete_fee_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_fee_assignment procedure: Before call to do_delete_fee_assignment proc');
    END IF;

    -- call to business logic.
    do_delete_fee_assignment(
                   l_fee_assignment_id,
                   x_return_status
                  );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_fee_assignment procedure: After call to do_delete_fee_assignment proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_fee_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_fee_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Delete_fee_assignment procedure');
    END IF;

END delete_fee_assignment;

FUNCTION IS_EXIST_FEE_ASSIGNMENT (
    p_fee_id			 NUMBER
) RETURN VARCHAR2 IS

  CURSOR C_Is_Exist_Assignment (X_Fee_Id NUMBER) IS
  SELECT 'X' FROM DUAL
  WHERE EXISTS ( SELECT NULL FROM LNS_FEE_ASSIGNMENTS
                  WHERE FEE_ID = X_FEE_ID )
  OR EXISTS ( SELECT NULL FROM LNS_LOAN_PRODUCT_LINES
              WHERE LINE_REFERENCE_ID = X_FEE_ID
              AND ( LOAN_PRODUCT_LINE_TYPE = 'FEE' OR LOAN_PRODUCT_LINE_TYPE='DISB_FEE' )
              );


  l_dummy VARCHAR2(1);

BEGIN

  OPEN C_Is_Exist_Assignment (p_fee_id);
  FETCH C_Is_Exist_Assignment INTO l_dummy;
  IF C_Is_Exist_Assignment%FOUND THEN
    CLOSE C_Is_Exist_Assignment;
    RETURN 'Y';
  END IF;
  CLOSE C_Is_Exist_Assignment;
  RETURN 'N';

END IS_EXIST_FEE_ASSIGNMENT;



-- Bug#6830765 Handled for billOptions SUBMIT_FOR_APPROVAL  and AD_HOC
PROCEDURE create_LP_FEE_ASSIGNMENT(
            P_LOAN_ID IN NUMBER ) IS

CURSOR loan_prod_fee ( c_loan_id NUMBER ) IS
  select LNS_FEE_ASSIGNMENTS_S.NEXTVAL FEE_ASSIGNMENT_ID,
    LnsLoanHeaders.LOAN_ID,
    LnsFees.FEE_ID,
    --decode(LnsFees.RATE_TYPE,'VARIABLE', lns_fee_engine.calculateFee(LnsFees.FEE_ID,LnsLoanHeaders.LOAN_ID) , LnsFees.FEE) FEE,
    LnsFees.FEE,
    LnsFees.FEE_TYPE,
    LnsFees.FEE_BASIS,
    LnsFees.NUMBER_GRACE_DAYS,
    LnsFees.COLLECTED_THIRD_PARTY_FLAG,
    LnsFees.RATE_TYPE,
    decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
           'SUBMIT_FOR_APPROVAL',0,
	   'AD_HOC',0,
	   'TERM_CONVERSION',0,
           'BILL_WITH_INSTALLMENT',1,
           (decode(LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(LnsLoanHeaders.LOAN_ID) ,
             -1 , 0 , LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(LnsLoanHeaders.LOAN_ID)) + 1 )
      ) BEGIN_INSTALLMENT_NUMBER,
    decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
          'SUBMIT_FOR_APPROVAL',0,
	  'AD_HOC',0,
	  'TERM_CONVERSION',0,
          'BILL_WITH_INSTALLMENT',decode(LnsFees.fee_type, 'EVENT_LATE_CHARGE', lns_fin_utils.getnumberinstallments(LnsLoanHeaders.LOAN_ID), 1 ),
          lns_fin_utils.getnumberinstallments(LnsLoanHeaders.LOAN_ID)) END_INSTALLMENT_NUMBER,

     NULL NUMBER_OF_PAYMENTS,
     LnsFees.BILLING_OPTION,
     NULL CREATED_BY,
     NULL CREATION_DATE,
     NULL LAST_UPDATED_BY,
     NULL LAST_UPDATE_DATE,
     NULL LAST_UPDATE_LOGIN,
     1 OBJECT_VERSION_NUMBER,
     sysdate START_DATE_ACTIVE,
     NULL END_DATE_ACTIVE,
     NULL DISB_HEADER_ID,
     LnsLoanProductLines.MANDATORY_FLAG,
     NULL OPEN_PHASE_FLAG,  -- We don't use this flag anywhere
     NULL PHASE
FROM LNS_FEES LnsFees ,
LNS_LOAN_HEADERS LnsLoanHeaders ,
LNS_LOAN_PRODUCT_LINES LnsLoanProductLines

WHERE LnsLoanHeaders.LOAN_ID = c_loan_id
AND LnsLoanHeaders.PRODUCT_ID = LnsLoanProductLines.LOAN_PRODUCT_ID
AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'FEE'
AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsFees.FEE_ID ;

CURSOR fee_account_lines ( c_fee_id NUMBER ) IS
    SELECT  LINE_TYPE, ACCOUNT_NAME, CODE_COMBINATION_ID, ACCOUNT_TYPE, DISTRIBUTION_PERCENT, DISTRIBUTION_TYPE
    FROM LNS_DEFAULT_DISTRIBS
    WHERE ACCOUNT_NAME = 'FEE_RECEIVABLE' OR FEE_ID = c_fee_id ;


CURSOR current_loan_status ( c_loan_id NUMBER ) IS
  SELECT LOAN_STATUS , CURRENT_PHASE
  FROM LNS_LOAN_HEADERS LnsLoanHeaders
  WHERE LnsLoanHeaders.LOAN_ID = c_loan_id ;


CURSOR loan_fee_exists ( c_loan_id NUMBER ) IS
  SELECT 'Y'
  FROM DUAL
  WHERE
  EXISTS
  (SELECT NULL FROM LNS_FEE_ASSIGNMENTS LnsFeeAssignments
  WHERE LnsFeeAssignments.LOAN_ID = c_loan_id)
  OR EXISTS
  (SELECT NULL FROM LNS_LOAN_HISTORIES_H
   WHERE TABLE_NAME = 'LNS_FEE_ASSIGNMENTS' AND LOAN_ID = c_loan_id) ;



l_fee_assignment_rec fee_assignment_rec_type ;
l_fee_assignment_id NUMBER ;
x_return_status VARCHAR2(1) ;
l_loan_status   LNS_LOAN_HEADERS.LOAN_STATUS%TYPE ;
l_loan_Current_phase   LNS_LOAN_HEADERS.CURRENT_PHASE%TYPE ;
l_loan_fee_exists VARCHAR2(1) ;

l_line_type             LNS_DEFAULT_DISTRIBS.LINE_TYPE%TYPE ;
l_account_name          LNS_DEFAULT_DISTRIBS.ACCOUNT_NAME%TYPE ;
l_code_combination_id   LNS_DEFAULT_DISTRIBS.CODE_COMBINATION_ID%TYPE ;
l_account_type          LNS_DEFAULT_DISTRIBS.ACCOUNT_TYPE%TYPE ;
l_distribution_percent  LNS_DEFAULT_DISTRIBS.DISTRIBUTION_PERCENT%TYPE ;
l_distribution_type     LNS_DEFAULT_DISTRIBS.DISTRIBUTION_TYPE%TYPE ;

is_commit_needed BOOLEAN;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(32767);


BEGIN

    --Initialize this variable to false. Change to true when a record is
    --inserted into the table in this procedure
    is_commit_needed := FALSE;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin create_LP_FEE_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_LP_FEE_ASSIGNMENT ;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before opening cursor current_loan_status ');
    END IF;

    OPEN current_loan_status(P_LOAN_ID) ;

    FETCH current_loan_status INTO l_loan_status ,l_loan_Current_phase ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After opening cursor current_loan_status , loan status is '||l_loan_status ||' loan current phase is '||l_loan_Current_phase);
    END IF;

    /* If the loan current phase is not open or loan status is not Incomplete for Term loan , no fees assignment required  */
    IF( NOT ( ( l_loan_status='INCOMPLETE' AND l_loan_current_phase = 'TERM' ) OR ( l_loan_current_phase = 'OPEN' ) ) ) THEN
	        RETURN  ;
    END IF ;




    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before opening cursor loan_fee_exists ');
    END IF;

    OPEN loan_fee_exists(P_LOAN_ID) ;

    FETCH loan_fee_exists INTO l_loan_fee_exists ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After opening cursor loan_fee_exists , loan fee exist status is ' || l_loan_fee_exists );
    END IF;

    /* If the loan fee count is not zero and there are already fees assigned to loan, no fees assignment required  */
    IF( l_loan_fee_exists = 'Y' ) THEN
	        RETURN  ;
    END IF ;



    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before opening cursor loan_prod_fee ');
    END IF;

    OPEN loan_prod_fee(P_LOAN_ID) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After opening cursor loan_prod_fee , no of fees found is '||loan_prod_fee%ROWCOUNT);
    END IF;


LOOP

FETCH loan_prod_fee INTO l_fee_assignment_rec ;
EXIT WHEN loan_prod_fee%NOTFOUND ;

l_fee_assignment_id := l_fee_assignment_rec.fee_assignment_id ;


IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before call to do_create_FEE_ASSIGNMENT proc for fee '||l_fee_assignment_rec.FEE_ID );
    END IF;

    IF (l_loan_current_phase = 'OPEN'
          AND  (  (l_fee_assignment_rec.FEE_TYPE = 'EVENT_ORIGINATION')
		      OR ( l_fee_assignment_rec.FEE_TYPE = 'EVENT_FUNDING')
	  	   )
	) THEN

	l_fee_assignment_rec.phase := 'OPEN';
     ELSE
	l_fee_assignment_rec.phase := 'TERM';
     END IF;

    -- call to business logic.
    --do_create_FEE_ASSIGNMENT( l_fee_assignment_rec ,
    --                          l_fee_assignment_id ,
    --                          x_return_status ) ;
    -- Bug # 4728114 change to call from do_create_FEE_ASSIGNMENT to create_fee_assignment
    create_fee_assignment('T',l_fee_assignment_rec,l_fee_assignment_id,x_return_status,l_msg_count,l_msg_data);


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After call to do_create_FEE_ASSIGNMENT proc for fee'|| l_fee_assignment_rec.FEE_ID ||' , return status is' || x_return_status);
    END IF;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before opening cursor fee_account_lines ');
    END IF;

    OPEN fee_account_lines(l_fee_assignment_rec.fee_id) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After opening cursor fee_account_lines , no of accounting lines found is '||fee_account_lines%ROWCOUNT);
    END IF;


    LOOP

    FETCH fee_account_lines INTO l_line_type , l_account_name, l_code_combination_id, l_account_type , l_distribution_percent , l_distribution_type ;

    EXIT WHEN fee_account_lines%NOTFOUND ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: Before inserting to lns_distributions record for accountint name '||l_account_name || ' and code comb id ' ||  l_code_combination_id);
    END IF;

    Insert into lns_distributions
                (DISTRIBUTION_ID
                ,LOAN_ID
                ,LINE_TYPE
                ,ACCOUNT_NAME
                ,CODE_COMBINATION_ID
                ,ACCOUNT_TYPE
                ,DISTRIBUTION_PERCENT
                ,DISTRIBUTION_TYPE
                ,FEE_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,OBJECT_VERSION_NUMBER )
                values
                (LNS_DISTRIBUTIONS_S.nextval
                ,p_loan_id
                ,l_line_type
                ,l_account_name
                ,l_code_combination_id
                ,l_account_type
                ,l_distribution_percent
                ,l_distribution_type
                ,l_fee_assignment_rec.fee_id
                ,lns_utility_pub.creation_date
                ,lns_utility_pub.created_by
                ,lns_utility_pub.last_update_date
                ,lns_utility_pub.last_updated_by
                ,1) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_FEE_ASSIGNMENT procedure: After inserting to lns_distributions record for accountint name '||l_account_name || ' and code comb id ' ||  l_code_combination_id);
    END IF;

    END LOOP ;

    CLOSE fee_account_lines ;

    is_commit_needed := true;

END LOOP ;

--If records have been inserted into lns_fee_assignments table
--they need to be committed since the commit does not happen on the UI
--unless the user explicitly commits from the UI page
IF (is_commit_needed = TRUE) THEN
    COMMIT WORK;
END IF;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO create_LP_FEE_ASSIGNMENT ;

END create_LP_FEE_ASSIGNMENT ;


PROCEDURE create_LP_DISB_FEE_ASSIGNMENT(
             P_DISB_HEADER_ID IN NUMBER , P_LOAN_PRODUCT_LINE_ID IN NUMBER, P_LOAN_ID IN NUMBER  ) IS

CURSOR loan_prod_disb_fee ( c_disb_header_id NUMBER , c_loan_prod_line_id NUMBER ) IS
  select LNS_FEE_ASSIGNMENTS_S.NEXTVAL FEE_ASSIGNMENT_ID,
    NULL LOAN_ID,
    LnsFees.FEE_ID,
    LnsFees.FEE,
    LnsFees.FEE_TYPE,
    LnsFees.FEE_BASIS,
    LnsFees.NUMBER_GRACE_DAYS,
    LnsFees.COLLECTED_THIRD_PARTY_FLAG,
    LnsFees.RATE_TYPE,
    decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
    	   'SUBMIT_FOR_APPROVAL',0,
           'BILL_WITH_INSTALLMENT',1,
           (decode(LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT((select loan_id from lns_disb_headers where disb_header_id = c_disb_header_id )) ,
             -1 , 0 , LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT((select loan_id from lns_disb_headers where disb_header_id = c_disb_header_id ))) + 1 )
      ) BEGIN_INSTALLMENT_NUMBER,
    decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
   	  'SUBMIT_FOR_APPROVAL',0,
           'BILL_WITH_INSTALLMENT',1,
          lns_fin_utils.getnumberinstallments((select loan_id from lns_disb_headers where disb_header_id = c_disb_header_id )) ) END_INSTALLMENT_NUMBER,

     NULL NUMBER_OF_PAYMENTS,
     LnsFees.BILLING_OPTION,
     NULL CREATED_BY,
     NULL CREATION_DATE,
     NULL LAST_UPDATED_BY,
     NULL LAST_UPDATE_DATE,
     NULL LAST_UPDATE_LOGIN,
     1 OBJECT_VERSION_NUMBER,
     sysdate START_DATE_ACTIVE,
     NULL END_DATE_ACTIVE,
     c_disb_header_id DISB_HEADER_ID,
     LnsLoanProductLines.MANDATORY_FLAG,
     NULL OPEN_PHASE_FLAG,
     NULL  PHASE
FROM LNS_FEES LnsFees ,
LNS_LOAN_PRODUCT_LINES LnsLoanProductLines

WHERE LnsLoanProductLines.PARENT_PRODUCT_LINES_ID = c_loan_prod_line_id
AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'DISB_FEE'
AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsFees.FEE_ID ;

CURSOR fee_account_lines ( c_fee_id NUMBER ) IS
    SELECT  LINE_TYPE, ACCOUNT_NAME, CODE_COMBINATION_ID, ACCOUNT_TYPE, DISTRIBUTION_PERCENT, DISTRIBUTION_TYPE
    FROM LNS_DEFAULT_DISTRIBS
    WHERE ACCOUNT_NAME = 'FEE_RECEIVABLE' OR FEE_ID = c_fee_id ;


CURSOR current_loan_status ( c_loan_id NUMBER ) IS
  SELECT LOAN_STATUS , CURRENT_PHASE
  FROM LNS_LOAN_HEADERS LnsLoanHeaders
  WHERE LnsLoanHeaders.LOAN_ID = c_loan_id ;


CURSOR l_fee_acct_line_exists ( c_loan_id NUMBER ) IS
SELECT 'Y'
  FROM DUAL
  WHERE
  EXISTS
  (SELECT * FROM LNS_DISTRIBUTIONS lnsDistribs
  WHERE lnsDistribs.ACCOUNT_NAME = 'FEE_RECEIVABLE' AND lnsDistribs.LOAN_ID = c_loan_id);


l_fee_assignment_rec fee_assignment_rec_type ;
l_fee_assignment_id NUMBER ;
x_return_status VARCHAR2(1) ;
l_loan_status   LNS_LOAN_HEADERS.LOAN_STATUS%TYPE ;
l_loan_current_phase   LNS_LOAN_HEADERS.CURRENT_PHASE%TYPE ;
l_loan_fee_acct_line_exists VARCHAR2(1);

l_line_type             LNS_DEFAULT_DISTRIBS.LINE_TYPE%TYPE ;
l_account_name          LNS_DEFAULT_DISTRIBS.ACCOUNT_NAME%TYPE ;
l_code_combination_id   LNS_DEFAULT_DISTRIBS.CODE_COMBINATION_ID%TYPE ;
l_account_type          LNS_DEFAULT_DISTRIBS.ACCOUNT_TYPE%TYPE ;
l_distribution_percent  LNS_DEFAULT_DISTRIBS.DISTRIBUTION_PERCENT%TYPE ;
l_distribution_type     LNS_DEFAULT_DISTRIBS.DISTRIBUTION_TYPE%TYPE ;

is_commit_needed BOOLEAN;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(32767);

BEGIN


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin create_LP_DISB_FEE_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_LP_DISB_FEE_ASSIGNMENT ;

    l_loan_fee_acct_line_exists := 'N';

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before opening cursor current_loan_status ');
    END IF;

    OPEN current_loan_status(P_LOAN_ID) ;

    FETCH current_loan_status INTO l_loan_status ,l_loan_Current_phase ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After opening cursor current_loan_status , loan status is '||l_loan_status ||' loan current phase is '||l_loan_Current_phase);
    END IF;

    /* If the loan current phase is not open or loan status is not Incomplete for Term loan , no disb fees assignment required  */
    IF( NOT ( ( l_loan_status='INCOMPLETE' AND l_loan_current_phase = 'TERM' ) OR ( l_loan_current_phase = 'OPEN' ) ) ) THEN
	        RETURN  ;
    END IF ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before opening cursor l_fee_acct_line_exists ');
    END IF;

    OPEN l_fee_acct_line_exists(P_LOAN_ID) ;

    FETCH l_fee_acct_line_exists INTO l_loan_fee_acct_line_exists ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After opening cursor loan_fee_exists , loan fee exist status is ' || l_loan_fee_acct_line_exists );
    END IF;



    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before opening cursor loan_prod_disb_fee ');
    END IF;

    OPEN loan_prod_disb_fee(P_DISB_HEADER_ID , P_LOAN_PRODUCT_LINE_ID) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After opening cursor loan_prod_disb_fee , no of fees found for disb_header '||p_disb_header_id||' are '||loan_prod_disb_fee%ROWCOUNT);
    END IF;


    LOOP

	    FETCH loan_prod_disb_fee INTO l_fee_assignment_rec ;
	    EXIT WHEN loan_prod_disb_fee%NOTFOUND ;

	    l_fee_assignment_id := l_fee_assignment_rec.fee_assignment_id ;

	    IF (l_loan_current_phase = 'OPEN'
		  AND  (  (l_fee_assignment_rec.FEE_TYPE = 'EVENT_ORIGINATION')
			       OR ( l_fee_assignment_rec.FEE_TYPE = 'EVENT_FUNDING')
			    )
		) 	THEN

		l_fee_assignment_rec.phase := 'OPEN';

	ELSE
		l_fee_assignment_rec.phase := 'TERM';
	END IF;


	    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before call to do_create_FEE_ASSIGNMENT proc for fee '||l_fee_assignment_rec.FEE_ID );
	    END IF;

	    -- call to business logic.
	    do_create_FEE_ASSIGNMENT( l_fee_assignment_rec ,
				      l_fee_assignment_id ,
				      x_return_status ) ;

	    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After call to do_create_FEE_ASSIGNMENT proc for fee'|| l_fee_assignment_rec.FEE_ID ||' , return status is' || x_return_status);
	    END IF;


	    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before opening cursor fee_account_lines ');
	    END IF;

	    OPEN fee_account_lines(l_fee_assignment_rec.fee_id) ;

	    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After opening cursor fee_account_lines , no of accounting lines found is '||fee_account_lines%ROWCOUNT);
	    END IF;


	    LOOP
		    FETCH fee_account_lines INTO l_line_type , l_account_name, l_code_combination_id, l_account_type , l_distribution_percent , l_distribution_type ;

		    EXIT WHEN fee_account_lines%NOTFOUND ;

		    /* Only one set of fee account lines of type 'FEE_RECEIVBALE' should be there */
		    IF( l_loan_fee_acct_line_exists <> 'Y' OR l_account_name <> 'FEE_RECEIVABLE') THEN

			    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: Before inserting to lns_distributions record for accountint name '||l_account_name || ' and code comb id ' ||  l_code_combination_id);
			    END IF;

			    Insert into lns_distributions
					(DISTRIBUTION_ID
					,LOAN_ID
					,LINE_TYPE
					,ACCOUNT_NAME
					,CODE_COMBINATION_ID
					,ACCOUNT_TYPE
					,DISTRIBUTION_PERCENT
					,DISTRIBUTION_TYPE
					,FEE_ID
					,CREATION_DATE
					,CREATED_BY
					,LAST_UPDATE_DATE
					,LAST_UPDATED_BY
					,OBJECT_VERSION_NUMBER
					,DISB_HEADER_ID )
					values
					(LNS_DISTRIBUTIONS_S.nextval
					,p_loan_id
					,l_line_type
					,l_account_name
					,l_code_combination_id
					,l_account_type
					,l_distribution_percent
					,l_distribution_type
					,l_fee_assignment_rec.fee_id
					,lns_utility_pub.creation_date
					,lns_utility_pub.created_by
					,lns_utility_pub.last_update_date
					,lns_utility_pub.last_updated_by
					,1
					,p_disb_header_id) ;

			    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_DISB_FEE_ASSIGNMENT procedure: After inserting to lns_distributions record for accounting name '||l_account_name || ' and code comb id ' ||  l_code_combination_id);
			    END IF;


                      END IF;


	    END LOOP ;
            IF (l_account_name = 'FEE_RECEIVABLE') THEN
                l_loan_fee_acct_line_exists := 'Y';
            END IF;

            CLOSE fee_account_lines ;

    END LOOP ;


--If records have been inserted into lns_fee_assignments table
--they need to be committed since the commit does not happen on the UI
--unless the user explicitly commits from the UI page
--IF (is_commit_needed = TRUE) THEN
    --COMMIT WORK;
--END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End create_LP_DISB_FEE_ASSIGNMENT procedure - ');
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO create_LP_DISB_FEE_ASSIGNMENT ;

END create_LP_DISB_FEE_ASSIGNMENT ;



PROCEDURE delete_DISB_FEE_ASSIGNMENT(P_DISB_HEADER_ID IN NUMBER ) IS

CURSOR loan_disb_fee ( c_disb_header_id NUMBER ) IS
  select FEE_ASSIGNMENT_ID
  FROM LNS_FEE_ASSIGNMENTS LnsFeeAssignments
  WHERE LnsFeeAssignments.DISB_HEADER_ID = c_disb_header_id ;

l_fee_assignment_id NUMBER ;
x_return_status VARCHAR2(1) ;

BEGIN


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin delete_DISB_FEE_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT delete_DISB_FEE_ASSIGNMENT ;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_FEE_ASSIGNMENT procedure: Before opening cursor loan_disb_fee ');
    END IF;

    OPEN loan_disb_fee(P_DISB_HEADER_ID) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_FEE_ASSIGNMENT procedure: After opening cursor loan_disb_fee , no of fees found is '||loan_disb_fee%ROWCOUNT);
    END IF;


LOOP

FETCH loan_disb_fee INTO l_fee_assignment_id ;
EXIT WHEN loan_disb_fee%NOTFOUND ;



IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_FEE_ASSIGNMENT procedure: Before call to do_delete_fee_assignment proc for fee_assignment_id '||l_fee_assignment_id );
    END IF;

    -- call to business logic.
    do_delete_fee_assignment( l_fee_assignment_id ,
                              x_return_status );


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_FEE_ASSIGNMENT procedure: After call to do_delete_fee_assignment proc for fee_assignment_id'|| l_fee_assignment_id ||' , return status is' || x_return_status);
    END IF;



END LOOP ;



EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO delete_DISB_FEE_ASSIGNMENT ;

END delete_DISB_FEE_ASSIGNMENT ;

/*===========================================================================+
 | FUNCTION
 |              IS_LOAN_FASGM_EDITABLE
 |
 | DESCRIPTION
 |              .
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              IN:  p_loan_id
 |                    p_fee_id
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   26-OCT-2009     MBOLLI       Bug#8904109 - Created.
 +===========================================================================*/
FUNCTION IS_LOAN_FASGM_EDITABLE(p_loan_id           in number
				,p_fee_id              in NUMBER
				,p_disb_header_id in NUMBER
	    )  return VARCHAR2 IS

	l_updatableFlag  VARCHAR2(1);
	l_fees_category  lns_fees_all.fee_category%TYPE;
	l_fee_type          lns_fees_all.fee_type%TYPE;
	l_status              lns_loan_headers_all.loan_status%TYPE;
	l_disb_status	 lns_disb_headers.status%TYPE;

	CURSOR c_fasgm_edit (c_loan_id NUMBER, c_fee_id NUMBER, c_disb_header_id NUMBER) IS
  	SELECT 'X' FROM DUAL
  	WHERE EXISTS ( SELECT NULL FROM LNS_FEE_ASSIGNMENTS fasgn
			WHERE (fasgn.LOAN_ID = c_loan_id
				OR (fasgn.DISB_HEADER_ID = c_disb_header_id ))
			AND fasgn.FEE_ID = c_fee_id
			AND nvl(trunc(fasgn.END_DATE_ACTIVE), trunc(SYSDATE)) >= trunc(SYSDATE)
			AND nvl(trunc(fasgn.START_DATE_ACTIVE), trunc(SYSDATE)) <= trunc(SYSDATE)
		     )
	      AND
	        EXISTS ( SELECT NULL FROM LNS_FEE_SCHEDULES sched
			WHERE (sched.loan_id = c_loan_id OR sched.DISB_HEADER_ID = c_disb_header_id)
			AND sched.fee_id = c_fee_id
			AND sched.ACTIVE_FLAG = 'Y'
			AND sched.BILLED_FLAG = 'N'
			AND (NOT EXISTS
			  (select 'X'
			     from lns_amortization_scheds am
				 ,lns_amortization_lines lines
			    where lines.loan_id = c_loan_id
			      and lines.fee_schedule_id = sched.fee_schedule_id
			      and am.loan_id = lines.loan_id
			      and NVL(am.reversed_flag, 'N') = 'N'
			      --and am.payment_number = p_installment
			      )
			    or EXISTS
			    (select 'X'
			     from lns_amortization_scheds am
				 ,lns_amortization_lines lines
			    where lines.loan_id = c_loan_id
			      and lines.fee_schedule_id = sched.fee_schedule_id
			      and am.loan_id = lines.loan_id
			      and am.reversed_flag = 'Y'
			      --and am.payment_number = p_installment
			    )
			)
                      );

   CURSOR c_fee_details (c_fee_id NUMBER) IS
     	SELECT
		fees.fee_category, fees.fee_type
	FROM
		lns_fees_all fees
	WHERE
		fees.fee_id = c_fee_id;

   CURSOR c_loan_details (c_disb_header_id NUMBER) IS
     	SELECT
		hdr.loan_status
	FROM
		lns_loan_headers_all hdr
	WHERE
		hdr.loan_id in (select loan_id from lns_disb_headers where disb_header_id = c_disb_header_id);

   CURSOR c_disb_details (c_disb_header_id NUMBER) IS
	SELECT
		disb.status
	FROM
		lns_disb_headers disb
	WHERE
		disb.disb_header_id = c_disb_header_id;

 BEGIN
	   l_updatableFlag := 'N';


	OPEN c_fee_details (p_fee_id);

	FETCH c_fee_details INTO l_fees_category, l_fee_type;
	IF c_fee_details%NOTFOUND THEN
		CLOSE c_fee_details;
		return 'N';
	END IF;
	CLOSE c_fee_details;


	IF ( l_fees_category IS NOT NULL ) THEN
		IF  NOT(l_fees_category = 'MEMO'  OR  (l_fees_category = 'EVENT' AND l_fee_type in ('EVENT_ORIGINATION', 'EVENT_CONVERSION', 'EVENT_FUNDING'))
		    ) THEN
			return 'Y';
		END IF;
	END IF;

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' Before invoke cur c_fasgm_edit ');
	END IF;

       OPEN c_fasgm_edit (p_loan_id, p_fee_id, p_disb_header_id);
	FETCH c_fasgm_edit INTO l_updatableFlag;
	IF c_fasgm_edit%FOUND THEN
		CLOSE c_fasgm_edit;
		return 'Y';
	END IF;
	CLOSE c_fasgm_edit;

	-- All the disbursement fees can be edited before the loan becomes Active
	IF (p_disb_header_id IS NOT NULL)   THEN

		OPEN c_loan_details (p_disb_header_id);

		FETCH c_loan_details INTO l_status;


		OPEN c_disb_details (p_disb_header_id);

		FETCH c_disb_details INTO l_disb_status;



		IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'LoanStatus is '||l_status);
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Disbursement Header Status is ' ||l_disb_status);
		END IF;
		CLOSE c_loan_details;
		CLOSE c_disb_details;

		IF (l_disb_status is null) THEN  --OR l_status NOT IN ('ACTIVE', 'DEFAULT', 'DELINQUENT')) THEN
			IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Either Disb Header Status is null or Disb Fee is NOT billed, so edit = Y');
			END IF;
			return 'Y';
		END IF;
	END IF;


	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End IS_LOAN_FASGM_EDITABLE is N');
	END IF;

	return 'N';


       EXCEPTION
		WHEN OTHERS THEN
			IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Exception in IS_LOAN_FASGM_EDITABLE is '||sqlerrm);
			END IF;



END IS_LOAN_FASGM_EDITABLE;

END LNS_FEE_ASSIGNMENT_PUB;

/
