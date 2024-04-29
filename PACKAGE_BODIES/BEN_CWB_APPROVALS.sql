--------------------------------------------------------
--  DDL for Package Body BEN_CWB_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_APPROVALS" as
/* $Header: bencwbap.pkb 120.1 2005/12/23 02:40 aupadhya noship $ */




g_package             varchar2(80) := 'BEN_CWB_APPROVALS';



-- ----------------------------------------------------------------------------
-- |-------------------------< approve_all_managers >---------------------|
-- ----------------------------------------------------------------------------



procedure approve_all_managers
			(
			p_group_per_in_ler_id in number,
		        p_group_pl_id in number,
		        p_group_oipl_id in number,
		        p_task_id in number,
		        p_effective_date date,
		        p_login_person_id in number
		        )
    is
    	l_group_per_in_ler_id number;
    	l_group_pl_id number;
    	l_group_oipl_id number;
    	l_access_cd varchar2(15);
    	l_object_version_number number;
    	l_task_id number;
        l_object_version_number_task number;
    	l_error varchar2(500);
    	l_task_status varchar2(15);
    	l_package varchar2(80) := g_package||'.approve_all_managers';

        cursor getManagers  is
        	select
			group_per_in_ler_id,
			group_pl_id,
			group_oipl_id,
			grp.approval_cd,
			access_cd,
			grp.object_version_number
		from
			ben_cwb_person_groups grp,
			ben_cwb_group_hrchy hrchy,
			ben_cwb_group_hrchy hrchy_mgr
		where
			 hrchy.mgr_per_in_ler_id = p_group_per_in_ler_id
			  and hrchy.lvl_num>0
			  and hrchy.emp_per_in_ler_id=hrchy_mgr.mgr_per_in_ler_id
			  and hrchy_mgr.lvl_num=0
			  and grp.group_per_in_ler_id=hrchy_mgr.mgr_per_in_ler_id
			  and grp.group_pl_id = p_group_pl_id
			  and grp.group_oipl_id = p_group_oipl_id
			  and ((nvl(grp.approval_cd,'NULL') not in ('AP','PR')));

       cursor getTaskObjVerNum(c_group_per_in_ler_id in number,c_task_id in number) is
            select
            object_version_number ovn,
            status_cd status
            from ben_cwb_person_tasks
            where group_per_in_ler_id = c_group_per_in_ler_id
            and task_id = c_task_id
            and  group_pl_id=p_group_pl_id;

       cursor getApprTaskId(c_group_per_in_ler_id in number) is
      		 SELECT cwb_wksht_grp_id
      		 from
      			 ben_cwb_wksht_grp grp,
      			 ben_cwb_person_tasks tsk
       		where  grp.wksht_grp_cd = 'APPR'
       			and    tsk.group_per_in_ler_id= c_group_per_in_ler_id
			and    tsk.task_id=  grp.cwb_wksht_grp_id;


    begin
	 		--hr_utility.trace_on (null, 'ORACLE');

    			hr_utility.set_location('Entering '||l_package ,10);

			--hr_utility.set_location('p_group_per_in_ler_id '||p_group_per_in_ler_id ,20);
			--hr_utility.set_location('p_group_pl_id '||p_group_pl_id ,30);
			--hr_utility.set_location('p_group_oipl_id '||p_group_oipl_id ,40);
			--hr_utility.set_location('p_effective_date '||p_effective_date ,60);
			--hr_utility.set_location('p_login_person_id '||p_login_person_id ,70);


			for i in getManagers loop

				l_group_per_in_ler_id := i.group_per_in_ler_id;
				l_group_pl_id := i.group_pl_id;
				l_group_oipl_id := i.group_oipl_id;
				l_access_cd:= i.access_cd;
				l_object_version_number := i.object_version_number;

				--hr_utility.set_location('p_group_per_in_ler_id '||l_group_per_in_ler_id ,20);
				--hr_utility.set_location('p_group_pl_id '||l_group_pl_id ,30);
				--hr_utility.set_location('p_group_oipl_id '||l_group_oipl_id ,40);
				--hr_utility.set_location('l_access_cd '||l_access_cd ,50);


			 if ('NA' <> l_access_cd) then

				BEN_CWB_PERSON_GROUPS_API.update_group_budget
				(
				 p_validate             => false
				,p_group_per_in_ler_id  => l_group_per_in_ler_id
				,p_group_pl_id 	        => l_group_pl_id
				,p_group_oipl_id        => l_group_oipl_id
				,p_access_cd		=> 'RO'
				,p_approval_cd          => 'AP'
				,p_approval_date	=>  p_effective_date
				,p_approval_comments    => ' '
				,p_object_version_number => l_object_version_number
				);
			else
				BEN_CWB_PERSON_GROUPS_API.update_group_budget
				(
				 p_validate             => false
				,p_group_per_in_ler_id  => l_group_per_in_ler_id
				,p_group_pl_id 	        => l_group_pl_id
				,p_group_oipl_id        => l_group_oipl_id
				,p_approval_cd          => 'AP'
				,p_approval_date	=>  p_effective_date
				,p_approval_comments    => ' '
				,p_object_version_number => l_object_version_number
				);


			end if;

				-- Update task status to complete for all lower managers


				open getApprTaskId(l_group_per_in_ler_id);
				fetch getApprTaskId into l_task_id;
				close getApprTaskId;

				open getTaskObjVerNum(l_group_per_in_ler_id,l_task_id);
             			   fetch getTaskObjVerNum into l_object_version_number_task , l_task_status;
             			   --fetch getTaskObjVerNum.status into l_task_status;
    				close getTaskObjVerNum;

				if(l_task_status <> 'CO') then

				--hr_utility.set_location('l_task_id '||l_task_id ,60);
				--hr_utility.set_location('p_login_person_id '||p_login_person_id ,70);

					BEN_CWB_PERSON_TASKS_API.update_person_task
					(
					 p_validate             => false
					,p_group_per_in_ler_id  => l_group_per_in_ler_id
					,p_group_pl_id 	        => l_group_pl_id
					,p_task_id		=> l_task_id
					,p_status_cd		=> 'CO'
             				,p_object_version_number => l_object_version_number_task
             				,p_task_last_update_date => p_effective_date
             				,p_task_last_update_by =>   p_login_person_id
					);
				end if;

			end loop;


			 hr_utility.set_location('Leaving '||l_package ,30);
			 --hr_utility.trace_off;

		EXCEPTION
		when others then
		l_error:=fnd_message.get;
		hr_utility.set_location ('exception is'||l_error , 300);

