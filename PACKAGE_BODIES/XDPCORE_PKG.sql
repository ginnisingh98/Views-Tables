--------------------------------------------------------
--  DDL for Package Body XDPCORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_PKG" AS
/* $Header: XDPCORPB.pls 120.1 2005/06/15 22:40:00 appldev  $ */


/****
 All Private Procedures for the Package
****/

FUNCTION HandleOtherWFFuncmode (funcmode IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE InitializePackageService(itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2);

FUNCTION AreAllServicesInPkgDone (itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE LaunchServiceForPkgProcess(itemtype IN VARCHAR2,
                                     itemkey  IN VARCHAR2);

PROCEDURE LaunchServiceInPackage(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2);

FUNCTION ResolveIndDepPkgs (itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2) RETURN VARCHAR2;

Function LaunchAllIndServices(itemtype IN VARCHAR2,
                                     itemkey  IN VARCHAR2) return varchar2;

PROCEDURE InitializeDepServiceProcess(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2);

TYPE RowidArrayType IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

PROCEDURE UPDATE_PACKAGESERVICE_STATUS (p_line_item_id IN NUMBER,
                                        p_status_code  IN VARCHAR2,
                                        p_itemtype     IN VARCHAR2,
                                        p_itemkey      IN VARCHAR2) ;


/***********************************************
* END of Private Procedures/Function Definitions
************************************************/

--  INITIALIZE_PACKAGE_SERVICE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE INITIALIZE_PACKAGE_SERVICE (itemtype  IN VARCHAR2,
			              itemkey   IN VARCHAR2,
			              actid     IN NUMBER,
			              funcmode  IN VARCHAR2,
			              resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               InitializePackageService(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
      wf_core.context('XDPCORE_PKG', 'INITIALIZE_PACKAGE_SERVICE', itemtype, itemkey, to_char(actid), funcmode);
      raise;
END INITIALIZE_PACKAGE_SERVICE;





--  LAUNCH_SERVICE_FOR_PKG_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE LAUNCH_SERVICE_FOR_PKG_PROCESS (itemtype  IN VARCHAR2,
			                  itemkey   IN VARCHAR2,
			                  actid     IN NUMBER,
			                  funcmode  IN VARCHAR2,
			                  resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchServiceForPkgProcess(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'LAUNCH_SERVICE_FOR_PKG_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END LAUNCH_SERVICE_FOR_PKG_PROCESS;




--  LAUNCH_SERVICE_IN_PACKAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE LAUNCH_SERVICE_IN_PACKAGE (itemtype  IN VARCHAR2,
			             itemkey   IN VARCHAR2,
			             actid     IN NUMBER,
			             funcmode  IN VARCHAR2,
			             resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               LaunchServiceInPackage(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'LAUNCH_SERVICE_IN_PACKAGE', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END LAUNCH_SERVICE_IN_PACKAGE;






--  ARE_ALL_SERVICES_IN_PKG_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

PROCEDURE ARE_ALL_SERVICES_IN_PKG_DONE (itemtype        IN VARCHAR2,
                                        itemkey         IN VARCHAR2,
                                        actid           IN NUMBER,
                                        funcmode        IN VARCHAR2,
                                        resultout       OUT NOCOPY VARCHAR2 ) IS
l_result   VARCHAR2(10);
x_Progress VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := AreAllServicesInPkgDone(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'ARE_ALL_SERVICES_IN_PKG_DONE', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END ARE_ALL_SERVICES_IN_PKG_DONE;


PROCEDURE UPDATE_PACKAGESERVICE_STATUS (p_line_item_id IN NUMBER,
                                        p_status_code  IN VARCHAR2,
                                        p_itemtype     IN VARCHAR2,
                                        p_itemkey      IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION ;

 x_Progress   VARCHAR2(2000);

BEGIN
      UPDATE xdp_order_line_items
         SET status_code       = p_status_code,
             last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE line_item_id      = p_line_item_id ;
COMMIT;

EXCEPTION
     WHEN OTHERS THEN
          x_Progress := 'XDPCORE_PKG.UPDATE_PACKAGESERVICE_STATUS. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_PKG', 'UPDATE_PACKAGESERVICE_STATUS', p_itemtype, p_itemkey, null,null);
          rollback;
          raise;
END UPDATE_PACKAGESERVICE_STATUS;


PROCEDURE RESOLVE_IND_DEP_PKGS (itemtype        IN VARCHAR2,
                                        itemkey         IN VARCHAR2,
                                        actid           IN NUMBER,
                                        funcmode        IN VARCHAR2,
                                        resultout       OUT NOCOPY VARCHAR2 ) IS
l_result   VARCHAR2(15);
x_Progress VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := ResolveIndDepPkgs(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'RESOLVE_IND_DEP_PKGS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END RESOLVE_IND_DEP_PKGS;

PROCEDURE LAUNCH_ALL_IND_SERVICES (itemtype        IN VARCHAR2,
                                        itemkey         IN VARCHAR2,
                                        actid           IN NUMBER,
                                        funcmode        IN VARCHAR2,
                                        resultout       OUT NOCOPY VARCHAR2 ) IS
x_Progress VARCHAR2(2000);
l_result varchar2(1):= 'N';

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := LaunchAllIndServices(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'LAUNCH_ALL_IND_SERVICES', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END LAUNCH_ALL_IND_SERVICES;

PROCEDURE INITIALIZE_DEP_SERVICE_PROCESS (itemtype        IN VARCHAR2,
                                        itemkey         IN VARCHAR2,
                                        actid           IN NUMBER,
                                        funcmode        IN VARCHAR2,
                                        resultout       OUT NOCOPY VARCHAR2 ) IS
x_Progress VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                InitializeDepServiceProcess(itemtype, itemkey);
		resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_PKG', 'INITIALIZE_DEP_SERVICE_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END INITIALIZE_DEP_SERVICE_PROCESS;

/****
 All the Private Functions
****/

FUNCTION HandleOtherWFFuncmode( funcmode IN VARCHAR2) RETURN VARCHAR2
IS
resultout   VARCHAR2(30);
x_Progress  VARCHAR2(2000);

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


PROCEDURE LaunchServiceForPkgProcess (itemtype IN VARCHAR2,
                                      itemkey  IN VARCHAR2)
IS
 l_OrderID       NUMBER;
 l_LineItemID    NUMBER;
 l_SrvLineItemID NUMBER;
 l_Counter       NUMBER := 0;
 l_tempKey       VARCHAR2(240);

 TYPE t_ChildKeyTable IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 t_ChildKeys t_ChildKeyTable;

 TYPE t_ChildTypeTable IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
 t_ChildTypes t_ChildTypeTable;

 CURSOR c_GetIndServices (LineItemID NUMBER) IS
  SELECT XOL.LINE_ITEM_ID
    FROM XDP_LINE_RELATIONSHIPS XLR,
         XDP_ORDER_LINE_ITEMS XOL
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    IN ('IS_PART_OF_PACKAGE','IS_PART_OF_IB_EXPLOSION')
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE                = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND (SEQ_IN_PACKAGE IS NULL OR SEQ_IN_PACKAGE = 0);

 CURSOR c_GetDepServices (LineItemID NUMBER) IS
  SELECT XOL.LINE_ITEM_ID
    FROM XDP_LINE_RELATIONSHIPS XLR, XDP_ORDER_LINE_ITEMS XOL
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    IN ('IS_PART_OF_PACKAGE','IS_PART_OF_IB_EXPLOSION')
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE                = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND SEQ_IN_PACKAGE > 0;

 e_NoSvcInPkgFoundException EXCEPTION;
 e_AddAttributeException    EXCEPTION;

 x_Progress  VARCHAR2(2000);
 ErrCode     NUMBER;
 ErrStr      VARCHAR2(1996);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'LINE_ITEM_ID');


 IF c_GetIndServices%ISOPEN THEN
    CLOSE c_GetIndServices;
 END IF;

 /* Launch INdependent Service Worlflows for all the independent services of the package */

  OPEN c_GetIndServices(l_LineItemID);

  LOOP
    FETCH c_GetIndServices INTO l_SrvLineItemID;
    EXIT WHEN c_GetIndServices%NOTFOUND;

     l_Counter := l_Counter + 1;

     SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL) INTO l_tempKey FROM dual;
     l_tempKey := to_char(l_OrderID) || '-PKG-' || to_char(l_SrvLineItemID) || '-SVC-' || to_char(l_SrvLineItemID) || '-' || l_tempKey;


     t_ChildTypes(l_Counter) := 'XDPPROV';
     t_ChildKeys(l_Counter)  := l_tempKey;

      wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                              itemkey  => t_ChildKeys(l_Counter),
                              process  => 'SERVICE_PROCESS');

      wf_engine.SetItemParent(itemtype        => t_ChildTypes(l_Counter),
                              itemkey         => t_ChildKeys(l_Counter),
                              parent_itemtype => itemtype,
                              parent_itemkey  => itemkey,
                              parent_context  => null);

      wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'ORDER_ID',
                                  avalue   => l_OrderID);

      wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'LINE_ITEM_ID',
                                  avalue   => l_SrvLineItemID);

  END LOOP;

 close c_GetIndServices;

  /* Launch ONE Dependent Serivice Process for any Dependent service in the package */


  IF c_GetDepServices%ISOPEN THEN
     CLOSE c_GetDepServices;
  END IF;

  OPEN c_GetDepServices(l_LineItemID);

  FETCH c_GetDepServices INTO l_SrvLineItemID;

  IF c_GetDepServices%FOUND THEN
     l_Counter := l_Counter + 1;

     SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL) INTO l_tempKey FROM dual;
     l_tempKey := to_char(l_OrderID) || '-PKG-' || to_char(l_SrvLineItemID) || '-SVC-' || to_char(l_SrvLineItemID) || '-' || l_tempKey;


     t_ChildTypes(l_Counter) := 'XDPPROV';
     t_ChildKeys(l_Counter) := l_tempKey;

      wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                              itemkey  => t_ChildKeys(l_Counter),
                              process  => 'DEPENDENT_SERVICE_PROCESS');

      wf_engine.SetItemParent(itemtype        => t_ChildTypes(l_Counter),
                              itemkey         => t_ChildKeys(l_Counter),
                              parent_itemtype => itemtype,
                              parent_itemkey  => itemkey,
                              parent_context  => null);

      wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'ORDER_ID',
                                  avalue   => l_OrderID);

      wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'LINE_ITEM_ID',
                                  avalue   => l_LineItemID);

       XDPCORE.CheckNAddItemAttrNumber (itemtype  => t_ChildTypes(l_Counter),
                                        itemkey   => t_ChildKeys(l_Counter),
                                        AttrName  => 'CURRENT_SRV_IN_PKG_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode   => ErrCode,
                                        ErrStr    => ErrStr);

      IF ErrCode <> 0 THEN
         x_progress := 'In XDPCORE_WI.LaunchWIServiceForPkgProcess. Error when adding Item Attribute CURRENT_SRV_IN_PKG_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      END IF;

  END IF;

  close c_GetDepServices;

  IF l_Counter = 0 THEN
     x_Progress := 'XDPCORE_PKG.LaunchServiceForPkgProcess. No Services found to be processed for Order: ' || l_OrderID || ' LineItemID: ' || l_LineItemID;
     RAISE e_NoSvcInPkgFoundException;
  END IF;

   /* Start the WF Process */
   FOR i in 1..l_Counter LOOP
       wf_engine.StartProcess(t_ChildTypes(i),
                              t_ChildKeys(i));
   END LOOP;



EXCEPTION
     WHEN e_AddAttributeException then
          IF c_GetIndServices%ISOPEN THEN
             CLOSE c_GetIndServices;
          END IF;

          IF c_GetDepServices%ISOPEN THEN
             CLOSE c_GetDepServices;
          END IF;

         wf_core.context('XDPCORE_PKG', 'LaunchServiceForPkgProcess', itemtype, itemkey, null,null);
          raise;

    WHEN e_NoSvcInPkgFoundException THEN
         IF c_GetIndServices%ISOPEN THEN
            CLOSE c_GetIndServices;
         END IF;

          IF c_GetDepServices%ISOPEN THEN
             CLOSE c_GetDepServices;
          END IF;

         wf_core.context('XDPCORE_PKG', 'LaunchServiceForPkgProcess', itemtype, itemkey, null,null);
          raise;

     WHEN others THEN
         IF c_GetIndServices%ISOPEN THEN
            CLOSE c_GetIndServices;
         END IF;

          IF c_GetDepServices%ISOPEN THEN
             CLOSE c_GetDepServices;
          END IF;

         x_Progress := 'XDPCORE_PKG.LaunchServiceForPkgProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
         wf_core.context('XDPCORE_PKG', 'LaunchServiceForPkgProcess', itemtype, itemkey, null,null);
          raise;
END LaunchServiceForPkgProcess;



FUNCTION AreAllServicesInPkgDone (itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2) RETURN VARCHAR2
IS
 l_OrderID       NUMBER;
 l_LineItemID    NUMBER;
 l_SvcLineItemID NUMBER;
 l_PrevSequence  NUMBER;

 CURSOR c_GetSrcSeq (LineItemID number, OrderID number, Seq number) is
   SELECT XOl.LINE_ITEM_ID, XOL.SEQ_IN_PACKAGE
   FROM XDP_ORDER_LINE_ITEMS XOL, XDP_LINE_RELATIONSHIPS XLR
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    = 'IS_PART_OF_PACKAGE'
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE               = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND XOL.SEQ_IN_PACKAGE  = (
                            SELECT MIN(XOL1.SEQ_IN_PACKAGE)
                            FROM XDP_ORDER_LINE_ITEMS XOL1, XDP_LINE_RELATIONSHIPS XLR1
                            WHERE XLR1.RELATED_LINE_ITEM_ID   = LineItemID
                                AND XLR1.LINE_RELATIONSHIP    = 'IS_PART_OF_PACKAGE'
                                AND XOL1.LINE_ITEM_ID         = XLR1.LINE_ITEM_ID
                                AND XOL1.STATUS_CODE               = 'READY'
                                AND XOL1.IS_VIRTUAL_LINE_FLAG = 'Y'
                                AND XOL1.SEQ_IN_PACKAGE  > Seq);

 e_NoServicesFoundException EXCEPTION;
 x_Progress                 VARCHAR2(2000);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'LINE_ITEM_ID');

 l_PrevSequence := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CURRENT_SRV_IN_PKG_SEQUENCE');

 IF c_GetSrcSeq%ISOPEN THEN
    CLOSE c_GetSrcSeq;
 END IF;


 OPEN c_GetSrcSeq(l_LineItemID, l_OrderID, l_PrevSequence);

 FETCH c_GetSrcSeq INTO l_SvcLineItemID, l_PrevSequence;

 IF c_GetSrcSeq%NOTFOUND  THEN
     /* No more Services in package to be done */
      CLOSE c_GetSrcSeq;
      return 'Y';
 ELSE
   /* There are more Services to be done */
      CLOSE c_GetSrcSeq;
      return 'N';
 END IF;

 IF c_GetSrcSeq%ISOPEN THEN
    CLOSE c_GetSrcSeq;
 END IF;

EXCEPTION
     WHEN e_NoServicesFoundException then
          IF c_GetSrcSeq%ISOPEN THEN
             CLOSE c_GetSrcSeq;
          END IF;

          wf_core.context('XDPCORE_PKG', 'AreAllServicesInPkgDone', itemtype, itemkey, null,null);
           raise;

     WHEN Others THEN
          IF c_GetSrcSeq%ISOPEN THEN
             CLOSE c_GetSrcSeq;
          END IF;

          x_Progress := 'XDPCORE_PKG.AreAllServicesInPkgDone. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_PKG', 'AreAllServicesInPkgDone', itemtype, itemkey, null,null);
           raise;
