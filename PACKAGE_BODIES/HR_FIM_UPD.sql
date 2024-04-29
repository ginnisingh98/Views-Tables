--------------------------------------------------------
--  DDL for Package Body HR_FIM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FIM_UPD" as
/* $Header: hrfimrhi.pkb 115.5 2002/12/03 11:18:58 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_fim_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_fim_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the hr_form_items_b Row
  --
  update hr_form_items_b
    set
     form_item_id                    = p_rec.form_item_id
    ,object_version_number           = p_rec.object_version_number
    ,application_id                  = p_rec.application_id
    ,form_id                         = p_rec.form_id
    ,form_canvas_id                  = p_rec.form_canvas_id
    ,full_item_name                  = p_rec.full_item_name
    ,item_type                       = p_rec.item_type
    ,form_tab_page_id                = p_rec.form_tab_page_id
    ,radio_button_name               = p_rec.radio_button_name
    ,required_override               = p_rec.required_override
    ,form_tab_page_id_override       = p_rec.form_tab_page_id_override
    ,visible_override                = p_rec.visible_override
    where form_item_id = p_rec.form_item_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_fim_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_fim_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_fim_shd.constraint_error
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
  (p_rec in hr_fim_shd.g_rec_type
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  ,p_rec                          in hr_fim_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_fim_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_form_item_id
      => p_rec.form_item_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_application_id
      => p_rec.application_id
      ,p_form_id
      => p_rec.form_id
      ,p_form_canvas_id
      => p_rec.form_canvas_id
      ,p_full_item_name
      => p_rec.full_item_name
      ,p_item_type
      => p_rec.item_type
      ,p_form_tab_page_id
      => p_rec.form_tab_page_id
      ,p_radio_button_name
      => p_rec.radio_button_name
      ,p_required_override
      => p_rec.required_override
      ,p_form_tab_page_id_override
      => p_rec.form_tab_page_id_override
      ,p_visible_override
      => p_rec.visible_override
      ,p_object_version_number_o
      => hr_fim_shd.g_old_rec.object_version_number
      ,p_application_id_o
      => hr_fim_shd.g_old_rec.application_id
      ,p_form_id_o
      => hr_fim_shd.g_old_rec.form_id
      ,p_form_canvas_id_o
      => hr_fim_shd.g_old_rec.form_canvas_id
      ,p_full_item_name_o
      => hr_fim_shd.g_old_rec.full_item_name
      ,p_item_type_o
      => hr_fim_shd.g_old_rec.item_type
      ,p_form_tab_page_id_o
      => hr_fim_shd.g_old_rec.form_tab_page_id
      ,p_radio_button_name_o
      => hr_fim_shd.g_old_rec.radio_button_name
      ,p_required_override_o
      => hr_fim_shd.g_old_rec.required_override
      ,p_form_tab_page_id_override_o
      => hr_fim_shd.g_old_rec.form_tab_page_id_override
      ,p_visible_override_o
      => hr_fim_shd.g_old_rec.visible_override
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_FORM_ITEMS_B'
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
  (p_rec in out nocopy hr_fim_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.application_id = hr_api.g_number) then
    p_rec.application_id :=
    hr_fim_shd.g_old_rec.application_id;
  End If;
  If (p_rec.form_id = hr_api.g_number) then
    p_rec.form_id :=
    hr_fim_shd.g_old_rec.form_id;
  End If;
  If (p_rec.form_canvas_id = hr_api.g_number) then
    p_rec.form_canvas_id :=
    hr_fim_shd.g_old_rec.form_canvas_id;
  End If;
  If (p_rec.full_item_name = hr_api.g_varchar2) then
    p_rec.full_item_name :=
    hr_fim_shd.g_old_rec.full_item_name;
  End If;
  If (p_rec.item_type = hr_api.g_varchar2) then
    p_rec.item_type :=
    hr_fim_shd.g_old_rec.item_type;
  End If;
  If (p_rec.form_tab_page_id = hr_api.g_number) then
    p_rec.form_tab_page_id :=
    hr_fim_shd.g_old_rec.form_tab_page_id;
  End If;
  If (p_rec.radio_button_name = hr_api.g_varchar2) then
    p_rec.radio_button_name :=
    hr_fim_shd.g_old_rec.radio_button_name;
  End If;
  If (p_rec.required_override = hr_api.g_number) then
    p_rec.required_override :=
    hr_fim_shd.g_old_rec.required_override;
  End If;
  If (p_rec.form_tab_page_id_override = hr_api.g_number) then
    p_rec.form_tab_page_id_override :=
    hr_fim_shd.g_old_rec.form_tab_page_id_override;
  End If;
  If (p_rec.visible_override = hr_api.g_number) then
    p_rec.visible_override :=
    hr_fim_shd.g_old_rec.visible_override;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_fim_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_fim_shd.lck
    (p_rec.form_item_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hr_fim_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  hr_fim_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_fim_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_fim_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_form_item_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_application_id               in     number    default hr_api.g_number
  ,p_form_id                      in     number    default hr_api.g_number
  ,p_form_canvas_id               in     number    default hr_api.g_number
  ,p_full_item_name               in     varchar2  default hr_api.g_varchar2
  ,p_item_type                    in     varchar2  default hr_api.g_varchar2
  ,p_form_tab_page_id             in     number    default hr_api.g_number
  ,p_radio_button_name            in     varchar2  default hr_api.g_varchar2
  ,p_required_override            in     number    default hr_api.g_number
  ,p_form_tab_page_id_override    in     number    default hr_api.g_number
  ,p_visible_override             in     number    default hr_api.g_number
  ) is
--
  l_rec	  hr_fim_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_fim_shd.convert_args
  (p_form_item_id
  ,p_object_version_number
  ,p_application_id
  ,p_form_id
  ,p_form_canvas_id
  ,p_full_item_name
  ,p_item_type
  ,p_form_tab_page_id
  ,p_radio_button_name
  ,p_required_override
  ,p_form_tab_page_id_override
  ,p_visible_override
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_fim_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_fim_upd;

/
