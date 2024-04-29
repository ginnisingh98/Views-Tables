--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_VUHK" AUTHID CURRENT_USER AS
/* $Header: amsicpns.pls 115.8 2002/11/16 00:41:16 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_pre
--
-- PURPOSE
--    Vertical industry pre-processing for create_campaign.
------------------------------------------------------------
PROCEDURE create_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_post
--
-- PURPOSE
--    Vertical industry post-processing for create_campaign.
------------------------------------------------------------
PROCEDURE create_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_campaign_pre
--
-- PURPOSE
--    Vertical industry pre-processing for delete_campaign.
------------------------------------------------------------
PROCEDURE delete_campaign_pre(
   x_camp_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    delete_campaign_post
--
-- PURPOSE
--    Vertical industry post-processing for delete_campaign.
------------------------------------------------------------
PROCEDURE delete_campaign_post(
   p_camp_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_campaign_pre
--
-- PURPOSE
--    Vertical industry pre-processing for lock_campaign.
------------------------------------------------------------
PROCEDURE lock_campaign_pre(
   x_camp_id        IN OUT NOCOPY NUMBER,
   x_object_version IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    lock_campaign_post
--
-- PURPOSE
--    Vertical industry post-processing for lock_campaign.
------------------------------------------------------------
PROCEDURE lock_campaign_post(
   p_camp_id        IN  NUMBER,
   p_object_version IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_campaign_pre
--
-- PURPOSE
--    Vertical industry pre-processing for update_campaign.
------------------------------------------------------------
PROCEDURE update_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    update_campaign_post
--
-- PURPOSE
--    Vertical industry post-processing for update_campaign.
------------------------------------------------------------
PROCEDURE update_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_campaign_pre
--
-- PURPOSE
--    Vertical industry pre-processing for validate_campaign.
------------------------------------------------------------
PROCEDURE validate_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    validate_campaign_post
--
-- PURPOSE
--    Vertical industry post-processing for validate_campaign.
------------------------------------------------------------
PROCEDURE validate_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_Campaign_VUHK;

 

/
