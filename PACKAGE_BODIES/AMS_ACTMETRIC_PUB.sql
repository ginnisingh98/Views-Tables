--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRIC_PUB" AS
/* $Header: amspamtb.pls 120.0 2005/05/31 16:05:39 appldev noship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_ActMetric_PUB';


---------------------------------------------------------------------
-- PROCEDURE
--    Create_ActMetric
--
-- PURPOSE
--   Creates a metric in AMS_ACT_METRICS_ALL given the
--   record for the metrics.
--
-- HISTORY
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_ActMetric(
   p_api_version       	   IN  NUMBER,
   p_init_msg_list     	   IN  VARCHAR2  := FND_API.g_false,
   p_commit            	   IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  	   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     	   OUT NOCOPY VARCHAR2,
   x_msg_count         	   OUT NOCOPY NUMBER,
   x_msg_data          	   OUT NOCOPY VARCHAR2,

   p_act_metric_rec        IN  AMS_ACTMETRIC_PVT.act_metric_rec_type,
   x_activity_metric_id    OUT NOCOPY NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Create_Metric';
   l_return_status  VARCHAR2(1);
   l_act_metric_rec AMS_ActMetric_PVT.act_metric_rec_type := p_act_metric_rec;

BEGIN

   SAVEPOINT create_actmetric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Create_ActMetric(
      p_api_version      	  => p_api_version,
      p_init_msg_list    	  => FND_API.g_false, --has done before
      p_commit           	  => FND_API.g_false, -- will do after
      p_validation_level 	  => p_validation_level,

      x_return_status    	  => l_return_status,
      x_msg_count        	  => x_msg_count,
      x_msg_data         	  => x_msg_data,

      p_act_metric_rec        => l_act_metric_rec,
      x_activity_metric_id    => x_activity_metric_id
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
      ROLLBACK TO create_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_actmetric_pub;
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

END Create_ActMetric;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_ActMetric
--
-- PURPOSE
--    Deletes the association of a metric to a business
--    object by creating a record in AMS_ACT_METRICS_ALL.
--
-- HISTORY
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
PROCEDURE Delete_ActMetric(
   p_api_version       	   IN  NUMBER,
   p_init_msg_list     	   IN  VARCHAR2 := FND_API.g_false,
   p_commit            	   IN  VARCHAR2 := FND_API.g_false,

   x_return_status     	   OUT NOCOPY VARCHAR2,
   x_msg_count         	   OUT NOCOPY NUMBER,
   x_msg_data          	   OUT NOCOPY VARCHAR2,

   p_activity_metric_id    IN  NUMBER,
   p_object_version    	   IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Delete_ActMetric';
   l_return_status  VARCHAR2(1);
   l_act_metric_id  NUMBER := p_activity_metric_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT delete_actmetric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Delete_ActMetric(
      p_api_version      		=> p_api_version,
      p_init_msg_list    		=> FND_API.g_false, --has done before
      p_commit           		=> FND_API.g_false, -- will do after

      x_return_status    		=> l_return_status,
      x_msg_count        		=> x_msg_count,
      x_msg_data         		=> x_msg_data,

      p_activity_metric_id      => l_act_metric_id,
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
      ROLLBACK TO delete_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_actmetric_pub;
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

END Delete_ActMetric;


---------------------------------------------------------------------
-- PROCEDURE
--    Lock_ActMetric
--
-- PURPOSE
--    Perform a row lock of the Activity metrics identified in the
--    given row.
-- HISTORY
--
--    10/14/99  ptendulk  Created.
---------------------------------------------------------------------
PROCEDURE Lock_ActMetric(
   p_api_version       	 IN  NUMBER,
   p_init_msg_list     	 IN  VARCHAR2 := FND_API.g_false,

   x_return_status     	 OUT NOCOPY VARCHAR2,
   x_msg_count         	 OUT NOCOPY NUMBER,
   x_msg_data          	 OUT NOCOPY VARCHAR2,

   p_activity_metric_id  IN  NUMBER,
   p_object_version    	 IN  NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Lock_ActMetric';
   l_return_status  VARCHAR2(1);
   l_act_metric_id  NUMBER := p_activity_metric_id;
   l_object_version NUMBER := p_object_version;

BEGIN

   SAVEPOINT lock_actmetric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Lock_ActMetric(
      p_api_version      	  => p_api_version,
      p_init_msg_list    	  => FND_API.g_false, --has done before

      x_return_status    	  => l_return_status,
      x_msg_count        	  => x_msg_count,
      x_msg_data         	  => x_msg_data,

      p_activity_metric_id    => l_act_metric_id,
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
      ROLLBACK TO lock_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_actmetric_pub;
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

END Lock_ActMetric;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_ActMetric
--
-- PURPOSE
--   Updates a metric in AMS_ACT_METRICS_ALL given the
--   record for the metrics.
--
-- HISTORY
--    10/14/99  ptendulk  created.
---------------------------------------------------------------------
PROCEDURE Update_ActMetric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_metric_rec    IN  AMS_ActMetric_PVT.act_metric_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Update_ActMetric';
   l_return_status  VARCHAR2(1);
   l_act_metric_rec AMS_ActMetric_PVT.act_metric_rec_type := p_act_metric_rec;

BEGIN

   SAVEPOINT update_actmetric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Update_ActMetric(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => FND_API.g_false, -- will do after
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_act_metric_rec   => l_act_metric_rec
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
      ROLLBACK TO update_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_actmetric_pub;
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

END Update_ActMetric;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ActMetric
--
-- PURPOSE
--   Validation API for Activity metrics.
--
--
-- HISTORY
--    10/01/99  ptendulk  validated.
---------------------------------------------------------------------
PROCEDURE Validate_ActMetric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_metric_rec    IN  AMS_ActMetric_PVT.act_metric_rec_type
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_ActMetric';
   l_return_status  VARCHAR2(1);
   l_act_metric_rec AMS_ActMetric_PVT.act_metric_rec_type := p_act_metric_rec;

BEGIN

   SAVEPOINT validate_actmetric_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Validate_ActMetric(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_validation_level => p_validation_level,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_act_metric_rec   => l_act_metric_rec
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
      ROLLBACK TO validate_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_actmetric_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_actmetric_pub;
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

END Validate_ActMetric;

---------------------------------------------------------------------
-- PROCEDURE
--    Invalidate_Rollup
--
-- PURPOSE
--    Invalidate to rollup pointers.
--
-- PARAMETERS
--    p_used_by_type: Object type, eg. 'CAMP', 'EVEO', etc.
--    p_used_by_id: Identifier for the object.
--
-- NOTES
--    1. Set the dirty flags for all related rollups.
--    2. Set the rollup_to_metric fields to null for this object.
--    3. When the hierarchy of business objects gets changed including deletion
--       and modification, this stored procedure needs to be called for the
--       child business object.  For example, when a user modifies the parent
--       of a campaign, call this procedure against the child campaign.
--       Another example, when a user changes an event associated with a
--       campaign, call this stored procedure for old event object.  One more
--       example, when a user delete a deliverable from a campaign, call
--       this stored procedure for the deliverable being deleted.  You do
--       not need to call this module when you add parent or child
--       to a businness object.
--
----------------------------------------------------------------------
PROCEDURE Invalidate_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_used_by_type      IN VARCHAR2,
   p_used_by_id        IN NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Invalidate_Rollup';
   l_return_status  VARCHAR2(1);

BEGIN

   SAVEPOINT invalidate_rollup_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- call business API
   AMS_ActMetric_PVT.Invalidate_Rollup(
      p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.g_false, --has done before
      p_commit           => p_commit,

      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

		p_used_by_type     => p_used_by_type,
		p_used_by_id       => p_used_by_id
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
      ROLLBACK TO invalidate_rollup_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO invalidate_rollup_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO invalidate_rollup_pub;
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

END Invalidate_Rollup;

END AMS_ActMetric_PUB;

/
