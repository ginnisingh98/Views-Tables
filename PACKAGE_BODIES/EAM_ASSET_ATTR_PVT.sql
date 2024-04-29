--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_ATTR_PVT" as
/* $Header: EAMVAATB.pls 120.5.12010000.2 2008/10/23 11:01:45 vboddapa ship $ */
 -- Start of comments
 -- API name    : EAM_ASSET_ATTR_PVT
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
 --          P_INVENTORY_ITEM_ID           IN  NUMBER
 --          P_SERIAL_NUMBER               IN  VARCHAR2
 --          P_START_DATE_ACTIVE           IN  DATE
 --          P_DESCRIPTIVE_TEXT            IN  VARCHAR2
 --          P_ORGANIZATION_ID             IN  NUMBER
 --          P_CATEGORY_ID                 IN  NUMBER
 --          P_PN_LOCATION_ID              IN  NUMBER
 --          P_EAM_LOCATION_ID             IN  NUMBER
 --          P_FA_ASSET_ID                 IN  NUMBER
 --          P_ASSET_STATUS_CODE           IN  VARCHAR2
 --          P_ASSET_CRITICALITY_CODE      IN  VARCHAR2
 --          P_WIP_ACCOUNTING_CLASS_CODE   IN  VARCHAR2
 --          P_MAINTAINABLE_FLAG           IN  VARCHAR2
 --          P_NETWORK_ASSET_FLAG          IN  VARCHAR2
 --          P_OWNING_DEPARTMENT_ID        IN  NUMBER
 --          P_DEPENDENT_ASSET_FLAG        IN  VARCHAR2
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
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_OBJECT_ID                   OUT NUMBER
 --          X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_asset_attr_pvt';


PROCEDURE INSERT_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_ASSOCIATION_ID                  NUMBER,
  P_APPLICATION_ID                  NUMBER,
  P_DESCRIPTIVE_FLEXFIELD_NAME      VARCHAR2,
  P_INVENTORY_ITEM_ID               NUMBER,
  P_SERIAL_NUMBER                   VARCHAR2,
  P_ORGANIZATION_ID                 NUMBER,
  P_ATTRIBUTE_CATEGORY              VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER ,
  P_PROGRAM_APPLICATION_ID          NUMBER ,
  P_PROGRAM_ID                      NUMBER ,
  P_PROGRAM_UPDATE_DATE             DATE ,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  P_CREATION_ORGANIZATION_ID          NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    l_serial_number	varchar2(30);
    l_inventory_item_id	number;

    CURSOR C IS SELECT rowid FROM MTL_EAM_ASSET_ATTR_VALUES
                 WHERE attribute_category = p_attribute_category
                   AND maintenance_object_type = P_maintenance_object_type
                   AND maintenance_object_id = P_maintenance_object_id
                   ;

 begin

   -- Standard Start of API savepoint
      SAVEPOINT eam_asset_attr;

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

   if (p_maintenance_object_id is not null) then
   	select serial_number,inventory_item_id
   	into l_serial_number,l_inventory_item_id
   	from csi_item_instances
   	where instance_id = p_maintenance_object_id;
   else
   	l_inventory_item_id := p_inventory_item_id;
   	l_serial_number := p_serial_number;
   end if;

