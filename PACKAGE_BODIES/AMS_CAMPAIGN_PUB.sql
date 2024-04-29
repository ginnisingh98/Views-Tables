--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_PUB" AS
/* $Header: amspcpnb.pls 115.10 2002/11/16 00:42:00 dbiswas ship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_Campaign_PUB';


---------------------------------------------------------------------
-- PROCEDURE
--    create_campaign
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE create_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type,
   x_camp_id           OUT NOCOPY NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'create_campaign';
   l_return_status  VARCHAR2(1);
   l_camp_rec       AMS_Campaign_PVT.camp_rec_type := p_camp_rec;

BEGIN

   SAVEPOINT create_campaign_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Campaign_CUHK.create_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Campaign_VUHK.create_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Campaign_PVT.create_campaign(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_camp_rec         => l_camp_rec,
      x_camp_id          => x_camp_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Campaign_VUHK.create_campaign_post(
         l_camp_rec,
         x_camp_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Campaign_CUHK.create_campaign_post(
         l_camp_rec,
         x_camp_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_campaign_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_campaign_pub;
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

END create_campaign;


---------------------------------------------------------------------
-- PROCEDURE
--    delete_campaign
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE delete_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'delete_campaign';
   l_return_status  VARCHAR2(1);
   l_camp_id        NUMBER := p_camp_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT delete_campaign_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Campaign_CUHK.delete_campaign_pre(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Campaign_VUHK.delete_campaign_pre(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Campaign_PVT.delete_campaign(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_camp_id          => l_camp_id,
      p_object_version   => l_object_version
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Campaign_VUHK.delete_campaign_post(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Campaign_CUHK.delete_campaign_post(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );


EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_campaign_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_campaign_pub;
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

END delete_campaign;


---------------------------------------------------------------------
-- PROCEDURE
--    lock_campaign
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE lock_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'lock_campaign';
   l_return_status  VARCHAR2(1);
   l_camp_id        NUMBER := p_camp_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT lock_campaign_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Campaign_CUHK.lock_campaign_pre(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Campaign_VUHK.lock_campaign_pre(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Campaign_PVT.lock_campaign(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_camp_id          => l_camp_id,
      p_object_version   => l_object_version
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Campaign_VUHK.lock_campaign_post(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Campaign_CUHK.lock_campaign_post(
         l_camp_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO lock_campaign_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_campaign_pub;
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

END lock_campaign;


---------------------------------------------------------------------
-- PROCEDURE
--    update_campaign
--
-- HISTORY
--    10/01/99  holiu  updated.
---------------------------------------------------------------------
PROCEDURE update_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'update_campaign';
   l_return_status  VARCHAR2(1);
   l_camp_rec       AMS_Campaign_PVT.camp_rec_type := p_camp_rec;

BEGIN

   SAVEPOINT update_campaign_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Campaign_CUHK.update_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Campaign_VUHK.update_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Campaign_PVT.update_campaign(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_camp_rec         => l_camp_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Campaign_VUHK.update_campaign_post(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Campaign_CUHK.update_campaign_post(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_campaign_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_campaign_pub;
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

END update_campaign;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_campaign
--
-- HISTORY
--    10/01/99  holiu  validated.
---------------------------------------------------------------------
PROCEDURE validate_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'validate_campaign';
   l_return_status  VARCHAR2(1);
   l_camp_rec       AMS_Campaign_PVT.camp_rec_type := p_camp_rec;

BEGIN

   SAVEPOINT validate_campaign_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Campaign_CUHK.validate_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Campaign_VUHK.validate_campaign_pre(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Campaign_PVT.validate_campaign(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_camp_rec         => l_camp_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Campaign_VUHK.validate_campaign_post(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Campaign_CUHK.validate_campaign_post(
         l_camp_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_campaign_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_campaign_pub;
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

END validate_campaign;


END AMS_Campaign_PUB;

/
