--------------------------------------------------------
--  DDL for Package IEM_PREPENQDEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_PREPENQDEQ_PUB" AUTHID CURRENT_USER as
/* $Header: iemppeds.pls 115.11 2002/12/04 20:23:20 sboorela shipped $*/
-- Start of Comments
-- API name      : 'PREP_ENQUEUE`
-- Purpose          : Enqueues a message into pre-processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--        p_api_version_number IN NUMBER Required
--        p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--        p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_msg_id    IN NUMBER Required
--  p_msg_size   IN NUMBER Required
--  p_sender_name   IN VARCHAR2 Required
--  p_user_name   IN VARCHAR2 Required
--  p_domain_name   IN VARCHAR2 Required
--  p_priority   IN VARCHAR2 Optional
--  p_msg_status   IN VARCHAR2  Optional
--  p_key1    IN VARCHAR2  Optional
--  p_val1    IN VARCHAR2 Optional
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE PREP_ENQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    			 IN  NUMBER,
 p_msg_size			 IN  NUMBER,
 p_sender_name   		 IN  VARCHAR2,
 p_user_name   		 IN  VARCHAR2,
 p_domain_name   		 IN  VARCHAR2,
 p_priority   			 IN  VARCHAR2,
 p_msg_status   		 IN  VARCHAR2,
 p_key1    			 IN  VARCHAR2,
 p_val1    			 IN  VARCHAR2,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2);


-- Start of Comments
-- API name      : 'PREP_DEQUEUE`
-- Purpose          : Dequeues a message from pre-processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    			 OUT NOCOPY  NUMBER,
 p_msg_size   			 OUT NOCOPY  NUMBER,
 p_sender_name   		 OUT NOCOPY  VARCHAR2,
 p_user_name   		 OUT NOCOPY  VARCHAR2,
 p_domain_name   		 OUT NOCOPY  VARCHAR2,
 p_priority   			 OUT NOCOPY  VARCHAR2,
 p_msg_status   		 OUT NOCOPY  VARCHAR2,
 p_key1    			 OUT NOCOPY  VARCHAR2,
 p_val1    			 OUT NOCOPY  VARCHAR2,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data       		 OUT NOCOPY  VARCHAR2);


-- Start of Comments
-- API name      : 'PREP_DEQUEUE`
-- Purpose          : Dequeues a message from pre-processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_qopt   IN VARCHAR2
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   			 IN VARCHAR2,
 p_msg_id    			 OUT NOCOPY  NUMBER,
 p_msg_size   			 OUT NOCOPY  NUMBER,
 p_sender_name   		 OUT NOCOPY  VARCHAR2,
 p_user_name   		 OUT NOCOPY  VARCHAR2,
 p_domain_name   		 OUT NOCOPY  VARCHAR2,
 p_priority   			 OUT NOCOPY  VARCHAR2,
 p_msg_status   		 OUT NOCOPY  VARCHAR2,
 p_key1    			 OUT NOCOPY  VARCHAR2,
 p_val1    			 OUT NOCOPY  VARCHAR2,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data       		 OUT NOCOPY  VARCHAR2);


-- Start of Comments
-- API name      : 'PREP_DEQUEUE`
-- Purpose          : Dequeues a message from pre-processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_qopt   IN VARCHAR2
--  p_qdeq   IN VARCHAR2
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   			 IN VARCHAR2,
 p_qdeq   			 IN VARCHAR2,
 p_msg_id    			 OUT NOCOPY  NUMBER,
 p_msg_size   			 OUT NOCOPY  NUMBER,
 p_sender_name   		 OUT NOCOPY  VARCHAR2,
 p_user_name   		 OUT NOCOPY  VARCHAR2,
 p_domain_name   		 OUT NOCOPY  VARCHAR2,
 p_priority   			 OUT NOCOPY  VARCHAR2,
 p_msg_status   		 OUT NOCOPY  VARCHAR2,
 p_key1    			 OUT NOCOPY  VARCHAR2,
 p_val1    			 OUT NOCOPY  VARCHAR2,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data       		 OUT NOCOPY  VARCHAR2);


