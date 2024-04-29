--------------------------------------------------------
--  DDL for Package Body AMW_PROC_ORG_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROC_ORG_APPROVAL_PKG" as
/*$Header: amwapogb.pls 120.3.12000000.4 2007/04/26 18:26:06 npanandi ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROC_APPROVAL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwapogb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;




procedure init is
begin

  x_index_tbl.delete;
  x_t1.delete;
  x_t2.delete;

end init;



-- process submitted for approval
-- change status to PA and lock subprocesses
procedure sub_for_approval (p_process_id in number, p_org_id in number) is
approv_choice varchar2(10);
dummy1 varchar2(1);
dummy2 varchar2(1000);

begin

-- get the approval parameter for risk library
    approv_choice := amw_utility_pvt.get_parameter(p_org_id, 'PROCESS_APPROVAL_OPTION');

-- error out if at least one risk or control associated with this process
-- does not have any approved revision.
    prod_err_unapr_obj_ass_ex (p_process_id, p_org_id, approv_choice, 'Y', dummy1, dummy2);

-- assuming that the process is in Draft status, otherwise you can't submit it for approval.
    update amw_process_organization
    set approval_status = 'PA'
    where process_id = p_process_id
    and organization_id = p_org_id
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
    object_version_number
    )
    values
    (
    p_org_id,
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
	object_version_number
	)
		(select distinct p_org_id, p_process_id, child_id, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1
 				 from amw_latest_hierarchies
 				 start with parent_id = p_process_id and organization_id = p_org_id
 					connect by prior child_id = parent_id and organization_id = p_org_id   );
--ko replacing the below clause...
/*        (select p_org_id, p_process_id, parent_child_id, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1
        from amw_org_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and organization_id = p_org_id
        and hierarchy_type = 'L');
*/
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
	object_version_number
	)
        (select p_org_id, p_process_id, child_process_id, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1
        from amw_latest_hierarchy_ORG_V
        where parent_process_id = p_process_id
        and child_organization_id = p_org_id);

    elsif (approv_choice = 'C') then

        check_hier_approved(p_process_id, p_org_id);

        insert into amw_process_locks
        (organization_id,
        locking_process_id,
        locked_process_id,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	object_version_number
	)(select distinct p_org_id, p_process_id, child_id, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1
 				 from amw_latest_hierarchies
 				 start with parent_id = p_process_id and organization_id = p_org_id
 					connect by prior child_id = parent_id and organization_id = p_org_id   );
--ko replacing the below clause...
/*       (select p_org_id, p_process_id, parent_child_id, sysdate, G_USER_ID, G_LOGIN_ID, sysdate, G_USER_ID, 1
        from amw_org_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and organization_id = p_org_id
        and hierarchy_type = 'L');
*/
    end if;

end sub_for_approval;


-- process approved: update amw_process, change status to A
-- unlock process(es)
-- write into amw_approved_hierarchies
-- update the association_tables
-- update amw_proc_hierarchy_denorm table where hierarchy_type = 'A'
procedure approve(p_process_id in number, p_org_id in number,
							p_update_count	in varchar2 := FND_API.G_TRUE) is

rev_num number;
approv_choice varchar2(10);
curr_app_status  varchar2(10);

 cursor c1 (p_process_id number, p_org_id number) is
 				select distinct child_id parent_child_id
 				from amw_latest_hierarchies
 				start with parent_id = p_process_id and organization_id = p_org_id
 				connect by prior child_id = parent_id and organization_id = p_org_id;

cursor c2 (p_process_id number, p_org_id number) is
        select distinct child_id parent_child_id,parent_id
        from amw_latest_hierarchies
        start with parent_id = p_process_id and organization_id = (-1*p_org_id)
        connect by prior child_id = parent_id and organization_id = (-1*p_org_id);


--ko replacing the below clause...
/*        select parent_child_id
        from amw_org_hierarchy_denorm
        where process_id = p_process_id
        and up_down_ind = 'D'
        and organization_id = p_org_id
        and hierarchy_type = 'L';
*/
 c1_rec c1%rowtype;
 c2_rec c2%rowtype;
 pex varchar2(1);

begin

    APPROV_TXN_DATE := sysdate;
-- check if the process is already approved, in that case, return
    select approval_status
    into curr_app_status
    from amw_process_organization
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null;

    if curr_app_status = 'A' then
        return;
    end if;


