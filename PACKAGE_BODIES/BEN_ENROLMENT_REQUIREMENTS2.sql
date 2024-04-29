--------------------------------------------------------
--  DDL for Package Body BEN_ENROLMENT_REQUIREMENTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLMENT_REQUIREMENTS2" AS
/* $Header: bendenr2.pkb 120.0 2006/02/16 12:24:50 kmahendr noship $ */
-------------------------------------------------------------------------------
/*
+=============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                 |
|                          Redwood Shores, California, USA                    |
|                               All rights reserved.                          |
+=============================================================================+
--
History
     Date       Who          Version   What?
     ----       ---          -------   -----
     24 Jan 06  mhoyes       115.0     Created.
*/
-------------------------------------------------------------------------------
PROCEDURE get_asg_dets
  (p_person_id IN            number
  ,p_run_mode  IN            varchar2
  ,p_leodt     IN            date
  ,p_effdt     IN            date
  --
  ,p_asg_id       out nocopy number
  ,p_org_id       out nocopy number
  )
IS
  --
  CURSOR c_asg
    (c_per_id number
    ,c_run_md varchar2
    ,c_effdt  date
    )
  IS
    SELECT asg.assignment_id,
           asg.organization_id
    FROM   per_all_assignments_f asg
    WHERE  person_id = c_per_id
    and    asg.assignment_type <> 'C'
    AND    asg.primary_flag = decode(c_run_md, 'I',asg.primary_flag, 'Y')
    AND    c_effdt
      BETWEEN asg.effective_start_date AND asg.effective_end_date;
  --
  l_asg_id number;
  l_org_id number;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.get_asg_dets', 10);
  end if;
  --
  OPEN c_asg
    (c_per_id => p_person_id
    ,c_run_md => p_run_mode
    ,c_effdt  => p_effdt
    );
  FETCH c_asg INTO l_asg_id, l_org_id;
  IF c_asg%NOTFOUND THEN
    CLOSE c_asg;
    fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
    fnd_message.set_token('PROC', 'ben_enrolment_requirements2.get_asg_dets');
    fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
    fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_leodt));
    fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effdt));
    RAISE ben_manage_life_events.g_record_error;
  END IF;
  CLOSE c_asg;
  --
  p_asg_id := l_asg_id;
  p_org_id := l_org_id;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.get_asg_dets', 50);
  end if;
  --
END get_asg_dets;
--
PROCEDURE get_perpiller_dets
  (p_person_id  IN     number
  ,p_bgp_id     IN     number
  ,p_ler_id     IN     number
  ,p_run_mode   IN     varchar2
  ,p_effdt      IN     date
  ,p_irecasg_id IN     number
  --
  ,p_pil_id        out nocopy number
  ,p_lertyp_cd     out nocopy varchar2
  ,p_lernm         out nocopy varchar2
  ,p_pil_leodt     out nocopy date
  ,p_ler_esd       out nocopy date
  ,p_ler_eed       out nocopy date
  )
IS
  --
  CURSOR c_per_in_ler_info
    (c_per_id     number
    ,c_bgp_id     number
    ,c_ler_id     number
    ,c_run_md     varchar2
    ,c_effdt      date
    ,c_irecasg_id number
    )
  IS
    SELECT   pil.per_in_ler_id,
             ler.typ_cd,
             ler.name,
             pil.lf_evt_ocrd_dt,
             ler.effective_start_date,
             ler.effective_end_date
    FROM     ben_per_in_ler pil, ben_ler_f ler
    WHERE    pil.person_id = c_per_id
    AND      pil.business_group_id = c_bgp_id
    AND      pil.ler_id = c_ler_id
    AND      pil.per_in_ler_stat_cd = 'STRTD'
    AND      ler.business_group_id = c_bgp_id
    AND      pil.ler_id = ler.ler_id
    AND      c_effdt BETWEEN ler.effective_start_date
                 AND ler.effective_end_date
    and      nvl(pil.assignment_id, -9999) = decode (c_run_md,
                                           'I',
					   c_irecasg_id,
					   nvl(pil.assignment_id, -9999) );
  --
  l_per_in_ler_id        number;
  l_ler_typ_cd           varchar2(2000);
  l_ler_name             varchar2(2000);
  l_lf_evt_ocrd_dt_fetch date;
  l_ler_esd              date;
  l_ler_eed              date;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.get_perpiller_dets', 10);
  end if;
  --
  OPEN c_per_in_ler_info
    (c_per_id     => p_person_id
    ,c_bgp_id     => p_bgp_id
    ,c_ler_id     => p_ler_id
    ,c_run_md     => p_run_mode
    ,c_effdt      => p_effdt
    ,c_irecasg_id => p_irecasg_id
    );
  FETCH c_per_in_ler_info INTO l_per_in_ler_id,
                               l_ler_typ_cd,
                               l_ler_name,
                               l_lf_evt_ocrd_dt_fetch,
                               l_ler_esd,
                               l_ler_eed;
  --
  IF c_per_in_ler_info%NOTFOUND THEN
     CLOSE c_per_in_ler_info;
     --
     fnd_message.set_name('BEN', 'BEN_91272_PER_IN_LER_MISSING');
     fnd_message.set_token('PROC', 'ben_enrolment_requirements2.get_perpiller_dets');
     fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
     fnd_message.set_token('LER_ID', TO_CHAR(p_ler_id));
     fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effdt));
     fnd_message.set_token('BG_ID', TO_CHAR(p_bgp_id));
     RAISE ben_manage_life_events.g_record_error;
     --
  END IF;
  CLOSE c_per_in_ler_info;
  --
  p_pil_id    := l_per_in_ler_id;
  p_lertyp_cd := l_ler_typ_cd;
  p_lernm     := l_ler_name;
  p_pil_leodt := l_lf_evt_ocrd_dt_fetch;
  p_ler_esd   := l_ler_esd;
  p_ler_eed   := l_ler_eed;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.get_perpiller_dets', 50);
  end if;
  --
