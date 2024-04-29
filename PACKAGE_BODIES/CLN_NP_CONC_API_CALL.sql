--------------------------------------------------------
--  DDL for Package Body CLN_NP_CONC_API_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NP_CONC_API_CALL" as
/* $Header: ECXNPCRB.pls 120.0 2005/08/25 04:47:04 nparihar noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));


-- Package: CLN_NP_CONC_API_CALL
--
-- Purpose: To run user defined PL/SQL function in concurrent mode
--
-- History
--     May-02-2002      Kodanda Ram         Created

--
-- Name
--    CALL_API
-- Purpose
--    This procedure submits a concurrent request for the user defined PL/SQL function
--
-- Arguments
--    P_ITEMTYPE   Item type
--    P_ITEMTYPE   Item Key
--    P_ACTID      Action ID
--    P_FUNCMODE   Function Mode
--    X_RESULTOUT  Result
--
-- Returns [ for functions ]
--
-- Notes
--     No specific notes




PROCEDURE CALL_API (
   p_itemtype        IN VARCHAR2,
   p_itemkey         IN VARCHAR2,
   p_actid           IN NUMBER,
   p_funcmode        IN VARCHAR2,
   x_resultout       IN OUT NOCOPY VARCHAR2)
IS
   l_cln_not_parameters       wf_parameter_list_t;
   l_debug_mode               VARCHAR2(255);
   l_procedure_call_statement VARCHAR2(250);
   l_procedure_name           VARCHAR2(250);
   l_application_id           VARCHAR2(250);
   l_collaboration_id         VARCHAR2(250);
   l_collaboration_type       VARCHAR2(250);
   l_reference_id             VARCHAR2(250);
   l_trading_partner_id       VARCHAR2(250);
   l_status                   VARCHAR2(250);
   l_header_desc              VARCHAR2(250);
   l_notification_code        VARCHAR2(250);
   l_notification_desc        VARCHAR2(250);
BEGIN
   -- Sets the debug mode to be FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_CONC_API_CALL.CALL_API', 2);
   END IF;

   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('With the following parameters:', 1);
           ecx_cln_debug_pub.Add('p_itemtype:' || p_itemtype, 1);
           ecx_cln_debug_pub.Add('p_itemkey:' || p_itemkey, 1);
           ecx_cln_debug_pub.Add('p_actid:' || p_actid, 1);
           ecx_cln_debug_pub.Add('p_funcmode:' || p_funcmode, 1);
   END IF;


   l_procedure_name := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'PROCEDURE_NAME');
   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('l_procedure_name - ' ||   l_procedure_name, 2);
   END IF;


   l_application_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'APPLICATION_ID');
   l_collaboration_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'COLLABORATION_ID');
   l_collaboration_type := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'COLLABORATION_TYPE');
   l_reference_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'REFERENCE_ID');
   l_trading_partner_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'TRADING_PARTNER_ID');
   l_status := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'STATUS');
   l_header_desc := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'HEADER_DESC');
   l_notification_code := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'NOTIFICATION_CODE');
   l_notification_desc := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid, 'NOTIFICATION_DESC');

   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('l_application_id - ' || l_application_id, 1);
           ecx_cln_debug_pub.Add('l_collaboration_id - ' || l_collaboration_id, 1);
           ecx_cln_debug_pub.Add('l_collaboration_type - ' || l_collaboration_type, 1);
           ecx_cln_debug_pub.Add('l_reference_id - ' || l_reference_id, 1);
           ecx_cln_debug_pub.Add('l_trading_partner_id - ' || l_trading_partner_id, 1);
           ecx_cln_debug_pub.Add('l_status - ' || l_status, 1);
           ecx_cln_debug_pub.Add('l_header_desc - ' || l_header_desc, 1);
           ecx_cln_debug_pub.Add('l_notification_code - ' || l_notification_code, 1);
           ecx_cln_debug_pub.Add('l_notification_desc - ' || l_notification_desc, 1);
   END IF;


   WF_EVENT.AddParameterToList('ApplicationId',l_application_id,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('CollaborationId',l_collaboration_id,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('CollaborationType',l_collaboration_type,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('ReferenceId',l_reference_id,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('TradingPartnerID',l_trading_partner_id,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('HeaderDescription',l_header_desc,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('NotificationDescription',l_notification_desc,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('NotificationCode',l_notification_code,l_cln_not_parameters);
   WF_EVENT.AddParameterToList('Status',l_status,l_cln_not_parameters);
   l_procedure_call_statement := 'begin ' || l_procedure_name || '(:l_cln_not_parameters); end;';
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('INVOKING PROCEDURE - ' || l_procedure_call_statement, 2);
   END IF;

   execute immediate l_procedure_call_statement using l_cln_not_parameters;
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('COMPLETED PROCEDURE - ' || l_procedure_call_statement, 2);
   END IF;

   x_resultout := 'Yes';
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING CLN_NP_CONC_API_CALL.CALL_API', 2);
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         -- Unexpected Exception
         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('Unexpected Exception', 2);
         END IF;

         x_resultout :='Unexpected Exception';
         RETURN;
END CALL_API;


END CLN_NP_CONC_API_CALL;

/
