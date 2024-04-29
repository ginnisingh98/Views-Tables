--------------------------------------------------------
--  DDL for Package OTA_INITIALIZATION_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_INITIALIZATION_WF" AUTHID CURRENT_USER as
/* $Header: ottomint.pkh 120.20.12010000.10 2009/08/31 13:49:06 smahanka ship $ */

-- ----------------------------------------------------------------------------
-- |-------------------< INITIALIZE_CANCEL_ENROLLMENT  >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to initialize workflow for Enrollment cancellation.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_booking_id
-- p_Line_id
-- p_org_id
-- p_Status
-- p_Event_id
-- p_Itemtype
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE INITIALIZE_CANCEL_ENROLLMENT
(
p_booking_id   IN    NUMBER,
p_Line_id      IN NUMBER,
p_org_id    IN NUMBER,
p_Status       IN VARCHAR2,
p_Event_id     IN NUMBER,
p_Itemtype     IN VARCHAR2,
p_process      IN VARCHAR2);

-- ----------------------------------------------------------------------------
-- |---------------------< INITIALIZE_CANCEL_EVENT  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to initialize workflow for Event Cancelation.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_event_id
-- p_Line_id
-- p_Status
-- p_Event_title
-- p_owner_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure INITIALIZE_CANCEL_EVENT
(
p_event_id     IN NUMBER,
p_Line_id      IN NUMBER,
p_Status    IN VARCHAR2,
p_Event_title  IN VARCHAR2 ,
p_owner_id     IN NUMBER,
p_org_id          IN NUMBER,
p_itemtype     IN VARCHAR2
);

-- ----------------------------------------------------------------------------
-- |------------------< INITIALIZE_EVENT_DATE_CHANGED>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to initialize workflow if when event date changed.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_Line_id
--   p_org_id
--   p_Event_title
--   p_Itemtype
--   p_process
--   p_emailid
--   p_name
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  INITIALIZE_EVENT_DATE_CHANGED
(
p_Line_id   IN NUMBER,
p_org_id IN NUMBER,
p_Event_title  IN VARCHAR2,
p_Itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_emailid   IN VARCHAR2,
p_name      IN VARCHAR2);

-- ----------------------------------------------------------------------------
-- |----------------------< initialize_cancel_order  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow if order got cancel from OM.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_email_address
--  p_line_id
--  p_status
--  p_full_name
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------


PROCEDURE INITIALIZE_CANCEL_ORDER (
p_itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_event_id     IN    NUMBER,
p_user_name       IN VARCHAR2,
p_line_id      IN    NUMBER,
p_status    IN    VARCHAR2,
p_full_name    IN    VARCHAR2

) ;


-- ----------------------------------------------------------------------------
-- |-----------------------------< Manual_waitlist  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow to notify event owner to
--   do manual waitlist enrollment .
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_user_name
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------


PROCEDURE MANUAL_WAITLIST (
p_itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_event_id     IN    NUMBER,
p_item_key        IN    VARCHAR2,
p_user_name       IN VARCHAR2
) ;

-- ----------------------------------------------------------------------------
-- |----------------------< Manual_enroll_waitlist  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow to notify event owner to
--   do manual waitlist enrollment .
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_user_name
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE MANUAL_ENROLL_WAITLIST (
p_itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_item_key     IN    VARCHAR2,
p_owner_id        IN    NUMBER
) ;

-- ----------------------------------------------------------------------------
-- |----------------------< set_wf_item_attr  >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_wf_item_attr(p_person_id in number,
                            p_item_type in wf_items.item_type%type,
                            p_item_key in wf_items.item_key%type);


Procedure get_event_fired(itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funcmode      in varchar2,
  resultout       out nocopy varchar2);
 -- ----------------------------------------------------------------------------
-- |----------------------< Initialize_wf  >-------------------------|
-- ----------------------------------------------------------------------------

