--------------------------------------------------------
--  DDL for Package Body AMS_EVENTOFFER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTOFFER_VUHK" AS
/* $Header: amsievob.pls 115.3 2002/11/16 00:41:30 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_EventOffer_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    create_EventOffer_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE create_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   p_evo_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_EventOffer_pre(
   x_evo_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE delete_EventOffer_post(
   p_evo_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_EventOffer_pre(
   x_evo_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE lock_EventOffer_post(
   p_evo_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_EventOffer_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    update_EventOffer_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE update_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer_pre
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer_post
--
-- HISTORY
--    10/01/99  holiu  Created.
------------------------------------------------------------
PROCEDURE validate_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


END AMS_EventOffer_VUHK;

/
