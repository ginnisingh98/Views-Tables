--------------------------------------------------------
--  DDL for Package Body OCM_CREDIT_REQUEST_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_CREDIT_REQUEST_UPDATE_PUB" AS
/*$Header: OCMUPCRB.pls 120.6.12010000.2 2008/09/24 15:10:06 mraymond ship $  */

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

TYPE ID_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.OCM_CREDIT_REQUEST_UPDATE_PUB' );
END;

PROCEDURE UPDATE_CREDIT_REQUEST (
        p_api_version           IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2 ,
        p_commit                IN          VARCHAR2,
        p_validation_level      IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        p_credit_request_rec    IN	credit_request_rec ) IS

        l_conc_request_id			NUMBER;
        l_status                    VARCHAR2(2000);
        l_credit_request_status     ar_cmgt_credit_requests.status%type;
    	l_resultout                 VARCHAR2(2000);
		itemtype					VARCHAR2(30) := 'ARCMGTAP';
		itemkey						VARCHAR2(30);
        l_check_flag                VARCHAr2(60);
BEGIN
		IF pg_debug = 'Y'
		THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST(+)');
			debug ( 'Trx Amount ' || p_credit_request_rec.trx_amount);
			debug ( 'Requested  Amount ' || p_credit_request_rec.requested_amount);
			debug ( 'Requestor ID ' || p_credit_request_rec.requestor_id);
			debug ( 'Case Folder ID ' || p_credit_request_rec.case_folder_id);
			debug ( 'Credit Request ID ' || p_credit_request_rec.credit_request_id);
            debug ( 'Credit Request Status ' || p_credit_request_rec.credit_request_status);
            debug ( 'Credit Classification ' || p_credit_request_rec.credit_classification);
            debug ( 'review_type  ' || p_credit_request_rec.review_type);
		END IF;

		SAVEPOINT UPDATE_CREDIT_REQ_PVT;

		x_return_status         := FND_API.G_RET_STS_SUCCESS;
		itemkey := p_credit_request_rec.credit_request_id;

		IF FND_API.to_Boolean( p_init_msg_list )
        THEN
              FND_MSG_PUB.initialize;
        END IF;

        IF p_credit_request_rec.credit_request_status IS NULL
        THEN
            IF p_credit_request_rec.credit_request_id IS NOT NULL
            THEN
                    SELECT STATUS
                    INTO   l_credit_request_status
                    FROM   ar_cmgt_credit_requests
                    WHERE  credit_request_id = p_credit_request_rec.credit_request_id;
            END IF;
        ElSE
            l_credit_request_status := p_credit_request_rec.credit_request_status;
        END IF;
		IF l_credit_request_status IN ( 'SUBMIT', 'IN_PROCESS' )
        THEN

		  UPDATE ar_cmgt_credit_requests
			SET trx_amount = nvl(p_credit_request_rec.trx_amount, trx_amount),
			    limit_amount = nvl(p_credit_request_rec.requested_amount, limit_amount),
			    requestor_id = nvl(p_credit_request_rec.requestor_id, requestor_id),
			    last_updated_by = fnd_global.user_id,
				last_update_date = sysdate
		  WHERE  credit_request_id = p_credit_request_rec.credit_request_id;

		  -- Need to update the workflow attributes.
		  -- first check whether workflow is initiated
		  BEGIN
			WF_ENGINE.ItemStatus(
						itemType => 'ARCMGTAP',
                        itemkey  => p_credit_request_rec.credit_request_id,
                        status   => l_status,
                        result   => l_resultout);
            IF l_status <> 'COMPLETE'
            THEN
				WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTED_CREDIT_LIMIT',
                                avalue   =>  p_credit_request_rec.requested_amount );
        		WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_PERSON_ID',
                                avalue   =>  p_credit_request_rec.requestor_id );
            END IF;
            EXCEPTION
            	WHEN OTHERS THEN
            		-- means wf is not yet started
            		NULL;
         END;
		 -- Submit Refresh case Folder Request
		 IF p_credit_request_rec.case_folder_id IS NOT NULL
		 THEN
			IF pg_debug = 'Y'
			THEN
				debug ( 'AR_CMGT_REFRESH_CONC.submit_refresh_request(+)');
			END IF;
			AR_CMGT_REFRESH_CONC.submit_refresh_request (
				p_case_folder_id =>    p_credit_request_rec.case_folder_id,
       			p_called_from    =>		'OCM_UPDATE_CREDIT_REQUEST',
       			p_conc_request_id   => l_conc_request_id );
       		IF pg_debug = 'Y'
			THEN
				debug ( 'Concurrent Request ID ' || l_conc_request_id);
				debug ( 'AR_CMGT_REFRESH_CONC.submit_refresh_request(-)');
			END IF;
       	 END IF;
        ELSIF  l_credit_request_status = 'SAVE'
        THEN
                -- validate critical values before doing updation
                IF p_credit_request_rec.requestor_id IS NOT NULL
                THEN
                  IF nvl(p_credit_request_rec.requestor_type,'EMPLOYEE')='EMPLOYEE'
		          THEN
                    BEGIN
                       SELECT 'x' INTO l_check_flag
                       FROM   PER_ALL_PEOPLE_F
                       WHERE  sysdate between effective_start_date and effective_end_date
                       and  current_employee_flag = 'Y'
                       and  person_id = p_credit_request_rec.requestor_id;

                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                x_msg_data := 'Invalid Requestor Id';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                            WHEN OTHERS THEN
                                x_msg_data := Sqlerrm;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                    END;
		          ELSIF p_credit_request_rec.requestor_type = 'FND_USER'
		          THEN
                    BEGIN
                       SELECT 'x' INTO l_check_flag
                       FROM   fnd_user
                       WHERE user_id =  p_credit_request_rec.requestor_id;

                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                x_msg_data := 'Invalid User Id';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                            WHEN OTHERS THEN
                                x_msg_data := Sqlerrm;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                    END;
		          ELSE
                      x_msg_data := 'Invalid requestor';
                      x_return_status := FND_API.G_RET_STS_ERROR;
		              return;

                END IF;
	       END IF;
                IF p_credit_request_rec.credit_type IS NOT NULL
                THEN
                    BEGIN
                        SELECT lookup_code INTO l_check_flag
                        FROM   ar_lookups
                        WHERE  lookup_type = 'AR_CMGT_CREDIT_TYPE'
                        AND    lookup_code = p_credit_request_rec.credit_type;

                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                x_msg_data := 'Invalid Credit Type';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                            WHEN OTHERS THEN
                                x_msg_data := Sqlerrm;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;

                    END;
                END IF;
                UPDATE ar_cmgt_credit_requests
                SET  trx_amount = nvl(p_credit_request_rec.trx_amount, trx_amount),
			         limit_amount = nvl(p_credit_request_rec.requested_amount, limit_amount),
			         requestor_id = nvl(p_credit_request_rec.requestor_id, requestor_id),
			         last_updated_by = fnd_global.user_id,
				     last_update_date = sysdate,
                     review_type   =  nvl(p_credit_request_rec.review_type, review_type),
                     credit_classification = nvl(p_credit_request_rec.credit_classification, credit_classification),
                     limit_currency   = nvl( p_credit_request_rec.requested_currency, limit_currency),
                     trx_currency     = nvl( p_credit_request_rec.trx_currency, trx_currency),
                     credit_type      = nvl( p_credit_request_rec.credit_type, credit_type ),
                     term_length      = nvl( p_credit_request_rec.term_length, term_length ),
                     credit_check_rule_id 	= nvl( p_credit_request_rec.credit_check_rule_id, credit_check_rule_id ),
                     party_id         = nvl( p_credit_request_rec.party_id, party_id),
                     cust_account_id  = nvl( p_credit_request_rec.cust_account_id, cust_account_id ),
                     cust_acct_site_id = nvl( p_credit_request_rec.cust_acct_site_id, cust_acct_site_id ),
                     site_use_id       = nvl( p_credit_request_rec.site_use_id, site_use_id ),
                     contact_party_id  = nvl( p_credit_request_rec.contact_party_id, contact_party_id ),
                     notes             = nvl( p_credit_request_rec.notes, notes),
                     source_org_id     = nvl( p_credit_request_rec.source_org_id, source_org_id),
                     source_user_id    = nvl( p_credit_request_rec.source_user_id, source_user_id),
                     source_resp_id    = nvl( p_credit_request_rec.source_resp_id, source_resp_id),
                     source_resp_appln_id   = nvl( p_credit_request_rec.source_resp_appln_id, source_resp_appln_id),
                     source_security_group_id  = nvl( p_credit_request_rec.source_security_group_id, source_security_group_id),
                     source_name          	=  nvl( p_credit_request_rec.source_name, source_name),
                     source_column1       	= nvl( p_credit_request_rec.source_column1, source_column1),
                     source_column2       	= nvl( p_credit_request_rec.source_column2, source_column2),
                     source_column3       	= nvl( p_credit_request_rec.source_column3, source_column3),
                     review_cycle          	= nvl( p_credit_request_rec.review_cycle,review_cycle),
                     stock_exchange         = nvl( p_credit_request_rec.stock_exchange, stock_exchange),
                     current_stock_price    = nvl( p_credit_request_rec.current_stock_price, current_stock_price),
                     stock_currency         = nvl( p_credit_request_rec.stock_currency,stock_currency),
                     market_capitalization     =   nvl( p_credit_request_rec.market_capitalization,market_capitalization),
                     market_cap_monetary_unit  =   nvl( p_credit_request_rec.market_cap_monetary_unit,market_cap_monetary_unit),
                     pending_litigations       =   nvl( p_credit_request_rec.pending_litigations,pending_litigations),
                     bond_rating               =   nvl( p_credit_request_rec.bond_rating,bond_rating),
                     legal_entity_name         =   nvl( p_credit_request_rec.legal_entity_name,legal_entity_name),
                     entity_type               =   nvl( p_credit_request_rec.entity_type,entity_type),
                     RECOMMENDATION_NAME       =   nvl( p_credit_request_rec.RECOMMENDATION_NAME,RECOMMENDATION_NAME)
                   WHERE credit_request_id =  p_credit_request_rec.credit_request_id
                   AND   status = 'SAVE';

        END IF;
       	IF pg_debug = 'Y'
		THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST(-)');
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				ROLLBACK TO UPDATE_CREDIT_REQ_PVT;
                FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','UPDATE_CREDIT_REQUEST : '||SQLERRM);
                FND_MSG_PUB.Add;
                FND_MSG_PUB.Count_And_Get(p_encoded      => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

END;

PROCEDURE GET_CREDIT_REQUEST_REC (
		p_credit_request_id		IN			  NUMBER,
		p_return_status			OUT NOCOPY	  VARCHAR2,
		p_error_msg				OUT NOCOPY 	  VARCHAR2,
        p_credit_request_rec    OUT NOCOPY    credit_request_rec ) IS

l_credit_request_id				ar_cmgt_credit_requests.credit_request_id%type;
l_APPLICATION_NUMBER			ar_cmgt_credit_requests.APPLICATION_NUMBER%type;
l_APPLICATION_DATE				ar_cmgt_credit_requests.application_date%type;
l_REQUESTOR_TYPE				ar_cmgt_credit_requests.requestor_type%type;
l_REQUESTOR_ID					ar_cmgt_credit_requests.requestor_id%type;
l_REVIEW_TYPE					ar_cmgt_credit_requests.review_type%type;
l_CREDIT_CLASSIFICATION			ar_cmgt_credit_requests.credit_classification%type;
l_CHECK_LIST_ID					ar_cmgt_credit_requests.check_list_id%type;
l_CREDIT_ANALYST_ID				ar_cmgt_credit_requests.credit_analyst_id%type;
l_LIMIT_AMOUNT					ar_cmgt_credit_requests.limit_amount%type;
l_LIMIT_CURRENCY				ar_cmgt_credit_requests.limit_currency%type;
l_TRX_AMOUNT					ar_cmgt_credit_requests.trx_amount%type;
l_TRX_CURRENCY					ar_cmgt_credit_requests.trx_currency%type;
l_CREDIT_CHECK_RULE_ID			ar_cmgt_credit_requests.credit_check_rule_id%type;
l_TERM_LENGTH					ar_cmgt_credit_requests.term_length%type;
l_CREDIT_TYPE					ar_cmgt_credit_requests.credit_type%type;
l_PARTY_ID						ar_cmgt_credit_requests.party_id%type;
l_CUST_ACCOUNT_ID				ar_cmgt_credit_requests.cust_account_id%type;
l_CUST_ACCT_SITE_ID				ar_cmgt_credit_requests.cust_acct_site_id%type;
l_SITE_USE_ID					ar_cmgt_credit_requests.site_use_id%type;
l_CONTACT_PARTY_ID				ar_cmgt_credit_requests.contact_party_id%type;
l_STOCK_EXCHANGE				ar_cmgt_credit_requests.stock_exchange%type;
l_CURRENT_STOCK_PRICE			ar_cmgt_credit_requests.current_stock_price%type;
l_STOCK_CURRENCY				ar_cmgt_credit_requests.stock_currency%type;
l_MARKET_CAPITALIZATION			ar_cmgt_credit_requests.market_capitalization%type;
l_MARKET_CAP_MONETARY_UNIT		ar_cmgt_credit_requests.market_cap_monetary_unit%type;
l_PENDING_LITIGATIONS			ar_cmgt_credit_requests.pending_litigations%type;
l_BOND_RATING					ar_cmgt_credit_requests.bond_rating%type;
l_LEGAL_ENTITY_NAME				ar_cmgt_credit_requests.legal_entity_name%type;
l_ENTITY_TYPE					ar_cmgt_credit_requests.entity_type%type;
l_CASE_FOLDER_NUMBER			ar_cmgt_credit_requests.case_folder_number%type;
l_SCORE_MODEL_ID				ar_cmgt_credit_requests.score_model_id%type;
l_STATUS						ar_cmgt_credit_requests.status%type;
l_SOURCE_NAME					ar_cmgt_credit_requests.source_name%type;
l_SOURCE_USER_ID				ar_cmgt_credit_requests.source_user_id%type;
l_SOURCE_RESP_ID				ar_cmgt_credit_requests.source_resp_id%type;
l_SOURCE_RESP_APPLN_ID			ar_cmgt_credit_requests.source_resp_appln_id%type;
l_SOURCE_SECURITY_GROUP_ID		ar_cmgt_credit_requests.source_security_group_id%type;
l_SOURCE_ORG_ID					ar_cmgt_credit_requests.source_org_id%type;
l_SOURCE_COLUMN1				ar_cmgt_credit_requests.source_column1%type;
l_SOURCE_COLUMN2				ar_cmgt_credit_requests.source_column2%type;
l_SOURCE_COLUMN3				ar_cmgt_credit_requests.source_column3%type;
l_NOTES							ar_cmgt_credit_requests.notes%type;
l_REVIEW_CYCLE					ar_cmgt_credit_requests.review_cycle%type;

BEGIN
	IF pg_debug = 'Y'
	THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC(+)');
	END IF;
	p_return_status         := FND_API.G_RET_STS_SUCCESS;
	-- Get credit request rec
	SELECT 	credit_request_id,
			APPLICATION_NUMBER,
			APPLICATION_DATE,
			REQUESTOR_TYPE,
			REQUESTOR_ID,
			REVIEW_TYPE,
			CREDIT_CLASSIFICATION,
			CHECK_LIST_ID,
			CREDIT_ANALYST_ID,
			LIMIT_AMOUNT,
			LIMIT_CURRENCY,
			TRX_AMOUNT,
			TRX_CURRENCY,
			CREDIT_CHECK_RULE_ID,
			TERM_LENGTH,
			CREDIT_TYPE,
			PARTY_ID,
			CUST_ACCOUNT_ID,
			CUST_ACCT_SITE_ID,
			SITE_USE_ID,
			CONTACT_PARTY_ID,
			STOCK_EXCHANGE,
			CURRENT_STOCK_PRICE,
			STOCK_CURRENCY,
			MARKET_CAPITALIZATION,
			MARKET_CAP_MONETARY_UNIT,
			PENDING_LITIGATIONS,
			BOND_RATING,
			LEGAL_ENTITY_NAME,
			ENTITY_TYPE,
			CASE_FOLDER_NUMBER,
			SCORE_MODEL_ID,
			STATUS,
			SOURCE_NAME,
			SOURCE_USER_ID,
			SOURCE_RESP_ID,
			SOURCE_RESP_APPLN_ID,
			SOURCE_SECURITY_GROUP_ID,
			SOURCE_ORG_ID,
			SOURCE_COLUMN1,
			SOURCE_COLUMN2,
			SOURCE_COLUMN3,
			NOTES,
			REVIEW_CYCLE
	INTO	l_credit_request_id,
			l_APPLICATION_NUMBER,
			l_APPLICATION_DATE,
			l_REQUESTOR_TYPE,
			l_REQUESTOR_ID,
			l_REVIEW_TYPE,
			l_CREDIT_CLASSIFICATION,
			l_CHECK_LIST_ID,
			l_CREDIT_ANALYST_ID,
			l_LIMIT_AMOUNT,
			l_LIMIT_CURRENCY,
			l_TRX_AMOUNT,
			l_TRX_CURRENCY,
			l_CREDIT_CHECK_RULE_ID,
			l_TERM_LENGTH,
			l_CREDIT_TYPE,
			l_PARTY_ID,
			l_CUST_ACCOUNT_ID,
			l_CUST_ACCT_SITE_ID,
			l_SITE_USE_ID,
			l_CONTACT_PARTY_ID,
			l_STOCK_EXCHANGE,
			l_CURRENT_STOCK_PRICE,
			l_STOCK_CURRENCY,
			l_MARKET_CAPITALIZATION,
			l_MARKET_CAP_MONETARY_UNIT,
			l_PENDING_LITIGATIONS,
			l_BOND_RATING,
			l_LEGAL_ENTITY_NAME,
			l_ENTITY_TYPE,
			l_CASE_FOLDER_NUMBER,
			l_SCORE_MODEL_ID,
			l_STATUS,
			l_SOURCE_NAME,
			l_SOURCE_USER_ID,
			l_SOURCE_RESP_ID,
			l_SOURCE_RESP_APPLN_ID,
			l_SOURCE_SECURITY_GROUP_ID,
			l_SOURCE_ORG_ID,
			l_SOURCE_COLUMN1,
			l_SOURCE_COLUMN2,
			l_SOURCE_COLUMN3,
			l_NOTES,
			l_REVIEW_CYCLE
	FROM   ar_cmgt_credit_requests
	WHERE  credit_request_id = p_credit_request_id;

	IF pg_debug = 'Y'
	THEN
        debug ('OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC (+)' );
        debug ('Credit request Id : '|| l_credit_request_id );
		debug ('APPLICATION_NUMBER '||	l_APPLICATION_NUMBER);
		debug ('APPLICATION_DATE '||	l_APPLICATION_DATE);
		debug ('REQUESTOR_TYPE '|| 	l_REQUESTOR_TYPE);
		debug ('REQUESTOR_ID ' || l_REQUESTOR_ID);
		debug ('REVIEW_TYPE '||	l_REVIEW_TYPE);
		debug ('CREDIT_CLASSIFICATION '||	l_CREDIT_CLASSIFICATION);
		debug ('CHECK_LIST_ID '||	l_CHECK_LIST_ID);
		debug ('CREDIT_ANALYST_ID '||	l_CREDIT_ANALYST_ID);
		debug ('LIMIT_AMOUNT '||	l_LIMIT_AMOUNT);
		debug ('LIMIT_CURRENCY '||	l_LIMIT_CURRENCY);
		debug ('TRX_AMOUNT '||	l_TRX_AMOUNT);
		debug ('TRX_CURRENCY '||	l_TRX_CURRENCY);
		debug ('CREDIT_CHECK_RULE_ID '||	l_CREDIT_CHECK_RULE_ID);
		debug ('TERM_LENGTH '||	l_TERM_LENGTH);
		debug ('CREDIT_TYPE '||	l_CREDIT_TYPE);
		debug ('PARTY_ID '||	l_PARTY_ID);
		debug ('CUST_ACCOUNT_ID '||	l_CUST_ACCOUNT_ID);
		debug ('CUST_ACCT_SITE_ID '||	l_CUST_ACCT_SITE_ID);
		debug ('SITE_USE_ID '||	l_SITE_USE_ID);
		debug ('CONTACT_PARTY_ID '||	l_CONTACT_PARTY_ID);
		debug ('STOCK_EXCHANGE '|| 	l_STOCK_EXCHANGE);
		debug ('CURRENT_STOCK_PRICE '||	l_CURRENT_STOCK_PRICE);
		debug ('STOCK_CURRENCY '||	l_STOCK_CURRENCY);
		debug ('MARKET_CAPITALIZATION '||	l_MARKET_CAPITALIZATION);
		debug ('MARKET_CAP_MONETARY_UNIT '||	l_MARKET_CAP_MONETARY_UNIT);
		debug ('PENDING_LITIGATIONS '||	l_PENDING_LITIGATIONS);
		debug ('BOND_RATING ' ||	l_BOND_RATING);
		debug ('LEGAL ENTITY NAMe '||	l_LEGAL_ENTITY_NAME);
		debug ('ENTITY_TYPE '||	l_ENTITY_TYPE);
		debug ('CASE_FOLDER_NUMBER '||	l_CASE_FOLDER_NUMBER);
		debug ('SCORE_MODEL_ID '|| 	l_SCORE_MODEl_ID);
		debug ('STATUS '|| 	l_STATUS);
		debug ('SOURCE_NAME '||	l_SOURCE_NAME);
		debug ('SOURCE_USER_ID '|| 	l_SOURCE_USER_ID);
		debug ('SOURCE_RESP_ID '||	l_SOURCE_RESP_ID);
		debug ('SOURCE_RESP_APPLN_ID '||	l_SOURCE_RESP_APPLN_ID);
		debug ('SOURCE_SECURITY_GROUP_ID '||	l_SOURCE_SECURITY_GROUP_ID);
		debug ('SOURCE_ORG_ID '||	l_SOURCE_ORG_ID);
		debug ('SOURCE_COLUMN1 '||	l_SOURCE_COLUMN1);
		debug ('SOURCE_COLUMN2 '||	l_SOURCE_COLUMN2);
		debug ('SOURCE_COLUMN3 ' ||	l_SOURCE_COLUMN3);
		debug ('NOTES '||	l_NOTES );
		debug ('REVIEW_CYCLE '||	l_REVIEW_CYCLE );
	END IF;

	p_credit_request_rec.credit_request_id := l_credit_request_id;
	p_credit_request_rec.APPLICATION_NUMBER :=  l_APPLICATION_NUMBER;
	p_credit_request_rec.APPLICATION_DATE :=  l_APPLICATION_DATE;
	p_credit_request_rec.REQUESTOR_TYPE :=  l_REQUESTOR_TYPE;
	p_credit_request_rec.REQUESTOR_ID :=  l_REQUESTOR_ID;
	p_credit_request_rec.REVIEW_TYPE :=  l_REVIEW_TYPE;
	p_credit_request_rec.CREDIT_CLASSIFICATION :=  l_CREDIT_CLASSIFICATION;
	p_credit_request_rec.CHECK_LIST_ID :=  l_CHECK_LIST_ID;
	p_credit_request_rec.CREDIT_ANALYST_ID :=  l_CREDIT_ANALYST_ID;
	p_credit_request_rec.REQUESTED_AMOUNT :=  l_LIMIT_AMOUNT;
	p_credit_request_rec.REQUESTED_CURRENCY :=  l_LIMIT_CURRENCY;
	p_credit_request_rec.TRX_AMOUNT :=  l_TRX_AMOUNT;
	p_credit_request_rec.TRX_CURRENCY :=  l_TRX_CURRENCY;
	p_credit_request_rec.CREDIT_CHECK_RULE_ID :=  l_CREDIT_CHECK_RULE_ID;
	p_credit_request_rec.TERM_LENGTH :=  l_TERM_LENGTH;
	p_credit_request_rec.CREDIT_TYPE :=  l_CREDIT_TYPE;
	p_credit_request_rec.PARTY_ID :=  l_PARTY_ID;
	p_credit_request_rec.CUST_ACCOUNT_ID :=  l_CUST_ACCOUNT_ID;
	p_credit_request_rec.CUST_ACCT_SITE_ID :=  l_CUST_ACCT_SITE_ID;
	p_credit_request_rec.SITE_USE_ID :=  l_SITE_USE_ID;
	p_credit_request_rec.CONTACT_PARTY_ID :=  l_CONTACT_PARTY_ID;
	p_credit_request_rec.STOCK_EXCHANGE :=  l_STOCK_EXCHANGE;
	p_credit_request_rec.CURRENT_STOCK_PRICE :=  l_CURRENT_STOCK_PRICE;
	p_credit_request_rec.STOCK_CURRENCY :=  l_STOCK_CURRENCY;
	p_credit_request_rec.MARKET_CAPITALIZATION :=  l_MARKET_CAPITALIZATION;
	p_credit_request_rec.MARKET_CAP_MONETARY_UNIT :=  l_MARKET_CAP_MONETARY_UNIT;
	p_credit_request_rec.PENDING_LITIGATIONS :=  l_PENDING_LITIGATIONS;
	p_credit_request_rec.BOND_RATING :=  l_BOND_RATING;
	p_credit_request_rec.LEGAL_ENTITY_NAME :=  l_LEGAL_ENTITY_NAME;
	p_credit_request_rec.ENTITY_TYPE :=  l_ENTITY_TYPE;
	p_credit_request_rec.CASE_FOLDER_NUMBER :=  l_CASE_FOLDER_NUMBER;
	p_credit_request_rec.SCORE_MODEL_ID :=  l_SCORE_MODEL_ID;
	p_credit_request_rec.SOURCE_NAME :=  l_SOURCE_NAME;
	p_credit_request_rec.SOURCE_USER_ID :=  l_SOURCE_USER_ID;
	p_credit_request_rec.SOURCE_RESP_ID :=  l_SOURCE_RESP_ID;
	p_credit_request_rec.SOURCE_RESP_APPLN_ID :=  l_SOURCE_RESP_APPLN_ID;
	p_credit_request_rec.SOURCE_SECURITY_GROUP_ID :=  l_SOURCE_SECURITY_GROUP_ID;
	p_credit_request_rec.SOURCE_ORG_ID :=  l_SOURCE_ORG_ID;
	p_credit_request_rec.SOURCE_COLUMN1 :=  l_SOURCE_COLUMN1;
	p_credit_request_rec.SOURCE_COLUMN2 :=  l_SOURCE_COLUMN2;
	p_credit_request_rec.SOURCE_COLUMN3 :=  l_SOURCE_COLUMN3;
	p_credit_request_rec.NOTES :=  l_NOTES;
	p_credit_request_rec.REVIEW_CYCLE :=  l_REVIEW_CYCLE;

	IF pg_debug = 'Y'
	THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC(-)');
	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND
		THEN
			NULL;
		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			p_error_msg := 'OCM_CREDIT_REQUEST_UPDATE_PUB.GET_CREDIT_REQUEST_REC '|| sqlerrm;

END;

PROCEDURE update_credit_request_status (
		p_api_version           IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN          VARCHAR2,
        p_validation_level      IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        p_credit_request_id		IN			NUMBER,
        p_credit_request_status	IN			VARCHAR2 DEFAULT 'SUBMIT') IS

        l_status				ar_cmgt_credit_requests.status%type;

        CURSOR cCreditRequests IS
        	SELECT credit_request_id
        	FROM   ar_cmgt_credit_requests
        	WHERE  parent_credit_request_id = p_credit_request_id
        	AND    status = 'SAVE';

    /* 6838491 */
    l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_guar_credit_request_id   ar_cmgt_credit_requests.credit_request_id%TYPE;
    i                          NUMBER := 0;
    datapoint_t    id_type; -- table
    guarcredreq_t  id_type; -- table

    CURSOR c_guar_list(cp_credit_request_id NUMBER) IS
        SELECT  gd.datapoint_id, -- unique key
                gd.credit_request_id, gd.review_type, gd.credit_classification,
                gd.guaranteed_amount, gd.currency, gd.party_id,
                gd.contact_party_id, gd.notes,
                pr.source_org_id, pr.source_user_id,
                pr.source_resp_id, pr.source_resp_appln_id,
                pr.source_security_group_id,
                pr.source_name parent_source_name,
                pr.application_date parent_application_date,
                pr.requestor_type, pr.requestor_id
        FROM    ar_cmgt_guarantor_data gd,
                ar_cmgt_credit_requests pr
        WHERE   gd.credit_request_id = cp_credit_request_id
        AND     gd.credit_request_id = pr.credit_request_id
        AND     gd.guarantor_credit_request_id IS NULL; -- prevents duplics

BEGIN
	IF pg_debug = 'Y'
	THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.update_credit_request_status(+)');
			debug ( 'Credit request Id :' || to_char(p_credit_request_id));
			debug ( 'Status :' || p_credit_request_status);
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SAVEPOINT UPDATE_CREDIT_REQ_STATUS;

	IF FND_API.to_Boolean( p_init_msg_list )
    THEN
    	FND_MSG_PUB.initialize;
    END IF;

    -- first check the status in case it was passed
    IF p_credit_request_status NOT IN ( 'SUBMIT', 'SAVE')
    THEN
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	x_msg_data := 'Invalid Status';
    	return;
    END IF;

	-- check for valid credit request id and status
	BEGIN
		SELECT status
		INTO   l_status
		FROM   ar_cmgt_credit_requests
		WHERE  credit_request_id = p_credit_request_id;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    			x_msg_data := 'Invalid Credit Request Id';
    			return;
    		WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    			x_msg_data := sqlerrm;
    			return;
	END;

	IF l_status = 'SAVE' and p_credit_request_status = 'SUBMIT'
	THEN
		IF pg_debug = 'Y'
		THEN
			debug ( 'Updating Status to Submit anc calling WF (+)');
		END IF;
		-- submit workflow
		UPDATE ar_cmgt_credit_requests
		SET    status = 'SUBMIT',
		       last_updated_by = fnd_global.user_id,
		       last_update_date = sysdate
		WHERE  credit_request_id = p_credit_request_id;

		AR_CMGT_WF_ENGINE.START_WORKFLOW
                (p_credit_request_id ,p_credit_request_status);

		IF pg_debug = 'Y'
		THEN
			debug ( 'Updating Status to Submit anc calling WF (-)');
		END IF;
	END IF;

        /* 6838491 - OKL has directly referenced some OCM OAF components
           and that includes the Guarantor pages.  So they (OKL) can
           add Guarantors to Saved CRs.  However, OCM submits the
           child CRs for the Guarantors from the submit button on the UI
           and this is not available to OKL.

           To rectify, we need to see if there are guarantors for this
           parent request, and submit child CRs for each guarantor. */

        FOR c_guar IN c_guar_list(p_credit_request_id) LOOP

           IF pg_debug = 'Y'
	   THEN
	      debug ( 'Processing guarantor party_id = ' || c_guar.party_id);
	   END IF;

          AR_CMGT_CREDIT_REQUEST_API.create_credit_request
             (p_api_version                => 1 ,
              p_init_msg_list              => FND_API.G_FALSE,
              p_commit                     => FND_API.G_FALSE,
              p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
              x_return_status              => l_return_status ,
              x_msg_count                  => l_msg_count ,
              x_msg_data                   => l_msg_data  ,
              p_application_number         => NULL ,
              p_application_date           => c_guar.parent_application_date,
              p_requestor_type             => NULL ,
              p_requestor_id               => -1 ,
              p_review_type                => c_guar.review_type,
              p_review_cycle               => NULL ,
              p_credit_classification      => c_guar.credit_classification ,
              p_requested_amount           => c_guar.guaranteed_amount ,
              p_requested_currency         => c_guar.currency ,
              p_trx_amount                 => c_guar.guaranteed_amount ,
              p_trx_currency               => c_guar.currency ,
              p_credit_type                => 'TRADE' ,
              p_term_length                => 0 ,
              p_credit_check_rule_id       => 0 ,
              p_credit_request_status      => 'SUBMIT',
              p_party_id                   => c_guar.party_id ,
              p_cust_account_id            => -99 ,
              p_cust_acct_site_id          => -99 ,
              p_site_use_id                => -99 ,
              p_contact_party_id           => c_guar.contact_party_id,
              p_notes                      => c_guar.notes,
              p_source_org_id              => c_guar.source_org_id,
              p_source_user_id             => c_guar.source_user_id,
              p_source_resp_id             => c_guar.source_resp_id,
              p_source_appln_id            => c_guar.source_resp_appln_id,
              p_source_security_group_id   => c_guar.source_security_group_id,
              p_source_name                => c_guar.parent_source_name,
              p_source_column1             => NULL ,
              p_source_column2             => NULL ,
              p_source_column3             => NULL ,
              p_case_folder_number         => NULL ,
              p_score_model_id             => NULL ,
              p_credit_request_id          => l_guar_credit_request_id,  --out
              p_parent_credit_request_id   => p_credit_request_id,
              p_credit_request_type        =>'GUARANTOR' ) ;

           IF pg_debug = 'Y'
	   THEN
	      debug ( 'Processed guarantor party_id = ' || c_guar.party_id ||
                        ' credit_request_id = ' || l_guar_credit_request_id);
	   END IF;

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
              debug('Creating guarantor credit request failed');
	      x_return_status := l_return_status;
              x_msg_data := l_msg_data;
              x_msg_count := l_msg_count;
    	      ROLLBACK TO UPDATE_CREDIT_REQ_STATUS;
              RETURN;
           END IF;

           /* Store datapoint_id and guarantor_credit_request_id
              so we can stamp them on ar_cmgt_guarantor_data afterwards */
           datapoint_t(i) := c_guar.datapoint_id;
           guarcredreq_t(i) := l_guar_credit_request_id;
           i := i + 1;
        END LOOP;

        /* Now update ar_cmgt_guarantor_data to set
            guarantor_credit_request_id */
        IF i > 0
        THEN
           /* 6956789 - Only execute update if there are rows
               to process */
           FORALL x in datapoint_t.FIRST..datapoint_t.LAST
             UPDATE ar_cmgt_guarantor_data
             SET    guarantor_credit_request_id = guarcredreq_t(x)
             WHERE  datapoint_id =                datapoint_t(x);
        END IF;

        /* End 6838491 */

	-- now submit all the child credit request in case if exists any
	FOR cCreditRequestsRec IN cCreditRequests
	LOOP
		IF pg_debug = 'Y'
		THEN
			debug ( 'Submitting child credit requests '|| to_char(cCreditRequestsRec.credit_request_id));
		END IF;

		UPDATE ar_cmgt_credit_requests
		SET    status = 'SUBMIT',
		       last_updated_by = fnd_global.user_id,
		       last_update_date = sysdate
		WHERE  credit_request_id = cCreditRequestsRec.credit_request_id;

		AR_CMGT_WF_ENGINE.START_WORKFLOW
                (cCreditRequestsRec.credit_request_id ,p_credit_request_status);

	END LOOP;

	IF pg_debug = 'Y'
	THEN
			debug ( 'Submitted All Child Credit requests');
	END IF;
	IF pg_debug = 'Y'
	THEN
			debug ( 'OCM_CREDIT_REQUEST_UPDATE_PUB.update_credit_request_status(-)');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    		x_msg_data := sqlerrm;
    		ROLLBACK TO UPDATE_CREDIT_REQ_STATUS;
    		return;
END;

END OCM_CREDIT_REQUEST_UPDATE_PUB;

/
