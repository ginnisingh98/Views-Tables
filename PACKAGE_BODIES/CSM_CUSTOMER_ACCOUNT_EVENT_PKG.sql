--------------------------------------------------------
--  DDL for Package Body CSM_CUSTOMER_ACCOUNT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CUSTOMER_ACCOUNT_EVENT_PKG" AS
/* $Header: csmecatb.pls 120.2 2006/07/27 11:05:40 trajasek noship $ */
g_cst_accnt_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_HZ_CUST_ACCOUNTS_ACC';
g_cst_accnt_table_name            CONSTANT VARCHAR2(30) := 'HZ_CUST_ACCOUNTS';
g_cst_accnt_seq_name              CONSTANT VARCHAR2(30) := 'CSM_HZ_CUST_ACCOUNTS_ACC_S' ;
g_cst_accnt_pk1_name              CONSTANT VARCHAR2(30) := 'CUST_ACCOUNT_ID';
g_pub_item               		  CONSTANT VARCHAR2(30) := 'CSM_HZ_CUST_ACCOUNTS';
g_accnt_pubi_name 			      CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_HZ_CUST_ACCOUNTS');

--PROCEDURE IMPLEMENTATION DETAILS
--This procedure will insert account id into the access table only for the party
--which is passed to this procedure and which is not already present in the CUST ACcount Access table
--Here the counter value for the ucstomer accoutns wont get increased even thought multiple instance of
--the party is present in the party Access table
PROCEDURE CUST_ACCOUNTS_INS (p_party_id NUMBER , p_user_id NUMBER)
IS
--CURSOR declarations
CURSOR  c_cust_accnt_ins(c_party_id NUMBER , c_user_id NUMBER)
IS
SELECT 	hzc.CUST_ACCOUNT_ID
FROM 	HZ_CUST_ACCOUNTS hzc
WHERE 	hzc.PARTY_ID = c_party_id
AND NOT EXISTS
	(
	SELECT 	1
	FROM 	CSM_HZ_CUST_ACCOUNTS_ACC acc
	WHERE 	acc.USER_ID = c_user_id
	AND		acc.CUST_ACCOUNT_ID = hzc.CUST_ACCOUNT_ID
	);

--variable declarations
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(2000);
p_message		VARCHAR2(3000);

BEGIN

    CSM_UTIL_PKG.LOG('Entering CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS',FND_LOG.LEVEL_EXCEPTION);


	FOR	l_cust_accnt_rec IN c_cust_accnt_ins(p_party_id,p_user_id)
	LOOP

   		CSM_ACC_PKG.Insert_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_accnt_pubi_name
     	,P_ACC_TABLE_NAME         => g_cst_accnt_acc_table_name
     	,P_SEQ_NAME               => g_cst_accnt_seq_name
     	,P_PK1_NAME               => g_cst_accnt_pk1_name
     	,P_PK1_NUM_VALUE          => l_cust_accnt_rec.CUST_ACCOUNT_ID
     	,P_USER_ID                => p_user_id
    	);

	END LOOP;

    CSM_UTIL_PKG.LOG('Leaving CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS',FND_LOG.LEVEL_EXCEPTION);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_message   := 'Exception in CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS Procedure :' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(p_message, 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_INS',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END CUST_ACCOUNTS_INS;
--update cannot be logically called from anywhere...
--but right now its planned to call from  JTM LOOKUP PROGRAM

PROCEDURE CUST_ACCOUNTS_UPD (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--CURSOR declarations
CURSOR  c_cust_accnt_upd(c_last_run_date DATE)
IS
SELECT 	acc.access_id,acc.user_id
FROM 	HZ_CUST_ACCOUNTS hzc , CSM_HZ_CUST_ACCOUNTS_ACC acc
WHERE 	hzc.cust_account_id = acc.cust_account_id
AND 	hzc.LAST_UPDATE_DATE > c_last_run_date;

--cursor to get last run date from jtm_con_request_data
CURSOR csr_last_run_date
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50) )
FROM 	jtm_con_request_data
WHERE 	package_name 	= 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG'
AND 	procedure_name 	= 'CUST_ACCOUNTS_UPD';

--variable declarations
l_cst_account_id 	HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
l_sqlerrno 		varchar2(20);
l_sqlerrmsg 	varchar2(2000);
l_markdirty		BOOLEAN;
l_accessid_lst 	asg_download.access_list;
l_userid_lst 	asg_download.user_list;
l_last_run_date JTM_CON_REQUEST_DATA.LAST_RUN_DATE%TYPE;

