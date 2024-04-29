--------------------------------------------------------
--  DDL for Package Body AMW_ORG_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ORG_HIERARCHY_PKG" as
/*$Header: amwoghrb.pls 120.16.12000000.4 2007/04/19 10:34:39 shelango ship $*/


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_ORG_HIERARCHY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwoghrb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- ****************************************************************************
-- it's enough if we check just the latest hierarchy that the child being added
-- exists as a parent
function is_child_an_ancestor(p_org_id in number,
                              p_parent_process_id in number,
                              p_child_process_id in number) return boolean
is
l_dummy number;
begin
select parent_id
    into l_dummy
    from amw_latest_hierarchies
    where parent_id = p_child_process_id
    start with child_id = p_parent_process_id  and organization_id = p_org_id
    connect by prior parent_id = child_id
    and organization_id = p_org_id;
/*
     select 1
     into l_dummy
     from amw_org_hierarchy_denorm
     where process_id = p_parent_process_id
     and   parent_child_id = p_child_process_id
     and   up_down_ind = 'U'
     and   hierarchy_type = 'L'
     and  organization_id = p_org_id;
*/
     return true;
exception
    when no_data_found then
        return false;
    when too_many_rows then
        return true;
end is_child_an_ancestor;

-- ****************************************************************************

-- check if a process exists in an org.
-- If it does not exist, return NOEXIST
-- If it exists but is "deleted", return DEL
-- If it exists but in no hierarchy, but exists in the org, return NOHIER
-- If it exists in latest hierarchy only, return LATEST
-- If it exists in approved hierarchy only, return APPROV
-- If it exists in both approved 1 hierarchy only, return BOTH
function ex_proc_in_which_hier (
	p_org_id in number,
	p_process_id in number) return varchar2
is
l_dummy number;
l_score number := 0;
l_return varchar2(30) := '';

begin
-- check in latest hierarchy
    begin
    select 1
    into l_dummy
    from AMW_LATEST_HIERARCHY_ORG_V
    where child_process_id =  p_process_id
    and child_organization_id = p_org_id;

    l_score := 1;

    exception
    when too_many_rows then
         l_score := 1;
    when no_data_found then
         l_score := 0;
    end;

-- check in approved hierarchy
    begin
    select 1
    into l_dummy
    from AMW_CURR_APP_HIERARCHY_org_v
    where child_process_id =  p_process_id
    and child_organization_id = p_org_id;

    l_score := l_score + 2;

    exception
    when too_many_rows then
        l_score := l_score + 2;
    when no_data_found then
        l_score := l_score + 0;
    end;

    if l_score = 3 then
        return 'BOTH';
    elsif l_score = 1 then
        return 'LATEST';
    elsif l_score = 2 then
        return 'APPROV';
    else
        begin
        select 1
        into l_dummy
        from AMW_CURR_APPROVED_REV_ORG_v
        where process_id =  p_process_id
        and organization_id = p_org_id
        and deletion_date is not null;

        l_return := 'DEL';
        exception
            when too_many_rows then
                l_return := 'DEL';
            when no_data_found then
                l_return := '';
        end;
        if l_return is null then
                begin
                select 1
                into l_dummy
                from amw_process_organization
                where process_id =  p_process_id
                and organization_id = p_org_id;

                l_return := 'NOHIER';
                exception
                    when too_many_rows then
                        l_return := 'NOHIER';
                    when no_data_found then
                        l_return := 'NOEXIST';
                end;
        end if;
        return l_return;
    end if;

end ex_proc_in_which_hier;

-- ****************************************************************************
-- if process is approved, revise it and create a draft.
-- if process is draft, move on
procedure revise_process_if_necessary (
	p_org_id in number,
	p_process_id in number) is

l_rev_num  number;

begin

    if p_process_id <> -2 then -- do not revise the root

  -- check if the latest revision is approved.
    select REVISION_NUMBER
    into l_rev_num
    from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null
    and approval_status = 'A';


  -- if you've come here => the latest revision is approved. We need to revise.

        -- insert a new revision row in amw_process_organization
		insert into amw_process_organization
			(CONTROL_COUNT,
			 RISK_COUNT,
			 PROCESS_ORGANIZATION_ID,
			 PROCESS_ID,
			 STANDARD_PROCESS_FLAG,
			 RISK_CATEGORY,
			 CERTIFICATION_STATUS,
			 LAST_AUDIT_STATUS,
			 ORGANIZATION_ID,
			 LAST_CERTIFICATION_DATE,
			 LAST_AUDIT_DATE,
			 NEXT_AUDIT_DATE,
			 APPLICATION_OWNER_ID,
			 PROCESS_OWNER_ID,
			 PROCESS_CATEGORY_CODE,
			 SIGNIFICANT_PROCESS_FLAG,
			 CREATED_FROM,
			 REQUEST_ID,
			 PROGRAM_APPLICATION_ID,
			  PROGRAM_ID,
			  PROGRAM_UPDATE_DATE,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  FINANCE_OWNER_ID,
			  PROCESS_CODE,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  RL_PROCESS_REV_ID,
			  STANDARD_VARIATION,
			  PROCESS_CATEGORY,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY,
			  LAST_UPDATE_LOGIN,
			  REVISION_NUMBER,
			  OBJECT_VERSION_NUMBER,
			  APPROVAL_STATUS,
			  END_DATE,
			  PROCESS_ORG_REV_ID,
			  START_DATE,
			  APPROVAL_DATE,
			  APPROVAL_END_DATE,
			  DELETION_DATE )

			  (select
			  CONTROL_COUNT,
			  RISK_COUNT,
			  AMW_PROCESS_ORGANIZATION_S.nextval,  --kosriniv this is primary key till AMW.C PROCESS_ORGANIZATION_ID,
			  PROCESS_ID,
			  STANDARD_PROCESS_FLAG,
			  RISK_CATEGORY,
			  CERTIFICATION_STATUS,
			  LAST_AUDIT_STATUS,
			  ORGANIZATION_ID,
			  LAST_CERTIFICATION_DATE,
			  LAST_AUDIT_DATE,
			  NEXT_AUDIT_DATE,
			  APPLICATION_OWNER_ID,
			  PROCESS_OWNER_ID,
			  PROCESS_CATEGORY_CODE,
			  SIGNIFICANT_PROCESS_FLAG,
			  CREATED_FROM,
			  REQUEST_ID,
			  PROGRAM_APPLICATION_ID,
			  PROGRAM_ID,
			  PROGRAM_UPDATE_DATE,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  FINANCE_OWNER_ID,
			  PROCESS_CODE,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  RL_PROCESS_REV_ID,
			  STANDARD_VARIATION,
			  PROCESS_CATEGORY,
			  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID,
			  REVISION_NUMBER + 1,
			  1,
			  'D',
			  null,
			  AMW_PROCESS_ORG_REV_S.nextval,
			  sysdate,
			  null,
			  null,
			  DELETION_DATE
			  from amw_process_organization
			  where process_id = p_process_id
			  and organization_id = p_org_id
			  and end_date is null
			  and approval_status = 'A');

        -- update the old row
         update amw_process_organization
         set    end_date = sysdate,
                object_version_number = object_version_number + 1
         where  process_id = p_process_id
         and    revision_number = l_rev_num
         and    organization_id = p_org_id;

    end if;

    exception
        when no_data_found then
          -- if you've come here => the latest revision is draft. Just move on.
          -- assumption: it's not pending approval. that check has been made.
            null;
end revise_process_if_necessary;

--******************************************************************************
-- This revises the process in all the organizations in one go
--******************************************************************************
procedure revise_process_if_necessary (p_process_id in number) is
    l_rev_num  number;
    l_Org_Ids t_Org_Ids;
    l_count number := 1;
    l_rev_number t_number;
    l_msg_data              varchar2(4000);
    l_msg_count	            number;

begin
    if p_process_id = -2 then
        return;
    END IF ;

    l_Org_Ids :=t_Org_Ids();
    l_rev_number :=t_number();

    FOR indx IN Org_Ids.FIRST .. Org_Ids.LAST
    LOOP
        Begin
            -- check if the latest revision is approved.
            select REVISION_NUMBER
            into l_rev_num
            from amw_process_organization
            where process_id = p_process_id
            and organization_id = Org_Ids(indx)
            and end_date is null
            and approval_status = 'A';
            l_Org_Ids.EXTEND(1);
            l_rev_number.EXTEND(1);
            l_Org_Ids(l_count) := Org_Ids(indx);
            l_rev_number(l_count) := l_rev_num ;
            l_count := l_count + 1;
        exception
            when no_data_found then
                -- if you've come here => the latest revision is draft. Just move on.
                -- assumption: it's not pending approval. that check has been made.
            raise;
        end;
    END LOOP;

    -- if you've come here => the latest revision is approved. We need to revise.

    -- insert a new revision row in amw_process_organization
    FORALL indx IN l_Org_Ids.FIRST .. l_Org_Ids.LAST
        insert into amw_process_organization
			(CONTROL_COUNT,
			 RISK_COUNT,
			 PROCESS_ORGANIZATION_ID,
			 PROCESS_ID,
			 STANDARD_PROCESS_FLAG,
			 RISK_CATEGORY,
			 CERTIFICATION_STATUS,
			 LAST_AUDIT_STATUS,
			 ORGANIZATION_ID,
			 LAST_CERTIFICATION_DATE,
			 LAST_AUDIT_DATE,
			 NEXT_AUDIT_DATE,
			 APPLICATION_OWNER_ID,
			 PROCESS_OWNER_ID,
			 PROCESS_CATEGORY_CODE,
			 SIGNIFICANT_PROCESS_FLAG,
			 CREATED_FROM,
			 REQUEST_ID,
			 PROGRAM_APPLICATION_ID,
			  PROGRAM_ID,
			  PROGRAM_UPDATE_DATE,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  FINANCE_OWNER_ID,
			  PROCESS_CODE,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  RL_PROCESS_REV_ID,
			  STANDARD_VARIATION,
			  PROCESS_CATEGORY,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY,
			  LAST_UPDATE_LOGIN,
			  REVISION_NUMBER,
			  OBJECT_VERSION_NUMBER,
			  APPROVAL_STATUS,
			  END_DATE,
			  PROCESS_ORG_REV_ID,
			  START_DATE,
			  APPROVAL_DATE,
			  APPROVAL_END_DATE,
			  DELETION_DATE )

			  (select
			  CONTROL_COUNT,
			  RISK_COUNT,
			  AMW_PROCESS_ORGANIZATION_S.nextval,  --kosriniv this is primary key till AMW.C PROCESS_ORGANIZATION_ID,
			  PROCESS_ID,
			  STANDARD_PROCESS_FLAG,
			  RISK_CATEGORY,
			  CERTIFICATION_STATUS,
			  LAST_AUDIT_STATUS,
			  ORGANIZATION_ID,
			  LAST_CERTIFICATION_DATE,
			  LAST_AUDIT_DATE,
			  NEXT_AUDIT_DATE,
			  APPLICATION_OWNER_ID,
			  PROCESS_OWNER_ID,
			  PROCESS_CATEGORY_CODE,
			  SIGNIFICANT_PROCESS_FLAG,
			  CREATED_FROM,
			  REQUEST_ID,
			  PROGRAM_APPLICATION_ID,
			  PROGRAM_ID,
			  PROGRAM_UPDATE_DATE,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  FINANCE_OWNER_ID,
			  PROCESS_CODE,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  RL_PROCESS_REV_ID,
			  STANDARD_VARIATION,
			  PROCESS_CATEGORY,
			  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID,
			  REVISION_NUMBER + 1,
			  1,
			  'D',
			  null,
			  AMW_PROCESS_ORG_REV_S.nextval,
			  sysdate,
			  null,
			  null,
			  DELETION_DATE
			  from amw_process_organization
			  where process_id    = p_process_id
			  and organization_id = l_Org_Ids(indx)
			  and end_date is null
			  and approval_status = 'A');

        -- update the old row
    FORALL indx IN l_Org_Ids.FIRST .. l_Org_Ids.LAST
         update amw_process_organization
         set    end_date = sysdate,
                object_version_number = object_version_number + 1
         where  process_id = p_process_id
         and    revision_number = l_rev_number(indx)
         and    organization_id = l_Org_Ids(indx);
Exception
    WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in Revision '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);
        raise;

end revise_process_if_necessary;


-- ****************************************************************************

-- The parent process and the child process both exist as ICM processes
-- Make a new link or delete an exisitng link. Revise parent if necessary
procedure add_delete_ex_child (
	p_org_id in number,
	p_parent_process_id in number,
	p_child_process_id in number,
    p_action in varchar2)
is
  l_dummy number;
  l_child_order_num amw_latest_hierarchies.child_order_number%type;
l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin
	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.Begin',
        'p_org_id:'||p_org_id ||';p_parent_process_id:'||p_parent_process_id ||';p_child_process_id:'||p_child_process_id ||';p_action:'||'ADD');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.produce_err_if_circular',
        p_org_id ||';'||p_parent_process_id ||';'||p_child_process_id);
	end if;

-- check for potential circular hierarchy formation
  produce_err_if_circular(
	p_org_id => p_org_id,
	p_parent_process_id => p_parent_process_id,
    p_child_process_id => p_child_process_id);


  -- find out if the latest revision for parent_id is approved or not.
  -- if approved, revise it. if draft, don't do anything
	  if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.revise_process_if_necessary',
        p_org_id ||';'||p_parent_process_id );
	  end if;
      revise_process_if_necessary(p_org_id, p_parent_process_id);

        --insert the latest hierarchy table
        if p_action = 'ADD' then
               insert into amw_latest_hierarchies
                (ORGANIZATION_ID, PARENT_ID, CHILD_ID, CHILD_ORDER_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, object_version_number)
               VALUES
                (p_org_id,p_parent_process_id,p_child_process_id,AMW_ORG_CHILD_ORDER_S.nextval, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1)
                returning                CHILD_ORDER_NUMBER
                 into                     l_child_order_num;
                AMW_RL_HIERARCHY_PKG.update_appr_ch_ord_num_if_reqd
                (p_org_id      =>  p_org_id,
                 p_parent_id   =>  p_parent_process_id,
                 p_child_id    =>  p_child_process_id,
                 p_instance_id =>  l_child_order_num);
        elsif p_action = 'DEL' then
               delete from amw_latest_hierarchies
               where parent_id = p_parent_process_id
               and   child_id  = p_child_process_id
               and organization_id = p_org_id;
        end if;

        -- if the parent is the root, then it doesn't get revised. This means if you
        -- add to the root, or delete from the root, the information must be transferred
        -- to the amw_approved_hierarchies table.
        if p_parent_process_id = -2 then
            if p_action = 'ADD' then
            	if( l_log_stmt_level >= l_curr_log_level ) then
    				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.write_approved_hierarchy',
        			'-2;0;'||p_org_id ||':'||sysdate);
	  			end if;
                AMW_PROC_ORG_APPROVAL_PKG.write_approved_hierarchy(-2, 0, p_org_id,sysdate);
            elsif p_action = 'DEL' then
            	if( l_log_stmt_level >= l_curr_log_level ) then
    				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.write_approved_hierarchy',
        			'-2;2;'||p_org_id ||':'||sysdate);
	  			end if;
                AMW_PROC_ORG_APPROVAL_PKG.write_approved_hierarchy(-2, 2, p_org_id,sysdate);
            end if;
            if( l_log_stmt_level >= l_curr_log_level ) then
    				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.write_approved_hierarchy',
        			'-2;3;'||p_org_id ||':'||sysdate);
	  		end if;
            AMW_PROC_ORG_APPROVAL_PKG.write_approved_hierarchy(-2, 3, p_org_id,sysdate);

            if( l_log_stmt_level >= l_curr_log_level ) then
    				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.write_approved_hierarchy',
        			'WRITE_APPROVED_HIERARCHY_END');
	  		end if;
        end if;

	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ADD_DELETE_EX_CHILD.End',
        'End');
	end if;

end add_delete_ex_child;


-- ****************************************************************************
/*
-- The parent process and the child process both exist as ICM processes
-- Make a new link or delete an exisitng link. Revise parent if necessary
procedure add_delete_ex_child (
	p_org_id in number,
	p_parent_process_id in number,
	p_child_process_id in number,
    p_action in varchar2,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2)
is
  l_api_name CONSTANT varchar2(30) := 'add_delete_ex_child';
  p_init_msg_list varchar2(10) := FND_API.G_FALSE;
  l_dummy number;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  -- find out if the latest revision for parent_id is approved or not.
  -- if approved, revise it. if draft, don't do anything

      revise_process_if_necessary(p_org_id, p_parent_process_id);

        --insert the latest hierarchy table
        if p_action = 'ADD' then
               insert into amw_latest_hierarchies
                (ORGANIZATION_ID, PARENT_ID, CHILD_ID, CHILD_ORDER_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, object_version_number)
               VALUES
                (p_org_id,p_parent_process_id,p_child_process_id,AMW_ORG_CHILD_ORDER_S.nextval, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1);
        elsif p_action = 'DEL' then
               delete from amw_latest_hierarchies
               where parent_id = p_parent_process_id
               and   child_id  = p_child_process_id
               and organization_id = p_org_id;
        end if;


exception
  when FND_API.G_EXC_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);


  when FND_API.G_EXC_UNEXPECTED_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => G_PKG_NAME,
                              p_procedure_name => l_api_name,
                              p_error_text => SUBSTRB(SQLERRM,1,240));

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

end add_delete_ex_child;
*/
-- ****************************************************************************

-- you can delete a process, i.e. set the deletion_date only when all occurrances of the
-- process is removed from the latest hierarchy.
procedure delete_process (
	p_org_id in number,
	p_process_id in number)
is
appexst varchar2(1);
l_return_status varchar2(10);
l_msg_count number;
l_msg_data varchar2(4000);
begin

	  appexst := does_apprvd_ver_exst(p_org_id,p_process_id);
	  if appexst = 'Y' then

      	revise_process_if_necessary(p_org_id, p_process_id);

	      update amw_process_organization
    	  set deletion_date = sysdate
	      where process_id = p_process_id
    	  and organization_id = p_org_id
      	  and end_date is null;
      else

      	delete_draft(   p_organization_id  => p_org_id,
                        p_process_id       => p_process_id,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data);

      end if;

end delete_process;


-- ****************************************************************************

-- import a process from rl into an org as child of an existing org-process
-- if parent is draft, just add child,
-- else revise parent. This involves creation
-- of a new org-process
procedure import_rlproc_as_child_of_ex (
	p_org_id in number,
	p_parent_process_id in number, -- exisitng org process
	p_child_process_id in number,  -- amw_process id
    apply_rcm in varchar2) is

l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;
begin
	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.begin',
        	'OrgId:' ||p_org_id || ';ProcessId:'||p_child_process_id
        	||';ParentProcessId:'||p_parent_process_id||';ApplyRCM:'||apply_rcm);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.produce_err_if_circular','produce_err_if_circular');
	end if;
-- check for potential circular hierarchy formation
  produce_err_if_circular(
	p_org_id => p_org_id,
	p_parent_process_id => p_parent_process_id,
    p_child_process_id => p_child_process_id);

  -- find out if the latest revision for parent_id is approved or not.
  -- if approved, revise it. if draft, don't do anything

  	 if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.revise_process_if_necessary','Revise parent:'|| p_parent_process_id );
	 end if;
      revise_process_if_necessary(p_org_id, p_parent_process_id);

     if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.insert Row','Insert Row' );
	 end if;

  --insert into amw_process_organization table
		insert into amw_process_organization
			( PROCESS_ORG_REV_ID,
   			  PROCESS_ORGANIZATION_ID,
			  REVISION_NUMBER,
			  PROCESS_ID,
       		  ORGANIZATION_ID,
			  PROCESS_CODE,
			  RL_PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY_CODE,
			  STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY,
			  LAST_UPDATE_LOGIN,
			  OBJECT_VERSION_NUMBER,
			  APPROVAL_STATUS,
  			  START_DATE,
              risk_category)

			  (select
			  AMW_PROCESS_ORG_REV_S.nextval,
			  AMW_PROCESS_ORGANIZATION_S.nextval,
			  1,
			  PROCESS_ID,
			  p_org_id,
			  PROCESS_CODE,
			  PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY,
			  STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE,
			  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID,
			  1,
			  'D',
			  sysdate,
              'High'
			  from amw_process
			  where process_id = p_child_process_id
			  and approval_date is not null
			  and approval_end_date is null);

		if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.insert_latest_hierarchy','insert_latest_hierarchy' );
	 	end if;
  --insert into latest hierarchy table
      insert into amw_latest_hierarchies
        (ORGANIZATION_ID, PARENT_ID, CHILD_ID, CHILD_ORDER_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, object_version_number)
      VALUES
        (p_org_id,p_parent_process_id,p_child_process_id,AMW_ORG_CHILD_ORDER_S.nextval, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1);


  -- import process objectives, key accounts, significant elements
  		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.import_process_attributes',
    		'p_child_process_id:' || p_child_process_id || ';p_org_id:'||p_org_id );
	 	end if;
      import_process_attributes(p_child_process_id, p_org_id);

  -- import rcm
      if apply_rcm = 'Y' then
      	  if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.IMPORT_RLPROC_AS_CHILD_OF_EX.import_rcm_for_new_orgprocess',
    		'p_child_process_id:' || p_child_process_id || ';p_org_id:'||p_org_id );
	 	end if;
          import_rcm_for_new_orgprocess(p_child_process_id, p_org_id);
      end if;

end import_rlproc_as_child_of_ex;


-- ****************************************************************************
PROCEDURE sync_attachments
   ( p_process_id IN NUMBER
     ,p_org_id IN NUMBER
     ,p_add_upd_flag VARCHAR2)
   IS
-- Purpose: Briefly explain the functionality of the procedure
-- Procedure for synchronizing the attachments
-- MODIFICATION HISTORY
-- Person      Date    Comments
--  dpatel      20/03/2006
-- ---------   ------  -------------------------------------------
v_proc_rev_id FND_ATTACHED_DOCUMENTS.pk1_value%type;
v_proc_org_rev_id FND_ATTACHED_DOCUMENTS.pk1_value%type;
BEGIN
    select process_org_rev_id into v_proc_org_rev_id
    from amw_process_organization
    where process_id = p_process_id
        and organization_id = p_org_id
        and end_date is null;

    select distinct pk1_value into v_proc_rev_id
    From FND_ATTACHED_DOCUMENTS
    where entity_name ='AMW_PROCESS'
        and pk1_value in ( select PROCESS_REV_ID
                            from amw_process_vl
                            where  process_id = p_process_id
                            and end_date is null);

    IF p_add_upd_flag = 'U' THEN
        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => 'AMW_PROCESS_ORGANIZATION'
         ,X_pk1_value => v_proc_org_rev_id);
         --,X_delete_document_flag => 'Y');

    END IF; -- if update then delete the current attachments before adding new

    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROCESS'
     ,X_from_pk1_value => v_proc_rev_id
     ,X_to_entity_name => 'AMW_PROCESS_ORGANIZATION'
     ,X_to_pk1_value => v_proc_org_rev_id
     ,X_created_by => G_USER_ID
     ,X_last_update_login => G_LOGIN_ID
     );

EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN;
END sync_attachments; -- Procedure

-- import key accounts
procedure import_process_attributes(p_child_process_id in number,
                                    p_org_id in number) is
cursor party_list(pid number) is
   SELECT      TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:','')) party_id,
        	   granted_menu.menu_name role_name,
        	   obj.obj_name object_name,
     		   granted_menu.menu_id menu_id,
		   grants.end_date end_date
         FROM fnd_grants grants,
             fnd_menus granted_menu,
             fnd_objects obj
         WHERE obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
         AND   grants.object_id = obj.object_id
         AND   grants.grantee_type ='USER'
         AND   grantee_key like 'HZ_PARTY%'
         AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         AND   grants.menu_id = granted_menu.menu_id
         AND   grants.instance_type = 'INSTANCE'
         AND   grants.instance_pk1_value = to_char(pid)
         AND   grants.instance_pk2_value = '*NULL*'
         AND   grants.instance_pk3_value = '*NULL*'
         AND   grants.instance_pk4_value = '*NULL*'
         AND   grants.instance_pk5_value = '*NULL*'
         and   granted_menu.menu_name in ('AMW_RL_PROC_OWNER_ROLE', 'AMW_RL_PROC_FINANCE_OWNER_ROLE', 'AMW_RL_PROC_APPL_OWNER_ROLE');

l_return_status varchar2(10);
l_msg_count number;
l_msg_data varchar2(4000);

begin

  for party_list_rec in party_list(p_child_process_id) loop
	  exit when party_list%notfound;

	  if party_list_rec.role_name = 'AMW_RL_PROC_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_child_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_msg_count,
               x_grant_guid            => l_msg_data,
               p_check_for_existing    => FND_API.G_FALSE);

	  elsif party_list_rec.role_name = 'AMW_RL_PROC_FINANCE_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_FIN_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_child_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_msg_count,
               x_grant_guid            => l_msg_data,
               p_check_for_existing    => FND_API.G_FALSE);

	  elsif party_list_rec.role_name = 'AMW_RL_PROC_APPL_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_APPL_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_child_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_msg_count,
               x_grant_guid            => l_msg_data,
               p_check_for_existing    => FND_API.G_FALSE);

	  end if;

  end loop;

    insert into amw_acct_associations
    (ACCT_ASSOC_ID,
    NATURAL_ACCOUNT_ID,
    PK1,
    PK2,
    STATEMENT_ID,
    STATEMENT_LINE_ID,
    ORIG_SYSTEM_ACCT_VALUE,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_ACCT_ASSOCIATIONS_S.nextval,
    NATURAL_ACCOUNT_ID,
    p_org_id,
    PK1,
    STATEMENT_ID,
    STATEMENT_LINE_ID,
    ORIG_SYSTEM_ACCT_VALUE,
    sysdate,
    null,
    null,
    null,
    'PROCESS_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_acct_associations
    where PK1 = p_child_process_id
    and object_type = 'PROCESS'
    and approval_date is not null
    and deletion_approval_date is null);
insert into amw_objective_associations
    (OBJECTIVE_ASSOCIATION_ID,
    PROCESS_OBJECTIVE_ID,
    PK1,
    PK2,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
    PROCESS_OBJECTIVE_ID,
    p_org_id,
    PK1,
    sysdate,
    null,
    null,
    null,
    'PROCESS_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_objective_associations
    where PK1 = p_child_process_id
    and object_type = 'PROCESS'
    and approval_date is not null
    and deletion_approval_date is null);

sync_attachments(p_process_id => p_child_process_id
    ,p_org_id => p_org_id
    ,p_add_upd_flag => 'A');

end;

-- ****************************************************************************

procedure import_rcm_for_new_orgprocess(p_child_process_id in number,
                                        p_org_id in number) is

begin

    insert into amw_risk_associations
    (RISK_ASSOCIATION_ID,
    RISK_ID,
    PK1,
    PK2,
    RISK_LIKELIHOOD_CODE,
    RISK_IMPACT_CODE,
    MATERIAL,
    MATERIAL_VALUE,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_RISK_ASSOCIATIONS_S.nextval,
    RISK_ID,
    p_org_id,
    PK1,
    RISK_LIKELIHOOD_CODE,
    RISK_IMPACT_CODE,
    MATERIAL,
    MATERIAL_VALUE,
    sysdate,
    null,
    null,
    null,
    'PROCESS_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_risk_associations
    where PK1 = p_child_process_id
    and object_type = 'PROCESS'
    and approval_date is not null
    and deletion_approval_date is null);
--    and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
--    and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)));


    insert into amw_control_associations
    (CONTROL_ASSOCIATION_ID,
    CONTROL_ID,
    PK1,
    PK2,
    PK3,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_CONTROL_ASSOCIATIONS_S.nextval,
    CONTROL_ID,
    p_org_id,
    PK1,
    PK2,
    sysdate,
    null,
    null,
    null,
    'RISK_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_control_associations
    where PK1 = p_child_process_id
    and object_type = 'RISK'
    and approval_date is not null
    and deletion_approval_date is null);
--    and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
--    and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)));


