--------------------------------------------------------
--  DDL for Package Body ARI_SELF_REG_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_SELF_REG_CONFIG" AS
/* $Header: ARISRCGB.pls 120.7.12010000.7 2010/04/30 11:10:18 avepati ship $ */

/*========================================================================
 | PUBLIC PROCEDURE verify_customer_site_access
 |
 | DESCRIPTION
 |      This procedure can be customised to specify access verification questions
 |      when the user selects the location of the customer requesting access.
 |
 | PARAMETERS
 |      p_customer_id           IN VARCHAR2
 |      p_customer_site_use_id  IN VARCHAR2 DEFAULT NULL
 |      x_verify_access         OUT ARI_SELF_REGISTRATION_PKG.VerifyAccessTable
 |      x_attempts              OUT NUMBER
 |
 | NOTES
 |      Records in ARI_SELF_REGISTRATION_PKG.VerifyAccessTable contain the variables listed below:
 |          question        VARCHAR2(2000)
 |          expected_answer VARCHAR2(2000)
 |          currency_code   VARCHAR2(15)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-May-2005           vnb               Created
 | 22-Mar-2010           avepati           bug 7713325 - FLEXIBILITY TO DEFINE CHALLENGE QUESTION DURING SELF REGISTRION
 *=======================================================================*/
PROCEDURE  verify_customer_site_access( p_customer_id          IN VARCHAR2,
                                        p_customer_site_use_id IN VARCHAR2 DEFAULT NULL,
                                        x_verify_access        OUT NOCOPY ARI_SELF_REGISTRATION_PKG.VerifyAccessTable,
                                        x_attempts             OUT NOCOPY NUMBER)
IS
    l_trx_number    VARCHAR2(255);
    l_receipt_number    VARCHAR2(255);
    l_temp number;
    l_no_inv_flag boolean:=FALSE;
    cust_site_org_id	NUMBER ;
    l_answer varchar2(200);
     i       PLS_INTEGER := 1 ;

    CURSOR cust_site_cur IS
    	select organization_id org_id from hr_operating_units where mo_global.check_access(organization_id) = 'Y';

    cust_site_rec		cust_site_cur%ROWTYPE;
BEGIN

      arp_standard.debug(' customer site use id :: '||p_customer_site_use_id);
      arp_standard.debug(' customer Id :: '||p_customer_id);
    /*
        Customize this portion to specify the parameters for different
        customers/customer sites
    */
        --At present, the registration process works with 3 attempts.
        --This hook is for future enhancements
    x_attempts := 0;

    cust_site_org_id := NULL ;
    if(p_customer_site_use_id is not null) then
    	SELECT org_id INTO cust_site_org_id
    	FROM hz_cust_site_uses
    	WHERE site_use_id = p_customer_site_use_id ;
    else
      --check if rule exist for the default org id.
	if(mo_utils.get_default_org_id is NOT NULL and FUN_RULE_OBJECTS_PUB.rule_object_instance_exists(222,'ARI_VALIDATE_SITE_ACCESS', NULL,mo_utils.get_default_org_id)) then
	  cust_site_org_id := mo_utils.get_default_org_id;
	else
	  --if rule does not exist for the cust_site_org or default org, then search thru all org setup at the security profile
	  FOR cust_site_rec IN cust_site_cur LOOP
		if(FUN_RULE_OBJECTS_PUB.rule_object_instance_exists(222,'ARI_VALIDATE_SITE_ACCESS', NULL,cust_site_rec.org_id)) then
		--site access question is set at the org id in secuirty profile, then set that org as cust_site_org_id
			cust_site_org_id :=  cust_site_rec.org_id;
			EXIT;
		end if;
	  END LOOP;
	end if;
    end if;

    IF(FUN_RULE_OBJECTS_PUB.rule_object_instance_exists(222,'ARI_VALIDATE_SITE_ACCESS', NULL,cust_site_org_id)) THEN

    FUN_RULE_PUB.SET_INSTANCE_CONTEXT('ARI_VALIDATE_SITE_ACCESS', 'AR', NULL, cust_site_org_id );
    FUN_RULE_PUB.init_parameter_list;
    FUN_RULE_PUB.add_parameter('ARI_CUSTOMER_ID', p_customer_id);
    FUN_RULE_PUB.add_parameter('ARI_CUSTOMER_SITE_USE_ID', p_customer_site_use_id);
    FUN_RULE_PUB.apply_rule('AR','ARI_VALIDATE_SITE_ACCESS');

