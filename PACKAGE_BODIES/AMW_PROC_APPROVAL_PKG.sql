--------------------------------------------------------
--  DDL for Package Body AMW_PROC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROC_APPROVAL_PKG" as
/*$Header: amwapprb.pls 120.3 2006/04/04 09:15:14 appldev noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROC_APPROVAL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwapprb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- process submitted for approval
-- change status to PA and lock subprocesses
--NPANANDI 11.26.2004, ADDED P_WEBADI_CALL PARAMETER
--BECAUSE WHEN THIS IS CALLED FROM WEBADI, WE DON'T WANT TO CALL
--CHECK_HIER_APPROVED PROCEDURE
procedure sub_for_approval (
   p_process_id in number
  ,p_webadi_call in varchar2 := NULL) is
approv_choice varchar2(10);
dummy1 varchar2(1);
dummy2 varchar2(1000);
begin

-- get the approval parameter for risk library
    approv_choice := amw_utility_pvt.get_parameter(-1, 'PROCESS_APPROVAL_OPTION');

-- error out if at least one risk or control associated with this process
-- does not have any approved revision.
    prod_err_unapr_obj_ass_ex (p_process_id, approv_choice, 'Y', dummy1, dummy2);

-- assuming that the process is in Draft status, otherwise you can't submit it for approval.
    update amw_process
    set approval_status = 'PA'
    where process_id = p_process_id
    and end_date is null;

-- approval choice cases:
-- (1) approve everything below
--          lock the process and all processes below,
--          note that the status of the downward processes do not change
-- (2) approve the process independently
--          lock only the process and its children
-- (3) don't approve unless everything below is approved.
--          same as (1)

    insert into amw_process_locks
    (organization_id,
    locking_process_id,
    locked_process_id,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    object_version_number)
    values
    (
    -1,
    p_process_id,
    p_process_id,
    sysdate,
    G_USER_ID,
    G_LOGIN_ID,
    sysdate,
    G_USER_ID,
    1
    );

    if (approv_choice = 'B') then

        insert into amw_process_locks
        (organization_id,
        locking_process_id,
        locked_process_id,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	object_version_number)
        (select -1, p_process_id, parent_child_id, sysdate, G_USER_ID, G_LOGIN_ID,
sysdate, G_USER_ID, 1
        from amw_proc_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L');

    elsif (approv_choice = 'A') then

        insert into amw_process_locks
        (organization_id,
        locking_process_id,
        locked_process_id,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	object_version_number)
        (select -1, p_process_id, child_process_id, sysdate, G_USER_ID, G_LOGIN_ID,
sysdate, G_USER_ID, 1
        from amw_latest_hierarchy_rl_v
        where parent_process_id = p_process_id);

    elsif (approv_choice = 'C') then

	    --NPANANDI 11.26.2004, ADDED P_WEBADI_CALL PARAMETER
		--BECAUSE WHEN THIS IS CALLED FROM WEBADI, WE DON'T WANT TO CALL
		--CHECK_HIER_APPROVED PROCEDURE
	    IF(P_WEBADI_CALL IS NULL) THEN
           check_hier_approved(p_process_id);
		END IF;

        insert into amw_process_locks
        (organization_id,
        locking_process_id,
        locked_process_id,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	object_version_number)
        (select -1, p_process_id, parent_child_id,  sysdate, G_USER_ID, G_LOGIN_ID,
sysdate, G_USER_ID, 1
        from amw_proc_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L');
    end if;

end sub_for_approval;


-- process approved: update amw_process, change status to A
-- unlock process(es)
-- write into amw_approved_hierarchy
-- update the association_tables
-- update amw_proc_hierarchy_denorm table where hierarchy_type = 'A'
procedure approve(p_process_id in number) is

rev_num number;
approv_choice varchar2(10);
curr_app_status  varchar2(10);

 cursor c1 (p_process_id number) is
/*
 * ko .. We need to update only draft children
 * select parent_child_id
        from amw_proc_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L';
*/
	select ah.parent_child_id
        from amw_proc_hierarchy_denorm ah,
            amw_process ap
        where ah.process_id = p_process_id
        and ah.up_down_ind = 'D'
        and ah.hierarchy_type = 'L'
        and ah.parent_child_id = ap.process_id
        and ap.end_date is null
        and ap.approval_date is null;

 c1_rec c1%rowtype;

