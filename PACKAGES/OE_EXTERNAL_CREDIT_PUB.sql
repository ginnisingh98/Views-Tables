--------------------------------------------------------
--  DDL for Package OE_EXTERNAL_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EXTERNAL_CREDIT_PUB" AUTHID CURRENT_USER AS
-- $Header: OEXPCECS.pls 120.0 2005/06/01 00:57:35 appldev noship $
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
--TYPE:         PUBLIC
--COMMENTS:     This is the main starting procedure for the check
--              external credit API. It check the api version and if it
--              matches, proceed to calling the private procedure.
--Parameters:
--IN
--OUT
--Version:  	Current Version   	1.0
--              Previous Version  	1.0
--=====================================================================

PROCEDURE Check_External_Credit
  ( p_api_version                IN NUMBER
  , p_init_msg_list              IN VARCHAR2 	:= FND_API.G_FALSE
  , x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
  , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
  , p_credit_check_rule_name     IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_credit_check_rule_id       IN NUMBER      := FND_API.G_MISS_NUM
  , p_functional_currency_code   IN VARCHAR2
  , p_transaction_currency_code  IN VARCHAR2
  , p_transaction_amount         IN NUMBER
  , p_operating_unit_name        IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_org_id                     IN NUMBER      := FND_API.G_MISS_NUM
  , x_result_out                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  , x_cc_hold_comment           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  );

END OE_EXTERNAL_CREDIT_PUB;

 

/
