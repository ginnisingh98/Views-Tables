--------------------------------------------------------
--  DDL for Package Body AS_SALES_METH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_METH_WF" AS
/* $Header: asxsmtwb.pls 115.38 2003/12/22 13:22:00 sumahali ship $ */
g_pkg_name varchar2(100);
g_notes  varchar2(4000);

x_task_details_tbl		jtf_task_inst_templates_pub.task_details_tbl;
------------------------------------------------------------------------------------------
----------------------------- Private Portion --------------------------------------------
------------------------------------------------------------------------------------------
-- We use the following private utility procedures
--
------------------------------------------------------------------------------------------
PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
);
PROCEDURE Print_Message
(
     p_error_msg      IN  VARCHAR2
);
-- Utility procedure to get the last error message
PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY  VARCHAR2
) ;
--
-- Start of comments
--    API name   : Add_Error_Message
--    Type       : Private
--
PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
) IS
BEGIN
    -- To Be Developed.
    PRINT_MESSAGE('p_api_name = ' || p_api_name);
    PRINT_MESSAGE('p_error_msg = ' || p_error_msg);
END Add_Error_Message;
PROCEDURE Print_Message
(
     p_error_msg      IN  VARCHAR2
) IS
BEGIN
NULL;
     -- Uncomment the line below for debug messages.
     --dbms_output.put_line('p_debug_msg = ' || p_error_msg);
END Print_Message;
PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY  VARCHAR2
) IS
l_count NUMBER := 0;
l_msg_index_out NUMBER := 0;
j NUMBER;
BEGIN
   x_msg_data := NULL;
   l_count := FND_MSG_PUB.Count_Msg;
   IF l_count > 0 THEN
      FND_MSG_PUB.Get(p_msg_index => l_count,
	                  p_encoded => FND_API.G_FALSE,
					  p_data => x_msg_data,
					  p_msg_index_out => l_msg_index_out);
   END IF;
END Get_Error_Message;
--------------------------------------------------------------------------------------------
/*
 * This procedure needs to be called with an itemtype and workflow process
which'll launch workflow .Start Methodology will call workflow based on Meth_flag in methodology base table*/
PROCEDURE start_methodology (p_source_object_type_code 	IN 	VARCHAR2,
			     p_source_object_id  	IN 	NUMBER,
			     p_source_object_name 	IN 	VARCHAR2,
			     p_owner_id  		IN 	NUMBER,
			     p_owner_type_code 		IN 	VARCHAR2,
			     p_object_type_code 	IN 	VARCHAR2,
			     p_current_stage_id 	IN 	NUMBER,
			     p_next_stage_id 		IN 	NUMBER,
			     p_template_group_id 	IN 	VARCHAR2,
			     item_type 			IN 	VARCHAR2,
			     workflow_process 		IN 	VARCHAR2,
			     x_return_status 		OUT NOCOPY 	VARCHAR2 ,
			     x_msg_count		OUT NOCOPY	NUMBER,
			     x_msg_data			OUT NOCOPY 	VARCHAR2,
                             x_warning_message          OUT NOCOPY     VARCHAR2 ) IS
				l_template_group_id		NUMBER;
				l_sales_stage_id		NUMBER;
			        l_methodology_id 		NUMBER;
				l_count			NUMBER;
			        l_meth_flag		VARCHAR2(10);
			     CURSOR c_profile IS
				SELECT b.profile_option_value
				FROM fnd_profile_options a, fnd_profile_option_values b
				WHERE a.profile_option_id = b.profile_option_id
			     	AND a.profile_option_name = 'AS_SM_CREATE_TASKS'
				AND b.application_id =279;
			     CURSOR c_resource IS
				SELECT decode(category,'EMPLOYEE','RS_EMPLOYEE','PARTNER','RS_PARTNER','PARTY','RS_PARTY')
				FROM jtf_rs_resource_extns
				WHERE resource_id = p_owner_id ;
			     CURSOR c_meth IS
				SELECT b.autocreatetask_flag,b.sales_methodology_id
				FROM as_leads_all a,as_sales_methodology_b b
				WHERE a.lead_id = p_source_object_id
				AND   a.sales_methodology_id = b.sales_methodology_id;
			    CURSOR c_stage IS
				SELECT a.sales_stage_id,task_template_group_id
				FROM as_sales_meth_stage_map a
 				WHERE a.sales_methodology_id= l_methodology_id
                                ORDER BY stage_sequence;
			    CURSOR c_task IS
				SELECT count(a.task_id) FROM as_sales_meth_task_map a
	 			WHERE a.object_type_code = p_source_object_type_code
	 			AND a.object_id = p_source_object_id
	 			AND a.sales_stage_id = l_sales_stage_id
				AND a.sales_methodology_id = l_methodology_id;
			     l_profile_value 		VARCHAR2(50);
			     l_result 			VARCHAR2(10);
			     itemtype 			VARCHAR2(10) ;
			     itemkey 			VARCHAR2(30);
			     workflowprocess 		VARCHAR2(30);
			     test 			VARCHAR2(100);
			     l_error_msg 		VARCHAR2(2000);
			     l_return_status 		VARCHAR2(20);
			     l_msg_count 		NUMBER;
			     l_msg_data 		VARCHAR2(2000);
			     l_api_name 		VARCHAR2(100) := 'AS_SALES_METH_WF';
			     l_category			VARCHAR2(100);
