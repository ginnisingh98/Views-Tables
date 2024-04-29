--------------------------------------------------------
--  DDL for Package Body GMS_SUMM_FUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_SUMM_FUNDING_PKG" AS
--$Header: gmsmfsfb.pls 120.1.12010000.2 2008/10/30 12:44:09 rrambati ship $

FUNCTION ROW_EXISTS_IN_GMS_SUMM_FUNDING(X_Installment_Id IN NUMBER,
                                        X_Project_Id     IN NUMBER,
                                        X_Task_Id        IN NUMBER DEFAULT NULL,
                                        X_Err_Code       OUT NOCOPY VARCHAR2,
                                        X_Err_Stage      OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
Row_Check INTEGER;
Begin
fnd_msg_pub.initialize;
  Select
  1
  into
  Row_Check
  from
  GMS_SUMMARY_PROJECT_FUNDINGS
  where
  INSTALLMENT_ID = X_Installment_Id and
  PROJECT_ID     = X_Project_Id     and
  (TASK_ID        = X_Task_Id
             OR
   TASK_ID IS NULL) ;  --DECODE(X_Task_Id,NULL,NULL,X_Task_Id);
                             X_Err_Code := 'S';
                             RETURN TRUE;
             EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                             X_Err_Code := 'S';
                             RETURN FALSE;
                   WHEN TOO_MANY_ROWS THEN
                        X_Err_Code := 'E';
                 X_Err_Stage := 'There is more than one row for the Installment '||to_char(X_Installment_Id)||' and the Project '||to_char(X_Project_Id);
                 FND_MESSAGE.SET_NAME('GMS','GMS_MULT_ROW_FOR_INST');
                 FND_MESSAGE.SET_TOKEN('INSTALLMENT_ID',to_char(X_Installment_Id) );
                 FND_MESSAGE.SET_TOKEN('PROJECT_ID',to_char(X_Project_Id) );
                 FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : ROW_EXISTS_IN_GMS_SUMM_FUNDING');
                 FND_MSG_PUB.add;
                 FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                           p_data  => X_Err_Stage);
                             RETURN FALSE;
                   WHEN OTHERS THEN
                              X_Err_Code := 'U';
                              X_Err_Stage := (SQLCODE||' '||SQLERRM);
                 FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : ROW_EXISTS_IN_GMS_SUMM_FUNDING');
                 FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                 FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                 FND_MSG_PUB.add;
                 FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                           p_data  => X_Err_Stage);

                                  RETURN FALSE;
END ROW_EXISTS_IN_GMS_SUMM_FUNDING;

PROCEDURE  GET_GMS_SUMM_FUNDING(X_Installment_Id        IN NUMBER,
                                X_Project_Id            IN NUMBER,
                                X_Task_Id               IN NUMBER DEFAULT NULL,
                                X_Total_Funding_Amount  OUT NOCOPY NUMBER,
                                X_Total_Billed_Amount   OUT NOCOPY NUMBER,
                                X_Total_Revenue_Amount  OUT NOCOPY NUMBER,
                                X_Err_Code              OUT NOCOPY VARCHAR2,
                                X_Err_Stage             OUT NOCOPY VARCHAR2) IS
Begin
fnd_msg_pub.initialize;

/*Bug 3643335: Added trunc for total_billed_amount and total_revenue_amount) */
 select
 total_funding_amount,
 trunc(nvl(total_billed_amount,0)),
 trunc(nvl(total_revenue_amount,0))
 into
 X_Total_Funding_Amount,
 X_Total_Billed_Amount,
 X_Total_Revenue_Amount
 from
 gms_summary_project_fundings gmf
 where
 gmf.installment_id     = X_Installment_Id and
 gmf.project_id         = X_Project_Id     and
 (gmf.task_id           =  X_Task_Id
             OR
  gmf.task_id is NULL);          -- decode(X_Task_Id,NULL,NULL,X_Task_Id);
             X_Err_Code := 'S';
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
    X_Err_Code := 'E';
    X_Err_Stage := 'No row found for Project and Task specified in GMS_SUMMARY_PROJECT_FUNDINGS';
      X_Total_Funding_Amount := -99;
      X_Total_Billed_Amount  := -99;
      X_Total_Revenue_Amount := -99;
      FND_MESSAGE.SET_NAME('GMS','GMS_NO_ACT_PRJ_TSK_IN_SF');
      FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : GET_GMS_SUMM_FUNDING');
      FND_MSG_PUB.add;
      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                p_data  => X_Err_Stage );
    WHEN OTHERS THEN
    X_Err_Code := 'U';
    X_Err_Stage := SQLCODE||' '||SQLERRM;
      FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : GET_GMS_SUMM_FUNDING');
      FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
      FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
      FND_MSG_PUB.add;
      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                p_data  => X_Err_Stage);

