--------------------------------------------------------
--  DDL for Package Body AR_CMGT_REVIEW_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_REVIEW_CONC" AS
/* $Header: ARCMPRCB.pls 120.6.12010000.2 2009/06/17 23:33:41 rravikir ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.AR_CMGT_REVIEW_CONC' );
END;

PROCEDURE populate_temp_table (
        p_party_id              IN      NUMBER,
        p_cust_account_id       IN      NUMBER,
        p_site_use_id           IN      NUMBER,
        p_check_list_id         IN      NUMBER,
        p_review_cycle          IN      VARCHAR2,
        p_next_review_date      IN      DATE,
        p_last_review_date      IN      DATE,
        p_review_type           IN      VARCHAR2,
        p_credit_classification IN      VARCHAR2,
        p_currency_code         IN      VARCHAR2 ) IS

-- This procedure will populate global temporary table which will
-- be used by Eligibility Reports
BEGIN

    IF pg_debug = 'Y' THEN
     debug ('AR_CMGT_REVIEW_CONC.populate_temp_table(+)' );
    END IF;

    INSERT INTO OCM_CREDIT_REVIEW_GT (
        party_id,
        cust_account_id,
        site_use_id,
        check_list_id,
        review_cycle,
        next_credit_review_date,
        last_credit_review_date,
        review_type,
        credit_classification,
        currency_code )
    VALUES
        (p_party_id,
         p_cust_account_id,
         p_site_use_id,
         p_check_list_id,
         p_review_cycle,
         p_next_review_date,
         p_last_review_date,
         p_review_type,
         p_credit_classification,
         p_currency_code);
    IF pg_debug = 'Y' THEN
        debug ('AR_CMGT_REVIEW_CONC.populate_temp_table(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
END;
/*========================================================================
 | PRIVATE PROCEDURE submit_preview_report
 |
 | DESCRIPTION
 |      This procedure submits the periodic cycle review report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      ar_cmgt_review_conc.submit_preview_report()
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_currency_code     IN Currency code
 |
 | RETURNS    :  NONE
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This concurrent request for periodic cycle review report submitted
 |     before the periodic review records are processed.
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-OCT-02             S.Nambiar         Created
 |
+===========================================================================*/


PROCEDURE submit_preview_report(
        p_party_id   	                 IN NUMBER,
        p_cust_account_id                IN NUMBER,
        p_currency_code                  IN VARCHAR2,
	    p_credit_classification          IN VARCHAR2,
	    p_profile_class_id   	         IN VARCHAR2,
	    p_check_list_id                  IN NUMBER,
	    p_review_cycle                   IN VARCHAR2,
        p_check_list_match_rule          IN VARCHAR2,
        p_review_cycle_as_of_date        IN VARCHAR2,
        p_cust_level                     IN VARCHAR2
	) IS

m_request_id      NUMBER;
l_request_id      NUMBER;
l_options_ok      BOOLEAN;

