--------------------------------------------------------
--  DDL for Package AMS_DELIVERABLE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVERABLE_VUHK" AUTHID CURRENT_USER as
/*$Header: amsidels.pls 115.1 2002/11/14 00:21:02 musman noship $*/

-- Start of Comments
-- Package name     : AMS_Deliverable_VUHK
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
-- PURPOSE
--    Customer pre-processing for create_Deliverable_pre.
------------------------------------------------------------
PROCEDURE create_Deliverable_pre(
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------
-- PROCEDURE
--    create_Deliverable_post
--
--
------------------------------------------------------------
PROCEDURE create_Deliverable_post(
   p_deliv_rec         IN  AMS_Deliverable_PVT.deliv_rec_type,
   p_deliv_id          IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------
-- PROCEDURE
--   delete_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for delete_Deliverable.
------------------------------------------------------------
PROCEDURE delete_Deliverable_pre(
   x_deliv_id            IN OUT NOCOPY NUMBER,
   x_object_version    IN OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY    VARCHAR2
);


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
   x_return_status     OUT NOCOPY    VARCHAR2
);

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
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for lock_Deliverable.
------------------------------------------------------------
PROCEDURE lock_Deliverable_post(
   p_deliv_id           IN  NUMBER,
   p_object_version   IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for update_Deliverable.
------------------------------------------------------------
PROCEDURE update_Deliverable_pre(
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


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
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_Deliverable_pre
--
-- PURPOSE
--    Customer pre-processing for validate_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_pre(
   x_deliv_rec        IN OUT NOCOPY AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_Deliverable_post
--
-- PURPOSE
--    Customer post-processing for validate_Deliverable.
------------------------------------------------------------
PROCEDURE validate_Deliverable_post(
   p_deliv_rec        IN  AMS_Deliverable_PVT.deliv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);

End AMS_Deliverable_VUHK;

 

/
