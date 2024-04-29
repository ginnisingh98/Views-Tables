--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_REALLOC_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_REALLOC_LOG_PKG" AS
/* $Header: pqbpllog.pkb 115.4 2004/06/15 13:47:02 rthiagar noship $ */

g_table_route_id   NUMBER(15);

g_package  varchar2(33) := '  pqh_bdgt_realloc_log_pkg.';  -- Global package name

FUNCTION get_table_route_for_bpl RETURN NUMBER IS
  CURSOR csr_table_route IS
  SELECT table_route_id
  FROM   pqh_table_route
  WHERE  table_alias =  'BPL';
  l_tab_route NUMBER(15);
  l_proc  varchar2(80) := g_package||'get_table_rout_for_bpl';
BEGIN
  hr_utility.set_location('Entering'||l_proc,10);
  OPEN csr_table_route;
  FETCH  csr_table_route INTO l_tab_route;
  CLOSE csr_table_route;
  hr_utility.set_location('Leaving with table_route'||l_tab_route||l_proc,10);
  RETURN l_tab_route;
END get_table_route_for_bpl;

FUNCTION get_process_log_id(p_entity_type in varchar2  -- F/T/DD/RD
                        ,p_transaction_id IN number  Default Null-- Realloc Transaction Id
                        ,p_entity_id IN number  Default Null -- Donor Receiver Entity
                        ,p_folder_id IN number) -- Realloc Folder Id
RETURN NUMBER IS
    CURSOR CSR_batch_master_log IS
     SELECT process_log_id
     FROM   pqh_process_log
     WHERE  txn_id = p_folder_id
     AND    module_cd = 'BUDGET_REALLOCATION';

    Cursor Csr_get_log (p_batch_id IN number)
    IS SELECT process_log_id,
              txn_id,
              information_category
     FROM     pqh_process_log
     START WITH txn_id = p_transaction_id
     AND        master_process_log_id     =  p_batch_id
     AND        module_cd = 'BUDGET_REALLOCATION'
     CONNECT BY PRIOR  process_log_id = master_process_log_id;
     l_proc varchar2(80) := g_package||'get_process_log_id';
     l_mast_log_id NUMBER(15);
BEGIN
    hr_utility.set_location(l_proc,10);
    OPEN CSR_batch_master_log;
    FETCH CSR_batch_master_log INTO l_mast_log_id;
    CLOSE CSR_batch_master_log ;
    IF p_entity_type = 'F' THEN
     hr_utility.set_location('Leaving with master log id as '||l_mast_log_id||l_proc,20);
     RETURN l_mast_log_id;
    END IF;
    FOR l_rec IN Csr_get_log(l_mast_log_id)
    LOOP
      IF p_entity_type = 'T' AND l_rec.txn_id = p_transaction_id AND l_rec.information_category = 'T' THEN
         hr_utility.set_location('Leaving with master log id as '||l_rec.process_log_id||l_proc,20);
         RETURN l_rec.process_log_id;
      ELSIF p_entity_type = 'D'AND l_rec.txn_id = -1*p_transaction_id AND l_rec.information_category = 'D' THEN
         hr_utility.set_location('Leaving with master log id as '||l_rec.process_log_id||l_proc,20);
         RETURN l_rec.process_log_id;
      ELSIF p_entity_type = 'R'AND l_rec.txn_id = -2*p_transaction_id AND l_rec.information_category = 'R' THEN
         hr_utility.set_location('Leaving with master log id as '||l_rec.process_log_id||l_proc,20);
         RETURN l_rec.process_log_id;
      ELSIF p_entity_type IN ('DD','RD')
            AND l_rec.information_category = p_entity_type
            AND l_rec.txn_id = p_entity_id THEN
         hr_utility.set_location('Leaving with master log id as '||l_rec.process_log_id||l_proc,20);
         RETURN l_rec.process_log_id;
      END IF;
    END LOOP;
    hr_utility.set_location('Leaving with master log id as -1'||l_proc,20);
    RETURN -1;
END;

PROCEDURE  start_log_for_folder(p_folder_id IN Number) IS

Cursor csr_folder_dtls IS
SELECT fld.name,
       pb.budget_name||'-'||bvr.version_number,
       pb.budgeted_entity_cd,
       fld.budget_unit_id
FROM   pqh_budget_pools fld,
       pqh_budgets pb,
       pqh_budget_versions bvr
