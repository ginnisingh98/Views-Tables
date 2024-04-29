--------------------------------------------------------
--  DDL for Package Body OKL_CURE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_WF" as
/* $Header: OKLCOWFB.pls 120.4 2007/06/18 19:31:28 pdevaraj noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;


--private procedure
/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
        fnd_message.set_token('API_NAME', p_api_name);
        fnd_message.set_token('MISSING_PARAM', p_param_name);
        fnd_msg_pub.add;

END AddMissingArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object and
  ** the operation (insert, update ,delete)
*/

PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('OKL', 'OKL_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;


PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_message       OUT NOCOPY VARCHAR2) IS


  l_msg_list        VARCHAR2(32627) := '';
  l_temp_msg        VARCHAR2(32627);
  l_appl_short_name  VARCHAR2(50) ;
  l_message_name    VARCHAR2(50) ;
  l_id              NUMBER;
  l_message_num     NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(32627);

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
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_message := l_msg_list;


END Get_Messages;

PROCEDURE  invoke_report_wf(
                    p_report_id       IN NUMBER
            	   ,x_return_status   OUT NOCOPY VARCHAR2
                   ,x_msg_count       OUT NOCOPY NUMBER
                   ,x_msg_data        OUT NOCOPY VARCHAR2 ) IS

l_parameter_list        wf_parameter_list_t;
l_key                   VARCHAR2(240);
l_seq                   NUMBER;
l_event_name            varchar2(240) := 'oracle.apps.okl.co.approverequest';

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);

l_api_name                CONSTANT VARCHAR2(50) := 'INVOKE_REPORT_WF';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
-- Selects the nextval from sequence, used later for defining event key
CURSOR okl_key_csr IS
SELECT okl_wf_item_s.nextval
FROM   dual;

cursor c_get_ref_details (p_cure_report_id IN NUMBER)
is select  crt.report_number
          ,pov.vendor_name
from okl_cure_reports crt,
     po_vendors pov
where crt.vendor_id =pov.vendor_id
and crt.cure_report_id =p_cure_report_id;

l_report_number  okl_cure_reports.report_number%TYPE;

l_vendor_name   po_vendors.vendor_name%TYPE;
l_notification_agent varchar2(100);

cursor c_get_agent(p_user_id IN NUMBER) is
select wfr.name
from   fnd_user fuser,wf_roles wfr
where   orig_system = 'PER'
and wfr.orig_system_id =fuser.employee_id
and fuser.user_id =p_user_id;


l_user_id   NUMBER := to_number(fnd_profile.value('OKL_CURE_APPROVAL_USER'));


BEGIN

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : START');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
      -- OKL message.
       AddfailMsg(
                  p_object    =>  'BEFORE CALLING WORKFLOW ',
                  p_operation =>  'CREATE' );

      SAVEPOINT INVOKE_REPORT_WF;
  	  OPEN okl_key_csr;
	  FETCH okl_key_csr INTO l_seq;
	  CLOSE okl_key_csr;
      l_key := l_event_name  ||'-'||l_seq;

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : l_key : '|| l_key);

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Event Key ' ||l_key);
         END IF;
      END IF;

      OPEN c_get_ref_details (p_REPORT_id );

      FETCH c_get_ref_details INTO l_report_number,
                                    l_vendor_name;

      CLOSE c_get_ref_details;

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : l_report_number : '|| l_report_number);
  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : l_vendor_name : '|| l_vendor_name);

     OPEN c_get_agent (l_user_id);
     FETCH c_get_agent INTO l_notification_agent;
     CLOSE c_get_Agent;

     IF l_notification_agent IS NULL THEN
          l_notification_agent := 'SYSADMIN';
     END IF;

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : l_notification_agent : '|| l_notification_agent);

      wf_event.AddParameterToList('NOTIFY_AGENT',
                                      l_notification_agent,
                                      l_parameter_list);

      wf_event.AddParameterToList('REPORT_ID',
                                      to_char(p_report_id),
                                      l_parameter_list);


      wf_event.AddParameterToList('VENDOR_NAME',
                                      l_vendor_name,
                                      l_parameter_list);

     wf_event.AddParameterToList('REPORT_NUMBER',
                                      l_REPORT_number,
                                      l_parameter_list);
     --added by akrangan
     wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);


     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before launching workflow');

     END IF;

      wf_event.raise(p_event_name  => l_event_name
                     ,p_event_key  => l_key
                    ,p_parameters  => l_parameter_list);

      COMMIT ;
      l_parameter_list.DELETE;

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : after launching cure request wf');

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully launched Cure REPORT workflow');
         END IF;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : END');

 EXCEPTION
 WHEN OTHERS THEN
      ROLLBACK TO INVOKE_REPORT_WF;
      okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : error launching cure request wf');
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_WF','INVOKE_REPORT_WF');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

End  invoke_REPORT_wf;


PROCEDURE  approve_cure_reports
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_report_id            IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )IS
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'APPROVE_CURE_REPORTS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
 lp_crtv_rec         okl_crt_pvt.crtv_rec_type;
 lx_crtv_rec     	 okl_crt_pvt.crtv_rec_type;

