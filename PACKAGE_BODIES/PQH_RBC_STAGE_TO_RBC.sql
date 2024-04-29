--------------------------------------------------------
--  DDL for Package Body PQH_RBC_STAGE_TO_RBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_STAGE_TO_RBC" as
/* $Header: pqrbcsrb.pkb 120.4 2006/02/20 16:06 srajakum noship $ */

g_package  Varchar2(30) := 'pqh_rbc_stage_to_rbc';
g_pln_short_code Varchar2(1000) := null;

function get_parent_rmn(p_copy_entity_txn_id in number,
                        p_copy_entity_result_id in number)
                        return number
                        is

l_parent_id number;
Begin
     hr_utility.set_location('Into get_parent_rmn',210);

     hr_utility.set_location('Into get_parent_rmn copy_entity_txn_id'||p_copy_entity_txn_id,210);
     hr_utility.set_location('Into get_parent_rmn copy_entity_result_id'||p_copy_entity_result_id,210);

   select information1
   into l_parent_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and copy_entity_result_id = p_copy_entity_result_id
   and table_alias = 'RMN';

        hr_utility.set_location('Into get_parent_rmn parent_id'||l_parent_id,210);

hr_utility.set_location('leaving get_parent_rmn',1);
 return l_parent_id;

exception
when no_data_found then
   hr_utility.set_location('Into get_parent_rmn exception',210);
   return null;

End get_parent_rmn;

Function chk_acty_base_rate_exist (
                                    p_pl_id in number,
                                    p_effective_date in date,
                                    p_business_group_id in number,
                                    P_MAPPING_TABLE_PK_ID in number
                                   ) return varchar2 is
cursor base_rt_cur is
Select *
from ben_acty_base_rt_f
where pl_id = p_pl_id
and  business_group_id = p_business_group_id
and  mapping_table_pk_id = p_mapping_table_pk_id
and p_effective_date between effective_start_date and effective_end_date;

l_status varchar2(1) := 'N';
l_base_rt_rec base_rt_cur%rowtype;
Begin
  open base_rt_cur;
  loop
  fetch base_rt_cur into l_base_rt_rec;
  exit when base_rt_cur%notfound;
  if base_rt_cur%found then
     l_status := 'Y';
  end if;
  end loop;
  return l_status;
End chk_acty_base_rate_exist;


procedure get_elig_det_for_rmn (p_business_group_id   in number,
                                p_rmn_id              in number,
                                p_elig_prfl_id        out nocopy number,
                                p_criteria_short_code out nocopy varchar2)
is
Begin
hr_utility.set_location('Entering get_elig_det_for_rmn',1);

select CRITERIA_SHORT_CODE, ELIGY_PRFL_ID
into p_criteria_short_code, p_elig_prfl_id
from pqh_rate_matrix_nodes
where rate_matrix_node_id = p_rmn_id
and business_group_id = p_business_group_id;

hr_utility.set_location('leaving get_elig_det_for_rmn',1);
End get_elig_det_for_rmn;

procedure rmn_writeback(p_copy_entity_result_id in number,
                    p_rmn_id in number,
                    p_copy_entity_txn_id in number) is

Begin
     hr_utility.set_location('inside rmn_writeback ',210);

     hr_utility.set_location('writing back on ben_copy_entity results ',210);
     hr_utility.set_location('writing back parent_id '||p_rmn_id,210);

     update ben_copy_entity_results
     set information1 = p_rmn_id
     where COPY_ENTITY_RESULT_ID = p_copy_entity_result_id
     and  copy_entity_txn_id = p_copy_entity_txn_id;

    update ben_copy_entity_results
    set  information161 = p_rmn_id
    where GS_PARENT_ENTITY_RESULT_ID = p_copy_entity_result_id
    and   copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias in ('RMV');

    update ben_copy_entity_results
    set  information161 = p_rmn_id
    where PARENT_ENTITY_RESULT_ID = p_copy_entity_result_id
    and   copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias in ('RMR');

        hr_utility.set_location('leaving rmn_writeback ',210);
End rmn_writeback;


function get_pl_typ_name return varchar2 is
   l_proc varchar2(72) := g_package||'get_pl_typ_name';
   l_name varchar2(80) ;
begin
        hr_utility.set_location(' Inside  '||l_proc,210);

   select meaning into l_name
     from hr_lookups
    where lookup_type = 'PQH_GSP_LE_PT_NAME'
      and lookup_code = 'RBC_PT';

        hr_utility.set_location(' Leaving  '||l_proc,210);
   return l_name ;
exception
   when others then
      hr_utility.set_location('issue in lookup ',10);
      raise;
end get_pl_typ_name;

function get_short_code (p_table_alias in varchar2)return varchar2 is

l_sql varchar2(2000);
l_code varchar2(1000);
l_seq varchar2(1000);
l_seq_no number;

begin
        hr_utility.set_location(' Inside  get_short_code ',210);

 if p_table_alias = 'RMN' then
    l_seq := 'PQH_RATE_MATRIX_NODES_S.NEXTVAL';
 elsif p_table_alias = 'RMV' then
    l_seq := 'PQH_RT_MATRIX_NODE_VALUES_S.NEXTVAL';
 elsif p_table_alias = 'RMR' then
     l_seq := 'PQH_RATE_MATRIX_RATES_S.NEXTVAL';
 end if;

l_code := g_pln_short_code;

l_sql := 'select '||l_seq||' from dual';

hr_utility.set_location('l_sql is '||substr(l_sql,1,50),20);
hr_utility.set_location('l_sql is '||substr(l_sql,51,50),20);
hr_utility.set_location('l_sql is '||substr(l_sql,101,50),20);

  EXECUTE IMMEDIATE l_sql
         INTO l_seq_no;

l_code := l_code||to_char(l_seq_no);

hr_utility.set_location('For '||p_table_alias||' short_code  is '||l_code,210);

hr_utility.set_location(' Leaving  get_short_code ',210);

return l_code;

exception
  when no_data_found then
   raise;

end get_short_code;

function create_plan_type (p_business_group_id  in number
                          ,p_copy_entity_txn_id in number
                          ,p_name               in varchar2)
