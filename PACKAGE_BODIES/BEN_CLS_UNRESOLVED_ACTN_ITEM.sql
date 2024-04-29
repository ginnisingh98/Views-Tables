--------------------------------------------------------
--  DDL for Package Body BEN_CLS_UNRESOLVED_ACTN_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLS_UNRESOLVED_ACTN_ITEM" as
/* $Header: benuneai.pkb 120.1.12010000.2 2010/01/19 08:48:08 sallumwa ship $ */
--
-- Globle Type declaration
--
type g_actn_rec is record
  (prtt_enrt_actn_id    ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type
  ,cmpltd_dt            ben_prtt_enrt_actn_f.cmpltd_dt%type
  ,due_dt               ben_prtt_enrt_actn_f.due_dt%type
  ,rqd_flag             ben_prtt_enrt_actn_f.rqd_flag%type
  ,prtt_enrt_rslt_id    ben_prtt_enrt_actn_f.prtt_enrt_rslt_id%type
  ,actn_typ_id          ben_prtt_enrt_actn_f.actn_typ_id%type
  ,actn_cd              varchar2(30)
  ,effective_start_date date
  ,effective_end_date   date
  );
type g_actn_table is table of g_actn_rec index by binary_integer;
--
type g_bnf_rec is record
  (prtt_enrt_rslt_id    number(15)
  ,bnf_person_id        number(15)
  );
type g_bnf_table is table of g_bnf_rec index by binary_integer;
--
type g_cert_rec is record
  (prtt_enrt_rslt_id    number(15)
  ,actn_typ_id          number(15)
  ,enrt_ctfn_recd_dt    date
  );
type g_cert_table is table of g_cert_rec index by binary_integer;
--
type g_dpnt_rec is record
  (prtt_enrt_rslt_id    number(15)
  ,dpnt_person_id       number(15)
  ,cvg_strt_dt          date
  ,cvg_end_dt           date
  );
type g_dpnt_table is table of g_dpnt_rec index by binary_integer;
--
-- Globle variable declaration.
--
g_package              varchar2(80) := 'ben_cls_unresolved_actn_item';
g_cache_per_proc       g_cache_person_process_rec;
g_persons_procd        integer := 0;
g_persons_errored      integer := 0;
g_max_person_err       integer := 100;
g_actn_cnt             number := 0;
g_actn_tbl             g_actn_table;
g_cert_cnt             number := 0;
g_cert_tbl             g_cert_table;
g_bnf_cnt              number := 0;
g_bnf_tbl              g_bnf_table;
g_dpnt_cnt             binary_integer := 0;
g_dpnt_tbl             g_dpnt_table;
g_person_actn_cnt      number := 0;
--
-- ----------------------------------------------------------------------------
-- |---------------------< write_person_category >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure write_person_category
  (p_audit_log          in varchar2 default 'N'
  ,p_error              in Boolean  default FALSE
  ,p_business_group_id  in number
  ,P_person_id          in number
  ,p_effective_date     in date
  )
is
  --
  l_proc       varchar2(80) := g_package||'.write_person_category';
  --
  l_actn       varchar2(80);
  l_cache      ben_batch_utils.g_comp_obj_table := ben_batch_utils.g_cache_comp;
  l_cache_cnt  binary_integer := ben_batch_utils.g_cache_comp_cnt;
  l_category   varchar2(30);
  l_detail     varchar2(132);
  l_ovn        number;
  l_id         number;
  l_ovn1       varchar2(240);
  l_actn_cd    varchar2(30);
  l_chg        boolean := FALSE;
  l_del        boolean := FALSE;
--
Begin
--
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  If(p_error) then
    --
    If(p_audit_log = 'Y') then
      --
      l_category := 'ERROR_C';
      l_detail := 'Error occur while Close action item';
      --
      l_actn := 'Calling ben_batch_utils.write_rec (ERROR_C)...';
      Ben_batch_utils.write_rec(p_typ_cd => l_category
                               ,p_text   => l_detail);
      --
    End if;
    --
  Else
    --
    l_actn := 'Determine person category...';
    --
    For i in 1..g_actn_cnt loop
      --
      If(g_actn_tbl(i).actn_cd in ('C','D')) then
        l_chg := TRUE;
        exit;
      End if;
      --
    End loop;
    --
    If (not l_chg) then
      --
      l_category := 'ACTNNOACTN';
      l_detail := 'Participants processed without action';
      --
    Else
      --
      For i in 1..l_cache_cnt loop
        --
        If(l_cache(i).actn_cd = 'D') then
          l_del := TRUE;
          exit;
        End if;
        --
      End loop;
      --
      If (l_del) then
        l_category := 'ACTNENRTDEL';
        l_detail := 'Participant action closed(Enrollment deleted)';
      Else
        l_category := 'ACTNNOENRTDEL';
        l_detail := 'Participant action closed(No enrollment deleted)';
      End if;
      --
    End if;
    --
    l_actn := 'Calling ben_batch_utils.write_rec...';
    Ben_batch_utils.write_rec(p_typ_cd => l_category
                             ,p_text   => l_detail);
    --
  End if;
  --
  If (not p_error and p_audit_log = 'Y') then
    --
    For i in 1..l_cache_cnt loop
      --
      l_actn := 'Calling ben_batch_rate_info_api.create_batch_rate_info...';
      --
      ben_batch_rate_info_api.create_batch_rate_info
        (p_batch_rt_id           => l_id
        ,p_benefit_action_id     => benutils.g_benefit_action_id
        ,p_person_id             => p_person_id
        ,p_pgm_id                => l_cache(i).pgm_id
        ,p_pl_id                 => l_cache(i).pl_id
        ,p_oipl_id               => l_cache(i).oipl_id
        ,p_dflt_val              => l_cache(i).bnft_amt
        ,p_val                   => l_cache(i).prtt_enrt_rslt_id
	,p_enrt_cvg_strt_dt      => l_cache(i).cvg_strt_dt         -- Bug 4386646
        ,p_enrt_cvg_thru_dt      => l_cache(i).cvg_thru_dt        -- Bug 4386646
        ,p_actn_cd               => l_actn_cd
        ,p_dflt_flag             => 'Y'
        ,p_business_group_id     => p_business_group_id
        ,p_effective_date        => p_effective_date
        ,p_object_version_number => l_OVN
        );
      --
    End loop;
    --
    For i in 1..g_dpnt_cnt loop
      --
      l_actn := 'Calling ben_batch_dpnt_info_api.create_batch_dpnt_info...';
      --
      ben_batch_dpnt_info_api.create_batch_dpnt_info
        (p_batch_dpnt_id         => l_id
        ,p_person_id             => p_person_id
        ,p_benefit_action_id     => benutils.g_benefit_action_id
        ,p_business_group_id     => p_business_group_id
        ,p_enrt_cvg_strt_dt      => g_dpnt_tbl(i).cvg_strt_dt
        ,p_enrt_cvg_thru_dt      => g_dpnt_tbl(i).cvg_end_dt
        ,p_actn_cd               => to_char(g_dpnt_tbl(i).prtt_enrt_rslt_id)
        ,p_object_version_number => l_OVN1
        ,p_dpnt_person_id        => g_dpnt_tbl(i).dpnt_person_id
        ,p_effective_date        => p_effective_date
        );
      --
    End loop;
    --
    For i in 1..g_actn_cnt loop
      --
      l_actn := 'Calling create_batch_actn_item_info...';
      ben_batch_actn_item_info_api.create_batch_actn_item_info
        (p_batch_actn_item_id     => l_id
        ,p_benefit_action_id      => benutils.g_benefit_action_id
        ,p_person_id              => p_person_id
        ,p_actn_typ_id            => g_actn_tbl(i).actn_typ_id
        ,p_cmpltd_dt              => g_actn_tbl(i).cmpltd_dt
        ,p_due_dt                 => g_actn_tbl(i).due_dt
        ,p_rqd_flag               => g_actn_tbl(i).rqd_flag
        ,p_actn_cd                => g_actn_tbl(i).actn_cd ||
                                     to_char(g_actn_tbl(i).prtt_enrt_rslt_id)
        ,p_business_group_id      => p_business_group_id
        ,p_object_version_number  => l_ovn
        ,p_effective_date         => p_effective_date
        );
      --
    End loop;
    --
    For i in 1..g_cert_cnt loop
      --
      l_actn := 'Calling create_batch_bnft_cert_info (Certification)...';
      --
      ben_batch_bnft_cert_info_api.create_batch_bnft_cert_info
        (p_batch_benft_cert_id    => l_id
        ,p_benefit_action_id      => benutils.g_benefit_action_id
        ,p_person_id              => p_person_id
        ,p_actn_typ_id            => g_cert_tbl(i).actn_typ_id
        ,p_typ_cd                 => 'C' ||
                                     to_char(g_cert_tbl(i).prtt_enrt_rslt_id)
        ,p_enrt_ctfn_recd_dt      => g_cert_tbl(i).enrt_ctfn_recd_dt
        ,p_object_version_number  => l_ovn
        ,p_effective_date         => p_effective_date
        );
      --
    End loop;
    --
    For i in 1..g_bnf_cnt loop
      --
      l_actn := 'Calling create_batch_bnft_cert_info (Beneficiary)...';
      --
      ben_batch_bnft_cert_info_api.create_batch_bnft_cert_info
        (p_batch_benft_cert_id    => l_id
        ,p_benefit_action_id      => benutils.g_benefit_action_id
        ,p_person_id              => p_person_id
        ,p_typ_cd                 => 'B' ||
                                     to_char(g_bnf_tbl(i).prtt_enrt_rslt_id)
        ,p_actn_typ_id            => g_bnf_tbl(i).bnf_person_id
        ,p_object_version_number  => l_ovn
        ,p_effective_date         => p_effective_date
        );
      --
    End loop;
    --
  End if;
  --
  hr_utility.set_location ('Leaving '||l_proc, 10);
  --
