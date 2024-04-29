--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_CUHK" AUTHID CURRENT_USER AS
/* $Header: amsccpns.pls 115.7 2002/11/16 00:41:10 dbiswas ship $ */


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_pre
--
-- PURPOSE
--    Customer pre-processing for create_campaign.
------------------------------------------------------------
PROCEDURE create_campaign_pre(
   x_camp_rec       IN OUT NOCOPY AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY    VARCHAR2
);


-----------------------------------------------------------
-- PROCEDURE
--    create_campaign_post
--
-- PURPOSE
--    Customer post-processing for create_campaign.
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
--    Customer pre-processing for delete_campaign.
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
--    Customer post-processing for delete_campaign.
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
--    Customer pre-processing for lock_campaign.
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
--    Customer post-processing for lock_campaign.
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
--    Customer pre-processing for update_campaign.
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
--    Customer post-processing for update_campaign.
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
--    Customer pre-processing for validate_campaign.
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
--    Customer post-processing for validate_campaign.
------------------------------------------------------------
PROCEDURE validate_campaign_post(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


END AMS_Campaign_CUHK;

 

/