INSERT INTO MTL_EAM_ASSET_ATTR_VALUES(
      association_id,
      application_id,
      descriptive_flexfield_name,
      inventory_item_id,
      serial_number,
      organization_id,
      attribute_category,
      c_attribute1,
      c_attribute2,
      c_attribute3,
      c_attribute4,
      c_attribute5,
      c_attribute6,
      c_attribute7,
      c_attribute8,
      c_attribute9,
      c_attribute10,
      c_attribute11,
      c_attribute12,
      c_attribute13,
      c_attribute14,
      c_attribute15,
      c_attribute16,
      c_attribute17,
      c_attribute18,
      c_attribute19,
      c_attribute20,
      d_attribute1,
      d_attribute2,
      d_attribute3,
      d_attribute4,
      d_attribute5,
      d_attribute6,
      d_attribute7,
      d_attribute8,
      d_attribute9,
      d_attribute10,
      n_attribute1,
      n_attribute2,
      n_attribute3,
      n_attribute4,
      n_attribute5,
      n_attribute6,
      n_attribute7,
      n_attribute8,
      n_attribute9,
      n_attribute10,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      maintenance_object_id,
      maintenance_object_type,
      creation_organization_id
           ) values (
      p_association_id,
      p_application_id,
      p_descriptive_flexfield_name,
      l_inventory_item_id,
      l_serial_number,
      p_organization_id,
      p_attribute_category,
      p_c_attribute1,
      p_c_attribute2,
      p_c_attribute3,
      p_c_attribute4,
      p_c_attribute5,
      p_c_attribute6,
      p_c_attribute7,
      p_c_attribute8,
      p_c_attribute9,
      p_c_attribute10,
      p_c_attribute11,
      p_c_attribute12,
      p_c_attribute13,
      p_c_attribute14,
      p_c_attribute15,
      p_c_attribute16,
      p_c_attribute17,
      p_c_attribute18,
      p_c_attribute19,
      p_c_attribute20,
      p_d_attribute1,
      p_d_attribute2,
      p_d_attribute3,
      p_d_attribute4,
      p_d_attribute5,
      p_d_attribute6,
      p_d_attribute7,
      p_d_attribute8,
      p_d_attribute9,
      p_d_attribute10,
      p_n_attribute1,
      p_n_attribute2,
      p_n_attribute3,
      p_n_attribute4,
      p_n_attribute5,
      p_n_attribute6,
      p_n_attribute7,
      p_n_attribute8,
      p_n_attribute9,
      p_n_attribute10,
      p_last_update_date,
      p_last_updated_by,
      p_creation_date,
      p_created_by,
      p_last_update_login,
      p_request_id,
      p_program_application_id,
      p_program_id,
      p_program_update_date,
      p_maintenance_object_id,
      p_maintenance_object_type,
      p_creation_organization_id
      );

    OPEN C;
    FETCH C INTO P_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    eam_text_util.process_asset_update_event
    (
      p_event         => 'UPDATE'
     ,p_instance_id   => p_maintenance_object_id
     ,p_commit        => p_commit
    );

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Insert_Row;



