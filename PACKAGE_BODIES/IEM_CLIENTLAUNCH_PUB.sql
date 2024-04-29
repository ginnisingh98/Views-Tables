--------------------------------------------------------
--  DDL for Package Body IEM_CLIENTLAUNCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CLIENTLAUNCH_PUB" as
/* $Header: iempuwqb.pls 120.2.12010000.4 2009/08/31 17:32:44 lkullamb ship $*/

--
--changed
-- Purpose: Maintain Launch Email Client
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  4/14/2003    Launched Message Component for INB, ACQ emails
--  Liang Xia  4/28/2003    Launching Inbound from node and subnode differently
--  Liang Xia  4/29/2003    Fixed bug unable to lauch Transfered message
--  Liang Xia  04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
--  Liang Xia  10/26/2005   Fixed bug 4692146
--  Lakshmi K  08/13/2009   Changed launchInbound procedure to enable cherry picking
--                          for 12.1.2 project
-- ---------   ------  -------------------------------
PROCEDURE launchInbound ( p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
   	                      x_action_type     OUT NOCOPY number,
                          x_action_name     OUT NOCOPY varchar2,
                          x_action_param    OUT NOCOPY varchar2,
                          x_msg_name        OUT NOCOPY varchar2,
                          x_msg_param       OUT NOCOPY varchar2,
                          x_dialog_style    OUT NOCOPY number,
                          x_msg_appl_short_name OUT NOCOPY VARCHAR2
                         )  IS

  l_name  varchar2(500);
  l_value varchar2(1996);
  l_type  varchar2(500);

  logMessage varchar2(2000);
  l_acct_id  number;
  l_acct_rt_class_id varchar2(30) := '-1';
  l_resource_id varchar2(30);
  l_classification_id number;
  l_launched_node varchar2(100);

  l_return_status         VARCHAR2(200) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);
  l_msg_id                 number;
  l_cust_id                number;
  l_sr_number              varchar(64);
  l_contact_id             number := -1;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT               launchInbound_pvt;


        FND_LOG_REPOSITORY.init(null,null);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[ launchInbound begin ]';
    	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;

        for i in 1..p_ieu_media_data.count loop

            if p_ieu_media_data(i).PARAM_NAME = 'IEU_PARAM_PK_COL' then
                l_launched_node := p_ieu_media_data(i).PARAM_VALUE;
            elsif p_ieu_media_data(i).PARAM_NAME = 'EMAIL_ACCOUNT_ID' then
                l_acct_id := TO_NUMBER(p_ieu_media_data(i).PARAM_VALUE);
            elsif p_ieu_media_data(i).PARAM_NAME = 'IEU_PARAM_PK_VALUE' then
	       --Changed for 12.1.2 project for UWQ -cherrypick
	       if l_launched_node = 'MESSAGE_ID' then
	          l_msg_id := p_ieu_media_data(i).PARAM_VALUE;
               else
                l_acct_rt_class_id := p_ieu_media_data(i).PARAM_VALUE;
               end if;
            elsif p_ieu_media_data(i).PARAM_NAME = 'RESOURCE_ID' then
                l_resource_id := p_ieu_media_data(i).PARAM_VALUE;
            end if;

        end loop;

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := 'l_acct_id='||l_acct_id||' | l_acct_rt_class_id='||
                    l_acct_rt_class_id||' | l_resource_id='||l_resource_id||
                    ' | l_launched_node=' ||l_launched_node ;
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;

        if l_launched_node = 'EMAIL_ACCOUNT_ID' then
            l_classification_id := '-1';
        elsif l_launched_node = 'ACCOUNT_ROUTE_CLASS_ID' then
            select route_classification_id into l_classification_id from iem_account_route_class
            where account_route_class_id = l_acct_rt_class_id;
        elsif l_launched_node = 'MESSAGE_ID' then
	    select rt_classification_id,customer_id,nvl(contact_id,-1)  into l_classification_id,l_cust_id,l_contact_id
	    from iem_rt_proc_emails where message_id = l_msg_id;

	    begin
		select incident_number into l_sr_number from cs_incidents_all_b
		where incident_id=(select value from iem_encrypted_tags tags,
		iem_encrypted_tag_dtls dtls where tags.encrypted_id = dtls.encrypted_id
		and dtls.key = 'IEMNBZTSRVSRID' and tags.message_id= l_msg_id );

	     exception when others then
                l_sr_number := null;
	     end;
        end if;

        x_action_type   := 2; --NULL;
        x_action_name   := 'IEM_MC_LAUNCHER';
        --Changed for 12.1.2 project
	if l_launched_node = 'MESSAGE_ID' then
          x_action_param  := 'appShortName=IEM&'||'act=cherrypickpreview&'||'uid='||l_msg_id||'&'||'agentID='||l_resource_id
                              ||'&'||'bigAcctID='||l_acct_id||'&'||'classificationID='||l_classification_id
			      ||'&'||'customerID='||l_cust_id||'&'||'contactID='||l_contact_id||'&'||'serviceRequest='||l_sr_number;
	else
	x_action_param  := 'appShortName=IEM&'||'act=getwork&'||'agentID='||l_resource_id
                        ||'&'||'accountID='||l_acct_id||'&'||'classificationID='||l_classification_id;
        end if;
        x_msg_name      := null; --'IEM_NOT_FROM_UWQ_MSG';
        x_msg_param     := NULL;
        x_dialog_style  := IEU_DS_CONSTS_PUB.G_DS_NONE;
        x_msg_appl_short_name := null;

    /* End of Stub */
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        logMessage := '[ launchInbound end ]';
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
    end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        logMessage := '[NO data found when query iem_account_route_class with l_acct_rt_class_id='||l_acct_rt_class_id||']';
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;

   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        logMessage := '[ FND_API.G_EXC_ERROR occur!!! ]';
    	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        logMessage := '[ FND_API.G_EXC_UNEXPECTED_ERROR occur!!! ]';
    	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;
   WHEN OTHERS THEN
        ROLLBACK TO launchInbound_pvt;
         if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[Other exception:' ||substr(sqlerrm,1,300)||']';
    	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHINBOUND', logMessage);
        end if;

