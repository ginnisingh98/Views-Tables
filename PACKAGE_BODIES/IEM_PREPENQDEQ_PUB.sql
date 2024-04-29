--------------------------------------------------------
--  DDL for Package Body IEM_PREPENQDEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_PREPENQDEQ_PUB" as
/* $Header: iemppedb.pls 115.19 2004/04/08 21:18:54 chtang shipped $*/

G_PKG_NAME varchar2(255) :='IEM_PREPENQDEQ_PUB';

PROCEDURE PREP_ENQUEUE(
 P_Api_Version_Number 	IN NUMBER,
 P_Init_Msg_List  		IN VARCHAR2     := FND_API.G_FALSE,
 P_Commit    			IN VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    			IN  NUMBER,
 p_msg_size   			IN  NUMBER,
 p_sender_name   		IN  VARCHAR2,
 p_user_name   		IN  VARCHAR2,
 p_domain_name   		IN  VARCHAR2,
 p_priority   			IN  VARCHAR2,
 p_msg_status   		IN  VARCHAR2,
 p_key1    			IN VARCHAR2,
 p_val1    			IN VARCHAR2,
 x_msg_count   	 OUT NOCOPY  NUMBER,
 x_return_status  	 OUT NOCOPY  VARCHAR2,
 x_msg_data   		 OUT NOCOPY VARCHAR2)

IS

BEGIN
	null;

END PREP_ENQUEUE;

PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit         		IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    		 OUT NOCOPY NUMBER,
 p_msg_size   		 OUT NOCOPY NUMBER,
 p_sender_name   	 OUT NOCOPY VARCHAR2,
 p_user_name   	 OUT NOCOPY VARCHAR2,
 p_domain_name   	 OUT NOCOPY VARCHAR2,
 p_priority   		 OUT NOCOPY VARCHAR2,
 p_msg_status   	 OUT NOCOPY VARCHAR2,
 p_key1    		 OUT NOCOPY VARCHAR2,
 p_val1    		 OUT NOCOPY VARCHAR2,
 x_msg_count   	 OUT NOCOPY NUMBER,
 x_return_status  	 OUT NOCOPY VARCHAR2,
 x_msg_data       	 OUT NOCOPY  VARCHAR2)

IS

BEGIN
	null;
END PREP_DEQUEUE;

PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit         		IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   			IN VARCHAR2,
 p_msg_id    		 OUT NOCOPY NUMBER,
 p_msg_size   		 OUT NOCOPY NUMBER,
 p_sender_name   	 OUT NOCOPY VARCHAR2,
 p_user_name   	 OUT NOCOPY VARCHAR2,
 p_domain_name   	 OUT NOCOPY VARCHAR2,
 p_priority   		 OUT NOCOPY VARCHAR2,
 p_msg_status   	 OUT NOCOPY VARCHAR2,
 p_key1    		 OUT NOCOPY VARCHAR2,
 p_val1    		 OUT NOCOPY VARCHAR2,
 x_msg_count   	 OUT NOCOPY NUMBER,
 x_return_status  	 OUT NOCOPY VARCHAR2,
 x_msg_data       	 OUT NOCOPY  VARCHAR2)

IS
BEGIN
		null;
END PREP_DEQUEUE;

PROCEDURE PREP_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit         		IN   VARCHAR2     := FND_API.G_FALSE,
 p_qopt   			IN VARCHAR2,
 p_qdeq   			IN VARCHAR2,
 p_msg_id    		 OUT NOCOPY NUMBER,
 p_msg_size   		 OUT NOCOPY NUMBER,
 p_sender_name   	 OUT NOCOPY VARCHAR2,
 p_user_name   	 OUT NOCOPY VARCHAR2,
 p_domain_name   	 OUT NOCOPY VARCHAR2,
 p_priority   		 OUT NOCOPY VARCHAR2,
 p_msg_status   	 OUT NOCOPY VARCHAR2,
 p_key1    		 OUT NOCOPY VARCHAR2,
 p_val1    		 OUT NOCOPY VARCHAR2,
 x_msg_count   	 OUT NOCOPY NUMBER,
 x_return_status  	 OUT NOCOPY VARCHAR2,
 x_msg_data       	 OUT NOCOPY  VARCHAR2)

IS

BEGIN
		null;
END PREP_DEQUEUE;

