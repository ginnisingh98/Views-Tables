--------------------------------------------------------
--  DDL for Package CS_CHARGE_DETAILS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_DETAILS_CUHK" AUTHID CURRENT_USER AS
/* $Header: cschrs.pls 120.0.12010000.3 2008/08/07 06:23:31 vpremach ship $ */


  /*======================================================================+
  ==
  ==  Package name      : CS_CHARGE_DETAILS_CUHK
  ==  Description       :  This is the Customer User Hook API.
  ==   The Customers can add customization procedures here for Pre and Post Processing.
  ==
  ==
  ==
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  11/18/2004  mviswana   Bug fixed  3868233 .
  ==  in Create_Charge_Details_Post, Update_Charge_Details_Pre and Update_Charge_Details_Post.
  ==  11/18/2004  mviswana   Bug Fixed  3951392 .
  ==  in Create_Charge_Details_Post, Update_Charge_Details_Pre and Update_Charge_Details_Post.
  ==  07/07/2005  mviswana   Bug Fixed 3951397
  ==  primary key unknown in user hook CS_CHARGE_DETAILS_CUHK
  ==
  ========================================================================*/
  /* Customer Procedure for pre processing in case of create charge details */

	Procedure  Create_Charge_Details_Pre(
		p_api_version      	        IN  NUMBER,
		p_init_msg_list    	        IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	        IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	        IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	        OUT NOCOPY VARCHAR2,
		x_msg_count       	        OUT NOCOPY NUMBER,
		x_object_version_number 	OUT NOCOPY NUMBER,
         	x_estimate_detail_id    	OUT NOCOPY NUMBER,
       	        x_line_number           	OUT NOCOPY NUMBER,
		x_msg_data         	    	OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	    	IN NUMBER DEFAULT NULL,
		p_resp_id          	   	IN NUMBER DEFAULT NULL,
    		p_user_id          	   	IN NUMBER DEFAULT NULL,
		p_login_id         	    	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control   	IN VARCHAR2 DEFAULT FND_API.G_TRUE,
		p_est_detail_rec        	IN CS_Charge_Details_PUB.Charges_Rec_Type);


  /* Customer Procedure for post processing in case of
	create charge details */


   Procedure Create_Charge_Details_Post(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT NOCOPY VARCHAR2,
		x_msg_count       	 OUT NOCOPY NUMBER,
		x_object_version_number  OUT NOCOPY NUMBER,
       	        x_estimate_detail_id     IN OUT NOCOPY NUMBER, --3951392
       	        x_line_number            OUT NOCOPY NUMBER,
		x_msg_data         	 OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    		p_user_id          	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control    IN VARCHAR2 DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);



  /* Customer Procedure for pre processing in case of update charge details */

	Procedure Update_Charge_Details_Pre(
		p_api_version      	        IN  NUMBER,
		p_init_msg_list    	        IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	        IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	        IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	        OUT  NOCOPY VARCHAR2,
		x_msg_count       	        OUT  NOCOPY  NUMBER,
		x_object_version_number 	OUT  NOCOPY NUMBER,
       	        x_estimate_detail_id            IN OUT NOCOPY NUMBER, --3951392
		x_msg_data         	    	OUT  NOCOPY VARCHAR2,
		p_resp_appl_id    	    	IN NUMBER DEFAULT NULL,
		p_resp_id          	   	IN NUMBER DEFAULT NULL,
    		p_user_id          	   	IN NUMBER DEFAULT NULL,
		p_login_id         	    	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control   	IN VARCHAR2 DEFAULT FND_API.G_TRUE,
		p_est_detail_rec        	IN CS_Charge_Details_PUB.Charges_Rec_Type);


  /* Customer Procedure for post processing in case of
	update charge details */


   Procedure Update_Charge_Details_Post(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT  NOCOPY VARCHAR2,
		x_msg_count       	 OUT  NOCOPY  NUMBER,
		x_object_version_number  OUT  NOCOPY NUMBER,
       	        x_estimate_detail_id     IN OUT NOCOPY NUMBER, --3951392
		x_msg_data         	 OUT  NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    		p_user_id          	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control    IN VARCHAR2 DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);



   /* Customer Procedure for pre processing in case of call pricing item */
    Procedure Call_Pricing_Item_Pre (
                p_inventory_item_id	IN NUMBER,
                p_price_list_id	        IN NUMBER,
                p_uom_code		IN VARCHAR2,
                p_currency_code	        IN VARCHAR2,
                p_quantity		IN NUMBER,
                p_org_id		IN NUMBER,
                x_list_price		OUT NOCOPY NUMBER,
                p_in_price_attr_tbl	IN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
                x_return_status	        OUT NOCOPY VARCHAR2,
                x_msg_count		OUT NOCOPY NUMBER,
                x_msg_data		OUT NOCOPY VARCHAR2 );

END  CS_CHARGE_DETAILS_CUHK ;

/