END get_perpiller_dets;
--
PROCEDURE get_latest_enrtdt
  (p_person_id  IN     number
  ,p_bgp_id     IN     number
  --
  ,p_pen_mxesd     out nocopy date
  )
IS
  --
  CURSOR c_get_latest_enrt_dt
    (c_per_id     number
    ,c_bgp_id     number
    )
  IS
    select max(rslt.effective_start_date)
    from   ben_prtt_enrt_rslt_f rslt,ben_ler_f ler
     where  rslt.person_id = c_per_id
    and ler.ler_id=rslt.ler_id
  --  and rslt.prtt_enrt_rslt_stat_cd NOT IN ('BCKDT', 'VOIDD')
    and rslt.prtt_enrt_rslt_stat_cd is null
    and   ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU' )
    and    rslt.business_group_id = c_bgp_id
    and rslt.enrt_cvg_thru_dt = hr_api.g_eot; -- Bug 4388226 - End-dated suspended enrl shudn't be picked up.
  --
  l_pen_mxesd     date;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.get_latest_enrtdt', 10);
  end if;
  --
  OPEN c_get_latest_enrt_dt
    (c_per_id => p_person_id
    ,c_bgp_id => p_bgp_id
    );
  FETCH c_get_latest_enrt_dt into l_pen_mxesd;
  close c_get_latest_enrt_dt ;
  --
  p_pen_mxesd := l_pen_mxesd;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.get_latest_enrtdt', 50);
  end if;
  --
END get_latest_enrtdt;
--
PROCEDURE bckdout_ler
  (p_person_id  IN     number
  ,p_effdt      IN     date
  ,p_bgp_id     IN     number
  ,p_ler_id     IN     number
  ,p_leodt      IN     date
  --
  ,p_pil_bcktdt    out nocopy date
  )
IS
  --
  CURSOR c_backed_out_ler
    (c_per_id number
    ,c_effdt  date
    ,c_bgp_id number
    ,c_ler_id number
    ,c_leodt  date
    )
  IS
    SELECT   MAX(pil.bckt_dt)
    FROM     ben_per_in_ler pil
            -- CWB changes
            ,ben_ler_f      ler
            ,ben_ptnl_ler_for_per  plr
    WHERE    pil.person_id = c_per_id
    AND      pil.ler_id    = ler.ler_id
    and      ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU')
    and      c_effdt
      between ler.effective_start_date and ler.effective_end_date
    AND      pil.business_group_id = c_bgp_id
    AND      pil.ler_id = c_ler_id
    AND      pil.lf_evt_ocrd_dt = c_leodt
    AND      pil.bckt_dt IS NOT NULL
    and      pil.per_in_ler_stat_cd = 'BCKDT'
    and      pil.ptnl_ler_for_per_id   = plr.ptnl_ler_for_per_id
    and      plr.ptnl_ler_for_per_stat_cd <> 'VOIDD';
  --
  l_pil_mxbcktdt     date;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.bckdout_ler', 10);
  end if;
  --
  OPEN c_backed_out_ler
    (c_per_id => p_person_id
    ,c_effdt  => p_effdt
    ,c_bgp_id => p_bgp_id
    ,c_ler_id => p_ler_id
    ,c_leodt  => p_leodt
    );
  FETCH c_backed_out_ler into l_pil_mxbcktdt;
  close c_backed_out_ler;
  --
  p_pil_bcktdt := l_pil_mxbcktdt;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.bckdout_ler', 50);
  end if;
  --
