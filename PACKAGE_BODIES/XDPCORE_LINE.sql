--------------------------------------------------------
--  DDL for Package Body XDPCORE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_LINE" AS
/* $Header: XDPCORLB.pls 120.1 2005/06/08 23:47:15 appldev  $ */


/****
 All Private Procedures for the Package
****/

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

Procedure InitializeLine(itemtype in varchar2,
                         itemkey in varchar2);

Function AreAllLinesDone (itemtype in varchar2,
                          itemkey in varchar2) return varchar2;

Procedure LaunchLineForOrderProcess(itemtype in varchar2,
                                    itemkey in varchar2);

Procedure LaunchLineItemProcess(itemtype in varchar2,
                                itemkey in varchar2);

Procedure LaunchLineItemProcessForBundle(itemtype in varchar2,
                                itemkey in varchar2);

Procedure LaunchLineItemProcessForOrder(itemtype in varchar2,
                                itemkey in varchar2);

Procedure LaunchServiceProcess(itemtype in varchar2,
                               itemkey in varchar2);

Function AreAllLinesDoneForBundleCaller(itemtype in varchar2,
                                        itemkey in varchar2) return varchar2;

Function AreAllLinesDoneForOrderCaller(itemtype in varchar2,
                                       itemkey in varchar2) return varchar2;

