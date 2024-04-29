--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_WF_PUB" AS
/* $Header: iexpstwb.pls 120.3 2006/01/16 22:47:40 kasreeni ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workflow will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_WF_PUB';
PG_DEBUG NUMBER(2);

PROCEDURE start_workflow
(
            p_api_version             IN  NUMBER := 2.0,
            p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
            p_strategy_rec        IN  IEX_STRATEGY_PVT.STRATEGY_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data      		   OUT NOCOPY VARCHAR2,
            bConcProg                 IN  VARCHAR2
) IS
           l_result       VARCHAR2(10);
           itemtype       VARCHAR2(10) ;
           itemkey       VARCHAR2(30);
           workflowprocess     VARCHAR2(30);
           rolename        VARCHAR2(200);
           roledisplayname VARCHAR2(200);

           l_error_msg     VARCHAR2(2000);
           l_return_status     VARCHAR2(20);
           l_msg_count     NUMBER;
           l_msg_data     VARCHAR2(2000);
           l_api_name     VARCHAR2(100) ;
           l_api_version_number          CONSTANT NUMBER   := 2.0;


BEGIN
    l_api_name      := 'START_WORKFLOW';
    -- Standard Start of API savepoint
    SAVEPOINT START_WORKFLOW;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    if (bConcProg = 'YES') then
        -- Debug Message
        write_log(FND_LOG.LEVEL_STATEMENT, 'Public API: IEX_STRATEGY_WF_PUB.' || l_api_name || ' start');
        write_log(FND_LOG.LEVEL_STATEMENT, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    else

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IEX_DEBUG_PUB.LogMessage( 'API: IEX_STRATEGY_WF_PUB.' || l_api_name || ' start');
    end if;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    itemtype := 'IEXSTRY';
    workflowprocess := 'STRATEGY_WORKFLOW';

    itemkey := p_strategy_rec.strategy_id;

    -- wf_directory.GetRoleName(Orig_System, User_ID, role_name, role_displayname);
    -- call engine API to set the owner.
    --- wf_engine.SetItemOwner(ItemType, ItemKey, role_name);
    wf_engine.createprocess  (  itemtype => itemtype,
            itemkey  => itemkey,
            process  => workflowprocess);

    if (bConcProg = 'YES') then
        write_log(FND_LOG.LEVEL_STATEMENT, 'IEX_STRATEGY_WF_PUB.start_workflow: Create Process done');
    else
        IEX_DEBUG_PUB.LogMessage( 'IEX_STRATEGY_WF_PUB.start_workflow: Create Process done');
    end if;

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
            itemkey  =>   itemkey,
            aname    =>   'STRATEGY_ID',
            avalue   =>   p_strategy_rec.strategy_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
            itemkey  =>   itemkey,
            aname    =>   'STRATEGY_TEMPLATE_ID',
            avalue   =>   p_strategy_rec.strategy_template_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
            itemkey  =>   itemkey,
            aname    =>   'DELINQUENCY_ID',
            avalue   =>   p_strategy_rec.delinquency_id);


    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
            itemkey  =>   itemkey,
            aname    =>   'PARTY_ID',
            avalue   =>   p_strategy_rec.PARTY_ID);

    if (bConcProg = 'YES') then
        write_log(FND_LOG.LEVEL_STATEMENT, 'Set Attrib. sucess');
    else
        IEX_DEBUG_PUB.LogMessage( 'Set Attr sucess');
    end if;

    wf_engine.startprocess(itemtype => itemtype,  itemkey  =>   itemkey);

    wf_engine.ItemStatus(  itemtype =>   ItemType,
                           itemkey   =>   ItemKey,
                           status   =>   l_return_status,
                           result   =>   l_result);

    if (l_return_status in ('COMPLETE', 'ACTIVE', 'SUSPEND')) THEN
       x_return_status := 'S';
    else
       x_return_status := 'F';
       fnd_file.put_line(FND_FILE.LOG, 'Failed Workflow: STATUS = ' || l_return_status || ' l_result= ' || l_result);
       fnd_file.put_line(FND_FILE.LOG, 'Database Error if any ' || 'sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
       raise fnd_api.g_exc_unexpected_error;
    end if;

    if (bConcProg = 'YES') then
        write_log(FND_LOG.LEVEL_STATEMENT, 'GET ITEM STATUS = ' || l_return_status);

          -- Debug Message
        write_log(FND_LOG.LEVEL_STATEMENT, 'PUB: ' || l_api_name || ' end');
        write_log(FND_LOG.LEVEL_STATEMENT, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    else
        IEX_DEBUG_PUB.LogMessage( 'GET ITEM STATUS = ' || l_return_status);

          -- Debug Message
        IEX_DEBUG_PUB.LogMessage( 'PUB: ' || l_api_name || ' end');
        IEX_DEBUG_PUB.LogMessage( 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    end if;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if (bConcProg = 'YES') then
            fnd_file.put_line(FND_FILE.LOG, 'UNEXPECTED ERROR. PUB: ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
            fnd_file.put_line(FND_FILE.LOG, 'UNEXPECTED ERROR. PUB: ' || l_api_name || ' end');
            fnd_file.put_line(FND_FILE.LOG, 'PUB: ' || l_api_name || ' end');
            fnd_file.put_line(FND_FILE.LOG, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        else
            IEX_DEBUG_PUB.LogMessage( 'UNEXPECTED ERROR. PUB: ' || l_api_name || ' end');
            IEX_DEBUG_PUB.LogMessage( 'PUB: ' || l_api_name || ' end');
            IEX_DEBUG_PUB.LogMessage( 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        end if;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        if (bConcProg = 'YES') then
            fnd_file.put_line(FND_FILE.LOG, 'UNHANDLED WORKFLOW EXCEPTION ERROR: ' || ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);
            fnd_file.put_line(FND_FILE.LOG, 'UNHANDLED WORKFLOW EXCEPTION. Strategy ID ' || p_strategy_rec.strategy_id);
            fnd_file.put_line(FND_FILE.LOG, 'PUB: ' || l_api_name || ' end');
            fnd_file.put_line(FND_FILE.LOG, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        else
            IEX_DEBUG_PUB.LogMessage( 'UNHANDLED WORKFLOW EXCEPTION. Strategy ID ' || p_strategy_rec.strategy_id);
            IEX_DEBUG_PUB.LogMessage( 'PUB: ' || l_api_name || ' end');
            IEX_DEBUG_PUB.LogMessage( 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        end if;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END start_workflow;

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2) is
BEGIN
    if (mesg_level >= PG_DEBUG) then
        fnd_file.put_line(FND_FILE.LOG,  mesg);
--        fnd_file.put_line(FND_FILE.LOG, my_timestamp || ' ' || mesg);
    end if;
END;


BEGIN
    PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));


END IEX_STRATEGY_WF_PUB;

/
