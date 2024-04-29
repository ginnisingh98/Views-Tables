--------------------------------------------------------
--  DDL for Package Body OZF_ACT_OFFERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACT_OFFERS_PVT" AS
/* $Header: ozfvoffb.pls 120.0 2005/06/01 01:54:23 appldev noship $ */

g_pkg_name   CONSTANT VARCHAR2(30) := 'OZF_Act_Offers_PVT';


/*****************************************************************************/
-- Procedure: create_act_offer
--
-- History
--    01/12/2000  julou  created
--    04/11/2000  holiu  add new columns
--   16-May-2000  choang Replaced call to get_source_code with get_new_source_code
--                       to implement new source code generation algorithm.
--   06-Jun-2000  ptendulk Revert back to old source code api
-------------------------------------------------------------------------------
PROCEDURE Create_Act_Offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type,
   x_act_offer_id        OUT NOCOPY NUMBER
)
IS

   CURSOR c_offer_code(l_id NUMBER) IS
   SELECT offer_code
     FROM ozf_offers
    WHERE qp_list_header_id = l_id;

   l_api_version       CONSTANT NUMBER := 1.0;
   l_api_name          CONSTANT VARCHAR2(30) := 'create_act_offer';
   l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_msg_data          VARCHAR2(2000);
   l_msg_count         NUMBER;
   l_return_status     VARCHAR2(1);
   l_act_offer_rec     act_offer_rec_type := p_act_offer_rec;
   l_act_offer_count   NUMBER;
   l_sourcecode_id     NUMBER;
   l_custom_setup_id   NUMBER;
   l_offer_code        VARCHAR2(30);
/*
   CURSOR c_custom_setup IS
   SELECT custom_setup_id
     FROM ams_custom_setups_vl
    WHERE object_type = 'OFFR'
      AND activity_type_code = p_act_offer_rec.offer_type;
*/
   CURSOR c_act_offer_seq IS
   SELECT ozf_act_offers_s.NEXTVAL
     FROM DUAL;

   CURSOR c_act_offer_count(act_offer_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ozf_act_offers
    WHERE activity_offer_id = act_offer_id;

BEGIN

   -- initialize
   SAVEPOINT create_act_offer;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
/*
   OPEN c_custom_setup;
   FETCH c_custom_setup INTO l_custom_setup_id;
   CLOSE c_custom_setup;
*/
   -- validate
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      validate_act_offer
      (
         p_api_version       => l_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_validation_level  => p_validation_level,
         x_return_status     => l_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_act_offer_rec     => l_act_offer_rec
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- insert
   --MY_Utility_PVT.debug_message(l_full_name || ': insert');

   IF l_act_offer_rec.activity_offer_id IS NULL THEN
      LOOP
         OPEN c_act_offer_seq;
         FETCH c_act_offer_seq INTO l_act_offer_rec.activity_offer_id;
         CLOSE c_act_offer_seq;

         OPEN c_act_offer_count(l_act_offer_rec.activity_offer_id);
         FETCH c_act_offer_count INTO l_act_offer_count;
         CLOSE c_act_offer_count;

         EXIT WHEN l_act_offer_count = 0;
      END LOOP;
   END IF;
/*
   -- default offer_code from AMS_SOURCE_CODES
   IF l_act_offer_rec.offer_code IS NULL THEN   -- need a new offer_code
   --========================================================================
   -- Following source generation code is revert back to old source code
   -- generation api by ptendulk on 06-Jun-2000 As the new api will only
   -- be available with R2
   --========================================================================
      --
      -- choang - 16-May-2000
      -- Modified to use new source code generation
      -- function for internal rollout requirement #20.
      -- NOTE: Need to implement global flag.]
--      l_act_offer_rec.offer_code := AMS_SourceCode_PVT.get_new_source_code (
--         p_object_type  => 'OFFR',
--         p_custsetup_id => l_custom_setup_id,
--         p_global_flag  => FND_API.g_false
--        );
      l_act_offer_rec.offer_code := AMS_SourceCode_PVT.get_source_code
       (
          'OFFR',
          l_act_offer_rec.offer_type
        );
   END IF;
*/
   -- set primary_offer_flag to default value
   IF l_act_offer_rec.primary_offer_flag IS NULL
      OR l_act_offer_rec.primary_offer_flag = FND_API.g_miss_char
   THEN
      l_act_offer_rec.primary_offer_flag := 'N';
   END IF;

   OPEN c_offer_code(l_act_offer_rec.qp_list_header_id);
   FETCH c_offer_code INTO l_offer_code;
   CLOSE c_offer_code;

   INSERT INTO OZF_ACT_OFFERS
   (
      activity_offer_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      act_offer_used_by_id,
      arc_act_offer_used_by,
      primary_offer_flag,
--      offer_type,
      offer_code,
      active_period_set,
      active_period,
--      start_date,
--      end_date,
--      order_date_from,
--      order_date_to,
--      ship_date_from,
--      ship_date_to,
--      perf_date_from,
--      perf_date_to,
--      status_code,
--      status_date,
--      offer_amount,
--      lumpsum_payment_type,
      qp_list_header_id
   )
   VALUES
   (
      l_act_offer_rec.activity_offer_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,
      l_act_offer_rec.act_offer_used_by_id,
      l_act_offer_rec.arc_act_offer_used_by,
      l_act_offer_rec.primary_offer_flag,
--      l_act_offer_rec.offer_type,
      l_offer_code,
      l_act_offer_rec.active_period_set,
      l_act_offer_rec.active_period,
--      l_act_offer_rec.start_date,
--      l_act_offer_rec.end_date,
--      l_act_offer_rec.order_date_from,
--      l_act_offer_rec.order_date_to,
--      l_act_offer_rec.ship_date_from,
--      l_act_offer_rec.ship_date_to,
--      l_act_offer_rec.perf_date_from,
--      l_act_offer_rec.perf_date_to,
--      l_act_offer_rec.status_code,
--      l_act_offer_rec.status_date,
--      l_act_offer_rec.offer_amount,
--      l_act_offer_rec.lumpsum_payment_type,
      l_act_offer_rec.qp_list_header_id
   );

   -- insert offer_code into AMS_SOURCE_CODES
   -- commented by julou 05/03/2001. offer_code is gone
/*   AMS_SourceCode_PVT.create_sourcecode(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,

      p_sourcecode         => l_act_offer_rec.offer_code,
      p_sourcecode_for     => 'OFFR',
      p_sourcecode_for_id  => l_act_offer_rec.activity_offer_id,
      x_sourcecode_id      => l_sourcecode_id
    );
*/
-- end of comment

   -- added by julou on 03/08/2000
   -- indicate offer has been defined for the campaign
/*   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => l_act_offer_rec.arc_act_offer_used_by,
      p_object_id          => l_act_offer_rec.act_offer_used_by_id,
      p_attr               => 'OFFR',
      p_attr_defined_flag  => 'Y'
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; */

   -- create attributes for this offer
   -- commented by julou 05/03/2001. custom_setup_id is gone
   /*
   IF l_custom_setup_id IS NOT NULL THEN
      AMS_ObjectAttribute_PVT.create_object_attributes(
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.g_false,
         p_commit            => FND_API.g_false,
         p_validation_level  => FND_API.g_valid_level_full,
         x_return_status     => l_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_object_type       => 'OFFR',
         p_object_id         => l_act_offer_rec.activity_offer_id,
         p_setup_id          => l_custom_setup_id
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
*/
-- end of comment

   -- finish
   x_act_offer_id := l_act_offer_rec.activity_offer_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get
   (
      p_encoded  => FND_API.g_false,
      p_count    => x_msg_count,
      p_data     => x_msg_data
   );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_act_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_act_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO create_act_offer;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );
END Create_Act_Offer;


/*****************************************************************************/
-- Procedure: update_act_offer
--
-- History
--    01/12/2000  julou  created
--    01/14/2000  ptendulk  modified
--    04/11/2000  holiu  add new columns
-------------------------------------------------------------------------------
PROCEDURE Update_Act_Offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type
)
IS

   l_api_version     CONSTANT NUMBER := 1.0;
   l_api_name        CONSTANT VARCHAR2(30) := 'update_act_offer';
   l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_msg_data        VARCHAR2(2000);
   l_msg_count       NUMBER;
   l_return_status   VARCHAR2(1);
   l_act_offer_rec   act_offer_rec_type := p_act_offer_rec;
   l_sourcecode_id   NUMBER;

