--------------------------------------------------------
--  DDL for Package Body AMS_ACTRESOURCE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTRESOURCE_VUHK" AS
/* $Header: amsirscb.pls 115.2 2002/11/16 00:47:50 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_resource_pre
--
-- HISTORY
--    10-Apr-2002  gmadana  Created.
------------------------------------------------------------
PROCEDURE create_resource_pre(
   x_resource_rec        IN OUT NOCOPY AMS_ActResource_PUB.act_Resource_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    create_resource_post
--
-- HISTORY
--    10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE create_resource_post(
   p_resource_rec        IN  AMS_ActResource_PUB.act_Resource_rec_type,
   p_resource_id         IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_resource_pre
--
-- HISTORY
--    10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE delete_resource_pre(
   x_resource_id        IN OUT NOCOPY NUMBER,
   x_object_version     IN OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_resource_post
--
-- HISTORY
--    10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE delete_resource_post(
   p_resource_id         IN  NUMBER,
   p_object_version      IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_resource_pre
--
-- HISTORY
--    10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE lock_resource_pre(
   x_resource_id        IN OUT NOCOPY NUMBER,
   x_object_version     IN OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_resource_post
--
-- HISTORY
--   10-Apr-2002  gmadana  Created.
------------------------------------------------------------
PROCEDURE lock_resource_post(
   p_resource_id         IN  NUMBER,
   p_object_version      IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_resource_pre
--
-- HISTORY
--   10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE update_resource_pre(
   x_resource_rec       IN OUT NOCOPY AMS_ActResource_PUB.act_Resource_rec_type,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_resource_post
--
-- HISTORY
--   10-Apr-2002  gmadana  Created.
------------------------------------------------------------
PROCEDURE update_resource_post(
   p_resource_rec       IN  AMS_ActResource_PUB.act_Resource_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_resource_pre
--
-- HISTORY
--    10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE validate_resource_pre(
   x_resource_rec       IN OUT NOCOPY AMS_ActResource_PUB.act_Resource_rec_type,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_resource_post
--
-- HISTORY
--   10-Apr-2002   gmadana  Created.
------------------------------------------------------------
PROCEDURE validate_resource_post(
   p_resource_rec       IN  AMS_ActResource_PUB.act_Resource_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


END AMS_ActResource_VUHK;

/
