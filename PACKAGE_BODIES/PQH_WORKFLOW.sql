--------------------------------------------------------
--  DDL for Package Body PQH_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WORKFLOW" as
/* $Header: pqwrkflw.pkb 120.4.12010000.5 2008/09/22 13:13:37 brsinha ship $ */
g_package varchar2(100) := 'pqh_workflow.';
procedure get_primary_asg_details(p_person_id      in number,
                                  p_effective_date in date,
                                  p_assignment_id     out nocopy number,
                                  p_position_id       out nocopy number) is
begin
   select assignment_id,position_id
   into p_assignment_id, p_position_id
   from   per_all_assignments_f
   where  person_id = p_person_id
   and    primary_flag ='Y'
   AND    assignment_type = 'E'  -- bug 7330323
   and    p_effective_date between effective_start_date and effective_end_date;
exception
   when others THEN
      hr_utility.set_location('Error inside get_primary_asg_details: ',10);
      hr_utility.set_location(sqlerrm,15);
      p_assignment_id := null;
      p_position_id := null;
end;
procedure get_user_name_details(p_user_name   in varchar2,
                                p_user_id     out nocopy number,
                                p_employee_id out nocopy varchar2) is
   l_user_id fnd_user.user_id%type;
   l_employee_id fnd_user.employee_id%type;
begin
   select user_id,employee_id
   into l_user_id,l_employee_id
   from fnd_user
   where user_name = p_user_name;
   p_user_id := l_user_id;
   p_employee_id := l_employee_id;
exception
   when others then
      p_user_id := l_user_id;
      p_employee_id := l_employee_id;
end;

procedure get_user_id_details(p_user_id     in number,
                              p_user_name   out nocopy varchar2,
                              p_employee_id out nocopy varchar2) is
   l_user_name fnd_user.user_name%type;
   l_employee_id fnd_user.employee_id%type;
begin
   select user_name,employee_id
   into l_user_name,l_employee_id
   from fnd_user
   where user_id = p_user_id;
   p_user_name := l_user_name;
   p_employee_id := l_employee_id;
exception
   when others then
      p_user_name := l_user_name;
      p_employee_id := l_employee_id;
end;
function tran_setup(p_tran_cat_id in number) return varchar2 is
   l_setup_type_cd    varchar2(30);
   l_freeze_status_cd varchar2(30);
begin
   select freeze_status_cd,setup_type_cd
   into l_freeze_status_cd,l_setup_type_cd
   from pqh_transaction_categories
   where transaction_category_id = p_tran_cat_id
   and nvl(enable_flag,'Y') = 'Y';
   if l_freeze_status_cd <>'FREEZE_CATEGORY' then
      l_setup_type_cd := 'INCOMPLETE' ;
   end if;
   return l_setup_type_cd;
end tran_setup;

function pos_in_ph(p_position_id    in number,
                   p_pos_str_ver_id in number) return varchar2 is
   l_return varchar2(30);
begin
   hr_utility.set_location('Entering pos_in_ph',10);

   select 'TRUE' into l_return
   from per_pos_structure_elements
   where subordinate_position_id = p_position_id
   and pos_structure_version_id = p_pos_str_ver_id;

   hr_utility.set_location('Exiting pos_in_ph',100);

   return l_return;
exception
   when no_data_found then
   begin
      hr_utility.set_location('Exiting pos_in_ph',101);

      select 'TRUE' into l_return
      from per_pos_structure_elements
      where parent_position_id = p_position_id
      and pos_structure_version_id = p_pos_str_ver_id;

      hr_utility.set_location('Exiting pos_in_ph',102);

      return l_return;
   exception
      when no_data_found then
         hr_utility.set_location('Exiting pos_in_ph',103);

         l_return := 'FALSE';
         return l_return;
      when too_many_rows then
         hr_utility.set_location('Exiting pos_in_ph',104);
         return 'TRUE';
   end;
   when too_many_rows then
     hr_utility.set_location('Exiting pos_in_ph',105);
     return 'TRUE';
end;

function get_transaction_category_name(p_transaction_category_id in number) return varchar2 is
   cursor c1 is select name
                from pqh_transaction_categories
                where transaction_category_id = p_transaction_category_id;
   l_transaction_category_name pqh_transaction_categories.name%type;
begin
   open c1;
   fetch c1 into l_transaction_category_name;
   close c1;
   return l_transaction_category_name;

end get_transaction_category_name;

function get_role_name(p_role_id in number) return varchar2 is
   cursor c1 is select role_name
                from pqh_roles
                where role_id = p_role_id;
   l_role_name pqh_roles.role_name%type;
begin
   open c1;
   fetch c1 into l_role_name;
   close c1;
   return l_role_name;
end get_role_name;

/**
function get_user_default_role(p_user_id in number,
                               p_session_date in date) return number is
   l_role_id number;
   cursor c_get_user_role (p_user_id number) is
          select decode(information_type, 'PQH_ROLE_USERS', to_number(pei.pei_information3), 0) role_id
          from per_people_extra_info pei , per_all_people_f ppf, fnd_user usr
          WHERE information_type = 'PQH_ROLE_USERS' and pei.person_id = ppf.person_id
          and p_session_date between ppf.effective_start_date and ppf.effective_end_date
          and usr.employee_id = ppf.person_id
          and nvl(pei.pei_information5,'Y')='Y'
          and nvl(pei.pei_information4,'N')='Y'
          and usr.user_id = p_user_id;
begin
   open c_get_user_role(p_user_id => p_user_id);
   fetch c_get_user_role into l_role_id;
   close c_get_user_role;
   return l_role_id;
end get_user_default_role;
**/

procedure get_default_role(p_session_date            in  date,
                           p_transaction_category_id in  number,
                           p_user_id                 in  number,
                           p_person_id               out nocopy number,
                           p_role_id                 out nocopy number) is
   l_member_cd               pqh_transaction_categories.member_cd%type;
   l_position_id             number;
   l_person_name             varchar2(240);
   l_position_name           hr_all_positions_f.name%type;
   l_assignment_id           number;
   l_workflow_enable_flag    pqh_transaction_categories.workflow_enable_flag%type;
   l_proc       varchar2(256) := g_package||'get_default_role';
   l_user_name  fnd_user.user_name%type := fnd_profile.value('USERNAME');

   cursor c_get_employee(p_user_id number) is
      select employee_id
      from fnd_user
      where user_id = p_user_id;

   cursor c_get_txn_cat (p_transaction_category_id number) IS
       select member_cd, workflow_enable_flag
       from   pqh_transaction_categories tct
       where  transaction_category_id = p_transaction_category_id;

   cursor c_get_assignment (p_user_id number) IS
         select asg.assignment_id,asg.position_id
         from per_all_assignments_f asg
            , fnd_user fu
         where asg.person_id = fu.employee_id
           and fu.user_id = p_user_id
           and asg.primary_flag = 'Y'
	   AND asg.assignment_type = 'E'  -- Bug 7422915
           and p_session_date between asg.effective_start_date and asg.effective_end_date;

   cursor c_get_pos_role(p_assignment_id number) is
          select decode(information_type, 'PQH_POS_ROLE_ID' , to_number(poei_information3), -1) ROLE_ID
          from per_position_extra_info pei, hr_all_positions_f pos, per_all_assignments_f asg
          where pei.position_id=pos.position_id and pei.information_type='PQH_POS_ROLE_ID'
          and pos.position_id = asg.position_id
          and p_session_date between pos.effective_start_date and pos.effective_end_date
          and p_session_date between asg.effective_start_date and asg.effective_end_date
          and asg.assignment_id = p_assignment_id;
begin
   hr_utility.set_location('Entering'||l_proc,10);
   hr_utility.set_location('user_id is'||p_user_id||l_proc,11);
   open c_get_txn_cat(p_transaction_category_id => p_transaction_category_id);
   fetch c_get_txn_cat into l_member_cd, l_workflow_enable_flag;
   close c_get_txn_cat;
   if nvl(l_workflow_enable_flag, 'N') = 'Y' then
      hr_utility.set_location('txn_cat wf_enabled'||l_proc,20);
      open c_get_employee(p_user_id => p_user_id);
      fetch c_get_employee into p_person_id;
      close c_get_employee;
      if p_person_id is null then
         hr_utility.set_location('person does not exist'||l_proc,21);
         p_role_id := -2;
      else
         l_person_name := hr_general.decode_person_name(p_person_id =>p_person_id);
         hr_utility.set_location('person_id is'||p_person_id||l_proc,25);
         hr_utility.set_location('person is'||l_person_name||l_proc,26);
         if l_member_cd = 'R'  then
            hr_utility.set_location('routing style RL'||l_proc,30);
            p_role_id := get_user_default_role(p_user_id => p_user_id);
/**
            p_role_id := get_user_default_role(p_user_id => p_user_id,
                                               p_session_date => p_session_date);
**/
         elsif l_member_cd in ('P','S') then
            hr_utility.set_location('routing style '||l_member_cd||l_proc,40);
            open c_get_assignment(p_user_id => p_user_id);
            fetch c_get_assignment into l_assignment_id,l_position_id;
            if c_get_assignment%notfound then
               close c_get_assignment;
               hr_utility.set_location('primary assignment not found '||l_proc,45);
               hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
               hr_utility.set_message_token('PERSON',l_person_name);
            else
               close c_get_assignment;
               if l_position_id is not null then
                  hr_utility.set_location('assignment for pos:'||l_position_id||l_proc,50);
                  open c_get_pos_role(p_assignment_id => l_assignment_id);
                  fetch c_get_pos_role into p_role_id;
                  if c_get_pos_role%notfound then
                     hr_utility.set_location('role not attached to POS'||l_proc,52);
                     l_position_name := hr_general.decode_position_latest_name(p_position_id =>l_position_id);
                     hr_utility.set_location('POS name'||l_position_name||l_proc,53);
                     hr_utility.set_message(8302,'PQH_NO_ACTIVE_ROLE_FOR_POS');
                     hr_utility.set_message_token('POSITION',l_position_name);
                     hr_utility.set_message_token('PERSON',l_person_name);
                     p_role_id := -3 ;
                  else
                     hr_utility.set_location('role for pos:'||p_role_id||l_proc,55);
                  end if;
                  close c_get_pos_role;
               else
                  hr_utility.set_location('user role '||l_proc,60);
            p_role_id := get_user_default_role(p_user_id => p_user_id);
/**
                  p_role_id := get_user_default_role(p_user_id => p_user_id,
                                                     p_session_date => p_session_date);
**/
               end if;
            end if;
         end if;
      end if;
   else
      p_role_id := -1;
   end if;
   hr_utility.set_location('default role is'||p_role_id||l_proc,70);
   hr_utility.set_location('Exiting'||l_proc,80);
   exception when others then
   p_person_id := null;
   p_role_id := null;
   raise;
end get_default_role;

function get_role_template(p_role_id                 in number,
                           p_transaction_category_id in number) return number is
   cursor c1 is select template_id
                from pqh_role_templates
                where role_id = p_role_id
                and transaction_category_id = p_transaction_category_id
                and enable_flag = 'Y';
   l_template_id  pqh_role_templates.template_id%type;
   l_role_name pqh_roles.role_name%type;
   l_transaction_category_name pqh_transaction_categories.name%type;
begin
   open c1;
   fetch c1 into l_template_id;
   if c1%notfound then
      l_template_id := -1 ;
      l_role_name := get_role_name(p_role_id);
      l_transaction_category_name := get_transaction_category_name(p_transaction_category_id);
      hr_utility.set_message(8302,'PQH_NO_DOMAIN_TEMPLATE');
      hr_utility.set_message_token('ROLE',l_role_name);
      hr_utility.set_message_token('TRANSACTION_CATEGORY',l_transaction_category_name);
   end if;
   close c1;
   return l_template_id;
end get_role_template;

function check_user_pos_details(p_value_date in date,
                                p_person_id  in number) return number is
   l_error_cd number := 0;
   l_position_id number;
   l_assignment_id number;
   l_proc       varchar2(256) := g_package||'check_user_pos_details';
   l_effective_date  date;
   l_user_name  fnd_user.user_name%type := fnd_profile.value('USERNAME');
   l_position_name varchar2(240);
   l_person_name varchar2(240);
begin
   hr_utility.set_location('Entering '||l_proc,10);
   l_person_name := hr_general.decode_person_name(p_person_id =>p_person_id);
   get_primary_asg_details(p_person_id      => p_person_id,
                           p_effective_date => p_value_date,
                           p_assignment_id  => l_assignment_id,
                           p_position_id    => l_position_id);
   if l_assignment_id is null then
      l_error_cd := 2;
      hr_utility.set_location('primary assignment not found '||l_proc,50);
      hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
      hr_utility.set_message_token('PERSON',l_person_name);
   else
      hr_utility.set_location('details found '||l_proc,52);
      if l_position_id is null then
         l_error_cd := 3;
         hr_utility.set_location('primary assignment not for position '||l_proc,54);
         hr_utility.set_message(8302,'PQH_PRIMARY_ASG_NOT_POS');
         hr_utility.set_message_token('PERSON',l_person_name);
      else
         hr_utility.set_location('position found '||l_position_id||l_proc,60);
         l_effective_date := hr_general.get_position_date_end(p_position_id => l_position_id);
         if (l_effective_date is null or l_effective_date > trunc(sysdate)) then
            hr_utility.set_location('valid position '||l_proc,61);
         else
            l_error_cd := 4;
            l_position_name := hr_general.decode_position_latest_name(l_position_id);
            hr_utility.set_location('Position Eliminated '||l_proc,62);
            hr_utility.set_message(8302,'PQH_POS_ELIMINATED');
            hr_utility.set_message_token('POSITION',l_position_name);
         end if;
      end if;
   end if;
   return l_error_cd;
end check_user_pos_details;

function check_user_asg_details(p_value_date        in date,
                                p_person_id         in number) return number is
   l_error_cd   number := 0 ;
   l_assignment_id number;
   l_position_id number;
   l_user_name  fnd_user.user_name%type := fnd_profile.value('USERNAME');
   l_person_name varchar2(240);
   l_proc       varchar2(256) := g_package||'check_user_asg_details';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('Value date is '||to_char(p_value_date,'dd/MM/RRRR')||l_proc,22);
   l_person_name := hr_general.decode_person_name(p_person_id =>p_person_id);
   get_primary_asg_details(p_person_id      => p_person_id,
                           p_effective_date => p_value_date,
                           p_assignment_id  => l_assignment_id,
                           p_position_id    => l_position_id);
   if l_assignment_id is null then
      l_error_cd := 2;
      hr_utility.set_location('primary assignment not found '||l_proc,50);
      hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
      hr_utility.set_message_token('PERSON',l_person_name);
   else
      hr_utility.set_location('details found '||l_proc,52);
   end if;
   hr_utility.set_location('Exiting '||l_proc,200);
   return l_error_cd;
end check_user_asg_details ;

function check_user_role_details(p_role_id in number,
                                 p_user_id in number,
                                 p_session_date in date) return number is
   cursor c1 is select role_name from pqh_roles
                where role_id = p_role_id
                and nvl(enable_flag,'X') = 'Y';
   cursor c3 is select 'X'
          from per_people_extra_info pei , per_all_people_f ppf, fnd_user usr
          WHERE information_type = 'PQH_ROLE_USERS' and pei.person_id = ppf.person_id
          and p_session_date between ppf.effective_start_date and ppf.effective_end_date
          and usr.employee_id = ppf.person_id
          and decode(information_type, 'PQH_ROLE_USERS', to_number(pei.pei_information3), 0)= p_role_id
          and nvl(pei.pei_information5,'Y')='Y'
          and usr.user_id = p_user_id ;
   l_error_cd number := 0;
   l_role_name pqh_roles.role_name%type;
   l_dummy varchar2(30);
   l_proc       varchar2(256) := g_package||'check_user_role_details';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   open c1;
   fetch c1 into l_role_name;
   if c1%found then
      hr_utility.set_location('role exists '||l_proc,20);
      close c1;
      -- check role is assigned to user
      open c3;
      fetch c3 into l_dummy;
      if c3%notfound then
         hr_utility.set_location('role-user combination does not exist'||l_proc,50);
         l_error_cd := 20;
         hr_utility.set_message(8302,'PQH_ROLE_NOT_ATCHD_TO_USER');
         hr_utility.set_message_token('ROLE',l_role_name);
      end if;
      close c3;
   else
      hr_utility.set_location('role does not exist '||l_proc,60);
      close c1;
      -- role is a disabled role
      l_error_cd := 1;
      hr_utility.set_message(8302,'PQH_INVALID_ROLE');
   end if;
   hr_utility.set_location('error_cd is '||l_error_cd||l_proc,70);
   hr_utility.set_location('exiting'||l_proc,100);
   return l_error_cd;
end check_user_role_details;

function routing_role(p_member_id          in number,
                      p_routing_history_id in number,
                      p_user_id            in number) return number is
   l_role_id	number;
   l_role_name	varchar2(300);
   l_dummy		varchar2(10);
cursor c_rlm(p_routing_history_id number) is
         select role_id
         from pqh_routing_history rht, pqh_routing_list_members rlm
         where rht.forwarded_to_member_id = rlm.routing_list_member_id
         and rht.routing_history_id = p_routing_history_id;
cursor c_role_users(p_user_id number, p_role_id number) is
         select 'X'
         from per_people_extra_info pei , per_all_people_f ppf, fnd_user usr
         WHERE information_type = 'PQH_ROLE_USERS' and pei.person_id = ppf.person_id
         and sysdate between ppf.effective_start_date and ppf.effective_end_date
         and usr.employee_id = ppf.person_id
         and decode(information_type, 'PQH_ROLE_USERS', to_number(pei.pei_information3), 0)= p_role_id
         and nvl(pei.pei_information5,'Y')='Y'
         and usr.user_id = p_user_id ;

begin
   open c_rlm(p_routing_history_id);
   fetch c_rlm into l_role_id;
   if c_rlm%notfound then
      close c_rlm;
      hr_utility.set_message(8302,'PQH_MEMBER_NOTIN_RL');
      l_role_id := -1;
   else
      close c_rlm;
      open c_role_users(p_user_id, l_role_id);
      fetch c_role_users INTO l_dummy;
      if c_role_users%notfound then
         close c_role_users;
         l_role_name := get_role_name(l_role_id);
         hr_utility.set_message(8302,'PQH_ROLE_NOT_ATCHD_TO_USER');
         hr_utility.set_message_token('ROLE',l_role_name);
      else
         close c_role_users;
      end if;
   end if;
   return(l_role_id);
end routing_role;

function get_routinghistory_role(p_routing_history_id in number,
                                 p_user_id            in number,
                                 p_user_name          in varchar2) return number IS
   l_role_id	number := -1;
   l_role_name	varchar2(300);
   l_position_id	number;
   l_person_id  number;
   l_position_name varchar2(240);
   l_rht_member_id     number;
   l_rht_position_id   number;
   l_rht_assignment_id number;
cursor c_person_details is
       select employee_id from fnd_user
       where user_id = p_user_id;
cursor c_position_role(p_position_id number) is
       SELECT decode(information_type, 'PQH_POS_ROLE_ID' , to_number(poei_information3), -1) ROLE_ID
       from per_position_extra_info pei
       WHERE pei.position_id=p_position_id
       and pei.information_type='PQH_POS_ROLE_ID';

cursor c_asg_details(p_assignment_id number,l_person_id number) is
         select position_id
         from per_all_assignments_f
         where assignment_id = p_assignment_id
         and person_id = l_person_id
         and primary_flag = 'Y'
         and sysdate between effective_start_date and effective_end_date;

cursor c_person_role(p_person_id number) is
         select decode(information_type, 'PQH_ROLE_USERS', to_number(pei.pei_information3), 0) role_id
         from per_people_extra_info pei , per_all_people_f ppf
         WHERE information_type = 'PQH_ROLE_USERS' and pei.person_id = ppf.person_id
         and sysdate between ppf.effective_start_date and ppf.effective_end_date
         and ppf.person_id = p_person_id
         and nvl(pei.pei_information5,'Y')='Y'
         and nvl(pei.pei_information4,'N')='Y';
   l_user_name  fnd_user.user_name%type := fnd_profile.value('USERNAME');
   l_person_name varchar2(240);
   l_proc varchar2(71) := g_package||'get_routinghist_role' ;
BEGIN
   hr_utility.set_location('entering'||l_proc,10);
   if nvl(p_routing_history_id,-1) >0 then
      open c_person_details;
      fetch c_person_details into l_person_id;
      close c_person_details;
      l_person_name := hr_general.decode_person_name(p_person_id =>l_person_id);
      hr_utility.set_location('person_id is'||l_person_id||l_proc,20);
      hr_utility.set_location('person_name is'||l_person_name||l_proc,21);
      select forwarded_to_member_id, forwarded_to_position_id,forwarded_to_assignment_id
      into l_rht_member_id,l_rht_position_id,l_rht_assignment_id
      from pqh_routing_history
      where routing_history_id = p_routing_history_id;
      hr_utility.set_location('rout_hist details pulled'||l_proc,30);
      if l_rht_member_id is not null then
         hr_utility.set_location('member role to be pulled'||l_proc,40);
         l_role_id := routing_role(p_routing_history_id => p_routing_history_id,
                                   p_member_id          => l_rht_member_id,
                                   p_user_id            => p_user_id);
         hr_utility.set_location('member role is'||l_role_id||l_proc,50);
      end if;
      if (l_rht_assignment_id is not null) then
         hr_utility.set_location('assignment details '||l_proc,60);
         open c_asg_details(l_rht_assignment_id,l_person_id);
         fetch c_asg_details into l_position_id;
         if c_asg_details%notfound then
            close c_asg_details;
            hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
            hr_utility.set_message_token('PERSON',l_person_name);
         else
            close c_asg_details;
            hr_utility.set_location('assignment details found'||l_proc,70);
            if l_position_id is not null then
               hr_utility.set_location('position assignment '||l_proc,80);
               open c_position_role(l_position_id);
               fetch c_position_role into l_role_id;
               if c_position_role%notfound then
                  hr_utility.set_location('position role notfound '||l_proc,90);
                  close c_position_role;
                  l_position_name := hr_general.decode_position_latest_name(l_position_id);
                  hr_utility.set_message(8302,'PQH_NO_ACTIVE_ROLE_FOR_POS');
                  hr_utility.set_message_token('POSITION',l_position_name);
                  hr_utility.set_message_token('PERSON',l_person_name);
               else
                  hr_utility.set_location('position role is '||l_role_id||l_proc,100);
                  close c_position_role;
               end if;
            else
               hr_utility.set_location('other assignment '||l_proc,120);
               open c_person_role(l_person_id);
               fetch c_person_role into l_role_id;
               if c_person_role%notfound then
                  hr_utility.set_location('person role notfound '||l_proc,130);
                  close c_person_role;
                  hr_utility.set_message(8302,'PQH_NO_DEFAULT_ROLE');
                  hr_utility.set_message_token('USERNAME',p_user_name);
               else
                  hr_utility.set_location('person role is '||l_role_id||l_proc,140);
                  close c_person_role;
               end if;
            end if;
         end if;
      elsif l_rht_position_id is not null then
         hr_utility.set_location('position role '||l_proc,150);
         open c_position_role(l_rht_position_id);
         fetch c_position_role into l_role_id;
         if c_position_role%notfound then
            hr_utility.set_location('position role notfound'||l_proc,160);
            close c_position_role;
            l_position_name := hr_general.decode_position_latest_name(l_rht_position_id);
            hr_utility.set_message(8302,'PQH_NO_ACTIVE_ROLE_FOR_POS');
            hr_utility.set_message_token('POSITION',l_position_name);
            hr_utility.set_message_token('PERSON',l_person_name);
         else
            hr_utility.set_location('position role is'||l_role_id||l_proc,170);
            close c_position_role;
         end if;
      end if;
   end if;
   hr_utility.set_location('exiting'||l_proc,200);
   return l_role_id;
end get_routinghistory_role;

function get_txn_cat( p_short_name        in varchar2,
                      p_business_group_id in number default null) return number IS
   l_local_txncat_id number;
   l_global_txncat_id number;
   l_txncat_id number;
   l_proc varchar2(71) := g_package||'get_txn_cat' ;
BEGIN
   hr_utility.set_location('entering'||l_proc,10);
   hr_utility.set_location('short_name'||p_short_name,12);
   hr_utility.set_location('business_group_id'||p_business_group_id,13);
-- only local transaction category can be disabled
   select transaction_category_id
   into l_local_txncat_id
   from pqh_transaction_categories
   where business_group_id = nvl(p_business_group_id,-1)
   and short_name = p_short_name
   and nvl(enable_flag,'Y') = 'Y';
   hr_utility.set_location('local tcat is'||l_local_txncat_id||l_proc,15);
   hr_utility.set_location('exiting'||l_proc,10);
   return l_local_txncat_id ;