return number is
   l_proc varchar2(72) := g_package||'create_plan_type';
   l_start_of_time DATE:= to_date('01-01-1951','DD-MM-YYYY');
   l_pl_typ_id                 number;
   l_effective_start_date      date;
   l_effective_end_date        date;
   l_object_version_number     number;
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);

   ben_plan_type_api.create_plan_type(
       p_pl_typ_id              => l_pl_typ_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_start_of_time
      ,p_name                   => p_name
      ,p_business_group_id      => p_business_group_id
      ,p_opt_typ_cd             => 'RBC'
      ,p_pl_typ_stat_cd         => 'A'
      ,p_no_mx_enrl_num_dfnd_flag => 'N'
      ,p_no_mn_enrl_num_dfnd_flag => 'N'
   );

   hr_utility.set_location('Leaving:'|| l_proc, 10);

   return l_pl_typ_id;
end create_plan_type;
--
function get_rbc_plntyp_str_date (p_business_group_id  in number
                                 ,p_copy_entity_txn_id  in number default  null
)
return date is
   l_proc varchar2(72) := g_package||'get_rbc_plntyp_str_date';
   l_plan_type_date DATE := null;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
   select min(effective_start_date)
     into l_plan_type_date
     from ben_pl_typ_f
    where business_group_id = p_business_group_id
      and opt_typ_cd ='RBC'
      and pl_typ_stat_cd ='A';
   hr_utility.set_location('Plan Type date is :'|| l_plan_type_date, 20);
   return l_plan_type_date ;
exception
   when others then
      hr_utility.set_location('Problem in determining Plan Type date ',40);
      raise;
end get_rbc_plntyp_str_date ;
--
procedure setup_check(p_copy_entity_txn_id      in number
                     ,p_effective_date          in date
                     ,p_business_group_id       in number
                     ,p_status                 out nocopy varchar2
                      ) is
   l_status  varchar2(30) ;
   l_ler_id number;
   l_ler_name varchar2(240);
   l_pt_id number;
   l_pt_name varchar2(240);
   l_start_of_time DATE:= get_rbc_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_effective_start_date date ;
   l_pl_typ_name varchar2(80) ;

begin

     hr_utility.set_location('Entering: setup_check', 10);
   if l_status is null then
      begin
         select pl_typ_id,name,effective_start_date
           into l_pt_id,l_pt_name,l_effective_start_date
           from ben_pl_typ_f
          where trunc(effective_end_date) = hr_general.end_of_time
            and business_group_id = p_business_group_id
            and opt_typ_cd ='RBC';

         hr_utility.set_location('pl_typ name '||substr(l_pt_name,1,40),10);

      if l_effective_start_date <> l_start_of_time then
         l_status := 'WRONG-DATE-PT' ;
      end if ;

      exception
         when no_data_found then
            hr_utility.set_location('No PT of RBC ',20);
            l_pl_typ_name := get_pl_typ_name();
            l_pt_id := create_plan_type (p_business_group_id,p_copy_entity_txn_id,l_pl_typ_name);
         when too_many_rows then
            hr_utility.set_location('many PT of RBC ',20);
            l_status := 'MANY-PT';
         when others then
            hr_utility.set_location('issue in Getting RBC PT ',20);
            l_status := 'PT-ERR';
      end;
   end if;

   if l_status is null then
      hr_utility.set_location('setup is fine, update staging area',10);
--      p_plan_tp_created_flag  := l_plan_tp_created_flag;
      p_status := 'Y';
   else
      p_status := l_status;
      hr_utility.set_location('control goes back with status'||l_status,10);
   end if;

       hr_utility.set_location('Leaving: setup_check', 10);

end setup_check;



procedure Delete_RMR(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_Date_Track_Mode    in Varchar2) is

cursor del_rmr is
select *
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and   table_alias = 'RMR'
and dml_operation = 'DELETE';

l_ovn number;
l_effective_start_date date;
l_effective_end_date date;
Begin

     hr_utility.set_location('Entering: Delete_RMR', 10);

  for del_rec in del_rmr loop
    l_ovn := del_rec.Information265;

   PQH_RATE_MATRIX_RATES_API.delete_rate_matrix_rate
                       (p_rate_matrix_rate_ID	  => del_rec.Information1
                       ,p_effective_start_date    => l_effective_start_date
                       ,p_effective_end_date      => l_effective_end_date
                       ,p_object_version_number   => l_ovn
                       ,p_effective_date          => p_effective_date
                       ,p_datetrack_mode          => p_Date_Track_Mode);

  end loop;

 hr_utility.set_location('Leaving: Delete_RMR', 10);
End Delete_RMR;

procedure Delete_RMV(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number) is

cursor del_rmv is
select *
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and   table_alias = 'RMV'
and dml_operation = 'DELETE';
Begin

 hr_utility.set_location('Entering: Delete_RMV', 10);

  for del_rec in del_rmv loop
   PQH_RT_MATRIX_NODE_VALUES_API.delete_rt_matrix_node_value
                              (p_effective_date  => p_effective_date
                              ,p_NODE_VALUE_ID	 =>  Del_rec.information1
                              ,p_object_version_number => del_rec.information265
                                 );

  /* pqh_rbc_elpro.delete_criteria
                 (

                 )*/

  end loop;

   hr_utility.set_location('Leaving: Delete_RMV', 10);
End Delete_RMV;

procedure Delete_RMN(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number) is

cursor del_rmn is
select *
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and   table_alias = 'RMN'
and dml_operation = 'DELETE';

Begin

 hr_utility.set_location('Entering: Delete_RMN', 10);
  for del_rec in del_rmn loop

   PQH_RATE_MATRIX_NODES_API.delete_rate_matrix_node
                          (p_effective_date        => p_effective_date
                          ,p_rate_matrix_node_id   => del_rec.information1
                          ,p_object_version_number => del_rec.information265
                          );


  end loop;

 hr_utility.set_location('Entering: Delete_RMN', 10);

End Delete_RMN;

procedure Delete_plan(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_Date_Track_Mode in varchar2) is

cursor del_plan is
select *
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and   table_alias = 'PLN'
and dml_operation = 'DELETE';

