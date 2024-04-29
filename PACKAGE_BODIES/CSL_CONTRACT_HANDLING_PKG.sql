--------------------------------------------------------
--  DDL for Package Body CSL_CONTRACT_HANDLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CONTRACT_HANDLING_PKG" AS
/* $Header: cslctrhb.pls 120.0 2005/05/25 11:06:41 appldev noship $ */

/*** Globals ***/

-- CSL_SR_CONTRACT_HEADERS
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSL_SR_CONTRACT_HEADERS_ACC';
g_publication_item_name1 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_SR_CONTRACT_HEADERS');
g_table_name1            CONSTANT VARCHAR2(30) := 'CSL_SR_CONTRACT_HEADERS';
g_pk1_name1              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';

-- CSL_CONTR_BUSS_PROCESSES
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSL_CONTR_BUSS_PROCESSES_ACC';
g_publication_item_name2 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CONTR_BUSS_PROCESSES');
g_table_name2            CONSTANT VARCHAR2(30) := 'CSL_CONTR_BUSS_PROCESSES';
g_pk1_name2              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_pk2_name2              CONSTANT VARCHAR2(30) := 'BUSINESS_PROCESS_ID';

-- CSL_CONTR_BUSS_TXN_TYPES
g_acc_table_name3        CONSTANT VARCHAR2(30) := 'CSL_CONTR_BUSS_TXN_TYPES_ACC';
g_publication_item_name3 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
  JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CONTR_BUSS_TXN_TYPES');
g_table_name3            CONSTANT VARCHAR2(30) := 'CSL_CONTR_BUSS_TXN_TYPES';
g_pk1_name3              CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_pk2_name3              CONSTANT VARCHAR2(30) := 'TXN_BILLING_TYPE_ID';
g_pk3_name3              CONSTANT VARCHAR2(30) := 'BUSINESS_PROCESS_ID';


g_debug_level           NUMBER; -- debug level

FUNCTION INSERT_TXN_TYPES_RECORD
  ( p_incident_id         IN NUMBER
  , p_txn_billing_type_id IN NUMBER
  , p_cov_txn_grp_line_id IN NUMBER
  , p_bp_id               IN NUMBER
  , p_up_to_amount        IN VARCHAR2
  , p_percent_covered     IN VARCHAR2
  )