END AreAllServicesInPkgDone;



PROCEDURE LaunchServiceInPackage (itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2)

IS

 l_OrderID         NUMBER;
 l_LineItemID      NUMBER;
 l_SvcLineItemID   NUMBER;
 l_PrevSequence    NUMBER;
 l_CurrentSequence NUMBER;
 l_Counter         NUMBER := 0;
 l_tempKey         VARCHAR2(240);

CURSOR c_GetSrcSeq (LineItemID number, OrderID number, Seq number) is
   SELECT XOl.LINE_ITEM_ID, XOL.SEQ_IN_PACKAGE
     FROM XDP_ORDER_LINE_ITEMS XOL,
          XDP_LINE_RELATIONSHIPS XLR
    WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
      AND XLR.LINE_RELATIONSHIP    = 'IS_PART_OF_PACKAGE'
      AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
      AND XOL.STATUS_CODE               = 'READY'
      AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
      AND XOL.SEQ_IN_PACKAGE       = (
                            SELECT MIN(XOL1.SEQ_IN_PACKAGE)
                              FROM XDP_ORDER_LINE_ITEMS XOL1,
                                   XDP_LINE_RELATIONSHIPS XLR1
                             WHERE XLR1.RELATED_LINE_ITEM_ID = LineItemID
                               AND XLR1.LINE_RELATIONSHIP    = 'IS_PART_OF_PACKAGE'
                               AND XOL1.LINE_ITEM_ID         = XLR1.LINE_ITEM_ID
                               AND XOL1.STATUS_CODE               = 'READY'
                               AND XOL1.IS_VIRTUAL_LINE_FLAG = 'Y'
                               AND XOL1.SEQ_IN_PACKAGE  > Seq);


