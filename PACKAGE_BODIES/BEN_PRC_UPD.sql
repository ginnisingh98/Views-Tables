--------------------------------------------------------
--  DDL for Package Body BEN_PRC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRC_UPD" as
/* $Header: beprcrhi.pkb 120.7.12010000.2 2008/08/05 15:19:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prc_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
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
	  (p_base_table_name	=> 'ben_prtt_reimbmt_rqst_f',
	   p_base_key_column	=> 'prtt_reimbmt_rqst_id',
	   p_base_key_value	=> p_rec.prtt_reimbmt_rqst_id);
    --
    ben_prc_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_prtt_reimbmt_rqst_f Row
    --
    update  ben_prtt_reimbmt_rqst_f
    set
        prtt_reimbmt_rqst_id        = p_rec.prtt_reimbmt_rqst_id,
    incrd_from_dt                   = p_rec.incrd_from_dt,
    incrd_to_dt                     = p_rec.incrd_to_dt,
    rqst_num                        = p_rec.rqst_num,
    rqst_amt                        = p_rec.rqst_amt,
    rqst_amt_uom                    = p_rec.rqst_amt_uom,
    rqst_btch_num                   = p_rec.rqst_btch_num,
    prtt_reimbmt_rqst_stat_cd       = p_rec.prtt_reimbmt_rqst_stat_cd,
    reimbmt_ctfn_typ_prvdd_cd       = p_rec.reimbmt_ctfn_typ_prvdd_cd,
    rcrrg_cd                        = p_rec.rcrrg_cd,
    submitter_person_id             = p_rec.submitter_person_id,
    recipient_person_id             = p_rec.recipient_person_id,
    provider_person_id              = p_rec.provider_person_id,
    provider_ssn_person_id          = p_rec.provider_ssn_person_id,
    pl_id                           = p_rec.pl_id,
    gd_or_svc_typ_id                = p_rec.gd_or_svc_typ_id,
    contact_relationship_id         = p_rec.contact_relationship_id,
    business_group_id               = p_rec.business_group_id,
    opt_id                          = p_rec.opt_id,
    popl_yr_perd_id_1               = p_rec.popl_yr_perd_id_1,
    popl_yr_perd_id_2               = p_rec.popl_yr_perd_id_2 ,
    amt_year1                       = p_rec.amt_year1 ,
    amt_year2                       = p_rec.amt_year2 ,
    prc_attribute_category          = p_rec.prc_attribute_category,
    prc_attribute1                  = p_rec.prc_attribute1,
    prc_attribute2                  = p_rec.prc_attribute2,
    prc_attribute3                  = p_rec.prc_attribute3,
    prc_attribute4                  = p_rec.prc_attribute4,
    prc_attribute5                  = p_rec.prc_attribute5,
    prc_attribute6                  = p_rec.prc_attribute6,
    prc_attribute7                  = p_rec.prc_attribute7,
    prc_attribute8                  = p_rec.prc_attribute8,
    prc_attribute9                  = p_rec.prc_attribute9,
    prc_attribute10                 = p_rec.prc_attribute10,
    prc_attribute11                 = p_rec.prc_attribute11,
    prc_attribute12                 = p_rec.prc_attribute12,
    prc_attribute13                 = p_rec.prc_attribute13,
    prc_attribute14                 = p_rec.prc_attribute14,
    prc_attribute15                 = p_rec.prc_attribute15,
    prc_attribute16                 = p_rec.prc_attribute16,
    prc_attribute17                 = p_rec.prc_attribute17,
    prc_attribute18                 = p_rec.prc_attribute18,
    prc_attribute19                 = p_rec.prc_attribute19,
    prc_attribute20                 = p_rec.prc_attribute20,
    prc_attribute21                 = p_rec.prc_attribute21,
    prc_attribute22                 = p_rec.prc_attribute22,
    prc_attribute23                 = p_rec.prc_attribute23,
    prc_attribute24                 = p_rec.prc_attribute24,
    prc_attribute25                 = p_rec.prc_attribute25,
    prc_attribute26                 = p_rec.prc_attribute26,
    prc_attribute27                 = p_rec.prc_attribute27,
    prc_attribute28                 = p_rec.prc_attribute28,
    prc_attribute29                 = p_rec.prc_attribute29,
    prc_attribute30                 = p_rec.prc_attribute30,
    prtt_enrt_rslt_id               = p_rec.prtt_enrt_rslt_id,
    comment_id                      = p_rec.comment_id  ,
    object_version_number           = p_rec.object_version_number ,
    stat_rsn_cd                     = p_rec.stat_rsn_cd ,
    pymt_stat_cd                    = p_rec.pymt_stat_cd ,
    pymt_stat_rsn_cd                = p_rec.pymt_stat_rsn_cd ,
    stat_ovrdn_flag                 = p_rec.stat_ovrdn_flag ,
    stat_ovrdn_rsn_cd               = p_rec.stat_ovrdn_rsn_cd ,
    stat_prr_to_ovrd                = p_rec.stat_prr_to_ovrd ,
    pymt_stat_ovrdn_flag            = p_rec.pymt_stat_ovrdn_flag ,
    pymt_stat_ovrdn_rsn_cd          = p_rec.pymt_stat_ovrdn_rsn_cd ,
    pymt_stat_prr_to_ovrd           = p_rec.pymt_stat_prr_to_ovrd ,
    adjmt_flag                      = p_rec.adjmt_flag ,
    submtd_dt                       = p_rec.submtd_dt ,
    ttl_rqst_amt                    = p_rec.ttl_rqst_amt ,
    aprvd_for_pymt_amt              = p_rec.aprvd_for_pymt_amt ,
    exp_incurd_dt		    = p_rec.exp_incurd_dt
    where   prtt_reimbmt_rqst_id    = p_rec.prtt_reimbmt_rqst_id
    and     effective_start_date    = p_validation_start_date
    and     effective_end_date      = p_validation_end_date;
    --
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
--	the validation_start_date.
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_prc_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.prtt_reimbmt_rqst_id,
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
      ben_prc_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_prc_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
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
	(p_rec 			 in ben_prc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_prc_rku.after_update
      (
  p_prtt_reimbmt_rqst_id          =>p_rec.prtt_reimbmt_rqst_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_incrd_from_dt                 =>p_rec.incrd_from_dt
 ,p_incrd_to_dt                   =>p_rec.incrd_to_dt
 ,p_rqst_num                      =>p_rec.rqst_num
 ,p_rqst_amt                      =>p_rec.rqst_amt
 ,p_rqst_amt_uom                  =>p_rec.rqst_amt_uom
 ,p_rqst_btch_num                 =>p_rec.rqst_btch_num
 ,p_prtt_reimbmt_rqst_stat_cd     =>p_rec.prtt_reimbmt_rqst_stat_cd
 ,p_reimbmt_ctfn_typ_prvdd_cd     =>p_rec.reimbmt_ctfn_typ_prvdd_cd
 ,p_rcrrg_cd                      =>p_rec.rcrrg_cd
 ,p_submitter_person_id           =>p_rec.submitter_person_id
 ,p_recipient_person_id           =>p_rec.recipient_person_id
 ,p_provider_person_id            =>p_rec.provider_person_id
 ,p_provider_ssn_person_id        =>p_rec.provider_ssn_person_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_gd_or_svc_typ_id              =>p_rec.gd_or_svc_typ_id
 ,p_contact_relationship_id       =>p_rec.contact_relationship_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_opt_id                        =>p_rec.opt_id
 ,p_popl_yr_perd_id_1             =>p_rec.popl_yr_perd_id_1
 ,p_popl_yr_perd_id_2             =>p_rec.popl_yr_perd_id_2
 ,p_amt_year1                     =>p_rec.amt_year1
 ,p_amt_year2                     =>p_rec.amt_year2
 ,p_prc_attribute_category        =>p_rec.prc_attribute_category
 ,p_prc_attribute1                =>p_rec.prc_attribute1
 ,p_prc_attribute2                =>p_rec.prc_attribute2
 ,p_prc_attribute3                =>p_rec.prc_attribute3
 ,p_prc_attribute4                =>p_rec.prc_attribute4
 ,p_prc_attribute5                =>p_rec.prc_attribute5
 ,p_prc_attribute6                =>p_rec.prc_attribute6
 ,p_prc_attribute7                =>p_rec.prc_attribute7
 ,p_prc_attribute8                =>p_rec.prc_attribute8
 ,p_prc_attribute9                =>p_rec.prc_attribute9
 ,p_prc_attribute10               =>p_rec.prc_attribute10
 ,p_prc_attribute11               =>p_rec.prc_attribute11
 ,p_prc_attribute12               =>p_rec.prc_attribute12
 ,p_prc_attribute13               =>p_rec.prc_attribute13
 ,p_prc_attribute14               =>p_rec.prc_attribute14
 ,p_prc_attribute15               =>p_rec.prc_attribute15
 ,p_prc_attribute16               =>p_rec.prc_attribute16
 ,p_prc_attribute17               =>p_rec.prc_attribute17
 ,p_prc_attribute18               =>p_rec.prc_attribute18
 ,p_prc_attribute19               =>p_rec.prc_attribute19
 ,p_prc_attribute20               =>p_rec.prc_attribute20
 ,p_prc_attribute21               =>p_rec.prc_attribute21
 ,p_prc_attribute22               =>p_rec.prc_attribute22
 ,p_prc_attribute23               =>p_rec.prc_attribute23
 ,p_prc_attribute24               =>p_rec.prc_attribute24
 ,p_prc_attribute25               =>p_rec.prc_attribute25
 ,p_prc_attribute26               =>p_rec.prc_attribute26
 ,p_prc_attribute27               =>p_rec.prc_attribute27
 ,p_prc_attribute28               =>p_rec.prc_attribute28
 ,p_prc_attribute29               =>p_rec.prc_attribute29
 ,p_prc_attribute30               =>p_rec.prc_attribute30
 ,p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
 ,p_comment_id                    =>p_rec.comment_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_stat_rsn_cd                   =>p_rec.stat_rsn_cd
 ,p_pymt_stat_cd                  =>p_rec.pymt_stat_cd
 ,p_pymt_stat_rsn_cd              =>p_rec.pymt_stat_rsn_cd
 ,p_stat_ovrdn_flag               =>p_rec.stat_ovrdn_flag
 ,p_stat_ovrdn_rsn_cd             =>p_rec.stat_ovrdn_rsn_cd
 ,p_stat_prr_to_ovrd              =>p_rec.stat_prr_to_ovrd
 ,p_pymt_stat_ovrdn_flag          =>p_rec.pymt_stat_ovrdn_flag
 ,p_pymt_stat_ovrdn_rsn_cd        =>p_rec.pymt_stat_ovrdn_rsn_cd
 ,p_pymt_stat_prr_to_ovrd         =>p_rec.pymt_stat_prr_to_ovrd
 ,p_adjmt_flag                    =>p_rec.adjmt_flag
 ,p_submtd_dt                     =>p_rec.submtd_dt
 ,p_ttl_rqst_amt                  =>p_rec.ttl_rqst_amt
 ,p_aprvd_for_pymt_amt            =>p_rec.aprvd_for_pymt_amt
 ,p_exp_incurd_dt		  =>p_rec.exp_incurd_dt
 ,p_effective_date                =>p_effective_date
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date_o        =>ben_prc_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_prc_shd.g_old_rec.effective_end_date
 ,p_incrd_from_dt_o               =>ben_prc_shd.g_old_rec.incrd_from_dt
 ,p_incrd_to_dt_o                 =>ben_prc_shd.g_old_rec.incrd_to_dt
 ,p_rqst_num_o                    =>ben_prc_shd.g_old_rec.rqst_num
 ,p_rqst_amt_o                    =>ben_prc_shd.g_old_rec.rqst_amt
 ,p_rqst_amt_uom_o                =>ben_prc_shd.g_old_rec.rqst_amt_uom
 ,p_rqst_btch_num_o               =>ben_prc_shd.g_old_rec.rqst_btch_num
 ,p_prtt_reimbmt_rqst_stat_cd_o   =>ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd
 ,p_reimbmt_ctfn_typ_prvdd_cd_o   =>ben_prc_shd.g_old_rec.reimbmt_ctfn_typ_prvdd_cd
 ,p_rcrrg_cd_o                    =>ben_prc_shd.g_old_rec.rcrrg_cd
 ,p_submitter_person_id_o         =>ben_prc_shd.g_old_rec.submitter_person_id
 ,p_recipient_person_id_o         =>ben_prc_shd.g_old_rec.recipient_person_id
 ,p_provider_person_id_o          =>ben_prc_shd.g_old_rec.provider_person_id
 ,p_provider_ssn_person_id_o      =>ben_prc_shd.g_old_rec.provider_ssn_person_id
 ,p_pl_id_o                       =>ben_prc_shd.g_old_rec.pl_id
 ,p_gd_or_svc_typ_id_o            =>ben_prc_shd.g_old_rec.gd_or_svc_typ_id
 ,p_contact_relationship_id_o     =>ben_prc_shd.g_old_rec.contact_relationship_id
 ,p_business_group_id_o           =>ben_prc_shd.g_old_rec.business_group_id
 ,p_opt_id_o                        =>ben_prc_shd.g_old_rec.opt_id
 ,p_popl_yr_perd_id_1_o             =>ben_prc_shd.g_old_rec.popl_yr_perd_id_1
 ,p_popl_yr_perd_id_2_o             =>ben_prc_shd.g_old_rec.popl_yr_perd_id_2
 ,p_amt_year1_o                     =>ben_prc_shd.g_old_rec.amt_year1
 ,p_amt_year2_o                     =>ben_prc_shd.g_old_rec.amt_year2
 ,p_prc_attribute_category_o      =>ben_prc_shd.g_old_rec.prc_attribute_category
 ,p_prc_attribute1_o              =>ben_prc_shd.g_old_rec.prc_attribute1
 ,p_prc_attribute2_o              =>ben_prc_shd.g_old_rec.prc_attribute2
 ,p_prc_attribute3_o              =>ben_prc_shd.g_old_rec.prc_attribute3
 ,p_prc_attribute4_o              =>ben_prc_shd.g_old_rec.prc_attribute4
 ,p_prc_attribute5_o              =>ben_prc_shd.g_old_rec.prc_attribute5
 ,p_prc_attribute6_o              =>ben_prc_shd.g_old_rec.prc_attribute6
 ,p_prc_attribute7_o              =>ben_prc_shd.g_old_rec.prc_attribute7
 ,p_prc_attribute8_o              =>ben_prc_shd.g_old_rec.prc_attribute8
 ,p_prc_attribute9_o              =>ben_prc_shd.g_old_rec.prc_attribute9
 ,p_prc_attribute10_o             =>ben_prc_shd.g_old_rec.prc_attribute10
 ,p_prc_attribute11_o             =>ben_prc_shd.g_old_rec.prc_attribute11
 ,p_prc_attribute12_o             =>ben_prc_shd.g_old_rec.prc_attribute12
 ,p_prc_attribute13_o             =>ben_prc_shd.g_old_rec.prc_attribute13
 ,p_prc_attribute14_o             =>ben_prc_shd.g_old_rec.prc_attribute14
 ,p_prc_attribute15_o             =>ben_prc_shd.g_old_rec.prc_attribute15
 ,p_prc_attribute16_o             =>ben_prc_shd.g_old_rec.prc_attribute16
 ,p_prc_attribute17_o             =>ben_prc_shd.g_old_rec.prc_attribute17
 ,p_prc_attribute18_o             =>ben_prc_shd.g_old_rec.prc_attribute18
 ,p_prc_attribute19_o             =>ben_prc_shd.g_old_rec.prc_attribute19
 ,p_prc_attribute20_o             =>ben_prc_shd.g_old_rec.prc_attribute20
 ,p_prc_attribute21_o             =>ben_prc_shd.g_old_rec.prc_attribute21
 ,p_prc_attribute22_o             =>ben_prc_shd.g_old_rec.prc_attribute22
 ,p_prc_attribute23_o             =>ben_prc_shd.g_old_rec.prc_attribute23
 ,p_prc_attribute24_o             =>ben_prc_shd.g_old_rec.prc_attribute24
 ,p_prc_attribute25_o             =>ben_prc_shd.g_old_rec.prc_attribute25
 ,p_prc_attribute26_o             =>ben_prc_shd.g_old_rec.prc_attribute26
 ,p_prc_attribute27_o             =>ben_prc_shd.g_old_rec.prc_attribute27
 ,p_prc_attribute28_o             =>ben_prc_shd.g_old_rec.prc_attribute28
 ,p_prc_attribute29_o             =>ben_prc_shd.g_old_rec.prc_attribute29
 ,p_prc_attribute30_o             =>ben_prc_shd.g_old_rec.prc_attribute30
 ,p_prtt_enrt_rslt_id_o           =>ben_prc_shd.g_old_rec.prtt_enrt_rslt_id
 ,p_comment_id_o                  =>ben_prc_shd.g_old_rec.comment_id
 ,p_object_version_number_o       =>ben_prc_shd.g_old_rec.object_version_number
 ,p_stat_rsn_cd_o                 =>ben_prc_shd.g_old_rec.stat_rsn_cd
 ,p_pymt_stat_cd_o                =>ben_prc_shd.g_old_rec.pymt_stat_cd
 ,p_pymt_stat_rsn_cd_o            =>ben_prc_shd.g_old_rec.pymt_stat_rsn_cd
 ,p_stat_ovrdn_flag_o             =>ben_prc_shd.g_old_rec.stat_ovrdn_flag
 ,p_stat_ovrdn_rsn_cd_o           =>ben_prc_shd.g_old_rec.stat_ovrdn_rsn_cd
 ,p_stat_prr_to_ovrd_o            =>ben_prc_shd.g_old_rec.stat_prr_to_ovrd
 ,p_pymt_stat_ovrdn_flag_o        =>ben_prc_shd.g_old_rec.pymt_stat_ovrdn_flag
 ,p_pymt_stat_ovrdn_rsn_cd_o      =>ben_prc_shd.g_old_rec.pymt_stat_ovrdn_rsn_cd
 ,p_pymt_stat_prr_to_ovrd_o       =>ben_prc_shd.g_old_rec.pymt_stat_prr_to_ovrd
 ,p_adjmt_flag_o                   =>ben_prc_shd.g_old_rec.adjmt_flag
 ,p_submtd_dt_o                   =>ben_prc_shd.g_old_rec.submtd_dt
 ,p_ttl_rqst_amt_o                =>ben_prc_shd.g_old_rec.ttl_rqst_amt
 ,p_aprvd_for_pymt_amt_o          =>ben_prc_shd.g_old_rec.aprvd_for_pymt_amt
 ,p_exp_incurd_dt_o		  =>ben_prc_shd.g_old_rec.exp_incurd_dt
  );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_reimbmt_rqst_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
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
Procedure convert_defs(p_rec in out nocopy ben_prc_shd.g_rec_type) is
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
  If (p_rec.incrd_from_dt = hr_api.g_date) then
    p_rec.incrd_from_dt :=
    ben_prc_shd.g_old_rec.incrd_from_dt;
  End If;
  If (p_rec.incrd_to_dt = hr_api.g_date) then
    p_rec.incrd_to_dt :=
    ben_prc_shd.g_old_rec.incrd_to_dt;
  End If;
  If (p_rec.rqst_num = hr_api.g_number) then
    p_rec.rqst_num :=
    ben_prc_shd.g_old_rec.rqst_num;
  End If;
  If (p_rec.rqst_amt = hr_api.g_number) then
    p_rec.rqst_amt :=
    ben_prc_shd.g_old_rec.rqst_amt;
  End If;
  If (p_rec.rqst_amt_uom = hr_api.g_varchar2) then
    p_rec.rqst_amt_uom :=
    ben_prc_shd.g_old_rec.rqst_amt_uom;
  End If;
  If (p_rec.rqst_btch_num = hr_api.g_number) then
    p_rec.rqst_btch_num :=
    ben_prc_shd.g_old_rec.rqst_btch_num;
  End If;
  If (p_rec.prtt_reimbmt_rqst_stat_cd = hr_api.g_varchar2) then
    p_rec.prtt_reimbmt_rqst_stat_cd :=
    ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd;
  End If;
  If (p_rec.reimbmt_ctfn_typ_prvdd_cd = hr_api.g_varchar2) then
    p_rec.reimbmt_ctfn_typ_prvdd_cd :=
    ben_prc_shd.g_old_rec.reimbmt_ctfn_typ_prvdd_cd;
  End If;
  If (p_rec.rcrrg_cd = hr_api.g_varchar2) then
    p_rec.rcrrg_cd :=
    ben_prc_shd.g_old_rec.rcrrg_cd;
  End If;
  If (p_rec.submitter_person_id = hr_api.g_number) then
    p_rec.submitter_person_id :=
    ben_prc_shd.g_old_rec.submitter_person_id;
  End If;
  If (p_rec.recipient_person_id = hr_api.g_number) then
    p_rec.recipient_person_id :=
    ben_prc_shd.g_old_rec.recipient_person_id;
  End If;
  If (p_rec.provider_person_id = hr_api.g_number) then
    p_rec.provider_person_id :=
    ben_prc_shd.g_old_rec.provider_person_id;
  End If;
  If (p_rec.provider_ssn_person_id = hr_api.g_number) then
    p_rec.provider_ssn_person_id :=
    ben_prc_shd.g_old_rec.provider_ssn_person_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_prc_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.gd_or_svc_typ_id = hr_api.g_number) then
    p_rec.gd_or_svc_typ_id :=
    ben_prc_shd.g_old_rec.gd_or_svc_typ_id;
  End If;
  If (p_rec.contact_relationship_id = hr_api.g_number) then
    p_rec.contact_relationship_id :=
    ben_prc_shd.g_old_rec.contact_relationship_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_prc_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.opt_id = hr_api.g_number) then
    p_rec.opt_id :=
    ben_prc_shd.g_old_rec.opt_id;
  End If;
  If (p_rec.popl_yr_perd_id_1 = hr_api.g_number) then
    p_rec.popl_yr_perd_id_1 :=
    ben_prc_shd.g_old_rec.popl_yr_perd_id_1;
  End If;
  If (p_rec.popl_yr_perd_id_2 = hr_api.g_number) then
    p_rec.popl_yr_perd_id_2 :=
    ben_prc_shd.g_old_rec.popl_yr_perd_id_2;
  End If;
  If (p_rec.amt_year1 = hr_api.g_number) then
    p_rec.amt_year1 :=
    ben_prc_shd.g_old_rec.amt_year1;
  End If;
  If (p_rec.amt_year2 = hr_api.g_number) then
    p_rec.amt_year2 :=
    ben_prc_shd.g_old_rec.amt_year2;
  End If;
  If (p_rec.prc_attribute_category = hr_api.g_varchar2) then
    p_rec.prc_attribute_category :=
    ben_prc_shd.g_old_rec.prc_attribute_category;
  End If;
  If (p_rec.prc_attribute1 = hr_api.g_varchar2) then
    p_rec.prc_attribute1 :=
    ben_prc_shd.g_old_rec.prc_attribute1;
  End If;
  If (p_rec.prc_attribute2 = hr_api.g_varchar2) then
    p_rec.prc_attribute2 :=
    ben_prc_shd.g_old_rec.prc_attribute2;
  End If;
  If (p_rec.prc_attribute3 = hr_api.g_varchar2) then
    p_rec.prc_attribute3 :=
    ben_prc_shd.g_old_rec.prc_attribute3;
  End If;
  If (p_rec.prc_attribute4 = hr_api.g_varchar2) then
    p_rec.prc_attribute4 :=
    ben_prc_shd.g_old_rec.prc_attribute4;
  End If;
  If (p_rec.prc_attribute5 = hr_api.g_varchar2) then
    p_rec.prc_attribute5 :=
    ben_prc_shd.g_old_rec.prc_attribute5;
  End If;
  If (p_rec.prc_attribute6 = hr_api.g_varchar2) then
    p_rec.prc_attribute6 :=
    ben_prc_shd.g_old_rec.prc_attribute6;
  End If;
  If (p_rec.prc_attribute7 = hr_api.g_varchar2) then
    p_rec.prc_attribute7 :=
    ben_prc_shd.g_old_rec.prc_attribute7;
  End If;
  If (p_rec.prc_attribute8 = hr_api.g_varchar2) then
    p_rec.prc_attribute8 :=
    ben_prc_shd.g_old_rec.prc_attribute8;
  End If;
  If (p_rec.prc_attribute9 = hr_api.g_varchar2) then
    p_rec.prc_attribute9 :=
    ben_prc_shd.g_old_rec.prc_attribute9;
  End If;
  If (p_rec.prc_attribute10 = hr_api.g_varchar2) then
    p_rec.prc_attribute10 :=
    ben_prc_shd.g_old_rec.prc_attribute10;
  End If;
  If (p_rec.prc_attribute11 = hr_api.g_varchar2) then
    p_rec.prc_attribute11 :=
    ben_prc_shd.g_old_rec.prc_attribute11;
  End If;
  If (p_rec.prc_attribute12 = hr_api.g_varchar2) then
    p_rec.prc_attribute12 :=
    ben_prc_shd.g_old_rec.prc_attribute12;
  End If;
  If (p_rec.prc_attribute13 = hr_api.g_varchar2) then
    p_rec.prc_attribute13 :=
    ben_prc_shd.g_old_rec.prc_attribute13;
  End If;
  If (p_rec.prc_attribute14 = hr_api.g_varchar2) then
    p_rec.prc_attribute14 :=
    ben_prc_shd.g_old_rec.prc_attribute14;
  End If;
  If (p_rec.prc_attribute15 = hr_api.g_varchar2) then
    p_rec.prc_attribute15 :=
    ben_prc_shd.g_old_rec.prc_attribute15;
  End If;
  If (p_rec.prc_attribute16 = hr_api.g_varchar2) then
    p_rec.prc_attribute16 :=
    ben_prc_shd.g_old_rec.prc_attribute16;
  End If;
  If (p_rec.prc_attribute17 = hr_api.g_varchar2) then
    p_rec.prc_attribute17 :=
    ben_prc_shd.g_old_rec.prc_attribute17;
  End If;
  If (p_rec.prc_attribute18 = hr_api.g_varchar2) then
    p_rec.prc_attribute18 :=
    ben_prc_shd.g_old_rec.prc_attribute18;
  End If;
  If (p_rec.prc_attribute19 = hr_api.g_varchar2) then
    p_rec.prc_attribute19 :=
    ben_prc_shd.g_old_rec.prc_attribute19;
  End If;
  If (p_rec.prc_attribute20 = hr_api.g_varchar2) then
    p_rec.prc_attribute20 :=
    ben_prc_shd.g_old_rec.prc_attribute20;
  End If;
  If (p_rec.prc_attribute21 = hr_api.g_varchar2) then
    p_rec.prc_attribute21 :=
    ben_prc_shd.g_old_rec.prc_attribute21;
  End If;
  If (p_rec.prc_attribute22 = hr_api.g_varchar2) then
    p_rec.prc_attribute22 :=
    ben_prc_shd.g_old_rec.prc_attribute22;
  End If;
  If (p_rec.prc_attribute23 = hr_api.g_varchar2) then
    p_rec.prc_attribute23 :=
    ben_prc_shd.g_old_rec.prc_attribute23;
  End If;
  If (p_rec.prc_attribute24 = hr_api.g_varchar2) then
    p_rec.prc_attribute24 :=
    ben_prc_shd.g_old_rec.prc_attribute24;
  End If;
  If (p_rec.prc_attribute25 = hr_api.g_varchar2) then
    p_rec.prc_attribute25 :=
    ben_prc_shd.g_old_rec.prc_attribute25;
  End If;
  If (p_rec.prc_attribute26 = hr_api.g_varchar2) then
    p_rec.prc_attribute26 :=
    ben_prc_shd.g_old_rec.prc_attribute26;
  End If;
  If (p_rec.prc_attribute27 = hr_api.g_varchar2) then
    p_rec.prc_attribute27 :=
    ben_prc_shd.g_old_rec.prc_attribute27;
  End If;
  If (p_rec.prc_attribute28 = hr_api.g_varchar2) then
    p_rec.prc_attribute28 :=
    ben_prc_shd.g_old_rec.prc_attribute28;
  End If;
  If (p_rec.prc_attribute29 = hr_api.g_varchar2) then
    p_rec.prc_attribute29 :=
    ben_prc_shd.g_old_rec.prc_attribute29;
  End If;
  If (p_rec.prc_attribute30 = hr_api.g_varchar2) then
    p_rec.prc_attribute30 :=
    ben_prc_shd.g_old_rec.prc_attribute30;
  End If;
  If (p_rec.exp_incurd_dt = hr_api.g_date) then
    p_rec.exp_incurd_dt :=
    ben_prc_shd.g_old_rec.exp_incurd_dt;
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
  p_rec			in out nocopy 	ben_prc_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
  ben_prc_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_prtt_reimbmt_rqst_id	 => p_rec.prtt_reimbmt_rqst_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_prc_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
   hr_utility.set_location('after date  check ' || p_rec.prtt_reimbmt_rqst_stat_cd, 110);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_prtt_reimbmt_rqst_id         in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_incrd_from_dt                in date             ,
  p_incrd_to_dt                  in date             ,
  p_rqst_num                     in number           ,
  p_rqst_amt                     in number           ,
  p_rqst_amt_uom                 in varchar2         ,
  p_rqst_btch_num                in number           ,
  p_prtt_reimbmt_rqst_stat_cd    in out nocopy varchar2     ,
  p_reimbmt_ctfn_typ_prvdd_cd    in varchar2         ,
  p_rcrrg_cd                     in varchar2         ,
  p_submitter_person_id          in number           ,
  p_recipient_person_id          in number           ,
  p_provider_person_id           in number           ,
  p_provider_ssn_person_id       in number           ,
  p_pl_id                        in number           ,
  p_gd_or_svc_typ_id             in number           ,
  p_contact_relationship_id      in number           ,
  p_business_group_id            in number           ,
  p_opt_id                         in  number
 ,p_popl_yr_perd_id_1              in  number
 ,p_popl_yr_perd_id_2              in  number
 ,p_amt_year1                      in  number
 ,p_amt_year2                      in  number,
  p_prc_attribute_category       in varchar2         ,
  p_prc_attribute1               in varchar2         ,
  p_prc_attribute2               in varchar2         ,
  p_prc_attribute3               in varchar2         ,
  p_prc_attribute4               in varchar2         ,
  p_prc_attribute5               in varchar2         ,
  p_prc_attribute6               in varchar2         ,
  p_prc_attribute7               in varchar2         ,
  p_prc_attribute8               in varchar2         ,
  p_prc_attribute9               in varchar2         ,
  p_prc_attribute10              in varchar2         ,
  p_prc_attribute11              in varchar2         ,
  p_prc_attribute12              in varchar2         ,
  p_prc_attribute13              in varchar2         ,
  p_prc_attribute14              in varchar2         ,
  p_prc_attribute15              in varchar2         ,
  p_prc_attribute16              in varchar2         ,
  p_prc_attribute17              in varchar2         ,
  p_prc_attribute18              in varchar2         ,
  p_prc_attribute19              in varchar2         ,
  p_prc_attribute20              in varchar2         ,
  p_prc_attribute21              in varchar2         ,
  p_prc_attribute22              in varchar2         ,
  p_prc_attribute23              in varchar2         ,
  p_prc_attribute24              in varchar2         ,
  p_prc_attribute25              in varchar2         ,
  p_prc_attribute26              in varchar2         ,
  p_prc_attribute27              in varchar2         ,
  p_prc_attribute28              in varchar2         ,
  p_prc_attribute29              in varchar2         ,
  p_prc_attribute30              in varchar2         ,
  p_prtt_enrt_rslt_id            in number           ,
  p_comment_id                   in number           ,
  p_object_version_number        in out nocopy number,
  -- Fide enh
  p_stat_rsn_cd                  in out nocopy varchar2  ,
  p_pymt_stat_cd                 in out nocopy varchar2  ,
  p_pymt_stat_rsn_cd             in out nocopy varchar2  ,
  p_stat_ovrdn_flag              in varchar2  ,
  p_stat_ovrdn_rsn_cd            in varchar2  ,
  p_stat_prr_to_ovrd             in varchar2  ,
  p_pymt_stat_ovrdn_flag         in varchar2  ,
  p_pymt_stat_ovrdn_rsn_cd       in varchar2  ,
  p_pymt_stat_prr_to_ovrd        in varchar2  ,
  p_adjmt_flag                   in varchar2  ,
  p_submtd_dt                    in date      ,
  p_ttl_rqst_amt                 in  number    ,
  p_aprvd_for_pymt_amt           in  out nocopy number  ,
  p_pymt_amount                  out nocopy number ,
  p_exp_incurd_dt		 in date      ,
  -- Fide enh
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_prc_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_prc_shd.convert_args
  (
  p_prtt_reimbmt_rqst_id,
  null,
  null,
  p_incrd_from_dt,
  p_incrd_to_dt,
  p_rqst_num,
  p_rqst_amt,
  p_rqst_amt_uom,
  p_rqst_btch_num,
  p_prtt_reimbmt_rqst_stat_cd,
  p_reimbmt_ctfn_typ_prvdd_cd,
  p_rcrrg_cd,
  p_submitter_person_id,
  p_recipient_person_id,
  p_provider_person_id,
  p_provider_ssn_person_id,
  p_pl_id,
  p_gd_or_svc_typ_id,
  p_contact_relationship_id,
  p_business_group_id,
  p_opt_id,
  p_popl_yr_perd_id_1,
  p_popl_yr_perd_id_2,
  p_amt_year1,
  p_amt_year2 ,
  p_prc_attribute_category,
  p_prc_attribute1,
  p_prc_attribute2,
  p_prc_attribute3,
  p_prc_attribute4,
  p_prc_attribute5,
  p_prc_attribute6,
  p_prc_attribute7,
  p_prc_attribute8,
  p_prc_attribute9,
  p_prc_attribute10,
  p_prc_attribute11,
  p_prc_attribute12,
  p_prc_attribute13,
  p_prc_attribute14,
  p_prc_attribute15,
  p_prc_attribute16,
  p_prc_attribute17,
  p_prc_attribute18,
  p_prc_attribute19,
  p_prc_attribute20,
  p_prc_attribute21,
  p_prc_attribute22,
  p_prc_attribute23,
  p_prc_attribute24,
  p_prc_attribute25,
  p_prc_attribute26,
  p_prc_attribute27,
  p_prc_attribute28,
  p_prc_attribute29,
  p_prc_attribute30,
  p_prtt_enrt_rslt_id,
  p_comment_id       ,
  p_object_version_number ,
  p_stat_rsn_cd,
  p_pymt_stat_cd,
  p_pymt_stat_rsn_cd,
  p_stat_ovrdn_flag,
  p_stat_ovrdn_rsn_cd,
  p_stat_prr_to_ovrd,
  p_pymt_stat_ovrdn_flag,
  p_pymt_stat_ovrdn_rsn_cd,
  p_pymt_stat_prr_to_ovrd,
  p_adjmt_flag,
  p_submtd_dt,
  p_ttl_rqst_amt,
  p_aprvd_for_pymt_amt,
  null ,
  p_exp_incurd_dt
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);

  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  p_prtt_reimbmt_rqst_Stat_cd   := l_rec.prtt_reimbmt_rqst_Stat_cd;
  p_stat_rsn_cd                 := l_rec.stat_rsn_cd ;
  p_pymt_stat_rsn_cd            := l_rec.pymt_stat_rsn_cd;
  p_pymt_stat_cd                := l_rec.pymt_stat_cd ;
  p_pymt_amount                 := l_rec.pymt_amount ;
  p_aprvd_for_pymt_amt          := l_rec.aprvd_for_pymt_amt ;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_prc_upd;

/