RETURN BOOLEAN
IS
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_TXN_TYPES_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  INSERT INTO CSL_CONTR_BUSS_TXN_TYPES
    ( INCIDENT_ID
    , TXN_BILLING_TYPE_ID
    , BUSINESS_PROCESS_ID
    , CONTRACT_SERVICE_ID
    , UP_TO_AMOUNT
    , PERCENT_COVERED
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    )
    VALUES
    ( p_incident_id
    , p_txn_billing_type_id
    , p_bp_id
    , p_cov_txn_grp_line_id
    , p_up_to_amount
    , p_percent_covered
    , sysdate
    , 1
    , sysdate
    , 1
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_TXN_TYPES_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_TXN_TYPES_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN FALSE;
END INSERT_TXN_TYPES_RECORD;


/* Function will get the Txn types and the related settings of it          **
**   - Up to amount                                                        **
**   - Percent covered                                                     **
** and will insert these into the CSL-Contract txn types table             */
FUNCTION INSERT_CONTRACT_TXN_TYPES
  ( p_incident_id         IN NUMBER
  , p_cov_txn_grp_line_id IN NUMBER
  , p_business_process_id IN NUMBER
  , p_resource_id         IN NUMBER
  )
RETURN NUMBER
IS

  --Fix for Bug #3478401
  CURSOR c_csl_contr_txn_types ( b_incident_id         NUMBER
                             , b_txn_bill_type_id NUMBER
                             , b_bp_id               NUMBER
                             , b_cov_txn_grp_line_id     NUMBER) IS
  SELECT null
  FROM CSL_CONTR_BUSS_TXN_TYPES
  WHERE INCIDENT_ID         = b_incident_id
  AND   TXN_BILLING_TYPE_ID = b_txn_bill_type_id
  AND   BUSINESS_PROCESS_ID = b_bp_id
  AND   CONTRACT_SERVICE_ID = b_cov_txn_grp_line_id;

  r_csl_contr_txn_types c_csl_contr_txn_types%ROWTYPE;

  l_oks_out_tbl_bt OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BT;
  l_oks_out_tbl_br OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BR;

  l_effected_records NUMBER := 0;
  l_success       BOOLEAN;

  p_init_msg_list VARCHAR2(4000);
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(4000);
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_CONTRACT_TXN_TYPES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  /* This call to the Contracts API will return the Txn billing types in table
   ** variable: l_oks_out_tbl_bt
   ** This table should contain the following information:
   **   Txn_BT_line_id      (NUMBER): Txn billing type id
   **   txn_billing_type_id (NUMBER): Business process if
   **   Covered_upto_amount (NUMBER): Upto amount covered
   **   percent_covered     (NUMBER): percent_covered
  */
  OKS_ENTITLEMENTS_PUB.Get_txn_billing_types
     (  p_api_version       => 1.0
        , p_init_msg_list     => p_init_msg_list
        , p_cov_txngrp_line_id=> p_cov_txn_grp_line_id
        , p_return_bill_rates_YN => 'N' -- Not interested on the billing rates
        , x_return_status     => x_return_status
        , x_msg_count         => x_msg_count
        , x_msg_data          => x_msg_data
        , x_txn_bill_types    => l_oks_out_tbl_bt
        , x_txn_bill_rates    => l_oks_out_tbl_br -- Should return null
     );
  IF l_oks_out_tbl_bt.COUNT > 0 THEN
    /* Looping over the table if table contain any record(s) */
    FOR i IN l_oks_out_tbl_bt.FIRST .. l_oks_out_tbl_bt.LAST LOOP

	--Modified to fix Bug #3478401
        OPEN c_csl_contr_txn_types
             ( p_incident_id
             , l_oks_out_tbl_bt(i).txn_bill_type_id
             , p_business_process_id
             , p_cov_txn_grp_line_id
             );

	FETCH c_csl_contr_txn_types INTO r_csl_contr_txn_types;
        IF c_csl_contr_txn_types%NOTFOUND THEN
          /* Insert the new Txn bill type record into the CSL contract table */
          l_success := INSERT_TXN_TYPES_RECORD
                          ( p_incident_id         => p_incident_id
                          , p_txn_billing_type_id => l_oks_out_tbl_bt(i).txn_bill_type_id
                          , p_cov_txn_grp_line_id => p_cov_txn_grp_line_id
                          , p_bp_id               => p_business_process_id
                          , p_up_to_amount        => l_oks_out_tbl_bt(i).Covered_upto_amount
                          , p_percent_covered     => l_oks_out_tbl_bt(i).percent_covered
                          );
        ELSE
          l_success := TRUE;
        END IF;
        CLOSE c_csl_contr_txn_types;

        IF l_success THEN
          -- Push record to the Resource (insert in ACC)
          IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( l_oks_out_tbl_bt(i).txn_bt_line_id
            , g_table_name3
            , 'Inserting ACC record for resource_id = ' || p_resource_id
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
            , 'csl_contract_handling_pkg');
          END IF;

          JTM_HOOK_UTIL_PKG.Insert_Acc
            ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
             ,P_ACC_TABLE_NAME         => g_acc_table_name3
             ,P_RESOURCE_ID            => p_resource_id
             ,P_PK1_NAME               => g_pk1_name3
             ,P_PK1_NUM_VALUE          => p_incident_id
             ,P_PK2_NAME               => g_pk2_name3
             ,P_PK2_NUM_VALUE          => l_oks_out_tbl_bt(i).txn_bill_type_id
             ,P_PK3_NAME               => g_pk3_name3
             ,P_PK3_NUM_VALUE          => p_business_process_id
            );

          /* increase effected records if a new  record has been created */
          l_effected_records := l_effected_records + 1;
        END IF;

    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_CONTRACT_TXN_TYPES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN l_effected_records;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_CONTRACT_TXN_TYPES'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN l_effected_records;
END INSERT_CONTRACT_TXN_TYPES;

