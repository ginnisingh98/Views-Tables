--------------------------------------------------------
--  DDL for Package Body PQH_RBC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_UTILITY" AS
/* $Header: pqrbcutl.pkb 120.35.12010000.2 2009/12/29 07:07:44 kgowripe ship $ */

function future_criteria_exist(p_copy_entity_txn_id in number) return varchar2 is
 l_rate_matrix_id number(30);

  cursor c11(p_rate_matrix_id in number) is select distinct criteria_short_code
                    from pqh_rate_matrix_nodes a, ben_eligy_prfl_f b
                    where pl_id = p_rate_matrix_id
                    and criteria_short_code is not null
                    and a.eligy_prfl_id = b.eligy_prfl_id;


  cursor c21 is select distinct information13 from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'RBC_CRIT'; -- also consider 'DELETE' status rows

 l_short_code varchar2(100);
 l_temp varchar2(100);
 l_status varchar2(10);
 l_temp_found varchar2(10);
begin
 l_status := 'NO';
 l_temp_found := 'NO';

        select information1 into l_rate_matrix_id from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'PLN';

        open c11(l_rate_matrix_id);
        loop
        fetch c11 into l_short_code;
        EXIT WHEN c11%NOTFOUND;
        l_temp_found := 'NO';
        -- check if a short code in base table is present in ben_copy
        open c21;
        loop
            fetch c21 into l_temp;
            EXIT WHEN c21%NOTFOUND;
            if l_short_code = l_temp then
            l_temp_found := 'YES';
            exit;
            end if;
        end loop;
        close c21;

        if l_temp_found  = 'NO' then
        l_status := 'YES';
        exit;
        end if;

    end loop;
    close c11;

return l_status;

end future_criteria_exist;

FUNCTION allow_criteria_delete(p_eligy_criteria_id NUMBER) RETURN varchar2 IS
   l_eligy_prfl_id number;
   l_criteria_type varchar(100);
   l_status varchar2(20);
   cursor c1 is select eligy_prfl_id from ben_eligy_crit_values_f
                where eligy_criteria_id = p_eligy_criteria_id;

BEGIN
    open c1;
    fetch c1 into l_eligy_prfl_id;
    if c1%notfound then
       l_status := 'DeleteEnabled';
    else
       l_status := 'DeleteDisabled';
    end if;
    close c1;
return l_status;
END allow_criteria_delete;

--
--
procedure delete_matrix_values(p_copy_entity_txn_id in number,
                            p_rate_matrix_node_id   in number,
                            p_mode      in varchar2
                            ) is
begin
   hr_utility.set_location('going for deleting matrix values row',100);
/*
   if p_mode = 'CREATE' then
   delete from ben_copy_entity_results where INFORMATION161 = p_rate_matrix_node_id and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMV';
   else
   update ben_copy_entity_results set dml_operation = 'DELETE' where INFORMATION161 = p_rate_matrix_node_id  and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMV';
   end if;
*/ -- dont use this because each row has its characteristics to revert back independent of pmode

   delete from ben_copy_entity_results where INFORMATION161 = p_rate_matrix_node_id and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMV' and dml_operation = 'CREATE';
   update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode = 'DELETE' where INFORMATION161 = p_rate_matrix_node_id  and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMV' and dml_operation in ('UPDATE','COPIED');

exception
   when others then
      hr_utility.set_location('issues in deleting matrix values row',100);
      raise;
end delete_matrix_values;

procedure delete_matrix_rates(p_copy_entity_txn_id in number,
                            p_rate_matrix_node_id   in number,
                            p_mode      in varchar2
                            ) is
begin
   hr_utility.set_location('going for deleting matrix rates row',100);
/*
   if p_mode = 'CREATE' then
   delete from ben_copy_entity_results where INFORMATION161 = p_rate_matrix_node_id and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMR';
   else
   update ben_copy_entity_results set dml_operation = 'DELETE' where INFORMATION161 = p_rate_matrix_node_id  and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMR';
   end if;
*/
   delete from ben_copy_entity_results where INFORMATION161 = p_rate_matrix_node_id and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMR' and dml_operation = 'CREATE';
   update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode = 'DELETE' where INFORMATION161 = p_rate_matrix_node_id  and copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMR' and dml_operation in ('UPDATE','COPIED');


exception
   when others then
      hr_utility.set_location('issues in deleting matrix rates row',100);
      raise;
end delete_matrix_rates;



procedure delete_matrix_nodes(p_copy_entity_txn_id in number,
                            p_pl_id     in number,
                            p_level     in number,
                            p_short_code in varchar2,
                            p_mode      in varchar2

                            ) is
  l_rate_matrix_node_id number;

   -- p_mode in UPDATE or CREATE
  cursor c1 is  select information1 from ben_copy_entity_results where
        Copy_entity_txn_id = p_copy_entity_txn_id and
        Information160 =  p_level and
        information13 = p_short_code and
        Information261 = p_pl_id and
        TABLE_ALIAS = 'RMN';
begin
   hr_utility.set_location('going for deleting matrix nodes row',100);

    -- USE THIS IF YOU ARE NOT CALLING VOROW.REMOVE IN AM
        delete from ben_copy_entity_results where
        Copy_entity_txn_id = p_copy_entity_txn_id and
        Information160 =  p_level and
        information13 = p_short_code and
        Information261 = p_pl_id and
        TABLE_ALIAS = 'RBC_CRIT' and
        dml_operation = 'CREATE';

        update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode = 'DELETE' where
        Copy_entity_txn_id = p_copy_entity_txn_id and
        Information160 =  p_level and
        information13 = p_short_code and
        Information261 = p_pl_id and
        TABLE_ALIAS = 'RBC_CRIT' and
        dml_operation in ('UPDATE','COPIED');

    hr_utility.set_location('deleting hgrid criteria rows',110);

    open c1;
    fetch c1 into l_rate_matrix_node_id;
    if c1%notfound then
       RETURN;
    else
        --delete all child rows of current rmn row
        delete_matrix_values(p_copy_entity_txn_id,l_rate_matrix_node_id,p_mode);
        delete_matrix_rates(p_copy_entity_txn_id,l_rate_matrix_node_id,p_mode);
    end if;
    close c1;

        --DELETE RMN CURRENT ROW AFTER DELETING CHILD
        delete from ben_copy_entity_results where
        Copy_entity_txn_id = p_copy_entity_txn_id and
        Information160 =  p_level and
        information13 = p_short_code and
        Information261 = p_pl_id and
        TABLE_ALIAS = 'RMN' and
        dml_operation = 'CREATE';

        update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode = 'DELETE' where
        Copy_entity_txn_id = p_copy_entity_txn_id and
        Information160 =  p_level and
        information13 = p_short_code and
        Information261 = p_pl_id and
        TABLE_ALIAS = 'RMN' and
        dml_operation in ('UPDATE','COPIED');

exception
   when others then
      hr_utility.set_location('issues in deleting matrix nodes row',100);
      raise;
end delete_matrix_nodes;




/*
	 To check if there are criteria values present in rate matrix, check if there are any rows in ben_copy_entity_results with table_alias = 'RMN' and dml_operation <> 'DELETE' for the current copy_entity_txn_id.
	 To check if there are criteria attached to rate matrix, check if there are any rows in ben_copy_entity_results with table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE' for the current copy_entity_txn_id.
*/


function allow_hgrid_reorder(p_copy_entity_txn_id in number) return varchar2 IS
    l_temp  varchar2(1);
    l_max number;

    cursor c1 is select null from ben_copy_entity_results where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RMN' and dml_operation <> 'DELETE' and information160 <> 1;
    cursor c2 is select null from ben_copy_entity_results where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE';
BEGIN

/*  INSTEAD OF C2 WE CAN USE THIS
    select max(nvl(information160,1)) into l_max from ben_copy_entity_results where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE';
    if l_max = 1 then
       return 'DisallowOrder';
    end if;
*/

   if future_criteria_exist(p_copy_entity_txn_id) = 'YES' then
      return 'DisallowOrder';
   end if;


    open c2;
    fetch c2 into l_temp;
    if c2%notfound then
       close c2;
       return 'DisallowOrder';
    end if;
    fetch c2 into l_temp;
    if c2%notfound then
       close c2;
       return 'DisallowOrder';
    end if;
    close c2;

    open c1;
    fetch c1 into l_temp;
    if c1%notfound then
       close c1;
       return 'AllowOrder';
    else
       close c1;
       return 'DisallowOrder';
    end if;
    close c1;

END allow_hgrid_reorder;

