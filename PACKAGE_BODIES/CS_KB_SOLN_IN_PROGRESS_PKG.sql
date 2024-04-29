--------------------------------------------------------
--  DDL for Package Body CS_KB_SOLN_IN_PROGRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SOLN_IN_PROGRESS_PKG" AS
/* $Header: cskbsipb.pls 115.2 2003/11/14 00:53:09 mkettle noship $ */

--ERRBUF = err messages

--RETCODE = 0 success, 1 = warning, 2=error


PROCEDURE CHECK_SOLN_IN_PROGRESS (
  ERRBUF  OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2 )
IS

 CURSOR GET_IN_PROGRESS_SOLUTIONS IS
  SELECT Soln.Set_id, Soln.Set_Number, Soln.Locked_By, Soln.FLow_Details_Id, Soln.Name,
         FlowDetail.Group_id
  FROM CS_KB_SETS_VL Soln,
       CS_KB_WF_FLOW_DETAILS FlowDetail
  WHERE Soln.STATUS IN ('SAV','NOT','REJ')
  AND   Soln.LATEST_VERSION_FLAG = 'Y'
  AND Soln.Flow_Details_id = FlowDetail.Flow_Details_Id (+)
  AND   Soln.Locked_BY > -1;

 l_complete_soln VARCHAR2(10);
 l_user  NUMBER := FND_GLOBAL.User_Id;
 l_login NUMBER := FND_GLOBAL.Login_Id;

BEGIN

  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting Concurrent Program to unlock Solutions at: '||sysdate);

/*
  FND_FILE.PUT_LINE(FND_FILE.LOG,
'Solutions will be unlocked if the locking User nolonger has access
to the complete Solution. Access to the complete solution invloves
the User having the necessary Visibility to the Solution and all its
associated statements. The Solution must also reside in a Category
that has been associated to the users Category Group. ');
  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
*/

  FOR Solutions IN GET_IN_PROGRESS_SOLUTIONS LOOP

    IF ( CS_KB_SECURITY_PVT.IS_COMPLETE_SOLUTION_VISIBLE( Solutions.Locked_By,
                                                          Solutions.Set_id) = 'FALSE') THEN
      -- If current Locking User Does Not have Complete access to the Solution,
      -- then UnLock the Solution

      UPDATE CS_KB_SETS_B
      SET Locked_By = -1,
          Lock_Date = NULL,
          Last_Update_Date = sysdate,
          Last_Updated_By = l_user,
          Last_Update_Login = l_login
      WHERE Set_Id = Solutions.Set_id;

      IF Solutions.FLow_Details_Id IS NOT NULL THEN
        -- For Solutions that are currently in a Flow we will create
        -- a new WF process to re-notify the Resource Group that the
        -- Solution is back in the queue and needs reassigning

        BEGIN
         CS_KB_WF_PKG.Create_Wf_Process( p_set_id          => Solutions.Set_id,
                                         p_set_number      => Solutions.Set_Number,
                                         p_command         => 'NOT',
                                         p_flow_details_id => Solutions.FLow_Details_Id,
                                         p_group_id        => Solutions.Group_Id,
                                         p_solution_title  => Solutions.Name );
        EXCEPTION WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.GET_STRING('CS','CS_KB_NOT_RESEND_ERR')||
                                          Solutions.Set_Number||' -'||substrb(sqlerrm,1,200));
        END;

      END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, Solutions.Set_Number||fnd_message.GET_STRING('CS','CS_KB_SOLN_UNLOCK'));

    END IF;

  END LOOP;

  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Finished Concurrent Program to unlock Solutions at: '||sysdate);

  COMMIT;

  --ERRBUF := 'Success';

  RETCODE := 0;


EXCEPTION
  WHEN OTHERS THEN

    RETCODE := 2;

    ERRBUF := fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);

END CHECK_SOLN_IN_PROGRESS;

END CS_KB_SOLN_IN_PROGRESS_PKG;

/