Exception
  --
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
    raise;
  --
End write_person_category;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< submit_all_reports >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Submit_all_reports
  (p_rpt_flag    in Boolean  default FALSE
  ,p_audit_log   in varchar2 default 'N')
is
  --
  l_proc        varchar2(80) := g_package||'.submit_all_reports';
  l_actn        varchar2(80);
  l_request_id  number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  l_actn := 'Calling ben_batch_utils.batch_report (BENUAAUD)...';
  --
  If fnd_global.conc_request_id <> -1 then
    --
    If(p_audit_log = 'Y') then
      --
      ben_batch_utils.batch_report
        (p_concurrent_request_id => fnd_global.conc_request_id
        ,p_program_name          => 'BENUAAUD'
        ,p_request_id            => l_request_id);
      --
    End if;
    --
    l_actn := 'Calling ben_batch_utils.batch_report (BENUASUM)...';
    --
    ben_batch_utils.batch_report
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_program_name          => 'BENUASUM'
      ,p_request_id            => l_request_id
      );
    --
    -- Submit the generic error by error type and error by person reports.
    --
    ben_batch_reporting.batch_reports
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_report_type           => 'ERROR_BY_ERROR_TYPE');
    --
    ben_batch_reporting.batch_reports
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_report_type           => 'ERROR_BY_PERSON');
    --
  End if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
Exception
  --
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => p_rpt_flag
                             );
    raise;
End Submit_all_reports;
--
-- ----------------------------------------------------------------------------
-- |---------------------< remove_prtt_actn >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_prtt_actn
  (p_prtt_enrt_actn_id          in     number
  ,p_business_group_id          in     number
  ,p_effective_date             in     date
  ,p_datetrack_mode             in     varchar2
  ,p_object_version_number      in out nocopy number
  ,p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_unsuspend_enrt_flag        in     varchar2
  ,p_effective_start_date       in out nocopy date
  ,p_effective_end_date         in out nocopy date
  ,p_batch_flag                 in     boolean
  ,p_audit_log                  in     varchar2  default 'N'
  )
is
  --
  l_proc     varchar2(80) := g_package||'.Remove_Prtt_Actn';
  l_actn     varchar2(80);

  -- For nocopy changes
  l_object_version_number number := p_object_version_number;
  l_rslt_object_version_number number := p_object_version_number;
  l_effective_start_date  date := p_effective_start_date;
  l_effective_end_date date := p_effective_end_date;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,5);
  --
  --
  l_actn := 'Calling delete_prtt_enrt_actn(' || to_char(p_prtt_enrt_actn_id)
              || ')...' ;
  --
  ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
    (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
    ,p_business_group_id          => p_business_group_id
    ,p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_object_version_number      => p_object_version_number
    ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
    ,p_rslt_object_version_number => p_rslt_object_version_number
    ,p_unsuspend_enrt_flag        => p_unsuspend_enrt_flag
    ,p_effective_start_date       => p_effective_start_date
    ,p_effective_end_date         => p_effective_end_date
    );
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
Exception
  --
  When others then
    --
    ben_batch_utils.rpt_error(p_proc => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag => p_batch_flag
                             );
    -- For nocopy changes
	p_object_version_number := l_object_version_number;
	p_rslt_object_version_number := l_object_version_number;
	p_effective_start_date   := l_effective_start_date;
	p_effective_end_date := l_effective_end_date;

    raise;
  --
End;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ld_dpnt >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure ld_dpnt
  (p_business_group_id  in     number
  ,p_effective_date     in     date
  ,p_prtt_enrt_rslt_id  in     number)
is
  --
  cursor c1
  is
  select ecd.prtt_enrt_rslt_id,
         ecd.dpnt_person_id,
         ecd.cvg_strt_dt,
         ecd.cvg_thru_dt
    from ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where ecd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=ecd.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_proc     varchar2(80) := g_package||'.ld_dpnt';
  l_actn     varchar2(80);
--
Begin
--
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  l_actn := 'Entering ld_dpnt...';
  --
  For rec in c1 loop
    l_actn := 'Loading dpnt...';
    g_dpnt_cnt := g_dpnt_cnt + 1;
    g_dpnt_tbl(g_dpnt_cnt) := rec;
  End loop;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
Exception
  --
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
    raise;
  --
End ld_dpnt;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ld_bnf >------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ld_bnf
  (p_business_group_id  in     number
  ,p_effective_date     in     date
  ,p_prtt_enrt_rslt_id  in     number)
is
  --
  cursor c1
  is
  select bnf.prtt_enrt_rslt_id, bnf.bnf_person_id
    from ben_pl_bnf_f bnf,
         ben_per_in_ler pil
   where bnf.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and bnf.business_group_id= p_business_group_id
     and p_effective_date between bnf.effective_start_date
                              and bnf.effective_end_date
     and pil.per_in_ler_id=bnf.per_in_ler_id
     and pil.business_group_id=bnf.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_proc     varchar2(80) := g_package||'.ld_bnf';
  l_actn     varchar2(80);
  --
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  l_actn := 'Entering ld_bnf...';
  For rec in c1 loop
    l_actn := 'Loading beneficiary...';
    g_bnf_cnt := g_bnf_cnt + 1;
    g_bnf_tbl(g_bnf_cnt) := rec;
  End loop;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
    raise;
