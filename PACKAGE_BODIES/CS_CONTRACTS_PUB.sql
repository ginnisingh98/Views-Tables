--------------------------------------------------------
--  DDL for Package Body CS_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACTS_PUB" AS
/* $Header: csctpapb.pls 115.11 99/07/16 08:53:07 porting ship $ */
----------------------------------------------------------------------------
-- GLOBAL CONSTANTS
----------------------------------------------------------------------------
G_DATE_FORMAT			CONSTANT VARCHAR2(200) := 'DD-MM-YYYY';
----------------------------------------------------------------------------
-- GLOBAL MESSAGES
----------------------------------------------------------------------------
-- Message for NO_CHILDREN should be something like:
--   "Invalid record for: PARENT_TABLE. No children exist in CHILD_TABLE"
G_NO_CHILDREN_MSG		CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_NO_CHILDREN';
G_SERVICE_ATTACHED_TO_TEMPLATE	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_SVC_ATT_TEMPLATE';
G_INCOMPATIBLE_CONTRACT_LEVELS	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INCMPTBL_COV_LVLS';
G_VALIDATION_SUCCESSFUL		CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_VAL_SUCCESS';
G_COVERAGE_OVERLAP		CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_COVERAGE_OVERLAP';
G_INVALID_SERVICE_START_DATE	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INVD_SVC_START_DT';
G_INVALID_SERVICE_END_DATE	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INVD_SVC_END_DT';
G_INVALID_TXN_GRP_DATE	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INVD_TXNGRP_DT';
G_TXN_GRP_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE1';
G_COV_START_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE2';
G_COV_END_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE3';
G_MISMATCH_COV_SERVICE_DATES	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INVD_SVC_COV_DT';
G_COVERAGE_START_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE1';
G_COVERAGE_END_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE2';
G_SVC_START_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE3';
G_SVC_END_DATE_TOKEN	CONSTANT VARCHAR2(200) := 'DATE4';

--------------------------------------------------------------------------------
-- PROCEDURE set_msg_no_children
--------------------------------------------------------------------------------
PROCEDURE set_msg_no_children (
	p_parent_name	IN VARCHAR2,
	p_child_name	IN VARCHAR2
) IS
-- PL/SQL Block
BEGIN
  FND_MESSAGE.set_name(G_APP_NAME, G_NO_CHILDREN_MSG);
  FND_MESSAGE.set_token('PARENT_TABLE', p_parent_name);
  FND_MESSAGE.set_token('CHILD_TABLE', p_child_name);
END set_msg_no_children;
--------------------------------------------------------------------------------
-- FUNCTION get_service_name
--------------------------------------------------------------------------------
FUNCTION get_service_name (
	p_services_rec		IN services_all_rec_type
) RETURN VARCHAR2 IS
  CURSOR get_service_name_cur (
		p_cp_service_id IN MTL_SYSTEM_ITEMS_KFV.INVENTORY_ITEM_ID%TYPE) IS
  SELECT concatenated_segments
    FROM mtl_system_items_kfv
   WHERE inventory_item_id = p_cp_service_id
	AND organization_id = FND_PROFILE.VALUE_SPECIFIC('SO_ORGANIZATION_ID');

  l_retval	get_service_name_cur%ROWTYPE;
BEGIN
  OPEN get_service_name_cur (p_services_rec.cp_service_id);
  FETCH get_service_name_cur INTO l_retval;
  IF (get_service_name_cur%NOTFOUND) THEN
    l_retval.concatenated_segments := TO_CHAR(p_services_rec.cp_service_id);
  END IF;
  CLOSE get_service_name_cur;
  RETURN (l_retval.concatenated_segments);
END get_service_name;
--------------------------------------------------------------------------------
-- FUNCTION populate_contract_rec
--------------------------------------------------------------------------------
FUNCTION populate_contract_rec (
	p_contract_id		IN CS_CONTRACTS_ALL.CONTRACT_ID%TYPE
) RETURN Contract_Rec_Type IS
  CURSOR get_contract_rec (p_contract_id IN CS_CONTRACTS_ALL.CONTRACT_ID%TYPE) IS
  SELECT *
    FROM cs_contracts_all
   WHERE contract_id = p_contract_id;

  l_contract_rec	Contract_Rec_Type;
  l_no_data_found	BOOLEAN := TRUE;
BEGIN
  OPEN get_contract_rec(p_contract_id);
  FETCH get_contract_rec INTO l_contract_rec;
  l_no_data_found := get_contract_rec%NOTFOUND;
  CLOSE get_contract_rec;

  IF (l_no_data_found) THEN
    FND_MESSAGE.set_name(G_APP_NAME, G_INVALID_VALUE);
    FND_MESSAGE.set_token('COL_NAME', 'CONTRACT_ID');
  END IF;
  RETURN (l_contract_rec);
