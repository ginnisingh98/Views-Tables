--------------------------------------------------------
--  DDL for Package OZF_CHARGEBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CHARGEBACK_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcbks.pls 120.0 2005/06/01 02:04:17 appldev noship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order_Record
--
-- PURPOSE
--    This procedure validates the order information
--    These are validation specific to chargeback process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Order_Record (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Order
--
-- PURPOSE
--    This is the main API for chargeback. It reads the order information of dicrect customers
--    and creates accruals based on the result of the pricing simulation.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Order (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_payment
--
-- PURPOSE
--    Initiate payment for a batch.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Initiate_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Order_Price
--
-- PURPOSE
--    Get Order Price
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Get_Order_Price (
   p_resale_batch_id          IN  NUMBER,
   p_order_number             IN  VARCHAR2,
   p_sold_from_cust_acct_id   IN  NUMBER,
   p_date_ordered             IN  DATE,
   x_line_tbl                 OUT NOCOPY OZF_ORDER_PRICE_PVT.line_rec_tbl_type,
   x_ldets_tbl                OUT NOCOPY OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE,
   x_related_lines_tbl        OUT NOCOPY OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE,
   x_return_status            OUT NOCOPY VARCHAR2
);

END OZF_CHARGEBACK_PVT;

 

/
