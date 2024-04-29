--------------------------------------------------------
--  DDL for Package Body PQH_WKS_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WKS_BUDGET" as
/* $Header: pqwksbud.pkb 120.1 2005/08/17 11:26:20 nsanghal noship $ */
   g_package varchar2(100) := 'PQH_WKS_BUDGET.' ;

function get_currency_precision(p_currency_code in varchar2) return number is
   cursor c1 is select precision
                from fnd_currencies
                where currency_code = p_currency_code;
   l_precision number;
begin
   open c1;
   fetch c1 into l_precision;
   close c1;
   return l_precision;
end;
function valid_grade(p_position_id in number default null,
                     p_job_id      in number default null,
                     p_grade_id    in number) return varchar2 is
/*
   cursor c1 is select 'x' from per_valid_grades
                where (position_id = p_position_id or position_id is null)
                and (job_id        = p_job_id or job_id is null)
                and grade_id = p_grade_id ;
*/
   l_check varchar2(1);
begin
  return 'TRUE';
/*
-- Commented the grade code to return everything as valid for the time being
   if p_position_id is null and p_job_id is null then
      hr_utility.set_location('All grades valid',10);
      return 'TRUE';
   else
      open c1;
      fetch c1 into l_check;
      if c1%notfound then
         hr_utility.set_location('invalid grade:'||p_grade_id||' for pos:'||p_position_id||' and job:'||p_job_id,20);
         return 'FALSE';
      else
         hr_utility.set_location('valid grade:'||p_grade_id||' for pos:'||p_position_id||' and job:'||p_job_id,30);
         return 'TRUE';
      end if;
   end if;
*/
end;

function can_apply(p_worksheet_detail_id in number) return varchar2 is
   cursor c1 is select parent_worksheet_detail_id from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id;
   l_apply varchar2(30) := 'Y';
begin
   for i in c1 loop
       if i.parent_worksheet_detail_id is null then
          l_apply := 'Y' ;
       else
          l_apply := 'N' ;
       end if;
   end loop;
   return l_apply;
end;

function can_approve(p_worksheet_detail_id in number) return varchar2 is
   cursor c1 is select status from pqh_worksheet_details
                where action_cd ='D'
                and parent_worksheet_detail_id = p_worksheet_detail_id;
   l_approve varchar2(30) := 'YES';
-- as discussed with dinesh, right now, we will return force when there is any delegated worksheet
-- which is not approved else YES will be returned. No option can be used in future.
begin
   for i in c1 loop
      if i.status not in ('APPROVED') then
	 l_approve := 'FORCE';
      end if;
   end loop;
   return l_approve;
end;
procedure get_all_unit_desc(p_worksheet_detail_id in number,
                            p_unit1_desc             out nocopy varchar2,
                            p_unit2_desc             out nocopy varchar2,
                            p_unit3_desc             out nocopy varchar2) is
begin
   pqh_utility.get_all_unit_desc(p_worksheet_detail_id => p_worksheet_detail_id,
                                 p_unit1_desc          => p_unit1_desc,
                                 p_unit2_desc          => p_unit2_desc,
                                 p_unit3_desc          => p_unit3_desc);
exception when others then
p_unit1_desc := null;
p_unit2_desc := null;
p_unit3_desc := null;
raise;
end;

/*
this procedure commented out nocopy here and code being to pqh_utility package


Procedure get_all_unit_desc(p_worksheet_detail_id in number,
                            p_unit1_desc             out nocopy varchar2,
                            p_unit2_desc             out nocopy varchar2,
                            p_unit3_desc             out nocopy varchar2) is
   cursor c1 is select budget_unit1_id,budget_unit2_id,budget_unit3_id
                from pqh_budgets bgt,pqh_worksheets wks, pqh_worksheet_details wkd
		where wkd.worksheet_id = wks.worksheet_id
		and wks.budget_id = bgt.budget_id
		and wkd.worksheet_detail_id = p_worksheet_detail_id;
   l_budget_unit1_id pqh_budgets.budget_unit1_id%type;
   l_budget_unit2_id pqh_budgets.budget_unit1_id%type;
   l_budget_unit3_id pqh_budgets.budget_unit1_id%type;
begin
   if p_worksheet_detail_id is not null then
      begin
         open c1;
         fetch c1 into l_budget_unit1_id,l_budget_unit2_id,l_budget_unit3_id;
         close c1;
      exception
	 when others then
            hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
            hr_utility.raise_error;
      end;
      p_unit1_desc := get_unit_desc(l_budget_unit1_id);
      if l_budget_unit2_id is not null then
         p_unit2_desc := get_unit_desc(l_budget_unit2_id);
      else
         p_unit2_desc := null;
      end if;
      if l_budget_unit3_id is not null then
         p_unit3_desc := get_unit_desc(l_budget_unit3_id);
      else
         p_unit3_desc := null;
      end if;
   else
      hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
      hr_utility.raise_error;
   end if;
exception
   when others then
p_unit1_desc := null;
p_unit2_desc := null;
p_unit3_desc := null;
      hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
      hr_utility.raise_error;
end get_all_unit_desc;
*/

function get_org_hier(p_org_structure_version_id in number) return varchar2 is
   cursor c1 is select ors.name
                from per_org_structure_versions osv, per_organization_structures ors
                where osv.organization_structure_id = ors.organization_structure_id
                and osv.org_structure_version_id = p_org_structure_version_id;
   l_org_hier varchar2(100);
begin
   open c1;
   fetch c1 into l_org_hier;
   close c1;
   return l_org_hier;
end;

function get_unit_type(p_unit_id in number) return varchar2 is
   cursor c1 is select system_type_cd
                from per_shared_types
                where lookup_type ='BUDGET_MEASUREMENT_TYPE'
                and shared_type_id = p_unit_id;
   l_system_type_cd per_shared_types_vl.system_type_cd%type;
begin
   open c1;
   fetch c1 into l_system_type_cd;
   close c1;
   return l_system_type_cd;
exception
   when others then
      hr_utility.set_message(8302,'PQH_INVALID_UNIT_ENTERED');
      hr_utility.raise_error;
end get_unit_type;

function get_unit_desc(p_unit_id in number) return varchar2 is
   l_unit_name per_shared_types_vl.shared_type_name%type;
begin
   l_unit_name := pqh_utility.get_unit_desc(p_unit_id);
   return l_unit_name;
end;
/*
This function moved from here to shared aru component package pqh_utility
so that process log form could use it.

function get_unit_desc(p_unit_id in number) return varchar2 is
   cursor c1 is select shared_type_name
                from per_shared_types_vl
                where lookup_type ='BUDGET_MEASUREMENT_TYPE'
                and shared_type_id = p_unit_id;
   l_shared_type_name per_shared_types_vl.shared_type_name%type;
begin
   open c1;
   fetch c1 into l_shared_type_name;
   close c1;
   return l_shared_type_name;
exception
   when others then
      hr_utility.set_message(8302,'PQH_INVALID_UNIT_ENTERED');
      hr_utility.raise_error;
end get_unit_desc;
*/
function get_parent_value(p_worksheet_detail_id      in number,
			  p_worksheet_propagate_code in varchar2) return varchar2 is
   cursor c1(p_worksheet_detail_id number) is
		select parent_worksheet_detail_id,worksheet_id
		from pqh_worksheet_details
		where worksheet_detail_id = p_worksheet_detail_id ;
   cursor c2(p_worksheet_detail_id number) is
		select propagation_method,worksheet_detail_id
		from pqh_worksheet_details
		where worksheet_detail_id = p_worksheet_detail_id ;
   cursor c3(p_worksheet_id number) is
		select propagation_method
		from pqh_worksheets
		where worksheet_id = p_worksheet_id ;
   l_worksheet_detail_id        number;
   l_parent_worksheet_detail_id number;
   l_worksheet_id               number;
   l_code                       varchar2(3);
   l_proc varchar2(100) := g_package||'get_parent_value' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_worksheet_detail_id is not null then
     begin
        open c1(p_worksheet_detail_id);
        fetch c1 into l_parent_worksheet_detail_id,l_worksheet_id;
        close c1;
     exception
	when others then
           hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
           hr_utility.raise_error;
     end;
     if l_parent_worksheet_detail_id is null then
        hr_utility.set_location('parent null '||l_proc,20);
	begin
           open c3(l_worksheet_id);
           fetch c3 into l_code;
           close c3;
        exception
   	   when others then
              hr_utility.set_message(8302,'PQH_INVALID_WKS_PASSED');
              hr_utility.raise_error;
        end;
        return l_code;
     else
        hr_utility.set_location('parent not null '||l_parent_worksheet_detail_id||l_proc,30);
	begin
           open c2(l_parent_worksheet_detail_id);
           fetch c2 into l_code,l_worksheet_detail_id;
           close c2;
        exception
	   when others then
              hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
              hr_utility.raise_error;
        end;
        if l_code = 'PC' then
   	   l_code := get_parent_value(l_worksheet_detail_id,p_worksheet_propagate_code);
        end if;
        hr_utility.set_location('l_code is '||l_code||l_proc,40);
        return l_code;
     end if;
  else
     l_code := p_worksheet_propagate_code;
     hr_utility.set_location('l_code is '||l_code||l_proc,50);
     return l_code;
  end if;
end;
function get_value(p_worksheet_detail_id      in number,
		   p_worksheet_propagate_code in varchar2,
		   code                       in varchar2) return varchar2 is
   l_code varchar2(3);
   l_meaning varchar2(80);
   l_meaning1 varchar2(80);
   l_proc varchar2(100) := g_package||'get_value' ;
