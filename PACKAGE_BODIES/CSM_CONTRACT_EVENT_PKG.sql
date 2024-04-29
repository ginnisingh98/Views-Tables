--------------------------------------------------------
--  DDL for Package Body CSM_CONTRACT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CONTRACT_EVENT_PKG" AS
/* $Header: csmectrb.pls 120.2.12010000.2 2009/09/03 05:03:28 trajasek ship $*/

/*** Globals ***/
-- CSM_CONTR_HEADERS
g_acc_table_name1           CONSTANT VARCHAR2(30) := 'CSM_CONTR_HEADERS_ACC';
g_publication_item_name1    CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_CONTR_HEADERS');
g_pk1_name1                 CONSTANT VARCHAR2(30) := 'INCIDENT_ID';
g_sequence_name1            CONSTANT VARCHAR2(30) := 'CSM_CONTR_HEADERS_ACC_S';

-- CSM_CONTR_BUSS_PROCESSES
g_acc_table_name2           CONSTANT VARCHAR2(30) := 'CSM_CONTR_BUSS_PROCESSES_ACC';
g_publication_item_name2    CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_CONTR_BUSS_PROCESSES');
g_pk1_name2                 CONSTANT VARCHAR2(30) := 'CONTRACT_SERVICE_ID';
g_pk2_name2                 CONSTANT VARCHAR2(30) := 'BUSINESS_PROCESS_ID';
g_sequence_name2            CONSTANT VARCHAR2(30) := 'CSM_CONTR_BUSS_PROCESSES_ACC_S';

-- CSM_CONTR_BUSS_TXN_TYPES
g_acc_table_name3           CONSTANT VARCHAR2(30) := 'CSM_CONTR_BUSS_TXN_TYPES_ACC';
g_publication_item_name3    CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_CONTR_BUSS_TXN_TYPES');
g_pk1_name3                 CONSTANT VARCHAR2(30) := 'CONTRACT_SERVICE_ID';
g_pk2_name3                 CONSTANT VARCHAR2(30) := 'BUSINESS_PROCESS_ID';
g_pk3_name3                 CONSTANT VARCHAR2(30) := 'TXN_BILLING_TYPE_ID';
g_sequence_name3            CONSTANT VARCHAR2(30) := 'CSM_CONTR_BUSS_TXN_TYPES_ACC_S';

--CSM_COV_ACTION_TIMES
g_acc_table_name4           CONSTANT VARCHAR2(30) := 'CSM_COV_ACTION_TIMES_ACC';
g_publication_item_name4    CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_COV_ACTION_TIMES');
g_pk1_name4                 CONSTANT VARCHAR2(30) := 'ID';
g_pk2_name4                 CONSTANT VARCHAR2(30) := 'INCIDENT_SEVERITY_ID1';
g_pk3_name4                 CONSTANT VARCHAR2(30) := 'ACTION_TYPE_CODE';
g_sequence_name4            CONSTANT VARCHAR2(30) := 'CSM_COV_ACTION_TIMES_ACC_S';

-- CSF_M_NOTES
g_notes_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_NOTES_ACC';
g_notes_table_name            CONSTANT VARCHAR2(30) := 'JTF_NOTES_B';
g_notes_seq_name              CONSTANT VARCHAR2(30) := 'CSM_NOTES_ACC_S';
g_notes_pk1_name              CONSTANT VARCHAR2(30) := 'JTF_NOTE_ID';
g_notes_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_NOTES');

/* Function will get the field service related buss_processes of           **
** the Contract Line and the Action and the Reaction Times **
** Associated with it                               */
PROCEDURE INSERT_COV_ACTION_TIMES
  ( p_user_id         IN NUMBER,
    p_contract_service_id IN VARCHAR2,
    p_business_proc_id     IN NUMBER
  )
IS

CURSOR c_get_cov_id(c_contract_service_id IN NUMBER, c_business_process_id in number)
IS
   SELECT BPL.Id
   FROM OKS_K_Lines_B KSL,
        OKC_K_LINES_B BPL
  WHERE KSL.Cle_ID = c_contract_service_id
    AND BPL.Cle_ID = KSL.COVERAGE_ID
    AND BPL.Lse_Id IN (3,16,21)
    AND EXISTS (SELECT 'x'
                   FROM OKC_K_Items BIT
                  WHERE BIT.Cle_id = BPL.Id
                    AND Object1_Id1 = c_business_process_id
                    AND Jtot_Object1_Code = 'OKX_BUSIPROC');

CURSOR c_get_cov_times(c_bus_proc_cle_id in number)
IS
select  ID,INCIDENT_SEVERITY_ID1,ACTION_TYPE_CODE
FROM    OKS_COV_ACTION_TIMES_V
WHERE   BUS_PROCESS_CLE_ID = c_bus_proc_cle_id;

l_sqlerrno      VARCHAR2(20);
l_sqlerrmsg     VARCHAR2(2000);
l_bus_proc_cle_id NUMBER;

