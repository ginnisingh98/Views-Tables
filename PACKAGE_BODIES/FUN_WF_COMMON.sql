--------------------------------------------------------
--  DDL for Package Body FUN_WF_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_WF_COMMON" AS
/* $Header: FUN_WF_COMMON_B.pls 120.24.12010000.6 2010/01/13 08:03:44 ychandra ship $ */

/*-----------------------------------------------------
 * FUNCTION generate_event_key
 * ----------------------------------------------------
 * Get the attributes for the recipient WF.
 * ---------------------------------------------------*/

FUNCTION generate_event_key (
    batch_id IN number,
    trx_id IN number) RETURN varchar2
IS
    l_result    varchar2(64);
BEGIN
    l_result := TO_CHAR(batch_id)||'_'||TO_CHAR(trx_id)||SYS_GUID();
    RETURN l_result;
END generate_event_key;



/*-----------------------------------------------------
 * FUNCTION concat_msg_stack
 * ----------------------------------------------------
 * Pop <p_depth> messages off the fnd_message stack and
 * concat them, separated by '\n'.
 *
 * If there are not enough messages in the stack, then
 * all the messages are popped.
 * ---------------------------------------------------*/

FUNCTION concat_msg_stack (
    p_depth IN number,
    p_flush IN boolean  default TRUE) RETURN varchar2
IS
    i           number;
    l_depth     number;
    l_result    varchar2(2000) ;
    l_curr      varchar2(2000);
    l_msg_index number;
BEGIN
    l_result :='';
    IF (p_depth = 0) THEN
        RETURN '';
    END IF;

    l_depth := fnd_msg_pub.count_msg;
    IF (p_depth < l_depth) THEN
        l_depth := p_depth;
    END IF;

    FOR i IN 1..l_depth LOOP
        IF i = 1
        THEN
            fnd_msg_pub.get(fnd_msg_pub.g_first, 'F', l_curr, l_msg_index);
        ELSE
            fnd_msg_pub.get(fnd_msg_pub.g_next, 'F', l_curr, l_msg_index);
        END IF;
        IF ( nvl(p_flush,TRUE)) THEN
            fnd_msg_pub.delete_msg(l_msg_index);
        END IF;
        l_result := l_result || l_curr || fnd_global.newline;
    END LOOP;

    fnd_msg_pub.get(fnd_msg_pub.g_next, 'F', l_curr, l_msg_index);
    IF ( nvl(p_flush,TRUE)) THEN
        fnd_msg_pub.delete_msg(l_msg_index);
    END IF;
    l_result := l_result || l_curr;
    RETURN l_result;
END concat_msg_stack;



/*-----------------------------------------------------
 * FUNCTION get_contact_role
 * ----------------------------------------------------
 * Get the contact for this party into an item attr
 * called CONTACT.
 * It assumes there is an item attr called PARTY_ID.
 * ---------------------------------------------------*/

FUNCTION get_contact_role (
    p_party_id    IN number) RETURN varchar2
IS
    l_role_name     varchar2(30) ;
    l_role_display  varchar2(60);
    l_exp_date      date ;
    l_users         varchar2(360) ;
    l_wf_user       varchar2(360);
    l_hz_user_id    number;
    l_dummy         varchar2(60);
    l_count 	    number ;
    l_exist         number;
    l_role_name_db     varchar2(30);


BEGIN
    -- Function not used anymore.

    NULL;


    RETURN l_role_name;
END get_contact_role;


/*-----------------------------------------------------
 * PROCEDURE is_arap_batch_mode
 * ----------------------------------------------------
 * Check whether AR/AP transfer is in batch mode.
 * ---------------------------------------------------*/

PROCEDURE is_arap_batch_mode (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_result    boolean;
BEGIN
    IF (funcmode = 'RUN' OR funcmode = 'CANCEL') THEN
        l_result := fun_system_options_pkg.is_apar_batch();
        IF (l_result) THEN
            resultout := wf_engine.eng_completed||':T';
        ELSE
            resultout := wf_engine.eng_completed||':F';
        END IF;

        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_WF_COMMON', 'IS_ARAP_BATCH_MODE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END is_arap_batch_mode;



/*-----------------------------------------------------
 * PROCEDURE raise_complete
 * ----------------------------------------------------
 * Raise the complete event.
 * ---------------------------------------------------*/

PROCEDURE raise_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_batch_id      number;
    l_trx_id        number;
    l_event_key     varchar2(240);
    l_params        wf_parameter_list_t := wf_parameter_list_t();
BEGIN
    IF (funcmode = 'RUN') THEN
        l_batch_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'BATCH_ID');
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');
        l_event_key := fun_wf_common.generate_event_key(l_batch_id, l_trx_id);

        wf_event.AddParameterToList(p_name => 'TRX_ID',
                                 p_value => TO_CHAR(l_trx_id),
                                 p_parameterlist => l_params);
        wf_event.AddParameterToList(p_name => 'BATCH_ID',
                                 p_value => TO_CHAR(l_batch_id),
                                 p_parameterlist => l_params);

        wf_event.raise(
                p_event_name => 'oracle.apps.fun.manualtrx.complete.send',
                p_event_key  => l_event_key,
                p_parameters => l_params);

        l_params.delete();
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_WF_COMMON', 'RAISE_COMPLETE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END raise_complete;


