--------------------------------------------------------
--  DDL for Package Body AHL_GENERIC_APRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_GENERIC_APRV_PVT" as
/* $Header: AHLVGWFB.pls 115.7 2003/12/30 06:27:55 rroy noship $ */

/*****************************************************************
-- Private API Specifications
*****************************************************************/

PROCEDURE Get_User_Role(
	p_resource_id        IN     NUMBER,
	x_role_name          OUT NOCOPY    VARCHAR2,
	x_role_display_name  OUT NOCOPY    VARCHAR2 ,
	x_return_status      OUT NOCOPY    VARCHAR2);

PROCEDURE Check_Approval_Required(
	p_rule_id             IN  NUMBER,
	p_current_seq         IN   NUMBER,
	x_next_seq            OUT NOCOPY  NUMBER,
	x_required_flag       OUT NOCOPY  VARCHAR2);

PROCEDURE Check_Appl_Usg_Code(
	p_appl_usg_code IN  VARCHAR2,
	x_return_status      OUT NOCOPY VARCHAR2
);

--======================================================================
-- PROCEDURE
--    Start_WF_Process
--
-- PURPOSE
--    Start Workflow Process
--
--======================================================================

PROCEDURE Start_WF_Process
           (p_object                 IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2,
	    p_object_version_number  IN   NUMBER,
            p_orig_status_code       IN   VARCHAR2,
            p_new_status_code        IN   VARCHAR2,
            p_reject_status_code     IN   VARCHAR2,
            p_requester_userid       IN   NUMBER,
            p_notes_from_requester   IN   VARCHAR2,
            p_workflowprocess        IN   VARCHAR2,
            p_item_type              IN   VARCHAR2,
            p_application_usg_code   IN   VARCHAR2   DEFAULT 'AHL'
           )
IS
    itemtype              VARCHAR2(30) := nvl(p_item_type,'AHLGAPP');
    itemkey               VARCHAR2(30) := p_approval_type||':'||p_object||':'||to_char(p_activity_id)||':'||to_char(p_object_version_number);
    itemuserkey           VARCHAR2(80) := p_object||':'||to_char(p_activity_id);

    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_error_msg              VARCHAR2(4000);
    l_save_threshold         NUMBER := wf_engine.threshold;
    l_index                  NUMBER;
    l_return_status		     varchar2(1);
    l_counter                NUMBER;
    l_timeout                NUMBER;

    l_requester_role         VARCHAR2(30);
    l_resource_id            NUMBER;
    l_display_name           VARCHAR2(80);
    l_application_usg_code   VARCHAR2(30);

    CURSOR c_resource IS
    SELECT resource_id
    FROM ahl_jtf_rs_emp_v
    WHERE user_id = p_requester_userid ;
