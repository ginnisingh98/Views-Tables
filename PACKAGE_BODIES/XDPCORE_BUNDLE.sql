--------------------------------------------------------
--  DDL for Package Body XDPCORE_BUNDLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_BUNDLE" AS
/* $Header: XDPCORBB.pls 120.1 2005/06/15 22:11:52 appldev  $ */

/****
 All Private Procedures for the Package
****/

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

Procedure InitializeBundle(itemtype in varchar2,
                           itemkey in varchar2);

Function AreAllBundlesDone (itemtype in varchar2,
                            itemkey in varchar2) return varchar2;

Function ResolveIndDepBundles (itemtype in varchar2,
                            itemkey in varchar2) return varchar2;

Procedure LaunchBundleProcesses(itemtype in varchar2,
                               itemkey in varchar2);

Procedure LaunchBundleProcessSeq(itemtype in varchar2,
                               itemkey in varchar2);

Procedure LaunchLineForBundleProcess(itemtype in varchar2,
                                     itemkey in varchar2);

Function LaunchAllIndBundles(itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Procedure InitializeDepBundleProcess(itemtype in varchar2,
                        itemkey in varchar2);


Procedure LaunchBundleProcess(itemtype in varchar2,
                        itemkey in varchar2);


Function ResolveIndDepLinesForBun (itemtype in varchar2,
                                     itemkey in varchar2) return varchar2;

type RowidArrayType is table of rowid index by binary_integer;


/***********************************************
* END of Private Procedures/Function Definitions
************************************************/

--  LAUNCH_BUNDLE_PROCESSES
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_BUNDLE_PROCESSES (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);


BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchBundleProcesses(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
               return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'LAUNCH_BUNDLE_PROCESSES', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_BUNDLE_PROCESSES;


--  LAUNCH_BUNDLE_PROCESS_SEQ
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_BUNDLE_PROCESS_SEQ (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchBundleProcessSeq(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'LAUNCH_BUNDLE_PROCESS_SEQ', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_BUNDLE_PROCESS_SEQ;






--  LAUNCH_LINE_FOR_BUNDLE_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_LINE_FOR_BUNDLE_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchLineForBundleProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'LAUNCH_LINE_FOR_BUNDLE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_LINE_FOR_BUNDLE_PROCESS;



--  ARE_ALL_BUNDLES_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure ARE_ALL_BUNDLES_DONE (itemtype        in varchar2,
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
                l_result := AreAllBundlesDone(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'ARE_ALL_BUNDLES_DONE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ARE_ALL_BUNDLES_DONE;


PROCEDURE UPDATE_BUNDLE_STATUS(p_bundle_id   IN NUMBER,
                               p_order_id    IN NUMBER,
                               p_status_code IN VARCHAR2,
                               p_itemtype    IN VARCHAR2,
                               p_itemkey     IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION ;
 x_Progress                     VARCHAR2(2000);

BEGIN
      UPDATE xdp_order_bundles
         SET status            = p_status_code ,
             last_update_date  = sysdate ,
             last_updated_by   = fnd_global.user_id ,
             last_update_login = fnd_global.login_id
       WHERE order_id          = p_order_id
         AND bundle_id         = p_bundle_id ;
COMMIT;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_BUNDLE.UPDATE_BUNDLE_STATUS. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 2000);
          wf_core.context('XDPCORE_BUNDLE', 'UPDATE_BUNDLE_STATUS', p_itemtype, p_itemkey, null, x_Progress);
          rollback;
          raise;
END UPDATE_BUNDLE_STATUS ;

-- INITIALIZE_BUNDLE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure INITIALIZE_BUNDLE (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                InitializeBundle(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'INITIALIZE_BUNDLE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_BUNDLE;

Procedure RESOLVE_IND_DEP_BUNDLES (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);
 l_result varchar2(30);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_result := ResolveIndDepBundles(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'RESOLVE_IND_DEP_BUNDLES', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESOLVE_IND_DEP_BUNDLES;

Procedure LAUNCH_ALL_IND_BUNDLES (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2) IS

x_Progress                     VARCHAR2(2000);
l_result varchar2(1) := 'N';

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := LaunchAllIndBundles(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'LAUNCH_ALL_IND_BUNDLES', itemtype, itemkey, to_char(actid), funcmode);
 raise;

END LAUNCH_ALL_IND_BUNDLES;


Procedure INITIALIZE_DEP_BUNDLE_PROCESS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2) IS

x_Progress                     VARCHAR2(2000);
l_result varchar2(1);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                InitializeDepBundleProcess(itemtype, itemkey);
                resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'INITIALIZE_DEP_BUNDLE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_DEP_BUNDLE_PROCESS;



Procedure LAUNCH_BUNDLE_PROCESS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2) IS

x_Progress                     VARCHAR2(2000);
l_result varchar2(1);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                LaunchBundleProcess(itemtype, itemkey);
                resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'LAUNCH_BUNDLE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_BUNDLE_PROCESS;


Procedure RESOLVE_IND_DEP_LINES_FOR_BUN (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2) IS

x_Progress                     VARCHAR2(2000);
l_result varchar2(20);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := ResolveIndDepLinesForBun(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_BUNDLE', 'RESOLVE_IND_DEP_LINES_FOR_BUN', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESOLVE_IND_DEP_LINES_FOR_BUN;




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



Function AreAllBundlesDone (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
is
 cursor c_BundleSeq( OrderID number, BundleSeq number) is
  select BUNDLE_ID
   from XDP_ORDER_LINE_ITEMS
   where ORDER_ID = OrderID
    and STATUS_CODE    = 'READY'
    and BUNDLE_SEQUENCE = (select min(BUNDLE_SEQUENCE)
                     from XDP_ORDER_LINE_ITEMS
                     where ORDER_ID = OrderID
                       and STATUS_CODE    = 'READY'
                       and BUNDLE_SEQUENCE > BundleSeq);

 l_OrderID number;
 l_BundleID number;
 l_PrevBundleSeq number;

 e_NoBundlesFoundException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => AreAllBundlesDone.itemtype,
                                          itemkey => AreAllBundlesDone.itemkey,
                                          aname => 'ORDER_ID');

 l_PrevBundleSeq := wf_engine.GetItemAttrNumber(itemtype => AreAllBundlesDone.itemtype,
                                                itemkey => AreAllBundlesDone.itemkey,
                                                aname => 'CURRENT_BUNDLE_SEQUENCE');


 if c_BundleSeq%ISOPEN then
    close c_BundleSeq;
 end if;

 open c_BundleSeq(l_OrderID, l_PrevBundleSeq);

 Fetch c_BundleSeq into l_BundleID;

 if c_BundleSeq%NOTFOUND  then
     /* No more Bundles to be done */
      close c_BundleSeq;
      return ('Y');
 else
   /* There are more Bundles to be done */
      close c_BundleSeq;


      return ('N');

 end if;

 if c_BundleSeq%ISOPEN then
    close c_BundleSeq;
 end if;


exception
when e_NoBundlesFoundException then
 if c_BundleSeq%ISOPEN then
    close c_BundleSeq;
 end if;

 wf_core.context('XDPCORE_BUNDLE', 'AreAllBundlesDone', itemtype, itemkey, null, x_Progress);
 raise;

when others then
 if c_BundleSeq%ISOPEN then
    close c_BundleSeq;
 end if;

 x_Progress := 'XDPCORE_BUNDLE.AreAllBundlesDone. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 2000);
 wf_core.context('XDPCORE_BUNDLE', 'AreAllBundlesDone', itemtype, itemkey, null, x_Progress);
 raise;
end AreAllBundlesDone;




Procedure LaunchBundleProcesses (itemtype in varchar2,
                                 itemkey in varchar2)
is
 l_tempKey varchar2(240);
 l_BundleID number;
 l_OrderID number;
 l_Counter number := 0;
 i number;
 l_CurrentBundleSequence number;

 cursor c_GetIndBundle(OrderID number) is
  select distinct(NVL(BUNDLE_ID, -1))
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE   = 'READY'
    and (BUNDLE_SEQUENCE is null) OR (BUNDLE_SEQUENCE = 0);

 cursor c_GetDepBundle(OrderID number) is
  select BUNDLE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE   = 'READY'
   and BUNDLE_ID IS NOT NULL
   and BUNDLE_SEQUENCE > 0;

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;


 e_InvalidConfigException exception;
 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin

  l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchBundleProcesses.itemtype,
                                           itemkey => LaunchBundleProcesses.itemkey,
                                           aname => 'ORDER_ID');

  open c_GetIndBundle(l_OrderID);

  LOOP
    Fetch c_GetIndBundle into l_BundleID;

    EXIT when c_GetIndBundle%NOTFOUND;

--    dbms_output.put_line('Got Ind bundle id: ' || l_BundleID);

     l_Counter := l_Counter + 1;

     select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
     l_tempKey := to_char(l_OrderID) || '-BUNDLE-IND-' || l_tempKey;

     t_ChildTypes(l_Counter) := 'XDPPROV';
     t_ChildKeys(l_Counter) := l_tempKey;


     wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                             itemkey => t_ChildKeys(l_Counter),
                             process => 'INDEPENDENT_BUNDLE_PROCESS');

     wf_engine.setItemParent(itemtype => t_ChildTypes(l_Counter),
                             itemkey  => t_ChildKeys(l_Counter),
                             parent_itemtype => itemtype,
                             parent_itemkey  => itemkey,
                             parent_context  => 'WAITFORFLOW-BUNDLE-DEP');

     wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 aname => 'ORDER_ID',
                                 avalue => l_OrderID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcesses. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'INDEPENDENT_BUNDLE_FLAG',
                                      AttrValue => 'TRUE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcesses. Error when adding Item Attribute INDEPENDENT_BUNDLE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

  END LOOP;

  close c_GetIndBundle;


  /* Dependent Bundle Sequencing Processing */

     if c_GetDepBundle%ISOPEN then
        close c_GetDepBundle;
     end if;

     open c_GetDepBundle(l_OrderID);
     Fetch c_GetDepBundle into l_BundleID;

    -- dbms_output.put_line('Got Dep bundle id: ' || l_BundleID);

     if c_GetDepBundle%NOTFOUND  and l_Counter = 0 then
        /* Some thing wrong */
        close c_GetDepBundle;
        x_Progress := 'XDPCORE_BUNDLE.LaunchBundleProcesses. No Bundles Detected for OrderID: ' || l_OrderID;
        RAISE e_InvalidConfigException;
     elsif c_GetDepBundle%FOUND then
       l_Counter := l_Counter + 1;

        t_ChildTypes(l_Counter) := 'XDPPROV';

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-BUNDLE-' || to_char(l_BundleID) || '-' || l_tempKey;

        t_ChildKeys(l_Counter) := l_tempKey;

         wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 process => 'DEPENDENT_BUNDLE_PROCESS');

         wf_engine.setItemParent(itemtype => t_ChildTypes(l_Counter),
                                 itemkey  => t_ChildKeys(l_Counter),
                                 parent_itemtype => itemtype,
                                 parent_itemkey  => itemkey,
                                 parent_context  => null);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'ORDER_ID',
                                     avalue => l_OrderID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcesses. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'INDEPENDENT_BUNDLE_FLAG',
                                      AttrValue => 'FALSE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcesses. Error when adding Item Attribute INDEPENDENT_BUNDLE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'CURRENT_BUNDLE_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcesses. Error when adding Item Attribute CURRENT_BUNDLE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       close c_GetDepBundle;
     end if;

    /* Launch all the Child Processes */
    for i in 1..l_Counter loop

      -- dbms_output.put_line('launching Bundles: ' || t_ChildKeys(i));
      wf_engine.StartProcess(itemtype => t_ChildTypes(i),
                             itemkey => t_ChildKeys(i));
    end loop;

exception
when e_AddAttributeException then
  if c_GetDepBundle%ISOPEN then
     close c_GetDepBundle;
  end if;

  if c_GetIndBundle%ISOPEN then
     close c_GetIndBundle;
  end if;

 wf_core.context('XDPCORE_BUNDLE', 'LaunchBundleProcesses', itemtype, itemkey, null, x_Progress);
  raise;

when e_InvalidConfigException then
  if c_GetDepBundle%ISOPEN then
     close c_GetDepBundle;
  end if;

  if c_GetIndBundle%ISOPEN then
     close c_GetIndBundle;
  end if;

 wf_core.context('XDPCORE_BUNDLE', 'LaunchBundleProcesses', itemtype, itemkey, null, x_Progress);
  raise;

when others then
  if c_GetDepBundle%ISOPEN then
     close c_GetDepBundle;
  end if;

  if c_GetIndBundle%ISOPEN then
     close c_GetIndBundle;
  end if;

 x_Progress := 'XDPCORE_BUNDLE.LaunchBundleProcesses. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 2000);
 wf_core.context('XDPCORE_BUNDLE', 'LaunchBundleProcesses', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchBundleProcesses;


Procedure LaunchLineForBundleProcess (itemtype in varchar2,
                                      itemkey in varchar2)
is
 l_OrderID number;
 l_BundleID number;
 l_Counter number := 0;
 l_LineItemID number;

 l_IndBundleFlag varchar2(10);
 l_tempKey varchar2(240);
 l_LineMaster varchar2(40);
 l_PackageFlag varchar(1);

 cursor c_GetIndLinesNullBundle(OrderID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID is null
    and LINE_SEQUENCE = 0;

 cursor c_GetDepLinesNullBundle(OrderID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID is null
    and LINE_SEQUENCE > 0;


 cursor c_GetIndLinesForBundle(OrderID number, BundleID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE = 0;

 cursor c_GetDepLinesForBundle(OrderID number, BundleID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE > 0;


TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

 e_NoLinesFoundException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin
 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineForBundleProcess.itemtype,
                                          itemkey => LaunchLineForBundleProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_BundleID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineForBundleProcess.itemtype,
                                           itemkey => LaunchLineForBundleProcess.itemkey,
                                           aname => 'BUNDLE_ID');

 l_IndBundleFlag := wf_engine.GetItemAttrText(itemtype => LaunchLineForBundleProcess.itemtype,
                                              itemkey => LaunchLineForBundleProcess.itemkey,
                                              aname => 'INDEPENDENT_BUNDLE_FLAG');



 if l_IndBundleFlag = 'TRUE' then
    l_LineMaster := 'WAITFORFLOW-IND_BUNDLE';
 else
    l_LineMaster := 'WAITFORFLOW-DEP_BUNDLE';
 end if;


 if l_BundleID is null or l_BundleID = -1 then
    /* Need to process all the line items as one bundle */

    /*
    ** The Bundle is for all the line items with a bundle id of 0.
    ** The Line items for this also can be sequenced as independent or
    ** Dependent.
    **/

    /* Get all the independent lines */

     open c_GetIndLinesNullBundle(l_OrderID);
     LOOP
       Fetch c_GetIndLinesNullBundle into l_LineItemID, l_PackageFlag;
       EXIT when c_GetIndLinesNullBundle%NOTFOUND;

        l_Counter := l_Counter + 1;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-BUNDLE_LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;


         wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 process => 'LINE_PROCESSING_PROCESS');

         wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 parent_itemtype => LaunchLineForBundleProcess.itemtype,
                                 parent_itemkey => LaunchLineForBundleProcess.itemkey,
                                 parent_context => null);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'ORDER_ID',
                                     avalue => l_OrderID);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'LINE_ITEM_ID',
                                     avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

     END LOOP;
     close c_GetIndLinesNullBundle;

      /* Launch One Dependent Line Item Processing Process */
      open c_GetDepLinesNullBundle(l_OrderID);

      Fetch c_GetDepLinesNullBundle into l_LineItemID, l_PackageFlag;
      if c_GetDepLinesNullBundle%FOUND then
         /**
          ** Add the new line item id to the list if wf's to be started
          ** and Create an instance if the dependent line item process
         **/
         l_Counter := l_Counter + 1;

         select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
         l_tempKey := to_char(l_OrderID) || '-BUNDLE_LINE-' || to_char(l_LineItemID) || l_tempKey;

         t_ChildTypes(l_Counter) := 'XDPPROV';
         t_ChildKeys(l_Counter) := l_tempKey;


          wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  process => 'LINE_SEQ_PROCESSING');

          wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  parent_itemtype => LaunchLineForBundleProcess.itemtype,
                                  parent_itemkey => LaunchLineForBundleProcess.itemkey,
                                  parent_context => null);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'ORDER_ID',
                                      avalue => l_OrderID);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'LINE_ITEM_ID',
                                      avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

       if ErrCode <> 0 then
          x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
          raise e_AddAttributeException;
       end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

      end if;

      close c_GetDepLinesNullBundle;


 elsif l_BundleID > 0 then
    /* Process the lines for a current Bundle ID */
    /*
    ** The Bundle is for all the line items with a non 0 bundle id.
    ** The Line items for this also can be sequenced as independent or
    ** Dependent.
    **/

    /* Get all the independent lines */

     open c_GetIndLinesForBundle(l_OrderID, l_BundleID);
     LOOP
       Fetch c_GetIndLinesForBundle into l_LineItemID, l_PackageFlag;
       EXIT when c_GetIndLinesForBundle%NOTFOUND;

        l_Counter := l_Counter + 1;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-BUNDLE- ' || to_char(l_BundleID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;


         wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 process => 'LINE_PROCESSING_PROCESS');

         wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 parent_itemtype => LaunchLineForBundleProcess.itemtype,
                                 parent_itemkey => LaunchLineForBundleProcess.itemkey,
                                 parent_context => null);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'ORDER_ID',
                                     avalue => l_OrderID);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'LINE_ITEM_ID',
                                     avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;



     END LOOP;
     close c_GetIndLinesForBundle;


      /* Launch One Dependent Line Item Processing Process */
      open c_GetDepLinesForBundle(l_OrderID, l_BundleID);

      Fetch c_GetDepLinesForBundle into l_LineItemID, l_PackageFlag;
      if c_GetDepLinesForBundle%FOUND then
         /**
          ** Add the new line item id to the list if wf's to be started
          ** and Create an instance if the dependent line item process
         **/
         l_Counter := l_Counter + 1;

         select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
         l_tempKey := to_char(l_OrderID) || '-BUNDLE_LINE-' || to_char(l_LineItemID) || l_tempKey;

         t_ChildTypes(l_Counter) := 'XDPPROV';
         t_ChildKeys(l_Counter) := l_tempKey;

          wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  process => 'LINE_SEQ_PROCESSING');

          wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  parent_itemtype => LaunchLineForBundleProcess.itemtype,
                                  parent_itemkey => LaunchLineForBundleProcess.itemkey,
                                  parent_context => null);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'ORDER_ID',
                                      avalue => l_OrderID);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'LINE_ITEM_ID',
                                      avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

       if ErrCode <> 0 then
          x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
          raise e_AddAttributeException;
       end if;


       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLineForBundleProcess. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;



      end if;

      close c_GetDepLinesForBundle;
 else
   /* Some thing Wrong */
   -- RAISE; ??
   null;
 end if;



   if l_Counter = 0 then
      RAISE e_NoLinesFoundException;
   end if;


  /* Now start the workflow process */
   FOR i in 1..l_Counter LOOP

     wf_engine.StartProcess(t_ChildTypes(i),
                            t_ChildKeys(i));

   END LOOP;

