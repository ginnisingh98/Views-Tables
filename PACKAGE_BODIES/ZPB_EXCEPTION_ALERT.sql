--------------------------------------------------------
--  DDL for Package Body ZPB_EXCEPTION_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_EXCEPTION_ALERT" AS
/* $Header: zpbwfexc.plb 120.4 2007/12/04 16:23:03 mbhat ship $ */

 Owner     varchar2(30);
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'zpb_exception_alert';

-- Directly called by WF function Activity
procedure EVALUATE_RESULTS (itemtype in varchar2,
      itemkey  in varchar2,
      actid    in number,
      funcmode in varchar2,
                  resultout   out nocopy varchar2)
   IS

    TaskID number;
    ExplainReq varchar2(3);
    countEx number;

BEGIN

 IF (funcmode = 'RUN') then

     resultout :='COMPLETE:NOEXCEPT';

     TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'TASKID');

     select count(*) INTO countEx
       from ZPB_EXCP_RESULTS
       where TASK_ID = TaskID;

     if countEx > 0 then
       select  value into ExplainReq
        from ZPB_TASK_PARAMETERS
        where TASK_ID = TaskID and NAME = 'EXPLANATION_REQUIRED_FLAG';

       -- type of exception
       if ExplainReq = 'N' then
          resultout :='COMPLETE:FYI';
       else
          resultout :='COMPLETE:ACTIONREQ_DUE';
       end if;
     else
      -- if not results no exception
      resultout :='COMPLETE:NOEXCEPT';
     end if;

   END IF;
   return;

  exception

   when others then
     WF_CORE.CONTEXT('ZPB_WF.EVALUATE_RESULTS', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end EVALUATE_RESULTS;

procedure SET_ATTRIBUTES (itemtype in varchar2,
    newitemkey  in varchar2,
    taskID   in number)

  IS

    value  Varchar2(4000);
    ExpReq Varchar2(4000);
    DType Varchar2(4000);
    Deadline varchar2(4000);
    DeadDate date;
    TASKPARAMNAME varchar2(100);
    errmsg varchar2(255);
    relative number;
    l_authorIDT varchar2(4000);
    authorID number;
    l_label  varchar2(4000);

    CURSOR c_tskparams is
      select NAME, VALUE
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID and NAME <> 'SPECIFIED_TARGET_NAME';

      v_tskparams c_tskparams%ROWTYPE;


BEGIN

    for  v_tskparams in c_tskparams loop

     taskParamName := v_tskparams.name;

     if taskParamName = 'NOTIFY_SUBJECT' then
        value := v_tskparams.value;
        wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'SUBJECT',
         avalue => value);
        elsif taskParamName = 'NOTIFY_CONTENT' then
          value := v_tskparams.value;
          wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ISSUEMSG',
                   avalue => value);
               elsif taskParamName = 'EXCEPTION_DIMENSION_NAME' then
                  value := v_tskparams.value;
                  wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'EXCEPDIM',
         avalue => value);
                  elsif taskParamName = 'SAVED_SELECTION_NAME' then
                    value := v_tskparams.value;

                      if value is not NULL then
                         -- Selection label
                         FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_SELECT_LABEL');
                         l_label := FND_MESSAGE.GET;
                         value := l_label || value;

                         wf_engine.SetItemAttrText(Itemtype => ItemType,
          Itemkey => NEWItemKey,
          aname => 'EXCEPSELECTION',
          avalue => value);
                        end if;


                     elsif taskParamName = 'EXPLANATION_REQUIRED_FLAG' then
                         ExpReq := v_tskparams.value;
                       elsif taskParamName = 'WAIT_TYPE' then
                           DType := v_tskparams.value;
                           elsif taskParamName = 'WAIT_VALUE' then
                               Deadline := v_tskparams.value;

     else
        errMsg := v_tskparams.value;
     end if;

   end loop;

   if ExpReq = 'Y' then

        if Dtype = 'DAY' then
           Relative  :=  to_number(Deadline)* 1440;
           DeadDate :=  sysdate + to_number(Deadline);
             elsif Dtype = 'WEEK' then
                 Relative  :=  to_number(Deadline)* 7 * 1440;
                 DeadDate :=  sysdate + (to_number(Deadline) * 7);
               elsif Dtype = 'MONTH' then
                   DeadDate :=  add_months(sysdate, to_number(Deadline));
                   Relative := (DeadDate - sysdate) * 1440;
          end if;

     -- DEADLINE for child explanation processes
     -- relative subtract 1 minute from child timeout to get them to timeout first.
     wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                   Itemkey => NEWItemKey,
                   aname => 'EXPDEADLINE',
                   avalue => Relative-1);

    end if;

    -- bug 3482485
    select value into l_authorIDT
       from  zpb_task_parameters
       where task_id = TaskID and name = 'OWNER_ID';

    authorID := to_number(l_authorIDT);

    wf_engine.SetItemAttrText(Itemtype => ItemType,
  Itemkey => NEWItemKey,
        aname => '#FROM_ROLE',
        avalue => ZPB_WF_NTF.ID_to_FNDUser(authorID));

    return;

 exception

   when others then
     raise;

end SET_ATTRIBUTES;

procedure SET_SPECIFIED_USERS (ExcType in varchar2,
                  AuthorID in number,
                  itemtype in varchar2,
              newitemkey  in varchar2,
            taskID   in number,
                  InstanceID in number)

IS

  rolename varchar2(100);
  relative number := 7;
  thisRecipient varchar2(100);
  thisUserID number;
  errmsg varchar2(100);

  CURSOR c_recipient is
    select NAME, value
    from ZPB_TASK_PARAMETERS
    where TASK_ID = TaskID and name = 'SPECIFIED_NOTIFICATION_RECIPIENT';

    v_recipient c_recipient%ROWTYPE;

BEGIN

     for  v_recipient in c_recipient loop

           thisRecipient := v_recipient.value;

           if c_recipient%ROWCOUNT = 1 then
              rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
              zpb_wf_ntf.SetRole(rolename, relative);
              ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
           else
             if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
                ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
             end if;
           end if;

         -- add in shadow if there is one
         thisUserID := zpb_wf_ntf.fnduser_to_ID(thisRecipient);
         zpb_wf_ntf.add_Shadow(rolename, thisUserId);

     end loop;

    -- add in author as recipient if EXCEPTION_TYPE => A
    if ExcType = 'A' then
        thisRecipient := zpb_wf_ntf.ID_to_FNDUser(AuthorID);
        if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
           ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
           zpb_wf_ntf.add_Shadow(rolename, AuthorID);
        end if;
    end if;

    wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => RoleName);

   return;

  exception
   when others then
     raise;

end SET_SPECIFIED_USERS;

procedure FYI_NOTIFICATIONS (ntfTarget in varchar2,
                  itemtype in varchar2,
      itemkey  in varchar2,
      taskID in number)
   IS

    ACNAME varchar2(300);
    ACID number;
    owner  varchar2(30);
    ownerID  number;
    AuthorID number;
    thisUser varchar2(100);
    relative number := 7;
    ExcType varchar2(100);
    rolename varchar2(100);
    InstanceID number;
    InstanceDesc varchar2(300);
    TaskName varchar2(256);
    charDate varchar2(30);
    NEWItemKey varchar2(240);
    workflowprocess varchar2(30) := 'NOTIFYEXCEPT';
    value varchar2(4000);
    errMsg varchar2(2000);
    l_authorIDT varchar2(4000);