Function IsLineaPackage(itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Function LaunchAllIndLines(itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Function LaunchAllIndLinesForOrder (itemtype in varchar2,
                            itemkey in varchar2) return varchar2;

Function LaunchAllIndLinesForBundle (itemtype in varchar2,
                            itemkey in varchar2) return varchar2;

Procedure AddLineAttributes(itemtype in varchar2,
			    itemkey in varchar2,
			    Module in varchar2,
			    IsPackageFlag in varchar2,
                            ibsource      in varchar2,
                            ibsourceid in  number,
			    LineProcessCaller in varchar2,
			    CurrentLineSequence in number,
			    errcode OUT NOCOPY number,
			    errstr OUT NOCOPY varchar2);

Procedure UpdateInstallBase(itemtype in varchar2,
                            itemkey  in varchar2
                            );

Procedure InitializeDepLineProcess(itemtype in varchar2,
                            itemkey  in varchar2 );

Function ResolveIndDepLines (itemtype in varchar2,
                             itemkey in varchar2) return varchar2;

Function IsSerPartPackage (itemtype in varchar2,
                           itemkey in varchar2) return varchar2;

PROCEDURE UPDATDE_ORDER_LINE(p_line_item_id IN NUMBER ,
                             p_status_code  IN VARCHAR2,
                             p_itemtype     IN VARCHAR2,
                             p_itemkey      IN VARCHAR2) ;



PROCEDURE PublishXDPLineDone(itemtype  IN VARCHAR2,
                             itemkey   IN VARCHAR2,
                             actid     IN NUMBER,
                             resultout IN VARCHAR2);


type RowidArrayType is table of rowid index by binary_integer;



/***********************************************
* END of Private Procedures/Function Definitions
************************************************/


--  LAUNCH_LINEITEM_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_LINEITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchLineItemProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
               return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'LAUNCH_LINEITEM_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_LINEITEM_PROCESS;




--  INITIALIZE_LINE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure INITIALIZE_LINE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               InitializeLine(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'INITIALIZE_LINE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_LINE;




--  IS_LINE_A_PACKAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure IS_LINE_A_PACKAGE (itemtype        in varchar2,
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
               l_result := IsLineaPackage(itemtype, itemkey);
               resultout := 'COMPLETE:' || l_result;
               return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'IS_LINE_A_PACKAGE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_LINE_A_PACKAGE;



--  LAUNCH_LINE_FOR_ORDER_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_LINE_FOR_ORDER_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchLineForOrderProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'LAUNCH_LINE_FOR_ORDER_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_LINE_FOR_ORDER_PROCESS;




--  LAUNCH_SERVICE_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_SERVICE_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchServiceProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'LAUNCH_SERVICE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_SERVICE_PROCESS;





--  ARE_ALL_LINES_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure ARE_ALL_LINES_DONE (itemtype        in varchar2,
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
                l_result := AreAllLinesDone(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'ARE_ALL_LINES_DONE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ARE_ALL_LINES_DONE;



Procedure UPDATE_INSTALL_BASE (itemtype        in varchar2,
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
                UpdateInstallBase(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'UPDATE_INSTALL_BASE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END UPDATE_INSTALL_BASE;

Procedure LAUNCH_ALL_IND_LINES (itemtype        in varchar2,
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
                l_result := LaunchAllIndLines(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'LAUNCH_ALL_IND_LINES', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_ALL_IND_LINES;

Procedure INITIALIZE_DEP_LINE_PROCESS (itemtype        in varchar2,
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
                InitializeDepLineProcess(itemtype, itemkey);
                resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'INITIALIZE_DEP_LINE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_DEP_LINE_PROCESS;

Procedure RESOLVE_IND_DEP_LINES (itemtype        in varchar2,
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
                l_result := ResolveIndDepLines(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'RESOLVE_IND_DEP_LINES', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESOLVE_IND_DEP_LINES;

Procedure IS_SER_PART_PACKAGE (itemtype        in varchar2,
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
                l_result := IsSerPartPackage(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_LINE', 'IS_SER_PART_PACKAGE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_SER_PART_PACKAGE;



-- ****************  PUBLISH_XDP_LINE_DONE       *********************

PROCEDURE PUBLISH_XDP_LINE_DONE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);

BEGIN

        IF (funcmode = 'RUN') THEN
               PublishXDPLineDone(itemtype, itemkey,actid,l_resultout);
               resultout := l_resultout ;
               return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_LINE', 'LINE_FULFILLMENT_DONE', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END PUBLISH_XDP_LINE_DONE ;



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



Function AreAllLinesDone (itemtype in varchar2,
                          itemkey in varchar2) return varchar2
is

 l_LineCaller varchar2(40);
 l_result varchar2(10);

 x_Progress                     VARCHAR2(2000);

begin

 l_LineCaller := wf_engine.GetItemAttrText(itemtype => AreAllLinesDone.itemtype,
                                            itemkey => AreAllLinesDone.itemkey,
                                            aname => 'LINE_PROCESSING_CALLER');

 if l_LineCaller = 'BUNDLE' then
    l_result := AreAllLinesDoneForBundleCaller(itemtype => AreAllLinesDone.itemtype,
                                               itemkey => AreAllLinesDone.itemkey);
 else
    l_result := AreAllLinesDoneForOrderCaller(itemtype => AreAllLinesDone.itemtype,
                                              itemkey => AreAllLinesDone.itemkey);

 end if;

 return l_result;

exception
when others then
 x_Progress := 'XDPCORE_LINE.AreAllLinesDone. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'AreAllLinesDone', itemtype, itemkey, null, x_Progress);
  raise;
end AreAllLinesDone;



Function AreAllLinesDoneForBundleCaller (itemtype in varchar2,
                                         itemkey in varchar2) return varchar2
is

 l_OrderID number;
 l_BundleID number;
 l_LineItemID number;
 l_CurrentLineSeq number;

 l_LineNumber number;
 l_PackageFlag varchar2(1);
 l_ib_source varchar2(20);
 l_ib_source_id number;

 l_LineName varchar2(40);

 e_InvalidConfigException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => AreAllLinesDoneForBundleCaller.itemtype,
                                          itemkey => AreAllLinesDoneForBundleCaller.itemkey,
                                          aname => 'ORDER_ID');

 l_BundleID := wf_engine.GetItemAttrNumber(itemtype => AreAllLinesDoneForBundleCaller.itemtype,
                                           itemkey => AreAllLinesDoneForBundleCaller.itemkey,
                                           aname => 'BUNDLE_ID');

 l_CurrentLineSeq := wf_engine.GetItemAttrNumber(itemtype => AreAllLinesDoneForBundleCaller.itemtype,
                                                 itemkey => AreAllLinesDoneForBundleCaller.itemkey,
                                                 aname => 'CURRENT_LINE_SEQUENCE');


 /* If the Caller is a bundle and the bundle ID is null then process all the line items for
  ** that order with a bundleid of null
  **/

  if l_BundleID is null or l_BundleID = -1 then
      if c_LineSeqNullBundle%ISOPEN then
         close c_LineSeqNullBundle;
      end if;

      open c_LineSeqNullBundle(l_OrderID, l_CurrentLineSeq);
	Fetch c_LineSeqNullBundle
         into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag, l_CurrentLineSeq , l_ib_source , l_ib_source_id ;

        if c_LineSeqNullBundle%NOTFOUND  then
            /* No more Lines's for the current bundle to be done */
             close c_LineSeqNullBundle;
             return ('Y');
        else
          /* There are more lines for the current bundle to be done */
             close c_LineSeqNullBundle;
             return ('N');

        end if;

        if c_LineSeqNullBundle%ISOPEN then
           close c_LineSeqNullBundle;
        end if;

  else
      /* The Bundle caller is for a specific bundle id */
      if c_LineSeqForBundle%ISOPEN then
         close c_LineSeqForBundle;
      end if;

      open c_LineSeqForBundle(l_OrderID, l_BundleID, l_CurrentLineSeq);
--      Fetch c_LineSeqForBundle into l_LineItemID, l_CurrentLineSeq;
      Fetch c_LineSeqForBundle
       into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag, l_CurrentLineSeq , l_ib_source , l_ib_source_id ;

        if c_LineSeqForBundle%NOTFOUND  then
            /* No more Lines's for the current bundle to be done */
             close c_LineSeqForBundle;
             return ('Y');
        else
          /* There are more lines for the current bundle to be done */
             close c_LineSeqForBundle;
             return ('N');
        end if;

        if c_LineSeqForBundle%ISOPEN then
           close c_LineSeqForBundle;
        end if;

  end if;

exception
when e_InvalidConfigException then
  if c_LineSeqNullBundle%ISOPEN then
     close c_LineSeqNullBundle;
  end if;

  if c_LineSeqForBundle%ISOPEN then
     close c_LineSeqForBundle;
  end if;

 wf_core.context('XDPCORE_LINE', 'AreAllLinesDoneForBundleCaller', itemtype, itemkey, null, x_Progress);
 raise;
when others then
  if c_LineSeqNullBundle%ISOPEN then
     close c_LineSeqNullBundle;
  end if;

  if c_LineSeqForBundle%ISOPEN then
     close c_LineSeqForBundle;
  end if;

 x_Progress := 'XDPCORE_LINE.AreAllLinesDoneForBundleCaller. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'AreAllLinesDoneForBundleCaller', itemtype, itemkey, null, x_Progress);
  raise;
end AreAllLinesDoneForBundleCaller;



Function AreAllLinesDoneForOrderCaller (itemtype in varchar2,
                                        itemkey in varchar2) return varchar2
is

 l_CurrentLineSeq number;
 l_OrderID number;
 l_LineSeq number;
 l_LineItemID number;

 l_CurrentDBSeq number;
 l_LineNumber number;
 l_PackageFlag varchar2(1);
 l_ib_source varchar2(30);
 l_ib_source_id number;
 l_LineName varchar2(40);

 e_NoLinesFoundException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => AreAllLinesDoneForOrderCaller.itemtype,
                                          itemkey => AreAllLinesDoneForOrderCaller.itemkey,
                                          aname => 'ORDER_ID');

 l_CurrentLineSeq := wf_engine.GetItemAttrNumber(itemtype => AreAllLinesDoneForOrderCaller.itemtype,
                                                 itemkey => AreAllLinesDoneForOrderCaller.itemkey,
                                                 aname => 'CURRENT_LINE_SEQUENCE');

 if c_LineSeq%ISOPEN then
    close c_LineSeq;
 end if;



 open c_LineSeq(l_OrderID, l_CurrentLineSeq);
   Fetch c_LineSeq
    into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag, l_CurrentDBSeq,l_ib_source,l_ib_source_id;

   if c_LineSeq%NOTFOUND  then
       /* No more Lines's for the current bundle to be done */
        close c_LineSeq;
        return ('Y');
   else
     /* There are more lines for the current bundle to be done */
        close c_LineSeq;
        return ('N');
   end if;

   if c_LineSeq%ISOPEN then
      close c_LineSeq;
   end if;

exception
when e_NoLinesFoundException then
   if c_LineSeq%ISOPEN then
      close c_LineSeq;
   end if;

 wf_core.context('XDPCORE_LINE', 'AreAllLinesDoneForOrderCaller', itemtype, itemkey, null, x_Progress);
  raise;

when others then
   if c_LineSeq%ISOPEN then
      close c_LineSeq;
   end if;

 x_Progress := 'XDPCORE_LINE.AreAllLinesDoneForOrderCaller. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'AreAllLinesDoneForOrderCaller', itemtype, itemkey, null, x_Progress);
  raise;
end AreAllLinesDoneForOrderCaller;



Procedure LaunchLineItemProcess (itemtype in varchar2,
                                 itemkey in varchar2)
is
 l_LineCaller varchar2(40);
 x_Progress                     VARCHAR2(2000);

begin

 l_LineCaller := wf_engine.GetItemAttrText(itemtype => LaunchLineItemProcess.itemtype,
                                            itemkey => LaunchLineItemProcess.itemkey,
                                            aname => 'LINE_PROCESSING_CALLER');

 if l_LineCaller = 'BUNDLE' then
    LaunchLineItemProcessForBundle(itemtype => LaunchLineItemProcess.itemtype,
                                   itemkey => LaunchLineItemProcess.itemkey);
 else
    LaunchLineItemProcessForOrder(itemtype => LaunchLineItemProcess.itemtype,
                                  itemkey => LaunchLineItemProcess.itemkey);

 end if;


exception
when others then
 x_Progress := 'XDPCORE_LINE.LaunchLineItemProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchLineItemProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchLineItemProcess;



Procedure LaunchLineItemProcessForBundle (itemtype in varchar2,
                                          itemkey in varchar2)
is
 l_BundleID number;
 l_OrderID number;
 l_CurrentLineSeq number;
 l_PrevLineSeq number;
 l_LineItemID number;
 l_Counter number := 0;
 l_LineNumber number;
 l_PackageFlag varchar2(1);
 l_ib_source  varchar2(20);
 l_ib_source_id number ;

 l_tempKey varchar2(240);
 l_LineName varchar2(40);

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

TYPE t_IDTable is table of number INDEX BY BINARY_INTEGER;
t_WiIDList t_IDTable;
t_PriorityList t_IDTable;

 e_InvalidConfigException exception;
 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineItemProcessForBundle.itemtype,
                                          itemkey => LaunchLineItemProcessForBundle.itemkey,
                                          aname => 'ORDER_ID');

 l_BundleID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineItemProcessForBundle.itemtype,
                                           itemkey => LaunchLineItemProcessForBundle.itemkey,
                                           aname => 'BUNDLE_ID');

 l_PrevLineSeq := wf_engine.GetItemAttrNumber(itemtype => LaunchLineItemProcessForBundle.itemtype,
                                              itemkey => LaunchLineItemProcessForBundle.itemkey,
                                              aname => 'CURRENT_LINE_SEQUENCE');


 if c_LineSeqNullBundle%ISOPEN then
    close c_LineSeqNullBundle;
 end if;


 if l_BundleID is null or l_BundleID = -1 then
    Open c_LineSeqNullBundle(l_OrderID, l_PrevLineSeq);

    LOOP
      Fetch c_LineSeqNullBundle
       into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag, l_CurrentLineSeq, l_ib_source,l_ib_source_id;

       EXIT when c_LineSeqNullBundle%NOTFOUND;

       l_Counter := l_Counter + 1;

       select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
       l_tempkey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

       t_ChildTypes(l_Counter) := 'XDPPROV';
       t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	XDPCORE.CreateNAddAttrNParentLabel
			(itemtype => t_ChildTypes(l_Counter),
			 itemkey => t_ChildKeys(l_Counter),
			 processname => 'LINE_PROCESSING_PROCESS',
			 parentitemtype => LaunchLineItemProcessForBundle.itemtype,
			 parentitemkey => LaunchLineItemProcessForBundle.itemkey,
                         waitflowlabel => 'WAITFORFLOW-LINE-DEP',
			 OrderID => l_OrderID,
			 LineitemID => l_LineItemID,
			 WIInstanceID => null,
			 FAInstanceID => null);

        wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                  itemkey => l_tempKey,
                                  aname => 'MASTER_TO_CONTINUE',
                                  avalue => 'WAITFORFLOW-LINE-DEP');

	AddLineAttributes(itemtype => t_ChildTypes(l_Counter),
			  itemkey => t_ChildKeys(l_Counter),
			  Module => 'XDPCORE_WI.LaunchLinetItemProcessForBundle',
			  IsPackageFlag => l_PackageFlag,
                          ibsource   => l_ib_source,
                          ibsourceid => l_ib_source_id,
			  LineProcessCaller => 'ORDER',
			  CurrentLineSequence => null,
			  errcode => ErrCode,
			  errstr => ErrStr);

      if ErrCode <> 0 then
         x_progress := ErrStr;
         raise e_AddAttributeException;
      end if;


     END LOOP;

     close c_LineSeqNullBundle;

     if l_Counter = 0 and l_CurrentLineSeq = 0 then
        x_Progress := 'XDPCORE_LINE.LaunchLineItemProcessForBundle. Could not find any Lines for Independet Bundle for OrderID: ' || l_OrderID;
        RAISE e_InvalidConfigException;
     else

       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchLineItemProcessForBundle.itemtype,
                                        itemkey => LaunchLineItemProcessForBundle.itemkey,
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => l_CurrentLineSeq,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForBundle. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

         /* Launch the Line Item Fulfillment Process */
           FOR i in 1..l_Counter LOOP
             wf_engine.StartProcess(t_ChildTypes(i),
                                    t_ChildKeys(i));

           END LOOP;

     end if;

 else

    if c_LineSeqForBundle%ISOPEN then
       close c_LineSeqForBundle;
    end if;

    Open c_LineSeqForBundle(l_OrderID, l_BundleID, l_PrevLineSeq);

    LOOP
      Fetch c_LineSeqForBundle
       into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag, l_CurrentLineSeq, l_ib_source , l_ib_source_id ;

       EXIT when c_LineSeqForBundle%NOTFOUND;

       l_Counter := l_Counter + 1;

       select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
       l_tempkey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

       t_ChildTypes(l_Counter) := 'XDPPROV';
       t_ChildKeys(l_Counter) := l_tempKey;


-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateNAddAttrNParentLabel(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'LINE_PROCESSING_PROCESS',
			      parentitemtype => LaunchLineItemProcessForBundle.itemtype,
			      parentitemkey => LaunchLineItemProcessForBundle.itemkey,
                              waitflowlabel => 'WAITFORFLOW-LINE-DEP',
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => null,
			      FAInstanceID => null);

        wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                  itemkey => l_tempKey,
                                  aname => 'MASTER_TO_CONTINUE',
                                  avalue => 'WAITFORFLOW-LINE-DEP');

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForBundle. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IB_SOURCE',
                                      AttrValue => l_ib_source,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForBundle. Error when adding Item Attribute IB_SOURCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IB_SOURCE_ID',
                                      AttrValue => l_ib_source_id,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForBundle. Error when adding Item Attribute IB_SOURCE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;
     END LOOP;

     close c_LineSeqForBundle;

     if l_Counter = 0 and l_CurrentLineSeq = 0 then
        x_Progress := 'XDPCORE_LINE.LaunchLineItemProcessForBundle. Could not find any Lines for BundleID: ' || l_BundleID || ' OrderID: ' || l_OrderID;
        RAISE e_InvalidConfigException;
     else

       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchLineItemProcessForBundle.itemtype,
                                        itemkey => LaunchLineItemProcessForBundle.itemkey,
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => l_CurrentLineSeq,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForBundle. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

         /* Launch the Line Item Fulfillment Process */
           FOR i in 1..l_Counter LOOP
             wf_engine.StartProcess(t_ChildTypes(i),
                                    t_ChildKeys(i));
           END LOOP;

     end if;
 end if;

exception
when e_AddAttributeException then
 if c_LineSeqNullBundle%ISOPEN then
    close c_LineSeqNullBundle;
 end if;

 if c_LineSeqForBundle%ISOPEN then
    close c_LineSeqForBundle;
 end if;

 wf_core.context('XDPCORE_WI', 'LaunchLineItemProcessForBundle', itemtype, itemkey, null, x_Progress);
 raise;

when e_InvalidConfigException then
 if c_LineSeqNullBundle%ISOPEN then
    close c_LineSeqNullBundle;
 end if;

 if c_LineSeqForBundle%ISOPEN then
    close c_LineSeqForBundle;
 end if;

 wf_core.context('XDPCORE_LINE', 'LaunchLineItemProcessForBundle', itemtype, itemkey, null, x_Progress);
  raise;

when others then
 if c_LineSeqNullBundle%ISOPEN then
    close c_LineSeqNullBundle;
 end if;

 if c_LineSeqForBundle%ISOPEN then
    close c_LineSeqForBundle;
 end if;

 x_Progress := 'XDPCORE_LINE.LaunchLineItemProcessForBundle. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchLineItemProcessForBundle', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchLineItemProcessForBundle;



Procedure LaunchLineItemProcessForOrder (itemtype in varchar2,
                                         itemkey in varchar2)
is
 l_OrderID number;
 l_CurrentLineSeq number;
 l_PrevLineSeq number;
 l_LineItemID number;
 l_Counter number := 0;
 l_LineNumber number;
 l_PackageFlag varchar2(1);
 l_ib_source varchar2(20);
 l_ib_source_id number;

 l_tempKey varchar2(240);
 l_LineName varchar2(40);

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

TYPE t_IDTable is table of number INDEX BY BINARY_INTEGER;
t_WiIDList t_IDTable;
t_PriorityList t_IDTable;

 e_InvalidConfigException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);
 ErrCode number;
 ErrStr varchar2(1996);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineItemProcessForOrder.itemtype,
                                          itemkey => LaunchLineItemProcessForOrder.itemkey,
                                          aname => 'ORDER_ID');

 l_PrevLineSeq := wf_engine.GetItemAttrNumber(itemtype => LaunchLineItemProcessForOrder.itemtype,
                                              itemkey => LaunchLineItemProcessForOrder.itemkey,
                                              aname => 'CURRENT_LINE_SEQUENCE');


 if c_LineSeq%ISOPEN then
    close c_LineSeq;
 end if;

 Open c_LineSeq(l_OrderID, l_PrevLineSeq);

 LOOP
   Fetch c_LineSeq into l_LineItemID, l_LineNumber,l_LineName, l_PackageFlag,
         l_CurrentLineSeq,l_ib_source,l_ib_source_id;

    EXIT when c_LineSeq%NOTFOUND;

    l_Counter := l_Counter + 1;

    select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
    l_tempkey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

    t_ChildTypes(l_Counter) := 'XDPPROV';
    t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateNAddAttrNParentLabel(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'LINE_PROCESSING_PROCESS',
			      parentitemtype => LaunchLineItemProcessForOrder.itemtype,
			      parentitemkey => LaunchLineItemProcessForOrder.itemkey,
                              waitflowlabel => 'WAITFORFLOW-LINE-DEP',
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => null,
			      FAInstanceID => null);


        wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                  itemkey => l_tempKey,
                                  aname => 'MASTER_TO_CONTINUE',
                                  avalue => 'WAITFORFLOW-LINE-DEP');

       -- Adding IS_PACKAGE_FLAG to the itemattrlist

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => l_PackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForOrder. Error when adding Item Attribute IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       -- Adding IB_SOURCE to the itemattrlist

       XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                      itemkey => t_ChildKeys(l_Counter),
                                      AttrName => 'IB_SOURCE',
                                      AttrValue => l_ib_source,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForOrder. Error when adding Item Attribute IB_SOURCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

       -- Adding IB_SOURCE_ID to the itemattrlist

       XDPCORE.CheckNAddItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                     itemkey => t_ChildKeys(l_Counter),
                                     AttrName => 'IB_SOURCE_ID',
                                     AttrValue => l_ib_source_id,
                                     ErrCode => ErrCode,
                                     ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForOrder. Error when adding Item Attribute IB_SOURCE_ID. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;

  END LOOP;

   close c_LineSeq;

 if l_Counter = 0 and l_CurrentLineSeq = 0 then
        x_Progress := 'XDPCORE_LINE.LaunchLineItemProcessForOrder. Could not find any Lines for OrderID: ' || l_OrderID || ' Current Line Seqeuence: ' || l_PrevLineSeq;
        RAISE e_InvalidConfigException;
 else
       XDPCORE.CheckNAddItemAttrNumber (itemtype => LaunchLineItemProcessForOrder.itemtype,
                                        itemkey => LaunchLineItemProcessForOrder.itemkey,
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => l_CurrentLineSeq,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_WI.LaunchLinetItemProcessForOrder. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


   /* Launch the Line Item Fulfillment Process */
   FOR i in 1..l_Counter LOOP
     wf_engine.StartProcess(t_ChildTypes(i),
                            t_ChildKeys(i));

   END LOOP;

 end if;


exception
when e_AddAttributeException then
 if c_LineSeq%ISOPEN then
    close c_LineSeq;
 end if;

 wf_core.context('XDPCORE_WI', 'LaunchLineItemProcessForOrder', itemtype, itemkey, null, x_Progress);
 raise;

when e_InvalidConfigException then
 if c_LineSeq%ISOPEN then
    close c_LineSeq;
 end if;

 wf_core.context('XDPCORE_LINE', 'LaunchLineItemProcessForOrder', itemtype, itemkey, null, x_Progress);
 raise;

when others then
 if c_LineSeq%ISOPEN then
    close c_LineSeq;
 end if;

 x_Progress := 'XDPCORE_LINE.LaunchLineItemProcessForOrder. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchLineItemProcessForOrder', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchLineItemProcessForOrder;



Procedure LaunchLineForOrderProcess (itemtype in varchar2,
                                     itemkey in varchar2)
is
 l_OrderID number;
 l_Counter number := 0;
 l_LineItemID number;
 l_Priority number;

 l_IsPackageFlag varchar2(10);
 l_tempKey varchar2(240);
 l_LineMaster varchar2(40);
 l_ib_source varchar2(20) ;
 l_ib_source_id number ;

 e_NoLinesFoundException exception;
 e_AddAttributeException exception;

 cursor c_GetIndLines(OrderID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG, PRIORITY ,IB_SOURCE, NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE = 0;

 cursor c_GetDepLines(OrderID number) is
  select LINE_ITEM_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE > 0;


TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin

 l_Counter := 0;

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchLineForOrderProcess.itemtype,
                                          itemkey => LaunchLineForOrderProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_LineMaster := 'WAITFORFLOW-ORDER_LINE';


 if c_GetIndLines%ISOPEN then
    close c_GetIndLines;
 end if;

    /* Get all the independent lines */

     open c_GetIndLines(l_OrderID);
     LOOP
       Fetch c_GetIndLines into l_LineItemID, l_IsPackageFlag, l_Priority,l_ib_source,l_ib_source_id;
       EXIT when c_GetIndLines%NOTFOUND;

        l_Counter := l_Counter + 1;
        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'LINE_PROCESSING_PROCESS',
			      parentitemtype => LaunchLineForOrderProcess.itemtype,
			      parentitemkey => LaunchLineForOrderProcess.itemkey,
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => null,
			      FAInstanceID => null);

	AddLineAttributes(itemtype => t_ChildTypes(l_Counter),
			  itemkey => t_ChildKeys(l_Counter),
			  Module => 'XDPCORE_WI.LaunchLinetItemForOrderProcess',
			  IsPackageFlag => l_IsPackageFlag,
                          ibsource   => l_ib_source,
                          ibsourceid => l_ib_source_id,
			  LineProcessCaller => 'ORDER',
			  CurrentLineSequence => null,
			  errcode => ErrCode,
			  errstr => ErrStr);


      if ErrCode <> 0 then
         x_progress := ErrStr;
         raise e_AddAttributeException;
      end if;

    END LOOP;
     close c_GetIndLines;

      if c_GetDepLines%ISOPEN then
         close c_GetDepLines;
      end if;

      /* Launch One Dependent Line Item Processing Process */
      open c_GetDepLines(l_OrderID);

      Fetch c_GetDepLines into l_LineItemID;
      if c_GetDepLines%FOUND then
         /**
          ** Add the new line item id to the list if wf's to be started
          ** and Create an instance if the dependent line item process
         **/
         l_Counter := l_Counter + 1;

         select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
         l_tempKey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

         t_ChildTypes(l_Counter) := 'XDPPROV';
         t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
				   itemkey => t_ChildKeys(l_Counter),
				   processname => 'LINE_SEQ_PROCESSING',
			      	   parentitemtype => LaunchLineForOrderProcess.itemtype,
			           parentitemkey => LaunchLineForOrderProcess.itemkey,
			           OrderID => l_OrderID,
			           LineitemID => l_LineItemID,
			           WIInstanceID => null,
			           FAInstanceID => null);

	AddLineAttributes(itemtype => t_ChildTypes(l_Counter),
			  itemkey => t_ChildKeys(l_Counter),
			  Module => 'XDPCORE_WI.LaunchLinetItemForOrderProcess',
			  IsPackageFlag => null,
                          ibsource   => null,
                          ibsourceid => null,
			  LineProcessCaller => 'ORDER',
			  CurrentLineSequence => 0,
			  errcode => ErrCode,
			  errstr => ErrStr);

		if ErrCode <> 0 then
			x_progress := ErrStr;
			raise e_AddAttributeException;
		end if;

	end if;


      close c_GetDepLines;

       if l_Counter = 0 then
          x_Progress := 'XDPCORE_LINE.LaunchLineForOrderProcess. Found No lines to be processed for OrderID: ' || l_OrderID;
          RAISE e_NoLinesFoundException;
       end if;


  /* Now start the workflow process */
   FOR i in 1..l_Counter LOOP

     wf_engine.StartProcess(t_ChildTypes(i),
                            t_ChildKeys(i));
   END LOOP;

exception
when e_AddAttributeException then
 if c_GetIndLines%ISOPEN then
    close c_GetIndLines;
 end if;

 if c_GetDepLines%ISOPEN then
    close c_GetDepLines;
 end if;

 wf_core.context('XDPCORE_LINE', 'LaunchLineForOrderProcess', itemtype, itemkey, null, x_Progress);
  raise;

when e_NoLinesFoundException then
 if c_GetIndLines%ISOPEN then
    close c_GetIndLines;
 end if;

 if c_GetDepLines%ISOPEN then
    close c_GetDepLines;
 end if;

 wf_core.context('XDPCORE_LINE', 'LaunchLineForOrderProcess', itemtype, itemkey, null, x_Progress);
  raise;

when others then
 if c_GetIndLines%ISOPEN then
    close c_GetIndLines;
 end if;

 if c_GetDepLines%ISOPEN then
    close c_GetDepLines;
 end if;

 x_Progress := 'XDPCORE_LINE.LaunchLineForOrderProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchLineForOrderProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchLineForOrderProcess;

Function LaunchAllIndLines (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
is
 l_LineCaller varchar2(40);
 x_Progress                     VARCHAR2(2000);
 l_result varchar2(1) := 'N';

begin

 l_LineCaller := wf_engine.GetItemAttrText(itemtype =>LaunchAllIndLines.itemtype,
                                            itemkey =>LaunchAllIndLines.itemkey,
                                            aname => 'LINE_PROCESSING_CALLER');

 if l_LineCaller = 'BUNDLE' then
    l_result := LaunchAllIndLinesForBundle(itemtype =>LaunchAllIndLines.itemtype,
                                   itemkey => LaunchAllIndLines.itemkey);
 else
    l_result := LaunchAllIndLinesForOrder(itemtype =>LaunchAllIndLines.itemtype,
                                  itemkey =>LaunchAllIndLines.itemkey);

 end if;

 return l_result;

end LaunchAllIndLines;

Function LaunchAllIndLinesForOrder (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
is
 l_OrderID number;
 l_Counter number := 0;
 l_LineItemID number;
 l_Priority number;
 l_tempKey varchar2(240);
 l_IsPackageFlag varchar2(10);
 l_ib_source varchar2(20) ;
 l_ib_source_id number ;


 l_result varchar2(1) := 'N';

 e_NoLinesFoundException exception;
 e_AddAttributeException exception;

 cursor c_GetIndLines( OrderID number ) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG, PRIORITY ,IB_SOURCE, NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE = 0;

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin


 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndLinesForOrder.itemtype,
                                          itemkey => LaunchAllIndLinesForOrder.itemkey,
                                          aname => 'ORDER_ID');



    /* Get all the independent lines */
    FOR lv_LineRec in c_GetIndLines( l_OrderID ) LOOP
        l_result := 'Y';
        l_Counter := l_Counter + 1;
        l_LineItemID := lv_LineRec.LINE_ITEM_ID;
        l_IsPackageFlag := lv_LineRec.IS_PACKAGE_FLAG;
        l_Priority := lv_LineRec.PRIORITY;
        l_ib_source := lv_LineRec.IB_SOURCE;
        l_ib_source_id := lv_LineRec.IB_SOURCE_ID;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildKeys(l_Counter) := l_tempKey;

				-- Create Process and Bulk Set Item Attribute
	XDPCORE.CreateNAddAttrNParentLabel(itemtype => 'XDPPROV',
		      itemkey => t_ChildKeys(l_Counter),
		      processname => 'LINE_PROCESSING_PROCESS',
		      parentitemtype => LaunchAllIndLinesForOrder.itemtype,
		      parentitemkey => LaunchAllIndLinesForOrder.itemkey,
		      waitflowlabel => 'WAITFORFLOW-LINE-IND',
		      OrderID => l_OrderID,
		      LineitemID => l_LineItemID,
		      WIInstanceID => null,
		      FAInstanceID => null);

         wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                   itemkey =>   t_ChildKeys(l_Counter),
                                   aname => 'MASTER_TO_CONTINUE',
                                   avalue => 'WAITFORFLOW-LINE-IND');


	 AddLineAttributes(itemtype => 'XDPPROV',
			itemkey => t_ChildKeys(l_Counter),
			Module => 'XDPCORE_WI.LaunchLinetItemForOrderProcess',
			IsPackageFlag => l_IsPackageFlag,
			ibsource   => l_ib_source,
			ibsourceid => l_ib_source_id,
			LineProcessCaller => 'ORDER',
			CurrentLineSequence => null,
			errcode => ErrCode,
			errstr => ErrStr);


      if ErrCode <> 0 then
         x_progress := ErrStr;
         raise e_AddAttributeException;
      end if;

    END LOOP;

  /* Now start the workflow process */

   FOR i in 1..l_Counter LOOP
     wf_engine.StartProcess( 'XDPPROV', t_ChildKeys(i));
   END LOOP;

   return l_result;

exception
when e_AddAttributeException then

 xdpcore.context('XDPCORE_LINE', 'LaunchAllIndLinesForOrder', itemtype, itemkey, null, x_Progress);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForOrder', itemtype, itemkey, null, x_Progress);
  raise;

when e_NoLinesFoundException then

 xdpcore.context('XDPCORE_LINE', 'LaunchAllIndLinesForOrder', itemtype, itemkey, null, x_Progress);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForOrder', itemtype, itemkey, null, x_Progress);
  raise;

when others then

 x_Progress := 'XDPCORE_LINE.LaunchAllIndLinesForOrder. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForOrder', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchAllIndLinesForOrder;


Function LaunchAllIndLinesForBundle (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
is
 l_BundleID number;
 l_OrderID number;
 l_Counter number := 0;
 l_LineItemID number;
 l_Priority number;
 l_tempKey varchar2(240);
 l_IsPackageFlag varchar2(10);
 l_ib_source varchar2(20) ;
 l_ib_source_id number ;

 l_result varchar2(1):= 'N';

 e_NoLinesFoundException exception;
 e_AddAttributeException exception;

 cursor c_GetIndLines(OrderID number, BundleID number) is
  select LINE_ITEM_ID, IS_PACKAGE_FLAG, PRIORITY ,IB_SOURCE, NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE = 0
    and BUNDLE_ID = BundleID;

 cursor c_GetIndLinesNullBundle(OrderID number) is
  select  LINE_ITEM_ID, IS_PACKAGE_FLAG, PRIORITY ,IB_SOURCE, NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE = 0
    and ((BUNDLE_ID is null) or (BUNDLE_ID = 0 ) );

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);

begin


 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndLinesForBundle.itemtype,
                                          itemkey => LaunchAllIndLinesForBundle.itemkey,
                                          aname => 'ORDER_ID');

 l_BundleID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndLinesForBundle.itemtype,
                                          itemkey => LaunchAllIndLinesForBundle.itemkey,
                                          aname => 'BUNDLE_ID');


    /* Get all the independent lines */

 if l_BundleID is null or l_BundleID = -1 or l_BundleID = 0 then

    FOR lv_LineRec in c_GetIndLinesNullBundle( l_OrderID ) LOOP
        l_result := 'Y';
        l_Counter := l_Counter + 1;
        l_LineItemID := lv_LineRec.LINE_ITEM_ID;
        l_IsPackageFlag := lv_LineRec.IS_PACKAGE_FLAG;
        l_Priority := lv_LineRec.PRIORITY;
        l_ib_source := lv_LineRec.IB_SOURCE;
        l_ib_source_id := lv_LineRec.IB_SOURCE_ID;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildKeys(l_Counter) := l_tempKey;

				-- Create Process and Bulk Set Item Attribute
	XDPCORE.CreateNAddAttrNParentLabel(itemtype => 'XDPPROV',
		      itemkey => t_ChildKeys(l_Counter),
		      processname => 'LINE_PROCESSING_PROCESS',
		      parentitemtype => LaunchAllIndLinesForBundle.itemtype,
		      parentitemkey => LaunchAllIndLinesForBundle.itemkey,
		      waitflowlabel => 'WAITFORFLOW-LINE-IND',
		      OrderID => l_OrderID,
		      LineitemID => l_LineItemID,
		      WIInstanceID => null,
		      FAInstanceID => null);

         wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                   itemkey =>   t_ChildKeys(l_Counter),
                                   aname => 'MASTER_TO_CONTINUE',
                                   avalue => 'WAITFORFLOW-LINE-IND');

	 AddLineAttributes(itemtype => 'XDPPROV',
			itemkey => t_ChildKeys(l_Counter),
			Module => 'XDPCORE_LINE.LaunchAllIndLinesForBundle',
			IsPackageFlag => l_IsPackageFlag,
			ibsource   => l_ib_source,
			ibsourceid => l_ib_source_id,
			LineProcessCaller => 'BUNDLE',
			CurrentLineSequence => null,
			errcode => ErrCode,
			errstr => ErrStr);


      if ErrCode <> 0 then
         x_progress := ErrStr;
         raise e_AddAttributeException;
      end if;
    END LOOP;

 elsif  l_BundleID > 0 then

    FOR lv_LineRec in c_GetIndLines( l_OrderID, l_BundleID ) LOOP
        l_result := 'Y';
        l_Counter := l_Counter + 1;
        l_LineItemID := lv_LineRec.LINE_ITEM_ID;
        l_IsPackageFlag := lv_LineRec.IS_PACKAGE_FLAG;
        l_Priority := lv_LineRec.PRIORITY;
        l_ib_source := lv_LineRec.IB_SOURCE;
        l_ib_source_id := lv_LineRec.IB_SOURCE_ID;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-LINE-' || to_char(l_LineItemID) || l_tempKey;

        t_ChildKeys(l_Counter) := l_tempKey;

				-- Create Process and Bulk Set Item Attribute
	XDPCORE.CreateNAddAttrNParentLabel(itemtype => 'XDPPROV',
		      itemkey => t_ChildKeys(l_Counter),
		      processname => 'LINE_PROCESSING_PROCESS',
		      parentitemtype => LaunchAllIndLinesForBundle.itemtype,
		      parentitemkey => LaunchAllIndLinesForBundle.itemkey,
		      waitflowlabel => 'WAITFORFLOW-LINE-IND',
		      OrderID => l_OrderID,
		      LineitemID => l_LineItemID,
		      WIInstanceID => null,
		      FAInstanceID => null);

         wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                   itemkey =>   t_ChildKeys(l_Counter),
                                   aname => 'MASTER_TO_CONTINUE',
                                   avalue => 'WAITFORFLOW-LINE-IND');


	 AddLineAttributes(itemtype => 'XDPPROV',
			itemkey => t_ChildKeys(l_Counter),
			Module => 'XDPCORE_LINE.LaunchAllIndLinesForBundle',
			IsPackageFlag => l_IsPackageFlag,
			ibsource   => l_ib_source,
			ibsourceid => l_ib_source_id,
			LineProcessCaller => 'BUNDLE',
			CurrentLineSequence => null,
			errcode => ErrCode,
			errstr => ErrStr);


      if ErrCode <> 0 then
         x_progress := ErrStr;
         raise e_AddAttributeException;
      end if;

    END LOOP;

  end if;
  /* Now start the workflow process */

   FOR i in 1..l_Counter LOOP
     wf_engine.StartProcess( 'XDPPROV', t_ChildKeys(i));
   END LOOP;

   return L_result;

exception
when e_AddAttributeException then

 xdpcore.context('XDPCORE_LINE', 'LaunchAllIndLinesForBundle', itemtype, itemkey, null, x_Progress);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForBundle', itemtype, itemkey, null, x_Progress);
  raise;

when e_NoLinesFoundException then

 xdpcore.context('XDPCORE_LINE', 'LaunchAllIndLinesForBundle', itemtype, itemkey, null, x_Progress);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForBundle', itemtype, itemkey, null, x_Progress);
  raise;

when others then

 x_Progress := 'XDPCORE_LINE.LaunchAllIndLinesForBundle. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchAllIndLinesForBundle', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchAllIndLinesForBundle;



Function IsLineaPackage (itemtype in varchar2,
                         itemkey in varchar2) return varchar2
is
 l_PackageFlag  varchar2(5);
 x_Progress     VARCHAR2(2000);
 l_ib_source_id number;
 l_ib_source    varchar2(20) ;
 l_resultout    varchar2(5) ;

begin

 l_PackageFlag := wf_engine.GetItemAttrText(itemtype => IsLineaPackage.itemtype,
                                            itemkey  => IsLineaPackage.itemkey,
                                            aname    => 'IS_PACKAGE_FLAG');

 l_ib_source := wf_engine.GetItemAttrText(itemtype => IsLineaPackage.itemtype,
                                          itemkey  => IsLineaPackage.itemkey,
                                          aname    => 'IB_SOURCE');

 l_ib_source_id := wf_engine.GetItemAttrNumber(itemtype => IsLineaPackage.itemtype,
                                              itemkey  => IsLineaPackage.itemkey,
                                              aname    => 'IB_SOURCE_ID');

 IF ((l_PackageFlag = 'Y') OR
     (l_ib_source IN('CSI','TXN') AND l_ib_source_id = -999 )
    ) THEN
    l_resultout := 'Y' ;
 ELSIF ((l_PackageFlag = 'N' AND l_ib_source ='NONE') OR
        (l_ib_source IN('CSI','TXN') AND l_ib_source_id <> -999  )
       ) THEN
    l_resultout  := 'N' ;
 END IF;

 return l_resultout;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_LINE.IsLineaPackage. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_LINE', 'IsLineaPackage', itemtype, itemkey, null, x_Progress);
          raise;
end IsLineaPackage;



Procedure LaunchServiceProcess (itemtype in varchar2,
                                itemkey in varchar2)
is
 l_OrderID number;
 l_LineItemID number;

 l_tempKey varchar2(240);

 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchServiceProcess.itemtype,
                                          itemkey => LaunchServiceProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchServiceProcess.itemtype,
                                             itemkey => LaunchServiceProcess.itemkey,
                                             aname => 'LINE_ITEM_ID');


  select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
  l_tempKey := to_char(l_OrderID) || '-SVC-' || to_char(l_LineItemID) || l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateNAddAttrNParentLabel(itemtype => 'XDPPROV',
			      itemkey => l_tempKey,
			      processname => 'SERVICE_PROCESS',
			      parentitemtype => LaunchServiceProcess.itemtype,
			      parentitemkey => LaunchServiceProcess.itemkey,
                              WaitflowLabel => 'WAITFORFLOW-SERVICE',
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => null,
			      FAInstanceID => null);

     wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                               itemkey =>  l_tempKey,
                               aname => 'MASTER_TO_CONTINUE',
                               avalue => 'WAITFORFLOW-SERVICE');


  wf_engine.StartProcess(itemtype => 'XDPPROV',
                         itemkey => l_tempKey);


