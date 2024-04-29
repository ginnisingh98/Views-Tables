--------------------------------------------------------
--  DDL for Package AMS_EVENTOFFER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTOFFER_CUHK" AUTHID CURRENT_USER AS
/* $Header: amscevos.pls 115.3 2002/11/16 00:41:00 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_EventOffer_pre
--
-- PURPOSE
--    Customer pre-processing for create_EventOffer.
------------------------------------------------------------
PROCEDURE create_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_EventOffer_post
--
-- PURPOSE
--    Customer post-processing for create_EventOffer.
------------------------------------------------------------
PROCEDURE create_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   p_evo_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer_pre
--
-- PURPOSE
--    Customer pre-processing for delete_EventOffer.
------------------------------------------------------------
PROCEDURE delete_EventOffer_pre(
   x_evo_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer_post
--
-- PURPOSE
--    Customer post-processing for delete_EventOffer.
------------------------------------------------------------
PROCEDURE delete_EventOffer_post(
   p_evo_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer_pre
--
-- PURPOSE
--    Customer pre-processing for lock_EventOffer.
------------------------------------------------------------
PROCEDURE lock_EventOffer_pre(
   x_evo_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer_post
--
-- PURPOSE
--    Customer post-processing for lock_EventOffer.
------------------------------------------------------------
PROCEDURE lock_EventOffer_post(
   p_evo_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_EventOffer_pre
--
-- PURPOSE
--    Customer pre-processing for update_EventOffer.
------------------------------------------------------------
PROCEDURE update_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_EventOffer_post
--
-- PURPOSE
--    Customer post-processing for update_EventOffer.
------------------------------------------------------------
PROCEDURE update_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer_pre
--
-- PURPOSE
--    Customer pre-processing for validate_EventOffer.
------------------------------------------------------------
PROCEDURE validate_EventOffer_pre(
   x_evo_rec       IN OUT NOCOPY AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer_post
--
-- PURPOSE
--    Customer post-processing for validate_EventOffer.
------------------------------------------------------------
PROCEDURE validate_EventOffer_post(
   p_evo_rec       IN  AMS_EventOffer_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_EventOffer_CUHK;

 

/
