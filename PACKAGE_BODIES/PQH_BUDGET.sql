--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET" as
/* $Header: pqprochg.pkb 120.3.12000000.2 2007/04/12 13:21:57 brsinha noship $ */
   type t_org_table is table of number(15) index by binary_integer;
   p_what_org_is_del     t_org_table ;
   p_what_org_can_del    t_org_table ;
   p_what_org_is_bud     t_org_table;
   p_what_job_is_bud     t_org_table;
   p_what_pos_is_bud     t_org_table;
   p_what_pot_is_bud     t_org_table;
   p_what_grd_is_bud     t_org_table;
   type t_prd_rec is record (
        start_date date,
        unit1_value number,
        unit2_value number,
        unit3_value number);
   type t_prd_table is table of t_prd_rec  index by binary_integer;
   p_prd_unit_tab     t_prd_table ;
   g_package varchar2(100) := 'PQH_BUDGET.' ;
procedure lock_worksheet_detail(p_worksheet_detail_id   in number,
                                p_object_version_number in number default null,
                                p_status                   out nocopy varchar2) is
   l_object_version_number number;
   cursor c0 is select object_version_number
                from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id;
   l_proc varchar2(100) := g_package||'lck_wkd';
begin
  -- return 'N' if lock failed else return 'Y'
   hr_utility.set_location('inside for worksheet_detail'||p_worksheet_detail_id||l_proc,10);
   if p_object_version_number is null then
      open c0;
      fetch c0 into l_object_version_number;
      close c0;
   end if;
   begin
      hr_utility.set_location('locking for wkd'||p_worksheet_detail_id||l_proc,30);
      pqh_wdt_shd.lck(p_worksheet_detail_id => p_worksheet_detail_id,
                      p_object_version_number => nvl(p_object_version_number,l_object_version_number));
      p_status := 'Y' ;
   exception
      when others then
         hr_utility.set_location('lock failed for '||p_worksheet_detail_id||l_proc,20);
         p_status := 'N' ;
   end;
   hr_utility.set_location('out of worksheet_detail with status'||p_status||l_proc,30);
end lock_worksheet_detail;
procedure lock_wkd(p_worksheet_detail_id in number,
                   p_transaction_category_id in number,
                   p_status                     out nocopy varchar2,
                   p_working_user               out nocopy varchar2,
                   p_user_type                  out nocopy varchar2) is
   l_user_id number;
   l_user_name varchar2(200);
   l_role_name varchar2(200);
   l_person_name varchar2(200);
   l_position_name varchar2(200);
   l_max_routing_history_id number;
   -- for pulling up the record # of routing history, if it is 0 then no routing history
   cursor c0 is select max(routing_history_id) from pqh_routing_history
                where transaction_category_id = p_transaction_category_id
                and transaction_id = p_worksheet_detail_id ;
   -- for pulling up the latest routing history details if any
   cursor c1 is select person_name_to,role_name_to,position_name_to,user_name_to
                from pqh_routing_history_v
                where transaction_id = p_worksheet_detail_id
                and transaction_category_id = p_transaction_category_id
                and routing_history_id = l_max_routing_history_id ;
   -- for pulling up the manager for the delegated worksheet
   cursor c2 is select user_id from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id;
   -- for pulling up the user_details
   cursor c4(p_user_id number) is select user_name from fnd_user
                 where user_id = p_user_id;
   l_proc varchar2(100) := g_package||'lck_wkd';
begin
   hr_utility.set_location('inside for worksheet_detail'||p_worksheet_detail_id||l_proc,10);
   begin
      lock_worksheet_detail(p_worksheet_detail_id   => p_worksheet_detail_id,
                            p_status                => p_status );
   exception
      when others then
      hr_utility.set_location('exception raised '||p_worksheet_detail_id||l_proc,11);
   end;
   if nvl(p_status,'Y') = 'N' then
      hr_utility.set_location('worksheet_detail lock failed'||l_proc,12);
      open c0;
      fetch c0 into l_max_routing_history_id;
      close c0;
      hr_utility.set_location('max routing history is '||l_max_routing_history_id||l_proc,20);
      if nvl(l_max_routing_history_id,0) = 0 then
         -- routing history is not available
         hr_utility.set_location('routing history not exist '||l_proc,22);
         open c2;
         fetch c2 into l_user_id ;
         close c2;
         open c4(l_user_id);
         fetch c4 into l_user_name;
         close c4;
         p_user_type := 'D';
         p_working_user := l_user_name;
         hr_utility.set_location('manager of wkd is '||l_user_name||l_proc,30);
      else
         -- routing history is available and will be used for finding current user of wdt
         open c1;
         fetch c1 into l_person_name,l_role_name,l_position_name,l_user_name;
         close c1;
         hr_utility.set_location('routing history pulled up '||l_proc,40);
         if l_user_name is not null then
            p_user_type := 'R';
            p_working_user := l_role_name ;
            if l_user_name is not null then
               p_working_user := p_working_user ||':'||l_user_name;
            end if;
            hr_utility.set_location('working_user is '||p_working_user||l_proc,50);
         elsif l_position_name is not null then
            p_user_type := 'P';
            p_working_user := l_position_name;
            if l_user_name is not null then
               p_working_user := p_working_user ||':'||l_user_name;
            end if;
            hr_utility.set_location('working_user is '||p_working_user||l_proc,60);
         elsif l_person_name is not null then
            p_user_type := 'S';
            p_working_user := l_person_name;
            if l_user_name is not null then
               p_working_user := p_working_user ||':'||l_user_name;
            end if;
            hr_utility.set_location('working_user is '||p_working_user||l_proc,70);
         else
            hr_utility.set_location('details missing in routing history'||l_proc,80);
         end if;
      end if;
   else
      hr_utility.set_location('wkd lock pass'||l_proc,85);
   end if;
   hr_utility.set_location('out of '||l_proc,100);
   exception
      when others then
         p_status                     := 'N';
         p_working_user               := null;
         p_user_type                  := null;
         raise;
end lock_wkd;
procedure lock_children(p_worksheet_detail_id     in number,
                        p_transaction_category_id in number,
                        p_status                  in out nocopy varchar2,
                        p_working_users           in out nocopy varchar2) is
   cursor c1 is select worksheet_detail_id
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_worksheet_detail_id;
   l_working_user varchar2(200);
   l_user_type varchar2(30);
   l_proc varchar2(100) := g_package||'lck_child' ;
   l_initial_status varchar2(10) := p_status;
   l_initial_working_users varchar2(200) := p_working_users;

begin
   hr_utility.set_location('inside for worksheet_detail'||p_worksheet_detail_id||l_proc,10);
   for i in c1 loop
      lock_wkd(p_worksheet_detail_id     => i.worksheet_detail_id,
               p_transaction_category_id => p_transaction_category_id,
               p_status                  => p_status,
               p_working_user            => l_working_user,
               p_user_type               => l_user_type );
      hr_utility.set_location('done locking of '||i.worksheet_detail_id||l_proc,13);
      if p_status = 'N' then
         -- lock failed
-- commented lines are there so that we don't show the user_type to user.
         if p_working_users is null then
 --         p_working_users := l_user_type||':'||l_working_user;
            p_working_users := l_working_user;
         else
 --         p_working_users := p_working_users||','||l_user_type||':'||l_working_user;
            p_working_users := p_working_users||','||l_working_user;
         end if;
      else
         hr_utility.set_location('all lock successful '||l_proc,14);
      end if;
      hr_utility.set_location('working users '||p_working_users||l_proc,15);
   end loop;
   hr_utility.set_location('done for worksheet_detail'||p_worksheet_detail_id||l_proc,40);
   exception when others then
   p_status := l_initial_status;
   p_working_users := l_initial_working_users;
   raise;
end lock_children;
procedure lock_all_children(p_worksheet_detail_id     in number,
                            p_transaction_category_id in number,
                            p_status                  in out nocopy varchar2,
                            p_working_users           in out nocopy varchar2) is
   cursor c1 is select worksheet_detail_id
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_worksheet_detail_id
                and action_cd ='D';
   l_working_user varchar2(200);
   l_user_type varchar2(30);
   l_proc varchar2(100) := g_package||'lck_all_child' ;
   l_initial_status varchar2(10) := p_status;
   l_initial_working_users varchar2(200) := p_working_users;
begin
   hr_utility.set_location('inside for worksheet_detail'||p_worksheet_detail_id||l_proc,10);
   for i in c1 loop
      hr_utility.set_location('doing locking for '||i.worksheet_detail_id||l_proc,11);
      lock_all_children(p_worksheet_detail_id     => i.worksheet_detail_id,
                        p_transaction_category_id => p_transaction_category_id,
                        p_status                  => p_status,
                        p_working_users           => p_working_users);
      hr_utility.set_location('doing locking children of '||i.worksheet_detail_id||l_proc,12);
      lock_wkd(p_worksheet_detail_id     => i.worksheet_detail_id,
               p_transaction_category_id => p_transaction_category_id,
               p_status                  => p_status,
               p_working_user            => l_working_user,
               p_user_type               => l_user_type );
      hr_utility.set_location('done locking of '||i.worksheet_detail_id||l_proc,13);
      if p_status = 'N' then
         -- lock failed
-- commented lines are there so that we don't show the user_type to user.
         if p_working_users is null then
 --         p_working_users := l_user_type||':'||l_working_user;
            p_working_users := l_working_user;
         else
 --         p_working_users := p_working_users||','||l_user_type||':'||l_working_user;
            p_working_users := p_working_users||','||l_working_user;
         end if;
      else
         hr_utility.set_location('all lock successful '||l_proc,14);
      end if;
      hr_utility.set_location('working users '||p_working_users||l_proc,15);
   end loop;
   hr_utility.set_location('done for worksheet_detail'||p_worksheet_detail_id||l_proc,40);
exception when others then
p_status := l_initial_status;
p_working_users := l_initial_working_users;
raise;
end lock_all_children;
procedure complete_workflow(p_worksheet_detail_id       in number,
                            p_transaction_category_id   in number,
                            p_result_status             in varchar2,
                            p_wks_object_version_number    out nocopy number,
                            p_wkd_object_version_number    out nocopy number) is
   l_workflow_name varchar2(200);
   l_itemkey       varchar2(200);
   cursor c_child is
                 select worksheet_detail_id,status,object_version_number
                 from pqh_worksheet_details
                 where action_cd ='D'
                 and parent_worksheet_detail_id = p_worksheet_detail_id;
   l_proc varchar2(100) := g_package||'complete_workflow' ;
   l_wkd_ovn number;
   l_wkd1_ovn number;
   l_worksheet_id number;
   l_parent_wkd_id number ;
   l_status varchar2(30);
   l_wks_ovn number;
   l_number number;
begin
   hr_utility.set_location('inside '||l_proc,10);
   l_workflow_name := pqh_wf.get_workflow_name(p_transaction_category_id => p_transaction_category_id);
   hr_utility.set_location('workflow name is '||l_workflow_name||l_proc,20);
   select wkd.status,wkd.parent_worksheet_detail_id,wkd.object_version_number,
          wks.worksheet_id,wks.object_version_number
   into l_status,l_parent_wkd_id,l_wkd_ovn,l_worksheet_id,l_wks_ovn
   from pqh_worksheet_details wkd, pqh_worksheets wks
   where wkd.worksheet_detail_id = p_worksheet_detail_id
   and wkd.worksheet_id = wks.worksheet_id;
   if p_result_status = 'REJECT' then
      hr_utility.set_location('result_status is '||p_result_status||l_proc,30);
      hr_utility.set_location('going in loop for '||p_worksheet_detail_id||l_proc,40);
      for i in c_child loop
          hr_utility.set_location('in loop for '||i.worksheet_detail_id||l_proc,50);
          l_wkd1_ovn := i.object_version_number;
          complete_workflow(p_worksheet_detail_id     => i.worksheet_detail_id,
                            p_transaction_category_id => p_transaction_category_id,
                            p_result_status           => p_result_status,
                            p_wks_object_version_number => l_number,
                            p_wkd_object_version_number   => l_wkd1_ovn);
          hr_utility.set_location('wf completed for children of'||i.worksheet_detail_id||l_proc,60);
          l_itemkey := to_char(p_transaction_category_id) ||'-'||to_char(i.worksheet_detail_id);
          hr_utility.set_location('status of the child is '||i.status,70);
          if i.status ='APPROVED' then
             -- if the delegated worksheet is approved already, in that case on the workflow it is sitting
             -- at delegate_block activity, moving it from there to end reject

             begin
                hr_utility.set_location('going for block activity completion',77);
                wf_engine.completeactivity(l_workflow_name,l_itemkey,'DELEGATE_BLOCK-1','COMPLETE');
                hr_utility.set_location('block activity completed',78);
             exception
                when others then
                   hr_utility.set_location(substr(sqlerrm,1,55),80);
                   hr_utility.set_location(substr(sqlerrm,56,55),81);
                   hr_utility.set_location('pqh_wf1_delegate is getting failed ',82);
                   raise;
             end;
             -- as delegated row was already approved, so its balances must have gone up. Those balances
             -- are to be brought down.
          elsif i.status ='DELEGATED' then
             -- if the delegated worksheet is waiting in inbox for the sender then it can be directly rejected
             begin
                hr_utility.set_location('coming to approve the delegated transaction',95);
                wf_engine.SetItemAttrText(itemtype => l_workflow_name,
                                          itemkey  => l_itemkey,
                                          aname    => 'TRANSACTION_STATUS',
                                          avalue   => 'FRC_RJCT');
                wf_engine.completeactivity(l_workflow_name,l_itemkey,'NTF_NEXT_USER','FRC_RJCT');
             exception
                when others then
                   hr_utility.set_location(substr(sqlerrm,1,55),100);
                   hr_utility.set_location(substr(sqlerrm,56,55),101);
                   hr_utility.set_location('pqh_wf2 is getting failed ',102);
                   raise;
             end;
          else
             hr_utility.set_location('status of delegated row is '||i.status,105);
          end if;
      end loop;
      hr_utility.set_location('out of loop for '||p_worksheet_detail_id||l_proc,130);
      if l_parent_wkd_id is null then
         if l_status in ('PENDING','APPROVED') then
            hr_utility.set_location('wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail(
            p_worksheet_detail_id               => p_worksheet_detail_id,
            p_effective_date                    => trunc(sysdate),
            p_object_version_number             => l_wkd_ovn,
            p_status                            => 'REJECT'
            );
            hr_utility.set_location('wks status changed from '||l_status||l_proc,110);
            pqh_worksheets_api.update_worksheet(
            p_worksheet_id          => l_worksheet_id,
            p_effective_date        => trunc(sysdate),
            p_object_version_number => l_wks_ovn,
            p_transaction_status    => 'REJECT'
            );
         else
            hr_utility.set_location('wkd status is '||l_status||l_proc,110);
         end if;
      else
         if l_status in ('DELEGATED','APPROVED') THEN
            hr_utility.set_location('child wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail(
            p_worksheet_detail_id               => p_worksheet_detail_id,
            p_effective_date                    => trunc(sysdate),
            p_object_version_number             => l_wkd_ovn,
            p_status                            => 'REJECT'
            );
         else
            hr_utility.set_location('child wkd status is '||l_status||l_proc,110);
         end if;
      end if;
      hr_utility.set_location('status updated '||p_worksheet_detail_id||l_proc,120);
   elsif p_result_status = 'APPROVED' then
      hr_utility.set_location('result_status is '||p_result_status||l_proc,140);
      for i in c_child loop
          hr_utility.set_location('in loop for '||i.worksheet_detail_id||l_proc,150);
          l_wkd1_ovn := i.object_version_number;
          complete_workflow(p_worksheet_detail_id       => i.worksheet_detail_id,
                            p_transaction_category_id   => p_transaction_category_id,
                            p_result_status             => p_result_status,
                            p_wks_object_version_number => l_number,
                            p_wkd_object_version_number => l_wkd1_ovn);
          hr_utility.set_location('wf completed for children of '||i.worksheet_detail_id||l_proc,153);
          l_itemkey := to_char(p_transaction_category_id) ||'-'||to_char(i.worksheet_detail_id);
          if i.status = 'DELEGATED' then
             begin
                wf_engine.SetItemAttrText(itemtype => l_workflow_name,
                                          itemkey  => l_itemkey,
                                          aname    => 'TRANSACTION_STATUS',
                                          avalue   => 'FRC_RJCT');
                wf_engine.completeactivity(l_workflow_name,l_itemkey,'NTF_NEXT_USER','FRC_RJCT');
             exception
                when others then
                   hr_utility.set_location(substr(sqlerrm,1,55),160);
                   hr_utility.set_location(substr(sqlerrm,56,55),161);
                   hr_utility.set_location('pqh_wf3 is getting failed ',162);
                   raise;
             end;
          end if;
          hr_utility.set_location('updating status for '||i.worksheet_detail_id||l_proc,153);
          update_worksheet_detail( p_worksheet_detail_id   => i.worksheet_detail_id,
                                   p_effective_date        => trunc(sysdate),
                                   p_object_version_number => l_wkd1_ovn,
                                   p_status                => 'APPROVED');
      end loop;
      hr_utility.set_location('out of loop '||p_worksheet_detail_id||l_proc,230);
      if l_parent_wkd_id is null then
         if l_status in ('PENDING','SUBMITTED') then
            hr_utility.set_location('wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail( p_worksheet_detail_id   => p_worksheet_detail_id,
                                     p_effective_date        => trunc(sysdate),
                                     p_object_version_number => l_wkd_ovn,
                                     p_status                => 'APPROVED');
            hr_utility.set_location('wks status changed from '||l_status||l_proc,110);
            pqh_worksheets_api.update_worksheet(
            p_worksheet_id          => l_worksheet_id,
            p_effective_date        => trunc(sysdate),
            p_object_version_number => l_wks_ovn,
            p_transaction_status    => 'APPROVED');
         else
            hr_utility.set_location('wkd status is '||l_status||l_proc,110);
         end if;
      else
         if l_status in ('DELEGATED','REJECT') THEN
            hr_utility.set_location('child wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail( p_worksheet_detail_id   => p_worksheet_detail_id,
                                     p_effective_date        => trunc(sysdate),
                                     p_object_version_number => l_wkd_ovn,
                                     p_status                => 'APPROVED');
         else
            hr_utility.set_location('child wkd status is '||l_status||l_proc,110);
         end if;
      end if;
   elsif p_result_status = 'SUBMITTED' then
      hr_utility.set_location('result_status is '||p_result_status||l_proc,140);
      if l_parent_wkd_id is null then
         if l_status in ('PENDING','APPROVED') then
            hr_utility.set_location('wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail( p_worksheet_detail_id   => p_worksheet_detail_id,
                                     p_effective_date        => trunc(sysdate),
                                     p_object_version_number => l_wkd_ovn,
                                     p_status                => 'SUBMITTED');
            hr_utility.set_location('wks status changed from '||l_status||l_proc,110);
            pqh_worksheets_api.update_worksheet(
            p_worksheet_id          => l_worksheet_id,
            p_effective_date        => trunc(sysdate),
            p_object_version_number => l_wks_ovn,
            p_transaction_status    => 'SUBMITTED');
         else
            hr_utility.set_location('wkd status is '||l_status||l_proc,110);
         end if;
      end if;
   elsif p_result_status = 'PENDING' then
      hr_utility.set_location('result_status is '||p_result_status||l_proc,140);
      if l_parent_wkd_id is null then
         if l_status in ('APPROVED') then
            hr_utility.set_location('wkd status changed from '||l_status||l_proc,110);
            update_worksheet_detail( p_worksheet_detail_id   => p_worksheet_detail_id,
                                     p_effective_date        => trunc(sysdate),
                                     p_object_version_number => l_wkd_ovn,
                                     p_status                => 'PENDING');
            hr_utility.set_location('wks status changed from '||l_status||l_proc,110);
            pqh_worksheets_api.update_worksheet(
            p_worksheet_id          => l_worksheet_id,
            p_effective_date        => trunc(sysdate),
            p_object_version_number => l_wks_ovn,
            p_transaction_status    => 'PENDING');
         else
            hr_utility.set_location('wkd status is '||l_status||l_proc,110);
         end if;
      end if;
   elsif p_result_status = 'TERMINATE' then
      l_status := pqh_apply_budget.set_status(p_transaction_category_id => p_transaction_category_id,
                                              p_transaction_id          => p_worksheet_detail_id,
                                              p_status                  => p_result_status);
      -- status is changed to terminated, get the ovn's
      select wkd.object_version_number,wks.object_version_number
      into l_wkd_ovn,l_wks_ovn
      from pqh_worksheet_details wkd, pqh_worksheets wks
      where wkd.worksheet_detail_id = p_worksheet_detail_id
      and wkd.worksheet_id = wks.worksheet_id;
   end if;
   select wkd.object_version_number, wks.object_version_number
   into l_wkd_ovn,l_wks_ovn
   from pqh_worksheet_details wkd, pqh_worksheets wks
   where wkd.worksheet_detail_id = p_worksheet_detail_id
   and wkd.worksheet_id = wks.worksheet_id;
   p_wkd_object_version_number := l_wkd_ovn;
   p_wks_object_version_number := l_wks_ovn;
   hr_utility.set_location('wkd '||p_worksheet_detail_id||' out nocopy ovn is '||l_wkd_ovn||l_proc,280);
   hr_utility.set_location('wks out nocopy ovn is '||l_wks_ovn||l_proc,290);
   hr_utility.set_location('out of '||l_proc,300);
--
-- No need for a when others exception for nocopy changes since we are not setting
--   the p_wkd_object_version_number and p_wks_object_version_number directly.
-- Also this is happening at the end of the procedure after which there is no more processing.
end;

/*
This procedure is counter to procedure in the pqh_apply_budget package named
delegate_approve (which transfers the available figures of the delegated worksheet
which is going to be approved to the parent worksheet.) This procedure checks if
the delegated rows which are already approved are going to be changed by the
propagate_worksheet_changes, if yes then changes the status to delegate and
reduces the available figures from the worksheet available
*/
procedure change_available(p_worksheet_detail_id   in number,
			   p_propagation_method    in varchar2,
			   p_object_version_number in out nocopy number) as
   cursor c1 is select budget_unit1_available ,
		       budget_unit2_available ,
		       budget_unit3_available ,
		       budget_unit1_value_type_cd,
		       budget_unit2_value_type_cd,
		       budget_unit3_value_type_cd,
		       status,organization_id,worksheet_detail_id,object_version_number,propagation_method
                from pqh_worksheet_details
		where parent_worksheet_detail_id = p_worksheet_detail_id
		and action_cd ='D'
		and status ='APPROVED'
		for update of status;
   cursor c2 is select budget_unit1_available,budget_unit2_available,
                       budget_unit3_available,worksheet_detail_id,object_version_number
		from pqh_worksheet_details
		where worksheet_detail_id = p_worksheet_detail_id;
   l_chg_unit1_available number;
   l_chg_unit2_available number;
   l_chg_unit3_available number;
   l_object_version_number number := p_object_version_number;
   l_delegate_change     varchar2(3);
   l_proc varchar2(100) := g_package||'change_available' ;
begin
   hr_utility.set_location('entering with prop method-'||p_propagation_method||l_proc,10);
   hr_utility.set_location('entering with ovn'||p_object_version_number||l_proc,11);
   hr_utility.set_location('entering for wd '||p_worksheet_detail_id||l_proc,12);
   if p_propagation_method not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_INVALID_PROPAGATION_METHOD');
      hr_utility.raise_error;
   end if;
   -- The idea is to find out wether the value will be getting changed or not for even a single field
   -- if yes in that case available figures of the parent are to be reduced by the available figures
   -- of the child and status of the child should be marked as delegate.
   for i in c1 loop
      l_delegate_change := 'N' ;
      hr_utility.set_location('for approved organization'||i.organization_id||l_proc,20);
      if p_propagation_method = 'UE' then
         if nvl(i.budget_unit1_value_type_cd,'D') = 'P'
            or nvl(i.budget_unit2_value_type_cd,'D') = 'P'
            or nvl(i.budget_unit3_value_type_cd,'D') = 'P' then
	    l_delegate_change := 'Y' ;
	 else
	    l_delegate_change := 'N' ;
	 end if;
      elsif p_propagation_method ='RP' then
	    l_delegate_change := 'Y' ;
      else
	    l_delegate_change := 'N' ;
      end if;
      l_object_version_number := i.object_version_number;
      if l_delegate_change = 'Y' then
         l_chg_unit1_available := nvl(l_chg_unit1_available,0) + nvl(i.budget_unit1_available,0);
         l_chg_unit2_available := nvl(l_chg_unit2_available,0) + nvl(i.budget_unit2_available,0);
         l_chg_unit3_available := nvl(l_chg_unit3_available,0) + nvl(i.budget_unit3_available,0);
         update_worksheet_detail( p_worksheet_detail_id   => i.worksheet_detail_id,
	                          p_effective_date        => trunc(sysdate),
	                          p_object_version_number => l_object_version_number,
                                  p_status                => 'DELEGATE');
      end if;
      change_available(p_worksheet_detail_id   => i.worksheet_detail_id,
                       p_object_version_number => l_object_version_number,
                       p_propagation_method    => i.propagation_method);
  end loop;
  hr_utility.set_location('sum to be reduced from parent calculated'||l_proc,30);
  hr_utility.set_location('unit1_available reduction by'||l_chg_unit1_available||l_proc,40);
  hr_utility.set_location('unit2_available reduction by'||l_chg_unit2_available||l_proc,50);
  hr_utility.set_location('unit3_available reduction by'||l_chg_unit3_available||l_proc,60);
-- if there is any value to be changed only then update the parent worksheet
  if nvl(l_chg_unit1_available,0) > 0
  or nvl(l_chg_unit2_available,0) > 0
  or nvl(l_chg_unit3_available,0) > 0 then
     for i in c2 loop
        hr_utility.set_location('inside other loop '||l_proc,62);
        update_worksheet_detail(p_worksheet_detail_id    => i.worksheet_detail_id,
	                        p_effective_date         => trunc(sysdate),
	                        p_object_version_number  => p_object_version_number,
                                p_budget_unit1_available => nvl(i.budget_unit1_available,0) - nvl(l_chg_unit1_available,0),
                                p_budget_unit2_available => nvl(i.budget_unit2_available,0) - nvl(l_chg_unit2_available,0),
                                p_budget_unit3_available => nvl(i.budget_unit3_available,0) - nvl(l_chg_unit3_available,0));
     end loop;
  end if;
  hr_utility.set_location('exiting with ovn'||p_object_version_number||l_proc,69);
  hr_utility.set_location('parent updated and exiting'||l_proc,70);