exception
when others then
 x_Progress := 'XDPCORE_LINE.LaunchServiceProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'LaunchServiceProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchServiceProcess;



Procedure InitializeLine (itemtype in varchar2,
                          itemkey in varchar2) IS

 l_OrderID number;
 l_LineItemID number;

 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => InitializeLine.itemtype,
                                          itemkey => InitializeLine.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => InitializeLine.itemtype,
                                             itemkey => InitializeLine.itemkey,
                                             aname => 'LINE_ITEM_ID');


 if l_OrderID is not null and l_LineItemID is not null then

    UPDATDE_ORDER_LINE(p_line_item_id => l_LineItemID ,
                       p_status_code  => 'IN PROGRESS',
                       p_itemtype     => InitializeLine.itemtype,
                       p_itemkey      => InitializeLine.itemkey );

 end if;
exception
when others then
     x_Progress := 'XDPCORE_LINE.InitializeLine. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
     wf_core.context('XDPCORE_LINE', 'InitializeLine', itemtype, itemkey, null, x_Progress);
      raise;
end InitializeLine;

PROCEDURE UPDATDE_ORDER_LINE(p_line_item_id IN NUMBER ,
                             p_status_code  IN VARCHAR2,
                             p_itemtype     IN VARCHAR2,
                             p_itemkey      IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION ;

x_Progress  VARCHAR2(2000);

BEGIN

     UPDATE xdp_order_line_items
        SET status_code       = p_status_code ,
            wf_item_type      = p_itemtype,
            wf_item_key       = p_itemkey,
            last_update_date  = sysdate ,
            last_updated_by   = fnd_global.user_id ,
            last_update_login = fnd_global.login_id
      WHERE line_item_id      = p_line_item_id ;

COMMIT;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_LINE.UPDATDE_ORDER_LINE. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_LINE', 'UPDATDE_ORDER_LINE', p_itemtype, p_itemkey, null, x_Progress);
          ROLLBACK;
          raise;
END UPDATDE_ORDER_LINE ;


Procedure AddLineAttributes(itemtype in varchar2,
			    itemkey in varchar2,
			    Module in varchar2,
			    IsPackageFlag in varchar2,
                            ibsource in   varchar2,
                            ibsourceid in number,
			    LineProcessCaller in varchar2,
			    CurrentLineSequence in number,
			    ErrCode OUT NOCOPY number,
			    ErrStr OUT NOCOPY varchar2)
is

begin

  ErrCode := 0;
  ErrStr := NULL;

  if IsPackageFlag is not null then
       XDPCORE.CheckNAddItemAttrText (itemtype => AddLineAttributes.itemtype,
                                      itemkey => AddLineAttributes.itemkey,
                                      AttrName => 'IS_PACKAGE_FLAG',
                                      AttrValue => IsPackageFlag,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

	if ErrCode <> 0 then
		ErrStr := 'In ' || Module || '. Error when adding Item Attribute ' ||
			'IS_PACKAGE_FLAG. Error: ' || substr(ErrStr,1,1500);
		return;
	end if;
  end if;

  if ibsource is not null then
       XDPCORE.CheckNAddItemAttrText (itemtype => AddLineAttributes.itemtype,
                                      itemkey => AddLineAttributes.itemkey,
                                      AttrName => 'IB_SOURCE',
                                      AttrValue => ibsource,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

	if ErrCode <> 0 then
		ErrStr := 'In ' || Module || '. Error when adding Item Attribute ' ||
			'IB_SOURCE. Error: ' || substr(ErrStr,1,1500);
		return;
	end if;
  end if;
  if ibsourceid is not null then
       XDPCORE.CheckNAddItemAttrNumber (itemtype => AddLineAttributes.itemtype,
                                      itemkey => AddLineAttributes.itemkey,
                                      AttrName => 'IB_SOURCE_ID',
                                      AttrValue => ibsourceid,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

	if ErrCode <> 0 then
		ErrStr := 'In ' || Module || '. Error when adding Item Attribute ' ||
			'IB_SOURCE_ID. Error: ' || substr(ErrStr,1,1500);
		return;
	end if;
  end if;

  if LineProcessCaller is not null then
       XDPCORE.CheckNAddItemAttrText (itemtype => AddLineAttributes.itemtype,
                                      itemkey => AddLineAttributes.itemkey,
                                      AttrName => 'LINE_PROCESSING_CALLER',
                                      AttrValue => LineProcessCaller,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

	if ErrCode <> 0 then
		ErrStr := 'In ' || Module || '. Error when adding Item Attribute ' ||
			'LINE_PROCESSING_CALLER. Error: ' || substr(ErrStr,1,1500);
		return;
	end if;
  end if;


  if CurrentLineSequence is not null then
       XDPCORE.CheckNAddItemAttrNumber (itemtype => AddLineAttributes.itemtype,
                                      itemkey => AddLineAttributes.itemkey,
                                      AttrName => 'CURRENT_LINE_SEQUENCE',
                                      AttrValue => CurrentLineSequence,
                                      ErrCode => ErrCode,
                                      ErrStr => ErrStr);

	if ErrCode <> 0 then
		ErrStr := 'In ' || Module || '. Error when adding Item Attribute ' ||
			'CURRENT_LINE_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
		return;
	end if;
  end if;

exception
when others then
 errcode := SQLCODE;
 errstr := 'Unhandled Exception when adding Line Attributes: ' || substr(SQLERRM,1,500);
end AddLineAttributes;


Procedure UpdateInstallBase(itemtype in varchar2,
                            itemkey in varchar2)
is
 l_OrderID number;
 l_LineItemID number;
 l_errCode number := 0;
 l_errStr varchar2(1996):=  NULL;
 l_error_description varchar2(2000);


begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => UpdateInstallBase.itemtype,
                                          itemkey => UpdateInstallBase.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => UpdateInstallBase.itemtype,
                                             itemkey => UpdateInstallBase.itemkey,
                                             aname => 'LINE_ITEM_ID');

   if l_OrderID is not null and
      l_LineItemID is not null then

      XDP_INSTALL_BASE.UPDATE_IB(p_order_id => l_OrderID,
                                 p_line_id  => l_LineItemID,
                                 p_error_code   => l_errcode,
                                 p_error_description => l_error_description);
   end if;

   if l_errCode <> 0 then
      l_errStr :=  ' Error when adding Item Attribute ' ||
			'UpdateInstallBase. Error: ' || substr(l_error_description,1,1500);
      return;
   end if;

 END UpdateInstallBase;

Procedure InitializeDepLineProcess(itemtype in varchar2,
                            itemkey  in varchar2 ) IS
 ErrCode number;
 ErrStr varchar2(1996);

 e_AddAttributeException exception;
 x_Progress                     VARCHAR2(2000);

begin

       XDPCORE.CheckNAddItemAttrNumber (itemtype => InitializeDepLineProcess.itemtype,
                                        itemkey => InitializeDepLineProcess.itemkey,
                                        AttrName => 'CURRENT_LINE_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

      if ErrCode <> 0 then
         x_progress := 'In XDPCORE_LINE.InitializeDepLineProcess. Error when adding Item Attribute CURRENT_LINE_SEQUENCE. Error:' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      end if;


EXCEPTION
  when others then
   x_Progress := 'XDPCORE_LINE.InitializeDepLineProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 xdpcore.context('XDPCORE_LINE', 'InitializeDepLineProcess', itemtype, itemkey,x_Progress);
 wf_core.context('XDPCORE_LINE', 'InitializeDepLineProcess', itemtype, itemkey, null, x_Progress);
  raise;


END InitializeDepLineProcess;


Function ResolveIndDepLines (itemtype in varchar2,
                                     itemkey in varchar2) return varchar2
is
 l_OrderID number;

 l_IndFound number := 0;
 l_DepFound number := 0;

 x_Progress                     VARCHAR2(2000);

 cursor c_GetIndLines(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE = 0;

 cursor c_GetDepLines(OrderID number) is
  select 'Y'
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and IS_VIRTUAL_LINE_FLAG = 'N'
    and STATUS_CODE = 'READY'
    and LINE_SEQUENCE > 0;

begin

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepLines.itemtype,
                                          itemkey => ResolveIndDepLines.itemkey,
                                          aname => 'ORDER_ID');

 FOR lv_LineRec in c_GetIndLines( l_OrderID ) LOOP
  l_IndFound := 1;
  EXIT;
 END LOOP;

 FOR lv_LineRec in c_GetDepLines( l_OrderID ) LOOP
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


exception
when others then

 x_Progress := 'XDPCORE_LINE.ResolveIndDepLines. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'ResolveIndDepLines', itemtype, itemkey, null, x_Progress);
  raise;
end ResolveIndDepLines;


Function IsSerPartPackage (itemtype in varchar2,
                                     itemkey in varchar2) return varchar2
is
 l_LineItemID NUMBER;
 l_flag VARCHAR2(1);
 x_Progress                     VARCHAR2(2000);

begin

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => IsSerPartPackage.itemtype,
                                          itemkey => IsSerPartPackage.itemkey,
                                          aname => 'LINE_ITEM_ID');
  SELECT is_virtual_line_flag INTO l_flag
    FROM xdp_order_line_items
   WHERE line_item_id = l_LineItemID;

  return l_flag;
exception
when others then

 x_Progress := 'XDPCORE_LINE.IsSerPartPackage. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_LINE', 'IsSerPartPackage', itemtype, itemkey, null, x_Progress);
  raise;
end IsSerPartPackage;


-- ****************    PublishXDPLineDone   *********************

PROCEDURE PublishXDPLineDone(itemtype  IN VARCHAR2,
                             itemkey   IN VARCHAR2,
                             actid     IN NUMBER,
                             resultout IN VARCHAR2) IS

l_line_number       NUMBER;
l_line_item_id      NUMBER;
l_message_id        NUMBER ;
l_error_code        NUMBER ;
l_error_message     VARCHAR2(4000);
x_progress          VARCHAR2(4000);
l_order_id          NUMBER;
e_publish_exception EXCEPTION ;

BEGIN

     l_line_item_id := WF_ENGINE.GetItemAttrNumber
                              (itemtype => PublishXDPLineDone.itemtype ,
                               itemkey  => PublishXDPLineDone.itemkey ,
                               aname    => 'LINE_ITEM_ID' );

     l_order_id     := WF_ENGINE.GetItemAttrNumber
                              (itemtype => PublishXDPLineDone.itemtype ,
                               itemkey  => PublishXDPLineDone.itemkey ,
                               aname    => 'ORDER_ID' );

    SELECT line_number
      INTO l_line_number
      FROM xdp_order_line_items
     WHERE line_item_id  = l_line_item_id ;


    XNP_XDP_LINE_DONE_U.PUBLISH
                   (XNP$LINE_ITEM_ID     => l_line_item_id ,
                    P_REFERENCE_ID       => l_line_number  ,
                    P_ORDER_ID           => l_order_id ,
                    X_MESSAGE_ID         => l_message_id  ,
                    X_ERROR_CODE         => l_error_code  ,
                    X_ERROR_MESSAGE      => l_error_message );

    IF l_error_code <> 0 THEN
       x_progress := 'In XDPCORE_LINE.PublishXDPLineDone. Error while publishing XDP_LINE_DONE . Error :- ' ||l_error_message ;
       RAISE e_publish_exception ;
    END IF ;

EXCEPTION
     WHEN e_publish_exception THEN
           wf_core.context('XDPCORE_LINE', 'PublishXDPLineDone', itemtype, itemkey, null, x_Progress);
           raise;
     WHEN others THEN
          wf_core.context('XDPCORE_LINE', 'PublishXDPLineDone',itemtype,itemkey,actid,null);
          raise;
END PublishXDPLineDone ;

End XDPCORE_LINE;

/
