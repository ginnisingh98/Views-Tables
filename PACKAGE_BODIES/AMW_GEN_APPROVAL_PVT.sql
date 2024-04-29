--------------------------------------------------------
--  DDL for Package Body AMW_GEN_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_GEN_APPROVAL_PVT" as
/* $Header: amwvgapb.pls 120.0 2005/05/31 20:42:23 appldev noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'amw_gen_approval_pvt';
g_file_name    CONSTANT VARCHAR2 (15) := 'amwvgapb.pls' ;
G_ITEMTYPE     CONSTANT varchar2(30) := 'AMWGAPP';

/***************************  PRIVATE ROUTINES  *******************************/
-------------------------------------------------------------------------------
-- Start of Comments
-- NAME
--   Get_User_Role
--
-- PURPOSE
--   This Procedure will be return the User role for
--   the userid sent
-- Called By
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--   6/12/2003        KARTHI MUTHUSWAMY Modified the procedure to obtain the role name
--                              and role display name based on FND User Id.
--   6/25/2003        KARTHI MUTHUSWAMY Modified the procedure to obtain the Employee Id
--                              from FND_USER.USER_ID
--   06/30/2003      KARTHI MUTHUSWAMY Changed p_workflowprocess to p_workflow_process
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_User_Role(
   p_user_id            IN     NUMBER,
   x_role_name          OUT NOCOPY    VARCHAR2,
   x_role_display_name  OUT NOCOPY    VARCHAR2 ,
   x_return_status      OUT NOCOPY    VARCHAR2) IS
l_employee_id   FND_USER.EMPLOYEE_ID%TYPE ;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
   -- The parameter p_user_id is the FND_USER.USER_ID
   -- Get the Person Id (which is the Employee Id) for this USER_ID
   begin
      select   employee_id
      into   l_employee_id
      from   FND_USER
      where   user_id   = p_user_id ;
   exception
      when   no_data_found
      then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('AMW','AMW_APPR_INVALID_ROLE');
         FND_MSG_PUB.Add;

         return ;
   end ;
*/

   -- Pass the Employee Id (which is Person Id) to get the Role
   WF_DIRECTORY.getrolename(
      p_orig_system      => 'PER',
      p_orig_system_id   => p_user_id ,
      p_name         => x_role_name,
      p_display_name      => x_role_display_name );

   IF x_role_name is null
   then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('AMW','AMW_APPR_INVALID_ROLE');
      FND_MSG_PUB.Add;
   END IF;
END Get_User_Role;
-------------------------------------------------------------------------------
--
-- Checks gets the person id
--
-------------------------------------------------------------------------------

PROCEDURE get_person_id(
   p_user_id           IN   NUMBER,
   x_person_id         OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY  VARCHAR2)
IS
   CURSOR c_person_id IS
      select   employee_id
      from   FND_USER
      where   user_id   = p_user_id  ;
   -- Obtain and populate the Role Name and Display Name from the USER ID
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN c_person_id ;
   FETCH c_person_id INTO x_person_id ;
   CLOSE c_person_id;