BEGIN
			--------------------------------------------------------
			IF p_template_group_id IS NULL	THEN
				l_error_msg:='Template group id must not be null';
				fnd_message.set_name('AS','AS_INVALID_TEMPLATE_ID');
			        fnd_msg_pub.add;
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			IF p_owner_id IS NULL  THEN
				l_error_msg:='Owner id must not be null';
				fnd_message.set_name('AS','AS_INVALID_OWNER_ID');
			        fnd_msg_pub.add;
			        RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			/*IF p_owner_type_code IS NULL THEN
				l_error_msg:='Owner Type Code must not be null';
				fnd_msg_pub.add_exc_msg('AS_SALES_METH','START_METHODOLOGY',l_error_msg);
			        fnd_msg_pub.add;
			       	RAISE fnd_api.g_exc_unexpected_error;
			END IF;*/
			IF p_source_object_id IS NULL  THEN
				l_error_msg:='Source Object id must not be null';
				fnd_message.set_name('AS','AS_INVALID_OBJECT_ID');
			        fnd_msg_pub.add;
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			IF p_source_object_type_code IS NULL THEN
				l_error_msg:='Source object type code  must not be null';
				PRINT_MESSAGE('p_error_msg = ' || l_error_msg);
				fnd_message.set_name('AS','AS_INVALID_OBJECT_TYPE');
			        fnd_msg_pub.add;
			        RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			IF p_source_object_name IS NULL THEN
				l_error_msg:='Source object name  must not be null';
				PRINT_MESSAGE('p_error_msg = ' || l_error_msg);
				fnd_message.set_name('AS','AS_INVALID_OBJECT_NAME');
			        fnd_msg_pub.add;
			        RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			/*IF p_current_stage_id IS NULL THEN
				l_error_msg:='Current Stage id  must not be null';
				print_message('p_error_msg = ' || l_error_msg);
				fnd_msg_pub.add_exc_msg('AS_SALES_METH','START_METHODOLOGY',l_error_msg);
			        fnd_msg_pub.add;
			        RAISE fnd_api.g_exc_unexpected_error;
			END IF;*/
			IF p_next_stage_id IS NULL THEN
				l_error_msg:='Next Stage id  must not be null';
				print_message('p_error_msg = ' || l_error_msg);
				fnd_message.set_name('AS','AS_INVALID_NEXT_STAGE');
			        fnd_msg_pub.add;
			        RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			----------------------------------------------------------
			OPEN c_profile;
				FETCH c_profile INTO l_profile_value;
					IF 	(c_profile%NOTFOUND) THEN
						CLOSE c_profile;
						l_error_msg:='Required Profile not found';
						PRINT_MESSAGE('p_error_msg = ' || l_error_msg);
						fnd_message.set_name('AS','AS_PROFILE_NOT_FOUND');
			        		fnd_msg_pub.add;
			        		RAISE fnd_api.g_exc_unexpected_error;
					END IF;
			CLOSE c_profile;
	IF 	l_profile_value = 'Y' THEN
		--------------------------------
		OPEN c_resource;
			FETCH  c_resource INTO l_category;
			PRINT_MESSAGE('category:'||l_category);
				IF 	(c_resource%NOTFOUND ) THEN
					CLOSE c_resource;
					l_error_msg := 'Category for resource  not found in jtf_rs_resource_extns table';
					PRINT_MESSAGE('p_error_msg = ' || l_error_msg);
					fnd_message.set_name('AS','AS_INVALID_RESOURCE');
			        	fnd_msg_pub.add;
			        	RAISE fnd_api.g_exc_unexpected_error;
			       END IF;
		CLOSE c_resource;
		-------------------------------
		workflowprocess :=workflow_process;
		itemtype := item_type;
		print_message(test);
   		SELECT TO_CHAR(AS_SALES_METHODOLOGY_WF_S.NEXTVAL) INTO itemkey FROM dual;
		IF 	(itemtype IS NOT NULL) AND (itemkey IS NOT NULL) THEN
			wf_engine.createprocess	(	itemtype => itemtype,
							itemkey  => itemkey,
							process  => workflowprocess);
			wf_engine.setitemattrnumber(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'OWNER_ID',
			          			avalue   => 	p_owner_id);
			wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'OWNER_TYPE_CODE',
			          			avalue   => 	l_category);
   			wf_engine.setitemattrnumber(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'SOURCE_OBJECT_ID',
			          			avalue   => 	p_source_object_id);
			wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'SOURCE_OBJECT_TYPE_CODE',
			          			avalue   => 	p_source_object_type_code);
  			wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'SOURCE_OBJECT_NAME',
			          			avalue   => 	p_source_object_name);
			wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'OBJECT_TYPE_CODE',
			          			avalue   => 	p_object_type_code);
   			wf_engine.setitemattrnumber(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'CURRENT_STAGE_ID',
			          			avalue   => 	p_current_stage_id);
  			wf_engine.setitemattrnumber(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'NEXT_STAGE_ID',
			          			avalue   => 	p_next_stage_id);
  			wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  			itemkey  => 	itemkey,
				  			aname    => 	'TASK_TEMPLATE_GROUP_ID',
			          			avalue   => 	p_template_group_id);
			--------------------------------------------------------------
		OPEN c_meth;
		LOOP
		print_message('Inside meth cursor loop');
			FETCH c_meth INTO l_meth_flag,l_methodology_id;
			print_message('Inside  methodology id'||l_methodology_id);
			EXIT WHEN c_meth%NOTFOUND;
			IF 	l_meth_flag = 'Y' THEN
			print_message('Meth flag'||l_meth_flag);
					OPEN c_stage;
					LOOP
					  FETCH c_stage INTO l_sales_stage_id,l_template_group_id;
					  EXIT WHEN c_stage%NOTFOUND;
						OPEN c_task;
						LOOP
							FETCH 	c_task INTO l_count;
							EXIT WHEN c_task%NOTFOUND;
							print_message('Inside Task cursor loop =='||l_count);
								IF 	l_count >= 1 THEN
									print_message('Inside task count>=1');
									x_return_status := 'S' ;
								ELSE
									PRINT_MESSAGE('sales stage id in count=='||l_sales_stage_id);
									PRINT_MESSAGE('Task template group id in count=='||l_template_group_id);
									wf_engine.setitemattrnumber(	itemtype =>	itemtype,
				  									itemkey  => 	itemkey,
				  									aname    => 	'NEXT_STAGE_ID',
			          									avalue   => 	l_sales_stage_id);
  									wf_engine.setitemattrtext(	itemtype =>	itemtype,
				  									itemkey  => 	itemkey,
				  									aname    => 	'TASK_TEMPLATE_GROUP_ID',
			          									avalue   => 	l_template_group_id);
									print_message('Inside task count<1');
									wf_engine.startprocess(		itemtype => 	itemtype,
													itemkey  => 	itemkey);
									wf_engine.ItemStatus      (	itemtype => 	ItemType,
	      		   										itemkey	 => 	ItemKey,
	      		   										status   => 	l_return_status,
	      		   										result   => 	l_result);
									print_message('Result after workflow=in count else='||l_result);
									IF 		l_result = 'SUCCESS'  AND l_return_status ='COMPLETE' THEN
											x_return_status := 'S' ;
									ELSE
											x_return_status := 'F';
									END IF ;
								END IF;
						 END LOOP;
						CLOSE c_task;
					END LOOP;
					CLOSE c_stage;
			ELSE
			----------------------------------------------------------
			print_message('Meth flag is not equal to yes');
			wf_engine.startprocess(		itemtype => 	itemtype,
							itemkey  => 	itemkey);
			wf_engine.ItemStatus      (	itemtype => 	ItemType,
	      		   				itemkey	 => 	ItemKey,
	      		   				status   => 	l_return_status,
	      		   				result   => 	l_result);
			IF 		l_result = 'SUCCESS'  AND l_return_status ='COMPLETE' THEN
					x_return_status := 'S' ;
			ELSE
					x_return_status := 'F';
			END IF ;
		END IF;
		END LOOP;
		CLOSE c_meth;
		ELSE
			l_error_msg:='Item Type OR Item Key IS not null';
			fnd_message.set_name('AS','AS_INVALID_ITEMTYPE');
			fnd_msg_pub.add;
			RAISE fnd_api.g_exc_unexpected_error;
  			x_return_status := 'U';
		END IF;
			---------------------------------------------------------------
	ELSE
		l_error_msg:='Invalid Profile value';
		PRINT_MESSAGE('p_error_msg = ' || l_error_msg);
		fnd_message.set_name('AS','AS_INVALID_PROFILE');
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_unexpected_error;
  		x_return_status := 'U';
	END IF;
        x_warning_message := wf_engine.getitemattrtext(		itemtype   =>	itemtype,
				  					itemkey   => 	itemkey,
				  					aname     => 	'WARNING_MESSAGE');

		print_message(' Item Status->'||' '||x_return_status||'item status result->'||' '||l_result);
