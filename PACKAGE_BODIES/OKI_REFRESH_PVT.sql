--------------------------------------------------------
--  DDL for Package Body OKI_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_REFRESH_PVT" AS
/* $Header: OKIRRFHB.pls 115.74 2004/08/13 16:35:16 asparama ship $ */

----
--
-- type declarations
--
----
TYPE vc_tab_type     IS TABLE OF VARCHAR2(30);

-- arrays of various fixed-size datatypes used in bulk collections.
TYPE numlist is table of number index by binary_integer ;
TYPE rowlist is table of rowid index by binary_integer ;
TYPE datelist is table of date index by binary_integer ;

----
--
-- cursors
--
----
CURSOR index_info_csr (b_tab_name VARCHAR2
                      ,b_ind_name VARCHAR2
                      ,b_own_name VARCHAR2) IS

SELECT tablespace_name,initial_extent, next_extent
FROM all_indexes
WHERE table_name = b_tab_name
  AND table_owner = b_own_name
  AND index_name = b_ind_name
;

CURSOR index_name_csr(b_tab_name VARCHAR2) IS
SELECT index_name
FROM all_indexes
WHERE table_name  = b_tab_name
  AND table_owner = 'OKI'
;

CURSOR g_latest_job_run_id_csr IS
SELECT MAX(jrn.job_run_id) job_run_id
FROM   oki_job_runs jrn
;
rec_g_latest_job_run_id_csr g_latest_job_run_id_csr%ROWTYPE ;

--
-- Variables
--
l_ind_rec           index_info_csr%ROWTYPE;
l_base_currency    CONSTANT fnd_currencies.currency_code%TYPE :=
                        fnd_profile.value('OKI_BASE_CURRENCY');
-- used to limit batch collection sizes
l_max_rows			CONSTANT binary_integer := 1000;

---------------------------------------------------------------------
--
-- Procedure create_indices
-- Creates the known indicies for the named table
--
---------------------------------------------------------------------
--   11510 Changes to create_indices
--      1. Denormalization of Tables
--           Tables oki_addresses and oki_expired_lines are obsoleted.
--           So, indexes of these tables are removed
--      2. Indexes on columns which are not populated in the table are removed.
--           Index on salesrep_name of oki_k_salesrep and
--           customer_name of oki_sales_k_hdrs are removed.
--      3. Index created on new column is_exp_not_renewed_yn of oki_cov_prd_lines table.
PROCEDURE create_indicies (p_object_name IN VARCHAR2
                          ,p_parm_rec IN index_info_csr%ROWTYPE) IS

l_contract_number VARCHAR2(1000);
l_sql_string    VARCHAR2(4000);
l_index_info    index_info_csr%ROWTYPE;

   CURSOR c_default_index_info IS
      SELECT tspace.tablespace_name,
             tspace.initial_extent,
             tspace.next_extent
      FROM   dba_users usr, dba_tablespaces tspace
      WHERE  usr.username = 'OKI'
      AND    usr.default_tablespace = tspace.tablespace_name;

