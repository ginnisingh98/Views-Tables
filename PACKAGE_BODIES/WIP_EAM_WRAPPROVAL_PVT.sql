--------------------------------------------------------
--  DDL for Package Body WIP_EAM_WRAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_WRAPPROVAL_PVT" AS
/*$Header: WIPVWRAB.pls 120.8.12010000.2 2008/10/30 07:19:58 srkotika ship $ */

PROCEDURE StartWRAProcess ( p_work_request_id		in number,
                           p_asset_number       	in varchar2,
                           p_asset_group        	in number,
                           p_asset_location     	in number,
                           p_organization_id    	in number,
                           p_work_request_status_id     in number,
                           p_work_request_priority_id   in number,
                           p_work_request_owning_dept_id in number,
                           p_expected_resolution_date   in date,
                           p_work_request_type_id     	in number,
                           p_maintenance_object_type	in number default 3,
                           p_maintenance_object_id	in number default null,
                           p_notes              	in varchar2,
                           p_notify_originator		in number,
                           p_resultout    		OUT NOCOPY varchar2,
                           p_error_message              OUT NOCOPY varchar2
                           ) IS

 itemtype            	        varchar2(8) := 'EAMWRAP';
 itemkey             	        varchar2(240)
 --:=  p_work_request_id
 ;
 l_instance_number              varchar2(30);
 l_asset_group_segments		varchar2(240);
 l_asset_group_description     	varchar2(240);
 l_asset_description   		varchar2(240);
 l_priority_description 	varchar2(240);
 l_workflow_process     	varchar2(30) := 'EAMWRAP_PROCESS';
 l_role_name            	varchar2(80);
 l_department_code              varchar2(240);
 l_location_codes               varchar2(240);
 l_work_request_type            varchar2(240);
 l_notes                        varchar2(2000);
-- l_eam_location_id             number;
-- l_from_role            	varchar2(240);
 l_stmt_number                  number;
 l_NO_DEPT_RESP                 EXCEPTION;
 l_resp_id                varchar2(80);
 l_resp_appl_id             varchar2(20);
 l_resp_string              varchar2(20);
 l_display_name             varchar2(80);
 l_asset_location 	number;
 l_primary_approver_name	fnd_user.user_name%type;
 l_maintenance_object_id	number;
 l_asset_group_id		number;
/* If multiple responsibility to dept , would pick up the first , but
  this scenario should not exist  as per design */

/* Bug 2112323 - For performance reasons, we shall use work flow API to get responsibility name
-- changing the select statement below as it selects only those
-- responsibilities that are tied to asset owning department.
-- now the user is able to select other depts in beda
cursor c_role_name is
   select wfr.NAME
   from  wf_roles wfr ,
         bom_eam_dept_approvers beda
   where
     beda.dept_id = p_work_request_owning_dept_id
     and beda.organization_id = p_organization_id
     and beda.responsibility_id = wfr.orig_system_id ;
*/

cursor c_resp_name is
   select beda.responsibility_id,beda.responsibility_application_id,fu.user_name
   from   bom_eam_dept_approvers beda, fnd_user fu
   where
     beda.dept_id = p_work_request_owning_dept_id
     and beda.organization_id = p_organization_id
     and fu.user_id(+) = beda.primary_approver_id;