EXCEPTION
----------------------------------
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
	   Get_Error_Message(l_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       --ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_ERROR;
       Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
	   Get_Error_Message(l_msg_data);
    WHEN OTHERS THEN
      --ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       Add_Error_Message (l_api_name, SQLERRM);
	   IF FND_MSG_PUB.Check_Msg_Level
	       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	      FND_MSG_PUB.Add_Exc_Msg
		   (G_PKG_NAME, l_api_name,sqlerrm);
	   END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
	   Get_Error_Message(l_msg_data);
----------------------------------
END start_methodology;
/**************************************************************************
 *  PROCEDURE: 		check_task_for_current
 *  DESCRIPTION:	This procedure checks for any mandatory tasks for current stage
 *
 *                      It returns 'N' if no tasks exist
 *			Otherwise 'it returns 'Y'
 *
 **********************************************************************/
PROCEDURE check_task_for_current (	itemtype		IN 	VARCHAR2,
		  			itemkey 		IN 	VARCHAR2,
					actid 			IN 	NUMBER,
					funcmode		IN 	VARCHAR2,
					result 	       		OUT NOCOPY 	VARCHAR2 ) IS
					l_return_status 		VARCHAR2(10);
					l_source_object_type_code 	VARCHAR2(100) ;
					l_source_object_name 		VARCHAR2(100);
					l_source_object_id 		NUMBER;
					l_object_type_code 		VARCHAR2(100) ;
					l_object_id 			NUMBER ;
					l_task_id 			NUMBER;
					l_task_name 			VARCHAR2(100);
					l_task_number 			NUMBER;
					l_meth_note_type 		VARCHAR2(100);
					n 				NUMBER :=0;
					CURSOR c_current_stage IS SELECT a.task_id FROM jtf_tasks_b a,as_sales_meth_task_map b,
                                        jtf_task_statuses_b c
	 				WHERE a.task_id = b.task_id
	 				AND a.source_object_type_code = l_source_object_type_code
	 				AND a.source_object_id = l_source_object_id
					AND b.sales_stage_id = l_object_id
 					AND a.task_status_id = c.task_status_id
 					AND a.restrict_closure_flag ='Y'
                                        AND (c.closed_flag IS NULL OR c.closed_flag <> 'Y');
 					c_current_stage_rec c_current_stage%ROWTYPE;
BEGIN
     	 			-- initializing return status
       				l_return_status := 'U';
				print_message('current func mode'||funcmode);
	IF 	funcmode = 'RUN' THEN
				l_source_object_type_code := wf_engine.getitemattrtext(itemtype   =>	itemtype,
				  							itemkey   => 	itemkey,
				  							aname     => 'SOURCE_OBJECT_TYPE_CODE');
        			l_source_object_id	  := wf_engine.getitemattrnumber(itemtype =>	itemtype,
				  							 itemkey  => 	itemkey,
				  							 aname    => 	'SOURCE_OBJECT_ID');
       				l_source_object_name	  := wf_engine.getitemattrtext  (itemtype =>	itemtype,
				  							 itemkey  => 	itemkey,
				  							 aname    => 	'SOURCE_OBJECT_NAME');
				l_object_type_code	  := wf_engine.getitemattrtext  (itemtype =>	itemtype,
				  							 itemkey  => 	itemkey,
				  							 aname    => 	'OBJECT_TYPE_CODE');
				l_object_id		  := wf_engine.getitemattrnumber(itemtype =>	itemtype,
				  							 itemkey  => 	itemkey,
				  							 aname    => 	'CURRENT_STAGE_ID');
				print_message('--------------------------------------------------');
				print_message('SOURCE_OBJECT_CODE ='||l_source_object_type_code);
				print_message('SOURCE_OBJECT_ID ='||l_source_object_id);
				print_message('SOURCE_OBJECT_NAME ='||l_source_object_name);
				print_message('OBJECT_TYPE_CODE ='||l_object_type_code);
				print_message('CURRENT_STAGE_ID ='||l_object_id);
 			FOR c_current_stage_rec IN 	c_current_stage
 				LOOP
					n := n+1;
					g_task_tab(n) := c_current_stage_rec.task_id;
 					l_return_status:='Y';
 					-- create note comes here
 				END LOOP;
 					l_meth_note_type := 'CURRENT_STAGE';
 					wf_engine.setitemattrtext	(	itemtype =>	itemtype,
					  					itemkey  => 	itemkey,
					  					aname    => 	'METH_NOTE_TYPE',
			          						avalue   => 	l_meth_note_type);
 				IF 	l_return_status ='Y' THEN
 					result:='COMPLETE:Y';
 				ELSE
 					result:='COMPLETE:N';
 				END IF;
 					print_message('result after current stage = ' ||result);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		wf_core.context('SAL_MET3','Check Mandatory for Current',itemtype, itemkey, to_char(actid), funcmode);
	RAISE;
END Check_task_for_current;
/**************************************************************************
 *  PROCEDURE: 		check_task_for_next
 *  DESCRIPTION:	This procedure checks for any tasks created for next stage
 *
 *                      It returns 'N' if no tasks exist
 *			Otherwise  it returns 'Y'
 *
 **********************************************************************/
PROCEDURE check_task_exist_for_next  (	itemtype	IN 	VARCHAR2,
		  			itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) IS
					l_source_object_type_code 	VARCHAR2(100) ;
					l_source_object_id 		NUMBER ;
					l_source_object_name 		VARCHAR2(100);
					l_object_type_code 		VARCHAR2(100) ;
					l_object_id 			NUMBER;
					l_meth_note_type 		VARCHAR2(100);
					l_task_id 			NUMBER;
					l_task_name 			VARCHAR2(100);
					l_task_number 			NUMBER;
					l_name 				VARCHAR2(10);
					l_return_status 		VARCHAR2(10);
					l_long_task_id 			VARCHAR2(4000);
					n 				NUMBER:= 0;
					CURSOR c_next_stage IS SELECT a.task_id FROM as_sales_meth_task_map a
	 				WHERE a.object_type_code = l_source_object_type_code
	 				AND a.object_id = l_source_object_id
	 				AND a.sales_stage_id = l_object_id ;
 					c_next_stage_rec c_next_stage%ROWTYPE;
BEGIN
					l_return_status:='U';
 IF 		funcmode = 'RUN' THEN
        	l_source_object_type_code := wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'SOURCE_OBJECT_TYPE_CODE');
        	l_source_object_id:= wf_engine.getitemattrnumber(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'SOURCE_OBJECT_ID');
		l_source_object_name:= wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'SOURCE_OBJECT_NAME');
		l_object_type_code:= wf_engine.getitemattrtext(		itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'OBJECT_TYPE_CODE');
		l_object_id:=wf_engine.getitemattrnumber(		itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'NEXT_STAGE_ID');
			print_message('NEXT_STAGE_ID= '||l_object_id);
  		FOR c_next_stage_rec IN	c_next_stage
  		LOOP
			print_message('Task id in next stage = '||c_next_stage_rec.task_id);
			n := n+1;
			g_task_tab(n) := c_next_stage_rec.task_id;
  			l_return_status:='Y';
  		END LOOP;
  			l_meth_note_type := 'NEXT_STAGE';
  			wf_engine.setitemattrtext(			itemtype =>	itemtype,
						  			itemkey  => 	itemkey,
						  			aname    => 	'METH_NOTE_TYPE',
			          					avalue   => 	l_meth_note_type);
  		IF 	l_return_status = 'Y' AND nvl(fnd_profile.value('AS_SM_RECREATE_TASKS'), 'N') <>  'Y' THEN
  			result:='COMPLETE:Y';
  		ELSE
  	  		result:='COMPLETE:N';
  			print_message('result after next stage = ' ||result);
		END IF;
		g_task_tab:=empty_tbl;