End ld_bnf;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ld_cert >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ld_cert(p_business_group_id  in     number
                 ,p_effective_date     in     date
                 ,p_prtt_enrt_rslt_id  in     number
                 ) is
  --
  Cursor c1 is
    Select a.prtt_enrt_rslt_id,
           b.actn_typ_id,
           a.enrt_ctfn_recd_dt
      from ben_prtt_enrt_ctfn_prvdd_f a
          ,ben_prtt_enrt_actn_f b
          ,ben_per_in_ler pil
     where a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and a.business_group_id= p_business_group_Id
       and p_effective_date between
             a.effective_start_date and a.effective_start_date
       and b.prtt_enrt_actn_id = a.prtt_enrt_actn_id
       and p_effective_date between
             b.effective_start_date and b.effective_start_date
       and pil.per_in_ler_id=b.per_in_ler_id
       and pil.business_group_id=b.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    ;
  --
  l_proc     varchar2(80) := g_package||'.ld_cert';
  l_actn     varchar2(80);
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  l_actn := 'Entering ld_cert...';
  For rec in c1 loop
    l_actn := 'Loading Certicication...';
    g_cert_cnt := g_cert_cnt + 1;
    g_cert_tbl(g_cert_cnt) := rec;
  End loop;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
    raise;
End ld_cert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ld_actn >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure ld_actn
  (p_business_group_id  in     number
  ,p_effective_date     in     date
  ,p_prtt_enrt_rslt_id  in     number
  ,p_before             in     Boolean
  ,p_after              in     Boolean
  ,p_idx_b              in out nocopy binary_integer
  ,p_idx_e              in out nocopy binary_integer
  )
is
  --
  cursor c1
  is
  select pea.prtt_enrt_actn_id
        ,pea.cmpltd_dt
        ,pea.due_dt
        ,pea.rqd_flag
        ,pea.prtt_enrt_rslt_id
        ,pea.actn_typ_id
        ,'N' actn_cd
        ,pea.effective_start_date
        ,pea.effective_end_date
    from ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.business_group_id = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and pil.per_in_ler_id=pea.per_in_ler_id
     and pil.business_group_id=pea.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
   order by pea.prtt_enrt_rslt_id, pea.prtt_enrt_actn_id
    ;
  l_proc     varchar2(80) := g_package||'.ld_actn';
  l_actn     varchar2(80);
  i          binary_integer := 0;
  l_fnd      boolean;
  l_idx_b  binary_integer := p_idx_b ;
  l_idx_e  binary_integer:=  p_idx_e;

Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  If(p_before) then
    --
    l_actn := 'Load actn item (Before)...';
    p_idx_b := g_actn_cnt;
    For rec1 in c1 loop
      g_actn_cnt := g_actn_cnt + 1;
      g_actn_tbl(g_actn_cnt) := rec1;
    End loop;
    p_idx_e:= g_actn_cnt;
  Elsif(p_after) then
    --
    l_actn := 'Compae actn item (After)...';
    For rec2 in c1 loop
      l_fnd := FALSE;
      For i in p_idx_b+1..p_idx_e loop
        If (rec2.prtt_enrt_actn_id = g_actn_tbl(i).prtt_enrt_actn_id) then
          If(rec2.effective_end_date = p_effective_date) then
            g_actn_tbl(i).actn_cd := 'D';
          Elsif(rec2.cmpltd_dt is not null and g_actn_tbl(i).cmpltd_dt is NULL)
          then
            g_actn_tbl(i).actn_cd := 'C';
          End if;
          l_fnd := TRUE;
          Exit;
        End if;
      End loop;
      -- * Handle actn item get Zapped.
      If (not l_fnd) then
         g_actn_tbl(i).actn_cd := 'D';
      End if;
    End loop;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
  -- for nocopy changes
  p_idx_b := l_idx_b ;
  p_idx_e :=  l_idx_e;
    raise;
End ld_actn;
--
-- ----------------------------------------------------------------------------
-- |-------------------< cls_per_unresolved_actn_item >-----------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is called to close any unresolved action items for a person.
--
procedure cls_per_unresolved_actn_item
  (p_person_id               in  number
  ,p_effective_date          in  date
  ,p_business_group_id       in  number
  ,p_overwrite_flag          in  boolean  default FALSE
  ,p_batch_flag              in  boolean  default FALSE
  ,p_validate                in  boolean  default FALSE
  ,p_person_action_id        in  Number   default NULL
  ,p_object_version_number   in  Number   default NULL
  ,p_audit_log               in  varchar2 default 'N'
  )
