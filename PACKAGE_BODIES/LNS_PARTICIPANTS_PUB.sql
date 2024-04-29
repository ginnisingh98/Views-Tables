--------------------------------------------------------
--  DDL for Package Body LNS_PARTICIPANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_PARTICIPANTS_PUB" AS
/* $Header: LNS_PART_PUBP_B.pls 120.19.12010000.1 2008/07/29 09:12:19 appldev ship $ */
 G_DEBUG_COUNT               CONSTANT NUMBER := 0;
 G_DEBUG                     CONSTANT BOOLEAN := FALSE;
 G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'LNS_PARTICIPANTS_PUB';

--------------------------------------------------
 -- Procedure for logging debug messages
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

--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------

Procedure createCreditRequest(p_loan_participant_rec IN OUT NOCOPY loan_participant_rec_type,
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count            OUT NOCOPY NUMBER,
                       x_msg_data             OUT NOCOPY VARCHAR2);

Procedure denormalizePrimaryInfo(p_loan_participant_rec IN loan_participant_rec_type,
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count            OUT NOCOPY NUMBER,
                       x_msg_data             OUT NOCOPY VARCHAR2);

PROCEDURE do_create_participant (
    p_loan_participant_rec     IN OUT NOCOPY loan_participant_rec_type,
    x_participant_id              OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE getDefaultPrimaryContact(p_loan_participant_rec IN OUT NOCOPY loan_participant_rec_type,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2
			    );

--------------------------------------------------
 -- end declaration of private procedures and functions
--------------------------------------------------

procedure validateParticipant(p_loan_participant_rec IN loan_participant_rec_type,
															p_mode IN VARCHAR2,
                              x_return_status        OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2)
is

    l_participant_id        NUMBER;
    l_LOAN_ID               NUMBER;
    l_hz_party_id           NUMBER;
    l_loan_participant_type VARCHAR2(30);
    l_cust_account_id       NUMBER;
    l_start_date            DATE;
    l_end_date              DATE;

    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);

		l_primary            varchar2(30);
    l_api_name    CONSTANT       varchar2(25) := 'validateParticipant';
		l_valid_acct_site_party VARCHAR2(1);

    -- validation for bill_to_site_use
    CURSOR c_site_uses(p_primary_borrower_id NUMBER, p_cust_account_id NUMBER, p_bill_to_acct_site_id number) IS
        select 'Y' valid_acct_site_party
        from
            hz_parties party,
            hz_party_sites site,
						hz_cust_accounts acct,
            hz_cust_acct_sites acct_site,
            hz_cust_site_uses acc_site_use
				where party.party_id = p_primary_borrower_id
				and acct.party_id = party.party_id
				and acct.cust_account_id = p_cust_account_id
        and acct_site.cust_account_id = acct.cust_account_id
        and acct_site.cust_acct_site_id = p_bill_to_acct_site_id
        and acc_site_use.cust_acct_site_id = acct_site.cust_acct_site_id
        and acct_site.party_site_id = site.party_site_id
        and acc_site_use.site_use_code = 'BILL_TO'
        and acc_site_use.status = 'A'
        and site.status = 'A'
				and acct.status = 'A'
				and party.status = 'A';
        --and sysdate between nvl(site.start_date_active,sysdate) and nvl(site.end_date_active,sysdate);

    l_last_api_called varchar2(500); --Store the last api that was called before exception

BEGIN

 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_mode: ' || p_mode);


		l_last_api_called				 := 'validateParticipant';
    l_participant_id         := p_loan_participant_rec.participant_id;
    l_LOAN_ID                := p_loan_participant_rec.loan_id;
    l_hz_party_id            := p_loan_participant_rec.hz_party_id;
    l_loan_participant_type  := p_loan_participant_rec.LOAN_PARTICIPANT_TYPE;
    l_cust_account_id        := p_loan_participant_rec.cust_account_id;
    l_start_date               := p_loan_participant_rec.start_date_active;
    l_end_date                 := p_loan_participant_rec.end_date_active;

    --SAVEPOINT validateParticipant;

    --dbms_output.put_line('validate');
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF (p_mode = 'CREATE') THEN

    -- validate loan_id
    IF l_LOAN_ID IS NOT NULL AND
        l_LOAN_ID <> FND_API.G_MISS_NUM
    THEN

				-- check to see if primary_borrower. if so then CUST_ACCOUNT_ID,bill_to_acct_site_id and PARTY_ID MUST
				-- be valid combination with valid BILL_TO purpose
				if (l_loan_participant_type = 'PRIMARY_BORROWER' AND p_mode = 'CREATE') then

					 BEGIN
								OPEN c_site_uses(p_loan_participant_rec.hz_party_id, p_loan_participant_rec.cust_account_id, p_loan_participant_rec.bill_to_acct_site_id);
								FETCH c_site_uses INTO l_valid_acct_site_party;
								CLOSE c_site_uses;

								--dbms_output.put_line('Site use number is ' || l_num_acct_site_uses);
								if l_valid_acct_site_party <> 'Y' then
									 FND_MESSAGE.SET_NAME('LNS', 'LNS_BORROWER_NO_BILL_TO');
									 FND_MSG_PUB.ADD;
									 RAISE FND_API.G_EXC_ERROR;
								end if;
					 exception
						when NO_DATA_FOUND then
							 FND_MESSAGE.SET_NAME('LNS', 'LNS_BORROWER_NO_BILL_TO');
							 FND_MSG_PUB.ADD;
							 RAISE FND_API.G_EXC_ERROR;
					 End;

				end if; --end if (l_loan_participant_type = 'PRIMARY_BORROWER') then

        LNS_UTILITY_PUB.VALIDATE_ANY_ID(P_API_VERSION    =>  1.0,
                                        P_INIT_MSG_LIST  =>  'F',
                                        X_MSG_COUNT      =>  l_msg_count,
                                        X_MSG_DATA       =>  l_msg_data,
                                        X_RETURN_STATUS  =>  l_return_status,
                                        P_COL_ID         =>  l_loan_id,
                                        P_COL_NAME       =>  'LOAN_ID',
                                        P_TABLE_NAME     =>  'LNS_LOAN_HEADERS_ALL');
    --dbms_output.put_line('output');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_loan_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

    END IF;

    -- validate hz_party_id
    IF l_hz_party_id IS NOT NULL AND
        l_hz_party_id <> FND_API.G_MISS_NUM
    THEN

        LNS_UTILITY_PUB.VALIDATE_ANY_ID(P_API_VERSION    =>  1.0,
                                        P_INIT_MSG_LIST  =>  'F',
                                        X_MSG_COUNT      =>  l_msg_count,
                                        X_MSG_DATA       =>  l_msg_data,
                                        X_RETURN_STATUS  =>  l_return_status,
                                        P_COL_ID         =>  l_hz_party_id,
                                        P_COL_NAME       =>  'PARTY_ID',
                                        P_TABLE_NAME     =>  'HZ_PARTIES');
    --dbms_output.put_line('output2');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'HZ_PARTY_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_hz_party_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

    END IF;


    -- validate l_loan_participant_type
    IF l_loan_participant_type IS NOT NULL AND
        l_loan_participant_type <> FND_API.G_MISS_CHAR
    THEN
        LNS_UTILITY_PUB.VALIDATE_LOOKUP_CODE(P_API_VERSION    =>  1.0,
                                             P_INIT_MSG_LIST  =>  'F',
                                             X_MSG_COUNT      =>  l_msg_count,
                                             X_MSG_DATA       =>  l_msg_data,
                                             X_RETURN_STATUS  =>  l_return_status,
                                             P_LOOKUP_TYPE    =>  'LNS_PARTICIPANT_TYPE',
                                             P_LOOKUP_CODE    =>  l_loan_participant_type,
                                             P_LOOKUP_VIEW    =>  'LNS_LOOKUPS');
    --dbms_output.put_line('output3');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'PARTICIPANT_TYPE');
            FND_MESSAGE.SET_TOKEN('VALUE', l_loan_participant_type);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

    END IF;

    IF l_cust_account_id IS NOT NULL AND
        l_cust_account_id <> FND_API.G_MISS_NUM
    THEN

        LNS_UTILITY_PUB.VALIDATE_ANY_ID(P_API_VERSION    =>  1.0,
                                        P_INIT_MSG_LIST  =>  'F',
                                        X_MSG_COUNT      =>  l_msg_count,
                                        X_MSG_DATA       =>  l_msg_data,
                                        X_RETURN_STATUS  =>  l_return_status,
                                        P_COL_ID         =>  l_cust_account_id,
                                        P_COL_NAME       =>  'CUST_ACCOUNT_ID',
                                        P_TABLE_NAME     =>  'HZ_CUST_ACCOUNTS');
    --dbms_output.put_line('output5');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'CUST_ACCOUNT_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_cust_account_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

    END IF;

 END IF; -- end IF (p_mode = 'CREATE') THEN

    if l_start_date is not null then
        if l_end_date is not null then
            if trunc(l_start_date) > trunc(l_end_date) then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_ACTIVE_DATE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            end if;
        end if;
    end if;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'create participant validation passed OK');
    END IF;

 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO validateParticipant;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO validateParticipant;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        --ROLLBACK TO Validate_any_id_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END validateParticipant;

