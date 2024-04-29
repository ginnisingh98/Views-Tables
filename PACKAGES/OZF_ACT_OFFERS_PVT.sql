--------------------------------------------------------
--  DDL for Package OZF_ACT_OFFERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACT_OFFERS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoffs.pls 120.0 2005/06/01 00:52:03 appldev noship $ */

TYPE act_offer_rec_type IS RECORD
(
   ACTIVITY_OFFER_ID          NUMBER,
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_LOGIN          NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   ACT_OFFER_USED_BY_ID       NUMBER,
   ARC_ACT_OFFER_USED_BY      VARCHAR2(30),
   PRIMARY_OFFER_FLAG         VARCHAR2(1),
   ACTIVE_PERIOD_SET          VARCHAR2(240),
   ACTIVE_PERIOD              VARCHAR2(30),
--   START_DATE                 DATE,
--   END_DATE                   DATE,
--   ORDER_DATE_FROM            DATE,
--   ORDER_DATE_TO              DATE,
--   SHIP_DATE_FROM             DATE,
--   SHIP_DATE_TO               DATE,
--   PERF_DATE_FROM             DATE,
--   PERF_DATE_TO               DATE,
--   STATUS_CODE                VARCHAR2(30),
--   STATUS_DATE                DATE,
--   OFFER_TYPE                 VARCHAR2(30),
--   OFFER_CODE                 VARCHAR2(30),
--   OFFER_AMOUNT               NUMBER,
--   LUMPSUM_PAYMENT_TYPE       VARCHAR2(30),
   QP_LIST_HEADER_ID          NUMBER,
   SECURITY_GROUP_ID          NUMBER
);


-----------------------------------------------------------
-- PROCEDURE
--   create_act_offer
-- PURPOSE
--   create a row in OZF_ACT_OFFES
-----------------------------------------------------------
PROCEDURE create_act_offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type,
   x_act_offer_id        OUT NOCOPY NUMBER
);

-----------------------------------------------------------
-- PROCEDURE
--   update_act_offer
-- PURPOSE
--   Update a row in OZF_ACT_OFFERS.
-----------------------------------------------------------
PROCEDURE update_act_offer
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   p_act_offer_rec       IN  act_offer_rec_type
);

-----------------------------------------------------------
-- PROCEDURE
--   delete_act_offer
-- PURPOSE
--   Delete a row from OZF_ACT_OFFERS.
-----------------------------------------------------------
PROCEDURE delete_act_offer
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_offer_id      IN  NUMBER,
   p_object_version    IN  NUMBER
);

-----------------------------------------------------------
-- PROCEDURE
--   lock_act_offer
-- PURPOSE
--   Lock a row form OZF_ACT_OFFERS.
-----------------------------------------------------------
PROCEDURE lock_act_offer
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_offer_id      IN  NUMBER,
   p_object_version    IN  NUMBER
);

-----------------------------------------------------------
-- PROCEDURE
--   validate_act_offer
-- PURPOSE
--   Validate a record before inserting or updating.
-----------------------------------------------------------
PROCEDURE validate_act_offer
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.g_false,
   p_validation_level   IN  NUMBER := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_act_offer_rec      IN  act_offer_rec_type
);

-----------------------------------------------------------
-- PROCEDURE
--   check_items
-- PURPOSE
--   Check the item level business rules.
-----------------------------------------------------------
PROCEDURE check_items
(
    p_validation_mode  IN  VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    p_act_offer_rec    IN  act_offer_rec_type
);

-----------------------------------------------------------
-- PROCEDURE
--    check_record
-- PURPOSE
--    Check the record level business rules.
-----------------------------------------------------------
PROCEDURE check_record
(
   p_act_offer_rec   IN  act_offer_rec_type,
   p_complete_rec    IN  act_offer_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------
-- PROCEDURE
--    complete_rec
-- PURPOSE
--    Replace g_miss values with current database values.
-----------------------------------------------------------
PROCEDURE complete_rec
(
   p_act_offer_rec   IN  act_offer_rec_type,
   x_complete_rec    OUT NOCOPY act_offer_rec_type
);

-----------------------------------------------------------------------
-- PROCEDURE
--    init_rec
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
-----------------------------------------------------------------------
PROCEDURE init_rec
(
   x_act_offer_rec  OUT NOCOPY act_offer_rec_type
);


END OZF_Act_Offers_PVT;

 

/