BEGIN
    CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES'
                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES', FND_LOG.LEVEL_PROCEDURE);

    --get the Business process Cle id
    OPEN  c_get_cov_id(p_contract_service_id, p_business_proc_id);
    FETCH c_get_cov_id INTO l_bus_proc_cle_id;
    CLOSE c_get_cov_id;

    IF l_bus_proc_cle_id IS NOT NULL THEN

      FOR r_get_cov_times IN c_get_cov_times(l_bus_proc_cle_id) LOOP

       -- Push record to the Resource (insert in ACC)
        CSM_UTIL_PKG.LOG( 'Inserting ACC record for user_id and contract serviceid = '
        || p_user_id || ' - ' || p_contract_service_id
                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES', FND_LOG.LEVEL_STATEMENT);

        CSM_ACC_PKG.Insert_Acc ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
                            ,P_ACC_TABLE_NAME         => g_acc_table_name4
                            ,P_SEQ_NAME               => g_sequence_name4
                            ,P_PK1_NAME               => g_pk1_name4
                            ,P_PK1_NUM_VALUE          => r_get_cov_times.ID
                            ,P_PK2_NAME               => g_pk2_name4
                            ,P_PK2_NUM_VALUE          => r_get_cov_times.INCIDENT_SEVERITY_ID1
                            ,P_PK3_NAME               => g_pk3_name4
                            ,P_PK3_CHAR_VALUE          => r_get_cov_times.ACTION_TYPE_CODE
                            ,P_USER_ID                => p_user_id
                            );

        UPDATE CSM_COV_ACTION_TIMES_ACC
        SET    JTOT_OBJECT1_CODE = 'OKX_BUSIPROC',
               OBJECT1_ID1       = p_business_proc_id,
               CONTRACT_SERVICE_ID = p_contract_service_id
        WHERE  ID = r_get_cov_times.ID
        AND    INCIDENT_SEVERITY_ID1 = r_get_cov_times.INCIDENT_SEVERITY_ID1
        AND    ACTION_TYPE_CODE = r_get_cov_times.ACTION_TYPE_CODE
        AND    USER_ID = p_user_id;

      END LOOP;
    END IF;

    CSM_UTIL_PKG.LOG( 'Leaving  CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES'
                              , 'CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in  CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES:' || l_sqlerrno || ':' || l_sqlerrmsg
                              , 'CSM_CONTRACT_EVENT_PKG.INSERT_COV_ACTION_TIMES', FND_LOG.LEVEL_ERROR);
    RAISE;

END INSERT_COV_ACTION_TIMES;

PROCEDURE DELETE_COV_ACTION_TIMES
  ( p_user_id         IN NUMBER,
    p_contract_service_id IN VARCHAR2,
    p_business_proc_id     IN NUMBER
  )
IS
CURSOR c_delete_cov_times(c_contract_service_id IN VARCHAR2, c_business_process_id in NUMBER, c_user_id NUMBER)
IS
  SELECT ID,INCIDENT_SEVERITY_ID1,ACTION_TYPE_CODE
  FROM   CSM_COV_ACTION_TIMES_ACC
  WHERE  USER_ID = c_user_id
  AND    CONTRACT_SERVICE_ID = c_contract_service_id
  AND    OBJECT1_ID1 = c_business_process_id;

l_sqlerrno      VARCHAR2(20);
l_sqlerrmsg     VARCHAR2(2000);
l_bus_proc_cle_id NUMBER;

BEGIN
    CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES'
                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES', FND_LOG.LEVEL_PROCEDURE);

      FOR r_get_cov_times IN c_delete_cov_times(p_contract_service_id, p_business_proc_id, p_user_id) LOOP

       -- Push record to the Resource (insert in ACC)
        CSM_UTIL_PKG.LOG( 'Deleting ACC record for user_id and contract serviceid = '
        || p_user_id || ' - ' || p_contract_service_id
                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES', FND_LOG.LEVEL_STATEMENT);

        CSM_ACC_PKG.Delete_Acc ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
                            ,P_ACC_TABLE_NAME         => g_acc_table_name4
                            ,P_PK1_NAME               => g_pk1_name4
                            ,P_PK1_NUM_VALUE          => r_get_cov_times.ID
                            ,P_PK2_NAME               => g_pk2_name4
                            ,P_PK2_NUM_VALUE          => r_get_cov_times.INCIDENT_SEVERITY_ID1
                            ,P_PK3_NAME               => g_pk3_name4
                            ,P_PK3_CHAR_VALUE          => r_get_cov_times.ACTION_TYPE_CODE
                            ,P_USER_ID                => p_user_id
                            );

      END LOOP;

    CSM_UTIL_PKG.LOG( 'Leaving  CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES'
                              , 'CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in  CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES:' || l_sqlerrno || ':' || l_sqlerrmsg
                              , 'CSM_CONTRACT_EVENT_PKG.DELETE_COV_ACTION_TIMES', FND_LOG.LEVEL_ERROR);
    RAISE;

END DELETE_COV_ACTION_TIMES;

/* Function will get the Txn types and the related settings of it          **
**   - Up to amount                                                        **
**   - Percent covered                                                     **
** and will insert these into the CSM-Contract txn types table             */
PROCEDURE INSERT_CONTRACT_TXN_TYPES
  ( p_cov_txn_grp_line_id IN NUMBER
  , p_business_process_id IN NUMBER
  , p_contract_service_id IN VARCHAR2
  , p_user_id         IN NUMBER
  )
