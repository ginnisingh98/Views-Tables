--------------------------------------------------------
--  DDL for Package Body ZPB_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_WF_NTF" AS
/* $Header: zpbwfntf.plb 120.6 2007/12/04 16:23:24 mbhat ship $ */

PROCEDURE SetRole (AdHocRole in varchar2, ExpDays in number, RoleDisplay in varchar2 default NULL)
IS
   -- May replace with AdHocRole
   roleDisplayName varchar2(320) := AdHocRole;
   roleName varchar2(320) :=AdHocRole;
   addDays number :=ExpDays;

BEGIN

   if RoleDisplay is not NULL then
      roleDisplayName := RoleDisplay;
   end if;

   wf_directory.CreateAdHocRole(role_name => roleName,
			role_display_name => roleDisplayName,
                                language  => NULL,
                                territory => NULL,
                         role_description => NULL,
                 notification_preference  => 'MAILHTML',
                               role_users => NULL,
                           email_address  => NULL,
                                fax       => NULL,
                                status    => 'ACTIVE',
                         expiration_date  => sysdate+addDays);
end SetRole;
--
--

procedure VALIDATE_BUS_AREA (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)

IS

    TaskID number;
    l_business_area_id number;
    l_version_id number;



    CURSOR c_val_msgs is
       select  error_type, message
       from ZPB_BUSAREA_VALIDATIONS;

      l_cur_rec c_val_msgs%ROWTYPE;

    errorlist varchar2(4000) := null;
    warninglist varchar2(4000) := null;
    l_chr_newline VARCHAR2(8);

BEGIN
    l_chr_newline := fnd_global.newline;
    IF (funcmode = 'RUN') THEN
        TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');

        select business_area_id into l_business_area_id
            from zpb_analysis_cycles
            where analysis_cycle_id = (select analysis_cycle_id
                from zpb_analysis_cycle_tasks where task_id = TaskId);

        wf_engine.SetItemAttrText(Itemtype => ItemType,
        	Itemkey => ItemKey,
       	    aname => 'BUSINESSAREAID',
            avalue => l_business_area_id);

        select VERSION_ID into l_version_id
            from ZPB_BUSAREA_VERSIONS
            where VERSION_TYPE = 'P' and BUSINESS_AREA_ID = l_business_area_id;

        wf_engine.SetItemAttrText(Itemtype => ItemType,
        	Itemkey => ItemKey,
           	aname => 'VERSIONID',
            avalue => l_version_id);

        ZPB_BUSAREA_VAL.VAL_AGAINST_EPB(l_version_id);
        ZPB_BUSAREA_VAL.VAL_AGAINST_EPF(l_version_id);
        ZPB_BUSAREA_VAL.VAL_DEFINITION(l_version_id);

            for  l_cur_rec in c_val_msgs loop
                if l_cur_rec.error_type = 'E'  then
                    errorlist := errorlist || l_cur_rec.message || l_chr_newline;
                elsif l_cur_rec.error_type = 'W'  then
                    warninglist := warninglist || l_cur_rec.message || l_chr_newline;
                end if;
            end loop;

            if errorlist is not null then
                resultout:= 'E';
            elsif warninglist is not null then
                resultout := 'W';
            else
                resultout := 'N';
            end if ;
            wf_engine.SetItemAttrText(Itemtype => ItemType,
            	Itemkey => ItemKey,
               	aname => 'VALIDATIONERROR',
                avalue => ERRORLIST);

            wf_engine.SetItemAttrText(Itemtype => ItemType,
            	Itemkey => ItemKey,
               	aname => 'VALIDATIONWARNING',
                avalue => warninglist);

    END IF;

 return;

 exception
   when NO_DATA_FOUND then
         Null;

   when others then
     WF_CORE.CONTEXT('ZPB_WF_NTF.VALIDATE_BUS_AREA', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end VALIDATE_BUS_AREA;


PROCEDURE RemUser (AdHocRole in varchar2,
                   UserList in varchar2)
IS
   roleName varchar2(320) :=AdHocRole;
BEGIN
 wf_directory.RemoveUsersFromAdHocRole(roleName, UserList);
end RemUser;


--
--
-- RemALL cleans up wf_local_roles.  It is called from OES by ntf.purgerole
-- ntf.purgerole also calls wf_purge.notificatons and wf_purgeItem
-- along with this so all expired notifications are cleaned.
-- These are called by expiration_date.
--
PROCEDURE RemALL (AdHocRole in varchar2)
IS
   roleName varchar2(320) :=AdHocRole;
BEGIN
  wf_directory.RemoveUsersFromAdHocRole(roleName);

  delete wf_local_roles
  where name = roleName;

  commit;

exception
   when others then
     raise;

end RemALL;


function MakeRoleName (ACID in Number, TaskID in Number, UserID in Number default NULL) return varchar2

   AS

   charDate varchar2(20);
   rolename varchar2(320);
   lcount number;

   BEGIN

   lcount := 1;

   while lcount > 0
    loop

    charDate := to_char(sysdate, 'J-SSSSS');
    if UserID is not NULL then
       rolename := 'ZPB'|| to_char( TaskID) || '-' || charDate || '-' || UserID;
    else
       rolename := 'ZPB'|| to_char( TaskID) || '-' || charDate;
    end if;

    select count(name)
      into lcount
      from wf_roles
      where name = rolename;

    if lcount > 0 then
       dbms_lock.sleep(1);
    end if;

    end loop;


   return rolename;

   exception
   when others then
       raise;

END;


function GetFNDResp (RespKey in Varchar2) return varchar2

   AS

   rolename varchar2(320);
   respID number;
   appID number;

   BEGIN

   select APPLICATION_ID
   into appID
   from FND_APPLICATION
   where APPLICATION_SHORT_NAME  = 'ZPB';


   if RespKey = 'ZPB' then
      rolename := 'FND_RESP'|| appID;
      return rolename;
   else

      select RESPONSIBILITY_ID
      into respID
      from fnd_responsibility_vl
      where APPLICATION_ID = appID and RESPONSIBILITY_KEY = RespKey;

      rolename := 'FND_RESP'|| appID || ':' || respID;
      return rolename;

   end if;

   exception
   when NO_DATA_FOUND then
    return 'NOT_FOUND';

   when others then
       raise;

END;

procedure SET_ATTRIBUTES (itemtype in varchar2,
            		  itemkey  in varchar2,
	 	          actid    in number,
 		          funcmode in varchar2,
                          resultout   out nocopy varchar2)
 IS

    ACNAME varchar2(300);
    ACID number;
    errMsg varchar2(320);
    ActEntry varchar2(30);
    TaskID number;
    RoleName varchar2(320);
    InstDesc varchar2(300);
    InstanceID number;
    Deadline varchar2(30);
    DeadDate date;
    Relative number := 0;
    DType  varchar(24);
    WDeadline varchar2(30);
    WType  varchar(24);
    workflowprocess varchar2(30);
    TASKPARAMNAME varchar2(100);
    UserList varchar(4000);
    Subject  varchar(4000);
    Message  varchar(4000);
    UserToNotifyP varchar2(1);
    authorID number;
    l_authorIDT varchar2(4000);
    thisOwnerID number;
    thisOwner varchar2(150);
    l_business_area_id number;
    l_deadDate varchar2(100);

    CURSOR c_tparams is
      select NAME, value
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID;

      v_tparams c_tparams%ROWTYPE;


CURSOR c_baControllers is
     select C.USER_NAME
	from FND_RESPONSIBILITY A,
         ZPB_ACCOUNT_STATES B,
		 FND_USER C
	where B.BUSINESS_AREA_ID = l_business_area_id AND
	      A.RESPONSIBILITY_ID = B.RESP_ID AND
		  A.RESPONSIBILITY_KEY = 'ZPB_SUPER_CONTROLLER_RESP' AND
		  C.USER_ID = B.USER_ID ;

      v_baControllers c_baControllers%ROWTYPE;

CURSOR c_bpadmin is
    select C.USER_NAME
	from FND_RESPONSIBILITY A,
	     ZPB_ACCOUNT_STATES B,
		 FND_USER C
	where A.RESPONSIBILITY_ID = B.RESP_ID AND
		  A.RESPONSIBILITY_KEY = 'ZPB_CONTROLLER_RESP' AND
		  C.USER_ID = B.USER_ID ;

      v_bpadmin c_bpadmin%ROWTYPE;

-- B4951035 - ACID was hard coded to 8891.
CURSOR c_bpowner is
     select C.USER_NAME
		  from zpb_analysis_cycles A,
		  	   FND_USER C
		  where analysis_cycle_id = ACID AND
		  		C.USER_ID = A.OWNER_ID ;

	 v_bpowner c_bpowner%ROWTYPE;

 BEGIN

 IF (funcmode = 'RUN') THEN
   resultout :='COMPLETE:B';


   SELECT ACTIVITY_NAME, PROCESS_NAME INTO ActEntry, workflowprocess
    FROM WF_PROCESS_ACTIVITIES
    WHERE INSTANCE_ID=actid;


   -- B 4951035 - ERROR IN CODE FOR NOTIFICATIONS TO BPO
   ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
         	       aname => 'ACID');

   ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
 		       Itemkey => ItemKey,
        	       aname => 'ACNAME');


   TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');


   InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'INSTANCEID');


   thisOwnerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
      	 	       aname => 'OWNERID');
   thisOwner := zpb_wf_ntf.ID_to_FNDUser(thisOwnerID);