exception
      when   no_data_found
      then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('AMW','AMW_APPR_INVALID_ROLE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
end ;


-------------------------------------------------------------------------------
--
-- Checks if there are more approvers
--
-------------------------------------------------------------------------------
PROCEDURE Check_Approval_Required(
   p_OBJECT_type    IN  VARCHAR2,
   p_OBJECT_id           IN   NUMBER,
   x_required_flag         OUT NOCOPY  VARCHAR2)
IS


BEGIN

   x_required_flag    :=  FND_API.G_TRUE;

END  Check_Approval_Required;

-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--   HANDLE_ERR
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--   set it to the workflow error message attribute
--   It also sets the subject for the generic error message wf attribute
--   The generic error message body wf attribute is set in the
--   ntf_requestor_of_error procedure
--
-- NOTES
--
-- End of Comments
-------------------------------------------------------------------------------

PROCEDURE Handle_Err
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
   l_appr_meaning         VARCHAR2(240);
   l_appr_obj_name        VARCHAR2(240);
   l_gen_err_sub          VARCHAR2(240);
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
   --
   l_appr_meaning       := wf_engine.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AMW_APPROVAL_OBJECT_MEANING');

   l_appr_obj_name      := wf_engine.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AMW_APPROVAL_OBJECT_NAME');
   --
   fnd_message.set_name ('AMW', 'AMW_GEN_NTF_ERROR_SUB');
   fnd_message.set_token ('OBJ_MEANING', l_appr_meaning, FALSE);
   fnd_message.set_token ('OBJ_NAME', l_appr_obj_name, FALSE);

   l_gen_err_sub  := SUBSTR(fnd_message.get,1,240);

   Wf_Engine.SetItemAttrText
      (itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => 'ERR_SUBJECT',
       avalue     => l_gen_err_sub );
END Handle_Err;

/*****************************************************************
-- Start of Comments
-- NAME
--   StartProcess
-- PURPOSE
--   This Procedure will Start the flow
--
-- Used By Objects
-- p_OBJECT_type                     OBJECT Type or Objects
--                                     (CAMP,DELV,EVEO,EVEH .. )
-- p_OBJECT_id                       Primary key of the Object
-- p_approval_type                     BUDGET,CONCEPT
-- p_OBJECT_version_number             Object Version Number
-- p_orig_stat_id                      The status to which is
--                                     to be reverted if process fails
-- p_new_stat_id                       The status to which it is
--                                     to be updated if the process succeeds
-- p_reject_stat_id                    The status to which is
--                                     to be updated if the process fails
-- p_requestor_userid                  The requestor who has submitted the
--                                     process
-- p_notes_from_requestor              Notes from the requestor
-- p_workflow_process                   Name of the workflow process
--                                     AMW_CONCEPT_APPROVAL -- For Concept
--                                     AMW_APPROVAL -- For Budget Approvals
-- p_item_type                         AMWGAPP
-- NOTES
-- Item key generated as combination of OBJECT Type, OBJECT Id, and Object
-- Version Number.
-- For ex. RISK100007 where 7 is OBJECT version number and 10000 OBJECT id
-- HISTORY
--  5/28/2003          mpande       CREATED
-- End of Comments
*****************************************************************/

PROCEDURE StartProcess
           (p_OBJECT_type          IN   VARCHAR2,
            p_OBJECT_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2 DEFAULT NULL ,
            p_OBJECT_version_number  IN   NUMBER,
            p_requestor_userid       IN   NUMBER,
            p_workflow_process        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
            p_gen_process_flag       IN   VARCHAR2   DEFAULT NULL,
            x_return_status out nocopy varchar2,
            x_msg_count out nocopy number,
            x_msg_data out nocopy varchar2

             )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'start_Process';
   itemtype                 VARCHAR2(30) := nvl(p_item_type,'AMWGAPP');
   itemkey                  VARCHAR2(30) := p_approval_type||p_OBJECT_type||p_OBJECT_id||
                                             p_OBJECT_version_number;
   itemuserkey              VARCHAR2(80) := p_OBJECT_type||p_OBJECT_id||
                                             p_OBJECT_version_number;

   l_requestor_role         VARCHAR2(320) ;  -- Changed from VARCHAR2(100)
   l_role_display_name      VARCHAR2(360) ;  -- Changed from VARCHAR2(240);
   l_requestor_id           NUMBER ;
   l_employee_id            NUMBER ;
   l_appr_for               VARCHAR2(240) ;
   l_appr_meaning           VARCHAR2(240);
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_error_msg              VARCHAR2(4000);
   l_index                  NUMBER;
   l_save_threshold         NUMBER := wf_engine.threshold;

   ---npanandi added this for timeout profile value.
   l_timeout_profile        NUMBER;


   CURSOR c_resource IS
   SELECT 1 -- resource_id ,employee_id source_id,full_name resource_name change
   FROM dual ;
--   WHERE user_id = x_resource_id ; need to change
BEGIN
   --FND_MSG_PUB.initialize();
   savepoint start_process ;
   x_return_status := FND_API.g_ret_sts_success;

   AMW_Utility_PVT.debug_message('Start :Item Type : '||itemtype
                         ||' Item key : '||itemkey);

    -- wf_engine.threshold := -1;
   WF_ENGINE.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflow_process);

   WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);

   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/



   -- OBJECT Type  (Some of valid values are 'RISK, 'CTRL', etc.,,);
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMW_OBJECT_TYPE',
                             avalue     =>   p_OBJECT_type  );

   -- OBJECT ID  (primary Id of OBJECT Object)
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'AMW_OBJECT_ID',
                               avalue    =>  p_OBJECT_id  );

   ---npanandi added 10/20/2004 to set timeout variable
   /*
   l_timeout_profile := NVL(fnd_profile.VALUE ('AMW_DELT_CTRL_INTF'), 'N');
   INSTEAD OF HARDCODING THE TIMEOUT ATTRIBUTE VALUE, LOOK IT UP FROM THE BELOW
   PROFILE AND SET THE ATTRIBUTE VALUE ACCORDINGLY
   ACCORDING TO WORKFLOW DOCUMENTATION
   'A null timeout value or a value of zero means no timeout.' --> FOR THOSE
   CUSTOMERS THAT DO NOT WANT TIMEOUT AT ALL, THEY MAY SET THIS VALUE TO BE NULL
   */
   l_timeout_profile := fnd_profile.VALUE ('AMW_APPROVAL_TIMEOUT_VALUE');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'L_TIMEOUT_PROFILE IN DAYS: '||L_TIMEOUT_PROFILE);
   IF(L_TIMEOUT_PROFILE IS NOT NULL) THEN
      ---CONVERT THE PROFILE VALUE FROM DAYS TO MINUTES
      L_TIMEOUT_PROFILE := (L_TIMEOUT_PROFILE) * 1440;
   END IF;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'L_TIMEOUT_PROFILE IN MINUTES: '||L_TIMEOUT_PROFILE);
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'AMW_NOTIFICATION_TIMEOUT',
                               avalue    =>  l_timeout_profile);
   ---npanandi ended

   -- Object Version Number
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMW_OBJECT_VERSION_NUMBER',
                               avalue    =>  p_OBJECT_version_number  );
/*
   -- Notes from the requestor
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'AMW_NOTES_FROM_REQUESTOR',
                             avalue     =>  nvl(p_notes_from_requestor,'') );
*/
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'DOCUMENT_ID',
                             avalue     =>  itemtype || ':' ||itemkey);

   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMW_REQUESTOR_ID',
                               avalue    =>  p_requestor_userid       );

   WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                            itemkey  =>  itemkey,
                            aname    =>  'AMW_APPROVAL_TYPE',
                            avalue   =>  p_approval_type  );

   l_return_status := FND_API.G_RET_STS_SUCCESS;

   get_person_id(
      p_user_id           =>p_requestor_userid,
      x_person_id         =>l_employee_id,
      x_return_status     =>l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Pass the Employee Id (which is Person Id) to get the Role
   WF_DIRECTORY.getrolename(
      p_orig_system      => 'PER',
      p_orig_system_id   => l_employee_id ,
      p_name            => l_requestor_role ,
      p_display_name      => l_role_display_name );


   WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                         itemkey     =>  itemkey,
                         aname       =>  'AMW_REQUESTOR',
                         avalue      =>  l_requestor_role  );


   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMW_GENERIC_FLAG',
                             avalue     =>   p_gen_process_flag  );

   WF_ENGINE.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requestor_role);

   -- Start the Process
   WF_ENGINE.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);

    -- wf_engine.threshold := l_save_threshold ;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO start_process;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO start_process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO start_process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