END GET_GMS_SUMM_FUNDING;

PROCEDURE UPDATE_GMS_SUMM_PROJ_FUNDING(X_Installment_Id      IN NUMBER,
                                          X_Project_Id       IN NUMBER,
                                          X_Task_Id          IN NUMBER DEFAULT NULL,
                                          X_Funding_Amount   IN NUMBER,
                                          X_Err_Code         OUT NOCOPY VARCHAR2,
                                          X_Err_Stage        OUT NOCOPY VARCHAR2) IS
St_Total_Funding NUMBER(22,5);
Begin
fnd_msg_pub.initialize;

   update GMS_SUMMARY_PROJECT_FUNDINGS
      set   TOTAL_FUNDING_AMOUNT = X_Funding_Amount,
            LAST_UPDATE_DATE = SYSDATE ,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      where
            INSTALLMENT_ID   = X_Installment_Id and
            PROJECT_ID       = X_Project_Id     and
            (TASK_ID          = X_Task_Id
                          OR
             TASK_ID IS NULL );      --DECODE(X_Task_Id,NULL,NULL,X_Task_Id);

               X_Err_Code := 'S';
             If SQL%NOTFOUND THEN
             X_Err_Code := 'E';
             X_Err_Stage := 'No Row to update for Installment '||to_char(X_Installment_Id)||' and Project '||to_char(X_Project_Id);
       FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PRJ_TSK_SF');
       FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : UPDATE_GMS_SUMM_PROJ_FUNDING');
       FND_MESSAGE.SET_TOKEN('INSTALLMENT_ID',to_char(X_Installment_Id) );
       FND_MESSAGE.SET_TOKEN('PROJECT_ID', to_char(X_Project_Id) );
       FND_MSG_PUB.add;
       FND_MSG_PUB.Count_And_Get(p_count  =>  p_msg_count,
                                 p_data   =>  X_Err_Stage );
             End If;

END UPDATE_GMS_SUMM_PROJ_FUNDING;

Procedure INSERT_GMS_SUMM_PROJ_FUNDING(X_Installment_Id IN NUMBER,
                                       X_Project_Id     IN NUMBER,
                                       X_Task_Id        IN NUMBER DEFAULT NULL,
                                       X_Funding_Amount IN NUMBER,
                                       X_Err_Code       OUT NOCOPY VARCHAR2,
                                       X_Err_Stage      OUT NOCOPY VARCHAR2) IS
Begin
fnd_msg_pub.initialize;

   INSERT INTO GMS_SUMMARY_PROJECT_FUNDINGS
   (INSTALLMENT_ID ,
    PROJECT_ID,
    TASK_ID ,
    TOTAL_FUNDING_AMOUNT ,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
   VALUES
   (X_Installment_Id,
    X_Project_Id,
    X_Task_Id,
    X_Funding_Amount,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    FND_GLOBAL.LOGIN_ID);
                    X_Err_Code := 'S';
   EXCEPTION

       WHEN OTHERS THEN
           X_Err_Code := 'U';
                 FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : INSERT_GMS_SUMM_PROJ_FUNDING');
                 FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                 FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                 FND_MSG_PUB.add;
                 FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                           p_data  => X_Err_Stage);

End INSERT_GMS_SUMM_PROJ_FUNDING;

Procedure CREATE_GMS_SUMMARY_FUNDING(X_Installment_Id IN NUMBER,
                                       X_Project_Id     IN NUMBER,
                                       X_Task_Id        IN NUMBER DEFAULT NULL,
                                       X_Funding_Amount IN NUMBER,
                                       RETCODE          OUT NOCOPY VARCHAR2,
                                       ERRBUF           OUT NOCOPY VARCHAR2) IS
X_Err_Code VARCHAR2(1);
X_Err_Stage VARCHAR2(200);
X_Total_Funding_Amount NUMBER(22,5);
X_Total_Billed_Amount  NUMBER(22,5);
X_Total_Revenue_Amount NUMBER(22,5);