BEGIN
      /* IF PG_DEBUG in ('Y', 'C') THEN
         --arp_util.debug('ar_cmgt_review_conc.submit_preview_report (+)');
      END IF; */

      l_request_id := fnd_global.conc_request_id;

      l_options_ok := FND_REQUEST.SET_OPTIONS (
                      implicit      => 'NO'
                    , protected     => 'YES'
                    , language      => ''
                    , territory     => '');
      IF (l_options_ok)
      THEN

       m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                 application   => 'AR'
                , program       => 'ARCMPRPT'
                , description   => ''
                , start_time    => ''
                , sub_request   => FALSE
                , argument1     => p_review_cycle
                , argument2     => fnd_date.date_to_canonical(p_review_cycle_as_of_date)
                , argument3     => p_currency_code
                , argument4     => p_cust_level
                , argument5     => fnd_number.number_to_canonical(p_check_list_id)
                , argument6     => p_check_list_match_rule
                , argument7     => fnd_number.number_to_canonical(p_party_id)
                , argument8     => p_cust_account_id
                , argument9     =>  p_credit_classification
                , argument10     => fnd_number.number_to_canonical(p_profile_class_id)
                , argument11    => chr(0)
                , argument12    => ''
                , argument13    => ''
                , argument14    => ''
                , argument15    => ''
                , argument16    => ''
                , argument17    => ''
                , argument18    => ''
                , argument19    => ''
                , argument20    => ''
                , argument21    => ''
                , argument22    => ''
                , argument23    => ''
                , argument24    => ''
                , argument25    => ''
                , argument26    => ''
                , argument27    => ''
                , argument28    => ''
                , argument29    => ''
                , argument30    => ''
                , argument31    => ''
                , argument32    => ''
                , argument33    => ''
                , argument34    => ''
                , argument35    => ''
                , argument36    => ''
                , argument37    => ''
                , argument38    => ''
                , argument39    => ''
                , argument40    => ''
                , argument41    => ''
                , argument42    => ''
                , argument43    => ''
                , argument44    => ''
                , argument45    => ''
                , argument46    => ''
                , argument47    => ''
                , argument48    => ''
                , argument49    => ''
                , argument50    => ''
                , argument51    => ''
                , argument52    => ''
                , argument53    => ''
                , argument54    => ''
                , argument55    => ''
                , argument56    => ''
                , argument57    => ''
                , argument58    => ''
                , argument59    => ''
                , argument60    => ''
                , argument61    => ''
                , argument62    => ''
                , argument63    => ''
                , argument64    => ''
                , argument65    => ''
                , argument66    => ''
                , argument67    => ''
                , argument68    => ''
                , argument69    => ''
                , argument70    => ''
                , argument71    => ''
                , argument72    => ''
                , argument73    => ''
                , argument74    => ''
                , argument75    => ''
                , argument76    => ''
                , argument77    => ''
                , argument78    => ''
                , argument79    => ''
                , argument80    => ''
                , argument81    => ''
                , argument82    => ''
                , argument83    => ''
                , argument84    => ''
                , argument85    => ''
                , argument86    => ''
                , argument87    => ''
                , argument88    => ''
                , argument89    => ''
                , argument90    => ''
                , argument91    => ''
                , argument92    => ''
                , argument93    => ''
                , argument94    => ''
                , argument95    => ''
                , argument96    => ''
                , argument97    => ''
                , argument98    => ''
                , argument99    => ''
                , argument100   => '');

    END IF;
      /*IF PG_DEBUG in ('Y', 'C') THEN
         --arp_util.debug('ar_cmgt_review_conc.submit_preview_report (+)');
      END IF; */

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         raise;
         --arp_util.debug('EXCEPTION :ar_cmgt_review_conc.submit_preview_report '||SQLERRM);
      END IF;
END submit_preview_report;


--------------------------------------------------------------------------------------------------------------------
--K.Joshi (IDC)   Periodic Credit Review Enhancement - Bug 3824304
-- Added the following new parameters:
-- 1) review_cycle_as_of_date
-- 2) cust_level
-- 3) account_number
-- Removed the following new parameters
-- 1) review_match_rule
-- 2) Party Number
--Changes Start-----------------------------------------------------------------------------------------------------


PROCEDURE periodic_review(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_review_cycle                   IN VARCHAR2,
       p_review_cycle_as_of_date        IN VARCHAR2,
       p_currency_code                  hz_cust_profile_amts.currency_code%type,
       p_cust_level                     IN VARCHAR2,
       p_check_list_id                  IN VARCHAR2,
       p_party_id   	                IN NUMBER,
       p_cust_account_id   	            IN NUMBER,
       p_credit_classification          IN VARCHAR2,
       p_profile_class_id   	        IN VARCHAR2,
       p_processing_option   	        IN VARCHAR2 )
       IS
--Changes End-----------------------------------------------------------------------------------------------------