/*-----------------------------------------------------
 * PROCEDURE update_status_error
 * ----------------------------------------------------
 * Update status to error.
 * ---------------------------------------------------*/

PROCEDURE update_status_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'ERROR');
        -- TODO: check return status
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_ERROR',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_status_error;


/*-----------------------------------------------------
 * PROCEDURE update_status_received
 * ----------------------------------------------------
 * Update status to received.
 * ---------------------------------------------------*/

PROCEDURE update_status_received (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'RECEIVED');
        -- TODO: check return status
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_RECIPIENT_WF', 'UPDATE_STATUS_RECEIVED',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_status_received;


/*-----------------------------------------------------
 * PROCEDURE update_status_complete
 * ----------------------------------------------------
 * Update status to complete.
 * ---------------------------------------------------*/

PROCEDURE update_status_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_status        varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(1000);
BEGIN
    IF (funcmode = 'RUN') THEN
        l_trx_id := wf_engine.GetItemAttrNumber
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'TRX_ID');

        fun_trx_pvt.update_trx_status
                        (p_api_version => 1.0,
                         x_return_status => l_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_trx_id => l_trx_id,
                         p_update_status_to => 'COMPLETE');
        -- TODO: check return status
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
        RETURN;
    END IF;

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN others THEN
            wf_core.context('FUN_WF_COMMON', 'UPDATE_STATUS_COMPLETE',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END update_status_complete;


/*-----------------------------------------------------
 * PROCEDURE raise_wf_bus_event
 * ----------------------------------------------------
 * Raise workflow business event
 * ---------------------------------------------------*/

PROCEDURE raise_wf_bus_event (
    batch_id   IN number,
    trx_id     IN number default null,
    event_key  IN varchar2 default null,
    event_name IN varchar2 default null)
IS
  l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
  l_user_id       NUMBER;
  l_resp_id       NUMBER;
  l_appl_id       NUMBER;
  l_user_env_lang VARCHAR2(5);
  CURSOR c_trx ( p_batch_id  NUMBER) IS
  SELECT trx_id
  FROM   fun_trx_headers
  WHERE  batch_id = p_batch_id;

begin
--Bug: 7639191
 l_user_id  := fnd_global.user_id;
 l_resp_id  := fnd_global.resp_id;
 l_appl_id  := fnd_global.resp_appl_id;

 select USERENV('LANG')
 INTO l_user_env_lang
 FROM DUAL;

 FND_GLOBAL.APPS_INITIALIZE(l_user_id,l_resp_id,l_appl_id);

 WF_EVENT.AddParameterToList(p_name=>'BATCH_ID',
                             p_value=>TO_CHAR(batch_id),
                             p_parameterlist=>l_parameter_list);
 WF_EVENT.AddParameterToList(p_name=>'RESP_ID',
                             p_value=>TO_CHAR(l_resp_id),
                             p_parameterlist=>l_parameter_list);
 WF_EVENT.AddParameterToList(p_name=>'USER_ID',
                             p_value=>TO_CHAR(l_user_id),
                             p_parameterlist=>l_parameter_list);
 WF_EVENT.AddParameterToList(p_name=>'APPL_ID',
                             p_value=>TO_CHAR(l_appl_id),
                             p_parameterlist=>l_parameter_list);
 IF trx_id is not null then
    WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                             p_value=>TO_CHAR(trx_id),
                             p_parameterlist=>l_parameter_list);
 END IF;

 /* Start of changes for AME Uptake, 3671923. 11 Oct 2004 */
 IF (event_name IS NULL
 OR event_name = 'oracle.apps.fun.manualtrx.batch.send')
 THEN
	WF_EVENT.AddParameterToList(p_name=>'USER_LANG',
                             p_value=>TO_CHAR(l_user_env_lang),
                             p_parameterlist=>l_parameter_list);
    IF  trx_id IS NOT NULL
    THEN
        -- Initialize the AME Approval Process
        ame_api2.clearallapprovals(applicationIdIn   => 435,
                                transactionTypeIn => 'FUN_IC_RECI_TRX',
                                transactionIdIn   => trx_id);
    ELSE
        FOR l_trx IN c_trx(batch_id)
        LOOP
            -- Initialize the AME Approval Process
            ame_api2.clearallapprovals(applicationIdIn   => 435,
                                transactionTypeIn => 'FUN_IC_RECI_TRX',
                                transactionIdIn   => l_trx.trx_id);

        END LOOP;

    END IF;
 END IF;

 /* End of changes for AME Uptake, 3671923. 11 Oct 2004 */

 IF event_name is not null then
   WF_EVENT.RAISE(p_event_name =>event_name,
                p_event_key  =>nvl(event_key,'Test '||batch_id),
                p_parameters =>l_parameter_list);
 ELSE
   WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.manualtrx.batch.send',
                p_event_key  =>nvl(event_key,'Test '||batch_id),
                p_parameters =>l_parameter_list);
 END IF;