begin
   hr_utility.set_location('entering '||code||l_proc,10);
   if code = 'PC' then
      l_code := get_parent_value(p_worksheet_detail_id,p_worksheet_propagate_code);
      l_meaning := hr_general.decode_lookup('PQH_WORKSHEET_PROPAGATE_METHOD','PC');
      l_meaning1 := hr_general.decode_lookup('PQH_WORKSHEET_PROPAGATE_METHOD',l_code);
      l_meaning := l_meaning||'('||l_meaning1||')' ;
   elsif code in ('RV','RP','UE') then
      l_meaning := hr_general.decode_lookup('PQH_WORKSHEET_PROPAGATE_METHOD',code);
   else
      hr_utility.set_message(8302,'PQH_INVALID_PROPAGATION_METHOD');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location('exiting with meaning'||l_meaning||l_proc,50);
   return l_meaning;
end get_value;
function lookup_desc(p_lookup_type in varchar2,
                     p_lookup_code in varchar2) return varchar2 is
   cursor c1 is select nvl(description,meaning) description
                from hr_lookups
                where lookup_type = p_lookup_type
                and lookup_code   = p_lookup_code;
   l_desc varchar2(240);
begin
   for i in c1 loop
       l_desc := i.description;
       exit;
   end loop;
   return l_desc;
end lookup_desc;
procedure wkd_propagation_method(p_worksheet_detail_id in number,
				 p_propagation_method     out nocopy varchar2 ) is
   cursor c0 is select worksheet_id,propagation_method from pqh_worksheet_details
		where worksheet_detail_id = p_worksheet_detail_id ;
   l_change_mode  varchar2(3);
   l_wks_change_mode  varchar2(3);
   l_effective_change_mode  varchar2(3);
   l_worksheet_id number;
   cursor c1 is select propagation_method from pqh_worksheets
		where worksheet_id = l_worksheet_id ;
begin
   begin
      open c0;
      fetch c0 into l_worksheet_id,l_change_mode ;
      close c0;
   exception
      when others then
         hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
         hr_utility.raise_error;
   end;
   if l_change_mode = 'PC' then
      open c1;
      fetch c1 into l_wks_change_mode;
      close c1;
      l_effective_change_mode := get_parent_value(p_worksheet_detail_id,l_wks_change_mode);
      p_propagation_method := l_effective_change_mode;
   else
      p_propagation_method := l_change_mode;
   end if;
exception when others then
p_propagation_method := null;
raise;
end wkd_propagation_method;
procedure get_bgt_unit_precision(p_budget_id           in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) is
   cursor c1 is select currency_code,budget_unit1_id,budget_unit2_id,budget_unit3_id
                from pqh_budgets
                where budget_id = p_budget_id;
   l_currency_code varchar2(15);
   l_unit1_id number;
   l_unit2_id number;
   l_unit3_id number;
   l_unit1_type varchar2(30);
   l_unit2_type varchar2(30);
   l_unit3_type varchar2(30);
begin
   open c1;
   fetch c1 into l_currency_code,l_unit1_id,l_unit2_id,l_unit3_id;
   close c1;
   if l_unit1_id is not null then
      l_unit1_type := get_unit_type(l_unit1_id);
      if l_unit1_type ='MONEY' then
         p_unit1_precision := get_currency_precision(p_currency_code => l_currency_code);
      else
         p_unit1_precision := 2;
      end if;
   end if;
   if l_unit2_id is not null then
      l_unit2_type := get_unit_type(l_unit2_id);
      if l_unit2_type ='MONEY' then
         p_unit2_precision := get_currency_precision(p_currency_code => l_currency_code);
      else
         p_unit2_precision := 2;
      end if;
   end if;
   if l_unit3_id is not null then
      l_unit3_type := get_unit_type(l_unit3_id);
      if l_unit3_type ='MONEY' then
         p_unit3_precision := get_currency_precision(p_currency_code => l_currency_code);
      else
         p_unit3_precision := 2;
      end if;
   end if;
   exception when others then
   p_unit1_precision := null;
   p_unit2_precision := null;
   p_unit3_precision := null;
   raise;
end get_bgt_unit_precision;
procedure get_wks_unit_precision(p_worksheet_id        in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) is
   cursor c1 is select budget_id
                from pqh_worksheets
                where worksheet_id = p_worksheet_id;
   l_budget_id number;
begin
   open c1;
   fetch c1 into l_budget_id;
   close c1;
   get_bgt_unit_precision(p_budget_id       => l_budget_id,
                          p_unit1_precision => p_unit1_precision,
                          p_unit2_precision => p_unit2_precision,
                          p_unit3_precision => p_unit3_precision);
exception when others then
p_unit1_precision := null;
p_unit2_precision := null;
p_unit3_precision := null;
raise;
end get_wks_unit_precision;
procedure get_wkd_unit_precision(p_worksheet_detail_id in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) is
   l_budget_id number;
   cursor c1 is select wks.budget_id
                from pqh_worksheet_details wkd, pqh_worksheets wks
                where wkd.worksheet_detail_id = p_worksheet_detail_id
                and wkd.worksheet_id = wks.worksheet_id;
begin
   open c1;
   fetch c1 into l_budget_id;
   close c1;
   get_bgt_unit_precision(p_budget_id       => l_budget_id,
                          p_unit1_precision => p_unit1_precision,
                          p_unit2_precision => p_unit2_precision,
                          p_unit3_precision => p_unit3_precision);
exception when others then
p_unit1_precision := null;
p_unit2_precision := null;
p_unit3_precision := null;
raise;
end;
procedure get_wks_unit_aggregate(p_worksheet_id        in number,
                                 p_unit1_aggregate        out nocopy varchar2,
                                 p_unit2_aggregate        out nocopy varchar2,
				 p_unit3_aggregate        out nocopy varchar2 ) is
   cursor c1 is select bgt.budget_unit1_aggregate,bgt.budget_unit2_aggregate,bgt.budget_unit3_aggregate
		from pqh_worksheets wks, pqh_budgets bgt
		where wks.worksheet_id = p_worksheet_id
		and wks.budget_id = bgt.budget_id;
begin
   for i in c1 loop
      p_unit1_aggregate := i.budget_unit1_aggregate;
      p_unit2_aggregate := i.budget_unit2_aggregate;
      p_unit3_aggregate := i.budget_unit3_aggregate;
   end loop;
exception when others then
p_unit1_aggregate := null;
p_unit2_aggregate := null;
p_unit3_aggregate := null;
raise;
end get_wks_unit_aggregate;
procedure get_wkd_unit_aggregate(p_worksheet_detail_id in number,
                                 p_unit1_aggregate        out nocopy varchar2,
                                 p_unit2_aggregate        out nocopy varchar2,
				 p_unit3_aggregate        out nocopy varchar2 ) is
   cursor c1 is select bgt.budget_unit1_aggregate,bgt.budget_unit2_aggregate,bgt.budget_unit3_aggregate
		from pqh_worksheets wks, pqh_worksheet_details wkd, pqh_budgets bgt
		where wks.worksheet_id = wkd.worksheet_id
		and wks.budget_id = bgt.budget_id
		and wkd.worksheet_detail_id = p_worksheet_detail_id;
begin
   for i in c1 loop
      p_unit1_aggregate := i.budget_unit1_aggregate;
      p_unit2_aggregate := i.budget_unit2_aggregate;
      p_unit3_aggregate := i.budget_unit3_aggregate;
   end loop;
exception when others then
p_unit1_aggregate := null;
p_unit2_aggregate := null;
p_unit3_aggregate := null;
raise;
end get_wkd_unit_aggregate;
procedure insert_budgetset(p_dflt_budget_set_id      number,
                           p_worksheet_budget_set_id number) IS
   cursor c1 is select dflt_budget_element_id,element_type_id,dflt_dist_percentage
                from pqh_dflt_budget_elements pbe
                where dflt_budget_set_id = p_dflt_budget_set_id ;
   cursor c2(p_dflt_budget_element_id number) is
                select project_id, award_id, task_id,
                       organization_id, expenditure_type,
                       cost_allocation_keyflex_id,dflt_dist_percentage
                from pqh_dflt_fund_srcs
                where dflt_budget_element_id = p_dflt_budget_element_id ;
   l_worksheet_bdgt_elmnt_id number(15) ;
   l_worksheet_fund_src_id   number(15) ;
   l_object_version_number number;
   l_count   number(15) ;
BEGIN
   if p_worksheet_budget_set_id is not null then
      if p_dflt_budget_set_id is null then
         hr_utility.set_message(8302,'PQH_WKS_MIG_INV_SET');
         hr_utility.raise_error;
      else
         select count(*) into l_count from pqh_worksheet_bdgt_elmnts
         where worksheet_budget_set_id = p_worksheet_budget_set_id ;
         if l_count = 0 then
            for i in c1 loop
               pqh_worksheet_bdgt_elmnts_api.create_worksheet_bdgt_elmnt(
                  p_validate                   => FALSE
                 ,p_worksheet_budget_set_id    => p_worksheet_budget_set_id
                 ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                 ,p_element_type_id            => i.element_type_id
                 ,p_object_version_number      => l_object_version_number
                 ,p_distribution_percentage    => i.dflt_dist_percentage
                 );
               for j in c2(i.dflt_budget_element_id) loop
                  pqh_worksheet_fund_srcs_api.create_worksheet_fund_src(
                     p_validate                   => FALSE
                    ,p_worksheet_fund_src_id      => l_worksheet_fund_src_id
                    ,p_worksheet_bdgt_elmnt_id    => l_worksheet_bdgt_elmnt_id
                    ,p_cost_allocation_keyflex_id => j.cost_allocation_keyflex_id
                    ,p_project_id                 => j.project_id
                    ,p_award_id                   => j.award_id
                    ,p_task_id                    => j.task_id
                    ,p_organization_id            => j.organization_id
                    ,p_expenditure_type           => j.expenditure_type
                    ,p_object_version_number      => l_object_version_number
                    ,p_distribution_percentage    => j.dflt_dist_percentage
                    );
               end loop;
           end loop;
        end if;
     end if;
  end if;
