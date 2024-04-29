--------------------------------------------------------
--  DDL for Package Body PQH_RBC_LOAD_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_LOAD_OBJECTS" as
/* $Header: pqhrbcld.pkb 120.10.12000000.2 2007/04/19 12:44:33 brsinha noship $ */

function get_plan_id(p_short_code in  varchar2,
                   p_effective_date in date,
                   p_business_group_id in number)
                    return varchar2 is
   Cursor csr_pl is
   select pl_id from ben_pl_f
    where short_code = p_short_code
      and p_effective_date between effective_start_date and effective_end_date
      and business_group_id = p_business_group_id;
   l_pl_id                  ben_pl_f.pl_id%type ;

begin
  Open csr_pl;
  Fetch csr_pl into l_pl_id;
  Close csr_pl;

  return l_pl_id;
end;


--
--
-- The following procedure will be called when loading a rate matrix node.
--
Procedure load_rate_matrix_row
  (p_pl_short_code        in  varchar2
  ,p_name                 in  varchar2
  ,p_short_name           in  varchar2
  ,p_pl_stat_cd           in  varchar2
  ,p_pl_cd                in  varchar2
  ,p_legislation_code     in  varchar2
  ,p_effective_start_date in  varchar2
  ,p_owner                in  varchar2
  ) is

--
   l_pl_id                  ben_pl_f.pl_id%type ;
   l_pl_typ_id              ben_pl_typ_f.pl_typ_id%type;
   l_ovn                    number ;
   l_effective_start_date   date ;
   l_effective_end_date     date ;
   l_effective_date         date;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
   l_dt_mode                varchar2(30);
--
--
   l_created_by             ben_pl_f.created_by%TYPE;
   l_last_updated_by        ben_pl_f.last_updated_by%TYPE;
   l_creation_date          ben_pl_f.creation_date%TYPE;
   l_last_update_date       ben_pl_f.last_update_date%TYPE;
   l_last_update_login      ben_pl_f.last_update_login%TYPE;
--
 -- Create a plan corresponding to Rate matrix.
 --
   Cursor csr_pl is
   select pl_id,object_version_number from ben_pl_f
    where short_code = p_pl_short_code
      and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
  --
  -- There can be only one plan type in the business group with option type = 'RBC'
  --
   Cursor csr_pl_typ is
    select pl_typ_id
      From ben_pl_typ_f
     Where opt_typ_cd = 'RBC'
       and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
  --
Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  Open csr_pl;
  Fetch csr_pl into l_pl_id,l_ovn;
  Close csr_pl;

  -- No plan exists corresponding to Rate matrix short code
  --
  If l_pl_id is null then

     Open csr_pl_typ;
     Fetch csr_pl_typ into l_pl_typ_id;
     Close csr_pl_typ;
     --
     If l_pl_typ_id is null then

        ben_PLAN_TYPE_api.create_PLAN_TYPE
        (
           p_validate                      => false
          ,p_pl_typ_id                     => l_pl_typ_id
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
          ,p_no_mx_enrl_num_dfnd_flag      => 'N'
          ,p_no_mn_enrl_num_dfnd_flag      => 'N'
          ,p_name                          => 'Rate By Criteria'
          ,p_pl_typ_stat_cd                => 'A'
          ,p_opt_typ_cd                    => 'RBC'
          ,p_business_group_id             => l_business_group_id
          ,p_object_version_number         => l_ovn
          ,p_effective_date                => l_effective_date
          ,p_short_name                    => 'RBC'
          ,p_short_code                    => 'RBC'
         );
     End if;

     BEN_PLAN_API.CREATE_PLAN(
              P_EFFECTIVE_DATE                     => l_effective_date
             ,P_BUSINESS_GROUP_ID                  => l_business_group_id
             ,P_NAME                               => p_name
             ,P_PL_CD                              => 'MYNTBPGM'
             ,P_PL_ID                              => l_pl_id
             ,P_PL_STAT_CD                         => p_pl_stat_cd
             ,P_PL_TYP_ID                          => l_pl_typ_id
             ,P_SHORT_CODE                         => p_pl_short_code
             ,P_SHORT_NAME                         => p_short_name
             ,P_EFFECTIVE_START_DATE               => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                 => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER              => l_ovn
           );
  Else
    l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode('BEN_PL_F','PL_ID', l_pl_id, l_effective_date) ;


     BEN_PLAN_API.UPDATE_PLAN(
              P_EFFECTIVE_DATE                      => l_effective_date
             ,P_BUSINESS_GROUP_ID                  => l_business_group_id
             ,P_NAME                               => p_name
             ,P_PL_ID                              => l_pl_id
             ,P_PL_STAT_CD                         => p_pl_stat_cd
             ,P_PL_CD                              => p_pl_cd
             ,P_RT_STRT_DT_RL                      => ''
             ,P_VRFY_FMLY_MMBR_RL                  => ''
             ,P_SHORT_CODE                         => p_pl_short_code
             ,P_SHORT_NAME                         => p_short_name
             ,P_EFFECTIVE_START_DATE               => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                 => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER              => l_ovn
             ,P_DATETRACK_MODE                     => l_dt_mode
             );
  End if;
 --
End;
--
Procedure load_rmn_row
  (p_pl_short_code          in  varchar2
  ,p_node_short_code        in  varchar2
  ,p_node_name              in  varchar2
  ,p_level_number           in  varchar2
  ,p_criteria_short_code    in  varchar2
  ,p_parent_node_short_code in  varchar2
  ,p_eligy_prfl_name        in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_effective_date         in  varchar2
  ,p_owner                  in  varchar2
  ) is
--
   l_pl_id                  ben_pl_f.pl_id%type ;
   l_eligy_prfl_id          ben_eligy_prfl_f.eligy_prfl_id%type;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
   --
   l_rate_matrix_node_id    pqh_rate_matrix_nodes.rate_matrix_node_id%type;
   l_parent_node_id         pqh_rate_matrix_nodes.parent_node_id%type;
   l_ovn                    number := 1;
   l_effective_date         date;
--
--
   l_created_by             pqh_rate_matrix_nodes.created_by%TYPE;
   l_last_updated_by        pqh_rate_matrix_nodes.last_updated_by%TYPE;
   l_creation_date          pqh_rate_matrix_nodes.creation_date%TYPE;
   l_last_update_date       pqh_rate_matrix_nodes.last_update_date%TYPE;
   l_last_update_login      pqh_rate_matrix_nodes.last_update_login%TYPE;
--
--
 --
 -- rate matrix node
 --
 Cursor csr_rmn(p_code in varchar2) is
  select rate_matrix_node_id
    from pqh_rate_matrix_nodes
   Where short_code = p_code
    and business_group_id = l_business_group_id;
 --
 -- plan corresponding to Rate matrix.
 --
/*   Cursor csr_pl is
   select pl_id from ben_pl_f
    where short_code = p_pl_short_code
      and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
      */

