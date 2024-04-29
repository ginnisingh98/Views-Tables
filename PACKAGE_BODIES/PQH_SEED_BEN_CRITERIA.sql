--------------------------------------------------------
--  DDL for Package Body PQH_SEED_BEN_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SEED_BEN_CRITERIA" AS
/* $Header: pqcritld.pkb 120.1 2005/10/12 20:18 srajakum noship $ */
--
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
                        ,p_last_update_date               in varchar2
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
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  /**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  **/
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
--
--
end pqh_seed_ben_criteria;

/
