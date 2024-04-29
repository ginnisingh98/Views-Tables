--------------------------------------------------------
--  DDL for Package Body BEN_DM_DOWNLOAD_DK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_DOWNLOAD_DK" AS
/* $Header: benfdmdddk.pkb 120.0 2006/05/04 04:47:10 nkkrishn noship $ */

--
--  Package Variables
--
g_package  varchar2(33) := 'ben_dm_download_dk';
--

function check_if_dk_exists(p_table_name           in VARCHAR2
                           ,p_column_name          in VARCHAR2
                           ,p_source_id            in NUMBER
                           ,p_business_group_name  in VARCHAR2) return boolean is


begin


 for i in 1..ben_dm_data_util.g_resolve_mapping_cache.count
 loop
     if ben_dm_data_util.g_resolve_mapping_cache(i).table_name = p_table_name and
        ben_dm_data_util.g_resolve_mapping_cache(i).source_id = p_source_id and
        ben_dm_data_util.g_resolve_mapping_cache(i).column_name = p_column_name and
        ben_dm_data_util.g_resolve_mapping_cache(i).business_group_name = p_business_group_name
     then
         return true;
     end if;

 end loop;

 return False;

end;

--
-- Get Dk from Cache
--

function get_dk_from_cache(p_table_name           in VARCHAR2
                           ,p_column_name          in VARCHAR2
                           ,p_source_id            in NUMBER
                           ,p_business_group_name  in VARCHAR2) return number is


begin


 for i in 1..ben_dm_data_util.g_resolve_mapping_cache.count
 loop
     if ben_dm_data_util.g_resolve_mapping_cache(i).table_name = p_table_name and
        ben_dm_data_util.g_resolve_mapping_cache(i).source_id = p_source_id and
        ben_dm_data_util.g_resolve_mapping_cache(i).column_name = p_column_name and
        ben_dm_data_util.g_resolve_mapping_cache(i).business_group_name = p_business_group_name
     then
         return ben_dm_data_util.g_resolve_mapping_cache(i).resolve_mapping_id;
     end if;
 end loop;

 return 0;

end;

--
-- DK Resolve from Table BEN_ACTL_PREM_F
--
procedure get_dk_frm_apr (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  --  cursor to Fetch the DK for BEN_ACTL_PREM_F.ACTL_PREM_ID.
  --

 cursor csr_get_dk_apr is
 select name
 from   ben_actl_prem_f apr
 where  actl_prem_id = p_source_id;

  -- Declare local variables
  l_proc                         varchar2(72) := g_package || 'get_dk_frm_apr' ;
  l_rec_inserted_cnt             number := 0;
  l_row_fetched                  boolean := FALSE;
  l_table_rec                    csr_get_dk_apr%rowtype;
  l_table_name                   varchar2(30) := 'BEN_ACTL_PREM_F';
  l_column_name                  varchar2(30) := 'ACTL_PREM_ID';
  l_resolve_mapping_id           ben_dm_resolve_mappings.resolve_mapping_id%type;

begin

  l_rec_inserted_cnt := 0;

    --
    -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table.
    -- If Not then derive it.
    --
   if not check_if_dk_exists
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name) then

    -- debug messages

    open csr_get_dk_apr;
      fetch csr_get_dk_apr into l_table_rec;
      if csr_get_dk_apr%notfound then
        close csr_get_dk_apr;
        l_row_fetched := FALSE;
      else
        l_row_fetched := TRUE;
      end if;
    close csr_get_dk_apr;

      --
      -- if no row fetched then exit the loop
      --
      if not l_row_fetched then
        -- <<RAISE Some kind of Exception>>
        null;
      else
        --
        -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
        --
        ben_dm_data_util.create_pk_mapping
        (p_resolve_mapping_id  => l_resolve_mapping_id
        ,p_table_name          => l_table_name
        ,p_column_name         => l_column_name
        ,p_source_id           => p_source_id
        ,p_source_key          => l_table_rec.name
        ,p_business_group_name => p_business_group_name);
      end if;
      --
     end if;
