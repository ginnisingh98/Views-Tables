--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFFOBJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFFOBJ_PUB" as
/* $Header: iexpwrob.pls 120.10.12010000.3 2009/08/14 12:39:08 ehuh ship $ */
-- Start of Comments
-- Package name     :IEX_WRITEOFFOBJ_PUB
-- Purpose          : 1) Procedure to populate OKL_TRX_ADJST_B and OKL_TXL_ADJSTS_LNS_B
--                  : 2) Procedure to call OKL_WRAPPER OKL_CREATE_ADJ_PVT
--                  :    to create an adjustment
--                  : 3) Procedure to check approval before creating a writeoff.
--                  : 4) Procedure to update iex_writeoff_objects after creating

G_FILE_NAME VARCHAR2(12) ;
PG_DEBUG    NUMBER ;
wf_yes 	    varchar2(1) ;
wf_no       varchar2(1) ;

PROCEDURE AddfailMsg ( p_object IN VARCHAR2, p_operation  IN VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('IEX', 'IEX_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('UPDATE', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;

PROCEDURE Get_Messages ( p_message_count IN  NUMBER, x_message  OUT nocopy VARCHAR2) IS

  l_msg_list        VARCHAR2(32627) := '';
  l_temp_msg        VARCHAR2(32627);
  l_appl_short_name  VARCHAR2(50) ;
  l_message_name    VARCHAR2(50) ;
  l_id              NUMBER;
  l_message_num     NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(32627);
  l_new_line        VARCHAR2(10) := FND_GLOBAL.NEWLINE;

  Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
         SELECT  application_id
         FROM    fnd_application_vl
         WHERE   application_short_name = x_short_name;

  Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
         SELECT  msg.message_number
         FROM    fnd_new_messages msg, fnd_languages_vl lng
         WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;

BEGIN
      iex_debug_pub.logmessage ( 'in get message routine');
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;

          IF l_id is not NULL THEN
              OPEN Get_Message_Num (l_message_name, l_id, to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0 then
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1 then
              l_msg_list := l_msg_list || l_temp_msg || fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg || fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';
          iex_debug_pub.logmessage ( 'l_msg_lis'||l_msg_list);
      END LOOP;

      x_message := l_msg_list;
      iex_debug_pub.logmessage ( ' x_message ' ||x_message);
  EXCEPTION
    WHEN OTHERS THEN
        x_message:=l_msg_list;
END Get_Messages;


PROCEDURE Get_Messages1 ( p_message_count IN  NUMBER, x_message OUT nocopy VARCHAR2) IS

  l_msg_list        VARCHAR2(32627) := '';
  l_temp_msg        VARCHAR2(32627);
  l_appl_short_name  VARCHAR2(50) ;
  l_message_name    VARCHAR2(50) ;
  l_id              NUMBER;
  l_message_num     NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(32627);
  l_new_line        VARCHAR2(10) := FND_GLOBAL.NEWLINE;

BEGIN
     iex_debug_pub.logmessage ( 'in get message routine');
     FOR i IN 1..p_message_count
     LOOP
         fnd_msg_pub.get(p_data => l_msg_data,
                         p_msg_index_out => l_msg_count,
                         p_encoded => fnd_api.g_false,
                         p_msg_index => fnd_msg_pub.g_next);
     	 IF i = 1 THEN
	       l_msg_list := l_msg_data;
     	 ELSE
	       l_msg_list := l_msg_list  || l_new_line || l_msg_data;
    	 END IF;
      END LOOP;
      x_message:=l_msg_list;
      iex_debug_pub.logmessage ( ' x_message ' ||x_message);
  EXCEPTION
    WHEN OTHERS THEN
        x_message:=l_msg_list;
END Get_Messages1;

PROCEDURE  invoke_writeoff_wf(
                     p_WRITEOFF_ID     IN NUMBER
                    ,p_writeoff_type   IN VARCHAR2
                    ,p_request_id      IN NUMBER
                    ,p_object_id       IN VARCHAR2
              	    ,x_return_status   OUT NOCOPY VARCHAR2
                    ,x_msg_count       OUT NOCOPY NUMBER
                    ,x_msg_data        OUT NOCOPY VARCHAR2 ) IS

l_parameter_list        wf_parameter_list_t;
l_key                   VARCHAR2(240);
l_seq                   NUMBER;
l_event_name            varchar2(240) ;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      VARCHAR2(50) ;
l_api_name_full VARCHAR2(150);
l_notification_agent varchar2(100);
l_case_owner         varchar2(100);
l_case_number    varchar2(240);

TYPE c_getinvoiceCurTyp IS REF CURSOR;
c_getinvoices c_getinvoiceCurTyp;

l_object_id VARCHAR2(32627) ;
l_currency_code  VARCHAR2(10);
l_amount  NUMBER;
l_user_id number := FND_GLOBAL.User_Id;

cursor c_get_agent(p_id number) is
 -- bug 8752313
 -- SELECT name from wf_roles
 -- where  orig_system     = 'FND_RESP'
 -- and    orig_system_id  = '23366';
 select b.user_name
      from JTF_RS_RESOURCE_EXTNS a,    JTF_RS_RESOURCE_EXTNS b
      where b.source_id = nvl(a.source_mgr_id,a.source_id)
        and a.user_name = (select fu.user_name from fnd_user fu where fu.user_id = p_id);

cursor c_get_ar_invoices(p_object_id IN VARCHAR2) is
  select to_char(payment_schedule_id), invoice_currency_code, amount_due_remaining
   from ar_payment_schedules
  where customer_trx_id = p_object_id;
  --where payment_schedule_id =p_object_id;

cursor c_get_cont_invoices(p_object_id IN VARCHAR2,p_request_id IN NUMBER) is
 select chr.contract_number, sum(iwob.adjustment_amount), chr.currency_code
   from iex_writeoff_objects iwob, okc_k_headers_b chr
  where chr.id = p_object_id
    and iwob.contract_id = chr.id
    and iwob.request_id = p_request_id
  group by chr.contract_number,chr.currency_code ;

BEGIN

      SAVEPOINT invoke_writeoff_wf;
      l_event_name     := 'oracle.apps.iex.wrf.approvewriteoff';
      l_api_name       := 'invoke_writeoff_wf';
      l_api_name_full  := g_pkg_name || '.'||l_api_name;
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      AddfailMsg(p_object => 'BEFORE CALLING WORKFLOW ', p_operation => 'CREATE');

      l_key := l_event_name  ||'-'||p_request_id;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Event Key ' ||l_key ||'writeoff_type' ||p_writeoff_type||
                                   'object_id'||p_object_id|| 'request_id'||p_request_id);
      END IF;

      l_amount :=0;

      if p_writeoff_type ='AR_INVOICE' THEN
            OPEN  c_get_ar_invoices(p_object_id);
            FETCH c_get_ar_invoices  INTO l_object_id, l_currency_code, l_amount;
            CLOSE c_get_ar_invoices ;
      else
            OPEN c_get_cont_invoices(p_object_id,p_request_id);
            FETCH c_get_cont_invoices  INTO l_object_id, l_amount, l_currency_code;
            CLOSE c_get_cont_invoices;

            if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('in contracts' ||'writeoff_type' ||p_writeoff_type||
                                   'object_id'||p_object_id|| 'request_id'||p_request_id);
            end if;
      end if;

      begin
          iex_debug_pub.logmessage ('Get notify Agent User ID.....' ||l_user_id);
          OPEN c_get_agent(l_user_id) ;
          FETCH c_get_agent INTO l_notification_agent;
          if c_get_agent%NOTFOUND then null; end if;
          CLOSE c_get_Agent;

          exception
            when others then null;
      end;

      IF l_notification_agent IS NULL THEN l_notification_agent := 'SYSADMIN';
      END IF;


      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('l_case_number ' ||l_case_number || 'l_case_owner' || l_case_owner
                                   ||'<-----L_AMOUNT----->' ||l_amount);
      END IF;

      wf_event.AddParameterToList('AMOUNT', to_char(l_amount), l_parameter_list);
      --wf_event.AddParameterToList('CASE_OWNER', l_case_owner, l_parameter_list);
      --wf_event.AddParameterToList('CASE_NUMBER', l_case_number, l_parameter_list);
      wf_event.AddParameterToList('NOTIFY_AGENT', l_notification_agent, l_parameter_list);
      wf_event.AddParameterToList('REQUEST_ID', p_request_ID, l_parameter_list);
      wf_event.AddParameterToList('WRITEOFF_ID', p_writeoff_ID, l_parameter_list);
      wf_event.AddParameterToList('OBJECT_ID', l_object_ID, l_parameter_list);
      wf_event.AddParameterToList('WRITEOFF_TYPE', p_writeoff_type, l_parameter_list);
      wf_event.AddParameterToList('CURRENCY_CODE', l_currency_code, l_parameter_list);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('before launching workflow');
      END IF;

      wf_event.raise(p_event_name  => l_event_name
                    ,p_event_key   => l_key
                    ,p_parameters  => l_parameter_list);
      COMMIT ;
      l_parameter_list.DELETE;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Successfully launched writeoff workflow');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
 EXCEPTION
 WHEN OTHERS THEN
      ROLLBACK TO invoke_writeoff_wf;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('IEX_WRITEOFFOBJ_PUB','invoke_writeoff_wf');
      Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                ,p_data    => x_msg_data);
End  invoke_writeoff_wf;


PROCEDURE  invoke_asset_mgr_wf(
                     p_object_id      IN varchar2
                    ,p_request_id     IN varchar2
              	    ,x_return_status  OUT NOCOPY VARCHAR2
                    ,x_msg_count      OUT NOCOPY NUMBER
                    ,x_msg_data       OUT NOCOPY VARCHAR2 ) IS

l_parameter_list        wf_parameter_list_t;
l_key                   VARCHAR2(240);
l_seq                   NUMBER;
l_event_name            varchar2(240) ;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                 VARCHAR2(50) ;
l_api_name_full	           VARCHAR2(150);
l_notification_agent varchar2(100);
l_case_owner         varchar2(100);
l_contract_number    varchar2(120);
l_user_id number := FND_GLOBAL.User_Id;

cursor c_get_agent is
   SELECT name from   wf_roles
    where  orig_system     = 'FND_RESP'
      and  orig_system_id  = '23449';

 cursor c_get_case_owner(p_object_id IN VARCHAR2) IS
  select rs.source_name, chr.contract_number
    from iex_cases_all_b icas,
         jtf_rs_resource_extns rs,
         iex_case_objects  ico,
         okc_k_headers_b chr
 where ico.cas_id = icas.cas_id
   and icas.owner_resource_id = rs.resource_id(+)
   and chr.id = ico.object_id
   and chr.id = to_number(p_object_id);

BEGIN
      SAVEPOINT invoke_asset_mgr_wf;
      l_event_name    := 'oracle.apps.iex.wrf.terminatenotification';
      l_api_name         := 'invoke_asset_mgr_wf';
      l_api_name_full	 := g_pkg_name || '.'||l_api_name;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      AddfailMsg(p_object => 'BEFORE CALLING WORKFLOW ', p_operation => 'CREATE');

      l_key := l_event_name  ||'-'||p_request_id;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Event Key ' ||l_key);
      END IF;

      OPEN c_get_case_owner(p_object_id);
      FETCH c_get_case_owner  INTO l_case_owner, l_contract_number;
      CLOSE c_get_case_owner;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('l_contract_number ' ||l_contract_number
                                   || 'l_case_owner' || l_case_owner);
      END IF;

      begin
          OPEN c_get_agent;
          FETCH c_get_agent INTO l_notification_agent;
          if c_get_agent%NOTFOUND then null; end if;
          CLOSE c_get_Agent;

          exception
            when others then null;
      end;

      IF l_notification_agent IS NULL THEN
          l_notification_agent := 'SYSADMIN';
      END IF;

      wf_event.AddParameterToList('NOTIFY_AGENT', l_notification_agent, l_parameter_list);
      wf_event.AddParameterToList('CASE_OWNER', l_case_owner, l_parameter_list);
      wf_event.AddParameterToList('CONTRACT_NUMBER', l_contract_number, l_parameter_list);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('before launching workflow');
      END IF;

      wf_event.raise(p_event_name  => l_event_name
                    ,p_event_key   => l_key
                    ,p_parameters  => l_parameter_list);

      COMMIT ;
      l_parameter_list.DELETE;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Successfully launched asset mgr workflow');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
 EXCEPTION
 WHEN OTHERS THEN
      ROLLBACK TO invoke_asset_mgr_wf;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('IEX_WRITEOFFOBJ_PUB','invoke_asset_mgr_wf');
      Fnd_Msg_Pub.count_and_get(p_count   => x_msg_count
                               ,p_data    => x_msg_data);
End  invoke_asset_mgr_wf;


PROCEDURE create_writeoffs(
     P_Api_Version_Number           IN NUMBER
    ,p_init_msg_list                IN VARCHAR2
    ,p_commit                       IN VARCHAR2
    ,p_writeoff_object_rec          IN writeoff_obj_rec_type := g_miss_writeoff_obj_rec_type
    ,p_writeoff_type                IN VARCHAR2
    ,p_object_id                    IN VARCHAR2
    ,p_invoice_line_id              IN NUMBER
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,x_adjustment_id                OUT  NOCOPY NUMBER) IS

    l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_WRITEOFFS';
    l_api_name_full	      CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
    l_api_version_number      CONSTANT NUMBER       := 2.0;
    l_writeoff_object_id      IEX_writeoff_objects.writeoff_object_id%TYPE;
    x_adj_id                  IEX_writeoff_objects.receviables_adjustment_id%TYPE;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(32627);
    l_message VARCHAR2(32627);

    l_object_version_number IEX_writeoff_objects.writeoff_object_id%TYPE;
    l_adjv_rec adjv_rec_type;
    x_adjv_rec adjv_rec_type;
    l_ajlv_rec ajlv_rec_type;
    x_ajlv_rec ajlv_rec_type;
    l_writeoff_obj_rec  writeoff_obj_rec_type ;
    l_writeoff_rec      writeoff_rec_type ;
    l_code_combination_id  ar_adjustments.code_combination_ID%TYPE;
    l_contract_number      okc_k_headers_b.contract_number%TYPE;
    l_product okl_products_v.name%TYPE;
    l_stream  okl_strm_type_b.code%TYPE;

    cursor c_get_obj_ver(p_WRITEOFF_ID IN NUMBER) is
       select object_version_number
         from iex_writeoffs
         where WRITEOFF_ID =p_WRITEOFF_ID;

 BEGIN

      l_writeoff_obj_rec  := p_writeoff_object_rec;
      SAVEPOINT CREATE_WRITEOFFS;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME) then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FND_MSG_PUB.initialize;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_writeoff_obj_rec.writeoff_status  := 'W';
      l_writeoff_obj_rec.writeoff_type    := p_writeoff_type;
      l_writeoff_obj_rec.writeoff_type_id := p_object_id;

      IEX_WRITEOFF_OBJECTS_PUB.create_writeoff_objects(
          P_Api_Version_Number       =>p_Api_Version_Number
         ,P_Init_Msg_List            =>P_Init_Msg_List
         ,P_Commit                   =>p_commit
         ,P_writeoff_obj_rec         =>l_writeoff_obj_rec
         ,X_writeoff_object_id       =>l_writeoff_object_id
         ,x_return_status            =>l_return_status
         ,x_msg_count                =>l_msg_count
         ,x_msg_data                 =>l_msg_data);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('writeoff creation object ID '||
            l_writeoff_object_id || 'status ' ||l_return_status);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             raise FND_API.G_EXC_ERROR;

      ELSE
            FND_MSG_PUB.initialize;
      END IF;

      AddfailMsg( p_object    =>  'Writeoffs ', p_operation =>  'UPDATE' );

      OPEN  c_get_obj_ver(l_writeoff_obj_rec.writeoff_id);
      FETCH c_get_obj_ver INTO l_writeoff_rec.object_version_number;
      CLOSE c_get_obj_ver;

      l_writeoff_rec.disposition_code := 'W';
      --l_writeoff_rec.disposition_date := SYSDATE;
      l_writeoff_rec.writeoff_id:=l_writeoff_obj_rec.writeoff_id;

      IEX_WRITEOFFS_PVT.Update_writeoffs(
           P_Api_Version_Number   =>l_api_version_number
          ,P_Init_Msg_List        =>'F'
          ,P_Commit               =>'T'
          ,P_writeoffs_Rec        =>l_writeoff_rec
          ,x_return_status        => l_return_status
          ,x_msg_count            => l_msg_count
          ,x_msg_data             => l_msg_data
          ,xo_object_version_number  =>l_object_version_number
          );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             raise FND_API.G_EXC_ERROR;
      ELSE
              FND_MSG_PUB.initialize;
              if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logmessage ('obj of iex_writeoff' ||l_object_version_number
                                        ||'l_writeoff_rec.writeoff_id' || l_writeoff_obj_rec.writeoff_id);
              end if;
      END IF;

      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFFS;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFFS;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
          WHEN OTHERS THEN
                ROLLBACK TO CREATE_WRITEOFFS;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

 END create_writeoffs;