FUNCTION INSERT_BUSS_PROCESSES_RECORD
  ( p_incident_id         IN  NUMBER
  , p_cov_txn_grp_line_id IN  NUMBER
  , p_bp_id               IN  NUMBER
  , p_start_date          IN  DATE
  , p_end_date            IN  DATE
  )
RETURN BOOLEAN
IS
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_BUSS_PROCESSES_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  INSERT INTO CSL_CONTR_BUSS_PROCESSES
    ( INCIDENT_ID
    , BUSINESS_PROCESS_ID
    , CONTRACT_SERVICE_ID
    , START_DATE
    , END_DATE
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    )
    VALUES
    ( p_incident_id
    , p_bp_id
    , p_cov_txn_grp_line_id
    , p_start_date
    , p_end_date
    , sysdate
    , 1
    , sysdate
    , 1
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_BUSS_PROCESSES_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_BUSS_PROCESSES_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN FALSE;
END INSERT_BUSS_PROCESSES_RECORD;

/* Function will get the field service related buss_processes of           **
** the Contract Line and will insert the details of these buss_processes   **
** into the CSL-Contract buss process table                                */
FUNCTION INSERT_CONTRACT_BUSS_PROCESSES
  ( p_incident_id         IN NUMBER
  , p_contract_service_id IN NUMBER
  , p_resource_id         IN NUMBER
  )
RETURN NUMBER
IS
CURSOR c_csl_contr_bus_proc (b_incident_id NUMBER, b_cov_txn_grp_line_id NUMBER, b_bp_id NUMBER) IS
   SELECT null
   FROM CSL_CONTR_BUSS_PROCESSES
   WHERE INCIDENT_ID         = b_incident_id
   AND   BUSINESS_PROCESS_ID = b_bp_id
   AND   CONTRACT_SERVICE_ID = b_cov_txn_grp_line_id;

  r_csl_contr_bus_proc c_csl_contr_bus_proc%ROWTYPE;

  l_oks_in_rec_bp  OKS_ENTITLEMENTS_PUB.INP_REC_BP;
  l_oks_out_tbl_bp OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BP;

  l_effected_records NUMBER := 0;
  l_rec           NUMBER := 0;
  l_success       BOOLEAN;

  p_init_msg_list VARCHAR2(4000);
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(4000);
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_CONTRACT_BUSS_PROCESSES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  /* The l_oks_rec_bp should contain the information about the contract line
   ** which the information should get from and the flags will make the criteria
   ** of the result set which you're interest in
  */
  l_oks_in_rec_bp.contract_line_id := p_contract_service_id;
  /* Y: API will check the business process definition */
  l_oks_in_rec_bp.check_bp_def     := 'Y';
  /* Y: Validate with Service Request enabled flag of the bus-proc  */
  l_oks_in_rec_bp.sr_enabled       := 'Y';
  /* N: Don't validate with Depot Repair enabled flag of the bus-proc */
  /* BUG 2641172: Pass NULL i.o. 'N' */
  /* l_oks_in_rec_bp.dr_enabled       := 'N';  */
  /* Y: Validate with Field Service enabled flag of the bus-proc */
  l_oks_in_rec_bp.fs_enabled       := 'Y';


  /* This call to the Contracts API will return the business processes in table
   ** variable: l_oks_out_tbl_bp
   ** This table should contain the following information:
   **   cov_txn_grp_line_id (NUMBER): Contract line id for business process
   **   bp_id               (NUMBER): Business Process ID
   **   start_date          (DATE)  : Start Date for business process
   **   end_date            (DATE)  : End Date for business process              */
  OKS_ENTITLEMENTS_PUB.Get_cov_txn_groups
		(  p_api_version       => 1.0
		 , p_init_msg_list     => p_init_msg_list
		 , p_inp_rec_bp        => l_oks_in_rec_bp
		 , x_return_status     => x_return_status
		 , x_msg_count         => x_msg_count
		 , x_msg_data          => x_msg_data
		 , x_cov_txn_grp_lines => l_oks_out_tbl_bp
		);
  IF l_oks_out_tbl_bp.COUNT > 0 THEN
    /* Looping over the table if table contain any record(s) */
    FOR i IN l_oks_out_tbl_bp.FIRST .. l_oks_out_tbl_bp.LAST LOOP

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_incident_id
        , g_table_name1
        , 'Processing business_process_id ' || l_oks_out_tbl_bp(i).bp_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , 'csl_contract_handling_pkg');
      END IF;

      OPEN c_csl_contr_bus_proc
           ( p_incident_id
           , l_oks_out_tbl_bp(i).cov_txn_grp_line_id
           , l_oks_out_tbl_bp(i).bp_id
           );
      FETCH c_csl_contr_bus_proc INTO r_csl_contr_bus_proc;
      IF c_csl_contr_bus_proc%NOTFOUND THEN
        /* Insert the new bus proc record into the CSL contract table */
        l_success := INSERT_BUSS_PROCESSES_RECORD
                        ( p_incident_id         => p_incident_id
                          , p_cov_txn_grp_line_id => l_oks_out_tbl_bp(i).cov_txn_grp_line_id
                          , p_bp_id               => l_oks_out_tbl_bp(i).bp_id
                          , p_start_date          => l_oks_out_tbl_bp(i).start_date
                          , p_end_date            => l_oks_out_tbl_bp(i).end_date
                        );
      ELSE
        l_success := TRUE;
      END IF;
      CLOSE c_csl_contr_bus_proc;

      IF l_success THEN

        /* Insert all the Txn Billing Types for the Bus-proc */
        l_rec := INSERT_CONTRACT_TXN_TYPES
             ( p_incident_id         => p_incident_id
             , p_cov_txn_grp_line_id => l_oks_out_tbl_bp(i).cov_txn_grp_line_id
             , p_business_process_id => l_oks_out_tbl_bp(i).bp_id
             , p_resource_id         => p_resource_id
             );

        -- Push record to the Resource (insert in ACC)
        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( l_oks_out_tbl_bp(i).bp_id
          , g_table_name2
          , 'Inserting ACC record for resource_id = ' || p_resource_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          , 'csl_contract_handling_pkg');
        END IF;

        JTM_HOOK_UTIL_PKG.Insert_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
           ,P_ACC_TABLE_NAME         => g_acc_table_name2
           ,P_RESOURCE_ID            => p_resource_id
           ,P_PK1_NAME               => g_pk1_name2
           ,P_PK1_NUM_VALUE          => p_incident_id
           ,P_PK2_NAME               => g_pk2_name2
           ,P_PK2_NUM_VALUE          => l_oks_out_tbl_bp(i).bp_id
          );

        /* increase effected records if a new  record has been created */
        l_effected_records := l_effected_records + 1;
      END IF;

    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_CONTRACT_BUSS_PROCESSES'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN l_effected_records;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_CONTRACT_BUSS_PROCESSES'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN l_effected_records;