IS
CURSOR l_access_id_csr(p_contract_service_id IN VARCHAR2, p_business_process_id in number,
                       p_txn_billing_type_id in number, p_user_id IN number)
IS
SELECT 	acc.access_id, acc.counter
FROM 	csm_contr_buss_txn_types_acc acc
WHERE 	user_id 			= p_user_id
AND 	contract_service_id = p_contract_service_id
AND 	business_process_id = p_business_process_id
AND 	txn_billing_type_id = p_txn_billing_type_id;

l_oks_out_tbl_bt OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BT;
l_oks_out_tbl_br OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BR;

l_effected_records 	NUMBER := 0;
l_success       	BOOLEAN;

p_init_msg_list 	VARCHAR2(4000);
x_return_status		VARCHAR2(1);
x_msg_count     	NUMBER;
x_msg_data      	VARCHAR2(4000);
l_sql           	VARCHAR2(2000);
l_sqlerrno      	VARCHAR2(20);
l_sqlerrmsg     	VARCHAR2(2000);
l_access_id     	number;
l_counter       	number;

BEGIN
  CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES'
                               , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES', FND_LOG.LEVEL_PROCEDURE);

  /* This call to the Contracts API will return the Txn billing types in table  **
  ** variable: l_oks_out_tbl_bt                                                 **
  ** This table should contain the following information:                       **
  **   Txn_BT_line_id      (NUMBER): Txn billing type id                        **
  **   txn_billing_type_id (NUMBER): Business process if                        **
  **   Covered_upto_amount (NUMBER): Upto amount covered                        **
  **   percent_covered     (NUMBER): percent_covered                            */

  OKS_ENTITLEMENTS_PUB.Get_txn_billing_types
		(  p_api_version       => 1.0
		 , p_init_msg_list     => p_init_msg_list
 	     , p_cov_txngrp_line_id=> p_cov_txn_grp_line_id
   		 , p_return_bill_rates_YN => 'N' -- We're not interested on the billing rates
		 , x_return_status     => x_return_status
		 , x_msg_count         => x_msg_count
		 , x_msg_data          => x_msg_data
		 , x_txn_bill_types    => l_oks_out_tbl_bt
		 , x_txn_bill_rates    => l_oks_out_tbl_br -- Should return null
		);

  IF l_oks_out_tbl_bt.COUNT > 0 THEN
    /* Looping over the table if table contain any record(s) */
    FOR i IN l_oks_out_tbl_bt.FIRST .. l_oks_out_tbl_bt.LAST LOOP

          -- Push record to the Resource (insert in ACC)
          CSM_UTIL_PKG.LOG( 'Inserting ACC record for user_id = ' || p_user_id
                            , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES', FND_LOG.LEVEL_STATEMENT);

          CSM_ACC_PKG.Insert_Acc ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
                            ,P_ACC_TABLE_NAME         => g_acc_table_name3
                            ,P_SEQ_NAME               => g_sequence_name3
                            ,P_USER_ID                => p_user_id
                            ,P_PK1_NAME               => g_pk1_name3
--                            ,P_PK1_CHAR_VALUE          => p_cov_txn_grp_line_id
                            ,P_PK1_CHAR_VALUE          => p_contract_service_id
                            ,P_PK2_NAME               => g_pk2_name3
                            ,P_PK2_NUM_VALUE          => p_business_process_id
                            ,P_PK3_NAME               => g_pk3_name3
                            ,P_PK3_NUM_VALUE          => l_oks_out_tbl_bt(i).txn_bill_type_id
                            );

