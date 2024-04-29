--------------------------------------------------------
--  DDL for Package Body AMS_DELIVKITITEM_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVKITITEM_VUHK" AS
/*$Header: amsikitb.pls 115.1 2002/11/14 00:21:05 musman noship $*/

-----------------------------------------------------------
-- PACKAGE
--
---- Package name     : AMS_DelivKitItem_VUHK
-- PURPOSE
--    Customer user hook package for AMS_DelivKitItem_PUB.
--
-- PROCEDURES
--  create_DelivKitItem
--  update_DelivKitItem
--  delete_DelivKitItem
--  lock_DelivKitItem
-- HISTORY
------------------------------------------------------------
-----------------------------------------------------------
-- PROCEDURE
--    create_DelivKitItem_pre
--
------------------------------------------------------------

PROCEDURE create_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
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
--    create_DelivKitItem_post
--
------------------------------------------------------------
PROCEDURE create_DelivKitItem_post(
   p_deliv_kit_item_rec         IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   p_deliv_kit_item_id          IN  NUMBER,
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
--    delete_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for delete_DelivKitItem.
------------------------------------------------------------
PROCEDURE delete_DelivKitItem_pre(
   x_deliv_kit_item_id            IN OUT NOCOPY NUMBER,
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
--    delete_DelivKitItem_post
--
-- PURPOSE
--    Customer post-processing for delete_DelivKitItem.
------------------------------------------------------------
PROCEDURE delete_DelivKitItem_post(
   p_deliv_kit_item_id            IN  NUMBER,
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
--    lock_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for lock_DelivKitItem.
------------------------------------------------------------
PROCEDURE lock_DelivKitItem_pre(
   x_deliv_kit_item_id            IN OUT NOCOPY NUMBER,
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
--    lock_DelivKitItem_post
--
-- PURPOSE
--    Customer post-processing for lock_DelivKitItem.
------------------------------------------------------------
PROCEDURE lock_DelivKitItem_post(
   p_deliv_kit_item_id            IN  NUMBER,
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
--    update_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing forupdate_DelivKitItem.
------------------------------------------------------------
PROCEDURE update_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
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
--    update_DelivKitItem_post
--
-- PURPOSE
--    Customer post-processing for update_DelivKitItem.
------------------------------------------------------------
PROCEDURE update_DelivKitItem_post(
   p_deliv_kit_item_rec        IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
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
--   validate_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for validate_DelivKitItem.
------------------------------------------------------------
PROCEDURE validate_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
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
--    validate_DelivKitItem_post
--
-- PURPOSE
--    Customer post-processing for validate_DelivKitItem.
------------------------------------------------------------
PROCEDURE validate_DelivKitItem_post(
   p_deliv_kit_item_rec        IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;



End AMS_DelivKitItem_VUHK;

/
