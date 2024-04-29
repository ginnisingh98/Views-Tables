--------------------------------------------------------
--  DDL for Package Body PQH_CBR_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CBR_ENGINE" as
/* $Header: pqcbreng.pkb 120.0 2005/05/29 01:36:58 appldev noship $ */
function build_message(p_application_id in number,
                       p_message_cd     in varchar2,
                       p_message_token1 in varchar2 default null,
                       p_message_param1 in varchar2 default null,
                       p_message_token2 in varchar2 default null,
                       p_message_param2 in varchar2 default null,
                       p_message_token3 in varchar2 default null,
                       p_message_param3 in varchar2 default null) return varchar2 is
   l_message fnd_new_messages.message_text%type;
   l_proc varchar2(71) := g_package||'build_message';
begin
   hr_utility.set_Location('inside'||l_proc,10);
   hr_utility.set_message(applid         => p_application_id,
                          l_message_name => p_message_cd);
   if p_message_param1 is not null then
      hr_utility.set_message_token(l_token_name => p_message_param1,
                                   l_token_value => p_message_token1);
   end if;
   if p_message_param2 is not null then
      hr_utility.set_message_token(l_token_name => p_message_param2,
                                   l_token_value => p_message_token2);
   end if;
   if p_message_param3 is not null then
      hr_utility.set_message_token(l_token_name => p_message_param3,
                                   l_token_value => p_message_token3);
   end if;
   l_message := hr_utility.get_message;
   hr_utility.set_Location('message'||substr(l_message,1,60),20);
   hr_utility.set_Location('leaving'||l_proc,100);
   return l_message;
end build_message;
procedure get_period_details (p_budget_period_id in number,
                              p_budget_entity_id in number,
                              p_prd_avl_amt      out nocopy number,
                              p_prd_act_amt      out nocopy number,
                              p_prd_com_amt      out nocopy number,
                              p_prd_don_amt      out nocopy number,
                              p_prd_res_amt      out nocopy number,
                              p_prd_bgt_amt      out nocopy number,
                              p_prd_start_date   out nocopy date) is
   l_prd_start_date date;
   l_prd_end_date date;
   l_job_id number;
   l_grade_id number;
   l_organization_id number;
   l_unit1_value number;
   l_unit2_value number;
   l_unit3_value number;
   l_proc varchar2(71) := g_package||'get_period_details';
begin
   hr_utility.set_Location('inside'||l_proc,10);
   select calstart.start_date,calend.end_date,budget_unit1_value,budget_unit2_value,budget_unit3_value
   into   l_prd_start_date,l_prd_end_date,l_unit1_value,l_unit2_value,l_unit3_value
   from   pqh_budget_periods per,per_time_periods calstart, per_time_periods calend
   where  budget_period_id = p_budget_period_id
   and    per.start_time_period_id = calstart.time_period_id
   and    per.end_time_period_id  = calend.time_period_id;

   if g_budget_unit_num = 1 then
      p_prd_bgt_amt := nvl(l_unit1_value,0);
   elsif g_budget_unit_num = 2 then
      p_prd_bgt_amt := nvl(l_unit2_value,0);
   elsif g_budget_unit_num = 3 then
      p_prd_bgt_amt := nvl(l_unit3_value,0);
   end if;
   hr_utility.set_Location('bgt_amt is'||p_prd_bgt_amt,20);
   if g_budget_entity ='POSITION' then
      p_prd_act_amt := pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
                                         (p_budget_version_id  => g_budget_version_id,
                                          p_position_id        => p_budget_entity_id,
                                          p_start_date         => l_prd_start_date,
                                          p_end_date           => l_prd_end_date,
                                          p_unit_of_measure_id => g_budget_unit_id,
                                          p_value_type         => 'A' ,
                                          p_currency_code      => g_budget_currency);
      hr_utility.set_Location('act_amt is'||p_prd_act_amt,30);
      if g_budget_unit_type ='M' then
         p_prd_com_amt:= pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
                                         (p_budget_version_id  => g_budget_version_id,
                                          p_position_id        => p_budget_entity_id,
                                          p_start_date         => l_prd_start_date,
                                          p_end_date           => l_prd_end_date,
                                          p_unit_of_measure_id => g_budget_unit_id,
                                          p_value_type         => 'C' ,
                                          p_currency_code      => g_budget_currency);
      else
         p_prd_com_amt := nvl(p_prd_act_amt,0);
      end if;
      hr_utility.set_Location('com_amt is'||p_prd_com_amt,40);
   else
      if g_budget_entity ='JOB' then
         l_job_id := p_budget_entity_id;
      elsif g_budget_entity ='GRADE' then
         l_grade_id := p_budget_entity_id;
      elsif g_budget_entity ='ORGANIZATION' then
         l_organization_id := p_budget_entity_id;
      end if;
      p_prd_act_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
                                         (p_budget_version_id    => g_budget_version_id,
                                          p_budgeted_entity_cd   => g_budget_entity,
                                          p_job_id               => l_job_id,
                                          p_grade_id             => l_grade_id,
                                          p_organization_id      => l_organization_id,
                                          p_start_date           => l_prd_start_date,
                                          p_end_date             => l_prd_end_date,
                                          p_unit_of_measure_id   => g_budget_unit_id,
                                          p_value_type           => 'A' ,
                                          p_currency_code        => g_budget_currency);
      hr_utility.set_Location('act_amt is'||p_prd_act_amt,50);
      if g_budget_unit_type ='M' then
         p_prd_com_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
                                         (p_budget_version_id    => g_budget_version_id,
                                          p_budgeted_entity_cd   => g_budget_entity,
                                          p_job_id               => l_job_id,
                                          p_grade_id             => l_grade_id,
                                          p_organization_id      => l_organization_id,
                                          p_start_date           => l_prd_start_date,
                                          p_end_date             => l_prd_end_date,
                                          p_unit_of_measure_id   => g_budget_unit_id,
                                          p_value_type           => 'C' ,
                                          p_currency_code        => g_budget_currency);
      else
         p_prd_com_amt := p_prd_act_amt;
      end if;
      hr_utility.set_Location('com_amt is'||p_prd_com_amt,60);
   end if;
   p_prd_don_amt := pqh_bdgt_realloc_utility.get_prd_realloc_reserved_amt
                                              (p_budget_period_id => p_budget_period_id,
                                               p_entity_type      => g_budget_entity,
                                               p_budget_unit_id   => g_budget_unit_id,
                                               p_transaction_type => 'DD', -- donated
                                               p_approval_status  => 'A', -- approved
                                               p_amount_type      => 'R'); -- Reallocated
   hr_utility.set_Location('don_amt is'||p_prd_don_amt,70);
   --
   p_prd_res_amt := pqh_bdgt_realloc_utility.get_prd_realloc_reserved_amt
                                              (p_budget_period_id => p_budget_period_id,
                                               p_entity_type      => g_budget_entity,
                                               p_budget_unit_id   => g_budget_unit_id,
                                               p_transaction_type => 'DD', -- donated
                                               p_approval_status  => 'A', -- approved
                                               p_amount_type      => 'RV'); -- Reserved
   hr_utility.set_Location('res_amt is'||p_prd_res_amt,80);
   --
   if g_budget_unit_type ='M' then
      p_prd_avl_amt := nvl(p_prd_bgt_amt,0) - nvl(p_prd_act_amt,0) - nvl(p_prd_com_amt,0) - nvl(p_prd_don_amt,0)- nvl(p_prd_res_amt,0);
   else
      p_prd_avl_amt := nvl(p_prd_bgt_amt,0) - nvl(p_prd_act_amt,0) - nvl(p_prd_don_amt,0) - nvl(p_prd_res_amt,0);
   end if;
   hr_utility.set_Location('avl_amt is'||p_prd_avl_amt,90);
   hr_utility.set_Location('leaving'||l_proc,100);
exception
   when others then
      hr_utility.set_location('errors in computing period details',420);
      raise;
end get_period_details;

function get_txn_child_count(p_child_type in varchar2,
                             p_txn_id     in number) return number is
   l_number number;
begin
   select count(*)
   into l_number
   from pqh_bdgt_pool_realloctions
   where pool_id = p_txn_id
   and   transaction_type = p_child_type;
   return l_number;
exception
   when others then
      hr_utility.set_location('invalid child type',10);
      raise;
end;
procedure get_txn_balances(p_txn_id            in number,
                           p_donor_realloc_amt out nocopy number,
                           p_donor_reserve_amt out nocopy number,
                           p_rcvr_realloc_amt  out nocopy number) is
begin
   select sum(nvl(period.reallocation_amt,0)),sum(nvl(period.reserved_amt,0))
   into  p_donor_realloc_amt,p_donor_reserve_amt
   from  pqh_bdgt_pool_realloctions donor, pqh_bdgt_pool_realloctions period
   where donor.pool_id = p_txn_id
   and   period.txn_detail_id = donor.reallocation_id
   and   donor.transaction_type = 'D'
   and   period.transaction_type = 'DD' ;

   select sum(nvl(period.reallocation_amt,0))
   into  p_rcvr_realloc_amt
   from  pqh_bdgt_pool_realloctions rcvr, pqh_bdgt_pool_realloctions period
   where rcvr.pool_id = p_txn_id
   and   period.txn_detail_id = rcvr.reallocation_id
   and   rcvr.transaction_type = 'R'
   and   period.transaction_type = 'RD' ;
exception
   when others then
      hr_utility.set_location('invalid txn_id ',10);
      raise;
