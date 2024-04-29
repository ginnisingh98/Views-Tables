--------------------------------------------------------
--  DDL for Package Body CSM_CNTR_RELATION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CNTR_RELATION_EVENT_PKG" AS
/* $Header: csmecrlb.pls 120.0 2005/11/23 06:35:32 trajasek noship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
g_cst_accnt_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_CNTR_RELATIONSHIPS_ACC';
g_cst_accnt_table_name            CONSTANT VARCHAR2(30) := 'CSI_COUNTER_RELATIONSHIPS';
g_cst_accnt_seq_name              CONSTANT VARCHAR2(30) := 'CSM_CNTR_RELATIONSHIPS_ACC_S' ;
g_cst_accnt_pk1_name              CONSTANT VARCHAR2(30) := 'RELATIONSHIP_ID';
g_pub_item               		  CONSTANT VARCHAR2(30) := 'CSM_CNTR_RELATIONSHIPS';
g_accnt_pubi_name 			      CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_CNTR_RELATIONSHIPS');


PROCEDURE COUNTER_RELATION_INS(p_counter_id NUMBER,
                                       p_user_id NUMBER)
IS
--variable declarations
l_sqlerrno 			VARCHAR2(20);
l_sqlerrmsg 		varchar2(2000);
l_mark_dirty 		boolean;
l_relationship_id 	CSI_COUNTER_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
--Cursor Declarations
--Insert Cursor
CURSOR csr_cntr_rel_ins(l_counter_id NUMBER,l_user_id NUMBER)
IS
SELECT 	b.relationship_id
FROM 	csi_counter_relationships b
WHERE 	source_counter_id = l_counter_id
AND 	NOT EXISTS
    	(
		SELECT	1
     	FROM 	CSM_CNTR_RELATIONSHIPS_ACC acc
     	WHERE 	acc.relationship_id = b.relationship_id
     	AND		acc.user_id			= l_user_id
    	);
BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS ',
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS', FND_LOG.LEVEL_PROCEDURE);
 --process inserts
	FOR	l_cntr_rel_rec IN csr_cntr_rel_ins(p_counter_id,p_user_id)
	LOOP

   		CSM_ACC_PKG.Insert_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_accnt_pubi_name
     	,P_ACC_TABLE_NAME         => g_cst_accnt_acc_table_name
     	,P_SEQ_NAME               => g_cst_accnt_seq_name
     	,P_PK1_NAME               => g_cst_accnt_pk1_name
     	,P_PK1_NUM_VALUE          => l_cntr_rel_rec.relationship_id
     	,P_USER_ID                => p_user_id
    	);
 		CSM_UTIL_PKG.LOG('Inserting counter relationship id ' || TO_CHAR(l_cntr_rel_rec.relationship_id) || ' for user '||TO_CHAR(p_user_id) , 'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS',FND_LOG.LEVEL_PROCEDURE);

	END LOOP;
	COMMIT;
  CSM_UTIL_PKG.LOG('Leaving CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS ',
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS',FND_LOG.LEVEL_PROCEDURE);
 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_INS',FND_LOG.LEVEL_EXCEPTION);
END COUNTER_RELATION_INS;

--Deleting relationships
PROCEDURE COUNTER_RELATION_DEL(p_counter_id NUMBER,
                                       p_user_id NUMBER)
IS
--variable declarations
l_sqlerrno 			VARCHAR2(20);
l_sqlerrmsg 		varchar2(2000);
l_mark_dirty 		boolean;
l_relationship_id 	CSI_COUNTER_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
--Cursor Declarations
--Insert Cursor
--delete the relationship for the counter only if the counter access table does not contain
--the counter id that is corresponding to the mapping(source_counter_id)
CURSOR csr_cntr_rel_del(l_counter_id NUMBER,l_user_id NUMBER)
IS
SELECT 	acc.relationship_id
FROM 	csi_counter_relationships b,
		CSM_CNTR_RELATIONSHIPS_ACC acc
WHERE 	b.source_counter_id = l_counter_id
AND		acc.user_id			= l_user_id
AND		acc.relationship_id = b.relationship_id
AND 	NOT EXISTS
    	(
		SELECT	1
     	FROM 	CSM_COUNTERS_ACC cacc
     	WHERE 	cacc.counter_id = l_counter_id
     	AND		cacc.user_id	= l_user_id
    	);
BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL ',
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL', FND_LOG.LEVEL_PROCEDURE);
 --process inserts
	FOR	l_cntr_rel_rec IN csr_cntr_rel_del(p_counter_id,p_user_id)
	LOOP

   		CSM_ACC_PKG.Delete_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_accnt_pubi_name
     	,P_ACC_TABLE_NAME         => g_cst_accnt_acc_table_name
     	,P_PK1_NAME               => g_cst_accnt_pk1_name
     	,P_PK1_NUM_VALUE          => l_cntr_rel_rec.relationship_id
     	,P_USER_ID                => p_user_id
    	);
 		CSM_UTIL_PKG.LOG('Deleting counter relationship id ' || TO_CHAR(l_cntr_rel_rec.relationship_id) || ' for user '||TO_CHAR(p_user_id) , 'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL',FND_LOG.LEVEL_PROCEDURE);

	END LOOP;
	COMMIT;
  CSM_UTIL_PKG.LOG('Leaving CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL ',
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL',FND_LOG.LEVEL_PROCEDURE);
 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_CNTR_RELATIONSHIPS_EVENT_PKG.COUNTER_RELATION_DEL',FND_LOG.LEVEL_EXCEPTION);
END COUNTER_RELATION_DEL;

END CSM_CNTR_RELATION_EVENT_PKG;

/