END INSERT_CONTRACT_BUSS_PROCESSES;

FUNCTION INSERT_CONTRACT_HEADER_RECORD
  ( p_incident_id         IN  NUMBER
  , p_cov_txn_grp_line_id IN  NUMBER
  , p_contract_number     IN  VARCHAR2
  , p_service_name        IN  VARCHAR2
  , p_service_description IN  VARCHAR2
  , p_amount_uom_code     IN  VARCHAR2
  )
RETURN BOOLEAN
IS
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_CONTRACT_HEADER_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  INSERT INTO CSL_SR_CONTRACT_HEADERS
    ( INCIDENT_ID
    , CONTRACT_SERVICE_ID
    , CONTRACT_NUMBER
    , SERVICE_NAME
    , SERVICE_DESCRIPTION
    , AMOUNT_UOM_CODE
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    )
    VALUES
    ( p_incident_id
    , p_cov_txn_grp_line_id
    , p_contract_number
    , p_service_name
    , p_service_description
    , p_amount_uom_code
    , sysdate
    , 1
    , sysdate
    , 1
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_CONTRACT_HEADER_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_CONTRACT_HEADER_RECORD'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN FALSE;
END INSERT_CONTRACT_HEADER_RECORD;

/* Function will get the details of the Contract Line             **
** and will insert the details into the CSL-Contract header table */
FUNCTION INSERT_CONTRACT_HEADER
  ( p_incident_id IN NUMBER
  , p_resource_id IN NUMBER
  )
RETURN BOOLEAN
IS

--Added sts_code = 'ACTIVE' to fix bug #3484383
CURSOR c_csl_contract_line_details (b_incident_id NUMBER ) IS
  select l.id
  ,      h.contract_number
  ,      s.name
  ,      s.description
  ,      l.currency_code
  from okc_k_headers_b    h
  ,    okc_k_lines_b      l
  ,    Okx_System_Items_V s
  ,    Okc_K_Items        IT
  ,    CS_INCIDENTS_ALL_B cs
  where cs.INCIDENT_ID         = b_incident_id
  and   cs.CONTRACT_SERVICE_ID = l.id
  and   h.id                   = l.dnz_chr_id
  and   l.id                   = it.CLE_ID
  AND   s.Id1                  = to_number(IT.Object1_Id1)
  AND   s.Id2                  = to_number(IT.Object1_Id2)
  AND   h.sts_code             = 'ACTIVE';

CURSOR c_csl_contr_record (b_incident_id NUMBER) IS
  SELECT NULL
  FROM   CSL_SR_CONTRACT_HEADERS
  WHERE  INCIDENT_ID = b_incident_id;

  r_csl_contr_record    c_csl_contr_record%ROWTYPE;

  l_success             BOOLEAN := FALSE;
  l                     NUMBER;

  l_contract_service_id NUMBER;
  l_contract_nuber      VARCHAR2(120);
  l_service_name        VARCHAR2(120);
  l_service_description VARCHAR2(2000);
  l_amount_uom_code     VARCHAR2(30);
  l_return              BOOLEAN;

--Added by UTEKUMAL on 04-Mar-2004 to fix Bug #3478401
CURSOR c_csl_contract_service_id (b_incident_id NUMBER) IS
    SELECT CONTRACT_SERVICE_ID
    FROM CS_INCIDENTS_ALL_B CS
    WHERE CS.incident_id = b_incident_id;

BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering INSERT_CONTRACT_HEADER'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  OPEN c_csl_contr_record(p_incident_id);
  FETCH c_csl_contr_record INTO r_csl_contr_record;
  IF c_csl_contr_record%NOTFOUND THEN

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Contract Line for INCIDENT_ID: ' || p_incident_id || ' does not exist in CSL_SR_CONTRACT_HEADERS'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , 'csl_contract_handling_pkg');

      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Getting the details of the Contract Line for INCIDENT_ID: ' || p_incident_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , 'csl_contract_handling_pkg');
    END IF;

    OPEN c_csl_contract_line_details(p_incident_id);
    FETCH c_csl_contract_line_details INTO l_contract_service_id
                                         , l_contract_nuber
                                         , l_service_name
                                         , l_service_description
                                         , l_amount_uom_code;
    IF c_csl_contract_line_details%NOTFOUND THEN
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_incident_id
        , g_table_name1
        , 'No data found in CURSOR Contract Line for INCIDENT_ID: ' || p_incident_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , 'csl_contract_handling_pkg');
      END IF;
    ELSE

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( p_incident_id
        , g_table_name1
        , 'Details of Contract Line for INCIDENT_ID: ' || p_incident_id
          || ', CONTRACT_SERVICE_ID: ' || l_contract_service_id
          || ', CONTRACT_SERVICE_ID: ' || l_contract_nuber
          || ', CONTRACT_SERVICE_ID: ' || l_service_name
          || ', CONTRACT_SERVICE_ID: ' || l_service_description
          || ', CONTRACT_SERVICE_ID: ' || l_amount_uom_code
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , 'csl_contract_handling_pkg');
      END IF;

      /* Insert the new contract line record into the CSL contract table */
      l_success := INSERT_CONTRACT_HEADER_RECORD
                          ( p_incident_id         => p_incident_id
                          , p_cov_txn_grp_line_id => l_contract_service_id
                          , p_contract_number     => l_contract_nuber
                          , p_service_name        => l_service_name
                          , p_service_description => l_service_description
                          , p_amount_uom_code     => l_amount_uom_code
                          );
    END IF;
    CLOSE c_csl_contract_line_details;
  ELSE
    l_success := TRUE;
  END IF;
  CLOSE c_csl_contr_record;

  IF l_success THEN
    --Fix for Bug #3478401
    IF l_contract_service_id IS NULL THEN
        OPEN c_csl_contract_service_id(p_incident_id);
        FETCH c_csl_contract_service_id INTO l_contract_service_id;
        CLOSE c_csl_contract_service_id;
    END IF;

    l := INSERT_CONTRACT_BUSS_PROCESSES
                ( p_incident_id         => p_incident_id
                , p_contract_service_id => l_contract_service_id
                , p_resource_id         => p_resource_id
                );

    -- Push record to the Resource (insert in ACC)
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Inserting ACC record for resource_id = ' || p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , 'csl_contract_handling_pkg');
    END IF;

    -- Bug 3107687 fix:
    -- check if bus process is not empty insert header info to acc table.
    IF l > 0 THEN

      JTM_HOOK_UTIL_PKG.Insert_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
         ,P_ACC_TABLE_NAME         => g_acc_table_name1
         ,P_RESOURCE_ID            => p_resource_id
         ,P_PK1_NAME               => g_pk1_name1
         ,P_PK1_NUM_VALUE          => p_incident_id
        );

      -- ER 3168529 - Support for contract notes
      l_return := CSL_JTF_NOTES_ACC_PKG.PRE_INSERT_CHILDREN
                 ( P_SOURCE_OBJ_ID   => l_contract_service_id
                   , P_SOURCE_OBJ_CODE => 'OKS_COV_NOTE'
                   , P_RESOURCE_ID     => p_resource_id
                 );

      IF NOT(l_return) THEN
        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( l_contract_service_id
          , g_table_name1
          , 'Inserting Contract Notes Failed for resource_id = '
             || p_resource_id
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          , 'csl_contract_handling_pkg');
        END IF;
      END IF;

    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving INSERT_CONTRACT_HEADER'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in INSERT_CONTRACT_HEADER'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
    RETURN FALSE;