PROCEDURE LOCK_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_ASSOCIATION_ID                  NUMBER,
  P_APPLICATION_ID                  NUMBER,
  P_DESCRIPTIVE_FLEXFIELD_NAME      VARCHAR2,
  P_INVENTORY_ITEM_ID               NUMBER,
  P_SERIAL_NUMBER                   VARCHAR2,
  P_ORGANIZATION_ID                 NUMBER,
  P_ATTRIBUTE_CATEGORY              VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER  ,
  P_PROGRAM_APPLICATION_ID          NUMBER  ,
  P_PROGRAM_ID                      NUMBER  ,
  P_PROGRAM_UPDATE_DATE             DATE  ,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

    CURSOR C IS
        SELECT *
        FROM   MTL_EAM_ASSET_ATTR_VALUES
        WHERE  rowid = P_Rowid
        FOR UPDATE of ATTRIBUTE_CATEGORY NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT eam_asset_attr;

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
       (Recinfo.INVENTORY_ITEM_ID =  P_INVENTORY_ITEM_ID)
       AND (Recinfo.SERIAL_NUMBER =  P_SERIAL_NUMBER)
       AND (Recinfo.ASSOCIATION_ID =  P_ASSOCIATION_ID)
       AND (Recinfo.APPLICATION_ID =  P_APPLICATION_ID)
       AND (Recinfo.DESCRIPTIVE_FLEXFIELD_NAME =  P_DESCRIPTIVE_FLEXFIELD_NAME)
       AND (   (Recinfo.attribute_category =  P_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (P_Attribute_Category IS NULL)))
       AND (   (Recinfo.c_attribute1 =  p_c_attribute1)
            OR (    (Recinfo.c_attribute1 IS NULL)
                AND (p_c_attribute1 IS NULL)))
       AND (   (Recinfo.c_attribute2 =  p_c_attribute2)
            OR (    (Recinfo.c_attribute2 IS NULL)
                AND (p_c_attribute2 IS NULL)))
       AND (   (Recinfo.c_attribute3 =  p_c_attribute3)
            OR (    (Recinfo.c_attribute3 IS NULL)
                AND (p_c_attribute3 IS NULL)))
       AND (   (Recinfo.c_attribute4 =  p_c_attribute4)
            OR (    (Recinfo.c_attribute4 IS NULL)
                AND (p_c_attribute4 IS NULL)))
       AND (   (Recinfo.c_attribute5 =  p_c_attribute5)
            OR (    (Recinfo.c_attribute5 IS NULL)
                AND (p_c_attribute5 IS NULL)))
       AND (   (Recinfo.c_attribute6 =  p_c_attribute6)
            OR (    (Recinfo.c_attribute6 IS NULL)
                AND (p_c_attribute6 IS NULL)))
       AND (   (Recinfo.c_attribute7 =  p_c_attribute7)
            OR (    (Recinfo.c_attribute7 IS NULL)
                AND (p_c_attribute7 IS NULL)))
       AND (   (Recinfo.c_attribute8 =  p_c_attribute8)
            OR (    (Recinfo.c_attribute8 IS NULL)
                AND (p_c_attribute8 IS NULL)))
       AND (   (Recinfo.c_attribute9 =  p_c_attribute9)
            OR (    (Recinfo.c_attribute9 IS NULL)
                AND (p_c_attribute9 IS NULL)))
       AND (   (Recinfo.c_attribute10 =  p_c_attribute10)
            OR (    (Recinfo.c_attribute10 IS NULL)
                AND (p_c_attribute10 IS NULL)))
       AND (   (Recinfo.c_attribute11 =  p_c_attribute11)
            OR (    (Recinfo.c_attribute11 IS NULL)
                AND (p_c_attribute11 IS NULL)))
       AND (   (Recinfo.c_attribute12 =  p_c_attribute12)
            OR (    (Recinfo.c_attribute12 IS NULL)
                AND (p_c_attribute12 IS NULL)))
       AND (   (Recinfo.c_attribute13 =  p_c_attribute13)
            OR (    (Recinfo.c_attribute13 IS NULL)
                AND (p_c_attribute13 IS NULL)))
       AND (   (Recinfo.c_attribute14 =  p_c_attribute14)
            OR (    (Recinfo.c_attribute14 IS NULL)
                AND (p_c_attribute14 IS NULL)))
       AND (   (Recinfo.c_attribute15 =  p_c_attribute15)
            OR (    (Recinfo.c_attribute15 IS NULL)
                AND (p_c_attribute15 IS NULL)))
       AND (   (Recinfo.c_attribute16 =  p_c_attribute16)
            OR (    (Recinfo.c_attribute16 IS NULL)
                AND (p_c_attribute16 IS NULL)))
       AND (   (Recinfo.c_attribute17 =  p_c_attribute17)
            OR (    (Recinfo.c_attribute17 IS NULL)
                AND (p_c_attribute17 IS NULL)))
       AND (   (Recinfo.c_attribute18 =  p_c_attribute18)
            OR (    (Recinfo.c_attribute18 IS NULL)
                AND (p_c_attribute18 IS NULL)))
       AND (   (Recinfo.c_attribute19 =  p_c_attribute19)
            OR (    (Recinfo.c_attribute19 IS NULL)
                AND (p_c_attribute19 IS NULL)))
       AND (   (Recinfo.c_attribute20 =  p_c_attribute20)
            OR (    (Recinfo.c_attribute20 IS NULL)
                AND (p_c_attribute20 IS NULL)))
       AND (   (Recinfo.n_attribute1 =  p_n_attribute1)
            OR (    (Recinfo.n_attribute1 IS NULL)
                AND (p_n_attribute1 IS NULL)))
       AND (   (Recinfo.n_attribute2 =  p_n_attribute2)
            OR (    (Recinfo.n_attribute2 IS NULL)
                AND (p_n_attribute2 IS NULL)))
       AND (   (Recinfo.n_attribute3 =  p_n_attribute3)
            OR (    (Recinfo.n_attribute3 IS NULL)
                AND (p_n_attribute3 IS NULL)))
       AND (   (Recinfo.n_attribute4 =  p_n_attribute4)
            OR (    (Recinfo.n_attribute4 IS NULL)
                AND (p_n_attribute4 IS NULL)))
       AND (   (Recinfo.n_attribute5 =  p_n_attribute5)
            OR (    (Recinfo.n_attribute5 IS NULL)
                AND (p_n_attribute5 IS NULL)))
       AND (   (Recinfo.n_attribute6 =  p_n_attribute6)
            OR (    (Recinfo.n_attribute6 IS NULL)
                AND (p_n_attribute6 IS NULL)))
       AND (   (Recinfo.n_attribute7 =  p_n_attribute7)
            OR (    (Recinfo.n_attribute7 IS NULL)
                AND (p_n_attribute7 IS NULL)))
       AND (   (Recinfo.n_attribute8 =  p_n_attribute8)
            OR (    (Recinfo.n_attribute8 IS NULL)
                AND (p_n_attribute8 IS NULL)))
       AND (   (Recinfo.n_attribute9 =  p_n_attribute9)
            OR (    (Recinfo.n_attribute9 IS NULL)
                AND (p_n_attribute9 IS NULL)))
       AND (   (Recinfo.n_attribute10 =  p_n_attribute10)
            OR (    (Recinfo.n_attribute10 IS NULL)
                AND (p_n_attribute10 IS NULL)))
       AND (   (Recinfo.d_attribute1 =  p_d_attribute1)
            OR (    (Recinfo.d_attribute1 IS NULL)
                AND (p_d_attribute1 IS NULL)))
       AND (   (Recinfo.d_attribute2 =  p_d_attribute2)
            OR (    (Recinfo.d_attribute2 IS NULL)
                AND (p_d_attribute2 IS NULL)))
       AND (   (Recinfo.d_attribute3 =  p_d_attribute3)
            OR (    (Recinfo.d_attribute3 IS NULL)
                AND (p_d_attribute3 IS NULL)))
       AND (   (Recinfo.d_attribute4 =  p_d_attribute4)
            OR (    (Recinfo.d_attribute4 IS NULL)
                AND (p_d_attribute4 IS NULL)))
       AND (   (Recinfo.d_attribute5 =  p_d_attribute5)
            OR (    (Recinfo.d_attribute5 IS NULL)
                AND (p_d_attribute5 IS NULL)))
       AND (   (Recinfo.d_attribute6 =  p_d_attribute6)
            OR (    (Recinfo.d_attribute6 IS NULL)
                AND (p_d_attribute6 IS NULL)))
       AND (   (Recinfo.d_attribute7 =  p_d_attribute7)
            OR (    (Recinfo.d_attribute7 IS NULL)
                AND (p_d_attribute7 IS NULL)))
       AND (   (Recinfo.d_attribute8 =  p_d_attribute8)
            OR (    (Recinfo.d_attribute8 IS NULL)
                AND (p_d_attribute8 IS NULL)))
       AND (   (Recinfo.d_attribute9 =  p_d_attribute9)
            OR (    (Recinfo.d_attribute9 IS NULL)
                AND (p_d_attribute9 IS NULL)))
       AND (   (Recinfo.d_attribute10 =  p_d_attribute10)
            OR (    (Recinfo.d_attribute10 IS NULL)
                AND (p_d_attribute10 IS NULL)))
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
       AND (   (Recinfo.MAINTENANCE_OBJECT_TYPE = P_MAINTENANCE_OBJECT_TYPE)
            OR (    (Recinfo.MAINTENANCE_OBJECT_TYPE IS NULL)
                AND (P_MAINTENANCE_OBJECT_TYPE IS NULL)))
       AND (   (Recinfo.MAINTENANCE_OBJECT_ID = P_MAINTENANCE_OBJECT_ID)
            OR (    (Recinfo.MAINTENANCE_OBJECT_ID IS NULL)
                AND (P_MAINTENANCE_OBJECT_ID IS NULL)))
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
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Lock_Row;