/*          l_sql := ' UPDATE '|| g_acc_table_name3 ||
                   ' SET percent_covered = ' || '''' || l_oks_out_tbl_bt(i).percent_covered || '''' ||
                   ' ,up_to_amount = ' || '''' || l_oks_out_tbl_bt(i).Covered_upto_amount || '''' ||
                   ' WHERE contract_service_id = ' || '''' || p_contract_service_id || '''' ||
                   ' AND business_process_id = ' || p_business_process_id ||
                   ' AND txn_billing_type_id = ' || l_oks_out_tbl_bt(i).txn_bill_type_id ;

           EXECUTE IMMEDIATE l_sql;
*/

          l_sql := ' UPDATE '|| g_acc_table_name3 ||
                   ' SET percent_covered = :1 ' ||
                   ' ,up_to_amount = :2 ' ||
                   ' WHERE contract_service_id = :3' ||
                   ' AND business_process_id = :4' ||
                   ' AND txn_billing_type_id = :5';

           EXECUTE IMMEDIATE l_sql USING l_oks_out_tbl_bt(i).percent_covered, l_oks_out_tbl_bt(i).Covered_upto_amount,
                            p_contract_service_id, p_business_process_id, l_oks_out_tbl_bt(i).txn_bill_type_id;

          OPEN l_access_id_csr(p_contract_service_id, p_business_process_id,
                               l_oks_out_tbl_bt(i).txn_bill_type_id, p_user_id);
          FETCH l_access_id_csr INTO l_access_id, l_counter;
          CLOSE l_access_id_csr;

          -- if counter > 1 then pass update to the Pub item as we are updating acc table
          IF l_counter > 1 THEN
             CSM_ACC_PKG.UPDATE_ACC (p_publication_item_names => g_publication_item_name3
                                  ,p_acc_table_name => g_acc_table_name3
                                  ,p_user_id => p_user_id
                                  ,p_access_id => l_access_id
                                  );
          END IF;

          /* increase effected records if a new  record has been created */
          l_effected_records := l_effected_records + 1;

    END LOOP;
  END IF;

  CSM_UTIL_PKG.LOG( 'Leaving CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES'
                          , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES:' || l_sqlerrno || ':' || l_sqlerrmsg
                                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_TXN_TYPES', FND_LOG.LEVEL_ERROR);
   RAISE;
END INSERT_CONTRACT_TXN_TYPES;


/* Function will get the field service related buss_processes of           **
** the Contract Line and will insert the details of these buss_processes   **
** into the CSM-Contract buss process table                                */
PROCEDURE INSERT_CONTRACT_BUSS_PROCESSES
  ( p_contract_service_id IN VARCHAR2
  , p_user_id         IN NUMBER
  )
IS
CURSOR l_access_id_csr(p_contract_service_id IN VARCHAR2, p_business_process_id in number, p_user_id IN number)
IS
SELECT 	acc.access_id, acc.counter
FROM 	csm_contr_buss_processes_acc acc
WHERE 	user_id 			= p_user_id
AND 	contract_service_id = p_contract_service_id
AND 	business_process_id = p_business_process_id;

l_oks_in_rec_bp  OKS_ENTITLEMENTS_PUB.INP_REC_BP;
l_oks_out_tbl_bp OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BP;
l_effected_records NUMBER := 0;
l_rec           NUMBER := 0;
l_success       BOOLEAN;

p_init_msg_list VARCHAR2(4000);
x_return_status VARCHAR2(1);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(4000);
l_sql           VARCHAR2(2000);
l_sqlerrno      VARCHAR2(20);
l_sqlerrmsg     VARCHAR2(2000);
l_access_id     number;
l_counter       number;

BEGIN
  CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES'
                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES', FND_LOG.LEVEL_PROCEDURE);

  /* The l_oks_rec_bp should contain the information about the contract line    **
  ** which the information should get from and the flags will make the criteria **
  ** of the result set which you're interest in                                 */
  l_oks_in_rec_bp.contract_line_id := p_contract_service_id;
  /* Y: API will check the business process definition                          */
  l_oks_in_rec_bp.check_bp_def     := 'Y';
  /* Y: Validate with Service Request enabled flag of the bus-proc              */
  l_oks_in_rec_bp.sr_enabled       := 'Y';
  /* N: Don't validate with Depot Repair enabled flag of the bus-proc           */
  --BUG 2613672: Pass NULL instead of 'N '
  --l_oks_in_rec_bp.dr_enabled       := 'N';
  /* Y: Validate with Field Service enabled flag of the bus-proc                */
  l_oks_in_rec_bp.fs_enabled       := 'Y';


  /* This call to the Contracts API will return the business processes in table **
  ** variable: l_oks_out_tbl_bp                                                 **
  ** This table should contain the following information:                       **
  **   cov_txn_grp_line_id (NUMBER): Contract line id for business process      **
  **   bp_id               (NUMBER): Business Process ID                        **
  **   start_date          (DATE)  : Start Date for business process            **
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

        /* Insert all the Txn Billing Types for the Bus-proc */
        INSERT_CONTRACT_TXN_TYPES
             ( p_cov_txn_grp_line_id => l_oks_out_tbl_bp(i).cov_txn_grp_line_id
             , p_business_process_id => l_oks_out_tbl_bp(i).bp_id
             , p_contract_service_id => p_contract_service_id
             , p_user_id         => p_user_id
             );

          /* Insert all the Coverage Action and Reactiton times for the Bus-proc */
        INSERT_COV_ACTION_TIMES
        ( p_user_id             => p_user_id,
          p_contract_service_id => p_contract_service_id,
          p_business_proc_id    => l_oks_out_tbl_bp(i).bp_id
        );

        -- Push record to the Resource (insert in ACC)
        CSM_UTIL_PKG.LOG( 'Inserting ACC record for user_id = ' || p_user_id
                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES', FND_LOG.LEVEL_STATEMENT);

        CSM_ACC_PKG.Insert_Acc ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
                            ,P_ACC_TABLE_NAME         => g_acc_table_name2
                            ,P_SEQ_NAME               => g_sequence_name2
                            ,P_PK1_NAME               => g_pk1_name2
                            ,P_PK1_CHAR_VALUE          => p_contract_service_id
                            ,P_PK2_NAME               => g_pk2_name2
                            ,P_PK2_NUM_VALUE          => l_oks_out_tbl_bp(i).bp_id
                            ,P_USER_ID                => p_user_id
                            );

/*        l_sql :=  ' UPDATE '|| g_acc_table_name2 ||
                  ' SET start_date = ' || '''' || l_oks_out_tbl_bp(i).start_date || '''' ||
                  ' ,end_date = '|| '''' || l_oks_out_tbl_bp(i).end_date || '''' ||
                  ' WHERE contract_service_id = ' || '''' ||  p_contract_service_id || '''' ||
                  ' AND business_process_id = ' || l_oks_out_tbl_bp(i).bp_id;

        EXECUTE IMMEDIATE l_sql;
*/
        l_sql :=  ' UPDATE '|| g_acc_table_name2 ||
                  ' SET start_date = :1 ' ||
                  ' ,end_date = :2'||
                  ' WHERE contract_service_id = :3' ||
                  ' AND business_process_id = :4';

        EXECUTE IMMEDIATE l_sql USING l_oks_out_tbl_bp(i).start_date,l_oks_out_tbl_bp(i).end_date,
                                      p_contract_service_id,l_oks_out_tbl_bp(i).bp_id;

        OPEN  l_access_id_csr(p_contract_service_id, l_oks_out_tbl_bp(i).bp_id, p_user_id);
        FETCH l_access_id_csr INTO l_access_id, l_counter;
        CLOSE l_access_id_csr;

        -- if counter > 1 then pass update to the Pub item as we are updating acc table
        IF l_counter > 1 THEN
           CSM_ACC_PKG.UPDATE_ACC (p_publication_item_names => g_publication_item_name2
                                  ,p_acc_table_name => g_acc_table_name2
                                  ,p_user_id => p_user_id
                                  ,p_access_id => l_access_id
                                  );
        END IF;

        /* increase effected records if a new  record has been created */
        l_effected_records := l_effected_records + 1;

    END LOOP;
  END IF;

  CSM_UTIL_PKG.LOG( 'Leaving  CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES'
                              , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in  CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES:' || l_sqlerrno || ':' || l_sqlerrmsg
                              , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_BUSS_PROCESSES', FND_LOG.LEVEL_ERROR);
    RAISE;

END INSERT_CONTRACT_BUSS_PROCESSES;

/* Function will get the details of the Contract Line             **
** and will insert the details into the CSM-Contract header table */
PROCEDURE INSERT_CONTRACT_HEADER
  ( p_incident_id IN NUMBER
  , p_user_id IN NUMBER
  )
IS
CURSOR l_csm_contract_line_details (b_incident_id NUMBER )
IS
SELECT 	cs.CONTRACT_SERVICE_ID
,      	h.contract_number
,      	s.name
,      	s.description
,      	l.currency_code
FROM	okc_k_headers_all_b    h
,    	okc_k_lines_b      	l
,    	Okx_System_Items_V 	s
,    	Okc_K_Items        	IT
,    	CS_INCIDENTS_ALL_B 	cs
WHERE 	cs.INCIDENT_ID         = b_incident_id
AND   	cs.CONTRACT_SERVICE_ID = l.id
AND   	h.id                   = l.dnz_chr_id
AND   	l.id                   = it.CLE_ID
AND   	s.Id1                  = to_number(IT.Object1_Id1)
AND   	s.Id2                  = to_number(IT.Object1_Id2);

CURSOR l_access_id_csr(p_incident_id IN number, p_user_id IN number)
IS
SELECT 	acc.access_id, acc.counter
FROM 	csm_contr_headers_acc acc
WHERE 	incident_id = p_incident_id
AND 	user_id 	= p_user_id;

r_csm_contract_line_details l_csm_contract_line_details%ROWTYPE;
l_sql       VARCHAR2(2000);
l_sqlerrno 	varchar2(20);
l_sqlerrmsg varchar2(2000);
l_access_id number;
l_counter 	number;

BEGIN
  CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER'
                           , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER', FND_LOG.LEVEL_PROCEDURE);

  OPEN l_csm_contract_line_details(p_incident_id);
  FETCH l_csm_contract_line_details INTO r_csm_contract_line_details;
  IF l_csm_contract_line_details%NOTFOUND THEN
      CSM_UTIL_PKG.LOG( 'No data found in CURSOR Contract Line for INCIDENT_ID: ' || p_incident_id
                                 , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER', FND_LOG.LEVEL_EXCEPTION);
  ELSE
      CSM_UTIL_PKG.LOG( 'Details of Contract Line for INCIDENT_ID: ' || p_incident_id
                        || ', CONTRACT_SERVICE_ID: ' || r_csm_contract_line_details.contract_service_id
                        || ', CONTRACT_NUMBER: ' || r_csm_contract_line_details.contract_number
                        || ', SERVICE_NAME: ' || r_csm_contract_line_details.name
                        || ', SERVICE_DESCRIPTION: ' || r_csm_contract_line_details.description
                        || ', AMOUNT_UOM_CODE: ' || r_csm_contract_line_details.currency_code
                        , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER'
                        , FND_LOG.LEVEL_STATEMENT);

      INSERT_CONTRACT_BUSS_PROCESSES
                ( p_contract_service_id => r_csm_contract_line_details.contract_service_id
                , p_user_id         => p_user_id
                );

      CSM_UTIL_PKG.LOG( 'Inserting ACC record for user_id = ' || p_user_id
                  , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER', FND_LOG.LEVEL_STATEMENT);

      CSM_ACC_PKG.Insert_Acc ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                            ,P_ACC_TABLE_NAME         => g_acc_table_name1
                            ,P_SEQ_NAME               => g_sequence_name1
                            ,P_PK1_NAME               => g_pk1_name1
                            ,P_PK1_NUM_VALUE          => p_incident_id
                            ,P_USER_ID                => p_user_id
                            );


/*      l_sql :=  ' UPDATE '|| g_acc_table_name1 ||
                ' SET contract_service_id = ' || '''' || r_csm_contract_line_details.contract_service_id || '''' ||
                ', contract_number = '|| '''' || r_csm_contract_line_details.contract_number || '''' ||
                ', service_name = '|| '''' ||r_csm_contract_line_details.name ||'''' ||
                ', service_description = '||'''' || r_csm_contract_line_details.description ||'''' ||
                ', amount_uom_code = '|| '''' ||r_csm_contract_line_details.currency_code ||'''' ||
                ' WHERE incident_id = '|| p_incident_id;

      EXECUTE IMMEDIATE l_sql;
*/
     l_sql :=  ' UPDATE '|| g_acc_table_name1 ||
                ' SET contract_service_id = :1' ||
                ', contract_number = :2 '||
                ', service_name = :3'||
                ', service_description = :4'||
                ', amount_uom_code = :5'||
                ' WHERE incident_id = :6 ';

      EXECUTE IMMEDIATE l_sql USING r_csm_contract_line_details.contract_service_id, r_csm_contract_line_details.contract_number,
                            r_csm_contract_line_details.name, r_csm_contract_line_details.description,
                            r_csm_contract_line_details.currency_code, p_incident_id;

      OPEN 	l_access_id_csr(p_incident_id, p_user_id);
      FETCH l_access_id_csr INTO l_access_id, l_counter;
      CLOSE l_access_id_csr;

      -- if counter > 1 then pass update to the Pub item as we are updating acc table
      IF l_counter > 1 THEN
        CSM_ACC_PKG.UPDATE_ACC (p_publication_item_names => g_publication_item_name1
                               ,p_acc_table_name => g_acc_table_name1
                               ,p_user_id => p_user_id
                               ,p_access_id => l_access_id
                               );
      END IF;

   END IF;
   CLOSE l_csm_contract_line_details;

   CSM_UTIL_PKG.LOG( 'Leaving CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER'
                              , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER' , FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
    IF l_csm_contract_line_details%ISOPEN THEN
       CLOSE l_csm_contract_line_details;
    END IF;
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER:' || l_sqlerrno || ':' || l_sqlerrmsg
                          , 'CSM_CONTRACT_EVENT_PKG.INSERT_CONTRACT_HEADER', FND_LOG.LEVEL_ERROR);
    RAISE;
END INSERT_CONTRACT_HEADER;


/* Will delete all the sr-contract acc records for all mobile resources */
PROCEDURE DELETE_SR_CONTRACT_ACC
  ( p_incident_id     IN NUMBER
  , p_user_id         IN NUMBER
  )
IS
l_sqlerrno 	varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_contr_headers_csr(p_incidentid IN number,
                           p_userid IN number)
IS
SELECT 	incident_id, contract_service_id
FROM 	CSM_CONTR_HEADERS_ACC
WHERE 	user_id 	= p_user_id
AND 	incident_id = p_incidentid;

CURSOR l_contr_buss_processes_csr(p_contractserviceid IN VARCHAR2,
                                  p_userid IN number)
IS
SELECT 	contract_service_id, business_process_id
FROM 	CSM_CONTR_BUSS_PROCESSES_ACC
WHERE 	user_id = p_userid
AND 	contract_service_id = p_contractserviceid;

CURSOR l_contr_buss_txn_types_csr(p_contractserviceid IN varchar2,
                                  p_businessprocessid IN number,
                                  p_userid IN number)
IS
SELECT 	contract_service_id, business_process_id, txn_billing_type_id
FROM 	csm_contr_buss_txn_types_acc
WHERE 	user_id = p_userid
AND 	contract_service_id = p_contractserviceid
AND 	business_process_id = p_businessprocessid;

BEGIN
  CSM_UTIL_PKG.LOG( 'Entering CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC'
                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_PROCEDURE);

  FOR r_contr_headers_rec IN l_contr_headers_csr(p_incident_id, p_user_id) LOOP

    FOR r_contr_buss_processes_rec IN l_contr_buss_processes_csr(r_contr_headers_rec.contract_service_id, p_user_id) LOOP

       FOR r_contr_buss_txn_types_rec IN l_contr_buss_txn_types_csr(r_contr_buss_processes_rec.contract_service_id,
                                                                    r_contr_buss_processes_rec.business_process_id,
                                                                    p_user_id) LOOP
           CSM_UTIL_PKG.LOG( 'Deleting Buss Txn type ACC record for user_id = ' || p_user_id ||
                                  ', contract_service_id = ' || r_contr_buss_txn_types_rec.contract_service_id ||
                                  ', business_process_id = ' || r_contr_buss_txn_types_rec.business_process_id ||
                                  ', txn_billing_type_id = ' || r_contr_buss_txn_types_rec.txn_billing_type_id
                                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_STATEMENT);

           CSM_ACC_PKG.Delete_Acc
            ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
             ,P_ACC_TABLE_NAME         => g_acc_table_name3
             ,P_PK1_NAME               => g_pk1_name3
             ,P_PK1_CHAR_VALUE          => r_contr_buss_txn_types_rec.contract_service_id
             ,P_PK2_NAME               => g_pk2_name3
             ,P_PK2_NUM_VALUE          => r_contr_buss_txn_types_rec.business_process_id
             ,P_PK3_NAME               => g_pk3_name3
             ,P_PK3_NUM_VALUE          => r_contr_buss_txn_types_rec.txn_billing_type_id
             ,P_USER_ID                => p_user_id
            );
       END LOOP;

      CSM_UTIL_PKG.LOG( 'Deleting Buss proc ACC record for user_id = ' || p_user_id ||
                                  ', contract_service_id = ' || r_contr_buss_processes_rec.contract_service_id ||
                                  ', business_process_id = ' || r_contr_buss_processes_rec.business_process_id
                                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_STATEMENT);

      CSM_ACC_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
        ,P_ACC_TABLE_NAME         => g_acc_table_name2
        ,P_PK1_NAME               => g_pk1_name2
        ,P_PK1_CHAR_VALUE          => r_contr_buss_processes_rec.contract_service_id
        ,P_PK2_NAME               => g_pk2_name2
        ,P_PK2_NUM_VALUE          => r_contr_buss_processes_rec.business_process_id
        ,P_USER_ID                => p_user_id
       );

      DELETE_COV_ACTION_TIMES
        ( p_user_id             => p_user_id,
          p_contract_service_id => r_contr_buss_processes_rec.contract_service_id,
          p_business_proc_id    => r_contr_buss_processes_rec.business_process_id
        );
    END LOOP;

    CSM_UTIL_PKG.LOG( 'Deleting Contract Header ACC record for user_id = ' || p_user_id ||
                                ', incident_id = ' || p_incident_id
                              , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_STATEMENT);

    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_contr_headers_rec.incident_id
      ,P_USER_ID                => p_user_id
     );

  END LOOP;

  CSM_UTIL_PKG.LOG( 'Leaving CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC'
                              , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_PROCEDURE);