BEGIN

   fnd_msg_pub.initialize;

   -- wf_engine.threshold := -1;
   WF_ENGINE.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

   WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);


   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'OBJECT_TYPE',
                             avalue     =>   p_object  );

   -- Reema: Validate Application Usage Code
   l_application_usg_code := p_application_usg_code;
   Check_Appl_Usg_Code(p_appl_usg_code => l_application_usg_code,
   		  x_return_status => l_return_status
		  );
   IF l_return_status <> Fnd_Api.g_ret_sts_error
   THEN
   -- Reema:
   -- Set the Value of Application Usage Code
   -- This value can then be used in other procedures.
   WF_ENGINE.SetItemAttrText(itemtype 	=>   itemtype,
   			     itemkey    =>   itemkey,
			     aname      =>   'APPLICATION_USG_CODE',
			     avalue     =>   p_application_usg_code);
   END IF;

   -- Activity ID  (primary Id of Activity Object)
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'OBJECT_ID',
                               avalue    =>  p_activity_id  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'ORG_STATUS_ID',
                             avalue     =>   p_orig_status_code  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'NEW_STATUS_ID',
                             avalue     =>   P_NEW_STATUS_CODE  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'REJECT_STATUS_ID',
                             avalue     =>   p_reject_status_code  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'OBJECT_VER',
                             avalue     =>   p_object_version_number  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'REQUESTER_ID',
                             avalue     =>   p_requester_userid  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'REQUESTER_NOTE',
                             avalue     =>   nvl(p_notes_from_requester,''));

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'APPROVAL_TYPE',
                             avalue     =>   p_approval_type  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'REQUEST_TIME',
                             avalue     =>   SYSDATE  );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'DOCUMENT_ID',
                             avalue     =>  itemtype || ':' ||itemkey);


  -- Set up Loop Counter here from profile option value!
   l_counter := FND_PROFILE.VALUE('AHL_WF_COUNTER');

   if l_counter is null
   then

      	FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_COUNTER');
		FND_MSG_PUB.Add;
    else
       WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'COUNTER',
                             avalue     =>  l_counter  );

	END IF;

  -- Set up Timeout here from profile option value!
   l_timeout := FND_PROFILE.VALUE('AHL_WF_TIMEOUT');

   if l_timeout is null
   then

      	FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_TIMEOUT');
		FND_MSG_PUB.Add;
    else
       WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'TIMEOUT',
                             avalue     =>  l_timeout  );

	END IF;

   --Standard Call to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


    -- Set up requester Role
    l_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Get Resource ID of the Requester
    OPEN c_resource ;
	FETCH c_resource INTO l_resource_id ;
	IF c_resource%NOTFOUND THEN
		l_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_RESOURCE');
		FND_MSG_PUB.Add;
        CLOSE c_resource ;
    ELSE
        CLOSE c_resource ;
        Get_User_Role(p_resource_id          => l_resource_id ,
                      x_role_name            => l_requester_role,
                      x_role_display_name    => l_display_name,
                      x_return_status        => l_return_status);

	END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'REQUESTER',
                            avalue      =>  l_requester_role  );

    -- Setting the WF Owner
				WF_ENGINE.SetItemOwner(itemtype => itemtype,
																											itemkey => itemkey,
																											owner => l_requester_role);
  END IF;

   -- Start the Process
   WF_ENGINE.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);


    -- wf_engine.threshold := l_save_threshold ;
 EXCEPTION
     WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);

       if(l_msg_count > 0)then
           for I in 1 .. l_msg_count LOOP
               fnd_msg_pub.Get
              (p_msg_index      => FND_MSG_PUB.G_NEXT,
               p_encoded        => FND_API.G_FALSE,
               p_data           => l_msg_data,
               p_msg_index_out  => l_index);

--         dbms_output.put_line('error message :'||l_msg_data);
           end loop;
        end if;
        RAISE;

END Start_WF_Process;

/*****************************************************************
-- Wrapper API Body
*****************************************************************/


