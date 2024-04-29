--------------------------------------------------------
--  DDL for Package Body IEX_DEL_CREATE_EVT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DEL_CREATE_EVT_PVT" AS
/* $Header: iexdevtb.pls 120.0 2005/06/15 17:39:39 acaraujo noship $ */

PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
l_enabled varchar2(5) := 'N';

PROCEDURE  RAISE_EVENT(
	ERRBUF        OUT NOCOPY     VARCHAR2,
	RETCODE       OUT NOCOPY     VARCHAR2,
    P_REQUEST_ID  IN             NUMBER) IS


   l_parameter_list        wf_parameter_list_t;
   l_key                   VARCHAR2(240);
   l_seq                   NUMBER;
   l_event_name            varchar2(240) := 'oracle.apps.iex.delinquency.create';
   l_evt_ctr               NUMBER ;
   l_request_id           NUMBER;

   cursor c_get_del(l_request_id IN NUMBER) is
   select party_cust_id,delinquency_id,status,
          cust_account_id,customer_site_use_id,
          payment_schedule_id,case_id
   from iex_delinquencies
   where request_id = l_request_id;



BEGIN
       l_request_id :=p_request_id;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Start Raise Delinquency Event Concurrent program');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||SYSDATE);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Request Id = ' ||l_request_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');


       --Event Counter
       l_evt_ctr :=0;
       for i in c_get_del(l_request_id)
       LOOP
           select iex_del_wf_s.nextval INTO l_seq from dual;
           l_key := l_event_name  ||'-'||i.delinquency_id || '-'||l_seq;
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                write_log(FND_LOG.LEVEL_STATEMENT,' EVENT KEY ' ||l_key );
                write_log(FND_LOG.LEVEL_STATEMENT,'****************************************');
                write_log(FND_LOG.LEVEL_STATEMENT,
                                    ' STATUS ='           ||i.status
                                   ||' PARTY = '          ||i.party_cust_id
                                   ||' ACCOUNT = '        ||i.cust_account_id
                                   ||' BILL_TO ='         ||i.customer_site_use_id
                                   ||' PAYMENT SCHEDULE ='||i.payment_schedule_id
                                   ||' CASE  ='           ||i.case_id
                                   ||' DELINQUENCY = '    ||i.delinquency_id
                                   );

           END IF;

           wf_event.AddParameterToList('PARTY_ID',
                                  to_char(i.party_cust_id),
                                  l_parameter_list);
           wf_event.AddParameterToList('COLLECTION_STATUS',
                                   i.status,
                                   l_parameter_list);
           wf_event.AddParameterToList('ACCOUNT_ID',
                                  to_char(i.cust_account_id),
                                  l_parameter_list);
           wf_event.AddParameterToList('BILL_TO_ID',
                                   to_char(i.customer_site_use_id),
                                   l_parameter_list);
           wf_event.AddParameterToList('PAYMENT SCHEDULE_ID',
                                  to_char(i.payment_schedule_id),
                                  l_parameter_list);
           wf_event.AddParameterToList('CASE_ID',
                                   to_char(i.case_id),
                                   l_parameter_list);
           wf_event.AddParameterToList('DELINQUENCY_ID',
                                  to_char(i.delinquency_id),
                                  l_parameter_list);


           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              write_log(FND_LOG.LEVEL_STATEMENT,
                        ' Before Launching Event ');
           END IF;

          wf_event.raise(p_event_name  => l_event_name
                         ,p_event_key  => l_key
                         ,p_parameters  => l_parameter_list);

          COMMIT ;

          l_parameter_list.DELETE;
          l_evt_ctr:=l_evt_ctr +1;
      END LOOP;

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'No of Events raised :'||l_evt_ctr);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'End Raise Delinquency Event Concurrent program');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

EXCEPTION
    WHEN OTHERS THEN
       write_log(FND_LOG.LEVEL_UNEXPECTED,
          'Raise Delinquency Event Concurrent program raised exception '
          || sqlerrm);
       close c_get_del;
END RAISE_EVENT;

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2) is
l_schema varchar2(10);
l_dot varchar2(10);
l_module varchar2(10);
BEGIN
    if (mesg_level >= l_msgLevel) then
        fnd_file.put_line(FND_FILE.LOG, mesg);
    end if;
END write_log;

BEGIN
    l_enabled := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (l_enabled = 'N') then
       l_MsgLevel := FND_LOG.LEVEL_UNEXPECTED;
    else
       l_MsgLevel := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;


END IEX_DEL_CREATE_EVT_PVT;

/