END populate_contract_rec;
--------------------------------------------------------------------------------
-- PROCEDURE validate_contract
--------------------------------------------------------------------------------
PROCEDURE validate_contract
(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_rec             	   IN Contract_Rec_Type
) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_contract';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1);
--------------------------------------------------------------------------------
-- FUNCTION val_cov_txn_grps_children
--------------------------------------------------------------------------------
FUNCTION val_cov_txn_grps_children (
	p_coverages_rec		IN coverages_rec_type
) RETURN VARCHAR2 IS
	l_index			NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_return_error_exc	EXCEPTION;
	CURSOR chk_csr (p_coverage_id IN CS_COVERAGE_TXN_GROUPS.COVERAGE_ID%TYPE) IS
	SELECT *
	  FROM cs_coverage_txn_groups
	 WHERE coverage_id = p_coverage_id;
	l_cov_txn_grps_tbl	coverage_txn_groups_tbl_type;
	--------------------------------
	-- FUNCTION val_start_end_dates
	--------------------------------
	FUNCTION val_start_end_dates (
		p_cov_txn_grps_rec	IN coverage_txn_groups_rec_type,
		p_coverages_rec		IN coverages_rec_type
	) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_return_error_exc		EXCEPTION;
	BEGIN
    	  -- Validate START and END dates of Coverage_Txn_Groups fall within the
    	  -- START and END dates of CS_COVERAGES
	  IF (p_cov_txn_grps_rec.coverage_start_date < p_coverages_rec.start_date_active) THEN
	    FND_MESSAGE.set_name(G_APP_NAME, G_INVALID_TXN_GRP_DATE);
	    FND_MESSAGE.set_token(G_TXN_GRP_DATE_TOKEN,
			TO_CHAR(p_cov_txn_grps_rec.coverage_start_date, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_COV_START_DATE_TOKEN,
			TO_CHAR(p_coverages_rec.start_date_active, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_COV_END_DATE_TOKEN,
			TO_CHAR(p_coverages_rec.end_date_active, G_DATE_FORMAT));
	    RAISE l_return_error_exc;
	  ELSIF (p_cov_txn_grps_rec.coverage_end_date > p_coverages_rec.end_date_active) THEN
	    FND_MESSAGE.set_name(G_APP_NAME, G_INVALID_TXN_GRP_DATE);
	    FND_MESSAGE.set_token(G_TXN_GRP_DATE_TOKEN,
			TO_CHAR(p_cov_txn_grps_rec.coverage_end_date, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_COV_START_DATE_TOKEN,
			TO_CHAR(p_coverages_rec.start_date_active, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_COV_END_DATE_TOKEN, TO_CHAR(p_coverages_rec.end_date_active, G_DATE_FORMAT));
	    RAISE l_return_error_exc;
	  END IF;
       RETURN(l_return_status);
     EXCEPTION
       WHEN l_return_error_exc THEN
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN(l_return_status);
	END val_start_end_dates;
BEGIN
  FOR l_rec IN chk_csr (p_coverages_rec.coverage_id) LOOP
    l_cov_txn_grps_tbl(chk_csr%ROWCOUNT) := l_rec;
  END LOOP;

  l_index := l_cov_txn_grps_tbl.FIRST;
  LOOP
    -----------------------------------------------------------------------
    -- Validate START and END dates of Coverage_Txn_Groups fall within the
    -- START and END dates of CS_COVERAGES
    -----------------------------------------------------------------------
    l_return_status := val_start_end_dates(l_cov_txn_grps_tbl(l_index), p_coverages_rec);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;
    EXIT WHEN (l_index >= l_cov_txn_grps_tbl.LAST);
    l_index := l_cov_txn_grps_tbl.NEXT(l_index);
  END LOOP;

  RETURN(l_return_status);
EXCEPTION
  WHEN l_return_error_exc THEN
    RETURN(l_return_status);
END val_cov_txn_grps_children;
--------------------------------------------------------------------------------
-- FUNCTION cov_txn_grp_children_exist
--------------------------------------------------------------------------------
FUNCTION cov_txn_grp_children_exist (
	p_coverage_rec		IN coverages_rec_type
) RETURN BOOLEAN IS
	l_children_exist	BOOLEAN := TRUE;
	CURSOR chk_csr
		(p_coverage_id IN CS_COVERAGE_TXN_GROUPS.COVERAGE_ID%TYPE) IS
	SELECT *
	  FROM cs_coverage_txn_groups
	 WHERE coverage_id = p_coverage_id;
	l_chk_rec	chk_csr%ROWTYPE;
BEGIN
  OPEN chk_csr (p_coverage_rec.coverage_id);
  FETCH chk_csr INTO l_chk_rec;
  l_children_exist := chk_csr%FOUND;
  CLOSE chk_csr;
  RETURN(l_children_exist);
END cov_txn_grp_children_exist;
--------------------------------------------------------------------------------
-- FUNCTION val_coverage_levels_children
--------------------------------------------------------------------------------
FUNCTION val_coverage_levels_children (
	p_services_rec		IN services_all_rec_type
) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_index				NUMBER := 0;
	l_return_error_exc		EXCEPTION;
	l_children_exist		BOOLEAN := FALSE;

	CURSOR chk_csr (
		p_cp_service_id IN CS_CONTRACT_COV_LEVELS.CP_SERVICE_ID%TYPE) IS
	SELECT *
	  FROM cs_contract_cov_levels
	 WHERE cp_service_id = p_cp_service_id;

	l_cov_lvls_tbl		contract_cov_lvls_tbl_type;
     ------------------------------------------
	-- FUNCTION cov_products_children_exist --
     ------------------------------------------
	FUNCTION cov_products_children_exist (
		p_cov_lvl_rec	IN contract_cov_lvls_rec_type
	) RETURN BOOLEAN IS
	  l_retval	BOOLEAN := FALSE;
	  CURSOR chk_csr (
	    p_cov_lvl_id	IN CS_COVERED_PRODUCTS.COVERAGE_LEVEL_ID%TYPE) IS
	  SELECT *
	    FROM cs_covered_products
	   WHERE coverage_level_id = p_cov_lvl_id;

	  l_rec		chk_csr%ROWTYPE;
	BEGIN
	  OPEN chk_csr(p_cov_lvl_rec.coverage_level_id);
	  FETCH chk_csr INTO l_rec;
	  l_retval := chk_csr%FOUND;
	  CLOSE chk_csr;
	  RETURN (l_retval);
	END cov_products_children_exist;
BEGIN
  FOR l_rec IN chk_csr(p_services_rec.cp_service_id) LOOP
    l_cov_lvls_tbl(chk_csr%ROWCOUNT) := l_rec;
  END LOOP;
  IF (l_cov_lvls_tbl.COUNT > 0) THEN
	  -----------------------------------------------------------------------
	  -- If a COVERAGE_LEVEL has COVERED_PRODUCTS then ALL COVERAGE_LEVELS
	  -- must have COVERED_PRODUCTS.  Conversly, if a COVERAGE_LEVEL has no
	  -- COVERED_PRODUCTS then ALL COVERAGE_LEVEL must NOT have
	  -- COVERED_PRODUCTS.
	  -----------------------------------------------------------------------
	  l_index := l_cov_lvls_tbl.FIRST;
	  LOOP
		IF (l_index = l_cov_lvls_tbl.FIRST) THEN
			-- We set this flag only on the first record.
			l_children_exist := cov_products_children_exist(
											l_cov_lvls_tbl(l_index));
		ELSIF ((cov_products_children_exist(l_cov_lvls_tbl(l_index))) <>
			  (l_children_exist)) THEN
			FND_MESSAGE.set_name(G_APP_NAME, G_INCOMPATIBLE_CONTRACT_LEVELS);
           	FND_MESSAGE.set_token('SERVICE_ID',
								get_service_name(p_services_rec));
           	l_return_status := FND_API.G_RET_STS_ERROR;
			RAISE l_return_error_exc;
		END IF;
	    EXIT WHEN (l_index >= l_cov_lvls_tbl.LAST);
	    l_index := l_cov_lvls_tbl.NEXT(l_index);
	  END LOOP;
  ELSE -- No children in CS_CONTRACT_COVERAGE_LEVEL for CS_CP_SERVICE_ALL,
       -- RAISE ERROR
    set_msg_no_children('CS_CP_SERVICE_ALL', 'CS_CONTRACT_COVERAGE_LEVEL');
    l_return_status := FND_API.G_RET_STS_ERROR;
    RAISE l_return_error_exc;
  END IF;

  RETURN(l_return_status);
EXCEPTION
  WHEN l_return_error_exc THEN
    RETURN(l_return_status);
END val_coverage_levels_children;
--------------------------------------------------------------------------------
-- FUNCTION val_coverages_children
--------------------------------------------------------------------------------
FUNCTION val_coverages_children (
	p_services_rec		IN services_all_rec_type
) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_index			NUMBER := 0;
	l_return_error_exc	EXCEPTION;

	CURSOR chk_csr (p_coverage_id IN CS_COVERAGES.COVERAGE_ID%TYPE) IS
	SELECT *
	  FROM cs_coverages
	 WHERE coverage_id = p_coverage_id;

	l_coverages_tbl		coverages_tbl_type;
	-----------------------------------------
	-- PROCEDURE verify_cov_children_exist --
	-----------------------------------------
	PROCEDURE verify_cov_children_exist (
		p_coverages_tbl IN coverages_tbl_type
	) IS
	BEGIN
       IF (p_coverages_tbl.COUNT = 0) THEN
         set_msg_no_children('CS_CP_SERVICES_ALL', 'CS_COVERAGES');
         l_return_status := FND_API.G_RET_STS_ERROR;
         RAISE l_return_error_exc;
       END IF;
	END verify_cov_children_exist;
	---------------------------------------
	-- PROCEDURE verify_not_cov_template --
	---------------------------------------
	PROCEDURE verify_not_cov_template (
	  p_coverages_tbl IN coverages_tbl_type
	) IS
	  i	NUMBER := 0;
	BEGIN
          i := p_coverages_tbl.FIRST;
          LOOP
            IF (p_coverages_tbl(i).TEMPLATE_FLAG = 'Y') THEN
              FND_MESSAGE.set_name(G_APP_NAME, G_SERVICE_ATTACHED_TO_TEMPLATE);
              FND_MESSAGE.set_token('SERVICE_ID',get_service_name(p_services_rec));
              FND_MESSAGE.set_token('TEMPLATE_NAME', p_coverages_tbl(i).name);
	         l_return_status := FND_API.G_RET_STS_ERROR;
	         RAISE l_return_error_exc;
            END IF;
            EXIT WHEN (i >= p_coverages_tbl.LAST);
            i := p_coverages_tbl.NEXT(i);
          END LOOP;
	END verify_not_cov_template;
	--------------------------------
	-- FUNCTION val_start_end_dates
	--------------------------------
	FUNCTION val_start_end_dates (
		p_coverages_rec	IN coverages_rec_type,
		p_services_rec	IN services_all_rec_type
	) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_return_error_exc		EXCEPTION;
	BEGIN
    	  -- Validate START and END dates of Coverages fall within the
    	  -- START and END dates of CS_CP_SERVICES
	  IF ((p_coverages_rec.start_date_active <> p_services_rec.start_date_active) OR
		 (p_coverages_rec.end_date_active <> p_services_rec.end_date_active)) THEN
	    FND_MESSAGE.set_name(G_APP_NAME, G_MISMATCH_COV_SERVICE_DATES);
	    FND_MESSAGE.set_token(G_COVERAGE_START_DATE_TOKEN,
				TO_CHAR(p_coverages_rec.start_date_active, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_COVERAGE_END_DATE_TOKEN,
				TO_CHAR(p_coverages_rec.end_date_active, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_SVC_START_DATE_TOKEN,
				TO_CHAR(p_services_rec.start_date_active, G_DATE_FORMAT));
	    FND_MESSAGE.set_token(G_SVC_END_DATE_TOKEN,
				TO_CHAR(p_services_rec.end_date_active, G_DATE_FORMAT));
	    RAISE l_return_error_exc;
	  END IF;
       RETURN (l_return_status);
     EXCEPTION
       WHEN l_return_error_exc THEN
	    l_return_status := FND_API.G_RET_STS_ERROR;
         RETURN (l_return_status);
	END val_start_end_dates;
BEGIN
  FOR l_rec IN chk_csr(p_services_rec.coverage_schedule_id) LOOP
    l_coverages_tbl(chk_csr%ROWCOUNT) := l_rec;
  END LOOP;
  ------------------------------------
  -- Verify children exist in COVERAGE
  ------------------------------------
  verify_cov_children_exist(l_coverages_tbl);
  -------------------------------------------------
  -- Verify the COVERAGE is NOT a COVERAGE TEMPLATE
  -------------------------------------------------
  verify_not_cov_template(l_coverages_tbl);

  l_index := l_coverages_tbl.FIRST;
  LOOP
    ------------------------------------------------------------------
    -- Validate START and END dates of the Coverages fall withing the
    -- START and END dates of CS_CP_SERVICES
    ------------------------------------------------------------------
    l_return_status:= val_start_end_dates (l_coverages_tbl(l_index), p_services_rec);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE l_return_error_exc;
      END IF;
    ------------------------------------------------------------------------------
    -- An optional relationship exists between CS_COVERAGES and
    -- CS_COVERAGE_TXN_GRPS.
    -- Normally, no check is required, however, CS_COVERAGE_TXN_GROUPS cannot
    -- exist w/o records in CS_COV_TXN_GRP_CTRS.  Therefore, if children
    -- records exist in CS_COVERAGE_TXN_GROUPS for a given
    -- CS_COVERAGES.COVERAGE_ID, then we must verify that records also exist
    -- in CS_COV_TXN_GRP_CTRS.
    ------------------------------------------------------------------------------
    IF (cov_txn_grp_children_exist(l_coverages_tbl(l_index))) THEN
      l_return_status := val_cov_txn_grps_children (l_coverages_tbl(l_index));
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE l_return_error_exc;
      END IF;
    END IF;
    EXIT WHEN (l_index >= l_coverages_tbl.LAST);
    l_index := l_coverages_tbl.NEXT(l_index);
  END LOOP;

  RETURN(l_return_status);
EXCEPTION
  WHEN l_return_error_exc THEN
    RETURN(l_return_status);
END val_coverages_children;
--------------------------------------------------------------------------------
-- FUNCTION val_services_children
--------------------------------------------------------------------------------
FUNCTION val_services_children (
	p_contract_rec		IN contract_rec_type
) RETURN VARCHAR2 IS
	l_index			NUMBER := 0;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_return_error_exc	EXCEPTION;

	CURSOR chk_csr (p_contract_id IN CS_CONTRACTS_ALL.CONTRACT_ID%TYPE) IS
	SELECT *
	  FROM cs_cp_services_all
	 WHERE contract_id = p_contract_id;

	l_services_all_tbl	services_all_tbl_type;
  ---------------------------------
  -- FUNCTION val_services_items --
  ---------------------------------
  FUNCTION val_services_items (
	p_services_all_rec	IN services_all_rec_type,
	p_contract_rec		IN contract_rec_type
  ) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    ----------------------------------------------------------------------
    -- Check FIRST_BILL_DATE and BILLING_FREQUENCY_PERIOD are NOT NULL.
    -- While the 2 columns are allowed to be NULL in CS_CP_SERVICES_ALL,
    -- the columns should not be NULL for a contract.
    -- If the fields are null in CS_CP_SERVICES_ALL, as well as
    -- CS_CONTRACTS_ALL then give a warning.
    ----------------------------------------------------------------------
    IF ((p_services_all_rec.FIRST_BILL_DATE IS NULL)
	   AND (p_contract_rec.FIRST_BILL_DATE IS NULL)) THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
				'FIRST_BILL_DATE');
      l_return_status := TAPI_DEV_KIT.G_RET_STS_WARNING;
    END IF;

    IF ((p_services_all_rec.BILLING_FREQUENCY_PERIOD IS NULL)
	   AND (p_contract_rec.BILLING_FREQUENCY_PERIOD IS NULL)) THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
				 'BILLING_FREQUENCY_PERIOD');
      l_return_status := TAPI_DEV_KIT.G_RET_STS_WARNING;
    END IF;

    RETURN(l_return_status);
  END val_services_items;
  -------------------------------------
  -- FUNCTION check_coverage_overlap --
  -------------------------------------
  FUNCTION check_coverage_overlap (
  	p_services_rec	services_all_rec_type
  ) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_return_error_exc		EXCEPTION;
	l_overlap_flag			VARCHAR2(1) := 'N';
        CURSOR chk_csr (p_cp_service_id IN CS_CONTRACT_COV_LEVELS.CP_SERVICE_ID%TYPE) IS
        SELECT *
          FROM cs_contract_cov_levels cccl
         WHERE cp_service_id = p_cp_service_id
           AND NOT EXISTS (SELECT 'x'
                             FROM cs_covered_products ccp
                            WHERE ccp.coverage_level_id = cccl.coverage_level_id);
  BEGIN
    FOR l_rec IN chk_csr(p_services_rec.cp_service_id) LOOP
      ------------------------------------------------------------------------------
      -- Use CS_COVERAGE_SERVICE_PUB.Check_Service_Overlap to find any services
      -- that overlap each other
      ------------------------------------------------------------------------------
      CS_COVERAGE_SERVICE_PUB.check_service_overlap (
	p_api_version			=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	p_commit				=> p_commit,
	p_service_inv_item_id	=> p_services_rec.service_inventory_item_id,
	p_organization_id		=> p_services_rec.service_manufacturing_org_id,
	p_customer_product_id	=> p_services_rec.customer_product_id,
	p_coverage_level_code	=> l_rec.coverage_level_code,
     p_coverage_level_value	=> l_rec.coverage_level_value,
	p_coverage_level_id		=> l_rec.coverage_level_id,
	p_start_date_active		=> p_services_rec.start_date_active,
	p_end_date_active		=> p_services_rec.end_date_active,
	x_overlap_flag			=> l_overlap_flag,
	x_return_status		=> x_return_status,
	x_msg_count			=> x_msg_count,
	x_msg_data			=> x_msg_data);
      IF (l_overlap_flag = 'Y') THEN
	   FND_MESSAGE.set_name(G_APP_NAME, G_COVERAGE_OVERLAP);
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END LOOP;
    RETURN(l_return_status);
  EXCEPTION
    WHEN l_return_error_exc THEN
      IF (chk_csr%ISOPEN) THEN
        CLOSE chk_csr;
      END IF;
      RETURN(l_return_status);
  END check_coverage_overlap;
  -------------------------------
  -- FUNCTION val_start_end_dates
  -------------------------------
  FUNCTION val_start_end_dates (
	p_services_rec		IN services_all_rec_type,
	p_contract_rec		IN contract_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status			VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_return_error_exc		EXCEPTION;
  BEGIN
    -- Validate START and END dates of the service fall within the
    -- START and END dates of CS_CONTRACTS
    IF (p_services_rec.start_date_active < p_contract_rec.start_date_active) THEN
	   FND_MESSAGE.set_name(G_APP_NAME, G_INVALID_SERVICE_START_DATE);
	   RAISE l_return_error_exc;
    ELSIF (p_services_rec.end_date_active > p_contract_rec.end_date_active) THEN
	   FND_MESSAGE.set_name(G_APP_NAME, G_INVALID_SERVICE_END_DATE);
	   RAISE l_return_error_exc;
    END IF;
    RETURN(l_return_status);
  EXCEPTION
    WHEN l_return_error_exc THEN
      FND_MESSAGE.set_token('SERVICE_NAME', get_service_name(p_services_rec));
	 l_return_status := FND_API.G_RET_STS_ERROR;
      RETURN(l_return_status);
  END val_start_end_dates;
BEGIN
  FOR l_csr_rec IN chk_csr(p_contract_rec.contract_id) LOOP
    l_services_all_tbl(chk_csr%ROWCOUNT) := l_csr_rec;
  END LOOP;
  IF (l_services_all_tbl.COUNT = 0) THEN
    set_msg_no_children('CS_CONTRACTS_ALL', 'CS_CP_SERVICES_ALL');
    l_return_status := FND_API.G_RET_STS_ERROR;
    RAISE l_return_error_exc;
  END IF;

  -- validate all records
  l_index := l_services_all_tbl.FIRST;
  LOOP
    ---------------------------------------------------------------
    -- Validate any column values (min, max, date issues, not null)
    ---------------------------------------------------------------
    l_return_status := val_services_items(l_services_all_tbl(l_index), p_contract_rec);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;
    --------------------------------------------------------------
    -- Validate START and END dates of the service fall within the
    -- START and END dates of CS_CONTRACTS
    --------------------------------------------------------------
    l_return_status := val_start_end_dates(l_services_all_tbl(l_index), p_contract_rec);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;
    -------------------------------
    -- Validate no coverage overlap
    -------------------------------
    l_return_status := check_coverage_overlap(l_services_all_tbl(l_index));
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;
    ------------------------------------------
    -- Validate children of CS_CP_SERVICES_ALL
    ------------------------------------------
    l_return_status := val_coverage_levels_children(l_services_all_tbl(l_index));
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;

    l_return_status := val_coverages_children(l_services_all_tbl(l_index));
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_return_error_exc;
    END IF;
    EXIT WHEN (l_index >= l_services_all_tbl.LAST);
    l_index := l_services_all_tbl.NEXT(l_index);
  END LOOP;
  RETURN(l_return_status);
EXCEPTION
  WHEN l_return_error_exc THEN
    RETURN(l_return_status);
END val_services_children;
--------------------------------------------------------------------------------
-- FUNCTION val_contract_children
--------------------------------------------------------------------------------
FUNCTION val_contract_children (
	p_contract_rec		IN contract_rec_type
) RETURN VARCHAR2 IS
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
  l_return_status := val_services_children(p_contract_rec);
  RETURN(l_return_status);
END val_contract_children;
--------------------------------------------------------------------------------
-- PROCEDURE validate_contract
--------------------------------------------------------------------------------
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------------------------------------------------
    -- Validate all children of the contract
    ---------------------------------------------------------------------------
    l_return_status := val_contract_children(p_contract_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = TAPI_DEV_KIT.G_RET_STS_WARNING) THEN
	 RAISE TAPI_DEV_KIT.G_EXC_WARNING;
    END IF;

    -- Return Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MESSAGE.set_name(G_APP_NAME, G_VALIDATION_SUCCESSFUL);
    FND_MESSAGE.set_token('CONTRACT_NUMBER', p_contract_rec.contract_number);

-- COMMENTED OUT 10/23/98 JSU
--    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
    x_msg_count := 1;
    x_msg_data := FND_MESSAGE.GET;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
      APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
      APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_WARNING THEN
	 -- Just exit out of the procedure, we do not want
	 -- TAPI_DEV_KIT.HANDLE_EXCEPTIONS because the first thing it does is
	 -- rollback all transactions.
	 x_return_status := TAPI_DEV_KIT.G_RET_STS_WARNING;
      x_msg_count := 1;
	 x_msg_data := FND_MESSAGE.GET;

-- COMMENTED OUT 17-SEP-98 JSU: Forms cannot handle this style
-- of messaging
--    WHEN OTHERS THEN
--      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
--      (
--        l_api_name,
--        G_PKG_NAME,
--        'OTHERS',
--        x_msg_count,
--        x_msg_data,
--        '_Pvt'
--      );
END validate_contract;
PROCEDURE validate_contract
(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_id                  IN CS_CONTRACTS.CONTRACT_ID%TYPE
-- COMMENTED OUT 17-SEP-98 DEVELOPER/2000 FORMS uses PL/SQL 1.6 which cannot
-- handle selective parameter passing
--    p_contract_number              IN CS_CONTRACTS.CONTRACT_NUMBER%TYPE := NULL,
--    p_workflow                     IN CS_CONTRACTS.WORKFLOW%TYPE := NULL,
--    p_agreement_id                 IN CS_CONTRACTS.AGREEMENT_ID%TYPE := NULL,
--    p_price_list_id                IN CS_CONTRACTS.PRICE_LIST_ID%TYPE := NULL,
--    p_currency_code                IN CS_CONTRACTS.CURRENCY_CODE%TYPE := NULL,
--    p_conversion_type_code         IN CS_CONTRACTS.CONVERSION_TYPE_CODE%TYPE := NULL,
--    p_conversion_rate              IN CS_CONTRACTS.CONVERSION_RATE%TYPE := NULL,
--    p_conversion_date              IN CS_CONTRACTS.CONVERSION_DATE%TYPE := NULL,
--    p_invoicing_rule_id            IN CS_CONTRACTS.INVOICING_RULE_ID%TYPE := NULL,
--    p_accounting_rule_id           IN CS_CONTRACTS.ACCOUNTING_RULE_ID%TYPE := NULL,
--    p_billing_frequency_period     IN CS_CONTRACTS.BILLING_FREQUENCY_PERIOD%TYPE := NULL,
--    p_first_bill_date              IN CS_CONTRACTS.FIRST_BILL_DATE%TYPE := NULL,
--    p_next_bill_date               IN CS_CONTRACTS.NEXT_BILL_DATE%TYPE := NULL,
--    p_create_sales_order           IN CS_CONTRACTS.CREATE_SALES_ORDER%TYPE := NULL,
--    p_renewal_rule                 IN CS_CONTRACTS.RENEWAL_RULE%TYPE := NULL,
--    p_termination_rule             IN CS_CONTRACTS.TERMINATION_RULE%TYPE := NULL,
--    p_bill_to_site_use_id          IN CS_CONTRACTS.BILL_TO_SITE_USE_ID%TYPE := NULL,
--    p_contract_status_id           IN CS_CONTRACTS.CONTRACT_STATUS_ID%TYPE := NULL,
--    p_contract_type_id             IN CS_CONTRACTS.CONTRACT_TYPE_ID%TYPE := NULL,
--    p_contract_template_id         IN CS_CONTRACTS.CONTRACT_TEMPLATE_ID%TYPE := NULL,
--    p_contract_group_id            IN CS_CONTRACTS.CONTRACT_GROUP_ID%TYPE := NULL,
--    p_customer_id                  IN CS_CONTRACTS.CUSTOMER_ID%TYPE := NULL,
--    p_duration                     IN CS_CONTRACTS.DURATION%TYPE := NULL,
--    p_period_code                  IN CS_CONTRACTS.PERIOD_CODE%TYPE := NULL,
--    p_ship_to_site_use_id          IN CS_CONTRACTS.SHIP_TO_SITE_USE_ID%TYPE := NULL,
--    p_salesperson_id               IN CS_CONTRACTS.SALESPERSON_ID%TYPE := NULL,
--    p_ordered_by_contact_id        IN CS_CONTRACTS.ORDERED_BY_CONTACT_ID%TYPE := NULL,
--    p_source_code                  IN CS_CONTRACTS.SOURCE_CODE%TYPE := NULL,
--    p_source_reference             IN CS_CONTRACTS.SOURCE_REFERENCE%TYPE := NULL,
--    p_terms_id                     IN CS_CONTRACTS.TERMS_ID%TYPE := NULL,
--    p_po_number                    IN CS_CONTRACTS.PO_NUMBER%TYPE := NULL,
--    p_bill_on                      IN CS_CONTRACTS.BILL_ON%TYPE := NULL,
--    p_tax_handling                 IN CS_CONTRACTS.TAX_HANDLING%TYPE := NULL,
--    p_tax_exempt_num               IN CS_CONTRACTS.TAX_EXEMPT_NUM%TYPE := NULL,
--    p_tax_exempt_reason_code       IN CS_CONTRACTS.TAX_EXEMPT_REASON_CODE%TYPE := NULL,
--    p_contract_amount              IN CS_CONTRACTS.CONTRACT_AMOUNT%TYPE := NULL,
--    p_auto_renewal_flag            IN CS_CONTRACTS.AUTO_RENEWAL_FLAG%TYPE := NULL,
--    p_original_end_date            IN CS_CONTRACTS.ORIGINAL_END_DATE%TYPE := NULL,
--    p_terminate_reason_code        IN CS_CONTRACTS.TERMINATE_REASON_CODE%TYPE := NULL,
--    p_discount_id                  IN CS_CONTRACTS.DISCOUNT_ID%TYPE := NULL,
--    p_po_required_to_service       IN CS_CONTRACTS.PO_REQUIRED_TO_SERVICE%TYPE := NULL,
--    p_pre_payment_required         IN CS_CONTRACTS.PRE_PAYMENT_REQUIRED%TYPE := NULL,
--    p_last_update_date             IN CS_CONTRACTS.LAST_UPDATE_DATE%TYPE := NULL,
--    p_last_updated_by              IN CS_CONTRACTS.LAST_UPDATED_BY%TYPE := NULL,
--    p_creation_date                IN CS_CONTRACTS.CREATION_DATE%TYPE := NULL,
--    p_created_by                   IN CS_CONTRACTS.CREATED_BY%TYPE := NULL,
--    p_last_update_login            IN CS_CONTRACTS.LAST_UPDATE_LOGIN%TYPE := NULL,
--    p_start_date_active            IN CS_CONTRACTS.START_DATE_ACTIVE%TYPE := NULL,
--    p_end_date_active              IN CS_CONTRACTS.END_DATE_ACTIVE%TYPE := NULL,
--    p_attribute1                   IN CS_CONTRACTS.ATTRIBUTE1%TYPE := NULL,
--    p_attribute2                   IN CS_CONTRACTS.ATTRIBUTE2%TYPE := NULL,
--    p_attribute3                   IN CS_CONTRACTS.ATTRIBUTE3%TYPE := NULL,
--    p_attribute4                   IN CS_CONTRACTS.ATTRIBUTE4%TYPE := NULL,
--    p_attribute5                   IN CS_CONTRACTS.ATTRIBUTE5%TYPE := NULL,
--    p_attribute6                   IN CS_CONTRACTS.ATTRIBUTE6%TYPE := NULL,
--    p_attribute7                   IN CS_CONTRACTS.ATTRIBUTE7%TYPE := NULL,
--    p_attribute8                   IN CS_CONTRACTS.ATTRIBUTE8%TYPE := NULL,
--    p_attribute9                   IN CS_CONTRACTS.ATTRIBUTE9%TYPE := NULL,
--    p_attribute10                  IN CS_CONTRACTS.ATTRIBUTE10%TYPE := NULL,
--    p_attribute11                  IN CS_CONTRACTS.ATTRIBUTE11%TYPE := NULL,
--    p_attribute12                  IN CS_CONTRACTS.ATTRIBUTE12%TYPE := NULL,
--    p_attribute13                  IN CS_CONTRACTS.ATTRIBUTE13%TYPE := NULL,
--    p_attribute14                  IN CS_CONTRACTS.ATTRIBUTE14%TYPE := NULL,
--    p_attribute15                  IN CS_CONTRACTS.ATTRIBUTE15%TYPE := NULL,
--    p_context                      IN CS_CONTRACTS.CONTEXT%TYPE := NULL,
--    p_object_version_number        IN CS_CONTRACTS.OBJECT_VERSION_NUMBER%TYPE := NULL
) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_contract';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1);
    l_contract_rec                 Contract_Rec_Type;
BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- The calling program SHOULD pass in all appropriate parameters.
    -- However, because of the limitations of FORMS 4.5 we will populate the
    -- record ourselves.
    l_contract_rec := populate_contract_rec(p_contract_id);
--    l_contract_rec.CONTRACT_ID := p_contract_id;
--    l_contract_rec.CONTRACT_NUMBER := p_contract_number;
--    l_contract_rec.WORKFLOW := p_workflow;
--    l_contract_rec.AGREEMENT_ID := p_agreement_id;
--    l_contract_rec.PRICE_LIST_ID := p_price_list_id;
--    l_contract_rec.CURRENCY_CODE := p_currency_code;
--    l_contract_rec.CONVERSION_TYPE_CODE := p_conversion_type_code;
--    l_contract_rec.CONVERSION_RATE := p_conversion_rate;
--    l_contract_rec.CONVERSION_DATE := p_conversion_date;
--    l_contract_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
--    l_contract_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
--    l_contract_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
--    l_contract_rec.FIRST_BILL_DATE := p_first_bill_date;
--    l_contract_rec.NEXT_BILL_DATE := p_next_bill_date;
--    l_contract_rec.CREATE_SALES_ORDER := p_create_sales_order;
--    l_contract_rec.RENEWAL_RULE := p_renewal_rule;
--    l_contract_rec.TERMINATION_RULE := p_termination_rule;
--    l_contract_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
--    l_contract_rec.CONTRACT_STATUS_ID := p_contract_status_id;
--    l_contract_rec.CONTRACT_TYPE_ID := p_contract_type_id;
--    l_contract_rec.CONTRACT_TEMPLATE_ID := p_contract_template_id;
--    l_contract_rec.CONTRACT_GROUP_ID := p_contract_group_id;
--    l_contract_rec.CUSTOMER_ID := p_customer_id;
--    l_contract_rec.DURATION := p_duration;
--    l_contract_rec.PERIOD_CODE := p_period_code;
--    l_contract_rec.SHIP_TO_SITE_USE_ID := p_ship_to_site_use_id;
--    l_contract_rec.SALESPERSON_ID := p_salesperson_id;
--    l_contract_rec.ORDERED_BY_CONTACT_ID := p_ordered_by_contact_id;
--    l_contract_rec.SOURCE_CODE := p_source_code;
--    l_contract_rec.SOURCE_REFERENCE := p_source_reference;
--    l_contract_rec.TERMS_ID := p_terms_id;
--    l_contract_rec.PO_NUMBER := p_po_number;
--    l_contract_rec.BILL_ON := p_bill_on;
--    l_contract_rec.TAX_HANDLING := p_tax_handling;
--    l_contract_rec.TAX_EXEMPT_NUM := p_tax_exempt_num;
--    l_contract_rec.TAX_EXEMPT_REASON_CODE := p_tax_exempt_reason_code;
--    l_contract_rec.CONTRACT_AMOUNT := p_contract_amount;
--    l_contract_rec.AUTO_RENEWAL_FLAG := p_auto_renewal_flag;
--    l_contract_rec.ORIGINAL_END_DATE := p_original_end_date;
--    l_contract_rec.TERMINATE_REASON_CODE := p_terminate_reason_code;
--    l_contract_rec.DISCOUNT_ID := p_discount_id;
--    l_contract_rec.PO_REQUIRED_TO_SERVICE := p_po_required_to_service;
--    l_contract_rec.PRE_PAYMENT_REQUIRED := p_pre_payment_required;
--    l_contract_rec.LAST_UPDATE_DATE := p_last_update_date;
--    l_contract_rec.LAST_UPDATED_BY := p_last_updated_by;
--    l_contract_rec.CREATION_DATE := p_creation_date;
--    l_contract_rec.CREATED_BY := p_created_by;
--    l_contract_rec.LAST_UPDATE_LOGIN := p_last_update_login;
--    l_contract_rec.START_DATE_ACTIVE := p_start_date_active;
--    l_contract_rec.END_DATE_ACTIVE := p_end_date_active;
--    l_contract_rec.ATTRIBUTE1 := p_attribute1;
--    l_contract_rec.ATTRIBUTE2 := p_attribute2;
--    l_contract_rec.ATTRIBUTE3 := p_attribute3;
--    l_contract_rec.ATTRIBUTE4 := p_attribute4;
--    l_contract_rec.ATTRIBUTE5 := p_attribute5;
--    l_contract_rec.ATTRIBUTE6 := p_attribute6;
--    l_contract_rec.ATTRIBUTE7 := p_attribute7;
--    l_contract_rec.ATTRIBUTE8 := p_attribute8;
--    l_contract_rec.ATTRIBUTE9 := p_attribute9;
--    l_contract_rec.ATTRIBUTE10 := p_attribute10;
--    l_contract_rec.ATTRIBUTE11 := p_attribute11;
--    l_contract_rec.ATTRIBUTE12 := p_attribute12;
--    l_contract_rec.ATTRIBUTE13 := p_attribute13;
--    l_contract_rec.ATTRIBUTE14 := p_attribute14;
--    l_contract_rec.ATTRIBUTE15 := p_attribute15;
--    l_contract_rec.CONTEXT := p_context;
--    l_contract_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_contract(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contract_rec
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
      APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
      APP_EXCEPTION.RAISE_EXCEPTION;
-- COMMENTED OUT 17-SEP-98 JSU: Forms cannot handle this style
-- of messaging
--    WHEN OTHERS THEN
--      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
--      (
--        l_api_name,
--        G_PKG_NAME,
--        'OTHERS',
--        x_msg_count,
--        x_msg_data,
--        '_Pvt'
--      );
END validate_contract;


PROCEDURE update_contract
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_number              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_workflow                     IN CS_CONTRACTS.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow_process_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_agreement_id                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CONTRACTS.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type_code         IN CS_CONTRACTS.CONVERSION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CONTRACTS.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_billing_frequency_period     IN CS_CONTRACTS.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_first_bill_date              IN CS_CONTRACTS.FIRST_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_next_bill_date               IN CS_CONTRACTS.NEXT_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_create_sales_order           IN CS_CONTRACTS.CREATE_SALES_ORDER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_rule                 IN CS_CONTRACTS.RENEWAL_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_rule             IN CS_CONTRACTS.TERMINATION_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_status_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_group_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_customer_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_period_code                  IN CS_CONTRACTS.PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ship_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_salesperson_id               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_ordered_by_contact_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_source_code                  IN CS_CONTRACTS.SOURCE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_source_reference             IN CS_CONTRACTS.SOURCE_REFERENCE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terms_id                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_po_number                    IN CS_CONTRACTS.PO_NUMBER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_bill_on                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_handling                 IN CS_CONTRACTS.TAX_HANDLING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_num               IN CS_CONTRACTS.TAX_EXEMPT_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_reason_code       IN CS_CONTRACTS.TAX_EXEMPT_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_amount              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_auto_renewal_flag            IN CS_CONTRACTS.AUTO_RENEWAL_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_original_end_date            IN CS_CONTRACTS.ORIGINAL_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_terminate_reason_code        IN CS_CONTRACTS.TERMINATE_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_po_required_to_service       IN CS_CONTRACTS.PO_REQUIRED_TO_SERVICE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pre_payment_required         IN CS_CONTRACTS.PRE_PAYMENT_REQUIRED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACTS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACTS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACTS.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACTS.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACTS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACTS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACTS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACTS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACTS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACTS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACTS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACTS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACTS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACTS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACTS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACTS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACTS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACTS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACTS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACTS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_contract';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contract_rec                 CS_CONTRACT_PVT.Contract_Val_Rec_Type;
    p_old_status_id            	   CS_CONTRACTS.CONTRACT_STATUS_ID%TYPE;
    p_new_status_id                CS_CONTRACTS.CONTRACT_STATUS_ID%TYPE;
    p_inv_flag		           CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Get the old status id

    SELECT contract_status_id
	INTO p_old_status_id
        FROM CS_CONTRACTS
    WHERE contract_id = p_contract_id;

    l_contract_rec.CONTRACT_ID := p_contract_id;
    l_contract_rec.CONTRACT_NUMBER := p_contract_number;
    l_contract_rec.WORKFLOW := p_workflow;
    l_contract_rec.WORKFLOW_PROCESS_ID := p_workflow_process_id;
    l_contract_rec.AGREEMENT_ID := p_agreement_id;
    l_contract_rec.PRICE_LIST_ID := p_price_list_id;
    l_contract_rec.CURRENCY_CODE := p_currency_code;
    l_contract_rec.CONVERSION_TYPE_CODE := p_conversion_type_code;
    l_contract_rec.CONVERSION_RATE := p_conversion_rate;
    l_contract_rec.CONVERSION_DATE := p_conversion_date;
    l_contract_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_contract_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_contract_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_contract_rec.FIRST_BILL_DATE := p_first_bill_date;
    l_contract_rec.NEXT_BILL_DATE := p_next_bill_date;
    l_contract_rec.CREATE_SALES_ORDER := p_create_sales_order;
    l_contract_rec.RENEWAL_RULE := p_renewal_rule;
    l_contract_rec.TERMINATION_RULE := p_termination_rule;
    l_contract_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_contract_rec.CONTRACT_STATUS_ID := p_contract_status_id;
    l_contract_rec.CONTRACT_TYPE_ID := p_contract_type_id;
    l_contract_rec.CONTRACT_TEMPLATE_ID := p_contract_template_id;
    l_contract_rec.CONTRACT_GROUP_ID := p_contract_group_id;
    l_contract_rec.CUSTOMER_ID := p_customer_id;
    l_contract_rec.DURATION := p_duration;
    l_contract_rec.PERIOD_CODE := p_period_code;
    l_contract_rec.SHIP_TO_SITE_USE_ID := p_ship_to_site_use_id;
    l_contract_rec.SALESPERSON_ID := p_salesperson_id;
    l_contract_rec.ORDERED_BY_CONTACT_ID := p_ordered_by_contact_id;
    l_contract_rec.SOURCE_CODE := p_source_code;
    l_contract_rec.SOURCE_REFERENCE := p_source_reference;
    l_contract_rec.TERMS_ID := p_terms_id;
    l_contract_rec.PO_NUMBER := p_po_number;
    l_contract_rec.BILL_ON := p_bill_on;
    l_contract_rec.TAX_HANDLING := p_tax_handling;
    l_contract_rec.TAX_EXEMPT_NUM := p_tax_exempt_num;
    l_contract_rec.TAX_EXEMPT_REASON_CODE := p_tax_exempt_reason_code;
    l_contract_rec.CONTRACT_AMOUNT := p_contract_amount;
    l_contract_rec.AUTO_RENEWAL_FLAG := p_auto_renewal_flag;
    l_contract_rec.ORIGINAL_END_DATE := p_original_end_date;
    l_contract_rec.TERMINATE_REASON_CODE := p_terminate_reason_code;
    l_contract_rec.DISCOUNT_ID := p_discount_id;
    l_contract_rec.PO_REQUIRED_TO_SERVICE := p_po_required_to_service;
    l_contract_rec.PRE_PAYMENT_REQUIRED := p_pre_payment_required;
    l_contract_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contract_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contract_rec.CREATION_DATE := p_creation_date;
    l_contract_rec.CREATED_BY := p_created_by;
    l_contract_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contract_rec.START_DATE_ACTIVE := p_start_date_active;
    l_contract_rec.END_DATE_ACTIVE := p_end_date_active;
    l_contract_rec.ATTRIBUTE1 := p_attribute1;
    l_contract_rec.ATTRIBUTE2 := p_attribute2;
    l_contract_rec.ATTRIBUTE3 := p_attribute3;
    l_contract_rec.ATTRIBUTE4 := p_attribute4;
    l_contract_rec.ATTRIBUTE5 := p_attribute5;
    l_contract_rec.ATTRIBUTE6 := p_attribute6;
    l_contract_rec.ATTRIBUTE7 := p_attribute7;
    l_contract_rec.ATTRIBUTE8 := p_attribute8;
    l_contract_rec.ATTRIBUTE9 := p_attribute9;
    l_contract_rec.ATTRIBUTE10 := p_attribute10;
    l_contract_rec.ATTRIBUTE11 := p_attribute11;
    l_contract_rec.ATTRIBUTE12 := p_attribute12;
    l_contract_rec.ATTRIBUTE13 := p_attribute13;
    l_contract_rec.ATTRIBUTE14 := p_attribute14;
    l_contract_rec.ATTRIBUTE15 := p_attribute15;
    l_contract_rec.CONTEXT := p_context;
    l_contract_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    CS_CONTRACT_PVT.update_row(
      	p_api_version,
      	p_init_msg_list,
      	p_validation_level,
      	p_commit,
      	x_return_status,
      	x_msg_count,
      	x_msg_data,
      	l_contract_rec,
      	x_object_version_number
    );

    --- Get the new status id after the update

    SELECT contract_status_id
	INTO p_new_status_id
        FROM CS_CONTRACTS
    WHERE contract_id = l_contract_rec.contract_id;

    SELECT eligible_for_invoicing
	INTO p_inv_flag
	FROM CS_CONTRACT_STATUSES
	WHERE contract_status_id = p_new_status_id;

    --- Call update service if status changes
    IF l_contract_rec.contract_status_id <> TAPI_DEV_KIT.G_MISS_NUM  and
		p_old_status_id <> p_new_status_id
-- COMMENTED OUT 22-FEB-1999 AS PER REQUESTED BY SKARUPPASAMY -- JSU
--		and p_inv_flag = 'Y'
    THEN
	for l_servicerec in (
			Select cp_service_id from cs_cp_services
			where contract_id = l_contract_rec.contract_id
			and contract_line_status_id = p_old_status_id)
	LOOP
		--- Call update service
		CS_SERVICES_PVT.Update_Service
  		(
    		p_api_version                  => 1.0,
    		p_init_msg_list                => TAPI_DEV_KIT.G_FALSE,
    		p_validation_level             => 100,
    		p_commit                       => TAPI_DEV_KIT.G_FALSE,
    		x_return_status                => x_return_status,
    		x_msg_count                    => x_msg_count,
    		x_msg_data                     => x_msg_data,
    		p_cp_service_id                => l_servicerec.cp_service_id,
    		p_contract_line_status_id      => p_new_status_id,
    		p_last_update_date             => sysdate,
    		p_last_updated_by              => FND_GLOBAL.user_id
		);
	END LOOP;
    END IF;

    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END Update_Contract;

BEGIN
  null;
END cs_contracts_pub;

/
