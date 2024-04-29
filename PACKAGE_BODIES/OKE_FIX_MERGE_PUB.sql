--------------------------------------------------------
--  DDL for Package Body OKE_FIX_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FIX_MERGE_PUB" AS
/*$Header: OKEPMRGB.pls 120.1 2006/01/30 10:46:22 ausmani noship $ */


  FUNCTION merge_cust_acct
    (merge_from_acct VARCHAR2,record_date DATE,program_date DATE)
  RETURN VARCHAR2 IS

  CURSOR retrieve_account IS
  SELECT CUSTOMER_ID,DUPLICATE_ID,PROGRAM_UPDATE_DATE
  FROM RA_CUSTOMER_MERGES
  WHERE DUPLICATE_ID=merge_from_acct
  AND PROGRAM_UPDATE_DATE > record_date
  AND PROGRAM_UPDATE_DATE > program_date
  ORDER BY PROGRAM_UPDATE_DATE;


  l_merge_row   retrieve_account%rowtype;

  BEGIN

	OPEN retrieve_account;
	FETCH retrieve_account INTO l_merge_row;
	IF retrieve_account%NOTFOUND
	THEN
	  CLOSE retrieve_account;
	  RETURN merge_from_acct;
	ELSE
	  CLOSE retrieve_account;
	  RETURN merge_cust_acct(l_merge_row.CUSTOMER_ID,
				record_date,l_merge_row.PROGRAM_UPDATE_DATE);
	END IF;
  END merge_cust_acct;

  FUNCTION merge_cust_acct_site_use
    (merge_from_site_use VARCHAR2,record_date DATE,program_date DATE)
  RETURN VARCHAR2 IS

  CURSOR retrieve_account_site_use IS
  SELECT CUSTOMER_SITE_ID,DUPLICATE_SITE_ID,PROGRAM_UPDATE_DATE
  FROM RA_CUSTOMER_MERGES
  WHERE DUPLICATE_SITE_ID=merge_from_site_use
  AND PROGRAM_UPDATE_DATE > record_date
  AND PROGRAM_UPDATE_DATE > program_date
  ORDER BY PROGRAM_UPDATE_DATE;


  l_merge_row   retrieve_account_site_use%rowtype;

  BEGIN

	OPEN retrieve_account_site_use;
	FETCH retrieve_account_site_use INTO l_merge_row;
	IF retrieve_account_site_use%NOTFOUND
	THEN
	  CLOSE retrieve_account_site_use;
	  RETURN merge_from_site_use;
	ELSE
	  CLOSE retrieve_account_site_use;
	  RETURN merge_cust_acct_site_use(l_merge_row.CUSTOMER_SITE_ID,
				record_date,l_merge_row.PROGRAM_UPDATE_DATE);
	END IF;
  END merge_cust_acct_site_use;

PROCEDURE  fix_merge_for_contract(k_header_id NUMBER) IS

  CURSOR list_of_parties (k_header_id NUMBER) IS
  SELECT id,jtot_object1_code,
	object1_id1,object1_id2,last_update_date
  FROM okc_k_party_roles_b
  WHERE DNZ_CHR_ID=k_header_id
  AND JTOT_OBJECT1_CODE IN
    ('OKE_CUST_KADMIN','OKE_BILLTO','OKE_CUSTACCT','OKE_MARKFOR','OKE_SHIPTO');

  l_party_role 		list_of_parties%rowtype;
  l_final_id		VARCHAR2(80);

BEGIN

		-- iterate through rows in OKC_K_PARTY_ROLES_B
		-- for each contract
		OPEN list_of_parties(k_header_id);
		LOOP
		FETCH list_of_parties INTO l_party_role;
		EXIT WHEN list_of_parties%NOTFOUND;

		  IF l_party_role.JTOT_OBJECT1_CODE = 'OKE_CUSTACCT' THEN
			l_final_id:=merge_cust_acct(l_party_role.object1_id1,
				l_party_role.last_update_date,to_date('01-01-1990','MM-DD-YYYY'));

		UPDATE OKC_K_PARTY_ROLES_B
		SET OBJECT1_ID1 = l_final_id,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = -1
		WHERE ID = l_party_role.id;

		  ELSE
			l_final_id:=merge_cust_acct_site_use(l_party_role.object1_id1,
				l_party_role.last_update_date,to_date('01-01-1990','MM-DD-YYYY'));

		UPDATE OKC_K_PARTY_ROLES_B
	 	SET OBJECT1_ID1 = l_final_id,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = -1
		WHERE ID = l_party_role.id;

		  END IF;

		END LOOP;
		CLOSE list_of_parties;

END;


END OKE_FIX_MERGE_PUB;

/