l_ovn number;
l_effective_start_date date;
l_effective_end_date date;

Begin
   hr_utility.set_location('inside delete_plan',1);
  for del_rec in del_plan loop
   l_ovn := del_rec.information265;

   ben_Plan_api.delete_Plan
                (p_pl_id                     => del_rec.information1
                ,p_effective_start_date      => l_effective_start_date
                ,p_effective_end_date        => l_effective_end_date
                ,p_object_version_number     => l_ovn
                ,p_effective_date            => p_effective_date
                ,p_datetrack_mode            => p_Date_Track_Mode
                 );


  end loop;
  hr_utility.set_location('leaving delete_plan',1);
End Delete_plan;


procedure pre_push_data(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_Date_Track_Mode    in Varchar2,
                        p_status out nocopy varchar2) is

   l_return varchar2(30) := 'YES';
   l_effective_date date;
   l_Del_Dt_Mode Varchar2(30);
   l_status varchar2(30);

begin
   hr_utility.set_location('inside pre-push',1);

   If P_Date_Track_Mode = 'UPDATE_OVERRIDE' Then
      l_Del_Dt_Mode := 'DELETE';
   Else
      l_Del_Dt_Mode := 'ZAP';
   End If;

   Delete_RMR(p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date  => p_effective_date,
              p_business_group_id => p_business_group_id,
              p_Date_Track_Mode => 'ZAP');

   Delete_RMV(p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date => p_effective_date,
              p_business_group_id => p_business_group_id);

   Delete_RMN(p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date => p_effective_date,
              p_business_group_id => p_business_group_id);


   Delete_plan(p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date => p_effective_date,
              p_business_group_id => p_business_group_id,
              p_Date_Track_Mode => l_Del_Dt_Mode);

   setup_check(p_copy_entity_txn_id   => p_copy_entity_txn_id,
               p_effective_date       => p_effective_date,
               p_business_group_id    => p_business_group_id,
               p_status               => l_status);

   if l_status <> 'Y' then
     if l_status = 'WRONG-DATE-PT' then
        hr_utility.set_message(8302,'PQH_RBC_WRONG_ST_DT_PT');
        hr_multi_message.add;
    elsif l_status = 'MANY-PT' then
        hr_utility.set_message(8302,'PQH_RBC_MANY_PT');
        hr_multi_message.add;
    end if;
     l_return := 'NO';
   end if;

   p_status := l_return;
   hr_utility.set_location('leaving pre-push',100);

exception
     when others then
     l_return := 'NO';
     p_status := l_return;
    raise;
end pre_push_data;


Procedure stage_to_rmn_values(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_rmn_id in number )
                         is
l_proc varchar2(61) :='stage_to_rmn_values';
l_rmv_id number;
l_seq number;
l_db_ovn number;
l_ovn number;
l_object varchar2(80);
l_message_text varchar2(2000);
l_short_code varchar2(1000);
l_number_value1 number;
l_number_value2 number;
l_criteria_short_code varchar2(80);
l_elig_prfl_id  number;
cursor csr_rmv is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'RMV'
      and dml_operation in ('CREATE','UPDATE')
      and information161 = p_rmn_id;
begin

   hr_utility.set_location('inside'||l_proc,10);

   for rmv_rec in csr_rmv loop
      l_ovn := rmv_rec.Information265;
      l_rmv_id := rmv_rec.Information1;
       if rmv_rec.dml_operation = 'CREATE' then
         hr_utility.set_location('new node value is being created'||l_proc,20);
         l_short_code := rmv_rec.INFORMATION12;
             hr_utility.set_location('Short_code is '||l_short_code,20);
  /*  Short code genration for the rows witout short code */

            if l_short_code is null then
             hr_utility.set_location('Short_code is null',20);
                          l_short_code := get_short_code('RMV');
             hr_utility.set_location('Short_code generated'||l_short_code,20);
            end if;
 /*

    Assigning number values depending upon the criteria selected.
    if organization hierarchy id (information223 ) is not null then
        number_value1 = information223
        number_value2 = information224
    if  position hierarchy id (information225 ) is not null then
        number_value1 = information225
        number_value2 = information226
    else
       number_value1 = information169
       number_value2 = information174

*/
         if rmv_rec.information223 is not null then
               l_number_value1 := rmv_rec.information223;
               l_number_value2 := rmv_rec.information224;
         elsif rmv_rec.information225 is not null then
               l_number_value1 := rmv_rec.information225;
               l_number_value2 := rmv_rec.information226;
         else
               l_number_value1 := rmv_rec.information169;
               l_number_value2 := rmv_rec.information174;
         end if;

         begin
            hr_utility.set_location('Node value id'||l_rmv_id,20);
            PQH_RT_MATRIX_NODE_VALUES_API.create_rt_matrix_node_value
                                    (p_effective_date => p_effective_date
                                    ,p_NODE_VALUE_ID  => l_rmv_id
                                    ,p_RATE_MATRIX_NODE_ID  => rmv_rec.INFORMATION161
                                    ,p_SHORT_CODE           => l_short_code
                                    ,p_CHAR_VALUE1          => rmv_rec.INFORMATION13
                                    ,p_CHAR_VALUE2          => rmv_rec.INFORMATION14
                                    ,p_CHAR_VALUE3          => rmv_rec.INFORMATION15
                                    ,p_CHAR_VALUE4          => rmv_rec.INFORMATION16
                                    ,p_NUMBER_VALUE1        => l_number_value1
                                    ,p_NUMBER_VALUE2        => l_number_value2
                                    ,p_NUMBER_VALUE3        => rmv_rec.INFORMATION221
                                    ,p_NUMBER_VALUE4        => rmv_rec.INFORMATION222
                                    ,p_DATE_VALUE1          => rmv_rec.INFORMATION166
                                    ,p_DATE_VALUE2          => rmv_rec.INFORMATION167
                                    ,p_DATE_VALUE3          => rmv_rec.INFORMATION306
                                    ,p_DATE_VALUE4          => rmv_rec.INFORMATION307
                                    ,p_BUSINESS_GROUP_ID    => rmv_rec.INFORMATION4
                                    ,p_object_version_number => l_ovn
                                    );
             get_elig_det_for_rmn (p_business_group_id   => rmv_rec.INFORMATION4,
                                   p_rmn_id              => rmv_rec.INFORMATION161,
                                   p_elig_prfl_id        => l_elig_prfl_id,
                                   p_criteria_short_code => l_criteria_short_code);

             PQH_RBC_ELPRO.create_criteria
                          (p_criteria_code     => l_criteria_short_code
                          ,p_char_value1       => rmv_rec.INFORMATION13
                          ,p_CHAR_VALUE2          => rmv_rec.INFORMATION14
                          ,p_CHAR_VALUE3          => rmv_rec.INFORMATION15
                          ,p_CHAR_VALUE4          => rmv_rec.INFORMATION16
                          ,p_NUMBER_VALUE1        => l_number_value1
                          ,p_NUMBER_VALUE2        => l_number_value2
                          ,p_NUMBER_VALUE3        => rmv_rec.INFORMATION221
                          ,p_NUMBER_VALUE4        => rmv_rec.INFORMATION222
                          ,p_DATE_VALUE1          => rmv_rec.INFORMATION166
                          ,p_DATE_VALUE2          => rmv_rec.INFORMATION167
                          ,p_DATE_VALUE3          => rmv_rec.INFORMATION306
                          ,p_DATE_VALUE4          => rmv_rec.INFORMATION307
                          ,p_BUSINESS_GROUP_ID    => rmv_rec.INFORMATION4
                          ,p_effective_date       => p_effective_date
                          ,p_elig_prfl_id         => l_elig_prfl_id
                           );

            hr_utility.set_location('rmv id'||l_rmv_id,20);
         exception
            when others then
               hr_utility.set_location('issues in creating rmv'||rmv_rec.information5,30);
               raise;
         end;
         hr_utility.set_location('rmv id is '||l_rmv_id,30);
      elsif rmv_rec.dml_operation in ('UPDATE')
      and l_ovn is not null
      and l_rmv_id is not null then
         hr_utility.set_location('Rate Node Value is being updated'||l_rmv_id,60);