begin

    APPROV_TXN_DATE := sysdate;
-- check if the process is already approved, in that case, return
    select approval_status
    into curr_app_status
    from amw_process
    where process_id = p_process_id
    and end_date is null;

    if curr_app_status = 'A' then
        return;
    end if;


-- release locks
    approv_choice := amw_utility_pvt.get_parameter(-1, 'PROCESS_APPROVAL_OPTION');

    delete from amw_process_locks
    where organization_id = -1
    and locking_process_id = p_process_id;

    update amw_process
    set approval_status = 'A',
    approval_date = APPROV_TXN_DATE
    where process_id = p_process_id
    and end_date is null
    returning revision_number into rev_num;

    if rev_num > 1 then
        update amw_process
        set approval_end_date = APPROV_TXN_DATE
        where process_id = p_process_id
        and revision_number = (rev_num-1);
    end if;


    --kosriniv ..Need to update the org count...
    AMW_RL_HIERARCHY_PKG.update_org_count(p_process_id => p_process_id);
    approve_associations(p_process_id);
    write_approved_hierarchy(p_process_id, 2);


    if (approv_choice = 'B') then

      for c1_rec in c1(p_process_id) loop
    	  exit when c1%notfound;
                update amw_process
                set approval_status = 'A',
                approval_date = APPROV_TXN_DATE
                where process_id = c1_rec.parent_child_id
                and end_date is null
                returning revision_number into rev_num;

                if rev_num > 1 then
                    update amw_process
                    set approval_end_date = APPROV_TXN_DATE
                    where process_id = c1_rec.parent_child_id
                    and revision_number = (rev_num-1);
                end if;
		--kosriniv ..Need to update the org count...
		AMW_RL_HIERARCHY_PKG.update_org_count(p_process_id => c1_rec.parent_child_id );
                approve_associations(c1_rec.parent_child_id);
                write_approved_hierarchy(p_process_id, 2);
      end loop;

    end if;

    write_approved_hierarchy(p_process_id, 1);
    amw_rl_hierarchy_pkg.update_approved_denorm(-1);
    amw_rl_hierarchy_pkg.update_appr_control_counts;
    amw_rl_hierarchy_pkg.update_appr_risk_counts;

end approve;


-- process approval rejected
-- change status D and unlock
procedure reject (p_process_id in number) is

begin
    update amw_process
    set approval_status = 'D'
    where process_id = p_process_id
    and end_date is null;

    delete from amw_process_locks
    where organization_id = -1
    and locking_process_id = p_process_id;

end reject;


-- check that all processes below are approved, else produce error
procedure check_hier_approved(p_process_id in number) is

unappr_xst_excpt exception;
err_msg varchar2(4000);
l_dummy number;

begin

    begin
        select 1 --parent_child_id, a.approval_status
        into l_dummy
        from amw_proc_hierarchy_denorm d, amw_process a
        where d.process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and a.process_id = d.parent_child_id
        and a.end_date is null
        and a.approval_status <> 'A';

        raise unappr_xst_excpt;
    exception
        when no_data_found then
            null;

        when too_many_rows then
            raise unappr_xst_excpt;
    end;

exception

    when unappr_xst_excpt then
         rollback;
         fnd_message.set_name('AMW','AMW_UNAPPROV_PROC_DOWN');
         err_msg := fnd_message.get;
         fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'amw_proc_approval_pkg',
                   	     p_procedure_name =>   'check_hier_approved',
  	                     p_error_text => err_msg);
         raise;

end check_hier_approved;


procedure approve_associations(p_process_id in number) is

begin
    update amw_risk_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and approval_date is null;

    update amw_risk_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_control_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'RISK'
    and approval_date is null;

    update amw_control_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'RISK'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_acct_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and approval_date is null;

    update amw_acct_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_objective_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type in ('PROCESS', 'CONTROL')
    and approval_date is null;

    update amw_objective_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type in ('PROCESS', 'CONTROL')
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_significant_elements
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and approval_date is null;

    update amw_significant_elements
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS'
    and deletion_date is not null
    and deletion_approval_date is null;

end approve_associations;