end insert_budgetset;
procedure insert_budgetset(p_dflt_budget_set_id number,
                           p_budget_set_id      number) IS
   cursor c1 is select dflt_budget_element_id,element_type_id,dflt_dist_percentage
                from pqh_dflt_budget_elements pbe
                where dflt_budget_set_id = p_dflt_budget_set_id ;
   cursor c2(p_dflt_budget_element_id number) is
                select project_id, award_id, task_id,
                       organization_id, expenditure_type,
                       cost_allocation_keyflex_id,dflt_dist_percentage
                from pqh_dflt_fund_srcs
                where dflt_budget_element_id = p_dflt_budget_element_id ;
   l_budget_element_id number(15) ;
   l_budget_fund_src_id   number(15) ;
   l_count   number(15) ;
   l_object_version_number number;
BEGIN
   if p_budget_set_id is not null then
      if p_dflt_budget_set_id is null then
         hr_utility.set_message(8302,'PQH_WKS_MIG_INV_SET');
         hr_utility.raise_error;
      else
         select count(*) into l_count from pqh_budget_elements
         where budget_set_id = p_budget_set_id ;
         if l_count = 0 then
            for i in c1 loop
               pqh_budget_elements_api.create_budget_element(
                  p_validate                   => FALSE
                 ,p_budget_set_id              => p_budget_set_id
                 ,p_budget_element_id          => l_budget_element_id
                 ,p_element_type_id            => i.element_type_id
                 ,p_object_version_number      => l_object_version_number
                 ,p_distribution_percentage    => i.dflt_dist_percentage
                 );
                for j in c2(i.dflt_budget_element_id) loop
                   pqh_budget_fund_srcs_api.create_budget_fund_src(
                      p_validate                   => FALSE
                     ,p_budget_fund_src_id         => l_budget_fund_src_id
                     ,p_budget_element_id          => l_budget_element_id
                     ,p_cost_allocation_keyflex_id => j.cost_allocation_keyflex_id
                     ,p_project_id                 => j.project_id
                     ,p_award_id                   => j.award_id
                     ,p_task_id                    => j.task_id
                     ,p_organization_id            => j.organization_id
                     ,p_expenditure_type           => j.expenditure_type
                     ,p_object_version_number      => l_object_version_number
                     ,p_distribution_percentage    => j.dflt_dist_percentage
                     );
               end loop;
           end loop;
        end if;
     end if;
  end if;
end insert_budgetset;
procedure delegating_org (p_worksheet_detail_id     in number,
                          p_forwarded_by_user_id    in number,
			  p_member_cd               in varchar,
			  p_action_date             in date,
                          p_transaction_category_id in number) is
   cursor c1 is select worksheet_detail_id,user_id,status,defer_flag,object_version_number
                from pqh_worksheet_details
                where action_cd ='D'
                and parent_worksheet_detail_id = p_worksheet_detail_id
                and nvl(defer_flag,'N') = 'N'
                and user_id is not null
                and organization_id is not null
                and status = 'DELEGATE'
                for update of status;
   cursor c2(p_user_id number) is
   select user_name
   from fnd_user
   where user_id = p_user_id ;
   l_proc varchar2(200) := g_package||'Delegating org' ;
   l_user_name varchar2(100);
   l_object_version_number number;
   l_transaction_name varchar2(200);
   l_apply_error_mesg varchar2(200);
   l_apply_error_num  varchar2(30);
begin
   hr_utility.set_location('entering '||l_proc,10);
   for i in c1 loop
      hr_utility.set_location('inside loop '||l_proc,11);
      begin
	open c2(i.user_id);
	fetch c2 into l_user_name;
	close c2;
      exception
	when others then
           hr_utility.set_location('user name fetch raised error '||l_proc,20);
	   raise;
      end;
      hr_utility.set_location('user name is '||l_user_name||l_proc,30);
      hr_utility.set_location('calling process user action'||l_proc,40);
      begin
        l_transaction_name := get_transaction_name(p_worksheet_detail_id => i.worksheet_detail_id);
	pqh_wf.process_user_action(p_transaction_category_id => p_transaction_category_id,
				   p_transaction_id          => i.worksheet_detail_id,
				   p_route_to_user           => l_user_name,
				   p_forwarded_to_user_id    => i.user_id,
				   p_forwarded_by_user_id    => p_forwarded_by_user_id,
				   p_effective_date          => p_action_date,
				   p_member_cd               => p_member_cd,
				   p_user_action_cd          => 'DELEGATE',
                                   p_transaction_name        => l_transaction_name,
                                   p_apply_error_mesg        => l_apply_error_mesg,
				   p_apply_error_num         => l_apply_error_num);
      exception
	 when others then
            hr_utility.set_location('process user action raised error'||l_proc,50);
	    raise;
      end;
      hr_utility.set_location('going to update status'||l_proc,60);
      l_object_version_number := i.object_version_number;
      pqh_budget.update_worksheet_detail(
      p_worksheet_detail_id               => i.worksheet_detail_id,
      p_effective_date                    => trunc(sysdate),
      p_object_version_number             => l_object_version_number,
      p_status                            => 'DELEGATED'
      );
      hr_utility.set_location('updated status'||l_proc,60);
   end loop;
   hr_utility.set_location('leaving '||l_proc,1000);
end delegating_org;
procedure wks_date_validation( p_worksheet_mode     in varchar2,
                               p_budget_id          in number,
			       p_budget_version_id  in number default null,
			       p_wks_start_date     in date,
			       p_wks_end_date       in date,
			       p_wks_ll_date        out nocopy date,
			       p_wks_ul_date        out nocopy date,
			       p_status             out nocopy varchar2) is
   l_max_version    number;
   cursor c0 is select max(version_number) from pqh_budget_versions
		where budget_id = p_budget_id ;
   cursor c1 is select 'x' from pqh_budget_versions
                where budget_version_id = p_budget_version_id
                and budget_id = p_budget_id;
   cursor c2 is select date_to from pqh_budget_versions
		where version_number = l_max_version
		and budget_id = p_budget_id;
   cursor c3 is select version_number from pqh_budget_versions
		where budget_version_id = p_budget_version_id;
   l_max_end_date   date;
   l_ver_chk        varchar2(15);
   l_version_number number;
   l_proc           varchar2(61) := g_package ||'wks_date_validation' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
-- mode N is  edit and make new version
-- mode S is  start from scratch
-- mode O is  copy and edit version
   if p_worksheet_mode not in ('N','S','O') then
      hr_utility.set_message(8302,'PQH_INVALID_WORKSHEET_MODE');
      hr_utility.raise_error;
   elsif p_budget_id is null then
      hr_utility.set_message(8302,'PQH_INVALID_BUDGET');
      hr_utility.raise_error;
   elsif p_worksheet_mode in ('O','N') and p_budget_version_id is null then
      hr_utility.set_message(8302,'PQH_INVALID_BUDGET_VERSION');
      hr_utility.raise_error;
   elsif p_wks_start_date is null then
      hr_utility.set_message(8302,'PQH_START_DT_NULL');
      hr_utility.raise_error;
   elsif p_wks_end_date is null then
      hr_utility.set_message(8302,'PQH_END_DT_NULL');
      hr_utility.raise_error;
   elsif p_wks_start_date > p_wks_end_date then
      hr_utility.set_message(8302,'PQH_INVALID_END_DT');
      hr_utility.set_message_token('STARTDATE',fnd_date.date_to_chardate(p_wks_start_date));
      hr_utility.set_message_token('ENDDATE',fnd_date.date_to_chardate(p_wks_end_date));
      hr_utility.raise_error;
   end if;
   if p_budget_version_id is not null then
      open c1;
      fetch c1 into l_ver_chk;
      if c1%notfound then
         close c1;
         hr_utility.set_message(8302,'PQH_INVALID_BUDGET_VER');
         hr_utility.raise_error;
      end if;
      close c1;
   end if;
   hr_utility.set_location('wks_mode is '||p_worksheet_mode||l_proc,20);
   if p_worksheet_mode in ('S','N') then
   -- in the case of start from scratch, worksheet dates should be greater than all the existing
   -- version dates as it is going to make a new version in all cases, if the dates
   -- are not highest in that case status is returned as error
   -- budget_version_id may be null but budget_id should be there.
   -- gaps are also ok
      open c0;
      fetch c0 into l_max_version;
      close c0;
      hr_utility.set_location('max_version is '||l_max_version||l_proc,30);
      open c2;
      fetch c2 into l_max_end_date;
      if c2%notfound then
         hr_utility.set_location('max_end_date notfound '||l_proc,40);
	 if p_worksheet_mode ='S' then
	    -- no dates in the budget version as it is a initial case so
	    p_status := 'SUCCESS' ;
	 else
            -- mode is correction but no records
	    p_status := 'ERROR' ;
	 end if;
      else
         hr_utility.set_location('max_end_date is '||l_max_end_date||l_proc,50);
         if l_max_end_date is not null then
            if p_wks_start_date = l_max_end_date + 1 then
               -- start date is valid as it is not overlapping and nor giving any gap.
	       p_wks_ll_date := l_max_end_date+1 ;
	       p_wks_ul_date := l_max_end_date+1 ;
	       p_status := 'SUCCESS' ;
            elsif p_wks_start_date >= l_max_end_date +1 then
               -- gaps will be there but no overlapping
	       p_wks_ll_date := l_max_end_date+1 ;
	       p_status := 'SUCCESS' ;
            else
               -- invalid start date
	       p_wks_ll_date := l_max_end_date+1 ;
	       p_status := 'ERROR' ;
            end if;
         else
	    p_status := 'SUCCESS' ;
         end if;
      end if;
      close c2;
      hr_utility.set_location('end of validation with status'||p_status||l_proc,60);
   else
      open c3;
      fetch c3 into l_version_number;
      close c3;
      pqh_bdgt.bgv_date_validation( p_budget_id      => p_budget_id,
                                    p_version_number => l_version_number ,
                                    p_date_from      => p_wks_start_date,
                                    p_date_to        => p_wks_end_date,
                                    p_bgv_ll_date    => p_wks_ll_date,
                                    p_bgv_ul_date    => p_wks_ul_date,
                                    p_status         => p_status ) ;
      hr_utility.set_location('end of validation with status'||p_status||l_proc,170);
   end if;