--         hr_utility.set_location('plan ovn'||grd_rec.information222,60);

         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PQH_RT_MATRIX_NODE_VALUES',
                               p_key_column_name    => 'NODE_VALUE_ID',
                               p_key_column_value   => l_rmv_id);

         hr_utility.set_location(' ovn is '||l_db_ovn,30);

         if l_db_ovn <> l_ovn then

              hr_utility.set_location('Invalid ovn no ', 20);
           else
            begin
            PQH_RT_MATRIX_NODE_VALUES_API.update_rt_matrix_node_value
                                   (p_effective_date => p_effective_date
                                    ,p_NODE_VALUE_ID  => l_rmv_id
                                    ,p_RATE_MATRIX_NODE_ID  => rmv_rec.INFORMATION161
                                    ,p_SHORT_CODE           => rmv_rec.INFORMATION12
                                    ,p_CHAR_VALUE1          => rmv_rec.INFORMATION13
                                    ,p_CHAR_VALUE2          => rmv_rec.INFORMATION14
                                    ,p_CHAR_VALUE3          => rmv_rec.INFORMATION15
                                    ,p_CHAR_VALUE4          => rmv_rec.INFORMATION16
                                    ,p_NUMBER_VALUE1        => l_number_value2
                                    ,p_NUMBER_VALUE2        => l_number_value2
                                    ,p_NUMBER_VALUE3        => rmv_rec.INFORMATION221
                                    ,p_NUMBER_VALUE4        => rmv_rec.INFORMATION222
                                    ,p_DATE_VALUE1          => rmv_rec.INFORMATION166
                                    ,p_DATE_VALUE2          => rmv_rec.INFORMATION167
                                    ,p_DATE_VALUE3          => rmv_rec.INFORMATION306
                                    ,p_DATE_VALUE4          => rmv_rec.INFORMATION307
                                    ,p_BUSINESS_GROUP_ID    => rmv_rec.INFORMATION4
                                    ,p_object_version_number => l_ovn );
            exception
               when others then
                  hr_utility.set_location('issues in updating Node lalues'||l_rmv_id,70);
                  hr_utility.set_location('rmv ovn'||l_ovn,75);
                  hr_utility.set_location('rmv name'||substr(rmv_rec.information5,1,45),78);
                  raise;
            end;
         end if;
      else
         l_message_text := 'invalid operation '||rmv_rec.dml_operation
         ||' rmv_id'||l_rmv_id
         ||' rmv_ovn'||l_ovn
         ||' rmv_name'||rmv_rec.information5;


      end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
    raise;

end stage_to_rmn_values;

procedure get_plan_det_for_rmn(p_rmn_id in number,
                               p_business_group_id in number,
                               p_effective_date in date,
                               p_pl_id out nocopy ben_pl_f.pl_id%type,
                               p_pl_name out nocopy ben_pl_f.name%type)
is
begin
   hr_utility.set_location('Entering get_plan_name_for_rmn ',100);

    select pl.pl_id pl_id, pl.name pl_name
    into p_pl_id, p_pl_name
    from ben_pl_f pl,
         pqh_rate_matrix_nodes rmn
    where rmn.pl_id = pl.pl_id
    and p_effective_date between pl.effective_start_date and pl.effective_end_date
    and rmn.rate_matrix_node_id = p_rmn_id
    and rmn.business_group_id = p_business_group_id
    and pl.business_group_id = p_business_group_id
    and rmn.business_group_id = pl.business_group_id;


   hr_utility.set_location('leaving get_plan_name_for_rmn',100);

exception
   when others then
    hr_utility.set_location('Issues in getting plan details',100);
    raise;
End get_plan_det_for_rmn;

Function get_crit_rate_def_name (p_crd_id in number,
                                 p_business_group_id in number)
                                 return varchar2
is
l_crd_name varchar2(1000);
Begin
   hr_utility.set_location('Entering get_crit_rate_def_name',100);

 select name crd_name
 into l_crd_name
 from pqh_criteria_rate_defn_vl
 where CRITERIA_RATE_DEFN_ID = p_crd_id
 and    business_group_id = p_business_group_id;

  hr_utility.set_location('leaving get_crit_rate_def_name',100);

  return l_crd_name;