/*****************************************************************
-- Start of Comments
--
-- NAME
--   set_activity_details
--
-- PURPOSE
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE Set_Activity_Details(itemtype     IN  VARCHAR2,
                               itemkey      IN  VARCHAR2,
                               actid        IN  NUMBER,
                               funcmode     IN  VARCHAR2,
			                   resultout    OUT NOCOPY VARCHAR2)
IS
l_object                VARCHAR(30);
l_approval_type         VARCHAR2(30);
l_pkg_name              varchar2(80);
l_proc_name             varchar2(80);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_return_status		varchar2(1);
dml_str VARCHAR2		(2000);

BEGIN

  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN

     -- get approval object
     l_object        := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'OBJECT_TYPE' );


     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	  Get_Api_Name('WORKFLOW', l_object, 'SET_ACTIVITY_DETAILS', l_approval_type, l_pkg_name, l_proc_name, l_return_status);
	  if (l_return_status = fnd_api.g_ret_sts_success) then
			dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
			EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey,IN actid,IN funcmode, OUT resultout;
	  else
              RAISE FND_API.G_EXC_ERROR;
              return;
      end if;

  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_GENERIC_APRV_PVT','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);

      resultout := 'COMPLETE:ERROR';

  WHEN OTHERS THEN

        wf_core.context('AHL_GENERIC_APRV_PVT','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,'Unexpected Error!');

        RAISE;

END Set_Activity_Details ;



-------------------------------------------------------------------------------
--
-- NAME
--   PREPARE_DOC
--
-- PURPOSE
--   Serve as a connection point. Dose nothing.
-------------------------------------------------------------------------------

PROCEDURE Prepare_Doc( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in  number,
                       funcmode        in  varchar2,
                       resultout       out nocopy varchar2 )
IS
BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     resultout := 'COMPLETE:SUCCESS';
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --

END Prepare_Doc;


-------------------------------------------------------------------------------
--
-- Set_Approver_Details
--
-------------------------------------------------------------------------------
PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       out nocopy varchar2 )
IS
l_current_seq             NUMBER;
l_approval_rule_id        NUMBER;
l_approver_id             NUMBER;
l_approver                VARCHAR2(30);
l_approver_display_name   VARCHAR2(80);
l_approver_type           VARCHAR2(30);
l_object_approver_id      NUMBER;

l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_error_msg               VARCHAR2(4000);


BEGIN

	FND_MSG_PUB.initialize();

	IF (funcmode = 'RUN') THEN
		l_approval_rule_id := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'RULE_ID' );

		l_current_seq        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_SEQ' );

		Get_approver_Info
          ( p_rule_id              =>  l_approval_rule_id,
            p_current_seq          =>  l_current_seq ,
            x_approver_id          =>  l_approver_id,
            x_approver_type        =>  l_approver_type,
            x_object_approver_id   =>  l_object_approver_id,
            x_return_status        =>  l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then

             RAISE FND_API.G_EXC_ERROR;
		END IF;

		Get_User_Role(p_resource_id          => l_object_approver_id ,
                      x_role_name            => l_approver,
                      x_role_display_name    => l_approver_display_name,
                      x_return_status        => l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then

             RAISE FND_API.G_EXC_ERROR;
		END IF;

		wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER',
                                    avalue   => l_approver);

		wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_ID',
                                    avalue   => l_object_approver_id);


		resultout := 'COMPLETE:';
	END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );

        Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;


         wf_core.context('AHL_GENERIC_APRV_PVT',
                         'set_approver_Details',
                         itemtype, itemkey,to_char(actid),l_error_msg);

        RAISE;
    WHEN OTHERS THEN

         wf_core.context('AHL_GENERIC_APRV_PVT',
                         'set_approver_Details',
                         itemtype, itemkey,to_char(actid),'Unexpected Error!');

    RAISE;
  --

END Set_Approver_Details;


-------------------------------------------------------------------------------
--
-- Set_Further_Approvals
--
-------------------------------------------------------------------------------
PROCEDURE Set_Further_Approval(  itemtype        in  varchar2,
                                 itemkey         in  varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       out nocopy varchar2 )
IS
l_current_seq             NUMBER;
l_next_seq                NUMBER;
l_approval_rule_id        NUMBER;
l_required_flag           VARCHAR2(1);
l_approver_id             NUMBER;
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_return_status           VARCHAR2(1);
l_error_msg               VARCHAR2(4000);
BEGIN

  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     l_approval_rule_id   := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'RULE_ID' );

     l_current_seq        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_SEQ' );

     l_approver_id := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_ID' );


     Check_Approval_Required
             ( p_rule_id                  => l_approval_rule_id,
               p_current_seq              => l_current_seq,
               x_next_seq                 => l_next_seq,
               x_required_flag            => l_required_flag);

     IF l_next_seq is not null THEN
          wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_SEQ',
                                    avalue   => l_next_seq);
        resultout := 'COMPLETE:Y';
     ELSE
        resultout := 'COMPLETE:N';
     END IF;
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
           FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
           Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;

           wf_core.context('AHL_GENERIC_APRV_PVT',
                    'set_further_approval',
                    itemtype, itemkey,to_char(actid),l_error_msg);
         RAISE;
     WHEN OTHERS THEN

        wf_core.context('AHL_GENERIC_APRV_PVT',
                    'set_further_approval',
                    itemtype, itemkey,to_char(actid),'Unexpected Error!');
    RAISE;
  --

END Set_Further_Approval;


--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval(document_id         in  varchar2,
                       display_type        in  varchar2,
                       document            in out nocopy varchar2,
                       document_type	   in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_APPROVAL',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approval',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approval',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Approval;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Error_Act(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Error_Act(document_id  in  varchar2,
                 display_type        in  varchar2,
                 document            in out nocopy  varchar2,
                 document_type	     in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_ERROR_ACT',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_error_act',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_error_act',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Error_Act;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval_Reminder(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval_Reminder(document_id  in  varchar2,
                         display_type        in  varchar2,
                         document            in out nocopy  varchar2,
                         document_type		 in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_APPROVAL_REMINDER',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approval_reminder',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approval_reminder',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Approval_Reminder;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Forward_FYI(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Forward_FYI(document_id  in  varchar2,
                   display_type        in  varchar2,
                   document            in out nocopy  varchar2,
                   document_type	   in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN

    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');

    l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_FORWARD_FYI',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_forward_fyi',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_forward_fyi',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Forward_FYI;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approved_FYI(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approved_FYI(document_id  in  varchar2,
                    display_type        in  varchar2,
                    document            in out nocopy  varchar2,
                    document_type		in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_APPROVED_FYI',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approved_fyi',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_approved_fyi',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Approved_FYI;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Rejected_FYI(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_REJECTED_FYI',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_rejected_fyi',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_rejected_fyi',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Rejected_FYI;
--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Final_Approval_FYI(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Final_Approval_FYI(document_id  in  varchar2,
                          display_type        in  varchar2,
                          document            in out nocopy  varchar2,
                          document_type		  in out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_itemType           varchar2(80);
l_itemKey            varchar2(80);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AHLGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'NTF_FINAL_APPROVAL_FYI',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	if (l_return_stat = fnd_api.g_ret_sts_success) then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
           );
        Handle_Error
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_final_approval_fyi',
                    l_itemtype, l_itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'ntf_final_approval_fyi',
                    l_itemtype, l_itemkey,'Unexpected Error!');
    RAISE;
  --

END Ntf_Final_Approval_FYI;

-------------------------------------------------------------------------------
--
-- Procedure
--   Update_Status(itemtype       in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Update_Status(itemtype        IN varchar2,
                        itemkey         IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_status		 varchar2(1);
BEGIN
    FND_MSG_PUB.initialize();
    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'UPDATE_STATUS',l_approval_type, l_pkg_name, l_proc_name, l_return_status);

	  if (l_return_status = fnd_api.g_ret_sts_success) then
			dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
			EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey,IN actid,IN funcmode, OUT resultout;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           );
        wf_core.context('AHL_GENERIC_APRV_PVT',
                    'update_status',
                    itemtype, itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'update_status',
                    itemtype, itemkey,'Unexpected Error!');
    RAISE;
  --
END Update_Status;

-------------------------------------------------------------------------------
--
-- Procedure
--   Approved_Update_Status(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Approved_Update_Status(itemtype        IN varchar2,
                                 itemkey         IN varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       out nocopy varchar2    )
IS
l_approved_status        VARCHAR(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);

BEGIN

    l_approved_status      := wf_engine.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'NEW_STATUS_ID' );

	WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>   l_approved_status  );

	Update_Status(itemtype => itemtype,
                   itemkey => itemkey,
                     actid => actid,
                  funcmode => funcmode,
                 resultout => resultout);
EXCEPTION

     WHEN OTHERS THEN

        wf_core.context('AHL_GENERIC_APRV_PVT',
                        'Approved_Update_Status',
                        itemtype, itemkey,to_char(actid),'Unexpected Error!');
    RAISE;
  --

END Approved_Update_Status;

-------------------------------------------------------------------------------
--
-- Procedure
--   Reject_Update(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Rejected_Update_Status(itemtype      IN varchar2,
                        itemkey              IN varchar2,
                        actid                in  number,
                        funcmode             in  varchar2,
                        resultout            out nocopy varchar2    )
IS
l_rejected_status        VARCHAR(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);

BEGIN

    l_rejected_status      := wf_engine.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'REJECT_STATUS_ID' );

	WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>   l_rejected_status  );

	Update_Status(itemtype => itemtype,
                   itemkey => itemkey,
                     actid => actid,
                  funcmode => funcmode,
                 resultout => resultout);
EXCEPTION

     WHEN OTHERS THEN

        wf_core.context('AHL_GENERIC_APRV_PVT',
                        'Rejected_Update_Status',
                        itemtype, itemkey,to_char(actid),'Unexpected Error!');
    RAISE;
  --

END Rejected_Update_Status;
-------------------------------------------------------------------------------
--
-- Procedure
--   Revert_Status(itemtype       in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Revert_Status(itemtype        IN varchar2,
                        itemkey         IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       out nocopy varchar2    )
IS
dml_str              varchar2(2000);
l_pkg_name           varchar2(80);
l_proc_name          varchar2(80);
l_approval_type	     varchar2(80);
l_object             varchar2(30);
l_msg_data           VARCHAR2(4000);
l_msg_count          number;
l_error_msg          VARCHAR2(4000);
l_return_stat		 varchar2(1);
BEGIN
    FND_MSG_PUB.initialize();
    l_object      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'OBJECT_TYPE' );

    l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_object, 'REVERT_STATUS',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

	  if (l_return_stat = fnd_api.g_ret_sts_success) then
			dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
			EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey,IN actid,IN funcmode, OUT resultout;
	else
        RAISE FND_API.G_EXC_ERROR;
    end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )                ;
             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'Revert_Status',
                 itemtype, itemkey,l_error_msg);
         RAISE;
     WHEN OTHERS THEN

             wf_core.context('AHL_GENERIC_APRV_PVT',
                    'REVERT_STATUS',
                    itemtype, itemkey,'Unexpected Error!');
    RAISE;
  --
END Revert_Status;


/*****************************************************************
-- Helper APIs
*****************************************************************/

