--------------------------------------------------------
--  DDL for Package Body BEN_GLOBAL_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GLOBAL_ENRT" as
/* $Header: bengenrt.pkb 120.0.12010000.2 2008/08/05 14:47:54 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Enrollment Globals Package
Purpose
	This package is used to load and return globals used in the enrollment
      save processes.
History
  Date        Who        Version    What?
  ---------   ---------  -------    --------------------------------------------
  03 Apr 2000 lmcdonal   115.0      Created
  06 Apr 2000 lmcdonal   115.1      Added more procedures.
  07 Apr 2000 lmcdonal   115.2      Temp change:  always hit database
                                    until I can workout when to clear globals.
  18 Apr 2000 jcarpent   115.3      Allow assignment to not be ACTIVE_ASSIGN
  17 May 2001 maagrawa   115.4      Changed the procedure and record
                                    definitions.
  23 May 2001 maagrawa   115.5      Removed mandatory condition from
                                    get_pil.
  11 Jun 2002 pabodla    115.6      Added dbdrv command
  14-Jun-2002 pabodla    115.7      Do not select the contingent worker
                                    assignment when assignment data is
                                    fetched.
  13-Dec-2002 kmahendr   115.8      Nocopy Changes
  10-feb-2005 mmudigon   115.9      Bug 4157759. Changes to cursor c1 in get_pil
  17-feb-2005 bmanyam    115.10     Bug 4187137. Changed get_pil to query always.
  18-feb-2005 bmanyam    115.11     Bug 4187137. Changed get_pil to query always.
  22-Feb-2008 rtagarra   115.12     Bug 6840074
  ------------------------------------------------------------------------------
*/

g_package varchar2(30) := 'ben_global_enrt.';
------------------------------------------------------------------------------
--  get_epe
------------------------------------------------------------------------------
procedure get_epe
      (p_elig_per_elctbl_chc_id in number
      ,p_global_epe_rec        out nocopy g_global_epe_rec_type) is

  l_proc varchar2(80) := g_package||'get_epe';
  cursor c1 is
     select epe.per_in_ler_id
           ,epe.pil_elctbl_chc_popl_id
           ,epe.prtt_enrt_rslt_id
           ,epe.pgm_id
           ,epe.pl_id
           ,epe.pl_typ_id
           ,epe.plip_id
           ,epe.ptip_id
           ,epe.oipl_id
           ,epe.business_group_id
           ,epe.object_version_number
           ,epe.comp_lvl_cd
           ,epe.crntly_enrd_flag
           ,epe.alws_dpnt_dsgn_flag
           ,epe.dpnt_cvg_strt_dt_cd
           ,epe.dpnt_cvg_strt_dt_rl
           ,epe.enrt_cvg_strt_dt
           ,epe.erlst_deenrt_dt
           ,epe.enrt_cvg_strt_dt_cd
           ,epe.enrt_cvg_strt_dt_rl
     from   ben_elig_per_elctbl_chc epe
     where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;

  l_epe_rec g_global_epe_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_elig_per_elctbl_chc_id',
                             p_argument_value => p_elig_per_elctbl_chc_id);

  open c1;
  fetch c1 into g_global_epe_rec;
  if c1%notfound then
    g_global_epe_rec := l_epe_rec;
  end if;
  close c1;
  p_global_epe_rec := g_global_epe_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end get_epe;

------------------------------------------------------------------------------
--  reload_epe
------------------------------------------------------------------------------
procedure reload_epe
      (p_elig_per_elctbl_chc_id in number
      ,p_global_epe_rec        out nocopy g_global_epe_rec_type) is

  l_proc varchar2(80) := g_package||'reload_epe';


begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_elig_per_elctbl_chc_id',
                             p_argument_value => p_elig_per_elctbl_chc_id);

  ben_global_enrt.get_epe
       (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
       ,p_global_epe_rec         => p_global_epe_rec);

  hr_utility.set_location('Leaving '||l_proc,99);

end reload_epe;