PROCEDURE UPDATE_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER  ,
  P_PROGRAM_APPLICATION_ID          NUMBER  ,
  P_PROGRAM_ID                      NUMBER  ,
  P_PROGRAM_UPDATE_DATE             DATE  ,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  /* Bug 3371507 */
  P_FROM_PUBLIC_API               VARCHAR2 DEFAULT 'Y',
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT eam_asset_attr;

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
/* Bug 3371507: used 'decode' function*/
UPDATE MTL_EAM_ASSET_ATTR_VALUES
set
      c_attribute1           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE1, DECODE(p_c_attribute1,NULL,c_attribute1,FND_API.G_MISS_CHAR,NULL,p_c_attribute1)),
      c_attribute2           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE2, DECODE(p_c_attribute2,NULL,c_attribute2,FND_API.G_MISS_CHAR,NULL,p_c_attribute2)),
      c_attribute3           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE3, DECODE(p_c_attribute3,NULL,c_attribute3,FND_API.G_MISS_CHAR,NULL,p_c_attribute3)),
      c_attribute4           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE4, DECODE(p_c_attribute4,NULL,c_attribute4,FND_API.G_MISS_CHAR,NULL,p_c_attribute4)),
      c_attribute5           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE5, DECODE(p_c_attribute5,NULL,c_attribute5,FND_API.G_MISS_CHAR,NULL,p_c_attribute5)),
      c_attribute6           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE6, DECODE(p_c_attribute6,NULL,c_attribute6,FND_API.G_MISS_CHAR,NULL,p_c_attribute6)),
      c_attribute7           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE7, DECODE(p_c_attribute7,NULL,c_attribute7,FND_API.G_MISS_CHAR,NULL,p_c_attribute7)),
      c_attribute8           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE8, DECODE(p_c_attribute8,NULL,c_attribute8,FND_API.G_MISS_CHAR,NULL,p_c_attribute8)),
      c_attribute9           = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE9, DECODE(p_c_attribute9,NULL,c_attribute9,FND_API.G_MISS_CHAR,NULL,p_c_attribute9)),
      c_attribute10          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE10, DECODE(p_c_attribute10,NULL,c_attribute10,FND_API.G_MISS_CHAR,NULL,p_c_attribute10)),
      c_attribute11          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE11, DECODE(p_c_attribute11,NULL,c_attribute11,FND_API.G_MISS_CHAR,NULL,p_c_attribute11)),
      c_attribute12          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE12, DECODE(p_c_attribute12,NULL,c_attribute12,FND_API.G_MISS_CHAR,NULL,p_c_attribute12)),
      c_attribute13          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE13, DECODE(p_c_attribute13,NULL,c_attribute13,FND_API.G_MISS_CHAR,NULL,p_c_attribute13)),
      c_attribute14          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE14, DECODE(p_c_attribute14,NULL,c_attribute14,FND_API.G_MISS_CHAR,NULL,p_c_attribute14)),
      c_attribute15          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE15, DECODE(p_c_attribute15,NULL,c_attribute15,FND_API.G_MISS_CHAR,NULL,p_c_attribute15)),
      c_attribute16          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE16, DECODE(p_c_attribute16,NULL,c_attribute16,FND_API.G_MISS_CHAR,NULL,p_c_attribute16)),
      c_attribute17          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE17, DECODE(p_c_attribute17,NULL,c_attribute17,FND_API.G_MISS_CHAR,NULL,p_c_attribute17)),
      c_attribute18          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE18, DECODE(p_c_attribute18,NULL,c_attribute18,FND_API.G_MISS_CHAR,NULL,p_c_attribute18)),
      c_attribute19          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE19, DECODE(p_c_attribute19,NULL,c_attribute19,FND_API.G_MISS_CHAR,NULL,p_c_attribute19)),
      c_attribute20          = decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE20, DECODE(p_c_attribute20,NULL,c_attribute20,FND_API.G_MISS_CHAR,NULL,p_c_attribute20)),
      d_attribute1           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE1, DECODE(p_d_attribute1,NULL,d_attribute1,FND_API.G_MISS_DATE,NULL,p_d_attribute1)),
      d_attribute2           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE2, DECODE(p_d_attribute2,NULL,d_attribute2,FND_API.G_MISS_DATE,NULL,p_d_attribute2)),
      d_attribute3           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE3, DECODE(p_d_attribute3,NULL,d_attribute3,FND_API.G_MISS_DATE,NULL,p_d_attribute3)),
      d_attribute4           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE4, DECODE(p_d_attribute4,NULL,d_attribute4,FND_API.G_MISS_DATE,NULL,p_d_attribute4)),
      d_attribute5           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE5, DECODE(p_d_attribute5,NULL,d_attribute5,FND_API.G_MISS_DATE,NULL,p_d_attribute5)),
      d_attribute6           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE6, DECODE(p_d_attribute6,NULL,d_attribute6,FND_API.G_MISS_DATE,NULL,p_d_attribute6)),
      d_attribute7           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE7, DECODE(p_d_attribute7,NULL,d_attribute7,FND_API.G_MISS_DATE,NULL,p_d_attribute7)),
      d_attribute8           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE8, DECODE(p_d_attribute8,NULL,d_attribute8,FND_API.G_MISS_DATE,NULL,p_d_attribute8)),
      d_attribute9           = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE9, DECODE(p_d_attribute9,NULL,d_attribute9,FND_API.G_MISS_DATE,NULL,p_d_attribute9)),
      d_attribute10          = decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE10, DECODE(p_d_attribute10,NULL,d_attribute10,FND_API.G_MISS_DATE,NULL,p_d_attribute10)),
      n_attribute1           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE1, DECODE(p_n_attribute1,NULL,n_attribute1,FND_API.G_MISS_NUM,NULL,p_n_attribute1)),
      n_attribute2           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE2, DECODE(p_n_attribute2,NULL,n_attribute2,FND_API.G_MISS_NUM,NULL,p_n_attribute2)),
      n_attribute3           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE3, DECODE(p_n_attribute3,NULL,n_attribute3,FND_API.G_MISS_NUM,NULL,p_n_attribute3)),
      n_attribute4           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE4, DECODE(p_n_attribute4,NULL,n_attribute4,FND_API.G_MISS_NUM,NULL,p_n_attribute4)),
      n_attribute5           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE5, DECODE(p_n_attribute5,NULL,n_attribute5,FND_API.G_MISS_NUM,NULL,p_n_attribute5)),
      n_attribute6           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE6, DECODE(p_n_attribute6,NULL,n_attribute6,FND_API.G_MISS_NUM,NULL,p_n_attribute6)),
      n_attribute7           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE7, DECODE(p_n_attribute7,NULL,n_attribute7,FND_API.G_MISS_NUM,NULL,p_n_attribute7)),
      n_attribute8           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE8, DECODE(p_n_attribute8,NULL,n_attribute8,FND_API.G_MISS_NUM,NULL,p_n_attribute8)),
      n_attribute9           = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE9, DECODE(p_n_attribute9,NULL,n_attribute9,FND_API.G_MISS_NUM,NULL,p_n_attribute9)),
      n_attribute10          = decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE10, DECODE(p_n_attribute10,NULL,n_attribute10,FND_API.G_MISS_NUM,NULL,p_n_attribute10)),
      last_update_date       = p_last_update_date,
      last_updated_by        = p_last_updated_by,
      last_update_login      = p_last_update_login,
      request_id             = p_request_id,
      program_application_id = p_program_application_id,
      program_id             = p_program_id,
      program_update_date    = p_program_update_date,
      maintenance_object_type= p_maintenance_object_type,
      maintenance_object_id  = p_maintenance_object_id
    where rowid = p_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    eam_text_util.process_asset_update_event
    (
      p_event         => 'UPDATE'
     ,p_instance_id   => p_maintenance_object_id
     ,p_commit        => p_commit
    );


   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Update_Row;





