--------------------------------------------------------
--  DDL for Package Body CSM_DEFERRED_TXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DEFERRED_TXNS_PKG" AS
/*$Header: csmdftxb.pls 120.2.12010000.2 2009/08/07 09:37:27 saradhak noship $*/

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_DEFERRED_TXNS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_DEFERRED_TRANSACTIONS';
g_debug_level           NUMBER; -- debug level

PROCEDURE correct_inq_for_reapply(p_tracking_id IN NUMBER,
                                  p_tranid IN NUMBER, p_client_id IN VARCHAR2)
IS
l_qry  VARCHAR2(4000);
old_tranid NUMBER;
old_client_id varchar2(100);
old_seq NUMBER;
old_dml VARCHAR2(1);
inq_table VARCHAR2(100);
inq_pk_col VARCHAR2(100);
inq_pk_value varchar2(100);
l_proceed NUMBER;

BEGIN
 SELECT nfn.DEFERRED_TRAN_ID,nfn.CLIENT_ID, nfn.SEQUENCE,nfn.DML,
        nfn.OBJECT_NAME,pi.PRIMARY_KEY_COLUMN,nfn.OBJECT_ID,instr(pi.PRIMARY_KEY_COLUMN,',')
 INTO old_tranid, old_client_id,old_seq,old_dml,inq_table,inq_pk_col,inq_pk_value,l_proceed
 FROM CSM_DEFERRED_NFN_INFO nfn, ASG_PUB_ITEM pi
 WHERE nfn.tracking_id=p_tracking_id
 AND nfn.OBJECT_NAME = pi.item_id;

 IF l_proceed > 0 THEN
  CSM_UTIL_PKG.LOG('Multiple Pks in '||inq_table||' is not supported for correction',
                      'CSM_DEFERRED_TXNS_PKG.correct_inq_for_reapply',FND_LOG.LEVEL_PROCEDURE);
  RETURN;
 END IF;

 BEGIN

 l_qry:='SELECT 1 FROM '||inq_table||'_INQ WHERE '||inq_pk_col||'='''||inq_pk_value||''' AND TRANID$$='
         ||p_tranid||' AND CLID$$CS='''||p_client_id||'''';

 EXECUTE IMMEDIATE l_qry INTO l_proceed;

 l_qry:='DELETE FROM '||inq_table||'_INQ WHERE '||inq_pk_col||'='''||inq_pk_value||''' AND TRANID$$='
         ||old_tranid||' AND CLID$$CS='''||old_client_id||''' AND SEQNO$$='||old_seq;

 EXECUTE IMMEDIATE l_qry;

 IF(SQL%ROWCOUNT=0) THEN  -- Chances are there that MFS admin discarded this record already
                          -- in which case let the so-called corrected record go in the same txn
   CSM_UTIL_PKG.LOG('Tracking INQ record was lost',
                      'CSM_DEFERRED_TXNS_PKG.correct_inq_for_reapply',FND_LOG.LEVEL_PROCEDURE);

   RETURN;
 END IF;

 l_qry:= 'UPDATE '||inq_table||'_INQ SET TRANID$$='||old_tranid||',CLID$$CS='''||old_client_id||''' ,'
         ||' SEQNO$$='||old_seq||', DMLTYPE$$='''||old_dml||''' WHERE '||inq_pk_col||'='''||inq_pk_value||''' AND TRANID$$='
         ||p_tranid||' AND CLID$$CS='''||p_client_id||'''';

 EXECUTE IMMEDIATE l_qry;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CSM_UTIL_PKG.LOG('No data found in '||inq_table||'_INQ'||' with pk:'||inq_pk_value,
                      'CSM_DEFERRED_TXNS_PKG.correct_inq_for_reapply',FND_LOG.LEVEL_EXCEPTION);

    CSM_UTIL_PKG.LOG('Query is: '||l_qry,
                      'CSM_DEFERRED_TXNS_PKG.correct_inq_for_reapply',FND_LOG.LEVEL_EXCEPTION);

    CSM_UTIL_PKG.LOG('If there is no issue with query then a blind Re-apply was initiated from client without a corrected root record.',
                      'CSM_DEFERRED_TXNS_PKG.correct_inq_for_reapply',FND_LOG.LEVEL_PROCEDURE);
 END;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL; -- can't happen as we check base table for existence before calling this api.
END correct_inq_for_reapply;



PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
l_exists NUMBER;
l_qry VARCHAR2(400);

/* Select all inq records */
CURSOR c_inq_records( b_user_name VARCHAR2, b_tranid NUMBER)
IS
  SELECT *
  FROM  CSM_DEFERRED_TRANSACTIONS_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_tracking_tree(b_tracking_id number)
IS
 SELECT TRACKING_ID,CLIENT_ID FROM  CSM_DEFERRED_NFN_INFO
 connect by prior tracking_id=parent_id
 start with tracking_id=b_tracking_id;

CURSOR c_reapply_txn(b_tranid NUMBER,b_name VARCHAR2)
IS
 SELECT DISTINCT DEFERRED_TRAN_ID,CLIENT_ID
 FROM  CSM_DEFERRED_TRANSACTIONS_INQ
 WHERE tranid$$ = b_tranid  AND   clid$$cs = b_name
 AND  ACTION = 'C';

TYPE l_reapply_type IS TABLE OF c_reapply_txn%rowtype index by binary_integer;
l_reapply_tab l_reapply_type;

TYPE l_num_tab_type is table of number index by binary_integer;
TYPE l_char_tab_type is table of varchar2(100) index by binary_integer;

l_track_tab l_num_tab_type;
l_uname_tab l_char_tab_type;

l_cnt NUMBER:=0;

l_rec c_inq_records%rowtype;
l_process_status VARCHAR2(1);
l_error_msg      VARCHAR2(4000);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- NO DEFER FOR this PI from CSM

-- PURGE-1 : CLEAR INQ RECORDS WITH NO ACTION
-- PURGE-2 : CLEAR INQ RECORDS WITH NO CORRESPONDING RECORDS IN THE BASE TABLE
-- PURGE-3 : CLEAR INQ RECORDS WITH REAPPLY ACTION AND THAT ARE NOT ROOT
 l_cnt:=0;
 FOR clear_rec IN (SELECT TRACKING_ID,SEQNO$$ FROM CSM_DEFERRED_TRANSACTIONS_INQ inq
                   WHERE TRANID$$=p_tranid AND CLID$$CS=p_user_name
                   AND
                   (
                    (ACTION IS NULL OR ACTION NOT IN ('C','D'))
                   OR
                    NOT EXISTS(SELECT 1 FROM CSM_DEFERRED_NFN_INFO b
                               WHERE b.tracking_id=inq.tracking_id)
                   OR
                    (
                    ACTION='C'
                    AND EXISTS(SELECT 1 FROM CSM_DEFERRED_NFN_INFO b
                               WHERE b.tracking_id=inq.tracking_id
                               AND PARENT_ID IS NOT NULL)  /*REAPPLY supported only at ROOT level*/
                    )
                   ))
 LOOP
     CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          clear_rec.seqno$$,
          clear_rec.tracking_id,
          g_object_name,
          g_pub_name,
          l_error_msg,    --OUT variable
          l_process_status
        );

    BEGIN
      SELECT 'S' INTO l_process_status
      FROM CSM_DEFERRED_NFN_INFO
      WHERE tracking_id=clear_rec.tracking_id;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      /*Send a reject row for recs in INQ that don't exist in Base*/
       l_error_msg:= 'No such record in Base table';
       asg_defer.reject_row(p_user_name,
                            p_tranid,
                            g_pub_name,
                            clear_rec.seqno$$,
                            l_error_msg,   --IN variable of asg api
                            l_process_status);
       l_cnt:=l_cnt+1;
    END;

 END LOOP;

 IF(l_cnt>0) THEN
   CSM_UTIL_PKG.LOG('Purged and rejected '||l_cnt|| ' tracking records from INQ as they are missing in base table for -'||p_user_name ||' in current txn-'||p_tranid,
                      'CSM_DEFERRED_TXNS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
 END IF;


/***************************************PROCESS INQ RECORDS*********************************************/
--'D' for Discard : for a record, the record and all its related entries will discarded

--'C' for Reapply: the record should be root. Entire txn is reapplied but only this root record and its children
                 -- will be tracked

/* STORE REAPPLY TXNS - since INQ is cleared before reapply is called*/
OPEN c_reapply_txn(p_tranid,p_user_name);
FETCH c_reapply_txn BULK COLLECT INTO l_reapply_tab;
CLOSE c_reapply_txn;

FOR def_rec IN c_inq_records(p_user_name,p_tranid)
 LOOP
   CSM_UTIL_PKG.LOG('Found '||def_rec.tracking_id||' with action '||def_rec.action||' for -'||p_user_name ||' for txn-'||p_tranid,
                      'CSM_DEFERRED_TXNS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  /*Take action*/
   IF def_rec.ACTION = 'D' THEN
      -- Discard root(need not be main root,can be partial) and all its related entries
      l_cnt:=0;
      FOR disc_rec IN (SELECT * FROM  CSM_DEFERRED_NFN_INFO
                       connect by prior tracking_id=parent_id
                       start with tracking_id=def_rec.tracking_id)
      LOOP
        IF(disc_rec.dml='I') THEN
          asg_defer.reject_row(disc_rec.client_id,
                               disc_rec.deferred_tran_id,
                               disc_rec.OBJECT_NAME,
                               disc_rec.sequence,
                               disc_rec.error_msg,   --IN variable of asg api
                               l_process_status);
        END IF;

        CSM_UTIL_PKG.LOG('Discarding Tracking Id: '||disc_rec.tracking_id,
                      'CSM_DEFERRED_TXNS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

        asg_defer.discard_transaction(disc_rec.client_id,
                                     disc_rec.deferred_tran_id,
                                     disc_rec.OBJECT_NAME,
                                     disc_rec.sequence,l_process_status,false);


        CSM_ACC_PKG.Delete_Acc
         ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
          ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
          ,P_PK1_NAME               => 'TRACKING_ID'
          ,P_PK1_NUM_VALUE          => disc_rec.tracking_id
          ,P_USER_ID                => asg_base.get_user_id(disc_rec.client_id)
          );

        l_cnt:=l_cnt+1;
        l_track_tab(l_cnt):=disc_rec.tracking_id;

      END LOOP;


      FORALL I IN 1..l_cnt
       DELETE FROM CSM_DEFERRED_NFN_INFO WHERE TRACKING_ID = l_track_tab(I);

   ELSE /*IF def_rec.ACTION = 'C' THEN */

    /*correct inq*/
       correct_inq_for_reapply(def_rec.tracking_id,p_tranid,p_user_name);

    /*delete entire tree to reapply so that new defer reports updated error*/
      IF(l_track_tab.count >0) THEN
        l_track_tab.DELETE;
      END IF;
      IF(l_uname_tab.count >0) THEN
        l_uname_tab.DELETE;
      END IF;
      OPEN c_tracking_tree(def_rec.tracking_id);
      FETCH c_tracking_tree BULK COLLECT INTO l_track_tab,l_uname_tab;
      CLOSE c_tracking_tree;

      FOR I IN 1..l_track_tab.COUNT
      LOOP
         CSM_ACC_PKG.Delete_Acc
         ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
          ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
          ,P_PK1_NAME               => 'TRACKING_ID'
          ,P_PK1_NUM_VALUE          => l_track_tab(I)
          ,P_USER_ID                => asg_base.get_user_id(l_uname_tab(I))
          );

         DELETE FROM CSM_DEFERRED_NFN_INFO WHERE TRACKING_ID = l_track_tab(I);
      END LOOP;

   END IF;

--INQ Record processed successfully.
    CSM_UTIL_PKG.DELETE_RECORD
       (
         p_user_name,
         p_tranid,
         def_rec.seqno$$,
         def_rec.tracking_id,
         g_object_name,
         g_pub_name,
         l_error_msg,    --OUT variable
         l_process_status
        );

END LOOP;


--RE-APPLY
 FOR I IN 1..l_reapply_tab.COUNT
 LOOP
   CSM_UTIL_PKG.LOG('Reapplying Transaction:'||l_reapply_tab(I).DEFERRED_TRAN_ID ||' of user:'||l_reapply_tab(I).CLIENT_ID,
                      'CSM_DEFERRED_TXNS_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
   ASG_DEFER.reapply_transaction(l_reapply_tab(I).CLIENT_ID,l_reapply_tab(I).DEFERRED_TRAN_ID,l_process_status,false);
 END LOOP;


/* not required..done while upload in purge_pub_items
l_qry := 'DELETE FROM  ' ||asg_base.G_OLITE_SCHEMA ||'.C$INQ '
     ||' WHERE STORE='''||g_pub_name||''' AND TRANID$$='||p_tranid||' AND CLID$$CS= '''||p_user_name||'''';
execute immediate l_qry;
*/

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

   -- Set transaction status to discarded
PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
    BEGIN
	  /* process ROOT tracking records alone*/
	  FOR root_rec IN (SELECT TRACKING_ID FROM  CSM_DEFERRED_NFN_INFO
	                   WHERE CLIENT_ID=p_user_name AND DEFERRED_TRAN_ID=p_tranid
	                   AND PARENT_ID IS NULL)
	  LOOP
        FOR disc_rec IN (SELECT * FROM  CSM_DEFERRED_NFN_INFO
                         connect by prior tracking_id=parent_id
                         start with tracking_id=root_rec.tracking_id)
        LOOP
          IF(disc_rec.dml='I') THEN
            asg_defer.reject_row(disc_rec.client_id,
                                 disc_rec.deferred_tran_id,
                                 disc_rec.OBJECT_NAME,
                                 disc_rec.sequence,
                                 disc_rec.error_msg,   --IN variable of asg api
                                 x_return_status);
          END IF;

          CSM_ACC_PKG.Delete_Acc
           ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
            ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
            ,P_PK1_NAME               => 'TRACKING_ID'
            ,P_PK1_NUM_VALUE          => disc_rec.tracking_id
            ,P_USER_ID                => asg_base.get_user_id(disc_rec.client_id)
            );

        END LOOP;
	  END LOOP;

      DELETE FROM CSM_DEFERRED_NFN_INFO
	  WHERE CLIENT_ID=p_user_name
	  AND   DEFERRED_TRAN_ID=p_tranid;

   END;	   --processed tracking records


 ASG_DEFER.discard_transaction(p_user_name,p_tranid,x_return_status);

END discard_transaction;

-- Discards the specified deferred row ONLY
-- no related records are discarded
PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              p_pubitem  IN VARCHAR2,
                              p_sequence  IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_commit_flag IN BOOLEAN)
IS

 TYPE l_num_tab_type is table of number index by binary_integer;

 l_track_tab l_num_tab_type;
 l_tracking_id NUMBER;
 l_cnt NUMBER;
BEGIN

  BEGIN  --process tracking records
      SELECT TRACKING_ID INTO l_tracking_id
      FROM  CSM_DEFERRED_NFN_INFO
	  WHERE CLIENT_ID=p_user_name
	  AND   DEFERRED_TRAN_ID=p_tranid
	  AND   SEQUENCE = p_sequence
	  AND   OBJECT_NAME = p_pubitem;

      l_cnt:=0;
      FOR disc_rec IN (SELECT * FROM  CSM_DEFERRED_NFN_INFO
                       connect by prior tracking_id=parent_id
                       start with tracking_id=l_tracking_id)
      LOOP
        IF(disc_rec.dml='I') THEN
          asg_defer.reject_row(disc_rec.client_id,
                               disc_rec.deferred_tran_id,
                               disc_rec.OBJECT_NAME,
                               disc_rec.sequence,
                               disc_rec.error_msg,   --IN variable of asg api
                               x_return_status);
        END IF;

        CSM_ACC_PKG.Delete_Acc
         ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
          ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
          ,P_PK1_NAME               => 'TRACKING_ID'
          ,P_PK1_NUM_VALUE          => disc_rec.tracking_id
          ,P_USER_ID                => asg_base.get_user_id(disc_rec.client_id)
          );

        l_cnt:=l_cnt+1;
        l_track_tab(l_cnt):=disc_rec.tracking_id;

      END LOOP;

      FORALL I IN 1..l_cnt
       DELETE FROM CSM_DEFERRED_NFN_INFO WHERE TRACKING_ID = l_track_tab(I);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL;
  END;	   --processed tracking records

 ASG_DEFER.discard_transaction(p_user_name,p_tranid,p_pubitem,p_sequence,x_return_status,p_commit_flag);

END discard_transaction;

END CSM_DEFERRED_TXNS_PKG;

/