END IF;
EXCEPTION
	WHEN OTHERS THEN
		wf_core.context('SAL_MET3','Check task exist for next',itemtype, itemkey, to_char(actid), funcmode);
	RAISE;
END Check_task_exist_for_next;
/**************************************************************************
 *  PROCEDURE: 		create_tasks
 *  DESCRIPTION:	This procedure create tasks from templates and creates            *	references for those tasks.
 *
 *                      It returns 'SUCCESS' if tasks are successfully 				created  Otherwise  it returns 'FAIL'
 **********************************************************************/
PROCEDURE  create_tasks (		itemtype  IN 	VARCHAR2,
				     	itemkey   IN 	VARCHAR2,
				     	actid     IN 	NUMBER,
				     	funcmode  IN 	VARCHAR2,
				     	result    OUT NOCOPY 	VARCHAR2)	IS
					l_meth_note_type 			VARCHAR2(100);
					l_return_status 			VARCHAR2(100);
					l_ref_status				VARCHAR2(100);
					l_task_name 				VARCHAR2(10);
					l_task_id 				NUMBER;
					l_task_template_id  			NUMBER;
     					l_task_template_group_id            	NUMBER   ;
     					l_task_template_group_name          	VARCHAR2(100)     := NULL;
					l_sales_methodology_id			NUMBER;
					l_owner_id                          	NUMBER ;
     					l_owner_type_code                   	VARCHAR2(100) ;
					l_object_name 				VARCHAR2(100);
					l_object_type_code 			VARCHAR2(50);
     					l_source_object_type_code           	VARCHAR2(30) ;
     					l_source_object_id                  	NUMBER ;
     					l_source_object_name                	VARCHAR2(240) ;
     					l_workflow_process_id    		VARCHAR2(100);
					l_msg_count 				NUMBER;
					l_msg_data 				VARCHAR2(4000);
					l_object_id 				NUMBER;
					j 					NUMBER;
					l_msg_index_out 			NUMBER;
					l_error_msg 				VARCHAR2(4000);
					l_api_name 				VARCHAR2(2000);
					table_row				NUMBER;
					l_taask_id 				NUMBER;
					CURSOR c_Methodology IS
						SELECT sales_methodology_id from as_leads_all a
						WHERE a.lead_id = l_source_object_id;
					CURSOR c_task IS
						SELECT template_id,template_group_id
						FROM JTF_TASKS_B where task_id = l_taask_id;

-- Added for bug 2596419 start

CURSOR c_customer_info (c_lead_id NUMBER) IS
	select customer_id, address_id
	from as_leads_all
	where lead_id = c_lead_id;

CURSOR c_primary_address(c_customer_id NUMBER) IS
	select party_site_id
	from hz_party_sites
	where party_id = c_customer_id
	and identifying_address_flag = 'Y';

CURSOR c_task_templates(c_task_template_group_id NUMBER) IS
	select task_template_id
	from jtf_task_templates_b
	where task_group_id = c_task_template_group_id;

CURSOR c_contact_points ( c_customer_id NUMBER) IS
	select contact_point_id
	from hz_contact_points
	where owner_table_name = 'HZ_PARTIES'
	and owner_table_id = c_customer_id
	and status = 'A'
	and primary_flag = 'Y'
	-- and contact_point_type in ('EMAIL', 'PHONE');
	and contact_point_type = 'PHONE';


l_task_template_group_info	jtf_task_inst_templates_pub.task_template_group_info;
l_task_templates_tbl 		jtf_task_inst_templates_pub.task_template_info_tbl;
l_task_contact_points_tbl 	jtf_task_inst_templates_pub.task_contact_points_tbl;


l_customer_id	NUMBER;
l_address_id 	NUMBER;

K		NUMBER := 1;

-- Added for bug 2596419 end

BEGIN
			l_return_status := 'U';
  	IF 	funcmode = 'RUN' THEN
		l_source_object_type_code := 	wf_engine.getitemattrtext(	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'SOURCE_OBJECT_TYPE_CODE');
		print_message('current source type code = '||l_source_object_type_code);
		l_source_object_id	:= 	wf_engine.getitemattrnumber(	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'SOURCE_OBJECT_ID');
		l_object_type_code      := 	wf_engine.getitemattrtext(	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'OBJECT_TYPE_CODE');
		l_object_id		:=wf_engine.getitemattrnumber    (	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'NEXT_STAGE_ID');
		l_source_object_name	:= wf_engine.getitemattrtext	(	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'SOURCE_OBJECT_NAME');
		l_task_template_group_id:=wf_engine.getitemattrtext	(	itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname   	=> 	'TASK_TEMPLATE_GROUP_ID');
		l_owner_type_code 	:= wf_engine.getitemattrtext(		itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'OWNER_TYPE_CODE');
		l_owner_id 		:= wf_engine.getitemattrnumber(		itemtype 	=>	itemtype,
				  						itemkey  	=> 	itemkey,
				  						aname    	=> 	'OWNER_ID');
			print_message('OWNER_ID = '||l_owner_id);
			print_message('OWNER_TYPE_CODE = '||l_owner_type_code);
				print_message('about to   create tasks from templates');
			SAVEPOINT AS_CREATE_TASK;
-------------------------------------------


-- XDING Change for bug 2596491 start
-- Call jtf_task_inst_templates_pub.create_task_from_template instead of
-- jtf_tasks_pub.create_task_from_template to create tasks with
-- opportunity customer context and primary contact points

	IF l_source_object_id IS NULL  THEN
	    l_error_msg:='Source Object id must not be null';
	    fnd_message.set_name('AS','AS_INVALID_OBJECT_ID');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	OPEN c_customer_info(l_source_object_id);
	FETCH c_customer_info INTO l_customer_id, l_address_id;
	CLOSE c_customer_info;

	IF l_address_id IS NULL THEN
	    OPEN c_primary_address (l_customer_id);
	    FETCH c_primary_address INTO l_address_id;
	    CLOSE c_primary_address;
	END IF;

      	l_task_template_group_info.task_template_group_id := l_task_template_group_id;
      	l_task_template_group_info.owner_type_code := l_owner_type_code;
      	l_task_template_group_info.owner_id := l_owner_id;
      	l_task_template_group_info.source_object_id := l_source_object_id;
      	l_task_template_group_info.source_object_name := l_source_object_name;
      	-- l_task_template_group_info.cust_account_id :=
      	l_task_template_group_info.customer_id := l_customer_id;
      	l_task_template_group_info.address_id := l_address_id;
        l_task_template_group_info.date_selected := 'P';
        l_task_template_group_info.show_on_calendar := 'Y';

	FOR cntrec IN c_contact_points(l_customer_id) LOOP
	    FOR temprec IN c_task_templates (l_task_template_group_id) LOOP
      		l_task_contact_points_tbl(K).task_template_id := temprec.task_template_id;
      		l_task_contact_points_tbl(K).phone_id := cntrec.contact_point_id;
      		l_task_contact_points_tbl(K).primary_key := 'Y';
		K := K + 1;
	    END LOOP;
	END LOOP;

	jtf_task_inst_templates_pub.create_task_from_template (
      		p_api_version 			=> 1.0,
      		p_init_msg_list 		=> fnd_api.g_false,
      		p_commit 			=> fnd_api.g_false,
      		p_task_template_group_info 	=> l_task_template_group_info,
      		p_task_templates_tbl 		=> l_task_templates_tbl,
      		p_task_contact_points_tbl 	=> l_task_contact_points_tbl,
      		x_return_status 		=> l_return_status,
      		x_msg_count 			=> l_msg_count,
      		x_msg_data 			=> l_msg_data,
      		x_task_details_tbl 		=> x_task_details_tbl
   	);



