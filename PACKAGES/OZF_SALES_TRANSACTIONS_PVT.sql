--------------------------------------------------------
--  DDL for Package OZF_SALES_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SALES_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvstns.pls 120.3.12000000.2 2007/02/24 05:18:39 kdass ship $ */

TYPE SALES_TRANSACTION_REC_TYPE IS RECORD (
   sales_transaction_id            NUMBER,
   object_version_number           NUMBER,
   last_update_date                DATE ,
   last_updated_by                 NUMBER,
   creation_date                   DATE,
   request_id                      NUMBER,
   created_by                      NUMBER,
   created_from                    VARCHAR2(30),
   last_update_login               NUMBER(15),
   program_application_id          NUMBER,
   program_update_date             DATE,
   program_id                      NUMBER,
   transfer_type                   VARCHAR2(30),
   sold_from_cust_account_id       NUMBER,
   sold_from_party_id              NUMBER,
   sold_from_party_site_id         NUMBER,
   sold_to_cust_account_id         NUMBER,
   sold_to_party_id                NUMBER,
   sold_to_party_site_id           NUMBER,
   bill_to_site_use_id             NUMBER,
   ship_to_site_use_id             NUMBER,
   transaction_date                DATE,
   quantity                        NUMBER,
   uom_code                        VARCHAR2(30),
   amount                          NUMBER,
   currency_code                   VARCHAR2(30),
   inventory_item_id               NUMBER,
   primary_quantity                NUMBER,
   primary_uom_code                VARCHAR2(30),
   common_quantity                 NUMBER,
   common_uom_code                 VARCHAR2(30),
   common_currency_code            VARCHAR2(30),
   common_amount                   NUMBER,
   header_id                       NUMBER,
   line_id                         NUMBER,
   reason_code                     VARCHAR2(30),
   source_code                     VARCHAR2(30),
   error_flag                      VARCHAR2(1),
   attribute_category              VARCHAR2 (40),
   attribute1                      VARCHAR2 (240),
   attribute2                      VARCHAR2 (240),
   attribute3                      VARCHAR2 (240),
   attribute4                      VARCHAR2 (240),
   attribute5                      VARCHAR2 (240),
   attribute6                      VARCHAR2 (240),
   attribute7                      VARCHAR2 (240),
   attribute8                      VARCHAR2 (240),
   attribute9                      VARCHAR2 (240),
   attribute10                     VARCHAR2 (240),
   attribute11                     VARCHAR2 (240),
   attribute12                     VARCHAR2 (240),
   attribute13                     VARCHAR2 (240),
   attribute14                     VARCHAR2 (240),
   attribute15                     VARCHAR2 (240),
   org_id                          NUMBER,
   qp_list_header_id               VARCHAR2 (240)
  );

TYPE SALES_TRANS_TBL IS TABLE OF SALES_TRANSACTION_REC_TYPE INDEX BY BINARY_INTEGER;

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_transaction
--
-- PURPOSE
--    Validate a transaction record.
--
-- PARAMETERS
--    p_transaction : the transaction code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Transaction (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_transaction            IN  SALES_TRANSACTION_REC_TYPE
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_transaction
--
-- PURPOSE
--    This procedure creates an transaction
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE create_transaction (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_transaction_rec        IN  SALES_TRANSACTION_REC_TYPE
   ,x_sales_transaction_id   OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Inventory_tmp
--
-- PURPOSE
--    Populate the inventory temporary table
--
-- PARAMETERS
--    p_party_id: Id of the party that we want to have a look of its inventory
--    p_start_date : The date when we want to take a snapshot of inventory
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Initiate_Inventory_tmp (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN   NUMBER
   ,p_start_date             IN   DATE
   ,p_end_date               IN   DATE
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_Inventory_tmp
--
-- PURPOSE
--    update the inventory temporary table
--
-- PARAMETERS
--    p_sales_transaction_id: the id of the salse_transaction record to update
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  update_Inventory_tmp (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_sales_transaction_id   IN   NUMBER
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Inventory_Level
--
-- PURPOSE
--    Validate a line against the inventory levle.
--
-- PARAMETERS
--    p_line_int_rec: interface rece.
--    x_valid: boolean
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Inventory_Level (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN   OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE
   ,x_valid                  OUT NOCOPY  BOOLEAN
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Purchase_Price
--
-- PURPOSE
--    Calculate the purchase price of a line based on the order management data.
--
-- PARAMETERS
--    p_line_int_rec: interface rece.
--    x_purchase_price: NUMBER
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Get_Purchase_Price (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_order_date             IN   DATE
   ,p_sold_from_cust_account_id  IN   NUMBER
   ,p_sold_from_site_id      IN   NUMBER
   ,p_inventory_item_id      IN   NUMBER
   ,p_uom_code               IN   VARCHAR2
   ,p_quantity               IN   NUMBER
   ,p_currency_code          IN   VARCHAR2
   ,p_x_purchase_uom_code    IN OUT NOCOPY VARCHAR2
   ,x_purchase_price         OUT NOCOPY  NUMBER
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   );

END OZF_SALES_TRANSACTIONS_PVT;

 

/