exception when others then
p_wks_ll_date        := null;
p_wks_ul_date        := null;
p_status             := 'ERROR';
raise;
end wks_date_validation;

procedure propagate_bottom_up(p_worksheet_detail_id in number,
                              p_budget_unit1_value  in out nocopy number,
                              p_budget_unit2_value  in out nocopy number,
                              p_budget_unit3_value  in out nocopy number,
                              p_status                 out nocopy varchar2
 ) is


init_budget_unit1_value  number := p_budget_unit1_value;
init_budget_unit2_value  number := p_budget_unit2_value;
init_budget_unit3_value  number := p_budget_unit3_value;

   cursor c1 is select worksheet_detail_id,object_version_number,
                       budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       old_unit1_value,old_unit2_value,old_unit3_value
                from pqh_worksheet_details
                where parent_worksheet_detail_id = p_worksheet_detail_id
                and action_cd ='D';
   l_object_version_number number;
   l_budget_unit1_value number;
   l_budget_unit2_value number;
   l_budget_unit3_value number;
   l_lck_success boolean := FALSE;
   l_status varchar2(30) ;
begin
   hr_utility.set_location('entering bootom_up for wkd'||p_worksheet_detail_id,05);
   for i in c1 loop
       hr_utility.set_location('inside the loop for wkd'||i.worksheet_detail_id,10);
       begin
          hr_utility.set_location('going to lock'||i.worksheet_detail_id,20);
          pqh_wdt_shd.lck(p_worksheet_detail_id   => i.worksheet_detail_id,
                          p_object_version_number => i.object_version_number );
          l_lck_success := TRUE;
          hr_utility.set_location('lock success',30);
       exception
	  when others then
             hr_utility.set_location('lock failed',40);
             l_lck_success := FALSE;
             if p_status <> 'LOCK' then
                p_status := 'LOCK';
             end if;
       end;
       if l_lck_success then
	  hr_utility.set_location('going for propagation',50);
          l_object_version_number := i.object_version_number;
          l_budget_unit1_value    := i.budget_unit1_value;
          l_budget_unit2_value    := i.budget_unit2_value;
          l_budget_unit3_value    := i.budget_unit3_value;
	  hr_utility.set_location('calling propagate bottom_up',60);
	  begin
             propagate_bottom_up(p_worksheet_detail_id => i.worksheet_detail_id,
			         p_budget_unit1_value  => l_budget_unit1_value,
			         p_budget_unit2_value  => l_budget_unit2_value,
			         p_budget_unit3_value  => l_budget_unit3_value,
                                 p_status              => l_status);
          end;
          if nvl(l_status,'X') = 'LOCK' then
             p_status := 'LOCK';
          end if;
          p_budget_unit1_value := nvl(p_budget_unit1_value,0) -  nvl(i.old_unit1_value,0) + nvl(l_budget_unit1_value,0) ;
          p_budget_unit1_value := nvl(p_budget_unit1_value,0) -  nvl(i.old_unit1_value,0) + nvl(l_budget_unit1_value,0) ;
          p_budget_unit1_value := nvl(p_budget_unit1_value,0) -  nvl(i.old_unit1_value,0) + nvl(i.budget_unit1_value,0) ;
          pqh_budget.update_worksheet_detail(
                     p_worksheet_detail_id   => i.worksheet_detail_id,
                     p_object_version_number => l_object_version_number,
                     p_effective_date        => trunc(sysdate),
                     p_budget_unit1_value    => l_budget_unit1_value,
                     p_budget_unit2_value    => l_budget_unit2_value,
                     p_budget_unit3_value    => l_budget_unit3_value,
                     p_old_unit1_value       => l_budget_unit1_value,
                     p_old_unit2_value       => l_budget_unit2_value,
                     p_old_unit3_value       => l_budget_unit3_value);
      end if;
      hr_utility.set_location('end of the loop for wkd'||i.worksheet_detail_id,120);
   end loop;
   hr_utility.set_location('exiting propagate_bottom_up for wkd'||p_worksheet_detail_id,130);
exception when others then
p_budget_unit1_value  := init_budget_unit1_value;
p_budget_unit2_value  := init_budget_unit2_value;
p_budget_unit3_value  := init_budget_unit3_value;
p_status := null;
raise;
end propagate_bottom_up;
procedure populate_bud_grades(p_budget_version_id in number,
			      p_business_group_id in number,
                              p_rows_inserted        out nocopy number) is
   l_budget_start_date date;
   l_budget_end_date date;
   l_valid_grade_flag pqh_budgets.valid_grade_reqd_flag%type;
   l_budgeted_entity_cd pqh_budgets.budgeted_entity_cd%type;

   cursor c0 is select budget_start_date,budget_end_date,valid_grade_reqd_flag,budgeted_entity_cd
                from pqh_budgets bgt, pqh_budget_versions bgv
                where bgv.budget_id = bgt.budget_id
                and bgv.budget_version_id = p_budget_version_id;
   cursor c1 is select grade_id from per_grades a
		where business_group_id = p_business_group_id
                and ((nvl(l_valid_grade_flag,'N') = 'Y' and l_budgeted_entity_cd = 'GRADE' and
                     a.grade_id in (select b.grade_id from per_valid_grades b
                                   where  b.date_from < l_budget_end_date
                                   and   (b.date_to > l_budget_start_date or b.date_to is null)))
                    or (nvl(l_valid_grade_flag,'N') = 'N' and date_from < l_budget_end_date
                        and (date_to > l_budget_start_date or date_to is null)))
                and pqh_budget.already_budgeted_grd(a.grade_id) = 'FALSE' ;
   l_budget_detail_id number;
   l_rows_inserted number := 0;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_bud_grades' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date,l_valid_grade_flag,l_budgeted_entity_cd;
   close c0;
   hr_utility.set_location('budget_start_date is'||to_char(l_budget_start_date,'DD/MM/RRRR')||l_proc,11);
   hr_utility.set_location('budget_end_date is'||to_char(l_budget_end_date,'DD/MM/RRRR')||l_proc,12);
   for i in c1 loop
      l_rows_inserted := l_rows_inserted + 1;
      pqh_budget_details_api.create_budget_detail(
         p_validate                   => FALSE
        ,p_budget_detail_id           => l_budget_detail_id
        ,p_budget_version_id          => p_budget_version_id
        ,p_organization_id            => ''
        ,p_position_id                => ''
        ,p_job_id                     => ''
        ,p_grade_id                   => i.grade_id
        ,p_budget_unit1_value         => ''
        ,p_budget_unit1_percent       => ''
        ,p_budget_unit1_available     => ''
        ,p_budget_unit1_value_type_cd => ''
        ,p_budget_unit2_value         => ''
        ,p_budget_unit2_percent       => ''
        ,p_budget_unit2_available     => ''
        ,p_budget_unit2_value_type_cd => ''
        ,p_budget_unit3_value         => ''
        ,p_budget_unit3_percent       => ''
        ,p_budget_unit3_available     => ''
        ,p_budget_unit3_value_type_cd => ''
        ,p_object_version_number      => l_object_version_number
      );
      pqh_budget.insert_grd_is_bud(i.grade_id);
   end loop;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_rows_inserted := null;
raise;
end populate_bud_grades;