PROCEDURE DELETE_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    l_object_id               NUMBER;
  BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT eam_asset_attr;

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
   BEGIN
       SELECT maintenance_object_id into l_object_id
         FROM mtl_eam_asset_attr_values
        WHERE rowid = p_rowid;

       Delete from mtl_eam_asset_attr_values
        where rowid = p_rowid;


       eam_text_util.process_asset_update_event
       (
         p_event         => 'UPDATE'
        ,p_instance_id   => l_object_id
        ,p_commit        => p_commit
       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
       null;
   END;
   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_asset_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

END Delete_Row;


PROCEDURE COPY_ATTRIBUTE(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID            IN NUMBER,
  P_ORGANIZATION_ID              IN NUMBER,
  P_SERIAL_NUMBER_FROM           IN VARCHAR2,
  P_SERIAL_NUMBER_TO             IN VARCHAR2,
  X_OBJECT_ID                   OUT NOCOPY NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'copy_attribute';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    sql_stmt_num     NUMBER;
    l_return_status  VARCHAR2(30);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(30);
    l_object_id number;
    l_parent_object_id NUMBER;
    l_parent_inventory_item_id NUMBER;
    l_parent_serial_number VARCHAR2(30);



  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT copy_attr;

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
    sql_stmt_num :=1;

    select instance_id into l_object_id
    from csi_item_instances
    where serial_number = p_serial_number_to
    and inventory_item_id = p_inventory_item_id;



  insert into mtl_eam_asset_attr_values
  (
    association_id,
    application_id,
    descriptive_flexfield_name,
    inventory_item_id,
    serial_number,
    organization_id,
    attribute_category,
    c_attribute1,
    c_attribute2,
    c_attribute3,
    c_attribute4,
    c_attribute5,
    c_attribute6,
    c_attribute7,
    c_attribute8,
    c_attribute9,
    c_attribute10,
    c_attribute11,
    c_attribute12,
    c_attribute13,
    c_attribute14,
    c_attribute15,
    c_attribute16,
    c_attribute17,
    c_attribute18,
    c_attribute19,
    c_attribute20,
    d_attribute1,
    d_attribute2,
    d_attribute3,
    d_attribute4,
    d_attribute5,
    d_attribute6,
    d_attribute7,
    d_attribute8,
    d_attribute9,
    d_attribute10,
    n_attribute1,
    n_attribute2,
    n_attribute3,
    n_attribute4,
    n_attribute5,
    n_attribute6,
    n_attribute7,
    n_attribute8,
    n_attribute9,
    n_attribute10,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    program_id,
    program_update_date,
    program_application_id,
    request_id,
    maintenance_object_id,
    maintenance_object_type,
    creation_organization_id
  )
  select
    association_id,
    application_id,
    descriptive_flexfield_name,
    p_inventory_item_id,
    p_serial_number_to,
    p_organization_id,
    attribute_category,
    c_attribute1,
    c_attribute2,
    c_attribute3,
    c_attribute4,
    c_attribute5,
    c_attribute6,
    c_attribute7,
    c_attribute8,
    c_attribute9,
    c_attribute10,
    c_attribute11,
    c_attribute12,
    c_attribute13,
    c_attribute14,
    c_attribute15,
    c_attribute16,
    c_attribute17,
    c_attribute18,
    c_attribute19,
    c_attribute20,
    d_attribute1,
    d_attribute2,
    d_attribute3,
    d_attribute4,
    d_attribute5,
    d_attribute6,
    d_attribute7,
    d_attribute8,
    d_attribute9,
    d_attribute10,
    n_attribute1,
    n_attribute2,
    n_attribute3,
    n_attribute4,
    n_attribute5,
    n_attribute6,
    n_attribute7,
    n_attribute8,
    n_attribute9,
    n_attribute10,
    sysdate,--last_update_date,
    last_updated_by,
    sysdate,--creation_date,
    created_by,
    last_update_login,
    program_id,
    program_update_date,
    program_application_id,
    request_id,
    l_object_id,
    maintenance_object_type,
    organization_id
  from mtl_eam_asset_attr_values
  where descriptive_flexfield_name = 'MTL_EAM_ASSET_ATTR_VALUES'
  and   inventory_item_id = p_inventory_item_id
  and   serial_number = p_serial_number_from
  and   attribute_category not in (
                                    select attribute_category
                                    from mtl_eam_asset_attr_values
                                    where descriptive_flexfield_name = 'MTL_EAM_ASSET_ATTR_VALUES'
                                    and   inventory_item_id = p_inventory_item_id
                                    and   serial_number = p_serial_number_to
                                    );

    x_object_id := l_object_id;

    eam_text_util.process_asset_update_event
    (
      p_event         => 'UPDATE'
     ,p_instance_id   => l_object_id
     ,p_commit        => p_commit
    );


   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO copy_attr;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO copy_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO copy_attr;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END COPY_ATTRIBUTE;

END EAM_ASSET_ATTR_PVT;

/