FUNCTION get_matrix_disable_date(p_pl_id in number,p_effective_date in date) RETURN Date IS
l_effective_start_date Date;
   cursor c1 is
        select effective_start_date from ben_pl_f
                where pl_id = p_pl_id
                and  pl_stat_cd = 'I'
                and  effective_start_date > p_effective_date
                order by effective_start_date;
BEGIN
    open c1;
    fetch c1 into l_effective_start_date;
    if c1%notfound then
       RETURN null;
    else
       RETURN l_effective_start_date;
    end if;
    close c1;
END get_matrix_disable_date;


procedure create_criteria_txn(p_mode              in varchar2,
                              p_business_area     in varchar2,
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
      where short_name ='CRITERIA'
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
        ,p_context                        => 'CRITERIA'
        ,p_action_date                    => p_effective_date
        ,p_number_of_copies               => 1
        ,p_display_name                   => p_mode||' - CRITERIA - '||to_char(sysdate,'ddmmyyyyhhmiss')
        ,p_replacement_type_cd            => 'NONE'
        ,p_start_with                     => p_business_area
        ,p_status                         => p_mode
        ,p_object_version_number          => l_ovn
        ,p_effective_date                 => p_effective_date
        ) ;
    end if;
exception
   when others then
      hr_utility.set_location('issues in creating CET row',100);
      raise;
end create_criteria_txn;
/*
procedure create_criteria_cer (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_business_group_id  in number,
                               p_crit_cer_id           out nocopy number,
                               p_crit_cer_ovn          out nocopy number) is
   l_egl_tr_id number;
   l_egl_tr_name varchar2(80);
begin
   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'EGL',
    p_table_route_id => l_egl_tr_id,
    p_table_name     => l_egl_tr_name);

   ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => p_effective_date
      ,p_copy_entity_txn_id         => p_copy_entity_txn_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => l_egl_tr_name
      ,p_table_route_id             => l_egl_tr_id
      ,p_table_alias                => 'EGL'
      ,p_dml_operation              => 'CREATE'
      ,p_information2               => p_effective_date
      ,p_information4               => p_business_group_id
      ,p_information12              => 'USER'
      ,p_copy_entity_result_id      => p_crit_cer_id
      ,p_object_version_number      => p_crit_cer_ovn);
end create_criteria_cer;
*/

procedure check_criteria_in_busgrp(p_eligy_criteria_id_std  in number,p_business_group_id in number,p_eligy_criteria_id_new out nocopy number) is
l_short_code varchar2(240);
l_eligy_criteria_id_new number;
cursor c1 is select short_code from ben_eligy_criteria
             where eligy_criteria_id = p_eligy_criteria_id_std
             and business_group_id is null;

cursor c2(p_short_code varchar2) is
 select eligy_criteria_id from ben_eligy_criteria
             where short_code  = p_short_code
             and business_group_id = p_business_group_id;

begin

    open c1;
    fetch c1 into l_short_code;
    if c1%notfound then
       p_eligy_criteria_id_new := p_eligy_criteria_id_std;
    else
           open c2(l_short_code);
           fetch c2 into l_eligy_criteria_id_new;
           if c2%notfound then
               p_eligy_criteria_id_new := p_eligy_criteria_id_std;
            else
               p_eligy_criteria_id_new :=l_eligy_criteria_id_new;
            end if;

            close c2;


    end if;
    close c1;

end check_criteria_in_busgrp;

-- copy every thing similar to copy_egl_row but keep our business_group_id,'CREATE" dml operation
procedure copy_criteria_std (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_business_group_id  in number,
                               p_eligy_criteria_id  in number,
                               p_copy_entity_result_id  out nocopy number,
                               p_copy_entity_result_ovn out nocopy number) is

l_flex_value_set_name varchar2(80);
cursor c1 is select * from ben_eligy_criteria
             where eligy_criteria_id = p_eligy_criteria_id;

   l_egl_tr_id number;
   l_egl_tr_name varchar2(80);
   l_egl_cer_id number;
   l_egl_ovn number;
   l_ben_eligy_criteria number;
begin
  -- get new ben_eligy_criteria sequence --NOT NEEDED BCOZ WE USE API TO CREATE

  select BEN_ELIGY_CRITERIA_S.NEXTVAL into l_ben_eligy_criteria from dual;

   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'EGL',
    p_table_route_id => l_egl_tr_id,
    p_table_name     => l_egl_tr_name);
    hr_utility.set_location('table route is'||l_egl_tr_name,10);


      for l_egl_rec in c1 loop
       if l_egl_rec.col1_value_set_id is not null then
          SELECT flex_value_set_name
          into l_flex_value_set_name
          FROM fnd_flex_value_sets
          WHERE flex_value_set_id = l_egl_rec.col1_value_set_id;
          hr_utility.set_location('value set name  is'||l_flex_value_set_name,10);
       else
          hr_utility.set_location('value set is not used',10);
       end if;

       -- copy every thing similar to copy_egl_row but keep our business_group_id instead

       ben_copy_entity_results_api.create_copy_entity_results (
          p_copy_entity_result_id            => l_egl_cer_id,
          p_copy_entity_txn_id               => p_copy_entity_txn_id,
          p_result_type_cd                   => 'DISPLAY',
          p_number_of_copies                 => 1,
          p_table_route_id                   => l_egl_tr_id,
          p_table_alias                      => 'EGL',
          p_dml_operation                    => 'CREATE',
          p_information1                     => l_ben_eligy_criteria, -- get from sequence number
          p_information4                     => p_business_group_id, --  add our business group
          p_information5                     => l_egl_rec.name,
          p_information11                    => l_egl_rec.short_code,
          p_information12                    => l_egl_rec.criteria_type,
          p_information13                    => l_egl_rec.crit_col1_val_type_cd,
          p_information14                    => l_egl_rec.crit_col1_datatype,
          p_information15                    => l_egl_rec.col1_lookup_type,
          p_information16                    => l_egl_rec.access_table_name1,
          p_information17                    => l_egl_rec.access_column_name1,
          p_information18                    => l_egl_rec.time_entry_access_table_name1,
          p_information19                    => l_egl_rec.time_entry_access_col_name1,
          p_information20                    => l_egl_rec.crit_col2_val_type_cd,
          p_information21                    => l_egl_rec.crit_col2_datatype,
          p_information22                    => l_egl_rec.col2_lookup_type,
          p_information23                    => l_egl_rec.access_table_name2,
          p_information24                    => l_egl_rec.access_column_name2,
          p_information25                    => l_egl_rec.time_entry_access_table_name2,
          p_information26                    => l_egl_rec.time_entry_access_col_name2,
          p_information27                    => l_egl_rec.allow_range_validation_flag,
          p_information28                    => l_egl_rec.user_defined_flag,
          p_information29                    => l_egl_rec.legislation_code,
          p_information110                   => l_egl_rec.egl_attribute_category,
          p_information111                   => l_egl_rec.egl_attribute1,
          p_information112                   => l_egl_rec.egl_attribute2,
          p_information113                   => l_egl_rec.egl_attribute3,
          p_information114                   => l_egl_rec.egl_attribute4,
          p_information115                   => l_egl_rec.egl_attribute5,
          p_information116                   => l_egl_rec.egl_attribute6,
          p_information117                   => l_egl_rec.egl_attribute7,
          p_information118                   => l_egl_rec.egl_attribute8,
          p_information119                   => l_egl_rec.egl_attribute9,
          p_information120                   => l_egl_rec.egl_attribute10,
          p_information121                   => l_egl_rec.egl_attribute11,
          p_information122                   => l_egl_rec.egl_attribute12,
          p_information123                   => l_egl_rec.egl_attribute13,
          p_information124                   => l_egl_rec.egl_attribute14,
          p_information125                   => l_egl_rec.egl_attribute15,
          p_information126                   => l_egl_rec.egl_attribute16,
          p_information127                   => l_egl_rec.egl_attribute17,
          p_information128                   => l_egl_rec.egl_attribute18,
          p_information129                   => l_egl_rec.egl_attribute19,
          p_information130                   => l_egl_rec.egl_attribute20,
          p_information131                   => l_egl_rec.egl_attribute21,
          p_information132                   => l_egl_rec.egl_attribute22,
          p_information133                   => l_egl_rec.egl_attribute23,
          p_information134                   => l_egl_rec.egl_attribute24,
          p_information135                   => l_egl_rec.egl_attribute25,
          p_information136                   => l_egl_rec.egl_attribute26,
          p_information137                   => l_egl_rec.egl_attribute27,
          p_information138                   => l_egl_rec.egl_attribute28,
          p_information139                   => l_egl_rec.egl_attribute29,
          p_information140                   => l_egl_rec.egl_attribute30,
          p_information170                   => l_egl_rec.name,
          p_information185                   => l_flex_value_set_name,
          p_information219                   => l_egl_rec.description,
          p_information265                   => l_egl_rec.object_version_number,
          p_information266                   => l_egl_rec.col1_value_set_id,
          p_information267                   => l_egl_rec.col2_value_set_id,
          p_information268                   => l_egl_rec.access_calc_rule,
          p_information30                    => l_egl_rec.allow_range_validation_flag2,
          p_information269                   => l_egl_rec.access_calc_rule2,
          p_information270                   => l_egl_rec.time_access_calc_rule1,
          p_information271                   => l_egl_rec.time_access_calc_rule2,
          p_object_version_number            => l_egl_ovn,
          p_effective_date                   => p_effective_date);
   end loop;
   p_copy_entity_result_id := l_egl_cer_id;
   p_copy_entity_result_ovn := l_egl_ovn;
