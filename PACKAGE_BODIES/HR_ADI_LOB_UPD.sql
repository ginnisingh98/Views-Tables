--------------------------------------------------------
--  DDL for Package Body HR_ADI_LOB_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ADI_LOB_UPD" as
/* $Header: hrlobrhi.pkb 120.0 2005/05/31 01:18:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_adi_lob_upd.';  -- Global package name
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
Procedure update_dml
  (p_rec in out nocopy hr_adi_lob_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the fnd_lobs Row
  --
  update fnd_lobs
    set
     file_id                         = p_rec.file_id
    ,file_name                       = p_rec.file_name
    ,file_content_type               = p_rec.file_content_type
    ,upload_date                     = p_rec.upload_date
    ,program_name                    = p_rec.program_name
    ,program_tag                     = p_rec.program_tag
    ,file_format                     = p_rec.file_format
    where file_id = p_rec.file_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_adi_lob_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_adi_lob_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_adi_lob_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
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
Procedure pre_update
  (p_rec in out nocopy hr_adi_lob_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Derive file_format from file_content_type
  --
  --
  if (p_rec.file_content_type = 'text/html') OR
     (p_rec.file_content_type = 'text/xml') OR
     (p_rec.file_content_type = 'text/plain') then
    p_rec.file_format := 'TEXT';
  else
    p_rec.file_format := 'BINARY';
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
  (p_effective_date               in date
  ,p_rec                          in hr_adi_lob_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_adi_lob_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_file_id
      => p_rec.file_id
      ,p_file_name
      => p_rec.file_name
      ,p_file_content_type
      => p_rec.file_content_type
      ,p_upload_date
      => p_rec.upload_date
      ,p_program_name
      => p_rec.program_name
      ,p_program_tag
      => p_rec.program_tag
      ,p_file_format
      => p_rec.file_format
      ,p_file_name_o
      => hr_adi_lob_shd.g_old_rec.file_name
      ,p_file_content_type_o
      => hr_adi_lob_shd.g_old_rec.file_content_type
      ,p_upload_date_o
      => hr_adi_lob_shd.g_old_rec.upload_date
      ,p_program_name_o
      => hr_adi_lob_shd.g_old_rec.program_name
      ,p_program_tag_o
      => hr_adi_lob_shd.g_old_rec.program_tag
      ,p_file_format_o
      => hr_adi_lob_shd.g_old_rec.file_format
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'FND_LOBS'
        ,p_hook_type   => 'AU');
      --
  end;
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy hr_adi_lob_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.file_name = hr_api.g_varchar2) then
    p_rec.file_name :=
    hr_adi_lob_shd.g_old_rec.file_name;
  End If;
  If (p_rec.file_content_type = hr_api.g_varchar2) then
    p_rec.file_content_type :=
    hr_adi_lob_shd.g_old_rec.file_content_type;
  End If;
  If (p_rec.upload_date = hr_api.g_date) then
    p_rec.upload_date :=
    hr_adi_lob_shd.g_old_rec.upload_date;
  End If;
  If (p_rec.program_name = hr_api.g_varchar2) then
    p_rec.program_name :=
    hr_adi_lob_shd.g_old_rec.program_name;
  End If;
  If (p_rec.program_tag = hr_api.g_varchar2) then
    p_rec.program_tag :=
    hr_adi_lob_shd.g_old_rec.program_tag;
  End If;
  If (p_rec.file_format = hr_api.g_varchar2) then
    p_rec.file_format :=
    hr_adi_lob_shd.g_old_rec.file_format;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_adi_lob_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_adi_lob_shd.lck
    (p_rec.file_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hr_adi_lob_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_adi_lob_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_adi_lob_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_adi_lob_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_file_id                      in     number
  ,p_file_content_type            in     varchar2
  ,p_file_name                    in     varchar2
  ) is
--
  l_rec   hr_adi_lob_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_adi_lob_shd.convert_args
  (p_file_id
  ,p_file_name
  ,p_file_content_type
  ,SYSDATE
  ,'HRMS_ADI'
  ,hr_api.g_varchar2
  ,null
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call tHe corresponding record
  -- business process.
  --
  hr_adi_lob_upd.upd
     (p_effective_date
     ,l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_adi_lob_upd;

/
