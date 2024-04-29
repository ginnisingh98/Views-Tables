--------------------------------------------------------
--  DDL for Package Body XDPCORE_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_OM" AS
/* $Header: XDPCORMB.pls 120.4 2006/07/05 05:31:04 dputhiye ship $ */


/****   Global Variables ****/

g_order_header    XDP_TYPES.SERVICE_ORDER_HEADER ;
g_order_line_list XDP_TYPES.SERVICE_ORDER_LINE_LIST ;

/**** All Private Procedures for the Package ****/

PROCEDURE CreateFulfillmentOrder(itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid      IN NUMBER,
                                 resultout OUT NOCOPY VARCHAR2) ;

PROCEDURE GetHeaderDetails(p_header_id         IN  NUMBER ,
                           x_return_code       OUT NOCOPY NUMBER ,
                           x_error_description OUT NOCOPY VARCHAR2 );

PROCEDURE GetLineDetails(p_header_id         IN  NUMBER ,
                         x_return_code       OUT NOCOPY NUMBER ,
                         x_error_description OUT NOCOPY VARCHAR2 );

PROCEDURE WaitForFulfillment(itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER ,
                             resultout  OUT NOCOPY VARCHAR2);

PROCEDURE PublishXDPFulfillDone(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2) ;

PROCEDURE IsFulfillmentCompleted(itemtype     IN VARCHAR2,
                                 itemkey      IN VARCHAR2,
                                 actid        IN NUMBER,
                                 resultout OUT NOCOPY VARCHAR2);

PROCEDURE ProvisionLine(itemtype   IN VARCHAR2,
                         itemkey    IN VARCHAR2,
                         actid      IN NUMBER,
                         resultout OUT NOCOPY VARCHAR2);

PROCEDURE UpdateTxnDetails
                     (itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      resultout OUT NOCOPY VARCHAR2) ;

PROCEDURE PublishXDPFulfillStart(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2) ;


-- ****************    CREATE_FULFILLMENT_ORDER   *********************


PROCEDURE CREATE_FULFILLMENT_ORDER
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);

BEGIN

-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
               CreateFulfillmentOrder(itemtype, itemkey, actid, l_resultout);
               resultout := l_resultout ;
               return;
        ELSE
               resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
               return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'CREATE_FULFILLMENT_ORDER', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END CREATE_FULFILLMENT_ORDER ;

-- ****************    WAIT_FOR_FULFILLMENT   *********************

PROCEDURE WAIT_FOR_FULFILLMENT
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);

BEGIN

-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
               WaitForFulfillment(itemtype, itemkey, actid, l_resultout);
               resultout := l_resultout ;
               return;
        ELSE
               resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
               return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'WAIT_FOR_FULFILLMENT', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END WAIT_FOR_FULFILLMENT ;


-- ****************    IS_PROVISIONING_REQD   *********************

PROCEDURE IS_FULFILLMENT_COMPLETED
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);

BEGIN


-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
               IsFulfillmentCompleted(itemtype, itemkey, actid , l_resultout);
               resultout := 'COMPLETE' ;
               return;
        ELSE
               resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
               return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'IS_PROVISIONING_REQD', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END IS_FULFILLMENT_COMPLETED ;

-- ****************    PROVISION_LINE   *********************


PROCEDURE PROVISION_LINE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);


BEGIN

        IF (funcmode = 'RUN') THEN
               ProvisionLine(itemtype, itemkey,actid,resultout);
               resultout := resultout ;
               return;
        ELSE
                resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'PROVISION_LINE', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END PROVISION_LINE ;


-- ****************    LINE_FULFILLMENT_DONE   *********************

PROCEDURE LINE_FULFILLMENT_DONE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);


BEGIN

        IF (funcmode = 'RUN') THEN
               PublishXDPFulfillDone(itemtype, itemkey);
               resultout := 'COMPLETE:ACTIVITY_PERFORMED';
               return;
        ELSE
                resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'LINE_FULFILLMENT_DONE', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END LINE_FULFILLMENT_DONE ;


-- ****************    UPDATE_TXN_DETAILS   *********************

PROCEDURE UPDATE_TXN_DETAILS
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress     VARCHAR2(4000);
l_resultout    VARCHAR2(240);


BEGIN

        IF (funcmode = 'RUN') THEN

           UpdateTxnDetails
                     (itemtype   => update_txn_details.itemtype,
                      itemkey    => update_txn_details.itemkey,
                      actid      => update_txn_details.actid ,
                      resultout  => l_resultout );
           resultout := l_resultout ; -- 'COMPLETE' ;
           return;
        ELSE
           resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
           return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'UPDATE_TXN_DETAILS', itemtype, itemkey, to_char(actid), funcmode);
          raise;

END UPDATE_TXN_DETAILS;


-- ****************    UPDATE_OM_LINE_STATUS   *********************

PROCEDURE UPDATE_OM_LINE_STATUS
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) IS

x_progress           VARCHAR2(4000);
l_resultout          VARCHAR2(240);
l_line_id            NUMBER       := to_number(itemkey);
e_exception          EXCEPTION;
l_org_id             NUMBER;