/*
 		jtf_tasks_pub.create_task_from_template (       p_api_version            	=>   	1.0,
        							p_init_msg_list          	=>   	fnd_api.g_false,
        							p_commit                 	=>   	fnd_api.g_false,
        							p_task_template_group_id 	=>   	l_task_template_group_id,
        							p_task_template_group_name 	=> 	l_task_template_group_name,
        							p_owner_type_code       	=>    	l_owner_type_code,
        							p_owner_id              	=>    	l_owner_id,
        							p_source_object_id      	=>    	l_source_object_id,
        							p_source_object_name    	=>    	l_source_object_name,
        							p_planned_start_date		=>	sysdate,
        							p_planned_end_date		=>	sysdate,
        							x_return_status         	=>    	l_return_status,
        							x_msg_count             	=>    	l_msg_count,
        							x_msg_data              	=>    	l_msg_data,
        							x_task_details_tbl      	=>    	g_task_details_tbl   );

*/

-- Change for bug 2596491 end


				print_message('status after tasks from templates = ' ||l_return_status);
	IF l_return_status = 'S' THEN
	---------------------------
					OPEN c_methodology;
						FETCH 	c_methodology INTO l_sales_methodology_id;
						--dbms_output.put_line('Methodology_id = '||l_sales_methodology_id);
						IF 	(c_methodology %NOTFOUND) THEN
							g_notes:= fnd_message.get_string('AS','AS_INVALID_METH');
                                                        wf_engine.setitemattrtext(	itemtype =>	itemtype,
					                                                itemkey  => 	itemkey,
				 	                                                aname    => 	'WARNING_MESSAGE',
			          	                                                avalue   => 	g_notes);
							l_error_msg:='Methodology not found for lead_id';
							l_return_status:='U';
						END IF;
					CLOSE c_methodology;
	---------------------------
   		FOR 		table_row IN 1..x_task_details_tbl.count
   			LOOP
				l_taask_id :=x_task_details_tbl(table_row).task_id;
------------------------------------------------------
				OPEN c_task;
					FETCH 	c_task INTO l_task_template_id,l_task_template_group_id;
						IF 	(c_task %NOTFOUND) THEN
							CLOSE c_task;
							--------------
							g_notes:=fnd_message.get_string('AS','AS_INVALID_TEMPLATE_DTL');
                                                        wf_engine.setitemattrtext(      itemtype =>     itemtype,
                                                                                        itemkey  =>     itemkey,
                                                                                        aname    =>     'WARNING_MESSAGE',
                                                                                        avalue   =>     g_notes);
							l_error_msg:='Template and Template group are not found for Task_id';
							l_return_status:='U';
							EXIT;
							--------------
						END IF;
				CLOSE c_task;
--------------------------------------------------
					AS_SALES_METH_TASK_MAP_PVT.CREATE_SALES_METH_TASK_MAP (	P_API_VERSION             	=>	1.0,
  												P_INIT_MSG_LIST           	=>  	fnd_api.g_false,
  												P_COMMIT                  	=>  	fnd_api.g_false,
  												P_VALIDATE_LEVEL          	=>  	fnd_api.g_valid_level_full,
 												P_SALES_STAGE_ID  	    	=>  	l_object_id,
 												P_SALES_METHODOLOGY_ID    	=>  	l_sales_methodology_id,
 												P_SOURCE_OBJECT_ID        	=>  	l_source_object_id,
												P_SOURCE_OBJECT_TYPE_CODE	=>	l_source_object_type_code,
												P_SOURCE_OBJECT_NAME		=>	l_source_object_name,
  												P_TASK_ID              		=>  	l_taask_id,
  												P_TASK_TEMPLATE_ID            	=>	l_task_template_id,
												p_task_template_group_id	=>	l_task_template_group_id,
  												X_RETURN_STATUS           	=>  	l_ref_status,
  												X_MSG_COUNT               	=>  	l_msg_count,
  												X_MSG_DATA                	=>  	l_msg_data 	);
---------------------------------------------------
							print_message('Return status= '||l_ref_status);
				IF 	(FND_MSG_PUB.count_msg >0) THEN
					FOR j IN 1..FND_MSG_PUB.Count_msg
					LOOP
							fnd_msg_pub.get ( 	p_msg_index  		=> 	j,
						  	  			p_encoded    		=> 	'F',
						 	  			p_data 	  	=> 	l_msg_data,
						  	  			p_msg_index_out 	=> 	l_msg_index_out);
										print_message(l_msg_data);
					END LOOP;
				END IF;
				IF 	l_ref_status = 'S' THEN
					NULL;
				ELSE
					g_notes:=fnd_message.get_string('AS','AS_CREATE_TASK_MAP_FAIL');
					g_notes:=g_notes||l_msg_data;
                                        wf_engine.setitemattrtext(      itemtype =>     itemtype,
                                                                                        itemkey  =>     itemkey,
                                                                                        aname    =>     'WARNING_MESSAGE',
                                                                                        avalue   =>     g_notes);
					--g_notes:='Create map api in AS_SALES_METH_WF.CREATE_TASK failed with the following error **** '||l_msg_data;
					l_return_status:='U';
					EXIT;
				END IF;
   			END LOOP;
---------------------------------------------------
	ELSE
          		l_return_status := 'U';
			ROLLBACK TO AS_CREATE_TASK;
			 IF      (FND_MSG_PUB.count_msg >0) THEN
                                        FOR j IN 1..FND_MSG_PUB.Count_msg
                                        LOOP
                                                        fnd_msg_pub.get (       p_msg_index             =>      j,
                                                                                p_encoded               =>      'F',
                                                                                p_data          =>      l_msg_data,
                                                                                p_msg_index_out         =>      l_msg_index_out);
                                                                                print_message(l_msg_data);
                                        END LOOP;
                          END IF;
			g_notes:=fnd_message.get_string('AS','AS_CREATE_TASK_FAIL');
			g_notes:=g_notes||l_msg_data;
                        wf_engine.setitemattrtext(      itemtype =>     itemtype,
                                                                                        itemkey  =>     itemkey,
                                                                                        aname    =>     'WARNING_MESSAGE',
                                                                                        avalue   =>     g_notes);
	END IF ;
				l_meth_note_type := 'CREATE_TASKS';
				wf_engine.setitemattrtext(	itemtype =>	itemtype,
								itemkey  => 	itemkey,
								aname    => 	'METH_NOTE_TYPE',
			          				avalue   => 	l_meth_note_type);
      				IF 		l_return_status = 'S' 	THEN
      						print_message('Create task from template done');
      						result :='COMPLETE:SUCCESS';
      				ELSE
      						result := 'COMPLETE:FAIL';
      				END IF;
