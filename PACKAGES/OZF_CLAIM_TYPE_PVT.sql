--------------------------------------------------------
--  DDL for Package OZF_CLAIM_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvclms.pls 120.1 2005/08/02 07:56:13 appldev ship $ */

TYPE claim_rec_type IS RECORD
(
  claim_type_id              NUMBER,
  object_version_number      NUMBER,
  last_update_date           DATE,
  last_updated_by            NUMBER,
  creation_date              DATE,
  created_by                 NUMBER,
  last_update_login          NUMBER,
  request_id                 NUMBER,
  program_application_id     NUMBER,
  program_update_date        DATE,
  program_id                 NUMBER,
  created_from               VARCHAR2(30),
  claim_class                VARCHAR2(10),
  set_of_books_id            NUMBER,
  post_to_gl_flag            VARCHAR2(1),
  start_date                 DATE,
  end_date                   DATE,
  creation_sign              VARCHAR2(30),
  gl_id_ded_adj              NUMBER,
  gl_id_ded_adj_clearing     NUMBER,
  gl_id_ded_clearing         NUMBER,
  gl_id_accr_promo_liab      NUMBER,
  transaction_type           NUMBER,
  cm_trx_type_id             NUMBER,
  dm_trx_type_id             NUMBER,
  cb_trx_type_id             NUMBER,
  wo_rec_trx_id              NUMBER,
  adj_rec_trx_id             NUMBER,
  attribute_category         VARCHAR2(30),
  attribute1                 VARCHAR2(150),
  attribute2                 VARCHAR2(150),
  attribute3                 VARCHAR2(150),
  attribute4                 VARCHAR2(150),
  attribute5                 VARCHAR2(150),
  attribute6                 VARCHAR2(150),
  attribute7                 VARCHAR2(150),
  attribute8                 VARCHAR2(150),
  attribute9                 VARCHAR2(150),
  attribute10                VARCHAR2(150),
  attribute11                VARCHAR2(150),
  attribute12                VARCHAR2(150),
  attribute13                VARCHAR2(150),
  attribute14                VARCHAR2(150),
  attribute15                VARCHAR2(150),
  org_id                     NUMBER,
  name                       VARCHAR2(30),
  description                VARCHAR2(240),
  language                   VARCHAR2(4),
  source_lang                VARCHAR2(4),
  adjustment_type            VARCHAR2(30),
  order_type_id              NUMBER,
  neg_wo_rec_trx_id          NUMBER,
  gl_balancing_flex_value    VARCHAR2(150)
);



---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Type
--
-- PURPOSE
--    Create a new claim type.
--
-- PARAMETERS
--    p_claim_rec: the new record to be inserted
--    x_claim_type_id: return the claim_type_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If claim_type_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If claim_type_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
  ,x_claim_type_id     OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Type
--
-- PURPOSE
--    Delete a claim type.
--
-- PARAMETERS
--    p_claim_type_id: the claim_type_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_type_id     IN  NUMBER
  ,p_claim_org_id      IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Type
--
-- PURPOSE
--    Update a claim type.
--
-- PARAMETERS
--    p_claim_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
  ,p_mode              IN  VARCHAR2 := 'UPDATE'
  ,x_object_version    OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Type
--
-- PURPOSE
--    Validate a claim type record.
--
-- PARAMETERS
--    p_claim_rec: the claim_type record to be validated
--
-- NOTES
--    1. p_claim_rec should be the complete fund record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Claim_Type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_rec         IN  claim_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_claim_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_claim_rec       IN  claim_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Type_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_claim_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Claim_Type_Record(
   p_claim_rec        IN  claim_rec_type
  ,p_complete_rec     IN  claim_rec_type := NULL
  ,x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Claim_Type_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Claim_Type_Rec(
   x_claim_rec        OUT NOCOPY  claim_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Type_Rec
--
-- PURPOSE
--    For update_claim_type, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Type_Rec(
   p_claim_rec       IN  claim_rec_type
  ,x_complete_rec    OUT NOCOPY claim_rec_type
);


END OZF_Claim_Type_PVT;

 

/
