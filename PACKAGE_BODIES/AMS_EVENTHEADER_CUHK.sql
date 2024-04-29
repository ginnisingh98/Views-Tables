--------------------------------------------------------
--  DDL for Package Body AMS_EVENTHEADER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTHEADER_CUHK" AS
/* $Header: amscevhb.pls 115.3 2002/11/16 00:40:57 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_EventHeader_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
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
--    create_EventHeader_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   p_evh_id        IN  NUMBER,
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
--    delete_EventHeader_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_EventHeader_pre(
   x_evh_id        IN OUT NOCOPY NUMBER,
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
--    delete_EventHeader_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_EventHeader_post(
   p_evh_id        IN  NUMBER,
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
--    lock_EventHeader_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_EventHeader_pre(
   x_evh_id        IN OUT NOCOPY NUMBER,
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
--    lock_EventHeader_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_EventHeader_post(
   p_evh_id        IN  NUMBER,
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
--    update_EventHeader_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
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
--    update_EventHeader_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
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
--    validate_EventHeader_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
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
--    validate_EventHeader_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


END AMS_EventHeader_CUHK;

/