end;
 --
 -- DK Resolve from Table BEN_ACTN_TYP
 --
 procedure get_dk_frm_eat  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out  nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_ACTN_TYP.ACTN_TYP_ID
  --
   cursor csr_get_dk_eat is
   select name
     from ben_actn_typ
    where actn_typ_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_eat';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_eat%rowtype;
   l_table_name         varchar2(30) := 'BEN_ACTN_TYP';
   l_column_name        varchar2(30) := 'ACTN_TYP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_eat;
     fetch csr_get_dk_eat into l_table_rec;
     if csr_get_dk_eat%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_eat;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_ACTY_BASE_RT_F
 --
 procedure get_dk_frm_abr  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_ACTY_BASE_RT_F.ACTY_BASE_RT_ID
  --
   cursor csr_get_dk_abr is
   select name
     from ben_acty_base_rt_f
    where acty_base_rt_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_abr';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_abr%rowtype;
   l_table_name         varchar2(30) := 'BEN_ACTY_BASE_RT_F';
   l_column_name        varchar2(30) := 'ACTY_BASE_RT_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_abr;
     fetch csr_get_dk_abr into l_table_rec;
     if csr_get_dk_abr%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_abr;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_BENFTS_GRP
 --
 procedure get_dk_frm_bng  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_BENFTS_GRP.BENFTS_GRP_ID
  --
   cursor csr_get_dk_bng is
   select name
     from ben_benfts_grp
    where benfts_grp_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bng';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bng%rowtype;
   l_table_name         varchar2(30) := 'BEN_BENFTS_GRP';
   l_column_name        varchar2(30) := 'BENFTS_GRP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_bng;
     fetch csr_get_dk_bng into l_table_rec;
     if csr_get_dk_bng%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_bng;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_BNFTS_BAL_F
 --
 procedure get_dk_frm_bnb  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_BNFTS_BAL_F.BNFTS_BAL_ID
  --
   cursor csr_get_dk_bnb is
   select name
     from ben_bnfts_bal_f
    where bnfts_bal_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bnb';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bnb%rowtype;
   l_table_name         varchar2(30) := 'BEN_BNFTS_BAL_F';
   l_column_name        varchar2(30) := 'BNFTS_BAL_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_bnb;
     fetch csr_get_dk_bnb into l_table_rec;
     if csr_get_dk_bnb%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_bnb;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;

 --
 -- DK Resolve from Table BEN_BNFT_PRVDR_POOL_F
 --
 procedure get_dk_frm_bpp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_BNFT_PRVDR_POOL_F.BNFT_PRVDR_POOL_ID
  --
   cursor csr_get_dk_bpp is
   select name
     from ben_bnft_prvdr_pool_f
    where bnft_prvdr_pool_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bpp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bpp%rowtype;
   l_table_name         varchar2(30) := 'BEN_BNFT_PRVDR_POOL_F';
   l_column_name        varchar2(30) := 'BNFT_PRVDR_POOL_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_bpp;
     fetch csr_get_dk_bpp into l_table_rec;
     if csr_get_dk_bpp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_bpp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CMBN_PLIP_F
 --
 procedure get_dk_frm_cpl  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PLIP_F.CMBN_PLIP_ID
  --
   cursor csr_get_dk_cpl is
   select name
     from ben_cmbn_plip_f
    where cmbn_plip_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpl%rowtype;
   l_table_name         varchar2(30) := 'BEN_CMBN_PLIP_F';
   l_column_name        varchar2(30) := 'CMBN_PLIP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cpl;
     fetch csr_get_dk_cpl into l_table_rec;
     if csr_get_dk_cpl%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cpl;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CMBN_PTIP_F
 --
 procedure get_dk_frm_cbp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PTIP_F.CMBN_PTIP_ID
  --
   cursor csr_get_dk_cbp is
   select name
     from ben_cmbn_ptip_f
    where cmbn_ptip_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cbp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cbp%rowtype;
   l_table_name         varchar2(30) := 'BEN_CMBN_PTIP_F';
   l_column_name        varchar2(30) := 'CMBN_PTIP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cbp;
     fetch csr_get_dk_cbp into l_table_rec;
     if csr_get_dk_cbp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cbp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CMBN_PTIP_OPT_F
 --
 procedure get_dk_frm_cpt  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PTIP_OPT_F.CMBN_PTIP_OPT_ID
  --
   cursor csr_get_dk_cpt is
   select name
     from ben_cmbn_ptip_opt_f
    where cmbn_ptip_opt_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpt%rowtype;
   l_table_name         varchar2(30) := 'BEN_CMBN_PTIP_OPT_F';
   l_column_name        varchar2(30) := 'CMBN_PTIP_OPT_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cpt;
     fetch csr_get_dk_cpt into l_table_rec;
     if csr_get_dk_cpt%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cpt;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CM_TRGR
 --
 procedure get_dk_frm_bcr  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CM_TRGR.CM_TRGR_ID
  --
   cursor csr_get_dk_bcr is
   select cm_trgr_src_cd||cm_trgr_typ_cd||proc_cd name
     from ben_cm_trgr
    where cm_trgr_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bcr';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bcr%rowtype;
   l_table_name         varchar2(30) := 'BEN_CM_TRGR';
   l_column_name        varchar2(30) := 'CM_TRGR_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_bcr;
     fetch csr_get_dk_bcr into l_table_rec;
     if csr_get_dk_bcr%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_bcr;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CM_TYP_F
 --
 procedure get_dk_frm_cct  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CM_TYP_F.CM_TYP_ID
  --
   cursor csr_get_dk_cct is
   select name
     from ben_cm_typ_f
    where cm_typ_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cct';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cct%rowtype;
   l_table_name         varchar2(30) := 'BEN_CM_TYP_F';
   l_column_name        varchar2(30) := 'CM_TYP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cct;
     fetch csr_get_dk_cct into l_table_rec;
     if csr_get_dk_cct%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cct;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_COMP_LVL_FCTR
 --
 procedure get_dk_frm_clf  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_COMP_LVL_FCTR.COMP_LVL_FCTR_ID
  --
   cursor csr_get_dk_clf is
   select name
     from ben_comp_lvl_fctr
    where comp_lvl_fctr_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_clf';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_clf%rowtype;
   l_table_name         varchar2(30) := 'BEN_COMP_LVL_FCTR';
   l_column_name        varchar2(30) := 'COMP_LVL_FCTR_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_clf;
     fetch csr_get_dk_clf into l_table_rec;
     if csr_get_dk_clf%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_clf;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_CVG_AMT_CALC_MTHD_F
 --
 procedure get_dk_frm_ccm  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_CVG_AMT_CALC_MTHD_F.CVG_AMT_CALC_MTHD_ID
  --
   cursor csr_get_dk_ccm is
   select name
     from ben_cvg_amt_calc_mthd_f
    where cvg_amt_calc_mthd_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ccm';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ccm%rowtype;
   l_table_name         varchar2(30) := 'BEN_CVG_AMT_CALC_MTHD_F';
   l_column_name        varchar2(30) := 'CVG_AMT_CALC_MTHD_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ccm;
     fetch csr_get_dk_ccm into l_table_rec;
     if csr_get_dk_ccm%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ccm;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_ENRT_PERD
 --
 procedure get_dk_frm_enp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_ENRT_PERD.ENRT_PERD_ID
  --
   cursor csr_get_dk_enp is
   select *
     from ben_enrt_perd
    where enrt_perd_id = p_source_id;

  --
  -- cursor to Fetch the DK for POPL_ENRT_TYP_CYCL_F.POPL_ENRT_TYP_CYCL_ID
  --
   cursor csr_get_dk_pop (c_popl_enrt_typ_cycl_id number) is
   select *
     from ben_popl_enrt_typ_cycl_f
    where popl_enrt_typ_cycl_id = c_popl_enrt_typ_cycl_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_enp';
   l_row_fetched        boolean := FALSE;
   l_row_fetched_pop    boolean := FALSE;
   l_table_rec          csr_get_dk_enp%rowtype;
   l_table_rec_pop      csr_get_dk_pop%rowtype;
   l_table_name         varchar2(30) := 'BEN_ENRT_PERD';
   l_column_name        varchar2(30) := 'ENRT_PERD_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_yr_perd_id            number;
   l_popl_enrt_typ_cycl_id number;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id3 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_enp;
     fetch csr_get_dk_enp into l_table_rec;
     if csr_get_dk_enp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_enp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else

   open csr_get_dk_pop(l_table_rec.popl_enrt_typ_cycl_id);
     fetch csr_get_dk_pop into l_table_rec_pop;
     if csr_get_dk_pop%notfound then
       l_row_fetched_pop := FALSE;
     else
       l_row_fetched_pop := TRUE;
     end if;
   close csr_get_dk_pop;
   if not l_row_fetched_pop then
     -- <<RAISE Some kind of Exception>>
     null;
   else
    if l_table_rec_pop.pgm_id is not null then
     get_dk_frm_pgm (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec_pop.pgm_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id2);
    end if;
    if l_table_rec_pop.pl_id is not null then
     get_dk_frm_pln (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec_pop.pl_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id3);
    end if;
   end if;
  --
  -- Get FK data from parent tables.
  --
     get_dk_frm_yrp (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.yr_perd_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => to_char(l_table_rec.strt_dt,'dd-mm-rrrr')
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1
     ,p_resolve_mapping_id2 => l_resolve_mapping_id2
     ,p_resolve_mapping_id3 => l_resolve_mapping_id3);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_LEE_RSN_F
 --
 procedure get_dk_frm_len  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_LEE_RSN_F.LEE_RSN_ID
  --
   cursor csr_get_dk_len is
   select ler_id,
          popl_enrt_typ_cycl_id,
          effective_start_date
     from ben_lee_rsn_f
    where lee_rsn_id = p_source_id
   order by effective_start_date asc;

  --
  -- cursor to Fetch the DK for POPL_ENRT_TYP_CYCL_F.POPL_ENRT_TYP_CYCL_ID
  --
   cursor csr_get_dk_pop (c_popl_enrt_typ_cycl_id number) is
   select *
     from ben_popl_enrt_typ_cycl_f
    where popl_enrt_typ_cycl_id = c_popl_enrt_typ_cycl_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_len';
   l_row_fetched        boolean := FALSE;
   l_row_fetched_pop    boolean := FALSE;
   l_table_rec          csr_get_dk_len%rowtype;
   l_table_rec_pop      csr_get_dk_pop%rowtype;
   l_table_name         varchar2(30) := 'BEN_LEE_RSN_F';
   l_column_name        varchar2(30) := 'LEE_RSN_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id3 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_len;
     fetch csr_get_dk_len into l_table_rec;
     if csr_get_dk_len%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_len;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
     open csr_get_dk_pop(l_table_rec.popl_enrt_typ_cycl_id);
     fetch csr_get_dk_pop into l_table_rec_pop;
     if csr_get_dk_pop%notfound then
       l_row_fetched_pop := FALSE;
     else
       l_row_fetched_pop := TRUE;
     end if;
     close csr_get_dk_pop;

     if not l_row_fetched_pop then
       -- <<RAISE Some kind of Exception>>
       null;
     else
       if l_table_rec_pop.pgm_id is not null then
        get_dk_frm_pgm (p_business_group_name  => p_business_group_name
                       ,p_source_id            => l_table_rec_pop.pgm_id
                       ,p_resolve_mapping_id   => l_resolve_mapping_id2);
       end if;

       if l_table_rec_pop.pl_id is not null then
        get_dk_frm_pln (p_business_group_name  => p_business_group_name
                       ,p_source_id            => l_table_rec_pop.pl_id
                       ,p_resolve_mapping_id   => l_resolve_mapping_id3);
       end if;

       get_dk_frm_ler (p_business_group_name  => p_business_group_name
                      ,p_source_id            => l_table_rec.ler_id
                      ,p_resolve_mapping_id   => l_resolve_mapping_id1);
       ben_dm_utility.message('INFO','new ler id 0 : ' || l_table_rec.ler_id,5) ;
       ben_dm_utility.message('INFO','new ler id : ' || l_resolve_mapping_id1,5) ;
       --
       --
       -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
       --
       ben_dm_data_util.create_pk_mapping
       (p_resolve_mapping_id  => l_resolve_mapping_id
       ,p_table_name          => l_table_name
       ,p_column_name         => l_column_name
       ,p_source_id           => p_source_id
       ,p_source_key          => to_char(l_table_rec.effective_start_date,'dd-mm-rrrr')
       ,p_mapping_type        => 'P'
       ,p_resolve_mapping_id1 => l_resolve_mapping_id1
       ,p_resolve_mapping_id2 => l_resolve_mapping_id2
       ,p_resolve_mapping_id3 => l_resolve_mapping_id3
       ,p_business_group_name => p_business_group_name);
     end if;
     --
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_LER_F
 --
 procedure get_dk_frm_ler  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_LER_F.LER_ID
  --
   cursor csr_get_dk_ler is
   select name
     from ben_ler_f
    where ler_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ler';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ler%rowtype;
   l_table_name         varchar2(30) := 'BEN_LER_F';
   l_column_name        varchar2(30) := 'LER_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ler;
     fetch csr_get_dk_ler into l_table_rec;
     if csr_get_dk_ler%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ler;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);

     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
   else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_OIPLIP_F
 --
 procedure get_dk_frm_boi  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_OIPLIP_F.OIPLIP_ID
  --
   cursor csr_get_dk_boi is
   select *
     from ben_oiplip_f
    where oiplip_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_boi';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_boi%rowtype;
   l_table_name         varchar2(30) := 'BEN_OIPLIP_F';
   l_column_name        varchar2(30) := 'OIPLIP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_oipl_id             number;
   l_plip_id             number;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_boi;
     fetch csr_get_dk_boi into l_table_rec;
     if csr_get_dk_boi%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_boi;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else

  --
  -- Get FK data from parent tables.
  --
     get_dk_frm_cop (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.oipl_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);

     get_dk_frm_cpp (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.plip_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id2);
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.oiplip_id
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1
     ,p_resolve_mapping_id2 => l_resolve_mapping_id2);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_OIPL_F
 --
 procedure get_dk_frm_cop  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_OIPL_F.OIPL
  --
   cursor csr_get_dk_cop is
   select *
     from ben_oipl_f
    where oipl_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cop';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cop%rowtype;
   l_table_name         varchar2(30) := 'BEN_OIPL_F';
   l_column_name        varchar2(30) := 'OIPL_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_opt_id             number;
   l_pl_id              number;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

    -- debug messages

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cop;
     fetch csr_get_dk_cop into l_table_rec;
     if csr_get_dk_cop%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cop;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else

  --
  -- Get FK data from parent tables.
  --


     get_dk_frm_pln (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.pl_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);


     get_dk_frm_opt (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.opt_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id2);

  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.oipl_id
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1
     ,p_resolve_mapping_id2 => l_resolve_mapping_id2);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
  else
      p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_OPT_F
 --
 procedure get_dk_frm_opt  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_OPT_F.OPT_ID
  --
   cursor csr_get_dk_opt is
   select name
     from ben_opt_f
    where opt_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_opt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_opt%rowtype;
   l_table_name         varchar2(30) := 'BEN_OPT_F';
   l_column_name        varchar2(30) := 'OPT_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_opt;
     fetch csr_get_dk_opt into l_table_rec;
     if csr_get_dk_opt%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_opt;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
   else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_PGM_F
 --
 procedure get_dk_frm_pgm  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_PGM_F.PGM_ID
  --
   cursor csr_get_dk_pgm is
   select name
     from ben_pgm_f
    where pgm_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pgm';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pgm%rowtype;
   l_table_name         varchar2(30) := 'BEN_PGM_F';
   l_column_name        varchar2(30) := 'PGM_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_pgm;
     fetch csr_get_dk_pgm into l_table_rec;
     if csr_get_dk_pgm%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_pgm;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
   else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_PLIP_F
 --
 procedure get_dk_frm_cpp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_PLIP_F.PLIP_ID
  --
   cursor csr_get_dk_cpp is
   select *
     from ben_plip_f
    where plip_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpp%rowtype;
   l_table_name         varchar2(30) := 'BEN_PLIP_F';
   l_column_name        varchar2(30) := 'PLIP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_pgm_id             number;
   l_pl_id              number;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_cpp;
     fetch csr_get_dk_cpp into l_table_rec;
     if csr_get_dk_cpp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_cpp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else

  --
  -- Seed DK data From Parent tables.
  --
     get_dk_frm_pgm (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.pgm_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);

     get_dk_frm_pln (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.pl_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id2);

  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.plip_id
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1
     ,p_resolve_mapping_id2 => l_resolve_mapping_id2);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
   else
        p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_PL_F
 --
 procedure get_dk_frm_pln  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_PL_F.PL_ID
  --
   cursor csr_get_dk_pln is
   select name
     from ben_pl_f
    where pl_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pln';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pln%rowtype;
   l_table_name         varchar2(30) := 'BEN_PL_F';
   l_column_name        varchar2(30) := 'PL_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_pln;
     fetch csr_get_dk_pln into l_table_rec;
     if csr_get_dk_pln%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_pln;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
    p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
  else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_PL_TYP_F
 --
 procedure get_dk_frm_ptp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_PL_TYP_F.PL_TYP_ID
  --
   cursor csr_get_dk_ptp is
   select name
     from ben_pl_typ_f
    where pl_typ_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ptp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ptp%rowtype;
   l_table_name         varchar2(30) := 'BEN_PL_TYP_F';
   l_column_name        varchar2(30) := 'PL_TYP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ptp;
     fetch csr_get_dk_ptp into l_table_rec;
     if csr_get_dk_ptp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ptp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
      p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
  else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table BEN_PTIP_F
 --
 procedure get_dk_frm_ctp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_PTIP_F.PTIP_ID
  --
   cursor csr_get_dk_ctp is
   select *
     from ben_ptip_f
    where ptip_id = p_source_id;

