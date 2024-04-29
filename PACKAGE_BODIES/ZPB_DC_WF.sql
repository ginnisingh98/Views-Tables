--------------------------------------------------------
--  DDL for Package Body ZPB_DC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DC_WF" as
/* $Header: ZPBDCWFB.pls 120.6 2007/12/04 14:34:27 mbhat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_DC_WF';
  TYPE template_list_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  template_list template_list_type;

  PROCEDURE generate_template (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_instance_id   number := 0;
	l_ac_id         number := 0;
	l_task_id       number := 0;
	l_req_id        number := 0;

	l_respapp_id    number := 0;
    l_user_id       number := 0;
	l_resp_id       number := 0;

	l_template_name zpb_dc_objects.template_name%TYPE;
	l_template_id     number;
	l_wait_for_review varchar2(1);
	l_owner           varchar2(30);
	l_issue_msg       fnd_new_messages.message_text%TYPE;

  BEGIN

    IF (funcmode = 'RUN') THEN
	   resultout :='COMPLETE:N';

	   -- Retrieve values from previous wf process
	   l_ac_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'ACID');
       l_task_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');
       l_instance_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'INSTANCEID');
	   l_resp_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'RESPID');
       l_user_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'OWNERID');
       l_respapp_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'RESPAPPID');

	   -- Issue encountered related
	   l_owner := fnd_global.user_name;

	   -- Get the short text from fnd messages
           FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_GEN_TEMP_ISSUE_MSG');
           l_issue_msg := FND_MESSAGE.GET;

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'EPBPERFORMER',
               avalue => l_owner);

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ISSUEMSG',
               avalue => l_issue_msg);

	   -- Run the CP
	   fnd_global.apps_initialize(l_user_id,l_resp_id,l_respapp_id);

	   -- Set attributes
	   SELECT value
	   INTO l_template_name
	   FROM zpb_task_parameters
	   WHERE task_id = l_task_id
	   AND name = 'TEMPLATE_NAME';

	   wf_engine.SetItemAttrText(
	          Itemtype => ItemType,
  	          Itemkey => ItemKey,
  	          aname => 'DC_TEMPLATE_NAME',
 	          avalue => l_template_name);

	   SELECT value
	   INTO l_wait_for_review
	   FROM zpb_task_parameters
	   WHERE task_id = l_task_id
	   AND name = 'TEMPLATE_WAIT_FOR_REVIEW';

	   wf_engine.SetItemAttrText(
	          Itemtype => ItemType,
  	          Itemkey => ItemKey,
  	          aname => 'DC_WAIT_FOR_REVIEW',
 	          avalue => l_wait_for_review);

	  resultout := 'COMPLETE:Y';
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN OTHERS THEN
      WF_CORE.CONTEXT('zpb_dc_wf.generate_template', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END generate_template;

  PROCEDURE get_review_option (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_wait_for_review varchar2(1);
	l_notify          zpb_task_parameters.value%TYPE;
	l_task_id         number;
	l_from_name       fnd_user.user_name%TYPE;
	l_user_id         number;
	l_template_name   zpb_dc_objects.template_name%TYPE;

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_wait_for_review := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_WAIT_FOR_REVIEW');

      l_task_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');

	  -- Populate the from field in the notification details page
	  SELECT fnd.user_name
	  INTO l_from_name
	  FROM	fnd_user fnd,zpb_dc_objects obj
	  WHERE fnd.user_id = obj.object_user_id
	  AND obj.generate_template_task_id = l_task_id
	  AND obj.object_type = 'M';

	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

	  SELECT value
	  INTO l_notify
  	  FROM zpb_task_parameters
      WHERE task_id = l_task_id
	  AND name = 'NOTIFICATION_RECIPIENT_TYPE';

	  IF (l_wait_for_review = 'Y') THEN
            -- 5301285 06-JUN-27 =============================================
            -- Will find and set shadow users if EPBPERFORMER is a single user
            zpb_wf_ntf.SHADOWS_FOR_EPBPERFORMER (itemtype => ItemType,
	                                     Itemkey => ItemKey,
	                                     actid  => 0,
	                                     funcmode   => 'EPBPERFORMER',
                                             resultout  =>  resultout);

	    resultout := 'COMPLETE:WAIT' ;
	  ELSIF (l_wait_for_review = 'N' AND l_notify <> 'NONE') THEN
	    resultout := 'COMPLETE:NOTIFY' ;
	  ELSIF (l_wait_for_review = 'N' AND l_notify = 'NONE') THEN
	    resultout := 'COMPLETE:PROCEED' ;
      END IF;

	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN OTHERS THEN
      WF_CORE.CONTEXT('zpb_dc_wf.get_review_option', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END get_review_option;


  PROCEDURE review_complete(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  )
  IS
    l_wait_for_review_flag varchar2(1);
	l_review_complete_flag varchar2(1);
	l_template_id          number;
	l_instance_id          number;
	l_task_id              number;
  BEGIN

    IF (funcmode = 'RUN') THEN
	  resultout :='COMPLETE:N';

      l_instance_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'INSTANCEID');
      l_task_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'TASKID');

	  /* Get the template id from objects table
	     instead of task parameters table */
	  SELECT template_id
	  INTO l_template_id
	  FROM zpb_dc_objects
	  WHERE ac_instance_id = l_instance_id
	  AND object_type = 'M'
	  AND generate_template_task_id = l_task_id;

	  wf_engine.SetItemAttrNumber(
	          Itemtype => ItemType,
  	          Itemkey => ItemKey,
  	          aname => 'DC_TEMPLATE_ID',
 	          avalue => l_template_id);

	  SELECT review_complete_flag
	  INTO l_review_complete_flag
	  FROM zpb_dc_objects
	  WHERE template_id = l_template_id
	  AND object_type = 'M';

	  IF l_review_complete_flag = 'Y' THEN
	    resultout :='COMPLETE:Y';
	  ELSE
        resultout :='COMPLETE:N';
	  END IF;

	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.review_complete', itemtype, itemkey, to_char(actid), funcmode);
      raise;

  END review_complete;


  PROCEDURE auto_distribute (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_instance_id      number := 0;
	l_task_id          number := 0;
	l_template_id      number := 0;
	l_ac_template_id   number := 0;
	l_req_id           number := 0;
	l_object_id        number;
	l_object_user_id   number;
	l_object_user_name fnd_user.description%TYPE;
	l_distribute_message zpb_task_parameters.value%TYPE;
	l_template_name    zpb_dc_objects.template_name%TYPE;
	l_prior_item_key   zpb_analysis_cycle_tasks.item_key%TYPE;
	l_issue_msg        fnd_new_messages.message_text%TYPE;

	l_respapp_id       number := 0;
    l_user_id          number := 0;
	l_resp_id          number := 0;

  BEGIN

    IF (funcmode = 'RUN') THEN
	   resultout :='COMPLETE:N';

       l_instance_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'INSTANCEID');

       l_task_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');

	   -- Issue encounter msg
           -- Get Message from Fnd_Messages
           FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_AUTO_DIST_ISSUE_MSG');
           l_issue_msg := FND_MESSAGE.GET;

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ISSUEMSG',
               avalue => l_issue_msg);

	   /* To find out the specific distributed template
	   for  multiple template cases */
	   SELECT value
	   INTO l_ac_template_id
       FROM zpb_task_parameters
       WHERE task_id = l_task_id
       AND name = 'DISTRIBUTION_TEMPLATE_ID';

	   SELECT template_id, template_name
	   INTO l_template_id, l_template_name
	   FROM zpb_dc_objects
	   WHERE ac_instance_id = l_instance_id
	   AND ac_template_id = l_ac_template_id
	   AND object_type = 'M';

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'DC_TEMPLATE_NAME',
			   avalue => l_template_name);

	   wf_engine.SetItemAttrNumber(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'DC_TEMPLATE_ID',
			   avalue => l_template_id);

	   -- Get the parameters for set the apps context
	   l_resp_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'RESPID');
       l_user_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'OWNERID');
       l_respapp_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'RESPAPPID');

	   -- Get the user name to populate dc distributors
	   SELECT nvl(fnd.description,fnd.user_name)
	   INTO l_object_user_name
	   FROM	fnd_user fnd, zpb_dc_objects obj
	   WHERE fnd.user_id = obj.object_user_id
	   AND obj.template_id = l_template_id
	   AND obj.object_type = 'M';

       wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'DC_DISTRIBUTOR',
			   avalue => l_object_user_name);

	   -- Get the distribute message to populate dc distribution message
	   SELECT value
	   INTO l_distribute_message
	   FROM zpb_task_parameters
	   WHERE task_id = l_task_id
	   AND name = 'DISTRIBUTION_MESSAGE';

       wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'DC_DISTRIBUTION_MESSAGE',
			   avalue => l_distribute_message);

	   -- Set the context and Run the CP
       fnd_global.apps_initialize(l_user_id,l_resp_id,l_respapp_id);

	  resultout := 'COMPLETE:Y';
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

    IF ( funcmode not in ('RUN','CANCEL') ) THEN
      resultout := '';
    END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.auto_distribute: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN OTHERS THEN
      WF_CORE.CONTEXT('zpb_dc_wf.auto_distribute', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END auto_distribute;

  PROCEDURE set_ws_recipient (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_task_id                 NUMBER;
	l_template_id             NUMBER;
	l_ac_template_id          NUMBER;
	l_instance_id             NUMBER;
	l_object_id               NUMBER;
	l_object_user_id          NUMBER;
    l_rolename                VARCHAR2(320);
	l_dist_list_id            NUMBER;
	l_recipient_type          VARCHAR2(30);
	l_owner                   VARCHAR2(30);
	l_process_name            fnd_new_messages.message_text%TYPE;
	l_from_name               fnd_user.user_name%TYPE;
	l_template_name           zpb_dc_objects.template_name%TYPE;

    l_api_version             NUMBER;
	l_init_msg_list           VARCHAR2(1);
	l_commit                  VARCHAR2(1);
	l_validation_level        NUMBER;
	l_return_status           VARCHAR2(1);
	l_msg_count               NUMBER;
	l_msg_data                VARCHAR2(4000);
    l_resultout               VARCHAR2(30);
  BEGIN

    l_api_version             := 1.0;
	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;
	l_owner                   := fnd_global.user_name;

    IF (funcmode = 'RUN') THEN
	   resultout :='COMPLETE:N';

	   -- Auto distribution parameters
       l_task_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');

	   l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_TEMPLATE_ID');

	   l_instance_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'INSTANCEID');

	   -- Manual distribution parameters
	   IF (l_task_id is null) THEN
	     l_dist_list_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_DIST_LIST_ID');
         l_recipient_type  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_RECIPIENT_TYPE');
         l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_OBJECT_ID');
		END IF;


	     -- set issue notifications related parameters
	     wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'EPBPERFORMER',
               avalue => l_owner);

	   /* To find out the FROM ROLE
	   for  multiple template cases */
	   IF (l_instance_id is not null and
	       l_task_id is not null) then   -- AUTO--
	     SELECT value
	     INTO l_ac_template_id
         FROM zpb_task_parameters
         WHERE task_id = l_task_id
         AND name = 'DISTRIBUTION_TEMPLATE_ID';

	     SELECT object_user_id
	     INTO l_object_user_id
	     FROM zpb_dc_objects
	     WHERE ac_instance_id = l_instance_id
	     AND ac_template_id = l_ac_template_id
	     AND object_type = 'M';
	   ELSE   -- Manual--
		 SELECT template_id, template_name
		 INTO l_template_id, l_template_name
		 FROM zpb_dc_objects
		 WHERE object_id = l_object_id;

	     SELECT object_user_id
	     INTO l_object_user_id
	     FROM zpb_dc_objects
	     WHERE template_id = l_template_id
	     AND object_type = 'M';

           -- Get Message from Fnd_Messages
           FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_MANU_DIST_ISSUE_MSG');
           l_process_name := FND_MESSAGE.GET;

	     wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'DC_PROCESS_NAME',
               avalue => l_process_name);

	     wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'DC_TEMPLATE_NAME',
               avalue => l_template_name);

	   END IF;

	   SELECT user_name
	   INTO l_from_name
	   FROM	fnd_user
	   WHERE user_id = l_object_user_id;

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

	   -- Find out distribution recipients
	   ZPB_DC_OBJECTS_PVT.Set_Ws_Recipient(
                     p_api_version       => l_api_version,
					 p_init_msg_list     => l_init_msg_list,
					 p_commit            => l_commit,
					 p_validation_level  => l_validation_level,
					 x_return_status     => l_return_status,
					 x_msg_count         => l_msg_count,
					 x_msg_data          => l_msg_data,
					 --
					 p_task_id           => l_task_id,
					 p_template_id       => l_template_id,
					 p_dist_list_id      => l_dist_list_id,
					 p_object_id         => l_object_id,
					 p_recipient_type    => l_recipient_type,
					 x_role_name         => l_rolename,
                     			 x_resultout         => l_resultout);

	   wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_DISTRIBUTE_RECIPIENT',
         	  avalue => l_rolename);

     	-- l_resultout from above call will be 'N' when role_name does not have any Users
      IF (l_resultout = 'COMPLETE:Y') THEN
          resultout := 'COMPLETE:Y';
      ELSE
          resultout := 'COMPLETE:F';
      END IF;
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:N';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_ws_recipient', itemtype, itemkey, to_char(actid), funcmode);
      resultout :='COMPLETE:N';
      raise;
  END set_ws_recipient;


  PROCEDURE raise_distribution_event(
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_validation_level          IN       NUMBER,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2,
    --
    p_object_id       IN number,
	p_recipient_type  IN varchar2,
	p_dist_list_id    IN number,
	p_approver_type   IN varchar2,
	p_deadline_date   IN varchar2,
	p_overwrite_cust  IN varchar2,
	p_overwrite_data  IN varchar2,
	p_distribution_message IN varchar2
  )
  IS

    l_api_name        CONSTANT VARCHAR2(30) := 'raise_distribution_event' ;
    l_api_version     CONSTANT NUMBER := 1.0 ;
    l_return_status   VARCHAR2(1);
    --
	l_deadline_date            DATE;
	l_template_name            zpb_dc_objects.template_name%TYPE;
	l_substr_templ_name        VARCHAR2(140);
	l_sequence                 NUMBER;
	l_distribute_type          VARCHAR2(30);
	l_char_date                VARCHAR2(30);
    --
    l_item_type                VARCHAR2(100) ;
    l_item_key                 VARCHAR2(240) ;
    l_event_t wf_event_t;
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
	--
  BEGIN

    SAVEPOINT Raise_Distribution_Event ;

    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    -- Initialize the parameters
    l_item_type  := 'ZPBDC' ;


	SELECT ZPB_DC_WF_PROCESSES_S.nextval
	INTO l_sequence
	FROM dual;

	SELECT template_name
	INTO l_template_name
	FROM zpb_dc_objects
	WHERE object_id = p_object_id;

	l_substr_templ_name := substr(l_template_name,1,140);
	l_distribute_type := 'Distribute Template';
	l_char_date := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
    l_item_key := to_char(l_sequence) ||
	              '_' || l_distribute_type||
	              '_' || l_substr_templ_name ||
	              '_' || l_char_date;

    FND_FILE.Put_Line ( FND_FILE.LOG, 'WF key ' || l_item_key ) ;

    wf_event.AddParameterToList(
	    p_name         => 'DC_OBJECT_ID',
        p_value        => p_object_id,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_RECIPIENT_TYPE',
        p_value        => p_recipient_type,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_DIST_LIST_ID',
        p_value        => p_dist_list_id,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_APPROVER_TYPE',
        p_value        => p_approver_type,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_DEADLINE_DATE',
        p_value        => p_deadline_date,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_OVERWRITE_CUST',
        p_value        => p_overwrite_cust,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_OVERWRITE_DATA',
        p_value        => p_overwrite_data,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_DISTRIBUTION_MESSAGE',
        p_value        => p_distribution_message,
        p_parameterlist=> l_parameter_list);

    -- set fnd values so workflow process can use this values
    -- since they can now be run in deferred mode

    wf_event.AddParameterToList(p_name=>'FND_USER_ID',
	   p_value=> fnd_global.user_id,
	   p_parameterlist=>l_parameter_list);


    wf_event.AddParameterToList(p_name=>'FND_APPLICATION_ID',
	   p_value=> fnd_global.resp_appl_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_RESPONSIBILITY_ID',
	   p_value=> fnd_global.resp_id,
	   p_parameterlist=>l_parameter_list);

    -- wf debugging
	wf_log_pkg.wf_debug_flag := TRUE;
    -- raise the event
    wf_event.raise(p_event_name => 'oracle.apps.zpb.dc.worksheet.distribute',
		 p_event_key => l_item_key,
		 p_parameters => l_parameter_list);

    l_parameter_list.delete;


    COMMIT;

    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data ) ;
    --
    EXCEPTION
    --
     when FND_API.G_EXC_ERROR then
     --
       rollback to Raise_Distribution_Event ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
       rollback to Raise_Distribution_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when OTHERS then
     --
       rollback to Raise_Distribution_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
       END if;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
       --


  END raise_distribution_event;

  PROCEDURE manual_distribute (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_object_id        number;
    l_recipient_type   varchar2(30);
    l_dist_list_id     number;
    l_approver_type    zpb_dc_objects.approver_type%TYPE;
    l_deadline_date_text    varchar2(30);
    l_overwrite_cust   varchar2(30);
    l_overwrite_data   varchar2(30);
	l_req_id           number;
	l_object_user_id   number;
	l_object_user_name fnd_user.description%TYPE;
	l_from_name        fnd_user.user_name%TYPE;
	l_message          varchar2(4000);

	l_user_id 	       number;
    l_resp_id          number;
    l_respapp_id       number;

  BEGIN
    l_object_id        := 0;
    l_dist_list_id     := 0;
	l_req_id           := 0;
	l_user_id 	       := fnd_global.USER_ID;
    l_resp_id          := fnd_global.RESP_ID;
    l_respapp_id       := fnd_global.RESP_APPL_ID;

    IF (funcmode = 'RUN') THEN
	   resultout :='COMPLETE:N';

       l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_OBJECT_ID');

       l_dist_list_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_DIST_LIST_ID');


       l_recipient_type  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_RECIPIENT_TYPE');

       l_approver_type  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_APPROVER_TYPE');
	   IF (l_approver_type = '' OR l_approver_type is null) THEN
	     l_approver_type := 'DISTRIBUTOR';
	   END IF;

	   l_deadline_date_text  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_DEADLINE_DATE');

       l_overwrite_cust  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_OVERWRITE_CUST');

       l_overwrite_data  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_OVERWRITE_DATA');

       l_user_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_USER_ID');

       l_resp_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_RESPONSIBILITY_ID');

       l_respapp_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_APPLICATION_ID');

	   -- Get the object user id to populate dc distributors
	   SELECT nvl(fnd.description,fnd.user_name)
	   INTO l_object_user_name
	   FROM	fnd_user fnd,zpb_dc_objects obj
	   WHERE fnd.user_id = obj.object_user_id
	   AND obj.object_id = l_object_id;

       wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'DC_DISTRIBUTOR',
			   avalue => l_object_user_name);

	   /* Populate the from field in the notification details page
	      This name should be user name from the fnd table */
	   SELECT fnd.user_name
	   INTO l_from_name
	   FROM	fnd_user fnd,zpb_dc_objects obj
	   WHERE fnd.user_id = obj.object_user_id
	   AND obj.object_id = l_object_id;

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

           -- Get Message from Fnd_Messages
           FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_DISTRIBUTE_ISSUE_MSG');
           l_message := FND_MESSAGE.GET;

       wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'ISSUEMSG',
			   avalue => l_message);


	   -- Run the CP
	   fnd_global.apps_initialize(l_user_id,l_resp_id,l_respapp_id);

	   l_req_id := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
	               'ZPB_DC_MANUAL_DISTRIBUTE', NULL, NULL, FALSE,
				   l_object_id,l_recipient_type,l_dist_list_id,
                   l_approver_type,l_deadline_date_text,l_overwrite_cust,
                   l_overwrite_data);

       -- Set the values for ntf
       wf_engine.SetItemAttrNumber(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'REQUEST_ID',
			   avalue => l_req_id);

	  IF l_req_id = 0 THEN
	    resultout := 'COMPLETE:N';
	  ELSE
	    resultout := 'COMPLETE:Y';
	  END IF;
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.manual_distribute: no data found', itemtype, itemkey, to_char(actid), funcmode);
      resultout :='COMPLETE:N';
      raise;

    WHEN OTHERS THEN
      WF_CORE.CONTEXT('zpb_dc_wf.manual_distribute', itemtype, itemkey, to_char(actid), funcmode);
      resultout :='COMPLETE:N';
      raise;
  END manual_distribute;

  PROCEDURE get_template_count (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
 	l_task_id               NUMBER ;
    l_count                 NUMBER ;
	l_instance_id           NUMBER ;
	l_ac_template_id        NUMBER ;
	l_object_user_id        NUMBER ;
	l_from_name             fnd_user.user_name%TYPE;
  BEGIN

 	l_task_id               := 0;
    l_count                 := 0;
	l_instance_id           := 0;
	l_ac_template_id        := 0;
	l_object_user_id        := 0;

    IF (funcmode = 'RUN') THEN
	  resultout :='COMPLETE:N';

      l_task_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'TASKID');

      FOR template_id_rec IN (
	     SELECT obj.template_id
	     FROM zpb_task_parameters param,
		      zpb_dc_objects obj
	     WHERE param.task_id = l_task_id
	     AND param.name = 'SUBMISSION_TEMPLATE_ID'
		 AND to_number(param.value) = obj.ac_template_id
		 AND obj.status <> 'SUBMITTED_TO_SHARED'
		 AND obj.object_type = 'M' -- consistently choose M record
      )
	  LOOP
	    l_count := l_count + 1;
	    template_list(l_count) :=  template_id_rec.template_id;
	  END LOOP;

	  wf_engine.SetItemAttrText(
		   Itemtype => ItemType,
           Itemkey => ItemKey,
 	       aname => 'DC_SUBMIT_LOOP_COUNTER',
           avalue => l_count);

	  wf_engine.SetItemAttrText(
		   Itemtype => ItemType,
           Itemkey => ItemKey,
 	       aname => 'DC_LOOP_VISITED_COUNTER',
           avalue => 0);

	  -- Populate the from field in the notification details page
      l_instance_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'INSTANCEID');

	  /* To find out any (of the many) template(s)
	  for  multiple template cases */
	  SELECT min(value)
	  INTO l_ac_template_id
      FROM zpb_task_parameters
      WHERE task_id = l_task_id
      AND name = 'SUBMISSION_TEMPLATE_ID';

	  SELECT object_user_id
	  INTO l_object_user_id
	  FROM zpb_dc_objects
	  WHERE ac_instance_id = l_instance_id
	  AND ac_template_id = l_ac_template_id
	  AND object_type = 'M';

	  SELECT user_name
	  INTO l_from_name
	  FROM	fnd_user
	  WHERE user_id = l_object_user_id;

	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

      resultout := 'COMPLETE:Y';
    END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
	END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.get_template_count', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END get_template_count;

  PROCEDURE manage_submission (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_template_id            NUMBER ;
	l_ws_count               NUMBER ;
	l_ws_status_count        NUMBER ;
	l_loop_visited_counter   NUMBER ;
	l_distribution_method    zpb_dc_objects.distribution_method%TYPE;
      l_approval_required_flag zpb_dc_objects.approval_required_flag%TYPE;
      l_multiple_submissions_flag zpb_dc_objects.multiple_submissions_flag%TYPE;

  BEGIN
	l_template_id           := 0;
	l_ws_count              := 0;
	l_ws_status_count       := 0;
	l_loop_visited_counter  := 0;

    IF (funcmode = 'RUN') THEN

	  --------------------------------------
	  -- Get the right template to process -
	  --------------------------------------

      l_loop_visited_counter  :=  wf_engine.GetItemAttrNumber
			  (  itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'DC_LOOP_VISITED_COUNTER');
	  l_loop_visited_counter := l_loop_visited_counter + 1;

	  l_template_id := template_list(l_loop_visited_counter);

	  wf_engine.SetItemAttrNumber( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'DC_LOOP_VISITED_COUNTER',
			       avalue   => l_loop_visited_counter );


      wf_engine.SetItemAttrNumber( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'DC_TEMPLATE_ID',
			       avalue   => l_template_id );
       --
          FND_FILE.Put_Line ( FND_FILE.LOG, 'manage_submission -  l_template_id=' || l_template_id ) ;
	  --------------------------------------
	  --          Processing              --
	  --------------------------------------
	  -- Check whether distribution happened --
	  SELECT count(*)
	  INTO l_ws_count
	  FROM zpb_dc_objects
	  WHERE template_id = l_template_id
	  AND object_type = 'W';
	  FND_FILE.Put_Line ( FND_FILE.LOG, 'manage_submission -  l_ws_count=' || l_ws_count ) ;

	  -- Get the necessary info for processing --
	  FOR worksheet_rec IN (
	      SELECT distribution_method,
                 approval_required_flag,
		     multiple_submissions_flag
          FROM zpb_dc_objects
          WHERE template_id = l_template_id
	      AND object_type = 'M' )
	  LOOP
	    l_distribution_method := worksheet_rec.distribution_method;
	    l_approval_required_flag := worksheet_rec.approval_required_flag;
	    l_multiple_submissions_flag := worksheet_rec.multiple_submissions_flag;

	  END LOOP;
	  IF (l_ws_count = 0) THEN -- template not distributed yet--
	    resultout := 'COMPLETE:WAIT';
	  ELSE
	    IF (l_distribution_method = 'DIRECT_DISTRIBUTION' AND
	        l_approval_required_flag = 'N' AND
		  l_multiple_submissions_flag <>'Y') THEN
		  SELECT count(*)
		  INTO l_ws_status_count
		  FROM zpb_dc_objects, fnd_user
		  WHERE object_user_id = user_id
		  AND template_id = l_template_id
		  AND object_type = 'W'
		  AND status NOT IN ('SUBMITTED_TO_SHARED')
		  AND (end_date is null OR end_date > sysdate);
		FND_FILE.Put_Line ( FND_FILE.LOG, 'manage_submission -  l_ws_status_count=' || l_ws_status_count ) ;

	      IF (l_ws_status_count = 0) THEN
	        resultout := 'COMPLETE:UPDATE_STATUS';
		  ELSE
	        resultout := 'COMPLETE:WAIT';
		  END IF;
	    ELSE -- Direct with appr and Cascade, wait for BPO to submit --
	      resultout := 'COMPLETE:WAIT';
		END IF;
	  END IF;
	END IF;
	IF ( funcmode = 'CANCEL' ) THEN
	  resultout := 'COMPLETE:WAIT';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
	return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.manage_submission: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN OTHERS THEN
      WF_CORE.CONTEXT('zpb_dc_wf.manage_submission', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END manage_submission;

  PROCEDURE set_template_recipient (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_rolename                VARCHAR2(320);
	l_template_id             NUMBER;

    l_api_version    CONSTANT NUMBER := 1.0;
	l_init_msg_list           VARCHAR2(1);
	l_commit                  VARCHAR2(1);
	l_validation_level        NUMBER;
	l_return_status           VARCHAR2(1);
	l_msg_count               NUMBER;
	l_msg_data                VARCHAR2(4000);
  BEGIN

	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;

    IF (funcmode = 'RUN') THEN
      l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'DC_TEMPLATE_ID');

	  ZPB_DC_OBJECTS_PVT.Set_Template_Recipient(
                     p_api_version       => l_api_version,
					 p_init_msg_list     => l_init_msg_list,
					 p_commit            => l_commit,
					 p_validation_level  => l_validation_level,
					 x_return_status     => l_return_status,
					 x_msg_count         => l_msg_count,
					 x_msg_data          => l_msg_data,
					 --
					 p_template_id       => l_template_id,
					 x_role_name         => l_rolename);

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_TEMPLATE_RECIPIENT',
         	  avalue => l_rolename);

      resultout := 'COMPLETE';
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

    IF ( funcmode not in ('RUN','CANCEL') ) THEN
      resultout := '';
    END IF;
    return;

    EXCEPTION

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_template_recipient', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END set_template_recipient;

  PROCEDURE set_template_status (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
 	l_template_id           NUMBER;
  BEGIN

 	l_template_id := 0;
    IF (funcmode = 'RUN') THEN

      l_template_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'DC_TEMPLATE_ID');

	  UPDATE zpb_dc_objects
	  SET status = 'SUBMITTED_TO_SHARED',
	      freeze_flag = 'Y',
		  LAST_UPDATED_BY =  fnd_global.USER_ID,
		  LAST_UPDATE_DATE = SYSDATE,
		  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	  WHERE template_id = l_template_id
	  AND object_type in ('M','E','C');

      resultout := 'COMPLETE';
    END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_template_status: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_template_status', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END set_template_status;

  PROCEDURE check_template_status (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_count           NUMBER;
	l_task_id         NUMBER;
    l_instance_id     NUMBER;
  BEGIN

    IF ( funcmode = 'RUN' ) THEN
	  resultout :='COMPLETE:N';

      l_task_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'TASKID');
      l_instance_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
		      Itemkey => ItemKey,
	  	      aname => 'INSTANCEID');

	  SELECT count(*)
	  INTO l_count
	  FROM zpb_task_parameters param,
		   zpb_dc_objects obj
	  WHERE param.task_id = l_task_id
	  AND param.name = 'SUBMISSION_TEMPLATE_ID'
      AND to_number(param.value) = obj.ac_template_id
	  AND obj.status <> 'SUBMITTED_TO_SHARED'
          AND obj.ac_instance_id = l_instance_id
	  AND obj.object_type = 'M'; -- consistently choose M record

	  IF (l_count = 0) THEN
	    resultout :='COMPLETE:N';
	  ELSE
	    resultout :='COMPLETE:Y';
	  END IF;

	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION
    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.wait_to_process', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END check_template_status;

  PROCEDURE raise_submission_event(
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_validation_level          IN       NUMBER,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2,
    --
    p_object_id                 IN number,
	p_submission_message        IN varchar2
  )
  IS

    l_api_name             CONSTANT VARCHAR2(30) := 'raise_submission_event' ;
    l_api_version          CONSTANT NUMBER := 1.0 ;
    l_return_status        VARCHAR2(1);
	--
	l_template_id          NUMBER;
	l_distributor_id       NUMBER;
	l_bpo_id               NUMBER;
	l_approver_id          NUMBER;
	l_template_name        zpb_dc_objects.template_name%TYPE;
	l_substr_templ_name    VARCHAR2(140);
	l_object_type          zpb_dc_objects.object_type%TYPE;
	l_distribution_method  zpb_dc_objects.distribution_method%TYPE;
	l_object_user_id       NUMBER;
	l_char_date            VARCHAR2(30);
	l_sequence             NUMBER;
	l_submit_type          VARCHAR2(30);
	l_multiple_submissions_flag VARCHAR2(1);
	l_approval_required_flag VARCHAR2(1);
    --
    l_item_type            VARCHAR2(100);
    l_item_key             VARCHAR2(240) ;
    l_event_t              wf_event_t;
    l_parameter_list       wf_parameter_list_t := wf_parameter_list_t();
	--
  BEGIN

    SAVEPOINT Raise_Submission_Event ;

    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

	-- Initialize the parameters
    l_item_type   := 'ZPBDC' ;

	-- Get infor from the submitting user
	SELECT template_id,
	       object_type,
		   template_name,
		   object_user_id,
		   distributor_user_id,
		   distribution_method,
		   multiple_submissions_flag,
		   approval_required_flag
	INTO l_template_id,
	     l_object_type,
		 l_template_name,
		 l_object_user_id,
		 l_distributor_id,
		 l_distribution_method,
		 l_multiple_submissions_flag,
		 l_approval_required_flag
	FROM zpb_dc_objects
	WHERE object_id = p_object_id;

	SELECT object_user_id
    INTO l_bpo_id
    FROM zpb_dc_objects
    WHERE template_id = l_template_id
    AND object_type = 'M';

	-- Set the approver user id
	IF (l_distribution_method = 'DIRECT_DISTRIBUTION') THEN
      l_approver_id := l_bpo_id;
    ELSE
      IF (l_distributor_id  <> -100) THEN
        l_approver_id := l_distributor_id;
      ELSE
	    l_approver_id := l_bpo_id;
      END IF;
    END IF;

	-- Set the status to SUBMITTTED to prevent updating
	IF (l_object_type = 'E') THEN
	  UPDATE zpb_dc_objects
	  SET status = 'SUBMITTED',
	      submission_date = sysdate,
	      submitted_by = l_object_user_id,
          LAST_UPDATED_BY =  fnd_global.USER_ID,
		  LAST_UPDATE_DATE = SYSDATE,
 		  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	  WHERE template_id = l_template_id
	  AND object_type in ('M','E','C');
	ELSE
	  IF(l_distribution_method = 'DIRECT_DISTRIBUTION' AND l_multiple_submissions_flag = 'Y'
	  	AND l_approval_required_flag <> 'Y')
	     THEN
		UPDATE zpb_dc_objects
	        SET status = 'SUBMITTED',
 		  submission_date = sysdate,
	        submitted_by = l_object_user_id,
                approver_user_id = l_approver_id,
		  create_approval_measures_flag = 'Y',
		  delete_approval_measures_flag = 'N',
		  LAST_UPDATED_BY	 = fnd_global.USER_ID,
		  LAST_UPDATE_DATE  = SYSDATE,
		  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
		WHERE object_id = p_object_id;
	     ELSE
	      UPDATE zpb_dc_objects
		   SET status = 'SUBMITTED',
		   freeze_flag = 'Y',
		   submission_date = sysdate,
		   submitted_by = l_object_user_id,
		   approver_user_id = l_approver_id,
		   create_approval_measures_flag = 'Y',
		   delete_approval_measures_flag = 'N', --3834999--
		   LAST_UPDATED_BY	 = fnd_global.USER_ID,
		   LAST_UPDATE_DATE  = SYSDATE,
		   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
		WHERE object_id = p_object_id;
	      END IF;
	END IF;

	-- Create a meaningful item key for dev use--
	SELECT ZPB_DC_WF_PROCESSES_S.nextval
	INTO l_sequence
	FROM dual;

	IF (l_object_type = 'E') THEN
	  l_submit_type := 'Submit Template';
	ELSE
	  l_submit_type := 'Submit Worksheet';
	END IF;

	l_substr_templ_name := substr(l_template_name,1,140);
	l_char_date := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
    l_item_key := to_char(l_sequence) ||
	              '_' || l_submit_type||
	              '_' || l_substr_templ_name ||
	              '_' || l_char_date;


    FND_FILE.Put_Line ( FND_FILE.LOG, 'WF key ' || l_item_key ) ;

    wf_event.AddParameterToList(
	    p_name         => 'DC_OBJECT_ID',
        p_value        => p_object_id,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_TEMPLATE_ID',
        p_value        => l_template_id,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_OBJECT_TYPE',
        p_value        => l_object_type,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_SUBMISSION_MESSAGE',
        p_value        => p_submission_message,
        p_parameterlist=> l_parameter_list);

    -- set fnd values so workflow process can use this values
    -- since they can now be run in deferred mode

    wf_event.AddParameterToList(p_name=>'FND_USER_ID',
	   p_value=> fnd_global.user_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_APPLICATION_ID',
	   p_value=> fnd_global.resp_appl_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_RESPONSIBILITY_ID',
	   p_value=> fnd_global.resp_id,
	   p_parameterlist=>l_parameter_list);

    -- wf debugging
	wf_log_pkg.wf_debug_flag := TRUE;

    -- raise the event
    wf_event.raise(p_event_name => 'oracle.apps.zpb.dc.worksheet.submit',
		 p_event_key => l_item_key,
		 p_parameters => l_parameter_list);

    l_parameter_list.delete;


    COMMIT;

    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data ) ;
    --
    EXCEPTION
    --
     when FND_API.G_EXC_ERROR then
     --
       rollback to Raise_Submission_Event ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
       rollback to Raise_Submission_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when OTHERS then
     --
       rollback to Raise_Submission_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
       END if;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
       --


  END raise_submission_event;

  PROCEDURE check_object_type (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_object_type         VARCHAR2(10);
	l_object_id           NUMBER;
	l_distribution_method zpb_dc_objects.distribution_method%TYPE;
	l_approval_required   VARCHAR2(1);
  BEGIN

    IF (funcmode = 'RUN') THEN

	  l_object_type := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_TYPE');

	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');

	  SELECT distribution_method, approval_required_flag
	  INTO l_distribution_method, l_approval_required
	  FROM zpb_dc_objects
	  WHERE object_id = l_object_id;

      IF (l_object_type = 'E') THEN -- submit template --
		IF (l_distribution_method = 'DIRECT_DISTRIBUTION' AND
		    l_approval_required = 'Y') OR
		   (l_distribution_method = 'CASCADE_DISTRIBUTION') THEN
		  resultout := 'COMPLETE:TEMPLATE_DIRECT_APPR';
		ELSIF (l_distribution_method = 'DIRECT_DISTRIBUTION' AND
		         l_approval_required = 'N') THEN
		  resultout := 'COMPLETE:TEMPLATE_DIRECT_NO_APPR';
		END IF;
	  ELSE  -- submite worksheet --
		IF (l_distribution_method = 'DIRECT_DISTRIBUTION' AND
		    l_approval_required = 'Y') THEN
		  resultout := 'COMPLETE:WORKSHEET_DIRECT_APPR';
		ELSIF (l_distribution_method = 'DIRECT_DISTRIBUTION' AND
		         l_approval_required = 'N') THEN
		  resultout := 'COMPLETE:WORKSHEET_DIRECT_NO_APPR';
		ELSE
		  resultout := 'COMPLETE:WORKSHEET_CASCADE';
		END IF;
	  END IF;
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.check_object_type: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.check_object_type', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END check_object_type;

  PROCEDURE freeze_template (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_template_id      NUMBER;
	l_object_id        NUMBER;
	l_object_user_id   NUMBER;
	l_template_name   VARCHAR2(1000);

	l_object_user_name fnd_user.description%TYPE;
	l_from_name        fnd_user.user_name%TYPE;
	l_frzn_rolename    VARCHAR2(320);
	l_all_rolename     VARCHAR2(320);
    l_exp_days         NUMBER;
    l_charDate         VARCHAR2(20);
    l_frzn_role_has_users    VARCHAR2(1);
	--
  BEGIN

    l_exp_days       := 7;

    IF (funcmode = 'RUN') THEN

	  l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_TEMPLATE_ID');

	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');
 	  -- Get the template name
 	  SELECT template_name
 	  INTO l_template_name
 	  FROM zpb_dc_objects
 	  WHERE template_id = l_template_id
 	  AND object_type = 'M';


	  -- Populate the dc approver for frozen ntf
	  SELECT nvl(fnd.description,fnd.user_name), object_user_id
	  INTO l_object_user_name, l_object_user_id
	  FROM zpb_dc_objects, fnd_user fnd
	  WHERE object_id = l_object_id
	  AND object_user_id = fnd.user_id;

	  -- Populate FROM field
	  SELECT fnd.user_name
	  INTO l_from_name
	  FROM fnd_user fnd, zpb_dc_objects
	  WHERE object_id = l_object_id
	  AND object_user_id = fnd.user_id;

	  -- Create the roles for fromzen and all users
      l_charDate := to_char(sysdate, 'J-SSSSS');
      l_frzn_rolename := 'ZPB_DC_SUBMIT_FRZN'|| to_char(l_template_id) || '-' || l_charDate;
      l_all_rolename := 'ZPB_DC_SUBMIT_ALLU'|| to_char(l_template_id) || '-' || l_charDate;
      zpb_wf_ntf.SetRole(l_frzn_rolename, l_exp_days);
	  zpb_wf_ntf.SetRole(l_all_rolename, l_exp_days);
      l_frzn_role_has_users :=  'N';
	  FOR frzn_rec IN (
	      SELECT u.user_name as user_name
	      FROM zpb_dc_objects obj, fnd_user u
	      WHERE obj.template_id = l_template_id
		  AND obj.object_type = 'W'
		  AND obj.status NOT IN ('SUBMITTED','FROZEN','APPROVED','SUBMITTED_TO_SHARED')
		  AND obj.object_user_id = u.user_id
		  AND (u.end_date is null OR u.end_date > sysdate))
	  LOOP
        l_frzn_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_frzn_rolename, frzn_rec.user_name);
            l_frzn_role_has_users := 'Y';
	  END LOOP;

	  FOR all_rec IN (
	      SELECT u.user_name as user_name
	      FROM zpb_dc_objects obj, fnd_user u
	      WHERE obj.template_id = l_template_id
		  AND obj.object_type in ('W','C')
		  AND obj.object_user_id = u.user_id)
	  LOOP
        l_all_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_all_rolename, all_rec.user_name);
	  END LOOP;

	  -- Change the status to submitted to shared for the template records
	  UPDATE zpb_dc_objects
	  SET status = 'SUBMITTED_TO_SHARED',
	      submission_date = sysdate,
	      submitted_by = l_object_user_id
	  WHERE template_id = l_template_id
	  AND object_type in ('M','E','C');

	 /* Set the status to Frozen if status DISTRIBUTION_PENDING,
	     DISTRIBUTED, REJECTED */
	  UPDATE zpb_dc_objects
	  SET status = 'FROZEN'
	  WHERE template_id = l_template_id
	  AND OBJECT_TYPE = 'W'
	  AND status not in ('SUBMITTED','FROZEN','APPROVED','SUBMITTED_TO_SHARED');

	  -- Set the freeze/app mea flag all records
	  UPDATE zpb_dc_objects
	  SET freeze_flag = 'Y',
 		  LAST_UPDATED_BY =  fnd_global.USER_ID,
		  LAST_UPDATE_DATE = SYSDATE,
 		  LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	  WHERE template_id = l_template_id;

	  --Set template name
	  wf_engine.SetItemAttrText(
	  		      Itemtype => ItemType,
	          	  Itemkey => ItemKey,
	   	          aname => 'DC_TEMPLATE_NAME',
	           	  avalue => l_template_name);


	  -- Set notification recipients --
	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_FROZEN_WS_USER',
         	  avalue => l_frzn_rolename);

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_SUBMITTER',
         	  avalue => l_all_rolename);

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_APPROVER',
         	  avalue => l_object_user_name);

	   wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

          IF (l_frzn_role_has_users = 'Y') THEN
            resultout := 'COMPLETE:Y';
          ELSE
            resultout := 'COMPLETE:N';
          END IF;
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.freeze_template: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.freeze_template', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END freeze_template;

  PROCEDURE freeze_worksheet (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_object_id            NUMBER;
	l_template_id          NUMBER;
	l_distribution_method  zpb_dc_objects.distribution_method%TYPE;

    l_api_version          NUMBER;
	l_init_msg_list        VARCHAR2(1);
	l_commit               VARCHAR2(1);
	l_validation_level     NUMBER;
	l_return_status        VARCHAR2(1);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(4000);

	l_bpo_id               NUMBER;
	l_object_user_id       NUMBER;
	l_distributor_id       NUMBER;
	l_freeze_user_id       NUMBER;
	l_approver_id          NUMBER;
    --
    CURSOR worksheet_csr IS
    SELECT object_user_id
    FROM
    (SELECT distributor_user_id, object_user_id
    	FROM zpb_dc_objects
        WHERE template_id = l_template_id
        AND object_type = 'W'
    )
    START with distributor_user_id = l_object_user_id
    CONNECT by prior object_user_id = distributor_user_id;


  BEGIN

    l_api_version             := 1.0;
	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;

    IF (funcmode = 'RUN') THEN

	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');

	  l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_TEMPLATE_ID');

	  -- If CASCADE, need to freeze all sub ws
	  SELECT distribution_method,
			 distributor_user_id,
			 object_user_id
      INTO l_distribution_method,
		   l_distributor_id,
		   l_object_user_id
	  FROM zpb_dc_objects
      WHERE object_id = l_object_id;

	  IF (l_distribution_method = 'CASCADE_DISTRIBUTION') THEN

        OPEN worksheet_csr;
        LOOP
          FETCH worksheet_csr INTO l_freeze_user_id;
	      EXIT WHEN worksheet_csr%NOTFOUND;

	      IF (l_freeze_user_id <> l_object_user_id) THEN
            UPDATE zpb_dc_objects
	        SET status = 'FROZEN',
                freeze_flag = 'Y',
                LAST_UPDATED_BY	 = fnd_global.USER_ID,
                LAST_UPDATE_DATE  = SYSDATE,
                LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	        WHERE template_id = l_template_id
	        AND object_user_id = l_freeze_user_id;
	      END IF;
        END LOOP;
        CLOSE worksheet_csr;

		resultout := 'COMPLETE';
	  END IF;
	  resultout := 'COMPLETE';

	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.freeze_worksheet: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.freeze_worksheet', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END freeze_worksheet;

  PROCEDURE find_approver (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_approver_type     zpb_dc_objects.approver_type%TYPE;
	l_object_id         number;
  BEGIN

    IF (funcmode = 'RUN') THEN
	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');

	  SELECT approver_type
	  INTO l_approver_type
	  FROM zpb_dc_objects
	  WHERE object_id = l_object_id;

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_APPROVER_TYPE',
         	  avalue => l_approver_type);

      resultout := 'COMPLETE';
    END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.find_approver: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.find_approver', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END find_approver;

  PROCEDURE set_submit_ntf_recipients (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
    l_approver_type           zpb_dc_objects.approver_type%TYPE;
	l_dist_method             zpb_dc_objects.distribution_method%TYPE;
	l_template_name           zpb_dc_objects.template_name%TYPE;
	l_object_id               NUMBER;
	l_template_id             NUMBER;
	l_approver_for_msg        fnd_user.description%TYPE;
	l_submitter_for_msg       fnd_user.description%TYPE;
	l_from_name               fnd_user.user_name%TYPE;
	l_approver                fnd_user.user_name%TYPE;
	l_submitter               fnd_user.user_name%TYPE;
    l_exp_days                NUMBER := 7;
    l_charDate                VARCHAR2(20);
    l_frozen_rolename         VARCHAR2(320);
    l_appr_rolename         VARCHAR2(320);
    l_subtr_rolename         VARCHAR2(320);

    l_api_version             NUMBER;
	l_init_msg_list           VARCHAR2(1);
	l_commit                  VARCHAR2(1);
	l_validation_level        NUMBER;
	l_return_status           VARCHAR2(1);
	l_msg_count               NUMBER;
	l_msg_data                VARCHAR2(4000);
        l_frzn_role_has_users     VARCHAR2(1);

	CURSOR approver_csr IS
	SELECT fnd.user_name
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = l_object_id
	AND obj.approver_user_id = fnd.user_id;

	CURSOR submitter_csr IS
	SELECT fnd.user_name
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = l_object_id
	AND obj.object_user_id = fnd.user_id;

	CURSOR approver_for_msg_csr IS
	SELECT nvl(fnd.description, fnd.user_name)
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = l_object_id
	AND obj.approver_user_id = fnd.user_id;

	CURSOR submitter_for_msg_csr IS
	SELECT nvl(fnd.description, fnd.user_name)
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = l_object_id
	AND obj.object_user_id = fnd.user_id;

  BEGIN
    IF (funcmode = 'RUN') THEN
	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');

 	  l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_TEMPLATE_ID');

	  -- Appeover type is 'DISTRIBUTOR' for this release
	  l_approver_type  := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_APPROVER_TYPE');

	  SELECT template_name
	  INTO l_template_name
	  FROM zpb_dc_objects
	  WHERE object_id = l_object_id;

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_TEMPLATE_NAME',
         	  avalue => l_template_name);

   	  -- Create the roles for Approver and Submitter users
      l_charDate := to_char(sysdate, 'J-SSSSS');
      l_appr_rolename := 'ZPB_NOTE_APPR'|| to_char(l_object_id) || '-' || l_charDate;
      l_subtr_rolename := 'ZPB_NOTE_SUBTR'|| to_char(l_object_id) || '-' || l_charDate;
      zpb_wf_ntf.SetRole(l_appr_rolename, l_exp_days);
	  zpb_wf_ntf.SetRole(l_subtr_rolename, l_exp_days);
	  -- Set the recipients of the ntfs --

	  OPEN approver_csr;
	  FETCH approver_csr INTO l_approver;
	  CLOSE approver_csr;

	  IF (l_approver IS NULL) THEN
	    SELECT fnd.user_name
	    INTO l_approver
	    FROM  zpb_dc_objects obj, fnd_user fnd
	    WHERE obj.object_id = l_object_id
	    AND obj.distributor_user_id = fnd.user_id;

	    IF (l_approver IS NULL) THEN -- -100 --
	      SELECT fnd.user_name
		  INTO l_approver
		  FROM zpb_dc_objects obj, fnd_user fnd
		  WHERE obj.template_id = l_template_id
		  AND obj.object_type = 'M'
		  AND obj.object_user_id = fnd.user_id;
		END IF;
	  END IF;

      l_appr_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_appr_rolename, l_approver);
	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_APPROVER',
         	  avalue => l_appr_rolename);

	  OPEN submitter_csr;
	  FETCH submitter_csr INTO l_submitter;
	  CLOSE submitter_csr;

      l_subtr_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_subtr_rolename, l_submitter);
	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_SUBMITTER',
         	  avalue => l_subtr_rolename);

	  /* The following is to populate approver
	      and submitter for ntf msg, user description is used */
	  OPEN approver_for_msg_csr;
	  FETCH approver_for_msg_csr INTO l_approver_for_msg;
	  CLOSE approver_for_msg_csr;

	  IF (l_approver_for_msg IS NULL) THEN
	    SELECT nvl(fnd.description, fnd.user_name)
	    INTO l_approver_for_msg
	    FROM  zpb_dc_objects obj, fnd_user fnd
	    WHERE obj.object_id = l_object_id
	    AND obj.distributor_user_id = fnd.user_id;

	    IF (l_approver_for_msg IS NULL) THEN -- -100 --
	      SELECT nvl(fnd.description, fnd.user_name)
		  INTO l_approver_for_msg
		  FROM zpb_dc_objects obj, fnd_user fnd
		  WHERE obj.template_id = l_template_id
		  AND obj.object_type = 'M'
		  AND obj.object_user_id = fnd.user_id;
		END IF;
	  END IF;

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_APPROVER_FOR_MSG',
         	  avalue => l_approver_for_msg);

	  OPEN submitter_for_msg_csr;
	  FETCH submitter_for_msg_csr INTO l_submitter_for_msg;
	  CLOSE submitter_for_msg_csr;

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_SUBMITTER_FOR_MSG',
         	  avalue => l_submitter_for_msg);

	  /* Populate the From field in notification details page
	     Can not use description here, use user name*/
	  SELECT fnd.user_name
	  INTO l_from_name
	  FROM fnd_user fnd, zpb_dc_objects obj
	  WHERE obj.object_id = l_object_id
	  AND obj.object_user_id = fnd.user_id;

	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => l_from_name);

	  -- Create the role  for frozen ws user
      l_charDate := to_char(sysdate, 'J-SSSSS');
      l_frozen_rolename := 'ZPB_DC_SUB_FZN'|| to_char(l_object_id) || '-' || l_charDate;
      zpb_wf_ntf.SetRole(l_frozen_rolename, l_exp_days);
          l_frzn_role_has_users := 'N';
	  FOR frozen_user_rec IN (
	      SELECT u.user_name as user_name
	      FROM zpb_dc_objects obj, fnd_user u
	      WHERE obj.template_id = l_template_id
		  AND obj.object_type = 'W'
		  AND obj.status = 'FROZEN'
		  AND obj.object_user_id = u.user_id)
	  LOOP
            l_frozen_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_frozen_rolename, frozen_user_rec.user_name);
            l_frzn_role_has_users := 'Y';
	  END LOOP;

	  wf_engine.SetItemAttrText(
		      Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'DC_FROZEN_WS_USER',
         	  avalue => l_frozen_rolename);

      IF (l_frzn_role_has_users = 'Y') THEN
        resultout := 'COMPLETE:Y';
      ELSE
        resultout := 'COMPLETE:N';
      END IF;
    END IF; -- run mode

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_submit_ntf_recipients: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_submit_ntf_recipients', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END set_submit_ntf_recipients ;

  PROCEDURE update_aw(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_req_id                NUMBER;
	l_template_id           NUMBER;
	l_object_id             NUMBER;
	l_object_user_id        NUMBER;
	l_owner                 VARCHAR2(30);
	l_process_name          fnd_new_messages.message_text%TYPE;
	l_template_name         zpb_dc_objects.template_name%TYPE;

	l_user_id 	            NUMBER ;
    l_resp_id               NUMBER ;
    l_respapp_id            NUMBER ;
  BEGIN

	l_user_id 	            := fnd_global.USER_ID;
    l_resp_id               := fnd_global.RESP_ID;
    l_respapp_id            := fnd_global.RESP_APPL_ID;
	l_owner                 := fnd_global.user_name;

    IF (funcmode = 'RUN') THEN

	  l_object_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_ID');

	  l_template_id := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_TEMPLATE_ID');

      l_user_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_USER_ID');

      l_resp_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_RESPONSIBILITY_ID');

      l_respapp_id  := wf_engine.GetItemAttrNumber(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'FND_APPLICATION_ID');

	  SELECT object_user_id, template_name
	  INTO l_object_user_id, l_template_name
	  FROM zpb_dc_objects
	  WHERE object_id = l_object_id;

	  -- set EPBPerformer to owner name for issue notifications
	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'EPBPERFORMER',
               avalue => l_owner);

           -- Get Message from Fnd_Messages
           FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_SUBMIT_ISSUE_MSG');
           l_process_name := FND_MESSAGE.GET;

	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'DC_PROCESS_NAME',
               avalue => l_process_name);

	  wf_engine.SetItemAttrText(
	           Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'DC_TEMPLATE_NAME',
               avalue => l_template_name);

	  -- Push data to shared AW --
	  fnd_global.apps_initialize(l_user_id,l_resp_id,l_respapp_id);
      zpb_wf.submit_to_shared(l_object_user_id, l_template_id, l_req_id);

      -- Set the values for wait for concurrent program
      wf_engine.SetItemAttrNumber(
	           Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'REQUEST_ID',
			   avalue => l_req_id);

	  IF l_req_id = 0 THEN
	    resultout := 'COMPLETE:N';
	  ELSE
	    resultout := 'COMPLETE:Y';
	  END IF;
    END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE:Y';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.update_aw: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.update_aw', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END update_aw;

  PROCEDURE check_update_aw_type (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
	l_object_type         VARCHAR2(10);
  BEGIN

    IF (funcmode = 'RUN') THEN

	  l_object_type := wf_engine.GetItemAttrText(
	           Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DC_OBJECT_TYPE');

	  IF (l_object_type = 'E') THEN
		resultout := 'COMPLETE:TEMPLATE_DIRECT_APPR';
      ELSE
	    resultout := 'COMPLETE:WORKSHEET_DIRECT_NO_APPR';
	  END IF;
	END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.check_update_aw_type: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.check_update_aw_type', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END check_update_aw_type;

  PROCEDURE raise_approval_event(
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_validation_level          IN       NUMBER,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2,
    --
    p_object_id                 IN number,
    p_approver_user_id          IN number,
	p_approval_message          IN varchar2
  )
  IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'raise_approval_event' ;
    l_api_version               CONSTANT NUMBER := 1.0 ;
	l_init_msg_list             VARCHAR2(1);
	l_commit                    VARCHAR2(1);
	l_validation_level          NUMBER;
	l_return_status             VARCHAR2(1);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(4000);
    --
	l_submitter                 fnd_user.user_name%TYPE;
	l_approver_for_msg          fnd_user.description%TYPE;
	l_template_name             zpb_dc_objects.template_name%TYPE;
	l_substr_templ_name         VARCHAR2(140);
	l_template_id               NUMBER;
	l_from_name                 fnd_user.user_name%TYPE;
	l_sequence                  NUMBER;
	l_approval_type             VARCHAR2(30);
	l_char_date                 VARCHAR2(30);
    l_exp_days                  NUMBER := 7;
    l_frozen_rolename           VARCHAR2(320);
    l_appr_rolename             VARCHAR2(320);
    l_subtr_rolename            VARCHAR2(320);

	--
    l_item_type                 VARCHAR2(100) ;
    l_item_key                  VARCHAR2(240) ;
    l_event_t wf_event_t;
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
	--
  BEGIN

    SAVEPOINT Raise_Approval_Event ;

    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Initialize the parameters
    l_item_type               := 'ZPBDC' ;
	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;

	SELECT nvl(description,user_name)
	INTO l_approver_for_msg
	FROM fnd_user
	WHERE user_id= p_approver_user_id;

	SELECT user_name
	INTO l_from_name
	FROM fnd_user
	WHERE user_id= p_approver_user_id;

	SELECT obj.template_name, fnd.user_name, obj.template_id
	INTO l_template_name, l_submitter, l_template_id
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = p_object_id
	AND obj.object_user_id = fnd.user_id;

	SELECT ZPB_DC_WF_PROCESSES_S.nextval
	INTO l_sequence
	FROM dual;

	l_substr_templ_name := substr(l_template_name,1,140);
	l_approval_type := 'Approve Worksheet';
	l_char_date := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
    l_item_key := to_char(l_sequence) ||
	              '_' || l_approval_type||
	              '_' || l_substr_templ_name ||
	              '_' || l_char_date;

	FND_FILE.Put_Line ( FND_FILE.LOG, 'WF key ' || l_item_key ) ;

    -- Create the roles for Approver and Submitter users
    l_char_date := to_char(sysdate, 'J-SSSSS');
    l_appr_rolename := 'ZPB_APP_APPR'|| to_char(p_object_id) || '-' || l_char_date;
    l_subtr_rolename := 'ZPB_APP_SUBTR'|| to_char(p_object_id) || '-' || l_char_date;
    zpb_wf_ntf.SetRole(l_appr_rolename, l_exp_days);
    zpb_wf_ntf.SetRole(l_subtr_rolename, l_exp_days);

    wf_event.AddParameterToList(
	    p_name         => '#FROM_ROLE',
        p_value        => l_from_name,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_APPROVER_FOR_MSG',
        p_value        => l_approver_for_msg,
        p_parameterlist=> l_parameter_list);

    l_subtr_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_subtr_rolename, l_submitter);
    wf_event.AddParameterToList(
	    p_name         => 'DC_SUBMITTER',
        p_value        => l_subtr_rolename,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_TEMPLATE_NAME',
        p_value        => l_template_name,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_APPROVAL_MESSAGE',
        p_value        => p_approval_message,
        p_parameterlist=> l_parameter_list);

    -- set fnd values so workflow process can use this values
    -- since they can now be run in deferred mode
	-- working:fnd_global.apps_initialize(1005258,57124,210);

    wf_event.AddParameterToList(p_name=>'FND_USER_ID',
	   p_value=> fnd_global.user_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_APPLICATION_ID',
	   p_value=> fnd_global.resp_appl_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_RESPONSIBILITY_ID',
	   p_value=> fnd_global.resp_id,
	   p_parameterlist=>l_parameter_list);

    -- wf debugging
	wf_log_pkg.wf_debug_flag := TRUE;
    -- raise the event
    wf_event.raise(p_event_name => 'oracle.apps.zpb.dc.worksheet.approve',
		 p_event_key => l_item_key,
		 p_parameters => l_parameter_list);

    l_parameter_list.delete;

    COMMIT;

    ZPB_DC_OBJECTS_PVT.Populate_Approvers(
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_commit              => l_commit,
      p_validation_level    => l_validation_level,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      --
      p_object_id           => p_object_id,
      p_approver_user_id    => p_approver_user_id,
      p_approval_date       => sysdate);

    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data ) ;
    --
    EXCEPTION
    --
     when FND_API.G_EXC_ERROR then
     --
       rollback to Raise_Approval_Event ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
       rollback to Raise_Approval_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when OTHERS then
     --
       rollback to Raise_Approval_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
       END if;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
       --


  END raise_approval_event;

  PROCEDURE raise_rejection_event(
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_validation_level          IN       NUMBER,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2,
    --
    p_object_id                 IN number,
    p_approver_user_id          IN number,
	p_rejection_message         IN varchar2
  )
  IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'raise_rejection_event' ;
    l_api_version               CONSTANT NUMBER := 1.0 ;
	l_init_msg_list             VARCHAR2(1);
	l_commit                    VARCHAR2(1);
	l_validation_level          NUMBER;
	l_return_status             VARCHAR2(1);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(4000);
    --
	l_submitter                 fnd_user.user_name%TYPE;
	l_approver_for_msg          fnd_user.description%TYPE;
	l_template_name             zpb_dc_objects.template_name%TYPE;
	l_substr_templ_name         VARCHAR2(140);
	l_template_id               NUMBER;
	l_from_name                 fnd_user.user_name%TYPE;
	l_sequence                  NUMBER;
	l_rejection_type            VARCHAR2(30);
	l_char_date                 VARCHAR2(30);
    l_exp_days                  NUMBER := 7;
    l_frozen_rolename           VARCHAR2(320);
    l_appr_rolename             VARCHAR2(320);
    l_subtr_rolename            VARCHAR2(320);
	--
    l_item_type                 VARCHAR2(100) ;
    l_item_key                  VARCHAR2(240) ;
    l_event_t wf_event_t;
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
	--
  BEGIN

    SAVEPOINT Raise_Rejection_Event ;

    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Initialize the parameters
	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;


	SELECT ZPB_DC_WF_PROCESSES_S.nextval
	INTO l_item_key
	FROM dual;

	SELECT nvl(description,user_name)
	INTO l_approver_for_msg
	FROM fnd_user
	WHERE user_id= p_approver_user_id;

	SELECT obj.template_name, fnd.user_name, template_id
	INTO l_template_name, l_submitter, l_template_id
	FROM zpb_dc_objects obj, fnd_user fnd
	WHERE obj.object_id = p_object_id
	AND obj.object_user_id = fnd.user_id;

	-- Populate the From field in notification details page
	SELECT user_name
	INTO l_from_name
	FROM fnd_user
	WHERE user_id= p_approver_user_id;

	SELECT ZPB_DC_WF_PROCESSES_S.nextval
	INTO l_sequence
	FROM dual;

	l_substr_templ_name := substr(l_template_name,1,140);
	l_rejection_type := 'Reject Worksheet';
	l_char_date := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
    l_item_key := to_char(l_sequence) ||
	              '_' || l_rejection_type||
	              '_' || l_substr_templ_name ||
	              '_' || l_char_date;

    FND_FILE.Put_Line ( FND_FILE.LOG, 'WF key ' || l_item_key ) ;

    -- Create the roles for Approver and Submitter users
    l_char_date := to_char(sysdate, 'J-SSSSS');
    l_appr_rolename := 'ZPB_REJ_APPR'|| to_char(p_object_id) || '-' || l_char_date;
    l_subtr_rolename := 'ZPB_REJ_SUBTR'|| to_char(p_object_id) || '-' || l_char_date;
    zpb_wf_ntf.SetRole(l_appr_rolename, l_exp_days);
	zpb_wf_ntf.SetRole(l_subtr_rolename, l_exp_days);

    wf_event.AddParameterToList(
	    p_name         => '#FROM_ROLE',
        p_value        => l_from_name,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_APPROVER_FOR_MSG',
        p_value        => l_approver_for_msg,
        p_parameterlist=> l_parameter_list);

    l_subtr_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_subtr_rolename, l_submitter);
    wf_event.AddParameterToList(
	    p_name         => 'DC_SUBMITTER',
        p_value        => l_subtr_rolename,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_TEMPLATE_NAME',
        p_value        => l_template_name,
        p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(
	    p_name         => 'DC_REJECTION_MESSAGE',
        p_value        => p_rejection_message,
        p_parameterlist=> l_parameter_list);

    -- set fnd values so workflow process can use this values
    -- since they can now be run in deferred mode
	-- working:fnd_global.apps_initialize(1005258,57124,210);

    wf_event.AddParameterToList(p_name=>'FND_USER_ID',
	   p_value=> fnd_global.user_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_APPLICATION_ID',
	   p_value=> fnd_global.resp_appl_id,
	   p_parameterlist=>l_parameter_list);

    wf_event.AddParameterToList(p_name=>'FND_RESPONSIBILITY_ID',
	   p_value=> fnd_global.resp_id,
	   p_parameterlist=>l_parameter_list);

    -- wf debugging
	wf_log_pkg.wf_debug_flag := TRUE;
    -- raise the event
    wf_event.raise(p_event_name => 'oracle.apps.zpb.dc.worksheet.reject',
		 p_event_key => l_item_key,
		 p_parameters => l_parameter_list);

    l_parameter_list.delete;

    COMMIT;

    ZPB_DC_OBJECTS_PVT.Populate_Approvers(
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_commit              => l_commit,
      p_validation_level    => l_validation_level,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      --
      p_object_id           => p_object_id,
      p_approver_user_id    => p_approver_user_id,
      p_approval_date       => sysdate);

    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data ) ;
    --
    EXCEPTION
    --
     when FND_API.G_EXC_ERROR then
     --
       rollback to Raise_Rejection_Event ;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
       rollback to Raise_Rejection_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
     --
     when OTHERS then
     --
       rollback to Raise_Rejection_Event ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
       END if;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);
       --


  END raise_rejection_event;

  PROCEDURE set_worksheet_status (
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
	)
  IS
 	l_object_id           NUMBER;
 	l_multiple_submissions_flag VARCHAR2(1);
  BEGIN

 	l_object_id := 0;
    IF (funcmode = 'RUN') THEN

      l_object_id := wf_engine.GetItemAttrNumber(
	          Itemtype => ItemType,
	          Itemkey => ItemKey,
	         aname => 'DC_OBJECT_ID');

	  --find if multiple submissions are allowed
	  --If multiple submission are allowed  - only update status
	  --else update status and freeze flag
	  SELECT multiple_submissions_flag
	  INTO l_multiple_submissions_flag
	  FROM zpb_dc_objects
	  WHERE object_id = l_object_id;

	  IF(l_multiple_submissions_flag <>'Y')
	  THEN
             UPDATE zpb_dc_objects
  	     SET status = 'SUBMITTED_TO_SHARED',
 	      freeze_flag = 'Y',
	      LAST_UPDATED_BY =  fnd_global.USER_ID,
	      LAST_UPDATE_DATE = SYSDATE,
	      LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	     WHERE object_id = l_object_id;
	  ELSE
	     UPDATE zpb_dc_objects
	     SET status = 'SUBMITTED_TO_SHARED',
	      LAST_UPDATED_BY =  fnd_global.USER_ID,
	      LAST_UPDATE_DATE = SYSDATE,
	      LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
	     WHERE object_id = l_object_id;

	  END IF;


      resultout := 'COMPLETE';
    END IF;

    IF ( funcmode = 'CANCEL' ) THEN
      resultout := 'COMPLETE';
    END IF;

	IF (funcmode not in ('RUN','CANCEL')) THEN
	  resultout := '';
	END IF;
    return;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_worksheet_status: no data found', itemtype, itemkey, to_char(actid), funcmode);
      raise;

    WHEN others THEN
      WF_CORE.CONTEXT('zpb_dc_wf.set_worksheet_status', itemtype, itemkey, to_char(actid), funcmode);
      raise;
  END set_worksheet_status;


  PROCEDURE unblock_manage_submission (
      itemtype    IN varchar2,
      itemkey     IN varchar2,
      actid       IN number,
      funcmode    IN varchar2,
      resultout   OUT nocopy varchar2
  	)
    IS
   	l_object_id     NUMBER;
   	l_item_key      VARCHAR2(4000);

    BEGIN

   	l_object_id := 0;
      IF (funcmode = 'RUN') THEN

          l_object_id := wf_engine.GetItemAttrNumber(
  	          Itemtype => ItemType,
  	          Itemkey => ItemKey,
  	         aname => 'DC_OBJECT_ID');

  	  -- Find the item key  manage submission task that is managing the submissions
      	  -- of this template
  	  SELECT task.item_key
  	  INTO l_item_key
	  FROM zpb_dc_objects obj,zpb_analysis_cycle_tasks task,zpb_task_parameters param
	  WHERE obj.object_id = l_object_id
	  AND task.analysis_cycle_id = obj.ac_instance_id
	  AND task.task_id = param.task_id
	  AND param.name = 'SUBMISSION_TEMPLATE_ID'
	  AND obj.ac_template_id = to_number(param.value)
	  AND task.wf_process_name = 'MANAGE_SUBMISSION';


  	  --Unblock the manage submissions workflow
  	  wf_engine.completeactivity('EPBCYCLE',l_item_key,'BLOCK',NULL);

        resultout := 'COMPLETE';
      END IF;

      IF ( funcmode = 'CANCEL' ) THEN
        resultout := 'COMPLETE';
      END IF;

  	IF (funcmode not in ('RUN','CANCEL')) THEN
  	  resultout := '';
  	END IF;
      return;

      EXCEPTION

      WHEN NO_DATA_FOUND THEN
        WF_CORE.CONTEXT('zpb_dc_wf.unblock_manage_submission: no data found', itemtype, itemkey, to_char(actid), funcmode);
        raise;

      WHEN others THEN
        WF_CORE.CONTEXT('zpb_dc_wf.unblock_manage_submission', itemtype, itemkey, to_char(actid), funcmode);
        raise;
  END unblock_manage_submission;

  PROCEDURE check_all_ws_submitted (
        itemtype    IN varchar2,
    	itemkey     IN varchar2,
    	actid       IN number,
    	funcmode    IN varchar2,
        resultout   OUT nocopy varchar2
    	)
      IS
     	l_object_id           NUMBER;
     	l_template_id	      NUMBER;
     	l_ws_status_count     NUMBER;
     	l_multiple_submissions_flag VARCHAR2(1);
      BEGIN

     	l_object_id := 0;
        IF (funcmode = 'RUN') THEN

          l_object_id := wf_engine.GetItemAttrNumber(
    	          Itemtype => ItemType,
    	          Itemkey => ItemKey,
    	         aname => 'DC_OBJECT_ID');
    	  -- get the template_id
    	  SELECT template_id
    	  INTO l_template_id
    	  FROM zpb_dc_objects
    	  WHERE object_id = l_object_id;

    	  --check if all the worksheet for this template have been submitted
    	  SELECT count(*)
	  INTO l_ws_status_count
	  FROM zpb_dc_objects obj , fnd_user usr
	  WHERE obj.object_user_id = usr.user_id
        AND l_template_id = obj.template_id
	  AND obj.object_type = 'W'
	  AND obj.status NOT IN ('SUBMITTED_TO_SHARED')
	  AND (usr.end_date is null OR usr.end_date > sysdate);

	  --Find if multiple submissions are allowed
	  SELECT multiple_submissions_flag
	  INTO l_multiple_submissions_flag
	  FROM zpb_dc_objects
    	  WHERE object_id = l_object_id;

	  --if all the worksheet are not submitted to shared or multiple submission are allowed
	  -- take the No transition.
	  IF(l_ws_status_count > 0 OR l_multiple_submissions_flag = 'Y') THEN
	   resultout := 'COMPLETE:N';
	  ELSE
	   resultout := 'COMPLETE:Y';
	  END IF;
        END IF;

        IF ( funcmode = 'CANCEL' ) THEN
          resultout := 'COMPLETE:Y';
        END IF;

    	IF (funcmode not in ('RUN','CANCEL')) THEN
    	  resultout := '';
    	END IF;
        return;

        EXCEPTION

        WHEN NO_DATA_FOUND THEN
          WF_CORE.CONTEXT('zpb_dc_wf.check_all_ws_submitted: no data found', itemtype, itemkey, to_char(actid), funcmode);
          raise;

        WHEN others THEN
          WF_CORE.CONTEXT('zpb_dc_wf.check_all_ws_submitted', itemtype, itemkey, to_char(actid), funcmode);
          raise;
    END check_all_ws_submitted;


END ZPB_DC_WF ;

/
