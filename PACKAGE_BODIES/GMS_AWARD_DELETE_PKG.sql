--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_DELETE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_DELETE_PKG" as
/* $Header: gmsawdlb.pls 115.14 2003/08/01 09:34:00 lveerubh ship $ */

-- Awards delete
----------------------------------------------------------------------------------------
--Check event exist for any Project
----------------------------------------------------------------------------------------

  FUNCTION check_event_exist(p_award_id     IN  NUMBER ,
                             p_Err_Code     OUT NOCOPY VARCHAR2,
                             p_Err_Stage    OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

        CURSOR event_exist IS
        	SELECT 1 --COUNT(*) bug 2355648
  	        FROM  gms_event_attribute  gea, gms_installments gi
         	WHERE award_id = p_award_id
         	AND   gea.installment_id= gi.installment_id
                AND   rownum <=1;
       l_event_exist number:=0;
  BEGIN
       OPEN event_exist;
       FETCH event_exist INTO l_event_exist;
       CLOSE event_exist;
       p_Err_Code  := 'S';
       IF   l_event_exist >0  THEN
            RETURN TRUE;
       ELSE
            RETURN FALSE;
       END IF;
  EXCEPTION
       WHEN OTHERS THEN
       BEGIN
         p_Err_Code  := 'U';
         p_Err_Stage  := 'CHECK_EVENT_EXIST';
         FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: CHECK_EVENT_EXIST');
         FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
         FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
         RETURN TRUE;
        -- RAISE FND_API.G_EXC_ERROR;
       END;
  END check_event_exist;


----------------------------------------------------------------------------------------
--Following procedure check whether award has funded to any project
----------------------------------------------------------------------------------------


  FUNCTION  check_funding_exists
       ( p_award_id     IN      NUMBER,
         p_msg_count    OUT NOCOPY     NUMBER,
	 retcode 	OUT NOCOPY  	VARCHAR2,
         errbuff        OUT NOCOPY 	VARCHAR2
       ) RETURN BOOLEAN AS

      CURSOR  funding_exist IS
      SELECT 1 --COUNT(*) bug 2355648
      FROM   gms_summary_project_fundings gspf,gms_installments gi
      WHERE  gi.award_id = p_award_Id
      AND    gspf.installment_id=gi.installment_id
      AND   rownum <=1;
      l_funding_exist  NUMBER:=0;
  BEGIN
      OPEN funding_exist;
      FETCH funding_exist INTO l_funding_exist;
      retcode :='S';
      CLOSE funding_exist;
      IF   l_funding_exist >0  THEN
           RETURN TRUE;
      ELSE
           RETURN FALSE;
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
      BEGIN
         retcode :='U';
   	 errbuff := 'Error :'||substr(sqlerrm,1,200);
         FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: CHECK_FUNDING_EXISTS');
         FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
         FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
         FND_MSG_PUB.add;
         FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => errbuff);
         RETURN FALSE;
       END;
 END check_funding_exists;

---------------------------------------------------------------------------------------
--Check Baselined budget exist for any Project
---------------------------------------------------------------------------------------