-- replaced with    pl_id := getPlanId(p_pl_short_code,l_effective_date,l_business_group_id);
  --
 -- Find eligibility profile
 --
   Cursor csr_elg is
   select eligy_prfl_id from ben_eligy_prfl_f
    where name = p_eligy_prfl_name
      and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
  --
  --
Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  l_effective_date := nvl(to_date(p_effective_date,'DD/MM/YYYY'),sysdate);
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  /*
  Open csr_pl;
  Fetch csr_pl into l_pl_id;
  Close csr_pl;
 */

  l_pl_id := get_plan_id(p_pl_short_code,l_effective_date,l_business_group_id);
  --
  Open csr_elg;
  Fetch csr_elg into l_eligy_prfl_id;
  Close csr_elg;
  --
  Open csr_rmn(p_node_short_code);
  Fetch csr_rmn into l_rate_matrix_node_id;
  Close csr_rmn;


  Open csr_rmn(p_parent_node_short_code);
  Fetch csr_rmn into l_parent_node_id;
  Close csr_rmn;

  -- No rate matrix node exists corresponding to the node_short_code
  --
  If l_rate_matrix_node_id is not null then

     --
     Update pqh_rate_matrix_nodes
     set
     RATE_MATRIX_NODE_ID    = l_rate_matrix_node_id,
     SHORT_CODE             = p_node_short_code,
     PL_ID                  = l_pl_id,
     LEVEL_NUMBER           = p_level_number,
     CRITERIA_SHORT_CODE    = p_criteria_short_code,
     NODE_NAME              = p_node_name,
     PARENT_NODE_ID         = l_parent_node_id,
     ELIGY_PRFL_ID          = l_eligy_prfl_id,
     BUSINESS_GROUP_ID      = l_business_group_id,
     LEGISLATION_CODE       = p_legislation_code,
     last_updated_by        = l_last_updated_by,
     last_update_date       = l_last_update_date,
     last_update_login      = l_last_update_login
     Where rate_matrix_node_id = l_rate_matrix_node_id;
    --
  Else
    --
    Insert into pqh_rate_matrix_nodes
    (
    RATE_MATRIX_NODE_ID,
    SHORT_CODE,
    PL_ID,
    LEVEL_NUMBER,
    CRITERIA_SHORT_CODE,
    NODE_NAME,
    PARENT_NODE_ID,
    ELIGY_PRFL_ID,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
    )
    Values
    (
    pqh_rate_matrix_nodes_s.nextval,
    p_node_short_code,
    l_pl_id,
    p_level_number,
    p_criteria_short_code,
    p_node_name,
    l_parent_node_id,
    l_eligy_prfl_id,
    l_business_group_id,
    p_legislation_code,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login,
    l_ovn
    );

  End if;
 --
End load_rmn_row;
--
--
Procedure load_rmv_row
  (p_short_code             in  varchar2
  ,p_node_short_code        in  varchar2
  ,p_char_value1            in  varchar2
  ,p_char_value2            in  varchar2
  ,p_char_value3            in  varchar2
  ,p_char_value4            in  varchar2
  ,p_number_value1          in  varchar2
  ,p_number_value2          in  varchar2
  ,p_number_value3          in  varchar2
  ,p_number_value4          in  varchar2
  ,p_date_value1            in  varchar2
  ,p_date_value2            in  varchar2
  ,p_date_value3            in  varchar2
  ,p_date_value4            in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_effective_date         in  varchar2
  ,p_owner                  in  varchar2
  ) is
--
   l_business_group_id      hr_all_organization_units.business_group_id%type;
   l_rate_matrix_node_id    pqh_rate_matrix_nodes.rate_matrix_node_id%type;
   --
   l_node_value_id          pqh_rt_matrix_node_values.node_value_id%type;
   l_ovn                    number := 1;
   l_effective_date         date;
--
--
   l_created_by              pqh_rt_matrix_node_values.created_by%TYPE;
   l_last_updated_by         pqh_rt_matrix_node_values.last_updated_by%TYPE;
   l_creation_date           pqh_rt_matrix_node_values.creation_date%TYPE;
   l_last_update_date        pqh_rt_matrix_node_values.last_update_date%TYPE;
   l_last_update_login       pqh_rt_matrix_node_values.last_update_login%TYPE;
--
--
 --
 -- rate matrix node
 --
 Cursor csr_rmn(p_code in varchar2) is
  select rate_matrix_node_id
    from pqh_rate_matrix_nodes
   Where short_code = p_code
    and business_group_id = l_business_group_id;
 --
  --
 Cursor csr_rmv is
  select node_value_id
    from pqh_rt_matrix_node_values
   Where short_code = p_short_code
    and business_group_id = l_business_group_id;
 --
Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  l_effective_date := nvl(to_date(p_effective_date,'DD/MM/YYYY'),sysdate);
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  --
  Open csr_rmn(p_node_short_code);
  Fetch csr_rmn into l_rate_matrix_node_id;
  Close csr_rmn;
  --
  Open csr_rmv;
  Fetch csr_rmv into l_node_value_id;
  Close csr_rmv;

  -- rate matrix node value exists corresponding to the short_code
  --
  If l_node_value_id is not null then

     --
     Update pqh_rt_matrix_node_values
     set
     RATE_MATRIX_NODE_ID   = l_rate_matrix_node_id,
     SHORT_CODE            = p_short_code,
     CHAR_VALUE1           = p_char_value1,
     CHAR_VALUE2           = p_char_value2,
     CHAR_VALUE3           = p_char_value3,
     CHAR_VALUE4           = p_char_value4,
     NUMBER_VALUE1         = p_number_value1,
     NUMBER_VALUE2         = p_number_value2,
     NUMBER_VALUE3         = p_number_value3,
     NUMBER_VALUE4         = p_number_value4,
     DATE_VALUE1           = to_date(p_date_value1,'DD/MM/YYYY'),
     DATE_VALUE2           = to_date(p_date_value2,'DD/MM/YYYY'),
     DATE_VALUE3           = to_date(p_date_value3,'DD/MM/YYYY'),
     DATE_VALUE4           = to_date(p_date_value4,'DD/MM/YYYY'),
     BUSINESS_GROUP_ID     = l_business_group_id,
     LEGISLATION_CODE      = p_legislation_code,
     last_updated_by       = l_last_updated_by,
     last_update_date      = l_last_update_date,
     last_update_login     = l_last_update_login
     Where node_value_id = l_node_value_id;
    --
  Else
    --
    Insert into pqh_rt_matrix_node_values
    (
    NODE_VALUE_ID                   ,
    RATE_MATRIX_NODE_ID             ,
    SHORT_CODE                      ,
    CHAR_VALUE1                     ,
    CHAR_VALUE2                     ,
    CHAR_VALUE3                     ,
    CHAR_VALUE4                     ,
    NUMBER_VALUE1                   ,
    NUMBER_VALUE2                   ,
    NUMBER_VALUE3                   ,
    NUMBER_VALUE4                   ,
    DATE_VALUE1                     ,
    DATE_VALUE2                     ,
    DATE_VALUE3                     ,
    DATE_VALUE4                     ,
    BUSINESS_GROUP_ID               ,
    LEGISLATION_CODE                ,
    CREATED_BY                      ,
    CREATION_DATE                   ,
    LAST_UPDATED_BY                 ,
    LAST_UPDATE_DATE                ,
    LAST_UPDATE_LOGIN               ,
    OBJECT_VERSION_NUMBER
    )
    Values
    (
    pqh_rt_matrix_node_values_s.nextval,
    l_rate_matrix_node_id,
    p_short_code,
    p_char_value1,
    p_char_value2,
    p_char_value3,
    p_char_value4,
    p_number_value1,
    p_number_value2,
    p_number_value3,
    p_number_value4,
    to_date(p_date_value1,'DD/MM/YYYY'),
    to_date(p_date_value2,'DD/MM/YYYY'),
    to_date(p_date_value3,'DD/MM/YYYY'),
    to_date(p_date_value4,'DD/MM/YYYY'),
    l_business_group_id,
    p_legislation_code,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login,
    l_ovn
    );

  End if;
 --