is
  --
  -- Local Cursor/record variables
  --
  cursor c_pen
  is
  select pen.prtt_enrt_rslt_id
        ,pen.effective_start_date
        ,pen.effective_end_date
        ,pen.business_group_id
        ,pen.person_id
        ,pen.rplcs_sspndd_rslt_id
        ,pen.sspndd_flag
        ,pen.object_version_number
        ,pen.per_in_ler_id
        ,'N' skip
    from ben_prtt_enrt_rslt_f pen
   where pen.person_id = p_person_id
     and pen.business_group_id = p_business_group_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and exists (select null
                   from ben_prtt_enrt_actn_f pea
                  where pen.prtt_enrt_rslt_id = pea.prtt_enrt_rslt_id
                    and pea.cmpltd_dt is null
                    and p_effective_date between pea.effective_start_date
                                             and pea.effective_end_date)
     and nvl(pen.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date -1
    and ( pen.effective_end_date = hr_api.g_eot  or --Bug 4398840
          not exists (select 'x' from ben_prtt_enrt_rslt_f pen1  -- to exclude the ended result
                      where pen1.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                        and pen1.effective_end_date = hr_api.g_eot
                        and pen1.enrt_cvg_thru_dt <> hr_api.g_eot
                     )
        )
    and pen.effective_end_date >= pen.enrt_cvg_strt_dt;
  --
  type g_pen_record is table of c_pen%rowtype index by binary_integer;
  --
  -- Get all open actions for the prtt_enrt_rslt_id.
  --
  cursor c_actn (c_prtt_enrt_rslt_id number)
  is
  select b.prtt_enrt_actn_id
        ,b.due_dt
        ,b.cmpltd_dt
        ,b.rqd_flag
        ,b.prtt_enrt_rslt_id
        ,b.actn_typ_id
        ,b.effective_start_date
        ,b.effective_end_date
        ,b.object_version_number
    from ben_prtt_enrt_actn_f b,
         ben_per_in_ler pil
   where b.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and b.business_group_id = p_business_group_id
     and b.cmpltd_dt is NULL
     and p_effective_date between b.effective_start_date
                              and b.effective_end_date
     and pil.per_in_ler_id=b.per_in_ler_id
     and pil.business_group_id=b.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     AND EXISTS (SELECT NULL  ------Bug 8620516
                   FROM ben_prtt_enrt_rslt_f pen
                  WHERE pen.prtt_enrt_rslt_id = b.prtt_enrt_rslt_id
                    AND pen.per_in_ler_id = pil.per_in_ler_id
                    AND pen.business_group_id = pil.business_group_id
                    AND pen.prtt_enrt_rslt_stat_cd IS NULL)
  ;
  --
  -- Get minimum due date of all open, required actions for a result
  --
  cursor c_actn_min (c_prtt_enrt_rslt_id number)
  is
  select min(nvl(b.due_dt,hr_api.g_eot)) due_dt
    from ben_prtt_enrt_actn_f b,
         ben_per_in_ler pil
   where b.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and b.business_group_id = p_business_group_id
     and b.cmpltd_dt is NULL
     and b.rqd_flag = 'Y'
     and p_effective_date between b.effective_start_date
                              and b.effective_end_date
     and pil.per_in_ler_id=b.per_in_ler_id
     and pil.business_group_id=b.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;
  --
  -- Record structures for preliminary processing.
  --
  l_enrt_rec      g_pen_record;        -- Enrollment results
  l_enrt_cnt      number := 0;
  l_intr_rec      g_pen_record;        -- Interim Enrollments.
  l_intr_cnt      number := 0;
  l_process_rec   g_pen_record;        -- Enrt results minus interim results
  l_process_cnt   number := 0;
  --
  -- Local Variables.
  --
  l_proc             Varchar2(80) := g_package||'.cls_per_unresolved_actn_item';
  --
  l_actn             Varchar2(80);
  l_actn_cd          Varchar2(30) := 'N';
  l_set              Boolean := FALSE;
  l_found            Boolean := FALSE;
  l_del_flag         Boolean := FALSE;
  l_dump_boolean     Boolean := FALSE;
  l_dump_number      number  := 0;
  l_due_dt           date;
  l_suspend_flag     varchar2(30) ;
  l_output_string    varchar2(132);
  l_idx_b            Binary_integer := 0;
  l_idx_e            Binary_integer := 0;
  l_object_version_number Number := p_object_version_number;
--
begin
--
  hr_utility.set_location ('Entering ' || l_proc, 10);
  --
  -- Issue a savepoint for validation mode.
  --
  savepoint validate_point;
  --
  If p_batch_flag then
    --
    l_actn := 'Calling Ben_batch_utils.person_header...';
    --
    ben_batch_utils.person_header
      (p_person_id           => p_person_id
      ,p_business_group_id   => p_business_group_id
      ,p_effective_date      => p_effective_date);
    --
    ben_batch_utils.ini('COMP_OBJ');
    --
    g_actn_tbl.delete;
    g_actn_cnt := 0;
    g_cert_tbl.delete;
    g_cert_cnt := 0;
    g_bnf_tbl.delete;
    g_bnf_cnt := 0;
    g_dpnt_tbl.delete;
    g_dpnt_cnt := 0;
    --
  End if;
  --
  -- There is some preliminary processing that needs to be done before closing
  -- action items.
  -- 1. Load all the person's enrollment reslults into cache-A.
  -- 2. If the enrollment result is suspended and has an interim result, then
  --    load the interim enrollment results into cache-B.
  -- 3. Load all the records from cache-A minus the ones in cache-B into
  --    cache-C. This is the set of enrollment records that will be processed.
  --
  -- Step 1. Load all the enrollment results for the person into the cache.
  --
  l_actn := 'Loading cursor into cache';
  --
  for l_rec in c_pen loop
    l_enrt_cnt := l_enrt_cnt + 1;
    l_enrt_rec(l_enrt_cnt) := l_rec;
  end loop;
  --
  hr_utility.set_location ('All enrollments  l_enrt_cnt '||l_enrt_cnt ,20);
  for i in 1..l_enrt_cnt
  loop
    --
    -- If the enrollment result is suspended and has an interim enrollment
    -- then load the interim result's id into the cache.
    --
    if l_enrt_rec(i).rplcs_sspndd_rslt_id is not null then
      hr_utility.set_location('Loading interim id into cache', 10);
      l_intr_cnt := l_intr_cnt + 1;
      l_intr_rec(l_intr_cnt).prtt_enrt_rslt_id := l_enrt_rec(i).rplcs_sspndd_rslt_id;
    end if;
    --
  end loop;
  hr_utility.set_location ('Interim l_intr_cnt '||l_intr_cnt,30);
  --
  -- Load all of the person's interim enrt-rslt records into the l_intr_rec cache.
  --
  for i in 1..l_intr_cnt loop
    --
    for j in 1..l_enrt_cnt loop
      --
      if (l_enrt_rec(j).prtt_enrt_rslt_id = l_intr_rec(i).prtt_enrt_rslt_id )
      then
        l_intr_rec(i) := l_enrt_rec(j);
        exit;
      end if;
      --
    end loop;
    --
  end loop;
  --
  -- l_process_rec is all results for the person that are not interim results
  --
  l_actn := 'Removing interim from All enrollments';
  --
  if l_intr_cnt > 0 then
    --
    l_found := false;
    --
    for i in 1..l_enrt_cnt loop
      --
      for j in 1..l_intr_cnt loop
        --
        l_found := false;  --Bug 2386000
        --hr_utility.set_location(' INTR PEN '||l_intr_rec(j).prtt_enrt_rslt_id,111);
        --hr_utility.set_location(' ENROLL PEN '||l_enrt_rec(i).prtt_enrt_rslt_id,111);
        --
        if l_intr_rec(j).prtt_enrt_rslt_id = l_enrt_rec(i).prtt_enrt_rslt_id
        then
          --
          l_found := TRUE;
          exit;
          --
        end if;
        --
      end loop;
      --
      if not l_found then
        --
        l_process_cnt := l_process_cnt + 1;
        l_process_rec(l_process_cnt) := l_enrt_rec(i);
        --
      end if;
      --
    end loop;
    --
  else
    l_process_cnt := l_enrt_cnt ;
    l_process_rec := l_enrt_rec;
  end if;
  --
  hr_utility.set_location(' All enrt minus Interim enrt l_process_cnt '||l_process_cnt, 40);
  l_actn := 'Starting Enrollment loop';
  --
  for i in 1..l_process_cnt loop
    --
    l_actn_cd := 'N';
    --
    if (p_batch_flag) then
      --
      -- g_actn_tbl is all the action items for a single result
      --
      hr_utility.set_location(' Call ld_actn First Place ',50);
      ld_actn(p_business_group_id  => p_business_group_id
             ,p_effective_date     => p_effective_date
             ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id
             ,p_before             => TRUE
             ,p_after              => FALSE
             ,p_idx_b              => l_idx_b
             ,p_idx_e              => l_idx_e);
      --
    end if;
    --
    -- Attempt to resolve actions items for this result.
    --
    hr_utility.set_location('Call determine_action_items ',60);
    ben_enrollment_action_items.determine_action_items
      (p_prtt_enrt_rslt_id          => l_process_rec(i).prtt_enrt_rslt_id
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_suspend_flag               => l_suspend_flag
      ,p_post_rslt_flag             => 'Y'
      ,p_rslt_object_version_number => l_process_rec(i).object_version_number
      ,p_dpnt_actn_warning          => l_dump_boolean
      ,p_bnf_actn_warning           => l_dump_boolean
      ,p_ctfn_actn_warning          => l_dump_boolean);
    --
    hr_utility.set_location(' l_suspend_flag '||l_suspend_flag,70);
    hr_utility.set_location(' l_process_rec(i).sspndd_flag '||l_process_rec(i).sspndd_flag , 70);
    --
    If (l_suspend_flag = 'Y' and l_process_rec(i).sspndd_flag = 'Y') then
      --
      -- The result is suspended now, and was suspended before this call...
      --
      -- Get minimum due date of all required open actn items for this result
      --
      hr_utility.set_location('Enrt Result still suspended after benactcm call.'
                             , 10);
      --
      open c_actn_min(l_process_rec(i).prtt_enrt_rslt_id);
      Fetch c_actn_min into l_due_dt;
      --
      If c_actn_min%notfound then
        close c_actn_min;
        fnd_message.set_token('BEN', 'BEN_91909_REQ_ACTN_NO_FND_ENRT');
        fnd_message.raise_error;
      End if;
      --
      Close c_actn_min;
      --
      -- If the minimum due date has past, then there is no way for the prtt to
      -- complete all the required action items for this suspended result.  Go
      -- ahead and delete the suspended result.
      --
      If p_effective_date >= l_due_dt or p_overwrite_flag = TRUE
      then
        --
        hr_utility.set_location('Due date passed or overwrite flag TRUE', 10);
        --
        If (p_audit_log = 'Y') then
          --
          -- g_bnf_tbl is all the beneficiaries for a single result
          --
          l_actn := 'Calling ld_bnf...';
          ld_bnf (p_business_group_id  => p_business_group_id
                 ,p_effective_date     => p_effective_date
                 ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id);
          --
          -- g_cert_tbl is all the certifications for a single result
          --
          l_actn := 'Calling ld_cert...';
          ld_cert(p_business_group_id  => p_business_group_id
                 ,p_effective_date     => p_effective_date
                 ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id);
          --
        End if;
        --
        l_actn := 'Calling ben_prtt_enrt_result_api.delete_enrollment...' ;
        --
        ben_prtt_enrt_result_api.delete_enrollment
          (p_prtt_enrt_rslt_id     => l_process_rec(i).prtt_enrt_rslt_id
          ,p_per_in_ler_id         => l_process_rec(i).per_in_ler_id    -- Bug 2386000
          ,p_business_group_id     => p_business_group_id
          ,p_effective_start_date  => l_process_rec(i).effective_start_date
          ,p_effective_end_date    => l_process_rec(i).effective_end_date
          ,p_object_version_number => l_process_rec(i).object_version_number
          ,p_effective_date        => p_effective_date
          ,p_datetrack_mode        => hr_api.g_delete
          ,p_multi_row_validate    => TRUE
          ,p_source                => 'benuneai');
        --
        If (p_audit_log = 'Y')then
          --
          l_actn := 'Calling ld_dpnt...';
          --
          ld_dpnt(p_business_group_id  => p_business_group_id
                 ,p_effective_date     => p_effective_date
                 ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id);
          --
        End if;
        --
      End if;
      --
    Elsif l_suspend_flag = 'N' and l_process_rec(i).sspndd_flag = 'Y'
    then
      --
      -- If the enrollment result was unsuspended as a result of the call to
      -- determine_action_items process, then its interim enrollment would have
      -- been end-dated. So set the skip flag for the interim record so that
      -- processing is skipped when it is picked up.
      --
      l_actn := 'Processing unsupended enrollment in loop E';
      --
      hr_utility.set_location('Result unsuspended after benactcm call', 10);
      --
      If (p_batch_flag) then
        --
        ben_batch_utils.write(p_text => '>     Enrollment ( ' ||
                              to_char(l_process_rec(i).prtt_enrt_rslt_id) ||
                              ') unsuspended ');
        --
      End if;
      --
      l_actn_cd := 'U';
      --
      For j in 1..l_intr_cnt loop
        --
        If l_intr_rec(j).prtt_enrt_rslt_id=l_process_rec(i).prtt_enrt_rslt_id
        then
          --
          hr_utility.set_location('Will not process interim id ' ||
                                  l_intr_rec(j).prtt_enrt_rslt_id, 10);
          --
          l_intr_rec(j).skip := 'Y';
          --
          If (p_batch_flag) then
            ben_batch_utils.write(p_text => '>     Interim Enrollment ( ' ||
                                  to_char(l_process_rec(j).prtt_enrt_rslt_id) ||
                                  ') Ended ');
          End if;
          --
          exit;
          --
        End if;
        --
      End loop;
      --
    Elsif (l_suspend_flag = 'Y' and l_process_rec(i).sspndd_flag = 'N')  then
      --
      -- If the result is suspended now and wasn't before then error out.
      --
      hr_utility.set_location('Result suspended after benactcm call.', 10);
      --
      If (p_batch_flag) then
        --
        ben_batch_utils.write
                 ('Enrollment(' || to_char(l_process_rec(i).prtt_enrt_rslt_id)
                 || ') can not be suspeneded since it is active before');
      End if;
      --
      Fnd_message.set_name('BEN','BEN_91908_ENRT_NOT_ALWD_SUSP');
      Fnd_message.raise_error;
      --
    End if;
    --
    hr_utility.set_location(' After four cases ',80);
    -- Clean up all unresolved action items for this enrt result.
    --
    For l_recA in c_actn(l_process_rec(i).prtt_enrt_rslt_id) loop
      --
      l_del_flag := FALSE;
      --
      If p_overwrite_flag then
        --
        l_del_flag := TRUE;
        --
      Elsif l_recA.due_dt < p_effective_date then --CFW
        --
        l_del_flag := TRUE;
        --
      Else
        --
        -- if the due date for the action items isn't past, do not delete it.
        --
        NULL;
        --
      End if;
      --
      If l_del_flag then
        --
        hr_utility.set_location(' l_del_flag TRUE ',80);
        remove_prtt_actn
          (p_prtt_enrt_actn_id          => l_reca.prtt_enrt_actn_id
          ,p_business_group_id          => p_business_group_id
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => hr_api.g_delete
          ,p_object_version_number      => l_reca.object_version_number
          ,p_prtt_enrt_rslt_id          => l_dump_number
          ,p_rslt_object_version_number => l_dump_number
          ,p_unsuspend_enrt_flag        => 'N'
          ,p_effective_start_date       => l_recA.effective_start_date
          ,p_effective_end_date         => l_recA.effective_end_date
          ,p_batch_flag                 => p_batch_flag);
        --
      End if;
      --
    End loop;     -- End of c_Actn
    --
    If p_batch_flag then
      --
      --hr_utility.set_location(' Second ld_actn Call ', 90);
      --hr_utility.set_location(' l_idx_b '||l_idx_b,90);
      --hr_utility.set_location('l_idx_e '||l_idx_e,90);

      --
      ld_actn(p_business_group_id  => p_business_group_id
             ,p_effective_date     => p_effective_date
             ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id
             ,p_before             => FALSE
             ,p_after              => TRUE
             ,p_idx_b              => l_idx_b
             ,p_idx_e              => l_idx_e);
      --
      l_actn := 'Calling Ben_batch_utils.cache_comp_obj...';
      --
      Ben_batch_utils.cache_comp_obj
        (p_prtt_enrt_rslt_id => l_process_rec(i).prtt_enrt_rslt_id
        ,p_effective_date    => p_effective_date
        ,p_actn_cd           => l_actn_cd);
      --
      If (l_actn_cd = 'D') then
        --
        benutils.write
          (p_text => '>  Enrollment(' ||
           to_char(l_process_rec(i).prtt_enrt_rslt_id) || ') Ended ');
        --
      Elsif (l_actn_cd = 'U') then
        --
        benutils.write
          (p_text => '>  Enrollment(' ||
           to_char(l_process_rec(i).prtt_enrt_rslt_id) || ') unsuspended ');
        --
      End if;
      --
    End if;
    --
  End loop;    -- End of Erec loop
  --
  -- Clean up interim enrollments.
  --
  For i in 1..l_intr_cnt loop
    --
    -- For each enrt result id call determine action items to try to unsuspend
    -- the result.
    --
    hr_utility.set_location('Cleaing up interim enrollment id : ' ||
                            l_intr_rec(i).prtt_enrt_rslt_id, 10);
    --
    If (l_intr_rec(i).skip = 'N') then
      --
      l_actn_cd := 'N';
      --
      If (p_batch_flag) then
        --
        l_actn := 'Calling ld_actn...';
        --
      --hr_utility.set_location(' Second ld_actn Call ', 99);
      --hr_utility.set_location(' l_idx_b '||l_idx_b,99);
      --hr_utility.set_location('l_idx_e '||l_idx_e,99);
      --hr_utility.set_location('l_process_rec(i).prtt_enrt_rslt_id '
      --                                     ||l_process_rec(i).prtt_enrt_rslt_id,99);
      --hr_utility.set_location(' p_effective_date '||p_effective_date,99);

        ld_actn(p_business_group_id  => p_business_group_id
               ,p_effective_date     => p_effective_date
               ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id
               ,p_before             => TRUE
               ,p_after              => FALSE
               ,p_idx_b              => l_idx_b
               ,p_idx_e              => l_idx_e
               );
      End if;
      --
      ben_enrollment_action_items.determine_action_items
        (p_prtt_enrt_rslt_id          => l_intr_rec(i).prtt_enrt_rslt_id
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_suspend_flag               => l_suspend_flag
        ,p_datetrack_mode             => 'CORRECTION'
        ,p_post_rslt_flag             => 'N'
        ,p_rslt_object_version_number => l_intr_rec(i).object_version_number
        ,p_dpnt_actn_warning          => l_dump_boolean
        ,p_bnf_actn_warning           => l_dump_boolean
        ,p_ctfn_actn_warning          => l_dump_boolean
        );
      --
      If (l_suspend_flag = 'Y' ) then
        l_actn := 'Erroring out - Suspend_flag can not be "Y"(I) ';
        fnd_message.set_name('BEN','BEN_91908_ENRT_NOT_ALWD_SUSP');
        fnd_message.raise_error;
      End if;
      --
      l_actn := 'Cleaning out all unresolved actn items(I)';
      --
      For l_recA in c_actn
          (c_prtt_enrt_rslt_id =>  l_intr_rec(i).prtt_enrt_rslt_id)
      loop
        --
        l_del_flag := FALSE;
        --
        If (p_overwrite_flag) then
          l_del_flag := TRUE;
        Elsif (l_recA.DUE_dt <= p_effective_date) then
           -- if the due date for the action items isn't past, do not delete it.
           NULL;
        End if;
        --
        If (l_del_flag) then
          --
          l_actn := 'Calling REMOVE_PRTT_ACTN to clean actn(I)';
          --
          remove_prtt_actn
            (p_prtt_enrt_actn_id          => l_reca.prtt_enrt_actn_id
            ,p_business_group_id          => p_business_group_id
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => hr_api.g_delete
            ,p_object_version_number      => l_reca.object_version_number
            ,p_prtt_enrt_rslt_id          => l_dump_number
            ,p_rslt_object_version_number => l_dump_number
            ,p_unsuspend_enrt_flag        => 'N'
            ,p_effective_start_date       => l_recA.effective_start_date
            ,p_effective_end_date         => l_recA.effective_end_date
            ,p_batch_flag                 => p_batch_flag
            );
          --
          If (p_batch_flag) then
            --
            l_actn := 'Calling ben_batch_utils.write...';
            --
            ben_batch_utils.write(p_text => '>     Prtt_Enrt_Actn(' ||
                                  to_char(l_recA.prtt_enrt_actn_id) ||
                                  ') deleted');
            --
          End if;
          --
        End if;
        --
      End loop;     -- End of c_Actn
      --
      If (p_batch_flag) then
        --
        l_actn := 'Calling ld_actn...';
        --
        ld_actn(p_business_group_id  => p_business_group_id
               ,p_effective_date     => p_effective_date
               ,p_prtt_enrt_rslt_id  => l_process_rec(i).prtt_enrt_rslt_id
               ,p_before             => FALSE
               ,p_after              => TRUE
               ,p_idx_b              => l_idx_b
               ,p_idx_e              => l_idx_e
               );
        --
        l_actn := 'Calling Ben_batch_utils.cache_comp_obj...';
        --
        Ben_batch_utils.cache_comp_obj
          (p_prtt_enrt_rslt_id => l_process_rec(i).prtt_enrt_rslt_id
          ,p_effective_date    => p_effective_date
          ,p_actn_cd           => l_actn_cd
          );
        --
        If (l_actn_cd = 'D') then
          --
          benutils.write
            (p_text => '>  Enrollment(' ||
             to_char(l_process_rec(i).prtt_enrt_rslt_id) || ') Ended ');
          --
        Elsif (l_actn_cd = 'U') then
          --
          benutils.write
            (p_text => '>  Enrollment(' ||
             to_char(l_process_rec(i).prtt_enrt_rslt_id) || ') unsuspended ');
          --
        End if;
        --
      End if;
      --
    End if;
    --
  End loop;    -- End of Irec loop
  --
  If p_validate then
    rollback to validate_point;
  End if;
  --
  If (p_batch_flag) then
    --
    write_person_category
      (p_audit_log          => p_audit_log
      ,p_business_group_id  => p_business_group_id
      ,P_person_id          => p_person_id
      ,p_effective_date     => p_effective_date);
    --
    If p_person_action_id is not null then
      --
      l_actn := 'Calling ben_person_actions_api.update_person_actions...';
      --
      ben_person_actions_api.update_person_actions
        (p_person_action_id      => p_person_action_id
        ,p_action_status_cd      => 'P'
        ,p_object_version_number => l_object_version_number
        ,p_effective_date        => p_effective_date);
      --
    End if;
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
    g_persons_procd := g_persons_procd + 1;
    --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
Exception
  --
  When others then
    --
    rollback to validate_point;
    --
    hr_utility.set_location('Exception handled in cls_per...', 10);
    If (p_batch_flag) then
      --
      g_persons_errored := g_persons_errored + 1;
      ben_batch_utils.write_error_rec;
      --
      ben_batch_utils.rpt_error(p_proc       => l_proc
                               ,p_last_actn  => l_actn
                               ,p_rpt_flag   => TRUE);
      --
      Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                                ,p_effective_date    => p_effective_date
                                );
      --
      Ben_batch_utils.write(p_text => '        << Transactions Rollbacked >> ');
      --
      If p_person_action_id is not null then
        --
        ben_person_actions_api.update_person_actions
          (p_person_action_id      => p_person_action_id
          ,p_action_status_cd      => 'E'
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => p_effective_date);
        --
      End if;
      --
      write_person_category
        (p_audit_log          => p_audit_log
        ,p_error              => TRUE
        ,p_business_group_id  => p_business_group_id
        ,p_person_id          => p_person_id
        ,p_effective_date     => p_effective_date);
      --
      benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
      --
    End if;
    --
    fnd_message.raise_error;
    --