End get_crit_rate_def_name;


function get_rmn_short_code(p_rmn_id in number,
                            p_business_group_id in number)
                            return varchar2 is
l_rmn_short_code varchar2(1000);
Begin
  hr_utility.set_location('Entering get_rmn_short_code',100);

Select short_code
into  l_rmn_short_code
from  pqh_rate_matrix_nodes
where  rate_matrix_node_id = p_rmn_id
and     business_group_id = p_business_group_id;

hr_utility.set_location('leaving get_rmn_short_code',100);
return l_rmn_short_code;


End get_rmn_short_code;

Procedure stage_to_rmr(p_copy_entity_txn_id in number,
                   p_effective_date     in date,
                   p_business_group_id  in number,
                   p_datetrack_mode     in varchar2,
                   p_rmn_id in number)
                   is

l_proc varchar2(61) :='stage_to_rmr';
l_rmr_id number;
l_seq number;
l_db_ovn number;
l_ovn number;
l_object varchar2(80);
l_effective_start_date date;
l_effective_end_date date;
l_message_text varchar2(2000);
l_dt_mode varchar2(1000);
l_effective_date date;
l_esd date;
l_esd_abr date;
l_eed_abr date;
l_abr_id number;
l_pl_name ben_pl_f.name%type;
l_pl_id ben_pl_f.pl_id%type;
l_crd_name pqh_criteria_rate_defn_vl.name%type;
l_ovn_abr number;
l_short_code_rmn varchar2(1000);
l_base_rt_exist varchar2(1);

cursor csr_rmr is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'RMR'
      and dml_operation in ('CREATE','UPDATE')
      and  information161 = p_rmn_id;

begin
   hr_utility.set_location('inside'||l_proc,10);
   for rmr_rec in csr_rmr loop
      l_ovn := rmr_rec.Information265;
      l_rmr_id := rmr_rec.Information1;
       if rmr_rec.dml_operation = 'CREATE' then
         hr_utility.set_location('new plan is being created'||l_proc,20);
         begin
            hr_utility.set_location('rmr id'||l_rmr_id,20);

            select min(effective_start_date)
            into l_esd
            from ben_pl_f pl, pqh_rate_matrix_nodes rmn
            where  rmn.pl_id = pl.pl_id
            and    rmn.rate_matrix_node_id = p_rmn_id;

            if l_esd < p_effective_date then
                l_effective_date := l_esd;
            else
                l_effective_date := p_effective_date;
            end if;

              PQH_RATE_MATRIX_RATES_API.create_rate_matrix_rate
                                 (p_effective_date               => l_effective_date
                                 ,p_rate_matrix_rate_id          => l_rmr_id
                                 ,p_EFFECTIVE_START_DATE         => l_effective_start_date
                                 ,p_EFFECTIVE_END_DATE           => l_effective_end_date
                                 ,p_RATE_MATRIX_NODE_ID          => p_rmn_id
                                 ,p_CRITERIA_RATE_DEFN_ID        => rmr_rec.Information162
                                 ,p_MIN_RATE_VALUE               => nvl(rmr_rec.Information294,0)
                                 ,p_MAX_RATE_VALUE               => nvl(rmr_rec.Information295,0)
                                 ,p_MID_RATE_VALUE               => nvl(rmr_rec.Information296,0)
                                 ,p_RATE_VALUE                   => nvl(rmr_rec.Information297,0)
                                 ,p_BUSINESS_GROUP_ID            => rmr_rec.Information4
                                 ,p_object_version_number        => l_ovn
                                 );
               hr_utility.set_location('rmr id'||l_rmr_id,20);

               get_plan_det_for_rmn(p_rmn_id            => p_rmn_id,
                                    p_business_group_id => rmr_rec.Information4,
                                    p_effective_date    => l_effective_date,
                                    p_pl_id             => l_pl_id,
                                    p_pl_name           => l_pl_name);

               hr_utility.set_location('Plan id and name are '||l_pl_id||'  '||l_pl_name,20);

               l_crd_name := get_crit_rate_def_name (p_crd_id            => rmr_rec.Information162,
                                                     p_business_group_id => rmr_rec.Information4);


               hr_utility.set_location('Criteria rate definition name is '||l_crd_name,20);

               l_short_code_rmn := get_rmn_short_code(p_rmn_id            => p_rmn_id,
                                                      p_business_group_id => rmr_rec.Information4);


               hr_utility.set_location('Rate Matrix Node short code is '||l_short_code_rmn,20);

               l_base_rt_exist := chk_acty_base_rate_exist(
                                                           p_pl_id => l_pl_id,
                                                           p_effective_date => l_effective_date,
                                                           p_business_group_id => p_business_group_id ,
                                                           P_MAPPING_TABLE_PK_ID => rmr_rec.Information162
                                                           );
               if l_base_rt_exist = 'N' then
               BEN_ACTY_BASE_RATE_API.CREATE_ACTY_BASE_RATE
                                (P_EFFECTIVE_DATE                => l_effective_date
                                ,p_acty_base_rt_id               => l_abr_id
                                ,p_effective_start_date          => l_esd_abr
                                ,p_effective_end_date            => l_eed_abr
                                ,P_BUSINESS_GROUP_ID             => rmr_rec.Information4
                                ,P_ACTY_BASE_RT_STAT_CD          => 'A'
                                ,P_ACTY_TYP_CD                   => 'RBC'
                                ,P_NAME                          => l_pl_name||'-'||l_short_code_rmn||'-'||l_crd_name
                                ,P_PL_ID                         => l_pl_id
                                ,P_RT_MLT_CD                     => 'NSVU'
                                ,P_ELE_RQD_FLAG                  => 'N'
                                ,P_MAPPING_TABLE_NAME            => 'PQH_CRITERIA_RATE_DEFN'
                                ,P_MAPPING_TABLE_PK_ID           => rmr_rec.Information162
                                ,p_object_version_number         => l_ovn_abr
                                );
                  hr_utility.set_location('Base rate id and name is '||l_abr_id||' '||l_pl_name||' - '||l_crd_name,20);
               else
                   hr_utility.set_location('Base rate already exist',20);
               end if;

         exception
            when others then
               hr_utility.set_location('issues in creating Rate_matrix node'||l_rmr_id,30);
               raise;
         end;
         hr_utility.set_location('rmr id is '||l_rmr_id,30);
      elsif rmr_rec.dml_operation in ('UPDATE')
      and l_ovn is not null
      and l_rmr_id is not null then
         hr_utility.set_location('Rate Matrix node is being updated'||l_rmr_id,60);
         hr_utility.set_location('Rate Matrix rate dt mode '||p_datetrack_mode,60);
         if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode(p_table_name  => 'PQH_RATE_MATRIX_RATES_F',
                                           p_key_column_name => 'RATE_MATRIX_RATE_ID',
                                           p_key_column_value => l_rmr_id,
                                           p_effective_date => p_effective_date);
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
--         hr_utility.set_location('plan ovn'||grd_rec.information222,60);
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PQH_RATE_MATRIX_RATES_F',
                               p_key_column_name    => 'RATE_MATRIX_RATE_ID',
                               p_key_column_value   => l_rmr_id,
                               p_effective_date     => p_effective_date);
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_ovn then
              hr_utility.set_location('object verson not same ', 20);
           else
            begin
            PQH_RATE_MATRIX_RATES_API.update_rate_matrix_rate
                                    (p_effective_date                => p_effective_date
                                    ,p_datetrack_mode                => l_dt_mode
                                    ,p_RATE_MATRIX_RATE_ID           => l_rmr_id
                                    ,p_EFFECTIVE_START_DATE          => l_effective_start_date
                                    ,p_EFFECTIVE_END_DATE            => l_effective_end_date
                                    ,p_RATE_MATRIX_NODE_ID          => rmr_rec.Information161
                                    ,p_CRITERIA_RATE_DEFN_ID        => rmr_rec.Information162
                                    ,p_MIN_RATE_VALUE               => rmr_rec.Information294
                                    ,p_MAX_RATE_VALUE               => rmr_rec.Information295
                                    ,p_MID_RATE_VALUE               => rmr_rec.Information296
                                    ,p_RATE_VALUE                   => nvl(rmr_rec.Information297,0)
                                    ,p_BUSINESS_GROUP_ID            => rmr_rec.Information4
                                    ,p_object_version_number        => l_ovn);
            exception
               when others then
                  hr_utility.set_location('issues in updating rate matrix rate'||l_rmr_id,70);
                  hr_utility.set_location('rmr ovn'||l_ovn,75);
                  raise;
            end;
         end if;
      else
         l_message_text := 'invalid operation '||rmr_rec.dml_operation
         ||' rmr_id'||l_rmr_id
         ||' rmr_ovn'||l_ovn;
     end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      raise;