select business_area_id into l_business_area_id from
zpb_analysis_cycles where analysis_cycle_id = (select analysis_cycle_id
from zpb_analysis_cycle_tasks where task_id = TaskId) ;

   select INSTANCE_DESCRIPTION
   into InstDesc
   from ZPB_ANALYSIS_CYCLE_INSTANCES
   where INSTANCE_AC_ID = InstanceID;

   -- set descripton
   wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'INSTANCEDESC',
			   avalue => InstDesc);


   -- set up last_updated_by as authorID and who
   -- the notification is from.
   -- if workflowprocess = 'NOTIFY' then
   -- bug 3482485

    select value into l_authorIDT
       from  zpb_task_parameters
       where task_id = TaskID and name = 'OWNER_ID';

    authorID := to_number(l_authorIDT);

    wf_engine.SetItemAttrText(Itemtype => ItemType,
	Itemkey => ItemKey,
       	aname => '#FROM_ROLE',
        avalue => ZPB_WF_NTF.ID_to_FNDUser(authorID));

   -- end if;

   -- read parameters from ZPB_TASK_PARAMETERS using task ID.

  UserList := 'NONE';
  Dtype := 'NONE';
  UserToNotifyP := 'N';

   for  v_tparams in c_tparams loop

     taskParamName := v_tparams.name;
     if taskParamName = 'NOTIFY_SUBJECT' then
        Subject := v_tparams.value;

       wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'SUBJECT',
			   avalue => Subject);

        elsif taskParamName = 'NOTIFY_CONTENT' then
              Message := v_tparams.value;

              wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'ISSUEMSG',
            		   avalue => message);

              elsif taskParamName = 'DURATION_TYPE' then
                  DType := v_tparams.value;
                  elsif taskParamName = 'DURATION_VALUE' then
                  Deadline := v_tparams.value;

                     elsif taskParamName = 'USERS_TO_NOTIFY' then
                     UserList := v_tparams.value;
                     UserToNotifyP :=  'Y';

                       elsif taskParamName = 'WAIT_TYPE' then
                               DType := v_tparams.value;
                                 elsif taskParamName = 'WAIT_VALUE' then
                                     Deadline := v_tparams.value;



                    	elsif taskParamName = 'NOTIFY_BACONTROLLERS' then

                    		for c_rec in c_baControllers
                            loop
  			                   UserList :=  UserList ||', '||c_rec.user_name;
                            end loop;
                                UserToNotifyP :=  'Y';

                        	elsif taskParamName = 'NOTIFY_BPADMIN' then

                        		for c_rec in c_bpadmin
                                loop
                                    UserList :=  UserList ||', '||c_rec.user_name;
                                end loop;
                               		UserToNotifyP :=  'Y';

                                -- B4951035 future issue
                                --  NOTE none of the NOTIFY_B param names are in fnd_lookups
                                --  this looks like it was not fully implementd and
                                --  can not ever execute with typeO in NOTIFY_BPOWNER
                                --  I do not know if it should execute.  I currently will not change
                                --  this.

                            	elsif taskParamName = 'NOTIFY_BPOWNERN' then

                            		for c_rec in c_bpowner
		                            loop
                             			UserList :=  UserList ||', '||c_rec.user_name;
                            		end loop;
                                		UserToNotifyP :=  'Y';

      else
         errMsg := v_tparams.value;
      end if;

     end loop;


      if Dtype <> 'NONE' then

         if Dtype = 'DATE' then
            DeadDate := to_Date(Deadline,'YYYY/MM/DD-HH24:MI:SS');
            Relative := (DeadDate - sysdate) * 1440;
           elsif Dtype = 'DAY' then
              Relative  :=  to_number(Deadline)* 1440;
              DeadDate :=  sysdate + to_number(Deadline);
            elsif Dtype = 'WEEK' then
                Relative  :=  to_number(Deadline)* 7 * 1440;
                DeadDate :=  sysdate + (to_number(Deadline) * 7);
               elsif Dtype = 'MONTH' then
                  DeadDate :=  add_months(sysdate, to_number(Deadline));
                  Relative := (DeadDate - sysdate) * 1440;
          end if;

          l_deadDate := to_char(DeadDate,'DD-MON-YY HH24:MI:SS');

          -- relative default is 0 not delay!
          wf_engine.SetItemAttrNumber(Itemtype => ItemType,
   	                   Itemkey => ItemKey,
    	                   aname => 'WAITDEADLINE',
 	                   avalue => Relative);

          -- relative default is 0 not delay!
          wf_engine.SetItemAttrText(Itemtype => ItemType,
   	                   Itemkey => ItemKey,
    	                   aname => 'DEADLINEDISP',
 	                   avalue => l_deadDate);
       end if;

    -- Create AdHoc Roles when needed and set user lists for WF Directory
    -- sets wf_local_roles, wf_local_user_roles for views wf_users, wf_roles
    -- and wf_user_roles.

    if UserToNotifyP = 'Y' then

    -- test fix 11/18/2003
    if UserList = 'NONE' then
          resultout := 'COMPLETE:B';
          return;
    end if;

      -- this is support for * OLD STYLE * user_to_notify
      if UserList is not NULL OR UserList <> 'NONE' then
         -- B4951035 prevent relative from being passed as zero, that is now bad for WF
         RoleName := zpb_wf_ntf.OLD_STYLE_USERS(instanceID, taskID, thisOwner, thisOwnerID, relative+7, UserList);

         if RoleName <> '#NOROLE#' then
             wf_engine.SetItemAttrText(Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'EPBPERFORMER',
         	  avalue => RoleName);
         end if;
        -- this is set to A becuase at startup EPBPERFORMER is defaulted to BPcycle owner/publisher.
         resultout := 'COMPLETE:A';
       else
         -- UserList is NONE if none you can go around the notification.
         resultout := 'COMPLETE:B';
     end if;

   else  -- users_to_notify_param=N

      -- B4951035 prevent relative from being passed as zero, that is now bad for WF
      UserToNotifyP := zpb_wf_ntf.set_users_to_notify(taskID, ItemKey, workflowprocess, relative+7, thisOwner, thisOwnerID);

      if UserToNotifyP = 'B' then
         resultout := 'COMPLETE:B';
      else
         resultout := 'COMPLETE:A';
      end if;

   end if;


   -- b 4948928
   -- if Expired WF users have been detected then send list to BPO or its proxy
   -- otherwise do nothing.
   zpb_wf_ntf.SendExpiredUserMsg(thisOwnerID, TaskID, itemType);


 END IF;
 return;

 exception
   when NO_DATA_FOUND then
         Null;

   when others then
     WF_CORE.CONTEXT('ZPB_WF.SET_ATTRIBUTES', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end SET_ATTRIBUTES;

procedure SET_PAUSE (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS

-- NOTE: all values are for the WF that is ending need new values set for the
-- process to be started.

    ACID number;
    ACNAME varchar2(300);
    TaskID number;
    InstanceID number;
    charDate varchar2(30);
    DeadDate date;
    workflowprocess varchar2(30);
    UserList varchar(4000);

   BEGIN

   IF (funcmode = 'RUN') THEN

       ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'ACID');

       ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
        	       aname => 'ACNAME');

       TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'TASKID');

       InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
	  	       aname => 'INSTANCEID');