exception
when others then
 wf_core.context('XDPCORE_BUNDLE', 'LaunchLineForBundleProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchLineForBundleProcess;




Procedure LaunchBundleProcessSeq (itemtype in varchar2,
                                  itemkey in varchar2)

is
cursor c_BundleSeq( OrderID number, BundleSeq number) is
  select DISTINCT(BUNDLE_ID), BUNDLE_SEQUENCE
   from XDP_ORDER_LINE_ITEMS
   where ORDER_ID = OrderID
    and STATUS_CODE = 'READY'
    and BUNDLE_ID >= 0
    and BUNDLE_SEQUENCE = (select min(BUNDLE_SEQUENCE)
                     from XDP_ORDER_LINE_ITEMS
                     where ORDER_ID = OrderID
                       and STATUS_CODE = 'READY'
                       and BUNDLE_ID >= 0
                       and BUNDLE_SEQUENCE > BundleSeq);

 l_OrderID number;
 l_BundleID number;
 l_LineItemID number;
 l_PrevBundleSeq number;
 l_CurrentBundleSeq number;
 l_Counter number := 0;

 l_PackageFlag varchar2(1);
 l_tempKey varchar2(240);

cursor c_GetIndLinesForBundle(OrderID number, BundleID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE = 0;

 cursor c_GetDepLinesForBundle(OrderID number, BundleID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE > 0;


TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

 e_NoBundlesFoundException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);
begin
 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchBundleProcessSeq.itemtype,
                                          itemkey => LaunchBundleProcessSeq.itemkey,
                                          aname => 'ORDER_ID');

 l_PrevBundleSeq := wf_engine.GetItemAttrNumber(itemtype => LaunchBundleProcessSeq.itemtype,
                                                itemkey => LaunchBundleProcessSeq.itemkey,
                                                aname => 'CURRENT_BUNDLE_SEQUENCE');

 open c_BundleSeq(l_OrderID, l_PrevBundleSeq);
 LOOP

   Fetch c_BundleSeq into l_BundleID, l_CurrentBundleSeq;
   EXIT when c_BundleSeq%NOTFOUND;

   -- dbms_output.put_line('Bundle line item for bundle: ' || l_BundleID);

     open c_GetIndLinesForBundle(l_OrderID, l_BundleID);
     LOOP
       Fetch c_GetIndLinesForBundle into l_LineItemID, l_PackageFlag;
       EXIT when c_GetIndLinesForBundle%NOTFOUND;

       -- dbms_output.put_line('Bundle: ' || l_BundleID || ' Line: ' || l_LineItemID);
        l_Counter := l_Counter + 1;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-BUNDLE- ' || to_char(l_BundleID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;


         wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 process => 'LINE_PROCESSING_PROCESS');

         wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                 itemkey => t_ChildKeys(l_Counter),
                                 parent_itemtype => LaunchBundleProcessSeq.itemtype,
                                 parent_itemkey => LaunchBundleProcessSeq.itemkey,
                                 parent_context => null);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'ORDER_ID',
                                     avalue => l_OrderID);

         wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     aname => 'LINE_ITEM_ID',
                                     avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


     END LOOP;
     close c_GetIndLinesForBundle;


      /* Launch One Dependent Line Item Processing Process */
      open c_GetDepLinesForBundle(l_OrderID, l_BundleID);

      Fetch c_GetDepLinesForBundle into l_LineItemID, l_PackageFlag;
      if c_GetDepLinesForBundle%FOUND then
         /**
          ** Add the new line item id to the list if wf's to be started
          ** and Create an instance if the dependent line item process
         **/
         l_Counter := l_Counter + 1;

         -- dbms_output.put_line('Bundle: ' || l_BundleID || ' Line: ' || l_LineItemID);

         select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
         l_tempKey := to_char(l_OrderID) || '-BUNDLE_LINE-' || to_char(l_LineItemID) || l_tempKey;

         t_ChildTypes(l_Counter) := 'XDPPROV';
         t_ChildKeys(l_Counter) := l_tempKey;

          wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  process => 'LINE_SEQ_PROCESSING');

          wf_engine.SetItemParent(itemtype => t_ChildTypes(l_Counter),
                                  itemkey => t_ChildKeys(l_Counter),
                                  parent_itemtype => LaunchBundleProcessSeq.itemtype,
                                  parent_itemkey => LaunchBundleProcessSeq.itemkey,
                                  parent_context => null);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'ORDER_ID',
                                      avalue => l_OrderID);

          wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      aname => 'LINE_ITEM_ID',
                                      avalue => l_LineItemID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

       if ErrCode <> 0 then
          x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
          raise e_AddAttributeException;
       end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                        itemkey => t_ChildKeys(l_Counter),
                                        AttrName => 'BUNDLE_ID',
                                        AttrValue => l_BundleID,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => 'BUNDLE',
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


      end if;

      close c_GetDepLinesForBundle;

 END LOOP;

  if l_Counter = 0 and l_CurrentBundleSeq = 0 then
     RAISE e_NoBundlesFoundException;
  else

       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchBundleProcessSeq.itemtype,
                                        itemkey => LaunchBundleProcessSeq.itemkey,
                                        AttrName => 'CURRENT_BUNDLE_SEQUENCE',
                                        AttrValue => l_CurrentBundleSeq,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

       if ErrCode <> 0 then
          x_progress := 'In XDPCORE_WI.LaunchBundleProcessSeq. Error when adding Item Attribute CURRENT_BUNDLE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
          raise e_AddAttributeException;
       end if;


     FOR i in 1..l_Counter LOOP
         wf_engine.StartProcess(t_ChildTypes(i),
                                t_ChildKeys(i));
     END LOOP;

  end if;