BEGIN

        IF (funcmode = 'RUN') THEN

         -- Update OM Line Flow Status to 'Provisioning Succeeded'


           l_org_id := wf_engine.GetItemAttrNumber( itemtype => update_om_line_status.itemtype,
                                                    itemkey  => update_om_line_status.itemkey,
                                                    aname    => 'ORG_ID');

	   -- Date: 15 FEB 2006. Author: DPUTHIYE BUG#: 5023342
           -- Change description: Replaced the call to set_client_info with MO_GLOBAL.set_policy_context(..)
           -- Other files impacted: None.

	   --dbms_application_info.set_client_info(l_org_id);
	   MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => l_org_id);

	   OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                          (p_line_id            => l_line_id,
                           p_flow_status_code   => 'PROV_SUCCESS',
                           x_return_status      => l_resultout );

           IF l_resultout = 'S' THEN
              resultout := 'COMPLETE';
              return;
           ELSE
              x_progress := 'Error While OM Order Line Status for Line  : (Line ID = '||l_line_id||' - ' ||sqlerrm||' )' ;
              RAISE e_exception ;
           END IF ;


        ELSE
           resultout := xdp_om_util.HandleOtherWFFuncmode(funcmode);
           return;
        END IF;



EXCEPTION
     WHEN e_exception THEN
          wf_core.context('XDPCORE_OM', 'UPDATE_OM_LINE_STATUS', itemtype, itemkey, to_char(actid), x_progress);
          raise;
     WHEN OTHERS THEN
          x_progress := SQLCODE||' - ' ||SQLERRM ;
          wf_core.context('XDPCORE_OM', 'UPDATE_OM_LINE_STATUS', itemtype, itemkey, to_char(actid), x_progress);
          raise;

END UPDATE_OM_LINE_STATUS ;


-- ****************    START_FULFILLMENT_PROCESS  *********************


PROCEDURE START_FULFILLMENT_PROCESS
                (p_MESSAGE_ID           IN NUMBER ,
                 p_PROCESS_REFERENCE    IN VARCHAR2 ,
                 x_ERROR_CODE          OUT NOCOPY NUMBER ,
                 x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2) IS

 l_msg_text             VARCHAR2(32767) ;
 l_msg_header           XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
 l_sdp_result_code      VARCHAR2(20)   := NULL;
 l_item_type            VARCHAR2(256)  := 'XDPOMINT';
 l_item_key             VARCHAR2(256)  ;
 l_notification_role    VARCHAR2(256)  ;
 l_line_id              VARCHAR2(40) ;
 x_progress             VARCHAR2(4000);
 l_org_id               NUMBER ;
 l_order_number         NUMBER ;

BEGIN

savepoint start_fulfillment ;

   x_error_code := 0 ;
   x_error_message := NULL ;

   XNP_MESSAGE.GET(p_msg_id     => p_message_id,
                   x_msg_header => l_msg_header,
                   x_msg_text   => l_msg_text);

   XNP_XML_UTILS.DECODE (l_msg_text,'LINE_ID',l_line_id);

   l_item_key := l_line_id ;

   SELECT NVL(l.org_id,h.org_id), h.order_number
     INTO l_org_id,l_order_number
     FROM oe_order_lines_all l,
          oe_order_headers_all h
    WHERE l.line_id   = to_number(l_line_id)
      AND l.header_id = h.header_id  ;


   WF_ENGINE.CREATEPROCESS(itemtype => l_item_type,
                           itemkey  => l_item_key ,
                           process  => 'XDP_OM_INTERFACE');

   WF_ENGINE.SetItemAttrNumber(itemtype => l_item_type ,
                               itemkey  => l_item_key ,
                               aname    => 'LINE_ID',
                               avalue   => l_item_key );

   WF_ENGINE.SetItemAttrNumber(itemtype => l_item_type ,
                               itemkey  => l_item_key ,
                               aname    => 'ORG_ID',
                               avalue   => l_org_id );

   WF_ENGINE.SetItemAttrNumber(itemtype => l_item_type ,
                               itemkey  => l_item_key ,
                               aname    => 'ORDER_NUMBER',
                               avalue   => l_order_number );

   WF_ENGINE.StartProcess(l_item_type, l_item_key);

EXCEPTION
     WHEN others THEN
          x_progress := SQLCODE||' - ' ||SQLERRM ;
          wf_core.context('XDPCORE_OM','START_FULFILLMENT_PROCESS',l_item_type, l_item_key,null,x_progress);
          rollback to start_fulfillment ;
          RAISE;
END START_FULFILLMENT_PROCESS ;


-- ****************  ALL PRIVATE PROCEDURES       *********************

-- ****************    CreateFulfillmentOrder   *********************