BEGIN
    -- GET current task information.
    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'ACID');
    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ItemKey,
                 aname => 'ACNAME');
    ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'OWNERID');
    owner := zpb_wf_ntf.ID_to_FNDUser(ownerID);

    InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'INSTANCEID');

   -- set up defaults for author and type
   select TASK_NAME into TaskName
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;


   -- bug 3482485
   select value into l_authorIDT
     from  zpb_task_parameters
     where task_id = TaskID and name = 'OWNER_ID';

   AuthorID := to_number(l_authorIDT);


   select VALUE
   into ExcType
   from ZPB_TASK_PARAMETERS
   where TASK_ID = TaskID and name = 'EXCEPTION_TYPE';

   -- create NEWItemKey for FYI workflow
   charDate := to_char(sysdate, 'MM/DD/YYYY-HH24:MI:SS');
   NEWItemKey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-0-' || workflowprocess || '-' || charDate ;

   -- SET UP FYI PROCESS for this NEWItemKey!
   -- Create WF start process instance
   wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

   -- This should be the EPB controller.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);

    --  NOTE: for this NEWitemkey!
    wf_engine.SetItemAttrText(itemtype => itemtype,
      itemkey  => NEWItemKey,
      aname    => 'EXCEPLIST',
      avalue   =>
      'PLSQL:ZPB_EXCEPTION_ALERT.EXCEPTION_LIST/'||
      TO_CHAR(taskID)||':'||NEWItemKey);

    if ntfTarget = 'SPECIFIED' then
      -- this will populate wf attrs and WF Ad Hoc role with users.
      ZPB_EXCEPTION_ALERT.SET_SPECIFIED_USERS(ExcType, AuthorID, itemtype, NEWItemkey, taskID, InstanceID);

           elsif ntfTarget = 'OWNER_OF_AC' then

               -- BUSINESS PROCESS OWNER => OWNER_OF_AC
               rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
               zpb_wf_ntf.SetRole(rolename, relative);
               ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, owner);
               zpb_wf_ntf.add_Shadow(rolename, ownerID);

               -- add in author as recipient if EXCEPTION_TYPE => A
               if ExcType = 'A' then
                  thisUser := zpb_wf_ntf.ID_to_FNDUser(AuthorID);
                  if zpb_wf_ntf.user_in_role(rolename, thisUser) = 'N'  then
                      ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisUser);
                      zpb_wf_ntf.add_Shadow(rolename, AuthorID);
                  end if;
               end if;

               wf_engine.SetItemAttrText(Itemtype => ItemType,
        Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
      avalue => RoleName);

               elsif ntfTarget = 'JUST_AUTHOR' then
                     -- Just the Author
                     rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                     zpb_wf_ntf.SetRole(rolename, relative);
                     thisUser := zpb_wf_ntf.ID_to_FNDUser(AuthorID);
                     if zpb_wf_ntf.user_in_role(rolename, thisUser) = 'N'  then
                         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisUser);
                      -- zpb_wf_ntf.add_Shadow(rolename, AuthorID);
                     end if;
                     wf_engine.SetItemAttrText(Itemtype => ItemType,
        Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
      avalue => RoleName);
   end if;

    -- reads parameters and sets attributes for this process
   ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

   -- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

   -- set cycle Name!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACNAME',
         avalue => ACNAME);
   -- set Task ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

   -- set Task Name!
   select TASK_NAME
   into TaskName
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;

   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);

   select INSTANCE_DESCRIPTION
   into InstanceDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstanceDesc);



   -- START IT!
   -- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => NEWItemKey);

  return;

  exception
   when others then
    -- WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.FYI_SPECIFIED', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end FYI_NOTIFICATIONS;


procedure SEND_NOTIFICATIONS (itemtype in varchar2,
      itemkey  in varchar2,
      actid    in number,
      funcmode in varchar2,
                  resultout   out nocopy varchar2)
   IS

    InstItemType varchar2(8) := 'EPBCYCLE';
    ACNAME varchar2(300);
    TaskID number;
    owner  varchar2(30);
    newitemkey varchar2(240);
    workflowprocess varchar2(30);
    InstanceID number;
    NtfType varchar2(4000);
    ExcType varchar2(4000);
    ntfTarget varchar2(4000);
    DType Varchar2(6) := 'NONE';
    DeadDate date;
    Deadline varchar2(30);
    TASKPARAMNAME varchar2(100);
    errmsg varchar2(100);
    relative number;
    authorID number;
    l_authorIDT varchar2(4000);
    thisOwnerID number;   -- b 4948928

    CURSOR c_deadline is
      select NAME, VALUE
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID and ( NAME = 'WAIT_TYPE' or NAME = 'WAIT_VALUE' );

      v_deadline c_deadline%ROWTYPE;


BEGIN

 IF (funcmode = 'RUN') then

     resultout := 'ERROR';

     TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'TASKID');

    -- bug 3482485
    select value into l_authorIDT
       from  zpb_task_parameters
       where task_id = TaskID and name = 'OWNER_ID';

    authorID := to_number(l_authorIDT);

     wf_engine.SetItemAttrText(Itemtype => ItemType,
        Itemkey => ItemKey,
              aname => '#FROM_ROLE',
              avalue => ZPB_WF_NTF.ID_to_FNDUser(authorID));

     select  value into ntfType
       from ZPB_TASK_PARAMETERS
       where TASK_ID = TaskID and NAME = 'EXPLANATION_REQUIRED_FLAG';

     select  value into ntfTarget
       from ZPB_TASK_PARAMETERS
       where TASK_ID = TaskID and NAME = 'NOTIFICATION_RECIPIENT_TYPE';

     select  value into ExcType
       from ZPB_TASK_PARAMETERS
       where TASK_ID = TaskID and NAME = 'EXCEPTION_TYPE';

     if NtfType = 'N' then

         if ntfTarget = 'DATA_OWNERS' then
            -- this will populate wf attrs and start the NTF Workflow to send FYI for data owners.
            ZPB_EXCEPTION_ALERT.FYI_BY_OWNER(itemtype, itemkey, taskID);
            --after all dataowner get their ntfs send one to author if type = analyst.

           if ExcType = 'A' then
                -- overloaded ntfTarget type  to included JUST_AUTHOR
                ZPB_EXCEPTION_ALERT.FYI_NOTIFICATIONS('JUST_AUTHOR', itemtype, itemkey, taskID);
           end if;
           resultout := 'COMPLETE';
         else
            -- this will populate wf attrs and start the NTF Workflow which send the NTF.
            ZPB_EXCEPTION_ALERT.FYI_NOTIFICATIONS(ntfTarget, itemtype, itemkey, taskID);
            resultout := 'COMPLETE';
         end if;

        elsif NtfType = 'Y' then

           -- set timeout/deadline for Explanation parent
           for  v_deadline in c_deadline loop
                taskParamName := v_deadline.name;
                if taskParamName = 'WAIT_TYPE' then
                   DType := v_deadline.value;
                   elsif taskParamName = 'WAIT_VALUE' then
                      Deadline := v_deadline.value;
                   else
                      errMsg := v_deadline.value;
                end if;
           end loop;

           if Dtype = 'DAY' then
              Relative  :=  to_number(Deadline)* 1440;
              DeadDate :=  sysdate + to_number(Deadline);
             elsif Dtype = 'WEEK' then
                 Relative  :=  to_number(Deadline)* 7 * 1440;
                 DeadDate :=  sysdate + (to_number(Deadline) * 7);
               elsif Dtype = 'MONTH' then
                   DeadDate :=  add_months(sysdate, to_number(Deadline));
                   Relative := (DeadDate - sysdate) * 1440;
           end if;

           if Dtype <> 'NONE' then
              -- relative add 1 minutes to deadline to let children time out
               wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                   Itemkey => ItemKey,
                   aname => 'WAITDEADLINE',
                   avalue => Relative+1);

           end if;
           -- end of timeout/deadline code


           if ntfTarget = 'DATA_OWNERS' then
               -- this will populate wf attrs and start the NTF Workflow to send Exp NTFs.
               -- Note: itemkey is ParentItemkey
               ZPB_EXCEPTION_ALERT.EXPLANATION_BY_OWNER(itemtype, itemkey, taskID);
              resultout := 'COMPLETE';
             elsif ntfTarget = 'SPECIFIED' then
                   ZPB_EXCEPTION_ALERT.EXPLANATION_BY_SPECIFIED(itemtype, itemkey, taskID);
                   resultout := 'COMPLETE';
                 elsif ntfTarget = 'OWNER_OF_AC' then
                       ZPB_EXCEPTION_ALERT.EXPL_BY_ACOWNER(itemtype, itemkey, taskID);
                       resultout := 'COMPLETE';
            end if;


     else
       resultout := 'ERROR';
     end if;

   -- b 4948928
   -- if Expired WF users have been detected then send list to BPO or its proxy
   -- otherwise do nothing.

   thisOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'OWNERID');

  zpb_wf_ntf.SendExpiredUserMsg(thisOwnerID, taskID, itemType);
 -- end b 4948928

   END IF;


   return;

  exception

   when others then

     WF_CORE.CONTEXT('ZPB_EXPCEPTION_ALERT.SEND_NOTIFICATIONS', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end SEND_NOTIFICATIONS;


procedure WF_RUN_EXCEPTION (errbuf out nocopy varchar2,
            retcode out nocopy varchar2,
                        taskID in Number,
                        UserID in Number)
   IS

   x_return_status varchar2(100);
   x_msg_count number;
   x_msg_data varchar2(4000);

BEGIN


/*

--  zpb_excp_pvt.run_exception(UserID, taskID, 1.0, , , 1, x_return_status, x_msg_count, x_msg_data);

*/

-- Begining run of exception request

 ZPB_LOG.WRITE_EVENT_TR ('ZPB_EXCEPTION_ALERT.WF_RUN_EXCEPTION', 'ZPB_WF_BEGEXCPRUN');

 zpb_excp_pvt.run_exception(p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_FALSE,
                            p_commit => FND_API.G_TRUE,
                            p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            p_task_id => taskID,
                            p_user_id => UserID);

-- Successfully completed run of exception request
 ZPB_LOG.WRITE_EVENT_TR ('ZPB_EXCEPTION_ALERT.WF_RUN_EXCEPTION', 'ZPB_WF_COMPEXCPRUN');

   retcode :='0';
   return;

  exception

   when others then
-- Encountered error when running exception request
   FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_WF_ERREXCPRUN');
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

           retcode :='2';
           errbuf:=substr(sqlerrm, 1, 255);

end WF_RUN_EXCEPTION;


procedure EXCEPTION_LIST (document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

IS
    ItemType    varchar2(30) := 'EPBCYCLE';
    ItemKey varchar2(240);
    taskID      number;
    NID         number;
    ResultList varchar2(4000);
    thisMember varchar2(240);
    thisValue varchar2(2000);
    thisVFlag  number;
    l_label varchar2(200);
    l_number number;
    l_dimname varchar2(100);

    CURSOR c_results is
      select *
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID;

      v_results c_results%ROWTYPE;

BEGIN

     TaskID := to_number(substr(document_id, 1, instr(document_id,':')-1));
     itemkey := substr(document_id, instr(document_id,':')+1);


     -- Exceptionable member[s]:

     select value into l_dimname from ZPB_TASK_PARAMETERS
     where TASK_ID = TaskID and NAME = 'EXCEPTION_DIMENSION_NAME';

     -- Following ZPB_WF_DIMNAME members have an alert

     FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_DIMMEMBERS');
     FND_MESSAGE.SET_TOKEN ('ZPB_WF_DIMNAME', l_dimname);
     l_label := FND_MESSAGE.GET;


     -- put label in WF resource?
     document := document||   htf.tableOpen(cattributes=>'width=100%');
     document := document||   htf.tableRowOpen;
     document := document||   htf.tableData(cvalue=>htf.bold(l_label));
     document := document||   htf.tableData(htf.br);
     document := document||   htf.tableRowClose;


     for  v_results in c_results loop
/*
       thisMember := v_results.member_display;

       thisVFlag := v_results.VALUE_FLAG;
       if thisVFlag = 0 then
          thisValue := v_results.VALUE_CHAR;
          elsif thisVFlag = 1 then
              l_number := v_results.VALUE_NUMBER;
             thisValue := to_char(l_number);
             elsif thisVFlag = 2 then
                thisValue := to_char(v_results.VALUE_DATE);
       end if;

       resultList := thisMember || ' - ' || thisVAlue;
*/
        resultList := v_results.member_display;
        -- Exception results
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>ResultList);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;

     end loop;

  document_type := 'text/html';

  return;

  exception
when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','EXCEPTION_LIST',ItemType, ItemKey);
  raise;


END EXCEPTION_LIST;


procedure SET_OWNER_USERS (itemtype in varchar2,
              newitemkey  in varchar2,
            taskID   in number,
                  InstanceID in number)

IS

  UserList varchar2(600);
  rolename varchar2(100);
  relative number := 7;
  thisOWNER varchar2(100);

    CURSOR c_thisowner is
      select distinct OWNER
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID
      order by OWNER;

      v_thisowner c_thisowner%ROWTYPE;


BEGIN

   UserList := ' ';

   for  v_thisowner in c_thisowner loop
      thisOwner := v_thisowner.owner;
      if UserList = ' ' then
         UserList := thisOwner;
      else
         UserList := UserList || ',' ||thisOwner;
      end if;
    end loop;


    if instr(UserList, ',') > 0 then
      -- FND user names list so build Ad Hoc role
      rolename := zpb_wf_ntf.MakeRoleName(InstanceID, taskID);
      zpb_wf_ntf.SetRole(rolename, relative);
      ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, UserList);
        elsif length(UserList) > 0 then
          rolename := UserList;
    end if;

    wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => RoleName);

   return;

 exception

   when others then
     raise;