End;
--
Procedure load_rmr_row
  (p_node_short_code          in  varchar2
  ,p_crit_rt_defn_short_code  in  varchar2
  ,p_min_rate_value           in  varchar2
  ,p_max_rate_value           in  varchar2
  ,p_mid_rate_value           in  varchar2
  ,p_rate_value               in  varchar2
  ,p_legislation_code         in  varchar2
  ,p_effective_start_date     in  varchar2
  ,p_owner                    in  varchar2
  ) is

--
   l_crd_id                 pqh_criteria_rate_defn.criteria_rate_defn_id%type;
   l_crd_name               pqh_criteria_rate_defn.short_name%type;
   l_rate_matrix_node_id    pqh_rate_matrix_rates_f.rate_matrix_node_id%type;
   l_rt_matrix_rate_id      pqh_rate_matrix_rates_f.rate_matrix_rate_id%type;
   l_pl_id                  ben_pl_f.pl_id%type;
   l_pl_name                ben_pl_f.short_code%type;
   l_abr                    ben_acty_base_rt_f.acty_base_rt_id%type;
   l_ovn                    number := 1;
   l_effective_start_date   date ;
   l_effective_end_date     date ;
   l_effective_date         date;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
   l_dt_mode                varchar2(30);
--
--
   l_created_by             ben_pl_f.created_by%TYPE;
   l_last_updated_by        ben_pl_f.last_updated_by%TYPE;
   l_creation_date          ben_pl_f.creation_date%TYPE;
   l_last_update_date       ben_pl_f.last_update_date%TYPE;
   l_last_update_login      ben_pl_f.last_update_login%TYPE;
--
 -- Create a abr corresponding to Criteria rate defn in Rate matrix.
 --
 Cursor csr_plan is
 Select rate_matrix_node_id, pl_id from pqh_rate_matrix_nodes
  Where short_code = p_node_short_code
    and business_group_id = l_business_group_id;
  --
 Cursor csr_plan_name is
    select short_code
      From ben_pl_f
     Where pl_id = l_pl_id
       and l_effective_date between effective_start_date and effective_end_date
       and business_group_id = l_business_group_id;

  --
  Cursor csr_crd is
   Select criteria_rate_defn_id,short_name
     From pqh_criteria_rate_defn_vl
    Where short_name = p_crit_rt_defn_short_code
      and business_group_id = l_business_group_id;
  --
  --  Select activity base rate corresponding to the criteria rate defn in
  --  rate matrix.
  --
   Cursor csr_abr is
    select acty_base_rt_id
      From ben_acty_base_rt_f
     Where acty_typ_cd = 'RBC'
       and l_effective_date between effective_start_date and effective_end_date
       and business_group_id = l_business_group_id
       and pl_id = l_pl_id
       and mapping_table_name = 'PQH_CRITERIA_RATE_DEFN'
       and mapping_table_pk_id = l_crd_id;
  --
  Cursor csr_rmr is
   Select rate_matrix_rate_id ,object_version_number
     From pqh_rate_matrix_rates_f
    Where criteria_rate_defn_id = l_crd_id
      and rate_matrix_node_id = l_rate_matrix_node_id
      and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;

Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  Open csr_plan;
  Fetch csr_plan into l_rate_matrix_node_id, l_pl_id;
  Close csr_plan;

  Open csr_plan_name;
  Fetch csr_plan_name into l_pl_name;
  Close csr_plan_name;


  Open csr_crd;
  Fetch csr_crd into l_crd_id,l_crd_name;
  Close csr_crd;

  Open csr_rmr;
  Fetch csr_rmr into l_rt_matrix_rate_id,l_ovn;
  Close csr_rmr;

  -- No Rate matrix rate exists
  --
  If l_rt_matrix_rate_id is null then

     Open csr_abr;
     Fetch csr_abr into l_abr;
     Close csr_abr;
     --
     If l_abr is null then
        --
        BEN_ACTY_BASE_RATE_API.CREATE_ACTY_BASE_RATE(
           P_EFFECTIVE_DATE                => l_effective_date
          ,p_acty_base_rt_id               => l_abr
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
          ,P_BUSINESS_GROUP_ID             => l_business_group_id
          ,P_ACTY_BASE_RT_STAT_CD          => 'A'
          ,P_ACTY_TYP_CD                   => 'RBC'
          ,P_NAME                          => l_pl_name||' - '||l_crd_name
          ,P_PL_ID                         => l_pl_id
          ,P_RT_MLT_CD                     => 'NSVU'
          ,P_ELE_RQD_FLAG                  => 'N'
          ,P_MAPPING_TABLE_NAME            => 'PQH_CRITERIA_RATE_DEFN'
          ,P_MAPPING_TABLE_PK_ID           => l_crd_id
          ,p_object_version_number         => l_ovn
         );
        --
     End if;
     --
     /**
     l_ovn := 1;
     Insert into pqh_rate_matrix_rates_f
     (RATE_MATRIX_RATE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      RATE_MATRIX_NODE_ID,
      CRITERIA_RATE_DEFN_ID,
      MIN_RATE_VALUE,
      MAX_RATE_VALUE,
      MID_RATE_VALUE,
      RATE_VALUE,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      CREATED_BY                      ,
      CREATION_DATE                   ,
      LAST_UPDATED_BY                 ,
      LAST_UPDATE_DATE                ,
      LAST_UPDATE_LOGIN               ,
      OBJECT_VERSION_NUMBER
     )
     Values
     (pqh_rate_matrix_rates_s.nextval,
      l_effective_date,
      to_date('31/12/4712','dd/mm/yyyy'),
      l_rate_matrix_node_id,
      l_crd_id,
      p_min_rate_value,
      p_max_rate_value,
      p_mid_rate_value,
      p_rate_value,
      l_business_group_id,
      p_legislation_code,
      l_created_by,
      l_creation_date,
      l_last_updated_by,
      l_last_update_date,
      l_last_update_login,
      l_ovn);
     **/

   --
   -- Create Rate matrix Rates.
   --
   PQH_RATE_MATRIX_RATES_API.create_rate_matrix_rate(
   p_effective_date                => l_effective_date
  ,p_business_group_id             => l_business_group_id
  ,p_rate_matrix_rate_id           => l_rt_matrix_rate_id
  ,p_EFFECTIVE_START_DATE          => l_effective_start_date
  ,p_EFFECTIVE_END_DATE            => l_effective_end_date
  ,p_RATE_MATRIX_NODE_ID           => l_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => l_crd_id
  ,p_MIN_RATE_VALUE                => p_min_rate_value
  ,p_MAX_RATE_VALUE                => p_max_rate_value
  ,p_MID_RATE_VALUE                => p_mid_rate_value
  ,p_RATE_VALUE                    => p_rate_value
  ,p_object_version_number         => l_ovn
  );

  Else
    l_dt_mode := pqh_gsp_stage_to_ben.get_update_mode('PQH_RATE_MATRIX_RATES_F','RATE_MATRIX_RATE_ID', l_rt_matrix_rate_id, l_effective_date) ;

   PQH_RATE_MATRIX_RATES_API.update_rate_matrix_rate(
   p_effective_date                => l_effective_date
  ,p_business_group_id             => l_business_group_id
  ,p_rate_matrix_rate_id           => l_rt_matrix_rate_id
  ,p_EFFECTIVE_START_DATE          => l_effective_start_date
  ,p_EFFECTIVE_END_DATE            => l_effective_end_date
  ,p_RATE_MATRIX_NODE_ID           => l_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => l_crd_id
  ,p_MIN_RATE_VALUE                => p_min_rate_value
  ,p_MAX_RATE_VALUE                => p_max_rate_value
  ,p_MID_RATE_VALUE                => p_mid_rate_value
  ,p_RATE_VALUE                    => p_rate_value
  ,p_datetrack_mode                => l_dt_mode
  ,p_object_version_number         => l_ovn
  );

  End if;
 --