exception
when others then
 wf_core.context('XDPCORE_BUNDLE', 'LaunchBundleProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchBundleProcessSeq;


Procedure InitializeBundle (itemtype in varchar2,
                            itemkey in varchar2) IS

 l_BundleID number;
 l_OrderID number;

 ErrCode number;
 ErrStr varchar2(1996);

 x_Progress  VARCHAR2(2000);
 e_AddAttributeException EXCEPTION;

begin

 	l_OrderID  := wf_engine.GetItemAttrNumber(itemtype => InitializeBundle.itemtype,
                                           itemkey => InitializeBundle.itemkey,
                                           aname => 'ORDER_ID');

 	l_BundleID  := wf_engine.GetItemAttrNumber(itemtype => InitializeBundle.itemtype,
                                            itemkey => InitializeBundle.itemkey,
                                            aname => 'BUNDLE_ID');

-- 	if l_BundleID > 0 then

           UPDATE_BUNDLE_STATUS(p_bundle_id   => l_BundleID,
                                p_order_id    => l_OrderID,
                                p_status_code => 'IN PROGRESS',
                                p_itemtype    => InitializeBundle.itemtype,
                                p_itemkey     => InitializeBundle.itemkey) ;
-- 	end if;
     XDPCORE.CheckNAddItemAttrText (itemtype => 'XDPPROV',
                                    itemkey => InitializeBundle.itemkey,
                                    AttrName => 'LINE_PROCESSING_CALLER',
                                    AttrValue => 'BUNDLE',
                                    ErrCode => ErrCode,
                                    ErrStr => ErrStr);
      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_BUNDLE.InitializeBundle. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


exception
	when others then
             wf_core.context('XDPCORE_BUNDLE', 'InitializeBundle', itemtype, itemkey, null, x_Progress);
 	     raise;
end InitializeBundle;

Function ResolveIndDepBundles (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
IS

 l_OrderID NUMBER;

 l_IndFound number := 0;
 l_DepFound number := 0;

 cursor c_GetIndBundles(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE   = 'READY'
    and ( (BUNDLE_SEQUENCE is null) OR (BUNDLE_SEQUENCE = 0));

 cursor c_GetDepBundles(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE   = 'READY'
   and BUNDLE_ID IS NOT NULL
   and BUNDLE_SEQUENCE > 0;

BEGIN

  l_OrderID  := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepBundles.itemtype,
                                           itemkey => ResolveIndDepBundles.itemkey,
                                           aname => 'ORDER_ID');


  FOR lv_BundleRec in c_GetIndBundles( l_OrderID ) LOOP
    l_IndFound := 1;
    EXIT;
  END LOOP;

  FOR lv_BundleRec in c_GetDepBundles( l_OrderID ) LOOP
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
	WHEN OTHERS THEN
             wf_core.context('XDPCORE_BUNDLE', 'ResolveIndDepBundles', itemtype, itemkey );
 	     RAISE;
END ResolveIndDepBundles;


Function LaunchAllIndBundles(itemtype in varchar2,
                        itemkey in varchar2) return varchar2
IS
 l_tempKey varchar2(240);
 l_OrderID number;
 l_BundleID number;
 l_Counter number := 0;

 l_result varchar2(1) := 'N';

 cursor c_GetIndBundles(OrderID number) is
  select distinct(NVL(BUNDLE_ID, -1)) BUNDLE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE   = 'READY'
    and ((BUNDLE_SEQUENCE is null) OR (BUNDLE_SEQUENCE = 0));

  TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
  t_ChildKeys t_ChildKeyTable;

 e_InvalidConfigException exception;
 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);


BEGIN

  l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndBundles.itemtype,
                                           itemkey => LaunchAllIndBundles.itemkey,
                                           aname => 'ORDER_ID');



  FOR lv_BundleRec in c_GetIndBundles( l_OrderID ) LOOP
     l_result := 'Y';
     l_Counter := l_Counter + 1;

     l_BundleID := lv_BundleRec.BUNDLE_ID;
     select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
     l_tempKey := to_char(l_OrderID) || '-BUNDLE-' || l_tempKey;

     t_ChildKeys(l_Counter) := l_tempKey;

     wf_engine.CreateProcess(itemtype => 'XDPPROV',
                             itemkey => t_ChildKeys(l_Counter),
                             process => 'BUNDLE_PROCESS');

     wf_engine.setItemParent(itemtype => 'XDPPROV',
                             itemkey  =>  t_ChildKeys(l_Counter),
                             parent_itemtype => itemtype,
                             parent_itemkey  => itemkey,
                             parent_context  => 'WAITFORFLOW-BUNDLE-IND');

     wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                               itemkey =>   t_ChildKeys(l_Counter),
                               aname => 'MASTER_TO_CONTINUE',
                               avalue => 'WAITFORFLOW-BUNDLE-IND');

     wf_engine.SetItemAttrNumber(itemtype => 'XDPPROV',
                                 itemkey => t_ChildKeys(l_Counter),
                                 aname => 'ORDER_ID',
                                 avalue => l_OrderID);

     XDPCORE.CheckNAddItemAttrNumber (itemtype =>'XDPPROV',
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'BUNDLE_ID',
                                      AttrValue => l_BundleID,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_BUNDLE.LaunchAllIndBundles. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;
  END LOOP;

  for i in 1..l_Counter loop

    wf_engine.StartProcess(itemtype => 'XDPPROV', itemkey => t_ChildKeys(i));
  end loop;

  return l_result;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context('XDPCORE_BUNDLE', 'LaunchAllIndBundles', itemtype, itemkey, null, x_progress );
  RAISE;
END LaunchAllIndBundles;

Procedure InitializeDepBundleProcess(itemtype in varchar2,
                        itemkey in varchar2)
IS

 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

BEGIN
  XDPCORE.CheckNAddItemAttrNumber (itemtype => 'XDPPROV',
                                   itemkey => InitializeDepBundleProcess.itemkey,
                                   AttrName => 'CURRENT_BUNDLE_SEQUENCE',
                                   AttrValue => 0,
                                   ErrCode => ErrCode,
                                   ErrStr => ErrStr);

  if ErrCode <> 0 then
     x_progress := 'In XDPCORE_BUNDLE.CheckNAddItemAttrNumber. Error when adding Item Attribute CURRENT_BUNDLE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
     raise e_AddAttributeException;
  end if;


EXCEPTION
  WHEN OTHERS THEN
     wf_core.context('XDPCORE_BUNDLE', 'InitializeDepBundleProcess', itemtype, itemkey, null, x_progress );
  RAISE;
END InitializeDepBundleProcess;

Procedure LaunchBundleProcess(itemtype in varchar2,
                        itemkey in varchar2)
IS

 l_OrderID number;
 l_BundleID number;
 l_LineItemID number;
 l_PrevBundleSeq number;
 l_CurrentBundleSeq number;

 l_PackageFlag varchar2(1);
 l_tempKey varchar2(240);

 cursor c_BundleSeq( OrderID number, BundleSeq number) is
  select DISTINCT(BUNDLE_ID) BUNDLE_ID, BUNDLE_SEQUENCE
   from XDP_ORDER_LINE_ITEMS
   where ORDER_ID = OrderID
    and STATUS_CODE = 'READY'
    and BUNDLE_ID >= 0
    and BUNDLE_SEQUENCE = (select min(BUNDLE_SEQUENCE)
                     from XDP_ORDER_LINE_ITEMS
                     where ORDER_ID = OrderID
                       and STATUS_CODE = 'READY'
                       and BUNDLE_ID >= 0
                       and BUNDLE_SEQUENCE > BundleSeq);


 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);