/*==============================================================================================*/

-- Start of Comments
-- NAME
--  Get_Approval_Details
-- PURPOSE
--   This Procedure get all the approval details
--
-- Used By Objects
-- p_object                  Objects(Route, MC .. )
-- p_approval_type           CONCEPT
-- p_object_details          Object details contains the detail of objects
-- x_approval_rule_id        Approval detail Id macthing the criteria
-- x_approver_seq            Approval Sequence
-- x_return_status           Return Status
-- NOTES
-- HISTORY
-- 1. Reema : Added Application Usage Logic (18/09/2003)
-- End of Comments
/*****************************************************************/

PROCEDURE Get_Approval_Details
  ( p_object               IN   VARCHAR2,
    p_approval_type        IN   VARCHAR2,
    p_object_details       IN  ObjRecTyp,
    x_approval_rule_id     OUT NOCOPY  NUMBER,
    x_approver_seq         OUT NOCOPY  NUMBER,
    x_return_status        OUT NOCOPY  VARCHAR2)
IS

	l_operating_unit_id   NUMBER           :=1; --default value
	l_priority            VARCHAR2(30)     :=' ';---default value
	l_approval_type_code  VARCHAR2(30)     := ' ';
	l_approver_id         NUMBER;
	l_object_details      ObjRecTyp;
	l_object              VARCHAR2(30);
	l_object_id           NUMBER;
        l_seeded_flag         varchar2(1);
	l_application_usg_code varchar2(30)    := 'AHL';

 -- Get Approval Detail Id matching the Criteria
 -- Approval Object (CAMP, DELV.. ) is mandatory
 -- Approval type   (BUDGET    .. ) is mandatory

	CURSOR c_approval_rule_id IS
	SELECT approval_rule_id, seeded_flag
	FROM ahl_approval_rules_b
	WHERE nvl(operating_unit_id,l_operating_unit_id)  = l_operating_unit_id
	AND approval_object_code                          = p_object
	AND nvl(approval_type_code, l_approval_type_code) = l_approval_type_code
	AND nvl(approval_priority_code,l_priority)        = l_priority
	AND seeded_flag                                   = 'N'
	AND nvl(application_usg_code, l_application_usg_code) = l_application_usg_code
	AND status_code                                   = 'ACTIVE'
	and sysdate between nvl(active_start_date,sysdate -1 ) and nvl(active_end_date,sysdate + 1)
   	order by  (power(2,decode(operating_unit_id,'',0,2)) +
               power(2,decode(approval_priority_code,'',0,1)  )) desc ;

  -- If the there are no matching records it takes the default Rule
  CURSOR c_default_rule IS
  SELECT approval_rule_id, seeded_flag
    FROM ahl_approval_rules_b
   WHERE seeded_flag = 'Y'
   AND nvl(application_usg_code, l_application_usg_code) = l_application_usg_code;

  -- Takes Min Approver Sequence From Ahl_approvers Once matching records are
  -- Found form ahl_approval_rules_b
  CURSOR c_approver_seq IS
  SELECT min(approver_sequence)
    FROM ahl_approvers
   WHERE approval_rule_id  = x_approval_rule_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_operating_unit_id    := nvl(p_object_details.operating_unit_id, l_operating_unit_id);
  l_priority             := nvl(p_object_details.priority, l_priority);
  l_application_usg_code := nvl(p_object_details.application_usg_code, 'AHL');
  l_approval_type_code := nvl(p_approval_type, l_approval_type_code);