WHERE  fld.pool_id = p_folder_id
AND    fld.budget_version_id = bvr.budget_version_id
AND    bvr.budget_id = pb.budget_id;
 l_budget_name  VARCHAR2(40);
 l_folder_name  varchar2(30);
 l_entity_cd    varchar2(30);
 l_unit_id      NUMBER(15);
 l_folder_amt   NUMBER(22,3);
 l_proc  varchar2(80) := g_package||'start_log_for_folder';
BEGIN
    hr_utility.set_location('Entering '||l_proc,10);
    OPEN csr_folder_dtls;
    FETCH csr_folder_dtls INTO l_folder_name, l_budget_name,l_entity_cd, l_unit_id;
    CLOSE csr_folder_dtls;
    g_table_route_id := get_table_route_for_bpl;
--Folder
    PQH_PROCESS_BATCH_LOG.START_LOG( p_batch_id => p_folder_id
                                    ,p_module_cd => 'BUDGET_REALLOCATION'
                                    ,p_log_context=> l_folder_name
                                    ,p_information_category => 'F'
                                    ,p_information1 => l_budget_name
                                    ,p_information2 => l_entity_cd
                                    ,p_information3 => l_unit_id
                                    ,p_information4 => pqh_bdgt_realloc_utility.GET_FOLDER_LEVEL_TRANS_AMT(p_folder_id));   --Build a new canvas for this level
   hr_utility.set_location('Leaving '||l_proc,20);
END start_log_for_folder;

PROCEDURE start_log_for_transaction( p_folder_id IN number
                                    ,p_transaction_id IN Number) is

 Cursor csr_trnx_name IS
   SELECT name
   FROM   pqh_budget_pools
   WHERE  pool_id = p_transaction_id;
   l_name Varchar2(30);
   l_master_log_id  Number(15);
   l_process_log_id NUMBER(15);
   l_ovn   NUMBER(9);
   l_proc  varchar2(80) := g_package||'start_log_for_transaction';
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  hr_utility.set_location('Entering '||l_proc,10);
  OPEN csr_trnx_name;
  FETCH csr_trnx_name INTO l_name;
  CLOSE csr_trnx_name;
  l_master_log_id := get_process_log_id(p_entity_type => 'F'
                                       ,p_folder_id => p_folder_id);
  pqh_process_log_api.create_process_log(p_process_log_id => l_process_log_id
                                         ,p_module_cd => 'BUDGET_REALLOCATION'
                                         ,p_txn_id => p_transaction_id
                                         ,p_log_context => l_name
                                         ,p_batch_start_date => sysdate
                                         ,p_master_process_log_id => l_master_log_id
                                         ,p_message_type_cd => 'START'
                                         ,p_message_text => 'Process Started'
                                         ,p_effective_date => sysdate
                                         ,p_object_version_number => l_ovn
                                         ,p_information_category => 'T');
  hr_utility.set_location('Inserted a row for Transaction Level '||l_proc,20);
  l_master_log_id := l_process_log_id; -- Transaction level Process Log ID
  pqh_process_log_api.create_process_log(p_process_log_id=> l_process_log_id
                                         ,p_module_cd => 'BUDGET_REALLOCATION'
                                         ,p_txn_id => -1*p_transaction_id
                                         ,p_log_context => hr_general.decode_lookup('PQH_REALLOC_RECORD_TYPE','D')
                                         ,p_batch_start_date => sysdate
                                         ,p_master_process_log_id => l_master_log_id
                                         ,p_message_type_cd => 'START'
                                         ,p_message_text => 'Process Started'
                                         ,p_effective_date => sysdate
                                         ,p_object_version_number => l_ovn
                                         ,p_information_category => 'D');
  hr_utility.set_location('Inserted a row for Transaction-Donor Level '||l_proc,25);
  pqh_process_log_api.create_process_log(p_process_log_id=> l_process_log_id
                                         ,p_module_cd => 'BUDGET_REALLOCATION'
                                         ,p_txn_id => -2*p_transaction_id
                                         ,p_log_context => hr_general.decode_lookup('PQH_REALLOC_RECORD_TYPE','R')
                                         ,p_batch_start_date => sysdate
                                         ,p_master_process_log_id => l_master_log_id
                                         ,p_message_type_cd => 'START'
                                         ,p_message_text => 'Process Started'
                                         ,p_effective_date => sysdate
                                         ,p_object_version_number => l_ovn
                                         ,p_information_category => 'R');
  hr_utility.set_location('Inserted a row for Transaction-Receiver Level '||l_proc,25);


  Commit;
  hr_utility.set_location('Inserted a row for Transaction-Receive Level. Leaving '||l_proc,25);