--    select 'dk' name

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ctp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ctp%rowtype;
   l_table_name         varchar2(30) := 'BEN_PTIP_F';
   l_column_name        varchar2(30) := 'PTIP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_pgm_id             number;
   l_pl_typ_id          number;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id2 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ctp;
     fetch csr_get_dk_ctp into l_table_rec;
     if csr_get_dk_ctp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ctp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else

     get_dk_frm_pgm (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.pgm_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);

     get_dk_frm_ptp (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.pl_typ_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id2);
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.ptip_id
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1
     ,p_resolve_mapping_id2 => l_resolve_mapping_id2);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table BEN_YR_PERD
 --
 procedure get_dk_frm_yrp  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for BEN_YR_PERD.YR_PERD_ID
  --
   cursor csr_get_dk_yrp is
   select to_char(END_DATE,'YYYYMMDD:HH24:mi:ss')||'-'||to_char(START_DATE,'DD-MON-YYYY')||'-'||PERD_TYP_CD name
     from ben_yr_perd
    where yr_perd_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_yrp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_yrp%rowtype;
   l_table_name         varchar2(30) := 'BEN_YR_PERD';
   l_column_name        varchar2(30) := 'YR_PERD_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_yrp;
     fetch csr_get_dk_yrp into l_table_rec;
     if csr_get_dk_yrp%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_yrp;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
  else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);
  end if;
 end;
 --
 -- DK Resolve from Table FF_FORMULAS_F
 --
 procedure get_dk_frm_fra  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for FF_FORMULAS_F.FORMULA_ID
  --
   cursor csr_get_dk_fra is
   select formula_name
     from ff_formulas_f
    where formula_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fra';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fra%rowtype;
   l_table_name         varchar2(30) := 'FF_FORMULAS_F';
   l_column_name        varchar2(30) := 'FORMULA_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_fra;
     fetch csr_get_dk_fra into l_table_rec;
     if csr_get_dk_fra%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_fra;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.formula_name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table FND_ID_FLEX_STRUCTURES_VL
 --
 procedure get_dk_frm_fit  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for FND_ID_FLEX_STRUCTURES_VL.ID_FLEX_NUM
  --
   cursor csr_get_dk_fit is
   select id_flex_structure_name
     from fnd_id_flex_structures_vl
    where id_flex_num = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fit';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fit%rowtype;
   l_table_name         varchar2(30) := 'FND_ID_FLEX_STRUCTURES_VL';
   l_column_name        varchar2(30) := 'ID_FLEX_NUM';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_fit;
     fetch csr_get_dk_fit into l_table_rec;
     if csr_get_dk_fit%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_fit;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.id_flex_structure_name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table FND_USER
 --
 procedure get_dk_frm_fus  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for FND_USER.USER_ID
  --
   cursor csr_get_dk_fus is
   select user_name
     from fnd_user
    where user_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fus';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fus%rowtype;
   l_table_name         varchar2(30) := 'FND_USER';
   l_column_name        varchar2(30) := 'USER_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_fus;
     fetch csr_get_dk_fus into l_table_rec;
     if csr_get_dk_fus%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_fus;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.user_name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table HR_ALL_ORGANIZATION_UNITS
 --
 procedure get_dk_frm_aou  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID
  --
   cursor csr_get_dk_aou is
   select name, business_group_id
     from hr_all_organization_units
    where organization_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aou';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aou%rowtype;
   l_table_name         varchar2(30) := 'HR_ALL_ORGANIZATION_UNITS';
   l_column_name        varchar2(30) := 'ORGANIZATION_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_aou;
     fetch csr_get_dk_aou into l_table_rec;
     if csr_get_dk_aou%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_aou;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
  -- when the business_group_id and organization id is the same
  -- assign target bg name into  source key
     if  l_table_rec.business_group_id  = p_source_id then
         l_table_rec.name := p_business_group_name ;
     end if ;

     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table HR_ALL_ORGANIZATION_UNITS - FOR BG ONLY
 -- Special
 procedure get_dk_frm_ori (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ori';
   l_table_name         varchar2(30) := 'HR_ORGANIZATION_INFORMATION';
   l_column_name        varchar2(30) := 'ORGANIZATION_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => p_business_group_name
     ,p_business_group_name => p_business_group_name);
   --
 end;
 --
 -- DK Resolve from Table HR_LOCATIONS_ALL
 --
 procedure get_dk_frm_loc  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for HR_LOCATIONS_ALL.LOCATION_ID
  --
   cursor csr_get_dk_loc is
   select location_code
     from hr_locations_all
    where location_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_loc';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_loc%rowtype;
   l_table_name         varchar2(30) := 'HR_LOCATIONS_ALL';
   l_column_name        varchar2(30) := 'LOCATION_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_loc;
     fetch csr_get_dk_loc into l_table_rec;
     if csr_get_dk_loc%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_loc;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.location_code
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PAY_ALL_PAYROLLS_F
 --
 procedure get_dk_frm_prl  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PAY_ALL_PAYROLLS_F.PAYROLL_ID
  --
   cursor csr_get_dk_prl is
   select payroll_name
     from pay_all_payrolls_f
    where payroll_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_prl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_prl%rowtype;
   l_table_name         varchar2(30) := 'PAY_ALL_PAYROLLS_F';
   l_column_name        varchar2(30) := 'PAYROLL_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_prl;
     fetch csr_get_dk_prl into l_table_rec;
     if csr_get_dk_prl%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_prl;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.payroll_name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PAY_ELEMENT_TYPES_F
 --
 procedure get_dk_frm_pet  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID
  --
   cursor csr_get_dk_pet is
   select element_name
     from pay_element_types_f
    where element_type_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pet';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pet%rowtype;
   l_table_name         varchar2(30) := 'PAY_ELEMENT_TYPES_F';
   l_column_name        varchar2(30) := 'ELEMENT_TYPE_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_pet;
     fetch csr_get_dk_pet into l_table_rec;
     if csr_get_dk_pet%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_pet;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.element_name
     ,p_business_group_name => p_business_group_name);
     p_resolve_mapping_id := l_resolve_mapping_id;
   end if;
   --
  else
       p_resolve_mapping_id := get_dk_from_cache
        (p_table_name           => l_table_name
        ,p_column_name          => l_column_name
        ,p_source_id            => p_source_id
        ,p_business_group_name  => p_business_group_name);

  end if;
 end;
 --
 -- DK Resolve from Table PAY_INPUT_VALUES_F
 --
 procedure get_dk_frm_ipv  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PAY_INPUT_VALUES_F.INPUT_VALUE_ID
  --
   cursor csr_get_dk_ipv is
   select *
     from pay_input_values_f
    where input_value_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ipv';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ipv%rowtype;
   l_table_name         varchar2(30) := 'PAY_INPUT_VALUES_F';
   l_column_name        varchar2(30) := 'INPUT_VALUE_ID';
   l_element_type_id     number;
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ipv;
     fetch csr_get_dk_ipv into l_table_rec;
     if csr_get_dk_ipv%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ipv;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
     get_dk_frm_pet (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.element_type_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);

  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PAY_ELEMENT_LINKS_F
 --
 procedure get_dk_frm_pll  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PAY_ELEMENT_LINKS_F.ELEMENT_LINK_ID
  --
   cursor csr_get_dk_pll is
   select *
     from pay_element_links_f
    where element_link_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pll';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pll%rowtype;
   l_table_name         varchar2(30) := 'PAY_ELEMENT_LINKS_F';
   l_column_name        varchar2(30) := 'ELEMENT_LINK_ID';
   l_element_type_id     number;
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_pll;
     fetch csr_get_dk_pll into l_table_rec;
     if csr_get_dk_pll%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_pll;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
     get_dk_frm_pet (p_business_group_name  => p_business_group_name
                    ,p_source_id            => l_table_rec.element_type_id
                    ,p_resolve_mapping_id   => l_resolve_mapping_id1);

  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => '-1'
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_ASSIGNMENT_STATUS_TYPES
 --
 procedure get_dk_frm_ast  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_ASSIGNMENT_STATUS_TYPES.ASSIGNMENT_STATUS_TYPE_ID
  --
   cursor csr_get_dk_ast is
   select user_status||'-'||nvl(legislation_code,'-x')||'-'||decode(business_group_id, null,'N','Y') status
     from per_assignment_status_types
    where assignment_status_type_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ast';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ast%rowtype;
   l_table_name         varchar2(30) := 'PER_ASSIGNMENT_STATUS_TYPES';
   l_column_name        varchar2(30) := 'ASSIGNMENT_STATUS_TYPE_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_ast;
     fetch csr_get_dk_ast into l_table_rec;
     if csr_get_dk_ast%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_ast;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.status
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_GRADES
 --
 procedure get_dk_frm_gra  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_GRADES.GRADE_ID
  --
   cursor csr_get_dk_gra is
   select name
     from per_grades
    where grade_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_gra';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_gra%rowtype;
   l_table_name         varchar2(30) := 'PER_GRADES';
   l_column_name        varchar2(30) := 'GRADE_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_gra;
     fetch csr_get_dk_gra into l_table_rec;
     if csr_get_dk_gra%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_gra;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_JOBS
 --
 procedure get_dk_frm_job  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_JOBS.JOB_ID
  --
   cursor csr_get_dk_job is
   select name
     from per_jobs
    where job_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_job';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_job%rowtype;
   l_table_name         varchar2(30) := 'PER_JOBS';
   l_column_name        varchar2(30) := 'JOB_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_job;
     fetch csr_get_dk_job into l_table_rec;
     if csr_get_dk_job%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_job;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_PAY_BASES
 --
 procedure get_dk_frm_pyb  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_PAY_BASES.PAY_BASIS_ID
  --
   cursor csr_get_dk_pyb is
   select name
     from per_pay_bases
    where pay_basis_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pyb';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pyb%rowtype;
   l_table_name         varchar2(30) := 'PER_PAY_BASES';
   l_column_name        varchar2(30) := 'PAY_BASIS_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_pyb;
     fetch csr_get_dk_pyb into l_table_rec;
     if csr_get_dk_pyb%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_pyb;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_PERSON_TYPES
 --
 procedure get_dk_frm_prt  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_PERSON_TYPES.PERSON_TYPE_ID
  --
   cursor csr_get_dk_prt is
   select user_person_type
     from per_person_types
    where person_type_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_prt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_prt%rowtype;
   l_table_name         varchar2(30) := 'PER_PERSON_TYPES';
   l_column_name        varchar2(30) := 'PERSON_TYPE_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_prt;
     fetch csr_get_dk_prt into l_table_rec;
     if csr_get_dk_prt%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_prt;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.user_person_type
     ,p_business_group_name => p_business_group_name);
   end if;
   --
  end if;
 end;
 --
 -- DK Resolve from Table PER_ABSENCE_ATTENDANCE_TYPES
 --
 procedure get_dk_frm_aat  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_ABSENCE_ATTENDANCE_TYPES.ABSENCE_ATTENDANCE_TYPE_ID
  --
   cursor csr_get_dk_aat is
   select name
     from per_absence_attendance_types
    where absence_attendance_type_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aat';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aat%rowtype;
   l_table_name         varchar2(30) := 'PER_ABSENCE_ATTENDANCE_TYPES';
   l_column_name        varchar2(30) := 'ABSENCE_ATTENDANCE_TYPE_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_aat;
     fetch csr_get_dk_aat into l_table_rec;
     if csr_get_dk_aat%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_aat;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name);
     --
     p_resolve_mapping_id := l_resolve_mapping_id;
     --
   end if;
   --
  else
    --
    p_resolve_mapping_id := get_dk_from_cache
      (p_table_name           => l_table_name
      ,p_column_name          => l_column_name
      ,p_source_id            => p_source_id
      ,p_business_group_name  => p_business_group_name);
    --
  end if;
 end;
 --
 -- DK Resolve from Table PER_ABS_ATTENDANCE_REASONS
 --
 procedure get_dk_frm_aar  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PER_ABS_ATTENDANCE_REASONS.ABS_ATTENDANCE_REASON_ID
  --
   cursor csr_get_dk_aar is
   select *
     from per_abs_attendance_reasons
    where abs_attendance_reason_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aar';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aar%rowtype;
   l_table_name         varchar2(30) := 'PER_ABS_ATTENDANCE_REASONS';
   l_column_name        varchar2(30) := 'ABS_ATTENDANCE_REASON_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_resolve_mapping_id1 ben_dm_resolve_mappings.resolve_mapping_id%type;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_aar;
     fetch csr_get_dk_aar into l_table_rec;
     if csr_get_dk_aar%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_aar;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
     --
     get_dk_frm_aat(p_business_group_name  => p_business_group_name
                   ,p_source_id            => l_table_rec.absence_attendance_type_id
                   ,p_resolve_mapping_id   => l_resolve_mapping_id1);
     --
     -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
     --
     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => l_table_rec.name
     ,p_business_group_name => p_business_group_name
     ,p_mapping_type        => 'P'
     ,p_resolve_mapping_id1 => l_resolve_mapping_id1);
     --
   end if;
   --
  end if;
 end;