-- begin added for bug 7713325

    IF (FUN_RULE_PUB.get_attribute15 is not null) THEN

arp_standard.debug(' question1 - attribute15 :: '||FUN_RULE_PUB.get_attribute15||' answer table1 - attribute14  :: '||FUN_RULE_PUB.get_attribute14||' answer column1 - attribute13 :: '||FUN_RULE_PUB.get_attribute13);
arp_standard.debug('answer join column1 - attribute12 :: '||FUN_RULE_PUB.get_attribute12||' hz party sites join column1 - attribute11 :: '||FUN_RULE_PUB.get_attribute11);

             l_answer := validate_access(p_customer_id,p_customer_site_use_id,FUN_RULE_PUB.get_attribute14,FUN_RULE_PUB.get_attribute13,FUN_RULE_PUB.get_attribute12,FUN_RULE_PUB.get_attribute11);

            arp_standard.debug('l_answer :: '||l_answer);

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute15;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);

            i := i+1;

      END IF;

            IF (FUN_RULE_PUB.get_attribute10 is not null and FUN_RULE_PUB.get_attribute6 is not null) THEN -- to confirm that 2nd custom question is defined

arp_standard.debug('question2 - attribute10 :: '||FUN_RULE_PUB.get_attribute10||' answer table2 - attribute9 :: '||FUN_RULE_PUB.get_attribute9||' answer column2 - attribute8 :: '||FUN_RULE_PUB.get_attribute8);
arp_standard.debug(' answer join column2  - attribute7 ::  '||FUN_RULE_PUB.get_attribute7||'  hz join column2 - attribute6 :: '||FUN_RULE_PUB.get_attribute6);

            l_answer := validate_access(p_customer_id,p_customer_site_use_id,FUN_RULE_PUB.get_attribute9,FUN_RULE_PUB.get_attribute8,FUN_RULE_PUB.get_attribute7,FUN_RULE_PUB.get_attribute6);

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute10;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);

            i := i+1;

          END IF; --IF (FUN_RULE_PUB.get_attribute6 is not null) THEN

          IF (FUN_RULE_PUB.get_attribute5 is not null and FUN_RULE_PUB.get_attribute1 is not null) THEN   -- to confirm that 3 rd custom question is defined