end;
procedure get_budget_details(p_budget_version_id in number,
                             p_budget_unit_id    in number,
                             p_budget_name          out nocopy varchar2,
                             p_budget_currency      out nocopy varchar2,
                             p_entity_type          out nocopy varchar2,
                             p_budget_start_date    out nocopy date,
                             p_budget_end_date      out nocopy date,
                             p_budget_unit_name     out nocopy varchar2,
                             p_budget_unit_num      out nocopy number,
                             p_bmu_name             out nocopy varchar2,
                             p_budget_unit_type     out nocopy varchar2) is
   l_budget_id number;
   l_budget_unit1_id number;
   l_budget_unit2_id number;
   l_budget_unit3_id number;
begin
-- budget details are to be pulled in
   select bgt.budget_id,bgt.budget_name,bgt.budgeted_entity_cd,bgt.budget_start_date,
          bgt.budget_end_date,bgt.currency_code,bgt.budget_unit1_id,bgt.budget_unit2_id,bgt.budget_unit3_id
   into   l_budget_id,p_budget_name,p_entity_type,p_budget_start_date,
          p_budget_end_date,p_budget_currency,l_budget_unit1_id,l_budget_unit2_id,l_budget_unit3_id
   from   pqh_budgets bgt, pqh_budget_versions bvr
   where  bgt.budget_id = bvr.budget_id
   and    bvr.budget_version_id = p_budget_version_id
   and    bgt.position_control_flag ='Y';

-- business group currency to be used, in budget currency null
   if p_budget_currency is null then
      p_budget_currency := pqh_budget.get_currency_cd(p_budget_id => l_budget_id);
   end if;

-- unit num which is being reallocated
   if l_budget_unit1_id = p_budget_unit_id then
      p_budget_unit_num := 1;
   elsif l_budget_unit2_id = p_budget_unit_id then
      p_budget_unit_num := 2;
   elsif l_budget_unit3_id = p_budget_unit_id then
      p_budget_unit_num := 3;
   else
      hr_utility.set_location ('Error condition',10);
   end if;

-- unit details are to be pulled in
   select system_type_cd,shared_type_name
   into   p_bmu_name,p_budget_unit_name
   from   per_shared_types
   where  lookup_type ='BUDGET_MEASUREMENT_TYPE'
   and    shared_type_id = p_budget_unit_id;
   if p_bmu_name ='MONEY' then
      p_budget_unit_type := 'M' ;
   else
      p_budget_unit_type := 'N' ;
   end if;
exception
   when others then
      hr_utility.set_location('invalid budget_id',10);
      raise;
end get_budget_details;
function check_org_valid_rule(p_organization_id    in number,
                              p_rule_org_id        in number,
                              p_rule_applicability in varchar2,
                              p_rule_category      in varchar2,
                              p_rule_org_str_id    in number,
                              p_rule_start_org_id  in number) return boolean is
   l_proc varchar2(71) := g_package||'check_org_valid_rule';
Cursor csr_parent_nodes(P_ORGANIZATION_ID in number ,
                        P_ORG_STRUCTURE_VERSION_ID in number) is
  Select level,organization_id_parent
    From per_org_structure_elements
   where org_structure_version_id = p_org_structure_version_id
connect by prior organization_id_parent = organization_id_child
       and ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
  start with ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
        and organization_id_child = P_ORGANIZATION_ID
  UNION
  Select 0,p_organization_id
    from dual
  order by 1 asc;
  l_lowest_level boolean;
  l_org_str_version_id number;
  l_rule_level_cd varchar2(30);
  l_rule_set_id number;
  l_lo_rule_level_cd varchar2(30);
  l_lo_rule_set_id number;
  l_lo_start_org_id number;
  l_lo_org_str_id number;
  l_rule_exists boolean;
begin
   hr_utility.set_Location('inside'||l_proc,10);
   if p_rule_org_id = p_organization_id then
      l_rule_exists := TRUE;
      -- rule is defined at current org
   else
      hr_utility.set_Location('get_org_hier'||l_proc,20);
      get_org_structure_version_id
         (p_org_structure_id        => p_rule_org_str_id,
          p_org_structure_version_id=> l_org_str_version_id);
      for l_str_nodes_rec in csr_parent_nodes(p_organization_id          => p_organization_id,
                                              p_org_structure_version_id => l_org_str_version_id) loop
          hr_utility.set_Location('finding nodes'||l_proc,30);
          l_rule_exists := check_rule_existence
                              (p_organization_structure_id => p_rule_org_str_id,
                               p_starting_organization_id  => l_str_nodes_rec.organization_id_parent,
                               p_business_group_id         => g_business_group_id,
                               p_rule_category             => p_rule_category,
                               p_rule_applicability        => p_rule_applicability);
          if l_rule_exists then
             -- rule is found in the hierarchy
             hr_utility.set_Location('get out of loop '||l_proc,40);
             exit;
          end if;
      end loop;
   end if;
   return l_rule_exists;
end check_org_valid_rule;

function check_rule_existence(p_organization_structure_id in number,
                              p_starting_organization_id  in number,
                              p_business_group_id         in number,
                              p_rule_category             in varchar2,
                              p_rule_applicability        in varchar2) return boolean is
   l_rule_set_id number;
begin
   hr_utility.set_Location('check_rule_existence p_organization_structure_id'||p_organization_structure_id,40);
   hr_utility.set_Location('check_rule_existence p_starting_organization_id'||p_starting_organization_id,40);
   hr_utility.set_Location('check_rule_existence p_business_group_id'||p_business_group_id,40);
   hr_utility.set_Location('check_rule_existence p_rule_category'||p_rule_category,40);
   hr_utility.set_Location('check_rule_existence p_rule_applicability'||p_rule_applicability,40);
   select rule_set_id
   into l_rule_set_id
   from pqh_rule_sets
   where business_group_id = p_business_group_id
     and organization_structure_id = p_organization_structure_id
     and starting_organization_id = p_starting_organization_id
     and rule_category =p_rule_category
     and rule_applicability = p_rule_applicability;
   if l_rule_set_id is not null then
      hr_utility.set_Location('rule exists ',40);
      return TRUE;
   else
      hr_utility.set_Location('rule does not exist ',40);
      return FALSE;
   end if;
exception
   when others then
      hr_utility.set_Location('check_rule_existence errors',40);
      return FALSE;
end check_rule_existence;

function get_position_organization(p_position_id in number,
                                   p_effective_date in date) return number is
   l_organization_id number;
begin
   select organization_id
   into l_organization_id
   from hr_all_positions_f
   where position_id = p_position_id
   and p_effective_date between effective_start_date and effective_end_date;
   return l_organization_id;
end get_position_organization;
--
Procedure get_org_structure_version_id (p_org_structure_id           IN   NUMBER,
                                        p_org_structure_version_id  OUT nocopy  NUMBER) is
Cursor c1 is
  Select org_structure_version_id
    From per_org_structure_versions
   Where organization_structure_id = p_org_structure_id
     AND version_number =
         (select max(version_number)
          From per_org_structure_versions
          Where organization_structure_id = p_org_structure_id);
  --
  l_proc 	varchar2(72) := g_package||'g_org_structure_version_id';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c1;
  Fetch c1 into p_org_structure_version_id;
  If c1%notfound then
     hr_utility.set_message(8302, 'PQH_ORG_STRUCT_VER_NOT_FOUND');
     hr_utility.raise_error;
  End if;
  Close c1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
    when others then
        p_org_structure_version_id := null;
End;
--
procedure populate_context(p_entity_id in number,
                           p_folder_id in number) is
   l_proc varchar2(71) := g_package||'populate_context';
begin
-- Following parameters should be there in g_refresh_tab for right conversion
-- Position_id : Current entity id is budget entity is position
-- Business_group_id : we have it in global variable
-- Organization_id : for position or organization we will get it.
-- Pool_id : I guess it is folder id , we will be having it
-- Entity_id : is current row.
   hr_utility.set_location('Entering:'||l_proc, 5);
   pqh_refresh_data.g_refresh_tab.DELETE;
   hr_utility.set_location('dropped the context table:'||l_proc, 10);
   pqh_refresh_data.g_refresh_tab(1).column_name := 'ENTITY_ID';
   pqh_refresh_data.g_refresh_tab(1).TXN_VAL := p_entity_id;
   pqh_refresh_data.g_refresh_tab(2).column_name := 'BUSINESS_GROUP_ID';
   pqh_refresh_data.g_refresh_tab(2).TXN_VAL := g_business_group_id;
   pqh_refresh_data.g_refresh_tab(3).column_name := 'POOL_ID';
   pqh_refresh_data.g_refresh_tab(3).TXN_VAL := p_folder_id;
   hr_utility.set_location('budget entity is:'||g_budget_entity||l_proc, 20);
   if g_budget_entity ='ORGANIZATION' then
      pqh_refresh_data.g_refresh_tab(4).column_name := 'ORGANIZATION_ID';
      pqh_refresh_data.g_refresh_tab(4).TXN_VAL := p_entity_id;
   elsif g_budget_entity ='POSITION' then
--      l_pos_organization_id := get_position_organization(p_position_id    => p_entity_id,
--                                                         p_effective_date => trunc(sysdate));
--      pqh_refresh_data.g_refresh_tab(4).column_name := 'ORGANIZATION_ID';
--      pqh_refresh_data.g_refresh_tab(4).TXN_VAL := l_organization_id;
      pqh_refresh_data.g_refresh_tab(4).column_name := 'POSITION_ID';
      pqh_refresh_data.g_refresh_tab(4).TXN_VAL := p_entity_id;
   end if;
   hr_utility.set_location('leaving '||l_proc, 100);
