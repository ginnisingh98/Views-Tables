--------------------------------------------------------
--  DDL for Package Body XDP_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_OM_UTIL" AS
/* $Header: XDPOMUTB.pls 120.1 2005/06/09 00:21:55 appldev  $ */

/****
 All Private Procedures for the Package
****/

-- ****************    SUBSCRIBE_SERVICE_FULFILLMENT_DONE   *********************

PROCEDURE SUBSCRIBE_SRV_FULFILLMENT_DONE
                         (itemtype   IN  VARCHAR2,
                          itemkey    IN  VARCHAR2,
                          actid      IN  NUMBER,
                          resultout  OUT NOCOPY VARCHAR2 ) IS

l_reference_id         NUMBER ;
l_message_type         VARCHAR2(40) := 'XDP_FULFILL_DONE';
l_fa_instance_id       NUMBER;
l_workitem_instance_id NUMBER ;
l_order_id             NUMBER;
l_error_code           NUMBER;
l_error_message        VARCHAR2(4000);
l_activity_name        VARCHAR2(400);
l_process_reference    VARCHAR2(1000);
x_progress             VARCHAR2(4000);
e_subscribe_for_event  EXCEPTION;

BEGIN

     l_reference_id :=    to_number(itemkey);
     l_activity_name := wf_engine.GETACTIVITYLABEL(actid);
     l_process_reference := itemtype||':'||itemkey||':'||l_activity_name;

     XNP_STANDARD.SUBSCRIBE_FOR_EVENT
              (p_MESSAGE_TYPE         => l_MESSAGE_TYPE
              ,p_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
              ,p_CALLBACK_REF_ID      => l_REFERENCE_ID
              ,p_PROCESS_REFERENCE    => l_PROCESS_REFERENCE
              ,p_ORDER_ID             => l_ORDER_ID
              ,p_FA_INSTANCE_ID       => l_FA_INSTANCE_ID
              ,x_ERROR_CODE           => l_ERROR_CODE
              ,x_ERROR_MESSAGE        => l_ERROR_MESSAGE );

     IF l_error_code <> 0 THEN
        x_progress := 'In XDP_OM_UTIL.SUBSCRIBE_SRV_FULFILLMENT_DONE. Error while subscribing to '||
                      'XDP_FULFILLMENT_DONE Event . Error :- ' ||substr(l_error_message,1,2000) ;
        raise e_SUBSCRIBE_FOR_EVENT;
     END IF;

     resultout := 'NOTIFIED';

EXCEPTION
     WHEN e_subscribe_for_event THEN
          wf_core.context('XDPCORE_OM', 'SUBSCRIBE_SRV_FULFILLMENT_DONE', itemtype, itemkey,to_char(actid), x_progress);
          RAISE;
     WHEN others THEN
          x_progress := sqlcode|| ' - '||sqlerrm ;
          wf_core.context('XDP_OM_UTIL','SUBSCRIBE_SRV_FULFILLMENT_DONE',itemtype,itemkey,actid,x_progress) ;
          RAISE;
END SUBSCRIBE_SRV_FULFILLMENT_DONE ;


-- ****************    SUBSCRIBE_XDP_LINE_DONE   *********************

PROCEDURE SUBSCRIBE_XDP_LINE_DONE
                         (itemtype   IN  VARCHAR2,
                          itemkey    IN  VARCHAR2,
                          actid      IN  NUMBER,
                          resultout  OUT NOCOPY VARCHAR2 ) IS

l_reference_id         NUMBER ;
l_message_type         VARCHAR2(40) := 'XDP_LINE_DONE';
l_fa_instance_id       NUMBER;
l_workitem_instance_id NUMBER ;
l_order_id             NUMBER;
l_error_code           NUMBER;
l_error_message        VARCHAR2(4000);
l_activity_name        VARCHAR2(400);
l_process_reference    VARCHAR2(1000);
x_progress             VARCHAR2(4000);
e_subscribe_for_event  EXCEPTION;

BEGIN

     l_reference_id      := to_number(itemkey);
     l_activity_name     := wf_engine.GETACTIVITYLABEL(actid);
     l_process_reference := itemtype||':'||itemkey||':'||l_activity_name;

     XNP_STANDARD.SUBSCRIBE_FOR_EVENT
              (p_MESSAGE_TYPE         => l_MESSAGE_TYPE
              ,p_WORKITEM_INSTANCE_ID => l_WORKITEM_INSTANCE_ID
              ,p_CALLBACK_REF_ID      => l_REFERENCE_ID
              ,p_PROCESS_REFERENCE    => l_PROCESS_REFERENCE
              ,p_ORDER_ID             => l_ORDER_ID
              ,p_FA_INSTANCE_ID       => l_FA_INSTANCE_ID
              ,x_ERROR_CODE           => l_ERROR_CODE
              ,x_ERROR_MESSAGE        => l_ERROR_MESSAGE );

     IF l_error_code <> 0 THEN
        x_progress := 'In XDP_OM_UTIL.SUBSCRIBE_XDP_LINE_DONE. Error while subscribing to '||
                      'XDP_LINE_DONE Event . Error :- ' ||substr(l_error_message,1,2000) ;
        raise e_SUBSCRIBE_FOR_EVENT;
     END IF;

     resultout := 'NOTIFIED';

EXCEPTION
     WHEN e_subscribe_for_event THEN
          wf_core.context('XDPCORE_OM', 'SUBSCRIBE_XDP_LINE_DONE', itemtype, itemkey,to_char(actid), x_progress);
          RAISE;
     WHEN others THEN
          x_progress := sqlcode ||' - ' ||sqlerrm ;
          wf_core.context('XDP_OM_UTIL','SUBSCRIBE_XDP_LINE_DONE',itemtype,itemkey,actid,x_progress ) ;
          RAISE;
END SUBSCRIBE_XDP_LINE_DONE ;

-- ****************    IS_ACTIVATION_REQD   *********************

FUNCTION IS_ACTIVATION_REQD
                    (p_line_id IN NUMBER) RETURN BOOLEAN IS

l_inventory_item_id NUMBER ;
l_organization_id   NUMBER ;
l_activation_flag   VARCHAR2(1) := 'N' ;
x_progress          VARCHAr2(4000);

BEGIN

  SELECT NVL( msi.comms_activation_reqd_flag,'N')
    INTO l_activation_flag
    FROM oe_order_lines_all l,
         mtl_system_items_b msi
   WHERE l.line_id = p_line_id
     AND msi.inventory_item_id = l.inventory_item_id
     AND msi.organization_id   = l.ship_from_org_id   ;

  IF l_activation_flag = 'Y' THEN
     RETURN TRUE ;
  ELSE
     RETURN FALSE ;
  END IF ;

EXCEPTION
     WHEN others THEN
          x_progress := sqlcode ||' - ' ||sqlerrm  ;
          wf_core.context('XDP_OM_UTIL','SUBSCRIBE_SERVICE_FULFILLMENT_DONE',null,null,null,x_progress ) ;
          RAISE;

END IS_ACTIVATION_REQD ;


-- ****************    HandleOtherWFFuncmode   *********************


FUNCTION HandleOtherWFFuncmode( funcmode in varchar2) RETURN VARCHAR2 IS

resultout            VARCHAR2(30);
x_progress           VARCHAR2(4000);

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

END HandleOtherWFFuncmode;


End XDP_OM_UTIL;

/