exception when others then
p_object_version_number := l_object_version_number;
raise;
end change_available;
procedure propagate_worksheet_changes (p_change_mode           in varchar2,
                                       p_worksheet_detail_id   in number,
				       p_budget_style_cd       in varchar2,
                                       p_new_wks_unit1_value   in number,
                                       p_new_wks_unit2_value   in number,
                                       p_new_wks_unit3_value   in number,
				       p_unit1_precision       in number,
				       p_unit2_precision       in number,
				       p_unit3_precision       in number,
				       p_unit1_aggregate       in varchar2,
				       p_unit2_aggregate       in varchar2,
				       p_unit3_aggregate       in varchar2,
                                       p_wks_unit1_available   in out nocopy number,
                                       p_wks_unit2_available   in out nocopy number,
                                       p_wks_unit3_available   in out nocopy number,
				       p_object_version_number in out nocopy number
)is
   cursor c1 is select worksheet_detail_id,budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available,
                       object_version_number
   from pqh_worksheet_details
   where parent_worksheet_detail_id = p_worksheet_detail_id
   and nvl(action_cd,'D') = 'B'
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent ;

   cursor c2 is select worksheet_detail_id,status,object_version_number,
                       budget_unit1_value,budget_unit2_value,budget_unit3_value,
		       old_unit1_value,old_unit2_value,old_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
   from pqh_worksheet_details
   where parent_worksheet_detail_id = p_worksheet_detail_id
   and nvl(action_cd,'D') = 'D'
   for update of status,budget_unit1_value,budget_unit2_value,budget_unit3_value,
		 old_unit1_value,old_unit2_value,old_unit3_value,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent ;
   cursor c3 is select wks.propagation_method
                from pqh_worksheets wks, pqh_worksheet_details wkd
		where wks.worksheet_id = wkd.worksheet_id
		and worksheet_detail_id = p_worksheet_detail_id;
   l_budget_unit1_value  number;
   l_budget_unit2_value  number;
   l_budget_unit3_value  number;
   l_budget_unit1_percent  number;
   l_budget_unit2_percent  number;
   l_budget_unit3_percent  number;
   l_wks_unit1_available number := p_wks_unit1_available;
   l_wks_unit2_available number := p_wks_unit2_available;
   l_wks_unit3_available number := p_wks_unit3_available;
   l_old_unit1_value  number;
   l_old_unit2_value  number;
   l_old_unit3_value  number;
   l_budget_unit1_available  number;
   l_budget_unit2_available  number;
   l_budget_unit3_available  number;
   l_object_version_number   number := p_object_version_number;
   l_wks_propagation_method  pqh_worksheets.propagation_method%type;
   l_proc varchar2(100) := g_package||'propagate_worksheet_changes' ;
   l_code varchar2(30);
begin
   hr_utility.set_location('entering '||l_proc,10);
   hr_utility.set_location('entering with wkd'||p_worksheet_detail_id||l_proc,11);
   hr_utility.set_location('entering with ovn'||p_object_version_number||l_proc,12);