-- this procedure has three steps, for execution of three cursors that are explained below.
procedure write_approved_hierarchy(
   p_process_id in number,
   p_step in number) is

            -- "approved" links that are in the latest hierarchy but not in the approved
            -- hierarchy => links to be transferred to the approved hierarchy.
            -- the assumption is that we do not manipulate the order_number data,
            -- i.e. we faithfully store the exact number the sequence generates or user enters
            -- and copy that number to the approved hierarchy.
            -- executed when step = 1
            CURSOR c1 is
               (select parent_process_id,
			           child_process_id,
					   child_order_number
                  from (select *
				          from amw_latest_hierarchy_rl_v
						 where parent_approval_status = 'A'
						   and child_approval_status = 'A')
                  start with parent_process_id = -1
                connect by prior child_process_id = parent_process_id)
                MINUS
                (select parent_process_id,
				        child_process_id,
						child_order_number
				   from AMW_CURR_APP_HIERARCHY_RL_V);

            -- these links must be deleted from the approved hierarchy
            -- executed when step = 2
			CURSOR c2 is
			 (select parent_process_id,
			         child_process_id
			    from AMW_CURR_APP_HIERARCHY_RL_V
			   where parent_process_id = p_process_id)
			 MINUS
			 (select parent_process_id,
			         child_process_id
				from amw_latest_hierarchy_rl_v
			   where parent_process_id = p_process_id);


			-- 05.11.2005 npanandi: added below cursor for WebADI call
			-- c2_1 is the same as c2 above, exception that it does not
			-- take pProcessId as a bind variable
			CURSOR c2_1 is
			 (select parent_process_id,
			         child_process_id
			    from AMW_CURR_APP_HIERARCHY_RL_V)
			 MINUS
			 (select parent_process_id,
			         child_process_id
				from amw_latest_hierarchy_rl_v);


			-- as a result of the children being removed in c2 some links may become
            -- defunct in the approved hierarchy ... we must remove those links
            -- executed when step = 1
			CURSOR c3 is
			  (select parent_process_id,
			          child_process_id
				 from AMW_CURR_APP_HIERARCHY_RL_V
                where parent_process_id is not null)
			  MINUS
			  (select parent_process_id,
			          child_process_id
				 from AMW_CURR_APP_HIERARCHY_RL_V
			    start with parent_process_id = -1
			  connect by prior child_process_id = parent_process_id);
BEGIN
   if ( (p_step = 1) or (p_step = 0) ) then
      for a_link in c1 loop
         insert into amw_approved_hierarchies(
		    organization_id,
			parent_id,
			child_id,
			start_date,
			child_order_number,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			CREATION_DATE,
			CREATED_BY,
			object_version_number
		 )values(
		    -1,
			a_link.parent_process_id,
			a_link.child_process_id,
			APPROV_TXN_DATE,
			a_link.child_order_number,
			sysdate,
			G_USER_ID,
			G_LOGIN_ID,
			sysdate,
			G_USER_ID,
			1
		 );
      end loop;
   end if;

   if p_step = 2 then
      for defunct_link in c2 loop
		 update amw_approved_hierarchies
		    set end_date = APPROV_TXN_DATE,
		        object_version_number = object_version_number + 1
		  where organization_id = -1
		    and parent_id = defunct_link.parent_process_id
		    and child_id = defunct_link.child_process_id
		    and end_date is null;
      end loop;
   end if;

   if ( (p_step = 1) or (p_step = 3) ) then
      for defunct_link in c3 loop
         update amw_approved_hierarchies
			set end_date = APPROV_TXN_DATE,
			    object_version_number = object_version_number + 1
		  where organization_id = -1
			and parent_id = defunct_link.parent_process_id
			and child_id = defunct_link.child_process_id
			and end_date is null;
      end loop;
   end if;

   ---05.11.2005 npanandi: added below step to club the above actions
   ---when calling this procedure from WebADI
   if(p_step=4) then
      for a_link in c1 loop
         insert into amw_approved_hierarchies(
		    organization_id,
			parent_id,
			child_id,
			start_date,
			child_order_number,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			CREATION_DATE,
			CREATED_BY,
			object_version_number
		 )values(
		    -1,
			a_link.parent_process_id,
			a_link.child_process_id,
			APPROV_TXN_DATE,
			a_link.child_order_number,
			sysdate,
			G_USER_ID,
			G_LOGIN_ID,
			sysdate,
			G_USER_ID,
			1
		 );
      end loop;

	  for defunct_link in c2_1 loop
		 update amw_approved_hierarchies
		    set end_date              = APPROV_TXN_DATE
		       ,object_version_number = object_version_number + 1
			   ,last_update_date      = sysdate
			   ,last_updated_by       = G_USER_ID
			   ,last_update_login     = G_LOGIN_ID
		  where organization_id = -1
		    and parent_id = defunct_link.parent_process_id
		    and child_id = defunct_link.child_process_id
		    and end_date is null;
      end loop;

	  for defunct_link in c3 loop
         update amw_approved_hierarchies
			set end_date              = APPROV_TXN_DATE,
			    object_version_number = object_version_number + 1
			   ,last_update_date      = sysdate
			   ,last_updated_by       = G_USER_ID
			   ,last_update_login     = G_LOGIN_ID
		  where organization_id = -1
			and parent_id = defunct_link.parent_process_id
			and child_id = defunct_link.child_process_id
			and end_date is null;
      end loop;
   end if; --end of check for step = 4
