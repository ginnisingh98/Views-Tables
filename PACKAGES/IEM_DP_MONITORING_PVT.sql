--------------------------------------------------------
--  DDL for Package IEM_DP_MONITORING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DP_MONITORING_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvmons.pls 120.5 2005/11/16 17:31:41 liangxia noship $ */
--
--
-- Purpose: Mantain Download  Processor monitoring data
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2005   Created
--  Liang Xia   08/15/2005   GET_DP_RUNNING_STATUS
--  Liang Xia   11/07/2005   Fixed bug 4628955
-- ---------   ------  ------------------------------------------

--  Start of Comments
--  API name    : CREATE_DP_ACCT_STATUS
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_DP_ACCT_STATUStable
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE CREATE_DP_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : RECORD_ACCT_STATUS
--  Type        : Private
--  Function    : This procedure updates record in the table IEM_DP_ACCT_STATUS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE RECORD_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
				 p_error_flag		   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;

--  Start of Comments
--  API name    : UPDATE_DP_ACCT_STATUS
--  Type        : Private
--  Function    : This procedure updates record in the table IEM_DP_ACCT_STATUStable
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE UPDATE_DP_ACCT_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number,
                 p_inbox_count         IN   number,
                 p_processed_count     IN   number,
				 p_retry_count     	   IN   number,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : CREATE_PROCESS_STATUS
--  Type        : Private
--  Function    : This procedure updates record in the table IEM_DP_PROCESS_STATUStable
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE CREATE_PROCESS_STATUS (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 P_process_id		   IN   VARCHAR2,
				 x_status_id	       OUT	NOCOPY NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : cleanup_monitoring_data
--  Type        : Private
--  Function    : This procedure delete record in the table IEM_DP_PROCESS_STATUS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE cleanup_monitoring_data
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  p_preproc_sleep			IN  NUMBER,
			  p_postproc_sleep      	IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);


--  Start of Comments
--  API name    : GET_DP_RUNNING_STATUS
--  Type        : Private
--  Function    : This procedure get the running status of DP by calling FND_CONCURRENT API
--  Pre-reqs    : None.
--  Parameters  :

PROCEDURE GET_DP_RUNNING_STATUS
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  p_mode                  	IN  VARCHAR2 := null,
			  x_DP_STATUS			    OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : GET_ACCOUNT_DP_STATUS
--  Type        : Private
--  Function    : This procedure is called by DP monitor GUI to populate DPAccountsVO
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE GET_ACCOUNT_DP_STATUS
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
			  P_view_all_accounts		IN  VARCHAR2,
			  x_account_ids				OUT NOCOPY jtf_number_Table,
			  x_email_address			OUT NOCOPY jtf_varchar2_Table_200,
			  x_account_status			OUT NOCOPY jtf_varchar2_Table_100,
			  x_processor_status		OUT NOCOPY jtf_varchar2_Table_100,
			  x_last_run_time			OUT NOCOPY jtf_date_Table,
			  x_inbox_msg_count			OUT NOCOPY jtf_number_Table,
			  x_process_msg_count		OUT NOCOPY jtf_number_Table,
			  x_retry_msg_count			OUT NOCOPY jtf_number_Table,
			  x_log						OUT NOCOPY jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

FUNCTION get_parameter ( p_type in  varchar2,
		 			   	 p_param in  varchar2 )
			return number;

END IEM_DP_MONITORING_PVT;

 

/
