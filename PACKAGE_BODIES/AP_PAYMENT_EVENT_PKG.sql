--------------------------------------------------------
--  DDL for Package Body AP_PAYMENT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAYMENT_EVENT_PKG" as
/* $Header: appevntb.pls 120.2 2005/08/31 15:14:19 rlandows noship $ */

  ---------------------------------------------------------------------------------------
  ------- Procedure raise_event raises an event in Business Event System. Parameter
  ------- p_check_id is passed to the event. This procedure is being called in
  ------- in APXPAWKB.fmb for single payments and Confirm Program for the payment batches
  -----------------------------------------------------------------------------------------

  PROCEDURE raise_event  (p_check_id      in  NUMBER,
                          p_org_id        in  NUMBER) is

   i_para                         wf_parameter_t;
   l_parameter_list               wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t wf_parameter_t:= wf_parameter_t(null, null);

   l_event_key       NUMBER;

  BEGIN

     select ap_payment_event_s.nextval
     into   l_event_key
     from   sys.dual;

     l_parameter_t.setName('CHECK_ID');
     l_parameter_t.setVALUE(p_check_id);
     l_parameter_list.extend;
     l_parameter_list(1) := l_parameter_t;

     l_parameter_t.setName('ORG_ID');
     l_parameter_t.setVALUE(p_org_id);
     l_parameter_list.extend;
     l_parameter_list(2) := l_parameter_t;


      wf_event.raise(
                p_event_name => 'oracle.apps.ap.payment',
                p_event_key => l_event_key,
                p_event_data => null,
                p_parameters => l_parameter_list
                );

      l_parameter_list.DELETE;

  END raise_event;

 -------------------------------------------------------------------------------------------
 ------- Procedure raise_payment_batch_events
 -------
 -------------------------------------------------------------------------------------------


 PROCEDURE raise_payment_batch_events (p_checkrun_name           in VARCHAR2,
                                       p_checkrun_id             in number,
                                       p_completed_pmts_group_id in number,
                                       p_org_id                  in number) IS

   CURSOR get_check_info is
   SELECT AC.check_id,
          AC.org_id
   FROM   ap_checks AC
   WHERE  AC.checkrun_name = p_checkrun_name
   AND    AC.ORG_ID = p_org_id
   AND    AC.completed_pmts_group_id = p_completed_pmts_group_id
   AND    AC.status_lookup_code NOT IN ('OVERFLOW','SET UP');

   rec_get_check_info get_check_info%ROWTYPE;


 BEGIN

    OPEN get_check_info;

    LOOP

       FETCH get_check_info INTO rec_get_check_info;

       EXIT WHEN get_check_info%NOTFOUND;

       AP_PAYMENT_EVENT_PKG.raise_event(rec_get_check_info.check_id,rec_get_check_info.org_id);

    END LOOP;

    CLOSE get_check_info;

 END raise_payment_batch_events;

END AP_PAYMENT_EVENT_PKG;

/