PROCEDURE CreateFulfillmentOrder(itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid         IN NUMBER,
                                 resultout OUT NOCOPY VARCHAR2) IS

 x_Progress            VARCHAR2(4000);
 l_resultout           VARCHAR2(4000) ;
 l_header_id           NUMBER ;
 l_return_code         NUMBER ;
 l_error_description   VARCHAR2(4000);
 l_sfm_order_id        NUMBER;
 l_order_param_list    XDP_TYPES.SERVICE_ORDER_PARAM_LIST ;
 l_line_param_list     XDP_TYPES.SERVICE_LINE_PARAM_LIST ;
 l_msg_list            VARCHAR2(20);
 l_msg_count           NUMBER;
 l_return_status       VARCHAR2(20) := 'S';
 e_exception           EXCEPTION;

-- l_plsql_stmt         VARCHAR2(32000) := null;

 CURSOR c_lines(p_header_id NUMBER) IS
        SELECT line_id ,
               flow_status_code
          FROM oe_order_lines_all  l
         WHERE l.header_id = p_header_id ;

BEGIN

---  Get header information and create fulfillment order header  --

     g_order_header    := null ;
     g_order_line_list.DELETE ;

     l_return_code     := 0 ;
     l_error_description := null ;

     l_header_id := to_number (itemkey);

     GetHeaderDetails(p_header_id         => l_header_id ,
                      x_return_code       => l_return_code ,
                      x_error_description => l_error_description );

     IF l_return_code <> 0 THEN
        FND_MESSAGE.SET_NAME('XDP','XDP_UNABLE_TO_CREATE_SFM_ORDER');
        FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_return_code);
        FND_MESSAGE.SET_TOKEN('ERROR_DESC',l_error_description);
        OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.Add;

        resultout := 'INCOMPLETE' ;
        return;
     END IF ;

     GetLineDetails(p_header_id         => l_header_id ,
                    x_return_code       => l_return_code ,
                    x_error_description => l_error_description );

     IF l_return_code <> 0 THEN
        FND_MESSAGE.SET_NAME('XDP','XDP_UNABLE_TO_CREATE_SFM_ORDER');
        FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_return_code);
        FND_MESSAGE.SET_TOKEN('ERROR_DESC',l_error_description);
        OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.Add;

        resultout := 'INCOMPLETE' ;
        return;
     END IF ;

     IF  g_order_line_list.COUNT > 0 THEN

        XDP_INTERFACES_PUB.PROCESS_ORDER (P_API_VERSION      => 11,
                                          P_INIT_MSG_LIST    => l_msg_list,
                                          P_COMMIT           => FND_API.G_FALSE,
                                          P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                                          P_ORDER_HEADER     => g_order_header,
                                          P_ORDER_PARAM_LIST => l_order_param_list,
                                          P_ORDER_LINE_LIST  => g_order_line_list,
                                          P_LINE_PARAM_LIST  => l_line_param_list,
                                          X_RETURN_STATUS    => l_return_status,
                                          X_MSG_COUNT        => l_msg_count,
                                          X_MSG_DATA         => l_error_description,
                                          X_ERROR_CODE       => l_return_code,
                                          X_ORDER_ID         => l_sfm_order_id);
        IF l_return_status = 'S' THEN
--           FND_MESSAGE.SET_NAME('XDP','XDP_CREATED_SFM_ORDER');
--           FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',g_order_header.order_number||'('||g_order_header.order_version||')');
--           FND_MESSAGE.SET_TOKEN('ORDER_ID',l_sfm_order_id );
--           OE_STANDARD_WF.Set_Msg_Context(actid);
--           OE_MSG_PUB.Add;

           -- Update line status to 'PROV_REQUEST' if the line status is 'PROV_FAILED'

           FOR c_lines_rec IN c_lines(l_header_id )
               LOOP
                  IF C_lines_rec.flow_status_code = 'PROV_FAILED' THEN

                     OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                          (p_line_id            => C_lines_rec.line_id,
                           p_flow_status_code   => 'PROV_REQUEST',
                           x_return_status      => l_resultout );

                  END IF ;

                  IF l_resultout <> 'S' THEN
                     x_progress := 'Error While updating OM Order Line Flow status ';
                     RAISE e_exception ;
                  END IF ;

               END LOOP ;

           resultout := 'COMPLETE' ;
        ELSE
           -- Update line status to 'PROV_REQUEST' if the line status is 'PROV_FAILED'

           FOR c_lines_rec IN c_lines(l_header_id )
               LOOP
                  IF C_lines_rec.flow_status_code = 'PROV_REQUEST' THEN

                     OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                          (p_line_id            => C_lines_rec.line_id,
                           p_flow_status_code   => 'PROV_FAILED',
                           x_return_status      => l_resultout );

                  END IF;

                  IF l_resultout <> 'S' THEN
                     x_progress := 'Error While updating OM Order Line Flow status ';
                     RAISE e_exception ;
                  END IF ;

               END LOOP ;

           -- Set massage stack

           FND_MESSAGE.SET_NAME('XDP','XDP_UNABLE_TO_CREATE_SFM_ORDER');
           FND_MESSAGE.SET_TOKEN('ERROR_CODE',l_return_code);
           FND_MESSAGE.SET_TOKEN('ERROR_DESC',l_error_description);
           OE_STANDARD_WF.Set_Msg_Context(actid);
           OE_MSG_PUB.Add;

           resultout := 'INCOMPLETE' ;
           return;
        END IF ;

     -- Date:30 JUN 05	BUG#:4410080 (FP Fix for: 4383953)
     -- Change: Added the following else clause.
     -- Other files impacted: None.
     ELSE	--g_order_line_list.COUNT = 0
        --Return complete, even if there are no provisionable items in order.
        resultout := 'COMPLETE' ;
     END IF ;

