--------------------------------------------------------
--  DDL for Package Body PAY_PEL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEL_UPD" as
/* $Header: pypelrhi.pkb 120.7.12010000.3 2008/10/03 08:41:56 ankagarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pel_upd.';  -- Global package name
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
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
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
--   A Pl/Sql record structure.
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
  (p_rec                   in out nocopy pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'pay_element_links_f'
        ,p_base_key_column => 'element_link_id'
        ,p_base_key_value  => p_rec.element_link_id
        );
    --
    pay_pel_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_element_links_f Row
    --
    update  pay_element_links_f
    set
     element_link_id                      = p_rec.element_link_id
    ,cost_allocation_keyflex_id           = p_rec.cost_allocation_keyflex_id
    ,element_type_id                      = p_rec.element_type_id
    ,balancing_keyflex_id                 = p_rec.balancing_keyflex_id
    ,business_group_id                    = p_rec.business_group_id
    ,element_set_id                       = p_rec.element_set_id
    ,costable_type                        = p_rec.costable_type
    ,multiply_value_flag                  = p_rec.multiply_value_flag
    ,standard_link_flag                   = p_rec.standard_link_flag
    ,transfer_to_gl_flag                  = p_rec.transfer_to_gl_flag
    ,comment_id                           = p_rec.comment_id
    ,employment_category                  = p_rec.employment_category
    ,qualifying_age                       = p_rec.qualifying_age
    ,qualifying_length_of_service         = p_rec.qualifying_length_of_service
    ,qualifying_units                     = p_rec.qualifying_units
    ,attribute_category                   = p_rec.attribute_category
    ,attribute1                           = p_rec.attribute1
    ,attribute2                           = p_rec.attribute2
    ,attribute3                           = p_rec.attribute3
    ,attribute4                           = p_rec.attribute4
    ,attribute5                           = p_rec.attribute5
    ,attribute6                           = p_rec.attribute6
    ,attribute7                           = p_rec.attribute7
    ,attribute8                           = p_rec.attribute8
    ,attribute9                           = p_rec.attribute9
    ,attribute10                          = p_rec.attribute10
    ,attribute11                          = p_rec.attribute11
    ,attribute12                          = p_rec.attribute12
    ,attribute13                          = p_rec.attribute13
    ,attribute14                          = p_rec.attribute14
    ,attribute15                          = p_rec.attribute15
    ,attribute16                          = p_rec.attribute16
    ,attribute17                          = p_rec.attribute17
    ,attribute18                          = p_rec.attribute18
    ,attribute19                          = p_rec.attribute19
    ,attribute20                          = p_rec.attribute20
    ,object_version_number                = p_rec.object_version_number
    where   element_link_id = p_rec.element_link_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
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
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec                      in out nocopy pay_pel_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pel_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
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
--      details.
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
  (p_rec                     in out nocopy     pay_pel_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --

    pay_pel_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.element_link_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pay_pel_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    End If;
    --
    -- We must now insert the updated row
    --
    pay_pel_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
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
  (p_rec                   in out nocopy pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null and p_rec.comment_id is null) then
     hr_comm_api.ins(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ELEMENT_LINKS_F'
                    ,p_comment_text      => p_rec.comments
                    );
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comments <>
        pay_pel_shd.g_old_rec.comments) then
     hr_comm_api.upd(p_comment_id        => p_rec.comment_id
                    ,p_source_table_name => 'PAY_ELEMENT_LINKS_F'
                    ,p_comment_text      => p_rec.comments
                    );
  End If;
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
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
  (p_rec                   in pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_pel_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_element_link_id
      => p_rec.element_link_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_payroll_id
      => p_rec.payroll_id
      ,p_job_id
      => p_rec.job_id
      ,p_position_id
      => p_rec.position_id
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_cost_allocation_keyflex_id
      => p_rec.cost_allocation_keyflex_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_location_id
      => p_rec.location_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_balancing_keyflex_id
      => p_rec.balancing_keyflex_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_element_set_id
      => p_rec.element_set_id
      ,p_pay_basis_id
      => p_rec.pay_basis_id
      ,p_costable_type
      => p_rec.costable_type
      ,p_link_to_all_payrolls_flag
      => p_rec.link_to_all_payrolls_flag
      ,p_multiply_value_flag
      => p_rec.multiply_value_flag
      ,p_standard_link_flag
      => p_rec.standard_link_flag
      ,p_transfer_to_gl_flag
      => p_rec.transfer_to_gl_flag
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_employment_category
      => p_rec.employment_category
      ,p_qualifying_age
      => p_rec.qualifying_age
      ,p_qualifying_length_of_service
      => p_rec.qualifying_length_of_service
      ,p_qualifying_units
      => p_rec.qualifying_units
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
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_start_date_o
      => pay_pel_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_pel_shd.g_old_rec.effective_end_date
      ,p_payroll_id_o
      => pay_pel_shd.g_old_rec.payroll_id
      ,p_job_id_o
      => pay_pel_shd.g_old_rec.job_id
      ,p_position_id_o
      => pay_pel_shd.g_old_rec.position_id
      ,p_people_group_id_o
      => pay_pel_shd.g_old_rec.people_group_id
      ,p_cost_allocation_keyflex_id_o
      => pay_pel_shd.g_old_rec.cost_allocation_keyflex_id
      ,p_organization_id_o
      => pay_pel_shd.g_old_rec.organization_id
      ,p_element_type_id_o
      => pay_pel_shd.g_old_rec.element_type_id
      ,p_location_id_o
      => pay_pel_shd.g_old_rec.location_id
      ,p_grade_id_o
      => pay_pel_shd.g_old_rec.grade_id
      ,p_balancing_keyflex_id_o
      => pay_pel_shd.g_old_rec.balancing_keyflex_id
      ,p_business_group_id_o
      => pay_pel_shd.g_old_rec.business_group_id
      ,p_element_set_id_o
      => pay_pel_shd.g_old_rec.element_set_id
      ,p_pay_basis_id_o
      => pay_pel_shd.g_old_rec.pay_basis_id
      ,p_costable_type_o
      => pay_pel_shd.g_old_rec.costable_type
      ,p_link_to_all_payrolls_flag_o
      => pay_pel_shd.g_old_rec.link_to_all_payrolls_flag
      ,p_multiply_value_flag_o
      => pay_pel_shd.g_old_rec.multiply_value_flag
      ,p_standard_link_flag_o
      => pay_pel_shd.g_old_rec.standard_link_flag
      ,p_transfer_to_gl_flag_o
      => pay_pel_shd.g_old_rec.transfer_to_gl_flag
      ,p_comment_id_o
      => pay_pel_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_pel_shd.g_old_rec.comments
      ,p_employment_category_o
      => pay_pel_shd.g_old_rec.employment_category
      ,p_qualifying_age_o
      => pay_pel_shd.g_old_rec.qualifying_age
      ,p_qualifying_length_of_servi_o
      => pay_pel_shd.g_old_rec.qualifying_length_of_service
      ,p_qualifying_units_o
      => pay_pel_shd.g_old_rec.qualifying_units
      ,p_attribute_category_o
      => pay_pel_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_pel_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_pel_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_pel_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_pel_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_pel_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_pel_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_pel_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_pel_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_pel_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_pel_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_pel_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_pel_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_pel_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_pel_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_pel_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_pel_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_pel_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_pel_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_pel_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_pel_shd.g_old_rec.attribute20
      ,p_object_version_number_o
      => pay_pel_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_LINKS_F'
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
  (p_rec in out nocopy pay_pel_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.payroll_id = hr_api.g_number) then
    p_rec.payroll_id :=
    pay_pel_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    pay_pel_shd.g_old_rec.job_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    pay_pel_shd.g_old_rec.position_id;
  End If;
  If (p_rec.people_group_id = hr_api.g_number) then
    p_rec.people_group_id :=
    pay_pel_shd.g_old_rec.people_group_id;
  End If;
  If (p_rec.cost_allocation_keyflex_id = hr_api.g_number) then
    p_rec.cost_allocation_keyflex_id :=
    pay_pel_shd.g_old_rec.cost_allocation_keyflex_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    pay_pel_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pay_pel_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    pay_pel_shd.g_old_rec.location_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    pay_pel_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.balancing_keyflex_id = hr_api.g_number) then
    p_rec.balancing_keyflex_id :=
    pay_pel_shd.g_old_rec.balancing_keyflex_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_pel_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.element_set_id = hr_api.g_number) then
    p_rec.element_set_id :=
    pay_pel_shd.g_old_rec.element_set_id;
  End If;
  If (p_rec.pay_basis_id = hr_api.g_number) then
    p_rec.pay_basis_id :=
    pay_pel_shd.g_old_rec.pay_basis_id;
  End If;
  If (p_rec.costable_type = hr_api.g_varchar2) then
    p_rec.costable_type :=
    pay_pel_shd.g_old_rec.costable_type;
  End If;
  If (p_rec.link_to_all_payrolls_flag = hr_api.g_varchar2) then
    p_rec.link_to_all_payrolls_flag :=
    pay_pel_shd.g_old_rec.link_to_all_payrolls_flag;
  End If;
  If (p_rec.multiply_value_flag = hr_api.g_varchar2) then
    p_rec.multiply_value_flag :=
    pay_pel_shd.g_old_rec.multiply_value_flag;
  End If;
  If (p_rec.standard_link_flag = hr_api.g_varchar2) then
    p_rec.standard_link_flag :=
    pay_pel_shd.g_old_rec.standard_link_flag;
  End If;
  If (p_rec.transfer_to_gl_flag = hr_api.g_varchar2) then
    p_rec.transfer_to_gl_flag :=
    pay_pel_shd.g_old_rec.transfer_to_gl_flag;
  End If;
  If (p_rec.comment_id = hr_api.g_number) then
    p_rec.comment_id :=
    pay_pel_shd.g_old_rec.comment_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pay_pel_shd.g_old_rec.comments;
  End If;
  If (p_rec.employment_category = hr_api.g_varchar2) then
    p_rec.employment_category :=
    pay_pel_shd.g_old_rec.employment_category;
  End If;
  If (p_rec.qualifying_age = hr_api.g_number) then
    p_rec.qualifying_age :=
    pay_pel_shd.g_old_rec.qualifying_age;
  End If;
  If (p_rec.qualifying_length_of_service = hr_api.g_number) then
    p_rec.qualifying_length_of_service :=
    pay_pel_shd.g_old_rec.qualifying_length_of_service;
  End If;
  If (p_rec.qualifying_units = hr_api.g_varchar2) then
    p_rec.qualifying_units :=
    pay_pel_shd.g_old_rec.qualifying_units;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_pel_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_pel_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_pel_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_pel_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_pel_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_pel_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_pel_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_pel_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_pel_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_pel_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_pel_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_pel_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_pel_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_pel_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_pel_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_pel_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_pel_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_pel_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_pel_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_pel_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_pel_shd.g_old_rec.attribute20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pay_pel_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  p_rec.link_to_all_payrolls_flag := hr_api.g_varchar2;
  p_rec.payroll_id                := hr_api.g_number;
  p_rec.job_id                    := hr_api.g_number;
  p_rec.position_id               := hr_api.g_number;
  p_rec.people_group_id           := hr_api.g_number;
  p_rec.organization_id           := hr_api.g_number;
  p_rec.location_id               := hr_api.g_number;
  p_rec.grade_id                  := hr_api.g_number;
  p_rec.pay_basis_id              := hr_api.g_number;
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pay_pel_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_element_link_id                  => p_rec.element_link_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    ,p_enforce_foreign_locking          => true
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pay_pel_upd.convert_defs(p_rec);
  --
  pay_pel_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date                  => l_validation_end_date
    );
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
(p_effective_date		in date	    default hr_api.g_date
,p_element_type_id		in number   default hr_api.g_number
,p_business_group_id		in number   default hr_api.g_number
,p_costable_type		in varchar2 default hr_api.g_varchar2
,p_multiply_value_flag		in varchar2 default hr_api.g_varchar2
,p_standard_link_flag		in varchar2 default hr_api.g_varchar2
,p_transfer_to_gl_flag		in varchar2 default hr_api.g_varchar2
,p_cost_allocation_keyflex_id	in number   default hr_api.g_number
,p_balancing_keyflex_id      	in number   default hr_api.g_number
,p_element_set_id		in number   default hr_api.g_number
,p_comments			in varchar2 default hr_api.g_varchar2
,p_employment_category		in varchar2 default hr_api.g_varchar2
,p_qualifying_age		in varchar2 default hr_api.g_varchar2
,p_qualifying_length_of_service in varchar2 default hr_api.g_varchar2
,p_qualifying_units		in varchar2 default hr_api.g_varchar2
,p_attribute_category		in varchar2 default hr_api.g_varchar2
,p_attribute1			in varchar2 default hr_api.g_varchar2
,p_attribute2			in varchar2 default hr_api.g_varchar2
,p_attribute3			in varchar2 default hr_api.g_varchar2
,p_attribute4			in varchar2 default hr_api.g_varchar2
,p_attribute5			in varchar2 default hr_api.g_varchar2
,p_attribute6			in varchar2 default hr_api.g_varchar2
,p_attribute7			in varchar2 default hr_api.g_varchar2
,p_attribute8			in varchar2 default hr_api.g_varchar2
,p_attribute9			in varchar2 default hr_api.g_varchar2
,p_attribute10			in varchar2 default hr_api.g_varchar2
,p_attribute11			in varchar2 default hr_api.g_varchar2
,p_attribute12			in varchar2 default hr_api.g_varchar2
,p_attribute13			in varchar2 default hr_api.g_varchar2
,p_attribute14			in varchar2 default hr_api.g_varchar2
,p_attribute15			in varchar2 default hr_api.g_varchar2
,p_attribute16			in varchar2 default hr_api.g_varchar2
,p_attribute17			in varchar2 default hr_api.g_varchar2
,p_attribute18			in varchar2 default hr_api.g_varchar2
,p_attribute19			in varchar2 default hr_api.g_varchar2
,p_attribute20			in varchar2 default hr_api.g_varchar2
,p_element_link_id		in number   default hr_api.g_number
,p_datetrack_mode		in varchar2 default hr_api.g_varchar2
,p_object_version_number	in out nocopy varchar2
,p_effective_start_date		out nocopy date
,p_effective_end_date		out nocopy date
) is
--
  l_rec         pay_pel_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_pel_shd.convert_args
    (p_element_link_id
    ,null
    ,null
    ,null
    ,null
    ,null
    ,null
    ,p_cost_allocation_keyflex_id
    ,null
    ,p_element_type_id
    ,null
    ,null
    ,p_balancing_keyflex_id
    ,p_business_group_id
    ,p_element_set_id
    ,null
    ,p_costable_type
    ,null
    ,p_multiply_value_flag
    ,p_standard_link_flag
    ,p_transfer_to_gl_flag
    ,hr_api.g_number
    ,p_comments
    ,p_employment_category
    ,p_qualifying_age
    ,p_qualifying_length_of_service
    ,p_qualifying_units
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
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_object_version_number
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pel_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_pel_upd;

/
