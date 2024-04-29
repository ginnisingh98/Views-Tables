--------------------------------------------------------
--  DDL for Package Body OE_EXTERNAL_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EXTERNAL_CREDIT_PUB" AS
-- $Header: OEXPCECB.pls 120.0 2005/06/01 02:40:02 appldev noship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_External_Credit_PUB';
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
  )
IS
  l_api_name 	CONSTANT VARCHAR2(30) := 'Check_External_Credit';
  l_api_version	CONSTANT NUMBER       := 1.0;
BEGIN
  OE_DEBUG_PUB.Add('OEXPCECB: In Check_External_Credit');
  -- Check the API version and issue an error if the given API version does not
  -- match the one in this package.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    FND_MSG_PUB.Delete_Msg;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_API_VERSION_MISMATCH');
    FND_MESSAGE.SET_TOKEN ('API_NAME', l_api_name );
    FND_MESSAGE.SET_TOKEN ('P_API_VERSION', p_api_version );
    FND_MESSAGE.SET_TOKEN ('CURR_VER_NUM',l_api_version);
    FND_MESSAGE.SET_TOKEN ('CALLER_VER_NUM',p_api_version);
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
    OE_MSG_PUB.Initialize;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Call the OE_External_Credit_PVT.Check_External_Credit_PVT to
  -- perform credit checking.
  OE_External_Credit_PVT.Check_External_Credit (
      p_api_version 		=> p_api_version
    , p_init_msg_list 		=> p_init_msg_list
    , x_return_status		=> x_return_status
    , x_msg_count 		=> x_msg_count
    , x_msg_data           	=> x_msg_data
    , p_customer_name           => p_customer_name
    , p_customer_number         => p_customer_number
    , p_customer_id             => p_customer_id
    , p_bill_to_site_use_id  	=> p_bill_to_site_use_id
    , p_bill_to_address1      	=> p_bill_to_address1
    , p_bill_to_address2     	=> p_bill_to_address2
    , p_bill_to_address3    	=> p_bill_to_address3
    , p_bill_to_address4   	=> p_bill_to_address4
    , p_bill_to_city      	=> p_bill_to_city
    , p_bill_to_country  	=> p_bill_to_country
    , p_bill_to_postal_code     => p_bill_to_postal_code
    , p_bill_to_state   	=> p_bill_to_state
    , p_credit_check_rule_name  => p_credit_check_rule_name
    , p_credit_check_rule_id    => p_credit_check_rule_id
    , p_functional_currency_code  => p_functional_currency_code
    , p_transaction_currency_code => p_transaction_currency_code
    , p_transaction_amount  	=> p_transaction_amount
    , p_operating_unit_name  	=> p_operating_unit_name
    , p_org_id  		=> p_org_id
    , x_result_out		=> x_result_out
    , x_cc_hold_comment 	=> x_cc_hold_comment
  );
  OE_DEBUG_PUB.Add('OEXPCECB: x_return_status:   '||x_return_status);
  OE_DEBUG_PUB.Add('OEXPCECB: x_result_out:      '||x_result_out);
  OE_DEBUG_PUB.Add('OEXPCECB: x_cc_hold_comment: '||x_cc_hold_comment);
  OE_DEBUG_PUB.Add('OEXPCECB: Out Check_External_Credit');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_and_Get (
       p_count	=> x_msg_count
      ,p_data	=> x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_MSG_PUB.Count_and_Get (
       p_count  => x_msg_count
      ,p_data   => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (
          G_PKG_NAME
        , l_api_name);
    END IF;
    OE_MSG_PUB.Count_and_Get(
       p_count  => x_msg_count
      ,p_data   => x_msg_data);
  END Check_External_Credit;
END OE_EXTERNAL_CREDIT_PUB;

/