EXCEPTION
     WHEN e_exception THEN
          wf_core.context('XDPCORE_OM', 'CreateFulfillmentOrder',itemtype,itemkey,actid,x_progress);
          raise ;
     WHEN OTHERS THEN
          wf_core.context('XDPCORE_OM', 'CreateFulfillmentOrder', itemtype, itemkey,null,null);
          raise;
END  CreateFulfillmentOrder ;

-- ****************    GetHeaderDetails   *********************

PROCEDURE GetHeaderDetails(p_header_id         IN  NUMBER ,
                           x_return_code       OUT NOCOPY NUMBER ,
                           x_error_description OUT NOCOPY VARCHAR2 ) IS

CURSOR c_header IS
       SELECT order_number ,
              version_number ,
              request_date ,
              expiration_date ,
              header_id ,
              sold_to_contact_id,
              sold_to_org_id ,
              org_id
         FROM oe_order_headers_all
        WHERE header_id = p_header_id ;
BEGIN
x_return_code := 0 ;
x_error_description := null;

     FOR c_header_rec IN  c_header
         LOOP
            g_order_header.required_fulfillment_date :=  NVL(c_header_rec.request_date,sysdate) ;
            g_order_header.priority                  :=  100 ;
            g_order_header.jeopardy_enabled_flag     :=  'N';
            g_order_header.execution_mode            :=  'ASYNC' ;
            g_order_header.due_date                  :=  c_header_rec.expiration_date;
            g_order_header.customer_required_date    :=  c_header_rec.request_date ;
            g_order_header.order_source              :=  'OE_ORDER_HEADERS_ALL' ;
            g_order_header.order_ref_name            :=  'SALES' ;
            g_order_header.order_ref_value           :=  c_header_rec.header_id ;
            g_order_header.order_number              :=  c_header_rec.order_number;
            g_order_header.order_version             :=  c_header_rec.version_number;
            g_order_header.cust_account_id           :=  c_header_rec.sold_to_org_id;
            g_order_header.org_id                    :=  c_header_rec.org_id ;

         END LOOP ;

EXCEPTION
     WHEN OTHERS THEN
          x_return_code := sqlcode ;
          x_error_description := sqlerrm ;
END GetHeaderDetails ;


-- ****************  GetLineDetails    *********************

PROCEDURE GetLineDetails(p_header_id         IN  NUMBER  ,
                         x_return_code       OUT NOCOPY NUMBER  ,
                         x_error_description OUT NOCOPY VARCHAR2 ) IS

CURSOR c_top_lines IS
       SELECT l.line_id  ,
              l.line_number ,
              l.header_id ,
              l.line_type_id ,
              l.ship_from_org_id ,
              l.schedule_ship_date,
              l.promise_date ,
              l.request_date ,
              l.top_model_line_id ,
              l.link_to_line_id ,
              l.inventory_item_id ,
              l.configuration_id,
              l.config_header_id,
              l.config_rev_nbr,
              l.sort_order
         FROM oe_order_lines_all l
        WHERE l.header_id = p_header_id
          AND l.link_to_line_id IS NULL
        ORDER BY l.line_number ;

CURSOR c_child_lines(p_top_line_id NUMBER) IS
       SELECT l.line_id  ,
              l.line_number ,
              l.header_id ,
              l.line_type_id ,
              l.ship_from_org_id ,
              l.schedule_ship_date,
              l.promise_date ,
              l.request_date ,
              l.top_model_line_id ,
              l.link_to_line_id ,
              l.inventory_item_id ,
              l.configuration_id,
              l.config_header_id,
              l.config_rev_nbr,
              l.sort_order
         FROM oe_order_lines_all l
        WHERE l.header_id = p_header_id
          AND l.top_model_line_id = p_top_line_id
          AND l.link_to_line_id IS NOT NULL
          AND l.line_id <> p_top_line_id
        ORDER BY l.sort_order ;


l_init_seq        NUMBER := 10 ;
l_next_seq        NUMBER := 0 ;
l_seq             NUMBER := 0;
l_prev_sort_order OE_ORDER_LINES_ALL.SORT_ORDER%TYPE ;
l_line_count      NUMBER := 0;
l_line_type       VARCHAR2(40) ;

