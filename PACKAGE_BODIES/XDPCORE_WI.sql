--------------------------------------------------------
--  DDL for Package Body XDPCORE_WI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_WI" AS
/* $Header: XDPCORWB.pls 120.3 2005/07/10 23:47:32 appldev noship $ */


/****
 All Private Procedures for the Package
****/

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

Function AreAllWIsDone (itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Function evaluateWIParams(itemtype in varchar2,
                                  itemkey in varchar2) return varchar2;

Function evaluateAllWIsParams(itemtype in varchar2,
                                  itemkey in varchar2) return varchar2;

Function ContinueWorkitem (itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Function LaunchAllIndependentWIs (itemtype in varchar2,
                                  itemkey in varchar2) return varchar2;

Procedure InitDepWIProcess (itemtype in varchar2,
                    itemkey in varchar2);
Procedure LaunchWorkitemProcess(itemtype in varchar2,
                                itemkey in varchar2);

Procedure LaunchIndWorkitemProcess (itemtype in varchar2,
                                 itemkey in varchar2,
                                 p_OrderID in NUMBER,
                                 p_LineItemID in NUMBER,
                                 p_WorkitemID in NUMBER,
                                 p_WIInstanceID in NUMBER,
                                 p_Priority in NUMBER);

Procedure LaunchWIServiceProcess(itemtype in varchar2,
                                itemkey in varchar2);

Procedure LaunchWISeqProcess(itemtype in varchar2,
                             itemkey in varchar2);

Procedure OverrideParamValue( p_WIInstanceID IN NUMBER,
                              p_parameterName IN VARCHAR2,
                              p_newParamValue IN VARCHAR2,
                              p_evaluate IN VARCHAR2);

Procedure CheckIfWorkItemIsaWorkflow(workitem_ID in number,
                                     wf_flag OUT NOCOPY varchar2,
                                     user_item_type OUT NOCOPY varchar2,
                                     user_item_key_prefix OUT NOCOPY varchar2,
                                     user_wf_process_name OUT NOCOPY varchar2,
                                     user_wf_proc OUT NOCOPY varchar2,
                                     fa_exec_map_proc OUT NOCOPY varchar2);

Procedure InitializeWorkitemProcess(itemtype in varchar2,
                                    itemkey in varchar2);


Function IsWIAborted(WIInstanceID in number) return boolean;

type RowidArrayType is table of rowid index by binary_integer;

Procedure GetWIParamOnStart(itemtype in varchar2,
                            itemkey  in varchar2);

Function ResolveIndDepWIs(itemtype in varchar2,
                            itemkey  in varchar2) return varchar2;

PROCEDURE UPDATE_WORKITEM_STATUS(p_workitem_instance_id IN NUMBER,
                                 p_status_code          IN VARCHAR2,
                                 p_itemtype             IN VARCHAR2,
                                 p_itemkey              IN VARCHAR2) ;

FUNCTION GetWIProvisioningDate(p_workitem_instance_id IN NUMBER) RETURN DATE;

/***********************************************
* END of Private Procedures/Function Definitions
************************************************/



--  INITIALIZE_WORKITEM_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure INITIALIZE_WORKITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                InitializeWorkitemProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'INITIALIZE_WORKITEM_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_WORKITEM_PROCESS;


--  CONTINUE_WORKITEM
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure CONTINUE_WORKITEM (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
 l_Result varchar2(1);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_Result := ContinueWorkitem(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'CONTINUE_WORKITEM', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END CONTINUE_WORKITEM;



--  ARE_ALL_WIS_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure ARE_ALL_WIS_DONE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

l_result varchar2(10);

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := AreAllWIsDone(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'ARE_ALL_WIS_DONE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ARE_ALL_WIS_DONE;


Procedure EVALUATE_WI_PARAMS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2) IS

 l_result varchar2(10);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	 IF (funcmode = 'RUN') THEN
           l_result := evaluateWIParams(itemtype, itemkey);
           resultout := 'COMPLETE:' || l_result;
           return;
         ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
         END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'EVALUATE_WI_PARAMS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END EVALUATE_WI_PARAMS;

Procedure EVALUATE_ALL_WIS_PARAMS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2) IS

 l_result varchar2(10);
 x_Progress                     VARCHAR2(2000);
 l_evalFailed exception;

BEGIN
-- RUN mode - normal process execution
--
	 IF (funcmode = 'RUN') THEN
           l_result := evaluateAllWIsParams(itemtype, itemkey);
           IF ( l_result = 'FAILURE' ) THEN
             -- on failure do a raise and find out the business error..
             RAISE l_evalFailed;
           END IF;
           resultout := 'COMPLETE:' || l_result;
           return;
         ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
         END IF;


EXCEPTION
WHEN OTHERS THEN
 IF XDPCORE.is_business_error = 'Y' THEN
   XDPCORE.context('XDPCORE_WI', 'EVALUATE_ALL_WIS_PARAMS', itemtype, itemkey );

   --Log the error at the top level call
   XDPCORE_ERROR.LOG_SESSION_ERROR( 'BUSINESS' );
   --Set the workitem instance id of which evaluation failed..
   --we cant set this in the lower calls where the error is occurred
   --as we are doing a roll back on error...
   wf_engine.SetItemAttrNumber(itemtype => EVALUATE_ALL_WIS_PARAMS.itemtype,
                               itemkey  => EVALUATE_ALL_WIS_PARAMS.itemkey,
                               aname    => 'WORKITEM_INSTANCE_ID',
                               avalue   => g_WIInstance_ID_in_Error);


    resultout := 'COMPLETE:FAILURE';
    return;
 END IF;
 wf_core.context('XDPCORE_WI', 'EVALUATE_ALL_WIS_PARAMS', itemtype, itemkey, to_char(actid), funcmode);
 RAISE;
END EVALUATE_ALL_WIS_PARAMS;



Procedure LAUNCH_WORKITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

             	LaunchWorkitemProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'LAUNCH_WORKITEM_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_WORKITEM_PROCESS;



Procedure INITIALIZE_DEP_WI_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

            InitDepWIProcess (itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'INITIALIZE_DEP_WI_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_DEP_WI_PROCESS;




Procedure LAUNCH_WI_SEQ_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

             	LaunchWISeqProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'LAUNCH_WI_SEQ_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_WI_SEQ_PROCESS;



Procedure LAUNCH_ALL_IND_WIS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_result varchar2(1) := 'N';

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

                  l_result := LaunchAllIndependentWIs(itemtype, itemkey);
		  resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 xdpcore.context('XDPCORE_WI', 'LAUNCH_ALL_IND_WIS', itemtype, itemkey, to_char(actid), funcmode);
 wf_core.context('XDPCORE_WI', 'LAUNCH_ALL_IND_WIS', itemtype, itemkey, to_char(actid), funcmode);
 raise;

END LAUNCH_ALL_IND_WIS;

Procedure LAUNCH_WI_SERVICE_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

             	LaunchWIServiceProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'LAUNCH_WI_SERVICE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_WI_SERVICE_PROCESS;




--  INITIALIZE_WI_LIST
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure INITIALIZE_WI_LIST (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
--      <your procedure here>
                resultout := 'COMPLETE:<result>';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'INITIALIZE_WI_LIST', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_WI_LIST;



--  ARE_ALL_WIS_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure GET_ONSTART_WI_PARAMS (itemtype        in varchar2,
			         itemkey         in varchar2,
			         actid           in number,
			         funcmode        in varchar2,
			         resultout       OUT NOCOPY varchar2 ) IS

l_result varchar2(10);

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                GetWIParamOnStart(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'ARE_ALL_WIS_DONE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END GET_ONSTART_WI_PARAMS;



Procedure RESOLVE_IND_DEP_WIS (itemtype        in varchar2,
			         itemkey         in varchar2,
			         actid           in number,
			         funcmode        in varchar2,
			         resultout       OUT NOCOPY varchar2 ) IS

l_result varchar2(15);

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_Result := ResolveIndDepWIs(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'RESOLVE_IND_DEP_WIS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESOLVE_IND_DEP_WIS;

Procedure OVERRIDE_WI_PARAM (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS
l_nid NUMBER;
l_WIInstanceID NUMBER;
l_newParamValue VARCHAR2(100);
l_paramName VARCHAR2(100);
l_evaluate VARCHAR2(10);

BEGIN

  IF (funcmode = 'RESPOND') THEN
    l_nid := WF_ENGINE.context_nid;
    l_newParamValue := wf_notification.GetAttrText( l_nid, 'NEW_PARAM_VALUE');

    -- User havent entered any overriding parameter value..
    IF l_newParamValue IS NOT NULL THEN
      l_WIInstanceID := wf_engine.getItemAttrNumber( itemtype, itemkey, 'WORKITEM_INSTANCE_ID' );
      l_paramName := wf_engine.getItemAttrText( itemtype, itemkey, 'WI_PARAMETER_NAME' );
      l_evaluate := wf_notification.GetAttrText( l_nid, 'EVALUATE');

      OverrideParamValue( l_WIInstanceID, l_paramName, l_newParamValue, l_evaluate);
    END IF;

  END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_WI', 'OVERRIDE_WI_PARAM', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END OVERRIDE_WI_PARAM;

/****
 All the Private Functions
****/

Function HandleOtherWFFuncmode( funcmode in varchar2) return varchar2
is
resultout varchar2(30);
 x_Progress                     VARCHAR2(2000);

begin

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

end;

Function evaluateWIParams(itemtype in varchar2,
                                  itemkey in varchar2) return varchar2
 is

 x_Progress      VARCHAR2(2000);
 l_WIInstanceID  NUMBER;
 l_workitemID NUMBER;
 l_WorkItemName VARCHAR2(50);
 l_return_flag varchar2(1) := 'Y';

 l_ErrCode number;
 l_ErrStr varchar2(1996);

begin

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => evaluateWIParams.itemtype,
                                               itemkey  => evaluateWIParams.itemkey,
                                               aname    => 'WORKITEM_INSTANCE_ID');
  BEGIN
    xdp_engine.EvaluateWIParamsOnStart(l_WIInstanceID );
  EXCEPTION
      WHEN OTHERS THEN
        -- Evaluation procedure for this WI failed..
        SELECT workitem_id INTO l_workitemID FROM xdp_fulfill_worklist WHERE workitem_instance_id = l_WIInstanceID;
        SELECT workitem_name INTO l_WorkItemName from xdp_workitems WHERE workitem_id = l_workitemID;

        XDPCORE.CheckNAddItemAttrText ( itemtype => evaluateWIParams.itemtype,
                                        itemkey  => evaluateWIParams.itemkey,
                                        AttrName    => 'WORKITEM_NAME',
                                        AttrValue   => l_WorkItemName,
                                        ErrCode  => l_ErrCode,
                                        ErrStr   => l_ErrStr);
       l_return_flag := 'N';

  END;
  RETURN l_return_flag;

exception
     when others then
          x_Progress := 'XDPCORE_WI.GetWIParamOnStart. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_WI', 'GetWIParamOnStart', itemtype, itemkey, null, x_Progress);
          raise;
END evaluateWIParams;



Function evaluateAllWIsParams(itemtype in varchar2,
                                  itemkey in varchar2) return varchar2
is
 l_LineItemID  number;
 l_OrderID number;
 l_WIInstanceID number;
 l_WorkitemID number;
 l_WIsFound number := 0;
 l_return_flag varchar2(10) := 'SUCCESS';
 l_tempKey varchar2(240);
 l_WorkItemName varchar2(40);


 cursor c_GetWIList (OrderID number, LineItemID number) is
   select WORKITEM_INSTANCE_ID
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    ORDER BY WI_SEQUENCE;


 e_NoWorkitemsFoundException exception;
 x_Progress                     VARCHAR2(2000);

 l_ErrCode number;
 l_ErrStr varchar2(1996);

 cursor c_getVals ( cv_wiid number ) is
 select parameter_name, parameter_value
  From xdp_worklist_details
  where workitem_instance_id =  cv_wiid;

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => evaluateAllWIsParams.itemtype,
                                          itemkey => evaluateAllWIsParams.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => evaluateAllWIsParams.itemtype,
                                             itemkey => evaluateAllWIsParams.itemkey,
                                             aname => 'LINE_ITEM_ID');

  /* Evaluate parameters for all INDEPENDENT workitems */
  FOR lv_WI_rec in c_GetWIList( l_OrderID, l_LineItemID ) LOOP
    l_WIsFound := 1;
    BEGIN
      l_WIInstanceID := lv_WI_rec.WORKITEM_INSTANCE_ID;
      xdp_engine.EvaluateWIParamsOnStart(l_WIInstanceID );

    EXCEPTION
      when others then
       l_return_flag := 'FAILURE';
       EXIT;
    END;
  END LOOP;

  IF l_return_flag = 'FAILURE' THEN
   --set the error workitem so that we can access at higer level..
   g_WIInstance_ID_in_Error := l_WIInstanceID;
   --Failed to execute set the context and return..
   XDPCORE.context('XDPCORE_WI', 'evaluateAllWIsParams', 'WI', l_WIInstanceID );
   RETURN l_return_flag;
  END IF;

   IF l_WIsFound = 0 THEN
      x_Progress := 'XDPCORE_WI.evaluateAllWIsParams. Found No workitems to be processed for Order: ' || l_OrderID || ' LineItemID: ' || l_LineItemID;
      RAISE e_NoWorkitemsFoundException;
   END IF;
   -- Evaluation for all WI paramers are successfull...
   RETURN l_return_flag;

EXCEPTION

WHEN e_NoWorkitemsFoundException THEN
 XDPCORE.context('XDPCORE_WI', 'evaluateAllWIsParams', 'LINE', l_LineItemID, x_Progress );
 wf_core.context('XDPCORE_WI', 'evaluateAllWIsParams', itemtype, itemkey, null, x_Progress);
 RAISE;

WHEN others THEN
  x_Progress := 'XDPCORE_WI.evaluateAllWIsParams. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
  XDPCORE.context('XDPCORE_WI', 'evaluateAllWIsParams', 'LINE', l_LineItemID );
  wf_core.context('XDPCORE_WI', 'evaluateAllWIsParams', itemtype, itemkey, null, x_Progress);
  raise;
END evaluateAllWIsParams;



Function AreAllWIsDone (itemtype in varchar2,
                        itemkey in varchar2) return varchar2
is
l_PrevSequence number;
l_OrderID number;
l_LineItemID number;
l_WorkitemID number;
l_FulfillmentSeq number;

l_Priority number;
l_WIInstanceID number;

 e_NoWorkitemsFoundException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => AreAllWIsDone.itemtype,
                                          itemkey => AreAllWIsDone.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => AreAllWIsDone.itemtype,
                                             itemkey => AreAllWIsDone.itemkey,
                                             aname => 'LINE_ITEM_ID');

 l_PrevSequence := wf_engine.GetItemAttrNumber(itemtype => AreAllWIsDone.itemtype,
                                               itemkey => AreAllWIsDone.itemkey,
                                               aname => 'CURRENT_WI_SEQUENCE');

 if c_WIList%ISOPEN then
    Close c_WIList;
 end if;


 open c_WIList(l_OrderID, l_LineItemID, l_PrevSequence);

 Fetch c_WIList into l_WIInstanceID, l_WorkitemID, l_Priority, l_PrevSequence;

 if c_WIList%NOTFOUND  then
     /* No more WI's to be done */
      close c_WIList;
      return ('Y');
 else
   /* There are more Workitem's to be done */

       close c_WIList;
      return ('N');
 end if;


 if c_WIList%ISOPEN then
    Close c_WIList;
 end if;

exception
when e_NoWorkitemsFoundException then
 if c_WIList%ISOPEN then
    Close c_WIList;
 end if;

 wf_core.context('XDPCORE_WI', 'AreAllWIsDone', itemtype, itemkey, null, x_Progress);
 raise;
when others then
 if c_WIList%ISOPEN then
    Close c_WIList;
 end if;

 x_Progress := 'XDPCORE_WI.AreAllWIsDone. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_WI', 'AreAllWIsDone', itemtype, itemkey, null, x_Progress);
 raise;
end AreAllWIsDone;



Procedure LaunchWorkitemProcess (itemtype in varchar2,
                                 itemkey in varchar2)
is
 l_OrderID number;
 l_LineItemID number;
 l_WIInstanceID number;
 l_Priority number;
 l_WorkitemID number;
 l_ErrCode number;

 l_wiwf varchar2(40);
 l_UserItemType varchar2(10);
 l_UserItemKey varchar2(240);
 l_UserItemKeyPrefix varchar2(240);
 l_UserWIProc varchar2(40);
 l_UserWFProcess varchar2(40);
 l_ErrDescription varchar2(800);
 l_WFItemType varchar2(10);
 l_WFItemKey varchar2(240);
 l_FAMapProc varchar2(40);


 e_CallWIWfProcException exception;
 e_NullWIWfProcException exception;
 e_CallWIMapProcException exception;
 e_InvalidWITypeException exception;
 e_InvalidUserWFConfigException exception;
 e_UserWFCreateException exception;
 e_WIWFCreateException exception;
 e_AddWItoQException exception;
 e_AddWFItemException exception;


 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNUmber(itemtype => LaunchWorkitemProcess.itemtype,
                                          itemkey => LaunchWorkitemProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNUmber(itemtype => LaunchWorkitemProcess.itemtype,
                                             itemkey => LaunchWorkitemProcess.itemkey,
                                             aname => 'LINE_ITEM_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => LaunchWorkitemProcess.itemtype,
                                               itemkey => LaunchWorkitemProcess.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_WorkitemID := wf_engine.GetItemAttrNumber(itemtype => LaunchWorkitemProcess.itemtype,
                                             itemkey => LaunchWorkitemProcess.itemkey,
                                             aname => 'WORKITEM_ID');

 l_Priority := wf_engine.GetItemAttrNumber(itemtype => LaunchWorkitemProcess.itemtype,
                                           itemkey => LaunchWorkitemProcess.itemkey,
                                           aname => 'WI_PRIORITY');



 CheckIfWorkItemIsaWorkflow(l_WorkitemID, l_wiwf, l_UserItemType,
                            l_UserItemKeyPrefix, l_UserWFProcess, l_UserWIProc, l_FAMapProc);


/* The workitem can be of 4 types:
         1. Workflow with the procedure specified.
         2. Workflow with the itemtype, key profix and the process name specified
         3. Dynamic FA Mapping
         4. Statis FA Mapping
      */

   if l_wiwf = 'WORKFLOW_PROC' then
      /* The Workitem is a WOrkflow Process */

           if l_UserWIProc is null then
              x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Could Not Find User Defined Workflow Procedure for Workitem: '|| l_WorkitemID || ' Order: ' || l_OrderID;
              x_Progress := x_Progress || ' Workitem InstanceID: ' || l_WIInstanceID|| ' LineItemID: ' || l_LineItemID || ' Check Workitem Configuration';
              RAISE e_NullWIWfProcException;
           end if;


         /* The user has defined a procedure for the workitem*/
         /* Execute the procedure dynamically and get the item type and item key */
         /* The Create Process for the Workflo SHOULD be done in the Procedure */

         XDP_UTILITIES.CallWIWorkflowProc ( P_PROCEDURE_NAME => l_UserWIProc,
                                            P_ORDER_ID => l_OrderID,
                                            P_LINE_ITEM_ID => l_LineItemID,
                                            P_WI_INSTANCE_ID => l_WIInstanceID,
                                            P_WF_ITEM_TYPE => l_WFItemType,
                                            P_WF_ITEM_KEY => l_WFItemKey,
                                            P_WF_PROCESS_NAME => l_UserWFProcess,
                                            P_RETURN_CODE => l_ErrCode,
                                            P_ERROR_DESCRIPTION => l_ErrDescription);

          if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Executing The user-defined Workflow Procedure: '|| l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '|| SUBSTR(l_ErrDescription, 1, 1500);
             RAISE e_CallWIWfProcException;
          end if;

 /*
  Raja: 04-Nov-1999
  Must set the parent child relation ships
 */

     wf_engine.SetItemParent(itemtype => l_WFItemType,
                             itemkey => l_WFItemKey,
                             parent_itemtype => LaunchWorkitemProcess.itemtype,
                             parent_itemkey => LaunchWorkitemProcess.itemkey,
                             parent_context => null);

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'LINE_ITEM_ID',
                                            AttrValue => l_LineItemID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding LINE_ITEM_ID attri bute for the user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '|| SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

-- Raja: 09/14/2000
--       Set the WF Item Attributes WORKITEM_INSTANCE_ID, ORDER_ID
--       Found by Burnsy

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'WORKITEM_INSTANCE_ID',
                                            AttrValue => l_WIInstanceID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding WORKITEM_INSTANCE_ID attribute for the user-defined Workflow Procedure: '|| l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'ORDER_ID',
                                            AttrValue => l_OrderID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding ORDER_ID attribute for the user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

 --         /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;
*/
    elsif l_wiwf = 'WORKFLOW' then
           if (l_UserItemKeyPrefix is null) OR (l_UserItemType is null) OR
              (l_UserWFProcess is null) then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Invalid user-defined Workitem Workfl ow Configuration. Itemtype: ' || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix;
             x_Progress := x_Progress  || ' WF Proce ss: ' || l_UserWFProcess || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID;
                 RAISE e_InvalidUserWFConfigException;
           end if;

            /* The user has defined the item type, process name and has given the itemkey
               prefix SFM should start the process for them */

              l_WFItemType := l_UserItemType;


              CreateWorkitemProcess('USER', itemtype, itemkey, l_WFItemType,
                                    l_UserItemKeyPrefix, l_WFItemKey,
                                    l_UserWFProcess,l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                                    'WAITFORFLOW-IND_WI',
                                    l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when creating the Workflow Process for user-defined workflow. Itemtype: ' || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix || ' WF Proce ss: ';
             x_Progress := x_Progress  || l_UserWFProcess || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '|| SUBSTR(l_ErrDescription, 1, 1500);
                RAISE e_UserWFCreateException;
             end if;

--          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;
*/

    elsif l_wiwf = 'DYNAMIC' then
           /* The Workitem List is dynamic */
         l_WFItemType := 'XDPPROV';

         CreateWorkitemProcess('XDP', itemtype, itemkey, l_WFItemType,
                               null, l_WFItemKey,
                              'WORKITEM_PROCESS',l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                              'WAITFORFLOW-IND_WI',
                               l_ErrCode, l_ErrDescription);

         if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when creating the WORKITEM_PROCESS Workflow Process for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
            RAISE e_WIWFCreateException;
         end if;


    elsif l_wiwf = 'STATIC' then
            /* The workitem is a regular FA list process */

             l_WFItemType := 'XDPPROV';

             CreateWorkitemProcess('XDP', itemtype, itemkey, l_WFItemType,
                                   null, l_WFItemKey,
                                  'WORKITEM_PROCESS',l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                                  'WAITFORFLOW-IND_WI',
                                   l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when creating the WORKITEM_PRO CESS Workflow Process for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
                RAISE e_WIWFCreateException;
             end if;

    else
          /* Invalid Configuration again */
          x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Invalid Workitem type: ' || l_wiwf || ' for workitemID: ' || l_WorkitemID || ' Order: ' || l_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
          RAISE e_InvalidWITypeException;

    end if;

/* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;


            /* Enqueue all the  Wormitems in the Workitem Queue */

            XDP_AQ_UTILITIES.ADD_WORKITEM_TOQ ( P_ORDER_ID          => l_OrderID,
                                                P_WI_INSTANCE_ID    => l_WIInstanceID,
                                                P_PROV_DATE         => GetWIProvisioningDate(l_WIInstanceID),
                                                P_WF_ITEM_TYPE      => l_WFItemType,
                                                P_WF_ITEM_KEY       => l_WFItemKey,
                                                P_PRIORITY          => l_Priority,
                                                P_RETURN_CODE       => l_ErrCode,
                                                P_ERROR_DESCRIPTION => l_ErrDescription);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error When Adding Workitem to Queue . Itemtype : ' || l_WFItemType || ' Itemkey: ' || l_WFItemKey || ' for workitemID: ' || l_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWItoQException;
           end if;

exception
when e_CallWIWfProcException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_NullWIWfProcException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_CallWIMapProcException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_InvalidWITypeException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_InvalidUserWFConfigException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_UserWFCreateException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_WIWFCreateException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddWItoQException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddWFItemException then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;

when others then
   wf_core.context('XDPCORE_WI', 'LaunchWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;
end LaunchWorkitemProcess;

Function LaunchAllIndependentWIs (itemtype in varchar2,
                                  itemkey in varchar2) return varchar2
is
 l_OrderID number;
 l_LineItemID number;
 l_WIInstanceID number;
 l_WorkitemID number;
 l_Priority number;

 l_result varchar2(1) := 'N';

 cursor c_GetIndWIList (OrderID number, LineItemID number) is
   select WORKITEM_INSTANCE_ID, WORKITEM_ID, PRIORITY
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE = 0;

 e_NoWorkitemsFoundException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin
 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndependentWIs.itemtype,
                                          itemkey => LaunchAllIndependentWIs.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndependentWIs.itemtype,
                                             itemkey => LaunchAllIndependentWIs.itemkey,
                                             aname => 'LINE_ITEM_ID');

   /* Create WF Processes for all the independent Workitems */

  FOR lv_WIRec in c_GetIndWIList(l_OrderID, l_LineItemID) LOOP
    l_result := 'Y';
    l_WIInstanceID := lv_WIRec.workitem_instance_id;
    l_WorkitemID := lv_WIRec.workitem_id;
    l_Priority := lv_WIRec.priority;
    LaunchIndWorkitemProcess( itemtype => LaunchAllIndependentWIs.itemtype,
                           itemkey => LaunchAllIndependentWIs.itemkey,
                           p_OrderID => l_OrderID ,
                           p_LineItemID => l_LineItemID,
                           p_WorkitemID => l_WorkitemID,
                           p_WIInstanceID => l_WIInstanceID,
                           p_Priority => l_Priority);
  END LOOP;

  return l_result;

exception
 when others then
   x_Progress := 'XDPCORE_WI.LaunchAllIndependentWIs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   xdpcore.context('XDPCORE_WI', 'LaunchAllIndependentWIs', 'LINE', l_LineItemID,x_Progress);
   wf_core.context('XDPCORE_WI', 'LaunchAllIndependentWIs', itemtype, itemkey, null, x_Progress);
   raise;
end LaunchAllIndependentWIs;

Procedure LaunchIndWorkitemProcess (itemtype in varchar2,
                                 itemkey in varchar2,
                                 p_OrderID in NUMBER,
                                 p_LineItemID in NUMBER,
                                 p_WorkitemID in NUMBER,
                                 p_WIInstanceID in NUMBER,
                                 p_Priority in NUMBER)


is

 l_ErrCode number;

 l_wiwf varchar2(40);
 l_UserItemType varchar2(10);
 l_UserItemKey varchar2(240);
 l_UserItemKeyPrefix varchar2(240);
 l_UserWIProc varchar2(40);
 l_UserWFProcess varchar2(40);
 l_ErrDescription varchar2(800);
 l_WFItemType varchar2(10);
 l_WFItemKey varchar2(240);
 l_FAMapProc varchar2(40);

 e_CallWIWfProcException exception;
 e_NullWIWfProcException exception;
 e_CallWIMapProcException exception;
 e_InvalidWITypeException exception;
 e_InvalidUserWFConfigException exception;
 e_UserWFCreateException exception;
 e_WIWFCreateException exception;
 e_AddWItoQException exception;
 e_AddWFItemException exception;

 x_Progress                     VARCHAR2(2000);

begin

 CheckIfWorkItemIsaWorkflow(p_WorkitemID, l_wiwf, l_UserItemType, l_UserItemKeyPrefix,
                            l_UserWFProcess, l_UserWIProc, l_FAMapProc);


 /* The workitem can be of 4 types:
         1. Workflow with the procedure specified.
         2. Workflow with the itemtype, key profix and the process name specified
         3. Dynamic FA Mapping
         4. Statis FA Mapping
 */

 IF l_wiwf = 'WORKFLOW_PROC' THEN  /* The Workitem is a WOrkflow Process */
   IF l_UserWIProc IS NULL THEN
              x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Could Not Find User Defined Workflow Procedure for Workitem: '|| p_WorkitemID || ' Order: ' || p_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || p_WIInstanceID || 'LineItemID: ' || p_LineItemID || ' Check Workitem Configuration';
              RAISE e_NullWIWfProcException;
           end if;

         /* The user has defined a procedure for the workitem*/
         /* Execute the procedure dynamically and get the item type and item key */
         /* The Create Process for the Workflo SHOULD be done in the Procedure */

         XDP_UTILITIES.CallWIWorkflowProc ( P_PROCEDURE_NAME => l_UserWIProc,
                                            P_ORDER_ID => p_OrderID,
                                            P_LINE_ITEM_ID => p_LineItemID,
                                            P_WI_INSTANCE_ID => p_WIInstanceID,
                                            P_WF_ITEM_TYPE => l_WFItemType,
                                            P_WF_ITEM_KEY => l_WFItemKey,
                                            P_WF_PROCESS_NAME => l_UserWFProcess,
                                            P_RETURN_CODE => l_ErrCode,
                                            P_ERROR_DESCRIPTION => l_ErrDescription);

          if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when Executing The user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
             RAISE e_CallWIWfProcException;
          end if;

 /*
  Raja: 04-Nov-1999
  Must set the parent child relation ships
 */

     wf_engine.SetItemParent(itemtype => l_WFItemType,
                             itemkey => l_WFItemKey,
                             parent_itemtype => LaunchIndWorkitemProcess .itemtype,
                             parent_itemkey => LaunchIndWorkitemProcess .itemkey,
                             parent_context => null);

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'LINE_ITEM_ID',
                                            AttrValue => p_LineItemID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when Adding LINE_ITEM_ID attribute for the user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

-- Raja: 09/14/2000
--       Set the WF Item Attributes WORKITEM_INSTANCE_ID, ORDER_ID
--       Found by Burnsy

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'WORKITEM_INSTANCE_ID',
                                            AttrValue => p_WIInstanceID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when Adding WORKITEM_INSTANCE_ID attribute for the user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

           XDPCORE.CheckNAddItemAttrNumber (itemtype => l_WFItemType,
                                            itemkey => l_WFItemKey,
                                            AttrName => 'ORDER_ID',
                                            AttrValue => p_OrderID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when Adding ORDER_ID attribute for the user-defined Workflow Procedure: ' || l_UserWIProc || ' for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

--          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = p_WIInstanceID;
*/
    elsif l_wiwf = 'WORKFLOW' then
           if (l_UserItemKeyPrefix is null) OR (l_UserItemType is null) OR
              (l_UserWFProcess is null) then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Invalid user-defined Workitem Workflow Configuration. Itemtype: ' || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix || ' WF Process: ';
             x_Progress := x_Progress  || l_UserWFProcess || ' for Workitem: ' || p_WorkitemID || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID;
                 RAISE e_InvalidUserWFConfigException;
           end if;

            /* The user has defined the item type, process name and has given the itemkey
               prefix SFM should start the process for them */

              l_WFItemType := l_UserItemType;


              CreateWorkitemProcess('USER', itemtype, itemkey, l_WFItemType,
                                    l_UserItemKeyPrefix, l_WFItemKey,
                                    l_UserWFProcess,p_OrderID, p_LineItemID,
                                    p_WorkitemID, p_WIInstanceID,
                                    'WAITFORFLOW-IND_WI',
                                    l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when creating the
Workflow Process for user-defined workflow. Itemtype: ' || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix || ' WF Process: ' || l_UserWFProcess || ' for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
                RAISE e_UserWFCreateException;
             end if;

--          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = p_WIInstanceID;
*/

    elsif l_wiwf = 'DYNAMIC' then
           /* The Workitem List is dynamic */
         l_WFItemType := 'XDPPROV';

         CreateWorkitemProcess('XDP', itemtype, itemkey, l_WFItemType, null, l_WFItemKey,
                               'WORKITEM_PROCESS',p_OrderID, p_LineItemID,
                               p_WorkitemID, p_WIInstanceID, 'WAITFORFLOW-IND_WI',
                               l_ErrCode, l_ErrDescription);

         if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when creating the
WORKITEM_PROCESS Workflow Process for Workitem: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
            RAISE e_WIWFCreateException;
         end if;


    elsif l_wiwf = 'STATIC' then
            /* The workitem is a regular FA list process */

             l_WFItemType := 'XDPPROV';

             CreateWorkitemProcess('XDP', itemtype, itemkey, l_WFItemType, null, l_WFItemKey,
                                  'WORKITEM_PROCESS',p_OrderID, p_LineItemID, p_WorkitemID, p_WIInstanceID,
                                  'WAITFORFLOW-IND_WI', l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error when creating the WORKITEM_PROCESS Workflow Process for Workitem: ' || p_WorkitemID || ' Order: ' || p_OrderID;
             x_Progress := x_Progress || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
                RAISE e_WIWFCreateException;
             end if;

    else
          /* Invalid Configuration again */
          x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Invalid Workitem type: ' ||
l_wiwf || ' for workitemID: ' || p_WorkitemID || ' Order: ' || p_OrderID;
             x_Progress := x_Progress  || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
          RAISE e_InvalidWITypeException;

    end if;


          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = l_WFItemType,
                       WF_ITEM_KEY = l_WFItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = p_WIInstanceID;

            /* Enqueue all the  Wormitems in the Workitem Queue */

            XDP_AQ_UTILITIES.ADD_WORKITEM_TOQ ( P_ORDER_ID          => p_OrderID,
                                                P_WI_INSTANCE_ID    => p_WIInstanceID,
                                                P_PROV_DATE         => GetWIProvisioningDate(p_WIInstanceID),
                                                P_WF_ITEM_TYPE      => l_WFItemType,
                                                P_WF_ITEM_KEY       => l_WFItemKey,
                                                P_PRIORITY          => p_Priority,
                                                P_RETURN_CODE       => l_ErrCode,
                                                P_ERROR_DESCRIPTION => l_ErrDescription);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_WI.LaunchIndWorkitemProcess . Error When Adding Workitem to Queue. Itemtype : ' || l_WFItemType || ' Itemkey: ' || l_WFItemKey || ' for workitemID: ' || p_WorkitemID;
             x_Progress := x_Progress  || ' Order: ' || p_OrderID || ' Workitem InstanceID: ' || p_WIInstanceID || ' LineItemID: ' || p_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
             RAISE e_AddWItoQException;
           end if;
EXCEPTION
  WHEN others THEN
   wf_core.context('XDPCORE_WI', 'LaunchIndWorkitemProcess ', itemtype, itemkey, null, x_Progress);
   raise;
end LaunchIndWorkitemProcess ;



Procedure CheckIfWorkItemIsaWorkflow(workitem_ID in number,
                                    wf_flag OUT NOCOPY varchar2,
                                    user_item_type OUT NOCOPY varchar2,
                                    user_item_key_prefix OUT NOCOPY varchar2,
                                    user_wf_process_name OUT NOCOPY varchar2,
                                    user_wf_proc OUT NOCOPY varchar2,
                                    fa_exec_map_proc OUT NOCOPY varchar2)
is
 e_CheckWIException exception;
 x_Progress                     VARCHAR2(2000);

 cursor c_CheckWI is
   select WI_TYPE_CODE, NVL(USER_WF_ITEM_TYPE,null) ITEM_TYPE,
	  NVL(USER_WF_ITEM_KEY_PREFIX, null) ITEM_KEY_PREFIX ,
          NVL(USER_WF_PROCESS_NAME, null) PROCESS_NAME,
	  NVL(WF_EXEC_PROC, null) WF_EXEC_PROC,
          NVL(FA_EXEC_MAP_PROC, null) FA_EXEC_MAP_PROC
   from XDP_WORKITEMS
    where WORKITEM_ID = CheckIfWorkItemIsaWorkflow.workitem_ID;

begin

  for v_CheckWI in c_CheckWI loop
	wf_flag := v_CheckWI.WI_TYPE_CODE;
	user_item_type := v_CheckWI.ITEM_TYPE;
	user_item_key_prefix := v_CheckWI.ITEM_KEY_PREFIX;
	user_wf_process_name := v_CheckWI.PROCESS_NAME;
	user_wf_proc := v_CheckWI.WF_EXEC_PROC;
	fa_exec_map_proc := v_CheckWI.FA_EXEC_MAP_PROC;
  end loop;

exception
when others then
 x_Progress := 'XDPCORE_WI.CheckIfWorkItemIsaWorkflow. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_WI', 'CheckIfWorkItemIsaWorkflow', null, null, null,null);
 raise;
end CheckIfWorkItemIsaWorkflow;



Function ContinueWorkitem (itemtype in varchar2,
                           itemkey in varchar2)  return varchar2 is
 l_OrderID number;
 l_Continue varchar2(1) := 'N';

 x_Progress                     VARCHAR2(2000);

 CURSOR c_ContinueWI(p_OrderID number) is
     select 'Y' yahoo
      from dual
      where exists (select WORKITEM_INSTANCE_ID
                    from XDP_FULFILL_WORKLIST
                    where ORDER_ID = p_OrderID
                      and status_code   in ('READY','IN PROGRESS') );
begin
 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ContinueWorkitem.itemtype,
                                          itemkey => ContinueWorkitem.itemkey,
                                          aname => 'ORDER_ID');

 for v_ContinueWI in c_ContinueWI(l_OrderID) loop
	l_Continue := v_ContinueWI.yahoo;
	exit;
 end loop;
/*
   begin
     select 'Y' into l_Continue from dual
      where exists (select WORKITEM_INSTANCE_ID
                    from XDP_FULFILL_WORKLIST
                    where ORDER_ID = l_OrderID
                      and status_code   = 'READY' );

   exception
   when no_data_found then
      l_Continue := 'N';
   when others then
      RAISE;
   end;
*/
 return (l_Continue);

exception
when others then
   x_Progress := 'XDPCORE_WI.ContinueWorkitem. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_WI', 'ContinueWorkitem',itemtype, itemkey, null, null);
   raise;
end ContinueWorkitem;

Procedure InitializeWorkitemProcess(itemtype in varchar2,
                                    itemkey in varchar2) IS

 l_WIInstanceID number;

 e_InvalidConfigException exception;

 x_Progress                     VARCHAR2(2000);

begin

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => InitializeWorkitemProcess.itemtype,
                                               itemkey => InitializeWorkitemProcess.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 if l_WIInstanceID is null then
    RAISE e_InvalidConfigException;
 else
    /* Update the STATUS of the Workitems to be processed */

       UPDATE_WORKITEM_STATUS(p_workitem_instance_id => l_WIInstanceID,
                              p_status_code          => 'IN PROGRESS',
                              p_itemtype             => InitializeWorkitemProcess.itemtype,
                              p_itemkey              => InitializeWorkitemProcess.itemkey );
 end if;

exception
when others then
   x_Progress := 'XDPCORE_WI.InitializeWorkitemProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_WI', 'InitializeWorkitemProcess', itemtype, itemkey, null, x_Progress);
   raise;
end InitializeWorkitemProcess;



Procedure CreateWorkitemProcess (wftype in varchar2,
                                 parentitemtype in varchar2,
                                 parentitemkey in varchar2,
                                 itemtype in varchar2,
                                 itemkeyPrefix in varchar2,
                                 itemkey OUT NOCOPY varchar2,
                                 workflowprocessname in varchar2,
                                 OrderID in number,
                                 LineItemID in number,
                                 WorkitemID in number,
                                 WIInstanceID in number,
                                 WFMaster in varchar2,
                                 ErrCode OUT NOCOPY number,
                                 ErrStr OUT NOCOPY varchar2)
is

 l_tempKey varchar2(240);


 x_Progress                     VARCHAR2(2000);

begin

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;

    if itemkeyPrefix is null then
       itemkey := to_char(OrderID) || '-WI-' || l_tempKey;
    else
       itemkey := to_char(OrderID) || '-WI-' || itemkeyPrefix || l_tempKey;
    end if;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => Itemtype,
			      itemkey => Itemkey,
			      processname => workflowprocessname,
			      parentitemtype => parentitemtype,
			      parentitemkey => parentitemkey,
			      OrderID => OrderID,
			      LineitemID => LineItemID,
			      WIInstanceID => WIInstanceID,
			      FAInstanceID => null);

   if wftype = 'XDP' then

       XDPCORE.CheckNAddItemAttrNumber (itemtype => itemtype,
                                        itemkey => itemkey,
                                        AttrName => 'WORKITEM_ID',
                                        AttrValue => WorkitemID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         return;
      end if;


   end if;

    if wftype = 'XDP' then
       null;
    else
       XDPCORE.CheckNAddItemAttrNumber (itemtype => itemtype,
                                        itemkey => itemkey,
                                        AttrName => 'LINE_ITEM_ID',
                                        AttrValue => LineItemID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);
    end if;


exception
when others then
 ErrCode := SQLCODE;
 ErrStr := SUBSTR(SQLERRM, 1, 800);
end CreateWorkitemProcess;

Procedure InitDepWIProcess (itemtype in varchar2,
                    itemkey in varchar2)
is

 ErrCode number;
 ErrStr varchar2(1996);

 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

begin

       XDPCORE.CheckNAddItemAttrNumber (itemtype => InitDepWIProcess.itemtype,
                                        itemkey => InitDepWIProcess.itemkey,
                                        AttrName => 'CURRENT_WI_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchWIServiceProcess. Error when adding Item Attribute CURRENT_WI_SEQUENCE. Error:' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


EXCEPTION
  when others then
   x_Progress := 'XDPCORE_WI.InitDepWIProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 xdpcore.context('XDPCORE_WI', 'InitDepWIProcess', itemtype, itemkey,x_Progress);
 wf_core.context('XDPCORE_WI', 'InitDepWIProcess', itemtype, itemkey, null, x_Progress);
  raise;
end InitDepWIProcess;




Procedure LaunchWIServiceProcess (itemtype in varchar2,
                                  itemkey in varchar2)
is
 l_OrderID number;
 l_LineItemID number;
 l_WIInstanceID number;
 l_WorkitemID number;
 l_Counter number := 0;
 l_Priority number;

 l_tempKey varchar2(240);


 cursor c_GetIndWIList (OrderID number, LineItemID number) is
   select WORKITEM_INSTANCE_ID, WORKITEM_ID, PRIORITY
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE = 0;

 cursor c_GetDepWIList (OrderID number, LineItemID number) is
   select WORKITEM_INSTANCE_ID
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE > 0;



TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

 e_NoWorkitemsFoundException exception;
 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchWIServiceProcess.itemtype,
                                          itemkey => LaunchWIServiceProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchWIServiceProcess.itemtype,
                                             itemkey => LaunchWIServiceProcess.itemkey,
                                             aname => 'LINE_ITEM_ID');

 if c_GetIndWIList%ISOPEN then
    close c_GetIndWIList;
 end if;

  /* Create WF Processes for all the independent Workitems */

  open c_GetIndWIList(l_OrderID, l_LineItemID);
  LOOP
    Fetch c_GetIndWIList into l_WIInstanceID, l_WorkitemID, l_Priority;
    EXIT when c_GetIndWIList%NOTFOUND;

     l_Counter := l_Counter + 1;

     select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
     l_tempKey := to_char(l_OrderID) || '-WI-' || to_char(l_WIInstanceID) || l_tempKey;

     t_ChildTypes(l_Counter) := 'XDPPROV';
     t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'INDEPENDENT_WI_PROCESS',
			      parentitemtype => LaunchWIServiceProcess.itemtype,
			      parentitemkey => LaunchWIServiceProcess.itemkey,
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => l_WIInstanceID,
			      FAInstanceID => null);


       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'WORKITEM_ID',
                                        AttrValue => l_WorkitemID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchWIServiceProcess. Error when adding Item Attribute WORKITEM_ID. Error:
' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'WI_PRIORITY',
                                      AttrValue => to_char(l_Priority),
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchWIServiceProcess. Error when adding Item Attribute WI_PRIORITY. Error:
' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;
  END LOOP;

  close c_GetIndWIList;

  /* Create ONE workflow Process for processing all the depeneden WOrkitems */

  if c_GetDepWIList%ISOPEN then
     close c_GetDepWIList;
  end if;

  open c_GetDepWIList(l_OrderID, l_LineItemID);
  Fetch c_GetDepWIList into l_WIInstanceID;

  if c_GetDepWIList%FOUND then

     l_Counter := l_Counter + 1;

     select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
     l_tempKey := to_char(l_OrderID) || '-WI-' || to_char(l_WIInstanceID) || l_tempKey;

     t_ChildTypes(l_Counter) := 'XDPPROV';
     t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'DEPENDENT_WI_PROCESS',
			      parentitemtype => LaunchWIServiceProcess.itemtype,
			      parentitemkey => LaunchWIServiceProcess.itemkey,
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => l_WIInstanceID,
			      FAInstanceID => null);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'CURRENT_WI_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchWIServiceProcess. Error when adding Item Attribute CURRENT_WI_SEQUENCE. Error:
' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

   end if;

   close c_GetDepWIList;

   if l_Counter = 0 then
      x_Progress := 'XDPCORE_WI.LaunchWIServiceProcess. Found No workitems to be processed for Order: ' || l_OrderID || ' LineItemID: ' || l_LineItemID;
      RAISE e_NoWorkitemsFoundException;
   else

      FOR i in 1..l_Counter LOOP
           wf_engine.StartProcess(itemtype => t_ChildTypes(i),
                                  itemkey => t_ChildKeys(i));
      END LOOP;

   end if;

exception
when e_AddAttributeException then
 if c_GetIndWIList%ISOPEN then
    close c_GetIndWIList;
 end if;

  if c_GetDepWIList%ISOPEN then
     close c_GetDepWIList;
  end if;

 wf_core.context('XDPCORE_WI', 'LaunchWIServiceProcess', itemtype, itemkey, null, x_Progress);
 raise;

when e_NoWorkitemsFoundException then
 if c_GetIndWIList%ISOPEN then
    close c_GetIndWIList;
 end if;

  if c_GetDepWIList%ISOPEN then
     close c_GetDepWIList;
  end if;

 wf_core.context('XDPCORE_WI', 'LaunchWIServiceProcess', itemtype, itemkey, null, x_Progress);
 raise;

when others then
 if c_GetIndWIList%ISOPEN then
    close c_GetIndWIList;
 end if;

  if c_GetDepWIList%ISOPEN then
     close c_GetDepWIList;
  end if;

   x_Progress := 'XDPCORE_WI.LaunchWIServiceProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_WI', 'LaunchWIServiceProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchWIServiceProcess;



Procedure LaunchWISeqProcess (itemtype in varchar2,
                              itemkey in varchar2)
is

 l_PrevSequence number;
 l_CurrentSequence number;
 l_OrderID number;
 l_LineItemID number;
 l_Priority number;
 l_WorkitemID number;
 l_WIInstanceID number;
 l_Counter number := 0;
 l_ErrCode number;

 l_wiwf varchar2(40);
 l_UserItemType varchar2(10);
 l_UserItemKey varchar2(240);
 l_UserItemKeyPrefix varchar2(240);
 l_UserWIProc varchar2(40);
 l_UserWFProcess varchar2(40);
 l_ErrDescription varchar2(800);
 l_FAMapProc varchar2(40);


 l_tempKey varchar2(240);


 e_NoWIsFoundException exception;
 e_UserWFCreateException exception;
 e_WIWFCreateException exception;
 e_NullWIWfProcException exception;
 e_CallWIWFProcException exception;
 e_InvalidUserWFConfigException exception;
 e_CallWIMapProcException exception;
 e_AddWItoQException exception;
 e_InvalidWITypeException exception;
 e_AddWFItemException exception;
 e_AddAttributeException exception;

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

TYPE t_IdTable is table of number INDEX BY BINARY_INTEGER;
t_WIIDList t_IdTable;
t_PriorityList t_IdTable;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchWISeqProcess.itemtype,
                                          itemkey => LaunchWISeqProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchWISeqProcess.itemtype,
                                             itemkey => LaunchWISeqProcess.itemkey,
                                             aname => 'LINE_ITEM_ID');

 l_PrevSequence := wf_engine.GetItemAttrNumber(itemtype => LaunchWISeqProcess.itemtype,
                                               itemkey => LaunchWISeqProcess.itemkey,
                                               aname => 'CURRENT_WI_SEQUENCE');

 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

 open c_WIList(l_OrderID, l_LineItemID, l_PrevSequence);

 LOOP
   Fetch c_WIList into l_WIInstanceID, l_WorkitemID, l_Priority, l_CurrentSequence;
    EXIT when c_WIList%NOTFOUND;

    l_Counter := l_Counter + 1;

    t_WIIDList(l_Counter) := l_WIInstanceID;
    t_PriorityList(l_Counter) := l_Priority;

    CheckIfWorkItemIsaWorkflow(l_WorkitemID, l_wiwf, l_UserItemType,
                            l_UserItemKeyPrefix, l_UserWFProcess, l_UserWIProc, l_FAMapProc);

      /* The workitem can be of 4 types:
         1. Workflow with the procedure specified.
         2. Workflow with the itemtype, key profix and the process name specified
         3. Dynamic FA Mapping
         4. Statis FA Mapping
      */

      if l_wiwf = 'WORKFLOW_PROC' then
         /* The Workitem is a WOrkflow Process */

           if l_UserWIProc is null then
              x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Could Not Find User DefinedWorkflow Procedure for Workitem: '
                     || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID
                     || ' LineItemID: ' || l_LineItemID || ' Check WorkitemConfiguration';

              RAISE e_NullWIWfProcException;
           end if;

            /* The user has defined a procedure for the workitem*/
            /* Execute the procedure dynamically and get the item type and item key */
            /* The Create Process for the Workflo SHOULD be done in the Procedure */

            XDP_UTILITIES.CallWIWorkflowProc ( P_PROCEDURE_NAME => l_UserWIProc,
                                               P_ORDER_ID => l_OrderID,
                                               P_LINE_ITEM_ID => l_LineItemID,
                                               P_WI_INSTANCE_ID => l_WIInstanceID,
                                               P_WF_ITEM_TYPE => t_ChildTypes(l_Counter),
                                               P_WF_ITEM_KEY => t_ChildKeys(l_Counter),
                                               P_WF_PROCESS_NAME => l_UserWFProcess,
                                               P_RETURN_CODE => l_ErrCode,
                                               P_ERROR_DESCRIPTION => l_ErrDescription);

             if l_ErrCode <> 0 then
                x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Error when Executing The user-defined Workflow Procedure: '
                     || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || 'Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '
                     || SUBSTR(l_ErrDescription, 1, 1500);

                RAISE e_CallWIWFProcException;
             end if;

 /*
  Raja: 04-Nov-1999
  Must set the parent child relation ships
 */

     wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                             itemkey => t_ChildKeys(l_Counter),
                             parent_itemtype => LaunchWISeqProcess.itemtype,
                             parent_itemkey => LaunchWISeqProcess.itemkey,
                             parent_context => null);

           XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                            itemkey => t_ChildKeys(l_Counter),
                                            AttrName => 'LINE_ITEM_ID',
                                            AttrValue => l_LineItemID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding LINE_ITEM_ID attribute for the user-defined Workflow Procedure: '
                     || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '
                     || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;


-- Raja: 09/14/2000
--       Set the WF Item Attributes WORKITEM_INSTANCE_ID, ORDER_ID
--       Found by Burnsy

           XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                            itemkey => t_ChildKeys(l_Counter),
                                            AttrName => 'WORKITEM_INSTANCE_ID',
                                            AttrValue => l_WIInstanceID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding WORKITEM_INSTANCE_ID attribute for the user-defined Workflow Procedure: '
                     || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '
                     || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

           XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                            itemkey => t_ChildKeys(l_Counter),
                                            AttrName => 'ORDER_ID',
                                            AttrValue => l_OrderID,
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);

           if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWorkitemProcess. Error when Adding ORDER_ID attribute for the user-defined Workflow Procedure: '
                     || l_UserWIProc || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '
                     || SUBSTR(l_ErrDescription, 1, 1500);
              RAISE e_AddWFItemException;
           end if;

 --         /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = t_ChildTypes(l_Counter),
                       WF_ITEM_KEY = t_ChildKeys(l_Counter),
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;
*/
      elsif l_wiwf = 'WORKFLOW' then

             if (l_UserItemKeyPrefix is null) OR (l_UserItemType is null) OR
                (l_UserWFProcess is null) then
                 x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Invalid user-defined Workitem Workflow Configuration. Itemtype: '
                     || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix || ' WF Process: '
                     || l_UserWFProcess || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID;

                 RAISE e_InvalidUserWFConfigException;
             end if;


             /* The user has defined the item type, process name and has given the itemkey
             ** prefix SFM should start the process for them
             */

                 t_ChildTypes(l_Counter) := l_UserItemType;

                 CreateWorkitemProcess('USER', itemtype, itemkey, t_ChildTypes(l_Counter),
                                       l_UserItemKeyPrefix, t_ChildKeys(l_Counter),
                                       l_UserWFProcess,l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                                       'WAITFORFLOW-DEP_WI',
                                       l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
                x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Error when creating the Workflow Process for user-defined workflow. Itemtype: '
                     || l_UserItemType || ' ItemKey Prefix: ' || l_UserItemKeyPrefix || ' WF Process: '
                     || l_UserWFProcess || ' for Workitem: ' || l_WorkitemID || ' Order: ' || l_OrderID
                     || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: ' || l_LineItemID || ' Error: '
                     || SUBSTR(l_ErrDescription, 1, 1500);

                RAISE e_UserWFCreateException;
             end if;


--          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */
/*
               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = t_ChildTypes(l_Counter),
                       WF_ITEM_KEY = t_ChildKeys(l_Counter),
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;
*/
      elsif l_wiwf = 'DYNAMIC' then
           /* The Workitem List is dynamic */

           t_ChildTypes(l_Counter) := 'XDPPROV';

           CreateWorkitemProcess('XDP', itemtype, itemkey, t_ChildTypes(l_Counter),
                                 null, t_ChildKeys(l_Counter),
                                'WORKITEM_PROCESS',l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                                'WAITFORFLOW-DEP_WI',
                                 l_ErrCode, l_ErrDescription);

          if l_ErrCode <> 0 then
             x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Error when creating the WORKITEM_PROCESS Workflow Process for Workitem: '
                     || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID
                     || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

             RAISE e_WIWFCreateException;
          end if;

      elsif l_wiwf = 'STATIC' then
            /* The workitem is a regular FA list process */
                t_ChildTypes(l_Counter) := 'XDPPROV';

               CreateWorkitemProcess('XDP', itemtype, itemkey, t_ChildTypes(l_Counter),
                                     null, t_ChildKeys(l_Counter),
                                    'WORKITEM_PROCESS',l_OrderID, l_LineItemID, l_WorkitemID, l_WIInstanceID,
                                    'WAITFORFLOW-DEP_WI',
                                     l_ErrCode, l_ErrDescription);

             if l_ErrCode <> 0 then
                x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Error when creating the WORKITEM_PROCESS Workflow Process for Workitem: '
                     || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID
                     || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

                RAISE e_WIWFCreateException;
             end if;

      else
          /* Invalid Configuration again */
          x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Invalid Workitem type: ' || l_wiwf || ' for workitemID: '
                     || l_WorkitemID || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID
                     || ' LineItemID: ' || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

          RAISE e_InvalidWITypeException;
      end if;


 END LOOP;

 close c_WIList;

 if l_Counter = 0 and l_CurrentSequence = 0 then
    x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. No Workitems found to be processed for Order: ' || l_OrderID || ' LineItemID: ' || l_LineItemID;

    RAISE e_NoWIsFoundException;
 else

       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchWISeqProcess.itemtype,
                                        itemkey => LaunchWISeqProcess.itemkey,
                                        AttrName => 'CURRENT_WI_SEQUENCE',
                                        AttrValue => l_CurrentSequence,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchWISeqProcess. Error when adding Item Attribute CURRENT_WI_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

          /* Update the XDP_FULFILL_WORKLIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FULFILL_WORKLIST
                   set WF_ITEM_TYPE = t_ChildTypes(l_Counter),
                       WF_ITEM_KEY = t_ChildKeys(l_Counter),
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   WORKITEM_INSTANCE_ID = l_WIInstanceID;

       /* Enqueue all the  Wormitems in the Workitem Queue */
       FOR i in 1..l_Counter LOOP

            XDP_AQ_UTILITIES.ADD_WORKITEM_TOQ ( P_ORDER_ID           => l_OrderID,
                                                P_WI_INSTANCE_ID     => t_WIIDList(i),
                                                P_PROV_DATE          => GetWIProvisioningDate(t_WIIDList(i)),
                                                P_WF_ITEM_TYPE       => t_ChildTypes(i),
                                                P_WF_ITEM_KEY        => t_ChildKeys(i),
                                                P_PRIORITY           => t_PriorityList(i),
                                                P_RETURN_CODE        => l_ErrCode,
                                                P_ERROR_DESCRIPTION  => l_ErrDescription);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Error When Adding Workitemto Queue. Itemtype : '
                     || t_ChildTypes(i) || ' Itemkey: ' || t_ChildKeys(i) || ' for workitemID: ' || l_WorkitemID
                     || ' Order: ' || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID || ' LineItemID: '
                     || l_LineItemID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

	      RAISE e_AddWItoQException;
           end if;

       END LOOP;
 end if;

exception
when e_AddAttributeException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_NoWIsFoundException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_CallWIWfProcException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_NullWIWfProcException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_CallWIMapProcException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_InvalidWITypeException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_InvalidUserWFConfigException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_UserWFCreateException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_WIWFCreateException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddWItoQException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddWFItemException then
 if c_WIList%ISOPEN then
    close c_WIList;
 end if;

   wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
   raise;

when others then
   x_Progress := 'XDPCORE_WI.LaunchWISeqProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_WI', 'LaunchWISeqProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchWISeqProcess;




Procedure GetWIParamOnStart(itemtype in varchar2,
                            itemkey  in varchar2)
 is

 x_Progress      VARCHAR2(2000);
 l_WIInstanceID  NUMBER;

begin

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => GetWIParamOnStart.itemtype,
                                               itemkey  => GetWIParamOnStart.itemkey,
                                               aname    => 'WORKITEM_INSTANCE_ID');

  xdp_engine.EvaluateWIParamsOnStart(l_WIInstanceID );


exception
     when others then
          x_Progress := 'XDPCORE_WI.GetWIParamOnStart. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_WI', 'GetWIParamOnStart', itemtype, itemkey, null, x_Progress);
          raise;
