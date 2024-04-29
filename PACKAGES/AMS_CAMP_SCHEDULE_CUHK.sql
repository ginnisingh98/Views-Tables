--------------------------------------------------------
--  DDL for Package AMS_CAMP_SCHEDULE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMP_SCHEDULE_CUHK" AUTHID CURRENT_USER AS
/* $Header: amscschs.pls 115.4 2002/11/16 00:41:05 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_schedule_pre
--
-- PURPOSE
--    Customer pre-processing for create_schedule.
------------------------------------------------------------
PROCEDURE create_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_schedule_post
--
-- PURPOSE
--    Customer post-processing for create_schedule.
------------------------------------------------------------
PROCEDURE create_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
   p_sch_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_schedule_pre
--
-- PURPOSE
--    Customer pre-processing for delete_schedule.
------------------------------------------------------------
PROCEDURE delete_schedule_pre(
   x_sch_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_schedule_post
--
-- PURPOSE
--    Customer post-processing for delete_schedule.
------------------------------------------------------------
PROCEDURE delete_schedule_post(
   p_sch_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_schedule_pre
--
-- PURPOSE
--    Customer pre-processing for lock_schedule.
------------------------------------------------------------
PROCEDURE lock_schedule_pre(
   x_sch_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_schedule_post
--
-- PURPOSE
--    Customer post-processing for lock_schedule.
------------------------------------------------------------
PROCEDURE lock_schedule_post(
   p_sch_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_schedule_pre
--
-- PURPOSE
--    Customer pre-processing for update_schedule.
------------------------------------------------------------
PROCEDURE update_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_schedule_post
--
-- PURPOSE
--    Customer post-processing for update_schedule.
------------------------------------------------------------
PROCEDURE update_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_schedule_pre
--
-- PURPOSE
--    Customer pre-processing for validate_schedule.
------------------------------------------------------------
PROCEDURE validate_schedule_pre(
   x_sch_rec       IN OUT NOCOPY AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_schedule_post
--
-- PURPOSE
--    Customer post-processing for validate_schedule.
------------------------------------------------------------
PROCEDURE validate_schedule_post(
   p_sch_rec       IN  AMS_Camp_Schedule_PUB.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_Camp_Schedule_CUHK;

 

/
