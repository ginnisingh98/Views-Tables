--------------------------------------------------------
--  DDL for Package Body PQH_RBC_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_STAGE" AS
/* $Header: pqrbcstg.pkb 120.7 2006/03/14 09:26 srajakum noship $ */
procedure set_session_date(p_effective_date in date) is
   l_cnt number;
begin
   select 1
   into l_cnt
   from fnd_sessions
   where session_id = userenv('sessionid');
exception
   when no_data_found then
      hr_utility.set_location('session date not there, inserting',10);
      insert into fnd_sessions (session_id,effective_date) values (userenv('sessionid'),trunc(p_effective_date));
   when others then
      hr_utility.set_location('issues in session date pulling ',10);
      raise;
end;
procedure get_criteria(p_criteria_short_code in varchar2,
                       p_business_group_id   in number,
                       p_crit_rec            out nocopy ben_eligy_criteria%rowtype) is
begin
   select *
   into p_crit_rec
   from ben_eligy_criteria
   where short_code =p_criteria_short_code
   and business_group_id = p_business_group_id;
exception
   when no_data_found then
      hr_utility.set_location('no bg specific row exists for short_code'||p_criteria_short_code,25);
      begin
         select *
         into p_crit_rec
         from ben_eligy_criteria
         where short_code =p_criteria_short_code
         and business_group_id is null;
      exception
         when no_data_found then
            hr_utility.set_location('no global row for short_code'||p_criteria_short_code,25);
            raise;
         when others then
            hr_utility.set_location('issues in glb short_code'||p_criteria_short_code,25);
            raise;
      end;
   when others then
      hr_utility.set_location('issues in getting criteria for short_code'||p_criteria_short_code,25);
      raise;
end;
function get_rmn_cer(p_rmn_id in number,
                     p_cet_id in number) return number is
   l_rmn_cer_id number;
begin
   select copy_entity_result_id
   into l_rmn_cer_id
   from   ben_copy_entity_results
   where copy_entity_txn_id = p_cet_id
   and table_alias ='RMN'
   and information1 = p_rmn_id;
   hr_utility.set_location('RMN cer'||l_rmn_cer_id,20);
   return l_rmn_cer_id;
exception
   when others then
      hr_utility.set_location('issues in getting RMN cer'||p_rmn_id,10);
      raise;
end;
function get_ph_name(p_pos_hier_ver_id in number) return varchar2 is
   l_ph_name varchar2(240);
begin
   select ph.name
   into l_ph_name
   from per_position_structures ph, per_pos_structure_versions phv
   where ph.position_structure_id = phv.position_structure_id
   and phv.pos_structure_version_id = p_pos_hier_ver_id;
   return l_ph_name;
exception
   when others then
      hr_utility.set_location('issues in pulling ph name'||p_pos_hier_ver_id,10);
      raise;
end;
function get_oh_name(p_org_hier_ver_id in number) return varchar2 is
   l_oh_name varchar2(240);
begin
   select oh.name
   into l_oh_name
   from per_organization_structures oh, per_org_structure_versions ohv
   where oh.organization_structure_id = ohv.organization_structure_id
   and ohv.org_structure_version_id = p_org_hier_ver_id;
   return l_oh_name;
exception
   when others then
      hr_utility.set_location('issues in pulling oh name'||p_org_hier_ver_id,10);
      raise;
end;
function get_crit_type(p_criteria_short_code in varchar2,
                       p_business_group_id   in number) return varchar2 is
   l_crit ben_eligy_criteria%rowtype;
begin
   get_criteria(p_criteria_short_code => p_criteria_short_code,
                p_business_group_id   => p_business_group_id,
                p_crit_rec            => l_crit);
   if l_crit.crit_col1_val_type_cd ='ORG_HIER' then
      return 'OH';
   elsif l_crit.crit_col1_val_type_cd = 'POS_HIER' then
      return 'PH';
   else
      return 'OTHER';
   end if;
end get_crit_type;
function node_value(p_val_type_cd    in varchar2,
                    p_lookup_type    in varchar2,
                    p_crit_col_dtyp  in varchar2,
                    p_value_set_id   in number,
                    p_range_flag     in varchar2,
                    p_number_value1  in number,
                    p_number_value2  in number,
                    p_char_value1    in varchar2,
                    p_char_value2    in varchar2,
                    p_date_value1    in date,
                    p_date_value2    in date,
                    p_effective_date in date) return varchar2 is
   l_oh_desc varchar2(2000);
   l_org_desc varchar2(2000);
   l_ph_desc varchar2(2000);
   l_pos_desc varchar2(2000);
   l_node_desc varchar2(2000);
   l_node1_desc varchar2(2000);
   l_node2_desc varchar2(2000);