end approve_all_managers;


-- ----------------------------------------------------------------------------
-- |-------------------------< getNextApprover >---------------------|
-- ----------------------------------------------------------------------------

-- Next Approve Name used in self-service


procedure getNextApprover(p_per_in_ler_id in number,
			  p_ben_cwb_profile_disp_name in varchar2,
			  p_approver_name out nocopy varchar2,
			  p_approver_id out nocopy number,
			  p_last_approver_name out nocopy varchar2) is

	cursor get_approval_status is
		select approval_cd
		from ben_cwb_person_groups
		where group_per_in_ler_id= p_per_in_ler_id;

	cursor get_name(c_per_in_ler_id in number) is
		select
		decode(p_ben_cwb_profile_disp_name,'FN',full_name,'CN',custom_name,brief_name) manager_name
		from  ben_cwb_person_info
		where ben_cwb_person_info.group_per_in_ler_id = c_per_in_ler_id;

	cursor get_manager_name(c_per_in_ler_id in number) is
		select
		decode(p_ben_cwb_profile_disp_name,'FN',full_name,'CN',custom_name,brief_name) manager_name ,
		person_id
		from ben_cwb_group_hrchy,
		     ben_cwb_person_info
		where ben_cwb_group_hrchy.emp_per_in_ler_id = c_per_in_ler_id
		      and lvl_num=1
		      and ben_cwb_person_info.group_per_in_ler_id = ben_cwb_group_hrchy.mgr_per_in_ler_id;

	cursor get_next_approver is
		select mgr_per_in_ler_id
		from
		ben_cwb_group_hrchy,
		ben_cwb_person_groups
		where
		ben_cwb_group_hrchy.emp_per_in_ler_id = p_per_in_ler_id
		and ben_cwb_group_hrchy.mgr_per_in_ler_id = ben_cwb_person_groups.group_per_in_ler_id
		and group_oipl_id=-1
		and ((approval_cd is null ) or (approval_cd = 'RJ' ))
		and lvl_num <> -1
		order by lvl_num;

	l_next_approver_name varchar2(480):=null;
	l_last_approver_name varchar2(480):=null;
	l_next_approver_id number:=-1;
	l_approval_cd varchar2(5);
	l_per_in_ler_id number := -1 ;
	l_last_appr varchar2(100);


begin

-- fetch highest approver

	    fnd_message.set_name('BEN','BEN_92969_CWB_LAST_APPR');
	    l_last_appr:=fnd_message.get;

--  First check approval status of manager, if it is null or rejected
--  then supervisor is next approver

 	open get_approval_status;
 	fetch get_approval_status into l_approval_cd;
 	close get_approval_status;

 	if ((l_approval_cd is null ) or (l_approval_cd = 'RJ')) then
 		open get_manager_name(p_per_in_ler_id);
 		fetch get_manager_name into l_next_approver_name,l_next_approver_id;
 		close get_manager_name;
 		if l_next_approver_name is null then
 			p_approver_name:=l_last_appr;
 			p_approver_id := -1;
 		else
 			p_approver_name:=l_next_approver_name;
 			p_approver_id := l_next_approver_id;
 		end if;
 	   return;
 	end if;

-- Find for a manager in hrchy whose status is 	null or rejected , that managers supervisor will
-- be the approver.

	open get_next_approver;
	fetch get_next_approver into l_per_in_ler_id;
	close get_next_approver;

	if (l_per_in_ler_id <> -1 ) then

		open get_manager_name(l_per_in_ler_id);
		fetch get_manager_name into l_next_approver_name,l_next_approver_id;
		close get_manager_name;

		open get_name(l_per_in_ler_id);
		fetch get_name into l_last_approver_name;
		close get_name;

		p_last_approver_name := l_last_approver_name;

		if l_next_approver_name is null then
			p_approver_name:=l_last_appr;
			p_approver_id := -1;
		else
			p_approver_name:=l_next_approver_name;
			p_approver_id := l_next_approver_id;
 		end if;

 	end if;

end getNextApprover;



END BEN_CWB_APPROVALS;

/