END INSERT_CONTRACT_HEADER;


/* Will delete all the sr-contract acc records for all mobile resources */
  -- ER 3168529 - Support for contract notes. Added a new parameter
  -- p_contract_service_id
PROCEDURE DELETE_SR_CONTRACT_ACC
  ( p_incident_id         IN NUMBER
  , p_resource_id         IN NUMBER
    , p_contract_service_id IN NUMBER
  )
IS
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering DELETE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Deleting Header ACC record for resource_id = ' || p_resource_id || ', incident_id = ' || p_incident_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg'
    );
  END IF;

  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
     ,P_ACC_TABLE_NAME         => g_acc_table_name1
     ,P_PK1_NAME               => g_pk1_name1
     ,P_PK1_NUM_VALUE          => p_incident_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name2
    , 'Deleting Buss proc ACC record for resource_id = ' || p_resource_id || ', incident_id = ' || p_incident_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
     ,P_ACC_TABLE_NAME         => g_acc_table_name2
     ,P_PK1_NAME               => g_pk1_name2
     ,P_PK1_NUM_VALUE          => p_incident_id
     ,P_RESOURCE_ID            => p_resource_id
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name3
    , 'Deleting Buss Txn type ACC record for resource_id = ' || p_resource_id || ', incident_id = ' || p_incident_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  JTM_HOOK_UTIL_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
     ,P_ACC_TABLE_NAME         => g_acc_table_name3
     ,P_PK1_NAME               => g_pk1_name3
     ,P_PK1_NUM_VALUE          => p_incident_id
     ,P_RESOURCE_ID            => p_resource_id
    );

    -- ER 3168529 - Support for contract notes
    CSL_JTF_NOTES_ACC_PKG.POST_DELETE_CHILDREN
       (
         P_SOURCE_OBJ_ID   => p_contract_service_id
         , P_SOURCE_OBJ_CODE => 'OKS_COV_NOTE'
         , P_RESOURCE_ID     => p_resource_id
       );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving DELETE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( p_incident_id
      , g_table_name1
      , 'Exception occured in DELETE_SR_CONTRACT_ACC'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , 'csl_contract_handling_pkg');
    END IF;