End;
--
--
--  ----------------------------------- Load Criteria Rate Defn -----------------------------------------
Procedure load_crd_seed_row
             (p_upload_mode             in  varchar2
             ,p_name                    in  varchar2
             ,p_short_name              in  varchar2
             ,p_uom                     in  varchar2
             ,p_currency_code           in  varchar2  default null
             ,p_reference_period_cd     in  varchar2  default null
             ,p_define_max_rate_flag    in  varchar2  default null
             ,p_define_min_rate_flag    in  varchar2  default null
             ,p_define_mid_rate_flag    in  varchar2  default null
             ,p_define_std_rate_flag    in  varchar2  default null
             ,p_rate_calc_cd            in  varchar2
             ,p_preferential_rate_cd    in  varchar2
             ,p_rounding_cd             in  varchar2  default null
             ,p_legislation_code        in  varchar2  default null
             ,p_owner                   in  varchar2  default null
) is
--
Begin
       if (p_upload_mode = 'NLS') then
        pqh_crl_upd.translate_row (
            p_short_name                => p_short_name,
            p_name                      => p_name ,
            p_owner                     => p_owner);
       else
           pqh_rbc_load_objects.load_crd_row
             (
              p_name                    => p_name
             ,p_short_name              => p_short_name
             ,p_uom                     => p_uom
             ,p_currency_code           => p_currency_code
             ,p_reference_period_cd     => p_reference_period_cd
             ,p_define_max_rate_flag    => p_define_max_rate_flag
             ,p_define_min_rate_flag    => p_define_min_rate_flag
             ,p_define_mid_rate_flag    => p_define_mid_rate_flag
             ,p_define_std_rate_flag    => p_define_std_rate_flag
             ,p_rate_calc_cd            => p_rate_calc_cd
             ,p_preferential_rate_cd    => p_preferential_rate_cd
             ,p_rounding_cd             => p_rounding_cd
             ,p_legislation_code        => p_legislation_code
             ,p_owner                   => p_owner );
      end if;

End;
--
Procedure load_crd_row
             (p_name                    in  varchar2
             ,p_short_name              in  varchar2
             ,p_uom                     in  varchar2
             ,p_currency_code           in  varchar2  default null
             ,p_reference_period_cd     in  varchar2  default null
             ,p_define_max_rate_flag    in  varchar2  default null
             ,p_define_min_rate_flag    in  varchar2  default null
             ,p_define_mid_rate_flag    in  varchar2  default null
             ,p_define_std_rate_flag    in  varchar2  default null
             ,p_rate_calc_cd            in  varchar2
             --,p_rate_calc_rule          in  varchar2  default null
             ,p_preferential_rate_cd    in  varchar2
             --,p_preferential_rate_rule  in  varchar2  default null
             ,p_rounding_cd             in  varchar2  default null
             --,p_rounding_rule           in  varchar2
             ,p_legislation_code        in  varchar2  default null
             ,p_owner                   in  varchar2  default null
) is
--
   l_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_ovn                    number := 1;
   l_effective_date         date;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
--
--
   l_created_by             pqh_criteria_rate_defn.created_by%TYPE;
   l_last_updated_by        pqh_criteria_rate_defn.last_updated_by%TYPE;
   l_creation_date          pqh_criteria_rate_defn.creation_date%TYPE;
   l_last_update_date       pqh_criteria_rate_defn.last_update_date%TYPE;
   l_last_update_login      pqh_criteria_rate_defn.last_update_login%TYPE;
--
   l_language                  varchar2(30) ;

   Cursor c1 is select userenv('LANG') from dual ;
 --
 -- Check if the criteria rate defn exists
 --
   Cursor csr_crd is
   select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_short_name
      and business_group_id = l_business_group_id;
  --
   Cursor csr_crd_seq is
   Select pqh_criteria_rate_defn_s.nextval
     From dual;
Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  open c1;
  fetch c1 into l_language ;
  close c1;
  --
  Open csr_crd;
  Fetch csr_crd into l_criteria_rate_defn_id;
  Close csr_crd;

  -- No plan exists corresponding to Rate matrix short code
  --
  If l_criteria_rate_defn_id is not null then
     Update pqh_criteria_rate_defn
        set
            short_name             = p_short_name
            ,uom                    = p_uom
            ,currency_code          = p_currency_code
            ,reference_period_cd    = p_reference_period_cd
            ,define_max_rate_flag   = p_define_max_rate_flag
            ,define_min_rate_flag   = p_define_min_rate_flag
            ,define_mid_rate_flag   = p_define_mid_rate_flag
            ,define_std_rate_flag   = p_define_std_rate_flag
            ,rate_calc_cd           = p_rate_calc_cd
            --,rate_calc_rule         = p_rate_calc_rule
            ,preferential_rate_cd   = p_preferential_rate_cd
            --,preferential_rate_rule = p_preferential_rate_rule
            ,rounding_cd            = p_rounding_cd
            --,rounding_rule          = p_rounding_rule
            ,business_group_id      = l_business_group_id
            ,legislation_code       = p_legislation_code
            ,last_updated_by        = l_last_updated_by
            ,last_update_date       = l_last_update_date
            ,last_update_login      = l_last_update_login
     Where criteria_rate_defn_id = l_criteria_rate_defn_id;

       if (sql%found) then

      UPDATE pqh_criteria_rate_defn_tl
      SET  name               =  p_name,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login,
         source_lang                    = userenv('LANG')
      WHERE criteria_rate_defn_id  =  l_criteria_rate_defn_id
        AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      If (sql%notfound) then
       -- no row in TL table so insert row

      --
      insert into pqh_criteria_rate_defn_tl
      ( criteria_rate_defn_id,
        name,
        language,
        source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_criteria_rate_defn_id,
        p_name,
        l.language_code,
        l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_criteria_rate_defn_tl crl
                  where crl.criteria_rate_defn_id = l_criteria_rate_defn_id
                  and crl.language         = l.language_code );
      --
      End if;
      --
    end if; -- sql%found for main table


  Else
    --
    Open csr_crd_seq;
    Fetch csr_crd_seq into l_criteria_rate_defn_id;
    Close csr_crd_seq;
    --
    Insert into pqh_criteria_rate_defn
            (criteria_rate_defn_id
            ,short_name
            ,uom
            ,currency_code
            ,reference_period_cd
            ,define_max_rate_flag
            ,define_min_rate_flag
            ,define_mid_rate_flag
            ,define_std_rate_flag
            ,rate_calc_cd
--            ,rate_calc_rule
            ,preferential_rate_cd
--            ,preferential_rate_rule
            ,rounding_cd
--            ,rounding_rule
            ,business_group_id
            ,legislation_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,object_version_number
            )
    Values
            (l_criteria_rate_defn_id
            ,p_short_name
            ,p_uom
            ,p_currency_code
            ,p_reference_period_cd
            ,p_define_max_rate_flag
            ,p_define_min_rate_flag
            ,p_define_mid_rate_flag
            ,p_define_std_rate_flag
            ,p_rate_calc_cd
--            ,p_rate_calc_rule
            ,p_preferential_rate_cd
--            ,p_preferential_rate_rule
            ,p_rounding_cd
--            ,p_rounding_rule
            ,l_business_group_id
            ,p_legislation_code
            ,l_created_by
            ,l_creation_date
            ,l_last_updated_by
            ,l_last_update_date
            ,l_last_update_login
            ,l_ovn
            );

        insert into pqh_criteria_rate_defn_tl
      ( criteria_rate_defn_id,
        name,
        language,
        source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_criteria_rate_defn_id,
        p_name,
        l.language_code,
        l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_criteria_rate_defn_tl crl
                  where crl.criteria_rate_defn_id = l_criteria_rate_defn_id
                  and crl.language         = l.language_code );

  End if;
 --