exception
   when no_data_found then
      begin
         hr_utility.set_location('bg tcat does not exist'||l_proc,20);
         select transaction_category_id
         into l_global_txncat_id
         from pqh_transaction_categories
         where business_group_id is null
         and short_name = p_short_name;
         hr_utility.set_location('global tcat is'||l_global_txncat_id||l_proc,30);
         return l_global_txncat_id ;
      exception
         when no_data_found then
            hr_utility.set_location('tcat does not exist'||l_proc,30);
            hr_utility.set_message(8302,'PQH_INVALID_TXN_CAT_ID');
            hr_utility.set_message_token('TRANSACTION',p_short_name);
            hr_utility.raise_error;
      end;
END;

procedure list_rout_crit is
   i number;
begin
   i := g_routing_criterion.first;
   if i is not null then
      loop
         -- hr_utility.set_location('rec# is'||i||', att_id is'||g_routing_criterion(i).attribute_id,20);
         -- hr_utility.set_location('used for is'||g_routing_criterion(i).used_for,40);
         -- hr_utility.set_location('Attribute_type is'||g_routing_criterion(i).attribute_type,30);
         -- hr_utility.set_location('Range_name is'||g_routing_criterion(i).rule_name,30);
         -- hr_utility.set_location('value_num is'||g_routing_criterion(i).value_num,50);
         hr_utility.set_location('from_num is'||g_routing_criterion(i).from_num||'-'||g_routing_criterion(i).to_num,60);
         --hr_utility.set_location('value_num is'||g_routing_criterion(i).value_num,50);
         --hr_utility.set_location('from_num is'||g_routing_criterion(i).from_num||'-'||g_routing_criterion(i).to_num,60);
         exit when i= g_routing_criterion.last;
         i := g_routing_criterion.next(i);
      end loop;
   end if;
end list_rout_crit;
procedure insert_rout_crit(p_attribute_id   in number,
                           p_used_for       in varchar default null,
                           p_rule_name      in varchar default null,
                           p_attribute_type in varchar default null,
                           p_from_char      in varchar default null,
                           p_to_char        in varchar default null,
                           p_from_num       in number  default null,
                           p_to_num         in number  default null,
                           p_from_date      in date    default null,
                           p_to_date        in date    default null,
                           p_value_char     in varchar default null,
                           p_value_num      in number  default null,
                           p_value_date     in date    default null) is
   l_proc varchar2(81) := g_package||'insert_rout_crit';
   i number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   if p_used_for is not null then
      i := nvl(g_routing_criterion.last,0) + 1;
      hr_utility.set_location('Adding attribute_id'||p_attribute_id||l_proc,20);
      hr_utility.set_location('Adding for i'||i||l_proc,30);
      if p_attribute_type ='V' and p_value_char is not null then
         g_routing_criterion(i).attribute_id   := p_attribute_id;
         g_routing_criterion(i).attribute_type := p_attribute_type;
         g_routing_criterion(i).used_for       := p_used_for;
         g_routing_criterion(i).rule_name      := p_rule_name;
         g_routing_criterion(i).from_char      := p_from_char;
         g_routing_criterion(i).to_char        := p_to_char;
         g_routing_criterion(i).value_char     := p_value_char;
      end if;
      if p_attribute_type ='N' and p_value_num is not null then
         g_routing_criterion(i).attribute_id   := p_attribute_id;
         g_routing_criterion(i).attribute_type := p_attribute_type;
         g_routing_criterion(i).used_for       := p_used_for;
         g_routing_criterion(i).rule_name      := p_rule_name;
         g_routing_criterion(i).from_num       := p_from_num;
         g_routing_criterion(i).to_num         := p_to_num;
         g_routing_criterion(i).value_num      := p_value_num;
      end if;
      if p_attribute_type ='D' and p_value_date is not null then
         g_routing_criterion(i).attribute_id   := p_attribute_id;
         g_routing_criterion(i).attribute_type := p_attribute_type;
         g_routing_criterion(i).used_for       := p_used_for;
         g_routing_criterion(i).rule_name      := p_rule_name;
         g_routing_criterion(i).from_date      := p_from_date;
         g_routing_criterion(i).to_date        := p_to_date;
         g_routing_criterion(i).value_date     := p_value_date;
      end if;
   end if;
   hr_utility.set_location('exit'||l_proc,100);
   list_rout_crit;
end insert_rout_crit;
procedure delete_rout_crit(p_used_for in varchar,
                           p_rule_name in varchar) is
   l_proc varchar2(81) := g_package||'delete_rout_crit1';
   i number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   hr_utility.set_location('deleting rout_crit for'||p_used_for||l_proc,10);
   i := g_routing_criterion.first;
   if i is not null then
      loop
         if g_routing_criterion(i).used_for = p_used_for and
            g_routing_criterion(I).rule_name <> p_rule_name then
            g_routing_criterion.delete(i);
            hr_utility.set_location('row deleted'||l_proc,10);
         end if;
         exit when i >= nvl(g_routing_criterion.LAST,0);
         i := g_routing_criterion.NEXT(i);
      end loop;
   end if;
   list_rout_crit;
   hr_utility.set_location('exiting'||l_proc,100);
exception
   when others then
      hr_utility.set_location('error in delete_routing criterion'||l_proc,140);
      null;
end delete_rout_crit;
procedure delete_rout_crit(p_used_for in varchar) is
   l_proc varchar2(81) := g_package||'delete_rout_crit';
   i number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   hr_utility.set_location('deleting rout_crit for'||p_used_for||l_proc,10);
   i := g_routing_criterion.first;
   if i is not null then
      loop
         if g_routing_criterion(i).used_for = p_used_for then
            g_routing_criterion.delete(i);
            hr_utility.set_location('row deleted'||l_proc,10);
         end if;
         exit when i >= nvl(g_routing_criterion.LAST,0);
         i := g_routing_criterion.NEXT(i);
      end loop;
   end if;
   list_rout_crit;
   hr_utility.set_location('exiting'||l_proc,100);
exception
   when others then
      hr_utility.set_location('error in delete_routing criterion'||l_proc,140);
      null;
end delete_rout_crit;
procedure get_role_user(p_member_id in number,
                        p_role_id      out nocopy number,
                        p_user_id      out nocopy number ) is
   cursor c1 is select role_id,user_id
                from pqh_routing_list_members
                where routing_list_member_id = p_member_id ;
begin
   open c1;
   fetch c1 into p_role_id,p_user_id;
   if c1%notfound then
      close c1;
      hr_utility.set_message(8302,'PQH_MEMBER_NOTIN_RL');
      hr_utility.raise_error;
   end if;
   close c1;
exception when others then
p_role_id := null;
p_user_id := null;
raise;
end;

function override_approver(p_routing_category_id in number,
                           p_member_cd           in varchar2,
                           p_role_id             in number default null,
                           p_user_id             in number default null,
                           p_position_id         in number default null,
                           p_assignment_id       in number default null
                           ) return boolean is
   cursor c1 is select override_role_id,override_user_id,override_position_id,override_assignment_id
                from pqh_routing_categories
                where routing_category_id = p_routing_category_id
                and nvl(enable_flag,'X') = 'Y'
                and nvl(delete_flag,'N') = 'N';
  l_proc       varchar2(256) := g_package||'override_approver';
  l_result     boolean ;
  l_role_user_id number;
begin
   hr_utility.set_location('Entering for rc'||p_routing_category_id||l_proc,10);
   for i in c1 loop
       if p_member_cd ='R' then
          if p_role_id = i.override_role_id then
             hr_utility.set_location('RL and role=override_role '||l_proc,20);
             if i.override_user_id is null then
                hr_utility.set_location('override approver was role alone '||l_proc,22);
                l_result := TRUE;
             else
                if i.override_user_id = p_user_id then
                   hr_utility.set_location('user=override_user '||l_proc,24);
                   l_result := TRUE;
                else
                   hr_utility.set_location('user<>override_user '||l_proc,26);
                end if;
             end if;
          else
             hr_utility.set_location('RL and role does not match '||l_proc,27);
          end if;
       elsif p_member_cd ='P' and p_position_id = i.override_position_id then
          hr_utility.set_location('PS and position=override_position '||l_proc,30);
          l_result := TRUE;
       elsif p_member_cd ='S' and p_assignment_id = i.override_assignment_id then
          hr_utility.set_location('Sup and assignment=override_assignment '||l_proc,40);
          l_result := TRUE;
       end if;
       if l_result is null then
          hr_utility.set_location('no match of override '||l_proc,50);
          l_result := FALSE;
       end if;
   end loop;
   hr_utility.set_location('Exiting '||l_proc,100);
   return l_result;
end override_approver;

procedure old_approver_valid(p_transaction_category_id in number,
                             p_transaction_id          in number,
                             p_transaction_status      in varchar2,
                             p_old_approver_valid      out nocopy varchar2 ) is
   l_max_routing_history_id number(15);
   l_routing_category_id    number(15);
   l_rh_routing_category_id number(15);
   l_position_id            number(15);
   l_assignment_id          number(15);
   l_user_id                number(15);
   l_role_id                number(15);
   l_role_name              varchar2(200);
   l_user_name              varchar2(200);
   l_member_id              number(15);
   l_member_cd              varchar2(30);
   l_member_flag            boolean     ;
   l_routing_list_id        number(15);
   l_pos_str_id             number(15);
   l_from_clause            varchar2(2000);
   l_applicable_flag        boolean;
   l_status_flag            number;
   l_error_flag             boolean := FALSE;
   l_can_approve            boolean;
   l_override_approver      boolean;
   l_value_date             date := sysdate;
   l_setup                  varchar2(30);
   l_range_name             varchar2(100);
   l_proc                   varchar2(256) := g_package||'old_approver_valid' ;
   cursor c1 is select forwarded_by_position_id,forwarded_by_assignment_id,forwarded_by_user_id,forwarded_by_role_id,
                       forwarded_by_member_id,routing_category_id
                from pqh_routing_history
                where routing_history_id = l_max_routing_history_id;
   cursor c2 is select rlm.role_id
                from pqh_routing_categories rc,pqh_routing_list_members rlm
                where rc.routing_category_id = l_rh_routing_category_id
                and rc.routing_list_id = rlm.routing_list_id
                and rlm.routing_list_member_id = l_member_id
                and nvl(rc.enable_flag,'X') = 'Y'
                and nvl(rlm.enable_flag,'X') = 'Y'
                and nvl(rc.delete_flag,'X') <> 'Y';
begin
  p_old_approver_valid := 'N' ;
  if p_transaction_id is null then
     hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
     hr_utility.raise_error;
  elsif p_transaction_category_id is null then
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  elsif p_transaction_status <> 'APPROVED' then
     l_error_flag := TRUE;
  end if;
  if l_error_flag = FALSE then
     begin
        select max(routing_history_id)
        into l_max_routing_history_id
        from pqh_routing_history
        where transaction_category_id = p_transaction_category_id
        and transaction_id = p_transaction_id
        and approval_cd ='APPROVED' ;
        hr_utility.set_location('max RH id is '||l_max_routing_history_id||l_proc,10);
        if nvl(l_max_routing_history_id,0) >0 then
           open c1;
           fetch c1 into l_position_id,l_assignment_id,l_user_id,l_role_id,l_member_id,l_rh_routing_category_id;
           if c1 %notfound then
              hr_utility.set_location('error in getting routing history'||l_proc,20);
              close c1;
              l_status_flag := 1;
              hr_utility.set_message(8302,'PQH_RH_FETCH_FAILED');
              hr_utility.raise_error;
           else
              close c1;
              hr_utility.set_location('routing history details pulled'||l_proc,25);
              l_status_flag := 0;
           end if;
        else
           hr_utility.set_location('routing history does not exist'||l_proc,27);
           l_status_flag := 11;
        end if;
     end;
     if l_status_flag = 0 then
        prepare_from_clause(p_tran_cat_id => p_transaction_category_id,
                            p_trans_id    => p_transaction_id,
                            p_from_clause => l_from_clause);
        if l_from_clause is null then
           hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
           hr_utility.raise_error;
           hr_utility.set_location('From_clause not there '||l_proc,30);
        else
           l_setup := tran_setup(p_transaction_category_id);
           hr_utility.set_location('tran_cat setup is '||l_setup||l_proc,66);
           if nvl(l_setup,'XYZ') = 'STANDARD' then
              list_range_check(p_tran_cat_id         => p_transaction_category_id,
                               p_member_cd           => l_member_cd,
                               p_used_for            => 'O',
                               p_routing_list_id     => l_routing_list_id,
                               p_pos_str_id          => l_pos_str_id,
                               p_routing_category_id => l_routing_category_id,
                               p_status_flag         => l_status_flag);
           elsif nvl(l_setup,'XYZ') = 'ADVANCED' then
              hr_utility.set_location('From_clause selected '||l_proc,40);
              list_range_check(p_tran_cat_id         => p_transaction_category_id,
                               p_trans_id            => p_transaction_id,
                               p_from_clause         => l_from_clause,
                               p_used_for            => 'O',
                               p_member_cd           => l_member_cd,
                               p_routing_list_id     => l_routing_list_id,
                               p_pos_str_id          => l_pos_str_id,
                               p_routing_category_id => l_routing_category_id,
                               p_range_name          => l_range_name,
                               p_status_flag         => l_status_flag);
           else
              l_status_flag := 10;
           end if;
	   if l_status_flag = 0 then
	      hr_utility.set_location('CATg selected'||to_char(l_routing_category_id)||l_range_name||l_proc,50);
              if l_routing_category_id <> l_rh_routing_category_id then
	         hr_utility.set_location('selected routing catg was used for approval'||l_proc,52);
              else
	         hr_utility.set_location('catg change has happened'||l_proc,54);
	         hr_utility.set_location('catg used for approval'||l_rh_routing_category_id||l_proc,56);
              end if;
	   else
	      hr_utility.set_location('errors in selecting routing_category'||l_proc,60);
	   end if;
        end if;
     end if;
     if l_status_flag = 0 then
        if l_member_cd = 'R' then
           hr_utility.set_location('Routing category is RL '||l_proc,70);
           -- check wether this role-user combination exist in the selected routing list
           rlm_user_seq(p_routing_list_id => l_routing_list_id,
                        p_role_id         => l_role_id,
                        p_role_name       => l_role_name,
                        p_user_id         => l_user_id,
                        p_user_name       => l_user_name,
                        p_member_id       => l_member_id,
                        p_member_flag     => l_member_flag);
           if l_member_flag = TRUE then
              hr_utility.set_location('got member for the new RL'||l_member_id||l_proc,100);
              rl_member_applicable(p_tran_cat_id         => p_transaction_category_id,
                                   p_from_clause         => l_from_clause,
                                   p_member_id           => l_member_id  ,
                                   p_routing_category_id => l_routing_category_id,
                                   p_applicable_flag     => l_applicable_flag,
                                   p_status_flag         => l_status_flag,
                                   p_can_approve         => l_can_approve );
           else
              hr_utility.set_location('current user not RL member '||l_proc,100);
              hr_utility.set_location('checking override approver '||l_proc,102);
              l_override_approver := override_approver(p_member_cd           => l_member_cd,
                                                       p_routing_category_id => l_routing_category_id,
                                                       p_assignment_id       => l_assignment_id,
                                                       p_role_id             => l_role_id,
                                                       p_user_id             => l_user_id,
                                                       p_position_id         => l_position_id);
              if l_override_approver then
                 l_can_approve := TRUE;
                 hr_utility.set_location('member is defined as override approver '||l_proc,129);
              else
                 l_can_approve := FALSE;
                 l_status_flag := 11;
                 hr_utility.set_location('member is not defined as override approver '||l_proc,129);
              end if;
           end if;
        elsif l_member_cd ='P' then
           hr_utility.set_location('Routing category is PS '||l_proc,110);
           ps_element_applicable(p_tran_cat_id         => p_transaction_category_id,
                                 p_from_clause         => l_from_clause,
                                 p_position_id         => l_position_id,
                                 p_routing_category_id => l_routing_category_id,
                                 p_value_date          => l_value_date,
                                 p_applicable_flag     => l_applicable_flag,
                                 p_status_flag         => l_status_flag,
                                 p_can_approve         => l_can_approve );
        elsif l_member_cd ='S' then
           hr_utility.set_location('Routing category is SH '||l_proc,120);
           assignment_applicable(p_tran_cat_id         => p_transaction_category_id,
                                 p_from_clause         => l_from_clause,
                                 p_assignment_id       => l_assignment_id,
                                 p_routing_category_id => l_routing_category_id,
                                 p_value_date          => l_value_date,
                                 p_applicable_flag     => l_applicable_flag,
                                 p_status_flag         => l_status_flag,
                                 p_can_approve         => l_can_approve );
        else
           hr_utility.set_location('invalid member_cd '||l_proc,130);
        end if;
        if l_status_flag = 0 then
           if l_can_approve = TRUE then
              p_old_approver_valid := 'Y' ;
              hr_utility.set_location('old approver remains a valid approver'||l_proc,132);
           else
              p_old_approver_valid := 'N' ;
              hr_utility.set_location('old approver no longer approver'||l_proc,134);
           end if;
        else
           hr_utility.set_location('applicable check failed '||l_proc,140);
        end if;
     else
        hr_utility.set_location('routing category fetch failed '||l_proc,160);
        if l_status_flag = 11 then
           hr_utility.set_location('there is no routing history '||l_proc,160);
           p_old_approver_valid := 'Y' ;
        end if;
     end if;
  else
     hr_utility.set_location('transaction is not already approved '||l_proc,170);
  end if;
  hr_utility.set_location('exiting '||l_proc,200);
exception when others then
p_old_approver_valid := null;
raise;
end old_approver_valid;
procedure next_applicable(p_member_cd           in pqh_transaction_categories.member_cd%type,
			  p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                          p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
			  p_trans_id            in pqh_routing_history.transaction_id%type,
			  p_cur_assignment_id   in per_all_assignments_f.assignment_id%type,
			  p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
			  p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
			  p_cur_position_id     in pqh_position_transactions.position_id%type,
			  p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
			  p_next_position_id       out nocopy pqh_position_transactions.position_id%type,
			  p_next_member_id         out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_next_role_id           out nocopy number,
                          p_next_user_id           out nocopy number,
			  p_next_assignment_id     out nocopy per_all_assignments_f.assignment_id%type,
			  p_status_flag            out nocopy number)
is
  l_applicable_flag boolean       := FALSE;
  l_proc            varchar2(256) := g_package||'next_applicable' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_member_cd is null then
      hr_utility.set_message(8302,'PQH_MEMBER_CD_REQD');
      hr_utility.raise_error;
  elsif p_member_cd ='R' and p_routing_list_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_LIST_REQD');
      hr_utility.raise_error;
  elsif p_member_cd ='R' and p_cur_member_id is null then
      hr_utility.set_message(8302,'PQH_CURRENT_MEMBER_REQD');
      hr_utility.raise_error;
  elsif p_member_cd ='P' and p_cur_position_id is null then
      hr_utility.set_message(8302,'PQH_CUR_POS_REQD');
      hr_utility.raise_error;
  elsif p_member_cd ='S' and p_cur_assignment_id is null then
      hr_utility.set_message(8302,'PQH_CUR_ASG_REQD');
      hr_utility.raise_error;
  elsif p_member_cd ='P' and p_pos_str_ver_id is null then
      hr_utility.set_message(8302,'PQH_POS_STR_VER_REQD');
      hr_utility.raise_error;
  elsif p_routing_category_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_CATEGORY_REQD');
      hr_utility.raise_error;
  elsif p_tran_cat_id is null then
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
  elsif p_trans_id is null then
      hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
      hr_utility.raise_error;
  end if;
  hr_utility.set_location('transaction_id is '||p_trans_id||l_proc,51);
  hr_utility.set_location('trans_cat_id is '||p_tran_cat_id||l_proc,52);
  if p_member_cd = 'R' then
     hr_utility.set_location('calling next_member '||l_proc,20);
     next_applicable_member(p_routing_category_id => p_routing_category_id,
                            p_tran_cat_id         => p_tran_cat_id,
                            p_trans_id            => p_trans_id,
                            p_cur_member_id       => p_cur_member_id,
                            p_routing_list_id     => p_routing_list_id,
                            p_used_for            => 'N',
                            p_member_id           => p_next_member_id,
                            p_role_id             => p_next_role_id,
                            p_user_id             => p_next_user_id,
                            p_status_flag         => p_status_flag,
                            p_applicable_flag     => l_applicable_flag);
  elsif p_member_cd ='S' then
     hr_utility.set_location('calling next_assignment '||l_proc,30);
     next_applicable_assignment(p_routing_category_id => p_routing_category_id,
                                p_tran_cat_id         => p_tran_cat_id,
                                p_trans_id            => p_trans_id,
                                p_cur_assignment_id   => p_cur_assignment_id,
                                p_assignment_id       => p_next_assignment_id,
                                p_used_for            => 'N',
                                p_status_flag         => p_status_flag,
                                p_applicable_flag     => l_applicable_flag);
  elsif p_member_cd ='P' then
     hr_utility.set_location('calling next_position '||l_proc,40);
     next_applicable_position(p_routing_category_id => p_routing_category_id,
                              p_tran_cat_id         => p_tran_cat_id,
                              p_trans_id            => p_trans_id,
                              p_cur_position_id     => p_cur_position_id,
                              p_used_for            => 'N',
                              p_pos_str_ver_id      => p_pos_str_ver_id,
                              p_position_id         => p_next_position_id,
                              p_status_flag         => p_status_flag,
                              p_applicable_flag     => l_applicable_flag);
  else
     hr_utility.set_message(8302,'PQH_INVALID_MEMBER_CD');
     hr_utility.raise_error;
  end if;
  list_rout_crit;
  hr_utility.set_location('exiting '||l_proc,10000);
exception when others then
p_next_position_id       := null;
p_next_member_id         := null;
p_next_role_id           := null;
p_next_user_id           := null;
p_next_assignment_id     := null;
p_status_flag            := null;
raise;
end next_applicable;
procedure next_applicable_assignment(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                     p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				     p_trans_id            in pqh_routing_history.transaction_id%type,
				     p_cur_assignment_id   in per_all_assignments_f.assignment_id%type,
                                     p_used_for            in varchar2,
				     p_assignment_id          out nocopy per_all_assignments_f.assignment_id%type,
				     p_status_flag            out nocopy number,
				     p_applicable_flag        out nocopy boolean)
is
 l_value_date          date                := trunc(sysdate);
 l_from_clause         varchar2(2000) ;
 l_can_approve         boolean             := FALSE;
 l_cur_assignment_id   per_all_assignments_f.assignment_id%type;
 l_proc                varchar2(256)       := g_package||'next_applicable_assignment' ;
begin
   p_applicable_flag := FALSE;
   p_status_flag := 0;
   l_cur_assignment_id := p_cur_assignment_id;
   hr_utility.set_location('entering '||l_proc,10);
   if p_routing_category_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_CATEGORY_REQD');
      hr_utility.raise_error;
   elsif p_trans_id is null then
      hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
      hr_utility.raise_error;
   elsif p_tran_cat_id is null then
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_cur_assignment_id is null then
      hr_utility.set_message(8302,'PQH_CUR_ASG_REQD');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location('reqd data there '||l_proc,20);
   l_cur_assignment_id := p_cur_assignment_id;
   p_status_flag := 0;
   prepare_from_clause(p_tran_cat_id => p_tran_cat_id,
                       p_trans_id    => p_trans_id,
                       p_from_clause => l_from_clause);
   if l_from_clause is null then
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   else
      hr_utility.set_location('from clause selected '||l_proc,30);
      while p_status_flag = 0 and p_applicable_flag = FALSE loop
         su_next_user(p_cur_assignment_id  => l_cur_assignment_id,
                      p_value_date         => l_value_date,
                      p_assignment_id      => p_assignment_id,
                      p_status_flag        => p_status_flag) ;
         if p_status_flag = 0 then
            hr_utility.set_location('next assignment found check appli'||to_char(p_assignment_id)||l_proc,40);
            assignment_applicable(p_tran_cat_id         => p_tran_cat_id,
                                  p_from_clause         => l_from_clause,
                                  p_assignment_id       => p_assignment_id,
                                  p_routing_category_id => p_routing_category_id,
                                  p_used_for            => p_used_for,
                                  p_value_date          => l_value_date,
                                  p_applicable_flag     => p_applicable_flag,
                                  p_status_flag         => p_status_flag,
                                  p_can_approve         => l_can_approve );
            if p_applicable_flag = FALSE then
               hr_utility.set_location('next assignment unapplicable '||to_char(p_assignment_id)||l_proc,50);
               l_cur_assignment_id := p_assignment_id;
            else
               hr_utility.set_location('assignment applicable '||to_char(p_assignment_id)||l_proc,60);
            end if;
         else
            hr_utility.set_location('error getting next_assignment '||to_char(p_status_flag)||l_proc,70);
         end if;
      end loop;
   end if;
   hr_utility.set_location('exiting '||l_proc,10000);
