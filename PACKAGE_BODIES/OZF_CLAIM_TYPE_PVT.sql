--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_TYPE_PVT" AS
/* $Header: ozfvclmb.pls 120.3 2005/12/22 23:29:13 sshivali ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_Claim_Type_PVT';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Type
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Create_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
  ,x_claim_type_id     OUT NOCOPY NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Claim_Type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   l_claim_rec             claim_rec_type := p_claim_rec;

   l_object_version_number NUMBER := 1;

   l_claim_check           VARCHAR2(10);

   l_rowid                 VARCHAR2(80);

   -- Cursor to get the sequence for claim_type_id
   CURSOR c_claim_seq IS
   SELECT ozf_claim_types_all_b_s.NEXTVAL
     FROM DUAL;

   -- Cursor to validate the uniqueness of the claim_type_id
   CURSOR c_claim_count(cv_claim_type_id IN NUMBER) IS
   SELECT  'ANYTHING'
     FROM  ozf_claim_types_VL
     WHERE claim_type_id = cv_claim_type_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Claim_Type;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   Validate_Claim_Type(
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_claim_rec        => l_claim_rec
   );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


  -------------------------- insert --------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': insert');
  END IF;

  IF l_claim_rec.claim_type_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_claim_seq;
      FETCH c_claim_seq INTO l_claim_rec.claim_type_id;
      CLOSE c_claim_seq;

      -- Check the uniqueness of the identifier
      OPEN  c_claim_count(l_claim_rec.claim_type_id);
      FETCH c_claim_count INTO l_claim_check;
        -- Exit when the identifier uniqueness is established
        EXIT WHEN c_claim_count%ROWCOUNT = 0;
      CLOSE c_claim_count;
   END LOOP;
  END IF;

  BEGIN
    OZF_claim_types_All_PKG.INSERT_ROW (
      X_ROWID                   => l_rowid,
      X_CLAIM_TYPE_ID           => l_claim_rec.claim_type_id,
      X_OBJECT_VERSION_NUMBER   => l_object_version_number,
      X_REQUEST_ID              => FND_GLOBAL.conc_request_id,
      X_CREATED_FROM            => NULL,
      X_CLAIM_CLASS             => l_claim_rec.claim_class,
      X_SET_OF_BOOKS_ID         => l_claim_rec.set_of_books_id,
      X_POST_TO_GL_FLAG         => l_claim_rec.post_to_gl_flag,
      X_START_DATE              => l_claim_rec.start_date,
      X_END_DATE                => l_claim_rec.end_date,
      X_CREATION_SIGN           => l_claim_rec.creation_sign,
      X_GL_ID_DED_ADJ           => l_claim_rec.gl_id_ded_adj,
      X_GL_ID_DED_ADJ_CLEARING  => l_claim_rec.gl_id_ded_adj_clearing,
      X_GL_ID_DED_CLEARING      => l_claim_rec.gl_id_ded_clearing,
      X_GL_ID_ACCR_PROMO_LIAB   => l_claim_rec.gl_id_accr_promo_liab,
      X_TRANSACTION_TYPE        => l_claim_rec.transaction_type,
      X_CM_TRX_TYPE_ID          => l_claim_rec.cm_trx_type_id,
      X_DM_TRX_TYPE_ID          => l_claim_rec.dm_trx_type_id,
      X_CB_TRX_TYPE_ID          => l_claim_rec.cb_trx_type_id,
      X_WO_REC_TRX_ID           => l_claim_rec.wo_rec_trx_id,
      X_ADJ_REC_TRX_ID          => l_claim_rec.adj_rec_trx_id,
      X_ATTRIBUTE_CATEGORY      => l_claim_rec.attribute_category,
      X_ATTRIBUTE1              => l_claim_rec.attribute1,
      X_ATTRIBUTE2              => l_claim_rec.attribute2,
      X_ATTRIBUTE3              => l_claim_rec.attribute3,
      X_ATTRIBUTE4              => l_claim_rec.attribute4,
      X_ATTRIBUTE5              => l_claim_rec.attribute5,
      X_ATTRIBUTE6              => l_claim_rec.attribute6,
      X_ATTRIBUTE7              => l_claim_rec.attribute7,
      X_ATTRIBUTE8              => l_claim_rec.attribute8,
      X_ATTRIBUTE9              => l_claim_rec.attribute9,
      X_ATTRIBUTE10             => l_claim_rec.attribute10,
      X_ATTRIBUTE11             => l_claim_rec.attribute11,
      X_ATTRIBUTE12             => l_claim_rec.attribute12,
      X_ATTRIBUTE13             => l_claim_rec.attribute13,
      X_ATTRIBUTE14             => l_claim_rec.attribute14,
      X_ATTRIBUTE15             => l_claim_rec.attribute15,
      X_NAME                    => l_claim_rec.name,
      X_DESCRIPTION             => l_claim_rec.description,
      X_CREATION_DATE           => SYSDATE,
      X_CREATED_BY              => NVL(FND_GLOBAL.user_id, -1),
      X_LAST_UPDATE_DATE        => SYSDATE,
      X_LAST_UPDATED_BY         => NVL(FND_GLOBAL.user_id, -1),
      X_LAST_UPDATE_LOGIN       => NVL(FND_GLOBAL.conc_login_id, -1),
      x_adjustment_type         => l_claim_rec.adjustment_type,
      X_ORDER_TYPE_ID          => l_claim_rec.order_type_id,
      X_NEG_WO_REC_TRX_ID      => l_claim_rec.neg_wo_rec_trx_id,
      X_GL_BALANCING_FLEX_VALUE      => l_claim_rec.gl_balancing_flex_value,
      X_ORG_ID                      => l_claim_rec.org_id  -- R12 Enhancement
    );
  EXCEPTION
    WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;


  ------------------------- finish -------------------------------
  x_claim_type_id := l_claim_rec.claim_type_id;

  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Claim_Type;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN OTHERS THEN
      ROLLBACK TO Create_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
    THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_Claim_Type;


---------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Type
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
--    02/05/2001  MCHANG  Add checking: Claim Type can't be deleted if it
--                                      is using by an existing claim.
---------------------------------------------------------------
PROCEDURE Delete_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_type_id     IN  NUMBER
  ,p_claim_org_id      IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Claim_Type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_cLaim_check          VARCHAR2(10);
   l_claim_using_check    NUMBER;
   -- Cursor to validate the existing of the record to be deleted
   CURSOR c_claim_count(cv_claim_type_id IN NUMBER, cv_obj_ver_num IN NUMBER) IS
   SELECT  COUNT(claim_type_id)
     FROM  ozf_claim_types_VL
     WHERE claim_type_id = cv_claim_type_id
     AND   object_version_number = cv_obj_ver_num;

   CURSOR c_claim_using(cv_claim_type_id IN NUMBER) IS
   SELECT  claim_id
     FROM  ozf_claims
     WHERE claim_type_id = cv_claim_type_id;

   CURSOR c_adjustment_using(cv_adjustment_type_id IN NUMBER) IS
   SELECT  utilization_id
     FROM  ozf_funds_utilized_vl
     WHERE adjustment_type_id = cv_adjustment_type_id;

   CURSOR c_approval_using(cv_claim_type_id IN VARCHAR2) IS
   SELECT approval_detail_id
   FROM   ams_approval_details
   WHERE  approval_object_type = cv_claim_type_id
     AND  approval_object IN ('FUND','CLAM')
     AND  approval_type IN ('BUDGET','CLAIM');
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Claim_Type;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   -- Adjustment types cannot be deleted if the claim_type_id is less than 0
   IF p_claim_type_id < 0 THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       -- FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_NO_DEL');
       FND_MESSAGE.set_name('OZF', 'OZF_ADJ_TYPE_NO_DEL');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(p_claim_type_id ||': p_claim_type_id');
      OZF_Utility_PVT.debug_message(p_object_version ||': p_object_version');
   END IF;

   OPEN  c_claim_count(p_claim_type_id, p_object_version);
   FETCH c_claim_count INTO l_claim_check;
   IF (c_claim_count%ROWCOUNT = 0) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     CLOSE c_claim_count;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_claim_count;

   -- Claim Type cannot be deleted if it is using by an existing claim.
   OPEN  c_claim_using(p_claim_type_id);
   FETCH c_claim_using INTO l_claim_using_check;
   IF (c_claim_using%ROWCOUNT > 0) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_USED');
       FND_MSG_PUB.add;
     END IF;
     CLOSE c_claim_using;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_claim_using;

   -- Adjustment Type cannot be deleted if it is using by an funds utilized rec.
   OPEN c_adjustment_using(p_claim_type_id);
   FETCH c_adjustment_using INTO l_claim_using_check;
   IF (c_adjustment_using%ROWCOUNT > 0) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_ADJ_USED');
       FND_MSG_PUB.add;
     END IF;
     CLOSE c_adjustment_using;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_adjustment_using;

   -- Claim Types can not be deleted when used in approval rules.
   OPEN c_approval_using(p_claim_type_id);
   FETCH c_approval_using INTO l_claim_using_check;
   IF (c_approval_using%ROWCOUNT > 0) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_APPROVAL_USED');
       FND_MSG_PUB.add;
     END IF;
     CLOSE c_approval_using;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_approval_using;


  IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_claim_using_check ||': not aaaa using by any claim');
   END IF;


   BEGIN
       OZF_claim_types_All_PKG.DELETE_ROW (
           X_CLAIM_TYPE_ID  => p_claim_type_id,
	   X_ORG_ID  => p_claim_org_id
       );


   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(': After deleting');
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Claim_Type;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
    THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Delete_Claim_Type;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Type
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
----------------------------------------------------------------------
PROCEDURE Update_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
  ,p_mode              IN  VARCHAR2 := 'UPDATE'
  ,x_object_version    OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_Claim_Type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_p_claim_rec     claim_rec_type  := p_claim_rec;
   l_claim_rec       claim_rec_type;
   l_return_status   VARCHAR2(1);
   l_object_version  NUMBER;
   l_claim_check          VARCHAR2(10);
   -- Cursor to validate the existing of the record to be updated
   CURSOR c_claim_count(cv_claim_type_id IN NUMBER, cv_obj_ver_num IN NUMBER) IS
   SELECT  COUNT(claim_type_id)
     FROM  ozf_claim_types_VL
     WHERE claim_type_id = cv_claim_type_id
     AND   object_version_number = cv_obj_ver_num;

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_Claim_Type;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   ----------------------- validate ----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   OPEN  c_claim_count(p_claim_rec.claim_type_id, p_claim_rec.object_version_number);
   FETCH c_claim_count INTO l_claim_check;
   IF (c_claim_count%ROWCOUNT = 0) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
       END IF;
       CLOSE c_claim_count;
       RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_claim_count;

   -- Adjustment types cannot be updated if the claim_type_id is less than 0
   IF p_claim_rec.claim_type_id < 0 THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       --FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_NO_UPDATE');
       FND_MESSAGE.set_name('OZF', 'OZF_ADJ_TYPE_NO_UPDATE');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_Claim_Type_Rec(p_claim_rec, l_claim_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Claim_Type_Items(
         p_claim_rec       => l_claim_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Claim_Type_Record(
         p_claim_rec       => p_claim_rec,
         p_complete_rec    => l_claim_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   l_object_version := l_claim_rec.object_version_number + 1;
   -------------------------- update --------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': KISH update');
   END IF;


   BEGIN
       OZF_claim_types_All_PKG.UPDATE_ROW (
          X_CLAIM_TYPE_ID          => l_claim_rec.claim_type_id,
          X_OBJECT_VERSION_NUMBER  => l_object_version,
          X_REQUEST_ID             => FND_GLOBAL.conc_request_id,
          X_CREATED_FROM           => l_claim_rec.created_from,
          X_CLAIM_CLASS            => l_claim_rec.claim_class,
          X_SET_OF_BOOKS_ID        => l_claim_rec.set_of_books_id,
          X_POST_TO_GL_FLAG        => l_claim_rec.post_to_gl_flag,
          X_START_DATE             => l_claim_rec.start_date,
          X_END_DATE               => l_claim_rec.end_date,
          X_CREATION_SIGN          => l_claim_rec.creation_sign,
          X_GL_ID_DED_ADJ          => l_claim_rec.gl_id_ded_adj,
          X_GL_ID_DED_ADJ_CLEARING => l_claim_rec.gl_id_ded_adj_clearing,
          X_GL_ID_DED_CLEARING     => l_claim_rec.gl_id_ded_clearing,
          X_GL_ID_ACCR_PROMO_LIAB  => l_claim_rec.gl_id_accr_promo_liab,
          X_TRANSACTION_TYPE       => l_claim_rec.transaction_type,
          X_CM_TRX_TYPE_ID         => l_claim_rec.cm_trx_type_id,
          X_DM_TRX_TYPE_ID         => l_claim_rec.dm_trx_type_id,
          X_CB_TRX_TYPE_ID         => l_claim_rec.cb_trx_type_id,
          X_WO_REC_TRX_ID          => l_claim_rec.wo_rec_trx_id,
          X_ADJ_REC_TRX_ID         => l_claim_rec.adj_rec_trx_id,
          X_ATTRIBUTE_CATEGORY     => l_claim_rec.attribute_category,
          X_ATTRIBUTE1             => l_claim_rec.attribute1,
          X_ATTRIBUTE2             => l_claim_rec.attribute2,
          X_ATTRIBUTE3             => l_claim_rec.attribute3,
          X_ATTRIBUTE4             => l_claim_rec.attribute4,
          X_ATTRIBUTE5             => l_claim_rec.attribute5,
          X_ATTRIBUTE6             => l_claim_rec.attribute6,
          X_ATTRIBUTE7             => l_claim_rec.attribute7,
          X_ATTRIBUTE8             => l_claim_rec.attribute8,
          X_ATTRIBUTE9             => l_claim_rec.attribute9,
          X_ATTRIBUTE10            => l_claim_rec.attribute10,
          X_ATTRIBUTE11            => l_claim_rec.attribute11,
          X_ATTRIBUTE12            => l_claim_rec.attribute12,
          X_ATTRIBUTE13            => l_claim_rec.attribute13,
          X_ATTRIBUTE14            => l_claim_rec.attribute14,
          X_ATTRIBUTE15            => l_claim_rec.attribute15,
          X_NAME                   => l_claim_rec.name,
          X_DESCRIPTION            => l_claim_rec.description,
          X_LAST_UPDATE_DATE       => SYSDATE,
          X_LAST_UPDATED_BY        => NVL(FND_GLOBAL.user_id,-1),
          X_LAST_UPDATE_LOGIN      => NVL(FND_GLOBAL.conc_login_id,-1),
          x_adjustment_type        => l_claim_rec.adjustment_type,
          X_ORDER_TYPE_ID         => l_claim_rec.order_type_id,
	  X_NEG_WO_REC_TRX_ID      => l_claim_rec.neg_wo_rec_trx_id,
	  X_GL_BALANCING_FLEX_VALUE  => l_claim_rec.gl_balancing_flex_value,
	  X_ORG_ID                  => l_claim_rec.org_id
       );
   EXCEPTION
     WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -------------------- finish --------------------------
   x_object_version := l_object_version;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Claim_Type;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Claim_Type;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
    THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Update_Claim_Type;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Type
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
--------------------------------------------------------------------
PROCEDURE Validate_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Claim_Type';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Claim_Type_Items(
         p_claim_rec       => p_claim_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Claim_Type_Record(
         p_claim_rec       => p_claim_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
    THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Validate_Claim_Type;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Req_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Req_Items(
   p_claim_rec       IN  claim_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ claim_class --------------------------
   IF p_claim_rec.claim_class IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.Set_Token('COLUMN', 'CLAIM_CLASS');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
 ------------------------ Adjustment type--------------------------
   ELSIF p_claim_rec.claim_class = 'ADJ' AND
         p_claim_rec.adjustment_type IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_ADJTYPE');
         FND_MESSAGE.Set_Token('COLUMN', 'ADJUSTMENT_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ set_of_books_id -------------------------------
   ELSIF p_claim_rec.set_of_books_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         /*
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
  		   FND_MESSAGE.Set_Token('COLUMN', 'SET_OF_BOOKS_ID');
         FND_MSG_PUB.add;
         */
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TYPE_NO_BOOKS');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ post_to_gl_flag -------------------------------
   ELSIF p_claim_rec.post_to_gl_flag IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.Set_Token('COLUMN', 'POST_TO_GL_GLAG');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ start_date -------------------------------
   ELSIF p_claim_rec.start_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.Set_Token('COLUMN', 'START_DATE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ name -------------------------------
   ELSIF p_claim_rec.name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.Set_Token('COLUMN', 'NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;

   END IF;

END Check_Claim_Type_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Uk_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Uk_Items(
   p_claim_rec       IN  claim_rec_type
  ,p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For Create_Claim_Type, when claim_type_id is passed in, we need to
   -- check if this claim_type_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_claim_rec.claim_type_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_uniqueness(
          'ozf_claim_types_VL',
        'claim_type_id = ' || p_claim_rec.claim_type_id
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUPLICATE_VALUE');
				FND_MESSAGE.set_token('COLLUMN', 'CLAIM_TYPE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

END Check_Claim_Type_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Fk_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Fk_Items(
   p_claim_rec       IN  claim_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_dummy           NUMBER;
   CURSOR  c_order_trx_type(cv_id NUMBER)
   IS
      SELECT 1
      FROM oe_transaction_types_vl
      WHERE transaction_type_id = cv_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   --Check the validity of OM Transaction type
   IF p_claim_rec.order_type_id IS NOT NULL THEN
      OPEN c_order_trx_type(p_claim_rec.order_type_id);
      FETCH c_order_trx_type INTO l_dummy;
      CLOSE c_order_trx_type;
      IF l_dummy <> 1 THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_OM_TRX_TYPE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;

   -- check other fk items

END Check_Claim_Type_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Lookup_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Lookup_Items(
   p_claim_rec       IN  claim_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- claim_class ------------------------
   IF p_claim_rec.claim_class <> FND_API.g_miss_char AND
      p_claim_rec.claim_class <> 'ADJ' THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_table_name => 'OZF_LOOKUPS',
            p_lookup_type => 'OZF_CLAIM_CLASS',
            p_lookup_code => p_claim_rec.claim_class
         ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_CLASS');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- creation_sign ------------------------
   IF p_claim_rec.creation_sign <> FND_API.g_miss_char THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_table_name => 'OZF_LOOKUPS',
            p_lookup_type => 'OZF_CREATION_SIGN',
            p_lookup_code => p_claim_rec.creation_sign
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_CREATION_SIGN');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other lookup codes

END Check_Claim_Type_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Flag_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Flag_Items(
   p_claim_rec       IN  claim_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- post_to_gl_flag ------------------------
   /*
   IF p_claim_rec.post_to_gl_flag <> FND_API.g_miss_char
      AND p_claim_rec.post_to_gl_flag IS NOT NULL
   THEN
      IF p_claim_rec.post_to_gl_flag <> FND_API.g_true
        AND p_claim_rec.post_to_gl_flag <> FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
				FND_MESSAGE.Set_Token('FLAG','POST_TO_GL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
   -- check other flags

END Check_Claim_Type_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Items
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_claim_rec       IN  claim_rec_type
)
IS
BEGIN

   Check_Claim_Type_Req_Items(
      p_claim_rec       => p_claim_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Claim_Type_Uk_Items(
      p_claim_rec       => p_claim_rec
     ,p_validation_mode => p_validation_mode
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Claim_Type_Fk_Items(
      p_claim_rec       => p_claim_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Claim_Type_Lookup_Items(
      p_claim_rec       => p_claim_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Claim_Type_Flag_Items(
      p_claim_rec       => p_claim_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Claim_Type_Items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Record
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Record(
   p_claim_rec        IN  claim_rec_type
  ,p_complete_rec     IN  claim_rec_type := NULL
  ,x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings
   -- End date validation.
   IF (p_claim_rec.end_date IS NOT NULL)
      AND (p_claim_rec.end_date <> FND_API.G_MISS_DATE) THEN
      IF p_claim_rec.start_date > p_claim_rec.end_date THEN
         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_TYPE_SD_GT_ED');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

END Check_Claim_Type_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Claim_Type_Rec
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Init_Claim_Type_Rec(
   x_claim_rec   OUT NOCOPY  claim_rec_type
)
IS
BEGIN


   RETURN;
END Init_Claim_Type_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Type_Rec
--
-- HISTORY
--    06/27/2000  Michelle Chang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Type_Rec(
   p_claim_rec IN  claim_rec_type
  ,x_complete_rec    OUT NOCOPY claim_rec_type
)
IS

   CURSOR c_claim IS
   SELECT *
     FROM  ozf_claim_types_VL
     WHERE claim_type_id = p_claim_rec.claim_type_id;

   l_claim_rec  c_claim%ROWTYPE;

BEGIN

   x_complete_rec := p_claim_rec;

   OPEN c_claim;
   FETCH c_claim INTO l_claim_rec;
   IF c_claim%NOTFOUND THEN
      CLOSE c_claim;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_claim;


IF p_claim_rec.object_version_number = FND_API.G_MISS_NUM  THEN
   x_complete_rec.object_version_number := NULL;
END IF;
IF p_claim_rec.object_version_number IS NULL THEN
   x_complete_rec.object_version_number := l_claim_rec.object_version_number;
END IF;

IF p_claim_rec.claim_class = FND_API.G_MISS_CHAR THEN
   x_complete_rec.claim_class := NULL;
END IF;
IF p_claim_rec.claim_class IS NULL THEN
   x_complete_rec.claim_class := l_claim_rec.claim_class;
END IF;

IF p_claim_rec.set_of_books_id = FND_API.G_MISS_NUM  THEN
   x_complete_rec.set_of_books_id := NULL;
END IF;
IF p_claim_rec.set_of_books_id IS NULL THEN
   x_complete_rec.set_of_books_id := l_claim_rec.set_of_books_id;
END IF;

IF p_claim_rec.post_to_gl_flag = FND_API.G_MISS_CHAR THEN
   x_complete_rec.post_to_gl_flag := NULL;
END IF;
IF p_claim_rec.post_to_gl_flag IS NULL THEN
   x_complete_rec.post_to_gl_flag := l_claim_rec.post_to_gl_flag;
END IF;

IF p_claim_rec.start_date = FND_API.G_MISS_DATE  THEN
   x_complete_rec.start_date := NULL;
END IF;
IF p_claim_rec.start_date IS NULL THEN
   x_complete_rec.start_date := l_claim_rec.start_date;
END IF;

IF p_claim_rec.end_date = FND_API.G_MISS_DATE THEN
   x_complete_rec.end_date := NULL;
END IF;
IF p_claim_rec.end_date IS NULL THEN
   x_complete_rec.end_date := l_claim_rec.end_date;
END IF;

IF p_claim_rec.creation_sign = FND_API.G_MISS_CHAR  THEN
   x_complete_rec.creation_sign := NULL;
END IF;
IF p_claim_rec.creation_sign IS NULL THEN
   x_complete_rec.creation_sign := l_claim_rec.creation_sign;
END IF;

IF p_claim_rec.gl_id_ded_adj = FND_API.G_MISS_NUM  THEN
   x_complete_rec.gl_id_ded_adj := NULL;
END IF;
IF p_claim_rec.gl_id_ded_adj IS NULL THEN
   x_complete_rec.gl_id_ded_adj := l_claim_rec.gl_id_ded_adj;
END IF;

IF p_claim_rec.gl_id_ded_adj_clearing = FND_API.G_MISS_NUM  THEN
   x_complete_rec.gl_id_ded_adj_clearing := NULL;
END IF;
IF p_claim_rec.gl_id_ded_adj_clearing IS NULL THEN
   x_complete_rec.gl_id_ded_adj_clearing := l_claim_rec.gl_id_ded_adj_clearing;
END IF;

IF p_claim_rec.gl_id_ded_clearing = FND_API.G_MISS_NUM  THEN
   x_complete_rec.gl_id_ded_clearing := NULL;
END IF;
IF p_claim_rec.gl_id_ded_clearing IS NULL THEN
   x_complete_rec.gl_id_ded_clearing := l_claim_rec.gl_id_ded_clearing;
END IF;

IF p_claim_rec.gl_id_accr_promo_liab = FND_API.G_MISS_NUM  THEN
   x_complete_rec.gl_id_accr_promo_liab := NULL;
END IF;
IF p_claim_rec.gl_id_accr_promo_liab IS NULL THEN
   x_complete_rec.gl_id_accr_promo_liab := l_claim_rec.gl_id_accr_promo_liab;
END IF;

IF p_claim_rec.transaction_type = FND_API.G_MISS_NUM THEN
   x_complete_rec.transaction_type := NULL;
END IF;
IF p_claim_rec.transaction_type IS NULL THEN
   x_complete_rec.transaction_type := l_claim_rec.transaction_type;
END IF;

IF p_claim_rec.cm_trx_type_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.cm_trx_type_id := NULL;
END IF;
IF p_claim_rec.cm_trx_type_id IS NULL THEN
   x_complete_rec.cm_trx_type_id := l_claim_rec.cm_trx_type_id;
END IF;

IF p_claim_rec.dm_trx_type_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.dm_trx_type_id := NULL;
END IF;
IF p_claim_rec.dm_trx_type_id IS NULL THEN
   x_complete_rec.dm_trx_type_id := l_claim_rec.dm_trx_type_id;
END IF;

IF p_claim_rec.cb_trx_type_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.cb_trx_type_id := NULL;
END IF;
IF p_claim_rec.cb_trx_type_id IS NULL THEN
   x_complete_rec.cb_trx_type_id := l_claim_rec.cb_trx_type_id;
END IF;

IF p_claim_rec.wo_rec_trx_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.wo_rec_trx_id := NULL;
END IF;
IF p_claim_rec.wo_rec_trx_id IS NULL THEN
   x_complete_rec.wo_rec_trx_id := l_claim_rec.wo_rec_trx_id;
END IF;

IF p_claim_rec.adj_rec_trx_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.adj_rec_trx_id := NULL;
END IF;
IF p_claim_rec.adj_rec_trx_id IS NULL THEN
   x_complete_rec.adj_rec_trx_id := l_claim_rec.adj_rec_trx_id;
END IF;

IF p_claim_rec.attribute_category = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute_category := NULL;
END IF;
IF p_claim_rec.attribute_category IS NULL THEN
   x_complete_rec.attribute_category := l_claim_rec.attribute_category;
END IF;

IF p_claim_rec.attribute1 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute1 := NULL;
END IF;
IF p_claim_rec.attribute1 IS NULL THEN
   x_complete_rec.attribute1 := l_claim_rec.attribute1;
END IF;

IF p_claim_rec.attribute2 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute2 := NULL;
END IF;
IF p_claim_rec.attribute2 IS NULL THEN
   x_complete_rec.attribute2 := l_claim_rec.attribute2;
END IF;

IF p_claim_rec.attribute3 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute3 := NULL;
END IF;
IF p_claim_rec.attribute3 IS NULL THEN
   x_complete_rec.attribute3 := l_claim_rec.attribute3;
END IF;

IF p_claim_rec.attribute4 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute4 := NULL;
END IF;
IF p_claim_rec.attribute4 IS NULL THEN
   x_complete_rec.attribute4 := l_claim_rec.attribute4;
END IF;

IF p_claim_rec.attribute5 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute5 := NULL;
END IF;
IF p_claim_rec.attribute5 IS NULL THEN
   x_complete_rec.attribute5 := l_claim_rec.attribute5;
END IF;

IF p_claim_rec.attribute6 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute6 := NULL;
END IF;
IF p_claim_rec.attribute6 IS NULL THEN
   x_complete_rec.attribute6 := l_claim_rec.attribute6;
END IF;

IF p_claim_rec.attribute7 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute7 := NULL;
END IF;
IF p_claim_rec.attribute7 IS NULL THEN
   x_complete_rec.attribute7 := l_claim_rec.attribute7;
END IF;

IF p_claim_rec.attribute8 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute8 := NULL;
END IF;
IF p_claim_rec.attribute8 IS NULL THEN
   x_complete_rec.attribute8 := l_claim_rec.attribute8;
END IF;

IF p_claim_rec.attribute9 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute9 := NULL;
END IF;
IF p_claim_rec.attribute9 IS NULL THEN
   x_complete_rec.attribute9 := l_claim_rec.attribute9;
END IF;

IF p_claim_rec.attribute10 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute10 := NULL;
END IF;
IF p_claim_rec.attribute10 IS NULL THEN
   x_complete_rec.attribute10 := l_claim_rec.attribute10;
END IF;

IF p_claim_rec.attribute11 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute11 := NULL;
END IF;
IF p_claim_rec.attribute11 IS NULL THEN
   x_complete_rec.attribute11 := l_claim_rec.attribute11;
END IF;

IF p_claim_rec.attribute12 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute12 := NULL;
END IF;
IF p_claim_rec.attribute12 IS NULL THEN
   x_complete_rec.attribute12 := l_claim_rec.attribute12;
END IF;

IF p_claim_rec.attribute13 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute13 := NULL;
END IF;
IF p_claim_rec.attribute13 IS NULL THEN
   x_complete_rec.attribute13 := l_claim_rec.attribute13;
END IF;

IF p_claim_rec.attribute14 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute14 := NULL;
END IF;
IF p_claim_rec.attribute14 IS NULL THEN
   x_complete_rec.attribute14 := l_claim_rec.attribute14;
END IF;

IF p_claim_rec.attribute15 = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute15 := NULL;
END IF;
IF p_claim_rec.attribute15 IS NULL THEN
   x_complete_rec.attribute15 := l_claim_rec.attribute15;
END IF;

IF p_claim_rec.name = FND_API.G_MISS_CHAR THEN
   x_complete_rec.name := NULL;
END IF;
IF p_claim_rec.name IS NULL THEN
   x_complete_rec.name := l_claim_rec.name;
END IF;

IF p_claim_rec.description = FND_API.G_MISS_CHAR THEN
   x_complete_rec.description := NULL;
END IF;
IF p_claim_rec.description IS NULL THEN
   x_complete_rec.description := l_claim_rec.description;
END IF;

IF p_claim_rec.adjustment_type = FND_API.G_MISS_CHAR THEN
   x_complete_rec.adjustment_type := NULL;
END IF;
IF p_claim_rec.adjustment_type IS NULL THEN
   x_complete_rec.adjustment_type := l_claim_rec.adjustment_type;
END IF;

IF p_claim_rec.order_type_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.order_type_id := NULL;
END IF;
IF p_claim_rec.order_type_id IS NULL THEN
   x_complete_rec.order_type_id := l_claim_rec.order_type_id;
END IF;

IF p_claim_rec.neg_wo_rec_trx_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.neg_wo_rec_trx_id := NULL;
END IF;
IF p_claim_rec.neg_wo_rec_trx_id IS NULL THEN
   x_complete_rec.neg_wo_rec_trx_id := l_claim_rec.neg_wo_rec_trx_id;
END IF;

IF p_claim_rec.gl_balancing_flex_value = FND_API.G_MISS_CHAR THEN
   x_complete_rec.gl_balancing_flex_value := NULL;
END IF;
IF p_claim_rec.gl_balancing_flex_value IS NULL THEN
   x_complete_rec.gl_balancing_flex_value := l_claim_rec.gl_balancing_flex_value;
END IF;


END Complete_Claim_Type_Rec;


END OZF_Claim_Type_PVT;

/