PROCEDURE do_create_participant(p_loan_participant_rec IN OUT NOCOPY loan_participant_rec_type,
                            x_participant_id       OUT NOCOPY NUMBER,
                            x_return_status        IN OUT NOCOPY VARCHAR2)
IS
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
l_api_name     CONSTANT VARCHAR2(30) := 'do_create_participant';
BEGIN
 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    lns_participants_pkg.INSERT_ROW(
				    x_PARTICIPANT_ID 	    => p_loan_participant_rec.PARTICIPANT_ID
                                    ,P_LOAN_ID              => p_loan_participant_rec.LOAN_ID
                                    ,P_HZ_PARTY_ID          => p_loan_participant_rec.HZ_PARTY_ID
                                    ,P_LOAN_PARTICIPANT_TYPE=> p_loan_participant_rec.LOAN_PARTICIPANT_TYPE
                                    ,P_START_DATE_ACTIVE    => p_loan_participant_rec.START_DATE_ACTIVE
                                    ,P_END_DATE_ACTIVE      => p_loan_participant_rec.END_DATE_ACTIVE
                                    ,P_CUST_ACCOUNT_ID      => p_loan_participant_rec.CUST_ACCOUNT_ID
                                    ,P_BILL_TO_ACCT_SITE_ID => p_loan_participant_rec.BILL_TO_ACCT_SITE_ID
                                    ,P_OBJECT_VERSION_NUMBER => p_loan_participant_rec.OBJECT_VERSION_NUMBER
                                    ,P_ATTRIBUTE_CATEGORY   => p_loan_participant_rec.ATTRIBUTE_CATEGORY
                                    ,P_ATTRIBUTE1           => p_loan_participant_rec.ATTRIBUTE1
                                    ,P_ATTRIBUTE2           => p_loan_participant_rec.ATTRIBUTE2
                                    ,P_ATTRIBUTE3           => p_loan_participant_rec.ATTRIBUTE3
                                    ,P_ATTRIBUTE4           => p_loan_participant_rec.ATTRIBUTE4
                                    ,P_ATTRIBUTE5           => p_loan_participant_rec.ATTRIBUTE5
                                    ,P_ATTRIBUTE6           => p_loan_participant_rec.ATTRIBUTE6
                                    ,P_ATTRIBUTE7           => p_loan_participant_rec.ATTRIBUTE7
                                    ,P_ATTRIBUTE8           => p_loan_participant_rec.ATTRIBUTE8
                                    ,P_ATTRIBUTE9           => p_loan_participant_rec.ATTRIBUTE9
                                    ,P_ATTRIBUTE10          => p_loan_participant_rec.ATTRIBUTE10
                                    ,P_ATTRIBUTE11          => p_loan_participant_rec.ATTRIBUTE11
                                    ,P_ATTRIBUTE12          => p_loan_participant_rec.ATTRIBUTE12
                                    ,P_ATTRIBUTE13          => p_loan_participant_rec.ATTRIBUTE13
                                    ,P_ATTRIBUTE14          => p_loan_participant_rec.ATTRIBUTE14
                                    ,P_ATTRIBUTE15          => p_loan_participant_rec.ATTRIBUTE15
                                    ,P_ATTRIBUTE16          => p_loan_participant_rec.ATTRIBUTE16
                                    ,P_ATTRIBUTE17          => p_loan_participant_rec.ATTRIBUTE17
                                    ,P_ATTRIBUTE18          => p_loan_participant_rec.ATTRIBUTE18
                                    ,P_ATTRIBUTE19          => p_loan_participant_rec.ATTRIBUTE19
                                    ,P_ATTRIBUTE20          => p_loan_participant_rec.ATTRIBUTE20
																		,P_CONTACT_REL_PARTY_ID => p_loan_participant_rec.CONTACT_REL_PARTY_ID
																		,P_CONTACT_PERS_PARTY_ID => p_loan_participant_rec.CONTACT_PERS_PARTY_ID
																		,P_CREDIT_REQUEST_ID 		=> p_loan_participant_rec.CREDIT_REQUEST_ID
																		,P_CASE_FOLDER_ID 			=> p_loan_participant_rec.CASE_FOLDER_ID
																		,p_REVIEW_TYPE 			    => p_loan_participant_rec.REVIEW_TYPE
																		,p_CREDIT_CLASSIFICATION => p_loan_participant_rec.CREDIT_CLASSIFICATION
                                    );
    --dbms_output.put_line('after tblH');
    x_participant_id := p_loan_participant_rec.PARTICIPANT_ID;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_participant procedure: After call to lns_participants_pkg.Insert_Row');
    END IF;
 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

END do_create_participant;


PROCEDURE createParticipant(p_init_msg_list        IN VARCHAR2,
														p_validation_level		 IN NUMBER,
														p_loan_participant_rec IN loan_participant_rec_type,
                            x_participant_id       OUT NOCOPY NUMBER,
                            x_return_status        OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2)
IS
		l_init_msg_list VARCHAR2(1);
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_loan_participant_rec loan_participant_rec_type;

    l_participant_id        NUMBER;
    l_loan_id               NUMBER;
    l_hz_party_id           NUMBER;
    l_dup_party_count 	    NUMBER;

		l_party_type varchar2(30);
		l_loan_party_type varchar2(30);
		l_loan_credit_review_flag varchar2(1);
		l_borrower_review_type varchar2(30);
		l_guarantor_review_type varchar2(30);
		l_loan_status varchar2(30);
		l_loan_sec_status varchar2(30);

    CURSOR CheckDupParty(p_loan_id number, p_party_id number) IS
    select count(1) from lns_participants
    where loan_id = p_loan_id and
    hz_party_id = p_party_id;

		CURSOR c_get_credit_info(p_loan_id number) IS
		select loan.party_type, loan.credit_review_flag, prod.credit_review_type,
					 prod.guarantor_review_type, loan.loan_status, loan.secondary_status
		from lns_loan_products_all prod, lns_loan_headers_all loan
		where loan.loan_id = p_loan_id
		and prod.loan_product_id = loan.product_id;

		CURSOR c_get_party_type(p_party_id number) IS
		select party_type
		from hz_parties
		where party_id = p_party_id;

    l_last_api_called varchar2(500); --Store the last api that was called before exception
		l_api_name     CONSTANT VARCHAR2(30) := 'createParticipant';


