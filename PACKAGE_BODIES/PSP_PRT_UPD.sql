--------------------------------------------------------
--  DDL for Package Body PSP_PRT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PRT_UPD" as
/* $Header: PSPRTRHB.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_prt_upd.';  -- Global package name
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
  (p_rec in out nocopy psp_prt_shd.g_rec_type
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
  psp_prt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the psp_report_templates Row
  --
  update psp_report_templates
    set
     template_id                     = p_rec.template_id
    ,template_name                   = p_rec.template_name
    ,business_group_id               = p_rec.business_group_id
    ,set_of_books_id                 = p_rec.set_of_books_id
    ,object_version_number           = p_rec.object_version_number
    ,report_type                     = p_rec.report_type
    ,period_frequency_id             = p_rec.period_frequency_id
    ,report_template_code            = p_rec.report_template_code
    ,display_all_emp_distrib_flag    = p_rec.display_all_emp_distrib_flag
    ,manual_entry_override_flag      = p_rec.manual_entry_override_flag
    ,approval_type                   = p_rec.approval_type
    ,custom_approval_code            = p_rec.custom_approval_code
    ,sup_levels                      = p_rec.sup_levels
    ,preview_effort_report_flag      = p_rec.preview_effort_report_flag
    ,notification_reminder_in_days   = p_rec.notification_reminder_in_days
    ,sprcd_tolerance_amt             = p_rec.sprcd_tolerance_amt
    ,sprcd_tolerance_percent         = p_rec.sprcd_tolerance_percent
    ,description                     = p_rec.description
    ,legislation_code                = p_rec.legislation_code
    ,hundred_pcent_eff_at_per_asg    = p_rec.hundred_pcent_eff_at_per_asg
    ,selection_match_level           = p_rec.selection_match_level
    where template_id = p_rec.template_id;
  --
  psp_prt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    psp_prt_shd.g_api_dml := false;   -- Unset the api dml status
    psp_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    psp_prt_shd.g_api_dml := false;   -- Unset the api dml status
    psp_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    psp_prt_shd.g_api_dml := false;   -- Unset the api dml status
    psp_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    psp_prt_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in psp_prt_shd.g_rec_type
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
  (p_rec                          in psp_prt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_prt_rku.after_update
      (p_template_id
      => p_rec.template_id
      ,p_template_name
      => p_rec.template_name
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_set_of_books_id
      => p_rec.set_of_books_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_report_type
      => p_rec.report_type
      ,p_period_frequency_id
      => p_rec.period_frequency_id
      ,p_report_template_code
      => p_rec.report_template_code
      ,p_display_all_emp_distrib_flag
      => p_rec.display_all_emp_distrib_flag
      ,p_manual_entry_override_flag
      => p_rec.manual_entry_override_flag
      ,p_approval_type
      => p_rec.approval_type
      ,p_custom_approval_code
      => p_rec.custom_approval_code
      ,p_sup_levels
      => p_rec.sup_levels
      ,p_preview_effort_report_flag
      => p_rec.preview_effort_report_flag
      ,p_notification_reminder_in_day
      => p_rec.notification_reminder_in_days
      ,p_sprcd_tolerance_amt
      => p_rec.sprcd_tolerance_amt
      ,p_sprcd_tolerance_percent
      => p_rec.sprcd_tolerance_percent
      ,p_description
      => p_rec.description
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_hundred_pcent_eff_at_per_asg
      => p_rec.hundred_pcent_eff_at_per_asg
      ,p_selection_match_level
      => p_rec.selection_match_level
      ,p_template_name_o
      => psp_prt_shd.g_old_rec.template_name
      ,p_business_group_id_o
      => psp_prt_shd.g_old_rec.business_group_id
      ,p_set_of_books_id_o
      => psp_prt_shd.g_old_rec.set_of_books_id
      ,p_object_version_number_o
      => psp_prt_shd.g_old_rec.object_version_number
      ,p_report_type_o
      => psp_prt_shd.g_old_rec.report_type
      ,p_period_frequency_id_o
      => psp_prt_shd.g_old_rec.period_frequency_id
      ,p_report_template_code_o
      => psp_prt_shd.g_old_rec.report_template_code
      ,p_display_all_emp_distrib_fl_o
      => psp_prt_shd.g_old_rec.display_all_emp_distrib_flag
      ,p_manual_entry_override_flag_o
      => psp_prt_shd.g_old_rec.manual_entry_override_flag
      ,p_approval_type_o
      => psp_prt_shd.g_old_rec.approval_type
      ,p_custom_approval_code_o
      => psp_prt_shd.g_old_rec.custom_approval_code
      ,p_sup_levels_o
      => psp_prt_shd.g_old_rec.sup_levels
      ,p_preview_effort_report_flag_o
      => psp_prt_shd.g_old_rec.preview_effort_report_flag
      ,p_notification_reminder_in_d_o
      => psp_prt_shd.g_old_rec.notification_reminder_in_days
      ,p_sprcd_tolerance_amt_o
      => psp_prt_shd.g_old_rec.sprcd_tolerance_amt
      ,p_sprcd_tolerance_percent_o
      => psp_prt_shd.g_old_rec.sprcd_tolerance_percent
      ,p_description_o
      => psp_prt_shd.g_old_rec.description
      ,p_legislation_code_o
      => psp_prt_shd.g_old_rec.legislation_code
      ,p_hundred_pcent_eff_at_per_a_o
      => psp_prt_shd.g_old_rec.hundred_pcent_eff_at_per_asg
      ,p_selection_match_level_o
      => psp_prt_shd.g_old_rec.selection_match_level
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_REPORT_TEMPLATES'
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
  (p_rec in out nocopy psp_prt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.template_name = hr_api.g_varchar2) then
    p_rec.template_name :=
    psp_prt_shd.g_old_rec.template_name;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    psp_prt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.set_of_books_id = hr_api.g_number) then
    p_rec.set_of_books_id :=
    psp_prt_shd.g_old_rec.set_of_books_id;
  End If;
  If (p_rec.report_type = hr_api.g_varchar2) then
    p_rec.report_type :=
    psp_prt_shd.g_old_rec.report_type;
  End If;
  If (p_rec.period_frequency_id = hr_api.g_number) then
    p_rec.period_frequency_id :=
    psp_prt_shd.g_old_rec.period_frequency_id;
  End If;
  If (p_rec.report_template_code = hr_api.g_varchar2) then
    p_rec.report_template_code :=
    psp_prt_shd.g_old_rec.report_template_code;
  End If;
  If (p_rec.display_all_emp_distrib_flag = hr_api.g_varchar2) then
    p_rec.display_all_emp_distrib_flag :=
    psp_prt_shd.g_old_rec.display_all_emp_distrib_flag;
  End If;
  If (p_rec.manual_entry_override_flag = hr_api.g_varchar2) then
    p_rec.manual_entry_override_flag :=
    psp_prt_shd.g_old_rec.manual_entry_override_flag;
  End If;
  If (p_rec.approval_type = hr_api.g_varchar2) then
    p_rec.approval_type :=
    psp_prt_shd.g_old_rec.approval_type;
  End If;
  If (p_rec.custom_approval_code = hr_api.g_varchar2) then
    p_rec.custom_approval_code :=
    psp_prt_shd.g_old_rec.custom_approval_code;
  End If;
  If (p_rec.sup_levels = hr_api.g_number) then
    p_rec.sup_levels :=
    psp_prt_shd.g_old_rec.sup_levels;
  End If;
  If (p_rec.preview_effort_report_flag = hr_api.g_varchar2) then
    p_rec.preview_effort_report_flag :=
    psp_prt_shd.g_old_rec.preview_effort_report_flag;
  End If;
  If (p_rec.notification_reminder_in_days = hr_api.g_number) then
    p_rec.notification_reminder_in_days :=
    psp_prt_shd.g_old_rec.notification_reminder_in_days;
  End If;
  If (p_rec.sprcd_tolerance_amt = hr_api.g_number) then
    p_rec.sprcd_tolerance_amt :=
    psp_prt_shd.g_old_rec.sprcd_tolerance_amt;
  End If;
  If (p_rec.sprcd_tolerance_percent = hr_api.g_number) then
    p_rec.sprcd_tolerance_percent :=
    psp_prt_shd.g_old_rec.sprcd_tolerance_percent;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    psp_prt_shd.g_old_rec.description;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    psp_prt_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.hundred_pcent_eff_at_per_asg = hr_api.g_varchar2) then
    p_rec.hundred_pcent_eff_at_per_asg :=
    psp_prt_shd.g_old_rec.hundred_pcent_eff_at_per_asg;
  End If;
  If (p_rec.selection_match_level = hr_api.g_varchar2) then
    p_rec.selection_match_level :=
    psp_prt_shd.g_old_rec.selection_match_level;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy psp_prt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  psp_prt_shd.lck
    (p_rec.template_id
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
  psp_prt_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  psp_prt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  psp_prt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  psp_prt_upd.post_update
     (p_rec
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
  (p_template_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_template_name                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_report_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_frequency_id          in     number    default hr_api.g_number
  ,p_report_template_code         in     varchar2  default hr_api.g_varchar2
  ,p_approval_type                in     varchar2  default hr_api.g_varchar2
  ,p_preview_effort_report_flag   in     varchar2  default hr_api.g_varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2  default hr_api.g_varchar2
  ,p_selection_match_level        in     varchar2  default hr_api.g_varchar2
  ,p_display_all_emp_distrib_flag in     varchar2  default hr_api.g_varchar2
  ,p_manual_entry_override_flag   in     varchar2  default hr_api.g_varchar2
  ,p_custom_approval_code         in     varchar2  default hr_api.g_varchar2
  ,p_sup_levels                   in     number    default hr_api.g_number
  ,p_notification_reminder_in_day in     number    default hr_api.g_number
  ,p_sprcd_tolerance_amt          in     number    default hr_api.g_number
  ,p_sprcd_tolerance_percent      in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   psp_prt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  psp_prt_shd.convert_args
  (p_template_id
  ,p_template_name
  ,p_business_group_id
  ,p_set_of_books_id
  ,p_object_version_number
  ,p_report_type
  ,p_period_frequency_id
  ,p_report_template_code
  ,p_display_all_emp_distrib_flag
  ,p_manual_entry_override_flag
  ,p_approval_type
  ,p_custom_approval_code
  ,p_sup_levels
  ,p_preview_effort_report_flag
  ,p_notification_reminder_in_day
  ,p_sprcd_tolerance_amt
  ,p_sprcd_tolerance_percent
  ,p_description
  ,p_legislation_code
  ,p_hundred_pcent_eff_at_per_asg
  ,p_selection_match_level
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  psp_prt_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end psp_prt_upd;

/