end populate_context;
--
Function GET_TRANSACTION_VALUE (p_entity_id      IN  number,
                                p_attribute_id   IN  number) RETURN  varchar2 IS
   l_sel_stmt               varchar2(4000);
   l_from_clause            PQH_TABLE_ROUTE.FROM_CLAUSE%TYPE;
   l_where_clause_in        PQH_TABLE_ROUTE.WHERE_CLAUSE%TYPE;
   l_where_clause_out       PQH_TABLE_ROUTE.WHERE_CLAUSE%TYPE;
   l_column_name            PQH_ATTRIBUTES.COLUMN_NAME%TYPE;
   l_column_type            PQH_ATTRIBUTES.COLUMN_TYPE%TYPE;
   l_selected_value_v       varchar2(2000);
   l_selected_value_n       number;
   l_selected_value_d       date;
   l_proc                   varchar2(100) := 'get_transaction_value';
   l_table_route_id         PQH_TABLE_ROUTE.TABLE_ROUTE_ID%TYPE;
BEGIN
hr_utility.set_location('Entering : '||l_proc, 5);
if (p_entity_id is not null and p_attribute_id is not null) then

-- get the attribute details
   select column_name, master_table_route_id,column_type
   into   l_column_name, l_table_route_id,l_column_type
   from   pqh_attributes
   where  attribute_id = p_attribute_id;
   hr_utility.set_location('column_name1 is : '||substr(l_column_name,1,50),10);
   hr_utility.set_location('column_name2 is : '||substr(l_column_name,51,50),11);
   hr_utility.set_location('column_name3 is : '||substr(l_column_name,101,50),12);
   hr_utility.set_location('column_name4 is : '||substr(l_column_name,151,50),13);
   hr_utility.set_location('column_type is : '||l_column_type,15);
   hr_utility.set_location('table_route is : '||l_table_route_id,20);

-- table route is selected, get the details

   select from_clause, where_clause
   into   l_from_clause, l_where_clause_in
   from   pqh_table_route where table_route_id = l_table_route_id;
--broke the set_location for from_clause into two lines kgowripe
   hr_utility.set_location('from_clause1 is : '||substr(l_from_clause,1,30),30);
   hr_utility.set_location('from_clause2 is : '||substr(l_from_clause,31,30),31);
   hr_utility.set_location('where_clause 1is : '||substr(l_where_clause_in,1,40),40);
   hr_utility.set_location('where_clause 2is : '||substr(l_where_clause_in,41,40),40);

-- update the where clause with the context values

    pqh_refresh_data.replace_where_params(
      p_where_clause_in  => l_where_clause_in,
      p_txn_tab_flag     => 'N',
      p_txn_id           => p_entity_id,
      p_where_clause_out => l_where_clause_out);
   hr_utility.set_location('where_clause 1is : '||substr(l_where_clause_out,1,40),50);
   hr_utility.set_location('where_clause 2is : '||substr(l_where_clause_out,41,40),50);

-- build up the statement to be used for getting the value
    l_sel_stmt := 'select '||l_column_name||' from '||l_from_clause||' where '||l_where_clause_out ;
   hr_utility.set_location('stmt1 '||substr(l_sel_stmt,1,60),55);
   hr_utility.set_location('stmt2 '||substr(l_sel_stmt,61,60),55);
   hr_utility.set_location('stmt3 '||substr(l_sel_stmt,121,60),55);
   hr_utility.set_location('stmt4 '||substr(l_sel_stmt,181,60),55);
   hr_utility.set_location('stmt5 '||substr(l_sel_stmt,241,60),55);
   hr_utility.set_location('stmt6 '||substr(l_sel_stmt,361,60),55);

-- execute the dynamic sql
   if l_column_type ='D' then
      hr_utility.set_location('date being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_d;
      -- converting the date to character format
      l_selected_value_v := fnd_date.date_to_canonical(l_selected_value_d);
   elsif l_column_type ='N' then
      hr_utility.set_location('number being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_n;
      l_selected_value_v := to_char(l_selected_value_n);
   else
      hr_utility.set_location('varchar being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_v;
   end if;
   hr_utility.set_location('leaving with value: '||l_selected_value_v, 90);
   return l_selected_value_v;
else
   hr_utility.set_location('values passed was null. '||l_proc, 420);
   return null;
end if;
EXCEPTION
   when no_data_found then
      hr_utility.set_location('no data exists '||l_proc, 100);
      return null;
   WHEN others THEN
      hr_utility.set_location('Failure in program unit: '||l_proc, 420);
      return null;
END GET_TRANSACTION_VALUE;

function check_attribute_result(p_rule_value     in varchar2,
                                p_txn_value      in varchar2,
                                p_operation_code in varchar2,
                                p_attribute_type in varchar2) return BOOLEAN is
BEGIN
if (p_rule_value is null or
    p_attribute_type is null or
    p_txn_value is null or
    p_operation_code is null) then
    return false;
else
   hr_utility.set_location('p_rule_value is '||p_rule_value, 5);
   hr_utility.set_location('p_attribute_type is '||p_attribute_type, 10);
   hr_utility.set_location('p_txn_value is '||p_txn_value, 15);
   hr_utility.set_location('p_operation_code is '||p_operation_code, 20);
   if p_operation_code = 'EQ' then
      if p_txn_value = p_rule_value then
         hr_utility.set_location('EQ true', 25);
         return TRUE;
      else
         hr_utility.set_location('EQ false', 25);
         return false;
      end if;
   elsif p_operation_code = 'GT' then
--added by kgowripe for Numeric attribute comparision
    if p_attribute_type = 'N' THEN
      if to_number(p_txn_value) > to_number(p_rule_value) then
        hr_utility.set_location('Numeric GT True',21);
        return true;
      else
        hr_utility.set_location('Numeric GT False',21);
        return false;
      end if;
    else
--code changes by kgowripe ends
      if p_txn_value > p_rule_value then
         hr_utility.set_location('GT true', 25);
         return true;
      else
         hr_utility.set_location('GT false', 25);
         return false;
      end if;
    end if;
   elsif p_operation_code = 'LT' then
--added by kgowripe for Numeric attribute comparision
    if p_attribute_type = 'N' then
      if to_number(p_txn_value) < to_number(p_rule_value) then
       hr_utility.set_location('Numeric LT Rule true ',22);
       return true;
     else
       hr_utility.set_location('Numeric LT Rule False',22);
       return false;
     end if;
    else
--end code changes by kgowripe
      if p_txn_value < p_rule_value then
         hr_utility.set_location('LT true', 25);
         return true;
      else
         hr_utility.set_location('LT false', 25);
         return false;
      end if;
    end if;
   elsif p_operation_code = 'NEQ' then
      if p_txn_value <> p_rule_value then
         hr_utility.set_location('NEQ true', 25);
         return true;
      else
         hr_utility.set_location('NEQ false', 25);
         return false;
      end if;
   else
      return false;
   end if;
end if;
EXCEPTION
   WHEN others THEN
      return false;
END CHECK_ATTRIBUTE_RESULT;

-- routine, which will be called by page.
PROCEDURE apply_rules(p_transaction_type   IN varchar2,
                      p_business_group_id  IN Number,
                      p_transaction_id     IN number,
                      p_effective_date     IN date DEFAULT sysdate,
                      p_status_flag           OUT NOCOPY varchar2) is
   l_proc varchar2(71) := g_package||'apply_rules';
begin
   hr_utility.set_location('inside '||l_proc,10);
   if p_transaction_type ='REALLOCATION' then
      hr_utility.set_location('calling CBR '||l_proc,20);
      apply_cbr_realloc(p_transaction_id    => p_transaction_id,
                        p_business_group_id => p_business_group_id,
                        p_effective_date    => p_effective_date,
                        p_status_flag       => p_status_flag);
      hr_utility.set_location('finished CBR_ENG with status'||p_status_flag,40);
   else
      hr_utility.set_location('invalid txn type'||p_transaction_type,30);
   end if;
   hr_utility.set_location('leaving '||l_proc,100);
end apply_rules;

-- routine which cntrols reallocation related rule applications
PROCEDURE apply_CBR_realloc(p_transaction_id    IN number,
                            p_business_group_id IN number,
                            p_effective_date    IN DATE,
                            p_status_flag           OUT NOCOPY varchar2) is
   l_proc varchar2(71) := g_package||'apply_cbr_realloc';
   l_status_flag boolean;
begin
   hr_utility.set_location('inside '||l_proc,10);
   populate_globals(p_transaction_id => p_transaction_id);
   hr_utility.set_location('globals populated '||l_proc,20);
   apply_business_rules(p_transaction_id    => p_transaction_id,
                        p_business_group_id => p_business_group_id,
                        p_effective_date    => p_effective_date,
                        p_status_flag       => l_status_flag);
   if l_status_flag then
      hr_utility.set_location('out with status TRUE '||l_proc,20);
   else
      hr_utility.set_location('out with status FALSE'||l_proc,30);
   end if;
   if l_status_flag then
      hr_utility.set_location('checking defined rules'||l_proc,40);
      apply_defined_rules(p_transaction_id    => p_transaction_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => p_effective_date,
                          p_status_flag       => p_status_flag);
      if p_status_flag is null then
         hr_utility.set_location('defined rules cleared',50);
      else
         hr_utility.set_location('defined rules failed',60);
      end if;
   else
      hr_utility.set_location('business rules failed',70);
      p_status_flag := 'E';
   end if;
end apply_cbr_realloc;

-- process rules are applied for donor/ receivers
PROCEDURE apply_defined_rules(p_transaction_id    IN number,
                              p_business_group_id IN number,
                              p_effective_date    IN DATE,
                              p_status_flag          OUT NOCOPY varchar2) is
   l_proc varchar2(71) := g_package||'apply_defined_rules';
   l_rule_matx t_rule_matx;
   l_cond_matx t_cond_matx;
   l_attr_matx t_attr_matx;
   l_cond_result boolean;
   l_transaction_value varchar2(2000);
   l_prev_txn_id number;
   l_prev_txn_type varchar2(30);
   l_txn_type varchar2(30);
   l_final_stat varchar2(30);
   l_prev_entity_id number;
   l_rule_message fnd_new_messages.message_text%type;
   rule_counter number;
   cond_counter number;
begin
   hr_utility.set_location('inside'||l_proc,10);
   -- attribute properties populated
   populate_attr_matx(l_attr_matx);
/*
-- used for debugging only
   for i in 1..l_attr_matx.count loop
       hr_utility.set_location(i||'column_name '||substr(l_attr_matx(i).column_name,1,50),70);
       hr_utility.set_location(i||'entity_type '||l_attr_matx(i).entity_type,80);
       hr_utility.set_location(i||'applicability '||l_attr_matx(i).applicability,90);
   end loop;
*/
   hr_utility.set_location('attribute matrix populated',20);
   -- valid rules for the folder populated
   valid_process_rules(p_transaction_id    => p_transaction_id,
                       p_business_group_id => p_business_group_id,
                       p_rule_category     => 'REALLOCATION',
                       p_effective_date    => p_effective_date,
                       l_rule_matx         => l_rule_matx);
   hr_utility.set_location('valid_rule matrix populated',30);
   -- folder process logging started
   pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'F',
                                      p_folder_id       => p_transaction_id);
   hr_utility.set_location('rules to apply are :'||l_rule_matx.count,40);
   for rule_counter in 1..l_rule_matx.count loop
       hr_utility.set_location('applying rule '||l_rule_matx(rule_counter).rule_set_id,20);
       if l_rule_matx(rule_counter).rule_applicability ='DONOR' then
          l_txn_type := 'D';
       elsif l_rule_matx(rule_counter).rule_applicability ='RECEIVER' then
          l_txn_type := 'R';
       else
          hr_utility.set_location('rule applicability is'||l_rule_matx(rule_counter).rule_applicability ,30);
       end if;
/*
If rule matrix is not ordered by entity id then we will have an issue
*/
       -- get the row, if the txn is same as last one, we don't have to start the log
       if l_prev_txn_id is not null then
          -- not 1st time in loop, variable is set
          hr_utility.set_location('inside itxn chk',25);
          if l_prev_txn_id <> nvl(l_rule_matx(rule_counter).txn_id,-1) then
             hr_utility.set_location('inside entity chk',28);
          -- different txn is being started
             pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => l_prev_txn_type,
                                              p_folder_id       => p_transaction_id,
                                              p_transaction_id  => l_prev_txn_id,
                                              p_entity_id       => l_prev_entity_id);
             pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'T',
                                              p_folder_id       => p_transaction_id,
                                              p_transaction_id  => l_prev_txn_id);
             hr_utility.set_location('old log ended, new being started ',29);
             pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'T',
                                                p_folder_id       => p_transaction_id,
                                                p_transaction_id  => l_prev_txn_id);
             pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => l_txn_type, --line modified by kgowripe