end write_approved_hierarchy;


procedure prod_err_unapr_obj_ass_ex (p_process_id in number,
                                     approve_option in varchar2,
                                     raise_ex in varchar2,
                                     p_result out nocopy varchar2,
                                     p_out_mesg out nocopy varchar2 ) is

cursor process_list (pid number) is
        select parent_child_id
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        union
        select pid from dual;

cursor ass_risks (pid number) is
    select risk_id from amw_risk_associations where pk1 = pid and object_type = 'PROCESS';

cursor ass_controls (pid number) is
    select control_id from amw_control_associations where pk1 = pid and object_type = 'RISK';

l_dummy number;
unappr_obj_exception  exception;
err_msg varchar2(4000);

begin

    p_result := 'Y';
    p_out_mesg := null;

    if approve_option = 'B' then

   			for process_list_rec in process_list(p_process_id) loop

    			for ass_risks_rec in ass_risks(process_list_rec.parent_child_id) loop

                    begin
                        select 1
                        into l_dummy
                        from amw_risks_b
                        where risk_id = ass_risks_rec.risk_id
                        and approval_status = 'A';

                    exception
                        when too_many_rows then
                                null;
                        when no_data_found then
                                raise unappr_obj_exception;
                    end;

    			end loop;


    			for ass_controls_rec in ass_controls(process_list_rec.parent_child_id) loop

                    begin
                        select 1
                        into l_dummy
                        from amw_controls_b
                        where control_id = ass_controls_rec.control_id
                        and approval_status = 'A';

                    exception
                        when too_many_rows then
                                null;
                        when no_data_found then
                                raise unappr_obj_exception;
                    end;

    			end loop;

            end loop;
    else
    			for ass_risks_rec in ass_risks(p_process_id) loop

                    begin
                        select 1
                        into l_dummy
                        from amw_risks_b
                        where risk_id = ass_risks_rec.risk_id
                        and approval_status = 'A';

                    exception
                        when too_many_rows then
                                null;
                        when no_data_found then
                                raise unappr_obj_exception;
                    end;

    			end loop;


    			for ass_controls_rec in ass_controls(p_process_id) loop

                    begin
                        select 1
                        into l_dummy
                        from amw_controls_b
                        where control_id = ass_controls_rec.control_id
                        and approval_status = 'A';

                    exception
                        when too_many_rows then
                                null;
                        when no_data_found then
                                raise unappr_obj_exception;
                    end;

    			end loop;

    end if;

exception

    when unappr_obj_exception then
         fnd_message.set_name('AMW','AMW_UNAPPRV_ASSOC');
         err_msg := fnd_message.get;
         if raise_ex = 'Y' then
             fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'AMW_PROC_APPROVAL_PKG',
                   	     p_procedure_name =>   'prod_err_unapr_obj_ass_ex',
  	                     p_error_text => err_msg);
             raise;
         else
             p_result := 'N';
             p_out_mesg := err_msg;
         end if;

end prod_err_unapr_obj_ass_ex;