BEGIN
x_return_code       := 0;
x_error_description := null;

  FOR c_top_rec IN c_top_lines
      LOOP
          IF xdp_om_util.Is_Activation_Reqd(p_line_id => c_top_rec.line_id) THEN

             -- The top line is not a package and needs activation.

             g_order_line_list(l_line_count).line_number                := c_top_rec.line_id ;
             g_order_line_list(l_line_count).line_source                := 'OE_ORDER_LINES_ALL' ;
             g_order_line_list(l_line_count).inventory_item_id          := c_top_rec.inventory_item_id  ;
             g_order_line_list(l_line_count).action_code                := c_top_rec.line_type_id ;
             g_order_line_list(l_line_count).organization_id            := c_top_rec.ship_from_org_id  ;
             g_order_line_list(l_line_count).ib_source                  := 'TXN' ;
             g_order_line_list(l_line_count).ib_source_id               := c_top_rec.line_id ;
             g_order_line_list(l_line_count).required_fulfillment_date  := NVL(TRUNC(c_top_rec.schedule_ship_date),c_top_rec.request_date) ;
             g_order_line_list(l_line_count).fulfillment_required_flag  := 'Y' ;
             g_order_line_list(l_line_count).is_package_flag            := 'N' ;
             g_order_line_list(l_line_count).fulfillment_sequence       := l_init_seq ;
             g_order_line_list(l_line_count).priority                   := 100 ;
             g_order_line_list(l_line_count).due_date                   := c_top_rec.promise_date ;
             g_order_line_list(l_line_count).jeopardy_enabled_flag      := 'N' ;
             g_order_line_list(l_line_count).customer_required_date     := c_top_rec.request_date ;
             g_order_line_list(l_line_count).is_virtual_line_flag       := 'N' ;

             l_line_count      := l_line_count + 1 ;
             l_next_seq        := l_init_seq ;

          END IF ;

          l_prev_sort_order := c_top_rec.sort_order;

          FOR c_child_rec IN c_child_lines(c_top_rec.line_id)
              LOOP

                IF xdp_om_util.Is_Activation_Reqd(p_line_id => c_child_rec.line_id) THEN

                   IF l_prev_sort_order <> c_child_rec.sort_order THEN
                      l_next_seq        := l_next_seq + 10;
                      l_prev_sort_order := c_child_rec.sort_order ;
                   END IF ;

                   g_order_line_list(l_line_count).line_number                := c_child_rec.line_id ;
                   g_order_line_list(l_line_count).line_source                := 'OE_ORDER_LINES_ALL' ;
                   g_order_line_list(l_line_count).inventory_item_id          := c_child_rec.inventory_item_id  ;
                   g_order_line_list(l_line_count).action_code                := c_child_rec.line_type_id ;
                   g_order_line_list(l_line_count).organization_id            := c_child_rec.ship_from_org_id  ;
                   g_order_line_list(l_line_count).ib_source                  := 'TXN' ;
                   g_order_line_list(l_line_count).ib_source_id               := c_child_rec.line_id ;
                   g_order_line_list(l_line_count).required_fulfillment_date  := NVL(TRUNC(c_child_rec.schedule_ship_date),c_child_rec.request_date) ;
                   g_order_line_list(l_line_count).fulfillment_required_flag  := 'Y' ;
                   g_order_line_list(l_line_count).is_package_flag            := 'N' ;
                   g_order_line_list(l_line_count).fulfillment_sequence       := l_next_seq ;
                   g_order_line_list(l_line_count).priority                   := 100 ;
                   g_order_line_list(l_line_count).due_date                   := c_child_rec.promise_date ;
                   g_order_line_list(l_line_count).jeopardy_enabled_flag      := 'N' ;
                   g_order_line_list(l_line_count).customer_required_date     := c_child_rec.request_date ;
                   g_order_line_list(l_line_count).is_virtual_line_flag       := 'N' ;

                   l_line_count := l_line_count + 1 ;
                END IF ;

             END LOOP ;
      END LOOP ;

EXCEPTION
     WHEN OTHERS THEN
          x_return_code       := 0;
          x_error_description := null;
END GetLineDetails ;


-- ****************    WaitForFulfillment   *********************


PROCEDURE WaitForFulfillment(itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER ,
                             resultout  OUT NOCOPY VARCHAR2) IS

l_line_id           NUMBER          := to_number(itemkey);
l_ordeR_id          NUMBER          := to_number(null) ;
l_itemtype          VARCHAR2(240)   := 'XDPOMINT';
l_itemkey           VARCHAR2(240)   := itemkey;
l_resultout         VARCHAR2(240) ;
l_flow_status_code  VARCHAR2(30)    := 'PROV_REQUEST';
e_exception         EXCEPTION;
x_progress          VARCHAR2(4000);
l_org_id            NUMBER ;