end GetWIParamOnStart;


Function IsWIAborted(WIInstanceID in number) return boolean

 is
 l_Status boolean := FALSE;
 l_WIState varchar2(40);
 l_LineState varchar2(40);
 l_LineItemID number;


 cursor c_GetWIState(p_WIInstanceID number) is
  select status_code, line_item_id from
  XDP_FULFILL_WORKLIST
  where workitem_instance_id = p_WIInstanceID
  for update;

 cursor c_GetLineState(p_LineItemID number) is
  select status_code from
  xdp_order_line_items
  where line_item_id  = p_LineItemID
  for update;

e_NoLinesFoundException exception;
e_NoWIFoundException exception;
begin

 Savepoint GetWIState;

 open c_GetWIState(WIInstanceID);
 Fetch c_GetWIState into l_WIState, l_LineItemID;

 if c_GetWIState%NOTFOUND then
   rollback to GetWIState;
   raise e_NoWIFoundException;
 end if;

 close c_GetWIState;

 if l_WIState IN ('CANCELED','ABORTED') then
    l_Status := TRUE;
    rollback to GetWIState;
    return l_Status;
 else
    open c_GetLineState(l_LineItemID);
    Fetch c_GetLineState into l_LineState;

    if c_GetLineState%NOTFOUND then
      rollback to GetWIState;
      raise e_NoLinesFoundException;
    end if;

    close c_GetLineState;

    if l_LineState IN ('CANCELED','ABORTED') then
       l_Status := TRUE;
       rollback to GetWIState;
       return l_Status;
    end if;

 end if;

  rollback to GetWIState;
  l_Status := FALSE;
  return l_Status;


