--------------------------------------------------------
--  DDL for Package Body CN_ROLE_MODELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_MODELS_PKG" AS
  /*$Header: cntrlmlb.pls 115.3 2002/01/28 20:05:31 pkm ship      $*/

PROCEDURE insert_row
  (P_ROLE_MODEL_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROLE_ID                     IN   NUMBER,
   P_NAME                        IN   VARCHAR2,
   P_DESCRIPTION                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SEQ 	                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_STATUS 	                 IN   VARCHAR2,
   P_ACTIVATE_STATUS             IN   VARCHAR2,
   P_CLUB_ELIGIBLE_FLAG	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OTE		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROUNDING_FACTOR             IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTAIN_SCHEDULE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_PLAN_LEVEL		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MIN		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MAX		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ESTIMATED_PAYOUT	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_SRP_ROLE_ID                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_START_DATE		         IN   DATE,
   P_END_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_SCENARIO_STATUS	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR)
IS
   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

BEGIN

   INSERT INTO cn_role_models(
     role_model_id,
     role_id,
     name,
     description,
     seq,
     status,
     activate_status,
     club_eligible_flag,
     ote,
     rounding_factor,
     attain_schedule_id,
     plan_level,
     quota_min,
     quota_max,
     estimated_payout,
     srp_role_id,
     start_date,
     end_date,
     scenario_status,
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
     decode(p_role_model_id, mn, cn_role_models_s.nextval,
            p_role_model_id),
     p_role_id,
     p_name,
     decode(p_description, mc, null, p_description),
     decode(p_seq, mn, null, p_seq),
     decode(p_status, mc, null, p_status),
     decode(p_activate_status, mc, null, p_activate_status),
     decode(p_club_eligible_flag, mc, 'N', p_club_eligible_flag),
     decode(p_ote, mn, null, p_ote),
     decode(p_rounding_factor, mn, null, p_rounding_factor),
     decode(p_attain_schedule_id, mn, null, p_attain_schedule_id),
     decode(p_plan_level, mn, null, p_plan_level),
     decode(p_quota_min, mn, null, p_quota_min),
     decode(p_quota_max, mn, null, p_quota_max),
     decode(p_estimated_payout, mn, null, p_estimated_payout),
     decode(p_srp_role_id, mn, null, p_srp_role_id),
     trunc(p_start_date),
     decode(p_end_date, md, null, trunc(p_end_date)),
     decode(p_scenario_status, mc, null, p_scenario_status),
     decode(p_srp_id, mn, null, p_srp_id),
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
  (P_ROLE_MODEL_ID	         IN   NUMBER,
   P_ROLE_ID                     IN   NUMBER   := FND_API.G_MISS_NUM,
   P_NAME                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_DESCRIPTION                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SEQ 	                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_STATUS 	                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ACTIVATE_STATUS             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_CLUB_ELIGIBLE_FLAG	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OTE		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROUNDING_FACTOR             IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTAIN_SCHEDULE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_PLAN_LEVEL		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MIN		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MAX		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ESTIMATED_PAYOUT	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_SRP_ROLE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_START_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_END_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_SCENARIO_STATUS	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
	FROM cn_role_models
       WHERE role_model_id = p_role_model_id;

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

   UPDATE cn_role_models SET
    (role_id,
     name,
     description,
     seq,
     status,
     activate_status,
     club_eligible_flag,
     ote,
     rounding_factor,
     attain_schedule_id,
     plan_level,
     quota_min,
     quota_max,
     estimated_payout,
     srp_role_id,
     start_date,
     end_date,
     scenario_status,
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
        decode(p_role_id, mn, l_old_rec.role_id, p_role_id),
        decode(p_name, mc, l_old_rec.name, p_name),
        decode(p_description, mc, l_old_rec.description, p_description),
        decode(p_seq, mn, l_old_rec.seq, p_seq),
        decode(p_status, mc, l_old_rec.status, p_status),
        decode(p_activate_status, mc, l_old_rec.activate_status,
               p_activate_status),
        decode(p_club_eligible_flag, mc, l_old_rec.club_eligible_flag,
               p_club_eligible_flag),
        decode(p_ote, mn, l_old_rec.ote, p_ote),
        decode(p_rounding_factor, mn, l_old_rec.rounding_factor,
               p_rounding_factor),
        decode(p_attain_schedule_id, mn, l_old_rec.attain_schedule_id,
               p_attain_schedule_id),
        decode(p_plan_level, mn, l_old_rec.plan_level, p_plan_level),
        decode(p_quota_min, mn, l_old_rec.quota_min, p_quota_min),
        decode(p_quota_max, mn, l_old_rec.quota_max, p_quota_max),
        decode(p_estimated_payout, mn, l_old_rec.estimated_payout,
               p_estimated_payout),
        decode(p_srp_role_id, mn, l_old_rec.srp_role_id, p_srp_role_id),
        decode(p_start_date, md, trunc(l_old_rec.start_date),
               trunc(p_start_date)),
        decode(p_end_date, md, trunc(l_old_rec.end_date), trunc(p_end_date)),
        decode(p_scenario_status, mc, l_old_rec.scenario_status,
               p_scenario_status),
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
        decode(p_object_version_number, mn,
                 l_old_rec.object_version_number, p_object_version_number+1),
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
       FROM dual)
     WHERE role_model_id = p_role_model_id;

END Update_Row;


PROCEDURE Delete_Row
  (P_ROLE_MODEL_ID           IN   NUMBER) IS
BEGIN
   DELETE FROM cn_role_models
     WHERE role_model_id = p_role_model_id;

END Delete_Row;

END cn_role_models_pkg;

/
