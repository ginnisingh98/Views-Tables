--------------------------------------------------------
--  DDL for Package Body CCT_COLLECTIONROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_COLLECTIONROUTING_PUB" as
/* $Header: cctrcolb.pls 115.7 2003/08/23 01:47:49 gvasvani ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_COLLECTIONROUTING_PUB';

  PROCEDURE isCustomerOverdue (
    itemtype       in varchar2
    , itemkey      in varchar2
    , actid        in number
    , funmode      in varchar2
    , resultout    in out nocopy varchar2
  )
  IS
    l_proc_name      VARCHAR2(30) := 'isCustomerOverdue';
    l_return_status  VARCHAR2(32);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(32);
    l_customer_id    NUMBER;
    l_overdue        BOOLEAN;

  BEGIN
    IF (funmode = 'RUN')
    THEN
      -- Get the customer id from  wf attribute
      l_customer_id  := WF_ENGINE.GetItemAttrNumber (
                          itemtype
                          ,itemkey
                          ,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID
                        );
     /*
      -- Call IEX api to get overdue status of customer
      iex_routing_pvt.isCustomerOverdue (
         p_api_version         => '1'
         , x_return_status     => l_return_status
         , x_msg_count         => l_msg_count
         , x_msg_data          => l_msg_data
         , p_customer_id       => l_customer_id
         , p_customer_overdue  => l_overdue
      );
	 */

      IF l_overdue
      THEN
        -- Customer is Overdue return Yes to workflow
        resultout := wf_engine.eng_completed || ':Y';
      ELSE
        -- Customer is Not Overdue return No to workflow
        resultout := wf_engine.eng_completed || ':N';
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                itemtype, itemkey, to_char(actid), funmode);
      RAISE;
  END isCustomerOverdue;

  PROCEDURE getCollectors (
    itemtype       in varchar2
    , itemkey      in varchar2
    , actid        in number
    , funmode      in varchar2
    , resultout    in out nocopy  varchar2
  )
  IS
    l_proc_name      VARCHAR2(30) := 'getCollectors';
    l_return_status  VARCHAR2(32);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(32);
    l_customer_id    NUMBER;
    l_call_id        VARCHAR2(32);
--    l_collectors     iex_routing_pvt.iex_collectors_tbl_type;

  BEGIN
    IF (funmode = 'RUN')
    THEN
      -- set default result
      resultout := wf_engine.eng_completed ;

      -- Get the customer id from  wf attribute
      l_customer_id  := WF_ENGINE.GetItemAttrNumber (
                          itemtype
                          ,itemkey
                          ,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID
                        );

      -- Get the customer id from  wf attribute
      l_call_id  := WF_ENGINE.GetItemAttrText (
                          itemtype
                          ,itemkey
                          ,'OCCTMEDIAITEMID'
                        );
      -- If no customer id or call id exists return
      IF ( (l_customer_ID IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;
      /*
      -- Call IEX api to get collectors of customer
      iex_routing_pvt.getCollectors (
         p_api_version         => '1'    -- ??
         , x_return_status     => l_return_status
         , x_msg_count         => l_msg_count
         , x_msg_data          => l_msg_data
         , p_customer_id       => l_customer_id
         , p_collectors        => l_collectors
      );
	 */
      -- If no collectors exist return
      IF (l_msg_count = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
     -- CCT_RoutingWorkflow_UTL.InsertResults
    --  (l_call_ID, 'IEX_GetCOLLECTORS' , l_collectors);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                itemtype, itemkey, to_char(actid), funmode);
      RAISE;
  END getCollectors;


END CCT_COLLECTIONROUTING_PUB;

/