BEGIN

 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
        l_init_msg_list := FND_API.G_FALSE;
    end if;

    l_last_api_called	   := 'LNS_PARTICIPANTS_PUB.createParticipant';
    l_participant_id       := p_loan_participant_rec.participant_id;
    l_loan_id              := p_loan_participant_rec.loan_id;
    l_hz_party_id          := p_loan_participant_rec.hz_party_id;
    l_loan_participant_rec := p_loan_participant_rec;

    SAVEPOINT createParticipant;

    -- initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
   -- Get the default values of ContactPerson PartyId and ContactRel PartyId
   getDefaultPrimaryContact(p_loan_participant_rec => l_loan_participant_rec,
				x_return_status        => l_return_status,
	                        x_msg_count            => l_msg_count,
	                        x_msg_data             => l_msg_data
			   );


		open c_get_credit_info(l_loan_id);
		fetch c_get_credit_info into l_loan_party_type,l_loan_credit_review_flag,l_borrower_review_type,l_guarantor_review_type,l_loan_status,l_loan_sec_status;
		close c_get_credit_info;

		IF (l_loan_participant_rec.LOAN_PARTICIPANT_TYPE = 'GUARANTOR') THEN
			l_loan_participant_rec.REVIEW_TYPE := nvl(l_guarantor_review_type,'LNS');
		ELSE
			l_loan_participant_rec.REVIEW_TYPE := nvl(l_borrower_review_type,'LNS');
		END IF;

		IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

			open c_get_party_type(l_hz_party_id);
			fetch c_get_party_type into l_party_type;
			close c_get_party_type;

			if (l_party_type <> l_loan_party_type OR l_party_type NOT IN ('ORGANIZATION','PERSON')) then
				FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_PARTY_TYPE');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			end if;

			IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In createParticipant: Before call to validateParticipant');
			END IF;
			l_last_api_called := 'LNS_PARTICIPANTS_PUB.validateParticipant';
	    validateParticipant(p_loan_participant_rec => p_loan_participant_rec,
													p_mode 								 => 'CREATE',
	                        x_return_status        => l_return_status,
	                        x_msg_count            => l_msg_count,
	                        x_msg_data             => l_msg_data);
			IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In createParticipant: After call to validateParticipant');
			END IF;

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if;

		END IF; --end IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

    --validate duplicate entry for same party
    l_dup_party_count := 0;
    OPEN CheckDupParty(l_loan_id,l_hz_party_id);
    FETCH CheckDupParty INTO l_dup_party_count;
    IF (l_dup_party_count > 0) THEN
					FND_MESSAGE.SET_NAME('LNS', 'LNS_PARTICIPANT_DUP_PARTY');
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;
    END IF;

		if (l_loan_credit_review_flag = 'Y' and l_loan_status = 'INCOMPLETE' and (l_loan_sec_status is null OR l_loan_sec_status NOT IN ('IN_CREDIT_REVIEW','CREDIT_REVIEW_COMPLETE'))) then
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling createCreditRequest');
			l_last_api_called := 'LNS_PARTICIPANTS_PUB.createCreditRequest';
	    createCreditRequest(p_loan_participant_rec  => l_loan_participant_rec,
	                        x_return_status        => l_return_status,
	                        x_msg_count            => l_msg_count,
	                        x_msg_data             => l_msg_data);
	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling createCreditRequest');

		else
			--default the credit_request_id to -1 for the financial data component
			l_loan_participant_rec.credit_request_id := -1;
		end if; -- end if (l_loan_credit_review_flag = 'Y' and l_loan_status = 'INCOMPLETE' and (l_loan_sec_status is null OR l_loan_sec_status NOT IN ('IN_CREDIT_REVIEW','CREDIT_REVIEW_COMPLETE'))) then

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_create_participant procedure');
    END IF;

    -- call to business logic.
		l_last_api_called := 'LNS_PARTICIPANTS_PUB.do_create_participant';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling do_create_participant');
    do_create_participant(
                   l_loan_participant_rec,
                   x_participant_id,
                   x_return_status
                  );

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After call do_create_participant');

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling denormalizePrimaryInfo');
    denormalizePrimaryInfo(p_loan_participant_rec  => l_loan_participant_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling denormalizePrimaryInfo');

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

Exception
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO createParticipant;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO createParticipant;

WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO createParticipant;

END createParticipant;

PROCEDURE updateParticipant(p_init_msg_list        IN VARCHAR2,
														p_validation_level		 IN NUMBER,
														p_loan_participant_rec IN loan_participant_rec_type,
                            x_object_version_number IN OUT NOCOPY NUMBER,
                            x_return_status        OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2)
is
		l_init_msg_list VARCHAR2(1);
    l_rowid ROWID;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_object_version        NUMBER;
    l_loan_participant_rec loan_participant_rec_type;
    l_last_api_called varchar2(500); --Store the last api that was called before exception
		l_api_name     CONSTANT VARCHAR2(30) := 'updateParticipant';
BEGIN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_init_msg_list := p_init_msg_list;
    if (l_init_msg_list is null) then
        l_init_msg_list := FND_API.G_FALSE;
    end if;

    l_last_api_called := 'LNS_PARTICIPANTS_PUB.updateParticipant';
    l_loan_participant_rec := p_loan_participant_rec;
    savepoint updateParticipant;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin update participant');
    END IF;

    -- initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


   -- Get the default values of ContactPerson PartyId and ContactRel PartyId
   getDefaultPrimaryContact(p_loan_participant_rec => l_loan_participant_rec,
				x_return_status        => l_return_status,
	                        x_msg_count            => l_msg_count,
	                        x_msg_data             => l_msg_data
			   );



    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version,
               l_rowid
        FROM   LNS_PARTICIPANTS
        WHERE  PARTICIPANT_ID = p_loan_participant_rec.participant_id
        FOR UPDATE OF PARTICIPANT_ID NOWAIT;

        IF NOT
            (
             (x_object_version_number IS NULL AND l_object_version IS NULL)
             OR
             (x_object_version_number IS NOT NULL AND
              l_object_version IS NOT NULL AND
              x_object_version_number = l_object_version
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_participants');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(x_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'loan participant');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_loan_participant_rec.participant_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

		if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then

			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Before calling validateParticipant');
			l_last_api_called := 'validateParticipant';
	    validateParticipant(p_loan_participant_rec => p_loan_participant_rec,
													p_mode 								 => 'UPDATE',
	                        x_return_status        => l_return_status,
	                        x_msg_count            => l_msg_count,
	                        x_msg_data             => l_msg_data);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling validateParticipant');

		end if; -- end if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then


		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Before calling LNS_PARTICIPANTS_PKG.Update_Row');
		l_last_api_called := 'LNS_PARTICIPANTS_PKG.Update_Row';
    LNS_PARTICIPANTS_PKG.Update_Row(x_rowid             => l_rowid
                                    ,p_PARTICIPANT_ID   => l_loan_participant_rec.PARTICIPANT_ID
                                    ,p_LOAN_ID          => l_loan_participant_rec.LOAN_ID
                                    ,p_HZ_PARTY_ID      => l_loan_participant_rec.HZ_PARTY_ID
                                    ,p_LOAN_PARTICIPANT_TYPE => l_loan_participant_rec.LOAN_PARTICIPANT_TYPE
                                    ,p_START_DATE_ACTIVE => l_loan_participant_rec.START_DATE_ACTIVE
                                    ,p_END_DATE_ACTIVE   => l_loan_participant_rec.END_DATE_ACTIVE
                                    ,p_CUST_ACCOUNT_ID   => l_loan_participant_rec.CUST_ACCOUNT_ID
                                    ,p_BILL_TO_ACCT_SITE_ID   => l_loan_participant_rec.BILL_TO_ACCT_SITE_ID
                                    ,p_OBJECT_VERSION_NUMBER => x_object_version_number
                                    ,p_ATTRIBUTE_CATEGORY => l_loan_participant_rec.ATTRIBUTE_CATEGORY
                                    ,p_ATTRIBUTE1         => l_loan_participant_rec.ATTRIBUTE1
                                    ,p_ATTRIBUTE2         => l_loan_participant_rec.ATTRIBUTE2
                                    ,p_ATTRIBUTE3         => l_loan_participant_rec.ATTRIBUTE3
                                    ,p_ATTRIBUTE4         => l_loan_participant_rec.ATTRIBUTE4
                                    ,p_ATTRIBUTE5         => l_loan_participant_rec.ATTRIBUTE5
                                    ,p_ATTRIBUTE6         => l_loan_participant_rec.ATTRIBUTE6
                                    ,p_ATTRIBUTE7         => l_loan_participant_rec.ATTRIBUTE7
                                    ,p_ATTRIBUTE8         => l_loan_participant_rec.ATTRIBUTE8
                                    ,p_ATTRIBUTE9         => l_loan_participant_rec.ATTRIBUTE9
                                    ,p_ATTRIBUTE10        => l_loan_participant_rec.ATTRIBUTE10
                                    ,p_ATTRIBUTE11        => l_loan_participant_rec.ATTRIBUTE11
                                    ,p_ATTRIBUTE12        => l_loan_participant_rec.ATTRIBUTE12
                                    ,p_ATTRIBUTE13        => l_loan_participant_rec.ATTRIBUTE13
                                    ,p_ATTRIBUTE14        => l_loan_participant_rec.ATTRIBUTE14
                                    ,p_ATTRIBUTE15        => l_loan_participant_rec.ATTRIBUTE15
                                    ,p_ATTRIBUTE16        => l_loan_participant_rec.ATTRIBUTE16
                                    ,p_ATTRIBUTE17        => l_loan_participant_rec.ATTRIBUTE17
                                    ,p_ATTRIBUTE18        => l_loan_participant_rec.ATTRIBUTE18
                                    ,p_ATTRIBUTE19        => l_loan_participant_rec.ATTRIBUTE19
                                    ,p_ATTRIBUTE20        => l_loan_participant_rec.ATTRIBUTE20
																		,p_CONTACT_REL_PARTY_ID => l_loan_participant_rec.CONTACT_REL_PARTY_ID
																		,p_CONTACT_PERS_PARTY_ID => l_loan_participant_rec.CONTACT_PERS_PARTY_ID
																		,p_CREDIT_REQUEST_ID 		=> l_loan_participant_rec.CREDIT_REQUEST_ID
																		,p_CASE_FOLDER_ID 			=> l_loan_participant_rec.CASE_FOLDER_ID
																		,p_REVIEW_TYPE 			    => l_loan_participant_rec.REVIEW_TYPE
																		,p_CREDIT_CLASSIFICATION => l_loan_participant_rec.CREDIT_CLASSIFICATION
    				    );
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'After calling LNS_PARTICIPANTS_PKG.Update_Row');

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling denormalizePrimaryInfo');
    denormalizePrimaryInfo(p_loan_participant_rec  => l_loan_participant_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling denormalizePrimaryInfo');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

Exception
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO updateParticipant;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO updateParticipant;

WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     ROLLBACK TO updateParticipant;

END updateParticipant;

----------------------------------------------------------------
--This procedure changes resubmit/appeal the credit request that has been created
--for the primary borrower after the case folder has been closed and when loan secondary status is CREDIT_REVIEW_COMPLETE
--and changes the loan secondary status to null
----------------------------------------------------------------
PROCEDURE createAppealCreditRequest(p_loan_id IN NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2)
IS
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(32767);
l_loan_participant_rec loan_participant_rec_type;
l_loan_header_rec    LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
l_loan_id NUMBER;
l_object_version NUMBER;
l_old_credit_request_id NUMBER;
l_new_credit_request_id NUMBER;
l_last_api_called varchar2(500); --Store the last api that was called before exception
l_api_name     CONSTANT VARCHAR2(30) := 'createAppealCreditRequest';

CURSOR c_get_primary_borrower(pLoanId Number) IS
select
participant_id, loan_id, LOAN_PARTICIPANT_TYPE, hz_party_id, credit_request_id,
case_folder_id, object_version_number,review_type,credit_classification
from lns_participants
where loan_id = pLoanId
and LOAN_PARTICIPANT_TYPE = 'PRIMARY_BORROWER'
and end_date_active is null;

CURSOR C_GET_LOAN_OVN(pLoanId Number) IS
SELECT OBJECT_VERSION_NUMBER
FROM
LNS_LOAN_HEADERS_ALL
WHERE LOAN_ID = pLoanId;

BEGIN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

		l_last_api_called := 'LNS_PARTICIPANTS_PUB.createAppealCreditRequest';
    -- Standard Start of API savepoint
    SAVEPOINT createAppealCreditRequest;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
		l_loan_id := p_loan_id;

		open c_get_primary_borrower(l_loan_id);
		fetch c_get_primary_borrower into l_loan_participant_rec.participant_id, l_loan_participant_rec.loan_id,
																			l_loan_participant_rec.loan_participant_type,
																			l_loan_participant_rec.hz_party_id, l_loan_participant_rec.credit_request_id,
																			l_loan_participant_rec.case_folder_id, l_loan_participant_rec.object_version_number,
																			l_loan_participant_rec.review_type, l_loan_participant_rec.credit_classification;
		close c_get_primary_borrower;

		l_old_credit_request_id := l_loan_participant_rec.credit_request_id;
		if (l_old_credit_request_id is null) then
			return;
		end if;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling ');
		l_last_api_called := 'LNS_PARTICIPANTS_PUB.createCreditRequest';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
    createCreditRequest(p_loan_participant_rec  => l_loan_participant_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);

		l_new_credit_request_id := l_loan_participant_rec.credit_request_id;
		if (l_old_credit_request_id = l_new_credit_request_id) then
			--new credit request has not been submitted!
			return;
		end if;

		l_last_api_called := 'LNS_PARTICIPANTS_PUB.updateParticipant';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
		l_object_version := l_loan_participant_rec.object_version_number;
		updateParticipant(p_init_msg_list         => 'T',
											p_validation_level	    => FND_API.G_VALID_LEVEL_FULL,
											p_loan_participant_rec  => l_loan_participant_rec,
                      x_object_version_number => l_object_version,
											x_return_status        => l_return_status,
											x_msg_count            => l_msg_count,
											x_msg_data             => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);

		l_loan_header_rec.loan_id := l_loan_id;
		l_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;
		open C_GET_LOAN_OVN(l_loan_id);
		fetch C_GET_LOAN_OVN into l_object_version;
		close C_GET_LOAN_OVN;
		l_last_api_called := 'lns_loan_header_pub.update_loan';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
		lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_FALSE
																		,P_LOAN_HEADER_REC        => l_loan_header_rec
																		,P_OBJECT_VERSION_NUMBER => l_object_version
																		,X_RETURN_STATUS         => x_return_status
																		,X_MSG_COUNT             => x_msg_count
																		,X_MSG_DATA              => x_msg_data);

		x_return_status := l_return_status;
		x_msg_count := l_msg_count;
		x_msg_data := l_msg_data;
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');


    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createAppealCreditRequest;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createAppealCreditRequest;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createAppealCreditRequest;

END createAppealCreditRequest;

/*
|| Overview:    If credit_review_flag = 'Y' in LNS_LOAN_HEADERS for this loan
||              create a new credit request for Primary Borrower and Guarantor
||              If valid Credit Request already exists, then create a RESUBMISSION credit request for Primary Borrower
||
|| Parameter:   p_loan_participant_rec => participant details
*/
Procedure createCreditRequest(p_loan_participant_rec IN OUT NOCOPY loan_participant_rec_type,
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count            OUT NOCOPY NUMBER,
                       x_msg_data             OUT NOCOPY VARCHAR2)
IS
	l_api_name     CONSTANT VARCHAR2(30) := 'createCreditRequest';
  l_participant_type           varchar2(30);
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(1000);
  l_loan_id            number;
  l_org_id            number;
  l_credit_review_flag varchar2(1);
  l_loan_number varchar2(20);
	l_requested_amount number;
	l_loan_currency varchar2(30);
	l_loan_description varchar2(250);
	l_credit_request_id number;
	l_parent_credit_request_id number;
	l_guarantor_application_number varchar2(30);
	l_credit_request_type varchar2(30); --CREDIT_APP or RESUBMISSION
  l_last_api_called varchar2(500); --Store the last api that was called before exception
  l_loan_status varchar2(30);
	l_loan_sec_status varchar2(30);
	l_review_type varchar2(30);
	l_credit_classification varchar2(30);

	CURSOR c_get_loan_info(p_loan_id NUMBER) IS
	select org_id,credit_review_flag,loan_number,requested_amount,loan_currency,loan_description,loan_status,secondary_status
  from lns_loan_headers_all
  where loan_id = p_loan_id;

BEGIN

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

  l_last_api_called    := 'LNS_PARTICIPANTS_PUB.createCreditRequest';
  l_participant_type   := p_loan_participant_rec.LOAN_PARTICIPANT_TYPE;
  l_loan_id            := p_loan_participant_rec.loan_id;
  l_credit_request_id  := null;
	l_review_type        := p_loan_participant_rec.REVIEW_TYPE;
	l_credit_classification := p_loan_participant_rec.CREDIT_CLASSIFICATION;

    -- Standard Start of API savepoint
    SAVEPOINT createCreditRequest;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

		open c_get_loan_info(l_loan_id);
		fetch c_get_loan_info into l_org_id,l_credit_review_flag,l_loan_number,l_requested_amount,l_loan_currency,l_loan_description,l_loan_status,l_loan_sec_status;
		close c_get_loan_info;

		if (l_credit_review_flag <> 'Y') then
			return;
		end if;

    if (l_participant_type = 'PRIMARY_BORROWER') then

			 if (p_loan_participant_rec.credit_request_id is not null) then
				l_credit_request_type := 'RESUBMISSION';
				l_parent_credit_request_id := p_loan_participant_rec.credit_request_id;
			 else
				l_credit_request_type := 'CREDIT_APP';
				l_parent_credit_request_id := null;
			 end if;

			 if (l_credit_request_type = 'RESUBMISSION' AND (l_loan_status <> 'INCOMPLETE' OR l_loan_sec_status <> 'CREDIT_REVIEW_COMPLETE')) then
					--cannot create appeal credit request
					return;
				end if;

							--need to call credit request api
							--if (AR_CMGT_CREDIT_REQUEST_API.IS_CREDIT_MANAGEMENT_INSTALLED = true) then

							l_last_api_called    := 'AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST';
							logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
          		AR_CMGT_CREDIT_REQUEST_API.CREATE_CREDIT_REQUEST(
														 P_API_VERSION                  => 1.0
														,P_INIT_MSG_LIST                => FND_API.G_FALSE
														,P_COMMIT                       => FND_API.G_FALSE
														,P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL
														,X_RETURN_STATUS                => l_return_status
														,X_MSG_COUNT                    => l_msg_count
														,X_MSG_DATA                     => l_msg_data
														,P_APPLICATION_NUMBER           => l_loan_number
														,P_APPLICATION_DATE             => sysdate
														,P_REQUESTOR_TYPE               => 'EMPLOYEE'
														,P_REQUESTOR_ID                 => FND_GLOBAL.EMPLOYEE_ID
														,P_REVIEW_TYPE                  => l_review_type
														,P_CREDIT_CLASSIFICATION        => l_credit_classification
														,P_REQUESTED_AMOUNT             => l_requested_amount
														,P_REQUESTED_CURRENCY           => l_loan_currency
														,P_TRX_AMOUNT                   => l_requested_amount
														,P_TRX_CURRENCY                 => l_loan_currency
														,P_CREDIT_TYPE                  => 'TERM'
														,P_TERM_LENGTH                  => null
														,P_CREDIT_CHECK_RULE_ID         => null
														,P_CREDIT_REQUEST_STATUS        => 'SAVE'
														,P_PARTY_ID                     => p_loan_participant_rec.hz_party_id
														,P_CUST_ACCOUNT_ID              => null
														,P_CUST_ACCT_SITE_ID            => null
														,P_SITE_USE_ID                  => null
														,P_CONTACT_PARTY_ID             => null
														,P_NOTES                        => null
														,P_SOURCE_ORG_ID                => l_org_id --MO_GLOBAL.GET_CURRENT_ORG_ID()
														,P_SOURCE_USER_ID               => LNS_UTILITY_PUB.CREATED_BY
														,P_SOURCE_RESP_ID               => FND_GLOBAL.RESP_ID
														,P_SOURCE_APPLN_ID              => 206
														,P_SOURCE_SECURITY_GROUP_ID     => FND_GLOBAL.SECURITY_GROUP_ID
														,P_SOURCE_NAME                  => 'LNS'
														,P_SOURCE_COLUMN1               => l_loan_id
														,P_SOURCE_COLUMN2               => l_loan_number
														,P_SOURCE_COLUMN3               => l_loan_description
														,P_CREDIT_REQUEST_ID            => l_credit_request_id
														,P_REVIEW_CYCLE                 => null
														,P_CASE_FOLDER_NUMBER           => null
														,P_SCORE_MODEL_ID               => null
														,P_PARENT_CREDIT_REQUEST_ID     => l_parent_credit_request_id
														,P_CREDIT_REQUEST_TYPE          => l_credit_request_type
          		);
							logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);

          		x_return_status := l_return_status;
          		x_msg_count := l_msg_count;
          		x_msg_data := l_msg_data;
          		if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          			FND_MESSAGE.Set_Name('LNS', 'LNS_CREDIT_REQUEST_API_FAILED');
         				FND_MSG_PUB.Add;
         				RAISE FND_API.G_EXC_ERROR;
         			else
         				p_loan_participant_rec.CREDIT_REQUEST_ID := l_credit_request_id;
								if (l_credit_request_type = 'RESUBMISSION') then
									--set case_folder_id to null
									p_loan_participant_rec.case_folder_id :=  FND_API.G_MISS_NUM;
								end if;
          		end if;

    elsif (l_participant_type = 'COBORROWER') then

    	if (p_loan_participant_rec.credit_request_id is null) then

					--update with parent credit request id
						select credit_request_id into l_parent_credit_request_id
						from lns_participants
						where loan_id = l_loan_id
						and loan_participant_type = 'PRIMARY_BORROWER'
						and end_date_active is null;

						if (l_parent_credit_request_id is not null) then
							p_loan_participant_rec.CREDIT_REQUEST_ID := l_parent_credit_request_id;
						end if;

					end if;

    elsif (l_participant_type = 'GUARANTOR') then
    	if (p_loan_participant_rec.credit_request_id is null) then

					 --need to pass parent credit request id
						select credit_request_id into l_parent_credit_request_id
						from lns_participants
						where loan_id = l_loan_id
						and loan_participant_type = 'PRIMARY_BORROWER'
						and end_date_active is null;

						if (l_parent_credit_request_id is not null) then

							IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
											FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In checkPrimary: Before calling OCM_GUARANTOR_PUB.CREATE_GUARANTOR_CREDITREQUEST api');
							END IF;

							--Create Credit Request for Guarantor
							l_last_api_called    := 'OCM_GUARANTOR_PUB.CREATE_GUARANTOR_CREDITREQUEST';
							logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
							l_guarantor_application_number := l_loan_number;
							OCM_GUARANTOR_PUB.CREATE_GUARANTOR_CREDITREQUEST(
														 P_API_VERSION                  => 1.0
														,P_INIT_MSG_LIST                => FND_API.G_FALSE
														,P_COMMIT                       => FND_API.G_FALSE
														,P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL
														,X_RETURN_STATUS                => l_return_status
														,X_MSG_COUNT                    => l_msg_count
														,X_MSG_DATA                     => l_msg_data
														,X_GUARANTOR_CREDIT_REQUEST_ID  => l_credit_request_id
														,X_GUARANTOR_APPLICATION_NUMBER => l_guarantor_application_number
														,P_PARTY_ID                     => p_loan_participant_rec.hz_party_id
														,P_CONTACT_PARTY_ID             => null
														,P_PARENT_CREDIT_REQUEST_ID     => l_parent_credit_request_id
														,P_CURRENCY                     => l_loan_currency
														,P_GUARANTED_AMOUNT             => l_requested_amount
														,P_FUNDING_AVAILABLE_FROM       => null
														,P_FUNDING_AVAILABLE_TO         => null
														,P_CASE_FOLDER_ID               => null
														,P_NOTES                        => null
														,P_CREDIT_CLASSIFICATION        => l_credit_classification
														,P_REVIEW_TYPE                  => l_review_type
														,P_REQUESTOR_ID                 => FND_GLOBAL.EMPLOYEE_ID
														,P_SOURCE_ORG_ID                => l_org_id --MO_GLOBAL.GET_CURRENT_ORG_ID()
														,P_SOURCE_USER_ID               => LNS_UTILITY_PUB.CREATED_BY
														,P_SOURCE_RESP_ID               => FND_GLOBAL.RESP_ID
														,P_SOURCE_APPLN_ID              => 206
														,P_SOURCE_SECURITY_GROUP_ID     => FND_GLOBAL.SECURITY_GROUP_ID
														,P_SOURCE_NAME                  => 'LNS'
														,P_SOURCE_COLUMN1               => l_loan_id
														,P_SOURCE_COLUMN2               => l_loan_number
														,P_SOURCE_COLUMN3               => l_loan_description
														,P_CREDIT_REQUEST_STATUS        => 'SAVE'
														,P_REVIEW_CYCLE                 => null
														,P_CASE_FOLDER_NUMBER           => null
														,P_SCORE_MODEL_ID               => null
														,P_ASSET_CLASS_CODE             => null
													  ,P_ASSET_TYPE_CODE              => null
														,P_DESCRIPTION                  => null
														,P_QUANTITY                     => null
														,P_UOM_CODE                     => null
														,P_REFERENCE_TYPE               => null
														,P_APPRAISER                    => null
														,P_APPRAISER_PHONE              => null
														,P_VALUATION                    => null
														,P_VALUATION_METHOD_CODE        => null
														,P_VALUATION_DATE               => null
														,P_ACQUISITION_DATE             => null
														,P_ASSET_IDENTIFIER							=> null
							);
							logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);


							x_return_status := l_return_status;
							x_msg_count := l_msg_count;
							x_msg_data := l_msg_data;
							if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
								FND_MESSAGE.Set_Name('LNS', 'LNS_G_CRDT_REQ_API_FAILED');
								FND_MSG_PUB.Add;
								RAISE FND_API.G_EXC_ERROR;
							else
								p_loan_participant_rec.CREDIT_REQUEST_ID := l_credit_request_id;
							end if;

						end if; --if (l_parent_credit_request_id is not null) then

					end if; -- if (p_loan_participant_rec.credit_request_id is null) then

    end if; --if (l_participant_type = 'PRIMARY_BORROWER') then

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createCreditRequest;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createCreditRequest;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO createCreditRequest;

