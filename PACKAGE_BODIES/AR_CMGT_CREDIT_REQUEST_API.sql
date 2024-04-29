--------------------------------------------------------
--  DDL for Package Body AR_CMGT_CREDIT_REQUEST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_CREDIT_REQUEST_API" AS
/*$Header: ARCMCRAB.pls 120.27.12010000.7 2009/11/19 00:24:19 rravikir ship $  */

/* bug4414414 :  Added paramters p_parent_credit_request_id and p_credit_request_type
*/

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
  IF pg_debug = 'Y' THEN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.AR_CMGT_CREDIT_REQUEST_API' );
  END IF;
END;


PROCEDURE create_credit_request
     ( p_api_version      		IN NUMBER,
       p_init_msg_list     		IN VARCHAR2 ,
       p_commit            		IN VARCHAR2,
       p_validation_level  		IN VARCHAR2,
       x_return_status     		OUT NOCOPY VARCHAR2,
       x_msg_count         		OUT NOCOPY NUMBER,
       x_msg_data          		OUT NOCOPY VARCHAR2,
       p_application_number  	IN VARCHAR2,
       p_application_date    	IN DATE,
       p_requestor_type      	IN VARCHAR2,
       p_requestor_id        	IN NUMBER, --this happens to be the HR person_id of
                                      --the requestor
       p_review_type           	IN VARCHAR2,
       p_credit_classification 	IN VARCHAR2,
       p_requested_amount     	IN NUMBER,
       p_requested_currency   	IN VARCHAR2,
       p_trx_amount           	IN NUMBER,
       p_trx_currency         	IN VARCHAR2,
       p_credit_type          	IN VARCHAR2,
       p_term_length          	IN NUMBER,  --the unit is no of months
       p_credit_check_rule_id 	IN NUMBER, --this is the credit check rule from the OM
       p_credit_request_status	IN VARCHAR2, --SAVE or FINISH
       p_party_id             	IN NUMBER,
       p_cust_account_id      	IN NUMBER,
       p_cust_acct_site_id    	IN NUMBER,
       p_site_use_id          	IN NUMBER,
       p_contact_party_id     	IN NUMBER, --this is the party_id of the pseudo party
                                       --created becoz of the contact relationship.
       p_notes                		IN VARCHAR2,
       p_source_org_id          	IN NUMBER,
       p_source_user_id         	IN NUMBER,
       p_source_resp_id         	IN NUMBER,
       p_source_appln_id        	IN NUMBER,
       p_source_security_group_id   IN NUMBER,
       p_source_name          		IN VARCHAR2,
       p_source_column1       		IN VARCHAR2,
       p_source_column2       		IN VARCHAR2,
       p_source_column3       		IN VARCHAR2,
       p_credit_request_id    		OUT NOCOPY NUMBER,
       p_review_cycle          		IN VARCHAR2 ,
       p_case_folder_number   		IN  VARCHAR2,
       p_score_model_id	      		IN  NUMBER,
       p_parent_credit_request_id IN NUMBER  DEFAULT NULL,
       p_credit_request_type    IN VARCHAR2 DEFAULT NULL,
       p_reco                   IN VARCHAR2 DEFAULT NULL
       ) IS
l_sys_params_rec         ar_cmgt_setup_options%rowtype;
l_application_number     VARCHAR2(30);
l_credit_request_id      NUMBER(15);
l_application_date       DATE;
l_credit_request_status  VARCHAR2(10);
l_char                   VARCHAR2(1);
l_credit_type            ar_cmgt_credit_requests.credit_type%type;
l_isupdateable           VARCHAR2(1) := 'N';
l_case_folder_id         ar_cmgt_case_folders.case_folder_id%type;
l_case_folder_status     ar_cmgt_case_folders.status%type;
p_credit_request_rec     OCM_CREDIT_REQUEST_UPDATE_PUB.credit_request_rec;
l_parent_cr_status       VARCHAR2(15);
l_value1                 VARCHAR2(60);
l_value2                 VARCHAR2(60);
l_credit_request_type    ar_cmgt_credit_requests.credit_request_type%type;
l_requestor_type                 ar_cmgt_credit_requests.requestor_type%type;
l_trx_amount            NUMBER;
l_requested_amount      NUMBER;
l_requestor_id          NUMBER;

CURSOR system_parameters IS
SELECT *
FROM ar_cmgt_setup_options;

