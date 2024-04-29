--------------------------------------------------------
--  DDL for Package Body CN_SEASONALITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEASONALITIES_PKG" AS
/*$Header: cntseasb.pls 115.3 2002/01/28 20:06:01 pkm ship      $*/

PROCEDURE insert_row
  (P_SEASONALITY_ID    IN cn_seasonalities.SEASONALITY_ID%TYPE,
   P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE,
   P_CAL_PER_INT_TYPE_ID IN cn_seasonalities.CAL_PER_INT_TYPE_ID%TYPE,
   P_PERIOD_ID         IN cn_seasonalities.PERIOD_ID%TYPE,
   P_PCT_SEASONALITY   IN cn_seasonalities.PCT_SEASONALITY%TYPE,
   p_attribute_category IN cn_seasonalities.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seasonalities.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seasonalities.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seasonalities.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seasonalities.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seasonalities.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seasonalities.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seasonalities.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seasonalities.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seasonalities.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seasonalities.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seasonalities.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seasonalities.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seasonalities.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seasonalities.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seasonalities.attribute15%TYPE := NULL,
   p_created_by IN  cn_seasonalities.created_by%TYPE := NULL,
   p_creation_date IN cn_seasonalities.creation_date%TYPE := NULL,
   p_last_update_login IN cn_seasonalities.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seasonalities.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seasonalities.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_seasonalities.OBJECT_VERSION_NUMBER%TYPE := NULL)
   IS
   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

BEGIN
   INSERT INTO cn_seasonalities(
     SEASONALITY_ID,
     SEAS_SCHEDULE_ID,
     CAL_PER_INT_TYPE_ID,
     PERIOD_ID,
     PCT_SEASONALITY,
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
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     object_version_number
   )
   SELECT
     cn_seasonalities_s.nextval,
     P_SEAS_SCHEDULE_ID,
     P_CAL_PER_INT_TYPE_ID,
     P_PERIOD_ID,
     P_PCT_SEASONALITY,
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
     fnd_global.user_id,
     sysdate,
     fnd_global.login_id,
     sysdate,
     fnd_global.user_id,
     1
    FROM dual;
END insert_row;


PROCEDURE update_row
  (P_SEASONALITY_ID    IN cn_seasonalities.SEASONALITY_ID%TYPE,
   P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE,
   P_CAL_PER_INT_TYPE_ID IN cn_seasonalities.CAL_PER_INT_TYPE_ID%TYPE,
   P_PERIOD_ID         IN cn_seasonalities.PERIOD_ID%TYPE,
   P_PCT_SEASONALITY   IN cn_seasonalities.PCT_SEASONALITY%TYPE,
   p_attribute_category IN cn_seasonalities.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seasonalities.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seasonalities.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seasonalities.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seasonalities.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seasonalities.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seasonalities.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seasonalities.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seasonalities.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seasonalities.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seasonalities.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seasonalities.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seasonalities.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seasonalities.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seasonalities.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seasonalities.attribute15%TYPE := NULL,
   p_created_by IN  cn_seasonalities.created_by%TYPE := NULL,
   p_creation_date IN cn_seasonalities.creation_date%TYPE := NULL,
   p_last_update_login IN cn_seasonalities.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seasonalities.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seasonalities.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_seasonalities.OBJECT_VERSION_NUMBER%TYPE := NULL) IS

   CURSOR l_old_csr IS
      SELECT *
	FROM cn_seasonalities
       WHERE SEASONALITY_ID = P_SEASONALITY_ID AND SEAS_SCHEDULE_ID = P_SEAS_SCHEDULE_ID ;

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
   FROM dual;

   -- check object version number
   IF l_object_version_number <> l_old_rec.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   UPDATE cn_seasonalities SET
    (PCT_SEASONALITY,
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
        P_PCT_SEASONALITY,
        decode(p_attribute_category, mc, l_old_rec.attribute_category,p_attribute_category),
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
        decode(p_object_version_number, mn,l_old_rec.object_version_number, p_object_version_number+1),
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
       FROM dual)
       WHERE seasonality_id = p_seasonality_id AND seas_schedule_id = p_seas_schedule_id;
END update_row;


PROCEDURE delete_row
  (P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE) IS
BEGIN
   DELETE FROM cn_seasonalities
     WHERE SEAS_SCHEDULE_ID = P_SEAS_SCHEDULE_ID;

END delete_row;

END cn_seasonalities_pkg;

/
