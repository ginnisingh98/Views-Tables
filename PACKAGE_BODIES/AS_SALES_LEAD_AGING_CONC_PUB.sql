--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_AGING_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_AGING_CONC_PUB" AS
/* $Header: asxslacb.pls 115.3 2004/01/23 07:05:51 subabu ship $ */

g_debug_flag         VARCHAR2(1) := 'N';


PROCEDURE Debug(p_msg IN VARCHAR2)
IS
    l_length        NUMBER;
    l_start         NUMBER := 1;
    l_substring     VARCHAR2(255);

    l_base          VARCHAR2(12);
BEGIN
    IF g_debug_flag = 'Y'
    THEN
        -- chop the message to 255 long
        l_length := length(p_msg);
        WHILE l_length > 255 LOOP
            l_substring := substr(p_msg, l_start, 255);
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
            l_start := l_start + 255;
            l_length := l_length - 255;
        END LOOP;
        l_substring := substr(p_msg, l_start);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
    END IF;

    EXCEPTION
    WHEN others THEN
        Debug('Exception: others in Debug');
        Debug('SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' ||
              substr(SQLERRM, 1, 100));
END Debug;


PROCEDURE Run_Aging_Main(
     ERRBUF                  OUT VARCHAR2,
     RETCODE                 OUT VARCHAR2,
     p_trace_mode            IN  VARCHAR2,
     p_debug_mode            IN  VARCHAR2)
IS
    CURSOR c_sales_lead IS
        SELECT sales_lead_id, assign_to_salesforce_id
        FROM as_sales_leads
        WHERE nvl(status_code, 'NULL') <> 'DECLINED'
        AND nvl(deleted_flag,'NULL')  <> 'Y';

    l_request_id               NUMBER;
    l_seq_no                   NUMBER;
    l_msg                      VARCHAR2(2000);
    l_status                   BOOLEAN;
    l_submit_request_id        NUMBER;
    l_aging_days_noact         NUMBER;
    l_aging_days_abandon       NUMBER;
    l_aging_abandon_actions    VARCHAR2(240);
    l_aging_noact_actions      VARCHAR2(240);
BEGIN

    g_debug_flag := p_debug_mode;

    Debug('*** ASXSLAGMA starts ***');

    l_request_id         := to_number(fnd_profile.value('CONC_REQUEST_ID'));
    l_aging_days_noact   := to_number(fnd_profile.value('AS_AGING_DAYS_NOACT'));
    l_aging_days_abandon
                    := to_number(fnd_profile.value('AS_AGING_DAYS_ABANDON'));
    l_aging_abandon_actions := fnd_profile.value('AS_AGING_ABANDON_ACTIONS');
    l_aging_noact_actions   := fnd_profile.value('AS_AGING_ABANDON_ACTIONS');

    Debug('aging_days_noact=' || to_char(l_aging_days_noact) ||
          ' aging_noact_actions=' || l_aging_noact_actions);
    Debug('aging_days_abandon=' || to_char(l_aging_days_abandon) ||
          ' aging_abandon_actions=' || l_aging_abandon_actions);

    l_seq_no := 0;

    FOR l_sales_lead_rec IN c_sales_lead LOOP
        l_seq_no := l_seq_no + 1;

        Debug('Submit ASXSLAGWF');
        Debug('Sales Lead ID : ' || to_char(l_sales_lead_rec.sales_lead_id));

        l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                   'ASX',
                                   'ASXSLAGWF',
                                   'Concurrent Request for Sales Lead Aging',
                                   '',
                                   FALSE,
                                   p_trace_mode,
                                   p_debug_mode,
                                   l_request_id,
                                   l_seq_no,
                                   l_sales_lead_rec.sales_lead_id
                                   );

        IF l_submit_request_id = 0
        THEN
            l_msg := FND_MESSAGE.GET;
            Debug(l_msg);
        END IF;
        commit;
        Debug('Submitted Request ID : ' || to_char(l_submit_request_id));
    END LOOP;

    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            Debug('Cannot restart');

        WHEN others THEN
            Debug('Exception: others in Assign_Territory_Accesses');
            Debug('SQLCODE ' || to_char(SQLCODE) ||
                  ' SQLERRM ' || substr(SQLERRM, 1, 100));
            errbuf := SQLERRM;
            retcode := FND_API.G_RET_STS_UNEXP_ERROR;
            l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Run_Aging_Main;