cursor c_get_obj_ver(p_report_id IN NUMBER) is
select object_version_number
from okl_cure_reports
where cure_report_id =p_report_id;


BEGIN

  okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : START');
  okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : p_report_id : '||p_report_id);
      SAVEPOINT APPROVE_CURE_REPORTS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
     --call refund_workflow
      invoke_report_wf(
                  p_report_id=>p_report_id
            	 ,x_return_status	=> l_return_status
			      ,x_msg_count		=> l_msg_count
			      ,x_msg_data	    => l_msg_data );

  okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : invoke_report_wf : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after calling WF' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          FND_MSG_PUB.initialize;
    END IF;


    --Update Cure REPORTS headers table
    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REPORTS ',
                  p_operation =>  'UPDATE' );

      lp_crtv_rec.cure_report_id :=p_report_id;
      lp_crtv_rec.approval_status :='PENDING';

      OPEN c_get_obj_ver(p_report_id);
      FETCH c_get_obj_ver INTO  lp_crtv_rec.object_version_number;
      CLOSE  c_get_obj_ver;

     OKL_cure_reports_pub.update_cure_reports(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crtv_rec        => lp_crtv_rec
                          ,x_crtv_rec        => lx_crtv_rec);

  okl_debug_pub.logmessage('OKL_CURE_WF: invoke_report_wf : OKL_cure_reports_pub.update_cure_reports : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after updating cure reports'
                                           ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;

   IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )THEN
         COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : END');

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REPORTS;
      okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : Fnd_Api.G_EXC_ERROR');
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REPORTS;
      okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : Fnd_Api.G_EXC_UNEXPECTED_ERROR');
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO APPROVE_CURE_REPORTS;
      okl_debug_pub.logmessage('OKL_CURE_WF: approve_cure_reports : OTHERS');
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_WF','APPROVE_CURE_REPORTS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END APPROVE_CURE_REPORTS;




/**
  called from the workflow to update cure reports based on
  the approval
**/
  PROCEDURE set_approval_status (itemtype        in varchar2,
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

l_cure_report_id     VARCHAR2(32627);
lp_crtv_rec         okl_crt_pvt.crtv_rec_type;
lx_crtv_rec     	okl_crt_pvt.crtv_rec_type;

cursor c_get_obj_ver(p_report_id IN NUMBER) is
select object_version_number
from okl_cure_reports
where cure_report_id =p_report_id;


BEGIN

  okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : START');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
       end if;

       l_cure_report_id:= wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'REPORT_ID');

  okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : l_cure_report_id : '||l_cure_report_id);

      lp_crtv_rec.cure_report_id :=l_cure_report_id;
      lp_crtv_rec.approval_status :='APPROVED';

      OPEN c_get_obj_ver(l_cure_report_id);
      FETCH c_get_obj_ver INTO  lp_crtv_rec.object_version_number;
      CLOSE  c_get_obj_ver;

     OKL_cure_reports_pub.update_cure_reports(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crtv_rec        => lp_crtv_rec
                          ,x_crtv_rec        => lx_crtv_rec);

  okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : OKL_cure_reports_pub.update_cure_reports : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after updating cure reports'
                                           ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     END IF;

  okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : END');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : FND_API.G_EXC_ERROR');
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CURE_WF',
                       'set_approval_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then
      okl_debug_pub.logmessage('OKL_CURE_WF: set_approval_status : OTHERS');
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CURE_WF',
                       'set_approval_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END set_approval_status;

/**
  called from the workflow to update cure reports based on
  the approval
**/
  PROCEDURE set_reject_status (itemtype        in varchar2,
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

l_cure_report_id VARCHAR2(32627);
lp_crtv_rec         okl_crt_pvt.crtv_rec_type;
lx_crtv_rec     	okl_crt_pvt.crtv_rec_type;
cursor c_get_obj_ver(p_report_id IN NUMBER) is
select object_version_number
from okl_cure_reports
where cure_report_id =p_report_id;



BEGIN

  okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : START');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
       end if;

       l_cure_report_id:= wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'REPORT_ID');


  okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : l_cure_report_id : '||l_cure_report_id);

      lp_crtv_rec.cure_report_id :=l_cure_report_id;
      lp_crtv_rec.approval_status :='REJECTED';

      OPEN c_get_obj_ver(l_cure_report_id);
      FETCH c_get_obj_ver INTO  lp_crtv_rec.object_version_number;
      CLOSE  c_get_obj_ver;

     OKL_cure_reports_pub.update_cure_reports(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crtv_rec        => lp_crtv_rec
                          ,x_crtv_rec        => lx_crtv_rec);

  okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : OKL_cure_reports_pub.update_cure_reports : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after updating cure reports'
                                           ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     END IF;

  okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : END');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : FND_API.G_EXC_ERROR');
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CURE_WF',
                       'set_reject_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then

      okl_debug_pub.logmessage('OKL_CURE_WF: set_reject_status : OTHERS');
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CURE_WF',
                       'set_reject_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END set_reject_status;

END OKL_CURE_WF;

/