TYPE t_ChildKeyTable IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

 e_NoSvcInPkgFoundException EXCEPTION;
 e_AddAttributeException    EXCEPTION;
 x_Progress                 VARCHAR2(2000);
 ErrCode                    NUMBER;
 ErrStr                     VARCHAR2(1996);


BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'LINE_ITEM_ID');

 l_PrevSequence := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CURRENT_SRV_IN_PKG_SEQUENCE');

 IF c_GetSrcSeq%ISOPEN THEN
    CLOSE c_GetSrcSeq;
 END IF;


 OPEN c_GetSrcSeq(l_LineItemID, l_OrderID, l_PrevSequence);

 LOOP

   FETCH c_GetSrcSeq into l_SvcLineItemID, l_CurrentSequence;
   EXIT WHEN c_GetSrcSeq%NOTFOUND;

    l_Counter := l_Counter + 1;

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL) INTO l_tempKey FROM dual;
     l_tempKey := to_char(l_OrderID) || '-PKG-' || to_char(l_LineItemID) || '-SVC-' || to_char(l_LineItemID) || '-' || l_tempKey;

    t_ChildTypes(l_Counter) := 'XDPPROV';
    t_ChildKeys(l_Counter) := l_tempKey;

     wf_engine.CreateProcess(itemtype => t_ChildTypes(l_Counter),
                             itemkey  => t_ChildKeys(l_Counter),
                             process  => 'SERVICE_PROCESS');

     wf_engine.SetItemParent(itemtype        => t_ChildTypes(l_Counter),
                             itemkey         => t_ChildKeys(l_Counter),
                             parent_itemtype => itemtype,
                             parent_itemkey  => itemkey,
                             parent_context  => 'WAITFORFLOW-SERVICE-DEP');

     wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                               itemkey => l_tempKey,
                               aname => 'MASTER_TO_CONTINUE',
                               avalue => 'WAITFORFLOW-SERVICE-DEP');

     wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                 itemkey  => t_ChildKeys(l_Counter),
                                 aname    => 'ORDER_ID',
                                 avalue   => l_OrderID);

     wf_engine.SetItemAttrNumber(itemtype => t_ChildTypes(l_Counter),
                                 itemkey  => t_ChildKeys(l_Counter),
                                 aname    => 'LINE_ITEM_ID',
                                 avalue   => l_SvcLineItemID);

 END LOOP;

  CLOSE c_GetSrcSeq;

  IF l_Counter = 0 and l_CurrentSequence = 0 THEN
      x_Progress := 'XDPCORE_PKG.LaunchServiceInPackage. No Services found to be processed for Order: ' || l_OrderID || ' LineItemID (Package): ' || l_LineItemID;
     RAISE e_NoSvcInPkgFoundException;
  ELSE
       XDPCORE.CheckNAddItemAttrNumber (itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        AttrName  => 'CURRENT_SRV_IN_PKG_SEQUENCE',
                                        AttrValue => l_CurrentSequence,
                                        ErrCode   => ErrCode,
                                        ErrStr    => ErrStr);

      IF ErrCode <> 0 THEN
         x_progress := 'In XDPCORE_WI.LaunchWIServiceInPackage. Error when adding Item Attribute CURRENT_SRV_IN_PKG_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      END IF;

     /* Launch the Service Process */

     FOR i in 1..l_Counter LOOP

         wf_engine.StartProcess(itemtype => t_ChildTypes(i),
                                itemkey  => t_ChildKeys(i));

     END LOOP;

  END IF;