END raise_wf_bus_event;


/* Start of changes for AME Uptake, 3671923. 07 Jun 2004 */

/* ---------------------------------------------------------------------------
Name      : get_ame_contacts
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the various intercompany workflows
            to get the contact list to whom FYI notifications need to be
            sent out.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
            'Y' indicates contacts were found, 'N' indicates no contacts
Notes     : None.
Testing   : This function will be tested via workflows FUNARINT, FUNAPINT,
            FUNGLINT, FUNRTVAL, FUNIMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_ame_contacts (itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2 )
IS
l_approvers_found          VARCHAR2(1);
l_process_complete         VARCHAR2(1);
l_transaction_id           NUMBER;
l_role_name                VARCHAR2(30);
l_contact_type             VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_ame_admin_user           VARCHAR2(30);
l_error_message            VARCHAR2(2000);

BEGIN

    l_transaction_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRX_ID');

    l_contact_type := wf_engine.GetActivityAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         actid    => actid,
                                         aname    => 'CONTACT_ORG_TYPE');

    -- Call the procedure which will return the AME role
    fun_wf_common.get_ame_role_list
                   (itemkey            => itemkey,
                    p_transaction_id   => l_transaction_id,
                    p_fyi_notification => 'Y',
                    p_contact_type     => l_contact_type,
                    x_approvers_found  => l_approvers_found,
                    x_process_complete => l_process_complete,
                    x_role             => l_role_name,
                    x_return_status    => l_return_status,
                    x_ame_admin_user   => l_ame_admin_user,
                    x_error_message    => l_error_message);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        wf_engine.SetItemAttrText(itemtype => itemtype,
		  itemkey => itemkey,
		  aname   => 'AME_ADMIN_USER',
		  avalue  => l_ame_admin_user);

        wf_engine.SetItemAttrText(itemtype => itemtype,
		  itemkey => itemkey,
		  aname   => 'AME_ERROR',
		  avalue  => l_error_message);

        resultout := wf_engine.eng_completed||':'||'ERROR';
    ELSIF l_approvers_found = 'N'
    THEN
        resultout := wf_engine.eng_completed||':'||'NO';
    ELSIF l_approvers_found = 'Y'
    THEN
        -- Set the workflow attribute for CONTACT
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'CONTACT',
                                  avalue  => l_role_name);

        resultout := wf_engine.eng_completed||':'||'YES';
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_wf_common.get_ame_contacts',
                          SQLERRM || ' Error occurred '||
                          ' for transaction ' || l_transaction_id);
        END IF;

        wf_core.context('FUN_WF_COMMON', 'GET_AME_CONTACTS',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
END get_ame_contacts;

/* ---------------------------------------------------------------------------
Name      : get_ame_approvers
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the Recipient Main workflow
            to get the contact list to whom request for approval notfications
            are sent out.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
            'NOTIFY' indicates approvers were found,
            'COMPLETE' indicates no more approvals required - process is complete
            'ERROR' indicates there was an error
            'WAIT' indicates we are waiting for some approver to respond to notification
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_ame_approvers (itemtype   IN VARCHAR2,
                            itemkey     IN VARCHAR2,
                            actid       IN NUMBER,
                            funcmode    IN VARCHAR2,
                            resultout   OUT NOCOPY VARCHAR2 )
IS
l_approvers_found        VARCHAR2(1);
l_process_complete       VARCHAR2(1);
l_transaction_id         NUMBER;
l_role_name              VARCHAR2(30);
l_contact_type           VARCHAR2(1);
l_trx_status             fun_trx_headers.status%TYPE;
l_return_status          VARCHAR2(1);
l_ame_admin_user         VARCHAR2(30);
l_error_message          VARCHAR2(2000);


BEGIN

    l_transaction_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRX_ID');

    l_contact_type := wf_engine.GetActivityAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         actid    => actid,
                                         aname    => 'CONTACT_ORG_TYPE');

    -- Initialize the UI Action and Approver name workflow attributes.
    -- They will get set if and when user takes some approval action
    -- from the UI
    wf_engine.SetItemAttrText
      (itemtype => 'FUNRMAIN',
       itemkey  => itemkey,
       aname    => 'UI_ACTION_TYPE',
       avalue   => 'NONE');

    wf_engine.SetItemAttrText
      (itemtype => 'FUNRMAIN',
       itemkey  => itemkey,
       aname    => 'UI_ACTION_USER_NAME',
       avalue    => NULL);

    wf_engine.SetItemAttrNumber
      (itemtype => 'FUNRMAIN',
       itemkey  => itemkey,
       aname    => 'UI_ACTION_USER_ID',
       avalue    => NULL);

    -- Call the procedure which will return the AME role list
    fun_wf_common.get_ame_role_list
                       (itemkey            => itemkey,
                        p_transaction_id   => l_transaction_id,
                        p_fyi_notification => 'N',
                        p_contact_type     => l_contact_type,
                        x_approvers_found  => l_approvers_found,
                        x_process_complete => l_process_complete,
                        x_role             => l_role_name,
                        x_return_status    => l_return_status ,
                        x_ame_admin_user   => l_ame_admin_user,
                        x_error_message    => l_error_message);

    -- Check if Approval process is complete or was there an error
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        wf_engine.SetItemAttrText(itemtype => itemtype,
		  itemkey => itemkey,
		  aname   => 'AME_ADMIN_USER',
		  avalue  => l_ame_admin_user);

        wf_engine.SetItemAttrText(itemtype => itemtype,
		  itemkey => itemkey,
		  aname   => 'AME_ERROR',
		  avalue  => l_error_message);

        resultout := wf_engine.eng_completed||':'||'ERROR';
    ELSIF l_process_complete = 'Y'
    THEN
        resultout := wf_engine.eng_completed||':'||'COMPLETE';
    ELSIF (l_approvers_found = 'N' AND  l_process_complete = 'N')
    THEN
        resultout := wf_engine.eng_completed||':'||'WAIT';
    ELSIF l_approvers_found = 'Y'
    THEN
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey => itemkey,
                                      aname   => 'CONTACT',
                                      avalue  => l_role_name);

       resultout := wf_engine.eng_completed||':'||'NOTIFY';
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_wf_common.get_ame_approvers',
                          SQLERRM || ' Error occurred '||
                          'for transaction ' || l_transaction_id);
        END IF;

        wf_core.context('FUN_WF_COMMON', 'GET_AME_APPROVERS',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);
END get_ame_approvers;


/* ---------------------------------------------------------------------------
Name      : get_ame_role_list
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by get_ame_contacts() and
            get_ame_approvers functions. It returns the name of the wflow
            role to whom FYI or approval notifications are sent out.
Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
            p_fyi_notification - 'Y' or 'N' indicating if its FYI notification
            p_contact_type     - 'I'- Initiator or 'R'- Recipient
    OUT   : x_approvers_found  - 'Y'or 'N' indicating approvers found
            x_process_complete - 'Y'or 'N' indicating process complete
            x_role             - workflow role name
            x_return_status    - Return Status.
            x_ame_admin_user   - Ame Administrator
            x_error_message    - Error Message
Notes     : None.
Testing   : This function will be tested via the various intercompany
            workflows
------------------------------------------------------------------------------*/
PROCEDURE get_ame_role_list(itemkey            IN  VARCHAR2,
                            p_transaction_id   IN  NUMBER,
                            p_fyi_notification IN  VARCHAR2,
                            p_contact_type     IN  VARCHAR2,
                            x_approvers_found  OUT NOCOPY VARCHAR2,
                            x_process_complete OUT NOCOPY VARCHAR2,
                            x_role             OUT NOCOPY VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_ame_admin_user   OUT NOCOPY VARCHAR2,
                            x_error_message    OUT NOCOPY VARCHAR2)