end SET_OWNER_USERS;


procedure EXCEPTION_BY_OWNER (document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

IS
    ItemType   varchar2(30) := 'EPBCYCLE';
    ItemKey    varchar2(240);
    taskID     number;
    nid        number;
    role       varchar2(35);
    DDate      date;
    Dtext      varchar2(35);
    ResultList varchar2(4000);
    thisMember varchar2(240);
    thisValue  varchar2(1000);
    thisVFlag  number;

    CURSOR c_byowner is
      select *
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID and OWNER = role;

      v_byowner c_byowner%ROWTYPE;

BEGIN

     TaskID := to_number(substr(document_id, 1, instr(document_id,':')-1));
     nid := to_number(substr(document_id, instr(document_id,':')+1));
     wf_notification.GetInfo (nid, role, Dtext, Dtext, Dtext, Ddate, Dtext);

     for  v_byowner in c_byowner loop

       thisMember := v_byowner.member_display;

       thisVFlag := v_byowner.VALUE_FLAG;
       if thisVFlag = 0 then
          thisValue := v_byowner.VALUE_CHAR;
          elsif thisVFlag = 1 then
              thisValue := to_char(v_byowner.VALUE_NUMBER);
             elsif thisVFlag = 2 then
                thisValue := to_char(v_byowner.VALUE_DATE);
       end if;

       resultList := thisMember || ' - ' || thisVAlue;
        -- Exception results
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>htf.bold(ResultList));
       document := document||   htf.tableRowClose;

     end loop;

  document_type := 'text/html';

  return;

  exception
when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','EXCEPTION_BY_OWNER',ItemType, ItemKey);
  raise;

END EXCEPTION_BY_OWNER;


-- This launches the process EXPLAINCHILD which requires a response.
procedure EXPLANATION_BY_OWNER (itemtype in varchar2,
      ParentItemkey  in varchar2,
      taskID in number)
   IS

    ACNAME varchar2(300);
    ACID number;
    ProcOwner  varchar2(30);
    ProcOwnerID number;
    rolename varchar2(30);
    relative number :=7;
    InstanceID number;
    InstanceDesc varchar2(300);
    TaskName varchar2(256);
    NEWItemKey varchar2(240);
    workflowprocess varchar2(30) := 'EXPLAINCHILD';
    thisItemKey varchar2(240);
    thisOWNER varchar2(100);
    thisOwnerID number;
    thisApprover  varchar2(100);
    thisApproverID  number;
    ShadowStatus varchar2(24);
    errMsg varchar2(2000);
    NewDispName varchar2(360);
    l_label varchar2(50);

    l_htmlagent varchar2(1000);  --B 4106621 URL
    l_URLexplain varchar2(1000);   --B 4106621 URL
    l_newURL varchar2(2000);  --B 4106621 URL

    CURSOR c_thisowner is
      select distinct OWNER_ID, OWNER,  APPROVER_ID, APPROVER
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID
      order by OWNER;

      v_thisowner c_thisowner%ROWTYPE;


    CURSOR c_children is
      select ITEM_KEY
      from WF_ITEMS_V
      where PARENT_ITEM_KEY = ParentItemKey;

      v_child c_children%ROWTYPE;