BEGIN
  p_resultout :=  FND_API.G_RET_STS_SUCCESS;
  l_resp_string := 'FND_RESP';

  if p_maintenance_object_id is not null then
  	l_maintenance_object_id := p_maintenance_object_id;

  	select instance_number, inventory_item_id into l_instance_number, l_asset_group_id
  	from csi_item_instances where instance_id = l_maintenance_object_id;
  else
   if (p_asset_number is not null and p_asset_group is not null) then
  	select instance_number, instance_id into l_instance_number, l_maintenance_object_id
  	from csi_item_instances where serial_number = p_asset_number
  	and inventory_item_id = p_asset_group;
  	l_asset_group_id := p_asset_group;
   else
  	 l_instance_number:=null;
   	 l_maintenance_object_id:=null;
   end if;
  end if;

  l_stmt_number := 10 ;
  /* Bug 2112323 -For performance reasons, we shall use work flow API to get responsibility name
    Open    c_role_name;
    fetch c_role_name  into l_role_name ;
    if    c_role_name%NOTFOUND then
       close c_role_name ;
       raise l_NO_DEPT_RESP ;
    end if;
  close c_role_name;
  */

  Open    c_resp_name;
      fetch c_resp_name  into l_resp_id,l_resp_appl_id,l_primary_approver_name;
      if    c_resp_name%NOTFOUND then
         close c_resp_name ;
         raise l_NO_DEPT_RESP ;
      end if;
  close c_resp_name;

  -- Added due to Bug 2112323
  l_resp_appl_id := l_resp_string || l_resp_appl_id;

  -- bug 3841128: Changing parameter of GetRoleName as orig_system seems to be changed to 'FND_RESP'
  -- prior to 11.5.10, orig_system was FND_RESP concatenated with application id
  --wf_directory.GetRoleName(l_resp_appl_id ,l_resp_id,l_role_name,l_display_name);
  wf_directory.GetRoleName(l_resp_string ,l_resp_id,l_role_name,l_display_name);
  -- end bug 3841128

  -- End added due to Bug 2112323

  if (l_primary_approver_name is not null) then
  	l_role_name := l_primary_approver_name;

  end if;

