--------------------------------------------------------
--  DDL for Package Body BEN_GENERATE_COMMUNICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GENERATE_COMMUNICATIONS" as
/* $Header: bencommu.pkb 120.10.12010000.12 2010/03/15 04:38:40 pvelvano ship $ */
  --
  g_package varchar2(30) := 'ben_generate_communications.';
  -- bwharton bug 1619271 added 5 globals below.
  g_p_date_cd           varchar2(30);
  g_p_lf_evt_ocrd_dt    date;
  g_p_effective_date    date;
  g_p_formula_id        number;
  g_p_person_id         number;
  --
  function rule_passes(p_rule_id               in number,
                       p_person_id             in number,
                       p_assignment_id         in number,
               p_business_group_id     in number,
               p_organization_id       in number,
                   p_communication_type_id in number,
                   p_ler_id            in number default null,
                   p_pgm_id            in number default null,
                   p_pl_id             in number default null,
                   p_pl_typ_id             in number default null,
                   p_per_cm_id             in number default null,
                       p_effective_date        in date) return boolean is
    --
    l_proc              varchar2(80) := g_package||'rule_passes';
    l_outputs           ff_exec.outputs_t;
    l_jurisdiction_code pay_state_rules.jurisdiction_code%type;
    l_loc_rec           hr_locations_all%rowtype;
    l_ass_rec           per_all_assignments_f%rowtype;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Steps
    -- 1. If no rule exists return true
    -- 2. If a rule exists, evaluate rule
    -- 3. If evaluated value = 'N' return false
    --    If evaluated rule = 'Y' return true
    --
    -- Step 1.
    --
    if p_rule_id is null then
      --
      hr_utility.set_location('Leaving for rule id null : '||l_proc,10);
      return true;
      --
    else
      --
      -- Evaluate l_jurisdiction_code
      --
      ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_ass_rec);
      --
      if l_ass_rec.assignment_id is null then
        --
        -- Grab the persons benefits assignment instead
        --
        ben_person_object.get_benass_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
        --
      end if;
      --
      if l_ass_rec.location_id is not null then
        --
        ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                       p_rec         => l_loc_rec);
        --
        --if l_loc_rec.region_2 is not null then
        --   l_jurisdiction_code := pay_mag_utils.lookup_jurisdiction_code
        --                         (p_state => l_loc_rec.region_2);
        --end if;
        --
      end if;
      --
      -- Evaluate rule
      --
      -- Step 2.
      --
      l_outputs := benutils.formula
        (p_formula_id            => p_rule_id,
         p_effective_date        => p_effective_date,
         p_assignment_id         => p_assignment_id,
         p_business_group_id     => p_business_group_id,
     p_organization_id       => p_organization_id,
     p_communication_type_id => p_communication_type_id,
         p_ler_id                => p_ler_id,
         p_pgm_id                => p_pgm_id,
         p_pl_id                 => p_pl_id,
         p_pl_typ_id             => p_pl_typ_id,
         p_per_cm_id             => p_per_cm_id,
         p_jurisdiction_code     => l_jurisdiction_code,
         --RCHASE Bug Fix - Formula requires person_id as input value
         --RCHASE           for individuals without assignments
         p_param1                =>'PERSON_ID',
         p_param1_value          =>to_char(p_person_id)
         );
      --
      -- Step 3.
      --
      if l_outputs(l_outputs.first).value = 'Y' then
        --
        return true;
        --
      elsif l_outputs(l_outputs.first).value = 'N' then
        --
        return false;
        --
      elsif l_outputs(l_outputs.first).value <> 'N' then
        --
        fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
        fnd_message.set_token('RL','formula_id :'||p_rule_id);
        fnd_message.set_token('PROC',l_proc);
        raise ben_manage_life_events.g_record_error;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end rule_passes;
  --
  procedure pop_ben_per_cm_f
    (p_person_id         in  number
    ,p_ler_id            in  number
    ,p_per_in_ler_id     in  number
    ,p_prtt_enrt_actn_id in  number
    ,p_bnf_person_id     in  number
    ,p_dpnt_person_id    in  number
    ,p_cm_typ_id         in  number
    ,p_lf_evt_ocrd_dt    in  date
    ,p_rqstbl_untl_dt    in  date
    ,p_business_group_id in  number
    ,p_effective_date    in  date
    ,p_date_cd           in  varchar2
    ,p_formula_id        in  number
    ,p_pgm_id            in  number
    ,p_pl_id             in  number
    ,p_per_cm_id         out nocopy number
    )
  is
    --
    l_proc                  varchar2(80) := g_package||'pop_ben_per_cm_f';
    --
    -- Output variables
    --
    l_object_version_number number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    l_notfound              boolean;

    --
    cursor c_per_cm
      (c_ler_id     number
      ,c_pna_id     number
      ,c_per_id     number
      ,c_bnfper_id  number
      ,c_dpntper_id number
      ,c_cm_typ_id  number
      ,c_pil_id     number
      ,c_leo_dt     date
      ,c_eff_dt     date
      ,c_bgp_id     number
      ,c_comm_sdt   date
      )
    is
      select pcm.per_cm_id
      from   ben_per_cm_f pcm, ben_per_in_ler pil
             -- if commu table has no ler id dont compare , pil_id take care
             -- of validation # 3296015
      where (pcm.ler_id is null or  pcm.ler_id = c_ler_id)
      and    nvl(pcm.prtt_enrt_actn_id,-1) = nvl(c_pna_id,-1)
      and    nvl(pcm.person_id,-1) = nvl(c_per_id,-1)
      and    nvl(pcm.bnf_person_id,-1) = nvl(c_bnfper_id,-1)
      and    nvl(pcm.dpnt_person_id,-1) = nvl(c_dpntper_id,-1)
      and    nvl(pcm.cm_typ_id,-1) = nvl(c_cm_typ_id,-1)
      and    nvl(pcm.per_in_ler_id,-1) = nvl(c_pil_id,-1)
      and    nvl(pcm.lf_evt_ocrd_dt,nvl(c_leo_dt,c_eff_dt)) =
             nvl(c_leo_dt,c_eff_dt)
      and    pcm.business_group_id = c_bgp_id
      and    c_comm_sdt
             between pcm.effective_start_date
             and     pcm.effective_end_date
      and    pil.per_in_ler_id(+) = pcm.per_in_ler_id
      and    nvl(pil.business_group_id,c_bgp_id) =
             c_bgp_id
      and    nvl(pil.per_in_ler_stat_cd,'-1') not in ('VOIDD', 'BCKDT');
    --
    -- Added performant version of c_per_cm to fire only when PIL ID is set.
    --
    cursor c_pil_per_cm
      (c_ler_id     number
      ,c_pna_id     number
      ,c_per_id     number
      ,c_bnfper_id  number
      ,c_dpntper_id number
      ,c_cm_typ_id  number
      ,c_pil_id     number
      ,c_leo_dt     date
      ,c_eff_dt     date
      ,c_comm_sdt   date
      )
    is
      select pcm.per_cm_id
      from   ben_per_cm_f pcm,ben_per_cm_prvdd_f pcpf
      where  pcm.per_in_ler_id = c_pil_id
             -- if commu table has no ler id dont compare , pil_id take care
             -- of validation # 3296015
      and   (pcm.ler_id is null or  pcm.ler_id = c_ler_id)
      and    nvl(pcm.prtt_enrt_actn_id,-1) = nvl(c_pna_id,-1)
      and    nvl(pcm.person_id,-1) = nvl(c_per_id,-1)
      and    nvl(pcm.bnf_person_id,-1) = nvl(c_bnfper_id,-1)
      and    nvl(pcm.dpnt_person_id,-1) = nvl(c_dpntper_id,-1)
      and    nvl(pcm.cm_typ_id,-1) = nvl(c_cm_typ_id,-1)
      and    pcm.per_cm_id = pcpf.per_cm_id
      and    pcpf.per_cm_prvdd_stat_cd <> 'VOID'
             -- Bug :7629124, Check to see if Communication is VOIDed.If VOIDed, then create a new Communication for the same LE
	     -- Added ben_per_cm_prvdd_f table to the cursor for verification
      and    nvl(pcm.lf_evt_ocrd_dt,nvl(c_leo_dt,c_eff_dt)) =
             nvl(c_leo_dt,c_eff_dt)
      and    c_comm_sdt
        between pcm.effective_start_date and pcm.effective_end_date;
    --
    -- Added performant version of c_per_cm to fire only when PER ID is set.
    --
    cursor c_perid_per_cm
      (c_ler_id     number
      ,c_pna_id     number
      ,c_per_id     number
      ,c_bnfper_id  number
      ,c_dpntper_id number
      ,c_cm_typ_id  number
      ,c_leo_dt     date
      ,c_eff_dt     date
      ,c_comm_sdt   date
      )
    is
      select pcm.per_cm_id
      from   ben_per_cm_f pcm
      where  pcm.person_id = c_per_id
             -- if commu table has no ler id dont compare , pil_id take care
             -- of validation # 3296015
      and   (pcm.ler_id is null or  pcm.ler_id = c_ler_id)
      and    nvl(pcm.prtt_enrt_actn_id,-1) = nvl(c_pna_id,-1)
      and    nvl(pcm.bnf_person_id,-1) = nvl(c_bnfper_id,-1)
      and    nvl(pcm.dpnt_person_id,-1) = nvl(c_dpntper_id,-1)
      and    nvl(pcm.cm_typ_id,-1) = nvl(c_cm_typ_id,-1)
      and    nvl(pcm.lf_evt_ocrd_dt,nvl(c_leo_dt,c_eff_dt)) =
             nvl(c_leo_dt,c_eff_dt)
      and    c_comm_sdt
        between pcm.effective_start_date and pcm.effective_end_date;

  CURSOR c_pea
   IS
      SELECT effective_start_date
        FROM ben_prtt_enrt_actn_f
       WHERE prtt_enrt_actn_id = p_prtt_enrt_actn_id;
  l_pea_esd  date;
  -- added cursor for bug: 5499162
   CURSOR c_oipl
   IS
      SELECT oipl_id
        FROM ben_prtt_enrt_rslt_f
       WHERE prtt_enrt_rslt_id IN (
                                SELECT prtt_enrt_rslt_id
                                  FROM ben_prtt_enrt_actn_f
                                 WHERE prtt_enrt_actn_id =
                                                          p_prtt_enrt_actn_id);
   l_oipl_id ben_prtt_enrt_rslt_f.oipl_id%TYPE;
   -- end addition

  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Reset the globals for the communication.
    --
    g_comm_start_date := null;
    g_to_be_sent_dt   := null;
    --
    begin
      --
      -- bwharton Bug 1619171.
      -- Initialize globals to pass to check_hipaa_ctfn
      -- this will allow the correct info to be passed to
      -- ben_determine_date.
      g_p_date_cd := p_date_cd;
      g_p_person_id := p_person_id;
      g_p_formula_id := p_formula_id;
      g_p_effective_date := p_effective_date;
      g_p_lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
      --
      -- change here for bug: 5499162
      OPEN c_oipl;
	FETCH c_oipl
	  INTO l_oipl_id;
      CLOSE c_oipl;

      ben_determine_date.main
        (p_date_cd           => p_date_cd,
         p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_business_group_id => p_business_group_id,
         p_formula_id        => p_formula_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_returned_date     => g_to_be_sent_dt,
	 p_oipl_id           => l_oipl_id); -- added for bug: 5499162
	 -- change end
      --
    exception
      --
      when others then
        --
        g_to_be_sent_dt := p_effective_date;
        --
    end;
    --
    g_comm_start_date :=  p_effective_date;
    --
    if g_to_be_sent_dt < g_comm_start_date then
      --
      g_comm_start_date := g_to_be_sent_dt;
      --
    end if;
    --start 5332579
