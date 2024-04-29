--------------------------------------------------------
--  DDL for Package IEM_PP_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_PP_QUEUE_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvques.pls 120.3 2005/08/07 17:23:39 appldev noship $ */
--
-- file name: iemvques.pls
--
-- Purpose: EMTA runtime queue management
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/20/2003    Created
--  Liang Xia   08/29/2004   changed for new feature
--  Liang Xia   10/13/2004   Added x_subject for get_queue_rec
--  Liang Xia   11/02/2004   get Action from queue
--  Liang Xia   01/20/2005   Added expunge_queue
--  Liang Xia   05/20/2005   changed signature of expunge_queue
--  Liang Xia   05/20/2005   changed signature of create_pp_queue by adding RFC822_msgID
--		  					 received_date
-- ---------   ------  ------------------------------------------
TYPE key_tbl_type IS table of VARCHAR(100) INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    : create_pp_queue
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_RT_PP_QUEUES table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE create_pp_queue (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_msg_uid             IN   NUMBER,
  				 p_email_acct_id       IN   NUMBER,
                 p_subject             IN   VARCHAR2,
                 p_from                IN   varchar2,
                 p_size                IN   NUMBER,
                 p_flag                IN   VARCHAR2,
    			 p_retry_count		IN  NUMBER,
				 p_attach_name_tbl	IN JTF_VARCHAR2_TABLE_300,
				 p_attach_size_tbl	IN JTF_VARCHAR2_TABLE_300,
    			 p_attach_type_tbl	IN JTF_VARCHAR2_TABLE_300,
                 p_rfc822_msgId        IN   VARCHAR2,
                 p_received_date       IN   DATE,
    			 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;


--  Start of Comments
--  API name    : get_queue_rec
--  Type        : Private
--  Function    : This procedure get record for EMTA Processing thread
--  Pre-reqs    : None.
--  Parameters  :
Procedure get_queue_rec(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_pp_queue_id         OUT  NOCOPY NUMBER,
                 x_msg_uid             OUT  NOCOPY NUMBER,
                 x_subject             OUT  NOCOPY VARCHAR2,
                 x_acct_id             OUT  NOCOPY NUMBER,
                 x_action              OUT  NOCOPY NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    );

--  Start of Comments
--  API name    : expunge_queue
--  Type        : Private
--  Function    : This procedure deletes emails that has been processed
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE expunge_queue (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_acct_id			   IN   VARCHAR2,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 );


--  Start of Comments
--  API name    : get_queue_recs
--  Type        : Private
--  Function    : This procedure get records for EMTA Processing thread
--  Pre-reqs    : None.
--  Parameters  :
Procedure get_queue_recs(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_batch			   IN   NUMBER,
                 x_pp_queue_ids        OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_msg_uids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_subjects            OUT  NOCOPY jtf_varchar2_Table_2000,
                 x_acct_id             OUT  NOCOPY NUMBER,
                 x_actions             OUT  NOCOPY JTF_NUMBER_TABLE,
				 x_rfc_msgids          OUT  NOCOPY jtf_varchar2_Table_300,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    );

--  Start of Comments
--  API name    : mark_flags
--  Type        : Private
--  Function    : This procedure update flag for the batch data
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE mark_flags (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_flag			   	   IN   VARCHAR2,
				 p_queue_ids		   IN   jtf_varchar2_Table_100,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : reset_data
--  Type        : Private
--  Function    : This procedure reset flag to the queue data.
--  Pre-reqs    : None.
--  Parameters  :
 PROCEDURE reset_data (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;


END IEM_PP_QUEUE_PVT ;

 

/