End load_crd_row;
--
-- Load row for new tables
--
Procedure load_crf_row
  (
   p_crit_rt_defn_short_name   in      VARCHAR2
  ,p_parent_crit_rt_def_name   in       VARCHAR2
  ,p_owner                     in      VARCHAR2
  ,p_parent_rate_matrix_code   in      VARCHAR2
  ,p_legislation_code          in      VARCHAR2
  ,p_effective_start_date      in      varchar2
) is

   l_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_parent_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_criteria_rate_factor_id  pqh_criteria_rate_factors.criteria_rate_factor_id%type ;
   l_parent_rate_matrix_id pqh_criteria_rate_factors.parent_rate_matrix_id%type ;

   l_effective_date Date;
   l_object_version_number                  number := 1;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
--
--
   l_created_by             pqh_criteria_rate_factors.created_by%TYPE;
   l_last_updated_by        pqh_criteria_rate_factors.last_updated_by%TYPE;
   l_creation_date          pqh_criteria_rate_factors.creation_date%TYPE;
   l_last_update_date       pqh_criteria_rate_factors.last_update_date%TYPE;
   l_last_update_login      pqh_criteria_rate_factors.last_update_login%TYPE;
--
   l_language                  varchar2(30) ;

   Cursor c1 is select userenv('LANG') from dual ;
 --
 -- Check if the criteria rate defn exists
 --
   Cursor csr_crd is
   select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_crit_rt_defn_short_name
      and business_group_id = l_business_group_id;
  --
   Cursor csr_crdp is
    select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_parent_crit_rt_def_name
     and business_group_id = l_business_group_id;

  Cursor csr_crf(crd_id in number,crdp_id in number)is
   select criteria_rate_factor_id from pqh_criteria_rate_factors
   where criteria_rate_defn_id = crd_id
   and parent_criteria_rate_defn_id = crdp_id
   and business_group_id = l_business_group_id;
  --
  Cursor csr_crf_seq is
   Select pqh_criteria_rate_factors_s.nextval
     From dual;

/*   Cursor csr_prm is
   select pl_id from ben_pl_f
    where short_code = p_parent_rate_matrix_code
     and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
      */

Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --

 -- l_effective_date := SYSDATE;
  l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
 -- TEST
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  Open csr_crd;
  Fetch csr_crd into l_criteria_rate_defn_id;
  Close csr_crd;

  Open csr_crdp;
  Fetch csr_crdp into l_parent_criteria_rate_defn_id;
  Close csr_crdp;

  Open csr_crf(l_criteria_rate_defn_id,l_parent_criteria_rate_defn_id);
  Fetch csr_crf into l_criteria_rate_factor_id;
  Close csr_crf;
/*
  Open csr_prm;
  Fetch csr_prm into l_parent_rate_matrix_id;
  Close csr_prm;
*/
  l_parent_rate_matrix_id := get_plan_id(p_parent_rate_matrix_code,l_effective_date,l_business_group_id);

  if(l_criteria_rate_factor_id is not null) then
 update pqh_criteria_rate_factors
    set
     criteria_rate_defn_id           = l_criteria_rate_defn_id
    ,parent_rate_matrix_id           = l_parent_rate_matrix_id
    ,parent_criteria_rate_defn_id    = l_parent_criteria_rate_defn_id
    ,business_group_id               = l_business_group_id
    ,legislation_code                = p_legislation_code
    where criteria_rate_factor_id = l_criteria_rate_factor_id;


 else
    Open csr_crf_seq;
    Fetch csr_crf_seq into l_criteria_rate_factor_id;
    Close csr_crf_seq;


    insert into pqh_criteria_rate_factors
      (criteria_rate_factor_id
      ,criteria_rate_defn_id
      ,parent_rate_matrix_id
      ,parent_criteria_rate_defn_id
      ,business_group_id
      ,legislation_code
      ,object_version_number
      )
  Values
    (l_criteria_rate_factor_id
    ,l_criteria_rate_defn_id
    ,l_parent_rate_matrix_id
    ,l_parent_criteria_rate_defn_id
    ,l_business_group_id
    ,p_legislation_code
    ,l_object_version_number
    );

 end if;

end load_crf_row;

Procedure load_rfe_row
  (p_crit_rt_defn_short_name   in      VARCHAR2
  ,p_parent_crit_rt_def_name   in      VARCHAR2
  ,p_owner                     in      VARCHAR2
  ,p_element_type_name         in      VARCHAR2
  ,p_rate_factor_val_record_tbl   in      VARCHAR2
  ,p_rate_factor_val_record_col   in      VARCHAR2
  ,p_legislation_code          in      VARCHAR2
  ,p_effective_start_date      in      VARCHAR2
) is

   l_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_parent_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_criteria_rate_factor_id  pqh_criteria_rate_factors.criteria_rate_factor_id%type ;

   l_element_type_id        pay_element_types_f.element_type_id%type;
   l_criteria_rate_element_id pqh_criteria_rate_elements.criteria_rate_element_id%type;

   l_rate_factor_on_elmnt_id pqh_rate_factor_on_elmnts.rate_factor_on_elmnt_id%TYPE;
   l_rate_factor_val_record_col pqh_rate_factor_on_elmnts.rate_factor_val_record_col%type;

   l_effective_date Date;
   l_object_version_number                  number := 1;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
--
--
   l_created_by             pqh_rate_factor_on_elmnts.created_by%TYPE;
   l_last_updated_by        pqh_rate_factor_on_elmnts.last_updated_by%TYPE;
   l_creation_date          pqh_rate_factor_on_elmnts.creation_date%TYPE;
   l_last_update_date       pqh_rate_factor_on_elmnts.last_update_date%TYPE;
   l_last_update_login      pqh_rate_factor_on_elmnts.last_update_login%TYPE;