EXCEPTION
     WHEN e_AddAttributeException then
          IF c_GetSrcSeq%ISOPEN THEN
             CLOSE c_GetSrcSeq;
          END IF;

          wf_core.context('XDPCORE_PKG', 'LaunchServiceInPackage', itemtype, itemkey, null,null);
           raise;

     WHEN e_NoSvcInPkgFoundException THEN
          IF c_GetSrcSeq%ISOPEN THEN
             CLOSE c_GetSrcSeq;
          END IF;

          wf_core.context('XDPCORE_PKG', 'LaunchServiceInPackage', itemtype, itemkey, null,null);
           raise;

     WHEN others THEN
          IF c_GetSrcSeq%ISOPEN THEN
             CLOSE c_GetSrcSeq;
          END IF;

          x_Progress := 'XDPCORE_PKG.LaunchServiceInPackage. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE_PKG', 'LaunchServiceInPackage', itemtype, itemkey, null,null);
           raise;
END LaunchServiceInPackage;

PROCEDURE InitializePackageService (itemtype IN VARCHAR2,
                                    itemkey  IN VARCHAR2) IS

 l_OrderID    NUMBER;
 l_LineItemID NUMBER;
 x_Progress   VARCHAR2(2000);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey => itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                             itemkey => itemkey,
                                             aname => 'LINE_ITEM_ID');

 IF l_OrderID is not null and l_LineItemID is not null THEN

    UPDATE_PACKAGESERVICE_STATUS (p_line_item_id => l_LineItemID,
                                  p_status_code  => 'IN PROGRESS',
                                  p_itemtype     => itemtype,
                                  p_itemkey      => itemkey);
 END IF;