exception when others then
p_assignment_id          := null;
p_status_flag            := null;
p_applicable_flag        := null;

raise;
end next_applicable_assignment;

procedure next_applicable_member(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                 p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				 p_trans_id            in pqh_routing_history.transaction_id%type,
				 p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
				 p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
                                 p_used_for            in varchar2,
				 p_member_id              out nocopy pqh_routing_list_members.routing_list_member_id%type,
                                 p_role_id                out nocopy number,
                                 p_user_id                out nocopy number,
				 p_status_flag            out nocopy number,
				 p_applicable_flag        out nocopy boolean)
is
 l_value_date      date                := trunc(sysdate);
 l_from_clause     varchar2(2000) ;
 l_can_approve     boolean             := FALSE;
 l_error_flag      boolean             := FALSE;
 l_member_role_id  pqh_roles.role_id%type;
 l_member_user_id  fnd_user.user_id%type;
 l_cur_member_id   number;
 l_proc            varchar2(256)       := g_package||'next_applicable_member' ;
begin
   p_applicable_flag := FALSE;
   p_status_flag := 0;
   hr_utility.set_location('entering '||l_proc,10);
   if p_routing_category_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_CATEGORY_REQD');
      hr_utility.raise_error;
   elsif p_trans_id is null then
      hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
      hr_utility.raise_error;
   elsif p_tran_cat_id is null then
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_cur_member_id   is null then
      hr_utility.set_message(8302,'PQH_CURRENT_MEMBER_REQD');
      hr_utility.raise_error;
   elsif p_routing_list_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_LIST_REQD');
      hr_utility.raise_error;
   else
      l_error_flag := FALSE;
   end if;
   if l_error_flag = FALSE then
      hr_utility.set_location('reqd data there '||l_proc,20);
      p_status_flag := 0;
      prepare_from_clause(p_tran_cat_id => p_tran_cat_id,
                          p_trans_id    => p_trans_id,
                          p_from_clause => l_from_clause);
      if l_from_clause is null then
         hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
         hr_utility.raise_error;
      else
         hr_utility.set_location('from clause selected '||l_proc,30);
         l_cur_member_id := p_cur_member_id;
	 while p_status_flag = 0 and p_applicable_flag = FALSE loop
            rl_next_user(p_routing_list_id => p_routing_list_id,
	    	         p_cur_member_id   => l_cur_member_id,
                         p_member_id       => p_member_id,
                         p_role_id         => p_role_id,
                         p_user_id         => p_user_id,
                         p_status_flag     => p_status_flag);
	    if p_status_flag = 0 then
               hr_utility.set_location('next member found check appli'||to_char(p_member_id)||l_proc,40);
               rl_member_applicable(p_tran_cat_id         => p_tran_cat_id,
                                    p_from_clause         => l_from_clause,
                                    p_member_id           => p_member_id  ,
                                    p_routing_category_id => p_routing_category_id,
                                    p_used_for            => p_used_for,
                                    p_applicable_flag     => p_applicable_flag,
                                    p_status_flag         => p_status_flag,
                                    p_can_approve         => l_can_approve );
	       if p_applicable_flag = FALSE then
                  hr_utility.set_location('next member unapplicable '||to_char(p_member_id)||l_proc,50);
		  l_cur_member_id := p_member_id  ;
	       else
                  hr_utility.set_location('member applicable '||to_char(p_member_id  )||l_proc,60);
	       end if;
            elsif p_status_flag = 1 then
               hr_utility.set_location('last_member, status returned:'||to_char(p_status_flag)||l_proc,70);
            else
               hr_utility.set_location('error getting next_member '||to_char(p_status_flag)||l_proc,70);
	    end if;
	 end loop;
      end if;
   else
      hr_utility.set_location('mandatory data missing'||l_proc,80);
      hr_utility.set_message(8302,'PQH_MANDATORY_DATA_MISS');
   end if;
   hr_utility.set_location('exiting '||l_proc,10000);
   exception when others then
p_member_id              := null;
p_role_id                := null;
p_user_id                := null;
p_status_flag            := null;
p_applicable_flag        := null;
raise;
end next_applicable_member;

procedure next_applicable_position(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                   p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				   p_trans_id            in pqh_routing_history.transaction_id%type,
				   p_cur_position_id     in pqh_position_transactions.position_id%type,
				   p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
                                   p_used_for            in varchar2,
				   p_position_id            out nocopy pqh_position_transactions.position_id%type,
				   p_status_flag            out nocopy number,
				   p_applicable_flag        out nocopy boolean)
is
 l_value_date      date                := trunc(sysdate);
 l_from_clause     varchar2(2000) ;
 l_can_approve     boolean             := FALSE;
 l_error_flag      boolean             := FALSE;
 l_pos_str_id      pqh_routing_categories.position_structure_id%type;
 l_cur_position_id pqh_position_transactions.position_id%type;
 l_proc            varchar2(256)       := g_package||'next_applicable_position' ;
begin
   p_applicable_flag := FALSE;
   p_status_flag := 0;
   l_cur_position_id := p_cur_position_id;
   hr_utility.set_location('entering '||l_proc,10);
   if p_routing_category_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_CATEGORY_REQD');
      hr_utility.raise_error;
   elsif p_trans_id is null then
      hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
      hr_utility.raise_error;
   elsif p_tran_cat_id is null then
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_cur_position_id is null then
      hr_utility.set_message(8302,'PQH_CUR_POS_REQD');
      hr_utility.raise_error;
   elsif p_pos_str_ver_id is null then
      hr_utility.set_message(8302,'PQH_POS_STR_VER_REQD');
      hr_utility.raise_error;
   else
      l_error_flag := FALSE;
   end if;
   if l_error_flag = FALSE then
      hr_utility.set_location('reqd data there '||l_proc,20);
      p_status_flag := 0;
      prepare_from_clause(p_tran_cat_id => p_tran_cat_id,
                          p_trans_id    => p_trans_id,
                          p_from_clause => l_from_clause);
      if l_from_clause is null then
         hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
         hr_utility.raise_error;
      else
         hr_utility.set_location('from clause selected '||l_proc,30);
         /* Changed while loop condition to check for next applicable
            position if eliminated position encountered-Bug#2295241 */
	 while (p_status_flag = 0 or p_status_flag = 8) and p_applicable_flag = FALSE loop
            ph_next_user(p_cur_position_id => l_cur_position_id,
                         p_pos_str_ver_id  => p_pos_str_ver_id,
                         p_position_id     => p_position_id,
                         p_status_flag     => p_status_flag) ;
	    if p_status_flag = 0 then
               hr_utility.set_location('next position found check appli'||to_char(p_position_id)||l_proc,40);
               ps_element_applicable(p_tran_cat_id         => p_tran_cat_id,
                                     p_from_clause         => l_from_clause,
                                     p_position_id         => p_position_id,
                                     p_routing_category_id => p_routing_category_id,
                                     p_value_date          => l_value_date,
                                     p_used_for            => p_used_for,
                                     p_applicable_flag     => p_applicable_flag,
                                     p_status_flag         => p_status_flag,
                                     p_can_approve         => l_can_approve );
	       if p_applicable_flag = FALSE then
                  hr_utility.set_location('next position unapplicable '||to_char(p_position_id)||l_proc,50);
		  l_cur_position_id := p_position_id;
	       else
                  hr_utility.set_location('position applicable '||to_char(p_position_id)||l_proc,60);
	       end if;
            elsif p_status_flag = 8 then
              /* Added for Bug#2295241 */
              hr_utility.set_location('next position is eliminated:'||to_char(p_position_id)||l_proc,65);
              l_cur_position_id := p_position_id;
              /* End Bug#2295241 */
            else
               hr_utility.set_location('error getting next_pos '||to_char(p_status_flag)||l_proc,70);
	    end if;
	 end loop;
      end if;
   else
      hr_utility.set_location('mandatory data missing'||l_proc,80);
      hr_utility.set_message(8302,'PQH_MANDATORY_DATA_MISS');
   end if;
   hr_utility.set_location('exiting '||l_proc,10000);
exception when others then
p_position_id            := null;
p_status_flag            := null;
p_applicable_flag        := null;
raise;
end next_applicable_position;

procedure position_applicable(p_position_id         in pqh_position_transactions.position_id%type,
                              p_pos_str_ver_id      in per_pos_structure_versions.pos_structure_version_id%type,
                              p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                              p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                              p_trans_id            in pqh_position_transactions.position_transaction_id%type,
                              p_status_flag            out nocopy number,
                              p_can_approve            out nocopy boolean,
                              p_applicable_flag        out nocopy boolean)
 as
 l_proc varchar2(256) := g_package||'position_applicable';
 l_from_clause varchar2(2000) ;
 l_value_date date := trunc(sysdate);
begin
  hr_utility.set_location('entering '||l_proc,10);
  prepare_from_clause(p_tran_cat_id => p_tran_cat_id,
                      p_trans_id    => p_trans_id,
                      p_from_clause => l_from_clause);
  ps_element_applicable(p_tran_cat_id         => p_tran_cat_id,
                        p_from_clause         => l_from_clause,
                        p_position_id         => p_position_id,
                        p_routing_category_id => p_routing_category_id,
                        p_value_date          => l_value_date,
                        p_applicable_flag     => p_applicable_flag,
                        p_status_flag         => p_status_flag,
                        p_can_approve         => p_can_approve );
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_status_flag            := null;
p_can_approve            := null;
p_applicable_flag        := null;
raise;
end;

procedure position_occupied(p_position_id     in pqh_position_transactions.position_id%type,
                            p_value_date      in date,
                            p_applicable_flag    out nocopy boolean)
 as
  cursor c1 is select person_id
               from per_all_assignments_f
               where position_id = p_position_id
               and primary_flag = 'Y'
               and p_value_date between effective_start_date and effective_end_date;
  l_person_id     fnd_user.employee_id%type;
  l_proc          varchar2(256) := g_package||'Position_occupied';
  l_error_flag    boolean := FALSE ;
begin
  hr_utility.set_location('Entering '||l_proc,10);
  p_applicable_flag := FALSE;
  if p_position_id is null then
     hr_utility.set_location('Position id reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_POSITION_REQD');
     hr_utility.raise_error;
  elsif p_value_date is null then
     hr_utility.set_location('date reqd'||l_proc,30);
     hr_utility.set_message(8302,'PQH_POS_EFF_DATE_REQD');
     hr_utility.raise_error;
  else
     l_error_flag := FALSE;
  end if;
-- the idea of this procedure is to find out atleast one person occupying the selected position
-- to have a user.
  if l_error_flag = FALSE then
     open c1;
     fetch c1 into l_person_id;
     loop
       if c1%notfound then
          hr_utility.set_location('EOL '||l_proc,40);
          p_applicable_flag := FALSE;
          exit;
       else
          hr_utility.set_location('checking person has user for person '||l_person_id||l_proc,45);
          person_has_user(p_person_id       => l_person_id,
			  p_value_date      => p_value_date,
                          p_applicable_flag => p_applicable_flag );
          if p_applicable_flag = TRUE then
             hr_utility.set_location('Person has user'||l_proc,50);
             exit;
          else
             hr_utility.set_location('Person, no user'||l_proc,60);
             fetch c1 into l_person_id;
          end if;
       end if;
     end loop;
  else
     p_applicable_flag := FALSE;
     hr_utility.set_location('Mandatory data missing '||l_proc,70);
      hr_utility.set_message(8302,'PQH_MANDATORY_DATA_MISS');
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_applicable_flag := null;
raise;
end position_occupied;

procedure person_has_user(p_person_id       in fnd_user.employee_id%type,
			  p_value_date      in date,
                          p_applicable_flag    out nocopy boolean)
 as
 l_user_id fnd_user.user_id%type;
 cursor c1 is select user_id
              from fnd_user
              where employee_id = p_person_id
	      and p_value_date between nvl(start_date,p_value_date)
                                   and nvl(end_date,p_value_date);
 l_proc       varchar2(256) := g_package||'person_has_user';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  p_applicable_flag := FALSE;
  if p_person_id is null then
     hr_utility.set_location('Person id reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_PERSON_ID_REQD');
     hr_utility.raise_error;
  elsif p_value_date is null then
     hr_utility.set_location('Date reqd'||l_proc,30);
     hr_utility.set_message(8302,'PQH_PER_EFF_DATE_REQD');
     hr_utility.raise_error;
  end if;
  open c1;
  fetch c1 into l_user_id;
  if c1%notfound then
     p_applicable_flag := FALSE;
     hr_utility.set_location('No user for person '||to_char(p_person_id)||l_proc,40);
  else
     p_applicable_flag := TRUE;
     hr_utility.set_location('user exists for person '||to_char(p_person_id)||l_proc,50);
  end if;
  close c1;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_applicable_flag := null;
raise;
end person_has_user;

procedure applicable_next_user(p_trans_id              in pqh_routing_history.transaction_id%type,
                               p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
                               p_cur_user_id           in out nocopy fnd_user.user_id%type,
                               p_cur_user_name         in out nocopy fnd_user.user_name%type,
                               p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
                               p_user_active_role_name in out nocopy pqh_roles.role_name%type,
                               p_routing_category_id      out nocopy pqh_routing_categories.routing_category_id%type,
                               p_member_cd                out nocopy pqh_transaction_categories.member_cd%type,
                               p_old_member_cd            out nocopy pqh_transaction_categories.member_cd%type,
                               p_routing_history_id       out nocopy pqh_routing_history.routing_history_id%type,
                               p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_person_id                out nocopy fnd_user.employee_id%type,
                               p_old_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_routing_list_id          out nocopy pqh_routing_lists.routing_list_id%type,
                               p_old_routing_list_id      out nocopy pqh_routing_lists.routing_list_id%type,
                               p_member_role_id           out nocopy pqh_roles.role_id%type,
                               p_member_user_id           out nocopy fnd_user.user_id%type,
                               p_cur_person_id            out nocopy fnd_user.employee_id%type,
                               p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_position_id              out nocopy pqh_position_transactions.position_id%type,
                               p_old_position_id          out nocopy pqh_position_transactions.position_id%type,
                               p_cur_position_id          out nocopy pqh_position_transactions.position_id%type,
                               p_pos_str_id               out nocopy pqh_routing_categories.position_structure_id%type,
                               p_old_pos_str_id           out nocopy pqh_routing_categories.position_structure_id%type,
                               p_pos_str_ver_id           out nocopy pqh_routing_history.pos_structure_version_id%type,
                               p_old_pos_str_ver_id       out nocopy pqh_routing_categories.position_structure_id%type,
                               p_assignment_id            out nocopy per_all_assignments_f.assignment_id%type,
                               p_cur_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                               p_old_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                               p_status_flag              out nocopy number,
                               p_history_flag             out nocopy boolean,
                               p_range_name               out nocopy pqh_attribute_ranges.range_name%type,
                               p_can_approve              out nocopy boolean)
as
 l_from_clause      pqh_table_route.from_clause%type;
 l_applicable_flag  boolean;
 l_value_date       date := trunc(sysdate);
 l_cur_user_id           fnd_user.user_id%type := p_cur_user_id;
 l_cur_user_name         fnd_user.user_name%type  := p_cur_user_name;
 l_user_active_role_id   pqh_roles.role_id%type   := p_user_active_role_id;
 l_user_active_role_name pqh_roles.role_name%type := p_user_active_role_name;