--
 --
 -- DK Resolve from Table HR_SOFT_CODING_KEYFLEX
 --
 procedure get_dk_frm_scl  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for HR_SOFT_CODING_KEYFLEX
  --
   cursor csr_get_dk_scl is
   select *
     from hr_soft_coding_keyflex
    where soft_coding_keyflex_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_scl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_scl%rowtype;
   l_table_name         varchar2(30) := 'HR_SOFT_CODING_KEYFLEX';
   l_column_name        varchar2(30) := 'SOFT_CODING_KEYFLEX_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_migration_id       number;
   l_result_id          number;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_scl;
     fetch csr_get_dk_scl into l_table_rec;
     if csr_get_dk_scl%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_scl;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --

   select max(migration_id)
     into l_migration_id
     from ben_dm_migrations;

   ben_dm_data_util.create_entity_result(
    p_entity_result_id =>  l_result_id
   ,p_migration_id     =>  l_migration_id
   ,p_table_name       =>  l_table_name
   ,p_group_order      =>  0
   ,P_INFORMATION131   => l_table_rec.SOFT_CODING_KEYFLEX_ID
   ,P_INFORMATION1     => l_table_rec.CONCATENATED_SEGMENTS
   ,P_INFORMATION132   => l_table_rec.ID_FLEX_NUM
   ,P_INFORMATION2     => l_table_rec.SUMMARY_FLAG
   ,P_INFORMATION3     => l_table_rec.ENABLED_FLAG
   ,P_INFORMATION211   => l_table_rec.START_DATE_ACTIVE
   ,P_INFORMATION212   => l_table_rec.END_DATE_ACTIVE
   ,P_INFORMATION4     => l_table_rec.SEGMENT1
   ,P_INFORMATION5     => l_table_rec.SEGMENT2
   ,P_INFORMATION6     => l_table_rec.SEGMENT3
   ,P_INFORMATION7     => l_table_rec.SEGMENT4
   ,P_INFORMATION8     => l_table_rec.SEGMENT5
   ,P_INFORMATION9     => l_table_rec.SEGMENT6
   ,P_INFORMATION10    => l_table_rec.SEGMENT7
   ,P_INFORMATION11    => l_table_rec.SEGMENT8
   ,P_INFORMATION12    => l_table_rec.SEGMENT9
   ,P_INFORMATION13    => l_table_rec.SEGMENT10
   ,P_INFORMATION14    => l_table_rec.SEGMENT11
   ,P_INFORMATION15    => l_table_rec.SEGMENT12
   ,P_INFORMATION16    => l_table_rec.SEGMENT13
   ,P_INFORMATION17    => l_table_rec.SEGMENT14
   ,P_INFORMATION18    => l_table_rec.SEGMENT15
   ,P_INFORMATION19    => l_table_rec.SEGMENT16
   ,P_INFORMATION20    => l_table_rec.SEGMENT17
   ,P_INFORMATION21    => l_table_rec.SEGMENT18
   ,P_INFORMATION22    => l_table_rec.SEGMENT19
   ,P_INFORMATION23    => l_table_rec.SEGMENT20
   ,P_INFORMATION24    => l_table_rec.SEGMENT21
   ,P_INFORMATION25    => l_table_rec.SEGMENT22
   ,P_INFORMATION26    => l_table_rec.SEGMENT23
   ,P_INFORMATION27    => l_table_rec.SEGMENT24
   ,P_INFORMATION28    => l_table_rec.SEGMENT25
   ,P_INFORMATION29    => l_table_rec.SEGMENT26
   ,P_INFORMATION30    => l_table_rec.SEGMENT27
   ,P_INFORMATION31    => l_table_rec.SEGMENT28
   ,P_INFORMATION32    => l_table_rec.SEGMENT29
   ,P_INFORMATION33    => l_table_rec.SEGMENT30
   ,P_INFORMATION213   => l_table_rec.LAST_UPDATE_DATE
   ,P_INFORMATION133   => l_table_rec.LAST_UPDATED_BY
   ,P_INFORMATION134   => l_table_rec.LAST_UPDATE_LOGIN
   ,P_INFORMATION135   => l_table_rec.CREATED_BY
   ,P_INFORMATION214   => l_table_rec.CREATION_DATE);

     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => 'DK'
     ,p_resolve_mapping_id1 => l_result_id
     ,p_business_group_name => p_business_group_name);

   end if;
   --
  end if;
 end;

 --
 -- DK Resolve from Table PAY_PEOPLE_GROUPS
 --
 procedure get_dk_frm_peg  (p_business_group_name in VARCHAR2
                           ,p_source_id           in NUMBER
                           ,p_resolve_mapping_id out nocopy NUMBER) is
  --
  -- cursor to Fetch the DK for PAY_PEOPLE_GROUPS
  --
   cursor csr_get_dk_peg is
   select *
     from pay_people_groups
    where people_group_id = p_source_id;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_peg';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_peg%rowtype;
   l_table_name         varchar2(30) := 'PAY_PEOPLE_GROUPS';
   l_column_name        varchar2(30) := 'PEOPLE_GROUP_ID';
   l_resolve_mapping_id ben_dm_resolve_mappings.resolve_mapping_id%type;
   l_migration_id       number;
   l_result_id          number;

 begin

  --
  -- Check to see if this developer key already exists in the BEN_DM_DEVELOPER_KEYS table
  -- If Not then derive it.
  --
  if not check_if_dk_exists
     (p_table_name           => l_table_name
     ,p_column_name          => l_column_name
     ,p_source_id            => p_source_id
     ,p_business_group_name  => p_business_group_name) then

  -- debug messages
   open csr_get_dk_peg;
     fetch csr_get_dk_peg into l_table_rec;
     if csr_get_dk_peg%notfound then
       l_row_fetched := FALSE;
     else
       l_row_fetched := TRUE;
     end if;
   close csr_get_dk_peg;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Seed DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --

   select max(migration_id)
     into l_migration_id
     from ben_dm_migrations;

   ben_dm_data_util.create_entity_result(
    p_entity_result_id =>  l_result_id
   ,p_migration_id     =>  l_migration_id
   ,p_table_name       =>  l_table_name
   ,p_group_order      =>  0
   ,P_INFORMATION132   => l_table_rec.PEOPLE_GROUP_ID
   ,P_INFORMATION1     => l_table_rec.GROUP_NAME
   ,P_INFORMATION131   => l_table_rec.ID_FLEX_NUM
   ,P_INFORMATION2     => l_table_rec.SUMMARY_FLAG
   ,P_INFORMATION3     => l_table_rec.ENABLED_FLAG
   ,P_INFORMATION211   => l_table_rec.START_DATE_ACTIVE
   ,P_INFORMATION212   => l_table_rec.END_DATE_ACTIVE
   ,P_INFORMATION4     => l_table_rec.SEGMENT1
   ,P_INFORMATION5     => l_table_rec.SEGMENT2
   ,P_INFORMATION6     => l_table_rec.SEGMENT3
   ,P_INFORMATION7     => l_table_rec.SEGMENT4
   ,P_INFORMATION8     => l_table_rec.SEGMENT5
   ,P_INFORMATION9     => l_table_rec.SEGMENT6
   ,P_INFORMATION10    => l_table_rec.SEGMENT7
   ,P_INFORMATION11    => l_table_rec.SEGMENT8
   ,P_INFORMATION12    => l_table_rec.SEGMENT9
   ,P_INFORMATION13    => l_table_rec.SEGMENT10
   ,P_INFORMATION14    => l_table_rec.SEGMENT11
   ,P_INFORMATION15    => l_table_rec.SEGMENT12
   ,P_INFORMATION16    => l_table_rec.SEGMENT13
   ,P_INFORMATION17    => l_table_rec.SEGMENT14
   ,P_INFORMATION18    => l_table_rec.SEGMENT15
   ,P_INFORMATION19    => l_table_rec.SEGMENT16
   ,P_INFORMATION20    => l_table_rec.SEGMENT17
   ,P_INFORMATION21    => l_table_rec.SEGMENT18
   ,P_INFORMATION22    => l_table_rec.SEGMENT19
   ,P_INFORMATION23    => l_table_rec.SEGMENT20
   ,P_INFORMATION24    => l_table_rec.SEGMENT21
   ,P_INFORMATION25    => l_table_rec.SEGMENT22
   ,P_INFORMATION26    => l_table_rec.SEGMENT23
   ,P_INFORMATION27    => l_table_rec.SEGMENT24
   ,P_INFORMATION28    => l_table_rec.SEGMENT25
   ,P_INFORMATION29    => l_table_rec.SEGMENT26
   ,P_INFORMATION30    => l_table_rec.SEGMENT27
   ,P_INFORMATION31    => l_table_rec.SEGMENT28
   ,P_INFORMATION32    => l_table_rec.SEGMENT29
   ,P_INFORMATION33    => l_table_rec.SEGMENT30
   ,P_INFORMATION213   => l_table_rec.LAST_UPDATE_DATE
   ,P_INFORMATION133   => l_table_rec.LAST_UPDATED_BY
   ,P_INFORMATION134   => l_table_rec.LAST_UPDATE_LOGIN
   ,P_INFORMATION135   => l_table_rec.CREATED_BY
   ,P_INFORMATION214   => l_table_rec.CREATION_DATE);

     ben_dm_data_util.create_pk_mapping
     (p_resolve_mapping_id  => l_resolve_mapping_id
     ,p_table_name          => l_table_name
     ,p_column_name         => l_column_name
     ,p_source_id           => p_source_id
     ,p_source_key          => 'DK'
     ,p_resolve_mapping_id1 => l_result_id
     ,p_business_group_name => p_business_group_name);

   end if;
   --
  end if;
 end;

--

end ben_dm_download_dk;

/