Begin
 If ROW_EXISTS_IN_GMS_SUMM_FUNDING(X_Installment_Id,
                                        X_Project_Id,
                                        X_Task_Id,
                                        X_Err_Code,
                                        X_Err_Stage) THEN

        GET_GMS_SUMM_FUNDING(X_Installment_Id,
                             X_Project_Id,
                             X_Task_Id,
                             X_Total_Funding_Amount,
                             X_Total_Billed_Amount,
                             X_Total_Revenue_Amount,
                             X_Err_Code,
                             X_Err_Stage);
               If X_Err_Code <> 'S' then
                 RAISE FND_API.G_EXC_ERROR;
               End If;

          X_Total_Funding_Amount := X_Total_Funding_Amount + X_Funding_Amount;
               UPDATE_GMS_SUMM_PROJ_FUNDING(X_Installment_Id,
                                            X_Project_Id,
                                            X_Task_Id,
                                            X_Total_Funding_Amount,
                                            X_Err_Code,
                                            X_Err_Stage);
                   If X_Err_Code <> 'S' then
                     RAISE FND_API.G_EXC_ERROR;
                   End If;
 Else
     If X_Err_Code = 'S' then
         INSERT_GMS_SUMM_PROJ_FUNDING(X_Installment_Id,
                                       X_Project_Id,
                                       X_Task_Id,
                                       X_Funding_Amount,
                                       X_Err_Code,
                                       X_Err_Stage);

                    If X_Err_Code <> 'S' then
                     RAISE FND_API.G_EXC_ERROR;
                   End If;
     Else
           RAISE FND_API.G_EXC_ERROR;
     End If;
 End If;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   RETCODE := X_Err_Code;
   ERRBUF  := X_Err_Stage;

END CREATE_GMS_SUMMARY_FUNDING;

Procedure DELETE_GMS_SUMMARY_FUNDING(X_Installment_Id   IN NUMBER,
                                     X_Project_Id       IN NUMBER,
                                     X_Task_Id          IN NUMBER DEFAULT NULL,
                                     X_Funding_Amount   IN NUMBER,
                                     RETCODE            OUT NOCOPY VARCHAR2,
                                     ERRBUF             OUT NOCOPY VARCHAR2) IS
-- Cursor is added as fix for bug 1583819
cursor Hard_Limit_Flag_cr is
   	 select  hard_limit_flag,invoice_limit_flag  /*Bug 6642901*/
	 from    gms_awards  awd,
 	 	 gms_installments_v ins
 	 where   awd.award_id=ins.award_id
	 and     ins.installment_id = X_Installment_Id;
X_Hard_Limit_Flag VARCHAR2(1);  --Added to fix bug 1583819
X_Invoice_Limit_Flag VARCHAR2(1); /*Bug 6642901*/
X_Err_Code VARCHAR2(1);
X_Err_Stage VARCHAR2(200);
X_Total_Funding_Amount NUMBER(22,5);
X_Total_Billed_Amount  NUMBER(22,5);
X_Total_Revenue_Amount NUMBER(22,5);
--X_funding_exists VARCHAR2(1) := 'Y';

-- Bug 2270436 : Added function gms_funding_exists
-- This function checks for existence of any record in gms_project_fundings before
-- deleting records from gms_summary_project_fundings

FUNCTION gms_funding_exists (p_installment_id NUMBER, p_project_id NUMBER, p_task_id NUMBER)
   RETURN BOOLEAN
IS
   CURSOR c_funding_exists
   IS SELECT 1 FROM DUAL
      WHERE EXISTS (SELECT 1
        	    FROM gms_project_fundings
       		    WHERE installment_id = p_installment_id
         	    AND project_id = p_project_id
         	    AND nvl(task_id,0) = nvl(p_task_id,0));


   x_dummy                       NUMBER := 0;
BEGIN
   OPEN c_funding_exists;
   FETCH c_funding_exists INTO x_dummy;
   CLOSE c_funding_exists;

   IF x_dummy <> 0
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END;

Begin

fnd_msg_pub.initialize;
	  -- Assume project funding row has been deleted.

          GET_GMS_SUMM_FUNDING(X_Installment_Id,
                             X_Project_Id,
                             X_Task_Id,
                             X_Total_Funding_Amount,
                             X_Total_Billed_Amount,
                             X_Total_Revenue_Amount,
                             X_Err_Code,
                             X_Err_Stage);
               If X_Err_Code <> 'S' then
                 RAISE FND_API.G_EXC_ERROR;
               End If;