/*
this procedure is called when there are changes are to be reflected in the details when
there are changes made at the worksheet level. As worksheet level changes are only
allowed in the case of Top down budgetthis routine won't be called in bottom down mode.
This routine subsequently calls budget detail propagtion routine.
The changes for the delegated worksheets are made only at the worksheet level and are
not passed down below.
once the delegated worksheet is opened, and values checked, if the old value is different
from the new value this routine is called to propagate the changes below.
*/
  if p_change_mode ='PC' then
     begin
        open c3;
        fetch c3 into l_wks_propagation_method;
        close c3;
     exception
	when others then
           hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
           hr_utility.raise_error;
     end;
     l_code := pqh_wks_budget.get_parent_value(p_worksheet_detail_id,l_wks_propagation_method);
  else
     l_code := p_change_mode;
  end if;
  if l_code not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_INVALID_PROPAGATION_METHOD');
      hr_utility.raise_error;
  end if;
  hr_utility.set_location('l_code is'||l_code||l_proc,35);
  if p_budget_style_cd ='TOP' then
     hr_utility.set_location('before change_available '||l_proc,36);
     change_available(p_worksheet_detail_id   => p_worksheet_detail_id,
		      p_object_version_number => p_object_version_number,
		      p_propagation_method    => l_code );
     hr_utility.set_location('after change_available '||l_proc,37);
  end if;
  for i in c1 loop
    hr_utility.set_location('for each budgeted row '||l_proc,40);
    if l_code = 'RV' then
       hr_utility.set_location('unit1 for RV'||l_proc,45);
       if nvl(p_new_wks_unit1_value,0) <> 0 then
          l_budget_unit1_percent := round((i.budget_unit1_value * 100)/p_new_wks_unit1_value,2) ;
       else
	  l_budget_unit1_percent := null;
       end if;
       l_budget_unit1_value     := i.budget_unit1_value;
       l_budget_unit1_available := i.budget_unit1_available;
    elsif l_code = 'RP' then
       hr_utility.set_location('unit1 for RP'||l_proc,50);
       if nvl(p_new_wks_unit1_value,0) <> 0 then
          l_budget_unit1_value     := round(p_new_wks_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
          l_budget_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_wks_unit1_available    := nvl(p_wks_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
	  l_budget_unit1_value     := i.budget_unit1_value;
	  l_budget_unit1_available := i.budget_unit1_available;
       end if;
       l_budget_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE'||l_proc,55);
       if nvl(p_new_wks_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_budget_unit1_value     := round(p_new_wks_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
             l_budget_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_wks_unit1_available    := nvl(p_wks_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_budget_unit1_percent   := i.budget_unit1_percent;
	  else
	     l_budget_unit1_value     := i.budget_unit1_value;
	     l_budget_unit1_available := i.budget_unit1_available;
             l_budget_unit1_percent   := round((i.budget_unit1_value * 100)/p_new_wks_unit1_value,2) ;
          end if;
       else
	  l_budget_unit1_value     := i.budget_unit1_value;
	  l_budget_unit1_available := i.budget_unit1_available;
          l_budget_unit1_percent   := null;
       end if;
    end if;

    if l_code ='RV' then
       hr_utility.set_location('unit2 for RV'||l_proc,60);
       if nvl(p_new_wks_unit2_value,0) <> 0 then
          l_budget_unit2_percent := round((i.budget_unit2_value * 100)/p_new_wks_unit2_value,2) ;
       else
	  l_budget_unit2_percent := null;
       end if;
       l_budget_unit2_value     := i.budget_unit2_value;
       l_budget_unit2_available := i.budget_unit2_available;
    elsif l_code ='RP' then
       hr_utility.set_location('unit2 for RP'||l_proc,65);
       if nvl(p_new_wks_unit2_value,0) <> 0 then
          l_budget_unit2_value     := round(p_new_wks_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
          l_budget_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_wks_unit2_available    := nvl(p_wks_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
	  l_budget_unit2_value     := i.budget_unit2_value;
	  l_budget_unit2_available := i.budget_unit2_available;
       end if;
       l_budget_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE'||l_proc,70);
       if nvl(p_new_wks_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_budget_unit2_value     := round(p_new_wks_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
             l_budget_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_wks_unit2_available    := nvl(p_wks_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_budget_unit2_percent   := i.budget_unit2_percent;
	  else
	     l_budget_unit2_value     := i.budget_unit2_value;
	     l_budget_unit2_available := i.budget_unit2_available;
             l_budget_unit2_percent   := round((i.budget_unit2_value * 100)/p_new_wks_unit2_value,2) ;
          end if;
       else
	  l_budget_unit2_value     := i.budget_unit2_value;
	  l_budget_unit2_available := i.budget_unit2_available;
          l_budget_unit2_percent   := null;
       end if;
    end if;

    if l_code ='RV' then
       hr_utility.set_location('unit3 for RV'||l_proc,75);
       if nvl(p_new_wks_unit3_value,0) <> 0 then
          l_budget_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_wks_unit3_value,2) ;
       else
	  l_budget_unit3_percent := null;
       end if;
       l_budget_unit3_value     := i.budget_unit3_value;
       l_budget_unit3_available := i.budget_unit3_available;
    elsif l_code ='RP' then
       hr_utility.set_location('unit3 for RP'||l_proc,80);
       if nvl(p_new_wks_unit3_value,0) <> 0 then
          l_budget_unit3_value     := round(p_new_wks_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
          l_budget_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_wks_unit3_available    := nvl(p_wks_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
	  l_budget_unit3_value     := i.budget_unit3_value;
	  l_budget_unit3_available := i.budget_unit3_available;
       end if;
       l_budget_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE'||l_proc,85);
       if nvl(p_new_wks_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_budget_unit3_value     := round(p_new_wks_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
             l_budget_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_wks_unit3_available    := nvl(p_wks_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_budget_unit3_percent := i.budget_unit3_percent;
	  else
	     l_budget_unit3_value     := i.budget_unit3_value;
	     l_budget_unit3_available := i.budget_unit3_available;
             l_budget_unit3_percent   := round((i.budget_unit3_value * 100)/p_new_wks_unit3_value,2) ;
          end if;
       else
	  l_budget_unit3_value     := i.budget_unit3_value;
	  l_budget_unit3_available := i.budget_unit3_available;
          l_budget_unit3_percent   := null;
       end if;
    end if;
    hr_utility.set_location('before calling propagate_budget_changes'||l_proc,90);
    hr_utility.set_location('values passed are'||l_proc,95);
    hr_utility.set_location('unit1_value'||l_budget_unit1_value||l_proc,100);
    hr_utility.set_location('unit2_value'||l_budget_unit2_value||l_proc,101);
    hr_utility.set_location('unit3_value'||l_budget_unit3_value||l_proc,102);
    hr_utility.set_location('unit1_available'||l_budget_unit1_available||l_proc,103);
    hr_utility.set_location('unit2_available'||l_budget_unit2_available||l_proc,104);
    hr_utility.set_location('unit3_available'||l_budget_unit3_available||l_proc,105);
    l_object_version_number := i.object_version_number;
    propagate_budget_changes(p_change_mode         => l_code,
                             p_worksheet_detail_id => i.worksheet_detail_id,
                             p_new_bgt_unit1_value => l_budget_unit1_value,
                             p_new_bgt_unit2_value => l_budget_unit2_value,
                             p_new_bgt_unit3_value => l_budget_unit3_value,
			     p_unit1_precision     => p_unit1_precision,
			     p_unit2_precision     => p_unit2_precision,
			     p_unit3_precision     => p_unit3_precision,
			     p_unit1_aggregate     => p_unit1_aggregate,
			     p_unit2_aggregate     => p_unit2_aggregate,
			     p_unit3_aggregate     => p_unit3_aggregate,
                             p_bgt_unit1_available => l_budget_unit1_available,
                             p_bgt_unit2_available => l_budget_unit2_available,
                             p_bgt_unit3_available => l_budget_unit3_available);
    hr_utility.set_location('values returned are'||l_proc,110);
    hr_utility.set_location('unit1_available'||l_budget_unit1_available||l_proc,113);
    hr_utility.set_location('unit2_available'||l_budget_unit2_available||l_proc,114);
    hr_utility.set_location('unit3_available'||l_budget_unit3_available||l_proc,115);
    update_worksheet_detail( p_worksheet_detail_id    => i.worksheet_detail_id,
                             p_effective_date         => trunc(sysdate),
                             p_budget_unit1_percent   => l_budget_unit1_percent,
                             p_budget_unit1_value     => l_budget_unit1_value,
                             p_budget_unit2_percent   => l_budget_unit2_percent,
                             p_budget_unit2_value     => l_budget_unit2_value,
                             p_budget_unit3_percent   => l_budget_unit3_percent,
                             p_budget_unit3_value     => l_budget_unit3_value,
                             p_budget_unit1_available => l_budget_unit1_available,
                             p_budget_unit2_available => l_budget_unit2_available,
                             p_budget_unit3_available => l_budget_unit3_available,
                             p_object_version_number  => l_object_version_number);
    hr_utility.set_location('budget row updated '||l_proc,120);
  end loop;
-- propagation to delegated worksheets
  if p_budget_style_cd ='TOP' then
    for j in c2 loop
      hr_utility.set_location('for each delegated row '||l_proc,130);
      if l_code ='RV' then
         hr_utility.set_location('unit1 for RV'||l_proc,140);
         if nvl(p_new_wks_unit1_value,0) <> 0 then
            l_budget_unit1_percent  := round((j.budget_unit1_value * 100)/p_new_wks_unit1_value,2) ;
         else
	    l_budget_unit1_percent := null;
         end if;
	 l_old_unit1_value        := j.old_unit1_value;
         l_budget_unit1_value     := j.budget_unit1_value;
         l_budget_unit1_available := j.budget_unit1_available;
      elsif l_code ='RP' then
         hr_utility.set_location('unit1 for RP'||l_proc,150);
         if nvl(p_new_wks_unit1_value,0) <> 0 then
            l_budget_unit1_value     := round(p_new_wks_unit1_value * nvl(j.budget_unit1_percent,0)/100,p_unit1_precision) ;
            l_budget_unit1_available := nvl(j.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(j.budget_unit1_value,0);
            p_wks_unit1_available    := nvl(p_wks_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(j.budget_unit1_value,0);
	    l_old_unit1_value        := nvl(j.old_unit1_value,j.budget_unit1_value);
         else
	    l_budget_unit1_value     := j.budget_unit1_value;
	    l_budget_unit1_available := j.budget_unit1_available;
	    l_old_unit1_value        := j.old_unit1_value;
         end if;
         l_budget_unit1_percent := j.budget_unit1_percent;
      else
         hr_utility.set_location('unit1 for UE'||l_proc,160);
         if nvl(p_new_wks_unit1_value,0) <> 0 then
            if j.budget_unit1_value_type_cd = 'P' then
               l_budget_unit1_value     := round(p_new_wks_unit1_value * nvl(j.budget_unit1_percent,0)/100,p_unit1_precision) ;
               l_budget_unit1_available := nvl(j.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(j.budget_unit1_value,0);
               p_wks_unit1_available    := nvl(p_wks_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(j.budget_unit1_value,0);
               l_budget_unit1_percent := j.budget_unit1_percent;
	       l_old_unit1_value        := nvl(j.old_unit1_value,j.budget_unit1_value);
	    else
	       l_budget_unit1_value     := j.budget_unit1_value;
	       l_budget_unit1_available := j.budget_unit1_available;
               l_budget_unit1_percent  := round((j.budget_unit1_value * 100)/p_new_wks_unit1_value,2) ;
	       l_old_unit1_value        := j.old_unit1_value;
            end if;
         else
	    l_budget_unit1_value     := j.budget_unit1_value;
	    l_budget_unit1_available := j.budget_unit1_available;
            l_budget_unit1_percent   := null;
	    l_old_unit1_value        := j.old_unit1_value;
         end if;
      end if;
      if l_code ='RV' then
         hr_utility.set_location('unit2 for RV'||l_proc,170);
         if nvl(p_new_wks_unit2_value,0) <> 0 then
            l_budget_unit2_percent  := round((j.budget_unit2_value * 100)/p_new_wks_unit2_value,2) ;
         else
	    l_budget_unit2_percent := null;
         end if;
	 l_old_unit2_value        := j.old_unit2_value;
         l_budget_unit2_value     := j.budget_unit2_value;
         l_budget_unit2_available := j.budget_unit2_available;
      elsif l_code ='RP' then
         hr_utility.set_location('unit2 for RP'||l_proc,180);
         if nvl(p_new_wks_unit2_value,0) <> 0 then
            l_budget_unit2_value     := round(p_new_wks_unit2_value * nvl(j.budget_unit2_percent,0)/100,p_unit2_precision) ;
            l_budget_unit2_available := nvl(j.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(j.budget_unit2_value,0);
            p_wks_unit2_available    := nvl(p_wks_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(j.budget_unit2_value,0);
	    l_old_unit2_value        := nvl(j.old_unit2_value,j.budget_unit2_value);
         else
	    l_old_unit2_value        := j.old_unit2_value;
	    l_budget_unit2_value     := j.budget_unit2_value;
	    l_budget_unit2_available := j.budget_unit2_available;
         end if;
         l_budget_unit2_percent := j.budget_unit2_percent;
      else
         hr_utility.set_location('unit2 for UE'||l_proc,190);
         if nvl(p_new_wks_unit2_value,0) <> 0 then
            if j.budget_unit2_value_type_cd = 'P' then
               l_budget_unit2_value     := round(p_new_wks_unit2_value * nvl(j.budget_unit2_percent,0)/100,p_unit2_precision) ;
               l_budget_unit2_available := nvl(j.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(j.budget_unit2_value,0);
               p_wks_unit2_available    := nvl(p_wks_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(j.budget_unit2_value,0);
               l_budget_unit2_percent   := j.budget_unit2_percent;
	       l_old_unit2_value        := nvl(j.old_unit2_value,j.budget_unit2_value);
	    else
	       l_budget_unit2_value     := j.budget_unit2_value;
	       l_budget_unit2_available := j.budget_unit2_available;
               l_budget_unit2_percent   := round((j.budget_unit2_value * 100)/p_new_wks_unit2_value,2) ;
	       l_old_unit2_value        := j.old_unit2_value;
            end if;
         else
	    l_budget_unit2_value     := j.budget_unit2_value;
	    l_budget_unit2_available := j.budget_unit2_available;
	    l_budget_unit2_percent   := null;
	    l_old_unit2_value        := j.old_unit2_value;
         end if;
      end if;
      if l_code ='RV' then
         hr_utility.set_location('unit3 for RV'||l_proc,200);
         if nvl(p_new_wks_unit3_value,0) <> 0 then
            l_budget_unit3_percent  := round((j.budget_unit3_value * 100)/p_new_wks_unit3_value,2) ;
         else
	    l_budget_unit3_percent := null;
         end if;
         l_budget_unit3_value     := j.budget_unit3_value;
         l_budget_unit3_available := j.budget_unit3_available;
	 l_old_unit3_value        := j.old_unit3_value;
      elsif l_code ='RP' then
         hr_utility.set_location('unit3 for RP'||l_proc,210);
         if nvl(p_new_wks_unit3_value,0) <> 0 then
            l_budget_unit3_value     := round(p_new_wks_unit3_value * nvl(j.budget_unit3_percent,0)/100,p_unit3_precision) ;
            l_budget_unit3_available := nvl(j.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(j.budget_unit3_value,0);
            p_wks_unit3_available    := nvl(p_wks_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(j.budget_unit3_value,0);
	    l_old_unit3_value        := nvl(j.old_unit3_value,j.budget_unit3_value);
         else
	    l_budget_unit3_value     := j.budget_unit3_value;
	    l_budget_unit3_available := j.budget_unit3_available;
	    l_old_unit3_value        := j.old_unit3_value;
         end if;
         l_budget_unit3_percent := j.budget_unit3_percent;
      else
         hr_utility.set_location('unit3 for UE'||l_proc,220);
         if nvl(p_new_wks_unit3_value,0) <> 0 then
            if j.budget_unit3_value_type_cd = 'P' then
               l_budget_unit3_value     := round(p_new_wks_unit3_value * nvl(j.budget_unit3_percent,0)/100,p_unit3_precision) ;
               l_budget_unit3_available := nvl(j.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(j.budget_unit3_value,0);
               p_wks_unit3_available    := nvl(p_wks_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(j.budget_unit3_value,0);
               l_budget_unit3_percent   := j.budget_unit3_percent;
	       l_old_unit3_value        := nvl(j.old_unit3_value,j.budget_unit3_value);
	    else
	       l_budget_unit3_value     := j.budget_unit3_value;
	       l_budget_unit3_available := j.budget_unit3_available;
               l_budget_unit3_percent   := round((j.budget_unit3_value * 100)/p_new_wks_unit3_value,2) ;
	       l_old_unit3_value        := j.old_unit3_value;
            end if;
         else
	    l_budget_unit3_value     := j.budget_unit3_value;
	    l_budget_unit3_available := j.budget_unit3_available;
	    l_budget_unit3_percent   := null;
	    l_old_unit3_value        := j.old_unit3_value;
         end if;
      end if;
      hr_utility.set_location('values passed for updating worksheet are'||l_proc,230);
      hr_utility.set_location('unit1_value'||l_budget_unit1_value||l_proc,240);
      hr_utility.set_location('unit2_value'||l_budget_unit2_value||l_proc,241);
      hr_utility.set_location('unit3_value'||l_budget_unit3_value||l_proc,242);
      hr_utility.set_location('unit1_available'||l_budget_unit1_available||l_proc,243);
      hr_utility.set_location('unit2_available'||l_budget_unit2_available||l_proc,244);
      hr_utility.set_location('unit3_available'||l_budget_unit3_available||l_proc,245);
      hr_utility.set_location('unit1_percent'||l_budget_unit1_percent||l_proc,249);
      hr_utility.set_location('unit2_percent'||l_budget_unit2_percent||l_proc,250);
      hr_utility.set_location('unit3_percent'||l_budget_unit3_percent||l_proc,251);
      l_object_version_number := j.object_version_number;
      update_worksheet_detail(
      p_worksheet_detail_id               => j.worksheet_detail_id,
      p_effective_date                    => trunc(sysdate),
      p_object_version_number             => l_object_version_number,
      p_budget_unit1_percent              => l_budget_unit1_percent,
      p_budget_unit1_value                => l_budget_unit1_value,
      p_budget_unit2_percent              => l_budget_unit2_percent,
      p_budget_unit2_value                => l_budget_unit2_value,
      p_budget_unit3_percent              => l_budget_unit3_percent,
      p_budget_unit3_value                => l_budget_unit3_value,
      p_old_unit1_value                   => l_old_unit1_value,
      p_old_unit2_value                   => l_old_unit2_value,
      p_old_unit3_value                   => l_old_unit3_value,
      p_budget_unit1_available            => l_budget_unit1_available,
      p_budget_unit2_available            => l_budget_unit2_available,
      p_budget_unit3_available            => l_budget_unit3_available
      );
      hr_utility.set_location('worksheet updated'||l_proc,260);
    end loop;
  end if;
  hr_utility.set_location('values passed out nocopy are'||l_proc,270);
  p_wks_unit1_available := round(p_wks_unit1_available,p_unit1_precision);
  p_wks_unit2_available := round(p_wks_unit2_available,p_unit2_precision);
  p_wks_unit3_available := round(p_wks_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available'||p_wks_unit1_available||l_proc,273);
  hr_utility.set_location('unit2_available'||p_wks_unit2_available||l_proc,274);
  hr_utility.set_location('unit3_available'||p_wks_unit3_available||l_proc,275);
  hr_utility.set_location('exiting with ovn'||p_object_version_number||l_proc,276);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_wks_unit1_available   := l_wks_unit1_available;
p_wks_unit2_available   := l_wks_unit2_available;
p_wks_unit3_available   := l_wks_unit3_available;
p_object_version_number := l_object_version_number;
raise;

end propagate_worksheet_changes;

procedure propagate_budget_changes (p_change_mode           in varchar2,
                                    p_worksheet_detail_id   in number,
                                    p_new_bgt_unit1_value   in number,
                                    p_new_bgt_unit2_value   in number,
                                    p_new_bgt_unit3_value   in number,
				    p_unit1_precision       in number,
				    p_unit2_precision       in number,
				    p_unit3_precision       in number,
				    p_unit1_aggregate       in varchar2,
				    p_unit2_aggregate       in varchar2,
				    p_unit3_aggregate       in varchar2,
                                    p_bgt_unit1_available   in out nocopy number,
                                    p_bgt_unit2_available   in out nocopy number,
                                    p_bgt_unit3_available   in out nocopy number
)is
   cursor c1 is select worksheet_period_id,budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
   from pqh_worksheet_periods
   where worksheet_detail_id = p_worksheet_detail_id
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available ;

   l_period_unit1_value  number;
   l_period_unit2_value  number;
   l_period_unit3_value  number;
   l_period_unit1_percent  number;
   l_period_unit2_percent  number;
   l_period_unit3_percent  number;
   l_period_unit1_available  number;
   l_period_unit2_available  number;
   l_period_unit3_available  number;
   l_bgt_unit1_available number := p_bgt_unit1_available;
   l_bgt_unit2_available number := p_bgt_unit2_available;
   l_bgt_unit3_available number := p_bgt_unit3_available;
   x_unit1_max number;
   x_unit2_max number;
   x_unit3_max number;
   x_unit1_avg number;
   x_unit2_avg number;
   x_unit3_avg number;
   x_unit1_sum number;
   x_unit2_sum number;
   x_unit3_sum number;
   l_budget_id number;
   l_proc varchar2(100) := g_package||'propagate_budget_changes' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_change_mode not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_INVALID_PROPAGATION_METHOD');
      hr_utility.raise_error;
  end if;

  /* make a call to sub_budgetrow to subtract the all period info. from the table*/
  sub_budgetrow(p_worksheet_detail_id => p_worksheet_detail_id,
                p_unit1_aggregate     => p_unit1_aggregate,
                p_unit2_aggregate     => p_unit2_aggregate,
                p_unit3_aggregate     => p_unit3_aggregate);

  for i in c1 loop
    hr_utility.set_location('for each period '||l_proc,20);
    if p_change_mode ='RV' then
       hr_utility.set_location('unit1 for RV '||l_proc,30);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          l_period_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_bgt_unit1_value,2) ;
       else
          l_period_unit1_percent := null;
       end if;
       l_period_unit1_value     := i.budget_unit1_value;
       l_period_unit1_available := i.budget_unit1_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit1 for RP '||l_proc,35);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          l_period_unit1_value  := round(p_new_bgt_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
          l_period_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_period_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_bgt_unit1_available := nvl(p_bgt_unit1_available,0) - nvl(l_period_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
	  l_period_unit1_value := i.budget_unit1_value;
	  l_period_unit1_available := i.budget_unit1_available;
       end if;
       l_period_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE '||l_proc,40);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_period_unit1_value  := round(p_new_bgt_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
             l_period_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_period_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_bgt_unit1_available := nvl(p_bgt_unit1_available,0) - nvl(l_period_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_period_unit1_percent := i.budget_unit1_percent;
	  else
	     l_period_unit1_value     := i.budget_unit1_value;
	     l_period_unit1_available := i.budget_unit1_available;
             l_period_unit1_percent   := round((i.budget_unit1_value * 100)/p_new_bgt_unit1_value,2) ;
          end if;
       else
	  l_period_unit1_value     := i.budget_unit1_value;
	  l_period_unit1_available := i.budget_unit1_available;
          l_period_unit1_percent   := i.budget_unit1_percent;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit2 for RV '||l_proc,50);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          l_period_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_bgt_unit2_value,2) ;
       else
          l_period_unit2_percent := null;
       end if;
       l_period_unit2_value     := i.budget_unit2_value;
       l_period_unit2_available := i.budget_unit2_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit2 for RP '||l_proc,60);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          l_period_unit2_value  := round(p_new_bgt_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
          l_period_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_period_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_bgt_unit2_available := nvl(p_bgt_unit2_available,0) - nvl(l_period_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
	  l_period_unit2_value := i.budget_unit2_value;
	  l_period_unit2_available := i.budget_unit2_available;
       end if;
       l_period_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE '||l_proc,70);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_period_unit2_value  := round(p_new_bgt_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
             l_period_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_period_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_bgt_unit2_available := nvl(p_bgt_unit2_available,0) - nvl(l_period_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_period_unit2_percent := i.budget_unit2_percent;
	  else
	     l_period_unit2_value := i.budget_unit2_value;
	     l_period_unit2_available := i.budget_unit2_available;
             l_period_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_bgt_unit2_value,2) ;
          end if;
       else
	  l_period_unit2_value := i.budget_unit2_value;
	  l_period_unit2_available := i.budget_unit2_available;
          l_period_unit2_percent := i.budget_unit2_percent;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit3 for RV '||l_proc,80);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          l_period_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_bgt_unit3_value,2) ;
       else
          l_period_unit3_percent := null;
       end if;
       l_period_unit3_value     := i.budget_unit3_value;
       l_period_unit3_available := i.budget_unit3_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit3 for RP '||l_proc,90);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          l_period_unit3_value  := round(p_new_bgt_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
          l_period_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_period_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_bgt_unit3_available := nvl(p_bgt_unit3_available,0) - nvl(l_period_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
	  l_period_unit3_value := i.budget_unit3_value;
	  l_period_unit3_available := i.budget_unit3_available;
       end if;
       l_period_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE '||l_proc,100);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_period_unit3_value  := round(p_new_bgt_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
             l_period_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_period_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_bgt_unit3_available := nvl(p_bgt_unit3_available,0) - nvl(l_period_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_period_unit3_percent := i.budget_unit3_percent;
	  else
	     l_period_unit3_value := i.budget_unit3_value;
	     l_period_unit3_available := i.budget_unit3_available;
             l_period_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_bgt_unit3_value,2) ;
          end if;
       else
	  l_period_unit3_value := i.budget_unit3_value;
	  l_period_unit3_available := i.budget_unit3_available;
          l_period_unit3_percent := i.budget_unit3_percent;
       end if;
    end if;
    hr_utility.set_location('calling period changes with values '||l_proc,110);
    hr_utility.set_location('unit1_value is '||l_period_unit1_value||l_proc,120);
    hr_utility.set_location('unit2_value is '||l_period_unit2_value||l_proc,121);
    hr_utility.set_location('unit3_value is '||l_period_unit3_value||l_proc,122);
    hr_utility.set_location('unit1_available is '||l_period_unit1_available||l_proc,123);
    hr_utility.set_location('unit2_available is '||l_period_unit2_available||l_proc,124);
    hr_utility.set_location('unit3_available is '||l_period_unit3_available||l_proc,125);
    propagate_period_changes (p_change_mode          => p_change_mode,
                              p_worksheet_period_id  => i.worksheet_period_id,
                              p_unit1_precision      => p_unit1_precision,
                              p_unit2_precision      => p_unit2_precision,
                              p_unit3_precision      => p_unit3_precision,
                              p_new_prd_unit1_value  => l_period_unit1_value,
                              p_new_prd_unit2_value  => l_period_unit2_value,
                              p_new_prd_unit3_value  => l_period_unit3_value,
                              p_prd_unit1_available  => l_period_unit1_available,
                              p_prd_unit2_available  => l_period_unit2_available,
                              p_prd_unit3_available  => l_period_unit3_available);
    hr_utility.set_location('after period changes values '||l_proc,130);
    hr_utility.set_location('unit1_available is '||l_period_unit1_available||l_proc,133);
    hr_utility.set_location('unit2_available is '||l_period_unit2_available||l_proc,134);
    hr_utility.set_location('unit3_available is '||l_period_unit3_available||l_proc,135);
    update pqh_worksheet_periods
    set budget_unit1_value = l_period_unit1_value,
        budget_unit2_value = l_period_unit2_value,
        budget_unit3_value = l_period_unit3_value,
        budget_unit1_percent = l_period_unit1_percent,
        budget_unit2_percent = l_period_unit2_percent,
        budget_unit3_percent = l_period_unit3_percent,
        budget_unit1_available = l_period_unit1_available,
        budget_unit2_available = l_period_unit2_available,
        budget_unit3_available = l_period_unit3_available
    where current of c1;
    hr_utility.set_location('after period updated '||l_proc,140);
  end loop;

  /* make a call to add_budgetrow to add the all period info. from the table
     and then get the available figures using each unit to be passed on to budget*/

  add_budgetrow(p_worksheet_detail_id => p_worksheet_detail_id,
                p_unit1_aggregate     => p_unit1_aggregate,
                p_unit2_aggregate     => p_unit2_aggregate,
                p_unit3_aggregate     => p_unit3_aggregate);
  chk_unit_sum(p_unit1_sum_value     => x_unit1_sum,
	       p_unit2_sum_value     => x_unit2_sum,
	       p_unit3_sum_value     => x_unit3_sum);
  chk_unit_max(p_unit1_max_value     => x_unit1_max,
	       p_unit2_max_value     => x_unit2_max,
	       p_unit3_max_value     => x_unit3_max);
  chk_unit_avg(p_unit1_avg_value     => x_unit1_avg,
	       p_unit2_avg_value     => x_unit2_avg,
	       p_unit3_avg_value     => x_unit3_avg);
  if p_unit1_aggregate ='ACCUMULATE' then
     p_bgt_unit1_available := round(nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_sum,0),p_unit1_precision);
  elsif p_unit1_aggregate='MAXIMUM' then
     p_bgt_unit1_available := round(nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_max,0),p_unit1_precision);
  elsif p_unit1_aggregate='AVERAGE' then
     p_bgt_unit1_available := round(nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_avg,0),p_unit1_precision);
  end if;
  if p_unit2_aggregate ='ACCUMULATE' then
     p_bgt_unit2_available := round(nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_sum,0),p_unit2_precision);
  elsif p_unit2_aggregate='MAXIMUM' then
     p_bgt_unit2_available := round(nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_max,0),p_unit2_precision);
  elsif p_unit2_aggregate='AVERAGE' then
     p_bgt_unit2_available := round(nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_avg,0),p_unit2_precision);
  end if;
  if p_unit3_aggregate ='ACCUMULATE' then
     p_bgt_unit3_available := round(nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_sum,0),p_unit3_precision);
  elsif p_unit3_aggregate='MAXIMUM' then
     p_bgt_unit3_available := round(nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_max,0),p_unit3_precision);
  elsif p_unit3_aggregate='AVERAGE' then
     p_bgt_unit3_available := round(nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_avg,0),p_unit3_precision);
  end if;
  hr_utility.set_location('values passed out nocopy are'||l_proc,150);
  p_bgt_unit1_available := round(p_bgt_unit1_available,p_unit1_precision);
  p_bgt_unit2_available := round(p_bgt_unit2_available,p_unit2_precision);
  p_bgt_unit3_available := round(p_bgt_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available is '||p_bgt_unit1_available||l_proc,153);
  hr_utility.set_location('unit2_available is '||p_bgt_unit2_available||l_proc,154);
  hr_utility.set_location('unit3_available is '||p_bgt_unit3_available||l_proc,155);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
  p_bgt_unit1_available := l_bgt_unit1_available;
  p_bgt_unit2_available := l_bgt_unit2_available;
  p_bgt_unit3_available := l_bgt_unit3_available;
raise;
end propagate_budget_changes;

procedure propagate_period_changes (p_change_mode          in varchar2,
                                    p_worksheet_period_id  in number,
                                    p_new_prd_unit1_value  in number,
                                    p_new_prd_unit2_value  in number,
                                    p_new_prd_unit3_value  in number,
                                    p_unit1_precision      in number,
                                    p_unit2_precision      in number,
                                    p_unit3_precision      in number,
                                    p_prd_unit1_available  in out nocopy number,
                                    p_prd_unit2_available  in out nocopy number,
                                    p_prd_unit3_available  in out nocopy number
)is
   cursor c1 is select budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
   from pqh_worksheet_budget_sets
   where worksheet_period_id = p_worksheet_period_id
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available ;

   l_budgetset_unit1_value  number;
   l_budgetset_unit2_value  number;
   l_budgetset_unit3_value  number;
   l_budgetset_unit1_available  number;
   l_budgetset_unit2_available  number;
   l_budgetset_unit3_available  number;
   l_budgetset_unit1_percent  number;
   l_budgetset_unit2_percent  number;
   l_budgetset_unit3_percent  number;
   l_prd_unit1_available number := p_prd_unit1_available;
   l_prd_unit2_available number := p_prd_unit2_available;
   l_prd_unit3_available number := p_prd_unit3_available;

   l_proc varchar2(100) := g_package||'propagate_period_changes' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_change_mode not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_INVALID_PROPAGATION_METHOD');
      hr_utility.raise_error;
  end if;
  for i in c1 loop
    if p_change_mode ='RV' then
       hr_utility.set_location('unit1 for RV '||l_proc,20);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          l_budgetset_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_prd_unit1_value,2) ;
       else
          l_budgetset_unit1_percent := null;
       end if;
       l_budgetset_unit1_value     := i.budget_unit1_value;
       l_budgetset_unit1_available := i.budget_unit1_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit1 for RP '||l_proc,30);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          l_budgetset_unit1_value  := round(p_new_prd_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
          l_budgetset_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budgetset_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_prd_unit1_available := nvl(p_prd_unit1_available,0) - nvl(l_budgetset_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
          l_budgetset_unit1_value := i.budget_unit1_value;
          l_budgetset_unit1_available := i.budget_unit1_available;
       end if;
       l_budgetset_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE '||l_proc,40);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_budgetset_unit1_value  := round(p_new_prd_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
             l_budgetset_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budgetset_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_prd_unit1_available := nvl(p_prd_unit1_available,0) - nvl(l_budgetset_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_budgetset_unit1_percent := i.budget_unit1_percent;
	  else
             l_budgetset_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_prd_unit1_value,2) ;
             l_budgetset_unit1_value := i.budget_unit1_value;
             l_budgetset_unit1_available := i.budget_unit1_available;
          end if;
       else
          l_budgetset_unit1_value := i.budget_unit1_value;
          l_budgetset_unit1_available := i.budget_unit1_available;
          l_budgetset_unit1_percent := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit2 for RV '||l_proc,50);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          l_budgetset_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_prd_unit2_value,2) ;
       else
          l_budgetset_unit2_percent := null;
       end if;
       l_budgetset_unit2_value     := i.budget_unit2_value;
       l_budgetset_unit2_available := i.budget_unit2_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit2 for RP '||l_proc,60);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          l_budgetset_unit2_value  := round(p_new_prd_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
          l_budgetset_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budgetset_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_prd_unit2_available := nvl(p_prd_unit2_available,0) - nvl(l_budgetset_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
          l_budgetset_unit2_value := i.budget_unit2_value;
          l_budgetset_unit2_available := i.budget_unit2_available;
       end if;
       l_budgetset_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE '||l_proc,70);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_budgetset_unit2_value  := round(p_new_prd_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
             l_budgetset_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budgetset_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_prd_unit2_available := nvl(p_prd_unit2_available,0) - nvl(l_budgetset_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_budgetset_unit2_percent := i.budget_unit2_percent;
	  else
             l_budgetset_unit2_value := i.budget_unit2_value;
             l_budgetset_unit2_available := i.budget_unit2_available;
             l_budgetset_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_prd_unit2_value,2) ;
          end if;
       else
          l_budgetset_unit2_value := i.budget_unit2_value;
          l_budgetset_unit2_available := i.budget_unit2_available;
          l_budgetset_unit2_percent := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit3 for RV '||l_proc,80);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          l_budgetset_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_prd_unit3_value,2) ;
       else
          l_budgetset_unit3_percent := null;
       end if;
       l_budgetset_unit3_value     := i.budget_unit3_value;
       l_budgetset_unit3_available := i.budget_unit3_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit3 for RP '||l_proc,90);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          l_budgetset_unit3_value  := round(p_new_prd_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
          l_budgetset_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budgetset_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_prd_unit3_available := nvl(p_prd_unit3_available,0) - nvl(l_budgetset_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
          l_budgetset_unit3_value := i.budget_unit3_value;
          l_budgetset_unit3_available := i.budget_unit3_available;
       end if;
       l_budgetset_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE '||l_proc,100);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_budgetset_unit3_value  := round(p_new_prd_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
             l_budgetset_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budgetset_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_prd_unit3_available := nvl(p_prd_unit3_available,0) - nvl(l_budgetset_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_budgetset_unit3_percent := i.budget_unit3_percent;
	  else
             l_budgetset_unit3_value := i.budget_unit3_value;
             l_budgetset_unit3_available := i.budget_unit3_available;
             l_budgetset_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_prd_unit3_value,2) ;
          end if;
       else
          l_budgetset_unit3_value := i.budget_unit3_value;
          l_budgetset_unit3_available := i.budget_unit3_available;
          l_budgetset_unit3_percent := null;
       end if;
    end if;
    hr_utility.set_location('before update values passed are '||l_proc,110);
    hr_utility.set_location('unit1_value '||l_budgetset_unit1_value||l_proc,120);
    hr_utility.set_location('unit2_value '||l_budgetset_unit2_value||l_proc,121);
    hr_utility.set_location('unit3_value '||l_budgetset_unit3_value||l_proc,122);
    hr_utility.set_location('unit1_percent '||l_budgetset_unit1_percent||l_proc,123);
    hr_utility.set_location('unit2_percent '||l_budgetset_unit2_percent||l_proc,124);
    hr_utility.set_location('unit3_percent '||l_budgetset_unit3_percent||l_proc,125);
    hr_utility.set_location('unit1_available '||l_budgetset_unit1_available||l_proc,126);
    hr_utility.set_location('unit2_available '||l_budgetset_unit2_available||l_proc,127);
    hr_utility.set_location('unit3_available '||l_budgetset_unit3_available||l_proc,128);
    update pqh_worksheet_budget_sets
    set budget_unit1_value = l_budgetset_unit1_value,
        budget_unit2_value = l_budgetset_unit2_value,
        budget_unit3_value = l_budgetset_unit3_value,
        budget_unit1_percent = l_budgetset_unit1_percent,
        budget_unit2_percent = l_budgetset_unit2_percent,
        budget_unit3_percent = l_budgetset_unit3_percent,
        budget_unit1_available = l_budgetset_unit1_available,
        budget_unit2_available = l_budgetset_unit2_available,
        budget_unit3_available = l_budgetset_unit3_available
    where current of c1;
  end loop;
  hr_utility.set_location('after update out nocopy values passed are '||l_proc,130);
  p_prd_unit1_available := round(p_prd_unit1_available,p_unit1_precision);
  p_prd_unit2_available := round(p_prd_unit2_available,p_unit2_precision);
  p_prd_unit3_available := round(p_prd_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available '||p_prd_unit1_available||l_proc,136);
  hr_utility.set_location('unit2_available '||p_prd_unit2_available||l_proc,137);
  hr_utility.set_location('unit3_available '||p_prd_unit3_available||l_proc,138);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_prd_unit1_available := l_prd_unit1_available;
p_prd_unit2_available := l_prd_unit2_available;
p_prd_unit3_available := l_prd_unit3_available;
raise;
end propagate_period_changes;

procedure delegate_adjustment( p_delegate_org_id            in number,
                               p_parent_wd_id               in number,
                               p_delegate_wd_id             in number,
			       p_delegate_ovn               in out nocopy number,
                               p_org_str_id                 in number,
                               p_budget_style_cd            in varchar2,
                               p_del_budget_unit1_value     in out nocopy number,
                               p_del_budget_unit2_value     in out nocopy number,
                               p_del_budget_unit3_value     in out nocopy number,
                               p_del_budget_unit1_available in out nocopy number,
                               p_del_budget_unit2_available in out nocopy number,
                               p_del_budget_unit3_available in out nocopy number,
                               p_wks_budget_unit1_value     in out nocopy number,
                               p_wks_budget_unit2_value     in out nocopy number,
                               p_wks_budget_unit3_value     in out nocopy number,
                               p_wks_budget_unit1_available in out nocopy number,
                               p_wks_budget_unit2_available in out nocopy number,
                               p_wks_budget_unit3_available in out nocopy number)
is
-- cursor c1 selects all the positions or organizations which are direct child of the parent organization
  cursor c1 is select position_id,organization_id,parent_worksheet_detail_id,worksheet_detail_id,
                      budget_unit1_percent,budget_unit1_value,budget_unit1_value_type_cd,
                      budget_unit2_percent,budget_unit2_value,budget_unit2_value_type_cd,
                      budget_unit3_percent,budget_unit3_value,budget_unit3_value_type_cd,
                      object_version_number
               from pqh_worksheet_details
               where parent_worksheet_detail_id = p_parent_wd_id
               and action_cd ='B'
               for update of parent_worksheet_detail_id ,budget_unit1_percent,budget_unit2_percent,budget_unit3_percent;

  cursor c3(p_position_id number) is
               select organization_id
               from hr_positions
               where position_id = p_position_id;
  cursor c2 is select organization_id_child
               from per_org_structure_elements
               where org_structure_version_id = p_org_str_id
               connect by prior organization_id_child = organization_id_parent
                          and org_structure_version_id = p_org_str_id
               start with organization_id_parent = p_delegate_org_id
                          and org_structure_version_id = p_org_str_id;
-- cursor c2 builds the organization tree under the delegated org.
  type tab is table of number(15) index by binary_integer;
  a tab;
  cnt number := 1;
  l_organization_id number(15);
  l_budget_unit1_percent number(15,2);
  l_budget_unit2_percent number(15,2);
  l_budget_unit3_percent number(15,2);
  l_object_version_number number;
  l_proc varchar2(100) := g_package||'delegate_adjustment' ;
  l_del_budget_unit1_value     number := p_del_budget_unit1_value;
  l_del_budget_unit2_value     number := p_del_budget_unit2_value;
  l_del_budget_unit3_value     number := p_del_budget_unit3_value;
  l_del_budget_unit1_available number := p_del_budget_unit1_available;
  l_del_budget_unit2_available number := p_del_budget_unit2_available;
  l_del_budget_unit3_available number := p_del_budget_unit3_available;
  l_wks_budget_unit1_value     number := p_wks_budget_unit1_value;
  l_wks_budget_unit2_value     number := p_wks_budget_unit2_value;
  l_wks_budget_unit3_value     number := p_wks_budget_unit3_value;
  l_wks_budget_unit1_available number := p_wks_budget_unit1_available;
  l_wks_budget_unit2_available number := p_wks_budget_unit2_available;
  l_wks_budget_unit3_available number := p_wks_budget_unit3_available;
  l_delegate_ovn number := p_delegate_ovn;
begin
-- for each delegated row all the positions or organizations which are below that organization are moved
-- to point to this worksheet detail which had been earlier pointing to the parent worksheet detail
-- in case of delegate adjustment propagation method does not effect as values are retained to calculate
-- percent
   hr_utility.set_location('entering '||l_proc,10);
   a(0) := p_delegate_org_id ;
   for i in c2 loop
      a(cnt) := i.organization_id_child ;
      cnt := cnt +1 ;
   end loop;
   hr_utility.set_location('all the children of delegated org stored'||l_proc,20);
   for j in c1 loop
      if j.organization_id is null then
         begin
            open c3(j.position_id);
            fetch c3 into l_organization_id;
            close c3;
         end;
      else
         l_organization_id := j.organization_id;
      end if;
      for k in 0..cnt-1 loop
         if l_organization_id = a(k) then
            if nvl(p_del_budget_unit1_value,0) <> 0then
               l_budget_unit1_percent := round(nvl(j.budget_unit1_value,0)*100/p_del_budget_unit1_value,2);
            else
               l_budget_unit1_percent := 0;
	    end if;
            if nvl(p_del_budget_unit2_value,0) <> 0then
               l_budget_unit2_percent := round(nvl(j.budget_unit2_value,0)*100/p_del_budget_unit2_value,2);
            else
               l_budget_unit2_percent := 0;
	    end if;
            if nvl(p_del_budget_unit3_value,0) <> 0then
               l_budget_unit3_percent := round(nvl(j.budget_unit3_value,0)*100/p_del_budget_unit3_value,2);
            else
               l_budget_unit3_percent := 0;
	    end if;
            if p_budget_style_cd ='BOTTOM' then
               p_wks_budget_unit1_value := nvl(p_wks_budget_unit1_value,0) - nvl(j.budget_unit1_value,0);
               p_wks_budget_unit2_value := nvl(p_wks_budget_unit2_value,0) - nvl(j.budget_unit2_value,0);
               p_wks_budget_unit3_value := nvl(p_wks_budget_unit3_value,0) - nvl(j.budget_unit3_value,0);
               p_del_budget_unit1_value := nvl(p_del_budget_unit1_value,0) + nvl(j.budget_unit1_value,0);
               p_del_budget_unit2_value := nvl(p_del_budget_unit2_value,0) + nvl(j.budget_unit2_value,0);
               p_del_budget_unit3_value := nvl(p_del_budget_unit3_value,0) + nvl(j.budget_unit3_value,0);
            else
               p_wks_budget_unit1_available := nvl(p_wks_budget_unit1_available,0) + nvl(j.budget_unit1_value,0);
               p_wks_budget_unit2_available := nvl(p_wks_budget_unit2_available,0) + nvl(j.budget_unit2_value,0);
               p_wks_budget_unit3_available := nvl(p_wks_budget_unit3_available,0) + nvl(j.budget_unit3_value,0);
               p_del_budget_unit1_available := nvl(p_del_budget_unit1_available,0) - nvl(j.budget_unit1_value,0);
               p_del_budget_unit2_available := nvl(p_del_budget_unit2_available,0) - nvl(j.budget_unit2_value,0);
               p_del_budget_unit3_available := nvl(p_del_budget_unit3_available,0) - nvl(j.budget_unit3_value,0);
	    end if;
            l_object_version_number := j.object_version_number;
            update_worksheet_detail(
            p_worksheet_detail_id               => j.worksheet_detail_id,
	    p_effective_date                    => trunc(sysdate),
            p_object_version_number             => l_object_version_number,
            p_parent_worksheet_detail_id        => p_delegate_wd_id,
            p_budget_unit1_percent              => l_budget_unit1_percent,
            p_budget_unit2_percent              => l_budget_unit2_percent,
            p_budget_unit3_percent              => l_budget_unit3_percent
          );
         end if;
      end loop;
   end loop;
   update_worksheet_detail(
   p_worksheet_detail_id               => p_delegate_wd_id,
   p_effective_date                    => trunc(sysdate),
   p_object_version_number             => p_delegate_ovn,
   p_budget_unit1_value                => p_del_budget_unit1_value,
   p_budget_unit2_value                => p_del_budget_unit2_value,
   p_budget_unit3_value                => p_del_budget_unit3_value,
   p_budget_unit1_available            => p_del_budget_unit1_available,
   p_budget_unit2_available            => p_del_budget_unit2_available,
   p_budget_unit3_available            => p_del_budget_unit3_available
   );
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
  p_del_budget_unit1_value     := l_del_budget_unit1_value;
  p_del_budget_unit2_value     := l_del_budget_unit2_value;
  p_del_budget_unit3_value     := l_del_budget_unit3_value;
  p_del_budget_unit1_available := l_del_budget_unit1_available;
  p_del_budget_unit2_available := l_del_budget_unit2_available;
  p_del_budget_unit3_available := l_del_budget_unit3_available;
  p_wks_budget_unit1_value     := l_wks_budget_unit1_value;
  p_wks_budget_unit2_value     := l_wks_budget_unit2_value;
  p_wks_budget_unit3_value     := l_wks_budget_unit3_value;
  p_wks_budget_unit1_available := l_wks_budget_unit1_available;
  p_wks_budget_unit2_available := l_wks_budget_unit2_available;
  p_wks_budget_unit3_available := l_wks_budget_unit3_available;
  p_delegate_ovn	       := l_delegate_ovn;
  raise;
end delegate_adjustment ;

procedure delete_delegate(p_worksheet_detail_id in number) as
   cursor c1 is select worksheet_detail_id,rowid row_id
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_worksheet_detail_id
		and action_cd ='D'
		for update of worksheet_detail_id ;
   cursor c2(p_parent_wd_id number) is
                select count(*)
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_parent_wd_id;
  l_count number;
  l_proc varchar2(100) := g_package||'delete_delegate' ;
begin
-- This program checks wether there are any children for the worksheet detail. If there then calls
-- itself with each children worksheet detail and deletes the tree.
   hr_utility.set_location('entering '||l_proc,10);
   for i in c1 loop
      begin
         open c2(i.worksheet_detail_id);
         fetch c2 into l_count;
         close c2;
      exception
	 when others then
            hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
            hr_utility.raise_error;
      end;
      hr_utility.set_location('deleting worksheet detail rowid 1 - '||i.row_id||l_proc,30);
      if l_count > 0 then
         hr_utility.set_location('goind to delete details of '||i.worksheet_detail_id||l_proc,20);
	 delete_delegate(i.worksheet_detail_id);
      end if;
      hr_utility.set_location('deleting worksheet detail '||i.worksheet_detail_id||l_proc,30);
      hr_utility.set_location('deleting worksheet detail rowid 2 - '||i.row_id||l_proc,30);
      delete from pqh_worksheet_details where rowid = i.row_id;
   end loop;
   hr_utility.set_location('exiting '||l_proc,1000);
end delete_delegate;

procedure delete_delegate_chk(p_worksheet_detail_id in number,
			      p_status_flag         out nocopy number) as
   cursor c1 is select worksheet_detail_id,status
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_worksheet_detail_id
		and action_cd ='D'
		for update of worksheet_detail_id ;
   cursor c2(p_parent_wd_id number) is
                select count(*)
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_parent_wd_id
		and action_cd ='D';
  l_proc varchar2(100) := g_package||'delete_delegate_chk' ;
  l_status number;
  l_count number;
begin
-- This program is used to tell wether the delegated row can be deleted or not. Called from the form
   hr_utility.set_location('entering '||l_proc,10);
   p_status_flag := 0;
   for i in c1 loop
      if i.status = 'DELEGATED' then
	 -- routing already done
	 p_status_flag := 1;
      else
	 p_status_flag := 2;
	 begin
            open c2(i.worksheet_detail_id);
            fetch c2 into l_count;
            close c2;
         exception
	    when others then
               hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
               hr_utility.raise_error;
         end;
         if l_count > 0 then
            hr_utility.set_location('goind to check details of '||i.worksheet_detail_id||l_proc,20);
	    delete_delegate_chk(i.worksheet_detail_id,l_status);
	    if l_status = 1 then
	       p_status_flag := 1;
	    end if;
         end if;
      end if;
   end loop;
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_status_flag := null;
raise;
end delete_delegate_chk;
procedure delete_adjustment(p_parent_wd_id           in number,
                            p_delegate_wd_id         in number,
			    p_budget_style_cd        in varchar2,
                            p_budget_unit1_value     in out nocopy number,
                            p_budget_unit2_value     in out nocopy number,
                            p_budget_unit3_value     in out nocopy number,
                            p_budget_unit1_available in out nocopy number,
                            p_budget_unit2_available in out nocopy number,
                            p_budget_unit3_available in out nocopy number)
is
  cursor c2 is select worksheet_detail_id
               from pqh_worksheet_details
               where action_cd ='D'
               and parent_worksheet_detail_id = p_delegate_wd_id ;
  cursor c1 is select action_cd,parent_worksheet_detail_id,worksheet_detail_id,
               budget_unit1_percent,budget_unit1_value,budget_unit1_value_type_cd,
               budget_unit2_percent,budget_unit2_value,budget_unit2_value_type_cd,
               budget_unit3_percent,budget_unit3_value,budget_unit3_value_type_cd,
	       object_version_number
               from pqh_worksheet_details
               where action_cd = 'B'
               and parent_worksheet_detail_id = p_delegate_wd_id
               for update of parent_worksheet_detail_id,budget_unit1_percent,budget_unit2_percent,budget_unit3_percent ;
  l_budget_unit1_percent  number(15,2);
  l_budget_unit2_percent  number(15,2);
  l_budget_unit3_percent  number(15,2);
  l_object_version_number number(15,2);
  l_proc varchar2(100) := g_package||'delete_adjustment' ;
 l_budget_unit1_value     number := p_budget_unit1_value;
 l_budget_unit2_value     number := p_budget_unit2_value;
 l_budget_unit3_value     number := p_budget_unit3_value;
 l_budget_unit1_available number := p_budget_unit1_available;
 l_budget_unit2_available number := p_budget_unit2_available;
 l_budget_unit3_available number := p_budget_unit3_available;
begin
-- delete adjustment program is called for a worksheet detail, which is going to be deleted,
-- it moves all the budgeted deatils to point to parent worksheet detail
-- and calls iteself for each delegated worksheet. This way the whole delegate tree budget rows are
-- moved to parent worksheet.

   hr_utility.set_location('entering '||l_proc,10);
   for j in c1 loop
       hr_utility.set_location('going to update values for wd '||j.worksheet_detail_id||l_proc,10);
       if nvl(p_budget_unit1_value,0) <> 0 then
          l_budget_unit1_percent := round(nvl(j.budget_unit1_value,0)*100/p_budget_unit1_value,2);
       else
          l_budget_unit1_percent := 0;
       end if;
       if nvl(p_budget_unit2_value,0) <> 0 then
          l_budget_unit2_percent := round(nvl(j.budget_unit2_value,0)*100/p_budget_unit2_value,2);
       else
          l_budget_unit2_percent := 0;
       end if;
       if nvl(p_budget_unit3_value,0) <> 0 then
          l_budget_unit3_percent := round(nvl(j.budget_unit3_value,0)*100/p_budget_unit3_value,2);
       else
          l_budget_unit3_percent := 0;
       end if;
       if p_budget_style_cd ='TOP' then
          p_budget_unit1_available := nvl(p_budget_unit1_available,0) - nvl(j.budget_unit1_value,0);
          p_budget_unit2_available := nvl(p_budget_unit2_available,0) - nvl(j.budget_unit2_value,0);
          p_budget_unit3_available := nvl(p_budget_unit3_available,0) - nvl(j.budget_unit3_value,0);
       else
          p_budget_unit1_value := nvl(p_budget_unit1_value,0) + nvl(j.budget_unit1_value,0);
          p_budget_unit2_value := nvl(p_budget_unit2_value,0) + nvl(j.budget_unit2_value,0);
          p_budget_unit3_value := nvl(p_budget_unit3_value,0) + nvl(j.budget_unit3_value,0);
       end if;

       hr_utility.set_location('going to update worksheetdetail '||j.worksheet_detail_id||l_proc,20);
       l_object_version_number := j.object_version_number;
       update_worksheet_detail(
       p_worksheet_detail_id               => j.worksheet_detail_id,
       p_effective_date                    => trunc(sysdate),
       p_object_version_number             => l_object_version_number,
       p_parent_worksheet_detail_id        => p_parent_wd_id,
       p_budget_unit1_percent              => l_budget_unit1_percent,
       p_budget_unit2_percent              => l_budget_unit2_percent,
       p_budget_unit3_percent              => l_budget_unit3_percent
       );
   end loop;
   for i in c2 loop
       hr_utility.set_location('going for details of wd'||i.worksheet_detail_id||l_proc,20);
       delete_adjustment(p_parent_wd_id           => p_parent_wd_id,
			 p_delegate_wd_id         => i.worksheet_detail_id,
			 p_budget_style_cd        => p_budget_style_cd,
                         p_budget_unit1_value     => p_budget_unit1_value,
                         p_budget_unit2_value     => p_budget_unit2_value,
                         p_budget_unit3_value     => p_budget_unit3_value,
                         p_budget_unit1_available => p_budget_unit1_available,
                         p_budget_unit2_available => p_budget_unit2_available,
                         p_budget_unit3_available => p_budget_unit3_available);
   end loop;
exception when others then
 p_budget_unit1_value     := l_budget_unit1_value;
 p_budget_unit2_value     := l_budget_unit2_value;
 p_budget_unit3_value     := l_budget_unit3_value;
 p_budget_unit1_available := l_budget_unit1_available;
 p_budget_unit2_available := l_budget_unit2_available;
 p_budget_unit3_available := l_budget_unit3_available;
 raise;
end delete_adjustment ;
procedure delegate_delete_adjustment(p_parent_wd_id           in number,
                                     p_delegate_wd_id         in number,
				     p_budget_style_cd        in varchar2,
                                     p_budget_unit1_value     in out nocopy number,
                                     p_budget_unit2_value     in out nocopy number,
                                     p_budget_unit3_value     in out nocopy number,
                                     p_budget_unit1_available in out nocopy number,
                                     p_budget_unit2_available in out nocopy number,
                                     p_budget_unit3_available in out nocopy number)
is
  l_proc varchar2(100) := g_package||'delegate_delete_adjustment' ;
 l_budget_unit1_value     number := p_budget_unit1_value;
 l_budget_unit2_value     number := p_budget_unit2_value;
 l_budget_unit3_value     number := p_budget_unit3_value;
 l_budget_unit1_available number := p_budget_unit1_available;
 l_budget_unit2_available number := p_budget_unit2_available;
 l_budget_unit3_available number := p_budget_unit3_available;
begin
   hr_utility.set_location('entering '||l_proc,10);
   delete_adjustment(p_parent_wd_id           => p_parent_wd_id,
 		     p_delegate_wd_id         => p_delegate_wd_id,
		     p_budget_style_cd        => p_budget_style_cd,
                     p_budget_unit1_value     => p_budget_unit1_value,
                     p_budget_unit2_value     => p_budget_unit2_value,
                     p_budget_unit3_value     => p_budget_unit3_value,
                     p_budget_unit1_available => p_budget_unit1_available,
                     p_budget_unit2_available => p_budget_unit2_available,
                     p_budget_unit3_available => p_budget_unit3_available);
   hr_utility.set_location('going to delete '||p_delegate_wd_id||l_proc,1000);
   delete_delegate(p_delegate_wd_id);
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
 p_budget_unit1_value     := l_budget_unit1_value;
 p_budget_unit2_value     := l_budget_unit2_value;
 p_budget_unit3_value     := l_budget_unit3_value;
 p_budget_unit1_available := l_budget_unit1_available;
 p_budget_unit2_available := l_budget_unit2_available;
 p_budget_unit3_available := l_budget_unit3_available;
 raise;
end delegate_delete_adjustment ;

/*
Insert_from_budget is a overloaded procedure .
This one copies budget details as well as their values, but it can fail if the details for the version are having values upto the limit of the budget version values.
This procedure may be removed after some time.
*/
procedure insert_from_budget(p_budget_version_id          in     number,
                             p_budgeted_entity_cd         in     varchar,
                             p_worksheet_id               in     number,
			     p_business_group_id          in     number,
			     p_start_organization_id      in     number,
                             p_parent_worksheet_detail_id in     number,
                             p_worksheet_unit1_available  in out nocopy number,
                             p_worksheet_unit2_available  in out nocopy number,
                             p_worksheet_unit3_available  in out nocopy number,
                             p_worksheet_unit1_value      in out nocopy number,
                             p_worksheet_unit2_value      in out nocopy number,
                             p_worksheet_unit3_value      in out nocopy number,
                             p_org_hier_ver               in     number,
                             p_copy_budget_periods        in     varchar2,
                             p_budget_style_cd            in     varchar,
                             p_rows_inserted                 out nocopy number) IS
  cursor c0 is select budget_unit1_value,budget_unit2_value,budget_unit3_value
               from pqh_budget_versions
               where budget_version_id = p_budget_version_id;
  cursor c1 is select position_id , grade_id, bud.organization_id organization_id, job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from pqh_budget_details bud, hr_organization_units org
               where org.business_group_id = p_business_group_id
               and bud.organization_id = org.organization_id
               and bud.budget_version_id = p_budget_version_id;
  cursor c2 is select bud.position_id, bud.grade_id, bud.organization_id , bud.job_id,bud.budget_detail_id,
                      bud.budget_unit1_value,bud.budget_unit2_value,bud.budget_unit3_value,
                      bud.budget_unit1_available,bud.budget_unit2_available,bud.budget_unit3_available,
                      bud.budget_unit1_percent,bud.budget_unit2_percent,bud.budget_unit3_percent,
                      bud.budget_unit1_value_type_cd,bud.budget_unit2_value_type_cd,bud.budget_unit3_value_type_cd
               from  (select organization_id_child from pqh_worksheet_organizations_v
		      where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual )x
	       , pqh_budget_details bud
	       where bud.budget_version_id = p_budget_version_id
               and bud.organization_id  = x.organization_id_child;
  cursor c3 is select position_id , grade_id, bud.organization_id organization_id, job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from pqh_budget_details bud, hr_organization_units org
               where org.business_group_id = p_business_group_id
               and bud.organization_id = org.organization_id
               and pqh_budget.already_budgeted_org(bud.organization_id) = 'FALSE'
               and bud.budget_version_id = p_budget_version_id;
  cursor c4 is select position_id, grade_id, organization_id , job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from  (select organization_id_child from pqh_worksheet_organizations_v
		      where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual )x
	       , pqh_budget_details
               where pqh_budget.already_budgeted_org(organization_id) = 'FALSE'
               and budget_version_id = p_budget_version_id
               and organization_id  = x.organization_id_child;
  cursor c5 is select position_id ,grade_id, organization_id , job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from pqh_budget_details
               where pqh_budget.already_budgeted_job(job_id) = 'FALSE'
               and budget_version_id = p_budget_version_id;
  cursor c6 is select position_id ,grade_id, organization_id , job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from pqh_budget_details
               where pqh_budget.already_budgeted_grd(grade_id) = 'FALSE'
               and budget_version_id = p_budget_version_id;
  cursor c7 is select position_id ,grade_id, organization_id , job_id,budget_detail_id,
                      budget_unit1_value,budget_unit2_value,budget_unit3_value,
                      budget_unit1_available,budget_unit2_available,budget_unit3_available,
                      budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                      budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd
               from pqh_budget_details
               where budget_version_id = p_budget_version_id;
  l_budget_unit1_percent number(5,2);
  l_budget_unit2_percent number(5,2);
  l_budget_unit3_percent number(5,2);
  l_budget_unit1_value number;
  l_budget_unit2_value number;
  l_budget_unit3_value number;
  l_worksheet_unit1_available  number := p_worksheet_unit1_available;
  l_worksheet_unit2_available  number := p_worksheet_unit2_available;
  l_worksheet_unit3_available  number := p_worksheet_unit3_available;
  l_worksheet_unit1_value      number := p_worksheet_unit1_value;
  l_worksheet_unit2_value      number := p_worksheet_unit2_value;
  l_worksheet_unit3_value      number := p_worksheet_unit3_value;
  l_rows_inserted number := 0;
  l_proc varchar2(100) := g_package||'insert_from_budget' ;
  l_worksheet_detail_id number;
begin
   hr_utility.set_location('entering '||l_proc,10);
-- available is made equal to value as periods and details are not fetched for the time being.
-- percent calc using the worksheet values and the existing budget values will create problem when the difference
-- in worksheet value and version value is there.
-- so it is decidied that instead of keeping the value same, we will keep the % same and compute the value.

  if p_budgeted_entity_cd = 'POSITION' then
     hr_utility.set_location('budget entity is Position '||l_proc,20);
     if p_org_hier_ver is null then
        hr_utility.set_location('org hier is null using BG '||l_proc,30);
        for i in c1 loop
           if pqh_budget.already_budgeted_pos(i.position_id) = 'FALSE' then
              l_rows_inserted := l_rows_inserted + 1;
              hr_utility.set_location('calculating new % figures'||l_proc,60);
              if p_budget_style_cd ='TOP' then
                 if nvl(p_worksheet_unit1_value,0) <> 0 then
                    l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
                 end if;
                 if nvl(p_worksheet_unit2_value,0) <> 0 then
                    l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
                 end if;
                 if nvl(p_worksheet_unit3_value,0) <> 0 then
                    l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
   	         end if;
                 p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
                 p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
                 p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
              else
                 p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0) ;
                 p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0) ;
                 p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0) ;
              end if;
              hr_utility.set_location('inserting into plsql table'||l_proc,70);
              pqh_budget.insert_pos_is_bud(i.position_id);
              hr_utility.set_location('inserting into worksheet_detail table'||l_proc,80);
              insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                     ,p_worksheet_id               => p_worksheet_id
                                     ,p_organization_id            => i.organization_id
                                     ,p_job_id                     => i.job_id
                                     ,p_position_id                => i.position_id
                                     ,p_grade_id                   => i.grade_id
                                     ,p_position_transaction_id    => ''
                                     ,p_budget_detail_id           => i.budget_detail_id
                                     ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                     ,p_user_id                    => ''
                                     ,p_action_cd                  => 'B'
                                     ,p_budget_unit1_percent       => l_budget_unit1_percent
                                     ,p_budget_unit1_value         => i.budget_unit1_value
                                     ,p_budget_unit2_percent       => l_budget_unit2_percent
                                     ,p_budget_unit2_value         => i.budget_unit2_value
                                     ,p_budget_unit3_percent       => l_budget_unit3_percent
                                     ,p_budget_unit3_value         => i.budget_unit3_value
                                     ,p_budget_unit1_value_type_cd => i.budget_unit1_value_type_cd
                                     ,p_budget_unit2_value_type_cd => i.budget_unit2_value_type_cd
                                     ,p_budget_unit3_value_type_cd => i.budget_unit3_value_type_cd
                                     ,p_status                     => ''
                                     ,p_budget_unit1_available     => i.budget_unit1_value
                                     ,p_budget_unit2_available     => i.budget_unit2_value
                                     ,p_budget_unit3_available     => i.budget_unit3_value
                                     ,p_copy_budget_periods        => p_copy_budget_periods );
              hr_utility.set_location('insert worksheet_detail table complete'||l_proc,90);
              copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id,
                                  p_copy_budget_periods    => p_copy_budget_periods,
                                  p_budget_unit1_value     => i.budget_unit1_value,
                                  p_budget_unit2_value     => i.budget_unit2_value,
                                  p_budget_unit3_value     => i.budget_unit3_value) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
        end loop;
     else
        hr_utility.set_location('using org hier '||l_proc,120);
        hr_utility.set_location('before insert loop '||l_proc,135);
        for i in c2 loop
	   if pqh_budget.already_budgeted_pos(i.position_id) = 'FALSE' then
              hr_utility.set_location('inside insert loop '||l_proc,140);
              l_rows_inserted := l_rows_inserted + 1;
   	      if p_budget_style_cd ='TOP' then
                 hr_utility.set_location('budget style top '||l_proc,141);
                 hr_utility.set_location('wks_unit1_value is '||p_worksheet_unit1_value||l_proc,141);
                 hr_utility.set_location('bgt_unit1_value is '||i.budget_unit1_value||l_proc,141);
                 if nvl(p_worksheet_unit1_value,0) <> 0 then
                    l_budget_unit1_percent := round((nvl(i.budget_unit1_value,0) * 100) / p_worksheet_unit1_value,2) ;
   	         end if;
                 hr_utility.set_location('unit1_percent cal'||l_proc,142);
                 hr_utility.set_location('wks_unit2_value is '||p_worksheet_unit2_value||l_proc,141);
                 hr_utility.set_location('bgt_unit2_value is '||i.budget_unit2_value||l_proc,141);
                 if nvl(p_worksheet_unit2_value,0) <> 0 then
                    l_budget_unit2_percent := round((nvl(i.budget_unit2_value,0) * 100) / p_worksheet_unit2_value,2) ;
   	         end if;
                 hr_utility.set_location('unit2_percent cal'||l_proc,143);
                 hr_utility.set_location('wks_unit3_value is '||p_worksheet_unit3_value||l_proc,141);
                 hr_utility.set_location('bgt_unit3_value is '||i.budget_unit3_value||l_proc,141);
                 if nvl(p_worksheet_unit3_value,0) <> 0 then
                    l_budget_unit3_percent := round((nvl(i.budget_unit3_value,0) * 100) / p_worksheet_unit3_value,2) ;
   	         end if;
                 hr_utility.set_location('unit3_percent cal'||l_proc,144);
                 p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
                 p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
                 p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
                 hr_utility.set_location('available recalc '||l_proc,145);
              else
                 hr_utility.set_location('budget style bottom '||l_proc,146);
                 p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
                 p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0);
                 p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0);
                 hr_utility.set_location('value recalc '||l_proc,147);
              end if;
              hr_utility.set_location('going for insert '||l_proc,148);
              pqh_budget.insert_pos_is_bud(i.position_id);
              insert_worksheet_detail(p_worksheet_detail_id        =>  l_worksheet_detail_id
                                     ,p_worksheet_id               =>  p_worksheet_id
                                     ,p_organization_id            =>  i.organization_id
                                     ,p_job_id                     =>  i.job_id
                                     ,p_position_id                =>  i.position_id
                                     ,p_grade_id                   =>  i.grade_id
                                     ,p_position_transaction_id    =>  ''
                                     ,p_budget_detail_id           =>  i.budget_detail_id
                                     ,p_parent_worksheet_detail_id =>  p_parent_worksheet_detail_id
                                     ,p_user_id                    =>  ''
                                     ,p_action_cd                  =>  'B'
                                     ,p_budget_unit1_percent       =>  l_budget_unit1_percent
                                     ,p_budget_unit1_value         =>  i.budget_unit1_value
                                     ,p_budget_unit2_percent       =>  l_budget_unit2_percent
                                     ,p_budget_unit2_value         =>  i.budget_unit2_value
                                     ,p_budget_unit3_percent       =>  l_budget_unit3_percent
                                     ,p_budget_unit3_value         =>  i.budget_unit3_value
                                     ,p_budget_unit1_value_type_cd =>  i.budget_unit1_value_type_cd
                                     ,p_budget_unit2_value_type_cd =>  i.budget_unit2_value_type_cd
                                     ,p_budget_unit3_value_type_cd =>  i.budget_unit3_value_type_cd
                                     ,p_status                     =>  ''
                                     ,p_budget_unit1_available     =>  i.budget_unit1_value
                                     ,p_budget_unit2_available     =>  i.budget_unit2_value
                                     ,p_budget_unit3_available     =>  i.budget_unit3_value
                                     ,p_copy_budget_periods        => p_copy_budget_periods );
              hr_utility.set_location('row inserted going for period copy'||l_proc,150);
              copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id,
                                  p_copy_budget_periods    => p_copy_budget_periods,
                                  p_budget_unit1_value     => i.budget_unit1_value,
                                  p_budget_unit2_value     => i.budget_unit2_value,
                                  p_budget_unit3_value     => i.budget_unit3_value) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
        end loop;
     end if;
  elsif p_budgeted_entity_cd ='ORGANIZATION' then
     hr_utility.set_location('budget entity organization '||l_proc,160);
     if p_org_hier_ver is null then
        hr_utility.set_location('org hier null using bg '||l_proc,170);
        hr_utility.set_location('before insert loop '||l_proc,190);
        for i in c3 loop
           l_rows_inserted := l_rows_inserted + 1;
	   if p_budget_style_cd ='TOP' then
              if nvl(p_worksheet_unit1_value,0) <> 0 then
                 l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
	      end if;
              if nvl(p_worksheet_unit2_value,0) <> 0 then
                 l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
	      end if;
              if nvl(p_worksheet_unit3_value,0) <> 0 then
                 l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
	      end if;
              p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
              p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
              p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
           else
              p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
              p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
              p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
           end if;
           pqh_budget.insert_org_is_bud(i.organization_id);
           insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                  ,p_worksheet_id               => p_worksheet_id
                                  ,p_organization_id            => i.organization_id
                                  ,p_job_id                     => i.job_id
                                  ,p_position_id                => i.position_id
                                  ,p_grade_id                   => i.grade_id
                                  ,p_position_transaction_id    => ''
                                  ,p_budget_detail_id           => i.budget_detail_id
                                  ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                  ,p_user_id                    => ''
                                  ,p_action_cd                  => 'B'
                                  ,p_budget_unit1_percent       => l_budget_unit1_percent
                                  ,p_budget_unit1_value         => i.budget_unit1_value
                                  ,p_budget_unit2_percent       => l_budget_unit2_percent
                                  ,p_budget_unit2_value         => i.budget_unit2_value
                                  ,p_budget_unit3_percent       => l_budget_unit3_percent
                                  ,p_budget_unit3_value         => i.budget_unit3_value
                                  ,p_budget_unit1_value_type_cd => i.budget_unit1_value_type_cd
                                  ,p_budget_unit2_value_type_cd => i.budget_unit2_value_type_cd
                                  ,p_budget_unit3_value_type_cd => i.budget_unit3_value_type_cd
                                  ,p_status                     => ''
                                  ,p_budget_unit1_available     => i.budget_unit1_value
                                  ,p_budget_unit2_available     => i.budget_unit2_value
                                  ,p_budget_unit3_available     => i.budget_unit3_value
                                  ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('after insert '||l_proc,200);
           copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                               p_worksheet_detail_id    => l_worksheet_detail_id,
                               p_copy_budget_periods    => p_copy_budget_periods,
                               p_budget_unit1_value     => i.budget_unit1_value,
                               p_budget_unit2_value     => i.budget_unit2_value,
                               p_budget_unit3_value     => i.budget_unit3_value) ;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
        end loop;
     else
        hr_utility.set_location('using org hier '||l_proc,210);
        hr_utility.set_location('before insert loop  '||l_proc,230);
        for i in c4 loop
           l_rows_inserted := l_rows_inserted + 1;
	   if p_budget_style_cd ='TOP' then
              if nvl(p_worksheet_unit1_value,0) <> 0 then
                 l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
	      end if;
              if nvl(p_worksheet_unit2_value,0) <> 0 then
                 l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
	      end if;
              if nvl(p_worksheet_unit3_value,0) <> 0 then
                 l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
	      end if;
              p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
              p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
              p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
           else
              p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
              p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0);
              p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0);
           end if;
           pqh_budget.insert_org_is_bud(i.organization_id);
           insert_worksheet_detail
           (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_budget_unit1_percent           =>  l_budget_unit1_percent
           ,p_budget_unit1_value             =>  i.budget_unit1_value
           ,p_budget_unit2_percent           =>  l_budget_unit2_percent
           ,p_budget_unit2_value             =>  i.budget_unit2_value
           ,p_budget_unit3_percent           =>  l_budget_unit3_percent
           ,p_budget_unit3_value             =>  i.budget_unit3_value
           ,p_budget_unit1_value_type_cd     =>  i.budget_unit1_value_type_cd
           ,p_budget_unit2_value_type_cd     =>  i.budget_unit2_value_type_cd
           ,p_budget_unit3_value_type_cd     =>  i.budget_unit3_value_type_cd
           ,p_status                         =>  ''
           ,p_budget_unit1_available         =>  i.budget_unit1_value
           ,p_budget_unit2_available         =>  i.budget_unit2_value
           ,p_budget_unit3_available         =>  i.budget_unit3_value
           ,p_old_unit1_value                =>  ''
           ,p_old_unit2_value                =>  ''
           ,p_old_unit3_value                =>  ''
           ,p_defer_flag                     =>  ''
           ,p_propagation_method             =>  ''
           ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('after insert '||l_proc,240);
           copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                               p_worksheet_detail_id    => l_worksheet_detail_id,
                               p_copy_budget_periods    => p_copy_budget_periods,
                               p_budget_unit1_value     => i.budget_unit1_value,
                               p_budget_unit2_value     => i.budget_unit2_value,
                               p_budget_unit3_value     => i.budget_unit3_value
           ) ;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
        end loop;
     end if;
  elsif p_budgeted_entity_cd ='JOB' then
     hr_utility.set_location('budget entity job'||l_proc,260);
     hr_utility.set_location('before insert loop'||l_proc,270);
     for i in c5 loop
        l_rows_inserted := l_rows_inserted + 1;
        if p_budget_style_cd = 'TOP' then
           if nvl(p_worksheet_unit1_value,0) <> 0 then
              l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
	   end if;
           if nvl(p_worksheet_unit2_value,0) <> 0 then
              l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
	   end if;
           if nvl(p_worksheet_unit3_value,0) <> 0 then
              l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
	   end if;
           p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
           p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
           p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
        else
           p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
           p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0);
           p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0);
        end if;
        pqh_budget.insert_job_is_bud(i.job_id);
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_budget_unit1_percent           =>  l_budget_unit1_percent
           ,p_budget_unit1_value             =>  i.budget_unit1_value
           ,p_budget_unit2_percent           =>  l_budget_unit2_percent
           ,p_budget_unit2_value             =>  i.budget_unit2_value
           ,p_budget_unit3_percent           =>  l_budget_unit3_percent
           ,p_budget_unit3_value             =>  i.budget_unit3_value
           ,p_budget_unit1_value_type_cd     =>  i.budget_unit1_value_type_cd
           ,p_budget_unit2_value_type_cd     =>  i.budget_unit2_value_type_cd
           ,p_budget_unit3_value_type_cd     =>  i.budget_unit3_value_type_cd
           ,p_status                         =>  ''
           ,p_budget_unit1_available         =>  i.budget_unit1_value
           ,p_budget_unit2_available         =>  i.budget_unit2_value
           ,p_budget_unit3_available         =>  i.budget_unit3_value
           ,p_copy_budget_periods        => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,280);
         hr_utility.set_location('after available change '||l_proc,290);
           copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                               p_worksheet_detail_id    => l_worksheet_detail_id,
                               p_copy_budget_periods    => p_copy_budget_periods,
                               p_budget_unit1_value     => i.budget_unit1_value,
                               p_budget_unit2_value     => i.budget_unit2_value,
                               p_budget_unit3_value     => i.budget_unit3_value) ;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
     end loop;
  elsif p_budgeted_entity_cd ='GRADE' then
     hr_utility.set_location('budget entity grade'||l_proc,300);
     hr_utility.set_location('before insert loop '||l_proc,310);
     for i in c6 loop
        l_rows_inserted := l_rows_inserted + 1;
        if p_budget_style_cd = 'TOP' then
           if nvl(p_worksheet_unit1_value,0) <> 0 then
              l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
	   end if;
           if nvl(p_worksheet_unit2_value,0) <> 0 then
              l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
           end if;
           if nvl(p_worksheet_unit3_value,0) <> 0 then
              l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
           end if;
           p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
           p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
           p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
        else
           p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
           p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0);
           p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0);
        end if;
        pqh_budget.insert_grd_is_bud(i.grade_id);
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_budget_unit1_percent           =>  l_budget_unit1_percent
           ,p_budget_unit1_value             =>  i.budget_unit1_value
           ,p_budget_unit2_percent           =>  l_budget_unit2_percent
           ,p_budget_unit2_value             =>  i.budget_unit2_value
           ,p_budget_unit3_percent           =>  l_budget_unit3_percent
           ,p_budget_unit3_value             =>  i.budget_unit3_value
           ,p_budget_unit1_value_type_cd     =>  i.budget_unit1_value_type_cd
           ,p_budget_unit2_value_type_cd     =>  i.budget_unit2_value_type_cd
           ,p_budget_unit3_value_type_cd     =>  i.budget_unit3_value_type_cd
           ,p_status                         =>  ''
           ,p_budget_unit1_available         =>  i.budget_unit1_value
           ,p_budget_unit2_available         =>  i.budget_unit2_value
           ,p_budget_unit3_available         =>  i.budget_unit3_value
           ,p_copy_budget_periods            => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,320);
         hr_utility.set_location('after available change '||l_proc,330);
           copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                               p_worksheet_detail_id    => l_worksheet_detail_id,
                               p_copy_budget_periods    => p_copy_budget_periods,
                               p_budget_unit1_value     => i.budget_unit1_value,
                               p_budget_unit2_value     => i.budget_unit2_value,
                               p_budget_unit3_value     => i.budget_unit3_value) ;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
     end loop;
  elsif p_budgeted_entity_cd ='OPEN' then
     hr_utility.set_location('budget entity OPEN '||l_proc,340);
     hr_utility.set_location('before insert loop '||l_proc,350);
     for i in c7 loop
        l_rows_inserted := l_rows_inserted + 1;
        if p_budget_style_cd = 'TOP' then
           if nvl(p_worksheet_unit1_value,0) <> 0 then
              l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_worksheet_unit1_value,2) ;
	   end if;
           if nvl(p_worksheet_unit2_value,0) <> 0 then
              l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_worksheet_unit2_value,2) ;
           end if;
           if nvl(p_worksheet_unit3_value,0) <> 0 then
              l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_worksheet_unit3_value,2) ;
           end if;
           p_worksheet_unit1_available := nvl(p_worksheet_unit1_available,0) - nvl(i.budget_unit1_value,0);
           p_worksheet_unit2_available := nvl(p_worksheet_unit2_available,0) - nvl(i.budget_unit2_value,0);
           p_worksheet_unit3_available := nvl(p_worksheet_unit3_available,0) - nvl(i.budget_unit3_value,0);
        else
            p_worksheet_unit1_value := nvl(p_worksheet_unit1_value,0) + nvl(i.budget_unit1_value,0);
            p_worksheet_unit2_value := nvl(p_worksheet_unit2_value,0) + nvl(i.budget_unit2_value,0);
            p_worksheet_unit3_value := nvl(p_worksheet_unit3_value,0) + nvl(i.budget_unit3_value,0);
        end if;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_budget_unit1_percent           =>  l_budget_unit1_percent
           ,p_budget_unit1_value             =>  i.budget_unit1_value
           ,p_budget_unit2_percent           =>  l_budget_unit2_percent
           ,p_budget_unit2_value             =>  i.budget_unit2_value
           ,p_budget_unit3_percent           =>  l_budget_unit3_percent
           ,p_budget_unit3_value             =>  i.budget_unit3_value
           ,p_budget_unit1_value_type_cd     =>  i.budget_unit1_value_type_cd
           ,p_budget_unit2_value_type_cd     =>  i.budget_unit2_value_type_cd
           ,p_budget_unit3_value_type_cd     =>  i.budget_unit3_value_type_cd
           ,p_status                         =>  ''
           ,p_budget_unit1_available         =>  i.budget_unit1_value
           ,p_budget_unit2_available         =>  i.budget_unit2_value
           ,p_budget_unit3_available         =>  i.budget_unit3_value
           ,p_copy_budget_periods        => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,360);
           copy_budget_periods(p_budget_detail_id       => i.budget_detail_id,
                               p_worksheet_detail_id    => l_worksheet_detail_id,
                               p_copy_budget_periods    => p_copy_budget_periods,
                               p_budget_unit1_value     => i.budget_unit1_value,
                               p_budget_unit2_value     => i.budget_unit2_value,
                               p_budget_unit3_value     => i.budget_unit3_value
           ) ;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
     end loop;
  end if;
  p_rows_inserted := l_rows_inserted;
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_worksheet_unit1_available  := l_worksheet_unit1_available;
p_worksheet_unit2_available  := l_worksheet_unit2_available;
p_worksheet_unit3_available  := l_worksheet_unit3_available;
p_worksheet_unit1_value      := l_worksheet_unit1_value;
p_worksheet_unit2_value      := l_worksheet_unit2_value;
p_worksheet_unit3_value      := l_worksheet_unit3_value;
p_rows_inserted		     := null;
raise;
end insert_from_budget;

procedure populate_bud_grades(p_parent_worksheet_detail_id in number,
                              p_worksheet_id               in number,
                              p_business_group_id          in number,
                              p_rows_inserted              out nocopy number) as
   l_budget_start_date date;
   l_budget_end_date date;
   l_valid_grade_flag pqh_budgets.valid_grade_reqd_flag%type;
   l_budget_entity_cd pqh_budgets.budgeted_entity_cd%type;

   cursor c0 is select budget_start_date,budget_end_date,valid_grade_reqd_flag,budgeted_entity_cd
                from pqh_budgets bge, pqh_worksheets wks
                where wks.budget_id = bge.budget_id
                and wks.worksheet_id = p_worksheet_id;
   cursor c1 is select grade_id from per_grades a
                where business_group_id = p_business_group_id
                and ((nvl(l_valid_grade_flag,'N') = 'Y' and l_budget_entity_cd = 'GRADE' and
                     a.grade_id in (select b.grade_id from per_valid_grades b
                                   where  b.date_from < l_budget_end_date
                                   and   (b.date_to > l_budget_start_date or b.date_to is null)))
                    or (nvl(l_valid_grade_flag,'N') = 'N' and date_from < l_budget_end_date
                        and (date_to > l_budget_start_date or date_to is null)));
   l_worksheet_detail_id number;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_bud_grades' ;
   l_rows_inserted number := 0;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date,l_valid_grade_flag,l_budget_entity_cd;
   close c0;
   hr_utility.set_location('budget start date '||l_budget_start_date||l_proc,11);
   hr_utility.set_location('budget end date '||l_budget_end_date||l_proc,12);
   for i in c1 loop
     if pqh_budget.already_budgeted_grd(i.grade_id) = 'FALSE' then
       l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  ''
           ,p_job_id                         =>  ''
           ,p_position_id                    =>  ''
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B');
      pqh_budget.insert_grd_is_bud(i.grade_id);
      end if;
   end loop;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_rows_inserted := null;
raise;
end populate_bud_grades;
procedure populate_bud_jobs(p_parent_worksheet_detail_id in number,
                            p_worksheet_id               in number,
                            p_business_group_id          in number,
                            p_rows_inserted                 out nocopy number) as
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_worksheets wks
                where wks.budget_id = bgt.budget_id
                and wks.worksheet_id = p_worksheet_id;
   cursor c1 is select job_id from per_jobs
		where business_group_id = p_business_group_id
                and date_from < l_budget_end_date
                and (date_to > l_budget_start_date or date_to is null);
   l_worksheet_detail_id number;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_bud_jobs' ;
   l_rows_inserted number := 0;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget start date '||l_budget_start_date||l_proc,11);
   hr_utility.set_location('budget end date '||l_budget_end_date||l_proc,12);
   for i in c1 loop
     if pqh_budget.already_budgeted_job(i.job_id) = 'FALSE' then
       l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  ''
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  ''
           ,p_grade_id                       =>  ''
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B');
          pqh_budget.insert_job_is_bud(i.job_id);
      end if;
   end loop;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,1000);
   exception
      when others then
         p_rows_inserted := null;
         raise;
end populate_bud_jobs;
procedure populate_bud_positions(p_parent_worksheet_detail_id in number,
                                 p_worksheet_id               in number,
                                 p_org_hier_ver               in number,
                                 p_start_organization_id      in number,
                                 p_business_group_id          in number,
                                 p_rows_inserted              out nocopy number) as
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_worksheets wks
                where wks.budget_id = bgt.budget_id
                and wks.worksheet_id = p_worksheet_id;
   cursor c1 is select position_id,job_id,organization_id,availability_status_id
		from hr_positions
		where business_group_id = p_business_group_id
                and effective_start_date < l_budget_end_date
                and effective_end_date > l_budget_start_date ;
   cursor csr_orgs is select organization_id_child
                      from pqh_worksheet_organizations_v
    	              where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent
                                  and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id
                                  and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual;
   cursor csr_pos(p_organization_id number) is
          select position_id,job_id,organization_id,availability_status_id
          from  hr_positions
	  where effective_start_date < l_budget_end_date
          and effective_end_date > l_budget_start_date
	  and organization_id = p_organization_id;
   l_rows_inserted number := 0;
   l_worksheet_detail_id number;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_budget_positions' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   hr_utility.set_location('business_group_id is '||p_business_group_id||l_proc,11);
   hr_utility.set_location('parent wd is '||p_parent_worksheet_detail_id||l_proc,12);
   hr_utility.set_location('org_hier is '||p_org_hier_ver||l_proc,13);
   hr_utility.set_location('worksheet id is '||p_worksheet_id||l_proc,14);
   hr_utility.set_location('start organization is '||p_start_organization_id||l_proc,15);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget start date '||l_budget_start_date||l_proc,11);
   hr_utility.set_location('budget end date '||l_budget_end_date||l_proc,12);
   if p_org_hier_ver is null then
      hr_utility.set_location('Business group cursor selected '||l_proc,20);
      for i in c1 loop
        if pqh_budget.already_budgeted_pos(i.position_id) = 'FALSE'
           and pqh_wks_budget.get_position_budget_flag(i.availability_status_id) = 'Y' then
           l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  ''
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B');
         pqh_budget.insert_pos_is_bud(i.position_id);
         hr_utility.set_location('position inserted '||i.position_id||l_proc,40);
       end if;
      end loop;
   else
      hr_utility.set_location('Org hierarchy cursor selected '||l_proc,45);
      for k in csr_orgs loop
         hr_utility.set_location('Org is'||k.organization_id_child,46);
         for i in csr_pos(k.organization_id_child) loop
            if pqh_budget.already_budgeted_pos(i.position_id) = 'FALSE'
	       and pqh_wks_budget.get_position_budget_flag(i.availability_status_id) = 'Y' then
               l_rows_inserted := l_rows_inserted + 1;
               insert_worksheet_detail ( p_worksheet_detail_id            =>  l_worksheet_detail_id
                                        ,p_worksheet_id                   =>  p_worksheet_id
                                        ,p_organization_id                =>  i.organization_id
                                        ,p_job_id                         =>  i.job_id
                                        ,p_position_id                    =>  i.position_id
                                        ,p_grade_id                       =>  ''
                                        ,p_position_transaction_id        =>  ''
                                        ,p_budget_detail_id               =>  ''
                                        ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
                                        ,p_user_id                        =>  ''
                                        ,p_action_cd                      =>  'B');
              pqh_budget.insert_pos_is_bud(i.position_id);
              hr_utility.set_location('position inserted '||i.position_id||l_proc,50);
            end if;
          end loop;
      end loop;
   end if;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,90);
   exception when others then
   p_rows_inserted := null;
   raise;
