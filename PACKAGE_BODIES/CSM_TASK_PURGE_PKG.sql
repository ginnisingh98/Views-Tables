--------------------------------------------------------
--  DDL for Package Body CSM_TASK_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TASK_PURGE_PKG" as
/* $Header: csmtkprb.pls 120.1 2005/08/26 01:46:51 skotikal noship $ */
G_PKG_NAME     CONSTANT VARCHAR2(30):= 'CSM_TASK_PURGE_PKG';

PROCEDURE VALIDATE_MFS_TASKS(
      P_API_VERSION                IN        NUMBER,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN        NUMBER,
      P_OBJECT_TYPE                IN  VARCHAR2,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                  IN OUT NOCOPY VARCHAR2)
  IS
l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_MFS_TASKS';
l_api_version_number      CONSTANT NUMBER   := 1.0;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS ',
      'CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',FND_LOG.LEVEL_PROCEDURE);

  SAVEPOINT VALIDATE_MFS_TASKS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list
  FND_MSG_PUB.initialize;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*VALIDATION logic
   -----------------
    1) Check if the TASK ids associated to the processing set id
       (i/p parameter) has incident links to Mobile objects. If so then
       Mark the TASK as Not Purgeable else Make it Purgeable. */

  IF (nvl(P_OBJECT_TYPE,  'TASK') = 'TASK') THEN
 	UPDATE JTF_OBJECT_PURGE_PARAM_TMP
	SET	   purge_status = 'E',
     	   purge_error_message = 'CSM:CSM_TASK_PURGE_FAILED'
	WHERE  processing_set_id = P_PROCESSING_SET_ID AND
           object_id IN
        		   (
             	   SELECT	 DISTINCT acc.TASK_ID
				   FROM		 CSM_TASKS_ACC acc,
				   			 JTF_OBJECT_PURGE_PARAM_TMP tmp
			       WHERE	 tmp.object_id = acc.TASK_ID AND
                             nvl(tmp.purge_status, 'S') <> 'E' AND
                             tmp.processing_set_id = P_PROCESSING_SET_ID
        	      ) AND
            nvl(purge_status, 'S') <> 'E';

  END IF ;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS ',
          'CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO VALIDATE_MFS_TASKS;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  CSM_UTIL_PKG.LOG('Error in CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',
          'CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',FND_LOG.LEVEL_EXCEPTION);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO VALIDATE_MFS_TASKS;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  CSM_UTIL_PKG.LOG('Error in CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',
          'CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',FND_LOG.LEVEL_EXCEPTION);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      ROLLBACK TO VALIDATE_MFS_TASKS;
      CSM_UTIL_PKG.LOG('Error in CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',
          'CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS',FND_LOG.LEVEL_EXCEPTION);
END VALIDATE_MFS_TASKS;


-- Procedure to delete MFS Tasks. No-op right now

  PROCEDURE DELETE_MFS_TASKS(
      P_API_VERSION                IN	   NUMBER  ,
      P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN      NUMBER  ,
      P_OBJECT_TYPE                IN  	   VARCHAR2 ,
      X_RETURN_STATUS              IN      OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	   OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN	   OUT NOCOPY VARCHAR2)
   IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_MFS_TASKS';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_sqlerrno                NUMBER;
l_sqlerrmsg               VARCHAR2(256);
BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS',
     'CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS',FND_LOG.LEVEL_PROCEDURE);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,p_api_version,
                                           l_api_name,G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   CSM_UTIL_PKG.LOG('Leaving CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS',
 	'CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS',FND_LOG.LEVEL_PROCEDURE);
 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,256);
     csm_util_pkg.log('CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS ERROR : ' ||
                  l_sqlerrno || ':' || l_sqlerrmsg, FND_LOG.LEVEL_EXCEPTION);
END DELETE_MFS_TASKS;

END CSM_TASK_PURGE_PKG;

/