END StartProcess;

/*****************************************************************
-- Start of Comments
--
-- NAME
--   set_object_details
--
-- PURPOSE
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE Set_OBJECT_Details(itemtype     IN  VARCHAR2,
                               itemkey      IN  VARCHAR2,
                               actid        IN  NUMBER,
                               funcmode     IN  VARCHAR2,
                resultout    OUT NOCOPY VARCHAR2) IS


l_OBJECT_id           NUMBER;
l_OBJECT_type         VARCHAR2(30);
l_approval_type         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_pkg_name              varchar2(80);
l_proc_name             varchar2(80);
l_return_stat      varchar2(1);
dml_str                 VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_OBJECT_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_ID' );

     -- get the OBJECT type
     l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

     Get_Api_Name('WORKFLOW', l_OBJECT_type, 'SET_OBJECT_DETAILS', l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

     IF (l_return_stat = 'S') THEN
       dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
       EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey,IN actid,IN funcmode, OUT resultout;

      resultout := 'COMPLETE:SUCCESS';

   return ;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
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
  --

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      wf_core.context('amw_gen_approval_pvt','Set_OBJECT_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      raise;
   WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('amw_approval_pvt','Set_OBJECT_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      raise;
END Set_OBJECT_Details ;

-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  Set_Approver_Details
--
-- PURPOSE
--  This procedure will set the next approver details. These details are obtained
--  by making a call to the Approvals Manager. If the Approvals Manager does not
--  return value, the object is approved and the procedure will return with a 'COMPLETE'
--  status.
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--   6/12/2003       KARTHI MUTHUSWAMY Added code to call Approvals Manager
--   6/24/2003       KARTHI MUTHUSWAMY Added code to skip approval if profile option is set
-- End of Comments
-------------------------------------------------------------------------------

PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2 )
IS
l_OBJECT_type           VARCHAR2(80);
l_approver_id             NUMBER;
l_approver                VARCHAR2(320); -- Was VARCHAR2(100);
l_prev_approver           VARCHAR2(320); -- Was VARCHAR2(100);
l_approver_display_name   VARCHAR2(360); -- Was VARCHAR2(80)
l_notification_type       VARCHAR2(30);
l_notification_timeout    NUMBER;
l_approver_type           VARCHAR2(30);
l_role_name               VARCHAR2(100); --l_role_name  VARCHAR2(30);
l_prev_role_name          VARCHAR2(100); --l_prev_role_name VARCHAR2(30);
l_OBJECT_approver_id      NUMBER;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_error_msg               VARCHAR2(4000);
l_pkg_name                varchar2(80);
l_proc_name               varchar2(80);
l_appr_id                 NUMBER;
dml_str                   VARCHAR2(2000);
l_version                 NUMBER;
l_approval_type           VARCHAR2(30);
l_OBJECT_id             NUMBER;
l_appr_type               VARCHAR2(30);
l_obj_appr_id             NUMBER;
l_prev_approver_disp_name VARCHAR2(360);
l_note                    VARCHAR2(4000);
l_object_approval_status  VARCHAR2 (20) := null ;
l_disable_workflow     VARCHAR2 (10) ;
                                 l_nextApprover            ame_util.approverRecord;


BEGIN
   FND_MSG_PUB.initialize();
   IF (funcmode = 'RUN')
   THEN
   -- Check if the AMW_DISABLE_WORKFLOW_APPROVAL profile option is set.
   -- If it set to 'Y' skip the approval process and update the object
   -- status as "Approved"
   l_disable_workflow := fnd_profile.value( 'AMW_DISABLE_WORKFLOW_APPROVAL' ) ;

   if ( l_disable_workflow = 'Y' )
   then
      resultout := 'COMPLETE:COMPLETE' ;

      return ;
   end if ;

      l_OBJECT_id := Wf_Engine.GetItemAttrNumber(
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'AMW_OBJECT_ID' );

      l_OBJECT_type := Wf_Engine.GetItemAttrText(
                        itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'AMW_OBJECT_TYPE' );

      l_version  := Wf_Engine.GetItemAttrNumber(
                    itemtype => itemtype,
                    itemkey => itemkey,
                    aname   => 'AMW_OBJECT_VERSION_NUMBER' );

      l_approval_type := Wf_Engine.GetItemAttrText(
                        itemtype => itemtype,
                        itemkey => itemkey,
                        aname   => 'AMW_APPROVAL_TYPE' );

     -- To start with the value of AMW_APPROVER_ID item attribute will be NULL
      l_object_approver_id := wf_engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMW_APPROVER_ID' ) ;

     -- Obtain the value of UPDATE_GEN_STATUS item attribute
     -- The very first entry into this activity this value will be NULL
      l_object_approval_status := WF_ENGINE.GetItemAttrText(
                           itemtype   =>  itemtype,
                                   itemkey    =>  itemkey,
                                   aname      =>  'UPDATE_GEN_STATUS' ) ;

     -- This activity is re-visited whenever the Object is 'Approved' and
     -- needs to go up the chain for further approval

     IF ( l_object_approval_status = 'APPROVED' )
     THEN
          -- we need to call AME API to update the approver status
        AME_API.updateApprovalStatus2(
                    applicationIdIn    => 242,
                        transactionIdIn    => l_OBJECT_id,
                        approvalStatusIn   => AME_UTIL.approvedStatus,
                        approverPersonIdIn => l_object_approver_id,
                        approverUserIdIn   => NULL,
                        transactionTypeIn  => l_OBJECT_type ) ;
     END IF ;
     /*
     WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                         itemkey    =>  itemkey,
                         aname      =>  'APPROVAL_NOTE',
                         avalue     =>   'ObjInfo:' || l_OBJECT_id || l_object_type );
     */
      ame_api.getNextApprover( applicationIdIn => 242,
                      transactionIdIn => l_OBJECT_id,
                      transactionTypeIn => l_OBJECT_type,
                      nextApproverOut => l_nextapprover ) ;

      -- Check the results returned from Approvals Manager
      IF ( l_nextApprover.person_id is null ) and ( l_nextApprover.user_id is null )
         and ( l_nextApprover.approval_status is null )      THEN
         -- 2 options either, there are no more approvers in the approver list
         -- or no appprovers are returned by OAM
         -- for now, the transaction is approved
         resultout := 'COMPLETE:COMPLETE' ;

         WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                            itemkey    =>  itemkey,
                            aname      =>  'AMW_ERROR_MSG',
                            avalue     =>   'No More Approvers' );

         RETURN ;
      ELSIF ( l_nextApprover.approval_status = ame_util.exceptionStatus )    THEN
         -- an error has occurred and Approvals Manager may return the admin approver
         -- or it may just return a exception status. Write to log that there is an error

         WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                            itemkey    =>  itemkey,
                            aname      =>  'AMW_ERROR_MSG',
                            avalue     =>   'Exception Status:' || l_nextApprover.approval_status );
         resultout := 'COMPLETE:ERROR' ;

         RETURN ;
         /**********PENDING***************/
         -- Check for the person id
         -- If ( Person Id is not null ) continue
         -- If it is null check if User Id is not null and convert user id to person Id
         /**********PENDING***************/
      ELSIF ( l_nextApprover.person_id is not null )
      THEN
         -- Approvals Manager returned the next approver's person id
           l_OBJECT_approver_id := l_nextApprover.person_id ;

           WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                                itemkey    =>  itemkey,
                                aname      =>  'UPDATE_GEN_STATUS',
                                avalue     =>   'APPROVED'  );
           WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                itemkey    =>  itemkey,
                aname      =>  'AMW_ERROR_MSG',
                avalue     =>   'Got Person Id:' || l_OBJECT_approver_id );

      ELSIF ( l_nextApprover.user_id is not null )
      THEN
         -- Approvals Manager returned the next approver's user id
            l_OBJECT_approver_id := l_nextApprover.user_id ;
            WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                                itemkey    =>  itemkey,
                                aname      =>  'UPDATE_GEN_STATUS',
                                avalue     =>   'APPROVED'  );

            get_person_id(
               p_user_id           =>l_nextApprover.user_id,
               x_person_id         =>l_OBJECT_approver_id,
               x_return_status     =>l_return_status);

            WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                   itemkey    =>  itemkey,
                   aname      =>  'AMW_ERROR_MSG',
                   avalue     =>   'Got User Id:' || l_OBJECT_approver_id );
      END IF ;

      Get_User_Role(p_user_id       => l_OBJECT_approver_id, -- the person id
             x_role_name            => l_approver,
             x_role_display_name    => l_approver_display_name,
             x_return_status        => l_return_status ) ;

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF ;

   -- Get the current approver's display name, person who just approved the object
      l_prev_approver_disp_name  := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVER_DISPLAY_NAME' );

   -- Set the person who currently approved to previous approver display name
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'AMW_PREV_APPROVER_DISP_NAME',
                        avalue   => l_prev_approver_disp_name);

   -- Get the current approver's approval note
      l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_NOTE');

   -- Set the current approver's notes to previous approval note
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'AMW_PREV_APPROVER_NOTE',
                        avalue   => l_note);

   -- Clear the value in approval note so that the next approval does not see the previous values
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVAL_NOTE',
                                    avalue   => null);

   -- Set the next approver's display name obtained from Get_User_Role()
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMW_APPROVER_DISPLAY_NAME',
                                    avalue   => l_approver_display_name);

   -- Set the next approver's role name obtained from Get_User_Role()
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMW_APPROVER',
                                    avalue   => l_approver);

   -- Set the next approver's id obtained from Get_User_Role()
      wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMW_APPROVER_ID',
                                    avalue   => l_OBJECT_approver_id);

      resultout := 'COMPLETE:SUCCESS';

   return ;
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
      Handle_Err
         (p_itemtype          => itemtype   ,
         p_itemkey           => itemkey    ,
         p_msg_count         => l_msg_count, -- Number of error Messages
         p_msg_data          => l_msg_data ,
         p_attr_name         => 'AMW_ERROR_MSG',
         x_error_msg         => l_error_msg
      );
      wf_core.context('amw_gen_approval_pvt',
           'set_approval_rules',
           itemtype, itemkey,to_char(actid),l_error_msg);
      resultout := 'COMPLETE:ERROR';
   --RAISE;
   WHEN OTHERS THEN
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => l_msg_count,
         p_data  => l_msg_data
      );
      Handle_Err
         (p_itemtype          => itemtype   ,
         p_itemkey           => itemkey    ,
         p_msg_count         => l_msg_count, -- Number of error Messages
         p_msg_data          => l_msg_data ,
         p_attr_name         => 'AMW_ERROR_MSG',
         x_error_msg         => l_error_msg
      )               ;
      wf_core.context('amw_gen_approval_pvt',
              'set_approver_details',
              itemtype, itemkey,to_char(actid),l_error_msg);
   RAISE;
