--------------------------------------------------------
--  DDL for Package Body AR_BPA_PARTY_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_PARTY_SEARCH" AS
/*$Header: ARBPDQMB.pls 120.6 2006/09/14 18:50:05 lishao noship $ */

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
 |      This is used from the bill presentment architecture search pages.
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
 | 11-Jan-2003           LISHAO            Created
 |
 *=======================================================================*/
Procedure DQM_SEARCH (p_keyword  IN varchar2,
                      p_search_context_id OUT NOCOPY NUMBER)
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
	l_rule_number VARCHAR2(30);
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

BEGIN
	-- 1. Setup the Search criteria
    party_cond.PARTY_ALL_NAMES := p_keyword;
	-- party_cond.party_name := p_keyword;
    -- party_cond.organization_name := p_keyword;

	-- Note that the party_site, contact and contact point
	-- search records are tables. So you can pass any
	-- number of addresses to search on.

	-- Note that Phone and Email address criteria need to
	-- be passed seperately.
	-- FND_PROFILE.get('HZ_SEARCH_RULE', l_rule_number);

   --IF l_rule_number IS NULL THEN
    --Bug 4528997: use "SAMPLE:BASIC SEARCH RULE" as the default rule.
    --FND_MESSAGE.SET_NAME( 'AR', 'AR_BPA_NO_MATCH_RULE' );
    --app_exception.raise_exception;
    l_rule_id := 33;
--	 ELSE
--   	l_rule_id := to_number(l_rule_number);
--   END IF;

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

	-- 3. Setup the SEARCH_RESULTS block to show the
	--    results. This block is based on the Global Temporary Table
        --    HZ_MATCHED_PARTIES_GT

        p_search_context_id := l_search_context_id;

END DQM_SEARCH;


END AR_BPA_PARTY_SEARCH;

/