begin
   if p_val_type_cd ='LOOKUP' then
      hr_utility.set_location('based on lkp',10);
      hr_utility.set_location('lkp_type'||p_lookup_type,40);
      hr_utility.set_location('lkp_code'||p_char_value1,40);
      if p_char_value1 is not null then
         l_node1_desc := hr_general.decode_lookup(p_lookup_type => p_lookup_type,
                                                  p_lookup_code => p_char_value1);
      else
         l_node1_desc := hr_general.decode_lookup(p_lookup_type => p_lookup_type,
                                                  p_lookup_code => p_number_value1);
      end if;
      if p_range_flag = 'Y' then
         if p_char_value2 is not null then
            l_node2_desc := hr_general.decode_lookup(p_lookup_type => p_lookup_type,
                                                     p_lookup_code => p_char_value2);
         else
            l_node2_desc := hr_general.decode_lookup(p_lookup_type => p_lookup_type,
                                                     p_lookup_code => p_number_value2);
         end if;
         l_node_desc := l_node1_desc ||' - '||l_node2_desc;
      else
         l_node_desc := l_node1_desc ;
      end if;
   elsif  p_val_type_cd ='ORG_HIER' then
      hr_utility.set_location('based on oh'||p_number_value1||' : '||p_number_value2,40);
      l_oh_desc := get_oh_name(p_number_value1);
      l_org_desc := hr_general.decode_organization(p_organization_id => p_number_value2);
      l_node_desc := l_oh_desc ||' - '||l_org_desc;
   elsif  p_val_type_cd ='POS_HIER' then
      hr_utility.set_location('based on ph'||p_number_value1||' : '||p_number_value2,40);
      l_ph_desc := get_ph_name(p_number_value1);
      l_pos_desc := hr_general.decode_position(p_position_id => p_number_value2);
      l_node_desc := l_ph_desc ||' - '||l_pos_desc;
   elsif  p_val_type_cd ='VAL_SET' then
      hr_utility.set_location('based on vset'||p_value_set_id,40);
      if p_crit_col_dtyp ='C' then
         hr_utility.set_location('char based vset',40);
         l_node1_desc := pqh_utility.get_display_value(p_value => p_char_value1,
                                                       p_value_set_id => p_value_set_id);
         hr_utility.set_location('val1 is '||l_node1_desc,40);
         if p_range_flag = 'Y' and p_char_value2 is not null then
            l_node2_desc := pqh_utility.get_display_value(p_value => p_char_value2,
                                                          p_value_set_id => p_value_set_id);
            hr_utility.set_location('val2 is '||l_node2_desc,40);
            l_node_desc := l_node1_desc ||' - '||l_node2_desc;
         else
            l_node_desc := l_node1_desc ;
         end if;
      elsif p_crit_col_dtyp ='N' then
         hr_utility.set_location('num based vset',40);
         l_node1_desc := pqh_utility.get_display_value(p_value => to_char(p_number_value1),
                                                       p_value_set_id => p_value_set_id);
         hr_utility.set_location('val1 is '||l_node1_desc,40);
         if p_range_flag = 'Y' and p_number_value2 is not null then
            l_node2_desc := pqh_utility.get_display_value(p_value => p_number_value2,
                                                          p_value_set_id => p_value_set_id);
            hr_utility.set_location('val2 is '||l_node2_desc,40);
            l_node_desc := l_node1_desc ||' - '||l_node2_desc;
         else
            l_node_desc := l_node1_desc ;
         end if;
      elsif p_crit_col_dtyp ='D' then
         hr_utility.set_location('Date based vset',40);
          select to_char(p_date_value1,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
                         into l_node1_desc
                         from dual;
         hr_utility.set_location('val1 is '||l_node1_desc,40);
         if p_range_flag = 'Y' and p_date_value2 is not null then
             select to_char(p_date_value2,fnd_profile.value('ICX_DATE_FORMAT_MASK'))
                         into l_node2_desc
                         from dual;
            hr_utility.set_location('val2 is '||l_node2_desc,40);
            l_node_desc := l_node1_desc ||' - '||l_node2_desc;
         else
            l_node_desc := l_node1_desc ;
         end if;
      end if;
   end if;
   return l_node_desc;
end node_value;
function build_rate_node_name(p_rate_matrix_node_id in number,
                              p_business_group_id   in number,
                              p_node_short_code     in varchar2 default null,
                              p_effective_date      in date) return varchar2 is
   l_crit_short_code varchar2(80);
   l_crt_rec ben_eligy_criteria%rowtype;
   l_node1_desc varchar2(2000);
   l_node2_desc varchar2(2000);
   l_node_sum_desc varchar2(2000);
   l_node_name varchar2(2000);
   l_part2 varchar2(30);
   l_valuset_val_type varchar2(30);
   l_valuset_sql_stmt varchar2(5000);
   l_valuset_err_st varchar2(60);
   l_val_set_name varchar2(1000);
   l_dep_val_set varchar2(1) := 'Y';
   l_prnt_value1 varchar2(1000);
   l_prnt_value2 varchar2(1000);
   l_value3 varchar2(1000);
   l_value4 varchar2(1000);
   cursor c_rnv is select * from pqh_rt_matrix_node_values
                   where rate_matrix_node_id = p_rate_matrix_node_id;
begin
-- get the node details
   hr_utility.set_location('get node value for '||p_rate_matrix_node_id,10);
   pqh_utility.init_query_date;
   pqh_utility.set_query_date(p_effective_date => p_effective_date);
   if p_node_short_code is null then
      begin
         select criteria_short_code
         into l_crit_short_code
         from pqh_rate_matrix_nodes
         where rate_matrix_node_id = p_rate_matrix_node_id;
         hr_utility.set_location('nodeshort_code is'||l_crit_short_code,10);
      exception
         when others then
            hr_utility.set_location('issues in getting '||l_crit_short_code,10);
            raise;
      end;
   else
      l_crit_short_code := p_node_short_code;
   end if;
   if l_crit_short_code is not null then
      hr_utility.set_location('get criteria detail'||l_crit_short_code,25);
      get_criteria(p_criteria_short_code => l_crit_short_code,
                   p_business_group_id   => p_business_group_id,
                   p_crit_rec            => l_crt_rec);
      hr_utility.set_location('criteria desc is'||substr(l_crt_rec.name,1,30),30);
      if l_crt_rec.crit_col2_val_type_cd is not null then
         hr_utility.set_location('2 part critera',30);
         l_part2 := 'Y';
      end if;
      for i in c_rnv loop
          l_node1_desc := '';
          hr_utility.set_location('node_value_id is'||i.node_value_id,40);
          hr_utility.set_location('node_ dt is'||l_crt_rec.crit_col1_datatype,40);
          l_node1_desc := node_value(p_val_type_cd    => l_crt_rec.crit_col1_val_type_cd,
                                     p_lookup_type    => l_crt_rec.col1_lookup_type,
                                     p_crit_col_dtyp  => l_crt_rec.crit_col1_datatype,
                                     p_value_set_id   => l_crt_rec.col1_value_set_id,
                                     p_range_flag     => l_crt_rec.allow_range_validation_flag,
                                     p_number_value1  => i.number_value1,
                                     p_number_value2  => i.number_value2,
                                     p_char_value1    => i.char_value1,
                                     p_char_value2    => i.char_value2,
                                     p_date_value1    => i.date_value1,
                                     p_date_value2    => i.date_value2,
                                     p_effective_date => p_effective_date);
          if l_part2 = 'Y' then
             l_node2_desc := '';

                         hr_utility.set_location('before node description 2',200);
             hr_utility.set_location('before node 2 crit_col2_val_type_cd'||l_crt_rec.crit_col2_val_type_cd,200);
             hr_utility.set_location('before node 2 l_crt_rec.col2_lookup_type'||l_crt_rec.col2_lookup_type,200);
             hr_utility.set_location('before node 2 l_crt_rec.col2_value_set_id'||l_crt_rec.col2_value_set_id,200);
             hr_utility.set_location('before node 2 l_crt_rec.allow_range_validation_flag2'||l_crt_rec.allow_range_validation_flag2,200);
             hr_utility.set_location('before node 2 i.number_value3'||i.number_value3,200);
             hr_utility.set_location('before node 2 i.char_value3'||i.char_value3,200);
             hr_utility.set_location('before node 2 crit_col1_val_type_cd'||l_crt_rec.crit_col1_val_type_cd,200);
             hr_utility.set_location('before node 2 l_crt_rec.col1_lookup_type'||l_crt_rec.col1_lookup_type,200);
             hr_utility.set_location('before node 2 l_crt_rec.col1_value_set_id'||l_crt_rec.col1_value_set_id,200);
             hr_utility.set_location('before node 2 l_crt_rec.allow_range_validation_flag'||l_crt_rec.allow_range_validation_flag,200);
             hr_utility.set_location('before node 2 i.number_value1'||i.number_value1,200);
             hr_utility.set_location('before node 2 i.char_value1'||i.char_value1,200);
             if (l_crt_rec.crit_col2_val_type_cd = 'VAL_SET' and l_crt_rec.crit_col1_val_type_cd = 'VAL_SET') then
                pqh_utility.get_valueset_sql(p_value_set_id     => l_crt_rec.col2_value_set_id,
                                          p_validation_type     => l_valuset_val_type,
                                          p_sql_stmt            => l_valuset_sql_stmt,
                                          p_error_status        => l_valuset_err_st);
                hr_utility.set_location('value set query  '||substr(l_valuset_sql_stmt,1,100), 200);
                hr_utility.set_location('value set query  '||substr(l_valuset_sql_stmt,101,100), 200);
                hr_utility.set_location('value set query  '||substr(l_valuset_sql_stmt,201,100), 200);
                hr_utility.set_location('value set query  '||substr(l_valuset_sql_stmt,301,100), 200);
                   Select upper(flex_value_set_name)
                   into l_val_set_name
                   from fnd_flex_value_sets
                   where flex_value_set_id = l_crt_rec.col1_value_set_id;

                   hr_utility.set_location('parent value set name '||l_val_set_name, 30);

                  if instr(upper(l_valuset_sql_stmt),':$FLEX$.'||l_val_set_name ) > 0 then
                    if l_crt_rec.crit_col1_datatype = 'C' then
                         l_prnt_value1 := i.char_value1;
                         l_prnt_value2 := i.char_value2;
                    elsif l_crt_rec.crit_col1_datatype = 'N' then
                         l_prnt_value1 := to_number(i.number_value1);
                         l_prnt_value2 := to_number(i.number_value2);
                    end if;

                    if l_crt_rec.crit_col2_datatype = 'C' then
                         l_value3 := i.char_value3;
                         l_value4 := i.char_value4;
                    elsif l_crt_rec.crit_col2_datatype = 'N' then
                         l_value3 := to_number(i.number_value3);
                         l_value4 := to_number(i.number_value4);
                    end if;

                   l_node2_desc := pqh_utility.get_display_value(p_value  => l_value3,
                                                                 p_value_set_id  => l_crt_rec.col2_value_set_id,
                                                                 p_prnt_valset_nm => l_val_set_name,
                                                                 p_prnt_value => l_prnt_value1);
                   if l_crt_rec.allow_range_validation_flag2 = 'Y' then
                   l_node2_desc := l_node2_desc||' - '||pqh_utility.get_display_value(p_value  => l_value4,
                                                                 p_value_set_id  => l_crt_rec.col2_value_set_id,
                                                                 p_prnt_valset_nm => l_val_set_name,
                                                                 p_prnt_value => l_prnt_value1);
                   end if;
                   hr_utility.set_location('SJ node2 desc '||l_node2_desc, 30);
                else
                   l_dep_val_set := 'N';
                end if;
             else
                    l_dep_val_set := 'N';
             end if;
                  hr_utility.set_location('l_dep_val_set '||l_dep_val_set, 30);
             if l_dep_val_set = 'N' then
             l_node2_desc := node_value(p_val_type_cd    => l_crt_rec.crit_col2_val_type_cd,
                                        p_lookup_type    => l_crt_rec.col2_lookup_type,
                                        p_crit_col_dtyp  => l_crt_rec.crit_col2_datatype,
                                        p_value_set_id   => l_crt_rec.col2_value_set_id,
                                        p_range_flag     => l_crt_rec.allow_range_validation_flag2,
                                        p_number_value1  => i.number_value3,
                                        p_number_value2  => i.number_value4,
                                        p_char_value1    => i.char_value3,
                                        p_char_value2    => i.char_value4,
                                     p_date_value1    => i.date_value3,
                                     p_date_value2    => i.date_value4,
                                     p_effective_date => p_effective_date);
             end if;

            l_node1_desc := l_node1_desc||'/ '||l_node2_desc;
         end if;
         hr_utility.set_location('node desc is'||l_node1_desc,25);
         if l_node_sum_desc is null then
            l_node_sum_desc := l_node1_desc ;
         else
            l_node_sum_desc := l_node_sum_desc ||'; '||l_node1_desc ;
         end if;
      end loop;
      hr_utility.set_location('node desc is'||l_node_sum_desc,25);
      l_node_name := l_crt_rec.name ||' : '||l_node_sum_desc;
   else
      hr_utility.set_location('criteria shd be there',40);
   end if;
   hr_utility.set_location('node name is'||l_node_name,45);
   return l_node_name;
end build_rate_node_name;
procedure create_matrix_txn(p_mode              in varchar2,
                            p_business_group_id in number,
                            p_effective_date    in date,
                            p_copy_entity_txn_id out nocopy number) is
   l_rbc_txn_cat number;
   l_ovn number;
begin
   hr_utility.set_location('going for creating cet row',100);
   begin
      select transaction_category_id
      into l_rbc_txn_cat
      from pqh_transaction_categories
      where short_name ='RBC_MATRIX'
      and business_group_id is null;
      hr_utility.set_location('txn_cat is'||l_rbc_txn_cat,100);
   exception
      when others then
         hr_utility.set_location('txn_cat doesnot exist',100);
         raise;
  end;
   if l_rbc_txn_cat is not null then
      pqh_copy_entity_txns_api.create_COPY_ENTITY_TXN
        (p_copy_entity_txn_id             => p_copy_entity_txn_id
        ,p_transaction_category_id        => l_rbc_txn_cat
        ,p_context_business_group_id      => p_business_group_id
        ,p_context                        => 'RBC_MATRIX'
        ,p_action_date                    => p_effective_date
        ,p_number_of_copies               => 1
        ,p_display_name                   => p_mode||' - RBC_MATRIX - '||to_char(sysdate,'ddmmyyyyhhmiss')
        ,p_replacement_type_cd            => 'NONE'
        ,p_start_with                     => 'Rate Matrix'
        ,p_status                         => p_mode
        ,p_object_version_number          => l_ovn
        ,p_effective_date                 => p_effective_date
        ) ;
    end if;
exception
   when others then
      hr_utility.set_location('issues in creating CET row',100);
      raise;
end create_matrix_txn;
procedure delete_matrix(p_copy_entity_txn_id in number) is
begin
   delete from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id ;
exception
   when others then
      hr_utility.set_location('issues in deleting cer rows ',10);
      raise;
end delete_matrix;
function get_comp_flag(p_rate_comp_cd in varchar2) return varchar2 is
   l_comp_flag varchar2(30);
begin
   hr_utility.set_location('rate comp cd is'||p_rate_comp_cd,10);
   if p_rate_comp_cd in ('AMOUNT','RULE') then
      l_comp_flag := 'N';
   elsif p_rate_comp_cd in ('PERCENT','ADD_TO') then
      l_comp_flag := 'Y';
   else
      l_comp_flag := 'A';
   end if;
   hr_utility.set_location('comp flag is'||l_comp_flag,10);
   return l_comp_flag;
end get_comp_flag;
procedure matx_rates(p_rate_matrix_id in number,
                     p_cet_id              in number,
                     p_effective_date      in date,
                     p_business_group_id   in number,
                     p_rcr_tr_name         in varchar2,
                     p_rcr_tr_id           in number,
                     p_count               out nocopy number) is
   l_rcr_cer_id number;
   l_rcr_cer_ovn number;
   l_count number := 0;
   cursor c_matx_rates is select distinct rate.criteria_rate_defn_id
                          from pqh_rate_matrix_rates_f rate, pqh_rate_matrix_nodes node
                          where node.pl_id = p_rate_matrix_id
                          and node.rate_matrix_node_id = rate.rate_matrix_node_id
                          and p_effective_date between effective_start_date and effective_end_date;
   l_min       varchar2(150);
   l_mid       varchar2(150);
   l_max       varchar2(150);
   l_rate      varchar2(150);
   l_calc_mthd varchar2(150);
   l_comp_flag varchar2(150);
   l_crit_name varchar2(250);
   l_currency_code pqh_criteria_rate_defn.currency_code%type;
   l_uom pqh_criteria_rate_defn.uom%type;
begin
   hr_utility.set_location('inside copying matrix_rates ',10);
   for matx_rate in c_matx_rates loop
      hr_utility.set_location('copying matx_rate to staging'||l_count,20);
      begin
         select define_min_rate_flag,define_mid_rate_flag,define_max_rate_flag,define_std_rate_flag,rate_calc_cd, name,currency_code,uom
         into l_min,l_mid,l_max,l_rate,l_calc_mthd,l_crit_name,l_currency_code,l_uom
         from pqh_criteria_rate_defn_vl
         where criteria_rate_defn_id = matx_rate.criteria_rate_defn_id;
      exception
         when others then
            hr_utility.set_location('issue in getting rate defn det',30);
            raise;
      end;
      l_comp_flag := get_comp_flag(l_calc_mthd);
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => p_rcr_tr_name
      ,p_table_route_id             => p_rcr_tr_id
      ,p_table_alias                => 'RCR'
      ,p_dml_operation              => 'COPIED'
      ,p_information1               => matx_rate.criteria_rate_defn_id
      ,p_information4               => p_business_group_id
      ,p_information5               => l_crit_name
      ,p_information49               => l_uom
      ,p_information50               =>  l_currency_code
      ,p_information160             => l_count
      ,p_information111             => l_min
      ,p_information112             => l_mid
      ,p_information113             => l_max
      ,p_information114             => l_rate
      ,p_information115             => l_calc_mthd
      ,p_information116             => l_comp_flag
      ,p_copy_entity_result_id      => l_rcr_cer_id
      ,p_object_version_number      => l_rcr_cer_ovn);
      hr_utility.set_location('rcr cer row is  '||l_rcr_cer_id,30);
      l_count := l_count + 1;
   end loop;
   hr_utility.set_location('total matx rates'||l_count,50);
   p_count := l_count;