-- create a new workflow process
  l_stmt_number := 20 ;

  -- select sequence value as itemkey
  select wip_Eam_wrapproval_s.nextval
  into itemkey
  from dual;

  wf_engine.CreateProcess( itemtype => itemtype,
			   itemkey  => itemkey,
   			   process  => l_workflow_process,
			   owner_role=> FND_GLOBAL.USER_NAME);

 /* Get Asset description */
  l_stmt_number := 30 ;
  begin
  select  cii.instance_description
    into  l_asset_description
    from  csi_item_instances cii
    where cii.instance_id = l_maintenance_object_id;

  exception
	when No_Data_Found then
	     l_asset_description   := null;
	when others then
	     null;
  end;

  /* Get Asset Group description */
  l_stmt_number := 40 ;
  begin
  select  MSI.concatenated_segments, MSI.description
    into  l_asset_group_segments, l_asset_group_description
    from  mtl_system_items_kfv msi, mtl_parameters mp
    where msi.organization_id = mp.organization_id
      and mp.maint_organization_id = p_organization_id
      and msi.inventory_item_id = l_asset_group_id
      and rownum = 1;

  exception
	when No_Data_Found then
	     l_asset_group_segments := null;
	     l_asset_group_description   := null;
	when others then
	     null;
  end;


  /* Get Work Request Priority description */
  l_stmt_number := 50 ;
  begin
  select ML.meaning
    into l_priority_description
    from mfg_lookups ML
    where ml.lookup_code = p_work_request_priority_id
    and   ml.lookup_type = 'WIP_EAM_ACTIVITY_PRIORITY' ;

  exception
	when No_Data_Found then
	     l_priority_description   := null;
	when others then
	     null;
  end;

  /* Get Department Code */
  l_stmt_number := 60 ;
  begin
  select bd.department_code
    into l_department_code
    from bom_departments bd
  where  bd.organization_id = p_organization_id
    and  bd.department_id   = p_work_request_owning_dept_id ;

  exception
	when No_Data_Found then
	     l_department_code  := null;
	when others then
	     null;
  end;

 /* sraval: if p_asset_location is null, check if asset has a location */
 /* csprague: added check for p_asset_location = 0 fp: 4320910 */
 if (p_asset_location is null or p_asset_location = 0) then
 	begin
 		select area_id
 		into l_asset_location
 		from eam_org_maint_defaults
 		where organization_id = p_organization_id
 		and object_type = 50
 		and object_id = l_maintenance_object_id;
 	exception
 		when no_data_found then
 			l_asset_location := null;
 		when others then
 			raise;
 	end;
 else
 	l_asset_location := p_asset_location;

 end if;



 /* Get Location Code */
   l_stmt_number := 70 ;
  begin
  select location_codes
    into l_location_codes
    from MTL_EAM_LOCATIONS
  where  organization_id = p_organization_id
    and  location_id   =   l_asset_location ;

  exception
	when No_Data_Found then
	     l_location_codes  := null;
	when others then
	     null;
  end;

 /* Get Work Request Type  */
  l_stmt_number := 75 ;
  begin
  select  ml.meaning
    into  l_work_request_type
    from  MFG_LOOKUPS ml
    where ml.lookup_code = p_work_request_type_id
    and   ml.lookup_type = 'WIP_EAM_WORK_REQ_TYPE' ;

  exception
	when No_Data_Found then
	     l_work_request_type   := null;
	when others then
	     null;
  end;


 /* Get header info. for notes
    The below record should always exist, as even for empty comments
    we insert the header info  */
  l_stmt_number := 76 ;
  begin
  select   notes into l_notes
    from   WIP_EAM_WORK_REQ_NOTES wrn1
    where  work_request_id  = p_work_request_id
      and  work_request_note_id in
          (select min(work_request_note_id)
             from WIP_EAM_WORK_REQ_NOTES wrn2
            where wrn1.work_request_id = wrn2.work_request_id);

  If l_notes is not null then
     l_notes := l_notes || wf_core.newline || p_notes ;
  Else
     l_notes := p_notes ;
  End if ;

  exception
	when others then
             l_notes := p_notes ;
	     null;
  end ;


  /* Set Attributes */
  l_stmt_number := 80 ;
  wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'WORK_REQUEST_ID',
			       avalue   =>  p_work_request_id );

  wf_engine.SetItemAttrText( itemtype => itemtype,
			     itemkey  => itemkey,
			     aname    => 'ASSET_NUMBER',
			     avalue   => l_instance_number);

  wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey => itemkey,
                             aname   => 'ASSET_DESCRIPTION',
                             avalue  => l_asset_description);

  wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'ASSET_GROUP',
                              avalue   => p_asset_group);

   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ASSET_GROUP_SEGMENTS',
                             avalue   => l_asset_group_segments);

   wf_engine.SetItemAttrText(itemtype =>itemtype,
                             itemkey  =>itemkey,
                             aname    => 'ASSET_GROUP_DESCRIPTION',
                             avalue   => l_asset_group_description);

  wf_engine.SetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'WORK_REQUEST_STATUS_ID',
                               avalue   => p_work_request_status_id);

  wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'WORK_REQUEST_PRIORITY_ID',
			       avalue   => p_work_request_priority_id);

  wf_engine.SetItemAttrText(itemtype =>itemtype,
                             itemkey =>itemkey,
                             aname   => 'PRIORITY_DESCRIPTION',
                             avalue  => l_priority_description);

  wf_engine.SetItemAttrNumber( itemtype =>  itemtype,
                               itemkey  => itemkey,
                               aname    => 'WORK_REQUEST_OWNING_DEPT_ID',
                               avalue   => p_work_request_owning_dept_id);

  wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPARTMENT_CODE',
                             avalue=> l_department_code);

  wf_engine.SetItemAttrDate( itemtype => itemtype,
			     itemkey  => itemkey,
			     aname    => 'EXPECTED_RESOLUTION_DATE',
			     avalue   => p_expected_resolution_date);

  wf_engine.SetItemAttrText( itemtype => itemtype,
			     itemkey  => itemkey,
			     aname    => 'NOTES',
			     avalue   => l_notes);

  /*  Responsibility associated to the Owning Dept in MSN */
   wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPT_RESPONSIBILTY',
                             avalue=> l_role_name);


  wf_engine.SetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'ASSET_LOCATION',
                               avalue   => l_asset_location);

   wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'LOCATION_CODES',
                             avalue=> l_location_codes);

   wf_engine.SetItemAttrNumber(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'WORK_REQUEST_TYPE_ID',
                             avalue=> p_work_request_type_id);

   wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'WORK_REQUEST_TYPE',
                             avalue=> l_work_request_type);

