--------------------------------------------------------
--  DDL for Package IBE_OM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_OM_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/*$Header: IBEGORDS.pls 115.1 2003/09/02 09:41:08 venagara noship $ */


  -- =======================================================================
  -- Global Constants to indicate the Return-Notification request context
  G_RETURN_APPROVAL   VARCHAR2(30) := '1';
  G_RETURN_REJECT     VARCHAR2(30) := '2';


  -- =======================================================================
  -- PROCEDURE notify_rma_request_action
  -- This procedure will notify the iStore end-user(s) about the OM Administrator's action
  -- (approval or rejection) on the "Return Order submitted by him".
  -- If the Return-order is approved, for approval notification, OM will call this API
  -- with P_notif_context = G_RETURN_APPROVAL and with P_notif_context = G_RETURN_REJECT
  -- for rejection notification.
  -- This notification sent, will potentially contain the address of the location where
  -- the goods need to be returned, if return is approved
  -- If Approval process has "NOT" been setup in OM, then this api will not be invoked by OM
  -- and the Return-order will be directly Booked, upon "User Submission".
  -- In future, api can be used to get notification party list for other OM events.
  -- by extending the notif_context parameter values.
  --
  -- Parameter P_notif_context
  -- Pass Context Value
  -- Valid values : G_RETURN_APPROVAL, G_RETURN_REJECT
  --
  -- Parameter P_comments
  -- Pass the comments entered by the OM admin
  --
  -- Parameter P_reject_reason_code
  -- Pass the rejection reason code, if P_notif_context is G_RETURN_REJECT.

  PROCEDURE  notify_rma_request_action(
           P_Api_Version_Number   IN         NUMBER,
           P_Init_Msg_List        IN         VARCHAR2 := FND_API.G_FALSE,
           P_order_header_id      IN         NUMBER,
           P_notif_context        IN         VARCHAR2,
           P_comments             IN         VARCHAR2,
           P_reject_reason_code   IN         VARCHAR2 := NULL,
           X_Return_Status        OUT NOCOPY VARCHAR2,
           X_Msg_Count            OUT NOCOPY NUMBER,
           X_Msg_Data             OUT NOCOPY VARCHAR2);

  -- =======================================================================


END IBE_OM_INTEGRATION_GRP;

 

/