-- abedajna, control objective import
    insert into amw_objective_associations
    (OBJECTIVE_ASSOCIATION_ID,
    PROCESS_OBJECTIVE_ID,
    PK1,
    PK2,
    PK3,
    PK4,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
    o.PROCESS_OBJECTIVE_ID,
    p_org_id,
    o.PK1,
    o.PK2,
    o.pk3,
    sysdate,
    null,
    null,
    null,
    'CONTROL_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_objective_associations o, amw_control_associations c
    where o.object_type = 'CONTROL'
    and o.approval_date is not null
    and o.deletion_approval_date is null
    and c.object_type = 'RISK_ORG'
    and c.approval_date is null
    and c.deletion_date is null
    and c.pk1 = p_org_id
    and c.pk2 = p_child_process_id
    and c.pk2 = o.pk1
    and c.pk3 = o.pk2
    and o.pk3 = c.control_id);

    insert into amw_ap_associations
    (AP_ASSOCIATION_ID,
    AUDIT_PROCEDURE_ID,
    PK1,
    PK2,
    PK3,
    DESIGN_EFFECTIVENESS,
    OP_EFFECTIVENESS,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_AP_ASSOCIATIONS_S.nextval,
    AUDIT_PROCEDURE_ID,
    p_org_id,
    p_child_process_id,
    PK1,
--ko, the values are pk1 = org, pk2 = process, pk3 = control in the org context.    PK2,
    DESIGN_EFFECTIVENESS,
    OP_EFFECTIVENESS,
    null, --ko commenting.. we set association creation date upon approval of the process..sysdate,
    null,
    null,
    null,
    'CTRL_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_ap_associations
    where PK1 in --ko, replacing  = with in  controls can be more than one..
        (select distinct control_id
        from amw_control_associations
        where PK1 = p_child_process_id
        and object_type = 'RISK'
        and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
        and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)))
    and object_type = 'CTRL'
    and approval_date is not null
    and deletion_approval_date is null);
--    and (APPROVAL_DATE is not null and APPROVAL_DATE <= sysdate)
--    and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)));


end import_rcm_for_new_orgprocess;
-- ****************************************************************************

-- make the attributes and RCM of a target process in org the same as those of
-- the same process in rl. If the target is in draft, just update, else revise and update
procedure synch_process_att_rcm(
	p_org_id in number,
	p_process_id in number,
	apply_rcm in varchar2) is

l_RL_PROCESS_REV_ID               amw_process.PROCESS_REV_ID%type;
l_SIGNIFICANT_PROCESS_FLAG	      amw_process.SIGNIFICANT_PROCESS_FLAG%type;
l_STANDARD_PROCESS_FLAG 	      amw_process.STANDARD_PROCESS_FLAG%type;
l_PROCESS_CATEGORY    		      amw_process.PROCESS_CATEGORY%type;
l_STANDARD_VARIATION      	      amw_process.STANDARD_VARIATION%type;
l_ATTRIBUTE_CATEGORY      	      amw_process.ATTRIBUTE_CATEGORY%type;
l_ATTRIBUTE1              	      amw_process.ATTRIBUTE1%type;
l_ATTRIBUTE2              	      amw_process.ATTRIBUTE2%type;
l_ATTRIBUTE3              	      amw_process.ATTRIBUTE3%type;
l_ATTRIBUTE4              	      amw_process.ATTRIBUTE4%type;
l_ATTRIBUTE5              	      amw_process.ATTRIBUTE5%type;
l_ATTRIBUTE6              	      amw_process.ATTRIBUTE6%type;
l_ATTRIBUTE7              	      amw_process.ATTRIBUTE7%type;
l_ATTRIBUTE8              	      amw_process.ATTRIBUTE8%type;
l_ATTRIBUTE9              	      amw_process.ATTRIBUTE9%type;
l_ATTRIBUTE10             	      amw_process.ATTRIBUTE10%type;
l_ATTRIBUTE11             	      amw_process.ATTRIBUTE11%type;
l_ATTRIBUTE12             	      amw_process.ATTRIBUTE12%type;
l_ATTRIBUTE13             	      amw_process.ATTRIBUTE13%type;
l_ATTRIBUTE14             	      amw_process.ATTRIBUTE14%type;
l_ATTRIBUTE15             	      amw_process.ATTRIBUTE15%type;
l_SECURITY_GROUP_ID       	      amw_process.SECURITY_GROUP_ID%type;
l_PROCESS_TYPE            	      amw_process.PROCESS_TYPE%type;
l_CONTROL_ACTIVITY_TYPE		      amw_process.CONTROL_ACTIVITY_TYPE%type;


begin
  -- find out if the latest revision for target is approved or not.
  -- if approved, revise it. if draft, don't do anything
      revise_process_if_necessary(p_org_id, p_process_id);

  -- copy the attributes from rl to org
       select PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY,
			  STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE
              into
              l_RL_PROCESS_REV_ID,
			  l_SIGNIFICANT_PROCESS_FLAG,
			  l_STANDARD_PROCESS_FLAG,
			  l_PROCESS_CATEGORY,
			  l_STANDARD_VARIATION,
			  l_ATTRIBUTE_CATEGORY,
			  l_ATTRIBUTE1,
			  l_ATTRIBUTE2,
			  l_ATTRIBUTE3,
			  l_ATTRIBUTE4,
			  l_ATTRIBUTE5,
			  l_ATTRIBUTE6,
			  l_ATTRIBUTE7,
			  l_ATTRIBUTE8,
			  l_ATTRIBUTE9,
			  l_ATTRIBUTE10,
			  l_ATTRIBUTE11,
			  l_ATTRIBUTE12,
			  l_ATTRIBUTE13,
			  l_ATTRIBUTE14,
			  l_ATTRIBUTE15,
			  l_SECURITY_GROUP_ID,
			  l_PROCESS_TYPE,
			  l_CONTROL_ACTIVITY_TYPE
              from amw_process
              where process_id = p_process_id
              and end_date is null;


      update amw_process_organization
      set     RL_PROCESS_REV_ID             =   l_RL_PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG      =   l_SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG	        =   l_STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY_CODE	            =   l_PROCESS_CATEGORY,
			  STANDARD_VARIATION	        =   l_STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY            =   l_ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1		    =   l_ATTRIBUTE1,
			  ATTRIBUTE2			=   l_ATTRIBUTE2,
			  ATTRIBUTE3			=   l_ATTRIBUTE3,
			  ATTRIBUTE4			=   l_ATTRIBUTE4,
			  ATTRIBUTE5			=   l_ATTRIBUTE5,
			  ATTRIBUTE6			=   l_ATTRIBUTE6,
			  ATTRIBUTE7			=   l_ATTRIBUTE7,
			  ATTRIBUTE8			=   l_ATTRIBUTE8,
			  ATTRIBUTE9			=   l_ATTRIBUTE9,
			  ATTRIBUTE10			=   l_ATTRIBUTE10,
			  ATTRIBUTE11			=   l_ATTRIBUTE11,
			  ATTRIBUTE12			=   l_ATTRIBUTE12,
			  ATTRIBUTE13			=   l_ATTRIBUTE13,
			  ATTRIBUTE14			=   l_ATTRIBUTE14,
			  ATTRIBUTE15			=   l_ATTRIBUTE15,
			  SECURITY_GROUP_ID		=   l_SECURITY_GROUP_ID,
			  PROCESS_TYPE			=   l_PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE	=   l_CONTROL_ACTIVITY_TYPE
      where organization_id = p_org_id
      and process_id = p_process_id
      and end_date is null;

  -- apply process key accounts

    -- delete existing accounts
        update amw_acct_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   deletion_date is null;
    --ko, delete the rows that are not approved..happens in case of synchronizing latest revision and the some accounts are added to that revision..
      delete amw_acct_associations
      where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   approval_date is null;

    -- add new accounts
    import_process_attributes(p_process_id, p_org_id);

  -- apply rcm if necessary
    if apply_rcm = 'Y' then

    -- delete existing rcm
    -- populate the delete date for the existing rows where delete_date is null and
    -- import corresponding data from library context. Ideally we don't need to populate
    -- the delete_dates for all the current rows, we can do an incremental thing, i.e.
    -- delete rows that are not there in rl, and add the remaining. However, that means
    -- we need to do some in memory processing, and for the time being, I choose to skip that.
        delete_existing_rcm(p_process_id, p_org_id);

    -- apply new rcm
        import_rcm_for_new_orgprocess(p_process_id, p_org_id);
    end if;

end synch_process_att_rcm;


-- ****************************************************************************

procedure delete_existing_rcm(
p_process_id in number,
p_org_id     in number) is

begin

-- ko, We Don't want the draft associations to linger in the table..So delete them..
        delete amw_risk_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   approval_date is null;

        update amw_risk_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   deletion_date is null;

--ko, Similarly for controls also..

        delete amw_control_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'RISK_ORG'
        and   approval_date is null;

        update amw_control_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'RISK_ORG'
        and   deletion_date is null;

-- abedajna, control objectives
        delete amw_objective_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'CONTROL_ORG'
        and   approval_date is null;

        update amw_objective_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'CONTROL_ORG'
        and   deletion_date is null;

--      in orgs, ap's don't undergo revisions..
-- association creation date is null for AP's for draft control associations..We can remove those aps..
-- ko1. uncommenting the following lines.. We do need to set the deletion date in order to maintain the history.
      delete from amw_ap_associations
      where pk1 = p_org_id
      and   pk2 = p_process_id
      and association_creation_date is null
      and   object_type = 'CTRL_ORG';

      update amw_ap_associations
      set DELETION_DATE = sysdate
      where pk1 = p_org_id
      and   pk2 = p_process_id
      and   object_type = 'CTRL_ORG'
      and   deletion_date is null;

--ko2. commenting the following..
--


end delete_existing_rcm;

-- ****************************************************************************

/*
create_new_as_child_of_ex; (the basic assumption is the process itself doesn't exist in the org)
examine children in rl;
	if child does not exist in org, create_new_as_child_of_ex;
	if child exists in org
		if p_revise_existing = 'Y', synchronize
        if p_revise_existing = 'N', exit




		if p_revise_existing = 'N'
			does child exist as "direct child" of parent?
				if yes then
					exit;
				if no then
					add_ex_as_child_of_ex;
					exit;
		else if p_revise_existing = 'Y'
			is the child in Pending Approval status?
				is yes then
					exit with error;
			does child exist as "direct child" of parent?
				if yes then
					revise_process_att_rcm;
					-- note that we revise the process even if the
					-- atts and rcm are the same in org and rl, i.e.
					-- we do not perform this extra check
				if no then
					-- note that we revise the process even if the
					-- atts and rcm are the same in org and rl, i.e.
					-- we do not perform this extra check
					revise_process_att_rcm;
					add_ex_as_child_of_ex;
*/

-- main procedure for associating.
-- just make sure before calling this that the p_associated_proc_id does not already
procedure associate_process_to_org (
	p_org_id in number,
	p_parent_process_id in number,
	p_associated_proc_id in number,
	p_revise_existing in varchar2,
    p_apply_rcm in varchar2) is

pex varchar2(1);
l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin

	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.begin',
        	'OrgId:' ||p_org_id || ';ProcessId:'||p_associated_proc_id
        	||';ParentProcessId:'||p_parent_process_id||';reviseExisting:'||p_revise_existing||';ApplyRCM:'||p_apply_rcm);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.does_process_exist_in_org',
        	'p_associated_proc_id:'||p_associated_proc_id||';p_org_id:'||p_org_id);
	end if;
    pex := does_process_exist_in_org(p_associated_proc_id, p_org_id);
	if pex = 'N' then
	   -- The process is not existing in the organziation...
		-- When the process is not existing in the system, apply_rcm is always true....so pass 'Y' in the apply rcm parameter.
		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.import_rlproc_as_child_of_ex',
        		p_org_id||';'||p_parent_process_id||';'||p_associated_proc_id||';'||'Y');
		end if;
        import_rlproc_as_child_of_ex (p_org_id, p_parent_process_id, p_associated_proc_id, 'Y');

        if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.associate_hierarchy',
        		p_associated_proc_id ||';'||p_org_id ||';'||p_revise_existing ||';'||p_apply_rcm);
		end if;
		associate_hierarchy(p_associated_proc_id, p_org_id, p_revise_existing, p_apply_rcm);

	elsif pex = 'D' then --The process is existing in the system some time back and got deleted. so undelete it and sync up..
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.undelete',
        			p_associated_proc_id ||';'||p_org_id );
			end if;
	        undelete(p_associated_proc_id, p_org_id);
	        if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.add_delete_ex_child',
        			p_org_id ||';'||p_parent_process_id ||';'||p_associated_proc_id ||';'||'ADD');
			end if;
			add_delete_ex_child (p_org_id, p_parent_process_id, p_associated_proc_id, 'ADD');
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.Synchronize_process',
        			p_org_id ||';'||p_associated_proc_id);
			end if;
            Synchronize_process(p_org_id      => p_org_id,
								p_process_id  => p_associated_proc_id,
								p_sync_mode   => 'PONLY',               -- Include sub processes also..
								p_sync_hierarchy => 'NO',              -- Sync up the hierarchy also..
								p_sync_attributes => 'YES',				-- Sync up the attributes also..
								p_sync_rcm        => 'SLIB',			-- Sync with the library definition...
								p_sync_people     => 'SLIB'				-- Sync with library definition....
								 );
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.associate_hierarchy',
        			p_associated_proc_id ||';'||p_org_id||';'||p_revise_existing||';'||p_apply_rcm);
			end if;
			associate_hierarchy(p_associated_proc_id, p_org_id, p_revise_existing, p_apply_rcm);
    end if;

    if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_PROCESS_TO_ORG.End',
        'End');
	end if;
end associate_process_to_org;


-- ****************************************************************************
-- note that p_revise_existing => leave the exisitng process (if exists) as is
-- or "revise" it. Here "revise" is used more in a loose sense of the term,
-- in the sense of synchronization
procedure associate_hierarchy (
	p_parent_process_id in number,
  	p_org_id in number,
    p_revise_existing in varchar2,
    p_apply_rcm in varchar2) is

  cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

  c1_rec c1%rowtype;
  pex varchar2(1);
  l_child_process_id number;
  pending_approval_exception exception;
  err_msg varchar2(4000);
  l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin
  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.begin',
        ' OrgId:' ||p_org_id ||';ParentProcessId:'||p_parent_process_id||';reviseExisting:'||p_revise_existing||';ApplyRCM:'||p_apply_rcm);
  end if;

  for c1_rec in c1(p_parent_process_id) loop
	  exit when c1%notfound;
        l_child_process_id := c1_rec.child_process_id;
        if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.does_process_exist_in_org',l_child_process_id||';'||p_org_id);
  		end if;
        pex := does_process_exist_in_org(l_child_process_id, p_org_id);

        -- case 1: l_process_id does not exist in the org
        if pex = 'N' then
        -- Apply RCM is Yes for a new process.....
        	if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.import_rlproc_as_child_of_ex',
        		p_org_id||';'||p_parent_process_id||';'||l_child_process_id||';'||'Y');
  			end if;
            import_rlproc_as_child_of_ex(p_org_id, p_parent_process_id, l_child_process_id, 'Y');
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.associate_hierarchy',
        		l_child_process_id||';'||p_org_id||';'||p_revise_existing||';'||p_apply_rcm);
  			end if;
            associate_hierarchy(l_child_process_id, p_org_id, p_revise_existing, p_apply_rcm);
        -- case 2: l_process_id exists in the org
        elsif pex = 'Y' then
        	if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.add_delete_ex_child',
        			p_org_id ||';'||p_parent_process_id ||';'||l_child_process_id ||';'||'ADD');
			end if;
            add_delete_ex_child (p_org_id, p_parent_process_id, l_child_process_id, 'ADD');
            if p_revise_existing = 'Y' then
                    -- Don't need the following line..sync process handles this..
                    --produce_err_if_pa_or_locked(p_org_id, l_child_process_id);
                    -- User want to synchronize the changes..so do sync up the process..apply_rcm is passed by user for the existing processes.
                    if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.Synchronize_process',
        				p_org_id ||';'||l_child_process_id ||';'||'PSUBP');
					end if;
                    Synchronize_process(
										p_org_id      => p_org_id,
										p_process_id  => l_child_process_id,
										p_sync_mode   => 'PSUBP',               -- Include sub processes also..
										p_sync_hierarchy => 'YES',              -- Sync up the hierarchy also..
										p_sync_attributes => 'YES',				-- Sync up the attributes also..
										p_sync_rcm        => p_apply_rcm,				-- get the value from the user...
										p_sync_people     => 'SLIB'				-- Sync with library definition....
								      );
			else
				 if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.Synchronize_process',
        				p_org_id ||';'||l_child_process_id ||';'||'PONLY');
				 end if;
				Synchronize_process(    p_org_id      => p_org_id,
										p_process_id  => l_child_process_id,
										p_sync_mode   => 'PONLY',               -- DON'T Include sub processes also..
										p_sync_hierarchy => 'NO',              --  NO Sync up the hierarchy also..
										p_sync_attributes => 'NO',				-- DON'T Sync up the attributes also..
										p_sync_rcm        => p_apply_rcm,	    -- DO IT ACCORDING TO THE value from the user...
										p_sync_people     => 'RDEF'				-- DON'T DO ANY CHANGES..Sync with library definition....
								      );

            end if;
        -- case 3: l_process_id exists in the org but is deleted.
        elsif pex = 'D' then

            if p_revise_existing = 'Y' then
            		if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.produce_err_if_pa_or_locked',
        				p_org_id ||';'||l_child_process_id );
				 	end if;
                    produce_err_if_pa_or_locked(p_org_id, l_child_process_id);
                    if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.associate_process_to_org',
        				p_org_id ||';'||l_child_process_id ||';'||l_child_process_id);
				 	end if;
                    associate_process_to_org (  p_org_id => p_org_id,
												p_parent_process_id => p_parent_process_id,
												p_associated_proc_id => l_child_process_id,
												p_revise_existing => p_revise_existing,
												p_apply_rcm => p_apply_rcm);
            elsif p_revise_existing = 'N' then
                -- Check if the process got deleted and approved..In this case we need to bring this back ...
                BEGIN
                	select 'Y' into pex
                	from amw_process_organization
                	where organization_id = p_org_id
                	and process_id = l_child_process_id
                	and end_date is null
                	and approval_date is not null
                	and deletion_date is not null;

                	-- HERE WE NEED TO ASSOCIATE THIS ONE AS NEW PROCESS..
                	if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.associate_process_to_org',
        				p_org_id ||';'||l_child_process_id ||';'||l_child_process_id);
				 	end if;
                	associate_process_to_org (
											p_org_id => p_org_id,
											p_parent_process_id => p_parent_process_id,
											p_associated_proc_id => l_child_process_id,
											p_revise_existing => p_revise_existing,
											p_apply_rcm => p_apply_rcm);

                EXCEPTION
                	WHEN NO_DATA_FOUND THEN
                		null;

				END;

            end if;

        end if;
  end loop;
 if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.ASSOCIATE_HIERARCHY.End',
        'End');
  end if;
end associate_hierarchy;

-- ****************************************************************************
-- this is very similar to associate_hierarchy, but there are some important differences.
-- During synchronization, the existing children of the process being synchronized are deleted
-- in the org. Obviously, p_revise_existing has no meaning, by default it is Y

-- assume that p_parent_process_id exists in the org and its attributes and RCM
-- are already synchronized. also, this process is in draft status.
-- traverse the approved hierarchy in rl. For every process_id in org, delete its
-- existing list of children and add the children from rl (associate if necessary).
-- do this recursively.
procedure synchronize_hierarchy (
								p_org_id   in number,
								p_parent_process_id  in number,
								p_sync_attributes in varchar2,
								p_sync_rcm in varchar2,
								p_sync_people in varchar2
								) is

    cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

  c1_rec c1%rowtype;
  l_child_process_id number;
  pex varchar2(1);
  l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin

	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.begin',
        ' OrgId:' ||p_org_id || ';p_parent_process_id:'||p_parent_process_id
        ||';p_sync_attributes:'||p_sync_attributes||';p_sync_rcm:'||p_sync_rcm||';p_sync_people:'||p_sync_people);
	end if;


-- first delete all children of this process in the org.
  delete from amw_latest_hierarchies
  where parent_id = p_parent_process_id
  and organization_id = p_org_id;


  for c1_rec in c1(p_parent_process_id) loop
	  exit when c1%notfound;
        l_child_process_id := c1_rec.child_process_id;
        if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.does_process_exist_in_org',
        	l_child_process_id||';'||p_org_id);
		end if;
        pex := does_process_exist_in_org(l_child_process_id, p_org_id);

        -- case 1: child does not exist in the org, associate it
        if pex = 'N' then
        	if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.import_rlproc_as_child_of_ex',
        		p_org_id||';'||l_child_process_id);
			end if;
            import_rlproc_as_child_of_ex(p_org_id, p_parent_process_id, l_child_process_id, 'Y');
          	if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.synchronize_hierarchy',
        		p_org_id||';'||l_child_process_id);
			end if;

            synchronize_hierarchy(p_org_id   		   =>p_org_id,
								  p_parent_process_id  =>l_child_process_id,
								  p_sync_attributes    =>p_sync_attributes,
								  p_sync_rcm           =>p_sync_rcm,
								  p_sync_people        =>p_sync_people
								  );
        -- case 2: child exists in the org
        elsif pex = 'Y' then
        	if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.add_delete_ex_child',
        		p_org_id||';'||p_parent_process_id||';'||l_child_process_id||';'||'ADD');
			end if;
            add_delete_ex_child (p_org_id, p_parent_process_id, l_child_process_id, 'ADD');

--            produce_err_if_pa_or_locked(p_org_id, l_child_process_id);
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.synchronize_process',
        		p_org_id||';'||l_child_process_id);
			end if;
            synchronize_process(  p_org_id   		   =>p_org_id,
								  p_process_id  =>l_child_process_id,
								  p_sync_mode          => 'PSUBP',          -- SYNC UP ALL THE CHILD PROCESSES
								  p_sync_hierarchy     =>'YES',				-- SYNC UP THE HIERARCHY ALSO..
								  p_sync_attributes    =>p_sync_attributes,
								  p_sync_rcm           =>p_sync_rcm,
								  p_sync_people        =>p_sync_people
								  );
        -- case 3: child exists in the org but is deleted.
        elsif pex = 'D' then

        -- Check if the process got deleted and approved..In this case we need to bring this back ...
                BEGIN
                	select 'Y' into pex
                	from amw_process_organization
                	where organization_id = p_org_id
                	and process_id = l_child_process_id
                	and end_date is null
                	and approval_date is not null
                	and deletion_date is not null;
					if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        				'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.undelete',
        				l_child_process_id||';'||p_org_id);
					end if;
                	undelete(l_child_process_id, p_org_id);
                	if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        				'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.add_delete_ex_child',
        				p_org_id||';'||p_parent_process_id||';'||l_child_process_id||';'||'ADD');
					end if;
                  	add_delete_ex_child (p_org_id, p_parent_process_id, l_child_process_id, 'ADD');
                  	if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        				'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.synchronize_process',
        				p_org_id||';'||l_child_process_id);
					end if;
                  	Synchronize_process(p_org_id      => p_org_id,
								p_process_id  => l_child_process_id,
								p_sync_mode   => 'PONLY',               -- Include sub processes also..
								p_sync_hierarchy => 'NO',              -- Sync up the hierarchy also..
								p_sync_attributes => 'YES',				-- Sync up the attributes also..
								p_sync_rcm        => 'SLIB',			-- Sync with the library definition...
								p_sync_people     => 'SLIB'				-- Sync with library definition....
								 );

					if( l_log_stmt_level >= l_curr_log_level ) then
    					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        				'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.synchronize_hierarchy',
        				p_org_id||';'||l_child_process_id);
					end if;
                	synchronize_hierarchy(p_org_id     =>p_org_id,
								  p_parent_process_id  =>l_child_process_id,
								  p_sync_attributes    =>p_sync_attributes,
								  p_sync_rcm           =>p_sync_rcm,
								  p_sync_people        =>p_sync_people
								  );

                EXCEPTION
                	WHEN NO_DATA_FOUND THEN
                		if( l_log_stmt_level >= l_curr_log_level ) then
    						FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        					'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.undelete',
        					l_child_process_id||';'||p_org_id);
						end if;
                		undelete(l_child_process_id, p_org_id);
                		if( l_log_stmt_level >= l_curr_log_level ) then
    						FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        					'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.add_delete_ex_child',
        					p_org_id||';'||p_parent_process_id||';'||l_child_process_id||';'||'ADD');
						end if;
                  		add_delete_ex_child (p_org_id, p_parent_process_id, l_child_process_id, 'ADD');
                  		if( l_log_stmt_level >= l_curr_log_level ) then
    						FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        					'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_HIERARCHY.synchronize_process',
        					p_org_id||';'||l_child_process_id);
						end if;
                  		Synchronize_process(p_org_id      => p_org_id,
								p_process_id  => l_child_process_id,
								p_sync_mode   => 'PSUBP',               -- Include sub processes also..
								p_sync_hierarchy => 'YES',              -- Sync up the hierarchy also..
								p_sync_attributes => p_sync_attributes,				-- Sync up the attributes also..
								p_sync_rcm        => p_sync_rcm,			-- Sync with the library definition...
								p_sync_people     => p_sync_people				-- Sync with library definition....
								 );

				END;

        end if;
  end loop;


end synchronize_hierarchy;

--*****************************************************************************
-- Synchronize Risk library Process hierarchy with the Organization
-- Process Hierarchy
--*****************************************************************************
procedure synchronize_hierarchy (
								p_parent_process_id  in number,
								p_sync_attributes in varchar2,
								p_sync_rcm in varchar2,
								p_sync_people in varchar2
								) is

    cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

  c1_rec c1%rowtype;
  l_child_process_id number;
  pex varchar2(1);
  l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin

    -- first delete all children of this process in the org.
    FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        delete from amw_latest_hierarchies
        where parent_id = p_parent_process_id
        and organization_id = Org_Ids(indx);

    FOR indx IN Org_Ids.FIRST .. Org_Ids.LAST
    LOOP
        for c1_rec in c1(p_parent_process_id) loop
        exit when c1%notfound;
            l_child_process_id := c1_rec.child_process_id;
            pex := does_process_exist_in_org(l_child_process_id, Org_Ids(indx));

            -- case 1: child does not exist in the org, associate it
            if pex = 'N' then
                import_rlproc_as_child_of_ex(Org_Ids(indx), p_parent_process_id, l_child_process_id, 'Y');
                synchronize_hierarchy(p_org_id   		   =>Org_Ids(indx),
				    				  p_parent_process_id  =>l_child_process_id,
					       			  p_sync_attributes    =>p_sync_attributes,
					   	       		  p_sync_rcm           =>p_sync_rcm,
							     	  p_sync_people        =>p_sync_people
								     );
            -- case 2: child exists in the org
            elsif pex = 'Y' then
                add_delete_ex_child (Org_Ids(indx), p_parent_process_id, l_child_process_id, 'ADD');

                synchronize_process(  p_org_id   		   =>Org_Ids(indx),
	       							  p_process_id         =>l_child_process_id,
		      						  p_sync_mode          => 'PSUBP',          -- SYNC UP ALL THE CHILD PROCESSES
			     					  p_sync_hierarchy     =>'YES',				-- SYNC UP THE HIERARCHY ALSO..
				    				  p_sync_attributes    =>p_sync_attributes,
					       			  p_sync_rcm           =>p_sync_rcm,
						      		  p_sync_people        =>p_sync_people
                                    );
            -- case 3: child exists in the org but is deleted.
            elsif pex = 'D' then
            -- Check if the process got deleted and approved..In this case we need to bring this back ...
                BEGIN
                	select 'Y' into pex
                	from amw_process_organization
                	where organization_id = Org_Ids(indx)
                	and process_id = l_child_process_id
                	and end_date is null
                	and approval_date is not null
                	and deletion_date is not null;

                	undelete(l_child_process_id, Org_Ids(indx));

                  	add_delete_ex_child (Org_Ids(indx), p_parent_process_id, l_child_process_id, 'ADD');

                  	Synchronize_process(p_org_id      => Org_Ids(indx),
								p_process_id  => l_child_process_id,
								p_sync_mode   => 'PONLY',               -- Include sub processes also..
								p_sync_hierarchy => 'NO',               -- Sync up the hierarchy also..
								p_sync_attributes => 'YES',				-- Sync up the attributes also..
								p_sync_rcm        => 'SLIB',			-- Sync with the library definition...
								p_sync_people     => 'SLIB'				-- Sync with library definition....
								 );

                	synchronize_hierarchy(p_org_id     =>Org_Ids(indx),
								  p_parent_process_id  =>l_child_process_id,
								  p_sync_attributes    =>p_sync_attributes,
								  p_sync_rcm           =>p_sync_rcm,
								  p_sync_people        =>p_sync_people
								  );
                EXCEPTION
                	WHEN NO_DATA_FOUND THEN
                		undelete(l_child_process_id, Org_Ids(indx));
                  		add_delete_ex_child (Org_Ids(indx), p_parent_process_id, l_child_process_id, 'ADD');
                  		Synchronize_process(p_org_id      => Org_Ids(indx),
								p_process_id  => l_child_process_id,
								p_sync_mode   => 'PSUBP',               -- Include sub processes also..
								p_sync_hierarchy => 'YES',              -- Sync up the hierarchy also..
								p_sync_attributes => p_sync_attributes,	-- Sync up the attributes also..
								p_sync_rcm        => p_sync_rcm,		-- Sync with the library definition...
								p_sync_people     => p_sync_people		-- Sync with library definition....
								 );
				END;
            end if;
        end loop;
    END LOOP;