BEGIN
  l_index_info := p_parm_rec;
  -- guard against failures where we could not get storage parameters
  -- for the index
  IF l_index_info.tablespace_name IS NULL THEN
    -- get parameters for the OKI user
     OPEN c_default_index_info;
     FETCH c_default_index_info INTO l_index_info;
    CLOSE c_default_index_info;
  END IF;

  -- create the indexes
  IF p_object_name = 'OKI_SALES_K_HDRS' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(IS_NEW_YN)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(CLOSE_DATE)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N3 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(END_DATE)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N4 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(CUSTOMER_PARTY_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N5 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(DATE_CANCELED)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N6 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(START_DATE)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N7 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(DATE_TERMINATED)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N8 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(authoring_org_id)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N9 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(date_approved)'
						  ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;

/*  11510 Changes
    Commenting out creation of index as customer name is not be used
    from this table.

    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N10 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(customer_name)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
*/
    l_sql_string := 'CREATE INDEX OKI.OKI_SALES_K_HDRS_N11 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(COMPLETE_CONTRACT_NUMBER)'
						  ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_SALES_K_HDRS_U1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(CHR_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_SALES_K_HDRS_U2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SALES_K_HDRS(CONTRACT_NUMBER,CONTRACT_NUMBER_MODIFIER)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;

/*  11510 Changes

    Commenting out creation of index as oki_addresses is obsoleted

  ELSIF p_object_name = 'OKI_ADDRESSES' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_ADDRESSES_N1 ON OKI.OKI_ADDRESSES (CLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
*/
  ELSIF p_object_name = 'OKI_SOLD_ITM_LINES' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(CHR_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(CONTRACT_NUMBER)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N3 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(COMPLETE_CONTRACT_NUMBER)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N4 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(ITEM_ID, INVENTORY_ORGANIZATION_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_SOLD_ITM_LINES_U1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(CLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
  	/*11.5.10 ADDED
	    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N5 ON';
	    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(BILL_TO_SITE_USE_ID)'||' PARALLEL ';

	l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
	    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
	    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
	    EXECUTE IMMEDIATE l_sql_string;
	    l_sql_string := 'CREATE INDEX OKI.OKI_SOLD_ITM_LINES_N6 ON';
	    l_sql_string := l_sql_string||' OKI.OKI_SOLD_ITM_LINES(SHIP_TO_SITE_USE_ID)'||' PARALLEL ';
	    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
	    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
	    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
	    EXECUTE IMMEDIATE l_sql_string;
	  11510 Changes End */
  ELSIF p_object_name = 'OKI_COV_PRD_LINES' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(CHR_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(CONTRACT_NUMBER)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N3 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(COVERED_PRODUCT_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N4 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(PARENT_CLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N5 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(START_DATE)'
						  ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N6 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(COMPLETE_CONTRACT_NUMBER)'
						  ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N7 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(system_name)'
                                ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N8 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(end_date)'
                                ||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
/*  11510 Changes Start
Adding new index on oki_cov_prd_lines table. */
    l_sql_string := 'CREATE INDEX OKI.OKI_COV_PRD_LINES_N9 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(IS_EXP_NOT_RENEWED_YN)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
/*  11510 Changes End */

    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_COV_PRD_LINES_U1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_COV_PRD_LINES(CLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;

/*  11510 Changes

Commenting out creation of index as oki_expired_lines is obsoleted

  ELSIF p_object_name = 'OKI_EXPIRED_LINES' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_EXPIRED_LINES_N1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_EXPIRED_LINES(CHR_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE INDEX OKI.OKI_EXPIRED_LINES_N2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_EXPIRED_LINES(END_DATE)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_EXPIRED_LINES_U1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_EXPIRED_LINES(CLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
*/
  ELSIF p_object_name = 'OKI_K_SALESREPS' THEN
    l_sql_string := 'CREATE INDEX OKI.OKI_K_SALESREPS_N1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_K_SALESREPS(CONTRACT_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;

/* 11510 Changes
Commenting out creation of index as salesrep name is not be used from
this table.

    l_sql_string := 'CREATE INDEX OKI.OKI_K_SALESREPS_N2 ON';
    l_sql_string := l_sql_string||' OKI.OKI_K_SALESREPS(SALESREP_NAME)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
*/
    l_sql_string := 'CREATE INDEX OKI.OKI_K_SALESREPS_N3 ON';
    l_sql_string := l_sql_string||' OKI.OKI_K_SALESREPS(PARTY_ROLE_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
    l_sql_string := 'CREATE UNIQUE INDEX OKI.OKI_K_SALESREPS_U1 ON';
    l_sql_string := l_sql_string||' OKI.OKI_K_SALESREPS(PARTY_CONTACT_ID)'||' PARALLEL ';
    l_sql_string := l_sql_string||' TABLESPACE '||l_index_info.tablespace_name;
    l_sql_string := l_sql_string||' STORAGE(INITIAL '||l_index_info.initial_extent;
    l_sql_string := l_sql_string||' NEXT '||l_index_info.next_extent||')';
    EXECUTE IMMEDIATE l_sql_string;
  END IF;
EXCEPTION
   WHEN OTHERS
	 THEN
         fnd_file.put_line(  which => fnd_file.log
                           , buff  => 'The Following SQL statement failed ');
         fnd_file.put_line(  which => fnd_file.log
                           , buff  => l_sql_string);
         fnd_file.put_line(  which => fnd_file.log
                           , buff  => ' ');
         IF (p_object_name = 'OKI_SALES_K_HDRS')
	    THEN
            FOR r_rec IN (SELECT dnz_chr_id, count(1) chr_count
					 FROM   okc_k_party_roles_b
		                WHERE rle_code  IN ('CUSTOMER','LICENSEE','BUYER')
		                AND   cle_id is null
		                GROUP BY dnz_chr_id
		                HAVING COUNT(1) > 1)
            LOOP
              SELECT contract_number ||' '||contract_number_modifier
              INTO   l_contract_number
              FROM okc_k_headers_b
              WHERE id = r_rec.dnz_chr_id;
               fnd_file.put_line(  which => fnd_file.log
                                 , buff  => 'Multiple Parties (Ex. CUSTOMER) defined for contract number '
                                             || l_contract_number);
            END LOOP;
            fnd_file.put_line(  which => fnd_file.log
                              , buff  => ' ');
         END IF;
	 RAISE;
END create_indicies;

---------------------------------------------------------------------
--
-- Procedure update_oki_refreshs
-- Log concurrent manager information for full refresh of an object
--
---------------------------------------------------------------------
PROCEDURE update_oki_refresh ( p_object_name IN  VARCHAR2
                             , x_retcode     OUT NOCOPY VARCHAR2
                             , p_job_run_id  IN  NUMBER DEFAULT NULL ) IS
l_sqlcode   VARCHAR2(100);
l_sqlerrm   VARCHAR2(1000);

BEGIN

  x_retcode := '0';

  UPDATE OKI_REFRESHS
  SET    REQUEST_ID             = g_request_id ,
         PROGRAM_APPLICATION_ID = g_program_application_id,
         PROGRAM_ID             = g_program_id,
         PROGRAM_UPDATE_DATE    = g_program_update_date,
         OBJECT_VERSION_NUMBER  = OBJECT_VERSION_NUMBER +1,
         LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
         LAST_UPDATE_DATE       = SYSDATE,
         LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID,
         JOB_RUN_ID             = p_job_run_id
  WHERE  OBJECT_NAME = p_object_name;

 IF SQL%ROWCOUNT <> 1  THEN
  	x_retcode := 2;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;

    -- Set return code to warning
    x_retcode := '2';

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UPD_RFR_TABLE_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff => l_sqlcode||' '||l_sqlerrm );
END update_oki_refresh;

---------------------------------------------------------------------
--
-- Procedure update_oki_refreshs
-- Log concurrent manager information for full refresh of an object
--
---------------------------------------------------------------------
PROCEDURE update_refresh_job_run(
  p_object_name IN VARCHAR2
, p_job_run_id  IN NUMBER
, x_retcode     OUT NOCOPY VARCHAR2 ) IS

  -- Location within the program before the error was encountered.
  l_loc          VARCHAR2(200) ;
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

BEGIN

  x_retcode := '0';

  l_loc := 'Updating oki_refreshs job_run_id for ' || p_object_name ;
  UPDATE OKI_REFRESHS
  SET    REQUEST_ID             = g_request_id ,
         PROGRAM_APPLICATION_ID = g_program_application_id,
         PROGRAM_ID             = g_program_id,
--         PROGRAM_UPDATE_DATE    = g_program_update_date,
         JOB_RUN_ID             = p_job_run_id,
         LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
         LAST_UPDATE_DATE       = SYSDATE,
         LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID
  WHERE  OBJECT_NAME = p_object_name;

EXCEPTION
  WHEN OTHERS THEN

    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;

    -- Set return code to warning
    x_retcode := '1';

    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.update_refresh_job_run ' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UPD_RFR_TABLE_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff => l_sqlcode||' '||l_sqlerrm );
END update_refresh_job_run ;

---------------------------------------------------------------------
-- procedure ins_job_runs
--
-- This procedure creates a job_runs record.
--
---------------------------------------------------------------------
PROCEDURE ins_job_runs
( p_job_start_date      IN  DATE
, p_job_end_date        IN  DATE
, p_job_curr_start_date IN  DATE
, p_job_curr_end_date   IN  DATE
, p_job_run_id          OUT NOCOPY NUMBER
, x_errbuf              OUT NOCOPY VARCHAR2
, x_retcode             OUT NOCOPY VARCHAR2
) IS

  -- Cursor declaration
  CURSOR l_seq_num_csr IS
    SELECT oki_job_runs_s1.nextval seq
    FROM dual
    ;
  rec_l_seq_num l_seq_num_csr%ROWTYPE ;

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc           VARCHAR2(200) ;
  l_sqlcode       VARCHAR2(100) ;
  l_sqlerrm       VARCHAR2(1000) ;
  l_retcode       VARCHAR2(1) ;
  l_table_name    VARCHAR2(30);
  l_sequence      NUMBER := NULL ;
  l_sysdate       DATE ;

BEGIN
  l_retcode := '0' ;
  l_sysdate := sysdate;
  l_table_name := 'OKI_JOB_RUNS';

  l_loc := 'Get job_run_id sequence number.' ;
  OPEN l_seq_num_csr ;
  FETCH l_seq_num_csr INTO rec_l_seq_num ;
    -- unable to generate sequence number, exit immediately
    IF l_seq_num_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    l_sequence := rec_l_seq_num.seq ;
  CLOSE l_seq_num_csr ;

  l_loc := 'Inserting into ' || l_table_name ;
  INSERT INTO oki_job_runs (
           job_run_id
         , job_start_date
         , job_end_date
         , job_curr_start_date
         , job_curr_end_date
         , creation_date
         , created_by
         , last_update_date
         , last_updated_by
         , security_group_id
         , request_id
  ) VALUES (
           l_sequence
         , p_job_start_date
         , p_job_end_date
         , least(p_job_curr_start_date,l_sysdate)
         , least(p_job_curr_end_date,l_sysdate)
         , l_sysdate
         , FND_GLOBAL.USER_ID
         , l_sysdate
         , FND_GLOBAL.USER_ID
         , NULL
         , g_request_id );

  p_job_run_id := l_sequence ;

  COMMIT ;

EXCEPTION
  WHEN l_excp_exit_immediate THEN
    -- Set return code to error
    x_retcode := 2 ;

    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.ins_job_runs' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.job_start' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END ins_job_runs ;


---------------------------------------------------------------------
-- procedure truncate_table
--
-- This procedure truncates a table.
--
---------------------------------------------------------------------
PROCEDURE truncate_table
( p_table_owner         IN  VARCHAR2
, p_table_name          IN  VARCHAR2
, x_errbuf              OUT NOCOPY VARCHAR2
, x_retcode             OUT NOCOPY VARCHAR2
) IS
  -- Location within the program before the error was encountered.
  l_loc           VARCHAR2(200) ;
  l_sqlcode       VARCHAR2(100) ;
  l_sqlerrm       VARCHAR2(1000) ;
  l_retcode       VARCHAR2(1) ;
  l_sql_string    VARCHAR2(4000) ;

BEGIN
  l_retcode := '0' ;

  l_loc := 'Truncating table ' || p_table_owner || '.' || p_table_name ;
  l_sql_string := 'TRUNCATE TABLE ' || p_table_owner || '.' || p_table_name ;
  EXECUTE IMMEDIATE l_sql_string ;

EXCEPTION
  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.truncate_table' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;

END truncate_table ;

---------------------------------------------------------------------
-- procedure initial_job_check
--
-- This procedure checks if this is the initial first time job run.
-- If it is, then it:
-- 1. Truncates the oki base tables
-- 2. Seeds the oki_job_runs table with a dummy record
-- 3. Updates the oki_refreshs table job_run id with
--    the dummy job_run_id
--
---------------------------------------------------------------------
PROCEDURE initial_job_check
( x_errbuf              OUT NOCOPY VARCHAR2
, x_retcode             OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc           VARCHAR2(200) ;
  l_sqlcode       VARCHAR2(100) ;
  l_sqlerrm       VARCHAR2(1000) ;
  l_retcode       VARCHAR2(1) ;
  l_job_run_count NUMBER ;
  l_table_owner   VARCHAR2(30) ;
  l_table_name    VARCHAR2(30) ;
  l_job_run_id    NUMBER ;
  l_init_job_run_date  DATE ;

-- Cursor to check if this is the first time the job has ever run
CURSOR l_job_run_count_csr IS
  SELECT count(*) jbrn_count
  FROM oki_job_runs jrn ;
rec_l_job_run_count_csr l_job_run_count_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;
  l_init_job_run_date := fnd_conc_date.string_to_date('1900/01/01');

  l_loc := 'Checking if this is the first time the job has ever run.' ;
  OPEN l_job_run_count_csr ;
  FETCH l_job_run_count_csr INTO rec_l_job_run_count_csr ;
    l_job_run_count := rec_l_job_run_count_csr.jbrn_count ;
  CLOSE l_job_run_count_csr ;

  l_loc := 'Checking if this is the initial first time load' ;
  IF l_job_run_count > 0 THEN
    RAISE l_excp_no_processing ;
  END IF ;

  l_table_owner := 'OKI' ;

  l_table_name := 'OKI_SALES_K_HDRS' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
  l_table_name := 'OKI_SOLD_ITM_LINES' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_table_name := 'OKI_COV_PRD_LINES' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
/* 11510 Changes
  l_table_name := 'OKI_EXPIRED_LINES' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/
  l_table_name := 'OKI_K_SALESREPS' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

/* 11510 Changes

  l_table_name := 'OKI_ADDRESSES' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/
  ins_job_runs(
        p_job_start_date      => sysdate
      , p_job_end_date        => sysdate
      , p_job_curr_start_date => l_init_job_run_date
      , p_job_curr_end_date   => l_init_job_run_date
      , p_job_run_id          => l_job_run_id
      , x_errbuf              => x_errbuf
      , x_retcode             => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_table_name := 'OKI_SALES_K_HDRS' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                   , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- update_oki_refresh failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_table_name := 'OKI_SOLD_ITM_LINES' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_table_name := 'OKI_COV_PRD_LINES' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

/* 11510 Changes

  l_table_name := 'OKI_EXPIRED_LINES' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/

  l_table_name := 'OKI_K_SALESREPS' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

/* 11510 Changes

  l_table_name := 'OKI_ADDRESSES' ;
  l_loc := 'Updating OKI_REFRESHS for || l_table_name' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/

  COMMIT ;
EXCEPTION
  WHEN l_excp_no_processing then
    -- Just exit the program and continue with the table load

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_OBJ_ALREADY_RFR_MSG') ;
    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'OKI_JOB_RUNS') ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get) ;

  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;


  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    x_retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.initial_job_check' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;

END initial_job_check ;

---------------------------------------------------------------------
-- procedure get_load_date_range
--
-- Retrieves the start and end date for which the load should be
-- processed.
---------------------------------------------------------------------
PROCEDURE get_load_date_range
( p_job_run_id          IN  NUMBER
, p_job_curr_start_date OUT NOCOPY DATE
, p_job_curr_end_date   OUT NOCOPY DATE
, x_errbuf              OUT NOCOPY VARCHAR2
, x_retcode             OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc          VARCHAR2(200) ;
  l_sqlcode      VARCHAR2(100) ;
  l_sqlerrm      VARCHAR2(1000) ;
  l_retcode      VARCHAR2(1) ;

  -- Cursor to retrieve the
  CURSOR l_job_curr_date_csr
  ( p_job_run_id IN NUMBER
  ) IS
    SELECT
            job_curr_start_date
          , job_curr_end_date
    FROM oki_job_runs jrn
    WHERE jrn.job_run_id = p_job_run_id ;
  rec_l_job_curr_date l_job_curr_date_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;

  l_loc := 'Getting job_curr_date range.' ;
  OPEN l_job_curr_date_csr(p_job_run_id) ;
  FETCH l_job_curr_date_csr INTO rec_l_job_curr_date ;
    IF l_job_curr_date_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    p_job_curr_start_date := rec_l_job_curr_date.job_curr_start_date ;
    p_job_curr_end_date   := rec_l_job_curr_date.job_curr_end_date ;
  CLOSE l_job_curr_date_csr ;

EXCEPTION
  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.get_load_date_range' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END get_load_date_range ;

---------------------------------------------------------------------
-- procedure ins_job_run_dtl
--
-- Procedure to insert into the oki_job_run_dtl the list of
-- contracts to be deleted from and inserted into the oki base
-- tables.
---------------------------------------------------------------------

PROCEDURE ins_job_run_dtl
( p_job_run_id          IN  NUMBER
, p_job_curr_start_date IN  DATE
, p_job_curr_end_date   IN  DATE
, x_retcode             OUT NOCOPY VARCHAR2
) IS
  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc            VARCHAR2(200) ;
  l_sqlcode        VARCHAR2(100) ;
  l_sqlerrm        VARCHAR2(1000) ;
  l_retcode        VARCHAR2(1) ;
  l_sysdate        DATE   ;

BEGIN
  l_retcode := '0' ;
  l_sysdate := sysdate;

  l_loc := 'Inserting into oki_job_run_dtl.' ;
  -- Insert into the job_run_dtl table
  -- record to be deleted and records to be inserted
  INSERT INTO oki_job_run_dtl (
           job_run_id
         , chr_id
         , action_flag
         , sob_id
         , period_set_name
         , accounted_period_type
         , func_currency
         , trx_func_rate
         , trx_base_rate
         , conversion_date
         , creation_date
         , created_by
         , last_update_date
         , last_updated_by
         , security_group_id
         , request_id
         , major_version
         , minor_version
  ) (SELECT
             p_job_run_id
           , shd.chr_id
           , 'D'
           , NULL     --sob_id
           , NULL     --period_set_name
           , NULL     --accounted_period_type
           , NULL     --func_currency
           , NULL     --trx_func_rate
           , NULL     --trx_base_rate
           , NULL     --conversion_date
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , NULL
           , g_request_id
           , NULL     --Major Version
           , NULL     --Minor Version
    FROM oki_sales_k_hdrs shd
    MINUS
    SELECT
             p_job_run_id
           , khr.id
           , 'D'
           , NULL     --sob_id
           , NULL     --period_set_name
           , NULL     --accounted_period_type
           , NULL     --func_currency
           , NULL     --trx_func_rate
           , NULL     --trx_base_rate
           , NULL     --conversion_date
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , NULL
           , g_request_id
           , NULL     --Major Version
           , NULL     --Minor Version
    FROM okc_k_headers_b khr)
    UNION
    SELECT
             p_job_run_id
           , vnm.chr_id
           , 'I'
           , SOB.set_of_books_id
           , SOB.period_set_name
           , SOB.accounted_period_type
           , SOB.currency_code
           , decode (sts.ste_code,'ACTIVE',
                     get_conversion_rate( trunc(khr.start_date),khr.currency_code,sob.currency_code)
                    , 'HOLD',
		     get_conversion_rate( trunc(khr.start_date),khr.currency_code,sob.currency_code)
                    ,'TERMINATED',
		     get_conversion_rate( trunc(khr.start_date),khr.currency_code,sob.currency_code)
                    , 'EXPIRED',
                    get_conversion_rate( trunc(khr.start_date),khr.currency_code,sob.currency_code)
                   , get_conversion_rate(l_sysdate,khr.currency_code,sob.currency_code)
                  ) trx_func_rate
           , decode (sts.ste_code,'ACTIVE',
                     get_conversion_rate( trunc(khr.start_date),khr.currency_code,l_base_currency)
                    , 'HOLD',
		     get_conversion_rate( trunc(khr.start_date),khr.currency_code,l_base_currency)
                    ,'TERMINATED',
		     get_conversion_rate( trunc(khr.start_date),khr.currency_code,l_base_currency)
                    , 'EXPIRED',
                    get_conversion_rate( trunc(khr.start_date),khr.currency_code,l_base_currency)
                   , get_conversion_rate(l_sysdate,khr.currency_code,l_base_currency)
                  ) trx_base_rate
           , decode (sts.ste_code,'ACTIVE',
                      trunc(khr.start_date)
                    , 'HOLD',
              		  trunc(khr.start_date)
                    ,'TERMINATED',
         		      trunc(khr.start_date)
                    , 'EXPIRED',
                      trunc(khr.start_date)
                    , trunc(sysdate)
                  ) conversion_date
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , NULL
           , g_request_id
           , vnm.major_version
           , vnm.minor_version
    FROM  okc_k_headers_b khr
         ,okc_k_vers_numbers vnm
         ,hr_organization_information oin
         ,gl_sets_of_books sob
	 ,okc_statuses_b sts
    WHERE 1 = 1
    AND   khr.buy_or_sell             = 'S'
    AND   khr.template_yn             = 'N'
    AND   khr.application_id          = 515
    AND   khr.scs_code                IN ('SERVICE','WARRANTY') -- 11510 Change
    AND   vnm.chr_id                  = khr.id
    AND   oin.organization_id         = khr.authoring_org_id
    AND   oin.org_information_context = 'Operating Unit Information'
    AND   sob.set_of_books_id         = TO_NUMBER(oin.org_information3)
    AND   vnm.last_update_date BETWEEN p_job_curr_start_date
                                   AND p_job_curr_end_date
    AND khr.sts_code                = sts.code;
    COMMIT ;


   -- analyze table
    fnd_stats.gather_table_stats(ownname=>'OKI' ,tabname=>'OKI_JOB_RUN_DTL',percent=> 10);

EXCEPTION
  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.ins_job_run_dtl' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END ins_job_run_dtl ;

/****************11510 changes for currency conversion new Procedure***********/
---------------------------------------------------------------------
-- procedure initial_load_job_run_dtl
-- Insert into the oki_job_run_dtl the list of
-- contracts to be inserted into OKI_SALES_K_HDRS table during inital load.
-- This table stores both the functional as well as base conversion rates for
-- all the contracts inserted
---------------------------------------------------------------------

PROCEDURE initial_load_job_run_dtl(  p_job_run_id          IN  NUMBER
                                   , p_job_curr_start_date IN  DATE
                                   , p_job_curr_end_date   IN  DATE
                                   ,x_retcode OUT NOCOPY VARCHAR2) IS
TYPE chr_id_tab_typ IS TABLE OF oki_sales_k_hdrs.chr_id%TYPE INDEX BY BINARY_INTEGER;
TYPE version_number_tab_typ IS TABLE OF oki_sales_k_hdrs.major_version%TYPE INDEX BY BINARY_INTEGER;
TYPE date_tab_typ IS TABLE OF oki_sales_k_hdrs.start_date%TYPE INDEX BY BINARY_INTEGER;
TYPE currency_tab_typ IS TABLE OF oki_sales_k_hdrs.currency_code%TYPE INDEX BY BINARY_INTEGER;
TYPE rate_tab_typ IS TABLE OF gl_daily_rates.conversion_rate%TYPE INDEX BY BINARY_INTEGER;

TYPE sob_acct_period_tab_typ IS TABLE OF gl_sets_of_books.accounted_period_type%TYPE INDEX BY BINARY_INTEGER;
TYPE sob_id_tab_typ IS TABLE OF gl_sets_of_books.set_of_books_id%TYPE INDEX BY BINARY_INTEGER;
TYPE period_set_name_tab_typ IS TABLE OF gl_sets_of_books.period_set_name%TYPE INDEX BY BINARY_INTEGER;

l_no_update_refresh exception;
chr_id_tab          chr_id_tab_typ;
conversion_date_tab      date_tab_typ;
trans_currency_tab  currency_tab_typ;
base_currency_tab   currency_tab_typ;
func_currency_tab    currency_tab_typ;
sob_acct_period_tab    sob_acct_period_tab_typ;
sob_id_tab    sob_id_tab_typ;
period_set_name_tab    period_set_name_tab_typ;
major_version_tab      version_number_tab_typ;
minor_version_tab      version_number_tab_typ;

l_sysdate        DATE ;

CURSOR cur_contracts IS
SELECT khr.id  chr_id,
       decode (sts.ste_code,'ACTIVE',
                    trunc(khr.start_date)
                    , 'HOLD',
		            trunc(khr.start_date)
                    ,'TERMINATED',
                    trunc(khr.start_date)
                    , 'EXPIRED',
                    trunc(khr.start_date)
                   , l_sysdate
                  ) conversion_date,
   khr.currency_code currency_code,
   fnd_profile.value('OKI_BASE_CURRENCY') base_currency_code,
   sob.currency_code sob_currency_code,
   sob.accounted_period_type,
   sob.set_of_books_id,
   sob.period_set_name,
   vnm.major_version,
   vnm.minor_version
FROM
   okc_k_headers_b khr,
   okc_k_vers_numbers vnm,
   okc_statuses_b sts,
   gl_sets_of_books sob,
   hr_organization_information oin
WHERE 1 = 1
AND khr.buy_or_sell             = 'S'
AND khr.template_yn             = 'N'
AND khr.application_id          = 515
AND khr.scs_code                IN ('SERVICE','WARRANTY') -- 11510 Change
AND khr.sts_code                = sts.code
AND khr.authoring_org_id        = oin.organization_id
AND vnm.chr_id                  = khr.id
AND oin.org_information_context = 'Operating Unit Information'
AND sob.set_of_books_id         = oin.org_information3;


l_conv_type   gl_daily_rates.conversion_type%TYPE;

CURSOR cur_currency_rate(l_curr_date Date,
                       l_from_curr Varchar2,
                       l_to_curr Varchar2,
                       l_conv_type Varchar2) IS
Select conversion_rate from gl_daily_rates
Where  from_currency = l_from_curr
And    to_currency =   l_to_curr
And    conversion_date =  (SELECT MAX(conversion_date)
                         FROM   gl_daily_rates
                         WHERE  from_currency = l_from_curr
                         AND    to_currency =   l_to_curr
                         AND    conversion_date <=  l_curr_date
                         AND    conversion_type = l_conv_type)
And    conversion_type = l_conv_type;

l_date                      date ;
l_last_date                 date ;
l_trx_base_rate_tab             rate_tab_typ;
l_trx_func_rate_tab             rate_tab_typ;
l_message                       varchar2(1000);
l_limit                         INTEGER := 0;
l_max_select                    INTEGER := 20000;
l_remainder                     INTEGER;
l_sqlcode                       VARCHAR2(100);
l_sqlerrm                       VARCHAR2(1000);

BEGIN
  x_retcode := 0;
  l_sysdate := sysdate ;
  l_conv_type  := fnd_profile.value('OKI_DEFAULT_CONVERSION_TYPE');

SELECT count(*) INTO l_remainder
FROM
   okc_k_headers_b khr,
   okc_statuses_b sts,
   gl_sets_of_books sob,
   hr_organization_information oin
WHERE 1 = 1
AND khr.buy_or_sell             = 'S'
AND khr.template_yn             = 'N'
AND khr.application_id          = 515
AND khr.scs_code                IN ('SERVICE','WARRANTY') -- 11510 Change
AND khr.sts_code                = sts.code
AND khr.authoring_org_id        = oin.organization_id
AND oin.org_information_context = 'Operating Unit Information'
AND sob.set_of_books_id         = oin.org_information3;



  IF l_remainder > l_max_select THEN
    l_limit := l_max_select;
    l_remainder := l_remainder - l_max_select;
  ELSE
    l_limit := l_remainder;
    l_remainder := 0;
  END IF;

  IF l_limit > 0 THEN
    OPEN cur_contracts;
    LOOP
        FETCH cur_contracts BULK COLLECT INTO chr_id_tab
                               ,conversion_date_tab
                               ,trans_currency_tab
                               ,base_currency_tab
                               ,func_currency_tab
                               ,sob_acct_period_tab
                               ,sob_id_tab
                               ,period_set_name_tab
                               ,major_version_tab
                               ,minor_version_tab
                               LIMIT l_limit;

        IF chr_id_tab.first IS NOT NULL THEN
          FOR i in chr_id_tab.first..chr_id_tab.last LOOP
            l_date                          := conversion_date_tab(i);
            l_trx_base_rate_tab(i)         := 0;
            l_trx_func_rate_tab(i)          := 0;

            IF(trans_currency_tab(i) = base_currency_tab(i)) THEN
              l_trx_base_rate_tab(i) := 1 ;
            ELSE
              FOR curr_rec IN cur_currency_rate (l_date,trans_currency_tab(i),base_currency_tab(i),l_conv_type)
              LOOP
                l_trx_base_rate_tab(i) := curr_rec.conversion_rate ;
              END LOOP ;
            END IF;

            IF(trans_currency_tab(i) = func_currency_tab(i)) THEN
            	 l_trx_func_rate_tab(i)  := 1 ;
            ELSE
              FOR curr_rec IN cur_currency_rate (l_date,trans_currency_tab(i),func_currency_tab(i),l_conv_type)
              LOOP
                l_trx_func_rate_tab(i) := curr_rec.conversion_rate ;
              END LOOP ;
            END IF;


            IF(l_trx_base_rate_tab(i) = 0) THEN
              fnd_message.set_name(application => 'OKI'
                                  ,name => 'OKI_CONV_RATE_FAILURE');
              fnd_message.set_token(token => 'FROM_CURRENCY'
                                   ,value => trans_currency_tab(i));
              fnd_message.set_token(token => 'TO_CURRENCY'
                                   ,value => base_currency_tab(i));
              fnd_file.put_line(which => fnd_file.log
                               ,buff => fnd_message.get);
            END IF;

            IF(l_trx_func_rate_tab(i) = 0) THEN
              fnd_message.set_name(application => 'OKI'
                                  ,name => 'OKI_CONV_RATE_FAILURE');
              fnd_message.set_token(token => 'FROM_CURRENCY'
                                   ,value => trans_currency_tab(i));
              fnd_message.set_token(token => 'TO_CURRENCY'
                                   ,value => func_currency_tab(i));
              fnd_file.put_line(which => fnd_file.log
                               ,buff => fnd_message.get);
            END IF;

          END LOOP; -- FOR loop on tab(i)


       FORALL j in chr_id_tab.first..chr_id_tab.last
      INSERT INTO oki_job_run_dtl (
               job_run_id
              ,chr_id
              ,action_flag
              ,sob_id
              ,period_set_name
              ,accounted_period_type
              ,func_currency
              ,trx_func_rate
              ,trx_base_rate
              ,conversion_date
              ,creation_date
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,security_group_id
              ,request_id
              ,major_version
              ,minor_version
              )
          values
               (  p_job_run_id
                 ,chr_id_tab(j)
                 ,'I'
                 ,sob_id_tab(j)
                 ,period_set_name_tab(j)
                 ,sob_acct_period_tab(j)
                 ,func_currency_tab(j)
                 ,l_trx_func_rate_tab(j)
                 ,l_trx_base_rate_tab(j)
                 , conversion_date_tab(j)
                 , l_sysdate
                 , FND_GLOBAL.USER_ID
                 , l_sysdate
                 , FND_GLOBAL.USER_ID
                 , NULL
                 , g_request_id
                 ,major_version_tab(j)
                 ,minor_version_tab(j));
            COMMIT;
        END IF;  -- chr_id_tab.first IS NOT NULL

        IF l_remainder > l_max_select THEN
          l_limit := l_max_select;
          l_remainder := l_remainder - l_max_select;
        ELSE
          l_limit := l_remainder;
          l_remainder := 0;
        END IF;

         IF l_limit = 0 THEN
          EXIT;
        END IF;

     END LOOP; -- main loop
    CLOSE cur_contracts;
  END IF;  -- l_limit > 0

  -- update oki_refreshes
  update_oki_refresh(p_object_name => 'OKI_K_CONV_RATE'
                    ,x_retcode => x_retcode);
  IF x_retcode = '2' THEN
    -- update_oki_refresh failed, exit immediately.
    RAISE l_no_update_refresh;
  END IF ;


  -- analyze table
  fnd_stats.gather_table_stats(ownname => 'OKI'
                              ,tabname => 'OKI_K_CONV_RATE',percent=> 10);

  EXCEPTION
  	when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'initial_load_job_run_dtl');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
    WHEN OTHERS THEN
      CLOSE cur_contracts;
      l_sqlcode := sqlcode;
      l_sqlerrm := sqlerrm;
      ROLLBACK;
      x_retcode := '2';
      fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'initial_load_job_run_dtl');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);
      fnd_file.put_line(which => fnd_file.log
                       ,buff => l_sqlcode||' '||l_sqlerrm);
END  initial_load_job_run_dtl;


---------------------------------------------------------------------
-- procedure job_start
--
-- Starts the refresh process
-- 1.  Creates an oki_job_runs record
-- 2.  Loads the oki_job_run_dtl table with the records to delete
--     and insert into the oki base tables.
---------------------------------------------------------------------
PROCEDURE job_start
( p_job_start_date  IN  DATE
, x_errbuf          OUT NOCOPY VARCHAR2
, x_retcode         OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc            VARCHAR2(200) ;
  l_sqlcode        VARCHAR2(100) ;
  l_sqlerrm        VARCHAR2(1000) ;
  l_retcode        VARCHAR2(1) ;
  l_sequence       NUMBER := NULL;
  l_sysdate        DATE   ;
  l_job_start_date DATE ;
  l_job_end_date   DATE;
  l_job_curr_start_date DATE ;
  l_job_curr_end_date   DATE ;
  l_table_name    VARCHAR2(30) ;
  l_table_owner   VARCHAR2(30) ;

  -- Cursor declaration
  CURSOR l_seq_num_csr IS
    SELECT oki_job_runs_s1.nextval seq
    FROM dual
    ;
  rec_l_seq_num l_seq_num_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;
  l_sysdate := sysdate;
  l_table_owner :='OKI';

/*   No need to truncate this table for incremental load
  l_table_name := 'OKI_JOB_RUN_DTL' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/
 l_loc := 'Get job_runs_id sequence number.' ;

  OPEN l_seq_num_csr ;
  FETCH l_seq_num_csr INTO rec_l_seq_num ;
    -- unable to generate sequence number, exit immediately
    IF l_seq_num_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate;
    END IF ;
    l_sequence := rec_l_seq_num.seq ;
  CLOSE l_seq_num_csr ;

  SELECT least(jrn.job_curr_end_date + (1/(24 * 60 * 60)), l_sysdate)
  INTO l_job_start_date
  FROM oki_job_runs jrn
  WHERE jrn.job_run_id = (
                             SELECT MAX(jrn1.job_run_id)
                             FROM oki_job_runs jrn1
                             WHERE jrn1.job_run_id < l_sequence ) ;

   l_job_end_date := LEAST(nvl(p_job_start_date, sysdate ),l_sysdate);

     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Service Contracts Intelligence -  incremental load Started on ' ||
                                       fnd_date.date_to_displayDT(sysdate));
     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Parameter : start date               '|| fnd_date.date_to_displayDT(l_job_start_date));
     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Parameter : end date                 '|| fnd_date.date_to_displayDT(l_job_end_date));

    IF l_job_end_date < l_job_start_date THEN
   	-- Job start date is greater than job end date
   	fnd_file.put_line(  which => fnd_file.log
                      , buff  => 'Job start date is greater than job end date...Hence exiting');
   	RAISE l_excp_exit_immediate;
    END IF;

  l_loc := 'Inserting into oki_job_runs' ;
  INSERT INTO oki_job_runs (
           job_run_id
         , job_start_date
         , job_end_date
         , job_curr_start_date
         , job_curr_end_date
         , creation_date
         , created_by
         , last_update_date
         , last_updated_by
         , security_group_id
         , request_id
  ) SELECT
            l_sequence
           , l_sysdate
           , NULL
           -- Add 1 second to the start time so the time
           -- does not overlap with the previous job run
           , l_job_start_date
           , l_job_end_date
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , NULL
           , g_request_id
    FROM oki_job_runs jrn1
    WHERE jrn1.job_run_id = (
                             SELECT MAX(jrn3.job_run_id)
                             FROM oki_job_runs jrn3
                             WHERE jrn3.job_run_id < l_sequence ) ;
  COMMIT ;

  l_loc := 'Calling get_load_date_range.' ;
  get_load_date_range(
      p_job_run_id          => l_sequence
    , p_job_curr_start_date => l_job_curr_start_date
    , p_job_curr_end_date   => l_job_curr_end_date
    , x_errbuf              => x_errbuf
    , x_retcode             => l_retcode ) ;
  l_loc := 'Determining status of get_job_run_id.' ;
  IF l_retcode = '2' THEN
    -- No job_run_id, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Calling ins_job_run_dtl.' ;
  ins_job_run_dtl(
        p_job_run_id          => l_sequence
      , p_job_curr_start_date => l_job_curr_start_date
      , p_job_curr_end_date   => l_job_curr_end_date
      , x_retcode             => l_retcode ) ;
    IF l_retcode = '2' THEN
    -- ins_job_run_dtl failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

EXCEPTION
  WHEN l_excp_exit_immediate THEN
    -- Set return code to error
    x_retcode := 2 ;

    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.job_start' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.job_start' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END job_start ;


/**********11510 Changes due to currency conversion New Procedure**********/
---------------------------------------------------------------------
-- procedure initial_load_job_start
--
-- Starts the refresh process
-- 1.  Creates an oki_job_runs record
-- 2.  Loads the oki_job_run_dtl table with the records
--     to insert into the oki base tables.
---------------------------------------------------------------------

PROCEDURE initial_load_job_start
( x_errbuf          OUT NOCOPY VARCHAR2
, x_retcode         OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc            VARCHAR2(200) ;
  l_sqlcode        VARCHAR2(100) ;
  l_sqlerrm        VARCHAR2(1000) ;
  l_retcode        VARCHAR2(1) ;
  l_sequence       NUMBER := NULL ;
  l_sysdate        DATE   ;
  l_job_start_date DATE   ;
  l_table_name    VARCHAR2(30);
  l_table_owner   VARCHAR2(30);

  -- Cursor declaration
  CURSOR l_seq_num_csr IS
    SELECT oki_job_runs_s1.nextval seq
    FROM dual
    ;
  rec_l_seq_num l_seq_num_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;
  l_sysdate       := sysdate ;
  l_job_start_date := fnd_conc_date.string_to_date('1900/01/01');
  l_table_name    :='OKI_JOB_RUN_DTL' ;
  l_table_owner   := 'OKI';

     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Service Contracts Intelligence -  Initial load Started on:  ' ||
                                       fnd_date.date_to_displayDT(sysdate));
     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Parameter : start date               '|| fnd_date.date_to_displayDT(l_job_start_date));
     fnd_file.put_line(  which => fnd_file.log
                       , buff  => 'Parameter : end date                 '|| fnd_date.date_to_displayDT(l_sysdate));

   l_table_name := 'OKI_JOB_RUNS' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_table_name := 'OKI_JOB_RUN_DTL' ;
  l_loc := 'Calling truncate_table with ' || l_table_owner || '.' || l_table_name ;
  truncate_table( p_table_owner => l_table_owner
                , p_table_name  => l_table_name
                , x_errbuf      => x_errbuf
                , x_retcode     => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- Truncate failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;


  l_loc := 'Get job_runs_id sequence number.' ;

  OPEN l_seq_num_csr ;
  FETCH l_seq_num_csr INTO rec_l_seq_num ;
    -- unable to generate sequence number, exit immediately
    IF l_seq_num_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    l_sequence := rec_l_seq_num.seq ;
  CLOSE l_seq_num_csr ;

  l_loc := 'Inserting into oki_job_runs' ;

  INSERT INTO oki_job_runs (
           job_run_id
         , job_start_date
         , job_end_date
         , job_curr_start_date
         , job_curr_end_date
         , creation_date
         , created_by
         , last_update_date
         , last_updated_by
         , security_group_id
         , request_id
  ) values
          (  l_sequence
           , l_sysdate
           , NULL
           , l_job_start_date
           , l_sysdate
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , l_sysdate
           , FND_GLOBAL.USER_ID
           , NULL
           , g_request_id);

  COMMIT ;

  l_loc := 'Calling initial_load_job_run_dtl.' ;
  initial_load_job_run_dtl(
        p_job_run_id          => l_sequence
      , p_job_curr_start_date => l_job_start_date
      , p_job_curr_end_date   => l_sysdate
      , x_retcode             => l_retcode ) ;
  IF l_retcode = '2' THEN
    -- initial_load_job_run_dtl failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

EXCEPTION
  WHEN l_excp_exit_immediate THEN
    -- Set return code to error
    x_retcode := 2 ;

    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.job_start' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.job_start' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END initial_load_job_start;


/***11510 Change New Function to get the conversion rates for the contracts ***/
---------------------------------------------------------------------
-- Function get_conversion_rate
--
-- 1.  gets the latest conversion rate from GL_Daily_Rates given a
--     conversion date,From and To currency
-- Returns 0 if the conversion rates could not be found
-- Returns 1 if the from and to cirrency are same
-- Returns -1 if some error occurs during the calculation of the rate

---------------------------------------------------------------------
FUNCTION get_conversion_rate( p_curr_date  DATE
   		                     , p_from_currency IN VARCHAR2
	                         , p_to_currency   IN VARCHAR2
	               		    ) RETURN NUMBER
IS

l_conv_type   gl_daily_rates.conversion_type%TYPE;

CURSOR cur_currency_rate (p_curr_date Date,
                         p_from_currency varchar2,
                         p_to_currency varchar2)
 IS
 SELECT conversion_rate FROM gl_daily_rates
 WHERE from_currency = p_from_currency
 AND    to_currency = p_to_currency
 AND    conversion_date = (SELECT MAX (conversion_date)
                          FROM   gl_daily_rates
                          WHERE from_currency = p_from_currency
                          AND    to_currency = p_to_currency
                          AND    conversion_date <= p_curr_date
                          AND    conversion_type = l_conv_type)
AND    conversion_type = l_conv_type;

l_curr_rec              cur_currency_rate%ROWTYPE;

l_excp_exit_immediate   EXCEPTION;
l_rate                  NUMBER;
l_sqlcode               VARCHAR2(100);
l_sqlerrm               VARCHAR2(1000);
l_loc            VARCHAR2(200) ;


BEGIN
l_conv_type  := fnd_profile.value('OKI_DEFAULT_CONVERSION_TYPE');
 IF (p_from_currency =p_to_currency) THEN
  RETURN 1;
 END IF;

  l_loc := 'The from and to currencies are different..' ;

   OPEN cur_currency_rate (p_curr_date, p_from_currency, p_to_currency);
    FETCH cur_currency_rate INTO l_curr_rec;
   IF cur_currency_rate%NOTFOUND THEN
    RAISE l_excp_exit_immediate;
    END IF;
    l_rate:=l_curr_rec.conversion_rate;
   CLOSE cur_currency_rate;
 RETURN l_rate;

EXCEPTION
   WHEN l_excp_exit_immediate THEN
    IF cur_currency_rate%ISOPEN THEN
       CLOSE cur_currency_rate;
    END IF;
   RETURN 0;

    WHEN OTHERS THEN
     IF cur_currency_rate%ISOPEN THEN
       CLOSE cur_currency_rate;
     END IF;
      l_sqlcode := sqlcode;
      l_sqlerrm := sqlerrm;
     fnd_message.set_name(  application => 'OKI'
                          , name        => 'OKI_CONV_RATE_FAILURE' ) ;

     fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.get_conversion_rate' ) ;

     fnd_message.set_token(  token => 'FROM_CURRENCY'
                          , value => 'p_from_currency' ) ;

     fnd_message.set_token(  token => 'TO_CURRENCY'
                          , value => 'p_to_currency' ) ;

     fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
     fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
     fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
     fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;
     RETURN -1;
END;


---------------------------------------------------------------------
-- procedure job_end
--
-- Updates the job_end_date if it has not already been updated.
-- Cases where the job_end_date is not populated is:
-- 1.  Start of the job
-- 2.  Load fails when the oki base tables are being updated
---------------------------------------------------------------------
PROCEDURE job_end
( x_errbuf       OUT NOCOPY VARCHAR2
, x_retcode      OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc            VARCHAR2(200) ;
  l_sqlcode        VARCHAR2(100) ;
  l_sqlerrm        VARCHAR2(1000) ;
  l_retcode        VARCHAR2(1) ;
  l_job_run_id     NUMBER ;
  l_job_end_date   DATE ;

  -- Cursor to get the latest job_run_id
  CURSOR l_job_run_id_csr IS
    SELECT  jrn1.job_run_id, jrn1.job_end_date
    FROM oki_job_runs jrn1
    WHERE jrn1.job_run_id = ( SELECT MAX(jrn2.job_run_id)
                               FROM oki_job_runs jrn2)
    ;
  rec_l_job_run_id l_job_run_id_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;

  l_loc := 'Get latest job_run_id sequence number.' ;
  OPEN l_job_run_id_csr ;
  FETCH l_job_run_id_csr INTO rec_l_job_run_id ;
    -- unable to retrieve job_id, exit immediately
    IF l_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    l_job_run_id := rec_l_job_run_id.job_run_id ;
    l_job_end_date := rec_l_job_run_id.job_end_date ;
  CLOSE l_job_run_id_csr ;

  l_loc := 'Determining if job_end_date needs to be set.' ;
  IF l_job_end_date IS NULL THEN
    l_loc := 'Updating oki_job_runs.' ;
    UPDATE oki_job_runs jrn1
    SET job_end_date     = sysdate
      , last_update_date = sysdate
    WHERE job_run_id = l_job_run_id ;
  END IF ;

  COMMIT ;
EXCEPTION
  WHEN l_excp_exit_immediate THEN
    -- Set return code to error
    x_retcode := 2 ;

    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.job_end' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.job_end' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END job_end ;

---------------------------------------------------------------------
-- procedure process_refresh_check
--
-- Determines if the object has been refreshed or if it needs to be
-- refreshed
---------------------------------------------------------------------

PROCEDURE process_refresh_check
( p_object_name     IN  VARCHAR2
, x_job_run_id      OUT NOCOPY NUMBER
, x_process_yn      OUT NOCOPY VARCHAR2
, x_errbuf          OUT NOCOPY VARCHAR2
, x_retcode         OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;

  -- Location within the program before the error was encountered.
  l_loc            VARCHAR2(200) ;
  l_sqlcode        VARCHAR2(100) ;
  l_sqlerrm        VARCHAR2(1000) ;
  l_retcode        VARCHAR2(1) ;
  l_job_run_id     NUMBER ;
  l_rfh_job_run_id NUMBER ;

  -- Cursor to get the latest job_run_id
  CURSOR l_job_run_id_csr IS
    SELECT max(jrn.job_run_id) job_run_id
    FROM oki_job_runs jrn
    ;
  rec_l_job_run_id l_job_run_id_csr%ROWTYPE ;

  -- Cursor to get the job_run_id from the oki_refreshs table
  CURSOR l_rfh_job_run_id_csr
  ( p_object_name IN VARCHAR2
  ) IS
    SELECT rfh.job_run_id job_run_id
    FROM oki_refreshs rfh
    WHERE rfh.object_name = p_object_name
    ;
  rec_l_rfh_job_run_id l_rfh_job_run_id_csr%ROWTYPE ;

BEGIN
  l_retcode := '0' ;
  x_retcode := '0' ;
  x_process_yn := 'Y' ;

  l_loc := 'Get latest job_run_id sequence number.' ;
  OPEN l_job_run_id_csr ;
  FETCH l_job_run_id_csr INTO rec_l_job_run_id ;
    -- unable to retrieve job_id, exit immediately
    IF l_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    l_job_run_id := rec_l_job_run_id.job_run_id ;
  CLOSE l_job_run_id_csr ;

  l_loc := 'Get refresh job_run_id sequence number.' ;
  OPEN l_rfh_job_run_id_csr (p_object_name ) ;
  FETCH l_rfh_job_run_id_csr INTO rec_l_rfh_job_run_id ;
    -- unable to retrieve refresh job_run_id, exit immediately
    IF l_rfh_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_exit_immediate ;
    END IF ;
    l_rfh_job_run_id := rec_l_rfh_job_run_id.job_run_id ;
  CLOSE l_rfh_job_run_id_csr ;

  l_loc := p_object_name || ' has already been refreshed.' ;
  -- Refresh for this table has already been completed successfully
  -- since the job_run_id from the oki_job_run table equals the
  -- job_run_id from the oki_job_run_dtl table.
  IF l_job_run_id = l_rfh_job_run_id THEN
    raise l_excp_no_processing ;
  END IF ;

  l_loc := 'Getting job_id to process.' ;
  IF l_job_run_id > l_rfh_job_run_id THEN
    -- Refresh needs to be processed
    x_job_run_id := l_job_run_id ;
  END IF ;

EXCEPTION
  WHEN l_excp_no_processing then
    x_process_yn := 'N' ;
    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_OBJ_ALREADY_RFR_MSG') ;
    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => p_object_name ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get) ;

  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := 2 ;
    -- Log the location within the package where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE') ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => 'oki_refresh_pvt.process_refresh_check' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE') ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get) ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode ;
    l_sqlerrm := sqlerrm ;
    ROLLBACK ;
    x_retcode := '2' ;
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

    fnd_message.set_token(  token => 'OBJECT_NAME'
                          , value => 'oki_refresh_pvt.process_refresh_check' ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE' ) ;
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END process_refresh_check ;

---------------------------------------------------------------------
--
-- Procedure to refresh the latest conversion rates from
-- gl table to oki schema
--
---------------------------------------------------------------------
PROCEDURE refresh_daily_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS

    v_dummy                    varchar2(1);
--    l_conversion_type          gl_daily_rates.conversion_type%TYPE := 'Corporate';
    l_conversion_type          gl_daily_rates.conversion_type%TYPE ;
    l_no_update_refresh EXCEPTION;
    CURSOR c_conversion IS
       SELECT a.from_currency,
              a.to_currency,
              a.conversion_rate,
              a.conversion_date
       FROM   gl_daily_rates a
       WHERE (a.from_currency, a.to_currency, a.conversion_date) IN
                           ( SELECT b.from_currency, b.to_currency, MAX(b.conversion_date) conversion_date
                                    FROM   gl_daily_rates b
                                    WHERE  b.conversion_type = l_conversion_type
                                    GROUP BY b.from_currency, b.to_currency)
       AND  a.conversion_type = l_conversion_type;
BEGIN

   retcode := '0';
   l_conversion_type :=  fnd_profile.value('OKI_DEFAULT_CONVERSION_TYPE');
   /* For all distinct from and to currencies */
   FOR r_conversion IN c_conversion
   LOOP
      --dbms_output.put_line(r_conversion.from_currency || '  '|| r_conversion.to_currency);
      /* Update oki_daily_rates table with the latest conversion rates
         If no record is found in OKI table insert a new record       */
      UPDATE oki_daily_rates
      SET    conversion_rate = r_conversion.conversion_rate
           , conversion_date = r_conversion.conversion_date
      WHERE  from_currency   = r_conversion.from_currency
      AND    to_currency     = r_conversion.to_currency ;

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO oki_daily_rates
            (from_currency
           , to_currency
           , conversion_rate
           , conversion_date
            )
         VALUES
            (r_conversion.from_currency
           , r_conversion.to_currency
           , r_conversion.conversion_rate
           , r_conversion.conversion_date
         ) ;
      END IF ;
      /* Check and insert a record for the conversion rate between the same currency with a
         conversion rate of 1 */
      BEGIN
         SELECT 'x'
         INTO v_dummy
         FROM oki_daily_rates
         WHERE from_currency = r_conversion.from_currency
         AND to_currency     = r_conversion.from_currency ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --DBMS_OUTPUT.PUT_LINE('inserting conversion rate for same currency  ' || r_conversion.from_currency);
            INSERT INTO oki_daily_rates
               (from_currency
              , to_currency
              , conversion_rate
              , conversion_date
               )
            VALUES
               (r_conversion.from_currency
              , r_conversion.from_currency
              , 1
              , TRUNC(sysdate)
               ) ;
      END;
   END LOOP;
   -- Update oki_refresh
      update_oki_refresh(p_object_name => 'OKI_DAILY_RATES'
                        ,x_retcode => retcode);
  IF retcode = '2' THEN
    -- update_oki_refresh failed, exit immediately.
    RAISE  l_no_update_refresh;
  END IF ;

   -- analyze table
   fnd_stats.gather_table_stats(ownname=>'OKI' ,tabname=>'OKI_DAILY_RATES',percent=> 10);

   --DBMS_OUTPUT.PUT_LINE('End of the program...');
   fnd_message.set_name('OKI','OKI_TABLE_LOAD_SUCCESS');
   fnd_message.set_token('TABLE_NAME','OKI_DAILY_RATES');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
EXCEPTION
when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_DAILY_RATES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
	WHEN OTHERS THEN
           retcode := '2';
           fnd_file.put_line(fnd_file.log,sqlcode||' '||sqlerrm);

           fnd_message.set_name(application => 'OKI'
                               ,name => 'OKI_UNEXPECTED_FAILURE');
           fnd_message.set_token(token => 'OBJECT_NAME'
                                ,value => 'OKI_DAILY_RATES');
           fnd_file.put_line(which => fnd_file.log
                            ,buff => fnd_message.get);

           fnd_message.set_name(application => 'OKI'
                               ,name => 'OKI_TABLE_LOAD_FAILURE');
           fnd_message.set_token(token => 'TABLE_NAME'
                                ,value => 'OKI_DAILY_RATES');
           fnd_file.put_line(which => fnd_file.log
                            ,buff => fnd_message.get);
        ROLLBACK;
END  refresh_daily_rates;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_sales_k_hdrs
-- This procedure assumes the customer is always in HZ_PARTIES
-- for a sell contract
--
---------------------------------------------------------------------
--    11510 Changes to refresh/fast_sales_k_headers
--       1. Rules Migration
--       2. Denormalization of Tables
--            Logic of refresh_k_pricing_rules is migrated to refresh_sales_k_hdrs.
--       3. True Value
--       4. Currency Conversion
--       5. Removal of customer_name and customer_number
--            Customer_name and customer_number columns are not populated in the
--            table. Therefore, the logic to populate these columns is removed from
--            the procedure.
--       6. Removal of reference / joins to unnecessary tables
--            Major_version and minor_version columns are to be obsoleted
--                                  and join to the table okc_k_vers_numbers is removed.
PROCEDURE refresh_sales_k_hdrs(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY VARCHAR2) IS

  l_index_tab         vc_tab_type;
  l_sql_string        VARCHAR2(4000);
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  -- Application ID for OKS
  l_application_id    CONSTANT NUMBER := 515 ;

  -- variables to set up the fast refresh job
  l_job_run_id         NUMBER ;
  l_init_job_run_date  DATE ;
  l_sysdate            DATE := NULL ;

BEGIN
  retcode := '0';
  l_init_job_run_date := fnd_conc_date.string_to_date('1900/01/01');
  l_sysdate := sysdate ;

  -- get representative index storage parms for later use
  OPEN index_info_csr('OKI_SALES_K_HDRS','OKI_SALES_K_HDRS_N1','OKI');
  FETCH index_info_csr INTO l_ind_rec;
  CLOSE index_info_csr;
  l_errpos := 1;

  -- drop indexes
  OPEN index_name_csr('OKI_SALES_K_HDRS');
  FETCH index_name_csr BULK COLLECT INTO l_index_tab;
  CLOSE index_name_csr;

  IF l_index_tab.first IS NOT NULL THEN
    FOR i IN l_index_tab.first..l_index_tab.last LOOP
      l_sql_string := 'DROP INDEX OKI.'||l_index_tab(i);
      EXECUTE IMMEDIATE l_sql_string;
    END LOOP;
  END IF;

  l_errpos := 2;

  -- truncate table
  l_sql_string := 'TRUNCATE TABLE OKI.OKI_SALES_K_HDRS';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 3;

/*
  oki_refresh_pvt.ins_job_runs (
        p_job_start_date      => l_sysdate
      , p_job_end_date        => l_sysdate
      , p_job_curr_start_date => l_init_job_run_date
      , p_job_curr_end_date   => l_sysdate
      , p_job_run_id          => l_job_run_id
      , x_errbuf              => errbuf
      , x_retcode             => retcode ) ;
  IF retcode = '2' THEN
    -- ins_job_runs failed, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;
*/

  BEGIN
     select max(job_run_id)
     into l_job_run_id
     from oki_job_runs;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       retcode := '2';
       fnd_file.put_line(which => fnd_file.log
                         ,buff => 'For initial load please run Initial Job Start Set-up, Contracts Intelligence concurrent program first');

       RAISE l_excp_exit_immediate ;
  END;


  l_sql_string := 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE l_sql_string;

  l_sql_string := 'alter session set hash_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;
  l_sql_string := 'alter session set sort_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;

  l_errpos := 4;

  -- insert data
  INSERT /*+ append */ INTO oki_sales_k_hdrs
  (
   chr_id,
   contract_number,
   contract_number_modifier,
   complete_contract_number,
   order_number,
   authoring_org_id,
   organization_name,
   scs_code,
   sts_code,
   ste_code,
   customer_party_id,
   customer_name,
   customer_number,
   contract_amount,
   currency_code,
   contract_amount_renewed,
   currency_code_renewed,
   win_percent,
   forecast_amount,
   sob_id,
   sob_contract_amount,
   sob_forecast_amount,
   sob_contract_amount_renewed,
   sob_currency_code,
   base_contract_amount,
   base_forecast_amount,
   base_contract_amount_renewed,
   base_currency_code,
   close_date,
   start_date,
   end_date,
   duration,
   period,
   date_approved,
   date_signed,
   date_renewed,
   date_canceled,
   date_terminated,
   start_period_num,
   start_period_name,
   start_quarter,
   start_year,
   close_period_num,
   close_period_name,
   close_quarter,
   close_year,
   trn_code,
   inventory_organization_id,
   is_new_yn,
   is_latest_yn,
   orig_system_source_code,
   orig_system_id1,
   orig_system_reference1,
   contract_type,
   application_id,
   creation_date,
   last_update_date,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   major_version,
   minor_version,
/* 11510 Changes Start
Added the new columns from oki_pricing_rules and oki_qto
Also, terminated amount is now calculated during insertion */
   agreement_id,
   acct_rule_id,
   payment_term_id,
   inv_rule_id,
   list_header_id,
   grace_duration,
   grace_period_code,
   quote_to_contact_id,
   quote_to_site_id,
   quote_to_email_id,
   quote_to_phone_id,
   quote_to_fax_id,
   terminated_amount,
   sob_terminated_amount,
   base_terminated_amount
/*  11510 Changes End */
  )
  SELECT /*+ leading(khr) use_hash(khr, hoks,jrd,cpl, pty, sts,vnm , spd,spd1, ro, oh.oh, r.ol,og,terminated.okscle) */
       khr.id
      ,khr.contract_number
      ,khr.contract_number_modifier
      ,khr.contract_number ||
		 decode(khr.contract_number_modifier
				  , null, null, '-'|| khr.contract_number_modifier )
      ,oh.order_number
      ,khr.authoring_org_id
      ,NULL organization_name  -- 11510 Changes
      ,khr.scs_code
      ,khr.sts_code
      ,sts.ste_code
      ,to_number(cpl.object1_id1)
      ,NULL customer_name -- 11510 Changes
      ,NULL customer_number -- 11510 Changes
      ,khr.estimated_amount
      ,khr.currency_code
      ,null
      ,khr.currency_code_renewed
      ,hoks.est_rev_percent win_percent -- 11510 Changes
      ,((khr.estimated_amount * hoks.est_rev_percent ) / 100 ) -- 11510 Changes
      ,jrd.sob_id -- 11510 Changes
      ,(khr.estimated_amount * jrd.trx_func_rate) -- 11510 Changes
      ,(((khr.estimated_amount * jrd.trx_func_rate) * hoks.est_rev_percent ) / 100 ) -- 11510 Changes
      ,null
      ,jrd.func_currency -- 11510 Changes
      ,(khr.estimated_amount * jrd.trx_base_rate) -- 11510 Changes
      , (((khr.estimated_amount * jrd.trx_base_rate) * hoks.est_rev_percent) / 100 ) -- 11510 Changes
      ,null
      ,l_base_currency
      ,hoks.est_rev_date close_date -- 11510 Changes
      ,trunc(khr.start_date)
      ,trunc(khr.end_date)
      ,oki_disco_util_pub.get_duration(khr.start_date,khr.end_date)
      ,oki_disco_util_pub.get_period(khr.start_date,khr.end_date)
      ,trunc(khr.date_approved)
      ,trunc(khr.date_signed)
      ,trunc(khr.date_renewed)
      ,trunc(khr.datetime_cancelled)
      ,trunc(khr.date_terminated)
      ,spd.period_num
      ,spd.period_name
      ,spd.quarter_num
      ,spd.period_year
/*  11510 Changes Start */
      ,spd1.period_num
      ,spd1.period_name
      ,spd1.quarter_num
      ,spd1.period_year
/*  11510 Changes End */
      ,khr.trn_code
      ,khr.inv_organization_id
--      ,DECODE(r.is_new_yn,'Y','Y',NULL)
      ,DECODE( nvl(r.is_new_yn,'Y'),'Y','Y',NULL)
      , decode(khr.datetime_cancelled,null,null,'N')
      ,khr.orig_system_source_code
      ,khr.orig_system_id1
      ,khr.orig_system_reference1
      ,decode( nvl(r.is_new_yn,'Y'),'Y','NEW','REN')
      ,khr.application_id
      ,khr.creation_date
      ,khr.last_update_date -- 11510 Changes
      ,khr.attribute_category
      ,khr.attribute1
      ,khr.attribute2
      ,khr.attribute3
      ,khr.attribute4
      ,khr.attribute5
      ,khr.attribute6
      ,khr.attribute7
      ,khr.attribute8
      ,khr.attribute9
      ,khr.attribute10
      ,khr.attribute11
      ,khr.attribute12
      ,khr.attribute13
      ,khr.attribute14
      ,khr.attribute15
/*  11510 Changes Start */
      ,jrd.major_version major_version
      ,jrd.minor_version minor_version
      ,og.ISA_AGREEMENT_ID agreement_id        -- From oki_pricing_rules
      ,hoks.acct_rule_id
      ,khr.payment_term_id                     -- From oki_pricing_rules
      ,khr.inv_rule_id
      ,khr.price_list_id list_header_id        -- From oki_pricing_rules
      ,hoks.grace_duration                     -- From oki_pricing_rules
      ,hoks.grace_period                       -- From oki_pricing_rules
      ,hoks.quote_to_contact_id quote_to_contact_id    -- From oki_qto
      ,hoks.quote_to_site_id quote_to_site_id          -- From oki_qto
      ,hoks.quote_to_email_id quote_to_email_id        -- From oki_qto
      ,hoks.quote_to_phone_id quote_to_phone_id        -- From oki_qto
      ,hoks.quote_to_fax_id quote_to_fax_id            -- From oki_qto
      ,terminated.terminated_amount
      ,terminated.terminated_amount * jrd.trx_func_rate
      ,terminated.terminated_amount * jrd.trx_base_rate
/*  11510 Changes End */
    FROM
       okc_k_headers_b khr
      , oks_k_headers_b hoks -- 11510 Changes
      , oki_job_run_dtl jrd -- 11510 Changes
      , okc_k_party_roles_b cpl
      , okc_statuses_b sts
      , gl_periods spd
      , gl_periods spd1 -- 11510 Changes
      , okc_k_rel_objs ro
      , okx_order_headers_v oh
      , okc_governances og   -- 11510 Changes
      , (  SELECT ol.subject_chr_id, decode(count(1),0,'Y','N') is_new_yn
           FROM   okc_operation_lines ol
           WHERE  1 = 1
           AND    ol.object_chr_id is not null
           GROUP BY ol.subject_chr_id
         ) r
/*  11510 Changes Start */
      , (SELECT okscle.dnz_chr_id
              , SUM (NVL(ubt_amount,0) + NVL(credit_amount,0) +
                         NVL(suppressed_credit,0)) terminated_amount
         FROM   oks_k_lines_b okscle,okc_k_lines_b okccle
         WHERE   okccle.id = okscle.cle_id
         AND  okccle.price_level_ind='Y'
         GROUP BY okscle.dnz_chr_id
        ) terminated
/*  11510 Changes End */
  WHERE 1 = 1
      and khr.buy_or_sell             = 'S'
      and khr.template_yn             = 'N'
      and khr.application_id          = 515
      and cpl.rle_code                in ('CUSTOMER','LICENSEE','BUYER')
      and cpl.dnz_chr_id              = khr.id
      and cpl.cle_id                  IS NULL
      and sts.code                    = khr.sts_code
      and spd.period_set_name         = jrd.period_set_name
      and spd.period_type             = jrd.accounted_period_type
      and spd.adjustment_period_flag  = 'N'
      and khr.start_date              BETWEEN spd.start_date
				      AND spd.end_date+0.99999
/*  11510 Changes Start */
      and nvl(spd1.period_set_name,jrd.period_set_name)     = jrd.period_set_name
      and nvl(spd1.period_type,jrd.accounted_period_type)   = jrd.accounted_period_type
      and spd1.adjustment_period_flag(+) = 'N'
      and hoks.est_rev_date           BETWEEN spd1.start_date(+)
                                      AND spd1.end_date(+) + 0.99999
/*  11510 Changes End */
      and ro.chr_id (+)               = khr.id
      AND ro.jtot_object1_code (+)    = 'OKX_ORDERHEAD'
   /*Bug Fix 3675638
      AND ro.rty_code (+)             = 'CONTRACTSERVICESORDER'
   */
      AND oh.id1 (+)                  = ro.object1_id1
      AND r.subject_chr_id(+)         = khr.id
/*  11510 Changes Start */
      AND hoks.chr_id                 = khr.id
      AND og.chr_id(+)                = hoks.chr_id    -- From oki_pricing_rules
      AND jrd.chr_id                  = khr.id
      AND terminated.dnz_chr_id(+)    = khr.id
/*  11510 Changes End */
    ;
  COMMIT;

  l_errpos := 5;

/* 11510 Changes..

  UPDATE oki_sales_k_hdrs shd
  SET (close_period_num
      ,close_period_name
      ,close_quarter
      ,close_year) =
             (SELECT cpd.period_num
                    ,cpd.period_name
                    ,cpd.quarter_num
                    ,cpd.period_year
              FROM gl_periods cpd
                  ,gl_sets_of_books sob
              WHERE shd.close_date      between cpd.start_date and cpd.end_date+0.99999
                and cpd.period_type     = sob.accounted_period_type
                and cpd.period_set_name = sob.period_set_name
                and cpd.adjustment_period_flag  = 'N'
                and sob.set_of_books_id = shd.sob_id)
   WHERE shd.close_date IS NOT NULL
   ;
  COMMIT;

  l_errpos := 5.5;


  UPDATE oki_sales_k_hdrs shd
  SET (terminated_amount
       ,sob_terminated_amount
       ,base_terminated_amount) = (
                 SELECT -SUM(bcl.amount),
                        -SUM(bcl.amount) * shd.sob_contract_amount/ DECODE(shd.contract_amount,0,NULL,shd.contract_amount),
                        -SUM(bcl.amount) * shd.base_contract_amount/ DECODE(shd.contract_amount,0,NULL,shd.contract_amount)
                 FROM oks_bill_cont_lines bcl,
                      okc_k_lines_b cle
                 WHERE bcl.bill_action = 'TR'
                 AND  cle.id = bcl.cle_id
                 AND  cle.chr_id = shd.chr_id )
  WHERE shd.date_terminated IS NOT NULL;
  COMMIT;
*/
  l_errpos := 6;
  -- recreate indexes
  create_indicies(p_object_name => 'OKI_SALES_K_HDRS'
                    ,p_parm_rec => l_ind_rec);

  /* Fetches distinct qualifiers before issuing update with subquery. */
  l_errpos := 6.25;
  -- analyze table
  fnd_stats.gather_table_stats(ownname => 'OKI'
                              ,tabname => 'OKI_SALES_K_HDRS',percent=> 10);

  l_errpos := 7;

   -- alter table back
   l_sql_string := 'ALTER TABLE OKI.OKI_SALES_K_HDRS NOPARALLEL';
   EXECUTE IMMEDIATE l_sql_string;
   l_errpos := 8;

  -- update oki_refreshes
  update_oki_refresh(  p_object_name => 'OKI_SALES_K_HDRS'
                     , p_job_run_id  => l_job_run_id
                     , x_retcode     => retcode);
   COMMIT;
  IF retcode = '2' THEN
    -- update_oki_refresh failed, exit immediately.
    RAISE l_no_update_refresh;
  END IF;


  l_errpos := 10;

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_SALES_K_HDRS');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);
  l_errpos := 11;

EXCEPTION
when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SALES_K_HDRS');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_SALES_K_HDRS');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode || ' ' || l_sqlerrm);
     -- try to get indexes back
     IF l_errpos < 6 THEN
       create_indicies(p_object_name => 'OKI_SALES_K_HDRS'
                       ,p_parm_rec => l_ind_rec);
     ELSIF(l_errpos = 6 ) THEN
       -- truncate table
       l_sql_string := 'TRUNCATE TABLE OKI.OKI_SALES_K_HDRS';
       EXECUTE IMMEDIATE l_sql_string;
     END IF;

END refresh_sales_k_hdrs;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_sales_k_hdrs without a
-- complete refresh.  This procedure assumes the customer is always
-- in HZ_PARTIES for a sell contract
--
---------------------------------------------------------------------
PROCEDURE fast_sales_k_hdrs
(  x_errbuf  OUT NOCOPY VARCHAR2
 , x_retcode OUT NOCOPY VARCHAR2 ) IS


  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  l_index_tab         vc_tab_type;
  l_sql_string        VARCHAR2(4000);
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;
  -- Application ID for OKS
  l_application_id    CONSTANT NUMBER := 515 ;

  -- Location within the program before the error was encountered.
  l_loc                 VARCHAR2(200) ;
  l_retcode             VARCHAR2(1) ;
  l_process_yn          VARCHAR2(1) ;
  l_job_run_id          NUMBER ;
  l_job_curr_start_date DATE ;
  l_job_curr_end_date   DATE ;
  l_table_name          VARCHAR2(30)  ;

BEGIN
  l_retcode := '0' ;
  l_table_name := 'OKI_SALES_K_HDRS';
  l_loc := 'Calling process_refresh_check.' ;

  process_refresh_check(
        p_object_name => l_table_name
      , x_job_run_id  => l_job_run_id
      , x_process_yn  => l_process_yn
      , x_errbuf      => x_errbuf
      , x_retcode     => l_retcode ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  =>  'Job-run-id'||to_char(l_job_run_id)) ;


  l_loc := 'Determining status of process_refresh_check.' ;
  IF l_retcode = '2' THEN
    -- No job_run_id, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Checking if records have already been processed.' ;


  IF l_process_yn = 'N' THEN
    RAISE l_excp_no_processing ;
  END IF ;


  l_loc := 'Calling get_load_date_range.' ;
  get_load_date_range(
      p_job_run_id          => l_job_run_id
    , p_job_curr_start_date => l_job_curr_start_date
    , p_job_curr_end_date   => l_job_curr_end_date
    , x_errbuf              => x_errbuf
    , x_retcode             => l_retcode ) ;
  l_loc := 'Determining status of  get_load_date_range' ;
  IF l_retcode = '2' THEN
    -- No job_curr_date range values, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Deleting from ' || l_table_name ;
  DELETE FROM oki_sales_k_hdrs shd
  WHERE chr_id in ( SELECT /*+ index_ffs(jrd oki_job_run_dtl_u1)*/
                    jrd.chr_id
                    FROM oki_job_run_dtl jrd
                    WHERE jrd.job_run_id  = l_job_run_id ) ;


  l_loc := 'Populating Table oki_sales_k_hdrs ' ;
  INSERT  INTO oki_sales_k_hdrs (
          chr_id
        , contract_number
        , contract_number_modifier
        , complete_contract_number
	   , order_number
        , authoring_org_id
        , organization_name
        , scs_code
        , sts_code
        , ste_code
        , customer_party_id
        , customer_name
        , customer_number
        , contract_amount
        , currency_code
        , contract_amount_renewed
        , currency_code_renewed
        , win_percent
        , forecast_amount
        , sob_id
        , sob_contract_amount
        , sob_forecast_amount
        , sob_contract_amount_renewed
        , sob_currency_code
        , base_contract_amount
        , base_forecast_amount
        , base_contract_amount_renewed
        , base_currency_code
        , close_date
        , start_date
        , end_date
    	, duration
    	, period
        , date_approved
        , date_signed
        , date_renewed
        , date_canceled
        , date_terminated
        , start_period_num
        , start_period_name
        , start_quarter
        , start_year
        , close_period_num
        , close_period_name
        , close_quarter
        , close_year
        , trn_code
        , inventory_organization_id
        , is_new_yn
        , is_latest_yn
        , orig_system_source_code
        , orig_system_id1
        , orig_system_reference1
        , contract_type
        , application_id
        , creation_date
        , last_update_date
        , attribute_category
        , attribute1
        , attribute2
        , attribute3
        , attribute4
        , attribute5
        , attribute6
        , attribute7
        , attribute8
        , attribute9
        , attribute10
        , attribute11
        , attribute12
        , attribute13
        , attribute14
        , attribute15
        , major_version
        , minor_version
/* 11510 Changes Start
Added the new columns from oki_pricing_rules and oki_qto
Also, terminated amount is now calculated during insertion */
        , agreement_id             -- From oki_pricing_rule
        , acct_rule_id
        , payment_term_id          -- From oki_pricing_rule
        , inv_rule_id
        , list_header_id           -- From oki_pricing_rule
        , grace_duration           -- From oki_pricing_rule
        , grace_period_code        -- From oki_pricing_rule
        , quote_to_contact_id           -- From oki_qto
        , quote_to_site_id              -- From oki_qto
        , quote_to_email_id             -- From oki_qto
        , quote_to_phone_id             -- From oki_qto
        , quote_to_fax_id               -- From oki_qto
        , terminated_amount
        , sob_terminated_amount
        , base_terminated_amount
/*  11510 Changes End */
  ) SELECT /*+ leading(jrd) full(jrd) cardinality(jrd,1) use_nl(r) */
        khr.id
      , khr.contract_number
      , khr.contract_number_modifier
      , khr.contract_number || decode(khr.contract_number_modifier
                  ,null, null
                  ,'-' || khr.contract_number_modifier )
      , oh.order_number
      , khr.authoring_org_id
      , NULL organization_name -- 11510 Changes
      , khr.scs_code
      , khr.sts_code
      , sts.ste_code
      , to_number(cpl.object1_id1)
      , NULL customer_name -- 11510 Changes
      , NULL customer_number -- 11510 Changes
      , khr.estimated_amount
      , khr.currency_code
      , khr.estimated_amount_renewed
      , khr.currency_code_renewed
      , hoks.est_rev_percent win_percent  -- 11510 Changes
      , ((khr.estimated_amount * hoks.est_rev_percent ) / 100 )  -- 11510 Changes
      , jrd.sob_id  -- 11510 Changes
      , (khr.estimated_amount * jrd.trx_func_rate)  -- 11510 Changes
      ,(((khr.estimated_amount * jrd.trx_func_rate) * hoks.est_rev_percent ) / 100 )  -- 11510 Changes
      , NULL
      , jrd.func_currency  -- 11510 Changes
      , (khr.estimated_amount * jrd.trx_base_rate)  -- 11510 Changes
      , (((khr.estimated_amount * jrd.trx_base_rate) * hoks.est_rev_percent) / 100 )  -- 11510 Changes
      , NULL
      , l_base_currency
      , hoks.est_rev_date close_date  -- 11510 Changes
      , TRUNC(khr.start_date)
      , TRUNC(khr.end_date)
	 , oki_disco_util_pub.get_duration(khr.start_date,khr.end_date)
	 , oki_disco_util_pub.get_period(khr.start_date,khr.end_date)
      , TRUNC(khr.date_approved)
      , TRUNC(khr.date_signed)
      , TRUNC(khr.date_renewed)
      , TRUNC(khr.datetime_cancelled)
      , TRUNC(khr.date_terminated)
      , spd.period_num
      , spd.period_name
      , spd.quarter_num
      , spd.period_year
/*  11510 Changes Start */
      ,spd1.period_num
      ,spd1.period_name
      ,spd1.quarter_num
      ,spd1.period_year
/*  11510 Changes End */
      , khr.trn_code
      , khr.inv_organization_id
      , decode( nvl(r.is_new_yn,'Y'),'Y','Y',null) is_new_yn
      , decode(khr.datetime_cancelled,null,null,'N') is_latest_yn
      , khr.orig_system_source_code
      , khr.orig_system_id1
      , khr.orig_system_reference1
      , decode( nvl(r.is_new_yn,'Y'),'Y','NEW','REN') ren_type
      , khr.application_id
      , khr.creation_date
      , khr.last_update_date
      , khr.attribute_category
      , khr.attribute1
      , khr.attribute2
      , khr.attribute3
      , khr.attribute4
      , khr.attribute5
      , khr.attribute6
      , khr.attribute7
      , khr.attribute8
      , khr.attribute9
      , khr.attribute10
      , khr.attribute11
      , khr.attribute12
      , khr.attribute13
      , khr.attribute14
      , khr.attribute15
/*  11510 Changes Start */
      , jrd.major_version major_version
      , jrd.minor_version minor_version
      , og.ISA_AGREEMENT_ID agreement_id        -- From oki_pricing_rules
      , hoks.acct_rule_id
      , khr.payment_term_id                     -- From oki_pricing_rules
      , khr.inv_rule_id
      , khr.price_list_id list_header_id        -- From oki_pricing_rules
      , hoks.grace_duration                     -- From oki_pricing_rules
      , hoks.grace_period                       -- From oki_pricing_rules
      , hoks.quote_to_contact_id quote_to_contact_id    -- From oki_qto
      , hoks.quote_to_site_id quote_to_site_id          -- From oki_qto
      , hoks.quote_to_email_id quote_to_email_id        -- From oki_qto
      , hoks.quote_to_phone_id quote_to_phone_id        -- From oki_qto
      , hoks.quote_to_fax_id quote_to_fax_id            -- From oki_qto
      , terminated.terminated_amount
      , terminated.terminated_amount * jrd.trx_func_rate
      , terminated.terminated_amount * jrd.trx_base_rate
/*  11510 Changes End */
    FROM
        oki_job_run_dtl jrd
      , okc_k_headers_b khr
      , oks_k_headers_b hoks -- 11510 Changes
      , okc_k_party_roles_b cpl
      , okc_statuses_b sts
      , gl_periods spd
      , gl_periods spd1 -- 11510 Changes
      , okc_k_rel_objs ro
      , okx_order_headers_v oh
      , okc_governances og        -- From oki_pricing_rule
      , (  SELECT /*+ leading(jrd) full(jrd) cardinality(jrd,1)*/
           ol.subject_chr_id, decode(count(1),0,'Y','N') is_new_yn
           FROM   okc_operation_lines ol,  oki_job_run_dtl jrd
           WHERE  1 = 1
           AND   jrd.job_run_id              = l_job_run_id
           AND   jrd.action_flag             = 'I'
           AND   ol.subject_chr_id           = jrd.chr_id
           AND   ol.object_chr_id            is not null
           GROUP by ol.subject_chr_id
        ) r
/*  11510 Changes Start */
       ,(SELECT okscle.dnz_chr_id  /*+ leading(jrd) full(jrd) cardinality(jrd,1)*/
              , SUM (NVL(ubt_amount,0) + NVL(credit_amount,0) +
                         NVL(suppressed_credit,0)) terminated_amount
         FROM  oks_k_lines_b okscle,okc_k_lines_b okccle,oki_job_run_dtl jrd
	     WHERE okccle.id = okscle.cle_id
         AND   okscle.dnz_chr_id = jrd.chr_id
         AND   jrd.job_run_id    = l_job_run_id
         AND   jrd.action_flag   = 'I'
         AND   okccle.price_level_ind='Y'
         GROUP BY okscle.dnz_chr_id
        ) terminated
/*  11510 Changes End */
    WHERE 1 = 1
    AND   jrd.job_run_id              = l_job_run_id
    AND   jrd.action_flag             = 'I'
    AND   khr.id                      = jrd.chr_id
    AND   cpl.rle_code                in ('CUSTOMER','LICENSEE','BUYER')
    AND   cpl.dnz_chr_id              = khr.id
    AND   cpl.cle_id                  IS NULL
    AND   sts.code                    = khr.sts_code
    AND   spd.period_set_name         = jrd.period_set_name
    AND   spd.period_type             = jrd.accounted_period_type
    AND   spd.adjustment_period_flag  = 'N'
    AND   khr.start_date              BETWEEN spd.start_date
                                          AND spd.end_date + 0.99999
/*  11510 Changes Start */
    AND nvl(spd1.period_set_name,jrd.period_set_name)     = jrd.period_set_name
    AND nvl(spd1.period_type,jrd.accounted_period_type)   = jrd.accounted_period_type
    AND spd1.adjustment_period_flag(+) = 'N'
    AND hoks.est_rev_date           BETWEEN spd1.start_date(+)
                                      AND spd1.end_date(+) + 0.99999
/*  11510 Changes End */
    AND   ro.chr_id(+)                = jrd.chr_id
    AND   ro.jtot_object1_code (+)    = 'OKX_ORDERHEAD'
/* Bug Fix 3675638
    AND   ro.rty_code (+)             = 'CONTRACTSERVICESORDER'
    */
    AND   oh.id1 (+)                  = ro.object1_id1
    AND   r.subject_chr_id(+)         = khr.id
/*  11510 Changes Start */
    AND   hoks.chr_id                 = khr.id
    AND   og.chr_id(+)                = hoks.chr_id    -- From oki_pricing_rule
    AND   terminated.dnz_chr_id(+)    = khr.id;
/*  11510 Changes End */


/*
  l_loc := 'Updating Table  oki_sales_k_hdrs  with forecast period details ' ;
  UPDATE oki_sales_k_hdrs shd
  SET (close_period_num
      ,close_period_name
      ,close_quarter
      ,close_year) =
             (SELECT cpd.period_num
                    ,cpd.period_name
                    ,cpd.quarter_num
                    ,cpd.period_year
              FROM gl_periods cpd
                  ,gl_sets_of_books sob
              WHERE shd.close_date      between cpd.start_date and cpd.end_date+0.99999
                and cpd.period_type     = sob.accounted_period_type
                and cpd.period_set_name = sob.period_set_name
                and cpd.adjustment_period_flag  = 'N'
                and sob.set_of_books_id = shd.sob_id)
  WHERE shd.chr_id IN (
    SELECT chr_id
    FROM   oki_job_run_dtl jrd
    WHERE 1 = 1
    AND   jrd.job_run_id              = l_job_run_id
    AND   jrd.action_flag             = 'I'
                       )
    AND shd.close_date IS NOT NULL;
  COMMIT;

  l_loc := 'Updating Table  oki_sales_k_hdrs  with termination amount details ' ;


  UPDATE oki_sales_k_hdrs shd
  SET (terminated_amount
       ,sob_terminated_amount
       ,base_terminated_amount) = (
                 SELECT -SUM(bcl.amount),
                        -SUM(bcl.amount) * shd.sob_contract_amount/ DECODE(shd.contract_amount,0,NULL,shd.contract_amount),
                        -SUM(bcl.amount) * shd.base_contract_amount/ DECODE(shd.contract_amount,0,NULL,shd.contract_amount)
                 FROM oks_bill_cont_lines bcl,
                      okc_k_lines_b cle
                 WHERE bcl.bill_action = 'TR'
                 AND  cle.id = bcl.cle_id
                 AND  cle.chr_id = shd.chr_id )
  WHERE shd.date_terminated IS NOT NULL
  AND   shd.chr_id IN (
              SELECT  chr_id
              FROM   oki_job_run_dtl jrd
              WHERE 1 = 1
              AND   jrd.job_run_id              = l_job_run_id
              AND   jrd.action_flag             = 'I'
                       );

  COMMIT;
*/

  l_loc := 'Updating OKI_REFRESHS.' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;

  COMMIT ;
  IF l_retcode = 2 THEN
  	RAISE l_no_update_refresh;
  END IF;
  l_loc := 'Analyzing ' || l_table_name ;
  -- analyze table
  fnd_stats.gather_table_stats( ownname => 'OKI'
                              , tabname => l_table_name
                              , percent => 10 ) ;

  fnd_message.set_name( application => 'OKI'
                      , name        => 'OKI_TABLE_LOAD_SUCCESS' ) ;
  fnd_message.set_token( token => 'TABLE_NAME'
                       , value => l_table_name ) ;
  fnd_file.put_line( which => fnd_file.log
                   , buff  => fnd_message.get ) ;

EXCEPTION
  WHEN l_excp_no_processing then
    -- Do not log an error ;  It has already been logged.
    -- Just exit the program and continue with the other table load
    null ;

  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;

  WHEN l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SALES_K_HDRS');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    x_retcode := '2';

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_SALES_K_HDRS' ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    -- Log the location within the procedure where the error occurred
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_LOC_IN_PROG_FAILURE');
    fnd_message.set_token(  token => 'LOCATION'
                          , value => l_loc ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END fast_sales_k_hdrs ;

---------------------------------------------------------------------
--
-- load address (bill to, ship to) information
--
-- Since the address can come from any number of places, such as
-- account site uses, party site uses, party sites, it must determine
-- the source view dynamically from jtf_objects.
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

PROCEDURE refresh_addrs(errbuf OUT NOCOPY VARCHAR2
                       ,retcode OUT NOCOPY VARCHAR2) IS

  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END refresh_addrs;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_addresses without a complete
-- refresh
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

PROCEDURE fast_addrs
( x_errbuf  OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2 ) IS

  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

end fast_addrs ;

---------------------------------------------------------------------
--
-- procedure to load the sold item lines table
--
---------------------------------------------------------------------
--     11510 Changes to refresh/fast_sold_itm_lines
--        1. Rules Migration
--        2. Denormalization of Tables
--             Logic of refresh_addrs is migrated to refresh_sold_itm_lines.
--        3. True Value
--        4. Currency Conversion
--             OKI currently uses only two object types for  top line level WARRANTY
--             and SERVICE. The join to oks_line_style_sources should be removed and
--             hard coded with OKX_SERVICE and OKX_WARRANTY
procedure refresh_sold_itm_lines(errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY VARCHAR2) IS
  -- Exception to immediately exit the procedure
  l_excp_no_job_run_id   EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  l_index_tab         vc_tab_type;
  l_sql_string        VARCHAR2(4000);
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;

  -- variables to set up the fast refresh job
  l_job_run_id         NUMBER ;

BEGIN
  retcode := '0';

  -- get representative index storage parms for later use
  OPEN index_info_csr('OKI_SOLD_ITM_LINES','OKI_SOLD_ITM_LINES_U1','OKI');
  FETCH index_info_csr INTO l_ind_rec;
  CLOSE index_info_csr;
  l_errpos := 1;

  -- drop indexes
  OPEN index_name_csr('OKI_SOLD_ITM_LINES');
  FETCH index_name_csr BULK COLLECT INTO l_index_tab;
  CLOSE index_name_csr;

  IF l_index_tab.first IS NOT NULL THEN
    FOR i IN l_index_tab.first..l_index_tab.last LOOP
      l_sql_string := 'DROP INDEX OKI.'||l_index_tab(i);
      EXECUTE IMMEDIATE l_sql_string;
    END LOOP;
  END IF;
  l_errpos := 2;

  -- truncate table
  l_sql_string := 'TRUNCATE TABLE OKI.OKI_SOLD_ITM_LINES';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 3;

  l_sql_string := 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 4;

  l_sql_string := 'alter session set hash_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;
  l_sql_string := 'alter session set sort_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;

  -- insert data
  INSERT /*+ append */ INTO OKI_SOLD_ITM_LINES
  (
   CLE_ID,
   CHR_ID,
   CONTRACT_NUMBER,
   CONTRACT_NUMBER_MODIFIER,
   COMPLETE_CONTRACT_NUMBER,
   SCS_CODE,
   LINE_NUMBER,
   START_DATE,
   END_DATE,
   DURATION,
   PERIOD,
   STS_CODE,
   ste_code,
   TRN_CODE,
   DATE_TERMINATED,
   DATE_RENEWED,
   NUMBER_OF_ITEMS,
   UOM_CODE,
   UNIT_PRICE,
   UNIT_PRICE_PERCENT,
   PRICE_NEGOTIATED,
   CURRENCY_CODE,
   PRICE_NEGOTIATED_RENEWED,
   CURRENCY_CODE_RENEWED,
   SOB_PRICE_UNIT,
   SOB_PRICE_NEGOTIATED,
   SOB_PRICE_NEGOTIATED_RENEWED,
   SOB_CURRENCY_CODE,
   BASE_PRICE_UNIT,
   BASE_PRICE_NEGOTIATED,
   BASE_PRICE_NEGOTIATED_RENEWED,
   BASE_CURRENCY_CODE,
   SOLD_ITEM,
   ITEM_ID,
   CONCATENATED_SEGMENTS,
   AUTHORING_ORG_ID,
   INVENTORY_ORGANIZATION_ID,
   CREATION_DATE,
   LAST_UPDATE_DATE,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1,
   ATTRIBUTE2,
   ATTRIBUTE3,
   ATTRIBUTE4,
   ATTRIBUTE5,
   ATTRIBUTE6,
   ATTRIBUTE7,
   ATTRIBUTE8,
   ATTRIBUTE9,
   ATTRIBUTE10,
   ATTRIBUTE11,
   ATTRIBUTE12,
   ATTRIBUTE13,
   ATTRIBUTE14,
   ATTRIBUTE15,
   BILL_TO_SITE_USE_ID,  -- 11510 Changes
   SHIP_TO_SITE_USE_ID   -- 11510 Changes
  )
  SELECT
     cle.id
    ,shd.chr_id
    ,shd.contract_number
    ,shd.contract_number_modifier
    ,shd.complete_contract_number
    ,shd.scs_code
    ,cle.line_number
    ,trunc(cle.start_date)
    ,trunc(cle.end_date)
    ,oki_disco_util_pub.get_duration(cle.start_date,cle.end_date)
    ,oki_disco_util_pub.get_period(cle.start_date,cle.end_date)
    ,cle.sts_code
    ,sts.ste_code
    ,cle.trn_code
    ,trunc(cle.date_terminated)
    ,trunc(cle.date_renewed)
    ,cim.number_of_items
    ,cim.uom_code
    ,cle.price_unit
    ,cle.price_unit_percent
    ,cle.price_negotiated
    ,shd.currency_code
    ,cle.price_negotiated_renewed
    ,cle.currency_code_renewed
    ,(cle.price_unit * jrd.trx_func_rate) -- 11510 Changes
    ,(cle.price_negotiated * jrd.trx_func_rate) -- 11510 Changes
    ,null
    ,shd.sob_currency_code
    ,(cle.price_unit * jrd.trx_base_rate) -- 11510 Changes
    ,(cle.price_negotiated * jrd.trx_base_rate) -- 11510 Changes
    ,null
    ,l_base_currency
    , null
    ,cim.object1_id1
    , null
    ,shd.authoring_org_id
    ,cim.object1_id2
    ,cle.creation_date
    ,cle.last_update_date
    ,cle.attribute_category
    ,cle.attribute1
    ,cle.attribute2
    ,cle.attribute3
    ,cle.attribute4
    ,cle.attribute5
    ,cle.attribute6
    ,cle.attribute7
    ,cle.attribute8
    ,cle.attribute9
    ,cle.attribute10
    ,cle.attribute11
    ,cle.attribute12
    ,cle.attribute13
    ,cle.attribute14
    ,cle.attribute15
    ,cle.bill_to_site_use_id -- 11510 Changes
    ,cle.ship_to_site_use_id -- 11510 Changes
  FROM
     okc_k_lines_b cle
    ,oki_sales_k_hdrs shd
    ,okc_k_items cim
    ,okc_statuses_b sts
    ,oki_job_run_dtl jrd -- 11510 Changes
  WHERE 1=1
    and cim.cle_id            = cle.id
    and sts.code              = cle.sts_code
    and cle.chr_id            is not null
    and cle.dnz_chr_id        = shd.chr_id
    and jrd.chr_id            = shd.chr_id -- 11510 Changes
    and cim.jtot_object1_code IN ('OKX_SERVICE','OKX_WARRANTY') -- 11510 Changes
    and cle.lse_id            IN (1,19,14) -- 11510 Changes
  ;
  COMMIT;
  l_errpos := 5;

  -- recreate indexes
  create_indicies(p_object_name => 'OKI_SOLD_ITM_LINES'
                 ,p_parm_rec => l_ind_rec);
  l_errpos := 6;


  OPEN g_latest_job_run_id_csr ;
  FETCH g_latest_job_run_id_csr INTO rec_g_latest_job_run_id_csr ;
    IF g_latest_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_no_job_run_id ;
    END IF ;
    l_job_run_id := rec_g_latest_job_run_id_csr.job_run_id ;
  CLOSE g_latest_job_run_id_csr ;

  -- update oki_refreshes
  update_oki_refresh(   p_object_name => 'OKI_SOLD_ITM_LINES'
                      , p_job_run_id  => l_job_run_id
                      , x_retcode     => retcode ) ;
  COMMIT ;
  IF retcode = '2' THEN
    -- update_oki_refresh failed, exit immediately.
    RAISE l_no_update_refresh;
  END IF ;
  l_errpos := 8;

  -- analyze table
  fnd_stats.gather_table_stats(ownname => 'OKI'
                              ,tabname => 'OKI_SOLD_ITM_LINES',percent=> 10);
  l_errpos := 9;

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_SOLD_ITM_LINES');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);

EXCEPTION
	  WHEN l_excp_no_job_run_id THEN
    ROLLBACK;
    retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_SOLD_ITM_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);

    fnd_message.set_name(  application => 'OKI'
                         , name => 'OKI_NO_JOB_RUN_ID_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);

  WHEN l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_SOLD_ITM_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode||' '||l_sqlerrm);
    IF l_errpos < 5 THEN
      create_indicies(p_object_name => 'OKI_SOLD_ITM_LINES'
                      ,p_parm_rec => l_ind_rec);
    ELSIF l_errpos = 5 THEN
      -- truncate table
      l_sql_string := 'TRUNCATE TABLE OKI.OKI_SOLD_ITM_LINES';
      EXECUTE IMMEDIATE l_sql_string;
    END IF;

END refresh_sold_itm_lines;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_sold_itm_lines without a complete
-- refresh
--
---------------------------------------------------------------------
procedure fast_sold_itm_lines
(  x_errbuf  OUT NOCOPY VARCHAR2
 , x_retcode OUT NOCOPY VARCHAR2 ) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  l_sqlcode           VARCHAR2(100) ;
  l_sqlerrm           VARCHAR2(1000) ;
  l_errpos            NUMBER := 0 ;
  -- Location within the program before the error was encountered.
  l_loc                 VARCHAR2(200) ;
  l_retcode             VARCHAR2(1) ;
  l_process_yn          VARCHAR2(1) ;
  l_job_run_id          NUMBER ;
  l_job_curr_start_date DATE ;
  l_job_curr_end_date   DATE ;
  l_table_name          VARCHAR2(30) ;

BEGIN
  l_retcode := '0' ;
  l_table_name := 'OKI_SOLD_ITM_LINES' ;

  l_loc := 'Calling process_refresh_check.' ;
  process_refresh_check(
        p_object_name => l_table_name
      , x_job_run_id  => l_job_run_id
      , x_process_yn  => l_process_yn
      , x_errbuf      => x_errbuf
      , x_retcode     => l_retcode ) ;
  l_loc := 'Determining status of process_refresh_check.' ;
  IF l_retcode = '2' THEN
    -- No job_run_id, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Checking if records have already been processed.' ;
  IF l_process_yn = 'N' THEN
    -- Object has been refreshed successfully.
    RAISE l_excp_no_processing ;
  END IF ;

  l_loc := 'Calling get_load_date_range.' ;
  get_load_date_range(
      p_job_run_id          => l_job_run_id
    , p_job_curr_start_date => l_job_curr_start_date
    , p_job_curr_end_date   => l_job_curr_end_date
    , x_errbuf              => x_errbuf
    , x_retcode             => l_retcode ) ;
  l_loc := 'Determining status of get_load_date_range' ;
  IF l_retcode = '2' THEN
    -- No job_curr_date range values, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Deleting from ' || l_table_name ;
  DELETE FROM oki_sold_itm_lines sil
  WHERE chr_id in ( SELECT jrd.chr_id
                    FROM oki_job_run_dtl jrd
                    WHERE jrd.job_run_id  = l_job_run_id ) ;

  l_loc := 'Inserting into ' || l_table_name ;
  -- insert data
  INSERT INTO oki_sold_itm_lines(
           cle_id
         , chr_id
         , contract_number
         , contract_number_modifier
         , complete_contract_number
         , scs_code
         , line_number
         , start_date
         , end_date
	 , duration
	 , period
         , sts_code
         , ste_code
         , trn_code
         , date_terminated
         , date_renewed
         , number_of_items
         , uom_code
         , unit_price
         , unit_price_percent
         , price_negotiated
         , currency_code
         , price_negotiated_renewed
         , currency_code_renewed
         , sob_price_unit
         , sob_price_negotiated
         , sob_price_negotiated_renewed
         , sob_currency_code
         , base_price_unit
         , base_price_negotiated
         , base_price_negotiated_renewed
         , base_currency_code
         , sold_item
         , item_id
         , concatenated_segments
         , authoring_org_id
         , inventory_organization_id
         , creation_date
         , last_update_date
         , attribute_category
         , attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , bill_to_site_use_id  -- 11510 Changes
         , ship_to_site_use_id  -- 11510 Changes
  ) SELECT
             cle.id
           , shd.chr_id
           , shd.contract_number
           , shd.contract_number_modifier
           , shd.complete_contract_number
           , shd.scs_code
           , cle.line_number
           , TRUNC(cle.start_date)
           , TRUNC(cle.end_date)
	   , oki_disco_util_pub.get_duration(cle.start_date,cle.end_date)
	   , oki_disco_util_pub.get_period(cle.start_date,cle.end_date)
           , cle.sts_code
           , sts.ste_code
           , cle.trn_code
           , TRUNC(cle.date_terminated)
           , TRUNC(cle.date_renewed)
           , cim.number_of_items
           , cim.uom_code
           , cle.price_unit
           , cle.price_unit_percent
           , cle.price_negotiated
           , shd.currency_code
           , cle.price_negotiated_renewed
           , cle.currency_code_renewed
           , (cle.price_unit * jrd.trx_func_rate) -- 11510 Changes
           , (cle.price_negotiated * jrd.trx_func_rate) -- 11510 Changes
           , null
           , shd.sob_currency_code
           , (cle.price_unit * jrd.trx_base_rate) -- 11510 Changes
           , (cle.price_negotiated * jrd.trx_base_rate) -- 11510 Changes
           , null
           , l_base_currency
           , null
           , cim.object1_id1
           , null
           , shd.authoring_org_id
           , cim.object1_id2
           , cle.creation_date
           , cle.last_update_date
           , cle.attribute_category
           , cle.attribute1
           , cle.attribute2
           , cle.attribute3
           , cle.attribute4
           , cle.attribute5
           , cle.attribute6
           , cle.attribute7
           , cle.attribute8
           , cle.attribute9
           , cle.attribute10
           , cle.attribute11
           , cle.attribute12
           , cle.attribute13
           , cle.attribute14
           , cle.attribute15
           , cle.bill_to_site_use_id -- 11510 Changes
           , cle.ship_to_site_use_id -- 11510 Changes
    FROM
           okc_k_lines_b cle
         , oki_sales_k_hdrs shd
         , okc_k_items cim
         , okc_statuses_b sts
         , oki_job_run_dtl jrd
    WHERE 1=1
    AND    cim.cle_id            = cle.id
    and    sts.code              = cle.sts_code
    AND    cle.chr_id            IS NOT NULL
    AND    cle.dnz_chr_id        = shd.chr_id
    AND    jrd.chr_id            = shd.chr_id
    AND    jrd.job_run_id        = l_job_run_id
    AND    jrd.action_flag       = 'I'
    AND    cim.jtot_object1_code IN ('OKX_SERVICE','OKX_WARRANTY')  -- 11510 Changes
   ;

  l_loc := 'Updating OKI_REFRESHS.' ;
  -- update oki_refreshes
  update_oki_refresh(p_object_name => l_table_name
                    , p_job_run_id => l_job_run_id
                    , x_retcode    => l_retcode ) ;

  COMMIT;
  IF l_retcode = 2 THEN
  	RAISE l_no_update_refresh;
  END IF;

  l_loc := 'Analyzing ' || l_table_name ;
  -- analyze table
  fnd_stats.gather_table_stats( ownname => 'OKI'
                              , tabname => l_table_name
                              , percent => 10 ) ;

  fnd_message.set_name( application => 'OKI'
                      , name        => 'OKI_TABLE_LOAD_SUCCESS' ) ;
  fnd_message.set_token( token => 'TABLE_NAME'
                       , value => l_table_name ) ;
  fnd_file.put_line( which => fnd_file.log
                   , buff  => fnd_message.get ) ;

EXCEPTION
  WHEN l_excp_no_processing then
    -- Do not log an error ;  It has already been logged.
    -- Just exit the program and continue with the other table load
    null ;

  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;

when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    x_retcode := '2';
    fnd_message.set_name( application => 'OKI'
                        , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;
    fnd_message.set_token( token => 'TABLE_NAME'
                         , value => l_table_name ) ;
    fnd_file.put_line( which => fnd_file.log
                     , buff  => fnd_message.get ) ;
    fnd_file.put_line( which => fnd_file.log
                     , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END fast_sold_itm_lines ;

---------------------------------------------------------------------
--
-- procedure to refresh the covered product lines
--
---------------------------------------------------------------------
procedure refresh_cov_prd_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2) IS


  -- Exception to immediately exit the procedure
  l_excp_no_job_run_id   EXCEPTION ;
  l_no_update_refresh    EXCEPTION;
  l_index_tab         vc_tab_type;
  l_sql_string        VARCHAR2(4000);
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;

  -- variables to set up the fast refresh job
  l_job_run_id         NUMBER ;

BEGIN
  retcode := '0';

  -- get representative index storage parms for later use
  OPEN index_info_csr('OKI_COV_PRD_LINES','OKI_COV_PRD_LINES_U1','OKI');
  FETCH index_info_csr INTO l_ind_rec;
  CLOSE index_info_csr;
  l_errpos := 1;

  -- drop indexes
  OPEN index_name_csr('OKI_COV_PRD_LINES');
  FETCH index_name_csr BULK COLLECT INTO l_index_tab;
  CLOSE index_name_csr;

  IF l_index_tab.first IS NOT NULL THEN
    FOR i IN l_index_tab.first..l_index_tab.last LOOP
      l_sql_string := 'DROP INDEX OKI.'||l_index_tab(i);
      EXECUTE IMMEDIATE l_sql_string;
    END LOOP;
  END IF;
  l_errpos := 2;

  -- truncate table
  l_sql_string := 'TRUNCATE TABLE OKI.OKI_COV_PRD_LINES';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 3;

  l_sql_string := 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 4;

  l_sql_string := 'alter session set hash_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;
  l_sql_string := 'alter session set sort_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;

  -- insert data
  INSERT /*+ append */ INTO OKI_COV_PRD_LINES
  (
   CLE_ID,
   CHR_ID,
   PARENT_CLE_ID,
   SCS_CODE,
   CONTRACT_NUMBER,
   CONTRACT_NUMBER_MODIFIER,
   COMPLETE_CONTRACT_NUMBER,
   LINE_NUMBER,
   START_DATE,
   END_DATE,
   DURATION,
   PERIOD,
   STS_CODE,
   ste_code,
   TRN_CODE,
   DATE_TERMINATED,
   DATE_RENEWED,
   NUMBER_OF_ITEMS,
   UOM_CODE,
   UNIT_PRICE,
   UNIT_PRICE_PERCENT,
   PRICE_NEGOTIATED,
   CURRENCY_CODE,
   PRICE_NEGOTIATED_RENEWED,
   CURRENCY_CODE_RENEWED,
   SOB_PRICE_UNIT,
   SOB_PRICE_NEGOTIATED,
   SOB_PRICE_NEGOTIATED_RENEWED,
   SOB_CURRENCY_CODE,
   BASE_PRICE_UNIT,
   BASE_PRICE_NEGOTIATED,
   BASE_PRICE_NEGOTIATED_RENEWED,
   BASE_CURRENCY_CODE,
   SERVICE_ITEM,
   COVERED_PRODUCT_ID,
   CUSTOMER_PRODUCT_ITEM_ID,
   CONCATENATED_SEGMENTS,
   SERIAL_NUMBER,
   REFERENCE_NUMBER,
   COV_PROD_QUANTITY,
   COV_PROD_UOM,
   INSTALLATION_DATE,
   COV_PROD_ORDER_DATE,
   COV_PROD_ORDER_NUMBER,
   COV_PROD_ORDER_LINE,
   COV_PROD_NET_AMOUNT,
   COV_PROD_ORDER_LINE_ID,
   SYSTEM_ID,
   SYSTEM_NAME,
   PRODUCT_AGREEMENT_ID,
   COV_PROD_BILL_TO_SITE_ID,
   COV_PROD_SHIP_TO_SITE_ID,
   COV_PROD_INSTALL_SITE_ID,
   COV_PROD_BILL_TO_CONTACT_ID,
   COV_PROD_SHIP_TO_CONTACT_ID,
   AUTHORING_ORG_ID,
   INVENTORY_ORGANIZATION_ID,
   CREATION_DATE,
   LAST_UPDATE_DATE,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1,
   ATTRIBUTE2,
   ATTRIBUTE3,
   ATTRIBUTE4,
   ATTRIBUTE5,
   ATTRIBUTE6,
   ATTRIBUTE7,
   ATTRIBUTE8,
   ATTRIBUTE9,
   ATTRIBUTE10,
   ATTRIBUTE11,
   ATTRIBUTE12,
   ATTRIBUTE13,
   ATTRIBUTE14,
   ATTRIBUTE15 ,
   PRICING_ATTRIBUTE1,
   PRICING_ATTRIBUTE2,
   PRICING_ATTRIBUTE3,
   PRICING_ATTRIBUTE4,
   PRICING_ATTRIBUTE5,
   PRICING_ATTRIBUTE6,
   PRICING_ATTRIBUTE7,
   PRICING_ATTRIBUTE8,
   PRICING_ATTRIBUTE9,
   PRICING_ATTRIBUTE10,
/* 11510 changes start added these columns*/
   END_PERIOD_NUM ,
   END_PERIOD_NAME ,
   END_QUARTER ,
   END_YEAR ,
   IS_EXP_NOT_RENEWED_YN
/* 11510 changes end */
 )
SELECT  /*+ leading(sil) */
   cle.id
  ,sil.chr_id
  ,cle.cle_id
  ,sil.scs_code
  ,sil.contract_number
  ,sil.contract_number_modifier
  ,sil.complete_contract_number
  ,sil.line_number ||'.'|| cle.line_number
  ,trunc(cle.start_date)
  ,trunc(cle.end_date)
  ,oki_disco_util_pub.get_duration(cle.start_date,cle.end_date)
  ,oki_disco_util_pub.get_period(cle.start_date,cle.end_date)
  ,cle.sts_code
  ,sts.ste_code
  ,cle.trn_code
  ,trunc(cle.date_terminated)
  ,trunc(cle.date_renewed)
  ,cim.number_of_items
  ,cim.uom_code
  ,cle.price_unit
  ,cle.price_unit_percent
  ,cle.price_negotiated
  ,sil.currency_code
  ,cle.price_negotiated_renewed
  ,cle.currency_code_renewed
/* 11510 changes start */
  ,cle.price_unit * jrd.trx_func_rate --(cle.price_unit * nvl(kcr.sob_currency_conv_rate,dre1.conversion_rate))
  ,cle.price_negotiated * jrd.trx_func_rate --(cle.price_negotiated * nvl(kcr.sob_currency_conv_rate,dre1.conversion_rate))
/* 11510 changes end */
  ,null
  ,sil.sob_currency_code
/* 11510 changes start */
  ,cle.price_unit * jrd.trx_base_rate --(cle.price_unit * nvl(kcr.base_currency_conv_rate,dre3.conversion_rate))
  ,cle.price_negotiated * jrd.trx_base_rate --(cle.price_negotiated * nvl(kcr.base_currency_conv_rate,dre3.conversion_rate))
/* 11510 changes end */
  ,null
  ,l_base_currency
  ,sil.sold_item
  ,cii.instance_id
  ,cii.inventory_item_id
  ,null
  ,cii.serial_number
  ,cii.instance_number
  ,cii.quantity
  ,cii.unit_of_measure
  ,cii.install_date
  ,null
  ,null
  ,null
  ,null
  ,cii.last_oe_order_line_id
  ,cii.system_id
  ,null
  ,cii.last_oe_agreement_id
  ,null
  ,null
  ,cii.install_location_id
  ,null
  ,null
  ,sil.authoring_org_id
  ,sil.inventory_organization_id
  ,cle.creation_date
  ,cle.last_update_date
  ,cle.attribute_category
  ,cle.attribute1
  ,cle.attribute2
  ,cle.attribute3
  ,cle.attribute4
  ,cle.attribute5
  ,cle.attribute6
  ,cle.attribute7
  ,cle.attribute8
  ,cle.attribute9
  ,cle.attribute10
  ,cle.attribute11
  ,cle.attribute12
  ,cle.attribute13
  ,cle.attribute14
  ,cle.attribute15
  ,null
  ,null
  ,null
  ,null
  ,null
  ,null
  ,null
  ,null
  ,null
  ,null
  /*11510 changes start*/
  , epd.period_num
  , epd.period_name
  , epd.quarter_num
  , epd.period_year
--Bug Fix 3469671 code changes-------------------------------------------------
   , DECODE(sts.ste_code,'EXPIRED'  -- If contract is expired then
         ,DECODE(cle.price_level_ind,'Y' --check if line is priced
                ,DECODE(cle.date_renewed,NULL,'Y' --check if renewed or record from operation line exists
                       ,DECODE(exp.cle_id,NULL,'Y','N') --if so 'N' else 'Y'
                       )
                ,'N')--if the line is not priced 'N'
       ,'N')--if the contract is not expired 'N'
   is_exp_not_renewed_yn
--Bug Fix 3469671 code changes-------------------------------------------------
from
   oki_sold_itm_lines sil
/*11510 changes added*/
  ,oki_job_run_dtl jrd
  ,okc_k_lines_b cle
  ,okc_k_items cim
  ,csi_item_instances cii
  ,okc_statuses_b sts
/*11510 changes added*/
  ,gl_periods epd
  ,(select distinct object_cle_id cle_id from okc_operation_lines
    where active_yn = 'Y' ) exp
where 1 = 1
    and cii.instance_id          = to_number(cim.object1_id1)
    and cim.cle_id               = cle.id
    and sts.code                 = cle.sts_code
    and cle.cle_id               = sil.cle_id
    /* 11510 changes added join for expired inline view */
    and exp.cle_id(+)            = cle.cle_id
    and cle.lse_id               in (9, 18, 25)
  /*11510 changes start*/
    and jrd.chr_id               = sil.chr_id
    and cle.end_date     between epd.start_date and epd.end_date+0.99999
    and epd.period_type          = jrd.accounted_period_type
    and epd.period_set_name      = jrd.period_set_name
    and epd.adjustment_period_flag  = 'N'
  /*11510 changes end */
;

  COMMIT;
  l_errpos := 5;

  -- recreate indexes
  create_indicies(p_object_name => 'OKI_COV_PRD_LINES'
                 ,p_parm_rec => l_ind_rec);
  l_errpos := 6;

  OPEN g_latest_job_run_id_csr ;
  FETCH g_latest_job_run_id_csr INTO rec_g_latest_job_run_id_csr ;
    IF g_latest_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_no_job_run_id ;
    END IF ;
    l_job_run_id := rec_g_latest_job_run_id_csr.job_run_id ;
  CLOSE g_latest_job_run_id_csr ;

  -- update oki_refreshes
  update_oki_refresh(   p_object_name => 'OKI_COV_PRD_LINES'
                      , p_job_run_id  => l_job_run_id
                      , x_retcode     => retcode);
  if retcode =2 THEN
  	raise l_no_update_refresh;
  END IF;
  l_errpos := 8;

  -- analyze table
  fnd_stats.gather_table_stats(ownname => 'OKI'
                              ,tabname => 'OKI_COV_PRD_LINES',percent=> 10);
  l_errpos := 9;

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_COV_PRD_LINES');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);

EXCEPTION
	WHEN l_no_update_refresh THEN
		    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_COV_PRD_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff  =>'Update of OKI_REFRESHS failed' );

  WHEN l_excp_no_job_run_id THEN
    ROLLBACK;
    retcode := '2';

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_COV_PRD_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_NO_JOB_RUN_ID_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    retcode := '2';

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_COV_PRD_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode||' '||l_sqlerrm);
    IF l_errpos < 5 THEN
      create_indicies(  p_object_name => 'OKI_COV_PRD_LINES'
                      , p_parm_rec    => l_ind_rec);
    ELSIF l_errpos = 5 THEN
      -- truncate table
      l_sql_string := 'TRUNCATE TABLE OKI.OKI_COV_PRD_LINES';
      EXECUTE IMMEDIATE l_sql_string;
    END IF;
END refresh_cov_prd_lines;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_cov_prd_lines without a complete
-- refresh
--
---------------------------------------------------------------------
procedure fast_cov_prd_lines
( x_errbuf  OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2 ) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;
  -- Location within the program before the error was encountered.
  l_loc                 VARCHAR2(200) ;
  l_retcode             VARCHAR2(1) ;
  l_process_yn          VARCHAR2(1) ;
  l_job_run_id          NUMBER ;
  l_job_curr_start_date DATE ;
  l_job_curr_end_date   DATE ;
  l_table_name          VARCHAR2(30);


BEGIN
  l_retcode := '0';
  l_table_name  := 'OKI_COV_PRD_LINES' ;

  l_loc := 'Calling process_refresh_check.' ;
  process_refresh_check(
        p_object_name => 'OKI_COV_PRD_LINES'
      , x_job_run_id  => l_job_run_id
      , x_process_yn  => l_process_yn
      , x_errbuf      => x_errbuf
      , x_retcode     => l_retcode ) ;
  l_loc := 'Determining status of process_refresh_check.' ;
  IF l_retcode = '2' THEN
    -- No job_run_id, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Checking if records have already been processed.' ;
  IF l_process_yn = 'N' THEN
    -- Object has been refreshed successfully.
    RAISE l_excp_no_processing ;
  END IF ;

  l_loc := 'Calling get_load_date_range.' ;
  get_load_date_range(
      p_job_run_id          => l_job_run_id
    , p_job_curr_start_date => l_job_curr_start_date
    , p_job_curr_end_date   => l_job_curr_end_date
    , x_errbuf              => x_errbuf
    , x_retcode             => l_retcode ) ;
  l_loc := 'Determining status of get_load_date_range' ;
  IF l_retcode = '2' THEN
    -- No job_curr_date range values, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Deleting from ' || l_table_name ;
  DELETE FROM oki_cov_prd_lines cpl
  WHERE chr_id in ( SELECT /*+ index_ffs(jrd oki_job_run_dtl_u1)*/
                    jrd.chr_id
                    FROM oki_job_run_dtl jrd
                    WHERE jrd.job_run_id  = l_job_run_id ) ;

  l_loc := 'Inserting into ' || l_table_name ;
  -- insert data
  INSERT INTO oki_cov_prd_lines (
           cle_id
         , chr_id
         , parent_cle_id
         , scs_code
         , contract_number
         , contract_number_modifier
         , complete_contract_number
         , line_number
         , start_date
         , end_date
	    , duration
	    , period
         , sts_code
         , ste_code
         , trn_code
         , date_terminated
         , date_renewed
         , number_of_items
         , uom_code
         , unit_price
         , unit_price_percent
         , price_negotiated
         , currency_code
         , price_negotiated_renewed
         , currency_code_renewed
         , sob_price_unit
         , sob_price_negotiated
         , sob_price_negotiated_renewed
         , sob_currency_code
         , base_price_unit
         , base_price_negotiated
         , base_price_negotiated_renewed
         , base_currency_code
         , service_item
         , covered_product_id
         , customer_product_item_id
         , concatenated_segments
         , serial_number
         , reference_number
         , cov_prod_quantity
         , cov_prod_uom
         , installation_date
         , cov_prod_order_date
         , cov_prod_order_number
         , cov_prod_order_line
         , cov_prod_net_amount
         , cov_prod_order_line_id
         , system_id
    	 , system_name
         , product_agreement_id
         , cov_prod_bill_to_site_id
         , cov_prod_ship_to_site_id
         , cov_prod_install_site_id
         , cov_prod_bill_to_contact_id
         , cov_prod_ship_to_contact_id
         , authoring_org_id
         , inventory_organization_id
         , creation_date
         , last_update_date
         , attribute_category
         , attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , pricing_attribute1
         , pricing_attribute2
         , pricing_attribute3
         , pricing_attribute4
         , pricing_attribute5
         , pricing_attribute6
         , pricing_attribute7
         , pricing_attribute8
         , pricing_attribute9
         , pricing_attribute10
/* 11510 changes start */
         , end_period_num
         , end_period_name
         , end_quarter
         , end_year
         , is_exp_not_renewed_yn
/* 11510 changes start */
  ) SELECT /*+ leading(jrd) full(jrd) cardinality(jrd,1) */
             cle.id
           , sil.chr_id
           , cle.cle_id
           , sil.scs_code
           , sil.contract_number
           , sil.contract_number_modifier
           , sil.complete_contract_number
           , sil.line_number ||'.'|| cle.line_number
           , TRUNC(cle.start_date)
           , TRUNC(cle.end_date)
	      ,oki_disco_util_pub.get_duration(cle.start_date,cle.end_date)
	      ,oki_disco_util_pub.get_period(cle.start_date,cle.end_date)
           , cle.sts_code
           , sts.ste_code
           , cle.trn_code
           , TRUNC(cle.date_terminated)
           , TRUNC(cle.date_renewed)
           , cim.number_of_items
           , cim.uom_code
           , cle.price_unit
           , cle.price_unit_percent
           , cle.price_negotiated
           , sil.currency_code
           , cle.price_negotiated_renewed
           , cle.currency_code_renewed
/* 11510 changes start */
           , cle.price_unit * jrd.trx_func_rate --(cle.price_unit * NVL(kcr.sob_currency_conv_rate,  dre1.conversion_rate))
           , cle.price_negotiated * jrd.trx_func_rate --(cle.price_negotiated * NVL(kcr.sob_currency_conv_rate,dre1.conversion_rate))
/* 11510 changes start */
           , null--(cle.price_negotiated_renewed * NVL(kcr.renewed_sob_conv_rate,
                  --     dre2.conversion_rate))
           , sil.sob_currency_code
/* 11510 changes start */
           , cle.price_unit * jrd.trx_base_rate --(cle.price_unit * NVL(kcr.base_currency_conv_rate,dre3.conversion_rate))
           , cle.price_negotiated * jrd.trx_base_rate --(cle.price_negotiated * NVL(kcr.base_currency_conv_rate,dre3.conversion_rate))
/* 11510 changes start */
           , null --(cle.price_negotiated_renewed * NVL(kcr.renewed_base_conv_rate,
                  --     dre4.conversion_rate))
           , l_base_currency
           , sil.sold_item
           , cii.instance_id
           , cii.inventory_item_id
           , null
           , cii.serial_number
           , cii.instance_number
           , cii.quantity
           , cii.unit_of_measure
           , cii.install_date
           , null
           , null
           , null
           , null
           , cii.last_oe_order_line_id
           , cii.system_id
           , null
           , cii.last_oe_agreement_id
           , null
           , null
           , cii.install_location_id
           , null
           , null
           , sil.authoring_org_id
           , sil.inventory_organization_id
           , cle.creation_date
           , cle.last_update_date
           , cle.attribute_category
           , cle.attribute1
           , cle.attribute2
           , cle.attribute3
           , cle.attribute4
           , cle.attribute5
           , cle.attribute6
           , cle.attribute7
           , cle.attribute8
           , cle.attribute9
           , cle.attribute10
           , cle.attribute11
           , cle.attribute12
           , cle.attribute13
           , cle.attribute14
           , cle.attribute15
           , null
           , null
           , null
           , null
           , null
           , null
           , null
           , null
           , null
           , null
	   , epd.period_num
	   , epd.period_name
	   , epd.quarter_num
	   , epd.period_year
--Bug Fix 3469671 code changes-------------------------------------------------
       , DECODE(sts.ste_code,'EXPIRED'  -- If contract is expired then
              ,DECODE(cle.price_level_ind,'Y' --check if line is priced
                     ,DECODE(cle.date_renewed,NULL,'Y' --check if renewed or record from operation line exists
                            ,DECODE(exp.cle_id,NULL,'Y','N') --if so 'N' else 'Y'
                       )
                ,'N')--if the line is not priced 'N'
       ,'N')--if the contract is not expired 'N'
    is_exp_not_renewed_yn
--Bug Fix 3469671 code changes-------------------------------------------------
   FROM
           okc_k_lines_b cle
         , oki_sold_itm_lines sil
         , okc_k_items cim
         , csi_item_instances cii
         , okc_statuses_b sts
         , oki_job_run_dtl jrd
/*11510 changes added*/
         , gl_periods epd
         ,(select distinct object_cle_id cle_id from okc_operation_lines
            where active_yn = 'Y' ) exp --Bug Fix 3469671 code changes
    WHERE
            cii.instance_id          = to_number(cim.object1_id1)
    AND     exp.cle_id(+)            = cle.id            --Bug Fix 3469671 code changes
    AND     cim.cle_id               = cle.id
    AND     sts.code                 = cle.sts_code
    AND     cle.cle_id               = sil.cle_id
    AND     cle.lse_id               IN (9, 18, 25)
    AND jrd.chr_id      = sil.chr_id
    AND jrd.job_run_id  = l_job_run_id
    AND jrd.action_flag = 'I'
/*11510 changes start*/
    AND cle.end_date            between epd.start_date and epd.end_date+0.99999
    AND epd.period_type          = jrd.accounted_period_type
    AND epd.period_set_name      = jrd.period_set_name
    AND epd.adjustment_period_flag  = 'N'
/*11510 changes end*/
    ;

  l_loc := 'Updating OKI_REFRESHS.' ;
  -- update oki_refreshes
  update_oki_refresh(p_object_name => 'OKI_COV_PRD_LINES'
                    , p_job_run_id => l_job_run_id
                    , x_retcode    => l_retcode ) ;
  COMMIT;

  IF l_retcode = 2 THEN
  	RAISE l_no_update_refresh;
  END IF;

  l_loc := 'Analyzing ' || l_table_name ;
  -- analyze table
  fnd_stats.gather_table_stats( ownname => 'OKI'
                              , tabname => l_table_name
                              , percent => 10 ) ;

  fnd_message.set_name( application => 'OKI'
                      , name        => 'OKI_TABLE_LOAD_SUCCESS' ) ;
  fnd_message.set_token( token => 'TABLE_NAME'
                       , value => l_table_name ) ;
  fnd_file.put_line( which => fnd_file.log
                   , buff  => fnd_message.get ) ;

EXCEPTION
  WHEN l_excp_no_processing then
    -- Do not log an error ;  It has already been logged.
    -- Just exit the program and continue with the other table load
    null ;

  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;

when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_COV_PRD_LINES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');

  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    x_retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => l_table_name ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END fast_cov_prd_lines ;
---------------------------------------------------------------------
--
-- load the expired lines table
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

procedure refresh_expired_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2) IS

  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END refresh_expired_lines;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_expired_lines without a complete
-- refresh
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

procedure fast_expired_lines
(
  x_errbuf  OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2
) IS

  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END fast_expired_lines ;

---------------------------------------------------------------------
--
-- load the contract salesreps table
--
---------------------------------------------------------------------
--   11510 Changes to refresh/fast_k_salesrep
--      1. Table oki_role_maps is obsoleted, so the procedure hard codes the
--         value for contact role code depending upon the contract subclass.
--      2. Column salesrep_name is not populated in the table
--         oki_k_salesreps. Therefore, the logic to populate this column is
--         removed from the procedure.
procedure refresh_k_salesreps(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS

  -- Exception to immediately exit the procedure
  l_excp_no_job_run_id   EXCEPTION ;
  l_no_update_refresh   EXCEPTION;
  l_index_tab         vc_tab_type;
  l_sql_string        VARCHAR2(4000);
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;

  -- variables to set up the fast refresh job
  l_job_run_id         NUMBER ;

  l_salesperson_code  okc_contacts.cro_code%TYPE; -- 11510 Changes

BEGIN
  retcode := '0';

  -- get representative index storage parms for later use
  OPEN index_info_csr('OKI_K_SALESREPS','OKI_K_SALESREPS_U1','OKI');
  FETCH index_info_csr INTO l_ind_rec;
  CLOSE index_info_csr;
  l_errpos := 1;

  -- drop indexes
  OPEN index_name_csr('OKI_K_SALESREPS');
  FETCH index_name_csr BULK COLLECT INTO l_index_tab;
  CLOSE index_name_csr;
  l_errpos := 2;

/*  11510 Changes Start */
  l_salesperson_code := fnd_profile.value('OKS_ENABLE_SALES_CREDIT');
   IF l_salesperson_code IN ('YES') THEN
        l_salesperson_code := fnd_profile.value('OKS_VENDOR_CONTACT_ROLE');
   ELSE
      l_salesperson_code := 'SALESPERSON';
   END IF;
/*  11510 Changes End */

  IF l_index_tab.first IS NOT NULL THEN
    FOR i IN l_index_tab.first..l_index_tab.last LOOP
      l_sql_string := 'DROP INDEX OKI.'||l_index_tab(i);
      EXECUTE IMMEDIATE l_sql_string;
    END LOOP;
  END IF;
  l_errpos := 3;

  -- truncate table
  l_sql_string := 'TRUNCATE TABLE OKI.OKI_K_SALESREPS';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 4;

  l_sql_string := 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE l_sql_string;
  l_errpos := 5;

  l_sql_string := 'alter session set hash_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;
  l_sql_string := 'alter session set sort_area_size=100000000';
  EXECUTE IMMEDIATE l_sql_string;

  -- insert data
  INSERT /*+ append */ INTO OKI_K_SALESREPS
  (
   PARTY_CONTACT_ID,
   CONTRACT_ID,
   PARTY_ROLE_ID,
   CONTACT_ROLE_CODE,
   CONTACT_ID,
   SALESREP_NAME ,
   CREATION_DATE,
   LAST_UPDATE_DATE,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1,
   ATTRIBUTE2,
   ATTRIBUTE3,
   ATTRIBUTE4,
   ATTRIBUTE5,
   ATTRIBUTE6,
   ATTRIBUTE7,
   ATTRIBUTE8,
   ATTRIBUTE9,
   ATTRIBUTE10,
   ATTRIBUTE11,
   ATTRIBUTE12,
   ATTRIBUTE13,
   ATTRIBUTE14,
   ATTRIBUTE15
  )
  SELECT /*+ use_hash(shd) use_hash(ctt) use_hash(srp) use_hash(jrs) */
      ctt.id
     ,ctt.dnz_chr_id
     ,ctt.cpl_id
     ,ctt.cro_code
     ,ctt.object1_id1
     ,NULL salesrep_name -- 11510 Changes
     ,ctt.creation_date
     ,ctt.last_update_date
     ,ctt.attribute_category
     ,ctt.attribute1
     ,ctt.attribute2
     ,ctt.attribute3
     ,ctt.attribute4
     ,ctt.attribute5
     ,ctt.attribute6
     ,ctt.attribute7
     ,ctt.attribute8
     ,ctt.attribute9
     ,ctt.attribute10
     ,ctt.attribute11
     ,ctt.attribute12
     ,ctt.attribute13
     ,ctt.attribute14
     ,ctt.attribute15
  FROM
         oki_sales_k_hdrs shd
        ,okc_contacts ctt
   WHERE 1=1
     AND ctt.cro_code         = l_salesperson_code -- 11510 Changes
     AND ctt.dnz_chr_id       = shd.chr_id
  ;
  COMMIT;
  l_errpos := 6;

  -- recreate indexes
  create_indicies(p_object_name => 'OKI_K_SALESREPS'
                 ,p_parm_rec => l_ind_rec);
  l_errpos := 7;

  OPEN g_latest_job_run_id_csr ;
  FETCH g_latest_job_run_id_csr INTO rec_g_latest_job_run_id_csr ;
    IF g_latest_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_no_job_run_id ;
    END IF ;
    l_job_run_id := rec_g_latest_job_run_id_csr.job_run_id ;
  CLOSE g_latest_job_run_id_csr ;

  -- update oki_refreshes
  update_oki_refresh(   p_object_name => 'OKI_K_SALESREPS'
                      , p_job_run_id  => l_job_run_id
                      , x_retcode     => retcode ) ;
  if retcode = 2 THEN
  	raise l_no_update_refresh;
  end if;

  l_errpos := 9;

  -- analyze table
  fnd_stats.gather_table_stats(ownname => 'OKI'
                              ,tabname => 'OKI_K_SALESREPS',percent=> 10);

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_K_SALESREPS');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);

EXCEPTION
  WHEN l_excp_no_job_run_id THEN
    ROLLBACK;
    retcode := '2';

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_K_SALESREPS');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);

    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_NO_JOB_RUN_ID_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);

when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_K_SALESREPS');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_K_SALESREPS');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);
    fnd_file.put_line(  which => fnd_file.log
                      , buff => l_sqlcode||' '||l_sqlerrm);
    IF l_errpos < 6 THEN
      create_indicies(  p_object_name => 'OKI_K_SALESREPS'
                      , p_parm_rec => l_ind_rec);
    ELSIF l_errpos = 6 THEN
      -- truncate table
      l_sql_string := 'TRUNCATE TABLE OKI.OKI_K_SALESREPS';
      EXECUTE IMMEDIATE l_sql_string;
    END IF;
END refresh_k_salesreps;
---------------------------------------------------------------------
--
-- Procedure to load data into oki_k_salesrep without a complete
-- refresh
--
---------------------------------------------------------------------
procedure fast_k_salesreps
( x_errbuf  OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2
) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;
  l_no_update_refresh  EXCEPTION;
  l_sqlcode           VARCHAR2(100);
  l_sqlerrm           VARCHAR2(1000);
  l_errpos            NUMBER := 0;
  -- Location within the program before the error was encountered.
  l_loc                 VARCHAR2(200) ;
  l_retcode             VARCHAR2(1) ;
  l_process_yn          VARCHAR2(1) ;
  l_job_run_id          NUMBER ;
  l_job_curr_start_date DATE ;
  l_job_curr_end_date   DATE ;
  l_table_name          VARCHAR2(30)  ;

  l_salesperson_code  okc_contacts.cro_code%TYPE; -- 11510 Changes

BEGIN
  l_retcode := '0';
  l_table_name := 'OKI_K_SALESREPS';

  l_loc := 'Calling process_refresh_check.' ;
  process_refresh_check(
        p_object_name => l_table_name
      , x_job_run_id  => l_job_run_id
      , x_process_yn  => l_process_yn
      , x_errbuf      => x_errbuf
      , x_retcode     => l_retcode ) ;
  l_loc := 'Determining status of process_refresh_check.' ;
  IF l_retcode = '2' THEN
    -- No job_run_id, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Checking if records have already been processed.' ;
  IF l_process_yn = 'N' THEN
    RAISE l_excp_no_processing ;
  END IF ;

/*  11510 Changes Start */
  l_salesperson_code := fnd_profile.value('OKS_ENABLE_SALES_CREDIT');
   IF l_salesperson_code IN ('YES') THEN
        l_salesperson_code := fnd_profile.value('OKS_VENDOR_CONTACT_ROLE');
   ELSE
      l_salesperson_code := 'SALESPERSON';
   END IF;
/*  11510 Changes End */

  l_loc := 'Calling get_load_date_range.' ;
  get_load_date_range(
      p_job_run_id          => l_job_run_id
    , p_job_curr_start_date => l_job_curr_start_date
    , p_job_curr_end_date   => l_job_curr_end_date
    , x_errbuf              => x_errbuf
    , x_retcode             => l_retcode ) ;
  l_loc := 'Determining status of  get_load_date_range' ;
  IF l_retcode = '2' THEN
    -- No job_curr_date range values, exit immediately.
    RAISE l_excp_exit_immediate ;
  END IF ;

  l_loc := 'Deleting from ' || l_table_name ;
  DELETE FROM oki_k_salesreps ksr
  WHERE contract_id in ( SELECT jrd.chr_id
                         FROM oki_job_run_dtl jrd
                         WHERE jrd.job_run_id  = l_job_run_id ) ;

  l_loc := 'Inserting into ' || l_table_name ;
  -- insert data
  INSERT INTO OKI_K_SALESREPS(
           PARTY_CONTACT_ID
         , CONTRACT_ID
         , PARTY_ROLE_ID
         , CONTACT_ROLE_CODE
         , CONTACT_ID
         , SALESREP_NAME
         , CREATION_DATE
         , LAST_UPDATE_DATE
         , ATTRIBUTE_CATEGORY
         , ATTRIBUTE1
         , ATTRIBUTE2
         , ATTRIBUTE3
         , ATTRIBUTE4
         , ATTRIBUTE5
         , ATTRIBUTE6
         , ATTRIBUTE7
         , ATTRIBUTE8
         , ATTRIBUTE9
         , ATTRIBUTE10
         , ATTRIBUTE11
         , ATTRIBUTE12
         , ATTRIBUTE13
         , ATTRIBUTE14
         , ATTRIBUTE15
  ) SELECT
             ctt.id
           , ctt.dnz_chr_id
           , ctt.cpl_id
           , ctt.cro_code
           , ctt.object1_id1
	   , NULL salesrep_name -- 11510 Changes
           , ctt.creation_date
           , ctt.last_update_date
           , ctt.attribute_category
           , ctt.attribute1
           , ctt.attribute2
           , ctt.attribute3
           , ctt.attribute4
           , ctt.attribute5
           , ctt.attribute6
           , ctt.attribute7
           , ctt.attribute8
           , ctt.attribute9
           , ctt.attribute10
           , ctt.attribute11
           , ctt.attribute12
           , ctt.attribute13
           , ctt.attribute14
           , ctt.attribute15
    FROM
           oki_sales_k_hdrs shd
         , okc_contacts ctt
         , oki_job_run_dtl jrd
    WHERE  1=1
    AND    ctt.cro_code         = l_salesperson_code -- 11510 Changes
    AND    ctt.dnz_chr_id       = shd.chr_id
    and    jrd.chr_id           = shd.chr_id
    and    jrd.job_run_id       = l_job_run_id
    and    jrd.action_flag      = 'I' ;

  l_loc := 'Updating OKI_REFRESHS.' ;
  -- update oki_refreshes
  update_oki_refresh( p_object_name => l_table_name
                    , p_job_run_id  => l_job_run_id
                    , x_retcode     => l_retcode ) ;
   COMMIT;
if l_retcode = 2 then
	raise l_no_update_refresh;
end if;

  l_loc := 'Analyze ' || l_table_name ;
  -- analyze table
  fnd_stats.gather_table_stats(  ownname => 'OKI'
                               , tabname => l_table_name
                               , percent => 10 ) ;

  fnd_message.set_name(  application => 'OKI'
                       , name        => 'OKI_TABLE_LOAD_SUCCESS' ) ;
  fnd_message.set_token(  token => 'TABLE_NAME'
                        , value => l_table_name ) ;
  fnd_file.put_line(  which => fnd_file.log
                    , buff  => fnd_message.get ) ;

EXCEPTION
  WHEN l_excp_no_processing then
    -- Do not log an error ;  It has already been logged.
    -- Just exit the program and continue with the other table load
    null ;

when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => l_table_name);
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;

  WHEN OTHERS THEN
    l_sqlcode := sqlcode;
    l_sqlerrm := sqlerrm;
    ROLLBACK;
    x_retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;
    fnd_message.set_token( token  => 'TABLE_NAME'
                          , value => l_table_name ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get ) ;
    fnd_file.put_line(  which => fnd_file.log
                      , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
END fast_k_salesreps ;
/*********11510 changes stub out the procedure *********/
--------------------------------------------------------------
---  Refresh the conversion rates which are locked for contracts
---------------------------------------------------------------

-- 11510 Change: Stub out the procedure

PROCEDURE refresh_k_conv_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS
  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END  refresh_k_conv_rates;

---------------------------------------------------------------------
--
-- Procedure to load data into oki_pricing_rules.
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

PROCEDURE refresh_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
                                  , x_retcode OUT NOCOPY VARCHAR2 ) IS

  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END refresh_k_pricing_rules ;

---------------------------------------------------------------------
--
-- Procedure to load change data into oki_pricing_rules and OKI QTO.
--
---------------------------------------------------------------------

-- 11510 Change: Stub out the procedure

PROCEDURE fast_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
                               , x_retcode OUT NOCOPY VARCHAR2 ) IS
  l_sql_string       VARCHAR2(2000);