-- From_Role is displayed on Notifn Summary screen
-- l_from_role  :=  FND_GLOBAL.USER_NAME ;
  wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> '#FROM_ROLE',
                             avalue=> FND_GLOBAL.USER_NAME );

  -- sraval: set originator attribute if notify_originator is 'Yes'
  if ((p_notify_originator is not null) and (p_notify_originator = 1)) then
  	wf_engine.SetItemAttrText(itemtype=>itemtype,
	                     itemkey =>itemkey,
	                     aname=> 'WORK_REQUEST_ORIGINATOR',
                             avalue=> FND_GLOBAL.USER_NAME );
  else
 	wf_engine.SetItemAttrText(itemtype=>itemtype,
		             itemkey =>itemkey,
		             aname=> 'WORK_REQUEST_ORIGINATOR',
                             avalue=> null);

  end if;
  /* Start Process */
  l_stmt_number := 100 ;
  wf_engine.StartProcess( itemtype => itemtype,
			  itemkey  => itemkey);

  /* Set workflow process to background for better performance */

  update wip_eam_work_requests
  set wf_item_type = itemtype,
  wf_item_key = itemkey
  where work_request_id = p_work_request_id;
  l_stmt_number := 120 ;
--wf_engine.threshold := -1;

-- commit ;

EXCEPTION
 When l_NO_DEPT_RESP then
    p_resultout  := FND_API.G_RET_STS_ERROR;
    p_error_message  :=  ' Work Request cannot be created as there are no ' ||
                            ' department approvers for the selected ' ||
                          ' [Asset : '  || p_asset_number || '] Assigned Department';
 When others then
    wf_core.context('EAMWRAP','StartWRAProcess', itemtype, itemkey);
    p_resultout  := FND_API.G_RET_STS_ERROR;
    p_error_message  :=  to_char(l_stmt_number) || ' EAMWRAP'
                          || ' StartWRAProcess'|| itemtype || itemkey;
    raise;

END StartWRAProcess;

/* Update status to 'Awaiting Work Order' in wip_eam_work_requests */
PROCEDURE Update_Status_Await_Wo( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is

  l_work_request_id 	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'WORK_REQUEST_ID');

  l_comment             varchar2(2000) :=
   wf_engine.GetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'COMMENT');

  l_role_name            varchar2(80) :=
  wf_engine.GetItemAttrText( itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPT_RESPONSIBILTY');

  l_work_request_note_id  number;
  l_last_updated_by       number;
  l_stmt_number           number;
  l_user_name varchar2(100);
BEGIN

  l_stmt_number        := 10;

  If (funcmode = 'RUN') then

     Update WIP_EAM_WORK_REQUESTS
       set  work_request_status_id = 3 ,
            last_updated_by        = FND_GLOBAL.USER_ID,
            last_update_date       = SYSDATE
     Where  work_request_id 	   = l_work_request_id ;

--  Set the from role to be displayed on notifn summary

     l_user_name := fnd_global.user_name;

     wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> '#FROM_ROLE',
                             avalue=> l_user_name);

     set_employee_name(
     		itemtype=>itemtype,
                itemkey =>itemkey,
                actid   => actid,
		funcmode  =>funcmode,
     		p_user_name => l_user_name);


--   If l_comment is not null Then
        l_stmt_number        := 20;
        select wip_eam_work_req_notes_s.nextval
          into l_work_request_note_id
        from dual ;

        l_comment := ' *** '||
                    l_user_name||
                    ' (' ||
                    to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
                    ||') *** ' || wf_core.newline ||
                     l_comment ;