END IF;
EXCEPTION
			WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      			 	l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 		  	Add_Error_Message (l_api_name, l_Error_Msg);
      			 	FND_MSG_PUB.count_and_get(	p_encoded => FND_API.g_false,
            							p_count   => l_msg_count,
           		 					p_data    => l_msg_data );
	   		 	Get_Error_Message(l_msg_data);
        		WHEN OTHERS THEN
        			wf_core.context('SAL_MET3','Create task from template',itemtype,itemkey,to_char(actid),funcmode);
        		RAISE;
END create_tasks;
-------------------------------------
/**************************************************************************
 *  PROCEDURE: 		check_duration
 *  DESCRIPTION:	This procedure checks duration
 *
 *
 **********************************************************************/
PROCEDURE  check_duration (		itemtype  IN 	varchar2,
				     	itemkey   IN 	VARCHAR2,
				     	actid     IN 	NUMBER,
				     	funcmode  IN 	VARCHAR2,
				     	result    OUT NOCOPY 	VARCHAR2)IS
			table_row 				NUMBER;
			l_task_details_tbl  			jtf_tasks_pub.task_details_tbl;
			l_end_hours 				NUMBER;
			l_start_hours				NUMBER;
			l_start_minutes				NUMBER;
			l_planned_end_date 			DATE;
			l_planned_start_date			DATE;
			l_duration 				NUMBER;
			l_duration_uom 				VARCHAR2(100);
			l_current_task_id 			NUMBER;
			l_end_date				NUMBER;
			l_update_status				VARCHAR2(100);
			l_msg_data 				VARCHAR2(4000);
			l_msg_count 				NUMBER;
			l_msg_index_out				NUMBER;
			l_return_status				VARCHAR2(10);
			l_meth_note_type			VARCHAR2(100);
			l_notes_flag				VARCHAR2(10):=NULL;
			CURSOR c_tasks IS
				SELECT duration,duration_uom,object_version_number,task_id,description,planned_start_date
				FROM jtf_tasks_vl
				WHERE task_id = l_current_task_id;
			c_tasks_rec c_tasks%ROWTYPE;
BEGIN
			l_notes_flag:='NO';
			--l_return_status := 'U';
  	IF funcmode = 'RUN' THEN
		FOR 		table_row IN 1..x_task_details_tbl.count
   			LOOP
					----------------------
					l_current_task_id := x_task_details_tbl(table_row).task_id;
					----------------------
				OPEN c_tasks;
						fetch c_tasks into c_tasks_rec;
						IF 	(c_tasks%NOTFOUND) THEN
							CLOSE c_tasks;
						END IF;
						l_duration := c_tasks_rec.duration;
						l_duration_uom :=c_tasks_rec.duration_uom;
						print_message('duration='||l_duration||' '||'duration_uom='||l_duration_uom);
					IF 	l_duration IS NOT NULL AND l_duration_uom IS NOT NULL THEN
		   				IF	l_duration_uom = 'DAY' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
    							l_planned_end_date:= SYSDATE+l_duration;
    						ELSIF 	l_duration_uom = 'WK' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
    							l_planned_end_date := SYSDATE+(7*l_duration);
    						ELSIF 	l_duration_uom='HR' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
    							l_planned_end_date :=SYSDATE+(l_duration/24);
     						ELSIF 	l_duration_uom='MIN' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
    							l_planned_end_date :=SYSDATE+(l_duration/1440);
    						ELSIF 	l_duration_uom = 'MTH' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
    							l_planned_end_date:= ADD_MONTHS(SYSDATE,l_duration);
						ELSIF   l_duration_uom = 'YR' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
							l_planned_end_date := ADD_MONTHS(SYSDATE, (l_duration*12));
						ELSIF	l_duration_uom = 'CN' AND ABS(l_duration) >0 THEN
							l_notes_flag:='NO';
							l_planned_end_date:=ADD_MONTHS(SYSDATE, (l_duration*100*12));
						ELSE
							l_planned_end_date :=SYSDATE;
							l_notes_flag:='YES';
    						END IF;
					ELSIF   l_duration IS NULL AND l_duration_uom IS NOT NULL THEN
						l_notes_flag:='YES';
						l_planned_end_date :=SYSDATE;
					ELSIF	l_duration IS NOT NULL AND l_duration_uom IS NULL THEN
						l_notes_flag:='YES';
						l_planned_end_date :=SYSDATE;
					ELSE
						--l_notes_flag:='YES';
						l_planned_end_date :=SYSDATE;
					END IF;
			---------------------------------
					l_planned_start_date:=SYSDATE;
					--l_planned_end_date :=SYSDATE;
					l_start_minutes:=TO_NUMBER(floor(to_char(l_planned_start_date,'mi')/15)*15) ;
					l_start_hours:=TO_NUMBER(TO_CHAR(l_planned_start_date,'hh24'));
					l_planned_start_date:=TRUNC(l_planned_start_date)+(l_start_hours/24)+(l_start_minutes/1440);
					l_end_date:=FLOOR(TO_CHAR(l_planned_end_date,'mi')/15)*15 ;
					l_end_hours:=TO_NUMBER(TO_CHAR(l_planned_end_date,'hh24'));
					l_planned_end_date:=TRUNC(l_planned_end_date)+(l_end_hours/24)+(l_end_date/1440);
					print_message('modified end date'||to_char(l_planned_end_date,'dd-mon-yyyy hh24:mi'));
					print_message('modified start date'||to_char(l_planned_start_date,'dd-mon-yyyy hh24:mi'));
			---------------------------------
			--------------------Update api------------------------------------
					JTF_TASKS_PUB.update_task (
        					p_api_version             => 1.0,
        					p_object_version_number   => c_tasks_rec.object_version_number,
        					p_task_id                 => c_tasks_rec.task_id,
        					p_description             => c_tasks_rec.description,
        					p_planned_start_date      => l_planned_start_date,
        					p_planned_end_date        => l_planned_end_date,
        					x_return_status 	  =>  l_update_status,
        					x_msg_count 		  =>  l_msg_count ,
        					x_msg_data 		  =>  l_msg_data );
					print_message('status after update task api='||l_update_status);
					IF 	l_update_status = 'S'  AND l_notes_flag ='NO'THEN
			   			l_return_status:='S';
					ELSIF	l_update_status = 'S' AND l_notes_flag ='YES' THEN
						l_return_status := 'U';
						l_meth_note_type := 'CHECK_DURATION';
						wf_engine.setitemattrtext(	itemtype =>	itemtype,
										itemkey  => 	itemkey,
										aname    => 	'METH_NOTE_TYPE',
			          						avalue   => 	l_meth_note_type);
						g_notes:= fnd_message.get_string('AS','AS_INVALID_DURATION');
                                                wf_engine.setitemattrtext(      itemtype =>     itemtype,
                                                                                        itemkey  =>     itemkey,
                                                                                        aname    =>     'WARNING_MESSAGE',
                                                                                        avalue   =>     g_notes);
					ELSE
						g_notes:=fnd_message.get_string('AS','AS_DURATION_UPDATE_FAIL');
                                                wf_engine.setitemattrtext(      itemtype =>     itemtype,
                                                                                        itemkey  =>     itemkey,
                                                                                        aname    =>     'WARNING_MESSAGE',
                                                                                        avalue   =>     g_notes);
						l_return_status :='U';
						l_meth_note_type := 'CHECK_DURATION';
						wf_engine.setitemattrtext(	itemtype =>	itemtype,
										itemkey  => 	itemkey,
										aname    => 	'METH_NOTE_TYPE',
			          						avalue   => 	l_meth_note_type);
					END IF;
			-----------------------------
				CLOSE c_tasks;
		END LOOP;
				print_message('return status = ' ||l_return_status);
			-----------------------------------------------------
				IF 	l_return_status = 'S' THEN
							result :='COMPLETE:SUCCESS';
					--dbms_output.put_line('in check duration'||result);
      				ELSE
      						result := 'COMPLETE:FAIL';
					--dbms_output.put_line('in check duration'||result);
				END IF;
	END IF ;