-- Get Approval Rule ID
	OPEN  c_approval_rule_id ;
	FETCH c_approval_rule_id INTO x_approval_rule_id, l_seeded_flag;

	IF c_approval_rule_id%NOTFOUND THEN
		CLOSE c_approval_rule_id;

       -- Get Default Rule ID if no rule has been defined for the given combination of qualifiers
        OPEN c_default_rule;
		FETCH c_default_rule INTO x_approval_rule_id, l_seeded_flag;

		IF c_default_rule%NOTFOUND THEN
			CLOSE c_default_rule ;

			FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_RULE_ID');
			FND_MSG_PUB.Add;

			x_return_status := FND_API.G_RET_STS_ERROR;
			return;

		END IF;
		CLOSE c_default_rule;
	ELSE
		CLOSE c_approval_rule_id;
	END IF;

-- Get Approver Sequence with Approval Rule ID

	OPEN  c_approver_seq  ;
	FETCH c_approver_seq INTO x_approver_seq ;

	--IF c_approver_seq%NOTFOUND THEN
        IF x_approver_seq is null THEN
		CLOSE c_approver_seq;

		FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_SEQ');
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;

		return;

	END IF;

	CLOSE c_approver_seq;

END Get_Approval_Details;

-------------------------------------------------------------------------------
--
-- Gets approver info
-- Approvers Can be user or Role
-- If it is role it should of role_type AHLAPPR or AHLGAPPR
-- The Seeded role is AHL_DEFAULT_APPROVER
--
-------------------------------------------------------------------------------
PROCEDURE Get_Approver_Info
  ( p_rule_id              IN  NUMBER,
    p_current_seq          IN   NUMBER,
    x_approver_id          OUT NOCOPY  VARCHAR2,
    x_approver_type        OUT NOCOPY  VARCHAR2,
    x_object_approver_id   OUT NOCOPY  VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2)
