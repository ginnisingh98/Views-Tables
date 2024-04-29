--------------------------------------------------------
--  DDL for Package Body XDPCORE_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_ERROR" AS
/* $Header: XDPCORRB.pls 120.2 2006/04/10 23:23:04 dputhiye noship $ */


/****
 All Private Procedures for the Package
****/

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

Function FeErrorProcessOptions(itemtype in varchar2,
                          itemkey in varchar2,
                          actid in number) return varchar2;

Procedure PrepareErrorMessage(itemtype in varchar2,
                              itemkey in varchar2,
                               actid in number);


Procedure NotifyOutsideSystemOfError(itemtype in varchar2,
                                     itemkey in varchar2,
                                     actid in number);

Procedure FeErrorNotif (itemtype in varchar2,
                       itemkey in varchar2,
                       actid in number,
                       funcmode in varchar2,
                       result out NOCOPY varchar2);

Function GetNotifRecepient return varchar2;

Function GetResubmissionJobID (itemtype in varchar2,
                               itemkey in varchar2) return number;

Procedure SetErrorContext (itemtype in varchar2,
                       itemkey in varchar2);

type RowidArrayType is table of rowid index by binary_integer;



/***********************************************
* END of Private Procedures/Function Definitions
************************************************/


--  FE_ERR_NTF
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure FE_ERR_NTF (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
--      <your procedure here>
                FeErrorNotif (itemtype, itemkey, actid, funcmode, resultout);
                return;
        ELSE
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_ERROR', 'FE_ERR_NTF', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END FE_ERR_NTF;


--  FE_ERROR_PROCESS_OPTIONS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure FE_ERROR_PROCESS_OPTIONS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2 ) IS

l_result varchar2(40);

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := FeErrorProcessOptions(itemtype, itemkey, actid);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_ERROR', 'FE_ERROR_PROCESS_OPTIONS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END FE_ERROR_PROCESS_OPTIONS;


