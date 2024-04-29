--------------------------------------------------------
--  DDL for Package Body PQH_PLG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PLG_UPD" as
/* $Header: pqplgrhi.pkb 115.5 2002/12/12 23:13:49 sgoyal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_plg_upd.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
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
Procedure update_dml(p_rec in out nocopy pqh_plg_shd.g_rec_type) is
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
  --
  -- Update the pqh_process_log Row
  --
  update pqh_process_log
  set
  process_log_id                    = p_rec.process_log_id,
  module_cd                         = p_rec.module_cd,
  txn_id                            = p_rec.txn_id,
  master_process_log_id             = p_rec.master_process_log_id,
  message_text                      = p_rec.message_text,
  message_type_cd                   = p_rec.message_type_cd,
  batch_status                      = p_rec.batch_status,
  batch_start_date                  = p_rec.batch_start_date,
  batch_end_date                    = p_rec.batch_end_date,
  txn_table_route_id                = p_rec.txn_table_route_id,
  log_context                       = p_rec.log_context,
  information_category              = p_rec.information_category,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  information21                     = p_rec.information21,
  information22                     = p_rec.information22,
  information23                     = p_rec.information23,
  information24                     = p_rec.information24,
  information25                     = p_rec.information25,
  information26                     = p_rec.information26,
  information27                     = p_rec.information27,
  information28                     = p_rec.information28,
  information29                     = p_rec.information29,
  information30                     = p_rec.information30,
  object_version_number             = p_rec.object_version_number
  where process_log_id = p_rec.process_log_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_plg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_plg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_plg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_update(p_rec in pqh_plg_shd.g_rec_type) is
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
Procedure post_update(
p_effective_date in date,p_rec in pqh_plg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_plg_rku.after_update
      (
  p_process_log_id                =>p_rec.process_log_id
 ,p_module_cd                     =>p_rec.module_cd
 ,p_txn_id                        =>p_rec.txn_id
 ,p_master_process_log_id         =>p_rec.master_process_log_id
 ,p_message_text                  =>p_rec.message_text
 ,p_message_type_cd               =>p_rec.message_type_cd
 ,p_batch_status                  =>p_rec.batch_status
 ,p_batch_start_date              =>p_rec.batch_start_date
 ,p_batch_end_date                =>p_rec.batch_end_date
 ,p_txn_table_route_id            =>p_rec.txn_table_route_id
 ,p_log_context                   =>p_rec.log_context
 ,p_information_category          =>p_rec.information_category
 ,p_information1                  =>p_rec.information1
 ,p_information2                  =>p_rec.information2
 ,p_information3                  =>p_rec.information3
 ,p_information4                  =>p_rec.information4
 ,p_information5                  =>p_rec.information5
 ,p_information6                  =>p_rec.information6
 ,p_information7                  =>p_rec.information7
 ,p_information8                  =>p_rec.information8
 ,p_information9                  =>p_rec.information9
 ,p_information10                 =>p_rec.information10
 ,p_information11                 =>p_rec.information11
 ,p_information12                 =>p_rec.information12
 ,p_information13                 =>p_rec.information13
 ,p_information14                 =>p_rec.information14
 ,p_information15                 =>p_rec.information15
 ,p_information16                 =>p_rec.information16
 ,p_information17                 =>p_rec.information17
 ,p_information18                 =>p_rec.information18
 ,p_information19                 =>p_rec.information19
 ,p_information20                 =>p_rec.information20
 ,p_information21                 =>p_rec.information21
 ,p_information22                 =>p_rec.information22
 ,p_information23                 =>p_rec.information23
 ,p_information24                 =>p_rec.information24
 ,p_information25                 =>p_rec.information25
 ,p_information26                 =>p_rec.information26
 ,p_information27                 =>p_rec.information27
 ,p_information28                 =>p_rec.information28
 ,p_information29                 =>p_rec.information29
 ,p_information30                 =>p_rec.information30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_module_cd_o                   =>pqh_plg_shd.g_old_rec.module_cd
 ,p_txn_id_o                      =>pqh_plg_shd.g_old_rec.txn_id
 ,p_master_process_log_id_o       =>pqh_plg_shd.g_old_rec.master_process_log_id
 ,p_message_text_o                =>pqh_plg_shd.g_old_rec.message_text
 ,p_message_type_cd_o             =>pqh_plg_shd.g_old_rec.message_type_cd
 ,p_batch_status_o                =>pqh_plg_shd.g_old_rec.batch_status
 ,p_batch_start_date_o            =>pqh_plg_shd.g_old_rec.batch_start_date
 ,p_batch_end_date_o              =>pqh_plg_shd.g_old_rec.batch_end_date
 ,p_txn_table_route_id_o          =>pqh_plg_shd.g_old_rec.txn_table_route_id
 ,p_log_context_o                 =>pqh_plg_shd.g_old_rec.log_context
 ,p_information_category_o        =>pqh_plg_shd.g_old_rec.information_category
 ,p_information1_o                =>pqh_plg_shd.g_old_rec.information1
 ,p_information2_o                =>pqh_plg_shd.g_old_rec.information2
 ,p_information3_o                =>pqh_plg_shd.g_old_rec.information3
 ,p_information4_o                =>pqh_plg_shd.g_old_rec.information4
 ,p_information5_o                =>pqh_plg_shd.g_old_rec.information5
 ,p_information6_o                =>pqh_plg_shd.g_old_rec.information6
 ,p_information7_o                =>pqh_plg_shd.g_old_rec.information7
 ,p_information8_o                =>pqh_plg_shd.g_old_rec.information8
 ,p_information9_o                =>pqh_plg_shd.g_old_rec.information9
 ,p_information10_o               =>pqh_plg_shd.g_old_rec.information10
 ,p_information11_o               =>pqh_plg_shd.g_old_rec.information11
 ,p_information12_o               =>pqh_plg_shd.g_old_rec.information12
 ,p_information13_o               =>pqh_plg_shd.g_old_rec.information13
 ,p_information14_o               =>pqh_plg_shd.g_old_rec.information14
 ,p_information15_o               =>pqh_plg_shd.g_old_rec.information15
 ,p_information16_o               =>pqh_plg_shd.g_old_rec.information16
 ,p_information17_o               =>pqh_plg_shd.g_old_rec.information17
 ,p_information18_o               =>pqh_plg_shd.g_old_rec.information18
 ,p_information19_o               =>pqh_plg_shd.g_old_rec.information19
 ,p_information20_o               =>pqh_plg_shd.g_old_rec.information20
 ,p_information21_o               =>pqh_plg_shd.g_old_rec.information21
 ,p_information22_o               =>pqh_plg_shd.g_old_rec.information22
 ,p_information23_o               =>pqh_plg_shd.g_old_rec.information23
 ,p_information24_o               =>pqh_plg_shd.g_old_rec.information24
 ,p_information25_o               =>pqh_plg_shd.g_old_rec.information25
 ,p_information26_o               =>pqh_plg_shd.g_old_rec.information26
 ,p_information27_o               =>pqh_plg_shd.g_old_rec.information27
 ,p_information28_o               =>pqh_plg_shd.g_old_rec.information28
 ,p_information29_o               =>pqh_plg_shd.g_old_rec.information29
 ,p_information30_o               =>pqh_plg_shd.g_old_rec.information30
 ,p_object_version_number_o       =>pqh_plg_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_process_log'
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
Procedure convert_defs(p_rec in out nocopy pqh_plg_shd.g_rec_type) is
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
  If (p_rec.module_cd = hr_api.g_varchar2) then
    p_rec.module_cd :=
    pqh_plg_shd.g_old_rec.module_cd;
  End If;
  If (p_rec.txn_id = hr_api.g_number) then
    p_rec.txn_id :=
    pqh_plg_shd.g_old_rec.txn_id;
  End If;
  If (p_rec.master_process_log_id = hr_api.g_number) then
    p_rec.master_process_log_id :=
    pqh_plg_shd.g_old_rec.master_process_log_id;
  End If;
  If (p_rec.message_text = hr_api.g_varchar2) then
    p_rec.message_text :=
    pqh_plg_shd.g_old_rec.message_text;
  End If;
  If (p_rec.message_type_cd = hr_api.g_varchar2) then
    p_rec.message_type_cd :=
    pqh_plg_shd.g_old_rec.message_type_cd;
  End If;
  If (p_rec.batch_status = hr_api.g_varchar2) then
    p_rec.batch_status :=
    pqh_plg_shd.g_old_rec.batch_status;
  End If;
  If (p_rec.batch_start_date = hr_api.g_date) then
    p_rec.batch_start_date :=
    pqh_plg_shd.g_old_rec.batch_start_date;
  End If;
  If (p_rec.batch_end_date = hr_api.g_date) then
    p_rec.batch_end_date :=
    pqh_plg_shd.g_old_rec.batch_end_date;
  End If;
  If (p_rec.txn_table_route_id = hr_api.g_number) then
    p_rec.txn_table_route_id :=
    pqh_plg_shd.g_old_rec.txn_table_route_id;
  End If;
  If (p_rec.log_context = hr_api.g_varchar2) then
    p_rec.log_context :=
    pqh_plg_shd.g_old_rec.log_context;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    pqh_plg_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pqh_plg_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pqh_plg_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pqh_plg_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pqh_plg_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pqh_plg_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pqh_plg_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pqh_plg_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pqh_plg_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pqh_plg_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pqh_plg_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pqh_plg_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pqh_plg_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pqh_plg_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pqh_plg_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pqh_plg_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pqh_plg_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pqh_plg_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pqh_plg_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pqh_plg_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pqh_plg_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pqh_plg_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pqh_plg_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pqh_plg_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pqh_plg_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pqh_plg_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pqh_plg_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pqh_plg_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pqh_plg_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pqh_plg_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pqh_plg_shd.g_old_rec.information30;
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
  p_rec        in out nocopy pqh_plg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_plg_shd.lck
	(
	p_rec.process_log_id,
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
  pqh_plg_bus.update_validate(p_rec
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
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_process_log_id               in number,
  p_module_cd                    in varchar2         default hr_api.g_varchar2,
  p_txn_id                       in number           default hr_api.g_number,
  p_master_process_log_id        in number           default hr_api.g_number,
  p_message_text                 in varchar2         default hr_api.g_varchar2,
  p_message_type_cd              in varchar2         default hr_api.g_varchar2,
  p_batch_status                 in varchar2         default hr_api.g_varchar2,
  p_batch_start_date             in date             default hr_api.g_date,
  p_batch_end_date               in date             default hr_api.g_date,
  p_txn_table_route_id           in number           default hr_api.g_number,
  p_log_context                  in varchar2         default hr_api.g_varchar2,
  p_information_category         in varchar2         default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pqh_plg_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_plg_shd.convert_args
  (
  p_process_log_id,
  p_module_cd,
  p_txn_id,
  p_master_process_log_id,
  p_message_text,
  p_message_type_cd,
  p_batch_status,
  p_batch_start_date,
  p_batch_end_date,
  p_txn_table_route_id,
  p_log_context,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30,
  p_object_version_number
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
end pqh_plg_upd;

/
