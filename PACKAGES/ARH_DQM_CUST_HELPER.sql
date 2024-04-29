--------------------------------------------------------
--  DDL for Package ARH_DQM_CUST_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_DQM_CUST_HELPER" AUTHID CURRENT_USER AS
/*$Header: ARHDQMAS.pls 115.1 2002/03/28 11:26:15 pkm ship   $*/

FUNCTION Is_cust_role_rel_dqm_pty
( p_ctx_id               IN NUMBER,
  p_cust_account_role_id IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_cust_acct_in_pty_gt
------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCOUNT_ID is already in HZ_MATCHED_PARTIES_GT
-- Otherwise N
------------------------------------------------------------------------
( p_ctx_id               IN NUMBER,
  p_cust_account_id      IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION is_cust_role_in_ct_gt
---------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCOUNR_ROLE_ID is already inserted in HZ_MATCHED_CONTACTS_GT
-- Otherwise N
---------------------------------------------------------------------------------------
( p_ctx_id               IN NUMBER,
  p_cust_account_role_id IN NUMBER,
  p_cust_account_id      IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION Is_acct_site_in_ps_gt
---------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCT_SITE_ID is already inserted in HZ_MATCHED_PARTY_SITES_GT
-- Otherwise N
---------------------------------------------------------------------------------------
( p_ctx_id            IN NUMBER,
  p_cust_acct_site_id IN NUMBER,
  p_cust_account_id   IN NUMBER,
  p_cur_all           IN VARCHAR2,
  p_status            IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_as_rel_dqm_pty
--------------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCT_SITE_D is associated with a party_id in HZ_MATCHED_PARTIES_GT
-- Otherwise N
--------------------------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_account_id    IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION score_of_rel_ps
-------------------------------------------------------------------------------------------------------
-- Return the score of the party_site related to a cust_acct_site in HZ_MATCHED_PARTY_SITES_GT if found
-- Otherwise -99999
-------------------------------------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2)
RETURN NUMBER;

PROCEDURE ins_as_in_ps_gt
-------------------------------------------------------------------------
-- Insert in CUST_ACCT_SITE_ID in HZ_MATCHED_PARTY_SITES_GT
-- If 1) the cust_acct_site_id is related to a matched party
--    2) the cust_acct_site_id is not yet in HZ_MATCHED_PARTY_SITES_GT
-------------------------------------------------------------------------
--  CUST_ACCOUNT_ID  CUST_ACCT_SITE_ID   -PSscore(-1)   SEARCH_CONTEXT_ID
-------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_account_id    IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2);

PROCEDURE ins_ca_car_in_gt
-------------------------------------------------------------------
-- Treatement for HZ_CUST_ACCOUNT_ROLES
-------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_org_contact_id  IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2);

FUNCTION score_rel_party
( p_ctx_id           IN NUMBER,
  p_cust_account_id  IN NUMBER,
  p_status           IN VARCHAR2)
RETURN NUMBER;

PROCEDURE find_as_rel_ps
-----------------------------------------------------------------------------------------------
-- INSERT all the CUST_ACCT_SITE_ID related to the P_PARTY_SITE_ID in HZ_MATCHED_PARTY_SITES_GT
--        If necesary insert also the CUST_ACCOUNT_ID related in  HZ_MATCHED_PARTIES_GT
-----------------------------------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_party_site_id   IN NUMBER,
  p_score           IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2);

FUNCTION is_as_rel_ps_in_ps_gt
------------------------------------------------------------------------------------------------------
-- Return Y if the CUST_ACCT_SITE_ID related to the P_PARTY_SITE_ID exist in HZ_MATCHED_PARTY_SITES_GT
------------------------------------------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_party_site_id   IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE as_ps_treatment
------------------------------------------------------------------------
-- Cust Account Site / Party Site treatment in HZ_MATCHED_PARTY_SITES_GT
------------------------------------------------------------------------
( p_ctx_id      IN NUMBER  ,
  p_cur_all     IN VARCHAR2,
  p_status      IN VARCHAR2 );

PROCEDURE ac_pty_treatment
-------------------------------------------------------
-- Account / Party Treatement in HZ_MATCHED_PARTIES_GT
-------------------------------------------------------
( p_ctx_id     IN NUMBER,
  p_cur_all    IN VARCHAR2,
  p_status     IN VARCHAR2);

PROCEDURE find_all_account_for_party
-------------------------------------------------------------------------
-- INSERT all_cust_account related to P_PARTY_ID in HZ_MATCHED_PARTIES_GT
-------------------------------------------------------------------------
( p_ctx_id    IN NUMBER,
  p_party_id  IN NUMBER,
  p_score     IN NUMBER,
  p_cur_all   IN VARCHAR2,
  p_status    IN VARCHAR2);

PROCEDURE car_oc_treatment
---------------------------------------------------------------
-- Treatment for CUST_ACCOUNT_ROLE_ID in HZ_MATCHED_CONTACTS_GT
-- Affect HZ_MATCHED_PARTY_SITES_GT and HZ_MATCHED_PARTIES_GT
---------------------------------------------------------------
( p_ctx_id       IN   NUMBER,
  p_cur_all      IN   VARCHAR2,
  p_status       IN   VARCHAR2);

FUNCTION is_ac_rel_pty_in_p_gt
------------------------------------------------------------------------------------------------
-- RETURN Y if the P_PARTY_ID has at leat one CUST_ACCT_ID related to it in HZ_MATCHED_PARIES_GT
-- Otherwise N
------------------------------------------------------------------------------------------------
( p_ctx_id     IN NUMBER,
  p_party_id   IN NUMBER,
  p_status     IN VARCHAR2)
RETURN VARCHAR2;

END;

 

/