/** Intialize record defintion to avoid direct server side access of variables
 */
  FUNCTION INIT_WRITEOFFOBJ_REC
     RETURN IEX_WRITEOFFOBJ_PUB.writeoff_obj_rec_type
   IS
     l_return_rec IEX_WRITEOFFOBJ_PUB.writeoff_obj_rec_type ;
   BEGIN
        RETURN   l_return_rec;
  END INIT_WRITEOFFOBJ_REC;


/**
  called from the workflow to approve writeoffs
**/
  PROCEDURE approve_writeoffs (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               result       out nocopy varchar2) IS

l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message      VARCHAR2(32627);

l_WRITEOFF_ID     VARCHAR2(32627);
l_REQUEST_ID     VARCHAR2(32627);
l_OBJECT_ID     VARCHAR2(32627);
l_OBJECT_TYPE     VARCHAR2(100);

cursor c_get_obj_ver(p_WRITEOFF_ID IN NUMBER) is
    select object_version_number,writeoff_reason
      from iex_writeoffs
     where WRITEOFF_ID =p_WRITEOFF_ID;


--bug 8258156  add ar_payment_schedules_all to get org id
cursor c_get_writeoff_objects(p_WRITEOFF_ID IN NUMBER, p_request_id IN NUMBER) is
   select writeoff_object_id, object_version_number, transaction_id,
          adjustment_amount, contract_id, org_id
     from iex_writeoff_objects io,ar_payment_schedules_all ap
    where WRITEOFF_ID = p_WRITEOFF_ID
      and writeoff_status ='W'
      and transaction_id = payment_schedule_id(+)
      and io.request_id = p_request_id;