end synchronize_hierarchy;
-- ****************************************************************************

function process_locked(p_process_id in number, p_org_id in number) return boolean is
l_dummy number;
begin
    select 1
    into l_dummy
    from amw_process_locks
    where locked_process_id = p_process_id
    and organization_id = p_org_id;

    return true;
exception
    when no_data_found then
        return false;

    when too_many_rows then
        return true;

end process_locked;


-- ****************************************************************************

function process_pending_approval(p_process_id in number, p_org_id in number) return boolean is
l_dummy number;
begin
    select 1
    into l_dummy
    from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null
    and approval_status = 'PA';

    return true;
exception
    when no_data_found then
        return false;
end process_pending_approval;

-- ****************************************************************************

-- remove the deletion_date. If deletion is approved, revise the process.
procedure undelete (
	p_process_id in number,
  	p_org_id in number) is

begin

-- KSR CHANGES BEGIN...

-- Make changes such that the disassociation is also taken care of....


-- KSR CHANGES END.....
    revise_process_if_necessary (p_org_id, p_process_id);

    update amw_process_organization
         set    deletion_date = null,
                object_version_number = object_version_number + 1
         where  process_id = p_process_id
         and    organization_id = p_org_id
         and    end_date is null;

end undelete;

-- ****************************************************************************

function does_process_exist_in_org(p_process_id in number, p_org_id in number) return varchar2 is
l_del_date date := null;
begin
-- check if the latest version is end-dated
    select deletion_date
    into l_del_date
    from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null;

    if l_del_date is null then
        return 'Y';
    else
        return 'D';
    end if;

exception
    when no_data_found then
        return 'N';

--    when too_many_rows then
--        return 'Y';

end does_process_exist_in_org;

-- ****************************************************************************

procedure find_rl_app_hier_children(p_process_id in number)
is
  cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

  c1_rec c1%rowtype;

begin
  for c1_rec in c1(p_process_id) loop
	  exit when c1%notfound;
--	  child_num := child_num + 1;
--	  v_child_name(child_num) := c1_rec.CHILD_PROCESS_NAME;
          find_rl_app_hier_children(p_process_id =>c1_rec.child_process_id);
  end loop;
end find_rl_app_hier_children;

-- ****************************************************************************

procedure  produce_err_if_pa_or_locked(
	p_org_id in number,
	p_process_id in number) is

pending_approval_exception exception;
err_msg varchar2(4000);

begin

 if (process_pending_approval(p_process_id, p_org_id) OR
    process_locked(p_process_id, p_org_id)) then
                    raise pending_approval_exception;
 end if;

exception

    when pending_approval_exception then
	 rollback;
         fnd_message.set_name('AMW','AMW_ATTEMPT_MODIF_LOCKED');
         err_msg := fnd_message.get;
         fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'amw_org_hierarchy_pkg',
                   	     p_procedure_name =>   'produce_err_if_pa_or_locked',
  	                     p_error_text => err_msg);
         raise;

end produce_err_if_pa_or_locked;



-- ****************************************************************************

procedure  produce_err_if_circular(
	p_org_id in number,
	p_parent_process_id in number,
    p_child_process_id in number) is

circular_exception exception;
err_msg varchar2(4000);

begin

      if is_child_an_ancestor(p_org_id => p_org_id,
                              p_parent_process_id => p_parent_process_id,
                              p_child_process_id => p_child_process_id) then
          raise circular_exception;
      end if;

exception

    when circular_exception then
	 rollback;
         fnd_message.set_name('AMW','AMW_ATTEMPT_CIRCULAR');
         err_msg := fnd_message.get;
         fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'amw_org_hierarchy_pkg',
                   	     p_procedure_name =>   'produce_err_if_circular',
  	                     p_error_text => err_msg);
         raise;

end produce_err_if_circular;


-- ****************************************************************************

-- to be called recursively from disassociate_process_org
procedure disassociate_process_org_hier (
	p_org_id in number,
	p_process_id in number) is

  cursor c3 (l_pid number, l_org number) is
    select child_process_id
	from AMW_LATEST_HIERARCHY_ORG_V
    where parent_process_id=l_pid
    and child_organization_id = l_org;

  c3_rec c3%rowtype;
  l_child_process_id number;
  l_dummy number;
  l_exists_elsewhere boolean := false;

begin

    for c3_rec in c3(p_process_id, p_org_id) loop
	  exit when c3%notfound;
        l_child_process_id := c3_rec.child_process_id;

     -- Remove the link between the parent process and the child process...
        /*delete from amw_latest_hierarchies
        where child_id  = l_child_process_id
        and parent_id = p_process_id
        and organization_id = p_org_id;*/
        /*commenting the above delete and adding the following update
         so that when a process is dissasociated and approved,the
         children will also be approved using the below link*/
         update amw_latest_hierarchies
          set organization_id = organization_id * (-1),
              object_version_number = object_version_number + 1,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATED_BY = g_user_id,
              LAST_UPDATE_LOGIN = g_login_id
          where child_id  = l_child_process_id
          and parent_id = p_process_id
          and organization_id = p_org_id;
--remove the rcm links...dpatel
delete_existing_rcm(l_child_process_id,p_org_id);

-- Now check whether this process is locked.
        if not process_locked(l_child_process_id, p_org_id) then
          -- So we can update this to be deleted. But need to check whether this is existing as a child of any other process
            begin
              select 1 into l_dummy
              from amw_latest_hierarchies
              where child_id  = l_child_process_id
              and organization_id = p_org_id
              and parent_id <> p_process_id;

              l_exists_elsewhere := true;

            exception
              when no_data_found then
                  l_exists_elsewhere := false;
              when too_many_rows then
                  l_exists_elsewhere := true;
            end;

          if l_exists_elsewhere = false then
           -- So the Process does not exist any where..Delete from latest hierarchy..
          --   delete from amw_latest_hierarchies
          --   where child_id  = l_child_process_id
          --   and parent_id = p_process_id
          --   and organization_id = p_org_id;
            -- We need to process the child hierarchy now to disassociate --So call disassociate_proc_org_hier on child.
            disassociate_process_org_hier(p_org_id, l_child_process_id);
            -- So delete the process now..
            delete_process(p_org_id, l_child_process_id);
          end if;
      end if;
    end loop;

end disassociate_process_org_hier;

-- ****************************************************************************

procedure disassociate_process_org (
	p_org_id in number,
	p_process_id in number) is

  cursor c2 (l_pid number, l_org number) is
    select parent_process_id
	from AMW_LATEST_HIERARCHY_ORG_V
    where child_process_id = l_pid
    and child_organization_id = l_org;

  c2_rec c2%rowtype;
  l_parent_process_id number;

begin
--ko 1. First Check the process is not in locked state. Because we need to set its deletion date.
  produce_err_if_pa_or_locked(p_org_id => p_org_id,p_process_id => p_process_id);
-- ko 1. Also Check the Parents of this process can be revised/updated.. Else Produce Error.
-- obviously you got to revise those parent processes
  for c2_rec in c2(p_process_id, p_org_id) loop
    	exit when c2%notfound;
        l_parent_process_id := c2_rec.parent_process_id;
        produce_err_if_pa_or_locked(p_org_id, l_parent_process_id);
        revise_process_if_necessary(p_org_id, l_parent_process_id);
  end loop;

--ko 3. So revised all the necessary parents. No go ahead and delete them from the latest hierarchy.
-- delete all the links from latest hierarchy where p_process_id is child
        delete from amw_latest_hierarchies
        where child_id  = p_process_id
        and organization_id = p_org_id;
--remove the rcm links...dpatel
delete_existing_rcm(p_process_id,p_org_id);

-- koStart 4. Call the following API. I have a doubt regarding the functionality.
-- The functionality of disassociating a process is like the following.
-- 1. Delete the process From All its parents.
--2. For each of the child,
--      Check if the child is not locked and it is not under any other parent. If not so proceed to the next child.
--3. If the child can not be found under any other parent, then you need to disassociate this process.
--4  Just delete the parent child link. Delete the Process. call the disassociate_process_org_hier with the child.
-- koEnd.
-- disassociate the hierarchy
        disassociate_process_org_hier(p_org_id, p_process_id);
-- Now we need to delete the links of the process from the root process if there are any..
        AMW_PROC_ORG_APPROVAL_PKG.write_approved_hierarchy(-2, 2, p_org_id);

 -- Now we need to set the deletion date of this process...................

		delete_process(p_org_id, p_process_id);

end disassociate_process_org;

-- ****************************************************************************

procedure upd_ltst_risk_count(p_org_id in number, p_process_id in number) is

cursor c1 is
   (select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_id
                    		from amw_latest_hierarchies
                    		start with child_id = p_process_id and organization_id = p_org_id
                    		connect by prior parent_id = child_id
                    		and organization_id = p_org_id
                        union all
                        select p_process_id from dual
                      )
    and end_date is null
    );
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   (select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_child_id
                        from amw_org_hierarchy_denorm
                        where process_id = p_process_id
                        and organization_id = p_org_id
                        and up_down_ind = 'U'
                        and hierarchy_type = 'L'
                       )
    and end_date is null
    union
    select p_process_id from dual);
*/
cursor c2 is
    select process_id
    from amw_process_organization
    where end_date is null
   and organization_id = p_org_id;

type t_n is table of number;

x t_n;

begin
if p_process_id is null then
    open c2;
    fetch c2 bulk collect into x;
    close c2;
else
    open c1;
    fetch c1 bulk collect into x;
    close c1;
end if;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process_organization
        set risk_count_latest = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 = p_org_id
                            and pk2 in (
                            						select child_id
  																			from amw_latest_hierarchies
  																			start with child_id = x(ctr) and organization_id = p_org_id
  																			connect by prior child_id = parent_id and organization_id = p_org_id
                            						)
/* ko removing the usage of amw_org_hierarchy_denorm
												    ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = x(ctr)
                            and organization_id = p_org_id
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L' ) union (select x(ctr) from dual) )
*/
                            and deletion_date is null
                            and object_type = 'PROCESS_ORG'
                            ) ),last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where end_date is null
        and process_id <> -2
        and organization_id = p_org_id
        and process_id = x(ctr);
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end upd_ltst_risk_count;

-- ****************************************************************************

procedure upd_ltst_control_count(p_org_id in number, p_process_id in number) is


cursor c1 is
		select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_id
                    		from amw_latest_hierarchies
                    		start with child_id = p_process_id and organization_id = p_org_id
                    		connect by prior parent_id = child_id
                    		and organization_id = p_org_id
  		                union all
  		                select p_process_id from dual
                       )
    and end_date is null;
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   (select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_child_id
                        from amw_org_hierarchy_denorm
                        where process_id = p_process_id
                        and organization_id = p_org_id
                        and up_down_ind = 'U'
                        and hierarchy_type = 'L'
                       )
    and end_date is null
    union
    select p_process_id from dual);
*/

cursor c2 is
    select process_id
    from amw_process_organization
    where end_date is null
   and organization_id = p_org_id;

type t_n is table of number;

x t_n;

begin
if p_process_id is null then
    open c2;
    fetch c2 bulk collect into x;
    close c2;
else
    open c1;
    fetch c1 bulk collect into x;
    close c1;
end if;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process_organization
        set control_count_latest = (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 = p_org_id
                            and pk2 in ( select child_id
  																			from amw_latest_hierarchies
  																			start with child_id = x(ctr) and organization_id = p_org_id
  																			connect by prior child_id = parent_id and organization_id = p_org_id
  																			)
/* ko remove org_denorm
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = x(ctr)
                            and organization_id = p_org_id
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L' ) union (select x(ctr) from dual)
                            )
*/
                            and deletion_date is null
                            and object_type = 'RISK_ORG'
                            ) ),last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where end_date is null
        and process_id <> -2
        and organization_id = p_org_id
        and process_id = x(ctr);
end if;

end upd_ltst_control_count;

-- ****************************************************************************

procedure upd_appr_risk_count(p_org_id in number, p_process_id in number) is

cursor c1 is
		select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_id
                        from amw_approved_hierarchies
                        start with child_id = p_process_id and organization_id = p_org_id
                        and start_date is not null and end_date is null
                        connect by prior parent_id = child_id and organization_id = p_org_id
                        and start_date is not null and end_date is null
                        union all
                        select p_process_id from dual
                        )
    and end_date is null;
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   (select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_child_id
                        from amw_org_hierarchy_denorm
                        where process_id = p_process_id
                        and organization_id = p_org_id
                        and up_down_ind = 'U'
                        and hierarchy_type = 'A'
                       )
    and end_date is null
    union
    select p_process_id from dual);
*/
cursor c2 is
    select process_id
    from amw_process_organization
    where approval_date is not null
        and approval_end_date is null
        and organization_id = p_org_id;
type t_n is table of number;

x t_n;

begin
if p_process_id is null then
    open c2;
    fetch c2 bulk collect into x;
    close c2;
else
    open c1;
    fetch c1 bulk collect into x;
    close c1;
end if;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process_organization
        set risk_count = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 = p_org_id
                            and pk2 in ( select child_id
                                         from amw_approved_hierarchies
                                         start with child_id = x(ctr) and organization_id = p_org_id
                                                and start_date is not null and end_date is null
                                         connect by prior child_id = parent_id and organization_id = p_org_id
                                                and start_date is not null and end_date is null
																				)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = x(ctr)
                            and organization_id = p_org_id
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A' ) union (select x(ctr) from dual)
                            )
*/
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'PROCESS_ORG'
                            ) ),last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where approval_date is not null
        and approval_end_date is null
        and process_id <> -2
        and organization_id = p_org_id
        and process_id = x(ctr);
end if;



end upd_appr_risk_count;

-- ****************************************************************************

procedure upd_appr_control_count(p_org_id in number, p_process_id in number) is

cursor c1 is
		select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_id
                        from amw_approved_hierarchies
                        start with child_id = p_process_id and organization_id = p_org_id
                        and start_date is not null and end_date is null
                        connect by prior parent_id = child_id and organization_id = p_org_id
                        and start_date is not null and end_date is null
                        union all
                        select p_process_id from dual
                        )
    and end_date is null;
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   (select process_id
    from amw_process_organization
    where organization_id = p_org_id
    and process_id in ( select parent_child_id
                        from amw_org_hierarchy_denorm
                        where process_id = p_process_id
                        and organization_id = p_org_id
                        and up_down_ind = 'U'
                        and hierarchy_type = 'A'
                       )
    and end_date is null
    union
    select p_process_id from dual);
*/
cursor c2 is
    select process_id
    from amw_process_organization
    where approval_date is not null
        and approval_end_date is null
        and organization_id = p_org_id;

type t_n is table of number;

x t_n;

begin
if p_process_id is null then
    open c2;
    fetch c2 bulk collect into x;
    close c2;
else
    open c1;
    fetch c1 bulk collect into x;
    close c1;
end if;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process_organization
        set control_count= (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 = p_org_id
                            and pk2 in ( select child_id
                                         from amw_approved_hierarchies
                                         start with child_id = x(ctr) and organization_id = p_org_id
                                                and start_date is not null and end_date is null
                                         connect by prior child_id = parent_id and organization_id = p_org_id
                                                and start_date is not null and end_date is null
																				)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = x(ctr)
                            and organization_id = p_org_id
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A' ) union (select x(ctr) from dual)
                            )
*/
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'RISK_ORG'
                            ) ),last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where approval_date is not null
        and approval_end_date is null
        and process_id <> -2
        and organization_id = p_org_id
        and process_id = x(ctr);
end if;


end upd_appr_control_count;

-- ****************************************************************************
PROCEDURE push_proc_org_srs(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
    p_org_range_from		IN varchar2,
    p_org_range_to			IN varchar2,
    p_synchronize		    IN varchar2,
    p_apply_rcm			    IN varchar2
)
IS
cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

cursor c2(pid number, orgName varchar2) is
    select  aauv.organization_id,
    		name
    from    amw_audit_units_v aauv
    where   NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    and     'Y' = AMW_UTILITY_PVT.IS_ORG_REGISTERED(aauv.ORGANIZATION_ID)
    and     aauv.organization_id not in(
                select distinct organization_id
                from amw_process_organization
                where process_id = pid
                and end_date is null
                and (
                    deletion_date is null or
                    (deletion_date is not null and approval_date is null)
                )
            )
    and (UPPER(NAME) LIKE UPPER(orgName));
cursor c3(pid number, rangeFrom varchar2, rangeTo varchar2) is
    select  aauv.organization_id,
    		name
    from    amw_audit_units_v aauv
    where   NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    and     'Y' = AMW_UTILITY_PVT.IS_ORG_REGISTERED(aauv.ORGANIZATION_ID)
    and     aauv.organization_id not in(
                select distinct organization_id
                from amw_process_organization
                where process_id = pid
                and end_date is null
                and (
                    deletion_date is null or
                    (deletion_date is not null and approval_date is null)
                )
            )
    and NAME >= rangeFrom and substr(NAME,0,length(rangeTo))<= rangeTo;


    conc_status             boolean;
    p_mode                  varchar2(5) := 'ASSOC';
    L_API_NAME CONSTANT     varchar2(30):= 'push_proc_org_srs';
    l_return_status	        varchar2(10);
    l_msg_data              varchar2(4000);
    l_msg_count	            number;
    p_parent_orgprocess_id  number := -2 ;


cursor c_processes (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;


type t_audit_unit_rec is record (organization_id  amw_audit_units_v.organization_id%type,
                         	   org_name  amw_audit_units_v.name%type);

type t_audit_units_tbl is table of t_audit_unit_rec;
l_audit_units_tbl t_audit_units_tbl;

show_warning boolean:= false;

BEGIN

    IF FND_GLOBAL.User_Id IS NULL THEN
        AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    if p_process_id = -1 OR p_process_id = -2 then
        conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: Cannot Associate Root Process');
        return;
    end if;
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_SRS.Begin','BEGIN');
  end if;
	if  p_org_range_from is not null and p_org_range_to is not null then
    	open c3(p_process_id, p_org_range_from,p_org_range_to);
    	fetch c3 bulk collect into l_audit_units_tbl;
    	close c3;
    elsif p_org_name is null then
    	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: No Organization filter found to proceed');
    	return;
    else
    	open c2(p_process_id, p_org_name || '%');
    	fetch c2 bulk collect into l_audit_units_tbl;
    	close c2;
	end if;
	if l_audit_units_tbl.exists(1)  then
    FOR orgid IN l_audit_units_tbl.first .. l_audit_units_tbl.last loop
--    	fnd_file.put_line(fnd_file.LOG, 'Associating to ' || l_audit_units_tbl(orgid).org_name  );
     	push_proc_per_org(
            p_parent_orgprocess_id	=> p_parent_orgprocess_id,
			p_process_id		=> p_process_id,
			p_org_id			=> l_audit_units_tbl(orgid).organization_id,
			p_mode				=> p_mode,
			p_apply_rcm			=> p_apply_rcm,
			p_synchronize		=> p_synchronize,
			p_update_count		=> FND_API.G_FALSE,
			p_commit            => FND_API.G_FALSE,
			x_return_status		=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data);

           	IF l_return_status <> 'S' THEN
           	  show_warning := true;
		      fnd_file.put_line(fnd_file.LOG, 'Error when Associating the process to ' || l_audit_units_tbl(orgid).org_name  );
		      fnd_file.put_line(fnd_file.LOG, l_msg_data );
            ELSE
            -- If user wants the processes to be associated as approved, user should set this profile to Y.
            -- Note that to get the whole hierarchy approved, user needs to set the approval option to
            -- "approve everything down below". Else only the process id passed will be approved.
            -- Although this is not very user friendly, I cannot see an option, as I cannot change the
            -- approval option ad hoc for this association process. When user associates a process,
            -- may be some-subprocess down below is in pending approval status, and that should prevent
            -- modifying the approval option.
            -- Also note that the "Approval Required" parameter for the org will be overridden, if set to yes.
	       	IF fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' THEN
	       		BEGIN
                	AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(p_process_id, l_audit_units_tbl(orgid).organization_id);
                	AMW_PROC_ORG_APPROVAL_PKG.approve(p_process_id, l_audit_units_tbl(orgid).organization_id,FND_API.G_FALSE);
                EXCEPTION
                	WHEN OTHERS THEN
                		show_warning := true;
                		ROLLBACK;
                		-- Unapproved object associations exists exception may happen..catche them here..
                		FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
                		fnd_file.put_line(fnd_file.LOG, ' Error when Approving the process in organization ' ||l_audit_units_tbl(orgid).org_name  );
                		fnd_file.put_line(fnd_file.LOG, l_msg_data);
                END;
	       	END IF;
	       END IF;
	       -- Done associating...Commit here..
	       COMMIT;
 	END LOOP;
 	if show_warning then
 	  conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Process cannot be associated to some organizations');
    end if;

-- update the org count..
	update amw_process AP
  	set AP.org_count = (select count(o.organization_id)
    					from hr_all_organization_units o,
              			hr_organization_information o2
        					WHERE o.organization_id = o2.organization_id
         					 and o2.org_information_context = 'CLASS'
         					 and o2.org_information1 = 'AMW_AUDIT_UNIT'
         					 and o2.org_information2 = 'Y'
                             and exists (select 1
                            			from amw_process_organization APO
                            			WHERE APO.organization_id = o.ORGANIZATION_ID
                            			AND  APO.process_id = AP.PROCESS_ID
                            			and APO.end_date is null
                            			and (APO.deletion_date is null or (APO.deletion_date is not null and APO.approval_date is null)))),
         AP.object_version_number = AP.object_version_number + 1
        ,AP.last_update_date = sysdate
        ,AP.last_updated_by = G_USER_ID
        ,AP.last_update_login = G_LOGIN_ID
   	where AP.approval_date is not null
    and AP.approval_end_date is null
    and AP.process_id <> -1
    and AP.process_id   IN (select APHD.parent_child_id process_to_count
                              from amw_proc_hierarchy_denorm APHD
                              where APHD.process_id = p_process_id
                              and APHD.up_down_ind = 'D'
                              and APHD.hierarchy_type = 'A'
                              union
                              select p_process_id process_to_count from dual);

	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_SRS.Update_ORG_Counts','UPDATED');
  	end if;
-- commit here..
	COMMIT;


 	if p_org_range_from is not null and p_org_range_to is not null then

 		update amw_process_organization APO
        set APO.risk_count_latest = (
                            select count(distinct ARA.risk_id) from amw_risk_associations ARA
                            where ARA.pk1 = APO.ORGANIZATION_ID
                            and ARA.pk2 in ( select alh.child_id
																				     from amw_latest_hierarchies alh
																				     start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
																				     connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
																				    )
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'L' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ARA.deletion_date is null
                            and ARA.object_type = 'PROCESS_ORG'
                            ),
        APO.control_count_latest = (
                            select count(distinct ACA.CONTROL_ID) from amw_control_associations ACA
                            where ACA.pk1 = APO.ORGANIZATION_ID
                            and ACA.pk2 in ( select alh.child_id
																				     from amw_latest_hierarchies alh
																				     start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
																				     connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
																				    )
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*													( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'L' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ACA.deletion_date is null
                            and ACA.object_type = 'RISK_ORG'
                            )
              ,APO.last_update_date = sysdate
              ,APO.last_updated_by = G_USER_ID
              ,APO.last_update_login = G_LOGIN_ID
        where APO.end_date is null
        and APO.process_id <> -2
        and APO.organization_id in (  select  aauv.organization_id
    								  from    amw_audit_units_v aauv
    								  where NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    								  and  NAME >= p_org_range_from and substr(NAME,0,length(p_org_range_to))<= p_org_range_to);
    else

    	update amw_process_organization APO
        set APO.risk_count_latest = (
                            select count(distinct ARA.risk_id) from amw_risk_associations ARA
                            where ARA.pk1 = APO.ORGANIZATION_ID
                            and ARA.pk2 in ( select alh.child_id
																				     from amw_latest_hierarchies alh
																				     start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
																				     connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
																				    )
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'L' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ARA.deletion_date is null
                            and ARA.object_type = 'PROCESS_ORG'
                            ),
        APO.control_count_latest = (
                            select count(distinct ACA.CONTROL_ID) from amw_control_associations ACA
                            where ACA.pk1 = APO.ORGANIZATION_ID
                            and ACA.pk2 in ( select alh.child_id
																				     from amw_latest_hierarchies alh
																				     start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
																				     connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
																				    )
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'L' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ACA.deletion_date is null
                            and ACA.object_type = 'RISK_ORG'
                            )
              ,APO.last_update_date = sysdate
              ,APO.last_updated_by = G_USER_ID
              ,APO.last_update_login = G_LOGIN_ID
        where APO.end_date is null
        and APO.process_id <> -2
        and APO.organization_id in (  select  aauv.organization_id
    								  from    amw_audit_units_v aauv
    								  where NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    								  and (UPPER(NAME) LIKE UPPER(p_org_name || '%')));

	end if;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_SRS.Update_Latest_Counts','UPDATED');
  	end if;
	-- do a COMMIT;
	COMMIT;

	-- Update the latest risk and control counts

        if fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' then

          if p_org_range_from is not null and p_org_range_to is not null then

	   		update amw_process_organization APO
        	set APO.risk_count = (
                            select count(distinct ARA.risk_id) from amw_risk_associations ARA
                            where ARA.pk1 = APO.ORGANIZATION_ID
                            and ARA.pk2 in (  select alh.child_id
											  											from amw_approved_hierarchies  alh
											  											start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
											     															and alh.start_date is not null and alh.end_date is null
								              								connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
								                												and alh.start_date is not null and alh.end_date is null
								           									)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'A' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ARA.approval_date is not null
                            and ARA.deletion_approval_date is null
                            and ARA.object_type = 'PROCESS_ORG'
                            ),
        	APO.control_count = (
                            select count(distinct ACA.CONTROL_ID) from amw_control_associations ACA
                            where ACA.pk1 = APO.ORGANIZATION_ID
                            and ACA.pk2 in (  select alh.child_id
											  											from amw_approved_hierarchies  alh
											  											start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
											     															and alh.start_date is not null and alh.end_date is null
								              								connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
								                												and alh.start_date is not null and alh.end_date is null
								           									)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'A' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ACA.approval_date is not null
                            and ACA.deletion_approval_date is null
                            and ACA.object_type = 'RISK_ORG'
                            )
              ,APO.last_update_date = sysdate
              ,APO.last_updated_by = G_USER_ID
              ,APO.last_update_login = G_LOGIN_ID
           where APO.approval_date is not null
           and APO.approval_end_date is null
           and APO.process_id <> -2
           and APO.organization_id in (  select  aauv.organization_id
    								  from    amw_audit_units_v aauv
    								  where NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    								  and  NAME >= p_org_range_from and substr(NAME,0,length(p_org_range_to))<= p_org_range_to);
        else

    		update amw_process_organization APO
        	set APO.risk_count = (
                            select count(distinct ARA.risk_id) from amw_risk_associations ARA
                            where ARA.pk1 = APO.ORGANIZATION_ID
                            and ARA.pk2 in (  select alh.child_id
											  											from amw_approved_hierarchies  alh
											  											start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
											     															and alh.start_date is not null and alh.end_date is null
								              								connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
								                												and alh.start_date is not null and alh.end_date is null
								           									)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'A' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ARA.approval_date is not null
                            and ARA.deletion_approval_date is null
                            and ARA.object_type = 'PROCESS_ORG'
                            ),
        	APO.control_count = (
                            select count(distinct ACA.CONTROL_ID) from amw_control_associations ACA
                            where ACA.pk1 = APO.ORGANIZATION_ID
                            and ACA.pk2 in (  select alh.child_id
											  											from amw_approved_hierarchies  alh
											  											start with alh.child_id = APO.PROCESS_ID and alh.organization_id = APO.ORGANIZATION_ID
											     															and alh.start_date is not null and alh.end_date is null
								              								connect by prior alh.child_id = alh.parent_id and alh.organization_id = APO.ORGANIZATION_ID
								                												and alh.start_date is not null and alh.end_date is null
								           									)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select AOH.parent_child_id
                            from amw_org_hierarchy_denorm AOH
                            where AOH.process_id = APO.PROCESS_ID
                            and AOH.organization_id = APO.ORGANIZATION_ID
                            and AOH.up_down_ind = 'D'
                            and AOH.hierarchy_type = 'A' ) union all (select APO.PROCESS_ID from dual)
                            )
*/
                            and ACA.approval_date is not null
                            and ACA.deletion_approval_date is null
                            and ACA.object_type = 'RISK_ORG'
                            )
              ,APO.last_update_date = sysdate
              ,APO.last_updated_by = G_USER_ID
              ,APO.last_update_login = G_LOGIN_ID
           where APO.approval_date is not null
           and APO.approval_end_date is null
           and APO.process_id <> -2
           and APO.organization_id in (  select  aauv.organization_id
    								  from    amw_audit_units_v aauv
    								  where NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    								  and (UPPER(NAME) LIKE UPPER(p_org_name || '%')));
	     end if;

	    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_SRS.Update_Approved_Counts','UPDATED');
  		end if;
      end if;
  end if;

	COMMIT;
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_SRS.End','END');
  end if;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN OTHERS THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