-- variable used to hold the value of approve_flag for thenext user
 l_can_approve  boolean;

 l_error_flag       boolean := FALSE;
 l_old_user_id   number;
 l_old_role_id   number;
 l_setup varchar2(30);
 l_proc             varchar2(256) := g_package||'applicable_next_user';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_trans_id is null then
     hr_utility.set_location('Transaction id reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
     hr_utility.raise_error;
  elsif p_tran_cat_id is null then
     hr_utility.set_location('Transaction category reqd '||l_proc,30);
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  elsif p_cur_user_id is null and p_cur_user_name is null then
     hr_utility.set_location('user id or user name reqd'||l_proc,40);
     hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
     hr_utility.raise_error;
  elsif p_user_active_role_id is null and p_user_active_role_name is null then
     hr_utility.set_location('user role id or role name reqd'||l_proc,50);
     hr_utility.set_message(8302,'PQH_ROLEID_OR_NAME_REQD');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location('transaction_id is '||p_trans_id||l_proc,51);
  hr_utility.set_location('trans_cat_id is '||p_tran_cat_id||l_proc,52);
  hr_utility.set_location('user_role_id is '||p_user_active_role_id||l_proc,53);
  hr_utility.set_location('user_role_name is '||p_user_active_role_name||l_proc,54);
  hr_utility.set_location('user_id is '||p_cur_user_id||l_proc,55);
  hr_utility.set_location('user_name is '||p_cur_user_name||l_proc,56);
  prepare_from_clause(p_tran_cat_id => p_tran_cat_id,
                      p_trans_id    => p_trans_id,
                      p_from_clause => l_from_clause);
  if l_from_clause is null then
     hr_utility.set_location('From_clause not there '||l_proc,57);
     hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
     hr_utility.raise_error;
  else
     hr_utility.set_location('From_clause selected '||l_proc,60);
     routing_current(p_tran_cat_id        => p_tran_cat_id,
                     p_trans_id           => p_trans_id,
                     p_history_flag       => p_history_flag,
                     p_old_member_cd      => p_old_member_cd,
                     p_position_id        => p_old_position_id,
                     p_member_id          => p_old_member_id,
                     p_role_id            => l_old_role_id,
                     p_user_id            => l_old_user_id,
                     p_assignment_id      => p_old_assignment_id,
                     p_pos_str_ver_id     => p_old_pos_str_ver_id,
                     p_routing_list_id    => p_old_routing_list_id,
                     p_routing_history_id => p_routing_history_id,
                     p_status_flag        => p_status_flag);
     if p_status_flag = 0 then
        hr_utility.set_location('no error in routing history'||l_proc,65);
        l_setup := tran_setup(p_tran_cat_id);
        hr_utility.set_location('tran_cat setup is '||l_setup||l_proc,66);
        if nvl(l_setup,'XYZ') = 'STANDARD' then
           list_range_check(p_tran_cat_id         => p_tran_cat_id,
                            p_member_cd           => p_member_cd,
                            p_used_for            => 'L',
                            p_routing_list_id     => p_routing_list_id,
                            p_pos_str_id          => p_pos_str_id,
                            p_routing_category_id => p_routing_category_id,
                            p_status_flag         => p_status_flag);
        elsif nvl(l_setup,'XYZ') = 'ADVANCED' then
           list_range_check(p_tran_cat_id         => p_tran_cat_id,
                            p_trans_id            => p_trans_id,
                            p_from_clause         => l_from_clause,
                            p_member_cd           => p_member_cd,
                            p_used_for            => 'L',
                            p_routing_list_id     => p_routing_list_id,
                            p_pos_str_id          => p_pos_str_id,
                            p_routing_category_id => p_routing_category_id,
                            p_range_name          => p_range_name,
                            p_status_flag         => p_status_flag);
        else
           p_status_flag := 10;
        end if;
        if p_status_flag = 0 then
	   hr_utility.set_location('CATg selected'||to_char(p_routing_category_id)||p_range_name||l_proc,70);
	else
	   hr_utility.set_location('errors in selecting routing_category'||l_proc,70);
	end if;
     else
        hr_utility.set_location('errors in selecing history '||l_proc,65);
     end if;
  end if;
  if p_status_flag = 0 then
     if p_member_cd = 'R' then
        hr_utility.set_location('Routing category is RL '||l_proc,80);
        rl_member_check(p_routing_list_id       => p_routing_list_id,
                        p_old_routing_list_id   => p_old_routing_list_id,
                        p_history_flag          => p_history_flag,
                        p_tran_cat_id           => p_tran_cat_id,
                        p_from_clause           => l_from_clause,
                        p_routing_category_id   => p_routing_category_id,
                        p_cur_member_id         => p_cur_member_id,
                        p_old_member_id         => p_old_member_id,
                        p_old_role_id           => l_old_role_id  ,
                        p_old_user_id           => l_old_user_id  ,
                        p_user_active_role_id   => p_user_active_role_id,
                        p_user_active_role_name => p_user_active_role_name,
                        p_cur_user_id           => p_cur_user_id,
                        p_cur_user_name         => p_cur_user_name,
                        p_member_id             => p_member_id,
                        p_member_role_id        => p_member_role_id,
                        p_member_user_id        => p_member_user_id,
                        p_status_flag           => p_status_flag,
                        p_applicable_flag       => l_applicable_flag,
                        p_old_can_approve       => p_can_approve,
                        p_can_approve           => l_can_approve) ;
        if p_status_flag <> 0 then
           hr_utility.set_location('error '||p_status_flag||l_proc,90);
        else
           hr_utility.set_location('procedure went fine'||l_proc,100);
        end if;
     elsif p_member_cd = 'P' then
        hr_utility.set_location('Routing category is PS'||l_proc,110);
        ps_element_check(p_history_flag        => p_history_flag,
                         p_value_date          => l_value_date,
                         p_tran_cat_id         => p_tran_cat_id,
                         p_from_clause         => l_from_clause,
                         p_routing_category_id => p_routing_category_id,
                         p_old_position_id     => p_old_position_id,
                         p_pos_str_id          => p_pos_str_id,
                         p_pos_str_ver_id      => p_pos_str_ver_id,
                         p_cur_user_id         => p_cur_user_id,
                         p_cur_user_name       => p_cur_user_name,
                         p_cur_position_id     => p_cur_position_id,
                         p_cur_person_id       => p_cur_person_id,
                         p_cur_assignment_id   => p_cur_assignment_id,
                         p_old_pos_str_id      => p_old_pos_str_id,
                         p_position_id         => p_position_id,
                         p_status_flag         => p_status_flag,
                         p_old_can_approve     => p_can_approve,
                         p_can_approve         => l_can_approve,
                         p_applicable_flag     => l_applicable_flag);
        if p_status_flag <> 0 then
           hr_utility.set_location('error in execution of '||l_proc,120);
        else
           hr_utility.set_location('fine'||l_proc,130);
        end if;
     elsif p_member_cd = 'S' then
        hr_utility.set_location('Routing category is S '||l_proc,140);
        assignment_check(p_history_flag          => p_history_flag,
                         p_tran_cat_id           => p_tran_cat_id,
                         p_from_clause           => l_from_clause,
                         p_routing_category_id   => p_routing_category_id,
                         p_old_assignment_id     => p_old_assignment_id,
                         p_value_date            => l_value_date,
                         p_cur_user_id           => p_cur_user_id,
                         p_cur_user_name         => p_cur_user_name,
                         p_cur_person_id         => p_cur_person_id,
                         p_assignment_id         => p_assignment_id,
                         p_person_id             => p_person_id,
                         p_status_flag           => p_status_flag,
                         p_cur_assignment_id     => p_cur_assignment_id,
                         p_old_can_approve       => p_can_approve,
                         p_can_approve           => l_can_approve,
                         p_applicable_flag       => l_applicable_flag );
        if p_status_flag <> 0 then
           hr_utility.set_location('error in procedure '||l_proc,150);
        else
           hr_utility.set_location('The execution went fine'||l_proc,160);
        end if;
     else
        hr_utility.set_location('Invalid member_cd '||l_proc,170);
     end if;
  else
     hr_utility.set_location('error reported is '||to_char(p_status_flag)||l_proc,180);
  end if;
  list_rout_crit;
  hr_utility.set_location('Rout catg'||to_char(p_routing_category_id)||l_proc,200);
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_cur_user_id              := l_cur_user_id;
p_cur_user_name            := l_cur_user_name;
p_user_active_role_id      := l_user_active_role_id;
p_user_active_role_name    := l_user_active_role_name;
p_routing_category_id      := null;
p_member_cd                := null;
p_old_member_cd            := null;
p_routing_history_id       := null;
p_member_id                := null;
p_person_id                := null;
p_old_member_id            := null;
p_routing_list_id          := null;
p_old_routing_list_id      := null;
p_member_role_id           := null;
p_member_user_id           := null;
p_cur_person_id           := null;
p_cur_member_id            := null;
p_position_id              := null;
p_old_position_id          := null;
p_cur_position_id          := null;
p_pos_str_id               := null;
p_old_pos_str_id           := null;
p_pos_str_ver_id           := null;
p_old_pos_str_ver_id       := null;
p_assignment_id            := null;
p_cur_assignment_id        := null;
p_old_assignment_id        := null;
p_status_flag              := null;
p_history_flag             := null;
p_range_name               := null;
p_can_approve              := null;
raise;
end applicable_next_user;

procedure person_on_assignment(p_assignment_id in per_all_assignments_f.assignment_id%type,
			       p_value_date    in date,
                               p_person_id        out nocopy fnd_user.employee_id%type )
as
  cursor c1 is select person_id
               from per_all_assignments_f
               where assignment_id = p_assignment_id
	       and p_value_date between effective_start_date and effective_end_date;
 l_proc        varchar2(256) := g_package||'person_on_assignment';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_assignment_id is not null then
     open c1;
     fetch c1 into p_person_id;
     if c1%notfound then
        hr_utility.set_location('error in fetching info.'||l_proc,20);
     else
        hr_utility.set_location('person for assignment '||to_char(p_assignment_id)||' is '||to_char(p_person_id)||l_proc,30);
     end if;
     close c1;
  else
     hr_utility.set_location('assignment id reqd for person '||l_proc,40);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_person_id := null;
raise;
end person_on_assignment;

procedure rl_member_check(p_routing_list_id       in pqh_routing_lists.routing_list_id%type,
                          p_old_routing_list_id   in pqh_routing_lists.routing_list_id%type,
                          p_history_flag          in boolean,
                          p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
                          p_from_clause           in pqh_table_route.from_clause%type,
                          p_routing_category_id   in pqh_routing_categories.routing_category_id%type,
                          p_old_member_id         in pqh_routing_list_members.routing_list_member_id%type,
                          p_old_user_id           in number,
                          p_old_role_id           in number,
                          p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
                          p_user_active_role_name in out nocopy pqh_roles.role_name%type,
                          p_cur_user_id           in out nocopy fnd_user.user_id%type,
                          p_cur_user_name         in out nocopy fnd_user.user_name%type,
                          p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_member_role_id           out nocopy pqh_routing_list_members.role_id%type,
                          p_member_user_id           out nocopy pqh_routing_list_members.user_id%type,
                          p_status_flag              out nocopy number,
                          p_applicable_flag          out nocopy boolean,
			  p_old_can_approve          out nocopy boolean,
                          p_can_approve              out nocopy boolean )
as
l_user_active_role_id   pqh_roles.role_id%type := p_user_active_role_id;
l_user_active_role_name pqh_roles.role_name%type := p_user_active_role_name;
l_cur_user_id           fnd_user.user_id%type := p_cur_user_id;
l_cur_user_name         fnd_user.user_name%type := p_cur_user_name;

  l_member_id       pqh_routing_list_members.routing_list_member_id%type;
  l_member_flag     boolean  ;
  l_applicable_flag boolean;
  l_error_flag      boolean := FALSE ;
  l_override_approver boolean ;
  l_proc            varchar2(256) := g_package||'rl_member_check';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_tran_cat_id is null then
     hr_utility.set_location('Transaction category reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  elsif p_from_clause is null then
     hr_utility.set_location('from clause reqd '||l_proc,30);
     hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
     hr_utility.raise_error;
  elsif p_routing_list_id is null then
     hr_utility.set_location('Routing list reqd '||l_proc,40);
     hr_utility.set_message(8302,'PQH_ROUTING_LIST_REQD');
     hr_utility.raise_error;
  elsif p_cur_user_id is null and p_cur_user_name is null then
     hr_utility.set_location('USER id or name reqd '||l_proc,50);
     hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
     hr_utility.raise_error;
  elsif p_user_active_role_id is null and p_user_active_role_name is null then
     hr_utility.set_location('role id or name reqd '||l_proc,50);
     hr_utility.set_message(8302,'PQH_ROLEID_OR_NAME_REQD');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location('All the required data is there '||l_proc,60);
  p_status_flag := 0;
  p_applicable_flag := FALSE;
  rlm_user_seq(p_routing_list_id => p_routing_list_id,
               p_old_user_id     => p_old_user_id ,
               p_old_role_id     => p_old_role_id ,
               p_old_member_id   => p_old_member_id ,
               p_role_id         => p_user_active_role_id,
               p_role_name       => p_user_active_role_name,
               p_user_id         => p_cur_user_id,
               p_user_name       => p_cur_user_name,
               p_member_id       => p_cur_member_id,
               p_member_flag     => l_member_flag);
  if l_member_flag = TRUE then
     hr_utility.set_location('Cur memberid '||to_char(p_cur_member_id)||l_proc,70);
     -- calculate wether the current member can approve the transaction or not.
     rl_member_applicable(p_tran_cat_id         => p_tran_cat_id,
                          p_from_clause         => p_from_clause,
                          p_member_id           => p_cur_member_id,
                          p_routing_category_id => p_routing_category_id,
                          p_used_for            => 'C',
                          p_applicable_flag     => l_applicable_flag,
                          p_status_flag         => p_status_flag,
                          p_can_approve         => p_old_can_approve);
     if p_status_flag <> 0 then
        hr_utility.set_location('current member authority check failed'||l_proc,80);
        hr_utility.set_message(8302,'PQH_CURMEMBER_APPROVE_CHK_FAIL');
        hr_utility.raise_error;
     else
        if p_old_can_approve = TRUE then
           hr_utility.set_location('current member can approve '||l_proc,90);
        else
           hr_utility.set_location('current member cannot approve '||l_proc,92);
        end if;
     end if;
  else
     hr_utility.set_location('current user not in RL '||l_proc,100);
     l_override_approver := override_approver(p_member_cd           => 'R',
                                              p_routing_category_id => p_routing_category_id,
                                              p_assignment_id       => '',
                                              p_role_id             => p_user_active_role_id,
                                              p_user_id             => p_cur_user_id,
                                              p_position_id         => '');
     if l_override_approver then
        p_old_can_approve := TRUE;
        hr_utility.set_location('member is defined as override approver '||l_proc,129);
     else
        p_old_can_approve := FALSE;
        hr_utility.set_location('member is not defined as override approver '||l_proc,129);
     end if;
  end if;
  l_member_id := p_cur_member_id;
  while p_status_flag = 0 and nvl(p_applicable_flag,FALSE) = FALSE loop
     rl_next_user(p_routing_list_id => p_routing_list_id,
                  p_cur_member_id   => l_member_id,
                  p_member_id       => p_member_id,
                  p_role_id         => p_member_role_id,
                  p_user_id         => p_member_user_id,
                  p_status_flag     => p_status_flag);
     if p_status_flag = 0 then
        hr_utility.set_location('user selected, checking applicability'||l_proc,110);
        rl_member_applicable(p_tran_cat_id         => p_tran_cat_id,
                             p_from_clause         => p_from_clause,
                             p_member_id           => p_member_id,
                             p_routing_category_id => p_routing_category_id,
                             p_used_for            => 'N',
                             p_applicable_flag     => p_applicable_flag,
                             p_status_flag         => p_status_flag,
                             p_can_approve         => p_can_approve);
        if p_status_flag = 0 then
           hr_utility.set_location('User checked for applicability no error'||l_proc,120);
           if p_applicable_flag = FALSE then
              hr_utility.set_location('user not applicable, another iteration '||l_proc,130);
              l_member_id := p_member_id;
           else
              hr_utility.set_location('user is applicable '||l_proc,140);
           end if;
        elsif p_status_flag = 1 then
           hr_utility.set_location('got EOL for member'||to_char(p_member_id)||l_proc,150);
        else
           hr_utility.set_location('Error, status is '||to_char(p_status_flag)||' memberid '||to_char(p_member_id)||l_proc,160);
        end if;
     elsif p_status_flag = 1 then
        hr_utility.set_location('Got EOL '||l_proc,170);
     else
        hr_utility.set_location('error  '||to_char(p_status_flag)||to_char(l_member_id)||l_proc,180);
     end if;
  end loop;
  if p_status_flag = 0 then
     hr_utility.set_location('no error so far and out nocopy of loop '||l_proc,190);
     if p_applicable_flag = TRUE then
        hr_utility.set_location('Applicable member found to be '||to_char(p_member_id)||l_proc,200);
     else
        hr_utility.set_location('This message should not be shown '||l_proc,210);
     end if;
  else
     hr_utility.set_location('Out of loop, status_flag '||to_char(p_status_flag)||l_proc,220);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_user_active_role_id   := l_user_active_role_id;
p_user_active_role_name := l_user_active_role_name;
p_cur_user_id           := l_cur_user_id;
p_cur_user_name         := l_cur_user_name;
p_cur_member_id            := null;
p_member_id                := null;
p_member_role_id           := null;
p_member_user_id           := null;
p_status_flag              := null;
p_applicable_flag          := null;
p_old_can_approve          := null;
p_can_approve              := null;
raise;
end rl_member_check ;

procedure ps_element_check(p_history_flag        in boolean,
                           p_value_date          in date,
                           p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                           p_from_clause         in pqh_table_route.from_clause%type,
                           p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                           p_old_position_id     in pqh_position_transactions.position_id%type,
                           p_pos_str_id          in per_pos_structure_versions.position_structure_id%type,
                           p_cur_user_id         in out nocopy fnd_user.user_id%type,
                           p_cur_user_name       in out nocopy fnd_user.user_name%type,
			   p_pos_str_ver_id         out nocopy per_pos_structure_elements.pos_structure_version_id%type,
                           p_cur_position_id        out nocopy per_all_assignments_f.position_id%type,
                           p_cur_person_id          out nocopy fnd_user.employee_id%type,
                           p_cur_assignment_id      out nocopy per_all_assignments_f.assignment_id%type,
                           p_old_pos_str_id         out nocopy per_pos_structure_versions.position_structure_id%type,
                           p_position_id            out nocopy pqh_position_transactions.position_id%type,
                           p_status_flag            out nocopy number,
                           p_can_approve            out nocopy boolean,
                           p_old_can_approve        out nocopy boolean,
                           p_applicable_flag        out nocopy boolean )
as
  l_cur_user_id         fnd_user.user_id%type := p_cur_user_id;
  l_cur_user_name       fnd_user.user_name%type := p_cur_user_name;
  l_cur_position_id pqh_position_transactions.position_id%type;
  l_override_approver boolean ;
  l_error_flag      boolean := FALSE;
  l_member_flag     varchar2(30) ;
  l_pos_str_change  boolean;
  l_applicable_flag boolean;
  l_proc            varchar2(256) := g_package||'ps_element_check';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  p_status_flag := 0;
  p_applicable_flag := FALSE;
  if p_tran_cat_id is null then
     hr_utility.set_location('Transaction category reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  elsif p_from_clause is null then
     hr_utility.set_location('From clause reqd '||l_proc,30);
     hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
     hr_utility.raise_error;
  elsif p_cur_user_id is null and p_cur_user_name is null then
     hr_utility.set_location('either cur user id or name reqd '||l_proc,40);
     hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
     hr_utility.raise_error;
  elsif p_pos_str_id is null then
     hr_utility.set_location('Position structure must be provided '||l_proc,41);
     hr_utility.set_message(8302,'PQH_POS_STR_REQD');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location('Get the latest version '||l_proc,42);
  p_pos_str_ver_id := pos_str_version(p_pos_str_id     => p_pos_str_id);
  hr_utility.set_location('getting current user details'||l_proc,52);
  user_position_and_assignment(p_user_id           => p_cur_user_id,
                               p_user_name         => p_cur_user_name,
                               p_value_date        => p_value_date,
                               p_assignment_id     => p_cur_assignment_id,
                               p_person_id         => p_cur_person_id,
                               p_position_id       => p_cur_position_id);
  hr_utility.set_location('Current user position id is '||to_char(p_cur_position_id)||l_proc,70);
  l_member_flag := pos_in_ph(p_position_id    => p_cur_position_id,
                             p_pos_str_ver_id => p_pos_str_ver_id );
  hr_utility.set_location('Current user position id is '||l_proc,701);

  if l_member_flag = 'TRUE' then
     hr_utility.set_location('l_member_flag = TRUE '||l_proc,702);
     ps_element_applicable(p_tran_cat_id         => p_tran_cat_id,
                           p_from_clause         => p_from_clause,
                           p_position_id         => p_cur_position_id,
                           p_routing_category_id => p_routing_category_id,
                           p_value_date          => p_value_date,
                           p_used_for            => 'C',
                           p_applicable_flag     => l_applicable_flag,
                           p_status_flag         => p_status_flag,
                           p_can_approve         => p_old_can_approve );
     hr_utility.set_location('l_member_flag = TRUE '||l_proc,703);
     if p_status_flag = 0 then
     hr_utility.set_location('l_member_flag = TRUE '||l_proc,704);
        if p_old_can_approve then
           hr_utility.set_location('cur user can approve '||l_proc,71);
        else
           hr_utility.set_location('cur user can not approve '||l_proc,72);
        end if;
     else
        hr_utility.set_location('cur position approve checked'||l_proc,73);
        hr_utility.set_message(8302,'PQH_CURPOS_APPROVE_FAILED');
        hr_utility.raise_error;
     end if;
     hr_utility.set_location('l_member_flag = TRUE '||l_proc,705);
  else
     hr_utility.set_location('current position not in PH'||l_proc,74);
     hr_utility.set_location('checking override approver'||l_proc,75);
     -- check for override position approver
     l_override_approver := override_approver(p_member_cd           => 'P',
                                              p_routing_category_id => p_routing_category_id,
                                              p_assignment_id       => '',
                                              p_role_id             => '',
                                              p_user_id             => '',
                                              p_position_id         => p_cur_position_id);
     if l_override_approver then
        p_old_can_approve := TRUE;
        hr_utility.set_location('override position'||l_proc,76);
     end if;
  end if;
  hr_utility.set_location('After l_member_flag cond '||l_proc,710);
  l_cur_position_id := p_cur_position_id;
/* Changed the while condition-to fetch next available position
   in case of eliminated position Bug#2295241 */
  while (p_status_flag = 0 or p_status_flag = 8)and nvl(p_applicable_flag,FALSE) = FALSE loop
     hr_utility.set_location('Inside the next position loop'||l_proc,80);
     ph_next_user(p_cur_position_id => l_cur_position_id,
                  p_pos_str_ver_id  => p_pos_str_ver_id,
                  p_position_id     => p_position_id,
                  p_status_flag     => p_status_flag) ;
     if p_status_flag = 0 then
        hr_utility.set_location('user selected '||to_char(p_position_id)||l_proc,90);
        ps_element_applicable(p_tran_cat_id         => p_tran_cat_id,
                              p_from_clause         => p_from_clause,
                              p_position_id         => p_position_id,
                              p_routing_category_id => p_routing_category_id,
                              p_value_date          => p_value_date,
                              p_used_for            => 'N',
                              p_applicable_flag     => p_applicable_flag,
                              p_status_flag         => p_status_flag,
                              p_can_approve         => p_can_approve );
        if p_status_flag = 0 then
           hr_utility.set_location('User checked no error'||l_proc,100);
           if p_applicable_flag = FALSE then
              hr_utility.set_location('user unapplicable, iteration reqd'||l_proc,110);
              l_cur_position_id := p_position_id;
           else
              hr_utility.set_location('user applicable '||l_proc,120);
           end if;
        elsif p_status_flag = 1 then
           hr_utility.set_location('got EOL'||to_char(l_cur_position_id)||l_proc,130);
/* Added for Bug#2295241 */
        elsif p_status_flag = 8 then
           hr_utility.set_location('Eliminated Position:'||to_char(l_cur_position_id)||l_proc,135);
           l_cur_position_id := p_position_id;
/* End Bug#2295241*/
        else
           hr_utility.set_location('Error,stat'||to_char(p_status_flag)||' Pos'||to_char(l_cur_position_id)||l_proc,140);
        end if;
     elsif p_status_flag = 1 then
        hr_utility.set_location('Got EOL '||l_proc,150);
     elsif p_status_flag = 8 then
        hr_utility.set_location('Got Eliminated Position '||l_proc,155);
        /* Added for Bug#2295241 */
        l_cur_position_id := p_position_id;
        /* End Bug#2295241 */
     else
        hr_utility.set_location('error next position '||to_char(l_cur_position_id)||l_proc,160);
     end if;
  end loop;
  if p_status_flag = 0 then
     hr_utility.set_location('no error so far '||l_proc,170);
     if p_applicable_flag = TRUE then
        hr_utility.set_location('Applicable position '||to_char(p_position_id)||l_proc,180);
     else
        hr_utility.set_location('message not be shown '||l_proc,190);
     end if;
  else
     hr_utility.set_location('Out,status_flag '||to_char(p_status_flag)||l_proc,200);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
			   p_cur_user_id         := l_cur_user_id;
			   p_cur_user_name       := l_cur_user_name;
			   p_pos_str_ver_id         := null;
                           p_cur_position_id        := null;
                           p_cur_person_id          := null;
                           p_cur_assignment_id      := null;
                           p_old_pos_str_id         := null;
                           p_position_id            := null;
                           p_status_flag            := null;
                           p_can_approve            := null;
                           p_old_can_approve        := null;
                           p_applicable_flag        := null;
raise;
end ps_element_check ;

procedure assignment_check(p_history_flag        in boolean,
                           p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                           p_from_clause         in pqh_table_route.from_clause%type,
                           p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                           p_old_assignment_id   in per_all_assignments_f.assignment_id%type,
                           p_value_date          in date,
                           p_cur_user_id         in out nocopy fnd_user.user_id%type,
                           p_cur_user_name       in out nocopy fnd_user.user_name%type,
                           p_cur_person_id          out nocopy fnd_user.employee_id%type,
                           p_assignment_id          out nocopy per_all_assignments_f.assignment_id%type,
                           p_person_id              out nocopy per_all_assignments_f.person_id%type,
                           p_status_flag            out nocopy number,
                           p_cur_assignment_id      out nocopy per_all_assignments_f.assignment_id%type,
                           p_old_can_approve        out nocopy boolean,
                           p_can_approve            out nocopy boolean,
                           p_applicable_flag        out nocopy boolean )
as
  l_old_assignment_id per_all_assignments_f.assignment_id%type;
  l_applicable_flag   boolean ;
  l_override_approver boolean;
  l_error_flag        boolean := FALSE ;
  l_proc              varchar2(256) := g_package||'assignment_check';
  l_cur_user_id 	fnd_user.user_id%type := p_cur_user_id;
  l_cur_user_name 	fnd_user.user_name%type := p_cur_user_name;
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_tran_cat_id is null then
      hr_utility.set_location('Trans_cat reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_from_clause is null then
      hr_utility.set_location('From clause reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   elsif p_cur_user_id is null and p_cur_user_name is null then
      hr_utility.set_location('Cur userid or name reqd '||l_proc,40);
      hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
      hr_utility.raise_error;
   end if;
   p_status_flag := 0;
   user_assignment(p_user_id           => p_cur_user_id,
                   p_user_name         => p_cur_user_name,
                   p_person_id         => p_cur_person_id,
                   p_value_date        => p_value_date,
                   p_assignment_id     => p_cur_assignment_id);
   assignment_applicable(p_tran_cat_id         => p_tran_cat_id,
                         p_from_clause         => p_from_clause,
                         p_assignment_id       => p_cur_assignment_id,
                         p_routing_category_id => p_routing_category_id,
                         p_value_date          => p_value_date,
                         p_used_for            => 'C',
                         p_applicable_flag     => l_applicable_flag,
                         p_status_flag         => p_status_flag,
                         p_can_approve         => p_old_can_approve) ;
   if p_status_flag = 0 then
      if p_old_can_approve then
         hr_utility.set_location('cur user can approve '||l_proc,41);
      else
         hr_utility.set_location('cur user can not approve '||l_proc,42);
      end if;
   else
      hr_utility.set_location('assignment not applicable, checking override'||l_proc,50);
      l_override_approver := override_approver(p_member_cd           => 'S',
                                               p_routing_category_id => p_routing_category_id,
                                               p_assignment_id       => p_assignment_id,
                                               p_role_id             => '',
                                               p_user_id             => '',
                                               p_position_id         => '');
      if l_override_approver then
         p_old_can_approve := TRUE;
         hr_utility.set_location('assignment is defined as override approver '||l_proc,129);
      else
         p_old_can_approve := FALSE;
         hr_utility.set_location('assignment is not defined as override approver '||l_proc,129);
      end if;
   end if;
   l_old_assignment_id := p_cur_assignment_id;
   while p_status_flag = 0 and nvl(p_applicable_flag,FALSE) = FALSE loop
      hr_utility.set_location('Finding the supervisor of assignment'||to_char(l_old_assignment_id)||l_proc,70);
      su_next_user(p_cur_assignment_id  => l_old_assignment_id,
                   p_value_date         => p_value_date,
                   p_assignment_id      => p_assignment_id,
                   p_status_flag        => p_status_flag) ;
      if p_status_flag = 0 then
         hr_utility.set_location('next assignment selected, checking '||l_proc,80);
         assignment_applicable(p_tran_cat_id         => p_tran_cat_id,
                               p_from_clause         => p_from_clause,
                               p_assignment_id       => p_assignment_id,
                               p_routing_category_id => p_routing_category_id,
                               p_value_date          => p_value_date,
                               p_used_for            => 'N',
                               p_applicable_flag     => p_applicable_flag,
                               p_status_flag         => p_status_flag,
                               p_can_approve         => p_can_approve) ;
         if p_status_flag = 0 then
            hr_utility.set_location('assignment checked no error'||l_proc,90);
            if p_applicable_flag = FALSE then
               hr_utility.set_location('unapplicable, iteration'||l_proc,100);
               l_old_assignment_id := p_assignment_id;
            else
               hr_utility.set_location('assignment applicable'||l_proc,110);
            end if;
         elsif p_status_flag = 1 then
            hr_utility.set_location('got EOL, assignment '||to_char(l_old_assignment_id)||l_proc,120);
         else
            hr_utility.set_location('Error , status '||to_char(p_status_flag)||' assignment '||to_char(l_old_assignment_id)||l_proc,130);
         end if;
      elsif p_status_flag = 1 then
         hr_utility.set_location('Got EOL'||l_proc,140);
      else
         hr_utility.set_location('error , assignment '||to_char(l_old_assignment_id)||l_proc,150);
      end if;
   end loop;
   if p_status_flag = 0 then
      hr_utility.set_location('no error , out nocopy of loop '||l_proc,160);
      if p_applicable_flag = TRUE then
         hr_utility.set_location('Applicable assignment '||to_char(p_assignment_id)||l_proc,170);
      else
         hr_utility.set_location('message should not be shown '||l_proc,180);
      end if;
   else
      hr_utility.set_location('Out of loop and status_flag '||to_char(p_status_flag)||l_proc,190);
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                           p_cur_user_id            := l_cur_user_id;
                           p_cur_user_name          := l_cur_user_name;
                           p_cur_person_id          := null;
                           p_assignment_id          := null;
                           p_person_id              := null;
                           p_status_flag            := null;
                           p_cur_assignment_id      := null;
                           p_old_can_approve        := null;
                           p_can_approve            := null;
                           p_applicable_flag        := null;
raise;
end assignment_check ;

function get_attribute_name(p_attribute_id   in number,
                            p_transaction_id in number,
                            p_tran_cat_id    in number)
return varchar2 is
   l_attribute_name varchar2(200);
   l_column_name varchar2(200);
   l_unit_name varchar2(200);
   l_avail_desc varchar2(200);
   l_budget_id number;
cursor c0 is select wks.budget_id
             from pqh_worksheets wks, pqh_worksheet_details wdt
             where wdt.worksheet_detail_id = p_transaction_id
             and wdt.worksheet_id = wks.worksheet_id
             and wks.wf_transaction_category_id = p_tran_cat_id;
cursor c1 is select attribute_name,column_name
             from pqh_attributes_vl
             where attribute_id = p_attribute_id
             and nvl(enable_flag,'X') ='Y';
cursor c2 is select sty.shared_type_name unit_name,lkp.description avail_desc
             from pqh_budgets bgt, per_shared_types sty, hr_lookups lkp
             where bgt.budget_id = l_budget_id
             and bgt.budget_unit1_aggregate = lkp.lookup_code
             and lkp.lookup_type ='PQH_BGT_UOM_AGGREGATE'
             and bgt.budget_unit1_id = sty.shared_type_id ;
cursor c3 is select sty.shared_type_name unit_name, lkp.description avail_desc
             from pqh_budgets bgt, per_shared_types sty, hr_lookups lkp
             where bgt.budget_id = l_budget_id
             and bgt.budget_unit2_aggregate = lkp.lookup_code
             and lkp.lookup_type ='PQH_BGT_UOM_AGGREGATE'
             and bgt.budget_unit2_id = sty.shared_type_id ;
cursor c4 is select sty.shared_type_name unit_name, lkp.description avail_desc
             from pqh_budgets bgt, per_shared_types sty, hr_lookups lkp
             where bgt.budget_id = l_budget_id
             and bgt.budget_unit3_aggregate = lkp.lookup_code
             and lkp.lookup_type ='PQH_BGT_UOM_AGGREGATE'
             and bgt.budget_unit3_id = sty.shared_type_id ;
   l_proc             varchar2(256) := g_package||'get_attribute_name';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('attribute_id is '||p_attribute_id||l_proc,20);
   open c0;
   fetch c0 into l_budget_id;
   if c0%found then
      hr_utility.set_location('budget is '||l_budget_id||l_proc,20);
      for i in c1 loop
         l_attribute_name := i.attribute_name;
         l_column_name := i.column_name;
      end loop;
      hr_utility.set_location('attribute_name is '||l_attribute_name||l_proc,30);
      hr_utility.set_location('column_name is '||l_column_name||l_proc,30);
      if l_column_name in ('WDT.BUDGET_UNIT1_VALUE','WDT.BUDGET_UNIT1_AVAILABLE','WDT.BUDGET_UNIT1_PERCENT') then
         hr_utility.set_location('unit column is '||l_column_name||l_proc,30);
         open c2;
         fetch c2 into l_unit_name,l_avail_desc ;
         if c2%notfound then
            hr_utility.set_location('unit1 is not defined '||l_proc,30);
         else
            hr_utility.set_location('unit1_name fetched '||l_unit_name||l_proc,30);
            if l_column_name = 'WDT.BUDGET_UNIT1_VALUE' then
               l_attribute_name := l_unit_name ;
            elsif l_column_name = 'WDT.BUDGET_UNIT1_PERCENT' then
               l_attribute_name := l_unit_name ||' : % ';
            elsif l_column_name = 'WDT.BUDGET_UNIT1_AVAILABLE' then
               l_attribute_name := l_unit_name ||' : '||l_avail_desc;
            end if;
         end if;
         close c2;
      elsif l_column_name in ('WDT.BUDGET_UNIT2_VALUE','WDT.BUDGET_UNIT2_AVAILABLE','WDT.BUDGET_UNIT2_PERCENT') then
         hr_utility.set_location('unit column is '||l_column_name||l_proc,30);
         open c3;
         fetch c3 into l_unit_name,l_avail_desc ;
         if c3%notfound then
            hr_utility.set_location('unit2 is not defined '||l_proc,30);
         else
            hr_utility.set_location('unit2_name fetched '||l_unit_name||l_proc,30);
            if l_column_name = 'WDT.BUDGET_UNIT2_VALUE' then
               l_attribute_name := l_unit_name ;
            elsif l_column_name = 'WDT.BUDGET_UNIT2_PERCENT' then
               l_attribute_name := l_unit_name ||' : % ';
            elsif l_column_name = 'WDT.BUDGET_UNIT2_AVAILABLE' then
               l_attribute_name := l_unit_name ||' : '||l_avail_desc;
            end if;
         end if;
         close c3;
      elsif l_column_name in ('WDT.BUDGET_UNIT3_VALUE','WDT.BUDGET_UNIT3_AVAILABLE','WDT.BUDGET_UNIT3_PERCENT') then
         hr_utility.set_location('unit column is '||l_column_name||l_proc,30);
         open c4;
         fetch c4 into l_unit_name,l_avail_desc ;
         if c4%notfound then
            hr_utility.set_location('unit3 is not defined'||l_proc,30);
         else
            hr_utility.set_location('unit3_name fetched '||l_unit_name||l_proc,30);
            if l_column_name = 'WDT.BUDGET_UNIT3_VALUE' then
               l_attribute_name := l_unit_name ;
            elsif l_column_name = 'WDT.BUDGET_UNIT3_PERCENT' then
               l_attribute_name := l_unit_name ||' : % ';
            elsif l_column_name = 'WDT.BUDGET_UNIT3_AVAILABLE' then
               l_attribute_name := l_unit_name ||' : '||l_avail_desc;
            end if;
         end if;
         close c4;
      end if;
   else
      hr_utility.set_location('tran_cat is '||p_tran_cat_id||l_proc,30);
      for i in c1 loop
         l_attribute_name := i.attribute_name;
         l_column_name := i.column_name;
      end loop;
   end if;
   hr_utility.set_location('attribute_name is '||l_attribute_name||l_proc,30);
   return l_attribute_name;
   hr_utility.set_location('Exiting '||l_proc,10000);
end;

procedure list_range_check(p_tran_cat_id       in pqh_transaction_categories.transaction_category_id%type,
                           p_used_for          in varchar2           default null,
                           p_member_cd            out nocopy pqh_transaction_categories.member_cd%type,
                           p_routing_list_id      out nocopy pqh_routing_lists.routing_list_id%type,
                           p_pos_str_id           out nocopy pqh_routing_categories.position_structure_id%type,
                           p_routing_category_id  out nocopy pqh_routing_categories.routing_category_id%type,
                           p_status_flag          out nocopy number ) is
   cursor c0 is select member_cd
                from pqh_transaction_categories
                where transaction_category_id = p_tran_cat_id;
   cursor c1 is
   select routing_list_id ,routing_category_id
   from pqh_routing_categories
   where transaction_category_id = p_tran_cat_id
   and nvl(enable_flag,'N') ='Y'
   and nvl(default_flag,'N') = 'Y'
   and nvl(delete_flag,'N') = 'N'
   and routing_list_id is not null;

   cursor c2 is
   select position_structure_id ,routing_category_id
   from pqh_routing_categories
   where transaction_category_id = p_tran_cat_id
   and nvl(enable_flag,'N') ='Y'
   and nvl(default_flag,'N') = 'Y'
   and nvl(delete_flag,'N') = 'N'
   and position_structure_id is not null;

   cursor c3 is
   select routing_category_id
   from pqh_routing_categories
   where transaction_category_id = p_tran_cat_id
   and nvl(enable_flag,'N') ='Y'
   and nvl(default_flag,'N') = 'Y'
   and nvl(delete_flag,'N') = 'N'
   and routing_list_id is null
   and position_structure_id is null;

   l_proc             varchar2(256) := g_package||'list_range_check_std';
begin
   -- this procedure will be getting called if only standard setup is complete.
  /*
   The change in logic , to pick up the routing category was changed with discussion with stella
   as per the change in wizard functionality.
   earlier we were assuming that only one default routing category will be there, but there can be
   multiple default routing categories for different member_cd.
   for a member_cd however there will be only one.  so based on that assumption, three cursors
   were made to pull up the routing category based on member_cd
  */
  hr_utility.set_location('Entering '||l_proc,10);
  p_status_flag := 0;
  if p_tran_cat_id is null then
     hr_utility.set_location('Transaction category reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  end if;
  delete_rout_crit(p_used_for => nvl(p_used_for,'L'));
  hr_utility.set_location('data deleted for rout select '||l_proc,40);
  open c0;
  fetch c0 into p_member_cd;
  close c0;
  if p_member_cd = 'R' then
     hr_utility.set_location('Routing List '||l_proc,50);
     open c1;
     fetch c1 into p_routing_list_id,p_routing_category_id;
     close c1;
  elsif p_member_cd ='P' then
     hr_utility.set_location('Position hierarchy '||l_proc,60);
     open c2;
     fetch c2 into p_pos_str_id,p_routing_category_id;
     close c2;
  elsif p_member_cd ='S' then
     hr_utility.set_location('Supervisory hierarchy '||l_proc,70);
     open c3;
     fetch c3 into p_routing_category_id;
     close c3;
  else
     hr_utility.set_location('invalid member cd '||l_proc,70);
     p_status_flag := 1;
  end if;
  hr_utility.set_location('Exiting '||l_proc,200);
exception
  when others then
                           p_member_cd            := null;
                           p_routing_list_id      := null;
                           p_pos_str_id           := null;
                           p_routing_category_id  := null;
                           p_status_flag          := null;
     hr_utility.set_location('some error'||substr(sqlerrm,1,50),100);
     hr_utility.raise_error;
end list_range_check;

procedure list_range_check(p_tran_cat_id       in pqh_transaction_categories.transaction_category_id%type,
                           p_trans_id          in pqh_routing_history.transaction_id%type,
                           p_from_clause       in pqh_table_route.from_clause%type,
                           p_used_for          in varchar2           default null,
                           p_member_cd            out nocopy pqh_transaction_categories.member_cd%type,
                           p_routing_list_id      out nocopy pqh_routing_lists.routing_list_id%type,
                           p_pos_str_id           out nocopy pqh_routing_categories.position_structure_id%type,
                           p_routing_category_id  out nocopy pqh_routing_categories.routing_category_id%type,
                           p_range_name           out nocopy pqh_attribute_ranges.range_name%type,
                           p_status_flag          out nocopy number )
as
 cursor c1 is
        select distinct ar.routing_category_id, ar.range_name
        from pqh_attribute_ranges ar
        where ar.routing_list_member_id is null
        and ar.position_id is null
        and ar.assignment_id is null
        and nvl(ar.enable_flag,'X')  = 'Y'
        and nvl(ar.delete_flag,'N')  = 'N'
        and routing_category_id in (select routing_category_id
                                    from pqh_routing_categories rc, pqh_transaction_categories tc
                                    where rc.transaction_category_id = p_tran_cat_id
                                    and tc.transaction_category_id = rc.transaction_category_id
                                    and ((tc.member_cd = 'R' and rc.routing_list_id is not null) or
                                        (tc.member_cd = 'P' and rc.Position_structure_id is not null) or
                                        (tc.member_cd = 'S' and rc.routing_list_id is null and rc.position_structure_id is null))
                                    and nvl(rc.enable_flag,'X')  = 'Y'
                                    and nvl(rc.delete_flag,'N')  = 'N'
                                    and nvl(rc.default_flag,'X') <> 'Y' );
 cursor c2 is
        select att.attribute_id,att.attribute_name,att.column_name,att.column_type
        from pqh_attributes att, pqh_txn_category_attributes tca
        where att.attribute_id = tca.attribute_id
	and tca.transaction_category_id = p_tran_cat_id
        and tca.list_identifying_flag = 'Y'
        and nvl(att.enable_flag,'X') = 'Y';
 cursor c3(p_attribute_id varchar2) is
        select ar.from_char,ar.to_char,ar.from_date,ar.to_date,ar.from_number,
               ar.to_number,rc.routing_category_id,ar.range_name
        from pqh_attribute_ranges ar,pqh_routing_categories rc
        where ar.attribute_id = p_attribute_id
        and ar.routing_category_id = rc.routing_category_id
        and rc.transaction_category_id = p_tran_cat_id
	and ar.routing_list_member_id is null
	and ar.position_id is null
	and ar.assignment_id is null
        and nvl(ar.enable_flag,'X') = 'Y'
        and nvl(rc.delete_flag,'N') = 'N'
        and nvl(ar.delete_flag,'N') = 'N'
        and nvl(rc.enable_flag,'X') = 'Y'
        and nvl(rc.default_flag,'X') <> 'Y';
 cursor c4 is
        select tc.member_cd,rc.routing_list_id,rc.position_structure_id
        from pqh_routing_categories rc, pqh_transaction_categories tc
        where rc.routing_category_id = p_routing_category_id
        and tc.transaction_category_id = rc.transaction_category_id
        and nvl(rc.delete_flag,'N') = 'N'
        and nvl(rc.enable_flag,'X') = 'Y';
 l_attribute_value_char varchar2(2000);
 l_attribute_value_date date;
 l_attribute_value_num number;
 l_attributes_name varchar2(2000);
 l_null_attributes_name varchar2(2000);
 l_attribute_name varchar2(2000);
 l_in_range boolean ;
 l_rule_cnt number ;
 type list_rec is record (
   routing_category_id pqh_routing_categories.routing_category_id%type,
   range_name pqh_attribute_ranges.range_name%type,
   selected_flag boolean) ;
 type list_tab is table of list_rec
   index by binary_integer;
 l_hierarchy list_tab;
 l_error_flag boolean := FALSE;
 l_range_found_flag boolean;
 l_approver_flag boolean;
 l_rout_cat number;
 l_standard_setup number;
 l_proc             varchar2(256) := g_package||'list_range_check_adv';
begin
/* called when advanced setup is complete */
  hr_utility.set_location('Entering '||l_proc,10);
  p_status_flag := 0;
  if p_tran_cat_id is null then
     hr_utility.set_location('Transaction category reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
     hr_utility.raise_error;
  elsif p_from_clause is null then
     hr_utility.set_location('from clause reqd '||l_proc,30);
     hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
     hr_utility.raise_error;
  end if;
  delete_rout_crit(p_used_for => p_used_for);
  l_rule_cnt := 0;
  hr_utility.set_location('Finding unique rules for tran_cat : '||to_char(p_tran_cat_id)||l_proc,40);
  for i in c1 loop
     l_hierarchy(l_rule_cnt).routing_category_id := i.routing_category_id;
     l_hierarchy(l_rule_cnt).range_name := i.range_name;
     l_hierarchy(l_rule_cnt).selected_flag := TRUE ;
     l_rule_cnt := l_rule_cnt + 1;
     hr_utility.set_location('catg added'||to_char(i.routing_category_id)||i.range_name||l_proc,45);
  end loop;
  if l_rule_cnt >0 then
    hr_utility.set_location('fetch the values '||l_proc,50);
    for i in c2 loop
      hr_utility.set_location('inside loop for each list_identifying attribute '||l_proc,51);
      hr_utility.set_location('col_name 1 '||substr(i.column_name,1,50)||l_proc,52);
      hr_utility.set_location('col_name 2 '||substr(i.column_name,51,50)||l_proc,53);
      l_attribute_name := get_attribute_name(p_attribute_id   => i.attribute_id,
                                             p_transaction_id => p_trans_id,
                                             p_tran_cat_id    => p_tran_cat_id);
      hr_utility.set_location('att_name 1'||substr(l_attributes_name,1,50)||l_proc,54);
      hr_utility.set_location('att_name 2'||substr(l_attributes_name,51,50)||l_proc,55);
      if i.column_type ='V' or i.column_type ='C' then
         hr_utility.set_location('column type is '||i.column_type||l_proc,58);
         begin
           execute immediate 'select '||i.column_name||' '||p_from_clause
           into l_attribute_value_char ;
           hr_utility.set_location('value for attribute is '||l_attribute_value_char||l_proc,60 );
         exception
           when no_data_found then
                hr_utility.set_location('no data in trans table'||l_proc,70);
           when others then
                hr_utility.set_location('error in select table'||l_proc,70);
                hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                hr_utility.raise_error;
         end;
         if l_attributes_name is null then
            l_attributes_name := l_attribute_name ||' => '||l_attribute_value_char ;
         else
            if l_attribute_name is not null then
               l_attributes_name := l_attributes_name||','||l_attribute_name ||' => '||l_attribute_value_char;
            end if;
         end if;
         if l_attribute_value_char is null then
            if l_null_attributes_name is null then
               l_null_attributes_name := l_attribute_name;
            else
               if l_attribute_name is not null then
                  l_null_attributes_name := l_null_attributes_name||','||l_attribute_name;
               end if;
            end if;
         end if;
      elsif i.column_type ='D' then
         hr_utility.set_location('column type is '||i.column_type||l_proc,54);
         begin
           execute immediate 'select '||i.column_name||' '||p_from_clause
           into l_attribute_value_date ;
           hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_date,'DDMMRRRR')||l_proc,80 );
         exception
           when no_data_found then
                hr_utility.set_location('no data in trans table'||l_proc,90);
           when others then
                hr_utility.set_location('error in select table'||l_proc,70);
                hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                hr_utility.raise_error;
         end;
         if l_attributes_name is null then
            l_attributes_name := l_attribute_name ||' => '||to_char(l_attribute_value_date,'DDMMRRRR') ;
         else
            if l_attribute_name is not null then
               l_attributes_name := l_attributes_name||','||l_attribute_name ||' => '||to_char(l_attribute_value_date,'DDMMRRRR');
            end if;
         end if;
         if l_attribute_value_date is null then
            if l_null_attributes_name is null then
               l_null_attributes_name := l_attribute_name;
            else
               if l_attribute_name is not null then
                  l_null_attributes_name := l_null_attributes_name||','||l_attribute_name;
               end if;
            end if;
         end if;
      elsif i.column_type ='N' then
         hr_utility.set_location('column type is '||i.column_type||l_proc,54);
         begin
           execute immediate 'select '||i.column_name||' '||p_from_clause
           into l_attribute_value_num ;
           hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_num)||l_proc,100 );
         exception
           when no_data_found then
                hr_utility.set_location('no data in trans table'||l_proc,110);
           when others then
                hr_utility.set_location('error in select table'||l_proc,70);
                hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                hr_utility.raise_error;
         end;
         if l_attributes_name is null then
            l_attributes_name := l_attribute_name ||' => '||l_attribute_value_num ;
         else
            if l_attribute_name is not null then
               l_attributes_name := l_attributes_name||','||l_attribute_name ||' => '||l_attribute_value_num;
            end if;
         end if;
         if l_attribute_value_num is null then
            if l_null_attributes_name is null then
               l_null_attributes_name := l_attribute_name;
            else
               if l_attribute_name is not null then
                  l_null_attributes_name := l_null_attributes_name||','||l_attribute_name;
               end if;
            end if;
         end if;
      else
         hr_utility.set_location('column type is '||i.column_type||l_proc,54);
      end if;
      hr_utility.set_location('going for checking range allowed for attribute '||l_proc,111);
      for j in c3(i.attribute_id) loop
         insert_rout_crit(p_attribute_id   => i.attribute_id,
                          p_used_for       => p_used_for,
                          p_rule_name      => j.range_name,
                          p_attribute_type => i.column_type,
                          p_from_num       => j.from_number,
                          p_to_num         => j.to_number,
                          p_value_num      => l_attribute_value_num,
                          p_from_char      => j.from_char,
                          p_to_char        => j.to_char,
                          p_value_char     => l_attribute_value_char,
                          p_from_date      => j.from_date,
                          p_to_date        => j.to_date,
                          p_value_date     => l_attribute_value_date);
         if i.column_type = 'V' then
            hr_utility.set_location('varchar,range '||j.from_char||' to '||j.to_char||l_proc,120 );
            check_value_range(p_value_char => l_attribute_value_char,
                              p_from_char  => j.from_char,
                              p_to_char    => j.to_char,
                              p_in_range   => l_in_range,
                              p_can_approve => l_approver_flag);
         elsif i.column_type = 'N' then
            hr_utility.set_location('number,range '||to_char(j.from_number)||' to '||to_char(j.to_number)||l_proc,130 );
            check_value_range(p_value_num => l_attribute_value_num,
                              p_from_num  => j.from_number,
                              p_to_num    => j.to_number,
                              p_in_range  => l_in_range,
                              p_can_approve => l_approver_flag);
         elsif i.column_type = 'D' then
            hr_utility.set_location('number,range '||to_char(j.from_date,'ddmmRRRR')||' to '||to_char(j.to_date,'ddmmRRRR')||l_proc,140 );
            check_value_range(p_value_date => l_attribute_value_date,
                              p_from_date  => j.from_date,
                              p_to_date    => j.to_date,
                              p_in_range   => l_in_range,
                              p_can_approve => l_approver_flag);
         end if;
         if l_in_range = FALSE then
           hr_utility.set_location('Value not in range deselect range '||l_proc,150);
           for k in 0..(l_rule_cnt-1) loop
             if j.range_name = l_hierarchy(k).range_name and j.routing_category_id = l_hierarchy(k).routing_category_id then
                l_hierarchy(k).selected_flag := FALSE ;
		hr_utility.set_location('catg deleted'||to_char(j.routing_category_id)||j.range_name||l_proc,155);
             end if;
           end loop;
         end if;
      end loop;
    end loop;
    hr_utility.set_location('Picking selected range '||l_proc,160);
    l_range_found_flag := FALSE;
    for i in 0..(l_rule_cnt - 1) loop
       if l_hierarchy(i).selected_flag = TRUE then
          if l_range_found_flag = TRUE then
             -- hard coding the value of routing catg to 0
             p_routing_category_id := 0;
             p_status_flag := 11;
	     hr_utility.set_location('more than one routing category applicable '||l_proc,162);
             hr_utility.set_message(8302,'PQH_MORE_ROUTCAT_APPLICABLE');
             hr_utility.set_message_token('ATTRIBUTES', l_null_attributes_name);
          else
             p_routing_category_id := l_hierarchy(i).routing_category_id;
             p_range_name          := l_hierarchy(i).range_name;
             g_list_range          := p_range_name;
             l_range_found_flag    := TRUE ;
	     hr_utility.set_location('catg sele'||to_char(p_routing_category_id)||p_range_name||l_proc,165);
             delete_rout_crit(p_used_for       => p_used_for,
                              p_rule_name      => p_range_name);
          end if;
       end if;
    end loop;
    if p_status_flag = 0 and l_range_found_flag = TRUE then
       open c4;
       fetch c4 into p_member_cd,p_routing_list_id,p_pos_str_id;
       if c4%notfound then
          hr_utility.set_location('Rout_cat not exist '||to_char(p_routing_category_id)||l_proc,170);
          hr_utility.set_message(8302,'PQH_ROUTCAT_NOT_EXISTS');
          hr_utility.raise_error;
       else
          hr_utility.set_location('details member_cd is '||p_member_cd||' ,RL is'||to_char(p_routing_list_id)||' , PS is '||to_char(p_pos_str_id)||l_proc,180);
       end if;
       close c4;
    elsif p_status_flag = 11 then
       hr_utility.set_location('more than one range applicable'||l_proc,190);
    else
       list_rout_crit;
       hr_utility.set_location('no range applicable'||p_status_flag||l_proc,192);
       -- check standard setup can be taken or not if yes then call it.
       select count(*) into l_standard_setup
       from pqh_routing_categories
       where transaction_category_id = p_tran_cat_id
       and nvl(default_flag,'X') ='Y'
       and nvl(delete_flag,'N') = 'N'
       and nvl(enable_flag,'X') = 'Y';
       if nvl(l_standard_setup,0) > 0 then
           hr_utility.set_location('calling standard setup'||l_proc,200);
           list_range_check(p_tran_cat_id         => p_tran_cat_id,
                            p_member_cd           => p_member_cd,
                            p_used_for            => 'L',
                            p_routing_list_id     => p_routing_list_id,
                            p_pos_str_id          => p_pos_str_id,
                            p_routing_category_id => p_routing_category_id,
                            p_status_flag         => p_status_flag);
           hr_utility.set_location('out of standard setup'||l_proc,200);
       else
          -- hard coding the value of routing catg to 0
          p_routing_category_id := 0;
          p_status_flag := 11;
          hr_utility.set_message(8302,'PQH_NO_RANGE_SELECTED');
          hr_utility.set_message_token('ATTRIBUTES', l_attributes_name);
       end if;
    end if;
  else
-- no ranges are defined.
     hr_utility.set_location('no range defined'||l_proc,210);
     select count(*) into l_rout_cat
     from pqh_routing_categories
     where transaction_category_id = p_tran_cat_id
     and nvl(delete_flag,'N') = 'N'
     and nvl(enable_flag,'X') = 'Y';
     if l_rout_cat =1 then
        hr_utility.set_location('only one routing category with no ranges'||l_proc,220);
        p_range_name := '';
        g_list_range := '';
        begin
           select tc.member_cd,rc.routing_list_id,rc.position_structure_id,rc.routing_category_id
           into p_member_cd,p_routing_list_id,p_pos_str_id,p_routing_category_id
           from pqh_routing_categories rc, pqh_transaction_categories tc
           where tc.transaction_category_id = p_tran_cat_id
           and tc.transaction_category_id = rc.transaction_category_id
           and nvl(rc.enable_flag,'X') = 'Y'
           and nvl(rc.delete_flag,'N') = 'N' ;

           hr_utility.set_location('details member_cd is '||p_member_cd||' ,RL is'||to_char(p_routing_list_id)||' , PS is '||to_char(p_pos_str_id)||l_proc,240);
           p_status_flag := 0;
        exception
           when others then
              hr_utility.set_location('Rout_cat does not exist '||l_proc,230);
              hr_utility.set_message(8302,'PQH_ROUTCAT_NOT_EXISTS');
              hr_utility.raise_error;
        end;
     end if;
  end if;
  hr_utility.set_location('Exiting '||l_proc,1000);
exception when others then
                           p_member_cd            := null;
                           p_routing_list_id      := null;
                           p_pos_str_id           := null;
                           p_routing_category_id  := null;
                           p_range_name           := null;
                           p_status_flag          := null;
raise;
end list_range_check;

procedure assignment_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                                p_from_clause         in pqh_table_route.from_clause%type,
                                p_assignment_id       in per_all_assignments_f.assignment_id%type,
                                p_routing_category_id in pqh_routing_categories.routing_category_id%type,
				p_value_date          in date,
				p_used_for            in varchar2 default null,
                                p_applicable_flag        out nocopy boolean,
                                p_status_flag            out nocopy number,
                                p_can_approve            out nocopy boolean)
as
 cursor c1 is
        select distinct range_name, NVL(approver_flag,'N') approve_flag
        from pqh_attribute_ranges
        where assignment_id = p_assignment_id
        and routing_category_id = p_routing_category_id
        and nvl(enable_flag,'X') = 'Y'
        and nvl(delete_flag,'N') = 'N';
 cursor c2 is
        select att.attribute_id,att.attribute_name,att.column_name,att.column_type
        from pqh_attributes att, pqh_txn_category_attributes tca
        where att.attribute_id = tca.attribute_id and
	tca.transaction_category_id = p_tran_cat_id
        and tca.member_identifying_flag = 'Y'
        and nvl(att.enable_flag,'X') = 'Y';
 cursor c3(p_attribute_id number) is
        select range_name,from_char,to_char,from_date,to_date,from_number,to_number,approver_flag
        from pqh_attribute_ranges
        where attribute_id = p_attribute_id
        and assignment_id = p_assignment_id
        and routing_category_id = p_routing_category_id
        and nvl(delete_flag,'N') = 'N'
        and nvl(enable_flag,'X') = 'Y';
 l_attribute_value_char varchar2(2000);
 l_attribute_value_num number ;
 l_attribute_value_date date;
 type rule_rec is record (
   range_name varchar2(240),
   approve_flag boolean,
   selected_flag boolean ) ;
 type rule_tab is table of rule_rec
   index by binary_integer;
 l_assignment_rules rule_tab;
 l_rule_cnt   number ;
 l_in_range   boolean ;
 l_error_flag boolean := FALSE;
 l_approver_flag boolean;
 l_override_approver boolean;
 l_person_id  fnd_user.employee_id%type;
 l_proc       varchar2(256) := g_package||'assignment_applicable';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_tran_cat_id is null then
      hr_utility.set_location('Trans_cat reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_from_clause is null then
      hr_utility.set_location('From clause reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   end if;
-- deletes the old records of the used for type from the plsql table
   delete_rout_crit(p_used_for => p_used_for);
   p_applicable_flag := FALSE;
   p_status_flag := 0;
   l_rule_cnt := 0;
   for i in c1 loop
      l_assignment_rules(l_rule_cnt).range_name    := i.range_name ;
      l_assignment_rules(l_rule_cnt).selected_flag := TRUE ;
      --Added below if condition to check approval_flag
      --instead of defaulting to TRUE. Bug #2236178.
      if i.approve_flag = 'Y' then
        l_assignment_rules(l_rule_cnt).approve_flag  := TRUE ;
      else
        l_assignment_rules(l_rule_cnt).approve_flag  := FALSE ;
      end if;
      l_rule_cnt := l_rule_cnt + 1 ;
   end loop;
   hr_utility.set_location(' '||to_char(l_rule_cnt)||' rules for member '||l_proc,40);
   if l_rule_cnt <> 0 then
      for i in c2 loop
         hr_utility.set_location('Attribute is '||to_char(i.attribute_id)||l_proc,50 );
         if i.column_type ='V' or i.column_type ='C' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_char ;
               hr_utility.set_location('value for attribute is '||l_attribute_value_char||l_proc,60 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='D' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_date ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_date,'DDMMRRRR')||l_proc,70 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='N' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_num ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_num)||l_proc,80 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         end if;
         for j in c3(i.attribute_id) loop
            hr_utility.set_location('Picking ranges for attribute '||to_char(i.attribute_id)||l_proc,90 );
            insert_rout_crit(p_attribute_id   => i.attribute_id,
                             p_used_for       => p_used_for,
                             p_attribute_type => i.column_type,
                             p_from_num       => j.from_number,
                             p_to_num         => j.to_number,
                             p_value_num      => l_attribute_value_num,
                             p_from_char      => j.from_char,
                             p_to_char        => j.to_char,
                             p_value_char     => l_attribute_value_char,
                             p_from_date      => j.from_date,
                             p_to_date        => j.to_date,
                             p_value_date     => l_attribute_value_date);
            if i.column_type = 'V' or i.column_type = 'C' then
               hr_utility.set_location('varchar ,range is '||j.from_char||' to '||j.to_char||l_proc,100 );
               check_value_range(p_value_char => l_attribute_value_char,
                                 p_from_char  => j.from_char,
                                 p_to_char    => j.to_char,
                                 p_in_range   => l_in_range,
                                 p_can_approve => l_approver_flag);
            elsif i.column_type = 'N' then
               hr_utility.set_location('number, range is '||to_char(j.from_number)||' to '||to_char(j.to_number)||l_proc,110 );
               check_value_range(p_value_num => l_attribute_value_num,
                                 p_from_num  => j.from_number,
                                 p_to_num    => j.to_number,
                                 p_in_range  => l_in_range,
                                 p_can_approve => l_approver_flag);
            elsif i.column_type = 'D' then
               hr_utility.set_location('date,range '||to_char(j.from_date,'ddmmRRRR')||' to '||to_char(j.to_date,'ddmmRRRR')||l_proc,120 );
               check_value_range(p_value_date => l_attribute_value_date,
                                 p_from_date  => j.from_date,
                                 p_to_date    => j.to_date,
                                 p_in_range   => l_in_range,
                                 p_can_approve => l_approver_flag);
            end if;
            for k in 0..(l_rule_cnt-1) loop
               if l_assignment_rules(k).range_name = j.range_name then
                  if l_in_range = TRUE then
                     if upper(j.approver_flag) = 'N' or l_approver_flag = FALSE then
                        l_assignment_rules(k).approve_flag := FALSE ;
                     end if;
                  else
                     l_assignment_rules(k).selected_flag := FALSE ;
                     hr_utility.set_location('deleting the range'||l_proc,122);
                  end if;
               end if;
            end loop;
         end loop;
      end loop;
      for i in 0..(l_rule_cnt-1) loop
          if l_assignment_rules(i).selected_flag = TRUE then
             if p_used_for = 'C' then
                g_current_member_range := l_assignment_rules(i).range_name;
             elsif p_used_for = 'N' then
                g_next_member_range := l_assignment_rules(i).range_name;
             end if;
             delete_rout_crit(p_used_for => p_used_for,
                              p_rule_name => l_assignment_rules(i).range_name);
             p_can_approve := l_assignment_rules(i).approve_flag ;
             p_applicable_flag := TRUE;
          end if;
      end loop;
   else
      p_can_approve := FALSE;
      p_applicable_flag := TRUE;
   end if;
   if p_can_approve = FALSE then
      l_override_approver := override_approver(p_member_cd           => 'S',
                                               p_routing_category_id => p_routing_category_id,
                                               p_assignment_id       => p_assignment_id,
                                               p_role_id             => '',
                                               p_user_id             => '',
                                               p_position_id         => '');
      if l_override_approver then
         p_can_approve := TRUE;
      end if;
   end if;
   if p_applicable_flag = TRUE then
      person_on_assignment(p_assignment_id => p_assignment_id,
                           p_value_date    => p_value_date,
                           p_person_id     => l_person_id);
      hr_utility.set_location('Person on assignment is '||to_char(l_person_id)||l_proc,140);
      if l_person_id is not null then
         person_has_user(p_person_id       => l_person_id,
                         p_value_date      => p_value_date,
                         p_applicable_flag => p_applicable_flag);
         if p_applicable_flag = TRUE then
            hr_utility.set_location('Person has user defined'||l_proc,150);
         else
            hr_utility.set_location('Person has no user '||l_proc,160);
         end if;
      else
         hr_utility.set_location('assignment has no person attached',180);
         p_applicable_flag := FALSE;
      end if;
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                                p_applicable_flag        := null;
                                p_status_flag            := null;
                                p_can_approve            := null;
raise;
end assignment_applicable;
-- Added for Tar 4085705.996
Procedure is_std_rule (p_routing_category_id  in number,
                       p_position_id          in number,
                       p_range_name           in varchar2,
                       p_approver_flag        out nocopy varchar2,
                       p_is_std_rule_flag     out nocopy varchar2) is
--
Cursor csr_std_rule is
 Select attribute_id,nvl(approver_flag,'N') approver_flag
        from pqh_attribute_ranges
        where position_id = p_position_id
        and routing_category_id = p_routing_category_id
        and nvl(delete_flag,'N') = 'N'
        and nvl(enable_flag,'X') ='Y'
        and range_name = p_range_name;
--
 l_attr pqh_attribute_ranges.attribute_id%type;
 l_appr pqh_attribute_ranges.approver_flag%type;
 l_cnt number(15);
 l_proc varchar2(72) := 'is_std_rule';
--
Begin
--
   hr_utility.set_location('Entering '||l_proc,5);
   l_cnt := 0;
   p_is_std_rule_flag := 'N';
   p_approver_flag  := 'N';
   For attr_rec in csr_std_rule loop
       l_cnt := l_cnt + 1;
       l_attr := attr_rec.attribute_id;
       l_appr := attr_rec.approver_flag;
   End loop;

   If l_cnt = 1  and l_attr is null then
      p_is_std_rule_flag := 'Y';
      p_approver_flag  := l_appr;
   else
      p_is_std_rule_flag := 'N';
      p_approver_flag  := 'Y';
   End if;
   hr_utility.set_location('Exiting '||l_proc,10000);
--
End;
-- End of Added for Tar 4085705.996



procedure ps_element_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                                p_from_clause         in pqh_table_route.from_clause%type,
                                p_position_id         in pqh_position_transactions.position_id%type,
                                p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                p_value_date          in date,
                                p_used_for            in varchar2 default null,
                                p_applicable_flag        out nocopy boolean,
                                p_status_flag            out nocopy number,
                                p_can_approve            out nocopy boolean) as
 cursor c1 is select distinct range_name
              from pqh_attribute_ranges
              where position_id = p_position_id
              and routing_category_id = p_routing_category_id
              and nvl(delete_flag,'N') = 'N'
              and nvl(enable_flag,'X') ='Y';
 cursor c2 is
        select att.attribute_id,att.attribute_name,att.column_name,att.column_type
        from pqh_attributes att,pqh_txn_category_attributes tca
        where att.attribute_id = tca.attribute_id and
	tca.transaction_category_id = p_tran_cat_id
        and tca.member_identifying_flag = 'Y'
        and nvl(att.enable_flag,'X') = 'Y';
 cursor c3(p_attribute_id number) is
        select range_name,from_char,to_char,from_date,to_date,from_number,to_number,approver_flag
        from pqh_attribute_ranges
        where attribute_id = p_attribute_id
        and position_id = p_position_id
        and routing_category_id = p_routing_category_id
        and nvl(delete_flag,'N') = 'N'
        and nvl(enable_flag,'X') ='Y';
 l_attribute_value_char varchar2(2000);
 l_attribute_value_num number ;
 l_attribute_value_date date;
 type rule_rec is record (
   range_name varchar2(240),
   approve_flag boolean,
   selected_flag boolean ) ;
 type rule_tab is table of rule_rec
   index by binary_integer;
 l_position_rules rule_tab;
 l_rule_cnt       number := 0 ;
 l_in_range       boolean ;
 l_error_flag     boolean := FALSE;
 l_approver_flag boolean;
 l_override_approver boolean;
 --
 -- Added for Tar 4085705.996
 l_appr pqh_attribute_ranges.approver_flag%type;
 l_std_rule varchar2(10);
 --
 -- End of Added for Tar 4085705.996
 l_proc           varchar2(256) := g_package||'ps_element_applicable';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   p_applicable_flag := FALSE;
   p_status_flag := 0;
   if p_tran_cat_id is null then
      hr_utility.set_location('trans_cat reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_from_clause is null then
      hr_utility.set_location('from clause reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   end if;

   for i in c1 loop
      l_position_rules(l_rule_cnt).range_name := i.range_name ;

      -- Added for Tar 4085705.996

      is_std_rule(p_routing_category_id, p_position_id, i.range_name, l_appr, l_std_rule);
      If l_std_rule = 'Y' then
         If l_appr = 'Y' then
            l_position_rules(l_rule_cnt).approve_flag := TRUE ;
         Else
            l_position_rules(l_rule_cnt).approve_flag := FALSE ;
         End if;
      Else
         l_position_rules(l_rule_cnt).approve_flag := TRUE ;
      End if;
      -- l_position_rules(l_rule_cnt).approve_flag := TRUE ;
      -- End of Added for Tar 4085705.996

      l_position_rules(l_rule_cnt).selected_flag := TRUE ;
      l_rule_cnt := l_rule_cnt + 1 ;
   end loop;
   hr_utility.set_location(' '||to_char(l_rule_cnt)||' rules for member '||l_proc,40);
-- deletes the old records of the used for type from the plsql table
   delete_rout_crit(p_used_for => p_used_for);
   if l_rule_cnt <> 0 then
      hr_utility.set_location('ranges defined '||l_proc,50);
      for i in c2 loop
         hr_utility.set_location('Attribute is '||to_char(i.attribute_id)||l_proc,60 );
         if i.column_type ='V' or i.column_type ='C' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_char ;
               hr_utility.set_location('value for attribute is '||l_attribute_value_char||l_proc,70 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='D' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_date ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_date,'DDMMRRRR')||l_proc,80 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='N' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_num ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_num)||l_proc,90 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         end if;
         for j in c3(i.attribute_id) loop
            insert_rout_crit(p_attribute_id   => i.attribute_id,
                             p_used_for       => p_used_for,
                             p_attribute_type => i.column_type,
                             p_from_num       => j.from_number,
                             p_to_num         => j.to_number,
                             p_value_num      => l_attribute_value_num,
                             p_from_char      => j.from_char,
                             p_to_char        => j.to_char,
                             p_value_char     => l_attribute_value_char,
                             p_from_date      => j.from_date,
                             p_to_date        => j.to_date,
                             p_value_date     => l_attribute_value_date);
            if i.column_type = 'V' or i.column_type = 'C' then
               hr_utility.set_location('varchar,range '||j.from_char||' to '||j.to_char||l_proc,100 );
               check_value_range(p_value_char => l_attribute_value_char,
                                 p_from_char  => j.from_char,
                                 p_to_char    => j.to_char,
                                 p_in_range   => l_in_range,
                                 p_can_approve => l_approver_flag);
            elsif i.column_type = 'N' then
               hr_utility.set_location('number,range '||to_char(j.from_number)||' to '||to_char(j.to_number)||l_proc,110 );
               hr_utility.set_location('number,value '||to_char(l_attribute_value_num)||l_proc,111 );
               check_value_range(p_value_num => l_attribute_value_num,
                                 p_from_num  => j.from_number,
                                 p_to_num    => j.to_number,
                                 p_in_range  => l_in_range,
                                 p_can_approve => l_approver_flag);
            elsif i.column_type = 'D' then
               hr_utility.set_location('date,range '||to_char(j.from_date,'ddmmRRRR')||' to '||to_char(j.to_date,'ddmmRRRR')||l_proc,120 );
               check_value_range(p_value_date => l_attribute_value_date,
                                 p_from_date  => j.from_date,
                                 p_to_date    => j.to_date,
                                 p_in_range   => l_in_range,
                                 p_can_approve => l_approver_flag);
            end if;
            for k in 0..(l_rule_cnt-1) loop
               if l_position_rules(k).range_name = j.range_name then
                  hr_utility.set_location('range match '||l_proc,122);
                  if l_in_range = TRUE then
	             hr_utility.set_location('in range, '||l_proc,123);
                     if upper(j.approver_flag) = 'N' or l_approver_flag = FALSE then
                        l_position_rules(k).approve_flag := FALSE ;
                     end if;
                  else
                     hr_utility.set_location('not in range, deselecting'||l_proc,125);
                     l_position_rules(k).selected_flag := FALSE ;
                     hr_utility.set_location('deleting the range'||l_proc,122);
                  end if;
               end if;
            end loop;
         end loop;
      end loop ;
      for i in 0..(l_rule_cnt-1) loop
         if l_position_rules(i).selected_flag = TRUE then
            if p_used_for = 'C' then
               g_current_member_range := l_position_rules(i).range_name;
            elsif p_used_for = 'N' then
               g_next_member_range := l_position_rules(i).range_name;
            end if;
            delete_rout_crit(p_used_for => p_used_for,
                             p_rule_name => l_position_rules(i).range_name);
            p_can_approve := l_position_rules(i).approve_flag ;
            p_applicable_flag := TRUE;
         end if;
      end loop;
   else
      hr_utility.set_location('No ranges, position applicable '||l_proc,127);
      p_can_approve := FALSE;
      p_applicable_flag := TRUE;
   end if;
   if p_can_approve = FALSE then
      hr_utility.set_location('position is not defined as approver '||l_proc,129);
      l_override_approver := override_approver(p_member_cd           => 'P',
                                               p_routing_category_id => p_routing_category_id,
                                               p_assignment_id       => '',
                                               p_role_id             => '',
                                               p_user_id             => '',
                                               p_position_id         => p_position_id);
      if l_override_approver then
         p_can_approve := TRUE;
         hr_utility.set_location('position is defined as override approver '||l_proc,129);
      end if;
   end if;
   if p_applicable_flag = TRUE then
      position_occupied(p_position_id     => p_position_id,
                        p_value_date      => p_value_date,
                        p_applicable_flag => p_applicable_flag);
      if p_applicable_flag = TRUE then
         hr_utility.set_location('Position occupied by user '||l_proc,130);
      else
         hr_utility.set_location('Position unoccupied '||l_proc,140);
      end if;
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                                p_applicable_flag        := null;
                                p_status_flag            := null;
                                p_can_approve            := null;
raise;
end ps_element_applicable;

procedure rl_member_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                               p_from_clause         in pqh_table_route.from_clause%type,
                               p_member_id           in pqh_routing_list_members.routing_list_member_id%type,
                               p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                               p_used_for            in varchar2 default null,
                               p_applicable_flag        out nocopy boolean,
                               p_status_flag            out nocopy number,
                               p_can_approve            out nocopy boolean) as
 cursor c1 is select distinct range_name, NVL(approver_flag,'N') approve_flag
              from pqh_attribute_ranges
              where routing_list_member_id = p_member_id
              and routing_category_id = p_routing_category_id
              and nvl(delete_flag,'N') = 'N'
              and nvl(enable_flag,'X') ='Y';
 cursor c2 is
        select att.attribute_id,att.attribute_name,att.column_name,att.column_type
        from pqh_attributes att, pqh_txn_category_attributes tca
        where att.attribute_id = tca.attribute_id and
	tca.transaction_category_id = p_tran_cat_id
        and tca.member_identifying_flag = 'Y'
        and nvl(att.enable_flag,'X') = 'Y';
 cursor c3(p_attribute_id number) is
        select range_name,from_char,to_char,from_date,to_date,from_number,to_number,approver_flag
        from pqh_attribute_ranges
        where attribute_id = p_attribute_id
        and routing_list_member_id = p_member_id
        and routing_category_id = p_routing_category_id
        and nvl(delete_flag,'N') = 'N'
        and nvl(enable_flag,'X') ='Y';
 cursor c4 is select approver_flag
              from pqh_routing_list_members
              where routing_list_member_id = p_member_id
              and nvl(enable_flag,'X') = 'Y';
 l_attribute_value_char varchar2(2000);
 l_attribute_value_num number ;
 l_attribute_value_date date;
 type rule_rec is record (
   range_name varchar2(240),
   approve_flag boolean,
   selected_flag boolean ) ;
 type rule_tab is table of rule_rec
   index by binary_integer;
 l_member_rules        rule_tab;
 l_rule_cnt            number := 0 ;
 l_in_range            boolean ;
 l_member_approve_flag pqh_routing_list_members.approver_flag%type;
 l_error_flag          boolean := FALSE;
 l_approver_flag boolean;
 l_override_approver boolean;
 l_role_id number;
 l_user_id number;
 l_proc                varchar2(256) := g_package||'rl_member_applicable';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   p_applicable_flag := FALSE ;
   p_status_flag := 0;
   if p_tran_cat_id is null then
      hr_utility.set_location('Trans_cat reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_from_clause is null then
      hr_utility.set_location('From clause reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   end if;
   for i in c1 loop
      l_member_rules(l_rule_cnt).range_name := i.range_name ;
      l_member_rules(l_rule_cnt).selected_flag := TRUE ;
      --Added below if condition to check approval_flag
      --instead of defaulting to TRUE. Bug #2236178.
      if i.approve_flag = 'Y' then
        l_member_rules(l_rule_cnt).approve_flag := TRUE ;
      else
        l_member_rules(l_rule_cnt).approve_flag := FALSE ;
      end if;
      l_rule_cnt := l_rule_cnt + 1 ;
   end loop;

-- deletes the old records of the used for type from the plsql table
   delete_rout_crit(p_used_for => p_used_for);
   hr_utility.set_location(' '||to_char(l_rule_cnt)||' rules for member '||l_proc,40);
   if l_rule_cnt <> 0 then
      hr_utility.set_location('ranges defined for member'||l_proc,50);
      for i in c2 loop
         hr_utility.set_location('Attribute is '||to_char(i.attribute_id)||l_proc,60 );
         if i.column_type ='V' or i.column_type ='C' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,61);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_char ;
               hr_utility.set_location('value for attribute is '||l_attribute_value_char||l_proc,70 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,71);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,72);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='D' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,75);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_date ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_date,'DDMMRRRR')||l_proc,80 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,81);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,82);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         elsif i.column_type ='N' then
            hr_utility.set_location('column type is '||i.column_type||l_proc,85);
            begin
               execute immediate 'select '||i.column_name||' '||p_from_clause
               into l_attribute_value_num ;
               hr_utility.set_location('value for attribute is '||to_char(l_attribute_value_num)||l_proc,90 );
            exception
               when no_data_found then
                  hr_utility.set_location('no data in trans table'||l_proc,91);
               when others then
                  hr_utility.set_location('error in select table'||l_proc,92);
                  hr_utility.set_message(8302,'PQH_SELECT_FAILED');
                  hr_utility.raise_error;
            end;
         end if;
         for j in c3(i.attribute_id) loop
            insert_rout_crit(p_attribute_id   => i.attribute_id,
                             p_used_for       => p_used_for,
                             p_attribute_type => i.column_type,
                             p_from_num       => j.from_number,
                             p_to_num         => j.to_number,
                             p_value_num      => l_attribute_value_num,
                             p_from_char      => j.from_char,
                             p_to_char        => j.to_char,
                             p_value_char     => l_attribute_value_char,
                             p_from_date      => j.from_date,
                             p_to_date        => j.to_date,
                             p_value_date     => l_attribute_value_date);
            hr_utility.set_location('ranges for attribute '||to_char(i.attribute_id)||l_proc,100 );
            if i.column_type = 'V' or i.column_type = 'C' then
               hr_utility.set_location('varchar,range '||j.from_char||' to '||j.to_char||l_proc,110 );
               check_value_range(p_value_char     => l_attribute_value_char ,
                                 p_from_char      => j.from_char,
                                 p_to_char        => j.to_char,
                                 p_in_range       => l_in_range,
                                 p_can_approve => l_approver_flag) ;
            elsif i.column_type = 'N' then
               hr_utility.set_location('number,range'||to_char(j.from_number)||' to '||to_char(j.to_number)||l_proc,120 );
               check_value_range(p_value_num => l_attribute_value_num,
                                 p_from_num  => j.from_number,
                                 p_to_num    => j.to_number,
                                 p_in_range     => l_in_range,
                                 p_can_approve => l_approver_flag) ;
            elsif i.column_type = 'D' then
               hr_utility.set_location('date,range'||to_char(j.from_date,'ddmmRRRR')||' to '||to_char(j.to_date,'ddmmRRRR')||l_proc,130 );
               check_value_range(p_value_date => l_attribute_value_date,
                                 p_from_date  => j.from_date,
                                 p_to_date    => j.to_date,
                                 p_in_range   => l_in_range,
                                 p_can_approve => l_approver_flag) ;
            end if;
            for k in 0..(l_rule_cnt-1) loop
               if l_member_rules(k).range_name = j.range_name then
                  if l_in_range= TRUE then
                     if nvl(upper(j.approver_flag),'N') = 'N' or l_approver_flag = FALSE then
                        l_member_rules(k).approve_flag := FALSE ;
                     end if;
                  else
                     l_member_rules(k).selected_flag := FALSE ;
                     hr_utility.set_location('not in range, deselecting'||l_member_rules(k).range_name||l_proc,132);
                     hr_utility.set_location('deleting the range'||l_proc,122);
                  end if;
                  exit;
               end if;
            end loop;
         end loop;
      end loop;
      for k in 0..(l_rule_cnt-1) loop
         if l_member_rules(k).selected_flag = TRUE then
            if l_member_rules(k).approve_flag = TRUE then
               p_can_approve := TRUE;
               hr_utility.set_location('can approve '||l_proc,133);
            else
               p_can_approve := FALSE;
               hr_utility.set_location('cant approve '||l_proc,134);
            end if;
            if p_used_for = 'C' then
               g_current_member_range := l_member_rules(k).range_name;
            elsif p_used_for = 'N' then
               g_next_member_range := l_member_rules(k).range_name;
            end if;
            delete_rout_crit(p_used_for => p_used_for,
                             p_rule_name => l_member_rules(k).range_name);
            p_applicable_flag := TRUE;
            hr_utility.set_location('range match found '||l_member_rules(k).range_name||l_proc,135);
            exit;
         else
            hr_utility.set_location('cant approve '||l_proc,136);
            p_can_approve := FALSE;
            p_applicable_flag := FALSE;
         end if;
      end loop;
   else
      hr_utility.set_location('no rules '||l_proc,137) ;
      p_applicable_flag := TRUE;
      open c4;
      fetch c4 into l_member_approve_flag;
      if c4%notfound then
         hr_utility.set_location('error RL_member '||to_char(p_member_id)||l_proc,140) ;
      else
         hr_utility.set_location('going to check approve '||l_proc,142);
         if upper(l_member_approve_flag) = 'Y' then
            p_can_approve := TRUE ;
            hr_utility.set_location('can approve '||l_proc,143);
         else
            p_can_approve := FALSE ;
            hr_utility.set_location('cant approve '||l_proc,144);
         end if;
      end if;
      close c4;
   end if;
   if p_can_approve = FALSE then
      hr_utility.set_location('member is not defined as approver '||l_proc,129);
      get_role_user(p_member_id => p_member_id,
                    p_user_id   => l_user_id,
                    p_role_id   => l_role_id );
      l_override_approver := override_approver(p_member_cd           => 'R',
                                               p_routing_category_id => p_routing_category_id,
                                               p_assignment_id       => '',
                                               p_role_id             => l_role_id,
                                               p_user_id             => l_user_id,
                                               p_position_id         => '');
      if l_override_approver then
         p_can_approve := TRUE;
         hr_utility.set_location('member is defined as override approver '||l_proc,129);
      end if;
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                                p_applicable_flag        := null;
                                p_status_flag            := null;
                                p_can_approve            := null;