exception
   when others then
      hr_utility.set_location('issues in pulling matx rates',10);
      raise;
end matx_rates;
procedure get_rate_value(p_rmn_cer_id          in number,
                         p_crit_rate_defn_id   in number,
                         p_cet_id              in number,
                         p_effective_date      in date,
                         p_min                 out nocopy number,
                         p_mid                 out nocopy number,
                         p_max                 out nocopy number,
                         p_rate                out nocopy number,
                         p_currency_cd         out nocopy varchar2,
                         p_freq_cd             out nocopy varchar2) is
 l_rate_rec ben_copy_entity_results%rowtype;
begin
   select *
   into l_rate_rec
   from ben_copy_entity_results
   where copy_entity_txn_id = p_cet_id
   and   information162 = p_crit_rate_defn_id
   and table_alias = 'RMR'
   and   parent_entity_result_id = p_rmn_cer_id
   and dml_operation <> 'DELETE'
   and p_effective_date between information2 and nvl(information3,to_date('31/12/4712','dd/mm/yyyy'));
   p_min := l_rate_rec.information294;
   p_max := l_rate_rec.information295;
   p_mid := l_rate_rec.information296;
   p_rate := l_rate_rec.information297;
   begin
      select currency_code,reference_period_cd
      into p_currency_cd,p_freq_cd
      from pqh_criteria_rate_defn
      where criteria_rate_defn_id = p_crit_rate_defn_id;
   exception
      when no_data_found then
         hr_utility.set_location('crit rate not exists ',15);
         raise;
      when others then
         hr_utility.set_location('issues in pulling crit rate',20);
         raise;
   end ;
exception
   when no_data_found then
      hr_utility.set_location('no value for node and rate',10);
   when others then
      hr_utility.set_location('issues in pulling rate value',20);
      raise;
end get_rate_value;
procedure get_rate_value(p_rate_matrix_node_id in number,
                         p_crit_rate_defn_id   in number,
                         p_effective_date      in date,
                         p_min                 out nocopy number,
                         p_mid                 out nocopy number,
                         p_max                 out nocopy number,
                         p_rate                out nocopy number) is
 l_rate_rec pqh_rate_matrix_rates_f%rowtype;
begin
   select *
   into l_rate_rec
   from pqh_rate_matrix_rates_f
   where rate_matrix_node_id = p_rate_matrix_node_id
   and   criteria_rate_defn_id = p_crit_rate_defn_id
   and p_effective_date between effective_start_date and effective_end_date;
   p_min := l_rate_rec.min_rate_value;
   p_mid := l_rate_rec.mid_rate_value;
   p_max := l_rate_rec.max_rate_value;
   p_rate := l_rate_rec.rate_value;
exception
   when no_data_found then
      hr_utility.set_location('no value for node and rate',10);
   when others then
      hr_utility.set_location('issues in pulling rate value',20);
      raise;
end get_rate_value;
function get_annual_factor(p_freq_cd in varchar2) return number is
begin
   if p_freq_cd = 'BWK' then
      return 27;
   elsif p_freq_cd = 'MO' then
      return 12;
   elsif p_freq_cd = 'PQU' then
      return 4;
   elsif p_freq_cd = 'PWK' then
      return 52;
   elsif p_freq_cd = 'PYR' then
      return 1;
   elsif p_freq_cd = 'SAN' then
      return 2;
   elsif p_freq_cd = 'SMO' then
      return 24;
   else
      hr_utility.set_location('invalid freq passed',10);
      return -1;
   end if;
end get_annual_factor;
procedure get_comp_value(p_rate_defn_id   in number,
                         p_rounding_code  in number,
                         p_rmn_cer_id     in number,
                         p_effective_date in date,
                         p_cet_id         in number,
                         p_min            in number,
                         p_mid            in number,
                         p_max            in number,
                         p_rate           in number,
                         p_min_c          out nocopy varchar2,
                         p_mid_c          out nocopy varchar2,
                         p_max_c          out nocopy varchar2,
                         p_rate_c         out nocopy varchar2) is
     cursor crit_rate_factors (p_criteria_rate_defn_id number) is
        select * from pqh_criteria_rate_factors
        where criteria_rate_defn_id = p_criteria_rate_defn_id;
     l_crit_rate_rec pqh_criteria_rate_defn%rowtype;
     l_rate_min number;
     l_rate_mid number;
     l_rate_max number;
     l_rate_value number;
     l_rate_c number;
     l_min_c number;
     l_mid_c number;
     l_max_c number;
     l_freq_conv number;
     l_curr_conv number;
     l_rt_freq_ann number;
     l_ref_freq_ann number;
     l_curr_cd varchar2(30);
     l_freq_cd varchar2(30);