arp_standard.debug('question3 - attribute5 :: '||FUN_RULE_PUB.get_attribute5||' answer table3 - attribute4 :: '||FUN_RULE_PUB.get_attribute4||' answer column3 - attribute3 :: '||FUN_RULE_PUB.get_attribute3);
arp_standard.debug(' answer join column3 - attribute2 ::  '||FUN_RULE_PUB.get_attribute2||'  hz join column3 - attribute1 :: '||FUN_RULE_PUB.get_attribute1);
            l_answer := validate_access(p_customer_id,p_customer_site_use_id,FUN_RULE_PUB.get_attribute4,FUN_RULE_PUB.get_attribute3,FUN_RULE_PUB.get_attribute2,FUN_RULE_PUB.get_attribute1);

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute5;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);

            i := i+1;

          END IF; --IF (FUN_RULE_PUB.get_attribute11 is not null) THEN

  -- end for bug 7713325

    IF (FUN_RULE_PUB.get_attribute1 is not null and FUN_RULE_PUB.get_attribute5 is null) THEN
        x_verify_access(i).question := FUN_RULE_PUB.get_attribute1;
        x_verify_access(i).expected_answer := FUN_RULE_PUB.get_attribute2;
        i := i+1;
        return;
    END IF;

    IF( FUN_RULE_PUB.get_attribute3 = 'Y' OR
           FUN_RULE_PUB.get_attribute5 = 'Y') THEN
        BEGIN
                --Select an open invoice
                SELECT trx_number
                INTO l_trx_number
                FROM ar_payment_schedules
                WHERE customer_id = p_customer_id
                AND customer_site_use_id = nvl(p_customer_site_use_id,customer_site_use_id)
                AND status like 'OP'
                AND amount_due_remaining > 0
                AND rownum = 1;

                --Use the existing message as below, or define a new message
                --and set that as the question
                FND_MESSAGE.SET_NAME('AR', 'ARI_REG_VERIFY_QUESTION');
                FND_MESSAGE.SET_TOKEN('INVOICE', l_trx_number);
                --Set this as first question
                x_verify_access(i).question := FND_MESSAGE.get;
                BEGIN
                    --Set the expected answer
                    SELECT to_char(amount_due_remaining)
                    INTO x_verify_access(i).expected_answer
                    FROM ar_payment_schedules
                    WHERE customer_id = p_customer_id
                    AND customer_site_use_id = nvl(p_customer_site_use_id,customer_site_use_id)
                    AND status like 'OP'
                    AND amount_due_remaining > 0
                    AND rownum = 1;
                END;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_no_inv_flag:=TRUE;
        END;
         i := i+1;
    END IF;
         --Questions can be defined on payment too
         IF ( FUN_RULE_PUB.get_attribute4 = 'Y' OR
              FUN_RULE_PUB.get_attribute5 = 'Y' ) THEN
            BEGIN
            --Select a receipt  at this customer site
              SELECT receipt_number
              INTO l_receipt_number
              FROM ar_cash_receipts
              WHERE PAY_FROM_CUSTOMER = p_customer_id
              AND customer_site_use_id = nvl(p_customer_site_use_id,customer_site_use_id)
              AND rownum = 1;
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    RETURN;
            END;
            --Set this as another question in the 'x_verify_access' var
            FND_MESSAGE.SET_NAME('AR', 'ARI_REG_VERIFY_ADDL_QUESTION');
            FND_MESSAGE.SET_TOKEN('RECEIPT', l_receipt_number);
            IF ( l_no_inv_flag OR
              (FUN_RULE_PUB.get_attribute3 is null AND FUN_RULE_PUB.get_attribute5 is null) ) THEN
                x_verify_access(i).question := FND_MESSAGE.get;
            ELSE
              x_verify_access(i).question := FND_MESSAGE.get;
            END IF;


            BEGIN
                --Set the expected answer
                        SELECT amount
                        INTO l_temp
                        FROM ar_cash_receipts
                        WHERE PAY_FROM_CUSTOMER = p_customer_id
                        AND customer_site_use_id = nvl(p_customer_site_use_id,customer_site_use_id)
                        AND rownum = 1;

                IF ( l_no_inv_flag OR
                  (FUN_RULE_PUB.get_attribute3 is null AND FUN_RULE_PUB.get_attribute5 is null)) THEN
                    x_verify_access(i).expected_answer := l_temp;
                ELSE
                  x_verify_access(i).expected_answer := l_temp;
                END IF;
            END;

          END IF;
           i := i+1;
   END IF;


END verify_customer_site_access;



/*========================================================================
 | PUBLIC PROCEDURE validate_cust_detail_access
 |
 | DESCRIPTION
 |      This procedure can be customised to specify access verification questions
 |      when the user selects the customer requesting access.
 |
 | PARAMETERS
 |      p_customer_id           IN VARCHAR2
 |      x_verify_access         OUT ARI_SELF_REGISTRATION_PKG.VerifyAccessTable
 |      x_attempts              OUT NUMBER
 |
 | NOTES
 |      Records in ARI_SELF_REGISTRATION_PKG.VerifyAccessTable contain the variables listed below:
 |          question        VARCHAR2(2000)
 |          expected_answer VARCHAR2(2000)
 |          currency_code   VARCHAR2(15)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-May-2005           vnb               Created
 | 19-Mar-2010           avepati           bug 7713325 - FLEXIBILITY TO DEFINE CHALLENGE QUESTION DURING SELF REGISTRION
 *=======================================================================*/
