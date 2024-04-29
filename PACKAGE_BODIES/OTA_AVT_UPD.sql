--------------------------------------------------------
--  DDL for Package Body OTA_AVT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AVT_UPD" as
/* $Header: otavtrhi.pkb 120.0 2005/05/29 07:02:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_avt_upd.';  -- Global package name
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
  (p_rec in out nocopy ota_avt_shd.g_rec_type
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
  -- Update the ota_activity_versions_tl Row
  --
  update ota_activity_versions_tl
    set
     activity_version_id             = p_rec.activity_version_id
    ,language                        = p_rec.language
    ,source_lang                     = p_rec.source_lang
    ,version_name                    = p_rec.version_name
    ,description                     = p_rec.description
    ,intended_audience               = p_rec.intended_audience
    ,objectives                      = p_rec.objectives
    ,keywords                        = p_rec.keywords
    where activity_version_id = p_rec.activity_version_id
    and language = p_rec.language;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_avt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_avt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_avt_shd.constraint_error
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
  (p_rec in ota_avt_shd.g_rec_type
  ) is
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
  ,p_rec                          in ota_avt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_avt_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_language
      => p_rec.language
      ,p_source_lang
      => p_rec.source_lang
      ,p_version_name
      => p_rec.version_name
      ,p_description
      => p_rec.description
      ,p_intended_audience
      => p_rec.intended_audience
      ,p_objectives
      => p_rec.objectives
      ,p_keywords
      => p_rec.keywords
      ,p_source_lang_o
      => ota_avt_shd.g_old_rec.source_lang
      ,p_version_name_o
      => ota_avt_shd.g_old_rec.version_name
      ,p_description_o
      => ota_avt_shd.g_old_rec.description
      ,p_intended_audience_o
      => ota_avt_shd.g_old_rec.intended_audience
      ,p_objectives_o
      => ota_avt_shd.g_old_rec.objectives
      ,p_keywords_o
      => ota_avt_shd.g_old_rec.keywords
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_ACTIVITY_VERSIONS_TL'
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
  (p_rec in out nocopy ota_avt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.source_lang = hr_api.g_varchar2) then
    p_rec.source_lang :=
    ota_avt_shd.g_old_rec.source_lang;
  End If;
  If (p_rec.version_name = hr_api.g_varchar2) then
    p_rec.version_name :=
    ota_avt_shd.g_old_rec.version_name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    ota_avt_shd.g_old_rec.description;
  End If;
  If (p_rec.intended_audience = hr_api.g_varchar2) then
    p_rec.intended_audience :=
    ota_avt_shd.g_old_rec.intended_audience;
  End If;
  If (p_rec.objectives = hr_api.g_varchar2) then
    p_rec.objectives :=
    ota_avt_shd.g_old_rec.objectives;
  End If;
  If (p_rec.keywords = hr_api.g_varchar2) then
      p_rec.keywords :=
      ota_avt_shd.g_old_rec.keywords;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_avt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_avt_shd.lck
    (p_rec.activity_version_id
    ,p_rec.language
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ota_avt_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ota_avt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_avt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_avt_upd.post_update
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
  ,p_activity_version_id          in     number
  ,p_language                     in     varchar2
  ,p_source_lang                  in     varchar2  default hr_api.g_varchar2
  ,p_version_name                 in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_intended_audience            in     varchar2  default hr_api.g_varchar2
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ota_avt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_avt_shd.convert_args
  (p_activity_version_id
  ,p_language
  ,p_source_lang
  ,p_version_name
  ,p_description
  ,p_intended_audience
  ,p_objectives
  ,p_keywords
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_avt_upd.upd
     (p_effective_date
     ,l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd_tl >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_tl
  (p_effective_date               in date
  ,p_language_code                 in varchar2
  ,p_activity_version_id          in number
  ,p_version_name                 in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_intended_audience            in varchar2 default hr_api.g_varchar2
  ,p_objectives                   in varchar2 default hr_api.g_varchar2
  ,p_keywords                     in varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Cursor to obtain the translation rows where the language or
  -- source_lang match the specified language.
  --
  cursor csr_upd_langs is
    select avt.language
      from ota_activity_versions_tl avt
     where avt.activity_version_id = p_activity_version_id
       and p_language_code in (avt.language
                              ,avt.source_lang);
  --
  l_proc  varchar2(72) := g_package||'upd_tl';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Update the translated values for every matching row
  -- setting SOURCE_LANG to the specified language.
  --
  for l_lang in csr_upd_langs loop
    ota_avt_upd.upd
      (p_effective_date              => p_effective_date
      ,p_activity_version_id         => p_activity_version_id
      ,p_language                    => l_lang.language
      ,p_source_lang                 => p_language_code
      ,p_version_name                => p_version_name
      ,p_description                 => p_description
      ,p_intended_audience           => p_intended_audience
      ,p_objectives                  => p_objectives
      ,p_keywords                    => p_keywords
      );
  end loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
End upd_tl;
--
end ota_avt_upd;

/