BEGIN
    -- GET current task information.
    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'ACID');
    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'ACNAME');
    ProcOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'OWNERID');
    ProcOwner := zpb_wf_ntf.ID_to_FNDUser(ProcOwnerID);

    InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'INSTANCEID');

   -- B 4106621 URL
   -- l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', ProcOwnerID);

   l_URLexplain := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'URLEXPLAIN');
   -- l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;

   -- set Task Name!
   select TASK_NAME
   into TaskName
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;

   select INSTANCE_DESCRIPTION
   into InstanceDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   -- FOR EACH OWNER start a explanation required process
   for  v_thisowner in c_thisowner loop

      thisOwnerID := v_thisowner.owner_id;
      thisOwner := v_thisowner.owner;
      thisApproverID := v_thisowner.approver_id;
      thisApprover := v_thisowner.approver;

      -- create NEWItemKey for FYI workflow
      NEWItemKey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(InstanceID) || '-' || to_char(taskID)  || '-' || thisOwner || '-' || workflowprocess;

      -- SET UP PROCESS for this NEWItemKey!
      -- Create WF start process instance
      wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

      -- SETITEMPARENT! NewItemKey is the CHILD!
      wf_engine.SetItemParent(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         PARENT_ITEMTYPE => ItemType,
                         PARENT_ITEMKEY => ParentItemKey,
                         PARENT_CONTEXT => NULL);

     -- This should be the EPB controller.
     wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => ProcOwner);

     --  owner ID
     wf_engine.SetItemAttrNumber(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'OWNERID',
            avalue => ProcOwnerID);

     --=============================================================================
     -- b5179198 URL profile should be set for the ntf target user
     l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', thisOwnerID);
     l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;
     --==============================================================================

     -- B 4106621 URL
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'URLEXPLAIN',
            avalue => l_newURL);

     -- make the Ad Hoc role to hold both the dataowner and shadow
     if zpb_wf_ntf.has_Shadow(thisOwnerID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisOwnerID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisOwner;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisOwner);
         zpb_wf_ntf.add_Shadow(rolename, thisOwnerID);
      else
        rolename := thisOwner;
      end if;

     -- explanation recipient rolename with owner and shadow
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => rolename);

     -- **********************************************************
     -- make the Ad Hoc role to hold both the APPROVERS and shadow

     dbms_lock.sleep(1);

     if zpb_wf_ntf.has_Shadow(thisApproverID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisApproverID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisApprover;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisApprover);
         zpb_wf_ntf.add_Shadow(rolename, thisApproverID);
      else
        rolename := thisApprover;
      end if;

     -- approver
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'FNDUSERNAM',
            avalue => rolename);

    -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'EXCEPLIST',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.EXP_EXCEP_BY_OWNER/' || TO_CHAR(taskID) || ':' || thisOwner);

   -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'RESPNOTE',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.SHOW_RESP/' || NEWitemkey );


   -- reads parameters and sets attributes for this process
   ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

   -- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

   -- set cycle Name!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACNAME',
         avalue => ACNAME);
   -- set Task ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);


   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstanceDesc);


                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER1',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER2',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER3',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER4',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER5',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER6',
                          avalue => NULL);

   end loop;



   -- START IT!
   for  v_child in c_children loop

      thisItemKEY := v_child.ITEM_KEY;
      -- Now that all is created and set START each CHILD PROCESS!
      wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => thisItemKey);
   end loop;

  return;

  exception
   when others then
    -- WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.FYI_SPECIFIED', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end EXPLANATION_BY_OWNER;



procedure EXP_EXCEP_BY_OWNER (document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

IS
    ItemType   varchar2(30) := 'EPBCYCLE';
    ItemKey    varchar2(240);
    taskID     number;
    nid        number;
    DataOwner  varchar2(100);
    l_label  varchar2(200);
    DDate      date;
    Dtext      varchar2(35);
    ResultList varchar2(4000);
    thisMember varchar2(240);
    thisValue  varchar2(1000);
    thisVFlag  number;
    l_dimname varchar2(100);

    CURSOR c_byowner is
      select *
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID and OWNER = DataOwner;

      v_byowner c_byowner%ROWTYPE;

BEGIN

     TaskID := to_number(substr(document_id, 1, instr(document_id,':')-1));
     DataOwner := substr(document_id, instr(document_id,':')+1);


     -- Exceptionable member[s]:

     select value into l_dimname
       from ZPB_TASK_PARAMETERS
       where TASK_ID = TaskID and NAME = 'EXCEPTION_DIMENSION_NAME';

     -- Following  ZPB_WF_DIMNAME members have an alert
     FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_DIMMEMBERS');
     FND_MESSAGE.SET_TOKEN ('ZPB_WF_DIMNAME', l_dimname);
     l_label := FND_MESSAGE.GET;


     -- put label in WF resource?
     document := document||   htf.tableOpen(cattributes=>'width=100%');
     document := document||   htf.tableRowOpen;
     document := document||   htf.tableData(cvalue=>htf.bold(l_label));
     document := document||   htf.tableData(htf.br);
     document := document||   htf.tableRowClose;

     for  v_byowner in c_byowner loop
/*
       thisMember := v_byowner.member_display;

       thisVFlag := v_byowner.VALUE_FLAG;
       if thisVFlag = 0 then
          thisValue := v_byowner.VALUE_CHAR;
          elsif thisVFlag = 1 then
              thisValue := to_char(v_byowner.VALUE_NUMBER);
             elsif thisVFlag = 2 then
                thisValue := to_char(v_byowner.VALUE_DATE);
       end if;

       resultList := thisMember || ' - ' || thisVAlue;
*/
        resultList := v_byowner.member_display;
        -- Exception results
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>ResultList);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;

     end loop;

  document_type := 'text/html';

  return;

  exception
when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','EXP_EXCEP_BY_OWNER',ItemType, ItemKey);
  raise;

END EXP_EXCEP_BY_OWNER;

procedure MANAGE_RESPONSE(itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS

    thisNID Number;
    userDispName varchar2(360);
    Ttext  varchar2(360);
    thisRole  varchar2(360);
    result varchar2(24);
    resp varchar2(1000) := NULL;
    reg1 varchar2(1000) := NULL;
    reg2 varchar2(1000) := NULL;
    reg3 varchar2(1000) := NULL;
    reg4 varchar2(1000) := NULL;
    reg5 varchar2(1000) := NULL;
    reg6 varchar2(1000) := NULL;


   BEGIN


   if (funcmode = 'RUN') then

    result := wf_engine.GetItemAttrText(Itemtype => ItemType,
                   Itemkey => ItemKey,
                    aname => 'RESULT');



    if result = 'REJECTED' or result = 'EXPLANATION' then

       thisNID := wf_engine.context_nid;

       if result = 'REJECTED' then

           thisRole := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'FNDUSERNAM');
      else
          thisRole := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'EPBPERFORMER');

      end if;


      wf_engine.SetItemAttrText(Itemtype => ItemType,
    Itemkey => ItemKey,
          aname => '#FROM_ROLE',
          avalue => thisRole);


      select distinct display_name
        into UserDispName
        from wf_roles
        where name = thisRole;

          wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'THISNID',
                  avalue => thisNID);


              resp :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'WF_NOTE');

              if resp is not NULL then
                 resp :=  userDispName || ' - ' ||  sysdate ||': ' || resp ;
              end if;

              reg1 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER1');

              reg2 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER2');

              reg3 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER3');

              reg4 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER4');

              reg5 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER5');

              reg6 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER6');


              if (resp is not null) then
                  reg6 :=  reg5;
                  reg5 :=  reg4;
                  reg4 :=  reg3;
                  reg3 :=  reg2;
                  reg2 :=  reg1;
                  reg1 :=  resp;

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER1',
              avalue => reg1);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER2',
              avalue => reg2);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER3',
              avalue => reg3);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER4',
              avalue => reg4);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER5',
              avalue => reg5);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'REGISTER6',
                          avalue => reg6);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => ItemKey,
                              aname => 'WF_NOTE',
                          avalue => NULL);


       end if;

   end if;

end if;

  if (funcmode = 'TIMEOUT') then
      resultout := wf_engine.eng_timedout;
  end if;

 return;

 exception
   when others then
     WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.MANAGE_RESPONSE', itemtype, itemkey, to_char(actid), funcmode);
   raise;

end MANAGE_RESPONSE;


procedure SHOW_RESP(document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

IS
    ItemType   varchar2(30) := 'EPBCYCLE';
    ItemKey    varchar2(240);
    nid        number;
    l_label  varchar2(100);
    reg1 varchar2(1000) := NULL;
    reg2 varchar2(1000) := NULL;
    reg3 varchar2(1000) := NULL;
    reg4 varchar2(1000) := NULL;
    reg5 varchar2(1000) := NULL;
    reg6 varchar2(1000) := NULL;
    thisValue  varchar2(360);

BEGIN

     ItemKey := document_id;

     reg1 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER1');

     reg2 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER2');

     reg3 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER3');

     reg4 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER4');

     reg5 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER5');

     reg6 :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'REGISTER6');


     -- Notes:
     FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_NOTES');
     l_label := FND_MESSAGE.GET;

     -- Exception results
     if reg1 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>htf.bold(l_label));
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg1);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

     if reg2 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg2);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

     if reg3 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg3);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

     if reg4 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg4);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

     if reg5 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg5);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

     if reg6 is not NULL then
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>reg6);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;
     end if;

  document_type := 'text/html';

  return;

  exception
when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','SHOW_RESP',ItemType, ItemKey);
  raise;

END SHOW_RESP;


procedure CLEAN_RESULTS_TABLE (errbuf out nocopy varchar2,
            retcode out nocopy varchar2,
                        taskID in Number)
   IS

BEGIN

