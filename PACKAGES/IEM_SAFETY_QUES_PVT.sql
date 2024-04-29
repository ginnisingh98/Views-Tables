--------------------------------------------------------
--  DDL for Package IEM_SAFETY_QUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SAFETY_QUES_PVT" AUTHID CURRENT_USER as
/* $Header: iemvsfqs.pls 115.2 2002/12/02 23:53:28 sboorela shipped $*/

-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_SAFETY_QUEUES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_message_id IN   number,
--  p_message_size	IN   number,
--  p_sender_name	IN   VARCHAR2,
--  p_user_name	IN   VARCHAR2,
--  p_domain_name	IN   VARCHAR2,
--  p_message_priority	IN   VARCHAR2,
--  p_msg_status	IN   VARCHAR2,
--  p_subject	IN   VARCHAR2,
--  p_classification	IN   VARCHAR2,
--  p_score	IN   number,
--  p_sent_date IN   date,
--  p_customer_id IN   NUMBER,
--  p_product_id IN   NUMBER,
--  p_key1	IN	VARCHAR2,
--  p_value1	IN	VARCHAR2,
--  p_key2	IN	VARCHAR2,
--  p_value2	IN	VARCHAR2,
--  p_key3	IN	VARCHAR2,
--  p_value3	IN	VARCHAR2,
--  p_key4	IN	VARCHAR2,
--  p_value4	IN	VARCHAR2,
--  p_key5	IN	VARCHAR2,
--  p_value5	IN	VARCHAR2,
--  p_key6	IN	VARCHAR2,
--  p_value6	IN	VARCHAR2,
--  p_key7	IN	VARCHAR2,
--  p_value7	IN	VARCHAR2,
--  p_key8	IN	VARCHAR2,
--  p_value8	IN	VARCHAR2,
--  p_key9	IN	VARCHAR2,
--  p_value9	IN	VARCHAR2,
--  p_key10	IN	VARCHAR2,
--  p_value10	IN	VARCHAR2,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count		OUT	NUMBER
--	x_msg_data		OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2:= FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2:= FND_API.G_FALSE,
  				p_MESSAGE_ID IN NUMBER,
				p_MESSAGE_SIZE IN NUMBER,
				p_SENDER_NAME IN VARCHAR2,
 				p_USER_NAME	IN VARCHAR2,
				p_DOMAIN_NAME IN VARCHAR2,
 				p_MESSAGE_PRIORITY IN VARCHAR2,
				p_MSG_STATUS IN VARCHAR2,
				p_SUBJECT IN VARCHAR2,
				p_CLASSIFICATION	IN VARCHAR2,
				p_SCORE IN	NUMBER,
				p_SENT_DATE IN DATE,
				p_CUSTOMER_ID IN NUMBER,
				p_PRODUCT_ID IN NUMBER,
				p_key1     IN   VARCHAR2,
				p_value1   IN   VARCHAR2,
				p_key2     IN   VARCHAR2,
				p_value2   IN   VARCHAR2,
				p_key3     IN   VARCHAR2,
				p_value3   IN   VARCHAR2,
				p_key4     IN   VARCHAR2,
				p_value4   IN   VARCHAR2,
				p_key5     IN   VARCHAR2,
				p_value5   IN   VARCHAR2,
				p_key6     IN   VARCHAR2,
				p_value6   IN   VARCHAR2,
				p_key7     IN   VARCHAR2,
				p_value7   IN   VARCHAR2,
				p_key8     IN   VARCHAR2,
				p_value8   IN   VARCHAR2,
				p_key9     IN   VARCHAR2,
				p_value9   IN   VARCHAR2,
				p_key10    IN   VARCHAR2,
				p_value10  IN   VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_SAFETY_QUEUES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_message_id	in number,
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_message_id	IN   NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: requeue_item
--  Type	: 	Private
--  Function	: This procedure requeues a record in the table IEM_SAFETY_QUEUES
--  			  into Processing AQ
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_message_id	in number,
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE requeue_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_message_id	IN   NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );



END IEM_SAFETY_QUES_PVT;

 

/
