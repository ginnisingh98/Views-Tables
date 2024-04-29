--------------------------------------------------------
--  DDL for Package Body XDPCORE_ORU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_ORU" AS
/* $Header: XDPCORUB.pls 120.1 2005/06/15 22:40:59 appldev  $ */


/****
 All Private Procedures for the Package
****/

FUNCTION HandleOtherWFFuncmode (funcmode IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE InitializeORUProcess(itemtype IN VARCHAR2,
                               itemkey  IN VARCHAR2);

PROCEDURE LaunchResubmissionFAs(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2);

PROCEDURE SetORUStatus(itemtype IN VARCHAR2,
                       itemkey  IN VARCHAR2);

TYPE RowidArrayType IS TABLE OF ROWID INDEX BY BINARY_INTEGER;



/***********************************************
* END of Private Procedures/Function Definitions
************************************************/

--  INITIALIZE_ORU_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE INITIALIZE_ORU_PROCESS (itemtype  IN VARCHAR2,
		 	          itemkey   IN VARCHAR2,
			          actid     IN NUMBER,
			          funcmode  IN VARCHAR2,
			          resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               InitializeORUProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORU', 'INITIALIZE_ORU_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END INITIALIZE_ORU_PROCESS;





--  LAUNCH_RESUBMISSION_FAS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE LAUNCH_RESUBMISSION_FAS (itemtype  IN VARCHAR2,
			           itemkey   IN VARCHAR2,
			           actid     IN NUMBER,
			           funcmode  IN VARCHAR2,
			           resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress  VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchResubmissionFAs(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORU', 'LAUNCH_RESUBMISSION_FAS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END LAUNCH_RESUBMISSION_FAS;


--  SET_ORU_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE SET_ORU_STATUS (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2 )
 IS
 x_Progress VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetORUStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORU', 'SET_ORU_STATUS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END SET_ORU_STATUS;

/****
 All the Private Functions
****/

FUNCTION HandleOtherWFFuncmode( funcmode IN VARCHAR2) RETURN VARCHAR2
IS

resultout    VARCHAR2(30);
x_Progress   VARCHAR2(2000);

BEGIN

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'others') THEN
                resultout := 'COMPLETE';
        END IF;


        return resultout;

END;

PROCEDURE LaunchResubmissionFAs (itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2)

IS

 l_OrderID           NUMBER;
 l_WIINstanceID      NUMBER;
 l_FAInstanceID      NUMBER;
 l_LineItemID        NUMBER;
 l_Counter           NUMBER := 0;
 l_ResubmissionJOBID NUMBER;
 l_tempKey           VARCHAR2(240);

CURSOR c_GetResubFAs (ResubJobID number) IS
   SELECT XFW.ORDER_ID,
          XFR.WORKITEM_INSTANCE_ID,
          XFR.FA_INSTANCE_ID,
          XFW.LINE_ITEM_ID
     FROM XDP_FA_RUNTIME_LIST XFR,
          XDP_FULFILL_WORKLIST XFW
    WHERE XFR.RESUBMISSION_JOB_ID = ResubJobID
      AND XFR.WORKITEM_INSTANCE_ID = XFW.WORKITEM_INSTANCE_ID;

 e_NoJobsFoundException   EXCEPTION;
 e_LaunchFAException      EXCEPTION;
 x_Progress               VARCHAR2(2000);
 ErrCode                  NUMBER;
 ErrStr                   VARCHAR2(2000);

BEGIN

 l_ResubmissionJOBID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'RESUBMISSION_JOB_ID');

 if c_GetResubFAs%ISOPEN then
    close c_GetResubFAs;
  end if;


 Open c_GetResubFAs(l_ResubmissionJOBID);

 LOOP

   FETCH C_GetResubFAs
    INTO l_OrderID,
         l_WIInstanceID,
         l_FAInstanceID,
         l_LineItemID;

   EXIT WHEN c_GetResubFAs%NOTFOUND;

    l_Counter := l_Counter + 1;

      XDP_ENG_UTIL.Execute_Resubmit_FA (p_order_id            => l_OrderID,
                                        p_line_item_id        => l_LineItemID,
                                        p_wi_instance_id      => l_WIInstanceID,
                                        p_fa_instance_id      => l_FAInstanceID,
                                        p_oru_item_type       => itemtype,
                                        p_oru_item_key        => itemkey,
                                        p_resubmission_job_id => l_ResubmissionJOBID,
                                        p_fa_master           => 'WAITFORFLOW-FA-IND',
                                        p_return_code         => ErrCode,
                                        p_error_description   => ErrStr,
                                        p_fa_caller           => 'INTERNAL');


       IF ErrCode <>0 THEN
          x_progress := 'Error when launch FA Proces for Resubmission JOB ID: ' || to_char(l_ResubmissionJobID)
                  || ' OrderID: ' || to_char(l_OrderID) || ' WIInstanceID:' || to_char(l_WIInstanceID) || ' FA:'
                  || to_char(l_FAInstanceID) || ' Error:' || SUBSTR(ErrStr, 1, 1000);
          raise e_LaunchFAException;
       END IF;

  END LOOP;

  CLOSE c_GetResubFAs;

  IF l_Counter = 0 THEN
     x_Progress := 'XDPCORE_ORU.LaunchResubmissionFAs. No Jobs found to be processed for Resubmission Job ID: ' || l_ResubmissionJOBID;
     RAISE e_NoJobsFoundException;

  ELSE
    null;

  END IF;


EXCEPTION
     WHEN e_LaunchFAException THEN

          wf_core.context('XDPCORE_ORU', 'LaunchResubmissionFAs', itemtype, itemkey, null,x_progress);
          raise;

     when e_NoJobsFoundException THEN

          IF c_GetResubFAs%ISOPEN THEN
             close c_GetResubFAs;
          END IF;

          wf_core.context('XDPCORE_ORU', 'LaunchResubmissionFAs', itemtype, itemkey, null,null);
          raise;

     WHEN others THEN

          IF c_GetResubFAs%ISOPEN THEN
             close c_GetResubFAs;
          END IF;

          x_Progress := 'XDPCORE_ORU.LaunchResubmissionFAs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_ORU', 'LaunchResubmissionFAs', itemtype, itemkey, null,null);
           raise;
END LaunchResubmissionFAs;




PROCEDURE InitializeORUProcess (itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2)

IS
 l_ResubmissionJOBID  NUMBER;
 x_Progress           VARCHAR2(2000);

BEGIN

 l_ResubmissionJobID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'RESUBMISSION_JOB_ID');

 UPDATE XDP_FA_RESUBMISSION_LOG
    SET status_code         = 'IN PROGRESS',
        last_update_date    = sysdate,
        last_updated_by     = fnd_global.user_id,
        last_update_login   = fnd_global.login_id
  WHERE resubmission_job_id = l_ResubmissionJobID;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_ORU.InitializeORUProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_ORU', 'InitializeORUProcess', itemtype, itemkey, null,null);
           raise;
END InitializeORUProcess;


PROCEDURE SetORUStatus (itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2)

IS
 l_ResubmissionJobID NUMBER;
 x_Progress          VARCHAR2(2000);

begin

 l_ResubmissionJobID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'RESUBMISSION_JOB_ID');

    UPDATE XDP_FA_RESUBMISSION_LOG
       SET status_code        = 'SUCCESS',
           completion_date    = sysdate,
           last_update_date   = sysdate,
           last_updated_by    = fnd_global.user_id,
           last_update_login  = fnd_global.login_id
    WHERE resubmission_job_id = l_ResubmissionJobID;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_ORU.SetORUStatus. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_ORU', 'SetORUStatus', itemtype, itemkey, null,null);
           raise;
END SetORUStatus;

END XDPCORE_ORU;

/