END bckdout_ler;
--
PROCEDURE ptipenrt_info
  (p_person_id   IN     number
  ,p_effdt       IN     date
  ,p_bgp_id      IN     number
  ,p_ptip_id     IN     number
  ,p_cvgthrudt   IN     date
  --
  ,p_pen_pl_id      out nocopy number
  ,p_pen_oipl_id    out nocopy number
  ,p_pen_plip_id    out nocopy number
  )
IS
  --
  CURSOR c_ptip_enrolment_info
    (c_per_id    number
    ,c_bgp_id    number
    ,c_cvgthrudt date
    ,c_ptip_id   number
    ,c_effdt     date
    )
  IS
    SELECT   pen.pl_id,
             pen.oipl_id,
             plip.plip_id
    FROM     ben_prtt_enrt_rslt_f pen, ben_plip_f plip
    WHERE    pen.person_id = c_per_id
    AND      pen.business_group_id = c_bgp_id
    AND      pen.prtt_enrt_rslt_stat_cd IS NULL
    --AND      pen.sspndd_flag = 'N'
    AND      (pen.sspndd_flag = 'N' --CFW
               OR (pen.sspndd_flag = 'Y' and
                   pen.enrt_cvg_thru_dt = hr_api.g_eot
                  )
             )
    AND      pen.effective_end_date = hr_api.g_eot
    AND      c_cvgthrudt <= pen.enrt_cvg_thru_dt
    AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
    AND      c_ptip_id = pen.ptip_id
    AND      plip.pgm_id = pen.pgm_id
    AND      plip.pl_id = pen.pl_id
    AND      c_effdt BETWEEN plip.effective_start_date
                 AND plip.effective_end_date;
  --
  l_pil_mxbcktdt     date;
  --
  l_pen_pl_id    number;
  l_pen_oipl_id  number;
  l_pen_plip_id  number;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.ptipenrt_info', 10);
  end if;
  --
  OPEN c_ptip_enrolment_info
    (c_per_id    => p_person_id
    ,c_bgp_id    => p_bgp_id
    ,c_cvgthrudt => p_cvgthrudt
    ,c_ptip_id   => p_ptip_id
    ,c_effdt     => p_effdt
    );
  FETCH c_ptip_enrolment_info into l_pen_pl_id, l_pen_oipl_id, l_pen_plip_id;
  close c_ptip_enrolment_info;
  --
  p_pen_pl_id   := l_pen_pl_id;
  p_pen_oipl_id := l_pen_oipl_id;
  p_pen_plip_id := l_pen_plip_id;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.ptipenrt_info', 50);
  end if;
  --
END ptipenrt_info;
--
PROCEDURE get_lerplipdfltcd
  (p_plip_id  IN     number
  ,p_ler_id   IN     number
  ,p_effdt    IN     date
  --
  ,p_lep_dflt_enrt_cd out nocopy varchar2
  ,p_lep_dflt_enrt_rl out nocopy varchar2
  )
IS
  --
  CURSOR c_ler_plip_dflt_cd
    (c_plip_id number
    ,c_ler_id  number
    ,c_effdt   date
    )
  IS
    SELECT   lep.dflt_enrt_cd,
             lep.dflt_enrt_rl
    FROM     ben_ler_chg_plip_enrt_f lep
    WHERE    c_plip_id = lep.plip_id
    AND      c_ler_id = lep.ler_id
    AND      c_effdt BETWEEN lep.effective_start_date
                 AND lep.effective_end_date;
  --
  l_pil_mxbcktdt     date;
  --
  l_dflt_enrt_cd varchar2(1000);
  l_dflt_enrt_rl number;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering: ben_enrolment_requirements2.get_lerplipdfltcd', 10);
  end if;
  --
  OPEN c_ler_plip_dflt_cd
    (c_plip_id => p_plip_id
    ,c_ler_id  => p_ler_id
    ,c_effdt   => p_effdt
    );
  FETCH c_ler_plip_dflt_cd into l_dflt_enrt_cd, l_dflt_enrt_rl;
  close c_ler_plip_dflt_cd;
  --
  p_lep_dflt_enrt_cd := l_dflt_enrt_cd;
  p_lep_dflt_enrt_rl := l_dflt_enrt_rl;
  --
  if g_debug then
    hr_utility.set_location('Leaving: ben_enrolment_requirements2.get_lerplipdfltcd', 50);
  end if;
  --
END get_lerplipdfltcd;
--
END ben_enrolment_requirements2;

/