begin
   hr_utility.set_location('get computed value for RMN'||p_rmn_cer_id,10);
   hr_utility.set_location('                       CRT'||p_rate_defn_id,10);
   begin
      select * into l_crit_rate_rec
      from pqh_criteria_rate_defn
      where criteria_rate_defn_id = p_rate_defn_id;
   exception
      when no_data_found then
         hr_utility.set_location('no rate exists'||p_rate_defn_id,20);
         raise ;
      when others then
         hr_utility.set_location('rate fetch causing issues'||p_rate_defn_id,30);
         raise ;
   end;
   if l_crit_rate_rec.rate_calc_cd in ('AMOUNT','RULE') then
      hr_utility.set_location('rate of type amt ',30);
      p_min_c := null;
      p_mid_c := null;
      p_max_c := null;
      p_rate_c := null;
   elsif l_crit_rate_rec.rate_calc_cd in ('ADD_TO','PERCENT','SUM') then
      hr_utility.set_location('rate of type '||l_crit_rate_rec.rate_calc_cd,40);
      for i in crit_rate_factors(p_rate_defn_id) loop
          hr_utility.set_location('rate factors pulled ',45);
          get_rate_value(p_rmn_cer_id          => p_rmn_cer_id,
                         p_cet_id              => p_cet_id,
                         p_crit_rate_defn_id   => i.parent_criteria_rate_defn_id,
                         p_effective_date      => p_effective_date,
                         p_min                 => l_rate_min,
                         p_mid                 => l_rate_mid,
                         p_max                 => l_rate_max,
                         p_rate                => l_rate_value,
                         p_currency_cd         => l_curr_cd,
                         p_freq_cd             => l_freq_cd);
          hr_utility.set_location('parent value of rate '||l_rate_value,45);
          hr_utility.set_location('parent value of min '||l_rate_min,45);
          hr_utility.set_location('parent value of mid '||l_rate_mid,45);
          hr_utility.set_location('parent value of max '||l_rate_max,45);
          if l_freq_cd <> l_crit_rate_rec.reference_period_cd then
          -- get the conv factor between frequencies
             l_rt_freq_ann := get_annual_factor(l_freq_cd);
             l_ref_freq_ann := get_annual_factor(l_crit_rate_rec.reference_period_cd);
             l_freq_conv := l_rt_freq_ann/l_ref_freq_ann;
          else
             l_freq_conv := 1;
          end if;
          hr_utility.set_location('freq conv fctr is '||l_freq_conv,46);
          if l_curr_cd <> l_crit_rate_rec.currency_code then
          hr_utility.set_location('Conv from '||l_curr_cd||' To '||l_crit_rate_rec.currency_code,46);
          -- get the conv factor between currencies from gl_daily_rates
             begin
                select conversion_rate
                into l_curr_conv
                from gl_daily_rates
                where from_currency = l_curr_cd
                and to_currency = l_crit_rate_rec.currency_code
                and conversion_date = (select max(conversion_date)
                                       from gl_daily_rates
                                       where from_currency = l_curr_cd
                                       and to_currency = l_crit_rate_rec.currency_code
                                       and conversion_date <=p_effective_date);
             exception
                when no_data_found then
                   hr_utility.set_location('rates not exist',25);
                   l_curr_conv := 1;
                when others then
                   hr_utility.set_location('daily rates pull error',25);
                   raise;
             end;
          else
             l_curr_conv := 1;
          end if;
          hr_utility.set_location('curr conv factr is'||l_curr_conv,28);
          l_rate_min := (l_freq_conv * nvl(l_rate_min,0)*l_curr_conv);
          l_rate_mid := (l_freq_conv * nvl(l_rate_mid,0)*l_curr_conv);
          l_rate_max := (l_freq_conv * nvl(l_rate_max,0)*l_curr_conv);
          l_rate_value := (l_freq_conv * nvl(l_rate_value,0)*l_curr_conv);
          hr_utility.set_location('conv. parent value of rate '||l_rate_value,45);
          hr_utility.set_location('conv. parent value of min '||l_rate_min,45);
          hr_utility.set_location('conv. parent value of mid '||l_rate_mid,45);
          hr_utility.set_location('conv. parent value of max '||l_rate_max,45);
          if l_crit_rate_rec.rate_calc_cd = 'ADD_TO' then
             if l_rate_min is not null then
                l_min_c := l_rate_min + nvl(p_min,0);
             end if;
             if l_rate_mid is not null then
                l_mid_c := l_rate_mid + nvl(p_mid,0);
             end if;
             if l_rate_max is not null then
                l_max_c := l_rate_max + nvl(p_max,0);
             end if;
             if l_rate_value is not null then
                l_rate_c := l_rate_value + nvl(p_rate,0);
             end if;
          end if;
          if l_crit_rate_rec.rate_calc_cd = 'SUM' then
             if l_rate_min is not null then
                l_min_c := l_rate_min + nvl(l_min_c,0);
             end if;
             if l_rate_mid is not null then
                l_mid_c := l_rate_mid + nvl(l_mid_c,0);
             end if;
             if l_rate_max is not null then
                l_max_c := l_rate_max + nvl(l_max_c,0);
             end if;
             if l_rate_value is not null then
                l_rate_c := l_rate_value + nvl(l_rate_c,0);
             end if;
          end if;
          if l_crit_rate_rec.rate_calc_cd = 'PERCENT' then
             if l_rate_min is not null then
                l_min_c := l_rate_min * nvl(p_min,0) / 100 ;
             end if;
             if l_rate_mid is not null then
                l_mid_c := l_rate_mid * nvl(p_mid,0) / 100 ;
             end if;
             if l_rate_max is not null then
                l_max_c := l_rate_max * nvl(p_max,0) / 100 ;
             end if;
             if l_rate_value is not null then
                l_rate_c := l_rate_value * nvl(p_rate,0) / 100 ;
             end if;
          end if;
      end loop;
      p_min_c := to_char(round(l_min_c,p_rounding_code));
      p_mid_c := to_char(round(l_mid_c,p_rounding_code));
      p_max_c := to_char(round(l_max_c,p_rounding_code));
      p_rate_c := to_char(round(l_rate_c,p_rounding_code));
   end if;
end get_comp_value;
procedure build_rbr_for_rmn(p_rmn_cer_id     in number,
                            p_rbr_cer_id     in number,
                            p_cet_id         in number,
                            p_effective_date in date,
                            p_rbr_tr_id      in number,
                            p_rbr_tr_name    in varchar2) is
   cursor csr_rate_types is select *
                            from ben_copy_entity_results
                            where copy_entity_txn_id = p_cet_id
                            and   table_alias = 'RCR'
                            order by information160; -- in rate order
   cursor csr_rates (p_rate_defn_id in number, p_node_cer_id in number) is
                       select copy_entity_result_id,information294,information295,information296,information297
                       from ben_copy_entity_results
                       where copy_entity_txn_id = p_cet_id
                       and table_alias = 'RMR'
                       and information162 = p_rate_defn_id
                       and parent_entity_result_id = p_node_cer_id and dml_operation <> 'DELETE';
   l_rbr_cer_id number;
   l_rbr_cer_ovn number;
   l_min number;
   l_mid number;
   l_max number;
   l_rate number;
   l_rmr_cer_id number;
   l_min_c varchar2(30);
   l_mid_c varchar2(30);
   l_max_c varchar2(30);
   l_rate_c varchar2(30);

   min1 number;
   min1_c varchar2(30);
   min1_flag varchar2(30);
   mid1 number;
   mid1_c varchar2(30);
   mid1_flag varchar2(30);
   max1 number;
   max1_c varchar2(30);
   max1_flag varchar2(30);
   rate1 number;
   rate1_c varchar2(30);
   rate1_flag varchar2(30);
   rmr1_cer_id number;
   comp1_flag varchar2(30);

   min2 number;
   min2_c varchar2(30);
   min2_flag varchar2(30);
   mid2 number;
   mid2_c varchar2(30);
   mid2_flag varchar2(30);
   max2 number;
   max2_c varchar2(30);
   max2_flag varchar2(30);
   rate2 number;
   rate2_c varchar2(30);
   rate2_flag varchar2(30);
   rmr2_cer_id number;
   comp2_flag varchar2(30);

   min3 number;
   min3_c varchar2(30);
   min3_flag varchar2(30);
   mid3 number;
   mid3_c varchar2(30);
   mid3_flag varchar2(30);
   max3 number;
   max3_c varchar2(30);
   max3_flag varchar2(30);
   rate3 number;
   rate3_c varchar2(30);
   rate3_flag varchar2(30);
   rmr3_cer_id number;
   comp3_flag varchar2(30);

   min4 number;
   min4_c varchar2(30);
   min4_flag varchar2(30);
   mid4 number;
   mid4_c varchar2(30);
   mid4_flag varchar2(30);
   max4 number;
   max4_c varchar2(30);
   max4_flag varchar2(30);
   rate4 number;
   rate4_c varchar2(30);
   rate4_flag varchar2(30);
   rmr4_cer_id number;
   comp4_flag varchar2(30);