procedure populate_bud_jobs(p_budget_version_id in number,
			    p_business_group_id in number,
                            p_rows_inserted        out nocopy number) is
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_budget_versions bgv
                where bgv.budget_id = bgt.budget_id
                and bgv.budget_version_id = p_budget_version_id;
   cursor c1 is select job_id from per_jobs job, per_job_groups jgr
		where job.job_group_id = jgr.job_group_id and jgr.internal_name = 'HR_' || job.business_group_id
                and job.business_group_id = p_business_group_id
                and date_from < l_budget_end_date
                and (date_to > l_budget_start_date or date_to is null)
                and pqh_budget.already_budgeted_job(job_id) = 'FALSE';
   l_budget_detail_id number;
   l_rows_inserted number := 0;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_bud_jobs' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget_start_date is'||to_char(l_budget_start_date,'DD/MM/RRRR')||l_proc,11);
   hr_utility.set_location('budget_end_date is'||to_char(l_budget_end_date,'DD/MM/RRRR')||l_proc,12);
   for i in c1 loop
      l_rows_inserted := l_rows_inserted + 1;
      pqh_budget_details_api.create_budget_detail(
         p_validate                   => FALSE
        ,p_budget_detail_id           => l_budget_detail_id
        ,p_budget_version_id          => p_budget_version_id
        ,p_organization_id            => ''
        ,p_position_id                => ''
        ,p_job_id                     => i.job_id
        ,p_grade_id                   => ''
        ,p_budget_unit1_value         => ''
        ,p_budget_unit1_percent       => ''
        ,p_budget_unit1_available     => ''
        ,p_budget_unit1_value_type_cd => ''
        ,p_budget_unit2_value         => ''
        ,p_budget_unit2_percent       => ''
        ,p_budget_unit2_available     => ''
        ,p_budget_unit2_value_type_cd => ''
        ,p_budget_unit3_value         => ''
        ,p_budget_unit3_percent       => ''
        ,p_budget_unit3_available     => ''
        ,p_budget_unit3_value_type_cd => ''
        ,p_object_version_number      => l_object_version_number
      );
      pqh_budget.insert_job_is_bud(i.job_id);
   end loop;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_rows_inserted := null;
raise;
end populate_bud_jobs;
procedure populate_bud_positions(p_budget_version_id     in number,
				 p_org_hier_ver          in number,
				 p_start_organization_id in number,
			         p_business_group_id     in number,
                                 p_rows_inserted        out nocopy number) is
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_budget_versions bgv
                where bgv.budget_id = bgt.budget_id
                and bgv.budget_version_id = p_budget_version_id;
   cursor c1 is select position_id,job_id,pos.organization_id organization_id
		from hr_positions pos,hr_organization_units org
		where org.business_group_id = p_business_group_id
		and pos.business_group_id   = p_business_group_id
		and pos.organization_id = org.organization_id
                and pos.effective_start_date < l_budget_end_date
                and pos.effective_end_date > l_budget_start_date
                and pqh_budget.already_budgeted_pos(position_id) = 'FALSE'
                and get_position_budget_flag(pos.availability_status_id) = 'Y';
   cursor c2 is select position_id,job_id,organization_id
               from  ( select organization_id_child from pqh_worksheet_organizations_v
		       where org_structure_version_id = p_org_hier_ver
                      connect by prior organization_id_child = organization_id_parent
                                  and org_structure_version_id = p_org_hier_ver
		      start with organization_id_parent = p_start_organization_id
                                  and org_structure_version_id = p_org_hier_ver
		      union
		      select p_start_organization_id organization_id_child from dual )x,
		hr_positions_f
		where pqh_budget.already_budgeted_pos(position_id) = 'FALSE'
                and get_position_budget_flag(availability_status_id) = 'Y'
                and effective_start_date < l_budget_end_date
                and effective_end_date > l_budget_start_date
		and organization_id = x.organization_id_child ;
   l_budget_detail_id number;
   l_rows_inserted number := 0;
   l_object_version_number number := 1;
   l_proc varchar2(100) := g_package||'populate_budget_positions' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   hr_utility.set_location('business_group_id is '||p_business_group_id||l_proc,11);
   hr_utility.set_location('org_hier is '||p_org_hier_ver||l_proc,13);
   hr_utility.set_location('start organization is '||p_start_organization_id||l_proc,15);
   open c0;
   fetch c0 into l_budget_start_date, l_budget_end_date;
   close c0;
   if p_org_hier_ver is null then
      hr_utility.set_location('Business group cursor selected '||l_proc,20);
      for i in c1 loop
         l_rows_inserted := l_rows_inserted + 1;
         pqh_budget_details_api.create_budget_detail(
            p_validate                   => FALSE
           ,p_budget_detail_id           => l_budget_detail_id
           ,p_budget_version_id          => p_budget_version_id
           ,p_organization_id            => i.organization_id
           ,p_position_id                => i.position_id
           ,p_job_id                     => i.job_id
           ,p_grade_id                   => ''
           ,p_budget_unit1_value         => ''
           ,p_budget_unit1_percent       => ''
           ,p_budget_unit1_available     => ''
           ,p_budget_unit1_value_type_cd => ''
           ,p_budget_unit2_value         => ''
           ,p_budget_unit2_percent       => ''
           ,p_budget_unit2_available     => ''
           ,p_budget_unit2_value_type_cd => ''
           ,p_budget_unit3_value         => ''
           ,p_budget_unit3_percent       => ''
           ,p_budget_unit3_available     => ''
           ,p_budget_unit3_value_type_cd => ''
           ,p_object_version_number      => l_object_version_number
         );
         pqh_budget.insert_pos_is_bud(i.position_id);
         hr_utility.set_location('position inserted '||i.position_id||l_proc,40);
      end loop;
   else
      hr_utility.set_location('Org hierarchy cursor selected '||l_proc,45);
      for i in c2 loop
         l_rows_inserted := l_rows_inserted + 1;
         pqh_budget_details_api.create_budget_detail(
            p_validate                   => FALSE
           ,p_budget_detail_id           => l_budget_detail_id
           ,p_budget_version_id          => p_budget_version_id
           ,p_organization_id            => i.organization_id
           ,p_position_id                => i.position_id
           ,p_job_id                     => i.job_id
           ,p_grade_id                   => ''
           ,p_budget_unit1_value         => ''
           ,p_budget_unit1_percent       => ''
           ,p_budget_unit1_available     => ''
           ,p_budget_unit1_value_type_cd => ''
           ,p_budget_unit2_value         => ''
           ,p_budget_unit2_percent       => ''
           ,p_budget_unit2_available     => ''
           ,p_budget_unit2_value_type_cd => ''
           ,p_budget_unit3_value         => ''
           ,p_budget_unit3_percent       => ''
           ,p_budget_unit3_available     => ''
           ,p_budget_unit3_value_type_cd => ''
           ,p_object_version_number      => l_object_version_number
         );
         pqh_budget.insert_pos_is_bud(i.position_id);
         hr_utility.set_location('position inserted '||i.position_id||l_proc,50);
      end loop;
   end if;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('exiting '||l_proc,90);
exception when others then
p_rows_inserted := null;
raise;
end populate_bud_positions;
procedure populate_bud_organizations(p_budget_version_id     in number,
				     p_org_hier_ver          in number,
				     p_start_organization_id in number,
			             p_business_group_id     in number,
                                     p_rows_inserted        out nocopy number) is
   l_budget_start_date date;
   l_budget_end_date date;
   cursor c0 is select budget_start_date,budget_end_date
                from pqh_budgets bgt, pqh_budget_versions bgv
                where bgv.budget_id = bgt.budget_id
                and bgv.budget_version_id = p_budget_version_id;
   cursor c1 is select organization_id
		from hr_all_organization_units
		where business_group_id = p_business_group_id
		and date_from < l_budget_end_date
		and (date_to > l_budget_start_date or date_to is null)
		and DECODE(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE',
                 HR_SECURITY.SHOW_RECORD('HR_ALL_ORGANIZATION_UNITS', ORGANIZATION_ID))='TRUE'
		--and decode(hr_general.get_xbg_profile,'Y', business_group_id , hr_general.get_business_group_id) = business_group_id
		and pqh_budget.already_budgeted_org(organization_id) = 'FALSE';
   cursor c2 is select w.organization_id_child organization_id
                      from pqh_worksheet_organizations_v w
                      where org_structure_version_id = p_org_hier_ver
                      and pqh_budget.already_budgeted_org(w.organization_id_child) = 'FALSE'
                      and exists
                      (select null
                       from hr_all_organization_units hao
                       where organization_id = w.organization_id_child
                       and date_from < l_budget_end_date
                       and (date_to > l_budget_start_date or date_to is null)
                       and DECODE(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE',
                        HR_SECURITY.SHOW_RECORD('HR_ALL_ORGANIZATION_UNITS', HAO.ORGANIZATION_ID))='TRUE' )
                       --AND decode(hr_general.get_xbg_profile,'Y', hao.business_group_id , hr_general.get_business_group_id) = hao.business_group_id)
                      connect by prior organization_id_child = organization_id_parent
                                   and org_structure_version_id = p_org_hier_ver
                      start with organization_id_parent = p_start_organization_id
                                   and org_structure_version_id = p_org_hier_ver
                union
                select organization_id
                from hr_all_organization_units hao
                where organization_id = p_start_organization_id
                and pqh_budget.already_budgeted_org(p_start_organization_id) = 'FALSE'
                and date_from < l_budget_end_date
                and (date_to > l_budget_start_date or date_to is null)
                and DECODE(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE',
                        HR_SECURITY.SHOW_RECORD('HR_ALL_ORGANIZATION_UNITS', HAO.ORGANIZATION_ID))='TRUE' ;
                --AND decode(hr_general.get_xbg_profile,'Y', hao.business_group_id ,
                 --                hr_general.get_business_group_id) = hao.business_group_id;

   l_budget_detail_id number;
   l_object_version_number number := 1;
   l_rows_inserted number := 0;
   l_proc varchar2(100) := g_package||'populate_bud_orgs' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   open c0;
   fetch c0 into l_budget_start_date,l_budget_end_date;
   close c0;
   hr_utility.set_location('budget_start_date is'||to_char(l_budget_start_date,'DD/MM/RRRR')||l_proc,11);
   hr_utility.set_location('budget_end_date is'||to_char(l_budget_end_date,'DD/MM/RRRR')||l_proc,12);
   if p_org_hier_ver is null then
      hr_utility.set_location('bg is used '||l_proc,20);
      for i in c1 loop
         hr_utility.set_location('in loop for '||i.organization_id||l_proc,25);
         l_rows_inserted := l_rows_inserted + 1;
         pqh_budget_details_api.create_budget_detail(
            p_validate                   => FALSE
           ,p_budget_detail_id           => l_budget_detail_id
           ,p_budget_version_id          => p_budget_version_id
           ,p_organization_id            => i.organization_id
           ,p_position_id                => ''
           ,p_job_id                     => ''
           ,p_grade_id                   => ''
           ,p_budget_unit1_value         => ''
           ,p_budget_unit1_percent       => ''
           ,p_budget_unit1_available     => ''
           ,p_budget_unit1_value_type_cd => ''
           ,p_budget_unit2_value         => ''
           ,p_budget_unit2_percent       => ''
           ,p_budget_unit2_available     => ''
           ,p_budget_unit2_value_type_cd => ''
           ,p_budget_unit3_value         => ''
           ,p_budget_unit3_percent       => ''
           ,p_budget_unit3_available     => ''
           ,p_budget_unit3_value_type_cd => ''
           ,p_object_version_number      => l_object_version_number
         );
         hr_utility.set_location('inserting '||i.organization_id||l_proc,30);
         pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   else
      hr_utility.set_location('oh is used '||l_proc,40);
      for i in c2 loop
         l_rows_inserted := l_rows_inserted + 1;
         pqh_budget_details_api.create_budget_detail(
            p_validate                   => FALSE
           ,p_budget_detail_id           => l_budget_detail_id
           ,p_budget_version_id          => p_budget_version_id
           ,p_organization_id            => i.organization_id
           ,p_position_id                => ''
           ,p_job_id                     => ''
           ,p_grade_id                   => ''
           ,p_budget_unit1_value         => ''
           ,p_budget_unit1_percent       => ''
           ,p_budget_unit1_available     => ''
           ,p_budget_unit1_value_type_cd => ''
           ,p_budget_unit2_value         => ''
           ,p_budget_unit2_percent       => ''
           ,p_budget_unit2_available     => ''
           ,p_budget_unit2_value_type_cd => ''
           ,p_budget_unit3_value         => ''
           ,p_budget_unit3_percent       => ''
           ,p_budget_unit3_available     => ''
           ,p_budget_unit3_value_type_cd => ''
           ,p_object_version_number      => l_object_version_number
         );
         hr_utility.set_location('inserting '||i.organization_id||l_proc,50);
         pqh_budget.insert_org_is_bud(i.organization_id);
      end loop;
   end if;
   p_rows_inserted := l_rows_inserted;
   hr_utility.set_location('entering '||l_proc,60);
