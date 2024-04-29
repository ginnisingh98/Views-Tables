--------------------------------------------------------
--  DDL for Package AST_UWQ_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: astugens.pls 120.1 2005/08/10 02:20:25 appldev ship $ */

FUNCTION Convert_to_server_time(p_client_time IN date) return DATE;

  	g_jtf_note_contexts_tab     jtf_notes_pub.jtf_note_contexts_tbl_type;

	PROCEDURE Create_Contact(
		p_admin_flag			IN	VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			IN	NUMBER,
		p_customer_id			IN	NUMBER,
		p_lead_id				IN	NUMBER,
		p_contact_party_id		IN	NUMBER,
		p_address_id			IN	NUMBER,
		x_return_status           OUT NOCOPY      VARCHAR2,
		x_msg_count               OUT NOCOPY      NUMBER,
		x_msg_data                OUT NOCOPY      VARCHAR2
	);

	PROCEDURE create_task (
		p_task_name               	IN       	VARCHAR2,
		p_task_type_name          	IN       	VARCHAR2 	DEFAULT NULL,
		p_task_type_id            	IN       	NUMBER 	DEFAULT NULL,
		p_description             	IN       	VARCHAR2 	DEFAULT NULL,
		p_owner_id                	IN	   	NUMBER 	DEFAULT NULL,
		p_customer_id             	IN       	NUMBER 	DEFAULT NULL,
		p_contact_id              	IN       	NUMBER 	DEFAULT NULL,
		p_date_type		  		IN	   	VARCHAR2 	DEFAULT NULL,
		p_start_date    	  		IN       	DATE 	DEFAULT NULL,
		p_end_date      	  		IN       	DATE 	DEFAULT NULL,
		p_source_object_type_code	IN       	VARCHAR2 	DEFAULT NULL,
		p_source_object_id        	IN       	NUMBER 	DEFAULT NULL,
		p_source_object_name      	IN       	VARCHAR2 	DEFAULT NULL,
		p_phone_id		  		IN	   	NUMBER 	DEFAULT NULL,
		p_address_id		  		IN	   	NUMBER 	DEFAULT NULL,
		p_duration		  		IN	   	NUMBER	DEFAULT	NULL,
		p_duration_uom		  		IN	   	VARCHAR2 	DEFAULT NULL,
		p_called_node		  		IN	   	VARCHAR2,
		x_return_status            OUT NOCOPY      	VARCHAR2,
		x_msg_count                OUT NOCOPY      	NUMBER,
		x_msg_data                 OUT NOCOPY      	VARCHAR2,
		x_task_id                  OUT NOCOPY      	NUMBER
	);

	PROCEDURE add_context_to_table (
		p_counter 			  IN	   BINARY_INTEGER,
		p_context_id 			  IN	   NUMBER,
		p_context_type			  IN	   VARCHAR2,
		p_last_update_date 		  IN	   DATE,
		p_last_updated_by 		  IN	   NUMBER,
		p_last_update_login		  IN	   NUMBER,
		p_creation_date 		  IN	   DATE,
		p_created_by			  IN	   NUMBER
	);

	PROCEDURE create_note (
		p_source_object_id          	IN	   NUMBER,
		p_source_object_code        	IN 	   VARCHAR2,
		p_notes					IN 	   VARCHAR2,
		p_notes_detail			  	IN 	   VARCHAR2,
		p_entered_by			  	IN 	   NUMBER,
		p_entered_date			  	IN 	   DATE,
		p_last_update_date		  	IN 	   DATE,
		p_last_updated_by		  	IN 	   NUMBER,
		p_creation_date		  	IN 	   DATE,
		p_created_by			  	IN 	   NUMBER,
		p_last_update_login		  	IN 	   NUMBER,
		p_party_id			  	IN	   NUMBER,
		x_jtf_note_id                OUT NOCOPY    NUMBER,
		x_return_status              OUT NOCOPY    VARCHAR2,
		x_msg_count                  OUT NOCOPY 	   NUMBER,
		x_msg_data                   OUT NOCOPY    VARCHAR2
	);
	--New parameter p_total_revenue_forecast_amt added for R12 forecast amount enhancement
	PROCEDURE header_rec_set (
		p_last_update_date 		  IN 	   DATE,
		p_lead_id 			  IN 	   NUMBER,
		p_lead_number 			  IN 	   VARCHAR2,
		p_description 			  IN 	   VARCHAR2,
		p_status_code 			  IN 	   VARCHAR2,
		p_source_promotion_id	  IN 	   NUMBER,
		p_customer_id			  IN 	   NUMBER,
		p_address_id			  IN 	   NUMBER,
		p_sales_stage_id		  IN 	   NUMBER,
		p_win_probability		  IN 	   NUMBER,
		p_total_amount			  IN 	   NUMBER,
		p_total_revenue_forecast_amt	  IN 	   NUMBER,
		p_channel_code 		  IN 	   VARCHAR2,
		p_decision_date 		  IN 	   DATE,
		p_currency_code 		  IN 	   VARCHAR2,
		p_vehicle_response_code    IN 	   VARCHAR2,
		p_customer_budget          IN         NUMBER,
		p_close_comment 		  IN 	   VARCHAR2,
		p_parent_project 		  IN 	   VARCHAR2,
		p_freeze_flag 			  IN 	   VARCHAR2,
		header_rec 			  IN 	   OUT NOCOPY AS_OPPORTUNITY_PUB.Header_Rec_type
	);

	PROCEDURE create_opportunity (
		p_admin_flag			IN  VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			  IN			NUMBER,
		p_last_update_date 		  IN			DATE,
		p_lead_id 			  IN			NUMBER,
		p_lead_number 			  IN 	   	VARCHAR2,
		p_description 			  IN 	   	VARCHAR2,
		p_status_code 			  IN 	   	VARCHAR2,
		p_source_code       		  IN	        VARCHAR2, -- Added by Sumita for bug # 3812865
		p_source_code_id       		IN	NUMBER,
		p_customer_id			  IN 	   	NUMBER,
		p_contact_party_id			IN	   	NUMBER,
		p_address_id			  IN 	   	NUMBER,
		p_sales_stage_id		  IN 	   	NUMBER,
		p_win_probability		  IN 	   	NUMBER,
		p_total_amount			  IN 	   	NUMBER,
		p_total_revenue_forecast_amt	  IN 	   NUMBER,
		p_channel_code			  IN 	   	VARCHAR2,
		p_decision_date 		  IN 	   	DATE,
		p_currency_code 		  IN 	   	VARCHAR2,
		p_vehicle_response_code    IN 	   VARCHAR2,
		p_customer_budget          IN         NUMBER,
		p_close_comment 		  IN 	   	VARCHAR2,
		p_parent_project 		  IN 	   	VARCHAR2,
		p_freeze_flag 			  IN 	   	VARCHAR2,
		p_salesgroup_id		  IN	   		NUMBER,
		p_called_node			  IN	   		VARCHAR2,
		p_action_key                          IN                  VARCHAR2, -- Added by Sumita for bug # 3812865
		x_return_status            OUT NOCOPY      	VARCHAR2,
		x_msg_count                OUT NOCOPY      	NUMBER,
		x_msg_data                 OUT NOCOPY      	VARCHAR2,
		x_lead_id                  OUT NOCOPY      	NUMBER
	);

	PROCEDURE create_lead (
		p_admin_group_id			IN	   	NUMBER,
		p_identity_salesforce_id		IN	   	NUMBER,
		p_status_code				IN	   	VARCHAR2,
		p_customer_id				IN	   	NUMBER,
		p_contact_party_id			IN	   	NUMBER,
		p_address_id				IN	   	NUMBER,
		p_admin_flag				IN	   	VARCHAR2,
		p_assign_to_salesforce_id   	IN     	NUMBER,
		p_assign_sales_group_id     	IN     	NUMBER,
		p_budget_status_code		IN	   	VARCHAR2,
		p_description				IN	   	VARCHAR2,
		p_source_code       		        IN	   	VARCHAR2, -- Added by Sumita for bug # 3812865
		p_source_code_id       		IN	   	NUMBER,
		p_lead_rank_id				IN	   	NUMBER,
		p_decision_timeframe_code	IN	   	VARCHAR2,
		p_initiating_contact_id		IN	   	NUMBER,
		p_phone_id				IN	   	NUMBER,
		p_called_node			  	IN	   	VARCHAR2,
		p_action_key                                IN            VARCHAR2, -- Added by Sumita for bug # 3812865
		x_sales_lead_id           OUT NOCOPY    	NUMBER,
		x_return_status           OUT NOCOPY    	VARCHAR2,
		x_msg_count               OUT NOCOPY    	NUMBER,
		x_msg_data                OUT NOCOPY    	VARCHAR2
	);

     PROCEDURE update_lead (
          p_sales_lead_id               IN      NUMBER := FND_API.G_MISS_NUM,
          p_admin_group_id              IN      NUMBER := FND_API.G_MISS_NUM,
          p_identity_salesforce_id      IN      NUMBER := FND_API.G_MISS_NUM,
		p_last_update_date 		     IN	   DATE,
          p_status_code                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_customer_id                 IN      NUMBER := FND_API.G_MISS_NUM,
          p_address_id                  IN      NUMBER := FND_API.G_MISS_NUM,
          p_assign_to_salesforce_id     IN      NUMBER := FND_API.G_MISS_NUM,
          p_admin_flag                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_assign_sales_group_id       IN      NUMBER := FND_API.G_MISS_NUM,
          p_budget_status_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_description                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_source_promotion_id         IN      NUMBER := FND_API.G_MISS_NUM,
          p_lead_rank_id                IN      NUMBER := FND_API.G_MISS_NUM,
          p_decision_timeframe_code     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_initiating_contact_id       IN      NUMBER := FND_API.G_MISS_NUM,
          p_accept_flag                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_qualified_flag              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          p_phone_id                    IN      NUMBER := FND_API.G_MISS_NUM,
          p_close_reason_code           IN      VARCHAR2  := FND_API.G_MISS_CHAR,
          p_called_node                 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
          x_return_status           OUT NOCOPY    VARCHAR2,
          x_msg_count               OUT NOCOPY    NUMBER,
          x_msg_data                OUT NOCOPY    VARCHAR2
     );

	PROCEDURE create_opp_for_lead (
		p_admin_flag	 	IN	VARCHAR2,
		p_sales_lead_id	IN	NUMBER,
		p_resource_id		IN	NUMBER,
		p_salesgroup_id	IN	NUMBER,
		p_called_node		IN	VARCHAR2,
		x_app_launch	 OUT NOCOPY VARCHAR2,
		x_return_status     OUT NOCOPY  VARCHAR2,
		x_msg_count         OUT NOCOPY  NUMBER,
		x_msg_data          OUT NOCOPY  VARCHAR2,
		x_opportunity_id    OUT NOCOPY NUMBER
	);

	PROCEDURE reassign_lead (
		p_admin_flag			IN	VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_default_group_id		IN	NUMBER,
		p_person_id				IN	NUMBER,
		p_resource_id			IN	NUMBER,
		p_sales_lead_id			IN	NUMBER,
		p_new_salesforce_id		IN	NUMBER,
		p_last_update_date      IN  DATE,
		p_new_sales_group_id	IN	NUMBER,
		p_new_owner_id			IN	NUMBER,	--person_id of new owner
		p_called_node			IN	VARCHAR2,
		x_return_status      OUT NOCOPY  VARCHAR2,
		x_msg_count          OUT NOCOPY  NUMBER,
		x_msg_data           OUT NOCOPY  VARCHAR2
	);

	procedure get_potential_opportunity (
		p_sales_lead_id 	IN	  NUMBER,
 		p_admin_flag		IN	  VARCHAR2,
 		p_admin_group_id	IN	  NUMBER,
 		p_resource_id		IN	  NUMBER,
 		x_query_string  OUT NOCOPY   varchar2
	);

	PROCEDURE update_opportunity (
		p_admin_flag			IN  VARCHAR2,
		p_admin_group_id		IN	NUMBER,
		p_resource_id			  IN			NUMBER,
		p_last_update_date 		  IN			DATE,
		p_lead_id 			  IN			NUMBER,
		p_lead_number 			  IN 	   	VARCHAR2,
		p_description 			  IN 	   	VARCHAR2,
		p_status_code 			  IN 	   	VARCHAR2,
		p_close_reason_code		  IN		VARCHAR2,
		p_source_promotion_id	  IN 	   	NUMBER,
		p_customer_id			  IN 	   	NUMBER,
		p_contact_party_id			IN	   	NUMBER,
		p_address_id			  IN 	   	NUMBER,
		p_sales_stage_id		  IN 	   	NUMBER,
		p_win_probability		  IN 	   	NUMBER,
		p_total_amount			  IN 	   	NUMBER,
		p_total_revenue_forecast_amt	  IN 	   NUMBER,
		p_channel_code			  IN 	   	VARCHAR2,
		p_decision_date 		  IN 	   	DATE,
		p_currency_code 		  IN 	   	VARCHAR2,
		p_vehicle_response_code    IN           VARCHAR2,
		p_customer_budget          IN           NUMBER,
		p_close_comment 		  IN 	   	VARCHAR2,
		p_parent_project 		  IN 	   	VARCHAR2,
		p_freeze_flag 			  IN 	   	VARCHAR2,
		p_called_node			  IN	   		VARCHAR2,
		x_return_status            OUT NOCOPY      	VARCHAR2,
		x_msg_count                OUT NOCOPY      	NUMBER,
		x_msg_data                 OUT NOCOPY      	VARCHAR2,
		x_lead_id                  OUT NOCOPY      	NUMBER
	);
END ast_uwq_wrapper_pkg;

 

/
