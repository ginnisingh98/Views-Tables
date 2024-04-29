--------------------------------------------------------
--  DDL for Package Body BEN_PGM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_UPD" as
/* $Header: bepgmrhi.pkb 120.1 2005/12/09 05:02:29 nhunur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pgm_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
        (p_rec                   in out nocopy ben_pgm_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
          (p_base_table_name    => 'ben_pgm_f',
           p_base_key_column    => 'pgm_id',
           p_base_key_value     => p_rec.pgm_id);
    --
    ben_pgm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_pgm_f Row
    --
    update  ben_pgm_f
    set
    pgm_id                          = p_rec.pgm_id,
    name                            = p_rec.name,
    dpnt_adrs_rqd_flag              = p_rec.dpnt_adrs_rqd_flag,
    pgm_prvds_no_auto_enrt_flag     = p_rec.pgm_prvds_no_auto_enrt_flag,
    dpnt_dob_rqd_flag               = p_rec.dpnt_dob_rqd_flag,
    pgm_prvds_no_dflt_enrt_flag     = p_rec.pgm_prvds_no_dflt_enrt_flag,
    dpnt_legv_id_rqd_flag           = p_rec.dpnt_legv_id_rqd_flag,
    dpnt_dsgn_lvl_cd                = p_rec.dpnt_dsgn_lvl_cd,
    pgm_stat_cd                     = p_rec.pgm_stat_cd,
    ivr_ident                       = p_rec.ivr_ident,
    pgm_typ_cd                      = p_rec.pgm_typ_cd,
    elig_apls_flag                  = p_rec.elig_apls_flag,
    uses_all_asmts_for_rts_flag     = p_rec.uses_all_asmts_for_rts_flag,
    url_ref_name                    = p_rec.url_ref_name,
    pgm_desc                        = p_rec.pgm_desc,
    prtn_elig_ovrid_alwd_flag       = p_rec.prtn_elig_ovrid_alwd_flag,
    pgm_use_all_asnts_elig_flag     = p_rec.pgm_use_all_asnts_elig_flag,
    dpnt_dsgn_cd                    = p_rec.dpnt_dsgn_cd,
    mx_dpnt_pct_prtt_lf_amt         = p_rec.mx_dpnt_pct_prtt_lf_amt,
    mx_sps_pct_prtt_lf_amt          = p_rec.mx_sps_pct_prtt_lf_amt,
    acty_ref_perd_cd                = p_rec.acty_ref_perd_cd,
    coord_cvg_for_all_pls_flg       = p_rec.coord_cvg_for_all_pls_flg,
    enrt_cvg_end_dt_cd              = p_rec.enrt_cvg_end_dt_cd,
    enrt_cvg_end_dt_rl              = p_rec.enrt_cvg_end_dt_rl,
    dpnt_cvg_end_dt_cd              = p_rec.dpnt_cvg_end_dt_cd,
    dpnt_cvg_end_dt_rl              = p_rec.dpnt_cvg_end_dt_rl,
    dpnt_cvg_strt_dt_cd             = p_rec.dpnt_cvg_strt_dt_cd,
    dpnt_cvg_strt_dt_rl             = p_rec.dpnt_cvg_strt_dt_rl,
    dpnt_dsgn_no_ctfn_rqd_flag      = p_rec.dpnt_dsgn_no_ctfn_rqd_flag,
    drvbl_fctr_dpnt_elig_flag       = p_rec.drvbl_fctr_dpnt_elig_flag,
    drvbl_fctr_prtn_elig_flag       = p_rec.drvbl_fctr_prtn_elig_flag,
    enrt_cvg_strt_dt_cd             = p_rec.enrt_cvg_strt_dt_cd,
    enrt_cvg_strt_dt_rl             = p_rec.enrt_cvg_strt_dt_rl,
    enrt_info_rt_freq_cd            = p_rec.enrt_info_rt_freq_cd,
    rt_strt_dt_cd                   = p_rec.rt_strt_dt_cd,
    rt_strt_dt_rl                   = p_rec.rt_strt_dt_rl,
    rt_end_dt_cd                    = p_rec.rt_end_dt_cd,
    rt_end_dt_rl                    = p_rec.rt_end_dt_rl,
    pgm_grp_cd                      = p_rec.pgm_grp_cd,
    pgm_uom                         = p_rec.pgm_uom,
    drvbl_fctr_apls_rts_flag        = p_rec.drvbl_fctr_apls_rts_flag,
    alws_unrstrctd_enrt_flag        = p_rec.alws_unrstrctd_enrt_flag,
    enrt_cd                         = p_rec.enrt_cd,
    enrt_mthd_cd                    = p_rec.enrt_mthd_cd,
    poe_lvl_cd                      = p_rec.poe_lvl_cd,
    enrt_rl                         = p_rec.enrt_rl,
    auto_enrt_mthd_rl               = p_rec.auto_enrt_mthd_rl,
    trk_inelig_per_flag             = p_rec.trk_inelig_per_flag,
    business_group_id               = p_rec.business_group_id,
    per_cvrd_cd                     = p_rec.per_cvrd_cd ,
    vrfy_fmly_mmbr_rl               = p_rec.vrfy_fmly_mmbr_rl  ,
    vrfy_fmly_mmbr_cd               = p_rec.vrfy_fmly_mmbr_cd,
    short_name			    = p_rec.short_name,		/*FHR*/
    short_code			    = p_rec.short_code,  	/*FHR*/
        legislation_code			    = p_rec.legislation_code,  	/*FHR*/
        legislation_subgroup			    = p_rec.legislation_subgroup,  	/*FHR*/
    Dflt_pgm_flag                   = p_rec.Dflt_pgm_flag,
    Use_prog_points_flag            = p_rec.Use_prog_points_flag,
    Dflt_step_cd                    = p_rec.Dflt_step_cd,
    Dflt_step_rl                    = p_rec.Dflt_step_rl,
    Update_salary_cd                = p_rec.Update_salary_cd,
    Use_multi_pay_rates_flag         = p_rec.Use_multi_pay_rates_flag,
    dflt_element_type_id            = p_rec.dflt_element_type_id,
    Dflt_input_value_id             = p_rec.Dflt_input_value_id,
    Use_scores_cd                   = p_rec.Use_scores_cd,
    Scores_calc_mthd_cd             = p_rec.Scores_calc_mthd_cd,
    Scores_calc_rl                  = p_rec.Scores_calc_rl,
    gsp_allow_override_flag          = p_rec.gsp_allow_override_flag,
    use_variable_rates_flag          = p_rec.use_variable_rates_flag,
    salary_calc_mthd_cd          = p_rec.salary_calc_mthd_cd,
    salary_calc_mthd_rl          = p_rec.salary_calc_mthd_rl,
    susp_if_dpnt_ssn_nt_prv_cd   = p_rec.susp_if_dpnt_ssn_nt_prv_cd,
    susp_if_dpnt_dob_nt_prv_cd   = p_rec.susp_if_dpnt_dob_nt_prv_cd,
    susp_if_dpnt_adr_nt_prv_cd   = p_rec.susp_if_dpnt_adr_nt_prv_cd,
    susp_if_ctfn_not_dpnt_flag   = p_rec.susp_if_ctfn_not_dpnt_flag,
    dpnt_ctfn_determine_cd       = p_rec.dpnt_ctfn_determine_cd,
    pgm_attribute_category          = p_rec.pgm_attribute_category,
    pgm_attribute1                  = p_rec.pgm_attribute1,
    pgm_attribute2                  = p_rec.pgm_attribute2,
    pgm_attribute3                  = p_rec.pgm_attribute3,
    pgm_attribute4                  = p_rec.pgm_attribute4,
    pgm_attribute5                  = p_rec.pgm_attribute5,
    pgm_attribute6                  = p_rec.pgm_attribute6,
    pgm_attribute7                  = p_rec.pgm_attribute7,
    pgm_attribute8                  = p_rec.pgm_attribute8,
    pgm_attribute9                  = p_rec.pgm_attribute9,
    pgm_attribute10                 = p_rec.pgm_attribute10,
    pgm_attribute11                 = p_rec.pgm_attribute11,
    pgm_attribute12                 = p_rec.pgm_attribute12,
    pgm_attribute13                 = p_rec.pgm_attribute13,
    pgm_attribute14                 = p_rec.pgm_attribute14,
    pgm_attribute15                 = p_rec.pgm_attribute15,
    pgm_attribute16                 = p_rec.pgm_attribute16,
    pgm_attribute17                 = p_rec.pgm_attribute17,
    pgm_attribute18                 = p_rec.pgm_attribute18,
    pgm_attribute19                 = p_rec.pgm_attribute19,
    pgm_attribute20                 = p_rec.pgm_attribute20,
    pgm_attribute21                 = p_rec.pgm_attribute21,
    pgm_attribute22                 = p_rec.pgm_attribute22,
    pgm_attribute23                 = p_rec.pgm_attribute23,
    pgm_attribute24                 = p_rec.pgm_attribute24,
    pgm_attribute25                 = p_rec.pgm_attribute25,
    pgm_attribute26                 = p_rec.pgm_attribute26,
    pgm_attribute27                 = p_rec.pgm_attribute27,
    pgm_attribute28                 = p_rec.pgm_attribute28,
    pgm_attribute29                 = p_rec.pgm_attribute29,
    pgm_attribute30                 = p_rec.pgm_attribute30,
    object_version_number           = p_rec.object_version_number
    where   pgm_id = p_rec.pgm_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pgm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pgm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pgm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
        (p_rec                   in out nocopy ben_pgm_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec                   => p_rec,
                p_effective_date        => p_effective_date,
                p_datetrack_mode        => p_datetrack_mode,
                p_validation_start_date => p_validation_start_date,
                p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
        (p_rec                   in out nocopy ben_pgm_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_pgm_shd.upd_effective_end_date
     (p_effective_date         => p_effective_date,
      p_base_key_value         => p_rec.pgm_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_pgm_del.delete_dml
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => p_validation_start_date,
         p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_pgm_ins.insert_dml
      (p_rec                    => p_rec,
       p_effective_date         => p_effective_date,
       p_datetrack_mode         => p_datetrack_mode,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
        (p_rec                   in out nocopy ben_pgm_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
        (p_rec                   in ben_pgm_shd.g_rec_type,
         p_effective_date        in date,
         p_datetrack_mode        in varchar2,
         p_validation_start_date in date,
         p_validation_end_date   in date) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Added for GSP validations
    pqh_gsp_ben_validations.pgm_validations
    	(  p_pgm_id			=> p_rec.pgm_id
    	 , p_dml_operation 		=> 'U'
    	 , p_effective_date 		=> p_effective_date
    	 , p_business_group_id  	=> p_rec.business_group_id
    	 , p_short_name			=> p_rec.short_name
    	 , p_short_code			=> p_rec.short_code
    	 , p_Dflt_Pgm_Flag		=> p_rec.Dflt_Pgm_Flag
    	 , p_Pgm_Typ_Cd			=> p_rec.Pgm_Typ_Cd
    	 , p_pgm_Stat_cd		=> p_rec.pgm_Stat_cd
    	 , p_Use_Prog_Points_Flag	=> p_rec.Use_Prog_Points_Flag
    	 , p_Acty_Ref_Perd_Cd		=> p_rec.Acty_Ref_Perd_Cd
    	 , p_Pgm_Uom			=> p_rec.Pgm_Uom
    	 );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_pgm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_pgm_shd.g_old_rec.name;
  End If;
  If (p_rec.dpnt_adrs_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_adrs_rqd_flag :=
    ben_pgm_shd.g_old_rec.dpnt_adrs_rqd_flag;
  End If;
  If (p_rec.pgm_prvds_no_auto_enrt_flag = hr_api.g_varchar2) then
    p_rec.pgm_prvds_no_auto_enrt_flag :=
    ben_pgm_shd.g_old_rec.pgm_prvds_no_auto_enrt_flag;
  End If;
  If (p_rec.dpnt_dob_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_dob_rqd_flag :=
    ben_pgm_shd.g_old_rec.dpnt_dob_rqd_flag;
  End If;
  If (p_rec.pgm_prvds_no_dflt_enrt_flag = hr_api.g_varchar2) then
    p_rec.pgm_prvds_no_dflt_enrt_flag :=
    ben_pgm_shd.g_old_rec.pgm_prvds_no_dflt_enrt_flag;
  End If;
  If (p_rec.dpnt_legv_id_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_legv_id_rqd_flag :=
    ben_pgm_shd.g_old_rec.dpnt_legv_id_rqd_flag;
  End If;
  If (p_rec.dpnt_dsgn_lvl_cd = hr_api.g_varchar2) then
    p_rec.dpnt_dsgn_lvl_cd :=
    ben_pgm_shd.g_old_rec.dpnt_dsgn_lvl_cd;
  End If;
  If (p_rec.pgm_stat_cd = hr_api.g_varchar2) then
    p_rec.pgm_stat_cd :=
    ben_pgm_shd.g_old_rec.pgm_stat_cd;
  End If;
  If (p_rec.ivr_ident = hr_api.g_varchar2) then
    p_rec.ivr_ident :=
    ben_pgm_shd.g_old_rec.ivr_ident;
  End If;
  If (p_rec.pgm_typ_cd = hr_api.g_varchar2) then
    p_rec.pgm_typ_cd :=
    ben_pgm_shd.g_old_rec.pgm_typ_cd;
  End If;
  If (p_rec.elig_apls_flag = hr_api.g_varchar2) then
    p_rec.elig_apls_flag :=
    ben_pgm_shd.g_old_rec.elig_apls_flag;
  End If;
  If (p_rec.uses_all_asmts_for_rts_flag = hr_api.g_varchar2) then
    p_rec.uses_all_asmts_for_rts_flag :=
    ben_pgm_shd.g_old_rec.uses_all_asmts_for_rts_flag;
  End If;
  If (p_rec.url_ref_name = hr_api.g_varchar2) then
    p_rec.url_ref_name :=
    ben_pgm_shd.g_old_rec.url_ref_name;
  End If;
  If (p_rec.pgm_desc = hr_api.g_varchar2) then
    p_rec.pgm_desc :=
    ben_pgm_shd.g_old_rec.pgm_desc;
  End If;
  If (p_rec.prtn_elig_ovrid_alwd_flag = hr_api.g_varchar2) then
    p_rec.prtn_elig_ovrid_alwd_flag :=
    ben_pgm_shd.g_old_rec.prtn_elig_ovrid_alwd_flag;
  End If;
  If (p_rec.pgm_use_all_asnts_elig_flag = hr_api.g_varchar2) then
    p_rec.pgm_use_all_asnts_elig_flag :=
    ben_pgm_shd.g_old_rec.pgm_use_all_asnts_elig_flag;
  End If;
  If (p_rec.dpnt_dsgn_cd = hr_api.g_varchar2) then
    p_rec.dpnt_dsgn_cd :=
    ben_pgm_shd.g_old_rec.dpnt_dsgn_cd;
  End If;
  If (p_rec.mx_dpnt_pct_prtt_lf_amt = hr_api.g_number) then
    p_rec.mx_dpnt_pct_prtt_lf_amt :=
    ben_pgm_shd.g_old_rec.mx_dpnt_pct_prtt_lf_amt;
  End If;
  If (p_rec.mx_sps_pct_prtt_lf_amt = hr_api.g_number) then
    p_rec.mx_sps_pct_prtt_lf_amt :=
    ben_pgm_shd.g_old_rec.mx_sps_pct_prtt_lf_amt;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_pgm_shd.g_old_rec.acty_ref_perd_cd;
  End If;
  If (p_rec.coord_cvg_for_all_pls_flg = hr_api.g_varchar2) then
    p_rec.coord_cvg_for_all_pls_flg :=
    ben_pgm_shd.g_old_rec.coord_cvg_for_all_pls_flg;
  End If;
  If (p_rec.enrt_cvg_end_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_end_dt_cd :=
    ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_cd;
  End If;
  If (p_rec.enrt_cvg_end_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_end_dt_rl :=
    ben_pgm_shd.g_old_rec.enrt_cvg_end_dt_rl;
  End If;
  If (p_rec.dpnt_cvg_end_dt_cd = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_end_dt_cd :=
    ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_cd;
  End If;
  If (p_rec.dpnt_cvg_end_dt_rl = hr_api.g_number) then
    p_rec.dpnt_cvg_end_dt_rl :=
    ben_pgm_shd.g_old_rec.dpnt_cvg_end_dt_rl;
  End If;
  If (p_rec.dpnt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_strt_dt_cd :=
    ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_cd;
  End If;
  If (p_rec.dpnt_cvg_strt_dt_rl = hr_api.g_number) then
    p_rec.dpnt_cvg_strt_dt_rl :=
    ben_pgm_shd.g_old_rec.dpnt_cvg_strt_dt_rl;
  End If;
  If (p_rec.dpnt_dsgn_no_ctfn_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_dsgn_no_ctfn_rqd_flag :=
    ben_pgm_shd.g_old_rec.dpnt_dsgn_no_ctfn_rqd_flag;
  End If;
  If (p_rec.drvbl_fctr_dpnt_elig_flag = hr_api.g_varchar2) then
    p_rec.drvbl_fctr_dpnt_elig_flag :=
    ben_pgm_shd.g_old_rec.drvbl_fctr_dpnt_elig_flag;
  End If;
  If (p_rec.drvbl_fctr_prtn_elig_flag = hr_api.g_varchar2) then
    p_rec.drvbl_fctr_prtn_elig_flag :=
    ben_pgm_shd.g_old_rec.drvbl_fctr_prtn_elig_flag;
  End If;
  If (p_rec.enrt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_strt_dt_cd :=
    ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_cd;
  End If;
  If (p_rec.enrt_cvg_strt_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_strt_dt_rl :=
    ben_pgm_shd.g_old_rec.enrt_cvg_strt_dt_rl;
  End If;
  If (p_rec.enrt_info_rt_freq_cd = hr_api.g_varchar2) then
    p_rec.enrt_info_rt_freq_cd :=
    ben_pgm_shd.g_old_rec.enrt_info_rt_freq_cd;
  End If;
  If (p_rec.rt_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_strt_dt_cd :=
    ben_pgm_shd.g_old_rec.rt_strt_dt_cd;
  End If;
  If (p_rec.rt_strt_dt_rl = hr_api.g_number) then
    p_rec.rt_strt_dt_rl :=
    ben_pgm_shd.g_old_rec.rt_strt_dt_rl;
  End If;
  If (p_rec.rt_end_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_end_dt_cd :=
    ben_pgm_shd.g_old_rec.rt_end_dt_cd;
  End If;
  If (p_rec.rt_end_dt_rl = hr_api.g_number) then
    p_rec.rt_end_dt_rl :=
    ben_pgm_shd.g_old_rec.rt_end_dt_rl;
  End If;
  If (p_rec.pgm_grp_cd = hr_api.g_varchar2) then
    p_rec.pgm_grp_cd :=
    ben_pgm_shd.g_old_rec.pgm_grp_cd;
  End If;
  If (p_rec.pgm_uom = hr_api.g_varchar2) then
    p_rec.pgm_uom :=
    ben_pgm_shd.g_old_rec.pgm_uom;
  End If;
  If (p_rec.drvbl_fctr_apls_rts_flag = hr_api.g_varchar2) then
    p_rec.drvbl_fctr_apls_rts_flag :=
    ben_pgm_shd.g_old_rec.drvbl_fctr_apls_rts_flag;
  End If;
  If (p_rec.alws_unrstrctd_enrt_flag = hr_api.g_varchar2) then
    p_rec.alws_unrstrctd_enrt_flag :=
    ben_pgm_shd.g_old_rec.alws_unrstrctd_enrt_flag;
  End If;
  If (p_rec.enrt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cd :=
    ben_pgm_shd.g_old_rec.enrt_cd;
  End If;
  If (p_rec.enrt_mthd_cd = hr_api.g_varchar2) then
    p_rec.enrt_mthd_cd :=
    ben_pgm_shd.g_old_rec.enrt_mthd_cd;
  End If;
  If (p_rec.poe_lvl_cd = hr_api.g_varchar2) then
    p_rec.poe_lvl_cd :=
    ben_pgm_shd.g_old_rec.poe_lvl_cd;
  End If;
  If (p_rec.enrt_rl = hr_api.g_number) then
    p_rec.enrt_rl :=
    ben_pgm_shd.g_old_rec.enrt_rl;
  End If;
  If (p_rec.auto_enrt_mthd_rl = hr_api.g_number) then
    p_rec.auto_enrt_mthd_rl :=
    ben_pgm_shd.g_old_rec.auto_enrt_mthd_rl;
  End If;
  If (p_rec.trk_inelig_per_flag = hr_api.g_varchar2) then
    p_rec.trk_inelig_per_flag :=
    ben_pgm_shd.g_old_rec.trk_inelig_per_flag;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pgm_shd.g_old_rec.business_group_id;
  End If;


  If (p_rec.per_cvrd_cd = hr_api.g_varchar2) then
    p_rec.per_cvrd_cd :=
    ben_pgm_shd.g_old_rec.per_cvrd_cd;
  End If;

  If (p_rec.vrfy_fmly_mmbr_rl = hr_api.g_number) then
    p_rec.vrfy_fmly_mmbr_rl :=
    ben_pgm_shd.g_old_rec.vrfy_fmly_mmbr_rl;
  End If;

  If (p_rec.vrfy_fmly_mmbr_cd = hr_api.g_varchar2) then
    p_rec.vrfy_fmly_mmbr_cd :=
    ben_pgm_shd.g_old_rec.vrfy_fmly_mmbr_cd;
  End If;

--FHR
  If (p_rec.short_name = hr_api.g_varchar2) then
    p_rec.short_name :=
    ben_pgm_shd.g_old_rec.short_name;
  End If;

  If (p_rec.short_code = hr_api.g_varchar2) then
    p_rec.short_code :=
    ben_pgm_shd.g_old_rec.short_code;
  End If;

  If (p_rec.legislation_code = hr_api.g_varchar2) then
        p_rec.legislation_code :=
        ben_pgm_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.legislation_subgroup = hr_api.g_varchar2) then
        p_rec.legislation_subgroup :=
        ben_pgm_shd.g_old_rec.legislation_subgroup;
  End If;

--GSTP
  If (p_rec.Dflt_pgm_flag = hr_api.g_varchar2) then
    p_rec.Dflt_pgm_flag :=
    ben_pgm_shd.g_old_rec.Dflt_pgm_flag;
  End If;
  If (p_rec.Use_prog_points_flag = hr_api.g_varchar2) then
    p_rec.Use_prog_points_flag :=
    ben_pgm_shd.g_old_rec.Use_prog_points_flag;
  End If;
  If (p_rec.Dflt_step_cd = hr_api.g_varchar2) then
    p_rec.Dflt_step_cd :=
    ben_pgm_shd.g_old_rec.Dflt_step_cd;
  End If;
  If (p_rec.Dflt_step_rl = hr_api.g_number) then
    p_rec.Dflt_step_rl :=
    ben_pgm_shd.g_old_rec.Dflt_step_rl;
  End If;
  If (p_rec.Update_salary_cd = hr_api.g_varchar2) then
    p_rec.Update_salary_cd :=
    ben_pgm_shd.g_old_rec.Update_salary_cd;
  End If;
  If (p_rec.Use_multi_pay_rates_flag = hr_api.g_varchar2) then
    p_rec.Use_multi_pay_rates_flag :=
    ben_pgm_shd.g_old_rec.Use_multi_pay_rates_flag;
  End If;
  If (p_rec.dflt_element_type_id = hr_api.g_number) then
    p_rec.dflt_element_type_id :=
    ben_pgm_shd.g_old_rec.dflt_element_type_id;
  End If;
  If (p_rec.Dflt_input_value_id = hr_api.g_number) then
    p_rec.Dflt_input_value_id :=
    ben_pgm_shd.g_old_rec.Dflt_input_value_id;
  End If;
  If (p_rec.Use_scores_cd = hr_api.g_varchar2) then
    p_rec.Use_scores_cd :=
    ben_pgm_shd.g_old_rec.Use_scores_cd;
  End If;
  If (p_rec.Scores_calc_mthd_cd = hr_api.g_varchar2) then
    p_rec.Scores_calc_mthd_cd :=
    ben_pgm_shd.g_old_rec.Scores_calc_mthd_cd;
  End If;
  If (p_rec.Scores_calc_rl = hr_api.g_number) then
    p_rec.Scores_calc_rl :=
    ben_pgm_shd.g_old_rec.Scores_calc_rl;
  End If;
--GSTP

  If (p_rec.gsp_allow_override_flag = hr_api.g_varchar2) then
    p_rec.gsp_allow_override_flag :=
    ben_pgm_shd.g_old_rec.gsp_allow_override_flag;
  End If;

  If (p_rec.use_variable_rates_flag = hr_api.g_varchar2) then
    p_rec.use_variable_rates_flag :=
    ben_pgm_shd.g_old_rec.use_variable_rates_flag;
  End If;

  If (p_rec.salary_calc_mthd_cd = hr_api.g_varchar2) then
    p_rec.salary_calc_mthd_cd :=
    ben_pgm_shd.g_old_rec.salary_calc_mthd_cd;
  End If;


  If (p_rec.salary_calc_mthd_rl = hr_api.g_number) then
    p_rec.salary_calc_mthd_rl :=
    ben_pgm_shd.g_old_rec.salary_calc_mthd_rl;
  End If;

  If (p_rec.susp_if_dpnt_ssn_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_ssn_nt_prv_cd :=
    ben_pgm_shd.g_old_rec.susp_if_dpnt_ssn_nt_prv_cd;
  End If;

  If (p_rec.susp_if_dpnt_dob_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_dob_nt_prv_cd :=
    ben_pgm_shd.g_old_rec.susp_if_dpnt_dob_nt_prv_cd;
  End If;
  If (p_rec.susp_if_dpnt_adr_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_adr_nt_prv_cd :=
    ben_pgm_shd.g_old_rec.susp_if_dpnt_adr_nt_prv_cd;
  End If;
  If (p_rec.susp_if_ctfn_not_dpnt_flag = hr_api.g_varchar2) then
    p_rec.susp_if_ctfn_not_dpnt_flag :=
    ben_pgm_shd.g_old_rec.susp_if_ctfn_not_dpnt_flag;
  End If;
  If (p_rec.dpnt_ctfn_determine_cd = hr_api.g_varchar2) then
    p_rec.dpnt_ctfn_determine_cd :=
    ben_pgm_shd.g_old_rec.dpnt_ctfn_determine_cd;
  End If;

  If (p_rec.pgm_attribute_category = hr_api.g_varchar2) then
    p_rec.pgm_attribute_category :=
    ben_pgm_shd.g_old_rec.pgm_attribute_category;
  End If;

  If (p_rec.pgm_attribute1 = hr_api.g_varchar2) then
    p_rec.pgm_attribute1 :=
    ben_pgm_shd.g_old_rec.pgm_attribute1;
  End If;

  If (p_rec.pgm_attribute2 = hr_api.g_varchar2) then
    p_rec.pgm_attribute2 :=
    ben_pgm_shd.g_old_rec.pgm_attribute2;
  End If;
  If (p_rec.pgm_attribute3 = hr_api.g_varchar2) then
    p_rec.pgm_attribute3 :=
    ben_pgm_shd.g_old_rec.pgm_attribute3;
  End If;
  If (p_rec.pgm_attribute4 = hr_api.g_varchar2) then
    p_rec.pgm_attribute4 :=
    ben_pgm_shd.g_old_rec.pgm_attribute4;
  End If;
  If (p_rec.pgm_attribute5 = hr_api.g_varchar2) then
    p_rec.pgm_attribute5 :=
    ben_pgm_shd.g_old_rec.pgm_attribute5;
  End If;
  If (p_rec.pgm_attribute6 = hr_api.g_varchar2) then
    p_rec.pgm_attribute6 :=
    ben_pgm_shd.g_old_rec.pgm_attribute6;
  End If;
  If (p_rec.pgm_attribute7 = hr_api.g_varchar2) then
    p_rec.pgm_attribute7 :=
    ben_pgm_shd.g_old_rec.pgm_attribute7;
  End If;
  If (p_rec.pgm_attribute8 = hr_api.g_varchar2) then
    p_rec.pgm_attribute8 :=
    ben_pgm_shd.g_old_rec.pgm_attribute8;
  End If;
  If (p_rec.pgm_attribute9 = hr_api.g_varchar2) then
    p_rec.pgm_attribute9 :=
    ben_pgm_shd.g_old_rec.pgm_attribute9;
  End If;
  If (p_rec.pgm_attribute10 = hr_api.g_varchar2) then
    p_rec.pgm_attribute10 :=
    ben_pgm_shd.g_old_rec.pgm_attribute10;
  End If;
  If (p_rec.pgm_attribute11 = hr_api.g_varchar2) then
    p_rec.pgm_attribute11 :=
    ben_pgm_shd.g_old_rec.pgm_attribute11;
  End If;
  If (p_rec.pgm_attribute12 = hr_api.g_varchar2) then
    p_rec.pgm_attribute12 :=
    ben_pgm_shd.g_old_rec.pgm_attribute12;
  End If;
  If (p_rec.pgm_attribute13 = hr_api.g_varchar2) then
    p_rec.pgm_attribute13 :=
    ben_pgm_shd.g_old_rec.pgm_attribute13;
  End If;
  If (p_rec.pgm_attribute14 = hr_api.g_varchar2) then
    p_rec.pgm_attribute14 :=
    ben_pgm_shd.g_old_rec.pgm_attribute14;
  End If;
  If (p_rec.pgm_attribute15 = hr_api.g_varchar2) then
    p_rec.pgm_attribute15 :=
    ben_pgm_shd.g_old_rec.pgm_attribute15;
  End If;
  If (p_rec.pgm_attribute16 = hr_api.g_varchar2) then
    p_rec.pgm_attribute16 :=
    ben_pgm_shd.g_old_rec.pgm_attribute16;
  End If;
  If (p_rec.pgm_attribute17 = hr_api.g_varchar2) then
    p_rec.pgm_attribute17 :=
    ben_pgm_shd.g_old_rec.pgm_attribute17;
  End If;
  If (p_rec.pgm_attribute18 = hr_api.g_varchar2) then
    p_rec.pgm_attribute18 :=
    ben_pgm_shd.g_old_rec.pgm_attribute18;
  End If;
  If (p_rec.pgm_attribute19 = hr_api.g_varchar2) then
    p_rec.pgm_attribute19 :=
    ben_pgm_shd.g_old_rec.pgm_attribute19;
  End If;
  If (p_rec.pgm_attribute20 = hr_api.g_varchar2) then
    p_rec.pgm_attribute20 :=
    ben_pgm_shd.g_old_rec.pgm_attribute20;
  End If;
  If (p_rec.pgm_attribute21 = hr_api.g_varchar2) then
    p_rec.pgm_attribute21 :=
    ben_pgm_shd.g_old_rec.pgm_attribute21;
  End If;
  If (p_rec.pgm_attribute22 = hr_api.g_varchar2) then
    p_rec.pgm_attribute22 :=
    ben_pgm_shd.g_old_rec.pgm_attribute22;
  End If;
  If (p_rec.pgm_attribute23 = hr_api.g_varchar2) then
    p_rec.pgm_attribute23 :=
    ben_pgm_shd.g_old_rec.pgm_attribute23;
  End If;
  If (p_rec.pgm_attribute24 = hr_api.g_varchar2) then
    p_rec.pgm_attribute24 :=
    ben_pgm_shd.g_old_rec.pgm_attribute24;
  End If;
  If (p_rec.pgm_attribute25 = hr_api.g_varchar2) then
    p_rec.pgm_attribute25 :=
    ben_pgm_shd.g_old_rec.pgm_attribute25;
  End If;
  If (p_rec.pgm_attribute26 = hr_api.g_varchar2) then
    p_rec.pgm_attribute26 :=
    ben_pgm_shd.g_old_rec.pgm_attribute26;
  End If;
  If (p_rec.pgm_attribute27 = hr_api.g_varchar2) then
    p_rec.pgm_attribute27 :=
    ben_pgm_shd.g_old_rec.pgm_attribute27;
  End If;
  If (p_rec.pgm_attribute28 = hr_api.g_varchar2) then
    p_rec.pgm_attribute28 :=
    ben_pgm_shd.g_old_rec.pgm_attribute28;
  End If;
  If (p_rec.pgm_attribute29 = hr_api.g_varchar2) then
    p_rec.pgm_attribute29 :=
    ben_pgm_shd.g_old_rec.pgm_attribute29;
  End If;
  If (p_rec.pgm_attribute30 = hr_api.g_varchar2) then
    p_rec.pgm_attribute30 :=
    ben_pgm_shd.g_old_rec.pgm_attribute30;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec                 in out nocopy  ben_pgm_shd.g_rec_type,
  p_effective_date      in      date,
  p_datetrack_mode      in      varchar2
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_pgm_shd.lck
        (p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_pgm_id        => p_rec.pgm_id,
         p_object_version_number => p_rec.object_version_number,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_pgm_bus.update_validate
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pgm_id                       in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_dpnt_adrs_rqd_flag           in varchar2         default hr_api.g_varchar2,
  p_pgm_prvds_no_auto_enrt_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_dob_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_pgm_prvds_no_dflt_enrt_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_legv_id_rqd_flag        in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_lvl_cd             in varchar2         default hr_api.g_varchar2,
  p_pgm_stat_cd                  in varchar2         default hr_api.g_varchar2,
  p_ivr_ident                    in varchar2         default hr_api.g_varchar2,
  p_pgm_typ_cd                   in varchar2         default hr_api.g_varchar2,
  p_elig_apls_flag               in varchar2         default hr_api.g_varchar2,
  p_uses_all_asmts_for_rts_flag  in varchar2         default hr_api.g_varchar2,
  p_url_ref_name                 in varchar2         default hr_api.g_varchar2,
  p_pgm_desc                     in varchar2         default hr_api.g_varchar2,
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_pgm_use_all_asnts_elig_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_mx_dpnt_pct_prtt_lf_amt      in number           default hr_api.g_number,
  p_mx_sps_pct_prtt_lf_amt       in number           default hr_api.g_number,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_coord_cvg_for_all_pls_flg    in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_dpnt_dsgn_no_ctfn_rqd_flag   in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_dpnt_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_enrt_info_rt_freq_cd         in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_rl                in number           default hr_api.g_number,
  p_rt_end_dt_cd                 in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_rl                 in number           default hr_api.g_number,
  p_pgm_grp_cd                   in varchar2         default hr_api.g_varchar2,
  p_pgm_uom                      in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default hr_api.g_varchar2,
  p_alws_unrstrctd_enrt_flag     in  varchar2        default hr_api.g_varchar2,
  p_enrt_cd                      in  varchar2        default hr_api.g_varchar2,
  p_enrt_mthd_cd                 in  varchar2        default hr_api.g_varchar2,
  p_poe_lvl_cd                   in  varchar2        default hr_api.g_varchar2,
  p_enrt_rl                      in  number          default hr_api.g_number,
  p_auto_enrt_mthd_rl            in  number          default hr_api.g_number,
  p_trk_inelig_per_flag          in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_per_cvrd_cd                  in varchar2        default hr_api.g_varchar2,
  P_vrfy_fmly_mmbr_rl            in number          default hr_api.g_number,
  P_vrfy_fmly_mmbr_cd            in varchar2        default hr_api.g_varchar2,
  p_short_name			 in varchar2         default hr_api.g_varchar2,    --FHR
  p_short_code			 in varchar2         default hr_api.g_varchar2,    --FHR
    p_legislation_code			 in varchar2         default hr_api.g_varchar2,
    p_legislation_subgroup			 in varchar2         default hr_api.g_varchar2,
  p_Dflt_pgm_flag                in Varchar2         default hr_api.g_varchar2,
  p_Use_prog_points_flag         in Varchar2         default hr_api.g_varchar2,
  p_Dflt_step_cd                 in Varchar2         default hr_api.g_varchar2,
  p_Dflt_step_rl                 in number           default hr_api.g_number,
  p_Update_salary_cd             in Varchar2         default hr_api.g_varchar2,
  p_Use_multi_pay_rates_flag     in Varchar2         default hr_api.g_varchar2,
  p_dflt_element_type_id         in number           default hr_api.g_number,
  p_Dflt_input_value_id          in number           default hr_api.g_number,
  p_Use_scores_cd                in Varchar2         default hr_api.g_varchar2,
  p_Scores_calc_mthd_cd          in Varchar2         default hr_api.g_varchar2,
  p_Scores_calc_rl               in number           default hr_api.g_number,
  p_gsp_allow_override_flag       in varchar2         default hr_api.g_varchar2,
  p_use_variable_rates_flag       in varchar2         default hr_api.g_varchar2,
  p_salary_calc_mthd_cd       in varchar2         default hr_api.g_varchar2,
  p_salary_calc_mthd_rl       in number         default hr_api.g_number,
  p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default hr_api.g_varchar2,
  p_dpnt_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2,
  p_pgm_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date               in date,
  p_datetrack_mode               in varchar2
  ) is
--
  l_rec         ben_pgm_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pgm_shd.convert_args
  (
  p_pgm_id,
  null,
  null,
  p_name,
  p_dpnt_adrs_rqd_flag,
  p_pgm_prvds_no_auto_enrt_flag,
  p_dpnt_dob_rqd_flag,
  p_pgm_prvds_no_dflt_enrt_flag,
  p_dpnt_legv_id_rqd_flag,
  p_dpnt_dsgn_lvl_cd,
  p_pgm_stat_cd,
  p_ivr_ident,
  p_pgm_typ_cd,
  p_elig_apls_flag,
  p_uses_all_asmts_for_rts_flag,
  p_url_ref_name,
  p_pgm_desc,
  p_prtn_elig_ovrid_alwd_flag,
  p_pgm_use_all_asnts_elig_flag,
  p_dpnt_dsgn_cd,
  p_mx_dpnt_pct_prtt_lf_amt,
  p_mx_sps_pct_prtt_lf_amt,
  p_acty_ref_perd_cd,
  p_coord_cvg_for_all_pls_flg,
  p_enrt_cvg_end_dt_cd,
  p_enrt_cvg_end_dt_rl,
  p_dpnt_cvg_end_dt_cd,
  p_dpnt_cvg_end_dt_rl,
  p_dpnt_cvg_strt_dt_cd,
  p_dpnt_cvg_strt_dt_rl,
  p_dpnt_dsgn_no_ctfn_rqd_flag,
  p_drvbl_fctr_dpnt_elig_flag,
  p_drvbl_fctr_prtn_elig_flag,
  p_enrt_cvg_strt_dt_cd,
  p_enrt_cvg_strt_dt_rl,
  p_enrt_info_rt_freq_cd,
  p_rt_strt_dt_cd,
  p_rt_strt_dt_rl,
  p_rt_end_dt_cd,
  p_rt_end_dt_rl,
  p_pgm_grp_cd,
  p_pgm_uom,
  p_drvbl_fctr_apls_rts_flag,
  p_alws_unrstrctd_enrt_flag,
  p_enrt_cd,
  p_enrt_mthd_cd,
  p_poe_lvl_cd,
  p_enrt_rl,
  p_auto_enrt_mthd_rl,
  p_trk_inelig_per_flag,
  p_business_group_id,
  p_per_cvrd_cd  ,
  P_vrfy_fmly_mmbr_rl,
  P_vrfy_fmly_mmbr_cd,
  p_short_name,			/*FHR*/
  p_short_code,			/*FHR*/
    p_legislation_code,			/*FHR*/
    p_legislation_subgroup,			/*FHR*/
  p_Dflt_pgm_flag,
  p_Use_prog_points_flag,
  p_Dflt_step_cd,
  p_Dflt_step_rl,
  p_Update_salary_cd,
  p_Use_multi_pay_rates_flag,
  p_dflt_element_type_id,
  p_Dflt_input_value_id,
  p_Use_scores_cd,
  p_Scores_calc_mthd_cd,
  p_Scores_calc_rl,
  P_gsp_allow_override_flag,
  P_use_variable_rates_flag,
  P_salary_calc_mthd_cd,
  P_salary_calc_mthd_rl,
  p_susp_if_dpnt_ssn_nt_prv_cd,
  p_susp_if_dpnt_dob_nt_prv_cd,
  p_susp_if_dpnt_adr_nt_prv_cd,
  p_susp_if_ctfn_not_dpnt_flag,
  p_dpnt_ctfn_determine_cd,
  P_pgm_attribute_category,
  p_pgm_attribute1,
  p_pgm_attribute2,
  p_pgm_attribute3,
  p_pgm_attribute4,
  p_pgm_attribute5,
  p_pgm_attribute6,
  p_pgm_attribute7,
  p_pgm_attribute8,
  p_pgm_attribute9,
  p_pgm_attribute10,
  p_pgm_attribute11,
  p_pgm_attribute12,
  p_pgm_attribute13,
  p_pgm_attribute14,
  p_pgm_attribute15,
  p_pgm_attribute16,
  p_pgm_attribute17,
  p_pgm_attribute18,
  p_pgm_attribute19,
  p_pgm_attribute20,
  p_pgm_attribute21,
  p_pgm_attribute22,
  p_pgm_attribute23,
  p_pgm_attribute24,
  p_pgm_attribute25,
  p_pgm_attribute26,
  p_pgm_attribute27,
  p_pgm_attribute28,
  p_pgm_attribute29,
  p_pgm_attribute30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pgm_upd;

/
