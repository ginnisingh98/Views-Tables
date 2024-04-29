--------------------------------------------------------
--  DDL for Package Body BEN_DERIVE_PART_AND_RATE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVE_PART_AND_RATE_CACHE" AS
/* $Header: bendrpac.pkb 120.1 2005/08/05 11:44:59 mmudigon noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Derive Participation and Rate Cache Routine
Purpose
        This package is used to return or retrieve information that is
        needed for rates and or factors.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        23 Nov 98        G Perry    115.0      Created.
        20 Dec 98        G Perry    115.1      Support for hours worked.
        17 Feb 99        G Perry    115.2      Changed hours worked cursor so
                                               it selects once_r_cntug_cd.
        04 May 99        G Perry    115.3      Cache support for PTIP, PLIP.
                                               Added in hashing utility.
        06 May 99        G Perry    115.4      Backport for Fidelity.
        06 May 99        G Perry    115.5      Leapfrog from 115.3
        04 Aug 99        T Guy      115.6      Enhanced Base Age calc to take
                                               into account spouse/child DOB
        23 Aug 99        G Perry    115.6      Added nocopy compiler directive.
                                               Removed trace messages.
                                               Hashing done locally.
        06 Oct 99        mhoyes     115.8    - Tuned c1 cursors in,
                                               - get_age_plip_rate
                                               - get_age_ptip_rate
        10 Jan 00        pbodla     115.9    - Added los_calc_rl to c1 cursor in
                                               get_los_pgm_elig, get_los_pl_elig
                                               get_los_plip_elig, get_los_ptip_elig,
                                               get_los_pgm_elig ,
                                               get_los_stated   , get_los_pgm_rate ,
                                               get_los_pl_rate  , get_los_oipl_rate,
                                               get_los_plip_rate, get_los_ptip_rate
        24 Jan 00        lmcdonal   115.10     Add hrs_wkd_calc_rl to hwf and
                                               comp_calc_rl to clf.  Bugs
                                               1118118, 1118113.
        07 Mar 00        gperry     115.11     Fixes for WWBUG 1195803.
        31 Mar 00        gperry     115.12     Added oiplip support.
        13 May 00        mhoyes     115.13   - CBO tuning. Removed business group
                                               restrictions from get_age_???_elig
                                               get_comp_???_elig cursors.
                                             - Replaced all binary_integer datatypes
                                               with pls_integer datatyps.
        26 Jun 00        gperry     115.14     Added age_calc_rl support.
        03 Aug 00        mhoyes     115.15   - General tuning. Removed business
                                               group restrictions.
        17-jan-01        tilak      115.16     derive factor maximaum validated with < max +  1
        16-Nov-01        ikasire    115.17     Bug 2101937 - Fixed the error in the ceil
                                               condition of version 116.2 in all cursors.
        08-Oct-02        kmahendr   115.18     Added parameters to get_los_elig,get_los_pgm_elig
                                               get_los_ptip_elig, get_los_plip_elig, get_los_pl_elig
                                               get_los_oipl_elig and modified cursor c1
        08-Oct-02        kmahendr   115.19     Added dbdrv lines
        09-Oct-02        kmahendr   115.20     added parameters in call to get_los_pl_elig,
                                               get_los_plip_elig, get_los_ptip_elig
        18-Oct-02        kmahendr   115.21     Added old_val, new_val parameters to other
                                               derived factors
        22-Oct-02        ikasire    115.22     Bug 2502763 added more parameters to clf routines
        16-Mar-02        tjesumic   115.23     bug 2853140 age factor changes.
        18-Mar-02        ikasire    115.24     Bug 2853140 Modifed the cursors to get
                                               a row when both old and new values also
                                               in the same range.
                                               Added validation to update only first time for
                                               each comp object with N in exist.
        19-May-2003      ikasire    115.25     Option Level Rates Enhancements
        30-Jun-2003      ikasire    115.27     Elpro Vapro Data model changes
        19-Aug-2003      mmudigon   115.28     gscc fix
        16-Oct-2003      rpgupta    115.29     Bug 3188198
        				       Uncommented 'and p_old_val < lsf.mn_los_num'
        				       in cursor c1 at all levels
        				       Now the cursor would return only one row and
        				       hence the ptnl le would be detected at all
        				       stages.

        28-Jul-2004     bmanyam     115.30      Bug 3761038. Split UNIONed queryies into 2.
                                                Search Text "PERFNEW".
        05-Aug-2005     mmudigon    115.31      Bug 4518047. Removed hr_utility
                                                statements at lines 305,306 and
                                                307
*/
--------------------------------------------------------------------------------
--
  g_package   VARCHAR2(80) := 'ben_derive_part_and_rate_cache';
  g_hash_key  NUMBER       := ben_hash_utility.get_hash_key;
  g_hash_jump NUMBER       := ben_hash_utility.get_hash_jump;
  --
  --Private function to get opt_id from the oipl_id
  --Option level rates enhancements
  --
  FUNCTION get_opt_id(p_oipl_id number,p_effective_date date) return number
    is
      --
      l_opt_id number ;
      cursor c_opt(p_oipl_id number,p_effective_date date) is
        select opt_id
        from ben_oipl_f otp
        where otp.oipl_id = p_oipl_id
        and   p_effective_date between otp.effective_start_date
                                  and otp.effective_end_date ;
      --
    begin
     --
     open c_opt(p_oipl_id,p_effective_date) ;
       --
       fetch c_opt into l_opt_id ;
       --
     close c_opt;
     --
     return l_opt_id ;
     --
  END get_opt_id;
  --
  --
  PROCEDURE get_los_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(lsf.mn_los_num ,p_new_val)
                   and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                 ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                  nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                   and p_old_val < lsf.mn_los_num -- uncommented this -- bug 3188198
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(lsf.mn_los_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                   ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(lsf.mn_los_num ,p_old_val)
                    and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            ) ;
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_prev_index     PLS_INTEGER;
  --
  BEGIN
    --
    hr_utility.set_location ('Entering '||l_package,10);
    hr_utility.set_location ('p_old_val '||p_old_val,10);
    hr_utility.set_location ('p_new_val '||p_new_val,10);

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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_los_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      hr_utility.set_location ('raise ndf ',10);
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_los_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_los_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            hr_utility.set_location ('raise ndf ',20);
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_los_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      hr_utility.set_location ('raise ndf ',30);
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_los_el_rec(l_index);
  --
   hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_los_el_rec(l_index);

      IF c1%NOTFOUND THEN
        --
        -- We store the value of the PK in the id so we know that there is
        -- no value for this PK.
        -- Bug 2853140 This needs to be set only called first time.
        -- If found once with p_old_val and p_new_val both passed as
        -- null, we should not reset this to N again.
        --
        if NOT g_cache_pgm_los_el_rec.EXISTS(l_index) then
          --
          g_cache_pgm_los_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_los_el_rec(l_index).exist  := 'N';
          --
        end if;
        --
      END IF;
      --
      p_rec  := g_cache_pgm_los_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_pgm_elig;
--
  PROCEDURE get_los_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(lsf.mn_los_num ,p_new_val)
                   and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                 ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                  nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                   and p_old_val < lsf.mn_los_num -- uncommented this -- bug 3188198
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(lsf.mn_los_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                   ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(lsf.mn_los_num ,p_old_val)
                    and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )
     )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            ) ;
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_los_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_los_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_los_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_los_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    IF  p_old_val IS NOT NULL
           AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_los_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_los_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        -- Bug 2853140 This needs to be set only called first time.
        -- If found once with p_old_val and p_new_val both passed as
        -- null, we should not reset this to N again.
        if NOT g_cache_pl_los_el_rec.EXISTS(l_index) then
          --
          g_cache_pl_los_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_los_el_rec(l_index).exist  := 'N';
          --
        end if ;
      --
      END IF;
      --
      p_rec  := g_cache_pl_los_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_pl_elig;
--
  PROCEDURE get_los_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(lsf.mn_los_num ,p_new_val)
                   and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                 ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                  nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                   and p_old_val < lsf.mn_los_num -- uncommented this -- bug 3188198
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(lsf.mn_los_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                   ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(lsf.mn_los_num ,p_old_val)
                    and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )
     )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            ) ;
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_los_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_los_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_los_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_los_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_oipl_los_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_los_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        -- We store the value of the PK in the id so we know that there is
        -- no value for this PK.
        --
        -- Bug 2853140 This needs to be set only called first time.
        -- If found once with p_old_val and p_new_val both passed as
        -- null, we should not reset this to N again.
        if NOT g_cache_oipl_los_el_rec.EXISTS(l_index) then
          --
          g_cache_oipl_los_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_los_el_rec(l_index).exist  := 'N';
          --
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_los_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_oipl_elig;
--
  PROCEDURE get_los_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(lsf.mn_los_num ,p_new_val)
                   and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                 ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                  nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                   and p_old_val < lsf.mn_los_num -- uncommented this -- bug 3188198
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(lsf.mn_los_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                   ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(lsf.mn_los_num ,p_old_val)
                    and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )
     )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_los_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_los_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_los_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_los_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_los_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_los_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        -- Bug 2853140 This needs to be set only called first time.
        -- If found once with p_old_val and p_new_val both passed as
        -- null, we should not reset this to N again.
        if NOT g_cache_plip_los_el_rec.EXISTS(l_index) then
          g_cache_plip_los_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_los_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_los_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_plip_elig;
