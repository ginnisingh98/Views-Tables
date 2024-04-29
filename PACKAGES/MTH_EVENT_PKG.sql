--------------------------------------------------------
--  DDL for Package MTH_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_EVENT_PKG" AUTHID CURRENT_USER AS
/*$Header: mthevnts.pls 120.2.12010000.2 2009/08/21 11:55:05 sdonthu noship $ */

TYPE ActionHandlerRec IS RECORD (
     Person_fk_key  MTH.MTH_EVENT_ACTION_SETUP.personnel_fk_key%TYPE,
     email_notification MTH.MTH_EVENT_ACTION_SETUP.email_notification%TYPE,
     mobile_notification MTH.MTH_EVENT_ACTION_SETUP.mobile_notification%TYPE,
 	   Action_type_code MTH.MTH_EVENT_ACTION_SETUP.ACTION_TYPE_CODE%TYPE,
	   Action_Handler_API VARCHAR2(1024),
     domain_name MTH.MTH_EVENT_ACTION_SETUP.DOMAIN_NAME%TYPE
	);

TYPE ActionHandlerTableType IS VARRAY(50) OF ActionHandlerRec;

TYPE ActionStatusRec IS RECORD (
    action_type_code MTH.MTH_EVENT_ACTIONS.action_type_code%TYPE,
    notification_id MTH.MTH_EVENT_ACTIONS.notification_id%TYPE,
    notification_content MTH.MTH_EVENT_ACTIONS.notification_content%TYPE,
    action_reference_id MTH.MTH_EVENT_ACTIONS.action_reference_id%TYPE,
    action_status MTH.MTH_EVENT_ACTIONS.action_status%TYPE,
    action_handler_api MTH.MTH_EVENT_ACTIONS.action_handler_api%TYPE
  );

TYPE ActionStatusTableType IS VARRAY(50) OF ActionStatusRec;

PROCEDURE init_action_handler_rec;
PROCEDURE init_action_status_rec;

PROCEDURE handle_event(p_equipment_fk_key IN NUMBER,
                       p_event_type IN VARCHAR2,
                       p_Shift_workday_fk_key IN NUMBER,
                       p_Workorder_fk_key IN NUMBER,
                       p_Reading_time IN DATE,
                       p_reason_code IN VARCHAR2,
                       p_equip_status IN NUMBER,
                       p_event_description IN VARCHAR2);


FUNCTION create_mth_event(p_equipment_fk_key IN NUMBER,
                          p_event_type IN VARCHAR2,
                          p_Shift_workday_fk_key IN NUMBER,
                          p_Workorder_fk_key IN NUMBER,
                          p_Reading_time IN DATE,
                          p_reason_code IN VARCHAR2,
                          p_equip_status IN NUMBER,
                          p_event_description IN VARCHAR2) RETURN NUMBER;


PROCEDURE ACTION_HANDLER_LOOKUP (p_equipment_fk_key IN NUMBER,
                                 p_event_type IN VARCHAR2,
                                 p_reason_code IN VARCHAR2,
                                 p_event_actions OUT NOCOPY ActionHandlerTableType);

PROCEDURE ACTION_HANDLER_DISPATCHER (p_event_id IN NUMBER,
                                     p_event_action_rec IN ActionHandlerRec,
                                     p_action_statuses OUT NOCOPY ActionStatusTableType);

PROCEDURE UPDATE_MTH_EVENT_ACTION (p_event_id IN NUMBER,
                                   p_action_statuses IN ActionStatusTableType) ;

PROCEDURE INVOKE_EVENT_NOTIFICATION(p_event_id IN NUMBER,
                                    p_event_action_rec IN ActionHandlerRec,
                                    p_action_statuses OUT NOCOPY ActionStatusTableType);

FUNCTION SEND_NOTIFICATION(p_send_to varchar2,
                           p_subject varchar2,
                           p_text varchar2 ) RETURN VARCHAR2;

PROCEDURE INVOKE_EVENT_EAM_WR(p_event_id IN NUMBER,
                              p_event_action_rec IN ActionHandlerRec,
                              p_action_statuses OUT NOCOPY ActionStatusTableType);

PROCEDURE INVOKE_EVENT_PLSQL_API(p_event_id IN NUMBER,
                                 p_event_action_rec IN ActionHandlerRec,
                                 p_action_statuses OUT NOCOPY ActionStatusTableType);

PROCEDURE INVOKE_EVENT_BPEL(p_event_id IN NUMBER,
                            p_event_action_rec IN ActionHandlerRec,
                            p_action_statuses OUT NOCOPY ActionStatusTableType);

FUNCTION invoke_http_request(p_event_id   IN NUMBER,
                             p_url        IN VARCHAR2,
                             p_namespace  IN VARCHAR2,
                             p_action     IN VARCHAR2) RETURN VARCHAR2;

END Mth_event_PKG;

/
