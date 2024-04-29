--------------------------------------------------------
--  DDL for Package IBY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_MERGE" AUTHID CURRENT_USER AS
/*$Header: IBYMERGS.pls 120.1.12010000.2 2009/09/10 10:46:32 sgogula noship $ */

PROCEDURE  MERGE
( req_id                       NUMBER,
  set_num                      NUMBER,
  process_mode                 VARCHAR2
);

CURSOR CUR_GET_EXT_PAYER_ID
	(account_id iby_external_payers_all.cust_account_id%TYPE,
	 account_site_use_id iby_external_payers_all.acct_site_use_id%TYPE ) IS
	 SELECT ext_payer_id
	 FROM iby_external_payers_all
	 WHERE cust_account_id = account_id
	 AND  NVL(acct_site_use_id,0) = NVL(account_site_use_id,0);

  TYPE ext_payer_id_list_type IS TABLE OF
         iby_external_payers_all.ext_payer_id%TYPE
        INDEX BY BINARY_INTEGER;

END IBY_MERGE;

/