End stage_to_rmr;



procedure rbc_data_push(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_datetrack_mode     in varchar2,
                        p_status out nocopy varchar2 ) is
   l_datetrack_mode varchar2(30);
   l_continue varchar2(30) := 'Y';
   l_status varchar2(30) := 'YES';
begin

--  hr_utility.trace_on(NULL,'SJRBC');

   hr_utility.set_location('inside rbc_data_push',10);
   if p_datetrack_mode = 'OVERWRITE' then
      l_datetrack_mode := 'CORRECTION';
   elsif p_datetrack_mode = 'DATETRACK' then
      l_datetrack_mode := 'UPDATE_OVERRIDE';
   else
      hr_utility.set_location('invalid dt mode passed'||p_datetrack_mode,10);
      l_continue := 'N';
   end if;
   if l_continue = 'Y' then
   begin

        pre_push_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_effective_date     => p_effective_date,
                       p_business_group_id  => p_business_group_id,
         		       P_Date_Track_Mode    => l_datetrack_mode,
                       p_status => l_status );


        if l_status = 'YES' then
            hr_utility.set_location('pre push done ',20);
            rbc_stage_to_hr(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_date     => p_effective_date,
                         p_business_group_id  => p_business_group_id,
                         p_datetrack_mode     => l_datetrack_mode,
                         p_status => l_status);
        end if;

        if l_status = 'YES' then
            hr_utility.set_location('data pushed to hr ',20);

          begin

          update pqh_copy_entity_txns
           set status ='COMPLETED'
           where copy_entity_txn_id = p_copy_entity_txn_id;

	    -- Purging the Copy Entity Txn record as it is no longer required --

      	  Delete from Ben_Copy_Entity_Results
  	      where Copy_Entity_Txn_Id = p_copy_entity_txn_id;
         -- and table_alias in ('PLN','RMN','RMV','RMR','RBR',');


            hr_utility.set_location('txn stat chg to comp',40);
           exception
            when others then
               hr_utility.set_location('issues in updating cet row ',10);
               l_status := 'NO';
               raise;
         end;

        end if;

      exception
         when others then
            hr_utility.set_location('issues in writing data ',10);
            l_status := 'NO';
            raise;
      end;
   end if;

   p_status := l_status ;


  hr_utility.set_location('Leaving: rbc_data_push', 10);
--  hr_utility.trace_off;
end rbc_data_push;

function get_pl_typ_id (p_effective_date in date,
                        p_business_group_id in number)
                        return number
                        is
l_pl_typ_id number;
begin

  hr_utility.set_location('Entering: get_pl_typ_id', 10);

 select PL_TYP_ID
 into l_pl_typ_id
 from ben_pl_typ_f
 where p_effective_date between effective_start_date and effective_end_date
 and business_group_id = p_business_group_id
 and opt_typ_cd = 'RBC';

  hr_utility.set_location('Leaving: get_pl_typ_id', 10);

  return l_pl_typ_id;
exception
  when too_many_rows then
     hr_utility.set_location('more than onr rows returned', 20);
  when others then
     hr_utility.set_location('Problem in getting pl_typ_id ', 20);

End get_pl_typ_id;



Procedure stage_to_plan(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_datetrack_mode     in varchar2) is
l_proc varchar2(61) :='stage_to_plan';
l_plan_id number;
l_seq number;
l_db_ovn number;
l_ovn number;
l_object varchar2(80);
l_effective_start_date date;
l_effective_end_date date;
l_message_text varchar2(2000);
l_pl_typ_id number;
l_dt_mode varchar2(1000);
cursor csr_plan is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'PLN'
      and dml_operation in ('CREATE','UPDATE');
begin
   hr_utility.set_location('inside'||l_proc,10);
   for plan_rec in csr_plan loop
      l_ovn := plan_rec.Information265;
      l_plan_id := plan_rec.Information1;
       if plan_rec.dml_operation = 'CREATE' then
         hr_utility.set_location('new plan is being created'||l_proc,20);
         begin
            hr_utility.set_location('plan name'||substr(plan_rec.information170,1,45),20);
            hr_utility.set_location('plan id'||l_plan_id,20);
            l_pl_typ_id := get_pl_typ_id(p_effective_date,plan_rec.Information4);
            hr_utility.set_location('plan typ id'||l_pl_typ_id,20);
            ben_plan_api.create_Plan(
                                    p_pl_id  => l_plan_id
                                   ,p_effective_start_date => l_effective_start_date
                                   ,p_effective_end_date   => l_effective_end_date
                                   ,p_name                 => plan_rec.Information170
                                   ,p_pl_stat_cd           => plan_rec.Information19
                                   ,p_object_version_number => l_ovn
                                   ,p_effective_date        => p_effective_date
                                   ,p_short_name			=> plan_rec.Information94
                                   ,p_short_code			=> plan_rec.Information93
                                   ,p_business_group_id     => plan_rec.Information4
                                   ,p_pl_cd                 => 'MYNTBPGM'
                                   ,p_pl_typ_id             => l_pl_typ_id
                                   ,p_vrfy_fmly_mmbr_cd     =>  null
                                    );
            hr_utility.set_location('paln id'||l_plan_id,20);

         exception
            when others then
               hr_utility.set_location('issues in creating plan'||plan_rec.information170,30);
               raise;
         end;
         hr_utility.set_location('plan id is '||l_plan_id,30);
      elsif plan_rec.dml_operation in ('UPDATE')
      and l_ovn is not null
      and l_plan_id is not null then
         hr_utility.set_location('Plan is being updated'||l_plan_id,60);
--         hr_utility.set_location('plan ovn'||grd_rec.information222,60);
        if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode(p_table_name  => 'BEN_PL_F',
                                           p_key_column_name => 'PL_ID',
                                           p_key_column_value => l_plan_id,
                                           p_effective_date => p_effective_date);
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'BEN_PL_F',
                               p_key_column_name    => 'PL_ID',
                               p_key_column_value   => l_plan_id,
                               p_effective_date     => p_effective_date);
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','PLN');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',plan_rec.information170);
              fnd_message.raise_error;
           else
            begin
            BEN_PLAN_API.update_Plan(
                                   p_pl_id                 => l_plan_id
                                  ,p_effective_start_date  => l_effective_start_date
                                  ,p_effective_end_date    => l_effective_end_date
                                  ,p_name                  => plan_rec.information170
                                  ,p_pl_stat_cd            => plan_rec.Information19
                                  ,p_business_group_id     => plan_rec.Information4
                                  ,p_object_version_number => l_ovn
                                  ,p_effective_date        => p_effective_date
                                  ,p_datetrack_mode        => l_dt_mode
                                  ,p_short_name            => plan_rec.Information94
                                  ,p_short_code            => plan_rec.Information93
                                  ,p_vrfy_fmly_mmbr_cd     =>  null);
            exception
               when others then
                  hr_utility.set_location('issues in updating plan'||l_plan_id,70);
                  hr_utility.set_location('paln ovn'||l_ovn,75);
                  hr_utility.set_location('plan name'||substr(plan_rec.information170,1,45),78);
                  raise;
            end;
         end if;
      else
         l_message_text := 'invalid operation '||plan_rec.dml_operation
         ||' plan_id'||l_plan_id
         ||' plan_ovn'||l_ovn
         ||' plan_name'||plan_rec.information170;

      end if;

    -- writeback(plan_rec.copy_entity_result_id,l_plan_id,p_copy_entity_txn_id);
      g_pln_short_code := plan_rec.Information93;

      stage_to_rmn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date     => p_effective_date,
                p_business_group_id  => p_business_group_id,
                p_plan_id => l_plan_id,
                p_datetrack_mode => p_datetrack_mode);

     g_pln_short_code := null;
     hr_utility.set_location('Rate_matrix_node row updated',40);

   end loop;

   hr_utility.set_location('leaving '||l_proc,100);