IS
	l_count              number;
	l_pkg_name           VARCHAR2(80);
	l_proc_name          VARCHAR2(80);
	dml_str              VARCHAR2(2000);
	x_msg_count          NUMBER;
	x_msg_data           VARCHAR2(2000);

	CURSOR c_approver_info IS
	SELECT  approval_approver_id,
			approver_type_code,
			approver_id
	FROM ahl_approvers
	WHERE approval_rule_id = p_rule_id
	AND approver_sequence  = p_current_seq;

	CURSOR c_role_info IS
	SELECT rr.ROLE_RESOURCE_ID
	FROM JTF_RS_ROLE_RELATIONS rr, JTF_RS_ROLES_B rb
	WHERE rr.role_id = rb.role_id
	AND rb.role_type_code in( 'AHLGAPPR','AHLAPPR')
	AND rr.ROLE_ID   = x_object_approver_id
	AND rr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND rr.delete_flag = 'N'
	and sysdate between nvl(rr.start_date_active,sysdate -1 ) and nvl(rr.end_date_active,sysdate + 1);

	CURSOR c_role_info_count IS
	SELECT count(1)
	FROM JTF_RS_ROLE_RELATIONS rr, JTF_RS_ROLES_B rb
	WHERE rr.role_id = rb.role_id
    AND rb.role_type_code in( 'AHLGAPPR','AHLAPPR')
	AND rr.ROLE_ID   = x_object_approver_id
	AND rr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND rr.delete_flag = 'N'
	and sysdate between nvl(rr.start_date_active,sysdate -1 ) and nvl(rr.end_date_active,sysdate + 1);

	CURSOR c_default_role_info IS
	SELECT rr.role_id
	FROM jtf_rs_role_relations rr,
			jtf_rs_roles_vl rl
	WHERE rr.role_id = rl.role_id
	and  rl.role_type_code ='AHLAPPR'
	AND rl.role_code   = 'AHL_DEFAULT_APPROVER'
	AND rr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND delete_flag = 'N'
	AND sysdate between rr.start_date_active and nvl(rr.end_date_active,sysdate);

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN  c_approver_info;
	FETCH c_approver_info
	INTO x_approver_id,
    	 x_approver_type,
		 x_object_approver_id;

	IF c_approver_info%NOTFOUND THEN
		CLOSE c_approver_info;
		FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_APPROVER_ID');
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF;

	IF x_approver_type = 'ROLE' THEN
		if x_object_approver_id is null then
            -- use default approver
			OPEN  c_default_role_info ;
			FETCH c_default_role_info
			INTO x_object_approver_id;

			IF c_default_role_info%NOTFOUND THEN
				CLOSE c_default_role_info ;
				FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_DEFAULT_ROLE');
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			END IF;
			CLOSE c_default_role_info ;
		end if;

        -- More than one role found with given approver ID
		OPEN  c_role_info_count;
		FETCH c_role_info_count
		INTO l_count;
		IF l_count > 1 THEN
			CLOSE c_role_info_count;

			FND_MESSAGE.Set_Name('AHL','AHL_APRV_MORE_ROLE');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_role_info_count;

		OPEN  c_role_info;
		FETCH c_role_info
		INTO x_object_approver_id;
		IF c_role_info%NOTFOUND THEN
			CLOSE c_role_info;

			FND_MESSAGE.Set_Name('AHL','AHL_APRV_INVALID_ROLE');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_role_info;
	END IF; --x_approval_type = ROLE;

	CLOSE c_approver_info;