--   delete ZPB_EXCP_RESULTS
--     where TASK_ID = taskID;

--   delete ZPB_EXCP_EXPLANATIONS
--     where TASK_ID = taskID;

--   commit;

   retcode :='0';
   return;

  exception

   when others then
           rollback;
           retcode :='2';
           errbuf:=substr(sqlerrm, 1, 255);

end CLEAN_RESULTS_TABLE;

-- This launches the process EXPLAINCHILD which requires a response.
procedure EXPLANATION_BY_SPECIFIED(itemtype in varchar2,
      ParentItemkey  in varchar2,
      taskID in number)
   IS

    ACNAME varchar2(300);
    ACID number;
    owner  varchar2(30);
    InstanceID number;
    InstanceDesc varchar2(300);
    TaskName varchar2(256);
    NEWItemKey varchar2(240);
    workflowprocess varchar2(30) := 'EXPLAINCHILD';
    thisItemKey varchar2(240);
    thisRecipient varchar2(100);
    thisApprover  varchar2(100);
    thisRecipientID number;
    thisApproverID  number;
    errMsg varchar2(2000);
    rolename varchar2(320);
    NewDispName varchar2(360);
    l_label varchar2(30);
    relative number;
    ApproverTYPE varchar2(4000);

    l_htmlagent varchar2(2000);   -- B 4106621 URL agent override
    ProcOwnerID number;           -- B 4106621 URL agent override
    l_URLexplain varchar2(1000);   --B 4106621 URL
    l_newURL varchar2(2000);  --B 4106621 URL


    CURSOR c_children is
      select ITEM_KEY
      from WF_ITEMS_V
      where PARENT_ITEM_KEY = ParentItemKey;

      v_child c_children%ROWTYPE;

    CURSOR c_recipient is
      select value
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID and name = 'SPECIFIED_NOTIFICATION_RECIPIENT';

      v_recipient c_recipient%ROWTYPE;

BEGIN
    -- GET current task information.
    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'ACID');
    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'ACNAME');
    owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'FNDUSERNAM');
    InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'INSTANCEID');


   -- B 4106621 URL agent override
   --ProcOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
   --        Itemkey => ParentItemKey,
   --          aname => 'OWNERID');

   --l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', ProcOwnerID);

   l_URLexplain := wf_engine.GetItemAttrText(Itemtype => ItemType,
                      Itemkey => ParentItemKey,
                      aname => 'URLEXPLAIN');

   --l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;

   -- set Task Name!
   select TASK_NAME, LAST_UPDATED_BY
   into TaskName, thisApproverID
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;

   select INSTANCE_DESCRIPTION
   into InstanceDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   select value
    into ApproverTYPE
    from ZPB_TASK_PARAMETERS
    where TASK_ID = TaskID and name = 'EXPLANATION_APPROVER';

   if ApproverTYPE = 'AUTHOR_OF_EXCEPTION' then
     thisApprover := zpb_wf_ntf.ID_to_fnduser(thisApproverID);
   end if;

   -- FOR EACH OWNER start a explanation required process
   for  v_recipient in c_recipient loop
      dbms_lock.sleep(1);
      thisRecipient := v_recipient.value;
      -- create NEWItemKey for FYI workflow
      NEWItemKey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(InstanceID) || '-' || to_char(taskID)  || '-' || thisRecipient || '-' || workflowprocess;

      -- SET UP PROCESS for this NEWItemKey!
      -- Create WF start process instance
      wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

      -- SETITEMPARENT! NewItemKey is the CHILD!
      wf_engine.SetItemParent(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         PARENT_ITEMTYPE => ItemType,
                         PARENT_ITEMKEY => ParentItemKey,
                         PARENT_CONTEXT => NULL);

     -- This should be the EPB controller.
     wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);


     -- explanation recipient
     -- make the Ad Hoc role to hold both the dataowner and shadow

     thisRecipientID := zpb_wf_ntf.fnduser_to_ID(thisRecipient);

     --=============================================================================
     -- b5179198 URL profile should be set for the ntf target user
     l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', thisRecipientID);
     l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;
     --==============================================================================

     if zpb_wf_ntf.has_Shadow(thisRecipientID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisRecipientID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisRecipient;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
         zpb_wf_ntf.add_Shadow(rolename, thisRecipientID);
      else
        rolename := thisRecipient;
      end if;

     -- explanation recipient rolename with owner and shadow
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => rolename);


     -- **********************************************************
     -- make the Ad Hoc role to hold both the APPROVERS and shadow

     if zpb_wf_ntf.has_Shadow(thisApproverID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisApproverID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisApprover;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisApprover);
         zpb_wf_ntf.add_Shadow(rolename, thisApproverID);
      else
        rolename := thisApprover;
      end if;

     -- approver
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'FNDUSERNAM',
            avalue => rolename);


    -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'EXCEPLIST',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.EXCEPTION_LIST/'|| TO_CHAR(taskID)||':'||NEWItemKey);

   -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'RESPNOTE',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.SHOW_RESP/' || NEWitemkey );


   -- reads parameters and sets attributes for this process
   ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

   -- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

   -- set cycle Name!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACNAME',
         avalue => ACNAME);
   -- set Task ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);

   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstanceDesc);

   -- B 4106621 URL
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'URLEXPLAIN',
         avalue => l_newURL);

                wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER1',
                              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER2',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER3',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER4',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER5',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER6',
                          avalue => NULL);

   end loop;



   -- START IT!
   for  v_child in c_children loop

      thisItemKEY := v_child.ITEM_KEY;
      -- Now that all is created and set START each CHILD PROCESS!
      wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => thisItemKey);
   end loop;

  return;

  exception
   when others then
    -- WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.EXPLANATION_BY_SPECIFIED', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end EXPLANATION_BY_SPECIFIED;