-- Start of Comments
-- API name      : 'PROC_ENQUEUE`
-- Purpose          : Enqueues a message into processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--  p_msg_id    IN NUMBER
--  p_msg_size   IN NUMBER
--  p_sender_name   IN VARCHAR2
--  p_user_name   IN VARCHAR2
--  p_domain_name   IN VARCHAR2
--  p_priority   IN VARCHAR2
--  p_msg_status   IN VARCHAR2
--  p_subject    IN VARCHAR2
--  p_sent_date   IN DATE
--  p_customer_id   IN NUMBER
--  p_product_id   IN NUMBER
--  p_classification  IN VARCHAR2
--  p_score_percent  IN NUMBER
--  p_info_id    IN NUMBER
--  p_key1    IN VARCHAR2
--  p_val1    IN VARCHAR2
--  p_key2    IN VARCHAR2
--  p_val2    IN VARCHAR2
--  p_key3    IN VARCHAR2
--  p_val3    IN VARCHAR2
--  p_key4    IN VARCHAR2
--  p_val4    IN VARCHAR2
--  p_key5    IN VARCHAR2
--  p_val5    IN VARCHAR2
--  p_key6    IN VARCHAR2
--  p_val6    IN VARCHAR2
--  p_key7    IN VARCHAR2
--  p_val7    IN VARCHAR2
--  p_key8    IN VARCHAR2
--  p_val8    IN VARCHAR2
--  p_key9    IN VARCHAR2
--  p_val9    IN VARCHAR2
--  p_key10    IN VARCHAR2
--  p_val10    IN VARCHAR2
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments

PROCEDURE PROC_ENQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    		IN  NUMBER,
 p_msg_size   		IN  NUMBER,
 p_sender_name   	IN  VARCHAR2,
 p_user_name   	IN  VARCHAR2,
 p_domain_name   	IN  VARCHAR2,
 p_priority   		IN  VARCHAR2,
 p_msg_status   	IN  VARCHAR2,
 p_subject    		IN VARCHAR2,
 p_sent_date   	IN date,
 p_customer_id      IN number,
 p_product_id       IN number,
 p_classification   IN varchar2,
 p_score_percent    IN number,
 p_info_id          IN number,
 p_key1             IN varchar2,
 p_val1             IN varchar2,
 p_key2             IN varchar2,
 p_val2             IN varchar2,
 p_key3             IN varchar2,
 p_val3             IN varchar2,
 p_key4             IN varchar2,
 p_val4             IN varchar2,
 p_key5             IN varchar2,
 p_val5             IN varchar2,
 p_key6             IN varchar2,
 p_val6             IN varchar2,
 p_key7             IN varchar2,
 p_val7             IN varchar2,
 p_key8             IN varchar2,
 p_val8             IN varchar2,
 p_key9             IN varchar2,
 p_val9             IN varchar2,
 p_key10            IN varchar2,
 p_val10            IN varchar2,
 x_msg_count    OUT NOCOPY  NUMBER,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_data   	 OUT NOCOPY VARCHAR2);

-- Start of Comments
-- API name      : 'PROC_DEQUEUE`
-- Purpose          : Dequeues a message from processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_subject    OUT VARCHAR2
--  p_sent_date   OUT DATE
--  p_customer_id   OUT NUMBER
--  p_product_id   OUT NUMBER
--  p_classification  OUT VARCHAR2
--  p_score_percent  OUT NUMBER
--  p_info_id    OUT NUMBER
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--  p_key2    OUT VARCHAR2
--  p_val2    OUT VARCHAR2
--  p_key3    OUT VARCHAR2
--  p_val3    OUT VARCHAR2
--  p_key4    OUT VARCHAR2
--  p_val4    OUT VARCHAR2
--  p_key5    OUT VARCHAR2
--  p_val5    OUT VARCHAR2
--  p_key6    OUT VARCHAR2
--  p_val6    OUT VARCHAR2
--  p_key7    OUT VARCHAR2
--  p_val7    OUT VARCHAR2
--  p_key8    OUT VARCHAR2
--  p_val8    OUT VARCHAR2
--  p_key9    OUT VARCHAR2
--  p_val9    OUT VARCHAR2
--  p_key10    OUT VARCHAR2
--  p_val10    OUT VARCHAR2
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments

PROCEDURE PROC_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    	 OUT NOCOPY  NUMBER,
 p_msg_size   	 OUT NOCOPY  NUMBER,
 p_sender_name    OUT NOCOPY  VARCHAR2,
 p_user_name    OUT NOCOPY  VARCHAR2,
 p_domain_name    OUT NOCOPY  VARCHAR2,
 p_priority   	 OUT NOCOPY  VARCHAR2,
 p_msg_status    OUT NOCOPY  VARCHAR2,
 p_subject    	 OUT NOCOPY VARCHAR2,
 p_sent_date    OUT NOCOPY date,
 p_customer_id    OUT NOCOPY number,
 p_product_id    OUT NOCOPY number,
 p_classification   OUT NOCOPY varchar2,
 p_score_percent   OUT NOCOPY number,
 p_info_id    	 OUT NOCOPY number,
 p_key1             OUT NOCOPY varchar2,
 p_val1             OUT NOCOPY varchar2,
 p_key2             OUT NOCOPY varchar2,
 p_val2             OUT NOCOPY varchar2,
 p_key3             OUT NOCOPY varchar2,
 p_val3             OUT NOCOPY varchar2,
 p_key4             OUT NOCOPY varchar2,
 p_val4             OUT NOCOPY varchar2,
 p_key5             OUT NOCOPY varchar2,
 p_val5             OUT NOCOPY varchar2,
 p_key6             OUT NOCOPY varchar2,
 p_val6             OUT NOCOPY varchar2,
 p_key7             OUT NOCOPY varchar2,
 p_val7             OUT NOCOPY varchar2,
 p_key8             OUT NOCOPY varchar2,
 p_val8             OUT NOCOPY varchar2,
 p_key9             OUT NOCOPY varchar2,
 p_val9             OUT NOCOPY varchar2,
 p_key10            OUT NOCOPY varchar2,
 p_val10            OUT NOCOPY varchar2,
 x_msg_count    OUT NOCOPY  NUMBER,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_data        OUT NOCOPY  VARCHAR2);