l_api_name                CONSTANT VARCHAR2(50) := 'APPROVE_WRITEOFFS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER       := 2.0;
l_writeoff_object_id      IEX_writeoff_objects.writeoff_object_id%TYPE;
x_adj_id                  IEX_writeoff_objects.receviables_adjustment_id%TYPE;
l_object_version_number   IEX_writeoff_objects.object_version_number%TYPE;

x_adjv_rec adjv_rec_type;
l_ajlv_rec ajlv_rec_type;
x_ajlv_rec ajlv_rec_type;
l_writeoff_obj_rec  writeoff_obj_rec_type ;
l_writeoff_rec      writeoff_rec_type ;
l_adj_reason_code   iex_writeoffs.writeoff_reason%TYPE;
l_ctr NUMBER;

l_code_combination_id  ar_adjustments.code_combination_ID%TYPE;
l_contract_number      okc_k_headers_b.contract_number%TYPE;

BEGIN

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
       end if;

       l_WRITEOFF_ID:= wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname     => 'WRITEOFF_ID');
       l_REQUEST_ID:= wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'REQUEST_ID');
       l_object_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'OBJECT_ID');
       l_object_type := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => 'WRITEOFF_TYPE');
       /** 1) insert into okl_trx_ar_adjst_b and tl
       ** 2) insert into okl_txl_adjst_lns_b and tl
       ** 3) call okl_adjst_create_pvt to create adjsutment
       ** 4) update iex_writeoff_objects with the adjustment ID
       ** 5) update iex_writeoffs disposition code to APPROVED
       ** 6) if writeoff type is CONTRACT then send asset mgr a termination notification */

      OPEN  c_get_obj_ver(l_WRITEOFF_ID);
      FETCH c_get_obj_ver INTO l_writeoff_rec.object_version_number, l_adj_reason_code;
      CLOSE c_get_obj_ver;

         -- do not process if objects are part of a different
         --transaction . this will not happen since the views already remove
         --the transaction if it is part of any other request
     l_ctr :=0;

     For i in c_get_writeoff_objects (l_writeoff_id,L_REQUEST_ID) LOOP

         l_ctr := 1;
         l_writeoff_obj_rec.WRITEOFF_OBJECT_ID :=i.writeoff_object_id;
         l_writeoff_obj_rec.OBJECT_VERSION_NUMBER :=i.object_version_number;

      --START jsanju bug 4637174 replace 3 calls with one call
      /*
         --populate the record type to be passed(l_adjv_rec)
         --l_adjv_rec.adjustment_reason_code:= l_adj_reason_code;
          l_adjv_rec.adjustment_reason_code:= 'WRITE OFF';
          l_adjv_rec.apply_date :=sysdate;
          l_adjv_rec.gl_date    := sysdate;
          l_adjv_rec.trx_status_code :='WORKING';

        -- call okl_trx_ar_adjsts_pub.insert_trx_ar_adjsts
        --set error message,so this will be prefixed before the
        --actual message, so it makes more sense than displaying an
        -- OKL message.

          AddfailMsg(
                      p_object    =>  'RECORD IN OKL_TRX_AR_ADJST_B ',
                      p_operation =>  'CREATE' );

         okl_trx_ar_adjsts_pub.insert_trx_ar_adjsts(
             p_api_version              =>1.0
            ,p_init_msg_list            =>'F'
            ,x_return_status            =>l_return_status
            ,x_msg_count                =>l_msg_count
            ,x_msg_data                 =>l_msg_data
            ,p_adjv_rec                 =>l_adjv_rec
            ,x_adjv_rec                 =>x_adjv_rec);

         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage ('okl_trx_ar_adjsts status ' ||l_return_status);
                  iex_debug_pub.logmessage ('okl_trx_ar_adjsts adj_id ' || x_adjv_rec.id);
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;

         ELSE
              FND_MSG_PUB.initialize;
         END IF;

        --else insert of okl_trx_ar_adjsts_b is successful we can go to
        --the third step of populating the okl_txl_adjsts_lns_b tables

        --populate the record type to be passed(l_ajlv_rec)

        -- call okl_txl_adjsts_lns_pub.insert_txl_adjsts_lns

         l_ajlv_rec.adj_id :=x_adjv_rec.id;
         l_ajlv_rec.psl_id :=i.transaction_id;
         l_ajlv_rec.amount :=i.adjustment_amount;

         --not sure what to pass????
        -- l_ajlv_rec.CODE_COMBINATION_ID := 17001;

         --08/13/03
         --check for code combination before creating
         --writeoff objects
           OPEN c_get_code_comb(i.transaction_id);
           FETCH c_get_code_comb INTO l_CODE_COMBINATION_ID;
           CLOSE c_get_code_comb;

           IF l_CODE_COMBINATION_ID IS NULL THEN
--               IF PG_DEBUG < 11  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage ('Error in retreiving Code combination ');
               END IF;

               select contract_number into l_contract_number
               from okc_k_headers_b
               where id=i.contract_id;

               fnd_message.set_name('IEX', 'IEX_WRITEOFFOBJ_CODE_COMB');
               fnd_message.set_token('CONTRACT_NUMBER', l_contract_number);
               fnd_msg_pub.add;
               IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
               END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
              result := wf_engine.eng_completed ||':'||wf_no;
              return;

            END IF;

           l_ajlv_rec.CODE_COMBINATION_ID := l_CODE_COMBINATION_ID;
           l_code_combination_id := null;

          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('Code combination' ||l_ajlv_rec.CODE_COMBINATION_ID );
         END IF;

        --set error message,so this will be prefixed before the
        --actual message, so it makes more sense than displaying an
        -- OKL message.
         AddfailMsg( p_object    =>  'RECORD IN OKL_TXL_ADJSTS_LNS_B ',
                     p_operation =>  'CREATE' );

         okl_txl_adjsts_lns_pub.insert_txl_adjsts_lns(
             p_api_version              =>1.0
            ,p_init_msg_list            =>'F'
            ,x_return_status            =>l_return_status
            ,x_msg_count                =>l_msg_count
            ,x_msg_data                 =>l_msg_data
            ,p_ajlv_rec                 =>l_ajlv_rec
            ,x_ajlv_rec                 =>x_ajlv_rec);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;
        ELSE
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('okl_txl_adjsts_lns status '
                                      ||l_return_status || ' Id ' ||
                                      x_ajlv_rec.id);
             END IF;
             FND_MSG_PUB.initialize;
        END IF;

        --else insert of okl_txl_adjsts_lns_b is successful we can go to
        --the fourth step of calling okl_create_adjst_pvt
  */
  --END jsanju for bug 4637174 replace 3 calls with one call.

        --set error message,so this will be prefixed before the
        --actual message, so it makes more sense than displaying an
        -- OKL message.

         AddfailMsg( p_object    =>  'Adjustments ', p_operation =>  'CREATE' );