BEGIN

     IF XDP_OM_UTIL.IS_ACTIVATION_REQD(p_line_id => l_line_id) THEN


        -- Publish SFM Fulfillment Start Event to start an SFM - OM Interface WF Process.

       l_org_id := wf_engine.GetItemAttrNumber( itemtype => WaitForFulfillment.itemtype,
                                                itemkey  => WaitForFulfillment.itemkey,
                                                aname    => 'ORG_ID');

       -- Date: 15 FEB 2006. Author: DPUTHIYE BUG#: 5023342
       -- Change description: Replaced the call to set_client_info with MO_GLOBAL.set_policy_context(..)
       -- Since this activity will be invoked from OEOL flows, current org is checked before setting it.
       -- Other files impacted: None.

       --dbms_application_info.set_client_info(l_org_id);
       IF ( NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id) THEN
	       MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => l_org_id);
       END IF;

       OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                          (p_line_id            => l_line_id,
                           p_flow_status_code   => 'PROV_REQUEST',
                           x_return_status      => l_resultout );


           IF l_resultout <> 'S' THEN
              x_progress := 'Error While updating OM Order Line Flow status ';
              RAISE e_exception ;
           END IF ;

        -- Publish XDP_FULFILL_START event to create SFM-OM Interface WF process as a part of it's sbscription .

        PublishXDPFulfillStart(itemtype  =>  WaitForFulfillment.itemtype,
                               itemkey   =>  WaitForFulfillment.itemkey );

        -- Subscribe to Fulfillment Done Event with reference Id as OM order line_id

        XDP_OM_UTIL.SUBSCRIBE_SRV_FULFILLMENT_DONE
                  (itemtype => itemtype ,
                   itemkey  => itemkey ,
                   actid    => actid ,
                   resultout=> l_resultout) ;

        resultout := l_resultout ;

     ELSE resultout := 'COMPLETE' ;
     END IF ;

EXCEPTION
     WHEN e_exception THEN
          wf_core.context('XDPCORE_OM', 'WaitForFulfillment',itemtype,itemkey,actid,x_progress);
          raise ;
     WHEN others THEN
          x_progress := sqlcode ||' - ' ||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'WaitForFulfillment',itemtype,itemkey,actid,x_progress );
          raise ;
END WaitForFulfillment ;

-- ****************    PublishXDPFulfillDone   *********************

PROCEDURE PublishXDPFulfillDone(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2) IS

 l_line_id           NUMBER ;
 l_message_id        NUMBER ;
 l_error_code        NUMBER ;
 l_error_message     VARCHAR2(4000);
 x_progress          VARCHAR2(4000);

 e_publish_exception EXCEPTION ;

BEGIN

    l_line_id := to_number(itemkey) ;

    XNP_XDP_FULFILL_DONE_U.PUBLISH
                   (P_REFERENCE_ID       => l_line_id  ,
                    X_MESSAGE_ID         => l_message_id  ,
                    X_ERROR_CODE         => l_error_code  ,
                    X_ERROR_MESSAGE      => l_error_message );

    IF l_error_code <> 0 THEN
       x_progress := 'In XDPCORE_OM.PublishXDPFulfillDone. Error while publishing XDP_FULFILL_DONE . Error :- ' ||l_error_message ;
       RAISE e_publish_exception ;
    END IF ;

EXCEPTION
     WHEN e_publish_exception THEN
           wf_core.context('XDPCORE_OM', 'PublishXDPFulfillDone', itemtype, itemkey, null, x_Progress);
           raise;
     WHEN OTHERS THEN
          x_progress := sqlcode|| ' - '||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'PublishXDPFulfillDone', itemtype, itemkey,null,x_progress);
          raise;
END PublishXDPFulfillDone;


-- ****************    ProvisionLine   *********************

PROCEDURE ProvisionLine(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        resultout OUT NOCOPY VARCHAR2) IS

l_line_id        NUMBER := to_number(itemkey);
l_resultout      VARCHAR2(40) := null;
x_progress       VARCHAR2(4000);
l_org_id         NUMBER;

BEGIN
     -- Check if the line provisioning is already completed

          IsFulfillmentCompleted
                       (itemtype  => ProvisionLine.itemtype,
                        itemkey   => ProvisionLine.itemkey ,
                        actid     => ProvisionLine.actid   ,
                        resultout => l_resultout ) ;

     IF l_resultout = 'LINE_COMPLETE' THEN
        l_resultout := 'COMPLETE' ;
     ELSE
        IF l_resultout = 'LINE_NOT_FOUND' THEN

            -- Update OM Line Flow Status to 'Provisioning Failed'

              l_org_id := wf_engine.GetItemAttrNumber( itemtype => ProvisionLine.itemtype,
                                                       itemkey  => ProvisionLine.itemkey,
                                                       aname    => 'ORG_ID');

              dbms_application_info.set_client_info(l_org_id);

              OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                             (p_line_id            => l_line_id,
                              p_flow_status_code   => 'PROV_FAILED',
                              x_return_status      => l_resultout );
        END IF ;

         -- Subscribe to XDP_LINE_DONE event to be published by SFM order line

         XDP_OM_UTIL.SUBSCRIBE_XDP_LINE_DONE
                            (itemtype   => ProvisionLine.itemtype,
                             itemkey    => ProvisionLine.itemkey ,
                             actid      => ProvisionLine.actid   ,
                             resultout  => l_resultout  );
     END IF ;

     resultout := l_resultout ;

EXCEPTION
     WHEN others THEN
          x_progress := sqlcode|| ' - '||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'ProvisionLine',itemtype,itemkey,actid,x_progress);
          raise;
END ProvisionLine ;


-- ****************    IsFulfillmentCompleted   *********************