------------------------------------------------------------------------------
--  get_pel
------------------------------------------------------------------------------
procedure get_pel
      (p_pil_elctbl_chc_popl_id in number
      ,p_global_pel_rec        out nocopy g_global_pel_rec_type)is

  l_proc varchar2(80) := g_package||'get_pel';
  cursor c1 is
     select pel.per_in_ler_id
           ,pel.pgm_id
           ,pel.pl_id
           ,pel.lee_rsn_id
           ,pel.enrt_perd_id
           ,pel.uom
           ,pel.acty_ref_perd_cd
     from   ben_pil_elctbl_chc_popl pel
     where  pel.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id ;

  l_pel_rec g_global_pel_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_pil_elctbl_chc_popl_id',
                             p_argument_value => p_pil_elctbl_chc_popl_id);

  if g_global_pel_id <> p_pil_elctbl_chc_popl_id or
     g_global_pel_id is null then
     open c1;
     fetch c1 into g_global_pel_rec;
     if c1%notfound then
       g_global_pel_rec := l_pel_rec;
     end if;
     close c1;
     g_global_pel_id := p_pil_elctbl_chc_popl_id;
  end if;
  p_global_pel_rec := g_global_pel_rec;

  hr_utility.set_location('Leaving '||l_proc,99);
end get_pel;
------------------------------------------------------------------------------
--  get_pil
------------------------------------------------------------------------------
procedure get_pil
      (p_per_in_ler_id in number
      ,p_global_pil_rec        out nocopy g_global_pil_rec_type) is

  l_proc varchar2(80) := g_package||'get_pil';
  cursor c1 is
     select pil.person_id
           ,pil.ler_id
           ,pil.lf_evt_ocrd_dt
           ,ler.typ_cd
     from   ben_per_in_ler pil,
            ben_ler_f ler
     where  pil.per_in_ler_id = p_per_in_ler_id
       and  ler.ler_id(+) = pil.ler_id
       and  pil.lf_evt_ocrd_dt between ler.effective_start_date(+)
       and  ler.effective_end_date(+) ;

  l_pil_rec g_global_pil_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  --
  if p_per_in_ler_id is null then
   p_global_pil_rec := l_pil_rec;
   return;
  end if;

  if (g_global_pil_id is null)
     or  (g_global_pil_id <> p_per_in_ler_id)
     or (g_global_pil_rec.typ_cd = 'SCHEDDU') then
  /* 4187137: For Unrestricted, we need to fetch the details everytime as lf_evt_ocrd_dt can change..
     Henceforth, query PIL record always for Unrestricted... */
    open c1;
    fetch c1 into g_global_pil_rec;
    if c1%notfound then
      g_global_pil_rec := l_pil_rec;
    end if;
    close c1;
    g_global_pil_id := p_per_in_ler_id;
  end if;
  p_global_pil_rec := g_global_pil_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end get_pil;
------------------------------------------------------------------------------
--  clear_enb
------------------------------------------------------------------------------
procedure clear_enb
      (p_global_enb_rec        out nocopy g_global_enb_rec_type) is

  l_proc varchar2(80) := g_package||'clear_enb';
  l_enb_rec g_global_enb_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);

  g_global_enb_rec := l_enb_rec;

  p_global_enb_rec := g_global_enb_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end clear_enb;
------------------------------------------------------------------------------
--  get_enb
------------------------------------------------------------------------------
procedure get_enb
      (p_enrt_bnft_id           in number
      ,p_global_enb_rec        out nocopy g_global_enb_rec_type) is

  l_proc varchar2(80) := g_package||'get_enb';
  cursor c1 is
     select enb.ordr_num
           ,enb.val
           ,enb.bnft_typ_cd
           ,enb.cvg_mlt_cd
           ,enb.nnmntry_uom
           ,enb.object_version_number
     from   ben_enrt_bnft enb
     where  enb.enrt_bnft_id = p_enrt_bnft_id ;

  l_enb_rec g_global_enb_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_enrt_bnft_id',
                             p_argument_value => p_enrt_bnft_id);

  open c1;
  fetch c1 into g_global_enb_rec;
  if c1%notfound then
    g_global_enb_rec := l_enb_rec;
  end if;
  close c1;
  p_global_enb_rec := g_global_enb_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end get_enb;