exception
when others then
  if c_GetWIState%ISOPEN then
     close c_GetWIState;
  end if;
  if c_GetLineState%ISOPEN then
     close c_GetLineState;
  end if;
  rollback to GetWIState;
  raise;
end IsWIAborted;

Procedure EvaluateWIParamsOnStart(WIInstanceID in number)
is
begin

 null;

end EvaluateWIParamsOnStart;

PROCEDURE UPDATE_WORKITEM_STATUS(p_workitem_instance_id IN NUMBER,
                                 p_status_code          IN VARCHAR2,
                                 p_itemtype             IN VARCHAR2,
                                 p_itemkey              IN VARCHAR2) IS
 PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(20000);
BEGIN

    UPDATE xdp_fulfill_worklist
       SET status_code          = p_status_code ,
           wf_item_type         = p_itemtype ,
           wf_item_key          = p_itemkey ,
           last_update_date     = sysdate,
           last_updated_by      = fnd_global.user_id,
           last_update_login    = fnd_global.login_id
     WHERE workitem_instance_id = p_workitem_instance_id;

COMMIT;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_WI.UPDATE_WORKITEM_STATUS. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_WI', 'UPDATE_WORKITEM_STATUS', p_itemtype, p_itemkey, null, x_Progress);
          rollback;
          raise;