end copy_criteria_std;
--
procedure copy_egl_row(p_eligy_criteria_id      in number,
                       p_copy_entity_txn_id     in number,
                       p_effective_date         in date,
                       p_copy_entity_result_id  out nocopy number,
                       p_copy_entity_result_ovn out nocopy number) is

l_flex_value_set_name varchar2(80);
cursor c1 is select * from ben_eligy_criteria
             where eligy_criteria_id = p_eligy_criteria_id;

   l_egl_tr_id number;
   l_egl_tr_name varchar2(80);
   l_egl_cer_id number;
   l_egl_ovn number;
begin
   pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'EGL',
    p_table_route_id => l_egl_tr_id,
    p_table_name     => l_egl_tr_name);
    hr_utility.set_location('table route is'||l_egl_tr_name,10);
   for l_egl_rec in c1 loop
       if l_egl_rec.col1_value_set_id is not null then
          SELECT flex_value_set_name
          into l_flex_value_set_name
          FROM fnd_flex_value_sets
          WHERE flex_value_set_id = l_egl_rec.col1_value_set_id;
          hr_utility.set_location('value set name  is'||l_flex_value_set_name,10);
       else
          hr_utility.set_location('value set is not used',10);
       end if;
       ben_copy_entity_results_api.create_copy_entity_results (
          p_copy_entity_result_id            => l_egl_cer_id,
          p_copy_entity_txn_id               => p_copy_entity_txn_id,
          p_result_type_cd                   => 'DISPLAY',
          p_number_of_copies                 => 1,
          p_table_route_id                   => l_egl_tr_id,
          p_table_alias                      => 'EGL',
          p_dml_operation                    => 'UPDATE',
          p_information1                     => l_egl_rec.eligy_Criteria_id,
          p_information4                     => l_egl_rec.business_group_id,
          p_information5                     => l_egl_rec.name,
          p_information11                    => l_egl_rec.short_code,
          p_information12                    => l_egl_rec.criteria_type,
          p_information13                    => l_egl_rec.crit_col1_val_type_cd,
          p_information14                    => l_egl_rec.crit_col1_datatype,
          p_information15                    => l_egl_rec.col1_lookup_type,
          p_information16                    => l_egl_rec.access_table_name1,
          p_information17                    => l_egl_rec.access_column_name1,
          p_information18                    => l_egl_rec.time_entry_access_table_name1,
          p_information19                    => l_egl_rec.time_entry_access_col_name1,
          p_information20                    => l_egl_rec.crit_col2_val_type_cd,
          p_information21                    => l_egl_rec.crit_col2_datatype,
          p_information22                    => l_egl_rec.col2_lookup_type,
          p_information23                    => l_egl_rec.access_table_name2,
          p_information24                    => l_egl_rec.access_column_name2,
          p_information25                    => l_egl_rec.time_entry_access_table_name2,
          p_information26                    => l_egl_rec.time_entry_access_col_name2,
          p_information27                    => l_egl_rec.allow_range_validation_flag,
          p_information28                    => l_egl_rec.user_defined_flag,
          p_information29                    => l_egl_rec.legislation_code,
          p_information110                   => l_egl_rec.egl_attribute_category,
          p_information111                   => l_egl_rec.egl_attribute1,
          p_information112                   => l_egl_rec.egl_attribute2,
          p_information113                   => l_egl_rec.egl_attribute3,
          p_information114                   => l_egl_rec.egl_attribute4,
          p_information115                   => l_egl_rec.egl_attribute5,
          p_information116                   => l_egl_rec.egl_attribute6,
          p_information117                   => l_egl_rec.egl_attribute7,
          p_information118                   => l_egl_rec.egl_attribute8,
          p_information119                   => l_egl_rec.egl_attribute9,
          p_information120                   => l_egl_rec.egl_attribute10,
          p_information121                   => l_egl_rec.egl_attribute11,
          p_information122                   => l_egl_rec.egl_attribute12,
          p_information123                   => l_egl_rec.egl_attribute13,
          p_information124                   => l_egl_rec.egl_attribute14,
          p_information125                   => l_egl_rec.egl_attribute15,
          p_information126                   => l_egl_rec.egl_attribute16,
          p_information127                   => l_egl_rec.egl_attribute17,
          p_information128                   => l_egl_rec.egl_attribute18,
          p_information129                   => l_egl_rec.egl_attribute19,
          p_information130                   => l_egl_rec.egl_attribute20,
          p_information131                   => l_egl_rec.egl_attribute21,
          p_information132                   => l_egl_rec.egl_attribute22,
          p_information133                   => l_egl_rec.egl_attribute23,
          p_information134                   => l_egl_rec.egl_attribute24,
          p_information135                   => l_egl_rec.egl_attribute25,
          p_information136                   => l_egl_rec.egl_attribute26,
          p_information137                   => l_egl_rec.egl_attribute27,
          p_information138                   => l_egl_rec.egl_attribute28,
          p_information139                   => l_egl_rec.egl_attribute29,
          p_information140                   => l_egl_rec.egl_attribute30,
          p_information170                   => l_egl_rec.name,
          p_information185                   => l_flex_value_set_name,
          p_information219                   => l_egl_rec.description,
          p_information265                   => l_egl_rec.object_version_number,
          p_information266                   => l_egl_rec.col1_value_set_id,
          p_information267                   => l_egl_rec.col2_value_set_id,
          p_information268                   => l_egl_rec.access_calc_rule,
          p_information30                    => l_egl_rec.allow_range_validation_flag2,
          p_information269                   => l_egl_rec.access_calc_rule2,
          p_information270                   => l_egl_rec.time_access_calc_rule1,
          p_information271                   => l_egl_rec.time_access_calc_rule2,
          p_object_version_number            => l_egl_ovn,
          p_effective_date                   => p_effective_date);
   end loop;
   p_copy_entity_result_id := l_egl_cer_id;
   p_copy_entity_result_ovn := l_egl_ovn;