--
   l_language                  varchar2(30) ;

   Cursor c1 is select userenv('LANG') from dual ;
 --
 -- Check if the criteria rate defn exists
 --
   Cursor csr_crd is
   select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_crit_rt_defn_short_name
      and business_group_id = l_business_group_id;
  --
   Cursor csr_crdp is
    select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_parent_crit_rt_def_name
     and business_group_id = l_business_group_id;

  Cursor csr_crf(crd_id in number,crdp_id in number)is
   select criteria_rate_factor_id from pqh_criteria_rate_factors
   where criteria_rate_defn_id = crd_id
   and parent_criteria_rate_defn_id = crdp_id
   and business_group_id = l_business_group_id;

  Cursor csr_ele is
   select element_type_id from pay_element_types_f
    where element_name = p_element_type_name
     and l_effective_date between effective_start_date and effective_end_date
     and (business_group_id = l_business_group_id OR (legislation_code in
     (select legislation_code from per_business_groups_perf where business_group_id = l_business_group_id)
     and business_group_id  is null));
    --

  Cursor csr_cre(crd_id in number,ele_id in number)is
   select criteria_rate_element_id from pqh_criteria_rate_elements
   where criteria_rate_defn_id = crd_id
   and element_type_id = ele_id
   and business_group_id = l_business_group_id;
  --

  Cursor csr_rfe(crf_id in number,cre_id in number)is
   select rate_factor_on_elmnt_id from pqh_rate_factor_on_elmnts
   where criteria_rate_factor_id = crf_id
   and criteria_rate_element_id = cre_id
   and business_group_id = l_business_group_id;
  --
/* dont store id
  Cursor csr_rel_inp is
   select input_value_id from pay_input_values_f
    where name = p_rate_factor_val_record_col
    and element_type_id = l_element_type_id
    and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
*/

  Cursor csr_rel_inp is
   select name from pay_input_values_f
    where name = p_rate_factor_val_record_col
    and element_type_id = l_element_type_id
    and l_effective_date between effective_start_date and effective_end_date;


  Cursor csr_rfe_seq is
   Select pqh_rate_factor_on_elmnts_s.nextval
     From dual;

Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
  Open csr_crd;
  Fetch csr_crd into l_criteria_rate_defn_id;
  Close csr_crd;

  Open csr_crdp;
  Fetch csr_crdp into l_parent_criteria_rate_defn_id;
  Close csr_crdp;

  Open csr_crf(l_criteria_rate_defn_id,l_parent_criteria_rate_defn_id);
  Fetch csr_crf into l_criteria_rate_factor_id;
  Close csr_crf;

  -- got l_criteria_rate_factor_id

  Open csr_ele;
  Fetch csr_ele into l_element_type_id;
  Close csr_ele;

  Open csr_cre(l_criteria_rate_defn_id,l_element_type_id);
  Fetch csr_cre into l_criteria_rate_element_id;
  Close csr_cre;

  if (LOWER(p_rate_factor_val_record_tbl) = 'pay_element_entries_f') then
     l_rate_factor_val_record_col := p_rate_factor_val_record_col;
  else
    open csr_rel_inp;
    Fetch csr_rel_inp into l_rate_factor_val_record_col;
    close csr_rel_inp;
  end if;


  open csr_rfe(l_criteria_rate_factor_id,l_criteria_rate_element_id);
  Fetch csr_rfe into l_rate_factor_on_elmnt_id;
  close csr_rfe;


  if(l_rate_factor_on_elmnt_id is not null) then
   update pqh_rate_factor_on_elmnts
    set
     rate_factor_on_elmnt_id         =l_rate_factor_on_elmnt_id
    ,criteria_rate_element_id        =l_criteria_rate_element_id
    ,criteria_rate_factor_id         =l_criteria_rate_factor_id
    ,rate_factor_val_record_tbl      =p_rate_factor_val_record_tbl
    ,rate_factor_val_record_col      =l_rate_factor_val_record_col
    ,business_group_id               =l_business_group_id
    ,legislation_code                =p_legislation_code
    where rate_factor_on_elmnt_id =l_rate_factor_on_elmnt_id;

 else
    Open csr_rfe_seq;
    Fetch csr_rfe_seq into l_rate_factor_on_elmnt_id;
    Close csr_rfe_seq;
    insert into pqh_rate_factor_on_elmnts
      (rate_factor_on_elmnt_id
      ,criteria_rate_element_id
      ,criteria_rate_factor_id
      ,rate_factor_val_record_tbl
      ,rate_factor_val_record_col
      ,business_group_id
      ,legislation_code
      ,object_version_number
      )
  Values
    (l_rate_factor_on_elmnt_id
    ,l_criteria_rate_element_id
    ,l_criteria_rate_factor_id
    ,p_rate_factor_val_record_tbl
    ,l_rate_factor_val_record_col
    ,l_business_group_id
    ,p_legislation_code
    ,l_object_version_number
    );
  end if;

end load_rfe_row;


Procedure load_cre_row
  (p_crit_rt_defn_short_name   in      VARCHAR2
  ,p_element_type_name         in      VARCHAR2
  ,p_input_value_name          in      VARCHAR2
  ,p_owner                     in      VARCHAR2
  ,p_legislation_code          in      VARCHAR2
  ,p_effective_start_date      in      VARCHAR2
) is

   l_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_element_type_id        pay_element_types_f.element_type_id%type;
   l_input_value_id         pay_input_values_f.input_value_id%type;
   l_criteria_rate_element_id pqh_criteria_rate_elements.criteria_rate_element_id%type;
   l_effective_date Date;
   l_object_version_number  number := 1;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
--
--
   l_created_by             pqh_criteria_rate_elements.created_by%TYPE;
   l_last_updated_by        pqh_criteria_rate_elements.last_updated_by%TYPE;
   l_creation_date          pqh_criteria_rate_elements.creation_date%TYPE;
   l_last_update_date       pqh_criteria_rate_elements.last_update_date%TYPE;
   l_last_update_login      pqh_criteria_rate_elements.last_update_login%TYPE;
--
   l_language                  varchar2(30) ;

  Cursor csr_crd is
   select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_crit_rt_defn_short_name
      and business_group_id = l_business_group_id;
  --

   Cursor csr_ele is
   select element_type_id from pay_element_types_f
    where element_name = p_element_type_name
    and l_effective_date between effective_start_date and effective_end_date
    and (business_group_id = l_business_group_id OR (legislation_code in
    (select legislation_code from per_business_groups_perf where business_group_id = l_business_group_id)
    and business_group_id  is null));
  --

   Cursor csr_inp is
   select input_value_id from pay_input_values_f
    where name = p_input_value_name
    and element_type_id = l_element_type_id
    and l_effective_date between effective_start_date and effective_end_date
    and (business_group_id = l_business_group_id OR (legislation_code in
    (select legislation_code from per_business_groups_perf where business_group_id = l_business_group_id)
    and business_group_id  is null));
  --

  Cursor csr_cre(crd_id in number,ele_id in number,inp_id in number)is
   select criteria_rate_element_id from pqh_criteria_rate_elements
   where criteria_rate_defn_id = crd_id
   and element_type_id = ele_id
   and input_value_id = inp_id
   and business_group_id = l_business_group_id;
  --
  Cursor csr_cre_seq is
   Select pqh_criteria_rate_elements_s.nextval
     From dual;


   Cursor c1 is select userenv('LANG') from dual ;

Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
 -- l_effective_date := SYSDATE;
  l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