-- Debashis. This does not seem to be correct. Where is task id ? Use the function gms_funding_exists instead. Bug 2270436
/*
		Begin
		select 'Y' into x_funding_exists
		from dual
		where exists ( select 1 from gms_project_fundings
			       where  installment_id = x_installment_id
			       and project_id  = x_project_id);
		exception
		when no_data_found then
		x_funding_exists := 'N';
		End;
*/
--Debashis

 -- Cursor is added as fix for bug 1583819
       open  Hard_Limit_Flag_cr;
       fetch Hard_Limit_Flag_cr
       into  X_Hard_Limit_Flag,X_Invoice_Limit_Flag;   /*Bug 6445688*/
       close Hard_Limit_Flag_cr;
-- Cursor is added as fix for bug 1583819

/* Bug 6445688. Modified code to split the hard limit logic separately for revenue limit and invoice limit.
   Also replaced the single message with 2 separate revenue/invoice specific error messages. */
      If (X_Hard_Limit_Flag ='Y') and
          ( /*((X_Total_Funding_Amount - X_Funding_Amount) < X_Total_Billed_Amount)
                                          OR commented for bug 6642901*/
           ((X_Total_Funding_Amount - X_Funding_Amount) < X_Total_Revenue_Amount)
         ) then
                     X_Err_Code := 'E';
/*                     X_Err_Stage := 'Total Funding Amount cannot go less than Total Billed Amount or Total Revenue Amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_REV_BILL');  commented for bug 6642901*/
                             X_Err_Stage := 'You cannot delete the funding line, as this will cause total funds to be less than the total revenue amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_REV');
        FND_MSG_PUB.add;
        FND_MSG_PUB.Count_And_Get(p_count   =>   p_msg_count,
                                  p_data    =>   X_Err_Stage );

                           RAISE FND_API.G_EXC_ERROR;
      Elsif (X_Invoice_Limit_Flag ='Y') and ((X_Total_Funding_Amount - X_Funding_Amount) < X_Total_Billed_Amount) then
                     X_Err_Code := 'E';
                     X_Err_Stage := 'You cannot delete the funding line, as this will cause total funds to be less than the total billed amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_BILL');
        FND_MSG_PUB.add;
        FND_MSG_PUB.Count_And_Get(p_count   =>   p_msg_count,
                                  p_data    =>   X_Err_Stage );

                           RAISE FND_API.G_EXC_ERROR;
      End If;


	  If (((X_Total_Funding_Amount - X_Funding_Amount) = 0)
		 and not gms_funding_exists(X_installment_id,x_project_id,x_task_id))	-- Bug 2270436
	   then
	  	DELETE FROM GMS_SUMMARY_PROJECT_FUNDINGS
		WHERE
	        INSTALLMENT_ID   = X_Installment_Id and
            	PROJECT_ID       = X_Project_Id     and
            	(TASK_ID          = X_Task_Id
                      OR
                 TASK_ID IS NULL ); -- DECODE(X_Task_Id,NULL,NULL,X_Task_Id);
                X_Err_Code := 'S';

                If SQL%ROWCOUNT = 0 THEN
                   X_Err_Code := 'E';
                   X_Err_Stage := 'No Row to delete for Installment '||to_char(X_Installment_Id)||' and Project '||to_char(X_Project_Id);

       FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PRJ_TSK_SF');
       FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_SUMM_FUNDING_PKG : DELETE_GMS_SUMM_PROJ_FUNDING');
       FND_MESSAGE.SET_TOKEN('INSTALLMENT_ID',to_char(X_Installment_Id) );
       FND_MESSAGE.SET_TOKEN('PROJECT_ID', to_char(X_Project_Id) );
       FND_MSG_PUB.add;
       FND_MSG_PUB.Count_And_Get(p_count  =>  p_msg_count,
                                 p_data   =>  X_Err_Stage );
                End If;
	  Else
		X_Total_Funding_Amount := (X_Total_Funding_Amount - X_Funding_Amount);
                UPDATE_GMS_SUMM_PROJ_FUNDING(X_Installment_Id,
                                             X_Project_Id,
                                             X_Task_Id,
                                             X_Total_Funding_Amount,
                                             X_Err_Code,
                                             X_Err_Stage);
                If X_Err_Code <> 'S' then
                  RAISE FND_API.G_EXC_ERROR;
                End If;
	  end if;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   RETCODE := X_Err_Code;
   ERRBUF  := X_Err_Stage;

End DELETE_GMS_SUMMARY_FUNDING;