end copy_egl_row;
--
/**
procedure load_criteria_seed_row(
                         p_owner                        in varchar2
                        ,p_short_code                   in varchar2
                        ,p_name                         in varchar2
                        ,p_description                  in varchar2
                        ,p_crit_col1_val_type_cd        in varchar2
                        ,p_crit_col1_datatype           in varchar2
                        ,p_col1_lookup_type             in varchar2
                        ,p_col1_value_set_name          in varchar2
                        ,p_access_table_name1           in varchar2
                        ,p_access_column_name1          in varchar2
                        ,p_crit_col2_val_type_cd        in varchar2
                        ,p_crit_col2_datatype           in varchar2
                        ,p_col2_lookup_type             in varchar2
                        ,p_col2_value_set_name          in varchar2
                        ,p_access_table_name2           in varchar2
                        ,p_access_column_name2          in varchar2
                        ,p_allow_range_validation_flag  in varchar2
                        ,p_allow_range_validation_flag2 in varchar2
                        ,p_user_defined_flag            in varchar2
                        ,p_business_group_id            in varchar2
                        ,p_legislation_code             in varchar2
                        ) is

   l_ovn                     number := 1;
   l_created_by              ben_eligy_criteria.created_by%type;
   l_last_updated_by         ben_eligy_criteria.last_updated_by%type;
   l_creation_date           ben_eligy_criteria.creation_date%type;
   l_last_update_date        ben_eligy_criteria.last_update_date%type;
   l_last_update_login       ben_eligy_criteria.last_update_login%type;

   l_col1_value_set_id       ben_eligy_criteria.col1_value_set_id%type;
   l_col2_value_set_id       ben_eligy_criteria.col2_value_set_id%type;

   l_eligy_criteria_id       ben_eligy_criteria.eligy_criteria_id%type;


  cursor csr_fvs(p_valset_name in varchar2) is
  select flex_value_set_id
    from fnd_flex_value_sets
   where flex_value_set_name = p_valset_name;
  --
  cursor csr_bec is
  select eligy_criteria_id
    from ben_eligy_criteria
   where short_code = p_short_code and business_group_id is null and criteria_type='STD';
  --
  cursor csr_bg_bec is
  select eligy_criteria_id
    from ben_eligy_criteria
   where short_code = p_short_code and business_group_id is not null and criteria_type='STD';
  --
l_data_migrator_mode varchar2(10);
--
 begin
  --
   l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
   --
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by := fnd_load_util.owner_id(p_owner);
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  open csr_bec;
  fetch csr_bec into l_eligy_criteria_id;
  close csr_bec;
  --
  open csr_fvs(p_col1_value_set_name);
  fetch csr_fvs into l_col1_value_set_id;
  close csr_fvs;
  --
  open csr_fvs(p_col2_value_set_name);
  fetch csr_fvs into l_col2_value_set_id;
  close csr_fvs;

  if l_eligy_criteria_id is not null then
   --
   update ben_eligy_criteria set
   name = p_name,
   description = p_description,
   crit_col1_val_type_cd = p_crit_col1_val_type_cd,
   crit_col1_datatype = p_crit_col1_datatype,
   col1_lookup_type = p_col1_lookup_type,
   col1_value_set_id = l_col1_value_set_id,
   access_table_name1 = p_access_table_name1 ,
   access_column_name1 = p_access_column_name1,
   crit_col2_val_type_cd = p_crit_col2_val_type_cd,
   crit_col2_datatype = p_crit_col2_datatype,
   col2_lookup_type = p_col2_lookup_type,
   col2_value_set_id = l_col2_value_set_id,
   access_table_name2 = p_access_table_name2,
   access_column_name2 = p_access_column_name2,
   allow_range_validation_flag = p_allow_range_validation_flag,
   allow_range_validation_flag2 = p_allow_range_validation_flag2,
   user_defined_flag = p_user_defined_flag,
   business_group_id = to_number(p_business_group_id),
   legislation_code = p_legislation_code,
   criteria_type = 'STD',
   last_updated_by        = l_last_updated_by,
   last_update_date       = l_last_update_date,
   last_update_login      = l_last_update_login
   where eligy_criteria_id = l_eligy_criteria_id;
   --
   -- Update any BG specific rows that were created.
   --
   For bg_crit_rec in csr_bg_bec loop
   --
   update ben_eligy_criteria set
   name = p_name,
   description = p_description,
   crit_col1_val_type_cd = p_crit_col1_val_type_cd,
   crit_col1_datatype = p_crit_col1_datatype,
   col1_lookup_type = p_col1_lookup_type,
   col1_value_set_id = l_col1_value_set_id,
   access_table_name1 = p_access_table_name1 ,
   access_column_name1 = p_access_column_name1,
   crit_col2_val_type_cd = p_crit_col2_val_type_cd,
   crit_col2_datatype = p_crit_col2_datatype,
   col2_lookup_type = p_col2_lookup_type,
   col2_value_set_id = l_col2_value_set_id,
   access_table_name2 = p_access_table_name2,
   access_column_name2 = p_access_column_name2,
   allow_range_validation_flag = p_allow_range_validation_flag,
   allow_range_validation_flag2 = p_allow_range_validation_flag2,
   user_defined_flag = p_user_defined_flag,
   legislation_code = p_legislation_code,
   criteria_type = 'STD',
   last_updated_by        = l_last_updated_by,
   last_update_date       = l_last_update_date,
   last_update_login      = l_last_update_login
   where eligy_criteria_id = bg_crit_rec.eligy_criteria_id;
   --
   End loop;

  else
    --
    insert into ben_eligy_criteria
    (
    eligy_criteria_id,
    short_code,
    name,
    description,
    crit_col1_val_type_cd,
    crit_col1_datatype,
    col1_lookup_type,
    col1_value_set_id,
    access_table_name1,
    access_column_name1,
    crit_col2_val_type_cd,
    crit_col2_datatype,
    col2_lookup_type,
    col2_value_set_id,
    access_table_name2,
    access_column_name2,
    allow_range_validation_flag,
    allow_range_validation_flag2,
    user_defined_flag,
    business_group_id,
    legislation_code,
    criteria_type,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number
    )
    values
    (
    ben_eligy_criteria_s.nextval,
    p_short_code,
    p_name,
    p_description,
    p_crit_col1_val_type_cd,
    p_crit_col1_datatype,
    p_col1_lookup_type,
    l_col1_value_set_id,
    p_access_table_name1,
    p_access_column_name1,
    p_crit_col2_val_type_cd,
    p_crit_col2_datatype,
    p_col2_lookup_type,
    l_col2_value_set_id,
    p_access_table_name2,
    p_access_column_name2,
    p_allow_range_validation_flag,
    p_allow_range_validation_flag2,
    p_user_defined_flag,
    null,
    p_legislation_code,
    'STD',
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login,
    l_ovn
    );
    --
  end if;
  --
   hr_general.g_data_migrator_mode := l_data_migrator_mode;
end load_criteria_seed_row;
**/
--
procedure create_update_criteria(p_mode               in varchar2,
                                 p_eligy_criteria_id  in number,
                                 p_business_area      in varchar2,
                                 p_business_group_id  in number,
                                 p_effective_date     in date,
                                 p_criteria_type      in varchar2,
                                 p_copy_entity_txn_id in  out nocopy number,
                                 p_copy_entity_result_id  out nocopy number,
                                 p_copy_entity_result_ovn out nocopy number) is
   l_cet_id number;
   l_cer_id number;
   l_cer_ovn number;
   l_eligy_criteria_id_new number;
begin

   if p_mode ='CREATE'  and p_copy_entity_txn_id is null then
      hr_utility.set_location('creating cet row',10);
      create_criteria_txn(p_mode               => p_mode,
                          p_business_area      => p_business_area,
                          p_business_group_id  => p_business_group_id,
                          p_effective_date     => p_effective_date,
                          p_copy_entity_txn_id => l_cet_id);

      if l_cet_id is not null then
            hr_utility.set_location('populate out params',10);
            p_copy_entity_txn_id := l_cet_id;
      else
         hr_utility.set_location('cet row is not there',10);
      end if;

   elsif p_mode ='UPDATE' and p_copy_entity_txn_id is null then
   -- create the copy entity txn row
   -- copy the EGL data into staging area and set dml_operation to 'UPDATE'
      hr_utility.set_location('creating cet row for update',10);
      create_criteria_txn(p_mode               => p_mode,
                          p_business_area      => p_business_area,
                          p_business_group_id  => p_business_group_id,
                          p_effective_date     => p_effective_date,
                          p_copy_entity_txn_id => l_cet_id);



      if l_cet_id is not null then

         if p_criteria_type = 'USER' then -- USER DEFINED CRITERIA TYPE
             -- we have to pull eligy criteria into cer row
             hr_utility.set_location('copying criteria row',10);
             copy_egl_row(p_eligy_criteria_id      => p_eligy_criteria_id,
                          p_copy_entity_txn_id     => l_cet_id,
                          p_effective_date         => p_effective_date,
                          p_copy_entity_result_id  => l_cer_id,
                          p_copy_entity_result_ovn => l_cer_ovn);
         else    -- WE HAVE TO PULL STANDARD CRITERIA AND ADD BUSINESS GRP ID

            check_criteria_in_busgrp(p_eligy_criteria_id,p_business_group_id,l_eligy_criteria_id_new);

            hr_utility.set_location('Value returned from check_criteria_in_busgrp:'||l_eligy_criteria_id_new ,10);

            if p_eligy_criteria_id <> l_eligy_criteria_id_new then
             -- we have to pull eligy criteria into cer row
             hr_utility.set_location('copying criteria row',10);
             copy_egl_row(p_eligy_criteria_id      => l_eligy_criteria_id_new,
                          p_copy_entity_txn_id     => l_cet_id,
                          p_effective_date         => p_effective_date,
                          p_copy_entity_result_id  => l_cer_id,
                          p_copy_entity_result_ovn => l_cer_ovn);
            else
             hr_utility.set_location('copying criteria std row',10);
             copy_criteria_std(p_eligy_criteria_id      => p_eligy_criteria_id,
                              p_copy_entity_txn_id     => l_cet_id,
                              p_effective_date         => p_effective_date,
                              p_business_group_id       => p_business_group_id,
                              p_copy_entity_result_id  => l_cer_id,
                              p_copy_entity_result_ovn => l_cer_ovn);
             end if;
        end if;

        if l_cer_id is not null then
           hr_utility.set_location('populate out params',10);
           p_copy_entity_txn_id := l_cet_id;
           p_copy_entity_result_id := l_cer_id;
           p_copy_entity_result_ovn := l_cer_ovn;
        else
           hr_utility.set_location('cer row not there',10);
        end if;

      end if;


   else
      hr_utility.set_location('invalid mode passed',10);
   end if;
