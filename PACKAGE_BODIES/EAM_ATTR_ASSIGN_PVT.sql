--------------------------------------------------------
--  DDL for Package Body EAM_ATTR_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ATTR_ASSIGN_PVT" as
/* $Header: EAMVATAB.pls 120.1 2005/07/28 08:12:53 yjhabak noship $ */
 -- Start of comments
 -- API name    : EAM_ATTR_ASSIGN_PVT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_API_VERSION                 IN NUMBER       REQUIRED
 --          P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_COMMIT                      IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
 --             DEFAULT = FND_API.G_VALID_LEVEL_FULL
 --          P_ROWID                       IN OUT VARCHAR2 REQUIRED
 --          P_ATTRIBUTE_ASSOCIATION_ID    IN  NUMBER      REQUIRED
 --          P_APPLICATION_ID              IN  NUMBER      REQUIRED
 --          P_FLEXFIELD_NAME  IN  VARCHAR2(40)  REQUIRED
 --          P_FLEX_CONTEXT_CODE IN VARCHAR2(30) REQUIRED
 --          P_ORGANIZATION_ID             IN  NUMBER      REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER      REQUIRED
 --          P_ENABLED_FLAG                IN  VARCHAR2(1) REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_attr_assign_pvt';


PROCEDURE INSERT_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         IN OUT NOCOPY VARCHAR2,
  P_ATTRIBUTE_ASSOCIATION_ID      IN OUT NOCOPY NUMBER,
  P_APPLICATION_ID                NUMBER,
  P_FLEXFIELD_NAME                VARCHAR2,
  P_FLEX_CONTEXT_CODE             VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_ENABLED_FLAG                  VARCHAR2,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_CREATION_ORGANIZATION_ID	  NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

    CURSOR C IS SELECT rowid FROM MTL_EAM_ASSET_ATTR_GROUPS
                 WHERE ASSOCIATION_ID = P_ATTRIBUTE_ASSOCIATION_ID;
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

       INSERT INTO MTL_EAM_ASSET_ATTR_GROUPS(
       ASSOCIATION_ID,
       APPLICATION_ID,
       DESCRIPTIVE_FLEXFIELD_NAME,
       DESCRIPTIVE_FLEX_CONTEXT_CODE,
       ORGANIZATION_ID,
       INVENTORY_ITEM_ID,
       ENABLED_FLAG,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       CREATION_ORGANIZATION_ID
       ) values (
--       P_ATTRIBUTE_ASSOCIATION_ID,
       mtl_eam_asset_attr_groups_s.nextval,
       P_APPLICATION_ID,
       P_FLEXFIELD_NAME,
       P_FLEX_CONTEXT_CODE,
       P_ORGANIZATION_ID,
       P_INVENTORY_ITEM_ID,
       P_ENABLED_FLAG,
       P_LAST_UPDATE_DATE,
       P_LAST_UPDATED_BY,
       P_CREATION_DATE,
       P_CREATED_BY,
       P_LAST_UPDATE_LOGIN,
       P_CREATION_ORGANIZATION_ID) returning association_id, rowid into P_ATTRIBUTE_ASSOCIATION_ID, P_ROWID;

    OPEN C;
    FETCH C INTO P_Rowid;
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
  P_ROWID                           VARCHAR2,
  P_ATTRIBUTE_ASSOCIATION_ID      IN OUT NOCOPY NUMBER,
  P_APPLICATION_ID                NUMBER,
  P_FLEXFIELD_NAME    VARCHAR2,
  P_FLEX_CONTEXT_CODE VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_ENABLED_FLAG                  VARCHAR2,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

    CURSOR C IS
        SELECT *
        FROM   MTL_EAM_ASSET_ATTR_GROUPS
        WHERE  rowid = P_Rowid
        FOR UPDATE of ASSOCIATION_ID NOWAIT;
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
       (Recinfo.ASSOCIATION_ID =  P_ATTRIBUTE_ASSOCIATION_ID)
       AND (Recinfo.APPLICATION_ID =  P_APPLICATION_ID)
       AND (Recinfo.DESCRIPTIVE_FLEXFIELD_NAME =  P_FLEXFIELD_NAME)
       AND (Recinfo.DESCRIPTIVE_FLEX_CONTEXT_CODE =  P_FLEX_CONTEXT_CODE)
       AND (Recinfo.INVENTORY_ITEM_ID =  P_INVENTORY_ITEM_ID)
       AND (Recinfo.ENABLED_FLAG =   P_ENABLED_FLAG)
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

PROCEDURE UPDATE_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         VARCHAR2,
  P_ENABLED_FLAG                  VARCHAR2,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
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

    UPDATE MTL_EAM_ASSET_ATTR_GROUPS
    SET
     ENABLED_FLAG                    =     P_ENABLED_FLAG,
     LAST_UPDATE_DATE                =     P_LAST_UPDATE_DATE,
     LAST_UPDATED_BY                 =     P_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN               =     P_LAST_UPDATE_LOGIN
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

END EAM_ATTR_ASSIGN_PVT;

/