IS
l_approver_table           ame_util.approversTable2;
l_invalid_usr_rec 	   ame_util.approverRecord2;
l_ame_admin_rec            ame_util.approverRecord2;
l_process_complete         VARCHAR2(1);
l_party_id                 NUMBER;
l_index                    NUMBER;
l_role_name                VARCHAR2(30) ;
l_role_display             hz_parties.party_name%TYPE;
l_exp_date                 DATE ;
l_role_exists              VARCHAR2(1) ;
l_transaction_type         VARCHAR2(30);
l_users                    VARCHAR2(2000);
l_invalid_users            VARCHAR2(2000);
l_valid_user               VARCHAR2(1);


CURSOR c_chk_wf_role (p_role_name    VARCHAR2) IS
SELECT 'Y'
FROM   wf_local_roles
WHERE  name = p_role_name;

CURSOR c_get_orgname (p_transaction_id NUMBER,
                      p_contact_type   VARCHAR2) IS
SELECT hzp.party_name
FROM   hz_parties hzp,
       fun_trx_headers trx
WHERE  hzp.party_id = DECODE(p_contact_type,'I',trx.initiator_id,
                                                trx.recipient_id)
AND    trx.trx_id = p_transaction_id;

BEGIN

    OPEN c_get_orgname (p_transaction_id, p_contact_type);
    FETCH c_get_orgname INTO l_role_display;
    CLOSE c_get_orgname;

    IF p_contact_type = 'I'
    THEN
        -- We need the contact list for the initiating organization
        l_transaction_type := 'FUN_IC_INIT_TRX';
        l_role_name:='FUN_ADHOC_INIT_'||p_transaction_id;
    ELSE
        -- We need the contact list for the recipient organization
        l_transaction_type := 'FUN_IC_RECI_TRX';
        l_role_name:='FUN_ADHOC_RECI_'||p_transaction_id;
    END IF;

    l_exp_date :=  SYSDATE + 1;
    l_role_exists:='N';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if the ADHOC role already exists
    OPEN c_chk_wf_role(l_role_name);
    FETCH c_chk_wf_role INTO l_role_exists;
    CLOSE c_chk_wf_role;

    -- Get the AME Admin Approver
    ame_api2.getAdminApprover(
           applicationIdIn   => 435,
           transactionTypeIn => l_transaction_type,
           adminApproverOut  => l_ame_admin_rec);

    x_ame_admin_user := l_ame_admin_rec.name;

    IF p_fyi_notification = 'Y'
    THEN
        -- Call the AME API to get the list of ALL approvers
        ame_api2.getAllApprovers7 (
                           applicationIdIn               => 435,
                           transactionTypeIn             => l_transaction_type,
                           transactionIdIn               => to_char(p_transaction_id),
                           approvalProcessCompleteYNOut  => l_process_complete,
                           ApproversOut                  => l_approver_table);

    ELSE
        -- Call the AME API to get the list of next approver
        ame_api2.getNextApprovers4 (
                           applicationIdIn               => 435,
                           transactionTypeIn             => l_transaction_type,
                           transactionIdIn               => to_char(p_transaction_id),
                           approvalProcessCompleteYNOut  => l_process_complete,
                           nextApproversOut              => l_approver_table);

    END IF;

    -- Check if AME encountered any errors.
    IF  l_approver_table.COUNT > 0
    AND  l_approver_table(1).approval_status = ame_util.exceptionStatus
    THEN
        -- Ame had an exception whilst generating the approver
        -- list.
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('FUN','FUN_AME_EXECUTION_EXCEPTION');
        x_error_message  := FND_MESSAGE.GET;

        RETURN;
    END IF;

    -- Check approval status etc ...
    -- IF l_process_complete = ame_util.booleanTrue
       IF l_process_complete = 'Y'                  -- 6995183
    THEN
        x_process_complete := 'Y';
    ELSE
        IF l_approver_table.COUNT = 0
        THEN
            -- This indicates we are still waiting for response from a few approvers
            x_approvers_found  := 'N';
	    --Bug No:5897122
            x_process_complete := 'Y';
        ELSE
            -- This indicates there are still approvers to be notified.
            x_approvers_found  := 'Y';
            x_process_complete := 'N';
        END IF;
    END IF;

    -- If the approval process is not over or if this is an FYI
    -- notification, build the list of resources to send out the
    -- notifications
    If x_approvers_found = 'Y' OR p_fyi_notification = 'Y'
    THEN
        -- Check that the list of approvers returned are all authorised
        -- to view the intercompany transaction.

        -- The security model is undergoing changes as per ER 3358579
        -- Once the technical design for the ER has been finalized,
        -- this section will be updated with the correct
        -- validation (see open issues 2)

        FOR l_index IN 1..l_approver_table.COUNT
        LOOP
            -- Check user has access to the transaction
            IF p_fyi_notification = 'Y'
            THEN
                -- Check if user has Update, View or Contact access.
                NULL;
            ELSE
                -- Check if user has Update access.
                NULL;
            END IF;

            -- For now, call is_valid_approver procedure
            l_valid_user := fun_wf_common.is_user_valid_approver
                                (p_transaction_id => p_transaction_id,
				 p_user_id        => NULL,
                                 p_role_name      => l_approver_table(l_index).name,
                                 p_org_type       => p_contact_type,
                                 p_mode           => 'WF');

            IF l_valid_user = 'Y'
            THEN
                -- Add the user to list of users who can approve the
                -- document.
                IF l_users IS NULL
                THEN
                    l_users := l_approver_table(l_index).name;
                ELSE
                    l_users := l_users ||','||l_approver_table(l_index).name;
                END IF;
            ELSE
                -- Add the user to list of invalid users
                -- These users will be put on the notification sent
                -- out to the AME administrator.
                IF l_invalid_users IS NULL
                THEN
                    l_invalid_users := l_approver_table(l_index).name;
                ELSE
                    l_invalid_users := l_invalid_users ||', '||
                                   l_approver_table(l_index).name;
                END IF;

            END IF;
        END LOOP;

        IF l_invalid_users IS NOT NULL
        OR l_users IS NULL
        THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
                fnd_log.string(FND_LOG.LEVEL_ERROR,
                          'fun.plsql.fun_wf_common.get_ame_role_list',
                          ' Invalid users found without access to org ' ||
                          'for transaction ' || p_transaction_id);
            END IF;

            -- Since we will be recalling AME after sysadmin
            -- has fixed the error, we need to reset the approval
            -- status within AME so that the same list of users
            -- are returned again.
            FOR l_index IN 1..l_approver_table.COUNT
            LOOP
                l_invalid_usr_rec := l_approver_table(l_index);
                l_invalid_usr_rec.approval_status := NULL;

                ame_api2.updateApprovalStatus(
                        applicationIdIn     => 435,
                        transactionTypeIn   => l_transaction_type,
                        transactionIdIn     => p_transaction_id,
                        approverIn          => l_invalid_usr_rec);
            END LOOP;

            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('FUN','FUN_AME_INVALID_USERS');
            FND_MESSAGE.Set_Token ('USER_LIST',l_invalid_users);
            x_error_message  := FND_MESSAGE.GET;

        ELSE
            -- Check if the ADHOC role already exists
            IF l_role_exists = 'Y'
            THEN
                -- If the role exists, then empty the existing role list
                wf_directory.RemoveUsersFromAdHocRole
                (role_name         => l_role_name,
                 role_users        => NULL);

                -- Add the users we have identified to the role list.
                wf_directory.AddUsersToAdHocRole
                                (role_name         => l_role_name,
                                 role_users        => l_users);

            ELSE
                -- Create an ADHOC role for the approver list and add the
                -- users.
                wf_directory.CreateAdHocRole
                        (role_name         => l_role_name,
                         role_display_name => l_role_display,
                         role_users        => l_users,
                         expiration_date   => NULL);

            END IF; -- Check ADHOC role exists
        END IF; -- valid IC users found

        x_role := l_role_name;

    END IF;  --  approvers found