end create_update_criteria;


procedure stage_to_criteria(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_eligy_criteria_id     out nocopy number) is
   cursor c1 is select * from ben_copy_entity_results
                where table_alias = 'EGL'
                and copy_entity_txn_id = p_copy_entity_txn_id;
   l_eligy_criteria_id number;
   l_eligy_ovn number;
   l_effective_date date := p_effective_date;
begin
   FND_MSG_PUB.initialize;
   for r_egl in c1 loop
      if r_egl.dml_operation ='UPDATE' then
         hr_utility.set_location('going for update operation ',10);
         l_eligy_ovn := r_egl.information265;
         l_eligy_criteria_id := r_egl.information1;

        ben_eligy_criteria_api.update_eligy_criteria(
               p_validate                    => FALSE,
               p_eligy_criteria_id           => l_eligy_criteria_id,
               p_name                        => r_egl.information170,
               p_short_code                  => r_egl.information11,
               p_description                 => r_egl.information219,
               p_criteria_type               => r_egl.information12,
               p_crit_col1_val_type_cd       => r_egl.information13,
               p_crit_col1_datatype          => r_egl.information14,

               p_col1_lookup_type            => r_egl.information15,
               p_col1_value_set_id           => r_egl.information266,
               p_access_table_name1          => r_egl.information16,
               p_access_column_name1         => r_egl.information17,
               p_time_entry_access_tab_nam1  => r_egl.information18,
               p_time_entry_access_col_nam1  => r_egl.information19,

               p_crit_col2_val_type_cd       => r_egl.information20,
               p_crit_col2_datatype          => r_egl.information21,
               p_col2_lookup_type            => r_egl.information22,
               p_col2_value_set_id           => r_egl.information267,
               p_access_table_name2          => r_egl.information23,
               p_access_column_name2         => r_egl.information24,
               p_time_entry_access_tab_nam2  => r_egl.information25,
               p_time_entry_access_col_nam2  => r_egl.information26,

               p_access_calc_rule            => r_egl.information268,
               p_allow_range_validation_flg  => r_egl.information27,
               p_user_defined_flag           => r_egl.information28,
               p_business_group_id           => r_egl.information4,
               p_legislation_code            => r_egl.information29,
               p_egl_attribute_category      => r_egl.information110,
               p_egl_attribute1              => r_egl.information111,
               p_egl_attribute2              => r_egl.information112,
               p_egl_attribute3              => r_egl.information113,
               p_egl_attribute4              => r_egl.information114,
               p_egl_attribute5              => r_egl.information115,
               p_egl_attribute6              => r_egl.information116,
               p_egl_attribute7              => r_egl.information117,
               p_egl_attribute8              => r_egl.information118,
               p_egl_attribute9              => r_egl.information119,
               p_egl_attribute10             => r_egl.information120,
               p_egl_attribute11             => r_egl.information121,
               p_egl_attribute12             => r_egl.information122,
               p_egl_attribute13             => r_egl.information123,
               p_egl_attribute14             => r_egl.information124,
               p_egl_attribute15             => r_egl.information125,
               p_egl_attribute16             => r_egl.information126,
               p_egl_attribute17             => r_egl.information127,
               p_egl_attribute18             => r_egl.information128,
               p_egl_attribute19             => r_egl.information129,
               p_egl_attribute20             => r_egl.information130,
               p_egl_attribute21             => r_egl.information131,
               p_egl_attribute22             => r_egl.information132,
               p_egl_attribute23             => r_egl.information133,
               p_egl_attribute24             => r_egl.information134,
               p_egl_attribute25             => r_egl.information135,
               p_egl_attribute26             => r_egl.information136,
               p_egl_attribute27             => r_egl.information137,
               p_egl_attribute28             => r_egl.information138,
               p_egl_attribute29             => r_egl.information139,
               p_egl_attribute30             => r_egl.information140,
               p_object_version_number       => l_eligy_ovn,
               p_effective_date              => l_effective_date,
               p_allow_range_validation_flag2 => r_egl.information30,
               p_access_calc_rule2            => r_egl.information269,
               p_time_access_calc_rule1       => r_egl.information270,
               p_time_access_calc_rule2       => r_egl.information271
            );
      elsif r_egl.dml_operation = 'CREATE' then
         hr_utility.set_location('going for create operation ',10);

        ben_eligy_criteria_api.create_eligy_criteria(
               p_validate                    => FALSE,
               p_eligy_criteria_id           => l_eligy_criteria_id,
               p_name                        => r_egl.information170,
               p_short_code                  => r_egl.information11,
               p_description                 => r_egl.information219,
               p_criteria_type               => r_egl.information12,
               p_crit_col1_val_type_cd       => r_egl.information13,
               p_crit_col1_datatype          => r_egl.information14,
               p_col1_lookup_type            => r_egl.information15,
               p_col1_value_set_id           => r_egl.information266,
               p_access_table_name1          => r_egl.information16,
               p_access_column_name1         => r_egl.information17,
               p_time_entry_access_tab_nam1  => r_egl.information18,
               p_time_entry_access_col_nam1  => r_egl.information19,

               p_crit_col2_val_type_cd       => r_egl.information20,
               p_crit_col2_datatype          => r_egl.information21,
               p_col2_lookup_type            => r_egl.information22,
               p_col2_value_set_id           => r_egl.information267,
               p_access_table_name2          => r_egl.information23,
               p_access_column_name2         => r_egl.information24,
               p_time_entry_access_tab_nam2  => r_egl.information25,
               p_time_entry_access_col_nam2  => r_egl.information26,

               p_access_calc_rule            => r_egl.information268,
               p_allow_range_validation_flg  => r_egl.information27,
               p_user_defined_flag           => r_egl.information28,
               p_business_group_id           => r_egl.information4,
               p_legislation_code            => r_egl.information29,
               p_egl_attribute_category      => r_egl.information110,
               p_egl_attribute1              => r_egl.information111,
               p_egl_attribute2              => r_egl.information112,
               p_egl_attribute3              => r_egl.information113,
               p_egl_attribute4              => r_egl.information114,
               p_egl_attribute5              => r_egl.information115,
               p_egl_attribute6              => r_egl.information116,
               p_egl_attribute7              => r_egl.information117,
               p_egl_attribute8              => r_egl.information118,
               p_egl_attribute9              => r_egl.information119,
               p_egl_attribute10             => r_egl.information120,
               p_egl_attribute11             => r_egl.information121,
               p_egl_attribute12             => r_egl.information122,
               p_egl_attribute13             => r_egl.information123,
               p_egl_attribute14             => r_egl.information124,
               p_egl_attribute15             => r_egl.information125,
               p_egl_attribute16             => r_egl.information126,
               p_egl_attribute17             => r_egl.information127,
               p_egl_attribute18             => r_egl.information128,
               p_egl_attribute19             => r_egl.information129,
               p_egl_attribute20             => r_egl.information130,
               p_egl_attribute21             => r_egl.information131,
               p_egl_attribute22             => r_egl.information132,
               p_egl_attribute23             => r_egl.information133,
               p_egl_attribute24             => r_egl.information134,
               p_egl_attribute25             => r_egl.information135,
               p_egl_attribute26             => r_egl.information136,
               p_egl_attribute27             => r_egl.information137,
               p_egl_attribute28             => r_egl.information138,
               p_egl_attribute29             => r_egl.information139,
               p_egl_attribute30             => r_egl.information140,
               p_object_version_number       => l_eligy_ovn,
               p_effective_date              => l_effective_date,
               p_allow_range_validation_flag2 => r_egl.information30,
               p_access_calc_rule2            => r_egl.information269,
               p_time_access_calc_rule1       => r_egl.information270,
               p_time_access_calc_rule2       => r_egl.information271);

      else
         hr_utility.set_location('invalid mode of operation passed',10);
      end if;
      p_eligy_criteria_id := l_eligy_criteria_id;
   end loop;