END;
/*
-------------------------------------------------------------------------------
--
-- Set_Further_Approvals
--
-------------------------------------------------------------------------------

PROCEDURE Set_Further_Approvals( itemtype        in  varchar2,
                                 itemkey         in  varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       OUT NOCOPY varchar2 )
IS
l_current_seq             NUMBER;
l_next_seq                NUMBER;
l_approval_detail_id      NUMBER;
l_required_flag           VARCHAR2(1);
l_approver_id             NUMBER;
l_note                    VARCHAR2(4000);
l_all_note                VARCHAR2(4000);
l_OBJECT_type           VARCHAR2(30);
l_OBJECT_id             NUMBER;
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_return_status           VARCHAR2(1);
l_error_msg               VARCHAR2(4000);
-- 11.5.9
l_version                 NUMBER;
l_approval_type           VARCHAR2(30);

BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     l_approval_detail_id := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVAL_DETAIL_ID' );

     l_current_seq        := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVER_SEQ' );

     l_approver_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVER_ID' );

     l_OBJECT_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_ID' );

     l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

      -- Added for 11.5.9
      -- Bug 2535600
     wf_engine.SetItemAttrText(  itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVAL_DATE',
                                 avalue   => trunc(sysdate));

     l_version            := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMW_OBJECT_VERSION_NUMBER' );

     l_approval_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMW_APPROVAL_TYPE' );

     l_note               := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'APPROVAL_NOTE' );


     Check_Approval_Required
             ( p_approval_detail_id       => l_approval_detail_id,
               p_current_seq              => l_current_seq,
               x_next_seq                 => l_next_seq,
               x_required_flag            => l_required_flag);
     IF l_next_seq is not null THEN
          wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMW_APPROVER_SEQ',
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
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'set_further_approvals',
                    itemtype, itemkey,to_char(actid),l_error_msg);
         RAISE;
WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'set_further_approvals',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
  --

END;
*/
-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  Revert_Status
--
-- PARAMETERS
--           itemtype     (varchar2)
--          itemkey     (varchar2)
--          actid        (number)
--          funcmode     (number)
--          reultout     (varchar2)
-- PURPOSE
--  This procedure is called from the "Revert Object Status" function activity.
--   It sets the 'UPDATE_GEN_STATUS' item attribute to "ERROR" and calls
--   Update_Status().
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--    6/17/2003       KARTHI MUTHUSWAMY Added comments
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2    )
IS
   l_OBJECT_id            NUMBER;
   l_OBJECT_type          VARCHAR2(30);
   l_orig_status_id         NUMBER;
   l_return_status          varchar2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_error_msg              VARCHAR2(4000);
   l_version                NUMBER;
   l_approval_type          VARCHAR2(30);