end cls_per_unresolved_actn_item;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< do_multithread >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure do_multithread
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_validate              in     varchar2 default 'N'
  ,p_benefit_action_id     in     number
  ,p_thread_id             in     number
  ,p_effective_date        in     varchar2
  ,p_business_group_id     in     number
  ,p_audit_log             in     varchar2 default 'N'
  )
is
  --
  -- Local variable declaration
  --
  l_proc                   varchar2(80) := g_package||'.do_multithread';
  --
  l_effective_date         date;
  l_person_id              ben_person_actions.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_object_version_number  ben_person_actions.object_version_number%type;
  l_ler_id                 ben_person_actions.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_record_number          number := 0;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_actn                   varchar2(80);
  l_cnt                    number(5):= 0;
  l_validate               boolean;
  l_threads                number;
  l_chunk_size             number;
  --
  -- Cursors declaration
  --
  cursor c_range_thread
  is
  select ran.range_id
        ,ran.starting_person_action_id
        ,ran.ending_person_action_id
    from ben_batch_ranges ran
   where ran.range_status_cd = 'U'
     and ran.benefit_action_id  = p_benefit_action_id
     and rownum < 2
     for update of ran.range_status_cd;
  --
  cursor c_person_thread
  is
  select ben.person_id
        ,ben.person_action_id
        ,ben.object_version_number
        ,ben.ler_id
    from ben_person_actions ben
   where ben.benefit_action_id = p_benefit_action_id
     and ben.action_status_cd <> 'P'
     and ben.person_action_id between l_start_person_action_id
                                  and l_end_person_action_id
   order by ben.person_action_id;
  --
  cursor c_parameter
  is
  select *
    from ben_benefit_actions ben
   where ben.benefit_action_id = p_benefit_action_id;
  --
  cursor c_master is
    select 'Y'
    from   ben_benefit_actions bft
    where  bft.benefit_action_id = p_benefit_action_id
    and    bft.request_id = fnd_global.conc_request_id;
  --
  l_parm c_parameter%rowtype;
  l_commit number;
  l_master varchar2(1) := 'N';
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,5);
  --
  -- Convert varchar2 dates to real dates
  -- 1) First remove time component
  -- 2) Next convert format
  --
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR')
                             ,'DD/MM/RRRR');
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENUNEAI'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_person_err);
  --
  -- Set up benefits environment
  --
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_person_err,
                      p_benefit_action_id => p_benefit_action_id);
  --
  g_persons_procd := 0;
  g_persons_errored := 0;
  --
  ben_batch_utils.ini;
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  --
  open  c_master;
  fetch c_master into l_master;
  close c_master;
  --
  if p_validate = 'Y'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  open c_parameter;
  fetch c_parameter into l_parm;
  close c_parameter;
  --
  if fnd_global.conc_request_id <> -1
  then
    --
    -- Print the batch parameters to the log file if this program was called by
    -- the concurrent manager.
    --
    Ben_batch_utils.print_parameters
      (p_thread_id                => p_thread_id
      ,p_benefit_action_id        => p_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_person_id                => l_parm.person_id
      ,p_person_selection_rule_id => l_parm.person_selection_rl
      ,p_location_id              => l_parm.location_id
      ,p_audit_log                => p_audit_log);
    --
  end if;
  --
  -- The processing for this thread is as follows:
  --   1) Lock the rows in ben_batch_ranges that are not processed.
  --   2) Fetch the start and ending person action id for the range.
  --   3) Loop through the person actions in the range and close unresolved
  --      action items for each.
  --   4) Go to number 1 again and repeat until all ranges are processed.
  --
  loop
    --
    open c_range_thread;
    fetch c_range_thread
     into l_range_id,l_start_person_action_id,l_end_person_action_id;
    --
    if c_range_thread%notfound
    then
      close c_range_thread;
      exit;
    end if;
    --
    close c_range_thread;
    --
    update ben_batch_ranges ran
       set ran.range_status_cd = 'P'
     where ran.range_id = l_range_id;
    --
    commit;
    --
    g_cache_per_proc.delete;
    --
    l_record_number := 0;
    --
    -- Loop through all the person actions for the batch range being processed
    -- and close the unresolved action items.
    --
    for l_rec in c_person_thread
    loop
      --
      hr_utility.set_location('person_id : ' || l_rec.person_id, 10);
      --
      g_person_actn_cnt := g_person_actn_cnt + 1;
      --
      begin
        --
        ben_cls_unresolved_actn_item.cls_per_unresolved_actn_item
           (p_person_id             => l_rec.person_id
           ,p_person_action_id      => l_rec.person_action_id
           ,p_object_version_number => l_rec.object_version_number
           ,p_effective_date        => l_effective_date
           ,p_business_group_id     => p_business_group_id
           ,p_overwrite_flag        => FALSE
           ,p_validate              => l_validate
           ,p_batch_flag            => TRUE
           ,p_audit_log             => p_audit_log);
        --
        Exception
          When others then
              If (g_persons_errored > g_max_person_err) then
                  fnd_message.raise_error;
              End if;
        End;

    End loop;
        --
    --
  End loop;
  --
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                               ,p_num_pers_errored   => g_persons_errored);
  --
  --
  -- Check if all the slave processes are finished.
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  --
  -- End the process.
  --
  ben_batch_utils.end_process
    (p_benefit_action_id => p_benefit_action_id
    ,p_person_selected   => g_person_actn_cnt
    ,p_business_group_id => p_business_group_id);
  --
  -- Submit reports.
  --
  if l_master = 'Y' then
    --
    submit_all_reports(p_audit_log => p_audit_log);
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
Exception
  --
  when others
  then
    --
    rollback;
    --
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE);
    --
    benutils.write(p_text => fnd_message.get);
    benutils.write(p_text => sqlerrm);
    --
    ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
    --
    ben_batch_utils.end_process(p_benefit_action_id => p_benefit_action_id
                               ,p_person_selected   => g_person_actn_cnt
                               ,p_business_group_id => p_business_group_id);
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    commit;
    --
    fnd_message.raise_error;
    --