-- Start of Comments
-- API name      : 'PROC_DEQUEUE`
-- Purpose          : Dequeues a message from processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--  p_qopt   IN VARCHAR2
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_subject    OUT VARCHAR2
--  p_sent_date   OUT DATE
--  p_customer_id   OUT NUMBER
--  p_product_id   OUT NUMBER
--  p_classification  OUT VARCHAR2
--  p_score_percent  OUT NUMBER
--  p_info_id    OUT NUMBER
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--  p_key2    OUT VARCHAR2
--  p_val2    OUT VARCHAR2
--  p_key3    OUT VARCHAR2
--  p_val3    OUT VARCHAR2
--  p_key4    OUT VARCHAR2
--  p_val4    OUT VARCHAR2
--  p_key5    OUT VARCHAR2
--  p_val5    OUT VARCHAR2
--  p_key6    OUT VARCHAR2
--  p_val6    OUT VARCHAR2
--  p_key7    OUT VARCHAR2
--  p_val7    OUT VARCHAR2
--  p_key8    OUT VARCHAR2
--  p_val8    OUT VARCHAR2
--  p_key9    OUT VARCHAR2
--  p_val9    OUT VARCHAR2
--  p_key10    OUT VARCHAR2
--  p_val10    OUT VARCHAR2
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments

PROCEDURE PROC_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   		IN VARCHAR2,
 p_msg_id    	 OUT NOCOPY  NUMBER,
 p_msg_size   	 OUT NOCOPY  NUMBER,
 p_sender_name    OUT NOCOPY  VARCHAR2,
 p_user_name    OUT NOCOPY  VARCHAR2,
 p_domain_name    OUT NOCOPY  VARCHAR2,
 p_priority   	 OUT NOCOPY  VARCHAR2,
 p_msg_status    OUT NOCOPY  VARCHAR2,
 p_subject    	 OUT NOCOPY VARCHAR2,
 p_sent_date    OUT NOCOPY date,
 p_customer_id    OUT NOCOPY number,
 p_product_id    OUT NOCOPY number,
 p_classification   OUT NOCOPY varchar2,
 p_score_percent   OUT NOCOPY number,
 p_info_id    	 OUT NOCOPY number,
 p_key1             OUT NOCOPY varchar2,
 p_val1             OUT NOCOPY varchar2,
 p_key2             OUT NOCOPY varchar2,
 p_val2             OUT NOCOPY varchar2,
 p_key3             OUT NOCOPY varchar2,
 p_val3             OUT NOCOPY varchar2,
 p_key4             OUT NOCOPY varchar2,
 p_val4             OUT NOCOPY varchar2,
 p_key5             OUT NOCOPY varchar2,
 p_val5             OUT NOCOPY varchar2,
 p_key6             OUT NOCOPY varchar2,
 p_val6             OUT NOCOPY varchar2,
 p_key7             OUT NOCOPY varchar2,
 p_val7             OUT NOCOPY varchar2,
 p_key8             OUT NOCOPY varchar2,
 p_val8             OUT NOCOPY varchar2,
 p_key9             OUT NOCOPY varchar2,
 p_val9             OUT NOCOPY varchar2,
 p_key10            OUT NOCOPY varchar2,
 p_val10            OUT NOCOPY varchar2,
 x_msg_count    OUT NOCOPY  NUMBER,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_data        OUT NOCOPY  VARCHAR2);