-- l_rule_matx(rule_counter).rule_applicability,
                                                p_folder_id       => p_transaction_id,
                                                p_transaction_id  => l_rule_matx(rule_counter).txn_id,
--Added by kgowripe
                                                p_bdgt_entity_type=> g_budget_entity,
--
                                                p_entity_id       => l_rule_matx(rule_counter).entity_id);
             hr_utility.set_location('new log started ',30);
          else
             -- same txn is getting start check same entity
             hr_utility.set_location('same txn ',35);
             if l_prev_entity_id <> l_rule_matx(rule_counter).entity_id then
                -- different entity getting start
                hr_utility.set_location('different txn ',40);
                pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => l_prev_txn_type,
                                                 p_folder_id       => p_transaction_id,
                                                 p_transaction_id  => l_prev_txn_id,
                                                 p_entity_id       => l_prev_entity_id);
                pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => l_txn_type,-- line modified by kgowripe
--l_rule_matx(rule_counter).rule_applicability,
                                                   p_folder_id       => p_transaction_id,
                                                   p_transaction_id  => l_rule_matx(rule_counter).txn_id,
--Added by kgowripe
                                                   p_bdgt_entity_type=> g_budget_entity,
--
                                                   p_entity_id       => l_rule_matx(rule_counter).entity_id);
                hr_utility.set_location('log started ',45);
             else
                -- same entity is being worked on
                hr_utility.set_location('another rule for entity ',50);
             end if;
          end if;
       else
          -- 1st time in loop so start the txn and entity, nothing is there to end.
          hr_utility.set_location('1st time in rule chk ',60);
          pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'T',
                                             p_folder_id       => p_transaction_id,
                                             p_transaction_id  => l_rule_matx(rule_counter).txn_id);
          pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => l_txn_type,
                                             p_folder_id       => p_transaction_id,
                                             p_transaction_id  => l_rule_matx(rule_counter).txn_id,
--Added by kgowripe
                                             p_bdgt_entity_type=> g_budget_entity,
--
                                             p_entity_id       => l_rule_matx(rule_counter).entity_id);
          hr_utility.set_location('log started ',65);
       end if;
       hr_utility.set_location('populate rule conditions'||l_proc,68);
       valid_rule_conditions(p_entity_type        => g_budget_entity,
                             p_rule_set_id        => l_rule_matx(rule_counter).rule_set_id,
                             p_rule_applicability => l_rule_matx(rule_counter).rule_applicability,
                             p_attr_matx          => l_attr_matx,
                             p_cond_matx          => l_cond_matx);
-- context is set for applying all rules belonging to a condition
       populate_context(p_entity_id => l_rule_matx(rule_counter).entity_id,
                        p_folder_id   => p_transaction_id);
       for cond_counter in 1..l_cond_matx.count loop
           hr_utility.set_location('applying rule conditions'||l_proc,70);
           l_transaction_value := get_transaction_value
                                    (p_entity_id    => l_rule_matx(rule_counter).entity_id,
                                     p_attribute_id => l_cond_matx(cond_counter).attribute_id);
           hr_utility.set_location('txn_value '||l_transaction_value,75);
           if l_transaction_value is not null
              and l_cond_matx(cond_counter).attribute_value is not null then
              hr_utility.set_location('checking result '||l_proc,75);
              l_cond_result := check_attribute_result
                                 (p_rule_value     => l_cond_matx(cond_counter).attribute_value,
                                  p_txn_value      => l_transaction_value,
                                  p_operation_code => l_cond_matx(cond_counter).operation_code,
                                  p_attribute_type => l_cond_matx(cond_counter).column_type);
              if l_cond_result then
                 -- rule is satisfied, hence process log should be updated with the values
                 hr_utility.set_location('condition is being satisfied by txn',10);
                 if l_rule_matx(rule_counter).rule_level_cd ='E' then
                    p_status_flag := 'E';
                    -- rule is an error rule, so no more conditions for this rule
/* exit after logging the error message in process log. commented by kgowripe
                    exit; -- get out of condition loop
*/
                 else
                    p_status_flag := 'W';
                 end if;
                 l_rule_message := build_message (p_application_id => 8302,
                                                  p_message_cd => l_rule_matx(rule_counter).message_cd);
                 pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                            (p_folder_id        => p_transaction_id,
                                             p_transaction_id   => l_rule_matx(rule_counter).txn_id,
                                             p_txn_entity_type  => l_txn_type, -- line modified by kgowripe
--l_rule_matx(rule_counter).rule_applicability,
--Added by kgowripe
                                             p_bdgt_entity_type=> g_budget_entity,
                                             p_rule_name => l_rule_matx(rule_counter).rule_name,
--
                                             p_entity_id        => l_rule_matx(rule_counter).entity_id,
                                             p_rule_level       => p_status_flag,
                                             p_rule_msg_cd      => l_rule_message);
--code inserted by kgowripe
--leave the conditions loop after logging the message, in case the rule level is Error
                if l_rule_matx(rule_counter).rule_level_cd = 'E' then
                     exit;
                end if;
--end code inserted by kgowripe
              else
                 -- rule fails
                 hr_utility.set_location('condition no match ',90);
              end if;
           end if;
           hr_utility.set_location('going for next condition',100);
       end loop; -- conditions for a rule
       l_prev_txn_type := l_txn_type; -- modified by kgowripe-- l_rule_matx(rule_counter).rule_applicability;
       l_prev_entity_id := l_rule_matx(rule_counter).entity_id;
       l_prev_txn_id := l_rule_matx(rule_counter).txn_id;

-- if final stat is null and we encounter some issue, we log that
-- or we encounter an error we log that
-- so if an error is reported and after that 4 warnings, final stat will be 'E'
       if p_status_flag ='E' or (l_final_stat is null and p_status_flag is not null) then
          -- this status will be passed to the calling routine
          l_final_stat := p_status_flag;
       end if;
       p_status_flag := '';
       hr_utility.set_location('going for next rule',140);
   end loop; -- rules for all entities of a folder
   hr_utility.set_location('all rule applied '||l_final_stat,145);
   -- close the entity, txn and folder processing
   pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => l_prev_txn_type,
                                    p_folder_id       => p_transaction_id,
                                    p_transaction_id  => l_prev_txn_id,
                                    p_entity_id       => l_prev_entity_id);
   pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'T', --modified by kgowripe l_prev_txn_type,
                                    p_folder_id       => p_transaction_id,
                                    p_transaction_id  => l_prev_txn_id);
   pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'F', --modified by kgowripe l_prev_txn_type,
                                    p_folder_id       => p_transaction_id);
   p_status_flag := l_final_stat;
   hr_utility.set_location('leaving '||l_proc,200);
exception
   when others then
      hr_utility.set_location('some error '||l_proc,420);
      raise;
end apply_defined_rules;

-- business rules related to Reallocation are applied , if error status is returned as false
PROCEDURE apply_business_rules(p_transaction_id    IN number,
                               p_business_group_id IN number,
                               p_effective_date    IN DATE,
                               p_status_flag           OUT NOCOPY BOOLEAN) is
   l_proc varchar2(71) := g_package||'apply_business_rules';
   l_rule_message fnd_new_messages.message_text%type;
   l_num_txns number;