--       owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
--		       Itemkey => ItemKey,
--      	       aname => 'FNDUSERNAM');

	  -- first save the current status code in previous status code field
	  update ZPB_ANALYSIS_CYCLES
          set prev_status_code = status_code
          where ANALYSIS_CYCLE_ID = InstanceID;

	  -- then update status_code to PAUSED
          update ZPB_ANALYSIS_CYCLES
          set status_code = 'PAUSED'
          where ANALYSIS_CYCLE_ID = InstanceID;

	  -- Set the ReviewBP task whose notification action caused the
          -- instance to be paused to complete
          -- This is normally done in RunNextTask procedure, but this task
          -- never calls that procedure
	  update ZPB_ANALYSIS_CYCLE_TASKS
	  set status_code = 'COMPLETE'
          where TASK_ID = TaskID;

    resultout :='COMPLETE';

  END IF;
  return;

  exception
   when NO_DATA_FOUND then
         Null;

   when others then
     WF_CORE.CONTEXT('ZPB_WF.RunNextTask', itemtype, itemkey, to_char(actid), funcmode);
     raise;

 end SET_PAUSE;

function Get_EPB_Users (RespKey in Varchar2) return clob
   AS

  -- UserList varchar2(4000);
   UserList clob;
   userhold varchar2(30);
   fndResp varchar2(30);

   CURSOR c_users is
   select user_name
   from wf_user_roles
   where role_name = fndResp;

   v_users c_users%ROWTYPE;


   CURSOR c_zpbusers is
   select distinct user_name
   from wf_user_roles
   where ROLE_ORIG_SYSTEM = fndResp;

   v_zpbusers c_zpbusers%ROWTYPE;

   BEGIN

    fndResp := ZPB_WF_NTF.GetFNDResp(RespKey);

     if RespKEY = 'ZPB' then
       -- by application
       for  v_zpbusers in c_zpbusers loop
          if c_zpbusers%ROWCOUNT = 1 then
             userlist := v_zpbusers.user_name;
          else
             userhold := v_zpbusers.user_name;
             userlist := userlist ||',' || userhold;
          end if;
     end loop;

    else
      -- by responsibility
      for  v_users in c_users loop
         if c_users%ROWCOUNT = 1 then
            userlist := v_users.user_name;
         else
            userhold := v_users.user_name;
            userlist := userlist ||',' || userhold;
         end if;
      end loop;

   end if;

   return userlist;

   exception
   when others then
       raise;