/*
        l_stmt_number        := 30;
        select orig_system_id
           into l_last_updated_by
        from wf_roles
        where name = l_role_name ;
*/
--  Assumption For SYSDATE , there is not much time lag betwn
--  comments entered on WF and time it reaches the below insert

        l_stmt_number        := 40;
        Insert into WIP_EAM_WORK_REQ_NOTES
        (WORK_REQUEST_NOTE_ID ,
         LAST_UPDATE_DATE ,
         LAST_UPDATED_BY ,
         CREATION_DATE,
         CREATED_BY ,
         LAST_UPDATE_LOGIN,
         WORK_REQUEST_ID ,
         NOTES,
         WORK_REQUEST_NOTE_TYPE,
         NOTIFICATION_ID )
        Values
        ( l_work_request_note_id,
          SYSDATE ,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          null,
          l_work_request_id,
          l_comment ,
          2,
          null);
--   End If ;  --- comment not null

    resultout := 'COMPLETE:';
    return;

  End if;


  if (funcmode = 'CANCEL') then

    l_stmt_number        := 50;
    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    l_stmt_number        := 60;
    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('EAMWRAP','UPDATE_STATUS_AWAIT_WO '||to_char(l_stmt_number),
                     itemtype, itemkey, actid, funcmode);
    raise;

END Update_Status_Await_Wo;


/* update status to Rejected in wip_eam_work_requests  */
PROCEDURE Update_Status_Rejected( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is

  l_work_request_id 	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'WORK_REQUEST_ID');

  l_comment             varchar2(2000) :=
   wf_engine.GetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'COMMENT');

  l_role_name           varchar2(80) :=
  wf_engine.GetItemAttrText( itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPT_RESPONSIBILTY');

  l_work_request_note_id number;
  l_last_updated_by      number;
  l_stmt_number          number;
  l_user_name varchar2(100);

BEGIN
  l_stmt_number        := 10;

  If (funcmode = 'RUN') then

     Update WIP_EAM_WORK_REQUESTS
       set  work_request_status_id = 5,
            last_updated_by        = FND_GLOBAL.USER_ID,
            last_update_date       = SYSDATE
     Where  work_request_id = l_work_request_id ;

--  Set the from role to be displayed on notifn summary

     l_user_name := fnd_global.user_name;
     wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> '#FROM_ROLE',
                             avalue=> l_user_name ) ;
    set_employee_name(
     		itemtype=>itemtype,
                itemkey =>itemkey,
                actid   => actid,
		funcmode  =>funcmode,
     		p_user_name => l_user_name);

--   If l_comment is not null Then
        l_stmt_number        := 20;
        select wip_eam_work_req_notes_s.nextval
          into l_work_request_note_id
        from dual ;

        l_comment := ' *** '||
                    l_user_name||
                    ' (' ||
                    to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
                    ||') *** ' || wf_core.newline ||
                    l_comment;
/*
        l_stmt_number        := 30;
        select orig_system_id
           into l_last_updated_by
        from wf_roles
        where name = l_role_name ;
*/

--  Assumption For SYSDATE , there is not much time lag betwn
--  comments entered on WF and time it reaches the below insert

        l_stmt_number        := 40;
        Insert into WIP_EAM_WORK_REQ_NOTES
        (WORK_REQUEST_NOTE_ID ,
         LAST_UPDATE_DATE ,
         LAST_UPDATED_BY ,
         CREATION_DATE,
         CREATED_BY ,
         LAST_UPDATE_LOGIN,
         WORK_REQUEST_ID ,
         NOTES,
         WORK_REQUEST_NOTE_TYPE,
         NOTIFICATION_ID )
        Values
        ( l_work_request_note_id,
          SYSDATE ,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          null,
          l_work_request_id,
          l_comment ,
          2,
          null);
--   End If ;  --- comment not null

    resultout := 'COMPLETE:';
    return;

  End if;

  if (funcmode = 'CANCEL') then

    l_stmt_number        := 50;
    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    l_stmt_number        := 60;
    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('EAMWRAP','UPDATE_STATUS_REJECTED '|| to_char(l_stmt_number)                    ,itemtype, itemkey, actid, funcmode);
    raise;