exception
   when others then
      raise;
end stage_to_plan;

Procedure stage_to_rmn(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_plan_id   in number,
                         p_datetrack_mode in varchar2
                         ) is
l_proc varchar2(61) :='stage_to_rmn';
l_rmn_id number;
l_seq number;
l_db_ovn number;
l_ovn number;
l_object varchar2(80);
l_message_text varchar2(2000);
l_short_code varchar2(1000);
l_parent_rmn_id number;
l_elp_id number;
cursor csr_rmn is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'RMN'
      and dml_operation in ('CREATE','UPDATE')
      order by information160;
begin
   hr_utility.set_location('inside'||l_proc,10);
   for rmn_rec in csr_rmn loop
      l_ovn := rmn_rec.Information265;
      l_rmn_id := rmn_rec.Information1;

      l_parent_rmn_id := get_parent_rmn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                        p_copy_entity_result_id => rmn_rec.GS_PARENT_ENTITY_RESULT_ID);

       if rmn_rec.dml_operation = 'CREATE' then
         hr_utility.set_location('new Rate matrix node is being created'||l_proc,20);
         begin
            hr_utility.set_location('Rate Matrix Node name'||substr(rmn_rec.information219,1,45),20);
            l_short_code := rmn_rec.INFORMATION12;
             hr_utility.set_location('Short_code is '||l_short_code,20);
            if l_short_code is null then
             hr_utility.set_location('Short_code is null',20);
                          l_short_code := get_short_code('RMN');
             hr_utility.set_location('Short_code generated'||l_short_code,20);
              end if;
            hr_utility.set_location('RMN id'||l_rmn_id,20);

           -- Creating Eligibilty profile for each node
            if rmn_rec.Information160 > 1 then
            pqh_rbc_elpro.create_elpro(p_name              => l_short_code,
                                       p_description       => rmn_rec.Information219,
                                       p_business_group_id => rmn_rec.Information4,
                                       p_effective_date    => p_effective_date,
                                       p_elig_prfl_id      => l_elp_id);
            else
              l_elp_id := null;
             end if;

            PQH_RATE_MATRIX_NODES_API.create_rate_matrix_node
                                (p_effective_date => p_effective_date
                                ,p_rate_matrix_node_id   => l_rmn_id
                                ,p_short_code => l_short_code
                                ,p_pl_id => p_plan_id
                                ,p_level_number => rmn_rec.Information160
                                ,p_criteria_short_code => rmn_rec.INFORMATION13
                                ,p_node_name => rmn_rec.Information219
                                ,p_parent_node_id => l_parent_rmn_id
                                ,p_eligy_prfl_id => l_elp_id
                                ,p_business_group_id => rmn_rec.Information4
                                ,p_object_version_number  => l_ovn
                                );
            hr_utility.set_location('rmn id'||l_rmn_id,20);
         exception
            when others then
               hr_utility.set_location('issues in creating rmn'||rmn_rec.information219,30);
               raise;
         end;
         hr_utility.set_location('rmn id is '||l_rmn_id,30);
      elsif rmn_rec.dml_operation in ('UPDATE')
      and l_ovn is not null
      and l_rmn_id is not null then
         hr_utility.set_location('Rate Matrix Node is being updated'||l_rmn_id,60);
         l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PQH_RATE_MATRIX_NODES',
                               p_key_column_name    => 'RATE_MATRIX_NODE_ID',
                               p_key_column_value   => l_rmn_id
                               );
         hr_utility.set_location(' ovn is '||l_db_ovn,30);
         if l_db_ovn <> l_ovn then
              fnd_message.set_name('PQH','PQH_RBC_OBJ_OVN_INVALID');
              fnd_message.raise_error;
           else
            begin
            PQH_RATE_MATRIX_NODES_API.update_rate_matrix_node
                                    (p_effective_date => p_effective_date
                                    ,p_rate_matrix_node_id => l_rmn_id
                                    ,p_short_code => rmn_rec.INFORMATION12
                                    ,p_pl_id => p_plan_id
                                    ,p_level_number => rmn_rec.Information160
                                    ,p_criteria_short_code => rmn_rec.INFORMATION13
                                    ,p_node_name => rmn_rec.Information219
                                    ,p_parent_node_id => l_parent_rmn_id
                                    ,p_eligy_prfl_id => rmn_rec.Information169
                                    ,p_business_group_id => rmn_rec.Information4
                                    ,p_object_version_number  => l_ovn
                                    );
            exception
               when others then
                  hr_utility.set_location('issues in updating Rate Matrix node'||l_rmn_id,70);
                  hr_utility.set_location('rmn ovn'||l_ovn,75);
                  hr_utility.set_location('rate Matix Node name'||substr(rmn_rec.information170,1,45),78);
                  raise;
            end;
         end if;
      else
         l_message_text := 'invalid operation '||rmn_rec.dml_operation
         ||' rmn_id'||l_rmn_id
         ||' rmn_ovn'||l_ovn
         ||' rmn_name'||rmn_rec.information170;

      end if;

       hr_utility.set_location('IN RMN COPY ENTITY RESULT ID '||to_char(rmn_rec.copy_entity_result_id),201);
       hr_utility.set_location('IN RMN rmn id is'||to_char(l_rmn_id),202);
       hr_utility.set_location('IN RMN copy entity txn id '||p_copy_entity_txn_id,203);

      rmn_writeback(p_copy_entity_result_id => rmn_rec.copy_entity_result_id,
                    p_rmn_id => l_rmn_id,
                    p_copy_entity_txn_id => p_copy_entity_txn_id);

      stage_to_rmn_values(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_business_group_id  => p_business_group_id,
                         p_effective_date     => p_effective_date,
                         p_rmn_id => l_rmn_id );

      stage_to_rmr(p_copy_entity_txn_id => p_copy_entity_txn_id,
                   p_effective_date     => p_effective_date,
                   p_business_group_id  => p_business_group_id,
                   p_datetrack_mode     => p_datetrack_mode,
                   p_rmn_id => l_rmn_id );

   hr_utility.set_location('Rate_matrix_rates row updated',40);
   hr_utility.set_location('Rate_matrix_node_values created if any reqd',41);

   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      raise;
