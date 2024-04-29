--------------------------------------------------------
--  DDL for Package Body BEN_DERIVE_PART_AND_RATE_CVG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVE_PART_AND_RATE_CVG" as
/* $Header: bendrcvg.pkb 115.6 2002/10/23 00:55:05 ikasire noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Derive Participation and Rate Coverage Routine
Purpose
        This package is used to return or retrieve information that is
        needed for rates and or factors.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        23 Mar 00        G Perry    115.0      Created.
        26 Jun 00        G Perry    115.1      Added age_calc_rl support.
        17-jan-01        tilak      116.2      derived faction validation with max
                                               changed from > max to > max +1
        17-Nov-01        ikasire    116.3      Bug 2101937 - Fixed the error in the ceil
                                               condition of version 116.2 in all cursors.
        03-Dec-01        ikasire    116.4      Bug 2101937 - fixed the typo of version 116.3
        22-Oct-02        ikasire    116.6      Bug 2502763 Added more parameters to clf routines
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_derive_part_and_rate_cvg';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
--
procedure get_los_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_los_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_los_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           lsf.los_det_cd,
           lsf.los_dt_to_use_cd,
           lsf.use_overid_svc_dt_flag,
           lsf.los_uom,
           lsf.los_det_rl,
           lsf.los_dt_to_use_rl,
           lsf.los_calc_rl,
           lsf.rndg_cd,
           lsf.rndg_rl,
           lsf.mn_los_num,
           lsf.mx_los_num
    from   ben_los_fctr lsf,
           ben_los_rt_f lsr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
    and    vpf.business_group_id = lsr.business_group_id
    and    p_effective_date
           between lsr.effective_start_date
           and     lsr.effective_end_date
    and    lsr.los_fctr_id = lsf.los_fctr_id
    and    lsr.business_group_id = lsf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(lsf.mn_los_num,p_new_val) and
             --p_new_val < ceil( nvl(lsf.mx_los_num,p_new_val) + 0.001 ) )
             p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(lsf.mn_los_num,p_new_val) or
              --p_new_val >= ceil( nvl(lsf.mx_los_num,p_new_val))+ 0.001 ) and
             p_new_val >=  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  ) and

              p_old_val >= nvl(lsf.mn_los_num,p_old_val) and
              --p_old_val < ceil(nvl(lsf.mx_los_num,p_old_val))+ 0.001 )
             p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) , trunc(nvl(lsf.mx_los_num,p_old_val))
                         ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                         nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_los_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_los_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_los_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_los_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_los_rt_rec(l_index);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_los_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_los_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_los_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_los_rt_rec(l_index);
      --
    close c1;
    --
end get_los_pl_rate;
--
procedure get_los_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_los_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_los_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           lsf.los_det_cd,
           lsf.los_dt_to_use_cd,
           lsf.use_overid_svc_dt_flag,
           lsf.los_uom,
           lsf.los_det_rl,
           lsf.los_dt_to_use_rl,
           lsf.los_calc_rl,
           lsf.rndg_cd,
           lsf.rndg_rl,
           lsf.mn_los_num,
           lsf.mx_los_num
    from   ben_los_fctr lsf,
           ben_los_rt_f lsr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
    and    vpf.business_group_id = lsr.business_group_id
    and    p_effective_date
           between lsr.effective_start_date
           and     lsr.effective_end_date
    and    lsr.los_fctr_id = lsf.los_fctr_id
    and    lsr.business_group_id = lsf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(lsf.mn_los_num,p_new_val) and
             --p_new_val < ceil( nvl(lsf.mx_los_num,p_new_val) + 0.001 ) )
             p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(lsf.mn_los_num,p_new_val) or
             --p_new_val >= ceil( nvl(lsf.mx_los_num,p_new_val))+ 0.001 ) and
             p_new_val >=  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  ) and

              p_old_val >= nvl(lsf.mn_los_num,p_old_val) and
             --p_old_val < ceil(nvl(lsf.mx_los_num,p_old_val))+ 0.001 )
             p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) , trunc(nvl(lsf.mx_los_num,p_old_val))
                         ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                         nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_los_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_los_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_los_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_los_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_los_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_los_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_los_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_los_rt_rec(l_index);
      --
    close c1;
    --
end get_los_oipl_rate;
--
procedure get_los_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_los_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_los_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           lsf.los_det_cd,
           lsf.los_dt_to_use_cd,
           lsf.use_overid_svc_dt_flag,
           lsf.los_uom,
           lsf.los_det_rl,
           lsf.los_dt_to_use_rl,
           lsf.los_calc_rl,
           lsf.rndg_cd,
           lsf.rndg_rl,
           lsf.mn_los_num,
           lsf.mx_los_num
    from   ben_los_fctr lsf,
           ben_los_rt_f lsr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.plip_id = p_plip_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
    and    vpf.business_group_id = lsr.business_group_id
    and    p_effective_date
           between lsr.effective_start_date
           and     lsr.effective_end_date
    and    lsr.los_fctr_id = lsf.los_fctr_id
    and    lsr.business_group_id = lsf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(lsf.mn_los_num,p_new_val) and
             --p_new_val < ceil( nvl(lsf.mx_los_num,p_new_val)+0.001))
             p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(lsf.mn_los_num,p_new_val) or
              --p_new_val >= ceil(nvl(lsf.mx_los_num,p_new_val))+0.001) and
             p_new_val >=  decode(nvl(lsf.mx_los_num,p_new_val) , trunc(nvl(lsf.mx_los_num,p_new_val))
                         ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                         nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(lsf.mn_los_num,p_old_val) and
              --p_old_val < ceil(nvl(lsf.mx_los_num,p_old_val))+0.001)
             p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) , trunc(nvl(lsf.mx_los_num,p_old_val))
                         ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                         nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                         nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_los_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_los_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_los_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_los_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_los_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_los_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_los_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_los_rt_rec(l_index);
      --
    close c1;
    --
end get_los_plip_rate;
--
procedure get_los_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_los_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_los_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_los_pl_rate(p_pl_id             => p_pl_id,
                    p_old_val           => p_old_val,
                    p_new_val           => p_new_val,
                    p_business_group_id => p_business_group_id,
                    p_effective_date    => p_effective_date,
                    p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_los_oipl_rate(p_oipl_id           => p_oipl_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_los_plip_rate(p_plip_id           => p_plip_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_los_rate;
--
procedure get_age_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_age_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_age_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           agf.age_det_cd,
           agf.age_to_use_cd,
           agf.age_uom,
           agf.age_det_rl,
           agf.rndg_cd,
           agf.rndg_rl,
           agf.age_calc_rl,
           agf.mn_age_num,
           agf.mx_age_num
    from   ben_age_fctr agf,
           ben_age_rt_f art,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
    and    vpf.business_group_id = art.business_group_id
    and    p_effective_date
           between art.effective_start_date
           and     art.effective_end_date
    and    art.age_fctr_id = agf.age_fctr_id
    and    art.business_group_id = agf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(agf.mn_age_num,p_new_val) and
             --p_new_val < ceil( nvl(agf.mx_age_num,p_new_val)+0.001))
             p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(agf.mn_age_num,p_new_val) or
              --p_new_val >= ceil(nvl(agf.mx_age_num,p_new_val))+0.001) and
             p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(agf.mn_age_num,p_old_val) and
              --p_old_val < ceil(nvl(agf.mx_age_num,p_old_val))+0.001)
             p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) , trunc(nvl(agf.mx_age_num,p_old_val))
                         ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                         nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                         nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_age_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_age_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_age_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_age_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val ind p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_age_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_age_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_age_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_age_rt_rec(l_index);
      --
    close c1;
    --
end get_age_pl_rate;
--
procedure get_age_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_age_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_age_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           agf.age_det_cd,
           agf.age_to_use_cd,
           agf.age_uom,
           agf.age_det_rl,
           agf.rndg_cd,
           agf.rndg_rl,
           agf.age_calc_rl,
           agf.mn_age_num,
           agf.mx_age_num
    from   ben_age_fctr agf,
           ben_age_rt_f art,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
    and    vpf.business_group_id = art.business_group_id
    and    p_effective_date
           between art.effective_start_date
           and     art.effective_end_date
    and    art.age_fctr_id = agf.age_fctr_id
    and    art.business_group_id = agf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(agf.mn_age_num,p_new_val) and
             --p_new_val < ceil(nvl(agf.mx_age_num,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(agf.mn_age_num,p_new_val) or
              --p_new_val >= ceil(nvl(agf.mx_age_num,p_new_val))+0.001 ) and
             p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(agf.mn_age_num,p_old_val) and
              --p_old_val < ceil(nvl(agf.mx_age_num,p_old_val))+0.001 )
             p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) , trunc(nvl(agf.mx_age_num,p_old_val))
                         ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                         nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                         nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_age_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_age_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_age_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_age_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_age_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_age_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_age_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_age_rt_rec(l_index);
      --
    close c1;
    --
end get_age_oipl_rate;
--
procedure get_age_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_age_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_age_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           agf.age_det_cd,
           agf.age_to_use_cd,
           agf.age_uom,
           agf.age_det_rl,
           agf.rndg_cd,
           agf.rndg_rl,
           agf.age_calc_rl,
           agf.mn_age_num,
           agf.mx_age_num
    from   ben_cvg_amt_calc_mthd_f abr,
           ben_bnft_vrbl_rt_f avr,
           ben_vrbl_rt_prfl_f vpf,
           ben_age_rt_f art,
           ben_age_fctr agf
    where  abr.plip_id = p_plip_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
    and    p_effective_date
           between art.effective_start_date
           and     art.effective_end_date
    and    art.age_fctr_id = agf.age_fctr_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(agf.mn_age_num,p_new_val) and
             --p_new_val < ceil(nvl(agf.mx_age_num,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(agf.mn_age_num,p_new_val) or
              --p_new_val >= ceil(nvl(agf.mx_age_num,p_new_val))+0.001 )  and
             p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) , trunc(nvl(agf.mx_age_num,p_new_val))
                         ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                         nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                         nvl(agf.mx_age_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(agf.mn_age_num,p_old_val) and
              --p_old_val < ceil(nvl(agf.mx_age_num,p_old_val))+0.001 )
             p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) , trunc(nvl(agf.mx_age_num,p_old_val))
                         ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                         nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                         nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_age_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_age_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_age_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_age_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_age_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_age_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_age_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_age_rt_rec(l_index);
      --
    close c1;
    --
end get_age_plip_rate;
--
procedure get_age_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_age_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_age_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_age_pl_rate(p_pl_id             => p_pl_id,
                    p_old_val           => p_old_val,
                    p_new_val           => p_new_val,
                    p_business_group_id => p_business_group_id,
                    p_effective_date    => p_effective_date,
                    p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_age_oipl_rate(p_oipl_id           => p_oipl_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_age_plip_rate(p_plip_id           => p_plip_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_age_rate;
--
procedure get_comp_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_clf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comp_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           clf.comp_lvl_uom,
           clf.comp_src_cd,
           clf.comp_lvl_det_cd,
           clf.comp_lvl_det_rl,
           clf.rndg_cd,
           clf.rndg_rl,
           clf.mn_comp_val,
           clf.mx_comp_val,
           clf.bnfts_bal_id,
           clf.defined_balance_id,
           clf.sttd_sal_prdcty_cd,
           clf.comp_lvl_fctr_id,
           clf.comp_calc_rl
    from   ben_comp_lvl_fctr clf,
           ben_comp_lvl_rt_f clr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
    and    vpf.business_group_id = clr.business_group_id
    and    p_effective_date
           between clr.effective_start_date
           and     clr.effective_end_date
    and    clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
    and    clr.business_group_id = clf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(clf.mn_comp_val,p_new_val) and
             --p_new_val < ceil(nvl(clf.mx_comp_val,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(clf.mn_comp_val,p_new_val) or
              --p_new_val >= ceil(nvl(clf.mx_comp_val,p_new_val))+0.001 )  and
             p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(clf.mn_comp_val,p_old_val) and
              --p_old_val < ceil(nvl(clf.mx_comp_val,p_old_val))+0.001 )
             p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) , trunc(nvl(clf.mx_comp_val,p_old_val))
                         ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                         nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_clf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_clf_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_clf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_clf_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_clf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_clf_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_clf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_clf_rt_rec(l_index);
      --
    close c1;
    --
end get_comp_pl_rate;
--
procedure get_comp_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_clf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comp_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           clf.comp_lvl_uom,
           clf.comp_src_cd,
           clf.comp_lvl_det_cd,
           clf.comp_lvl_det_rl,
           clf.rndg_cd,
           clf.rndg_rl,
           clf.mn_comp_val,
           clf.mx_comp_val,
           clf.bnfts_bal_id,
           clf.defined_balance_id,
           clf.sttd_sal_prdcty_cd,
           clf.comp_lvl_fctr_id,
           clf.comp_calc_rl
    from   ben_comp_lvl_fctr clf,
           ben_comp_lvl_rt_f clr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
    and    vpf.business_group_id = clr.business_group_id
    and    p_effective_date
           between clr.effective_start_date
           and     clr.effective_end_date
    and    clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
    and    clr.business_group_id = clf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(clf.mn_comp_val,p_new_val) and
             --p_new_val < ceil(nvl(clf.mx_comp_val,p_new_val)+ 0.001 ) )
             p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(clf.mn_comp_val,p_new_val) or
              --p_new_val >= ceil(nvl(clf.mx_comp_val,p_new_val))+ 0.001 ) and
             p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(clf.mn_comp_val,p_old_val) and
              --p_old_val < ceil(nvl(clf.mx_comp_val,p_old_val))+ 0.001 )
             p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) , trunc(nvl(clf.mx_comp_val,p_old_val))
                         ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                         nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_clf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_clf_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_clf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_clf_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_clf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_clf_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_clf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_clf_rt_rec(l_index);
      --
    close c1;
    --
end get_comp_oipl_rate;
--
procedure get_comp_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_clf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comp_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           clf.comp_lvl_uom,
           clf.comp_src_cd,
           clf.comp_lvl_det_cd,
           clf.comp_lvl_det_rl,
           clf.rndg_cd,
           clf.rndg_rl,
           clf.mn_comp_val,
           clf.mx_comp_val,
           clf.bnfts_bal_id,
           clf.defined_balance_id,
           clf.sttd_sal_prdcty_cd,
           clf.comp_lvl_fctr_id,
           clf.comp_calc_rl
    from   ben_comp_lvl_fctr clf,
           ben_comp_lvl_rt_f clr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.plip_id = p_plip_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
    and    vpf.business_group_id = clr.business_group_id
    and    p_effective_date
           between clr.effective_start_date
           and     clr.effective_end_date
    and    clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
    and    clr.business_group_id = clf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(clf.mn_comp_val,p_new_val) and
             --p_new_val < ceil(nvl(clf.mx_comp_val,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(clf.mn_comp_val,p_new_val) or
              --p_new_val >= ceil(nvl(clf.mx_comp_val,p_new_val))+0.001 )  and
             p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) , trunc(nvl(clf.mx_comp_val,p_new_val))
                         ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                         nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(clf.mn_comp_val,p_old_val) and
              --p_old_val < ceil(nvl(clf.mx_comp_val,p_old_val))+0.001 )
             p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) , trunc(nvl(clf.mx_comp_val,p_old_val))
                         ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                         nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                         nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_clf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_clf_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_clf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_clf_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_clf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_clf_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_clf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_clf_rt_rec(l_index);
      --
    close c1;
    --
end get_comp_plip_rate;
--
procedure get_comp_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_clf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comp_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_comp_pl_rate(p_pl_id             => p_pl_id,
                     p_old_val           => p_old_val,
                     p_new_val           => p_new_val,
                     p_business_group_id => p_business_group_id,
                     p_effective_date    => p_effective_date,
                     p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_comp_oipl_rate(p_oipl_id           => p_oipl_id,
                       p_old_val           => p_old_val,
                       p_new_val           => p_new_val,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_comp_plip_rate(p_plip_id           => p_plip_id,
                       p_old_val           => p_old_val,
                       p_new_val           => p_new_val,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_comp_rate;
--
procedure get_comb_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_cla_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comb_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           cla.los_fctr_id,
           cla.age_fctr_id,
           cla.cmbnd_min_val,
           cla.cmbnd_max_val
    from   ben_cmbn_age_los_fctr cla,
           ben_cmbn_age_los_rt_f cmr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
    and    vpf.business_group_id = cmr.business_group_id
    and    p_effective_date
           between cmr.effective_start_date
           and     cmr.effective_end_date
    and    cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
    and    cmr.business_group_id = cla.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(cla.cmbnd_min_val,p_new_val) and
             --p_new_val < ceil( nvl(cla.cmbnd_max_val,p_new_val)+ 0.001 ) )
             p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(cla.cmbnd_min_val,p_new_val) or
              --p_new_val >= ceil(nvl(cla.cmbnd_max_val,p_new_val))+0.001 ) and
             p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(cla.cmbnd_min_val,p_old_val) and
              --p_old_val < ceil(nvl(cla.cmbnd_max_val,p_old_val))+0.001 )
             p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) , trunc(nvl(cla.cmbnd_max_val,p_old_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                         nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_cla_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_cla_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_cla_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_cla_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_cla_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_cla_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_cla_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_cla_rt_rec(l_index);
      --
    close c1;
    --
end get_comb_pl_rate;
--
procedure get_comb_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_cla_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comb_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           cla.los_fctr_id,
           cla.age_fctr_id,
           cla.cmbnd_min_val,
           cla.cmbnd_max_val
    from   ben_cmbn_age_los_fctr cla,
           ben_cmbn_age_los_rt_f cmr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
    and    vpf.business_group_id = cmr.business_group_id
    and    p_effective_date
           between cmr.effective_start_date
           and     cmr.effective_end_date
    and    cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
    and    cmr.business_group_id = cla.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(cla.cmbnd_min_val,p_new_val) and
             --p_new_val < ceil(nvl(cla.cmbnd_max_val,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(cla.cmbnd_min_val,p_new_val) or
              --p_new_val >= ceil(nvl(cla.cmbnd_max_val,p_new_val))+0.001 ) and
             p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(cla.cmbnd_min_val,p_old_val) and
              --p_old_val < ceil(nvl(cla.cmbnd_max_val,p_old_val))+0.001 )
             p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) , trunc(nvl(cla.cmbnd_max_val,p_old_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                         nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_cla_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_cla_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_cla_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_cla_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_cla_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_cla_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_cla_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_cla_rt_rec(l_index);
      --
    close c1;
    --
end get_comb_oipl_rate;
--
procedure get_comb_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_cla_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comb_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           cla.los_fctr_id,
           cla.age_fctr_id,
           cla.cmbnd_min_val,
           cla.cmbnd_max_val
    from   ben_cmbn_age_los_fctr cla,
           ben_cmbn_age_los_rt_f cmr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.plip_id = p_plip_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
    and    vpf.business_group_id = cmr.business_group_id
    and    p_effective_date
           between cmr.effective_start_date
           and     cmr.effective_end_date
    and    cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
    and    cmr.business_group_id = cla.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(cla.cmbnd_min_val,p_new_val) and
             --p_new_val < ceil(nvl(cla.cmbnd_max_val,p_new_val)+ 0.001 ) )
             p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(cla.cmbnd_min_val,p_new_val) or
              --p_new_val >= ceil(nvl(cla.cmbnd_max_val,p_new_val))+ 0.001 )  and
             p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) , trunc(nvl(cla.cmbnd_max_val,p_new_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                         nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(cla.cmbnd_min_val,p_old_val) and
              --p_old_val < ceil(nvl(cla.cmbnd_max_val,p_old_val))+ 0.001 )
             p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) , trunc(nvl(cla.cmbnd_max_val,p_old_val))
                         ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                         nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                         nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_cla_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_cla_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_cla_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_cla_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_cla_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_cla_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_cla_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_cla_rt_rec(l_index);
      --
    close c1;
    --
end get_comb_plip_rate;
--
procedure get_comb_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_cla_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_comb_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_comb_pl_rate(p_pl_id             => p_pl_id,
                     p_old_val           => p_old_val,
                     p_new_val           => p_new_val,
                     p_business_group_id => p_business_group_id,
                     p_effective_date    => p_effective_date,
                     p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_comb_oipl_rate(p_oipl_id           => p_oipl_id,
                       p_old_val           => p_old_val,
                       p_new_val           => p_new_val,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_comb_plip_rate(p_plip_id           => p_plip_id,
                       p_old_val           => p_old_val,
                       p_new_val           => p_new_val,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_comb_rate;
--
procedure get_pct_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_pff_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_pct_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           pff.use_prmry_asnt_only_flag,
           pff.use_sum_of_all_asnts_flag,
           pff.rndg_cd,
           pff.rndg_rl,
           pff.mn_pct_val,
           pff.mx_pct_val
    from   ben_pct_fl_tm_fctr pff,
           ben_pct_fl_tm_rt_f pfr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
    and    vpf.business_group_id = pfr.business_group_id
    and    p_effective_date
           between pfr.effective_start_date
           and     pfr.effective_end_date
    and    pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
    and    pfr.business_group_id = pff.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(pff.mn_pct_val,p_new_val) and
             (p_new_val*100)  < (nvl(pff.mx_pct_val,p_new_val)*100)+1)
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(pff.mn_pct_val,p_new_val) or
              (p_new_val*100) >= (nvl(pff.mx_pct_val,p_new_val)*100)+1) and
              p_old_val >= nvl(pff.mn_pct_val,p_old_val) and
              (p_old_val*100) < (nvl(pff.mx_pct_val,p_old_val)*100)+1)
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_pff_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_pff_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_pff_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_pff_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_pff_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_pff_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_pff_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_pff_rt_rec(l_index);
      --
    close c1;
    --
end get_pct_pl_rate;
--
procedure get_pct_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_pff_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_pct_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           pff.use_prmry_asnt_only_flag,
           pff.use_sum_of_all_asnts_flag,
           pff.rndg_cd,
           pff.rndg_rl,
           pff.mn_pct_val,
           pff.mx_pct_val
    from   ben_pct_fl_tm_fctr pff,
           ben_pct_fl_tm_rt_f pfr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
    and    vpf.business_group_id = pfr.business_group_id
    and    p_effective_date
           between pfr.effective_start_date
           and     pfr.effective_end_date
    and    pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
    and    pfr.business_group_id = pff.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(pff.mn_pct_val,p_new_val) and
             (p_new_val*100) < (nvl(pff.mx_pct_val,p_new_val)*100)+1)
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(pff.mn_pct_val,p_new_val) or
              (p_new_val*100) >= (nvl(pff.mx_pct_val,p_new_val)*100)+1) and
              p_old_val >= nvl(pff.mn_pct_val,p_old_val) and
              (p_old_val*100) < (nvl(pff.mx_pct_val,p_old_val)*100)+1)
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_pff_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_pff_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_pff_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_pff_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_pff_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_pff_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_pff_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_pff_rt_rec(l_index);
      --
    close c1;
    --
end get_pct_oipl_rate;
--
procedure get_pct_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_pff_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_pct_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           pff.use_prmry_asnt_only_flag,
           pff.use_sum_of_all_asnts_flag,
           pff.rndg_cd,
           pff.rndg_rl,
           pff.mn_pct_val,
           pff.mx_pct_val
    from   ben_pct_fl_tm_fctr pff,
           ben_pct_fl_tm_rt_f pfr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.plip_id = p_plip_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
    and    vpf.business_group_id = pfr.business_group_id
    and    p_effective_date
           between pfr.effective_start_date
           and     pfr.effective_end_date
    and    pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
    and    pfr.business_group_id = pff.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(pff.mn_pct_val,p_new_val) and
             (p_new_val*100) < (nvl(pff.mx_pct_val,p_new_val)*100)+1)
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(pff.mn_pct_val,p_new_val) or
              (p_new_val*100) >= (nvl(pff.mx_pct_val,p_new_val)*100)+1) and
              p_old_val >= nvl(pff.mn_pct_val,p_old_val) and
              (p_new_val*100) < (nvl(pff.mx_pct_val,p_old_val)*100)+1)
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_pff_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_pff_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_pff_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_pff_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_pff_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_pff_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_pff_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_pff_rt_rec(l_index);
      --
    close c1;
    --
end get_pct_plip_rate;
--
procedure get_pct_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_pff_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_pct_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_pct_pl_rate(p_pl_id             => p_pl_id,
                    p_old_val           => p_old_val,
                    p_new_val           => p_new_val,
                    p_business_group_id => p_business_group_id,
                    p_effective_date    => p_effective_date,
                    p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_pct_oipl_rate(p_oipl_id           => p_oipl_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_pct_plip_rate(p_plip_id           => p_plip_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_pct_rate;
--
procedure get_hours_pl_rate
 (p_pl_id                  in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_hours_pl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_pl_id,
           'Y',
           hwf.hrs_src_cd,
           hwf.hrs_wkd_det_cd,
           hwf.hrs_wkd_det_rl,
           hwf.rndg_cd,
           hwf.rndg_rl,
           hwf.defined_balance_id,
           hwf.bnfts_bal_id,
           hwf.mn_hrs_num,
           hwf.mx_hrs_num,
           hwf.once_r_cntug_cd,
           hwf.hrs_wkd_calc_rl
    from   ben_hrs_wkd_in_perd_fctr hwf,
           ben_hrs_wkd_in_perd_rt_f hwr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.pl_id = p_pl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
    and    vpf.business_group_id = hwr.business_group_id
    and    p_effective_date
           between hwr.effective_start_date
           and     hwr.effective_end_date
    and    hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
    and    hwr.business_group_id = hwf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(hwf.mn_hrs_num,p_new_val) and
             --p_new_val < ceil(nvl(hwf.mx_hrs_num,p_new_val)+0.001) )
             p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(hwf.mn_hrs_num,p_new_val) or
              --p_new_val >= ceil(nvl(hwf.mx_hrs_num,p_new_val))+0.001) and
             p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(hwf.mn_hrs_num,p_old_val) and
              --p_old_val < ceil(nvl(hwf.mx_hrs_num,p_old_val)) +0.001)
             p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) , trunc(nvl(hwf.mx_hrs_num,p_old_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                         nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_pl_id,g_hash_key);
  --
  if not g_cache_pl_hwf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_pl_hwf_rt_rec(l_index).id <> p_pl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_pl_hwf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_pl_hwf_rt_rec(l_index).id = p_pl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_pl_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_pl_hwf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_pl_hwf_rt_rec(l_index).id := p_pl_id;
          g_cache_pl_hwf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_pl_hwf_rt_rec(l_index);
      --
    close c1;
    --
end get_hours_pl_rate;
--
procedure get_hours_oipl_rate
 (p_oipl_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_hours_oipl_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_oipl_id,
           'Y',
           hwf.hrs_src_cd,
           hwf.hrs_wkd_det_cd,
           hwf.hrs_wkd_det_rl,
           hwf.rndg_cd,
           hwf.rndg_rl,
           hwf.defined_balance_id,
           hwf.bnfts_bal_id,
           hwf.mn_hrs_num,
           hwf.mx_hrs_num,
           hwf.once_r_cntug_cd,
           hwf.hrs_wkd_calc_rl
    from   ben_hrs_wkd_in_perd_fctr hwf,
           ben_hrs_wkd_in_perd_rt_f hwr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.oipl_id = p_oipl_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
    and    vpf.business_group_id = hwr.business_group_id
    and    p_effective_date
           between hwr.effective_start_date
           and     hwr.effective_end_date
    and    hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
    and    hwr.business_group_id = hwf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(hwf.mn_hrs_num,p_new_val) and
             --p_new_val < ceil( nvl(hwf.mx_hrs_num,p_new_val) +0.001))
             p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(hwf.mn_hrs_num,p_new_val) or
              --p_new_val >= ceil(nvl(hwf.mx_hrs_num,p_new_val))+0.001) and
             p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(hwf.mn_hrs_num,p_old_val) and
              --p_old_val < ceil(nvl(hwf.mx_hrs_num,p_old_val))+0.001)
             p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) , trunc(nvl(hwf.mx_hrs_num,p_old_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                         nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_oipl_id,g_hash_key);
  --
  if not g_cache_oipl_hwf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_oipl_hwf_rt_rec(l_index).id <> p_oipl_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_oipl_hwf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_oipl_hwf_rt_rec(l_index).id = p_oipl_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_oipl_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_oipl_hwf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_oipl_hwf_rt_rec(l_index).id := p_oipl_id;
          g_cache_oipl_hwf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_oipl_hwf_rt_rec(l_index);
      --
    close c1;
    --
end get_hours_oipl_rate;
--
procedure get_hours_plip_rate
 (p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_hours_plip_rate';
  --
  -- Define Cursor
  --
  cursor c1 is
    select p_plip_id,
           'Y',
           hwf.hrs_src_cd,
           hwf.hrs_wkd_det_cd,
           hwf.hrs_wkd_det_rl,
           hwf.rndg_cd,
           hwf.rndg_rl,
           hwf.defined_balance_id,
           hwf.bnfts_bal_id,
           hwf.mn_hrs_num,
           hwf.mx_hrs_num,
           hwf.once_r_cntug_cd,
           hwf.hrs_wkd_calc_rl
    from   ben_hrs_wkd_in_perd_fctr hwf,
           ben_hrs_wkd_in_perd_rt_f hwr,
           ben_vrbl_rt_prfl_f vpf,
           ben_bnft_vrbl_rt_f avr,
           ben_cvg_amt_calc_mthd_f abr
    where  abr.plip_id = p_plip_id
    and    abr.business_group_id = p_business_group_id
    and    p_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cvg_amt_calc_mthd_id = avr.cvg_amt_calc_mthd_id
    and    abr.business_group_id = avr.business_group_id
    and    p_effective_date
           between avr.effective_start_date
           and     avr.effective_end_date
    and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
    and    avr.business_group_id = vpf.business_group_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
    and    vpf.business_group_id = hwr.business_group_id
    and    p_effective_date
           between hwr.effective_start_date
           and     hwr.effective_end_date
    and    hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
    and    hwr.business_group_id = hwf.business_group_id
    and    ((p_new_val is not null and
             p_old_val is not null and
             p_new_val >= nvl(hwf.mn_hrs_num,p_new_val) and
             --p_new_val < ceil(nvl(hwf.mx_hrs_num,p_new_val)+0.001 ) )
             p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
            or
            (p_new_val is not null and
             p_old_val is not null and
             (p_new_val < nvl(hwf.mn_hrs_num,p_new_val) or
              --p_new_val >= ceil(nvl(hwf.mx_hrs_num,p_new_val))+0.001 ) and
             p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) , trunc(nvl(hwf.mx_hrs_num,p_new_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                         nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  ) and
              p_old_val >= nvl(hwf.mn_hrs_num,p_old_val) and
              --p_old_val < ceil(nvl(hwf.mx_hrs_num,p_old_val))+0.001 )
             p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) , trunc(nvl(hwf.mx_hrs_num,p_old_val))
                         ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                         nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                         nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
           or
           (p_new_val is null and
            p_old_val is null));
  --
  --
  l_index          binary_integer;
  l_not_hash_found boolean;
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Steps to do process
  --
  -- 1) Try and get value from cache
  -- 2) If can get from cache then copy to output record
  -- 3) If can't get from cache do db hit and then
  --    copy to cache record and then copy to output record.
  --
  -- Get hashed index value
  --
  l_index := mod(p_plip_id,g_hash_key);
  --
  if not g_cache_plip_hwf_rt_rec.exists(l_index) then
    --
    -- Lets store the hash value in this index
    --
    raise no_data_found;
    --
  else
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_plip_hwf_rt_rec(l_index).id <> p_plip_id then
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      --
      l_not_hash_found := false;
      --
      while not l_not_hash_found loop
        --
        l_index := l_index+g_hash_jump;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_plip_hwf_rt_rec.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          raise no_data_found;
          --
        else
          --
          -- Make sure the index is the correct one
          --
          if g_cache_plip_hwf_rt_rec(l_index).id = p_plip_id then
            --
            -- We have a match so the hashed value  has been stored before
            --
            l_not_hash_found := true;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If p_old_val and p_new_val is set this means we are trying to retrieve
  -- the correct rate for the calculated value.
  -- Previously we just cached the first rate we
  -- found since we needed the determination code, the correct age,los code,etc
  -- By killing the cache and forcing the value to be removed we cache the
  -- correct rate profile for the case we need.
  --
  if p_old_val is not null and p_new_val is not null then
    --
    raise no_data_found;
    --
  end if;
  --
  p_rec := g_cache_plip_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when no_data_found then
    --
    -- The record has not been cached yet so lets cache it
    --
    open c1;
      --
      fetch c1 into g_cache_plip_hwf_rt_rec(l_index);
      if p_old_val is null and p_new_val is null then
        --
        if c1%notfound then
          --
          g_cache_plip_hwf_rt_rec(l_index).id := p_plip_id;
          g_cache_plip_hwf_rt_rec(l_index).exist := 'N';
          --
        end if;
        --
      end if;
      --
      p_rec := g_cache_plip_hwf_rt_rec(l_index);
      --
    close c1;
    --
end get_hours_plip_rate;
--
procedure get_hours_rate
 (p_pl_id                  in  number,
  p_oipl_id                in  number,
  p_plip_id                in  number,
  p_old_val                in  number default null,
  p_new_val                in  number default null,
  p_business_group_id      in  number,
  p_effective_date         in  date,
  p_rec                    out nocopy ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj) is
  --
  l_package          varchar2(80) := g_package||'.get_hours_rate';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Derive which data type we are dealing with
  --
  if p_pl_id is not null then
    --
    get_hours_pl_rate(p_pl_id             => p_pl_id,
                      p_old_val           => p_old_val,
                      p_new_val           => p_new_val,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_rec               => p_rec);
    --
  elsif p_oipl_id is not null then
    --
    get_hours_oipl_rate(p_oipl_id           => p_oipl_id,
                        p_old_val           => p_old_val,
                        p_new_val           => p_new_val,
                        p_business_group_id => p_business_group_id,
                        p_effective_date    => p_effective_date,
                        p_rec               => p_rec);
    --
  elsif p_plip_id is not null then
    --
    get_hours_plip_rate(p_plip_id           => p_plip_id,
                        p_old_val           => p_old_val,
                        p_new_val           => p_new_val,
                        p_business_group_id => p_business_group_id,
                        p_effective_date    => p_effective_date,
                        p_rec               => p_rec);
    --
  end if;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end get_hours_rate;
--
procedure clear_down_cache is
  --
  l_package          varchar2(80) := g_package||'.clear_down_cache';
  --
begin
  --
  -- hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Clear down all caches
  --
  g_cache_pl_los_rt_rec.delete;
  g_cache_oipl_los_rt_rec.delete;
  g_cache_plip_los_rt_rec.delete;
  g_cache_pl_age_rt_rec.delete;
  g_cache_oipl_age_rt_rec.delete;
  g_cache_plip_age_rt_rec.delete;
  g_cache_pl_clf_rt_rec.delete;
  g_cache_oipl_clf_rt_rec.delete;
  g_cache_plip_clf_rt_rec.delete;
  g_cache_pl_cla_rt_rec.delete;
  g_cache_oipl_cla_rt_rec.delete;
  g_cache_plip_cla_rt_rec.delete;
  g_cache_pl_pff_rt_rec.delete;
  g_cache_oipl_pff_rt_rec.delete;
  g_cache_plip_pff_rt_rec.delete;
  g_cache_pl_hwf_rt_rec.delete;
  g_cache_oipl_hwf_rt_rec.delete;
  g_cache_plip_hwf_rt_rec.delete;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
end clear_down_cache;
--
end ben_derive_part_and_rate_cvg;

/