exception when others then
p_rows_inserted := null;
raise;
end populate_bud_organizations;
function get_wks_budget( p_worksheet_id in number) return number is
   cursor c1 is select budget_id from pqh_worksheets
                where worksheet_id = p_worksheet_id;
   l_budget_id number;
begin
   open c1;
   fetch c1 into l_budget_id ;
   close c1;
   return l_budget_id;
end get_wks_budget;
function get_wkd_budget( p_worksheet_detail_id in number) return number is
   cursor c1 is select worksheet_id from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id;
   l_worksheet_id number;
   l_budget_id number;
begin
   open c1;
   fetch c1 into l_worksheet_id ;
   close c1;
   l_budget_id := get_wks_budget(p_worksheet_id => l_worksheet_id);
   return l_budget_id;
end get_wkd_budget;
function get_bgd_budget( p_budget_detail_id in number) return number is
   cursor c1 is select budget_id
                from pqh_budget_versions bgv, pqh_budget_details bgd
                where bgd.budget_detail_id = p_budget_detail_id
                and bgd.budget_version_id = bgv.budget_version_id ;
   l_budget_id number;
begin
   open c1;
   fetch c1 into l_budget_id ;
   close c1;
   return l_budget_id;
end get_bgd_budget;
procedure insert_default_period(p_worksheet_detail_id   in     number,
                                p_wkd_ovn               in out nocopy number,
                                p_worksheet_unit1_value in     number default null,
                                p_worksheet_unit2_value in     number default null,
                                p_worksheet_unit3_value in     number default null,
                                p_worksheet_period_id      out nocopy number,
                                p_wpr_ovn                  out nocopy number) is
   l_wkd_ovn number := p_wkd_ovn;
   l_budget_id number;
   l_calendar varchar2(30);
   l_budget_start_date date;
   l_budget_end_date date;
   l_period_start_date date;
   l_period_end_date date;
   l_start_time_period_id number;
   l_end_time_period_id number;
   cursor c1 is
   select time_period_id,start_date
   from per_time_periods
   where period_set_name = l_calendar
   and start_date >= l_budget_start_date
   and start_date < l_budget_end_date
   order by start_date;
   cursor c2 is
   select time_period_id,end_date
   from per_time_periods
   where period_set_name = l_calendar
   and end_date > l_budget_start_date
   and end_date <= l_budget_end_date
   and end_date > l_period_start_date
   order by end_date desc;
   l_proc varchar2(100) := g_package||'insert_default_period' ;
begin
   hr_utility.set_location('entering  '||l_proc,10);
   hr_utility.set_location('unit1_value  '||p_worksheet_unit1_value||l_proc,11);
   hr_utility.set_location('unit2_value  '||p_worksheet_unit2_value||l_proc,12);
   hr_utility.set_location('unit3_value  '||p_worksheet_unit3_value||l_proc,13);
   l_budget_id := get_wkd_budget(p_worksheet_detail_id);
   hr_utility.set_location('budget id is  '||l_budget_id||l_proc,20);
   select period_set_name,budget_start_date,budget_end_date
   into l_calendar,l_budget_start_date,l_budget_end_date
   from pqh_budgets
   where budget_id = l_budget_id;
   hr_utility.set_location('calendar id is  '||l_calendar||l_proc,30);
   hr_utility.set_location('budget start date is  '||to_char(l_budget_start_date,'DD/MM/RRRR')||l_proc,40);
   hr_utility.set_location('budget_end date id is  '||to_char(l_budget_end_date,'DD/MM/RRRR')||l_proc,50);
   open c1;
   fetch c1 into l_start_time_period_id,l_period_start_date;
   hr_utility.set_location('period_start date id is  '||to_char(l_period_start_date,'DD/MM/RRRR')||l_proc,60);
   if c1%found then
      open c2;
      fetch c2 into l_end_time_period_id,l_period_end_date;
      hr_utility.set_location('period_end date id is  '||to_char(l_period_end_date,'DD/MM/RRRR')||l_proc,70);
      close c2;
   end if;
   close c1;
   if l_end_time_period_id is null then
      hr_utility.set_location('no period lies during budget life'||l_proc,80);
      pqh_budget.update_worksheet_detail(
                 p_worksheet_detail_id    => p_worksheet_detail_id,
                 p_object_version_number  => p_wkd_ovn,
                 p_effective_date         => trunc(sysdate),
                 p_budget_unit1_available => p_worksheet_unit1_value,
                 p_budget_unit2_available => p_worksheet_unit1_value,
                 p_budget_unit3_available => p_worksheet_unit1_value);
      hr_utility.set_location('ovn of wkd after is'||p_wkd_ovn||l_proc,90);
   else
      hr_utility.set_location('inserting worksheet period '||l_proc,100);
      pqh_worksheet_periods_api.create_worksheet_period
      (
       p_worksheet_period_id           => p_worksheet_period_id
      ,p_end_time_period_id            => l_end_time_period_id
      ,p_worksheet_detail_id           => p_worksheet_detail_id
      ,p_budget_unit1_percent          => 100
      ,p_budget_unit2_percent          => 100
      ,p_budget_unit3_percent          => 100
      ,p_budget_unit1_value            => p_worksheet_unit1_value
      ,p_budget_unit2_value            => p_worksheet_unit2_value
      ,p_budget_unit3_value            => p_worksheet_unit3_value
      ,p_object_version_number         => p_wpr_ovn
      ,p_budget_unit1_value_type_cd    => 'P'
      ,p_budget_unit2_value_type_cd    => 'P'
      ,p_budget_unit3_value_type_cd    => 'P'
      ,p_start_time_period_id          => l_start_time_period_id
      ,p_budget_unit1_available        => p_worksheet_unit1_value
      ,p_budget_unit2_available        => p_worksheet_unit2_value
      ,p_budget_unit3_available        => p_worksheet_unit3_value
      ,p_effective_date                => trunc(sysdate)
      );
   end if;
   hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_wkd_ovn := l_wkd_ovn;
p_worksheet_period_id := null;
p_wpr_ovn := null;
raise;
end insert_default_period;

procedure apply_wks(p_transaction_id          in number,
                   p_transaction_category_id in number,
                   p_wkd_ovn                 out nocopy number,
                   p_wks_ovn                 out nocopy number) IS
   l_transaction_status varchar2(30);
   l_wkd_ovn number;
   l_wks_ovn number;
   l_proc varchar2(61) := g_package||'apply_wks' ;