end populate_bud_positions;
procedure populate_bud_organizations(p_parent_worksheet_detail_id in number,
                                     p_worksheet_id               in number,
				     p_org_hier_ver               in number,
				     p_start_organization_id      in number,
			             p_business_group_id          in number,
                                     p_rows_inserted                 out nocopy number) as
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_worksheets wks
                where wks.budget_id = bgt.budget_id
                and wks.worksheet_id = p_worksheet_id;
   cursor c1 is select organization_id
		from hr_organization_units
		where business_group_id = p_business_group_id
                and date_from < l_budget_end_date
                and (date_to > l_budget_start_date or date_to is null)
                and pqh_budget.already_budgeted_org(organization_id) = 'FALSE' ;
   cursor c2 is select organization_id
               from  (select organization_id_child from pqh_worksheet_organizations_v
		      where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual )x,
		hr_organization_units
		where pqh_budget.already_budgeted_org(organization_id) = 'FALSE'
                and date_from < l_budget_end_date
                and (date_to > l_budget_start_date or date_to is null)
		and organization_id = x.organization_id_child;
   l_worksheet_detail_id number;
   l_object_version_number number := 1;
   l_rows_inserted number := 0;
  l_proc varchar2(100) := g_package||'populate_bud_orgs' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget start date '||l_budget_start_date||l_proc,11);
   hr_utility.set_location('budget end date '||l_budget_end_date||l_proc,12);
   if p_org_hier_ver is null then
      hr_utility.set_location('bg is used '||l_proc,20);
      for i in c1 loop
       l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  ''
           ,p_position_id                    =>  ''
           ,p_grade_id                       =>  ''
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B');
         hr_utility.set_location('org is added '||i.organization_id||l_proc,30);
         pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   else
      hr_utility.set_location('oh is used '||l_proc,40);
      for i in c2 loop
       l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  ''
           ,p_position_id                    =>  ''
           ,p_grade_id                       =>  ''
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B');
         hr_utility.set_location('org is added '||i.organization_id||l_proc,50);
         pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   end if;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('entering '||l_proc,10000);
   exception when others then
   p_rows_inserted := null;
   raise;