BEGIN
   FND_MSG_PUB.initialize();
  --
  -- RUN mode
  --
   IF (funcmode = 'RUN') THEN
     -- get the object id
     l_OBJECT_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_ID' );
     -- get the OBJECT type
     l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

     l_version            := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_VERSION_NUMBER' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

                         /*
     l_orig_status_id     := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_ORIG_STAT_ID' );
                         */

     Wf_Engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'UPDATE_GEN_STATUS',
                               avalue   => 'ERROR');

     Update_Status(itemtype      => itemtype,
                   itemkey       => itemkey,
                   actid         => actid,
                   funcmode      => funcmode,
                   resultout     => resultout);

     IF resultout = 'COMPLETE:ERROR' then

        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           );
     END IF;

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
  --

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data
      );
      Handle_Err
      (p_itemtype          => itemtype   ,
       p_itemkey           => itemkey    ,
       p_msg_count         => l_msg_count, -- Number of error Messages
       p_msg_data          => l_msg_data ,
       p_attr_name         => 'AMW_ERROR_MSG',
       x_error_msg         => l_error_msg
      );
      wf_core.context('amw_gen_approval_pvt',
                 'Revert_Status',
                 itemtype, itemkey,to_char(actid),l_error_msg);
       resultout := 'COMPLETE:ERROR';
      --RAISE;
   WHEN OTHERS THEN
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
       );
      Handle_Err
       (p_itemtype          => itemtype   ,
        p_itemkey           => itemkey    ,
        p_msg_count         => l_msg_count, -- Number of error Messages
        p_msg_data          => l_msg_data ,
        p_attr_name         => 'AMW_ERROR_MSG',
        x_error_msg         => l_error_msg
        )               ;
      wf_core.context('amw_gen_approval_pvt',
                 'Revert_status',
                 itemtype, itemkey,to_char(actid),l_error_msg);
   RAISE;
END Revert_Status;

