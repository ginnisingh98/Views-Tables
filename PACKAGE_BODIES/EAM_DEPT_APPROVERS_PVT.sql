--------------------------------------------------------
--  DDL for Package Body EAM_DEPT_APPROVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DEPT_APPROVERS_PVT" as
/* $Header: EAMVDAPB.pls 115.8 2003/08/19 06:51:40 yjhabak ship $ */
-- Start of comments
-- API name    : EAM_DEPT_APPROVERS_PVT
-- Type     : Private
-- Function :
-- Pre-reqs : None.
-- Parameters  :
-- IN        P_API_VERSION                 IN NUMBER       REQUIRED
--           P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
--             DEFAULT = FND_API.G_FALSE
--           P_COMMIT                      IN VARCHAR2     OPTIONAL
--             DEFAULT = FND_API.G_FALSE
--           P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
--             DEFAULT = FND_API.G_VALID_LEVEL_FULL
--	     P_DEPT_ID			   IN  NUMBER 	   REQUIRED
-- 	     P_LAST_UPDATE_DATE            IN  DATE	   REQUIRED
-- 	     P_LAST_UPDATED_BY             IN  NUMBER	   REQUIRED
-- 	     P_CREATION_DATE               IN  DATE	   REQUIRED
-- 	     P_CREATED_BY                  IN  NUMBER      REQUIRED
-- 	     P_LAST_UPDATE_LOGIN           IN  NUMBER	   OPTIONAL
-- 	     P_RESPONSIBILITY_ID           IN  NUMBER	   REQUIRED
-- 	     P_RESPONSIBILITY_APPLICATN_ID IN  NUMBER	   REQUIRED
-- OUT       X_RETURN_STATUS               OUT VARCHAR2(1)
--           X_MSG_COUNT                   OUT NUMBER
--           X_MSG_DATA                    OUT VARCHAR2(2000)
--
-- Version  Current version 115.0
--
-- Notes    : Note text
--
-- End of comments
  g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_DEPT_APPROVERS_PVT';

PROCEDURE INSERT_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  P_PRIMARY_APPROVER                NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2)
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

    CURSOR C IS SELECT rowid FROM BOM_EAM_DEPT_APPROVERS
                 WHERE DEPT_ID = P_DEPT_ID AND RESPONSIBILITY_ID=P_RESPONSIBILITY_ID;

   BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT apiname_apitype;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body
       INSERT INTO BOM_EAM_DEPT_APPROVERS(
	DEPT_ID,
	ORGANIZATION_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	RESPONSIBILITY_ID,
	RESPONSIBILITY_APPLICATION_ID,
        PRIMARY_APPROVER_ID
       ) SELECT
       		P_DEPT_ID,
		P_ORGANIZATION_ID,
  		P_LAST_UPDATE_DATE,
  		P_LAST_UPDATED_BY,
  		P_CREATION_DATE,
  		P_CREATED_BY,
  		P_LAST_UPDATE_LOGIN,
  		P_RESPONSIBILITY_ID,
  		P_RESPONSIBILITY_APPLICATN_ID,
 	        P_PRIMARY_APPROVER
       	FROM 	DUAL
	WHERE P_DEPT_ID = P_DEPT_ID
		AND
		NOT EXISTS (
		SELECT null
		FROM	BOM_EAM_DEPT_APPROVERS	BDA
		WHERE	BDA.DEPT_ID = P_DEPT_ID And
			BDA.RESPONSIBILITY_ID = P_RESPONSIBILITY_ID
	);

	OPEN C;
	FETCH C INTO P_ROWID;
	if (C%NOTFOUND) then
		CLOSE C;
		Raise NO_DATA_FOUND;
	end if;
	CLOSE C;

    -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END Insert_Row;


PROCEDURE LOCK_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2)
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

    CURSOR C IS
	SELECT * FROM BOM_EAM_DEPT_APPROVERS
	WHERE rowid = P_ROWID
	FOR UPDATE Of RESPONSIBILITY_ID NOWAIT;
    Recinfo C%ROWTYPE;

    BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT apiname_apitype;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
       (Recinfo.DEPT_ID =  P_DEPT_ID)
       AND (Recinfo.ORGANIZATION_ID =  P_ORGANIZATION_ID)
       AND (Recinfo.RESPONSIBILITY_ID =  P_RESPONSIBILITY_ID)
       AND (Recinfo.RESPONSIBILITY_APPLICATION_ID =  P_RESPONSIBILITY_APPLICATN_ID)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Lock_Row;


  PROCEDURE UPDATE_ROW
  (
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  P_PRIMARY_APPROVER                NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2)
  IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

  BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT apiname_apitype;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body

    UPDATE BOM_EAM_DEPT_APPROVERS
    SET
     DEPT_ID               	     =     P_DEPT_ID,
     ORGANIZATION_ID                 =     P_ORGANIZATION_ID,
     LAST_UPDATE_DATE                =     P_LAST_UPDATE_DATE,
     LAST_UPDATED_BY                 =     P_LAST_UPDATED_BY,
     CREATION_DATE		     =     P_CREATION_DATE,
     CREATED_BY			     =     P_CREATED_BY,
     LAST_UPDATE_LOGIN               =     P_LAST_UPDATE_LOGIN,
     RESPONSIBILITY_ID               =     P_RESPONSIBILITY_ID,
     RESPONSIBILITY_APPLICATION_ID   =     P_RESPONSIBILITY_APPLICATN_ID,
     PRIMARY_APPROVER_ID             =     P_PRIMARY_APPROVER
    WHERE ROWID = P_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO apiname_apitype;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Update_Row;



PROCEDURE DELETE_ROW (
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID                 NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER)
is
begin

  delete from BOM_EAM_DEPT_APPROVERS
  where DEPT_ID = P_DEPT_ID
  and ORGANIZATION_ID = P_ORGANIZATION_ID
  and RESPONSIBILITY_ID = P_RESPONSIBILITY_ID
  and RESPONSIBILITY_APPLICATION_ID = P_RESPONSIBILITY_APPLICATN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

END EAM_DEPT_APPROVERS_PVT;


/