EXCEPTION
WHEN OTHERS THEN
     x_Progress := 'XDPCORE_PKG.InitializePackageService. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
     wf_core.context('XDPCORE_PKG', 'InitializePackageService', itemtype, itemkey, null,null);
     raise;
END initializePackageService;


FUNCTION ResolveIndDepPkgs (itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2) RETURN VARCHAR2
IS
 l_IndFound number := 0;
 l_DepFound number := 0;
 l_LineItemID number;


 CURSOR c_GetIndServices (LineItemID NUMBER) IS
  SELECT 'Y'
    FROM XDP_LINE_RELATIONSHIPS XLR,
         XDP_ORDER_LINE_ITEMS XOL
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    IN ('IS_PART_OF_PACKAGE','IS_PART_OF_IB_EXPLOSION')
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE                = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND (SEQ_IN_PACKAGE IS NULL OR SEQ_IN_PACKAGE = 0);

 CURSOR c_GetDepServices (LineItemID NUMBER) IS
  SELECT 'Y'
    FROM XDP_LINE_RELATIONSHIPS XLR, XDP_ORDER_LINE_ITEMS XOL
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    IN ('IS_PART_OF_PACKAGE','IS_PART_OF_IB_EXPLOSION')
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE                = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND SEQ_IN_PACKAGE > 0;

 x_Progress   VARCHAR2(2000);

