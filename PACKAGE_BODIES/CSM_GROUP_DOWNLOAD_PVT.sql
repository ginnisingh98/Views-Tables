--------------------------------------------------------
--  DDL for Package Body CSM_GROUP_DOWNLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_GROUP_DOWNLOAD_PVT" AS
/* $Header: csmegrpb.pls 120.4 2008/02/29 08:50:40 anaraman noship $ */

-- The same table is used as both base and access table.


g_grp_acc_table_name            CONSTANT VARCHAR2(30) := 'CSM_GROUPS';
g_grp_table_name                  CONSTANT VARCHAR2(30) := 'CSM_GROUPS';
g_grp_seq_name                    CONSTANT VARCHAR2(30) := 'CSM_GROUPS_S' ;
g_grp_pk1_name                    CONSTANT VARCHAR2(30) := 'GROUP_ID';
g_grp_item               		      CONSTANT VARCHAR2(30) := 'CSM_GROUPS';
g_grp_pubi_name 			      CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_GROUPS');

-- This procedure will insert current group record in csm_groups
-- during user-creation.
PROCEDURE INSERT_MY_GROUP (p_user_id NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2)
IS
--CURSOR declarations
CURSOR  c_group_ins(b_user_id NUMBER)
IS
SELECT 	GROUP_ID, OWNER_ID
FROM 	ASG_USER usr
WHERE 	usr.USER_ID = b_user_id
AND     usr.ENABLED = 'Y'
AND NOT EXISTS
	(
	SELECT 	1
	FROM 	CSM_GROUPS acc
	WHERE 	acc.USER_ID = usr.OWNER_ID
	AND     acc.GROUP_TYPE ='C'
	);

--variable declarations
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(2000);
l_message		VARCHAR2(3000);
l_group_id 	CSM_GROUPS.GROUP_ID%TYPE := NULL;
l_owner_id 	CSM_GROUPS.GROUP_OWNER_ID%TYPE := NULL;
BEGIN

    CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP Proc ',
        'CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP',FND_LOG.LEVEL_STATEMENT);
    OPEN  c_group_ins (p_user_id);
    FETCH c_group_ins INTO l_group_id,l_owner_id;
    CLOSE c_group_ins;

  IF l_group_id IS NOT NULL AND l_owner_id IS NOT NULL THEN
    CSM_ACC_PKG.Insert_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_grp_pubi_name
     	,P_ACC_TABLE_NAME         => g_grp_acc_table_name
     	,P_SEQ_NAME               => g_grp_seq_name
     	,P_PK1_NAME               => g_grp_pk1_name
     	,P_PK1_NUM_VALUE          => l_group_id
     	,P_USER_ID                => l_owner_id
    	);

        UPDATE CSM_GROUPS
        SET    GROUP_TYPE ='C',
                 GROUP_OWNER_ID=l_owner_id
        WHERE  GROUP_ID = l_group_id
        AND    USER_ID  = l_owner_id;

  END IF;

     x_return_status := 'SUCCESS';
     x_error_message := 'Group Data for Current Group successfully Inserted';

    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP Proc ',
       'CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP',FND_LOG.LEVEL_STATEMENT);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     x_return_status := 'ERROR';
     x_error_message := l_sqlerrmsg;
     l_message   := 'Exception in CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP Procedure :' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_message, 'CSM_GROUP_DOWNLOAD_PVT.INSERT_MY_GROUP',FND_LOG.LEVEL_EXCEPTION);
END INSERT_MY_GROUP;


-- The Group which was downloaded for the user has to be deleted from the
-- CSM_GROUPS table only if there are no Mobile Users from the Group.

PROCEDURE DELETE_MY_GROUP ( p_user_id NUMBER
                           , x_return_status OUT NOCOPY VARCHAR2
                           , x_error_message OUT NOCOPY VARCHAR2)
IS
--CURSOR declarations
CURSOR c_group_del(b_user_id NUMBER)
IS
SELECT 	acc.group_id
FROM 	CSM_GROUPS acc
WHERE 	acc.USER_ID = b_user_id
AND     acc.GROUP_TYPE = 'C';

--variable declarations
l_group_id 	    CSM_GROUPS.GROUP_ID%TYPE := NULL;
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(2000);
l_message		VARCHAR2(3000);
l_access_id	CSM_GROUPS.ACCESS_ID%TYPE;

BEGIN
    CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP Proc ',
       'CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP',FND_LOG.LEVEL_STATEMENT);
    OPEN c_group_del(p_user_id);
    FETCH c_group_del INTO l_group_id;
    CLOSE c_group_del;

    IF l_group_id IS NOT NULL THEN

   		CSM_ACC_PKG.Delete_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_grp_pubi_name
     	,P_ACC_TABLE_NAME         => g_grp_acc_table_name
     	,P_PK1_NAME               => g_grp_pk1_name
     	,P_PK1_NUM_VALUE          => l_group_id
     	,P_USER_ID                => p_user_id
    	);
    END IF;

     x_return_status := 'SUCCESS';
     x_error_message := 'Group Data successfully Deleted';
     CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP Proc ',
       'CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP',FND_LOG.LEVEL_STATEMENT);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     x_return_status := 'ERROR';
     x_error_message := 'l_sqlerrmsg';
     l_message   := 'Exception in CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP Procedure : for accessid '
      || l_access_id ||': with error ' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_message, 'CSM_GROUP_DOWNLOAD_PVT.DELETE_MY_GROUP',FND_LOG.LEVEL_EXCEPTION);
