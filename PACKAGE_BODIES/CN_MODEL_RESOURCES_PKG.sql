--------------------------------------------------------
--  DDL for Package Body CN_MODEL_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MODEL_RESOURCES_PKG" AS
  /*$Header: cntmlrsb.pls 115.2 2002/01/28 20:04:51 pkm ship      $*/

PROCEDURE insert_row
  (P_MODEL_RESOURCE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_RESOURCE_ID                 IN   NUMBER,
   P_NAME                        IN   VARCHAR2,
   P_SRP_ID                      IN   NUMBER,
   P_ATTRIBUTE_CATEGORY          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR)
IS
   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

BEGIN

   INSERT INTO cn_model_resources(
     model_resource_id,
     resource_id,
     name,
     srp_id,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     object_version_number,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     CREATION_DATE,
     CREATED_BY
   )
   SELECT
     decode(p_model_resource_id, mn, cn_model_resources_s.nextval,
            p_model_resource_id),
     p_resource_id,
     p_name,
     p_srp_id,
     decode(p_attribute_category, mc, null, p_attribute_category),
     decode(p_attribute1, mc, null, p_attribute1),
     decode(p_attribute2, mc, null, p_attribute2),
     decode(p_attribute3, mc, null, p_attribute3),
     decode(p_attribute4, mc, null, p_attribute4),
     decode(p_attribute5, mc, null, p_attribute5),
     decode(p_attribute6, mc, null, p_attribute6),
     decode(p_attribute7, mc, null, p_attribute7),
     decode(p_attribute8, mc, null, p_attribute8),
     decode(p_attribute9, mc, null, p_attribute9),
     decode(p_attribute10, mc, null, p_attribute10),
     decode(p_attribute11, mc, null, p_attribute11),
     decode(p_attribute12, mc, null, p_attribute12),
     decode(p_attribute13, mc, null, p_attribute13),
     decode(p_attribute14, mc, null, p_attribute14),
     decode(p_attribute15, mc, null, p_attribute15),
     1,
     sysdate,
     fnd_global.user_id,
     fnd_global.login_id,
     sysdate,
     fnd_global.user_id
    FROM dual
        ;

END Insert_Row;


PROCEDURE Update_Row
  (P_MODEL_RESOURCE_ID	         IN   NUMBER,
   P_RESOURCE_ID                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_NAME                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SRP_ID                      IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTRIBUTE_CATEGORY          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUMBER       IN   NUMBER   := FND_API.G_MISS_NUM )
IS

   CURSOR l_old_csr IS
      SELECT *
	FROM cn_model_resources
       WHERE model_resource_id = p_model_resource_id;

   l_old_rec   l_old_csr%ROWTYPE;

   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

   l_object_version_number  NUMBER;

BEGIN
   OPEN l_old_csr;
   FETCH l_old_csr INTO l_old_rec;
   CLOSE l_old_csr;

   SELECT decode(p_object_version_number, mn,
                 l_old_rec.object_version_number, p_object_version_number)
     INTO l_object_version_number
     FROM dual
        ;

   -- check object version number
   IF l_object_version_number <> l_old_rec.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   UPDATE cn_model_resources SET
    (resource_id,
     name,
     srp_id,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     object_version_number,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
   ) =
     (
      SELECT
        decode(p_resource_id, mn, l_old_rec.resource_id, p_resource_id),
        decode(p_name, mc, l_old_rec.name, p_name),
        decode(p_srp_id, mn, l_old_rec.srp_id, p_srp_id),
        decode(p_attribute_category, mc, l_old_rec.attribute_category,
               p_attribute_category),
        decode(p_attribute1, mc, l_old_rec.attribute1, p_attribute1),
        decode(p_attribute2, mc, l_old_rec.attribute2, p_attribute2),
        decode(p_attribute3, mc, l_old_rec.attribute3, p_attribute3),
        decode(p_attribute4, mc, l_old_rec.attribute4, p_attribute4),
        decode(p_attribute5, mc, l_old_rec.attribute5, p_attribute5),
        decode(p_attribute6, mc, l_old_rec.attribute6, p_attribute6),
        decode(p_attribute7, mc, l_old_rec.attribute7, p_attribute7),
        decode(p_attribute8, mc, l_old_rec.attribute8, p_attribute8),
        decode(p_attribute9, mc, l_old_rec.attribute9, p_attribute9),
        decode(p_attribute10, mc, l_old_rec.attribute10, p_attribute10),
        decode(p_attribute11, mc, l_old_rec.attribute11, p_attribute11),
        decode(p_attribute12, mc, l_old_rec.attribute12, p_attribute12),
        decode(p_attribute13, mc, l_old_rec.attribute13, p_attribute13),
        decode(p_attribute14, mc, l_old_rec.attribute14, p_attribute14),
        decode(p_attribute15, mc, l_old_rec.attribute15, p_attribute15),
        l_old_rec.object_version_number+1,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
       FROM dual)
     WHERE model_resource_id = p_model_resource_id;

END Update_Row;


PROCEDURE Delete_Row
  (P_MODEL_RESOURCE_ID           IN   NUMBER) IS
BEGIN
   DELETE FROM cn_model_resources
     WHERE model_resource_id = p_model_resource_id;

END Delete_Row;

END cn_model_resources_pkg;

/