exception
   when others then
      hr_utility.set_location('issues in writing criteria ',10);
      raise;
end stage_to_criteria;


FUNCTION check_criteria_rate_under_use(p_criteria_rate_defn_id NUMBER) RETURN varchar2 IS
    l_rate_matrix_rate_id number;
    l_rate_matrix_rate_id2 number;
    l_ret_vlaue varchar2(3);
    cursor c1 is select rate_matrix_rate_id from pqh_rate_matrix_rates_f
        where criteria_rate_defn_id = p_criteria_rate_defn_id;
    cursor c2 is select information1 from ben_copy_entity_results where
        information1 = p_criteria_rate_defn_id and table_alias = 'RCR';
    BEGIN
        open c1;
        fetch c1 into l_rate_matrix_rate_id;
        if c1%found then
            l_ret_vlaue := 'Yes';
        else
            open c2;
            fetch c2 into l_rate_matrix_rate_id2;
            if c2%found then
                l_ret_vlaue := 'Yes';
            else
                l_ret_vlaue := 'No';
            end if;
            close c2;
        end if;
        close c1;
        RETURN l_ret_vlaue;
      END check_criteria_rate_under_use;

procedure insert_rate_defn_tl(rateid  in number,
                                  ratename in varchar2,
                                  lang     in varchar2,
                                  slang    in varchar2,
                                  cdate    in date,
                                  cperson  in number) is
    begin

        insert into pqh_criteria_rate_defn_tl(CRITERIA_RATE_DEFN_ID,NAME,LANGUAGE,
                                           SOURCE_LANG,CREATION_DATE,CREATED_BY)
                values(rateid,ratename,lang,slang,cdate,cperson);
        commit;

    end insert_rate_defn_tl;

procedure sync_rate_factors_tables(critId  in varchar2,
                                  parentId in varchar2) is
    l_rate_factor_id pqh_rate_factor_on_elmnts.rate_factor_on_elmnt_id%TYPE;
    cursor c1 is select rate_factor_on_elmnt_id from
        Pqh_rate_factor_on_elmnts rf, Pqh_criteria_rate_elements re
        where rf.criteria_rate_element_id = re.criteria_rate_element_id
          and re.criteria_rate_defn_id = critId
          and rf.criteria_rate_factor_id = parentId;
    begin
        open c1;
        loop
            fetch c1 into l_rate_factor_id;
            delete from Pqh_rate_factor_on_elmnts
                where rate_factor_on_elmnt_id = l_rate_factor_id;
            exit when c1%NOTFOUND;
        end loop;
        close c1;
    end sync_rate_factors_tables;

FUNCTION is_used_in_matrix(p_selected_rate_matrix NUMBER, p_criteria_rate_defn_id NUMBER) RETURN varchar2 IS
    l_return_vlaue varchar2(1);
    BEGIN
        Select 'Y' INTO l_return_vlaue from
            pqh_rate_matrix_rates_f t1, pqh_rate_matrix_nodes t2
            Where t2.pl_id = p_selected_rate_matrix
            and t2.rate_matrix_node_id = t1.rate_matrix_node_id
            and sysdate between t1.effective_start_date and t1.effective_end_date
            and t1.criteria_rate_defn_id = p_criteria_rate_defn_id group by t1.criteria_rate_defn_id;
        RETURN l_return_vlaue;
    END is_used_in_matrix;

FUNCTION get_rate_factor_name(p_criteria_rate_factor_id NUMBER) RETURN varchar2 IS
    l_return_vlaue varchar2(30);
    BEGIN
        l_return_vlaue := 'RATE_FACTOR_NAME';
        RETURN l_return_vlaue;
    END get_rate_factor_name;

PROCEDURE is_crit_rate_short_name_uniq( sname       in varchar2,
                                        rateId      in number,
                                        bgId        in number,
                                        isValid     out nocopy varchar2)is
    l_name pqh_criteria_rate_defn_vl.short_name%TYPE;
    cursor c11 is
    SELECT SHORT_NAME FROM pqh_criteria_rate_defn_vl
        where  upper(short_name) = upper(sname)
        and CRITERIA_RATE_DEFN_ID <> rateId
        and business_group_id = bgId;
    begin
        hr_utility.set_location('Rate Id'||to_char(rateId), 5);
        hr_utility.set_location('name'||sname, 10);
        open c11;
        fetch c11 into l_name;
        close c11;

        if l_name is null then
            hr_utility.set_location('l_name'||l_name, 20);
            isValid := 'valid';
        else
            isValid := 'invalid';
        end if;
    end is_crit_rate_short_name_uniq;

PROCEDURE is_crit_rate_name_uniq(cname      in varchar2,
                                 rateId     in number,
                                 bgId       in number,
                                 isValid    out nocopy varchar2)is
    l_name pqh_criteria_rate_defn_vl.name%TYPE;
    cursor c11 is
    SELECT NAME FROM pqh_criteria_rate_defn_vl
        where  upper(name) = upper(cname)
        and CRITERIA_RATE_DEFN_ID <> rateId
        and business_group_id = bgId;
    begin
        open c11;
        fetch c11 into l_name;
        close c11;
        if l_name is null then
            isValid := 'valid';
        else
            isValid := 'invalid';
        end if;
    end is_crit_rate_name_uniq;

PROCEDURE cascade_rate_factors_table(rateTypeId varchar2) IS
    BEGIN
        delete from Pqh_criteria_rate_factors
            where criteria_rate_defn_id = rateTypeId;
    END cascade_rate_factors_table;

--
-- Procedures needed for adding or removing criteria rate definition from Rate Matrix.
--
Procedure remove_crd_from_rate_matrix
         (p_business_group_id     in number,
          p_criteria_rate_defn_id in number,
          p_copy_entity_txn_id    in number,
          p_removed_crd_name     out nocopy varchar2,
          p_removed_dep_crd      out nocopy varchar2) is
--
Cursor csr_exist_crd(p_crd_id in number) is
 Select 'x'
  from ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   AND table_alias = 'RMR'
   AND information162 = p_crd_id
   and dml_operation <> 'DELETE'
   and information1 is not null;
--
Cursor csr_rm is
Select information1
  from  ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   AND table_alias = 'PLN';
--
Cursor csr_ref_crd(p_rate_matrix_id in number) is
Select copy_entity_result_id, information1 , nvl(information5,'name') crd_name,information160
 from ben_copy_entity_results
Where table_alias = 'RCR'
  and copy_entity_txn_id = p_copy_entity_txn_id
  and (information1 = p_criteria_rate_defn_id OR
       information1 in (select criteria_rate_defn_id
                          from pqh_criteria_rate_factors
                         Where parent_criteria_rate_defn_id = p_criteria_rate_defn_id
                           and (parent_rate_matrix_id is null or parent_rate_matrix_id = p_rate_matrix_id)
                        )
      );
--
 l_dummy varchar2(1);
 l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%type;
 l_criteria_rate_defn_id ben_copy_entity_results.information1%type;
 l_criteria_rate_defn_name ben_copy_entity_results.information5%type;
 l_curr_order_number     ben_copy_entity_results.information160%type;
 l_curr_rate_matrix_id   ben_copy_entity_results.information1%type;
--
Begin
--
hr_utility.set_location('Entering',5);
l_criteria_rate_defn_name := null;
p_removed_crd_name := null;
l_curr_rate_matrix_id := null;

Open csr_rm;
Fetch csr_rm into l_curr_rate_matrix_id;
Close csr_rm;
--
If l_curr_rate_matrix_id is null then
   l_curr_rate_matrix_id := -1;