EXCEPTION
  WHEN OTHERS THEN
    l_sqlerrno := to_char(SQLCODE);
    l_sqlerrmsg := substr(SQLERRM, 1,2000);
    CSM_UTIL_PKG.LOG( 'Exception occured in CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC:' || l_sqlerrno || ':' || l_sqlerrmsg
                                  , 'CSM_CONTRACT_EVENT_PKG.DELETE_SR_CONTRACT_ACC', FND_LOG.LEVEL_ERROR);
    RAISE;

END DELETE_SR_CONTRACT_ACC;

PROCEDURE DELETE_OKS_NOTES_ACC(p_contract_service_id IN varchar2,
                               p_user_id IN number)
IS
l_markdirty				BOOLEAN;
l_dmllist 				asg_download.dml_list;
l_dml 					varchar2(1);
l_timestamp 			DATE;
l_accesslist 			asg_download.access_list;
l_null_accesslist 		asg_download.access_list;
l_resourcelist 			asg_download.user_list;
l_null_resourcelist 	asg_download.user_list;
l_user_id 				NUMBER;
l_sourceobjectid 		NUMBER;
l_sourceobjectcode 		VARCHAR2(240);
l_publicationitemname 	VARCHAR2(30);
l_access_count 			NUMBER;
l_pkvalueslist 			asg_download.pk_list;
l_notes_found 			boolean;

