--------------------------------------------------------
--  DDL for Package Body AMS_EVENTHEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTHEADER_PUB" AS
/* $Header: amspevhb.pls 115.3 2002/11/16 00:42:52 dbiswas ship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_EventHeader_PUB';


---------------------------------------------------------------------
-- PROCEDURE
--    create_EventHeader
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE create_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type,
   x_evh_id           OUT NOCOPY NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'create_EventHeader';
   l_return_status  VARCHAR2(1);
   l_evh_rec       AMS_EventHeader_PVT.evh_rec_type := p_evh_rec;

BEGIN

   SAVEPOINT create_EventHeader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventHeader_CUHK.create_EventHeader_pre(
         l_evh_rec,
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
      AMS_EventHeader_VUHK.create_EventHeader_pre(
         l_evh_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventHeader_PVT.create_event_header(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evh_rec         => l_evh_rec,
      x_evh_id          => x_evh_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventHeader_VUHK.create_EventHeader_post(
         l_evh_rec,
         x_evh_id,
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
      AMS_EventHeader_CUHK.create_EventHeader_post(
         l_evh_rec,
         x_evh_id,
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
      ROLLBACK TO create_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_EventHeader_pub;
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

END create_EventHeader;


---------------------------------------------------------------------
-- PROCEDURE
--    delete_EventHeader
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE delete_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'delete_EventHeader';
   l_return_status  VARCHAR2(1);
   l_evh_id        NUMBER := p_evh_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT delete_EventHeader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventHeader_CUHK.delete_EventHeader_pre(
         l_evh_id,
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
      AMS_EventHeader_VUHK.delete_EventHeader_pre(
         l_evh_id,
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
   AMS_EventHeader_PVT.delete_event_header(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evh_id          => l_evh_id,
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
      AMS_EventHeader_VUHK.delete_EventHeader_post(
         l_evh_id,
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
      AMS_EventHeader_CUHK.delete_EventHeader_post(
         l_evh_id,
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
      ROLLBACK TO delete_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_EventHeader_pub;
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

END delete_EventHeader;


---------------------------------------------------------------------
-- PROCEDURE
--    lock_EventHeader
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE lock_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'lock_EventHeader';
   l_return_status  VARCHAR2(1);
   l_evh_id        NUMBER := p_evh_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT lock_EventHeader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventHeader_CUHK.lock_EventHeader_pre(
         l_evh_id,
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
      AMS_EventHeader_VUHK.lock_EventHeader_pre(
         l_evh_id,
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
   AMS_EventHeader_PVT.lock_event_header(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evh_id          => l_evh_id,
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
      AMS_EventHeader_VUHK.lock_EventHeader_post(
         l_evh_id,
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
      AMS_EventHeader_CUHK.lock_EventHeader_post(
         l_evh_id,
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
      ROLLBACK TO lock_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_EventHeader_pub;
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

END lock_EventHeader;


---------------------------------------------------------------------
-- PROCEDURE
--    update_EventHeader
--
-- HISTORY
--    10/01/99  holiu  updated.
---------------------------------------------------------------------
PROCEDURE update_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'update_EventHeader';
   l_return_status  VARCHAR2(1);
   l_evh_rec       AMS_EventHeader_PVT.evh_rec_type := p_evh_rec;

BEGIN

   SAVEPOINT update_EventHeader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventHeader_CUHK.update_EventHeader_pre(
         l_evh_rec,
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
      AMS_EventHeader_VUHK.update_EventHeader_pre(
         l_evh_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventHeader_PVT.update_event_header(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evh_rec         => l_evh_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventHeader_VUHK.update_EventHeader_post(
         l_evh_rec,
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
      AMS_EventHeader_CUHK.update_EventHeader_post(
         l_evh_rec,
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
      ROLLBACK TO update_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_EventHeader_pub;
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

END update_EventHeader;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_EventHeader
--
-- HISTORY
--    10/01/99  holiu  validated.
---------------------------------------------------------------------
PROCEDURE validate_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'validate_EventHeader';
   l_return_status  VARCHAR2(1);
   l_evh_rec       AMS_EventHeader_PVT.evh_rec_type := p_evh_rec;

BEGIN

   SAVEPOINT validate_EventHeader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_EventHeader_CUHK.validate_EventHeader_pre(
         l_evh_rec,
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
      AMS_EventHeader_VUHK.validate_EventHeader_pre(
         l_evh_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_EventHeader_PVT.validate_event_header(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_evh_rec         => l_evh_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_EventHeader_VUHK.validate_EventHeader_post(
         l_evh_rec,
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
      AMS_EventHeader_CUHK.validate_EventHeader_post(
         l_evh_rec,
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
      ROLLBACK TO validate_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_EventHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_EventHeader_pub;
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

END validate_EventHeader;


END AMS_EventHeader_PUB;

/