begin
   hr_utility.set_location('inside build_matx',10);
   for rate_types in csr_rate_types loop
      open csr_rates(rate_types.information1,p_rmn_cer_id);
      fetch csr_rates into l_rmr_cer_id,l_min,l_max,l_mid,l_rate;
      if csr_rates%notfound then
         hr_utility.set_location('rate not found, nulling ',10);
         hr_utility.set_location('rate type is '||rate_types.information1,10);
         hr_utility.set_location('rmn_cer is '||p_rmn_cer_id,10);
         l_min := '';
         l_mid := '';
         l_max := '';
         l_rate := '';
         l_min_c := '';
         l_mid_c := '';
         l_max_c := '';
         l_rate_c := '';
         l_rmr_cer_id := '';
      else
         hr_utility.set_location('rate value  '||l_rate,20);
         get_comp_value(p_rate_defn_id        => rate_types.information1,
                        p_rounding_code       => 3,
                        p_cet_id              => p_cet_id,
                        p_rmn_cer_id          => p_rmn_cer_id,
                        p_effective_date      => p_effective_date,
                        p_min                 => l_min,
                        p_mid                 => l_mid,
                        p_max                 => l_max,
                        p_rate                => l_rate,
                        p_min_c               => l_min_c,
                        p_mid_c               => l_mid_c,
                        p_max_c               => l_max_c,
                        p_rate_c              => l_rate_c);
         hr_utility.set_location('comp rate '||l_rate_c,20);
         hr_utility.set_location('comp min  '||l_min_c,20);
         hr_utility.set_location('comp mid  '||l_mid_c,20);
         hr_utility.set_location('comp max  '||l_max_c,20);
      end if;
      close csr_rates;
      if rate_types.information160 = 0 then
         hr_utility.set_location('1st rate values set  ',20);
         min1 := l_min;
         mid1 := l_mid;
         max1 := l_max;
         rate1 := l_rate;
         rmr1_cer_id := l_rmr_cer_id;
         min1_flag := rate_types.information111;
         mid1_flag := rate_types.information112;
         max1_flag := rate_types.information113;
         rate1_flag := rate_types.information114;
         comp1_flag := rate_types.information116;
         min1_c := l_min_c;
         mid1_c := l_mid_c;
         max1_c := l_max_c;
         rate1_c := l_rate_c;
      end if;
      if rate_types.information160 = 1 then
         hr_utility.set_location('2nd rate values set  ',20);
         min2 := l_min;
         mid2 := l_mid;
         max2 := l_max;
         rate2 := l_rate;
         rmr2_cer_id := l_rmr_cer_id;
         min2_flag := rate_types.information111;
         mid2_flag := rate_types.information112;
         max2_flag := rate_types.information113;
         rate2_flag := rate_types.information114;
         comp2_flag := rate_types.information116;
         min2_c := l_min_c;
         mid2_c := l_mid_c;
         max2_c := l_max_c;
         rate2_c := l_rate_c;
      end if;
      if rate_types.information160 = 2 then
         min3 := l_min;
         mid3 := l_mid;
         max3 := l_max;
         rate3 := l_rate;
         rmr3_cer_id := l_rmr_cer_id;
         min3_flag := rate_types.information111;
         mid3_flag := rate_types.information112;
         max3_flag := rate_types.information113;
         rate3_flag := rate_types.information114;
         comp3_flag := rate_types.information116;
         min3_c := l_min_c;
         mid3_c := l_mid_c;
         max3_c := l_max_c;
         rate3_c := l_rate_c;
      end if;
      if rate_types.information160 = 3 then
         min4 := l_min;
         mid4 := l_mid;
         max4 := l_max;
         rate4 := l_rate;
         rmr4_cer_id := l_rmr_cer_id;
         min4_flag := rate_types.information111;
         mid4_flag := rate_types.information112;
         max4_flag := rate_types.information113;
         rate4_flag := rate_types.information114;
         comp4_flag := rate_types.information116;
         min4_c := l_min_c;
         mid4_c := l_mid_c;
         max4_c := l_max_c;
         rate4_c := l_rate_c;
      end if;
   end loop;
   if p_rbr_cer_id is null then
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => p_rbr_tr_name
      ,p_table_route_id             => p_rbr_tr_id
      ,p_table_alias                => 'RBR'
      ,p_dml_operation              => 'COPIED'
      ,p_Information287             => min1
      ,p_Information288             => mid1
      ,p_Information289             => max1
      ,p_Information290             => rate1
      ,p_Information160             => rmr1_cer_id
      ,p_Information36              => min1_c
      ,p_Information37              => mid1_c
      ,p_Information38              => max1_c
      ,p_Information39              => rate1_c
      ,p_Information11              => min1_flag
      ,p_Information12              => mid1_flag
      ,p_Information13              => max1_flag
      ,p_Information14              => rate1_flag
      ,p_Information15              => comp1_flag
      ,p_Information293             => min2
      ,p_Information294             => mid2
      ,p_Information295             => max2
      ,p_Information296             => rate2
      ,p_Information161             => rmr2_cer_id
      ,p_Information40              => min2_c
      ,p_Information41              => mid2_c
      ,p_Information42              => max2_c
      ,p_Information43              => rate2_c
      ,p_Information16              => min2_flag
      ,p_Information17              => mid2_flag
      ,p_Information18              => max2_flag
      ,p_Information19              => rate2_flag
      ,p_Information20              => comp2_flag
      ,p_Information297             => min3
      ,p_Information298             => mid3
      ,p_Information299             => max3
      ,p_Information300             => rate3
      ,p_Information162             => rmr3_cer_id
      ,p_Information44              => min3_c
      ,p_Information45              => mid3_c
      ,p_Information46              => max3_c
      ,p_Information47              => rate3_c
      ,p_Information21              => min3_flag
      ,p_Information22              => mid3_flag
      ,p_Information23              => max3_flag
      ,p_Information24              => rate3_flag
      ,p_Information25              => comp3_flag
      ,p_Information301             => min4
      ,p_Information302             => mid4
      ,p_Information303             => max4
      ,p_Information304             => rate4
      ,p_Information169             => rmr4_cer_id
      ,p_Information48              => min4_c
      ,p_Information49              => mid4_c
      ,p_Information50              => max4_c
      ,p_Information51              => rate4_c
      ,p_Information26              => min4_flag
      ,p_Information27              => mid4_flag
      ,p_Information28              => max4_flag
      ,p_Information29              => rate4_flag
      ,p_Information30              => comp4_flag
      ,p_information1               => p_rmn_cer_id
      ,p_copy_entity_result_id      => l_rbr_cer_id
      ,p_object_version_number      => l_rbr_cer_ovn);
      hr_utility.set_location('rbr row created',20);
   else
      l_rbr_cer_ovn := pqh_gsp_stage_to_ben.get_ovn(
                       p_table_name       => 'BEN_COPY_ENTITY_RESULTS',
                       p_key_column_name  => 'COPY_ENTITY_RESULT_ID',
                       p_key_column_value => p_rbr_cer_id,
                       p_effective_date   => '');
      hr_utility.set_location('rbr ovn is'||l_rbr_cer_ovn,10);
      ben_copy_entity_results_api.update_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => p_rbr_tr_name
      ,p_table_route_id             => p_rbr_tr_id
      ,p_table_alias                => 'RBR'
      ,p_Information287             => min1
      ,p_Information288             => mid1
      ,p_Information289             => max1
      ,p_Information290             => rate1
      ,p_Information160             => rmr1_cer_id
      ,p_Information36              => min1_c
      ,p_Information37              => mid1_c
      ,p_Information38              => max1_c
      ,p_Information39              => rate1_c
      ,p_Information11              => min1_flag
      ,p_Information12              => mid1_flag
      ,p_Information13              => max1_flag
      ,p_Information14              => rate1_flag
      ,p_Information15              => comp1_flag
      ,p_Information293             => min2
      ,p_Information294             => mid2
      ,p_Information295             => max2
      ,p_Information296             => rate2
      ,p_Information161             => rmr2_cer_id
      ,p_Information40              => min2_c
      ,p_Information41              => mid2_c
      ,p_Information42              => max2_c
      ,p_Information43              => rate2_c
      ,p_Information16              => min2_flag
      ,p_Information17              => mid2_flag
      ,p_Information18              => max2_flag
      ,p_Information19              => rate2_flag
      ,p_Information20              => comp2_flag
      ,p_Information297             => min3
      ,p_Information298             => mid3
      ,p_Information299             => max3
      ,p_Information300             => rate3
      ,p_Information162             => rmr3_cer_id
      ,p_Information44              => min3_c
      ,p_Information45              => mid3_c
      ,p_Information46              => max3_c
      ,p_Information47              => rate3_c
      ,p_Information21              => min3_flag
      ,p_Information22              => mid3_flag
      ,p_Information23              => max3_flag
      ,p_Information24              => rate3_flag
      ,p_Information25              => comp3_flag
      ,p_Information301             => min4
      ,p_Information302             => mid4
      ,p_Information303             => max4
      ,p_Information304             => rate4
      ,p_Information169             => rmr4_cer_id
      ,p_Information48              => min4_c
      ,p_Information49              => mid4_c
      ,p_Information50              => max4_c
      ,p_Information51              => rate4_c
      ,p_Information26              => min4_flag
      ,p_Information27              => mid4_flag
      ,p_Information28              => max4_flag
      ,p_Information29              => rate4_flag
      ,p_Information30              => comp4_flag
      ,p_information1               => p_rmn_cer_id
      ,p_copy_entity_result_id      => p_rbr_cer_id
      ,p_object_version_number      => l_rbr_cer_ovn
      ,p_information323             => '');
      hr_utility.set_location('rbr row updated',20);
   end if;
end build_rbr_for_rmn;
procedure recalc_rate_matx(p_cet_id in number,
                           p_effective_date in date) is
   cursor c1 is select *
                from ben_copy_entity_results
                where copy_entity_txn_id = p_cet_id
                and table_alias = 'RBR'
                and nvl(dml_operation,'UPDATE') = 'UPDATE';
   l_rbr_tr_id number;
   l_rbr_tr_name varchar2(150);

begin
   hr_utility.set_location('inside recalc',10);
   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RBR',
   p_table_route_id => l_rbr_tr_id,
   p_table_name     => l_rbr_tr_name);
   hr_utility.set_location('tr name is  '||l_rbr_tr_name,10);
   for i in c1 loop
       rbr_writeback(p_rbr_cer_id => i.copy_entity_result_id,
                     p_effective_date => p_effective_date);
       hr_utility.set_location('rbr wrtbk comple for rmn_cer'||i.information1,22);
       build_rbr_for_rmn(p_rmn_cer_id     => i.information1,
                         p_rbr_cer_id     => i.copy_entity_result_id,
                         p_cet_id         => p_cet_id,
                         p_effective_date => p_effective_date,
                         p_rbr_tr_id      => l_rbr_tr_id,
                         p_rbr_tr_name    => l_rbr_tr_name);
       hr_utility.set_location('rbr row built ',22);
   end loop;
end recalc_rate_matx;
procedure build_rate_matx(p_cet_id in number,
                          p_effective_date in date) is
   cursor csr_nodes is select copy_entity_result_id
                       from ben_copy_entity_results
                       where copy_entity_txn_id = p_cet_id
                       and table_alias = 'RMN'
                       and dml_operation <> 'DELETE';
   cursor csr_rbr(p_rmn_cer_id number) is
                     select copy_entity_result_id
                     from ben_copy_entity_results
                     where copy_entity_txn_id = p_cet_id
                       and table_alias = 'RBR'
                       and information1 = p_rmn_cer_id;
   l_rbr_tr_id number;
   l_rbr_tr_name varchar2(150);
   l_rbr_cer_id number;
begin
   hr_utility.set_location('inside build_matx',10);
   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RBR',
   p_table_route_id => l_rbr_tr_id,
   p_table_name     => l_rbr_tr_name);
   hr_utility.set_location('tr name is  '||l_rbr_tr_name,10);
   for node in csr_nodes loop
       hr_utility.set_location('rmn cer is '||node.copy_entity_result_id,20);
       open csr_rbr(node.copy_entity_result_id);
       fetch csr_rbr into l_rbr_cer_id;
       if csr_rbr%notfound then
          hr_utility.set_location('rbr cer is '||l_rbr_cer_id,10);
          l_rbr_cer_id := '';
       end if;
       close csr_rbr;
       build_rbr_for_rmn(p_rmn_cer_id     => node.copy_entity_result_id,
                         p_rbr_cer_id     => l_rbr_cer_id,
                         p_cet_id         => p_cet_id,
                         p_effective_date => p_effective_date,
                         p_rbr_tr_id      => l_rbr_tr_id,
                         p_rbr_tr_name    => l_rbr_tr_name);
   end loop;
end build_rate_matx;
procedure write_rmr_row(p_rmr_cer_id in number,
                        p_rmn_cer_id in number,
                        p_cet_id     in number,
                        p_effective_date in date,
                        p_rate_level in number,
                        p_min        in number,
                        p_mid        in number,
                        p_max        in number,
                        p_value      in number) is
   l_rcr_rec ben_copy_entity_results%rowtype;
   l_rmr_cer_id number;
   l_rmr_cer_ovn number;
   l_rmr_tr_id number;
   l_rmr_tr_name varchar2(80);
   l_rmr_rec ben_copy_entity_results%rowtype;
   l_dml_operation varchar2(30);
   cursor c1 is select * from ben_copy_entity_results
                where copy_entity_result_id = p_rmr_cer_id
                for update of dml_operation;