END;

function NotifyForTask (TaskID in Number) return varchar2

   AS

   itemtype varchar2(8) := 'EPBCYCLE';
   workflowProcess varchar2(30) := 'NOEVENTNTF';
   itemkey 	      varchar2(240);
   UserName varchar2(30);
   ACName varchar2(300);
   ACIDEvent number;
   TaskName varchar2(256);
   charDate varchar2(30);
   owner varchar2(30) := fnd_global.user_name;
   ownerID 	number := fnd_global.USER_ID;
   respID number := fnd_global.RESP_ID;
   respAppID number := fnd_global.RESP_APPL_ID;


   CURSOR c_eventACID is
   select  distinct v.analysis_cycle_id thisACID, v.name thisACName,
   u.user_name thisUser
   from zpb_all_cycles_v v, zpb_process_details_v pro, fnd_user u
   where  v.analysis_cycle_id in (select pa.analysis_cycle_id from zpb_ac_param_values pa
   where pa.param_id = 20 and pa.value in(select d.value from ZPB_PROCESS_DETAILS_V d
   where d.name = 'CREATE_EVENT_IDENTIFIER' and d.task_id = TaskID))
   and v.last_updated_by = u.user_id;

  -- v_eventACID c_eventACID%ROWTYPE;

   BEGIN

   select task_name into TaskName
   from zpb_process_details_v
   where task_id = TaskID and name = 'CREATE_EVENT_IDENTIFIER';

   ACIDEvent := NULL;
   FOR each in c_eventACID loop
     ACIDEvent := each.thisACID;
     ACName    := each.thisACName;
     UserName  := each.thisUser;

-- create itemkey for workflow
charDate := to_char(sysdate, 'MM/DD/YYYY-HH24:MI:SS');
itemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACIDEvent) || '-0-' || workflowprocess || '-' || charDate ;

-- Create WF start process instance
    wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => ItemKey,
                         process => WorkflowProcess);


-- set Cycle ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'ACID',
			   avalue => ACIDEvent);
-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'ACNAME',
			   avalue => ACNAME);

-- set task Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'TASKNAME',
			   avalue => TaskName);

-- This should be the EPB controller user.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => ItemKey,
                           owner => owner);

-- set EPBPerformer to owner name for notifications!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'EPBPERFORMER',
			   avalue => UserName);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'OWNERID',
			   avalue => ownerID);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'RESPID',
			   avalue => respID);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'RESPAPPID',
			   avalue => respAppID);

  wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => '#FROM_ROLE',
			   avalue => owner);

-- Now that all is created and set: START the PROCESS!

   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => ItemKey);
   commit;

   end loop;

   if ACIDEvent is Null then
      return 'NONE_FOUND';
   else
      return 'NOTIFIED';
   end if;

   exception
   when others then
       raise;

END;

procedure NOTIFY_ON_DELETE (numericID in number,
                    IDType in Varchar2 default 'TASK')

IS

  retval varchar2(30);
  taskID number;

  CURSOR c_acid is
  select TASK_ID, TASK_NAME
  from ZPB_PROCESS_DETAILS_V
  where ANALYSIS_CYCLE_ID = numericID AND
  name = 'CREATE_EVENT_IDENTIFIER';

  v_acid c_acid%ROWTYPE;

BEGIN

 if IDType = 'TASK' then
     retval := NotifyForTask(numericID);
 else
     for  v_acid in c_acid loop
        if c_acid%ROWCOUNT >= 1 then
           taskID :=v_acid.task_id;
           retval := NotifyForTask(taskID);
        end if;
     end loop;
 end if;

 exception
   when others then
       raise;

end NOTIFY_ON_DELETE;



Function SET_USERS_TO_NOTIFY (taskID in number,
           		  itemkey  in varchar2,
                          workflowprocess in varchar2,
                          relative in number,
                          thisOwner in varchar2,
                          thisOwnerID in number) return varchar2

   IS

    errMsg varchar2(320);
    RoleName varchar2(320);
    TASKPARAMNAME varchar2(100) := NULL;
    UserList varchar2(2000);
    UserToNotifyP varchar2(1);
    Rtype varchar2(4000) := NULL;
    thisRecipient varchar2(100);
    thisUserID number;
    cCount number;
    InstanceID number;
    itemtype varchar2(30) := 'EPBCYCLE';
    l_label varchar2(50);
    NewDispName varchar2(360);


    CURSOR c_recipient is
      select NAME, value
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID and name = 'SPECIFIED_NOTIFICATION_RECIPIENT';

      v_recipient c_recipient%ROWTYPE;

    CURSOR c_type is
      select name, value
      from ZPB_TASK_PARAMETERS
      where TASK_ID = TaskID and name =  'NOTIFICATION_RECIPIENT_TYPE';

      v_type c_type%ROWTYPE;


   BEGIN
   for  v_type in c_type loop
      TASKPARAMNAME := v_type.name;
      Rtype := v_type.value;
   end loop;

  if TASKPARAMNAME is NULL then
     if workflowprocess = 'WAIT_TASK' then
       return 'A';
      else
       return 'B';
      end if;
   end if;

   select count(*)
   into cCount
   from ZPB_TASK_PARAMETERS
   where TASK_ID = TaskID and name = 'SPECIFIED_NOTIFICATION_RECIPIENT';


  InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
               Itemkey => ItemKey,
 	       aname => 'INSTANCEID');
   if Rtype = 'SPECIFIED' then

      for  v_recipient in c_recipient loop
           thisRecipient := v_recipient.value;

           if c_recipient%ROWCOUNT = 1 then
              if cCount > 1 then

                 -- THIS SHOULD NOT BE FOR REVIEW FRAMEWORK  - FYI style
                 rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                 zpb_wf_ntf.SetRole(rolename, relative+7);
                 ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
                 thisUserID := FNDUser_to_ID(thisRecipient);
                 zpb_wf_ntf.add_Shadow(rolename, thisUserID);

               else

                 -- THIS CAN BE FOR REVIEW FRAMEWORK  - response style
                 -- only one user
                 thisUserID := FNDUser_to_ID(thisRecipient);
                 -- make the Ad Hoc role to hold both the dataowner and shadow
                 if zpb_wf_ntf.has_Shadow(thisUserID) = 'Y' then
                    rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                    select distinct display_name
                      into NewDispName
                      from wf_users
                      where name = thisRecipient;
                      -- add (And Shadows) display to role dispaly name
                      FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
                      l_label := FND_MESSAGE.GET;
                      NewDispName := NewDispName || l_label;

                      zpb_wf_ntf.SetRole(rolename, relative+7, NewDispName);
                      ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
                      zpb_wf_ntf.add_Shadow(rolename, thisUserID);
                  else
                      rolename := thisRecipient;
                  end if;
              end if;
           else
             -- not for Review Framework
             -- b 4948928 added test as part of this bug premptively
             if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
                ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
             end if;

             thisUserID := FNDUser_to_ID(thisRecipient);
             zpb_wf_ntf.add_Shadow(rolename, thisUserID);
           end if;

        end loop;
      elsif Rtype = 'ZPB_CONTROLLER_RESP' then
             -- transform to FND resp.
             roleName := zpb_wf_ntf.GetFNDResp('ZPB_CONTROLLER_RESP');
             elsif Rtype = 'ZPB_ALL_USERS' then

                   -- transform to all ZPB users.
                   -- not setting shadows for all users
                   rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                   zpb_wf_ntf.SetRole(rolename, relative+7);
                   zpb_wf_ntf.Set_EPB_Users(rolename, 'ZPB');

                elsif Rtype = 'OWNER_OF_AC' then
                      -- uses thisOwner
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
                    elsif Rtype = 'NONE' or Rtype is NULL then
                        return 'B';
      end if;

      wf_engine.SetItemAttrText(Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'EPBPERFORMER',
         	  avalue => RoleName);

  return 'A';