EXCEPTION

    WHEN OTHERS
    THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_wf_common.get_ame_role_list',
                          SQLERRM || ' Error occurred '||
                          'for transaction ' || p_transaction_id);
        END IF;

	FND_MESSAGE.Set_Name('FUN','FUN_AME_UNEXPECTED_EXCEPTION');
	x_error_message  := FND_MESSAGE.GET;
        x_return_status := FND_API.G_RET_STS_ERROR;

END get_ame_role_list;

-- 6995183 START
/* ---------------------------------------------------------------------------
Name      : validate_approver
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called to check if the user is a valid approver before enabling
            the 'Approve' and 'Reject' button.

Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
    OUT   : Varchar2 - 'Y' implies user has access, 'N' means no access
Notes     : None.
Testing   : This function will be tested via the inbound trx UI
------------------------------------------------------------------------------*/

FUNCTION validate_approver (p_transaction_id      IN VARCHAR2 )
RETURN VARCHAR2 IS
l_transaction_type         VARCHAR2(30);
l_approver_table           ame_util.approversTable2;
l_application_id           NUMBER;

BEGIN

l_transaction_type := 'FUN_IC_RECI_TRX';
l_application_id := 435;

--insert into yuva_temp (text) values ('Inside');
--insert into yuva_temp (text) values ('After : l_application_id ' || l_application_id);
--insert into yuva_temp (text) values ('After : l_transaction_type' || p_transaction_id);
--insert into yuva_temp (text) values ('After : l_transaction_type ' || l_transaction_type);


	ame_api3.getOldApprovers (
                           applicationIdIn               => l_application_id,
                           transactionIdIn               => to_char(p_transaction_id),
			   transactionTypeIn             => l_transaction_type,
                           oldApproversOut              => l_approver_table);