--  PREPARE_ERROR_MESSAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure PREPARE_ERROR_MESSAGE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                PrepareErrorMessage(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_ERROR', 'PREPARE_ERROR_MESSAGE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END PREPARE_ERROR_MESSAGE;


--  NOTIFY_OUTSIDE_SYSTEM_OF_ERROR
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure NOTIFY_OUTSIDE_SYSTEM_OF_ERROR (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                NotifyOutsideSystemOfError(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_ERROR', 'NOTIFY_OUTSIDE_SYSTEM_OF_ERROR', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END NOTIFY_OUTSIDE_SYSTEM_OF_ERROR;

Procedure SET_ERROR_CONTEXT (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetErrorContext(itemtype, itemkey);
		resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_ERROR', 'SET_ERROR_CONTEXT', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_ERROR_CONTEXT;

Procedure LOG_SESSION_ERROR( p_errory_type in varchar2)
IS

l_object_type   VARCHAR2(2000);
l_object_key     VARCHAR2(32000);
l_error_name      VARCHAR2(30);
l_error_message   VARCHAR2(2000);
l_error_stack     VARCHAR2(32000);

BEGIN

  XDP_ERRORS_PKG.set_message( XDPCORE.object_type, XDPCORE.object_key, XDPCORE.error_name, XDPCORE.error_message, p_errory_type );

EXCEPTION
  WHEN others THEN
   raise;
END LOG_SESSION_ERROR;

/****
 All the Private Functions
****/

Function GetResubmissionJobID (itemtype in varchar2,
                               itemkey in varchar2) return number is
 l_JobID number;
 e_UnhandledException exception;
begin
 begin
   l_JobID := wf_engine.GetItemAttrNumber(itemtype => GetResubmissionJobID.itemtype,
                                          itemkey => GetResubmissionJobID.itemkey,
                                          aname => 'RESUBMISSION_JOB_ID');

 exception
 when others then
  if sqlcode = -20002 then
      l_JobID := 0;
      wf_core.clear;
  else
    raise e_UnhandledException;
  end if;
 end;

 return l_JobID;

End GetResubmissionJobID;

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




Function FeErrorProcessOptions (itemtype in varchar2,
                                itemkey in varchar2,
                                actid in number) return varchar2

is
 l_ProcessOption varchar2(40);

 x_Progress                     VARCHAR2(2000);

begin

 l_ProcessOption :=  wf_engine.GetActivityAttrText( itemtype => FeErrorProcessOptions.itemtype,
                                                    itemkey => FeErrorProcessOptions.itemkey,
                                                    actid => FeErrorProcessOptions.actid,
                                                    aname => 'FE_ERROR_PROCESS_OPTION');

 return (l_ProcessOption);

exception
when others then
   x_Progress := 'XDPCORE_ERROR.FeErrorProcessOptions. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
   wf_core.context('XDPCORE_ERROR', 'FeErrorProcessOptions', itemtype, itemkey, to_char(actid), x_Progress);
   raise;
end FeErrorProcessOptions;



Procedure PrepareErrorMessage (itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number)
is

 x_Progress                     VARCHAR2(2000);
 l_ResubmissionJOBID number;

 l_NtfSubject varchar2(1000);
 l_ErrorDesc varchar2(4000);
 l_ErrorType varchar2(20);

 l_NtfDesc varchar2(4000);	--Size of this var (4000) is utilized to fix bug 4112678. dputhiye. 21-Feb-2005
				--Any change in this value should be rippled to this fix in this procedure.

 l_FAInstanceID number;

 l_OrderID number;
 l_OrderNumber varchar2(40);
 l_OrderVersion varchar2(40);
 l_FAName varchar2(80);
 l_FEName varchar2(80);
 l_WIName varchar2(80);
 l_LineName varchar2(40);
 l_WIResponsiblity varchar2(200);
 l_status VARCHAR2(1);
 lv_fp_name VARCHAR2(80);
 lv_fp_disp_name VARCHAR2(80);
 ErrCode number;
 ErrStr varchar2(2000);

 e_AddAttrException exception;

  CURSOR cur_error_count(cv_fp_name  varchar2) IS
  SELECT error_count
    FROM xdp_error_count
   WHERE object_key = cv_fp_name
     AND object_type = XDP_UTILITIES.g_fp_object_type;

begin
null;

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => PrepareErrorMessage.itemtype,
                                               itemkey => PrepareErrorMessage.itemkey,
                                               aname => 'FA_INSTANCE_ID');


 l_ErrorDesc := wf_engine.GetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                          itemkey => PrepareErrorMessage.itemkey,
                                          aname => 'FE_ERROR_DESCRIPTION');

-- Place Holder until FND Bug 2064891 is resolved.

	 --l_ErrorDesc := replace(l_ErrorDesc, chr(0), '');
	 l_ErrorDesc := replace(l_ErrorDesc, fnd_global.local_chr(0), '');

 Begin
     l_ErrorType := wf_engine.GetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                              itemkey => PrepareErrorMessage.itemkey,
                                              aname => 'FE_ERROR_TYPE');

         -- reset fe error type to none
         wf_engine.SetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                   itemkey => PrepareErrorMessage.itemkey,
                                   aname => 'FE_ERROR_TYPE',
                                   avalue => 'NONE');

     exception
       when others then
         l_ErrorType := 'NOT_DEFINED';
       -- this attribute does not exist in the flow as the error occured is an
       -- unhandled exception..
 end;

 /* Get all the Order Config Information to be displayed for the notification */

 select xoo.order_id, xoo.External_Order_number, NVL(xoo.external_order_version, 'N/A'), xoo.fa_display_name, xoo.wi_display_name, xoo.line_item_name, xfe.display_name
 into l_OrderID, l_OrderNumber, l_OrderVersion, l_FAName, l_WIName, l_LineName, l_FeName
 from XDP_ORU_ORDERS_V xoo, XDP_FES_VL xfe
 where fa_instance_id = l_FAInstanceID
   and xoo.FE_ID = xfe.fe_id;

 l_ResubmissionJobID := GetResubmissionJobID(itemtype => PrepareErrorMessage.itemtype,
                                              itemkey => PrepareErrorMessage.itemkey);

 if l_ResubmissionJobID <> 0 then
         FND_MESSAGE.SET_NAME('XDP','XDP_FMC_RESUB_NTF_SUBJECT');
         FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_OrderNumber);
         FND_MESSAGE.SET_TOKEN('ORD_VER', l_OrderVersion);
         FND_MESSAGE.SET_TOKEN('JOBID', to_char(l_ResubmissionJobID));
         l_NtfSubject := FND_MESSAGE.GET;
 elsif (l_ErrorType = 'NOTIFY_ERROR') then
        -- user sent error using NOTIFY_ERROR Macro..
          FND_MESSAGE.SET_NAME('XDP','XDP_NTF_SBJCT_NTF_ERR');
          FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_OrderNumber);
          FND_MESSAGE.SET_TOKEN('ORD_VER', l_OrderVersion);
          FND_MESSAGE.SET_TOKEN('FA_DISP_NAME', l_FAName);
          FND_MESSAGE.SET_TOKEN('NOTIFY_ERROR', substr(l_ErrorDesc,1,100));
          l_NtfSubject := FND_MESSAGE.GET;
 elsif (l_ErrorType = 'SESSION_LOST') then
        -- user sent error using NOTIFY_ERROR Macro..
          FND_MESSAGE.SET_NAME('XDP','XDP_ORDER_SESSION_LOST');
          FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_OrderNumber);
          FND_MESSAGE.SET_TOKEN('ORD_VER', l_OrderVersion);
          FND_MESSAGE.SET_TOKEN('FE_NAME', l_FeName);
          l_NtfSubject := FND_MESSAGE.GET;
 else
        --unhandled exception..
          lv_fp_name := wf_engine.GetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                                  itemkey => PrepareErrorMessage.itemkey,
                                                  aname => XDPCORE_FA.g_fp_name );

          l_status := WF_ENGINE.GetActivityattrtext(itemtype =>PrepareErrorMessage.itemtype,
                                                    itemkey  =>PrepareErrorMessage.itemkey,
                                                    actid    =>PrepareErrorMessage.actid,
                                                    aname    =>'FP_RETRY');
          IF ( l_status = 'N' ) THEN
            FND_MESSAGE.SET_NAME('XDP','XDP_FP_ERR_THRSHD_EXCDED');
            SELECT display_name INTO lv_fp_disp_name
            FROM xdp_proc_body_vl
            WHERE proc_name =  lv_fp_name;
            FND_MESSAGE.SET_TOKEN('FP_NAME', lv_fp_disp_name);
          ELSE
            FND_MESSAGE.SET_NAME('XDP','XDP_FMC_NTF_SUBJECT');
            FND_MESSAGE.SET_TOKEN('FA_DISP_NAME', l_FAName);
          END IF;

          FND_MESSAGE.SET_TOKEN('ORDER_NUM', l_OrderNumber);
          FND_MESSAGE.SET_TOKEN('ORD_VER', l_OrderVersion);
          l_NtfSubject := FND_MESSAGE.GET;
 end if;
         wf_engine.SetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                   itemkey => PrepareErrorMessage.itemkey,
                                   aname => 'NTF_SUBJECT',
                                   avalue => l_NtfSubject);



         FND_MESSAGE.SET_NAME('XDP','XDP_FMC_NTF_ORD_DESC');
         FND_MESSAGE.SET_TOKEN('ORDER_ID', to_char(l_OrderID));
         FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', l_OrderNumber);
         FND_MESSAGE.SET_TOKEN('ORDER_VERSION', l_OrderVersion);
         FND_MESSAGE.SET_TOKEN('FA', l_FAName);
         FND_MESSAGE.SET_TOKEN('FE_NAME', l_FEName);
         FND_MESSAGE.SET_TOKEN('WI', l_WIName);
         FND_MESSAGE.SET_TOKEN('LINE_NAME', l_LineName);

         FND_MESSAGE.SET_TOKEN('ERROR_DATE', to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
         FND_MESSAGE.SET_TOKEN('ERROR_DESCRIPTION', substr(l_ErrorDesc,1,1000));

	l_NtfDesc := FND_MESSAGE.GET;
        --l_NtfDesc := l_NtfDesc || chr(10) || XDPCORE.error_stack;

	--Date: 21-Feb-2005 Author:dputhiye  Bug#:4112678 (Bug 3998762 on 11.5.9)
        --l_NtfDesc := l_NtfDesc || fnd_global.local_chr(10) || XDPCORE.error_stack;
	--The source line commented above has been replaced with the line below.
	--error_stack lengths during runtime can get to 32,000+ and must be truncated here to fit in l_NtfDesc.
	--Length of the variable l_NtfDesc is 4000, and any change in the declaration must be reflected here.
        l_NtfDesc := l_NtfDesc || fnd_global.local_chr(10) || substr(XDPCORE.error_stack, 1, 3999 - length(l_NtfDesc));
	--End of fix for 4112678

        -- clear the stack..
        XDPCORE.error_stack := NULL;

         wf_engine.SetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                   itemkey => PrepareErrorMessage.itemkey,
                                   aname => 'NTF_BODY',
                                   avalue => substr(l_NtfDesc,1,1999));

         /* future functionality
         l_WIResponsiblity := XDPCORE_WI.get_wi_responsibility( PrepareErrorMessage.itemtype,
                                                                PrepareErrorMessage.itemkey );

         wf_engine.SetItemAttrText(itemtype => PrepareErrorMessage.itemtype,
                                   itemkey => PrepareErrorMessage.itemkey,
                                   aname => 'ERROR_RECEPIENT',
                                   avalue => l_WIResponsiblity);
         */