CURSOR employee(p_person_id IN NUMBER) is
SELECT 'x'
FROM   PER_ALL_PEOPLE_F
WHERE  sysdate between effective_start_date and effective_end_date
  and  current_employee_flag = 'Y'
  and  person_id = p_person_id;

CURSOR cFndUser(cp_user_id NUMBER) is
SELECT 'x'
FROM   fnd_user
WHERE  sysdate between start_date and nvl(end_date, sysdate)
and  user_id = cp_user_id;

 BEGIN

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

      SAVEPOINT CREATE_CREDIT_REQ_PVT;


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;

	IF pg_debug = 'Y'
        THEN
                debug ( 'AR_CMGT_CREDIT_REQUEST_API(+)');
                debug ( 'Application Number ' || p_application_number );
                debug ( 'Requestor Type ' || p_requestor_type   );
                debug ( 'Requestor Id ' || p_requestor_id   );
                debug ( 'Review Type ' || p_review_type   );
                debug ( 'Classification ' || p_credit_classification   );
                debug ( 'Party Id ' || p_party_id  );
                debug ( 'Account Id' || p_cust_account_id  );
                debug ( 'Site Use Id' || p_site_use_id  );
                debug ( 'Parent Credit request Id ' || p_parent_credit_request_id  );
                debug ( 'Credit request type' || p_credit_request_type );
                debug ( 'Recommendation ' || p_reco );
                debug ( 'Status ' || p_credit_request_status );
                debug ( 'Source Name' || p_source_name );
                debug ( 'Source Id' || p_source_column1  );
                debug ( 'Req Currency ' || p_requested_currency );
                debug ( 'Trx Currency ' || p_trx_currency );
        END IF;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status         := FND_API.G_RET_STS_SUCCESS;
        l_application_date      := p_application_date;
        l_application_number    := p_application_number;
        l_credit_request_status := p_credit_request_status;
        l_requestor_type        := p_requestor_type;
   	    l_requestor_id          := p_requestor_id;

        IF p_credit_request_type IS NULL
        THEN
            l_credit_request_type := 'CREDIT_APP';
        ELSE
            l_credit_request_type := p_credit_request_type;
        END IF;

        IF l_requestor_type IS NULL -- For Backward compatibility
        THEN
           l_requestor_type := 'FND_USER/EMPLOYEE';
        ELSIF l_requestor_type IS NOT NULL AND
           l_requestor_type NOT IN ('EMPLOYEE', 'FND_USER')
        THEN
          IF pg_debug = 'Y'
          THEN
            debug ( 'Invalid Requestor Type ' || l_requestor_type );
          END IF;
          FND_MESSAGE.SET_NAME('AR','OCM_INVALID_REQUESTOR_TYPE');
          FND_MSG_PUB.Add;
          x_msg_data := 'OCM_INVALID_REQUESTOR_TYPE';
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
        END IF;

        debug ( 'l_requestor_type ' || l_requestor_type );

        IF l_requestor_type = 'FND_USER/EMPLOYEE'
        THEN
          /* Not Sure of the Source since p_request_type is passed as NULL
             In that case first check the requestor ID, if its passed as -1
             or NULL then take the FND_GLOBAL.USER_ID and set the request
             type as FND_USER.

             If the Requestor ID is not NULL or <> -1 then check if the
             Requestor is an Employee
             Else check if the Requestor is a FND User
          */

            IF l_requestor_id IS NULL OR l_requestor_id = -1
            THEN
               debug('p_requestor_type is passed as NULL, p_requestor_id is NULL or -1, use FND USER');
               l_requestor_id := FND_GLOBAL.USER_ID;
               l_requestor_type := 'FND_USER';
               debug('p_requestor_type is passed as NULL, l_requestor_id:'||
                  l_requestor_id||' l_requestor_type :'||l_requestor_type);
            ELSE
               debug('p_requestor_type is passed as NULL, check both EMPLOYEE and FND_USER');
               OPEN employee(l_requestor_id);
               FETCH employee INTO l_char;
               IF employee%NOTFOUND
               THEN
                     debug('p_requestor_type is passed as NULL, EMPLOYEE check failed');
                  OPEN cFndUser(l_requestor_id);
                  FETCH cFndUser INTO l_char;
                  IF cFndUser%NOTFOUND
                  THEN
                     debug('p_requestor_type is passed as NULL, FND_USER check failed');
                     x_return_status := FND_API.G_RET_STS_ERROR;
                  ELSE
                     -- The Requestor is a FND User, set the Requestor Type
                     l_requestor_type := 'FND_USER';
                  END IF;
                  CLOSE cFndUser;

               ELSE
                  -- The Requestor is an Employee, set the Requestor Type
                  l_requestor_type := 'EMPLOYEE';
               END IF;
               CLOSE employee;
            END IF;
            debug('p_requestor_type is passed as NULL, l_requestor_type IS :'||
               l_requestor_type);

        ELSIF l_requestor_id IS NOT NULL and l_requestor_type = 'EMPLOYEE'
        THEN
           --verify if the requestor_id is indeed the
           --person_id existing in the HR
           OPEN employee(l_requestor_id);
           FETCH employee INTO l_char;
           IF employee%NOTFOUND THEN
              debug('p_requestor_type is passed, Employee check is failed');
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE employee;
        ELSIF l_requestor_id IS NOT NULL and l_requestor_type = 'FND_USER'
        THEN
           OPEN cFndUser(l_requestor_id);
           FETCH cFndUser INTO l_char;
           IF cFndUser%NOTFOUND
           THEN
              debug('p_requestor_type is passed, FND USER check is failed');
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE cFndUser;
        ELSE
           debug('p_requestor_type is NOT passed OR Request ID is passed as NULL');
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/
        /* bug4556688: Added code for validating the request for appeal project
        Validation :1. Check for p_credit_request_type for 'APPEAL','APPEAL_REJECTION'
                   and 'RESUBMISSION'.
                2. Check whether p_parent_credit_request_id is not null
                3. The parent credit request must be completed.
                4. Party Id, Cust Account Id, Site Id, Currency, Credit Classification,
                   Review Type must be same as parent credit request.
                5. In case of Appeal, Appeal Rejection  parent credit request
                    must have 'AUTHORIZE_APPEAL' recommendation.
                6. The value1 column will contain the Number of days Appeal is authorised.
                   The value2 column will contain the expiration date of Appeal.
                7. In case of Appeal we need to validate the credit application date
                   must be less than or equal to Appeal expiration date.
            If any of above is not met then reject the credit request.
        */
    BEGIN
        SELECT 'X'
        INTO   l_char
        FROM   ar_lookups
        WHERE  lookup_type = 'OCM_CREDIT_REQUEST_TYPE'
        AND    lookup_code = l_credit_request_type;
    EXCEPTION
        WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('AR','OCM_UNKNOWN_CREDIT_REQUEST');
             FND_MSG_PUB.Add;
	     x_return_status := FND_API.G_RET_STS_ERROR;
             return;
    END;

    IF  l_char IS NOT NULL
    THEN

       IF  ( l_credit_request_type = 'APPEAL' or
            l_credit_request_type = 'APPEAL_REJECTION' or
            l_credit_request_type = 'RESUBMISSION' )
       THEN

         IF p_parent_credit_request_id is not NULL
         THEN
               BEGIN
                   select status
                   into   l_parent_cr_status
                   from   ar_cmgt_credit_requests
                   where  credit_request_id = p_parent_credit_request_id
                   and    party_id = p_party_id
                   and    nvl(cust_account_id,-99) = nvl(p_cust_account_id,-99)
                   and    nvl(site_use_id,-99) = nvl(p_site_use_id,-99)
                   and    nvl(trx_currency,limit_currency) = p_trx_currency
                   and    credit_classification = p_credit_classification
                   and    review_type = p_review_type;

                   IF pg_debug = 'Y'
                   THEN
                      debug ( 'Inside Appeal, Parent Credit request Status '||
                      l_parent_cr_status);
                   END IF;

                   IF l_parent_cr_status = 'PROCESSED'
                   THEN
                      IF l_credit_request_type in ( 'APPEAL', 'APPEAL_REJECTION')
                      THEN

                        BEGIN
                             select recommendation_value1,
                                    recommendation_value2
                             into   l_value1,
                                    l_value2
                             from   ar_cmgt_cf_recommends
                             where  credit_request_id = p_parent_credit_request_id
                             and    credit_recommendation = 'AUTHORIZE_APPEAL'
                             and    status = 'I'
                             and    rownum = 1;

                             IF pg_debug = 'Y'
                             THEN
                                debug ( 'Reco value 1 '||l_value1);
                                debug ( 'Reco value 2 '||l_value2);
                             END IF;

                             IF  trunc(fnd_date.canonical_to_date(p_application_date))
                               > trunc(fnd_date.canonical_to_date(l_value2))
                             THEN
                                -- reject the application
                                IF pg_debug = 'Y'
                                THEN
                                   debug ( 'Appeal request is Out of date range');
                                END IF;
                                FND_MESSAGE.SET_NAME('AR','OCM_APPEAL_EXPIRATION_REQUEST');
                                FND_MSG_PUB.Add;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                             END IF;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                  -- reject the application
                                FND_MESSAGE.SET_NAME('AR','OCM_NO_RECO_APPEAL_REQUEST');
                                FND_MSG_PUB.Add;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                          WHEN OTHERS THEN
                                  -- reject the application
                                FND_MESSAGE.SET_NAME('AR','OCM_NO_RECO_APPEAL_REQUEST');
                                FND_MSG_PUB.Add;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        END;
                      END IF; -- end APPEAL/APPEAL_REJECTION

                   ELSE
                      -- reject the application as parent request is not closed
                      FND_MESSAGE.SET_NAME('AR','OCM_NO_PARENT_APPEAL_REQUEST');
                      FND_MSG_PUB.Add;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- reject the application
                     FND_MESSAGE.SET_NAME('AR','OCM_NO_PARENT_APPEAL_REQUEST');
                     FND_MSG_PUB.Add;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                  WHEN OTHERS THEN
                     -- reject the application
                     FND_MESSAGE.SET_NAME('AR','OCM_NO_PARENT_APPEAL_REQUEST');
                     FND_MSG_PUB.Add;
                     x_return_status := FND_API.G_RET_STS_ERROR;
               END;

         ELSE
            -- reject the application parent credit request id is null
            FND_MESSAGE.SET_NAME('AR','OCM_NO_PARENT_APPEAL_REQUEST');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF; -- end parent_credit_request_id is not null
       END IF; -- end APPEAL/REJECTION/RESUBMISSION

    ELSE
      -- reject the application as request type is unknown
      FND_MESSAGE.SET_NAME('AR','OCM_UNKNOWN_CREDIT_REQUEST');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF; -- end 'unknown' credit_request_type


    -- Bug 4137766, In case request comes from OM
    -- need to verify update is possible or not.
    IF p_source_name = 'OM' and x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        -- Get the credit request Id
        p_credit_request_rec.credit_request_status := 'SUBMIT';

             BEGIN
                SELECT credit_request_id
                INTO   l_credit_request_id
                FROM   ar_cmgt_credit_requests
                WHERE  source_name = p_source_name
                AND    source_column1 = p_source_column1
                AND    party_id = p_party_id
                AND    cust_account_id = nvl(p_cust_account_id, -99)
                AND    site_use_id  = nvl(p_site_use_id, -99)
                AND    status <> 'PROCESSED';

                l_isupdateable  := 'Y';
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_credit_request_id := null;
                   l_isupdateable  := 'N';
                WHEN TOO_MANY_ROWS THEN
                   -- this is for backward compatibitilty
                   -- get the latest credit request id
                   BEGIN
                      SELECT max(credit_request_id)
                      INTO   l_credit_request_id
                      FROM   ar_cmgt_credit_requests
                      WHERE  source_name = p_source_name
                      AND    source_column1 = p_source_column1
                      AND    party_id = p_party_id
                      AND    cust_account_id = nvl(p_cust_account_id, -99)
                      AND    site_use_id  = nvl(p_site_use_id, -99)
                      AND    status <> 'PROCESSED';

                      l_isupdateable := 'Y'; -- 7185336
                   EXCEPTION
                      WHEN OTHERS THEN
                         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                            'GETTING_MAX_CREDIT_REQUEST_FOR_UPDATE : '||SQLERRM);
                         FND_MSG_PUB.Add;
                         return;
                   END;

                WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                   FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                   FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                       'GETTING_CREDIT_REQUEST_FOR_UPDATE : '||SQLERRM);
                   FND_MSG_PUB.Add;
                   return;
                END;

        BEGIN
           /* 7185336 -- Originally, this only found case folders
              where status NOT IN SUBMITTED/CLOSED.  However, we
              need to differentiate between situations where
              the case folder exists vs ones where it does not to
              determine if we are attempting to update one that is literally
              in progress at the time of the call */
           SELECT case_folder_id, status
           INTO   l_case_folder_id, l_case_folder_status
           FROM   ar_cmgt_case_folders
           WHERE  credit_request_id =  l_credit_request_id
           AND    type = 'CASE';

           -- Now upadate the records
           UPDATE ar_cmgt_case_folders
           SET    STATUS = 'REFRESH',
                  last_updated_by = fnd_global.user_id,
                  last_update_date = sysdate,
                  last_updated = sysdate
           WHERE  case_folder_id = l_case_folder_id
           AND    status NOT IN ('SUBMITTED','CLOSED');

           /* 7185336 - if the case folder is CLOSED or SUBMITTED,
              then we need a new one.  Otherwise, we can wait for
              the existing one to become available */
           IF l_case_folder_status IN ('SUBMITTED','CLOSED')
           THEN
              -- need a new one
              l_isupdateable := 'N';
           ELSE
              -- we can use the existing request/folder
              l_isupdateable := 'Y';
              p_credit_request_rec.credit_request_status := 'IN_PROCESS';
           END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               /* 7185336 - This means there literally was no case folder
                  for this active request.  Likely a timing issue */
               IF l_isupdateable  = 'Y'
               THEN
                   select trx_amount,limit_amount
                   into   l_trx_amount,l_requested_amount
                   from   ar_cmgt_credit_requests
                   where  credit_request_id = l_credit_request_id;

                   IF l_trx_amount = p_trx_amount AND
                      l_requested_amount = p_requested_amount
                   THEN
                      debug('sent for process already.Will return back.');
                      p_credit_request_id := l_credit_request_id;
                      return;
                   END IF;
               END IF;
            WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
               FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
                    'GETTING_CASE_FOLDER_FOR_UPDATE : '||SQLERRM);
               FND_MSG_PUB.Add;
               return;
        END;

        IF l_isupdateable  = 'Y'
        THEN
           -- Now call Update API to update credit request.
           -- FOR OM we will be updating only Amount.
           p_credit_request_rec.credit_request_id := l_credit_request_id;
           p_credit_request_id := l_credit_request_id;
           p_credit_request_rec.case_folder_id := l_case_folder_id;
           p_credit_request_rec.trx_amount := p_trx_amount;
           p_credit_request_rec.requested_amount := p_requested_amount;
           p_credit_request_rec.requestor_id := l_requestor_id;


           OCM_CREDIT_REQUEST_UPDATE_PUB.UPDATE_CREDIT_REQUEST (
                       p_api_version           => p_api_version,
                       p_init_msg_list         => p_init_msg_list,
                       p_commit                => p_commit,
                       p_validation_level      => p_validation_level,
                       x_return_status         => x_return_status,
                       x_msg_count             => x_msg_count,
                       x_msg_data              => x_msg_data,
                       p_credit_request_rec    => p_credit_request_rec );
           return;
        END IF; -- end of l_isupdateable

    END IF; -- p_source_name = 'OM'

       /*-----------------------------------------+
        |   DEFAULTING                            |
        +-----------------------------------------*/

         OPEN system_parameters;
         FETCH system_parameters INTO l_sys_params_rec;
         CLOSE system_parameters;

         IF l_application_date IS NULL  THEN
           l_application_date := trunc(sysdate);
         END IF;

        IF    l_application_number IS NULL
         AND nvl(l_sys_params_rec.auto_application_num_flag, 'N') = 'Y'
         THEN
           SELECT AR_CMGT_APPLICATION_NUM_S.NEXTVAL, AR_CMGT_CREDIT_REQUESTS_S.NEXTVAL
           INTO l_application_number, l_credit_request_id
           FROM DUAL;

        END IF;

        IF l_credit_request_id IS NULL THEN
          SELECT AR_CMGT_CREDIT_REQUESTS_S.NEXTVAL
          INTO   l_credit_request_id
          FROM dual;
        END IF;

    /*-----------------------------------------+
    |   VALIDATION                            |
    +-----------------------------------------*/
	IF l_requestor_id IS NOT NULL and l_requestor_type = 'EMPLOYEE'
	THEN
	--verify if the requestor_id is indeed the
	--person_id existing in the HR
		OPEN employee(l_requestor_id);
		FETCH employee INTO l_char;
		IF employee%NOTFOUND THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		CLOSE employee;
	ELSIF l_requestor_id IS NOT NULL and l_requestor_type =
	'FND_USER'
	THEN
		OPEN cFndUser(l_requestor_id);
		FETCH cFndUser INTO l_char;
		IF cFndUser%NOTFOUND
		THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
		CLOSE cFndUser;
	ELSE
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

          IF p_party_id IS NULL
          THEN
           --raise error message
           FND_MESSAGE.SET_NAME('AR','AR_CMGT_NULL_PARTY_ID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF p_review_type IS  NULL
           THEN
            --raise error message
           debug('AR_CMGT_NULL_REVIEW_TYPE');
           FND_MESSAGE.SET_NAME('AR','AR_CMGT_NULL_REVIEW_TYPE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF p_requested_currency IS NULL
           THEN
            --raise error message
               debug('AR_CMGT_NULL_REQ_CURR');
               FND_MESSAGE.SET_NAME('AR','AR_CMGT_NULL_REQ_CURR');
               FND_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF p_credit_type IS NULL
           THEN
            --raise error
            debug('AR_CMGT_NULL_CREDIT_TYPE');
            FND_MESSAGE.SET_NAME('AR','AR_CMGT_NULL_CREDIT_TYPE');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
            --verify the specified value is from lookups
            BEGIN
                SELECT lookup_code INTO l_credit_type
                FROM   ar_lookups
                WHERE  lookup_type = 'AR_CMGT_CREDIT_TYPE'
                AND    lookup_code = p_credit_type;

                EXCEPTION
                    WHEN OTHERS THEN
                       debug('AR_CMGT_INVALID_CREDIT_TYPE');
                       FND_MESSAGE.SET_NAME('AR','AR_CMGT_INVALID_CREDIT_TYPE');
                       FND_MSG_PUB.Add;
                       x_return_status := FND_API.G_RET_STS_ERROR;
            END;
          END IF;

          IF l_credit_request_status IS NULL
           THEN
             l_credit_request_status := 'SUBMIT';
          ELSE
            IF l_credit_request_status NOT IN
                                 ('SUBMIT','SAVE')
              THEN
               --raise error
               debug('AR_CMGT_INVALID_CR_STATUS');
               FND_MESSAGE.SET_NAME('AR','AR_CMGT_INVALID_CR_STATUS');
               FND_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

          END IF;

          -- validate score_model_id
          IF p_score_model_id IS NOT NULL
          THEN
                BEGIN
                        SELECT 'X'
                        INTO   l_char
                        FROM ar_cmgt_scores
                        WHERE score_model_id = p_score_model_id
                        AND   submit_flag = 'Y'
                        AND   sysdate between start_date and
                                nvl(end_date,sysdate);
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            debug('AR_CMGT_SCORE_NAME_INVALID');
                            FND_MESSAGE.SET_NAME('AR','AR_CMGT_SCORE_NAME_INVALID');
                            FND_MSG_PUB.Add;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        WHEN OTHERS THEN
                            debug('AR_CMGT_SCORE_NAME_INVALID, SQLERRM :'||SQLERRM);
                            x_return_status := FND_API.G_RET_STS_ERROR;
                END;
          END IF;

       /*-----------------------------------------+
        |   CREATION                              |
        +-----------------------------------------*/
/* bug4414414 : Added columns parent_credit_request_id and credit_request_type
*/
      IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
         INSERT INTO AR_CMGT_CREDIT_REQUESTS
          (credit_request_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           application_number,
           application_date,
           requestor_type,
           requestor_id,
           review_type,
           review_cycle,
           credit_classification,
           check_list_id,
           credit_analyst_id,
           limit_amount,
           limit_currency,
           trx_amount,
           trx_currency,
           credit_check_rule_id,
           term_length,
           credit_type,
           party_id,
           cust_account_id,
           cust_acct_site_id,
           site_use_id,
           contact_party_id,
           case_folder_number,
           score_model_id,
           attachment_flag,
           status,
           source_name,
           source_user_id,
           source_resp_id,
           source_resp_appln_id,
           source_security_group_id,
           source_org_id,
           source_column1,
           source_column2,
           source_column3,
           notes,
           request_id,
           parent_credit_request_id,
           credit_request_type,
           RECOMMENDATION_NAME
          )
          VALUES
          (l_credit_request_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           l_application_number,
           l_application_date,
           l_requestor_type,
           l_requestor_id,
           p_review_type,
           p_review_cycle,
           p_credit_classification,
           null,
           null,
           p_requested_amount,
           p_requested_currency,
           p_trx_amount,
           p_trx_currency,
           p_credit_check_rule_id,
           p_term_length,
           p_credit_type,
           p_party_id,
           nvl(p_cust_account_id,-99),
           nvl(p_cust_acct_site_id,-99),
           nvl(p_site_use_id,-99),
           p_contact_party_id,
           p_case_folder_number,
           p_score_model_id,
           null,
           l_credit_request_status,
           p_source_name,
           p_source_user_id,
           p_source_resp_id,
           p_source_appln_id,
           p_source_security_group_id,
           p_source_org_id,
           p_source_column1,
           p_source_column2,
           p_source_column3,
           p_notes,
           fnd_global.conc_request_id,
           p_parent_credit_request_id,
           l_credit_request_type,
           p_reco
          );
        -- commit;
       /*-----------------------------------------+
        |   WORKFLOW CALL                         |
        +-----------------------------------------*/

        IF l_credit_request_status = 'SUBMIT'
         THEN
                IF pg_debug = 'Y'
                THEN
                        debug ( 'Workflow Call');
                        END IF;
           AR_CMGT_WF_ENGINE.START_WORKFLOW
                (l_credit_request_id ,l_credit_request_status);
        END IF;

        p_credit_request_id := l_credit_request_id;

       ELSE
        --error was raised during the validation
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count       =>      x_msg_count,
                                     p_data        =>      x_msg_data
                                         );
           return;

       END IF;
        IF pg_debug = 'Y'
        THEN
          debug ( 'AR_CMGT_CREDIT_REQUEST_API(-)');
        END IF;
 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO CREATE_CREDIT_REQ_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                --Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded      => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO CREATE_CREDIT_REQ_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               --  Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded      => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_UNEXPECTED_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
        WHEN OTHERS  THEN

                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','CREATE_CREDIT_REQUEST : '||SQLERRM);
                      FND_MSG_PUB.Add;


                ROLLBACK TO Create_credit_req_PVT;


             --   Display_Parameters;
                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_UNEXPECTED_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
END create_credit_request;

/* Overloaded create_credit_request to handle hold_reasons */
PROCEDURE create_credit_request
     ( p_api_version      		IN NUMBER,
       p_init_msg_list     		IN VARCHAR2 ,
       p_commit            		IN VARCHAR2,
       p_validation_level  		IN VARCHAR2,
       x_return_status     		OUT NOCOPY VARCHAR2,
       x_msg_count         		OUT NOCOPY NUMBER,
       x_msg_data          		OUT NOCOPY VARCHAR2,
       p_application_number  	IN VARCHAR2,
       p_application_date    	IN DATE,
       p_requestor_type      	IN VARCHAR2,
       p_requestor_id        	IN NUMBER, --this happens to be the HR person_id of
                                      --the requestor
       p_review_type           	IN VARCHAR2,
       p_credit_classification 	IN VARCHAR2,
       p_requested_amount     	IN NUMBER,
       p_requested_currency   	IN VARCHAR2,
       p_trx_amount           	IN NUMBER,
       p_trx_currency         	IN VARCHAR2,
       p_credit_type          	IN VARCHAR2,
       p_term_length          	IN NUMBER,  --the unit is no of months
       p_credit_check_rule_id 	IN NUMBER, --this is the credit check rule from the OM
       p_credit_request_status	IN VARCHAR2, --SAVE or FINISH
       p_party_id             	IN NUMBER,
       p_cust_account_id      	IN NUMBER,
       p_cust_acct_site_id    	IN NUMBER,
       p_site_use_id          	IN NUMBER,
       p_contact_party_id     	IN NUMBER, --this is the party_id of the pseudo party
                                       --created becoz of the contact relationship.
       p_notes                		IN VARCHAR2,
       p_source_org_id          	IN NUMBER,
       p_source_user_id         	IN NUMBER,
       p_source_resp_id         	IN NUMBER,
       p_source_appln_id        	IN NUMBER,
       p_source_security_group_id   IN NUMBER,
       p_source_name          		IN VARCHAR2,
       p_source_column1       		IN VARCHAR2,
       p_source_column2       		IN VARCHAR2,
       p_source_column3       		IN VARCHAR2,
       p_credit_request_id    		OUT NOCOPY NUMBER,
       p_review_cycle          		IN VARCHAR2 ,
       p_case_folder_number   		IN  VARCHAR2,
       p_score_model_id	      		IN  NUMBER,
       p_parent_credit_request_id IN NUMBER  DEFAULT NULL,
       p_credit_request_type    IN VARCHAR2 DEFAULT NULL,
       p_reco                   IN VARCHAR2 DEFAULT NULL,
       p_hold_reason_rec        IN hold_reason_rec_type
       ) IS

       l_hold_reason_rec	hold_reason_rec_type;
       l_credit_request_id	NUMBER;
BEGIN

        IF pg_debug = 'Y'
        THEN
          debug ( 'Overloaded AR_CMGT_CREDIT_REQUEST_API(+)');
        END IF;

    /* make normal API call */
    create_credit_request
     ( p_api_version,
       p_init_msg_list,
       p_commit,
       p_validation_level,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_application_number,
       p_application_date,
       p_requestor_type,
       p_requestor_id,
       p_review_type,
       p_credit_classification,
       p_requested_amount,
       p_requested_currency,
       p_trx_amount,
       p_trx_currency,
       p_credit_type,
       p_term_length,
       p_credit_check_rule_id,
       p_credit_request_status,
       p_party_id,
       p_cust_account_id,
       p_cust_acct_site_id,
       p_site_use_id,
       p_contact_party_id,
       p_notes,
       p_source_org_id,
       p_source_user_id,
       p_source_resp_id,
       p_source_appln_id,
       p_source_security_group_id,
       p_source_name,
       p_source_column1,
       p_source_column2,
       p_source_column3,
       p_credit_request_id,
       p_review_cycle,
       p_case_folder_number,
       p_score_model_id,
       p_parent_credit_request_id,
       p_credit_request_type,
       p_reco);

    /* 8869430 - Handle hold_reason_rec here */
    /* using p_hold_reason_rec and p_credit_request_id */
    l_hold_reason_rec := p_hold_reason_rec;
    l_credit_request_id := p_credit_request_id;

	IF pg_debug = 'Y' THEN
      debug ( 'Credit Request ID ' || l_credit_request_id );
    END IF;

    IF (l_hold_reason_rec.COUNT > 0) THEN
      FOR rec in l_hold_reason_rec.FIRST..l_hold_reason_rec.LAST
      LOOP
        INSERT INTO AR_CMGT_HOLD_DETAILS (HOLD_DETAIL_ID,
										  CREDIT_REQUEST_ID,
										  TYPE,
										  CODE,
										  CREATED_BY,
										  CREATION_DATE,
										  LAST_UPDATED_BY,
										  LAST_UPDATE_DATE,
										  LAST_UPDATE_LOGIN)
		VALUES (AR_CMGT_HOLD_DTL_S.NEXTVAL,
                l_credit_request_id,
                'REASON',
                l_hold_reason_rec(rec),
      			fnd_global.user_id,
				SYSDATE,
				fnd_global.user_id,
				SYSDATE,
				fnd_global.login_id);

      END LOOP;
    END IF;

        IF pg_debug = 'Y'
        THEN
          debug ( 'Overloaded AR_CMGT_CREDIT_REQUEST_API(-)');
        END IF;
 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := FND_API.G_RET_STS_ERROR ;

                --Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded      => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               --  Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded      => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_UNEXPECTED_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
        WHEN OTHERS  THEN

                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','CREATE_CREDIT_REQUEST : '||SQLERRM);
                      FND_MSG_PUB.Add;

             --   Display_Parameters;
                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );
                debug('FND_API.G_EXC_UNEXPECTED_ERROR, x_msg_data :'||x_msg_data|| ' SQLERRM :'||SQLERRM);