END createCreditRequest;

----------------------------------------------------------------
--This procedure updates the loan header with denormalized information
--from lns_participants for the primary borrower
----------------------------------------------------------------
Procedure denormalizePrimaryInfo(p_loan_participant_rec IN loan_participant_rec_type,
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count            OUT NOCOPY NUMBER,
                       x_msg_data             OUT NOCOPY VARCHAR2)
IS
  l_participant_type           varchar2(30);
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(32767);
  l_loan_header_rec    LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
  l_object_version     NUMBER;
  l_loan_id            number;
  l_last_api_called varchar2(500); --Store the last api that was called before exception
	l_api_name     CONSTANT VARCHAR2(30) := 'denormalizePrimaryInfo';

	CURSOR C_GET_LOAN_OVN(pLoanId Number) IS
	SELECT OBJECT_VERSION_NUMBER
	FROM
	LNS_LOAN_HEADERS_ALL
	WHERE LOAN_ID = pLoanId;

BEGIN
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
  l_last_api_called    := 'LNS_PARTICIPANTS_PUB.denormalizePrimaryInfo';
  l_participant_type   := p_loan_participant_rec.LOAN_PARTICIPANT_TYPE;
  l_loan_id            := p_loan_participant_rec.loan_id;

    -- Standard Start of API savepoint
    SAVEPOINT denormalizePrimaryInfo;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (l_participant_type = 'PRIMARY_BORROWER') then

          l_loan_header_rec.loan_id := p_loan_participant_rec.loan_id;
          l_loan_header_rec.cust_account_id := p_loan_participant_rec.cust_account_id;
          l_loan_header_rec.BILL_TO_ACCT_SITE_ID := p_loan_participant_rec.BILL_TO_ACCT_SITE_ID;
          l_loan_header_rec.primary_borrower_id := p_loan_participant_rec.hz_party_id;
          l_loan_header_rec.CONTACT_REL_PARTY_ID := p_loan_participant_rec.CONTACT_REL_PARTY_ID;
          l_loan_header_rec.CONTACT_PERS_PARTY_ID := p_loan_participant_rec.CONTACT_PERS_PARTY_ID;
						open C_GET_LOAN_OVN(l_loan_id);
						fetch C_GET_LOAN_OVN into l_object_version;
						close C_GET_LOAN_OVN;
					l_last_api_called	:= 'lns_loan_header_pub.update_loan';
					logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
          lns_loan_header_pub.update_loan(p_init_msg_list => FND_API.G_FALSE
																					,P_LOAN_HEADER_REC        => l_loan_header_rec
                                          ,P_OBJECT_VERSION_NUMBER => l_object_version
                                          ,X_RETURN_STATUS         => x_return_status
                                          ,X_MSG_COUNT             => x_msg_count
                                          ,X_MSG_DATA              => x_msg_data);
						logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);
          		x_return_status := l_return_status;
          		x_msg_count := l_msg_count;
          		x_msg_data := l_msg_data;
		end if; -- end if (l_participant_type = 'PRIMARY_BORROWER') then
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO denormalizePrimaryInfo;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
						FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO denormalizePrimaryInfo;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
            ROLLBACK TO denormalizePrimaryInfo;