PROCEDURE  validate_cust_detail_access( p_customer_id          IN VARCHAR2,
                                        x_verify_access        OUT NOCOPY ARI_SELF_REGISTRATION_PKG.VerifyAccessTable,
                                        x_attempts             OUT NOCOPY NUMBER)
IS
    l_customer_name     hz_parties.party_name%type;
    l_answer varchar2(200);
    i       PLS_INTEGER := 1 ;

BEGIN

    /*
        Customize this portion to specify the parameters for different
        customers
    */
        arp_standard.debug('Begin procedure validate_cust_detail_access ');
        FUN_RULE_PUB.init_parameter_list;
        FUN_RULE_PUB.add_parameter('ARI_CUSTOMER_ID', to_char(p_customer_id));
        FUN_RULE_PUB.apply_rule('AR','ARI_VALIDATE_CUST_ACCESS');

        BEGIN

        IF (FUN_RULE_PUB.get_attribute1 is not null) THEN
          IF (FUN_RULE_PUB.get_attribute5 is not null) THEN   -- to confirm that 1 st custom question is defined

arp_standard.debug(' question1 - attribute1 :: '||FUN_RULE_PUB.get_attribute1||' answer table1 - attribute2 '||FUN_RULE_PUB.get_attribute2||' answer column1 - attribute3 '||FUN_RULE_PUB.get_attribute3);
arp_standard.debug(' answer join column1 - attribute4  '||FUN_RULE_PUB.get_attribute4||' hz join column1 - attribute5 '||FUN_RULE_PUB.get_attribute5);

               l_answer := validate_access(p_customer_id,'CUST_LEVEL',FUN_RULE_PUB.get_attribute2,FUN_RULE_PUB.get_attribute3,FUN_RULE_PUB.get_attribute4,FUN_RULE_PUB.get_attribute5);
               arp_standard.debug('l_answer :: '||l_answer);

          elsif (FUN_RULE_PUB.get_attribute2 is not null) then -- IF (FUN_RULE_PUB.get_attribute5 is not null) THEN
            l_answer := FUN_RULE_PUB.get_attribute2;
            arp_standard.debug('l_answer for static question '||l_answer);
          END IF; --IF (FUN_RULE_PUB.get_attribute5 is not null) THEN

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute1;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);
            i := i+1;

           END IF; --IF (FUN_RULE_PUB.get_attribute1 is not null) THEN

            IF (FUN_RULE_PUB.get_attribute6 is not null and FUN_RULE_PUB.get_attribute10 is not null) THEN -- to confirm that 2nd custom question is defined

arp_standard.debug('question2 - attribute6 :: '||FUN_RULE_PUB.get_attribute6||' answer table2 - attribute7 '||FUN_RULE_PUB.get_attribute7||' answer column2 - attribute8 '||FUN_RULE_PUB.get_attribute8);
arp_standard.debug('answer join column2 - attribute9  '||FUN_RULE_PUB.get_attribute9||'  hz join column2 - attribute10 '||FUN_RULE_PUB.get_attribute10);

            l_answer := validate_access(p_customer_id,'CUST_LEVEL',FUN_RULE_PUB.get_attribute7,FUN_RULE_PUB.get_attribute8,FUN_RULE_PUB.get_attribute9,FUN_RULE_PUB.get_attribute10);

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute6;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);

            i := i+1;

          END IF; --IF (FUN_RULE_PUB.get_attribute6 is not null) THEN


          IF (FUN_RULE_PUB.get_attribute11 is not null and FUN_RULE_PUB.get_attribute15 is not null) THEN   -- to confirm that 3 rd custom question is defined