End if;
--
For del_crd_row in csr_ref_crd(l_curr_rate_matrix_id)  loop
   --
   l_criteria_rate_defn_id := del_crd_row.information1;
   l_copy_entity_result_id := del_crd_row.copy_entity_result_id;
   l_curr_order_number := del_crd_row.information160;
   If l_criteria_rate_defn_id = p_criteria_rate_defn_id then
      --
      If p_removed_crd_name is null then
         p_removed_crd_name := del_crd_row.crd_name;
      else
         p_removed_crd_name := p_removed_crd_name ||','||del_crd_row.crd_name;
      End if;
   Else
      --
      If p_removed_dep_crd is null then
         p_removed_dep_crd := del_crd_row.crd_name;
      else
         p_removed_dep_crd := p_removed_dep_crd ||','||del_crd_row.crd_name;
      End if;
      --
   End if;

   hr_utility.set_location('Removing:'||p_removed_crd_name,5);
   --
   -- 1) set the RMR rows for this removed criteria rate definition to deleted.
   -- Check if this criteria rate defintion was added as part of this transaction.
   -- If rates for rate matrix nodes exist for this criteria rate definition in the
   -- master table, then RMR rows will have a rate_matrix_rate_id
   --
   Open csr_exist_crd(l_criteria_rate_defn_id);
   Fetch csr_exist_crd into l_dummy;
   If csr_exist_crd%notfound then
      --
      -- Criteria Rate definition was added to rate matrix as a part of current txn.
      --
      Delete from  ben_copy_entity_results
      Where copy_entity_txn_id = p_copy_entity_txn_id
      AND table_alias = 'RMR'
      AND information162 = l_criteria_rate_defn_id
      and dml_operation <> 'DELETE';

    Else
      --
      -- Criteria Rate definition was previously added to rate matrix.Hence rates
      -- must be deleted from the master table. Hence mark it for deletion in
      -- staging area.
      --
      Update ben_copy_entity_results
      set dml_operation = 'DELETE'
      Where copy_entity_txn_id = p_copy_entity_txn_id
      AND table_alias = 'RMR'
      AND information162 = l_criteria_rate_defn_id
      and dml_operation <> 'DELETE';
      --
    End if;
    Close csr_exist_crd;
    --
    -- Delete RCR row.
    --
    hr_utility.set_location('Deleting:'||to_char(l_copy_entity_result_id),15);
    Delete from ben_copy_entity_results
    Where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'RCR'
    and copy_entity_result_id = l_copy_entity_result_id;
    --
    -- Adjust order number for remanining RCR rows.
    --
/**
    Update ben_copy_entity_results
    set information160 = (information160 - 1)
    Where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'RCR'
    and information160 > l_curr_order_number;
**/
    --
End loop;
--
End;
--
Procedure rebuild_rbr_rows
         (p_business_group_id     in number,
          p_copy_entity_txn_id    in number
          ) is
--
--
 l_dummy varchar2(1);
 l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%type;
 l_criteria_rate_defn_id ben_copy_entity_results.information1%type;
 l_criteria_rate_defn_name ben_copy_entity_results.information5%type;
 l_curr_order_number     ben_copy_entity_results.information160%type;
 l_new_order_number     ben_copy_entity_results.information160%type := 0;
 l_parent               pqh_criteria_rate_defn.criteria_rate_defn_id%type;
 l_curr_rate_matrix_id  ben_pl_f.pl_id%type;
--
Cursor csr_ref_crd is
Select copy_entity_result_id, information1 , nvl(information5,'name') crd_name,information160
 from ben_copy_entity_results
Where table_alias = 'RCR'
  and copy_entity_txn_id = p_copy_entity_txn_id
 order by information160;
--
Cursor csr_rm is
Select information1
  from  ben_copy_entity_results
 Where copy_entity_txn_id = p_copy_entity_txn_id
   AND table_alias = 'PLN';
--
Cursor csr_find_parent(p_rate_matrix_id in number, p_criteria_rate_defn_id in number) is
select a.parent_criteria_rate_defn_id parent_id, b.name parent_name
 from pqh_criteria_rate_factors a, pqh_criteria_rate_defn_vl b
Where a.criteria_rate_defn_id = p_criteria_rate_defn_id
  and (parent_rate_matrix_id is null or parent_rate_matrix_id = p_rate_matrix_id)
  and a.parent_criteria_rate_defn_id = b.criteria_rate_defn_id;
--
Cursor csr_is_parent_added(p_parent in number) is
Select 'x'
 from ben_copy_entity_results
Where table_alias = 'RCR'
  and copy_entity_txn_id = p_copy_entity_txn_id
  and information1 = p_parent;
--
Begin
--
hr_utility.set_location('Entering rebuild_rbr_rows',5);
--
/**
l_curr_rate_matrix_id := null;

Open csr_rm;
Fetch csr_rm into l_curr_rate_matrix_id;
Close csr_rm;
--
If l_curr_rate_matrix_id is null then
   l_curr_rate_matrix_id := -1;
   hr_utility.set_location('null rate matrix',5);
End if;
--
--
-- Validate if any criteria_rate_defn is dependent on another and if so, if the parent has
-- been added to the rate matrix.
-- Find all criteria rate defn added to rate matrix
--
hr_multi_message.enable_message_list;
For added_rcr_rec in csr_ref_crd loop
   --
   l_criteria_rate_defn_id := null;
   l_criteria_rate_defn_name := null;
   l_parent:= null;
   --
   l_criteria_rate_defn_id := added_rcr_rec.information1;
   --
   hr_utility.set_location('crd ='||to_char(l_criteria_rate_defn_id),5);
   -- Find its parent
   --
   For parent_rec in  csr_find_parent(l_curr_rate_matrix_id,l_criteria_rate_defn_id) loop
       l_parent:= parent_rec.parent_id;
       l_criteria_rate_defn_name := parent_rec.parent_name;
       -- Is parent added
       hr_utility.set_location('parent id ='||to_char(l_parent),5);
       hr_utility.set_location('parent name ='||l_criteria_rate_defn_name,5);
       Open csr_is_parent_added(l_parent);
       Fetch csr_is_parent_added into l_dummy;
       If csr_is_parent_added%notfound then
          hr_utility.set_location('parent not found',5);
          hr_utility.set_message(8302,'PQH_RBC_REENTER_PLAN_INFO');
          hr_multi_message.add;
       End if;
       Close csr_is_parent_added;

   End loop;
End loop;
**/
--
-- Adjust order number for remanining RCR rows.
--
l_criteria_rate_defn_id := null;
l_criteria_rate_defn_name := null;
For del_crd_row in csr_ref_crd loop
   --
   l_criteria_rate_defn_id := del_crd_row.information1;
   l_copy_entity_result_id := del_crd_row.copy_entity_result_id;
   l_curr_order_number := del_crd_row.information160;
    --
    --
    Update ben_copy_entity_results
    set information160 = l_new_order_number
    Where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'RCR'
    and copy_entity_result_id = l_copy_entity_result_id;
    l_new_order_number := l_new_order_number+1;
    --
End loop;
--
End;
--
Procedure add_crd_to_rate_matrix
         (p_business_group_id     in number,
          p_criteria_rate_defn_id in number,
          p_copy_entity_txn_id    in number,
          p_define_min_flag       in varchar2,
          p_define_mid_flag       in varchar2,
          p_define_max_flag       in varchar2,
          p_define_std_flag       in varchar2,
          p_currency_code         in varchar2,
          p_uom                   in varchar2,
          p_rate_calc_cd          in varchar2,
          p_display_computed_values in varchar2,
          p_name                    in varchar2
          ) is
   --
   l_rcr_cer_id number;
   l_rcr_cer_ovn number;
   l_order_num   number := null;
   --
   l_rcr_tr_id number;
   l_rcr_tr_name varchar2(150);
   --
Cursor csr_next_order_num is
Select max(information160) + 1
from ben_copy_entity_results
Where copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'RCR';
--
Begin
--
  Open csr_next_order_num;
  Fetch csr_next_order_num into l_order_num;
  Close csr_next_order_num;
  --
  If l_order_num is null then
     l_order_num := 0;
  End if;
  --
  pqh_gsp_hr_to_stage.get_table_route_details
   (p_table_alias    => 'RCR',
   p_table_route_id => l_rcr_tr_id,
   p_table_name     => l_rcr_tr_name);
  --
-- When a new criteria rate definition is added, Add a RCR row with the correct
-- order number and details
      ben_copy_entity_results_api.create_copy_entity_results(
      p_effective_date              => trunc(sysdate)
      ,p_copy_entity_txn_id         => p_copy_entity_txn_id
      ,p_result_type_cd             => 'DISPLAY'
      ,p_table_name                 => l_rcr_tr_name
      ,p_table_route_id             => l_rcr_tr_id
      ,p_table_alias                => 'RCR'
      ,p_dml_operation              => 'COPIED'
      ,p_information1               => p_criteria_rate_defn_id
      ,p_information4               => p_business_group_id
      ,p_information5               => p_name
      ,p_information49              => p_uom
      ,p_information50              => p_currency_code
      ,p_information160             => l_order_num
      ,p_information111             => p_define_min_flag
      ,p_information112             => p_define_mid_flag
      ,p_information113             => p_define_max_flag
      ,p_information114             => p_define_std_flag
      ,p_information115             => p_rate_calc_cd
      ,p_information116             => p_display_computed_values
      ,p_copy_entity_result_id      => l_rcr_cer_id
      ,p_object_version_number      => l_rcr_cer_ovn);