BEGIN

  l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepPkgs.itemtype,
                                              itemkey => ResolveIndDepPkgs.itemkey,
                                              aname => 'LINE_ITEM_ID');

  FOR c_PkgRec in c_GetIndServices( l_LineItemID ) LOOP
   l_IndFound := 1;
   EXIT;
  END LOOP;

  FOR c_PkgRec in c_GetDepServices( l_LineItemID ) LOOP
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
     x_Progress := 'XDPCORE_PKG.ResolveIndDepPkgs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
     wf_core.context('XDPCORE_PKG', 'ResolveIndDepPkgs', itemtype, itemkey, null,null);
     raise;

END ResolveIndDepPkgs;

Function LaunchAllIndServices(itemtype IN VARCHAR2,
                                     itemkey  IN VARCHAR2) return varchar2
IS
 l_OrderID       NUMBER;
 l_LineItemID    NUMBER;
 l_SrvLineItemID NUMBER;
 l_Counter       NUMBER := 0;
 l_tempKey       VARCHAR2(240);

 l_result varchar2(1):= 'N';

 TYPE t_ChildKeyTable IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 t_ChildKeys t_ChildKeyTable;

 CURSOR c_GetIndServices (LineItemID NUMBER) IS
  SELECT XOL.LINE_ITEM_ID
    FROM XDP_LINE_RELATIONSHIPS XLR,
         XDP_ORDER_LINE_ITEMS XOL
   WHERE XLR.RELATED_LINE_ITEM_ID = LineItemID
     AND XLR.LINE_RELATIONSHIP    IN ('IS_PART_OF_PACKAGE','IS_PART_OF_IB_EXPLOSION')
     AND XOL.LINE_ITEM_ID         = XLR.LINE_ITEM_ID
     AND XOL.STATUS_CODE                = 'READY'
     AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y'
     AND (SEQ_IN_PACKAGE IS NULL OR SEQ_IN_PACKAGE = 0);

 e_NoSvcInPkgFoundException EXCEPTION;
 e_AddAttributeException    EXCEPTION;

 x_Progress  VARCHAR2(2000);
 ErrCode     NUMBER;
 ErrStr      VARCHAR2(1996);

