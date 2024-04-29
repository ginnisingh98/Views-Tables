--------------------------------------------------------
--  DDL for Package Body IEM_DP_NOTIFICATION_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DP_NOTIFICATION_WF_PUB" as
/* $Header: iempdpnb.pls 120.4 2006/05/03 15:30:20 rtripath noship $*/

   /**********************Global Variable Declaration **********************/

   G_PKG_NAME	varchar2(30):='IEM_DP_NOTIFICATION_WF_PUB';


	PROCEDURE 	IEM_START_PROCESS(
     			WorkflowProcess IN VARCHAR2,
     			ItemType in VARCHAR2 ,
				ItemKey in number)

			IS

          l_proc_name    varchar2(20):='IEM_STARTPROCESS';
		  l_ret		number;
		  l_ret1		number;
 		  adhoc_role VARCHAR2(320);
 		  adhoc_role_name VARCHAR2(360);

begin

           wf_engine.CreateProcess( ItemType => itemtype,
                    ItemKey  => ItemKey,
                    process  => WorkflowProcess );

 			adhoc_role_name := 'Email Center Administor';
			adhoc_role := 'IEMDPNTFRECPT'||'-'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');

 			WF_DIRECTORY.CREATEADHOCROLE(adhoc_role,adhoc_role_name,null,null,null,'MAILHTML',null,null,null,'ACTIVE',sysdate);

 			wf_engine.SetItemAttrText (itemtype => itemtype,
          					itemkey  => itemkey,
         					aname      => 'IEMDPADMIN',
         				--	avalue     => adhoc_role );
         					avalue     =>'FND_RESP|IEM|EMAIL_CENTER_SSS|STANDARD' );

 			-- Set the From field:
 			WF_ENGINE.SetItemAttrText(itemtype, ItemKey, 'NTFROM', 'FND_RESP|IEM|EMAIL_CENTER_SSS|STANDARD');--'Oracle Email Center'); --FND_GLOBAL.User_Name);
                -- invoke an instance of workflow process


         	wf_engine.StartProcess( itemtype => itemtype,
         							itemkey    => itemkey );


   exception
          when others then
               wf_core.context(G_PKG_NAME, l_proc_name,
               itemtype, itemkey);
			   G_STAT:='E';
               raise;
end IEM_START_PROCESS;





PROCEDURE IEM_LAUNCH_WF_DPNTF
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name		        varchar2(30):='IEM_LAUNCH_WF_DPNTF_PVT';
    l_api_version_number    number:=1.0;
    logMessage              varchar2(2000);
	l_seq_id				number;

BEGIN

    --Standard Savepoint
    SAVEPOINT  IEM_LAUNCH_WF_DPNTF_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	--temp solution, modify when get real sequence
	SELECT IEM_DP_PROCESS_STATUS_S1.nextval
	INTO l_seq_id
	FROM dual;

	IEM_DP_NOTIFICATION_WF_PUB.IEM_START_PROCESS(
     		WorkflowProcess => 'SEND_DP_STUTAS_FYI',
     		--ItemType =>'IEMDPNTF' ,
			ItemType =>'IEMDPNTF' ,
			ItemKey =>l_seq_id);

	    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			(    p_count =>  x_msg_count,
                p_data  =>    x_msg_data
			);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   ROLLBACK TO IEM_LAUNCH_WF_DPNTF_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO IEM_LAUNCH_WF_DPNTF_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
            );
   WHEN OTHERS THEN

	ROLLBACK TO  IEM_LAUNCH_WF_DPNTF_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
            		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		     );
	END IF;
	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    		);

END	 IEM_LAUNCH_WF_DPNTF;


end IEM_DP_NOTIFICATION_WF_PUB;

/
