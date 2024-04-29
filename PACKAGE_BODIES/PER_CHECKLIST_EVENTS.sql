--------------------------------------------------------
--  DDL for Package Body PER_CHECKLIST_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CHECKLIST_EVENTS" as
/* $Header: pecklevt.pkb 120.10.12010000.3 2010/04/03 12:23:50 brsinha ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_CHECKLIST_EVENTS.';
g_debug boolean := hr_utility.debug_enabled;


  procedure check_approvers_exist
            (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2)
  is
    all_approvers    ame_util.approversTable2;
    l_taskin_cklid     number;
    process_complete varchar2(1000);
    l_proc varchar2(72);

    --
    l_person_id			number;			-- 8861932
    l_allocated_task_id		number;			-- 8861932
    l_transaction_id		varchar2(100);		-- 8861932
    --
  begin

      l_proc := g_package||'check_process';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location(l_proc,1);

     l_taskin_cklid    := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'TASKIN_CKLID'
                               ,ignore_notfound  => false
                               );
     -- 8891632 starts
     l_allocated_task_id    := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'ALLOC_TASKID'
                               ,ignore_notfound  => false
                               );
     SELECT pac.person_id INTO l_person_id
     FROM per_allocated_tasks pat, per_allocated_checklists pac
     WHERE allocated_task_id = l_allocated_task_id
     AND pac.allocated_checklist_id = pat.allocated_checklist_id;

     l_transaction_id	:= l_taskin_cklid||'-'||l_person_id;
     -- 8891632 ends

     ame_api2.getAllApprovers7(
                APPLICATIONIDIN              => 800,
                TRANSACTIONTYPEIN            => 'CHECKLISTID',
                --TRANSACTIONIDIN              => l_taskin_cklid,
		TRANSACTIONIDIN              => l_transaction_id,		-- 8891632
                approvalProcessCompleteYNout => process_complete,
                APPROVERSOUT                 => ALL_APPROVERS);

      if all_approvers.count =0 then
         resultout:='COMPLETE:N';
      else
        resultout:='COMPLETE:Y';
      end if;

      hr_utility.set_location('retvalue:'|| resultout, 20);
      hr_utility.set_location('Leaving:'|| l_proc, 10);

 end;


function getRoleForAllApproversList(p_transaction_id in varchar2) return varchar2
is

       l_approver_table           ame_util.approversTable2;
       l_invalid_usr_rec 	  ame_util.approverRecord2;
       l_ame_admin_rec            ame_util.approverRecord2;
       l_process_complete         VARCHAR2(1);
       l_party_id                 NUMBER;
       l_index                    NUMBER;
       l_role_name                VARCHAR2(30) ;
       l_role_display             VARCHAR2(60) ;
       l_exp_date                 DATE ;
       l_role_exists              VARCHAR2(1) ;
       l_transaction_type         VARCHAR2(30);
       l_users                    VARCHAR2(2000);
       l_invalid_users            VARCHAR2(2000);
       l_valid_user               VARCHAR2(1);
       l_index integer :=0;
       ln_notification_id number;
       l_task_in_chklist_id		varchar2(100);				-- 8891632


        CURSOR c_chk_wf_role (p_role_name    VARCHAR2) IS
        SELECT 'Y'
        FROM   wf_local_roles
        WHERE  name = p_role_name;

      BEGIN
      l_task_in_chklist_id	:= substr(p_transaction_id,1,instr(p_transaction_id,'-')-1);		-- 8861932

     -- l_role_name:='CKLLST_ADHOC_'||p_transaction_id;
     -- l_role_display:='Checklist Group For '||p_transaction_id;
      l_role_name:='CKLLST_ADHOC_'||l_task_in_chklist_id;						-- 8861932
      l_role_display:='Checklist Group For '||l_task_in_chklist_id;					-- 8861932

      l_role_exists:='N';
         -- Check if the ADHOC role already exists
         OPEN c_chk_wf_role(l_role_name);
        	 FETCH c_chk_wf_role INTO l_role_exists;
      	 CLOSE c_chk_wf_role;

    	-- Call the AME API to get the list of ALL approvers

        ame_api2.getAllApprovers7 (
                           applicationIdIn               => 800,
                           transactionTypeIn             => 'CHECKLISTID',
                           transactionIdIn               => p_transaction_id,
                           approvalProcessCompleteYNOut  => l_process_complete,
                           ApproversOut                  => l_approver_table);

                if l_approver_table.count > 0  then
                     for l_index in 1 .. l_approver_table.count
                      loop
                          IF l_users IS NULL THEN
                               l_users := l_approver_table(l_index).name;
                          ELSE
                            l_users := l_users ||','||l_approver_table(l_index).name;
                         END IF;
                     end loop;
               end if;

        	-- Check if AME encountered any errors.
	        IF l_approver_table.COUNT <> 0 then
                   -- Check if the ADHOC role already exists
                    IF l_role_exists = 'Y' THEN
		       -- If the role exists, then empty the existing role list
		            wf_directory.RemoveUsersFromAdHocRole
		                    (role_name         => l_role_name,
		                     role_users        => NULL);

		                    -- Add the users we have identified to the role list.
		                    wf_directory.AddUsersToAdHocRole
		                                    (role_name         => l_role_name,
		                                     role_users        => l_users);
		                ELSE
		                    -- Create an ADHOC role for the approver list and add the
		                    -- users.
		                    wf_directory.CreateAdHocRole
		                            (role_name         => l_role_name,
		                             role_display_name => l_role_display,
		                             role_users        => l_users,
		                             expiration_date   => NULL);

            	    END IF; -- Check ADHOC role exists


    END IF; -- approver count

   return l_role_name;
end;

procedure PROCESS_VOTING
               (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2)

  is
    l_proc    varchar2(72);
    l_status  varchar2(30);
    l_responder varchar2(320);

    cursor cur_check_wf_status(cur_p_context varchar2) is
    select
      TEXT_VALUE,RESPONDER
    from
     wf_notifications wfn,
     wf_notification_attributes wfna
    where
      wfn.notification_id=wfna.notification_id and context like cur_p_context and responder is not null and name ='RESULT';

  begin
      l_proc := g_package||'PROCESS_VOTING';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location(l_proc,1);

      if(funcmode='RUN') then
          open cur_check_wf_status(itemtype||':'|| itemkey ||':%');
            fetch cur_check_wf_status into l_status,l_responder;
            if(cur_check_wf_status%FOUND) then
               if(l_status is not null and l_status='COMPLETE' )then
                    wf_engine.SetItemAttrText(itemtype,itemkey,'TASK_STATUS',    hr_general.decode_lookup('PER_CHECKLIST_TASK_STATUS','COM'));
                    wf_engine.SetItemAttrText(itemtype,itemkey,'TASK_DONE_BY',l_responder);
                    resultout:='COMPLETE:'||l_status;
               else
                if (l_status is not null and l_status='NOT COMPLETED' )then
                    wf_engine.SetItemAttrText(itemtype,itemkey,'TASK_STATUS',hr_general.decode_lookup('PER_CHECKLIST_TASK_STATUS','REJ'));
                    wf_engine.SetItemAttrText(itemtype,itemkey,'TASK_DONE_BY',l_responder);
                    resultout:='COMPLETE:'||l_status;
                end if;
               end if;
            end if;
          close cur_check_wf_status;
      else
          resultout:=null;
     end if;
      hr_utility.set_location('result:'|| resultout, 20);
      hr_utility.set_location('Leaving:'|| l_proc, 10);
  end;

--
-- ------------------------------------------------------------------------
-- |----------------------------< create_event>---------------------------|
-- ------------------------------------------------------------------------
--
procedure CREATE_EVENT
      		(p_effective_date in date,
		 P_person_id      in number,
		 P_assignment_id  in number,
		 P_ler_id         in number)
is
l_event_id number;
  --
  l_proc varchar2(72) ;
  --cursor event_exists(p_person_id number,p_assignment_id number,p_ler_id number, p_effective_date date) is
  cursor event_exists is
    SELECT 'X'
    FROM per_ben_identified_events
    WHERE person_id             = p_person_id
    AND   nvl(assignment_id,-1) = nvl(p_assignment_id,-1)
    AND   event_reason_id       = p_ler_id
    AND   effective_date        = p_effective_date;
  --
  l_exists varchar2(30);
  --
--
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_event';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
    open event_exists;
    fetch event_exists into l_exists;
    if event_exists%notfound then
      if g_debug then
        hr_utility.set_location('Entering '||l_proc,20);
      end if;
	insert into per_ben_identified_events(
             ben_identified_event_id,
	     event_reason_id,
	     person_id,
	     assignment_id,
	     status,
	     effective_date,
	     object_version_number)
	values(
	     per_ben_identified_events_s.nextval,
	     p_ler_id,
	     p_person_id,
	     p_assignment_id,
	     'Pending',
	     p_effective_date,
	     1);
    end if;
    close event_exists;
    if g_debug then
      hr_utility.set_location('Leaving '||l_proc,30);
    end if;
End create_event;
--

-- ---------------------------------------------------------------------------------
-- |------------------------------PROCESS EVENT------------------------------------|
-- ---------------------------------------------------------------------------------
--
  procedure PROCESS_EVENT
     (p_person_id     in number
     ,p_assignment_id in number default null
     ,p_date          in date
     ,p_ler_event_id  in number) as

  l_ler_event_id     number;
  l_person_id        number;
  l_assignment_id    number;
  --
  l_proc varchar2(72) ;
  --
  --
  -- Cursor fetches all the tasks in checklist for the event attached for the checklist
  --
  cursor c1(pl_ler_event number) is
    select
      ctsk.eligibility_object_id
     ,ckl.checklist_id
     ,ckl.name                 checklist_name
     ,ckl.description          checklist_description
     ,ckl.checklist_category
     ,ctsk.checklist_task_name
     ,ctsk.description         checklist_task_description
     ,ctsk.task_in_checklist_id
     ,ctsk.target_duration
     ,ctsk.target_duration_uom
     ,ctsk.mandatory_flag
     ,ctsk.ame_attribute_identifier
     ,ctsk.action_url
     ,ckl.event_reason_id
     ,ckl.business_group_id
    from
      per_tasks_in_checklist  ctsk,
      per_checklists          ckl
    where ckl.event_reason_id     = pl_ler_event
      and ctsk.checklist_id       = ckl.checklist_id
    order by ckl.checklist_id,ctsk.eligibility_object_id;
  x_cur c1%rowtype;
  --
  --
  -- Cursor to check whether a task is already allocated
  --
  cursor chk_exists (p_person_id number
                    ,p_task_in_checklist_id number) is
    select
      'Exists'
    from
      per_tasks_in_checklist   tic,
      per_allocated_checklists pac,
      per_allocated_tasks      pat
    where
      tic.task_in_checklist_id = p_task_in_checklist_id
      and pac.person_id        = p_person_id
      and tic.checklist_id     = pac.checklist_id
      and tic.checklist_task_name          = pat.task_name
      and pac.allocated_checklist_id     = pat.allocated_checklist_id;
  --
  cursor alloc_ckl_exists (p_person_id number
                          ,p_assignment_id number
                          ,p_checklist_id number) is
    select allocated_checklist_id
    FROM per_allocated_checklists
    WHERE person_id     = p_person_id
    AND   nvl(assignment_id,-1) = nvl(p_assignment_id,-1)
    AND   checklist_id  = p_checklist_id;

    x1 varchar2(10);
    l_chk varchar2(2000);
    --==============AME=======================
    i integer; --approver_count
    l_approver_display_name varchar2(360);
    l_approver_name         varchar2(320);
    all_approvers           ame_util.approversTable2;
    process_complete        varchar2(1000);
    l_orig_system           varchar2(30);
    l_orig_system_id        number;
    l_approver_order_number number;
    l_approver_count        number;
    l_current_approver      number :=1;
    l_transaction_id	    varchar2(100);		-- 8861932
    --==============AME=======================

    l_dummy varchar2(10);
    current_checklist_id number;
    current_alloc_ckl_id number;
    l_allocated_task_id  number;
    l_alloc_task_ovn     number;
    l_alloc_ckl_id       number;
    l_alloc_ckl_ovn      number;
    l_target_end_date    date;
  --
  begin
    --
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'create_event';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location('person_id '||to_char(p_person_id),10);
      hr_utility.set_location('asg id '||to_char(p_assignment_id),10);
      hr_utility.set_location('event reason '||to_char(p_ler_event_id),10);
    end if;
    --
    --loop throught the number of records fetched which are pending to process.
    --

    for x_cur in c1(p_ler_event_id) loop
      if g_debug then
         hr_utility.set_location('In the first loop',20);
      end if;

       --
       -- if not a concurrent request ben code BEN_PER_ASG_ELIG
       -- lines are intializing so deferring in that case

       if x_cur.eligibility_object_id is not null and fnd_global.conc_request_id not in (0,-1) then
         ben_env_object.init
         (p_business_group_id =>  x_cur.business_group_id,
          p_thread_id => null,
          p_chunk_size => null,
          p_threads => null,
          p_max_errors => null,
          p_benefit_action_id => null,
          p_effective_date=>  p_date);
      end if;
      --
      if x_cur.eligibility_object_id is null or  ben_per_asg_elig.Eligible(p_person_id,
                                   p_assignment_id,
                                   x_cur.eligibility_object_id,
                                   p_date,
				   x_cur.business_group_id,
				   false)
      then
          if g_debug then
	     hr_utility.set_location('In the first loop',30);
	  end if;
         --
         open chk_exists(p_person_id,x_cur.task_in_checklist_id);
         fetch chk_exists into l_dummy;
         if chk_exists%notfound then
            if g_debug then
	       hr_utility.set_location('In the first loop',40);
	    end if;
	    --
	    if nvl(x_cur.checklist_id,-1) <> nvl(current_checklist_id,-1) then
               --
	       if g_debug then
		  hr_utility.set_location('In the first loop',50);
               end if;
	       --
	       open alloc_ckl_exists (p_person_id,p_assignment_id,x_cur.checklist_id);
	       fetch alloc_ckl_exists into current_alloc_ckl_id;
	       if alloc_ckl_exists%notfound then
                 --
		 l_alloc_ckl_id := null;
		 current_checklist_id := x_cur.checklist_id;
		 PER_ALLOCATED_CHECKLIST_API.CREATE_ALLOC_CHECKLIST
                    (p_validate                => false
                    ,p_effective_date          => p_date
                    ,p_checklist_id            => current_checklist_id
                    ,p_checklist_name          => x_cur.checklist_name
		    ,p_description             => x_cur.checklist_description
		    ,p_checklist_category      => x_cur.checklist_category
                    ,p_person_id               => p_person_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_allocated_checklist_id  => l_alloc_ckl_id
                    ,p_object_version_number   => l_alloc_ckl_ovn
                    );
		 current_alloc_ckl_id := l_alloc_ckl_id;
	       end if;
	       close alloc_ckl_exists;
               --
	       if g_debug then
	          hr_utility.set_location('In the first loop',80);
               end if;
	       --
	    end if;
	    if g_debug then
               hr_utility.set_location('In the first loop',90);
	    end if;
            --
-- ---------------------------------------------------------
-- ---------------------------------------------------------

-- ==============================================================================
-- ==============Begin of Initial approver from AME =============================
-- ==============================================================================

	    --
            -- run AME and get first performer and count for populating
	    -- PER_ALLOCATED_TASK columns for performer.
	    --
	    begin
              if x_cur.ame_attribute_identifier is not null then

                if g_debug then
    		          hr_utility.set_location('before approver'||l_proc,75);
	           	end if;
                --
                -- Get All approvers
                --
		l_transaction_id := x_cur.task_in_checklist_id||'-'||p_person_id;   -- 8861932

                ame_api2.getAllApprovers7(
                    APPLICATIONIDIN              => 800,
                    TRANSACTIONTYPEIN            => 'CHECKLISTID',
                    TRANSACTIONIDIN              => l_transaction_id,			-- 8861932
                    approvalProcessCompleteYNout => process_complete,
                    APPROVERSOUT                 => ALL_APPROVERS);
                    if g_debug then
	               	  hr_utility.set_location('after approver'||l_proc,76);
            		end if;

                   if all_approvers.count > 0 then
                        i := 1;  -- approver_count
                        l_orig_system           := all_approvers(i).orig_system;
                        l_orig_system_id        := all_approvers(i).orig_system_id;
                        l_approver_count        := all_approvers.count;
                        l_approver_display_name := all_approvers(i).display_name;
                        l_approver_name         := all_approvers(i).name;
                   end if;
              end if; -- ame_attribute_identifier not null

               if x_cur.ame_attribute_identifier is null or
                  all_approvers.count=0 then
        		l_orig_system           := null;
                l_orig_system_id        := null;
                l_approver_order_number := null;
                l_approver_display_name := null;
                l_approver_name         := null;
    	      end if;
	    end;
            --
-- ==============================================================================
-- ================End of Initial approver from AME =============================
-- ==============================================================================

	      begin
		if g_debug then
                   hr_utility.set_location('Before target date'||l_proc,200);
		end if;

		--
		-- Calculate target end date
		--
		if nvl(x_cur.target_duration,-1) <> -1 and
		   nvl(x_cur.target_duration_uom,'ZZ') <> 'ZZ'  then
		   --
		   if x_cur.target_duration_uom = 'D' then
		      l_target_end_date := trunc(sysdate+x_cur.target_duration);
		   end if;
		   if x_cur.target_duration_uom = 'W' then
		      l_target_end_date := trunc(sysdate+x_cur.target_duration*7);
		   end if;
		   if x_cur.target_duration_uom = 'M' then
		      l_target_end_date := add_months(trunc(sysdate),x_cur.target_duration);
		   end if;
		  --
		else
		  l_target_end_date := null;
		end if;
		--
		-- Default the Performer Orig System if not already supplied
		--
                IF l_orig_system IS NULL THEN
                  l_orig_system := 'PER';
                END IF;
		--
		if g_debug then
                   hr_utility.set_location('After Target Date'||l_proc,210);
                   hr_utility.set_location('Target date '||to_char(l_target_end_date),210);
		   hr_utility.set_location('alloc_task_id '||to_char(l_allocated_task_id),210);
		end if;
		--
		PER_ALLOCATED_TASK_API.CREATE_ALLOC_TASK
                   ( p_validate                => false
                    ,p_effective_date          => p_date
                    ,p_allocated_checklist_id  => current_alloc_ckl_id
                    ,p_task_name               => x_cur.checklist_task_name
                    ,p_description             => x_cur.checklist_task_description
                    ,p_performer_orig_system   => l_orig_system
                    ,p_performer_orig_sys_id   => l_orig_system_id
		    ,p_status                  => 'INI' -- It may be better to populate by global variable
		    ,p_mandatory_flag          => x_cur.mandatory_flag
		    ,p_action_url              => x_cur.action_url
                    --,p_task_owner_person_id    =>
                    --,p_task_sequence           => 1
                    ,p_target_start_date       => trunc(sysdate)
                    ,p_target_end_date         => l_target_end_date
                    ,p_allocated_task_id       => l_allocated_task_id
                    ,p_object_version_number   => l_alloc_task_ovn
                   );
		   -- TASK_STATUS ......!!!!!
                   hr_utility.set_location('In the first loop',110);
		end;
                --
              hr_utility.set_location('after insert',70);
              --
-- ==============================================================================
-- ===============Begin of start workflow if eligible ===========================
-- ==============================================================================
	    --
            -- call workflow only if an approver is found.
            --
            if l_approver_name is not null then
               if g_debug then
                  hr_utility.set_location('Before wkflow'||l_proc,80);
                  hr_utility.set_location('approver_order num  '||to_char(l_approver_order_number),999);
               end if;
               --
               begin
                 --
                 per_checklist_events.Start_wf_Process
                            (p_person_id               => p_person_id
                            ,p_assignment_id           => p_assignment_id
                            ,p_task_name               => x_cur.checklist_task_name
			                ,p_task_description        => x_cur.checklist_task_description
                            ,p_checklist_name          => x_cur.checklist_name
			                ,p_checklist_description   => x_cur.checklist_description
            			    ,p_performer_name          => l_approver_name
			                ,p_performer_display_name  => l_approver_display_name
                            ,p_target_date             => l_target_end_date
                            ,p_total_approvers         => l_approver_count
                            ,p_current_approver_num    => l_current_approver
                            ,p_allocated_task_id       => l_allocated_task_id
                            ,p_task_in_checklist_id    => x_cur.task_in_checklist_id
                            );

		 --
                 if g_debug then
                    hr_utility.set_location('After wkflow'||l_proc,80);
                 end if;
                 --
               end;
               --
               --
	    end if;  -- approver is not null
            --
            l_orig_system           := null;
            l_orig_system_id        := null;
            l_approver_name         := null;
            l_approver_display_name := null;
            l_approver_count        := null;
            l_current_approver      := null;
            l_allocated_task_id     := null;
            --
-- ==============================================================================
-- ========================= End of Workflow ====================================
-- ==============================================================================
	 end if; -- chk_exists
         close chk_exists;
      hr_utility.set_location('In the first loop',120);
	 --
      end if;  -- BEN Eligibility engine fetches an eligible object
      --
      hr_utility.set_location('In the first loop',130);
    end loop;
    --

      hr_utility.set_location('In the first loop',140);

  exception
     when others then
        --
        raise;
        --
  end process_event;  -- Procedure

  --
  --
  -- ---------------------------------------------------------------------------------
  -- |------------------------------Allocate Tasks-----------------------------------|
  -- ---------------------------------------------------------------------------------
  --
  Procedure ALLOCATE_TASKS(errbuf  out  nocopy  varchar2
                          ,retcode out  nocopy  number
                          ,p_purge in   varchar2) as
    --
    cursor pending_events is
      SELECT person_id ,
             assignment_id ,
             effective_date,
             event_reason_id
	FROM per_ben_identified_events
	WHERE status = 'Pending'
	FOR UPDATE OF status;
  --
  l_proc    varchar2(72) ;
  l_errbuf  varchar2(2000);
  l_retcode varchar2(1000);
  --
    --l_events pending_events%rowtype;
    --
  begin
  --
    fnd_file.put_line(FND_FILE.LOG, '   Allocate Tasks Process Started');
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'Allocate_Tasks';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location('Before process call',1);
    end if;
    --
    FOR p_cur in pending_events loop
        if nvl(p_cur.assignment_id,-1) <> -1 then
          per_checklist_events.process_event
           ( p_person_id     => p_cur.person_id
            ,p_assignment_id => p_cur.assignment_id
            ,p_date          => p_cur.effective_date
            ,p_ler_event_id  => p_cur.event_reason_id
	   );
          if g_debug then
             hr_utility.set_location(l_proc||'after process event call',2);
          end if;
	else
          if g_debug then
             hr_utility.set_location(l_proc||'Before Procecss with ASG',3);
          end if;
          --
	  per_checklist_events.process_event
           ( p_person_id     => p_cur.person_id
            ,p_assignment_id => null
            ,p_date          => p_cur.effective_date
            ,p_ler_event_id  => p_cur.event_reason_id
	   );
	end if;
        if g_debug then
             hr_utility.set_location(l_proc||'After Procecss Call',4);
        end if;
      --
      -- Update the status from PENDING to Processed
      --
      UPDATE per_ben_identified_events
      SET status = 'Processed'
      WHERE CURRENT OF pending_events;
    end loop;
    --
    -- Purge records that are processed. Purges all records
    --
    if nvl(p_purge,'N') = 'Y' then
       delete from per_ben_identified_events
       where status = 'Processed';
    end if;
    --
    commit;
    --
    fnd_file.put_line(FND_FILE.LOG, '   Allocate Tasks Process Completed');
    retcode := 0;
    --
  exception
      when others then
        --
        fnd_file.put_line(FND_FILE.LOG, '   Allocate Tasks Process Errored');
        errbuf  := substr(sqlerrm,0,240);
        retcode := sqlcode;
        --
        fnd_file.put_line(fnd_file.log,sqlerrm||' '||sqlcode);
        --
       raise;
  end allocate_tasks;
  --
  --
  -- ---------------------------------------------------------------------------------
  -- |---------------------------Allocate Person Tasks-------------------------------|
  -- ---------------------------------------------------------------------------------
  --
  Procedure ALLOCATE_PERSON_TASKS(p_person_id in number) as
    --
    cursor pending_events is
      SELECT person_id ,
             assignment_id ,
             effective_date,
             event_reason_id
	FROM per_ben_identified_events
	WHERE status = 'Pending'
	AND   person_id = p_person_id
	FOR UPDATE OF status;

    --l_events pending_events%rowtype;
    l_proc varchar2(72) ;
    --
    --
  begin
    --
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'Allocate_person_tasks';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location('Before process call',1);
    end if;
    --
    FOR p_cur in pending_events loop
        if nvl(p_cur.assignment_id,-1) <> -1 then
          per_checklist_events.process_event
           ( p_person_id     => p_cur.person_id
            ,p_assignment_id => p_cur.assignment_id
            ,p_date          => p_cur.effective_date
            ,p_ler_event_id  => p_cur.event_reason_id
	   );
        hr_utility.set_location('after process call',2);
	else
        hr_utility.set_location('after process call',3);
	  per_checklist_events.process_event
           ( p_person_id     => p_cur.person_id
            ,p_assignment_id => null
            ,p_date          => p_cur.effective_date
            ,p_ler_event_id  => p_cur.event_reason_id
	   );
	end if;
        hr_utility.set_location('after process call',4);
      --
      -- Update the status from PENDING to Processed
      --
      UPDATE per_ben_identified_events
      SET status = 'Processed'
      WHERE CURRENT OF pending_events;
    end loop;

    --

    commit;
    if g_debug then
      hr_utility.set_location('Leaving:'|| l_proc, 100);
    end if;
    --
  exception
      when others then
       raise;
  end allocate_person_tasks;
  --
  -- ------------------------------------------------------------------------
  -- |----------------------< Start_WF_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
  -- Description
  --
  --    Initialize the Checklist Workflow process
  --
  --
  procedure START_WF_PROCESS (p_person_id                in number
                             ,p_assignment_id            in number   default null
                             ,p_checklist_name           in varchar2
                             ,p_checklist_description    in varchar2
            			     ,p_task_name                in varchar2
			                 ,p_task_description         in varchar2
                             ,p_performer_name           in varchar2
            			     ,p_performer_display_name   in varchar2
                             ,p_target_date              in date
			                 ,p_total_approvers          in number
            			     ,p_current_approver_num     in number default 1
			                 ,p_allocated_task_id        in number
            			     ,p_task_in_checklist_id     in number) as


  l_item_key        varchar2(240) := 'Checklist Task '||p_allocated_task_id;
  l_process         varchar2(30)  := 'PERCHECKLISTPROCESS';
  l_item_type       varchar2(8)   := 'HRCKLTSK';
  l_person_name     varchar2(240);
  l_proc            varchar2(72) ;
  l_transaction_id	varchar2(100);			-- 8861932
  --
  l_user_key varchar2(240) := l_Item_Key;
  --
  CURSOR csr_person_name is
      select FULL_NAME
      from per_all_people_f
      where person_id = p_person_id
      and trunc(sysdate) between effective_start_date and effective_end_date;

    varname        Wf_Engine.NameTabTyp;
    varvalue       Wf_Engine.TextTabTyp;
    numname        Wf_Engine.NameTabTyp;
    numvalue       Wf_Engine.NumTabTyp;
    --
    l_performer_name varchar2(3000);

  begin
     --
     g_debug := hr_utility.debug_enabled;
     if g_debug then
       l_proc := g_package||'Start_WF_Process';
       hr_utility.set_location('Entering:'|| l_proc, 10);
       hr_utility.set_location('Before process call',1);
     end if;
     --
     OPEN csr_person_name;
     FETCH csr_person_name into l_person_name;
     CLOSE csr_person_name;


      wf_engine.CreateProcess (ItemType       =>  l_Item_Type
                              ,ItemKey        =>  l_Item_Key
                              ,process        =>  l_process
                              ,User_Key   =>  l_user_key
                              ,Owner_Role =>  'COREHR' --l_task_owner -- p_task_owner
                              );

      --
      -- Here l_performer_name is role name created as adhoc
      l_transaction_id :=  p_task_in_checklist_id||'-'||p_person_id;		-- 8861932
   -- l_performer_name:=getRoleForAllApproversList(p_task_in_checklist_id);
      l_performer_name:=getRoleForAllApproversList(l_transaction_id);		-- 8861932

      varname(1)  := 'PERFORMER';
      varvalue(1) := l_performer_name;
      varname(2)  := 'PERFORMER_NAME';
      varvalue(2) := p_performer_display_name;
      varname(3)  := 'TASK';
      varvalue(3) := p_task_name;
      varname(4)  := 'TASK_DESCRIPTION';
      varvalue(4) := p_task_description;
      varname(5)  := 'CHECKLIST';
      varvalue(5) := p_checklist_name;
      varname(6)  := 'CHECKLIST_DESCRIPTION';
      varvalue(6) := p_checklist_description;
      varname(7)  := 'PERSON';
      varvalue(7) := l_person_name;

      wf_engine.SetItemAttrTextArray(l_Item_Type,l_Item_Key,varname,varvalue);
      --
      numname(1)  := 'ALLOC_TASKID';
      numvalue(1) := p_allocated_task_id;
      numname(2)  := 'TASKIN_CKLID';
      numvalue(2) := p_task_in_checklist_id;

      wf_engine.SetItemAttrNumberArray(l_Item_Type,l_Item_Key,numname,numvalue);
      --
      wf_engine.SetItemAttrDate (itemtype       => l_Item_Type
                               ,itemkey       => l_Item_Key
                               ,aname         => 'TARGETDATE'
                               ,avalue        => p_target_date
                               );

     wf_engine.StartProcess    (itemtype       => l_Item_Type
                               ,itemkey       => l_Item_Key
                               );
    --
    if g_debug then
      hr_utility.set_location('Leaving:'|| l_proc, 100);
    end if;
    --
  end start_wf_process;
  --
  -- ------------------------------------------------------------------------
  -- |----------------------< approve_wf_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
    procedure APPROVE_WF_PROCESS
    --
                 (itemtype    in varchar2,
                  itemkey     in varchar2,
                  actid       in number,
                  funcmode    in varchar2,
                  resultout   out nocopy varchar2)

    is
      l_alloc_id number;
      l_proc     varchar2(72);
      -- bug 7560762
      l_task_done_by    wf_local_roles.name%type;
      l_PERFORMER_ORIG_SYS_ID   PER_ALLOCATED_TASKS.PERFORMER_ORIG_SYS_ID%type;

      cursor c_performer_orig_sys_id(p_task_done_by    varchar2) is
      SELECT  ORIG_SYSTEM_ID
      FROM   wf_local_roles
      where  ORIG_SYSTEM = 'PER'
      and name = p_task_done_by;
      -- bug 7560762
    --
    begin
       --
       g_debug := hr_utility.debug_enabled;
       if g_debug then
         l_proc := g_package||'APPROVE_WF_PROCESS';
         hr_utility.set_location('Entering:'|| l_proc, 10);
         hr_utility.set_location(l_proc,1);
       end if;
       -- Debug code added in 120.9 removed in 120.10
       --my_test_pkg.ins_my_values(l_proc||'funmode',funcmode);
       --
       if (funcmode = 'RUN') then
         --
         --
        l_alloc_id := wf_engine.GetItemAttrNumber(
                                  itemtype         => itemtype
                                 ,itemkey          => itemkey
                                 ,aname            => 'ALLOC_TASKID'
                                 ,ignore_notfound  => false
                                 );
          --
	-- bug 7560762
        l_task_done_by  := wf_engine.GetItemAttrText(
                                  itemtype         => itemtype
                                 ,itemkey          => itemkey
                                 ,aname            => 'TASK_DONE_BY');
        hr_utility.set_location('l_task_done_by '||l_task_done_by,99);
        open c_performer_orig_sys_id(l_task_done_by);
        fetch c_performer_orig_sys_id into l_PERFORMER_ORIG_SYS_ID;
        close c_performer_orig_sys_id;
        hr_utility.set_location('l_PERFORMER_ORIG_SYS_ID '||l_PERFORMER_ORIG_SYS_ID,100);
        -- bug 7560762
        --
          update PER_ALLOCATED_TASKS
          set status = 'COM',
          performer_orig_sys_id = nvl(l_performer_orig_sys_id,performer_orig_sys_id)    -- bug 7560762
          where ALLOCATED_TASK_ID =  l_alloc_id;
      	--
          resultout := l_alloc_id || 'COMPLETE';
          --
          return;
       elsif ( funcmode = 'CANCEL' )
       then
  	  --
  	  null;
  	  --
       end if;
       --
      if g_debug then
        hr_utility.set_location('Leaving:'|| l_proc, 100);
      end if;
      --
  end approve_wf_process;
  --
  -- ------------------------------------------------------------------------
  -- |-------------------------< rejected_wf_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
   procedure REJECTED_WF_PROCESS
                 (itemtype   in varchar2,
                  itemkey    in varchar2,
                  actid	   in number,
                  funcmode   in varchar2,
                  resultout  out nocopy varchar2) is
      --
      l_alloc_id number;
      l_proc     varchar2(72);
      -- bug 7560762
      l_task_done_by    wf_local_roles.name%type;
      l_PERFORMER_ORIG_SYS_ID   PER_ALLOCATED_TASKS.PERFORMER_ORIG_SYS_ID%type;

      cursor c_performer_orig_sys_id(p_task_done_by    varchar2) is
      SELECT  ORIG_SYSTEM_ID
      FROM   wf_local_roles
      where  ORIG_SYSTEM = 'PER'
      and name = p_task_done_by;
      -- bug 7560762

      --
    begin
      --
      g_debug := hr_utility.debug_enabled;
      if g_debug then
        l_proc := g_package||'REJECT_WF_PROCESS';
        hr_utility.set_location('Entering:'|| l_proc, 10);
        hr_utility.set_location(l_proc,1);
      end if;
      --
      if (funcmode = 'RUN')
      then
        --
        l_alloc_id := wf_engine.GetItemAttrNumber(
                                  itemtype         => itemtype
                                 ,itemkey          => itemkey
                                 ,aname            => 'ALLOC_TASKID'
                                 ,ignore_notfound  => false
                                 );
        --
	-- bug 7560762 starts
        l_task_done_by  := wf_engine.GetItemAttrText(
                                  itemtype         => itemtype
                                 ,itemkey          => itemkey
                                 ,aname            => 'TASK_DONE_BY');

        open c_performer_orig_sys_id(l_task_done_by);
        fetch c_performer_orig_sys_id into l_PERFORMER_ORIG_SYS_ID;
        close c_performer_orig_sys_id;
        -- bug 7560762 ends

        update PER_ALLOCATED_TASKS
        set status = 'REJ',
        performer_orig_sys_id = nvl(l_performer_orig_sys_id,performer_orig_sys_id)    -- bug 7560762
        where ALLOCATED_TASK_ID =  l_alloc_id;
        --
        resultout := l_alloc_id || 'TASK_REJECTED';
        return;
      elsif ( funcmode = 'CANCEL' ) then
  	  --
  	  null;
  	  --
      end if;
      --
      if g_debug then
        hr_utility.set_location('Leaving:'|| l_proc, 100);
      end if;
      --
  end rejected_wf_process;
  --

  -- ------------------------------------------------------------------------
  -- |------------------------------< Process_fyi>--------------------------|
  -- ------------------------------------------------------------------------
  --
  procedure PROCESS_FYI
               (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2)
  is
    --
    l_total_approvers  number;
    l_curr_approver number;
    l_taskin_cklid     number;
    l_recipient        varchar2(320);
    l_recipient_name   varchar2(360);
    all_approvers    ame_util.approversTable2;
    process_complete varchar2(1000);
    i number;
    l_count number;
    l_t_count number;
    l_boolean boolean;
    l_proc    varchar2(72);
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'PROCESS_FYI';
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location(l_proc,1);
    end if;
    --
    --
    if (funcmode = 'RUN')
    then
      --
      l_total_approvers := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'TOTAL_APPROVERS'
                               ,ignore_notfound  => false
                               );
      l_curr_approver := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'CURRENT_APPROVER'
                               ,ignore_notfound  => false
                               );

      if l_total_approvers > 1 and (l_curr_approver < l_total_approvers)  then
	 --
         l_count := l_curr_approver+1;
         -- insert into tp_temp values ('Current Apr lcount ',l_count);
	 l_taskin_cklid    := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'TASKIN_CKLID'
                               ,ignore_notfound  => false
                               );
         begin
            ame_api2.getAllApprovers7(
                APPLICATIONIDIN              => 800,
                TRANSACTIONTYPEIN            => 'CHECKLISTID',
                TRANSACTIONIDIN              => l_taskin_cklid,
                approvalProcessCompleteYNout => process_complete,
                APPROVERSOUT                 => ALL_APPROVERS);

	    l_t_count := all_approvers.count;
            l_recipient      := all_approvers(l_count).name;
            l_recipient_name := all_approvers(l_count).display_name;

         end;
         wf_engine.SetItemAttrNumber (
	                       itemtype       => itemtype
                              ,itemkey        => itemkey
                              ,aname          => 'CURRENT_APPROVER'
                              ,avalue         => l_count
                              );
         wf_engine.SetItemAttrText (
	                       itemtype         => itemtype
                              ,itemkey          => itemkey
                              ,aname            => 'RECIPIENT'
                              ,avalue           => l_recipient
                              );
         wf_engine.SetItemAttrText (
	                       itemtype         => itemtype
                              ,itemkey          => itemkey
                              ,aname            => 'RECIPIENT_NAME'
                              ,avalue           => l_recipient_name
                              );

         resultout := 'COMPLETE:Y';
      else
         resultout := 'COMPLETE:N';
      end if;
      --
      return;
      --
    elsif ( funcmode = 'CANCEL' ) then
      --
      null;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location('Leaving:'|| l_proc, 100);
    end if;
    --
  end process_fyi;
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< Copy_Tasks >--------------------------|
  -- ------------------------------------------------------------------------
  --
  PROCEDURE Copy_Tasks (p_from_ckl_id          IN NUMBER
                       ,p_to_alloc_ckl_id      IN NUMBER
                       ,p_task_owner_person_id IN NUMBER
                       ) IS
    --
    l_proc            VARCHAR2(50);
    l_alloc_task_id   NUMBER;
    l_ovn             NUMBER;
    l_target_end_date DATE;
    --
    CURSOR c_tasks(cp_checklist_id IN NUMBER) IS
      SELECT checklist_task_name
            ,description
            ,task_sequence
            ,mandatory_flag
            ,target_duration
            ,target_duration_uom
            ,action_url
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute16
            ,attribute17
            ,attribute18
            ,attribute19
            ,attribute20
            ,information_category
            ,information1
            ,information2
            ,information3
            ,information4
            ,information5
            ,information6
            ,information7
            ,information8
            ,information9
            ,information10
            ,information11
            ,information12
            ,information13
            ,information14
            ,information15
            ,information16
            ,information17
            ,information18
            ,information19
            ,information20
      FROM per_tasks_in_checklist
      WHERE checklist_id = cp_checklist_id;
    --
    lr_tasks c_tasks%ROWTYPE;
    --
  BEGIN
    --
    l_proc:= 'per_checklist_events.copy_tasks';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    --
    OPEN c_tasks(p_from_ckl_id);
    --
    LOOP
      FETCH c_tasks INTO lr_tasks;
      EXIT WHEN c_tasks%NOTFOUND;
      --
      -- Calculate target end date
      IF lr_tasks.target_duration IS NOT NULL AND lr_tasks.target_duration_uom IS NOT NULL THEN
        IF lr_tasks.target_duration_uom = 'D' THEN
          l_target_end_date := SYSDATE + lr_tasks.target_duration;
        ELSIF lr_tasks.target_duration_uom = 'W' THEN
          l_target_end_date := SYSDATE + (7 * lr_tasks.target_duration);
        ELSIF lr_tasks.target_duration_uom = 'M' THEN
          SELECT ADD_MONTHS(SYSDATE,lr_tasks.target_duration)
          INTO l_target_end_date FROM DUAL;
        END IF;
      ELSE
        l_target_end_date := NULL;
      END IF;
      --
      per_allocated_task_api.create_alloc_task
        (p_effective_date         => SYSDATE
        ,p_allocated_checklist_id => p_to_alloc_ckl_id
        ,p_task_name              => lr_tasks.checklist_task_name
        ,p_description            => lr_tasks.description
        ,p_performer_orig_system  => 'PER'
        ,p_task_owner_person_id   => p_task_owner_person_id
        ,p_task_sequence          => lr_tasks.task_sequence
        ,p_target_start_date      => SYSDATE
        ,p_target_end_date        => l_target_end_date
        ,p_action_url             => lr_tasks.action_url
        ,p_mandatory_flag         => lr_tasks.mandatory_flag
        ,p_status                 => 'INP'
        ,p_attribute_category     => lr_tasks.attribute_category
        ,p_attribute1             => lr_tasks.attribute1
        ,p_attribute2             => lr_tasks.attribute2
        ,p_attribute3             => lr_tasks.attribute3
        ,p_attribute4             => lr_tasks.attribute4
        ,p_attribute5             => lr_tasks.attribute5
        ,p_attribute6             => lr_tasks.attribute6
        ,p_attribute7             => lr_tasks.attribute7
        ,p_attribute8             => lr_tasks.attribute8
        ,p_attribute9             => lr_tasks.attribute9
        ,p_attribute10            => lr_tasks.attribute10
        ,p_attribute11            => lr_tasks.attribute11
        ,p_attribute12            => lr_tasks.attribute12
        ,p_attribute13            => lr_tasks.attribute13
        ,p_attribute14            => lr_tasks.attribute14
        ,p_attribute15            => lr_tasks.attribute15
        ,p_attribute16            => lr_tasks.attribute16
        ,p_attribute17            => lr_tasks.attribute17
        ,p_attribute18            => lr_tasks.attribute18
        ,p_attribute19            => lr_tasks.attribute19
        ,p_attribute20            => lr_tasks.attribute20
        ,p_information_category   => lr_tasks.information_category
        ,p_information1           => lr_tasks.information1
        ,p_information2           => lr_tasks.information2
        ,p_information3           => lr_tasks.information3
        ,p_information4           => lr_tasks.information4
        ,p_information5           => lr_tasks.information5
        ,p_information6           => lr_tasks.information6
        ,p_information7           => lr_tasks.information7
        ,p_information8           => lr_tasks.information8
        ,p_information9           => lr_tasks.information9
        ,p_information10          => lr_tasks.information10
        ,p_information11          => lr_tasks.information11
        ,p_information12          => lr_tasks.information12
        ,p_information13          => lr_tasks.information13
        ,p_information14          => lr_tasks.information14
        ,p_information15          => lr_tasks.information15
        ,p_information16          => lr_tasks.information16
        ,p_information17          => lr_tasks.information17
        ,p_information18          => lr_tasks.information18
        ,p_information19          => lr_tasks.information19
        ,p_information20          => lr_tasks.information20
        ,p_allocated_task_id      => l_alloc_task_id
        ,p_object_version_number  => l_ovn
        );
    END LOOP;
    --
    CLOSE c_tasks;
    --
    hr_utility.set_location('Leaving: '|| l_proc, 20);
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RAISE;
    --
  END Copy_Tasks;
  --
  -- ER 8861932 starts
  FUNCTION get_person_id (p_transaction_id	IN VARCHAR2)  RETURN NUMBER
  IS
  l_person_id		per_people_f.person_id%type;
  BEGIN
    select substr(p_transaction_id,instr(p_transaction_id,'-')+1,length(p_transaction_id))
    INTO l_person_id FROM dual;

    RETURN l_person_id ;
  END get_person_id ;
  --
  FUNCTION get_supervisor_id (p_transaction_id	IN VARCHAR2)  RETURN NUMBER
  IS
  l_person_id		per_people_f.person_id%type;
  l_supervisor_id	per_assignments_f.supervisor_id%type;
  l_effective_date	per_ben_identified_events.effective_date%type;
  BEGIN
    select substr(p_transaction_id,instr(p_transaction_id,'-')+1,length(p_transaction_id))
    INTO l_person_id FROM dual;
    -- first get the effective_date from per_ben_identified_events table. we expect that there would be only one event with status 'PENDING'
    SELECT effective_date
    INTO l_effective_date
	FROM per_ben_identified_events
	WHERE status = 'Pending'
	AND   person_id = l_person_id;

    -- get supervisor_id from assignment table as of the effective_date
    SELECT supervisor_id INTO l_supervisor_id
    FROM per_assignments_f
    WHERE person_id = l_person_id
    AND l_effective_date BETWEEN effective_start_date AND effective_end_date
    AND assignment_type = 'E'
    AND primary_flag = 'Y';

    RETURN l_supervisor_id ;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    -- supervisor does not exist on the event date
    l_supervisor_id := NULL ;
    RETURN l_supervisor_id;
  END get_supervisor_id ;
 ---
  FUNCTION get_ame_attribute_identifier (p_transaction_id	IN VARCHAR2)  RETURN VARCHAR2
  IS
  l_ame_attribute_identifier		per_tasks_in_checklist.ame_attribute_identifier%type;
  BEGIN
	SELECT AME_ATTRIBUTE_IDENTIFIER INTO l_ame_attribute_identifier
	FROM PER_TASKS_IN_CHECKLIST
	WHERE task_in_checklist_id= substr(p_transaction_id,1,instr(p_transaction_id,'-')-1);

    RETURN l_ame_attribute_identifier ;

  END get_ame_attribute_identifier  ;
 ---
 -- ER 8861932 ends
--
end per_checklist_events;

/