END UPDATE_WORKITEM_STATUS ;

FUNCTION GetWIProvisioningDate(p_workitem_instance_id IN NUMBER)
 RETURN DATE IS

 l_prov_date   DATE ;
 x_progress    VARCHAR2(2000);

BEGIN
     SELECT provisioning_date
       INTO l_prov_date
       FROM xdp_fulfill_worklist
      WHERE workitem_instance_id = p_workitem_instance_id ;

RETURN l_prov_date;


EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_WI.GetWIProvisioningDate. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_WI', 'GetWIProvisioningDate', null, null, null, x_Progress);
          raise;
END GetWIProvisioningDate ;

Function GET_WI_RESPONSIBILITY (itemtype        in varchar2,
                        itemkey         in varchar2 ) return varchar2
IS
l_wi_responsiblilty VARCHAR2(100);
l_WIInstanceID  NUMBER;
l_WorkitemID NUMBER;
x_progress varchar2(2000);
BEGIN

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => GET_WI_RESPONSIBILITY.itemtype,
                                               itemkey  => GET_WI_RESPONSIBILITY.itemkey,
                                               aname    => 'WORKITEM_INSTANCE_ID');
 BEGIN
   SELECT wis.role_name  INTO l_wi_responsiblilty
   FROM  xdp_workitems wis
   WHERE  wis.workitem_id in ( select lst.workitem_id
                             from  xdp_fulfill_worklist lst
                             WHERE  lst.workitem_instance_id = l_WIInstanceID);

 EXCEPTION

   WHEN no_data_found THEN
   l_wi_responsiblilty := NULL;

 END;
   return l_wi_responsiblilty;

 EXCEPTION
   WHEN others THEN
          x_Progress := 'XDPCORE_WI.GET_WI_RESPONSIBILITY. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          xdpcore.context('XDPCORE_WI', 'GET_WI_RESPONSIBILITY', 'WI', l_WIInstanceID, x_Progress);
          wf_core.context('XDPCORE_WI', 'GET_WI_RESPONSIBILITY', 'WI', l_WIInstanceID, null, x_Progress);
          raise;