/*****************************************************************
-- Start of Comments
--
-- NAME
--   AbortProcess
-- PURPOSE
--   This Procedure will abort the process of Approvals
-- Used By Activities
--
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE AbortProcess
             (p_itemkey                       IN   VARCHAR2
             ,p_workflow_process               IN   VARCHAR2      DEFAULT NULL
             ,p_itemtype                      IN   VARCHAR2      DEFAULT NULL
             )
IS
    itemkey   VARCHAR2(30) := p_itemkey ;
    itemtype  VARCHAR2(30) := nvl(p_itemtype,'AMW_APPROVAL') ;
BEGIN
   AMW_Utility_PVT.debug_message('Process Abort Process');
   WF_ENGINE.AbortProcess (itemtype   =>   itemtype,
                           itemkey    =>  itemkey ,
                           process    =>  p_workflow_process);
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('amw_gen_approval_pvt',
                      'AbortProcess',
                      itemtype,
                      itemkey
                      ,p_workflow_process);
         RAISE;
END AbortProcess;


--------------------------------------------------------------------------------
--
-- Procedure
--    Get_Api_Name
--
---------------------------------------------------------------------------------
PROCEDURE Get_Api_Name( p_rule_used_by        in  varchar2,
                        p_rule_used_by_type   in  varchar2,
                        p_rule_type           in  VARCHAR2,
                        p_appr_type           in  VARCHAR2,
                        x_pkg_name            OUT NOCOPY varchar2,
                        x_proc_name           OUT NOCOPY varchar2,
              x_return_stat         OUT NOCOPY varchar2)
IS
   CURSOR c_API_Name(rule_used_by_in      IN VARCHAR2,
                          rule_used_by_type_in IN VARCHAR2,
                          rule_type_in         IN VARCHAR2,
                          appr_type_in         IN VARCHAR2) is
     SELECT package_name, procedure_name
       FROM amw_OBJECT_rules
      WHERE rule_used_by = rule_used_by_in
        AND object_type = rule_used_by_type_in
        AND rule_type = rule_type_in
   AND nvl(APPROVAL_TYPE, 'N') = nvl(appr_type_in, 'N');

BEGIN
   x_return_stat := 'S';
   open c_API_Name(p_rule_used_by, p_rule_used_by_type,p_rule_type,p_appr_type);
   fetch c_API_Name into x_pkg_name, x_proc_name;
   IF c_API_Name%NOTFOUND THEN
      x_return_stat := 'E';
   END IF;
   close c_API_Name;
EXCEPTION
        -- This exception will never be raised
   --WHEN NO_DATA_FOUND THEN
   --  x_return_stat := 'E';
    WHEN OTHERS THEN
     x_return_stat := 'U';
   RAISE;
END Get_Api_Name;


--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type       in OUT NOCOPY varchar2    )
IS
   l_pkg_name  varchar2(80);
   l_proc_name varchar2(80);
   l_return_stat            varchar2(1);
   l_OBJECT_type    varchar2(80);
   l_approval_type   varchar2(80);
   l_msg_data              VARCHAR2(4000);
   l_msg_count          number;
   l_error_msg             VARCHAR2(4000);
   dml_str  varchar2(2000);
   l_itemType varchar2(80);
   l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

  l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   Get_Api_Name('WORKFLOW',
                l_OBJECT_type,
                'NTF_APPROVAL',
                l_approval_type,
                l_pkg_name,
                l_proc_name,
                l_return_stat);

   if (l_return_stat = 'S') then
      dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
   end if;
   /*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'Reject_OBJECT_status',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
 */
