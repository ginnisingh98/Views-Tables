--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_PUB" AS
/* $Header: amspmtcb.pls 120.0 2005/05/31 18:07:37 appldev noship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_Metric_PUB';


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Metric
--
-- PURPOSE
--   Creates a metric in AMS_METRICS_ALL_B given the
--   record for the metrics.
--
-- HISTORY
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_METRIC_PVT.metric_rec_type,
   x_metric_id         OUT NOCOPY NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Create_Metric';
   l_return_status  VARCHAR2(1);
   l_metric_rec     AMS_Metric_PVT.metric_rec_type := p_metric_rec;

BEGIN

   SAVEPOINT create_metric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_Metric_PVT.Create_Metric(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_metric_rec       => l_metric_rec,
      x_metric_id        => x_metric_id
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      ROLLBACK TO create_metric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_metric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_metric_pub;
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

END Create_Metric;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Metric
--
-- PURPOSE
--   Deletes a metric in AMS_METRICS_ALL_B given the
--   key identifier for the metric.
--
-- HISTORY
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
PROCEDURE Delete_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Delete_Metric';
   l_return_status  VARCHAR2(1);
   l_metric_id      NUMBER := p_metric_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT delete_metric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_Metric_PVT.Delete_Metric(
      p_api_version      		=> p_api_version,
      p_init_msg_list    		=> FND_API.g_false, --has done before
      p_commit           		=> FND_API.g_false, -- will do after

      x_return_status    		=> l_return_status,
      x_msg_count        		=> x_msg_count,
      x_msg_data         		=> x_msg_data,

      p_metric_id        		=> l_metric_id,
      p_object_version_number   => l_object_version
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      ROLLBACK TO delete_metric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_metric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_metric_pub;
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

END Delete_Metric;


---------------------------------------------------------------------
-- PROCEDURE
--    Lock_Metric
--
-- PURPOSE
--    Perform a row lock of the metrics identified in the
--    given row.
-- HISTORY
--
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
PROCEDURE Lock_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Lock_Metric';
   l_return_status  VARCHAR2(1);
   l_metric_id      NUMBER := p_metric_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT lock_metric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_Metric_PVT.Lock_Metric(
      p_api_version      	  => p_api_version,
      p_init_msg_list    	  => FND_API.g_false, --has done before

      x_return_status    	  => l_return_status,
      x_msg_count        	  => x_msg_count,
      x_msg_data         	  => x_msg_data,

      p_metric_id        	  => l_metric_id,
      p_object_version_number => l_object_version
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO lock_metric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_metric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_metric_pub;
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

END Lock_Metric;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Metric
--
-- PURPOSE
--   Updates a metric in AMS_METRICS_ALL_B given the
--   record for the metrics.
--
-- HISTORY
--    10/14/99  ptendulk  created.
---------------------------------------------------------------------
PROCEDURE Update_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_Metric_PVT.metric_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Update_Metric';
   l_return_status  VARCHAR2(1);
   l_metric_rec       AMS_Metric_PVT.metric_rec_type := p_metric_rec;

BEGIN

   SAVEPOINT update_metric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_Metric_PVT.Update_Metric(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_metric_rec       => l_metric_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      ROLLBACK TO update_metric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_metric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_metric_pub;
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

END Update_Metric;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Metric
--
-- PURPOSE
--   Validation API for metrics.
--
--
-- HISTORY
--    10/01/99  ptendulk  validated.
---------------------------------------------------------------------
PROCEDURE Validate_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_Metric_PVT.metric_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_Metric';
   l_return_status  VARCHAR2(1);
   l_metric_rec       AMS_Metric_PVT.metric_rec_type := p_metric_rec;

BEGIN

   SAVEPOINT validate_metric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_Metric_PVT.Validate_Metric(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_metric_rec       => l_metric_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_metric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_metric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_metric_pub;
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

END Validate_Metric;


END AMS_Metric_PUB;

/