END GET_WI_RESPONSIBILITY;

Function ResolveIndDepWIs(itemtype in varchar2,
                            itemkey  in varchar2) return varchar2
IS

 l_OrderID number;
 l_LineItemID number;
 l_IndFound number := 0;
 l_DepFound number := 0;

 cursor c_GetIndWIList (OrderID number, LineItemID number) is
   select 'Y'
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE = 0;

 cursor c_GetDepWIList (OrderID number, LineItemID number) is
   select 'Y'
   from XDP_FULFILL_WORKLIST
   where ORDER_ID = Order_ID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE > 0;


 e_NoWorkitemsFoundException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepWIs.itemtype,
                                          itemkey => ResolveIndDepWIs.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepWIs.itemtype,
                                          itemkey => ResolveIndDepWIs.itemkey,
                                          aname => 'LINE_ITEM_ID');


  FOR c_WIRec in c_GetIndWIList(l_OrderID,  l_LineItemID ) LOOP
   l_IndFound := 1;
   EXIT;
  END LOOP;

  FOR c_WIRec in c_GetDepWIList(l_OrderID,  l_LineItemID ) LOOP
   l_DepFound := 1;
   EXIT;
  END LOOP;

  if( l_IndFound = 1 AND l_DepFound = 1 ) THEN
    RETURN 'BOTH';
  elsif( l_IndFound = 1) THEN
    RETURN 'INDEPENDENT';
  elsif( l_DepFound = 1 ) THEN
    RETURN 'DEPENDENT';
  end if;


 EXCEPTION
   WHEN others THEN
          x_Progress := 'XDPCORE_WI. ResolveIndDepWIs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_WI', ' ResolveIndDepWIs', null, null, null, x_Progress);
          raise;