END Update_status_rejected;

/*Update status to 'Additional Information' in wip_eam_work_requests  */

PROCEDURE Update_Status_Add( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is

  l_work_request_id   number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'WORK_REQUEST_ID');

  l_comment            varchar2(2000) :=
   wf_engine.GetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'COMMENT');

  l_previous_reassign_comment    varchar2(2000) :=
   wf_engine.GetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'PREVIOUS_REASSIGN_COMMENT');
-- From role
  l_role_name  	       varchar2(80) :=
  wf_engine.GetItemAttrText( itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPT_RESPONSIBILTY');
-- To role
  l_reassign_role_name  varchar2(80) :=
  wf_engine.GetItemAttrText( itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'REASSIGN_ROLE');


  l_work_request_note_id  number ;
  l_last_updated_by       number ;
  l_stmt_number           number ;
  l_user_name varchar2(100);
BEGIN

IF funcmode =  'RUN' then

    l_stmt_number        := 10;
    /* Bug:  3418639 - Commenting line below so that the From field in notification
    			is the same as the from field during creation of notification and
    			not the from field of the person who has changed status to Add. Info
    wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> '#FROM_ROLE',
                             avalue=> FND_GLOBAL.USER_NAME);
    */

-- 7 Aug '01 , as per discussion with Adey

    If l_reassign_role_name is null then
       l_reassign_role_name := l_role_name ;
    End if ;

    l_user_name := FND_GLOBAL.USER_NAME;
    set_employee_name(
     		itemtype=>itemtype,
                itemkey =>itemkey,
                actid   => actid,
		funcmode  =>funcmode,
     		p_user_name => l_user_name);

    BEGIN
    	--Bug 3494922: Set From Role 2 to the approver's user name
    	wf_engine.SetItemAttrText(itemtype=>itemtype,
                                 itemkey =>itemkey,
                                 aname=> 'FROM_ROLE2',
                             avalue=> l_user_name);
	EXCEPTION/*bug#4425039 - added for WF upgraded from pre11i10*/
	        WHEN OTHERS THEN
	                IF (wf_core.error_name = 'WFENG_ITEM_ATTR') THEN
	                        wf_engine.AddItemAttr(itemtype=>itemtype,
	                                           itemkey =>itemkey,
	                                           aname=>'FROM_ROLE2');
	                        wf_engine.SetItemAttrText( itemtype => itemtype,
	     			        itemkey  => itemkey,
	                                aname    => 'FROM_ROLE2',
	                                avalue   =>  l_user_name );
	                ELSE
	                        raise;
	                END IF;
    END;
    l_stmt_number        := 15;
    wf_engine.SetItemAttrText(itemtype=>itemtype,
                             itemkey =>itemkey,
                             aname=> 'DEPT_RESPONSIBILTY',
                             avalue=> l_reassign_role_name);

    l_stmt_number        := 20;
    Update  WIP_EAM_WORK_REQUESTS
       set  work_request_status_id = 2,
            last_updated_by        = FND_GLOBAL.USER_ID,
            last_update_date       = SYSDATE
     Where  work_request_id = l_work_request_id ;

--  If l_comment is not null Then
        l_stmt_number        := 30;
        select wip_eam_work_req_notes_s.nextval
          into l_work_request_note_id
        from dual ;

/*      l_stmt_number        := 40;
        select orig_system_id , display_name
           into l_last_updated_by , l_display_name
        from wf_roles
        where name = l_role_name ;
*/

       l_stmt_number        := 50;

       -- set additional info comment before changing and nullifying comment, bug7480408
        wf_engine.SetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'ADD_COMMENT',
                              avalue   => l_comment);

       l_comment := ' *** '||
                    l_user_name||
                    ' (' ||
                    to_char(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
                    ||') *** ' || wf_core.newline ||
                    l_comment;


       If l_previous_reassign_comment is null
       Then
          l_previous_reassign_comment := l_comment ;
       Else
          l_previous_reassign_comment := l_previous_reassign_comment ||
                                         wf_core.newline || l_comment ;
       End if ;

--  Assumption For SYSDATE , there is not much time lag betwn
--  comments entered on WF and time it reaches the below insert

        l_stmt_number        := 60;
        Insert into WIP_EAM_WORK_REQ_NOTES
        (WORK_REQUEST_NOTE_ID ,
         LAST_UPDATE_DATE ,
         LAST_UPDATED_BY ,
         CREATION_DATE,
         CREATED_BY ,
         LAST_UPDATE_LOGIN,
         WORK_REQUEST_ID ,
         NOTES,
         WORK_REQUEST_NOTE_TYPE,
         NOTIFICATION_ID )
        Values
        ( l_work_request_note_id,
          SYSDATE ,
          FND_GLOBAL.USER_ID ,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          null,
          l_work_request_id,
          l_comment ,
          2,
          null);

/*     begin
      select TEXT_VALUE into l_previous_reassign_comment
      from   wf_item_attribute_values
       where ITEM_TYPE = itemtype
       and   ITEM_KEY =  itemkey
       and   NAME     =  'PREVIOUS_REASSIGN_COMMENT' ;

     Exception
         When others then
              null;
     End ;
 */

      l_stmt_number        := 70;
      wf_engine.SetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'PREVIOUS_REASSIGN_COMMENT',
                              avalue   => l_previous_reassign_comment);