CURSOR csr_txn_rec(p_folder_id in number) is
select pool_id txn_id,name
from pqh_budget_pools
where parent_pool_id = p_folder_id;

CURSOR csr_donor_rec(p_txn_id in number) is
select reallocation_id donor_id,budget_detail_id,entity_id
from pqh_bdgt_pool_realloctions
where pool_id = p_txn_id
and transaction_type ='D' ;

CURSOR csr_rcvr_rec(p_txn_id in number) is
select reallocation_id rcvr_id,entity_id
from pqh_bdgt_pool_realloctions
where pool_id = p_txn_id
and transaction_type ='R' ;

CURSOR csr_donorperiod_rec(p_donor_id in number) is
select reallocation_amt,reserved_amt,budget_period_id
from pqh_bdgt_pool_realloctions
where txn_detail_id = p_donor_id
and pool_id is null
and transaction_type ='DD' ;

CURSOR csr_rcvrperiod_rec(p_rcvr_id in number) is
select reallocation_amt,entity_id,start_date,end_date,reallocation_id rcvr_period_id
from pqh_bdgt_pool_realloctions
where txn_detail_id = p_rcvr_id
and pool_id is null
and transaction_type ='RD' ;

   l_num_donors number;
   l_num_rcvrs number;
   l_donor_realloc_amt number;
   l_donor_reserve_amt number;
   l_rcvr_realloc_amt number;
   l_lo_don_prd_start_date date;
   l_prd_start_date date;
   l_prd_avl_amt number;
   l_prd_act_amt number;
   l_prd_com_amt number;
   l_prd_don_amt number;
   l_prd_res_amt number;
   l_prd_rec_amt number;
   l_prd_bgt_amt number;
begin
   hr_utility.set_location('inside'||l_proc,10);
   p_status_flag := TRUE;
   pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'F',
                                      p_folder_id       => p_transaction_id);
   hr_utility.set_location('plg flder started'||l_proc,20);
   select count(*) into l_num_txns
   from pqh_budget_pools
   where parent_pool_id = p_transaction_id;
   if nvl(l_num_txns,0) = 0 then
      hr_utility.set_location('no txn '||l_proc,25);
      p_status_flag := FALSE;