Procedure UPDATE_GMS_SUMMARY_FUNDING(X_Installment_Id   IN NUMBER,
                                     X_Project_Id       IN NUMBER,
                                     X_Task_Id          IN NUMBER DEFAULT NULL,
				     X_old_amount	IN NUMBER,
				     X_new_amount	IN NUMBER,
                                     RETCODE            OUT NOCOPY VARCHAR2,
                                     ERRBUF             OUT NOCOPY VARCHAR2) IS
X_Err_Code VARCHAR2(1);
X_Err_Stage VARCHAR2(200);
X_Total_Funding_Amount NUMBER(22,5);
X_Total_Billed_Amount  NUMBER(22,5);
X_Total_Revenue_Amount NUMBER(22,5);

-- For Bug fix 3150477
CURSOR 	 hard_limit_flag_cr IS
         SELECT   	hard_limit_flag,invoice_limit_flag  /*Bug 6642901*/
         FROM    	gms_awards  awd,
                 	gms_installments_v ins
         WHERE   	awd.award_id=ins.award_id
         AND      	ins.installment_id = X_Installment_Id;

X_Hard_Limit_Flag VARCHAR2(1);
X_Invoice_Limit_Flag VARCHAR2(1);  /*Bug 6642901*/
--End of bug fix 3150477

Begin
          GET_GMS_SUMM_FUNDING(X_Installment_Id,
                               X_Project_Id,
                               X_Task_Id,
                               X_Total_Funding_Amount,
                               X_Total_Billed_Amount,
                               X_Total_Revenue_Amount,
                               X_Err_Code,
                               X_Err_Stage);
               If X_Err_Code <> 'S' then
                 RAISE FND_API.G_EXC_ERROR;
               End If;

-- For bug 3150477
       OPEN hard_limit_flag_cr;
       FETCH hard_limit_flag_cr INTO  X_Hard_Limit_Flag,X_Invoice_Limit_Flag; /*Bug 6642901*/
       CLOSE hard_limit_flag_cr;
-- End of Bug fix  3150477

	  X_Total_Funding_Amount := X_Total_Funding_Amount + ( X_new_amount  -  X_old_amount);
/* Bug 6445688. Modified code to split the hard limit logic separately for revenue limit and invoice limit.
   Also replaced the single message with 2 separate revenue/invoice specific error messages. */

      --Added hard limit flag check for bug 3150477
       If (X_Hard_Limit_Flag ='Y') AND
	( /*(X_Total_Funding_Amount < X_Total_Billed_Amount) OR  Commented for Bug 6642901*/
            (X_Total_Funding_Amount < X_Total_Revenue_Amount)
          ) then
                  X_Err_Code   := 'E';
/*                  X_Err_Stage  := 'Total Funding cannot go less than the Total Revenue Amount or Total Billed Amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_REV_BILL'); Commented for bug 6445688*/
                  X_Err_Stage  := 'You cannot delete the funding line, as this will cause total funds to be less than the total revenue amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_REV');
        FND_MSG_PUB.add;
        FND_MSG_PUB.Count_And_Get(p_count   =>   p_msg_count,
                                  p_data    =>   X_Err_Stage );
                        RAISE FND_API.G_EXC_ERROR;
       Elsif (X_Invoice_Limit_Flag ='Y') AND (X_Total_Funding_Amount < X_Total_Billed_Amount) then
                  X_Err_Code   := 'E';
                  X_Err_Stage  := 'You cannot delete the funding line, as this will cause total funds to be less than the total billed amount';
        FND_MESSAGE.SET_NAME('GMS','GMS_FUND_LESS_BILL');
        FND_MSG_PUB.add;
        FND_MSG_PUB.Count_And_Get(p_count   =>   p_msg_count,
                                  p_data    =>   X_Err_Stage );
                        RAISE FND_API.G_EXC_ERROR;
       Else
          UPDATE_GMS_SUMM_PROJ_FUNDING(X_Installment_Id,
                                       X_Project_Id,
                                       X_Task_Id,
                                       X_Total_Funding_Amount,
                                       X_Err_Code,
                                       X_Err_Stage);
               If X_Err_Code <> 'S' then
                 RAISE FND_API.G_EXC_ERROR;
               End If;
       End If;



EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   RETCODE := X_Err_Code;
   ERRBUF  := X_Err_Stage;

End UPDATE_GMS_SUMMARY_FUNDING;

End GMS_SUMM_FUNDING_PKG;

/