end do_multithread;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< restart >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure restart
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_benefit_action_id in     number)
is
  --
  -- Cursor Declaration
  --
  cursor c_parameters
  is
  select to_char(process_date,'YYYY/MM/DD HH24:MI:SS') process_date
        ,business_group_id
        ,pgm_id
        ,pl_id
        ,location_id
        ,ler_id
        ,popl_enrt_typ_cycl_id
        ,person_id
        ,person_selection_rl
        ,validate_flag
        ,debug_messages_flag
        ,audit_log_flag
   from ben_benefit_actions ben
  where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters    c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_actn        varchar2(80);
--
Begin
--
  hr_utility.set_location ('Entering ' || l_proc, 10);
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
  fetch c_parameters into l_parameters;
  --
  If c_parameters%notfound
  then
    close c_parameters;
    fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
    fnd_message.raise_error;
  End if;
  --
  close c_parameters;
  --
  -- Call the "process" procedure with parameters for restart
  --
  process(errbuf                     => l_errbuf
         ,retcode                    => l_retcode
         ,p_benefit_action_id        => p_benefit_action_id
         ,p_effective_date           => l_parameters.process_date
         ,p_validate                 => l_parameters.validate_flag
         ,p_business_group_id        => l_parameters.business_group_id
         ,p_pgm_id                   => l_parameters.pgm_id
         ,p_pl_nip_id                => l_parameters.pl_id
         ,p_location_id              => l_parameters.location_id
         ,p_person_id                => l_parameters.person_id
         ,p_debug_messages           => l_parameters.debug_messages_flag
         ,p_audit_log                => l_parameters.audit_log_flag
         );
  --
  hr_utility.set_location ('Leaving ' || l_proc, 70);
  --
