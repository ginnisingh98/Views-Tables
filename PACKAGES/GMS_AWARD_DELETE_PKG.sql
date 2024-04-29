--------------------------------------------------------
--  DDL for Package GMS_AWARD_DELETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_DELETE_PKG" AUTHID CURRENT_USER as
/* $Header: gmsawdls.pls 120.1 2005/07/26 14:20:33 appldev ship $ */
/*===============================================================================
  Verify whether user can delete the award or not
  ===============================================================================*/
  FUNCTION Delete_Award_Ok
  (
  	p_Award_Id 	IN	NUMBER,
  	p_Billing_Rule 	IN	VARCHAR2, -- Stop using parameter  bug 2355648
   	p_Revenue_Rule	IN	VARCHAR2, -- Stop using  parameter bug 2355648
  	RETCODE		OUT NOCOPY	VARCHAR2,
  	ERRBUFF		OUT NOCOPY	VARCHAR2
  ) RETURN BOOLEAN;

/*===============================================================================
  Delete all award related information if award is getting deleted
  ===============================================================================*/

  PROCEDURE Delete_Award_All
  ( 	p_Award_Id	IN	NUMBER,
        p_msg_count     OUT NOCOPY     NUMBER,
  	RETCODE 	OUT NOCOPY	VARCHAR2,
  	ERRBUFF		OUT NOCOPY	VARCHAR2
  );

/*===============================================================================
  Checks whether project funding exists.
  ===============================================================================*/
  FUNCTION Check_Funding_Exists
  (
  	p_Award_Id 	IN	NUMBER,
        p_msg_count     OUT NOCOPY     NUMBER, --Added for bug 2355648
  	RETCODE		OUT NOCOPY	VARCHAR2,
  	ERRBUFF		OUT NOCOPY	VARCHAR2
  ) RETURN BOOLEAN;


 /*===============================================================================
  Checks whether draft budget exists.
  ===============================================================================*/
  FUNCTION Check_Draft_Budget_Exists
  (
  	p_Award_Id 	IN	NUMBER,
        p_msg_count     OUT NOCOPY     NUMBER ,--Added for bug 235564
  	RETCODE		OUT NOCOPY	VARCHAR2,
  	ERRBUFF		OUT NOCOPY	VARCHAR2

  ) RETURN BOOLEAN;

 /* Added below API to fix bug 2355648 */

  PROCEDURE DELETE_AWARD_DETAIL( 	p_award_id 		IN  NUMBER ,
					p_award_project_id      IN  NUMBER,
	                                p_agreement_id          IN  NUMBER,
        	                        p_Award_Template_flag   IN  VARCHAR2,
					p_msg_count  		OUT NOCOPY NUMBER,
					RETCODE	          	OUT NOCOPY VARCHAR2,
				  	ERRBUFF	     	        OUT NOCOPY VARCHAR2);

END GMS_AWARD_DELETE_PKG;

 

/
