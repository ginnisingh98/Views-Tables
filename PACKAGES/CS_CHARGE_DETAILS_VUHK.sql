--------------------------------------------------------
--  DDL for Package CS_CHARGE_DETAILS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_DETAILS_VUHK" AUTHID CURRENT_USER AS
  /* $Header: cschvrs.pls 120.0 2006/02/09 14:59:59 mviswana noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/



  	/* Vertcal Industry Procedure for pre processing in case of create charge details */

	PROCEDURE Create_Charge_Details_Pre(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT NOCOPY VARCHAR2,
		x_msg_count       	 OUT NOCOPY  NUMBER,
		x_object_version_number  OUT NOCOPY NUMBER,
       	        x_estimate_detail_id     OUT NOCOPY NUMBER,
       	        x_line_number            OUT NOCOPY NUMBER,
		x_msg_data         	 OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    		p_user_id          	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control    IN NUMBER DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);


  /* Vertcal Industry Procedure for post processing in case of create Charge Details */


	PROCEDURE Create_Charge_Details_Post(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT NOCOPY VARCHAR2,
		x_msg_count       	 OUT NOCOPY  NUMBER,
		x_object_version_number  OUT NOCOPY NUMBER,
       	        x_estimate_detail_id     OUT NOCOPY NUMBER,
       	        x_line_number            OUT NOCOPY NUMBER,
		x_msg_data         	 OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    		p_user_id          	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       	        p_transaction_control    IN NUMBER DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);


  /* Vertcal Industry Procedure for pre processing in case of
	Update Charge Details */

	PROCEDURE Update_Charge_Details_Pre(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT NOCOPY VARCHAR2,
		x_msg_count       	 OUT NOCOPY  NUMBER,
		x_object_version_number  OUT NOCOPY NUMBER,
                x_estimate_detail_id     OUT NOCOPY NUMBER,
		x_msg_data         	 OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    	        p_user_id          	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                p_transaction_control    IN NUMBER DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);


  /* Vertcal Industry Procedure for post processing in case of Update Charge Details */


	PROCEDURE Update_Charge_Details_Post(
		p_api_version      	 IN  NUMBER,
		p_init_msg_list    	 IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit           	 IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
		p_validation_level 	 IN  NUMBER  DEFAULT  FND_API.G_VALID_LEVEL_FULL,
		x_return_status    	 OUT NOCOPY VARCHAR2,
		x_msg_count       	 OUT NOCOPY  NUMBER,
		x_object_version_number  OUT NOCOPY NUMBER,
                x_estimate_detail_id     OUT NOCOPY NUMBER,
		x_msg_data         	 OUT NOCOPY VARCHAR2,
		p_resp_appl_id    	 IN NUMBER DEFAULT NULL,
		p_resp_id          	 IN NUMBER DEFAULT NULL,
    	p_user_id          	   	 IN NUMBER DEFAULT NULL,
		p_login_id         	 IN NUMBER DEFAULT FND_API.G_MISS_NUM,
       p_transaction_control   	         IN NUMBER DEFAULT FND_API.G_TRUE,
		p_est_detail_rec         IN CS_Charge_Details_PUB.Charges_Rec_Type);

END CS_CHARGE_DETAILS_VUHK ;

 

/