END create_credit_request;

FUNCTION is_Credit_Management_Installed
RETURN BOOLEAN
IS
CURSOR C1 IS
SELECT 'x'
FROM ar_cmgt_setup_options;
l_return BOOLEAN;
l_char   VARCHAR2(1);
BEGIN

 OPEN C1;

 FETCH C1 into l_char;

 IF C1%NOTFOUND  THEN
  l_return := FALSE;
 ELSE
  -- since row exists in setup options table, check in checklist table
  BEGIN
    SELECT 'x'
    INTO   l_char
    FROM   ar_cmgt_check_lists
    WHERE  submit_flag = 'Y';

    l_return := TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND then
        l_return := FALSE;
      WHEN TOO_MANY_ROWS then
        l_return := TRUE;
  END;

 END IF;

 CLOSE C1;

 return(l_return);

END;

FUNCTION get_application_number (
    p_credit_request_id     IN      NUMBER )
    RETURN VARCHAR2 IS

    CURSOR cApplicationNumber IS
        SELECT application_number
        FROM ar_cmgt_credit_requests
        WHERE credit_request_id = p_credit_request_id;

    l_application_number        VARCHAR2(30);
BEGIN
    OPEN cApplicationNumber;

    FETCH cApplicationNumber INTO l_application_number;

    IF cApplicationNumber%NOTFOUND
    THEN
        l_application_number := NULL;
    END IF;

    CLOSE cApplicationNumber;

    return(l_application_number);
END get_application_number;

END AR_CMGT_CREDIT_REQUEST_API;

/