procedure BUILD_DEADLINE_NTF (itemtype in varchar2,
                  itemkey  in varchar2,
              actid    in number,
              funcmode in varchar2,
                          resultout   out nocopy varchar2)
 IS


    errMsg varchar2(320);
    TaskID number;
    InstDesc varchar2(300);
    value varchar2(4000);
    InstanceID number;
    workflowprocess varchar2(30);
    taskParamName  varchar2(100);
    thisCount number := 0;
    taskname varchar2(150);
    l_label  varchar2(4000);

    CURSOR c_tparams is
      select NAME, value
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID;

      v_tparams c_tparams%ROWTYPE;

  BEGIN


  IF (funcmode = 'RUN') THEN

      resultout :='COMPLETE:N';

      -- b5102962 WF_ITEM_ACTIVITY_STATUSES_V is non performant so
      -- it is replaced by the table WF_ITEM_ACTIVITY_STATUSES and
      -- ACTIVITY_STATUS_CODE is replaced by ACTIVITY_STATUS
      select count(*) into thisCount
        from WF_ITEM_ACTIVITY_STATUSES
        where ITEM_TYPE = 'EPBCYCLE' and
        ITEM_KEY in (select ITEM_KEY from WF_ITEMS_V where PARENT_ITEM_KEY = ItemKey)
        and (ACTIVITY_STATUS = 'NOTIFIED' or ACTIVITY_RESULT_CODE = '#TIMEOUT');

       if thisCount > 0 then

          TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'TASKID');

          InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'INSTANCEID');

          select INSTANCE_DESCRIPTION
            into InstDesc
            from ZPB_ANALYSIS_CYCLE_INSTANCES
            where INSTANCE_AC_ID = InstanceID;

          -- set descripton
          wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => ItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstDesc);

         for  v_tparams in c_tparams loop

           taskParamName := v_tparams.name;

           if taskParamName = 'EXCEPTION_DIMENSION_NAME' then
                  value := v_tparams.value;
                  wf_engine.SetItemAttrText(Itemtype => ItemType,
                      Itemkey => ItemKey,
                      aname => 'EXCEPDIM',
                      avalue => value);
                  elsif taskParamName = 'SAVED_SELECTION_NAME' then
                    value := v_tparams.value;


                      if value is not NULL then
                         -- Selection label
                         FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_SELECT_LABEL');
                         l_label := FND_MESSAGE.GET;
                         value := l_label || value;

                         wf_engine.SetItemAttrText(Itemtype => ItemType,
          Itemkey => ItemKey,
          aname => 'EXCEPSELECTION',
          avalue => value);
                        end if;

           end if;
         end loop;
        resultout :='COMPLETE:Y';
     end if;

  END IF;

  return;

  exception

   when others then
     WF_CORE.CONTEXT('ZPB_WF.BUILD_DEADLINE_NTF', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end BUILD_DEADLINE_NTF;

-- b5102962 reorganized this procedure removed WF view from cursor - performance issue.
procedure NON_RESPONDERS (document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

 IS
    ItemType      varchar2(30);
    ItemKey       varchar2(240);
    thisUser      varchar2(320);
    childItemKey  varchar2(240);
    l_label       varchar2(150);
    l_ctr         number;
    l_activity_id number;

    -- b5102962 WF_ITEM_ACTIVITY_STATUSES_V is non performant so
    -- it is replaced by the table WF_ITEM_ACTIVITY_STATUSES and
    -- ACTIVITY_STATUS_CODE is replaced by ACTIVITY_STATUS and
    -- ASSIGNED_USER_DISPLAY_NAME to ASSIGNED_USER.
    -- Done for both cursors below.

    CURSOR c_exceptionPool is
     SELECT ITEM_KEY, ASSIGNED_USER
       FROM WF_ITEM_ACTIVITY_STATUSES
       WHERE ITEM_TYPE = 'EPBCYCLE' and
       ITEM_KEY in  (select ITEM_KEY from WF_ITEMS_V where PARENT_ITEM_KEY = ItemKey)
       and (ACTIVITY_STATUS = 'NOTIFIED' or ACTIVITY_RESULT_CODE = '#TIMEOUT');
     v_exChild c_exceptionPool%ROWTYPE;

  BEGIN

  ItemType := 'EPBCYCLE';
  ItemKey  := document_id;
  -- Explanations not received from:
  FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_EXPLAINERS');
  l_label := FND_MESSAGE.GET;

  --pool1
  l_ctr := 0;
  for v_exChild in c_exceptionPool loop

      -- b5102962
      l_activity_id := NULL;
      childItemKey :=  v_exChild.Item_key;

      begin

      select activity_id into l_activity_id
        from  WF_ITEM_ACTIVITY_STATUSES_V
        WHERE ITEM_TYPE = 'EPBCYCLE'
        AND ITEM_KEY = childItemKey
        AND activity_name = 'EXPREQNTF';

      exception
        when NO_DATA_FOUND then
           l_activity_id := null;
      end;

      -- if there is a hit then process this
      if l_activity_id is not NULL then
         l_ctr := l_ctr+1;
         thisUser := substr(wf_directory.getroledisplayname(v_exChild.ASSIGNED_USER), 1, 320);
         -- thisUser := v_explainer.ASSIGNED_USER_DISPLAY_NAME;
         -- put label in WF resource?
          if l_ctr = 1 then
             document := document||   htf.tableOpen(cattributes=>'width=100%');
             document := document||   htf.tableRowOpen;
             document := document||   htf.tableData(cvalue=>htf.bold(l_label));
             document := document||   htf.tableData(htf.br);
             document := document||   htf.tableRowClose;
          end if;
           -- Exception results
           document := document||   htf.tableRowOpen;
           document := document||   htf.tableData(cvalue=>thisUser);
           document := document||   htf.tableData(htf.br);
           document := document||   htf.tableRowClose;
      end if;
  end loop;
  --pool1


  --pool2
  -- Approvals not received from:
  FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_APPROVERS');
  l_label := FND_MESSAGE.GET;

  l_ctr := 0;
  for v_exChild in c_exceptionPool loop
      -- b5102962
      l_activity_id := NULL;
      childItemKey :=  v_exChild.Item_key;

      begin

      select activity_id into l_activity_id
        from  WF_ITEM_ACTIVITY_STATUSES_V
        WHERE ITEM_TYPE = 'EPBCYCLE'
        AND ITEM_KEY = childItemKey
        and activity_name = 'EXPAPPROVAL';

       exception
          when NO_DATA_FOUND then
             l_activity_id := null;
       end;
       -- if there is a hit then process this
       if l_activity_id is NOT NULL then
          l_ctr := l_ctr+1;
          -- b5102962
          thisUser := substr(wf_directory.getroledisplayname(v_exChild.ASSIGNED_USER), 1, 320);
          -- thisUser := v_approver.ASSIGNED_USER_DISPLAY_NAME;
          -- put label in WF resource?

          if l_ctr = 1 then
            document := document||   htf.tableOpen(cattributes=>'width=100%');
            document := document||   htf.tableRowOpen;
            document := document||   htf.tableData(cvalue=>htf.bold(l_label));
            document := document||   htf.tableData(htf.br);
            document := document||   htf.tableRowClose;
            end if;

          -- Exception results
          document := document||   htf.tableRowOpen;
          document := document||   htf.tableData(cvalue=>thisUser);
          document := document||   htf.tableData(htf.br);
          document := document||   htf.tableRowClose;
       end if;

    end loop;
    -- pool2

  document_type := 'text/html';

  return;

exception

when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','NON_RESPONDERS',ItemType, ItemKey);
  raise;

end NON_RESPONDERS;

-- 5179198 agent by user
procedure REQUEST_EXPLANATIONS (taskID              in  NUMBER,
                                NID                 in  NUMBER,
                                AddMsg              in  varchar2 default NULL,
                                Dtype               in  varchar2 default NULL,
                                Dvalue              in  number default NULL,
                                p_api_version       IN  NUMBER,
                                p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                                p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                                p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                                x_return_status     OUT nocopy varchar2,
                                x_msg_count         OUT nocopy number,
                                x_msg_data          OUT nocopy varchar2)



 IS

   l_api_name      CONSTANT VARCHAR2(30) := 'REQUEST_EXPLANATIONS';
   l_api_version   CONSTANT NUMBER       := 1.0;

   ItemKey varchar2(240);
   ItemType varchar2(30) := 'EPBCYCLE';
   InstanceID number;
   ACID number;
   ACNAME varchar2(256);
   InstDesc  varchar2(256);
   Subject   varchar2(4000);
   Message   varchar2(4000);
   ExcepDim  varchar2(4000);
   ExcepSel  varchar2(4000);
   TaskName  varchar2(256);
   DeadDate date;
   Deadline varchar2(30);
   relative number;
   NEWItemKey varchar2(240);
   workflowprocess varchar2(30) := 'EXPLAIN_MORE';
   rolename varchar2(100);
   thisOwner  varchar2(100);
   thisOwnerID number;
   thisApprover  varchar2(100);
   thisApproverID  number;
   errMsg varchar2(2000);
   NewDispName varchar2(360);
   l_label varchar2(50);

   ProcOwnerID number;           -- B 4106621 URL agent override
   l_htmlagent varchar2(2000);   -- B 4106621 URL agent override
   l_URLexplain varchar2(1000);  --B 4106621 URL
   l_newURL varchar2(2000);      --B 4106621 URL


   CURSOR c_thisowner is
      select distinct OWNER, OWNER_ID, APPROVER, APPROVER_ID
      from ZPB_EXCP_EXPLANATIONS
      where TASK_ID = TaskID and Notification_id = NID and STATUS = 2
      order by OWNER;

    v_thisowner c_thisowner%ROWTYPE;


  BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT zpb_request_explanation;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Begin REQUEST_EXPLANATIONS code
   select ITEM_KEY into ItemKey
   from WF_ITEM_ACTIVITY_STATUSES_V
   where item_type = 'EPBCYCLE' and NOTIFICATION_ID = NID;


   ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'ACID');
   InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
           aname => 'INSTANCEID');
   TaskName := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ItemKey,
             aname => 'TASKNAME');
   Subject := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
         aname => 'SUBJECT');
   Message := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ISSUEMSG');
   ExcepDim := wf_engine.GetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
               aname => 'EXCEPDIM');
   ExcepSel := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
         aname => 'EXCEPSELECTION');
   InstDesc :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
         Itemkey => ItemKey,
         aname => 'INSTANCEDESC');

   -- B 4106621 URL agent override
   --l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', ProcOwnerID);
   --
   l_URLexplain := wf_engine.GetItemAttrText(Itemtype => ItemType,
                     Itemkey => ItemKey,
                     aname => 'URLEXPLAIN');
   --
   --l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;


   if Dtype is not NULL then

        if Dtype = 'DAY' then
           Relative  :=  Dvalue * 1440;
           DeadDate :=  sysdate + DValue;
             elsif Dtype = 'WEEK' then
                 Relative  :=  Dvalue * 7 * 1440;
                 DeadDate :=  sysdate + (DValue * 7);
               elsif Dtype = 'MONTH' then
                   DeadDate :=  add_months(sysdate, Dvalue);
                   Relative := (DeadDate - sysdate) * 1440;
          end if;
   else
        Relative := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
               Itemkey => ItemKey,
         aname => 'EXPDEADLINE');
   end if;


   -- NOTE: need to add owner in.


   -- THE BIG LOOP
   -- FOR EACH OWNER start a explanation required process

   for v_thisowner in c_thisowner loop

      thisOwner := v_thisowner.owner;
      thisOwnerID := v_thisowner.owner_id;
      thisApprover := v_thisowner.approver;
      thisApproverID := v_thisowner.approver_id;

      -- create NEWItemKey for FYI workflow
      NEWItemKey := rtrim(substr(InstDesc, 1, 25), ' ') || '-' || to_char(InstanceID) || '-' || to_char(taskID)  || '-' || thisOwner || '-' || to_char(sysdate, 'MM/DD/YYYY-HH24:MI:SS') || workflowprocess;

      -- SET UP PROCESS for this NEWItemKey!
      -- Create WF start process instance
      wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

      -- This should be the EPB controller.
      wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => thisOwner);


      --=============================================================================
      -- b5179198 URL profile should be set for the ntf target user
      l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', thisOwnerID);
      l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;
      --==============================================================================

      -- B 4106621 URL agent override
      wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'URLEXPLAIN',
            avalue => l_newURL);

     -- **********************************************************
     -- make the Ad Hoc role to hold both the dataowner and shadow
     dbms_lock.sleep(1);
     if zpb_wf_ntf.has_Shadow(thisOwnerID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisOwnerID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisOwner;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisOwner);
         zpb_wf_ntf.add_Shadow(rolename, thisOwnerID);
      else
        rolename := thisOwner;
      end if;

      -- explanation recipient
      wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => rolename);

     -- **********************************************************
     -- make the Ad Hoc role to hold both the APPROVERS and shadow
     if zpb_wf_ntf.has_Shadow(thisApproverID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisApproverID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisApprover;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisApprover);
         zpb_wf_ntf.add_Shadow(rolename, thisApproverID);
      else
        rolename := thisApprover;
      end if;

      -- approver
      wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'FNDUSERNAM',
            avalue => rolename);


      -- plsql document procedure
      wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'EXCEPLIST',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.EXCEP_NTF_LIST/' || TO_CHAR(taskID) || ':' || NID || ':' || thisOwner);

      -- plsql document procedure
      wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'RESPNOTE',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.SHOW_RESP/' || NEWitemkey );

      -- reads parameters and sets attributes for this process
      ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

      wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

      -- set workflow with Instance Cycle ID!
      wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

       -- set Task ID!
       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

       wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);

       wf_engine.SetItemAttrText(Itemtype => ItemType,
           Itemkey => NEWItemKey,
         aname => 'SUBJECT',
                 avalue => Subject);

       if AddMsg is not NULL then
          Message := Message || ' Additional Note: ' || AddMsg;
       end if;

       wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ISSUEMSG',
                 avalue => Message);

       wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'EXCEPDIM',
         avalue => ExcepDim);

       wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'EXCEPSELECTION',
         avalue => ExcepSel);

        wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstDesc);

        -- relative default is Task Deadline!
        wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                     Itemkey => NEWItemKey,
                     aname => 'EXPDEADLINE',
                     avalue => Relative);

        -- Initialize corespondance regesters
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER1',
              avalue => NULL);
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER2',
              avalue => NULL);
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER3',
              avalue => NULL);
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER4',
              avalue => NULL);
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER5',
              avalue => NULL);
                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER6',
                          avalue => NULL);

           -- Now that all is created and set START each independent PROCESS!
           wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => NewItemKey);
   end loop;

   -- b 4948928
   -- if Expired WF users have been detected then send list to BPO or its proxy
   -- otherwise do nothing.

   ProcOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ItemKey,
           aname => 'OWNERID');

   zpb_wf_ntf.SendExpiredUserMsg(ProcOwnerID, taskID, itemType);
   -- end b 4948928