PROCEDURE IsFulfillmentCompleted(itemtype     IN VARCHAR2,
                                 itemkey      IN VARCHAR2,
                                 actid        IN NUMBER,
                                 resultout   OUT NOCOPY VARCHAR2) IS

l_line_id        NUMBER := to_number(itemkey);
l_order_number   NUMBER ;
l_order_version  VARCHAR2(30);
l_header_id      NUMBER;
l_line_status    VARCHAR2(40);
l_resultout      VARCHAR2(40);
l_line_item_id   NUMBER;
l_order_id       NUMBER;
x_progress       VARCHAR2(4000) ;

BEGIN

     SELECT h.order_number ,
            NVL(h.version_number,'1.0') ,
            h.header_id
       INTO l_order_number ,
            l_order_version ,
            l_header_id
       FROM oe_order_lines_all l ,
            oe_order_headers_all h
      WHERE l.line_id = l_line_id
        AND l.header_id = h.header_id ;

     BEGIN

            SELECT l.status_code,
                   l.line_item_id,
                   l.order_id
              INTO l_line_status ,
                   l_line_item_id,
                   l_order_id
              FROM xdp_order_headers h,
                    xdp_order_line_items l
             WHERE h.external_order_number  = to_char(l_order_number)
               AND h.external_order_version = l_order_version
               AND h.order_ref_name         = 'SALES'
               AND h.order_id               = l.order_id
               AND l.line_number            = l_line_id ;
     EXCEPTION
           WHEN no_data_found THEN
                l_resultout := 'LINE_NOT_FOUND';
     END ;


     IF l_line_status IN ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELLED') THEN
        l_resultout := 'LINE_COMPLETE';
     ELSE
        l_resultout := 'LINE_INCOMPLETE';
     END IF;

     IF l_line_item_id IS NOT NULL THEN

        WF_ENGINE.SetItemAttrNumber(itemtype => IsFulfillmentCompleted.itemtype ,
                                    itemkey  => IsFulfillmentCompleted.itemkey  ,
                                    aname    => 'LINE_ITEM_ID',
                                    avalue   => l_line_item_id );
     END IF ;

     IF  l_order_id IS NOT NULL THEN

        WF_ENGINE.SetItemAttrNumber(itemtype => IsFulfillmentCompleted.itemtype ,
                                    itemkey  => IsFulfillmentCompleted.itemkey  ,
                                    aname    => 'ORDER_ID',
                                    avalue   => l_order_id );
     END IF ;

     resultout := l_resultout ;

EXCEPTION
     WHEN others THEN
          x_progress := sqlcode || ' - '||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'IsFulfillmentCompleted',itemtype,itemkey,actid,x_progress);
          raise;

END IsFulfillmentCompleted ;

-- ****************    UpdateTxnDetails   *********************

PROCEDURE UpdateTxnDetails
                     (itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER ,
                      resultout OUT NOCOPY VARCHAR2) IS

 l_line_id       NUMBER := to_number(itemkey);
 l_order_number  NUMBER ;
 l_order_version NUMBER ;
 l_header_id     NUMBER ;
 l_order_id      NUMBER;
 l_line_item_id  NUMBER;
 l_errCode       NUMBER          :=  0;
 l_errStr        VARCHAR2(1996)  :=  NULL;
 e_exception     EXCEPTION ;
 x_progress      VARCHAR2(2000) ;
 l_error_description VARCHAR2(2000);
 l_resultout    VARCHAR2(2000);
 l_org_id        NUMBER;