BEGIN


 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchBundleProcess.itemtype,
                                          itemkey => LaunchBundleProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_PrevBundleSeq := wf_engine.GetItemAttrNumber(itemtype => LaunchBundleProcess.itemtype,
                                                itemkey => LaunchBundleProcess.itemkey,
                                                aname => 'CURRENT_BUNDLE_SEQUENCE');


 FOR lv_BundelRec in c_BundleSeq( l_OrderID, l_PrevBundleSeq ) LOOP
     l_BundleID := lv_BundelRec.BUNDLE_ID;
     l_CurrentBundleSeq := lv_BundelRec.BUNDLE_SEQUENCE;

     select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
         l_tempKey := to_char(l_OrderID) || '-BUNDLE-' || to_char(l_LineItemID) || l_tempKey;

     wf_engine.CreateProcess(itemtype => 'XDPPROV',
                             itemkey => l_tempKey,
                             process => 'BUNDLE_PROCESS');

     wf_engine.setItemParent(itemtype => 'XDPPROV',
                             itemkey  =>  l_tempKey,
                             parent_itemtype => itemtype,
                             parent_itemkey  => itemkey,
                             parent_context  => 'WAITFORFLOW-BUNDLE-DEP');

     wf_engine.SetItemAttrNumber(itemtype => 'XDPPROV',
                                 itemkey => l_tempKey,
                                 aname => 'ORDER_ID',
                                 avalue => l_OrderID);

     wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                               itemkey => l_tempKey,
                               aname => 'MASTER_TO_CONTINUE',
                               avalue => 'WAITFORFLOW-BUNDLE-DEP');

     XDPCORE.CheckNAddItemAttrNumber (itemtype =>'XDPPROV',
                                      itemkey => l_tempKey,
                                      AttrName => 'BUNDLE_ID',
                                      AttrValue => l_BundleID,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_BUNDLE.LaunchBundleProcess. Error when adding Item Attribute BUNDLE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

     XDPCORE.CheckNAddItemAttrText (itemtype => 'XDPPROV',
                                    itemkey => l_tempKey,
                                    AttrName => 'LINE_PROCESSING_CALLER',
                                    AttrValue => 'BUNDLE',
                                    ErrCode => ErrCode,
                                    ErrStr => ErrStr);


      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_BUNDLE.LaunchBundleProcess. Error when adding Item Attribute LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

      --Start the process...
      wf_engine.StartProcess('XDPPROV', l_tempKey );

  END LOOP;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchBundleProcess.itemtype,
                                        itemkey => LaunchBundleProcess.itemkey,
                                        AttrName => 'CURRENT_BUNDLE_SEQUENCE',
                                        AttrValue => l_CurrentBundleSeq,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_BUNDLE.LaunchBundleProcess. Error when adding Item Attribute CURRENT_BUNDLE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context('XDPCORE_BUNDLE', 'LaunchBundleProcess', itemtype, itemkey, null, x_progress );
  RAISE;
END LaunchBundleProcess;

Function ResolveIndDepLinesForBun (itemtype in varchar2,
                                     itemkey in varchar2) return varchar2
is
 l_OrderID number;
 l_BundleID number;

 l_IndFound number := 0;
 l_DepFound number := 0;

 x_Progress                     VARCHAR2(2000);

 cursor c_GetIndLinesNullBundle(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID is null
    and LINE_SEQUENCE = 0;


 cursor c_GetDepLinesNullBundle(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID is null
    and LINE_SEQUENCE > 0;

 cursor c_GetIndLinesForBundle(OrderID number, BundleID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE = 0;


 cursor c_GetDepLinesForBundle(OrderID number, BundleID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and BUNDLE_ID  = BundleID
    and LINE_SEQUENCE > 0;


begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepLinesForBun.itemtype,
                                          itemkey => ResolveIndDepLinesForBun.itemkey,
                                          aname => 'ORDER_ID');

 l_BundleID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepLinesForBun.itemtype,
                                           itemkey => ResolveIndDepLinesForBun.itemkey,
                                           aname => 'BUNDLE_ID');

 if l_BundleID is null or l_BundleID = -1 then

   FOR lv_LineRec in c_GetIndLinesNullBundle( l_OrderID ) LOOP
    l_IndFound := 1;
    EXIT;
   END LOOP;

   FOR lv_LineRec in c_GetDepLinesNullBundle( l_OrderID ) LOOP
    l_DepFound := 1;
    EXIT;
   END LOOP;

 elsif l_BundleID > 0 then

   FOR lv_LineRec in c_GetIndLinesForBundle( l_OrderID, l_BundleID ) LOOP
    l_IndFound := 1;
    EXIT;
   END LOOP;

   FOR lv_LineRec in c_GetDepLinesForBundle( l_OrderID, l_BundleID ) LOOP
    l_DepFound := 1;
    EXIT;
   END LOOP;
 end if;


 if( l_IndFound = 1 AND l_DepFound = 1 ) THEN
   RETURN 'BOTH';
 elsif( l_IndFound = 1) THEN
   RETURN 'INDEPENDENT';
 elsif( l_DepFound = 1 ) THEN
   RETURN 'DEPENDENT';
 end if;


exception

when others then

 x_Progress := 'XDPCORE_BUNDLE.ResolveIndDepLinesForBun. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_BUNDLE', 'ResolveIndDepLinesForBun', itemtype, itemkey, null, x_Progress);
  raise;
end ResolveIndDepLinesForBun;

End XDPCORE_BUNDLE;

/
