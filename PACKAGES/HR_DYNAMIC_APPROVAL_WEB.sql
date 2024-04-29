--------------------------------------------------------
--  DDL for Package HR_DYNAMIC_APPROVAL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DYNAMIC_APPROVAL_WEB" AUTHID CURRENT_USER AS
/* $Header: hrdynapr.pkh 120.2.12010000.1 2008/07/28 03:13:49 appldev ship $ */

TYPE grt_wf_attributes IS RECORD (
       dynamic_approval_mode     varchar2 (200)
      ,approval_level            NUMBER
    );


TYPE person_details IS RECORD (
        full_name       per_people_f.FULL_NAME%TYPE,
        person_id       per_people_f.person_id%TYPE,
        job_title       per_jobs.name%TYPE DEFAULT NULL,
        default_approver    VARCHAR2(10) DEFAULT 'N',
        error_exists        VARCHAR2(10) DEFAULT 'N'
     );

TYPE t_person_table IS TABLE OF person_details INDEX BY BINARY_INTEGER;

TYPE approver_rec IS RECORD (
        person_id           per_people_f.person_id%TYPE,
        default_approver    VARCHAR2(10) DEFAULT 'N'
        );
TYPE approver_rec_table   IS TABLE OF  approver_rec   INDEX BY BINARY_INTEGER;

TYPE notifier_rec IS RECORD (
      full_name       per_people_f.FULL_NAME%TYPE,
      person_id       per_people_f.person_id%TYPE,
      job_title       per_jobs.name%TYPE DEFAULT NULL,
      on_submit       VARCHAR2(10) DEFAULT 'Y',
      on_approval     VARCHAR2(10) DEFAULT 'Y',
      error_exists        VARCHAR2(10) DEFAULT 'N'
);

TYPE notifier_rec_table   IS TABLE OF  notifier_rec  INDEX BY BINARY_INTEGER;


TYPE ddl_record IS RECORD (
	label hr_lookups.meaning%type,
	code hr_lookups.lookup_code%type,
    code_index NUMBER
);

TYPE ddl_data IS TABLE OF ddl_record INDEX BY BINARY_INTEGER;




PROCEDURE get_wf_attributes (
             p_item_type  in wf_items.item_type%TYPE
            ,p_item_key   in wf_items.item_key%TYPE
            ,p_actid      in number
          );


PROCEDURE get_default_approvers(
    p_approver_name OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_approver_flag OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE
        );

PROCEDURE get_all_approvers(p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                            p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
                            p_item_type IN wf_items.item_type%TYPE,
                            p_item_key         IN wf_items.item_key%TYPE,
                            p_effective_date   IN DATE DEFAULT SYSDATE);



FUNCTION  build_ddl(p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                    p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
                    p_item_type        IN wf_items.item_type%TYPE,
                    p_item_key         IN wf_items.item_key%TYPE ,
                    p_variable_name       in varchar2,
                    p_variable_value      in varchar2 DEFAULT NULL
  		           ,p_attributes IN VARCHAR2 DEFAULT NULL)   RETURN LONG  ;

PROCEDURE add_approver(p_approver_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_approver_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_approver_index IN NUMBER DEFAULT 0);

 PROCEDURE delete_approver(p_approver_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_approver_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_approver_index IN NUMBER DEFAULT 1);



PROCEDURE add_notifier(
                    p_notifier_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                    p_notify_onsubmit_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                    p_notify_onapproval_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                    p_item_type IN wf_items.item_type%TYPE
                   ,p_item_key IN wf_items.item_key%TYPE
                   ,P_PERSON_NAME IN per_all_people_f.full_name%TYPE
                   ,p_person_id IN per_all_people_f.person_id%TYPE
                 );



PROCEDURE Get_all_notifiers(
                       p_notifier_name  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onsubmit_flag  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onapproval_flag  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_effective_date IN DATE
                  );



PROCEDURE update_notifiers(
          p_item_type 	     IN WF_ITEMS.ITEM_TYPE%TYPE ,
          p_item_key  	     IN WF_ITEMS.ITEM_KEY%TYPE ,
          p_act_id    	     IN NUMBER ,
          p_notifiers_num    IN NUMBER DEFAULT 0,
          p_Notify_On_Submit  hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default,
          p_Notify_On_Approval  hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default

              );

PROCEDURE clean_invalid_data( p_item_type 	     IN WF_ITEMS.ITEM_TYPE%TYPE ,
          p_item_key  	     IN WF_ITEMS.ITEM_KEY%TYPE ,
          p_act_id    	     IN NUMBER ,
          p_approvers_name   IN hr_util_misc_web.g_varchar2_tab_type
          );


--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );



-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure Check_Final_Approver( p_item_type    in varchar2,
                p_item_key     in varchar2,
                p_act_id       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );

-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Notifier >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure Check_OnSubmit_Notifier( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );

procedure  Check_OnApproval_Notifier( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_OnSubmit_notifier >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next notifier in the chain
--
--
procedure Get_OnSubmit_Notifier (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_OnApproval_notifier >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next notifier in the chain
--
--
procedure Get_OnApproval_Notifier (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );



procedure set_first_onapproval_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);

procedure set_first_onsubmit_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);


procedure initialize_item_attributes
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);



procedure Notify(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);


/*-----------------------------------------------------------------------

|| PROCEDURE         : get_default_approvers_list
||
|| This is a wrapper procedure to get_default_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_default_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss);

PROCEDURE get_default_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss,
    p_error_message OUT NOCOPY varchar);


/*-----------------------------------------------------------------------

|| PROCEDURE         : get_ame_approvers_list
||
|| This is a wrapper procedure to get_default_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/
PROCEDURE get_ame_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss);


/*-----------------------------------------------------------------------

|| PROCEDURE         : set_ame_approvers_list
||
|| This is a wrapper procedure to get_default_approvers to update
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE set_ame_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list IN hr_dynamic_approver_list_ss);

/*-----------------------------------------------------------------------

|| PROCEDURE         : get_additional_notifiers_list
||
|| This is a wrapper procedure to get_default_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_additional_notifiers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_additional_notifiers_list OUT NOCOPY hr_dynamic_approver_list_ss);


end hr_dynamic_approval_web;   -- Package spec

/