PROCEDURE PROC_ENQUEUE(
 P_Api_Version_Number 	IN NUMBER,
 P_Init_Msg_List  		IN VARCHAR2     := FND_API.G_FALSE,
 P_Commit    			IN VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    			IN  NUMBER,
 p_msg_size   			IN  NUMBER,
 p_sender_name   		IN  VARCHAR2,
 p_user_name   		IN  VARCHAR2,
 p_domain_name   		IN  VARCHAR2,
 p_priority   			IN  VARCHAR2,
 p_msg_status   		IN  VARCHAR2,
 p_subject    			IN   varchar2,
 p_sent_date              IN   date,
 p_customer_id            IN   number,
 p_product_id             IN   number,
 p_classification         IN   varchar2,
 p_score_percent          IN   number,
 p_info_id                IN   number,
 p_key1    			IN VARCHAR2,
 p_val1    			IN VARCHAR2,
 p_key2                   IN   varchar2,
 p_val2                   IN   varchar2,
 p_key3                   IN   varchar2,
 p_val3                   IN   varchar2,
 p_key4                   IN   varchar2,
 p_val4                   IN   varchar2,
 p_key5                   IN   varchar2,
 p_val5                   IN   varchar2,
 p_key6                   IN   varchar2,
 p_val6                   IN   varchar2,
 p_key7                   IN   varchar2,
 p_val7                   IN   varchar2,
 p_key8                   IN   varchar2,
 p_val8                   IN   varchar2,
 p_key9                   IN   varchar2,
 p_val9                   IN   varchar2,
 p_key10                  IN   varchar2,
 p_val10                  IN   varchar2,
 x_msg_count   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2,
 x_msg_data   OUT NOCOPY VARCHAR2)

IS

BEGIN
			null;
END PROC_ENQUEUE;

PROCEDURE PROC_DEQUEUE(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
 P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
 p_msg_id    		 OUT NOCOPY  NUMBER,
 p_msg_size   		 OUT NOCOPY  NUMBER,
 p_sender_name   	 OUT NOCOPY  VARCHAR2,
 p_user_name   	 OUT NOCOPY  VARCHAR2,
 p_domain_name   	 OUT NOCOPY  VARCHAR2,
 p_priority   		 OUT NOCOPY  VARCHAR2,
 p_msg_status   	 OUT NOCOPY  VARCHAR2,
 p_subject    		 OUT NOCOPY VARCHAR2,
 p_sent_date   	 OUT NOCOPY date,
 p_customer_id   	 OUT NOCOPY number,
 p_product_id   	 OUT NOCOPY number,
 p_classification  	 OUT NOCOPY varchar2,
 p_score_percent  	 OUT NOCOPY number,
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
 x_msg_count   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2,
 x_msg_data       OUT NOCOPY  VARCHAR2)
IS
BEGIN
			null;
END PROC_DEQUEUE;

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
 p_msg_status   OUT NOCOPY  VARCHAR2,
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
 x_return_status  OUT NOCOPY  VARCHAR2,
 x_msg_data       OUT NOCOPY  VARCHAR2)
IS
BEGIN
				null;
END PROC_DEQUEUE;

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
 p_msg_status   OUT NOCOPY  VARCHAR2,
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
 x_return_status  OUT NOCOPY  VARCHAR2,
 x_msg_data       OUT NOCOPY  VARCHAR2)
IS

BEGIN
		null;
END PROC_DEQUEUE;

PROCEDURE ENABLE_QUEUE(
 P_Api_Version_Number 	IN NUMBER,
 P_Init_Msg_List  		IN VARCHAR2     := FND_API.G_FALSE,
 P_Commit    			IN VARCHAR2     := FND_API.G_FALSE,
 p_queue_name   		IN  VARCHAR2,
 p_enqueue	   		IN  VARCHAR2,
 p_dequeue   			IN  VARCHAR2,
 x_msg_count   	 OUT NOCOPY  NUMBER,
 x_return_status  	 OUT NOCOPY  VARCHAR2,
 x_msg_data   		 OUT NOCOPY VARCHAR2)

IS

BEGIN
		null;

END ENABLE_QUEUE;

PROCEDURE DISABLE_QUEUE(
 P_Api_Version_Number 	IN NUMBER,
 P_Init_Msg_List  		IN VARCHAR2     := FND_API.G_FALSE,
 P_Commit    			IN VARCHAR2     := FND_API.G_FALSE,
 p_queue_name   		IN  VARCHAR2,
 p_enqueue	   		IN  VARCHAR2,
 p_dequeue   			IN  VARCHAR2,
 x_msg_count   	 OUT NOCOPY  NUMBER,
 x_return_status  	 OUT NOCOPY  VARCHAR2,
 x_msg_data   		 OUT NOCOPY VARCHAR2)

IS

BEGIN
	null;
END DISABLE_QUEUE;

End IEM_PREPENQDEQ_PUB;

/