--           IF PG_DEBUG <11 THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('Before calling Okl Api' ||'transaction id ' || i.transaction_id);
         END IF;

         -- Begin bug 8258156
         -- mo_global.set_policy_context('S',7746);
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('Before calling Okl Api Org ID = ' || i.org_id);
         END IF;

         mo_global.set_policy_context('S',i.org_id);
         -- End bug 8258156

         okl_create_adjst_pub.iex_create_adjustments_pub (
                              p_api_version          => 1
                             ,p_init_msg_list        => 'F'
                             ,p_commit_flag          => 'F'
                             ,p_psl_id               => i.transaction_id
                             ,p_chk_approval_limits  => 'F'
                             ,x_new_adj_id           => x_adj_id
                             ,x_return_status        => l_return_status
                             ,x_msg_count            => l_msg_count
                             ,x_msg_data             => l_msg_data);

--           IF PG_DEBUG <11 THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('After calling Okl Api and status'||l_return_status);
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;
         ELSE
              FND_MSG_PUB.initialize;
              if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEx_debug_pub.logmessage ('After caling OKL Adj API and adj_id ' || x_adj_id);
              end if;
         END IF;

       --else adjustment created and update iex_writeoff_objects
       --with the adjustment ID
       --populate the writeoff_obect rec

         if x_adj_id IS NOT NULL then
            l_writeoff_obj_rec.RECEVIABLES_ADJUSTMENT_ID :=x_adj_id;
            l_writeoff_obj_rec.writeoff_status :='A';
         else