end populate_bud_organizations;
procedure populate_del_orgs(p_parent_worksheet_detail_id in number,
                            p_wks_propagation_method     in varchar2,
                            p_worksheet_id               in number,
                            p_start_organization_id      in number,
                            p_org_hier_ver               in number,
                            p_rows_inserted                 out nocopy number) as
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_worksheets wks
                where wks.budget_id = bgt.budget_id
                and wks.worksheet_id = p_worksheet_id;
   cursor c1 is select hier.organization_id_child
                from per_org_structure_elements hier, hr_organization_units org
                where hier.org_structure_version_id = p_org_hier_ver
                and org.date_from < l_budget_end_date
                and (org.date_to > l_budget_start_date or org.date_to is null)
                and org.organization_id = hier.organization_id_child
                and hier.organization_id_parent = p_start_organization_id
                and pqh_budget.already_delegated_org(hier.organization_id_child) = 'FALSE' ;
   l_worksheet_detail_id number;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_del_orgs' ;
   l_rows_inserted number := 0;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget start date '||l_budget_start_date||l_proc,11);
   hr_utility.set_location('budget end date '||l_budget_end_date||l_proc,12);
   for i in c1 loop
      hr_utility.set_location('delegate record found '||l_proc,20);
       l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id_child
           ,p_job_id                         =>  ''
           ,p_position_id                    =>  ''
           ,p_grade_id                       =>  ''
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  ''
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'D'
           ,p_status                         =>  'PENDING'
           ,p_defer_flag                     =>  ''
           ,p_propagation_method             =>  p_wks_propagation_method);
      pqh_budget.insert_org_is_del(i.organization_id_child);
   end loop;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,30);
   exception when others then
   p_rows_inserted := null;
   raise;
end populate_del_orgs;

procedure copy_all_budget_details(p_worksheet_id in number) as
   cursor c1 is select worksheet_detail_id,budget_detail_id,object_version_number,
		       budget_unit1_value,budget_unit2_value,budget_unit3_value,
		       budget_unit1_available,budget_unit2_available,budget_unit3_available
                from pqh_worksheet_details
                where worksheet_id = p_worksheet_id
		and action_cd ='B'
		and budget_detail_id is not null
                for update of budget_unit1_available,budget_unit2_available,budget_unit3_available;
   l_budget_version_id number;
   l_budget_unit1_available number(15,2);
   l_budget_unit2_available number(15,2);
   l_budget_unit3_available number(15,2);
   l_object_version_number number;
   l_proc varchar2(100) := g_package||'copy_all_budget_details' ;
   l_unit1_aggregate varchar2(30);
   l_unit2_aggregate varchar2(30);
   l_unit3_aggregate varchar2(30);
   l_unit1_precision number;
   l_unit2_precision number;
   l_unit3_precision number;
begin
   hr_utility.set_location('entering '||l_proc,10);
   pqh_wks_budget.get_wks_unit_aggregate(p_worksheet_id        => p_worksheet_id ,
                                         p_unit1_aggregate     => l_unit1_aggregate,
                                         p_unit2_aggregate     => l_unit2_aggregate,
                                         p_unit3_aggregate     => l_unit3_aggregate);
   pqh_wks_budget.get_wks_unit_precision(p_worksheet_id        => p_worksheet_id ,
                                         p_unit1_precision     => l_unit1_precision,
                                         p_unit2_precision     => l_unit2_precision,
                                         p_unit3_precision     => l_unit3_precision);
   for i in c1 loop
      l_budget_unit1_available := i.budget_unit1_available;
      l_budget_unit2_available := i.budget_unit2_available;
      l_budget_unit3_available := i.budget_unit3_available;
      l_object_version_number := i.object_version_number;
      copy_budget_details(p_budget_detail_id    => i.budget_detail_id,
			  p_worksheet_detail_id => i.worksheet_detail_id,
                          p_unit1_aggregate     => l_unit1_aggregate,
                          p_unit2_aggregate     => l_unit2_aggregate,
                          p_unit3_aggregate     => l_unit3_aggregate,
                          p_unit1_precision     => l_unit1_precision,
                          p_unit2_precision     => l_unit2_precision,
                          p_unit3_precision     => l_unit3_precision,
			  p_budget_unit1_value  => i.budget_unit1_value,
			  p_budget_unit2_value  => i.budget_unit2_value,
			  p_budget_unit3_value  => i.budget_unit3_value,
                          p_budget_unit1_available => l_budget_unit1_available,
                          p_budget_unit2_available => l_budget_unit2_available,
                          p_budget_unit3_available => l_budget_unit3_available);
     update_worksheet_detail(
     p_worksheet_detail_id               => i.worksheet_detail_id,
     p_effective_date                    => trunc(sysdate),
     p_object_version_number             => l_object_version_number,
     p_budget_unit1_available            => l_budget_unit1_available,
     p_budget_unit2_available            => l_budget_unit2_available,
     p_budget_unit3_available            => l_budget_unit3_available
     );
   end loop;
   hr_utility.set_location('exiting '||l_proc,1000);
end copy_all_budget_details;

procedure copy_budget_details(p_budget_detail_id       in number,
			      p_worksheet_detail_id    in number,
                              p_unit1_aggregate        in varchar2,
                              p_unit2_aggregate        in varchar2,
                              p_unit3_aggregate        in varchar2,
                              p_unit1_precision        in number,
                              p_unit2_precision        in number,
                              p_unit3_precision        in number,
			      p_budget_unit1_value     in number,
			      p_budget_unit2_value     in number,
			      p_budget_unit3_value     in number,
			      p_budget_unit1_available in out nocopy number,
			      p_budget_unit2_available in out nocopy number,
			      p_budget_unit3_available in out nocopy number) as
   cursor c1(p_budget_detail_id number) is
      select budget_period_id,start_time_period_id,end_time_period_id,
             budget_unit1_value,budget_unit2_value,budget_unit3_value,
--             budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
             budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
             budget_unit1_available,budget_unit2_available,budget_unit3_available
      from pqh_budget_periods
      where budget_detail_id = p_budget_detail_id;
   cursor c2(p_budget_period_id number) is
      select budget_set_id,dflt_budget_set_id,
	     budget_unit1_value,budget_unit2_value,budget_unit3_value,
             budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
             budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
             budget_unit1_available,budget_unit2_available,budget_unit3_available
      from pqh_budget_sets
      where budget_period_id = p_budget_period_id;
   cursor c3(p_budget_set_id number) is
      select budget_element_id,element_type_id,distribution_percentage
      from pqh_budget_elements
      where budget_set_id = p_budget_set_id;
   cursor c4(p_budget_element_id number) is
      select cost_allocation_keyflex_id,distribution_percentage
      from pqh_budget_fund_srcs
      where budget_element_id = p_budget_element_id;
   l_worksheet_period_id   number(15,2);
   l_worksheet_budget_set_id  number(15,2);
   l_worksheet_bdgt_elmnt_id  number(15,2);
   l_worksheet_fund_src_id number(15,2);
   l_budget_detail_id      number(15,2);
   l_budget_unit1_percent  number(5,2);
   l_budget_unit2_percent  number(5,2);
   l_budget_unit3_percent  number(5,2);
   l_count                 number ;
   l_object_version_number number;
l_budget_unit1_available number := p_budget_unit1_available;
l_budget_unit2_available number := p_budget_unit2_available;
l_budget_unit3_available number := p_budget_unit3_available;
   l_proc varchar2(100) := g_package||'copy_budget_details' ;
begin
/*
as available figures of the worksheet_details does not reflect these periods, the available figures
of the worksheet_details are to be changed too
*/
   hr_utility.set_location('entering '||l_proc,10);
   select count(*) into l_count
   from pqh_worksheet_periods where worksheet_detail_id = p_worksheet_detail_id;
   if l_count = 0 then
      hr_utility.set_location('no periods found '||l_proc,20);
      for i in c1(p_budget_detail_id) loop
         hr_utility.set_location('for each pos '||l_proc,30);
	 if nvl(p_budget_unit1_value,0) <> 0 then
	    l_budget_unit1_percent := round(nvl(i.budget_unit1_value,0) * 100 / p_budget_unit1_value,2) ;
	 end if;
	 if nvl(p_budget_unit2_value,0) <> 0 then
	    l_budget_unit2_percent := round(nvl(i.budget_unit2_value,0) * 100 / p_budget_unit2_value,2) ;
	 end if;
	 if nvl(p_budget_unit3_value,0) <> 0 then
	    l_budget_unit3_percent := round(nvl(i.budget_unit3_value,0) * 100 / p_budget_unit3_value,2) ;
	 end if;
         hr_utility.set_location('% figures changed '||l_proc,35);
         pqh_worksheet_periods_api.create_worksheet_period(
            p_validate                   => FALSE
           ,p_effective_date             => trunc(sysdate)
           ,p_worksheet_detail_id        => p_worksheet_detail_id
           ,p_worksheet_period_id        => l_worksheet_period_id
           ,p_start_time_period_id       => i.start_time_period_id
           ,p_end_time_period_id         => i.end_time_period_id
           ,p_object_version_number      => l_object_version_number
           ,p_budget_unit1_value         => i.budget_unit1_value
           ,p_budget_unit1_percent       => l_budget_unit1_percent
           ,p_budget_unit1_available     => i.budget_unit1_available
           ,p_budget_unit1_value_type_cd => i.budget_unit1_value_type_cd
           ,p_budget_unit2_value         => i.budget_unit2_value
           ,p_budget_unit2_percent       => l_budget_unit2_percent
           ,p_budget_unit2_available     => i.budget_unit2_available
           ,p_budget_unit2_value_type_cd => i.budget_unit2_value_type_cd
           ,p_budget_unit3_value         => i.budget_unit3_value
           ,p_budget_unit3_percent       => l_budget_unit3_percent
           ,p_budget_unit3_available     => i.budget_unit3_available
           ,p_budget_unit3_value_type_cd => i.budget_unit3_value_type_cd
           );
         hr_utility.set_location('period inserted '||l_proc,37);
         for j in c2(i.budget_period_id) loop
            hr_utility.set_location('for each period '||l_proc,40);
            pqh_worksheet_budget_sets_api.create_worksheet_budget_set(
               p_validate                   => FALSE
              ,p_effective_date             => trunc(sysdate)
              ,p_worksheet_budget_set_id    => l_worksheet_budget_set_id
              ,p_worksheet_period_id        => l_worksheet_period_id
              ,p_dflt_budget_set_id         => j.dflt_budget_set_id
              ,p_object_version_number      => l_object_version_number
              ,p_budget_unit1_value         => j.budget_unit1_value
              ,p_budget_unit1_percent       => j.budget_unit1_percent
              ,p_budget_unit1_available     => j.budget_unit1_available
              ,p_budget_unit1_value_type_cd => j.budget_unit1_value_type_cd
              ,p_budget_unit2_value         => j.budget_unit2_value
              ,p_budget_unit2_percent       => j.budget_unit2_percent
              ,p_budget_unit2_available     => j.budget_unit2_available
              ,p_budget_unit2_value_type_cd => j.budget_unit2_value_type_cd
              ,p_budget_unit3_value         => j.budget_unit3_value
              ,p_budget_unit3_percent       => j.budget_unit3_percent
              ,p_budget_unit3_available     => j.budget_unit3_available
              ,p_budget_unit3_value_type_cd => j.budget_unit3_value_type_cd
              );
            for k in c3(j.budget_set_id) loop
               hr_utility.set_location('for each budgetset '||l_proc,50);
               pqh_worksheet_bdgt_elmnts_api.create_worksheet_bdgt_elmnt(
                  p_validate                   => FALSE
                 ,p_worksheet_budget_set_id    => l_worksheet_budget_set_id
                 ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                 ,p_element_type_id            => k.element_type_id
                 ,p_object_version_number      => l_object_version_number
                 ,p_distribution_percentage    => k.distribution_percentage
                 );
               for l in c4(k.budget_element_id) loop
                  hr_utility.set_location('for each budget_element '||l_proc,60);
                  pqh_worksheet_fund_srcs_api.create_worksheet_fund_src(
                     p_validate                   => FALSE
                    ,p_worksheet_fund_src_id      => l_worksheet_fund_src_id
                    ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                    ,p_cost_allocation_keyflex_id => l.cost_allocation_keyflex_id
                    ,p_object_version_number      => l_object_version_number
                    ,p_distribution_percentage    => l.distribution_percentage
                    );
               end loop;
            end loop;
         end loop;
      end loop;
-- available figures to be changed as it is not already accounted for depending upon
-- the aggregate method available is to be calculated.
-- call add_budgetrow
      hr_utility.set_location('after inserting '||l_proc,70);
      add_budgetrow(p_worksheet_detail_id => p_worksheet_detail_id,
                    p_unit1_aggregate     => p_unit1_aggregate,
                    p_unit2_aggregate     => p_unit2_aggregate,
                    p_unit3_aggregate     => p_unit3_aggregate);
-- call_bgt_chg_bgt_available
      hr_utility.set_location('after adding periods data in plsql table '||l_proc,80);
      hr_utility.set_location('calculating available  '||l_proc,90);
      bgt_chg_bgt_available(p_unit1_aggregate     => p_unit1_aggregate,
   			    p_unit2_aggregate     => p_unit2_aggregate,
			    p_unit3_aggregate     => p_unit3_aggregate,
                            p_unit1_value         => p_budget_unit1_value,
                            p_unit2_value         => p_budget_unit2_value,
                            p_unit3_value         => p_budget_unit3_value,
                            p_unit1_precision     => p_unit1_precision,
                            p_unit2_precision     => p_unit2_precision,
                            p_unit3_precision     => p_unit3_precision,
                            p_unit1_available     => p_budget_unit1_available,
                            p_unit2_available     => p_budget_unit2_available,
                            p_unit3_available     => p_budget_unit3_available);
      hr_utility.set_location('available unit1 is '||p_budget_unit1_available||l_proc,100);
      hr_utility.set_location('available unit2 is '||p_budget_unit2_available||l_proc,110);
      hr_utility.set_location('available unit3 is '||p_budget_unit3_available||l_proc,120);