exception
when e_AddAttrException then
 x_progress := 'XDPCORE.ERROR.PrepareErrorMessage. Error when adding attribute dynamically. Error: ' ||
SUBSTR(ErrStr,1,1500);
   wf_core.context('XDPCORE_ERROR', 'PrepareErrorMessage', itemtype, itemkey, null, x_Progress);
   raise;

when others then
   x_Progress := 'XDPCORE_ERROR.PrepareErrorMessage. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
   wf_core.context('XDPCORE_ERROR', 'PrepareErrorMessage', itemtype, itemkey, null, x_Progress);
   raise;
end PrepareErrorMessage;



Function GetNotifRecepient return varchar2 is

  l_NotifReceipent varchar2(100);
begin

-- Hard Code this for now!!!
  l_NotifReceipent := 'FND_RESP535:21704';

 return l_NotifReceipent;

end GetNotifRecepient;


Procedure NotifyOutsideSystemOfError (itemtype in varchar2,
                                      itemkey in varchar2,
                                     actid in number)
is
 x_Progress                     VARCHAR2(2000);

begin

 -- Not yet supported
	null;

exception
when others then
   x_Progress := 'XDPCORE_ERROR.NotifyOutsideSystemOfError. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
   wf_core.context('XDPCORE_ERROR', 'NotifyOutsideSystemOfError', itemtype, itemkey, to_char(actid), x_Progress);
   raise;