BEGIN
    CSM_UTIL_PKG.LOG('Entering CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD',FND_LOG.LEVEL_EXCEPTION);

	OPEN 	csr_last_run_date;
	FETCH	csr_last_run_date INTO l_last_run_date;
	CLOSE	csr_last_run_date;

	OPEN c_cust_accnt_upd(l_last_run_date);
	LOOP

		IF 	l_userid_lst.COUNT > 0 THEN
			l_userid_lst.DELETE;
		END IF;
		IF l_accessid_lst.COUNT > 0 THEN
			l_accessid_lst.DELETE;
		END IF;

		FETCH c_cust_accnt_upd BULK COLLECT INTO l_accessid_lst,l_userid_lst LIMIT 50;
		EXIT WHEN l_accessid_lst.COUNT=0;

   		l_markdirty := asg_download.mark_dirty( g_pub_item,l_accessid_lst
                                      ,l_userid_lst, 'U', sysdate );

		COMMIT;
	END LOOP;

	UPDATE 	jtm_con_request_data
	SET 	last_run_date   = sysdate
	WHERE 	package_name 	= 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG'
	AND 	procedure_name 	= 'CUST_ACCOUNTS_UPD';

	COMMIT;
	CLOSE c_cust_accnt_upd;
 	p_status := 'FINE';
	p_message :=  'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD Executed successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD',FND_LOG.LEVEL_EXCEPTION);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status 	 := 'ERROR';
     p_message   := 'Exception in CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD Procedure :' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(p_message, 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_UPD',FND_LOG.LEVEL_EXCEPTION);
     ROLLBACK;

END CUST_ACCOUNTS_UPD;

--PROCEDURE IMPLEMENTATION DETAILS
--While deleting the records from access table we are not considering the counter value
--in the access table this is because we do delete only for the accounts which
--doesnot have the corresponding party_id in the CSM_PARTIES_ACC Table.
--ie.The Delete depends only the pary acccess table.This delete procedure is called
--whenever the pary delete is called
PROCEDURE CUST_ACCOUNTS_DEL (p_party_id NUMBER , p_user_id NUMBER)
IS
--CURSOR declarations
CURSOR c_cust_accnt_del(c_party_id NUMBER , c_user_id NUMBER)
IS
SELECT 	acc.CUST_ACCOUNT_ID,acc.access_id
FROM 	CSM_HZ_CUST_ACCOUNTS_ACC acc
WHERE 	acc.USER_ID = c_user_id
AND NOT EXISTS
	(
	SELECT 	1
	FROM 	CSM_PARTIES_ACC acc
	WHERE 	acc.USER_ID  = c_user_id
	AND		acc.party_ID = c_party_id
	);

--variable declarations
l_cst_account_id 	HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
l_sqlerrno 		varchar2(20);
l_sqlerrmsg 	varchar2(2000);
p_message		VARCHAR(3000);
l_access_id		CSM_HZ_CUST_ACCOUNTS_ACC.ACCESS_ID%TYPE;
l_markdirty		BOOLEAN;
BEGIN

    CSM_UTIL_PKG.LOG('Entering CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL',FND_LOG.LEVEL_EXCEPTION);

	--take all teh cust_account_id for the party which doesnot exists for the user_id
	FOR	l_cust_accnt_rec IN c_cust_accnt_del(p_party_id,p_user_id)
	LOOP
		l_access_id := l_cust_accnt_rec.access_id;
   		CSM_ACC_PKG.Delete_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_accnt_pubi_name
     	,P_ACC_TABLE_NAME         => g_cst_accnt_acc_table_name
     	,P_PK1_NAME               => g_cst_accnt_pk1_name
     	,P_PK1_NUM_VALUE          => l_cust_accnt_rec.CUST_ACCOUNT_ID
     	,P_USER_ID                => p_user_id
    	);

	END LOOP;

    CSM_UTIL_PKG.LOG('Leaving CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL Package ', 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL',FND_LOG.LEVEL_EXCEPTION);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_message   := 'Exception in CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL Procedure : for accessid ' || l_access_id ||': with error' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(p_message, 'CSM_CUSTOMER_ACCOUNT_EVENT_PKG.CUST_ACCOUNTS_DEL',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END CUST_ACCOUNTS_DEL;

END CSM_CUSTOMER_ACCOUNT_EVENT_PKG;

/
