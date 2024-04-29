--------------------------------------------------------
--  DDL for Package Body PSP_PEE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PEE_UPD" as
/* $Header: PSPEERHB.pls 120.3 2006/02/08 05:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_pee_upd.';  -- Global package name
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
  (p_rec in out nocopy psp_pee_shd.g_rec_type
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
  -- Update the psp_external_effort_lines Row
  --
  update psp_external_effort_lines
    set
     external_effort_line_id         = p_rec.external_effort_line_id
    ,batch_name                      = p_rec.batch_name
    ,object_version_number           = p_rec.object_version_number
    ,distribution_date               = p_rec.distribution_date
    ,person_id                       = p_rec.person_id
    ,assignment_id                   = p_rec.assignment_id
    ,currency_code                   = p_rec.currency_code
    ,distribution_amount             = p_rec.distribution_amount
    ,business_group_id               = p_rec.business_group_id
    ,set_of_books_id                 = p_rec.set_of_books_id
    ,gl_code_combination_id          = p_rec.gl_code_combination_id
    ,project_id                      = p_rec.project_id
    ,task_id                         = p_rec.task_id
    ,award_id                        = p_rec.award_id
    ,expenditure_organization_id     = p_rec.expenditure_organization_id
    ,expenditure_type                = p_rec.expenditure_type
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    where external_effort_line_id = p_rec.external_effort_line_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    psp_pee_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    psp_pee_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    psp_pee_shd.constraint_error
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
  (p_rec in psp_pee_shd.g_rec_type
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
  (p_rec                          in psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_pee_rku.after_update
      (p_external_effort_line_id
      => p_rec.external_effort_line_id
      ,p_batch_name
      => p_rec.batch_name
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_distribution_date
      => p_rec.distribution_date
      ,p_person_id
      => p_rec.person_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_currency_code
      => p_rec.currency_code
      ,p_distribution_amount
      => p_rec.distribution_amount
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_set_of_books_id
      => p_rec.set_of_books_id
      ,p_gl_code_combination_id
      => p_rec.gl_code_combination_id
      ,p_project_id
      => p_rec.project_id
      ,p_task_id
      => p_rec.task_id
      ,p_award_id
      => p_rec.award_id
      ,p_expenditure_organization_id
      => p_rec.expenditure_organization_id
      ,p_expenditure_type
      => p_rec.expenditure_type
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_batch_name_o
      => psp_pee_shd.g_old_rec.batch_name
      ,p_object_version_number_o
      => psp_pee_shd.g_old_rec.object_version_number
      ,p_distribution_date_o
      => psp_pee_shd.g_old_rec.distribution_date
      ,p_person_id_o
      => psp_pee_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => psp_pee_shd.g_old_rec.assignment_id
      ,p_currency_code_o
      => psp_pee_shd.g_old_rec.currency_code
      ,p_distribution_amount_o
      => psp_pee_shd.g_old_rec.distribution_amount
      ,p_business_group_id_o
      => psp_pee_shd.g_old_rec.business_group_id
      ,p_set_of_books_id_o
      => psp_pee_shd.g_old_rec.set_of_books_id
      ,p_gl_code_combination_id_o
      => psp_pee_shd.g_old_rec.gl_code_combination_id
      ,p_project_id_o
      => psp_pee_shd.g_old_rec.project_id
      ,p_task_id_o
      => psp_pee_shd.g_old_rec.task_id
      ,p_award_id_o
      => psp_pee_shd.g_old_rec.award_id
      ,p_expenditure_organization_i_o
      => psp_pee_shd.g_old_rec.expenditure_organization_id
      ,p_expenditure_type_o
      => psp_pee_shd.g_old_rec.expenditure_type
      ,p_attribute_category_o
      => psp_pee_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => psp_pee_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => psp_pee_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => psp_pee_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => psp_pee_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => psp_pee_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => psp_pee_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => psp_pee_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => psp_pee_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => psp_pee_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => psp_pee_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => psp_pee_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => psp_pee_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => psp_pee_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => psp_pee_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => psp_pee_shd.g_old_rec.attribute15
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_EXTERNAL_EFFORT_LINES'
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
  (p_rec in out nocopy psp_pee_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.batch_name = hr_api.g_varchar2) then
    p_rec.batch_name :=
    psp_pee_shd.g_old_rec.batch_name;
  End If;
  If (p_rec.distribution_date = hr_api.g_date) then
    p_rec.distribution_date :=
    psp_pee_shd.g_old_rec.distribution_date;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    psp_pee_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    psp_pee_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    psp_pee_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.distribution_amount = hr_api.g_number) then
    p_rec.distribution_amount :=
    psp_pee_shd.g_old_rec.distribution_amount;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    psp_pee_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.set_of_books_id = hr_api.g_number) then
    p_rec.set_of_books_id :=
    psp_pee_shd.g_old_rec.set_of_books_id;
  End If;
  If (p_rec.gl_code_combination_id = hr_api.g_number) then
    p_rec.gl_code_combination_id :=
    psp_pee_shd.g_old_rec.gl_code_combination_id;
  End If;
  If (p_rec.project_id = hr_api.g_number) then
    p_rec.project_id :=
    psp_pee_shd.g_old_rec.project_id;
  End If;
  If (p_rec.task_id = hr_api.g_number) then
    p_rec.task_id :=
    psp_pee_shd.g_old_rec.task_id;
  End If;
  If (p_rec.award_id = hr_api.g_number) then
    p_rec.award_id :=
    psp_pee_shd.g_old_rec.award_id;
  End If;
  If (p_rec.expenditure_organization_id = hr_api.g_number) then
    p_rec.expenditure_organization_id :=
    psp_pee_shd.g_old_rec.expenditure_organization_id;
  End If;
  If (p_rec.expenditure_type = hr_api.g_varchar2) then
    p_rec.expenditure_type :=
    psp_pee_shd.g_old_rec.expenditure_type;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    psp_pee_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    psp_pee_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    psp_pee_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    psp_pee_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    psp_pee_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    psp_pee_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    psp_pee_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    psp_pee_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    psp_pee_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    psp_pee_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    psp_pee_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    psp_pee_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    psp_pee_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    psp_pee_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    psp_pee_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    psp_pee_shd.g_old_rec.attribute15;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  psp_pee_shd.lck
    (p_rec.external_effort_line_id
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
  psp_pee_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  psp_pee_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  psp_pee_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  psp_pee_upd.post_update
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
  (p_external_effort_line_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_batch_name                   in     varchar2  default hr_api.g_varchar2
  ,p_distribution_date            in     date      default hr_api.g_date
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_distribution_amount          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_gl_code_combination_id       in     number    default hr_api.g_number
  ,p_project_id                   in     number    default hr_api.g_number
  ,p_task_id                      in     number    default hr_api.g_number
  ,p_award_id                     in     number    default hr_api.g_number
  ,p_expenditure_organization_id  in     number    default hr_api.g_number
  ,p_expenditure_type             in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   psp_pee_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  psp_pee_shd.convert_args
  (p_external_effort_line_id
  ,p_batch_name
  ,p_object_version_number
  ,p_distribution_date
  ,p_person_id
  ,p_assignment_id
  ,p_currency_code
  ,p_distribution_amount
  ,p_business_group_id
  ,p_set_of_books_id
  ,p_gl_code_combination_id
  ,p_project_id
  ,p_task_id
  ,p_award_id
  ,p_expenditure_organization_id
  ,p_expenditure_type
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  psp_pee_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end psp_pee_upd;

/
