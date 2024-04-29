--------------------------------------------------------
--  DDL for Package IBE_QUOTE_CHECKOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_CHECKOUT_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVQASS.pls 120.3 2005/12/15 06:00:21 khiremat ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_Checkout_Pvt
-- Purpose	    :
-- NOTE 	    :

-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

PROCEDURE submitQuote(
  p_api_version_number        IN  NUMBER
  ,p_commit                   IN  VARCHAR2 := FND_API.g_false
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.g_false
--p_authorize                 IN  VARCHAR2 := FND_API.g_false
  ,p_quote_Header_Id          IN  NUMBER
  ,p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE

  ,p_sharee_party_Id          IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_sharee_number	      IN  NUMBER   := FND_API.G_MISS_NUM

  ,p_submit_Control_Rec       IN  ASO_QUOTE_PUB.Submit_Control_Rec_Type
				  := ASO_QUOTE_PUB.G_MISS_Submit_Control_Rec

  ,p_customer_comments        IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_reason_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_salesrep_email_id        IN  VARCHAR2 := FND_API.G_MISS_CHAR

  -- 9/17/02: added to control calling validate_user_update
  ,p_validate_user            IN  VARCHAR2 := FND_API.G_TRUE
  ,p_minisite_id	      IN  NUMBER   := FND_API.G_MISS_NUM

  ,x_order_header_rec         OUT NOCOPY ASO_QUOTE_PUB.Order_Header_Rec_Type
     --Mannamra: Added for bug 4716044
  ,x_hold_flag                OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2
  ,x_msg_count                OUT NOCOPY NUMBER
  ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE Authorize_Credit_Card(
   p_qte_Header_Id           IN  NUMBER
  ,x_return_status            OUT NOCOPY VARCHAR2
  ,x_msg_count                OUT NOCOPY NUMBER
  ,x_msg_data                 OUT NOCOPY VARCHAR2
);
end IBE_Quote_Checkout_Pvt;

 

/
