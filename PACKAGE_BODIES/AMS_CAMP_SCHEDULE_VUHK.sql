--------------------------------------------------------
--  DDL for Package Body AMS_CAMP_SCHEDULE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMP_SCHEDULE_VUHK" AS
/* $Header: amsischb.pls 115.4 2002/11/16 00:41:33 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_schedule_pre
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE create_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
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
--    create_schedule_post
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE create_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
   p_sch_id        IN  NUMBER,
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
--    delete_schedule_pre
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE delete_schedule_pre(
   x_sch_id        IN OUT NOCOPY NUMBER,
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
--    delete_schedule_post
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE delete_schedule_post(
   p_sch_id        IN  NUMBER,
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
--    lock_schedule_pre
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE lock_schedule_pre(
   x_sch_id        IN OUT NOCOPY NUMBER,
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
--    lock_schedule_post
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE lock_schedule_post(
   p_sch_id        IN  NUMBER,
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
--    update_schedule_pre
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE update_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
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
--    update_schedule_post
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE update_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
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
--    validate_schedule_pre
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE validate_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
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
--    validate_schedule_post
--
-- HISTORY
--    18-May-2001  soagrawa  Created.
------------------------------------------------------------
PROCEDURE validate_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- vertical industry to add the customization codes here
   -- for post processing
END;


END AMS_Camp_Schedule_VUHK;

/
