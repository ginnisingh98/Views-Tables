--------------------------------------------------------
--  DDL for Package DPP_SLA_CLAIM_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_SLA_CLAIM_EXTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: dppclexs.pls 120.3 2008/01/11 10:05:11 sdasan noship $ */
--   -------------------------------------------------------
--    Record name      claim_line_rec_type
--    Note: This is automatic generated record definition, it includes
--    all columns defined in the table, developer must manually add or
--    delete some of the attributes.
--   -------------------------------------------------------
  TYPE claim_line_rec_type IS RECORD
(
  claim_line_id              NUMBER  ,
  object_version_number      NUMBER ,
  last_update_date           DATE ,
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
  exchange_rate_date         DATE ,
  exchange_rate              NUMBER,
  set_of_books_id            NUMBER,
  valid_flag                 VARCHAR2(1),
  source_object_id           NUMBER,
  source_object_class        VARCHAR2(15),
  source_object_type_id      NUMBER,
  source_object_line_id      NUMBER,
  plan_id                    NUMBER,
  offer_id                   NUMBER,
  utilization_id             NUMBER,
  payment_method             VARCHAR2(15),
  payment_reference_id       NUMBER,
  payment_reference_number   VARCHAR2(15),
  payment_reference_date     DATE ,
  voucher_id                 NUMBER,
  voucher_number             VARCHAR2(30),
  payment_status             VARCHAR2(30),
  approved_flag              VARCHAR2(1),
  approved_date              DATE ,
  approved_by                NUMBER,
  settled_date               DATE ,
  settled_by                 NUMBER,
  performance_complete_flag  VARCHAR2(1),
  performance_attached_flag  VARCHAR2(1),
  item_id                    NUMBER,
  item_description           VARCHAR2(240),
  quantity                   NUMBER,
  quantity_uom               VARCHAR2(30),
  rate                       NUMBER,
  activity_type              VARCHAR2(30),
  activity_id                NUMBER,
  related_cust_account_id    NUMBER,
  relationship_type          VARCHAR2(30),
  earnings_associated_flag   VARCHAR2(1),
  comments                   VARCHAR2(2000),
  tax_code                   VARCHAR2(50),
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
  sale_date                  DATE,
  item_type                  VARCHAR2(30),
  tax_amount                 NUMBER,
  claim_curr_tax_amount      NUMBER,
  activity_line_id           NUMBER,
  offer_type                 VARCHAR2(30),
  prorate_earnings_flag      VARCHAR2(1),
  earnings_end_date          DATE,
  dpp_cust_account_id        VARCHAR2(20)
);
TYPE claim_line_tbl_type is TABLE OF claim_line_rec_type
INDEX BY BINARY_INTEGER;

 TYPE sla_line_rec_type IS RECORD
   (
     TRANSACTION_HEADER_ID            NUMBER  ,
     TRANSACTION_LINE_ID              NUMBER  ,
     BASE_TRANSACTION_HEADER_ID       NUMBER ,
     BASE_TRANSACTION_LINE_ID         NUMBER ,
     TRANSACTION_SUB_TYPE             VARCHAR2(20),
     CREATION_DATE		      DATE,
     CREATED_BY			      NUMBER,
     LAST_UPDATE_DATE		      DATE,
     LAST_UPDATED_BY		      NUMBER,
     LAST_UPDATE_LOGIN		      NUMBER
    );




TYPE sla_line_tbl_type is TABLE OF sla_line_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE Create_SLA_extract(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_id                   IN   ozf_claims.claim_id%TYPE,
    p_claim_line_tbl             IN   claim_line_tbl_type,
    p_userid			 IN NUMBER
    );


END DPP_SLA_CLAIM_EXTRACT_PUB;

/