END  ResolveIndDepWIs;

Function get_display_name( p_WIInstanceID IN NUMBER) return varchar2
IS
l_display_name varchar2(100);

BEGIN
 SELECT display_name into l_display_name
 FROM XDP_WORKITEMS_VL wis
 WHERE wis.workitem_id IN ( SELECT lst.workitem_id
                          FROM xdp_fulfill_worklist lst
                        WHERE  workitem_instance_id = p_WIInstanceID );
 return l_display_name;

EXCEPTION
   WHEN others THEN
     wf_core.context('XDPCORE_WI', 'get_display_name', null, null, null,p_WIInstanceID );
     raise;
END get_display_name;

Procedure OverrideParamValue( p_WIInstanceID IN NUMBER,
                              p_parameterName IN VARCHAR2,
                              p_newParamValue IN VARCHAR2,
                              p_evaluate IN VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  -- should we update parameter_ref_value????
  IF( p_evaluate = 'NO' ) THEN
    UPDATE xdp_worklist_details
       SET parameter_value = p_newParamValue,
           is_value_evaluated = 'Y',
           modified_flag = 'Y',
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
     WHERE workitem_instance_id = p_WIInstanceID
       AND parameter_name = p_parameterName;
  ELSE
    UPDATE xdp_worklist_details
       SET parameter_value = p_newParamValue,
           modified_flag = 'Y',
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
     WHERE workitem_instance_id = p_WIInstanceID
       AND parameter_name = p_parameterName;
  END IF;

  -- Commit the autonomous transaction..
  COMMIT;

EXCEPTION
   WHEN others THEN
     -- Rollback the  autonomous transaction..
      rollback;
     wf_core.context('XDPCORE_WI', ' OverrideParamValue', null, null, null,p_WIInstanceID );
     raise;
END OverrideParamValue;

End XDPCORE_WI;

/