--
  PROCEDURE get_los_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(lsf.mn_los_num ,p_new_val)
                   and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                 ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                  nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                   and p_old_val < lsf.mn_los_num -- uncommented this -- bug 3188198
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(lsf.mn_los_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                   ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(lsf.mn_los_num ,p_old_val)
                    and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )
     )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_los_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_los_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_los_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_los_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_los_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_los_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        -- Bug 2853140 This needs to be set only called first time.
        -- If found once with p_old_val and p_new_val both passed as
        -- null, we should not reset this to N again.
        if NOT g_cache_ptip_los_el_rec.EXISTS(l_index) then
          g_cache_ptip_los_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_los_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_los_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_ptip_elig;
--
  PROCEDURE get_los_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number
   ,p_new_val           in            number
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_los_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_los_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_los_pl_elig(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_los_oipl_elig(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_los_plip_elig(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_los_ptip_elig(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_los_elig;
--
  PROCEDURE get_los_stated(
    p_los_fctr_id       IN            NUMBER
   ,p_business_group_id IN            NUMBER
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_stated';
    --
    CURSOR c1 IS
      SELECT   p_los_fctr_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
      WHERE    lsf.los_fctr_id = p_los_fctr_id;
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_los_fctr_id
                 ,g_hash_key);
    --
    IF NOT g_cache_stated_los_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_stated_los_rec(l_index).id <> p_los_fctr_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_stated_los_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_stated_los_rec(l_index).id = p_los_fctr_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    p_rec    := g_cache_stated_los_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_stated_los_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_stated_los_rec.EXISTS(l_index) then
          g_cache_stated_los_rec(l_index).id     := p_los_fctr_id;
          g_cache_stated_los_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_stated_los_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_stated;
--
  PROCEDURE get_los_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_pgm_rate';
    --
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                 (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                     -- AND p_new_val < ceil( NVL(lsf.mx_los_num ,p_new_val) + 0.001)
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(lsf.mx_los_num
                 --                            ,p_new_val )) + 0.001 )
                 OR p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                  --    AND p_old_val < ceil( NVL(lsf.mx_los_num
                  --                     ,p_old_val)) + 0.001 )
                and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    /*  UNION ALL  PERFNEW - Following part should become the cursor c2 */
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM    ben_los_fctr lsf
              --NEW
              --,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              --NEW
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                 (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                     -- AND p_new_val < ceil( NVL(lsf.mx_los_num ,p_new_val) + 0.001)
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(lsf.mx_los_num
                 --                            ,p_new_val )) + 0.001 )
                 OR p_new_val >=   decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                  --    AND p_old_val < ceil( NVL(lsf.mx_los_num
                  --                     ,p_old_val)) + 0.001 )
                and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_los_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_los_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_new_val and p_old_val set this means we are trying to retrieve
    -- the correct rate for the calculated value. Previously we just cached
    -- the first rate we found since we needed the determination code, the
    -- correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_los_rt_rec.EXISTS(l_index) then
            g_cache_pgm_los_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_pgm_rate;
--
  PROCEDURE get_los_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_pl_rate';
    --
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val ) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )

                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >=  ceil( NVL(lsf.mx_los_num
                 --                            , p_new_val )) + 0.001 )
                              OR p_new_val >=    decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )

                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )

                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    -- UNION ALL
    CURSOR c2 IS
    SELECT   p_pl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              -- ,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              --
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val ) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )

                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >=  ceil( NVL(lsf.mx_los_num
                 --                            , p_new_val )) + 0.001 )
                              OR p_new_val >=    decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )

                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )

                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;

  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_los_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_los_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_los_rt_rec(l_index);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_los_rt_rec.EXISTS(l_index) then
            g_cache_pl_los_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_pl_rate;
--
  PROCEDURE get_los_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_oipl_rate';
    --
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id    NUMBER;
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001 ))
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             , p_new_val)) + 0.001)
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val)) + 0.001)
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
    SELECT   p_oipl_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM    ben_los_fctr lsf
              --,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = els.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001 ))
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             , p_new_val)) + 0.001)
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val)) + 0.001)
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_los_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_los_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oipl_los_rt_rec.EXISTS(l_index) then
            g_cache_oipl_los_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_oipl_rate;
--
  PROCEDURE get_los_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001))
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             ,p_new_val )) + 0.001 )
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
    SELECT   p_plip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              --,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = els.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001))
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             ,p_new_val )) + 0.001 )
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_los_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_los_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_los_rt_rec.EXISTS(l_index) then
            g_cache_plip_los_rt_rec(l_index).id     := p_plip_id;
            g_cache_plip_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_plip_rate;
--
  PROCEDURE get_los_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             ,p_new_val)) + 0.001 )
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val )) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_ptip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              --,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = els.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_new_val) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(lsf.mx_los_num
                --                             ,p_new_val)) + 0.001 )
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(lsf.mx_los_num
                --                       ,p_old_val )) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_los_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_los_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_los_rt_rec.EXISTS(l_index) then
            g_cache_ptip_los_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_ptip_rate;
