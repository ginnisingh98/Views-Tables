--------------------------------------------------------
--  DDL for Package AMS_DELIVKITITEM_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVKITITEM_VUHK" AUTHID CURRENT_USER as
/*$Header: amsikits.pls 115.1 2002/11/14 00:21:08 musman noship $*/

-- Start of Comments
-- Package name     : AMS_DelivKitItem_VUHK
-- PURPOSE
--    Customer user hook package for AMS_DelivKitItem_PUB.
--
-- PROCEDURES
--  create_DelivKitItem
--  update_DelivKitItem
--  delete_DelivKitItem
--  lock_DelivKitItem
--
-- HISTORY
--
-- 05/08/02        ABHOLA            Created
------------------------------------------------------------


-----------------------------------------------------------
-- PROCEDURE
--    create_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for create_DelivKitItem_pre.
------------------------------------------------------------
PROCEDURE create_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------
-- PROCEDURE
--    create_DelivKitItem_post
--
--
------------------------------------------------------------
PROCEDURE create_DelivKitItem_post(
   p_deliv_kit_item_rec         IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   p_deliv_kit_item_id          IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------
-- PROCEDURE
--   delete_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for delete_DelivKitItem.
------------------------------------------------------------
PROCEDURE delete_DelivKitItem_pre(
   x_deliv_kit_item_id            IN OUT NOCOPY NUMBER,
   x_object_version    IN OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY    VARCHAR2
);


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
   x_return_status     OUT NOCOPY    VARCHAR2
);

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
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_DelivKitItem_post
--
-- PURPOSE
--    Customer post-processing for lock_DelivKitItem.
------------------------------------------------------------
PROCEDURE lock_DelivKitItem_post(
   p_deliv_kit_item_id           IN  NUMBER,
   p_object_version   IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for update_DelivKitItem.
------------------------------------------------------------
PROCEDURE update_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


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
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_DelivKitItem_pre
--
-- PURPOSE
--    Customer pre-processing for validate_DelivKitItem.
------------------------------------------------------------
PROCEDURE validate_DelivKitItem_pre(
   x_deliv_kit_item_rec        IN OUT NOCOPY AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


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
);

End AMS_DelivKitItem_VUHK;

 

/
