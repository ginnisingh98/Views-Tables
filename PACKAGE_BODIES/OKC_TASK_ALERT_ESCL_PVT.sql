--------------------------------------------------------
--  DDL for Package Body OKC_TASK_ALERT_ESCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TASK_ALERT_ESCL_PVT" AS
/* $Header: OKCPALTB.pls 120.0 2005/05/25 19:30:37 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	--Select escalation_owner_ID's
-- The following cursor changed by MSENGUPT on 12/08/2001 to change okc_rules_v to okc_rules_b
	Cursor escal_owner_id(p_tve_id IN NUMBER) is
	select rul.rule_information6 escalate_owner1_id
	      ,rul.rule_information7 escalate_owner2_id
	      ,rul.dnz_chr_id
	from okc_rules_b rul
	where to_char(p_tve_id)           = rul.rule_information2
	and rul.rule_information_category = 'NTN';

	--Select Owner_names
	Cursor escal_owner_cur(p_escal_owner_id IN NUMBER) is
	Select fnd.user_name escalate_owner, okx.name full_name
	from  okx_resources_v okx, fnd_user fnd
	where okx.user_id = fnd.user_id
	and   okx.id1     = p_escal_owner_id;

  -- Following Local Procedure added for Bug 2477032

  PROCEDURE get_fnd_msg_stack(p_msg_data IN VARCHAR2) IS
    BEGIN
     IF FND_MSG_PUB.Count_Msg > 1 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
     ELSE
         FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg_data);
     END IF;
    FND_MSG_PUB.initialize;
  END get_fnd_msg_stack;

--------------------------------------------------------------------------------------
	-- Start of comments
  	-- Procedure Name  : task_alert
  	-- Description     : This procedure sends notifications to all the task owners
	--                   before the due date is reached.
     --   		      It also updates the workflow process id in tasks table
  	-- Version         : 1.0
  	-- End of comments
--------------------------------------------------------------------------------------
	PROCEDURE task_alert(errbuf          OUT NOCOPY VARCHAR2,
			     retcode         OUT NOCOPY VARCHAR2,
			     p_api_version   IN NUMBER,
			     p_init_msg_list IN VARCHAR2 ,
			     p_wf_name	     IN VARCHAR2,
			     p_wf_process    IN VARCHAR2) IS

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCSCHRULE - Contracts Schedule Rule - Bug 1683539
	CURSOR alert_cur IS
	Select jtb.object_version_number
	      ,jtb.task_id
	      ,jtb.task_number
	      ,jtb.task_name
	      ,jtb.source_object_id
	      ,jtb.owner_id
              ,jtb.planned_end_date
	      ,jtb.notification_period
              ,res.tve_id
	from jtf_tasks_vl jtb,
	     jtf_task_types_vl jttl,
	     jtf_task_statuses_vl jtsl,
             okc_resolved_timevalues res
	where jtb.actual_end_date IS NULL
        and res.id = jtb.source_object_id
	and   jtb.workflow_process_id IS NULL
	and   jtb.source_object_type_code = 'OKC_RESTIME'
	and   jtb.task_type_id            = jttl.task_type_id
	and   jttl.task_type_id           = 23
	--and jttl.name                   = 'OKCSCHRULE'
	and   jtb.task_status_id          = jtsl.task_status_id
	and   jtsl.task_status_id         = 10;
	--and jtsl.name                   = 'Open';

	l_workflow_process_id	        jtf_tasks_v.workflow_process_id%TYPE;
	l_object_version_number         NUMBER;
	l_task_id		        jtf_tasks_b.task_id%TYPE;
	l_task_number			jtf_tasks_b.task_number%TYPE;
	l_task_name			jtf_tasks_tl.task_name%TYPE;
	l_planned_end_date		jtf_tasks_b.planned_end_date%TYPE;
	l_notification_period           jtf_tasks_b.notification_period%TYPE;
	l_owner_id			jtf_tasks_b.owner_id%TYPE;
	l_owner_name			fnd_user.user_name%TYPE;
	l_actual_end_date		jtf_tasks_b.actual_end_date%TYPE;
	l_contract_id			okc_rules_b.dnz_chr_id%TYPE;
	l_escalation_owner1_id	        okc_rules_b.rule_information6%TYPE;
	l_escalation_owner2_id	        okc_rules_b.rule_information7%TYPE;
	l_escalate_name		        VARCHAR2(100);
	l_dummy				VARCHAR2(100);
	l_escalate_owner1		fnd_user.user_name%TYPE;
	l_escalate_owner2		fnd_user.user_name%TYPE;
	l_alarm_interval		jtf_tasks_b.alarm_interval%TYPE;
	l_planned_date 		        jtf_tasks_b.planned_end_date%TYPE;
	l_source_object_id		jtf_tasks_b.source_object_id%TYPE;
	l_item_type 			VARCHAR2(30);
	l_item_key			NUMBER;
	l_tve_id			NUMBER;
	l_process		        VARCHAR2(30);
	l_return_status		        VARCHAR2(3);
	l_api_name              	CONSTANT VARCHAR2(30) := 'task_alert';
        l_success_count                 NUMBER := 0;
        l_failure_count                 NUMBER := 0;

	--Send notifications to all task owners
	BEGIN
             IF (l_debug = 'Y') THEN
                OKC_DEBUG.set_indentation(l_api_name);
                OKC_DEBUG.log('10: Entered task_alert', 2);
             END IF;

		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                          G_PKG_NAME,
                                                          p_init_msg_list,
						          g_api_version,
						          p_api_version,
                                                          G_LEVEL,
                                                          g_return_status);
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_ERROR;
  		END IF;

		--Initialize the return code
		retcode := 0;

		--Check if the workflow name and process name exists
		IF p_wf_name IS NULL OR p_wf_process IS NULL THEN
		okc_api.set_message(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_PROCESS_NOTFOUND,
                            	    p_token1       => G_WF_NAME_TOKEN,
                            	    p_token1_value => P_WF_NAME,
			    	    p_token2       => G_WF_P_NAME_TOKEN,
                                    p_token2_value => P_WF_PROCESS);
                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('20: WorkFlow Name OR Process Name do not exist ....');
                           OKC_DEBUG.log('30: WorkFlow Name ' || p_wf_name || ' OR Process Name '|| p_wf_process);
                        END IF;
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
		--Check if the cursor is already open
		IF  alert_cur%ISOPEN THEN
			CLOSE alert_cur;
		END IF;
	  	FOR alert_rec in alert_cur LOOP
                   BEGIN
                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('40: In the alert_rec LOOP ....');
                        END IF;
                        savepoint task_alert_PVT;
			l_object_version_number     := alert_rec.object_version_number;
			l_task_id 		    := alert_rec.task_id;
			l_task_number		    := alert_rec.task_number;
			l_task_name 		    := alert_rec.task_name;
			l_source_object_id          := alert_rec.source_object_id;
			l_owner_id      	    := alert_rec.owner_id;
			l_planned_end_date	    := alert_rec.planned_end_date;
			l_notification_period       := alert_rec.notification_period;
			l_tve_id                    := alert_rec.tve_id;

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('50: l_object_version_number is ... '|| alert_rec.object_version_number);
   			OKC_DEBUG.log('60: l_task_id 		    ... '|| alert_rec.task_id);
   			OKC_DEBUG.log('70: l_task_number	    ... '|| alert_rec.task_number);
   			OKC_DEBUG.log('80: l_task_name 		    ... '|| alert_rec.task_name);
   			OKC_DEBUG.log('90: l_source_object_id       ... '|| alert_rec.source_object_id);
   			OKC_DEBUG.log('100: l_owner_id      	    ... '|| alert_rec.owner_id);
   			OKC_DEBUG.log('110: l_planned_end_date	    ... '|| alert_rec.planned_end_date);
   			OKC_DEBUG.log('120: l_notification_period   ... '|| alert_rec.notification_period);
                        END IF;

		    --If the planned date - current date is less than or equal to the notification period
		    --send out notifications to all the task owners

	     	    IF (TRUNC(l_planned_end_date) - TRUNC(sysdate) <= l_notification_period) THEN

			     --Select all the escalation owner id's
			     IF NOT escal_owner_id%ISOPEN THEN
			        --Get escalation owner1 ID
			        OPEN escal_owner_id(l_tve_id);
			        FETCH escal_owner_id into
				        l_escalation_owner1_id, l_escalation_owner2_id, l_contract_id;
			        CLOSE escal_owner_id;
			     END IF;

			     IF (l_debug = 'Y') THEN
   			     OKC_DEBUG.log('130: l_escalation_owner1_id         ... '|| l_escalation_owner1_id);
   			     OKC_DEBUG.log('140: l_escalation_owner2_id         ... '|| l_escalation_owner2_id);
   			     OKC_DEBUG.log('150: l_contract_id                  ... '|| l_contract_id);
			     END IF;

				--Select the owner of the Task
				IF NOT escal_owner_cur%ISOPEN THEN
				   --Get Task Owner
				   OPEN escal_owner_cur(l_owner_id);
				   FETCH escal_owner_cur into l_owner_name, l_dummy;
				   CLOSE escal_owner_cur;
			        END IF;

			     IF (l_debug = 'Y') THEN
   			     OKC_DEBUG.log('151: l_owner_name         ... '|| l_owner_name);
   			     OKC_DEBUG.log('160: l_dummy              ... '|| l_dummy);
			     END IF;

				--Select escalation owner1
				IF NOT escal_owner_cur%ISOPEN THEN
				   --Get escalation owner1
				   OPEN escal_owner_cur(l_escalation_owner1_id);
				   FETCH escal_owner_cur into l_escalate_owner1, l_escalate_name;
				   CLOSE escal_owner_cur;
		                END IF;

			     IF (l_debug = 'Y') THEN
   			     OKC_DEBUG.log('161: l_escalate_owner1         ... '|| l_escalate_owner1);
   			     OKC_DEBUG.log('162: l_escalate_name           ... '|| l_escalate_name);
			     END IF;

			--Select the item key
			select okc_wf_notify_s1.nextval
			into l_item_key
			from dual;

			l_item_key  := l_item_key || l_task_id;
			l_item_type := p_wf_name;
			l_process   := p_wf_process;

		     IF (l_debug = 'Y') THEN
   		     OKC_DEBUG.log('170: l_item_key         ... '|| l_item_key);
   		     OKC_DEBUG.log('180: l_item_type        ... '|| l_item_type);
   		     OKC_DEBUG.log('190: l_process          ... '|| l_process);
		     END IF;

			--Launch The workflow to send notifications
			WF_ENGINE.CREATEPROCESS(L_ITEM_TYPE, L_ITEM_KEY, L_PROCESS);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('200: Launching the Workflow to send notification .....');
                        END IF;

			--set item attributes;
			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'TASK_NAME',
						  avalue   => l_task_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('210: Setting Item Attribute TASK_NAME with '|| l_task_name);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_OWNER',
						    avalue   => l_owner_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('220: Setting Item Attribute TASK_OWNER with '|| l_owner_name);
                        END IF;

			WF_ENGINE.Setitemattrdate(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'DUE_DATE',
						  avalue   => l_planned_end_date);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('230: Setting Item Attribute DUE_DATE with '|| l_planned_end_date);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'ESCALATE_OWNER',
						    avalue   => l_escalate_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('240: Setting Item Attribute ESCALATE_OWNER with '|| l_escalate_name);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DISPLAY_TASK_OWNER',
						    avalue   => l_dummy);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('250: Setting Item Attribute DISPLAY_TASK_OWNER with '|| l_dummy);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_ID',
						    avalue   => l_task_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('260: Setting Item Attribute TASK_ID with '|| l_task_id);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'CONTRACT_ID',
						    avalue   => l_contract_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('270: Setting Item Attribute CONTRACT_ID with '|| l_contract_id);
                        END IF;

			--Start the workflow process
			WF_ENGINE.STARTPROCESS(l_item_type, l_item_key);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('280: started workflow process    .....');
                        END IF;

--			commit;

			l_return_status := OKC_API.START_ACTIVITY(
                                                         l_api_name,
                                                         G_PKG_NAME,
                                                         p_init_msg_list,
				                         g_api_version,
				                         p_api_version,
                                                         G_LEVEL,
                                                         g_return_status);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_ERROR;
  			END IF;

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('290: before OKC_TASK_PUB.update_task   .....');
                        END IF;

			--Update workflow_process_id in the tasks table
			OKC_TASK_PUB.update_task(p_api_version	 => g_api_version,
					         p_object_version_number => l_object_version_number,
					         p_init_msg_list => p_init_msg_list,
				                 p_task_id       => l_task_id,
					         p_task_number	 => l_task_number,
					         p_workflow_process_id	 => l_item_key,
					         x_return_status => g_return_status,
					         x_msg_count	 => g_msg_count,
					         x_msg_data      => g_msg_data);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('300: after OKC_TASK_PUB.update_task return_status is '|| g_return_status );
                        END IF;

			IF (g_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                               l_failure_count := l_failure_count + 1;
                                rollback to task_alert_PVT;
       				raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    			ELSIF (g_return_status = OKC_API.G_RET_STS_ERROR) THEN
                               l_failure_count := l_failure_count + 1;
                                rollback to task_alert_PVT;
       				raise OKC_API.G_EXCEPTION_ERROR;
			ELSIF (g_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                               l_success_count := l_success_count + 1;
				commit;
			END IF;
	       END IF;
	EXCEPTION
	  	WHEN OKC_API.G_EXCEPTION_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Exception Error in task_alert is '||g_msg_data);

     		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Unexcepted Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Unexpected error in task_alert is '||g_msg_data);

     		WHEN OTHERS THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Other Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
  	  	    retcode := 2;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,substr(sqlerrm,1,250));
                get_fnd_msg_stack(' Other Exception Error in task_alert is '||g_msg_data);
                exit;
              END;
	  END LOOP;
	  OKC_API.END_ACTIVITY(g_msg_count, g_msg_data);

          IF (l_debug = 'Y') THEN
             OKC_DEBUG.log('400: Exiting task_alert...', 2);
             OKC_DEBUG.Reset_Indentation;
          END IF;
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Success Count:'||l_success_count);
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Failure Count:'||l_failure_count);

	EXCEPTION
	  	WHEN OKC_API.G_EXCEPTION_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 400:Exception Error in task_alert...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

			retcode := 2;
          	        errbuf := substr(sqlerrm,1,250);
    			g_return_status := OKC_API.HANDLE_EXCEPTIONS
    			(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Exception Error in task_alert is '||g_msg_data);

     		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 400:Unexcepted Error in task_alert...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
    			g_return_status := OKC_API.HANDLE_EXCEPTIONS
    			(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_UNEXP_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Unexpected error in task_alert is '||g_msg_data);

     		WHEN OTHERS THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 400:Other Exception Error in task_alert...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

  			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
    			g_return_status := OKC_API.HANDLE_EXCEPTIONS
    			(l_api_name,
        		G_PKG_NAME,
        		'OTHERS',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Other Exception Error in task_alert is '||g_msg_data);
	END task_alert;

--------------------------------------------------------------------------------
	-- Start of comments
  	-- Procedure Name  : task_escalation1
  	-- Description     : This Procedure escalates the task to the manager if
	--                   not completed by the task owner. It also updates the
	--                   workflow process id and alarm fired count in tasks table
  	-- Version         : 1.0
  	-- End of comments
--------------------------------------------------------------------------------
	PROCEDURE task_escalation1(
                                    errbuf   		OUT NOCOPY VARCHAR2,
			      	    retcode    		OUT NOCOPY VARCHAR2,
				    p_api_version	IN NUMBER,
				    p_init_msg_list	IN VARCHAR2 ,
				    p_wf_name		IN VARCHAR2,
				    p_wf_process	IN VARCHAR2) IS

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCSCHRULE - Contract Schedule Rule - Bug 1683539
	CURSOR escalate_owner1_cur is
	Select jtb.object_version_number
	      ,jtb.task_id
	      ,jtb.task_number
	      ,jtb.task_name
	      ,jtb.source_object_id
	      ,jtb.owner_id
	      ,jtb.planned_end_date
	      ,jtb.actual_end_date
	      ,jtb.alarm_interval
              ,res.tve_id
	from jtf_tasks_vl jtb,
	     jtf_task_types_tl jttl,
	     jtf_task_statuses_tl jtsl,
             okc_resolved_timevalues res
	where jtb.actual_end_date IS NULL
        and res.id = jtb.source_object_id
	and jtb.workflow_process_id IS NOT NULL
	and jtb.alarm_fired_count IS NULL
	and jtb.source_object_type_code = 'OKC_RESTIME'
	and jtb.task_type_id            = jttl.task_type_id
	and jttl.task_type_id           = 23
	--and jttl.name                 = 'OKCSCHRULE'
	and jtb.task_status_id          = jtsl.task_status_id
	and jtsl.task_status_id         = 10;
	--and jtsl.name                 = 'Open';

	l_workflow_process_id	        jtf_tasks_v.workflow_process_id%TYPE;
	l_object_version_number	        NUMBER;
	l_tve_id	                NUMBER;
	l_contract_id			okc_rules_b.dnz_chr_id%TYPE;
	l_task_id			jtf_tasks_b.task_id%TYPE;
	l_task_number			jtf_tasks_b.task_number%TYPE;
	l_task_name			jtf_tasks_tl.task_name%TYPE;
	l_planned_end_date		jtf_tasks_b.planned_end_date%TYPE;
	l_notification_period	        jtf_tasks_b.notification_period%TYPE;
	l_owner_id			jtf_tasks_b.owner_id%TYPE;
	l_owner_name			fnd_user.user_name%TYPE;
	l_actual_end_date		jtf_tasks_b.actual_end_date%TYPE;
	l_escalation_owner1_id	        okc_rules_b.rule_information6%TYPE;
	l_escalation_owner2_id	        okc_rules_b.rule_information7%TYPE;
	l_escalate_owner1		fnd_user.user_name%TYPE;
	l_escalate_owner2		fnd_user.user_name%TYPE;
	l_escalate_name		        VARCHAR2(100);
	l_dummy				VARCHAR2(100);
	l_alarm_interval		jtf_tasks_v.alarm_interval%TYPE;
	l_return_status		        VARCHAR2(3);
	l_planned_date 		        jtf_tasks_b.planned_end_date%TYPE;
	l_source_object_id		jtf_tasks_b.source_object_id%TYPE;
	l_item_type 			VARCHAR2(30);
	l_item_key			NUMBER;
	l_process		        VARCHAR2(30);
	l_api_name              	CONSTANT VARCHAR2(30) := 'task_escalation1';
        l_success_count                 NUMBER := 0;
        l_failure_count                 NUMBER := 0;

	BEGIN
             IF (l_debug = 'Y') THEN
                OKC_DEBUG.set_indentation(l_api_name);
                OKC_DEBUG.log('510: Entered task_escalation1', 2);
             END IF;

		 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                           G_PKG_NAME,
                                                           p_init_msg_list,
						           g_api_version,
						           p_api_version,
                                                           G_LEVEL,
                                                           g_return_status);
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_ERROR;
  		END IF;

		--Initialize the return code
		retcode := 0;

		--Check if the workflow name and process_name exists
		IF p_wf_name IS NULL OR p_wf_process IS NULL THEN
		okc_api.set_message(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_PROCESS_NOTFOUND,
                            	    p_token1       => G_WF_NAME_TOKEN,
                            	    p_token1_value => P_WF_NAME,
			    	    p_token2       => G_WF_P_NAME_TOKEN,
                        	    p_token2_value => P_WF_PROCESS);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('520: WorkFlow Name OR Process Name do not exist ....');
                           OKC_DEBUG.log('530: WorkFlow Name ' || p_wf_name || ' OR Process Name '|| p_wf_process);
                        END IF;

			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

	     --Check if the cursor is already open
	     IF escalate_owner1_cur%ISOPEN THEN
			CLOSE escalate_owner1_cur;
	     END IF;
	  	FOR escalate_owner1_rec in escalate_owner1_cur LOOP
                   BEGIN

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('540: In the escalate_owner1_rec LOOP ....');
                        END IF;
                        savepoint task_alert_pvt;

			l_object_version_number	:= escalate_owner1_rec.object_version_number;
			l_task_id		:= escalate_owner1_rec.task_id;
			l_task_number		:= escalate_owner1_rec.task_number;
			l_task_name		:= escalate_owner1_rec.task_name;
			l_source_object_id	:= escalate_owner1_rec.source_object_id;
			l_owner_id		:= escalate_owner1_rec.owner_id;
			l_planned_end_date	:= escalate_owner1_rec.planned_end_date;
			l_actual_end_date	:= escalate_owner1_rec.actual_end_date;
			l_alarm_interval	:= escalate_owner1_rec.alarm_interval;
			l_tve_id	        := escalate_owner1_rec.tve_id;

                 IF (l_debug = 'Y') THEN
                    OKC_DEBUG.log('550: l_object_version_number is ... '|| escalate_owner1_rec.object_version_number);
                    OKC_DEBUG.log('560: l_task_id                  ... '|| escalate_owner1_rec.task_id);
                    OKC_DEBUG.log('570: l_task_number              ... '|| escalate_owner1_rec.task_number);
                    OKC_DEBUG.log('580: l_task_name                ... '|| escalate_owner1_rec.task_name);
                    OKC_DEBUG.log('590: l_source_object_id         ... '|| escalate_owner1_rec.source_object_id);
                    OKC_DEBUG.log('600: l_owner_id                 ... '|| escalate_owner1_rec.owner_id);
                    OKC_DEBUG.log('610: l_planned_end_date         ... '|| escalate_owner1_rec.planned_end_date);
                    OKC_DEBUG.log('615: l_actual_end_date          ... '|| escalate_owner1_rec.actual_end_date);
                    OKC_DEBUG.log('620: l_alarm_interval           ... '|| escalate_owner1_rec.alarm_interval);
                 END IF;

		-- If the current date is greater than planned end date + alarm interval
		-- and the task is incomplete then escalate the task to the  manager

	     	IF (TRUNC(sysdate) >= TRUNC(l_planned_end_date + l_alarm_interval)) THEN
			--Get escalation owner id
			 IF NOT escal_owner_id%ISOPEN THEN
			        --Get escalation owner1 ID
			        OPEN escal_owner_id(l_tve_id);
			        FETCH escal_owner_id into
					l_escalation_owner1_id, l_escalation_owner2_id, l_contract_id;
			        CLOSE escal_owner_id;
			 END IF;

                             IF (l_debug = 'Y') THEN
                                OKC_DEBUG.log('630: l_escalation_owner1_id         ... '|| l_escalation_owner1_id);
                                OKC_DEBUG.log('640: l_escalation_owner2_id         ... '|| l_escalation_owner2_id);
                                OKC_DEBUG.log('650: l_contract_id                  ... '|| l_contract_id);
                             END IF;

				--Select the owner of the Task
				IF NOT escal_owner_cur%ISOPEN THEN
				   --Get Task Owner
				   OPEN escal_owner_cur(l_owner_id);
				   FETCH escal_owner_cur into l_dummy, l_owner_name;
				   CLOSE escal_owner_cur;
				END IF;

                             IF (l_debug = 'Y') THEN
                                OKC_DEBUG.log('651: l_owner_name         ... '|| l_owner_name);
                                OKC_DEBUG.log('660: l_dummy              ... '|| l_dummy);
                             END IF;

				--Get escalation owner1
				IF NOT escal_owner_cur%ISOPEN THEN
				   OPEN escal_owner_cur(l_escalation_owner1_id);
				   FETCH escal_owner_cur into l_escalate_owner1, l_dummy;
				   CLOSE escal_owner_cur;
			     END IF;

                            IF (l_debug = 'Y') THEN
                               OKC_DEBUG.log('661: l_escalate_owner1         ... '|| l_escalate_owner1);
                               OKC_DEBUG.log('662: l_dummy                   ... '|| l_dummy);
                            END IF;

				--Get escalation owner2
				IF NOT escal_owner_cur%ISOPEN THEN
				   OPEN escal_owner_cur(l_escalation_owner2_id);
				   FETCH escal_owner_cur into l_escalate_owner2, l_escalate_name;
				   CLOSE escal_owner_cur;
			     END IF;

                            IF (l_debug = 'Y') THEN
                               OKC_DEBUG.log('663: l_escalate_owner2         ... '|| l_escalate_owner2);
                               OKC_DEBUG.log('664: l_escalate_name           ... '|| l_escalate_name);
                            END IF;

			select okc_wf_notify_s1.nextval
			into l_item_key
			from dual;

			l_item_key := l_item_key || l_task_id;
			l_item_type := p_wf_name;
			l_process := p_wf_process;

                     IF (l_debug = 'Y') THEN
                        OKC_DEBUG.log('670: l_item_key         ... '|| l_item_key);
                        OKC_DEBUG.log('680: l_item_type        ... '|| l_item_type);
                        OKC_DEBUG.log('690: l_process          ... '|| l_process);
                     END IF;

		--Launch the workflow to escalate the incomplete tasks to the manager
		WF_ENGINE.CREATEPROCESS(L_ITEM_TYPE, L_ITEM_KEY, L_PROCESS);

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('700: Launching the Workflow to send notification .....');
                END IF;

		--set item attributes;
			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'TASK_NAME',
						  avalue   => l_task_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('710: Setting Item Attribute TASK_NAME with '|| l_task_name);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_OWNER',
						    avalue   => l_escalate_owner1);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('720: Setting Item Attribute TASK_OWNER with '|| l_escalate_owner1);
                        END IF;

			WF_ENGINE.Setitemattrdate(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'DUE_DATE',
						  avalue   => l_planned_end_date);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('730: Setting Item Attribute DUE_DATE with '|| l_planned_end_date);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'ESCALATE_OWNER',
						    avalue   => l_escalate_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('740: Setting Item Attribute ESCALATE_OWNER with '|| l_escalate_name);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DISPLAY_TASK_OWNER',
						    avalue   => l_owner_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('750: Setting Item Attribute DISPLAY_TASK_OWNER with '|| l_owner_name);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_ID',
						    avalue   => l_task_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('760: Setting Item Attribute TASK_ID with '|| l_task_id);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'CONTRACT_ID',
						    avalue   => l_contract_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('770: Setting Item Attribute CONTRACT_ID with '|| l_contract_id);
                        END IF;
		--Start the workflow
		WF_ENGINE.STARTPROCESS(l_item_type, l_item_key);

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('780: started workflow process    .....');
                END IF;

--		commit;

		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
						  g_api_version,
						  p_api_version,
                                                  G_LEVEL,
                                                  g_return_status);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_ERROR;
  			END IF;

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('790: before OKC_TASK_PUB.update_task   .....');
                        END IF;

		   --Update workflow_process_id, alarm_fired_count in the tasks table
		   OKC_TASK_PUB.update_task(p_api_version		=> g_api_version,
					 p_object_version_number 	=> l_object_version_number,
					 p_init_msg_list	        => p_init_msg_list,
				         p_task_id               	=> l_task_id,
					 p_task_number	         	=> l_task_number,
					 p_workflow_process_id		=> l_item_key,
					 p_alarm_fired_count     	=> 1,
					 x_return_status         	=> g_return_status,
					 x_msg_count		 	=> g_msg_count,
					 x_msg_data              	=> g_msg_data);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('800: after OKC_TASK_PUB.update_task return_status is '|| g_return_status);
                        END IF;

			IF (g_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                               l_failure_count := l_failure_count + 1;
                                rollback to task_alert_pvt;
       				raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     			ELSIF (g_return_status = OKC_API.G_RET_STS_ERROR) THEN
                               l_failure_count := l_failure_count + 1;
                                rollback to task_alert_pvt;
       				raise OKC_API.G_EXCEPTION_ERROR;
			ELSIF (g_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                                l_success_count := l_success_count + 1;
				commit;
     			END IF;
		     END IF;
	     EXCEPTION
	  	WHEN OKC_API.G_EXCEPTION_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Exception Error in task_alert is '||g_msg_data);

     		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Unexcepted Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Unexpected error in task_alert is '||g_msg_data);

     		WHEN OTHERS THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Other Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

  			retcode := 2;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,substr(sqlerrm,1,250));

                get_fnd_msg_stack(' Other Exception Error in task_alert is '||g_msg_data);
                exit;
              END;
		   END LOOP;
		OKC_API.END_ACTIVITY(g_msg_count, g_msg_data);

          IF (l_debug = 'Y') THEN
             OKC_DEBUG.log('900: Exiting task_task_escalation1...', 2);
             OKC_DEBUG.Reset_Indentation;
          END IF;
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Success Count:'||l_success_count);
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Failure Count:'||l_failure_count);

	EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 900:Exception Error in task_escalation1...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       			g_return_status := OKC_API.HANDLE_EXCEPTIONS
       			(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Exception Error in task_escalation1 is '||g_msg_data);

     		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 900:Unexcepted Error in task_escalation1...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       			g_return_status := OKC_API.HANDLE_EXCEPTIONS
       			(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_UNEXP_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Unexpected error in task_escaltion1 is '||g_msg_data);

     		WHEN OTHERS THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 900:Other Exception Error in task_escalation1...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       			g_return_status := OKC_API.HANDLE_EXCEPTIONS
       			(l_api_name,
        		G_PKG_NAME,
        		'OTHERS',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Other Exception Error in task_escalation1 is '||g_msg_data);

	END task_escalation1;

        ------------------------------------------------------------------------------------------------
	-- Start of comments
  	-- Procedure Name  : task_escalation2
  	-- Description     : This Procedure escalates the task to to level 2(manager) if not
        --                   completed by the task owner
        --		     It also updates the workflow process id and alarm fired count in tasks table
  	-- Version         : 1.0
  	-- End of comments
        ------------------------------------------------------------------------------------------------

	PROCEDURE task_escalation2(errbuf   		OUT NOCOPY VARCHAR2,
			      	   retcode    		OUT NOCOPY VARCHAR2,
				   p_api_version	IN NUMBER,
				   p_init_msg_list	IN VARCHAR2 ,
				   p_wf_name		IN VARCHAR2,
				   p_wf_process		IN VARCHAR2) IS
-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCSCHRULE - Contract Schedule Rule - Bug 1683539
	CURSOR escalate_owner2_cur is
	Select jtb.object_version_number
	      ,jtb.task_id
	      ,jtb.task_number
	      ,jtb.task_name
	      ,jtb.owner_id
	      ,jtb.source_object_id
	      ,jtb.planned_end_date
	      ,jtb.actual_end_date
	      ,jtb.alarm_interval
              ,res.tve_id
	from jtf_tasks_vl jtb,
	     jtf_task_types_vl jttl,
	     jtf_task_statuses_vl jtsl,
             okc_resolved_timevalues res
	where jtb.actual_end_date IS NULL
        and res.id = jtb.source_object_id
	and jtb.workflow_process_id IS NOT NULL
	and jtb.alarm_fired_count       = 1
	and jtb.source_object_type_code = 'OKC_RESTIME'
	and jtb.task_type_id            = jttl.task_type_id
	and jttl.task_type_id           = 23
	--and jttl.name                 = 'OKCSCHRULE'
	and jtb.task_status_id          = jtsl.task_status_id
	and jtsl.task_status_id         = 10;
	--and jtsl.name                 = 'Open';

	l_workflow_process_id		jtf_tasks_v.workflow_process_id%TYPE;
	l_object_version_number		NUMBER;
	l_contract_id			okc_rules_b.dnz_chr_id%TYPE;
	l_task_id			jtf_tasks_b.task_id%TYPE;
	l_task_number			jtf_tasks_b.task_number%TYPE;
	l_task_name			jtf_tasks_tl.task_name%TYPE;
	l_planned_end_date		jtf_tasks_b.planned_end_date%TYPE;
	l_notification_period		jtf_tasks_b.notification_period%TYPE;
	l_owner_id			jtf_tasks_b.owner_id%TYPE;
	l_owner_name			fnd_user.user_name%TYPE;
	l_actual_end_date		jtf_tasks_b.actual_end_date%TYPE;
	l_escalation_owner1_id		okc_rules_b.rule_information6%TYPE;
	l_escalation_owner2_id		okc_rules_b.rule_information7%TYPE;
	l_escalate_name			VARCHAR2(100);
	l_dummy				VARCHAR2(100);
	l_escalate_owner1		fnd_user.user_name%TYPE;
	l_escalate_owner2		fnd_user.user_name%TYPE;
	l_alarm_interval		jtf_tasks_b.alarm_interval%TYPE;
	l_return_status			VARCHAR2(3);
	l_planned_date 			jtf_tasks_b.planned_end_date%TYPE;
	l_source_object_id		jtf_tasks_b.source_object_id%TYPE;
	l_item_type 			VARCHAR2(30);
	l_item_key			NUMBER;
	l_tve_id			NUMBER;
	l_process			VARCHAR2(30);
	l_api_name              	CONSTANT VARCHAR2(30) := 'task_escalation2';
        l_success_count                 NUMBER := 0;
        l_failure_count                 NUMBER := 0;

	BEGIN
             IF (l_debug = 'Y') THEN
                OKC_DEBUG.set_indentation(l_api_name);
                OKC_DEBUG.log('1010: Entered task_escalation2', 2);
             END IF;

		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
						  g_api_version,
						  p_api_version,
                                                  G_LEVEL,
                                                  g_return_status);
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_ERROR;
  		END IF;

		--Initialize the return code
		retcode := 0;

		--Check if the item_type and process_name exists
		IF p_wf_name IS NULL OR p_wf_process IS NULL THEN
		okc_api.set_message(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_PROCESS_NOTFOUND,
                            	    p_token1       => G_WF_NAME_TOKEN,
                            	    p_token1_value => P_WF_NAME,
			    	    p_token2       => G_WF_P_NAME_TOKEN,
                            	    p_token2_value => P_WF_PROCESS);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('1020: WorkFlow Name OR Process Name do not exist ....');
                           OKC_DEBUG.log('1030: WorkFlow Name ' || p_wf_name || ' OR Process Name '|| p_wf_process);
                        END IF;

			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

	     --Check if the cursor is already open
	     	IF escalate_owner2_cur%ISOPEN THEN
			CLOSE escalate_owner2_cur;
		END IF;
	  	  FOR escalate_owner2_rec in escalate_owner2_cur LOOP
                   BEGIN

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('1040: In the escalate_owner2_rec LOOP ....');
                        END IF;
                        savepoint task_alert_pvt;

				l_object_version_number	:= escalate_owner2_rec.object_version_number;
				l_task_id		:= escalate_owner2_rec.task_id;
				l_task_number		:= escalate_owner2_rec.task_number;
				l_task_name		:= escalate_owner2_rec.task_name;
				l_owner_id		:= escalate_owner2_rec.owner_id;
				l_source_object_id	:= escalate_owner2_rec.source_object_id;
				l_planned_end_date	:= escalate_owner2_rec.planned_end_date;
				l_actual_end_date	:= escalate_owner2_rec.actual_end_date;
				l_alarm_interval	:= escalate_owner2_rec.alarm_interval;
				l_tve_id	        := escalate_owner2_rec.tve_id;

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('1050: l_object_version_number is ... '|| escalate_owner2_rec.object_version_number);
                   OKC_DEBUG.log('1060: l_task_id                  ... '|| escalate_owner2_rec.task_id);
                   OKC_DEBUG.log('1070: l_task_number              ... '|| escalate_owner2_rec.task_number);
                   OKC_DEBUG.log('1080: l_task_name                ... '|| escalate_owner2_rec.task_name);
                   OKC_DEBUG.log('1090: l_source_object_id         ... '|| escalate_owner2_rec.source_object_id);
                   OKC_DEBUG.log('2000: l_owner_id                 ... '|| escalate_owner2_rec.owner_id);
                   OKC_DEBUG.log('2010: l_planned_end_date         ... '|| escalate_owner2_rec.planned_end_date);
                   OKC_DEBUG.log('2015: l_actual_end_date          ... '|| escalate_owner2_rec.actual_end_date);
                   OKC_DEBUG.log('2020: l_alarm_interval           ... '|| escalate_owner2_rec.alarm_interval);
                END IF;

		     --If current date is greater than or equal to planned date + twice the alarm interval then
		     --escalate the task to level 2(manager)
	   	     IF (TRUNC(sysdate) >= TRUNC(l_planned_end_date + (2 * l_alarm_interval))) THEN
			   --Get escalation owner2 ID
			   IF NOT escal_owner_id%ISOPEN THEN
			      --Get escalation owner1 ID
			      OPEN escal_owner_id(l_tve_id);
			      FETCH escal_owner_id into l_escalation_owner1_id,l_escalation_owner2_id,l_contract_id;
			      CLOSE escal_owner_id;
			   END IF;

                             IF (l_debug = 'Y') THEN
                                OKC_DEBUG.log('1030: l_escalation_owner1_id         ... '|| l_escalation_owner1_id);
                                OKC_DEBUG.log('1040: l_escalation_owner2_id         ... '|| l_escalation_owner2_id);
                                OKC_DEBUG.log('1050: l_contract_id                  ... '|| l_contract_id);
                             END IF;

				--Select the owner of the Task
				IF NOT escal_owner_cur%ISOPEN THEN
				   --Get Task Owner
				   OPEN escal_owner_cur(l_owner_id);
				   FETCH escal_owner_cur into l_dummy, l_owner_name;
				   CLOSE escal_owner_cur;
				END IF;

                             IF (l_debug = 'Y') THEN
                                OKC_DEBUG.log('1051: l_owner_name         ... '|| l_owner_name);
                                OKC_DEBUG.log('1060: l_dummy              ... '|| l_dummy);
                             END IF;

				--Get escalation owner2
				IF NOT escal_owner_cur%ISOPEN THEN
				   OPEN escal_owner_cur(l_escalation_owner2_id);
				   FETCH escal_owner_cur into l_escalate_owner2, l_dummy;
				   CLOSE escal_owner_cur;
			     END IF;

                            IF (l_debug = 'Y') THEN
                               OKC_DEBUG.log('1061: l_escalate_owner2         ... '|| l_escalate_owner2);
                               OKC_DEBUG.log('1062: l_dummy                   ... '|| l_dummy);
                            END IF;

			select okc_wf_notify_s1.nextval
			into l_item_key
			from dual;

			l_item_key := l_item_key || l_task_id;
			l_item_type := p_wf_name;
			l_process := p_wf_process;

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('1070: l_item_key         ... '|| l_item_key);
                           OKC_DEBUG.log('1080: l_item_type        ... '|| l_item_type);
                           OKC_DEBUG.log('1090: l_process          ... '|| l_process);
                        END IF;

			--Launch Workflow to escalate the task to level 2 (mananger)
			WF_ENGINE.CREATEPROCESS(L_ITEM_TYPE, L_ITEM_KEY, L_PROCESS);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2000: Launching the Workflow to send notification .....');
                        END IF;

			--set item attributes;
			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'TASK_NAME',
						  avalue   => l_task_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2010: Setting Item Attribute TASK_NAME with '|| l_task_name);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_OWNER',
						    avalue   => l_escalate_owner2);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2020: Setting Item Attribute TASK_OWNER with '|| l_escalate_owner2);
                        END IF;

			WF_ENGINE.Setitemattrdate(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'DUE_DATE',
						  avalue   => l_planned_end_date);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2030: Setting Item Attribute DUE_DATE with '|| l_planned_end_date);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'ESCALATE_OWNER',
						    avalue   => NULL);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2040: Setting Item Attribute ESCALATE_OWNER with '|| NULL);
                        END IF;

			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DISPLAY_TASK_OWNER',
						    avalue   => l_owner_name);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2050: Setting Item Attribute DISPLAY_TASK_OWNER with '|| l_owner_name);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'TASK_ID',
						    avalue   => l_task_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2060: Setting Item Attribute TASK_ID with '|| l_task_id);
                        END IF;

			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'CONTRACT_ID',
						    avalue   => l_contract_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2070: Setting Item Attribute CONTRACT_ID with '|| l_contract_id);
                        END IF;

		--start the workflow
		WF_ENGINE.STARTPROCESS(l_item_type, l_item_key);

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('2080: started workflow process    .....');
                END IF;

--		commit;

		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
			                          g_api_version,
				                  p_api_version,
                                                  G_LEVEL,
                                                  g_return_status);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_ERROR;
  			END IF;

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('2090: before OKC_TASK_PUB.update_task   .....');
                        END IF;

		--Update alarm fired count, workflow_process_id in the tasks table
		OKC_TASK_PUB.update_task(p_api_version	          => g_api_version,
					 p_object_version_number  => l_object_version_number,
					 p_init_msg_list	  => p_init_msg_list,
				         p_task_id                => l_task_id,
					 p_task_number	          => l_task_number,
					 p_workflow_process_id	  => l_item_key,
					 p_alarm_fired_count      => 2,
					 x_return_status          => g_return_status,
					 x_msg_count		  => g_msg_count,
					 x_msg_data               => g_msg_data);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.log('3000: after OKC_TASK_PUB.update_task return_status is '|| g_return_status);
                        END IF;

		IF (g_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        l_failure_count := l_failure_count + 1;
                        rollback to task_alert_pvt;
       			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     		ELSIF (g_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        l_failure_count := l_failure_count + 1;
                        rollback to task_alert_pvt;
       			raise OKC_API.G_EXCEPTION_ERROR;
		ELSIF (g_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                        l_success_count := l_success_count + 1;
			commit;
     		END IF;
	   END IF;
	EXCEPTION
	  	WHEN OKC_API.G_EXCEPTION_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Exception Error in task_alert is '||g_msg_data);

     		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Unexcepted Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);
                get_fnd_msg_stack(' Unexpected error in task_alert is '||g_msg_data);

     		WHEN OTHERS THEN
                    IF (l_debug = 'Y') THEN
                       OKC_DEBUG.log(' 400:Other Exception Error in task_alert...', 2);
                       OKC_DEBUG.Reset_Indentation;
                    END IF;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_number);

  			retcode := 2;
                    FND_FILE.PUT_LINE( FND_FILE.LOG,substr(sqlerrm,1,250));
                exit;
              END;
	  END LOOP;
		OKC_API.END_ACTIVITY(g_msg_count, g_msg_data);

          IF (l_debug = 'Y') THEN
             OKC_DEBUG.log('4000: Exiting task_task_escalation2...', 2);
             OKC_DEBUG.Reset_Indentation;
          END IF;
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Success Count:'||l_success_count);
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Failure Count:'||l_failure_count);

	EXCEPTION
	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 4000:Exception Error in task_escalation2...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_name);
			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       		        g_return_status := OKC_API.HANDLE_EXCEPTIONS
       		        (l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Exception Error in task_escaltion2 is '||g_msg_data);

     	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 4000:Unexcepted Error in task_escalation2...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_name);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       		        g_return_status := OKC_API.HANDLE_EXCEPTIONS
       		        (l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_UNEXP_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Unexpected Error in task_escalation2 is '||g_msg_data);

     	WHEN OTHERS THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 4000:Other Exception Error in task_escalation2...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;
                FND_FILE.PUT_LINE( FND_FILE.LOG,'Task:'||l_task_name);

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
       		        g_return_status := OKC_API.HANDLE_EXCEPTIONS
       		        (l_api_name,
        		G_PKG_NAME,
        		'OTHERS',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Other Exception Error in task_escalation2 is '||g_msg_data);

     	END task_escalation2;

----------------------------------------------------------------------------------------------------
	-- Start of comments
  	-- Procedure Name  : okc_pdate_reach_pvt
  	-- Description     : This Procedure triggers the action assembler when the current
     --			      date equals planned end date reached in the tasks table
  	-- Version         : 1.0
  	-- End of comments
----------------------------------------------------------------------------------------------------

	PROCEDURE okc_pdate_reach_pvt(errbuf   		     OUT NOCOPY VARCHAR2,
		      	              retcode    	     OUT NOCOPY VARCHAR2,
		                      p_api_version	     IN NUMBER,
		                      p_init_msg_list        IN VARCHAR2) IS

		CURSOR planned_date_cur IS
		SELECT planned_end_date, source_object_id
		from jtf_tasks_b
		where source_object_type_code = 'OKC_RESTIME';

		l_return_status			VARCHAR2(3);
		l_planned_date 			jtf_tasks_b.planned_end_date%TYPE;
		l_source_object_id		jtf_tasks_b.source_object_id%TYPE;
		l_api_name              	CONSTANT VARCHAR2(30) := 'okc_pdate_reach_pvt';

	BEGIN

             IF (l_debug = 'Y') THEN
                OKC_DEBUG.set_indentation(l_api_name);
                OKC_DEBUG.log('5010: Entered okc_pdate_reach_pvt', 2);
             END IF;

		l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
						  g_api_version,
						  p_api_version,
                                                  G_LEVEL,
                                                  g_return_status);
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_ERROR;
  		END IF;

		--Initialize the return code
		retcode := 0;

	        --Check if the cursor is already open
	       IF  planned_date_cur%ISOPEN THEN
                   CLOSE planned_date_cur;
	       END IF;

	   	FOR planned_date_rec in planned_date_cur  LOOP

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('5020: In planned_date_rec LOOP .... ');
                END IF;

		l_planned_date     := planned_date_rec.planned_end_date;
		l_source_object_id := planned_date_rec.source_object_id;

                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log('5030: l_planned_date is       '||l_planned_date );
                   OKC_DEBUG.log('5040: l_source_object_id is   '||l_source_object_id );
                END IF;

		  --If current date equals planned date then call the action assembler
		  IF trunc(sysdate) = trunc(l_planned_date) THEN

                  IF (l_debug = 'Y') THEN
                     OKC_DEBUG.log('5050: Before Calling the action assembler .... ');
                  END IF;

		      OKC_SCHR_PD_ASMBLR_PVT.acn_assemble(
  				p_api_version	=> g_api_version,
  				p_init_msg_list => p_init_msg_list,
  				x_return_status => g_return_status,
  				x_msg_count     => g_msg_count,
  				x_msg_data      => g_msg_data,
  				p_rtv_id	=> l_source_object_id,
  				p_planned_date	=> l_planned_date);

                  IF (l_debug = 'Y') THEN
                     OKC_DEBUG.log('5060: After Calling the action assembler return_status is  '||g_return_status);
                  END IF;

			IF (g_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       				raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     			ELSIF (g_return_status = OKC_API.G_RET_STS_ERROR) THEN
       				raise OKC_API.G_EXCEPTION_ERROR;
			ELSIF (g_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
				commit;
     			END IF;
		  END IF;
	   	END LOOP;

          IF (l_debug = 'Y') THEN
             OKC_DEBUG.log('6000: Exiting okc_pdate_reach_pvt...', 2);
             OKC_DEBUG.Reset_Indentation;
          END IF;

	EXCEPTION
	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 6000:Exception Error in okc_pdate_reach_pvt...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
        		g_return_status := OKC_API.HANDLE_EXCEPTIONS
        		(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Exception Error in okc_pdate_reach_pvt is '||g_msg_data);

     	 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 6000:Unexcepted Error in okc_pdate_reach_pvt...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
        		g_return_status := OKC_API.HANDLE_EXCEPTIONS
        		(l_api_name,
        		G_PKG_NAME,
        		'OKC_API.G_RET_STS_UNEXP_ERROR',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Unexpected Error in okc_pdate_reach_pvt is '||g_msg_data);

     	WHEN OTHERS THEN
                IF (l_debug = 'Y') THEN
                   OKC_DEBUG.log(' 6000:Other Exception Error in okc_pdate_reach_pvt...', 2);
                   OKC_DEBUG.Reset_Indentation;
                END IF;

			retcode := 2;
  			errbuf := substr(sqlerrm,1,250);
        		g_return_status := OKC_API.HANDLE_EXCEPTIONS
        		(l_api_name,
        		G_PKG_NAME,
        		'OTHERS',
        		g_msg_count,
        		g_msg_data,
        		G_LEVEL);

                get_fnd_msg_stack(' Other Exception Error in okc_pdate_reach_pvt is '||g_msg_data);

	END okc_pdate_reach_pvt;
END OKC_TASK_ALERT_ESCL_PVT;

/
