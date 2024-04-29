--------------------------------------------------------
--  DDL for Package Body BEN_DM_UPLOAD_DK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_UPLOAD_DK" AS
/* $Header: benfdmuddk.pkb 120.0 2006/05/04 04:52:15 nkkrishn noship $ */

--
--  Package Variables
--
g_package  varchar2(33) := 'ben_dm_upload_dk.';

--
-- Function to get target ID for given resolve mapping id.
--
function get_target_id_for_mapping(p_resolve_mapping_id           in NUMBER)
                                  return NUMBER is

l_target_id number;

begin

  select target_id
   into l_target_id
   from  ben_dm_resolve_mappings
   where resolve_mapping_id = p_resolve_mapping_id;

  return l_target_id;

end;

--
-- DK Resolve for Table BEN_ACTL_PREM_F
--
procedure get_dk_frm_apr is

  --
  --  cursor to Fetch the DK for BEN_ACTL_PREM_F.ACTL_PREM_ID.
  --

 cursor csr_get_dk_apr (c_business_group_id number, c_source_key varchar2) is
 select actl_prem_id
 from   ben_actl_prem_f apr
 where  business_group_id = c_business_group_id
   and  name = c_source_key;

 cursor csr_get_all_apr is
 select *
   from ben_dm_resolve_mappings cm
  where table_name = 'BEN_ACTL_PREM_F'
    and target_id is null;

  -- Declare local variables
  l_proc                         varchar2(72) := g_package || 'get_dk_frm_apr' ;
  l_row_fetched                  boolean := FALSE;
  l_table_rec                    csr_get_dk_apr%rowtype;
  l_table_rec_all                csr_get_all_apr%rowtype;
  l_bg_id                        number;

begin
    --
    -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_ACTL_PREM_F.
    --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_apr loop

     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);

    open csr_get_dk_apr(c_source_key => x.source_key
                       ,c_business_group_id => l_bg_id);
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
        -- ben_dm_utility.message('PARA','(p_dk_apr  - '  || l_table_rec.name  ||')', 10);
        ben_dm_data_util.update_pk_mapping
        (p_resolve_mapping_id  => x.resolve_mapping_id
        ,p_target_id           => l_table_rec.actl_prem_id);
      end if;
      --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;