--
  PROCEDURE get_los_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_los_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              ,ben_los_rt_f lsr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN lsr.effective_start_date
                   AND lsr.effective_end_date
      AND      lsr.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_new_val) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(lsf.mx_los_num
                 --                            ,p_new_val))+ 0.001)
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,lsf.los_det_cd
              ,lsf.los_dt_to_use_cd
              ,lsf.use_overid_svc_dt_flag
              ,lsf.los_uom
              ,lsf.los_det_rl
              ,lsf.los_dt_to_use_rl
              ,lsf.los_calc_rl
              ,lsf.rndg_cd
              ,lsf.rndg_rl
              ,lsf.mn_los_num
              ,lsf.mx_los_num
      FROM     ben_los_fctr lsf
              --,ben_los_rt_f lsr
              ,ben_elig_los_prte_f els
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = els.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      els.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      p_effective_date BETWEEN els.effective_start_date
                   AND els.effective_end_date
      AND      els.los_fctr_id = lsf.los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(lsf.mn_los_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_new_val) + 0.001) )
                 and p_new_val <  decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(lsf.mn_los_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(lsf.mx_los_num
                 --                            ,p_new_val))+ 0.001)
                              OR p_new_val >= decode(nvl(lsf.mx_los_num,p_new_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_new_val))
                     ,decode(nvl(lsf.mn_los_num,p_new_val), trunc(nvl(lsf.mn_los_num,p_new_val)),
                      nvl(lsf.mx_los_num,p_new_val)+1,nvl(lsf.mx_los_num,p_new_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(lsf.mn_los_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(lsf.mx_los_num
                 --                      ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(lsf.mx_los_num,p_old_val) ,
                                    trunc(nvl(lsf.mx_los_num,p_old_val))
                     ,decode(nvl(lsf.mn_los_num,p_old_val), trunc(nvl(lsf.mn_los_num,p_old_val)),
                      nvl(lsf.mx_los_num,p_old_val)+1,nvl(lsf.mx_los_num,p_old_val)+0.000000001),
                      nvl(lsf.mx_los_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_los_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_los_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_los_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_los_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_los_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_los_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_los_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_los_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_los_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_los_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_los_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_los_oiplip_rate;
--
  PROCEDURE get_los_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_los_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_los_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_los_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_los_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_los_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_los_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_los_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_los_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_los_rate;
--
  PROCEDURE get_age_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(agf.mn_age_num ,p_new_val)
                   and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                 ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                  nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                  -- and p_old_val < agf.mn_age_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(agf.mn_age_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                   ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(agf.mn_age_num ,p_old_val)
                    and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_age_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_age_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_age_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_age_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_age_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_age_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pgm_age_el_rec.EXISTS(l_index) then
          g_cache_pgm_age_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_age_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_age_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_pgm_elig;
--
  PROCEDURE get_age_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(agf.mn_age_num ,p_new_val)
                   and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                 ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                  nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                  -- and p_old_val < agf.mn_age_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(agf.mn_age_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                   ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(agf.mn_age_num ,p_old_val)
                    and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_age_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_age_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_age_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_age_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_age_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_age_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pl_age_el_rec.EXISTS(l_index) then
          g_cache_pl_age_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_age_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pl_age_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_pl_elig;
--
  PROCEDURE get_age_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(agf.mn_age_num ,p_new_val)
                   and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                 ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                  nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                  -- and p_old_val < agf.mn_age_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(agf.mn_age_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                   ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(agf.mn_age_num ,p_old_val)
                    and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_age_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_age_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_age_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_age_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_oipl_age_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_age_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_oipl_age_el_rec.EXISTS(l_index) then
          g_cache_oipl_age_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_age_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_age_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_oipl_elig;
--
  PROCEDURE get_age_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(agf.mn_age_num ,p_new_val)
                   and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                 ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                  nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                  -- and p_old_val < agf.mn_age_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(agf.mn_age_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                   ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(agf.mn_age_num ,p_old_val)
                    and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_age_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_age_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_age_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_age_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_age_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_age_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_plip_age_el_rec.EXISTS(l_index) then
          g_cache_plip_age_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_age_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_age_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_plip_elig;
--
  PROCEDURE get_age_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(agf.mn_age_num ,p_new_val)
                   and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                 ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                  nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                  -- and p_old_val < agf.mn_age_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(agf.mn_age_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                   ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(agf.mn_age_num ,p_old_val)
                    and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_age_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_age_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_age_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_age_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_age_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_age_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_ptip_age_el_rec.EXISTS(l_index) then
          g_cache_ptip_age_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_age_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_age_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_ptip_elig;
--
  PROCEDURE get_age_stated(
    p_age_fctr_id       IN            NUMBER
   ,p_business_group_id IN            NUMBER
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_stated';
    --
    CURSOR c1 IS
      SELECT   p_age_fctr_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
      WHERE    agf.age_fctr_id = p_age_fctr_id;
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_age_fctr_id
                 ,g_hash_key);
    --
    IF NOT g_cache_stated_age_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_stated_age_rec(l_index).id <> p_age_fctr_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_stated_age_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_stated_age_rec(l_index).id = p_age_fctr_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    p_rec    := g_cache_stated_age_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_stated_age_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_stated_age_rec.EXISTS(l_index) then
          g_cache_stated_age_rec(l_index).id     := p_age_fctr_id;
          g_cache_stated_age_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_stated_age_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_stated;
--
  PROCEDURE get_age_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_age_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_age_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_age_pl_elig(p_pl_id=> p_pl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_age_oipl_elig(p_oipl_id=> p_oipl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_age_plip_elig(p_plip_id=> p_plip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_age_ptip_elig(p_ptip_id=> p_ptip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_age_elig;
--
  PROCEDURE get_age_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_pgm_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_age_rt_f art
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(agf.mx_age_num
                --                       ,p_new_val ) + 0.001))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(agf.mx_age_num
                --                             ,p_new_val)) + 0.001)
                              OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(agf.mx_age_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              --,ben_age_rt_f art
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                --      AND p_new_val < ceil( NVL(agf.mx_age_num
                --                       ,p_new_val ) + 0.001))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                --            OR p_new_val >= ceil( NVL(agf.mx_age_num
                --                             ,p_new_val)) + 0.001)
                              OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(agf.mx_age_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_age_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_age_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val iand p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_age_rt_rec.EXISTS(l_index) then
            g_cache_pgm_age_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_pgm_rate;
--
  PROCEDURE get_age_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_pl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_age_rt_f art
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_new_val)+ 0.001 ))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(agf.mx_age_num
                 --                            ,p_new_val)) + 0.001)
                              OR p_new_val >= decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_old_val))  + 0.001)
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
    SELECT   p_pl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              --,ben_age_rt_f art
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_new_val)+ 0.001 ))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(agf.mx_age_num
                 --                            ,p_new_val)) + 0.001)
                              OR p_new_val >= decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                 --     AND p_old_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_old_val))  + 0.001)
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_age_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_age_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val ind p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_age_rt_rec.EXISTS(l_index) then
            g_cache_pl_age_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_pl_rate;
--
  PROCEDURE get_age_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_oipl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id  number ;
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              ,ben_age_rt_f art
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_new_val)+ 0.001 ))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(agf.mx_age_num
                 --                            ,p_new_val)) + 0.001 )
                              OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(agf.mx_age_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oipl_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_age_fctr agf
              --,ben_age_rt_f art
              ,ben_elig_age_prte_f eap
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                 --     AND p_new_val < ceil( NVL(agf.mx_age_num
                 --                      ,p_new_val)+ 0.001 ))
                 and p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                 --           OR p_new_val >= ceil( NVL(agf.mx_age_num
                 --                            ,p_new_val)) + 0.001 )
                              OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                --      AND p_old_val < ceil( NVL(agf.mx_age_num
                --                       ,p_old_val)) + 0.001 )
                 and p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_age_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_age_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oipl_age_rt_rec.EXISTS(l_index) then
            g_cache_oipl_age_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_oipl_rate;
--
  PROCEDURE get_age_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    --   ceil( NVL(agf.mx_age_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )

                                     -- ceil( NVL(agf.mx_age_num
                                     --         , p_new_val))  + 0.001 )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                     --ceil( NVL(agf.mx_age_num
                                     --  ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_plip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_elig_age_prte_f eap
              --,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    --   ceil( NVL(agf.mx_age_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )

                                     -- ceil( NVL(agf.mx_age_num
                                     --         , p_new_val))  + 0.001 )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                     --ceil( NVL(agf.mx_age_num
                                     --  ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_age_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_age_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_age_rt_rec.EXISTS(l_index) then
            g_cache_plip_age_rt_rec(l_index).id     := p_plip_id;
            g_cache_plip_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_plip_rate;
--
  PROCEDURE get_age_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --         ,p_new_val)) + 0.001)
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --   ,p_old_val)) + 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_ptip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_elig_age_prte_f eap
              --,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --         ,p_new_val)) + 0.001)
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(agf.mx_age_num
                                    --   ,p_old_val)) + 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_age_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_age_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_age_rt_rec.EXISTS(l_index) then
            g_cache_ptip_age_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_ptip_rate;