-- TEST

  Open csr_crd;
  Fetch csr_crd into l_criteria_rate_defn_id;
  Close csr_crd;

  Open csr_ele;
  Fetch csr_ele into l_element_type_id;
  Close csr_ele;

  Open csr_inp;
  Fetch csr_inp into l_input_value_id;
  Close csr_inp;

  Open csr_cre(l_criteria_rate_defn_id,l_element_type_id,l_input_value_id);
  Fetch csr_cre into l_criteria_rate_element_id;
  Close csr_cre;


  if l_criteria_rate_element_id is not null then
  update pqh_criteria_rate_elements
    set
     criteria_rate_element_id        = l_criteria_rate_element_id
    ,criteria_rate_defn_id           = l_criteria_rate_defn_id
    ,element_type_id                 = l_element_type_id
    ,input_value_id                  = l_input_value_id
    ,business_group_id               = l_business_group_id
    ,legislation_code                = p_legislation_code
    ,object_version_number           = l_object_version_number
    where criteria_rate_element_id = l_criteria_rate_element_id;
  else
  Open csr_cre_seq;
  Fetch csr_cre_seq into l_criteria_rate_element_id;
  Close csr_cre_seq;

   insert into pqh_criteria_rate_elements
      (criteria_rate_element_id
      ,criteria_rate_defn_id
      ,element_type_id
      ,input_value_id
      ,business_group_id
      ,legislation_code
      ,object_version_number
      )
  Values
    (l_criteria_rate_element_id
    ,l_criteria_rate_defn_id
    ,l_element_type_id
    ,l_input_value_id
    ,l_business_group_id
    ,p_legislation_code
    ,l_object_version_number
    );
  end if;

end load_cre_row;


Procedure load_rer_row
  (
   p_crit_rt_defn_short_name   in      VARCHAR2
  ,p_element_type_name         in      VARCHAR2
  ,p_owner                     in      VARCHAR2
  ,p_relation_type_code        in      VARCHAR2
  ,p_rel_element_name          in      VARCHAR2
  ,p_rel_input_val_name        in      VARCHAR2
  ,p_legislation_code          in      VARCHAR2
  ,p_effective_start_date      in      varchar2
) is
--
   l_criteria_rate_defn_id  pqh_criteria_rate_defn.criteria_rate_defn_id%type ;
   l_element_type_id        pay_element_types_f.element_type_id%type;
   l_criteria_rate_element_id pqh_criteria_rate_elements.criteria_rate_element_id%type;
   l_rel_element_type_id        pqh_rate_element_relations.rel_element_type_id%type;
   l_rel_input_value_id         pqh_rate_element_relations.rel_input_value_id%type;
   l_relation_type_cd          pqh_rate_element_relations.relation_type_cd%type;
   l_rate_element_relation_id  pqh_rate_element_relations.rate_element_relation_id%type;
   l_effective_date Date;

   l_object_version_number  number := 1;
   l_business_group_id      hr_all_organization_units.business_group_id%type;
--
--
   l_created_by             pqh_rate_element_relations.created_by%TYPE;
   l_last_updated_by        pqh_rate_element_relations.last_updated_by%TYPE;
   l_creation_date          pqh_rate_element_relations.creation_date%TYPE;
   l_last_update_date       pqh_rate_element_relations.last_update_date%TYPE;
   l_last_update_login      pqh_rate_element_relations.last_update_login%TYPE;
--
   l_language                  varchar2(30) ;



  Cursor c1 is select userenv('LANG') from dual ;

  Cursor csr_crd is
   select criteria_rate_defn_id from pqh_criteria_rate_defn
    where short_name = p_crit_rt_defn_short_name
      and business_group_id = l_business_group_id;
  --

   Cursor csr_ele is
   select element_type_id from pay_element_types_f
    where element_name = p_element_type_name
     and l_effective_date between effective_start_date and effective_end_date
     and (business_group_id = l_business_group_id OR (legislation_code in
     (select legislation_code from per_business_groups_perf where business_group_id = l_business_group_id)
     and business_group_id  is null));
    --


  Cursor csr_cre(crd_id in number,ele_id in number)is
   select criteria_rate_element_id from pqh_criteria_rate_elements
   where criteria_rate_defn_id = crd_id
   and element_type_id = ele_id
   and business_group_id = l_business_group_id;

  --
   --
  Cursor csr_rel_ele is
   select element_type_id from pay_element_types_f
    where element_name = p_rel_element_name
     and l_effective_date between effective_start_date and effective_end_date
    and business_group_id = l_business_group_id;



   Cursor csr_rel_inp is
   select input_value_id from pay_input_values_f
    where name = p_rel_input_val_name
    and element_type_id = l_rel_element_type_id
    and l_effective_date between effective_start_date and effective_end_date
      and business_group_id = l_business_group_id;
  --


  Cursor csr_rer(cre_id in number,rel_ele in number)is
   select rate_element_relation_id from pqh_rate_element_relations
   where criteria_rate_element_id = cre_id
   and relation_type_cd = p_relation_type_code
   and rel_element_type_id = rel_ele
   and business_group_id = l_business_group_id;
  --
  --
  Cursor csr_rer_seq is
   Select pqh_rate_element_relations_s.nextval
     From dual;


Begin
 --
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);


  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
  --
 l_effective_date := nvl(to_date(p_effective_start_date,'DD/MM/YYYY'),sysdate);
-- TEST
--  l_effective_date := sysdate;

  Open csr_crd;
  Fetch csr_crd into l_criteria_rate_defn_id;
  Close csr_crd;

  Open csr_ele;
  Fetch csr_ele into l_element_type_id;
  Close csr_ele;

  Open csr_cre(l_criteria_rate_defn_id,l_element_type_id);
  Fetch csr_cre into l_criteria_rate_element_id;
  Close csr_cre;

  open csr_rel_ele;
  Fetch csr_rel_ele into l_rel_element_type_id;
  close csr_rel_ele;

  if p_rel_input_val_name is not null then

  open csr_rel_inp;
  Fetch csr_rel_inp into l_rel_input_value_id;
  Close csr_rel_inp;

  end if;

  open csr_rer(l_criteria_rate_element_id,l_rel_element_type_id);
  Fetch csr_rer into l_rate_element_relation_id;
  close csr_rer;

  if l_rate_element_relation_id is not null then

   update pqh_rate_element_relations
    set
     rate_element_relation_id        = l_rate_element_relation_id
    ,criteria_rate_element_id        = l_criteria_rate_element_id
    ,relation_type_cd                = p_relation_type_code
    ,rel_element_type_id             = l_rel_element_type_id
    ,rel_input_value_id              = l_rel_input_value_id
    ,business_group_id               = l_business_group_id
    ,legislation_code                = p_legislation_code
    where rate_element_relation_id = l_rate_element_relation_id;


  else
   Open csr_rer_seq;
    Fetch csr_rer_seq into l_rate_element_relation_id;
    Close csr_rer_seq;

    insert into pqh_rate_element_relations
      (rate_element_relation_id
      ,criteria_rate_element_id
      ,relation_type_cd
      ,rel_element_type_id
      ,rel_input_value_id
      ,business_group_id
      ,legislation_code
      ,object_version_number
      )
  Values
    (l_rate_element_relation_id
    ,l_criteria_rate_element_id
    ,p_relation_type_code
    ,l_rel_element_type_id
    ,l_rel_input_value_id
    ,l_business_group_id
    ,p_legislation_code
    ,l_object_version_number
    );


  end if;



end load_rer_row;