begin
   if p_rmr_cer_id is null then
      begin
         select * into l_rcr_rec
         from ben_copy_entity_results
         where copy_entity_txn_id = p_cet_id
         and table_alias ='RCR'
         and information160 = p_rate_level;
      exception
         when no_data_found then
            hr_utility.set_location('Rate does not exist',10);
            raise;
         when others then
            hr_utility.set_location('Rate retrival issue ',20);
            raise;
      end;
      pqh_gsp_hr_to_stage.get_table_route_details
      (p_table_alias    => 'RMR',
      p_table_route_id => l_rmr_tr_id,
      p_table_name     => l_rmr_tr_name);
      hr_utility.set_location('rmr tr name is  '||l_rmr_tr_name,10);

      hr_utility.set_location('new rmr row to be cred, rate type'||p_rate_level,10);
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => l_rmr_tr_name
      ,p_table_route_id             => l_rmr_tr_id
      ,p_table_alias                => 'RMR'
      ,p_dml_operation              => 'CREATE'
      ,p_information2               => p_effective_date
      ,p_information4               => l_rcr_rec.information4
      ,p_information294             => p_min
      ,p_information295             => p_max
      ,p_information296             => p_mid
      ,p_information297             => p_value
      ,p_information162             => l_rcr_rec.information1
      ,p_parent_entity_result_id    => p_rmn_cer_id
      ,p_copy_entity_result_id      => l_rmr_cer_id
      ,p_object_version_number      => l_rmr_cer_ovn);
      hr_utility.set_location('rmr cer row is  '||l_rmr_cer_id,30);
   else
      hr_utility.set_location('existing rmr row to be upd',30);
      open c1;
      fetch c1 into l_rmr_rec;
      if c1%notfound then
         hr_utility.set_location('rmr row doesnot exist',30);
      else
         if nvl(l_rmr_rec.dml_operation,'COPIED') = 'COPIED' then
            l_dml_operation := 'UPDATE';
         else
            l_dml_operation := l_rmr_rec.dml_operation;
         end if;
         update ben_copy_entity_results
         set information294 = p_min,
             information295 = p_max,
             information296 = p_mid,
             information297 = p_value,
             dml_operation = l_dml_operation
         where current of c1;
         hr_utility.set_location('rmr row upd',30);
      end if;
      close c1;
   end if;
end write_rmr_row;
procedure set_rmn_stat(p_rmn_cer_id in number) is
   cursor c1 is select dml_operation
                from ben_copy_entity_results
                where copy_entity_result_id = p_rmn_cer_id
                for update of dml_operation;
   l_stat varchar2(80);
begin
   open c1;
   fetch c1 into l_stat;
   if c1%found then
      if l_stat not in ('CREATE','UPDATE') then
         update ben_copy_entity_results
         set dml_operation ='UPDATE'
         where current of c1;
      else
         hr_utility.set_location('rmn stat'||l_stat,20);
      end if;
   else
      hr_utility.set_location('no rmn'||p_rmn_cer_id,10);
   end if;
   close c1;
exception
   when no_data_found then
      hr_utility.set_location('no rmn'||p_rmn_cer_id,10);
      raise;
   when others then
      hr_utility.set_location('issues in getting rmn'||p_rmn_cer_id,10);
      raise;
end set_rmn_stat;
procedure rbr_writeback(p_cet_id         in number,
                        p_effective_date in date) is
   cursor c1 is select * from ben_copy_entity_results
                where copy_entity_txn_id = p_cet_id
                and   table_alias ='RBR'
                and   nvl(dml_operation,'UPDATE') = 'UPDATE'
                for update of dml_operation;
begin
   for i in c1 loop
       rbr_writeback(p_rbr_cer_id => i.copy_entity_result_id,
                     p_effective_date => p_effective_date);
       update ben_copy_entity_results
       set dml_operation = 'COPIED'
       where current of c1;
   end loop;
end rbr_writeback;
procedure rbr_writeback(p_rbr_cer_id     in number,
                        p_effective_date in date) is
   l_rbr_rec ben_copy_entity_results%rowtype;
   l_rate1_exists varchar2(30);
   l_rate2_exists varchar2(30);
   l_rate3_exists varchar2(30);
   l_rate4_exists varchar2(30);
begin
   begin
      select * into l_rbr_rec
      from ben_copy_entity_results
      where copy_entity_result_id = p_rbr_cer_id;
   exception
      when no_data_found then
         hr_utility.set_location('invalid rbr cer passed'||p_rbr_cer_id,10);
         raise;
      when others then
         hr_utility.set_location('issue in rbr pull'||p_rbr_cer_id,10);
         raise;
   end;
   if l_rbr_rec.information160 is not null or
      l_rbr_rec.information15  is not null or
      l_rbr_rec.information287 is not null or
      l_rbr_rec.information288 is not null or
      l_rbr_rec.information289 is not null or
      l_rbr_rec.information290 is not null then
      hr_utility.set_location('1st rmr exists with val '||l_rbr_rec.information290,10);
      l_rate1_exists := 'Y';
   else
      l_rate1_exists := 'N';
   end if;
   if l_rbr_rec.information161 is not null or
      l_rbr_rec.information20  is not null or
      l_rbr_rec.information293 is not null or
      l_rbr_rec.information294 is not null or
      l_rbr_rec.information295 is not null or
      l_rbr_rec.information296 is not null then
      hr_utility.set_location('2nd rmr exists with val '||l_rbr_rec.information296,10);
      l_rate2_exists := 'Y';
   else
      l_rate2_exists := 'N';
   end if;
   if l_rbr_rec.information162 is not null or
      l_rbr_rec.information25  is not null or
      l_rbr_rec.information297 is not null or
      l_rbr_rec.information298 is not null or
      l_rbr_rec.information299 is not null or
      l_rbr_rec.information300 is not null then
      hr_utility.set_location('3rd rmr exists with val '||l_rbr_rec.information300,10);
      l_rate3_exists := 'Y';
   else
      l_rate3_exists := 'N';
   end if;
   if l_rbr_rec.information169 is not null or
      l_rbr_rec.information30  is not null or
      l_rbr_rec.information301 is not null or
      l_rbr_rec.information302 is not null or
      l_rbr_rec.information303 is not null or
      l_rbr_rec.information304 is not null then
      hr_utility.set_location('4th rmr exists with val '||l_rbr_rec.information294,10);
      l_rate4_exists := 'Y';
   else
      l_rate4_exists := 'N';
   end if;
   if l_rate1_exists = 'Y' then
      hr_utility.set_location('update rmn status '||l_rbr_rec.information1,10);
      set_rmn_stat(p_rmn_cer_id => l_rbr_rec.information1);
      hr_utility.set_location('writing 1st rmr for rbr'||p_rbr_cer_id,10);
      write_rmr_row(p_rmr_cer_id => l_rbr_rec.information160,
                    p_rmn_cer_id => l_rbr_rec.information1,
                    p_rate_level => 0,
                    p_cet_id     => l_rbr_rec.copy_entity_txn_id,
                    p_effective_date => p_effective_date,
                    p_min        => l_rbr_rec.information287,
                    p_mid        => l_rbr_rec.information288,
                    p_max        => l_rbr_rec.information289,
                    p_value      => l_rbr_rec.information290);
      if l_rate2_exists = 'Y' then
         hr_utility.set_location('writing 2nd rmr for rbr'||p_rbr_cer_id,10);
         write_rmr_row(p_rmr_cer_id => l_rbr_rec.information161,
                       p_rmn_cer_id => l_rbr_rec.information1,
                       p_rate_level => 1,
                       p_cet_id     => l_rbr_rec.copy_entity_txn_id,
                       p_effective_date => p_effective_date,
                       p_min        => l_rbr_rec.information293,
                       p_mid        => l_rbr_rec.information294,
                       p_max        => l_rbr_rec.information295,
                       p_value      => l_rbr_rec.information296);
         if l_rate3_exists = 'Y' then
            hr_utility.set_location('writing 3rd rmr for rbr'||p_rbr_cer_id,10);
            write_rmr_row(p_rmr_cer_id => l_rbr_rec.information162,
                          p_rmn_cer_id => l_rbr_rec.information1,
                          p_rate_level => 2,
                          p_cet_id     => l_rbr_rec.copy_entity_txn_id,
                          p_effective_date => p_effective_date,
                          p_min        => l_rbr_rec.information297,
                          p_mid        => l_rbr_rec.information298,
                          p_max        => l_rbr_rec.information299,
                          p_value      => l_rbr_rec.information300);
            if l_rate4_exists = 'Y' then
               hr_utility.set_location('writing 4th rmr for rbr'||p_rbr_cer_id,10);
               write_rmr_row(p_rmr_cer_id => l_rbr_rec.information169,
                             p_rmn_cer_id => l_rbr_rec.information1,
                             p_rate_level => 3,
                             p_cet_id     => l_rbr_rec.copy_entity_txn_id,
                             p_effective_date => p_effective_date,
                             p_min        => l_rbr_rec.information301,
                             p_mid        => l_rbr_rec.information302,
                             p_max        => l_rbr_rec.information303,
                             p_value      => l_rbr_rec.information304);
            else
               hr_utility.set_location('4th rate not there',10);
            end if;
         else
            hr_utility.set_location('3rd rate not there',10);
         end if;
      else
         hr_utility.set_location('2nd rate not there',10);
      end if;
   else
      hr_utility.set_location('1st rate not there',10);
   end if;
end rbr_writeback;
procedure load_plan(p_rate_matrix_id     in number,
                    p_cet_id             in number,
                    p_effective_date     in date,
                    p_business_group_id  in number,
                    p_plan_cer_id           out nocopy number) is
   l_pln_tr_id number;
   l_pln_tr_name varchar2(80);
   l_plan_cer_ovn number;
   l_plan_cer_id number;

   l_rmn_tr_id number;
   l_rmn_tr_name varchar2(80);
   l_rmn_cer_ovn number;
   l_rmn_cer_id number;

   l_rcr_tr_id number;
   l_rcr_tr_name varchar2(80);
   l_rcr_cer_ovn number;
   l_rcr_cer_id number;

   l_rate_count number;

   cursor c1 is select * from ben_pl_f
                where pl_id = p_rate_matrix_id
                and p_effective_date between effective_start_date and effective_end_date;