END Get_Approver_Info;


--------------------------------------------------------------------------------
--
-- Procedure
--    Get_Api_Name
--
---------------------------------------------------------------------------------
PROCEDURE Get_Api_Name( p_api_used_by       in  varchar2,
                        p_object            in  varchar2,
                        p_activity_type     in  VARCHAR2,
             			p_approval_type     in  VARCHAR2,
                        x_pkg_name          out nocopy varchar2,
                        x_proc_name         out nocopy varchar2,
			            x_return_status     out nocopy varchar2)
IS

	CURSOR c_API_Name IS
     SELECT package_name, procedure_name
       FROM ahl_approval_api
      WHERE api_used_by = p_api_used_by
        AND approval_object_type = p_object
        AND activity_type = p_activity_type
	    AND approval_type = p_approval_type;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c_API_Name;
	fetch c_API_Name into x_pkg_name, x_proc_name;

	if c_API_Name%NOTFOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_API');
		FND_MSG_PUB.Add;
    end if;
	close c_API_Name;

EXCEPTION

	 WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RAISE;
END Get_Api_Name;

--------------------------------------------------------------------------------
--
-- Procedure
--    Handle_Error
--
---------------------------------------------------------------------------------

PROCEDURE Handle_Error
   (p_itemtype                 IN VARCHAR2    ,
    p_itemkey                  IN VARCHAR2    ,
    p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    p_attr_name                IN VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
   )
IS
   l_msg_count            NUMBER ;
   l_msg_data             VARCHAR2(2000);
   l_final_data           VARCHAR2(4000);
   l_msg_index            NUMBER ;
   l_cnt                  NUMBER := 0 ;