arp_standard.debug('question3 - attribute11 :: '||FUN_RULE_PUB.get_attribute11||' answer table3 - attribute12 '||FUN_RULE_PUB.get_attribute12||' answer column3 - attribute13 '||FUN_RULE_PUB.get_attribute13);
arp_standard.debug(' answer join column3 - attribute14  '||FUN_RULE_PUB.get_attribute14||'  hz join column3 - attribute15 '||FUN_RULE_PUB.get_attribute15);

            l_answer := validate_access(p_customer_id,'CUST_LEVEL',FUN_RULE_PUB.get_attribute12,FUN_RULE_PUB.get_attribute13,FUN_RULE_PUB.get_attribute14,FUN_RULE_PUB.get_attribute15);

            x_verify_access(i).question := FUN_RULE_PUB.get_attribute11;
            x_verify_access(i).expected_answer := l_answer;

            arp_standard.debug('Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);

            i := i+1;

          END IF; --IF (FUN_RULE_PUB.get_attribute11 is not null) THEN

          EXCEPTION
              WHEN OTHERS THEN
              arp_standard.debug('In Exception.. Expected Answer.. '||x_verify_access(i).expected_answer||'..Question'||x_verify_access(i).question);
              arp_standard.debug('ERROR => :: '||SQLERRM);
              l_answer := NULL;
         END;

END validate_cust_detail_access;


/*========================================================================
 | PUBLIC FUNCTION get_customer_id
 |
 | DESCRIPTION
 |      This function returns the customer id of the customer that the user requests access to.
 |      This can be customised to return the customer id in case of custom search queries.
 |
 | PARAMETERS
 |      p_search_type           IN VARCHAR2
 |      p_search_number         IN VARCHAR2
 |
 | NOTES
 |      This hook is kept as customisable for future enhancements
 |      in the direction of writing custom customer search for the registration process.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-May-2005           vnb               Created
 |
 *=======================================================================*/
FUNCTION  get_customer_id ( p_search_type VARCHAR2,
                            p_search_number  VARCHAR2) RETURN NUMBER
IS
    l_customer_id   NUMBER;
BEGIN

    --If user searches by customer, get customer id from hz_cust_accounts
    IF p_search_type = 'CUSTOMER_NUMBER' THEN
        SELECT cust_account_id
        INTO l_customer_id
        FROM hz_cust_accounts
        where account_number = p_search_number;

    --If user searches by transactions, get customer id from ar_payment_schedules
    ELSIF p_search_type = 'INVOICES' OR
          p_search_type = 'PAYMENTS' OR
          p_search_type = 'DEBIT_MEMOS' OR
          p_search_type = 'CREDIT_MEMOS' OR
          p_search_type = 'DEPOSITS' THEN

        BEGIN
/* Fix for bug# 5153874.
 * A customer can have same invoice no for more than invoices depending on
 * the source. So added 'distinct' in the below query to select unique customer_id.
 */
            SELECT DISTINCT customer_id
            INTO l_customer_id
            FROM ar_payment_schedules
            WHERE trx_number = p_search_number
            AND class = (CASE p_search_type
                            WHEN 'INVOICES' THEN 'INV'
            	            WHEN 'PAYMENTS' THEN 'PMT'
                            WHEN 'DEBIT_MEMOS' THEN 'DM'
                            WHEN 'CREDIT_MEMOS' THEN 'CM'
                            WHEN 'DEPOSITS' THEN 'DEP'
                	END);

        EXCEPTION
        	WHEN TOO_MANY_ROWS THEN
              	RETURN -1;
        END;

    END IF;

    RETURN l_customer_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -2;
END get_customer_id;

/*========================================================================
 | PUBLIC FUNCTION auto_generate_passwd_option
 |
 | DESCRIPTION
 |      This function can be customised to specify if the password is to automatically generated
 |      at customer/site level.
 |
 | PARAMETERS
 |      p_customer_id           IN VARCHAR2
 |      p_customer_site_use_id  IN VARCHAR2
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-May-2005           vnb               Created
 |
 *=======================================================================*/
FUNCTION auto_generate_passwd_option (  p_customer_id           IN  VARCHAR2,
                                        p_customer_site_use_id  IN  VARCHAR2)
                                 RETURN VARCHAR2
IS
BEGIN
    /*IF p_customer_id = 1006 THEN
        RETURN 'Y';
    END IF;*/
    RETURN 'N';
END auto_generate_passwd_option;

/*========================================================================
 | PUBLIC FUNCTION validate_access
 |
 | DESCRIPTION
 |      This function returns the self registration custom question answere
 |      defined at customer/site level.
 |
 | PARAMETERS
 |      p_customer_id           IN VARCHAR2
 |      p_customer_site_use_id  IN VARCHAR2
 |      p_answer_table          IN VARCHAR2
 |      p_answer_column         IN VARCHAR2
 |      p_answer_join_column    IN VARCHAR2
 |      p_hz_join_column        IN VARCHAR2
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Mar-2010           avepati               Created
  *=======================================================================*/
FUNCTION validate_access (   p_customer_id            IN VARCHAR2,
                             p_customer_site_use_id   IN VARCHAR2,
                             p_answer_table           IN VARCHAR2,
                             p_answer_column          IN VARCHAR2,
                             p_answer_join_column     IN VARCHAR2,
                             p_hz_join_column         IN VARCHAR2 )  RETURN VARCHAR2 IS

       l_answer          varchar2(200);
       l_query_string    varchar2(2000);
       l_site_use_id  number(15);
       TYPE l_ref_cur_type IS REF CURSOR;
       l_ref_cur l_ref_cur_type;
BEGIN


            if ( p_customer_id is not null and p_customer_site_use_id ='CUST_LEVEL') then

                  l_query_string := 'SELECT anstable.'||p_answer_column|| ' from '|| p_answer_table||' anstable, hz_cust_accounts hca WHERE rownum = 1 and hca.'||p_hz_join_column||' = anstable.'||p_answer_join_column||
                                  ' and hca.cust_account_id = '||p_customer_id;
            elsif ( p_customer_site_use_id is not null ) then

 l_query_string :=  'SELECT anstable.'||p_answer_column|| ' from '|| p_answer_table||' anstable,hz_party_sites hps, hz_cust_acct_sites_all hcas, hz_cust_site_uses_all hcsu where hcsu.site_use_id =' || p_customer_site_use_id ||
                                  ' and hcsu.cust_acct_site_id = hcas.cust_acct_site_id and hcas.party_site_id = hps.party_site_id and hps.'||p_hz_join_column||' = anstable.'||p_answer_join_column;

            else

              mo_global.init('AR');
              mo_global.set_policy_context('M',null);
              arp_standard.debug('apps context initialized');

              SELECT site_use_id into l_site_use_id FROM
                        ( SELECT 	site_uses.site_use_id   FROM
                                  fnd_territories_vl     Terr,
                                  hz_cust_acct_sites     acct_sites,
                                  hz_party_sites         party_sites,
                                  hz_locations           loc,
                                  hz_cust_accounts       Cust,
                                  hz_parties             Party,
                                  hz_cust_site_uses	 site_uses
                                WHERE Party.party_id = Cust.party_id
                                  AND Cust.account_number =  p_customer_id
                                  AND Cust.cust_account_id = acct_sites.cust_account_id
                                  AND ACCT_SITES.party_site_id     = PARTY_SITES.party_site_id
                                  AND PARTY_SITES.location_id      = LOC.location_id
                                  AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id
                                  AND site_uses.site_use_code = 'BILL_TO'
                                  AND loc.country         = Terr.territory_code(+)
                                  order by site_uses.creation_date asc ) dummy
                                  where rownum=1;

                arp_standard.debug('oldest bill to site id  ::  '||l_site_use_id);

  l_query_string :='SELECT anstable.'||p_answer_column|| ' from '|| p_answer_table||' anstable,hz_party_sites hps, hz_cust_acct_sites_all hcas, hz_cust_site_uses_all hcsu where hcsu.site_use_id =' || l_site_use_id ||
                                  ' and hcsu.cust_acct_site_id = hcas.cust_acct_site_id and hcas.party_site_id = hps.party_site_id and hps.'||p_hz_join_column||' = anstable.'||p_answer_join_column;

            end if;

              arp_standard.debug('l_query_string ::  '||l_query_string);

              open l_ref_cur for l_query_string;
              fetch l_ref_cur into l_answer;
              close l_ref_cur;

              arp_standard.debug('l_answer ::'||l_answer);

             RETURN l_answer;

              EXCEPTION
              WHEN OTHERS THEN
              arp_standard.debug('Exception  in validate_access');
              arp_standard.debug('ERROR => :: '||SQLERRM);
              l_answer := NULL;
              return l_answer;

END validate_access;


END ari_self_reg_config;

/