--
End;
--
--





function allow_hgrid_add(p_copy_entity_txn_id in number,p_max_allowed in number) return varchar2 IS
   l_max number;
BEGIN
    if future_criteria_exist(p_copy_entity_txn_id) = 'YES' then
            return 'DisallowAdd';
    end if;

    select max(nvl(information160,1))into l_max from ben_copy_entity_results where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias in('RBC_CRIT', 'PLN') and dml_operation <> 'DELETE';
    if l_max < p_max_allowed then
       RETURN 'AllowAdd';
    else
       RETURN 'DisallowAdd';
    end if;
END allow_hgrid_add;
--
--
procedure delete_rate_values(p_copy_entity_txn_id       in number,
                             p_copy_entity_result_id    in number
                            ) is
    l_copy_entity_result_id number;
    l_rate_matrix_node_id number;
    l_level_number number;
   -- p_mode in UPDATE or CREATE
  cursor c1 is select copy_entity_result_id, information160
        from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and gs_parent_entity_result_id = p_copy_entity_result_id
        and table_alias in ('RMN','RMV');
        --Bug#9206953 vkodedal
  cursor c2 is select information1,copy_entity_result_id
        from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and (copy_entity_result_id = l_copy_entity_result_id
        or gs_parent_entity_result_id = l_copy_entity_result_id)
        and table_alias in ('RMN','RMV');

  begin
    open c1;
    loop
        fetch c1 into l_copy_entity_result_id, l_level_number;
        EXIT WHEN c1%NOTFOUND;
        if(is_lowest_level(p_copy_entity_txn_id,
                           l_copy_entity_result_id,
                           l_level_number) = 'N')then
            delete_rate_values(p_copy_entity_txn_id, l_copy_entity_result_id);
        end if;

        delete from ben_copy_entity_results
            where INFORMATION1 = l_copy_entity_result_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'RBR';

        open c2;
        loop
             --Bug#9206953 vkodedal
            fetch c2 into l_rate_matrix_node_id,l_copy_entity_result_id;
            EXIT WHEN c2%NOTFOUND;
            delete from ben_copy_entity_results
            where INFORMATION1 = l_rate_matrix_node_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and copy_entity_result_id=l_copy_entity_result_id
            and table_alias in ('RMV','RMN')
            and dml_operation = 'CREATE';

            update ben_copy_entity_results
            set dml_operation = 'DELETE',datetrack_mode = 'DELETE'
            where INFORMATION1 = l_rate_matrix_node_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and copy_entity_result_id=l_copy_entity_result_id
            and table_alias in ('RMV','RMN')
            and dml_operation in ('UPDATE','COPIED');

        end loop;
        close c2;
    end loop;
    close c1;
    delete from ben_copy_entity_results
            where INFORMATION1 = p_copy_entity_result_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'RBR';

    delete from ben_copy_entity_results
            where copy_entity_result_id = p_copy_entity_result_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias in ('RMV','RMN')
            and dml_operation = 'CREATE';

    update ben_copy_entity_results
            set dml_operation = 'DELETE',datetrack_mode = 'DELETE'
            where copy_entity_result_id = p_copy_entity_result_id
            and copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias in ('RMV','RMN')
            and dml_operation in ('UPDATE','COPIED');

end;
--
function is_lowest_level(p_copy_entity_txn_id    number,
                          p_copy_entity_result_id number,
                          p_level_number          number) return varchar2 is
l_max_level_number number;
begin
    select max(information160) into l_max_level_number from ben_copy_entity_results
    where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE';

    if(p_level_number = 1 or p_level_number < l_max_level_number) then
        return 'N';
    else
        return 'Y';
    end if;
end is_lowest_level;

--
--
procedure cancel_rate_matrix_txn(p_copy_entity_txn_id in number,p_status out nocopy varchar2) is

   l_copy_entity_result_id number;
   cursor c1 is select copy_entity_result_id from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'PLN';

begin
   FND_MSG_PUB.initialize;

        open c1;
        fetch c1 into l_copy_entity_result_id;
        close c1;
        if l_copy_entity_result_id is null then
            p_status := 'NO';
        else
            p_status := 'YES';
        end if;



   hr_utility.set_location('going for deleting entire rate matrix txn',100);
   delete from ben_copy_entity_results where copy_entity_txn_id = p_copy_entity_txn_id;
   delete from pqh_copy_entity_txns  where  copy_entity_txn_id = p_copy_entity_txn_id;
   hr_utility.set_location('deleting entire rate matrix txn done',110);
exception
   when others then
      hr_utility.set_location('issues in deleting matrix txn',100);
      raise;
end cancel_rate_matrix_txn;

procedure rate_columns_in_sync(critId      in number,
                            pMaxFlag    in varchar2,
                            pMinFlag    in varchar2,
                            pMidFlag    in varchar2,
                            pDflFlag    in varchar2,
                            pOutValue   out nocopy varchar2) is
    l_max_flag varchar(2);
    l_mid_flag varchar(2);
    l_min_flag varchar(2);
    l_dfl_flag varchar(2);
begin
    select DEFINE_MAX_RATE_FLAG, DEFINE_MIN_RATE_FLAG, DEFINE_MID_RATE_FLAG, DEFINE_STD_RATE_FLAG
         into l_max_flag, l_min_flag, l_mid_flag, l_dfl_flag
    from pqh_criteria_rate_defn
    where CRITERIA_RATE_DEFN_ID = critId;
    if( (pMaxFlag = 'Y' AND l_max_flag <> pMaxFlag) OR
        (pMidFlag = 'Y' AND l_mid_flag <> pMidFlag) OR
        (pMinFlag = 'Y' AND l_min_flag <> pMinFlag) OR
        (pDflFlag = 'Y' AND l_dfl_flag <> pDflFlag)) then
        pOutValue := 'NO';
    else
        pOutValue := 'YES';
    end if;
end rate_columns_in_sync;

FUNCTION get_currency_name(p_currency_code varchar2) RETURN varchar2 IS
    l_currency_name varchar2(80);
    cursor c1 is select name from fnd_currencies_vl
            where currency_code = p_currency_code;
    BEGIN
        open c1;
        loop
            fetch c1 into l_currency_name;
            exit when c1%notfound;
        end loop;
        close c1;

        RETURN l_currency_name;
END get_currency_name;

FUNCTION get_formula_name(p_formula_id varchar2) RETURN varchar2 IS
    l_formula_id varchar2(80);
    cursor c1 is select formula_name from ff_formulas_f
        where formula_id = p_formula_id;
    BEGIN
        open c1;
        loop
            fetch c1 into l_formula_id;
            exit when c1%notfound;
        end loop;
        close c1;

        RETURN l_formula_id;
END get_formula_name;

--
-- Function to return the datatype of the value returned by a valueset
-- Char - C / V
-- Number - N
-- Standard Date - X / D
-- Treat any other value as invalid datatype
--
Function get_vset_datatype(p_value_set_id in number) return varchar2 is
--
-- Format type maybe 'C' , 'N' or 'X'
--
Cursor csr_val_type is
Select validation_type, format_type
  from fnd_flex_value_sets
 Where flex_value_set_id = p_value_set_id;
--
-- The column type may be 'C' , 'V', 'N' , 'D' or null
--
Cursor csr_id_col_type is
select nvl(id_column_type,'O')
  from fnd_flex_validation_tables
 where flex_value_set_id = p_value_set_id;
--
 l_validation_type fnd_flex_value_sets.validation_type%type;
 l_format_type     fnd_flex_value_sets.format_type%type;
 l_col_type        fnd_flex_validation_tables.id_column_type%type;
--
Begin
 -- Get the validation type of the valueset
 open csr_val_type;
 Fetch csr_val_type into l_validation_type, l_format_type;
 If csr_val_type%notfound then
    -- Invalid value set id passed.
    Close csr_val_type;
    return 'O';
 Else
   --
   -- Valid value set
   --
   Close csr_val_type;
   If l_validation_type = 'F' then
      -- Table type valueset
      open csr_id_col_type;
      Fetch csr_id_col_type into l_col_type;
      If csr_id_col_type%notfound then
         Close csr_id_col_type;
         return 'O';
      Else
        Close csr_id_col_type;
        return l_col_type;
      End if;
      --
   Else
      return l_format_type;
   End if;
   --
 End if;
 --
End get_vset_datatype;
--
--
end pqh_rbc_utility;

/