/*
  commit;
  return;
*/

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );


EXCEPTION

/*
  WHEN OTHERS THEN
    raise;
*/


  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

end REQUEST_EXPLANATIONS;

procedure EXCEP_NTF_LIST (document_id in  varchar2,
      display_type  in  varchar2,
      document  in out  nocopy varchar2,
      document_type in out  nocopy varchar2)

IS
    ItemType   varchar2(30) := 'EPBCYCLE';
    ItemKey    varchar2(240);
    taskID     number;
    nid        number;
    startPos1  number;
    startPos2  number;
    DataOwner  varchar2(100);
    l_label   varchar2(200);
    DDate      date;
    Dtext      varchar2(35);
    ResultList varchar2(4000);
    thisMember varchar2(240);
    thisValue  varchar2(1000);
    thisVFlag number;
    l_dimname  varchar2(100);

    CURSOR c_byowner is
      select *
      from ZPB_EXCP_EXPLANATIONS
      where TASK_ID = TaskID and
      NOTIFICATION_ID = nid and
      OWNER = DataOwner and
      status = 2;

      v_byowner c_byowner%ROWTYPE;

BEGIN

     startPos1 := instr(document_id,':')+1;
     startPos2 := instr(document_id, ':', startPos1);
     TaskID := to_number(substr(document_id, 1, instr(document_id,':')-1));
     -- nid := to_number(substr(document_id, startPos1, instr(document_id, ':')-1));
     nid := to_number(substr(document_id, startPos1, startPos2 - startPos1));
     DataOwner := substr(document_id, startPos2+1);


     -- Exceptionable member[s]:

     select value into l_dimname
       from ZPB_TASK_PARAMETERS
       where TASK_ID = TaskID and NAME = 'EXCEPTION_DIMENSION_NAME';

     -- Following  ZPB_WF_DIMNAME members have an alert
     FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_DIMMEMBERS');
     FND_MESSAGE.SET_TOKEN ('ZPB_WF_DIMNAME', l_dimname);
     l_label := FND_MESSAGE.GET;

     -- put label in WF resource?
     document := document||   htf.tableOpen(cattributes=>'width=100%');
     document := document||   htf.tableRowOpen;
     document := document||   htf.tableData(cvalue=>htf.bold(l_label));
     document := document||   htf.tableData(htf.br);
     document := document||   htf.tableRowClose;

     for  v_byowner in c_byowner loop
/*
       thisMember := v_byowner.member_display;

       thisVFlag := v_byowner.VALUE_FLAG;
       if thisVFlag = 0 then
          thisValue := v_byowner.VALUE_CHAR;
          elsif thisVFlag = 1 then
              thisValue := to_char(v_byowner.VALUE_NUMBER);
             elsif thisVFlag = 2 then
                thisValue := to_char(v_byowner.VALUE_DATE);
       end if;
*/
       resultList := v_byowner.member_display;
        -- Exception results
       document := document||   htf.tableRowOpen;
       document := document||   htf.tableData(cvalue=>ResultList);
       document := document||   htf.tableData(htf.br);
       document := document||   htf.tableRowClose;

     end loop;

  document_type := 'text/html';

  return;

  exception
when others then
  wf_core.context('ZPB_EXCEPTION_ALERT','EXCEP_NTF_LIST',ItemType, ItemKey);
  raise;

END EXCEP_NTF_LIST;


-- This launches the process
procedure FYI_BY_OWNER (itemtype in varchar2,
      ParentItemkey  in varchar2,
      taskID in number)
   IS

    ACNAME varchar2(300);
    ACID number;
    ProcOwner  varchar2(30);
    ProcOwnerID number;
    AuthorID number;
    SentToAuthor varchar2(1) := 'N';
    ExcType varchar2(4000);
    rolename varchar2(30);
    relative number :=7;
    InstanceID number;
    InstanceDesc varchar2(300);
    TaskName varchar2(256);
    NEWItemKey varchar2(240);
    workflowprocess varchar2(30) := 'NOTIFYEXCEPT';
    thisItemKey varchar2(240);
    thisOWNER varchar2(100);
    thisOwnerID number;
    errMsg varchar2(2000);
    NewDispName varchar2(360);
    l_label varchar2(50);
    l_authorIDT varchar2(4000);


    CURSOR c_thisowner is
      select distinct OWNER_ID, OWNER
      from ZPB_EXCP_RESULTS
      where TASK_ID = TaskID
      order by OWNER;

      v_thisowner c_thisowner%ROWTYPE;


    CURSOR c_children is
      select ITEM_KEY
      from WF_ITEMS_V
      where PARENT_ITEM_KEY = ParentItemKey;

      v_child c_children%ROWTYPE;