END start_log_for_transaction;
PROCEDURE start_log_for_entity(p_folder_id IN NUMBER
                              ,p_transaction_id IN NUMBER
                              ,p_txn_entity_type IN varchar2 --(D/R)
                              ,p_bdgt_entity_type IN varchar2
                              ,p_entity_id IN NUMBER) IS
   l_master_log_id NUMBER(15);
   l_entity_name    VARCHAR2(240);
   l_log_id   NUMBER(15);
   l_ovn            NUMBER(9);
   l_proc    varchar2(80) := g_package||'start_log_for_entity';
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
-- Log context for entity is the entity name
  IF p_bdgt_entity_type = 'POSITION' THEN
     l_entity_name := hr_general.decode_position_latest_name(p_entity_id);
  ELSIF p_bdgt_entity_type = 'ORGANIZATION' THEN
     l_entity_name := hr_general.decode_organization(p_entity_id);
  ELSIF p_bdgt_entity_type = 'JOB' THEN
     l_entity_name := hr_general.decode_job(p_entity_id);
  ELSIF p_bdgt_entity_type = 'GRADE' THEN
     l_entity_name := hr_general.decode_grade(p_entity_id);
  END IF;
  l_master_log_id := get_process_log_id(p_folder_id => p_folder_id
                                       ,p_transaction_id => p_transaction_id
                                       ,p_entity_type => p_txn_entity_type);

  pqh_process_log_api.create_process_log(p_process_log_id => l_log_id
                                         ,p_module_cd => 'BUDGET_REALLOCATION'
                                         ,p_txn_id => p_entity_id
                                         ,p_log_context => l_entity_name
                                         ,p_batch_start_date => sysdate
                                         ,p_master_process_log_id => l_master_log_id
                                         ,p_message_type_cd => 'START'
                                         ,p_message_text => 'Process Started'
                                         ,p_information_category => p_txn_entity_type||'D'
                                         ,p_effective_date => sysdate
                                         ,p_object_version_number => l_ovn);
  commit;
  hr_utility.set_location('Leaving '||l_proc,20);
END start_log_for_entity;

FUNCTION get_batch_status(p_start_log_id IN NUMBER) RETURN varchar2 IS

CURSOR csr_status (p_message_type_cd  IN VARCHAR2 ) IS
SELECT COUNT(*)
FROM pqh_process_log
WHERE message_type_cd = p_message_type_cd
START WITH  process_log_id = p_start_log_id
CONNECT BY PRIOR process_log_id = master_process_log_id;

l_count_error           NUMBER := 0;
l_count_warning         NUMBER := 0;
l_status                VARCHAR2(30);
l_proc                  varchar2(80) := g_package||'get_batch_status';
BEGIN
  hr_utility.set_location('Entering '||l_proc,10);
  /*
    Compute the status of the batch. If there exists any record in the batch with
    message_type_cd = 'ERROR' then the transaction_status = 'ERROR'
    If there only exists records in the batch with message_type_cd = 'WARNING' then
    the transaction_status = 'WARNING'
    If there are NO records in the batch with message_type_cd = 'WARNING' OR 'ERROR' then
    the transaction_status = 'SUCCESS'
  */
   OPEN csr_status(p_message_type_cd => 'ERROR');
     FETCH csr_status INTO l_count_error;
   CLOSE csr_status;
   OPEN csr_status(p_message_type_cd => 'WARNING');
     FETCH csr_status INTO l_count_warning;
   CLOSE csr_status;
   IF l_count_error <> 0 THEN
     -- there are one or more errors
      l_status := 'ERROR';
   ELSE
     -- errors are 0 , check for warnings
      IF l_count_warning <> 0 THEN
        -- there are one or more warnings
        l_status := 'WARNING';
      ELSE
        -- no errors or warnings
         l_status := 'SUCCESS';
      END IF;
   END IF;
   hr_utility.set_location('Leaving '||l_status||l_proc,10);
   RETURN l_status;
END get_batch_status;
PROCEDURE end_realloc_log(p_txn_entity_type IN varchar2
                         ,p_folder_id IN NUMBER
                         ,p_transaction_id IN NUMBER
                         ,p_entity_id IN NUMBER  Default NULL
                         ) IS