END push_proc_org_srs;


-- ****************************************************************************

--psomanat : assocciate to org concurrent program proceedure
PROCEDURE push_proc_org_conc_request(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_parent_orgprocess_id	IN varchar2,
    p_process_id		    IN varchar2,
    p_mode			        IN varchar2,
    p_apply_rcm			    IN varchar2,
    p_synchronize		    IN varchar2,
    p_org_id_count		    IN varchar2,
    p_org_id_string1		IN varchar2 := NULL,
    p_org_id_string2		IN varchar2 := NULL,
    p_org_id_string3		IN varchar2 := NULL,
    p_org_id_string4		IN varchar2 := NULL,
    p_org_id_string5		IN varchar2 := NULL,
    p_org_id_string6		IN varchar2 := NULL,
    p_org_id_string7		IN varchar2 := NULL,
    p_org_id_string8		IN varchar2 := NULL,
    p_org_id_string9		IN varchar2 := NULL,
    p_org_id_string10		IN varchar2 := NULL,
    p_org_id_string11		IN varchar2 := NULL,
    p_org_id_string12		IN varchar2 := NULL,
    p_org_id_string13		IN varchar2 := NULL,
    p_org_id_string14		IN varchar2 := NULL,
    p_org_id_string15		IN varchar2 := NULL,
    p_org_id_string16		IN varchar2 := NULL,
    p_org_id_string17		IN varchar2 := NULL,
    p_org_id_string18		IN varchar2 := NULL,
    p_org_id_string19		IN varchar2 := NULL,
    p_org_id_string20		IN varchar2 := NULL,
    p_org_id_string21		IN varchar2 := NULL,
    p_org_id_string22		IN varchar2 := NULL,
    p_org_id_string23		IN varchar2 := NULL,
    p_org_id_string24		IN varchar2 := NULL,
    p_org_id_string25		IN varchar2 := NULL,
    p_org_id_string26		IN varchar2 := NULL,
    p_org_id_string27		IN varchar2 := NULL,
    p_org_id_string28		IN varchar2 := NULL,
    p_org_id_string29		IN varchar2 := NULL,
    p_org_id_string30		IN varchar2 := NULL,
    p_org_id_string31		IN varchar2 := NULL,
    p_org_id_string32		IN varchar2 := NULL,
    p_org_id_string33		IN varchar2 := NULL,
    p_org_id_string34		IN varchar2 := NULL,
    p_org_id_string35		IN varchar2 := NULL,
    p_org_id_string36		IN varchar2 := NULL,
    p_org_id_string37		IN varchar2 := NULL,
    p_org_id_string38		IN varchar2 := NULL,
    p_org_id_string39		IN varchar2 := NULL,
    p_org_id_string40		IN varchar2 := NULL,
    p_org_id_string41		IN varchar2 := NULL,
    p_org_id_string42		IN varchar2 := NULL,
    p_org_id_string43		IN varchar2 := NULL,
    p_org_id_string44		IN varchar2 := NULL,
    p_org_id_string45		IN varchar2 := NULL,
    p_org_id_string46		IN varchar2 := NULL,
    p_org_id_string47		IN varchar2 := NULL,
    p_org_id_string48		IN varchar2 := NULL,
    p_org_id_string49		IN varchar2 := NULL,
    p_org_id_string50		IN varchar2 := NULL,
    p_org_id_string51		IN varchar2 := NULL,
    p_org_id_string52		IN varchar2 := NULL,
    p_org_id_string53		IN varchar2 := NULL,
    p_org_id_string54		IN varchar2 := NULL,
    p_org_id_string55		IN varchar2 := NULL,
    p_org_id_string56		IN varchar2 := NULL,
    p_org_id_string57		IN varchar2 := NULL,
    p_org_id_string58		IN varchar2 := NULL,
    p_org_id_string59		IN varchar2 := NULL,
    p_org_id_string60		IN varchar2 := NULL,
    p_org_id_string61		IN varchar2 := NULL,
    p_org_id_string62		IN varchar2 := NULL,
    p_org_id_string63		IN varchar2 := NULL,
    p_org_id_string64		IN varchar2 := NULL,
    p_org_id_string65		IN varchar2 := NULL,
    p_org_id_string66		IN varchar2 := NULL,
    p_org_id_string67		IN varchar2 := NULL,
    p_org_id_string68		IN varchar2 := NULL,
    p_org_id_string69		IN varchar2 := NULL,
    p_org_id_string70		IN varchar2 := NULL,
    p_org_id_string71		IN varchar2 := NULL,
    p_org_id_string72		IN varchar2 := NULL,
    p_org_id_string73		IN varchar2 := NULL,
    p_org_id_string74		IN varchar2 := NULL,
    p_org_id_string75		IN varchar2 := NULL,
    p_org_id_string76		IN varchar2 := NULL,
    p_org_id_string77		IN varchar2 := NULL,
    p_org_id_string78		IN varchar2 := NULL,
    p_org_id_string79		IN varchar2 := NULL,
    p_org_id_string80		IN varchar2 := NULL,
    p_org_id_string81		IN varchar2 := NULL,
    p_org_id_string82		IN varchar2 := NULL,
    p_org_id_string83		IN varchar2 := NULL,
    p_org_id_string84		IN varchar2 := NULL,
    p_org_id_string85		IN varchar2 := NULL,
    p_org_id_string86		IN varchar2 := NULL,
    p_org_id_string87		IN varchar2 := NULL,
    p_org_id_string88		IN varchar2 := NULL,
    p_org_id_string89		IN varchar2 := NULL,
    p_org_id_string90		IN varchar2 := NULL,
    p_org_id_string91		IN varchar2 := NULL,
    p_org_id_string92		IN varchar2 := NULL
)
IS
TYPE VARCHAR_TABLETYPE IS TABLE OF VARCHAR2(32000);
p_org_ids     VARCHAR_TABLETYPE;

conc_status     boolean;
l_return_status	varchar2(1);
l_msg_count	    number;
l_msg_data	    varchar2(4000);

cursor c_processes (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

type t_tn is table of number;

x_ptbl t_tn;
l_org_string varchar2(32000) := null;
l_sql_string varchar2(32000);

TYPE t_proc_cur_type IS REF CURSOR;
l_proc_cur    t_proc_cur_type;

TYPE t_org_cur IS REF CURSOR;
l_org_cur t_org_cur;

type t_audit_unit_rec is record (organization_id  amw_audit_units_v.organization_id%type,
                         	   org_name  amw_audit_units_v.name%type);

type t_audit_units_tbl is table of t_audit_unit_rec;
l_audit_units_tbl t_audit_units_tbl;


l_org_id NUMBER;

type t_org_proc_rec is record (organization_id  amw_process_organization.organization_id%type,
                         		process_id amw_process_organization.process_id%type);

type t_org_proc_tbl is table of t_org_proc_rec;
l_org_proc_tbl t_org_proc_tbl;


l_orgs_tbl t_tn;
l_procs_tbl t_tn;
show_warning boolean := false;


BEGIN
	IF to_number(p_process_id) = -1 OR to_number(p_process_id) = -2 then
		conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: Cannot Associate Root Process');
        return;
	end if;
	retcode     := 0;
	errbuf      := '';
    conc_status := TRUE;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_CONC_REQUEST.Begin','BEGIN');
    end if;
    p_org_ids:=VARCHAR_TABLETYPE(
               p_org_id_string1,p_org_id_string2,p_org_id_string3,p_org_id_string4,
               p_org_id_string5,p_org_id_string6,p_org_id_string7,p_org_id_string8,
               p_org_id_string9,p_org_id_string10,p_org_id_string11,p_org_id_string12,
               p_org_id_string13,p_org_id_string14,p_org_id_string15,p_org_id_string16,
               p_org_id_string17,p_org_id_string18,p_org_id_string19,p_org_id_string20,
               p_org_id_string21,p_org_id_string22,p_org_id_string23,p_org_id_string24,
               p_org_id_string25,p_org_id_string26,p_org_id_string27,p_org_id_string28,
               p_org_id_string29,p_org_id_string30,p_org_id_string31,p_org_id_string32,
               p_org_id_string33,p_org_id_string34,p_org_id_string35,p_org_id_string36,
               p_org_id_string37,p_org_id_string38,p_org_id_string39,p_org_id_string40,
               p_org_id_string41,p_org_id_string42,p_org_id_string43,p_org_id_string44,
               p_org_id_string45,p_org_id_string46,p_org_id_string47,p_org_id_string48,
               p_org_id_string49,p_org_id_string50,p_org_id_string51,p_org_id_string52,
               p_org_id_string53,p_org_id_string54,p_org_id_string55,p_org_id_string56,
               p_org_id_string57,p_org_id_string58,p_org_id_string59,p_org_id_string60,
               p_org_id_string61,p_org_id_string62,p_org_id_string63,p_org_id_string64,
               p_org_id_string65,p_org_id_string66,p_org_id_string67,p_org_id_string68,
               p_org_id_string69,p_org_id_string70,p_org_id_string71,p_org_id_string72,
               p_org_id_string73,p_org_id_string74,p_org_id_string75,p_org_id_string76,
               p_org_id_string77,p_org_id_string78,p_org_id_string79,p_org_id_string80,
               p_org_id_string81,p_org_id_string82,p_org_id_string83,p_org_id_string84,
               p_org_id_string85,p_org_id_string86,p_org_id_string87,p_org_id_string88,
               p_org_id_string89,p_org_id_string90,p_org_id_string91,p_org_id_string92);

    FOR k IN 1..TO_NUMBER(p_org_id_count) LOOP
    	l_org_string := l_org_string || p_org_ids(k);
	END LOOP;
	l_sql_string  := 'select organization_id, name  from amw_audit_units_v where  organization_id in ( ' ||
								   replace(rtrim(l_org_string,'x'),'x',',') || ')';
	open l_org_cur for l_sql_string;
	fetch l_org_cur bulk collect into l_audit_units_tbl;
	close l_org_cur;
	if l_audit_units_tbl.exists(1)  then
    FOR orgid IN l_audit_units_tbl.first .. l_audit_units_tbl.last loop
--    	fnd_file.put_line(fnd_file.LOG, 'Associating to ' || l_audit_units_tbl(orgid).org_name  );
     	push_proc_per_org(
            p_parent_orgprocess_id	=> p_parent_orgprocess_id,
			p_process_id		=> p_process_id,
			p_org_id			=> l_audit_units_tbl(orgid).organization_id,
			p_mode				=> p_mode,
			p_apply_rcm			=> p_apply_rcm,
			p_synchronize		=> p_synchronize,
			p_update_count		=> FND_API.G_FALSE,
			p_commit            => FND_API.G_FALSE,
			x_return_status		=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data);

           	IF l_return_status <> 'S' THEN
           	  show_warning := true;
		      fnd_file.put_line(fnd_file.LOG, 'Error when Associating the process to ' || l_audit_units_tbl(orgid).org_name  );
		      fnd_file.put_line(fnd_file.LOG, l_msg_data );
            ELSE
            -- If user wants the processes to be associated as approved, user should set this profile to Y.
            -- Note that to get the whole hierarchy approved, user needs to set the approval option to
            -- "approve everything down below". Else only the process id passed will be approved.
            -- Although this is not very user friendly, I cannot see an option, as I cannot change the
            -- approval option ad hoc for this association process. When user associates a process,
            -- may be some-subprocess down below is in pending approval status, and that should prevent
            -- modifying the approval option.
            -- Also note that the "Approval Required" parameter for the org will be overridden, if set to yes.
	       	IF fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' THEN
	       		BEGIN
                	AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(p_process_id, l_audit_units_tbl(orgid).organization_id);
                	AMW_PROC_ORG_APPROVAL_PKG.approve(p_process_id, l_audit_units_tbl(orgid).organization_id,FND_API.G_FALSE);
                EXCEPTION
                	WHEN OTHERS THEN
                		show_warning := true;
                		ROLLBACK;
                		-- Unapproved object associations exists exception may happen..catche them here..
                		FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
                		fnd_file.put_line(fnd_file.LOG, ' Error when Approving the process in organization ' ||l_audit_units_tbl(orgid).org_name  );
                		fnd_file.put_line(fnd_file.LOG, l_msg_data);
                END;
	       	END IF;
	       END IF;
	       -- Done associating...Commit here..
	       COMMIT;
 	END LOOP;
 	if show_warning then
 	  conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Process cannot be associated to some organizations');
    end if;

    /* This block is to update the latest and approved risk control counts..*/
    l_sql_string  := 'select organization_id, process_id  from amw_process_organization where revision_number = 1' ||
    							  ' and process_id <> -2  and organization_id in ( ' ||
								   replace(rtrim(l_org_string,'x'),'x',',') || ')';
	open l_proc_cur for l_sql_string;
	fetch l_proc_cur bulk collect into l_org_proc_tbl;
	close l_proc_cur;

	-- Update the latest risk and control counts
	if l_org_proc_tbl.exists(1) then
		l_orgs_tbl :=  t_tn();
		l_procs_tbl := t_tn();
		for ctr in l_org_proc_tbl.first .. l_org_proc_tbl.last loop
			l_orgs_tbl.extend();
			l_procs_tbl.extend();
			l_orgs_tbl(l_orgs_tbl.last) := l_org_proc_tbl(ctr).organization_id;
			l_procs_tbl(l_procs_tbl.last) := l_org_proc_tbl(ctr).process_id;
		end loop;

		forall ctr in l_orgs_tbl.first .. l_orgs_tbl.last
		update amw_process_organization
        set risk_count_latest = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 = l_orgs_tbl(ctr)
                            and pk2 in (select alh.child_id
					from amw_latest_hierarchies alh
					start with alh.child_id = l_procs_tbl(ctr) and alh.organization_id = l_orgs_tbl(ctr)
					connect by prior alh.child_id = alh.parent_id and alh.organization_id = l_orgs_tbl(ctr)
					)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = l_procs_tbl(ctr)
                            and organization_id = l_orgs_tbl(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L' ) union (select l_procs_tbl(ctr) from dual)
                            )
*/
                            and deletion_date is null
                            and object_type = 'PROCESS_ORG'
                            ) ),
            control_count_latest = (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 = l_orgs_tbl(ctr)
                            and pk2 in (select alh.child_id
					from amw_latest_hierarchies alh
					start with alh.child_id = l_procs_tbl(ctr) and alh.organization_id = l_orgs_tbl(ctr)
					connect by prior alh.child_id = alh.parent_id and alh.organization_id = l_orgs_tbl(ctr)
					)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
														( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = l_procs_tbl(ctr)
                            and organization_id = l_orgs_tbl(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L' ) union (select l_procs_tbl(ctr) from dual)
                            )
*/
                            and deletion_date is null
                            and object_type = 'RISK_ORG'
                            ) )
              ,last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where end_date is null
        and process_id <> -2
        and organization_id = l_orgs_tbl(ctr)
        and process_id = l_procs_tbl(ctr);


        if fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' then


        forall ctr in l_orgs_tbl.first .. l_orgs_tbl.last
        update amw_process_organization
        set risk_count = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 = l_orgs_tbl(ctr)
                            and pk2 in (  select alh.child_id
                                          from  amw_approved_hierarchies alh
																					start with alh.child_id = l_procs_tbl(ctr) and alh.organization_id = l_orgs_tbl(ctr)
                                              and alh.start_date is not null and alh.end_date is null
																					connect by prior alh.child_id = alh.parent_id and alh.organization_id = l_orgs_tbl(ctr)
										      										and alh.start_date is not null and alh.end_date is null
							             							)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = l_procs_tbl(ctr)
                            and organization_id = l_orgs_tbl(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A' ) union (select l_procs_tbl(ctr) from dual)
                            )
*/
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'PROCESS_ORG'
                            ) ),
             control_count= (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 = l_orgs_tbl(ctr)
                            and pk2 in (  select alh.child_id
                                          from  amw_approved_hierarchies alh
																					start with alh.child_id = l_procs_tbl(ctr) and alh.organization_id = l_orgs_tbl(ctr)
                                              and alh.start_date is not null and alh.end_date is null
																					connect by prior alh.child_id = alh.parent_id and alh.organization_id = l_orgs_tbl(ctr)
										      										and alh.start_date is not null and alh.end_date is null
							             							)
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                            ( ( select parent_child_id
                            from amw_org_hierarchy_denorm
                            where process_id = l_procs_tbl(ctr)
                            and organization_id = l_orgs_tbl(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A' ) union (select l_procs_tbl(ctr) from dual)
                            )
*/
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'RISK_ORG'
                            ) )
              ,last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
        where approval_date is not null
        and approval_end_date is null
        and process_id <> -2
        and organization_id = l_orgs_tbl(ctr)
        and process_id = l_procs_tbl(ctr);
      end if;

	end if;

  	open c_processes(TO_NUMBER(p_process_id));
  	fetch c_processes bulk collect into x_ptbl;
  	close c_processes;
  	if(x_ptbl.exists(1)) then
  	forall i in x_ptbl.first .. x_ptbl.last
  		update amw_process
  		set org_count = (select count(*) from
                (select distinct organization_id
                from amw_process_organization
                where process_id = x_ptbl(i)
                and end_date is null
                and (deletion_date is null or (deletion_date is not null and approval_date is null)))),
    	object_version_number = object_version_number + 1
    	,last_update_date = sysdate
    	,last_updated_by = G_USER_ID
    	,last_update_login = G_LOGIN_ID
		where approval_date is not null
		and approval_end_date is null
		and process_id <> -1  --retained for safety
		and process_id = x_ptbl(i);
	end if;

    COMMIT;
    end if;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_ORG_CONC_REQUEST.End','END');
    end if;
EXCEPTION
     WHEN others THEN
		retcode :=2;
		errbuf :=SUBSTR(SQLERRM,1,1000);
		conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
END push_proc_org_Conc_Request;

-- ****************************************************************************

procedure push_proc_org(
p_parent_orgprocess_id	in number,
p_process_id			in number,
p_org_id_string			in varchar2,
p_mode				    in varchar2,
p_apply_rcm			    in varchar2,
p_synchronize			in varchar2,
p_update_count		    in varchar2 := FND_API.G_TRUE,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 )

is


cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

L_API_NAME CONSTANT VARCHAR2(30) := 'push_proc_org';
l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
str              varchar2(4000);
diff		 number;
orgstr		 varchar2(100);
l_org_string     varchar2(4000);
orgid		 number;


begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


l_org_string := p_org_id_string;
while LENGTH(l_org_string) <> 0 loop
select LTRIM(l_org_string, '1234567890') into str from dual;
diff := LENGTH(l_org_string) - LENGTH(str);
if  LENGTH(str) is null then  diff := LENGTH(l_org_string); end if;
select SUBSTR(l_org_string, 1, diff) into orgstr from dual;
orgid := to_number(orgstr);

	push_proc_per_org(
            p_parent_orgprocess_id	=> p_parent_orgprocess_id,
			p_process_id		=> p_process_id,
			p_org_id			=> orgid,
			p_mode				=> p_mode,
			p_apply_rcm			=> p_apply_rcm,
			p_synchronize		=> p_synchronize,
			p_update_count     => p_update_count,
			p_commit            =>p_commit,
			x_return_status		=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data);

	if l_return_status <> 'S' then
		raise FND_API.G_EXC_ERROR;
	end if;



-- If user wants the processes to be associated as approved, user should set this profile to Y.
-- Note that to get the whole hierarchy approved, user needs to set the approval option to
-- "approve everything down below". Else only the process id passed will be approved.
-- Although this is not very user friendly, I cannot see an option, as I cannot change the
-- approval option ad hoc for this association process. When user associates a process,
-- may be some-subprocess down below is in pending approval status, and that should prevent
-- modifying the approval option.
-- Also note that the "Approval Required" parameter for the org will be overridden, if set to yes.
	if fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' then
		AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(p_process_id, orgid);
		AMW_PROC_ORG_APPROVAL_PKG.approve(p_process_id, orgid,p_update_count);
	end if;


select LTRIM(str, 'x') into l_org_string from dual;
end loop;

IF (p_update_count = FND_API.G_TRUE) THEN
	-- update the org counts of the child process and its hierarchy....
	for descendents_rec in c1(p_process_id) loop
     		exit when c1%notfound;
      		amw_rl_hierarchy_pkg.update_org_count(descendents_rec.process_to_count);
 	end loop;
END IF;

  IF (p_commit = FND_API.G_TRUE) then
    commit;
  END IF;

exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end push_proc_org;



procedure push_proc_per_org(
p_parent_orgprocess_id	in number,
p_process_id			in number,
p_org_id			in number,
p_mode				in varchar2,
p_apply_rcm			in varchar2,
p_synchronize			in varchar2,
p_update_count		    in varchar2 := FND_API.G_TRUE,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2 )

is

L_API_NAME CONSTANT VARCHAR2(30) := 'push_proc_per_org';
l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;

begin
  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_PER_ORG.Begin',
        'OrgId:' ||p_org_id || ';ProcessId:'||p_process_id
        ||';ParentProcessId:'||p_parent_orgprocess_id||';reviseExisting:'||p_synchronize||';ApplyRCM:'||p_apply_rcm);
  end if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_PER_ORG.associate_process_to_org',
        'OrgId:' ||p_org_id || ';p_associated_proc_id:'||p_process_id
        ||';ParentProcessId:'||p_parent_orgprocess_id||';reviseExisting:'||p_synchronize||';ApplyRCM:'||p_apply_rcm);
  end if;

  associate_process_to_org (
	p_org_id => p_org_id,
	p_parent_process_id => p_parent_orgprocess_id,
	p_associated_proc_id => p_process_id,
	p_revise_existing => p_synchronize,
    p_apply_rcm => p_apply_rcm);


-- ko Though We can determine whether to update all the counts / or simply set to zero depending on th eapply_rcm parameter.
-- ko for the time being updating for all the processes in the organization..
--ko we need to come up an efficient count algorithm to  update the counts in downward direction also..
--Ko Update the Proc_org_hierarchy_denorm tables..
--ko  removing amw_org_hierarchy_denorm usage...
/*
  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_PER_ORG.update_denorm',
        'Begin update denrom; OrgId:' ||p_org_id );
  end if;
  AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_org_id);
*/
  IF p_update_count = FND_API.G_TRUE THEN
  -- ko update the risk1 counts of the child process..
  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_PER_ORG.update_counts',
        'Begin update counts; OrgId:' ||p_org_id );
  end if;
  upd_ltst_risk_count(p_org_id => p_org_id, p_process_id => null);


  upd_ltst_control_count(p_org_id => p_org_id, p_process_id => null);
  END IF;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

  if( l_log_stmt_level >= l_curr_log_level ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.PUSH_PROC_PER_ORG.End',
        'End');
  end if;

exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end push_proc_per_org;

-- **********************************************************************************************************

/*kosriniv..... Procedure to add a process in the organization under a parent process..
 * p_organization_id  ---> Organization Id
 * p_parent_id        ---> parent process Id to which the child is being added
 * p_child_id         ---> process being associated
 * p_add_from         ---> identifies to add the existing process from org or new from RL
			'O' ... Add from Organization
			'R' ... Add from Risk Library
 * p_revise_existing  ---> if adding from Risk Library whether to keep the existing process or sync it
			'Y' ... Revise / 'N'... use existing
 * p_apply_rcm        ---> if adding from Risk Library whether to apply the RCM of the process in Org or NOt
	'RDEF'		  - Retain Definition in the organization.. Do not make any changes to Risks, controls and Audit Procedures.
	'SLIB' 		  - Synchronize with the library definition .. Risks, Controls and Audit Procedures list equal to the RL
	'ARCM'		  - Add Risks and Controls and Audit Procedures that exists in RL but not in Org.
*/

PROCEDURE add_organization_child
( p_organization_id	    IN NUMBER,
  p_child_id                IN NUMBER,
  P_parent_id		    IN NUMBER,
  P_add_from 		    IN VARCHAR2,
  p_revise_existing	    IN VARCHAR2,
  P_apply_rcm	            IN VARCHAR2,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)

IS

cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

L_API_NAME CONSTANT VARCHAR2(30) := 'Add_organization_child';
l_dummy NUMBER;

begin

--always initialize global variables in th api's used from SelfSerivice Fwk..
  G_USER_ID := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Make sure latest revision of parent is existing in the organization..

  SELECT 1 INTO l_dummy
  FROM amw_process_organization
  where process_id = p_parent_id
  and organization_id = p_organization_id
  and end_date is null
  and deletion_date is null;

  IF p_add_from = 'O'  THEN -- Add an existing process from organization
	-- Check that parent can be updated..(Not in pA or in locked state..)
	produce_err_if_pa_or_locked(p_org_id => p_organization_id,p_process_id => p_parent_id);
        -- Parent can be updated...Add the child and parent... Circular hierarchy check is taken care in the procedure.
       -- Make sure latest revision of child exists in the organization
       	SELECT 1 INTO l_dummy
        FROM amw_process_organization
        where process_id = p_child_id
        and organization_id = p_organization_id
        and end_date is null
  	and deletion_date is null;

	BEGIN
	 -- dO not add if the relation ship already exists in the latest hierarchy
	 SELECT 1 INTo l_dummy
	 from amw_latest_hierarchies
	 where organization_id = p_organization_id
	 and parent_id = p_parent_id
	 and child_id = p_child_id;

	EXCEPTION
		WHEN no_data_found THEN

 		 add_delete_ex_child (
			p_org_id => p_organization_id,
			p_parent_process_id => p_parent_id,
			p_child_process_id => p_child_id,
			p_action => 'ADD');

--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
		-- Update the Proc_org_hierarchy_denorm tables..


		AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_organization_id);
*/
		-- update the risk 1 counts of the parent process ..
		upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => p_parent_id);

		upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => p_parent_id);
	END;

  ELSIF p_add_from = 'R' THEN  -- Add the process from Risk library... Note that entire child hirarchy should be moved in to..


  --  Make sure that  the process not existing in the org.
  	BEGIN
		SELECT 1 INTO l_dummy
  		FROM amw_process_organization
		where process_id = p_child_id
		and organization_id = p_organization_id
  		and end_date is null
	  	and deletion_date is null;

	  EXCEPTION
	  	WHEN no_data_found THEN
			associate_process_to_org (
			p_org_id => p_organization_id,
			p_parent_process_id => p_parent_id,
			p_associated_proc_id => p_child_id,
			p_revise_existing => p_revise_existing,
			p_apply_rcm => p_apply_rcm);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
			-- Update the Proc_org_hierarchy_denorm tables..
			AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_organization_id);
*/
			-- update the risk1 counts of the child process..
			upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => null);

			upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => null);

			-- update the org counts of the child process and its hierarchy....
			for descendents_rec in c1(p_child_id) loop
    	  		exit when c1%notfound;
    	  		amw_rl_hierarchy_pkg.update_org_count(descendents_rec.process_to_count);
 			end loop;
	END;

 END IF;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END add_organization_child;

-- **********************************************************************************************************

/*kosriniv..... Procedure to delete a process in the organization from a parent process..
 * p_organization_id  ---> Organization Id
 * p_parent_id        ---> parent process Id to which the child is being added
 * p_child_id         ---> process being associated
*/

PROCEDURE delete_organization_child
( p_organization_id	    IN NUMBER,
  p_child_id                IN NUMBER,
  P_parent_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)

IS

L_API_NAME CONSTANT VARCHAR2(30) := 'delete_organization_child';
l_dummy NUMBER;

begin

--always initialize global variables in th api's used from SelfSerivice Fwk..
  G_USER_ID := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Make sure latest revision of parent is existing in the organization..

  SELECT 1 INTO l_dummy
  FROM amw_process_organization
  where process_id = p_parent_id
  and organization_id = p_organization_id
  and end_date is null
  and deletion_date is null;

-- Check that parent can be updated..(Not in pA or in locked state..)

  produce_err_if_pa_or_locked(p_org_id => p_organization_id,p_process_id => p_parent_id);

-- Parent can be updated...Add the child and parent... Circular hierarchy check is taken care in the procedure.

-- Make sure latest revision of child exists in the organization

   SELECT 1 INTO l_dummy
   FROM amw_process_organization
   where process_id = p_child_id
   and organization_id = p_organization_id
   and end_date is null
   and deletion_date is null;


   add_delete_ex_child (
	p_org_id => p_organization_id,
	p_parent_process_id => p_parent_id,
	p_child_process_id => p_child_id,
	p_action => 'DEL');

--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   -- Update the Proc_org_hierarchy_denorm tables..

   AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_organization_id);