BEGIN
   hr_utility.set_location('entering '||l_proc,10);
   approve_wks(p_transaction_id          => p_transaction_id,
               p_transaction_category_id => p_transaction_category_id,
               p_wkd_ovn                 => l_wkd_ovn,
               p_wks_ovn                 => l_wks_ovn);
   hr_utility.set_location(l_proc||'wks_ovn is '||l_wks_ovn,20);
   hr_utility.set_location(l_proc||'wkd_ovn is '||l_wkd_ovn,30);
   pqh_budget.complete_workflow(p_worksheet_detail_id       => p_transaction_id,
                                p_transaction_category_id   => p_transaction_category_id,
                                p_result_status             => 'SUBMITTED',
                                p_wkd_object_version_number => p_wkd_ovn,
                                p_wks_object_version_number => p_wks_ovn);
   hr_utility.set_location(l_proc||'wks_ovn is '||l_wks_ovn,40);
   hr_utility.set_location(l_proc||'wkd_ovn is '||l_wkd_ovn,50);
exception when others then
p_wkd_ovn := null;
p_wks_ovn := null;
raise;
END;
procedure pending_wks(p_transaction_id in number,
                      p_transaction_category_id in number,
                      p_wkd_ovn                 out nocopy number,
                      p_wks_ovn                 out nocopy number) IS
   l_user varchar2(100);
   l_transaction_status varchar2(30);
   l_status varchar2(30);
   l_working_users varchar2(2000);
   l_proc varchar2(61) := g_package||'pending_wks' ;
BEGIN
   hr_utility.set_location('entering'||l_proc,10);
   pqh_budget.complete_workflow(p_worksheet_detail_id       => p_transaction_id,
                                p_transaction_category_id   => p_transaction_category_id,
                                p_result_status             => 'PENDING',
                                p_wkd_object_version_number => p_wkd_ovn,
                                p_wks_object_version_number => p_wks_ovn);
   hr_utility.set_location(l_proc||'wks_ovn is '||p_wks_ovn,40);
   hr_utility.set_location(l_proc||'wkd_ovn is '||p_wkd_ovn,50);
exception when others then
p_wkd_ovn := null;
p_wks_ovn := null;
raise;
END;
procedure approve_wks(p_transaction_id in number,
                      p_transaction_category_id in number,
                      p_wkd_ovn                 out nocopy number,
                      p_wks_ovn                 out nocopy number) IS
   l_user varchar2(100);
   l_transaction_status varchar2(30);
   l_status varchar2(30);
   l_working_users varchar2(2000);
   l_proc varchar2(61) := g_package||'approve_wks' ;
BEGIN
   hr_utility.set_location('entering'||l_proc,10);
   pqh_budget.lock_all_children(p_worksheet_detail_id     => p_transaction_id,
                                p_transaction_category_id => p_transaction_category_id,
                                p_status                  => l_status,
                                p_working_users           => l_working_users);
   hr_utility.set_location('child locked'||l_proc,20);
   if nvl(l_status,'Y') ='Y' then
      -- close notifications and change status
      hr_utility.set_location('changing status'||l_proc,30);
      pqh_budget.complete_workflow(p_worksheet_detail_id         => p_transaction_id,
                                   p_transaction_category_id     => p_transaction_category_id,
                                   p_result_status               => 'APPROVED',
                                   p_wkd_object_version_number   => p_wkd_ovn,
                                   p_wks_object_version_number   => p_wks_ovn);
      hr_utility.set_location('status changed'||l_proc,40);
   else
      hr_utility.set_message(8302,'PQH_WKS_CHILD_WORKING');
      hr_utility.set_message_token('USERS',l_working_users);
      hr_utility.raise_error;
   end if;
   hr_utility.set_location('wks out nocopy ovn is'||p_wks_ovn||l_proc,90);
   hr_utility.set_location('wkd out nocopy ovn is'||p_wkd_ovn||l_proc,100);
exception when others then
p_wkd_ovn := null;
p_wks_ovn := null;
raise;
END;
procedure reject_wks(p_transaction_id in number,
                     p_transaction_category_id in number,
                     p_wkd_ovn                 out nocopy number,
                     p_wks_ovn                 out nocopy number) IS
   l_user varchar2(100);
   l_transaction_status varchar2(30);
   l_status varchar2(30);
   l_working_users varchar2(2000);
   l_proc varchar2(61) := g_package||'reject_wks' ;
BEGIN
   hr_utility.set_location('entering'||l_proc,10);
   -- if the current user is the initiator of the txn then mark the status
   -- as reject else status remains the same and notification will be sent to initiator.
   l_user := pqh_wf.get_requestor(p_transaction_category_id => p_transaction_category_id,
                                  p_transaction_id          => p_transaction_id);
   hr_utility.set_location('requestor is'||l_user||l_proc,20);
   -- change the status of the delegated rows to reject
   -- and all open notifications to be killed
   -- depending upon the initator of the delegated row
   if l_user is null or l_user = fnd_profile.value('USERNAME') then
      hr_utility.set_location('going for lock'||l_proc,30);
      pqh_budget.lock_all_children(p_worksheet_detail_id     => p_transaction_id,
                                   p_transaction_category_id => p_transaction_category_id,
                                   p_status                  => l_status,
                                   p_working_users           => l_working_users);
      hr_utility.set_location('locked'||l_proc,40);
      if nvl(l_status,'Y') ='Y' then
         -- notifications are to be closed and change status
         hr_utility.set_location('changing status'||l_proc,50);
         pqh_budget.complete_workflow(p_worksheet_detail_id       => p_transaction_id,
                                      p_transaction_category_id   => p_transaction_category_id,
                                      p_result_status             => 'REJECT',
                                      p_wkd_object_version_number => p_wkd_ovn,
                                      p_wks_object_version_number => p_wks_ovn);
         hr_utility.set_location('status changed'||l_proc,60);
      else
         hr_utility.set_message(8302,'PQH_WKS_CHILD_WORKING');
         hr_utility.set_message_token('USERS',l_working_users);
         hr_utility.raise_error;
      end if;
   else
      hr_utility.set_location('changing status'||l_proc,70);
      pqh_budget.complete_workflow(p_worksheet_detail_id       => p_transaction_id,
                                   p_transaction_category_id   => p_transaction_category_id,
                                   p_result_status             => 'PENDING',
                                   p_wkd_object_version_number => p_wkd_ovn,
                                   p_wks_object_version_number => p_wks_ovn);
      hr_utility.set_location('status changed'||l_proc,80);
   end if;
   hr_utility.set_location('wks out nocopy ovn is'||p_wks_ovn||l_proc,90);
   hr_utility.set_location('wkd out nocopy ovn is'||p_wkd_ovn||l_proc,100);
exception when others then
p_wkd_ovn := null;
p_wks_ovn := null;
raise;
END;
function get_transaction_name(p_worksheet_detail_id in number) return varchar2 is
   l_worksheet_name varchar2(240);
   l_org_name       hr_all_organization_units.name%type;
   l_org_id         number;
   l_transaction_name varchar2(300);
   cursor c1 is
   select wks.worksheet_name,wkd.organization_id
   from pqh_worksheets wks, pqh_worksheet_details wkd
   where wkd.worksheet_id = wks.worksheet_id
   and worksheet_detail_id = p_worksheet_detail_id
   and nvl(action_cd,'D') ='D';
begin
   open c1;
   fetch c1 into l_worksheet_name,l_org_id;
   close c1;
   --
   if l_org_id is not null then
      l_org_name := hr_general.decode_organization(l_org_id);
      l_transaction_name := l_worksheet_name||'('||l_org_name||')';
   else
      l_transaction_name := l_worksheet_name;
   end if;
   return l_transaction_name;
end;

Function check_job_pos_for_valid_grd(p_position_id  number default null,
                                     p_job_id       number default null,
                                     p_grade_id     number default null,
                                     p_valid_grade_flag varchar2 default null)
Return varchar2 is
Cursor C_position is select valid_grade_id
             from   per_valid_grades
             where  position_id = p_position_id
             and    grade_id = p_grade_id
             and    rownum < 2;

Cursor C_job is select valid_grade_id
             from   per_valid_grades
             where  job_id = p_job_id
             and    grade_id = p_grade_id
             and    rownum < 2;

l_valid_grade_id per_valid_grades.valid_grade_id%type;
Begin
  If nvl(p_grade_id,0) <> 0 then
    If nvl(p_valid_grade_flag,'N') = 'Y' then
      If p_position_id is not null then
        Open C_position;
        Fetch C_position into l_valid_grade_id;
        Close C_position;
      Elsif p_job_id is not null then
        Open C_job;
        Fetch C_job into l_valid_grade_id;
        Close C_job;
      End if;
      If l_valid_grade_id is null then
        Return 'FALSE';
      Else
        Return 'TRUE';
      End If;
    Else
      Return 'TRUE';
    End If;
  Else
    Return 'TRUE';
  End if;
End;

Function get_valid_grade(p_position_id  number default null,
                         p_job_id       number default null,
                         p_grade_id     number default null,
                         p_start_bud_date date,
                         p_end_bud_date   date)
Return varchar2 is
l_job_id per_valid_grades.job_id%type :=p_job_id;
Cursor C_job is select valid_grade_id
             from   per_valid_grades
             where  job_id = l_job_id
             and    grade_id = p_grade_id
             and    date_from < p_end_bud_date
             and    (date_to > p_start_bud_date or date_to is null)
             and    rownum < 2;