END Ntf_Approval;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval_reminder(itemtype     in  varchar2,
--                itemkey         in  varchar2,
--                p_OBJECT_type   in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval_reminder(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type       in OUT NOCOPY varchar2    )
IS
   l_pkg_name      varchar2(80);
   l_proc_name     varchar2(80);
   l_return_stat   varchar2(1);
   l_OBJECT_type varchar2(80);
   l_approval_type   varchar2(80);
   l_msg_data      VARCHAR2(4000);
   l_msg_count     number;
   l_error_msg     VARCHAR2(4000);
   dml_str         varchar2(2000);
   l_itemType      varchar2(80);
   l_itemKey       varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

   l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   Get_Api_Name('WORKFLOW',
                 l_OBJECT_type,
                 'NTF_APPROVAL_REMINDER',
                 l_approval_type,
                 l_pkg_name,
                 l_proc_name,
                 l_return_stat);
   if (l_return_stat = 'S') then
      dml_str := 'BEGIN ' ||  l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
   end if;
   /*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'Ntf_Approval_reminder',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Approval_reminder;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Forward_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                p_OBJECT_type   in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Forward_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type       in OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat            varchar2(1);
l_OBJECT_type    varchar2(80);
l_approval_type   varchar2(80);
l_msg_data              VARCHAR2(4000);
l_msg_count          number;
l_error_msg             VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

  l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   Get_Api_Name('WORKFLOW',
                l_OBJECT_type,
                'NTF_FORWARD_FYI',
                l_approval_type,
                l_pkg_name,
                l_proc_name,
                l_return_stat);
   if (l_return_stat = 'S') then
      dml_str := 'BEGIN '|| l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
   end if;

   /*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'Ntf_Forward_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Forward_FYI;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approved_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approved_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type         in OUT NOCOPY varchar2    )
IS
   l_pkg_name    varchar2(80);
   l_proc_name   varchar2(80);
   l_return_stat varchar2(1);
   l_OBJECT_type    varchar2(80);
   l_approval_type      varchar2(80);
   l_msg_data         VARCHAR2(4000);
   l_msg_count        number;
   l_error_msg        VARCHAR2(4000);
   dml_str  varchar2(2000);
   l_itemType varchar2(80);
   l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

  l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   Get_Api_Name('WORKFLOW',
                 l_OBJECT_type,
                 'NTF_APPROVED_FYI',
                 l_approval_type,
                 l_pkg_name,
                 l_proc_name,
                 l_return_stat);
   if (l_return_stat = 'S') then
      dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
   end if;

   /*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'Ntf_Approved_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
   */
END Ntf_Approved_FYI;

-------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Rejected_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type       in OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat varchar2(1);
l_OBJECT_type    varchar2(80);
l_approval_type   varchar2(80);
l_msg_data VARCHAR2(4000);
l_msg_count number;
l_error_msg VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

  l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   Get_Api_Name('WORKFLOW',
                l_OBJECT_type,
                'NTF_REJECTED_FYI',
                l_approval_type,
                l_pkg_name,
                l_proc_name,
                l_return_stat);

   if (l_return_stat = 'S') then
      dml_str := 'BEGIN '|| l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
   end if;

/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMW_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('amw_gen_approval_pvt',
                    'Ntf_Rejected_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Rejected_FYI;
-------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Requestor_Of_Error (itemtype    in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
--  If uptaking functionality has an API registered for handling error, that API is
--  used to generate the error message content. If not, this API generates a less
--  meaningful message which will notify the requestor of an error
---------------------------------------------------------------------------------
PROCEDURE Ntf_Requestor_Of_Error(document_id   in     varchar2,
                                 display_type  in     varchar2,
                                 document      in OUT NOCOPY varchar2,
                                 document_type in OUT NOCOPY varchar2 )
IS
   l_pkg_name         varchar2(80);
   l_proc_name        varchar2(80);
   l_return_stat      varchar2(1);
   l_OBJECT_type    varchar2(80);
   l_approval_type      varchar2(80);
   l_msg_data         VARCHAR2(10000);
   l_msg_count        number;
   l_error_msg        VARCHAR2(4000);
   dml_str            varchar2(2000);
   l_appr_meaning     varchar2(240);
   l_appr_obj_name    varchar2(240);
   l_itemType         varchar2(80);
   l_itemKey          varchar2(80);
   l_body_string      varchar2(2500);
   l_errmsg           varchar2(4000);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMWGAPP');
   l_itemKey  := substr(document_id, instr(document_id,':')+1);

   l_OBJECT_type      := wf_engine.GetItemAttrText(
                           itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'AMW_OBJECT_TYPE' );

   l_approval_type      := wf_engine.GetItemAttrText(
                           itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'AMW_APPROVAL_TYPE' );

   l_appr_meaning       := wf_engine.GetItemAttrText(
                           itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'AMW_APPROVAL_OBJECT_MEANING');

   l_appr_obj_name      := wf_engine.GetItemAttrText(
                           itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           aname    => 'AMW_APPROVAL_OBJECT_NAME');


   Get_Api_Name('WORKFLOW',
                 l_OBJECT_type,
                 'NTF_ERROR',
                 l_approval_type,
                 l_pkg_name,
                 l_proc_name,
                 l_return_stat);
   if (l_return_stat = 'S') then
      dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
      EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;

   elsif (l_return_stat = 'E') THEN -- no data found, generate a generic message

      l_errmsg := wf_engine.GetItemAttrText(
                   itemtype => l_itemtype,
                   itemkey  => l_itemkey,
                   aname    => 'AMW_ERROR_MSG');
      fnd_message.set_name ('AMW', 'AMW_GEN_NTF_ERROR_BODY');
      fnd_message.set_token ('OBJ_MEANING', l_appr_meaning, FALSE);
      fnd_message.set_token ('OBJ_NAME', l_appr_obj_name, FALSE);
      fnd_message.set_token ('ERR_MSG', l_errmsg, FALSE);
      l_body_string  := SUBSTR(fnd_message.get,1,10000);

      document_type := 'text/plain';
      document := l_body_string;
   end if;

END Ntf_Requestor_Of_Error;
-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  Update_Status
--
-- PARAMETERS
--           itemtype     (varchar2)
--          itemkey     (varchar2)
--          actid        (number)
--          funcmode     (number)
--          reultout     (varchar2)
-- PURPOSE
--  This is a generic procedure that is called by various procedures.
--   Depending on the Object Type and the Rule Type (UPDATE) the packaged procedure
--   to execute is obtained by calling Get_API_Name().
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--    6/17/2003       KARTHI MUTHUSWAMY Added comments
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
   l_pkg_name  varchar2(80);
   l_proc_name varchar2(80);
   l_return_stat            varchar2(1);
   l_msg_data              VARCHAR2(4000);
   l_msg_count          number;
   l_error_msg             VARCHAR2(4000);
   dml_str  varchar2(2000);
   l_OBJECT_type      varchar2(80);
   l_approval_type   varchar2(80);


BEGIN
   l_OBJECT_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_OBJECT_TYPE' );

  l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMW_APPROVAL_TYPE' );

   -- Obtain the Package.Procedure for the Object type and Approval Type
   Get_Api_Name('WORKFLOW',
                 l_OBJECT_type,
                 'UPDATE',
                 l_approval_type,
                 l_pkg_name,
                 l_proc_name,
                 l_return_stat);

   if (l_return_stat = 'S') then
         dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
         EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey, IN actid,IN funcmode,OUT resultout;
   end if;
END Update_Status;

-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  Approved_Update_Status
--
-- PARAMETERS
--           itemtype     (varchar2)
--          itemkey     (varchar2)
--          actid        (number)
--          funcmode     (number)
--          reultout     (varchar2)
-- PURPOSE
--  This procedure is called from the "Update Status for Approval" function activity.
--   It sets the 'UPDATE_GEN_STATUS' item attribute to "APPROVED" and calls
--   Update_Status().
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--    6/17/2003       KARTHI MUTHUSWAMY Added comments
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Approved_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
BEGIN
    -- The Object is Approved. Set the item attribute UPDATE_GEN_STATUS to 'APPROVED'
    WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>   'APPROVED'  );

   -- Call Update_Status() to update the status of the object to Approved
   Update_Status(itemtype => itemtype,
                        itemkey => itemkey,
                        actid => actid,
                        funcmode => funcmode,
                        resultout => resultout);

END Approved_Update_Status;

-------------------------------------------------------------------------------
-- Start of Comments
--
-- NAME
--  Reject_Update_Status
--
-- PARAMETERS
--           itemtype     (varchar2)
--          itemkey     (varchar2)
--          actid        (number)
--          funcmode     (number)
--          reultout     (varchar2)
-- PURPOSE
--  This procedure is called from the "Update Status for Rejection" function activity.
--   It sets the 'UPDATE_GEN_STATUS' item attribute to "REJECTED" and calls
--   Update_Status().
-- NOTES
-- HISTORY
--   6/4/2003        MUMU PANDE        CREATION
--    6/17/2003       KARTHI MUTHUSWAMY Added comments
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Reject_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS

   l_OBJECT_id           NUMBER;
   l_OBJECT_type         VARCHAR2(30);
   l_approver_seq          NUMBER;
   l_version               NUMBER;
   l_approver_id           NUMBER;
   l_approval_detail_id    NUMBER;
   l_approval_type         VARCHAR2(30);
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(4000);
   l_error_msg             VARCHAR2(4000);
   l_note                  VARCHAR2(4000);
BEGIN
    -- The Object is Rejected. Set the item attribute UPDATE_GEN_STATUS to 'REJECTED'
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                       itemkey    =>  itemkey,
                       aname      =>  'UPDATE_GEN_STATUS',
                       avalue     =>  'REJECTED');

   l_OBJECT_id  := Wf_Engine.GetItemAttrNumber(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'AMW_OBJECT_ID' );


   l_OBJECT_type := Wf_Engine.GetItemAttrText(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'AMW_OBJECT_TYPE' );

   l_approver_seq := Wf_Engine.GetItemAttrNumber(
                          itemtype => itemtype,
                          itemkey => itemkey,
                          aname   => 'AMW_APPROVER_SEQ' );

   l_version := Wf_Engine.GetItemAttrNumber(
                          itemtype => itemtype,
                          itemkey => itemkey,
                          aname   => 'AMW_OBJECT_VERSION_NUMBER' );

   l_approver_id := Wf_Engine.GetItemAttrNumber(
                          itemtype => itemtype,
                          itemkey => itemkey,
                          aname   => 'AMW_APPROVER_ID' );

   l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'AMW_APPROVAL_DETAIL_ID' );

   l_approval_type := Wf_Engine.GetItemAttrText(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'AMW_APPROVAL_TYPE' );

   l_note          := Wf_Engine.GetItemAttrText(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'APPROVAL_NOTE' );
  -- This needs to be last as it would change version number
   Update_Status(itemtype => itemtype,
                     itemkey => itemkey,
                     actid => actid,
                     funcmode => funcmode,
                     resultout => resultout);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => l_msg_count,
         p_data  => l_msg_data
      );
      Handle_Err
      (p_itemtype          => itemtype   ,
         p_itemkey           => itemkey    ,
         p_msg_count         => l_msg_count, -- Number of error Messages
         p_msg_data          => l_msg_data ,
         p_attr_name         => 'AMW_ERROR_MSG',
         x_error_msg         => l_error_msg
      );
      wf_core.context('amw_gen_approval_pvt',
              'set_approval_rules',
              itemtype, itemkey,to_char(actid),l_error_msg);
      resultout := 'COMPLETE:ERROR';
   --RAISE;
   WHEN OTHERS THEN
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => l_msg_count,
         p_data  => l_msg_data
       );
      Handle_Err
         (p_itemtype          => itemtype   ,
         p_itemkey           => itemkey    ,
         p_msg_count         => l_msg_count, -- Number of error Messages
         p_msg_data          => l_msg_data ,
         p_attr_name         => 'AMW_ERROR_MSG',
         x_error_msg         => l_error_msg
        )               ;
      wf_core.context('amw_gen_approval_pvt',
                 'set_approver_details',
                 itemtype, itemkey,to_char(actid),l_error_msg);
   RAISE;
   --
END Reject_Update_Status;

/*****************************************************************
-- Start of Comments
-- NAME
--   Approval_Required
-- PURPOSE
--   This Procedure will determine if the requestor of an OBJECT
--   is the same as the approver for that OBJECT. This is used to
--   bypass approvals if requestor is the same as the approver.
-- Used By Activities
-- NOTES
-- HISTORY
-- End of Comments
****************************************************************/
PROCEDURE Approval_Required(itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2)
IS
--
   l_requestor NUMBER;
   l_approver  NUMBER;


BEGIN
   Fnd_Msg_Pub.initialize();
   --
   -- RUN mode
   --
   IF (funcmode = 'RUN') THEN
      -- Get the Requestor
      l_requestor := Wf_Engine.GetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMW_REQUESTOR_ID');
      -- Get the Approver
      l_approver := Wf_Engine.GetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMW_APPROVER_ID');
      IF l_requestor = l_approver THEN
         resultout := 'COMPLETE:N';
      ELSE
         resultout := 'COMPLETE:Y';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
   END IF;

   --
   -- TIMEOUT mode
   --
   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
   END IF;
END Approval_Required;

END amw_gen_approval_pvt;

/