--Declare Local variables
  l_review_cycle                VARCHAR2(30);
  l_review_match_rule           VARCHAR2(30);
  l_check_list_id               ar_cmgt_check_lists.check_list_id%TYPE;
  l_match_prev_cf_checklist     VARCHAR2(80);
  l_profile_class_id            NUMBER(15);
  l_credit_classification   	VARCHAR2(30);
  l_processing_option           VARCHAR2(30);
  l_credit_request_id           NUMBER;
  l_request_id                  NUMBER;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_index                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_party_id                    hz_parties.party_id%TYPE;
  l_found_flag                  VARCHAR2(1) := 'N';
  l_create_request_flag         VARCHAR2(1) := 'N';
  l_case_folder_count           NUMBER;
  l_review_type                 VARCHAR2(30);
  l_currency_code               hz_cust_profile_amts.currency_code%type;
 l_review_cycle_as_of_date       hz_customer_profiles.LAST_CREDIT_REVIEW_DATE %type;
 l_next_review_date              hz_customer_profiles.NEXT_CREDIT_REVIEW_DATE%type;
 l_cust_level                    VARCHAR2(30);
 l_cust_account_id   	         VARCHAR2(360);
 l_last_review_date_for_curr	 ar_cmgt_credit_requests.application_date%type;
 l_results						 VARCHAR2(1);
 l_exist_trx_currency            ar_cmgt_credit_requests.trx_currency%type;

Type review_row IS RECORD
  (
    party_id                  hz_parties.party_id%type,
    cust_account_id           hz_customer_profiles.cust_account_id%type,
    site_use_id               hz_customer_profiles.site_use_id%type,
    review_cycle              hz_customer_profiles.review_cycle%type,
    next_review_date          hz_customer_profiles.NEXT_CREDIT_REVIEW_DATE%type ,
    last_review_date          hz_customer_profiles.LAST_CREDIT_REVIEW_DATE %type,
    review_type               ar_cmgt_check_lists.review_type%type,
    credit_classification     ar_cmgt_check_lists.credit_classification%type,
    profile_id                hz_customer_profiles.CUST_ACCOUNT_PROFILE_ID%type,
    cp_credit_classification  ar_cmgt_check_lists.credit_classification%type
  );

--Changes End------------------------------------------------------------------------------------------------------


  Type cur_typ is REF CURSOR;
  review_cur                    cur_typ;
  review_rec                    review_row;
  review_cur_str                VARCHAR2(12000);

  review_cur_str1               VARCHAR2(4000);
  review_cur_str2               VARCHAR2(4000);
  review_cur_str3               VARCHAR2(4000);
  review_cur_str4               VARCHAR2(4000);