-- release locks
    approv_choice := amw_utility_pvt.get_parameter(p_org_id,  'PROCESS_APPROVAL_OPTION' );

    delete from amw_process_locks
    where organization_id = p_org_id
    and locking_process_id = p_process_id;

    update amw_process_organization
    set approval_status = 'A',
    approval_date = APPROV_TXN_DATE
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null
    returning revision_number into rev_num;

    if rev_num > 1 then
        update amw_process_organization
        set approval_end_date = APPROV_TXN_DATE
        where process_id = p_process_id
        and organization_id = p_org_id
        and revision_number = (rev_num-1);
    end if;

    approve_associations(p_process_id, p_org_id);
    write_approved_hierarchy(p_process_id, 2, p_org_id);
    -- kosriniv.. Approve the Exceptions..
    approve_exceptions(p_org_id, p_process_id);
    IF p_update_count = FND_API.G_TRUE THEN
	-- Now updat the Org Count......
	amw_rl_hierarchy_pkg.update_org_count(p_process_id);
	END IF;

        /**04.26.2007 npanandi: fix for bug 6017644, the below was not properly
           commented out, leading to compilation errors
         **/
	--change for bug fix 5671087 starts here
     pex := AMW_ORG_HIERARCHY_PKG.does_process_exist_in_org(p_process_id, p_org_id);


 if (pex = 'D' and approv_choice = 'B') then

      for c2_rec in c2(p_process_id, p_org_id) loop
        exit when c2%notfound;

                update amw_process_organization
                set approval_status = 'A',
                approval_date = APPROV_TXN_DATE
                where process_id = c2_rec.parent_child_id
                and organization_id = p_org_id
                and end_date is null
                returning revision_number into rev_num;

                if rev_num > 1 then
                    update amw_process_organization
                    set approval_end_date = APPROV_TXN_DATE
                    where process_id = c2_rec.parent_child_id
                    and organization_id = p_org_id
                    and revision_number = (rev_num-1);
                end if;

                approve_associations(c2_rec.parent_child_id, p_org_id);
                write_approved_hierarchy(c2_rec.parent_child_id, 2, p_org_id);
                IF p_update_count = FND_API.G_TRUE THEN
                -- Update the Org Count
                amw_rl_hierarchy_pkg.update_org_count(c2_rec.parent_child_id);
                END IF;

               delete from amw_latest_hierarchies
               where child_id  = c2_rec.parent_child_id
               and parent_id = c2_rec.parent_id
               and organization_id = -p_org_id;



      end loop;
    write_approved_hierarchy(p_process_id,0 , p_org_id);

    IF p_update_count = FND_API.G_TRUE THEN
    amw_org_hierarchy_pkg.upd_appr_control_count(p_org_id, null); --ko, commenting this.. -2);
    amw_org_hierarchy_pkg.upd_appr_risk_count(p_org_id, null); --ko the count api is currently aggregating in the upward direction -2);
    END IF;

    return;

   end if;




--change for bug fix 5671087 ends here


    if (approv_choice = 'B') then

      for c1_rec in c1(p_process_id, p_org_id) loop
    	  exit when c1%notfound;
                update amw_process_organization
                set approval_status = 'A',
                approval_date = APPROV_TXN_DATE
                where process_id = c1_rec.parent_child_id
                and organization_id = p_org_id
                and end_date is null
                returning revision_number into rev_num;

                if rev_num > 1 then
                    update amw_process_organization
                    set approval_end_date = APPROV_TXN_DATE
                    where process_id = c1_rec.parent_child_id
                    and organization_id = p_org_id
                    and revision_number = (rev_num-1);
                end if;

                approve_associations(c1_rec.parent_child_id, p_org_id);
                write_approved_hierarchy(c1_rec.parent_child_id, 2, p_org_id);
                IF p_update_count = FND_API.G_TRUE THEN
                -- Update the Org Count
                amw_rl_hierarchy_pkg.update_org_count(c1_rec.parent_child_id);
                END IF;

      end loop;

    end if;

    write_approved_hierarchy(p_process_id, 1, p_org_id);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
    amw_rl_hierarchy_pkg.update_approved_denorm(p_org_id);
*/
    IF p_update_count = FND_API.G_TRUE THEN
    amw_org_hierarchy_pkg.upd_appr_control_count(p_org_id, null); --ko, commenting this.. -2);
    amw_org_hierarchy_pkg.upd_appr_risk_count(p_org_id, null); --ko the count api is currently aggregating in the upward direction -2);
    END IF;

end approve;


-- process approval rejected
-- change status D and unlock
procedure reject (p_process_id in number, p_org_id in number) is

begin
    update amw_process_organization
    set approval_status = 'D'
    where process_id = p_process_id
    and organization_id = p_org_id
    and end_date is null;

    delete from amw_process_locks
    where organization_id = p_org_id
    and locking_process_id = p_process_id;

end reject;