BEGIN
   -- Retriveing Error Message from FND_MSG_PUB
   -- Called by most of the procedures if it encounter error

   WHILE l_cnt < p_msg_count
   LOOP
      FND_MSG_PUB.Get
        (p_msg_index       => l_cnt + 1,
         p_encoded         => FND_API.G_FALSE,
         p_data            => l_msg_data,
         p_msg_index_out   => l_msg_index )       ;

      l_final_data := l_final_data ||l_msg_index||': '
          ||l_msg_data||fnd_global.local_chr(10) ;
      l_cnt := l_cnt + 1 ;
   END LOOP ;

   x_error_msg   := l_final_data;

   WF_ENGINE.SetItemAttrText
      (itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => p_attr_name,
       avalue     => l_final_data   );


END Handle_Error;


/*****************************************************************
-- Private API Specifications
*****************************************************************/
-------------------------------------------------------------------------------
-- Start of Comments
-- NAME
--   Check_Appl_Usg_Code
--
-- PURPOSE
--   This Procedure will validate the
--   application usage code
-- Called By
-- NOTES
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Check_Appl_Usg_Code(
	p_appl_usg_code IN  VARCHAR2,
	x_return_status      OUT NOCOPY VARCHAR2
)
IS
 l_count   NUMBER;

 CURSOR chk_appl_usg_code IS
    SELECT 1 FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE'
    AND LOOKUP_CODE = p_appl_usg_code;
BEGIN
      OPEN chk_appl_usg_code;
      FETCH chk_appl_usg_code INTO l_count;
	IF chk_appl_usg_code%NOTFOUND THEN
          CLOSE chk_appl_usg_code;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
		Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_INVALID');
		  Fnd_Msg_Pub.ADD;
          END IF;
	         x_return_status := Fnd_Api.g_ret_sts_error;
	         RETURN;
        ELSE
          CLOSE chk_appl_usg_code;
        END IF;
END Check_Appl_Usg_Code;
-------------------------------------------------------------------------------
-- Start of Comments
-- NAME
--   Get_User_Role
--
-- PURPOSE
--   This Procedure will return the User role for
--   the resource id sent
-- Called By
-- NOTES
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_User_Role(
	p_resource_id            IN     NUMBER,
	x_role_name          OUT NOCOPY    VARCHAR2,
	x_role_display_name  OUT NOCOPY    VARCHAR2 ,
	x_return_status      OUT NOCOPY    VARCHAR2)
IS
	l_person_id          number;

	CURSOR c_resource IS
	SELECT employee_id source_id
	FROM ahl_jtf_rs_emp_v
	WHERE resource_id = p_resource_id ;

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Get Employee ID
    OPEN c_resource ;
	FETCH c_resource INTO l_person_id ;

	IF c_resource%NOTFOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AHL','AHL_APRV_NO_RESOURCE');
		FND_MSG_PUB.Add;

	END IF;
	CLOSE c_resource ;

    -- Pass the Employee ID to get the Role
	WF_DIRECTORY.getrolename(
		p_orig_system       => 'PER',
		p_orig_system_id    => l_person_id ,
		p_name              => x_role_name,
		p_display_name      => x_role_display_name );

	IF x_role_name is null  then
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AHL','AHL_APRV_WF_NO_ROLE');
		FND_MSG_PUB.Add;

	END IF;

END Get_User_Role;


-------------------------------------------------------------------------------
--
-- Checks if there are more approvers required
--
-------------------------------------------------------------------------------
PROCEDURE Check_Approval_Required(
	p_rule_id            IN  NUMBER,
	p_current_seq        IN   NUMBER,
	x_next_seq           OUT NOCOPY  NUMBER,
	x_required_flag      OUT NOCOPY  VARCHAR2)
IS

	CURSOR c_check_app IS
	SELECT approver_sequence
	FROM ahl_approvers
	WHERE approval_rule_id = p_rule_id
	AND approver_sequence > p_current_seq
	order by approver_sequence  ;

BEGIN
	OPEN  c_check_app;
	FETCH c_check_app
	INTO x_next_seq;
	if c_check_app%NOTFOUND THEN
		x_required_flag    :=  FND_API.G_FALSE;
	ELSE
		x_required_flag    :=  FND_API.G_TRUE;
	END IF;
	CLOSE c_check_app;
END  Check_Approval_Required;

END ahl_generic_aprv_pvt;

/