l_status                VARCHAR2(30);
PRAGMA AUTONOMOUS_TRANSACTION;
l_process_log_id NUMBER(15);
l_proc varchar2(80) := g_package||'end_realloc_log';
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   l_process_log_id := get_process_log_id(p_entity_type => p_txn_entity_type
                                         ,p_folder_id => p_folder_id
                                         ,p_transaction_id => p_transaction_id
                                         ,p_entity_id => p_entity_id);
   l_status := get_batch_status(l_process_log_id);
  /*
    update the 'start' record for this transaction with message_type_cd = 'COMPLETE'
  */
   UPDATE pqh_process_log
   SET message_type_cd = DECODE(message_type_cd,'ERROR',message_type_cd,'COMPLETE'),
       message_text   = DECODE(message_type_cd,'ERROR',message_text,fnd_message.get_string('PQH','PQH_PROCESS_COMPLETED')),
       batch_status = DECODE(batch_status,'ERROR',batch_status,l_status),
       batch_end_date = sysdate
   WHERE process_log_id = l_process_log_id;
   hr_utility.set_location('Leaving '||l_proc,20);
   Commit;
END end_realloc_log;

PROCEDURE update_log_message(p_folder_id IN Number
                            ,p_txn_entity_type IN varchar2 ---- T/D/R/DP
                            ,p_transaction_id IN Number Default Null
                            ,p_entity_id IN Number Default Null
                            ,p_budget_period_id IN NUMBER default Null
                            ,p_message_type_cd  IN varchar2  -- E/I/W
                            ,p_message_text IN varchar2) IS
  l_proc varchar2(80) := g_package||'update_log_message';
  l_process_log_id  NUMBER(15);
  l_message_type_cd VARCHAR2(30);
  l_status varchar2(30);
  l_log_context  Varchar2(200);
  l_ovn NUMBER(9);
  l_period_log_id NUMBER(15);
  l_folder_log_id NUMBER(15);
  Cursor Csr_period_dates IS
    SELECT to_char(tp1.start_date,'DD-MM-RRRR')||' '||to_char(tp2.end_date,'DD-MM-RRRR')
    FROM   pqh_budget_periods bpr,
           per_time_periods tp1,
           per_time_periods tp2
    WHERE  bpr.budget_period_id = p_budget_period_id
    AND    tp1.time_period_id = bpr.start_time_period_id
    AND    tp2.time_period_id = bpr.end_time_period_id;
  Cursor csr_rcvr_dates IS
   SELECT  to_char(bpr.start_date,'DD-MM-RRRR')||' '||to_char(bpr.end_date,'DD-MM-RRRR')
   FROM    pqh_bdgt_pool_realloctions bpr
   WHERE   bpr.reallocation_id = p_budget_period_id;

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   IF p_folder_id IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                               ,p_argument => 'p_folder_id'
                               ,p_argument_value => p_folder_id);
   END IF;
   IF p_txn_entity_type IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                               ,p_argument => 'p_txn_entity_type'
                               ,p_argument_value => p_txn_entity_type);
   END IF;
   IF p_message_type_cd = 'E' THEN
     l_message_type_cd := 'ERROR';
     l_status := 'ERROR';
   ELSIF p_message_type_cd = 'W' THEN
     l_message_type_cd := 'WARNING';
     l_status := 'WARNING';
   END IF;
   IF p_txn_entity_type = 'F' THEN
    l_process_log_id := get_process_log_id(p_entity_type => 'F'
                                          ,p_folder_id => p_folder_id);
    l_log_context := 'FOLDER';
       pqh_process_log_api.create_process_log(p_process_log_id => l_folder_log_id
                                             ,p_module_cd => 'BUDGET_REALLOCATION'
                                             ,p_txn_id => p_folder_id
                                             ,p_log_context => l_log_context
                                             ,p_master_process_log_id => l_process_log_id
                                             ,p_message_text => NVL(p_message_text,'Completed Successfully')
                                             ,p_message_type_cd => NVL(l_message_type_cd,'COMPLETE')
                                             ,p_information_category => p_txn_entity_type
                                             ,p_object_version_number => l_ovn
                                             ,p_effective_date => sysdate );

   ELSIF p_txn_entity_type = 'T' THEN
     IF p_transaction_id IS NULL THEN
         hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                                   ,p_argument => 'p_transaction_id'
                                   ,p_argument_value => p_transaction_id);
      END IF;
      l_process_log_id := get_process_log_id(p_entity_type => 'T'
                                           ,p_transaction_id => p_transaction_id
                                           ,p_folder_id => p_folder_id);
      UPDATE  pqh_process_log
      set     message_type_cd =  l_message_type_cd
             ,batch_status = l_status
             ,message_text = p_message_text
      WHERE   process_log_id = l_process_log_id;
     ELSIF p_txn_entity_type IN ('DP','RP') THEN
       IF p_transaction_id IS NULL THEN
         hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                                   ,p_argument => 'p_transaction_id'
                                   ,p_argument_value => p_transaction_id);
       END IF;
       IF p_entity_id IS NULL THEN
         hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                                   ,p_argument => 'p_entity_id'
                                   ,p_argument_value => p_entity_id);
       END IF;
       IF p_budget_period_id IS NULL THEN
         hr_api.mandatory_arg_error(p_api_name => 'PQH_BDGT_REALLOC_LOG_PKG'
                                   ,p_argument => 'p_budget_period_id'
                                   ,p_argument_value => p_budget_period_id);
       END IF;
       l_process_log_id := get_process_log_id(p_entity_type=> substr(p_txn_entity_type,1,1)||'D'
                                             ,p_transaction_id => p_transaction_id
                                             ,p_folder_id => p_folder_id
                                             ,p_entity_id => p_entity_id);
       IF p_txn_entity_type = 'DP' THEN
         OPEN csr_period_dates;
         FETCH csr_period_dates INTO l_log_context;
         CLOSE csr_period_dates;
       ELSIF p_txn_entity_type = 'RP' THEN
        OPEN csr_rcvr_dates;
        FETCH csr_rcvr_dates INTO l_log_context;
        CLOSE csr_rcvr_dates;
       END IF;
       pqh_process_log_api.create_process_log(p_process_log_id => l_period_log_id
                                             ,p_module_cd => 'BUDGET_REALLOCATION'
                                             ,p_txn_id => p_budget_period_id
                                             ,p_log_context => l_log_context
                                             ,p_master_process_log_id => l_process_log_id
                                             ,p_message_text => NVL(p_message_text,'Completed Successfully')
                                             ,p_message_type_cd => NVL(l_message_type_cd,'COMPLETE')
                                             ,p_information_category => p_txn_entity_type
                                             ,p_object_version_number => l_ovn
                                             ,p_effective_date => sysdate );

   END IF;
   COMMIT;
   hr_utility.set_location('Leaving '||l_proc,20);