exception

   when NO_DATA_FOUND then
    return 'NO_DATA';

   when others then
     raise;

end;


-- This finds all EPB users and sets them to a WF role for
-- a notification to all users.
Procedure Set_EPB_Users (rolename in Varchar2, RespKey in Varchar2)
   AS

   UserList varchar2(2000);
   userhold varchar2(100);
   fndResp varchar2(30);
   cntr number :=1;

   CURSOR c_zpbusers is
   select distinct user_name
   from wf_user_roles
   where ROLE_ORIG_SYSTEM = fndResp;

   v_zpbusers c_zpbusers%ROWTYPE;

   BEGIN

     fndResp := ZPB_WF_NTF.GetFNDResp(RespKey);

       -- by application
       for  v_zpbusers in c_zpbusers loop
          if cntr = 1 then
             userlist := v_zpbusers.user_name;
             cntr := cntr+1;
          else
             userhold := v_zpbusers.user_name;
             userlist := userlist ||',' || userhold;
             cntr := cntr+1;
             if cntr = 20 then
                ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, UserList);
                UserList := NULL;
                cntr := 1;
             end if;
          end if;
     end loop;

     if UserList is not NULL then
        ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, UserList);
     end if;

   return;

   exception
   when others then
       raise;

 END Set_EPB_Users;

 /*=========================================================================+
 |                       FUNCTION update_Role_with_Shadows
 |
 | DESCRIPTION
 |   Updates the role with shadow users(if any) of the present user.
 |   and returns the same.
 |
 +=========================================================================*/
 function update_Role_with_Shadows (roleName varchar2, thisUser in varchar2 ) return varchar2
   AS
   thisUserID number;
   BEGIN
       thisUserID := FNDUser_to_ID(thisUser);
       if has_Shadow(thisUserID) = 'Y' then
           zpb_wf_ntf.add_Shadow(roleName, thisUserID);
       end if;

       -- abudnik 01JAN20 bUG 4641877
       if zpb_wf_ntf.user_in_role(rolename, thisUser) = 'N'  then
          ZPB_UTIL_PVT.AddUsersToAdHocRole(roleName, thisUser);
       end if;


       return roleName;

   exception

   when others then
       raise;

END;


function ID_to_FNDUser (userID in number) return varchar2
   AS

   fndUser varchar2(150);
   respID number;
   appID number;

   BEGIN


      select user_name into fndUser
      from fnd_user
      where user_id = userID;

      return fndUser;

   exception
   when NO_DATA_FOUND then
    return 'NOT_FOUND';

   when others then
       raise;

END;

function FNDUser_to_ID (fndUser in varchar2) return number
   AS

   userID number;
   respID number;
   appID number;

   BEGIN

      select user_id into userID
      from fnd_user
      where user_name = fndUser;

      return userID;

   exception
   when NO_DATA_FOUND then
    return 'NOT_FOUND';

   when others then
       raise;

END;

procedure ADD_SHADOW (rolename in varchar2, UserId in Number)

   AS

   thisID number;
   thisRecipient varchar2(100);

   CURSOR c_shadow is
   select shadow_id
   from zpb_shadow_users
   where user_id = UserId and privilege_lookup in ('FULLACCESS', 'NOTIFICATIONSONLY');

   v_shadow c_shadow%ROWTYPE;

   BEGIN


     for  v_shadow in c_shadow loop
          thisID := v_shadow.shadow_id;
          thisRecipient := ID_to_FNDUser(thisID);
          if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
             ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
          end if;
     end loop;

   return;

   exception

    when NO_DATA_FOUND then
         Null;

    when others then
            raise;

end ADD_SHADOW;

function USER_IN_ROLE (rolename in varchar2, UserName in varchar2) return varchar2

   AS

   thisUser varchar2(100) := NULL;

   CURSOR c_wfrole is
   select user_name
   from wf_user_roles
   where role_name  = rolename and user_name = UserName;

   v_wfrole c_wfrole%ROWTYPE;

   BEGIN

     for  v_wfrole in c_wfrole loop
          thisUser := v_wfrole.USER_NAME;
     end loop;

    if thisUser is NULL then
       return 'N';
    else
       return 'EXISTS';
    end if;


   exception

    when NO_DATA_FOUND then
         Null;

    when others then
            raise;

END;

Function HAS_SHADOW (userId in Number) return varchar2

   AS

   thisID number;
   thisRecipient varchar2(100);
   l_status varchar2(4) := 'N';

   CURSOR c_shadow is
   select shadow_id
   from zpb_shadow_users
   where user_id = UserId and privilege_lookup in ('FULLACCESS', 'NOTIFICATIONSONLY');

   v_shadow c_shadow%ROWTYPE;

   BEGIN

     for  v_shadow in c_shadow loop
         thisID := v_shadow.shadow_id;
         l_status := 'Y';
     end loop;

   return l_status;

   exception

    when NO_DATA_FOUND then
         Null;

    when others then
            raise;