FUNCTION check_baselined_budget_exist (p_award_id              IN  NUMBER,
                                       p_Err_Code              OUT NOCOPY VARCHAR2,
        	                       p_Err_Stage             OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

 CURSOR budget_exist IS
    SELECT 	1 --COUNT(*) bug 2355648
    FROM 	gms_budget_versions
    WHERE      	award_id = p_award_id
    AND      	budget_status_code IN ('B','S')
    AND         rownum <=1;

    l_budget_exist NUMBER:=0;

BEGIN
    OPEN budget_exist;
    FETCH budget_exist INTO l_budget_exist;
    CLOSE budget_exist;
    p_Err_Code :='S';
    IF   l_budget_exist >0  THEN
        RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
EXCEPTION
         WHEN OTHERS THEN
         BEGIN
             p_Err_Code :='U';
             p_err_stage :=' CHECK_BASELINED_BUDGET_EXIST';
             FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
    	     FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: CHECK_BASELINED_BUDGET_EXIST');
             FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
             FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
             RETURN TRUE;
       --      RAISE FND_API.G_EXC_ERROR;
        END;
END check_baselined_budget_exist;
---------------------------------------------------------------------------------------
--Check ADL exist for the award
---------------------------------------------------------------------------------------

FUNCTION check_adl_exist (p_award_id              IN  NUMBER,
 		          p_Err_Code              OUT NOCOPY VARCHAR2,
                          p_Err_Stage             OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

 CURSOR adl_exist IS
    SELECT 	1 --COUNT(*)  bug 2355648
    FROM 	gms_award_distributions
    WHERE       award_id = p_award_id
    AND         rownum <=1;

   l_adl_exist NUMBER:=0;

BEGIN
    OPEN adl_exist;
    FETCH adl_exist INTO l_adl_exist;
    CLOSE adl_exist;
        p_Err_Code :='S';
    IF  l_adl_exist >0  THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
         WHEN OTHERS THEN
         BEGIN
             p_Err_Code :='U';
             p_Err_Stage  :='CHECK_ADL_EXIST';
             FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
    	     FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: CHECK_ADL_EXIST');
             FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
             FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
	     RETURN TRUE;
        END;
END check_adl_exist;
--==========================================================
--Added below API to  fix bug 2355648
--==========================================================
PROCEDURE DELETE_AWARD_DETAIL( 	p_award_id 		IN  NUMBER ,
                                p_award_project_id      IN  NUMBER,
                                p_agreement_id          IN  NUMBER,
                                p_Award_Template_flag   IN  VARCHAR2,
                                p_msg_count             OUT NOCOPY NUMBER,
				retcode 	        OUT NOCOPY VARCHAR2,
       				errbuff                 OUT NOCOPY VARCHAR2 )  IS

CURSOR  GET_PROJECT_ID   IS
        	SELECT   DISTINCT PROJECT_ID
        	FROM     gms_summary_project_fundings gspf,gms_installments gi
        	WHERE   gi.award_id = p_award_id  --:gms_awards_v.Award_Id bug 2355648
        	AND     gspf.installment_id=gi.installment_id;


CURSOR  PROJECT_FUNDING IS
              SELECT    GI.INSTALLMENT_ID,
              		FUNDING_AMOUNT,
              		PROJECT_FUNDING_ID,
			GMS_PROJECT_FUNDING_ID,
              		PROJECT_ID ,
              		TASK_ID
 		FROM    GMS_PROJECT_FUNDINGS GPF ,GMS_INSTALLMENTS GI
       		WHERE   GPF.INSTALLMENT_ID=GI.INSTALLMENT_ID
     		AND     GI.AWARD_ID= p_award_id ;  --:GMS_AWARDS_V.AWARD_ID; 2355648
l_err_code		number;
l_app_name 		varchar2(10);
l_err_stage 		varchar2(240) :='';
l_err_stack 		varchar2(240) :='';
l_Funding_Exists        boolean;
l_draft_budget_exists   boolean;
Begin
   FND_MSG_PUB.Initialize;
    IF p_Award_Template_flag ='DEFERRED' THEN
       l_Funding_Exists:= GMS_AWARD_DELETE_PKG.CHECK_FUNDING_EXISTS
    			(p_Award_Id	=>p_Award_id,
                         p_msg_count    =>p_msg_count,
    			 RETCODE	=>retcode,
    			 ERRBUFF	=>errbuff);
       IF retcode <> 'S' THEN
              RAISE  FND_API.G_EXC_ERROR; --bug 2355648
       END IF;

       IF  l_funding_Exists THEN

            l_Draft_Budget_Exists:=GMS_AWARD_DELETE_PKG.CHECK_DRAFT_BUDGET_EXISTS
						(p_Award_Id	=>p_Award_id,
                                                 p_msg_count    =>p_msg_count,
						 RETCODE	=>retcode,
						 ERRBUFF	=>errbuff);

	    IF retcode <> 'S' THEN
                RAISE  FND_API.G_EXC_ERROR; --bug 2355648
            END IF;
	    IF l_Draft_Budget_Exists THEN
               FOR PROJECT_INFO IN GET_PROJECT_ID
      	       LOOP
      		   gms_budget_pub.delete_draft_budget(
      				p_api_version_number => 1.0,
      				p_pm_product_code => 'GMS',
      				x_err_code =>  l_err_code,
      				x_err_stage => l_err_stage,
      				x_err_stack => l_err_stack,
      				p_project_id => project_info.project_id,
      				p_award_id => p_Award_id,
      				p_budget_type_code =>'AC');

            	  IF (l_err_code <> 0) then
               	   exit;
            	  END IF;
               END LOOP;
	         IF (l_err_code <> 0) then
                      FND_MESSAGE.SET_NAME('GMS','GMS_DELETE_DRAFT_FAIL');
                      FND_MSG_PUB.add;
                      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => errbuff);
		      RAISE  FND_API.G_EXC_ERROR;  --bug 2355648
     	         END IF;
	    END IF; --End if for l_Draft_Budget_Exists

   	    FOR FUNDING_INFO IN PROJECT_FUNDING
   	    LOOP
      		GMS_PROJECT_FUNDINGS_PKG.DELETE_ROW
 			(X_GMS_PROJECT_FUNDING_ID =>FUNDING_INFO.GMS_PROJECT_FUNDING_ID);
         	GMS_SUMM_FUNDING_PKG.DELETE_GMS_SUMMARY_FUNDING
    			( X_Installment_Id 	=> FUNDING_INFO.INSTALLMENT_ID,
	    		  X_Project_Id 		=> FUNDING_INFO.PROJECT_ID,
    		  	  X_Task_Id 		=> FUNDING_INFO.TASK_ID,
    		  	  X_Funding_Amount 	=> FUNDING_INFO.FUNDING_AMOUNT,
    		  	  RETCODE          	=> retcode,
    		  	  ERRBUF           	=> errbuff);


		IF retcode <> 'S' then
                      FND_MESSAGE.SET_NAME('GMS','GMS_DELETE_FUNDING_FAIL');
                      FND_MSG_PUB.add;
                      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => errbuff);
		      RAISE  FND_API.G_EXC_ERROR;  --bug 2355648
		END IF;

	        GMS_MULTI_FUNDING.DELETE_AWARD_FUNDING
    			(X_INSTALLMENT_ID 	=> FUNDING_INFO.INSTALLMENT_ID,
    		  	X_ALLOCATED_AMOUNT 	=> FUNDING_INFO.FUNDING_AMOUNT,
    		  	X_PROJECT_FUNDING_ID	=> FUNDING_INFO.PROJECT_FUNDING_ID,
    		  	X_APP_SHORT_NAME 	=> l_app_name,
    		  	ERRBUF  		=> errbuff,
    		  	X_msg_count 		=> p_msg_count,
    		  	RETCODE 		=> retcode   );

    		 	IF retcode <> 'S' then
    		      	   RAISE FND_API.G_EXC_ERROR;
		  	END IF;
	    END LOOP;
        END IF ; --End if for l_funding_Exists

        GMS_MULTI_FUNDING.DELETE_AWARD_PROJECT(
	 X_Award_id         => p_award_id ,
	 X_AWARD_PROJECT_ID => p_award_project_id ,
	 X_AGREEMENT_ID     => p_agreement_id ,
	 X_MSG_COUNT        => p_msg_count      ,
	 X_APP_SHORT_NAME   => l_app_name,
	 RETCODE            => retcode,
	 ERRBUF             => errbuff );


        IF retcode<> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF; -- End if for :gms_awards_v.Award_Template_flag
                       DELETE_AWARD_ALL(p_Award_Id	=>p_Award_id,
                                          p_msg_count   =>p_msg_count,
				          RETCODE       =>retcode,
				       	  ERRBUFF       =>errbuff);
    IF retcode <> 'S' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    retcode :='S';
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
   	BEGIN
   	 	 retcode :='E';
   		 errbuff := 'Error :'||substr(sqlerrm,1,200);
                 ROLLBACK;
        END;
        WHEN  OTHERS THEN
        BEGIN
              --'S' for success, 'E' form exception for , and 'U' for Undefine Exception
             retcode :='U';
    	     errbuff := 'Error :'||substr(sqlerrm,1,200);
             FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: DELETE_AWARD_DETAIL');
             FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
             FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
             FND_MSG_PUB.add;
             FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => errbuff);
             ROLLBACK;
        END;