procedure autoapprove(
p_process_id            in number,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 )

is

L_API_NAME CONSTANT VARCHAR2(30) := 'autoapprove';
l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    sub_for_approval (p_process_id);
    approve(p_process_id);

exception

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count =>
x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count =>
x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,
p_data => x_msg_data);

end autoapprove;


-- check that all processes below are approved, else produce error
-- overloaded so as not to produce an expection
procedure check_hier_approved(p_process_id in number,
                              p_result out nocopy varchar2,
                              p_out_mesg out nocopy varchar2) is

unappr_xst_excpt exception;
err_msg varchar2(4000);
l_dummy number;

begin
    p_result := 'Y';
    p_out_mesg := null;
    begin
        select 1 --parent_child_id, a.approval_status
        into l_dummy
        from amw_proc_hierarchy_denorm d, amw_process a
        where d.process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and a.process_id = d.parent_child_id
        and a.end_date is null
        and a.approval_status <> 'A';

        raise unappr_xst_excpt;
    exception
        when no_data_found then
            null;

        when too_many_rows then
            raise unappr_xst_excpt;
    end;

exception

    when unappr_xst_excpt then
         fnd_message.set_name('AMW','AMW_UNAPPROV_PROC_DOWN');
         err_msg := fnd_message.get;
         p_result := 'N';
         p_out_mesg := err_msg;

end check_hier_approved;

--port
/*
Produce error if:
1. approval option says "Don't approve this unless everything below is approved". There's at least one process below that is NOT approved.
2. there's at least one risk associated (to this process / any process in the downward hierarchy, depending on the approval option) that does not have an approved revision.
3. there's at least one control associated (to this process / any process in the downward hierarchy, depending on the approval option) that does not have an approved revision.
4. the process is non-standard, and the standard variation does not have an approved revision.
5. the process is non-standard and the list of children in the latest hierarchy is not the same as the list of children recorded in the variations table.
*/
procedure check_approval_subm_eligib(
p_process_id            in number,
p_result                out nocopy varchar2,
p_out_mesg              out nocopy varchar2,
p_commit			    in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			    out nocopy number,
x_msg_data			    out nocopy varchar2 )

is

L_API_NAME CONSTANT VARCHAR2(30) := 'check_approval_subm_eligib';
l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
approv_choice  varchar2(1);
std_process varchar2(1);
st_var_pid number;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    p_result := 'Y';
    p_out_mesg := null;

    approv_choice := amw_utility_pvt.get_parameter(-1, 'PROCESS_APPROVAL_OPTION');

    if (approv_choice = 'C') then
          check_hier_approved(p_process_id, p_result, p_out_mesg);
          if p_result = 'N' then
            return;
          end if;
    end if;

    prod_err_unapr_obj_ass_ex (p_process_id, approv_choice, 'N', p_result, p_out_mesg);
    if p_result = 'N' then
        return;
    end if;

    prod_err_unappr_nsvar (p_process_id, approv_choice, p_result, p_out_mesg);
    if p_result = 'N' then
        return;
    end if;

    prod_err_modified_nschildlist (p_process_id, approv_choice, p_result, p_out_mesg);
    if p_result = 'N' then
        return;
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

end check_approval_subm_eligib;



procedure prod_err_unappr_nsvar(p_process_id in number,
                                approve_option in varchar2,
                                p_result out nocopy varchar2,
                                p_out_mesg out nocopy varchar2) is

cursor process_list (pid number) is
        select parent_child_id
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        union
        select pid from dual;

std_process varchar2(1);
st_var_pid number;
l_dummy number;

begin
    -- standard variation treatment
    -- I could probably have made good use for cursor variables here

if approve_option = 'B' then
    for process_list_rec in process_list(p_process_id) loop

	begin

        select a.standard_process_flag, b.process_id
        into std_process, st_var_pid
        from amw_process a, amw_process b
        where a.process_id = process_list_rec.parent_child_id
        and a.end_date is null
        and b.process_rev_id = a.standard_variation;

	exception
		when no_data_found then --process is standard/non-std but no var defined
			std_process := 'Y';
	end;

        if std_process = 'N' then -- if process is non-standard
            begin
                select 1
                into l_dummy
                from amw_process
                where process_id = st_var_pid
                and approval_status = 'A';

            exception
                when too_many_rows then
                     null;

                when no_data_found then
                     fnd_message.set_name('AMW','AMW_NS_VAR_UNAPPROVED');
                     p_out_mesg := fnd_message.get;
                     p_result := 'N';
                     return;
            end;
        end if;  -- if process is non-standard

    end loop;
