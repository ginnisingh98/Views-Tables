--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ELIGIBILITY4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ELIGIBILITY4" as
/* $Header: bendete4.pkb 120.0.12000000.2 2007/02/07 23:11:57 kmahendr noship $ */
--
procedure prev_elig_check
  (p_person_id        in        number
  ,p_pgm_id           in        number
  ,p_pl_id            in        number
  ,p_ptip_id          in        number
  ,p_effective_date   in        date
  ,p_mode_cd          in        varchar2
  ,p_irec_asg_id      in        number
  --
  ,p_prev_eligibility      out nocopy boolean
  ,p_elig_per_id           out nocopy number
  ,p_elig_per_elig_flag    out nocopy varchar2
  ,p_prev_prtn_strt_dt     out nocopy date
  ,p_prev_prtn_end_dt      out nocopy date
  ,p_per_in_ler_id         out nocopy number
  ,p_object_version_number out nocopy number
  ,p_prev_age_val          out nocopy number
  ,p_prev_los_val          out nocopy number
  )
is
  --
  CURSOR c_prev_elig_check
    (c_person_id      in number
    ,c_pgm_id         in number
    ,c_pl_id          in number
    ,c_ptip_id        in number
    ,c_effective_date in date
    ,c_mode_cd        in varchar2
    ,c_irec_asg_id    in number
    )
  IS
    select pep.elig_per_id,
           pep.elig_flag,
           pep.prtn_strt_dt,
           pep.prtn_end_dt,
           pep.per_in_ler_id,
           pep.object_version_number,
           pep.age_val,
           pep.los_val
    from   ben_elig_per_f pep,
           ben_per_in_ler pil
    where  pep.person_id = c_person_id
    and    nvl(pep.pgm_id,-1)  = c_pgm_id
    and    nvl(pep.pl_id,-1)   = c_pl_id
    and    pep.plip_id is null
    and    nvl(pep.ptip_id,-1) = c_ptip_id
    and    c_effective_date
           between pep.effective_start_date
           and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
            or pil.per_in_ler_stat_cd is null                  -- outer join condition
           )
    and    nvl(pil.assignment_id, -9999) = decode (c_mode_cd,
                                           'I',
				           c_irec_asg_id,
				           nvl(pil.assignment_id, -9999));
  --
  l_elig_per_id           number;
  l_elig_per_elig_flag    varchar2(1000);
  l_prev_prtn_strt_dt     date;
  l_prev_prtn_end_dt      date;
  l_per_in_ler_id         number;
  l_object_version_number number;
  l_prev_eligibility      boolean;
  l_prev_age_val          number;
  l_prev_los_val          number;
  --
begin
  --
  open c_prev_elig_check
    (c_person_id      => p_person_id
    ,c_pgm_id         => p_pgm_id
    ,c_pl_id          => p_pl_id
    ,c_ptip_id        => p_ptip_id
    ,c_effective_date => p_effective_date
    ,c_mode_cd        => p_mode_cd
    ,c_irec_asg_id    => p_irec_asg_id
    );
  --
  fetch c_prev_elig_check into l_elig_per_id,
                               l_elig_per_elig_flag,
                               l_prev_prtn_strt_dt,
                               l_prev_prtn_end_dt,
                               l_per_in_ler_id,
                               l_object_version_number,
                               l_prev_age_val,
                               l_prev_los_val;
  if c_prev_elig_check%notfound then
    --
    l_prev_eligibility := false;
    --
  else
    --
    l_prev_eligibility := true;
    --
  end if;
  close c_prev_elig_check;
  --
  p_prev_eligibility      := l_prev_eligibility;
  p_elig_per_id           := l_elig_per_id;
  p_elig_per_elig_flag    := l_elig_per_elig_flag;
  p_prev_prtn_strt_dt     := l_prev_prtn_strt_dt;
  p_prev_prtn_end_dt      := l_prev_prtn_end_dt;
  p_per_in_ler_id         := l_per_in_ler_id;
  p_object_version_number := l_object_version_number;
  p_prev_age_val          := l_prev_age_val;
  p_prev_los_val          := l_prev_los_val;
  --
