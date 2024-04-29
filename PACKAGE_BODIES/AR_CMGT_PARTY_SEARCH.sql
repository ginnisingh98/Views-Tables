--------------------------------------------------------
--  DDL for Package Body AR_CMGT_PARTY_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_PARTY_SEARCH" AS
/*$Header: ARDQMSRB.pls 120.5.12010000.2 2010/03/02 15:27:17 mraymond ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/


/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE DQM_SEARCH
 |
 | DESCRIPTION
 |      This procedure provides the cover routine for the call to the
 |      DQM search engine.
 |      This is used from the credit management search pages.
 |
 | PARAMETERS
 |      p_keyword             IN      The keyword on which search is to
 |                                    be performed.
 |      p_search_context_id   OUT NOCOPY     The unique id returned by DQM
 |
 | KNOWN ISSUES
 |      Enter business functionality which was de-scoped as part of the
 |      implementation. Ideally this should never be used.
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-AUG-2002           APANDIT            Created
 | 17-MAR-2006           KJOSHI             Made changes for modified DQM search
 *=======================================================================*/
Procedure DQM_SEARCH (p_keyword  IN varchar2,
                      p_dqm_param     IN VARCHAR2,
                      p_search_context_id OUT NOCOPY NUMBER,
		      p_return_status	  OUT NOCOPY VARCHAR2,
		      p_msg_count	  OUT NOCOPY NUMBER,
		      p_msg_data	  OUT NOCOPY VARCHAR2)
is
        -- Pass Party search criteria in this variable
	party_cond HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
    l_count   NUMBER;

	-- Pass Party Site search criteria in this variable
	party_site_cond HZ_PARTY_SEARCH.PARTY_SITE_LIST;

	-- Pass Contact search criteria in this variable
	contact_cond HZ_PARTY_SEARCH.CONTACT_LIST;

	-- Pass Contact Point search criteria in this variable
	contact_point_cond HZ_PARTY_SEARCH.CONTACT_POINT_LIST;

	-- The Match Rule to use for the search
	-- this should be set to the ID of the match rule you
	-- created for your application
	l_rule_id NUMBER;

	-- The Search Context ID returned by the API.
	-- This is used to query the results table for
        -- the matched records.
	l_search_context_id NUMBER;

	-- Other OUT NOCOPY parameters returned by the API.
	l_return_status VARCHAR2(1);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);

        -- API also returns the number of matches.
	l_num_matches NUMBER;

        --The partySearchResults cursor
        CURSOR partySearchResults (p_context_id IN NUMBER) is
        SELECT hzp.party_name, hzp.party_number,ca.account_number,
               ARH_ADDR_PKG.FORMAT_ADDRESS(LOC.ADDRESS_STYLE,LOC.ADDRESS1,
                    LOC.ADDRESS2,LOC.ADDRESS3,LOC.ADDRESS4,LOC.CITY,LOC.COUNTY,
                    LOC.STATE,LOC.PROVINCE,LOC.POSTAL_CODE,
                    TERR.TERRITORY_SHORT_NAME ) CONCATENATED_ADDRESS
               , score
        FROM HZ_MATCHED_PARTIES_GT GT,
             HZ_PARTIES HZP,
             HZ_CUST_ACCOUNTS CA,
             HZ_CUST_ACCT_SITES CAS,
             HZ_LOCATIONS LOC,
             HZ_PARTY_SITES PARTY_SITE,
             FND_TERRITORIES_VL TERR
        WHERE SEARCH_CONTEXT_ID = p_context_id
          AND GT.PARTY_ID = HZP.PARTY_ID
          AND GT.PARTY_ID = CA.PARTY_ID(+)
          AND CAS.CUST_ACCOUNT_ID(+) = CA.CUST_ACCOUNT_ID
          AND CAS.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID(+)
          AND LOC.LOCATION_ID(+) = PARTY_SITE.LOCATION_ID
          AND LOC.COUNTRY   = TERR.TERRITORY_CODE(+);

	  CURSOR get_matching_rule IS
          SELECT match_rule_id
	  FROM hz_match_rules_vl
	  where RULE_NAME ='HZ_ORG_SIMPLE_SEARCH_RULE';
          --from ar_cmgt_setup_options;

BEGIN
	-- 1. Setup the Search criteria
	if p_dqm_param = 'PARTY_NUM'
	THEN
           party_cond.party_number := substr(p_keyword,0,30);
        ELSIF p_dqm_param = 'PARTY_NAME'
	THEN
           party_cond.PARTY_ALL_NAMES := p_keyword;
	END IF;

	-- Note that Phone and Email address criteria need to
	-- be passed seperately.

	contact_point_cond(1).CONTACT_POINT_TYPE := 'PHONE';
	--contact_point_cond(1).FLEX_FORMAT_PHONE_NUMBER := p_keyword;

	contact_point_cond(2).CONTACT_POINT_TYPE := 'EMAIL';
	--contact_point_cond(2).EMAIL_ADDRESS := p_keyword;


	OPEN get_matching_rule;
        FETCH get_matching_rule INTO l_rule_id;
        CLOSE get_matching_rule;


       IF l_rule_id IS NULL THEN
        --raise error;
        FND_MESSAGE.SET_NAME( 'AR', 'AR_CMGT_NO_MATCH_RULE' );
        app_exception.raise_exception;

       END IF;

	HZ_PARTY_SEARCH.find_parties (p_init_msg_list    =>'T',
                                      x_rule_id          => l_rule_id,
                                      p_party_search_rec => party_cond,
                                      p_party_site_list  => party_site_cond,
                                      p_contact_list     => contact_cond ,
                                      p_contact_point_list => contact_point_cond,
                                      p_restrict_sql     => null,
                                      p_search_merged    => null,
                                      x_search_ctx_id    => l_search_context_id,
                                      x_num_matches      => l_num_matches,
                                      x_return_status    => l_return_status,
                                      x_msg_count        => l_msg_count,
                                      x_msg_data         => l_msg_data);

	arp_standard.debug('l_search_context_id: '||l_search_context_id);
	arp_standard.debug('l_return_status: '||l_return_status);
	arp_standard.debug('l_msg_count: '||l_msg_count);
	arp_standard.debug('l_msg_data: '||l_msg_data);
	-- 3. Setup the SEARCH_RESULTS block to show the
	--    results. This block is based on the Global Temporary Table
        --    HZ_MATCHED_PARTIES_GT

        p_search_context_id := l_search_context_id;
	p_return_status  := l_return_status;
	p_msg_count	 := l_msg_count;
	p_msg_data	 := l_msg_data;

END DQM_SEARCH;


END AR_CMGT_PARTY_SEARCH;

/