CURSOR l_oks_notes_csr (p_sourceobjectcode VARCHAR2,
				     	p_sourceobjectid NUMBER,
                        p_user_id NUMBER) IS
SELECT 	acc.jtf_note_id, acc.user_id
FROM 	jtf_notes_b notes, csm_notes_acc acc
WHERE 	notes.source_object_code 	= p_sourceobjectcode
AND   	notes.source_object_id 		= p_sourceobjectid
AND 	notes.jtf_note_id 			= acc.jtf_note_id
AND 	acc.user_id 				= p_user_id;

BEGIN
  l_sourceobjectcode := 'OKS_COV_NOTE';
  l_sourceobjectid   := p_contract_service_id;
  l_user_id 		 := p_user_id;

	--delete for the user
  	for l_oks_notes_rec in l_oks_notes_csr(l_sourceobjectcode,
										   l_sourceobjectid,
                                           l_user_id) loop
          CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_notes_pubi_name
           ,P_ACC_TABLE_NAME         => g_notes_acc_table_name
           ,P_PK1_NAME               => g_notes_pk1_name
           ,P_PK1_NUM_VALUE          => l_oks_notes_rec.jtf_note_id
           ,P_USER_ID                => l_oks_notes_rec.user_id
          );

  	end loop;

 EXCEPTION
 WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( sqlerrm|| ' for Contract_Service_Id ' || to_char(l_sourceobjectid),
      'CSM_CONTRACT_EVENT_PKG.DELETE_OKS_NOTES_ACC',FND_LOG.LEVEL_EXCEPTION);
  RAISE;

