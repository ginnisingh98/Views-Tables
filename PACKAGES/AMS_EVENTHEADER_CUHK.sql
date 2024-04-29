--------------------------------------------------------
--  DDL for Package AMS_EVENTHEADER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTHEADER_CUHK" AUTHID CURRENT_USER AS
/* $Header: amscevhs.pls 115.3 2002/11/16 00:40:54 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_EventHeader_pre
--
-- PURPOSE
--    Customer pre-processing for create_EventHeader.
------------------------------------------------------------
PROCEDURE create_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_EventHeader_post
--
-- PURPOSE
--    Customer post-processing for create_EventHeader.
------------------------------------------------------------
PROCEDURE create_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   p_evh_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventHeader_pre
--
-- PURPOSE
--    Customer pre-processing for delete_EventHeader.
------------------------------------------------------------
PROCEDURE delete_EventHeader_pre(
   x_evh_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventHeader_post
--
-- PURPOSE
--    Customer post-processing for delete_EventHeader.
------------------------------------------------------------
PROCEDURE delete_EventHeader_post(
   p_evh_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventHeader_pre
--
-- PURPOSE
--    Customer pre-processing for lock_EventHeader.
------------------------------------------------------------
PROCEDURE lock_EventHeader_pre(
   x_evh_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventHeader_post
--
-- PURPOSE
--    Customer post-processing for lock_EventHeader.
------------------------------------------------------------
PROCEDURE lock_EventHeader_post(
   p_evh_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_EventHeader_pre
--
-- PURPOSE
--    Customer pre-processing for update_EventHeader.
------------------------------------------------------------
PROCEDURE update_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_EventHeader_post
--
-- PURPOSE
--    Customer post-processing for update_EventHeader.
------------------------------------------------------------
PROCEDURE update_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventHeader_pre
--
-- PURPOSE
--    Customer pre-processing for validate_EventHeader.
------------------------------------------------------------
PROCEDURE validate_EventHeader_pre(
   x_evh_rec       IN OUT NOCOPY AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventHeader_post
--
-- PURPOSE
--    Customer post-processing for validate_EventHeader.
------------------------------------------------------------
PROCEDURE validate_EventHeader_post(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_EventHeader_CUHK;

 

/