/*
      This code is commented as Process log does not allow recording of log at folder level
      The same should be captured in review page.
      The error condition is being handled here, just in case.
*/
      l_rule_message := build_message (p_application_id => 8302,
                                       p_message_cd => 'PQH_BGT_REALLOC_NO_TXN');
      pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                 (p_folder_id        => p_transaction_id,
                                  p_transaction_id   => p_transaction_id,
                                  p_txn_entity_type  => 'F',
                                  p_rule_level       => 'E',
                                  p_rule_msg_cd      => l_rule_message);

   end if;
   if p_status_flag then
   for l_txn_rec in csr_txn_rec(p_folder_id => p_transaction_id) loop
       hr_utility.set_location('txn is '||l_txn_rec.name,30);
       pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'T',
                                          p_folder_id       => p_transaction_id,
                                          p_transaction_id  => l_txn_rec.txn_id);
       hr_utility.set_location('plg txn started'||l_proc,40);
       -- Many-many rule checked here
       l_num_donors := get_txn_child_count(p_child_type => 'D',
                                           p_txn_id     => l_txn_rec.txn_id);
       l_num_rcvrs := get_txn_child_count(p_child_type => 'R',
                                          p_txn_id     => l_txn_rec.txn_id);
       hr_utility.set_location('donors'||l_num_donors,50);
       hr_utility.set_location('rcvrs'||l_num_rcvrs,60);
       if l_num_donors > 1 then
          -- multiple donors exist
          hr_utility.set_Location('Many donors exist in txn',50);
          if l_num_rcvrs > 1 then
             -- error condition , many to many
             hr_utility.set_Location('Many rcvrs exist in txn',60);
             p_status_flag := FALSE;
             l_rule_message := build_message (p_application_id => 8302,
                                              p_message_cd => 'PQH_BGT_REALLOC_MANY_MANY');
             pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
          elsif l_num_rcvrs = 0 then

          -- Stared by mvankada to fix Bug : 2897642
            -- error Donor has only reserved amount
              p_status_flag := FALSE;
	      -- Reallocation amount, reserved amount
	          hr_utility.set_Location('get txn bal'||l_proc,61);
	              get_txn_balances(p_txn_id            => l_txn_rec.txn_id,
	                               p_donor_realloc_amt => l_donor_realloc_amt,
	                               p_donor_reserve_amt => l_donor_reserve_amt,
	                               p_rcvr_realloc_amt  => l_rcvr_realloc_amt);
	             hr_utility.set_Location('l_donor_realloc_amt .. '||l_donor_realloc_amt,62);
	             hr_utility.set_Location('l_donor_reserve_amt .. '||l_donor_reserve_amt,63);

	              if (nvl(l_donor_realloc_amt,0) = 0 and nvl(l_donor_reserve_amt,0) <> 0)  then
	                 -- Donor has only reserved amount
	                 hr_utility.set_Location('donor has reserved amount only ',65);
	                 p_status_flag := FALSE;
	                 l_rule_message := build_message (p_application_id => 8302,
	                                                  p_message_cd => 'PQH_BGT_REALLOC_RESERVED_AMT');
	                 pqh_bdgt_realloc_log_pkg.log_rule_for_entity
	                                            (p_folder_id        => p_transaction_id,
	                                             p_transaction_id   => l_txn_rec.txn_id,
	                                             p_txn_entity_type  => 'T',
	                                             p_rule_level       => 'E',
	                                             p_rule_msg_cd      => l_rule_message);
                      else
                             -- Ended  by mvankada to fix Bug : 2897642
                             -- error condition , No receiver
                             hr_utility.set_Location('No rcvrs exist in txn',30);
                             l_rule_message := build_message (p_application_id => 8302,
                                              p_message_cd => 'PQH_BGT_REALLOC_NO_RCVR');
             			pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
            	     end if;
          end if;
       elsif l_num_donors = 0 then
          -- error condition, no donor
             hr_utility.set_Location('No donor exist in txn',40);
             p_status_flag := FALSE;
             l_rule_message := build_message (p_application_id => 8302,
                                              p_message_cd => 'PQH_BGT_REALLOC_NO_DONOR');
             pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
       else -- # of donors is 1 then
      if l_num_rcvrs = 0 then

           -- Stared by mvankada to fix Bug : 2897642
            -- error Donor has only reserved amount
              p_status_flag := FALSE;
	      -- Reallocation amount, reserved amount
	          hr_utility.set_Location('get txn bal'||l_proc,45);
	              get_txn_balances(p_txn_id            => l_txn_rec.txn_id,
	                               p_donor_realloc_amt => l_donor_realloc_amt,
	                               p_donor_reserve_amt => l_donor_reserve_amt,
	                               p_rcvr_realloc_amt  => l_rcvr_realloc_amt);
                     hr_utility.set_Location('l_donor_realloc_amt .. '||l_donor_realloc_amt,47);
	             hr_utility.set_Location('l_donor_reserve_amt .. '||l_donor_reserve_amt,50);

	              if (nvl(l_donor_realloc_amt,0) = 0 and nvl(l_donor_reserve_amt,0) <> 0)  then
	                 -- Donor has only reserved amount
	                 hr_utility.set_Location('donor has reserved amount only ',55);
	                 p_status_flag := FALSE;
	                 l_rule_message := build_message (p_application_id => 8302,
	                                                  p_message_cd => 'PQH_BGT_REALLOC_RESERVED_AMT');
	                 pqh_bdgt_realloc_log_pkg.log_rule_for_entity
	                                            (p_folder_id        => p_transaction_id,
	                                             p_transaction_id   => l_txn_rec.txn_id,
	                                             p_txn_entity_type  => 'T',
	                                             p_rule_level       => 'E',
	                                             p_rule_msg_cd      => l_rule_message);
                     else

                       -- Ended  by mvankada to fix Bug : 2897642
                       -- error condition , No receiver
             		hr_utility.set_Location('No rcvrs exist in txn',30);
                        l_rule_message := build_message (p_application_id => 8302,
                                              		 p_message_cd => 'PQH_BGT_REALLOC_NO_RCVR');
             		pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
                     end if;
          end if;
       end if;
       if p_status_flag then
          -- txn_balance should be 0
          hr_utility.set_Location('get txn bal'||l_proc,50);
          get_txn_balances(p_txn_id            => l_txn_rec.txn_id,
                           p_donor_realloc_amt => l_donor_realloc_amt,
                           p_donor_reserve_amt => l_donor_reserve_amt,
                           p_rcvr_realloc_amt  => l_rcvr_realloc_amt);
          if l_donor_realloc_amt is null or l_rcvr_realloc_amt is null then
             -- txn is not balanced, write in process log with txn name
             hr_utility.set_Location('donor or rcvr null ',52);
             p_status_flag := FALSE;
             l_rule_message := build_message (p_application_id => 8302,
                                              p_message_cd => 'PQH_BGT_REALLOC_UNBAL_TXN');
             pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
          elsif nvl(l_donor_realloc_amt,0) <> nvl(l_rcvr_realloc_amt,0) then
             -- txn is not balanced, write in process log with txn name
             hr_utility.set_Location('txn not balanced',50);
             p_status_flag := FALSE;
             l_rule_message := build_message (p_application_id => 8302,
                                              p_message_cd => 'PQH_BGT_REALLOC_UNBAL_TXN');
             pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                        (p_folder_id        => p_transaction_id,
                                         p_transaction_id   => l_txn_rec.txn_id,
                                         p_txn_entity_type  => 'T',
                                         p_rule_level       => 'E',
                                         p_rule_msg_cd      => l_rule_message);
          end if;
          if p_status_flag then
             hr_utility.set_Location('validate donors '||l_proc,60);
             for l_donor_rec in csr_donor_rec(p_txn_id => l_txn_rec.txn_id) loop
                 hr_utility.set_Location('donor log started '||l_proc,70);
                 pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type  => 'D',
                                                    p_folder_id        => p_transaction_id,
                                                    p_transaction_id   => l_txn_rec.txn_id,
                                                    p_bdgt_entity_type => g_budget_entity,
                                                    p_entity_id        => l_donor_rec.entity_id); --modified by kgowripe l_donor_rec.donor_id);
                 hr_utility.set_Location('validate donor periods '||l_proc,80);
                 for l_donorperiod_rec in csr_donorperiod_rec(p_donor_id => l_donor_rec.donor_id) loop
                     hr_utility.set_Location('donor period id '||l_donor_rec.donor_id,90);
                     if nvl(l_donorperiod_rec.reallocation_amt,0) < 0 and p_status_flag then
                  -- error condition negative amount
                        hr_utility.set_Location('donorperiod realloc negative',60);
                        p_status_flag := FALSE;
                        l_rule_message := build_message (p_application_id => 8302,
                                                         p_message_cd => 'PQH_BGT_REALLOC_DONOR_REA_NEG');
                        hr_utility.set_Location('log rule '||l_proc,100);
                        pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                   (p_folder_id        => p_transaction_id,
                                                    p_transaction_id   => l_txn_rec.txn_id,
                                                    p_txn_entity_type  => 'DP',--modified by kgowripe 'D',
                                                    p_entity_id        => l_donor_rec.entity_id, --modified by kgowripe l_donor_rec.donor_id,
                                                    p_budget_period_id => l_donorperiod_rec.budget_period_id,
                                                    p_rule_level       => 'E',
                                                    p_rule_msg_cd      => l_rule_message);
                     end if;
                     if nvl(l_donorperiod_rec.reserved_amt,0) < 0 and p_status_flag then
                        -- error condition negative amount
                        hr_utility.set_Location('donorperiod reserve negative',70);
                        p_status_flag := FALSE;
                        l_rule_message := build_message (p_application_id => 8302,
                                                         p_message_cd => 'PQH_BGT_REALLOC_DONOR_RES_NEG');
                        pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                   (p_folder_id        => p_transaction_id,
                                                    p_transaction_id   => l_txn_rec.txn_id,
                                                    p_txn_entity_type  => 'DP',--modified by kgowripe 'D',
                                                    p_entity_id        => l_donor_rec.entity_id,--modified by kgowripe l_donor_rec.donor_id,
                                                    p_budget_period_id => l_donorperiod_rec.budget_period_id,
                                                    p_rule_level       => 'E',
                                                    p_rule_msg_cd      => l_rule_message);
                     end if;
                     -- details are being fetched here so that same can be passed to the process log
                     hr_utility.set_Location('get the period details '||l_proc,120);
                     get_period_details (p_budget_period_id => l_donorperiod_rec.budget_period_id,
                                         p_budget_entity_id => l_donor_rec.entity_id, --modified by kgowripe l_donor_rec.donor_id,
                                         p_prd_avl_amt      => l_prd_avl_amt,
                                         p_prd_act_amt      => l_prd_act_amt,
                                         p_prd_com_amt      => l_prd_com_amt,
                                         p_prd_don_amt      => l_prd_don_amt,
                                         p_prd_res_amt      => l_prd_res_amt,
                                         p_prd_bgt_amt      => l_prd_bgt_amt,
                                         p_prd_start_date   => l_prd_start_date);
                     if (nvl(l_prd_avl_amt,0) < (nvl(l_donorperiod_rec.reallocation_amt,0) +
                                                nvl(l_donorperiod_rec.reserved_amt,0))) and p_status_flag  then
                        -- error condition, amount available is less than used
                        hr_utility.set_Location('donorperiod available is less',80);
                        p_status_flag := FALSE;
                        l_rule_message := build_message (p_application_id => 8302,
                                                         p_message_cd => 'PQH_BGT_REALLOC_DONOR_LESS_AVL');
                        pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                   (p_folder_id        => p_transaction_id,
                                                    p_transaction_id   => l_txn_rec.txn_id,
                                                    p_txn_entity_type  => 'DP',--Modified by kgowripe 'D',
                                                    p_entity_id        => l_donor_rec.entity_id,--modified by kgowripe l_donor_rec.donor_id,
                                                    p_budget_period_id => l_donorperiod_rec.budget_period_id,
                                                    p_rule_level       => 'E',
                                                    p_rule_msg_cd      => l_rule_message);
                     end if;
                     if l_lo_don_prd_start_date > l_prd_start_date then
                        -- earlist donor period start date is being captured here
                        l_lo_don_prd_start_date := l_prd_start_date;
                        hr_utility.set_Location('earliest donorperiod is '||to_char(l_prd_start_date,'ddmmRRRR'),90);
                     end if;
                     if not p_status_flag then
                        exit;
                     end if;
                 end loop; -- donor periods inside the donor loop
                 pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'D',
                                                  p_folder_id => p_transaction_id,
                                                  p_transaction_id => l_txn_rec.txn_id,
                                                  p_entity_id => l_donor_rec.entity_id);--modified by kgowripe l_donor_rec.donor_id);
                 if not p_status_flag then
                    exit;
                 end if;
             end loop; -- donors inside the txn loop
             if p_status_flag then
                for l_rcvr_rec in csr_rcvr_rec(p_txn_id => l_txn_rec.txn_id) loop
                    pqh_bdgt_realloc_log_pkg.start_log(p_txn_entity_type => 'R',
                                                       p_folder_id => p_transaction_id,
                                                       p_transaction_id => l_txn_rec.txn_id,
                                                       p_bdgt_entity_type => g_budget_entity,
                                                       p_entity_id => l_rcvr_rec.entity_id);--modified by kgowripe l_rcvr_rec.rcvr_id);
                    for l_rcvrperiod_rec in csr_rcvrperiod_rec(p_rcvr_id => l_rcvr_rec.rcvr_id) loop
                        if l_rcvrperiod_rec.start_date < g_budget_start_date and p_status_flag then
                           -- error condition, receiver starting prior to budget date
                           hr_utility.set_Location('rcvrperiod starting <budget',100);
                           p_status_flag := FALSE;
                           l_rule_message := build_message (p_application_id => 8302,
                                                            p_message_cd => 'PQH_BGT_REALLOC_RCVR_START_BGT');
                           pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                      (p_folder_id        => p_transaction_id,
                                                       p_transaction_id   => l_txn_rec.txn_id,
                                                       p_txn_entity_type  => 'RP',
                                                       p_entity_id        => l_rcvr_rec.entity_id,--modified by kgowripe l_rcvr_rec.rcvr_id,
                                                       p_budget_period_id => l_rcvrperiod_rec.rcvr_period_id,--added by kgowriope
                                                       p_rule_level       => 'E',
                                                       p_rule_msg_cd      => l_rule_message);
                        end if;
                        if l_rcvrperiod_rec.end_date > g_budget_end_date and p_status_flag then
                           -- error condition, receiver ending later than budget end date.
                           hr_utility.set_Location('rcvrperiod ending >budget',110);
                           p_status_flag := FALSE;
                           l_rule_message := build_message (p_application_id => 8302,
                                                            p_message_cd => 'PQH_BGT_REALLOC_RCVR_END_BGT');
                           pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                      (p_folder_id        => p_transaction_id,
                                                       p_transaction_id   => l_txn_rec.txn_id,
                                                       p_txn_entity_type  => 'RP',
                                                       p_entity_id        => l_rcvr_rec.entity_id,--modified by kgowripe l_rcvr_rec.rcvr_id,
                                                       p_budget_period_id => l_rcvrperiod_rec.rcvr_period_id,--added by kgowriope
                                                       p_rule_level       => 'E',
                                                       p_rule_msg_cd      => l_rule_message);
                        end if;
                        if l_rcvrperiod_rec.start_date < l_lo_don_prd_start_date and p_status_flag then
                           -- error condition, receiver starting prior to earliest donor period date
                           hr_utility.set_Location('rcvrperiod starting <donor',110);
                           p_status_flag := FALSE;
                           l_rule_message := build_message (p_application_id => 8302,
                                                            p_message_cd => 'PQH_BGT_REALLOC_RCVR_START_DON');
                           pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                      (p_folder_id        => p_transaction_id,
                                                       p_transaction_id   => l_txn_rec.txn_id,
                                                       p_txn_entity_type  => 'RP',
                                                       p_entity_id        => l_rcvr_rec.entity_id,--modified by kgowripe l_rcvr_rec.rcvr_id,
                                                       p_budget_period_id => l_rcvrperiod_rec.rcvr_period_id,--added by kgowriope
                                                       p_rule_level       => 'E',
                                                       p_rule_msg_cd      => l_rule_message);
                        end if;
                        if nvl(l_rcvrperiod_rec.reallocation_amt,0) < 0 and p_status_flag then
                           -- error condition negative amount
                           hr_utility.set_Location('rcvrperiod realloc negative',120);
                           p_status_flag := FALSE;
                           l_rule_message := build_message (p_application_id => 8302,
                                                            p_message_cd => 'PQH_BGT_REALLOC_RCVR_REA_NEG');
                           pqh_bdgt_realloc_log_pkg.log_rule_for_entity
                                                      (p_folder_id        => p_transaction_id,
                                                       p_transaction_id   => l_txn_rec.txn_id,
                                                       p_txn_entity_type  => 'RP',
                                                       p_entity_id        => l_rcvr_rec.entity_id,--modified by kgowripe l_rcvr_rec.rcvr_id,
                                                       p_budget_period_id => l_rcvrperiod_rec.rcvr_period_id,--added by kgowriope
                                                       p_rule_level       => 'E',
                                                       p_rule_msg_cd      => l_rule_message);
                        end if;
                        if not p_status_flag then
                           exit;
                        end if;
                    end loop; -- rcvr periods inside the rcvr loop
                    pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'R',
                                                     p_folder_id => p_transaction_id,
                                                     p_transaction_id => l_txn_rec.txn_id,
                                                     p_entity_id => l_rcvr_rec.entity_id);
                    if not p_status_flag then
                       exit;
                    end if;
                end loop; -- rcvrs inside the txn loop
           else
                hr_utility.set_location('not going for rcvr, as error exist',140);
           end if;
           pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'T',
                                            p_folder_id => p_transaction_id,
                                            p_transaction_id => l_txn_rec.txn_id);
         end if; -- endif, if txn had balance errors
      end if; -- endif, if txn had num errors
      if not p_status_flag then
         exit;
      end if;
   end loop; -- transactions inside the folder loop
   end if; -- if folder had txns
   pqh_bdgt_realloc_log_pkg.end_log(p_txn_entity_type => 'F',
                                    p_folder_id => p_transaction_id);
   hr_utility.set_location('done business rules',150);