-- call sub_budgetrow
      hr_utility.set_location('before subtracting '||l_proc,130);
      sub_budgetrow(p_worksheet_detail_id => p_worksheet_detail_id,
                    p_unit1_aggregate     => p_unit1_aggregate,
                    p_unit2_aggregate     => p_unit2_aggregate,
                    p_unit3_aggregate     => p_unit3_aggregate);
   end if;
   hr_utility.set_location('exiting '||l_proc,150);
exception when others then
p_budget_unit1_available := l_budget_unit1_available;
p_budget_unit2_available := l_budget_unit2_available;
p_budget_unit3_available := l_budget_unit3_available;
raise;
end copy_budget_details;

procedure insert_org_is_del(p_org_id number) as
     ins boolean := true;
     l_proc varchar2(100) := g_package||'insert_org_is_del' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_org_id is not null then
	i := p_what_org_is_del.first;
	if i is not null then
	   loop
	      if p_what_org_is_del(i) = p_org_id then
		 ins := false;
		 exit;
	      end if;
	      exit when i = p_what_org_is_del.LAST;
	      i := p_what_org_is_del.NEXT(i);
	   end loop;
	end if;
	if ins then
	   i := nvl(p_what_org_is_del.LAST,0) + 1;
           p_what_org_is_del(i) := p_org_id ;
        end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
  end insert_org_is_del;
procedure calc_org_is_del(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_org_is_del' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_org_is_del.first;
     if i is not null then
	loop
           p_str := p_str||','||p_what_org_is_del(i);
	   exit when i = p_what_org_is_del.LAST;
	   i := p_what_org_is_del.NEXT(i);
        end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
end calc_org_is_del;
procedure delete_org_is_del(p_org_id number) as
     l_proc varchar2(100) := g_package||'delete_org_is_del' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_org_id is not null then
	i := p_what_org_is_del.first;
	if i is not null then
	   loop
              if p_what_org_is_del(i) = p_org_id then
                 p_what_org_is_del.DELETE(i) ;
		 exit;
              end if;
	      exit when i = p_what_org_is_del.LAST;
	      i := p_what_org_is_del.NEXT(i);
           end loop;
	end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
end delete_org_is_del;
procedure delete_org_is_del is
     l_proc varchar2(100) := g_package||'delete_org_is_del' ;
begin
     hr_utility.set_location('entering '||l_proc,10);
     p_what_org_is_del.DELETE ;
     hr_utility.set_location('leaving '||l_proc,10);
exception
     when others then
        raise;
end delete_org_is_del;
function already_delegated_org(p_org_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_delegated_org' ;
     i number;
begin
     hr_utility.set_location('entering '||p_org_id||l_proc,10);
     i := p_what_org_is_del.first;
     if i is not null then
	loop
           if p_what_org_is_del(i) = p_org_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_org_is_del.LAST;
	   i := p_what_org_is_del.NEXT(i);
        end loop;
     end if;
     if l_is_match  then
        hr_utility.set_location('delegated '||p_org_id||l_proc,20);
        return 'TRUE';
     else
        hr_utility.set_location('not delegated '||p_org_id||l_proc,30);
        return 'FALSE';
     end if;
     hr_utility.set_location('leaving '||l_proc,1000);
end already_delegated_org;
procedure insert_org_is_bud(p_org_id number) as
     ins boolean := true;
     l_proc varchar2(100) := g_package||'insert_org_is_bud' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_org_id is not null then
	i := p_what_org_is_bud.first;
	if i is not null then
           loop
	      if p_what_org_is_bud(i) = p_org_id then
		 ins := false;
		 exit;
	      end if;
	      exit when i = p_what_org_is_bud.LAST;
	      i := p_what_org_is_bud.NEXT(i);
	   end loop;
	end if;
	if ins then
	   i := nvl(p_what_org_is_bud.LAST,0) + 1;
           p_what_org_is_bud(i) := p_org_id ;
        end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,100);
end insert_org_is_bud;
procedure calc_org_is_bud(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_org_is_bud' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_org_is_bud.first;
     if i is not null then
	loop
           p_str := p_str||','||p_what_org_is_bud(i);
	   exit when i = p_what_org_is_bud.LAST;
	   i := p_what_org_is_bud.NEXT(i);
        end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
end calc_org_is_bud;
procedure delete_org_is_bud(p_org_id number) as
     l_proc varchar2(100) := g_package||'delete_org_is_bud' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_org_id is not null then
	i := p_what_org_is_bud.first;
	if i is not null then
           loop
              if p_what_org_is_bud(i) = p_org_id then
                 p_what_org_is_bud.DELETE(i) ;
	         exit;
              end if;
	      exit when i = p_what_org_is_bud.LAST;
	      i := p_what_org_is_bud.NEXT(i);
           end loop;
	end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
end delete_org_is_bud;
procedure delete_org_is_bud is
     l_proc varchar2(100) := g_package||'delete_org_is_bud' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   p_what_org_is_bud.DELETE ;
   hr_utility.set_location('leaving '||l_proc,10);
end delete_org_is_bud;
function already_budgeted_org(p_org_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_budgeted_org' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     i := p_what_org_is_bud.first;
     if i is not null then
	loop
           if p_what_org_is_bud(i) = p_org_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_org_is_bud.LAST;
	   i := p_what_org_is_bud.NEXT(i);
        end loop;
    end if;
    if l_is_match  then
       return 'TRUE';
    else
       return 'FALSE';
    end if;
    hr_utility.set_location('leaving '||l_proc,1000);
end already_budgeted_org;
procedure insert_pos_is_bud(p_pos_id number) as
     i number;
     l_proc varchar2(100) := g_package||'insert_pos_is_bud' ;
     ins boolean := true ;
begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_pos_id is not null then
	i := p_what_pos_is_bud.first;
        if i is not null then
           loop
              if p_what_pos_is_bud(i) = p_pos_id then
		 ins := false;
                 exit;
              else
                 exit when i = p_what_pos_is_bud.LAST;
                 i := p_what_pos_is_bud.NEXT(i);
              end if;
	   end loop;
	end if;
	if ins then
	   i := nvl(p_what_pos_is_bud.LAST,0) +1;
	   p_what_pos_is_bud(i) := p_pos_id;
	end if;
        hr_utility.set_location('value added '||p_pos_id,10);
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
end insert_pos_is_bud;
procedure calc_pos_is_bud(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_pos_is_bud' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_pos_is_bud.first;
     if i is not null then
     loop
       p_str := p_str||','||p_what_pos_is_bud(i);
       exit when i = p_what_pos_is_bud.LAST;
       i := p_what_pos_is_bud.NEXT(i);
     end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
exception
     when others then
       raise;
end calc_pos_is_bud;
procedure delete_pos_is_bud(p_pos_id number) as
     l_proc varchar2(100) := g_package||'delete_pos_is_bud' ;
     i number;
begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_pos_id is not null then
	i := p_what_pos_is_bud.first;
        if i is not null then
	loop
	   if nvl(p_what_pos_is_bud(i),-1) = p_pos_id then
              hr_utility.set_location('match found '||p_pos_id,15);
	      begin
	         p_what_pos_is_bud.DELETE(i);
	      exception
		 when others then
		     raise;
	      end;
              exit;
           else
              hr_utility.set_location('no match found '||p_pos_id,15);
	      exit when i = p_what_pos_is_bud.LAST;
	      i := p_what_pos_is_bud.NEXT(i);
	   end if;
	end loop;
        end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
exception
     when others then
        raise;
end delete_pos_is_bud;
procedure delete_pos_is_bud is
     l_proc varchar2(100) := g_package||'delete_pos_is_bud' ;
begin
     hr_utility.set_location('entering '||l_proc,10);
     p_what_pos_is_bud.DELETE ;
     hr_utility.set_location('leaving '||l_proc,10);
end delete_pos_is_bud;
function already_budgeted_pos(p_pos_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_budgeted_pos' ;
     i number;
begin
     hr_utility.set_location('entering '||p_pos_id||l_proc,10);
     i := p_what_pos_is_bud.first;
     if i is not null then
        loop
           if p_what_pos_is_bud(i) = p_pos_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_pos_is_bud.LAST;
	   i := p_what_pos_is_bud.NEXT(i);
        end loop;
    end if;
    if l_is_match  then
       hr_utility.set_location('budgeted'||p_pos_id||l_proc,20);
       return 'TRUE';
    else
       hr_utility.set_location('not budgeted'||p_pos_id||l_proc,30);
       return 'FALSE';
    end if;
    hr_utility.set_location('leaving '||l_proc,1000);
end already_budgeted_pos;
procedure pop_bud_tables(p_parent_worksheet_detail_id in number,
                         p_budgeted_entity_cd         in varchar) as
   cursor c1 is select position_id,job_id,organization_id,grade_id,position_transaction_id
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_parent_worksheet_detail_id
		and action_cd ='B';
  l_proc varchar2(100) := g_package||'pop_bud_tables' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   if p_budgeted_entity_cd ='POSITION' then
      delete_pos_is_bud;
      delete_pot_is_bud;
      for i in c1 loop
	 pqh_budget.insert_pos_is_bud(i.position_id);
	 pqh_budget.insert_pot_is_bud(i.position_transaction_id);
      end loop;
   elsif p_budgeted_entity_cd ='ORGANIZATION' then
      delete_org_is_bud;
      for i in c1 loop
	 pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   elsif p_budgeted_entity_cd ='JOB' then
      delete_job_is_bud;
      for i in c1 loop
	 pqh_budget.insert_job_is_bud(i.job_id);
      end loop;
   elsif p_budgeted_entity_cd ='GRADE' then
      delete_grd_is_bud;
      for i in c1 loop
	 pqh_budget.insert_grd_is_bud(i.grade_id);
      end loop;
   end if;
   hr_utility.set_location('exiting '||l_proc,1000);
end pop_bud_tables;
procedure pop_bud_tables(p_budget_version_id  in number,
                         p_budgeted_entity_cd in varchar) as
   cursor c1 is select position_id,job_id,organization_id,grade_id
                from pqh_budget_details
                where budget_version_id = p_budget_version_id;
  l_proc varchar2(100) := g_package||'pop_bud_tables' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   if p_budgeted_entity_cd ='POSITION' then
      delete_pos_is_bud;
      delete_pot_is_bud;
      for i in c1 loop
	 pqh_budget.insert_pos_is_bud(i.position_id);
      end loop;
   elsif p_budgeted_entity_cd ='ORGANIZATION' then
      delete_org_is_bud;
      for i in c1 loop
	 pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   elsif p_budgeted_entity_cd ='JOB' then
      delete_job_is_bud;
      for i in c1 loop
	 pqh_budget.insert_job_is_bud(i.job_id);
      end loop;
   elsif p_budgeted_entity_cd ='GRADE' then
      delete_grd_is_bud;
      for i in c1 loop
	 pqh_budget.insert_grd_is_bud(i.grade_id);
      end loop;
   end if;
   hr_utility.set_location('exiting '||l_proc,1000);
end pop_bud_tables;
procedure pop_del_tables(p_parent_worksheet_detail_id in number) as
   cursor c1 is select organization_id
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_parent_worksheet_detail_id
		and action_cd ='D' ;
  l_proc varchar2(100) := g_package||'pop_del_tables' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
    delete_org_is_del;
    for i in c1 loop
       pqh_budget.insert_org_is_del(i.organization_id);
    end loop;
   hr_utility.set_location('exiting '||l_proc,20);
end pop_del_tables;
procedure insert_pot_is_bud(p_pot_id number) as
     i number;
     l_proc varchar2(100) := g_package||'insert_pot_is_bud' ;
     ins boolean := true ;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_pot_id is not null then
	i := p_what_pot_is_bud.first;
        if i is not null then
           loop
              if p_what_pot_is_bud(i) = p_pot_id then
		 ins := false;
                 exit;
              else
                 exit when i = p_what_pot_is_bud.LAST;
                 i := p_what_pot_is_bud.NEXT(i);
              end if;
	   end loop;
	end if;
	if ins then
	   i := nvl(p_what_pot_is_bud.LAST,0) +1;
	   p_what_pot_is_bud(i) := p_pot_id;
	end if;
        hr_utility.set_location('value added '||p_pot_id,20);
     end if;
     hr_utility.set_location('leaving '||l_proc,30);
  end insert_pot_is_bud;
procedure calc_pot_is_bud(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_pot_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_pot_is_bud.first;
     if i is not null then
     loop
       p_str := p_str||','||p_what_pot_is_bud(i);
       exit when i = p_what_pot_is_bud.LAST;
       i := p_what_pot_is_bud.NEXT(i);
     end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,20);
  exception
     when others then
       raise;
  end calc_pot_is_bud;
procedure delete_pot_is_bud(p_pot_id number) as
     l_proc varchar2(100) := g_package||'delete_pot_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_pot_id is not null then
	i := p_what_pot_is_bud.first;
        if i is not null then
	loop
	   if nvl(p_what_pot_is_bud(i),-1) = p_pot_id then
              hr_utility.set_location('match found '||p_pot_id,15);
	      begin
	         p_what_pot_is_bud.DELETE(i);
	      exception
		 when others then
		     raise;
	      end;
              exit;
           else
              hr_utility.set_location('no match found '||p_pot_id,15);
	      exit when i = p_what_pot_is_bud.LAST;
	      i := p_what_pot_is_bud.NEXT(i);
	   end if;
	end loop;
        end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,20);
  exception
     when others then
        raise;
  end delete_pot_is_bud;
procedure delete_pot_is_bud is
     l_proc varchar2(100) := g_package||'delete_pot_is_bud' ;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_what_pot_is_bud.DELETE ;
     hr_utility.set_location('leaving '||l_proc,20);
  end delete_pot_is_bud;
function already_budgeted_pot(p_pot_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_budgeted_pot' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     i := p_what_pot_is_bud.first;
     if i is not null then
        loop
           if p_what_pot_is_bud(i) = p_pot_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_pot_is_bud.LAST;
	   i := p_what_pot_is_bud.NEXT(i);
        end loop;
    end if;
    if l_is_match  then
       return 'TRUE';
    else
       return 'FALSE';
    end if;
    hr_utility.set_location('leaving '||l_proc,20);
  end already_budgeted_pot;
procedure insert_job_is_bud(p_job_id number) as
     ins boolean := true;
     l_proc varchar2(100) := g_package||'insert_job_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_job_id is not null then
        hr_utility.set_location('job_id is '||p_job_id||l_proc,20);
	i := p_what_job_is_bud.first;
	if i is not null then
           hr_utility.set_location('first counter is '||i||l_proc,30);
	   loop
	      if p_what_job_is_bud(i) = p_job_id then
                 hr_utility.set_location('match already exists '||l_proc,40);
		 ins := false;
		 exit;
	      end if;
	      exit when i = p_what_job_is_bud.LAST;
	      i := p_what_job_is_bud.NEXT(i);
	   end loop;
	end if;
	if ins then
           hr_utility.set_location('match not exists inserting'||l_proc,50);
           i := nvl(p_what_job_is_bud.LAST,0)+ 1;
           p_what_job_is_bud(i) := p_job_id ;
	end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,60);
  end insert_job_is_bud;
procedure calc_job_is_bud(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_job_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_job_is_bud.first;
     if i is not null then
	loop
           p_str := p_str||','||p_what_job_is_bud(i);
	   exit when i = p_what_job_is_bud.LAST;
	   i := p_what_job_is_bud.NEXT(i);
        end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,30);
  end calc_job_is_bud;
procedure delete_job_is_bud(p_job_id number) as
     l_proc varchar2(100) := g_package||'delete_job_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_job_id is not null then
	i := p_what_job_is_bud.first;
	if i is not null then
           loop
              if p_what_job_is_bud(i) = p_job_id then
                 p_what_job_is_bud.DELETE(i) ;
		 exit;
              end if;
	      exit when i = p_what_job_is_bud.LAST;
	      i := p_what_job_is_bud.NEXT(i);
           end loop;
        end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,20);
  end delete_job_is_bud;
procedure delete_job_is_bud is
     l_proc varchar2(100) := g_package||'delete_job_is_bud' ;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_what_job_is_bud.DELETE ;
     hr_utility.set_location('leaving '||l_proc,20);
  end delete_job_is_bud;
function already_budgeted_job(p_job_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_budgeted_job' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     i := p_what_job_is_bud.first;
     if i is not null then
	loop
           if p_what_job_is_bud(i) = p_job_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_job_is_bud.LAST;
	   i := p_what_job_is_bud.NEXT(i);
        end loop;
     end if;
     if l_is_match  then
        return 'TRUE';
     else
        return 'FALSE';
     end if;
    hr_utility.set_location('leaving '||l_proc,20);
  end already_budgeted_job;
procedure insert_grd_is_bud(p_grd_id number) as
     i number;
     l_proc varchar2(100) := g_package||'insert_grd_is_bud' ;
     ins boolean := true;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_grd_id is not null then
	i := p_what_grd_is_bud.first;
	if i is not null then
	   loop
	      if p_what_grd_is_bud(i) = p_grd_id then
		 ins := false;
		 exit;
	      end if;
	      exit when i = p_what_grd_is_bud.LAST;
	      i := p_what_grd_is_bud.NEXT(i);
	   end loop;
	end if;
	if ins then
           i := nvl(p_what_grd_is_bud.LAST,0)+ 1;
           p_what_grd_is_bud(i) := p_grd_id ;
	end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
  end insert_grd_is_bud;
procedure calc_grd_is_bud(p_str out nocopy varchar2) as
     l_proc varchar2(100) := g_package||'calc_grd_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_str := '';
     i := p_what_grd_is_bud.first;
     if i is not null then
	loop
           p_str := p_str||','||p_what_grd_is_bud(i);
	   exit when i = p_what_grd_is_bud.LAST;
	   i := p_what_grd_is_bud.NEXT(i);
        end loop;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
  end calc_grd_is_bud;
procedure delete_grd_is_bud(p_grd_id number) as
     l_proc varchar2(100) := g_package||'delete_grd_is_bud' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     if p_grd_id is not null then
        i := p_what_grd_is_bud.first;
        if i is not null then
           loop
              if p_what_grd_is_bud(i) = p_grd_id then
                 p_what_grd_is_bud.DELETE(i) ;
		 exit;
              end if;
	      exit when i = p_what_grd_is_bud.LAST;
	      i := p_what_grd_is_bud.NEXT(i);
           end loop;
	end if;
     end if;
     hr_utility.set_location('leaving '||l_proc,10);
  end delete_grd_is_bud;
procedure delete_grd_is_bud is
     l_proc varchar2(100) := g_package||'delete_grd_is_bud' ;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     p_what_grd_is_bud.DELETE ;
     hr_utility.set_location('leaving '||l_proc,10);
  end delete_grd_is_bud;
function already_budgeted_grd(p_grd_id number) return varchar2 is
     l_is_match boolean := FALSE;
     l_proc varchar2(100) := g_package||'already_budgeted_grd' ;
     i number;
  begin
     hr_utility.set_location('entering '||l_proc,10);
     i := p_what_grd_is_bud.first;
     if i is not null then
	loop
           if p_what_grd_is_bud(i) = p_grd_id then
              l_is_match := TRUE;
              exit;
           end if;
	   exit when i = p_what_grd_is_bud.LAST;
	   i := p_what_grd_is_bud.NEXT(i);
        end loop;
    end if;
    if l_is_match  then
       return 'TRUE';
    else
       return 'FALSE';
    end if;
    hr_utility.set_location('leaving '||l_proc,1000);
end already_budgeted_grd;
function already_budgeted(p_position_id number,
                          p_job_id number,
                          p_organization_id number,
                          p_budgeted_entity varchar2 ) return varchar2 is
      l_match varchar2(20) := 'FALSE';
begin
        if p_budgeted_entity ='POSITION' then
	   l_match := already_budgeted_pos(p_position_id);
        elsif p_budgeted_entity ='JOB' then
	   l_match := already_budgeted_job(p_job_id);
        elsif p_budgeted_entity ='ORGANIZATION' then
	   l_match := already_budgeted_org(p_organization_id);
	end if;
	return l_match;
end already_budgeted;
function already_budgeted_pot(p_position_transaction_id number,
                              p_job_id number,
                              p_organization_id number,
                              p_budgeted_entity varchar2 ) return varchar2 is
      l_match varchar2(20) := 'FALSE';
begin
        if p_budgeted_entity ='POSITION' then
	   l_match := already_budgeted_pot(p_position_transaction_id);
        elsif p_budgeted_entity ='JOB' then
	   l_match := already_budgeted_job(p_job_id);
        elsif p_budgeted_entity ='ORGANIZATION' then
	   l_match := already_budgeted_org(p_organization_id);
	end if;
	return l_match;
end already_budgeted_pot;
procedure post_changes (p_worksheet_detail_id in number ,
                        p_budget_style_cd     in varchar2,
                        p_unit1_aggregate     in varchar2,
                        p_unit2_aggregate     in varchar2,
                        p_unit3_aggregate     in varchar2
) as
   cursor c1 is select worksheet_detail_id,propagation_method,object_version_number,
		       old_unit1_value,old_unit2_value,old_unit3_value,
                       budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
                from pqh_worksheet_details
		where parent_worksheet_detail_id = p_worksheet_detail_id
		and action_cd ='D'
		for update of old_unit1_value,old_unit2_value,old_unit3_value,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available;

   l_change_mode varchar2(3);
   l_propagate varchar2(10);
   l_budget_unit1_available number;
   l_budget_unit2_available number;
   l_budget_unit3_available number;
   l_object_version_number number;
   l_unit1_precision number;
   l_unit2_precision number;
   l_unit3_precision number;
begin
   pqh_wks_budget.get_wkd_unit_precision(p_worksheet_detail_id => p_worksheet_detail_id,
                                         p_unit1_precision     => l_unit1_precision,
                                         p_unit2_precision     => l_unit2_precision,
                                         p_unit3_precision     => l_unit3_precision);
   for i in c1 loop
      if p_budget_style_cd ='TOP' then
         if nvl(i.old_unit1_value,0) <> 0 or
            nvl(i.old_unit2_value,0) <> 0 or
            nvl(i.old_unit3_value,0) <> 0 then
	    l_propagate := 'TRUE';
         else
	    l_propagate := 'FALSE';
         end if;
      else
         l_propagate := 'FALSE' ;
      end if;
      if l_propagate ='TRUE' then
          pqh_wks_budget.wkd_propagation_method(i.worksheet_detail_id,l_change_mode);
          l_budget_unit1_available := i.budget_unit1_available;
          l_budget_unit2_available := i.budget_unit2_available;
          l_budget_unit3_available := i.budget_unit3_available;
	  l_object_version_number  := i.object_version_number;
          propagate_worksheet_changes(p_change_mode           => l_change_mode,
	   				         p_worksheet_detail_id   => i.worksheet_detail_id,
						 p_budget_style_cd       => p_budget_style_cd,
						 p_object_version_number => l_object_version_number,
					         p_new_wks_unit1_value   => i.budget_unit1_value,
					         p_new_wks_unit2_value   => i.budget_unit2_value,
					         p_new_wks_unit3_value   => i.budget_unit3_value,
			                         p_unit1_precision       => l_unit1_precision,
			                         p_unit2_precision       => l_unit2_precision,
			                         p_unit3_precision       => l_unit3_precision,
			                         p_unit1_aggregate       => p_unit1_aggregate,
			                         p_unit2_aggregate       => p_unit2_aggregate,
			                         p_unit3_aggregate       => p_unit3_aggregate,
					         p_wks_unit1_available   => l_budget_unit1_available,
					         p_wks_unit2_available   => l_budget_unit2_available,
					         p_wks_unit3_available   => l_budget_unit3_available);
          update_worksheet_detail(
          p_worksheet_detail_id               => i.worksheet_detail_id,
	  p_effective_date                    => trunc(sysdate),
          p_object_version_number             => l_object_version_number,
          p_budget_unit1_available            => l_budget_unit1_available,
          p_budget_unit2_available            => l_budget_unit2_available,
          p_budget_unit3_available            => l_budget_unit3_available,
          p_old_unit1_value                   => null,
          p_old_unit2_value                   => null,
          p_old_unit3_value                   => null);

          pqh_budget.post_changes(p_worksheet_detail_id => i.worksheet_detail_id,
                                  p_budget_style_cd     => p_budget_style_cd,
                                  p_unit1_aggregate     => p_unit1_aggregate,
                                  p_unit2_aggregate     => p_unit2_aggregate,
                                  p_unit3_aggregate     => p_unit3_aggregate);
       end if;
   end loop;
end post_changes;

procedure init_prd_tab(p_budget_id    in     number) as
   cursor c1 is select period_set_name,budget_start_date,budget_end_date
		from pqh_budgets
		where budget_id = p_budget_id;
   l_period_set_name pqh_budgets.period_set_name%type;
   l_prd_start_date  date;
   l_prd_end_date    date;
   k number := 1;
   cursor c2 is select start_date
		from per_time_periods
		where period_set_name = l_period_set_name
		and start_date >= l_prd_start_date
		and end_date <= l_prd_end_date ;
   l_proc varchar2(51) := g_package||'init_prd_tab';
begin
   hr_utility.set_location('entering'||l_proc,10);
   for i in c1 loop
       l_period_set_name := i.period_set_name;
       l_prd_start_date  := i.budget_start_date;
       l_prd_end_date    := i.budget_end_date;
   end loop;
   hr_utility.set_location('period_set_name is'||l_period_set_name||l_proc,20);
   hr_utility.set_location('period start_date is'||to_char(l_prd_start_date,'mm/dd/RRRR')||l_proc,30);
   hr_utility.set_location('period end_date is'||to_char(l_prd_end_date,'mm/dd/RRRR')||l_proc,40);
   begin
      p_prd_unit_tab.delete;
   exception
      when others then
         hr_utility.set_location('delete of table failed'||l_proc,42);
         null;
   end;
   for j in c2 loop
      p_prd_unit_tab(k).start_date := j.start_date;
      k := k+1;
      hr_utility.set_location('period added is'||to_char(j.start_date,'mm/dd/RRRR')||l_proc,50);
   end loop;
   hr_utility.set_location('# of periods added are'||k||' '||l_proc,50);
   hr_utility.set_location('exit'||l_proc,100);
end init_prd_tab;
procedure chk_unit_sum(p_unit1_sum_value out nocopy number,
                       p_unit2_sum_value out nocopy number,
                       p_unit3_sum_value out nocopy number) as
   i number;
   l_proc varchar2(51) := g_package||'chk_unit_sum';
begin
   hr_utility.set_location('entering'||l_proc,10);
   i := p_prd_unit_tab.first;
   if i is not null then
      loop
         p_unit1_sum_value := nvl(p_unit1_sum_value,0) + nvl(p_prd_unit_tab(i).unit1_value,0);
         p_unit2_sum_value := nvl(p_unit2_sum_value,0) + nvl(p_prd_unit_tab(i).unit2_value,0);
         p_unit3_sum_value := nvl(p_unit3_sum_value,0) + nvl(p_prd_unit_tab(i).unit3_value,0);
	 exit when i = p_prd_unit_tab.LAST;
	 i := p_prd_unit_tab.NEXT(i);
      end loop;
   end if;
   hr_utility.set_location('exiting'||l_proc,100);
exception when others then
p_unit1_sum_value := null;
p_unit2_sum_value := null;
p_unit3_sum_value := null;
raise;
end chk_unit_sum;
procedure chk_unit_avg(p_unit1_avg_value out nocopy number,
		       p_unit2_avg_value out nocopy number,
		       p_unit3_avg_value out nocopy number) as
   i number;
   l_unit1_sum_value number := 0;
   l_unit2_sum_value number := 0;
   l_unit3_sum_value number := 0;
   cnt number := 0;
   l_proc varchar2(51) := g_package||'chk_unit_avg';
begin
   hr_utility.set_location('entering'||l_proc,10);
   chk_unit_sum( p_unit1_sum_value => l_unit1_sum_value,
                 p_unit2_sum_value => l_unit2_sum_value,
                 p_unit3_sum_value => l_unit3_sum_value);
   cnt := get_prdtab_count;
   p_unit1_avg_value := l_unit1_sum_value/cnt;
   p_unit2_avg_value := l_unit2_sum_value/cnt;
   p_unit3_avg_value := l_unit3_sum_value/cnt;
/*
   i := p_prd_unit_tab.first;
   if i is not null then
      loop
	 l_unit1_sum_value := nvl(l_unit1_sum_value,0) + nvl(p_prd_unit_tab(i).unit1_value,0);
	 l_unit2_sum_value := nvl(l_unit2_sum_value,0) + nvl(p_prd_unit_tab(i).unit2_value,0);
	 l_unit3_sum_value := nvl(l_unit3_sum_value,0) + nvl(p_prd_unit_tab(i).unit3_value,0);
	 cnt := cnt + 1;
	 exit when i = p_prd_unit_tab.LAST;
	 i := p_prd_unit_tab.NEXT(i);
      end loop;
      p_unit1_avg_value := round(l_unit1_sum_value/cnt,2);
      p_unit2_avg_value := round(l_unit2_sum_value/cnt,2);
      p_unit3_avg_value := round(l_unit3_sum_value/cnt,2);
   end if;
*/
   hr_utility.set_location('unit1_avg is'||p_unit1_avg_value||l_proc,100);
   hr_utility.set_location('unit2_avg is'||p_unit2_avg_value||l_proc,110);
   hr_utility.set_location('unit3_avg is'||p_unit3_avg_value||l_proc,120);
   hr_utility.set_location('exit'||l_proc,130);
exception
   when others then
      hr_utility.set_location('errors in calculating average'||l_proc,200);
      p_unit1_avg_value := null;
      p_unit2_avg_value := null;
      p_unit3_avg_value := null;
      raise;
end chk_unit_avg;
procedure chk_unit_max(p_unit1_max_value out nocopy number,
		       p_unit2_max_value out nocopy number,
		       p_unit3_max_value out nocopy number) as
   i number;
   l_unit1_max_value number := 0;
   l_unit2_max_value number := 0;
   l_unit3_max_value number := 0;
   l_proc varchar2(51) := g_package||'chk_unit_max';
begin
   hr_utility.set_location('entering'||l_proc,10);
   i := p_prd_unit_tab.first;
   if i is not null then
      loop
	 if nvl(p_prd_unit_tab(i).unit1_value,0) > nvl(l_unit1_max_value,0) then
	    l_unit1_max_value := p_prd_unit_tab(i).unit1_value;
	 end if;
	 if nvl(p_prd_unit_tab(i).unit2_value,0) > nvl(l_unit2_max_value,0) then
	    l_unit2_max_value := p_prd_unit_tab(i).unit2_value;
	 end if;
	 if nvl(p_prd_unit_tab(i).unit3_value,0) > nvl(l_unit3_max_value,0) then
	    l_unit3_max_value := p_prd_unit_tab(i).unit3_value;
	 end if;
	 exit when i = p_prd_unit_tab.LAST;
	 i := p_prd_unit_tab.NEXT(i);
      end loop;
   end if;
   p_unit1_max_value := l_unit1_max_value;
   p_unit2_max_value := l_unit2_max_value;
   p_unit3_max_value := l_unit3_max_value;
   hr_utility.set_location('unit1_max is'||l_unit1_max_value||l_proc,100);
   hr_utility.set_location('unit2_max is'||l_unit2_max_value||l_proc,100);
   hr_utility.set_location('unit3_max is'||l_unit3_max_value||l_proc,100);
   hr_utility.set_location('exit'||l_proc,100);
exception when others then
p_unit1_max_value := null;
p_unit2_max_value := null;
p_unit3_max_value := null;
raise;
end chk_unit_max;
procedure add_prd(p_prd_start_date  in date,
		  p_prd_end_date    in date,
		  p_unit1_aggregate in varchar2,
		  p_unit2_aggregate in varchar2,
		  p_unit3_aggregate in varchar2,
		  p_prd_unit1_value in number,
		  p_prd_unit2_value in number,
		  p_prd_unit3_value in number ) as
   i number;
   l_proc varchar2(51) := g_package||'add_prd';
begin
/*
if the agregate is accumulate, then the value is added to the total in first period
else the value is added in each period which lies between the start date and end date inputted
*/
   hr_utility.set_location('entering'||l_proc,10);
   i := p_prd_unit_tab.first;
   if i is not null then
      loop
         hr_utility.set_location('calendar start_date '||to_char(p_prd_unit_tab(i).start_date,'mm/dd/RRRR')||l_proc,15);
	 if p_prd_unit_tab(i).start_date = p_prd_start_date then
            hr_utility.set_location('prd_start_date is equal to calendar'||l_proc,10);
	    if p_unit1_aggregate = 'ACCUMULATE' then
               hr_utility.set_location('unit1 is Sum '||l_proc,20);
	       p_prd_unit_tab(i).unit1_value := nvl(p_prd_unit_tab(i).unit1_value,0) + nvl(p_prd_unit1_value,0);
	    end if;
            if p_unit2_aggregate ='ACCUMULATE' then
               hr_utility.set_location('unit2 is Sum '||l_proc,30);
	       p_prd_unit_tab(i).unit2_value := nvl(p_prd_unit_tab(i).unit2_value,0) + nvl(p_prd_unit2_value,0);
	    end if;
            if p_unit3_aggregate ='ACCUMULATE' then
               hr_utility.set_location('unit3 is Sum '||l_proc,40);
	       p_prd_unit_tab(i).unit3_value := nvl(p_prd_unit_tab(i).unit3_value,0) + nvl(p_prd_unit3_value,0);
	    end if;
	 end if;
         if p_prd_unit_tab(i).start_date between p_prd_start_date and p_prd_end_date then
            hr_utility.set_location('prd_start_date is between '||l_proc,10);
	    if p_unit1_aggregate in ('MAXIMUM','AVERAGE') then
               hr_utility.set_location('unit1 is '||p_unit1_aggregate||l_proc,40);
	       p_prd_unit_tab(i).unit1_value := nvl(p_prd_unit_tab(i).unit1_value,0) + nvl(p_prd_unit1_value,0);
            end if;
	    if p_unit2_aggregate in ('MAXIMUM','AVERAGE') then
               hr_utility.set_location('unit2 is '||p_unit2_aggregate||l_proc,40);
	       p_prd_unit_tab(i).unit2_value := nvl(p_prd_unit_tab(i).unit2_value,0) + nvl(p_prd_unit2_value,0);
            end if;
	    if p_unit3_aggregate in ('MAXIMUM','AVERAGE') then
               hr_utility.set_location('unit3 is '||p_unit3_aggregate||l_proc,40);
	       p_prd_unit_tab(i).unit3_value := nvl(p_prd_unit_tab(i).unit3_value,0) + nvl(p_prd_unit3_value,0);
            end if;
         end if;
	 exit when i = p_prd_unit_tab.LAST;
	 i := p_prd_unit_tab.NEXT(i);
      end loop;
   end if;
   hr_utility.set_location('exit'||l_proc,100);
end add_prd;
procedure sub_prd(p_prd_start_date  in date,
		  p_prd_end_date    in date,
		  p_unit1_aggregate in varchar2,
		  p_unit2_aggregate in varchar2,
		  p_unit3_aggregate in varchar2,
		  p_prd_unit1_value in number,
		  p_prd_unit2_value in number,
		  p_prd_unit3_value in number ) as
   i number;
   l_proc varchar2(51) := g_package||'sub_prd';
begin
   hr_utility.set_location('entering'||l_proc,10);
   i := p_prd_unit_tab.first;
   if i is not null then
      loop
	 if p_prd_unit_tab(i).start_date = p_prd_start_date then
	    if p_unit1_aggregate = 'ACCUMULATE' then
	       p_prd_unit_tab(i).unit1_value := nvl(p_prd_unit_tab(i).unit1_value,0) - nvl(p_prd_unit1_value,0);
	    end if;
            if p_unit2_aggregate ='ACCUMULATE' then
	       p_prd_unit_tab(i).unit2_value := nvl(p_prd_unit_tab(i).unit2_value,0) - nvl(p_prd_unit2_value,0);
	    end if;
            if p_unit3_aggregate ='ACCUMULATE' then
	       p_prd_unit_tab(i).unit3_value := nvl(p_prd_unit_tab(i).unit3_value,0) - nvl(p_prd_unit3_value,0);
	    end if;
	 end if;
         if p_prd_unit_tab(i).start_date between p_prd_start_date and p_prd_end_date then
	    if p_unit1_aggregate in ('MAXIMUM','AVERAGE') then
	       p_prd_unit_tab(i).unit1_value := nvl(p_prd_unit_tab(i).unit1_value,0) - nvl(p_prd_unit1_value,0);
            end if;
	    if p_unit2_aggregate in ('MAXIMUM','AVERAGE') then
	       p_prd_unit_tab(i).unit2_value := nvl(p_prd_unit_tab(i).unit2_value,0) - nvl(p_prd_unit2_value,0);
            end if;
	    if p_unit3_aggregate in ('MAXIMUM','AVERAGE') then
	       p_prd_unit_tab(i).unit3_value := nvl(p_prd_unit_tab(i).unit3_value,0) - nvl(p_prd_unit3_value,0);
            end if;
         end if;
	 exit when i = p_prd_unit_tab.LAST;
	 i := p_prd_unit_tab.NEXT(i);
      end loop;
   end if;
   hr_utility.set_location('exit'||l_proc,100);
end sub_prd;
procedure add_budgetrow(p_worksheet_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_worksheet_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.worksheet_detail_id = p_worksheet_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'add_budgetrow';
   l_budget_id number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   l_budget_id := pqh_wks_budget.get_wkd_budget(p_worksheet_detail_id => p_worksheet_detail_id);
   init_prd_tab(p_budget_id => l_budget_id);
   for i in c1 loop
       add_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end add_budgetrow;
procedure sub_budgetrow(p_worksheet_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_worksheet_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.worksheet_detail_id = p_worksheet_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'sub_budgetrow';
begin
   hr_utility.set_location('entering'||l_proc,10);
   for i in c1 loop
       sub_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end sub_budgetrow;

procedure add_budgetrow(p_budget_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_budget_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.budget_detail_id = p_budget_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'add_budgetrow';
   l_budget_id number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   l_budget_id := pqh_wks_budget.get_bgd_budget(p_budget_detail_id => p_budget_detail_id);
   init_prd_tab(p_budget_id => l_budget_id);
   for i in c1 loop
       add_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end add_budgetrow;
procedure sub_budgetrow(p_budget_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_budget_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.budget_detail_id = p_budget_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'sub_budgetrow';
begin
   hr_utility.set_location('entering'||l_proc,10);
   for i in c1 loop
       sub_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end sub_budgetrow;

PROCEDURE bgt_chg_bgt_available(p_unit1_aggregate     in varchar2,
			        p_unit2_aggregate     in varchar2,
			        p_unit3_aggregate     in varchar2,
                                p_unit1_value         in number,
                                p_unit2_value         in number,
                                p_unit3_value         in number,
                                p_unit1_precision     in number,
                                p_unit2_precision     in number,
                                p_unit3_precision     in number,
                                p_unit1_available        out nocopy number,
                                p_unit2_available        out nocopy number,
                                p_unit3_available        out nocopy number ) IS
  l_unit1_max number;
  l_unit2_max number;
  l_unit3_max number;
  l_unit1_sum number;
  l_unit2_sum number;
  l_unit3_sum number;
  l_unit1_avg number;
  l_unit2_avg number;
  l_unit3_avg number;
  l_unit1_available number := p_unit1_available;
    l_unit2_available number := p_unit2_available;
    l_unit3_available number := p_unit3_available;
  l_proc varchar2(51) := g_package||'bgt_chg_bgt_available';
BEGIN
  hr_utility.set_location('entering'||l_proc,10);
  chk_unit_max(l_unit1_max,l_unit2_max,l_unit3_max);
  chk_unit_avg(l_unit1_avg,l_unit2_avg,l_unit3_avg);
  chk_unit_sum(l_unit1_sum,l_unit2_sum,l_unit3_sum);
  hr_utility.set_location('unit1 max is'||l_unit1_max||l_proc,30);
  hr_utility.set_location('unit2 max is'||l_unit2_max||l_proc,40);
  hr_utility.set_location('unit3 max is'||l_unit3_max||l_proc,50);
  hr_utility.set_location('unit1 sum is'||l_unit1_sum||l_proc,60);
  hr_utility.set_location('unit2 sum is'||l_unit2_sum||l_proc,70);
  hr_utility.set_location('unit3 sum is'||l_unit3_sum||l_proc,80);
  hr_utility.set_location('unit1 avg is'||l_unit1_avg||l_proc,90);
  hr_utility.set_location('unit2 avg is'||l_unit2_avg||l_proc,100);
  hr_utility.set_location('unit3 avg is'||l_unit3_avg||l_proc,110);
  if p_unit1_aggregate ='MAXIMUM' then
     p_unit1_available := round(nvl(p_unit1_value,0) - nvl(l_unit1_max,0),p_unit1_precision);
  elsif p_unit1_aggregate = 'AVERAGE' then
     p_unit1_available := round(nvl(p_unit1_value,0) - nvl(l_unit1_avg,0),p_unit1_precision);
  else
     p_unit1_available := round(nvl(p_unit1_value,0) - nvl(l_unit1_sum,0),p_unit1_precision);
  end if;
  if p_unit2_aggregate ='MAXIMUM' then
     p_unit2_available := round(nvl(p_unit2_value,0) - nvl(l_unit2_max,0),p_unit2_precision);
  elsif p_unit2_aggregate = 'AVERAGE' then
     p_unit2_available := round(nvl(p_unit2_value,0) - nvl(l_unit2_avg,0),p_unit2_precision);
  else
     p_unit2_available := round(nvl(p_unit2_value,0) - nvl(l_unit2_sum,0),p_unit2_precision);
  end if;
  if p_unit3_aggregate ='MAXIMUM' then
     p_unit3_available := round(nvl(p_unit3_value,0) - nvl(l_unit3_max,0),p_unit3_precision);
  elsif p_unit3_aggregate = 'AVERAGE' then
     p_unit3_available := round(nvl(p_unit3_value,0) - nvl(l_unit3_avg,0),p_unit3_precision);
  else
     p_unit3_available := round(nvl(p_unit3_value,0) - nvl(l_unit3_sum,0),p_unit3_precision);
  end if;
  hr_utility.set_location('exiting '||l_proc,150);
exception when others then
p_unit1_available := l_unit1_available;
p_unit2_available := l_unit2_available;
p_unit3_available := l_unit3_available;
raise;
END bgt_chg_bgt_available;
PROCEDURE prd_chg_bgt_available(p_unit1_aggregate     in varchar2,
			        p_unit2_aggregate     in varchar2,
			        p_unit3_aggregate     in varchar2,
			        p_prd_start_date      in date,
			        p_prd_end_date        in date,
                                p_unit1_value         in number,
                                p_unit2_value         in number,
                                p_unit3_value         in number,
                                p_bgt_unit1_value     in number,
                                p_bgt_unit2_value     in number,
                                p_bgt_unit3_value     in number,
                                p_unit1_precision     in number,
                                p_unit2_precision     in number,
                                p_unit3_precision     in number,
                                p_unit1_available     in out nocopy number,
                                p_unit2_available     in out nocopy number,
                                p_unit3_available     in out nocopy number ) IS
  l_unit1_max number;
  l_unit2_max number;
  l_unit3_max number;
  l_unit1_sum number;
  l_unit2_sum number;
  l_unit3_sum number;
  l_unit1_avg number;
  l_unit2_avg number;
  l_unit3_avg number;
   l_unit1_available number := p_unit1_available;
    l_unit2_available number := p_unit2_available;
    l_unit3_available number := p_unit3_available;
  l_proc varchar2(51) := g_package||'prd_chg_bgt_available';
BEGIN
  hr_utility.set_location('entering'||l_proc,10);
  if p_prd_start_date is not null and p_prd_end_date is not null then
     add_prd(p_prd_start_date  => p_prd_start_date,
             p_prd_end_date    => p_prd_end_date,
             p_unit1_aggregate => p_unit1_aggregate,
             p_unit2_aggregate => p_unit2_aggregate,
             p_unit3_aggregate => p_unit3_aggregate,
             p_prd_unit1_value => p_unit1_value,
             p_prd_unit2_value => p_unit2_value,
             p_prd_unit3_value => p_unit3_value);
     chk_unit_max(l_unit1_max,l_unit2_max,l_unit3_max);
     chk_unit_avg(l_unit1_avg,l_unit2_avg,l_unit3_avg);
     chk_unit_sum(l_unit1_sum,l_unit2_sum,l_unit3_sum);
     hr_utility.set_location('unit1 max is'||l_unit1_max||l_proc,30);
     hr_utility.set_location('unit2 max is'||l_unit2_max||l_proc,40);
     hr_utility.set_location('unit3 max is'||l_unit3_max||l_proc,50);
     hr_utility.set_location('unit1 sum is'||l_unit1_sum||l_proc,60);
     hr_utility.set_location('unit2 sum is'||l_unit2_sum||l_proc,70);
     hr_utility.set_location('unit3 sum is'||l_unit3_sum||l_proc,80);
     hr_utility.set_location('unit1 avg is'||l_unit1_avg||l_proc,90);
     hr_utility.set_location('unit2 avg is'||l_unit2_avg||l_proc,100);
     hr_utility.set_location('unit3 avg is'||l_unit3_avg||l_proc,110);
     if p_unit1_aggregate ='MAXIMUM' then
        p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_max,0),p_unit1_precision);
     elsif p_unit1_aggregate = 'AVERAGE' then
        p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_avg,0),p_unit1_precision);
     else
	p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_sum,0),p_unit1_precision);
     end if;
     if p_unit2_aggregate ='MAXIMUM' then
        p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_max,0),p_unit2_precision);
     elsif p_unit2_aggregate = 'AVERAGE' then
        p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_avg,0),p_unit2_precision);
     else
	p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_sum,0),p_unit2_precision);
     end if;
     if p_unit3_aggregate ='MAXIMUM' then
        p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_max,0),p_unit3_precision);
     elsif p_unit3_aggregate = 'AVERAGE' then
        p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_avg,0),p_unit3_precision);
     else
	p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_sum,0),p_unit3_precision);
     end if;
     sub_prd(p_prd_start_date  => p_prd_start_date,
             p_prd_end_date    => p_prd_end_date,
             p_unit1_aggregate => p_unit1_aggregate,
             p_unit2_aggregate => p_unit2_aggregate,
             p_unit3_aggregate => p_unit3_aggregate,
             p_prd_unit1_value => p_unit1_value,
             p_prd_unit2_value => p_unit2_value,
             p_prd_unit3_value => p_unit3_value);
     hr_utility.set_location('available max '||p_unit1_available||l_proc,60);
  end if;
  hr_utility.set_location('exiting '||l_proc,150);
  exception when others then