/***
if any issue use Alternate fix : bendenrr.pkb ,store backed_out_date to g_backed_out_date.
if g_comm_start_date < g_backed_out_date then g_comm_start_date = g_backed_out_date
****/
    IF p_prtt_enrt_actn_id IS NOT NULL
   THEN
      OPEN c_pea;
      FETCH c_pea INTO l_pea_esd;

      IF c_pea%FOUND
      THEN
         hr_utility.set_location ('PEA strt date ' || l_pea_esd, 10);

         IF l_pea_esd > g_comm_start_date
         THEN
            --
            g_comm_start_date := l_pea_esd;
         --
         END IF;

         hr_utility.set_location (   'final g_comm_start_date '
                                  || g_comm_start_date,
                                  10
                                 );
         CLOSE c_pea;
      ELSE
         CLOSE c_pea;
      END IF;
   END IF;

   -- end 5332579
    --
    -- Check if the PIL ID is set. If so then fire c_pil_per_cm
    -- rather than c_per_cm
    --
          hr_utility.set_location ('p_lf_evt_ocrd_dt 1'||p_lf_evt_ocrd_dt,101);
	  hr_utility.set_location ('p_effective_date 1'||p_effective_date,101);
          hr_utility.set_location ('Condition'||ben_generate_communications.g_comm_start_date,101);
    if p_per_in_ler_id is not null then
      --
      hr_utility.set_location ('Condition 1',101);
      open c_pil_per_cm
        (c_ler_id     => p_ler_id
        ,c_pna_id     => p_prtt_enrt_actn_id
        ,c_per_id     => p_person_id
        ,c_bnfper_id  => p_bnf_person_id
        ,c_dpntper_id => p_dpnt_person_id
        ,c_cm_typ_id  => p_cm_typ_id
        ,c_pil_id     => p_per_in_ler_id
        ,c_leo_dt     => p_lf_evt_ocrd_dt
        ,c_eff_dt     => p_effective_date
        ,c_comm_sdt   => ben_generate_communications.g_comm_start_date
        );
      fetch c_pil_per_cm into p_per_cm_id;
      if c_pil_per_cm%notfound then
        l_notfound := TRUE;
      else
        l_notfound := FALSE;
      end if;
      close c_pil_per_cm;
      --
    elsif p_person_id is not null
    then
      --
            hr_utility.set_location ('Condition 2',101);
      open c_perid_per_cm
        (c_ler_id     => p_ler_id
        ,c_pna_id     => p_prtt_enrt_actn_id
        ,c_per_id     => p_person_id
        ,c_bnfper_id  => p_bnf_person_id
        ,c_dpntper_id => p_dpnt_person_id
        ,c_cm_typ_id  => p_cm_typ_id
        ,c_leo_dt     => p_lf_evt_ocrd_dt
        ,c_eff_dt     => p_effective_date
        ,c_comm_sdt   => ben_generate_communications.g_comm_start_date
        );
      fetch c_perid_per_cm into p_per_cm_id;
      if c_perid_per_cm%notfound then
        l_notfound := TRUE;
      else
        l_notfound := FALSE;
      end if;
      close c_perid_per_cm;
      --
    else
      --
            hr_utility.set_location ('Condition 3',101);
      open c_per_cm
        (c_ler_id     => p_ler_id
        ,c_pna_id     => p_prtt_enrt_actn_id
        ,c_per_id     => p_person_id
        ,c_bnfper_id  => p_bnf_person_id
        ,c_dpntper_id => p_dpnt_person_id
        ,c_cm_typ_id  => p_cm_typ_id
        ,c_pil_id     => p_per_in_ler_id
        ,c_leo_dt     => p_lf_evt_ocrd_dt
        ,c_eff_dt     => p_effective_date
        ,c_bgp_id     => p_business_group_id
        ,c_comm_sdt   => ben_generate_communications.g_comm_start_date
        );
      --
      fetch c_per_cm into p_per_cm_id;
      if c_per_cm%notfound then
        l_notfound := TRUE;
      else
        l_notfound := FALSE;
      end if;
      close c_per_cm;
      --
    end if;
    --
    if l_notfound then
      --
      ben_per_cm_api.create_per_cm_perf
        (p_validate                       => false
        ,p_per_cm_id                      => p_per_cm_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
        ,p_rqstbl_untl_dt                 => p_rqstbl_untl_dt
        ,p_ler_id                         => p_ler_id
        ,p_per_in_ler_id                  => p_per_in_ler_id
        ,p_prtt_enrt_actn_id              => p_prtt_enrt_actn_id
        ,p_person_id                      => p_person_id
        ,p_bnf_person_id                  => p_bnf_person_id
        ,p_dpnt_person_id                 => p_dpnt_person_id
        ,p_cm_typ_id                      => p_cm_typ_id
        ,p_business_group_id              => p_business_group_id
        ,p_pcm_attribute_category         => null
        ,p_pcm_attribute1                 => null
        ,p_pcm_attribute2                 => null
        ,p_pcm_attribute3                 => null
        ,p_pcm_attribute4                 => null
        ,p_pcm_attribute5                 => null
        ,p_pcm_attribute6                 => null
        ,p_pcm_attribute7                 => null
        ,p_pcm_attribute8                 => null
        ,p_pcm_attribute9                 => null
        ,p_pcm_attribute10                => null
        ,p_pcm_attribute11                => null
        ,p_pcm_attribute12                => null
        ,p_pcm_attribute13                => null
        ,p_pcm_attribute14                => null
        ,p_pcm_attribute15                => null
        ,p_pcm_attribute16                => null
        ,p_pcm_attribute17                => null
        ,p_pcm_attribute18                => null
        ,p_pcm_attribute19                => null
        ,p_pcm_attribute20                => null
        ,p_pcm_attribute21                => null
        ,p_pcm_attribute22                => null
        ,p_pcm_attribute23                => null
        ,p_pcm_attribute24                => null
        ,p_pcm_attribute25                => null
        ,p_pcm_attribute26                => null
        ,p_pcm_attribute27                => null
        ,p_pcm_attribute28                => null
        ,p_pcm_attribute29                => null
        ,p_pcm_attribute30                => null
        ,p_object_version_number          => l_object_version_number
        ,p_effective_date                 => ben_generate_communications.
                                             g_comm_start_date
        ,p_request_id                     => fnd_global.conc_request_id
        ,p_program_application_id         => fnd_global.prog_appl_id
        ,p_program_id                     => fnd_global.conc_program_id
        ,p_program_update_date            => sysdate
        );
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end pop_ben_per_cm_f;
  --
  procedure pop_ben_per_cm_trgr_f(p_per_cm_id         in  number,
                                  p_cm_trgr_id        in  number,
                                  p_business_group_id in  number,
                                  p_effective_date    in  date,
                                  p_per_cm_trgr_id    out nocopy number) is
    --
    l_proc                  varchar2(80) := g_package||'pop_ben_per_cm_trgr_f';
    --
    -- Output variables
    --
    l_object_version_number number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    --
    cursor c_per_cm_trgr is
      select null
      from   ben_per_cm_trgr_f pcr
      where  pcr.cm_trgr_id = p_cm_trgr_id
      and    pcr.per_cm_id = p_per_cm_id
      and    pcr.business_group_id   = p_business_group_id
      and    ben_generate_communications.g_comm_start_date
             between pcr.effective_start_date
             and     pcr.effective_end_date;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    open c_per_cm_trgr;
      --
      fetch c_per_cm_trgr into p_per_cm_trgr_id;
      if c_per_cm_trgr%notfound then
        --
        ben_per_cm_trgr_api.create_per_cm_trgr_perf
          (p_validate                       => false
          ,p_per_cm_trgr_id                 => p_per_cm_trgr_id
          ,p_effective_start_date           => l_effective_start_date
          ,p_effective_end_date             => l_effective_end_date
          ,p_cm_trgr_id                     => p_cm_trgr_id
          ,p_per_cm_id                      => p_per_cm_id
          ,p_business_group_id              => p_business_group_id
          ,p_pcr_attribute_category         => null
          ,p_pcr_attribute1                 => null
          ,p_pcr_attribute2                 => null
          ,p_pcr_attribute3                 => null
          ,p_pcr_attribute4                 => null
          ,p_pcr_attribute5                 => null
          ,p_pcr_attribute6                 => null
          ,p_pcr_attribute7                 => null
          ,p_pcr_attribute8                 => null
          ,p_pcr_attribute9                 => null
          ,p_pcr_attribute10                => null
          ,p_pcr_attribute11                => null
          ,p_pcr_attribute12                => null
          ,p_pcr_attribute13                => null
          ,p_pcr_attribute14                => null
          ,p_pcr_attribute15                => null
          ,p_pcr_attribute16                => null
          ,p_pcr_attribute17                => null
          ,p_pcr_attribute18                => null
          ,p_pcr_attribute19                => null
          ,p_pcr_attribute20                => null
          ,p_pcr_attribute21                => null
          ,p_pcr_attribute22                => null
          ,p_pcr_attribute23                => null
          ,p_pcr_attribute24                => null
          ,p_pcr_attribute25                => null
          ,p_pcr_attribute26                => null
          ,p_pcr_attribute27                => null
          ,p_pcr_attribute28                => null
          ,p_pcr_attribute29                => null
          ,p_pcr_attribute30                => null
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => ben_generate_communications.
                                               g_comm_start_date);
        --
      end if;
      --
    close c_per_cm_trgr;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end pop_ben_per_cm_trgr_f;
  --
  procedure pop_ben_per_cm_prvdd_f(p_per_cm_id            in  number,
                                   p_effective_date       in  date,
                                   p_rqstd_flag           in  varchar2,
                                   p_inspn_rqd_flag       in  varchar2,
                                   p_per_cm_prvdd_stat_cd in  varchar2,
                                   p_cm_dlvry_med_cd      in  varchar2,
                                   p_cm_dlvry_mthd_cd     in  varchar2,
                                   p_sent_dt              in  date,
                                   p_mode                 in  varchar2,
                                   p_dlvry_instn_txt      in  varchar2,
                                   p_address_id           in  number,
                                   p_business_group_id    in  number,
                                   p_per_cm_prvdd_id      out nocopy number) is
    --
    l_proc varchar2(80) := g_package||'pop_ben_per_cm_prvdd_f';
    --
    -- Output variables
    --
    l_object_version_number number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    --
    cursor c_per_cm_prvdd is
      select pcd.*
      from   ben_per_cm_prvdd_f pcd
      where  pcd.per_cm_id = p_per_cm_id
      and    pcd.sent_dt is null
      and    pcd.business_group_id = p_business_group_id
      and    ben_generate_communications.g_comm_start_date
             between pcd.effective_start_date
             and     pcd.effective_end_date;
    --
    cursor c_get_instnc_num is
      select max(pcd.instnc_num)
      from   ben_per_cm_prvdd_f pcd
      where  pcd.per_cm_id = p_per_cm_id
      and    pcd.business_group_id = p_business_group_id
      and    ben_generate_communications.g_comm_start_date
             between pcd.effective_start_date
             and     pcd.effective_end_date;
    --
    l_instnc_num number;
    l_pcd_rec    c_per_cm_prvdd%rowtype;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    open c_per_cm_prvdd;
      --
      fetch c_per_cm_prvdd into l_pcd_rec;
      --
      if c_per_cm_prvdd%notfound then
        close c_per_cm_prvdd;
        --
        -- Get the instance number
        --
        open c_get_instnc_num;
        fetch c_get_instnc_num into l_instnc_num;
        close c_get_instnc_num;
        if l_instnc_num is null then
          --
          -- New communication.
          --
          l_instnc_num := 1;
        else
          l_instnc_num := l_instnc_num + 1;
        end if;
        --
        ben_per_cm_prvdd_api.create_per_cm_prvdd_perf
          (p_validate                       => false
          ,p_per_cm_prvdd_id                => p_per_cm_prvdd_id
          ,p_effective_start_date           => l_effective_start_date
          ,p_effective_end_date             => l_effective_end_date
          ,p_rqstd_flag                     => p_rqstd_flag
          ,p_inspn_rqd_flag                 => p_inspn_rqd_flag
          ,p_per_cm_prvdd_stat_cd           => p_per_cm_prvdd_stat_cd
          ,p_cm_dlvry_med_cd                => p_cm_dlvry_med_cd
          ,p_cm_dlvry_mthd_cd               => p_cm_dlvry_mthd_cd
          ,p_sent_dt                        => p_sent_dt
          ,p_instnc_num                     => l_instnc_num
          ,p_to_be_sent_dt                  => g_to_be_sent_dt
          ,p_dlvry_instn_txt                => p_dlvry_instn_txt
          ,p_per_cm_id                      => p_per_cm_id
          ,p_address_id                     => p_address_id
          ,p_business_group_id              => p_business_group_id
          ,p_pcd_attribute_category         => null
          ,p_pcd_attribute1                 => null
          ,p_pcd_attribute2                 => null
          ,p_pcd_attribute3                 => null
          ,p_pcd_attribute4                 => null
          ,p_pcd_attribute5                 => null
          ,p_pcd_attribute6                 => null
          ,p_pcd_attribute7                 => null
          ,p_pcd_attribute8                 => null
          ,p_pcd_attribute9                 => null
          ,p_pcd_attribute10                => null
          ,p_pcd_attribute11                => null
          ,p_pcd_attribute12                => null
          ,p_pcd_attribute13                => null
          ,p_pcd_attribute14                => null
          ,p_pcd_attribute15                => null
          ,p_pcd_attribute16                => null
          ,p_pcd_attribute17                => null
          ,p_pcd_attribute18                => null
          ,p_pcd_attribute19                => null
          ,p_pcd_attribute20                => null
          ,p_pcd_attribute21                => null
          ,p_pcd_attribute22                => null
          ,p_pcd_attribute23                => null
          ,p_pcd_attribute24                => null
          ,p_pcd_attribute25                => null
          ,p_pcd_attribute26                => null
          ,p_pcd_attribute27                => null
          ,p_pcd_attribute28                => null
          ,p_pcd_attribute29                => null
          ,p_pcd_attribute30                => null
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => ben_generate_communications.
                                               g_comm_start_date);
        --
      else
        close c_per_cm_prvdd;
      end if;
      --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end pop_ben_per_cm_prvdd_f;
  --
  procedure pop_ben_per_cm_usg_f
            (p_per_cm_id            in  number,
             p_cm_typ_usg_id        in  number,
             p_business_group_id    in  number,
             p_effective_date       in  date,
             p_per_cm_usg_id        out nocopy number,
             p_usage_created        out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'pop_ben_per_cm_usg_f';
    --
    -- Output variables
    --
    l_object_version_number number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    --
    cursor c1 is
      select pcu.per_cm_usg_id
      from   ben_per_cm_usg_f pcu
      where  pcu.per_cm_id = p_per_cm_id
      and    pcu.cm_typ_usg_id = p_cm_typ_usg_id
      and    pcu.business_group_id   = p_business_group_id
      and    ben_generate_communications.g_comm_start_date between
             pcu.effective_start_date and pcu.effective_end_date;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    p_usage_created := true;
    --
    open c1;
      --
      fetch c1 into p_per_cm_usg_id;
      if c1%notfound then
        --
        --
        ben_per_cm_usg_api.create_per_cm_usg_perf
          (p_validate                       => false
          ,p_per_cm_usg_id                  => p_per_cm_usg_id
          ,p_effective_start_date           => l_effective_start_date
          ,p_effective_end_date             => l_effective_end_date
          ,p_per_cm_id                      => p_per_cm_id
          ,p_cm_typ_usg_id                  => p_cm_typ_usg_id
          ,p_business_group_id              => p_business_group_id
          ,p_pcu_attribute_category         => null
          ,p_pcu_attribute1                 => null
          ,p_pcu_attribute2                 => null
          ,p_pcu_attribute3                 => null
          ,p_pcu_attribute4                 => null
          ,p_pcu_attribute5                 => null
          ,p_pcu_attribute6                 => null
          ,p_pcu_attribute7                 => null
          ,p_pcu_attribute8                 => null
          ,p_pcu_attribute9                 => null
          ,p_pcu_attribute10                => null
          ,p_pcu_attribute11                => null
          ,p_pcu_attribute12                => null
          ,p_pcu_attribute13                => null
          ,p_pcu_attribute14                => null
          ,p_pcu_attribute15                => null
          ,p_pcu_attribute16                => null
          ,p_pcu_attribute17                => null
          ,p_pcu_attribute18                => null
          ,p_pcu_attribute19                => null
          ,p_pcu_attribute20                => null
          ,p_pcu_attribute21                => null
          ,p_pcu_attribute22                => null
          ,p_pcu_attribute23                => null
          ,p_pcu_attribute24                => null
          ,p_pcu_attribute25                => null
          ,p_pcu_attribute26                => null
          ,p_pcu_attribute27                => null
          ,p_pcu_attribute28                => null
          ,p_pcu_attribute29                => null
          ,p_pcu_attribute30                => null
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => ben_generate_communications.
                                               g_comm_start_date);
        --
      end if;
      --
    close c1;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end pop_ben_per_cm_usg_f;
  --
  procedure populate_working_tables
    (p_person_id         in number,
     p_cm_typ_id         in number,
     p_business_group_id in number,
     p_effective_date    in date,
     p_cm_trgr_id        in number,
     p_inspn_rqd_flag    in varchar2,
     p_cm_dlvry_med_cd   in varchar2,
     p_cm_dlvry_mthd_cd  in varchar2,
     p_per_cm_id         in number,
     p_mode              in varchar2 default 'I') is
    --
    l_proc            varchar2(80) := g_package||'populate_working_tables';
    l_per_cm_trgr_id  number;
    l_per_cm_prvdd_id number;
    l_new_instnc      boolean := TRUE;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    pop_ben_per_cm_trgr_f
      (p_per_cm_id            => p_per_cm_id,
       p_cm_trgr_id           => p_cm_trgr_id,
       p_business_group_id    => p_business_group_id,
       p_effective_date       => p_effective_date,
       p_per_cm_trgr_id       => l_per_cm_trgr_id);
    --
    pop_ben_per_cm_prvdd_f
      (p_per_cm_id            => p_per_cm_id,
       p_rqstd_flag           => 'N',
       p_inspn_rqd_flag       => p_inspn_rqd_flag,
       p_per_cm_prvdd_stat_cd => 'ACTIVE',
       p_cm_dlvry_med_cd      => p_cm_dlvry_med_cd,
       p_cm_dlvry_mthd_cd     => p_cm_dlvry_mthd_cd,
       p_sent_dt              => null,
       p_mode                 => p_mode,
       p_dlvry_instn_txt      => null,
       p_address_id           => null,
       p_business_group_id    => p_business_group_id,
       p_effective_date       => p_effective_date,
       p_per_cm_prvdd_id      => l_per_cm_prvdd_id);
    --
    g_commu_rec.person_id         := p_person_id;
    g_commu_rec.per_cm_id         := p_per_cm_id;
    g_commu_rec.cm_typ_id         := p_cm_typ_id;
    g_commu_rec.per_cm_prvdd_id   := l_per_cm_prvdd_id;
    g_commu_rec.to_be_sent_dt     := g_to_be_sent_dt;
    g_commu_rec.business_group_id := p_business_group_id;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end populate_working_tables;
  --
  function get_cvg_strt_dt (p_elig_per_id   number,
                            p_per_in_ler_id number )
  return date is
       --
       cursor c_pep IS
       select pgm_id,
              pl_id
         from ben_elig_per_f pep
        where pep.per_in_ler_id = p_per_in_ler_id
          and pep.elig_per_id = p_elig_per_id ;
       --
       cursor c_epe_pgm(p_pgm_id number,p_pl_id number) IS
       select epe.fonm_cvg_strt_dt
         from ben_pil_elctbl_chc_popl popl,
              ben_elig_per_elctbl_chc epe
        where popl.per_in_ler_id = p_per_in_ler_id
          and popl.pgm_id = p_pgm_id
          and epe.pil_elctbl_chc_popl_id = popl.pil_elctbl_chc_popl_id
          and NVL(epe.pl_id,-1) =  nvl(p_pl_id, nvl(epe.pl_id,-1)) -- 5633934 : Added this condition
	  and not exists (select 'x' from ben_pil_elctbl_chc_popl popl1, ben_elig_per_elctbl_chc epe1
	                where popl1.per_in_ler_id = p_per_in_ler_id
                        and popl1.pgm_id = p_pgm_id
                        and epe1.pil_elctbl_chc_popl_id = popl1.pil_elctbl_chc_popl_id
                        and NVL(epe1.pl_id,-1) =  nvl(p_pl_id, nvl(epe1.pl_id,-1))
			and epe.fonm_cvg_strt_dt > epe1.fonm_cvg_strt_dt); /*Added not exists clause for Bug 7268357*/
       --
       cursor c_epe_pl(p_pl_id number) IS
       select epe.fonm_cvg_strt_dt
         from ben_pil_elctbl_chc_popl popl,
              ben_elig_per_elctbl_chc epe
        where popl.per_in_ler_id = p_per_in_ler_id
          and popl.pl_id = p_pl_id
          and epe.pil_elctbl_chc_popl_id = popl.pil_elctbl_chc_popl_id;
       --
       l_pl_id     number;
       l_pgm_id    number;
       l_cvg_date  date;
    begin
      --
      open c_pep ;
        fetch c_pep into l_pgm_id,l_pl_id ;
      close c_pep;
      --
      IF l_pgm_id IS NOT NULL THEN
         open c_epe_pgm(l_pgm_id, l_pl_id);
           fetch c_epe_pgm into l_cvg_date ;
         close c_epe_pgm ;
      ELSIF  l_pl_id IS NOT NULL THEN
         open c_epe_pl(l_pl_id);
           fetch c_epe_pl into l_cvg_date ;
         close c_epe_pl ;
      END IF;
      --
      /*
       open c_epe;
       fetch c_epe into l_cvg_date;
       close c_epe;
      */
      return l_cvg_date;
      --
  end get_cvg_strt_dt;

  procedure check_first_time_elig_inelig
      (p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       -- PB : 5422 :
       -- p_enrt_perd_id      in number,
       p_asnd_lf_evt_dt    in date,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_ler_id            in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_eligible_flag     in varchar2,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_first_time_elig_inelig';
    l_effective_date date;
    l_effective_date_1 date;
    --

    /* Added for Bug 8227214 */
    cursor c_get_per_in_ler(c_lf_evt_ocrd_dt date) is
    select pil.per_in_ler_id from ben_per_in_ler pil,ben_ler_f le
    where pil.lf_evt_ocrd_dt=c_lf_evt_ocrd_dt
    and pil.ler_id=le.ler_id
    and pil.person_id=p_person_id
    and c_lf_evt_ocrd_dt between le.effective_start_date and le.effective_end_date
    and  pil.per_in_ler_stat_cd NOT IN ( 'VOIDD', 'BCKDT')
    and le.typ_cd not in ('IREC','GSP','COMP','ABS','SCHEDDU','SCHEDDA');

    l_per_in_ler_id number;
    /* End of Bug 8227214 */


    cursor c1(cv_effective_date date, cv_effective_date_1 date) is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.ler_id,
             ctu.pl_typ_id,
	     get_cvg_strt_dt(pep.elig_per_id,pil.per_in_ler_id) cvg_dt,
	     pil.per_in_ler_id,
	     pep.elig_per_id,
	     pep.pgm_id ppgm_id,
	     pep.pl_id ppl_id
      from   ben_cm_typ_usg_f ctu,
             ben_elig_per_f pep,
             ben_per_in_ler pil
      where  ctu.business_group_id   = p_business_group_id
      and    pep.business_group_id   = ctu.business_group_id
      and    pep.person_id = p_person_id
      and    pil.per_in_ler_id = l_per_in_ler_id  -- Bug 8227214
      and    pep.per_in_ler_id = pil.per_in_ler_id -- Bug 8227214
      /*Commented condition for Bug 8227214 */
      /*and    nvl(get_cvg_strt_dt(pep.elig_per_id,pil.per_in_ler_id),cv_effective_date)
             between pep.effective_start_date and pep.effective_end_date*/
      and    nvl(ctu.ler_id,nvl(pil.ler_id,-1)) = nvl(pil.ler_id,-1)
      and    nvl(ctu.pgm_id,nvl(pep.pgm_id,-1)) = nvl(pep.pgm_id,-1)
      /* Bug 8809596: Pick the correct eligibility record instead of looping through all the
      eligibility records when Plan Usage is Null or PlanType Usage is Null*/
      and    ( (ctu.pl_typ_id is not null and nvl(ctu.pl_id,nvl(pep.pl_id,-1))   = nvl(pep.pl_id,-1) )
               or (ctu.pl_typ_id is null and nvl(ctu.pl_id,-1)   = nvl(pep.pl_id,-1))
             )
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
             /* Now join in enrollment period */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
             )
             -- if pl_typ is in usages , validte the pl  against pl_type
       and   (ctu.pl_typ_id is  null  or
                  exists
                  ( select 'x'
                          from  ben_pl_f  pl
                           where  pl.pl_id     = pep.pl_id
                             and  pl.pl_typ_id = ctu.pl_typ_id
                             and  cv_effective_date  between
                                  pl.effective_start_date
                                  and pl.effective_end_date

                  )
             )
             /* Use nvl here as only pgm pl can be populated */
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
             /* Final test make sure eligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      -- and    (pep.effective_start_date = p_effective_date or
      --         pep.effective_start_date = p_lf_evt_ocrd_dt)
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    pil.per_in_ler_id(+) = pep.per_in_ler_id
      and    nvl(pil.business_group_id,p_business_group_id) =
             p_business_group_id
      and    nvl(pil.per_in_ler_stat_cd,'-1') not in ('VOIDD','BCKDT')
      ---look for previous eligble
      and ((   p_eligible_flag = 'Y'
               and   not exists ( SELECT 'x'
                FROM   ben_elig_per_f pep2, ben_per_in_ler pil2
                        WHERE    pep2.person_id         = pep.person_id
                          AND    (ctu.pl_id   is null or nvl(pep2.pl_id,-1)  = nvl(pep.pl_id,-1)   )
                          AND    (ctu.pgm_id  is null or nvl(pep2.pgm_id,-1) = nvl(pep.pgm_id,-1)  )
                                 --- pep ler id is not updated so pil ler id is validated # 2784972
			  /*Bug 9454579 : Uncommented the below condition*/
                          AND    (ctu.ler_id  is null or nvl(ctu.ler_id,-1) = nvl(pil2.ler_id,-1) )
                          AND    (ctu.pl_typ_id is null or
                                   (exists
                                      ( select 'x'
                                          from  ben_pl_f  pl
                                          where  pl.pl_id     = nvl(pep2.pl_id,pl.pl_id)
                                            and  pl.pl_typ_id = nvl(ctu.pl_typ_id,pl.pl_typ_id)
                                            and  cv_effective_date  between
                                                 pl.effective_start_date
                                                  and pl.effective_end_date
                                        )
                                    ) )
                          AND    pep2.business_group_id = pep.business_group_id
                          AND    pep2.elig_flag = 'Y'
                          AND    pep.effective_start_date-1 -- Bug 8809596 : modified cond to pep.effective_start_date-1
                                 BETWEEN pep2.effective_start_date AND pep2.effective_end_date
                          AND      pil2.per_in_ler_id  = pep2.per_in_ler_id
			  /*Commented below condition for Bug 8809596*/
			  --and      pil2.per_in_ler_id <> l_per_in_ler_id -- Bug 8227214
                          AND      pil2.business_group_id  = pep2.business_group_id
                          AND      ( pil2.per_in_ler_stat_cd NOT IN
                                        ( 'VOIDD', 'BCKDT')
                                     OR pil2.per_in_ler_stat_cd IS NULL)    --
                      )
              )
            OR
             (   p_eligible_flag = 'N'
               and   exists ( SELECT 'x'
                FROM   ben_elig_per_f pep2, ben_per_in_ler pil2
                        WHERE    pep2.person_id         = pep.person_id
                          AND    (ctu.pl_id   is null or nvl(pep2.pl_id,-1)  = nvl(pep.pl_id,-1)   )
                          AND    (ctu.pgm_id  is null or nvl(pep2.pgm_id,-1) = nvl(pep.pgm_id,-1)  )
                                 -- pep ler id is not updated so pil led id is used # 2784972
		          /*Bug 9454579 : Uncommented the below condition*/
                          AND    (ctu.ler_id  is null or nvl(ctu.ler_id,-1) = nvl(pil2.ler_id,-1) )
                          AND    (ctu.pl_typ_id is null or
                                   (exists
                                      ( select 'x'
                                          from  ben_pl_f  pl
                                          where  pl.pl_id     = nvl(pep2.pl_id,pl.pl_id)
                                            and  pl.pl_typ_id = nvl(ctu.pl_typ_id,pl.pl_typ_id)
                                            and  cv_effective_date  between
                                                 pl.effective_start_date
                                                  and pl.effective_end_date
                                        )
                                    ) )
                          AND    pep2.business_group_id = pep.business_group_id
                          AND    pep2.elig_flag = 'N'
                          AND     pep.effective_start_date-1 -- Bug 8809596 : modified cond to pep.effective_start_date-1
                                 BETWEEN pep2.effective_start_date AND pep2.effective_end_date
                          AND      pil2.per_in_ler_id (+) = pep2.per_in_ler_id
			  /*Commented below condition for Bug 8809596*/
			  --and      pil2.per_in_ler_id <> l_per_in_ler_id -- Bug 8227214
                          AND      pil2.business_group_id (+) = pep2.business_group_id
                          AND      ( pil2.per_in_ler_stat_cd NOT IN
                                        ( 'VOIDD', 'BCKDT')
                                     OR pil2.per_in_ler_stat_cd IS NULL)    --
                      )
              )
           )  ;

    --
    cursor c2(cv_effective_date date, cv_lf_evt_ocrd_dt date) is
      select null
      from   ben_elig_per_f pep,
             ben_per_in_ler pil
      where  pep.business_group_id = p_business_group_id
      and    pep.person_id = p_person_id
      and    nvl(get_cvg_strt_dt(pep.elig_per_id,pil.per_in_ler_id),cv_effective_date)
             between pep.effective_start_date and     pep.effective_end_date
             /* Final test make sure eligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = cv_effective_date or
              pep.effective_start_date = cv_lf_evt_ocrd_dt or
              pep.effective_start_date = get_cvg_strt_dt(pep.elig_per_id,pil.per_in_ler_id))
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    pil.per_in_ler_id(+) = pep.per_in_ler_id
      and    nvl(pil.business_group_id,p_business_group_id) =
             p_business_group_id
      and    nvl(pil.per_in_ler_stat_cd,'-1') not in ('VOIDD','BCKDT');
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --

    --- To make sure the person is not elibile as dpnt
    --  a dpnt elible for cobra whn prtt terminated and
    --  the same dpnt aged out and became eligble for cobra as prtt
    --- in the case the first time elibility to be validated in ben_dpnt_elig
    cursor c3 (c_pgm_id  number,
              c_pl_id   number,
              c_ler_id  number,
              c_pl_typ_id   number,
              cv_effective_date date) is
    select 'x'
     FROM   ben_elig_per_f pep,
            ben_per_in_ler pil,
            ben_elig_dpnt egd
     WHERE  egd.dpnt_person_id    = p_person_id
       and  egd.business_group_id = p_business_group_id
       and  egd.elig_per_id       = pep.elig_per_id
       and  (c_pl_id   is null or nvl(c_pl_id,-1)  = nvl(pep.pl_id,-1)   )
       and  (c_pgm_id  is null or nvl(c_pgm_id,-1) = nvl(pep.pgm_id,-1)  )
       and  (c_ler_id  is null or nvl(c_ler_id,-1) = nvl(pep.ler_id,-1) )
       and  (c_pl_typ_id is null or
            (exists
                ( select 'x'
                  from  ben_pl_f  pl
                  where  pl.pl_id     = pep.pl_id
                    and  pl.pl_typ_id = c_pl_typ_id
                    and  cv_effective_date  between
                         pl.effective_start_date
                        and pl.effective_end_date
                 )
              ) )
       and    pep.business_group_id = pep.business_group_id
       and    nvl(get_cvg_strt_dt(pep.elig_per_id,pil.per_in_ler_id),cv_effective_date) -1
              BETWEEN pep.effective_start_date AND pep.effective_end_date
              AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
       and      pil.business_group_id (+) = pep.business_group_id
       and      ( pil.per_in_ler_stat_cd NOT IN
                ( 'VOIDD', 'BCKDT')
                 OR pil.per_in_ler_stat_cd IS NULL)    ;


    -- Local variables
    --
    l_usages_created    boolean := false;
    l_created           boolean := false;
    l_dummy             varchar2(1);
    l_ass_rec           per_all_assignments_f%rowtype;
    l_f_elg_nelg        varchar2(1) ;
    --
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --

  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    -- FONM
    -- Based on fonm mode reset the date.
    --
     open c_get_per_in_ler(p_lf_evt_ocrd_dt);
     fetch c_get_per_in_ler into l_per_in_ler_id;
     close c_get_per_in_ler;
      hr_utility.set_location('Coomu per_in_ler_id : '||l_per_in_ler_id,10);
      hr_utility.set_location('Coomu le occrd dt : '||p_lf_evt_ocrd_dt,10);

    l_effective_date_1 := least(p_effective_date,nvl(p_lf_evt_ocrd_dt,p_effective_date))-1 ;
    if l_ass_rec.assignment_id is null then
      --
      -- Grab the persons benefit assignment instead
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    hr_utility.set_location(' flag ' || p_whnvr_trgrd_flag , 1999);
    hr_utility.set_location(' pl_typ_id ' || p_pl_typ_id , 1999);
    hr_utility.set_location(' p_asnd_lf_evt_dt  ' || p_asnd_lf_evt_dt , 1999);
    hr_utility.set_location(' p_lf_evt_ocrd_dt   ' || p_lf_evt_ocrd_dt  , 1999);
    hr_utility.set_location(' p_effective_date   ' || p_effective_date  , 1999);
    hr_utility.set_location(' p_eligible_flag  ' ||  p_eligible_flag , 1999);
    hr_utility.set_location(' p_person_id  ' ||  p_person_id , 1999);
    hr_utility.set_location(' p_assignment_id   ' ||  p_assignment_id , 1999);
    hr_utility.set_location(' p_per_cm_id   ' ||  p_per_cm_id , 1999);
    hr_utility.set_location(' p_actn_typ_id    ' ||  p_actn_typ_id , 1999);
    hr_utility.set_location(' p_cm_typ_id   ' ||  p_cm_typ_id , 1999);
    hr_utility.set_location(' comm_start_date'||ben_generate_communications.g_comm_start_date , 1999);
    hr_utility.set_location(' p_ler_id   ' ||  p_ler_id , 1999);
    hr_utility.set_location(' p_pgm_id   ' ||  p_pgm_id , 1999);
    hr_utility.set_location(' p_pl_id   ' ||  p_pl_id , 1999);

    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      -- We must determine a if a usage exists
      --
      -- Reset the based on fonm mode.
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      hr_utility.set_location('Coomu l_effective_date : '||l_effective_date,10);
      open c1(l_effective_date , l_effective_date_1);
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
	  hr_utility.set_location('Coomu cvg_date : '||l_c1.cvg_dt,10);
	  hr_utility.set_location('Coomu cvg_date : '||l_c1.per_in_ler_id,10);
	  hr_utility.set_location('Coomu cvg_date : '||l_c1.elig_per_id,10);
	  hr_utility.set_location('Coomu cvg_date : '||l_c1.ler_id,10);
	  hr_utility.set_location('Coomu cvg_date : '||l_c1.pl_typ_id,10);
           -- make sure he is eligible /noneligible as dpnt for the same object
           -- # 2754970
           l_f_elg_nelg := 'Y';

           open  c3 (l_c1.pgm_id ,
                     l_c1.pl_id  ,
                     l_c1.ler_id ,
                     l_c1.pl_typ_id,
                     l_effective_date);

           fetch c3 into l_dummy ;
           if c3%found  then
              if  p_eligible_flag = 'Y'  then
                  l_f_elg_nelg := 'N' ;
                  hr_utility.set_location('l_f_elg_nelg = ' || l_f_elg_nelg , 5676);
              end if  ;
           end if  ;
           close c3 ;
           ----
           hr_utility.set_location('l_f_elg_nelg = ' || l_f_elg_nelg , 5678);

           if l_f_elg_nelg = 'Y' then

              hr_utility.set_location('p_pgm_id = ' || p_pgm_id || '  ler_id  = ' || p_ler_id, 5678);
              hr_utility.set_location('p_pgm_id = ' || l_c1.pgm_id || '  pl_id = ' || l_c1.pl_id, 5678);
             if rule_passes
                (p_rule_id               => l_c1.cm_usg_rl,
                 p_person_id             => p_person_id,
                 p_assignment_id         => p_assignment_id,
                p_business_group_id     => p_business_group_id,
                p_organization_id       => p_organization_id,
                p_communication_type_id => p_cm_typ_id,
                p_ler_id            => p_ler_id,
                p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
                p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
                p_pl_typ_id             => p_pl_typ_id,
                    p_per_cm_id             => p_per_cm_id,
                 p_effective_date        => l_effective_date) then
               --
               -- create usage
               --
               pop_ben_per_cm_usg_f
                 (p_per_cm_id            => p_per_cm_id,
                  p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
                  p_business_group_id    => p_business_group_id,
                  p_effective_date       => p_effective_date,
                  p_per_cm_usg_id        => l_per_cm_usg_id,
                     p_usage_created        => l_usages_created);
               --
               if l_usages_created then
                 --
                    -- Set boolean so we know that we created at least one usage
                 --
                 l_created := true;
                 --
               end if;
               --
             end if;
          end if ;
             --
       end loop;
           --
       close c1;
         --
    elsif p_whnvr_trgrd_flag = 'Y' then
      --
      -- We just need to check whether an eligible record exists as of todays
      -- date.
      --
      open c2(l_effective_date, p_lf_evt_ocrd_dt);
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_first_time_elig_inelig;
  --
  procedure check_automatic_enrollment
      (p_person_id         in number,
       p_per_in_ler_id     in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       -- PB : 5422 :
       -- p_enrt_perd_id      in number,
       p_asnd_lf_evt_dt    in date,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_automatic_enrollment';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen
      where  ctu.business_group_id   = p_business_group_id
             /* First join comp objects */
      and    pen.business_group_id   = ctu.business_group_id
      and    pen.person_id = p_person_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
             /* Final test make sure created in the same run
                Checking using per_in_ler_id and conc_request_id */
      and    pen.request_id = fnd_global.conc_request_id
      and    pen.enrt_mthd_cd = 'A'
      and    pen.prtt_enrt_rslt_stat_cd is null;
    --
    cursor c2 is
      select null
      from   ben_prtt_enrt_rslt_f pen
      where  pen.business_group_id   = p_business_group_id
      and    pen.person_id = p_person_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Final test make sure created in the same run
                Checking using per_in_ler_id and conc_request_id */
      and    pen.request_id = fnd_global.conc_request_id
      and    pen.enrt_mthd_cd = 'A'
      and    pen.prtt_enrt_rslt_stat_cd is null;
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
              p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
              p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_automatic_enrollment;
  --
  procedure check_electable_choice_popl
    (p_per_in_ler_id     in     number
    ,p_person_id         in     number
    ,p_business_group_id in     number
    ,p_assignment_id     in     number
    ,p_organization_id   in     number
    ,p_asnd_lf_evt_dt    in     date
    ,p_pgm_id            in     number
    ,p_pl_id             in     number
    ,p_pl_typ_id         in     number
    ,p_ler_id            in     number
    ,p_actn_typ_id       in     number
    ,p_per_cm_id         in     number
    ,p_cm_typ_id         in     number
    ,p_effective_date    in     date
    ,p_lf_evt_ocrd_dt    in     date
    ,p_whnvr_trgrd_flag  in     varchar2
    ,p_usages_created       out nocopy boolean
    )
  is
    --
    l_proc                 varchar2(80) := g_package||'check_electable_choice_popl';
    --
    l_ctu_cm_typ_usg_id_va benutils.g_number_table := benutils.g_number_table();
    l_ctu_cm_usg_rl_va     benutils.g_number_table := benutils.g_number_table();
    l_ctu_pl_id_va         benutils.g_number_table := benutils.g_number_table();
    l_ctu_pgm_id_va        benutils.g_number_table := benutils.g_number_table();
    l_ctu_pl_typ_id_va     benutils.g_number_table := benutils.g_number_table();
    --
    l_effective_date       date;
    -- bug 5465081 : re-worked the c1 sql for performance
   CURSOR c1 (
      c_pil_id           NUMBER,
      c_bgp_id           NUMBER,
      c_pl_typ_id        NUMBER,
      c_asnd_lf_evt_dt   DATE,
      c_comm_st_date     DATE,
      c_cm_typ_id        NUMBER
   )
   IS
      SELECT ctu.cm_typ_usg_id, ctu.cm_usg_rl, ctu.pl_id, ctu.pgm_id,
             ctu.pl_typ_id
        FROM ben_cm_typ_usg_f ctu, ben_per_in_ler pil
       WHERE ctu.business_group_id = c_bgp_id
         AND ctu.cm_typ_id = c_cm_typ_id
         AND ctu.all_r_any_cd = 'ALL'
         AND (   c_asnd_lf_evt_dt IS NULL
              OR ctu.enrt_perd_id IS NULL
              OR EXISTS (
                    SELECT NULL
                      FROM ben_enrt_perd enp_c
                     WHERE enp_c.enrt_perd_id = ctu.enrt_perd_id
                       AND enp_c.business_group_id = ctu.business_group_id
                       AND enp_c.asnd_lf_evt_dt = c_asnd_lf_evt_dt)
             )
         AND c_comm_st_date BETWEEN ctu.effective_start_date
                                AND ctu.effective_end_date
         AND (   c_pl_typ_id IS NULL
              OR NVL (ctu.pl_typ_id, c_pl_typ_id) = c_pl_typ_id
             )
         AND pil.per_in_ler_id = c_pil_id
         AND ctu.business_group_id = pil.business_group_id
         AND NVL (ctu.ler_id, pil.ler_id) = pil.ler_id
         AND EXISTS (
                SELECT NULL
                  FROM ben_elig_per_elctbl_chc epe
                 WHERE epe.per_in_ler_id = pil.per_in_ler_id
                   AND epe.business_group_id = pil.business_group_id
                   AND epe.elctbl_flag = 'Y'
                   AND NVL (ctu.pgm_id, NVL (epe.pgm_id, -1)) =
                                                           NVL (epe.pgm_id,
                                                                -1)
                   AND NVL (ctu.pl_id, NVL (epe.pl_id, -1)) =
                                                            NVL (epe.pl_id,
                                                                 -1)
                   AND NVL (ctu.pl_typ_id, NVL (epe.pl_typ_id, -1)) =
                                                        NVL (epe.pl_typ_id,
                                                             -1)
                   AND ROWNUM = 1);