end prev_elig_check;
--
procedure prev_opt_elig_check
  (p_person_id        in        number
  ,p_effective_date   in        date
  ,p_pl_id            in        number
  ,p_opt_id           in        number
  ,p_mode_cd          in        varchar2
  ,p_irec_asg_id      in        number
  --
  ,p_prev_eligibility          out nocopy boolean
  ,p_elig_per_opt_id           out nocopy number
  ,p_opt_elig_flag             out nocopy varchar2
  ,p_prev_prtn_strt_dt         out nocopy date
  ,p_prev_prtn_end_dt          out nocopy date
  ,p_object_version_number_opt out nocopy number
  ,p_elig_per_id               out nocopy number
  ,p_per_in_ler_id             out nocopy number
  ,p_elig_per_prtn_strt_dt     out nocopy date
  ,p_elig_per_prtn_end_dt      out nocopy date
  ,p_prev_age_val          out nocopy number
  ,p_prev_los_val          out nocopy number
  )
is
  --
  cursor c_prev_opt_elig_check
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pl_id          in number
    ,c_opt_id         in number
    ,c_mode_cd        in varchar2
    ,c_irec_asg_id    in number
    )
  is
    select epo.elig_per_opt_id,
           epo.elig_flag,
           epo.prtn_strt_dt,
           epo.prtn_end_dt,
           epo.object_version_number,
           pep.elig_per_id,
           epo.per_in_ler_id,
           pep.prtn_strt_dt,
           pep.prtn_end_dt,
           epo.age_val,
           epo.los_val
    from   ben_elig_per_opt_f epo,
           ben_per_in_ler pil,
           ben_elig_per_f pep
    where  pep.person_id   = c_person_id
    and    pep.pl_id = c_pl_id
    and    epo.opt_id = c_opt_id
    and    pep.elig_per_id = epo.elig_per_id
    and    pep.pgm_id is null
    and    c_effective_date
           between pep.effective_start_date
           and pep.effective_end_date
    and    c_effective_date
           between epo.effective_start_date
           and epo.effective_end_date
    and    pil.per_in_ler_id(+)=epo.per_in_ler_id
    and    pil.business_group_id(+)=epo.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null)
    and    nvl(pil.assignment_id,-9999) = decode ( c_mode_cd,
                                          'I',
				          c_irec_asg_id,
				          nvl(pil.assignment_id, -9999)    );             -- iRec : Match assignment_id for iRec
  --
  l_elig_per_opt_id           number;
  l_opt_elig_flag             varchar2(1000);
  l_prev_prtn_strt_dt         date;
  l_prev_prtn_end_dt          date;
  l_object_version_number_opt number;
  l_elig_per_id               number;
  l_per_in_ler_id             number;
  l_elig_per_prtn_strt_dt     date;
  l_elig_per_prtn_end_dt      date;
  l_prev_eligibility          boolean;
  l_prev_age_val              number;
  l_prev_los_val              number;
  --
begin
  --
  open c_prev_opt_elig_check
    (c_person_id      => p_person_id
    ,c_effective_date => p_effective_date
    ,c_pl_id          => p_pl_id
    ,c_opt_id         => p_opt_id
    ,c_mode_cd        => p_mode_cd
    ,c_irec_asg_id    => p_irec_asg_id
    );
  --
  fetch c_prev_opt_elig_check into l_elig_per_opt_id,
                                   l_opt_elig_flag,
                                   l_prev_prtn_strt_dt,
                                   l_prev_prtn_end_dt,
                                   l_object_version_number_opt,
                                   l_elig_per_id,
                                   l_per_in_ler_id,
                                   l_elig_per_prtn_strt_dt,
                                   l_elig_per_prtn_end_dt,
                                   l_prev_age_val,
                                   l_prev_los_val;
  if c_prev_opt_elig_check%notfound then
    --
    l_prev_eligibility := false;
    --
  else
    --
    l_prev_eligibility := true;
    --
  end if;
  close c_prev_opt_elig_check;
  --
  p_prev_eligibility          := l_prev_eligibility;
  p_elig_per_opt_id           := l_elig_per_opt_id;
  p_opt_elig_flag             := l_opt_elig_flag;
  p_prev_prtn_strt_dt         := l_prev_prtn_strt_dt;
  p_prev_prtn_end_dt          := l_prev_prtn_end_dt;
  p_object_version_number_opt := l_object_version_number_opt;
  p_elig_per_id               := l_elig_per_id;
  p_per_in_ler_id             := l_per_in_ler_id;
  p_elig_per_prtn_strt_dt     := l_elig_per_prtn_strt_dt;
  p_elig_per_prtn_end_dt      := l_elig_per_prtn_end_dt;
  p_prev_age_val              := l_prev_age_val;
  p_prev_los_val              := l_prev_los_val;
  --
end prev_opt_elig_check;
--
end ben_determine_eligibility4;

/