raise;
end rl_member_applicable;

procedure su_next_user(p_cur_assignment_id in number,
                       p_value_date        in date,
                       p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                       p_status_flag          out nocopy number) as
 l_person_id  per_all_assignments_f.supervisor_id%type;
 l_position_id  per_all_assignments_f.position_id%type;
 cursor c2 is select supervisor_id
              from per_all_assignments_f
              where assignment_id = p_cur_assignment_id
              and primary_flag ='Y'
              and p_value_date between effective_start_date and effective_end_date;
  l_proc       varchar2(256) := g_package||'su_next_user';
begin
  hr_utility.set_location('Entering '||l_proc,10);
  open c2;
  fetch c2 into l_person_id;
  if c2%notfound then
     hr_utility.set_location('status eol '||l_proc,30);
     p_status_flag := 1 ;
  else
     hr_utility.set_location('found supervisor '||l_proc,40);
     if l_person_id is null then
        hr_utility.set_location('no supervisor defined'||l_proc,42);
        p_status_flag := 1 ;
     else
        hr_utility.set_location('supervisor exists'||l_proc,45);
        get_primary_asg_details(p_person_id      => l_person_id,
                                p_effective_date => p_value_date,
                                p_assignment_id  => p_assignment_id,
                                p_position_id    => l_position_id );
        if p_assignment_id is null then
           hr_utility.set_location('supervisor donot have assignment '||l_proc,50);
           hr_utility.set_message(8302,'PQH_SUPER_NO_ASG');
           hr_utility.raise_error;
        else
           hr_utility.set_location('supervisor assignment is '||to_char(p_assignment_id)||l_proc,60);
           p_status_flag := 0;
        end if;
     end if;
  end if;
  close c2;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                       p_assignment_id        := null;
                       p_status_flag          := null;
