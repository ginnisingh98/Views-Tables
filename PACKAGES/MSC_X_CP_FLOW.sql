--------------------------------------------------------
--  DDL for Package MSC_X_CP_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_CP_FLOW" AUTHID CURRENT_USER AS
/* $Header: MSCXCPFS.pls 115.7 2003/08/05 21:54:49 pdandapa ship $ */


  -- This procedure will start the Workflow process to run the SCEM engine
  PROCEDURE Start_SCEM_Engine_WF;

  -- This procedure will lanuch the SCEM engine
  PROCEDURE Launch_SCEM_Engine
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  PROCEDURE Start_DP_Receive_Forecast_WF
  ( p_customer_id             in number
  ,  p_horizon_start           in date
  , p_horizon_days            in number
  --, p_recipient_name IN VARCHAR2
  --, p_responsibility_id IN NUMBER
  , p_resp_key IN varchar2
  , p_message_to_tp IN VARCHAR2
  , p_tp_name IN VARCHAR2
  );

  PROCEDURE DP_Receive_Forecast
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  PROCEDURE Receive_Supplier_Capacity_WF
  ( p_supplier_id IN Number
  , p_horizon_start_date In date
  , p_horizon_end_date In date
  --, p_recipient_name IN VARCHAR2
  --, p_responsibility_id IN NUMBER
  , p_resp_key IN varchar2
  , p_message_to_tp IN VARCHAR2
  , p_tp_name IN VARCHAR2
    );

  PROCEDURE Receive_Supplier_Capacity
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  PROCEDURE Start_ASCP_Engine_WF
  ( p_constrained_plan_flag IN NUMBER
  );

  PROCEDURE Launch_ASCP_Engine
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  FUNCTION auto_scem_mode
    RETURN NUMBER;

  PROCEDURE Publish_Supply_Commits_WF
  ( p_plan_id                 in number
  );

  PROCEDURE Publish_Supply_Commits
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  PROCEDURE Publish_Order_Forecast_WF
  ( p_plan_id                 in number
  );

  PROCEDURE Publish_Order_Forecast
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This procesure prints out debug info.
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

  END MSC_X_CP_FLOW;

 

/