-- this wf would be used for OTA_ENROLL_STATUS_CHNG_JSP_PRC
-- AND OTA_CLASS_CANCEL_JSP_PRC
--gets called from ota_evt_upd.upd for class rescheduling or location change
--called from alert
-- called from ota_evt_api_upd2.process_event
--from ota_tdb_api_upd2.update_enrollment

 Procedure Initialize_wf(p_process 	in wf_process_activities.process_name%type,
            p_item_type 		in wf_items.item_type%type,
            p_person_id 	in number default null,
         --   p_booking_id in ota_delegate_bookings.Booking_id%type default null,
            p_eventid       in ota_Events.event_id%type,
            p_event_fired in varchar2);

--gets called from ota_evt_upd.upd for class rescheduling or location change
-- called from ota_evt_api_upd2.update_event
--alert
--ota_resource_bookings_api.create/update_resource_booking
-- --ota_resource_bookings_api.delete_resource_booking

   Procedure Initialize_instructor_wf(
            p_item_type 		in wf_items.item_type%type,
            p_eventid 	in ota_events.event_id%type,
            p_sup_res_id       in ota_resource_bookings.supplied_resource_id%type default null,
            p_start_date in varchar2 default null,
            p_end_date in varchar2 default null,
            p_start_time in ota_events.course_start_time%type default null,
            p_end_time in ota_events.course_start_time%type default null,
            p_status in varchar2 default null,
            p_res_book_id in ota_resource_bookings.resource_booking_id%type default null,
            p_person_id in number default null,
            p_event_fired in varchar2);

 -- called from alerts

    Procedure Initialize_auto_wf(p_process 	in wf_process_activities.process_name%type,
            p_item_type 		in wf_items.item_type%type,
            p_event_fired in varchar2,
            p_event_id in ota_events.event_id%type default null);
  -- called from ota_lp_enrollment_api.update/create_lp_enrollment
    Procedure Init_LP_wf(p_item_type 		in wf_items.item_type%type,
            p_lp_enrollment_id       in ota_lp_enrollments.lp_enrollment_id%type,
            p_event_fired in varchar2);

    procedure init_assessment_wf(p_person_id in number,
	p_attempt_id 	in varchar2);

Procedure set_addnl_attributes(p_item_type 	in wf_items.item_type%type,
                                p_item_key in wf_items.item_key%type,
                                p_eventid in ota_events.event_id%type,
				p_from in varchar2 default null
                               );

-- ----------------------------------------------------------------------------
-- |----------------------< initialize_cert_ntf_wf  >-------------------------|
-- ----------------------------------------------------------------------------
-- This wf would be used for OTA_CERTIFICATION_NTF_JSP_PRC
-- Called from alert
Procedure initialize_cert_ntf_wf(p_item_type in wf_items.item_type%type,
                                  p_person_id in number default null,
                                  p_certification_id in ota_certifications_b.certification_id%type,
				  p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                                  p_cert_ntf_type in varchar2);

Procedure process_cert_alert(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2,
     p_cert_ntf_type in varchar2);

Procedure init_forum_notif(p_Forum_id in ota_forum_messages.forum_id%type,
                           p_Forum_message_id in ota_forum_messages.forum_message_id%type);

Procedure send_event_beginning_ntf(
     ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2) ;

Procedure send_instructor_reminder_ntf(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2);

procedure init_course_eval_notif(p_booking_id OTA_DELEGATE_BOOKINGS.booking_id%type);

procedure get_course_eval_status ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					                         itemkey	IN WF_ITEMS.ITEM_KEY%TYPE,
					                         actid		IN NUMBER,
					                         funcmode	IN VARCHAR2,
					                         resultout	OUT nocopy VARCHAR2 );
procedure get_class_name(document_id in varchar2,
                         display_type in varchar2,
                         document in out nocopy varchar2,
                         document_type in out nocopy varchar2);

procedure get_course_eval_del_mode ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					                         itemkey	IN WF_ITEMS.ITEM_KEY%TYPE,
					                         actid		IN NUMBER,
					                         funcmode	IN VARCHAR2,
					                         resultout	OUT nocopy VARCHAR2 );


procedure RAISE_BUSINESS_EVENT(
            p_eventid       in ota_Events.event_id%type,
            p_event_fired in varchar2,
            p_type in varchar2 default null);

end ota_initialization_wf;

/