end NotifyOutsideSystemOfError;


Procedure FeErrorNotif (itemtype in varchar2,
                       itemkey in varchar2,
                       actid in number,
                       funcmode in varchar2,
                       result out NOCOPY varchar2)

is

 x_Progress                     VARCHAR2(2000);

begin

 -- Not yet supported
	null;

exception
when others then
   x_Progress := 'XDPCORE_ERROR.FeErrorNotif. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
wf_core.context('XDPCORE_ERROR', 'FeErrorNotif', itemtype, itemkey, null, x_Progress);
  raise;
end FeErrorNotif;

Procedure SetErrorContext (itemtype in varchar2,
                       itemkey in varchar2)

is
 l_object_type   VARCHAR2(2000);
 l_object_key     VARCHAR2(32000);
 l_error_name      VARCHAR2(30);
 l_error_message   VARCHAR2(2000);
 l_error_stack     VARCHAR2(32000);
 l_order_number  VARCHAR2(40);
 l_order_version  VARCHAR2(40);


 l_OrderID NUMBER;
 l_LineID NUMBER;
 l_WIInstaceID NUMBER;
 l_FAInstanceID NUMBER;
 l_NtfSubject VARCHAR2(2000);
 l_NtfBody VARCHAR2(2000);
 l_WIResponsiblity VARCHAR2(100);
 l_LineName varchar2(100);
 l_wi_disp_name varchar2(100);
 l_fa_disp_name varchar2(100);
 x_Progress                     VARCHAR2(2000);
 l_NtfURL VARCHAR2(1000);
 l_click_here VARCHAR2(300);
 l_text       VARCHAR2(300);

