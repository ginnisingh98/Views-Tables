--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_ACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_ACTIVITIES_PVT" as
/* $Header: EAMVASOB.pls 120.1 2005/09/19 06:18:57 yjhabak noship $ */
 -- Start of comments
 -- API name    : EAM_ASSET_ACTIVITIES_PVT
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
 --          P_ACTIVITY_ASSOCIATION_ID     IN OUT NUMBER   REQUIRED
 --          P_ORGANIZATION_ID             IN  NUMBER      REQUIRED
 --          P_ASSET_ACTIVITY_ID           IN  NUMBER      REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER      REQUIRED
 --          P_SERIAL_NUMBER               IN  VARCHAR2    OPTIONAL
 --          P_START_DATE_ACTIVE           IN  DATE        OPTIONAL
 --          P_END_DATE_ACTIVE             IN  DATE        OPTIONAL
 --          P_PRIORITY_CODE               IN  VARCHAR2    OPTIONAL
 --          P_ACTIVITY_CAUSE_CODE         IN  VARCHAR2    OPTIONAL
 --          P_ACTIVITY_TYPE_CODE          IN  VARCHAR2    OPTIONAL
 --          P_OWNING_DEPARTMENT_ID        IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_ATTRIBUTE_CATEGORY          IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE1                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE2                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE3                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE4                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE5                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE6                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE7                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE8                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE9                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE10                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE11                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE12                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE13                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE14                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE15                 IN  VARCHAR2    OPTIONAL
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

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_asset_activities_pvt';

FUNCTION to_fnd_std_num(p_value NUMBER)
RETURN NUMBER IS
BEGIN
   IF (p_value IS NULL) THEN
     RETURN fnd_api.g_miss_num;
   ELSE
     RETURN p_value;
   END IF;
END to_fnd_std_num;