p_unit1_available := l_unit1_available;
p_unit2_available := l_unit2_available;
p_unit3_available := l_unit3_available;
raise;
END prd_chg_bgt_available;
function get_prdtab_count return number is
   l_count number;
begin
   l_count := p_prd_unit_tab.COUNT;
   return l_count;
end get_prdtab_count;
procedure get_prdtab_values(p_num        in number,
			    p_start_date    out nocopy date,
			    p_unit1         out nocopy number,
			    p_unit2         out nocopy number,
			    p_unit3         out nocopy number) as
begin
   p_start_date := p_prd_unit_tab(p_num).start_date;
   p_unit1      := p_prd_unit_tab(p_num).unit1_value;
   p_unit2      := p_prd_unit_tab(p_num).unit2_value;
   p_unit3      := p_prd_unit_tab(p_num).unit3_value;
end get_prdtab_values;
procedure insert_worksheet_detail(
  p_worksheet_id                in number,
  p_organization_id             in number           default null,
  p_job_id                      in number           default null,
  p_position_id                 in number           default null,
  p_grade_id                    in number           default null,
  p_position_transaction_id     in number           default null,
  p_budget_detail_id            in number           default null,
  p_parent_worksheet_detail_id  in number           default null,
  p_user_id                     in number           default null,
  p_action_cd                   in varchar2         default null,
  p_budget_unit1_percent        in number           default null,
  p_budget_unit1_value          in number           default null,
  p_budget_unit2_percent        in number           default null,
  p_budget_unit2_value          in number           default null,
  p_budget_unit3_percent        in number           default null,
  p_budget_unit3_value          in number           default null,
  p_budget_unit1_value_type_cd  in varchar2         default null,
  p_budget_unit2_value_type_cd  in varchar2         default null,
  p_budget_unit3_value_type_cd  in varchar2         default null,
  p_status                      in varchar2         default null,
  p_budget_unit1_available      in number           default null,
  p_budget_unit2_available      in number           default null,
  p_budget_unit3_available      in number           default null,
  p_old_unit1_value             in number           default null,
  p_old_unit2_value             in number           default null,
  p_old_unit3_value             in number           default null,
  p_defer_flag                  in varchar2         default null,
  p_propagation_method          in varchar2         default null,
  p_worksheet_detail_id         out nocopy number,
  p_copy_budget_periods         in varchar2         default 'N'
) is
   l_object_version_number number;
begin
   pqh_worksheet_details_api.create_worksheet_detail_bp(
      p_validate                     => FALSE
      ,p_worksheet_detail_id         => p_worksheet_detail_id
      ,p_worksheet_id                => p_worksheet_id
      ,p_organization_id             => p_organization_id
      ,p_job_id                      => p_job_id
      ,p_position_id                 => p_position_id
      ,p_grade_id                    => p_grade_id
      ,p_position_transaction_id     => p_position_transaction_id
      ,p_budget_detail_id            => p_budget_detail_id
      ,p_parent_worksheet_detail_id  => p_parent_worksheet_detail_id
      ,p_user_id                     => p_user_id
      ,p_action_cd                   => p_action_cd
      ,p_budget_unit1_percent        => p_budget_unit1_percent
      ,p_budget_unit1_value          => p_budget_unit1_value
      ,p_budget_unit2_percent        => p_budget_unit2_percent
      ,p_budget_unit2_value          => p_budget_unit2_value
      ,p_budget_unit3_percent        => p_budget_unit3_percent
      ,p_budget_unit3_value          => p_budget_unit3_value
      ,p_object_version_number       => l_object_version_number
      ,p_budget_unit1_value_type_cd  => p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd  => p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd  => p_budget_unit3_value_type_cd
      ,p_status                      => p_status
      ,p_budget_unit1_available      => p_budget_unit1_available
      ,p_budget_unit2_available      => p_budget_unit2_available
      ,p_budget_unit3_available      => p_budget_unit3_available
      ,p_old_unit1_value             => p_old_unit1_value
      ,p_old_unit2_value             => p_old_unit2_value
      ,p_old_unit3_value             => p_old_unit3_value
      ,p_defer_flag                  => p_defer_flag
      ,p_propagation_method          => p_propagation_method
      ,p_effective_date            => trunc(sysdate)
      ,p_copy_budget_periods        => p_copy_budget_periods
  );
exception when others then
p_worksheet_detail_id := null;
raise;
end insert_worksheet_detail;

Procedure update_worksheet_detail
  (
  p_effective_date in date,
  p_worksheet_detail_id          in number,
  p_worksheet_id                 in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_position_transaction_id      in number           default hr_api.g_number,
  p_budget_detail_id             in number           default hr_api.g_number,
  p_parent_worksheet_detail_id   in number           default hr_api.g_number,
  p_user_id                      in number           default hr_api.g_number,
  p_action_cd                    in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_percent         in number           default hr_api.g_number,
  p_budget_unit1_value           in number           default hr_api.g_number,
  p_budget_unit2_percent         in number           default hr_api.g_number,
  p_budget_unit2_value           in number           default hr_api.g_number,
  p_budget_unit3_percent         in number           default hr_api.g_number,
  p_budget_unit3_value           in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_available       in number           default hr_api.g_number,
  p_budget_unit2_available       in number           default hr_api.g_number,
  p_budget_unit3_available       in number           default hr_api.g_number,
  p_old_unit1_value              in number           default hr_api.g_number,
  p_old_unit2_value              in number           default hr_api.g_number,
  p_old_unit3_value              in number           default hr_api.g_number,
  p_defer_flag                   in varchar2         default hr_api.g_varchar2,
  p_propagation_method           in varchar2         default hr_api.g_varchar2
  ) as
  l_proc varchar2(61) := g_package||'Update_wkd';
  l_object_version_number number := p_object_version_number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   hr_utility.set_location('wkd id is'||p_worksheet_detail_id||l_proc,11);
   hr_utility.set_location('ovn is'||p_object_version_number||l_proc,12);
   pqh_worksheet_details_api.update_worksheet_detail(
      p_validate                    => FALSE
      ,p_worksheet_detail_id        => p_worksheet_detail_id
      ,p_worksheet_id               => p_worksheet_id
      ,p_organization_id            => p_organization_id
      ,p_position_id                => p_position_id
      ,p_job_id                     => p_job_id
      ,p_grade_id                   => p_grade_id
      ,p_position_transaction_id    => p_position_transaction_id
      ,p_budget_detail_id           => p_budget_detail_id
      ,p_user_id                    => p_user_id
      ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
      ,p_action_cd                  => p_action_cd
      ,p_budget_unit1_value         => p_budget_unit1_value
      ,p_budget_unit1_percent       => p_budget_unit1_percent
      ,p_budget_unit1_available     => p_budget_unit1_available
      ,p_old_unit1_value            => p_old_unit1_value
      ,p_budget_unit1_value_type_cd => p_budget_unit1_value_type_cd
      ,p_budget_unit2_value         => p_budget_unit2_value
      ,p_budget_unit2_percent       => p_budget_unit2_percent
      ,p_budget_unit2_available     => p_budget_unit2_available
      ,p_old_unit2_value            => p_old_unit2_value
      ,p_budget_unit2_value_type_cd => p_budget_unit2_value_type_cd
      ,p_budget_unit3_value         => p_budget_unit3_value
      ,p_budget_unit3_percent       => p_budget_unit3_percent
      ,p_budget_unit3_available     => p_budget_unit3_available
      ,p_old_unit3_value            => p_old_unit3_value
      ,p_budget_unit3_value_type_cd => p_budget_unit3_value_type_cd
      ,p_status                     => p_status
      ,p_defer_flag                 => p_defer_flag
      ,p_object_version_number      => p_object_version_number
      ,p_effective_date             => trunc(sysdate)
      ,p_propagation_method         => p_propagation_method
    );
   hr_utility.set_location('wkd id is'||p_worksheet_detail_id||l_proc,20);
   hr_utility.set_location('ovn is'||p_object_version_number||l_proc,30);
   hr_utility.set_location('exiting'||l_proc,100);
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_worksheet_detail;

