--------------------------------------------------------
--  DDL for Package PV_OFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_OFFER_PUB" AUTHID CURRENT_USER as
/* $Header: pvxvoffs.pls 115.1 2003/12/03 02:49:51 pklin ship $*/

-- ----------------------------------------------------------------------------
-- Global Variables
-- ----------------------------------------------------------------------------
TYPE Modifier_LIST_Rec_Type IS RECORD
(
   OFFER_ID                      NUMBER         := Fnd_Api.g_miss_num
  ,QP_LIST_HEADER_ID             NUMBER         := Fnd_Api.g_miss_num
  ,OFFER_TYPE                    VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,OFFER_CODE                    VARCHAR2(100)  := Fnd_Api.g_miss_char
  ,USER_STATUS_ID                NUMBER         := Fnd_Api.g_miss_num
  ,OBJECT_VERSION_NUMBER         NUMBER         := Fnd_Api.g_miss_num
  ,STATUS_CODE                   VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,CUSTOM_SETUP_ID               NUMBER         := Fnd_Api.g_miss_num
  ,BUDGET_AMOUNT_TC              NUMBER         := Fnd_Api.g_miss_num
  ,TRANSACTION_CURRENCY_CODE     VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,FUNCTIONAL_CURRENCY_CODE      VARCHAR2(15)   := Fnd_Api.g_miss_char
  ,CURRENCY_CODE                 VARCHAR2(30)   := Fnd_Api.g_miss_char
  ,NAME                          VARCHAR2(240)  := Fnd_Api.g_miss_char
  ,DESCRIPTION                   VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,COMMENTS                      VARCHAR2(2000) := Fnd_Api.g_miss_char
  ,OFFER_OPERATION              VARCHAR2(30)    := FND_API.g_miss_char
  ,MODIFIER_OPERATION           VARCHAR2(30)    := FND_API.g_miss_char
  ,BUDGET_OFFER_YN              VARCHAR2(1)     := FND_API.g_miss_char
  ,TIER_LEVEL                   VARCHAR2(30)    := FND_API.g_miss_char
);


TYPE discount_line_rec_type IS RECORD
(
       offer_discount_line_id          NUMBER,
       parent_discount_line_id         NUMBER,
       discount                        NUMBER,
       discount_type                   VARCHAR2(30),
       tier_type                       VARCHAR2(30),
       tier_level                      VARCHAR2(30),
       object_version_number           NUMBER,
       product_level                   VARCHAR2(30),
       product_id                      NUMBER,
       operation                       VARCHAR2(30)
);
TYPE discount_line_tbl_type IS TABLE OF discount_line_rec_type INDEX BY BINARY_INTEGER;

TYPE na_qualifier_rec_type IS RECORD
(
        qualifier_id                    NUMBER,
        qualifier_context               VARCHAR2(30),
        qualifier_attribute             VARCHAR2(30),
        qualifier_attr_value            VARCHAR2(240),
        object_version_number           NUMBER,
        operation                       VARCHAR2(30)
);
TYPE na_qualifier_tbl_type IS TABLE OF na_qualifier_rec_type INDEX BY BINARY_INTEGER;


TYPE budget_rec_type IS RECORD
(
   act_budget_id NUMBER
  ,budget_id     NUMBER
  ,budget_amount NUMBER
  ,operation     VARCHAR2(30)
);
TYPE budget_tbl_type IS TABLE OF budget_rec_type INDEX BY BINARY_INTEGER;


-- ----------------------------------------------------------------------------
-- Public Procedures
-- ----------------------------------------------------------------------------
PROCEDURE create_offer(
   p_init_msg_list         IN  VARCHAR2,
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_benefit_id            IN  NUMBER,
   p_operation             IN  VARCHAR2,
   p_offer_id              IN  NUMBER,
   p_modifier_list_rec     IN  modifier_list_rec_type,
   p_budget_tbl            IN  budget_tbl_type,
   p_discount_tbl          IN  discount_line_tbl_type,
   p_na_qualifier_tbl      IN  na_qualifier_tbl_type,
   x_offer_id              OUT NOCOPY NUMBER,
   x_qp_list_header_id     OUT NOCOPY NUMBER,
   x_error_location        OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2);


END PV_OFFER_PUB;

 

/