begin
   l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SetErrorContext.itemtype,
                                          itemkey => SetErrorContext.itemkey,
                                          aname => 'ORDER_ID');
    SELECT external_order_number, external_order_version
      INTO l_order_number, l_order_version
    FROM XDP_ORDER_HEADERS WHERE order_id = l_OrderID;


    l_LineID := wf_engine.GetItemAttrNumber(itemtype => SetErrorContext.itemtype,
                                            itemkey => SetErrorContext.itemkey,
                                            aname => 'LINE_ITEM_ID');

    SELECT line_item_name INTO l_LineName FROM xdp_order_line_items WHERE line_item_id = l_LineID;

    FND_MESSAGE.SET_NAME('XDP','XDP_ORDER_DETAILS');
    FND_MESSAGE.SET_TOKEN('ORD_NUM', l_order_number);
    FND_MESSAGE.SET_TOKEN('ORD_VER', l_order_version);
    FND_MESSAGE.SET_TOKEN('ORD_ID', l_OrderID);
    FND_MESSAGE.SET_TOKEN('LINE_NAME', l_LineName);
    l_NtfBody := l_NtfBody || FND_MESSAGE.GET;

    begin
      l_WIInstaceID := wf_engine.GetItemAttrNumber(itemtype => SetErrorContext.itemtype,
                                          itemkey => SetErrorContext.itemkey,
                                          aname => 'WORKITEM_INSTANCE_ID');

      l_wi_disp_name := XDPCORE_WI.get_display_name( l_WIInstaceID );

      FND_MESSAGE.SET_NAME('XDP','XDP_WI_DISP_NAME');
      FND_MESSAGE.SET_TOKEN('WI', l_wi_disp_name);
      --l_NtfBody := l_NtfBody || FND_MESSAGE.GET ||CHR(10);
      l_NtfBody := l_NtfBody || FND_MESSAGE.GET || fnd_global.local_CHR(10);


      XDP_NOTIFICATIONS.Get_WI_Update_URL(l_WIInstaceID,
                                          l_OrderID,
                                          itemtype,
                                          itemKey,
                                          l_NtfURL);

      --09/26/2002 HBCHUNG
      --setting Notification URL
      wf_engine.SetItemAttrText(itemtype => SetErrorContext.itemtype,
                                itemkey => SetErrorContext.itemkey,
                                aname => 'NTF_URL',
                                avalue => l_NtfURL );

   exception
     when others then
     --not at WI level do nothing..
     null;
   end;

   begin
   l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetErrorContext.itemtype,
                                          itemkey => SetErrorContext.itemkey,
                                          aname => 'FA_INSTANCE_ID');

      l_fa_disp_name := XDPCORE_FA.get_display_name( l_FAInstanceID );

      FND_MESSAGE.SET_NAME('XDP','XDP_FA_DISP_NAME');
      FND_MESSAGE.SET_TOKEN('FA', l_fa_disp_name);
      --l_NtfBody := l_NtfBody || FND_MESSAGE.GET ||CHR(10);
      l_NtfBody := l_NtfBody || FND_MESSAGE.GET || fnd_global.local_CHR(10);
   exception
     when others then
     --not at FA level do nothing..
     null;
  end;

  -- set error date..
  FND_MESSAGE.SET_NAME('XDP', 'XDP_ERROR_DATE');
  FND_MESSAGE.SET_TOKEN('ERROR_DATE', to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
  --l_NtfBody := l_NtfBody || FND_MESSAGE.GET ||CHR(10);
  l_NtfBody := l_NtfBody || FND_MESSAGE.GET || fnd_global.local_CHR(10);

  l_NtfSubject := l_order_number||' ( '||l_order_version||' ):';
  -- get error set in the context..
  XDPCORE.get_error(l_object_type, l_object_key,
	    l_error_name, l_error_message, l_error_stack);

  -- get the translated message....
  l_NtfSubject := l_NtfSubject || XDP_ERRORS_PKG.get_message( l_error_name, l_error_message );

  -- set the Notification Subject...
  wf_engine.SetItemAttrText(itemtype => SetErrorContext.itemtype,
                            itemkey => SetErrorContext.itemkey,
                            aname => 'NTF_SUBJECT',
                            avalue => l_NtfSubject);

  l_NtfBody := l_NtfBody || substr( l_error_stack, 1, 1999 );

  wf_engine.SetItemAttrText(itemtype => SetErrorContext.itemtype,
                            itemkey => SetErrorContext.itemkey,
                            aname => 'NTF_BODY',
                            avalue => l_NtfBody );

  /*
  -- In future we may want to send the notifications to the data entry folks registered while
  -- creating the workitems...
  l_WIResponsiblity := XDPCORE_WI.get_wi_responsibility( SetErrorContext.itemtype,
                                   SetErrorContext.itemkey );

  IF l_WIResponsiblity is not null THEN
    wf_engine.SetItemAttrText(itemtype => SetErrorContext.itemtype,
                              itemkey => SetErrorContext.itemkey,
                              aname => 'ERROR_RECEPIENT',
                              avalue => l_WIResponsiblity);
  END IF;
  */


exception
when others then
   x_Progress := 'XDPCORE_ERROR.SetErrorContext. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
wf_core.context('XDPCORE_ERROR', 'SetErrorContext', itemtype, itemkey, null, x_Progress);
  raise;
end SetErrorContext;


End XDPCORE_ERROR;

/