BEGIN
    -- GET current task information.
    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'ACID');
    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'ACNAME');
    ProcOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'OWNERID');
    ProcOwner := zpb_wf_ntf.ID_to_FNDUser(ProcOwnerID);

    InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'INSTANCEID');

   -- set Task Name!
   select TASK_NAME into TaskName
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;

    -- bug 3482485
    select value into l_authorIDT
       from  zpb_task_parameters
       where task_id = TaskID and name = 'OWNER_ID';

    authorID := to_number(l_authorIDT);


   select INSTANCE_DESCRIPTION
   into InstanceDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   select VALUE
   into ExcType
   from ZPB_TASK_PARAMETERS
   where TASK_ID = TaskID and name = 'EXCEPTION_TYPE';

   -- FOR EACH OWNER start a explanation required process
   for  v_thisowner in c_thisowner loop

      thisOwner := v_thisowner.owner;
      thisOwnerID := v_thisowner.owner_id;

      -- create NEWItemKey for FYI workflow
      NEWItemKey := rtrim(substr(ACName, 1, 25), ' ') || '-' || to_char(InstanceID) || '-' || to_char(taskID)  || '-' || thisOwner || '-' || to_char(sysdate, 'MM/DD/YYYY-HH24:MI:SS') || workflowprocess;

      -- SET UP PROCESS for this NEWItemKey!
      -- Create WF start process instance
      wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

     -- This should be the EPB controller.
     wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => ProcOwner);

     --  owner ID
     wf_engine.SetItemAttrNumber(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'OWNERID',
            avalue => ProcOwnerID);


     -- **********************************************************
     -- make the Ad Hoc role to hold both the dataowner and shadow
     if zpb_wf_ntf.has_Shadow(thisOwnerID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisOwner;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisOwner);
         zpb_wf_ntf.add_Shadow(rolename, thisOwnerID);
      else
        rolename := thisOwner;
      end if;

     -- explanation recipient rolename with owner and shadow
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => rolename);


    -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'EXCEPLIST',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.EXP_EXCEP_BY_OWNER/' || TO_CHAR(taskID) || ':' || thisOwner);


   -- reads parameters and sets attributes for this process
   ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

   -- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

   -- set cycle Name!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACNAME',
         avalue => ACNAME);
   -- set Task ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);

   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstanceDesc);


   -- Now that all is created and set START each independent PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => NEWItemKey);

  end loop;


  return;

  exception
   when others then
    -- WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.FYI_BY_OWNER', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end FYI_BY_OWNER;


procedure EXPL_BY_ACOWNER(itemtype in varchar2,
      ParentItemkey  in varchar2,
      taskID in number)
   IS

    ACNAME varchar2(300);
    ACID number;
    owner  varchar2(30);
    InstanceID number;
    InstanceDesc varchar2(300);
    TaskName varchar2(256);
    NEWItemKey varchar2(240);
    workflowprocess varchar2(30) := 'EXPLAINCHILD';
    thisItemKey varchar2(240);
    thisRecipient varchar2(100);
    thisApprover  varchar2(100);
    thisRecipientID number;
    thisApproverID  number;
    errMsg varchar2(2000);
    rolename varchar2(320);
    NewDispName varchar2(360);
    l_label varchar2(30);
    relative number;
    ApproverTYPE varchar2(4000);
    l_htmlagent varchar2(2000);   -- B 4106621 URL agent override
    ProcOwnerID number;           -- B 4106621 URL agent override
    l_URLexplain varchar2(1000);   --B 4106621 URL
    l_newURL varchar2(2000);  --B 4106621 URL


    CURSOR c_children is
      select ITEM_KEY
      from WF_ITEMS_V
      where PARENT_ITEM_KEY = ParentItemKey;

      v_child c_children%ROWTYPE;

BEGIN
    -- GET current task information.
    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'ACID');
    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'ACNAME');

    -- should be GOOD owner
    owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'FNDUSERNAM');

    thisRecipient := owner;

    InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'INSTANCEID');


    -- B 4106621 URL agent override
    ProcOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
           Itemkey => ParentItemKey,
             aname => 'OWNERID');

    l_htmlAgent := FND_PROFILE.VALUE_SPECIFIC('APPS_FRAMEWORK_AGENT', ProcOwnerID);
    l_URLexplain := wf_engine.GetItemAttrText(Itemtype => ItemType,
           Itemkey => ParentItemKey,
                 aname => 'URLEXPLAIN');
    l_newURL := l_htmlAgent || '/OA_HTML/' || l_URLexplain;

   -- set Task Name!
   select TASK_NAME, LAST_UPDATED_BY
   into TaskName, thisApproverID
   from zpb_analysis_cycle_tasks
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = taskid;

   select INSTANCE_DESCRIPTION
   into InstanceDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   select value
    into ApproverTYPE
    from ZPB_TASK_PARAMETERS
    where TASK_ID = TaskID and name = 'EXPLANATION_APPROVER';

   if ApproverTYPE = 'AUTHOR_OF_EXCEPTION' then
     thisApprover := zpb_wf_ntf.ID_to_fnduser(thisApproverID);
   end if;


      -- create NEWItemKey for FYI workflow
      NEWItemKey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(InstanceID) || '-' || to_char(taskID)  || '-' || thisRecipient || '-' || workflowprocess;

      -- SET UP PROCESS for this NEWItemKey!
      -- Create WF start process instance
      wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         process => WorkflowProcess);

      -- SETITEMPARENT! NewItemKey is the CHILD!
      wf_engine.SetItemParent(ItemType => ItemType,
                         itemKey => NEWItemKey,
                         PARENT_ITEMTYPE => ItemType,
                         PARENT_ITEMKEY => ParentItemKey,
                         PARENT_CONTEXT => NULL);

     -- This should be the EPB publisher controller.
     wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);


     -- B 4106621 URL agent override
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'URLEXPLAIN',
            avalue => l_newURL);

    -- explanation recipient
    -- make the Ad Hoc role to hold both the dataowner and shadow


     thisRecipientID := zpb_wf_ntf.fnduser_to_ID(thisRecipient);
     if zpb_wf_ntf.has_Shadow(thisRecipientID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisRecipientID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisRecipient;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
         zpb_wf_ntf.add_Shadow(rolename, thisRecipientID);
      else
        rolename := thisRecipient;
      end if;

     -- explanation recipient rolename with owner and shadow
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'EPBPERFORMER',
            avalue => rolename);


     -- **********************************************************
     -- make the Ad Hoc role to hold both the APPROVERS and shadow

     if zpb_wf_ntf.has_Shadow(thisApproverID) = 'Y' then
        rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID, thisApproverID);
        select distinct display_name
           into NewDispName
           from wf_users
           where name = thisApprover;

           -- add (And Shadows) display to role dispaly name
           FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
           l_label := FND_MESSAGE.GET;
           NewDispName := NewDispName || l_label;

         zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisApprover);
         zpb_wf_ntf.add_Shadow(rolename, thisApproverID);
      else
        rolename := thisApprover;
      end if;

     -- approver
     wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => NEWItemKey,
            aname => 'FNDUSERNAM',
            avalue => rolename);


    -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'EXCEPLIST',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.EXCEPTION_LIST/'|| TO_CHAR(taskID)||':'||NEWItemKey);

   -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
  itemkey  => NEWItemKey,
  aname    => 'RESPNOTE',
  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.SHOW_RESP/' || NEWitemkey );


   -- reads parameters and sets attributes for this process
   ZPB_EXCEPTION_ALERT.SET_ATTRIBUTES(itemtype, NEWItemkey, taskID);

   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACID',
         avalue => ACID);

   -- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEID',
                 avalue => InstanceID);

   -- set cycle Name!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'ACNAME',
         avalue => ACNAME);
   -- set Task ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
         Itemkey => NEWItemKey,
                   aname => 'TASKID',
         avalue => TaskID);

   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'TASKNAME',
         avalue => TaskName);

   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
         Itemkey => NEWItemKey,
         aname => 'INSTANCEDESC',
         avalue => InstanceDesc);


                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER1',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER2',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER3',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER4',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER5',
              avalue => NULL);

                 wf_engine.SetItemAttrText(Itemtype => ItemType,
                              Itemkey => NEWItemKey,
                              aname => 'REGISTER6',
                          avalue => NULL);



   -- START IT!
   for  v_child in c_children loop

      thisItemKEY := v_child.ITEM_KEY;
      -- Now that all is created and set START each CHILD PROCESS!
      wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => thisItemKey);
   end loop;

  return;

  exception
   when others then
    -- WF_CORE.CONTEXT('ZPB_EXCEPTION_ALERT.EXPL_BY_ACOWNER', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end EXPL_BY_ACOWNER;


end ZPB_EXCEPTION_ALERT;

/