End denormalizePrimaryInfo;

----------------------------------------------------------------
--This procedure changes all credit requests that have been created
--for the loan participants in SAVE status to SUBMIT status
--and changes the loan secondary status to IN_CREDIT_REVIEW
----------------------------------------------------------------
PROCEDURE submitCreditRequest(p_loan_id IN NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2)
IS
l_api_name     CONSTANT VARCHAR2(30) := 'submitCreditRequest';
l_last_api_called varchar2(500); --Store the last api that was called before exception

CURSOR C_GET_PRIMARY_CREQ_ID(pLoanId Number) IS
SELECT CREDIT_REQUEST_ID
FROM
LNS_PARTICIPANTS
WHERE LOAN_ID = pLoanId
AND LOAN_PARTICIPANT_TYPE = 'PRIMARY_BORROWER'
AND END_DATE_ACTIVE IS NULL;

CURSOR C_GET_LOAN_OVN(pLoanId Number) IS
SELECT OBJECT_VERSION_NUMBER
FROM
LNS_LOAN_HEADERS_ALL
WHERE LOAN_ID = pLoanId;

l_primary_credit_request_id number;
l_loan_header_rec    LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
l_object_version number;

BEGIN
	l_last_api_called := 'submitCreditRequest';
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

	x_return_status := FND_API.G_RET_STS_ERROR;

	open C_GET_PRIMARY_CREQ_ID(p_loan_id);
	fetch C_GET_PRIMARY_CREQ_ID into l_primary_credit_request_id;
 close C_GET_PRIMARY_CREQ_ID;

	if (l_primary_credit_request_id is not null) then

				IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
								FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In submitCreditRequest: Before calling OCM_CREDIT_REQUEST_UPDATE_PUB.update_credit_request_status api');
				END IF;
			l_last_api_called := 'OCM_CREDIT_REQUEST_UPDATE_PUB.update_credit_request_status';
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
			OCM_CREDIT_REQUEST_UPDATE_PUB.update_credit_request_status (
										p_api_version           => 1.0,
										p_init_msg_list         => FND_API.G_TRUE,
										p_commit                => FND_API.G_TRUE,
										p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
										x_return_status         => x_return_status,
										x_msg_count             => x_msg_count,
										x_msg_data              => x_msg_data,
										p_credit_request_id     => l_primary_credit_request_id,
									 p_credit_request_status => 'SUBMIT');
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);


				if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
						l_loan_header_rec.loan_id := p_loan_id;
						l_loan_header_rec.secondary_status := 'IN_CREDIT_REVIEW';
						open C_GET_LOAN_OVN(p_loan_id);
						fetch C_GET_LOAN_OVN into l_object_version;
						close C_GET_LOAN_OVN;

						IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
										FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In submitCreditRequest: Before calling lns_loan_header_pub.update_loan api');
						END IF;

						l_last_api_called := 'lns_loan_header_pub.update_loan';
						logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Before calling '|| l_last_api_called);
						lns_loan_header_pub.update_loan(
												p_init_msg_list         => FND_API.G_TRUE
											,P_LOAN_HEADER_REC       => l_loan_header_rec
											,P_OBJECT_VERSION_NUMBER => l_object_version
											,X_RETURN_STATUS         => x_return_status
											,X_MSG_COUNT             => x_msg_count
						 				,X_MSG_DATA              => x_msg_data);
						logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - After calling '|| l_last_api_called);

						COMMIT;

			 else

							FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
							FND_MESSAGE.Set_Name('LNS', 'LNS_CRDT_REQ_SUBMIT_API_FAILED');
							FND_MSG_PUB.Add;
							RAISE FND_API.G_EXC_ERROR;

				end if;

	else

				FND_MESSAGE.Set_Name('LNS', 'LNS_CREDIT_REQUEST_NOT_FOUND');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;

	end if;
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
END submitCreditRequest;


