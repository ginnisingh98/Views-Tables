--------------------------------------------------------
--  DDL for Package GMS_AWARDS_BOUNDARY_DATES_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARDS_BOUNDARY_DATES_CHK" AUTHID CURRENT_USER AS
-- $Header: gmsawvds.pls 120.1 2005/09/02 02:47:25 appldev ship $

  Procedure validate_start_date( P_AWARD_ID    	IN    NUMBER,
                        	 P_START_DATE   IN    DATE ,
				 X_MESSAGE      OUT   NOCOPY VARCHAR2);

  Procedure validate_end_date	( P_AWARD_ID   	IN    NUMBER,
                        	 P_END_DATE     IN    DATE ,
				 X_MESSAGE      OUT   NOCOPY VARCHAR2);

-- Added for Bug: 2269791 (CHANGING INSTALLMENT DATE WHEN BASELINED BUDGET EXISTS)
  Procedure validate_installment ( x_award_id IN NUMBER);

  -- The following procedure validates the change in project start date to see if any transactions
  -- exist outside the modified date.

  Procedure validate_proj_start_date( P_PROJECT_ID    	IN    NUMBER,
                        	      P_START_DATE      IN    DATE ,
				      X_MESSAGE         OUT   NOCOPY VARCHAR2,
				      P_TASK_ID         IN    PA_TASKS.TASK_ID%TYPE DEFAULT NULL);  /* Bug# 4138033 */

  Procedure validate_proj_completion_date( P_PROJECT_ID   	 IN    NUMBER,
                        	           P_COMPLETION_DATE     IN    DATE ,
				           X_MESSAGE             OUT   NOCOPY VARCHAR2,
					   P_TASK_ID             IN    PA_TASKS.TASK_ID%TYPE DEFAULT NULL);  /* Bug# 4138033 */


END;

 

/
