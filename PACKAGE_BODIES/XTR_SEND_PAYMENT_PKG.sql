--------------------------------------------------------
--  DDL for Package Body XTR_SEND_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_SEND_PAYMENT_PKG" as
/* $Header: xtrspayb.pls 120.0.12010000.3 2008/11/01 06:29:38 srsampat ship $ */



 -------------------------------------------------------------------------------------------
 ------ Procedure get_notification_data is called from the get_notification node
 ------ WF program aptrsend.wft calls this procedure
 -------------------------------------------------------------------------------------------


 PROCEDURE get_notification_data (p_item_type          IN VARCHAR2,
                                  p_item_key           IN VARCHAR2,
                                  p_actid              IN NUMBER,
                                  p_funmode            IN VARCHAR2,
                                  p_result             OUT NOCOPY VARCHAR2) IS

  /* Bug 7512197 Start  This package is no more used . So making it Null */

BEGIN

  null;

 END get_notification_data;

  -------------------------------------------------------------------------------------------
 ------ Procedure submit_conc_program is called from the submit_conc_program node
 ------ WF program aptrsend.wft calls this procedure
 -------------------------------------------------------------------------------------------

 PROCEDURE submit_conc_program   (p_item_type          IN VARCHAR2,
                                  p_item_key           IN VARCHAR2,
                                  p_actid              IN NUMBER,
                                  p_funmode            IN VARCHAR2,
                                  p_result             OUT NOCOPY VARCHAR2) IS


  /* Bug 7512197 Start  This package is no more used . So making it Null */

 BEGIN
 null;
 END submit_conc_program;

 -------------------------------------------------------------------------------------------
 ------ Procedure wait_for_conc_program is called from the wait_for_conc_program node
 ------ WF program aptrsend.wft calls this procedure
 -------------------------------------------------------------------------------------------

  PROCEDURE wait_for_conc_program (p_item_type          IN VARCHAR2,
                                   p_item_key           IN VARCHAR2,
                                   p_actid              IN NUMBER,
                                   p_funmode            IN VARCHAR2,
                                   p_result             OUT NOCOPY VARCHAR2) IS


   l_request_id        varchar2(100);
   result              varchar2(100);
   l_phase varchar2(100);
   l_status varchar2(100);
   l_dev_phase varchar2(100);
   l_dev_status varchar2(100);
   l_message varchar2(200);
   l_result boolean;

   BEGIN

     /* Get the Requst Id from the WF */

      l_request_id := wf_engine.getitemattrtext(p_item_type,
                                                  p_item_key,
                                                 'REQUEST_ID');

      /*  Call WF API to wait for conc program */


      FND_WF_STANDARD.WAITFORCONCPROGRAM(p_item_type,
                                         p_item_key,
                                         p_actid,
                                         p_funmode,
                                         p_result);

      If p_result = 'COMPLETE:'
      then
          p_result := 'SUCCESS';
      else
          p_result := 'ERROR';
      end if;


   END wait_for_conc_program ;



  ---------------------------------------------------------------------------------------
  ------- Procedure raise_event raises an event in Business Event System. Parameter
  ------- p_bank_transmission_id is passed to the event.
  -----------------------------------------------------------------------------------------

  PROCEDURE raise_event  (p_bank_transmission_id in  NUMBER) is

   i_para                         wf_parameter_t;
   l_parameter_list               wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t wf_parameter_t:= wf_parameter_t(null, null);

   l_event_key       NUMBER;
   l_org_id 	     NUMBER;
   session_org_id varchar2(100);


  BEGIN

     select xtr_payment_event_s.nextval
     into   l_event_key
     from   sys.dual;

     l_parameter_t.setName('BANK_TRANSMISSION_ID');
     l_parameter_t.setVALUE(p_bank_transmission_id);
     l_parameter_list.extend;
     l_parameter_list(1) := l_parameter_t;


     l_parameter_t.setName('USER_ID');
     l_parameter_t.setVALUE(FND_GLOBAL.USER_ID);
     l_parameter_list.extend;
     l_parameter_list(2) := l_parameter_t;

     l_parameter_t.setName('RESP_ID');
     l_parameter_t.setVALUE(FND_GLOBAL.RESP_ID);
     l_parameter_list.extend;
     l_parameter_list(3) := l_parameter_t;

     l_parameter_t.setName('RESP_APPL_ID');
     l_parameter_t.setVALUE(FND_GLOBAL.RESP_APPL_ID);
     l_parameter_list.extend;
     l_parameter_list(4) := l_parameter_t;

     fnd_profile.get(name=>'ORG_ID',val=>session_org_id);
     l_org_id := session_org_id;
     l_parameter_t.setName('ORG_ID');
     l_parameter_t.setVALUE(l_org_id);
     l_parameter_list.extend;
     l_parameter_list(5) := l_parameter_t;

      wf_event.raise(
                p_event_name => 'oracle.apps.xtr.send.payment',
                p_event_key => l_event_key,
                p_event_data => null,
                p_parameters => l_parameter_list
                );

      l_parameter_list.DELETE;

  END raise_event;




END XTR_SEND_PAYMENT_PKG;

/
