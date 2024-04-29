--------------------------------------------------------
--  DDL for Package OZF_CLAIM_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_LINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvclns.pls 120.4.12010000.2 2009/02/03 06:36:33 psomyaju ship $ */

TYPE claim_line_rec_type IS RECORD
(
  claim_line_id              NUMBER,
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
  claim_id                   NUMBER,
  line_number                NUMBER,
  split_from_claim_line_id   NUMBER,
  amount                     NUMBER,
  claim_currency_amount      NUMBER,
  acctd_amount               NUMBER,
  currency_code              VARCHAR2(15),
  exchange_rate_type         VARCHAR2(30),
  exchange_rate_date         DATE,
  exchange_rate              NUMBER,
  set_of_books_id            NUMBER,
  valid_flag                 VARCHAR2(1),
  source_object_id           NUMBER,
  source_object_line_id      NUMBER,
  source_object_class        VARCHAR2(15),
  source_object_type_id      NUMBER,
  plan_id                    NUMBER,
  offer_id                   NUMBER,
  utilization_id             NUMBER,
  payment_method             VARCHAR2(15),
  payment_reference_id       NUMBER,
  payment_reference_number   VARCHAR2(30),
  payment_reference_date     DATE,
  voucher_id                 NUMBER,
  voucher_number             VARCHAR2(30),
  payment_status             VARCHAR2(10),
  approved_flag              VARCHAR2(1),
  approved_date              DATE,
  approved_by                NUMBER,
  settled_date               DATE,
  settled_by                 NUMBER,
  performance_complete_flag  VARCHAR2(1),
  performance_attached_flag  VARCHAR2(1),
  select_cust_children_flag  VARCHAR2(1),
  item_id                    NUMBER,
  item_description           VARCHAR2(240),
  quantity                   NUMBER,
  quantity_uom               VARCHAR2(30),
  rate                       NUMBER,
  activity_type              VARCHAR2(30),
  activity_id                NUMBER,
  related_cust_account_id    NUMBER,
  buy_group_cust_account_id  NUMBER,
  relationship_type          VARCHAR2(30),
  earnings_associated_flag   VARCHAR2(1),
  comments                   VARCHAR2(2000),
  tax_code                   VARCHAR2(50),
  credit_to                  VARCHAR2(15),
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
  update_from_tbl_flag       VARCHAR2(1)    := FND_API.g_false,
  tax_action                 VARCHAR2(15),
  sale_date                  DATE,
  item_type                  VARCHAR2(30),
  tax_amount                 NUMBER,
  claim_curr_tax_amount      NUMBER,
  activity_line_id           NUMBER,
  offer_type                 VARCHAR2(30),
  prorate_earnings_flag      VARCHAR2(1),
  earnings_end_date          DATE,
  buy_group_party_id         NUMBER,
  acctd_tax_amount           NUMBER,
  dpp_cust_account_id        VARCHAR2(20), -- 12.1 Enhancement:Price Protection
  batch_line_id              NUMBER        --Bugfix 7811671
);

TYPE claim_line_tbl_type is TABLE OF claim_line_rec_type
INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Create_Line_Hist
--
-- PURPOSE
--    Checking if there is a need to create claim line history.
--
-- PARAMETERS
--    p_mode            : Data manipulating mode, it should be CREATE', 'UPDATE', or 'DELETE'.
--    p_claim_line_rec  : The new record to be created, updated, or deleted.
--    p_object_attribute: The object_attribut of screen. It could be 'LINE' or 'LNDT'.
--    x_create_hist_flag: Returning flag indicating create claim line history or not.
--
-- NOTES
--    1. p_mode should be 'CREATE', 'UPDATE', or 'DELETE'
--    2. x_create_hist_flag will be set to FND_API.g_true/false
--    3. p_object_attribute could be 'LINE' or 'LNDT'.
---------------------------------------------------------------------
PROCEDURE Check_Create_Line_Hist(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_mode              IN  VARCHAR2
  ,p_claim_line_rec    IN  claim_line_rec_type
  ,p_object_attribute  IN  VARCHAR2
  ,x_create_hist_flag  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Fm_Claim
--
-- PURPOSE
--    Update claim lines from Claim package.
--
-- PARAMETERS
--    p_new_claim_rec: the update records without complete(with FND_API.g_miss_num/char/date value)
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Line_Fm_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_new_claim_rec          IN    OZF_CLAIM_PVT.claim_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Line_Tbl
--
-- PURPOSE
--    Create multiple records of claim lines.
--
-- PARAMETERS
--    p_claim_line_tbl: the new records to be inserted
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Line
--
-- PURPOSE
--    Create a new record of claim line.
--
-- PARAMETERS
--    p_claim_line_rec: the new record to be inserted
--    x_claim_line_id: return the claim_line_id of the new claim line record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If claim_line_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If claim_line_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is FND_API.g_ture/false.
--       Raise exception for invalid flag.
--    5. If valid_flag column is not passed in, default it to FND_API.g_false.
--    6. Please don't pass in any FND_API.g_miss_char/num/date for claim_line record.
---------------------------------------------------------------------
PROCEDURE Create_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_rec    IN  claim_line_rec_type
  ,p_mode              IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_claim_line_id     OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Line_Tbl
--
-- PURPOSE
--    Delete multiple records of claim lines.
--
-- PARAMETERS
--    p_claim_line_tbl: the new records to be deleted
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Delete_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Line
--
-- PURPOSE
--    Delete a record of claim line.
--
-- PARAMETERS
--    p_claim_line_id: the claim_line_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_id     IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,p_mode              IN  VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
);

-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Claim_Line
--
-- PURPOSE
--    Lock a claim line record.
--
-- PARAMETERS
--    p_claim_line_id: the claim_line_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_id     IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Line_Tbl
--
-- PURPOSE
--    Update multiple records of claim lines.
--
-- PARAMETERS
--    p_claim_line_tbl: the new records to be updated.
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Line
--
-- PURPOSE
--    Update a claim line record.
--
-- PARAMETERS
--    p_claim_line_rec: the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_rec    IN  claim_line_rec_type
  ,p_mode              IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_object_version    OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Line
--
-- PURPOSE
--    Validate a claim line record.
--
-- PARAMETERS
--    p_claim_line: the claim line record to be validated
--
-- NOTES
--    1. p_claim_line_rec should be a complete record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Claim_Line(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_claim_line_rec     IN  claim_line_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_claim_line_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Items(
   p_claim_line_rec  IN  claim_line_rec_type
  ,p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_claim_line_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Record(
   p_claim_line_rec     IN  claim_line_rec_type
  ,p_complete_rec       IN  claim_line_rec_type := NULL
  ,x_return_status      OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Claim_Line_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Claim_Line_Rec(
   x_claim_line_rec   OUT NOCOPY  claim_line_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Line_Rec
--
-- PURPOSE
--    For update_claim_line, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_line_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Line_Rec(
   p_claim_line_rec     IN  claim_line_rec_type
  ,x_complete_rec       OUT NOCOPY claim_line_rec_type
);

-- Created for Bug4348163:Split a given claim line so as to associate each claim
-- line with earnings from only one offer-product combination.
PROCEDURE split_claim_line(
   p_api_version            IN    NUMBER
  ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,p_claim_line_id       IN  NUMBER
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
);

END OZF_Claim_Line_PVT;

/