------------------------------------------------------------------------------
--  get_asg
------------------------------------------------------------------------------
procedure get_asg
      (p_person_id              in number
      ,p_effective_date         in date
      ,p_global_asg_rec        out nocopy g_global_asg_rec_type) is

  l_proc varchar2(80) := g_package||'get_asg';

  -- Get employee active assignments first, then look for active
  -- benefit's assignments.
  cursor c1 is
        select asg.payroll_id
        from    per_all_assignments_f asg,
                per_assignment_status_types ast
        where   asg.person_id = p_person_id
         and    asg.assignment_type <> 'C'
         and    asg.primary_flag = 'Y'
         and    asg.assignment_status_type_id = ast.assignment_status_type_id
         and    ast.active_flag = 'Y'
         and    ast.primary_flag = 'P'
         and    p_effective_date between
                asg.effective_start_date and asg.effective_end_date
         order by decode(asg.assignment_type, 'E', 1, 'B', 2, 3);

  l_asg_rec g_global_asg_rec_type;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_person_id',
                             p_argument_value => p_person_id);

  if g_global_asg_person_id is null or
     g_global_asg_person_id <> p_person_id then
   open c1;
   fetch c1 into g_global_asg_rec;
   if c1%notfound then
     g_global_asg_rec := l_asg_rec;
   end if;
   close c1;
   g_global_asg_person_id := p_person_id;
  end if;
  p_global_asg_rec := g_global_asg_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end get_asg;
------------------------------------------------------------------------------
--  clear_pen
------------------------------------------------------------------------------
procedure clear_pen
      (p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype) is

  l_proc varchar2(80) := g_package||'clear_pen';
  l_pen_rec ben_prtt_enrt_rslt_f%rowtype;

begin
  hr_utility.set_location('Entering '||l_proc,10);

  g_global_pen_rec := l_pen_rec;
  p_global_pen_rec := g_global_pen_rec;

  hr_utility.set_location('Leaving '||l_proc,99);
end clear_pen;
------------------------------------------------------------------------------
--  get_pen - overloaded
------------------------------------------------------------------------------
procedure get_pen
      (p_prtt_enrt_rslt_id      in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype) is

  l_proc varchar2(80) := g_package||'get_pen';

  cursor c1 is
        select pen.*
        from   ben_prtt_enrt_rslt_f pen
        where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         and   pen.prtt_enrt_rslt_stat_cd is null
         and   p_effective_date between
               pen.effective_start_date and pen.effective_end_date;

  l_pen_rec  ben_prtt_enrt_rslt_f%rowtype;

begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_prtt_enrt_rslt_id',
                             p_argument_value => p_prtt_enrt_rslt_id);
  open c1;
  fetch c1 into g_global_pen_rec;
  if c1%notfound then
    g_global_pen_rec := l_pen_rec;
  end if;
  close c1;
  p_global_pen_rec := g_global_pen_rec;

  hr_utility.set_location('Leaving '||l_proc,99);
end get_pen;
------------------------------------------------------------------------------
--  get_pen - overloaded
------------------------------------------------------------------------------
-- This one is mostly for determine-date where result id is not passed in and it
-- wants to get the result based on per-in-ler and comp-object information.
procedure get_pen
      (p_per_in_ler_id          in number
      ,p_pgm_id                 in number
      ,p_pl_id                  in number
      ,p_oipl_id                in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype) is

  l_proc varchar2(80) := g_package||'get_pen_o';

  cursor c1 is
    select pen.*
    from  ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = p_per_in_ler_id and
          pen.pl_id=p_pl_id
      and nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
      and nvl(pen.oipl_id,-1)=nvl(p_oipl_id,-1)
      and pen.prtt_enrt_rslt_stat_cd is null
      and p_effective_date
          between pen.effective_start_date
              and pen.effective_end_date;

  l_pen_rec ben_prtt_enrt_rslt_f%rowtype;

begin
  hr_utility.set_location('Entering '||l_proc,10);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_pl_id',
                             p_argument_value => p_pl_id);
  open c1;
  fetch c1 into g_global_pen_rec;
  if c1%notfound then
    g_global_pen_rec := l_pen_rec;
  end if;
  close c1;
  p_global_pen_rec := g_global_pen_rec;

  hr_utility.set_location('Leaving '||l_proc,99);

end get_pen;
------------------------------------------------------------------------------
--  reload_pen
------------------------------------------------------------------------------
procedure reload_pen
      (p_prtt_enrt_rslt_id      in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype) is

  l_proc varchar2(80) := g_package||'reload_pen';


begin
  hr_utility.set_location('Entering '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_prtt_enrt_rslt_id',
                             p_argument_value => p_prtt_enrt_rslt_id);
  ben_global_enrt.get_pen
       (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
       ,p_effective_date         => p_effective_date
       ,p_global_pen_rec         => p_global_pen_rec);

  hr_utility.set_location('Leaving '||l_proc,99);

end reload_pen;


end ben_global_enrt;

/
