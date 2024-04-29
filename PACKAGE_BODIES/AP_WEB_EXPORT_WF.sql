--------------------------------------------------------
--  DDL for Package Body AP_WEB_EXPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_EXPORT_WF" AS
/* $Header: apwexpwb.pls 120.0 2005/06/09 20:26:36 rlangi noship $ */

------------------------
-- Events
------------------------
-- Event key is used for item key
-- Event name is the true event name
-- Item/Event key is in the form of: '<Event key>:<DD-MON-RRRR HH:MI:SS>'
C_REJECTION_EVENT_KEY	CONSTANT VARCHAR2(30) := 'export.rejection';
C_REJECTION_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.export.rejection';
C_REJECTION_PROCESS	CONSTANT VARCHAR2(80) := 'REJECTIONS_PROCESS';

-- Item Key Delimeter
C_ITEM_KEY_DELIM	CONSTANT VARCHAR2(1) := ':';


------------------------------------------------------------------------
FUNCTION GenerateEventKey(
                                 p_request_id    IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_timestamp		varchar2(30);
BEGIN

  select to_char(sysdate, 'DD-MON-RRRR HH:MI:SS')
  into   l_timestamp
  from   dual;

  return C_REJECTION_EVENT_KEY||C_ITEM_KEY_DELIM||p_request_id||C_ITEM_KEY_DELIM||l_timestamp;

END GenerateEventKey;


------------------------------------------------------------------------
PROCEDURE RaiseRejectionEvent(
                                 p_request_id    IN NUMBER,
				 p_role      IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);


  --l_parameter_list wf_parameter_list_t;
  l_item_type wf_items.item_type%type := C_APWEXPRT;
  l_item_key wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_EXPORT_WF', 'start RaiseRejectionEvent');

  /*

    Product teams WF BES events have been removed due to ATG R12 mandate

  ----------------------------------------------------------
  l_debug_info := 'Rejection Parameter List';
  ----------------------------------------------------------
  l_parameter_list := wf_parameter_list_t(
            wf_parameter_t('REQUEST_ID', to_char(p_request_id)),
            wf_parameter_t('REJECTIONS_ROLE', p_role));

  ----------------------------------------------------------
  l_debug_info := 'Raise Rejection Event';
  ----------------------------------------------------------
  wf_event.raise(p_event_name => C_REJECTION_EVENT_NAME,
                 p_event_key => GenerateEventKey(p_request_id),
                 p_parameters => l_parameter_list);
  */


  ----------------------------------------------------------
  l_debug_info := 'Create Rejection Process';
  ----------------------------------------------------------
  l_item_key := GenerateEventKey(p_request_id);

  WF_ENGINE.CreateProcess(l_item_type,
                          l_item_key,
                          C_REJECTION_PROCESS);

  ----------------------------------------------------------
  l_debug_info := 'Set Rejection Process Attr REQUEST_ID';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_item_type,
                              l_item_key,
                              'REQUEST_ID',
                              p_request_id);

  ----------------------------------------------------------
  l_debug_info := 'Set Rejection Process Attr REJECTIONS_ROLE';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_item_type,
                            l_item_key,
                            'REJECTIONS_ROLE',
                            p_role);

  ----------------------------------------------------------
  l_debug_info := 'Set the Requester as the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_item_type,
                         l_item_key,
                         p_role);


  ----------------------------------------------------------
  l_debug_info := 'Set Item User Key to Request Id for easier query ';
  ----------------------------------------------------------
  WF_ENGINE.SetItemUserKey(l_item_type,
                           l_item_key,
                           p_request_id);

  ----------------------------------------------------------
  l_debug_info := 'Start Rejection Process';
  ----------------------------------------------------------
  WF_ENGINE.StartProcess(l_item_type,
                         l_item_key);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_EXPORT_WF', 'end RaiseRejectionEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPORT_WF', 'RaiseRejectionEvent',
                     l_debug_info);
    raise;
END RaiseRejectionEvent;


END AP_WEB_EXPORT_WF;

/