else
    begin
    select a.standard_process_flag, b.process_id
    into std_process, st_var_pid
    from amw_process a, amw_process b
    where a.process_id = p_process_id
    and a.end_date is null
    and b.process_rev_id = a.standard_variation;
    exception
	when no_data_found then --process is standard/non-std but no var defined
			std_process := 'Y';
    end;

    if std_process = 'N' then -- if process is non-standard

    begin
        select 1
        into l_dummy
        from amw_process
        where process_id = st_var_pid
        and approval_status = 'A';

    exception
        when too_many_rows then
             null;

        when no_data_found then
             fnd_message.set_name('AMW','AMW_NS_VAR_UNAPPROVED');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;
    end;

    end if;  -- if process is non-standard

end if;

end prod_err_unappr_nsvar;


procedure prod_err_modified_nschildlist(p_process_id in number,
                                        approve_option in varchar2,
                                        p_result out nocopy varchar2,
                                        p_out_mesg out nocopy varchar2) is

cursor process_list (pid number) is
        select parent_child_id
        from amw_proc_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        union
        select pid from dual;

std_process varchar2(1);
l_std_variation amw_process.STANDARD_VARIATION%TYPE;
l_dummy number;

begin
    -- standard variation treatment
    -- I could probably have made good use for cursor variables here

if approve_option = 'B' then
    for process_list_rec in process_list(p_process_id) loop

    select standard_process_flag,standard_variation
    into std_process,l_std_variation
    from amw_process
    where process_id = process_list_rec.parent_child_id
    and end_date is null;

    if std_process = 'N'  and l_std_variation is not null then

    begin
        select parent_child_id
        into l_dummy
        from amw_proc_hierarchy_denorm
        where process_id = process_list_rec.parent_child_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and parent_child_id not in
            (select NON_STD_CHILD_ID
            from AMW_NONSTANDARD_VARIATIONS_B
            where NON_STD_PROCESS_ID = process_list_rec.parent_child_id
            and NON_STD_PROCESS_REV_NUM = (select revision_number
                                           from amw_process
                                           where process_id = process_list_rec.parent_child_id
                                           and end_date is null)
            and END_DATE is null);

             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;

    exception
        when no_data_found then
            null;

        when too_many_rows then
             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;
    end;

    begin
        select NON_STD_CHILD_ID
        into l_dummy
        from AMW_NONSTANDARD_VARIATIONS_B
        where NON_STD_PROCESS_ID = process_list_rec.parent_child_id
        and NON_STD_PROCESS_REV_NUM = (select revision_number
                                       from amw_process
                                       where process_id = process_list_rec.parent_child_id
                                       and end_date is null)
        and END_DATE is null
        and NON_STD_CHILD_ID not in
                (select parent_child_id
                from amw_proc_hierarchy_denorm
                where process_id = process_list_rec.parent_child_id
                and up_down_ind = 'D'
                and hierarchy_type = 'L');

             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;

    exception
        when no_data_found then
            null;

        when too_many_rows then
             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;
    end;

    end if;  -- if process is non-standard

    end loop;
else
    select standard_process_flag,standard_variation
    into std_process,l_std_variation
    from amw_process
    where process_id = p_process_id
    and end_date is null;

    if std_process = 'N' and l_std_variation is not null then

    begin
        select parent_child_id
        into l_dummy
        from amw_proc_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and parent_child_id not in
            (select NON_STD_CHILD_ID
            from AMW_NONSTANDARD_VARIATIONS_B
            where NON_STD_PROCESS_ID = p_process_id
            and NON_STD_PROCESS_REV_NUM = (select revision_number
                                           from amw_process
                                           where process_id = p_process_id
                                           and end_date is null)
            and END_DATE is null);

             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;

    exception
        when no_data_found then
            null;

        when too_many_rows then
             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;
    end;

    begin
        select NON_STD_CHILD_ID
        into l_dummy
        from AMW_NONSTANDARD_VARIATIONS_B
        where NON_STD_PROCESS_ID = p_process_id
        and NON_STD_PROCESS_REV_NUM = (select revision_number
                                       from amw_process
                                       where process_id = p_process_id
                                       and end_date is null)
        and END_DATE is null
        and NON_STD_CHILD_ID not in
                (select parent_child_id
                from amw_proc_hierarchy_denorm
                where process_id = p_process_id
                and up_down_ind = 'D'
                and hierarchy_type = 'L');

             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;

    exception
        when no_data_found then
            null;

        when too_many_rows then
             fnd_message.set_name('AMW','AMW_NS_CHILDLIST_DIFF');
             p_out_mesg := fnd_message.get;
             p_result := 'N';
             return;
    end;

    end if;  -- if process is non-standard