----------------------------------------------------------------
-- This is function updates lns_participants with the case_folder_id
-- if credit management case folder has been submitted with recommendations
-- for the loan application that submitted credit request
-- This is called from workflow business event from credit management
-- and also from the approval page UI if the loan is currently IN_CREDIT_REVIEW secondary status
-- This function returns 'Y' for Successful update, 'N' for update failure/error and 'I' for invalid condition
-- 'I' is returned when the loan has already changed status and case_folder_id has already been updated before
----------------------------------------------------------------
FUNCTION CASE_FOLDER_UPDATE(p_loan_id IN NUMBER) RETURN VARCHAR2
IS

l_return_flag VARCHAR2(1);
l_secondary_status VARCHAR2(30);
l_case_folder_count Number;
l_user_id NUMBER;
l_login_id NUMBER;
l_date DATE;
l_api_name     CONSTANT VARCHAR2(30) := 'CASE_FOLDER_UPDATE';

CURSOR check_loan_sec_status(pLoanId Number) is
select secondary_status
from lns_loan_headers_all
where loan_id = pLoanId;

CURSOR check_case_folder_complete(pLoanId Number) is
select count(case.case_folder_id)
from ar_cmgt_case_folders case, lns_participants part
where case.credit_request_id = part.credit_request_id and
part.loan_id = p_loan_id and
part.loan_participant_type = 'PRIMARY_BORROWER' and
part.end_date_active is null and
case.type = 'CASE' and
case.status = 'CLOSED';