BEGIN

  l_sql_string := 'Procedure no longer used' ;

END fast_k_pricing_rules ;


PROCEDURE update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
                              , x_retcode OUT NOCOPY VARCHAR2 ) IS

  -- Exception to immediately exit the procedure
  l_excp_no_job_run_id   EXCEPTION ;
  l_no_update_refresh    EXCEPTION;
  l_message          VARCHAR2(2000);
  l_sqlcode          VARCHAR2(100);
  l_sqlerrm          VARCHAR2(1000);
  l_errpos            NUMBER := 0 ;

  -- variables to set up the fast refresh job
  l_job_run_id         NUMBER ;

  -- Location within the program before the error was encountered.
  l_loc              VARCHAR2(200) ;

  BEGIN
    x_retcode := 0 ;

    l_loc := ' Updating price negotiated for Service Contracts ';

    UPDATE /*+ parallel(v) bypass_ujvc */ oki_sold_itm_lines_cpl_v v
       SET price_negotiated      = cpl_price_negotiated
	    , sob_price_negotiated  = cpl_sob_price_negotiated
	    , base_price_negotiated = cpl_base_price_negotiated ;

     COMMIT;
  l_loc := ' Succesfully Updated price negotiated for Service Contracts ';

  OPEN g_latest_job_run_id_csr ;
  FETCH g_latest_job_run_id_csr INTO rec_g_latest_job_run_id_csr ;
    IF g_latest_job_run_id_csr%NOTFOUND THEN
      RAISE l_excp_no_job_run_id ;
    END IF ;
    l_job_run_id := rec_g_latest_job_run_id_csr.job_run_id ;
  CLOSE g_latest_job_run_id_csr ;

  -- update oki_refreshes
  update_oki_refresh(   p_object_name => 'OKI_SOLD_ITM_LINES_UPDATE'
                      , p_job_run_id  => l_job_run_id
                      , x_retcode     => x_retcode ) ;
  COMMIT ;