--
  PROCEDURE get_age_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_age_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN art.effective_start_date
                   AND art.effective_end_date
      AND      art.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                   --  ceil( NVL(agf.mx_age_num
                                   --    , p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                       --    ceil( NVL(agf.mx_age_num
                                       --      ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                       --  ceil( NVL(agf.mx_age_num
                                       --   ,p_old_val)) +  0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,agf.age_det_cd
              ,agf.age_to_use_cd
              ,agf.age_uom
              ,agf.age_det_rl
              ,agf.rndg_cd
              ,agf.rndg_rl
              ,agf.age_calc_rl
              ,agf.mn_age_num
              ,agf.mx_age_num
      FROM     ben_acty_base_rt_f abr
              ,ben_acty_vrbl_rt_f avr
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_elig_age_prte_f eap
              --,ben_age_rt_f art
              ,ben_age_fctr agf
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = eap.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      eap.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN eap.effective_start_date
                   AND eap.effective_end_date
      AND      eap.age_fctr_id = agf.age_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(agf.mn_age_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                   --  ceil( NVL(agf.mx_age_num
                                   --    , p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(agf.mn_age_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(agf.mx_age_num,p_new_val) ,
                                    trunc(nvl(agf.mx_age_num,p_new_val))
                     ,decode(nvl(agf.mn_age_num,p_new_val), trunc(nvl(agf.mn_age_num,p_new_val)),
                      nvl(agf.mx_age_num,p_new_val)+1,nvl(agf.mx_age_num,p_new_val)+0.000000001),
                      nvl(agf.mx_age_num,p_new_val)+0.000000001 )  )
                                       --    ceil( NVL(agf.mx_age_num
                                       --      ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(agf.mn_age_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(agf.mx_age_num,p_old_val) ,
                                    trunc(nvl(agf.mx_age_num,p_old_val))
                     ,decode(nvl(agf.mn_age_num,p_old_val), trunc(nvl(agf.mn_age_num,p_old_val)),
                      nvl(agf.mx_age_num,p_old_val)+1,nvl(agf.mx_age_num,p_old_val)+0.000000001),
                      nvl(agf.mx_age_num,p_old_val)+0.000000001 )  )
                                       --  ceil( NVL(agf.mx_age_num
                                       --   ,p_old_val)) +  0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_age_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_age_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_age_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_age_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_age_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_age_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_age_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_age_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_age_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_age_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_age_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_age_oiplip_rate;
--
  PROCEDURE get_age_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_age_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_age_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_age_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_age_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_age_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_age_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_age_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_age_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_age_rate;
--
  PROCEDURE get_comp_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(clf.mn_comp_val ,p_new_val)
                   and p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                 ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                  nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                  -- and p_old_val < clf.mn_comp_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(clf.mn_comp_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                   ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(clf.mn_comp_val ,p_old_val)
                    and p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_clf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_clf_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_clf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_clf_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_clf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_clf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pgm_clf_el_rec.EXISTS(l_index) then
          g_cache_pgm_clf_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_clf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_clf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_pgm_elig;
--
  PROCEDURE get_comp_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(clf.mn_comp_val ,p_new_val)
                   and p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                 ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                  nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                  -- and p_old_val < clf.mn_comp_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(clf.mn_comp_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                   ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(clf.mn_comp_val ,p_old_val)
                    and p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_clf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_clf_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_clf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_clf_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_clf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_clf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pl_clf_el_rec.EXISTS(l_index) then
          g_cache_pl_clf_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_clf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pl_clf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_pl_elig;
--
  PROCEDURE get_comp_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(clf.mn_comp_val ,p_new_val)
                   and p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                 ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                  nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                  -- and p_old_val < clf.mn_comp_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(clf.mn_comp_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                   ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(clf.mn_comp_val ,p_old_val)
                    and p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_clf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_clf_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_clf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_clf_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_oipl_clf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_clf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_oipl_clf_el_rec.EXISTS(l_index) then
          g_cache_oipl_clf_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_clf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_clf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_oipl_elig;
--
  PROCEDURE get_comp_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(clf.mn_comp_val ,p_new_val)
                   and p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                 ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                  nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                  -- and p_old_val < clf.mn_comp_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(clf.mn_comp_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                   ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(clf.mn_comp_val ,p_old_val)
                    and p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_clf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_clf_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_clf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_clf_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_clf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_clf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_plip_clf_el_rec.EXISTS(l_index) then
          g_cache_plip_clf_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_clf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_clf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_plip_elig;
--
  PROCEDURE get_comp_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(clf.mn_comp_val ,p_new_val)
                   and p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                 ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                  nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                  -- and p_old_val < clf.mn_comp_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(clf.mn_comp_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                   ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(clf.mn_comp_val ,p_old_val)
                    and p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_clf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_clf_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_clf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_clf_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_clf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_clf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_ptip_clf_el_rec.EXISTS(l_index) then
          g_cache_ptip_clf_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_clf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_clf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_ptip_elig;
--
  PROCEDURE get_comp_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_comp_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_comp_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_comp_pl_elig(p_pl_id=> p_pl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_comp_oipl_elig(p_oipl_id=> p_oipl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_comp_plip_elig(p_plip_id=> p_plip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_comp_ptip_elig(p_ptip_id=> p_ptip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_comp_elig;
--
  PROCEDURE get_comp_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_pgm_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                        --   ceil( NVL(clf.mx_comp_val
                                        --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --   ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                        --   ceil( NVL(clf.mx_comp_val
                                        --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --   ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_clf_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_clf_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_clf_rt_rec.EXISTS(l_index) then
            g_cache_pgm_clf_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_pgm_rate;
--
  PROCEDURE get_comp_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_pl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                        --  ceil( NVL(clf.mx_comp_val
                                        --   ,p_new_val)) + 0.001)
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                       -- ceil( NVL(clf.mx_comp_val
                                       -- ,p_old_val))+ 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                        --  ceil( NVL(clf.mx_comp_val
                                        --   ,p_new_val)) + 0.001)
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                       -- ceil( NVL(clf.mx_comp_val
                                       -- ,p_old_val))+ 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_clf_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_clf_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_clf_rt_rec.EXISTS(l_index) then
            g_cache_pl_clf_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_pl_rate;
--
  PROCEDURE get_comp_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_oipl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id    NUMBER;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(clf.mx_comp_val
                                     --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          --  ,p_new_val))+ 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          -- ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
    SELECT   p_oipl_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(clf.mx_comp_val
                                     --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          --  ,p_new_val))+ 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          -- ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_clf_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_clf_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oipl_clf_rt_rec.EXISTS(l_index) then
            g_cache_oipl_clf_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_oipl_rate;
--
  PROCEDURE get_comp_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val < decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(clf.mx_comp_val
                                   --    ,p_new_val) + 0.001))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >= decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          -- ,p_new_val))  + 0.001)
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                   --ceil( NVL(clf.mx_comp_val
                                   --    ,p_old_val)) + 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_plip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val < decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(clf.mx_comp_val
                                   --    ,p_new_val) + 0.001))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >= decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                          -- ceil( NVL(clf.mx_comp_val
                                          -- ,p_new_val))  + 0.001)
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                   --ceil( NVL(clf.mx_comp_val
                                   --    ,p_old_val)) + 0.001)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_clf_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_clf_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_clf_rt_rec.EXISTS(l_index) then
            g_cache_plip_clf_rt_rec(l_index).id     := p_plip_id;
            g_cache_plip_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_plip_rate;
--
  PROCEDURE get_comp_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                       --   ceil( NVL(clf.mx_comp_val
                                       --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                      -- ceil( NVL(clf.mx_comp_val
                                      --  ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
    SELECT   p_ptip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(clf.mx_comp_val
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                       --   ceil( NVL(clf.mx_comp_val
                                       --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                      -- ceil( NVL(clf.mx_comp_val
                                      --  ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_clf_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_clf_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_clf_rt_rec.EXISTS(l_index) then
            g_cache_ptip_clf_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_ptip_rate;
--
  PROCEDURE get_comp_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comp_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              ,ben_comp_lvl_rt_f clr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN clr.effective_start_date
                   AND clr.effective_end_date
      AND      clr.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(clf.mx_comp_val
                                  --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                       --   ceil( NVL(clf.mx_comp_val
                                       --    , p_new_val))+ 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                       -- ceil( NVL(clf.mx_comp_val
                                       -- ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,clf.comp_lvl_uom
              ,clf.comp_src_cd
              ,clf.comp_lvl_det_cd
              ,clf.comp_lvl_det_rl
              ,clf.rndg_cd
              ,clf.rndg_rl
              ,clf.mn_comp_val
              ,clf.mx_comp_val
              ,clf.bnfts_bal_id
              ,clf.defined_balance_id
              ,clf.sttd_sal_prdcty_cd
              ,clf.comp_lvl_fctr_id
              ,clf.comp_calc_rl
      FROM     ben_comp_lvl_fctr clf
              --,ben_comp_lvl_rt_f clr
              ,ben_elig_comp_lvl_prte_f ecl
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecl.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecl.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecl.effective_start_date
                   AND ecl.effective_end_date
      AND      ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(clf.mn_comp_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(clf.mx_comp_val
                                  --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(clf.mn_comp_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(clf.mx_comp_val,p_new_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_new_val))
                     ,decode(nvl(clf.mn_comp_val,p_new_val), trunc(nvl(clf.mn_comp_val,p_new_val)),
                      nvl(clf.mx_comp_val,p_new_val)+1,nvl(clf.mx_comp_val,p_new_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_new_val)+0.000000001 )  )
                                       --   ceil( NVL(clf.mx_comp_val
                                       --    , p_new_val))+ 0.001 )
                      AND p_old_val >= NVL(clf.mn_comp_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(clf.mx_comp_val,p_old_val) ,
                                    trunc(nvl(clf.mx_comp_val,p_old_val))
                     ,decode(nvl(clf.mn_comp_val,p_old_val), trunc(nvl(clf.mn_comp_val,p_old_val)),
                      nvl(clf.mx_comp_val,p_old_val)+1,nvl(clf.mx_comp_val,p_old_val)+0.000000001),
                      nvl(clf.mx_comp_val,p_old_val)+0.000000001 )  )
                                       -- ceil( NVL(clf.mx_comp_val
                                       -- ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_clf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_clf_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_clf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_clf_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_clf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_clf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_clf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_clf_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_clf_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_clf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_clf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comp_oiplip_rate;
--
  PROCEDURE get_comp_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_clf_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_comp_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_comp_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_comp_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_comp_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_comp_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_comp_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_comp_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_comp_rate;
--
  PROCEDURE get_comb_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(cla.cmbnd_min_val ,p_new_val)
                   and p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                 ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                  nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                  -- and p_old_val < cla.cmbnd_min_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(cla.cmbnd_min_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                   ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(cla.cmbnd_min_val ,p_old_val)
                    and p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_cla_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_cla_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_cla_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_cla_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_cla_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_cla_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pgm_cla_el_rec.EXISTS(l_index) then
          g_cache_pgm_cla_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_cla_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_cla_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_pgm_elig;
--
  PROCEDURE get_comb_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(cla.cmbnd_min_val ,p_new_val)
                   and p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                 ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                  nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                  -- and p_old_val < cla.cmbnd_min_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(cla.cmbnd_min_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                   ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(cla.cmbnd_min_val ,p_old_val)
                    and p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_cla_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_cla_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_cla_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_cla_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_cla_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_cla_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pl_cla_el_rec.EXISTS(l_index) then
          g_cache_pl_cla_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_cla_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pl_cla_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_pl_elig;
--
  PROCEDURE get_comb_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(cla.cmbnd_min_val ,p_new_val)
                   and p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                 ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                  nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                  -- and p_old_val < cla.cmbnd_min_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(cla.cmbnd_min_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                   ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(cla.cmbnd_min_val ,p_old_val)
                    and p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_cla_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_cla_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_cla_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_cla_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_oipl_cla_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_cla_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_oipl_cla_el_rec.EXISTS(l_index) then
          g_cache_oipl_cla_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_cla_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_cla_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_oipl_elig;
--
  PROCEDURE get_comb_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(cla.cmbnd_min_val ,p_new_val)
                   and p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                 ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                  nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                  -- and p_old_val < cla.cmbnd_min_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(cla.cmbnd_min_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                   ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(cla.cmbnd_min_val ,p_old_val)
                    and p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_cla_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_cla_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_cla_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_cla_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_cla_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_cla_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_plip_cla_el_rec.EXISTS(l_index) then
          g_cache_plip_cla_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_cla_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_cla_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_plip_elig;
--
  PROCEDURE get_comb_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(cla.cmbnd_min_val ,p_new_val)
                   and p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                 ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                  nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                  -- and p_old_val < cla.cmbnd_min_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(cla.cmbnd_min_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                   ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(cla.cmbnd_min_val ,p_old_val)
                    and p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_cla_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_cla_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_cla_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_cla_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_cla_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_cla_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_ptip_cla_el_rec.EXISTS(l_index) then
          g_cache_ptip_cla_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_cla_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_cla_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_ptip_elig;
--
  PROCEDURE get_comb_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_comb_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_comb_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_comb_pl_elig(p_pl_id=> p_pl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_comb_oipl_elig(p_oipl_id=> p_oipl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_comb_plip_elig(p_plip_id=> p_plip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_comb_ptip_elig(p_ptip_id=> p_ptip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_comb_elig;
--
  PROCEDURE get_comb_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_pgm_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
				-- ceil( NVL(cla.cmbnd_max_val
                                --       ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    --    ceil( NVL(cla.cmbnd_max_val
                                    --     , p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
					-- ceil( NVL(cla.cmbnd_max_val
                                        -- ,p_old_val)) +   0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
				-- ceil( NVL(cla.cmbnd_max_val
                                --       ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    --    ceil( NVL(cla.cmbnd_max_val
                                    --     , p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
					-- ceil( NVL(cla.cmbnd_max_val
                                        -- ,p_old_val)) +   0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_cla_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_cla_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_cla_rt_rec.EXISTS(l_index) then
            g_cache_pgm_cla_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_pgm_rate;
--
  PROCEDURE get_comb_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_pl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val )) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val )) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_cla_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_cla_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_cla_rt_rec.EXISTS(l_index) then
            g_cache_pl_cla_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_pl_rate;
--
  PROCEDURE get_comb_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_oipl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id    NUMBER;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --  ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --    ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil(NVL(cla.cmbnd_max_val
                                     --   ,l_old_val_1)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oipl_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --  ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --    ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil(NVL(cla.cmbnd_max_val
                                     --   ,l_old_val_1)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_cla_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_cla_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_cla_rt_rec.EXISTS(l_index) then
            g_cache_oipl_cla_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_oipl_rate;
--
  PROCEDURE get_comb_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,l_new_val_1) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil(NVL(cla.cmbnd_max_val
                                     --    ,l_new_val_1)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,l_old_val_1)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_plip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,l_new_val_1) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil(NVL(cla.cmbnd_max_val
                                     --    ,l_new_val_1)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,l_old_val_1)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_cla_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_cla_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_cla_rt_rec.EXISTS(l_index) then
            g_cache_plip_cla_rt_rec(l_index).id     := p_plip_id;
            g_cache_plip_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_plip_rate;
--
  PROCEDURE get_comb_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(cla.cmbnd_max_val
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --    ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_ptip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(cla.cmbnd_max_val
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --    ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_cla_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_cla_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_cla_rt_rec.EXISTS(l_index) then
            g_cache_ptip_cla_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_ptip_rate;
--
  PROCEDURE get_comb_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_comb_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              ,ben_cmbn_age_los_rt_f cmr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN cmr.effective_start_date
                   AND cmr.effective_end_date
      AND      cmr.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,cla.los_fctr_id
              ,cla.age_fctr_id
              ,cla.cmbnd_min_val
              ,cla.cmbnd_max_val
      FROM     ben_cmbn_age_los_fctr cla
              --,ben_cmbn_age_los_rt_f cmr
              ,ben_elig_cmbn_age_los_prte_f ecp
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ecp.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ecp.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ecp.effective_start_date
                   AND ecp.effective_end_date
      AND      ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(cla.cmbnd_min_val
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(cla.cmbnd_max_val
                                    --    ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(cla.cmbnd_min_val
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(cla.cmbnd_max_val,p_new_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_new_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_new_val), trunc(nvl(cla.cmbnd_min_val,p_new_val)),
                      nvl(cla.cmbnd_max_val,p_new_val)+1,nvl(cla.cmbnd_max_val,p_new_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_new_val)+0.000000001 )  )
                                     --   ceil( NVL(cla.cmbnd_max_val
                                     --    ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(cla.cmbnd_min_val
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(cla.cmbnd_max_val,p_old_val) ,
                                    trunc(nvl(cla.cmbnd_max_val,p_old_val))
                     ,decode(nvl(cla.cmbnd_min_val,p_old_val), trunc(nvl(cla.cmbnd_min_val,p_old_val)),
                      nvl(cla.cmbnd_max_val,p_old_val)+1,nvl(cla.cmbnd_max_val,p_old_val)+0.000000001),
                      nvl(cla.cmbnd_max_val,p_old_val)+0.000000001 )  )
                                     -- ceil( NVL(cla.cmbnd_max_val
                                     --   ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_cla_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_cla_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_cla_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_cla_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_cla_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_cla_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_cla_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_cla_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_cla_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_cla_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_cla_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_comb_oiplip_rate;
--
  PROCEDURE get_comb_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_cla_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_comb_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_comb_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_comb_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_comb_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_comb_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_comb_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_comb_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_comb_rate;
--
  PROCEDURE get_pct_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(pff.mn_pct_val ,p_new_val)
                   and p_new_val <  decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                 ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                  nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                  -- and p_old_val < pff.mn_pct_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(pff.mn_pct_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                   ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                      nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(pff.mn_pct_val ,p_old_val)
                    and p_old_val <  decode(nvl(pff.mx_pct_val,p_old_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_old_val))
                     ,decode(nvl(pff.mn_pct_val,p_old_val), trunc(nvl(pff.mn_pct_val,p_old_val)),
                      nvl(pff.mx_pct_val,p_old_val)+1,nvl(pff.mx_pct_val,p_old_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_pff_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_pff_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_pff_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_pff_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_pff_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_pff_el_rec(l_index);
      --
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pgm_pff_el_rec.EXISTS(l_index) then
          g_cache_pgm_pff_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_pff_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_pff_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_pgm_elig;
--
  PROCEDURE get_pct_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(pff.mn_pct_val ,p_new_val)
                   and p_new_val <  decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                 ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                  nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                  -- and p_old_val < pff.mn_pct_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(pff.mn_pct_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                   ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                      nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(pff.mn_pct_val ,p_old_val)
                    and p_old_val <  decode(nvl(pff.mx_pct_val,p_old_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_old_val))
                     ,decode(nvl(pff.mn_pct_val,p_old_val), trunc(nvl(pff.mn_pct_val,p_old_val)),
                      nvl(pff.mx_pct_val,p_old_val)+1,nvl(pff.mx_pct_val,p_old_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_pff_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_pff_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_pff_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_pff_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_pff_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_pff_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pl_pff_el_rec.EXISTS(l_index) then
          g_cache_pl_pff_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_pff_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pl_pff_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_pl_elig;
--
  PROCEDURE get_pct_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(pff.mn_pct_val ,p_new_val)
                   and p_new_val <  decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                 ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                  nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                  -- and p_old_val < pff.mn_pct_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(pff.mn_pct_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                   ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                      nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(pff.mn_pct_val ,p_old_val)
                    and p_old_val <  decode(nvl(pff.mx_pct_val,p_old_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_old_val))
                     ,decode(nvl(pff.mn_pct_val,p_old_val), trunc(nvl(pff.mn_pct_val,p_old_val)),
                      nvl(pff.mx_pct_val,p_old_val)+1,nvl(pff.mx_pct_val,p_old_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_pff_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_pff_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_pff_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_pff_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_oipl_pff_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_pff_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_oipl_pff_el_rec.EXISTS(l_index) then
          g_cache_oipl_pff_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_pff_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_pff_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_oipl_elig;
--
  PROCEDURE get_pct_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(pff.mn_pct_val ,p_new_val)
                   and p_new_val <  decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                 ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                  nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                  -- and p_old_val < pff.mn_pct_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(pff.mn_pct_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                   ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                      nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(pff.mn_pct_val ,p_old_val)
                    and p_old_val <  decode(nvl(pff.mx_pct_val,p_old_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_old_val))
                     ,decode(nvl(pff.mn_pct_val,p_old_val), trunc(nvl(pff.mn_pct_val,p_old_val)),
                      nvl(pff.mx_pct_val,p_old_val)+1,nvl(pff.mx_pct_val,p_old_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_pff_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_pff_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_pff_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_pff_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_pff_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_pff_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_plip_pff_el_rec.EXISTS(l_index) then
          g_cache_plip_pff_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_pff_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_pff_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_plip_elig;
--
  PROCEDURE get_pct_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(pff.mn_pct_val ,p_new_val)
                   and p_new_val <  decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                 ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                  nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                  -- and p_old_val < pff.mn_pct_val
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(pff.mn_pct_val,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(pff.mx_pct_val,p_new_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_new_val))
                   ,decode(nvl(pff.mn_pct_val,p_new_val), trunc(nvl(pff.mn_pct_val,p_new_val)),
                      nvl(pff.mx_pct_val,p_new_val)+1,nvl(pff.mx_pct_val,p_new_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(pff.mn_pct_val ,p_old_val)
                    and p_old_val <  decode(nvl(pff.mx_pct_val,p_old_val) ,
                                    trunc(nvl(pff.mx_pct_val,p_old_val))
                     ,decode(nvl(pff.mn_pct_val,p_old_val), trunc(nvl(pff.mn_pct_val,p_old_val)),
                      nvl(pff.mx_pct_val,p_old_val)+1,nvl(pff.mx_pct_val,p_old_val)+0.000000001),
                      nvl(pff.mx_pct_val,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_pff_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_pff_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_pff_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_pff_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_pff_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_pff_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_ptip_pff_el_rec.EXISTS(l_index) then
          g_cache_ptip_pff_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_pff_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_pff_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_ptip_elig;
--
  PROCEDURE get_pct_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_pct_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_pct_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_pct_pl_elig(p_pl_id=> p_pl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_pct_oipl_elig(p_oipl_id=> p_oipl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_pct_plip_elig(p_plip_id=> p_plip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_pct_ptip_elig(p_ptip_id=> p_ptip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_pct_elig;
--
  PROCEDURE get_pct_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_pgm_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) <  (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1 )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100)  >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1 )
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) <  (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1 )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100)  >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1 )
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_pff_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_pff_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_pff_rt_rec.EXISTS(l_index) then
            g_cache_pgm_pff_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_pgm_rate;
--
  PROCEDURE get_pct_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_pl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < ( NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1 )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100)  >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1 )
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < ( NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1 )
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100)  >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1 )
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_pff_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_pff_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_pff_rt_rec.EXISTS(l_index) then
            g_cache_pl_pff_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_pl_rate;
--
  PROCEDURE get_pct_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_oipl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id    NUMBER;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) <( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oipl_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) <( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_pff_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_pff_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oipl_pff_rt_rec.EXISTS(l_index) then
            g_cache_oipl_pff_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_oipl_rate;
--
  PROCEDURE get_pct_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_plip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_pff_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_pff_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_pff_rt_rec.EXISTS(l_index) then
            g_cache_plip_pff_rt_rec(l_index).id     := p_plip_id;
            g_cache_plip_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_plip_rate;
--
  PROCEDURE get_pct_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_ptip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100) < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR (p_new_val*100) >= (NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < ( NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_pff_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_pff_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_pff_rt_rec.EXISTS(l_index) then
            g_cache_ptip_pff_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_ptip_rate;
--
  PROCEDURE get_pct_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_pct_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              ,ben_pct_fl_tm_rt_f pfr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN pfr.effective_start_date
                   AND pfr.effective_end_date
      AND      pfr.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR  (p_new_val*100) >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,pff.use_prmry_asnt_only_flag
              ,pff.use_sum_of_all_asnts_flag
              ,pff.rndg_cd
              ,pff.rndg_rl
              ,pff.mn_pct_val
              ,pff.mx_pct_val
      FROM     ben_pct_fl_tm_fctr pff
              --,ben_pct_fl_tm_rt_f pfr
              ,ben_elig_pct_fl_tm_prte_f epf
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = epf.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      epf.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN epf.effective_start_date
                   AND epf.effective_end_date
      AND      epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(pff.mn_pct_val
                                        ,p_new_val)
                      AND (p_new_val*100)  < (NVL(pff.mx_pct_val
                                       ,p_new_val)*100)+1)
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(pff.mn_pct_val
                                            ,p_new_val)
                            OR  (p_new_val*100) >= ( NVL(pff.mx_pct_val
                                             ,p_new_val)*100)+1)
                      AND p_old_val >= NVL(pff.mn_pct_val
                                        ,p_old_val)
                      AND (p_old_val*100) < (NVL(pff.mx_pct_val
                                       ,p_old_val)*100)+1)
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_pff_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_pff_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_pff_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_pff_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_pff_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_pff_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_pff_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_pff_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_pff_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_pff_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_pff_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_pct_oiplip_rate;
--
  PROCEDURE get_pct_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_pff_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_pct_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_pct_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_pct_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_pct_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_pct_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_pct_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_pct_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_pct_rate;
--
  PROCEDURE get_hours_pgm_elig(
    p_pgm_id            IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_pgm_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(hwf.mn_hrs_num ,p_new_val)
                   and p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                 ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                  nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                  -- and p_old_val < hwf.mn_hrs_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(hwf.mn_hrs_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                   ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(hwf.mn_hrs_num ,p_old_val)
                    and p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_hwf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_hwf_el_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_hwf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_hwf_el_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;

    p_rec    := g_cache_pgm_hwf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_hwf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pgm_hwf_el_rec.EXISTS(l_index) then
          g_cache_pgm_hwf_el_rec(l_index).id     := p_pgm_id;
          g_cache_pgm_hwf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_hwf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_pgm_elig;
--
  PROCEDURE get_hours_pl_elig(
    p_pl_id             IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_pl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.pl_id = p_pl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(hwf.mn_hrs_num ,p_new_val)
                   and p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                 ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                  nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                  -- and p_old_val < hwf.mn_hrs_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(hwf.mn_hrs_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                   ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(hwf.mn_hrs_num ,p_old_val)
                    and p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_hwf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_hwf_el_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_hwf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_hwf_el_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_pl_hwf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_hwf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_pl_hwf_el_rec.EXISTS(l_index) then
          g_cache_pl_hwf_el_rec(l_index).id     := p_pl_id;
          g_cache_pl_hwf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_pl_hwf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_pl_elig;
--
  PROCEDURE get_hours_oipl_elig(
    p_oipl_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_oipl_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(hwf.mn_hrs_num ,p_new_val)
                   and p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                 ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                  nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                  -- and p_old_val < hwf.mn_hrs_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(hwf.mn_hrs_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                   ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(hwf.mn_hrs_num ,p_old_val)
                    and p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_hwf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_hwf_el_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_hwf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_hwf_el_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_oipl_hwf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_hwf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_oipl_hwf_el_rec.EXISTS(l_index) then
          g_cache_oipl_hwf_el_rec(l_index).id     := p_oipl_id;
          g_cache_oipl_hwf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_hwf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_oipl_elig;
--
  PROCEDURE get_hours_plip_elig(
    p_plip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_plip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.plip_id = p_plip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(hwf.mn_hrs_num ,p_new_val)
                   and p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                 ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                  nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                  -- and p_old_val < hwf.mn_hrs_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(hwf.mn_hrs_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                   ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(hwf.mn_hrs_num ,p_old_val)
                    and p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_hwf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_hwf_el_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_hwf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_hwf_el_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_plip_hwf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_hwf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_plip_hwf_el_rec.EXISTS(l_index) then
          g_cache_plip_hwf_el_rec(l_index).id     := p_plip_id;
          g_cache_plip_hwf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_plip_hwf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_plip_elig;
--
  PROCEDURE get_hours_ptip_elig(
    p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_ptip_elig';
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_prtn_elig_prfl_f cep
              ,ben_prtn_elig_f epa
      WHERE    epa.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN epa.effective_start_date
                   AND epa.effective_end_date
      AND      epa.prtn_elig_id = cep.prtn_elig_id
      AND      p_effective_date BETWEEN cep.effective_start_date
                   AND cep.effective_end_date
      AND      cep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND     (
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND p_new_val >= NVL(hwf.mn_hrs_num ,p_new_val)
                   and p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                 ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                  nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                  -- and p_old_val < hwf.mn_hrs_num
                  )
                 OR
                 (
                   p_new_val IS NOT NULL
                   AND p_old_val IS NOT NULL
                   AND
                   (
                    p_new_val < NVL(hwf.mn_hrs_num,p_new_val)
                    OR
                    p_new_val >=   decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                   ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )
                     )
                    AND p_old_val >= NVL(hwf.mn_hrs_num ,p_old_val)
                    and p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )
                  )
                 OR
                  (  p_new_val IS NULL
                     AND p_old_val IS NULL
                   )
            );

    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_hwf_el_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_hwf_el_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_hwf_el_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_hwf_el_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
     IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    p_rec    := g_cache_ptip_hwf_el_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_hwf_el_rec(l_index);
      IF c1%NOTFOUND THEN
        --
        if NOT g_cache_ptip_hwf_el_rec.EXISTS(l_index) then
          g_cache_ptip_hwf_el_rec(l_index).id     := p_ptip_id;
          g_cache_ptip_hwf_el_rec(l_index).exist  := 'N';
        end if;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_hwf_el_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_ptip_elig;
--
  PROCEDURE get_hours_elig(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_old_val           in            number  default null
   ,p_new_val           in            number  default null
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_hours_elig';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_hours_pgm_elig(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_hours_pl_elig(p_pl_id=> p_pl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_hours_oipl_elig(p_oipl_id=> p_oipl_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_hours_plip_elig(p_plip_id=> p_plip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_hours_ptip_elig(p_ptip_id=> p_ptip_id
        ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_hours_elig;
--
  PROCEDURE get_hours_pgm_rate(
    p_pgm_id            IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_pgm_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pgm_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --          ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --      ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pgm_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pgm_id = p_pgm_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --          ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --      ,p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pgm_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pgm_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pgm_hwf_rt_rec(l_index).id <> p_pgm_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pgm_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pgm_hwf_rt_rec(l_index).id = p_pgm_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pgm_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pgm_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pgm_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pgm_hwf_rt_rec.EXISTS(l_index) then
            g_cache_pgm_hwf_rt_rec(l_index).id     := p_pgm_id;
            g_cache_pgm_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pgm_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_pgm_rate;
--
  PROCEDURE get_hours_pl_rate(
    p_pl_id             IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_pl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_pl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                    -- ceil(NVL(hwf.mx_hrs_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --           ,p_new_val))  + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_pl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.pl_id = p_pl_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                    -- ceil(NVL(hwf.mx_hrs_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --           ,p_new_val))  + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_pl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_pl_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_pl_hwf_rt_rec(l_index).id <> p_pl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_pl_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_pl_hwf_rt_rec(l_index).id = p_pl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_pl_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_pl_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_pl_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_pl_hwf_rt_rec.EXISTS(l_index) then
            g_cache_pl_hwf_rt_rec(l_index).id     := p_pl_id;
            g_cache_pl_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_pl_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_pl_rate;
--
  PROCEDURE get_hours_oipl_rate(
    p_oipl_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_oipl_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    l_opt_id    NUMBER;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oipl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(hwf.mx_hrs_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil(NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil(NVL(hwf.mx_hrs_num
                                  --      ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oipl_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    ( abr.oipl_id = p_oipl_id
      --
      --START Option level Rates Enhancements
               or ( abr.opt_id = l_opt_id and
                     not exists (select null from ben_acty_base_rt_f abr1
                     where abr1.oipl_id = p_oipl_id )))
      --END Option level Rates Enhancements
      --
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                    -- ceil( NVL(hwf.mx_hrs_num
                                    --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil(NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil(NVL(hwf.mx_hrs_num
                                  --      ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oipl_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oipl_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oipl_hwf_rt_rec(l_index).id <> p_oipl_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oipl_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oipl_hwf_rt_rec(l_index).id = p_oipl_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oipl_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      -- Option level rates enhancement
      l_opt_id := get_opt_id(p_oipl_id,p_effective_date);
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oipl_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oipl_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oipl_hwf_rt_rec.EXISTS(l_index) then
            g_cache_oipl_hwf_rt_rec(l_index).id     := p_oipl_id;
            g_cache_oipl_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oipl_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_oipl_rate;
--
  PROCEDURE get_hours_plip_rate(
    p_plip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_plip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_plip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(hwf.mx_hrs_num
                                     --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                 -- ceil( NVL(hwf.mx_hrs_num
                                 --      , p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_plip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.plip_id = p_plip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                     -- ceil( NVL(hwf.mx_hrs_num
                                     --   ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                 -- ceil( NVL(hwf.mx_hrs_num
                                 --      , p_old_val))  + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_plip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_plip_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_plip_hwf_rt_rec(l_index).id <> p_plip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_plip_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_plip_hwf_rt_rec(l_index).id = p_plip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_plip_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_plip_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_plip_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_plip_hwf_rt_rec.EXISTS(l_index) then
          g_cache_plip_hwf_rt_rec(l_index).id     := p_plip_id;
          g_cache_plip_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_plip_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_plip_rate;
--
  PROCEDURE get_hours_ptip_rate(
    p_ptip_id           IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_ptip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_ptip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            , p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_ptip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                   -- ceil( NVL(hwf.mx_hrs_num
                                   --     ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            , p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     ,p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_ptip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_ptip_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_ptip_hwf_rt_rec(l_index).id <> p_ptip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_ptip_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_ptip_hwf_rt_rec(l_index).id = p_ptip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_ptip_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_ptip_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_ptip_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_ptip_hwf_rt_rec.EXISTS(l_index) then
            g_cache_ptip_hwf_rt_rec(l_index).id     := p_ptip_id;
            g_cache_ptip_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_ptip_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_ptip_rate;
--
  PROCEDURE get_hours_oiplip_rate(
    p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package        VARCHAR2(80) := g_package || '.get_hours_oiplip_rate';
    l_old_val_1 NUMBER := p_old_val + 1;
    l_new_val_1 NUMBER := p_new_val + 1;
    --
    -- Define Cursor
    --
    CURSOR c1 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              ,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
      AND      vpf.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN hwr.effective_start_date
                   AND hwr.effective_end_date
      AND      hwr.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --      ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     , p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    -- PERFNEW. SPLIT TO 2 CURSORS C1 and C2.
    --UNION ALL
    CURSOR c2 IS
      SELECT   p_oiplip_id
              ,'Y'
              ,hwf.hrs_src_cd
              ,hwf.hrs_wkd_det_cd
              ,hwf.hrs_wkd_det_rl
              ,hwf.rndg_cd
              ,hwf.rndg_rl
              ,hwf.defined_balance_id
              ,hwf.bnfts_bal_id
              ,hwf.mn_hrs_num
              ,hwf.mx_hrs_num
              ,hwf.once_r_cntug_cd
              ,hwf.hrs_wkd_calc_rl
      FROM     ben_hrs_wkd_in_perd_fctr hwf
              --,ben_hrs_wkd_in_perd_rt_f hwr
              ,ben_elig_hrs_wkd_prte_f ehw
              ,ben_eligy_prfl_f elp
              ,ben_vrbl_rt_elig_prfl_f vep
              ,ben_vrbl_rt_prfl_f vpf
              ,ben_acty_vrbl_rt_f avr
              ,ben_acty_base_rt_f abr
      WHERE    abr.oiplip_id = p_oiplip_id
      AND      p_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date
      AND      abr.acty_base_rt_id = avr.acty_base_rt_id
      AND      p_effective_date BETWEEN avr.effective_start_date
                   AND avr.effective_end_date
      AND      avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vpf.effective_start_date
                   AND vpf.effective_end_date
--      AND      vpf.vrbl_rt_prfl_id = ehw.vrbl_rt_prfl_id
      AND      vpf.vrbl_rt_prfl_id = vep.vrbl_rt_prfl_id
      AND      p_effective_date BETWEEN vep.effective_start_date
                   AND vep.effective_end_date
      AND      vep.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN elp.effective_start_date
                   AND elp.effective_end_date
      AND      ehw.eligy_prfl_id = elp.eligy_prfl_id
      AND      p_effective_date BETWEEN ehw.effective_start_date
                   AND ehw.effective_end_date
      AND      ehw.hrs_wkd_in_perd_fctr_id = hwf.hrs_wkd_in_perd_fctr_id
      AND      (
                    (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND p_new_val >= NVL(hwf.mn_hrs_num
                                        ,p_new_val)
                      AND p_new_val <  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --      ,p_new_val) + 0.001 ))
                 OR (
                          p_new_val IS NOT NULL
                      AND p_old_val IS NOT NULL
                      AND (
                               p_new_val < NVL(hwf.mn_hrs_num
                                            ,p_new_val)
                            OR p_new_val >=  decode(nvl(hwf.mx_hrs_num,p_new_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_new_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_new_val), trunc(nvl(hwf.mn_hrs_num,p_new_val)),
                      nvl(hwf.mx_hrs_num,p_new_val)+1,nvl(hwf.mx_hrs_num,p_new_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_new_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --            ,p_new_val)) + 0.001 )
                      AND p_old_val >= NVL(hwf.mn_hrs_num
                                        ,p_old_val)
                      AND p_old_val <  decode(nvl(hwf.mx_hrs_num,p_old_val) ,
                                    trunc(nvl(hwf.mx_hrs_num,p_old_val))
                     ,decode(nvl(hwf.mn_hrs_num,p_old_val), trunc(nvl(hwf.mn_hrs_num,p_old_val)),
                      nvl(hwf.mx_hrs_num,p_old_val)+1,nvl(hwf.mx_hrs_num,p_old_val)+0.000000001),
                      nvl(hwf.mx_hrs_num,p_old_val)+0.000000001 )  )
                                  -- ceil( NVL(hwf.mx_hrs_num
                                  --     , p_old_val)) + 0.001 )
                 OR (    p_new_val IS NULL
                     AND p_old_val IS NULL));
    --
    --
    l_index          PLS_INTEGER;
    l_not_hash_found BOOLEAN;
    l_c2notfound       BOOLEAN;
  --
  BEGIN
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
    l_index  := MOD(p_oiplip_id
                 ,g_hash_key);
    --
    IF NOT g_cache_oiplip_hwf_rt_rec.EXISTS(l_index) THEN
      --
      -- Lets store the hash value in this index
      --
      RAISE NO_DATA_FOUND;
    --
    ELSE
      --
      -- If it does exist make sure its the right one
      --
      IF g_cache_oiplip_hwf_rt_rec(l_index).id <> p_oiplip_id THEN
        --
        -- Loop through the hash using the jump routine to check further
        -- indexes
        --
        l_not_hash_found  := FALSE;
        --
        WHILE NOT l_not_hash_found LOOP
          --
          l_index  := l_index + g_hash_jump;
          --
          -- Check if the hash index exists, if not we can use it
          --
          IF NOT g_cache_oiplip_hwf_rt_rec.EXISTS(l_index) THEN
            --
            -- Lets store the hash value in the index
            --
            RAISE NO_DATA_FOUND;
          --
          ELSE
            --
            -- Make sure the index is the correct one
            --
            IF g_cache_oiplip_hwf_rt_rec(l_index).id = p_oiplip_id THEN
              --
              -- We have a match so the hashed value  has been stored before
              --
              l_not_hash_found  := TRUE;
            --
            END IF;
          --
          END IF;
        --
        END LOOP;
      --
      END IF;
    --
    END IF;
    --
    -- If p_old_val and p_new_val is set this means we are trying to retrieve
    -- the correct rate for the calculated value.
    -- Previously we just cached the first rate we
    -- found since we needed the determination code, the correct age,los code,etc
    -- By killing the cache and forcing the value to be removed we cache the
    -- correct rate profile for the case we need.
    --
    IF     p_old_val IS NOT NULL
       AND p_new_val IS NOT NULL THEN
      --
      RAISE NO_DATA_FOUND;
    --
    END IF;
    --
    p_rec    := g_cache_oiplip_hwf_rt_rec(l_index);
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      -- The record has not been cached yet so lets cache it
      --
      OPEN c1;
      --
      FETCH c1 INTO g_cache_oiplip_hwf_rt_rec(l_index);
      -- PERFNEW
      IF c1%NOTFOUND THEN
         --
         l_c2notfound := false;
         OPEN c2;
         FETCH c2 INTO g_cache_oiplip_hwf_rt_rec(l_index);
         IF c2%NOTFOUND THEN
            --
            l_c2notfound := true;
            --
         END IF;
         CLOSE c2;
         --
      END IF;
      -- PERFNEW
      IF     p_old_val IS NULL
         AND p_new_val IS NULL THEN
        --
        IF c1%NOTFOUND and l_c2notfound THEN  -- PERFNEW
          --
          if NOT g_cache_oiplip_hwf_rt_rec.EXISTS(l_index) then
            g_cache_oiplip_hwf_rt_rec(l_index).id     := p_oiplip_id;
            g_cache_oiplip_hwf_rt_rec(l_index).exist  := 'N';
          end if;
        --
        END IF;
      --
      END IF;
      --
      p_rec  := g_cache_oiplip_hwf_rt_rec(l_index);
      --
      CLOSE c1;
  --
  END get_hours_oiplip_rate;
--
  PROCEDURE get_hours_rate(
    p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_old_val           IN            NUMBER DEFAULT NULL
   ,p_new_val           IN            NUMBER DEFAULT NULL
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_rec               OUT NOCOPY    g_cache_hwf_rec_obj) IS
    --
    l_package VARCHAR2(80) := g_package || '.get_hours_rate';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Derive which data type we are dealing with
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      get_hours_pgm_rate(p_pgm_id=> p_pgm_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_pl_id IS NOT NULL THEN
      --
      get_hours_pl_rate(p_pl_id=> p_pl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oipl_id IS NOT NULL THEN
      --
      get_hours_oipl_rate(p_oipl_id=> p_oipl_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_plip_id IS NOT NULL THEN
      --
      get_hours_plip_rate(p_plip_id=> p_plip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_ptip_id IS NOT NULL THEN
      --
      get_hours_ptip_rate(p_ptip_id=> p_ptip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    ELSIF p_oiplip_id IS NOT NULL THEN
      --
      get_hours_oiplip_rate(p_oiplip_id=> p_oiplip_id
       ,p_old_val           => p_old_val
       ,p_new_val           => p_new_val
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_rec               => p_rec);
    --
    END IF;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END get_hours_rate;
--
  PROCEDURE clear_down_cache IS
    --
    l_package VARCHAR2(80) := g_package || '.clear_down_cache';
  --
  BEGIN
    --
    -- hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Clear down all caches
    --
    g_cache_pl_los_el_rec.delete;
    g_cache_oipl_los_el_rec.delete;
    g_cache_plip_los_el_rec.delete;
    g_cache_ptip_los_el_rec.delete;
    g_cache_pgm_los_el_rec.delete;
    g_cache_pl_los_rt_rec.delete;
    g_cache_oipl_los_rt_rec.delete;
    g_cache_plip_los_rt_rec.delete;
    g_cache_ptip_los_rt_rec.delete;
    g_cache_oiplip_los_rt_rec.delete;
    g_cache_pgm_los_rt_rec.delete;
    g_cache_stated_los_rec.delete;
    g_cache_pl_age_el_rec.delete;
    g_cache_oipl_age_el_rec.delete;
    g_cache_plip_age_el_rec.delete;
    g_cache_ptip_age_el_rec.delete;
    g_cache_pgm_age_el_rec.delete;
    g_cache_pl_age_rt_rec.delete;
    g_cache_oipl_age_rt_rec.delete;
    g_cache_plip_age_rt_rec.delete;
    g_cache_ptip_age_rt_rec.delete;
    g_cache_oiplip_age_rt_rec.delete;
    g_cache_pgm_age_rt_rec.delete;
    g_cache_stated_age_rec.delete;
    g_cache_pl_clf_el_rec.delete;
    g_cache_oipl_clf_el_rec.delete;
    g_cache_plip_clf_el_rec.delete;
    g_cache_ptip_clf_el_rec.delete;
    g_cache_pgm_clf_el_rec.delete;
    g_cache_pl_clf_rt_rec.delete;
    g_cache_oipl_clf_rt_rec.delete;
    g_cache_plip_clf_rt_rec.delete;
    g_cache_oiplip_clf_rt_rec.delete;
    g_cache_ptip_clf_rt_rec.delete;
    g_cache_pgm_clf_rt_rec.delete;
    g_cache_pl_cla_el_rec.delete;
    g_cache_oipl_cla_el_rec.delete;
    g_cache_plip_cla_el_rec.delete;
    g_cache_ptip_cla_el_rec.delete;
    g_cache_pgm_cla_el_rec.delete;
    g_cache_pl_cla_rt_rec.delete;
    g_cache_oipl_cla_rt_rec.delete;
    g_cache_plip_cla_rt_rec.delete;
    g_cache_oiplip_cla_rt_rec.delete;
    g_cache_ptip_cla_rt_rec.delete;
    g_cache_pgm_cla_rt_rec.delete;
    g_cache_pl_pff_el_rec.delete;
    g_cache_oipl_pff_el_rec.delete;
    g_cache_plip_pff_el_rec.delete;
    g_cache_ptip_pff_el_rec.delete;
    g_cache_pgm_pff_el_rec.delete;
    g_cache_pl_pff_rt_rec.delete;
    g_cache_oipl_pff_rt_rec.delete;
    g_cache_plip_pff_rt_rec.delete;
    g_cache_oiplip_pff_rt_rec.delete;
    g_cache_ptip_pff_rt_rec.delete;
    g_cache_pgm_pff_rt_rec.delete;
    g_cache_pl_hwf_el_rec.delete;
    g_cache_oipl_hwf_el_rec.delete;
    g_cache_plip_hwf_el_rec.delete;
    g_cache_ptip_hwf_el_rec.delete;
    g_cache_pgm_hwf_el_rec.delete;
    g_cache_pl_hwf_rt_rec.delete;
    g_cache_oipl_hwf_rt_rec.delete;
    g_cache_plip_hwf_rt_rec.delete;
    g_cache_oiplip_hwf_rt_rec.delete;
    g_cache_ptip_hwf_rt_rec.delete;
    g_cache_pgm_hwf_rt_rec.delete;
  --
  -- hr_utility.set_location ('Leaving '||l_package,10);
  --
  END clear_down_cache;
--
END ben_derive_part_and_rate_cache;

/
