--------------------------------------------------------
--  DDL for Package Body FUN_NET_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_APPROVAL_WF" AS
/* $Header: funntwfb.pls 120.2 2006/12/14 11:21:22 ashikuma noship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================


    PROCEDURE Raise_Approval_Event(
                                --p_event_key       IN VARCHAR2,
                                --p_event_name      IN VARCHAR2,
                                p_batch_id        IN NUMBER) IS
        l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
        l_event_name     VARCHAR2(50);
        l_path           VARCHAR2(100);
    BEGIN
        l_path := g_path || 'Raise_Approval_Event';
        fun_net_util.Log_String(g_state_level,l_path,'Start of Raise_Approval_Event');
        fun_net_util.Log_String(g_state_level,l_path,'Batch ID: '||p_batch_id);

        l_event_name     := 'oracle.apps.fun.netting.batchApproval';
        wf_event.AddParameterToList
         (  p_name          => 'BATCH_ID',
            p_value         => p_batch_id,
            p_parameterlist => l_parameter_list  );

        fun_net_util.Log_String(g_state_level,l_path,'Before raising business event');
        wf_event.Raise3
        (
         p_event_name     => l_event_name,
         p_event_key      => to_char(p_batch_id)||' '||to_char(sysdate,'DD-MM-YY HH:MM:SS'),
         p_parameter_list => l_parameter_list
        );
        fun_net_util.Log_String(g_state_level,l_path,'After raising business event');
        l_parameter_list.DELETE;
        fun_net_util.Log_String(g_state_level,l_path,'End of Raise_Approval_Event');
    EXCEPTION
        WHEN others THEN
            --wf_core.CONTEXT(l_path_name,l_api_name,l_path_name);
            APP_EXCEPTION.RAISE_EXCEPTION;

    END Raise_Approval_Event;

    PROCEDURE Initialize(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2) IS

        CURSOR c_get_batch_details(cp_batch_id fun_net_batches_all.batch_id%TYPE) IS
            SELECT batch_number,
                    batch_name,
                    response_date,
                    created_by,
                    total_netted_amt,
                    agreement_id,
                    batch_currency
            FROM fun_net_batches_all
            WHERE batch_id = cp_batch_id;

        CURSOR c_get_preparer_id(cp_user_id IN fnd_user.user_id%TYPE) IS
            SELECT employee_id
            FROM FND_USER
            WHERE user_id = cp_user_id;

        CURSOR c_get_approver_name(cp_agreement_id fun_net_agreements_all.agreement_id%TYPE) IS
            SELECT approver_name
            FROM fun_net_agreements_all
            WHERE agreement_id = cp_agreement_id;

        l_batch_id              fun_net_batches_all.batch_id%TYPE;
        l_batch_number          fun_net_batches_all.batch_number%TYPE;
        l_batch_name            fun_net_batches_all.batch_name%TYPE;
        l_response_date         fun_net_batches_all.response_date%TYPE;
        l_created_by            fun_net_batches_all.created_by%TYPE;
        l_netting_amount        fun_net_batches_all.total_netted_amt%TYPE;
        l_netting_analyst_id    fnd_user.user_id%TYPE;
        l_analyst_name          wf_users.name%type;
        l_analyst_display_name  wf_users.display_name%type;
        l_agreement_id          fun_net_agreements_all.agreement_id%TYPE;
        l_approver_name         fun_net_agreements_all.approver_name%TYPE;
        l_batch_currency        fun_net_batches_all.batch_currency%TYPE;
        l_path                  varchar2(100);
    BEGIN
        l_path  := g_path || 'Initialize';
        l_batch_id := WF_ENGINE.GetItemAttrNumber(p_item_type, p_item_key, 'BATCH_ID');
        fun_net_util.Log_String(g_state_level,l_path,'Batch Id :'||l_batch_id);

        OPEN c_get_batch_details(l_batch_id);
        FETCH c_get_batch_details INTO l_batch_number,
                                        l_batch_name,
                                        l_response_date,
                                        l_created_by,
                                        l_netting_amount,
                                        l_agreement_id,
                                        l_batch_currency;
        CLOSE c_get_batch_details;
        fun_net_util.Log_String(g_state_level,l_path,'Setting WF Attributes');
        WF_ENGINE.SetItemAttrNumber(p_item_type, p_item_key, 'BATCH_NUMBER',l_batch_number);
        WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'BATCH_NAME',l_batch_name);
        WF_ENGINE.SetItemAttrDate(p_item_type, p_item_key, 'RESPONSE_DATE',l_response_date);
        WF_ENGINE.SetItemAttrNumber(p_item_type, p_item_key, 'NETTING_AMOUNT',l_netting_amount);
        WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'BATCH_CURRENCY',l_batch_currency);
        fun_net_util.Log_String(g_state_level,l_path,'After Setting WF Attributes');

        OPEN c_get_preparer_id(l_created_by);
        FETCH c_get_preparer_id INTO l_netting_analyst_id;
        CLOSE c_get_preparer_id;
        fun_net_util.Log_String(g_state_level,l_path,'Preparer ID :'||l_netting_analyst_id);

        WF_DIRECTORY.GetUserName('PER',
                           l_netting_analyst_id,
                           l_analyst_name,
                           l_analyst_display_name);

        fun_net_util.Log_String(g_state_level,l_path,'Analyst Name :'||l_analyst_name);

        WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'ANALYST_NAME',l_analyst_name);
        WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'ANALYST_DISP_NAME',l_analyst_display_name);

        OPEN c_get_approver_name(l_agreement_id);
        FETCH c_get_approver_name INTO l_approver_name;
        CLOSE c_get_approver_name;
        fun_net_util.Log_String(g_state_level,l_path,'Approver Name:'||l_approver_name);

        WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'APPROVER_NAME',l_approver_name);

        p_result := 'COMPLETE';
        fun_net_util.Log_String(g_state_level,l_path,'End of Initialization');

    EXCEPTION
        WHEN OTHERS THEN
            fun_net_util.Log_String(g_state_level,l_path,sqlerrm);
    END Initialize;

    PROCEDURE Validate_Settle_Batch(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2) IS

        l_batch_id fun_net_batches_all.batch_id%TYPE;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_path                  VARCHAR2(100);
        l_org_id    NUMBER;
        l_status VARCHAR2(50);
    BEGIN

 fun_net_util.Log_String(g_state_level,l_path,'Batch IdIASDASD: '||l_batch_id);
        l_path := g_path||'Validate_Settle_Batch';
        l_batch_id := WF_ENGINE.GetItemAttrNumber(p_item_type, p_item_key, 'BATCH_ID');
        fun_net_util.Log_String(g_state_level,l_path,'Batch Id: '||l_batch_id);


        -- Set the Multi Org Context

           SELECT ORG_ID
             INTO L_ORG_ID
             FROM FUN_NET_BATCHES_ALL
            WHERE BATCH_ID = L_BATCH_ID;


         mo_global.set_policy_context('S',l_org_id);


        FUN_NET_ARAP_PKG.settle_net_batch (
            p_init_msg_list     => FND_API.G_TRUE,
            p_commit            => FND_API.G_TRUE,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            p_batch_id          => l_batch_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            fun_net_util.Log_String(g_state_level,l_path,'Settle batch SUCCESS');
            p_result := 'COMPLETE:Y';
        ELSE
            select batch_status_code into l_status from fun_net_batches_all
            where batch_id=l_batch_id;
            IF l_status='ERROR' THEN
               fun_net_util.Log_String(g_state_level,l_path,'Setting batch FAILURE');
               p_result := 'COMPLETE:N';
            ELSIF l_status='CANCELLED' THEN
             fun_net_util.Log_String(g_state_level,l_path,'Setting batch CANCELLED');
             p_result := 'COMPLETE:C';
            END IF;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'End Validate_Settle_Batch');
    END Validate_Settle_Batch;

    PROCEDURE Get_NoResponse_Action(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2) IS

        CURSOR c_get_nonresponse_code(cp_batch_id fun_net_batches_all.batch_id%TYPE) IS
        SELECT a.non_response_action_code
        FROM fun_net_agreements_all a
        WHERE a.agreement_id = (SELECT b.agreement_id
                                FROM fun_net_batches_all b
                                WHERE b.batch_id = cp_batch_id);

        l_batch_id          fun_net_batches_all.batch_id%TYPE;
        l_nonresponse_code  fun_net_agreements_all.non_response_action_code%TYPE;
        l_path              VARCHAR2(100);
    BEGIN
        l_path              := g_path||'Get_NoResponse_Action';
        fun_net_util.Log_String(g_state_level,l_path,'Start of Get_NoResponse_Action');
        l_batch_id := WF_ENGINE.GetItemAttrNumber(p_item_type, p_item_key, 'BATCH_ID');
        fun_net_util.Log_String(g_state_level,l_path,'Batch ID: '||l_batch_id);

        OPEN c_get_nonresponse_code(l_batch_id);
        FETCH c_get_nonresponse_code INTO l_nonresponse_code;
        CLOSE c_get_nonresponse_code;

        IF l_nonresponse_code = 'APPROVE' THEN
            fun_net_util.Log_String(g_state_level,l_path,'No response action:'||'APPROVE');
            p_result := 'COMPLETE:APPROVED';
        ELSE
            fun_net_util.Log_String(g_state_level,l_path,'No response action:'||'REJECT');
            p_result := 'COMPLETE:REJECTED';
        END IF;
                    fun_net_util.Log_String(g_state_level,l_path,'End of Get_NoResponse_Action');
    END Get_NoResponse_Action;

    PROCEDURE Update_Batch_status_rej(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2) IS

        l_batch_id fun_net_batches_all.batch_id%TYPE;
        l_return_status         VARCHAR2(1);
        l_path                  VARCHAR2(100);
    BEGIN
        l_path := g_path||'Update_Batch_status';

        fun_net_util.Log_String(g_state_level,l_path,'Begin Update Batch Status');
        l_batch_id := WF_ENGINE.GetItemAttrNumber(p_item_type, p_item_key, 'BATCH_ID');
        fun_net_util.Log_String(g_state_level,l_path,'Batch Id: '||l_batch_id);

           FUN_NET_BATCHES_PKG.Update_Row
            (x_batch_id => l_batch_id,
            x_batch_status_code => 'REJECTED');

             p_result := 'COMPLETE';

        fun_net_util.Log_String(g_state_level,l_path,'End Update Batch Status');

    END Update_Batch_status_rej;

    PROCEDURE Update_Batch_status_err(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2) IS

        l_batch_id fun_net_batches_all.batch_id%TYPE;
        l_return_status         VARCHAR2(1);
        l_path                  VARCHAR2(100);
    BEGIN
        l_path := g_path||'Update_Batch_status';

        fun_net_util.Log_String(g_state_level,l_path,'Begin Update Batch Status');
        l_batch_id := WF_ENGINE.GetItemAttrNumber(p_item_type, p_item_key, 'BATCH_ID');
        fun_net_util.Log_String(g_state_level,l_path,'Batch Id: '||l_batch_id);

           FUN_NET_BATCHES_PKG.Update_Row
            (x_batch_id => l_batch_id,
            x_batch_status_code => 'ERROR');

             p_result := 'COMPLETE';

        fun_net_util.Log_String(g_state_level,l_path,'End Update Batch Status');

    END Update_Batch_status_err;


BEGIN
 --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        :=    'FUN.PLSQL.funntwfb.FUN_NET_APPROVAL_WF.';

--===========================FND_LOG.END=======================================



END FUN_NET_APPROVAL_WF;

/