end apply_business_rules;

-- populates valid rule conditions for an entity
-- Set of attributes are defined and mapping is stored in p_attr_matx that which attribute is
-- applicable for which one
procedure valid_rule_conditions(p_entity_type        in varchar2,
                                p_rule_set_id        in number,
                                p_rule_applicability in varchar2,
                                p_attr_matx          in t_attr_matx,
                                p_cond_matx             out NOCOPY t_cond_matx) is
   l_proc varchar2(71) := g_package||'valid_rule_conditions';
   cursor csr_condition_rec is
   select rule_attribute_id,attribute_value,operation_code,attribute_code
   from pqh_rule_attributes
   where rule_set_id = p_rule_set_id;
   read_counter number := 1;
   write_counter number := 1;
   l_valid_applicability boolean;
   l_valid_entity boolean;
begin
   hr_utility.set_location('inside'||l_proc,10);
   -- pqh_rule_attributes stores the attribute code (which links to attribute_id of pqh_attributes)
   -- this attribute id is linked to txn_category budget reallocation
   -- In this procedure we are getting conditions defined for a rule and populating
   -- the seeded attributes by comparing attribute_id
   for l_condition_rec in csr_condition_rec loop
       hr_utility.set_location('next condition'||l_condition_rec.attribute_code,20);
       for read_counter in 1..p_attr_matx.count loop
           hr_utility.set_location('next cond attribute'||l_condition_rec.attribute_code,25);
           hr_utility.set_location('next attribute'||p_attr_matx(read_counter).attribute_id,30);
           if l_condition_rec.attribute_code = p_attr_matx(read_counter).attribute_id then
              hr_utility.set_location('attribute match',30);
              hr_utility.set_location('rule_applicability :'||p_rule_applicability,32);
              hr_utility.set_location('entity_type :'||p_entity_type,34);
              if p_rule_applicability = 'DONOR' and
                 p_attr_matx(read_counter).applicability in ('DONOR','BOTH') then
                 hr_utility.set_location('applicability valid',40);
                 l_valid_applicability := TRUE;
              elsif p_rule_applicability = 'RECEIVER' and
                 p_attr_matx(read_counter).applicability in ('RECEIVER','BOTH') then
                 hr_utility.set_location('applicability valid',50);
                 l_valid_applicability := TRUE;
              else
                 l_valid_applicability := FALSE;
                 hr_utility.set_location('applicability invalid'||p_rule_applicability,70);
              end if;
              if p_entity_type = 'POSITION' and
                 p_attr_matx(read_counter).entity_type in ('POSITION','ALL') then
                 hr_utility.set_location('entity valid',50);
                 l_valid_entity := TRUE;
              elsif p_entity_type = 'ORGANIZATION' and
                 p_attr_matx(read_counter).entity_type in ('ORGANIZATION','ALL') then
                 hr_utility.set_location('entity valid',50);
                 l_valid_entity := TRUE;
              elsif p_entity_type = 'JOB' and
                 p_attr_matx(read_counter).entity_type in ('JOB','ALL') then
                 hr_utility.set_location('entity valid',50);
                 l_valid_entity := TRUE;
              elsif p_entity_type = 'GRADE' and
                 p_attr_matx(read_counter).entity_type in ('GRADE','ALL') then
                 hr_utility.set_location('entity valid',50);
                 l_valid_entity := TRUE;
              else
                 l_valid_entity := FALSE;
                 hr_utility.set_location('entity invalid '||p_entity_type,70);
              end if;
              if l_valid_applicability and l_valid_entity then
                 hr_utility.set_location('writing condition',80);
                 -- attribute matches the entity type and applicability and
                 -- is a valid rule to be applied.
                 p_cond_matx(write_counter).rule_attribute_id := l_condition_rec.rule_attribute_id;
                 p_cond_matx(write_counter).attribute_id := p_attr_matx(read_counter).attribute_id;
                 p_cond_matx(write_counter).column_type := p_attr_matx(read_counter).column_type;
                 p_cond_matx(write_counter).column_name := p_attr_matx(read_counter).column_name;
                 p_cond_matx(write_counter).operation_code := l_condition_rec.operation_code;
                 p_cond_matx(write_counter).attribute_value := l_condition_rec.attribute_value;
                 write_counter := write_counter + 1;
              end if; -- populating condtion matrix with the match
              exit; -- as match found, get next condition attribute
           else
              hr_utility.set_location('no match, go for next ',88);
           end if;  -- attribute compare if end
       end loop; -- attribute property matrix loop
       hr_utility.set_location('out of attribute loop',90);
   end loop; -- conditions loop
   hr_utility.set_location('out of conditions loop',95);
/*
-- used for debugging only
   for i in 1..p_cond_matx.count loop
       hr_utility.set_location('cond# is'||i,100);
       hr_utility.set_location('cond_attr'||p_cond_matx(i).attribute_id,101);
       hr_utility.set_location('column_name'||substr(p_cond_matx(i).column_name,1,50),102);
       hr_utility.set_location('attribute_value'||p_cond_matx(i).attribute_value,103);
   end loop;
*/
   hr_utility.set_location('leaving '||l_proc,110);
exception
   when others then
      hr_utility.set_location('error in valid_rule_conditions',420);
end valid_rule_conditions;

-- populates valid rules for a transaction folder
procedure valid_process_rules(p_transaction_id    in varchar2,
                              p_business_group_id in number,
                              p_rule_category     in varchar2,
                              p_effective_date    in date,
                              l_rule_matx            out NOCOPY t_rule_matx) is
   l_proc varchar2(71) := g_package||'valid_process_rules';

   CURSOR csr_rule_rec(p_rule_applicability in varchar2) is
   select rule_set_id,organization_structure_id,starting_organization_id,organization_id,
          rule_set_name,rule_level_cd,rule_applicability
   from pqh_rule_sets
   where business_group_id  = p_business_group_id
   and   rule_category      = p_rule_category
   and   rule_applicability = p_rule_applicability
   and   rule_level_cd      <> 'I' ;

   CURSOR csr_entity_rec IS
   SELECT txndtl.budget_detail_id budget_detail_id,
          txndtl.entity_id        entity_id,
          txndtl.transaction_type txn_type,
          txndtl.pool_id          txn_id
   FROM pqh_budget_pools fld,
        pqh_budget_pools txn,
        pqh_bdgt_pool_realloctions txndtl
   WHERE fld.pool_id = p_transaction_id
   AND   fld.parent_pool_id IS NULL
   AND   fld.pool_id = txn.parent_pool_id
   AND   txn.pool_id = txndtl.pool_id;
   counter number := 1;
   l_rule_added boolean;
   l_rule_scope varchar2(30);
   l_rule_valid boolean;
   l_org_str_version_id number;
   l_pos_organization_id number ;
   l_organization_id number ;
   l_rule_conditions number;
   l_rule_messages number;
   l_rule_set_id number;
   l_message_cd fnd_new_messages.message_name%type;
   l_rule_applicability varchar2(30);