Cursor C_position is select valid_grade_id
             from   per_valid_grades
             where  position_id = p_position_id
             and    grade_id = p_grade_id
             and    date_from < p_end_bud_date
             and    (date_to > p_start_bud_date or date_to is null)
             and    rownum < 2;

Cursor C2 is select valid_grade_id
             from   per_valid_grades
             where  grade_id = p_grade_id
             and    date_from < p_end_bud_date
             and    (date_to > p_start_bud_date or date_to is null)
             and    rownum < 2;
l_valid_grade_id per_valid_grades.valid_grade_id%type;
Begin
    If p_position_id is not null then
      Open C_position;
      Fetch C_position into l_valid_grade_id;
      Close C_position;
    Elsif l_job_id is not null then
      Open C_job;
      Fetch C_job into l_valid_grade_id;
      Close C_job;
    Elsif l_job_id is null and p_position_id is null then
      Open C2;
      Fetch C2 into l_valid_grade_id;
      Close C2;
    End If;
    If l_valid_grade_id is null then
      Return 'FALSE';
    Else
      Return 'TRUE';
    End If;
End;

Function get_position_budget_flag(p_availability_status_id in number)
return varchar2 is

l_budget_flag varchar2(150) := 'Y';
--
-- Get the budget flag value stored in the information1 column
--
Cursor c_budget_flag is
Select nvl(information1,'Y')
  from per_shared_types
 where lookup_type = 'POSITION_AVAILABILITY_STATUS'
   and shared_type_id = p_availability_status_id;

Begin
 --
 -- Fetch the Budget Flag value
 --
Open c_budget_flag;
Fetch c_budget_flag into l_budget_flag;
Close c_budget_flag;

Return l_budget_flag;

End;

/*
function valid_position_txn(p_position_transaction_id in number,
                            p_budget_start_date       in date,
                            p_budget_end_date         in date) is
   l_org_id number;
   l_job_id number;
   l_pos_start_date date;
   l_pos_end_date date;
   l_org_start_date date;
   l_org_end_date date;
   l_job_start_date date;
   l_job_end_date date;
begin
   select organization_id,job_id,effective_start_date,effective_end_date
   into l_org_id,l_job_id,l_pos_start_date,l_pos_end_date
   from pqh_position_transactions
   where position_transaction_id = p_position_transaction_id;
   if l_org_id is not null then
   end if;
   if l_job_id is not null then
   end if;
end valid_position_txn;
*/
procedure update_wkd_pot(p_worksheet_detail_id number) is
begin
   update pqh_worksheet_details
   set position_transaction_id = null
   where worksheet_detail_id = p_worksheet_detail_id;
end update_wkd_pot;

procedure purge_wkd(p_worksheet_detail_id in number,
                    p_budget_style_cd     in varchar2) is
   cursor c_worksheet_periods is select worksheet_period_id,object_version_number
      from pqh_worksheet_periods where worksheet_detail_id = p_worksheet_detail_id;
   cursor c_worksheet_budget_sets(p_worksheet_period_id number) is
      select worksheet_budget_set_id,object_version_number
      from pqh_worksheet_budget_sets where worksheet_period_id = p_worksheet_period_id;
   cursor c_worksheet_bdgt_elmnts (p_worksheet_budget_set_id number) is
      select worksheet_bdgt_elmnt_id,object_version_number
      from pqh_worksheet_bdgt_elmnts where worksheet_budget_set_id = p_worksheet_budget_set_id;
   cursor c_worksheet_fund_srcs (p_worksheet_bdgt_elmnt_id number) is
      select worksheet_fund_src_id,object_version_number
      from pqh_worksheet_fund_srcs where worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;
   l_parent_wkd_id number;
   l_budget_unit1_value number;
   l_budget_unit2_value number;
   l_budget_unit3_value number;
   l_object_version_number number;
begin
   for i in c_worksheet_periods loop
      for j in c_worksheet_budget_sets(i.worksheet_period_id) loop
         for k in c_worksheet_bdgt_elmnts(j.worksheet_budget_set_id) loop
            for l in c_worksheet_fund_srcs(k.worksheet_bdgt_elmnt_id) loop
               pqh_worksheet_fund_srcs_api.DELETE_WORKSHEET_FUND_SRC(
               P_WORKSHEET_FUND_SRC_ID => l.worksheet_fund_src_id,
               P_OBJECT_VERSION_NUMBER => l.object_version_number);
            end loop;
            pqh_worksheet_bdgt_elmnts_api.DELETE_WORKSHEET_BDGT_ELMNT(
            P_WORKSHEET_BDGT_ELMNT_ID => k.worksheet_bdgt_elmnt_id,
            P_OBJECT_VERSION_NUMBER => k.object_version_number);
         end loop;
         pqh_worksheet_budget_sets_api.DELETE_WORKSHEET_BUDGET_SET(
         P_WORKSHEET_BUDGET_SET_ID => j.worksheet_budget_set_id,
         P_EFFECTIVE_DATE      => trunc(sysdate),
         P_OBJECT_VERSION_NUMBER => j.object_version_number);
      end loop;
      pqh_worksheet_periods_api.DELETE_WORKSHEET_PERIOD(
      P_WORKSHEET_PERIOD_ID => i.worksheet_period_id,
      P_EFFECTIVE_DATE      => trunc(sysdate),
      P_OBJECT_VERSION_NUMBER => i.object_version_number);
   end loop;

   select parent_worksheet_detail_id,budget_unit1_value,budget_unit2_value,budget_unit3_value,object_version_number
   into l_parent_wkd_id,l_budget_unit1_value,l_budget_unit2_value,l_budget_unit3_value,l_object_version_number
   from pqh_worksheet_details where worksheet_detail_id = p_worksheet_detail_id;

   if p_budget_style_cd ='TOP' then
      update pqh_worksheet_details
      set budget_unit1_available = nvl(budget_unit1_available,0) - nvl(l_budget_unit1_value,0),
          budget_unit2_available = nvl(budget_unit2_available,0) - nvl(l_budget_unit2_value,0),
          budget_unit3_available = nvl(budget_unit3_available,0) - nvl(l_budget_unit3_value,0)
      where worksheet_detail_id = l_parent_wkd_id;
   else
      update pqh_worksheet_details
      set budget_unit1_value = nvl(budget_unit1_value,0) - nvl(l_budget_unit1_value,0),
          budget_unit2_value = nvl(budget_unit2_value,0) - nvl(l_budget_unit2_value,0),
          budget_unit3_value = nvl(budget_unit3_value,0) - nvl(l_budget_unit3_value,0)
      where worksheet_detail_id = l_parent_wkd_id;
   end if;
   pqh_worksheet_details_api.DELETE_WORKSHEET_DETAIL(
   P_WORKSHEET_DETAIL_ID => p_worksheet_detail_id,
   P_EFFECTIVE_DATE      => trunc(sysdate),
   P_OBJECT_VERSION_NUMBER => l_object_version_number);
end purge_wkd;
procedure delete_wkd(p_worksheet_detail_id in number,
                     p_object_version_number in number) is
   l_proc varchar2(100) := g_package||'delete_wkd' ;
   l_budget_id number;
   l_position_id number;
   l_budgeted_entity_cd varchar2(80);
   l_budget_style_cd    varchar2(80);
   l_worksheet_detail_id number;
   cursor c_worksheet_detail is
      select position_id,worksheet_detail_id
      from pqh_worksheet_details
      where worksheet_detail_id = p_worksheet_detail_id;
begin
/*
----------    logic of the program    --------------------------------
check whether worksheet detail exist in the system or not, if yes then do these
if primary budget entity is Position
   if Position_id is there then
      Position transaction should be updated to null
   else
      delete the dependent records of worksheet period, budgetsets etc.
      delete the worksheet_detail
      update the parent worksheet_detail balances
   end if;
else
   delete the dependent records of worksheet period, budgetsets etc.
   delete the worksheet_detail
   update the parent worksheet_detail balances
end if;
*/
----------    actual program    --------------------------------
   open c_worksheet_detail;
   fetch c_worksheet_detail into l_position_id,l_worksheet_detail_id;
   if c_worksheet_detail%found then
      l_budget_id := get_wkd_budget(p_worksheet_detail_id);
      select budgeted_entity_cd,budget_style_cd into l_budgeted_entity_cd,l_budget_style_cd
      from pqh_budgets where budget_id = l_budget_id;
      if l_budgeted_entity_cd ='POSITION' then
         if l_position_id is not null then
            update_wkd_pot(p_worksheet_detail_id => p_worksheet_detail_id);
         else
            purge_wkd(p_worksheet_detail_id => p_worksheet_detail_id,
                      p_budget_style_cd     => l_budget_style_cd);
         end if;
      else
         purge_wkd(p_worksheet_detail_id => p_worksheet_detail_id,
                   p_budget_style_cd     => l_budget_style_cd);
      end if;
   end if;
   close c_worksheet_detail;
end delete_wkd;

Function PQH_CHECK_GMS_INSTALLED
  RETURN  varchar2 IS
cursor gms is select a.status, a.application_id, b.application_short_name
from
fnd_product_installations a, fnd_application b
where
a.application_id = b.application_id
and
b.application_short_name = 'GMS' and status = 'I';
stat varchar2(10) := 'N';
BEGIN
for gms_rec in gms loop
stat := gms_rec.status;
end loop;
    RETURN stat;
EXCEPTION
   WHEN others THEN
    RETURN stat;
END; -- Function PQH_CHECK_GMS_INSTALL
end pqh_wks_budget;

/