raise;
end su_next_user;

procedure user_assignment(p_value_date        in date,
                          p_user_id           in out nocopy fnd_user.user_id%type,
                          p_user_name         in out nocopy fnd_user.user_name%type,
                          p_person_id            out nocopy fnd_user.employee_id%type,
                          p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type) as
  l_error_flag boolean := FALSE;
  l_person_name varchar2(240);
  l_user_id fnd_user.user_id%type := p_user_id;
  l_user_name fnd_user.user_name%type := p_user_name;
  l_position_id number;
  l_proc       varchar2(256) := g_package||'user_assignment';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_user_id is null and p_user_name is null then
      hr_utility.set_location('Userid or user name reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
      hr_utility.raise_error;
   elsif p_user_id is not null then
      get_user_id_details(p_user_id     => p_user_id,
                          p_user_name   => p_user_name,
                          p_employee_id => p_person_id);
   elsif p_user_name is not null then
      get_user_name_details(p_user_id     => p_user_id,
                            p_user_name   => p_user_name,
                            p_employee_id => p_person_id);
   end if;
   hr_utility.set_location('Value date is '||to_char(p_value_date,'dd/MM/RRRR')||l_proc,22);
   if p_person_id is null then
      if p_user_name is null or p_user_id is null then
         hr_utility.set_location('details not found for userid'||to_char(p_user_id)||',name '||p_user_name||l_proc,30 );
         hr_utility.set_message(8302,'PQH_INVALID_USER_ID');
         hr_utility.raise_error;
      else
         hr_utility.set_location('no employee defined for user '||l_proc,90);
         hr_utility.set_message(8302,'PQH_EMP_NOTFOR_USER');
         hr_utility.raise_error;
      end if;
   else
      hr_utility.set_location('employee # is '||to_char(p_person_id)||l_proc,40 );
      l_person_name := hr_general.decode_person_name(p_person_id =>p_person_id);
      get_primary_asg_details(p_person_id      => p_person_id,
                              p_effective_date => p_value_date,
                              p_assignment_id  => p_assignment_id,
                              p_position_id    => l_position_id );
      if p_assignment_id is null then
         hr_utility.set_location('primary assignment not found '||l_proc,50);
         hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
         hr_utility.set_message_token('PERSON',l_person_name);
         hr_utility.raise_error;
      else
         hr_utility.set_location('details found '||l_proc,52);
      end if;
   end if;
   hr_utility.set_location('Exiting '||l_proc,200);
   exception when others then
                          p_user_id           := l_user_id;
                          p_user_name         := l_user_name;
                          p_person_id            := null;
                          p_assignment_id        := null;
              raise;
end user_assignment ;

procedure user_position_and_assignment(p_value_date        in date,
                                       p_user_id           in out nocopy fnd_user.user_id%type,
                                       p_user_name         in out nocopy fnd_user.user_name%type,
                                       p_person_id            out nocopy fnd_user.employee_id%type,
                                       p_position_id          out nocopy pqh_position_transactions.position_id%type,
                                       p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type) as
  l_error_flag boolean := FALSE;
  l_proc       varchar2(256) := g_package||'user_position_and_assignment';
  l_effective_date  date;
  l_person_name varchar2(240);
  l_user_id fnd_user.user_id%type := p_user_id;
  l_user_name fnd_user.user_name%type := p_user_name;
  l_position   varchar2(240);
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_user_id is null and p_user_name is null then
      hr_utility.set_location('Userid or user name reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
      hr_utility.raise_error;
   elsif p_user_id is not null then
      get_user_id_details(p_user_id     => p_user_id,
                          p_user_name   => p_user_name,
                          p_employee_id => p_person_id);
   elsif p_user_name is not null then
      get_user_name_details(p_user_id     => p_user_id,
                            p_user_name   => p_user_name,
                            p_employee_id => p_person_id);
   end if;
   hr_utility.set_location('Value date is '||to_char(p_value_date,'dd/MM/RRRR')||l_proc,22);
   if p_person_id is null then
      if p_user_name is null or p_user_id is null then
         hr_utility.set_location('details not found for userid'||to_char(p_user_id)||',name '||p_user_name||l_proc,30 );
         hr_utility.set_message(8302,'PQH_INVALID_USER_ID');
         hr_utility.raise_error;
      else
         hr_utility.set_location('no employee defined for user '||l_proc,90);
         hr_utility.set_message(8302,'PQH_EMP_NOTFOR_USER');
         hr_utility.raise_error;
      end if;
   else
      hr_utility.set_location('employee # is '||to_char(p_person_id)||l_proc,40 );
      l_person_name := hr_general.decode_person_name(p_person_id =>p_person_id);
      get_primary_asg_details(p_person_id      => p_person_id,
                              p_effective_date => p_value_date,
                              p_assignment_id  => p_assignment_id,
                              p_position_id    => p_position_id );
      if p_assignment_id is null then
         hr_utility.set_location('primary assignment not found '||l_proc,50);
         hr_utility.set_message(8302,'PQH_NO_PRIMARY_ASSIGNMENT');
         hr_utility.set_message_token('PERSON',l_person_name);
         hr_utility.raise_error;
      else
         hr_utility.set_location('details found '||l_proc,52);
         if p_position_id is null then
            hr_utility.set_location('primary assignment not for position '||l_proc,54);
            hr_utility.set_message(8302,'PQH_PRIMARY_ASG_NOT_POS');
            hr_utility.set_message_token('PERSON',l_person_name);
            hr_utility.raise_error;
         else
            hr_utility.set_location('position found '||p_position_id||l_proc,60);
            l_effective_date := hr_general.get_position_date_end(p_position_id => p_position_id);
            if (l_effective_date is null or l_effective_date > trunc(sysdate)) then
               hr_utility.set_location('valid position '||l_proc,61);
            else
               hr_utility.set_location('Position Eliminated '||l_proc,62);
               hr_utility.set_message(8302,'PQH_POSITION_ELIMINATED');
               l_position  := hr_general.decode_position_latest_name(p_position_id);
               hr_utility.set_message_token('POSITION',l_position);
               hr_utility.raise_error;
            end if;
         end if;
      end if;
   end if;
   hr_utility.set_location('Exiting '||l_proc,200);
   exception
      when others then
         p_user_id           := l_user_id;
         p_user_name         := l_user_name;
         p_person_id            := null;
         p_position_id		 := null;
         p_assignment_id        := null;
raise;
end user_position_and_assignment ;

procedure prepare_from_clause(p_tran_cat_id in pqh_transaction_categories.transaction_category_id%type,
                              p_trans_id    in pqh_routing_history.transaction_id%type,
                              p_from_clause    out nocopy pqh_table_route.from_clause%type ) as
  cursor c1 is select rou.from_clause,rou.where_clause
               from pqh_transaction_categories cat ,pqh_table_route rou
               where cat.transaction_category_id = p_tran_cat_id
               and cat.consolidated_table_route_id = rou.table_route_id ;
  l_from_clause   pqh_table_route.from_clause%type ;
  l_where_clause_in  pqh_table_route.where_clause%type ;
  l_where_clause_out  pqh_table_route.where_clause%type ;
  l_error_flag    boolean := FALSE ;
  l_proc          varchar2(256) := g_package||'prepare_from_clause';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_tran_cat_id is null then
      hr_utility.set_location('Transaction category id reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   elsif p_trans_id is null then
      hr_utility.set_location('Transaction id reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_FROM_CLAUSE_NULL');
      hr_utility.raise_error;
   end if;
   -- hr_utilIty.set_location('tran_cat passed is '||to_char(p_tran_cat_id)||l_proc,40);
   -- hr_utility.set_location('transid  passed is '||to_char(p_trans_id)||l_proc,40);
   open c1;
   fetch c1 into l_from_clause,l_where_clause_in;
   if c1%notfound then
      hr_utility.set_location('error for '||to_char(p_tran_cat_id)||l_proc,40);
   else
      hr_utility.set_location('From clause '||substr(l_from_clause,1,45)||l_proc,50);
      hr_utility.set_location('where clause '||substr(l_where_clause_in,1,45)||l_proc,55);
/*
    l_where_clause_in does not contain where and has column id which is
    to be replaced by the transaction id . This where clause is to be
    then linked with the l_from_clause to form the p_from_clause
*/
--    p_from_clause := replace(l_from_clause,'<PK>',p_trans_id);
      pqh_refresh_data.replace_where_params(
      p_where_clause_in  => l_where_clause_in,
      p_txn_tab_flag     => 'Y',
      p_txn_id           => p_trans_id,
      p_where_clause_out => l_where_clause_out);
      p_from_clause := 'from '||l_from_clause||' where '||l_where_clause_out ;
   end if;
   close c1;
   hr_utility.set_location('From :  1'||substr(p_from_clause,1,45)||l_proc,61);
   hr_utility.set_location('From :  2'||substr(p_from_clause,46,45)||l_proc,62);
   hr_utility.set_location('From :  3'||substr(p_from_clause,91,45)||l_proc,63);
   hr_utility.set_location('From :  4'||substr(p_from_clause,136,45)||l_proc,64);
   hr_utility.set_location('From :  5'||substr(p_from_clause,181,45)||l_proc,65);
   hr_utility.set_location('From :  6'||substr(p_from_clause,226,45)||l_proc,66);
   hr_utility.set_location('From :  7'||substr(p_from_clause,271,45)||l_proc,67);
   hr_utility.set_location('From :  8'||substr(p_from_clause,316,45)||l_proc,68);
   hr_utility.set_location('From :  9'||substr(p_from_clause,361,45)||l_proc,69);
   hr_utility.set_location('From : 10'||substr(p_from_clause,406,45)||l_proc,70);
   hr_utility.set_location('From : 11'||substr(p_from_clause,451,45)||l_proc,71);
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
p_from_clause := null;
raise;
end prepare_from_clause;

procedure check_value_range(p_from_num  in pqh_attribute_ranges.from_number%type,
                            p_to_num    in pqh_attribute_ranges.to_number%type,
                            p_value_num in pqh_attribute_ranges.to_number%type,
                            p_in_range     out nocopy boolean ,
                            p_can_approve  out nocopy boolean ) as
 l_proc             varchar2(256) := g_package||'check_value_range_num';
 range_known exception;
 --pragma exception_init (range_known, 200000);
begin
  hr_utility.set_location('Entering '||l_proc,10);
--Modified p_value_num is null check to handle return can_approve TRUE
--if either from_num or to_num range value is NULL
  if p_value_num is null then
     if p_from_num is not null and p_to_num is not null then
        if (p_from_num = 0 OR p_to_num = 0) then
                p_can_approve := TRUE;
                p_in_range := TRUE;
         else
                p_can_approve := FALSE;
                p_in_range := FALSE;
         end if;
     else
        p_can_approve := TRUE;
        p_in_range := TRUE;
     end if;
     raise range_known;
  end if;

  if p_to_num IS NULL
    AND p_from_num IS NULL then
     p_in_range := TRUE;
     p_can_approve := TRUE;
     raise range_known;
  end if;
  if p_to_num is not null and p_from_num is not null then
     if p_value_num between p_from_num and p_to_num then
        p_in_range := TRUE;
        p_can_approve := TRUE;
        raise range_known;
     else
        p_in_range := FALSE;
        p_can_approve := FALSE;
        raise range_known;
     end if;
  else
     if p_to_num is not null then
        if p_to_num >= p_value_num then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
     else
        if p_from_num <= p_value_num then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
    end if;
  end if;
exception
  when range_known then
  if p_in_range = TRUE then
     hr_utility.set_location('inside the range '||l_proc,100);
  else
     hr_utility.set_location('not inside the range '||l_proc,110);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
when others then
                            p_in_range     := null;
                            p_can_approve  := null;
                            raise;
end check_value_range ;

procedure check_value_range (p_from_date  in pqh_attribute_ranges.from_date%type,
                             p_to_date    in pqh_attribute_ranges.to_date%type,
                             p_value_date in pqh_attribute_ranges.to_date%type,
                             p_in_range     out nocopy boolean ,
                             p_can_approve  out nocopy boolean ) as
 l_proc             varchar2(256) := g_package||'check_value_range_date';
 range_known exception;
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_value_date is null then
     p_in_range := TRUE;
     if p_from_date is not null and p_to_date is not null then
        p_can_approve := FALSE;
     else
        p_can_approve := TRUE;
     end if;
     raise range_known;
  end if;
  hr_utility.set_location('value date not null '||l_proc,20);
  if p_to_date IS NULL
    AND p_from_date IS NULL then
     p_in_range := TRUE;
     p_can_approve := TRUE;
     raise range_known;
  end if;
  hr_utility.set_location('to_date and from_date null '||l_proc,30);
  if p_to_date is not null and p_from_date is not null then
     if p_value_date between p_from_date and p_to_date then
        p_in_range := TRUE;
        p_can_approve := TRUE;
        raise range_known;
     else
        p_in_range := FALSE;
        p_can_approve := FALSE;
        raise range_known;
     end if;
     hr_utility.set_location('to_date and from_date not null '||l_proc,40);
  else
     if p_to_date is not null then
        if p_to_date >= p_value_date then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
       hr_utility.set_location('to_date is not null '||l_proc,50);
     else
        if p_from_date <= p_value_date then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
       hr_utility.set_location('from_date is not null '||l_proc,60);
    end if;
  end if;
exception
  when range_known then
  if p_in_range = TRUE then
     hr_utility.set_location('inside the range '||l_proc,100);
  else
     hr_utility.set_location('not inside the range '||l_proc,110);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
when others then
                            p_in_range     := null;
                            p_can_approve  := null;
                            raise;
end check_value_range ;

procedure check_value_range (p_from_char  in pqh_attribute_ranges.from_char%type,
                             p_to_char    in pqh_attribute_ranges.to_char%type,
                             p_value_char in pqh_attribute_ranges.to_char%type,
                             p_in_range      out nocopy boolean,
                             p_can_approve   out nocopy boolean ) as
--Added l_from_char and l_to_char parms by deenath.
 l_from_char pqh_attribute_ranges.from_char%type;
 l_to_char   pqh_attribute_ranges.to_char%type;
 l_proc             varchar2(256) := g_package||'check_value_range_char';
 range_known exception;
begin
  hr_utility.set_location('Entering '||l_proc,10);
--Added below checks for 'All Entities' so that these values are always in Range.
  l_from_char := p_from_char;
  l_to_char   := p_to_char;
  if p_from_char = 'All Entities' then
     l_from_char := NULL;
  end if;
  if p_to_char = 'All Entities' then
     l_to_char := NULL;
  end if;
--End of code addition. Replaced p_from_char and p_to_char with l_from_char and l_to_char.
  if p_value_char is null then
     if l_from_char is not null and l_to_char is not null then
        p_in_range := FALSE;
        p_can_approve := FALSE;
     else
        p_in_range := TRUE;
        p_can_approve := TRUE;
     end if;
     raise range_known;
  end if;
  if l_to_char IS NULL
    AND l_from_char IS NULL then
     p_in_range := TRUE;
     p_can_approve := TRUE;
     raise range_known;
  end if;
  if l_to_char is not null and l_from_char is not null then
     if p_value_char between l_from_char and l_to_char then
        p_in_range := TRUE;
        p_can_approve := TRUE;
        raise range_known;
     else
        p_in_range := FALSE;
        p_can_approve := FALSE;
        raise range_known;
     end if;
  else
     if l_to_char is not null then
        if l_to_char >= p_value_char then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
     else
        if l_from_char <= p_value_char then
          p_in_range := TRUE;
          p_can_approve := TRUE;
          raise range_known;
       else
          p_in_range := FALSE;
          p_can_approve := FALSE;
          raise range_known;
       end if;
    end if;
  end if;
exception
  when range_known then
  if p_in_range = TRUE then
     hr_utility.set_location('inside the range '||l_proc,100);
  else
     hr_utility.set_location('not inside the range '||l_proc,110);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
when others then
                            p_in_range     := null;
                            p_can_approve  := null;
                            raise;
end check_value_range ;

function find_pos_structure(p_pos_str_ver_id in per_pos_structure_versions.pos_structure_version_id%type) return number is
  cursor c1 is select position_structure_id
               from per_pos_structure_versions
               where pos_structure_version_id = p_pos_str_ver_id ;
  l_proc       varchar2(256) := g_package||'find_pos_structure';
  l_pos_str_id per_pos_structure_versions.position_structure_id%type;
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_pos_str_ver_id is null then
     hr_utility.set_location('Pos_str_version reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_POS_STR_VER_REQD');
     hr_utility.raise_error;
  end if;
  open c1;
  fetch c1 into l_pos_str_id;
  if c1%notfound then
     hr_utility.set_location('Pos_str not there'||l_proc,30);
  else
     hr_utility.set_location('pos_str is '||to_char(l_pos_str_id)||l_proc,40);
  end if;
  close c1;
  hr_utility.set_location('Exiting '||l_proc,10000);
  return l_pos_str_id;
end find_pos_structure;

function pos_str_version(p_pos_str_id   in per_pos_structure_versions.position_structure_id%type) return number is
  cursor c1 is select max(pos_structure_version_id)
               from per_pos_structure_versions
               where position_structure_id = p_pos_str_id ;
  l_proc       varchar2(256) := g_package||'pos_str_version';
  l_pos_str_ver_id number;
begin
  hr_utility.set_location('Entering '||l_proc,10);
  if p_pos_str_id is null then
     hr_utility.set_location('Pos_str reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_POS_STRUCT_ID_IS_NULL');
     hr_utility.raise_error;
  end if;
  open c1;
  fetch c1 into l_pos_str_ver_id;
  if c1%notfound then
     hr_utility.set_location('error getting ver for str '||to_char(p_pos_str_id)||l_proc,30);
  else
     hr_utility.set_location('ver for str is'||to_char(l_pos_str_ver_id)||l_proc,40);
  end if;
  close c1;
  hr_utility.set_location('Exiting '||l_proc,10000);
  return l_pos_str_ver_id;
end pos_str_version;

procedure rlm_user_seq( p_routing_list_id in pqh_routing_lists.routing_list_id%type,
                        p_old_user_id     in number default null,
                        p_old_role_id     in number default null,
                        p_old_member_id   in number default null,
                        p_role_id         in out nocopy pqh_roles.role_id%type,
                        p_role_name       in out nocopy pqh_roles.role_name%type,
                        p_user_id         in out nocopy fnd_user.user_id%type,
                        p_user_name       in out nocopy fnd_user.user_name%type,
                        p_member_id          out nocopy pqh_routing_list_members.routing_list_member_id%type,
                        p_member_flag        out nocopy boolean) as

l_role_id         pqh_roles.role_id%type   := p_role_id;
l_role_name       pqh_roles.role_name%type := p_role_name;
l_user_id         fnd_user.user_id%type   := p_user_id;
l_user_name       fnd_user.user_name%type := p_user_name;

  cursor c1 is select role_id,role_name
               from pqh_roles
               where role_name = nvl(p_role_name,role_name)
	       and role_id = nvl(p_role_id,role_id)
               and nvl(enable_flag,'X') ='Y';
  cursor c2 is select routing_list_member_id
               from pqh_routing_list_members
               where routing_list_id = p_routing_list_id
               and role_id = p_role_id
               and user_id = p_user_id
               and nvl(enable_flag,'X') ='Y';
  cursor c3 is select routing_list_member_id
               from pqh_routing_list_members
               where routing_list_id = p_routing_list_id
               and role_id = p_role_id and user_id is null
               and nvl(enable_flag,'X') ='Y';

-- finding new member based on old member and new routing list
  cursor c4 is select routing_list_member_id
               from pqh_routing_list_members
               where routing_list_id = p_routing_list_id
               and role_id = p_old_role_id
               and user_id = p_old_user_id
               and nvl(enable_flag,'X') ='Y';
  cursor c5 is select routing_list_member_id
               from pqh_routing_list_members
               where routing_list_id = p_routing_list_id
               and role_id = p_old_role_id
               and (user_id is null or user_id = p_user_id)
               and nvl(enable_flag,'X') ='Y';
  l_proc       varchar2(256) := g_package||'rlm_user_seq';
  l_member_check varchar2(1) := 'Y';
  l_employee_id number;
begin
  hr_utility.set_location('Entering '||l_proc,10);
  p_member_flag := TRUE;
  if p_role_id is null and p_role_name is null then
     hr_utility.set_location('Roleid or name reqd '||l_proc,12);
     hr_utility.set_message(8302,'PQH_ROLEID_OR_NAME_REQD');
     hr_utility.raise_error;
  elsif p_user_id is null and p_user_name is null then
     hr_utility.set_location('Userid or name reqd '||l_proc,20);
     hr_utility.set_message(8302,'PQH_USERID_OR_NAME_REQD');
     hr_utility.raise_error;
  elsif p_routing_list_id is null then
     hr_utility.set_location('RL reqd for finding member '||l_proc,30);
     hr_utility.set_message(8302,'PQH_ROUTING_LIST_REQD');
     hr_utility.raise_error;
  end if;
  if p_role_id is null or p_role_name is null then
     open c1;
     fetch c1 into p_role_id,p_role_name;
     if c1%notfound then
        hr_utility.set_location('role id or role_name is wrong'||l_proc,40);
     else
        hr_utility.set_location('role id is   '||to_char(p_role_id)||l_proc,45);
        hr_utility.set_location('role name is '||p_role_name||l_proc,50);
     end if;
     close c1;
  end if;
  if p_user_id is not null then
     get_user_id_details(p_user_id     => p_user_id,
                         p_user_name   => p_user_name,
                         p_employee_id => l_employee_id);
  elsif p_user_name is not null then
     get_user_name_details(p_user_id     => p_user_id,
                           p_user_name   => p_user_name,
                           p_employee_id => l_employee_id);
  end if;
  hr_utility.set_location('user id is   '||to_char(p_user_id)||l_proc,52);
  hr_utility.set_location('user name is '||p_user_name||l_proc,53);
  if p_old_role_id is not null then
     if p_role_id = p_old_role_id then
        hr_utility.set_location('person of the same role opening trans'||l_proc,54);
        if p_old_user_id is null then
           hr_utility.set_location('transaction was routed to role alone'||l_proc,55);
           l_member_check := 'N' ;
        else
           hr_utility.set_location('transaction was routed to role + user'||l_proc,56);
           if p_old_user_id = p_user_id then
              hr_utility.set_location('same user opening trans'||l_proc,57);
              l_member_check := 'N' ;
           else
              hr_utility.set_location('different user opening trans'||l_proc,58);
           end if;
        end if;
     else
        hr_utility.set_location('person of the different role opening trans'||l_proc,59);
     end if;
  else
     hr_utility.set_location('no routing history'||l_proc,59);
  end if;
  if l_member_check = 'Y' then
     hr_utility.set_location('checking current user and/or Role in RL '||l_proc,60);
     open c2;
     fetch c2 into p_member_id;
     if c2%notfound then
        hr_utility.set_location('role user combination does not exist in RL members '||l_proc,61);
        hr_utility.set_location('checking just role as the member in RL '||l_proc,62);
        open c3;
        fetch c3 into p_member_id;
        if c3%notfound then
           hr_utility.set_location('role alone also does not exist in RL member '||l_proc,64);
           p_member_flag := FALSE;
        else
           hr_utility.set_location('member exists'||l_proc,70);
           p_member_flag := TRUE;
        end if;
        close c3;
     else
        hr_utility.set_location('member exists'||l_proc,72);
        p_member_flag := TRUE;
     end if;
     close c2;
  else
     if p_old_member_id is not null then
-- old member is to be used for finding out next member
        if p_old_user_id is null then
           open c5;
           fetch c5 into p_member_id;
           if c5%notfound then
              p_member_flag := FALSE;
           else
              p_member_flag := TRUE;
           end if;
           close c5;
        else
           open c4;
           fetch c4 into p_member_id;
           if c4%notfound then
              p_member_flag := FALSE;
           else
              p_member_flag := TRUE;
           end if;
           close c4;
        end if;
        hr_utility.set_location('new member is'||p_member_id||l_proc,73);
        hr_utility.set_location('old member is'||p_old_member_id||l_proc,73);
     else
        p_member_flag := FALSE;
        hr_utility.set_location('old member is null'||l_proc,74);
     end if;
     hr_utility.set_location('Routing history user had trans  '||l_proc,75);
  end if;
  hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                        p_role_id         := l_role_id;
                        p_role_name       := l_role_name;
                        p_user_id         := l_user_id;
                        p_user_name       := l_user_name;
                        p_member_id       := null;
                        p_member_flag     := null;
raise;
end rlm_user_seq;

procedure routing_current (p_tran_cat_id     in pqh_transaction_categories.transaction_category_id%type,
                           p_trans_id        in pqh_routing_history.transaction_id%type,
                           p_history_flag       out nocopy boolean,
                           p_old_member_cd      out nocopy pqh_transaction_categories.member_cd%type,
                           p_position_id        out nocopy pqh_routing_history.forwarded_to_position_id%type,
                           p_member_id          out nocopy pqh_routing_history.forwarded_to_member_id%type,
                           p_role_id            out nocopy number,
                           p_user_id            out nocopy number,
                           p_assignment_id      out nocopy pqh_routing_history.forwarded_to_assignment_id%type,
                           p_pos_str_ver_id     out nocopy pqh_routing_history.pos_structure_version_id%type,
                           p_routing_list_id    out nocopy pqh_routing_lists.routing_list_id%type,
                           p_routing_history_id out nocopy pqh_routing_history.routing_history_id%type,
			   p_status_flag        out nocopy number) as
  cursor c1 is select max(routing_history_id)
               from pqh_routing_history
               where transaction_category_id = p_tran_cat_id
               and transaction_id = p_trans_id
               and user_action_cd <> 'APPLY';
  cursor c2 is select rh.forwarded_to_position_id,rh.forwarded_to_role_id,rh.forwarded_to_user_id,rh.forwarded_to_member_id,
                      rh.forwarded_to_assignment_id,rh.pos_structure_version_id,rc.routing_list_id
               from pqh_routing_history rh,pqh_routing_categories rc
               where routing_history_id = p_routing_history_id
               and rh.routing_category_id = rc.routing_category_id;
  l_error_flag boolean := FALSE;
  l_proc       varchar2(256) := g_package||'routing_current';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   p_history_flag := TRUE;
   p_status_flag := 0;
   if p_tran_cat_id is null then
      hr_utility.set_location('Trans_cat reqd '||l_proc,20);
      hr_utility.set_message(8302,'PQH_TRAN_CAT_REQD');
      hr_utility.raise_error;
   elsif p_trans_id is null then
      hr_utility.set_location('Transaction id reqd '||l_proc,30);
      hr_utility.set_message(8302,'PQH_TRANSACTION_ID_REQD');
      hr_utility.raise_error;
   end if;
   open c1;
   fetch c1 into p_routing_history_id ;
   close c1;
   if p_routing_history_id is not null then
      open c2;
      fetch c2 into p_position_id,p_role_id,p_user_id,p_member_id,p_assignment_id,p_pos_str_ver_id,p_routing_list_id ;
      if c2%notfound then
         hr_utility.set_location('wrong routing history id'||l_proc,40);
         p_history_flag := FALSE;
      else
         if p_position_id is not null then
            p_old_member_cd := 'P' ;
            hr_utility.set_location('Pos '||to_char(p_position_id)||l_proc,50 );
         elsif p_routing_list_id is not null then
            p_old_member_cd := 'R' ;
            hr_utility.set_location('Member '||to_char(p_member_id)||l_proc,50 );
         elsif p_assignment_id is not null then
            p_old_member_cd := 'S' ;
            hr_utility.set_location('Assig '||to_char(p_assignment_id)||l_proc,50 );
         else
            hr_utility.set_location('Invalid data in rout_hist'||l_proc,80);
            p_history_flag := FALSE;
            hr_utility.set_message(8302,'PQH_INVALID_ROUT_HIST');
            hr_utility.raise_error;
         end if;
         close c2;
      end if;
   else
      hr_utility.set_location('no history '||l_proc,85);
      p_history_flag := FALSE;
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception when others then
                           p_history_flag       := null;
                           p_old_member_cd      := null;
                           p_position_id        := null;
                           p_member_id          := null;
                           p_role_id            := null;
                           p_user_id            := null;
                           p_assignment_id      := null;
                           p_pos_str_ver_id     := null;
                           p_routing_list_id    := null;
                           p_routing_history_id := null;
			   p_status_flag        := null;
raise;
end routing_current;

procedure rl_next_user(p_routing_list_id         in pqh_routing_list_members.routing_list_id%type,
		       p_cur_member_id           in pqh_routing_list_members.routing_list_member_id%type,
                       p_member_id                  out nocopy pqh_routing_list_members.routing_list_member_id%type,
                       p_role_id                    out nocopy pqh_routing_list_members.role_id%type,
                       p_user_id                    out nocopy pqh_routing_list_members.user_id%type,
                       p_status_flag                out nocopy number)
as
 cursor c1 is
	select routing_list_member_id,role_id,user_id
        from pqh_routing_list_members
        where routing_list_id = p_routing_list_id
        and seq_no = (select min(seq_no)
                      from pqh_routing_list_members
                      where routing_list_id = p_routing_list_id
                      and seq_no > (select seq_no
                                    from pqh_routing_list_members
                                    where routing_list_id = p_routing_list_id
                                    and routing_list_member_id = p_cur_member_id)
                      and nvl(enable_flag,'X') = 'Y');
 cursor c2 is select routing_list_member_id,role_id,user_id
        from pqh_routing_list_members
        where routing_list_id = p_routing_list_id
        and seq_no = (select min(seq_no)
                      from pqh_routing_list_members
                      where routing_list_id = p_routing_list_id
                      and nvl(enable_flag,'X') = 'Y');
 l_error_flag boolean := FALSE;
 l_proc       varchar2(256) := g_package||'rl_next_user';
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_routing_list_id is null then
      hr_utility.set_message(8302,'PQH_ROUTING_LIST_REQD ');
      hr_utility.raise_error;
   end if;
   p_status_flag := 0;
   if p_cur_member_id is not null then
      hr_utility.set_location('next member using '||to_char(p_cur_member_id)||l_proc,80);
      open c1;
      fetch c1 into p_member_id,p_role_id,p_user_id ;
      if c1%notfound then
         hr_utility.set_location('error getting next RL_member '||l_proc,89);
         hr_utility.set_location('for RL '||to_char(p_routing_list_id)||to_char(p_cur_member_id)||l_proc,90);
         p_status_flag := 1;
      else
         hr_utility.set_location('RL_members , next member is '||to_char(p_member_id)||l_proc,100);
      end if;
      close c1;
   else
      hr_utility.set_location('first member of the routing list'||l_proc,110);
      open c2;
      fetch c2 into p_member_id,p_role_id,p_user_id;
      if c2%notfound then
         hr_utility.set_location('error getting first RL_member for RL '||to_char(p_routing_list_id)||l_proc,120);
         p_status_flag := 1;
      else
         hr_utility.set_location('RL_members , next member is '||to_char(p_member_id)||l_proc,130);
      end if;
      close c2;
   end if;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception
   when others then
      p_member_id                  := null;
      p_role_id                    := null;
      p_user_id                    := null;
      p_status_flag                := null;
   raise;
end rl_next_user;
procedure ph_next_user(p_cur_position_id in pqh_position_transactions.position_id%type,
                       p_pos_str_ver_id  in pqh_routing_history.pos_structure_version_id%type,
                       p_position_id        out nocopy pqh_position_transactions.position_id%type,
                       p_status_flag        out nocopy number ) as
  cursor c1(l_position_id number) is
	       select parent_position_id
               from per_pos_structure_elements
               where subordinate_position_id = l_position_id
               and pos_structure_version_id = p_pos_str_ver_id ;
  l_proc       varchar2(256) := g_package||'ph_next_user';
  l_effective_date date;
begin
   hr_utility.set_location('Entering '||l_proc,10);
   if p_cur_position_id is null then
      hr_utility.set_message(8302,'PQH_CUR_OLD_POS_NULL');
      hr_utility.raise_error;
   elsif p_pos_str_ver_id is null then
      hr_utility.set_message(8302,'PQH_POS_STR_OR_VER_NULL');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location('value of cur pos is'||to_char(p_cur_position_id),152);
   open c1(p_cur_position_id);
   fetch c1 into p_position_id ;
   if c1%notfound then
      hr_utility.set_location('eol set'||l_proc,200);
      p_status_flag := 1 ;
   else
      hr_utility.set_location('position found'||l_proc,210);
      l_effective_date := hr_general.get_position_date_end(p_position_id => p_position_id);
      if l_effective_date is not null then
         if l_effective_date < trunc(sysdate) then
            hr_utility.set_location('position eliminated'||l_proc,220);
            p_status_flag := 8 ;
         else
            hr_utility.set_location('valid position '||l_proc,230);
            p_status_flag := 0 ;
         end if;
      else
         hr_utility.set_location('valid position '||l_proc,240);
         p_status_flag := 0 ;
      end if;
   end if;
   close c1;
   hr_utility.set_location('Exiting '||l_proc,10000);
exception
   when others then
      p_position_id        := null;
      p_status_flag        := null;
raise;
end ph_next_user;

function get_txn_cat_id(p_transaction_id in number,
                        p_short_name     in varchar2) return number is
   l_txn_cat_id number;
begin
   if p_short_name ='POSITION_TRANSACTION' then
      select wf_transaction_category_id
      into l_txn_cat_id
      from pqh_position_transactions
      where position_transaction_id = p_transaction_id;
   elsif p_short_name ='BUDGET_WORKSHEET' then
      select wks.wf_transaction_category_id
      into l_txn_cat_id
      from pqh_worksheet_details wkd, pqh_worksheets wks
      where worksheet_detail_id = p_transaction_id
        and wks.worksheet_id = wkd.worksheet_id;
   elsif p_short_name ='PQH_BPR' then
      select wf_transaction_category_id
      into l_txn_cat_id
      from pqh_budget_pools
      where pool_id = p_transaction_id;
   end if;
   return l_txn_cat_id;
exception
   when others then
      return l_txn_cat_id;
end;

-- when transaction id is passed business group id is not even checked
-- business group id is used for pulling transaction category id only.
procedure valid_user_opening(p_business_group_id           in number    default null,
                             p_short_name                  in varchar2  ,
                             p_transaction_id              in number    default null,
                             p_routing_history_id          in number    default null,
                             p_wf_transaction_category_id     out nocopy number,
                             p_glb_transaction_category_id    out nocopy number,
                             p_role_id                        out nocopy number,
                             p_role_template_id               out nocopy number,
                             p_status_flag                    out nocopy varchar2) is
  l_proc       varchar2(256) := g_package||'valid_user_opening';
  l_freeze_status_cd            varchar2(30);
  l_member_cd                   varchar2(30);
  l_txn_catg_name               varchar2(240);
  l_user_id                     fnd_user.user_id%type := fnd_profile.value('USER_ID');
  l_user_name                   fnd_user.user_name%type := fnd_profile.value('USERNAME');
  l_scope_name                  varchar2(240);
  l_default_role_id             number;
  l_routing_role_id             number;
  l_routing_history_id          number;
  l_person_id                   number;
  l_error_cd                    number;
  l_date_start                  date;
  l_actual_term_date 		date;
  l_session_date                date;

  cursor c_tcat_details(p_transaction_category_id number) is
           select member_cd,freeze_status_cd,name
           from pqh_transaction_categories
           where transaction_category_id = p_transaction_category_id
           and nvl(enable_flag,'Y') = 'Y';
  cursor c_get_person_id(p_user_id number) is
   	   select employee_id
           from fnd_user
           where user_id = p_user_id;
  cursor c_emp_term(p_date date) is
  	select ppos.date_start, ppos.actual_termination_date
  	from per_periods_of_service ppos
  	where ppos.person_id = l_person_id
        and p_date between ppos.date_start and nvl(ppos.actual_termination_date, hr_general.end_of_time) ;

  cursor c_emp_date_start is
  	select min(ppos.date_start)
  	from per_periods_of_service ppos
  	where ppos.person_id = l_person_id;

  cursor c_user_action is
  	select user_action_cd
  	from    pqh_routing_history
  	where routing_history_id = p_routing_history_id;
  --
 l_user_action_cd varchar2(30);
 --
begin
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('user is '||l_user_name||l_proc,15);
   p_status_flag := null;

--
-- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
-- record if one does not already exist.
--
   begin
      SELECT  effective_date
      INTO    l_session_date
      FROM    fnd_sessions
      WHERE   session_id      = userenv('sessionid');
   exception
      when others then
        insert into fnd_sessions (session_id, effective_date) values(userenv('sessionid'),trunc(sysdate));
        l_session_date := trunc(sysdate);
   end;
--
   open c_get_person_id(p_user_id => l_user_id);
   fetch c_get_person_id into l_person_id;
   close c_get_person_id;

   if l_person_id is null then
   	p_status_flag := 1.1;
   	hr_utility.set_message(8302, 'PQH_NOT_EMP');
   else
	open c_emp_term(l_session_date);
   	fetch c_emp_term into l_date_start, l_actual_term_date;
        --
	if c_emp_term%notfound then
           p_status_flag := 1.1;
           hr_utility.set_message(8302,'PQH_EMP_TERMED');
           --
	   open c_emp_date_start;
   	   fetch c_emp_date_start into l_date_start;
           close c_emp_date_start;
           --
	   if l_date_start > l_session_date then
	     p_status_flag := 1.2;
	     hr_utility.set_message(8302, 'PQH_EMP_NOT_STARTED');
	   end if;
           --
        end if;
	close c_emp_term;
   end if;
   p_glb_transaction_category_id := get_txn_cat(p_short_name);
   hr_utility.set_location('global txn_cat is '||p_glb_transaction_category_id||l_proc,20);
   if p_transaction_id is null then
      hr_utility.set_location('txn_id is '||p_transaction_id||l_proc,22);
      if p_business_group_id is not null then
         p_wf_transaction_category_id := get_txn_cat(p_short_name,p_business_group_id);
      else
         p_wf_transaction_category_id := p_glb_transaction_category_id;
      end if;
   else
      hr_utility.set_location('txn_id is there'||l_proc,23);
      p_wf_transaction_category_id := get_txn_cat_id(p_transaction_id => p_transaction_id,
                                                     p_short_name     => p_short_name);
      hr_utility.set_location('txn txncat is '||p_wf_transaction_category_id||l_proc,25);
   end if;
   hr_utility.set_location('local txn_cat is '||p_wf_transaction_category_id||l_proc,30);
   if p_wf_transaction_category_id is not null then
      open c_tcat_details(p_wf_transaction_category_id);
      fetch c_tcat_details into l_member_cd,l_freeze_status_cd,l_txn_catg_name;
      if c_tcat_details%notfound then
         hr_utility.set_location('txn_cat details does not exist '||l_proc,50);
         close c_tcat_details;
         p_status_flag := 1;
         hr_utility.set_message(8302,'PQH_INVALID_TXN_CAT_ID');
         hr_utility.set_message_token('TRANSACTION',l_txn_catg_name);
      else
         close c_tcat_details;
         hr_utility.set_location('txn_cat details pulled '||l_proc,60);
         if nvl(l_freeze_status_cd,'NOT_FROZEN') <> 'FREEZE_CATEGORY' then
            hr_utility.set_location('txn_cat not frozen'||l_proc,70);
            if p_wf_transaction_category_id <> p_glb_transaction_category_id then
               l_scope_name := hr_general.decode_organization(p_business_group_id);
            else
               l_scope_name := hr_general.decode_lookup('PQH_TCT_SCOPE','GLOBAL');
            end if;
            p_status_flag := 2;
            hr_utility.set_message(8302,'PQH_TXN_CAT_NOT_FROZEN');
            hr_utility.set_message_token('TRANSACTION',l_txn_catg_name);
            hr_utility.set_message_token('SCOPE',l_scope_name);
         end if;
      end if;
   else
      p_status_flag := 1;
      hr_utility.set_message(8302,'PQH_INVALID_TXN_CAT_ID');
      hr_utility.set_message_token('TRANSACTION',l_txn_catg_name);
   end if;
   hr_utility.set_location('status is '||p_status_flag||l_proc,601);
   if p_status_flag is null then
      hr_utility.set_location('going for default role'||l_proc,80);
      get_default_role(p_session_date            => l_session_date,
                       p_transaction_category_id => p_wf_transaction_category_id,
                       p_person_id               => l_person_id,
                       p_user_id                 => l_user_id,
                       p_role_id                 => l_default_role_id);
      hr_utility.set_location('default role is '||l_default_role_id||l_proc,80);
      if l_default_role_id is null then
         p_status_flag := 3;
         hr_utility.set_message(8302,'PQH_USER_HAS_NO_ROLE');
      elsif l_default_role_id = -1 then
         p_status_flag := 4;
         hr_utility.set_message(8302,'PQH_TXN_CAT_NOT_WF_ENABLED');
         hr_utility.set_message_token('TRANSACTION',l_txn_catg_name);
      elsif l_default_role_id = -2 then
         p_status_flag := 5;
         hr_utility.set_message(8302,'PQH_EMP_NOTFOR_USER');
      elsif l_default_role_id = -3 then
         p_status_flag := 6;
      end if;
   end if;
   hr_utility.set_location('status is '||p_status_flag||l_proc,602);
   if p_status_flag is null then
      hr_utility.set_location('going for routing role'||l_proc,90);
      if p_transaction_id is not null then
         hr_utility.set_location('opening from inbox '||l_proc,110);
         if p_routing_history_id is null then
            hr_utility.set_location('transaction was saved in inbox after start'||l_proc,115);
         else
            select max(routing_history_id)
            into l_routing_history_id
            from pqh_routing_history
            where routing_history_id          > nvl(p_routing_history_id,0)
                  and transaction_id          = p_transaction_id
                  and transaction_category_id = p_wf_transaction_category_id;
            if l_routing_history_id > 0 then
               p_status_flag := 11;
               hr_utility.set_message(8302,'PQH_TRANS_ROUTING_EXISTS');
            else
               hr_utility.set_location('checking routing role '||l_proc,120);

               /* if transaction status (aka user_action_cd) is TIMEOUT then
	          do not fetch routing role, so that user's default role is used,
		  instead of the routing role.  NS:08/08/2006: Bug 5436925 */
               open c_user_action;
               fetch c_user_action into l_user_action_cd;
               close c_user_action;

               if (nvl(l_user_action_cd,'ERROR') <> 'TIMEOUT') then
                  l_routing_role_id := get_routinghistory_role(p_routing_history_id => p_routing_history_id,
                                                               p_user_id            => l_user_id,
                                                               p_user_name          => l_user_name);
               end if;
               hr_utility.set_location('routing role is'||l_routing_role_id||l_proc,130);
            end if;
         end if;
      end if;
      if nvl(l_routing_role_id,-1) > 0  then
         hr_utility.set_location('routing role is to be used '||l_proc,150);
         p_role_id := l_routing_role_id ;
      else
         p_role_id := l_default_role_id ;
         hr_utility.set_location('default role is to be used '||l_proc,140);
      end if;
   end if;
   hr_utility.set_location('status is '||p_status_flag||l_proc,603);
   if p_status_flag is null and p_short_name ='POSITION_TRANSACTION' then
      hr_utility.set_location('fetching role template for PTX'||l_proc,160);
      p_role_template_id := get_role_template(p_role_id                 => p_role_id,
                                              p_transaction_category_id => p_glb_transaction_category_id);
      hr_utility.set_location('role template is'||p_role_template_id||l_proc,170);
      if p_role_template_id = -1 then
         p_status_flag := 21;
      end if;
   end if;
   hr_utility.set_location('status is '||p_status_flag||l_proc,604);
   if p_status_flag is null then
      hr_utility.set_location('validation for type of routing'||l_proc,180);
      if l_member_cd ='R' then
         hr_utility.set_location('user-role-validation '||l_proc,190);
         l_error_cd := check_user_role_details(p_role_id => p_role_id,
                                               p_user_id => l_user_id,
                                          p_session_date => l_session_date);
         if l_error_cd <> 0 then
            p_status_flag := 31;
         end if;
      elsif l_member_cd ='P' then
         hr_utility.set_location('user-position-validation '||l_proc,200);
         l_error_cd := check_user_pos_details(p_person_id  => l_person_id,
                                              p_value_date => trunc(sysdate));
         if l_error_cd <> 0 then
            p_status_flag := 41;
         end if;
      elsif l_member_cd ='S' then
         hr_utility.set_location('user-assignment-validation '||l_proc,210);
         l_error_cd := check_user_asg_details(p_person_id  => l_person_id,
                                              p_value_date => trunc(sysdate));
         if l_error_cd <> 0 then
            p_status_flag := 51;
         end if;
      end if;
   end if;
   hr_utility.set_location('status flag is '||p_status_flag||l_proc,220);
   hr_utility.set_location('Exiting '||l_proc,10000);
exception
   when others then
      p_wf_transaction_category_id     := null;
      p_glb_transaction_category_id    := null;
      p_role_id                        := null;
      p_role_template_id               := null;
      p_status_flag                    := null;
raise;
end valid_user_opening;

function get_user_default_role(p_user_id in number)
return Number is
--
l_proc       varchar2(256) := g_package||'get_user_default_role';
l_role_id    pqh_roles.role_id%type;
--
Cursor csr_def_rl is
Select
decode(information_type, 'PQH_ROLE_USERS', to_number(pei.pei_information3), 0) role_id
from per_people_extra_info pei , fnd_user usr
WHERE usr.user_id = p_user_id
  and usr.employee_id = pei.person_id
  and information_type = 'PQH_ROLE_USERS'
 /** Check if default role **/
  and nvl(pei.pei_information4,'N') = 'Y'
 /** Check if enabled **/
  and nvl(pei.pei_information5,'Y')='Y';
--
begin
  --
  hr_utility.set_location('Entering '||l_proc,5);
  --
  Open csr_def_rl;
  Fetch csr_def_rl into l_role_id;
  If csr_def_rl%notfound then
     Close csr_def_rl;
     Return NULL;
  End if;

  Close csr_def_rl;
  Return l_role_id;
  --
  hr_utility.set_location('Exiting '||l_proc,10);
  --
end get_user_default_role;
--
--
end pqh_workflow;

/