if x_retcode = 2 then
	raise l_no_update_refresh;
end if;

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_SOLD_ITM_LINES');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);

  EXCEPTION
   WHEN l_excp_no_job_run_id THEN
    ROLLBACK;
    x_retcode := '2';
    fnd_message.set_name(  application => 'OKI'
                         , name => 'OKI_TABLE_LOAD_FAILURE');
    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => 'OKI_SOLD_ITM_LINES');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);

    fnd_message.set_name(  application => 'OKI'
                         , name => 'OKI_NO_JOB_RUN_ID_FAILURE');
    fnd_file.put_line(  which => fnd_file.log
                      , buff => fnd_message.get);

when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
    WHEN OTHERS THEN
      l_sqlcode := sqlcode;
      l_sqlerrm := sqlerrm;
      fnd_file.put_line(which => fnd_file.log
                       ,buff => l_message);
      ROLLBACK;
      x_retcode := '2';
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm);

  END update_service_line;


  PROCEDURE fast_update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
                                     , x_retcode OUT NOCOPY VARCHAR2 ) IS

  -- Exception to immediately exit the procedure
  l_excp_exit_immediate   EXCEPTION ;
  -- Records have already been processed, just exit the program
  l_excp_no_processing    EXCEPTION ;
  l_no_update_refresh EXCEPTION;
  l_retcode             VARCHAR2(1) ;
  l_process_yn          VARCHAR2(1) ;
  l_message          VARCHAR2(2000);
  l_sqlcode          VARCHAR2(100);
  l_sqlerrm          VARCHAR2(1000);
  l_errpos            NUMBER := 0 ;

  -- Location within the program before the error was encountered.
  l_loc              VARCHAR2(200) ;

  l_job_run_id          NUMBER ;
  l_table_name          VARCHAR2(30)  ;


  BEGIN
    x_retcode := 0 ;
    l_table_name := 'OKI_SOLD_ITM_LINES_UPDATE';

     l_loc := 'Calling process_refresh_check.' ;
     process_refresh_check(
           p_object_name => l_table_name
         , x_job_run_id  => l_job_run_id
         , x_process_yn  => l_process_yn
         , x_errbuf      => x_errbuf
         , x_retcode     => l_retcode ) ;
     l_loc := 'Determining status of process_refresh_check.' ;
     IF l_retcode = '2' THEN
       -- No job_run_id, exit immediately.
       RAISE l_excp_exit_immediate ;
     END IF ;

     l_loc := 'Checking if records have already been processed.' ;
     IF l_process_yn = 'N' THEN
       -- Object has been refreshed successfully.
       RAISE l_excp_no_processing ;
     END IF ;

    l_loc := ' Updating price negotiated for Service Contracts ';

    UPDATE OKI_SOLD_ITM_LINES sil
    SET (price_negotiated,
         sob_price_negotiated,
         base_price_negotiated)
    = (SELECT
          SUM(price_negotiated),
          SUM(sob_price_negotiated),
          SUM(base_price_negotiated)
       FROM oki_cov_prd_lines cpl
       where cpl.parent_cle_id = sil.cle_id
       )
	   where sil.chr_id in (select  shd.chr_id
	                        from oki_job_run_dtl jrd, oki_sales_k_hdrs shd
							where 1 =1
							and jrd.action_flag       = 'I'
							and jrd.job_run_id        = l_job_run_id
							and jrd.chr_id = shd.chr_id
							and shd.application_id = 515);

     l_loc := 'Updating OKI_REFRESHS.' ;
     -- update oki_refreshes
     update_oki_refresh(p_object_name => l_table_name
                       , p_job_run_id => l_job_run_id
                       , x_retcode    => l_retcode ) ;
     COMMIT;
 if l_retcode = 2 then
 	raise l_no_update_refresh;
 end if;
  l_loc := ' Succesfully Updated price negotiated for Service Contracts ';

  fnd_message.set_name(application => 'OKI'
                      ,name => 'OKI_TABLE_LOAD_SUCCESS');
  fnd_message.set_token(token => 'TABLE_NAME'
                       ,value => 'OKI_SOLD_ITM_LINES');
  fnd_file.put_line(which => fnd_file.log
                   ,buff => fnd_message.get);

  EXCEPTION
  WHEN l_excp_no_processing then
    -- Do not log an error ;  It has already been logged.
    -- Just exit the program and continue with the other table load
    null ;