-- Start of Comments
-- API name      : 'PROC_DEQUEUE`
-- Purpose          : Dequeues a message from processing AQ
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--  p_qopt   IN VARCHAR2
--  p_qdeq   IN VARCHAR2
--  p_msg_id    OUT NUMBER
--  p_msg_size   OUT NUMBER
--  p_sender_name   OUT VARCHAR2
--  p_user_name   OUT VARCHAR2
--  p_domain_name   OUT VARCHAR2
--  p_priority   OUT VARCHAR2
--  p_msg_status   OUT VARCHAR2
--  p_subject    OUT VARCHAR2
--  p_sent_date   OUT DATE
--  p_customer_id   OUT NUMBER
--  p_product_id   OUT NUMBER
--  p_classification  OUT VARCHAR2
--  p_score_percent  OUT NUMBER
--  p_info_id    OUT NUMBER
--  p_key1    OUT VARCHAR2
--  p_val1    OUT VARCHAR2
--  p_key2    OUT VARCHAR2
--  p_val2    OUT VARCHAR2
--  p_key3    OUT VARCHAR2
--  p_val3    OUT VARCHAR2
--  p_key4    OUT VARCHAR2
--  p_val4    OUT VARCHAR2
--  p_key5    OUT VARCHAR2
--  p_val5    OUT VARCHAR2
--  p_key6    OUT VARCHAR2
--  p_val6    OUT VARCHAR2
--  p_key7    OUT VARCHAR2
--  p_val7    OUT VARCHAR2
--  p_key8    OUT VARCHAR2
--  p_val8    OUT VARCHAR2
--  p_key9    OUT VARCHAR2
--  p_val9    OUT VARCHAR2
--  p_key10    OUT VARCHAR2
--  p_val10    OUT VARCHAR2
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments

PROCEDURE PROC_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   		IN VARCHAR2,
 p_qdeq   		IN VARCHAR2,
 p_msg_id    	 OUT NOCOPY  NUMBER,
 p_msg_size   	 OUT NOCOPY  NUMBER,
 p_sender_name    OUT NOCOPY  VARCHAR2,
 p_user_name    OUT NOCOPY  VARCHAR2,
 p_domain_name    OUT NOCOPY  VARCHAR2,
 p_priority   	 OUT NOCOPY  VARCHAR2,
 p_msg_status    OUT NOCOPY  VARCHAR2,
 p_subject    	 OUT NOCOPY VARCHAR2,
 p_sent_date    OUT NOCOPY date,
 p_customer_id    OUT NOCOPY number,
 p_product_id    OUT NOCOPY number,
 p_classification   OUT NOCOPY varchar2,
 p_score_percent   OUT NOCOPY number,
 p_info_id    	 OUT NOCOPY number,
 p_key1             OUT NOCOPY varchar2,
 p_val1             OUT NOCOPY varchar2,
 p_key2             OUT NOCOPY varchar2,
 p_val2             OUT NOCOPY varchar2,
 p_key3             OUT NOCOPY varchar2,
 p_val3             OUT NOCOPY varchar2,
 p_key4             OUT NOCOPY varchar2,
 p_val4             OUT NOCOPY varchar2,
 p_key5             OUT NOCOPY varchar2,
 p_val5             OUT NOCOPY varchar2,
 p_key6             OUT NOCOPY varchar2,
 p_val6             OUT NOCOPY varchar2,
 p_key7             OUT NOCOPY varchar2,
 p_val7             OUT NOCOPY varchar2,
 p_key8             OUT NOCOPY varchar2,
 p_val8             OUT NOCOPY varchar2,
 p_key9             OUT NOCOPY varchar2,
 p_val9             OUT NOCOPY varchar2,
 p_key10            OUT NOCOPY varchar2,
 p_val10            OUT NOCOPY varchar2,
 x_msg_count    OUT NOCOPY  NUMBER,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_data        OUT NOCOPY  VARCHAR2);

-- Start of Comments
-- API name      : 'ENABLE_QUEUE`
-- Purpose          : Enables a given IEM Queue
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_queue_name			IN VARCHAR2
--  p_enqueue				IN VARCHAR2
--  p_dequeue				IN VARCHAR2
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE ENABLE_QUEUE(
	P_Api_Version_Number     IN   NUMBER,
	P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
	P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
	p_queue_name             IN  	VARCHAR2,
	p_enqueue				IN  	VARCHAR2,
	p_dequeue				IN  	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_data               OUT NOCOPY  VARCHAR2);

-- Start of Comments
-- API name      : 'DISABLE_QUEUE`
-- Purpose          : Disables a given IEM Queue
-- Pre-reqs  : None
-- Parameters  :
--   IN
--  p_api_version_number IN NUMBER Required
--  p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--  p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_queue_name			IN VARCHAR2
--  p_enqueue				IN VARCHAR2
--  p_dequeue				IN VARCHAR2
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments


PROCEDURE DISABLE_QUEUE(
	P_Api_Version_Number     IN   NUMBER,
	P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
	P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
	p_queue_name             IN  	VARCHAR2,
	p_enqueue				IN  	VARCHAR2,
	p_dequeue				IN  	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_data               OUT NOCOPY  VARCHAR2);

End IEM_PREPENQDEQ_PUB;

 

/
