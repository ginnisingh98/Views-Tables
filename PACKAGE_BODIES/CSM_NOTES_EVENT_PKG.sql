--------------------------------------------------------
--  DDL for Package Body CSM_NOTES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NOTES_EVENT_PKG" AS
/* $Header: csmenotb.pls 120.3 2006/09/19 10:58:38 saradhak noship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

l_markdirty_failed EXCEPTION;

g_notes_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_NOTES_ACC';
g_notes_table_name            CONSTANT VARCHAR2(30) := 'JTF_NOTES_B';
g_notes_seq_name              CONSTANT VARCHAR2(30) := 'CSM_NOTES_ACC_S';
g_notes_pk1_name              CONSTANT VARCHAR2(30) := 'JTF_NOTE_ID';
g_notes_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_NOTES');

g_omappings_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_OBJECT_MAPPINGS_ACC';
g_omappings_table_name            CONSTANT VARCHAR2(30) := 'JTF_OBJECT_MAPPINGS';
g_omappings_seq_name              CONSTANT VARCHAR2(30) := 'CSM_OBJECT_MAPPINGS_ACC_S';
g_omappings_pk1_name              CONSTANT VARCHAR2(30) := 'MAPPING_ID';
g_omappings_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_OBJECT_MAPPINGS');

PROCEDURE INSERT_CSM_NOTES_ACC (p_jtf_note_id jtf_notes_b.jtf_note_id%TYPE,
								p_user_id	fnd_user.user_id%TYPE)
IS

BEGIN

   CSM_ACC_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => g_notes_pubi_name
   ,P_ACC_TABLE_NAME         => g_notes_acc_table_name
   ,P_SEQ_NAME               => g_notes_seq_name
   ,P_PK1_NAME               => g_notes_pk1_name
   ,P_PK1_NUM_VALUE          => p_jtf_note_id
   ,P_USER_ID                => p_user_id
  );


  EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( sqlerrm|| ' for PK ' || to_char(p_jtf_note_id),
      'CSM_NOTES_EVENT_PKG.INSERT_CSM_NOTES_ACC',FND_LOG.LEVEL_EXCEPTION);
  RAISE;

END;-- end INSERT_CSM_NOTES_ACC;

PROCEDURE INSERT_CSM_OBJECT_MAPPINGS_ACC (p_access_id IN NUMBER,
                                          p_mapping_id jtf_object_mappings.mapping_id%TYPE
								         )
IS
 l_sysdate 	date;
BEGIN
 l_sysdate := SYSDATE;

	INSERT INTO csm_object_mappings_acc (access_id,
                                         mapping_id,
								         created_by,
								         creation_date,
								         last_updated_by,
								         last_update_date,
								         last_update_login
                 )
						VALUES (p_access_id,
                                p_mapping_id,
								fnd_global.user_id,
								l_sysdate,
								fnd_global.user_id,
								l_sysdate,
								fnd_global.login_id
        );

  EXCEPTION
     WHEN others THEN
	    RAISE;

END;-- end INSERT_CSM_OBJECT_MAPPINGS_ACC;

-- Bug 5532961
PROCEDURE NOTES_MAKE_DIRTY_I_FOREACHUSER(p_jtf_note_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2)
IS
--Variable Declarations
l_jtf_note_id 		 jtf_notes_b.jtf_note_id%TYPE;
l_user_found 		 boolean;
l_source_object_code jtf_notes_b.source_object_code%TYPE;
l_userlist 			 asg_download.user_list;
l_countlist              asg_download.user_list;
l_source_object_id   jtf_notes_b.source_object_id%TYPE;


--Cursor Declarations
CURSOR  c_csm_notes_csr (c_jtf_note_id jtf_notes_b.jtf_note_id%TYPE)
IS
SELECT	source_object_code,
		source_object_id
FROM 	jtf_notes_b jtn
WHERE 	jtn.jtf_note_id = c_jtf_note_id;

CURSOR  c_sr_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT	acc.user_id,acc.counter
FROM 	csm_incidents_all_acc acc
WHERE 	acc.incident_id = c_source_object_id;

CURSOR 	c_task_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT 	acc.user_id,acc.counter
FROM 	csm_tasks_acc acc
WHERE 	acc.task_id = c_source_object_id;

CURSOR 	c_ib_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT 	acc.user_id,acc.counter
FROM 	CSM_ITEM_INSTANCES_ACC acc
WHERE 	acc.INSTANCE_ID = c_source_object_id;

CURSOR 	c_cst_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT 	acc.user_id,acc.counter
FROM 	CSM_PARTIES_ACC acc
WHERE 	acc.PARTY_ID = c_source_object_id;

CURSOR 	c_contract_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT 	DISTINCT acc.user_id,acc.counter --distinct not removed as there is no primary key with contract service id
FROM 	      csm_contr_headers_acc acc
WHERE 	acc.contract_service_id = c_source_object_id;

CURSOR 	c_dbheader_notes(c_source_object_id jtf_notes_b.source_object_id%TYPE)
IS
SELECT 	acc.user_id,acc.counter
FROM 	      csm_debrief_headers_acc acc
WHERE 	acc.debrief_header_id = c_source_object_id;


BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_FOREACHUSER ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);

    l_user_found  := false;
    l_jtf_note_id := p_jtf_note_id;
    --bug 5104453
    OPEN  	c_csm_notes_csr(p_jtf_note_id);
    FETCH 	c_csm_notes_csr INTO l_source_object_code,l_source_object_id;
    CLOSE 	c_csm_notes_csr;

	IF    l_source_object_code='SR'		THEN
    	OPEN  	c_sr_notes(l_source_object_id);
    	FETCH 	c_sr_notes 		BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_sr_notes;

	ELSIF l_source_object_code='TASK' 	THEN
		OPEN  	c_task_notes(l_source_object_id);
    	FETCH 	c_task_notes 	BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_task_notes;

	ELSIF l_source_object_code='CP' 	THEN
		OPEN  	c_ib_notes(l_source_object_id);
    	FETCH 	c_ib_notes 		BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_ib_notes;

	ELSIF l_source_object_code='PARTY' 	THEN
		OPEN  	c_cst_notes(l_source_object_id);
    	FETCH 	c_cst_notes 	BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_cst_notes;

	ELSIF l_source_object_code='OKS_COV_NOTE' THEN
		OPEN  	c_contract_notes(l_source_object_id);
    	FETCH 	c_contract_notes BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_contract_notes;

	ELSIF l_source_object_code='SD' 	THEN
		OPEN  	c_dbheader_notes(l_source_object_id);
    	FETCH 	c_dbheader_notes BULK COLLECT INTO l_userlist,l_countlist;
    	CLOSE 	c_dbheader_notes;

	END IF;
	-- insert for all the affected users
	FOR i IN 1..l_userlist.COUNT
	LOOP
        l_user_found := true;
   		-- insert into csm_notes_acc table
	    insert_csm_notes_acc (l_jtf_note_id, l_userlist(i));
--Bug 5532961
          update csm_notes_acc set counter=l_countlist(i) where jtf_note_id=l_jtf_note_id and user_id=l_userlist(i);
	END LOOP;

	IF l_userlist.COUNT >0 THEN
		l_userlist.DELETE;
	END IF;
    --bug 5104453


	IF l_user_found THEN
    	p_error_msg := ' CMPLT JtfNoteId:' || to_char(l_jtf_note_id);
    ELSE
	 	p_error_msg := ' No User for JtfNoteId: ' || to_char(l_jtf_note_id) ;
    END IF;

   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_FOREACHUSER ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	     p_error_msg := ' FAILED NOTES_MAKE_DIRTY_I_FOREACHUSER:' || to_char(p_jtf_note_id);
         CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);
END NOTES_MAKE_DIRTY_I_FOREACHUSER;

PROCEDURE NOTES_MAKE_DIRTY_U_FOREACHUSER(p_jtf_note_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2)
IS
--variable declarations
l_jtf_note_id 	jtf_notes_b.jtf_note_id%TYPE;
l_user_found 	boolean;

--cursor declarations
CURSOR	 l_csm_notes_foreachuser_csr (p_jtf_note_id jtf_notes_b.jtf_note_id%TYPE) IS
SELECT 	 acc.user_id,
	   	 acc.access_id
FROM   	 csm_notes_acc acc
WHERE  	 acc.jtf_note_id = p_jtf_note_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_U_FOREACHUSER ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_U_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);

   l_user_found  := false;
   l_jtf_note_id := p_jtf_note_id;

   -- update for all the affected users
	for l_csm_notes_foreachuser_rec in l_csm_notes_foreachuser_csr(l_jtf_note_id) loop
   	  CSM_ACC_PKG.Update_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_notes_pubi_name
         ,P_ACC_TABLE_NAME         => g_notes_acc_table_name
         ,P_USER_ID                => l_csm_notes_foreachuser_rec.user_id
         ,p_ACCESS_ID              => l_csm_notes_foreachuser_rec.access_id
        );
        l_user_found := TRUE;
    end loop;

     if l_user_found then
    	p_error_msg := ' COMP Note_id:' || to_char(l_jtf_note_id);
	 else
	 	p_error_msg := ' No Users for JtfNoteId : ' || to_char(l_jtf_note_id);
	 end if;

   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_U_FOREACHUSER ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_U_FOREACHUSER',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	     p_error_msg := ' FAILED NOTES_MAKE_DIRTY_U_FOREACHUSER:' || to_char(p_jtf_note_id);
         CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_U_FOREACHUSER',FND_LOG.LEVEL_EXCEPTION);

END NOTES_MAKE_DIRTY_U_FOREACHUSER;

PROCEDURE NOTES_MAKE_DIRTY_I_GRP(p_sourceobjectcode IN VARCHAR2,
                                 p_sourceobjectid IN NUMBER,
                                 p_userid IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
CURSOR l_notes_by_task_csr (p_sourceobjectcode VARCHAR2,
							p_sourceobjectid NUMBER) IS
SELECT jtf_note_id
FROM jtf_notes_b
WHERE source_object_code = p_sourceobjectcode
AND   source_object_id = p_sourceobjectid;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP',FND_LOG.LEVEL_PROCEDURE);

   FOR l_notes_by_task_rec in l_notes_by_task_csr(p_sourceobjectcode,
												  p_sourceobjectid) LOOP

    	-- insert into csm_notes_acc table
    	insert_csm_notes_acc (l_notes_by_task_rec.jtf_note_id, p_userid);
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	     p_error_msg := ' FAILED NOTES_MAKE_DIRTY_I_GRP for ' || p_sourceobjectcode || ':' || to_char(p_sourceobjectid);
         CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_I_GRP',FND_LOG.LEVEL_EXCEPTION);

END NOTES_MAKE_DIRTY_I_GRP;

PROCEDURE NOTES_MAKE_DIRTY_D_GRP(p_sourceobjectcode IN VARCHAR2,
                                 p_sourceobjectid IN NUMBER,
                                 p_userid IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
CURSOR l_notes_by_task_csr (p_source_object_code VARCHAR2,
							p_source_object_id NUMBER,
                            p_user_id NUMBER) IS
SELECT acc.jtf_note_id, acc.user_id
FROM jtf_notes_b notes, csm_notes_acc acc
WHERE notes.source_object_code = p_source_object_code
AND   notes.source_object_id = p_source_object_id
AND notes.jtf_note_id = acc.jtf_note_id
AND acc.user_id = p_user_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   CSM_UTIL_PKG.LOG('Entering CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP',FND_LOG.LEVEL_PROCEDURE);

  	FOR l_notes_by_task_rec IN l_notes_by_task_csr(p_sourceobjectcode,
                                        			p_sourceobjectid,
                                                    p_userid) LOOP

          CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_notes_pubi_name
           ,P_ACC_TABLE_NAME         => g_notes_acc_table_name
           ,P_PK1_NAME               => g_notes_pk1_name
           ,P_PK1_NUM_VALUE          => l_notes_by_task_rec.jtf_note_id
           ,P_USER_ID                => l_notes_by_task_rec.user_id
          );

  	END LOOP;

   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP ',
                         'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	     p_error_msg := ' FAILED NOTES_MAKE_DIRTY_D_GRP for ' || p_sourceobjectcode || ':' || to_char(p_sourceobjectid);
         CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_NOTES_EVENT_PKG.NOTES_MAKE_DIRTY_D_GRP',FND_LOG.LEVEL_EXCEPTION);
END NOTES_MAKE_DIRTY_D_GRP;

PROCEDURE OBJECT_MAPPINGS_ACC_PROCESSOR
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_markdirty BOOLEAN;
l_omfs_palm_user_list asg_download.user_list;
l_null_user_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
l_null_access_list asg_download.access_list;

CURSOR l_mappings_csr
IS
SELECT CSM_OBJECT_MAPPINGS_ACC_S.NEXTVAL access_id, jom.mapping_id
FROM jtf_object_mappings jom
WHERE jom.source_object_code IN ('PARTY', 'TASK', 'SR', 'CP','OKS_COV_NOTE','SD')
AND NVL(end_date, SYSDATE) >= SYSDATE
AND NOT EXISTS
(SELECT 1
 FROM csm_object_mappings_acc acc
 WHERE acc.mapping_id = jom.mapping_id);

BEGIN
  --get mfs users
  l_omfs_palm_user_list := l_null_user_list;
  l_omfs_palm_user_list := csm_util_pkg.get_all_omfs_palm_user_list;

  -- insert into csm_object_mappings_acc
  FOR r_mappings_rec IN l_mappings_csr LOOP

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_omfs_palm_user_list.COUNT LOOP
         l_single_access_id_list(i) := r_mappings_rec.access_id;
     END LOOP;

     INSERT_CSM_OBJECT_MAPPINGS_ACC(r_mappings_rec.access_id, r_mappings_rec.mapping_id);

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
     l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser('CSF_M_OBJECT_MAPPINGS',
          l_single_access_id_list, l_omfs_palm_user_list,
          ASG_DOWNLOAD.INS, sysdate);
     END IF;
  END LOOP;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  OBJECT_MAPPINGS_ACC_PROCESSOR ' || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTES_EVENT_PKG.OBJECT_MAPPINGS_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END OBJECT_MAPPINGS_ACC_PROCESSOR;

END CSM_NOTES_EVENT_PKG;

/
