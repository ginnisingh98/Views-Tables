--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_VUHK" AS
/*$Header: amsidelb.pls 115.1 2002/11/14 00:20:59 musman noship $*/

-----------------------------------------------------------
-- PACKAGE
--
---- Package name     : AMS_Deliverable_VUHK
-- PURPOSE
--    Customer user hook package for AMS_Deliverable_PUB.
--
-- PROCEDURES
--  create_Deliverable
--  update_Deliverable
--  delete_Deliverable
--  lock_Deliverable
-- HISTORY
------------------------------------------------------------
-----------------------------------------------------------
-- PROCEDURE
--    create_Deliverable_pre
--
------------------------------------------------------------

PROCEDURE create_Deliverable_pre(
   x_Deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    create_Deliverable_post
--
------------------------------------------------------------
PROCEDURE create_Deliverable_post(
   p_Deliv_rec         IN  AMS_Deliverable_PVT.deliv_rec_type,
   p_Deliv_id          IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for delete_Deliverable.
------------------------------------------------------------
PROCEDURE delete_Deliverable_pre(
   x_Deliv_id            IN OUT NOCOPY NUMBER,
   x_object_version     IN OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    delete_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for delete_Deliverable.
------------------------------------------------------------
PROCEDURE delete_Deliverable_post(
   p_Deliv_id            IN  NUMBER,
   p_object_version    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    lock_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for lock_Deliverable.
------------------------------------------------------------
PROCEDURE lock_Deliverable_pre(
   x_Deliv_id            IN OUT NOCOPY NUMBER,
   x_object_version    IN OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    lock_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for lock_Deliverable.
------------------------------------------------------------
PROCEDURE lock_Deliverable_post(
   p_Deliv_id            IN  NUMBER,
   p_object_version    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    update_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing forupdate_Deliverable.
------------------------------------------------------------
PROCEDURE update_Deliverable_pre(
   x_Deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
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
--    update_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for update_Deliverable.
------------------------------------------------------------
PROCEDURE update_Deliverable_post(
   p_Deliv_rec        IN  AMS_Deliverable_PVT.deliv_rec_type,
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
--   validate_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for validate_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_pre(
   x_Deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
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
--    validate_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for validate_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_post(
   p_Deliv_rec        IN  AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;



End AMS_Deliverable_VUHK;

/