*/
   -- update the risk 1 counts of the parent process ..
   upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => p_parent_id);

   upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => p_parent_id);

   -- update the org counts of the child process and its hierarchy....
  -- Need to be updated only after the process added to/deleted from approved hierarchy...

   -- Need to write a procedure for update the counts for all the child processes....



exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END delete_organization_child;

--============================================================================================================================================

PROCEDURE disassociate_org_process
( p_organization_id	    IN NUMBER,
  p_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'disassociate_org_process';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Disassociation functionality is to delete the process as a child and  mark the process as deleted
  disassociate_process_org(p_org_id => p_organization_id,p_process_id => p_process_id);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
  -- Update the Proc_org_hierarchy_denorm tables..

   AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_organization_id);
*/

  upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => NULL);

  upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => NULL);

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END disassociate_org_process;


--============================================================================================================================================

PROCEDURE synchronize_org_process
( p_org_id   in number,
  p_process_id  in number,
  p_sync_mode in varchar2,
  p_sync_hierarchy in varchar2,
  p_sync_attributes in varchar2,
  p_sync_rcm in varchar2,
  p_sync_people in varchar2,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  cursor c1 (pid number) is
     select parent_child_id process_to_count
     from amw_proc_hierarchy_denorm
     where process_id = pid
     and up_down_ind = 'D'
     and hierarchy_type = 'A';

  L_API_NAME CONSTANT VARCHAR2(30) := 'synchronize_org_process';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- do the basic validation..i.e. the process can not be locked state..

  produce_err_if_pa_or_locked(p_org_id => p_org_id,p_process_id => p_process_id);

-- So process is not in locked state.. Can be disassociated from  organization..

-- Check whether the synchronization of the process is clicked or not..

	synchronize_process(p_org_id      => p_org_id,
                        p_process_id  => p_process_id,
                        p_sync_mode   => p_sync_mode,
						p_sync_hierarchy =>p_sync_hierarchy,
                        p_sync_attributes => p_sync_attributes,
                        p_sync_rcm => p_sync_rcm,
                        p_sync_people => p_sync_people );
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
      -- Synchronized the hierarchy...So update the hierarchy denorm tables.
   AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_org_id);
*/
   upd_ltst_risk_count(p_org_id => p_org_id, p_process_id => NULL);

   upd_ltst_control_count(p_org_id => p_org_id, p_process_id => NULL);

   -- update the org counts of the child process and its hierarchy....
	for descendents_rec in c1(p_process_id) loop
    	exit when c1%notfound;
    	amw_rl_hierarchy_pkg.update_org_count(descendents_rec.process_to_count);
 	end loop;



exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END synchronize_org_process;


--============================================================================================================================================

PROCEDURE update_latest_rc_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'update_latest_rc_counts';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Update the Risk Counts..
    upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => p_process_id);
-- Update the Control Counts..
    upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => p_process_id);


exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END update_latest_rc_counts;

--============================================================================================================================================

PROCEDURE update_approved_rc_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'update_approved_rc_counts';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Update the Risk Counts..
    upd_appr_risk_count(p_org_id => p_organization_id, p_process_id => p_process_id);
-- Update the Control Counts..
    upd_appr_control_count(p_org_id => p_organization_id, p_process_id => p_process_id);


exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END update_approved_rc_counts;


-- ===============================================================================================================================================================================
PROCEDURE insert_exception_justification (
p_exception_Id		IN Number,
p_justification	        IN Varchar2,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2
)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'insert_exception_justification';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- insert the justification rows.
    insert into amw_exceptions_tl
		 (
                  EXCEPTION_ID,
                  LANGUAGE,
                  SOURCE_LANG,
                  JUSTIFICATION,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN
                  )
                  select
                 	p_Exception_Id,
                 	L.LANGUAGE_CODE,
                 	userenv('LANG'),
                 	p_Justification,
                 	sysdate,
                 	G_USER_ID,
                 	sysdate,
                 	G_USER_ID,
                 	G_LOGIN_ID
			from FND_LANGUAGES L
                 	where L.INSTALLED_FLAG in ('I', 'B')
                 	and not exists
                 		(select NULL
                 		 from AMW_EXCEPTIONS_TL T
                 		 where T.EXCEPTION_ID = p_Exception_Id
                 		 and T.LANGUAGE = L.LANGUAGE_CODE);


exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END insert_exception_justification;

-- ===============================================================================================================================================================================
function areChildListSame(p_organization_id	    IN NUMBER,p_process_id in number) return varchar is
retvalue varchar2(1);
l_dummy number;
begin

retvalue := 'N';

        begin
           select child_id
           into l_dummy
           from amw_approved_hierarchies
           where parent_id = p_process_id
           and organization_id = p_organization_id
           and (end_date is null or end_date > sysdate)
           and child_id not in
              (select child_id
              from amw_latest_hierarchies
              where parent_id = p_process_id
              and organization_id = p_organization_id);
       exception
            when no_data_found then
                begin
                   select child_id
                   into l_dummy
                   from amw_latest_hierarchies
                   where parent_id = p_process_id
                   and organization_id = p_organization_id
                   and child_id not in
                       (select child_id
                       from amw_approved_hierarchies
                       where parent_id = p_process_id
                       and organization_id = p_organization_id
                       and (end_date is null or end_date > sysdate));
                exception
                    when too_many_rows then
                        return retvalue;
                    when no_data_found then
                        retvalue := 'Y';
                        return retvalue;
                end;
            when too_many_rows then
                return retvalue;
        end;
return retvalue;
end;
-- ===============================================================================================================================================================================
function does_apprvd_ver_exst(p_organization_id in number,p_process_id in number) return varchar is
l_dummy number;
begin
    select 1
    into l_dummy
    from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_organization_id
    and approval_status = 'A';

    return 'Y';

exception
    when no_data_found then
        return 'N';
    when too_many_rows then
        return 'Y';
end does_apprvd_ver_exst;

-- ===============================================================================================================================================================================
-- this api is to be called from java to figure out if the process
-- is undoable or not. Based on this, the Undo buutton should
-- be rendered
procedure isProcessUndoAble (p_organization_id in number,
                			p_process_id in number,
                			ret_value out nocopy varchar2,
	                                x_return_status out nocopy varchar2,
                                        x_msg_count out nocopy number,
                                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'isProcessUndoAble';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);
l_dummy number;
appstatus varchar2(10);

begin
--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

ret_value := 'N';

-- check if the process is draft

select approval_status into appstatus
from amw_process_organization
where process_id = p_process_id
and organization_id = p_organization_id
and end_date is null;

if appstatus <> 'D' then
	return;
end if;

-- check if the draft has been created due to addition/deletion of children

if areChildListSame(p_organization_id,p_process_id) = 'Y' then
	ret_value := 'Y';
	return;
else
	return;
end if;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;

-- ===============================================================================================================================================================================
-- call this only after calling isProcessUndoAble.
-- This api performs the delete (purging of draft row) action
-- if conditions are satisfied
procedure delete_draft (p_organization_id in number,
                        p_process_id in number,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'delete_draft';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);
appexst varchar2(1);
l_risk_exists boolean :=false;
l_control_exists boolean :=false;
cursor parents(orgId NUMBER, pid number) is
             select parent_id
             from amw_latest_hierarchies
             where child_id = pid
             and organization_id = orgId ;

parent_rec parents%rowtype;
l_flag varchar2(10);
previd number;
l_dummy number;
ret_val varchar2(10);

begin
--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

select process_org_rev_id
    into previd from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_organization_id
    and end_date is null;

appexst := does_apprvd_ver_exst(p_organization_id,p_process_id);


if appexst = 'Y' then

    -- do another check for undoablity

         isProcessUndoAble (	p_organization_id => p_organization_id ,
                                        p_process_id => p_process_id,
                			ret_value => ret_val,
	                            x_return_status => x_return_status,
	                            x_msg_count => x_msg_count,
	                            x_msg_data => x_msg_data);

	     if ret_val <> 'Y' then
            fnd_message.set_name('AMW','AMW_CANT_UNDO_DRAFT');
            err_msg := fnd_message.get;
            fnd_msg_pub.add_exc_msg(p_pkg_name  => 'amw_ORG_hierarchy_pkg',
                       	            p_procedure_name => 'delete_draft',
                                    p_error_text => err_msg);
            raise FND_API.G_EXC_ERROR;
	     end if;
         if  x_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;




    delete from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_organization_id
    and end_date is null;


    update amw_process_organization
    set end_date = null
    where process_id = p_process_id
    and organization_id = p_organization_id
    and approval_date is not null
    and approval_end_date is null;

    -- If the previous version is deleted; then we make it deleted...
    begin
    	select 1 into l_dummy
    	from amw_process_organization
    	where process_id = p_process_id
    	and organization_id = p_organization_id
    	and deletion_date is not null
    	and end_date is null;

    	-- So  process is deleted..so remove the process from hierarchy
    	for parent_rec in parents(p_organization_id,p_process_id) loop
    	  exit when parents%notfound;
    	  revise_process_if_necessary(p_organization_id,parent_rec.parent_id);
    	  delete from amw_latest_hierarchies
    	  where parent_id = parent_rec.parent_id
    	  and child_id = p_process_id
    	  and organization_id = p_organization_id;
 	    end loop;

    	delete from amw_latest_hierarchies
    	where parent_id = p_process_id
    	and organization_id = p_organization_id;
	exception
		when no_data_found then
			null;
	end;



else -- appexst = 'N'

    for parent_rec in parents(p_organization_id,p_process_id) loop
    	  exit when parents%notfound;
    	  revise_process_if_necessary(p_organization_id,parent_rec.parent_id);
    	  delete from amw_latest_hierarchies
    	  where parent_id = parent_rec.parent_id
    	  and child_id = p_process_id
    	  and organization_id = p_organization_id;
 	end loop;

    delete from amw_latest_hierarchies
    where parent_id = p_process_id
    and organization_id = p_organization_id;
    delete from amw_process_organization where process_id = p_process_id and organization_id = p_organization_id;

end if;

-- perform other common delete operations

delete from amw_risk_associations
where pk1 = p_organization_id
and pk2 = p_process_id
and approval_date is null
and object_type = 'PROCESS_ORG';
IF SQL%FOUND THEN
l_risk_exists := TRUE;
END IF;
update amw_risk_associations
set deletion_date = null
where pk1 = p_organization_id
and pk2 = p_process_id
and object_type = 'PROCESS_ORG'
and deletion_date is not null
and deletion_approval_date is null;
IF SQL%FOUND THEN
l_risk_exists := TRUE;
END IF;


delete from amw_control_associations
where pk1 = p_organization_id
and pk2 = p_process_id
and approval_date is null
and object_type = 'RISK_ORG';
IF SQL%FOUND THEN
l_control_exists := TRUE;
END IF;

update amw_control_associations
set deletion_date = null
where pk1 = p_organization_id
and pk2 = p_process_id
and object_type = 'RISK_ORG'
and deletion_date is not null
and deletion_approval_date is null;
IF SQL%FOUND THEN
l_control_exists := TRUE;
END IF;


delete from amw_acct_associations
where pk1 = p_organization_id
and pk2 = p_process_id
and approval_date is null
and object_type = 'PROCESS_ORG';

update amw_acct_associations
set deletion_date = null
where pk1 = p_organization_id
and pk2 = p_process_id
and object_type = 'PROCESS_ORG'
and deletion_date is not null
and deletion_approval_date is null;


delete from amw_objective_associations
where pk1 = p_organization_id
and pk2 = p_process_id
and approval_date is null
and object_type in ('PROCESS_ORG', 'CONTROL_ORG');

update amw_objective_associations
set deletion_date = null
where pk1 = p_organization_id
and pk2 = p_process_id
and object_type in ('PROCESS_ORG', 'CONTROL_ORG')
and deletion_date is not null
and deletion_approval_date is null;

delete from amw_ap_associations
where pk1 = p_organization_id
and   pk2 = p_process_id
and association_creation_date is null
and   object_type = 'CTRL_ORG';


FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => 'AMW_PROCESS_ORGANIZATION',
                                               X_pk1_value   => previd);

-- cancel existing change requests
-- update org count..
amw_rl_hierarchy_pkg.update_org_count(p_process_id);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
-- update latest hierarchy denorm
amw_rl_hierarchy_pkg.update_denorm (p_organization_id, sysdate);
*/
if appexst = 'Y' AND l_risk_exists then

-- Update the latest risk control counts..
upd_ltst_risk_count(p_organization_id,p_process_id);


end if;

if appexst = 'Y' AND l_control_exists then

-- Update the latest risk control counts..
upd_ltst_control_count(p_organization_id,p_process_id);

end if;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;

--==============================================================================================================
-- Bring the AuditProcedures for newly added controls in the risklibrary to organization controls
procedure UPDATE_ORG_PROC_AP(p_organization_id	    IN NUMBER,
                        p_process_id in number,
                        p_date in DATE,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'UPDATE_ORG_PROC_AP';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);

begin
--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


	insert into amw_ap_associations
    (AP_ASSOCIATION_ID,
    AUDIT_PROCEDURE_ID,
    PK1,
    PK2,
    PK3,
    DESIGN_EFFECTIVENESS,
    OP_EFFECTIVENESS,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_AP_ASSOCIATIONS_S.nextval,
    APA.AUDIT_PROCEDURE_ID,
    p_organization_id,
    p_process_id,
    CONTROLS.control_id,
    APA.DESIGN_EFFECTIVENESS,
    APA.OP_EFFECTIVENESS,
    null,
    null,
    null,
    null,
    'CTRL_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
	from
	amw_ap_associations APA,
	(SELECT distinct control_id from
	amw_control_associations
	where object_type = 'RISK_ORG'
	AND PK1 = p_organization_id
	AND PK2 = p_process_id
	AND association_creation_date = p_date
	AND approval_date is null) CONTROLS
	where APA.object_type = 'CTRL'
	and APA.pk1 = CONTROLS.control_id
	and APA.approval_date is not null
	and APA.deletion_approval_date is null
	and APA.audit_procedure_id not in ( select audit_procedure_id from amw_ap_associations
                                where object_type = 'CTRL_ORG'
                                and pk1 = p_organization_id
                                and pk2 = p_process_id
                                and pk3 =  CONTROLS.control_id
                                and deletion_date is null));


DELETE FROM AMW_AP_ASSOCIATIONS
WHERE object_type = 'CTRL_ORG'
and pk1 = p_organization_id
and pk2 = p_process_id
and association_creation_date is null
and pk3 not in ( SELECT control_id from
                 amw_control_associations
                 where object_type = 'RISK_ORG'
                 AND PK1 = p_organization_id
                 AND PK2 = p_process_id
                 AND approval_date is null);

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;

--==============================================================================================================
-- Bring the AuditProcedures for newly added controls in the risklibrary to organization controls
procedure UPDATE_ENTITY_AP(p_organization_id	    IN NUMBER,
                        p_date in DATE,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'UPDATE_ENTITY_AP';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);

begin
--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


    insert into amw_ap_associations
    (AP_ASSOCIATION_ID,
    AUDIT_PROCEDURE_ID,
    PK1,
    PK2,
    DESIGN_EFFECTIVENESS,
    OP_EFFECTIVENESS,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_AP_ASSOCIATIONS_S.nextval,
    APA.AUDIT_PROCEDURE_ID,
    p_organization_id,
    CONTROLS.control_id,
    APA.DESIGN_EFFECTIVENESS,
    APA.OP_EFFECTIVENESS,
    sysdate,
    null,
    null,
    null,
    'ENTITY_AP',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
	from
	amw_ap_associations APA,
	(SELECT distinct control_id from
	amw_control_associations
	where object_type = 'ENTITY_CONTROL'
	AND PK1 = p_organization_id
	AND association_creation_date = p_date	) CONTROLS
	where APA.object_type = 'CTRL'
	and APA.pk1 = CONTROLS.control_id
	and APA.approval_date is not null
	and APA.deletion_approval_date is null
	and APA.audit_procedure_id not in ( select audit_procedure_id from amw_ap_associations
                                where object_type = 'ENTITY_AP'
                                and pk1 = p_organization_id
                                and pk2 = CONTROLS.control_id)
    );


DELETE FROM AMW_AP_ASSOCIATIONS
WHERE object_type = 'ENTITY_AP'
and pk1 = p_organization_id
and pk2 not in ( SELECT control_id from
                 amw_control_associations
                 where object_type = 'ENTITY_CONTROL'
                 AND PK1 = p_organization_id
                 );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;


procedure sync_process_attributes(p_org_id   in number,
								  p_process_id  in number
								 ) is


l_RL_PROCESS_REV_ID               amw_process.PROCESS_REV_ID%type;
l_SIGNIFICANT_PROCESS_FLAG	      amw_process.SIGNIFICANT_PROCESS_FLAG%type;
l_STANDARD_PROCESS_FLAG 	      amw_process.STANDARD_PROCESS_FLAG%type;
l_PROCESS_CATEGORY    		      amw_process.PROCESS_CATEGORY%type;
l_STANDARD_VARIATION      	      amw_process.STANDARD_VARIATION%type;
l_ATTRIBUTE_CATEGORY      	      amw_process.ATTRIBUTE_CATEGORY%type;
l_ATTRIBUTE1              	      amw_process.ATTRIBUTE1%type;
l_ATTRIBUTE2              	      amw_process.ATTRIBUTE2%type;
l_ATTRIBUTE3              	      amw_process.ATTRIBUTE3%type;
l_ATTRIBUTE4              	      amw_process.ATTRIBUTE4%type;
l_ATTRIBUTE5              	      amw_process.ATTRIBUTE5%type;
l_ATTRIBUTE6              	      amw_process.ATTRIBUTE6%type;
l_ATTRIBUTE7              	      amw_process.ATTRIBUTE7%type;
l_ATTRIBUTE8              	      amw_process.ATTRIBUTE8%type;
l_ATTRIBUTE9              	      amw_process.ATTRIBUTE9%type;
l_ATTRIBUTE10             	      amw_process.ATTRIBUTE10%type;
l_ATTRIBUTE11             	      amw_process.ATTRIBUTE11%type;
l_ATTRIBUTE12             	      amw_process.ATTRIBUTE12%type;
l_ATTRIBUTE13             	      amw_process.ATTRIBUTE13%type;
l_ATTRIBUTE14             	      amw_process.ATTRIBUTE14%type;
l_ATTRIBUTE15             	      amw_process.ATTRIBUTE15%type;
l_SECURITY_GROUP_ID       	      amw_process.SECURITY_GROUP_ID%type;
l_PROCESS_TYPE            	      amw_process.PROCESS_TYPE%type;
l_CONTROL_ACTIVITY_TYPE		      amw_process.CONTROL_ACTIVITY_TYPE%type;


begin
  -- find out if the latest revision for target is approved or not.
  -- if approved, revise it. if draft, don't do anything
      revise_process_if_necessary(p_org_id, p_process_id);

  -- copy the attributes from rl to org
       select PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY,
			  STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1,
			  ATTRIBUTE2,
			  ATTRIBUTE3,
			  ATTRIBUTE4,
			  ATTRIBUTE5,
			  ATTRIBUTE6,
			  ATTRIBUTE7,
			  ATTRIBUTE8,
			  ATTRIBUTE9,
			  ATTRIBUTE10,
			  ATTRIBUTE11,
			  ATTRIBUTE12,
			  ATTRIBUTE13,
			  ATTRIBUTE14,
			  ATTRIBUTE15,
			  SECURITY_GROUP_ID,
			  PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE
              into
              l_RL_PROCESS_REV_ID,
			  l_SIGNIFICANT_PROCESS_FLAG,
			  l_STANDARD_PROCESS_FLAG,
			  l_PROCESS_CATEGORY,
			  l_STANDARD_VARIATION,
			  l_ATTRIBUTE_CATEGORY,
			  l_ATTRIBUTE1,
			  l_ATTRIBUTE2,
			  l_ATTRIBUTE3,
			  l_ATTRIBUTE4,
			  l_ATTRIBUTE5,
			  l_ATTRIBUTE6,
			  l_ATTRIBUTE7,
			  l_ATTRIBUTE8,
			  l_ATTRIBUTE9,
			  l_ATTRIBUTE10,
			  l_ATTRIBUTE11,
			  l_ATTRIBUTE12,
			  l_ATTRIBUTE13,
			  l_ATTRIBUTE14,
			  l_ATTRIBUTE15,
			  l_SECURITY_GROUP_ID,
			  l_PROCESS_TYPE,
			  l_CONTROL_ACTIVITY_TYPE
              from amw_process
              where process_id = p_process_id
--ko need to sync with approved revision
--              and end_date is null;
              and approval_date is not null
              and approval_end_date is null;



      update amw_process_organization
      set     RL_PROCESS_REV_ID             =   l_RL_PROCESS_REV_ID,
			  SIGNIFICANT_PROCESS_FLAG      =   l_SIGNIFICANT_PROCESS_FLAG,
			  STANDARD_PROCESS_FLAG	        =   l_STANDARD_PROCESS_FLAG,
			  PROCESS_CATEGORY_CODE	            =   l_PROCESS_CATEGORY,
			  STANDARD_VARIATION	        =   l_STANDARD_VARIATION,
			  ATTRIBUTE_CATEGORY            =   l_ATTRIBUTE_CATEGORY,
			  ATTRIBUTE1		    =   l_ATTRIBUTE1,
			  ATTRIBUTE2			=   l_ATTRIBUTE2,
			  ATTRIBUTE3			=   l_ATTRIBUTE3,
			  ATTRIBUTE4			=   l_ATTRIBUTE4,
			  ATTRIBUTE5			=   l_ATTRIBUTE5,
			  ATTRIBUTE6			=   l_ATTRIBUTE6,
			  ATTRIBUTE7			=   l_ATTRIBUTE7,
			  ATTRIBUTE8			=   l_ATTRIBUTE8,
			  ATTRIBUTE9			=   l_ATTRIBUTE9,
			  ATTRIBUTE10			=   l_ATTRIBUTE10,
			  ATTRIBUTE11			=   l_ATTRIBUTE11,
			  ATTRIBUTE12			=   l_ATTRIBUTE12,
			  ATTRIBUTE13			=   l_ATTRIBUTE13,
			  ATTRIBUTE14			=   l_ATTRIBUTE14,
			  ATTRIBUTE15			=   l_ATTRIBUTE15,
			  SECURITY_GROUP_ID		=   l_SECURITY_GROUP_ID,
			  PROCESS_TYPE			=   l_PROCESS_TYPE,
			  CONTROL_ACTIVITY_TYPE	=   l_CONTROL_ACTIVITY_TYPE
      where organization_id = p_org_id
      and process_id = p_process_id
      and end_date is null;

  -- apply process key accounts -- Delete the accounts that does not exists in the rl process...

 	--ko, delete all the unapproved rows
        delete amw_acct_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   approval_date is null;

    -- delete existing accounts that are not found in RL process...
        update amw_acct_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   deletion_date is null
        and natural_account_id not in (select natural_account_id
        								from amw_acct_associations
        								where pk1 = p_process_id
        								and object_type = 'PROCESS'
        								and approval_date is not null
        								and deletion_approval_date is null);


		insert into amw_acct_associations(
		ACCT_ASSOC_ID,
        NATURAL_ACCOUNT_ID,
        PK1,
        PK2,
        STATEMENT_ID,
        STATEMENT_LINE_ID,
        ORIG_SYSTEM_ACCT_VALUE,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_ACCT_ASSOCIATIONS_S.nextval,
        NATURAL_ACCOUNT_ID,
        p_org_id,
        PK1,
        STATEMENT_ID,
        STATEMENT_LINE_ID,
        ORIG_SYSTEM_ACCT_VALUE,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_acct_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and NATURAL_ACCOUNT_ID not in(select natural_account_id
                                      from amw_acct_associations
                                      where pk1 = p_org_id
        							  and   pk2 = p_process_id
        							  and   object_type = 'PROCESS_ORG'
        							  and   deletion_date is null));

-- Copy attachments...by dpatel
sync_attachments(p_process_id => p_process_id
    ,p_org_id => p_org_id
    ,p_add_upd_flag => 'U');
-- Copy Objectives...by dpatel
--first delete all the unapproved rows...by dpatel
delete from amw_objective_associations
where pk1 = p_org_id
and   pk2 = p_process_id
and   object_type = 'PROCESS_ORG'
and   approval_date is null;

--then delete existing objectives that are not found in RL process...by dpatel
update amw_objective_associations
set deletion_date = sysdate
where pk1 = p_org_id
and   pk2 = p_process_id
and   object_type = 'PROCESS_ORG'
and   deletion_date is null
and PROCESS_OBJECTIVE_ID not in (select PROCESS_OBJECTIVE_ID
								from amw_objective_associations
								where pk1 = p_process_id
								and object_type = 'PROCESS'
								and approval_date is not null
								and deletion_approval_date is null);
--add objectives from the RL...by dpatel
insert into amw_objective_associations
    (OBJECTIVE_ASSOCIATION_ID,
    PROCESS_OBJECTIVE_ID,
    PK1,
    PK2,
    ASSOCIATION_CREATION_DATE,
    APPROVAL_DATE,
    DELETION_DATE,
    DELETION_APPROVAL_DATE,
    OBJECT_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER)
    (select
    AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
    PROCESS_OBJECTIVE_ID,
    p_org_id,
    PK1,
    sysdate,
    null,
    null,
    null,
    'PROCESS_ORG',
    sysdate,
    G_USER_ID,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    1
    from amw_objective_associations
    where PK1 = p_process_id
    and object_type = 'PROCESS'
    and approval_date is not null
    and deletion_approval_date is null
    and PROCESS_OBJECTIVE_ID not in (select PROCESS_OBJECTIVE_ID
                                    from amw_objective_associations
                                    where
                                    PK1 = p_org_id
                                    and PK2 = p_process_id
                                    and object_type = 'PROCESS_ORG'
                                    and deletion_date is null)
    );

end;

/*
  Synchronize the Process Attributes of the process in a all organizations.
*/
procedure sync_process_attributes(p_process_id  in number ) is
l_RL_PROCESS_REV_ID               amw_process.PROCESS_REV_ID%type;
l_SIGNIFICANT_PROCESS_FLAG	      amw_process.SIGNIFICANT_PROCESS_FLAG%type;
l_STANDARD_PROCESS_FLAG 	      amw_process.STANDARD_PROCESS_FLAG%type;
l_PROCESS_CATEGORY    		      amw_process.PROCESS_CATEGORY%type;
l_STANDARD_VARIATION      	      amw_process.STANDARD_VARIATION%type;
l_ATTRIBUTE_CATEGORY      	      amw_process.ATTRIBUTE_CATEGORY%type;
l_ATTRIBUTE1              	      amw_process.ATTRIBUTE1%type;
l_ATTRIBUTE2              	      amw_process.ATTRIBUTE2%type;
l_ATTRIBUTE3              	      amw_process.ATTRIBUTE3%type;
l_ATTRIBUTE4              	      amw_process.ATTRIBUTE4%type;
l_ATTRIBUTE5              	      amw_process.ATTRIBUTE5%type;
l_ATTRIBUTE6              	      amw_process.ATTRIBUTE6%type;
l_ATTRIBUTE7              	      amw_process.ATTRIBUTE7%type;
l_ATTRIBUTE8              	      amw_process.ATTRIBUTE8%type;
l_ATTRIBUTE9              	      amw_process.ATTRIBUTE9%type;
l_ATTRIBUTE10             	      amw_process.ATTRIBUTE10%type;
l_ATTRIBUTE11             	      amw_process.ATTRIBUTE11%type;
l_ATTRIBUTE12             	      amw_process.ATTRIBUTE12%type;
l_ATTRIBUTE13             	      amw_process.ATTRIBUTE13%type;
l_ATTRIBUTE14             	      amw_process.ATTRIBUTE14%type;
l_ATTRIBUTE15             	      amw_process.ATTRIBUTE15%type;
l_SECURITY_GROUP_ID       	      amw_process.SECURITY_GROUP_ID%type;
l_PROCESS_TYPE            	      amw_process.PROCESS_TYPE%type;
l_CONTROL_ACTIVITY_TYPE		      amw_process.CONTROL_ACTIVITY_TYPE%type;
begin
  -- find out if the latest revision for target is approved or not.
  -- if approved, revise it. if draft, don't do anything

  -- psomanat : The check is allready done in Synchronize_process Procedure
  -- revise_process_if_necessary(p_org_id, p_process_id);

  -- copy the attributes from rl to org

    select  PROCESS_REV_ID,
            SIGNIFICANT_PROCESS_FLAG,
            STANDARD_PROCESS_FLAG,
		    PROCESS_CATEGORY,
			STANDARD_VARIATION,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			SECURITY_GROUP_ID,
			PROCESS_TYPE,
			CONTROL_ACTIVITY_TYPE
            into
            l_RL_PROCESS_REV_ID,
			l_SIGNIFICANT_PROCESS_FLAG,
			l_STANDARD_PROCESS_FLAG,
			l_PROCESS_CATEGORY,
			l_STANDARD_VARIATION,
			l_ATTRIBUTE_CATEGORY,
			l_ATTRIBUTE1,
			l_ATTRIBUTE2,
			l_ATTRIBUTE3,
			l_ATTRIBUTE4,
			l_ATTRIBUTE5,
			l_ATTRIBUTE6,
			l_ATTRIBUTE7,
			l_ATTRIBUTE8,
			l_ATTRIBUTE9,
			l_ATTRIBUTE10,
			l_ATTRIBUTE11,
			l_ATTRIBUTE12,
			l_ATTRIBUTE13,
			l_ATTRIBUTE14,
			l_ATTRIBUTE15,
			l_SECURITY_GROUP_ID,
			l_PROCESS_TYPE,
			l_CONTROL_ACTIVITY_TYPE
    from amw_process
    where process_id = p_process_id