FUNCTION to_fnd_std_char(p_value VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   IF (p_value IS NULL) THEN
     RETURN fnd_api.g_miss_char;
   ELSE
     RETURN p_value;
   END IF;
END to_fnd_std_char;

PROCEDURE INSERT_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         IN OUT NOCOPY VARCHAR2,
  P_ACTIVITY_ASSOCIATION_ID       IN OUT NOCOPY NUMBER,
  P_ORGANIZATION_ID               NUMBER,
  P_ASSET_ACTIVITY_ID             NUMBER,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_END_DATE_ACTIVE               DATE,
  P_PRIORITY_CODE                 VARCHAR2,
  P_ACTIVITY_CAUSE_CODE           VARCHAR2,
  P_ACTIVITY_TYPE_CODE            VARCHAR2,
  P_ACTIVITY_SOURCE_CODE          VARCHAR2,
  P_CLASS_CODE                    VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
  P_TAGGING_REQUIRED_FLAG         VARCHAR2,
  P_SHUTDOWN_TYPE_CODE            VARCHAR2,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER,
  P_PROGRAM_APPLICATION_ID        NUMBER,
  P_PROGRAM_ID                    NUMBER,
  P_PROGRAM_UPDATE_DATE           DATE,
  P_TMPL_FLAG			VARCHAR2,
  P_MAINTENANCE_OBJECT_ID	NUMBER,
  P_MAINTENANCE_OBJECT_TYPE	NUMBER,
  P_CREATION_ORGANIZATION_ID	NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    l_object_type             NUMBER;

    CURSOR C IS SELECT rowid FROM MTL_EAM_ASSET_ACTIVITIES
                 WHERE ACTIVITY_ASSOCIATION_ID = P_ACTIVITY_ASSOCIATION_ID;

   BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT insert_row;

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

       INSERT INTO MTL_EAM_ASSET_ACTIVITIES(
       ACTIVITY_ASSOCIATION_ID,
       ASSET_ACTIVITY_ID,
       INVENTORY_ITEM_ID,
       SERIAL_NUMBER,
       START_DATE_ACTIVE,
       END_DATE_ACTIVE,
       PRIORITY_CODE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
	TMPL_FLAG,
	MAINTENANCE_OBJECT_ID,
	MAINTENANCE_OBJECT_TYPE
       ) VALUES (
       mtl_eam_asset_activities_s.nextval,
       P_ASSET_ACTIVITY_ID,
       P_INVENTORY_ITEM_ID,
       P_SERIAL_NUMBER,
       P_START_DATE_ACTIVE,
       P_END_DATE_ACTIVE,
       P_PRIORITY_CODE,
       P_LAST_UPDATE_DATE,
       P_LAST_UPDATED_BY,
       P_CREATION_DATE,
       P_CREATED_BY,
       P_LAST_UPDATE_LOGIN,
       P_ATTRIBUTE_CATEGORY,
       P_ATTRIBUTE1,
       P_ATTRIBUTE2,
       P_ATTRIBUTE3,
       P_ATTRIBUTE4,
       P_ATTRIBUTE5,
       P_ATTRIBUTE6,
       P_ATTRIBUTE7,
       P_ATTRIBUTE8,
       P_ATTRIBUTE9,
       P_ATTRIBUTE10,
       P_ATTRIBUTE11,
       P_ATTRIBUTE12,
       P_ATTRIBUTE13,
       P_ATTRIBUTE14,
       P_ATTRIBUTE15,
       P_REQUEST_ID,
       P_PROGRAM_APPLICATION_ID,
       P_PROGRAM_ID,
       P_PROGRAM_UPDATE_DATE,
       P_TMPL_FLAG,
       P_MAINTENANCE_OBJECT_ID,
       P_MAINTENANCE_OBJECT_TYPE
       ) returning activity_association_id, rowid into P_ACTIVITY_ASSOCIATION_ID, P_ROWID;

       IF p_maintenance_object_type = 2 THEN
          l_object_type := 40;
       ELSE
          l_object_type := 60;
       END IF;

       eam_org_maint_defaults_pvt.insert_row
	(
	      p_api_version           => 1.0
	     ,p_object_type           => l_object_type
	     ,p_object_id             => p_activity_association_id
	     ,p_organization_id       => p_organization_Id
	     ,p_owning_department_id  => p_owning_department_id
	     ,p_accounting_class_code => p_class_code
	     ,p_activity_cause_code   => p_activity_cause_code
	     ,p_activity_type_code    => p_activity_type_code
	     ,p_activity_source_code  => p_activity_source_code
	     ,p_shutdown_type_code    => p_shutdown_type_code
	     ,p_tagging_required_flag => p_tagging_required_flag
	     ,x_return_status         => x_return_status
	     ,x_msg_count             => x_msg_count
	     ,x_msg_data              => x_msg_data
	);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
	  RAISE fnd_api.g_exc_error;
       END IF;


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
         ROLLBACK TO insert_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO insert_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO insert_row;
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
  P_ACTIVITY_ASSOCIATION_ID         NUMBER,
  P_ORGANIZATION_ID                 NUMBER,
  P_ASSET_ACTIVITY_ID               NUMBER,
  P_INVENTORY_ITEM_ID               NUMBER,
  P_SERIAL_NUMBER                   VARCHAR2,
  P_START_DATE_ACTIVE               DATE,
  P_END_DATE_ACTIVE                 DATE,
  P_PRIORITY_CODE                   VARCHAR2,
  P_ACTIVITY_CAUSE_CODE             VARCHAR2,
  P_ACTIVITY_TYPE_CODE              VARCHAR2,
  P_ACTIVITY_SOURCE_CODE          VARCHAR2,
  P_CLASS_CODE                      VARCHAR2,
  P_OWNING_DEPARTMENT_ID            NUMBER,
  P_TAGGING_REQUIRED_FLAG           VARCHAR2,
  P_SHUTDOWN_TYPE_CODE              VARCHAR2,
  P_ATTRIBUTE_CATEGORY              VARCHAR2,
  P_ATTRIBUTE1                      VARCHAR2,
  P_ATTRIBUTE2                      VARCHAR2,
  P_ATTRIBUTE3                      VARCHAR2,
  P_ATTRIBUTE4                      VARCHAR2,
  P_ATTRIBUTE5                      VARCHAR2,
  P_ATTRIBUTE6                      VARCHAR2,
  P_ATTRIBUTE7                      VARCHAR2,
  P_ATTRIBUTE8                      VARCHAR2,
  P_ATTRIBUTE9                      VARCHAR2,
  P_ATTRIBUTE10                     VARCHAR2,
  P_ATTRIBUTE11                     VARCHAR2,
  P_ATTRIBUTE12                     VARCHAR2,
  P_ATTRIBUTE13                     VARCHAR2,
  P_ATTRIBUTE14                       VARCHAR2,
  P_ATTRIBUTE15                       VARCHAR2,
  P_REQUEST_ID                        NUMBER,
  P_PROGRAM_APPLICATION_ID            NUMBER,
  P_PROGRAM_ID                        NUMBER,
  P_PROGRAM_UPDATE_DATE               DATE,
  P_MAINTENANCE_OBJECT_ID	NUMBER,
  P_MAINTENANCE_OBJECT_TYPE	NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

    CURSOR C IS
        SELECT *
        FROM   MTL_EAM_ASSET_ACTIVITIES
        WHERE  rowid = P_Rowid
        FOR UPDATE of ASSET_ACTIVITY_ID NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT lock_row;

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
       (Recinfo.ACTIVITY_ASSOCIATION_ID =  P_ACTIVITY_ASSOCIATION_ID)
       AND (Recinfo.ASSET_ACTIVITY_ID =  P_ASSET_ACTIVITY_ID)
       AND (   (Recinfo.START_DATE_ACTIVE =  P_START_DATE_ACTIVE)
            OR (    (Recinfo.START_DATE_ACTIVE IS NULL)
                AND (P_START_DATE_ACTIVE IS NULL)))
       AND (   (Recinfo.END_DATE_ACTIVE =  P_END_DATE_ACTIVE)
            OR (    (Recinfo.END_DATE_ACTIVE IS NULL)
                AND (P_END_DATE_ACTIVE IS NULL)))
       AND (   (Recinfo.PRIORITY_CODE =  P_PRIORITY_CODE)
            OR (    (Recinfo.PRIORITY_CODE IS NULL)
                AND (P_PRIORITY_CODE IS NULL)))
       AND (   (Recinfo.attribute_category =  P_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (P_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 =  P_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (P_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 =  P_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (P_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 =  P_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (P_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 =  P_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (P_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 =  P_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (P_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 =  P_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (P_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 =  P_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (P_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 =  P_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (P_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 =  P_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (P_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 =  P_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (P_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 =  P_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (P_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 =  P_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (P_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 =  P_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (P_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 =  P_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (P_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 =  P_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (P_Attribute15 IS NULL)))
       AND (   (Recinfo.REQUEST_ID = P_REQUEST_ID)
            OR (    (Recinfo.REQUEST_ID IS NULL)
                AND (P_REQUEST_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID)
            OR (    (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
                AND (P_PROGRAM_APPLICATION_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_ID = P_PROGRAM_ID)
            OR (    (Recinfo.PROGRAM_ID IS NULL)
                AND (P_PROGRAM_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_UPDATE_DATE = P_PROGRAM_UPDATE_DATE)
            OR (    (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
                AND (P_PROGRAM_UPDATE_DATE IS NULL)))
       AND (   (Recinfo.MAINTENANCE_OBJECT_ID = P_MAINTENANCE_OBJECT_ID)
            OR (    (Recinfo.MAINTENANCE_OBJECT_ID IS NULL)
                AND (P_MAINTENANCE_OBJECT_ID IS NULL)))
       AND (   (Recinfo.MAINTENANCE_OBJECT_TYPE = P_MAINTENANCE_OBJECT_TYPE)
            OR (    (Recinfo.MAINTENANCE_OBJECT_TYPE IS NULL)
                AND (P_MAINTENANCE_OBJECT_TYPE IS NULL)))
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
         ROLLBACK TO lock_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO lock_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO lock_row;
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
  P_ACTIVITY_ASSOCIATION_ID       NUMBER,
  P_ORGANIZATION_ID               NUMBER,
  P_ASSET_ACTIVITY_ID             NUMBER,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_END_DATE_ACTIVE               DATE,
  P_PRIORITY_CODE                 VARCHAR2,
  P_ACTIVITY_CAUSE_CODE           VARCHAR2,
  P_ACTIVITY_TYPE_CODE            VARCHAR2,
  P_ACTIVITY_SOURCE_CODE          VARCHAR2,
  P_CLASS_CODE                    VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
  P_TAGGING_REQUIRED_FLAG         VARCHAR2,
  P_SHUTDOWN_TYPE_CODE            VARCHAR2,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER,
  P_PROGRAM_APPLICATION_ID        NUMBER,
  P_PROGRAM_ID                    NUMBER,
  P_PROGRAM_UPDATE_DATE           DATE,
  P_MAINTENANCE_OBJECT_ID	NUMBER,
  P_MAINTENANCE_OBJECT_TYPE	NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    l_object_type             NUMBER;
  BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT update_row;

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

    UPDATE MTL_EAM_ASSET_ACTIVITIES
    SET
--     INVENTORY_ITEM_ID               =     P_INVENTORY_ITEM_ID,
--     SERIAL_NUMBER                   =     P_SERIAL_NUMBER,
     START_DATE_ACTIVE               =     P_START_DATE_ACTIVE,
     END_DATE_ACTIVE                 =     P_END_DATE_ACTIVE,
     PRIORITY_CODE                   =     P_PRIORITY_CODE,
     LAST_UPDATE_DATE                =     P_LAST_UPDATE_DATE,
     LAST_UPDATED_BY                 =     P_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN               =     P_LAST_UPDATE_LOGIN,
     ATTRIBUTE_CATEGORY              =     P_ATTRIBUTE_CATEGORY,
     ATTRIBUTE1                      =     P_ATTRIBUTE1,
     ATTRIBUTE2                      =     P_ATTRIBUTE2,
     ATTRIBUTE3                      =     P_ATTRIBUTE3,
     ATTRIBUTE4                      =     P_ATTRIBUTE4,
     ATTRIBUTE5                      =     P_ATTRIBUTE5,
     ATTRIBUTE6                      =     P_ATTRIBUTE6,
     ATTRIBUTE7                      =     P_ATTRIBUTE7,
     ATTRIBUTE8                      =     P_ATTRIBUTE8,
     ATTRIBUTE9                      =     P_ATTRIBUTE9,
     ATTRIBUTE10                     =     P_ATTRIBUTE10,
     ATTRIBUTE11                     =     P_ATTRIBUTE11,
     ATTRIBUTE12                     =     P_ATTRIBUTE12,
     ATTRIBUTE13                     =     P_ATTRIBUTE13,
     ATTRIBUTE14                     =     P_ATTRIBUTE14,
     ATTRIBUTE15                     =     P_ATTRIBUTE15,
     REQUEST_ID                      =     P_REQUEST_ID,
     PROGRAM_APPLICATION_ID          =     P_PROGRAM_APPLICATION_ID,
     PROGRAM_ID                      =     P_PROGRAM_ID,
     PROGRAM_UPDATE_DATE             =     P_PROGRAM_UPDATE_DATE,
	MAINTENANCE_OBJECT_ID	=	P_MAINTENANCE_OBJECT_ID,
 	MAINTENANCE_OBJECT_TYPE	=	P_MAINTENANCE_OBJECT_TYPE
    WHERE ROWID = P_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    IF p_maintenance_object_type = 2 THEN
       l_object_type := 40;
    ELSE
       l_object_type := 60;
    END IF;

    eam_org_maint_defaults_pvt.update_insert_row
    (
      p_api_version           => 1.0
     ,p_object_type           => l_object_type
     ,p_object_id             => p_activity_association_id
     ,p_organization_id       => p_organization_Id
     ,p_owning_department_id  => to_fnd_std_num(p_owning_department_id)
     ,p_accounting_class_code => to_fnd_std_char(p_class_code)
     ,p_activity_cause_code   => to_fnd_std_char(p_activity_cause_code)
     ,p_activity_type_code    => to_fnd_std_char(p_activity_type_code)
     ,p_activity_source_code  => to_fnd_std_char(p_activity_source_code)
     ,p_shutdown_type_code    => to_fnd_std_char(p_shutdown_type_code)
     ,p_tagging_required_flag => to_fnd_std_char(p_tagging_required_flag)
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE fnd_api.g_exc_error;
    END IF;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Update_Row;

END EAM_ASSET_ACTIVITIES_PVT;

/