END DELETE_SR_CONTRACT_ACC;


/* Called after SR-ACC Insert */
PROCEDURE POST_INSERT_SR_CONTRACT_ACC (
	  p_incident_id IN NUMBER
	, p_resource_id IN NUMBER
	, x_return_status OUT NOCOPY VARCHAR2)
IS
  l_success BOOLEAN := FALSE;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering POST_INSERT_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  l_success := INSERT_CONTRACT_HEADER
                   ( p_incident_id  => p_incident_id
                   , p_resource_id  => p_resource_id
                   );

  IF l_success THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving POST_INSERT_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

END POST_INSERT_SR_CONTRACT_ACC;


/* Called after SR-ACC Update */
PROCEDURE POST_UPDATE_SR_CONTRACT_ACC (
	  p_incident_id             IN  NUMBER
        , p_old_contract_service_id IN  NUMBER
        , p_new_contract_service_id IN  NUMBER
	, p_resource_id             IN  NUMBER
	, x_return_status           OUT NOCOPY VARCHAR2)
IS
  CURSOR c_csl_contr_record (b_incident_id NUMBER) IS
    SELECT CONTRACT_SERVICE_ID
    FROM   CSL_SR_CONTRACT_HEADERS
    WHERE  INCIDENT_ID = b_incident_id;
  r_csl_contr_record c_csl_contr_record%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering POST_UPDATE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  /*** is new contract different from contract stored in csl_sr_contract_headers? ***/
  OPEN c_csl_contr_record( p_incident_id );
  FETCH c_csl_contr_record INTO r_csl_contr_record;
  IF c_csl_contr_record%FOUND THEN
    IF r_csl_contr_record.contract_service_id <> NVL( p_new_contract_service_id, FND_API.G_MISS_NUM ) THEN
      /*** yes -> delete old contract from csl contract tables ***/
      DELETE CSL_CONTR_BUSS_TXN_TYPES WHERE incident_id = p_incident_id;
      DELETE CSL_CONTR_BUSS_PROCESSES WHERE incident_id = p_incident_id;
      DELETE CSL_SR_CONTRACT_HEADERS WHERE incident_id = p_incident_id;
    END IF;
  END IF;
  CLOSE c_csl_contr_record;

  IF p_old_contract_service_id IS NOT NULL THEN
    /* The contract service id is updated for the SR                  **
    ** the ACC records has to be deleted for this SR-contract records */
    -- ER 3168529
    DELETE_SR_CONTRACT_ACC
        ( p_incident_id         => p_incident_id
        , p_resource_id         => p_resource_id
          , p_contract_service_id => p_old_contract_service_id
        );
  END IF;

  IF p_new_contract_service_id IS NOT NULL THEN
    /* The contract service id is updated for the SR                  **
    ** the ACC records has to be created for this SR-contract records */
    POST_INSERT_SR_CONTRACT_ACC
                     ( p_incident_id   => p_incident_id
                     , p_resource_id   => p_resource_id
                     , x_return_status => x_return_status
                     );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Leaving POST_UPDATE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