BEGIN

    l_order_id    := wf_engine.GetItemAttrNumber(itemtype => UpdateTxnDetails.itemtype,
                                                 itemkey  => UpdateTxnDetails.itemkey,
                                                 aname    => 'ORDER_ID');

    l_line_item_id := wf_engine.GetItemAttrNumber(itemtype => UpdateTxnDetails.itemtype,
                                                  itemkey  => UpdateTxnDetails.itemkey,
                                                  aname    => 'LINE_ITEM_ID');


    IF l_order_id IS NOT NULL AND
       l_line_item_id IS NOT NULL THEN

       XDP_INSTALL_BASE.UPDATE_IB(p_order_id     => l_order_id,
                                  p_line_id      => l_line_item_id,
                                  p_error_code   => l_errcode,
                                  p_error_description => l_error_description);
    ELSE

        SELECT h.order_number ,
               NVL(h.version_number,'1.0') ,
               h.header_id
          INTO l_order_number ,
               l_order_version ,
               l_header_id
          FROM oe_order_lines_all l ,
               oe_order_headers_all h
         WHERE l.line_id   = l_line_id
           AND l.header_id = h.header_id ;

         BEGIN
              SELECT l.line_item_id,
                     l.order_id
                INTO l_line_item_id,
                     l_order_id
                FROM xdp_order_headers h,
                     xdp_order_line_items l
		                        --Date: 05-JUL-2006, Author: DPUTHIYE, Bug#5370624/5222928
					--Description: Implicit conversion of l_order_number and l_order_version to number fails.
					--Dependencies: None.
                                 -- WHERE h.external_order_number  = l_order_number
                                 -- AND h.external_order_version = l_order_version
		 WHERE h.external_order_number  = to_char(l_order_number)
                 AND h.external_order_version = to_char(l_order_version)
                 AND h.order_ref_name         = 'SALES'
                 AND h.order_id               = l.order_id
                 AND l.line_number            = l_line_id ;

         EXCEPTION
              WHEN no_data_found THEN
                   x_progress := 'Could not find specified Fulfillment Order in SFM. Order Number : '|| l_order_number ||' Order Version : '||l_order_version ;
                   RAISE e_exception ;
         END ;

         XDP_INSTALL_BASE.UPDATE_IB(p_order_id     => l_order_id,
                                    p_line_id      => l_line_item_id,
                                    p_error_code   => l_errcode,
                                    p_error_description => l_error_description);

    END IF;

   IF l_errCode <> 0 then
      x_progress  :=  ' Error while updating TXN details for Item Attribute ( Line Item Id = '|| l_line_item_id ||')'||
                        'UpdateTxnDetails. Error: ' || substr(sqlerrm,1,1500);

      WF_ENGINE.SetItemAttrNumber(itemtype => UpdateTxnDetails.itemtype ,
                                  itemkey  => UpdateTxnDetails.itemkey  ,
                                  aname    => 'NOTIF_ERROR_CODE',
                                  avalue   => l_errcode );
                         --Date: 05-JUL-2006, Author: DPUTHIYE, Bug#5370624/5222928
			 --Description: 'NOTIF_ERROR_MESSAGE' is a text attribute.
               --WF_ENGINE.SetItemAttrNumber(itemtype => UpdateTxnDetails.itemtype ,
      WF_ENGINE.SetItemAttrText(itemtype => UpdateTxnDetails.itemtype ,
                                  itemkey  => UpdateTxnDetails.itemkey  ,
                                  aname    => 'NOTIF_ERROR_MESSAGE',
                                  avalue   => l_error_description);


      -- Update OM Line Flow Status to 'Provisioning Failed'

         l_org_id := wf_engine.GetItemAttrNumber( itemtype => UpdateTxnDetails.itemtype,
                                                  itemkey  => UpdateTxnDetails.itemkey,
                                                  aname    => 'ORG_ID');

         dbms_application_info.set_client_info(l_org_id);

         OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                     (p_line_id            => l_line_id,
                      p_flow_status_code   => 'PROV_FAILED',
                      x_return_status      => l_resultout );

      resultout := 'INCOMPLETE' ;
   ELSE

     -- Update OM Line Flow Status to 'Provisioning Requested'

        l_org_id := wf_engine.GetItemAttrNumber( itemtype => UpdateTxnDetails.itemtype,
                                                 itemkey  => UpdateTxnDetails.itemkey,
                                                 aname    => 'ORG_ID');

        dbms_application_info.set_client_info(l_org_id);

        OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                         (p_line_id            => l_line_id,
                          p_flow_status_code   => 'PROV_REQUEST',
                          x_return_status      => l_resultout );

        resultout := 'COMPLETE'   ;
--      RAISE e_exception;
   END IF;

EXCEPTION
     WHEN e_exception THEN
          wf_core.context('XDPCORE_OM', 'UpdateTxnDetails',itemtype,itemkey,actid,x_progress);
          raise ;
     WHEN others THEN
          x_progress := sqlcode || ' - '||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'UpdateTxnDetails',itemtype,itemkey,actid,x_progress);
          raise ;
END UpdateTxnDetails ;

-- ****************    PublishXDPFulfillmentStart   *********************

PROCEDURE PublishXDPFulfillStart(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2) IS

 l_line_id           NUMBER ;
 l_message_id        NUMBER ;
 l_error_code        NUMBER ;
 l_error_message     VARCHAR2(4000);
 x_Progress          VARCHAR2(4000);
 e_publish_exception EXCEPTION ;

BEGIN

    l_line_id := to_number(itemkey) ;

    XNP_XDP_FULFILL_START_U.PUBLISH
                   (XNP$LINE_ID     => l_line_id ,
                    P_REFERENCE_ID  => l_line_id  ,
                    X_MESSAGE_ID    => l_message_id  ,
                    X_ERROR_CODE    => l_error_code  ,
                    X_ERROR_MESSAGE => l_error_message );

    IF l_error_code <> 0 THEN
       x_progress := 'In XDPCORE_OM.PublishXDPFulfillStart. Error while publishing XDP_FULFILL_START .  Error :- ' ||l_error_message ;
       RAISE e_publish_exception ;
    END IF ;

EXCEPTION
     WHEN e_publish_exception THEN
           wf_core.context('XDPCORE_OM', 'PublishXDPFulfillStart', itemtype, itemkey, null, x_Progress);
          raise;
     WHEN OTHERS THEN
          x_progress := sqlcode || ' - '||sqlerrm ;
          wf_core.context('XDPCORE_OM', 'PublishXDPFulfillStart', itemtype, itemkey,null,x_progress);
          raise;
END PublishXDPFulfillStart;


End XDPCORE_OM;

/