END launchInbound;



PROCEDURE launchAcquired( p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
                          x_action_type     OUT NOCOPY number,
                          x_action_name     OUT NOCOPY varchar2,
                          x_action_param    OUT NOCOPY varchar2,
                          x_msg_name        OUT NOCOPY varchar2,
                          x_msg_param       OUT NOCOPY varchar2,
                          x_dialog_style    OUT NOCOPY number,
                          x_msg_appl_short_name OUT NOCOPY VARCHAR2
                         ) IS

  l_name  varchar2(500);
  l_value varchar2(1996);
  l_type  varchar2(500);
  logMessage varchar2(2000);

  l_acct_id varchar2(30);
  l_resource_id varchar2(30);
  l_msg_id  varchar2(30);

  l_classification_id   iem_route_classifications.route_classification_id%type;
  l_class_name          iem_route_classifications.name%type;

  l_rt_media_item_id    IEM_RT_MEDIA_ITEMS.rt_media_item_id%type;

  l_return_status         VARCHAR2(200) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count             NUMBER := 0;
  l_msg_data              VARCHAR2(2000);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT   launchInbound_pvt;
        FND_LOG_REPOSITORY.init(null,null);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[ launchAcquired begin ]';
    	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;

        for i in 1..p_ieu_media_data.count loop
            if p_ieu_media_data(i).PARAM_NAME = 'EMAIL_ACCOUNT_ID' then
                l_acct_id := p_ieu_media_data(i).PARAM_VALUE;
            elsif p_ieu_media_data(i).PARAM_NAME = 'IEU_PARAM_PK_VALUE' then
                l_msg_id := p_ieu_media_data(i).PARAM_VALUE;
            elsif p_ieu_media_data(i).PARAM_NAME = 'RESOURCE_ID' then
                l_resource_id := p_ieu_media_data(i).PARAM_VALUE;
            end if;
        end loop;

        if( FND_LOG.LEVEL_STATEMENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := 'l_acct_id='||l_acct_id||' | l_msg_id='||l_msg_id||' | l_resource_id='||l_resource_id;
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUBLAUNCHACQUIRED', logMessage);
        end if;

        select route_classification_id, name
            into l_classification_id, l_class_name
            --from iem_route_classifications a, iem_post_mdts b
            from iem_route_classifications a, iem_rt_proc_emails b
            where a.route_classification_id = b.rt_classification_id
            and b.message_id = l_msg_id;

        select rt_media_item_id
            into l_rt_media_item_id
            from IEM_RT_MEDIA_ITEMs
            where message_id = l_msg_id
		  and expire='N';

        if( FND_LOG.LEVEL_STATEMENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[l_class_name='||l_class_name||' | l_rt_media_item_id='||l_rt_media_item_id||']';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUBLAUNCHACQUIRED', logMessage);
        end if;

        x_action_type   := 2;
        x_action_name   := 'IEM_MC_LAUNCHER';
        x_action_param  := 'appShortName=IEM&'||'act=openmsg&'||'agentID='||l_resource_id
                        ||'&'||'classificationID='||l_classification_id||'&'||'classificationName='||l_class_name ||'&'||'key='||l_rt_media_item_id||'&'||'imMsgID='||l_msg_id;

        x_msg_name      := NULL;
        x_msg_param     := NULL;
        x_dialog_style  := IEU_DS_CONSTS_PUB.G_DS_NONE;
        x_msg_appl_short_name := NULL;

        if( FND_LOG.LEVEL_STATEMENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[ launchAcquired End ]';
    	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;

/* End of Stub */


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_STATEMENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[NO data found when query iem_account_route_class,IEM_RT_MEDIA_ITEMs with l_msg_id='||l_msg_id||']';
    	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;

   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[FND_API.G_EXC_ERROR ]';
    	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR]';
    	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;

   WHEN OTHERS THEN
        ROLLBACK TO launchInbound_pvt;
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            logMessage := '[Other exception:' ||substr(sqlerrm,1,300)||']';
    	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_CLIENTLAUNCH_PUB.LAUNCHACQUIRED', logMessage);
        end if;
END launchAcquired;


END IEM_CLIENTLAUNCH_PUB;

/