PROCEDURE Run_Aging_Workflow(
    ERRBUF                  OUT VARCHAR2,
    RETCODE                 OUT VARCHAR2,
    p_trace_mode            IN  VARCHAR2,
    p_debug_mode            IN  VARCHAR2,
    p_parent_request_id     IN NUMBER,
    p_sequence_number       IN NUMBER,
    p_sales_lead_id         IN NUMBER )
IS
    l_status                BOOLEAN;
    l_request_id            NUMBER;
    l_return_status         VARCHAR2(100);
    l_itemtype              VARCHAR2(8);
    l_itemkey               VARCHAR2(50);
    l_submit_request_id     NUMBER;
    l_aging_days_noact      NUMBER;
    l_aging_days_abandon    NUMBER;
    l_aging_abandon_actions VARCHAR2(240);
    l_aging_noact_actions   VARCHAR2(240);
    l_assigned_resource_id  NUMBER;
    l_sales_lead_id         NUMBER;

    CURSOR c_sales_lead (sales_lead_id_in NUMBER) IS
        SELECT assign_to_salesforce_id
        FROM as_sales_leads
        WHERE sales_lead_id = sales_lead_id_in;

BEGIN
    Debug('*** ASXSLAGWF start ***');

-----------------------------------------------------------------------------
    l_aging_days_noact   := to_number(fnd_profile.value('AS_AGING_DAYS_NOACT'));
    l_aging_days_abandon
                       := to_number(fnd_profile.value('AS_AGING_DAYS_ABANDON'));
    l_aging_abandon_actions := fnd_profile.value('AS_AGING_ABANDON_ACTIONS');
    l_aging_noact_actions   := fnd_profile.value('AS_AGING_ABANDON_ACTIONS');
-----------------------------------------------------------------------------
    Debug('Parent Request ID : ' || to_char( p_parent_request_id));
    Debug('Sequence Number : ' || to_char(p_sequence_number));
    Debug('Sales Lead ID : ' || to_char(p_sales_lead_id));
    Debug('Aging Days Noact : ' || to_char(l_aging_days_noact));
    Debug('Aging Noact Actions : ' || l_aging_noact_actions);
    Debug('Aging Days Abandon : ' || to_char(l_aging_days_abandon));
    Debug('Aging Abandon Actions : ' || l_aging_abandon_actions);

    l_request_id := to_number(fnd_profile.value('CONC_REQUEST_ID'));
    l_sales_lead_id := p_sales_lead_id;

    OPEN c_sales_lead(l_sales_lead_id);
    FETCH c_sales_lead INTO l_assigned_resource_id;
    CLOSE c_sales_lead;

    Debug('Request Id : ' || to_char(l_request_id));

    Debug('Calling StartSalesLeadAgingProcess');
    AS_SALES_LEAD_AGING_WF_PUB.StartSalesLeadAgingProcess(
            p_request_id               => l_request_id,
            p_sales_lead_id            => l_sales_lead_id,
            p_assigned_resource_id     => l_assigned_resource_id,
            p_aging_days_noact         => l_aging_days_noact,
            p_aging_days_abandon       => l_aging_days_abandon,
            p_aging_abandon_actions    => l_aging_abandon_actions,
            p_aging_noact_actions      => l_aging_noact_actions,
            x_item_type                => l_itemtype ,
            x_item_key                 => l_itemkey,
            x_return_status	         => l_return_status
            );

    -- Defer to wf_engine background process
    wf_engine.Background (
            itemtype => l_itemtype,
            minthreshold =>  null,
            maxthreshold =>  null,
            process_deferred => TRUE,
            process_timeout => TRUE);

    Debug('After StartSalesLeadAgingProcess');
    COMMIT;
    Debug('Commit Successfully');
    EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            Debug('Cannot restart');

        WHEN others THEN
            Debug('Exception: others in Assign_Territory_Accesses');
            Debug('SQLCODE ' || to_char(SQLCODE) ||
                  ' SQLERRM ' || substr(SQLERRM, 1, 100));
            errbuf := SQLERRM;
            retcode := FND_API.G_RET_STS_UNEXP_ERROR;
            l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END Run_Aging_Workflow;

END AS_SALES_LEAD_AGING_CONC_PUB;


/
