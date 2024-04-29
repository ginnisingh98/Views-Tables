--------------------------------------------------------
--  DDL for Package Body BEN_MNG_PRMRY_CARE_PRVDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MNG_PRMRY_CARE_PRVDR" as
/* $Header: benmnppr.pkb 120.3 2006/10/30 13:04:57 rgajula ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_mng_prmry_care_prvdr.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< fetch_pcp_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure returns the primary care provider desgination code
--   at both PRTT and DPNT level based on p_level for a particular enrollment
--   as of effective date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--p_prtt_enrt_rslt_id
--p_effective_date
--p_level
--p_pcp_dsgn_cd

-- Post Success
--   desginatio code is passed as the out parameter p_pcp_dsgn_cd
--
procedure fetch_pcp_dsgn_cd(p_prtt_enrt_rslt_id in number,
			   p_effective_date    in date,
			   p_level in varchar2,
			   p_pcp_dsgn_cd out nocopy  varchar2) is

  l_proc                        varchar2(72) := g_package||'fetch_pcp_dsgn_cd';

cursor c_pcp is
    select 1,decode(p_level,'PRTT',cop.pcp_dsgn_cd,'DPNT',cop.pcp_dpnt_dsgn_cd)
      from ben_oipl_f cop
      where oipl_id in (select pen.oipl_id
		        from ben_prtt_enrt_rslt_f  pen
		        where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
		         and prtt_enrt_rslt_stat_cd is null)
       and p_effective_date between cop.effective_Start_date and cop.effective_end_date
       UNION
    select 2,decode(p_level,'PRTT',cop.pcp_dsgn_cd,'DPNT',cop.pcp_dpnt_dsgn_cd)
      from ben_pl_pcp cop
      where pl_id in ( select pen.pl_id
		       from ben_prtt_enrt_rslt_f  pen
		       where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
		       and prtt_enrt_rslt_stat_cd is null)
	order by 1;

l_pcp_dsgn_cd   varchar2(30) := null;
lvl_pcp_dsgn_cd number := 0;

begin

--
hr_utility.set_location('Entering:'||l_proc, 5);

hr_utility.set_location('p_prtt_enrt_rslt_id' || p_prtt_enrt_rslt_id, 198);
hr_utility.set_location('p_effective_date' || p_effective_date, 198);
hr_utility.set_location('p_level' || p_level, 198);

	open c_pcp;
	fetch c_pcp into lvl_pcp_dsgn_cd,l_pcp_dsgn_cd;

	if c_pcp%notfound then
	  l_pcp_dsgn_cd := null;
	end if;

	p_pcp_dsgn_cd := nvl(l_pcp_dsgn_cd,'N');


hr_utility.set_location('lvl_pcp_dsgn_cd' || lvl_pcp_dsgn_cd, 198);
hr_utility.set_location('p_pcp_dsgn_cd' || p_pcp_dsgn_cd, 198);

hr_utility.set_location('Leaving:'||l_proc, 5);

end fetch_pcp_dsgn_cd;


-- ----------------------------------------------------------------------------
-- |------< recycle_ppr >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure inherits primary care providers for the enrollment result
--   from the set of primary care providers previously selected for this plan
--   (in another result id) according to the set of rules.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_new_prtt_enrt_rslt_id
--   p_old_prtt_enrt_rslt_id
--   p_business_group_id
--   p_effective_date        session date
--   p_datetrack_mode
--   p_validate
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   No database changes
--
-- Access Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------------------------
Procedure recycle_ppr(p_validate                       in boolean default false,
                           p_new_prtt_enrt_rslt_id          in number,
                           p_old_prtt_enrt_rslt_id          in number,
                           p_business_group_id              in number,
                           p_effective_date                 in date,
                           p_datetrack_mode                 in varchar2
                           )     is

  l_proc                        varchar2(72) := g_package||'recycle_ppr';

  l_effective_start_date  date;
  l_effective_end_date    date;
  l_prmry_care_prvdr_id   number;
  l_object_version_number number;

  -- check that results have same plan id
  cursor chk_rslt_c is
         select r2.effective_start_date, r2.effective_end_date
         from ben_prtt_enrt_rslt_f r,
              ben_prtt_enrt_rslt_f r2
         where r.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
           and r2.prtt_enrt_rslt_id = p_new_prtt_enrt_rslt_id
           and r.pl_id = r2.pl_id
           and r.business_group_id = p_business_group_id
           and p_effective_date between r.effective_start_date
                                    and r.effective_end_date
           and r2.business_group_id = p_business_group_id
           and p_effective_date between r2.effective_start_date
                                    and r2.effective_end_date;
  l_pen_effective_start_date date;
  l_pen_effective_end_date   date;

  -- old primary care provders hooked to old result
  cursor old_ppr_c is
         select NAME,
            EXT_IDENT,
            PRMRY_CARE_PRVDR_TYP_CD,
            PRTT_ENRT_RSLT_ID,
            ELIG_CVRD_DPNT_ID,
            BUSINESS_GROUP_ID,
            PPR_ATTRIBUTE_CATEGORY,
            PPR_ATTRIBUTE1,
            PPR_ATTRIBUTE2,
            PPR_ATTRIBUTE3,
            PPR_ATTRIBUTE4,
            PPR_ATTRIBUTE5,
            PPR_ATTRIBUTE6,
            PPR_ATTRIBUTE7,
            PPR_ATTRIBUTE8,
            PPR_ATTRIBUTE9,
            PPR_ATTRIBUTE10,
            PPR_ATTRIBUTE11,
            PPR_ATTRIBUTE12,
            PPR_ATTRIBUTE13,
            PPR_ATTRIBUTE14,
            PPR_ATTRIBUTE15,
            PPR_ATTRIBUTE16,
            PPR_ATTRIBUTE17,
            PPR_ATTRIBUTE18,
            PPR_ATTRIBUTE19,
            PPR_ATTRIBUTE20,
            PPR_ATTRIBUTE21,
            PPR_ATTRIBUTE22,
            PPR_ATTRIBUTE23,
            PPR_ATTRIBUTE24,
            PPR_ATTRIBUTE25,
            PPR_ATTRIBUTE26,
            PPR_ATTRIBUTE27,
            PPR_ATTRIBUTE28,
            PPR_ATTRIBUTE29,
            PPR_ATTRIBUTE30
      from ben_prmry_care_prvdr_f pcp
      where pcp.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
        and pcp.elig_cvrd_dpnt_id is null
        and pcp.business_group_id = p_business_group_id
        and p_effective_date between pcp.effective_start_date
                                 and pcp.effective_end_date
        ;

  -- old primary care provders hooked to dependents for old result
  cursor old_dpnt_ppr_c is
         select pcp.NAME,
            pcp.EXT_IDENT,
            pcp.PRMRY_CARE_PRVDR_TYP_CD,
            pcp.PRTT_ENRT_RSLT_ID,
            pcp.ELIG_CVRD_DPNT_ID old_elig_cvrd_dpnt_id,
            pcp.BUSINESS_GROUP_ID,
            pcp.PPR_ATTRIBUTE_CATEGORY,
            pcp.PPR_ATTRIBUTE1,
            pcp.PPR_ATTRIBUTE2,
            pcp.PPR_ATTRIBUTE3,
            pcp.PPR_ATTRIBUTE4,
            pcp.PPR_ATTRIBUTE5,
            pcp.PPR_ATTRIBUTE6,
            pcp.PPR_ATTRIBUTE7,
            pcp.PPR_ATTRIBUTE8,
            pcp.PPR_ATTRIBUTE9,
            pcp.PPR_ATTRIBUTE10,
            pcp.PPR_ATTRIBUTE11,
            pcp.PPR_ATTRIBUTE12,
            pcp.PPR_ATTRIBUTE13,
            pcp.PPR_ATTRIBUTE14,
            pcp.PPR_ATTRIBUTE15,
            pcp.PPR_ATTRIBUTE16,
            pcp.PPR_ATTRIBUTE17,
            pcp.PPR_ATTRIBUTE18,
            pcp.PPR_ATTRIBUTE19,
            pcp.PPR_ATTRIBUTE20,
            pcp.PPR_ATTRIBUTE21,
            pcp.PPR_ATTRIBUTE22,
            pcp.PPR_ATTRIBUTE23,
            pcp.PPR_ATTRIBUTE24,
            pcp.PPR_ATTRIBUTE25,
            pcp.PPR_ATTRIBUTE26,
            pcp.PPR_ATTRIBUTE27,
            pcp.PPR_ATTRIBUTE28,
            pcp.PPR_ATTRIBUTE29,
            pcp.PPR_ATTRIBUTE30,
            d2.elig_cvrd_dpnt_id elig_cvrd_dpnt_id,
            d2.effective_start_date,
            d2.effective_end_date
      from ben_prtt_enrt_rslt_f r,
           ben_prtt_enrt_rslt_f r2,
           ben_elig_cvrd_dpnt_f d,
           ben_elig_cvrd_dpnt_f d2,
           ben_prmry_care_prvdr_f pcp,
           ben_per_in_ler pil,
           ben_per_in_ler pil2
      where r.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
        and r2.prtt_enrt_rslt_id = p_new_prtt_enrt_rslt_id
        and d.prtt_enrt_rslt_id = r.prtt_enrt_rslt_id
        and d2.prtt_enrt_rslt_id = r2.prtt_enrt_rslt_id
        and d.dpnt_person_id = d2.dpnt_person_id
        and d.elig_cvrd_dpnt_id = pcp.elig_cvrd_dpnt_id
        and pcp.prtt_enrt_rslt_id is null
        and r.business_group_id = p_business_group_id
	and pcp.business_group_id = p_business_group_id
        and p_effective_date between r.effective_start_date
                                 and r.effective_end_date
        and p_effective_date between r2.effective_start_date
                                 and r2.effective_end_date
        and p_effective_date between d.effective_start_date
                                 and d.effective_end_date
        and p_effective_date between d2.effective_start_date
                                 and d2.effective_end_date
        and p_effective_date between pcp.effective_start_date
                                 and pcp.effective_end_date
        and pil.per_in_ler_id=d.per_in_ler_id
        and pil.business_group_id=p_business_group_id
        and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        and pil2.per_in_ler_id=d2.per_in_ler_id
        and pil2.business_group_id=p_business_group_id
        and pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

l_new_pcp_prtt_dsgn_cd varchar2(30) := null;

l_new_pcp_dpnt_dsgn_cd varchar2(30) := null;


--
begin
--
hr_utility.set_location('Entering:'||l_proc, 5);

  -- Check that the new result has the same plan id as the old result
  open chk_rslt_c;
  fetch chk_rslt_c into
        l_pen_effective_start_date, l_pen_effective_end_date;
  if chk_rslt_c%NOTFOUND or chk_rslt_c%NOTFOUND is null then
         fnd_message.set_name('BEN', 'BEN_91657_PL_NOT_SAME');
         fnd_message.raise_error;
  end if;

 hr_utility.set_location('before old_ppr loop'||l_proc, 10);

--
--Bug 5610430

fetch_pcp_dsgn_cd(p_prtt_enrt_rslt_id => p_new_prtt_enrt_rslt_id,
			   p_effective_date =>  p_effective_date,
			   p_level  => 'PRTT',
			   p_pcp_dsgn_cd => l_new_pcp_prtt_dsgn_cd);


if l_new_pcp_prtt_dsgn_cd in ('O','R') then

 --End Bug 5610430

  FOR old_ppr in old_ppr_c LOOP

    ben_prmry_care_prvdr_api.create_prmry_care_prvdr(
                     p_validate                => p_validate
                    ,p_prmry_care_prvdr_id     => l_prmry_care_prvdr_id
                    ,p_effective_start_date    => l_effective_start_date
                    ,p_effective_end_date      => l_effective_end_date
                    ,p_name                    => old_ppr.name
                    ,p_ext_ident               => old_ppr.ext_ident
                    ,p_prmry_care_prvdr_typ_cd => old_ppr.prmry_care_prvdr_typ_cd
                    ,p_prtt_enrt_rslt_id       => p_new_prtt_enrt_rslt_id
                    ,p_elig_cvrd_dpnt_id       => null
                    ,p_business_group_id       => p_business_group_id
                    ,p_ppr_attribute_category  => old_ppr.ppr_attribute_category
                    ,p_ppr_attribute1                 => old_ppr.ppr_attribute1
                    ,p_ppr_attribute2                 => old_ppr.ppr_attribute2
                    ,p_ppr_attribute3                 => old_ppr.ppr_attribute3
                    ,p_ppr_attribute4                 => old_ppr.ppr_attribute4
                    ,p_ppr_attribute5                 => old_ppr.ppr_attribute5
                    ,p_ppr_attribute6                 => old_ppr.ppr_attribute6
                    ,p_ppr_attribute7                 => old_ppr.ppr_attribute7
                    ,p_ppr_attribute8                 => old_ppr.ppr_attribute8
                    ,p_ppr_attribute9                 => old_ppr.ppr_attribute9
                    ,p_ppr_attribute10                => old_ppr.ppr_attribute10
                    ,p_ppr_attribute11                => old_ppr.ppr_attribute11
                    ,p_ppr_attribute12                => old_ppr.ppr_attribute12
                    ,p_ppr_attribute13                => old_ppr.ppr_attribute13
                    ,p_ppr_attribute14                => old_ppr.ppr_attribute14
                    ,p_ppr_attribute15                => old_ppr.ppr_attribute15
                    ,p_ppr_attribute16                => old_ppr.ppr_attribute16
                    ,p_ppr_attribute17                => old_ppr.ppr_attribute17
                    ,p_ppr_attribute18                => old_ppr.ppr_attribute18
                    ,p_ppr_attribute19                => old_ppr.ppr_attribute19
                    ,p_ppr_attribute20                => old_ppr.ppr_attribute20
                    ,p_ppr_attribute21                => old_ppr.ppr_attribute21
                    ,p_ppr_attribute22                => old_ppr.ppr_attribute22
                    ,p_ppr_attribute23                => old_ppr.ppr_attribute23
                    ,p_ppr_attribute24                => old_ppr.ppr_attribute24
                    ,p_ppr_attribute25                => old_ppr.ppr_attribute25
                    ,p_ppr_attribute26                => old_ppr.ppr_attribute26
                    ,p_ppr_attribute27                => old_ppr.ppr_attribute27
                    ,p_ppr_attribute28                => old_ppr.ppr_attribute28
                    ,p_ppr_attribute29                => old_ppr.ppr_attribute29
                    ,p_ppr_attribute30                => old_ppr.ppr_attribute30
                    ,p_request_id                     => fnd_global.conc_request_id
                    ,p_program_application_id         => fnd_global.prog_appl_id
                    ,p_program_id                     => fnd_global.conc_program_id
                    ,p_program_update_date            => sysdate
                    ,p_object_version_number          => l_object_version_number
                    ,p_effective_date                 => p_effective_date
                    );

   END LOOP;
end if;

 hr_utility.set_location('after old_ppr loop'||l_proc, 20);

 --Bug 5610430
fetch_pcp_dsgn_cd(p_prtt_enrt_rslt_id => p_new_prtt_enrt_rslt_id,
			   p_effective_date =>  p_effective_date,
			   p_level  => 'DPNT',
			   p_pcp_dsgn_cd => l_new_pcp_dpnt_dsgn_cd);


if l_new_pcp_dpnt_dsgn_cd in ('O','R') then

 --End Bug 5610430

  FOR old_dpnt_ppr in old_dpnt_ppr_c LOOP

    ben_prmry_care_prvdr_api.create_prmry_care_prvdr(
                     p_validate                => p_validate
                    ,p_prmry_care_prvdr_id     => l_prmry_care_prvdr_id
                    ,p_effective_start_date    => l_effective_start_date
                    ,p_effective_end_date      => l_effective_end_date
                    ,p_name                    => old_dpnt_ppr.name
                    ,p_ext_ident               => old_dpnt_ppr.ext_ident
                    ,p_prmry_care_prvdr_typ_cd => old_dpnt_ppr.prmry_care_prvdr_typ_cd
                    ,p_prtt_enrt_rslt_id       => null
                    ,p_elig_cvrd_dpnt_id       => old_dpnt_ppr.elig_cvrd_dpnt_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_ppr_attribute_category  => old_dpnt_ppr.ppr_attribute_category
                    ,p_ppr_attribute1                 => old_dpnt_ppr.ppr_attribute1
                    ,p_ppr_attribute2                 => old_dpnt_ppr.ppr_attribute2
                    ,p_ppr_attribute3                 => old_dpnt_ppr.ppr_attribute3
                    ,p_ppr_attribute4                 => old_dpnt_ppr.ppr_attribute4
                    ,p_ppr_attribute5                 => old_dpnt_ppr.ppr_attribute5
                    ,p_ppr_attribute6                 => old_dpnt_ppr.ppr_attribute6
                    ,p_ppr_attribute7                 => old_dpnt_ppr.ppr_attribute7
                    ,p_ppr_attribute8                 => old_dpnt_ppr.ppr_attribute8
                    ,p_ppr_attribute9                 => old_dpnt_ppr.ppr_attribute9
                    ,p_ppr_attribute10                => old_dpnt_ppr.ppr_attribute10
                    ,p_ppr_attribute11                => old_dpnt_ppr.ppr_attribute11
                    ,p_ppr_attribute12                => old_dpnt_ppr.ppr_attribute12
                    ,p_ppr_attribute13                => old_dpnt_ppr.ppr_attribute13
                    ,p_ppr_attribute14                => old_dpnt_ppr.ppr_attribute14
                    ,p_ppr_attribute15                => old_dpnt_ppr.ppr_attribute15
                    ,p_ppr_attribute16                => old_dpnt_ppr.ppr_attribute16
                    ,p_ppr_attribute17                => old_dpnt_ppr.ppr_attribute17
                    ,p_ppr_attribute18                => old_dpnt_ppr.ppr_attribute18
                    ,p_ppr_attribute19                => old_dpnt_ppr.ppr_attribute19
                    ,p_ppr_attribute20                => old_dpnt_ppr.ppr_attribute20
                    ,p_ppr_attribute21                => old_dpnt_ppr.ppr_attribute21
                    ,p_ppr_attribute22                => old_dpnt_ppr.ppr_attribute22
                    ,p_ppr_attribute23                => old_dpnt_ppr.ppr_attribute23
                    ,p_ppr_attribute24                => old_dpnt_ppr.ppr_attribute24
                    ,p_ppr_attribute25                => old_dpnt_ppr.ppr_attribute25
                    ,p_ppr_attribute26                => old_dpnt_ppr.ppr_attribute26
                    ,p_ppr_attribute27                => old_dpnt_ppr.ppr_attribute27
                    ,p_ppr_attribute28                => old_dpnt_ppr.ppr_attribute28
                    ,p_ppr_attribute29                => old_dpnt_ppr.ppr_attribute29
                    ,p_ppr_attribute30                => old_dpnt_ppr.ppr_attribute30
                    ,p_request_id                     => fnd_global.conc_request_id
                    ,p_program_application_id         => fnd_global.prog_appl_id
                    ,p_program_id                     => fnd_global.conc_program_id
                    ,p_program_update_date            => sysdate
                    ,p_object_version_number          => l_object_version_number
                    ,p_effective_date                 => p_effective_date
                    );
END LOOP;

end if;


 --
 hr_utility.set_location('Exiting'||l_proc, 70);

End recycle_ppr;


end ben_mng_prmry_care_prvdr;

/