END;


FUNCTION OLD_STYLE_USERS(instanceID in number, taskID in number, thisOwner in varchar2, thisOwnerID in number, relative in number DEFAULT 0, UserList in varchar2 DEFAULT NULL) return varchar2

IS

l_type varchar2(12);
l_label varchar2(50);
newDispName varchar2(360);
rolename varchar2(320);
curUser varchar2(150);
curUserId number;
l_UserList varchar2(2000);


BEGIN

    rolename := '#NOROLE#';

     -- Owner of Buisness Process
     if  UserList = 'OWNER_OF_AC' then
         curUser := thisOwner;
         curUserID := thisOwnerID;
         l_type := 'SET_THE_ROLE';

           elsif UserList = 'ZPB_CONTROLLER_RESP' then

               -- transform to FND resp.
               roleName := zpb_wf_ntf.GetFNDResp('ZPB_CONTROLLER_RESP');
               l_type := 'ALREADY_SET';

               elsif UserList = 'ZPB_ALL_USERS' then
                   -- transform to all ZPB users. so no need to add shadows.
                   rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                   zpb_wf_ntf.SetRole(rolename, relative+7);
                   l_UserList := zpb_wf_ntf.Get_EPB_Users('ZPB');
                   ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, l_UserList);
                   l_type := 'ALREADY_SET';

                 elsif instr(UserList, ',') > 0 then
                     -- FND user names list so build Ad Hoc role
                     rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
                     zpb_wf_ntf.SetRole(rolename, relative+7);
                     ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, UserList);
                     l_type := 'ALREADY_SET';

                     -- a single user selected
                     elsif instr(UserList, ',') = 0 then
                        curUser := UserList;
                        curUserID := zpb_wf_ntf.FNDUser_to_ID(UserList);
                        l_type := 'SET_THE_ROLE';

         end if;

     if l_type = 'SET_THE_ROLE' then
          -- make the Ad Hoc role to hold both the dataowner and shadow
         if zpb_wf_ntf.has_Shadow(curUserID) = 'Y' then
            rolename := zpb_wf_ntf.MakeRoleName(InstanceID, TaskID);
            select distinct display_name
              into NewDispName
              from wf_users
              where name = curUser;

             -- add (And Shadows) display to role dispaly name
             FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
             l_label := FND_MESSAGE.GET;
             NewDispName := NewDispName || l_label;

             zpb_wf_ntf.SetRole(rolename, relative, NewDispName);
             ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, curUser);
             zpb_wf_ntf.add_Shadow(rolename, curUserID);
         else
           rolename := curUser;
         end if;
      end if;


  return rolename;

  exception

    when NO_DATA_FOUND then
         Null;

    when others then
            raise;

END;


procedure SENDMSG(p_userid in number,
                   p_subject in varchar2,
                   p_message in varchar2)
/*

This procedure assumes application context is set!

p_userID is any user ID which corresponds to a valid wf_roles.name
 which may be a vaild fnd_user.user_name.
p_subject - the notification subject up to 150 chars
p_message - the notification message up to 2000 chars

May be called from any procedure if context is set.

*/

IS

 l_nid number;
 l_username  varchar2(150);
 l_subject   varchar2(150);
 l_message   varchar2(2000);
 l_item_type   varchar2(8);
 l_msg_name    varchar2(16);
 l_send_comment varchar2(30); -- future use


begin

 l_item_type := 'EPBCYCLE';
 -- FYI - this is the same FYI message defined and used by the
 -- Notify Task.
 l_msg_name := 'FYIMSG';

 l_username := ID_to_FNDUser(p_userid);

 l_nid := wf_notification.send(ROLE => l_username,
                            MSG_TYPE => l_item_type,
                            MSG_NAME => l_msg_name,
                            DUE_DATE => NULL,
                            CALLBACK => NULL,
                            CONTEXT => NULL,
                            SEND_COMMENT => l_send_comment,
                            PRIORITY => NULL);


 --DBMS_OUTPUT.PUT_LINE(l_nid);
 wf_notification.SETATTRTEXT(l_nid, 'SUBJECT', p_subject);
 wf_notification.SETATTRTEXT(l_nid, 'ISSUEMSG', p_message);


return;

exception
    when others then
       raise;

end SENDMSG;

-- added for b 5251227
/*=========================================================================+
 |                       FUNCTION update_Role_with_Shadows
 |
 | DESCRIPTION
 |   To be used when the EPBPrerformer Attrubute is a single user and not
 |   a list of users or if BP owner ID is passed in. When called this will
 |   set any shadow users the EPBPerformer may have so notifications will be
 |   sent to shadows also.
 |
 | Parameters: itemtype  - usually EPBCYCLE will work for other ITEMTYPES that have
 |             WF attributes TASKID, INSTANCEID OWNERID and EPBPERFORMER.
 |             itemkey   - for the currently running WF EPB process
 |             actid     - 0 if not called directly by WF
 |             functmode - RUN when called directly by WF  or
 |             EPBPERFORMER or EPB_BPOWNERID if called from procedure
 |             and not from WF directly.
 +=========================================================================*/
procedure SHADOWS_FOR_EPBPERFORMER (itemtype in varchar2,
            		  itemkey  in varchar2,
	 	          actid    in number,
 		          funcmode in varchar2,
                          resultout   out nocopy varchar2)

IS

l_thisUserID      NUMBER;
l_RoleName        varchar2(320);
l_thisRecipient   varchar2(100);
l_label           varchar2(50);
l_NewDispName     varchar2(360);
l_TASKID          NUMBER;
l_INSTANCEID      NUMBER;
l_retbool         BOOLEAN;