--ko need to sync with approved revision
--              and end_date is null;
      and approval_date is not null
      and approval_end_date is null;

    FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        update amw_process_organization
        set    RL_PROCESS_REV_ID             =   l_RL_PROCESS_REV_ID,
			   SIGNIFICANT_PROCESS_FLAG      =   l_SIGNIFICANT_PROCESS_FLAG,
			   STANDARD_PROCESS_FLAG	     =   l_STANDARD_PROCESS_FLAG,
			   PROCESS_CATEGORY_CODE	     =   l_PROCESS_CATEGORY,
			   STANDARD_VARIATION	         =   l_STANDARD_VARIATION,
			   ATTRIBUTE_CATEGORY            =   l_ATTRIBUTE_CATEGORY,
			   ATTRIBUTE1		             =   l_ATTRIBUTE1,
			   ATTRIBUTE2			         =   l_ATTRIBUTE2,
			   ATTRIBUTE3			         =   l_ATTRIBUTE3,
			   ATTRIBUTE4			         =   l_ATTRIBUTE4,
			   ATTRIBUTE5			         =   l_ATTRIBUTE5,
			   ATTRIBUTE6			         =   l_ATTRIBUTE6,
			   ATTRIBUTE7			         =   l_ATTRIBUTE7,
			   ATTRIBUTE8			         =   l_ATTRIBUTE8,
			   ATTRIBUTE9			         =   l_ATTRIBUTE9,
			   ATTRIBUTE10			         =   l_ATTRIBUTE10,
			   ATTRIBUTE11			         =   l_ATTRIBUTE11,
			   ATTRIBUTE12			         =   l_ATTRIBUTE12,
			   ATTRIBUTE13			         =   l_ATTRIBUTE13,
			   ATTRIBUTE14			         =   l_ATTRIBUTE14,
			   ATTRIBUTE15			         =   l_ATTRIBUTE15,
			   SECURITY_GROUP_ID		     =   l_SECURITY_GROUP_ID,
			   PROCESS_TYPE			         =   l_PROCESS_TYPE,
			   CONTROL_ACTIVITY_TYPE	     =   l_CONTROL_ACTIVITY_TYPE
        where organization_id = Org_Ids(indx)
        and process_id = p_process_id
        and end_date is null;


  -- apply process key accounts -- Delete the accounts that does not exists in the rl process...

 	--ko, delete all the unapproved rows
    FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        delete amw_acct_associations
        where pk1 = Org_Ids(indx)
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   approval_date is null;

    -- delete existing accounts that are not found in RL process...
    FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        update amw_acct_associations
        set DELETION_DATE = sysdate
        where pk1 = Org_Ids(indx)
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   deletion_date is null
        and   natural_account_id not in (select natural_account_id
        								 from   amw_acct_associations
        								 where  pk1 = p_process_id
        								 and    object_type = 'PROCESS'
        								 and    approval_date is not null
        								 and    deletion_approval_date is null);

    FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
		insert into amw_acct_associations(
		ACCT_ASSOC_ID,
        NATURAL_ACCOUNT_ID,
        PK1,
        PK2,
        STATEMENT_ID,
        STATEMENT_LINE_ID,
        ORIG_SYSTEM_ACCT_VALUE,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_ACCT_ASSOCIATIONS_S.nextval,
        NATURAL_ACCOUNT_ID,
        Org_Ids(indx),
        PK1,
        STATEMENT_ID,
        STATEMENT_LINE_ID,
        ORIG_SYSTEM_ACCT_VALUE,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_acct_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and NATURAL_ACCOUNT_ID not in (select natural_account_id
                                      from amw_acct_associations
                                      where pk1 = Org_Ids(indx)
        							  and   pk2 = p_process_id
        							  and   object_type = 'PROCESS_ORG'
        							  and   deletion_date is null));

        FOR indx IN Org_Ids.FIRST .. Org_Ids.LAST LOOP
            sync_attachments(p_process_id => p_process_id
                ,p_org_id => Org_Ids(indx)
                ,p_add_upd_flag => 'U');
        END LOOP;

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            delete from amw_objective_associations
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'PROCESS_ORG'
            and   approval_date is null;

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_objective_associations
            set deletion_date = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'PROCESS_ORG'
            and   deletion_date is null
            and PROCESS_OBJECTIVE_ID not in (select PROCESS_OBJECTIVE_ID
            								from amw_objective_associations
            								where pk1 = p_process_id
            								and object_type = 'PROCESS'
            								and approval_date is not null
            								and deletion_approval_date is null);

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            insert into amw_objective_associations
                (OBJECTIVE_ASSOCIATION_ID,
                PROCESS_OBJECTIVE_ID,
                PK1,
                PK2,
                ASSOCIATION_CREATION_DATE,
                APPROVAL_DATE,
                DELETION_DATE,
                DELETION_APPROVAL_DATE,
                OBJECT_TYPE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                OBJECT_VERSION_NUMBER)
                (select
                AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
                PROCESS_OBJECTIVE_ID,
                Org_Ids(indx),
                PK1,
                sysdate,
                null,
                null,
                null,
                'PROCESS_ORG',
                sysdate,
                G_USER_ID,
                sysdate,
                G_USER_ID,
                G_LOGIN_ID,
                1
                from amw_objective_associations
                where PK1 = p_process_id
                and object_type = 'PROCESS'
                and approval_date is not null
                and deletion_approval_date is null
                and PROCESS_OBJECTIVE_ID not in (select PROCESS_OBJECTIVE_ID
                                                from amw_objective_associations
                                                where
                                                PK1 = Org_Ids(indx)
                                                and PK2 = p_process_id
                                                and object_type = 'PROCESS_ORG'
                                                and deletion_date is null)
                );

end;
procedure sync_process_rcm(p_org_id      in number,
				 		   p_process_id  in number,
				           p_sync_rcm    in varchar2
				          ) is

BEGIN

	revise_process_if_necessary(p_org_id, p_process_id);
	IF p_sync_rcm = 'SLIB' THEN
		-- Reflect the RCM list to be like that RL process..
		-- 1.First sync up the Risks....
		-- We Don't want the draft associations to linger in the table..So delete them..
        delete amw_risk_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   approval_date is null;

        update amw_risk_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'PROCESS_ORG'
        and   deletion_date is null
        and  risk_id not in (select risk_id
        					 from amw_risk_associations
        					 where pk1 = p_process_id
        					 and object_type = 'PROCESS'
        					 and approval_date is not null
        					 and deletion_approval_date is null);
		-- Now deleted all the risks that exists in org only but not in rl..Now copy all the risks that exists in rl only and not in org..
  		insert into amw_risk_associations
        (RISK_ASSOCIATION_ID,
        RISK_ID,
        PK1,
        PK2,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_RISK_ASSOCIATIONS_S.nextval,
        RISK_ID,
        p_org_id,
        PK1,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_risk_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and risk_id not in(select risk_id
                            from amw_risk_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'PROCESS_ORG'
        					and   deletion_date is null));

        -- SECOND SYNC UP THE CONTROLS.
        delete amw_control_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'RISK_ORG'
        and   approval_date is null;

        update amw_control_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type = 'RISK_ORG'
        and   deletion_date is null
        and   (pk3, control_id) not in (select pk2, control_id
        					 			from amw_control_associations
        					 			where pk1 = p_process_id
        					 			and object_type = 'RISK'
        					 			and approval_date is not null
        					 			and deletion_approval_date is null);
    	insert into amw_control_associations
        (CONTROL_ASSOCIATION_ID,
        CONTROL_ID,
        PK1,
        PK2,
        PK3,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_CONTROL_ASSOCIATIONS_S.nextval,
        CONTROL_ID,
        p_org_id,
        PK1,
        PK2,
        sysdate,
        null,
        null,
        null,
        'RISK_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_control_associations
        where PK1 = p_process_id
        and object_type = 'RISK'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk2, control_id) not in(select pk3,control_id
                            from amw_control_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'RISK_ORG'
        					and   deletion_date is null));
	-- THIRD..AUDIT PROCEDURES..
		delete from amw_ap_associations
      	where pk1 = p_org_id
      	and   pk2 = p_process_id
      	and association_creation_date is null
      	and   object_type = 'CTRL_ORG';

     	update amw_ap_associations
      	set DELETION_DATE = sysdate
      	where pk1 = p_org_id
      	and   pk2 = p_process_id
      	and   object_type = 'CTRL_ORG'
      	and   deletion_date is null
        and   (pk3, audit_procedure_id) not in (select pk1, audit_procedure_id
        					 			from amw_ap_associations
        					 			where object_type = 'CTRL'
        					 			and approval_date is not null
        					 			and deletion_approval_date is null);
		insert into amw_ap_associations
        (AP_ASSOCIATION_ID,
        AUDIT_PROCEDURE_ID,
        PK1,
        PK2,
        PK3,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_AP_ASSOCIATIONS_S.nextval,
        AUDIT_PROCEDURE_ID,
        p_org_id,
        p_process_id,
        PK1,
    --ko, the values are pk1 = org, pk2 = process, pk3 = control in the org context.    PK2,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        null, --ko commenting.. we set association creation date upon approval of the process..sysdate,
        null,
        null,
        null,
        'CTRL_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_ap_associations
        where PK1 in --ko, replacing  = with in  controls can be more than one..
            (select distinct control_id
            from amw_control_associations
            where PK1 = p_process_id
            and object_type = 'RISK'
            and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
            and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)))
        and object_type = 'CTRL'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk1, audit_procedure_id) not in(select pk3,audit_procedure_id
                            from amw_ap_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'CTRL_ORG'
        					and   deletion_date is null));
      -- FOURTH..OBJECTIVES...

      	delete amw_objective_associations
        where pk1 = p_org_id
        and   pk2 = p_process_id
--        and   object_type  IN ('PROCESS_ORG','CONTROL_ORG') ...by dpatel
        and   object_type = 'CONTROL_ORG'
        and   approval_date is null;
		-- UPDATE CONTROL OBJECTIVES....
        update amw_objective_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type  = 'CONTROL_ORG'
        and   deletion_date is null
        and  (pk3,pk4,process_objective_id) not in (select pk2,pk3, process_objective_id
        					 						from amw_objective_associations
        					 						where pk1 = p_process_id
        					 						and object_type = 'CONTROL'
        					 						and approval_date is not null
        					 						and deletion_approval_date is null);
/*...by dpatel
       	-- UPDATE PROCESS OBJECTIVES..
       	update amw_objective_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type  = 'PROCESS_ORG'
        and   deletion_date is null
        and  process_objective_id not in (select process_objective_id
        					 			  from amw_objective_associations
        					 			  where pk1 = p_process_id
        					 			  and object_type = 'PROCESS'
        					 			  and approval_date is not null
        					 			  and deletion_approval_date is null);
		 -- INSERT PROCESS OBJECTIVES..
        insert into amw_objective_associations
        (OBJECTIVE_ASSOCIATION_ID,
        PROCESS_OBJECTIVE_ID,
        PK1,
        PK2,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
        PROCESS_OBJECTIVE_ID,
        p_org_id,
        PK1,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_objective_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and process_objective_id not in(select process_objective_id
                            			from amw_objective_associations
                            			where pk1 = p_org_id
        								and   pk2 = p_process_id
        								and   object_type = 'PROCESS_ORG'
        								and   deletion_date is null));
*/
       -- Insert Control Objectives...
   	   insert into amw_objective_associations
       (OBJECTIVE_ASSOCIATION_ID,
       PROCESS_OBJECTIVE_ID,
       PK1,
       PK2,
       PK3,
       PK4,
       ASSOCIATION_CREATION_DATE,
       APPROVAL_DATE,
       DELETION_DATE,
       DELETION_APPROVAL_DATE,
       OBJECT_TYPE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER)
       (select
       AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
       PROCESS_OBJECTIVE_ID,
       p_org_id,
       PK1,
       PK2,
       pk3,
       sysdate,
       null,
       null,
       null,
       'CONTROL_ORG',
       sysdate,
       G_USER_ID,
       sysdate,
       G_USER_ID,
       G_LOGIN_ID,
       1
       from amw_objective_associations
       where object_type = 'CONTROL'
       and pk1 = p_process_id
       and approval_date is not null
       and deletion_approval_date is null
       and  (pk2,pk3,process_objective_id) not in (select pk3,pk4, process_objective_id
        					 						from amw_objective_associations
        					 						where pk1 = p_org_id
        											and   pk2 = p_process_id
        											and   object_type  = 'CONTROL_ORG'
        					 						and   deletion_date is null));
--delete the control objectives which are not present in 'PROCESS_ORG'...by dpatel
        update amw_objective_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type  = 'CONTROL_ORG'
        and   deletion_date is null
        and  process_objective_id not in (select process_objective_id
                            			from amw_objective_associations
                            			where pk1 = p_org_id
        								and   pk2 = p_process_id
        								and   object_type = 'PROCESS_ORG'
        								and   deletion_date is null);

	ELSIF p_sync_rcm = 'ARCM' THEN

	    -- WE JUST NEED TO ADD THE NEWLY ADDED RISKS/CONTROLS/AUDIT PROCEDURES TO THE PROCESS..
	    -- so Add Risks..
	    insert into amw_risk_associations
        (RISK_ASSOCIATION_ID,
        RISK_ID,
        PK1,
        PK2,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_RISK_ASSOCIATIONS_S.nextval,
        RISK_ID,
        p_org_id,
        PK1,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_risk_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and risk_id not in(select risk_id
                            from  amw_risk_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'PROCESS_ORG'
        					and   deletion_date is null));
		-- Add controls...
		insert into amw_control_associations
        (CONTROL_ASSOCIATION_ID,
        CONTROL_ID,
        PK1,
        PK2,
        PK3,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_CONTROL_ASSOCIATIONS_S.nextval,
        CONTROL_ID,
        p_org_id,
        PK1,
        PK2,
        sysdate,
        null,
        null,
        null,
        'RISK_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_control_associations
        where PK1 = p_process_id
        and object_type = 'RISK'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk2, control_id) not in(select pk3,control_id
                            from amw_control_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'RISK_ORG'
        					and   deletion_date is null));
		-- NOW AUDIT PROCEDURES...
        insert into amw_ap_associations
        (AP_ASSOCIATION_ID,
        AUDIT_PROCEDURE_ID,
        PK1,
        PK2,
        PK3,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_AP_ASSOCIATIONS_S.nextval,
        AUDIT_PROCEDURE_ID,
        p_org_id,
        p_process_id,
        PK1,
    --ko, the values are pk1 = org, pk2 = process, pk3 = control in the org context.    PK2,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        null, --ko commenting.. we set association creation date upon approval of the process..sysdate,
        null,
        null,
        null,
        'CTRL_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_ap_associations
        where PK1 in --ko, replacing  = with in  controls can be more than one..
            (select distinct control_id
            from amw_control_associations
            where PK1 = p_process_id
            and object_type = 'RISK'
            and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
            and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)))
        and object_type = 'CTRL'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk1, audit_procedure_id) not in(select pk3,audit_procedure_id
                            from amw_ap_associations
                            where pk1 = p_org_id
        					and   pk2 = p_process_id
        					and   object_type = 'CTRL_ORG'
        					and   deletion_date is null));
/*...by dpatel
		 -- INSERT PROCESS OBJECTIVES..
        insert into amw_objective_associations
        (OBJECTIVE_ASSOCIATION_ID,
        PROCESS_OBJECTIVE_ID,
        PK1,
        PK2,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
        PROCESS_OBJECTIVE_ID,
        p_org_id,
        PK1,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_objective_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and process_objective_id not in(select process_objective_id
                            			from amw_objective_associations
                            			where pk1 = p_org_id
        								and   pk2 = p_process_id
        								and   object_type = 'PROCESS_ORG'
        								and   deletion_date is null));
*/
       --Insert Control Objectives...by dpatel
   	   insert into amw_objective_associations
       (OBJECTIVE_ASSOCIATION_ID,
       PROCESS_OBJECTIVE_ID,
       PK1,
       PK2,
       PK3,
       PK4,
       ASSOCIATION_CREATION_DATE,
       APPROVAL_DATE,
       DELETION_DATE,
       DELETION_APPROVAL_DATE,
       OBJECT_TYPE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER)
       (select
       AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
       PROCESS_OBJECTIVE_ID,
       p_org_id,
       PK1,
       PK2,
       pk3,
       sysdate,
       null,
       null,
       null,
       'CONTROL_ORG',
       sysdate,
       G_USER_ID,
       sysdate,
       G_USER_ID,
       G_LOGIN_ID,
       1
       from amw_objective_associations
       where object_type = 'CONTROL'
       and pk1 = p_process_id
       and approval_date is not null
       and deletion_approval_date is null
       and  (pk2,pk3,process_objective_id) not in (select pk3,pk4, process_objective_id
        					 						from amw_objective_associations
        					 						where pk1 = p_org_id
        											and   pk2 = p_process_id
        											and   object_type  = 'CONTROL_ORG'
        					 						and   deletion_date is null)
	   and (pk2,pk3) not in (select pk3,pk4 from amw_objective_associations
        					 						where pk1 = p_org_id
        											and   pk2 = p_process_id
        											and   object_type  = 'CONTROL_ORG'
        					 						and   deletion_date is null)
        );
--delete the control objectives which are not present in 'PROCESS_ORG'...by dpatel
        update amw_objective_associations
        set DELETION_DATE = sysdate
        where pk1 = p_org_id
        and   pk2 = p_process_id
        and   object_type  = 'CONTROL_ORG'
        and   deletion_date is null
        and  process_objective_id not in (select process_objective_id
                            			from amw_objective_associations
                            			where pk1 = p_org_id
        								and   pk2 = p_process_id
        								and   object_type = 'PROCESS_ORG'
        								and   deletion_date is null);

	END IF;

END;

/*
    Revise the Risk Library Process RCM with organizations process in one step.
*/
procedure sync_process_rcm( p_process_id  in number,
				            p_sync_rcm    in varchar2 )
is