end stage_to_rmn;

procedure rbc_stage_to_hr(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_datetrack_mode     in varchar2,
                          p_status             out nocopy varchar2
                          ) is

-- this procedure will be the callable routine
-- in this procedure we will traverse the hierarchy and find out what all is
-- hr data
-- for any plan created/updated stage_to_plan
-- for any option created/ updated stage_to_Rate_matrix_node
-- for any oipl created/ updated stage_to_Rate_matrix_node_value
-- for any standard rate created/ updated stage_to_Rate_matrix_rates
/* the data should be written in this order
1) Plan
2) Rate_matrix_node
3) Rate_matrix_node_values
4) Rate_matrix_Rates
*/
   l_proc varchar2(61) := 'rbc_stage_to_hr' ;
   l_effective_date date := p_effective_date;
   l_return  varchar2(3) := 'YES';
begin
   hr_utility.set_location('inside '||l_proc,10);
   hr_utility.set_location('cet is '||p_copy_entity_txn_id,1);
   hr_utility.set_location('bg is '||p_business_group_id,2);
   hr_utility.set_location('dt mode is '||p_datetrack_mode,4);

   stage_to_plan(p_copy_entity_txn_id  => p_copy_entity_txn_id,
                  p_effective_date     => l_effective_date,
                  p_business_group_id  => p_business_group_id,
                  p_datetrack_mode     => p_datetrack_mode);

   hr_utility.set_location('plan row checked for update',30);



   p_status := l_return ;
      hr_utility.set_location('Leaving '||l_proc,10);
exception
   when others then
      hr_utility.set_location('error encountered',420);
      p_status := 'NO';
      raise;
end rbc_stage_to_hr;

end pqh_rbc_stage_to_rbc;

/