end if; -- approval option B

end prod_err_modified_nschildlist;

---05.11.2005 npanandi: added below procedure for handling
---webadi approvals
procedure webadi_approve(
   p_process_id in number
  ,p_approv_choice in varchar2)
is
   rev_num number;
   approv_choice varchar2(10);
   curr_app_status  varchar2(10);

   dummy1 varchar2(1);
   dummy2 varchar2(1000);

   cursor c1 (p_process_id number) is
      select parent_child_id
        from amw_proc_hierarchy_denorm
       where process_id = p_process_id
         and up_down_ind = 'D'
         and hierarchy_type = 'L';
   c1_rec c1%rowtype;
begin
   -- error out if at least one risk or control associated with this process
   -- does not have any approved revision.
   prod_err_unapr_obj_ass_ex (p_process_id,p_approv_choice,'Y',dummy1,dummy2);


   APPROV_TXN_DATE := sysdate;
   -- check if the process is already approved, in that case, return
   select approval_status
     into curr_app_status
     from amw_process
    where process_id = p_process_id
      and end_date is null;

   if curr_app_status = 'A' then
      return;
   end if;

   /**
   delete from amw_process_locks
    where organization_id = -1
      and locking_process_id = p_process_id;
	  **/

   update amw_process
      set approval_status = 'A',
          approval_date = APPROV_TXN_DATE
    where process_id = p_process_id
      and end_date is null
   returning revision_number into rev_num;

   if rev_num > 1 then
      update amw_process
         set approval_end_date = APPROV_TXN_DATE
       where process_id = p_process_id
         and revision_number = (rev_num-1);
   end if;

    --kosriniv ..Need to update the org count...
    AMW_RL_HIERARCHY_PKG.update_org_count(p_process_id => p_process_id);

   approve_associations(p_process_id);
   ---05.11.2005 npanandi: per Amit, not needed here, since we will be calling
   ---write_approved_hierarchy with step # = 4
   ---write_approved_hierarchy(p_process_id, 2);


   if (p_approv_choice = 'B') then
      for c1_rec in c1(p_process_id) loop
      exit when c1%notfound;
         update amw_process
            set approval_status = 'A',
                approval_date = APPROV_TXN_DATE
          where process_id = c1_rec.parent_child_id
            and end_date is null
         returning revision_number into rev_num;

         if rev_num > 1 then
            update amw_process
               set approval_end_date = APPROV_TXN_DATE
             where process_id = c1_rec.parent_child_id
               and revision_number = (rev_num-1);
         end if;

	    --kosriniv ..Need to update the org count...
	 AMW_RL_HIERARCHY_PKG.update_org_count(p_process_id => c1_rec.parent_child_id);

         approve_associations(c1_rec.parent_child_id);
		 ---05.11.2005 npanandi: per Amit, not needed here, since we will be calling
         ---write_approved_hierarchy with step # = 4
         ---write_approved_hierarchy(p_process_id, 2);
      end loop;
   end if;


   ---05.11.2005 npanandi: calling this once from the main API, hence
   ---commenting out here
   /**
   write_approved_hierarchy(p_process_id, 1);
   amw_rl_hierarchy_pkg.update_approved_denorm(-1);
   amw_rl_hierarchy_pkg.update_appr_control_counts;
   amw_rl_hierarchy_pkg.update_appr_risk_counts;
   **/
end webadi_approve;


end AMW_PROC_APPROVAL_PKG;

/