EXCEPTION
	WHEN others THEN
		--
		wf_core.context('SAL_MET3','check duration',itemtype, itemkey, to_char(actid), funcmode);
	RAISE;
END check_duration;
PROCEDURE  create_note_for_duration (		itemtype  IN 	varchar2,
				     		itemkey   IN 	VARCHAR2,
				     		actid     IN 	NUMBER,
				     		funcmode  IN 	VARCHAR2,
				     		result    OUT NOCOPY 	VARCHAR2)IS
		l_meth_note_type 		VARCHAR2(100);
		l_api_version 			VARCHAR2(10) := 1.0;
 		l_return_status 		VARCHAR2(10);
 		l_note_id 			NUMBER;
 		l_context_tab 			jtf_notes_pub.jtf_note_contexts_tbl_type;
 		l_validation_level 		VARCHAR2(10);
 		l_msg_count 			NUMBER;
		l_msg_list 			VARCHAR2(10);
		l_msg_data 			VARCHAR2(4000);
		l_source_object_code 		VARCHAR2(100);
		l_source_object_id 		NUMBER;
		l_notes 			VARCHAR2(4000);
		l_long_task_id 			VARCHAR2(4000):= NULL;
		n 				NUMBER :=0;
		l_column 			VARCHAR2(10):=',';
		l_org_id			NUMBER;
BEGIN
		--l_return_status := 'U';
		l_org_id :=fnd_profile.value('ORG_ID');
  IF 		funcmode = 'RUN' THEN
		l_source_object_code := wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  						itemkey  => 	itemkey,
				  						aname    => 	'SOURCE_OBJECT_TYPE_CODE');
			print_message('current source type code=>'||l_source_object_code);
			l_source_object_id:= 	wf_engine.getitemattrnumber(	itemtype =>	itemtype,
				  						itemkey  => 	itemkey,
				  						aname    => 	'SOURCE_OBJECT_ID');
		l_meth_note_type := 	wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'METH_NOTE_TYPE');
		print_message('methodology note type = '||l_meth_note_type);
		IF 	l_meth_note_type = 'CHECK_DURATION' THEN
			jtf_notes_pub.Create_note  (  		p_parent_note_id       		=>    	NULL,
 								p_jtf_note_id                   =>      fnd_api.g_miss_num,
 								p_api_version          		=>      l_api_version,
 								p_init_msg_list                	=>      fnd_api.g_false,
 								p_commit                       	=>      fnd_api.g_false,
 								p_validation_level             	=>      fnd_api.g_valid_level_full,
 								x_return_status                	=>      l_return_status,
 								x_msg_count                    	=>      l_msg_count,
 								x_msg_data                     	=>      l_msg_data,
 								p_org_id                       	=>      l_org_id,
 								p_source_object_id             	=>      l_source_object_id,
 								p_source_object_code   		=>      l_source_object_code,
 								p_notes                        	=>    	g_notes ,
 								p_notes_detail         		=>      NULL,
 								p_note_status          		=>      'E',
 								p_entered_by           		=>      fnd_global.user_id,
 								p_entered_date                 	=>      sysdate,
 								x_jtf_note_id          		=>      l_note_id,
				 				p_last_update_date              =>      sysdate,
 								p_last_updated_by              	=>      fnd_global.user_id,
 								p_creation_date                 =>      sysdate,
 								p_created_by           		=>      fnd_global.user_id,
 								p_last_update_login            	=>      fnd_global.login_id,
 								p_context                      	=>      NULL,
 								p_note_type            		=>      'AS_SYSTEM',
 								p_jtf_note_contexts_tab 	=>       l_context_tab      );
			print_message('Create note for duration Completed with =  '||l_return_status);
			IF 	l_return_status ='S' then
				result:='COMPLETE:SUCCESS';
			ELSE
				result:='COMPLETE:SUCCESS';
			END IF;
		END IF;
			print_message('Note_id created  = '||l_note_id);
END IF;
EXCEPTION
	WHEN others THEN
		wf_core.context('SAL_MET3','Create Note for Duration',itemtype, itemkey, to_char(actid), funcmode);
	RAISE;
END create_note_for_duration;
/**************************************************************************
 *  PROCEDURE: 		create_note
 *  DESCRIPTION:	This procedure creates notes based on the previous node
		in the workflow.
 *
 *
 **********************************************************************/
