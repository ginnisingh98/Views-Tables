--------------------------------------------------------
--  DDL for Package AMS_ACTRESOURCE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTRESOURCE_VUHK" AUTHID CURRENT_USER AS
/* $Header: amsirscs.pls 115.2 2002/11/16 00:47:52 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_resource_pre
--
-- PURPOSE
--    Vertical industry pre-processing for create_resource.
------------------------------------------------------------
PROCEDURE create_resource_pre(
   x_resource_rec       IN OUT NOCOPY AMS_ActResource_PUB.Act_Resource_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_resource_post
--
-- PURPOSE
--    Vertical industry post-processing for create_resource.
------------------------------------------------------------
PROCEDURE create_resource_post(
   p_resource_rec       IN   AMS_ActResource_PUB.Act_Resource_rec_type,
   p_resource_id        IN   NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_resource_pre
--
-- PURPOSE
--    Vertical industry pre-processing for delete_resource.
------------------------------------------------------------
PROCEDURE delete_resource_pre(
   x_resource_id        IN OUT NOCOPY NUMBER,
   x_object_version     IN OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_resource_post
--
-- PURPOSE
--    Vertical industry post-processing for delete_resource.
------------------------------------------------------------
PROCEDURE delete_resource_post(
   p_resource_id        IN  NUMBER,
   p_object_version     IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_resource_pre
--
-- PURPOSE
--    Vertical industry pre-processing for lock_resource.
------------------------------------------------------------
PROCEDURE lock_resource_pre(
   x_resource_id        IN OUT NOCOPY NUMBER,
   x_object_version     IN OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_resource_post
--
-- PURPOSE
--    Vertical industry post-processing for lock_resource.
------------------------------------------------------------
PROCEDURE lock_resource_post(
   p_resource_id         IN  NUMBER,
   p_object_version      IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_resource_pre
--
-- PURPOSE
--    Vertical industry pre-processing for update_resource.
------------------------------------------------------------
PROCEDURE update_resource_pre(
   x_resource_rec       IN OUT NOCOPY AMS_ActResource_PUB.Act_Resource_rec_type,
   x_return_status      OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_resource_post
--
-- PURPOSE
--    Vertical industry post-processing for update_resource.
------------------------------------------------------------
PROCEDURE update_resource_post(
   p_resource_rec       IN  AMS_ActResource_PUB.Act_Resource_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_resource_pre
--
-- PURPOSE
--    Vertical industry pre-processing for validate_resource.
------------------------------------------------------------
PROCEDURE validate_resource_pre(
   x_resource_rec       IN OUT NOCOPY AMS_ActResource_PUB.Act_Resource_rec_type,
   x_return_status      OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_resource_post
--
-- PURPOSE
--    Vertical industry post-processing for validate_resource.
------------------------------------------------------------
PROCEDURE validate_resource_post(
   p_resource_rec       IN  AMS_ActResource_PUB.Act_Resource_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_ActResource_VUHK;

 

/