BEGIN

 IF (funcmode = 'RUN') or (instr(funcmode, 'EPB') = 1)  THEN


    if (funcmode = 'EPB_BPOWNERID') then

          -- explicit request to use owner ID as recipient
          l_thisUserID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => ItemType,
                                itemkey         => ItemKey,
                                aname           => 'OWNERID');
          l_thisRecipient := ID_to_FNDuser(l_thisUserID);

          wf_engine.SetItemAttrText(Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'EPBPERFORMER',
         	  avalue => l_thisRecipient);

     else
           -- value is EPBPERFORMER or RUN
           -- in either case vlue set in WF attr EPBPERFORMER is basis for target recipient
           l_thisRecipient := wf_engine.GetItemAttrText(Itemtype => ItemType,
 	           	       Itemkey => ItemKey,
        	               aname => 'EPBPERFORMER');
           l_thisUserID := FNDUser_to_ID(l_thisRecipient);

     end if;

     -- just tells us this is a vaid single user not group role
     -- so look for and set shadows
     l_retbool := wf_directory.useractive(l_thisRecipient);

     if l_retbool = TRUE then



      --DBMS_OUTPUT.PUT_LINE('in true');

      -- make the Ad Hoc role to hold both the dataowner and shadow

      --DBMS_OUTPUT.PUT_LINE(l_thisRecipient);
      if zpb_wf_ntf.has_Shadow(l_thisUserID) = 'Y' then


         l_InstanceID := WF_ENGINE.GetItemAttrNumber(
                          itemtype        => ItemType,
                          itemkey         => ItemKey,
                          aname           => 'INSTANCEID');

         l_TaskID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => ItemType,
                                itemkey         => ItemKey,
                                aname           => 'TASKID');

         --DBMS_OUTPUT.PUT_LINE('has shadow');
         l_RoleName := zpb_wf_ntf.MakeRoleName(l_InstanceID, l_TaskID);
         select distinct display_name
             into l_NewDispName
             from wf_users
             where name = l_thisRecipient;
         -- add (And Shadows) display to role dispaly name
         FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
         l_label := FND_MESSAGE.GET;

         l_NewDispName := l_NewDispName || l_label;
         zpb_wf_ntf.SetRole(l_RoleName, 7, l_NewDispName);
         -- b4948928
         if zpb_wf_ntf.user_in_role(l_rolename, l_thisRecipient) = 'N'  then
            ZPB_UTIL_PVT.AddUsersToAdHocRole(l_RoleName, l_thisRecipient);
         end if;
         zpb_wf_ntf.add_Shadow(l_RoleName, l_thisUserID);

         wf_engine.SetItemAttrText(Itemtype => ItemType,
        	  Itemkey => ItemKey,
 	          aname => 'EPBPERFORMER',
         	  avalue => l_RoleName);

       --DBMS_OUTPUT.PUT_LINE('performer set');

       end if;

    end if;  -- TRUE

  END IF;

  resultout :='COMPLETE';
  return;


  exception
   when others then

    if (funcmode = 'EPBPERFORMER') or (funcmode = 'EPB_BPOWNERID')  then
       raise;
    else

       Wf_Core.Context('ZPB_WF_NTF', 'SHADOWS_FOR_EPBPERFORMER', itemtype,
                    itemkey, to_char(actid), funcmode);
       raise;
    end if;

END SHADOWS_FOR_EPBPERFORMER;

procedure SendExpiredUserMsg (p_BPOwnerID in number,
              p_taskID in number,
              p_itemtype in varchar2)

is


 l_nid number;
 l_BPownerOrProxy   varchar2(150);
 l_item_type   varchar2(8);
 l_msg_name    varchar2(16);
 l_BPOwnerID     number;
 l_BP_runID      number;
 l_BP_runName    varchar2(100);
 l_TaskID        number;
 l_taskName      varchar2(60);
 l_BAID          number;
 l_BA_Name       varchar2(100);
 l_count         number;


begin

  --DBMS_OUTPUT.PUT_LINE('begin sendmsgexpired');

 SELECT count(user_name) into l_count
  FROM ZPB_WF_INACTIVE_USERS_GT;

 --DBMS_OUTPUT.PUT_LINE('COUNT from GT: ' || l_count);

if (l_count > 0) then


     l_BPOwnerID := p_BPOwnerID;
     l_taskID := p_taskID;

     select t.task_name, ac.business_area_id, v.name, i.INSTANCE_DESCRIPTION, t.ANALYSIS_CYCLE_ID
      into l_taskName, l_BAID, l_BA_name, l_BP_runName, l_BP_runID
      from zpb_analysis_cycles ac, zpb_analysis_cycle_tasks t,
      ZPB_BUSINESS_AREAS_VL v, zpb_analysis_cycle_instances i
      where t.task_id = l_taskID
      and t.ANALYSIS_CYCLE_ID = ac.ANALYSIS_CYCLE_ID
      and ac.ANALYSIS_CYCLE_ID = i.INSTANCE_AC_ID
      and ac.business_area_id = v.business_area_id;

  l_BPownerOrProxy := zpb_wf_ntf.Get_Active_User(l_BPOwnerID, l_BAID);

  --DBMS_OUTPUT.PUT_LINE('after getactive owner proxy' || l_bpownerorproxy);
  --DBMS_OUTPUT.PUT_LINE('l_taskname ' || l_taskname);


  -- need fndmessage
  if p_ItemType is NULL then
     l_item_type := 'EPBCYCLE';
  else
     l_item_type := p_itemtype;
  end if;
  l_msg_name := 'INACTIVEMSG';


  l_nid := wf_notification.send(ROLE => l_BPownerOrProxy,
                            MSG_TYPE => l_item_type,
                            MSG_NAME => l_msg_name,
                            DUE_DATE => NULL,
                            CALLBACK => NULL,
                            CONTEXT => NULL,
                            SEND_COMMENT => NULL,
                            PRIORITY => NULL);

      -- DBMS_OUTPUT.PUT_LINE('nid ' || l_nid);


      wf_notification.SETATTRTEXT(l_nid, '#HDR_TASKNAME', l_taskName);
      wf_notification.SETATTRTEXT(l_nid, '#HDR_BUS_AREA_NAME', l_BA_name);
      wf_notification.SETATTRTEXT(l_nid, '#HDR_INSTANCEDESC', l_BP_runName);
      wf_notification.SETATTRTEXT(l_nid, '#HDR_BUS_AREA_ID', l_BAID);
      wf_notification.SETATTRTEXT(l_nid, '#HDR_TASKID', l_taskID);



      --DBMS_OUTPUT.PUT_LINE('before build expired');
      -- Build user list for message body
      zpb_wf_ntf.Build_ExpiredUser_list (l_nid);

end if;  -- if > 0


return;

exception
    when others then
       raise;

end SendExpiredUserMsg;

function Get_Active_User (p_BPOwnerID in number, p_BAID in number) return varchar2

as