Procedure download_rbc(
          errbuf                     out nocopy varchar2
         ,retcode                    out nocopy number
         ,p_loader_file              in varchar2
         ,p_data_file                in varchar2
         ,p_entity                   in varchar2
         ,p_crit_rate_defn_code      in varchar2 default null
         ,p_rate_matrix_code         in varchar2 default null
         ,p_effective_date           in varchar2
         ,p_business_group_id        in number
         ,p_validate                 in  varchar2 default 'N'
       ) is
   --

   l_proc                    varchar2(72) := 'download_rbc';
   --
   l_business_group_name      varchar2(2000) := '' ;
   l_crit_defn_short_code     varchar2(2000) := '' ;
   l_rate_matrix_short_code   varchar2(2000) := '' ;
   l_effective_date           varchar2(2000) := '' ;
   l_request_id               number;
   l_validate                 varchar2(2000) ;
begin
  --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   hr_utility.set_location('p_loader_file '|| p_loader_file,10) ;
   hr_utility.set_location('p_data_file  '||  p_data_file ,10) ;
   hr_utility.set_location('p_crit_rate_defn_code '||   p_crit_rate_defn_code,10) ;
   hr_utility.set_location('p_rate_matrix_code'||p_rate_matrix_code ,10) ;
   hr_utility.set_location('p_effective_date'||p_effective_date ,10) ;
   hr_utility.set_location('p_business_group_id'||p_business_group_id ,10) ;
   hr_utility.set_location('p_validate  '|| p_validate ,10) ;
  --
  --

  savepoint SUBMIT_RBC_DOWNLOAD;
  --
  hr_utility.set_location(l_proc, 20);

  --

  If p_crit_rate_defn_code is not null then
     l_crit_defn_short_code := 'CRIT_RT_DEFN_SHORT_NAME='||p_crit_rate_defn_code;
  End if;

 If p_rate_matrix_code is not null then
     l_rate_matrix_short_code := 'PL_SHORT_CODE='||p_rate_matrix_code;
  End if;

  l_effective_date := 'EFFECTIVE_DATE='|| p_effective_date ;
  l_business_group_name := 'BG_ID='|| to_char(p_business_group_id) ;


  hr_utility.set_location('Download ',20) ;
  l_request_id := fnd_request.submit_request
                  (application => 'PQH'
                  ,program     => 'PQHRBCLD'
                  ,description => NULL
                  ,sub_request => FALSE
                  ,argument1   => 'DOWNLOAD'
                  ,argument2   => p_loader_file
                  ,argument3   => p_data_file
                  ,argument4   => p_entity
                  ,argument5   => l_crit_defn_short_code
                  ,argument6   => l_rate_matrix_short_code
                  ,argument7   => l_effective_date
                  ,argument8   => l_business_group_name

                 );
  --
  hr_utility.set_location(' Request id:'||to_char(l_request_id), 70);
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO SUBMIT_RBC_DOWNLOAD;
    raise;
    --
end download_rbc;
--
Procedure upload_rbc(
          errbuf                     out nocopy varchar2
         ,retcode                    out nocopy number
         ,p_loader_file              in varchar2
         ,p_data_file                in varchar2
         ,p_entity                   in varchar2
         ,p_crit_rate_defn_code      in varchar2 default null
         ,p_rate_matrix_code         in varchar2 default null
         ,p_validate                 in  varchar2 default 'N'
       ) is
   --

   l_proc                    varchar2(72) := 'UpLoad_rbc';
   --
   l_data_migrator_mode       varchar2(10);
   l_crit_defn_short_code     varchar2(2000) := '' ;
   l_rate_matrix_short_code   varchar2(2000) := '' ;
   l_request_id               number;
   l_validate                 varchar2(2000) ;
begin
  --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   hr_utility.set_location('p_loader_file '|| p_loader_file,10) ;
   hr_utility.set_location('p_data_file  '||  p_data_file ,10) ;
   hr_utility.set_location('p_crit_rate_defn_code '||   p_crit_rate_defn_code,10) ;
   hr_utility.set_location('p_rate_matrix_code'||p_rate_matrix_code ,10) ;
   hr_utility.set_location('p_validate  '|| p_validate ,10) ;
  --
  -- Setting g_data_migrator_mode = 'Y' , so that database triggers do not
  -- fire.
  --
  --l_data_migrator_mode := hr_general.g_data_migrator_mode ;
  --hr_general.g_data_migrator_mode := 'Y';
  --
  savepoint SUBMIT_RBC_UPLOAD;
  --
  hr_utility.set_location(l_proc, 20);
  --

  If p_crit_rate_defn_code is not null then
     l_crit_defn_short_code := 'CRIT_RT_DEFN_SHORT_NAME='||p_crit_rate_defn_code;
  End if;

 If p_rate_matrix_code is not null then
     l_rate_matrix_short_code := 'PL_SHORT_CODE='||p_rate_matrix_code;
  End if;

  hr_utility.set_location('Upload ',20) ;
  l_request_id := fnd_request.submit_request
                  (application => 'PQH'
                  ,program     => 'PQHRBCLD'
                  ,description => NULL
                  ,sub_request => FALSE
                  ,argument1   => 'UPLOAD_PARTIAL'
                  ,argument2   => p_loader_file
                  ,argument3   => p_data_file
                  ,argument4   => p_entity
                  ,argument5   => l_crit_defn_short_code
                  ,argument6   => l_rate_matrix_short_code
                 );
  --
  --
  -- Re-setting g_data_migrator_mode to its previous value
  --
  --hr_general.g_data_migrator_mode := l_data_migrator_mode;
  --
  hr_utility.set_location(' Request id:'||to_char(l_request_id), 70);
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    -- Re-setting g_data_migrator_mode to its previous value
    --
    --hr_general.g_data_migrator_mode := l_data_migrator_mode;
    --
    ROLLBACK TO SUBMIT_RBC_UPLOAD;
    raise;
    --
end upload_rbc;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- Procedure added as a fix for bug 5484366

Procedure ADD_LANGUAGE
is
begin
  delete from PQH_CRITERIA_RATE_DEFN_TL T
  where not exists
    (select NULL
    from PQH_CRITERIA_RATE_DEFN B
    where B.CRITERIA_RATE_DEFN_ID = T.CRITERIA_RATE_DEFN_ID
    );

  update PQH_CRITERIA_RATE_DEFN_TL T set (
      NAME
    ) = (select
      B.NAME
    from PQH_CRITERIA_RATE_DEFN_TL B
    where B.CRITERIA_RATE_DEFN_ID = T.CRITERIA_RATE_DEFN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CRITERIA_RATE_DEFN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CRITERIA_RATE_DEFN_ID,
      SUBT.LANGUAGE
    from PQH_CRITERIA_RATE_DEFN_TL SUBB, PQH_CRITERIA_RATE_DEFN_TL SUBT
    where SUBB.CRITERIA_RATE_DEFN_ID = SUBT.CRITERIA_RATE_DEFN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into PQH_CRITERIA_RATE_DEFN_TL (
    CRITERIA_RATE_DEFN_ID,
    NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CRITERIA_RATE_DEFN_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_CRITERIA_RATE_DEFN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_CRITERIA_RATE_DEFN_TL T
    where T.CRITERIA_RATE_DEFN_ID = B.CRITERIA_RATE_DEFN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-- --
-- --
End pqh_rbc_load_objects;

/