begin
-- for a donor entity all the donor rules defined in the business group are pulled in
-- and checked for validity and added the plsql table
   hr_utility.set_Location('inside'||l_proc,10);
   for l_entity_rec in csr_entity_rec loop
      hr_utility.set_Location('entity is'||l_entity_rec.entity_id,20);
      if l_entity_rec.txn_type ='R' then
         l_rule_applicability := 'RECEIVER';
      elsif l_entity_rec.txn_type ='D' then
         l_rule_applicability := 'DONOR';
      else
         hr_utility.set_location('Error '||l_entity_rec.txn_type,10);
      end if;
      if g_budget_entity in ('POSITION','ORGANIZATION') then
         if g_budget_entity = 'POSITION' then
            l_pos_organization_id := get_position_organization(p_position_id    => l_entity_rec.entity_id,
                                                               p_effective_date => p_effective_date);
         end if;
         l_organization_id := nvl(l_pos_organization_id,l_entity_rec.entity_id);
      end if;
      for l_rule_rec in csr_rule_rec(p_rule_applicability => l_rule_applicability) loop
          hr_utility.set_location('finding rule '||l_rule_applicability,30);
          l_rule_valid := FALSE ; -- initializing the result variable
          select count(*) into l_rule_messages from pqh_rules where rule_set_id = l_rule_rec.rule_set_id;
          select count(*) into l_rule_conditions from pqh_rule_attributes where rule_set_id = l_rule_rec.rule_set_id;
          if l_rule_messages <> 1 or l_rule_conditions = 0 then
             hr_utility.set_location('Either message or condition is undefined',50);
             l_rule_valid := FALSE ;
          else
             l_rule_valid := TRUE ;
             select message_name
             into l_message_cd
             from pqh_rules
             where rule_set_id = l_rule_rec.rule_set_id
             and application_id = 8302;
             hr_utility.set_location('message is'||l_message_cd,55);
          end if;
          if l_rule_valid then
             hr_utility.set_location('valid rule ',60);
             if l_rule_rec.organization_structure_id is null and l_rule_rec.organization_id is null then
                -- rule is defined for BG level
                l_rule_valid := TRUE;
             else
                if g_budget_entity in ('POSITION','ORGANIZATION') then
                   l_rule_valid := check_org_valid_rule
                                      (p_organization_id    => l_organization_id,
                                       p_rule_org_id        => l_rule_rec.organization_id,
                                       p_rule_applicability => l_rule_rec.rule_applicability,
                                       p_rule_category      => p_rule_category,
                                       p_rule_org_str_id    => l_rule_rec.organization_structure_id,
                                       p_rule_start_org_id  => l_rule_rec.starting_organization_id);
                end if;
             end if;
          end if;
          if l_rule_valid then
             l_rule_matx(counter).rule_set_id := l_rule_rec.rule_set_id;
             l_rule_matx(counter).rule_name := l_rule_rec.rule_set_name;
             l_rule_matx(counter).rule_applicability := l_rule_rec.rule_applicability;
             l_rule_matx(counter).entity_id := l_entity_rec.entity_id;
             l_rule_matx(counter).txn_id := l_entity_rec.txn_id;
             l_rule_matx(counter).message_cd := l_message_cd;
--rule level code is not being added to the matrix. added by kgowripe
             l_rule_matx(counter).rule_level_cd := l_rule_rec.rule_level_cd;
--
             counter := counter+1;
          else
             hr_utility.set_location('invalid rule '||l_rule_rec.rule_set_name,75);
          end if;
      end loop; -- all the rules defined for BG loop
   end loop; -- entities loop
   for i in 1..l_rule_matx.count loop
       hr_utility.set_location('rule# is'||i,100);
       hr_utility.set_location('rule_name'||l_rule_matx(i).rule_name,101);
       hr_utility.set_location('entity_id'||l_rule_matx(i).entity_id,102);
       hr_utility.set_location('message_cd'||l_rule_matx(i).message_cd,103);
       hr_utility.set_location('applicability'||l_rule_matx(i).rule_applicability,104);
   end loop;
exception
   when others then
     hr_utility.set_location('unexpected error',420);
     raise;
end valid_process_rules;

procedure populate_globals(p_transaction_id in number) is
   l_proc varchar2(71) := g_package||'.populate_globals';
   l_budget_unit_id number;
begin
   hr_utility.set_location('inside '||l_proc,10);
   g_folder_id := p_transaction_id;
   SELECT budget_version_id,budget_unit_id,name,business_group_id
   into   g_budget_version_id,l_budget_unit_id,g_folder_name,g_business_group_id
   FROM   pqh_budget_pools
   WHERE  pool_id = p_transaction_id
   and    parent_pool_id is null;
   hr_utility.set_location('folder name '||g_folder_name,20);
   get_budget_details(p_budget_version_id => g_budget_version_id,
                      p_budget_unit_id    => l_budget_unit_id,
                      p_budget_name       => g_budget_name,
                      p_budget_currency   => g_budget_currency,
                      p_entity_type       => g_budget_entity,
                      p_budget_start_date => g_budget_start_date,
                      p_budget_end_date   => g_budget_end_date,
                      p_budget_unit_name  => g_budget_unit_name,
                      p_budget_unit_num   => g_budget_unit_num,
                      p_bmu_name          => g_measurement_unit,
                      p_budget_unit_type  => g_budget_unit_type);
-- modified by kgowripe.set the session date as budget start date
   dt_fndate.set_effective_date(p_effective_date => g_budget_start_date);
--
   hr_utility.set_location('budget name '||g_budget_name,30);
   hr_utility.set_location('entity type'||g_budget_entity,40);
   hr_utility.set_location('unit name '||g_budget_unit_name,50);
end;

procedure populate_attr_matx (p_attr_matx out nocopy t_attr_matx)is
   l_proc varchar2(71) := g_package||'populate_attr_matx';
   cursor csr_attribute_rec is
      select tcat.txn_category_attribute_id tcat_attribute_id,
             att.attribute_id attribute_id,
             att.column_type column_type,
             att.column_name column_name
      from pqh_attributes att,pqh_txn_category_attributes tcat, pqh_transaction_categories txn
      where txn.transaction_category_id = tcat.transaction_category_id
        and txn.short_name = 'PQH_BPR'
        and txn.business_group_id is null
        and tcat.attribute_id = att.attribute_id
        and nvl(tcat.list_identifying_flag,'N') = 'N'
        and nvl(tcat.member_identifying_flag,'N') = 'N'
        and att.enable_flag ='Y';
   counter number := 1;
   l_entity_type varchar2(30);
   l_applicability varchar2(30);
   procedure set_attr (p_attr_matx            in out nocopy t_attr_matx
                    , p_subscript             in     number
                    , p_attribute_id          in     number
                    , p_column_type           in     varchar2
                    , p_column_name           in     varchar2
                    , p_txn_catg_attribute_id in     number
                    , p_entity_type           in     varchar2
                    , p_applicability         in     varchar2)
   is
   begin
      p_attr_matx(p_subscript).attribute_id          := p_attribute_id ;
      p_attr_matx(p_subscript).column_name           := p_column_name ;
      p_attr_matx(p_subscript).column_type           := p_column_type ;
      p_attr_matx(p_subscript).txn_catg_attribute_id := p_txn_catg_attribute_id ;
      p_attr_matx(p_subscript).entity_type           := p_entity_type;
      p_attr_matx(p_subscript).applicability         := p_applicability;
   end;
begin
-- possible values of entity type are
-- Position
-- Organization
-- All (Any entity type is allowed)

-- Possible values of applicability are
-- Both (used for Donor as well as Receiver)
-- Donor
-- Transaction

   for l_attribute_rec in csr_attribute_rec loop
       hr_utility.set_location('inside'||l_proc,10);
       --debug by kmg
       hr_utility.set_location('Column name length '||length(l_attribute_rec.column_name),24);
       --
       hr_utility.set_location('column_name'||substr(l_attribute_rec.column_name,1,50),20);
       hr_utility.set_location('column_name'||substr(l_attribute_rec.column_name,51,50),21);
       hr_utility.set_location('column_name'||substr(l_attribute_rec.column_name,101,50),22);
       hr_utility.set_location('column_name'||substr(l_attribute_rec.column_name,151,50),23);
       if upper(l_attribute_rec.column_name) in ('FTE','MAX_PERSONS','LOCATION_ID','JOB_ID','ORGANIZATION_ID','PERMANENT_TEMPORARY_FLAG','SEASONAL_FLAG','STATUS','POSITION_TYPE') then
          l_entity_type := 'POSITION';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) in ('HR_GENERAL.DECODE_JOB(JOB_ID)','HR_GENERAL.DECODE_LOCATION(LOCATION_ID)') then
          l_entity_type := 'POSITION';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) in ('HR_GENERAL.DECODE_LOOKUP(''POSITION_TYPE'',POSITION_TYPE)','HR_GENERAL.DECODE_ORGANIZATION(ORGANIZATION_ID)') then
          l_entity_type := 'POSITION';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) in ('ORU.LOCATION_ID','ORU.TYPE','ORU.NAME','HR_GENERAL.DECODE_LOCATION(ORU.LOCATION_ID)') then
          l_entity_type := 'ORGANIZATION';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) like 'PQH_MGMT_RPT_PKG.GET_ENTITY_BUDGET_AMT(FLD.ENTITY_TYPE,TRNXAMT.ENTITY_ID,FLD.BUDGET_VERSION_ID%' then
          l_entity_type := 'ALL';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) like 'PQH_BDGT_ACTUAL_CMMTMNT_PKG.GET_ENT_ACTUAL_AND_CMMTMNT(FLD.BUDGET_VERSION_ID%' then
          l_entity_type := 'ALL';
          l_applicability := 'BOTH';
       elsif upper(l_attribute_rec.column_name) like 'PQH_BDGT_REALLOC_UTILITY.GET_PRD_REALLOC_RESERVED_AMT(%' then
          l_entity_type := 'ALL';
          l_applicability := 'BOTH';
       end if;
       hr_utility.set_location('going for setting'||l_proc,30);
       hr_utility.set_location('entity_type '||l_entity_type,40);
       hr_utility.set_location('applicability '||l_applicability,50);
       set_attr(p_attr_matx             => p_attr_matx,
                p_subscript             => counter,
                p_attribute_id          => l_attribute_rec.attribute_id,
                p_txn_catg_attribute_id => l_attribute_rec.tcat_attribute_id,
                p_column_name           => l_attribute_rec.column_name,
                p_column_type           => l_attribute_rec.column_type,
                p_entity_type           => l_entity_type,
                p_applicability         => l_applicability);
       counter := counter + 1;
       l_entity_type := '';
       l_applicability := '';
   end loop;
/*
-- can be used for debugging , no need for functionality
   for i in 1..p_attr_matx.count loop
       hr_utility.set_location(i||'column_name '||substr(p_attr_matx(i).column_name,1,50),70);
       hr_utility.set_location(i||'entity_type '||p_attr_matx(i).entity_type,80);
       hr_utility.set_location(i||'applicability '||p_attr_matx(i).applicability,90);
   end loop;
*/
end;
end pqh_cbr_engine;

/