l_RoleName        varchar2(320);
l_thisRecipient   varchar2(150);
l_label           varchar2(50);
l_NewDispName     varchar2(360);
l_TASKID          NUMBER;
l_INSTANCEID      NUMBER;
l_respID          number;
L_RESPDISPLAY     varchar2(100);

begin

  l_thisRecipient := zpb_wf_ntf.ID_to_FNDUser(p_BPOwnerID);

  -- Make a role name may not use it if just one user.
  if zpb_wf_ntf.has_Shadow(p_BPOwnerID) = 'Y' then

     l_RoleName := zpb_wf_ntf.MakeRoleName(l_InstanceID, l_TaskID);

     select distinct display_name
        into l_NewDispName
        from wf_users
        where name = l_thisRecipient;
     -- add (And Shadows) display to role dispaly name
     FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
     l_label := FND_MESSAGE.GET;
     l_NewDispName := l_NewDispName || l_label;


     zpb_wf_ntf.SetRole(l_RoleName, 7, l_NewDispName);

     if wf_directory.useractive(l_thisRecipient) = TRUE then
        if zpb_wf_ntf.user_in_role(l_rolename, l_thisRecipient) = 'N'  then
           ZPB_UTIL_PVT.AddUsersToAdHocRole(l_RoleName, l_thisRecipient);
        end if;
     end if;

     zpb_wf_ntf.add_Shadow(l_RoleName, p_BPOwnerID);

  else

     if wf_directory.useractive(l_thisRecipient) = TRUE then
        l_RoleName := l_thisRecipient;
     else

        -- there are no shadows and the owner is expired so
        -- try to find secrity admins and send the notes to them
        l_RoleName := zpb_wf_ntf.MakeRoleName(l_InstanceID, l_TaskID);
        -- add Responibility name as role dispaly name
        -- first get RESPONSIBILITY_ID
        select RESPONSIBILITY_ID, RESPONSIBILITY_NAME
          into l_respID, l_respDisplay
          from fnd_responsibility_vl
          where application_id = 210 and
          RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP';

        zpb_wf_ntf.SetRole(l_RoleName, 7, l_respDisplay);

        l_RoleName := zpb_wf_ntf.FindSecurityAdmin (p_BAID, l_RoleName, l_respID);
        -- final check if no zpb users yet then go to sysadmin
        if l_RoleName = 'NO_ZPB_USERS' then
            l_RoleName := 'SYSADMIN';
        end if;

     end if;

  end if; -- shadow check

  return l_RoleName;

exception
    when others then
       raise;

end Get_Active_User;

function FindSecurityAdmin (p_BAID in number,
                  p_roleName in varchar2,
                  p_respID in number) return varchar2

as

  l_status varchar2(12);
  l_thisUserID number;
  l_thisRecipient varchar2(320);


  CURSOR c_SecAdmins is
  select USER_ID from zpb_account_states
   where RESP_ID = p_respID AND ACCOUNT_STATUS = 0 AND BUSINESS_AREA_ID = p_BAID;

   v_SecAdmin c_SecAdmins%ROWTYPE;

begin

     l_status := 'N0_ZPB_USERS';

     for  v_SecAdmin in c_SecAdmins loop
         l_thisUserID := v_SecAdmin.user_id;
         l_thisRecipient := ID_to_FNDuser(l_thisUserID);

         if wf_directory.useractive(l_thisRecipient) = TRUE then
             if zpb_wf_ntf.user_in_role(p_RoleName, l_thisRecipient) = 'N'  then
                ZPB_UTIL_PVT.AddUsersToAdHocRole(p_RoleName, l_thisRecipient);
                l_status := 'Y';
             end if;
         end if;

      end loop;

     return l_status;

end FindSecurityAdmin;



Procedure Build_ExpiredUser_list (p_nid in number)
is

 l_length  number;
 l_register number;
 l_userlist varchar2(4000);
 l_fullLength number;
 l_bypass varchar2(1);
 l_session_id  number;

 CURSOR c_inactive_users is
  select distinct(user_name) from ZPB_WF_INACTIVE_USERS_GT;

  v_inactive_user c_inactive_users%ROWTYPE;

begin

 SELECT SUM(LENGTH(user_name)) into l_fulllength
  FROM ZPB_WF_INACTIVE_USERS_GT;

if l_fulllength > 0 then -- do nothing if length is 0 or negative

  if l_fulllength < 3990 then
     -- just one register to needed
     for v_inactive_user in c_inactive_users loop

        if c_inactive_users%ROWCOUNT = 1 then
           l_userlist  :=  v_inactive_user.user_name;
        else
           l_userlist  :=  l_userlist || ', ' || v_inactive_user.user_name;
        end if;

     end loop;

      wf_notification.SETATTRTEXT(p_nid, 'REGISTER1', l_userlist);


  -- loop over cursor

  else
       l_register := 0;

       open c_inactive_users;
       loop
       fetch c_inactive_users into v_inactive_user;

       if  c_inactive_users%ROWCOUNT = 1 then
             l_userlist  :=  v_inactive_user.user_name;
             l_bypass := 'Y';
       else -- manyrows

         l_userlist  :=  l_userlist || ', ' || v_inactive_user.user_name;
         l_length := length(l_userlist);

         if l_length > 3660 then
            l_register := l_register+1;
            l_bypass := 'N';
            l_length := 0;
          else
            l_bypass := 'Y';
          end if;

          if c_inactive_users%NOTFOUND then
             l_bypass := 'LAST';
          end if;



        if l_bypass = 'N' or l_bypass = 'LAST' then  --BYPASS

         case l_register

           when 1  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER1', l_userlist);
              l_userlist := NULL;
           when 2  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER2', l_userlist);
              l_userlist := NULL;

           when 3  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER3', l_userlist);
              l_userlist := NULL;

           when 4  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER4', l_userlist);
              l_userlist := NULL;

           when 5  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER5', l_userlist);
              l_userlist := NULL;

           when 6  then
              wf_notification.SETATTRTEXT(p_nid, 'REGISTER6', l_userlist);
              l_userlist := NULL;

          end case;

        end if; -- manyrows

       end if; --BYPASS


       if c_inactive_users%NOTFOUND and l_bypass =  'LAST' then
           EXIT;
       end if;


      end loop;
      close c_inactive_users;


  end if;  -- fullLength test

end if; -- less than 0

return;

exception
    when others then
       raise;

end Build_ExpiredUser_list;




end ZPB_WF_NTF;

/
