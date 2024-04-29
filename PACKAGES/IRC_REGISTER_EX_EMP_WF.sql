--------------------------------------------------------
--  DDL for Package IRC_REGISTER_EX_EMP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REGISTER_EX_EMP_WF" AUTHID CURRENT_USER as
/* $Header: irexempr.pkh 120.2 2005/11/23 01:00:26 gjaggava noship $ */
--
procedure self_register_user_save
(itemtype in varchar2,
itemkey in varchar2,
actid in number,
funcmode in varchar2,
resultout out nocopy varchar2);
--
procedure self_register_user_init
   (p_current_email_address     IN     varchar2
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_first_name                IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_middle_names              IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_employee_number           IN     varchar2 default null
   ,p_national_identifier       IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_home_phone_number         IN     varchar2 default null
   ,p_work_phone_number         IN     varchar2 default null
   ,p_address_line_1            IN     varchar2 default null
   ,p_manager_last_name         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default 'N'
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   );

end;

 

/