End restart;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< process >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- This is the main procedure that is called from the concurrent manager.
--
procedure process
  (errbuf                       out nocopy varchar2
  ,retcode                      out nocopy number
  ,p_benefit_action_id       in     number
  ,p_effective_date          in     varchar2
  ,p_business_group_id       in     number
  ,p_pgm_id                  in     number   default NULL
  ,p_pl_nip_id               in     number   default NULL
  ,p_location_id             in     number   default NULL
  ,p_person_id               in     number   default NULL
  ,p_person_selection_rl     in     number   default NULL
  ,p_validate                in     varchar2 default 'N'
  ,p_debug_messages          in     varchar2 default 'N'
  ,p_audit_log               in     varchar2 default 'N'
  )
is
  --
  l_effective_date         date;
  --
  -- Cursor Declaration.
  --
  cursor c_pen
  is
  select distinct pen.person_id
    from ben_prtt_enrt_rslt_f pen
        ,ben_per_in_ler pil
        ,ben_prtt_enrt_actn_f actn
   where pen.business_group_id = p_business_group_id
     and pen.business_group_id = actn.business_group_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and pen.prtt_enrt_rslt_id = actn.prtt_enrt_rslt_id
     and nvl(pen.effective_end_date,hr_api.g_eot) = hr_api.g_eot
     and nvl(actn.effective_end_date,hr_api.g_eot) = hr_api.g_eot
     and actn.cmpltd_dt is null
     and (p_person_id is null or
          pen.person_id = p_person_id)
     and (p_location_id is null or
          exists ( select null
                     from per_assignments_f asg
                    where asg.person_id = pen.person_id
                      and   asg.assignment_type <> 'C'
                      and asg.location_id = p_location_id
                      and asg.business_group_id = p_business_group_id
                      and l_effective_date between asg.effective_start_date
                                               and asg.effective_end_date))
     and (p_pgm_id is null or
          pen.pgm_id = p_pgm_id)
     and (p_pl_nip_id is null or
           (pen.pl_id = p_pl_nip_id and pen.pgm_id is null))
     and pil.per_in_ler_id=actn.per_in_ler_id
     and pil.business_group_id=actn.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;
  --
  -- Local variable declaration.
  --
  l_proc                   varchar2(80) := g_package||'.Process';
  --
  l_object_version_number  Number(15);
  l_datetrack_mode         varchar2(80);
  l_actn                   varchar2(80);
  l_request_id             number;
  l_benefit_action_id      number(15);
  l_person_action_id       number(15);
  l_range_id               number(15);
  l_chunk_size             number := 20;
  l_num_ranges             number := 0;
  l_threads                number := 1;
  l_person_cnt             number := 0;
  l_chunk_num              number := 1;
  l_person_ok              varchar2(1) := 'Y';
  l_person_actn_cnt        number := 0;
  l_start_person_actn_id   number(15);
  l_end_person_actn_id     number(15);
  l_commit                 number;
