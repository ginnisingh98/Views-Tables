--------------------------------------------------------
--  DDL for Package UMX_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_NOTIFICATION_UTIL" AUTHID CURRENT_USER as
/* $Header: UMXNTFSS.pls 120.1.12010000.2 2017/11/17 04:08:03 avelu ship $ */
-- Start of Comments
-- Package name     : UMX_NOTIFICATION_UTIL
-- Purpose          :
--   This package contains specification  for notification details
   -- Procedure
  --      query_role_display_name
  --
  -- Description
  -- query the wf_local_roles for  the  role display name
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed


procedure Query_role_display_name (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);

  -- Procedure
  --      Check_Context
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed


procedure Check_Context (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);

 --
  -- Procedure
  --      Notification_process_done
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed


procedure Notification_Process_Done (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);

   -- Procedure
  --      GetNextApprover
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed


procedure GetNextApprover (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);

  -- Procedure
  --      get_recipient_username
  --
  -- Description
  -- Return the username of the notification recipient.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure get_recipient_username (item_type    in  varchar2,
                                    item_key     in  varchar2,
                                    activity_id  in  number,
                                    command      in  varchar2,
                                    resultout    out NOCOPY varchar2);

  --  getDecryptedPassword
  --
  -- Description
  -- Since we cannot store  decrypted password in table, the password has to be decrypted during run time.
  -- And this can be achived by using a document type attribute. This method is attached to the attribute
  -- DECRYPT_PWD. It will be called internally by workflow(run time) while emnbedding the attribute in the message body.
  -- IN
  --   document_id  - the encrypted pass
  --   display_type   - internally passed by WF
  -- IN OUT
  --   document     - decrypted password
  --   document_type  - Default plain/text


  procedure getUnencryptedPassword (document_id in varchar2,
									display_type in varchar2,
  									document in out nocopy varchar2,
   									document_type in out nocopy varchar2);

  procedure throw_exception (item_type    in  varchar2,
                             item_key     in  varchar2,
                             activity_id  in  number,
                             command      in  varchar2,
                             resultout    out NOCOPY varchar2);

procedure UpdateApprovalStatus (item_type    in  varchar2,
                                item_key     in  varchar2,
                                activity_id  in  number,
                                command      in  varchar2,
                                resultout    out NOCOPY varchar2);
procedure UpdateRejectedStatus (item_type    in  varchar2,
                                item_key     in  varchar2,
                                activity_id  in  number,
                                command      in  varchar2,
                                resultout    out NOCOPY varchar2);

end UMX_NOTIFICATION_UTIL;

/