END POST_UPDATE_SR_CONTRACT_ACC;


/* Called before SR-ACC delete */
PROCEDURE PRE_DELETE_SR_CONTRACT_ACC (
	  p_incident_id IN NUMBER
	, p_resource_id IN NUMBER
	, x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR c_csl_contr_record (b_incident_id NUMBER) IS
      SELECT CONTRACT_SERVICE_ID
      FROM   CSL_SR_CONTRACT_HEADERS
      WHERE  INCIDENT_ID = b_incident_id;
    r_csl_contr_record c_csl_contr_record%ROWTYPE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering PRE_DELETE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

  OPEN c_csl_contr_record (p_incident_id);
  FETCH c_csl_contr_record INTO r_csl_contr_record;
  CLOSE c_csl_contr_record;

  -- ER 3168529
  DELETE_SR_CONTRACT_ACC
      ( p_incident_id         => p_incident_id
      , p_resource_id         => p_resource_id
        , p_contract_service_id => r_csl_contr_record.contract_service_id
      );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , g_table_name1
    , 'Entering PRE_DELETE_SR_CONTRACT_ACC'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , 'csl_contract_handling_pkg');
  END IF;

END PRE_DELETE_SR_CONTRACT_ACC;

END CSL_CONTRACT_HANDLING_PKG;

/
