--------------------------------------------------------
--  DDL for Package AMS_DELIVERABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVERABLE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdels.pls 120.0 2005/05/31 17:02:59 appldev noship $ */

-- Default number of records fetch per call
 G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


TYPE deliv_rec_type IS RECORD
(
  deliverable_id                NUMBER,
  last_update_date              DATE,
  last_updated_by               NUMBER,
  creation_date                 DATE,
  created_by                    NUMBER,
  last_update_login             NUMBER,
  object_version_number         NUMBER,
  language_code                 VARCHAR2(4),
  version                       VARCHAR2(10),
  application_id                NUMBER,
  user_status_id                NUMBER,
  status_code                   VARCHAR2(30),
  status_date                   DATE,
  active_flag                   VARCHAR2(1),
  private_flag                  VARCHAR2(1),
  owner_user_id                 NUMBER,
  fund_source_id                NUMBER,
  fund_source_type              VARCHAR2(30),
  category_type_id              NUMBER,
  category_sub_type_id          NUMBER,
  kit_flag                      VARCHAR2(1),
  inventory_flag                VARCHAR2(1),
  inventory_item_id             NUMBER,
  inventory_item_org_id         NUMBER,
  pricelist_header_id           NUMBER,
  pricelist_line_id             NUMBER,
  actual_avail_from_date        DATE,
  actual_avail_to_date          DATE,
  forecasted_complete_date      DATE,
  actual_complete_date          DATE,
  transaction_currency_code     VARCHAR2(15),
  functional_currency_code      VARCHAR2(15),
  budget_amount_tc              NUMBER,
  budget_amount_fc              NUMBER,
  replaced_by_deliverable_id    NUMBER,
  can_fulfill_electronic_flag   VARCHAR2(1),
  can_fulfill_physical_flag     VARCHAR2(1),
  jtf_amv_item_id               NUMBER,
  non_inv_ctrl_code             VARCHAR2(30),
  non_inv_quantity_on_hand      NUMBER,
  non_inv_quantity_on_order     NUMBER,
  non_inv_quantity_on_reserve   NUMBER,
  chargeback_amount             NUMBER,
  chargeback_uom                VARCHAR2(3),
  chargeback_amount_curr_code   VARCHAR2(15),
  deliverable_code              VARCHAR2(100),
  deliverable_pick_flag         VARCHAR2(1),
  currency_code                 VARCHAR2(15),
  forecasted_cost               NUMBER,
  actual_cost                   NUMBER,
  forecasted_responses          NUMBER,
  actual_responses              NUMBER,
  country                       VARCHAR2(240),
  default_approver_id           NUMBER,
  attribute_category            VARCHAR2(30),
  attribute1                    VARCHAR2(150),
  attribute2                    VARCHAR2(150),
  attribute3                    VARCHAR2(150),
  attribute4                    VARCHAR2(150),
  attribute5                    VARCHAR2(150),
  attribute6                    VARCHAR2(150),
  attribute7                    VARCHAR2(150),
  attribute8                    VARCHAR2(150),
  attribute9                    VARCHAR2(150),
  attribute10                   VARCHAR2(150),
  attribute11                   VARCHAR2(150),
  attribute12                   VARCHAR2(150),
  attribute13                   VARCHAR2(150),
  attribute14                   VARCHAR2(150),
  attribute15                   VARCHAR2(150),
  deliverable_name              VARCHAR2(240),
  description                   VARCHAR2(4000),
  start_period_name             VARCHAR2(15),
  end_period_name               VARCHAR2(15),
  deliverable_calendar          VARCHAR2(15),
  country_id                    NUMBER,
  setup_id                      NUMBER,
  item_Number                   VARCHAR2(2000),
  associate_flag                VARCHAR2(1),
  master_object_id              NUMBER,
  master_object_type            VARCHAR2(150),
  email_content_type            VARCHAR2(30)
  );

---------------------------------------------------------------------
-- PROCEDURE
--    create_Deliverable
--
-- PURPOSE
--    Create a new Deliverable.
--
-- PARAMETERS
--    p_deliv_rec: the new record to be inserted
--    x_deliv_id: return the deliverable_id of the new Deliverable
--
-- NOTES
-- overloading the existing create_deliverable api with public rec_type for rosetta generation.
---------------------------------------------------------------------



PROCEDURE create_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  deliv_rec_type,
   x_deliv_id           OUT NOCOPY NUMBER
);




---------------------------------------------------------------------
-- PROCEDURE
--    create_Deliverable
--
-- PURPOSE
--    Create a new Deliverable.
--
-- PARAMETERS
--    p_deliv_rec: the new record to be inserted
--    x_deliv_id: return the deliverable_id of the new Deliverable
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Deliverable_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If Deliverable_id is not passed in, generate a unique one from
--       the sequence.
---------------------------------------------------------------------
PROCEDURE create_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  AMS_Deliverable_PVT.deliv_rec_type,
   x_deliv_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_Deliverable
--
-- PURPOSE
--    Delete a Deliverable.
--
-- PARAMETERS
--    p_deliv_id: the Deliverable_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the Deliverable to be inactive, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_Deliverable(
   p_api_version_number      IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_id           IN  NUMBER,
   p_object_version_number    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_Deliverable
--
-- PURPOSE
--    Lock a Deliverable.
--
-- PARAMETERS
--    p_deliv_id: the Deliverable_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_id           IN  NUMBER,
   p_object_version_number    IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_Deliverable
--
-- PURPOSE
--    Update a Deliverable.
--
-- PARAMETERS
--    p_deliv_rec: the record with new items
--
-- NOTES
-- overloading the existing create_deliverable api with public rec_type for rosetta generation.
----------------------------------------------------------------------
PROCEDURE update_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  deliv_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_Deliverable
--
-- PURPOSE
--    Update a Deliverable.
--
-- PARAMETERS
--    p_deliv_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  AMS_Deliverable_PVT.deliv_rec_type
);



---------------------------------------------------------------------
-- PROCEDURE
--    validate_Deliverable
--
-- PURPOSE
--    Validate a Deliverable record.
--
-- PARAMETERS
--    p_deliv_rec: the Deliverable record to be validated
--
-- NOTES
--    1. p_deliv_rec should be the complete Deliverable record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_validation_mode   IN VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  AMS_Deliverable_PVT.deliv_rec_type
);


END AMS_Deliverable_PUB;

 

/