CURSOR get_case_folder_info(pLoanId Number) is
SELECT case_folder.case_folder_id,case_folder.credit_classification,part.participant_id
FROM ar_cmgt_case_folders case_folder,lns_participants part
WHERE case_folder.credit_request_id = part.credit_request_id
AND part.loan_id = pLoanId
AND type = 'CASE'
AND status = 'CLOSED';

BEGIN
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

	l_return_flag := 'N';

	open check_loan_sec_status(p_loan_id);
	fetch check_loan_sec_status into l_secondary_status;
	close check_loan_sec_status;

	open check_case_folder_complete(p_loan_id);
	fetch check_case_folder_complete into l_case_folder_count;
	close check_case_folder_complete;
	if (l_case_folder_count IS NULL) then
		l_case_folder_count := 0;
	end if;

	if (l_secondary_status <> 'IN_CREDIT_REVIEW' OR l_case_folder_count <= 0) then
		l_return_flag := 'I';
		return l_return_flag;
	end if;

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE: Before calling update for lns_participants to update case_folder_id');
	END IF;

	l_user_id := LNS_UTILITY_PUB.created_by;
	l_login_id := LNS_UTILITY_PUB.last_update_login;
	l_date := sysdate;

	FOR case_folder_rec IN  get_case_folder_info(p_loan_id) LOOP
		UPDATE LNS_PARTICIPANTS
		SET CASE_FOLDER_ID = case_folder_rec.case_folder_id,
				CREDIT_CLASSIFICATION = case_folder_rec.credit_classification,
				LAST_UPDATED_BY = l_user_id,
				LAST_UPDATE_LOGIN = l_login_id,
				LAST_UPDATE_DATE = l_date,
				OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
		WHERE PARTICIPANT_ID = case_folder_rec.participant_id;
	END LOOP;

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE: After calling update for lns_participants to update case_folder_id');
	END IF;

        --Call to record history
        LNS_LOAN_HISTORY_PUB.log_record_pre(
                p_id => p_loan_id,
                p_primary_key_name => 'LOAN_ID',
                p_table_name => 'LNS_LOAN_HEADERS_ALL'
        );

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE: Before calling update for lns_loan_headers_all to update new secondary status');
	END IF;

	UPDATE LNS_LOAN_HEADERS_ALL
	SET SECONDARY_STATUS = 'CREDIT_REVIEW_COMPLETE',
				LAST_UPDATED_BY = l_user_id,
				LAST_UPDATE_LOGIN = l_login_id,
				LAST_UPDATE_DATE = l_date,
				OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
	WHERE LOAN_ID = p_loan_id
	AND SECONDARY_STATUS = 'IN_CREDIT_REVIEW'
	AND EXISTS (SELECT case_folder_id
	            FROM LNS_PARTICIPANTS
	            WHERE loan_id = LNS_LOAN_HEADERS_ALL.loan_id and hz_party_id = LNS_LOAN_HEADERS_ALL.primary_borrower_id);

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE: After calling update for lns_loan_headers_all to update new secondary status');
	END IF;

        --Call to record history
        LNS_LOAN_HISTORY_PUB.log_record_post(
                p_id => p_loan_id,
                p_primary_key_name => 'LOAN_ID',
                p_table_name => 'LNS_LOAN_HEADERS_ALL',
                p_loan_id => p_loan_id
        );

	COMMIT WORK;

	open check_loan_sec_status(p_loan_id);
	fetch check_loan_sec_status into l_secondary_status;
	close check_loan_sec_status;

	if (l_secondary_status = 'CREDIT_REVIEW_COMPLETE') then
		l_return_flag := 'Y';
	end if;

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

	return l_return_flag;