PROCEDURE  create_note (		itemtype  IN 	varchar2,
				     	itemkey   IN 	VARCHAR2,
				     	actid     IN 	NUMBER,
				     	funcmode  IN 	VARCHAR2,
				     	result    OUT NOCOPY 	VARCHAR2)IS
					l_meth_note_type 		VARCHAR2(100);
 					l_api_version 			VARCHAR2(10) := 1.0;
 					l_return_status 		VARCHAR2(10);
 					l_note_id 			NUMBER;
 					l_context_tab 			jtf_notes_pub.jtf_note_contexts_tbl_type;
 					l_validation_level 		VARCHAR2(10);
 					l_msg_count 			NUMBER;
					l_msg_list 			VARCHAR2(10);
					l_msg_data 			VARCHAR2(4000);
					l_source_object_code 		VARCHAR2(100);
					l_source_object_id 		NUMBER;
					l_long_task_id 			VARCHAR2(4000):= NULL;
					n 				NUMBER :=0;
					l_column 			VARCHAR2(10):=',';
					l_sql				VARCHAR2(2000);
					TYPE c_task_name IS REF CURSOR;
					c_task_name_ref	c_task_name;
					l_long_task_name 		VARCHAR2(2000);
					l_task_name			VARCHAR2(2000);
					l_org_id			NUMBER;
	BEGIN
				l_return_status := 'S';
				l_org_id:= fnd_profile.value('ORG_ID');
  	IF 		funcmode = 'RUN' THEN
			l_source_object_code := wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  						itemkey  => 	itemkey,
				  						aname    => 	'SOURCE_OBJECT_TYPE_CODE');
			print_message('current source type code=>'||l_source_object_code);
			l_source_object_id:= 	wf_engine.getitemattrnumber(	itemtype =>	itemtype,
				  						itemkey  => 	itemkey,
				  						aname    => 	'SOURCE_OBJECT_ID');
			l_meth_note_type := 	wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  						itemkey  => 	itemkey,
				  						aname    => 	'METH_NOTE_TYPE');
							print_message('methodology note type = '||l_meth_note_type);
		IF 	l_meth_note_type = 'CURRENT_STAGE' THEN
				---------------------------------
			FOR 	n IN 1 .. g_task_tab.count
				LOOP
					IF 	l_long_task_id IS NULL THEN
  						l_long_task_id := g_task_tab(n);
					ELSE
   						l_long_task_id := l_long_task_id ||l_column||g_task_tab(n);
					END IF;
				END LOOP;
				---------------------------------
			l_sql:='SELECT task_name FROM jtf_tasks_vl WHERE task_id IN'||'('||l_long_task_id||')';
			OPEN c_task_name_ref FOR l_sql;
				LOOP
					FETCH 	c_task_name_ref INTO l_task_name;
						IF 	l_long_task_name IS NULL  THEN
							l_long_task_name:=l_task_name;
							l_task_name:= NULL;
						ELSE
							IF 	l_task_name IS NOT NULL THEN
								l_long_task_name := l_long_task_name||l_column||' '||l_task_name;
								l_task_name:= NULL;
							END IF;
						END IF;
					EXIT WHEN c_task_name_ref%NOTFOUND;
			 	END LOOP;
			CLOSE c_task_name_ref ;
					print_message ('task_names are = '||l_long_task_name);
					print_message ('task_ids are = '||l_long_task_id);
					------------------------
					g_notes := 'Mandatory Tasks for Previous Stage have not been Completed.Work flow will continue with the next Stage.  '||'*'||' '||l_long_task_name||' '||'*';
		END IF;
					jtf_notes_pub.Create_note  (  		p_parent_note_id       		=>    	NULL,
 										p_jtf_note_id                   =>      fnd_api.g_miss_num,
 										p_api_version          		=>      l_api_version,
 										p_init_msg_list                	=>      fnd_api.g_false,
 										p_commit                       	=>      fnd_api.g_false,
 										p_validation_level             	=>      fnd_api.g_valid_level_full,
 										x_return_status                	=>      l_return_status,
 										x_msg_count                    	=>      l_msg_count,
 										x_msg_data                     	=>      l_msg_data,
 										p_org_id                       	=>      l_org_id,
 										p_source_object_id             	=>      l_source_object_id,
 										p_source_object_code   		=>      l_source_object_code,
 										p_notes                        	=>    	g_notes ,
 										p_notes_detail         		=>      NULL,
 										p_note_status          		=>      'E',
 										p_entered_by           		=>      fnd_global.user_id,
 										p_entered_date                 	=>      sysdate,
 										x_jtf_note_id          		=>      l_note_id,
				 						p_last_update_date              =>      sysdate,
 										p_last_updated_by              	=>      fnd_global.user_id,
 										p_creation_date                 =>      sysdate,
 										p_created_by           		=>      fnd_global.user_id,
 										p_last_update_login            	=>      fnd_global.login_id,
 										p_context                      	=>      NULL,
 										p_note_type            		=>      'AS_SYSTEM',
 										p_jtf_note_contexts_tab 	=>       l_context_tab      );
										print_message('Create note Completed with  = '||l_return_status);
			print_message('Note_id created  = '||l_note_id);
			g_task_tab:=empty_tbl;
	END IF;
EXCEPTION
			WHEN OTHERS THEN
        			wf_core.context('SAL_MET3','Create note from ',itemtype,itemkey,to_char(actid),funcmode);
        		RAISE;
END create_note;
----------------------------------
PROCEDURE  create_note_for_tasks_failure (		itemtype  IN 	varchar2,
				     		itemkey   IN 	VARCHAR2,
				     		actid     IN 	NUMBER,
				     		funcmode  IN 	VARCHAR2,
				     		result    OUT NOCOPY 	VARCHAR2)IS
		l_meth_note_type 		VARCHAR2(100);
 		l_api_version 			VARCHAR2(10) := 1.0;
 		l_return_status 		VARCHAR2(10);
 		l_note_id 			NUMBER;
 		l_context_tab 			jtf_notes_pub.jtf_note_contexts_tbl_type;
 		l_validation_level 		VARCHAR2(10);
 		l_msg_count 			NUMBER;
		l_msg_list 			VARCHAR2(10);
		l_msg_data 			VARCHAR2(4000);
		l_source_object_code 		VARCHAR2(100);
		l_source_object_id 		NUMBER;
		l_notes 			VARCHAR2(4000);
		l_long_task_id 			VARCHAR2(4000):= NULL;
		n 				NUMBER :=0;
		l_column 			VARCHAR2(10):=',';
		l_org_id			NUMBER;
BEGIN
	l_return_status := 'U';
	l_org_id :=fnd_profile.value('ORG_ID');
  	IF 		funcmode = 'RUN' THEN
			l_source_object_code := wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'SOURCE_OBJECT_TYPE_CODE');
			print_message('current source type code=>'||l_source_object_code);
			l_source_object_id:= 	wf_engine.getitemattrnumber(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'SOURCE_OBJECT_ID');
			l_meth_note_type := 	wf_engine.getitemattrtext(	itemtype =>	itemtype,
				  					itemkey  => 	itemkey,
				  					aname    => 	'METH_NOTE_TYPE');
			print_message('methodology note type = '||l_meth_note_type);
		IF 	l_meth_note_type = 'CREATE_TASKS' THEN
				jtf_notes_pub.Create_note  (  		p_parent_note_id       		=>    	NULL,
 									p_jtf_note_id                   =>      fnd_api.g_miss_num,
 									p_api_version          		=>      l_api_version,
 									p_init_msg_list                	=>      fnd_api.g_false,
 									p_commit                       	=>      fnd_api.g_false,
 									p_validation_level             	=>      fnd_api.g_valid_level_full,
 									x_return_status                	=>      l_return_status,
 									x_msg_count                    	=>      l_msg_count,
 									x_msg_data                     	=>      l_msg_data,
 									p_org_id                       	=>      l_org_id,
 									p_source_object_id             	=>      l_source_object_id,
 									p_source_object_code   		=>      l_source_object_code,
 									p_notes                        	=>    	g_notes ,
 									p_notes_detail         		=>      NULL,
 									p_note_status          		=>      'E',
 									p_entered_by           		=>      fnd_global.user_id,
 									p_entered_date                 	=>      sysdate,
 									x_jtf_note_id          		=>      l_note_id,
				 					p_last_update_date              =>      sysdate,
 									p_last_updated_by              	=>      fnd_global.user_id,
 									p_creation_date                 =>      sysdate,
 									p_created_by           		=>      fnd_global.user_id,
 									p_last_update_login            	=>      fnd_global.login_id,
 									p_context                      	=>      NULL,
 									p_note_type            		=>      'AS_SYSTEM',
 									p_jtf_note_contexts_tab 	=>       l_context_tab      );
									print_message('Create note Completed with =  '||l_return_status);
		END IF;
				print_message('Note_id created  = '||l_note_id);
	END IF;
EXCEPTION
		WHEN OTHERS THEN
        		wf_core.context('SAL_MET3','Create note from ',itemtype,itemkey,to_char(actid),funcmode);
        	RAISE;
END create_note_for_tasks_failure;
END as_sales_meth_wf;

/
