--------------------------------------------------------
--  DDL for Package OE_EXTERNAL_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EXTERNAL_CREDIT_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVCECS.pls 115.3 2003/10/20 07:20:00 appldev ship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--=====================================================================
--API NAME:     Check_External_Credit
--TYPE:         PRIVATE
--COMMENTS:     This procedure validates the input parameters and call
--              the OM credit check engine.
--Parameters:
--IN
--OUT
--Version:  	Current Version   	1.0
--              Previous Version  	1.0
--=====================================================================

PROCEDURE Check_External_Credit
  ( p_api_version                IN NUMBER
  , p_init_msg_list              IN VARCHAR2 	:= FND_API.G_FALSE
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , p_customer_name	         IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_customer_number            IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_customer_id                IN NUMBER      := FND_API.G_MISS_NUM
  , p_bill_to_site_use_id        IN NUMBER      := FND_API.G_MISS_NUM
  , p_bill_to_address1           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address2           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address3           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address4           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_city               IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_country            IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_postal_code        IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_state              IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_county             IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_province           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_credit_check_rule_name     IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_credit_check_rule_id       IN NUMBER      := FND_API.G_MISS_NUM
  , p_functional_currency_code   IN VARCHAR2
  , p_transaction_currency_code  IN VARCHAR2
  , p_transaction_amount         IN NUMBER
  , p_operating_unit_name        IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_org_id                     IN NUMBER      := FND_API.G_MISS_NUM
  , x_result_out                OUT NOCOPY VARCHAR2
  , x_cc_hold_comment           OUT NOCOPY VARCHAR2
  );

END OE_EXTERNAL_CREDIT_PVT;

 

/