END DELETE_MY_GROUP;

PROCEDURE INSERT_GROUP_ACC (p_user_id NUMBER
                          , p_group_id NUMBER
                          , p_owner_id NUMBER
                          , p_group_type VARCHAR2
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2)
IS
--CURSOR declarations
CURSOR  c_rel_group_ins(b_group_id IN NUMBER)
IS
SELECT 	1
FROM 	JTF_RS_GROUPS_B jrgb
WHERE 	jrgb.GROUP_ID = b_group_id
AND     NVL(jrgb.END_DATE_ACTIVE,SYSDATE) >= TRUNC(SYSDATE);

--variable declarations
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(2000);
l_message		VARCHAR2(3000);
l_chk_rel_grp           NUMBER;

BEGIN

    CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC Proc ',
      'CSM_GROUP_DOWNLOAD.INSERT_GROUP_ACC',FND_LOG.LEVEL_STATEMENT);

 OPEN c_rel_group_ins(p_group_id);
 FETCH c_rel_group_ins INTO l_chk_rel_grp;

 IF (c_rel_group_ins%NOTFOUND) THEN
   x_error_message := 'the related group id -'||p_group_id|| ' does not exists in JTF_RS_GROUPS_B base table';
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 CLOSE c_rel_group_ins;

  IF p_user_id IS NOT NULL AND p_group_id IS NOT NULL	THEN
	CSM_ACC_PKG.Insert_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_grp_pubi_name
     	,P_ACC_TABLE_NAME         => g_grp_acc_table_name
     	,P_SEQ_NAME               => g_grp_seq_name
     	,P_PK1_NAME               => g_grp_pk1_name
     	,P_PK1_NUM_VALUE          => p_group_id
     	,P_USER_ID                => p_user_id
    	);

        UPDATE CSM_GROUPS
        SET    GROUP_TYPE = p_group_type,
               GROUP_OWNER_ID = p_owner_id
        WHERE  GROUP_ID = p_group_id
        AND    USER_ID  = p_user_id;

  END IF;

  IF (c_rel_group_ins%ISOPEN) THEN

      CLOSE c_rel_group_ins;

  END IF;

     x_return_status := 'SUCCESS';
     x_error_message := 'Group Data successfully Inserted';

    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC Proc ',
     'CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC',FND_LOG.LEVEL_STATEMENT);

 EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := 'ERROR';
     CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC',FND_LOG.LEVEL_EXCEPTION);
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     x_return_status := 'ERROR';
     x_error_message := l_sqlerrmsg;
     l_message   := 'Exception in CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC Procedure :' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_message, 'CSM_GROUP_DOWNLOAD_PVT.INSERT_GROUP_ACC',FND_LOG.LEVEL_EXCEPTION);
END INSERT_GROUP_ACC;


--The Group which was downloaded for the user has to be deleted from the
--CSM_GROUPS table only if there are no Mobile Users from the Group.

PROCEDURE DELETE_GROUP_ACC ( p_user_id NUMBER
                          , p_group_id NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2)
IS

--variable declarations
l_group_id 	CSM_GROUPS.GROUP_ID%TYPE;
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(2000);
l_message		VARCHAR2(3000);
l_access_id	CSM_GROUPS.ACCESS_ID%TYPE;

BEGIN
    CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC Proc ',
      'CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC',FND_LOG.LEVEL_STATEMENT);

    IF p_user_id IS NOT NULL AND p_group_id IS NOT NULL THEN

   		CSM_ACC_PKG.Delete_Acc
    	(P_PUBLICATION_ITEM_NAMES => g_grp_pubi_name
     	,P_ACC_TABLE_NAME         => g_grp_acc_table_name
     	,P_PK1_NAME               => g_grp_pk1_name
     	,P_PK1_NUM_VALUE          => p_group_id
     	,P_USER_ID                => p_user_id
    	);
    END IF;

     x_return_status := 'SUCCESS';
     x_error_message := 'Group Data successfully Deleted';
    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC Proc ',
      'CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC',FND_LOG.LEVEL_STATEMENT);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     x_return_status := 'ERROR';
     x_error_message := 'l_sqlerrmsg';
     l_message   := 'Exception in CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC Procedure : for accessid '
       || l_access_id ||': with error ' || l_sqlerrno || ':' || l_sqlerrmsg;
     CSM_UTIL_PKG.LOG(l_message, 'CSM_GROUP_DOWNLOAD_PVT.DELETE_GROUP_ACC',
       FND_LOG.LEVEL_EXCEPTION);
END DELETE_GROUP_ACC;

END CSM_GROUP_DOWNLOAD_PVT;

/