begin
   for pl_row in c1 loop
       hr_utility.set_location('for copying matx plan row',10);
       pqh_gsp_hr_to_stage.get_table_route_details
       (p_table_alias    => 'PLN',
        p_table_route_id => l_pln_tr_id,
        p_table_name     => l_pln_tr_name);
       hr_utility.set_location('tr name is  '||l_pln_tr_name,10);

       pqh_gsp_hr_to_stage.get_table_route_details
       (p_table_alias    => 'RMN',
        p_table_route_id => l_rmn_tr_id,
        p_table_name     => l_rmn_tr_name);
       hr_utility.set_location('tr name is  '||l_rmn_tr_name,10);

       pqh_gsp_hr_to_stage.get_table_route_details
       (p_table_alias    => 'RCR',
        p_table_route_id => l_rcr_tr_id,
        p_table_name     => l_rcr_tr_name);
       hr_utility.set_location('tr name is  '||l_rcr_tr_name,10);


       ben_copy_entity_results_api.create_copy_entity_results(
       p_effective_date              => p_effective_date
       ,p_copy_entity_txn_id         => p_cet_id
       ,p_result_type_cd             => 'DISPLAY'
       ,p_table_name                 => l_pln_tr_name
       ,p_table_route_id             => l_pln_tr_id
       ,p_table_alias                => 'PLN'
       ,p_dml_operation              => 'COPIED'
       ,p_information1               => pl_row.pl_id
       ,p_information2               => pl_row.effective_start_date
       ,p_information3               => pl_row.effective_end_date
       ,p_information4               => p_business_group_id
       ,p_information5               => pl_row.name
       ,p_information170             => pl_row.name
       ,p_information265             => pl_row.object_version_number
       ,p_information19              => pl_row.pl_stat_cd
       ,p_information93              => pl_row.short_code
       ,p_information94              => pl_row.short_name
       ,p_copy_entity_result_id      => l_plan_cer_id
       ,p_object_version_number      => l_plan_cer_ovn);
       hr_utility.set_location('pln cer row is  '||l_plan_cer_id,10);
       p_plan_cer_id := l_plan_cer_id;
       if p_plan_cer_id is not null then
          matx_rates(p_rate_matrix_id      => pl_row.pl_id,
                     p_cet_id              => p_cet_id,
                     p_effective_date      => p_effective_date,
                     p_business_group_id   => p_business_group_id,
                     p_rcr_tr_name         => l_rcr_tr_name,
                     p_rcr_tr_id           => l_rcr_tr_id,
                     p_count               => l_rate_count);
          hr_utility.set_location('rates counted and copied  '||l_rate_count,50);
       end if;
   end loop;
exception
   when others then
      hr_utility.set_location('issues in copying plan row',10);
      raise;
end load_plan;

procedure node_val_details(p_rate_matrix_node_id in number,
                           p_rmn_cer_id          in number,
                           p_cet_id              in number,
                           p_crit_type           in varchar2,
                           p_effective_date      in date,
                           p_business_group_id   in number,
                           p_rnv_tr_name         in varchar2,
                           p_rnv_tr_id           in number) is
   l_rnv_cer_id number;
   l_rnv_cer_ovn number;
   l_number_oh_value number;
   l_number_ph_value number;
   l_number_xh_value number;
   l_number_on_value number;
   l_number_pn_value number;
   l_number_xn_value number;
   cursor c_node_val is select * from pqh_rt_matrix_node_values
                        where rate_matrix_node_id = p_rate_matrix_node_id;
begin
   hr_utility.set_location('inside copying node_val ',10);
   for node_val in c_node_val loop
      hr_utility.set_location('copying node_val to staging',20);
      if p_crit_type = 'OH' then
         l_number_oh_value := node_val.number_value1;
         l_number_on_value := node_val.number_value2;
      elsif p_crit_type = 'PH' then
         l_number_ph_value := node_val.number_value1;
         l_number_pn_value := node_val.number_value2;
      else
         l_number_xh_value := node_val.number_value1;
         l_number_xn_value := node_val.number_value2;
      end if;
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => p_rnv_tr_name
      ,p_table_route_id             => p_rnv_tr_id
      ,p_table_alias                => 'RMV'
      ,p_dml_operation              => 'COPIED'
      ,p_information1               => node_val.node_value_id
      ,p_information4               => p_business_group_id
      ,p_information265             => node_val.object_version_number
      ,p_information161             => p_rate_matrix_node_id
      ,p_information13              => node_val.char_value1
      ,p_information14              => node_val.char_value2
      ,p_information169             => l_number_xh_value
      ,p_information174             => l_number_xn_value
      ,p_information223             => l_number_oh_value
      ,p_information224             => l_number_on_value
      ,p_information225             => l_number_ph_value
      ,p_information226             => l_number_pn_value
      ,p_information166             => node_val.date_value1
      ,p_information167             => node_val.date_value2
      ,p_information15              => node_val.char_value3
      ,p_information16              => node_val.char_value4
      ,p_information221             => node_val.number_value3
      ,p_information222             => node_val.number_value4
      ,p_information306             => node_val.date_value3
      ,p_information307             => node_val.date_value4
      ,p_information12              => node_val.short_code
      ,p_parent_entity_result_id    => p_rmn_cer_id
      ,p_gs_parent_entity_result_id => p_rmn_cer_id
      ,p_copy_entity_result_id      => l_rnv_cer_id
      ,p_object_version_number      => l_rnv_cer_ovn);
      hr_utility.set_location('rnv cer row is  '||l_rnv_cer_id,30);
   end loop;
exception
   when others then
      hr_utility.set_location('issues in pulling node values',10);
      raise;
end node_val_details;
procedure node_rates(p_rate_matrix_node_id in number,
                     p_rmn_cer_id          in number,
                     p_cet_id              in number,
                     p_effective_date      in date,
                     p_business_group_id   in number,
                     p_rmr_tr_name         in varchar2,
                     p_rmr_tr_id           in number) is
   l_rmr_cer_id number;
   l_rmr_cer_ovn number;
   cursor c_node_rate is select * from pqh_rate_matrix_rates_f
                        where rate_matrix_node_id = p_rate_matrix_node_id
                        and p_effective_date between effective_start_date and effective_end_date;
begin
   hr_utility.set_location('inside copying node_rate ',10);
   for node_rate in c_node_rate loop
      hr_utility.set_location('copying node_rate to staging',20);
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_cet_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => p_rmr_tr_name
      ,p_table_route_id             => p_rmr_tr_id
      ,p_table_alias                => 'RMR'
      ,p_dml_operation              => 'COPIED'
      ,p_information1               => node_rate.rate_matrix_rate_id
      ,p_information2               => node_rate.effective_start_date
      ,p_information3               => node_rate.effective_end_date
      ,p_information4               => p_business_group_id
      ,p_information265             => node_rate.object_version_number
      ,p_information294             => node_rate.min_rate_value
      ,p_information295             => node_rate.max_rate_value
      ,p_information296             => node_rate.mid_rate_value
      ,p_information297             => node_rate.rate_value
      ,p_information162             => node_rate.criteria_rate_defn_id
      ,p_information161             => p_rate_matrix_node_id
      ,p_parent_entity_result_id    => p_rmn_cer_id
      ,p_copy_entity_result_id      => l_rmr_cer_id
      ,p_object_version_number      => l_rmr_cer_ovn);
      hr_utility.set_location('rmr cer row is  '||l_rmr_cer_id,30);
   end loop;
exception
   when others then
      hr_utility.set_location('issues in pulling node rates',10);
      raise;
end node_rates;
procedure load_matrix_dtls(p_rate_matrix_id     in number,
                           p_cet_id             in number,
                           p_plan_cer_id        in number,
                           p_effective_date     in date,
                           p_business_group_id  in number,
                           p_status_flag           out nocopy number) is
   l_rmn_tr_id number;
   l_rmn_tr_name varchar2(80);
   l_rmn_cer_id number;
   l_rmn_cer_ovn number;

   l_rmr_tr_id number;
   l_rmr_tr_name varchar2(80);

   l_rnv_tr_id number;
   l_rnv_tr_name varchar2(80);
   l_node_name varchar2(2000);

   l_crt_tr_id number;
   l_crit_type varchar2(30);
   l_crt_tr_name varchar2(80);
   l_crit ben_eligy_criteria%rowtype;
   l_crt_cer_id number;
   l_crt_cer_ovn number;
   l_status_flag number := 0;
   l_parent_id number;
   /**
   cursor c_crit is select distinct criteria_short_code,level_number
                    from pqh_rate_matrix_nodes
                    where pl_id = p_rate_matrix_id
                    and criteria_short_code is not null
                    order by level_number;
   **/
   cursor c_crit is select distinct a.criteria_short_code,a.level_number
                    from pqh_rate_matrix_nodes a, ben_eligy_prfl_f b
                    where a.pl_id = p_rate_matrix_id
                    and a.criteria_short_code is not null
                    and a.eligy_prfl_id = b.eligy_prfl_id
                    and p_effective_date between b.effective_start_date and b.effective_end_date
                    order by a.level_number;
   --
   /**
   cursor c_node is select * from pqh_rate_matrix_nodes
                    where pl_id = p_rate_matrix_id
                    order by level_number;
   **/
   cursor c_node is select a.* from pqh_rate_matrix_nodes a
                    where a.pl_id = p_rate_matrix_id
                      and (a.eligy_prfl_id is null
                    or exists (Select 1 from ben_eligy_prfl_f b
                    where a.eligy_prfl_id = b.eligy_prfl_id
                      and p_effective_date between b.effective_start_date and b.effective_end_date))
                    order by level_number;

  --