--insert into yuva_temp (text) values ('After : ' || p_transaction_id);

  FOR l_index IN 1..l_approver_table.COUNT
        LOOP
        	IF (l_approver_table(l_index).name = fnd_global.user_name AND l_approver_table(l_index).approval_status <> 'APPROVE') THEN
        		RETURN 'Y';
        	END IF;
        END LOOP;
RETURN 'N';
EXCEPTION
    WHEN OTHERS
    THEN
    	-- err_msg := substr(SQLERRM, 1, 200);
         --insert into yuva_temp values (substr(SQLERRM, 1, 200));
        RETURN 'N';

END validate_approver;

-- 6995183 END


/* ---------------------------------------------------------------------------
Name      : is_user_valid_approver
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called from the Inbound Transaction UI
            to check if the user is a valid approver before enabling
            the 'Approve' and 'Reject' button.
            This function is also called from within workflow to decide
            whether or not the user the notification is going to be sent to
            is a valid user or not.
Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
            p_user_id          - fnd_user.userid of the person navigating
                                 to the Inbound Trx UI.
            p_role_name        - wf_roles.name of the person the notification
                                 is being sent to or forwarded to.
            p_org_type         = 'I' Initiating, 'R' Recipient.
            p_mode             - UI - called from the UI
                                 WF - called from the workflow.

    OUT   : Varchar2 - 'Y' implies user has access, 'N' means no access
Notes     : None.
Testing   : This function will be tested via the inbound trx UI
------------------------------------------------------------------------------*/
FUNCTION is_user_valid_approver (p_transaction_id      IN VARCHAR2,
				 p_user_id             IN NUMBER,
                                 p_role_name           IN VARCHAR2,
                                 p_org_type            IN VARCHAR2,
                                 p_mode                IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_chk_user IS
    SELECT 'X'
    FROM   fnd_user usr,
           WF_USER_ROLE_ASSIGNMENTS role
    WHERE  usr.user_id = p_user_id
    AND    usr.user_name = role.user_name
    AND    role.role_name = 'FUN_ADHOC_RECI_'||p_transaction_id;
-- Bug No: 5897122
CURSOR c_chk_web IS
        SELECT 'X'
	FROM  hz_parties p,
	fnd_user fu,
	fun_trx_headers ftrx,
	hz_relationships hzr,
	hz_org_contacts hc,
	hz_org_contact_roles hcr
	WHERE p.party_type = 'PERSON'
	AND   p.party_id = hzr.subject_id
	AND   hzr.object_id = ftrx.recipient_id
	AND   hzr.relationship_code = 'CONTACT_OF'
	AND   hzr.relationship_type = 'CONTACT'
	AND   hzr.directional_flag = 'F'
	AND   hzr.subject_table_name = 'HZ_PARTIES'
	AND   hzr.object_table_name = 'HZ_PARTIES'
	AND   hzr.subject_type = 'PERSON'
	AND   hc.party_relationship_id = hzr.relationship_id
	AND   hcr.org_contact_id = hc.org_contact_id
	AND   hcr.role_type = 'INTERCOMPANY_CONTACT_FOR'
	AND   fu.person_party_id = p.party_id
	AND   sysdate BETWEEN
	nvl(hzr.start_date, sysdate -1)
	AND nvl(hzr.end_date, sysdate + 1)
	AND   ftrx.trx_id = p_transaction_id;
-- End: Bug No: 5897122
CURSOR c_chk_role IS
    SELECT 'X'
    FROM   fun_trx_headers  trx,
           hz_relationships rel,
           fnd_user         wf,
           hz_org_contacts c,
           hz_org_contact_roles cr
    WHERE  wf.user_name             = p_role_name
    AND    wf.person_party_id       = rel.subject_id
    AND    trx.trx_id               = p_transaction_id
    AND    rel.object_id            = DECODE(p_org_type, 'R',trx.recipient_id,
                                                'I',trx.initiator_id)
    AND    rel.relationship_code    = 'CONTACT_OF'
    AND    rel.relationship_type    = 'CONTACT'
    AND    rel.directional_flag     = 'F'
    AND    rel.subject_table_name   = 'HZ_PARTIES'
    AND    rel.object_table_name    = 'HZ_PARTIES'
    AND    rel.subject_type         = 'PERSON'
    AND    SYSDATE BETWEEN NVL(rel.start_date, SYSDATE -1)
                       AND NVL(rel.end_date, SYSDATE + 1)
    AND    c.party_relationship_id = rel.relationship_id
    AND    cr.org_contact_id = c.org_contact_id
    AND    cr.role_type = 'INTERCOMPANY_CONTACT_FOR';

l_user_name  fnd_user.user_name%TYPE;

BEGIN
    IF p_mode = 'UI'
    THEN
        -- Called from the inbound UI
        OPEN c_chk_user;
        FETCH c_chk_user INTO l_user_name;

        IF c_chk_user%FOUND
        THEN
            CLOSE c_chk_user;
            RETURN 'Y';
        ELSE
            CLOSE c_chk_user;
            -- Bug No: 5897122
            OPEN c_chk_web;
	    FETCH c_chk_web INTO l_user_name;

	    IF c_chk_web%FOUND
            THEN
                CLOSE c_chk_web;
                RETURN 'Y';
            ELSE
		CLOSE c_chk_web;
		RETURN 'N';
            END IF;
	    --End Bug No: 5897122
        END IF;
    ELSIF p_mode = 'WF'
    THEN
        -- Called from the workflow
        OPEN c_chk_role;
        FETCH c_chk_role INTO l_user_name;

        IF c_chk_role%FOUND
        THEN
            CLOSE c_chk_role;
            RETURN 'Y';
        ELSE
            CLOSE c_chk_role;
            RETURN 'N';
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
        RETURN 'N';
END is_user_valid_approver;


PROCEDURE set_invoice_reqd_flag(p_batch_id             IN NUMBER,
                                x_return_status        OUT NOCOPY VARCHAR2)
IS

CURSOR c_trx (p_batch_id   NUMBER)
IS
SELECT trx_id,
       recipient_id,
       to_le_id
FROM   fun_trx_headers
WHERE  batch_id = p_batch_id;

l_initiator_id     NUMBER;
l_ini_le_id        NUMBER;
l_trx_invoice_flag VARCHAR2(1);
l_ini_invoice_flag VARCHAR2(1);
l_rec_invoice_flag VARCHAR2(1);
l_return_status    VARCHAR2(1);
l_le_error         VARCHAR2(2000);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT b.initiator_id,
          b.from_le_id,
          Nvl(t.allow_invoicing_flag, 'N')
   INTO   l_initiator_id,
          l_ini_le_id,
          l_trx_invoice_flag
   FROM   fun_trx_batches b,
          fun_trx_types_vl t
   WHERE  b.batch_id = p_batch_id
   AND    b.trx_type_id = t.trx_type_id;

   IF l_trx_invoice_flag = 'N'
   THEN
       -- Check if initiator requires invoicing
       XLE_UTILITIES_GRP. Check_IC_Invoice_required(
          x_return_status     => l_return_status,
          x_msg_data          => l_le_error,
          p_legal_entity_id   => l_ini_le_id,
          p_party_id          => l_initiator_id,
          x_intercompany_inv  => l_ini_invoice_flag);

       IF l_ini_invoice_flag = FND_API.G_TRUE
       THEN
           -- invoicing is required for the initator and therefore
           -- required for all recipients.
           UPDATE fun_trx_headers
           SET    invoice_flag = 'Y'
           WHERE  batch_id = p_batch_id;
       ELSE
           -- check if invoice is required for the recipient
           FOR l_trx_rec IN c_trx (p_batch_id)
           LOOP
               -- Check if initiator requires invoicing
               XLE_UTILITIES_GRP. Check_IC_Invoice_required(
                  x_return_status     => l_return_status,
                  x_msg_data          => l_le_error,
                  p_legal_entity_id   => l_trx_rec.to_le_id,
                  p_party_id          => l_trx_rec.recipient_id,
                  x_intercompany_inv  => l_rec_invoice_flag);

               IF l_rec_invoice_flag = FND_API.G_TRUE
               THEN
                   -- invoicing is required for the recipient
                   UPDATE fun_trx_headers
                   SET    invoice_flag = 'Y'
                   WHERE  trx_id = l_trx_rec.trx_id;
               ELSE
                   -- invoicing is not required for the recipient
                   UPDATE fun_trx_headers
                   SET    invoice_flag = 'N'
                   WHERE  trx_id = l_trx_rec.trx_id;
               END IF; -- invoicing required for recipient
           END LOOP;

       END IF; -- invoicing enabled for inititator
   ELSE
       -- invoicing is required for this transaction
       UPDATE fun_trx_headers
       SET    invoice_flag = 'Y'
       WHERE  batch_id = p_batch_id;

   END IF; -- invoicing enabled for trx type

   COMMIT; -- commit here before starting further wf processing

EXCEPTION
   WHEN OTHERS
   THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_wf_common.set_invoice_reqd_flag',
                          SQLERRM || ' Error occurred '||
                          'for batch ' || p_batch_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END set_invoice_reqd_flag;

PROCEDURE wf_abort (p_batch_id IN NUMBER,
                    p_trx_id IN NUMBER)
IS

cursor batch_abort is
select distinct item_type,item_key
from WF_ITEM_ACTIVITY_STATUSES
where item_type in ('FUNRMAIN','FUNIMAIN','FUNRTVAL','FUNMSYST')
and item_key like to_char(p_batch_id)||'%'
and activity_status in( 'ACTIVE');

cursor trx_abort is
select distinct item_type,item_key
from WF_ITEM_ACTIVITY_STATUSES
where item_type in ('FUNRMAIN','FUNIMAIN','FUNRTVAL','FUNMSYST')
and item_key like to_char(p_batch_id)||'_'||to_char(p_trx_id)||'%'
and activity_status in( 'ACTIVE');

BEGIN

if p_trx_id is NULL then
for wf_abort in batch_abort
loop

wf_engine.AbortProcess
(itemtype =>wf_abort.item_type,
itemkey => wf_abort.item_key
);

end loop;
else
for wf_trx_abort in trx_abort
loop
wf_engine.AbortProcess
(itemtype =>wf_trx_abort.item_type,
itemkey => wf_trx_abort.item_key
);

end loop;

end if;
COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN
null;
WHEN OTHERS THEN
RAISE;

END wf_abort;

END FUN_WF_COMMON;

/