BEGIN

   -- initialize
   SAVEPOINT update_act_offer;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- validate
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_items
      (
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status    => l_return_status,
         p_act_offer_rec    => l_act_offer_rec
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   complete_rec
   (
      p_act_offer_rec,
      l_act_offer_rec
   );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_record
      (
         p_act_offer_rec => p_act_offer_rec,
         p_complete_rec   => l_act_offer_rec,
         x_return_status => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- The second line below is modified by ptendulk on Jan 14th:
   -- if the flag is not sent for update, don't update it.

   -- set primary_offer_flag to default value
   IF l_act_offer_rec.primary_offer_flag IS NULL
   -- OR l_act_offer_rec.primary_offer_flag = FND_API.g_miss_char
   THEN
      l_act_offer_rec.primary_offer_flag := 'N';
   END IF;

   -- update
   UPDATE ozf_act_offers SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      object_version_number = l_act_offer_rec.object_version_number + 1,
      last_update_login = FND_GLOBAL.conc_login_id,
      act_offer_used_by_id = l_act_offer_rec.act_offer_used_by_id,
      arc_act_offer_used_by = l_act_offer_rec.arc_act_offer_used_by,
      primary_offer_flag = l_act_offer_rec.primary_offer_flag,
--      offer_type = l_act_offer_rec.offer_type,
--      offer_code = l_act_offer_rec.offer_code,
      active_period_set = l_act_offer_rec.active_period_set,
      active_period = l_act_offer_rec.active_period,
--      start_date = l_act_offer_rec.start_date,
--      end_date = l_act_offer_rec.end_date,
--      order_date_from = l_act_offer_rec.order_date_from,
--      order_date_to = l_act_offer_rec.order_date_to,
--      ship_date_from = l_act_offer_rec.ship_date_from,
--      ship_date_to = l_act_offer_rec.ship_date_to,
--      perf_date_from = l_act_offer_rec.perf_date_from,
--      perf_date_to = l_act_offer_rec.perf_date_to,
--      status_code = l_act_offer_rec.status_code,
--      status_date = l_act_offer_rec.status_date,
--      offer_amount = l_act_offer_rec.offer_amount,
--      lumpsum_payment_type = l_act_offer_rec.lumpsum_payment_type,
      qp_list_header_id = l_act_offer_rec.qp_list_header_id
   WHERE activity_offer_id = l_act_offer_rec.activity_offer_id
   AND object_version_number = l_act_offer_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- finish
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get
   (
      P_ENCODED => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_act_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_act_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_act_offer;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );
END Update_Act_Offer;


/*****************************************************************************/
-- Procedure: delete_act_offer
--
-- History
--    11/22/1999  julou  created
-------------------------------------------------------------------------------
PROCEDURE Delete_Act_Offer
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_offer_id      IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version    CONSTANT NUMBER := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'delete_act_offer';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_used_by_id     NUMBER;
   l_used_by        VARCHAR2(30);
   l_dummy          NUMBER;

   CURSOR c_used_by IS
   SELECT act_offer_used_by_id, arc_act_offer_used_by
     FROM ozf_act_offers
    WHERE activity_offer_id = p_act_offer_id;

   CURSOR c_offer IS
   SELECT 1
     FROM ozf_act_offers
    WHERE act_offer_used_by_id = l_used_by_id
      AND arc_act_offer_used_by = l_used_by;

BEGIN

   -- initialize
   SAVEPOINT delete_act_offer;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_used_by;
   FETCH c_used_by INTO l_used_by_id, l_used_by;
   CLOSE c_used_by;

   -- delete
   DELETE FROM OZF_ACT_OFFERS
   WHERE activity_offer_id = p_act_offer_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

/*   -- added by julou on 03/07/2000
   -- indicate if there is any other offers for this campaign
   OPEN c_offer;
   FETCH c_offer INTO l_dummy;
   CLOSE c_offer;

   IF l_dummy IS NULL THEN
      AMS_ObjectAttribute_PVT.modify_object_attribute(
          p_api_version        => l_api_version,
          p_init_msg_list      => FND_API.g_false,
          p_commit             => FND_API.g_false,
          p_validation_level   => FND_API.g_valid_level_full,

          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,

          p_object_type        => l_used_by,
          p_object_id          => l_used_by_id,
          p_attr               => 'OFFR',
          p_attr_defined_flag  => 'N'
      );

      IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF; */

   -- finish
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get
   (
      P_ENCODED => FND_API.g_false,
      p_count    => x_msg_count,
      p_data      => x_msg_data
   );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_act_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_act_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_act_offer;
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Delete_Act_Offer;


/*****************************************************************************/
-- Procedure: lock_act_offer
--
-- History
--    11/22/1999  julou  created
-------------------------------------------------------------------------------
PROCEDURE Lock_Act_Offer
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_offer_id      IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'lock_act_offer';
   l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_act_offer_id     NUMBER;

   CURSOR c_act_offer_b IS
   SELECT activity_offer_id
     FROM OZF_ACT_OFFERS
    WHERE activity_offer_id = p_act_offer_id
      AND object_version_number = p_object_version
   FOR UPDATE OF activity_offer_id NOWAIT;

BEGIN

   -- initialize
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- lock
   OPEN c_act_offer_b;
   FETCH c_act_offer_b INTO l_act_offer_id;
   IF (c_act_offer_b%NOTFOUND) THEN
      CLOSE c_act_offer_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_offer_b;

   -- finish
   FND_MSG_PUB.count_and_get
   (
      p_encoded => FND_API.g_false,
      p_count    => x_msg_count,
      p_data      => x_msg_data
   );

EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status :=FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );
END Lock_Act_Offer;


/*****************************************************************************/
-- Procedure: validate_act_offer
--
-- History
--    11/29/99      julou      Created.
-------------------------------------------------------------------------------
PROCEDURE Validate_Act_Offer
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.g_false,
   p_validation_level   IN  NUMBER := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_act_offer_rec      IN  act_offer_rec_type
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'validate_act_offer';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_items
      (
          p_validation_mode  => JTF_PLSQL_API.g_create,
          x_return_status    => l_return_status,
          p_act_offer_rec    => p_act_offer_rec
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- record level
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_record
      (
         p_act_offer_rec => p_act_offer_rec,
         p_complete_rec  => p_act_offer_rec,
         x_return_status => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get
   (
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get
      (
         p_encoded => FND_API.g_false,
         p_count    => x_msg_count,
         p_data      => x_msg_data
      );

  WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get
     (
        p_encoded => FND_API.g_false,
        p_count    => x_msg_count,
        p_data      => x_msg_data
     );
END Validate_Act_Offer;


/*****************************************************************************/
-- Procedure: check_req_items
--
-- History
--    11/22/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE Check_Req_Items
(
   p_validation_mode      IN         VARCHAR2,
   p_act_offer_rec         IN         act_offer_rec_type,
   x_return_status         OUT NOCOPY       VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

-- Following Code is Commented by PTENDULK as Activity Offer ID
-- can be null Also No need to send Object version Number
-- Date : 14Jan2000

-- check activity_offer_id
   IF p_act_offer_rec.activity_offer_id IS NULL
      AND p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_ACT_OFFER_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

--   check object_version_number
   IF p_act_offer_rec.object_version_number IS NULL
      AND p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

-- check act_offer_used_by_id
   IF p_act_offer_rec.act_offer_used_by_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_USED_BY_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

-- check arc_act_offer_used_by
   IF p_act_offer_rec.arc_act_offer_used_by IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_USED_BY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

-- check qp_list_header_id
   IF p_act_offer_rec.qp_list_header_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_LIST_HEAD_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Req_Items;


/*****************************************************************************/
-- Procedure: check_uk_items
--
-- History
--    11/22/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE Check_Uk_Items
(
   p_validation_mode      IN         VARCHAR2 := JTF_PLSQL_API.g_create,
   p_act_offer_rec         IN         act_offer_rec_type,
   x_return_status         OUT NOCOPY       VARCHAR2
)
IS

   l_uk_flag      VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
-- rssharma fixed bug # 2747282
-- don't allow adding duplicate offers to same campaign
-- check PK, if activity_offer_id is passed in, must check if it is duplicate
   IF p_validation_mode = JTF_PLSQL_API.g_create
--      AND p_act_offer_rec.activity_offer_id IS NOT NULL
   THEN
      l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
		    'OZF_ACT_OFFERS',
		    ' qp_list_header_id = ' || p_act_offer_rec.qp_list_header_id ||
		    ' AND act_offer_used_by_id = ' || p_act_offer_rec.act_offer_used_by_id ||
		    ' AND arc_act_offer_used_by = ' ||p_act_offer_rec.arc_act_offer_used_by
                         );
  ELSIF p_validation_mode = JTF_PLSQL_API.g_update
      AND p_act_offer_rec.activity_offer_id IS NOT NULL
   THEN
      l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
		    'OZF_ACT_OFFERS',
		    ' activity_offer_id <> '|| p_act_offer_rec.activity_offer_id ||
		    ' AND qp_list_header_id = ' || p_act_offer_rec.qp_list_header_id ||
		    ' AND act_offer_used_by_id = ' || p_act_offer_rec.act_offer_used_by_id ||
		    ' AND arc_act_offer_used_by = ' ||p_act_offer_rec.arc_act_offer_used_by
                         );

   END IF;

   IF l_uk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)	THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_DUP_OFFER_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
-- commented by julou 05/03/2001. offer_code is gone.
/*
-- check offer_code
   IF p_act_offer_rec.offer_code IS NOT NULL THEN
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
                            'AMS_SOURCE_CODES',
                            'source_code =   ''' || p_act_offer_rec.offer_code || ''''
                         );
      ELSE
         l_uk_flag := OZF_Utility_PVT.check_uniqueness
                         (
                            'AMS_SOURCE_CODES',
                            'source_code_for_id <> ' || p_act_offer_rec.activity_offer_id || ' AND '
                            || 'source_code =   ''' || p_act_offer_rec.offer_code || ''''
                         );
      END IF;
   END IF;

   IF l_uk_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_DUP_OFFER_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
*/
-- end of comment

END Check_Uk_Items;


/*****************************************************************************/
-- Procedure: check_fk_items
--
-- History
--    11/22/1999      julou	    created
--    01/14/2000      ptendulk	Modified
--    05/29/2001      julou     modified. CSCH is allowable now.
-------------------------------------------------------------------------------
PROCEDURE Check_Fk_Items
(
   p_act_offer_rec      IN         act_offer_rec_type,
   x_return_status      OUT NOCOPY       VARCHAR2
)
IS

   l_fk_flag          VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

-- Following Code Has been Modified by ptendulk
-- Validate   p_act_offer_rec.act_offer_used_by_id against View
-- check act_offer_used_by_id
   IF p_act_offer_rec.act_offer_used_by_id <> FND_API.g_miss_num
   AND
     p_act_offer_rec.act_offer_used_by_id IS NOT NULL
   THEN
     IF p_act_offer_rec.arc_act_offer_used_by = 'CAMP' THEN
       l_fk_flag := OZF_Utility_PVT.check_fk_exists
                         (
                            'AMS_CAMPAIGNS_VL',
                            'campaign_id',
                            p_act_offer_rec.act_offer_used_by_id
                         );
     ELSE
       IF p_act_offer_rec.arc_act_offer_used_by = 'CSCH' THEN
         l_fk_flag := OZF_Utility_PVT.check_fk_exists
                         (
                            'AMS_CAMPAIGN_SCHEDULES_VL',
                            'schedule_id',
                            p_act_offer_rec.act_offer_used_by_id
                         );
       END IF;
     END IF;

     IF l_fk_flag = FND_API.g_false THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_USED_BY_ID');
          FND_MSG_PUB.add;
       END IF;

       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
     END IF;
   END IF;

-- Following Code has been modified by ptendulk
-- Validate against QP_LIST_HEADERS_VL
-- check qp_list_header_id
   IF p_act_offer_rec.qp_list_header_id <> FND_API.g_miss_num THEN
      l_fk_flag := OZF_Utility_PVT.check_fk_exists
                         (
                            'QP_LIST_HEADERS_VL',
                            'list_header_id',
                            p_act_offer_rec.qp_list_header_id
                         );

      IF l_fk_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_LIST_HEAD_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Fk_Items;

/*****************************************************************************/
-- Procedure: check_lookup_items
--
-- History
--    11/22/1999      julou      created
--    01/14/2000	    ptendulk Modified
-------------------------------------------------------------------------------
PROCEDURE Check_Lookup_Items
(
   p_act_offer_rec    IN   act_offer_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

BEGIN

    x_return_status := FND_API.g_ret_sts_success;

-- Following Code has been Changed by ptendulk
-- as Only Campaign can create Offers

-- check arc_act_offer_used_by
--    IF p_act_offer_rec.arc_act_offer_used_by <> FND_API.g_miss_char
--       AND p_act_offer_rec.arc_act_offer_used_by NOT IN ('ECAM', 'MCAM', 'RCAM', 'CAMP')
--    THEN
--       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--          FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_USED_BY');
--          FND_MSG_PUB.add;
--       END IF;
    --OZF_UTILITY_PVT.debug_message(g_pkg_name||': check used_by');
    --OZF_UTILITY_PVT.debug_message('used by: ' || p_act_offer_rec.arc_act_offer_used_by);
    IF p_act_offer_rec.arc_act_offer_used_by <> FND_API.g_miss_char
       AND (p_act_offer_rec.arc_act_offer_used_by <> 'CAMP'
            AND p_act_offer_rec.arc_act_offer_used_by <> 'CSCH')
    THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_NO_USED_BY');
          FND_MSG_PUB.add;
       END IF;

       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
    END IF;
-- commented by julou 05/03/2001. offer_type, status_code, lumpsum_payment_type are gone
/*
-- check offer_type
    IF p_act_offer_rec.offer_type <> FND_API.g_miss_char
       AND p_act_offer_rec.offer_type IS NOT NULL
    THEN
         IF OZF_Utility_PVT.check_lookup_exists(
                  p_lookup_type => 'OZF_OFFER_TYPE',
                  p_lookup_code => p_act_offer_rec.offer_type
             ) = FND_API.g_false
         THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_BAD_OFFER_TYPE');
                  FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
         END IF;
    END IF;

-- check status_code
    IF p_act_offer_rec.status_code <> FND_API.g_miss_char
       AND p_act_offer_rec.status_code IS NOT NULL
    THEN
         IF OZF_Utility_PVT.check_lookup_exists(
                  p_lookup_type => 'OZF_OFFER_STATUS',
                  p_lookup_code => p_act_offer_rec.status_code
             ) = FND_API.g_false
         THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_BAD_STATUS');
                  FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
         END IF;
    END IF;

-- check lumpsum_payment_type
    IF p_act_offer_rec.lumpsum_payment_type <> FND_API.g_miss_char
       AND p_act_offer_rec.lumpsum_payment_type IS NOT NULL
    THEN
         IF OZF_Utility_PVT.check_lookup_exists(
                  p_lookup_type => 'OZF_OFFER_LUMPSUM_PAYMENT',
                  p_lookup_code => p_act_offer_rec.lumpsum_payment_type
             ) = FND_API.g_false
         THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_BAD_PAYMENT');
                  FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
         END IF;
    END IF;
*/
-- end of comment

END Check_Lookup_Items;


/*****************************************************************************/
-- Procedure: check_items
--
-- History
--    11/22/1999      julou      created
-------------------------------------------------------------------------------
PROCEDURE Check_Items
(
    p_validation_mode  IN  VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    p_act_offer_rec    IN  act_offer_rec_type
)
IS

   l_api_version    CONSTANT NUMBER := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'check_items';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check required items
   check_req_items
   (
      p_validation_mode => p_validation_mode,
      p_act_offer_rec      => p_act_offer_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check unique key items
   check_uk_items
   (
      p_validation_mode => p_validation_mode,
      p_act_offer_rec      => p_act_offer_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check foreign key items
   check_fk_items
   (
      p_act_offer_rec   => p_act_offer_rec,
      x_return_status => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check lookup items
   check_lookup_items
   (
      p_act_offer_rec   => p_act_offer_rec,
      x_return_status => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Items;


/*****************************************************************************/
-- Procedure: check_record
--
-- History
--    01/15/1999  julou  created
--    01/17/1999  julou  check if the campaign is active
--    01/26/2001  rssharma  fixed bug on active campaigns

-------------------------------------------------------------------------------
PROCEDURE Check_Record
(
   p_act_offer_rec    IN   act_offer_rec_type,
   p_complete_rec      IN   act_offer_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_active(used_by_id IN NUMBER) IS
      SELECT count(*) FROM AMS_CAMPAIGNS_VL
      WHERE campaign_id = used_by_id
      AND (actual_exec_end_date IS NULL
      -- changed by rssharma for bug fixing on 01/26/2001
      OR actual_exec_end_date >= trunc(SYSDATE) );


   CURSOR c_primary_offer_count1(used_by_id IN NUMBER, used_by IN VARCHAR2) IS
      SELECT COUNT(*) FROM OZF_ACT_OFFERS
      WHERE act_offer_used_by_id = used_by_id
         AND arc_act_offer_used_by = used_by
         AND primary_offer_flag = 'Y';

   CURSOR c_primary_offer_count2(act_offer_id IN NUMBER, used_by_id IN NUMBER, used_by IN VARCHAR2) IS
      SELECT COUNT(*) FROM OZF_ACT_OFFERS
      WHERE act_offer_used_by_id = used_by_id
         AND arc_act_offer_used_by = used_by
         AND activity_offer_id <> act_offer_id
         AND primary_offer_flag = 'Y';

   l_primary_offer_count   NUMBER;
   l_active                NUMBER;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

-- commented by julou 05/03/2001. These dates are gone
/*
   -- check offer dates
   IF p_complete_rec.start_date > p_complete_rec.end_date THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_OFFR_START_AFTER_END');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF p_complete_rec.order_date_from > p_complete_rec.order_date_to THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_OFFR_BAD_ORDER_DATES');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF p_complete_rec.ship_date_from > p_complete_rec.ship_date_to THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_OFFR_BAD_SHIP_DATES');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF p_complete_rec.perf_date_from > p_complete_rec.perf_date_to THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_OFFR_BAD_PERF_DATES');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
*/
   -- check if the campaign is active
   IF p_complete_rec.arc_act_offer_used_by = 'CAMP' THEN
      OPEN c_active(p_complete_rec.act_offer_used_by_id);
      FETCH c_active INTO l_active;
      CLOSE c_active;

      IF l_active = 0 THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_CAMP_EXPIRED');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check if the primary offer is unique
   IF p_complete_rec.primary_offer_flag = 'Y' THEN
      IF p_complete_rec.activity_offer_id IS NULL THEN
         OPEN c_primary_offer_count1(p_complete_rec.act_offer_used_by_id, p_complete_rec.arc_act_offer_used_by);
         FETCH c_primary_offer_count1 INTO l_primary_offer_count;
         IF l_primary_offer_count <> 0 THEN
            CLOSE c_primary_offer_count1;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_PRI_OFFER_EXISTS');
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
         CLOSE c_primary_offer_count1;
      ELSE
         OPEN c_primary_offer_count2(p_complete_rec.activity_offer_id, p_complete_rec.act_offer_used_by_id, p_complete_rec.arc_act_offer_used_by);
         FETCH c_primary_offer_count2 INTO l_primary_offer_count;
         IF l_primary_offer_count <> 0 THEN
            CLOSE c_primary_offer_count2;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_ACT_OFFER_PRI_OFFER_EXISTS');
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
         CLOSE c_primary_offer_count2;
      END IF;
   END IF;

END Check_Record;

/*****************************************************************************/
-- Procedure: complete_rec
--
-- History
--    12/19/1999  julou     Created.
--    04/11/2000  holiu     Added new columns.
--    06/08/2000  ptendulk  Added condition for column primary offer flag
-------------------------------------------------------------------------------
PROCEDURE Complete_Rec
(
   p_act_offer_rec   IN  act_offer_rec_type,
   x_complete_rec    OUT NOCOPY act_offer_rec_type
)
IS

   CURSOR c_act_offer IS
   SELECT *
     FROM ozf_act_offers
    WHERE activity_offer_id = p_act_offer_rec.activity_offer_id;

   l_act_offer_rec  c_act_offer%ROWTYPE;

BEGIN

   x_complete_rec := p_act_offer_rec;

   OPEN c_act_offer;
   FETCH c_act_offer INTO l_act_offer_rec;
   IF (c_act_offer%NOTFOUND) THEN
      CLOSE c_act_offer;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_offer;

   IF p_act_offer_rec.act_offer_used_by_id = FND_API.g_miss_num THEN
      x_complete_rec.act_offer_used_by_id := l_act_offer_rec.act_offer_used_by_id;
   END IF;

   IF p_act_offer_rec.arc_act_offer_used_by = FND_API.g_miss_char THEN
      x_complete_rec.arc_act_offer_used_by := l_act_offer_rec.arc_act_offer_used_by;
   END IF;
-- commented by julou 05/03/2001. offer_type and offer_code are gone.
/*
   IF p_act_offer_rec.offer_type = FND_API.g_miss_char THEN
      x_complete_rec.offer_type := l_act_offer_rec.offer_type;
   END IF;

   IF p_act_offer_rec.offer_code = FND_API.g_miss_char THEN
      x_complete_rec.offer_code := l_act_offer_rec.offer_code;
   END IF;
*/
   -- ==================================================================
   -- Following line of code is added by ptendulk on 08Jun2000
   -- Check for the primary offer Flag
   -- =================================================================
   IF p_act_offer_rec.primary_offer_flag = FND_API.g_miss_char THEN
      x_complete_rec.primary_offer_flag := l_act_offer_rec.primary_offer_flag ;
   END IF;

   IF p_act_offer_rec.active_period_set = FND_API.g_miss_char THEN
      x_complete_rec.active_period_set := l_act_offer_rec.active_period_set;
   END IF;

   IF p_act_offer_rec.active_period = FND_API.g_miss_char THEN
      x_complete_rec.active_period := l_act_offer_rec.active_period;
   END IF;
-- commented by julou 05/03/2001. These dates are gone.
/*
   IF p_act_offer_rec.start_date = FND_API.g_miss_date THEN
      x_complete_rec.start_date := l_act_offer_rec.start_date;
   END IF;

   IF p_act_offer_rec.end_date = FND_API.g_miss_date THEN
      x_complete_rec.end_date := l_act_offer_rec.end_date;
   END IF;

   IF p_act_offer_rec.order_date_from = FND_API.g_miss_date THEN
      x_complete_rec.order_date_from := l_act_offer_rec.order_date_from;
   END IF;

   IF p_act_offer_rec.order_date_to = FND_API.g_miss_date THEN
      x_complete_rec.order_date_to := l_act_offer_rec.order_date_to;
   END IF;

   IF p_act_offer_rec.ship_date_from = FND_API.g_miss_date THEN
      x_complete_rec.ship_date_from := l_act_offer_rec.ship_date_from;
   END IF;

   IF p_act_offer_rec.ship_date_to = FND_API.g_miss_date THEN
      x_complete_rec.ship_date_to := l_act_offer_rec.ship_date_to;
   END IF;

   IF p_act_offer_rec.perf_date_from = FND_API.g_miss_date THEN
      x_complete_rec.perf_date_from := l_act_offer_rec.perf_date_from;
   END IF;

   IF p_act_offer_rec.perf_date_to = FND_API.g_miss_date THEN
      x_complete_rec.perf_date_to := l_act_offer_rec.perf_date_to;
   END IF;

   IF p_act_offer_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_act_offer_rec.status_code;
   END IF;

   IF p_act_offer_rec.status_date = FND_API.g_miss_date
      OR p_act_offer_rec.status_date IS NULL
   THEN
      IF x_complete_rec.status_code = l_act_offer_rec.status_code THEN
      -- no status change, set it to be the original value
         x_complete_rec.status_date := l_act_offer_rec.status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.status_date := SYSDATE;
      END IF;
   END IF;

   IF p_act_offer_rec.offer_amount = FND_API.g_miss_num THEN
      x_complete_rec.offer_amount := l_act_offer_rec.offer_amount;
   END IF;

   IF p_act_offer_rec.lumpsum_payment_type = FND_API.g_miss_char THEN
      x_complete_rec.lumpsum_payment_type := l_act_offer_rec.lumpsum_payment_type;
   END IF;
  */
  -- end of comment
   IF p_act_offer_rec.qp_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.qp_list_header_id := l_act_offer_rec.qp_list_header_id;
   END IF;

END Complete_Rec;


/****************************************************************************/
-- Procedure: init_rec
--
-- History
--    12/19/1999  julou  Created.
--    04/11/2000  holiu  Added new columns.
------------------------------------------------------------------------------
PROCEDURE Init_Rec
(
   x_act_offer_rec  OUT NOCOPY act_offer_rec_type
)
IS

BEGIN

   x_act_offer_rec.activity_offer_id := FND_API.g_miss_num;
   x_act_offer_rec.last_update_date := FND_API.g_miss_date;
   x_act_offer_rec.last_updated_by := FND_API.g_miss_num;
   x_act_offer_rec.creation_date := FND_API.g_miss_date;
   x_act_offer_rec.created_by := FND_API.g_miss_num;
   x_act_offer_rec.last_update_login := FND_API.g_miss_num;
   x_act_offer_rec.object_version_number := FND_API.g_miss_num;
   x_act_offer_rec.act_offer_used_by_id := FND_API.g_miss_num;
   x_act_offer_rec.arc_act_offer_used_by := FND_API.g_miss_char;
   x_act_offer_rec.primary_offer_flag := FND_API.g_miss_char;
   x_act_offer_rec.active_period_set := FND_API.g_miss_char;
   x_act_offer_rec.active_period := FND_API.g_miss_char;
-- commented by julou 05/03/2001. These columns are gone.
/*
   x_act_offer_rec.offer_type := FND_API.g_miss_char;
   x_act_offer_rec.offer_code := FND_API.g_miss_char;
   x_act_offer_rec.start_date := FND_API.g_miss_date;
   x_act_offer_rec.end_date := FND_API.g_miss_date;
   x_act_offer_rec.order_date_from := FND_API.g_miss_date;
   x_act_offer_rec.order_date_to := FND_API.g_miss_date;
   x_act_offer_rec.ship_date_from := FND_API.g_miss_date;
   x_act_offer_rec.ship_date_to := FND_API.g_miss_date;
   x_act_offer_rec.perf_date_from := FND_API.g_miss_date;
   x_act_offer_rec.perf_date_to := FND_API.g_miss_date;
   x_act_offer_rec.status_code := FND_API.g_miss_char;
   x_act_offer_rec.status_date := FND_API.g_miss_date;
   x_act_offer_rec.offer_amount := FND_API.g_miss_num;
   x_act_offer_rec.lumpsum_payment_type := FND_API.g_miss_char;
*/
-- end of comment
   x_act_offer_rec.qp_list_header_id := FND_API.g_miss_num;

END Init_Rec;

--==================================================================================
-- Following lines of code is commented by ptendulk on may31-2000 the Wrapper part
-- is added in the Offer api which calls the modifier pub by skarumar
--
--==================================================================================

/*
-- Start of Comments
--
-- NAME
--   Create_Offer
--
-- PURPOSE
--   This procedure is a Wrapper which will be used to create the offers in
--   Oracle Marketing. It will internally call OzfOfferPvt.processListHeader
--   and Then Create_Act_Offer . It will commit the changes if both are
--   successful  else it will rollback both.
--
-- NOTES
--   OzfOfferPvt.Process_List_Header will write the messages in OE PUB
--   So will have to read error messages from there , if any.
--   the out parameter x_message_type will return value FND / OE
--   It will return 'FND' if the Messages are stored in FND_PUB
--   It will return 'OE' if the Messages are stored in OE_PUB
--
-- HISTORY
--   05/12/2000        ptendulk    created
-- End of Comments
PROCEDURE Create_Offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type,
   p_list_header_id      IN  NUMBER   := FND_API.g_miss_num,
   p_offer_name          IN  VARCHAR2 := FND_API.g_miss_char,
   p_currency_code       IN  VARCHAR2 := FND_API.g_miss_char,
   p_start_date          IN  DATE     := FND_API.g_miss_date,
   p_end_date            IN  DATE     := FND_API.g_miss_date,
   p_active_flag         IN  VARCHAR2 := FND_API.g_miss_char,
   p_automatic_flag      IN  VARCHAR2 := 'Y',
   p_invoice_flag        IN  VARCHAR2 := 'Y',

   x_list_header_id      OUT NOCOPY NUMBER,
   x_act_offer_id        OUT NOCOPY NUMBER,
   x_message_type        OUT NOCOPY VARCHAR2    -- OE / FND
)
IS
   l_return_status     VARCHAR2(1) ;
   l_api_name      CONSTANT VARCHAR2(30)  := 'Create_Offer';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
   l_line_id       NUMBER ;
   l_list_header_id     NUMBER ;
   l_act_offer_rec      act_offer_rec_type := p_act_offer_rec ;
BEGIN

   -- initialize
   SAVEPOINT Create_Offer;
   x_message_type := 'FND' ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


   --
   -- Create the List Header for the offer
   --
   OZF_Offer_PVT.process_list_header(
           p_init_msg_list     =>  p_init_msg_list ,
           p_commit            =>  p_commit ,

           x_return_status     =>  l_return_status ,
           x_msg_count         =>  x_msg_count ,
           x_msg_data          =>  x_msg_data ,

           p_list_header_id    =>  p_list_header_id,
           p_offer_name        =>  p_offer_name,
           p_currency_code     =>  p_currency_code,
           p_start_date        =>  p_start_date,
           p_end_date          =>  p_end_date,
           p_active_flag       =>  p_active_flag,
           p_automatic_flag    =>  p_automatic_flag,
           p_mode              =>  'CREATE',

           x_list_header_id    =>  l_list_header_id
           );

  IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OZF_Utility_Pvt.Debug_Message('Created List Header for the offers');

   --===================================================================
   -- Following line of code is commented by ptendulk on 16th May
   -- Create the Offer line in detail page
   --===================================================================
   --
   -- Create the List line If the offer type is Tiered Discount
   --
--   IF p_act_offer_rec.offer_type = 'TIERED' THEN
--           OZF_Offer_PVT.Process_List_Line(
--                   p_init_msg_list           =>  p_init_msg_list,
--                   p_commit                  =>  p_commit,
--
--                   x_return_status           =>  x_return_status,
--                   x_msg_count               =>  x_msg_count,
--                   x_msg_data                =>  x_msg_data,
--
--                   p_m_list_header_id        =>  l_list_header_id,
--                   p_m_automatic_flag        =>  'Y',
--                   p_m_invoice_flag          =>  p_invoice_flag,
--                   p_m_list_line_type_code   =>  'PBH',
--                   p_m_modifier_level_code   =>  'LINE',
--                   p_m_mode                  =>  'CREATE',
--
--                   p_p_mode                  =>  'NONE',
--
--                   x_list_line_id            =>  l_line_id
--                );
--
--           IF x_return_status = FND_API.g_ret_sts_error THEN
--                 x_message_type := 'OE' ;
--                 RAISE FND_API.g_exc_error;
--           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
--                 x_message_type := 'OE' ;
--                 RAISE FND_API.g_exc_unexpected_error;
--           END IF;
--   END IF;
   --
   -- Create the record in Activity Offers
   --
   OZF_Utility_Pvt.Debug_Message('Create Activity Offer');
   l_act_offer_rec.qp_list_header_id := l_list_header_id  ;

   Create_Act_Offer
          (
           p_api_version         => p_api_version,
           p_init_msg_list       => p_init_msg_list,
           p_commit              => p_commit,
           p_validation_level    => p_validation_level,

           x_return_status       => l_return_status ,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,

           p_act_offer_rec       => l_act_offer_rec,
           x_act_offer_id        => x_act_offer_id
           ) ;

   IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- END of API body.
   --
   l_list_header_id := x_list_header_id ;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
     	COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OE_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

	        ROLLBACK TO Create_Offer;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Create_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;


        WHEN OTHERS THEN

	        ROLLBACK TO Create_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;

                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      IF OE_MSG_PUB.Check_Msg_Level ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;

END Create_Offer ;


-- Start of Comments
--
-- NAME
--   Update_Offer
--
-- PURPOSE
--   This procedure is a Wrapper which will be used to Update the offers in
--   Oracle Marketing. It will internally call OzfOfferPvt.processListHeader
--   and Then Update_Act_Offer . It will commit the changes if both are
--   successful  else it will rollback both.
--
-- NOTES
--   OzfOfferPvt.Process_List_Header will write the messages in OE PUB
--   So will have to read error messages from there , if any.
--   the out parameter x_message_type will return value FND / OE
--   It will return 'FND' if the Messages are stored in FND_PUB
--   It will return 'OE' if the Messages are stored in OE_PUB
--
-- HISTORY
--   05/12/2000        ptendulk    created
-- End of Comments
PROCEDURE Update_Offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type,
   p_list_header_id      IN  NUMBER   := FND_API.g_miss_num,
   p_offer_name          IN  VARCHAR2 := FND_API.g_miss_char,
   p_currency_code       IN  VARCHAR2 := FND_API.g_miss_char,
   p_start_date          IN  DATE     := FND_API.g_miss_date,
   p_end_date            IN  DATE     := FND_API.g_miss_date,
   p_active_flag         IN  VARCHAR2 := FND_API.g_miss_char,
   p_automatic_flag      IN  VARCHAR2 := FND_API.g_miss_char,

   x_message_type        OUT NOCOPY VARCHAR2    -- OE / FND
)
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Update_Offer';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
   l_return_status     VARCHAR2(1) ;
   l_list_header_id    NUMBER ;
BEGIN

   -- initialize
   SAVEPOINT Update_Offer;

   x_message_type := 'FND' ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


   --
   -- Create the List Header for the offer
   --
   OZF_Offer_PVT.process_list_header(
           p_init_msg_list     =>  p_init_msg_list ,
           p_commit            =>  p_commit ,

           x_return_status     =>  l_return_status ,
           x_msg_count         =>  x_msg_count ,
           x_msg_data          =>  x_msg_data ,

           p_list_header_id    =>  p_list_header_id,
           p_offer_name        =>  p_offer_name,
           p_currency_code     =>  p_currency_code,
           p_start_date        =>  p_start_date,
           p_end_date          =>  p_end_date,
           p_active_flag       =>  p_active_flag,
           p_automatic_flag    =>  p_automatic_flag,
           p_mode              =>  'UPDATE',

           x_list_header_id    =>  l_list_header_id
           );

   IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Create the record in Activity Offers
   --
   OZF_Utility_Pvt.Debug_Message('Update Activity Offer');
   Update_Act_Offer
          (
           p_api_version         => p_api_version,
           p_init_msg_list       => p_init_msg_list,
           p_commit              => p_commit,
           p_validation_level    => p_validation_level,

           x_return_status       => l_return_status ,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,

           p_act_offer_rec       => p_act_offer_rec
           ) ;

   IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- END of API body.
   --

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
     	COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OE_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

	        ROLLBACK TO Update_Offer;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Update_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;


        WHEN OTHERS THEN

	        ROLLBACK TO Update_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;

                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      IF OE_MSG_PUB.Check_Msg_Level ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;


END Update_Offer;


-- Start of Comments
--
-- NAME
--   Delete_Offer
--
-- PURPOSE
--   This procedure is a Wrapper which will be used to Delete the offers in
--   Oracle Marketing. It will internally call OzfOfferPvt.processListHeader
--   and then Delete_Act_Offer . It will commit the changes if both are
--   successful  else it will rollback both.
--
-- NOTES
--   OzfOfferPvt.Process_List_Header will write the messages in OE PUB
--   So will have to read error messages from there , if any.
--   the out parameter x_message_type will return value FND / OE
--   It will return 'FND' if the Messages are stored in FND_PUB
--   It will return 'OE' if the Messages are stored in OE_PUB
--
-- HISTORY
--   05/12/2000        ptendulk    created
-- End of Comments
PROCEDURE Delete_Offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_id        IN  NUMBER,
   p_object_version      IN  NUMBER,
   p_list_header_id      IN  NUMBER   := FND_API.g_miss_num,
   p_offer_name          IN  VARCHAR2 := FND_API.g_miss_char,
   p_currency_code       IN  VARCHAR2 := FND_API.g_miss_char,
   p_start_date          IN  DATE     := FND_API.g_miss_date,
   p_end_date            IN  DATE     := FND_API.g_miss_date,
   p_active_flag         IN  VARCHAR2 := FND_API.g_miss_char,
   p_automatic_flag      IN  VARCHAR2 := FND_API.g_miss_char,

   x_message_type        OUT NOCOPY VARCHAR2    -- OE / FND
)
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Delete_Offer';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
   l_list_header_id    NUMBER ;
   l_return_status     VARCHAR2(1) ;
BEGIN

   -- initialize
   SAVEPOINT Delete_Offer;
   x_message_type := 'FND' ;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


   --
   -- Delete the List Header for the offer
   --
   OZF_Offer_PVT.process_list_header(
           p_init_msg_list     =>  p_init_msg_list ,
           p_commit            =>  p_commit ,

           x_return_status     =>  l_return_status ,
           x_msg_count         =>  x_msg_count ,
           x_msg_data          =>  x_msg_data ,

           p_list_header_id    =>  p_list_header_id,
           p_offer_name        =>  p_offer_name,
           p_currency_code     =>  p_currency_code,
           p_start_date        =>  p_start_date,
           p_end_date          =>  p_end_date,
           p_active_flag       =>  p_active_flag,
           p_automatic_flag    =>  p_automatic_flag,
           p_mode              =>  'DELETE',

           x_list_header_id    =>  l_list_header_id
           );

   IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'OE' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Delete the record in Activity Offers
   --
   OZF_Utility_Pvt.Debug_Message('Delete Activity Offer');
   Delete_Act_Offer
          (
           p_api_version         => p_api_version,
           p_init_msg_list       => p_init_msg_list,
           p_commit              => p_commit,

           x_return_status       => l_return_status ,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,

           p_act_offer_id        => p_act_offer_id,
           p_object_version      => p_object_version
           ) ;

   IF l_return_status = FND_API.g_ret_sts_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_message_type := 'FND' ;
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- END of API body.
   --

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
     	COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OE_MSG_PUB.Count_AND_Get
        ( p_count     =>   x_msg_count,
          p_data      =>   x_msg_data,
          p_encoded   =>   FND_API.G_FALSE
        );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

	        ROLLBACK TO Delete_Offer;
        	x_return_status := FND_API.G_RET_STS_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	        ROLLBACK TO Delete_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;


        WHEN OTHERS THEN

	        ROLLBACK TO Delete_Offer;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF x_message_type = 'FND' THEN
                      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;

                      FND_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                ELSIF x_message_type = 'OE' THEN
                      IF OE_MSG_PUB.Check_Msg_Level ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                      THEN
                           OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                      END IF;
                      OE_MSG_PUB.Count_AND_Get
                        ( p_count           =>      x_msg_count,
                          p_data            =>      x_msg_data,
                          p_encoded	    =>      FND_API.G_FALSE
                        );
                END IF ;


END Delete_Offer;
*/

END OZF_Act_Offers_PVT;

/
