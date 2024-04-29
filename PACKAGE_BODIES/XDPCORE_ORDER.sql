--------------------------------------------------------
--  DDL for Package Body XDPCORE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_ORDER" AS
/* $Header: XDPCOROB.pls 120.1 2005/06/15 22:39:05 appldev  $ */


/****
 All Private Procedures for the Package
****/

Function HandleOtherWFFuncmode (funcmode IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE InitializeOrder(itemtype IN VARCHAR2,
                          itemkey  IN VARCHAR2);

FUNCTION ContinueOrder (itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION IsBundleDetected (itemtype IN VARCHAR2,
                           itemkey  IN VARCHAR2) RETURN VARCHAR2;

TYPE RowidArrayType IS TABLE OF ROWID INDEX BY BINARY_INTEGER;


PROCEDURE UPDATE_ORDER_STATUS (p_order_id IN NUMBER ,
                               p_status   IN VARCHAR2,
                               p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2) ;

/***********************************************
* END of Private Procedures/Function Definitions
************************************************/

--  INITIALIZE_ORDER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here: Initializatio process for the Order. Set Order Processing
--			  State, Order Status and itemtype/itemkey.

Procedure INITIALIZE_ORDER (itemtype  IN VARCHAR2,
			    itemkey   IN VARCHAR2,
			    actid     IN NUMBER,
			    funcmode  IN VARCHAR2,
			    resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

		InitializeOrder(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
	END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORDER', 'INITIALIZE_ORDER', itemtype, itemkey, to_char(actid), funcmode);
END INITIALIZE_ORDER;


--  CONTINUE_ORDER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here: Initializatio process for the Order. Set Order Processing
--			  State, Order Status and itemtype/itemkey.

PROCEDURE CONTINUE_ORDER (itemtype  IN VARCHAR2,
			  itemkey   IN VARCHAR2,
			  actid     IN NUMBER,
			  funcmode  IN VARCHAR2,
			  resultout OUT NOCOPY VARCHAR2 ) IS

l_Result     VARCHAR2(1);
x_Progress   VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

		l_Result := ContinueOrder(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
	END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORDER', 'CONTINUE_ORDER', itemtype, itemkey, to_char(actid), funcmode);
END CONTINUE_ORDER;


--  IS_BUNDLE_DETECTED
--   Resultout
--     yes/no
--
-- Your Description here: This procedure determines if the Order Analyzer is
--                        to Process the current Order


PROCEDURE IS_BUNDLE_DETECTED (itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2 ) IS

l_result     VARCHAR2(10);
 x_Progress  VARCHAR2(2000);

BEGIN

-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_result := IsBundleDetected(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_ORDER', 'IS_BUNDLE_DETECTED', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END IS_BUNDLE_DETECTED;


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




FUNCTION ContinueOrder (itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2)  RETURN VARCHAR2 IS

 l_OrderID  NUMBER;
 l_Continue VARCHAR2(1) := 'N';
 x_Progress VARCHAR2(2000);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ContinueOrder.itemtype,
                                          itemkey  => ContinueOrder.itemkey,
                                          aname    => 'ORDER_ID');

   BEGIN
     SELECT 'Y'
       INTO l_Continue
       FROM dual
      WHERE EXISTS (SELECT LINE_ITEM_ID
                      FROM XDP_ORDER_LINE_ITEMS
                     WHERE ORDER_ID = l_OrderID
                       AND STATUS_CODE   = 'READY'
                       AND PROVISIONING_REQUIRED_FLAG = 'Y');

   EXCEPTION
        WHEN no_data_found THEN
             l_Continue := 'N';
        WHEN others THEN
             RAISE;
   END;

 return (l_Continue);

EXCEPTION
     WHEN others THEN

          x_Progress := 'XDPCORE_ORDER.ContinueOrder. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_ORDER', 'ContinueOrder',itemtype, itemkey, null, x_Progress);
          raise;
END ContinueOrder;



PROCEDURE InitializeOrder (itemtype IN VARCHAR2,
                           itemkey  IN VARCHAR2) IS

 l_OrderID                NUMBER;
 e_InvalidConfigException EXCEPTION;
 x_Progress               VARCHAR2(2000);

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => InitializeOrder.itemtype,
                                          itemkey => InitializeOrder.itemkey,
                                          aname => 'ORDER_ID');

 IF l_OrderID is null THEN
    RAISE e_InvalidConfigException;
 ELSE
   /*
    * Update the STATE of the Order to be 'RUNNING' and the status to be 'IN PROGRESS'
    * Also update the item type and item key
    */

    UPDATE_ORDER_STATUS (p_order_id => l_OrderID,
                         p_status   => 'IN PROGRESS',
                         p_itemtype => itemtype,
                         p_itemkey  => itemkey ) ;
 END IF;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_ORDER.InitializeOrder. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_ORDER', 'InitializeOrder', itemtype, itemkey, null, x_Progress);
          raise;
END InitializeOrder;


FUNCTION IsBundleDetected (itemtype IN VARCHAR2,
                           itemkey  IN VARCHAR2) RETURN VARCHAR2 IS

 l_OrderID     NUMBER;
 l_BundleCount NUMBER;
 l_ErrCode number;
 l_ErrDescription varchar2(800);

 x_Progress    VARCHAR2(2000);

BEGIN

 l_OrderID :=  wf_engine.GetItemAttrNumber(itemtype => IsBundleDetected.itemtype,
                                           itemkey => IsBundleDetected.itemkey,
                                           aname => 'ORDER_ID');

 BEGIN
   SELECT 1
     INTO l_BundleCount
     FROM dual
    WHERE EXISTS(SELECT BUNDLE_ID
                   FROM XDP_ORDER_LINE_ITEMS
                  WHERE ORDER_ID = l_OrderID
                    AND PROVISIONING_REQUIRED_FLAG = 'Y'
                    AND BUNDLE_ID IS NOT NULL);


 EXCEPTION
      WHEN no_data_found THEn
           l_BundleCount := 0;
      WHEN others THEN
           raise;
 END;



 IF l_BundleCount = 0 THEN
    /* Bundle Not detected */

   XDPCORE.CheckNAddItemAttrText (itemtype => IsBundleDetected.itemtype,
                                             itemkey => IsBundleDetected.itemkey,
                                            AttrName => 'LINE_PROCESSING_CALLER',
                                            AttrValue => 'ORDER',
                                            ErrCode => l_ErrCode,
                                            ErrStr => l_ErrDescription);
   return ('N');

 ELSE
   /* Bundle Detected */
   --'LINE_PROCESSING_CALLER' attribute is set while launchig lines from
   --bundle process.. see XDPCORE_BUNDLE.InitializeBundle.. skilaru
   return ('Y');

 END IF;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_ORDER.IsBundleDetected. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_ORDER', 'IsBundleDetected', itemtype, itemkey, null, x_Progress);
          raise;
END IsBundleDetected;

PROCEDURE UPDATE_ORDER_STATUS (p_order_id IN NUMBER ,
                               p_status   IN VARCHAR2,
                               p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress  VARCHAR2(2000);

BEGIN

    UPDATE xdp_order_headers
       SET status_code       = p_status,
           wf_item_type      = p_itemtype,
           wf_item_key       = p_itemkey ,
	   actual_provisioning_date = sysdate,
           last_update_date  = sysdate,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE order_id          = p_order_id ;


COMMIT ;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_ORDER.UPDATE_ORDER_STATUS. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
          wf_core.context('XDPCORE_ORDER', 'UPDATE_ORDER_STATUS', p_itemtype, p_itemkey, null, x_Progress);
          rollback;
          raise;

END UPDATE_ORDER_STATUS;

End XDPCORE_ORDER;

/
