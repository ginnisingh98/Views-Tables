--------------------------------------------------------
--  DDL for Package Body BEN_EPO_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPO_INS" as
/* $Header: beeporhi.pkb 120.0 2005/05/28 02:42:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_epo_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   ben_elig_per_opt_f t
    where  t.elig_per_opt_id       = p_rec.elig_per_opt_id
    and    t.effective_start_date =
             ben_epo_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc        varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_elig_per_opt_f.created_by%TYPE;
  l_creation_date       ben_elig_per_opt_f.creation_date%TYPE;
  l_last_update_date       ben_elig_per_opt_f.last_update_date%TYPE;
  l_last_updated_by     ben_elig_per_opt_f.last_updated_by%TYPE;
  l_last_update_login   ben_elig_per_opt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
    (p_base_table_name => 'ben_elig_per_opt_f',
     p_base_key_column => 'elig_per_opt_id',
     p_base_key_value  => p_rec.elig_per_opt_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  ben_epo_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_elig_per_opt_f
  --
    hr_utility.set_location('Ins EPO:'||l_proc, 5);
  insert into ben_elig_per_opt_f
  (    elig_per_opt_id,
    elig_per_id,
    effective_start_date,
    effective_end_date,
    prtn_ovridn_flag,
    prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag,
    elig_flag,
    prtn_strt_dt,
    prtn_end_dt,
    wait_perd_cmpltn_date,
    wait_perd_strt_dt,
    prtn_ovridn_rsn_cd,
    pct_fl_tm_val,
    opt_id,
    per_in_ler_id,
    rt_comp_ref_amt,
    rt_cmbn_age_n_los_val,
    rt_comp_ref_uom,
    rt_age_val,
    rt_los_val,
    rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom,
    rt_los_uom,
    rt_pct_fl_tm_val,
    rt_frz_los_flag,
    rt_frz_age_flag,
    rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag,
    comp_ref_amt,
    cmbn_age_n_los_val,
    comp_ref_uom,
    age_val,
    los_val,
    hrs_wkd_val,
    hrs_wkd_bndry_perd_cd,
    age_uom,
    los_uom,
    frz_los_flag,
    frz_age_flag,
    frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag,
    ovrid_svc_dt,
    inelg_rsn_cd,
    once_r_cntug_cd,
    oipl_ordr_num,
    business_group_id,
    epo_attribute_category,
    epo_attribute1,
    epo_attribute2,
    epo_attribute3,
    epo_attribute4,
    epo_attribute5,
    epo_attribute6,
    epo_attribute7,
    epo_attribute8,
    epo_attribute9,
    epo_attribute10,
    epo_attribute11,
    epo_attribute12,
    epo_attribute13,
    epo_attribute14,
    epo_attribute15,
    epo_attribute16,
    epo_attribute17,
    epo_attribute18,
    epo_attribute19,
    epo_attribute20,
    epo_attribute21,
    epo_attribute22,
    epo_attribute23,
    epo_attribute24,
    epo_attribute25,
    epo_attribute26,
    epo_attribute27,
    epo_attribute28,
    epo_attribute29,
    epo_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    created_by,
    creation_date,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  Values
  ( p_rec.elig_per_opt_id,
    p_rec.elig_per_id,
    p_rec.effective_start_date,
    p_rec.effective_end_date,
    p_rec.prtn_ovridn_flag,
    p_rec.prtn_ovridn_thru_dt,
    p_rec.no_mx_prtn_ovrid_thru_flag,
    p_rec.elig_flag,
    p_rec.prtn_strt_dt,
    p_rec.prtn_end_dt,
    p_rec.wait_perd_cmpltn_date,
    p_rec.wait_perd_strt_dt,
    p_rec.prtn_ovridn_rsn_cd,
    p_rec.pct_fl_tm_val,
    p_rec.opt_id,
    p_rec.per_in_ler_id,
    p_rec.rt_comp_ref_amt,
    p_rec.rt_cmbn_age_n_los_val,
    p_rec.rt_comp_ref_uom,
    p_rec.rt_age_val,
    p_rec.rt_los_val,
    p_rec.rt_hrs_wkd_val,
    p_rec.rt_hrs_wkd_bndry_perd_cd,
    p_rec.rt_age_uom,
    p_rec.rt_los_uom,
    p_rec.rt_pct_fl_tm_val,
    p_rec.rt_frz_los_flag,
    p_rec.rt_frz_age_flag,
    p_rec.rt_frz_cmp_lvl_flag,
    p_rec.rt_frz_pct_fl_tm_flag,
    p_rec.rt_frz_hrs_wkd_flag,
    p_rec.rt_frz_comb_age_and_los_flag,
    p_rec.comp_ref_amt,
    p_rec.cmbn_age_n_los_val,
    p_rec.comp_ref_uom,
    p_rec.age_val,
    p_rec.los_val,
    p_rec.hrs_wkd_val,
    p_rec.hrs_wkd_bndry_perd_cd,
    p_rec.age_uom,
    p_rec.los_uom,
    p_rec.frz_los_flag,
    p_rec.frz_age_flag,
    p_rec.frz_cmp_lvl_flag,
    p_rec.frz_pct_fl_tm_flag,
    p_rec.frz_hrs_wkd_flag,
    p_rec.frz_comb_age_and_los_flag,
    p_rec.ovrid_svc_dt,
    p_rec.inelg_rsn_cd,
    p_rec.once_r_cntug_cd,
    p_rec.oipl_ordr_num,
    p_rec.business_group_id,
    p_rec.epo_attribute_category,
    p_rec.epo_attribute1,
    p_rec.epo_attribute2,
    p_rec.epo_attribute3,
    p_rec.epo_attribute4,
    p_rec.epo_attribute5,
    p_rec.epo_attribute6,
    p_rec.epo_attribute7,
    p_rec.epo_attribute8,
    p_rec.epo_attribute9,
    p_rec.epo_attribute10,
    p_rec.epo_attribute11,
    p_rec.epo_attribute12,
    p_rec.epo_attribute13,
    p_rec.epo_attribute14,
    p_rec.epo_attribute15,
    p_rec.epo_attribute16,
    p_rec.epo_attribute17,
    p_rec.epo_attribute18,
    p_rec.epo_attribute19,
    p_rec.epo_attribute20,
    p_rec.epo_attribute21,
    p_rec.epo_attribute22,
    p_rec.epo_attribute23,
    p_rec.epo_attribute24,
    p_rec.epo_attribute25,
    p_rec.epo_attribute26,
    p_rec.epo_attribute27,
    p_rec.epo_attribute28,
    p_rec.epo_attribute29,
    p_rec.epo_attribute30,
    p_rec.request_id,
    p_rec.program_application_id,
    p_rec.program_id,
    p_rec.program_update_date,
    p_rec.object_version_number,
    l_created_by,
    l_creation_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
  );
  --
  ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
    (p_rec              in out nocopy ben_epo_shd.g_rec_type,
     p_effective_date        in date,
     p_datetrack_mode        in varchar2,
     p_validation_start_date    in date,
     p_validation_end_date        in date) is
--
  l_proc    varchar2(72) := g_package||'pre_insert';
--
--
  Cursor C_Sel1 is select ben_elig_per_opt_f_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.elig_per_opt_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
    (p_rec              in ben_epo_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_epo_rki.after_insert
      (
  p_elig_per_opt_id               =>p_rec.elig_per_opt_id
 ,p_elig_per_id                   =>p_rec.elig_per_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_prtn_ovridn_flag              =>p_rec.prtn_ovridn_flag
 ,p_prtn_ovridn_thru_dt           =>p_rec.prtn_ovridn_thru_dt
 ,p_no_mx_prtn_ovrid_thru_flag    =>p_rec.no_mx_prtn_ovrid_thru_flag
 ,p_elig_flag                     =>p_rec.elig_flag
 ,p_prtn_strt_dt                  =>p_rec.prtn_strt_dt
 ,p_prtn_end_dt                   =>p_rec.prtn_end_dt
 ,p_wait_perd_cmpltn_date           =>p_rec.wait_perd_cmpltn_date
 ,p_wait_perd_strt_dt             =>p_rec.wait_perd_strt_dt
 ,p_prtn_ovridn_rsn_cd            =>p_rec.prtn_ovridn_rsn_cd
 ,p_pct_fl_tm_val                 =>p_rec.pct_fl_tm_val
 ,p_opt_id                        =>p_rec.opt_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_rt_comp_ref_amt               =>p_rec.rt_comp_ref_amt
 ,p_rt_cmbn_age_n_los_val         =>p_rec.rt_cmbn_age_n_los_val
 ,p_rt_comp_ref_uom               =>p_rec.rt_comp_ref_uom
 ,p_rt_age_val                    =>p_rec.rt_age_val
 ,p_rt_los_val                    =>p_rec.rt_los_val
 ,p_rt_hrs_wkd_val                =>p_rec.rt_hrs_wkd_val
 ,p_rt_hrs_wkd_bndry_perd_cd      =>p_rec.rt_hrs_wkd_bndry_perd_cd
 ,p_rt_age_uom                    =>p_rec.rt_age_uom
 ,p_rt_los_uom                    =>p_rec.rt_los_uom
 ,p_rt_pct_fl_tm_val              =>p_rec.rt_pct_fl_tm_val
 ,p_rt_frz_los_flag               =>p_rec.rt_frz_los_flag
 ,p_rt_frz_age_flag               =>p_rec.rt_frz_age_flag
 ,p_rt_frz_cmp_lvl_flag           =>p_rec.rt_frz_cmp_lvl_flag
 ,p_rt_frz_pct_fl_tm_flag         =>p_rec.rt_frz_pct_fl_tm_flag
 ,p_rt_frz_hrs_wkd_flag           =>p_rec.rt_frz_hrs_wkd_flag
 ,p_rt_frz_comb_age_and_los_flag  =>p_rec.rt_frz_comb_age_and_los_flag
 ,p_comp_ref_amt                  =>p_rec.comp_ref_amt
 ,p_cmbn_age_n_los_val            =>p_rec.cmbn_age_n_los_val
 ,p_comp_ref_uom                  =>p_rec.comp_ref_uom
 ,p_age_val                       =>p_rec.age_val
 ,p_los_val                       =>p_rec.los_val
 ,p_hrs_wkd_val                   =>p_rec.hrs_wkd_val
 ,p_hrs_wkd_bndry_perd_cd         =>p_rec.hrs_wkd_bndry_perd_cd
 ,p_age_uom                       =>p_rec.age_uom
 ,p_los_uom                       =>p_rec.los_uom
 ,p_frz_los_flag                  =>p_rec.frz_los_flag
 ,p_frz_age_flag                  =>p_rec.frz_age_flag
 ,p_frz_cmp_lvl_flag              =>p_rec.frz_cmp_lvl_flag
 ,p_frz_pct_fl_tm_flag            =>p_rec.frz_pct_fl_tm_flag
 ,p_frz_hrs_wkd_flag              =>p_rec.frz_hrs_wkd_flag
 ,p_frz_comb_age_and_los_flag     =>p_rec.frz_comb_age_and_los_flag
 ,p_ovrid_svc_dt                  =>p_rec.ovrid_svc_dt
 ,p_inelg_rsn_cd                  =>p_rec.inelg_rsn_cd
 ,p_once_r_cntug_cd               =>p_rec.once_r_cntug_cd
 ,p_oipl_ordr_num                 =>p_rec.oipl_ordr_num
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_epo_attribute_category        =>p_rec.epo_attribute_category
 ,p_epo_attribute1                =>p_rec.epo_attribute1
 ,p_epo_attribute2                =>p_rec.epo_attribute2
 ,p_epo_attribute3                =>p_rec.epo_attribute3
 ,p_epo_attribute4                =>p_rec.epo_attribute4
 ,p_epo_attribute5                =>p_rec.epo_attribute5
 ,p_epo_attribute6                =>p_rec.epo_attribute6
 ,p_epo_attribute7                =>p_rec.epo_attribute7
 ,p_epo_attribute8                =>p_rec.epo_attribute8
 ,p_epo_attribute9                =>p_rec.epo_attribute9
 ,p_epo_attribute10               =>p_rec.epo_attribute10
 ,p_epo_attribute11               =>p_rec.epo_attribute11
 ,p_epo_attribute12               =>p_rec.epo_attribute12
 ,p_epo_attribute13               =>p_rec.epo_attribute13
 ,p_epo_attribute14               =>p_rec.epo_attribute14
 ,p_epo_attribute15               =>p_rec.epo_attribute15
 ,p_epo_attribute16               =>p_rec.epo_attribute16
 ,p_epo_attribute17               =>p_rec.epo_attribute17
 ,p_epo_attribute18               =>p_rec.epo_attribute18
 ,p_epo_attribute19               =>p_rec.epo_attribute19
 ,p_epo_attribute20               =>p_rec.epo_attribute20
 ,p_epo_attribute21               =>p_rec.epo_attribute21
 ,p_epo_attribute22               =>p_rec.epo_attribute22
 ,p_epo_attribute23               =>p_rec.epo_attribute23
 ,p_epo_attribute24               =>p_rec.epo_attribute24
 ,p_epo_attribute25               =>p_rec.epo_attribute25
 ,p_epo_attribute26               =>p_rec.epo_attribute26
 ,p_epo_attribute27               =>p_rec.epo_attribute27
 ,p_epo_attribute28               =>p_rec.epo_attribute28
 ,p_epo_attribute29               =>p_rec.epo_attribute29
 ,p_epo_attribute30               =>p_rec.epo_attribute30
 ,p_request_id              =>p_rec.request_id
 ,p_program_application_id      =>p_rec.program_application_id
 ,p_program_id              =>p_rec.program_id
 ,p_program_update_date       =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_elig_per_opt_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
    (p_effective_date        in  date,
     p_datetrack_mode        in  varchar2,
     p_rec                   in  ben_epo_shd.g_rec_type,
     p_validation_start_date out nocopy date,
     p_validation_end_date     out nocopy date) is
--
  l_proc          varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date      date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date       => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_base_table_name       => 'ben_elig_per_opt_f',
     p_base_key_column       => 'elig_per_opt_id',
     p_base_key_value        => p_rec.elig_per_opt_id,
     p_parent_table_name1      => 'ben_elig_per_f',
     p_parent_key_column1      => 'elig_per_id',
     p_parent_key_value1       => p_rec.elig_per_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date       => l_validation_end_date
    );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                 in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date      in     date
  --
  ,p_override_validation in     boolean          default false
  )
is
--
  l_proc            varchar2(72) := g_package||'ins';
  l_datetrack_mode        varchar2(30) := 'INSERT';
  l_validation_start_date    date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
    (p_effective_date      => p_effective_date,
     p_datetrack_mode      => l_datetrack_mode,
     p_rec              => p_rec,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  -- - Override validation for performance.
  --
  if not p_override_validation then
    --
    ben_epo_bus.insert_validate
      (p_rec             => p_rec,
       p_effective_date     => p_effective_date,
       p_datetrack_mode     => l_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date     => l_validation_end_date
      );
    --
  end if;
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_elig_per_opt_id              out nocopy number,
  p_elig_per_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_prtn_ovridn_flag             in varchar2,
  p_prtn_ovridn_thru_dt          in date             default null,
  p_no_mx_prtn_ovrid_thru_flag   in varchar2,
  p_elig_flag                    in varchar2,
  p_prtn_strt_dt                 in date             default null,
  p_prtn_end_dt                  in date             default null,
  p_wait_perd_cmpltn_date          in date             default null,
  p_wait_perd_strt_dt            in date             default null,
  p_prtn_ovridn_rsn_cd           in varchar2         default null,
  p_pct_fl_tm_val                in number           default null,
  p_opt_id                       in number           default null,
  p_per_in_ler_id                in number           default null,
  p_rt_comp_ref_amt              in number           default null,
  p_rt_cmbn_age_n_los_val        in number           default null,
  p_rt_comp_ref_uom              in varchar2         default null,
  p_rt_age_val                   in number           default null,
  p_rt_los_val                   in number           default null,
  p_rt_hrs_wkd_val               in number           default null,
  p_rt_hrs_wkd_bndry_perd_cd     in varchar2         default null,
  p_rt_age_uom                   in varchar2         default null,
  p_rt_los_uom                   in varchar2         default null,
  p_rt_pct_fl_tm_val             in number           default null,
  p_rt_frz_los_flag              in varchar2         default null,
  p_rt_frz_age_flag              in varchar2         default null,
  p_rt_frz_cmp_lvl_flag          in varchar2         default null,
  p_rt_frz_pct_fl_tm_flag        in varchar2         default null,
  p_rt_frz_hrs_wkd_flag          in varchar2         default null,
  p_rt_frz_comb_age_and_los_flag in varchar2         default null,
  p_comp_ref_amt                 in number           default null,
  p_cmbn_age_n_los_val           in number           default null,
  p_comp_ref_uom                 in varchar2         default null,
  p_age_val                      in number           default null,
  p_los_val                      in number           default null,
  p_hrs_wkd_val                  in number           default null,
  p_hrs_wkd_bndry_perd_cd        in varchar2         default null,
  p_age_uom                      in varchar2         default null,
  p_los_uom                      in varchar2         default null,
  p_frz_los_flag                 in varchar2         default null,
  p_frz_age_flag                 in varchar2         default null,
  p_frz_cmp_lvl_flag             in varchar2         default null,
  p_frz_pct_fl_tm_flag           in varchar2         default null,
  p_frz_hrs_wkd_flag             in varchar2         default null,
  p_frz_comb_age_and_los_flag    in varchar2         default null,
  p_ovrid_svc_dt                 in date             default null,
  p_inelg_rsn_cd                 in varchar2         default null,
  p_once_r_cntug_cd              in varchar2         default null,
  p_oipl_ordr_num                in number           default null,
  p_business_group_id            in number           default null,
  p_epo_attribute_category       in varchar2         default null,
  p_epo_attribute1               in varchar2         default null,
  p_epo_attribute2               in varchar2         default null,
  p_epo_attribute3               in varchar2         default null,
  p_epo_attribute4               in varchar2         default null,
  p_epo_attribute5               in varchar2         default null,
  p_epo_attribute6               in varchar2         default null,
  p_epo_attribute7               in varchar2         default null,
  p_epo_attribute8               in varchar2         default null,
  p_epo_attribute9               in varchar2         default null,
  p_epo_attribute10              in varchar2         default null,
  p_epo_attribute11              in varchar2         default null,
  p_epo_attribute12              in varchar2         default null,
  p_epo_attribute13              in varchar2         default null,
  p_epo_attribute14              in varchar2         default null,
  p_epo_attribute15              in varchar2         default null,
  p_epo_attribute16              in varchar2         default null,
  p_epo_attribute17              in varchar2         default null,
  p_epo_attribute18              in varchar2         default null,
  p_epo_attribute19              in varchar2         default null,
  p_epo_attribute20              in varchar2         default null,
  p_epo_attribute21              in varchar2         default null,
  p_epo_attribute22              in varchar2         default null,
  p_epo_attribute23              in varchar2         default null,
  p_epo_attribute24              in varchar2         default null,
  p_epo_attribute25              in varchar2         default null,
  p_epo_attribute26              in varchar2         default null,
  p_epo_attribute27              in varchar2         default null,
  p_epo_attribute28              in varchar2         default null,
  p_epo_attribute29              in varchar2         default null,
  p_epo_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  --
  p_override_validation          in boolean          default false
  )
is
--
  l_rec        ben_epo_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_epo_shd.convert_args
  (
  null,
  p_elig_per_id,
  null,
  null,
  p_prtn_ovridn_flag,
  p_prtn_ovridn_thru_dt,
  p_no_mx_prtn_ovrid_thru_flag,
  p_elig_flag,
  p_prtn_strt_dt,
  p_prtn_end_dt,
  p_wait_perd_cmpltn_date,
  p_wait_perd_strt_dt,
  p_prtn_ovridn_rsn_cd,
  p_pct_fl_tm_val,
  p_opt_id,
  p_per_in_ler_id,
  p_rt_comp_ref_amt,
  p_rt_cmbn_age_n_los_val,
  p_rt_comp_ref_uom,
  p_rt_age_val,
  p_rt_los_val,
  p_rt_hrs_wkd_val,
  p_rt_hrs_wkd_bndry_perd_cd,
  p_rt_age_uom,
  p_rt_los_uom,
  p_rt_pct_fl_tm_val,
  p_rt_frz_los_flag,
  p_rt_frz_age_flag,
  p_rt_frz_cmp_lvl_flag,
  p_rt_frz_pct_fl_tm_flag,
  p_rt_frz_hrs_wkd_flag,
  p_rt_frz_comb_age_and_los_flag,
  p_comp_ref_amt,
  p_cmbn_age_n_los_val,
  p_comp_ref_uom,
  p_age_val,
  p_los_val,
  p_hrs_wkd_val,
  p_hrs_wkd_bndry_perd_cd,
  p_age_uom,
  p_los_uom,
  p_frz_los_flag,
  p_frz_age_flag,
  p_frz_cmp_lvl_flag,
  p_frz_pct_fl_tm_flag,
  p_frz_hrs_wkd_flag,
  p_frz_comb_age_and_los_flag,
  p_ovrid_svc_dt,
  p_inelg_rsn_cd,
  p_once_r_cntug_cd,
  p_oipl_ordr_num,
  p_business_group_id,
  p_epo_attribute_category,
  p_epo_attribute1,
  p_epo_attribute2,
  p_epo_attribute3,
  p_epo_attribute4,
  p_epo_attribute5,
  p_epo_attribute6,
  p_epo_attribute7,
  p_epo_attribute8,
  p_epo_attribute9,
  p_epo_attribute10,
  p_epo_attribute11,
  p_epo_attribute12,
  p_epo_attribute13,
  p_epo_attribute14,
  p_epo_attribute15,
  p_epo_attribute16,
  p_epo_attribute17,
  p_epo_attribute18,
  p_epo_attribute19,
  p_epo_attribute20,
  p_epo_attribute21,
  p_epo_attribute22,
  p_epo_attribute23,
  p_epo_attribute24,
  p_epo_attribute25,
  p_epo_attribute26,
  p_epo_attribute27,
  p_epo_attribute28,
  p_epo_attribute29,
  p_epo_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_epo_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date,p_override_validation);
  --
  -- Set the OUT arguments.
  --
  p_elig_per_opt_id            := l_rec.elig_per_opt_id;
  p_effective_start_date      := l_rec.effective_start_date;
  p_effective_end_date        := l_rec.effective_end_date;
  p_object_version_number     := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_epo_ins;

/