END DELETE_OKS_NOTES_ACC;

PROCEDURE INSERT_OKS_NOTES_ACC(p_contract_service_id IN VARCHAR2,
                               p_user_id IN number)
IS
l_markdirty				BOOLEAN;
l_dmllist 				asg_download.dml_list;
l_dml 					varchar2(1);
l_timestamp 			DATE;
l_accesslist 			asg_download.access_list;
l_resourcelist 			asg_download.user_list;
l_user_id 				NUMBER;
l_sourceobjectid 		NUMBER;
l_sourceobjectcode 		VARCHAR2(240);
l_publicationitemname 	VARCHAR2(30);
l_access_count 			NUMBER;
l_notes_found 			boolean;

CURSOR l_oks_notes_csr (p_sourceobjectcode VARCHAR2,
					    p_sourceobjectid NUMBER) IS
SELECT 	jtf_note_id
FROM 	jtf_notes_b
WHERE 	source_object_code 	= p_sourceobjectcode
AND   	source_object_id 	= p_sourceobjectid;

BEGIN
  l_sourceobjectcode := 'OKS_COV_NOTE';
  l_sourceobjectid   := p_contract_service_id;
  l_user_id 		 := p_user_id;

	--delete for the user
  	for l_oks_notes_rec in l_oks_notes_csr(l_sourceobjectcode,
										   l_sourceobjectid) loop

        CSM_ACC_PKG.Insert_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_notes_pubi_name
         ,P_ACC_TABLE_NAME         => g_notes_acc_table_name
         ,P_SEQ_NAME               => g_notes_seq_name
         ,P_PK1_NAME               => g_notes_pk1_name
         ,P_PK1_NUM_VALUE          => l_oks_notes_rec.jtf_note_id
         ,P_USER_ID                => l_user_id
        );

  	end loop;

 EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( sqlerrm|| ' for Contract_Service_Id ' || to_char(l_sourceobjectid),
      'CSM_CONTRACT_EVENT_PKG.INSERT_OKS_NOTES_ACC',FND_LOG.LEVEL_EXCEPTION);
  RAISE;