when l_no_update_refresh then
  		fnd_message.set_name(application => 'OKI'
                          ,name => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(token => 'TABLE_NAME'
                           ,value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(which => fnd_file.log
                       ,buff => fnd_message.get);

  		fnd_file.put_line(which => fnd_file.log
                       ,buff => 'Update of OKI_REFRESHS failed');
  WHEN l_excp_exit_immediate THEN
    -- Do not log an error ;  It has already been logged.
    -- Set return code to error
    x_retcode := '2' ;

    WHEN OTHERS THEN
      l_sqlcode := sqlcode;
      l_sqlerrm := sqlerrm;
      fnd_file.put_line(which => fnd_file.log
                       ,buff => l_message);
      ROLLBACK;
      x_retcode := '2';
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');
      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_SOLD_ITM_LINES');
      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm);
  END fast_update_service_line;



---------------------------------------------------------------------
--
-- GLOBAL VARIABLES INITIALIZATION
--
---------------------------------------------------------------------

BEGIN
    g_request_id               :=  fnd_global.CONC_REQUEST_ID;
    g_program_application_id   :=  fnd_global.PROG_APPL_ID;
    g_program_id               :=  fnd_global.CONC_PROGRAM_ID;
    g_program_update_date      :=  SYSDATE;
END OKI_REFRESH_PVT ;

/