--             IF PG_DEBUG < 11  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('Adjust ment ID is null ');
             END IF;

              AddfailMsg(p_object    =>  'Adjustments ',
                         p_operation =>  'CREATE' );
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;
         end if;

       --update iex_writeoff_objects
       --prefix this message before writeoff record is updated
         AddfailMsg( p_object    =>  'Writeoff Object ',
                     p_operation =>  'UPDATE' );

        IEX_WRITEOFF_OBJECTS_PUB.update_writeoff_objects(
                 P_Api_Version_Number       =>l_Api_Version_Number
                ,P_Init_Msg_List            =>'F'
                ,P_Commit                   =>'F'
                ,P_writeoff_obj_rec         =>l_writeoff_obj_rec
                ,xo_object_version_number   =>l_object_version_number
                ,x_return_status            =>l_return_status
                ,x_msg_count                =>l_msg_count
                ,x_msg_data                 =>l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;
         ELSE
              FND_MSG_PUB.initialize;
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Finished updating iex_writeoffobjects');
             END IF;

         END IF;

    END LOOP;

    if l_ctr =1 THEN
       --update iex_writeoffs
       --prefix this message before writeoff record is updated
         AddfailMsg( p_object    =>  'Writeoffs ', p_operation =>  'UPDATE' );

      -- update iex_writeoff's dispostion_code;
        l_writeoff_rec.disposition_code := 'A';
     --   l_writeoff_rec.disposition_date := SYSDATE;
        l_writeoff_rec.writeoff_id := l_writeoff_id;

        IEX_WRITEOFFS_PVT.Update_writeoffs(
           P_Api_Version_Number   => l_api_version_number
          ,P_Init_Msg_List        => 'F'
          ,P_Commit               => 'F'
          ,P_writeoffs_Rec        => l_writeoff_rec
          ,x_return_status        => l_return_status
          ,x_msg_count            => l_msg_count
          ,x_msg_data             => l_msg_data
          ,xo_object_version_number  =>l_object_version_number);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
             --raise FND_API.G_EXC_ERROR;
              result := wf_engine.eng_completed ||':'||wf_no;
              return;
         ELSE
              FND_MSG_PUB.initialize;
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage ('obj of iex_writeoff' ||l_object_version_number
                                       ||'l_writeoff_rec.writeoff_id' || l_writeoff_obj_rec.writeoff_id||
                                       'in approve writeoff procedure');
              END IF;

         END IF;

          /** if writeoff type is CONTRACT then send asset mgr a
                 termination notification
            */
          If l_object_type ='CONTRACT' THEN
             if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage('l_object_id ' || l_object_id|| 'l_request_id '|| l_request_id  );
             end if;
             -- iex_test_pub.logmessage('l_object_id ' || l_object_id||
               --                        'l_request_id '|| l_request_id  );
             invoke_asset_mgr_wf(p_object_id     => l_object_id
                                ,p_request_id    => l_request_id
              	                ,x_return_status => l_return_status
                                ,x_msg_count     => l_msg_count
	                        ,x_msg_data	 => l_msg_data );

      	     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	             Get_Messages1 (l_msg_count,l_message);
--                 IF PG_DEBUG < 11  THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('Error after calling asset mgr WF' ||l_message);
                 END IF;

                 wf_engine.SetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'ERROR_MESSAGE',
                                           avalue    => l_message);
                 --raise FND_API.G_EXC_ERROR;
                  result := wf_engine.eng_completed ||':'||wf_no;
                  return;
             ELSE
                 FND_MSG_PUB.initialize;
            END IF;
         END IF; --object_type
     END if ;--if l_ctr;

      result := wf_engine.eng_completed ||':'||wf_yes;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       --resultout := wf_engine.eng_completed ||':'||wf_no;