procedure copy_budget_periods(p_budget_detail_id       in number,
                              p_worksheet_detail_id    in number,
                              p_copy_budget_periods    in varchar2,
                              p_budget_unit1_value     in number,
                              p_budget_unit2_value     in number,
                              p_budget_unit3_value     in number) as
   l_object_version_number number := 1;
   l_unit1_aggregate varchar2(30);
   l_unit2_aggregate varchar2(30);
   l_unit3_aggregate varchar2(30);
   l_unit1_precision number;
   l_unit2_precision number;
   l_unit3_precision number;
   l_budget_unit1_available number;
   l_budget_unit2_available number;
   l_budget_unit3_available number;
   l_proc varchar2(61) := g_package||'copy_budget_periods' ;
begin
/*
after inserting the budget data, the periods and other details are also to be copied. In
doing this the available figures of the worksheet detail will also change.
if copy_budget_periods is yes then
   call to copy_budget_details is to be made.
   update worksheet_detail for available figures.
end if;
*/
   hr_utility.set_location('inside '||l_proc,10);
   hr_utility.set_location('called with copy_budget_periods '||p_copy_budget_periods||l_proc,15);
   if nvl(p_copy_budget_periods,'X') = 'Y' then
      hr_utility.set_location('going to copy prds from bud_det'||p_budget_detail_id||l_proc,20);
      hr_utility.set_location('going to copy prds to wks_det'||p_worksheet_detail_id||l_proc,30);
      pqh_wks_budget.get_wkd_unit_aggregate(p_worksheet_detail_id => p_worksheet_detail_id,
                                            p_unit1_aggregate     => l_unit1_aggregate,
                                            p_unit2_aggregate     => l_unit2_aggregate,
                                            p_unit3_aggregate     => l_unit3_aggregate);
      pqh_wks_budget.get_wkd_unit_precision(p_worksheet_detail_id => p_worksheet_detail_id,
                                            p_unit1_precision     => l_unit1_precision,
                                            p_unit2_precision     => l_unit2_precision,
                                            p_unit3_precision     => l_unit3_precision);
      hr_utility.set_location('unit aggregate fetched'||l_proc,40);
      l_budget_unit1_available := p_budget_unit1_value;
      l_budget_unit2_available := p_budget_unit2_value;
      l_budget_unit3_available := p_budget_unit3_value;
      hr_utility.set_location('going to copy_budget_details'||l_proc,50);
      copy_budget_details(p_budget_detail_id       => p_budget_detail_id,
   		          p_worksheet_detail_id    => p_worksheet_detail_id,
                          p_unit1_aggregate        => l_unit1_aggregate,
                          p_unit2_aggregate        => l_unit2_aggregate,
                          p_unit3_aggregate        => l_unit3_aggregate,
                          p_unit1_precision        => l_unit1_precision,
                          p_unit2_precision        => l_unit2_precision,
                          p_unit3_precision        => l_unit3_precision,
		          p_budget_unit1_value     => p_budget_unit1_value,
		          p_budget_unit2_value     => p_budget_unit2_value,
		          p_budget_unit3_value     => p_budget_unit3_value,
                          p_budget_unit1_available => l_budget_unit1_available,
                          p_budget_unit2_available => l_budget_unit2_available,
                          p_budget_unit3_available => l_budget_unit3_available);
      hr_utility.set_location('after copy_budget_details'||l_proc,60);
      hr_utility.set_location('going for update_wkd with ovn'||l_object_version_number||l_proc,70);
      update_worksheet_detail(
      p_worksheet_detail_id               => p_worksheet_detail_id,
      p_effective_date                    => trunc(sysdate),
      p_object_version_number             => l_object_version_number,
      p_budget_unit1_available            => l_budget_unit1_available,
      p_budget_unit2_available            => l_budget_unit2_available,
      p_budget_unit3_available            => l_budget_unit3_available
      );
      hr_utility.set_location('after update_wkd with ovn'||l_object_version_number||l_proc,80);
   end if;
   hr_utility.set_location('exiting'||l_proc,100);
end copy_budget_periods;

/*
This copy budget_details is called from insert-from_budget procedure when copy_budget_periods is enable
this is a local procedure only. There exists another procedure with the same name which is also in header with
different signature , which copies values as well.
Value coping will be going away after some time.
*/
procedure copy_budget_details(p_budget_detail_id       in number,
			      p_worksheet_detail_id    in number) is
   cursor c1(p_budget_detail_id number) is
      select budget_period_id,start_time_period_id,end_time_period_id
      from pqh_budget_periods
      where budget_detail_id = p_budget_detail_id;
   cursor c2(p_budget_period_id number) is
      select budget_set_id,dflt_budget_set_id
      from pqh_budget_sets
      where budget_period_id = p_budget_period_id;
   cursor c3(p_budget_set_id number) is
      select budget_element_id,element_type_id,distribution_percentage
      from pqh_budget_elements
      where budget_set_id = p_budget_set_id;
   cursor c4(p_budget_element_id number) is
      select cost_allocation_keyflex_id,distribution_percentage
      from pqh_budget_fund_srcs
      where budget_element_id = p_budget_element_id;
   l_worksheet_period_id   number(15,2);
   l_worksheet_budget_set_id  number(15,2);
   l_worksheet_bdgt_elmnt_id  number(15,2);
   l_worksheet_fund_src_id number(15,2);
   l_budget_detail_id      number(15,2);
   l_count                 number ;
   l_object_version_number number;
   l_proc varchar2(100) := g_package||'copy_budget_details' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   select count(*) into l_count
   from pqh_worksheet_periods where worksheet_detail_id = p_worksheet_detail_id;
   if l_count = 0 then
      hr_utility.set_location('no periods found '||l_proc,20);
      for i in c1(p_budget_detail_id) loop
         hr_utility.set_location('for each budget_detail '||l_proc,30);
         pqh_worksheet_periods_api.create_worksheet_period(
            p_validate                   => FALSE
           ,p_effective_date             => trunc(sysdate)
           ,p_worksheet_detail_id        => p_worksheet_detail_id
           ,p_worksheet_period_id        => l_worksheet_period_id
           ,p_start_time_period_id       => i.start_time_period_id
           ,p_end_time_period_id         => i.end_time_period_id
           ,p_object_version_number      => l_object_version_number
           );
         hr_utility.set_location('period inserted '||l_proc,37);
         for j in c2(i.budget_period_id) loop
            hr_utility.set_location('for each period '||l_proc,40);
            pqh_worksheet_budget_sets_api.create_worksheet_budget_set(
               p_validate                   => FALSE
              ,p_effective_date             => trunc(sysdate)
              ,p_worksheet_budget_set_id    => l_worksheet_budget_set_id
              ,p_worksheet_period_id        => l_worksheet_period_id
              ,p_dflt_budget_set_id         => j.dflt_budget_set_id
              ,p_object_version_number      => l_object_version_number
              );
            for k in c3(j.budget_set_id) loop
               hr_utility.set_location('for each budgetset '||l_proc,50);
               pqh_worksheet_bdgt_elmnts_api.create_worksheet_bdgt_elmnt(
                  p_validate                   => FALSE
                 ,p_worksheet_budget_set_id    => l_worksheet_budget_set_id
                 ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                 ,p_element_type_id            => k.element_type_id
                 ,p_object_version_number      => l_object_version_number
                 ,p_distribution_percentage    => k.distribution_percentage
                 );
               for l in c4(k.budget_element_id) loop
                  hr_utility.set_location('for each budget_element '||l_proc,60);
                  pqh_worksheet_fund_srcs_api.create_worksheet_fund_src(
                     p_validate                   => FALSE
                    ,p_worksheet_fund_src_id      => l_worksheet_fund_src_id
                    ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                    ,p_cost_allocation_keyflex_id => l.cost_allocation_keyflex_id
                    ,p_object_version_number      => l_object_version_number
                    ,p_distribution_percentage    => l.distribution_percentage
                    );
               end loop;
            end loop;
         end loop;
      end loop;
   end if;
   hr_utility.set_location('exiting '||l_proc,150);
end copy_budget_details;

/*
    procedure which only copies the budget details and values are left blank
    call is made to copy_budget_details instead of copy_budget_periods as
    no values are to be copied, available etc. are not calculated.
*/

procedure insert_from_budget(p_budget_version_id          in     number,
                             p_budgeted_entity_cd         in     varchar,
                             p_worksheet_id               in     number,
			     p_business_group_id          in     number,
			     p_start_organization_id      in     number,
                             p_parent_worksheet_detail_id in     number,
                             p_org_hier_ver               in     number,
                             p_copy_budget_periods        in     varchar2,
                             p_rows_inserted                 out nocopy number) IS
  cursor c1 is select position_id , grade_id, bud.organization_id organization_id, job_id,budget_detail_id
               from pqh_budget_details bud, hr_organization_units org
               where org.business_group_id = p_business_group_id
               and bud.organization_id = org.organization_id
               and pqh_budget.already_budgeted_pos(bud.position_id) = 'FALSE'
               and bud.budget_version_id = p_budget_version_id;
  cursor c2 is select bud.position_id, bud.grade_id, bud.organization_id , bud.job_id,bud.budget_detail_id
               from  (select organization_id_child from pqh_worksheet_organizations_v
		      where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual )x
	       , pqh_budget_details bud
	       where pqh_budget.already_budgeted_pos(bud.position_id) = 'FALSE'
               and bud.budget_version_id = p_budget_version_id
               and bud.organization_id  = x.organization_id_child;
  cursor c3 is select position_id , grade_id, bud.organization_id organization_id, job_id,budget_detail_id
               from pqh_budget_details bud, hr_organization_units org
               where org.business_group_id = p_business_group_id
               and bud.organization_id = org.organization_id
               and pqh_budget.already_budgeted_org(bud.organization_id) = 'FALSE'
               and bud.budget_version_id = p_budget_version_id;
  cursor c4 is select position_id, grade_id, organization_id , job_id,budget_detail_id
               from  (select organization_id_child from pqh_worksheet_organizations_v
		      where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id and org_structure_version_id = p_org_hier_ver
		      union all
		      select p_start_organization_id organization_id_child from dual )x
	       , pqh_budget_details
               where pqh_budget.already_budgeted_org(organization_id) = 'FALSE'
               and budget_version_id = p_budget_version_id
               and organization_id  = x.organization_id_child;
  cursor c5 is select position_id ,grade_id, organization_id , job_id,budget_detail_id
               from pqh_budget_details
               where pqh_budget.already_budgeted_job(job_id) = 'FALSE'
               and budget_version_id = p_budget_version_id;
  cursor c6 is select position_id ,grade_id, organization_id , job_id,budget_detail_id
               from pqh_budget_details
               where pqh_budget.already_budgeted_grd(grade_id) = 'FALSE'
               and budget_version_id = p_budget_version_id;
  cursor c7 is select position_id ,grade_id, organization_id , job_id,budget_detail_id
               from pqh_budget_details
               where budget_version_id = p_budget_version_id;
  l_rows_inserted number := 0;
  l_proc varchar2(100) := g_package||'insert_from_budget' ;
  l_worksheet_detail_id number;
begin
   hr_utility.set_location('entering '||l_proc,10);
-- available is made equal to value as periods and details are not fetched for the time being.
-- percent calc using the worksheet values and the existing budget values will create problem when the difference
-- in worksheet value and version value is there.
-- so it is decidied that instead of keeping the value same, we will keep the % same and compute the value.
-- but for bottom_up budget % is not entered or computed, so this procedure is to be overloaded so that only
-- the details are copied and not the values

  if p_budgeted_entity_cd = 'POSITION' then
     hr_utility.set_location('budget entity is Position '||l_proc,20);
     if p_org_hier_ver is null then
        hr_utility.set_location('org hier is null using BG '||l_proc,30);
        for i in c1 loop
           l_rows_inserted := l_rows_inserted + 1;
           hr_utility.set_location('inserting into plsql table'||l_proc,70);
           pqh_budget.insert_pos_is_bud(i.position_id);
           hr_utility.set_location('inserting into worksheet_detail table'||l_proc,80);
           insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                  ,p_worksheet_id               => p_worksheet_id
                                  ,p_organization_id            => i.organization_id
                                  ,p_job_id                     => i.job_id
                                  ,p_position_id                => i.position_id
                                  ,p_grade_id                   => i.grade_id
                                  ,p_position_transaction_id    => ''
                                  ,p_budget_detail_id           => i.budget_detail_id
                                  ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                  ,p_user_id                    => ''
                                  ,p_action_cd                  => 'B'
                                  ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('insert worksheet_detail table complete'||l_proc,90);
           if nvl(p_copy_budget_periods,'X') = 'Y' then
              copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
        end loop;
     else
        hr_utility.set_location('using org hier '||l_proc,120);
        hr_utility.set_location('before insert loop '||l_proc,135);
        for i in c2 loop
           hr_utility.set_location('inside insert loop '||l_proc,140);
           l_rows_inserted := l_rows_inserted + 1;
           hr_utility.set_location('going for insert '||l_proc,148);
           pqh_budget.insert_pos_is_bud(i.position_id);
           insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                  ,p_worksheet_id               => p_worksheet_id
                                  ,p_organization_id            => i.organization_id
                                  ,p_job_id                     => i.job_id
                                  ,p_position_id                => i.position_id
                                  ,p_grade_id                   => i.grade_id
                                  ,p_position_transaction_id    => ''
                                  ,p_budget_detail_id           => i.budget_detail_id
                                  ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                  ,p_user_id                    => ''
                                  ,p_action_cd                  => 'B'
                                  ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('row inserted going for period copy'||l_proc,150);
           if nvl(p_copy_budget_periods,'X') = 'Y' then
              copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
           hr_utility.set_location('after copying budget_periods '||l_proc,100);
        end loop;
     end if;
  elsif p_budgeted_entity_cd ='ORGANIZATION' then
     hr_utility.set_location('budget entity organization '||l_proc,160);
     if p_org_hier_ver is null then
        hr_utility.set_location('org hier null using bg '||l_proc,170);
        hr_utility.set_location('before insert loop '||l_proc,190);
        for i in c3 loop
           l_rows_inserted := l_rows_inserted + 1;
           pqh_budget.insert_org_is_bud(i.organization_id);
           insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                  ,p_worksheet_id               => p_worksheet_id
                                  ,p_organization_id            => i.organization_id
                                  ,p_job_id                     => i.job_id
                                  ,p_position_id                => i.position_id
                                  ,p_grade_id                   => i.grade_id
                                  ,p_position_transaction_id    => ''
                                  ,p_budget_detail_id           => i.budget_detail_id
                                  ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                  ,p_user_id                    => ''
                                  ,p_action_cd                  => 'B'
                                  ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('after insert '||l_proc,200);
           if nvl(p_copy_budget_periods,'X') = 'Y' then
              copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
        end loop;
     else
        hr_utility.set_location('using org hier '||l_proc,210);
        hr_utility.set_location('before insert loop  '||l_proc,230);
        for i in c4 loop
           l_rows_inserted := l_rows_inserted + 1;
           pqh_budget.insert_org_is_bud(i.organization_id);
           insert_worksheet_detail(p_worksheet_detail_id        => l_worksheet_detail_id
                                  ,p_worksheet_id               => p_worksheet_id
                                  ,p_organization_id            => i.organization_id
                                  ,p_job_id                     => i.job_id
                                  ,p_position_id                => i.position_id
                                  ,p_grade_id                   => i.grade_id
                                  ,p_position_transaction_id    => ''
                                  ,p_budget_detail_id           => i.budget_detail_id
                                  ,p_parent_worksheet_detail_id => p_parent_worksheet_detail_id
                                  ,p_user_id                    => ''
                                  ,p_action_cd                  => 'B'
                                  ,p_copy_budget_periods        => p_copy_budget_periods );
           hr_utility.set_location('after insert '||l_proc,240);
           if nvl(p_copy_budget_periods,'X') = 'Y' then
              copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                  p_worksheet_detail_id    => l_worksheet_detail_id) ;
              hr_utility.set_location('after copying budget_periods '||l_proc,100);
           end if;
        end loop;
     end if;
  elsif p_budgeted_entity_cd ='JOB' then
     hr_utility.set_location('budget entity job'||l_proc,260);
     hr_utility.set_location('before insert loop'||l_proc,270);
     for i in c5 loop
        l_rows_inserted := l_rows_inserted + 1;
        pqh_budget.insert_job_is_bud(i.job_id);
           insert_worksheet_detail
           (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_copy_budget_periods        => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,280);
         hr_utility.set_location('after available change '||l_proc,290);
         if nvl(p_copy_budget_periods,'X') = 'Y' then
            copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                p_worksheet_detail_id    => l_worksheet_detail_id) ;
            hr_utility.set_location('after copying budget_periods '||l_proc,100);
         end if;
     end loop;
  elsif p_budgeted_entity_cd ='GRADE' then
     hr_utility.set_location('budget entity grade'||l_proc,300);
     hr_utility.set_location('before insert loop '||l_proc,310);
     for i in c6 loop
        l_rows_inserted := l_rows_inserted + 1;
        pqh_budget.insert_grd_is_bud(i.grade_id);
           insert_worksheet_detail
           (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_copy_budget_periods            => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,320);
         hr_utility.set_location('after available change '||l_proc,330);
         if nvl(p_copy_budget_periods,'X') = 'Y' then
            copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                p_worksheet_detail_id    => l_worksheet_detail_id) ;
            hr_utility.set_location('after copying budget_periods '||l_proc,100);
         end if;
     end loop;
  elsif p_budgeted_entity_cd ='OPEN' then
     hr_utility.set_location('budget entity OPEN '||l_proc,340);
     hr_utility.set_location('before insert loop '||l_proc,350);
     for i in c7 loop
        l_rows_inserted := l_rows_inserted + 1;
           insert_worksheet_detail
           (
            p_worksheet_detail_id            =>  l_worksheet_detail_id
           ,p_worksheet_id                   =>  p_worksheet_id
           ,p_organization_id                =>  i.organization_id
           ,p_job_id                         =>  i.job_id
           ,p_position_id                    =>  i.position_id
           ,p_grade_id                       =>  i.grade_id
           ,p_position_transaction_id        =>  ''
           ,p_budget_detail_id               =>  i.budget_detail_id
           ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
           ,p_user_id                        =>  ''
           ,p_action_cd                      =>  'B'
           ,p_copy_budget_periods            => p_copy_budget_periods );
         hr_utility.set_location('after insert '||l_proc,360);
         if nvl(p_copy_budget_periods,'X') = 'Y' then
            copy_budget_details(p_budget_detail_id       => i.budget_detail_id,
                                p_worksheet_detail_id    => l_worksheet_detail_id) ;
            hr_utility.set_location('after copying budget_periods '||l_proc,100);
         end if;
     end loop;
  end if;
  p_rows_inserted := l_rows_inserted;
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
   p_rows_inserted := null;
   raise;
end insert_from_budget;

FUNCTION get_currency_cd (p_budget_id in number) RETURN varchar2 IS
/* This function will return the currency code of the budget */
l_proc                       varchar2(72) := g_package||'get_currency_cd';
l_currency_code              varchar2(240);
l_business_group_id          number;

--
/* NS: 2005/08/16: Sql Perf Repos Id: 12255124: Need to remove MJC
CURSOR csr_bus_grp IS
SELECT currency_code
FROM per_business_groups
WHERE business_group_id = l_business_group_id;
*/
--
/*
CURSOR csr_bus_grp IS
SELECT org_information10
FROM hr_organization_information
WHERE organization_id = l_business_group_id;
*/
-- cursor csr_bus_grp changed as the previous definition of it does not have
-- the organization information context as a filter. Bug 5867046
CURSOR csr_bus_grp IS
 SELECT org_information10
   FROM hr_organization_information hoi
  WHERE hoi.organization_id = l_business_group_id
    AND hoi.org_information_context = 'Business Group Information'
    AND hoi.org_information2 IS NOT NULL
    AND EXISTS
	( SELECT NULL
	    FROM hr_org_info_types_by_class oitbc,
		 hr_organization_information org_info
	   WHERE org_info.organization_id = hoi.organization_id
	     AND org_info.org_information_context = 'CLASS'
	     AND org_info.org_information2  = 'Y'
	     AND oitbc.org_classification   = org_info.org_information1
	     AND oitbc.org_information_type = 'Business Group Information'
	 );
--
CURSOR csr_bgt IS
SELECT currency_code,business_group_id
FROM pqh_budgets bgt
WHERE bgt.budget_id = p_budget_id;
begin
   open csr_bgt;
   fetch csr_bgt into l_currency_code,l_business_group_id;
   close csr_bgt;
   if l_currency_code is null then
      open csr_bus_grp;
      fetch csr_bus_grp into l_currency_code;
      close csr_bus_grp;
   end if;
   return l_currency_code;
end get_currency_cd;
--
/*
    procedure calculates the budget detail available values
*/
PROCEDURE calculate_bgt_det_available(p_unit1_aggregate     in varchar2,
                                p_unit2_aggregate     in varchar2,
                                p_unit3_aggregate     in varchar2,
                                p_bgt_unit1_value     in number,
                                p_bgt_unit2_value     in number,
                                p_bgt_unit3_value     in number,
                                p_unit1_precision     in number,
                                p_unit2_precision     in number,
                                p_unit3_precision     in number,
                                p_unit1_available     in out nocopy number,
                                p_unit2_available     in out nocopy number,
                                p_unit3_available     in out nocopy number ) IS
  l_unit1_max number;
  l_unit2_max number;
  l_unit3_max number;
  l_unit1_sum number;
  l_unit2_sum number;
  l_unit3_sum number;
  l_unit1_avg number;
  l_unit2_avg number;
  l_unit3_avg number;
  l_unit1_available number := p_unit1_available;
  l_unit2_available number := p_unit2_available;
  l_unit3_available number := p_unit3_available;
  l_proc varchar2(51) := g_package||'prd_chg_bgt_available';
BEGIN
     hr_utility.set_location('entering'||l_proc,10);
     --
     chk_unit_max(l_unit1_max,l_unit2_max,l_unit3_max);
     chk_unit_avg(l_unit1_avg,l_unit2_avg,l_unit3_avg);
     chk_unit_sum(l_unit1_sum,l_unit2_sum,l_unit3_sum);
     hr_utility.set_location('unit1 max is'||l_unit1_max||l_proc,30);
     hr_utility.set_location('unit2 max is'||l_unit2_max||l_proc,40);
     hr_utility.set_location('unit3 max is'||l_unit3_max||l_proc,50);
     hr_utility.set_location('unit1 sum is'||l_unit1_sum||l_proc,60);
     hr_utility.set_location('unit2 sum is'||l_unit2_sum||l_proc,70);
     hr_utility.set_location('unit3 sum is'||l_unit3_sum||l_proc,80);
     hr_utility.set_location('unit1 avg is'||l_unit1_avg||l_proc,90);
     hr_utility.set_location('unit2 avg is'||l_unit2_avg||l_proc,100);
     hr_utility.set_location('unit3 avg is'||l_unit3_avg||l_proc,110);
     if p_unit1_aggregate ='MAXIMUM' then
        p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_max,0),p_unit1_precision);
     elsif p_unit1_aggregate = 'AVERAGE' then
        p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_avg,0),p_unit1_precision);
     else
	p_unit1_available := round(nvl(p_bgt_unit1_value,0) - nvl(l_unit1_sum,0),p_unit1_precision);
     end if;
     if p_unit2_aggregate ='MAXIMUM' then
        p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_max,0),p_unit2_precision);
     elsif p_unit2_aggregate = 'AVERAGE' then
        p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_avg,0),p_unit2_precision);
     else
	p_unit2_available := round(nvl(p_bgt_unit2_value,0) - nvl(l_unit2_sum,0),p_unit2_precision);
     end if;
     if p_unit3_aggregate ='MAXIMUM' then
        p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_max,0),p_unit3_precision);
     elsif p_unit3_aggregate = 'AVERAGE' then
        p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_avg,0),p_unit3_precision);
     else
	p_unit3_available := round(nvl(p_bgt_unit3_value,0) - nvl(l_unit3_sum,0),p_unit3_precision);
     end if;
     hr_utility.set_location('available max '||p_unit1_available||l_proc,60);
     --
  hr_utility.set_location('exiting '||l_proc,150);
  exception when others then
p_unit1_available := l_unit1_available;
p_unit2_available := l_unit2_available;
p_unit3_available := l_unit3_available;
raise;
END calculate_bgt_det_available;
--
-- Add Budgetrow used in Position form
--
procedure add_budgetrow(p_budget_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2,
                        p_budget_id in number) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_budget_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.budget_detail_id = p_budget_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'add_budgetrow';
   l_budget_id number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   if p_budget_id is not null then
     l_budget_id := p_budget_id;
   else
     l_budget_id := pqh_wks_budget.get_bgd_budget(p_budget_detail_id => p_budget_detail_id);
   end if;
   init_prd_tab(p_budget_id => l_budget_id);
   for i in c1 loop
       add_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end add_budgetrow;
--
procedure add_budgetrow(p_worksheet_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2,
                        p_budget_id in number) as
   cursor c1 is select tps.start_date prd_start_date,tpe.end_date prd_end_date,
		       prd.budget_unit1_value unit1_value,prd.budget_unit2_value unit2_value,
		       prd.budget_unit3_value unit3_value
		from pqh_worksheet_periods prd, per_time_periods tps, per_time_periods tpe
		where prd.worksheet_detail_id = p_worksheet_detail_id
		and prd.start_time_period_id = tps.time_period_id
		and prd.end_time_period_id = tpe.time_period_id;
   l_proc varchar2(51) := g_package||'add_budgetrow';
   l_budget_id number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   if p_budget_id is not null then
     l_budget_id := p_budget_id;
   else
     l_budget_id := pqh_wks_budget.get_wkd_budget(p_worksheet_detail_id => p_worksheet_detail_id);
   end if;
   init_prd_tab(p_budget_id => l_budget_id);
   for i in c1 loop
       add_prd(p_prd_start_date  => i.prd_start_date,
	       p_prd_end_date    => i.prd_end_date,
               p_unit1_aggregate => p_unit1_aggregate,
               p_unit2_aggregate => p_unit2_aggregate,
               p_unit3_aggregate => p_unit3_aggregate,
	       p_prd_unit1_value => i.unit1_value,
	       p_prd_unit2_value => i.unit2_value,
	       p_prd_unit3_value => i.unit3_value);
   end loop;
   hr_utility.set_location('exit'||l_proc,100);
end add_budgetrow;
--
end pqh_budget;

/
