--------------------------------------------------------
--  DDL for Package Body BEN_CRT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_UPD" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crt_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_crt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_crt_ordr Row
  --
  update ben_crt_ordr
  set
  crt_ordr_id                       = p_rec.crt_ordr_id,
  crt_ordr_typ_cd                   = p_rec.crt_ordr_typ_cd,
  apls_perd_endg_dt                 = p_rec.apls_perd_endg_dt,
  apls_perd_strtg_dt                = p_rec.apls_perd_strtg_dt,
  crt_ident                         = p_rec.crt_ident,
  description                       = p_rec.description,
  detd_qlfd_ordr_dt                 = p_rec.detd_qlfd_ordr_dt,
  issue_dt                          = p_rec.issue_dt,
  qdro_amt                          = p_rec.qdro_amt,
  qdro_dstr_mthd_cd                 = p_rec.qdro_dstr_mthd_cd,
  qdro_pct                          = p_rec.qdro_pct,
  rcvd_dt                           = p_rec.rcvd_dt,
  uom                               = p_rec.uom,
  crt_issng                         = p_rec.crt_issng,
  pl_id                             = p_rec.pl_id,
  person_id                         = p_rec.person_id,
  business_group_id                 = p_rec.business_group_id,
  crt_attribute_category            = p_rec.crt_attribute_category,
  crt_attribute1                    = p_rec.crt_attribute1,
  crt_attribute2                    = p_rec.crt_attribute2,
  crt_attribute3                    = p_rec.crt_attribute3,
  crt_attribute4                    = p_rec.crt_attribute4,
  crt_attribute5                    = p_rec.crt_attribute5,
  crt_attribute6                    = p_rec.crt_attribute6,
  crt_attribute7                    = p_rec.crt_attribute7,
  crt_attribute8                    = p_rec.crt_attribute8,
  crt_attribute9                    = p_rec.crt_attribute9,
  crt_attribute10                   = p_rec.crt_attribute10,
  crt_attribute11                   = p_rec.crt_attribute11,
  crt_attribute12                   = p_rec.crt_attribute12,
  crt_attribute13                   = p_rec.crt_attribute13,
  crt_attribute14                   = p_rec.crt_attribute14,
  crt_attribute15                   = p_rec.crt_attribute15,
  crt_attribute16                   = p_rec.crt_attribute16,
  crt_attribute17                   = p_rec.crt_attribute17,
  crt_attribute18                   = p_rec.crt_attribute18,
  crt_attribute19                   = p_rec.crt_attribute19,
  crt_attribute20                   = p_rec.crt_attribute20,
  crt_attribute21                   = p_rec.crt_attribute21,
  crt_attribute22                   = p_rec.crt_attribute22,
  crt_attribute23                   = p_rec.crt_attribute23,
  crt_attribute24                   = p_rec.crt_attribute24,
  crt_attribute25                   = p_rec.crt_attribute25,
  crt_attribute26                   = p_rec.crt_attribute26,
  crt_attribute27                   = p_rec.crt_attribute27,
  crt_attribute28                   = p_rec.crt_attribute28,
  crt_attribute29                   = p_rec.crt_attribute29,
  crt_attribute30                   = p_rec.crt_attribute30,
  object_version_number             = p_rec.object_version_number,
  qdro_num_pymt_val                 = p_rec.qdro_num_pymt_val,
  qdro_per_perd_cd                  = p_rec.qdro_per_perd_cd,
  pl_typ_id                         = p_rec.pl_typ_id
  where crt_ordr_id = p_rec.crt_ordr_id;
  --
  ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure post_update( p_effective_date in date,p_rec in ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_old_rec ben_crt_ler.g_crt_ler_rec  ;
  l_new_rec ben_crt_ler.g_crt_ler_rec  ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
  l_old_rec.business_group_id    := ben_crt_shd.g_old_rec.business_group_id;
  l_old_rec.person_id            := ben_crt_shd.g_old_rec.person_id;
  l_old_rec.apls_perd_strtg_dt   := ben_crt_shd.g_old_rec.apls_perd_strtg_dt;
  l_old_rec.apls_perd_endg_dt    := ben_crt_shd.g_old_rec.apls_perd_endg_dt;
  l_old_rec.crt_ordr_typ_cd      := ben_crt_shd.g_old_rec.crt_ordr_typ_cd;
  l_old_rec.rcvd_dt              := ben_crt_shd.g_old_rec.rcvd_dt;
  l_old_rec.pl_id                := ben_crt_shd.g_old_rec.pl_id;
  l_old_rec.pl_typ_id            := ben_crt_shd.g_old_rec.pl_typ_id;
  l_new_rec.business_group_id := p_rec.business_group_id;
  l_new_rec.person_id         := p_rec.person_id;
  l_new_rec.apls_perd_strtg_dt:= p_rec.apls_perd_strtg_dt;
  l_new_rec.apls_perd_endg_dt := p_rec.apls_perd_endg_dt;
  l_new_rec.crt_ordr_typ_cd   := p_rec.crt_ordr_typ_cd;
  l_new_rec.rcvd_dt           := p_rec.rcvd_dt;
  l_new_rec.pl_id             := p_rec.pl_id;
  l_new_rec.pl_typ_id         := p_rec.pl_typ_id;
  l_new_rec.crt_ordr_id       := p_rec.crt_ordr_id;
  --
  ben_crt_rku.after_update
      (
  p_crt_ordr_id                   =>p_rec.crt_ordr_id
 ,p_crt_ordr_typ_cd               =>p_rec.crt_ordr_typ_cd
 ,p_apls_perd_endg_dt             =>p_rec.apls_perd_endg_dt
 ,p_apls_perd_strtg_dt            =>p_rec.apls_perd_strtg_dt
 ,p_crt_ident                     =>p_rec.crt_ident
 ,p_description                   =>p_rec.description
 ,p_detd_qlfd_ordr_dt             =>p_rec.detd_qlfd_ordr_dt
 ,p_issue_dt                      =>p_rec.issue_dt
 ,p_qdro_amt                      =>p_rec.qdro_amt
 ,p_qdro_dstr_mthd_cd             =>p_rec.qdro_dstr_mthd_cd
 ,p_qdro_pct                      =>p_rec.qdro_pct
 ,p_rcvd_dt                       =>p_rec.rcvd_dt
 ,p_uom                           =>p_rec.uom
 ,p_crt_issng                     =>p_rec.crt_issng
 ,p_pl_id                         =>p_rec.pl_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_crt_attribute_category        =>p_rec.crt_attribute_category
 ,p_crt_attribute1                =>p_rec.crt_attribute1
 ,p_crt_attribute2                =>p_rec.crt_attribute2
 ,p_crt_attribute3                =>p_rec.crt_attribute3
 ,p_crt_attribute4                =>p_rec.crt_attribute4
 ,p_crt_attribute5                =>p_rec.crt_attribute5
 ,p_crt_attribute6                =>p_rec.crt_attribute6
 ,p_crt_attribute7                =>p_rec.crt_attribute7
 ,p_crt_attribute8                =>p_rec.crt_attribute8
 ,p_crt_attribute9                =>p_rec.crt_attribute9
 ,p_crt_attribute10               =>p_rec.crt_attribute10
 ,p_crt_attribute11               =>p_rec.crt_attribute11
 ,p_crt_attribute12               =>p_rec.crt_attribute12
 ,p_crt_attribute13               =>p_rec.crt_attribute13
 ,p_crt_attribute14               =>p_rec.crt_attribute14
 ,p_crt_attribute15               =>p_rec.crt_attribute15
 ,p_crt_attribute16               =>p_rec.crt_attribute16
 ,p_crt_attribute17               =>p_rec.crt_attribute17
 ,p_crt_attribute18               =>p_rec.crt_attribute18
 ,p_crt_attribute19               =>p_rec.crt_attribute19
 ,p_crt_attribute20               =>p_rec.crt_attribute20
 ,p_crt_attribute21               =>p_rec.crt_attribute21
 ,p_crt_attribute22               =>p_rec.crt_attribute22
 ,p_crt_attribute23               =>p_rec.crt_attribute23
 ,p_crt_attribute24               =>p_rec.crt_attribute24
 ,p_crt_attribute25               =>p_rec.crt_attribute25
 ,p_crt_attribute26               =>p_rec.crt_attribute26
 ,p_crt_attribute27               =>p_rec.crt_attribute27
 ,p_crt_attribute28               =>p_rec.crt_attribute28
 ,p_crt_attribute29               =>p_rec.crt_attribute29
 ,p_crt_attribute30               =>p_rec.crt_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_qdro_num_pymt_val             =>p_rec.qdro_num_pymt_val
 ,p_qdro_per_perd_cd              =>p_rec.qdro_per_perd_cd
 ,p_pl_typ_id                     =>p_rec.pl_typ_id
 ,p_effective_date                =>p_effective_date
 ,p_crt_ordr_typ_cd_o             =>ben_crt_shd.g_old_rec.crt_ordr_typ_cd
 ,p_apls_perd_endg_dt_o           =>ben_crt_shd.g_old_rec.apls_perd_endg_dt
 ,p_apls_perd_strtg_dt_o          =>ben_crt_shd.g_old_rec.apls_perd_strtg_dt
 ,p_crt_ident_o                   =>ben_crt_shd.g_old_rec.crt_ident
 ,p_description_o                 =>ben_crt_shd.g_old_rec.description
 ,p_detd_qlfd_ordr_dt_o           =>ben_crt_shd.g_old_rec.detd_qlfd_ordr_dt
 ,p_issue_dt_o                    =>ben_crt_shd.g_old_rec.issue_dt
 ,p_qdro_amt_o                    =>ben_crt_shd.g_old_rec.qdro_amt
 ,p_qdro_dstr_mthd_cd_o           =>ben_crt_shd.g_old_rec.qdro_dstr_mthd_cd
 ,p_qdro_pct_o                    =>ben_crt_shd.g_old_rec.qdro_pct
 ,p_rcvd_dt_o                     =>ben_crt_shd.g_old_rec.rcvd_dt
 ,p_uom_o                         =>ben_crt_shd.g_old_rec.uom
 ,p_crt_issng_o                   =>ben_crt_shd.g_old_rec.crt_issng
 ,p_pl_id_o                       =>ben_crt_shd.g_old_rec.pl_id
 ,p_person_id_o                   =>ben_crt_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_crt_shd.g_old_rec.business_group_id
 ,p_crt_attribute_category_o      =>ben_crt_shd.g_old_rec.crt_attribute_category
 ,p_crt_attribute1_o              =>ben_crt_shd.g_old_rec.crt_attribute1
 ,p_crt_attribute2_o              =>ben_crt_shd.g_old_rec.crt_attribute2
 ,p_crt_attribute3_o              =>ben_crt_shd.g_old_rec.crt_attribute3
 ,p_crt_attribute4_o              =>ben_crt_shd.g_old_rec.crt_attribute4
 ,p_crt_attribute5_o              =>ben_crt_shd.g_old_rec.crt_attribute5
 ,p_crt_attribute6_o              =>ben_crt_shd.g_old_rec.crt_attribute6
 ,p_crt_attribute7_o              =>ben_crt_shd.g_old_rec.crt_attribute7
 ,p_crt_attribute8_o              =>ben_crt_shd.g_old_rec.crt_attribute8
 ,p_crt_attribute9_o              =>ben_crt_shd.g_old_rec.crt_attribute9
 ,p_crt_attribute10_o             =>ben_crt_shd.g_old_rec.crt_attribute10
 ,p_crt_attribute11_o             =>ben_crt_shd.g_old_rec.crt_attribute11
 ,p_crt_attribute12_o             =>ben_crt_shd.g_old_rec.crt_attribute12
 ,p_crt_attribute13_o             =>ben_crt_shd.g_old_rec.crt_attribute13
 ,p_crt_attribute14_o             =>ben_crt_shd.g_old_rec.crt_attribute14
 ,p_crt_attribute15_o             =>ben_crt_shd.g_old_rec.crt_attribute15
 ,p_crt_attribute16_o             =>ben_crt_shd.g_old_rec.crt_attribute16
 ,p_crt_attribute17_o             =>ben_crt_shd.g_old_rec.crt_attribute17
 ,p_crt_attribute18_o             =>ben_crt_shd.g_old_rec.crt_attribute18
 ,p_crt_attribute19_o             =>ben_crt_shd.g_old_rec.crt_attribute19
 ,p_crt_attribute20_o             =>ben_crt_shd.g_old_rec.crt_attribute20
 ,p_crt_attribute21_o             =>ben_crt_shd.g_old_rec.crt_attribute21
 ,p_crt_attribute22_o             =>ben_crt_shd.g_old_rec.crt_attribute22
 ,p_crt_attribute23_o             =>ben_crt_shd.g_old_rec.crt_attribute23
 ,p_crt_attribute24_o             =>ben_crt_shd.g_old_rec.crt_attribute24
 ,p_crt_attribute25_o             =>ben_crt_shd.g_old_rec.crt_attribute25
 ,p_crt_attribute26_o             =>ben_crt_shd.g_old_rec.crt_attribute26
 ,p_crt_attribute27_o             =>ben_crt_shd.g_old_rec.crt_attribute27
 ,p_crt_attribute28_o             =>ben_crt_shd.g_old_rec.crt_attribute28
 ,p_crt_attribute29_o             =>ben_crt_shd.g_old_rec.crt_attribute29
 ,p_crt_attribute30_o             =>ben_crt_shd.g_old_rec.crt_attribute30
 ,p_object_version_number_o       =>ben_crt_shd.g_old_rec.object_version_number
 ,p_qdro_num_pymt_val_o           =>ben_crt_shd.g_old_rec.qdro_num_pymt_val
 ,p_qdro_per_perd_cd_o            =>ben_crt_shd.g_old_rec.qdro_per_perd_cd
 ,p_pl_typ_id_o                   =>ben_crt_shd.g_old_rec.pl_typ_id
      );
  --
  hr_utility.set_location('D M Modie crt ' ||hr_general.g_data_migrator_mode , 378);
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
      hr_utility.set_location(' calling ler check in update  ' , 1408379 );
      --for bug 1408379 the call for this functiom moved from trigger
      ben_crt_ler.ler_chk(p_old => l_old_rec,
                      p_new => l_new_rec ,
                      p_effective_date => p_effective_date  );
   End if ;
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_crt_ordr'
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
Procedure convert_defs(p_rec in out nocopy ben_crt_shd.g_rec_type) is
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
  If (p_rec.crt_ordr_typ_cd = hr_api.g_varchar2) then
    p_rec.crt_ordr_typ_cd :=
    ben_crt_shd.g_old_rec.crt_ordr_typ_cd;
  End If;
  If (p_rec.apls_perd_endg_dt = hr_api.g_date) then
    p_rec.apls_perd_endg_dt :=
    ben_crt_shd.g_old_rec.apls_perd_endg_dt;
  End If;
  If (p_rec.apls_perd_strtg_dt = hr_api.g_date) then
    p_rec.apls_perd_strtg_dt :=
    ben_crt_shd.g_old_rec.apls_perd_strtg_dt;
  End If;
  If (p_rec.crt_ident = hr_api.g_varchar2) then
    p_rec.crt_ident :=
    ben_crt_shd.g_old_rec.crt_ident;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    ben_crt_shd.g_old_rec.description;
  End If;
  If (p_rec.detd_qlfd_ordr_dt = hr_api.g_date) then
    p_rec.detd_qlfd_ordr_dt :=
    ben_crt_shd.g_old_rec.detd_qlfd_ordr_dt;
  End If;
  If (p_rec.issue_dt = hr_api.g_date) then
    p_rec.issue_dt :=
    ben_crt_shd.g_old_rec.issue_dt;
  End If;
  If (p_rec.qdro_amt = hr_api.g_number) then
    p_rec.qdro_amt :=
    ben_crt_shd.g_old_rec.qdro_amt;
  End If;
  If (p_rec.qdro_dstr_mthd_cd = hr_api.g_varchar2) then
    p_rec.qdro_dstr_mthd_cd :=
    ben_crt_shd.g_old_rec.qdro_dstr_mthd_cd;
  End If;
  If (p_rec.qdro_pct = hr_api.g_number) then
    p_rec.qdro_pct :=
    ben_crt_shd.g_old_rec.qdro_pct;
  End If;
  If (p_rec.rcvd_dt = hr_api.g_date) then
    p_rec.rcvd_dt :=
    ben_crt_shd.g_old_rec.rcvd_dt;
  End If;
  If (p_rec.uom = hr_api.g_varchar2) then
    p_rec.uom :=
    ben_crt_shd.g_old_rec.uom;
  End If;
  If (p_rec.crt_issng = hr_api.g_varchar2) then
    p_rec.crt_issng :=
    ben_crt_shd.g_old_rec.crt_issng;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_crt_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_crt_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_crt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.crt_attribute_category = hr_api.g_varchar2) then
    p_rec.crt_attribute_category :=
    ben_crt_shd.g_old_rec.crt_attribute_category;
  End If;
  If (p_rec.crt_attribute1 = hr_api.g_varchar2) then
    p_rec.crt_attribute1 :=
    ben_crt_shd.g_old_rec.crt_attribute1;
  End If;
  If (p_rec.crt_attribute2 = hr_api.g_varchar2) then
    p_rec.crt_attribute2 :=
    ben_crt_shd.g_old_rec.crt_attribute2;
  End If;
  If (p_rec.crt_attribute3 = hr_api.g_varchar2) then
    p_rec.crt_attribute3 :=
    ben_crt_shd.g_old_rec.crt_attribute3;
  End If;
  If (p_rec.crt_attribute4 = hr_api.g_varchar2) then
    p_rec.crt_attribute4 :=
    ben_crt_shd.g_old_rec.crt_attribute4;
  End If;
  If (p_rec.crt_attribute5 = hr_api.g_varchar2) then
    p_rec.crt_attribute5 :=
    ben_crt_shd.g_old_rec.crt_attribute5;
  End If;
  If (p_rec.crt_attribute6 = hr_api.g_varchar2) then
    p_rec.crt_attribute6 :=
    ben_crt_shd.g_old_rec.crt_attribute6;
  End If;
  If (p_rec.crt_attribute7 = hr_api.g_varchar2) then
    p_rec.crt_attribute7 :=
    ben_crt_shd.g_old_rec.crt_attribute7;
  End If;
  If (p_rec.crt_attribute8 = hr_api.g_varchar2) then
    p_rec.crt_attribute8 :=
    ben_crt_shd.g_old_rec.crt_attribute8;
  End If;
  If (p_rec.crt_attribute9 = hr_api.g_varchar2) then
    p_rec.crt_attribute9 :=
    ben_crt_shd.g_old_rec.crt_attribute9;
  End If;
  If (p_rec.crt_attribute10 = hr_api.g_varchar2) then
    p_rec.crt_attribute10 :=
    ben_crt_shd.g_old_rec.crt_attribute10;
  End If;
  If (p_rec.crt_attribute11 = hr_api.g_varchar2) then
    p_rec.crt_attribute11 :=
    ben_crt_shd.g_old_rec.crt_attribute11;
  End If;
  If (p_rec.crt_attribute12 = hr_api.g_varchar2) then
    p_rec.crt_attribute12 :=
    ben_crt_shd.g_old_rec.crt_attribute12;
  End If;
  If (p_rec.crt_attribute13 = hr_api.g_varchar2) then
    p_rec.crt_attribute13 :=
    ben_crt_shd.g_old_rec.crt_attribute13;
  End If;
  If (p_rec.crt_attribute14 = hr_api.g_varchar2) then
    p_rec.crt_attribute14 :=
    ben_crt_shd.g_old_rec.crt_attribute14;
  End If;
  If (p_rec.crt_attribute15 = hr_api.g_varchar2) then
    p_rec.crt_attribute15 :=
    ben_crt_shd.g_old_rec.crt_attribute15;
  End If;
  If (p_rec.crt_attribute16 = hr_api.g_varchar2) then
    p_rec.crt_attribute16 :=
    ben_crt_shd.g_old_rec.crt_attribute16;
  End If;
  If (p_rec.crt_attribute17 = hr_api.g_varchar2) then
    p_rec.crt_attribute17 :=
    ben_crt_shd.g_old_rec.crt_attribute17;
  End If;
  If (p_rec.crt_attribute18 = hr_api.g_varchar2) then
    p_rec.crt_attribute18 :=
    ben_crt_shd.g_old_rec.crt_attribute18;
  End If;
  If (p_rec.crt_attribute19 = hr_api.g_varchar2) then
    p_rec.crt_attribute19 :=
    ben_crt_shd.g_old_rec.crt_attribute19;
  End If;
  If (p_rec.crt_attribute20 = hr_api.g_varchar2) then
    p_rec.crt_attribute20 :=
    ben_crt_shd.g_old_rec.crt_attribute20;
  End If;
  If (p_rec.crt_attribute21 = hr_api.g_varchar2) then
    p_rec.crt_attribute21 :=
    ben_crt_shd.g_old_rec.crt_attribute21;
  End If;
  If (p_rec.crt_attribute22 = hr_api.g_varchar2) then
    p_rec.crt_attribute22 :=
    ben_crt_shd.g_old_rec.crt_attribute22;
  End If;
  If (p_rec.crt_attribute23 = hr_api.g_varchar2) then
    p_rec.crt_attribute23 :=
    ben_crt_shd.g_old_rec.crt_attribute23;
  End If;
  If (p_rec.crt_attribute24 = hr_api.g_varchar2) then
    p_rec.crt_attribute24 :=
    ben_crt_shd.g_old_rec.crt_attribute24;
  End If;
  If (p_rec.crt_attribute25 = hr_api.g_varchar2) then
    p_rec.crt_attribute25 :=
    ben_crt_shd.g_old_rec.crt_attribute25;
  End If;
  If (p_rec.crt_attribute26 = hr_api.g_varchar2) then
    p_rec.crt_attribute26 :=
    ben_crt_shd.g_old_rec.crt_attribute26;
  End If;
  If (p_rec.crt_attribute27 = hr_api.g_varchar2) then
    p_rec.crt_attribute27 :=
    ben_crt_shd.g_old_rec.crt_attribute27;
  End If;
  If (p_rec.crt_attribute28 = hr_api.g_varchar2) then
    p_rec.crt_attribute28 :=
    ben_crt_shd.g_old_rec.crt_attribute28;
  End If;
  If (p_rec.crt_attribute29 = hr_api.g_varchar2) then
    p_rec.crt_attribute29 :=
    ben_crt_shd.g_old_rec.crt_attribute29;
  End If;
  If (p_rec.crt_attribute30 = hr_api.g_varchar2) then
    p_rec.crt_attribute30 :=
    ben_crt_shd.g_old_rec.crt_attribute30;
  End If;
  If (p_rec.qdro_num_pymt_val = hr_api.g_number) then
    p_rec.qdro_num_pymt_val :=
    ben_crt_shd.g_old_rec.qdro_num_pymt_val;
  End If;
  If (p_rec.qdro_per_perd_cd = hr_api.g_varchar2) then
    p_rec.qdro_per_perd_cd :=
    ben_crt_shd.g_old_rec.qdro_per_perd_cd;
  End If;
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_crt_shd.g_old_rec.pl_typ_id;
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
  p_effective_date in date,
  p_rec        in out nocopy ben_crt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  ---
  ben_crt_shd.lck
	(
	p_rec.crt_ordr_id,
	p_rec.object_version_number
	);


  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_crt_bus.update_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update( p_effective_date,p_rec);