--      IF PG_DEBUG < 11  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('Error ' ||l_message);
       END IF;

       wf_core.context('IEX_WRITEOFFOBJ_PUB',
                       'approve_writeoffs',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
--       IF PG_DEBUG < 11  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('Error WHEN OTHERE' ||sqlerrm);
       END IF;
       wf_core.context('IEX_WRITEOFFOBJ_PUB',
                       'approve_writeoffs',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END approve_writeoffs;

/**
  called from the workflow to reject writeoff record
  update disposition_code
**/
  PROCEDURE reject_writeoffs (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2) IS
l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message      VARCHAR2(32627);


l_WRITEOFF_ID     VARCHAR2(32627);
l_REQUEST_ID     VARCHAR2(32627);

cursor c_get_obj_ver(p_WRITEOFF_ID IN NUMBER) is
select object_version_number
from iex_writeoffs
where WRITEOFF_ID =p_WRITEOFF_ID;


l_api_name                CONSTANT VARCHAR2(50) := 'REJECT_WRITEOFFS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER       := 2.0;
l_object_version_number
          IEX_writeoff_objects.writeoff_object_id%TYPE;

l_writeoff_rec      writeoff_rec_type ;
l_writeoff_obj_rec  writeoff_obj_rec_type ;

cursor c_get_writeoff_objects(p_WRITEOFF_ID IN NUMBER,
                              p_REQUEST_ID IN NUMBER) is
select writeoff_object_id,
       object_version_number
from iex_writeoff_objects
where WRITEOFF_ID =p_WRITEOFF_ID
and writeoff_status ='W'
and request_id      =p_request_id;


BEGIN

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
       end if;
      iex_debug_pub.logmessage (  'JSANJU---inside reject writeoff');
       l_WRITEOFF_ID:= wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname     => 'WRITEOFF_ID');


       l_REQUEST_ID:= wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'REQUEST_ID');

      OPEN c_get_obj_ver(l_WRITEOFF_ID);
      FETCH c_get_obj_ver INTO  l_writeoff_rec.object_version_number;
      CLOSE  c_get_obj_ver;


       --update iex_writeoff_objects
       --prefix this message before writeoff record is updated
         AddfailMsg( p_object    =>  'Writeoff Object ',
                     p_operation =>  'UPDATE' );

       FOR i in c_get_writeoff_objects (l_writeoff_id,L_REQUEST_ID)
       LOOP
           l_writeoff_obj_rec.writeoff_object_id :=i.writeoff_object_id;
           l_writeoff_obj_rec.writeoff_status :='R';
           l_writeoff_obj_rec.object_version_number :=i.object_version_number;

           IEX_WRITEOFF_OBJECTS_PUB.update_writeoff_objects(
            P_Api_Version_Number       =>l_Api_Version_Number
           ,P_Init_Msg_List            =>'F'
           ,P_Commit                   =>'F'
           ,P_writeoff_obj_rec         =>l_writeoff_obj_rec
           ,xo_object_version_number   =>l_object_version_number
           ,x_return_status            =>l_return_status
           ,x_msg_count                =>l_msg_count
           ,x_msg_data                 =>l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message);
             END IF;
             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
                 --raise FND_API.G_EXC_ERROR;
                  result := wf_engine.eng_completed ||':'||wf_no;
                  return;
         ELSE
              FND_MSG_PUB.initialize;
         END IF;

      END LOOP;

       --update iex_writeoff_objects
       --prefix this message before writeoff record is updated
         AddfailMsg( p_object    =>  'Writeoffs ',
                     p_operation =>  'UPDATE' );

      -- update iex_writeoff's dispostion_code;
        l_writeoff_rec.disposition_code := 'R';
        --l_writeoff_rec.disposition_date := SYSDATE;
        l_writeoff_rec.writeoff_id := l_writeoff_id;

        IEX_WRITEOFFS_PVT.Update_writeoffs(
           P_Api_Version_Number   =>l_api_version_number
          ,P_Init_Msg_List        =>'F'
          ,P_Commit               =>'F'
          ,P_writeoffs_Rec        =>l_writeoff_rec
          ,x_return_status        => l_return_status
          ,x_msg_count            => l_msg_count
          ,x_msg_data             => l_msg_data
          ,xo_object_version_number => l_object_version_number);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IEX_WRITEOFFOBJ_PUB.Get_Messages1 (l_msg_count,l_message);
--             IF PG_DEBUG <11 THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('Error' ||l_message||itemkey||itemtype);
             END IF;

             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'ERROR_MESSAGE',
                                avalue    => l_message);
                 --raise FND_API.G_EXC_ERROR;
                  result := wf_engine.eng_completed ||':'||wf_no;
                  return;

         ELSE
              FND_MSG_PUB.initialize;
         END IF;

      result := wf_engine.eng_completed ||':'||wf_yes;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_WRITEOFFOBJ_PUB',
                       'reject_writeoffs',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_WRITEOFFOBJ_PUB',
                       'reject_writeoffs',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END reject_writeoffs;

BEGIN

    G_FILE_NAME  := 'iexpwrob.pls';
    PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    wf_yes := 'Y';
    wf_no  :='N';
END IEX_WRITEOFFOBJ_PUB;




/