END DELETE_AWARD_DETAIL;
------------------------------------------------------------------------------------------
--Following Function checks whether award deletion is possible. (MAIN FUNCTION)
------------------------------------------------------------------------------------------

 FUNCTION delete_award_ok
 (
 	p_Award_Id 	IN	NUMBER,
  	p_Billing_Rule 	IN	VARCHAR2, --Not Using this parameter  bug 2355648
   	p_Revenue_Rule	IN	VARCHAR2, --Not Using this parameter bug 2355648
  	RETCODE		OUT NOCOPY	VARCHAR2,
  	ERRBUFF		OUT NOCOPY	VARCHAR2
 ) RETURN BOOLEAN AS

   l_errbuff      VARCHAR2(200);
   l_retcode      VARCHAR2(200);
   l_fund_exists  BOOLEAN;
   l_event_exist  BOOLEAN;
   l_adl_exist    BOOLEAN;
   l_baselined_exist BOOLEAN;
 BEGIN
   l_event_exist := check_event_exist(p_award_Id, l_retcode, l_errbuff);

    IF l_retcode <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_adl_exist := check_adl_exist(p_award_id, l_retcode, l_errbuff);

    IF l_retcode <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_baselined_exist := check_baselined_budget_exist(p_award_Id,l_retcode, l_errbuff);

    IF l_retcode <> 'S' THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (  l_event_exist  OR
          l_adl_exist    OR
          l_baselined_exist  ) 		THEN

        retcode :='S';
        RETURN TRUE;
    ELSE
	retcode :='S';
        RETURN FALSE;

    END IF;

  --added below logic to fix bug 2366417
  /*   IF  check_baselined_budget_exist(x_award_Id) OR
         check_event_exist(x_award_id) THEN
         retcode :='S';
         RETURN TRUE;
     ELSE
         retcode :='S';
         RETURN FALSE;
     END IF; */

  --Commented out NOCOPY below logic to fix bug 2366417
   /* l_fund_exists  := check_funding_exists(x_award_id,l_retcode,l_errbuff);
    IF l_retcode = 'S' THEN
           IF  check_funding_exists(x_award_Id,l_retcode,l_errbuff)  THEN
		IF x_billing_rule= 'EVENT' AND x_revenue_rule= 'EVENT' THEN
              		IF check_baselined_budget_exist(x_award_Id) -- Bug 2301943
                           OR check_event_exist(x_award_id) THEN
              			retcode :='S';
                     		RETURN TRUE;
	      		ELSE
	      			retcode :='S';
            	     		RETURN FALSE;
	      		END IF;
      	   	ELSIF x_billing_rule= 'COST' AND x_revenue_rule= 'COST' THEN
			IF check_baselined_budget_exist(x_award_Id) THEN
				retcode :='S';
	     	     		RETURN TRUE;
			ELSE
				retcode :='S';
	             		RETURN FALSE;
	        	END IF;
           	ELSIF x_billing_rule= 'EVENT' AND x_revenue_rule= 'COST' THEN
                	IF  check_baselined_budget_exist(x_award_Id) OR  check_event_exist(x_award_Id) THEN
                		retcode :='S';
		     		RETURN TRUE;
                	ELSE
                		retcode :='S';
                     		RETURN FALSE;
                	END IF;
   	   	END IF;
   	  ELSE
   	  	retcode :='S';
   	  	RETURN FALSE;
   	  END IF;
   ELSE
   	  RAISE FND_API.G_EXC_ERROR ;
   END IF; */
  EXCEPTION
   	WHEN FND_API.G_EXC_ERROR THEN
   	BEGIN
   	 	 retcode :='E';
   		 errbuff := 'Error :'||substr(sqlerrm,1,200);
                 RETURN FALSE;
        END;
        WHEN  OTHERS THEN
        BEGIN
              --'S' for success, 'E' form exception for , and 'U' for Undefine Exception
             retcode :='U';
    	     errbuff := 'Error :'||substr(sqlerrm,1,200);
             FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: DELETE_AWARD_OK');
             FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
             FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
             RETURN FALSE;
        END;
  END delete_award_ok;