END update_log_message;

PROCEDURE  start_log(p_folder_id IN Number
                    ,p_transaction_id IN Number
                    ,p_entity_id IN Number
                    ,p_txn_entity_type IN varchar2 -- F/T/R/D
                    ,p_bdgt_entity_type IN varchar2 ) IS
  l_proc varchar2(80) := g_package||'start_log';
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   IF p_txn_entity_type = 'F' THEN
      start_log_for_folder(p_folder_id=> p_folder_id);
   ELSIF p_txn_entity_type = 'T' THEN
      start_log_for_transaction( p_folder_id => p_folder_id
                                ,p_transaction_id => p_transaction_id);
   ELSIF p_txn_entity_type IN ('D','R') THEN
      start_log_for_entity(p_folder_id => p_folder_id
                          ,p_transaction_id => p_transaction_id
                          ,p_txn_entity_type =>p_txn_entity_type
                          ,p_bdgt_entity_type => p_bdgt_entity_type
                          ,p_entity_id => p_entity_id);
   END IF;
   hr_utility.set_location('Leaving '||l_proc,20);
END start_log;

PROCEDURE log_rule_for_entity(p_folder_id IN NUMBER
                             ,p_transaction_id IN NUMBER
                             ,p_txn_entity_type IN varchar2 --(D/R)
                             ,p_bdgt_entity_type IN varchar2
                             ,p_entity_id IN NUMBER
                             ,p_budget_period_id IN NUMBER
                             ,p_rule_name IN varchar2
                             ,p_rule_level IN varchar2
                             ,p_rule_msg_cd IN Varchar2) IS

  l_master_log_id  NUMBER(15);
  l_message_text   VARCHAR2(4000);
  l_ovn            NUMBER(9);
  l_rule_log_id NUMBER(15);
  l_message_type_cd VARCHAR2(30);
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(80) := g_package||'log_rule_for_entity';
BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
-- set the message level based on the rule level for the current rule violation
   IF   p_rule_level = 'E' THEN
     l_message_type_cd := 'ERROR';
  ELSIF p_rule_level = 'W' THEN
     l_message_type_cd := 'WARNING';
  END IF;