end;
 --
 -- DK Resolve For Table BEN_ACTN_TYP
 --
 procedure get_dk_frm_eat is
  --
  -- cursor to Fetch the DK for BEN_ACTN_TYP.ACTN_TYP_ID
  --
   cursor csr_get_dk_eat (c_business_group_id number, c_source_key varchar2) is
   select actn_typ_id
     from ben_actn_typ
    where name = c_source_key
     and   business_group_id = c_business_group_id
      ;

   cursor csr_get_all_eat is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_ACTN_TYP'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_eat';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_eat%rowtype;
   l_table_rec_all      csr_get_all_eat%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_ACTN_TYP
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_eat loop

     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
     ben_dm_utility.message('INFO','bg  : ' || l_bg_id,5) ;
         open csr_get_dk_eat (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_utility.message('INFO','target   : ' || l_table_rec.actn_typ_id,5) ;
     ben_dm_utility.message('INFO','mapping   : ' || x.resolve_mapping_id,5) ;


     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.actn_typ_id);

   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
 --
 -- DK Resolve For Table BEN_ACTY_BASE_RT_F
 --
 procedure get_dk_frm_abr is
  --
  -- cursor to Fetch the DK for BEN_ACTY_BASE_RT_F.ACTY_BASE_RT_ID
  --
   cursor csr_get_dk_abr (c_business_group_id number, c_source_key varchar2) is
   select acty_base_rt_id
     from ben_acty_base_rt_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_abr is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_ACTY_BASE_RT_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_abr';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_abr%rowtype;
   l_table_rec_all      csr_get_all_abr%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_ACTY_BASE_RT_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_abr loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_abr (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.acty_base_rt_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
 --
 -- DK Resolve For Table BEN_BENFTS_GRP
 --
 procedure get_dk_frm_bng is
  --
  -- cursor to Fetch the DK for BEN_BENFTS_GRP.BENFTS_GRP_ID
  --
   cursor csr_get_dk_bng (c_business_group_id number, c_source_key varchar2) is
   select benfts_grp_id
     from ben_benfts_grp
    where name = c_source_key
      ;

   cursor csr_get_all_bng is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_BENFTS_GRP'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bng';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bng%rowtype;
   l_table_rec_all      csr_get_all_bng%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_BENFTS_GRP
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_bng loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_bng (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.benfts_grp_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PAY_ELEMENT_LINKS_F
 --
 procedure get_dk_frm_pll is
  --
  -- cursor to Fetch the DK for PAY_ELEMENT_LINKS_F.ELEMENT_LINK_ID
  --
   cursor csr_get_dk_pll (c_business_group_id number, c_source_id number) is
   select element_Link_id
     from pay_element_links_f
    where element_type_id = c_source_id
      and business_group_id = c_business_group_id;

   cursor csr_get_all_pll is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PAY_ELEMENT_LINKS_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pll';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pll%rowtype;
   l_table_rec_all      csr_get_all_pll%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PAY_ELEMENT_LINKS_F
  --
  ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_pll loop
      l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
       -- Get element_type_id
         ben_dm_utility.message('INFO','resolve_mapping_id1 '||x.resolve_mapping_id1,5) ;
         if x.resolve_mapping_id1 is not null then
           l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         end if;
         ben_dm_utility.message('INFO','l_target_id1 '||l_target_id1,5) ;
         ben_dm_utility.message('INFO','l_bg_id '||l_bg_id,5) ;

         open csr_get_dk_pll (c_source_id => l_target_id1
                            ,c_business_group_id => l_bg_id);
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
  --
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.element_link_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_BNFTS_BAL_F
 --
 procedure get_dk_frm_bnb is
  --
  -- cursor to Fetch the DK for BEN_BNFTS_BAL_F.BNFTS_BAL_ID
  --
   cursor csr_get_dk_bnb (c_business_group_id number, c_source_key varchar2) is
   select bnfts_bal_id
     from ben_bnfts_bal_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_bnb is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_BNFTS_BAL_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bnb';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bnb%rowtype;
   l_table_rec_all      csr_get_all_bnb%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_BNFTS_BAL_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_bnb loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_bnb (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.bnfts_bal_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_BNFT_PRVDR_POOL_F
 --
 procedure get_dk_frm_bpp is
  --
  -- cursor to Fetch the DK for BEN_BNFT_PRVDR_POOL_F.BNFT_PRVDR_POOL_ID
  --
   cursor csr_get_dk_bpp (c_business_group_id number, c_source_key varchar2) is
   select bnft_prvdr_pool_id
     from ben_bnft_prvdr_pool_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_bpp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_BNFT_PRVDR_POOL_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bpp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bpp%rowtype;
   l_table_rec_all      csr_get_all_bpp%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_BNFT_PRVDR_POOL_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_bpp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_bpp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.bnft_prvdr_pool_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CMBN_PLIP_F
 --
 procedure get_dk_frm_cpl is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PLIP_F.CMBN_PLIP_ID
  --
   cursor csr_get_dk_cpl (c_business_group_id number, c_source_key varchar2) is
   select cmbn_plip_id
     from ben_cmbn_plip_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cpl is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CMBN_PLIP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpl%rowtype;
   l_table_rec_all      csr_get_all_cpl%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CMBN_PLIP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cpl loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_cpl (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cmbn_plip_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CMBN_PTIP_F
 --
 procedure get_dk_frm_cbp is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PTIP_F.CMBN_PTIP_ID
  --
   cursor csr_get_dk_cbp (c_business_group_id number, c_source_key varchar2) is
   select cmbn_ptip_id
     from ben_cmbn_ptip_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cbp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CMBN_PTIP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cbp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cbp%rowtype;
   l_table_rec_all      csr_get_all_cbp%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CMBN_PTIP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cbp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_cbp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cmbn_ptip_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CMBN_PTIP_OPT_F
 --
 procedure get_dk_frm_cpt is
  --
  -- cursor to Fetch the DK for BEN_CMBN_PTIP_OPT_F.CMBN_PTIP_OPT_ID
  --
   cursor csr_get_dk_cpt (c_business_group_id number, c_source_key varchar2) is
   select cmbn_ptip_opt_id
     from ben_cmbn_ptip_opt_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cpt is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CMBN_PTIP_OPT_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpt%rowtype;
   l_table_rec_all      csr_get_all_cpt%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CMBN_PTIP_OPT_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cpt loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_cpt (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cmbn_ptip_opt_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CM_TRGR
 --
 procedure get_dk_frm_bcr is
  --
  -- cursor to Fetch the DK for BEN_CM_TRGR.CM_TRGR_ID
  --
   cursor csr_get_dk_bcr (c_business_group_id number, c_source_key varchar2) is
   select cm_trgr_id
     from ben_cm_trgr
    where cm_trgr_src_cd||cm_trgr_typ_cd||proc_cd = c_source_key
      ;

   cursor csr_get_all_bcr is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CM_TRGR'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_bcr';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_bcr%rowtype;
   l_table_rec_all      csr_get_all_bcr%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CM_TRGR
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_bcr loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_bcr (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cm_trgr_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CM_TYP_F
 --
 procedure get_dk_frm_cct is
  --
  -- cursor to Fetch the DK for BEN_CM_TYP_F.CM_TYP_ID
  --
   cursor csr_get_dk_cct (c_business_group_id number, c_source_key varchar2) is
   select cm_typ_id
     from ben_cm_typ_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cct is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CM_TYP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cct';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cct%rowtype;
   l_table_rec_all      csr_get_all_cct%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CM_TYP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cct loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_cct (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cm_typ_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_COMP_LVL_FCTR
 --
 procedure get_dk_frm_clf is
  --
  -- cursor to Fetch the DK for BEN_COMP_LVL_FCTR.COMP_LVL_FCTR_ID
  --
   cursor csr_get_dk_clf (c_business_group_id number, c_source_key varchar2) is
   select comp_lvl_fctr_id
     from ben_comp_lvl_fctr
    where name = c_source_key
      and business_group_id = c_business_group_id
      ;

   cursor csr_get_all_clf is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_COMP_LVL_FCTR'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_clf';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_clf%rowtype;
   l_table_rec_all      csr_get_all_clf%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_COMP_LVL_FCTR
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_clf loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_clf (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.comp_lvl_fctr_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_CVG_AMT_CALC_MTHD_F
 --
 procedure get_dk_frm_ccm is
  --
  -- cursor to Fetch the DK for BEN_CVG_AMT_CALC_MTHD_F.CVG_AMT_CALC_MTHD_ID
  --
   cursor csr_get_dk_ccm (c_business_group_id number, c_source_key varchar2) is
   select cvg_amt_calc_mthd_id
     from ben_cvg_amt_calc_mthd_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_ccm is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_CVG_AMT_CALC_MTHD_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ccm';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ccm%rowtype;
   l_table_rec_all      csr_get_all_ccm%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_CVG_AMT_CALC_MTHD_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ccm loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_ccm (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.cvg_amt_calc_mthd_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_ENRT_PERD
 --
 procedure get_dk_frm_enp is
  --
  -- cursor to Fetch the DK for BEN_ENRT_PERD.ENRT_PERD_ID
  --
   cursor csr_get_dk_enp (c_business_group_id number, c_source_key varchar2
                         ,c_target_id1 number, c_target_id2 number) is
   select enrt_perd_id
     from ben_enrt_perd
    where strt_dt = to_date(c_source_key,'dd-mm-rrrr')
      and yr_perd_id = c_target_id1
      and popl_enrt_typ_cycl_id = c_target_id2
      and business_group_id = c_business_group_id
  ;

   cursor csr_get_all_enp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_ENRT_PERD'
      and target_id is null;

   cursor csr_get_dk_pop (c_pgm_id number, c_pl_id number, c_business_group_id number) is
   select *
     from ben_popl_enrt_typ_cycl_f
    where nvl(pgm_id,-1) = nvl(c_pgm_id,-1)
      and nvl(pl_id,-1) = nvl(c_pl_id,-1)
      and business_group_id = c_business_group_id
   order by decode(enrt_typ_cycl_cd,'O',1,2) asc;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_enp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_enp%rowtype;
   l_table_rec_pop      csr_get_dk_pop%rowtype;
   l_table_rec_all      csr_get_all_enp%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);
   l_target_id3         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_ENRT_PERD
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_enp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get YR_PERD_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         -- Get PGM_ID
         if x.resolve_mapping_id2 is not null then
           l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         end if;
         -- Get PL_ID
         if x.resolve_mapping_id3 is not null then
           l_target_id3 := get_target_id_for_mapping(x.resolve_mapping_id3);
         end if;
         open csr_get_dk_pop (c_business_group_id => l_bg_id
                            ,c_pgm_id => l_target_id2
                            ,c_pl_id  => l_target_id3);
         fetch csr_get_dk_pop into l_table_rec_pop;
         if csr_get_dk_pop%notfound then
           l_row_fetched := FALSE;
           -- <<RAISE EXCEPTION>>
         else
           l_row_fetched := TRUE;
         end if;
         close csr_get_dk_pop;

         open csr_get_dk_enp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1
                            ,c_target_id2 => l_table_rec_pop.popl_enrt_typ_cycl_id);
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
  --
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.enrt_perd_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
 --
 -- DK Resolve For Table BEN_LEE_RSN_F
 --
 procedure get_dk_frm_len is
  --
  -- cursor to Fetch the DK for BEN_LEE_RSN_F.LEE_RSN_ID
  --
   cursor csr_get_dk_len (c_business_group_id number,
                          c_source_key varchar2,
                          c_ler_id     number,
                          c_popl_enrt_typ_cycl_id number) is
   select lee_rsn_id
     from ben_lee_rsn_f
    where effective_start_date = to_date(c_source_key,'dd-mm-rrrr')
      and ler_id = c_ler_id
      and popl_enrt_typ_cycl_id = c_popl_enrt_typ_cycl_id
      and business_group_id = c_business_group_id;

   cursor csr_get_all_len is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_LEE_RSN_F'
      and target_id is null;

   cursor csr_get_dk_pop (c_pgm_id number, c_pl_id number, c_business_group_id number) is
   select *
     from ben_popl_enrt_typ_cycl_f
    where nvl(pgm_id,-1) = nvl(c_pgm_id,-1)
      and nvl(pl_id,-1) = nvl(c_pl_id,-1)
      and business_group_id = c_business_group_id
      and enrt_typ_cycl_cd = 'L';

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_len';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_len%rowtype;
   l_table_rec_pop      csr_get_dk_pop%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);
   l_target_id3         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_ENRT_PERD
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_len loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get LER_ID
         if x.resolve_mapping_id1 is not null then
           l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         end if;
         -- Get PGM_ID
         if x.resolve_mapping_id2 is not null then
           l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         end if;
         -- Get PL_ID
         if x.resolve_mapping_id3 is not null then
           l_target_id3 := get_target_id_for_mapping(x.resolve_mapping_id3);
         end if;
         open csr_get_dk_pop (c_business_group_id => l_bg_id
                            ,c_pgm_id => l_target_id2
                            ,c_pl_id  => l_target_id3);
         fetch csr_get_dk_pop into l_table_rec_pop;
         if csr_get_dk_pop%notfound then
           l_row_fetched := FALSE;
           -- <<RAISE EXCEPTION>>
         else
           l_row_fetched := TRUE;
         end if;
         close csr_get_dk_pop;

         open csr_get_dk_len (c_business_group_id => l_bg_id
                            ,c_source_key => x.source_key
                            ,c_ler_id => l_target_id1
                            ,c_popl_enrt_typ_cycl_id => l_table_rec_pop.popl_enrt_typ_cycl_id);
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
         --
         -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
         --
            ben_dm_data_util.update_pk_mapping
            (p_resolve_mapping_id  => x.resolve_mapping_id
            ,p_target_id           => l_table_rec.lee_rsn_id);
          end if;
          --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_LER_F
 --
 procedure get_dk_frm_ler is
  --
  -- cursor to Fetch the DK for BEN_LER_F.LER_ID
  --
   cursor csr_get_dk_ler (c_business_group_id number, c_source_key varchar2) is
   select ler_id
     from ben_ler_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_ler is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_LER_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ler';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ler%rowtype;
   l_table_rec_all      csr_get_all_ler%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_LER_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ler loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_ler (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.ler_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_OIPLIP_F
 --
 procedure get_dk_frm_boi is
  --
  -- cursor to Fetch the DK for BEN_OIPLIP_F.OIPLIP_ID
  --
   cursor csr_get_dk_boi (c_business_group_id number, c_source_key varchar2
                         ,c_target_id1 number, c_target_id2 number) is
   select oiplip_id
     from ben_oiplip_f
    where oipl_id = c_target_id1
      and plip_id = c_target_id2;

   cursor csr_get_all_boi is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_OIPLIP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_boi';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_boi%rowtype;
   l_table_rec_all      csr_get_all_boi%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_OIPLIP_F
  --
  for x in csr_get_all_boi loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get OIPL_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         -- Get PLIP_ID
         l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         open csr_get_dk_boi (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1
                            ,c_target_id2 => l_target_id2);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.oiplip_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_OIPL_F
 --
 procedure get_dk_frm_cop is
  --
  -- cursor to Fetch the DK for BEN_OIPL_F.OIPL_ID
  --
   cursor csr_get_dk_cop (c_business_group_id number, c_source_key varchar2
                         ,c_target_id1 number, c_target_id2 number) is
   select oipl_id
     from ben_oipl_f
    where pl_id = c_target_id1
      and opt_id = c_target_id2
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cop is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_OIPL_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cop';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cop%rowtype;
   l_table_rec_all      csr_get_all_cop%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_OIPL_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cop loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get PL_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         -- Get OPT_ID
         l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         open csr_get_dk_cop (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1
                            ,c_target_id2 => l_target_id2);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.oipl_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_OPT_F
 --
 procedure get_dk_frm_opt is
  --
  -- cursor to Fetch the DK for BEN_OPT_F.OPT_ID
  --
   cursor csr_get_dk_opt (c_business_group_id number, c_source_key varchar2) is
   select opt_id
     from ben_opt_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_opt is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_OPT_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_opt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_opt%rowtype;
   l_table_rec_all      csr_get_all_opt%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_OPT_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_opt loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_opt (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.opt_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_PGM_F
 --
 procedure get_dk_frm_pgm is
  --
  -- cursor to Fetch the DK for BEN_PGM_F.PGM_ID
  --
   cursor csr_get_dk_pgm (c_business_group_id number, c_source_key varchar2) is
   select pgm_id
     from ben_pgm_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_pgm is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_PGM_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pgm';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pgm%rowtype;
   l_table_rec_all      csr_get_all_pgm%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_PGM_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_pgm loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_pgm (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.pgm_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_PLIP_F
 --
 procedure get_dk_frm_cpp is
  --
  -- cursor to Fetch the DK for BEN_PLIP_F.PLIP_ID
  --
   cursor csr_get_dk_cpp (c_business_group_id number, c_source_key varchar2
                         ,c_target_id1 number, c_target_id2 number) is
   select plip_id
     from ben_plip_f
    where pgm_id = c_target_id1
      and pl_id  = c_target_id2
      and business_group_id = c_business_group_id;

   cursor csr_get_all_cpp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_PLIP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_cpp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_cpp%rowtype;
   l_table_rec_all      csr_get_all_cpp%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_PLIP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_cpp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get PGM_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         -- Get PL_ID
         l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         open csr_get_dk_cpp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1
                            ,c_target_id2 => l_target_id2);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.plip_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_PL_F
 --
 procedure get_dk_frm_pln is
  --
  -- cursor to Fetch the DK for BEN_PL_F.PL_ID
  --
   cursor csr_get_dk_pln (c_business_group_id number, c_source_key varchar2) is
   select pl_id
     from ben_pl_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_pln is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_PL_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pln';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pln%rowtype;
   l_table_rec_all      csr_get_all_pln%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_PL_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_pln loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_pln (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.pl_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_PL_TYP_F
 --
 procedure get_dk_frm_ptp is
  --
  -- cursor to Fetch the DK for BEN_PL_TYP_F.PL_TYP_ID
  --
   cursor csr_get_dk_ptp (c_business_group_id number, c_source_key varchar2) is
   select pl_typ_id
     from ben_pl_typ_f
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_ptp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_PL_TYP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ptp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ptp%rowtype;
   l_table_rec_all      csr_get_all_ptp%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_PL_TYP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ptp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_ptp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.pl_typ_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_PTIP_F
 --
 procedure get_dk_frm_ctp is
  --
  -- cursor to Fetch the DK for BEN_PTIP_F.PTIP_ID
  --
   cursor csr_get_dk_ctp (c_business_group_id number, c_source_key varchar2
                         ,c_target_id1 number, c_target_id2 number) is
   select ptip_id
     from ben_ptip_f
    where pgm_id = c_target_id1
      and pl_typ_id = c_target_id2
      and business_group_id = c_business_group_id;

   cursor csr_get_all_ctp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_PTIP_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ctp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ctp%rowtype;
   l_table_rec_all      csr_get_all_ctp%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);
   l_target_id2         number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_PTIP_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ctp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get PGM_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         -- Get PL_TYP_ID
         l_target_id2 := get_target_id_for_mapping(x.resolve_mapping_id2);
         open csr_get_dk_ctp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1
                            ,c_target_id2 => l_target_id2);
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
  --
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.ptip_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table BEN_YR_PERD
 --
 procedure get_dk_frm_yrp is
  --
  -- cursor to Fetch the DK for BEN_YR_PERD.YR_PERD_ID
  --
   cursor csr_get_dk_yrp (c_business_group_id number, c_source_key varchar2) is
   select yr_perd_id
     from ben_yr_perd
    where to_char(END_DATE,'YYYYMMDD:HH24:mi:ss')||'-'||to_char(START_DATE,'DD-MON-YYYY')||'-'||PERD_TYP_CD = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_yrp is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'BEN_YR_PERD'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_yrp';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_yrp%rowtype;
   l_table_rec_all      csr_get_all_yrp%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table BEN_YR_PERD
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_yrp loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_yrp (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.yr_perd_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table FF_FORMULAS_F
 --
 procedure get_dk_frm_fra is
  --
  -- cursor to Fetch the DK for FF_FORMULAS_F.FORMULA_ID
  --
   cursor csr_get_dk_fra (c_business_group_id number, c_source_key varchar2) is
   select formula_id
     from ff_formulas_f
    where formula_name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_fra is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'FF_FORMULAS_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fra';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fra%rowtype;
   l_table_rec_all      csr_get_all_fra%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table FF_FORMULAS_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_fra loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_fra (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.formula_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table FND_ID_FLEX_STRUCTURES_VL
 --
 procedure get_dk_frm_fit is
  --
  -- cursor to Fetch the DK for FND_ID_FLEX_STRUCTURES_VL.ID_FLEX_NUM
  --
   cursor csr_get_dk_fit (c_business_group_id number, c_source_key varchar2) is
   select id_flex_num
     from fnd_id_flex_structures_vl
    where id_flex_structure_name = c_source_key
      ;

   cursor csr_get_all_fit is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'FND_ID_FLEX_STRUCTURES_VL'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fit';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fit%rowtype;
   l_table_rec_all      csr_get_all_fit%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table FND_ID_FLEX_STRUCTURES_VL
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_fit loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_fit (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.id_flex_num);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table FND_USER
 --
 procedure get_dk_frm_fus is
  --
  -- cursor to Fetch the DK for FND_USER.USER_ID
  --
   cursor csr_get_dk_fus (c_business_group_id number, c_source_key varchar2) is
   select user_id
     from fnd_user
    where user_name = c_source_key
      ;

   cursor csr_get_all_fus is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'FND_USER'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_fus';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_fus%rowtype;
   l_table_rec_all      csr_get_all_fus%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table FND_USER
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_fus loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_fus (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.user_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table HR_ALL_ORGANIZATION_UNITS
 --
 procedure get_dk_frm_aou is
  --
  -- cursor to Fetch the DK for HR_ALL_ORGANIZATION_UNITS.PERSON_ID
  --
   cursor csr_get_dk_aou (c_business_group_id number, c_source_key varchar2) is
   select organization_id
     from hr_all_organization_units
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_aou is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'HR_ALL_ORGANIZATION_UNITS'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aou';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aou%rowtype;
   l_table_rec_all      csr_get_all_aou%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table HR_ALL_ORGANIZATION_UNITS
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_aou loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_aou (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.organization_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;




 -- DK Resolve For Table HR_ALL_ORGANIZATION_UNITS
 -- for business greoup
 --
 procedure get_dk_frm_ori is
  --
  -- cursor to Fetch the DK for HR_ALL_ORGANIZATION_UNITS.PERSON_ID
  --
   cursor csr_get_dk_ori (c_business_group_id number, c_source_key varchar2) is
   select organization_id
     from hr_all_organization_units
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_ori is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'HR_ORGANIZATION_INFORMATION'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aou';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ori%rowtype;
   l_table_rec_all      csr_get_all_ori%rowtype;
   l_bg_id              number(15);


 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table HR_ALL_ORGANIZATION_UNITS
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ori loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_ori (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
         fetch csr_get_dk_ori into l_table_rec;
         if csr_get_dk_ori%notfound then
           l_row_fetched := FALSE;
         else
           l_row_fetched := TRUE;
         end if;
         close csr_get_dk_ori;

  --
  -- if no row fetched then raise exception
  --
   if not l_row_fetched then
  -- <<RAISE Some kind of Exception>>
     null;
   else
  --
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.organization_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;




 --
 -- DK Resolve For Table HR_LOCATIONS_ALL
 --
 procedure get_dk_frm_loc is
  --
  -- cursor to Fetch the DK for HR_LOCATIONS_ALL.LOCATION_ID
  --
   cursor csr_get_dk_loc (c_business_group_id number, c_source_key varchar2) is
   select location_id
     from hr_locations_all
    where location_code = c_source_key
      ;

   cursor csr_get_all_loc is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'HR_LOCATIONS_ALL'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_loc';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_loc%rowtype;
   l_table_rec_all      csr_get_all_loc%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table HR_LOCATIONS_ALL
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_loc loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_loc (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.location_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PAY_ALL_PAYROLLS_F
 --
 procedure get_dk_frm_prl is
  --
  -- cursor to Fetch the DK for PAY_ALL_PAYROLLS_F.PAYROLL_ID
  --
   cursor csr_get_dk_prl (c_business_group_id number, c_source_key varchar2) is
   select payroll_id
     from pay_all_payrolls_f
    where payroll_name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_prl is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PAY_ALL_PAYROLLS_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_prl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_prl%rowtype;
   l_table_rec_all      csr_get_all_prl%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PAY_ALL_PAYROLLS_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_prl loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_prl (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.payroll_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PAY_ELEMENT_TYPES_F
 --
 procedure get_dk_frm_pet is
  --
  -- cursor to Fetch the DK for PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID
  --
   cursor csr_get_dk_pet (c_business_group_id number, c_source_key varchar2) is
   select element_type_id
     from pay_element_types_f
    where element_name = c_source_key
      and (business_group_id = c_business_group_id or business_group_id is null)
      and (LEGISLATION_CODE = 'US' or LEGISLATION_CODE is null);

   cursor csr_get_all_pet is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PAY_ELEMENT_TYPES_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pet';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pet%rowtype;
   l_table_rec_all      csr_get_all_pet%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PAY_ELEMENT_TYPES_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_pet loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_pet (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.element_type_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PAY_INPUT_VALUES_F
 --
 procedure get_dk_frm_ipv is
  --
  -- cursor to Fetch the DK for PAY_INPUT_VALUES_F.INPUT_VALUE_ID
  --
   cursor csr_get_dk_ipv (c_business_group_id number, c_source_key varchar2
                          ,c_target_id1 number) is
   select input_value_id
     from pay_input_values_f
    where name = c_source_key
      and element_type_id = c_target_id1
      and (business_group_id = c_business_group_id or business_group_id is null)
      and (LEGISLATION_CODE = 'US' or LEGISLATION_CODE is null);

   cursor csr_get_all_ipv is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PAY_INPUT_VALUES_F'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ipv';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ipv%rowtype;
   l_table_rec_all      csr_get_all_ipv%rowtype;
   l_bg_id              number(15);
   l_target_id1         number(15);


 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PAY_INPUT_VALUES_F
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ipv loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         -- Get ELEMENT_TYPE_ID
         l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
         --
         open csr_get_dk_ipv (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id
                            ,c_target_id1 => l_target_id1);
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
  --
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.input_value_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PER_ASSIGNMENT_STATUS_TYPES
 --
 procedure get_dk_frm_ast is
  --
  -- cursor to Fetch the DK for PER_ASSIGNMENT_STATUS_TYPES.ASSIGNMENT_STATUS_TYPE_ID
  --
   cursor csr_get_dk_ast (c_user_status   varchar2,
                          c_leg_code      varchar2,
                          c_bg_id number) is
   select assignment_status_type_id
     from per_assignment_status_types
    where user_status = c_user_status
      and nvl(legislation_code,'-x') = c_leg_code
      and nvl(business_group_id,-1) = nvl(c_bg_id,-1) ;

   cursor csr_get_all_ast is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_ASSIGNMENT_STATUS_TYPES'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_ast';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_ast%rowtype;
   l_table_rec_all      csr_get_all_ast%rowtype;
   l_bg_id              number(15);
   l_user_status        varchar2(255);
   l_legislation_code   varchar2(30);
   l_business_group_id  number(15);
   l_pos1               number(15);
   l_pos2               number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_ASSIGNMENT_STATUS_TYPES
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_ast loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
     l_pos1 := instr(x.source_key,'-',1);
     l_pos2 := instr(x.source_key,'-',-1,1);
     l_user_status := substr(x.source_key,1,l_pos1-1);
     l_legislation_code := substr(x.source_key,l_pos1+1,l_pos2-l_pos1-1);
     if  substr(x.source_key,l_pos2+1) = 'Y' then
         l_business_group_id := l_bg_id;
     else
         l_business_group_id := null;
     end if;

     ben_dm_utility.message('INFO','l_pos1 '||l_pos1,5) ;
     ben_dm_utility.message('INFO','l_pos2 '||l_pos2,5) ;
     ben_dm_utility.message('INFO','l_user_status '||l_user_status,5) ;
     ben_dm_utility.message('INFO','l_legislation_code '||l_legislation_code,5) ;
     ben_dm_utility.message('INFO','l_business_group_id '||l_business_group_id,5) ;
     open csr_get_dk_ast (c_user_status => l_user_status
                         ,c_leg_code => l_legislation_code
                         ,c_bg_id    => l_business_group_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.assignment_status_type_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PER_GRADES
 --
 procedure get_dk_frm_gra is
  --
  -- cursor to Fetch the DK for PER_GRADES.GRADE_ID
  --
   cursor csr_get_dk_gra (c_business_group_id number, c_source_key varchar2) is
   select grade_id
     from per_grades
    where name = c_source_key
      ;

   cursor csr_get_all_gra is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_GRADES'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_gra';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_gra%rowtype;
   l_table_rec_all      csr_get_all_gra%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_GRADES
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_gra loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_gra (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.grade_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PER_JOBS
 --
 procedure get_dk_frm_job is
  --
  -- cursor to Fetch the DK for PER_JOBS.JOB_ID
  --
   cursor csr_get_dk_job (c_business_group_id number, c_source_key varchar2) is
   select job_id
     from per_jobs
    where name = c_source_key
      ;

   cursor csr_get_all_job is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_JOBS'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_job';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_job%rowtype;
   l_table_rec_all      csr_get_all_job%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_JOBS
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_job loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_job (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.job_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PER_PAY_BASES
 --
 procedure get_dk_frm_pyb is
  --
  -- cursor to Fetch the DK for PER_PAY_BASES.PAY_BASIS_ID
  --
   cursor csr_get_dk_pyb (c_business_group_id number, c_source_key varchar2) is
   select pay_basis_id
     from per_pay_bases
    where name = c_source_key
      ;

   cursor csr_get_all_pyb is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_PAY_BASES'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_pyb';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_pyb%rowtype;
   l_table_rec_all      csr_get_all_pyb%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_PAY_BASES
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_pyb loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_pyb (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.pay_basis_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PER_PERSON_TYPES
 --
 procedure get_dk_frm_prt is
  --
  -- cursor to Fetch the DK for PER_PERSON_TYPES.PERSON_TYPE_ID
  --
   cursor csr_get_dk_prt (c_business_group_id number, c_source_key varchar2) is
   select person_type_id
     from per_person_types
    where user_person_type = c_source_key
      and business_group_id = c_business_group_id ;

   cursor csr_get_all_prt is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_PERSON_TYPES'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_prt';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_prt%rowtype;
   l_table_rec_all      csr_get_all_prt%rowtype;
   l_bg_id              number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_PERSON_TYPES
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_prt loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_prt (c_source_key => x.source_key
                            ,c_business_group_id => l_bg_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.person_type_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
 --
 -- DK Resolve For Table PER_ABSENCE_ATTENDANCE_TYPES
 --
 procedure get_dk_frm_aat is
  --
  -- cursor to Fetch the DK for PER_ABSENCE_ATTENDANCE_TYPES.ABSENCE_ATTENDANCE_TYPE_ID
  --
   cursor csr_get_dk_aat (c_source_key      varchar2,
                          c_business_group_id   number) is
   select absence_attendance_type_id
     from per_absence_attendance_types
    where name = c_source_key
      and business_group_id = c_business_group_id;

   cursor csr_get_all_aat is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_ABSENCE_ATTENDANCE_TYPES'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aat';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aat%rowtype;
   l_table_rec_all      csr_get_all_aat%rowtype;
   l_business_group_id  number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_ABSENCE_ATTENDANCE_TYPES
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_aat loop
     l_business_group_id := ben_dm_data_util.get_bg_id(x.business_group_name);
     ben_dm_utility.message('INFO','l_business_group_id '||l_business_group_id,5) ;

     open csr_get_dk_aat (c_source_key => x.source_key
                         ,c_business_group_id => l_business_group_id);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.absence_attendance_type_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
 --
 -- DK Resolve For Table PER_ABS_ATTENDANCE_REASONS
 --
 procedure get_dk_frm_aar is
  --
  -- cursor to Fetch the DK for PER_ABS_ATTENDANCE_REASONS.ABS_ATTENDANCE_REASON_ID
  --
   cursor csr_get_dk_aar (c_source_key      varchar2,
                          c_business_group_id   number,
                          c_target_id1          number) is
   select abs_attendance_reason_id
     from per_abs_attendance_reasons
    where name = c_source_key
      and absence_attendance_type_id = c_target_id1
      and business_group_id = c_business_group_id;

   cursor csr_get_all_aar is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PER_ABS_ATTENDANCE_REASONS'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_aar';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_aar%rowtype;
   l_table_rec_all      csr_get_all_aar%rowtype;
   l_business_group_id  number(15);
   l_target_id1         number(15);
   --
 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PER_ABS_ATTENDANCE_REASONS
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_aar loop
     l_business_group_id := ben_dm_data_util.get_bg_id(x.business_group_name);
     ben_dm_utility.message('INFO','l_business_group_id '||l_business_group_id,5) ;
     --
     l_target_id1 := get_target_id_for_mapping(x.resolve_mapping_id1);
     --
     open csr_get_dk_aar (c_source_key => x.source_key
                         ,c_business_group_id => l_business_group_id
                         ,c_target_id1 => l_target_id1 );
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_table_rec.abs_attendance_reason_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
--
 --
 -- DK Resolve For Table HR_SOFT_CODING_KEYFLEX
 --
 procedure get_dk_frm_scl is
  --
  -- cursor to Fetch the DK for HR_SOFT_CODING_KEYFLEX
  --
   cursor csr_get_dk_scl (c_entity_result_id number) is
   select *
     from ben_dm_entity_results
    where entity_result_id = c_entity_result_id;

   cursor csr_get_all_scl is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'HR_SOFT_CODING_KEYFLEX'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_scl';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_scl%rowtype;
   l_table_rec_all      csr_get_all_scl%rowtype;
   l_bg_id              number(15);
   l_target_id          number(15);
   l_concatenated_segments   varchar2(700);


 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table HR_SOFT_CODING_KEYFLEX
  --
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_scl loop
     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);
         open csr_get_dk_scl (c_entity_result_id => x.resolve_mapping_id1);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --

    if l_table_rec.INFORMATION4 is not null then
       l_table_rec.INFORMATION4 := l_bg_id;
    end if;

     hr_scl_ins.ins_or_sel
    ( P_SEGMENT1               => l_table_rec.INFORMATION4
     ,P_SEGMENT2               => l_table_rec.INFORMATION5
     ,P_SEGMENT3               => l_table_rec.INFORMATION6
     ,P_SEGMENT4               => l_table_rec.INFORMATION7
     ,P_SEGMENT5               => l_table_rec.INFORMATION8
     ,P_SEGMENT6               => l_table_rec.INFORMATION9
     ,P_SEGMENT7               => l_table_rec.INFORMATION10
     ,P_SEGMENT8               => l_table_rec.INFORMATION11
     ,P_SEGMENT9               => l_table_rec.INFORMATION12
     ,P_SEGMENT10              => l_table_rec.INFORMATION13
     ,P_SEGMENT11              => l_table_rec.INFORMATION14
     ,P_SEGMENT12              => l_table_rec.INFORMATION15
     ,P_SEGMENT13              => l_table_rec.INFORMATION16
     ,P_SEGMENT14              => l_table_rec.INFORMATION17
     ,P_SEGMENT15              => l_table_rec.INFORMATION18
     ,P_SEGMENT16              => l_table_rec.INFORMATION19
     ,P_SEGMENT17              => l_table_rec.INFORMATION20
     ,P_SEGMENT18              => l_table_rec.INFORMATION21
     ,P_SEGMENT19              => l_table_rec.INFORMATION22
     ,P_SEGMENT20              => l_table_rec.INFORMATION23
     ,P_SEGMENT21              => l_table_rec.INFORMATION24
     ,P_SEGMENT22              => l_table_rec.INFORMATION25
     ,P_SEGMENT23              => l_table_rec.INFORMATION26
     ,P_SEGMENT24              => l_table_rec.INFORMATION27
     ,P_SEGMENT25              => l_table_rec.INFORMATION28
     ,P_SEGMENT26              => l_table_rec.INFORMATION29
     ,P_SEGMENT27              => l_table_rec.INFORMATION30
     ,P_SEGMENT28              => l_table_rec.INFORMATION31
     ,P_SEGMENT29              => l_table_rec.INFORMATION32
     ,P_SEGMENT30              => l_table_rec.INFORMATION33
     ,p_business_group_id      => l_bg_id
     ,p_soft_coding_keyflex_id => l_target_id
     ,p_concatenated_segments  => l_concatenated_segments
     ,p_validate               => FALSE);

     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_target_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;

 --
 -- DK Resolve For Table PAY_PEOPLE_GROUPS
 --
 procedure get_dk_frm_peg is
  --
  -- cursor to Fetch the DK for PAY_PEOPLE_GROUPS
  --
   cursor csr_get_dk_peg (c_entity_result_id number) is
   select *
     from ben_dm_entity_results
    where entity_result_id = c_entity_result_id;

   cursor csr_get_all_peg is
   select *
     from ben_dm_resolve_mappings
    where table_name = 'PAY_PEOPLE_GROUPS'
      and target_id is null;

  -- Declare local variables
   l_proc               varchar2(72) := g_package || 'get_dk_frm_peg';
   l_row_fetched        boolean := FALSE;
   l_table_rec          csr_get_dk_peg%rowtype;
   l_table_rec_all      csr_get_all_peg%rowtype;
   l_bg_id              number(15);
   l_target_id          number(15);
   l_group_name         varchar2(700);
   l_people_group_structure number(15);

 begin

  --
  -- Select all rows from BEN_DM_RESOLVE_MAPPINGS for table PAY_PEOPLE_GROUPS
  --
  ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;
  for x in csr_get_all_peg loop

     hr_general.g_data_migrator_mode := 'Y';

     l_bg_id := ben_dm_data_util.get_bg_id(x.business_group_name);

     open csr_get_dk_peg (c_entity_result_id => x.resolve_mapping_id1);
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
  -- Update DK data into BEN_DM_RESOLVE_MAPPINGS table.
  --

    select people_group_structure
      into l_people_group_structure
      from per_business_groups
     where business_group_id = l_bg_id;

    hr_kflex_utility.INS_OR_SEL_KEYFLEX_COMB
    ( P_SEGMENT1               => l_table_rec.INFORMATION4
     ,P_SEGMENT2               => l_table_rec.INFORMATION5
     ,P_SEGMENT3               => l_table_rec.INFORMATION6
     ,P_SEGMENT4               => l_table_rec.INFORMATION7
     ,P_SEGMENT5               => l_table_rec.INFORMATION8
     ,P_SEGMENT6               => l_table_rec.INFORMATION9
     ,P_SEGMENT7               => l_table_rec.INFORMATION10
     ,P_SEGMENT8               => l_table_rec.INFORMATION11
     ,P_SEGMENT9               => l_table_rec.INFORMATION12
     ,P_SEGMENT10              => l_table_rec.INFORMATION13
     ,P_SEGMENT11              => l_table_rec.INFORMATION14
     ,P_SEGMENT12              => l_table_rec.INFORMATION15
     ,P_SEGMENT13              => l_table_rec.INFORMATION16
     ,P_SEGMENT14              => l_table_rec.INFORMATION17
     ,P_SEGMENT15              => l_table_rec.INFORMATION18
     ,P_SEGMENT16              => l_table_rec.INFORMATION19
     ,P_SEGMENT17              => l_table_rec.INFORMATION20
     ,P_SEGMENT18              => l_table_rec.INFORMATION21
     ,P_SEGMENT19              => l_table_rec.INFORMATION22
     ,P_SEGMENT20              => l_table_rec.INFORMATION23
     ,P_SEGMENT21              => l_table_rec.INFORMATION24
     ,P_SEGMENT22              => l_table_rec.INFORMATION25
     ,P_SEGMENT23              => l_table_rec.INFORMATION26
     ,P_SEGMENT24              => l_table_rec.INFORMATION27
     ,P_SEGMENT25              => l_table_rec.INFORMATION28
     ,P_SEGMENT26              => l_table_rec.INFORMATION29
     ,P_SEGMENT27              => l_table_rec.INFORMATION30
     ,P_SEGMENT28              => l_table_rec.INFORMATION31
     ,P_SEGMENT29              => l_table_rec.INFORMATION32
     ,P_SEGMENT30              => l_table_rec.INFORMATION33
     ,p_appl_short_name        => 'PAY'
     ,p_flex_code              => 'GRP'
     ,p_flex_num               => l_people_group_structure
     ,p_concat_segments_in     => null
     ,p_ccid                   => l_target_id
     ,p_concat_segments_out    => l_group_name);


/*

    pay_pgp_ins.ins_or_sel
    ( P_SEGMENT1               => l_table_rec.INFORMATION4
     ,P_SEGMENT2               => l_table_rec.INFORMATION5
     ,P_SEGMENT3               => l_table_rec.INFORMATION6
     ,P_SEGMENT4               => l_table_rec.INFORMATION7
     ,P_SEGMENT5               => l_table_rec.INFORMATION8
     ,P_SEGMENT6               => l_table_rec.INFORMATION9
     ,P_SEGMENT7               => l_table_rec.INFORMATION10
     ,P_SEGMENT8               => l_table_rec.INFORMATION11
     ,P_SEGMENT9               => l_table_rec.INFORMATION12
     ,P_SEGMENT10              => l_table_rec.INFORMATION13
     ,P_SEGMENT11              => l_table_rec.INFORMATION14
     ,P_SEGMENT12              => l_table_rec.INFORMATION15
     ,P_SEGMENT13              => l_table_rec.INFORMATION16
     ,P_SEGMENT14              => l_table_rec.INFORMATION17
     ,P_SEGMENT15              => l_table_rec.INFORMATION18
     ,P_SEGMENT16              => l_table_rec.INFORMATION19
     ,P_SEGMENT17              => l_table_rec.INFORMATION20
     ,P_SEGMENT18              => l_table_rec.INFORMATION21
     ,P_SEGMENT19              => l_table_rec.INFORMATION22
     ,P_SEGMENT20              => l_table_rec.INFORMATION23
     ,P_SEGMENT21              => l_table_rec.INFORMATION24
     ,P_SEGMENT22              => l_table_rec.INFORMATION25
     ,P_SEGMENT23              => l_table_rec.INFORMATION26
     ,P_SEGMENT24              => l_table_rec.INFORMATION27
     ,P_SEGMENT25              => l_table_rec.INFORMATION28
     ,P_SEGMENT26              => l_table_rec.INFORMATION29
     ,P_SEGMENT27              => l_table_rec.INFORMATION30
     ,P_SEGMENT28              => l_table_rec.INFORMATION31
     ,P_SEGMENT29              => l_table_rec.INFORMATION32
     ,P_SEGMENT30              => l_table_rec.INFORMATION33
     ,p_business_group_id      => l_bg_id
     ,p_people_group_id        => l_target_id
     ,p_group_name             => l_group_name
     ,p_validate               => FALSE);

*/
     ben_dm_data_util.update_pk_mapping
     (p_resolve_mapping_id  => x.resolve_mapping_id
     ,p_target_id           => l_target_id);
   end if;
   --
  end loop;
  ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;
 end;
--
--   Genegeral procedure to call all other dk procedire

Procedure  get_dk_frm_all is

   cursor csr_get_no_target is
   select *
     from ben_dm_resolve_mappings
    where target_id is null;


l_proc  varchar2(75) ;
l_unresolved_dk boolean := FALSE;
no_dk   exception;

Begin
   l_proc  := g_package|| 'get_dk_frm_all' ;
   ben_dm_utility.message('INFO','Entering : ' || l_proc,5) ;

   hr_general.g_data_migrator_mode := 'Y';

   -- DK Resolve for Table BEN_ACTL_PREM_F
   get_dk_frm_apr;

   -- DK Resolve for Table BEN_ACTN_TYP
   get_dk_frm_eat;

   -- DK Resolve for Table BEN_ACTY_BASE_RT_F
   get_dk_frm_abr;

   -- DK Resolve for Table BEN_BENFTS_GRP
   get_dk_frm_bng;

   -- DK Resolve for Table BEN_BNFTS_BAL_F
   get_dk_frm_bnb;

   -- DK Resolve for Table BEN_BNFT_PRVDR_POOL_F
   get_dk_frm_bpp;

   -- DK Resolve for Table BEN_CMBN_PLIP_F
   get_dk_frm_cpl;

   -- DK Resolve for Table BEN_CMBN_PTIP_F
   get_dk_frm_cbp;

   -- DK Resolve for Table BEN_CMBN_PTIP_OPT_F
   get_dk_frm_cpt;

   -- DK Resolve for Table BEN_CM_TRGR
   get_dk_frm_bcr;

   -- DK Resolve for Table BEN_CM_TYP_F
   get_dk_frm_cct;

   -- DK Resolve for Table BEN_COMP_LVL_FCTR
   get_dk_frm_clf;

   -- DK Resolve for Table BEN_CVG_AMT_CALC_MTHD_F
   get_dk_frm_ccm;

   -- DK Resolve for Table BEN_LER_F
   get_dk_frm_ler;

   -- DK Resolve for Table BEN_OPT_F
   get_dk_frm_opt;

   -- DK Resolve for Table BEN_PGM_F
   get_dk_frm_pgm;

   -- DK Resolve for Table BEN_PL_F
   get_dk_frm_pln;

   -- DK Resolve for Table BEN_PL_TYP_F
   get_dk_frm_ptp;

   -- DK Resolve for Table BEN_YR_PERD
   get_dk_frm_yrp;

   -- DK Resolve for Table BEN_LEE_RSN_F
   get_dk_frm_len;

   -- DK Resolve for Table FF_FORMULAS_F
   get_dk_frm_fra;

   -- DK Resolve for Table FND_ID_FLEX_STRUCTURES_VL
   get_dk_frm_fit;

   -- DK Resolve for Table FND_USER
   get_dk_frm_fus;

   -- DK Resolve for Table HR_ALL_ORGANIZATION_UNITS
   get_dk_frm_aou;

   get_dk_frm_ori ;

   -- DK Resolve for Table HR_LOCATIONS_ALL
   get_dk_frm_loc;

   -- DK Resolve for Table PAY_ALL_PAYROLLS_F
   get_dk_frm_prl;

   -- DK Resolve for Table PAY_ELEMENT_TYPES_F
   get_dk_frm_pet;

   -- DK Resolve for Table PAY_INPUT_VALUES_F
   get_dk_frm_ipv;

   -- DK Resolve for Table PAY_ELEMENT_LINKS_F
   get_dk_frm_pll;

   -- DK Resolve for Table PER_ASSIGNMENT_STATUS_TYPES
   get_dk_frm_ast;

   -- DK Resolve for Table PER_GRADES
   get_dk_frm_gra;

   -- DK Resolve for Table PER_JOBS
   get_dk_frm_job;

   -- DK Resolve for Table PER_PAY_BASES
   get_dk_frm_pyb;

   -- DK Resolve for Table PER_PERSON_TYPES
   get_dk_frm_prt;

   -- DK Resolve for Table HR_SOFT_CODING_KEYFLEX
   get_dk_frm_scl;

   -- DK Resolve for Table PAY_PEOPLE_GROUPS
   get_dk_frm_peg;

   -- DK Resolve for Table BEN_ENRT_PERD
   get_dk_frm_enp;

   -- DK Resolve for Table BEN_OIPL_F
   get_dk_frm_cop;

   -- DK Resolve for Table BEN_PLIP_F
   get_dk_frm_cpp;

   -- DK Resolve for Table BEN_PTIP_F
   get_dk_frm_ctp;

   -- DK Resolve for Table BEN_OIPLIP_F
   get_dk_frm_boi;

   -- DK Resolve for Table PER_ABSENCE_ATTENDANCE_TYPES
   get_dk_frm_aat;

   -- DK Resolve for Table PER_ABS_ATTENDANCE_REASONS
   get_dk_frm_aar;

   --

 ben_dm_utility.message('INFO','Start of Report for Unresolved Developer Keys',5) ;
  for x in csr_get_no_target loop
    l_unresolved_dk := TRUE;

    ben_dm_utility.message('INFO','Resolve_Mapping_Id : ' || x.resolve_mapping_id,5);
    ben_dm_utility.message('INFO','Table_Name : ' || x.table_name,5);
    ben_dm_utility.message('INFO','Column_Name : ' || x.column_name,5);
    ben_dm_utility.message('INFO','Source_Key : ' || x.source_key,5);
    ben_dm_utility.message('INFO','Business_Group_name : ' || x.business_group_name,5);
   --
  end loop;
 ben_dm_utility.message('INFO','End of Report for Unresolved Developer Keys',5);

   if l_unresolved_dk then
     ben_dm_utility.message('INFO','Error : Unresolved Developer Keys',5) ;
     raise no_dk;
   end if;

 ben_dm_utility.message('INFO','Leaving : ' || l_proc,5) ;

Exception
  when others then
    ben_dm_utility.message('INFO','Error : ' || substr(sqlerrm,1,100) ,5) ;
    raise ;
end get_dk_frm_all ;


end ben_dm_upload_dk;

/