BEGIN

	IF p_sync_rcm = 'SLIB' THEN
		-- Reflect the RCM list to be like that RL process..
		-- 1.First sync up the Risks....
		-- We Don't want the draft associations to linger in the table..So delete them..

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            delete amw_risk_associations
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'PROCESS_ORG'
            and   approval_date is null;

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_risk_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'PROCESS_ORG'
            and   deletion_date is null
            and   risk_id not in (select risk_id
	 				              from amw_risk_associations
            					  where pk1 = p_process_id
        	       				  and object_type = 'PROCESS'
        	   	      			  and approval_date is not null
        		      			  and deletion_approval_date is null);
		-- Now deleted all the risks that exists in org only but not in rl..Now copy all the risks that exists in rl only and not in org..
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
  		    insert into amw_risk_associations
            (RISK_ASSOCIATION_ID,
            RISK_ID,
            PK1,
            PK2,
            RISK_LIKELIHOOD_CODE,
            RISK_IMPACT_CODE,
            MATERIAL,
            MATERIAL_VALUE,
            ASSOCIATION_CREATION_DATE,
            APPROVAL_DATE,
            DELETION_DATE,
            DELETION_APPROVAL_DATE,
            OBJECT_TYPE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER)
            (select
            AMW_RISK_ASSOCIATIONS_S.nextval,
            RISK_ID,
            Org_Ids(indx),
            PK1,
            RISK_LIKELIHOOD_CODE,
            RISK_IMPACT_CODE,
            MATERIAL,
            MATERIAL_VALUE,
            sysdate,
            null,
            null,
            null,
            'PROCESS_ORG',
            sysdate,
            G_USER_ID,
            sysdate,
            G_USER_ID,
            G_LOGIN_ID,
            1
            from amw_risk_associations
            where PK1 = p_process_id
            and object_type = 'PROCESS'
            and approval_date is not null
            and deletion_approval_date is null
            and risk_id not in (select risk_id
                                from amw_risk_associations
                                where pk1 = Org_Ids(indx)
        		      			and   pk2 = p_process_id
        		  	     		and   object_type = 'PROCESS_ORG'
        			     		and   deletion_date is null));

        -- SECOND SYNC UP THE CONTROLS.
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            delete  amw_control_associations
            where   pk1 = Org_Ids(indx)
            and     pk2 = p_process_id
            and     object_type = 'RISK_ORG'
            and     approval_date is null;

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_control_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'RISK_ORG'
            and   deletion_date is null
            and   (pk3, control_id) not in (select pk2, control_id
        					 			from amw_control_associations
        					 			where pk1 = p_process_id
        					 			and object_type = 'RISK'
        					 			and approval_date is not null
        					 			and deletion_approval_date is null);

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
    	   insert into amw_control_associations
            (CONTROL_ASSOCIATION_ID,
            CONTROL_ID,
            PK1,
            PK2,
            PK3,
            ASSOCIATION_CREATION_DATE,
            APPROVAL_DATE,
            DELETION_DATE,
            DELETION_APPROVAL_DATE,
            OBJECT_TYPE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER)
            (select
            AMW_CONTROL_ASSOCIATIONS_S.nextval,
            CONTROL_ID,
            Org_Ids(indx),
            PK1,
            PK2,
            sysdate,
            null,
            null,
            null,
            'RISK_ORG',
            sysdate,
            G_USER_ID,
            sysdate,
            G_USER_ID,
            G_LOGIN_ID,
            1
            from amw_control_associations
            where PK1 = p_process_id
            and object_type = 'RISK'
            and approval_date is not null
            and deletion_approval_date is null
            and (pk2, control_id) not in(select pk3,control_id
                            from amw_control_associations
                            where pk1 = Org_Ids(indx)
        					and   pk2 = p_process_id
        					and   object_type = 'RISK_ORG'
        					and   deletion_date is null));


	-- THIRD..AUDIT PROCEDURES..
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            delete from amw_ap_associations
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   association_creation_date is null
            and   object_type = 'CTRL_ORG';

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_ap_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'CTRL_ORG'
            and   deletion_date is null
            and   (pk3, audit_procedure_id) not in (select pk1, audit_procedure_id
        					 			from amw_ap_associations
        					 			where object_type = 'CTRL'
        					 			and approval_date is not null
        					 			and deletion_approval_date is null);

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            insert into amw_ap_associations
            (AP_ASSOCIATION_ID,
            AUDIT_PROCEDURE_ID,
            PK1,
            PK2,
            PK3,
            DESIGN_EFFECTIVENESS,
            OP_EFFECTIVENESS,
            ASSOCIATION_CREATION_DATE,
            APPROVAL_DATE,
            DELETION_DATE,
            DELETION_APPROVAL_DATE,
            OBJECT_TYPE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER)
            (select
            AMW_AP_ASSOCIATIONS_S.nextval,
            AUDIT_PROCEDURE_ID,
            Org_Ids(indx),
            p_process_id,
            PK1,
            --ko, the values are pk1 = org, pk2 = process, pk3 = control in the org context.    PK2,
            DESIGN_EFFECTIVENESS,
            OP_EFFECTIVENESS,
            null, --ko commenting.. we set association creation date upon approval of the process..sysdate,
            null,
            null,
            null,
            'CTRL_ORG',
            sysdate,
            G_USER_ID,
            sysdate,
            G_USER_ID,
            G_LOGIN_ID,
            1
            from amw_ap_associations
            where PK1 in --ko, replacing  = with in  controls can be more than one..
                (select distinct control_id
                from amw_control_associations
                where PK1 = p_process_id
                and object_type = 'RISK'
                and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
                and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)))
                and object_type = 'CTRL'
                and approval_date is not null
                and deletion_approval_date is null
                and (pk1, audit_procedure_id) not in(select pk3,audit_procedure_id
                            from amw_ap_associations
                            where pk1 = Org_Ids(indx)
        					and   pk2 = p_process_id
        					and   object_type = 'CTRL_ORG'
        					and   deletion_date is null));
      -- FOURTH..OBJECTIVES...

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
          	delete amw_objective_associations
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type = 'CONTROL_ORG'
            and   approval_date is null;

		  -- UPDATE CONTROL OBJECTIVES....
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_objective_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type  = 'CONTROL_ORG'
            and   deletion_date is null
            and  (pk3,pk4,process_objective_id) not in (select pk2,pk3, process_objective_id
        					 						from amw_objective_associations
        					 						where pk1 = p_process_id
        					 						and object_type = 'CONTROL'
        					 						and approval_date is not null
        					 						and deletion_approval_date is null);

           -- Insert Control Objectives...
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
   	       insert into amw_objective_associations
           (OBJECTIVE_ASSOCIATION_ID,
            PROCESS_OBJECTIVE_ID,
            PK1,
            PK2,
            PK3,
            PK4,
            ASSOCIATION_CREATION_DATE,
            APPROVAL_DATE,
            DELETION_DATE,
            DELETION_APPROVAL_DATE,
            OBJECT_TYPE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER)
            (select
            AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
            PROCESS_OBJECTIVE_ID,
            Org_Ids(indx),
            PK1,
            PK2,
            pk3,
            sysdate,
            null,
            null,
            null,
            'CONTROL_ORG',
            sysdate,
            G_USER_ID,
            sysdate,
            G_USER_ID,
            G_LOGIN_ID,
            1
            from amw_objective_associations
            where object_type = 'CONTROL'
            and pk1 = p_process_id
            and approval_date is not null
            and deletion_approval_date is null
            and  (pk2,pk3,process_objective_id) not in (select pk3,pk4, process_objective_id
        					 						from amw_objective_associations
        					 						where pk1 = Org_Ids(indx)
        											and   pk2 = p_process_id
        											and   object_type  = 'CONTROL_ORG'
        					 						and   deletion_date is null));

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_objective_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type  = 'CONTROL_ORG'
            and   deletion_date is null
            and  process_objective_id not in (select process_objective_id
                                			from amw_objective_associations
                                			where pk1 = Org_Ids(indx)
            								and   pk2 = p_process_id
            								and   object_type = 'PROCESS_ORG'
            								and   deletion_date is null);

	ELSIF p_sync_rcm = 'ARCM' THEN

	    -- WE JUST NEED TO ADD THE NEWLY ADDED RISKS/CONTROLS/AUDIT PROCEDURES TO THE PROCESS..
	    -- so Add Risks..
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        insert into amw_risk_associations
        (RISK_ASSOCIATION_ID,
        RISK_ID,
        PK1,
        PK2,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_RISK_ASSOCIATIONS_S.nextval,
        RISK_ID,
        Org_Ids(indx),
        PK1,
        RISK_LIKELIHOOD_CODE,
        RISK_IMPACT_CODE,
        MATERIAL,
        MATERIAL_VALUE,
        sysdate,
        null,
        null,
        null,
        'PROCESS_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_risk_associations
        where PK1 = p_process_id
        and object_type = 'PROCESS'
        and approval_date is not null
        and deletion_approval_date is null
        and risk_id not in (select risk_id
                            from  amw_risk_associations
                            where pk1 = Org_Ids(indx)
        					and   pk2 = p_process_id
        					and   object_type = 'PROCESS_ORG'
        					and   deletion_date is null));
		-- Add controls...
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
		insert into amw_control_associations
        (CONTROL_ASSOCIATION_ID,
        CONTROL_ID,
        PK1,
        PK2,
        PK3,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_CONTROL_ASSOCIATIONS_S.nextval,
        CONTROL_ID,
        Org_Ids(indx),
        PK1,
        PK2,
        sysdate,
        null,
        null,
        null,
        'RISK_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_control_associations
        where PK1 = p_process_id
        and object_type = 'RISK'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk2, control_id) not in (select pk3,control_id
                            from amw_control_associations
                            where pk1 = Org_Ids(indx)
        					and   pk2 = p_process_id
        					and   object_type = 'RISK_ORG'
        					and   deletion_date is null));
		-- NOW AUDIT PROCEDURES...
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
        insert into amw_ap_associations
        (AP_ASSOCIATION_ID,
        AUDIT_PROCEDURE_ID,
        PK1,
        PK2,
        PK3,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        ASSOCIATION_CREATION_DATE,
        APPROVAL_DATE,
        DELETION_DATE,
        DELETION_APPROVAL_DATE,
        OBJECT_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
        (select
        AMW_AP_ASSOCIATIONS_S.nextval,
        AUDIT_PROCEDURE_ID,
        Org_Ids(indx),
        p_process_id,
        PK1,
    --ko, the values are pk1 = org, pk2 = process, pk3 = control in the org context.    PK2,
        DESIGN_EFFECTIVENESS,
        OP_EFFECTIVENESS,
        null, --ko commenting.. we set association creation date upon approval of the process..sysdate,
        null,
        null,
        null,
        'CTRL_ORG',
        sysdate,
        G_USER_ID,
        sysdate,
        G_USER_ID,
        G_LOGIN_ID,
        1
        from amw_ap_associations
        where PK1 in --ko, replacing  = with in  controls can be more than one..
            (select distinct control_id
            from amw_control_associations
            where PK1 = p_process_id
            and object_type = 'RISK'
            and (APPROVAL_DATE is not null and APPROVAL_DATE <=  sysdate)
            and (DELETION_DATE is null or (DELETION_DATE is not null and DELETION_APPROVAL_DATE is null)))
        and object_type = 'CTRL'
        and approval_date is not null
        and deletion_approval_date is null
        and (pk1, audit_procedure_id) not in(select pk3,audit_procedure_id
                            from amw_ap_associations
                            where pk1 = Org_Ids(indx)
        					and   pk2 = p_process_id
        					and   object_type = 'CTRL_ORG'
        					and   deletion_date is null));

        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
       	   insert into amw_objective_associations
           (OBJECTIVE_ASSOCIATION_ID,
           PROCESS_OBJECTIVE_ID,
           PK1,
           PK2,
           PK3,
           PK4,
           ASSOCIATION_CREATION_DATE,
           APPROVAL_DATE,
           DELETION_DATE,
           DELETION_APPROVAL_DATE,
           OBJECT_TYPE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER)
           (select
           AMW_OBJECTIVE_ASSOCIATIONS_S.nextval,
           PROCESS_OBJECTIVE_ID,
           Org_Ids(indx),
           PK1,
           PK2,
           pk3,
           sysdate,
           null,
           null,
           null,
           'CONTROL_ORG',
           sysdate,
           G_USER_ID,
           sysdate,
           G_USER_ID,
           G_LOGIN_ID,
           1
           from amw_objective_associations
           where object_type = 'CONTROL'
           and pk1 = p_process_id
           and approval_date is not null
           and deletion_approval_date is null
           and  (pk2,pk3,process_objective_id) not in (select pk3,pk4, process_objective_id
            					 						from amw_objective_associations
            					 						where pk1 = Org_Ids(indx)
            											and   pk2 = p_process_id
            											and   object_type  = 'CONTROL_ORG'
            					 						and   deletion_date is null)
    	   and (pk2,pk3) not in (select pk3,pk4 from amw_objective_associations
            					 						where pk1 = Org_Ids(indx)
            											and   pk2 = p_process_id
            											and   object_type  = 'CONTROL_ORG'
            					 						and   deletion_date is null)
            );
        FORALL indx IN Org_Ids.FIRST .. Org_Ids.LAST
            update amw_objective_associations
            set DELETION_DATE = sysdate
            where pk1 = Org_Ids(indx)
            and   pk2 = p_process_id
            and   object_type  = 'CONTROL_ORG'
            and   deletion_date is null
            and  process_objective_id not in (select process_objective_id
                                			from amw_objective_associations
                                			where pk1 = Org_Ids(indx)
            								and   pk2 = p_process_id
            								and   object_type = 'PROCESS_ORG'
            								and   deletion_date is null);

	END IF;

END;
/* kosriniv...Need to uncomment and change old procedure..

procedure sync_process_people(p_org_id      in number,
		                      p_process_id  in number,
						 	  p_sync_people in varchar2
						     ) is


cursor process_party_list(pid number) is
   SELECT      TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:','')) party_id,
        	   granted_menu.menu_name role_name,
        	   obj.obj_name object_name,
     		   granted_menu.menu_id menu_id,
		   grants.end_date end_date
         FROM fnd_grants grants,
             fnd_menus granted_menu,
             fnd_objects obj
         WHERE obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
         AND   grants.object_id = obj.object_id
         AND   grants.grantee_type ='USER'
         AND   grantee_key like 'HZ_PARTY%'
         AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         AND   grants.menu_id = granted_menu.menu_id
         AND   grants.instance_type = 'INSTANCE'
         ---06.27.2005 npanandi: bug fix for ADS bug 4458414, passing to_char instead of num
		 ---AND   grants.instance_pk1_value = pid
		 AND   grants.instance_pk1_value = to_char(pid)
         AND   grants.instance_pk2_value = '*NULL*'
         AND   grants.instance_pk3_value = '*NULL*'
         AND   grants.instance_pk4_value = '*NULL*'
         AND   grants.instance_pk5_value = '*NULL*'
         and   granted_menu.menu_name in ('AMW_RL_PROC_OWNER_ROLE', 'AMW_RL_PROC_FINANCE_OWNER_ROLE', 'AMW_RL_PROC_APPL_OWNER_ROLE');

cursor org_only_party_list(org_id number, process_id number, org_menu_name varchar2, rl_menu_name varchar2) is
   SELECT   grants.grant_guid grant_guid
   FROM 	fnd_grants grants,
        	fnd_menus granted_menu,
            fnd_objects obj
   		WHERE obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
         AND   grants.object_id = obj.object_id
         AND   grants.grantee_type ='USER'
         AND   grantee_key like 'HZ_PARTY%'
         AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         AND   grants.menu_id = granted_menu.menu_id
         AND   grants.instance_type = 'INSTANCE'
         ---06.27.2005 npanandi: bug fix for ADS bug 4458414, passing to_char instead of num
         ---AND   grants.instance_pk1_value = org_id
		 AND   grants.instance_pk1_value = to_char(org_id)
		 ---06.27.2005 npanandi: bug fix for ADS bug 4458414, passing to_char instead of num
         ----AND   grants.instance_pk2_value = process_id
		 AND   grants.instance_pk2_value = to_char(process_id)
         AND   grants.instance_pk3_value = '*NULL*'
         AND   grants.instance_pk4_value = '*NULL*'
         AND   grants.instance_pk5_value = '*NULL*'
         and   granted_menu.menu_name = org_menu_name
         and (grants.grantee_key, obj.object_id ,grants.menu_id ) not in (select grants.grantee_key,obj.object_id, grants.menu_id
         	                                                              FROM fnd_grants grants,
         																	    fnd_menus granted_menu,
         																	    fnd_objects obj
         																	WHERE obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
         																	AND   grants.object_id = obj.object_id
         																	AND   grants.grantee_type ='USER'
         																	AND   grantee_key like 'HZ_PARTY%'
         																	AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         																	AND   grants.menu_id = granted_menu.menu_id
         																	AND   grants.instance_type = 'INSTANCE'
         																	---06.27.2005 npanandi: bug fix for ADS bug 4458414, passing to_char instead of num
         																	---AND   grants.instance_pk1_value = process_id
																			AND   grants.instance_pk1_value = to_char(process_id)
         																	AND   grants.instance_pk2_value = '*NULL*'
         																	AND   grants.instance_pk3_value = '*NULL*'
         																	AND   grants.instance_pk4_value = '*NULL*'
         																	AND   grants.instance_pk5_value = '*NULL*'
         																	and   granted_menu.menu_name = rl_menu_name);


l_return_status varchar2(10);
l_err_code number;
l_msg_data varchar2(4000);
BEGIN
    revise_process_if_necessary(p_org_id, p_process_id);
	IF  p_sync_people = 'SLIB' THEN
		-- NOW remove the ORG SPECIFIC PROC OWNERS..

		FOR powners_list_rec in org_only_party_list(p_org_id,p_process_id,'AMW_ORG_PROC_OWNER_ROLE','AMW_RL_PROC_OWNER_ROLE') LOOP
	  	EXIT WHEN org_only_party_list%NOTFOUND;

		  AMW_SECURITY_PUB.revoke_grant(
	  								   p_api_version    =>  1,
						     		   p_grant_guid     => 	powners_list_rec.grant_guid,
                                       x_return_status  =>  l_return_status,
                                       x_errorcode      =>  l_err_code
    	                                );
		END LOOP;

		FOR fowners_list_rec in org_only_party_list(p_org_id,p_process_id,'AMW_ORG_PROC_FIN_OWNER_ROLE','AMW_RL_PROC_FINANCE_OWNER_ROLE') LOOP
	  	EXIT WHEN org_only_party_list%NOTFOUND;
        AMW_SECURITY_PUB.revoke_grant(
	  								   p_api_version    =>  1,
						     		   p_grant_guid     => 	fowners_list_rec.grant_guid,
                                       x_return_status  =>  l_return_status,
                                       x_errorcode      =>  l_err_code
                                     );
		END LOOP;

		FOR aowners_list_rec in org_only_party_list(p_org_id,p_process_id,'AMW_ORG_PROC_APPL_OWNER_ROLE','AMW_RL_PROC_APPL_OWNER_ROLE') LOOP
	  	EXIT WHEN org_only_party_list%NOTFOUND;

	  	AMW_SECURITY_PUB.revoke_grant(
	  								   p_api_version    =>  1,
						     		   p_grant_guid     => 	aowners_list_rec.grant_guid,
                                       x_return_status  =>  l_return_status,
                                       x_errorcode      =>  l_err_code
        	                          );
		END LOOP;

	END IF;

	-- NOW ADD ALL THE ROLES NOW..

	for party_list_rec in process_party_list(p_process_id) loop
	  exit when process_party_list%notfound;

	  if party_list_rec.role_name = 'AMW_RL_PROC_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_err_code,
               x_grant_guid            => l_msg_data);

	  elsif party_list_rec.role_name = 'AMW_RL_PROC_FINANCE_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_FIN_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_err_code,
               x_grant_guid            => l_msg_data);

	  elsif party_list_rec.role_name = 'AMW_RL_PROC_APPL_OWNER_ROLE' then

              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => 'AMW_ORG_PROC_APPL_OWNER_ROLE',
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => party_list_rec.party_id,
               p_start_date            => sysdate,
               p_end_date              => party_list_rec.end_date,
               x_return_status         => l_return_status,
               x_errorcode             => l_err_code,
               x_grant_guid            => l_msg_data);

	  end if;

  end loop;


END;
*/

procedure sync_process_people(p_org_id      in number,
		                      p_process_id  in number,
						 	  p_sync_people in varchar2
						     ) is
BEGIN
    -- psomanat : This step allready done in Syncronize Process.
    --revise_process_if_necessary(p_org_id, p_process_id);
   	    IF  p_sync_people = 'SLIB' THEN
            sync_people_revoke_grant(p_org_id,p_process_id,'AMW_ORG_PROC_OWNER_ROLE','AMW_RL_PROC_OWNER_ROLE');
            sync_people_revoke_grant(p_org_id,p_process_id,'AMW_ORG_PROC_FIN_OWNER_ROLE','AMW_RL_PROC_FINANCE_OWNER_ROLE');
            sync_people_revoke_grant(p_org_id,p_process_id,'AMW_ORG_PROC_APPL_OWNER_ROLE','AMW_RL_PROC_APPL_OWNER_ROLE');
        END IF;
        sync_people_add_grant(p_org_id,p_process_id,'AMW_ORG_PROC_OWNER_ROLE','AMW_RL_PROC_OWNER_ROLE');
        sync_people_add_grant(p_org_id,p_process_id,'AMW_ORG_PROC_FIN_OWNER_ROLE','AMW_RL_PROC_FINANCE_OWNER_ROLE');
        sync_people_add_grant(p_org_id,p_process_id,'AMW_ORG_PROC_APPL_OWNER_ROLE','AMW_RL_PROC_APPL_OWNER_ROLE');
END;

--******************************************************************************
-- Remove the people with the given grant in risk library from the Organization.
-- p_org_id          : The Organization id
-- p_process_id      : The process in Risk Library whose people are syncronized
--                     to the same process in the given organization.
-- p_org_menu_name   : The Organization Grant Name
-- p_rl_menu_name    : The process Grant Name.
--******************************************************************************
procedure sync_people_revoke_grant(  p_org_id in number,
						 	         p_process_id in number,
                                     p_org_menu_name in varchar2,
                                     p_rl_menu_name in varchar2 ) is

    TYPE t_grant_guid IS TABLE OF fnd_grants.grant_guid%type;
    l_grant_guid t_grant_guid;
    l_return_status varchar2(10);
    l_err_code number;
    l_msg_data varchar2(4000);
    l_msg_count	            number;


BEGIN
    l_grant_guid := t_grant_guid();
    l_grant_guid.delete;

    SELECT  grants.grant_guid grant_guid
    BULK COLLECT INTO l_grant_guid
    FROM 	fnd_grants grants,
            fnd_menus granted_menu,
            fnd_objects obj
    WHERE   obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
    AND     grants.object_id = obj.object_id
    AND     grants.grantee_type ='USER'
    AND     grantee_key like 'HZ_PARTY%'
    AND     NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
    AND     grants.menu_id = granted_menu.menu_id
    AND     grants.instance_type = 'INSTANCE'
    AND     grants.instance_pk1_value = to_char(p_org_id)
    AND     grants.instance_pk2_value = to_char(p_process_id)
    AND     grants.instance_pk3_value = '*NULL*'
    AND     grants.instance_pk4_value = '*NULL*'
    AND     grants.instance_pk5_value = '*NULL*'
    and     granted_menu.menu_name = p_org_menu_name
    and     (grants.grantee_key) not in (   select  grants.grantee_key
                                            FROM    fnd_grants grants,
				                                    fnd_menus granted_menu,
                                                    fnd_objects obj
                                            WHERE obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
         										AND   grants.object_id = obj.object_id
         										AND   grants.grantee_type ='USER'
         										AND   grantee_key like 'HZ_PARTY%'
         										AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         										AND   grants.menu_id = granted_menu.menu_id
         										AND   grants.instance_type = 'INSTANCE'
												AND   grants.instance_pk1_value = to_char(p_process_id)
         										AND   grants.instance_pk2_value = '*NULL*'
         										AND   grants.instance_pk3_value = '*NULL*'
         										AND   grants.instance_pk4_value = '*NULL*'
         										AND   grants.instance_pk5_value = '*NULL*'
         										and   granted_menu.menu_name = p_rl_menu_name);

        IF l_grant_guid.exists(1)  THEN
            FOR i IN l_grant_guid.FIRST .. l_grant_guid.LAST
            LOOP
                AMW_SECURITY_PUB.revoke_grant(
		                  p_api_version    =>  1,
                          p_grant_guid     => 	l_grant_guid(i),
                          x_return_status  =>  l_return_status,
                          x_errorcode      =>  l_err_code
                    );
            END LOOP;
        END IF;

Exception
    when others then
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in sync_people_revoke_grant '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);
        raise;
END	;

--******************************************************************************
-- Adds the people with the given grant in risk library from the Organization.
-- p_org_id          : The Organization id
-- p_process_id      : The process in Risk Library whose people are syncronized
--                     to the same process in the given organization.
-- p_org_menu_name   : The Organization Grant Name
-- p_rl_menu_name    : The process Grant Name.
--******************************************************************************
procedure sync_people_add_grant(     p_org_id in number,
						 	         p_process_id in number,
                                     p_org_menu_name in varchar2,
                                     p_rl_menu_name in varchar2 ) is

    TYPE t_party_id IS TABLE OF number;
    TYPE t_end_date IS TABLE OF fnd_grants.end_date%TYPE;

    l_party_id t_party_id;
    l_end_date t_end_date;

    l_return_status varchar2(10);
    l_err_code number;
    l_msg_data varchar2(4000);
    l_msg_count	number;


BEGIN
    l_party_id := t_party_id();
    l_end_date := t_end_date();
    l_party_id.delete;
    l_end_date.delete;


    SELECT  TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:','')) party_id,
            grants.end_date end_date
    BULK COLLECT INTO   l_party_id,
                        l_end_date
    FROM    fnd_grants grants,
            fnd_menus granted_menu,
            fnd_objects obj
    WHERE   obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
    AND     grants.object_id = obj.object_id
    AND     grants.grantee_type ='USER'
    AND     grantee_key like 'HZ_PARTY%'
    AND     NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
    AND     grants.menu_id = granted_menu.menu_id
    AND     grants.instance_type = 'INSTANCE'
    AND     grants.instance_pk1_value = to_char(p_process_id)
    AND     grants.instance_pk2_value = '*NULL*'
    AND     grants.instance_pk3_value = '*NULL*'
    AND     grants.instance_pk4_value = '*NULL*'
    AND     grants.instance_pk5_value = '*NULL*'
    and     granted_menu.menu_name = p_rl_menu_name
    and     (grants.grantee_key) not in (   select  grants.grantee_key
                                            FROM    fnd_grants grants,
         							                fnd_menus granted_menu,
                                                    fnd_objects obj
         							        WHERE   obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
         							        AND     grants.object_id = obj.object_id
         							        AND     grants.grantee_type ='USER'
         							        AND     grantee_key like 'HZ_PARTY%'
         							        AND     NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
         							        AND     grants.menu_id = granted_menu.menu_id
         							        AND     grants.instance_type = 'INSTANCE'
                                            AND     grants.instance_pk1_value = to_char(p_org_id)
                                            AND     grants.instance_pk2_value = to_char(p_process_id)
         							        AND     grants.instance_pk3_value = '*NULL*'
         							        AND     grants.instance_pk4_value = '*NULL*'
         							        AND     grants.instance_pk5_value = '*NULL*'
         							        and     granted_menu.menu_name = p_org_menu_name );
    IF l_party_id.exists(1)  THEN
        FOR i IN l_party_id.FIRST .. l_party_id.LAST
        LOOP
              AMW_SECURITY_PUB.grant_role_guid
              (
               p_api_version           => 1,
               p_role_name             => p_org_menu_name,
               p_object_name           => 'AMW_PROCESS_ORGANIZATION',
               p_instance_type         => 'INSTANCE',
               p_instance_set_id       => null,
               p_instance_pk1_value    => p_org_id,
               p_instance_pk2_value    => p_process_id,
               p_instance_pk3_value    => null,
               p_instance_pk4_value    => null,
               p_instance_pk5_value    => null,
               p_party_id              => l_party_id(i),
               p_start_date            => sysdate,
               p_end_date              => l_end_date(i),
               x_return_status         => l_return_status,
               x_errorcode             => l_err_code,
               x_grant_guid            => l_msg_data);
        END LOOP;
    END IF;

Exception
    when others then
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in sync_people_add_grant '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);
        raise;

END	;

/*
  Syncronize the Risk Library People with the same process in
  all organization in one step.
*/
procedure sync_process_people(  p_process_id  in number,
						 	    p_sync_people in varchar2 ) is
	l_return_status varchar2(10);
    l_err_code number;
    l_msg_data varchar2(4000);
    l_msg_count	            number;
BEGIN
    FOR indx IN Org_Ids.FIRST .. Org_Ids.LAST
    LOOP
   	    IF  p_sync_people = 'SLIB' THEN
            sync_people_revoke_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_OWNER_ROLE','AMW_RL_PROC_OWNER_ROLE');
            sync_people_revoke_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_FIN_OWNER_ROLE','AMW_RL_PROC_FINANCE_OWNER_ROLE');
            sync_people_revoke_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_APPL_OWNER_ROLE','AMW_RL_PROC_APPL_OWNER_ROLE');
        END IF;
        sync_people_add_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_OWNER_ROLE','AMW_RL_PROC_OWNER_ROLE');
        sync_people_add_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_FIN_OWNER_ROLE','AMW_RL_PROC_FINANCE_OWNER_ROLE');
        sync_people_add_grant(Org_Ids(indx),p_process_id,'AMW_ORG_PROC_APPL_OWNER_ROLE','AMW_RL_PROC_APPL_OWNER_ROLE');
    END LOOP;
EXCEPTION
    when others then
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in sync_process_people '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);
        raise;
END;

/*
Synchornization Parameters
==========================

1. p_org_id          - Organization Id

2. p_process_id      - Process Id

3. p_sync_mode
	'PSUBP'  - Current Process and its Sub Processes
	'PONLY'   - Current Process Only.

4. p_sync_hierarchy
	'NO'         - Retain Definition In the Organization.. Do not change the hierarchy
	'YES'         - Synchronize with the library definition..Hierarchy Made equivalent to the Risk Library

5 p_sync_attributes
	'YES'        - Synchronize the process attributes..(attributes, keyaccounts, attachments)
	'NO'         - Do not change...

6. p_sync_rcm
	'RDEF'		  - Retain Definition in the organization.. Do not make any changes to Risks, controls and Audit Procedures.
	'SLIB' 		  - Synchronize with the library definition .. Risks, Controls and Audit Procedures list equal to the RL
	'ARCM'		  - Add Risks and Controls and Audit Procedures that exists in RL but not in Org.

7. p_sync_people
	'RDEF'		  -  Retain Definition In the Organization.. Do no make any changes to People list
	'SLIB'        -  Synchronize with the library definition...Make Equal to the RL list
	'APPL'		  -  Add Process People.
*/
procedure Synchronize_process(
				p_org_id   in number,
				p_process_id  in number,
				p_sync_mode in varchar2,
				p_sync_hierarchy in varchar2,
				p_sync_attributes in varchar2,
				p_sync_rcm in varchar2,
				p_sync_people in varchar2
			) is

 	cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

    c1_rec c1%rowtype;
    l_child_process_id number;
    l_dummy number;
  l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;
  pending_approval_exception exception;
  l_approval_status varchar2(1);
  l_proc_latest FND_ATTACHED_DOCUMENTS.pk1_value%type;
  l_proc_prev FND_ATTACHED_DOCUMENTS.pk1_value%type;

BEGIN

-- synchronization is only done to a process when it exists in the organization..
	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.begin',
        ' OrgId:' ||p_org_id || ';ProcessId:'||p_process_id
        ||';p_sync_mode:'||p_sync_mode||';p_sync_hierarchy:'||p_sync_hierarchy||';p_sync_attributes:'||p_sync_attributes
        ||';p_sync_rcm:'||p_sync_rcm||';p_sync_people:'||p_sync_people);
	end if;

    IF p_sync_hierarchy = 'NO' AND p_sync_attributes = 'NO' AND p_sync_rcm = 'RDEF' AND p_sync_people = 'RDEF' THEN
    	if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.End;',
        	'End');
		end if;
		return;
	END IF;

	SELECT 1 INTO l_dummy
	from amw_process_organization
	where organization_id = p_org_id
	and process_id = p_process_id
	and end_date is null
	and deletion_date is null;

	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.produce_err_if_pa_or_locked',
        ' OrgId:' ||p_org_id || ';ProcessId:'||p_process_id );
	end if;
	produce_err_if_pa_or_locked(p_org_id, p_process_id);
	if( l_log_stmt_level >= l_curr_log_level ) then
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.revise_process_if_necessary',
        ' OrgId:' ||p_org_id || ';ProcessId:'||p_process_id );
	end if;

	--attachment bug5968299 codefix start

	select approval_status
        into l_approval_status
        from amw_process_organization
        where process_id = p_process_id
        and organization_id = p_org_id
        and end_date is null
        and  deletion_date is null;
        /*the approval status should be known so that
        when a new revision is created while synchronising
        and if process attributes are not synchronised the attachments
        should be copied from previour revision to the latest revision*/



	--attachment bug5968299 codefix end

	revise_process_if_necessary(p_org_id, p_process_id);

		/*the following case will happen when
                 process attributes are not synchronised .
                 In that case we have to copy attachments from
                 latest approved revision to the latest revision in the organization */
	IF p_sync_attributes = 'NO' THEN
		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.sync_process_attributes(bug5962899)',
        	p_org_id || p_process_id );
		end if;
		if l_approval_status='A' then
		    select process_org_rev_id into l_proc_latest
		    from amw_process_organization
                    where process_id = p_process_id
                    and organization_id = p_org_id
                    and end_date is null;

                    select process_org_rev_id into l_proc_prev
	   	    from amw_process_organization
                    where process_id = p_process_id
                    and organization_id = p_org_id
                    and approval_date is not null
                    and approval_end_date is null;

                    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROCESS_ORGANIZATION'
                   ,X_from_pk1_value => l_proc_prev
                   ,X_to_entity_name => 'AMW_PROCESS_ORGANIZATION'
                   ,X_to_pk1_value => l_proc_latest
                   ,X_created_by => G_USER_ID
                   ,X_last_update_login => G_LOGIN_ID
                    );



		end if;


   	END IF;

	IF p_sync_attributes = 'YES' THEN
		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.sync_process_attributes',
        	p_org_id || p_process_id );
		end if;
		sync_process_attributes(p_org_id      => p_org_id,
								p_process_id  => p_process_id			-- Sync up the attributes also..
								);
	END IF;


	IF p_sync_rcm = 'SLIB' or p_sync_rcm = 'ARCM' THEN
		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.sync_process_rcm',
        	p_org_id || p_process_id ||p_sync_rcm);
		end if;
		sync_process_rcm(p_org_id      => p_org_id,
						 p_process_id  => p_process_id,
						 p_sync_rcm => p_sync_rcm				-- Sync up the RCM ...
						 );
	END IF;


	IF p_sync_people = 'SLIB' or p_sync_people = 'APPL' THEN
		if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.sync_process_people',
        	p_org_id || p_process_id ||p_sync_people);
		end if;
		sync_process_people(p_org_id      => p_org_id,
						 	p_process_id  => p_process_id,
						 	p_sync_people => p_sync_people				-- Sync up the PEOPLE...
						   );
	END IF;


	IF p_sync_mode = 'PSUBP' THEN
		IF p_sync_hierarchy = 'YES' THEN
			if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.synchronize_hierarchy',
        	p_org_id || p_process_id );
		end if;
			synchronize_hierarchy( p_org_id      => p_org_id,
                                  p_parent_process_id  => p_process_id,
                                  p_sync_attributes => p_sync_attributes,
                                  p_sync_rcm => p_sync_rcm,
                                  p_sync_people => p_sync_people );
	    ELSE
	    	-- For each of the child in the RL process, Call Synchronize_process

	    	for c1_rec in c1(p_process_id) loop
	  		exit when c1%notfound;
        	l_child_process_id := c1_rec.child_process_id;
			if( l_log_stmt_level >= l_curr_log_level ) then
    			FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        		'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.synchronize_process',
        		'child_id:' || l_child_process_id );
			end if;
	    	synchronize_process(p_org_id      => p_org_id,
                                  p_process_id  => l_child_process_id,
                                  p_sync_mode   => p_sync_mode,
								  p_sync_hierarchy =>p_sync_hierarchy,
                                  p_sync_attributes => p_sync_attributes,
                                  p_sync_rcm => p_sync_rcm,
                                  p_sync_people => p_sync_people );
		    end loop;


        END IF;
    END IF;
    if( l_log_stmt_level >= l_curr_log_level ) then
    		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        	'amw.plsql.AMW_ORG_HIERARCHY_PKG.SYNCHRONIZE_PROCESS.End;',
        	'End');
	end if;

EXCEPTION
	when pending_approval_exception then
	    raise;
	WHEN no_data_found THEN
        return;

END;
/*
    Synchronizes the Risk Library Process with the Process in all organization.
*/
procedure Synchronize_process(
				p_process_id  in number,
				p_sync_mode in varchar2,
				p_sync_hierarchy in varchar2,
				p_sync_attributes in varchar2,
				p_sync_rcm in varchar2,
				p_sync_people in varchar2
			) is

 	cursor c1 (l_pid number) is
    select ah.child_id child_process_id
      from amw_approved_hierarchies ah
      where ah.parent_id = (select pp.process_id
                            from amw_process pp
                            where pp.process_id = ah.parent_id
                            and pp.approval_date is not null
                            and pp.approval_end_date is null
                            and pp.deletion_date is null)
       and ah.child_id  =  ( select Cp.process_id
                            from amw_process Cp
                            where Cp.process_id = ah.child_id
                            and Cp.approval_date is not null
                            and Cp.approval_end_date is null
                            and Cp.deletion_date is null)
       and ah.start_date is not null
       and ah.end_date is null
       and ah.organization_id = -1
       and ah.parent_id = l_pid;

    c1_rec c1%rowtype;
    l_child_process_id number;
    l_dummy number;
  l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;
  pending_approval_exception exception;
    l_msg_data              varchar2(4000);
    l_msg_count	            number;