BEGIN

  l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndServices.itemtype,
                                          itemkey  => LaunchAllIndServices.itemkey,
                                          aname    => 'ORDER_ID');


  l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndServices.itemtype,
                                              itemkey => LaunchAllIndServices.itemkey,
                                              aname => 'LINE_ITEM_ID');


  FOR c_PkgRec in c_GetIndServices( l_LineItemID ) LOOP
     l_result := 'Y';
     l_SrvLineItemID := c_PkgRec.LINE_ITEM_ID;
     l_Counter := l_Counter + 1;

     SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL) INTO l_tempKey FROM dual;
     l_tempKey := to_char(l_OrderID) || '-PKG-' || to_char(l_SrvLineItemID) || '-SVC-' || to_char(l_SrvLineItemID) || '-' || l_tempKey;

     t_ChildKeys(l_Counter)  := l_tempKey;

      wf_engine.CreateProcess(itemtype => 'XDPPROV',
                              itemkey  => t_ChildKeys(l_Counter),
                              process  => 'SERVICE_PROCESS');

      wf_engine.SetItemParent(itemtype        =>  'XDPPROV',
                              itemkey         => t_ChildKeys(l_Counter),
                              parent_itemtype => itemtype,
                              parent_itemkey  => itemkey,
                              parent_context  => 'WAITFORFLOW-SERVICE-IND');

      wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                itemkey =>   t_ChildKeys(l_Counter),
                                aname => 'MASTER_TO_CONTINUE',
                                avalue => 'WAITFORFLOW-SERVICE-IND');

      wf_engine.SetItemAttrNumber(itemtype =>  'XDPPROV',
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'ORDER_ID',
                                  avalue   => l_OrderID);

      wf_engine.SetItemAttrNumber(itemtype => 'XDPPROV',
                                  itemkey  => t_ChildKeys(l_Counter),
                                  aname    => 'LINE_ITEM_ID',
                                  avalue   => l_SrvLineItemID);



  END LOOP;

   FOR i in 1..l_Counter LOOP
       wf_engine.StartProcess('XDPPROV', t_ChildKeys(i));
   END LOOP;

   return l_result;
EXCEPTION
WHEN OTHERS THEN
     x_Progress := 'XDPCORE_PKG.ResolveIndDepPkgs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1 , 1500);
     wf_core.context('XDPCORE_PKG', 'ResolveIndDepPkgs', itemtype, itemkey, null,null);
     raise;

END LaunchAllIndServices;

PROCEDURE InitializeDepServiceProcess(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2)
IS
  ErrCode number;
  ErrStr varchar2(2000);
  x_progress varchar2(2000);

  e_AddAttributeException exception;

BEGIN
       XDPCORE.CheckNAddItemAttrNumber (itemtype  =>InitializeDepServiceProcess.itemtype,
                                        itemkey   =>InitializeDepServiceProcess.itemkey,
                                        AttrName  => 'CURRENT_SRV_IN_PKG_SEQUENCE',
                                        AttrValue => 0,
                                        ErrCode   => ErrCode,
                                        ErrStr    => ErrStr);

      IF ErrCode <> 0 THEN
         x_progress := 'In XDPCORE_PKG.InitializeDepServiceProcess. Error when adding Item Attribute CURRENT_SRV_IN_PKG_SEQUENCE. Error: ' || substr(ErrStr,1,1500);
         raise e_AddAttributeException;
      END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_Progress := 'XDPCORE_PKG.InitializeDepServiceProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1 , 1500);
     wf_core.context('XDPCORE_PKG', 'InitializeDepServiceProcess', itemtype, itemkey, null,null);
     raise;

END InitializeDepServiceProcess;

END XDPCORE_PKG;

/
