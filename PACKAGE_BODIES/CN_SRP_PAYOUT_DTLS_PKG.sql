--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYOUT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYOUT_DTLS_PKG" AS
  /*$Header: cntmdtlb.pls 115.0 2003/08/25 21:47:57 nkodkani noship $*/

PROCEDURE insert_row
  (p_SRP_payout_dtl_ID IN cn_srp_payout_dtls.SRP_payout_dtl_ID%TYPE,
   p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_payout_dtls.role_model_id%TYPE := NULL,
   p_attain_tier_id IN cn_srp_payout_dtls.attain_tier_id%TYPE,
   p_role_id IN cn_srp_payout_dtls.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_payout_dtls.attain_schedule_id%TYPE,
   p_quota_category_id IN cn_srp_payout_dtls.quota_category_id%TYPE,
   p_percent IN cn_srp_payout_dtls.percent%TYPE,
   p_payout IN cn_srp_payout_dtls.payout%TYPE,
   p_attribute_category IN cn_srp_payout_dtls.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_payout_dtls.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_payout_dtls.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_payout_dtls.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_payout_dtls.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_payout_dtls.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_payout_dtls.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_payout_dtls.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_payout_dtls.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_payout_dtls.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_payout_dtls.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_payout_dtls.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_payout_dtls.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_payout_dtls.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_payout_dtls.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_payout_dtls.attribute15%TYPE := NULL,
   p_created_by IN  cn_srp_payout_dtls.created_by%TYPE := NULL,
   p_creation_date IN cn_srp_payout_dtls.creation_date%TYPE := NULL,
   p_last_update_login IN cn_srp_payout_dtls.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_srp_payout_dtls.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_srp_payout_dtls.last_updated_by%TYPE := NULL)
   IS
   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

BEGIN

   INSERT INTO cn_srp_payout_dtls(
     SRP_payout_dtl_ID,
     srp_role_id,
     role_model_id,
     role_id,
     attain_tier_id,
     attain_schedule_id,
     quota_category_id,
     percent,
     payout,
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
     cn_srp_payout_dtls_s.nextval,
     p_srp_role_id,
     p_role_model_id,
     decode(p_role_id,mn,null,p_role_id),
     decode(p_attain_tier_id,mn,null,p_attain_tier_id),
     decode(p_attain_schedule_id,mn,null,p_attain_schedule_id),
     decode(p_quota_category_id,mn,null,p_quota_category_id),
     decode(p_percent,mn,null,p_percent),
     decode(p_payout,mn,null,p_payout),
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
  (p_SRP_payout_dtl_ID IN cn_srp_payout_dtls.SRP_payout_dtl_ID%TYPE,
   p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE,
   p_role_model_id IN cn_srp_payout_dtls.role_model_id%TYPE :=NULL,
   p_attain_tier_id IN cn_srp_payout_dtls.attain_tier_id%TYPE,
   p_role_id IN cn_srp_payout_dtls.role_id%TYPE,
   p_attain_schedule_id IN cn_srp_payout_dtls.attain_schedule_id%TYPE,
   p_quota_category_id IN cn_srp_payout_dtls.quota_category_id%TYPE,
   p_percent IN cn_srp_payout_dtls.percent%TYPE,
   p_payout IN cn_srp_payout_dtls.payout%TYPE,
   p_attribute_category IN cn_srp_payout_dtls.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_srp_payout_dtls.attribute1%TYPE := NULL,
   p_attribute2 IN cn_srp_payout_dtls.attribute2%TYPE := NULL,
   p_attribute3 IN cn_srp_payout_dtls.attribute3%TYPE := NULL,
   p_attribute4 IN cn_srp_payout_dtls.attribute4%TYPE := NULL,
   p_attribute5 IN cn_srp_payout_dtls.attribute5%TYPE := NULL,
   p_attribute6 IN cn_srp_payout_dtls.attribute6%TYPE := NULL,
   p_attribute7 IN cn_srp_payout_dtls.attribute7%TYPE := NULL,
   p_attribute8 IN cn_srp_payout_dtls.attribute8%TYPE := NULL,
   p_attribute9 IN cn_srp_payout_dtls.attribute9%TYPE := NULL,
   p_attribute10 IN cn_srp_payout_dtls.attribute10%TYPE := NULL,
   p_attribute11 IN cn_srp_payout_dtls.attribute11%TYPE := NULL,
   p_attribute12 IN cn_srp_payout_dtls.attribute12%TYPE := NULL,
   p_attribute13 IN cn_srp_payout_dtls.attribute13%TYPE := NULL,
   p_attribute14 IN cn_srp_payout_dtls.attribute14%TYPE := NULL,
   p_attribute15 IN cn_srp_payout_dtls.attribute15%TYPE := NULL,
   p_last_update_login IN cn_srp_payout_dtls.last_update_login%TYPE,
   p_last_update_date IN cn_srp_payout_dtls.last_update_date%TYPE,
   p_last_updated_by IN cn_srp_payout_dtls.last_updated_by%TYPE,
   p_object_version_number IN cn_srp_payout_dtls.object_version_number%TYPE) IS

   CURSOR l_old_csr IS
      SELECT *
	FROM cn_srp_payout_dtls
       WHERE srp_role_id = p_srp_role_id;

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

   UPDATE cn_srp_payout_dtls SET
    (percent,
     payout,
     quota_category_id,
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
        decode(p_percent, mn, l_old_rec.percent, p_percent),
        decode(p_payout, mn, l_old_rec.payout, p_payout),
        decode(p_quota_category_id, mn, l_old_rec.quota_category_id, p_quota_category_id),
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
       WHERE srp_role_id = p_srp_role_id and attain_tier_id = p_attain_tier_id
       and attain_schedule_id = p_attain_schedule_id;
END update_row;


PROCEDURE delete_row
  (p_srp_role_id         IN cn_srp_payout_dtls.srp_role_id%TYPE) IS
BEGIN
   DELETE FROM cn_srp_payout_dtls
     WHERE srp_role_id = p_srp_role_id;

END delete_row;

END CN_SRP_payout_dtlS_pkg;

/