begin
   hr_utility.set_location('inside plan dtl copy ',10);
   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RBC_CRIT',
   p_table_route_id => l_crt_tr_id,
   p_table_name     => l_crt_tr_name);
   hr_utility.set_location('rbc_crit tr name is  '||l_crt_tr_name,10);

   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RMN',
   p_table_route_id => l_rmn_tr_id,
   p_table_name     => l_rmn_tr_name);
   hr_utility.set_location('rmn tr name is  '||l_rmn_tr_name,10);

   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RMV',
   p_table_route_id => l_rnv_tr_id,
   p_table_name     => l_rnv_tr_name);
   hr_utility.set_location('rnv tr name is  '||l_rnv_tr_name,10);

   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RMR',
   p_table_route_id => l_rmr_tr_id,
   p_table_name     => l_rmr_tr_name);
   hr_utility.set_location('rmr tr name is  '||l_rmr_tr_name,10);

   begin
     for crit in c_crit loop
       hr_utility.set_location('for copying matx crit row',10);
       if crit.criteria_short_code is not null then
          get_criteria(p_criteria_short_code => crit.criteria_short_code,
                       p_business_group_id   => p_business_group_id,
                       p_crit_rec            => l_crit);
       end if;
       ben_copy_entity_results_api.create_copy_entity_results(
       p_effective_date              => p_effective_date
       ,p_copy_entity_txn_id         => p_cet_id
       ,p_result_type_cd             => 'DISPLAY'
       ,p_table_name                 => l_crt_tr_name
       ,p_table_route_id             => l_crt_tr_id
       ,p_table_alias                => 'RBC_CRIT'
       ,p_dml_operation              => 'COPIED'
       ,p_information4               => p_business_group_id
       ,p_information1               => l_crit.eligy_criteria_id
       ,p_information261             => p_rate_matrix_id
       ,p_information13              => crit.criteria_short_code
       ,p_information160             => crit.level_number
       ,p_information170             => l_crit.name
       ,p_information5               => l_crit.name
       ,p_parent_entity_result_id    => p_plan_cer_id
       ,p_gs_parent_entity_result_id => nvl(l_crt_cer_id,p_plan_cer_id)
       ,p_copy_entity_result_id      => l_crt_cer_id
       ,p_object_version_number      => l_crt_cer_ovn);
       hr_utility.set_location('crt cer row is  '||l_crt_cer_id,10);
       end loop;
   exception
       when others then
          hr_utility.set_location('issues in copying rbc_crit row',10);
          raise;
   end;
   for node in c_node loop
       hr_utility.set_location('for copying matx plan row',10);
      if node.level_number = 1 then
         hr_utility.set_location('root node, no need to build name',10);
      else
         l_node_name :=  build_rate_node_name
             (p_rate_matrix_node_id => node.rate_matrix_node_id,
              p_business_group_id   => p_business_group_id,
              p_node_short_code     => node.criteria_short_code,
              p_effective_date      => p_effective_date);
      end if;
      if node.level_number > 1 then
         l_parent_id := get_rmn_cer(p_rmn_id => node.parent_node_id,
                                    p_cet_id => p_cet_id);
      else
         l_parent_id := p_plan_cer_id;
      end if;
       ben_copy_entity_results_api.create_copy_entity_results(
       p_effective_date              => p_effective_date
       ,p_copy_entity_txn_id         => p_cet_id
       ,p_result_type_cd             => 'DISPLAY'
       ,p_table_name                 => l_rmn_tr_name
       ,p_table_route_id             => l_rmn_tr_id
       ,p_table_alias                => 'RMN'
       ,p_dml_operation              => 'COPIED'
       ,p_information1               => node.rate_matrix_node_id
       ,p_information4               => p_business_group_id
       ,p_information265             => node.object_version_number
       ,p_information219             => l_node_name
       ,p_information5               => l_node_name
       ,p_information261             => node.pl_id
       ,p_information160             => node.level_number
       ,p_information12              => node.short_code
       ,p_information13              => node.criteria_short_code
       ,p_information161             => node.parent_node_id
       ,p_information169             => node.eligy_prfl_id
       ,p_parent_entity_result_id    => p_plan_cer_id
       ,p_gs_parent_entity_result_id => l_parent_id
       ,p_copy_entity_result_id      => l_rmn_cer_id
       ,p_object_version_number      => l_rmn_cer_ovn);
       hr_utility.set_location('rmn cer row is  '||l_rmn_cer_id,10);
       if node.criteria_short_code is not null then
          l_crit_type := get_crit_type(node.criteria_short_code,p_business_group_id);
          hr_utility.set_location('crit type is '||l_crit_type,10);
          if l_rmn_cer_id is not null then
             node_val_details(p_rate_matrix_node_id => node.rate_matrix_node_id,
                              p_rmn_cer_id          => l_rmn_cer_id,
                              p_cet_id              => p_cet_id,
                              p_crit_type           => l_crit_type,
                              p_effective_date      => p_effective_date,
                              p_business_group_id   => p_business_group_id,
                              p_rnv_tr_name         => l_rnv_tr_name,
                              p_rnv_tr_id           => l_rnv_tr_id);
             node_rates(p_rate_matrix_node_id => node.rate_matrix_node_id,
                        p_rmn_cer_id          => l_rmn_cer_id,
                        p_cet_id              => p_cet_id,
                        p_effective_date      => p_effective_date,
                        p_business_group_id   => p_business_group_id,
                        p_rmr_tr_name         => l_rmr_tr_name,
                        p_rmr_tr_id           => l_rmr_tr_id);
          else
             hr_utility.set_location('xxxxxxxxxxxxxxxxx',32);
          end if;
       else
          hr_utility.set_location('for top node ',40);
       end if;
   end loop;
   p_status_flag := l_status_flag;
exception
   when others then
      hr_utility.set_location('issues in copying rmn row',10);
      raise;
end load_matrix_dtls;

procedure load_matrix(p_rate_matrix_id     in number,
                      p_copy_entity_txn_id in number,
                      p_effective_date     in date,
                      p_business_group_id  in number,
                      p_status_flag           out nocopy number) is
   l_status_flag number := 0;
   l_plan_cer_id number;
begin
   hr_utility.set_location('here to copy plan',10);
   load_plan(p_rate_matrix_id    => p_rate_matrix_id,
             p_cet_id            => p_copy_entity_txn_id,
             p_effective_date    => p_effective_date,
             p_business_group_id => p_business_group_id,
             p_plan_cer_id       => l_plan_cer_id);
   hr_utility.set_location('copied plan cer '||l_plan_cer_id,15);
   hr_utility.set_location('here to copy plan details',20);
   load_matrix_dtls(p_rate_matrix_id    => p_rate_matrix_id,
                    p_cet_id            => p_copy_entity_txn_id,
                    p_plan_cer_id       => l_plan_cer_id,
                    p_effective_date    => p_effective_date,
                    p_business_group_id => p_business_group_id,
                    p_status_flag       => l_status_flag);
   p_status_flag := l_status_flag;
   hr_utility.set_location('plan dtls copied with stat '||l_status_flag,25);
end load_matrix;
procedure chk_matrix_presence(p_rate_matrix_id    in number,
                              p_business_group_id in number,
                              p_copy_entity_txn_id   out nocopy number) is
   l_cet_id number;
begin
   select txn.copy_entity_txn_id
   into l_cet_id
   from pqh_copy_entity_txns txn , ben_copy_entity_results cer
   where cer.copy_entity_txn_id = txn.copy_entity_txn_id
   and txn.context ='RBC_MATRIX'
   and txn.status = 'UPDATE'
   and txn.context_business_group_id = p_business_group_id
   and cer.table_alias = 'PLN'
   and cer.information1 = p_rate_matrix_id;
   hr_utility.set_location('cet row found is '||l_cet_id,10);
   p_copy_entity_txn_id := l_cet_id;
exception
   when no_data_found then
      p_copy_entity_txn_id := l_cet_id;
      hr_utility.set_location('no cet row exists ',10);
   when others then
      hr_utility.set_location('issues in checking matx presence',10);
      raise;
end chk_matrix_presence;
procedure upd_matrix(p_rate_matrix_id     in number,
                     p_effective_date     in date,
                     p_business_group_id  in number,
                     p_mode               in varchar2 default 'NORMAL',
                     p_matrix_loaded          out nocopy varchar2,
                     p_copy_entity_txn_id     out nocopy number) is
   l_cet_id number;
   l_status_flag number := 0;
begin
   p_matrix_loaded := 'ERR';
   set_session_date(p_effective_date => p_effective_date);
   if p_mode ='NORMAL' then
      hr_utility.set_location('checking matx presence in staging',10);
      chk_matrix_presence(p_rate_matrix_id     => p_rate_matrix_id,
                          p_business_group_id  => p_business_group_id,
                          p_copy_entity_txn_id => l_cet_id);
      if l_cet_id is null then
         hr_utility.set_location('matx not in stage, copying ',10);
         create_matrix_txn(p_mode               => 'UPDATE',
                           p_business_group_id  => p_business_group_id,
                           p_effective_date     => p_effective_date,
                           p_copy_entity_txn_id => l_cet_id);
         hr_utility.set_location('cet row created '||l_cet_id,10);
         load_matrix(p_rate_matrix_id     => p_rate_matrix_id,
                     p_copy_entity_txn_id => l_cet_id,
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_status_flag        => l_status_flag );
         if l_status_flag = 0 then
            hr_utility.set_location('matrix copied ',10);
            p_matrix_loaded := 'YES';
            p_copy_entity_txn_id := l_cet_id;
         else
            hr_utility.set_location('matrix copy error ',10);
            p_matrix_loaded := 'ERR';
         end if;
      else
         p_copy_entity_txn_id := l_cet_id;
         p_matrix_loaded := 'NO';
      end if;
  elsif p_mode ='OVERRIDE' then
      hr_utility.set_location('override matrix in stage',100);
      hr_utility.set_location('checking matx presence in staging',10);
      chk_matrix_presence(p_rate_matrix_id     => p_rate_matrix_id,
                          p_business_group_id  => p_business_group_id,
                          p_copy_entity_txn_id => l_cet_id);
      if l_cet_id is null then
         hr_utility.set_location('matx doesnot exist',10);
         create_matrix_txn(p_mode               => 'UPDATE',
                           p_business_group_id  => p_business_group_id,
                           p_effective_date     => p_effective_date,
                           p_copy_entity_txn_id => l_cet_id);
         hr_utility.set_location('new cet row created '||l_cet_id,10);
      else
         delete_matrix(p_copy_entity_txn_id => l_cet_id);
         hr_utility.set_location('cer rows for cet deleted',100);
      end if;
      load_matrix(p_rate_matrix_id     => p_rate_matrix_id,
                  p_copy_entity_txn_id => l_cet_id,
                  p_business_group_id  => p_business_group_id,
                  p_effective_date     => p_effective_date,
                  p_status_flag        => l_status_flag );
      if l_status_flag = 0 then
         hr_utility.set_location('matrix copied ',10);
         p_matrix_loaded := 'YES';
         p_copy_entity_txn_id := l_cet_id;
      else
         hr_utility.set_location('matrix copy error ',10);
         p_matrix_loaded := 'ERR';
      end if;
  else
      hr_utility.set_location('wrong mode passed',100);
  end if;
end upd_matrix;
procedure cre_matrix(p_business_group_id  in number,
                     p_effective_date     in date,
                     p_copy_entity_txn_id     out nocopy number) is
   l_cet_id number;
   l_cer_id number;
   l_cer_ovn number;
begin
   hr_utility.set_location('creating cet row',10);
   create_matrix_txn(p_mode               => 'CREATE',
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_copy_entity_txn_id => l_cet_id);
   if l_cet_id is not null then
         hr_utility.set_location('populate out params',10);
         p_copy_entity_txn_id := l_cet_id;
   else
      hr_utility.set_location('cet row is not there',10);
   end if;
end cre_matrix;
end pqh_rbc_stage;

/
