--------------------------------------------------------
--  DDL for Package AMS_CONTCAMPAIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CONTCAMPAIGN_PVT" AUTHID CURRENT_USER as
/* $Header: amsvtces.pls 120.1 2005/08/29 11:28:59 soagrawa noship $*/


-- Start of Comments
--
-- NAME
--   AMS_Campaign_PVT
--
-- PURPOSE
--   This package performs Continuous Campaigning
--	 in Oracle Marketing
--
--   Procedures:
--
--
--     Perform_checks (see below for specification)
--     Record_result   (see below for specification)
--     Schedule_Next_Trigger_Run  (see below for specification)
--     Validate_Sql  (see below for specification)
--
-- NOTES
--
--
-- HISTORY
--   07/12/1999        ptendulk            created
-- End of Comments

/******************************************************************************/
-- global constants
-- Define Exception to check whether the Discoverer query returns only one Column
/******************************************************************************/
valid_no_columns EXCEPTION ;

pragma EXCEPTION_INIT(valid_no_columns, -1007);

/******************************************************************************/
--PL\SQL table to hold the strings that compose a valid SQL statement from
--a discoverer workbook
/******************************************************************************/

TYPE t_SQLtable is TABLE OF varchar2(2000)
INDEX BY BINARY_INTEGER;


/******************************************************************************/

-- Start of Comments
--
-- NAME
----   Record_result
--
-- PURPOSE
--   This Procedure is to record the results of the check and also that
--   of action
--
-- NOTES
--
--
-- HISTORY
--   07/21/1999        ptendulk     Created
--   26-aug-2005       soagrawa     Added action for id to store who the NTF was sent to
--
-- End of Comments
PROCEDURE Record_Result(p_result_for_id	      IN	  NUMBER,
		  				p_process_id          IN	  NUMBER   :=	  NULL,
						p_chk1_value	      IN	  NUMBER   :=	  NULL,
						p_chk2_value	      IN	  NUMBER   :=	  NULL,
                        p_chk2_high_value     IN      NUMBER   :=     NULL,
						p_operator		      IN	  VARCHAR2 :=	  NULL,
						p_process_success     IN	  VARCHAR2 :=     NULL,
						p_check_met		      IN	  VARCHAR2 :=     NULL,
                        p_action_taken        IN      VARCHAR2 :=     NULL,
  		        p_action_for_id	      IN	  NUMBER   :=	  NULL,
                        x_result_id           OUT NOCOPY     NUMBER,
						x_return_status	      OUT NOCOPY   VARCHAR2);

-- Start of Comments
--
-- NAME
--   Schedule_Next_Trigger_Run
--
-- PURPOSE
--   This Procedure will mark the Last run time fot the trigger and
--   will calculate the next schedule run time. Will Update the AMS_TRIGGERS
--	 table with the new values for Last run time, next schedule run time
--
-- NOTES
--
--
-- HISTORY
--   07/23/1999        ptendulk            created
-- End of Comments

PROCEDURE Schedule_Next_Trigger_Run
		  				(p_api_version       IN   NUMBER,
                         p_init_msg_list     IN   VARCHAR2   := FND_API.G_FALSE,
						 p_commit		   	 IN   VARCHAR2   := FND_API.G_FALSE,
		  				 p_trigger_id 	     IN   NUMBER,
		  				 x_msg_count         OUT NOCOPY  NUMBER,
						 x_msg_data          OUT NOCOPY  VARCHAR2,
						 x_return_status	 OUT NOCOPY  VARCHAR2,
		  			 	 x_sch_date		     OUT NOCOPY  DATE) ;


-- Start of Comments
--
-- NAME
----   Validate_Sql
--
-- PURPOSE
--   This Function is to validate the discoverer SQL query.
--   The discoverer SQL defined for continuous Campaign must return
--   only one column and it must have only one row. Also the output should be
--   numeric value
--
-- CALLED BY
--   Perform_Checks
--
-- NOTES
--
--
-- HISTORY
--   07/12/1999        ptendulk            created
-- End of Comments

PROCEDURE Validate_Sql(      p_api_version 		  	   IN  	 NUMBER,
	    				     p_init_msg_list           IN    VARCHAR2  := FND_API.G_FALSE,

		  					 x_return_status           OUT NOCOPY   VARCHAR2,
  							 x_msg_count               OUT NOCOPY   NUMBER  ,
							 x_msg_data                OUT NOCOPY   VARCHAR2,

		  					 p_workbook_name       	   IN    VARCHAR2,
		  			   	 	 p_worksheet_name	       IN	 VARCHAR2,
					   	 	 p_workbook_owner_name 	   IN    VARCHAR2,

							 x_result				   OUT NOCOPY   NUMBER) ;

-- Start of Comments
--
-- NAME
----   Perform_Checks
--
-- PURPOSE
--   This Function is to execute various checks defined on the trigger.
--   Function performs the checks, stores the result in Result table and
--	 returns the flag Y/N to indicate whether the check was met or not
--
-- NOTES
--
--
-- HISTORY
--   07/12/1999        ptendulk            created
-- End of Comments

PROCEDURE Perform_Checks(p_api_version     IN   NUMBER ,
                         p_init_msg_list   IN   VARCHAR2   := FND_API.G_FALSE,

		  				 x_msg_count       OUT NOCOPY  NUMBER,
						 x_msg_data        OUT NOCOPY  VARCHAR2,
                         x_return_status   OUT NOCOPY VARCHAR2,

		  				 p_trigger_id 	   IN   NUMBER,
						 x_chk_success	   OUT NOCOPY  VARCHAR2,
                         x_check_val       OUT NOCOPY  NUMBER ,
                         x_check_high_val  OUT NOCOPY  NUMBER ,
                         x_result_id       OUT NOCOPY  NUMBER
		  			 	 );

END AMS_ContCampaign_PVT;

 

/
