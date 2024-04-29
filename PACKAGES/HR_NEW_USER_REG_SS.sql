--------------------------------------------------------
--  DDL for Package HR_NEW_USER_REG_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NEW_USER_REG_SS" AUTHID CURRENT_USER AS
/* $Header: hrregwrs.pkh 120.0.12010000.2 2009/07/02 09:21:49 amunsi ship $*/

g_ignore_emp_generation varchar2(20) := 'NO';

procedure processNewUserTransaction
(WfItemType     in varchar2,
 WfItemKey      in varchar2,
 PersonId       in out nocopy varchar2,
 AssignmentId   in out nocopy varchar2);

procedure process_selected_transaction
  (p_item_type           in varchar2
  ,p_item_key            in varchar2
  ,p_ignore_warnings     in varchar2 default 'Y'
  ,p_validate            in boolean default false
  ,p_update_object_version in varchar2 default 'N'
  ,p_effective_date      in varchar2 default null
  ,p_api_name            in varchar2 default null);

procedure  processExEmpTransaction
(WfItemType     in varchar2,
 WfItemKey      in varchar2,
 PersonId       in out nocopy varchar2,
 AssignmentId   in out nocopy varchar2,
 p_error_message                 out nocopy    long);

end hr_new_user_reg_ss;

/