End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_crt_ordr_id                  in number,
  p_crt_ordr_typ_cd              in varchar2         default hr_api.g_varchar2,
  p_apls_perd_endg_dt            in date             default hr_api.g_date,
  p_apls_perd_strtg_dt           in date             default hr_api.g_date,
  p_crt_ident                    in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_detd_qlfd_ordr_dt            in date             default hr_api.g_date,
  p_issue_dt                     in date             default hr_api.g_date,
  p_qdro_amt                     in number           default hr_api.g_number,
  p_qdro_dstr_mthd_cd            in varchar2         default hr_api.g_varchar2,
  p_qdro_pct                     in number           default hr_api.g_number,
  p_rcvd_dt                      in date             default hr_api.g_date,
  p_uom                          in varchar2         default hr_api.g_varchar2,
  p_crt_issng                    in varchar2         default hr_api.g_varchar2,
  p_pl_id                        in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_crt_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_crt_attribute1               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute2               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute3               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute4               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute5               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute6               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute7               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute8               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute9               in varchar2         default hr_api.g_varchar2,
  p_crt_attribute10              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute11              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute12              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute13              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute14              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute15              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute16              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute17              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute18              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute19              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute20              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute21              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute22              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute23              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute24              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute25              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute26              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute27              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute28              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute29              in varchar2         default hr_api.g_varchar2,
  p_crt_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_qdro_num_pymt_val            in number           default hr_api.g_number,
  p_qdro_per_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_pl_typ_id                    in number           default hr_api.g_number
  ) is
