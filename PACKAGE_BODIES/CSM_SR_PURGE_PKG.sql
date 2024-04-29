--------------------------------------------------------
--  DDL for Package Body CSM_SR_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SR_PURGE_PKG" as
/* $Header: csmsrprb.pls 120.0 2005/08/10 12:10:34 rsripada noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30):= 'CSM_SR_PURGE_PKG';

PROCEDURE Validate_MobileFSObjects(
      P_API_VERSION                IN        NUMBER,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN        NUMBER,
      P_OBJECT_TYPE                IN  VARCHAR2,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                  IN OUT NOCOPY VARCHAR2)
  IS
l_api_name                CONSTANT VARCHAR2(30) := 'Validate_MobileFSObjects';
l_api_version_number      CONSTANT NUMBER   := 1.0;
BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_SR_PURGE_PKG.Validate_MobileFSObjects ',
      'CSM_SR_PURGE_PKG.Validate_MobileFSObjects',FND_LOG.LEVEL_PROCEDURE);

  SAVEPOINT Validate_MFServiceObjects;
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
    1) Check if the incident ids associated to the processing set id
       (i/p parameter) has incident links to Mobile objects. If so then
       Mark the SR as Not Purgeable else Make it Purgeable. */

  IF (nvl(P_OBJECT_TYPE,  'SR') = 'SR') THEN
 	UPDATE JTF_OBJECT_PURGE_PARAM_TMP
	SET	   purge_status = 'E',
     	   purge_error_message = 'CSM:CSM_SR_PURGE_FAILED'
	WHERE  processing_set_id = P_PROCESSING_SET_ID AND
           object_id IN
        		   (
             	   SELECT	 DISTINCT acc.INCIDENT_ID
				   FROM		 csm_incidents_all_acc acc,
				   			 JTF_OBJECT_PURGE_PARAM_TMP tmp
			       WHERE	 tmp.object_id = acc.INCIDENT_ID AND
                             nvl(tmp.purge_status, 'S') <> 'E' AND
                             tmp.processing_set_id = P_PROCESSING_SET_ID
        	      ) AND
            nvl(purge_status, 'S') <> 'E';

  END IF ;

  CSM_UTIL_PKG.LOG('Leaving CSM_SR_PURGE_PKG.Validate_MobileFSObjects ',
          'CSM_SR_PURGE_PKG.Validate_MobileFSObjects',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO Validate_MFServiceObjects;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  CSM_UTIL_PKG.LOG('Error in CSM_SR_PURGE_PKG.Validate_MobileFSObjects',
          'CSM_SR_PURGE_PKG.Validate_MobileFSObjects',FND_LOG.LEVEL_EXCEPTION);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO Validate_MFServiceObjects;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  CSM_UTIL_PKG.LOG('Error in CSM_SR_PURGE_PKG.Validate_MobileFSObjects',
          'CSM_SR_PURGE_PKG.Validate_MobileFSObjects',FND_LOG.LEVEL_EXCEPTION);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      ROLLBACK TO Validate_MFServiceObjects;
      CSM_UTIL_PKG.LOG('Error in CSM_SR_PURGE_PKG.Validate_MobileFSObjects',
          'CSM_SR_PURGE_PKG.Validate_MobileFSObjects',FND_LOG.LEVEL_EXCEPTION);
END Validate_MobileFSObjects;


-- Procedure to delete MFS SRs. No-op right now as the SRs are purged
-- from csm_incidents_all_acc during JTM: Purge Program.
  PROCEDURE Delete_MobileFSObjects(
      P_API_VERSION                IN	   NUMBER  ,
      P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN      NUMBER  ,
      P_OBJECT_TYPE                IN  	   VARCHAR2 ,
      X_RETURN_STATUS              IN      OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	   OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN	   OUT NOCOPY VARCHAR2)
   IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_MobileFSObjects';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_sqlerrno                NUMBER;
l_sqlerrmsg               VARCHAR2(256);
BEGIN
   CSM_UTIL_PKG.LOG('Entering CSM_SR_PURGE_PKG.Delete_MobileFSObjects',
     'CSM_SR_PURGE_PKG.Delete_MobileFSObjects',FND_LOG.LEVEL_PROCEDURE);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,p_api_version,
                                           l_api_name,G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   CSM_UTIL_PKG.LOG('Leaving CSM_SR_PURGE_PKG.Delete_MobileFSObjects',
 	'CSM_SR_PURGE_PKG.Delete_MobileFSObjects',FND_LOG.LEVEL_PROCEDURE);
 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,256);
     csm_util_pkg.log('CSM_SR_PURGE_PKG.Delete_MobileFSObjects ERROR : ' ||
                  l_sqlerrno || ':' || l_sqlerrmsg, FND_LOG.LEVEL_EXCEPTION);
END Delete_MobileFSObjects;

END CSM_SR_PURGE_PKG;

/