--------------------------------------------------------------------------------------------
--Check Draft/Submitted budget exist
--------------------------------------------------------------------------------------------
Function check_draft_budget_exists(p_award_id      IN  NUMBER,
 				   p_msg_count     OUT NOCOPY NUMBER,
				   retcode 	   OUT NOCOPY VARCHAR2,
				   errbuff 	   OUT NOCOPY VARCHAR2
				  ) RETURN BOOLEAN  IS

    CURSOR draft_budget_exist IS
    SELECT 	1  --COUNT(*) bug 2355648
    FROM 	gms_budget_versions
    WHERE       award_id = p_award_id
    AND      	budget_status_code = 'W';

   l_budget_exist  NUMBER :=0;

BEGIN

    OPEN draft_budget_exist;
    FETCH draft_budget_exist INTO l_budget_exist;
    CLOSE draft_budget_exist;
    IF   l_budget_exist >0  THEN
         retcode :='S';
         RETURN TRUE;
    ELSE
         retcode :='S';
         RETURN FALSE;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    BEGIN
          retcode := 'U';
          errbuff := 'Error :'||substr(sqlerrm,1,200);
    	  FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: CHECK_DRAFT_BUDGET_EXISTS');
	  FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
	  FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
          FND_MSG_PUB.add;
          FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => Errbuff);

	  RETURN TRUE;
	--  RAISE FND_API.G_EXC_ERROR;
    END;