-- check that all processes below are approved, else produce error
procedure check_hier_approved(p_process_id in number, p_org_id in number) is

unappr_xst_excpt exception;
err_msg varchar2(4000);
l_dummy number;

begin

    begin
        select 1 --parent_child_id, a.approval_status
        into l_dummy
        from amw_process_organization  a
        where a.organization_id = p_org_id
        and a.end_date is null
        and a.approval_status <> 'A'
        and a.process_id in ( select alh.child_id
                              from amw_latest_hierarchies alh
                              start with alh.parent_id = p_process_id and alh.organization_id = p_org_id
                              connect by prior alh.child_id = alh.parent_id and alh.organization_id = p_org_id);
--ko replacing the below clause...
/*
        select 1 --parent_child_id, a.approval_status
        into l_dummy
        from amw_org_hierarchy_denorm d, amw_process_organization a
        where d.process_id = p_process_id
        and d.organization_id = p_org_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and a.process_id = d.parent_child_id
        and a.organization_id = p_org_id
        and a.end_date is null
        and a.approval_status <> 'A';
*/
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
         fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'amw_proc_org_approval_pkg',
                   	     p_procedure_name =>   'check_hier_approved',
  	                     p_error_text => err_msg);
         raise;

end check_hier_approved;



-- check that all processes below are approved, else produce error
-- overloaded so as not to produce an expection
procedure check_hier_approved(p_process_id in number,
                              p_org_id in number,
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
        from amw_process_organization  a
        where a.organization_id = p_org_id
        and a.end_date is null
        and a.approval_status <> 'A'
        and a.process_id in ( select alh.child_id
                              from amw_latest_hierarchies alh
                              start with alh.parent_id = p_process_id and alh.organization_id = p_org_id
                              connect by prior alh.child_id = alh.parent_id and alh.organization_id = p_org_id);
--ko replacing the below clause...
/*
        select 1 --parent_child_id, a.approval_status
        into l_dummy
        from amw_org_hierarchy_denorm d, amw_process_organization a
        where d.process_id = p_process_id
        and d.organization_id = p_org_id
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and a.process_id = d.parent_child_id
        and a.organization_id = p_org_id
        and a.end_date is null
        and a.approval_status <> 'A';
*/
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



procedure approve_associations(p_process_id in number, p_org_id in number) is

begin
    update amw_risk_associations
    set approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'PROCESS_ORG'
    and approval_date is null;

    update amw_risk_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'PROCESS_ORG'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_control_associations
    set approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'RISK_ORG'
    and approval_date is null;

    update amw_control_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'RISK_ORG'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_acct_associations
    set approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'PROCESS_ORG'
    and approval_date is null;

    update amw_acct_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk2 = p_process_id
    and pk1 = p_org_id
    and object_type = 'PROCESS_ORG'
    and deletion_date is not null
    and deletion_approval_date is null;
    --ko Approve Process Objectives and Control Objectives Associations..
    update amw_objective_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_org_id
    and pk2 = p_process_id
    and object_type in ( 'PROCESS_ORG' , 'CONTROL_ORG')
    and approval_date is null;

    update amw_objective_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_org_id
    and pk2 = p_process_id
    and object_type in ( 'PROCESS_ORG' , 'CONTROL_ORG')
    and deletion_date is not null
    and deletion_approval_date is null;

    -- Set the Start date of AP Associations...
    update amw_ap_associations
    set association_creation_date = sysdate
    where pk1 = p_org_id
    and   pk2 = p_process_id
    and   object_type = 'CTRL_ORG'
    and   association_creation_date is null;

    update AMW_AP_ASSOCIATIONS
    set deletion_date = sysdate
    WHERE object_type = 'CTRL_ORG'
    and pk1 = p_org_id
    and pk2 = p_process_id
    and association_creation_date is not null
    and pk3 not in ( SELECT control_id from
                 amw_control_associations
                 where object_type = 'RISK_ORG'
                 AND PK1 = p_org_id
                 AND PK2 = p_process_id
                 AND approval_date is not null
                 and deletion_approval_date is null);

/*    update amw_objective_associations
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS_ORG'
    and approval_date is null;

    update amw_objective_associations
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS_ORG'
    and deletion_date is not null
    and deletion_approval_date is null;

    update amw_significant_elements
    set approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS_ORG'
    and approval_date is null;

    update amw_significant_elements
    set deletion_approval_date = APPROV_TXN_DATE
    where pk1 = p_process_id
    and object_type = 'PROCESS_ORG'
    and deletion_date is not null
    and deletion_approval_date is null;  */

end approve_associations;



-- this procedure has three steps, for execution of three cursors that are explained below.
procedure write_approved_hierarchy(p_process_id in number, p_step in number, p_org_id in number,
                                   p_appr_date in DATE := NULL) is

            -- "approved" links that are in the latest hierarchy but not in the approved
            -- hierarchy => links to be transferred to the approved hierarchy.
            -- the assumption is that we do not manipulate the order_number data,
            -- i.e. we faithfully store the exact number the sequence generates or user enters
            -- and copy that number to the approved hierarchy.
            -- executed when step = 1
/*ksr commenting
            CURSOR c1 is
              (select parent_process_id, child_process_id, child_order_number
              from (select * from amw_latest_hierarchy_ORG_V where child_organization_id = p_org_id and parent_approval_status = 'A' and child_approval_status = 'A')
              start with parent_process_id = -2
              connect by prior child_process_id = parent_process_id)
			 MINUS
			 (select parent_process_id, child_process_id, child_order_number
             from AMW_CURR_APP_HIERARCHY_ORG_V
             where child_organization_id = p_org_id);
*/

            -- these links must be deleted from the approved hierarchy
            -- executed when step = 2
			CURSOR c2 is
			 (select parent_process_id, child_process_id from AMW_CURR_APP_HIERARCHY_ORG_V
			  where parent_process_id = p_process_id
              and child_organization_id = p_org_id)
			 MINUS
			 (select parent_process_id, child_process_id from amw_latest_hierarchy_ORG_V
			  where parent_process_id = p_process_id
              and child_organization_id = p_org_id);

			-- as a result of the children being removed in c2 some links may become
            -- defunct in the approved hierarchy ... we must remove those links
            -- executed when step = 1
/* ksr commenting
            CURSOR c3 is
			  (select parent_process_id, child_process_id from AMW_CURR_APP_HIERARCHY_ORG_V
              where parent_process_id is not null
              and child_organization_id = p_org_id)
			  MINUS
			  (select parent_process_id, child_process_id from
                (select * from AMW_CURR_APP_HIERARCHY_ORG_V where child_organization_id = p_org_id)
			   start with parent_process_id = -2
			   connect by prior child_process_id = parent_process_id);
*/


BEGIN
    if p_appr_date is not null then
        APPROV_TXN_DATE := p_appr_date;
    end if;
             if ( (p_step = 1) or (p_step = 0) ) then
/* kosriniv
    			for a_link in c1 loop
    				insert into amw_approved_hierarchies
                    (organization_id,
                    parent_id,
                    child_id,
                    start_date,
                    child_order_number,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_LOGIN,
		    CREATION_DATE,
		    CREATED_BY,
		    object_version_number )
                    values
                    (p_org_id,
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
kosriniv */
			added_rows(p_org_id);
			if(x_parent_tbl.exists(1)) then

			forall i in x_parent_tbl.first .. x_parent_tbl.last
				insert into amw_approved_hierarchies
                    (organization_id,
                    parent_id,
                    child_id,
                    start_date,
                    child_order_number,
		    		LAST_UPDATE_DATE,
		    		LAST_UPDATED_BY,
		    		LAST_UPDATE_LOGIN,
		    		CREATION_DATE,
		   			CREATED_BY,
		    		object_version_number )
                    values
                    (p_org_id,
                    x_parent_tbl(i),
                    x_child_tbl(i),
                    APPROV_TXN_DATE,
                    x_child_ord_tbl(i),
		    		sysdate,
		    		G_USER_ID,
		    		G_LOGIN_ID,
		    		sysdate,
		    		G_USER_ID,
		    		1
		    		);

			end if;

         end if;

-- I understand that this is not the most perfect use of object_version_number.
-- Ideally I should have obtained this number at the beginning of the procedure
-- and checked for concurrency here.

             if p_step = 2 then
        		for defunct_link in c2 loop
        			update amw_approved_hierarchies
                    set end_date = APPROV_TXN_DATE,
			object_version_number = object_version_number + 1
                    where organization_id = p_org_id
                    and parent_id = defunct_link.parent_process_id
                    and child_id = defunct_link.child_process_id
                    and end_date is null;
        		end loop;
             end if;

             if ( (p_step = 1) or (p_step = 3) ) then
/* kosriniv commenting
    			for defunct_link in c3 loop
        			update amw_approved_hierarchies
                    set end_date = APPROV_TXN_DATE,
			object_version_number = object_version_number + 1
                    where organization_id = p_org_id
                    and parent_id = defunct_link.parent_process_id
                    and child_id = defunct_link.child_process_id
                    and end_date is null;
			    end loop;
*/				invalid_rows(p_org_id);
				if(x_parent_tbl.exists(1)) then
				forall i in x_parent_tbl.first .. x_parent_tbl.last
					update amw_approved_hierarchies
                    set end_date = APPROV_TXN_DATE,
						object_version_number = object_version_number + 1
                    where organization_id = p_org_id
                    and parent_id = x_parent_tbl(i)
                    and child_id = x_child_tbl(i)
                    and end_date is null;
             end if;
          end if;

end write_approved_hierarchy;



procedure prod_err_unapr_obj_ass_ex (p_process_id in number,
                                     p_org_id in number,
                                     approve_option in varchar2,
                                     raise_ex in varchar2,
                                     p_result out nocopy varchar2,
                                     p_out_mesg out nocopy varchar2 ) is

cursor process_list (pid number, p_org_id number) is
			  select distinct alh.child_id parent_child_id
        from amw_latest_hierarchies alh
        start with alh.child_id = p_process_id and alh.organization_id = p_org_id
        connect by prior alh.child_id = alh.parent_id and alh.organization_id = p_org_id;
--ko replacing the below clause...
/*
        select parent_child_id
        from amw_org_hierarchy_denorm
        where process_id = pid
        and up_down_ind = 'D'
        and hierarchy_type = 'L'
        and organization_id = p_org_id
        union
        select pid from dual;
*/

cursor ass_risks (pid number, poid number) is
    select risk_id from amw_risk_associations where pk2 = pid and pk1 = poid and object_type = 'PROCESS_ORG';

cursor ass_controls (pid number, poid number) is
    select control_id from amw_control_associations where pk2 = pid and pk1 = poid and object_type = 'RISK_ORG';

l_dummy number;
unappr_obj_exception  exception;
err_msg varchar2(4000);

begin
    p_result := 'Y';
    p_out_mesg := null;

    if approve_option = 'B' then

   			for process_list_rec in process_list(p_process_id, p_org_id) loop

    			for ass_risks_rec in ass_risks(process_list_rec.parent_child_id, p_org_id) loop

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


    			for ass_controls_rec in ass_controls(process_list_rec.parent_child_id, p_org_id) loop

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
    			for ass_risks_rec in ass_risks(p_process_id, p_org_id) loop

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


    			for ass_controls_rec in ass_controls(p_process_id, p_org_id) loop

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
             fnd_msg_pub.add_exc_msg(p_pkg_name  =>    'AMW_PROC_ORG_APPROVAL_PKG',
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
p_org_id                in number,
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

    sub_for_approval (p_process_id, p_org_id);
    approve(p_process_id, p_org_id);

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

end autoapprove;


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
p_org_id                in number,
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

    approv_choice := amw_utility_pvt.get_parameter(p_org_id, 'PROCESS_APPROVAL_OPTION');

    if (approv_choice = 'C') then
          check_hier_approved(p_process_id, p_org_id, p_result, p_out_mesg);
          if p_result = 'N' then
            return;
          end if;
    end if;

    prod_err_unapr_obj_ass_ex (p_process_id, p_org_id, approv_choice, 'N', p_result, p_out_mesg);
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

PROCEDURE approve_exceptions(p_org_id IN NUMBER, p_process_id IN NUMBER)  IS
/* ======================================================================================================
 * What to do?                                                                                                                                                                      *
 * 1. Find out all the new Exceptions of the process in cotext.                                                                                                       *
 * 2. For each of the Exception, Examine whether an approved exception already exists with opposite action.                                         *
 *     If Exists , then End date both the old exception and newly created exception.                                                                           *
 * 3. Approve all the remaining Exceptions.                                                                                                                                  *
    ===================================================================================================== */
CURSOR deleted_exceptions(org_id NUMBER, process_id NUMBER) IS
SELECT exception_object_id,
       old_pk1,
			 old_pk2,
			 old_pk3,
			 old_pk4,
			 old_pk5,
			 old_pk6,
			 object_type
FROM amw_exceptions_b
WHERE approved_flag = 'N'
AND old_PK1 = org_Id
AND old_PK2 = process_id
AND transaction_type = 'DEL'
AND object_type IN ('PROCESS', 'RISK', 'CTRL')
AND end_date IS NULL;

CURSOR added_exceptions(org_id NUMBER, process_id NUMBER) IS
SELECT exception_object_id,
			 new_pk1,
			 new_pk2,
			 new_pk3,
			 new_pk4,
			 new_pk5,
			 new_pk6,
			 object_type
FROM amw_exceptions_b
WHERE approved_flag = 'N'
AND new_pk1 = org_Id
AND new_pk2 = process_id
AND transaction_type = 'ADD'
AND object_type IN ('PROCESS', 'RISK', 'CTRL')
AND end_date IS NULL;


CURSOR past_appr_addd_ex(p_pk1 VARCHAR2, p_pk2 VARCHAR2, p_pk3 VARCHAR2,p_pk4 VARCHAR2,p_pk5 VARCHAR2,p_pk6 VARCHAR2, p_obj_type VARCHAR2)
IS
SELECT exception_object_id
FROM amw_exceptions_b
WHERE  NVL(new_pk1, -99) = NVL(p_pk1, -99)
AND    NVL(new_pk2, -99) = NVL(p_pk2, -99)
AND    NVL(new_pk3, -99) = NVL(p_pk3, -99)
AND    NVL(new_pk4, -99) = NVL(p_pk4, -99)
AND    NVL(new_pk5, -99) = NVL(p_pk5, -99)
AND    NVL(new_pk6, -99) = NVL(p_pk6, -99)
AND object_type = p_obj_type
AND transaction_type = 'ADD'
AND end_date IS NULL;


CURSOR past_appr_del_ex(p_pk1 VARCHAR2, p_pk2 VARCHAR2, p_pk3 VARCHAR2,p_pk4 VARCHAR2,p_pk5 VARCHAR2,p_pk6 VARCHAR2, p_obj_type VARCHAR2)
IS
SELECT exception_object_id
FROM amw_exceptions_b
WHERE  NVL(old_pk1, -99) = NVL(p_pk1, -99)
AND    NVL(old_pk2, -99) = NVL(p_pk2, -99)
AND    NVL(old_pk3, -99) = NVL(p_pk3, -99)
AND    NVL(old_pk4, -99) = NVL(p_pk4, -99)
AND    NVL(old_pk5, -99) = NVL(p_pk5, -99)
AND    NVL(old_pk6, -99) = NVL(p_pk6, -99)
AND object_type = p_obj_type
AND transaction_type = 'DEL'
AND end_date IS NULL;

l_exception_exists BOOLEAN;
deleted_exceptions_rec deleted_exceptions%ROWTYPE;
added_exceptions_rec added_exceptions%ROWTYPE;
past_appr_addd_ex_rec past_appr_addd_ex%ROWTYPE;
past_appr_del_ex_rec past_appr_del_ex%ROWTYPE;

BEGIN

	-- Handle All the Open Exceptions.. Ending if any previous exceptions Exists for it..
  for added_exceptions_rec in  added_exceptions(p_org_id, p_process_id) LOOP
  	EXIT WHEN  added_exceptions%NOTFOUND;
  	l_exception_exists  := FALSE;
  	FOR  past_appr_del_ex_rec IN past_appr_del_ex(
  	   added_exceptions_rec.NEW_PK1,
			 added_exceptions_rec.NEW_PK2,
			 added_exceptions_rec.NEW_PK3,
			 added_exceptions_rec.NEW_PK4,
			 added_exceptions_rec.NEW_PK5,
			 added_exceptions_rec.NEW_PK6,
			 added_exceptions_rec.OBJECT_TYPE) LOOP
			 EXIT WHEN past_appr_del_ex%NOTFOUND;
			 l_exception_exists := TRUE;
			 -- We have an past exception for the opposite action.. So end date that exception...
			 UPDATE amw_exceptions_b SET end_date = SYSDATE	where exception_object_id = past_appr_del_ex_rec.exception_object_id;
		END LOOP;
	  IF l_exception_exists = TRUE THEN
	  	 UPDATE amw_exceptions_b SET end_date = SYSDATE, approved_flag = 'Y'	where exception_object_id = added_exceptions_rec.exception_object_id;
	  END IF;
	END LOOP;

	-- Similarly Check For the Delete Exceptions .... End Date if any previous exceptions exists..
	for deleted_exceptions_rec in  deleted_exceptions(p_org_id, p_process_id) LOOP
  	EXIT WHEN  deleted_exceptions%NOTFOUND;
  	l_exception_exists  := FALSE;
  	FOR  past_appr_addd_ex_rec IN past_appr_addd_ex(
  	   deleted_exceptions_rec.OLD_PK1,
			 deleted_exceptions_rec.OLD_PK2,
			 deleted_exceptions_rec.OLD_PK3,
			 deleted_exceptions_rec.OLD_PK4,
			 deleted_exceptions_rec.OLD_PK5,
			 deleted_exceptions_rec.OLD_PK6,
			 deleted_exceptions_rec.OBJECT_TYPE) LOOP
			 EXIT WHEN past_appr_addd_ex%NOTFOUND;
			 l_exception_exists := TRUE;
			 -- We have an past exception for the opposite action.. So end date that exception...
			 UPDATE amw_exceptions_b SET end_date = SYSDATE	where exception_object_id = past_appr_addd_ex_rec.exception_object_id;
		END LOOP;
	  IF l_exception_exists = TRUE THEN
	  	 UPDATE amw_exceptions_b SET end_date = SYSDATE, approved_flag = 'Y'	where exception_object_id = deleted_exceptions_rec.exception_object_id;
	  END IF;
	END LOOP;

 -- After end dated those exceptions which have previous exceptions entered.. Approved the remaining excepitons..

  UPDATE amw_exceptions_b
  SET approved_flag = 'Y'
  WHERE  end_date is null
  AND (     (old_pk1 = p_org_id AND 	old_pk2 = p_process_id AND transaction_type = 'DEL')
  			  OR (new_pk1 = p_org_id AND new_pk2 = p_process_id AND transaction_type = 'ADD') )
  AND object_type IN ('PROCESS' , 'RISK' , 'CTRL');

END approve_exceptions;


procedure add_child(p_process_id IN NUMBER)
is
temp1 tn;
temp2 tn;
str varchar2(50);
BEGIN
   str := to_char(p_process_id);
   if(x_t1.exists(str)) then
      temp1 := x_t1(str);
      temp2 := x_t2(str);
   else
      temp1 := tn();
      temp2 := tn();
   end if;
  /* check to avoid numeric error */
  if(temp1.exists(1)) then
  --for each child (of the process on which the procedure is called)
  for i in temp1.first .. temp1.last loop
     add_child( p_process_id => temp1(i));
     x_valid_links.extend;
     x_valid_links(x_valid_links.last) := t_valid_link(p_process_id, temp1(i),temp2(i));
  end loop;
 end if ;

end add_child;

procedure encode_links(p_process_id IN NUMBER)
is
temp1 tn;
str varchar2(50);
BEGIN
   str := to_char(p_process_id);
   if(x_t1.exists(str)) then
      temp1 := x_t1(str);
   else
      temp1 := tn();
   end if;
  /* check to avoid numeric error */
  if(temp1.exists(1)) then
  --for each child (of the process on which the procedure is called)
  for i in temp1.first .. temp1.last loop
     encode_links( p_process_id => temp1(i));
     x_index_tbl(to_char(p_process_id) || ':' || to_char(temp1(i))) := 1;
  end loop;
 end if ;

end encode_links;


procedure added_rows(p_org_id IN NUMBER)
is

cursor c_all_latest_links_org(l_org_id in number) is
  select ah.parent_id , ah.child_id, AH.CHILD_ORDER_NUMBER
    from amw_latest_hierarchies ah
    where ah.parent_id =(select pp.process_id
                          from amw_process_organization pp
                          where pp.organization_id = ah.organization_id
                          and  pp.process_id = ah.parent_id
                          and pp.end_date is null
                          and pp.APPROVAL_STATUS ='A')
     and ah.child_id = ( select Cp.process_id
                          from amw_process_organization Cp
                          where Cp.organization_id = ah.organization_id
                          and  Cp.process_id = ah.child_id
                          and Cp.end_date is null
                          and Cp.APPROVAL_STATUS ='A')
     and ah.organization_id = l_org_id;

cursor c_all_approved_links_org(l_org_id in number) is
	select ah.parent_id , ah.child_id
    from amw_approved_hierarchies ah
    where ah.parent_id =(select pp.process_id
                          from amw_process_organization pp
                          where pp.organization_id = ah.organization_id
                          and  pp.process_id = ah.parent_id
                          and pp.approval_date is not null
                          and pp.approval_end_date is null
                          and pp.deletion_date is null)
     and ah.child_id = ( select Cp.process_id
                          from amw_process_organization Cp
                          where Cp.organization_id = ah.organization_id
                          and  Cp.process_id = ah.child_id
                          and Cp.approval_date is not null
                          and Cp.approval_end_date is null
                          and Cp.deletion_date is null)
     and ah.start_date is not null
     and ah.end_date is null
     and ah.organization_id = l_org_id;


str varchar2(50);
p_ltst_links_tbl ltst_links_tbl;
p_appr_links_tbl appr_links_tbl;

begin
   init;
   open c_all_latest_links_org(p_org_id);
   fetch c_all_latest_links_org bulk collect into p_ltst_links_tbl;
   close c_all_latest_links_org;


   if (p_ltst_links_tbl.exists(1)) then
	  for ctr in p_ltst_links_tbl.first .. p_ltst_links_tbl.last loop
       str := to_char(p_ltst_links_tbl(ctr).parent_id);
       x_t1(str) := tn();
       x_t2(str) := tn();
      end loop;

  	  --put in all the links
      for ctr in p_ltst_links_tbl.first .. p_ltst_links_tbl.last loop
        str := to_char(p_ltst_links_tbl(ctr).parent_id);
        x_t1(str).extend;
        x_t2(str).extend;
        x_t1(str)(x_t1(str).last) := p_ltst_links_tbl(ctr).child_id;
        x_t2(str)(x_t2(str).last) := p_ltst_links_tbl(ctr).child_order_number;
      end loop;
   end if;

   open c_all_approved_links_org(p_org_id);
   fetch c_all_approved_links_org bulk collect into p_appr_links_tbl;
   close c_all_approved_links_org;

   if (p_appr_links_tbl.exists(1)) then
   	for ctr in p_appr_links_tbl.first .. p_appr_links_tbl.last loop
      x_index_tbl(to_char(p_appr_links_tbl(ctr).parent_id) || ':' || to_char(p_appr_links_tbl(ctr).child_id)) := 1;
    end loop;
   end if;
  x_valid_links := t_valid_lt();
  add_child(-2);
  	x_parent_tbl := tn();
	x_child_tbl  := tn();
	x_child_ord_tbl := tn();
	if(x_valid_links.exists(1)) then
  for i in x_valid_links.first .. x_valid_links.last loop
   	if (x_index_tbl.exists(to_char(x_valid_links(i)(1)) || ':' || to_char(x_valid_links(i)(2)))) then
   		null;
   	else
   		x_parent_tbl.extend;
   	 	x_child_tbl.extend;
   		x_child_ord_tbl.extend;

   		x_parent_tbl(x_parent_tbl.last) := x_valid_links(i)(1);
   		x_child_tbl(x_child_tbl.last) := x_valid_links(i)(2);
   		x_child_ord_tbl(x_child_ord_tbl.last) := x_valid_links(i)(3);
   		x_index_tbl(to_char(x_valid_links(i)(1)) || ':' || to_char(x_valid_links(i)(2))) := 1;
   	end if;
  end loop;
  end if;

end added_rows;

procedure invalid_rows(p_org_id IN NUMBER) IS

cursor c_all_approved_links_org(l_org_id in number) is
	select ah.parent_id , ah.child_id
    from amw_approved_hierarchies ah
    where ah.parent_id =(select pp.process_id
                          from amw_process_organization pp
                          where pp.organization_id = ah.organization_id
                          and  pp.process_id = ah.parent_id
                          and pp.approval_date is not null
                          and pp.approval_end_date is null
                          and pp.deletion_date is null)
     and ah.child_id = ( select Cp.process_id
                          from amw_process_organization Cp
                          where Cp.organization_id = ah.organization_id
                          and  Cp.process_id = ah.child_id
                          and Cp.approval_date is not null
                          and Cp.approval_end_date is null
                          and Cp.deletion_date is null)
     and ah.start_date is not null
     and ah.end_date is null
     and ah.organization_id = l_org_id;

str varchar2(50);
p_appr_links_tbl appr_links_tbl;
begin
   init;
   open c_all_approved_links_org(p_org_id);
   fetch c_all_approved_links_org bulk collect into p_appr_links_tbl;
   close c_all_approved_links_org;


   if (p_appr_links_tbl.exists(1)) then

	  for ctr in p_appr_links_tbl.first .. p_appr_links_tbl.last loop
       str := to_char(p_appr_links_tbl(ctr).parent_id);
       x_t1(str) := tn();
      end loop;

  	  --put in all the links
      for ctr in p_appr_links_tbl.first .. p_appr_links_tbl.last loop
        str := to_char(p_appr_links_tbl(ctr).parent_id);
        x_t1(str).extend;
        x_t1(str)(x_t1(str).last) := p_appr_links_tbl(ctr).child_id;
      end loop;
      encode_links(-2);
      x_parent_tbl := tn();
   	  x_child_tbl  := tn();
      for ctr in p_appr_links_tbl.first .. p_appr_links_tbl.last loop
         if (x_index_tbl.exists(to_char(p_appr_links_tbl(ctr).parent_id) || ':' || to_char(p_appr_links_tbl(ctr).child_id))) then
   		    null;
   	     else
   			x_parent_tbl.extend;
   	 		x_child_tbl.extend;
   			x_parent_tbl(x_parent_tbl.last) := p_appr_links_tbl(ctr).parent_id;
   			x_child_tbl(x_child_tbl.last) := p_appr_links_tbl(ctr).child_id;
   		 end if;
	  end loop;
   end if;
end invalid_rows;

end AMW_PROC_ORG_APPROVAL_PKG;

/