BEGIN
  IF pg_debug = 'Y' THEN
     debug ('AR_CMGT_REVIEW_CONC.periodic_review(+)' );
     debug (' Review Cycle ' || p_review_cycle );
     debug (' Review Cycle As of date ' || p_review_cycle_as_of_date  );
     debug (' Currency Code ' || p_currency_code  );
     debug (' Cust Level ' || p_cust_level   );
     debug (' Check List Id  ' || p_check_list_id    );
     debug (' Party Id  ' || p_party_id    );
     debug (' Cust Account Id  ' || p_cust_account_id    );
     debug (' Credit Classification  ' || p_credit_classification    );
     debug (' Profile Class Id  ' || p_profile_class_id     );
  END IF;

  l_cust_level := p_cust_level;

  IF ( l_cust_level = 'PARTY' ) THEN
        review_cur_str1 := 'SELECT party.party_id party_id,
                       -99  cust_account_id ,
                       -99  site_use_id ,
                       hcp.review_cycle review_cycle,
		                   hcp.NEXT_CREDIT_REVIEW_DATE next_review_date,
                       NVL(hcp.LAST_CREDIT_REVIEW_DATE, party.creation_date) last_review_date,
                       checklist.review_type review_type,
                       checklist.credit_classification credit_classification,
                       hcp.CUST_ACCOUNT_PROFILE_ID profile_id,
                       hcp.credit_classification cp_credit_classification
                       FROM   hz_customer_profiles hcp,
                              ar_cmgt_check_lists checklist,
                              hz_parties party
                      WHERE  hcp.party_id = NVL(:bnd_party_id ,hcp.party_id)
                      AND :bnd_cust_account_id IS NULL
                      AND hcp.cust_account_id = -1
                      AND hcp.site_use_id IS NULL
                      AND party.party_id = hcp.party_id
                      AND party.status = '||''''||'A'||''''||'
                      AND party.party_type = '||''''||'ORGANIZATION'||''''||'
		              AND nvl(hcp.credit_classification, -99) = NVL(:bnd_credit_classification,
                                         nvl(hcp.credit_classification,-99))
                      AND nvl(hcp.profile_class_id,-99) = NVL(:bnd_profile_class_id,nvl(hcp.profile_class_id,-99))
                      AND checklist.check_list_id = :bnd_check_list_id
                      AND nvl(hcp.review_cycle,-99) = NVL(:bnd_review_cycle,nvl(hcp.review_cycle,-99))
                      AND hcp.status ='||'''A''';
  END IF;
  IF ( l_cust_level = 'ACCT' ) THEN
      review_cur_str2 := 'SELECT party.party_id party_id,
                       hcp.cust_account_id cust_account_id,
                       -99 site_use_id,
                       hcp.review_cycle review_cycle,
                       hcp.NEXT_CREDIT_REVIEW_DATE next_review_date,
                       NVL(hcp.LAST_CREDIT_REVIEW_DATE, cust.creation_date) last_review_date,
                       checklist.review_type review_type,
                       checklist.credit_classification credit_classification,
                       hcp.CUST_ACCOUNT_PROFILE_ID profile_id,
                       hcp.credit_classification cp_credit_classification
                  FROM hz_parties party,
                       hz_customer_profiles hcp,
                       ar_cmgt_check_lists checklist,
                       hz_cust_accounts cust
                 WHERE hcp.party_id = NVL(:bnd_party_id ,hcp.party_id)
                       AND party.party_id = hcp.party_id
                       AND hcp.CUST_ACCOUNT_ID = NVL(:bnd_cust_account_id ,hcp.CUST_ACCOUNT_ID)
                       AND hcp.cust_account_id <> -1
                       and hcp.cust_account_id = cust.cust_account_id
                       and cust.status = '||''''||'A'||''''||'
                       AND hcp.site_use_id IS NULL
                       AND party.party_type = '||''''||'ORGANIZATION'||''''||'
                       AND nvl(hcp.credit_classification, -99) = NVL(:bnd_credit_classification,
                                         nvl(hcp.credit_classification,-99))
                       AND nvl(hcp.profile_class_id,-99) = NVL(:bnd_profile_class_id,nvl(hcp.profile_class_id,-99))
                       AND checklist.check_list_id = :bnd_check_list_id
                       AND nvl(hcp.review_cycle,-99) = NVL(:bnd_review_cycle,nvl(hcp.review_cycle,-99))
                       AND hcp.status ='||'''A''';
 END IF;
 IF (l_cust_level = 'SITE' ) THEN
       review_cur_str3 := 'SELECT party.party_id party_id,
                           hcp.cust_account_id cust_account_id,
                           hcp.site_use_id site_use_id,
                           hcp.review_cycle review_cycle,
                           hcp.NEXT_CREDIT_REVIEW_DATE next_review_date,
                           NVL(hcp.LAST_CREDIT_REVIEW_DATE, uses.creation_date) last_review_date,
                           checklist.review_type review_type,
                           checklist.credit_classification credit_classification,
                           hcp.CUST_ACCOUNT_PROFILE_ID profile_id,
                           hcp.credit_classification cp_credit_classification
                      FROM  hz_parties party,
                            HZ_CUST_SITE_USES_ALL uses ,
                            hz_customer_profiles hcp,
                            ar_cmgt_check_lists checklist
                     WHERE  hcp.party_id = NVL(:bnd_party_id,hcp.party_id)
                       AND hcp.CUST_ACCOUNT_ID = NVL(:bnd_cust_account_id ,hcp.CUST_ACCOUNT_ID)
                       AND party.party_id = hcp.party_id
                       AND hcp.cust_account_id <> -1
                       AND hcp.site_use_id IS NOT NULL
                       AND  hcp.SITE_USE_ID  = uses.SITE_USE_ID
                       AND  uses.site_use_code = '||''''||'BILL_TO'||''''||'
                       and  uses.status = '||''''||'A'||''''||'
                       AND  party.party_type = '||''''||'ORGANIZATION'||''''||'
                       AND nvl(hcp.credit_classification, -99) = NVL(:bnd_credit_classification,
                                         nvl(hcp.credit_classification,-99))
			           AND nvl(hcp.profile_class_id,-99) = NVL(:bnd_profile_class_id,nvl(hcp.profile_class_id,-99))
                       AND checklist.check_list_id = :bnd_check_list_id
                       AND nvl(hcp.review_cycle,-99) = NVL(:bnd_review_cycle,nvl(hcp.review_cycle,-99))
                       AND hcp.status ='||'''A''';
    END IF;
    IF (l_cust_level = 'ALL') THEN
     review_cur_str4 := 'SELECT hcp.party_id party_id,
                      DECODE(hcp.cust_account_id,-1,-99,hcp.cust_account_id) cust_account_id,
                      NVL(hcp.site_use_id,-99) site_use_id,
                      hcp.review_cycle review_cycle,
                      hcp.NEXT_CREDIT_REVIEW_DATE next_review_date,
                      NVL(NVL(hcp.LAST_CREDIT_REVIEW_DATE, uses.creation_date), party.creation_date) last_review_date,
                      checklist.review_type,
                      checklist.credit_classification,
                      hcp.CUST_ACCOUNT_PROFILE_ID profile_id,
                      hcp.credit_classification cp_credit_classification
                     FROM   hz_customer_profiles hcp,
                            ar_cmgt_check_lists checklist,
                            hz_parties party,
                            HZ_CUST_SITE_USES_ALL uses
                     WHERE  party.party_id = hcp.party_id
                     AND    :bnd_party_id IS NULL
                     AND    :bnd_cust_account_id IS NULL
                     AND    party.party_type = '||''''||'ORGANIZATION'||''''||'
                     AND nvl(hcp.credit_classification, -99) = NVL(:bnd_credit_classification,
                                         nvl(hcp.credit_classification,-99))
                     AND    hcp.profile_class_id = NVL(:bnd_profile_class_id,hcp.profile_class_id)
                     AND    checklist.check_list_id = :bnd_check_list_id
                     AND nvl(hcp.review_cycle,-99) = NVL(:bnd_review_cycle,nvl(hcp.review_cycle,-99))
                     AND    hcp.site_use_id = uses.site_use_id(+)
                     and    uses.site_use_code(+) = '||''''||'BILL_TO'||''''||'
                     AND    hcp.status ='||'''A''';

    END IF;


    IF (l_cust_level = 'PARTY') THEN
       review_cur_str := review_cur_str1;
    END IF;

    IF (l_cust_level = 'ACCT') THEN
       review_cur_str := review_cur_str2;
    END IF;

    IF (l_cust_level = 'SITE') THEN
       review_cur_str := review_cur_str3;
    END IF;

    IF (l_cust_level = 'ALL') THEN
       review_cur_str := review_cur_str4;

    END IF;


     l_review_cycle          := p_review_cycle          ;
     l_check_list_id         := FND_NUMBER.CANONICAL_TO_NUMBER(p_check_list_id) ;
     l_party_id              := p_party_id         ;
     l_profile_class_id      := FND_NUMBER.CANONICAL_TO_NUMBER(p_profile_class_id);
     l_credit_classification := p_credit_classification ;
     l_processing_option     := p_processing_option;
     l_request_id            := fnd_global.conc_request_id;
     l_review_cycle_as_of_date :=
            trunc(nvl(fnd_date.canonical_to_date(p_review_cycle_as_of_date), sysdate)) ;
     l_cust_level            := p_cust_level;
     l_cust_account_id        := p_cust_account_id;
     l_currency_code         := p_currency_code;

     l_return_status :=  FND_API.G_RET_STS_SUCCESS;


      IF  (l_party_id IS NULL)
      AND (l_cust_account_id IS NOT NULL) THEN
        SELECT party_id
          INTO l_party_id
          FROM HZ_CUST_ACCOUNTS
          WHERE CUST_ACCOUNT_ID = l_cust_account_id;
      END IF;

     IF NVL(l_processing_option,'NONE') in ('PROCESS_REVIEWS','BOTH', 'REPORT_ONLY')
      THEN
        IF(l_cust_level = 'SITE' OR  l_cust_level = 'ACCT' OR l_cust_level = 'PARTY'
            OR l_cust_level = 'ALL' )
        THEN
             OPEN review_cur FOR review_cur_str USING
                                l_party_id,
                                l_cust_account_id,
                                l_credit_classification,
                                l_profile_class_id,
                                l_check_list_id,
                                l_review_cycle;
        END IF;
     LOOP
     FETCH review_cur INTO review_rec;
      EXIT WHEN review_cur%NOTFOUND;
        IF pg_debug = 'Y' THEN
                debug ('Inside Loop'  );
                debug ('Party Id ' || review_rec.party_id );
                debug ('Cust Account Id ' || review_rec.cust_account_id  );
                debug ('Site Use Id ' || review_rec.site_use_id  );
        END IF;
     l_found_flag := 'N';
     l_create_request_flag := 'N';

     -- Now check additional Conditions
     IF review_rec.review_cycle IS NOT NULL
	 THEN
	 	IF review_rec.review_cycle = 'YEARLY' THEN
	       l_next_review_date := trunc(review_rec.last_review_date) + 365;
	       l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 365;
	    ELSIF review_rec.review_cycle = 'HALF_YEARLY' THEN
	      l_next_review_date := trunc(review_rec.last_review_date) + 180;
	      l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 180;
	    ELSIF review_rec.review_cycle = 'QUARTERLY' THEN
	      l_next_review_date := trunc(review_rec.last_review_date) + 90;
	      l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 90;
	    ELSIF review_rec.review_cycle = 'MONTHLY' THEN
	      l_next_review_date := trunc(review_rec.last_review_date) + 30;
	      l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 30;
	    ELSIF review_rec.review_cycle = 'WEEKLY' THEN
	      l_next_review_date := trunc(review_rec.last_review_date) + 7;
	      l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 7;
        ELSE
	      l_next_review_date := trunc(review_rec.last_review_date) + 1;
	      l_last_review_date_for_curr := trunc(l_review_cycle_as_of_date) - 1;
       END IF;
	 END IF;
     IF review_rec.next_review_date IS NOT NULL AND
        review_rec.next_review_date <=  l_review_cycle_as_of_date
     THEN
         IF pg_debug = 'Y' THEN
            debug ('Ist Condition True' );
         END IF;
         l_create_request_flag := 'Y';
     END IF;

     IF review_rec.next_review_date IS NULL AND
        review_rec.last_review_date IS NOT NULL AND
        review_rec.review_cycle IS NOT NULL
     THEN
        IF pg_debug = 'Y' THEN
            debug ('2nd Condition True' );
        END IF;
       IF   l_next_review_date  <= l_review_cycle_as_of_date
       THEN
            IF pg_debug = 'Y' THEN
                debug ('2nd Condition True with create_request_flag = Y' );
            END IF;
            l_create_request_flag := 'Y';
       END IF;
     END IF;

     IF review_rec.next_review_date IS NULL AND
        review_rec.last_review_date IS NULL AND
        review_rec.review_cycle IS NOT NULL
     THEN
         IF pg_debug = 'Y' THEN
                debug ('3rd Condition True' );
         END IF;
         l_create_request_flag := 'Y';
     END IF;

     --arp_util.debug('create request flag :'||l_create_request_flag);

     -- Now check if there
     IF NVL(l_create_request_flag,'N') = 'N'
     THEN
     	IF review_rec.review_cycle IS NOT NULL
     	THEN
     	  BEGIN
     		SELECT trx_currency
     		INTO l_exist_trx_currency
     		FROM  ar_cmgt_credit_requests
     		WHERE  party_id = review_rec.party_id
     		AND    cust_account_id = review_rec.cust_account_id
     		AND    site_use_id     = review_rec.site_use_id
     		AND    source_name     = 'AR_PERIODIC_REVIEW'
     		-- AND    trx_currency    = l_currency_code -- Bug 5149880
			AND    trunc(application_date) between l_last_review_date_for_curr
							and  l_review_cycle_as_of_date;

            -- bug 5159880
            IF l_exist_trx_currency = l_currency_code
            THEN
                    IF pg_debug = 'Y' THEN
                        debug ('Currency Matches' );
                    END IF;
                    l_create_request_flag :='N';
            ELSE
                    IF pg_debug = 'Y' THEN
                        debug ('Currency Does not Match' );
                    END IF;
                    l_create_request_flag :='Y';
            END IF;
			-- end 5149880

		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
                -- bug 5149880
                -- Checking this cindition to make sure it didn't pick
                -- unwanted records for which next review details are
                -- in future as entered in UI. If any of the values are not null
                -- then the condition would have executed  earlier.

                IF ( review_rec.next_review_date IS NOT NULL OR
                     review_rec.last_review_date IS NOT NULL OR
                     review_rec.review_cycle IS NOT NULL)
                THEN
                     IF pg_debug = 'Y' THEN
                        debug ('No Period Review Exists and No request will be created' );
                     END IF;
                     l_create_request_flag :='N';
                ELSE
                     IF pg_debug = 'Y' THEN
                        debug ('No Period Review Exists and request will be created' );
                     END IF;
                     l_create_request_flag :='Y';
                END IF;
			WHEN OTHERS THEN
				l_create_request_flag :='N';
     	  END;
     	END IF;
     END IF;

     IF NVL(l_create_request_flag,'N') = 'Y'
     THEN
        IF NVL(l_processing_option,'NONE') in ('PROCESS_REVIEWS','BOTH')
        THEN
           IF pg_debug = 'Y' THEN
                debug ('Inside Creating Request' );
                debug ('Employee Id ' || FND_GLOBAL.employee_id);
                debug ('Review Type ' || review_rec.review_type);
                debug ('Classification ' || review_rec.credit_classification);
           END IF;
           AR_CMGT_CREDIT_REQUEST_API.create_credit_request
             (p_api_version                => 1.0,
              p_init_msg_list              => FND_API.G_TRUE,
              p_commit                     => FND_API.G_FALSE,
              p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
              x_return_status              => l_return_status,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data,
              p_application_number         => NULL,
              p_application_date           => trunc(sysdate),
              p_requestor_type             => 'EMPLOYEE',
              p_requestor_id               => FND_GLOBAL.employee_id,
              p_review_type                => review_rec.review_type,
              p_review_cycle               => review_rec.review_cycle,
              p_credit_classification      => review_rec.credit_classification,
              p_requested_amount           => NULL,
              p_requested_currency         => l_currency_code,
              p_trx_amount                 => NULL,
              p_trx_currency               => l_currency_code,
              p_credit_type                => 'TRADE',
              p_term_length                => NULL,
              p_credit_check_rule_id       => NULL,
              p_credit_request_status      => 'SUBMIT',
              p_party_id                   => review_rec.party_id,
              p_cust_account_id            => review_rec.cust_account_id,
              p_cust_acct_site_id          => NULL,
              p_site_use_id                => review_rec.site_use_id,
              p_contact_party_id           => NULL,
              p_notes                      => NULL,
              p_source_org_id              => NULL,
              p_source_user_id             => NULL,
              p_source_resp_id             => NULL,
              p_source_appln_id            => NULL,
              p_source_security_group_id   => NULL,
              p_source_name                => 'AR_PERIODIC_REVIEW',
              p_source_column1             => NULL,
              p_source_column2             => NULL,
              p_source_column3             => NULL,
              p_credit_request_id          => l_credit_request_id
             );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                EXIT;
           END IF;
           IF pg_debug = 'Y' THEN
                debug ('Credit Request Created'  );
           END IF;
        END IF;
        IF NVL(l_processing_option,'NONE') in ('BOTH', 'REPORT_ONLY' )
        THEN
            IF pg_debug = 'Y' THEN
                debug ('Populate Global Temp Table'  );
            END IF;
            -- calculate the next review date for report purpose
            IF review_rec.review_cycle = 'YEARLY' THEN
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 365;
	        ELSIF review_rec.review_cycle = 'HALF_YEARLY' THEN
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 180;
	        ELSIF review_rec.review_cycle = 'QUARTERLY' THEN
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 90;
	        ELSIF review_rec.review_cycle = 'MONTHLY' THEN
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 30;
	        ELSIF review_rec.review_cycle = 'WEEKLY' THEN
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 7;
            ELSE
	           l_next_review_date := trunc(l_review_cycle_as_of_date) + 1;
            END IF;
            populate_temp_table (
                p_party_id              => review_rec.party_id,
                p_cust_account_id       => review_rec.cust_account_id,
                p_site_use_id           => review_rec.site_use_id,
                p_check_list_id        => l_check_list_id,
                p_review_cycle          => review_rec.review_cycle,
                p_next_review_date      => l_next_review_date,
                p_last_review_date      => review_rec.last_review_date,
                p_review_type           => review_rec.review_type,
                p_credit_classification => review_rec.cp_credit_classification,
                p_currency_code         => l_currency_code );
        END IF; -- if p_from_report
     END IF; -- if p_create_request_flag = 'Y'


     IF NVL(l_processing_option,'NONE') in ('PROCESS_REVIEWS','BOTH')
     THEN
       IF l_create_request_flag = 'Y'
       THEN
        BEGIN
           IF pg_debug = 'Y' THEN
                debug ('Updating HZ table'  );
           END IF;
	       UPDATE HZ_CUSTOMER_PROFILES
           SET    NEXT_CREDIT_REVIEW_DATE =
                    DECODE(review_cycle,
                     'YEARLY',       (trunc(sysdate) +  365),
                     'HALF_YEARLY',  (trunc(sysdate) + 180),
                     'QUARTERLY',    (trunc(sysdate) + 90),
                     'MONTHLY',      (trunc(sysdate) + 30),
                     'WEEKLY',       (trunc(sysdate) + 7),
                                     (trunc(sysdate) + 1)),
                  LAST_CREDIT_REVIEW_DATE = trunc(SYSDATE),
                  LAST_UPDATED_BY = fnd_global.user_id,
                  LAST_UPDATE_DATE = sysdate,
                  last_update_login = fnd_global.login_id
                 WHERE HZ_CUSTOMER_PROFILES.CUST_ACCOUNT_PROFILE_ID = review_rec.profile_id;
            END;
       END IF;
    END IF;
   END LOOP;
   END IF; --If review only, or both

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF NVL(l_msg_count,0)  > 0 Then
       IF l_msg_count > 1 Then
           FOR l_count IN 1..l_msg_count LOOP
               l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                             FND_API.G_FALSE);
               --arp_util.debug(to_char(l_count)||' : '||l_msg_data);
           END LOOP;
       END IF; -- l_msg_count
     END IF; -- NVL(l_msg_count,0)

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        FND_MSG_PUB.Get (FND_MSG_PUB.G_FIRST, FND_API.G_TRUE,l_msg_data, l_msg_index);
        FND_MESSAGE.Set_Encoded (l_msg_data);
        app_exception.raise_exception;
     END IF;
   END IF;
   IF pg_debug = 'Y' THEN
     debug ('AR_CMGT_REVIEW_CONC.periodic_review(-)' );
  END IF;
END;

END AR_CMGT_REVIEW_CONC;

/