--   Comment box is cleared so new comments can be entered
      l_comment  := null ;
      l_stmt_number        := 80;
      wf_engine.SetItemAttrText( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'COMMENT',
                              avalue   => l_comment);
--  End if ;  --- comment not null

      resultout := 'COMPLETE:';
      return;

 End if; -- function mode

 if (funcmode = 'CANCEL') then

    l_stmt_number        := 90;
    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    l_stmt_number        := 100;
    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('EAMWRAP', 'UPDATE_STATUS_ADD '|| to_char(l_stmt_number),
                    itemtype, itemkey, actid, funcmode);
    raise;

END Update_status_add;

procedure CHECK_NOTIFY_ORIGINATOR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout    in out NOCOPY varchar2)
is
  l_work_request_originator	varchar2(100);
  wf_yes 		varchar2(1) := 'Y';
  wf_no   		varchar2(1) := 'N';
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- retrieve requestor, approver
    l_work_request_originator := wf_engine.GetItemAttrText(itemtype => itemtype
						,itemkey => itemkey
						,aname => 'WORK_REQUEST_ORIGINATOR'
						,ignore_notfound=>true);/*Added for bug#4425039*/

    if l_work_request_originator is null then
	resultout  := wf_engine.eng_completed||':'||wf_no;
    else
	resultout  := wf_engine.eng_completed||':'||wf_yes;
    end if;
    return;
  end if;


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- no result needed
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := wf_engine.eng_null;
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WIPVWRAB', 'CHECK_NOTIFY_ORIGINATOR',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end CHECK_NOTIFY_ORIGINATOR;

procedure set_employee_name
			( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      p_user_name in varchar2)
is
	l_user_name varchar2(100);
	l_employee_name varchar2(300);
begin
	     -- select employee information
	     begin
	     	SELECT nvl(first_name ||' '||last_name,p_user_name)
	     	INTO l_employee_name
	     	FROM PER_PEOPLE_F
	     	WHERE PERSON_ID=
	     		(select employee_id from fnd_user where user_name=p_user_name);
	     exception
	     	when others then
	     		l_employee_name := p_user_name;
	     end;

	     wf_engine.SetItemAttrText( itemtype => itemtype,
	     			       itemkey  => itemkey,
	     			       aname    => 'FROM_ROLE_EMPLOYEE',
			       		avalue   =>  l_employee_name );
end set_employee_name;

END WIP_EAM_WRAPPROVAL_PVT;

/
