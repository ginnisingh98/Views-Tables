--------------------------------------------------------
--  DDL for Package Body CE_BANK_AND_ACCOUNT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_AND_ACCOUNT_UTIL" AS
/*$Header: cebautlb.pls 120.6.12010000.8 2010/04/22 08:48:59 talapati ship $ */

  /*=======================================================================+
   | PUBLIC FUNCTION get_masked_bank_acct_num                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a bank_account_id and returns the bank account  |
   |   number with the appropriate mask based on the value of the profile  |
   |   option 'CE: Mask Internal Bank Account Numbers'                     |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_acct_id                                                    |
   +=======================================================================*/

   FUNCTION get_masked_bank_acct_num(p_bank_acct_id    IN NUMBER)
   RETURN VARCHAR2
   IS
     l_bank_acct_num	VARCHAR2(100);
     l_profile_value    VARCHAR2(30);
     l_len		NUMBER;
     l_sub		VARCHAR2(15);
   BEGIN
     SELECT bank_account_num
     INTO   l_bank_acct_num
     FROM   ce_bank_accounts
     WHERE  bank_account_id = p_bank_acct_id;

     l_len := LENGTH(l_bank_acct_num);

     l_profile_value := NVL(FND_PROFILE.value
                     ('CE_MASK_INTERNAL_BANK_ACCT_NUM'), 'NO MASK');

     -- 6932525: For account numbers less than 4 digits, masking will not apply
     IF l_len < 4  THEN
        l_profile_value := 'NO MASK';
     END IF;


     IF l_profile_value = 'FIRST FOUR VISIBLE' THEN
       l_sub := SUBSTR(l_bank_acct_num, 1, 4);
       RETURN RPAD(l_sub, l_len, '*');
     ELSIF l_profile_value = 'LAST FOUR VISIBLE' THEN
       l_sub := SUBSTR(l_bank_acct_num, -4, 4);
       RETURN LPAD(l_sub, l_len, '*');
     ELSE
       RETURN l_bank_acct_num;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       sql_error('CE_BANK_AND_ACCOUNT_UTIL.get_masked_bank_acct_num', sqlcode, sqlerrm);
   END get_masked_bank_acct_num;

   /*=======================================================================+
   | PUBLIC FUNCTION get_masked_IBAN                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a bank_account_id and returns the IBAN          |
   |   number with the appropriate mask based on the value of the profile  |
   |   option 'CE: Mask Internal Bank Account Numbers'                     |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_acct_id                                                    |
   +=======================================================================*/

   FUNCTION get_masked_IBAN(p_bank_acct_id    IN NUMBER)
   RETURN VARCHAR2
   IS
     l_IBAN	VARCHAR2(30);
     l_profile_value    VARCHAR2(30);
     l_len		NUMBER;
     l_sub		VARCHAR2(5);
   BEGIN
     SELECT  IBAN_NUMBER
     INTO   l_IBAN
     FROM   ce_bank_accounts
     WHERE  bank_account_id = p_bank_acct_id;

     l_len := LENGTH(l_IBAN);

     l_profile_value := NVL(FND_PROFILE.value
                     ('CE_MASK_INTERNAL_BANK_ACCT_NUM'), 'NO MASK');

     -- For account numbers less than 4 digits, masking will not apply
     IF l_len < 4  THEN
        l_profile_value := 'NO MASK';
     END IF;


     IF l_profile_value = 'FIRST FOUR VISIBLE' THEN
       l_sub := SUBSTR(l_IBAN, 1, 4);
       RETURN RPAD(l_sub, l_len, '*');
     ELSIF l_profile_value = 'LAST FOUR VISIBLE' THEN
       l_sub := SUBSTR(l_IBAN, -4, 4);
       RETURN LPAD(l_sub, l_len, '*');
     ELSE
       RETURN l_IBAN;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       sql_error('CE_BANK_AND_ACCOUNT_UTIL.get_masked_IBAN', sqlcode, sqlerrm);
   END get_masked_IBAN;

  /*=======================================================================+
   | PUBLIC FUNCTION get_org_bank_acct_list                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a org_id and returns the list of bank accounts  |
   |   that this org has access                                            |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   | RETURN                                                                |
   |   '@' deliminated bank_account_id's                                   |
   +=======================================================================*/
   FUNCTION get_org_bank_acct_list(p_org_id     IN NUMBER)
   RETURN VARCHAR2
   IS
     TYPE BankAcctIdTable IS TABLE OF ce_bank_accounts.bank_account_id%TYPE;
     --l_bank_acct_list 	VARCHAR2(4000) DEFAULT '@';
     l_bank_acct_list 	VARCHAR2(4000);
     bank_acct_idtbl		BankAcctIdTable;
   BEGIN
     /* select bank_account_id's  */
     SELECT DISTINCT bank_account_id
     BULK COLLECT
     INTO bank_acct_idtbl
     FROM ce_bank_acct_uses_all
     WHERE org_id = p_org_id;

     --bug 3855002
     IF (l_bank_acct_list IS NULL)  THEN
       l_bank_acct_list := '@';
     END IF;

     /* Concatenate Ids  */
     IF bank_acct_idtbl.COUNT > 0 THEN
       FOR i IN bank_acct_idtbl.FIRST .. bank_acct_idtbl.LAST LOOP
         l_bank_acct_list := l_bank_acct_list || bank_acct_idtbl(i) || '@';
       END LOOP;
     ELSE
       l_bank_acct_list := '';
     END IF;
     RETURN l_bank_acct_list;

   EXCEPTION
     WHEN OTHERS THEN
       sql_error('CE_BANK_AND_ACCOUNT_UTIL.get_org_bank_acct_list', sqlcode, sqlerrm);
   END get_org_bank_acct_list;



  /*=======================================================================+
   | PUBLIC PRECEDURE sql_error                                            |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure sets the error message and raise an exception        |
   |   for unhandled sql errors.                                           |
   |   Called by other routines.                                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_routine                                                         |
   |     p_errcode                                                         |
   |     p_errmsg                                                          |
   +=======================================================================*/
   PROCEDURE sql_error(p_routine   IN VARCHAR2,
                       p_errcode   IN NUMBER,
                       p_errmsg    IN VARCHAR2) IS
   BEGIN
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ROUTINE', p_routine);
     fnd_message.set_token('ERRNO', p_errcode);
     fnd_message.set_token('REASON', p_errmsg);
     app_exception.raise_exception;
   EXCEPTION
     WHEN OTHERS THEN RAISE;
   END;


  /*=======================================================================+
   | PUBLIC PRECEDURE get_internal_bank_accts                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure returns the list of internal bank accounts given the |
   |   conditions of date, currency, and organization that uses this BA.   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency                                                        |
   |     p_org_type:  acceptable values are 'OPERATING_UNIT',              |
   |                                        'BUSINESS_GROUP',              |
   |                                      & 'LEGAL_ENTITY'                 |
   |     p_org_id                                                          |
   |     p_date                                                            |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_acct_ids  '@' deliminated bank_account_id's                |
   +=======================================================================*/
   PROCEDURE get_internal_bank_accts (p_currency      IN  VARCHAR2,
                                      p_org_type      IN  VARCHAR2,
                                      p_org_id        IN  NUMBER,
                                      p_date          IN  DATE,
                                      x_bank_acct_ids OUT NOCOPY BankAcctIdTable) IS
   BEGIN
     /* select bank_account_id's  */
     IF p_org_type = 'LEGAL_ENTITY' THEN
       SELECT BA.bank_account_id
       BULK COLLECT
       INTO x_bank_acct_ids
       FROM (	SELECT 	ce_ba.bank_account_id
		FROM 	ce_bank_accounts      ce_ba,
            		ce_bank_acct_uses_all ce_bau
       		WHERE 	ce_ba.bank_account_id = ce_bau.bank_account_id
       		AND   	NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
		AND   	(ce_ba.currency_code = p_currency
			or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       		AND   	ce_bau.legal_entity_id = p_org_id
		UNION
		SELECT	bank_account_id
		FROM 	ce_bank_accounts
		WHERE 	NVL(end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
		AND   	(currency_code = p_currency
			or MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       		AND   	account_owner_org_id = p_org_id) BA;
     ELSIF p_org_type in ('OPERATING_UNIT', 'BUSINESS_GROUP') THEN
       SELECT ce_ba.bank_account_id
       BULK COLLECT
       INTO x_bank_acct_ids
       FROM ce_bank_accounts      ce_ba,
  	    ce_bank_acct_uses_all ce_bau
       WHERE ce_ba.bank_account_id = ce_bau.bank_account_id
       AND   NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
       AND   (ce_ba.currency_code = p_currency
		or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       AND   ce_bau.org_id = p_org_id;
     ELSE
       FND_MESSAGE.Set_Name('CE', 'CE_INVALID_ORG_TYPE');
       APP_EXCEPTION.Raise_Exception;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       sql_error('CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts', sqlcode, sqlerrm);
   END get_internal_bank_accts;

  /*=======================================================================+
   | PUBLIC PRECEDURE get_internal_bank_accts  For bug 8277703             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure returns the list of internal bank accounts given the |
   |   conditions of date, currency, and organization that uses this BA.   |
   |									   |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency                                                        |
   |     p_org_id                                                          |
   |     p_date                                                            |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     p_internal_bank_account_id                                        |
   |     p_valid_flag                                                      |
   +=======================================================================*/
   PROCEDURE get_internal_bank_accts (p_currency      IN  VARCHAR2,
                                      p_org_type      IN  VARCHAR2,
                       		            p_org_id        IN  NUMBER,
                       		            p_date          IN  DATE,
				                              p_internal_bank_account_id IN OUT NOCOPY NUMBER,
                                      p_valid_flag OUT NOCOPY BOOLEAN)
   IS
       l_count NUMBER;
       l_bank_acct_ids BankAcctIdTable;
   BEGIN
      l_count := 0;
     /* select bank_account_id's  */
     IF (p_internal_bank_account_id IS NOT NULL) THEN
          IF p_org_type = 'LEGAL_ENTITY' THEN
            SELECT Count(BA.bank_account_id)
            INTO   l_count
            FROM (	SELECT 	ce_ba.bank_account_id
	                  FROM 	ce_bank_accounts      ce_ba,
            	      ce_bank_acct_uses_all ce_bau
       	            WHERE 	ce_ba.bank_account_id = ce_bau.bank_account_id
                    AND     ce_ba.bank_account_id = p_internal_bank_account_id
       	            AND   	NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
	                  AND   	(ce_ba.currency_code = p_currency
		                 or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       	            AND   	ce_bau.legal_entity_id = p_org_id
	                  UNION
	                  SELECT	bank_account_id
	                  FROM 	  ce_bank_accounts
	                  WHERE  bank_account_id = p_internal_bank_account_id
                    AND    NVL(end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
	                  AND   	(currency_code = p_currency
		                  or MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       	            AND   	account_owner_org_id = p_org_id
                  )BA;

          ELSIF p_org_type in ('OPERATING_UNIT', 'BUSINESS_GROUP') THEN
            SELECT Count(ce_ba.bank_account_id)
            INTO l_count
            FROM ce_bank_accounts      ce_ba,
  	        ce_bank_acct_uses_all ce_bau
            WHERE ce_ba.bank_account_id = ce_bau.bank_account_id
            AND   ce_ba.bank_account_id = p_internal_bank_account_id
            AND   NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
            AND   (ce_ba.currency_code = p_currency
	                 or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
            AND   ce_bau.org_id = p_org_id;
          ELSE
            FND_MESSAGE.Set_Name('CE', 'CE_INVALID_ORG_TYPE');
            APP_EXCEPTION.Raise_Exception;
          END IF;
          IF(l_count = 0) THEN
             p_valid_flag := FALSE;
          ELSE
             p_valid_flag := TRUE;
          END IF;
     ELSE
        IF p_org_type = 'LEGAL_ENTITY' THEN
            SELECT BA.bank_account_id
            BULK COLLECT
            INTO l_bank_acct_ids
            FROM (	SELECT 	ce_ba.bank_account_id
	           FROM 	ce_bank_accounts      ce_ba,
            	      ce_bank_acct_uses_all ce_bau
       	      WHERE 	ce_ba.bank_account_id = ce_bau.bank_account_id
       	      AND   	NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
	          AND   	(ce_ba.currency_code = p_currency
		          or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       	          AND   	ce_bau.legal_entity_id = p_org_id
	          UNION
	          SELECT	bank_account_id
	          FROM 	ce_bank_accounts
	          WHERE 	NVL(end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
	          AND   	(currency_code = p_currency
		          or MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
       	        AND   	account_owner_org_id = p_org_id) BA;

         ELSIF p_org_type in ('OPERATING_UNIT', 'BUSINESS_GROUP') THEN
            SELECT ce_ba.bank_account_id
            BULK COLLECT
            INTO l_bank_acct_ids
            FROM ce_bank_accounts      ce_ba,
  	        ce_bank_acct_uses_all ce_bau
            WHERE ce_ba.bank_account_id = ce_bau.bank_account_id
            AND   NVL(ce_ba.end_date, NVL(p_date, sysdate)) >= NVL(p_date, sysdate)
            AND   (ce_ba.currency_code = p_currency
	          or ce_ba.MULTI_CURRENCY_ALLOWED_FLAG = 'Y') --bug 4915527
            AND   ce_bau.org_id = p_org_id;
         ELSE
            FND_MESSAGE.Set_Name('CE', 'CE_INVALID_ORG_TYPE');
            APP_EXCEPTION.Raise_Exception;
         END IF;

         IF(l_bank_acct_ids.Count = 1)  THEN
            p_valid_flag := TRUE;
            p_internal_bank_account_id := l_bank_acct_ids(l_bank_acct_ids.FIRST);
         ELSE
            p_valid_flag := FALSE;
         END IF;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       sql_error('CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts', sqlcode, sqlerrm);
   END get_internal_bank_accts;

END CE_BANK_AND_ACCOUNT_UTIL;

/