--
  l_rec	  ben_crt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_crt_shd.convert_args
  (
  p_crt_ordr_id,
  p_crt_ordr_typ_cd,
  p_apls_perd_endg_dt,
  p_apls_perd_strtg_dt,
  p_crt_ident,
  p_description,
  p_detd_qlfd_ordr_dt,
  p_issue_dt,
  p_qdro_amt,
  p_qdro_dstr_mthd_cd,
  p_qdro_pct,
  p_rcvd_dt,
  p_uom,
  p_crt_issng,
  p_pl_id,
  p_person_id,
  p_business_group_id,
  p_crt_attribute_category,
  p_crt_attribute1,
  p_crt_attribute2,
  p_crt_attribute3,
  p_crt_attribute4,
  p_crt_attribute5,
  p_crt_attribute6,
  p_crt_attribute7,
  p_crt_attribute8,
  p_crt_attribute9,
  p_crt_attribute10,
  p_crt_attribute11,
  p_crt_attribute12,
  p_crt_attribute13,
  p_crt_attribute14,
  p_crt_attribute15,
  p_crt_attribute16,
  p_crt_attribute17,
  p_crt_attribute18,
  p_crt_attribute19,
  p_crt_attribute20,
  p_crt_attribute21,
  p_crt_attribute22,
  p_crt_attribute23,
  p_crt_attribute24,
  p_crt_attribute25,
  p_crt_attribute26,
  p_crt_attribute27,
  p_crt_attribute28,
  p_crt_attribute29,
  p_crt_attribute30,
  p_object_version_number,
  p_qdro_num_pymt_val,
  p_qdro_per_perd_cd,
  p_pl_typ_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_crt_upd;

/
