--------------------------------------------------------
--  DDL for Package Body AMS_EVENTOFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTOFFER_PUB" AS
/* $Header: amspevob.pls 115.3 2002/12/02 20:30:36 dbiswas ship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_EventOffer_PUB';


---------------------------------------------------------------------
-- PROCEDURE
--    create_EventOffer
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type,
   x_evo_id           OUT NOCOPY NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'create_EventOffer';
   l_return_status  VARCHAR2(1);
   l_evo_rec       AMS_EventOffer_PVT.evo_rec_type := p_evo_rec;

BEGIN

   SAVEPOINT create_EventOffer_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventOffer_CUHK.create_EventOffer_pre(
         l_evo_rec,
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
      AMS_EventOffer_VUHK.create_EventOffer_pre(
         l_evo_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventOffer_PVT.create_Event_Offer(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evo_rec         => l_evo_rec,
      x_evo_id          => x_evo_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventOffer_VUHK.create_EventOffer_post(
         l_evo_rec,
         x_evo_id,
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
      AMS_EventOffer_CUHK.create_EventOffer_post(
         l_evo_rec,
         x_evo_id,
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
      ROLLBACK TO create_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_EventOffer_pub;
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

END create_EventOffer;


---------------------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE delete_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'delete_EventOffer';
   l_return_status  VARCHAR2(1);
   l_evo_id        NUMBER := p_evo_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT delete_EventOffer_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventOffer_CUHK.delete_EventOffer_pre(
         l_evo_id,
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
      AMS_EventOffer_VUHK.delete_EventOffer_pre(
         l_evo_id,
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
   AMS_EventOffer_PVT.delete_Event_Offer(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evo_id          => l_evo_id,
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
      AMS_EventOffer_VUHK.delete_EventOffer_post(
         l_evo_id,
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
      AMS_EventOffer_CUHK.delete_EventOffer_post(
         l_evo_id,
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
      ROLLBACK TO delete_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_EventOffer_pub;
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

END delete_EventOffer;


---------------------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE lock_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'lock_EventOffer';
   l_return_status  VARCHAR2(1);
   l_evo_id        NUMBER := p_evo_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT lock_EventOffer_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventOffer_CUHK.lock_EventOffer_pre(
         l_evo_id,
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
      AMS_EventOffer_VUHK.lock_EventOffer_pre(
         l_evo_id,
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
   AMS_EventOffer_PVT.lock_Event_Offer(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evo_id          => l_evo_id,
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
      AMS_EventOffer_VUHK.lock_EventOffer_post(
         l_evo_id,
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
      AMS_EventOffer_CUHK.lock_EventOffer_post(
         l_evo_id,
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
      ROLLBACK TO lock_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_EventOffer_pub;
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

END lock_EventOffer;


---------------------------------------------------------------------
-- PROCEDURE
--    update_EventOffer
--
-- HISTORY
--    10/01/99  holiu  updated.
---------------------------------------------------------------------
PROCEDURE update_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'update_EventOffer';
   l_return_status  VARCHAR2(1);
   l_evo_rec       AMS_EventOffer_PVT.evo_rec_type := p_evo_rec;

BEGIN

   SAVEPOINT update_EventOffer_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventOffer_CUHK.update_EventOffer_pre(
         l_evo_rec,
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
      AMS_EventOffer_VUHK.update_EventOffer_pre(
         l_evo_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventOffer_PVT.update_Event_Offer(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evo_rec         => l_evo_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventOffer_VUHK.update_EventOffer_post(
         l_evo_rec,
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
      AMS_EventOffer_CUHK.update_EventOffer_post(
         l_evo_rec,
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
      ROLLBACK TO update_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_EventOffer_pub;
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

END update_EventOffer;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer
--
-- HISTORY
--    10/01/99  holiu  validated.
---------------------------------------------------------------------
PROCEDURE validate_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'validate_EventOffer';
   l_return_status  VARCHAR2(1);
   l_evo_rec       AMS_EventOffer_PVT.evo_rec_type := p_evo_rec;

BEGIN

   SAVEPOINT validate_EventOffer_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventOffer_CUHK.validate_EventOffer_pre(
         l_evo_rec,
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
      AMS_EventOffer_VUHK.validate_EventOffer_pre(
         l_evo_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventOffer_PVT.validate_Event_Offer(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evo_rec         => l_evo_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventOffer_VUHK.validate_EventOffer_post(
         l_evo_rec,
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
      AMS_EventOffer_CUHK.validate_EventOffer_post(
         l_evo_rec,
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
      ROLLBACK TO validate_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_EventOffer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_EventOffer_pub;
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

END validate_EventOffer;


END AMS_EventOffer_PUB;

/