BEGIN
    -- This to be handled later
	-- produce_err_if_pa_or_locked(p_org_id, p_process_id);

	revise_process_if_necessary(p_process_id);

	IF p_sync_attributes = 'YES' THEN
		sync_process_attributes(p_process_id  => p_process_id);
	END IF;

	IF p_sync_rcm = 'SLIB' or p_sync_rcm = 'ARCM' THEN
		sync_process_rcm(p_process_id  => p_process_id,
						 p_sync_rcm    => p_sync_rcm				-- Sync up the RCM ...
                );
	END IF;

	IF p_sync_people = 'SLIB' or p_sync_people = 'APPL' THEN
		sync_process_people(p_process_id  => p_process_id,
						 	p_sync_people => p_sync_people				-- Sync up the PEOPLE...
						   );
	END IF;

	IF p_sync_mode = 'PSUBP' THEN
		IF p_sync_hierarchy = 'YES' THEN
			synchronize_hierarchy( p_parent_process_id  => p_process_id,
                                   p_sync_attributes => p_sync_attributes,
                                   p_sync_rcm => p_sync_rcm,
                                   p_sync_people => p_sync_people );
	    ELSE
	    	-- For each of the child in the RL process, Call Synchronize_process
	    	for c1_rec in c1(p_process_id) loop
	  		exit when c1%notfound;
        	l_child_process_id := c1_rec.child_process_id;
	    	synchronize_process(  p_process_id  => l_child_process_id,
                                  p_sync_mode   => p_sync_mode,
								  p_sync_hierarchy =>p_sync_hierarchy,
                                  p_sync_attributes => p_sync_attributes,
                                  p_sync_rcm => p_sync_rcm,
                                  p_sync_people => p_sync_people );
		    end loop;
        END IF;
    END IF;
EXCEPTION
	when pending_approval_exception then
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in Revision '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);

	   raise;
	WHEN no_data_found THEN
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
        fnd_file.put_line(fnd_file.LOG, ' Error in Revision '||sqlerrm);
        fnd_file.put_line(fnd_file.LOG, l_msg_data);

        return;
END;

procedure sync_proc_organizations(
p_process_id			in number,
p_org_id_string			in varchar2,
p_sync_mode 			in varchar2,
p_sync_hierarchy 		in varchar2,
p_sync_attributes 		in varchar2,
p_sync_rcm 				in varchar2,
p_sync_people 			in varchar2,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 )is


cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A';

L_API_NAME CONSTANT VARCHAR2(30) := 'sync_proc_organizations';

str              varchar2(4000);
diff		 number;
orgstr		 varchar2(100);
l_org_string     varchar2(4000);
orgid		 number;


begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


l_org_string := p_org_id_string;
while LENGTH(l_org_string) <> 0 loop
select LTRIM(l_org_string, '1234567890') into str from dual;
diff := LENGTH(l_org_string) - LENGTH(str);
if  LENGTH(str) is null then  diff := LENGTH(l_org_string); end if;
select SUBSTR(l_org_string, 1, diff) into orgstr from dual;
orgid := to_number(orgstr);

	synchronize_process(p_org_id      => orgid,
                        p_process_id  => p_process_id,
                        p_sync_mode   => p_sync_mode,
						p_sync_hierarchy =>p_sync_hierarchy,
                        p_sync_attributes => p_sync_attributes,
                        p_sync_rcm => p_sync_rcm,
                        p_sync_people => p_sync_people );
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
--Ko Update the Proc_org_hierarchy_denorm tables..
  AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => orgid);
*/
  -- ko update the risk1 counts of the child process..
  upd_ltst_risk_count(p_org_id => orgid, p_process_id => null);

  upd_ltst_control_count(p_org_id => orgid, p_process_id => null);




select LTRIM(str, 'x') into l_org_string from dual;
end loop;

-- update the org counts of the child process and its hierarchy....
	for descendents_rec in c1(p_process_id) loop
     		exit when c1%notfound;
      		amw_rl_hierarchy_pkg.update_org_count(descendents_rec.process_to_count);
 	end loop;

exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end sync_proc_organizations;


procedure reset_count(
			 errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2,
			p_org_id in number
			) is
conc_status boolean;

cursor all_orgs is
select distinct organization_id
from amw_process_organization
where process_id = -2;

begin

	retcode :=0;
	errbuf :='';
	if p_org_id is null then
		for org_cursor in all_orgs loop
			exit when all_orgs%notfound;
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
			--updates latest hier denorm
			amw_rl_hierarchy_pkg.update_denorm (org_cursor.organization_id, sysdate);
			--updates approved hier denorm
			amw_rl_hierarchy_pkg.update_approved_denorm (org_cursor.organization_id, sysdate);
*/
			update amw_process_organization
			set risk_count = null,
			control_count = null,
			risk_count_latest = null,
			control_count_latest = null
			where organization_id = org_cursor.organization_id;

			-- update latest risk and control counts

			upd_ltst_risk_count(p_org_id => org_cursor.organization_id, p_process_id => null);

			upd_ltst_control_count(p_org_id => org_cursor.organization_id, p_process_id => null);

			-- update latest risk and control counts

			upd_appr_risk_count(p_org_id => org_cursor.organization_id, p_process_id => null);

			upd_appr_control_count(p_org_id => org_cursor.organization_id, p_process_id => null);
		end loop;

	else
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
		--updates latest hier denorm
		amw_rl_hierarchy_pkg.update_denorm (p_org_id, sysdate);
		--updates approved hier denorm
		amw_rl_hierarchy_pkg.update_approved_denorm (p_org_id, sysdate);
*/
		update amw_process_organization
		set risk_count = null,
		control_count = null,
		risk_count_latest = null,
		control_count_latest = null
		where organization_id = p_org_id;

		-- update latest risk and control counts

		upd_ltst_risk_count(p_org_id => p_org_id, p_process_id => null);

		upd_ltst_control_count(p_org_id => p_org_id, p_process_id => null);

		-- update latest risk and control counts

		upd_appr_risk_count(p_org_id => p_org_id, p_process_id => null);

		upd_appr_control_count(p_org_id => p_org_id, p_process_id => null);
	end if;

	commit;
exception
	when others then
		rollback;
		retcode :=2;
		errbuf :=SUBSTR(SQLERRM,1,1000);
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

end reset_count;

procedure delete_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_child_id_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2)
is
  l_api_name constant varchar2(30) := 'delete_activities';
  str              varchar2(4000);
  diff		 	 number;
  childstr		 varchar2(100);
  l_child_string   varchar2(4000);
  l_child_id		 number;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null or p_organization_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  l_child_string :=  p_child_id_string;
  while LENGTH(l_child_string) <> 0 loop
    select LTRIM(l_child_string, '1234567890') into str from dual;
    diff := LENGTH(l_child_string) - LENGTH(str);
    if  LENGTH(str) is null then
      diff := LENGTH(l_child_string);
    end if;
    select SUBSTR(l_child_string, 1, diff) into childstr from dual;
    l_child_id := to_number(childstr);

    delete from amw_latest_hierarchies
    where parent_id = p_parent_process_id
    and   child_id  = l_child_id
    and organization_id = p_organization_id;

    select LTRIM(str, 'x') into l_child_string from dual;
  end loop;
exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
end delete_activities;

procedure add_org_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_child_id_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2)
is
  l_api_name constant varchar2(30) := 'add_org_activities';
  str              varchar2(4000);
  diff		 	 number;
  childstr		 varchar2(100);
  l_child_string   varchar2(4000);
  l_child_id		 number;
  l_child_order_num amw_latest_hierarchies.child_order_number%type;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null or p_organization_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  l_child_string :=  p_child_id_string;
  while LENGTH(l_child_string) <> 0 loop
    select LTRIM(l_child_string, '1234567890') into str from dual;
    diff := LENGTH(l_child_string) - LENGTH(str);
    if  LENGTH(str) is null then
      diff := LENGTH(l_child_string);
    end if;
    select SUBSTR(l_child_string, 1, diff) into childstr from dual;
    l_child_id := to_number(childstr);

    produce_err_if_circular(
	p_org_id => p_organization_id,
	p_parent_process_id => p_parent_process_id,
    p_child_process_id => l_child_id);

    insert into amw_latest_hierarchies
    (ORGANIZATION_ID, PARENT_ID, CHILD_ID, CHILD_ORDER_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, object_version_number)
    VALUES
    (p_organization_id,p_parent_process_id,l_child_id,AMW_ORG_CHILD_ORDER_S.nextval, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1)
    returning                CHILD_ORDER_NUMBER
    into                     l_child_order_num;

    AMW_RL_HIERARCHY_PKG.update_appr_ch_ord_num_if_reqd
                (p_org_id      =>  p_organization_id,
                 p_parent_id   =>  p_parent_process_id,
                 p_child_id    =>  l_child_id,
                 p_instance_id =>  l_child_order_num);


    select LTRIM(str, 'x') into l_child_string from dual;
  end loop;
exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
end add_org_activities;

procedure add_rl_activities(p_parent_process_id in number,
						    p_organization_id in number,
			   				p_comb_string in varchar2,
  						 	p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
	                        x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2)
is
  l_api_name constant varchar2(30) := 'add_rl_activities';
  iStart pls_integer := 1;
  iEnd   pls_integer;
  childstr		 varchar2(100);
  l_child_id		 number;
  l_revise_existing varchar2(10);
  l_apply_RCM varchar2(10);
  l_dummy number;

  cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;
begin

	x_return_status := FND_API.G_RET_STS_SUCCESS;
  	IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  	END IF;
  	if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  	end if;

	while (true) loop

     /* returns the position of first occurence of 'w' */
     iEnd := INSTR(p_comb_string, 'x', iStart);
     if(iEnd = 0)
     then
       exit;
     end if;

     childstr := substr(p_comb_string, iStart, iEnd-iStart);
     iStart := iEnd+1;
     iEnd := INSTR(p_comb_string, 'x', iStart);
     l_revise_existing := substr(p_comb_string,iStart, iEnd-iStart);
     iStart := iEnd+1;
     iEnd := INSTR(p_comb_string, 'w', iStart);
     if(iEnd = 0)
     then
       iEnd := length(p_comb_string) + 1;
     end if;
     l_apply_RCM := substr(p_comb_string, iStart,iEnd-iStart);
     iStart := iEnd + 1;

     l_child_id := to_number(childstr);

     BEGIN
		 SELECT 1 INTO l_dummy
  		 FROM amw_process_organization
		 where process_id = l_child_id
		 and organization_id = p_organization_id
  		 and end_date is null
	  	 and deletion_date is null;

	  EXCEPTION
	  	WHEN no_data_found THEN
			associate_process_to_org (
			p_org_id => p_organization_id,
			p_parent_process_id => p_parent_process_id,
			p_associated_proc_id => l_child_id,
			p_revise_existing => l_revise_existing,
			p_apply_rcm => l_apply_RCM);

			-- update the org counts of the child process and its hierarchy....
			for descendents_rec in c1(l_child_id) loop
    	  		exit when c1%notfound;
    	  		amw_rl_hierarchy_pkg.update_org_count(descendents_rec.process_to_count);
 			end loop;
	END;
   end loop;
exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end add_rl_activities;

PROCEDURE update_latest_denorm_counts
( p_organization_id	    IN NUMBER,
  P_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'update_latest_denorm_counts';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- update the latest denorm hierarchy..
	AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => p_organization_id);
-- Update the Risk Counts..
    upd_ltst_risk_count(p_org_id => p_organization_id, p_process_id => p_process_id);
-- Update the Control Counts..
    upd_ltst_control_count(p_org_id => p_organization_id, p_process_id => p_process_id);


exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END update_latest_denorm_counts;

--******************************************************************************
--  Initialize the Nested Tables used in Synchronize Process to Organization.
--  The NEsted Table holds all the organization Ids.
--******************************************************************************

procedure init is
begin
    Org_Ids := t_Org_Ids();
    Org_Ids.delete;
end init;
-- ****************************************************************************
PROCEDURE sync_proc_org_srs(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
    p_org_range_from		IN varchar2,
    p_org_range_to			IN varchar2,
    p_sync_mode 			in varchar2,
    p_sync_hierarchy 		in varchar2,
    p_sync_attributes 		in varchar2,
    p_sync_rcm 				in varchar2,
    p_sync_people 			in varchar2,
    p_sync_approve 			in varchar2
)
IS
    conc_status             boolean;
    p_mode                  varchar2(5) := 'SYNC';
    L_API_NAME CONSTANT     varchar2(30):= 'sync_proc_org_srs';
    l_return_status	        varchar2(10);
    l_msg_data              varchar2(4000);
    l_msg_count	            number;
    show_warning            boolean:= false;
    l_sync_mode             varchar2(5);
    l_sync_hierarchy        varchar2(3);
    l_sync_attributes       varchar2(3);
    pending_approval_exception exception;

    cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

    cursor c_processes (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;


BEGIN

    IF p_sync_hierarchy = 'N' AND p_sync_attributes = 'N' AND p_sync_rcm = 'RDEF' AND p_sync_people = 'RDEF' THEN
		RETURN;
	END IF;

    IF FND_GLOBAL.User_Id IS NULL THEN
        AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_process_id = -1 OR p_process_id = -2 THEN
        conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: Cannot Associate Root Process');
        RETURN;
    END IF;

    IF p_org_name IS NULL THEN
       	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: No Organization filter found to proceed');
    	RETURN;
    ELSIF p_org_range_from IS NOT NULL and p_org_range_to IS NOT NULL then
        init;
        SELECT  DISTINCT aauv.organization_id
        BULK COLLECT INTO Org_Ids
        FROM    amw_audit_units_v aauv,
                amw_process_organization apo
        WHERE   aauv.organization_id=apo.organization_id
        AND     NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
        AND     apo.process_id=p_process_id
        AND     apo.end_date IS NULL
        AND     apo.deletion_date IS NULL
        AND     aauv.NAME >= p_org_range_from AND substr(aauv.NAME,0,length(p_org_range_to))<= p_org_range_to;
    else
        init;
        select  distinct aauv.organization_id
        BULK COLLECT INTO Org_Ids
        from    amw_audit_units_v aauv,
                amw_process_organization apo
        where aauv.organization_id=apo.organization_id
        and   NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
        and apo.process_id=p_process_id
        and apo.end_date is null
        and apo.deletion_date is null
        and (UPPER(aauv.NAME) LIKE UPPER(p_org_name || '%'));
	end if;

	-- set the sync mode..
	IF p_sync_mode = 'Y' then
		l_sync_mode := 'PSUBP';
	ELSE
		l_sync_mode := 'PONLY';
	END IF;

	-- Set the p_sync_hierarchy
	IF p_sync_hierarchy = 'Y' then

	   l_sync_hierarchy := 'YES' ;
	ELSE

	   l_sync_hierarchy := 'NO' ;
	END IF;

	-- Set the p_sync_attributes
	IF p_sync_attributes = 'Y' then

	   l_sync_attributes := 'YES' ;
    ELSE

	   l_sync_attributes := 'NO' ;
	END IF;

	IF Org_Ids.exists(1)  THEN
	   BEGIN
	       synchronize_process(    p_process_id  => p_process_id,
                                   p_sync_mode   => L_sync_mode,
						           p_sync_hierarchy =>l_sync_hierarchy,
                                   p_sync_attributes => l_sync_attributes,
                                   p_sync_rcm => p_sync_rcm,
                                   p_sync_people => p_sync_people
                               );

            FOR indx IN Org_Ids.FIRST .. Org_Ids.LAST
            LOOP
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
    	        --Ko Update the Proc_org_hierarchy_denorm tables..
                AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id =>Org_Ids(indx));
*/
       	        IF p_sync_approve = 'AUTO' THEN
                    BEGIN
       	                AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(p_process_id, Org_Ids(indx));
       	                AMW_PROC_ORG_APPROVAL_PKG.approve(p_process_id, Org_Ids(indx),FND_API.G_FALSE);
                    EXCEPTION
           	            WHEN OTHERS THEN
          		            show_warning := true;
              		        ROLLBACK;
                	       -- Unapproved object associations exists exception may happen..catche them here..
                	       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
                	       fnd_file.put_line(fnd_file.LOG, ' Error when Approving the process in organization ' ||Org_Ids(indx) );
                	       fnd_file.put_line(fnd_file.LOG, l_msg_data);
                    END;
       	        END IF;
            END LOOP;

            COMMIt;

         EXCEPTION
	     	 when pending_approval_exception then
	     	   show_warning := true;
               ROLLBACK;
	 		   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
               fnd_file.put_line(fnd_file.LOG, ' Error when Synchronizing the process in organization');
               fnd_file.put_line(fnd_file.LOG, l_msg_data);
	      	 when OTHERS then
	     	   show_warning := true;
               ROLLBACK;
	 		   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
               fnd_file.put_line(fnd_file.LOG, ' Error when Synchronizing the process in organization ');
               fnd_file.put_line(fnd_file.LOG, l_msg_data);
        END;

 	    if show_warning then
 	          conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Process cannot be synchronized to some organizations');
        end if;

        IF p_sync_mode = 'Y' or p_sync_hierarchy = 'Y' then

        -- update the org count..
            update amw_process AP
            set AP.org_count = (select  COUNT(o.organization_id)
                                from    hr_all_organization_units o,
                                        hr_organization_information o2,
                                        amw_process_organization APO
                                WHERE   o.organization_id = o2.organization_id
                                AND     APO.organization_id = o.ORGANIZATION_ID
                                and     o2.org_information_context = 'CLASS'
                                and     o2.org_information1 = 'AMW_AUDIT_UNIT'
                                and     o2.org_information2 = 'Y'
                                AND    APO.process_id = AP.PROCESS_ID
                                and    APO.end_date is null
                                and    ( APO.deletion_date is null
                                or
                                    ( APO.deletion_date is not null and APO.approval_date is null)
                                    )
                                ),
                AP.object_version_number = AP.object_version_number + 1,
                AP.last_update_date = sysdate,
                AP.last_updated_by = G_USER_ID,
                AP.last_update_login = G_LOGIN_ID
            where AP.approval_date is not null
            and   AP.approval_end_date is null
            and   AP.process_id <> -1
            and   AP.process_id   IN (  select APHD.parent_child_id process_to_count
                                from   amw_proc_hierarchy_denorm APHD
                                where  APHD.process_id = p_process_id
                                and    APHD.up_down_ind = 'D'
                                and    APHD.hierarchy_type = 'A'
                                union
                                select p_process_id process_to_count from dual
                            );
        END IF;
     END IF;
     commit;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN OTHERS THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
END sync_proc_org_srs;

/** Following 2 functions added by dpatel on 8th Feb, 2006*/
FUNCTION get_latest_conc_request (concur_prog_id number) RETURN NUMBER;
FUNCTION get_concur_program_id (concur_prog_name varchar2) RETURN NUMBER;

FUNCTION get_latest_conc_request (concur_prog_id number) RETURN NUMBER
IS
p_request_id number(15);
BEGIN
    select
      request_id into p_request_id
    from
          fnd_concurrent_requests
    where
          CONCURRENT_PROGRAM_ID = concur_prog_id
          and last_update_date = (select max(last_update_date) from fnd_concurrent_requests where CONCURRENT_PROGRAM_ID = concur_prog_id)
          and phase_code<>'C';
    return p_request_id;
END get_latest_conc_request;

FUNCTION get_concur_program_id (concur_prog_name varchar2) RETURN NUMBER
IS
v_concurrent_program_id number(15);

BEGIN
    select
        concurrent_program_id into v_concurrent_program_id
    from
        fnd_concurrent_programs
    where CONCURRENT_PROGRAM_NAME = concur_prog_name;
    return v_concurrent_program_id;
END get_concur_program_id;
/** Block by dpatel ends */

-- ****************************************************************************
PROCEDURE push_proc_org_no_count(
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_process_id		    IN number,
    p_org_name		        IN varchar2,
    p_org_range_from		IN varchar2,
    p_org_range_to			IN varchar2,
    p_synchronize		    IN varchar2,
    p_apply_rcm			    IN varchar2
)
IS
cursor c1 (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;

cursor c2(pid number, orgName varchar2) is
    select  aauv.organization_id,
    		name
    from    amw_audit_units_v aauv
    where   NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    and     'Y' = AMW_UTILITY_PVT.IS_ORG_REGISTERED(aauv.ORGANIZATION_ID)
    and     aauv.organization_id not in(
                select distinct organization_id
                from amw_process_organization
                where process_id = pid
                and end_date is null
                and (
                    deletion_date is null or
                    (deletion_date is not null and approval_date is null)
                )
            )
    and (UPPER(NAME) LIKE UPPER(orgName));
cursor c3(pid number, rangeFrom varchar2, rangeTo varchar2) is
    select  aauv.organization_id,
    		name
    from    amw_audit_units_v aauv
    where   NVL( AAUV.DATE_TO,SYSDATE ) >= SYSDATE
    and     'Y' = AMW_UTILITY_PVT.IS_ORG_REGISTERED(aauv.ORGANIZATION_ID)
    and     aauv.organization_id not in(
                select distinct organization_id
                from amw_process_organization
                where process_id = pid
                and end_date is null
                and (
                    deletion_date is null or
                    (deletion_date is not null and approval_date is null)
                )
            )
    and NAME >= rangeFrom and substr(NAME,0,length(rangeTo))<= rangeTo;


    conc_status             boolean;
    p_mode                  varchar2(5) := 'ASSOC';
    L_API_NAME CONSTANT     varchar2(30):= 'push_proc_org_no_count';
    l_return_status	        varchar2(10);
    l_msg_data              varchar2(4000);
    l_msg_count	            number;
    p_parent_orgprocess_id  number := -2 ;


cursor c_processes (pid number) is
        select parent_child_id process_to_count
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'A'
        union
        select pid process_to_count from dual;



type t_audit_unit_rec is record (organization_id  amw_audit_units_v.organization_id%type,
                         	   org_name  amw_audit_units_v.name%type);

type t_audit_units_tbl is table of t_audit_unit_rec;
l_audit_units_tbl t_audit_units_tbl;

show_warning boolean:= false;
/* dpatel on 8th Feb, 2006*/
cursor c_current_requests(prog_id number) IS
 select
  request_id, argument1, argument2, argument3, argument4
from
      fnd_concurrent_requests
where
      CONCURRENT_PROGRAM_ID = prog_id
      and last_update_date < (select max(last_update_date) from fnd_concurrent_requests where CONCURRENT_PROGRAM_ID = prog_id)
      and phase_code<>'C';
v_concurrent_program_id integer;
same_request_exception exception;
prior_process_id		    number;
prior_org_name		        varchar2(240);
prior_org_range_from		varchar2(240);
prior_org_range_to			varchar2(240);
p_U_org_name		        varchar2(240);
p_U_org_range_from		varchar2(240);
p_U_org_range_to			varchar2(240);
l_assoc_app_prof            varchar2(1);
BEGIN

    IF FND_GLOBAL.User_Id IS NULL THEN
        AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    if p_process_id = -1 OR p_process_id = -2 then
        conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: Cannot Associate Root Process');
        return;
    end if;
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.push_proc_org_no_count.Begin','BEGIN');
  end if;

/** Following block added by dpatel on 8th Feb, 2006*/
    p_U_org_name := upper(p_org_name);
    p_U_org_range_from := upper(p_org_range_from);
    p_U_org_range_to := upper(p_org_range_to);

    v_concurrent_program_id := get_concur_program_id('AMWASSOCPROCNOCOUNT');

    FOR r_current_requests IN c_current_requests(v_concurrent_program_id) LOOP
        prior_process_id := r_current_requests.argument1;
        prior_org_name := UPPER(r_current_requests.argument2);
        prior_org_range_from := UPPER(r_current_requests.argument3);
        prior_org_range_to := UPPER(r_current_requests.argument4);

      IF p_process_id = prior_process_id THEN
    	if p_U_org_range_from is not null and p_U_org_range_to is not null then
    	   if prior_org_range_from is not null and prior_org_range_to is not null then
    	       if p_U_org_range_from >= prior_org_range_from and p_U_org_range_from <= prior_org_range_to
                    or p_U_org_range_to >= prior_org_range_from and p_U_org_range_to <= prior_org_range_to
                    or p_U_org_range_from <= prior_org_range_from and p_U_org_range_to >= prior_org_range_to
                then
    	           RAISE same_request_exception;
    	       end if;
	       elsif prior_org_name is not null then
    	       if prior_org_name >= p_U_org_range_from and prior_org_name <= p_U_org_range_to then
    	           RAISE same_request_exception;
    	       end if;
    	   end if;
        elsif p_U_org_name is not null then
    	   if prior_org_range_from is not null and prior_org_range_to is not null then
    	       if p_U_org_name >= prior_org_range_from and p_U_org_name <= prior_org_range_to then
    	           RAISE same_request_exception;
    	       end if;
	       elsif prior_org_name is not null then
               if p_U_org_name like prior_org_name ||'%' or prior_org_name like p_U_org_name ||'%' then
	               RAISE same_request_exception;
               end if;
    	   end if;
    	end if;
      END IF;
    END LOOP;
/** Block by dpatel ends */

	if  p_U_org_range_from is not null and p_U_org_range_to is not null then
    	open c3(p_process_id, p_U_org_range_from,p_U_org_range_to);
    	fetch c3 bulk collect into l_audit_units_tbl;
    	close c3;
    elsif p_U_org_name is null then
    	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Warning: No Organization filter found to proceed');
    	return;
    else
    	open c2(p_process_id, p_U_org_name || '%');
    	fetch c2 bulk collect into l_audit_units_tbl;
    	close c2;
	end if;
	if l_audit_units_tbl.exists(1)  then
	   l_assoc_app_prof := fnd_profile.value('AMW_PROC_ORG_ASS_APPRV');
	   IF l_assoc_app_prof = 'Y' THEN
            AMW_UTILITY_PVT.cache_appr_options;
       	   END IF;
    FOR orgid IN l_audit_units_tbl.first .. l_audit_units_tbl.last loop
--    	fnd_file.put_line(fnd_file.LOG, 'Associating to ' || l_audit_units_tbl(orgid).org_name  );
     	push_proc_per_org(
            p_parent_orgprocess_id	=> p_parent_orgprocess_id,
			p_process_id		=> p_process_id,
			p_org_id			=> l_audit_units_tbl(orgid).organization_id,
			p_mode				=> p_mode,
			p_apply_rcm			=> p_apply_rcm,
			p_synchronize		=> p_synchronize,
			p_update_count		=> FND_API.G_FALSE,
			p_commit            => FND_API.G_FALSE,
			x_return_status		=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data);

           	IF l_return_status <> 'S' THEN
           	  show_warning := true;
		      fnd_file.put_line(fnd_file.LOG, 'Error when Associating the process to ' || l_audit_units_tbl(orgid).org_name  );
		      fnd_file.put_line(fnd_file.LOG, l_msg_data );
            ELSE
            -- If user wants the processes to be associated as approved, user should set this profile to Y.
            -- Note that to get the whole hierarchy approved, user needs to set the approval option to
            -- "approve everything down below". Else only the process id passed will be approved.
            -- Although this is not very user friendly, I cannot see an option, as I cannot change the
            -- approval option ad hoc for this association process. When user associates a process,
            -- may be some-subprocess down below is in pending approval status, and that should prevent
            -- modifying the approval option.
            -- Also note that the "Approval Required" parameter for the org will be overridden, if set to yes.
	       	IF fnd_profile.value('AMW_PROC_ORG_ASS_APPRV') = 'Y' THEN
	       		BEGIN
                	AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(p_process_id, l_audit_units_tbl(orgid).organization_id);
                	AMW_PROC_ORG_APPROVAL_PKG.approve(p_process_id, l_audit_units_tbl(orgid).organization_id,FND_API.G_FALSE);
                EXCEPTION
                	WHEN OTHERS THEN
                		show_warning := true;
                		ROLLBACK;
                		-- Unapproved object associations exists exception may happen..catche them here..
                		FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count,p_data => l_msg_data);
                		fnd_file.put_line(fnd_file.LOG, ' Error when Approving the process in organization ' ||l_audit_units_tbl(orgid).org_name  );
                		fnd_file.put_line(fnd_file.LOG, l_msg_data);
                END;
	       	END IF;
	       END IF;
	       -- Done associating...Commit here..
	       COMMIT;
 	END LOOP;
 	if show_warning then
 	  conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','Process cannot be associated to some organizations');
    end if;
	AMW_UTILITY_PVT.unset_appr_cache;
  END IF;
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'amw.plsql.AMW_ORG_HIERARCHY_PKG.push_proc_org_no_count.End','END');
  end if;
  COMMIT;
EXCEPTION
 WHEN same_request_exception THEN
    fnd_file.put_line(fnd_file.LOG, 'ERROR:'|| SQLERRM);
    conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
    'There is already a concurrent process running for a similar process id.'||
    'This concurrent request is also being run with the same value for parameter "Process id" '||
    ' and the parameter "Organization Name or Range" that the earlier concurrent program is running with. '
    );
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

  WHEN OTHERS THEN
    ROLLBACK;
	retcode := 2;
	errbuf  := SUBSTR(SQLERRM,1,1000);
	conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
END push_proc_org_no_count;

end AMW_ORG_HIERARCHY_PKG;

/