--
Begin
--
  hr_utility.set_location ('Entering '||l_proc,5);
  --
  -- Convert varchar2 dates to real dates
  -- 1) First remove time component
  -- 2) Next convert format
  --
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR')
                             ,'DD/MM/RRRR');
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
    (p_ses_date => l_effective_date,
     p_commit   => l_commit);
  --
  -- Make sure all the mandatory input parameters are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'p_effective_date'
                            ,p_argument_value => l_effective_date
                            );
  --
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Get the parameters that were defined for this batch process.
  --
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENUNEAI'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_person_err);
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  If p_benefit_action_id is null then
    --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => NULL
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => p_pl_nip_id
      ,p_popl_enrt_typ_cycl_id  => NULL
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => NULL
      ,p_person_selection_rl    => p_person_selection_rl
      ,p_ler_id                 => NULL
      ,p_organization_id        => NULL
      ,p_benfts_grp_id          => NULL
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_pl_typ_id              => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => NULL
      ,p_payroll_id             => NULL
      ,p_debug_messages_flag    => p_debug_messages
      ,p_audit_log_flag         => p_audit_log
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    benutils.g_thread_id         := 99;
    --
    -- Loop through rows in ben_per_in_ler_f based on the parameters passed and
    -- create person actions for the selected people.
    --
    for l_rec in c_pen
    loop
      --
      -- set variables for this iteration
      --
      l_person_ok := 'Y';
      --
      -- Check the person selection rule.
      --
      if p_person_selection_rl is not null
      then
        --
        l_person_ok := ben_batch_utils.person_selection_rule
                         (p_person_id                => l_rec.person_id
                         ,p_business_group_id        => p_business_group_id
                         ,p_person_selection_rule_id => p_person_selection_rl
                         ,p_effective_date           => l_effective_date);
        --
      end if;
      --
      if l_person_ok = 'Y'
      then
        --
        -- Either no person sel rule or person selection rule passed. Create a
        -- person action row.
        --
        ben_person_actions_api.create_person_actions
          (p_validate              => FALSE
          ,p_person_action_id      => l_person_action_id
          ,p_person_id             => l_rec.person_id
          ,p_benefit_action_id     => l_benefit_action_id
          ,p_action_status_cd      => 'U'
          ,p_chunk_number          => l_chunk_num
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => l_effective_date);
        --
        -- increment the person action count and Set the ending person action id
        -- to the last person action id that got created
        --
        l_person_actn_cnt := l_person_actn_cnt + 1;
        l_end_person_actn_id := l_person_action_id;
        --
        -- We have to create batch ranges based on the number of person actions
        -- created and the chunk size defined for the batch process.
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 1 or l_chunk_size = 1
        then
          --
          -- This is the first person action id in a new range.
          --
          l_start_person_actn_id := l_person_action_id;
          --
        end if;
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 0 or l_chunk_size = 1
        then
          --
          -- The number of person actions that got created equals the chunk
          -- size. Create a batch range for the person actions.
          --
          ben_batch_ranges_api.create_batch_ranges
            (p_validate                  => FALSE
            ,p_effective_date            => l_effective_date
            ,p_benefit_action_id         => l_benefit_action_id
            ,p_range_id                  => l_range_id
            ,p_range_status_cd           => 'U'
            ,p_starting_person_action_id => l_start_person_actn_id
            ,p_ending_person_action_id   => l_end_person_actn_id
            ,p_object_version_number     => l_object_version_number);
          --
          l_num_ranges := l_num_ranges + 1;
          l_chunk_num := l_chunk_num + 1;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
    -- There may be a few person actions left over from the loop above that may
    -- not have got inserted into a batch range because the number was less than
    -- the chunk size. Create a range for the remaining person actions. This
    -- also applies when only one person gets selected.
    --
    if l_person_actn_cnt > 0 and
       mod(l_person_actn_cnt, l_chunk_size) <> 0
    then
      --
      ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => FALSE
        ,p_effective_date            => l_effective_date
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_actn_id
        ,p_ending_person_action_id   => l_end_person_actn_id
        ,p_object_version_number     => l_object_version_number);
      --
      l_num_ranges := l_num_ranges + 1;
      --
    end if;
    --
  Else
    --
    -- Benefit action id is not null i.e. the batch process is being restarted
    -- for a certain benefit action id. Create batch ranges and person actions
    -- for restarting.
    --
    l_benefit_action_id := p_benefit_action_id;
    --
    hr_utility.set_location('Restarting for benefit action id : ' ||
                            to_char(l_benefit_action_id), 10);
    --
    ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_ranges
      ,p_num_persons        => l_person_cnt);
    --
  end if;
  --
  commit;
  --
  -- Submit requests to the concurrent manager based on the number of ranges
  -- that got created.
  --
  if l_num_ranges > 1
  then
    --
    hr_utility.set_location('More than one range got created.', 10);
    --
    -- Set the number of threads to the lesser of the defined number of threads
    -- and the number of ranges created above. There's no point in submitting
    -- 5 threads for only two ranges.
    --
    l_threads := least(l_threads, l_num_ranges);
    --
    for l_count in 1..(l_threads - 1)
    loop
      --
      -- We are subtracting one from the number of threads because the main
      -- process will act as the last thread and will be able to keep track of
      -- the child requests that get submitted.
      --
      hr_utility.set_location('Submitting request ' || l_count, 10);
      --
      l_request_id := fnd_request.submit_request
                        (application      => 'BEN'
                        ,program          => 'BENUNEAIS'
                        ,description      => NULL
                        ,sub_request      => FALSE
                        ,argument1        => p_validate
                        ,argument2        => l_benefit_action_id
                        ,argument3        => l_count
                        ,argument4        => p_effective_date
                        ,argument5        => p_business_group_id
                        ,argument6        => p_audit_log);
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      --
    end loop;
    --
  elsif l_num_ranges = 0
  then
    --
    hr_utility.set_location('No people selected', 10);
    -- No ranges got created. i.e. no people got selected. Error out.
    --
    ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rl
      ,p_location_id              => p_location_id
      );
    --
    ben_batch_utils.write(p_text =>
                       'No person got selected with above selection criteria.');
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.raise_error;
    --
  end if;
  --
  -- Carry on with the master. This will ensure that the master finishes last.
  --
  hr_utility.set_location('Submitting the master process', 10);
  --
  do_multithread
    (errbuf               => errbuf
    ,retcode              => retcode
    ,p_validate           => p_validate
    ,p_benefit_action_id  => l_benefit_action_id
    ,p_thread_id          => l_threads
    ,p_effective_date     => p_effective_date
    ,p_business_group_id  => p_business_group_id
    ,p_audit_log          => p_audit_log);
  --
  hr_utility.set_location ('Leaving ' || l_proc, 10);
  --
End process;
--
End ben_cls_unresolved_Actn_item;

/