/* bug 5465081 : re-worked the sql for performance
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_per_in_ler pil,
             ben_elig_per_elctbl_chc epe
      where  pil.per_in_ler_id     = c_pil_id
      and    pil.business_group_id = c_bgp_id
      and    ctu.business_group_id = pil.business_group_id

      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y'
      and    nvl(ctu.ler_id,pil.ler_id) = pil.ler_id
      and    nvl(ctu.pgm_id,nvl(epe.pgm_id,-1)) = nvl(epe.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(epe.pl_id,-1)) = nvl(epe.pl_id,-1)
      and    (c_pl_typ_id is null or
              nvl(ctu.pl_typ_id,c_pl_typ_id) = c_pl_typ_id)

      and    (c_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = c_asnd_lf_evt_dt
                     )
             )
      and    c_comm_st_date
        between ctu.effective_start_date and ctu.effective_end_date
      and    ctu.cm_typ_id = c_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'; */
    --
    cursor c2 is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id  = p_business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y';
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1
        (c_pil_id         => p_per_in_ler_id
        ,c_bgp_id         => p_business_group_id
        ,c_pl_typ_id      => p_pl_typ_id
        ,c_asnd_lf_evt_dt => p_asnd_lf_evt_dt
        ,c_comm_st_date   => ben_generate_communications.g_comm_start_date
        ,c_cm_typ_id      => p_cm_typ_id
        );
      fetch c1 BULK COLLECT INTO l_ctu_cm_typ_usg_id_va,
                                 l_ctu_cm_usg_rl_va,
                                 l_ctu_pl_id_va,
                                 l_ctu_pgm_id_va,
                                 l_ctu_pl_typ_id_va;
      close c1;
      --
      if l_ctu_cm_typ_usg_id_va.count > 0
      then
        --
        for ctuva in l_ctu_cm_typ_usg_id_va.first..l_ctu_cm_typ_usg_id_va.last
        loop
          --
          if rule_passes
            (p_rule_id               => l_ctu_cm_usg_rl_va(ctuva)
            ,p_person_id             => p_person_id
            ,p_assignment_id         => p_assignment_id
            ,p_business_group_id     => p_business_group_id
            ,p_organization_id       => p_organization_id
            ,p_communication_type_id => p_cm_typ_id
            ,p_ler_id                => p_ler_id
            ,p_pgm_id                => nvl(p_pgm_id, l_ctu_pgm_id_va(ctuva))
            ,p_pl_id                 => nvl(p_pl_id, l_ctu_pl_id_va(ctuva))
            ,p_pl_typ_id             => p_pl_typ_id
            ,p_per_cm_id             => p_per_cm_id
            ,p_effective_date        => l_effective_date
            )
          then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id         => p_per_cm_id
              ,p_cm_typ_usg_id     => l_ctu_cm_typ_usg_id_va(ctuva)
              ,p_business_group_id => p_business_group_id
              ,p_effective_date    => p_effective_date
              ,p_per_cm_usg_id     => l_per_cm_usg_id
              ,p_usage_created     => l_usages_created
              );
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
/*
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
              p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
*/
      --
    else
      --
      -- We just need to check whether an eligible record exists as of todays
      -- date.
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_electable_choice_popl;
  --
  procedure check_no_impact_on_benefits
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id        in number,
       p_pl_id             in number,
       p_pl_typ_id     in number,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_no_impact_on_benefits';
    l_effective_date date;
    --
    -- This check only really needs the ler_id as context
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.ler_id = p_ler_id
      and    ctu.pgm_id is null
      and    ctu.pl_id is null
      and    ctu.pl_typ_id is null
      and    ctu.enrt_perd_id is null
      and    ctu.actn_typ_id is null
      and    not exists (select null
                         from   ben_elig_per_elctbl_chc epe
                         where  epe.business_group_id = p_business_group_id
                         and    epe.elctbl_flag = 'Y'
                         and    epe.per_in_ler_id = p_per_in_ler_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
             /* This process code can only apply to ALL since one context only
                can be set, we code for both though just in case */
      and    ctu.all_r_any_cd in ('ALL','ANY');
    --
    cursor c2 is
      select null
      from   sys.dual
      where  not exists (select null
                         from   ben_elig_per_elctbl_chc epe
                         where  epe.business_group_id = p_business_group_id
                         and    epe.elctbl_flag = 'Y'
                         and    epe.per_in_ler_id = p_per_in_ler_id);
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_no_impact_on_benefits;
  --
  procedure check_inelig_deenroll
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_ler_id            in number,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_inelig_deenroll';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
	     ben_per_in_ler pil
      where  ctu.business_group_id   = p_business_group_id
             /* First join comp objects */
      and    pen.business_group_id   = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pil.per_in_ler_id = pen.per_in_ler_id -- 5926672 new pil join
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and   ( (p_effective_date
             between pen.effective_start_date   --  5926672 or condition As Enrollment window might have shifted to future dates
             and     pen.effective_end_date)
	     or pil.LF_EVT_OCRD_DT = p_effective_date
	     or pil.STRTD_DT  = p_effective_date
	     )
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id, pen.pl_id) = pen.pl_id
      and    nvl(ctu.pl_typ_id,pen.pl_typ_id) = pen.pl_typ_id
             /* Now join in enrollment period */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    pen.prtt_enrt_rslt_stat_cd is null;
    --
    cursor c2 is
      select null
      from   ben_prtt_enrt_rslt_f pen,
             ben_per_in_ler pil
      where  pen.business_group_id   = p_business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.per_in_ler_id = pil.per_in_ler_id  -- 5926672 join to pil
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    (
             (l_effective_date
             between pen.effective_start_date  -- 5926672 chnged to pil
             and     pen.effective_end_date
	     )
	     or pil.LF_EVT_OCRD_DT = l_effective_date
	     or pil.STRTD_DT  = l_effective_date
	     )
      and    pen.prtt_enrt_rslt_stat_cd is null;
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('p_per_in_ler_id: '||p_per_in_ler_id,10);
    --
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    hr_utility.set_location('l_effective_date: '||l_effective_date,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
              p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_inelig_deenroll;
  --
  procedure check_expl_dflt_enrollment
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_enrt_mthd_cd      in varchar2,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_expl_dflt_enrollment';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id   = p_business_group_id
             /* First join comp objects */
      and    pen.business_group_id   = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.per_in_ler_id = pel.per_in_ler_id
      and    pen.enrt_mthd_cd = p_enrt_mthd_cd
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    pel.business_group_id   = pen.business_group_id
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
      -- validate the incomming parameter to make sure comm triiger for right plan
      and    ( ctu.pgm_id is null or p_pgm_id is null or p_pgm_id = ctu.pgm_id )
      and    ( ctu.pl_id is null or p_pl_id is null or p_pl_id = ctu.pl_id )
      --if he pl_type_id is passed compare with pl_type_id or
      -- compare with pen.pl_type_id
      --and    (p_pl_typ_id is null or
      --        nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (  (p_pl_typ_id is null and
                 nvl(ctu.pl_typ_id,pen.pl_typ_id ) = pen.pl_typ_id)
              or (p_pl_typ_id is not null and
                 nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
              )
             /* Now join in enrollment period */
      and    ((ctu.enrt_perd_id = pel.enrt_perd_id
      and    ((nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
                 and pel.pgm_id is null)
               or nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)))
      or     (ctu.enrt_perd_id is null))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.prtt_enrt_rslt_stat_cd is null;
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    cursor c2 is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id  = p_business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);

    hr_utility.set_location('befo loop pl type_id ' || p_pl_typ_id,77);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          hr_utility.set_location('befo loop pl type_id ' || l_c1.pl_id,77);
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
              p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      -- we need to check if the person is eligible as of the effective_date
      --
      open c2;
      fetch c2 into l_dummy;
      --
      if c2%found then
        --
        l_created := true;
        --
      end if;
      --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_expl_dflt_enrollment;
    --
  procedure check_close_enrollment
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_close_enrollment';
    l_effective_date date;
    --
    -- Cursor fetch definition
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id   = p_business_group_id
             /* First join comp objects */
      and    pen.business_group_id   = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.per_in_ler_id = pel.per_in_ler_id
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    pel.business_group_id   = pen.business_group_id
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
      and    nvl(ctu.pl_typ_id,pen.pl_typ_id) = pen.pl_typ_id
             /* Now join in enrollment period */
      and    ((ctu.enrt_perd_id = pel.enrt_perd_id
      and    ((nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
                 and pel.pgm_id is null)
               or nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)))
      or     (ctu.enrt_perd_id is null))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.prtt_enrt_rslt_stat_cd is null;

    --
    l_c1             c1%rowtype;
    --
    cursor c2 is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id  = p_business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => l_c1.pgm_id, -- Bug 1555557
              p_pl_id                 => l_c1.pl_id,   -- Bug 1555557
          p_pl_typ_id             => null,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      -- we need to check if the person is eligible as of the effective_date
      --
      open c2;
        --
        fetch c2 into l_dummy;
        --
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_close_enrollment;
  --
  procedure check_actn_item
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_actn_typ_id       in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_actn_item';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (p_actn_typ_id is null or
              nvl(ctu.actn_typ_id,p_actn_typ_id) = p_actn_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_actn_item;
  --
  procedure check_reimbursement
      (p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_reimbursement';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('BG : '|| p_business_group_id,10);
    hr_utility.set_location('PL: '||p_pl_id,10);
    hr_utility.set_location('ler : '||p_ler_id,10);
    hr_utility.set_location('pgm: '|| p_pgm_id,10);
    hr_utility.set_location('pl_typ: '||p_pl_typ_id,10);
    hr_utility.set_location('comm date : '||ben_generate_communications.g_comm_start_date,10);
    hr_utility.set_location('comm type  : '||p_cm_typ_id,10);

    --
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
              p_business_group_id     => p_business_group_id,
              p_organization_id       => p_organization_id,
              p_communication_type_id => p_cm_typ_id,
              p_ler_id                => p_ler_id,
              p_pgm_id                => p_pgm_id,
              p_pl_id                 => p_pl_id,
              p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_reimbursement;
  --
  procedure check_dpnt_end_enrt
    (p_person_id         in number,
     p_assignment_id     in number,
     p_business_group_id in number,
     p_organization_id   in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc varchar2(80) := g_package || '.check_dpnt_end_enrt';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering : ' || l_proc, 10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      -- We have to check to see if usages exist.
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          hr_utility.set_location(' cursor got row ' , 110);
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id         => p_per_cm_id,
               p_cm_typ_usg_id     => l_c1.cm_typ_usg_id,
               p_business_group_id => p_business_group_id,
               p_effective_date    => p_effective_date,
               p_per_cm_usg_id     => l_per_cm_usg_id,
               p_usage_created     => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving : ' || l_proc, 10);
    --
  end check_dpnt_end_enrt;
  --
  procedure check_mass_mail
    (p_per_in_ler_id     in number,
     p_person_id         in number,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_organization_id   in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc varchar2(80) := g_package || '.check_mass_mail';
    l_effective_date date;
    --
    cursor c_mssmlg is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    l_mssmlg c_mssmlg%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering : ' || l_proc, 10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      -- We have to check to see if usages exist.
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c_mssmlg;
        --
        loop
          --
          fetch c_mssmlg into l_mssmlg;
          exit when c_mssmlg%notfound;
          --
          if rule_passes
             (p_rule_id               => l_mssmlg.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => null,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id         => p_per_cm_id,
               p_cm_typ_usg_id     => l_mssmlg.cm_typ_usg_id,
               p_business_group_id => p_business_group_id,
               p_effective_date    => p_effective_date,
               p_per_cm_usg_id     => l_per_cm_usg_id,
               p_usage_created     => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c_mssmlg;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving : ' || l_proc, 10);
    --
  end check_mass_mail;
  --
  procedure check_enrt_rmdr
    (p_per_in_ler_id     in number,
     p_person_id         in number,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_organization_id   in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     -- PB : 5422 :
     p_asnd_lf_evt_dt    in date,
     -- p_enrt_perd_id      in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_enrt_mthd_cd      in varchar2,
     p_lf_evt_ocrd_dt    in date,
     p_effective_date    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package || 'check_enrt_rmdr';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id   = p_business_group_id
      and    pel.business_group_id   = ctu.business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
             )
             /* Now join in enrollment period */
      and    pel.per_in_ler_id = p_per_in_ler_id
      and    nvl(ctu.enrt_perd_id,nvl(pel.enrt_perd_id,-1))
             = nvl(pel.enrt_perd_id, -1)
      and    nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
      and    nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists
                 (select null
                  from  ben_elig_per_elctbl_chc epe1
                  where epe1.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
                  and   epe1.elctbl_flag = 'Y');
    --
    cursor c2 is
       select null
       from   ben_elig_per_elctbl_chc epe
       where  epe.per_in_ler_id = p_per_in_ler_id
       and    epe.elctbl_flag = 'Y'
       and    epe.business_group_id = p_business_group_id;
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes(
              p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_enrt_rmdr;
  --
  procedure check_emrg_evt
    (p_per_in_ler_id     in number,
     p_person_id         in number,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_organization_id   in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_enrt_mthd_cd      in varchar2,
     p_lf_evt_ocrd_dt    in date,
     p_effective_date    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package || 'check_emrg_evt';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => null,
          p_pgm_id                => p_pgm_id,
          p_pl_id                 => p_pl_id,
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_emrg_evt;
  --
  procedure check_rate_change
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_assignment_id     in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_ler_id            in number,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'rate_change';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl,
             ctu.pl_id,     -- Bug 1555557
             ctu.pgm_id,
             ctu.pl_typ_id
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv
      where  ctu.business_group_id   = p_business_group_id
             /* First join comp objects */
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.elctns_made_dt = p_effective_date
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    pen.business_group_id  = prv.business_group_id
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,nvl(p_ler_id,-1)) = nvl(p_ler_id,-1)
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    prv.prtt_rt_val_stat_cd is null;
    --
    cursor c2 is
      select null
      from   ben_prtt_rt_val prv,
             ben_prtt_enrt_rslt_f pen
      where  prv.business_group_id   = p_business_group_id
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.elctns_made_dt = p_effective_date
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    pen.business_group_id  = prv.business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    prv.prtt_rt_val_stat_cd is null
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date;
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
          p_business_group_id     => p_business_group_id,
          p_organization_id       => p_organization_id,
          p_communication_type_id => p_cm_typ_id,
          p_ler_id                => p_ler_id,
              p_pgm_id                => nvl(p_pgm_id, l_c1.pgm_id), -- Bug 1555557
              p_pl_id                 => nvl(p_pl_id, l_c1.pl_id),   -- Bug 1555557
          p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      open c2;
        --
        fetch c2 into l_dummy;
        if c2%found then
          --
          l_created := true;
          --
        end if;
        --
      close c2;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_rate_change;
  --
  procedure check_hipaa_usages
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_hipaa_usages';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
             (p_rule_id               => l_c1.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
              p_business_group_id     => p_business_group_id,
              p_organization_id       => p_organization_id,
              p_communication_type_id => p_cm_typ_id,
              p_ler_id                => p_ler_id,
              p_pgm_id                => p_pgm_id,
              p_pl_id                 => p_pl_id,
              p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
            --
            -- create usage
            --
            pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_hipaa_usages;
  --
  procedure check_hipaa_ctfn
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_organization_id   in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc            varchar2(80) := g_package||'check_hipaa_ctfn';
    l_epe_exists      varchar2(30) := 'N';
    l_crntly_enrd     varchar2(30) := 'N';
    l_created         boolean      := false;
    l_usages_created  boolean      := false;
    --
    l_per_rec         per_all_people_f%rowtype;
    --
    -- bwharton bug 1619271 added 4 lines below.
    l_pl_id             number;
    l_oipl_id           number;
    l_business_group_id number;
    l_pgm_id            number;
    l_effective_date date;
    --
    -- This cursor gets all the comp. objects that were de-enrolled
    -- due/during this life event and satisfies the HIPAA conditions
    -- and regulation.
    --
    cursor c_prev_enrt is
       select distinct pen.pgm_id, pen.pl_typ_id
       from   ben_prtt_enrt_rslt_f pen,
              ben_pl_f             pln,
              ben_pl_regn_f        plrg,
              ben_regn_f           regn,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  pen.per_in_ler_id = p_per_in_ler_id
       and    pen.enrt_cvg_thru_dt <> hr_api.g_eot
       and    pen.sspndd_flag = 'N'
       and    pen.prtt_enrt_rslt_stat_cd is null
       --8818355
       --and    p_effective_date between
       --       pen.effective_start_date and pen.effective_end_date
       and    pen.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    plrg.pl_id = pln.pl_id
       and    plrg.regn_id = regn.regn_id
       and    regn.sttry_citn_name = 'HIPAA'
       and    p_effective_date between
              plrg.effective_start_date and plrg.effective_end_date
       and    p_effective_date between
              regn.effective_start_date and regn.effective_end_date
       and    pen.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);
    --
    -- This cursor checks existence of any electable choices for that
    -- plan type with a started per in ler.
    --
    cursor c_epe(v_pgm_id    in number,
                 v_pl_typ_id in number) is
       select 'Y'
       from   ben_elig_per_elctbl_chc epe,
              ben_per_in_ler          pil,
              ben_pl_f             pln,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  epe.per_in_ler_id = p_per_in_ler_id
       and    nvl(epe.pgm_id,-1) = nvl(v_pgm_id,-1)
       and    epe.pl_typ_id     = v_pl_typ_id
       and    epe.elctbl_flag   = 'Y'
       and    epe.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd = 'STRTD'
       and    epe.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    epe.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);
    --
    -- The cursor checks whether the participant is stil covered in the
    -- plan type.
    --
    cursor c_crntly_enrd(v_pgm_id    in number,
                         v_pl_typ_id in number) is
       select 'Y'
       from   ben_prtt_enrt_rslt_f pen,
              ben_pl_f             pln,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  pen.person_id        = p_person_id
    -- and    nvl(pen.pgm_id,-1)   = nvl(v_pgm_id,-1)  maagrawa (02/11/00)
       and    pen.pl_typ_id        = v_pl_typ_id
       and    pen.enrt_cvg_thru_dt = hr_api.g_eot
       --8818355
       and    pen.effective_end_date = hr_api.g_eot
       and    pen.sspndd_flag = 'N'
       and    pen.prtt_enrt_rslt_stat_cd is null
       --8818355
       --and    p_effective_date between
       --       pen.effective_start_date and pen.effective_end_date
       and    pen.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    pen.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);
    --
    -- bwharton bug 1619271 added cursor below.
    cursor c_revise_date (v_pgm_id number, v_pl_typ_id number,
         v_per_in_ler_id number, v_ler_id number) is
       select pgm_id, pl_id, oipl_id, business_group_id
       from   ben_prtt_enrt_rslt_f
       where  pl_typ_id = v_pl_typ_id
       and    pgm_id = v_pgm_id
       and    per_in_ler_id = v_per_in_ler_id
       and    ler_id = v_ler_id
       order by prtt_enrt_rslt_id desc
    ;
    -- 3717297  the hipaa communication called from benmngle and close enrollment
    -- to avoid the dups
    cursor c_pcd is
      select 'x'
      from ben_per_cm_prvdd_f
      where per_cm_id = p_per_cm_id
      --
      -- Bug No: 3752029
      -- Commented out this condition since it was only allowing selecting records for which we
      -- have 'To_be_sent_code' as 'As of event date'. So to disallow duplicate HIPAA letter
      -- generation for other To_be_sent_code values, this condition is removed.
      --
       -- and to_be_sent_dt = g_to_be_sent_dt
        and p_effective_date between
            effective_start_date and effective_end_date
     ;
    l_tmp varchar2(1) ;

    --
    --HIPAA Enh
      cursor c_cm_typ_pl_typ is
      select ctu.pl_typ_id,
             ctu.cm_typ_usg_id,
	     ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
             )
      and    ctu.pl_typ_id is not null
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.pl_typ_id is not null
      and    ctu.all_r_any_cd = 'ALL';
    --HIPAA Enh
    --
  begin
    --
    -- We need to generate prtt. HIPAA comm. when a person de-enrolls
    -- from a plan which has HIPAA regulation attached. The communication
    -- needs to be generated only if he de-enrolls from all plans within
    -- the plan type (within that program).
    -- First we check for all the comp. objects which are getting de-enrolled.
    -- Then we check for whether the prtt. is currently enrolled in that
    -- plan type. If not, check for any enrollment opportunity available
    -- to enroll in that plan type. If there are no enrollment opportunity,
    -- then generate the neccessary HIPAA comm.
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_per_rec);
    --
    -- If the person is dead, no comm. for the prtt.
    --
     hr_utility.set_location('per_in_ler_id  '||p_per_in_ler_id,20);
    if l_per_rec.date_of_death is not null then
      --
      p_usages_created := false;
      return;
      --
    end if;
     -- 3717297  the hipaa communication generated  from benmngle , before close enrollment extract is executed
     -- which updates the send date. then  the close enrollment  create the same instance of the commu one more time
     -- fixed by validating whether same comm exists for the same pil id  for the same to be send dt

    open c_pcd ;
    fetch c_pcd into l_tmp ;
    if c_pcd%found then
      close c_pcd ;
       p_usages_created := false;
       hr_utility.set_location('communication exist for the same id  '||l_proc,20);
       hr_utility.set_location(' same id  '||p_per_cm_id,20);
       hr_utility.set_location(' same dt  '||g_to_be_sent_dt,20);
       return;
    end if ;
    close c_pcd ;

    --
     hr_utility.set_location('Before loop '||l_proc,20);
     l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    for l_prev_enrt in c_prev_enrt loop
      --
        hr_utility.set_location('In loop: '||l_proc,30);
      --
      l_epe_exists  := 'N';
      l_crntly_enrd := 'N';
      --
      open  c_crntly_enrd(l_prev_enrt.pgm_id, l_prev_enrt.pl_typ_id);
      fetch c_crntly_enrd into l_crntly_enrd;
      close c_crntly_enrd;
      --
      --HIPAA Enh
      if l_crntly_enrd = 'N' then
	for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
          if rule_passes
             (p_rule_id               => l_cm_typ_pl_typ.cm_usg_rl,
              p_person_id             => p_person_id,
              p_assignment_id         => p_assignment_id,
              p_business_group_id     => p_business_group_id,
              p_organization_id       => p_organization_id,
              p_communication_type_id => p_cm_typ_id,
              p_ler_id                => p_ler_id,
              p_pgm_id                => p_pgm_id,
              p_pl_id                 => p_pl_id,
              p_pl_typ_id             => p_pl_typ_id,
              p_per_cm_id             => p_per_cm_id,
              p_effective_date        => l_effective_date) then
	         open  c_crntly_enrd(l_prev_enrt.pgm_id, l_cm_typ_pl_typ.pl_typ_id);
	         fetch c_crntly_enrd into l_crntly_enrd;
	         close c_crntly_enrd;
           end if;
         exit when l_crntly_enrd = 'Y';
	end loop;
      end if;
      --HIPAA Enh
      --
      if l_crntly_enrd = 'N' then
        --
        hr_utility.set_location('No Result: '||l_proc,40);
        --
        open  c_epe(l_prev_enrt.pgm_id, l_prev_enrt.pl_typ_id);
        fetch c_epe into l_epe_exists;
        close c_epe;
        --

	--HIPAA Enh
	if l_epe_exists = 'N' then
	   for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
             if rule_passes
               (p_rule_id               => l_cm_typ_pl_typ.cm_usg_rl,
                p_person_id             => p_person_id,
                p_assignment_id         => p_assignment_id,
                p_business_group_id     => p_business_group_id,
                p_organization_id       => p_organization_id,
                p_communication_type_id => p_cm_typ_id,
                p_ler_id                => p_ler_id,
                p_pgm_id                => p_pgm_id,
                p_pl_id                 => p_pl_id,
                p_pl_typ_id             => p_pl_typ_id,
                p_per_cm_id             => p_per_cm_id,
                p_effective_date        => l_effective_date) then
		  open  c_epe(l_prev_enrt.pgm_id, l_cm_typ_pl_typ.pl_typ_id);
       	          fetch c_epe into l_epe_exists;
		  close c_epe;
             end if;
	     exit when l_epe_exists = 'Y';
           end loop;
	end if;
	--HIPAA Enh

	--
        if l_epe_exists = 'N' then
          --
          --  hr_utility.set_location('No Choice : '||l_proc,50);
          --
          --  bwharton bug 1619271.
      --  When the to be sent date is null due to pl_id / oipl_id
      --  not available at the earlier call to determine date, try
      --  again as the pl_id / oipl_id can now be ascertained.
      --  the cursor is ordered by a descending prtt_enrt_rslt_id.
      --
      if g_to_be_sent_dt is null then
         for c_revise_date_rec in c_revise_date
         (
        l_prev_enrt.pgm_id,
        l_prev_enrt.pl_typ_id,
        p_per_in_ler_id,
        p_ler_id
         ) loop
                l_pgm_id := c_revise_date_rec.pgm_id;
                l_pl_id := c_revise_date_rec.pl_id;
                l_oipl_id := c_revise_date_rec.oipl_id;
                l_business_group_id := c_revise_date_rec.business_group_id;
         end loop;
             ben_determine_date.main
               (p_date_cd           => g_p_date_cd,
                p_per_in_ler_id     => p_per_in_ler_id,
                p_person_id         => g_p_person_id,
                p_pgm_id            => l_pgm_id,
                p_pl_id             => l_pl_id,
                p_oipl_id           => l_oipl_id,
                p_business_group_id => l_business_group_id,
                p_formula_id        => g_p_formula_id,
                p_effective_date    => g_p_effective_date,
                p_lf_evt_ocrd_dt    => g_p_lf_evt_ocrd_dt,
                p_returned_date     => g_to_be_sent_dt);
                hr_utility.set_location('BCW: revised g_to_be_sent_dt date : '
                                        ||g_to_be_sent_dt,1469);
      end if;
          --
          -- bwharton bug 1619271 end of changes above.
          check_hipaa_usages
            (p_per_in_ler_id     => p_per_in_ler_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_assignment_id     => p_assignment_id,
             p_organization_id   => p_organization_id,
             p_pgm_id            => l_prev_enrt.pgm_id,
             p_pl_id             => p_pl_id,
             p_pl_typ_id         => l_prev_enrt.pl_typ_id,
             p_ler_id            => p_ler_id,
             -- PB : 5422 :
             p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
             -- p_enrt_perd_id      => p_enrt_perd_id,
             p_per_cm_id         => p_per_cm_id,
             p_cm_typ_id         => p_cm_typ_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
             p_usages_created    => l_created);
          --
          if l_created then
            --
            l_usages_created := true;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
    p_usages_created := l_usages_created;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end check_hipaa_ctfn;
  --
  function usages_exist(p_proc_cd           in varchar2,
                        p_person_id         in number,
                        p_per_in_ler_id     in number,
                        p_organization_id   in number,
                        p_assignment_id     in number,
                        -- PB : 5422 :
                        p_asnd_lf_evt_dt    in date,
                        -- p_enrt_perd_id      in number,
                        p_actn_typ_id       in number,
                        p_ler_id            in number,
                        p_enrt_mthd_cd      in varchar2,
                        p_pgm_id            in number,
                        p_pl_id             in number,
                        p_pl_typ_id         in number,
                        p_per_cm_id         in number,
                        p_cm_typ_id         in number,
                        p_business_group_id in number,
                        p_effective_date    in date,
                        p_lf_evt_ocrd_dt    in date,
                        p_whnvr_trgrd_flag  in varchar2) return boolean is
    --
    l_proc           varchar2(80) := g_package||'usages_exist';
    --
    -- Output variable
    --
    l_usages_created boolean := false;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    hr_utility.set_location(' program ' || p_pgm_id , 1999);
    hr_utility.set_location(' ler_id  ' || p_ler_id  , 1999);
    hr_utility.set_location(' proc_cd  '|| p_proc_cd  , 1999);

    -- The whenever triggered flag is only relevant to BENMNGLE calls due to
    -- the fact that we need to know what action took place and to make sure
    -- that an action took place.
    --
    -- Evaluate proc cd and then call relevant procedure to check usage
    --
    if p_proc_cd = 'MLEELIG' then
      --
      -- Do eligible case
      --
      check_first_time_elig_inelig
        (p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_eligible_flag     => 'Y',
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLEINELIG' then
      --
      -- Do ineligible case
      --
      check_first_time_elig_inelig
        (p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_eligible_flag     => 'N',
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLEAUTOENRT' then
      --
      check_automatic_enrollment
        (p_person_id         => p_person_id,
         p_per_in_ler_id     => p_per_in_ler_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => p_organization_id,
         p_assignment_id     => p_assignment_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLEPECP' then
      --
      check_electable_choice_popl
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLENOIMP' then
      --
      check_no_impact_on_benefits
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLEENDENRT' then
      --
      check_inelig_deenroll
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MLERTCHG' then
      --
      check_rate_change
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd in ('FORMENRT','WEBENRT','IVRENRT','DFLTENRT') then
      --
      check_expl_dflt_enrollment
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_enrt_mthd_cd      => p_enrt_mthd_cd,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'CLSENRT' then
      --
      check_close_enrollment
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_ler_id            => p_ler_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
     --
    elsif p_proc_cd in ('ACTNCMPL', 'ACTNCREATED', 'MSSMLGAR') then
      --
      check_actn_item
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_actn_typ_id       => p_actn_typ_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MSSMLG' then
      --
      check_mass_mail
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'DPNTENDENRT' then
      --
      check_dpnt_end_enrt
        (p_person_id         => p_person_id,
         p_assignment_id     => p_assignment_id,
         p_business_group_id => p_business_group_id,
         p_organization_id   => p_organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MSSMLGER' then
      --
      check_enrt_rmdr
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_ler_id            => p_ler_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_enrt_mthd_cd      => p_enrt_mthd_cd,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_effective_date    => p_effective_date,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'MSSMLGEE' then
      --
      check_emrg_evt
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_pl_id             => p_pl_id,
         p_pgm_id            => p_pgm_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_enrt_mthd_cd      => p_enrt_mthd_cd,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_effective_date    => p_effective_date,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd = 'HPAPRTTDE' then
      --
      check_hipaa_ctfn
        (p_per_in_ler_id     => p_per_in_ler_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         -- PB : 5422 :
         p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
         -- p_enrt_perd_id      => p_enrt_perd_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    elsif p_proc_cd in
       ('RMBPYMT', 'RMBRQST', 'RMBPRPY', 'RMBDND','RMBAPRVD' , 'RMBPNDG' , 'RMBNAPEL' , 'RMBVOID','RMBDPLCT')
          then
      --
      check_reimbursement
        (p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_per_cm_id         => p_per_cm_id,
         p_cm_typ_id         => p_cm_typ_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
         p_usages_created    => l_usages_created);
      --
    else
      --
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('CODE1',p_proc_cd);
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    return l_usages_created;
    --
  end usages_exist;
  --
  procedure main(p_person_id             in number,
                 p_cm_trgr_typ_cd        in varchar2 default null,
                 p_cm_typ_id             in number   default null,
                 p_ler_id                in number   default null,
                 p_per_in_ler_id         in number   default null,
                 p_prtt_enrt_actn_id     in number   default null,
                 p_bnf_person_id         in number   default null,
                 p_dpnt_person_id        in number   default null,
                 -- PB : 5422 :
                 p_asnd_lf_evt_dt        in date     default null,
                 -- p_enrt_perd_id          in number   default null,
                 p_actn_typ_id           in number   default null,
                 p_enrt_mthd_cd          in varchar2 default null,
                 p_pgm_id                in number   default null,
                 p_pl_id                 in number   default null,
                 p_pl_typ_id             in number   default null,
                 p_rqstbl_untl_dt        in date     default null,
                 p_business_group_id     in number,
                 p_proc_cd1              in varchar2 default null,
                 p_proc_cd2              in varchar2 default null,
                 p_proc_cd3              in varchar2 default null,
                 p_proc_cd4              in varchar2 default null,
                 p_proc_cd5              in varchar2 default null,
                 p_proc_cd6              in varchar2 default null,
                 p_proc_cd7              in varchar2 default null,
                 p_proc_cd8              in varchar2 default null,
                 p_proc_cd9              in varchar2 default null,
                 p_proc_cd10             in varchar2 default null,
                 p_effective_date        in date,
                 p_lf_evt_ocrd_dt        in date     default null,
                 p_mode                  in varchar2 default 'I',
                 p_source                in varchar2 default null) is
    --
    l_proc      varchar2(80) := g_package||'main';
    --
    l_ass_rec        per_all_assignments_f%rowtype;
    l_pl_rec         ben_pl_f%rowtype;
    l_pil_rec        ben_per_in_ler%rowtype;
    l_loc_rec        hr_locations_all%rowtype;
    l_effective_date date;
    --
    cursor c_triggers(p_eff_date date) is
      select ctr.cm_trgr_src_cd,
             ctr.cm_trgr_typ_cd,
             ctr.cm_trgr_id,
             ctt.cm_typ_trgr_rl,
             cct.whnvr_trgrd_flag,
             cmt.cm_dlvry_mthd_typ_cd,
             cmd.cm_dlvry_med_typ_cd,
             cct.inspn_rqd_flag,
             cct.cm_typ_id,
             cct.to_be_sent_dt_cd,
             cct.to_be_sent_dt_rl,
             cct.cm_typ_rl,
             cct.inspn_rqd_rl,
             ctr.proc_cd,
             cct.rcpent_cd,
             cct.name
      from   ben_cm_trgr ctr,
             ben_cm_typ_trgr_f ctt,
             ben_cm_typ_f cct,
             ben_cm_dlvry_mthd_typ cmt,
             ben_cm_dlvry_med_typ cmd
             /* if p_cm_trgr_typ_cd is specified pick only those rows */
      where  ctr.cm_trgr_typ_cd = nvl(p_cm_trgr_typ_cd, ctr.cm_trgr_typ_cd)
      and    ctt.cm_trgr_id = ctr.cm_trgr_id
      and    ctt.business_group_id   = p_business_group_id
      and    p_eff_date
             between ctt.effective_start_date
             and     ctt.effective_end_date
             /* if p_cm_typ_id is specified, pick only those rows */
      and    cct.cm_typ_id = nvl(p_cm_typ_id, cct.cm_typ_id)
      and    cct.cm_typ_id = ctt.cm_typ_id
      and    p_eff_date
             between cct.effective_start_date
             and     cct.effective_end_date
      and    cct.cm_typ_id = cmt.cm_typ_id(+)
      and    nvl(cmt.dflt_flag,'Y') = 'Y'
      and    cmt.cm_dlvry_mthd_typ_id = cmd.cm_dlvry_mthd_typ_id(+)
      and    nvl(cmd.dflt_flag,'Y') = 'Y'
      and    ctr.proc_cd in (p_proc_cd1,
                             p_proc_cd2,
                             p_proc_cd3,
                             p_proc_cd4,
                             p_proc_cd5,
                             p_proc_cd6,
                             p_proc_cd7,
                             p_proc_cd8,
                             p_proc_cd9,
                             p_proc_cd10);
    --
    -- Cursor fetch definition
    --
    l_triggers        c_triggers%rowtype;
    --
    cursor c_pil (p_per_in_ler_id number ) is
    select pil.lf_evt_ocrd_dt,
           ler.typ_cd
    from ben_per_in_ler  pil ,
         ben_ler_f       ler
    where pil.per_in_ler_id  = p_per_in_ler_id
      and ler.ler_id         = pil.ler_id
      and p_effective_date between
          ler.effective_start_date and ler.effective_end_date ;
    --
-- Bug 6468678
    --
    CURSOR c_get_pil IS
     --
	SELECT   pil.*
	FROM	 ben_per_in_ler pil, ben_ler_f ler
	WHERE	 pil.person_id = p_person_id
	AND	 pil.per_in_ler_stat_cd = 'STRTD'
	AND	 ler.ler_id =  pil.ler_id
	AND	 ler.ler_id = NVL (p_ler_id, pil.ler_id)
	AND      ler.typ_cd not in ('COMP', 'GSP', 'ABS')
        AND	  p_effective_date BETWEEN
			ler.effective_start_date AND ler.effective_end_date
	ORDER BY DECODE(ler.typ_cd,'SCHEDDU',1,2) desc ;
    --
    l_get_pil c_get_pil%ROWTYPE;
    --
-- Bug 6468678
    -- Local variables
    --
    l_to_be_sent_dt   date;
    l_pl_typ_id       number := null;
    l_per_in_ler_id   number := null;
    l_rqstbl_untl_dt  date   := null;
    --
    -- Out variables from procedure calls
    --
    l_per_cm_id       number;
    l_per_cm_prvdd_id number;
    --
    l_lf_evt_ocrd_dt  date ;
    --  3296015
    l_pil_lf_evt_ocrd_dt  date ;
    l_pil_typ_cd          ben_ler_f.typ_cd%type ;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location(' proc cd 1' || p_proc_cd1,77);
    hr_utility.set_location(' proc cd 2' || p_proc_cd2,77);
    hr_utility.set_location(' proc cd 3' || p_proc_cd3,77);
   --
    l_effective_date := nvl(l_lf_evt_ocrd_dt,p_effective_date);
    --
    -- CWB Changes.
    --
    if p_per_in_ler_id is null  then
        --
-- Bug 64686780
/*       ben_person_object.get_object(p_person_id => p_person_id,
                                    p_rec       => l_pil_rec); */
       /*Bug 8873512:Added If Else condition. If 'Mass Mailing',per_in_ler_id will be null.
         Do not get the per_in_ler_id*/
       if(nvl(p_proc_cd1,'MSSMLGAR') <> 'MSSMLG') then
	    open c_get_pil;
	    fetch c_get_pil into l_get_pil;
	    close c_get_pil;
       end if;
       --
-- Bug 6468678
    end if;
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --

-- Bug 6468678
--    l_per_in_ler_id := nvl(p_per_in_ler_id, l_pil_rec.per_in_ler_id);
      l_per_in_ler_id := nvl(p_per_in_ler_id, l_get_pil.per_in_ler_id);
-- Bug 6468678

     --- incase lf_evt_ocrd_dt is null, get it from pil
    l_lf_evt_ocrd_dt := p_lf_evt_ocrd_dt ;

    --- 3296015 whne the maintenacne process executed , the current opne  le is a
    --- picked for the communication , that may be age old so the fix
    --- getting the effective date if the ler type is unrestricred and ler is is null

    if p_lf_evt_ocrd_dt is null and l_per_in_ler_id is not null  then
       hr_utility.set_location('pil befo : '||l_lf_evt_ocrd_dt,10);
       open c_pil (l_per_in_ler_id) ;
       fetch c_pil into l_pil_lf_evt_ocrd_dt, l_pil_typ_cd ;
       close c_pil ;


      l_lf_evt_ocrd_dt := l_pil_lf_evt_ocrd_dt ;
      hr_utility.set_location('pil aftr : '||l_lf_evt_ocrd_dt,10);


       -- when the ler_id is null it is called from some process not from any event
       -- when the ler type is unrestricred  the pil_id could be old
       -- the date validate whther pil id is old one # 3296015
       if p_ler_id is null and l_pil_typ_cd = 'SCHEDDU' and l_lf_evt_ocrd_dt <  p_effective_date  then
          l_lf_evt_ocrd_dt :=  p_effective_date ;
          hr_utility.set_location('ler  aftr : '||l_lf_evt_ocrd_dt,10);
       end if ;

    end if ;


    -- when the ler_id is null it is called from some process not from any event
    -- when the ler type is unrestricred  the pil_id could be old
    -- the date validate whther pil id is old one # 3296015
    if p_ler_id is null and l_pil_typ_cd = 'SCHEDDU' and l_lf_evt_ocrd_dt <  p_effective_date  then
        l_lf_evt_ocrd_dt :=  p_effective_date ;
        hr_utility.set_location('ler  aftr : '||l_lf_evt_ocrd_dt,10);
    end if ;

    --
    if l_ass_rec.assignment_id is null then
      --
      -- Grab the persons benefit assignment
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;

    ----
    --
    hr_utility.set_location( 'plan and type '|| p_pl_id || ' / '||p_pl_typ_id, 77 );
    if p_pl_id is not null and
       p_pl_typ_id is null then
      --
      ben_comp_object.get_object(p_pl_id => p_pl_id,
                                 p_rec   => l_pl_rec);
      --
      l_pl_typ_id := l_pl_rec.pl_typ_id;
      --
    else
      --
      l_pl_typ_id := p_pl_typ_id;
      --
    end if;
    --
    -- Steps to generate communications
    --
    -- 1. Get all communication triggers for BG that are valid as of effective
    --    date. Join to ben_cm_typ_trgr_f and ben_cm_typ (Cursor c_triggers).
    -- 2. Loop through records
    -- 3. Set Savepoint
    -- 4. If rule exists and fails then look at next record
    -- 5. If whnvr_trgrd_flag = 'Y' then do for all comp objects
    --    4a. Populate ben_cm_trgr_f
    --    4b. Populate ben_per_cm_f
    --    4b. Populate ben_per_cm_prvdd_f
    -- 6. If whnvr_trgrd_flag = 'N' then join to cm_typ_usg_f
    -- 7. If rule exists or no rule and a usage exists
    --    6a. Populate ben_per_cm_trgr_f
    --    6b. Populate ben_per_cm_usg_f
    --    6c. Populate ben_per_cm_f
    --    6d. Populate ben_per_cm_prvdd_f
    -- 8. Go to 2.
    --
    -- Step 1.
    --
    open c_triggers(l_effective_date);
      --
      loop
        --
        -- Step 2.
        --
        fetch c_triggers into l_triggers;
        exit when c_triggers%notfound;
        --
        -- Step 3.
        --
        savepoint communications_savepoint;
        --
            hr_utility.set_location('Commu type id'||l_triggers.cm_typ_id||' ' ||l_triggers.proc_cd,10);
        -- Step 4.
        --
        if rule_passes
           (p_rule_id               => l_triggers.cm_typ_trgr_rl,
            p_person_id             => p_person_id,
            p_assignment_id         => l_ass_rec.assignment_id,
        p_business_group_id     => p_business_group_id,
        p_organization_id       => l_ass_rec.organization_id,
        p_communication_type_id => l_triggers.cm_typ_id,
        p_ler_id                => p_ler_id,
        p_pgm_id                => p_pgm_id,
        p_pl_id                 => p_pl_id,
        p_pl_typ_id             => l_pl_typ_id,
            p_effective_date        => l_effective_date)
        and rule_passes
           (p_rule_id               => l_triggers.cm_typ_rl,
            p_person_id             => p_person_id,
            p_assignment_id         => l_ass_rec.assignment_id,
        p_business_group_id     => p_business_group_id,
        p_organization_id       => l_ass_rec.organization_id,
        p_communication_type_id => l_triggers.cm_typ_id,
        p_ler_id                => p_ler_id,
        p_pgm_id                => p_pgm_id,
        p_pl_id                 => p_pl_id,
        p_pl_typ_id             => l_pl_typ_id,
            p_effective_date        => l_effective_date) then
          --
          -- OK rule is fine!
          --
          if l_triggers.inspn_rqd_rl is not null then
            if rule_passes
              (p_rule_id               => l_triggers.inspn_rqd_rl,
               p_person_id             => p_person_id,
               p_assignment_id         => l_ass_rec.assignment_id,
           p_business_group_id     => p_business_group_id,
           p_organization_id       => l_ass_rec.organization_id,
           p_communication_type_id => l_triggers.cm_typ_id,
           p_ler_id                => p_ler_id,
           p_pgm_id                => p_pgm_id,
           p_pl_id                 => p_pl_id,
           p_pl_typ_id             => l_pl_typ_id,
               p_effective_date        => l_effective_date) then
              --
              l_triggers.inspn_rqd_flag := 'Y';
              --
            else
              --
              l_triggers.inspn_rqd_flag := 'N';
              --
            end if;
            --
          end if;
          --
          l_rqstbl_untl_dt := null;
          --
          if l_triggers.proc_cd in ('HPADPNTLC', 'HPAPRTTDE') then
            --
            l_rqstbl_untl_dt := nvl(p_rqstbl_untl_dt,
                                    add_months(l_effective_date,24));
            --
          end if;
          --
          -- If the receipient code is null, then generate comm for the
          -- participant. If the value is not null, then generate related
          -- person's communications and do not generate any prtt. comm.
          --
          -- Additionally, generate Participant HIPAA comm. for participants
          -- only; and generate dependent comm. for dependents.
          --
          if (l_triggers.rcpent_cd is null and
              l_triggers.proc_cd <> 'HPADPNTLC') or
             l_triggers.proc_cd = 'HPAPRTTDE' then
            --
            -- Step 5.
            --
            pop_ben_per_cm_f
              (p_person_id            => p_person_id,
               p_ler_id               => p_ler_id,
               p_per_in_ler_id        => l_per_in_ler_id,
               p_prtt_enrt_actn_id    => p_prtt_enrt_actn_id,
               p_bnf_person_id        => p_bnf_person_id,
               p_dpnt_person_id       => p_dpnt_person_id,
               p_cm_typ_id            => l_triggers.cm_typ_id,
               p_lf_evt_ocrd_dt       => l_lf_evt_ocrd_dt,
               p_rqstbl_untl_dt       => l_rqstbl_untl_dt,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_date_cd              => l_triggers.to_be_sent_dt_cd,
               p_formula_id           => l_triggers.to_be_sent_dt_rl,
               p_pgm_id               => p_pgm_id,
               p_pl_id                => p_pl_id,
               p_per_cm_id            => l_per_cm_id);
            hr_utility.set_location('Cm type id'||l_per_cm_id,10);
            --
            --
            -- We have to work out the usages and this depends on the proc_cd
            -- If we have no usages then there is no need to populate the
            -- other communication tables.
            --
            -- Step 6 and 7.
            --
            if not usages_exist
              (p_proc_cd           => l_triggers.proc_cd,
               p_person_id         => p_person_id,
               p_per_in_ler_id     => l_per_in_ler_id,
               p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_organization_id   => l_ass_rec.organization_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_enrt_mthd_cd      => p_enrt_mthd_cd,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => l_pl_typ_id,
               p_assignment_id     => l_ass_rec.assignment_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => l_triggers.cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => l_triggers.whnvr_trgrd_flag) then
              --
              -- We have to rollback the transaction
              --
              hr_utility.set_location('rolling back' ,10);
              rollback to communications_savepoint;
              --
            else
              --
              hr_utility.set_location('Cm type id'||l_per_cm_id,10);
              populate_working_tables
                (p_person_id             => p_person_id,
                 p_cm_typ_id             => l_triggers.cm_typ_id,
                 p_business_group_id     => p_business_group_id,
                 p_effective_date        => p_effective_date,
                 p_cm_trgr_id            => l_triggers.cm_trgr_id,
                 p_inspn_rqd_flag        => l_triggers.inspn_rqd_flag,
                 p_cm_dlvry_med_cd       => l_triggers.cm_dlvry_med_typ_cd,
                 p_cm_dlvry_mthd_cd      => l_triggers.cm_dlvry_mthd_typ_cd,
                 p_per_cm_id             => l_per_cm_id,
                 p_mode                  => p_mode);
              --
              fnd_message.set_name('BEN','BEN_92089_CREATED_PER_COMM');
              fnd_message.set_token('COMMUNICATION',l_triggers.name);
              if fnd_global.conc_request_id <> -1 then
                benutils.write(fnd_message.get);
                benutils.write(p_rec => g_commu_rec);
                g_comm_generated := true;
              end if;
              --
            end if;
            --
          else
            --
            -- Generate related persons/dependents comm.
            --
            hr_utility.set_location('Entering dpnt',10);
            ben_generate_dpnt_comm.main
             (p_proc_cd           => l_triggers.proc_cd,
              p_name              => l_triggers.name,
              p_rcpent_cd         => l_triggers.rcpent_cd,
              p_person_id         => p_person_id,
              p_per_in_ler_id     => l_per_in_ler_id,
              p_business_group_id => p_business_group_id,
              p_assignment_id     => l_ass_rec.assignment_id,
              p_prtt_enrt_actn_id => p_prtt_enrt_actn_id,
              -- PB : 5422 :
              p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
              -- p_enrt_perd_id      => p_enrt_perd_id,
              p_enrt_mthd_cd      => p_enrt_mthd_cd,
              p_actn_typ_id       => p_actn_typ_id,
              p_per_cm_id         => l_per_cm_id,
              p_pgm_id            => p_pgm_id,
              p_pl_id             => p_pl_id,
              p_pl_typ_id         => l_pl_typ_id,
              p_cm_typ_id         => l_triggers.cm_typ_id,
              p_cm_trgr_id        => l_triggers.cm_trgr_id,
              p_ler_id            => p_ler_id,
              p_date_cd           => l_triggers.to_be_sent_dt_cd,
              p_inspn_rqd_flag    => l_triggers.inspn_rqd_flag,
              p_formula_id        => l_triggers.to_be_sent_dt_rl,
              p_effective_date    => p_effective_date,
              p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt,
              p_rqstbl_untl_dt    => l_rqstbl_untl_dt,
              p_cm_dlvry_med_cd   => l_triggers.cm_dlvry_med_typ_cd,
              p_cm_dlvry_mthd_cd  => l_triggers.cm_dlvry_mthd_typ_cd,
              p_whnvr_trgrd_flag  => l_triggers.whnvr_trgrd_flag,
              p_source            => p_source);
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    close c_triggers;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    hr_utility.set_location('Displaying stats ',10);
  end main;
  --
end ben_generate_communications;
--

/
