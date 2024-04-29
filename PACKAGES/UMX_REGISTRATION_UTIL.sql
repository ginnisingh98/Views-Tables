--------------------------------------------------------
--  DDL for Package UMX_REGISTRATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REGISTRATION_UTIL" AUTHID CURRENT_USER as
/* $Header: UMXUTILS.pls 120.4.12010000.2 2017/08/02 06:39:51 avelu ship $ */

G_ITEM_TYPE constant VARCHAR2(8) := 'UMXREGWF';
 --
  -- Procedure
  --      assign_wf_role
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


procedure assign_wf_role (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);


-- temp work around remove after wf fixes the bug

procedure LaunchEvent (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);


-- temp work around remove after wf fixes the bug

procedure Start_Notification_Wf (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);
--
  -- Procedure
  -- check_approval_defined
  -- Description
  --    check if ame approval has been defined for this registration service.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure check_approval_defined (item_type    in  varchar2,
                                  item_key     in  varchar2,
                                  activity_id  in  number,
                                  command      in  varchar2,
                                  resultout    out NOCOPY varchar2);

 -- Procedure
  -- check_approval_status
  -- Description
  --    check if request has been approved or not
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure Check_Approval_Status (item_type    in  varchar2,
                                  item_key     in  varchar2,
                                  activity_id  in  number,
                                  command      in  varchar2,
                                  resultout    out NOCOPY varchar2);


--
  -- Procedure
  -- Check if identity verification is required during this registration process
  --
  -- Description
  -- Check if identity verification is required
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure check_idnty_vrfy_reqd (item_type    in  varchar2,
                                            item_key     in  varchar2,
                                            activity_id  in  number,
                                            command      in  varchar2,
                                            resultout    out NOCOPY varchar2);

  --
  -- Procedure
  -- check_mandatory_attributes
  -- Description
  --      Check if all the mandatory attributes are available.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_mandatory_attributes (item_type    in  varchar2,
                                        item_key     in  varchar2,
                                        activity_id  in  number,
                                        command      in  varchar2,
                                        resultout    out NOCOPY varchar2);

--
  -- Procedure
  -- Check_password_null
  -- (DEPRECATED API)
  -- Description
  --      Check if the password is null
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure check_password_null (item_type    in  varchar2,
                                            item_key     in  varchar2,
                                            activity_id  in  number,
                                            command      in  varchar2,
                                            resultout    out NOCOPY varchar2);

  -- Procedure
  --  create_reg_requests
  -- Description
  --  Wrapper around UMX_REG_REQUESTS_PVT.create_reg_srv_request
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure create_reg_request (   p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);
  -- Procedure
  --  update_reg_request
  -- Description
  --  Wrapper around UMX_REG_REQUESTS_PVT.update_reg
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure update_reg_request (   p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);

  -- Procedure
  --  Reserve UserName
  -- Description
  --  Wrapper around Fnd_user_pkg.create_username with status as pending
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure reserve_username (   p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);

  -- Procedure
  --  activate_userName
  -- Description
  --  Wrapper around Fnd_user_pkg.update_username with status as approved
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure activate_username (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);
-- Procedure
  --  release_userName
  -- Description
  --  Wrapper around Fnd_user_pkg.delete_username with status as rejected
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure release_username (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);
-- Procedure
  --  update_user_status
  -- Description
  --  Wrapper around Fnd_user_pkg.delete_username with status as rejected
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure update_user_status (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);
-- Procedure
  --  cancel_username
  -- Description
  --  Wrapper around Fnd_user_pkg.delete_username with status as cancelled
  -- this is for failed identity verification
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure cancel_username (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);
-- Procedure
  --  reject_request
  -- Description
  --  Wrapper around UMX_REG_REQUESTS_PVT.reject_request with status as reject
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure reject_request (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);

 -- Procedure
  --  increment_sequence
  -- Description
  -- Procedure which increments the sequence used for raising the events
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure increment_sequence(    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);

--
  --  Function
  --  set_event_object
  --
  -- Description
  -- This method sets back the changes made to parameters in subscribers back to
  -- the the main workflow.
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  - Run/Cancel/Timeout
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --


function set_event_object( p_event in out NOCOPY WF_EVENT_T,
                           p_attr_name in VARCHAR2 DEFAULT NULL,
                           p_attr_value in VARCHAR2 DEFAULT NULL)
                         return varchar2;

  -- Procedure
  --      create_ad_hoc_role
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure create_ad_hoc_role (item_type   in  varchar2,
                                item_key    in  varchar2,
                                activity_id in  number,
                                command     in  varchar2,
                                resultout   out NOCOPY varchar2);

  --
  -- Procedure
  --      release_ad_hoc_role
  --
  -- Description
  -- remove the adhoc role
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure release_ad_hoc_role (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2);

  --
  -- Procedure
  --      Launch_Custom_event
  --
  -- Description
  -- Launches the Custom Event, if one is defined.
  -- It also adds the context into event object
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed


procedure Launch_Custom_Event (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);

  --
  -- Procedure
  --   ICM_VIOLATION_CHECK
  --
  -- Description
  --   This API will call the ICM API to check if there are any violation
  --   with the requested role(s).
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure ICM_VIOLATION_CHECK (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2);

  -- procedure
  -- Launch_username_policy
  -- (DEPRECATED API)
  -- Description
  -- procedure to launch username policy
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure launch_username_policy (          item_type    in  varchar2,
                                            item_key     in  varchar2,
                                            activity_id  in  number,
                                            command      in  varchar2,
                                            resultout    out NOCOPY varchar2);

  --
  -- Procedure
  -- Check_userName_null
  -- (DEPRECATED API)
  -- Description
  --      Check if the username is null
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure check_username_null (item_type    in  varchar2,
                                            item_key     in  varchar2,
                                            activity_id  in  number,
                                            command      in  varchar2,
                                            resultout    out NOCOPY varchar2);


 -- procedure custom_code
  -- (DEPRECATED API)
 -- This api should not have been invoked,
 -- it will be done only if username policy failed
 procedure custom_code (    p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2);


 -- procedure LAUNCH_RESETPWD_WF
 --
 -- Description
 -- This api launches reset password WF which emails password reset link to user.
 -- it will be done only if 'MANUAL_PWD_RESET' profile is turned off.
 -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT

  procedure LAUNCH_RESETPWD_WF (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2);
end UMX_REGISTRATION_UTIL;

/