EXCEPTION
 WHEN OTHERS THEN

 	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE: Unexpected ERROR in the function call. SQLERRM is: ' || SQLERRM);
	END IF;

	return l_return_flag;

END CASE_FOLDER_UPDATE;

----------------------------------------------------------------
--This is rule function, that is subscribed to the Oracle Workflow
-- Business Event CreditRequest.Recommendation.implement
--to implement recomendations of the AR CRedit Management Review
----------------------------------------------------------------
FUNCTION OCM_WORKFLOW_CREDIT_RECO_EVENT(p_subscription_guid IN RAW,
																				p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2
IS
l_key                  VARCHAR2(240);
l_source_name										VARCHAR2(30);
l_source_column1       VARCHAR2(150);
l_source_column2       VARCHAR2(150);
l_source_column3       VARCHAR2(150);
l_party_id             NUMBER;
l_cust_account_id      NUMBER;
l_site_use_id          NUMBER;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(30);
l_credit_request_id    NUMBER;
l_loan_id              NUMBER;
l_org_id               NUMBER;
l_wf_return_status     VARCHAR2(30);
l_user_id              NUMBER;
l_resp_id              NUMBER;
l_resp_appl_id         NUMBER;
l_security_group_id    NUMBER;
l_case_folder_id       NUMBER;
l_loan_header_rec    LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
l_object_version number;
l_update_status_flag VARCHAR2(1);

CURSOR C_GET_LOAN_OVN(pLoanId Number) IS
SELECT OBJECT_VERSION_NUMBER
FROM
LNS_LOAN_HEADERS_ALL
WHERE LOAN_ID = pLoanId;

BEGIN

		l_wf_return_status := 'SUCCESS';

  l_key                  := p_event.GetEventKey();
  l_credit_request_id    := p_event.GetValueForParameter('CREDIT_REQUEST_ID');
  l_source_name 				 := p_event.GetValueForParameter('SOURCE_NAME');
  l_source_column1       := p_event.GetValueForParameter('SOURCE_COLUMN1');
  l_source_column2       := p_event.GetValueForParameter('SOURCE_COLUMN2');
  l_source_column3       := p_event.GetValueForParameter('SOURCE_COLUMN3');
  l_party_id 						 := p_event.GetValueForParameter('PARTY_ID');
  l_cust_account_id 		 := p_event.GetValueForParameter('CUST_ACCOUNT_ID');
  l_org_id               := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize(l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);
  MO_GLOBAL.INIT('LNS');
  MO_GLOBAL.set_policy_context('S',l_org_id);

	 IF (l_source_name = 'LNS') THEN
	 		l_loan_id := l_source_column1;
			l_update_status_flag := LNS_PARTICIPANTS_PUB.CASE_FOLDER_UPDATE(l_loan_id);

			if (l_update_status_flag NOT IN ('I', 'Y')) then
				l_wf_return_status := 'ERROR';
			end if;

			/*
			IF (l_credit_request_id IS NOT NULL) THEN
	 				SELECT CASE_FOLDER_ID INTO l_case_folder_id
	 				FROM
	 				AR_CMGT_CASE_FOLDERS
	 				WHERE CREDIT_REQUEST_ID = l_credit_request_id;

	 				IF (l_case_folder_id IS NOT NULL) THEN
	 						UPDATE LNS_PARTICIPANTS
	 						SET CASE_FOLDER_ID = l_case_folder_id
	 						WHERE CREDIT_REQUEST_ID = l_credit_request_id;

								l_loan_header_rec.loan_id := l_loan_id;
								l_loan_header_rec.secondary_status := 'CREDIT_REVIEW_COMPLETE';
								open C_GET_LOAN_OVN(l_loan_id);
								fetch C_GET_LOAN_OVN into l_object_version;
								close C_GET_LOAN_OVN;

								IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
												FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In OCM_WORKFLOW_CREDIT_RECO_EVENT: Before calling lns_loan_header_pub.update_loan api');
								END IF;

								lns_loan_header_pub.update_loan(
														p_init_msg_list         => FND_API.G_TRUE
													,P_LOAN_HEADER_REC       => l_loan_header_rec
													,P_OBJECT_VERSION_NUMBER => l_object_version
													,X_RETURN_STATUS         => l_return_status
													,X_MSG_COUNT             => l_msg_count
													,X_MSG_DATA              => l_msg_data);

									if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
										l_wf_return_status := 'ERROR';
									else
										COMMIT;
									end if;

									IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
													FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In OCM_WORKFLOW_CREDIT_RECO_EVENT: After calling lns_loan_header_pub.update_loan api: return_status:'||l_return_status);
									END IF;


	 				END IF; -- IF (l_case_folder_id IS NOT NULL) THEN

	 		END IF; -- IF (l_credit_request_id IS NOT NULL) THEN
			*/
	 END IF; -- IF (l_source_name = 'LNS') THEN

  RETURN l_wf_return_status;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
    FND_MSG_PUB.ADD;
    WF_CORE.CONTEXT(G_PKG_NAME,
                    'OCM_WORKFLOW_CREDIT_RECO_EVENT',
                    p_event.getEventName(),
                    p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');

    RETURN 'ERROR';

END OCM_WORKFLOW_CREDIT_RECO_EVENT;


----------------------------------------------------------------
--This procedure
--
--
----------------------------------------------------------------
PROCEDURE getDefaultPrimaryContact(p_loan_participant_rec IN OUT NOCOPY loan_participant_rec_type,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2)
IS

        l_party_type varchar2(30);
        l_api_name    CONSTANT       varchar2(25) := 'getDefaultPrimaryContact';

	CURSOR c_get_party_type(p_party_id number) IS
	select party_type
	from hz_parties
	where party_id = p_party_id;

BEGIN

 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, p_loan_participant_rec.LOAN_PARTICIPANT_TYPE);
	IF p_loan_participant_rec.LOAN_PARTICIPANT_TYPE <> 'PRIMARY_BORROWER' THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Contact Person '||p_loan_participant_rec.CONTACT_PERS_PARTY_ID||' and Rel PartyId is '||p_loan_participant_rec.CONTACT_REL_PARTY_ID);

	IF (p_loan_participant_rec.CONTACT_PERS_PARTY_ID IS NULL or p_loan_participant_rec.CONTACT_PERS_PARTY_ID = FND_API.G_MISS_NUM) AND
 (p_loan_participant_rec.CONTACT_REL_PARTY_ID IS NULL OR p_loan_participant_rec.CONTACT_REL_PARTY_ID = FND_API.G_MISS_NUM) THEN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Contact Person and PartyId are NULL');
		p_loan_participant_rec.CONTACT_REL_PARTY_ID := p_loan_participant_rec.HZ_PARTY_ID;

		open c_get_party_type(p_loan_participant_rec.HZ_PARTY_ID);
		fetch c_get_party_type into l_party_type;
		close c_get_party_type;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Party Type is '||l_party_type ||' for '||p_loan_participant_rec.HZ_PARTY_ID);
		IF l_party_type = 'PERSON' THEN
			p_loan_participant_rec.CONTACT_PERS_PARTY_ID := p_loan_participant_rec.HZ_PARTY_ID;
		END IF;
	END IF;
 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

END getDefaultPrimaryContact;



END LNS_PARTICIPANTS_PUB;

/
