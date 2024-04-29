--------------------------------------------------------
--  DDL for Package OZF_TP_ACCRUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TP_ACCRUAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvtpas.pls 115.5 2004/04/28 08:59:02 jxwu noship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


G_IFACE_CALLER         CONSTANT VARCHAR2(30) :='IFACE';
G_RESALE_CALLER         CONSTANT VARCHAR2(30) :='RESALE';

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
PROCEDURE  Validate_Order_Record(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN    NUMBER
   ,p_caller_type            IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Order
--
-- PURPOSE
--    This is the main API for Third party accrual. It reads the order information of dicrect customers
--    and creates accruals based on the result of the pricing simulation.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_Order (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id             IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    Process resale order information. Reads date from ozf_reasle_lines table.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_Resale
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id             IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_TP_ACCRUAL
--
-- PURPOSE
--    This function is for 11.5.9 backword compatable
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_TP_ACCRUAL (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_data_source_code       IN  VARCHAR2 := NULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Start_TP_ACCRUAL
--
-- PURPOSE
--    This procedure to initiate concurrent program to process third party accrual.
--    It is to for backword compatibility issue on 11.5.9
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_TP_ACCRUAL (
    ERRBUF                   OUT NOCOPY VARCHAR2,
    RETCODE                  OUT NOCOPY NUMBER,
    p_data_source_code       IN  VARCHAR2 :=null
);

END OZF_TP_ACCRUAL_PVT;

 

/
