--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_CUHK" AS
/*$Header: amscdelb.pls 115.1 2002/11/14 00:20:42 musman noship $*/
-----------------------------------------------------------
-- PACKAGE
--    AMS_Deliverable_CUHK
--
-- PURPOSE
--    Customer user hook package for AMS_Deliverable_PUB.
--
-- PROCEDURES
--  create_Deliverable
--  update_Deliverable
--  delete_Deliverable
--  lock_Deliverable
--
-- HISTORY
--
-- 05/08/02        ABHOLA            Created
------------------------------------------------------------

-----------------------------------------------------------
-- PROCEDURE
--    create_Deliverable_pre
--
------------------------------------------------------------

PROCEDURE create_Deliverable_pre(
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
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
--    create_Deliverable_post
--
-- HISTORY
--    10-Apr-2002  gmadana  Created.
------------------------------------------------------------
PROCEDURE create_Deliverable_post(
   p_deliv_rec         IN  AMS_Deliverable_PVT.deliv_rec_type,
   p_deliv_id          IN  NUMBER,
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
   x_deliv_id            IN OUT NOCOPY NUMBER,
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
--    delete_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for delete_Deliverable.
------------------------------------------------------------
PROCEDURE delete_Deliverable_post(
   p_deliv_id            IN  NUMBER,
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
   x_deliv_id            IN OUT NOCOPY NUMBER,
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
   p_deliv_id            IN  NUMBER,
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
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
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
   p_deliv_rec        IN  AMS_Deliverable_PVT.deliv_rec_type,
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
--    validate_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing forupdate_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_pre(
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
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
--    Customer post-processing for update_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_post(
   p_deliv_rec        IN  AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


End AMS_Deliverable_CUHK;

/