--Calling code is to send the message text now. so no need for set_name call
--  fnd_message.set_name(8302,p_rule_msg_cd);
--
  l_message_text :=  p_rule_msg_cd;
  IF p_txn_entity_type = 'F' THEN
   update_log_message(p_folder_id => p_folder_id
                     ,p_txn_entity_type => 'F'
                     ,p_message_type_cd => p_rule_level
                     ,p_message_text => l_message_text);
   hr_utility.set_location('Leaving from F '||l_proc,11);
   RETURN;
  ELSIF p_txn_entity_type = 'T' THEN
    update_log_message(p_folder_id => p_folder_id
                      ,p_transaction_id => p_transaction_id
                      ,p_txn_entity_type => 'T'
                      ,p_message_type_cd => p_rule_level
                      ,p_message_text=> l_message_text);
   hr_utility.set_location('Leaving from T '||l_proc,11);
   RETURN;
  END IF;
  IF p_txn_entity_type IN ('DP','RP') THEN
   -- code for inserting a row under the entity for Donor Periods under a Donor Entity
     update_log_message(p_folder_id => p_folder_id
                       ,p_transaction_id => p_transaction_id
                       ,p_entity_id => p_entity_id
                       ,p_txn_entity_type => p_txn_entity_type
                       ,p_budget_period_id => p_budget_period_id
                       ,p_message_type_cd => p_rule_level
                       ,p_message_text => l_message_text);
   hr_utility.set_location('Leaving from DP '||l_proc,12);
   RETURN;
  END IF;

  l_master_log_id := get_process_log_id(p_folder_id => p_folder_id
                                       ,p_transaction_id => p_transaction_id
                                       ,p_entity_type => p_txn_entity_type||'D'
                                       ,p_entity_id => p_entity_id);

  -- Create an entry in the process log for the current rule under the current entity
   pqh_process_log_api.create_process_log(p_process_log_id => l_rule_log_id
                                         ,p_module_cd => 'BUDGET_REALLOCATION'
                                         ,p_txn_id => p_entity_id
                                         ,p_log_context => p_rule_name
                                         ,p_master_process_log_id => l_master_log_id
                                         ,p_message_text => NVL(l_message_text,'Completed Successfully')
                                         ,p_message_type_cd => NVL(l_message_type_cd,'COMPLETE')
                                         ,p_information_category => p_txn_entity_type||'M'
                                         ,p_object_version_number => l_ovn
                                         ,p_effective_date => sysdate );
   hr_utility.set_location('Leaving '||l_proc,20);

  commit;
END  log_rule_for_entity;

PROCEDURE end_log(p_txn_entity_type IN varchar2
                 ,p_folder_id IN NUMBER
                 ,p_transaction_id IN NUMBER
                 ,p_entity_id IN NUMBER) IS
  l_proc  varchar2(80) := g_package||'end_log';
BEGIN
     hr_utility.set_location('Entering '||l_proc,10);
     IF p_txn_entity_type = 'F' THEN
           PQH_PROCESS_BATCH_LOG.END_LOG;
     ELSIF p_txn_entity_type = 'T' THEN
          end_realloc_log(p_txn_entity_type => p_txn_entity_type
                         ,p_folder_id => p_folder_id
                         ,p_transaction_id => p_transaction_id);
          end_realloc_log(p_txn_entity_type => 'D'
                         ,p_folder_id => p_folder_id
                         ,p_transaction_id => p_transaction_id);
          end_realloc_log(p_txn_entity_type => 'R'
                         ,p_folder_id => p_folder_id
                         ,p_transaction_id => p_transaction_id);
     ELSE
          end_realloc_log(p_txn_entity_type => p_txn_entity_type||'D'
                         ,p_folder_id => p_folder_id
                         ,p_transaction_id => p_transaction_id
                         ,p_entity_id => p_entity_id);
    END IF;
    hr_utility.set_location('Leaving '||l_proc,20);
END end_log;
END pqh_bdgt_realloc_log_pkg;

/