END INSERT_OKS_NOTES_ACC;

PROCEDURE SR_CONTRACT_ACC_I (p_incident_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg 	VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_CONTRACT_ACC_I for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_I',FND_LOG.LEVEL_PROCEDURE);

   INSERT_CONTRACT_HEADER( p_incident_id  => p_incident_id
                         , p_user_id  => p_user_id);

   CSM_UTIL_PKG.LOG('Leaving SR_CONTRACT_ACC_I for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno  := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CONTRACT_ACC_I for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_CONTRACT_ACC_I;

PROCEDURE SR_CONTRACT_ACC_D (p_incident_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg 	VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_CONTRACT_ACC_D for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_D',FND_LOG.LEVEL_PROCEDURE);

    DELETE_SR_CONTRACT_ACC
       ( p_incident_id   => p_incident_id
       , p_user_id       => p_user_id
       );

   CSM_UTIL_PKG.LOG('Leaving SR_CONTRACT_ACC_D for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno  := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CONTRACT_ACC_D for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_CONTRACT_ACC_D;

PROCEDURE SR_CONTRACT_ACC_U (p_incident_id IN NUMBER, p_old_contract_service_id IN NUMBER,
                             p_contract_service_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg 	VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering SR_CONTRACT_ACC_U for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_U',FND_LOG.LEVEL_PROCEDURE);

   IF p_old_contract_service_id IS NOT NULL THEN
        /* The contract service id is updated for the SR                  **
        ** the ACC records has to be deleted for this SR-contract records */
        DELETE_SR_CONTRACT_ACC
            ( p_incident_id  => p_incident_id
            , p_user_id      => p_user_id
            );

        -- delete contract notes
        DELETE_OKS_NOTES_ACC(p_contract_service_id => p_old_contract_service_id,
                             p_user_id => p_user_id);
    END IF;


    IF p_contract_service_id IS NOT NULL THEN
       /* The contract service id is updated for the SR                  **
       ** the ACC records has to be created for this SR-contract records */
      INSERT_CONTRACT_HEADER( p_incident_id  => p_incident_id
                            , p_user_id     => p_user_id);

      -- insert contract notes
      INSERT_OKS_NOTES_ACC(p_contract_service_id => p_contract_service_id,
                           p_user_id =>  p_user_id);

    END IF;

   CSM_UTIL_PKG.LOG('Leaving SR_CONTRACT_ACC_U for incident_id: ' || p_incident_id,
                                   'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  SR_CONTRACT_ACC_U for incident_id:'
                       || to_char(p_incident_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_CONTRACT_EVENT_PKG.SR_CONTRACT_ACC_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SR_CONTRACT_ACC_U;

END CSM_CONTRACT_EVENT_PKG;

/