END check_draft_budget_exists;
-------------------------------------------------------------------------------------------------------
--Delete the Award Details
-------------------------------------------------------------------------------------------------------
PROCEDURE delete_award_all( p_award_Id  IN   NUMBER ,
                            p_msg_count OUT NOCOPY  NUMBER,
                            retcode     OUT NOCOPY  VARCHAR2 ,
                            errbuff     OUT NOCOPY  VARCHAR2
                          )   AS
        CURSOR notification_lock  IS
            SELECT  1 FROM gms_notifications
            WHERE   award_id=p_award_Id
            FOR UPDATE NOWAIT;

        CURSOR lock_installments  IS
            SELECT  1 FROM gms_installments
            WHERE    award_id=p_award_Id
            FOR UPDATE NOWAIT;
         --Lock gms_notifiction table
BEGIN
       OPEN notification_lock;
        CLOSE notification_lock;
        OPEN lock_installments;
        CLOSE lock_installments;
--For bug 2312564 : changed the order of execution of delete to avoid dnagling records in gms_Reports
        DELETE FROM gms_reports WHERE  installment_id in (select installment_id from gms_installments WHERE   award_id =p_award_id);
        DELETE FROM gms_installments WHERE  award_id=p_award_id;
        DELETE FROM gms_default_reports WHERE  award_id = p_award_id;
        DELETE FROM gms_notifications WHERE  award_id= p_award_id;
        DELETE FROM gms_awards_terms_conditions WHERE  award_id=p_award_id;
       -- DELETE FROM gms_reports WHERE  installment_id in (select installment_id
        --        from gms_installments WHERE   award_id =p_award_id);
        DELETE FROM gms_personnel WHERE  award_id =p_award_id;
        DELETE FROM gms_reference_numbers WHERE  award_id=p_award_id;
        DELETE FROM gms_awards_contacts WHERE  award_id=p_award_id;
        DELETE FROM pa_credit_receivers WHERE  project_id= p_award_Id;
        -- Added the following delete statement for bug 2097676 :Multiple Indirect Cost schedules
        DELETE FROM gms_override_schedules WHERE award_id=p_award_id;
        retcode :='S';
EXCEPTION
        WHEN OTHERS THEN
        BEGIN
                   ROLLBACK;
                --'S' for success, 'E' form exception for , and 'U' for Undefine Exception
                   retcode :='U';
                   errbuff := 'Error :'||substr(sqlerrm,1,200);
                   FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_AWARD_DELETE_PKG: DELETE_AWARD_ALL');
                   FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                   FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                   p_data => errbuff);
        END;
END DELETE_AWARD_ALL;
END GMS_AWARD_DELETE_PKG;

/
