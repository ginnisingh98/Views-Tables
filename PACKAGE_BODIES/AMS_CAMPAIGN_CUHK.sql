--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_CUHK" AS
/* $Header: amsccpnb.pls 115.8 2002/11/16 00:41:13 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_campaign_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_campaign_pre(
   x_camp_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_campaign_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_campaign_post(
   p_camp_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_campaign_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_campaign_pre(
   x_camp_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_campaign_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_campaign_post(
   p_camp_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_campaign_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_campaign_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_campaign_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_campaign_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


END AMS_Campaign_CUHK;

/
