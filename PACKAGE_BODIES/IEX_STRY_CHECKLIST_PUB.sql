--------------------------------------------------------
--  DDL for Package Body IEX_STRY_CHECKLIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_CHECKLIST_PUB" AS
/* $Header: iexpschb.pls 120.1.12010000.3 2008/08/13 15:36:34 pnaveenk ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workflow will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRY_CHECKLIST_PUB';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE create_checklist_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_StrategyID                 IN   NUMBER
) IS

	l_result               VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) := 'CREATE_CHECKLIST_STRATEGY';
	l_api_version_number   CONSTANT NUMBER   := 2.0;


	fdelinquencyId number;
	fObjectId number;
	fobjectType varchar2(40);
    fStrategyVersionNumber number := 0;
    fCheckListTemplateID number;

    l_ObjectType    VARCHAR2(30);
	l_strategy_id number;
	l_strategy_template_id number;
	l_object_version_number number := 2.0;
	x_work_item_id number;

    l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;
    l_strategy2_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;
    l_strategy_work_item_rec IEX_STRATEGY_WORK_ITEMS_PVT.STRATEGY_WORK_ITEM_REC_TYPE;

    cursor c_witems(p_template_id NUMBER)
     is
      select sxref.strategy_temp_id TEMPLATE_ID,
          sxref.WORK_ITEM_TEMP_ID WORK_ITEM_TEMPLATE_ID,
          sxref.work_item_order ORDER_BY
       from iex_strategy_work_temp_xref sxref
       where sxref.strategy_temp_id = p_template_id;

    c_StrategySelect varchar2(1000) :=
	    ' select s.delinquency_id, ' ||
        ' s.object_id object_id, s.object_type object_type , s.object_version_number, ' ||
        ' t.check_list_temp_id ' ||
    	' from iex_strategies s, iex_strategy_templates_b t where ' ||
        ' s.strategy_id  = :pObjectID and s.strategy_template_id = t.strategy_temp_id ' ;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_checklist_strategy;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

     -- Debug Message
    IEX_DEBUG_PUB.LogMessage('PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start');

     -- Debug Message
    IEX_DEBUG_PUB.LogMessage('1. S.ID= ' || p_StrategyID || ' CLT.ID= ' );

     -- Debug Message
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start',
        print_date => 'Y');
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '1. S.ID= ' || p_StrategyID || ' CLT.ID= ',
        print_date => 'Y');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage( debug_msg => '15. S.ID= ' || p_StrategyID, print_date => 'Y');
        IEX_DEBUG_PUB.LogMessage( debug_msg => c_StrategySelect || ' Start', print_date => 'Y');
END IF;

        Execute Immediate c_StrategySelect into
                fDelinquencyID,  fObjectID,
                fObjectType, fStrategyVersionNumber, fCheckListTemplateID using  p_StrategyID;

    EXCEPTION
        When NO_DATA_FOUND then
            x_return_status := 'F';

            AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'IEX_STRATEGY_NOT_EXISTS',
                  p_token1        => 'STRATEGY_ID ',
                  p_token1_value  =>  to_char(p_StrategyID));

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage( debug_msg => '17. IEX_STRATEGY_NOT_EXISTS', print_date => 'Y');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
            return;
        When OTHERS then
            x_return_status := 'F';
            AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'IEX_OTHERS_SQL',
                  p_token1        => 'STRATEGY_ID ',
                  p_token1_value  =>  to_char(p_StrategyID));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage( debug_msg => '18. ERROR: IEX_OTHERS_SQL ', print_date => 'Y');
END IF;
            RAISE FND_API.G_EXC_ERROR;
            return;

    END;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '1. S.ID= ' || p_StrategyID || ' DB. CLT.ID= ' || fCheckListTemplateID,
        print_date => 'Y');
    END IF;

    if (fCheckListTemplateID is NULL) then
            x_return_status := 'F';
            AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'IEX_CHECKLIST_NOT_EXIST',
                  p_token1        => 'STRATEGY_ID ',
                  p_token1_value  =>  to_char(p_StrategyID));
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage( debug_msg => '20. CheckListTemplate Not exists ', print_date => 'Y');
END IF;
            RAISE FND_API.G_EXC_ERROR;
            return;
    end if;

    BEGIN

        l_strategy_rec.strategy_template_id := fCheckListTemplateID;
        l_strategy_rec.delinquency_id := fdelinquencyId;
        l_strategy_rec.next_work_item_id	:= null;
        l_strategy_rec.object_id := fObjectID;
        l_strategy_rec.object_type := fObjectType;
        l_strategy_rec.status_code := 'CLOSED';
        l_strategy_rec.checklist_yn := 'Y';
        l_object_version_number := 1;
   --Bug#6870773 Naveen
	if nvl(fnd_profile.value('IEX_PROC_STR_ORG'),'N') = 'Y' then
		--l_strategy_rec.org_id := fnd_profile.value('ORG_ID') ;
		l_strategy_rec.org_id:=mo_global.get_current_org_id;

	     else
                l_strategy_rec.org_id := null;
	end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage( debug_msg => '2. Create Checklist strategy ', print_date => 'Y');
END IF;

        IEX_DEBUG_PUB.LogMessage('2. Create Checklist strategy ');

        iex_strategy_pvt.create_strategy(
                P_Api_Version_Number=>2.0,
                p_commit =>  FND_API.G_FALSE,
                P_Init_Msg_List     =>FND_API.G_FALSE,
                p_strategy_rec => l_strategy_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                x_strategy_id => l_strategy_id
        );

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage( debug_msg => 'Return status = ' || l_return_status, print_date => 'Y');
END IF;
        IEX_DEBUG_PUB.LogMessage('Return status = ' || l_return_status);
        if (x_return_status <> 'S') then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        l_strategy_rec.strategy_id := l_strategy_id;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage( debug_msg => 'Strategy created. id = ' || l_strategy_id, print_date => 'Y');
END IF;
        IEX_DEBUG_PUB.LogMessage('Strategy created. id = ' || l_strategy_id);

    EXCEPTION
        WHEN OTHERS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage( debug_msg => 'IEX_STRATEGY_CREATE_FAILED', print_date => 'Y');
END IF;
            AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'IEX_STRATEGY_CREATE_FAILED',
                  p_token1        => 'OBJECT_ID ',
                  p_token1_value  =>  to_char(fObjectID));
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage( debug_msg => '3. Create WorkItems '
                        || l_strategy_rec.strategy_id, print_date => 'Y');
END IF;
    IEX_DEBUG_PUB.LogMessage('3. Create WorkItems '
                        || l_strategy_rec.strategy_id);

    FOR c_get_witem_rec in c_witems(fCheckListTemplateID )  LOOP

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage ('create_checklist_strategy: ' || 'work_item_template_id'|| c_get_witem_rec.work_item_template_id);
        END IF;

        l_strategy_work_item_rec.resource_id := 0;
        l_strategy_work_item_rec.work_item_template_id
                                 :=c_get_witem_rec.work_item_template_id;
        l_strategy_work_item_rec.strategy_id := l_strategy_rec.strategy_id;
        l_strategy_work_item_rec.status_code
                                :='OPEN';
        l_strategy_work_item_rec.strategy_temp_id := fCheckListTemplateID;
        l_strategy_work_item_rec.work_item_order  :=c_get_witem_rec.order_by;

        l_strategy_work_item_rec.execute_start   :=SYSDATE;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage ('create_checklist_strategy: ' || 'before calling create_work_pvt.create');
        END IF;

        iex_strategy_work_items_pvt.create_strategy_work_items
                   (P_Api_Version_Number     =>2.0,
                    P_Init_Msg_List          =>FND_API.G_TRUE,
                    P_Commit                 =>FND_API.G_FALSE,
                    p_validation_level       =>FND_API.G_VALID_LEVEL_NONE,
                    p_strategy_work_item_rec =>l_strategy_work_item_rec,
                    x_work_item_id           =>x_work_item_id,
                    x_return_status          =>l_return_status,
                    x_msg_count              =>l_msg_count,
                    x_msg_data               =>l_msg_data);

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('create_checklist_strategy: ' || 'after calling create_work_pvt.create');
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('create_checklist_strategy: ' || 'and l_return_status from the pvt ='||l_return_status);
          END IF;
          if (x_return_status <> 'S') then
            RAISE FND_API.G_EXC_ERROR;
         end if;

    END LOOP;

    IEX_DEBUG_PUB.LogMessage('Return status = ' || l_return_status);


    l_strategy2_rec.strategy_id := p_StrategyID;
    l_strategy2_rec.object_version_number := fStrategyVersionNumber;
    l_strategy2_rec.checklist_strategy_id := l_strategy_rec.strategy_id;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage( debug_msg => '2. Update Main Strategy ', print_date => 'Y');
END IF;

    IEX_DEBUG_PUB.LogMessage('2. Update Main Strategy ');

    iex_strategy_pvt.update_strategy(
                P_Api_Version_Number=>2.0,
                p_commit =>  FND_API.G_FALSE,
                P_Init_Msg_List     =>FND_API.G_FALSE,
                p_strategy_rec => l_strategy2_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                xo_object_version_number => l_object_version_number
        );
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage( debug_msg => 'Return status = ' || l_return_status, print_date => 'Y');
END IF;
    IEX_DEBUG_PUB.LogMessage('Return status = ' || l_return_status);
    if (x_return_status <> 'S') then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- Standard check for p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
     );

    IEX_DEBUG_PUB.LogMessage('Delinquency cursor ends' );


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END create_checklist_strategy;

END IEX_STRY_CHECKLIST_PUB;

/
