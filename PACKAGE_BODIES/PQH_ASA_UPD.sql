--------------------------------------------------------
--  DDL for Package Body PQH_ASA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ASA_UPD" as
/* $Header: pqasarhi.pkb 115.3 2002/11/27 00:35:21 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_asa_upd.';  -- Global package name
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
  (p_rec                   in out nocopy pqh_asa_shd.g_rec_type
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
        (p_base_table_name => 'pqh_assign_accommodations_f'
        ,p_base_key_column => 'assignment_acco_id'
        ,p_base_key_value  => p_rec.assignment_acco_id
        );
    --
    --
    --
    -- Update the pqh_assign_accommodations_f Row
    --
    update  pqh_assign_accommodations_f
    set
     assignment_acco_id                   = p_rec.assignment_acco_id
    ,business_group_id                    = p_rec.business_group_id
    ,assignment_id                        = p_rec.assignment_id
    ,accommodation_given                  = p_rec.accommodation_given
    ,temporary_assignment                 = p_rec.temporary_assignment
    ,accommodation_id                     = p_rec.accommodation_id
    ,acceptance_date                      = p_rec.acceptance_date
    ,moving_date                          = p_rec.moving_date
    ,refusal_date                         = p_rec.refusal_date
    ,comments                             = p_rec.comments
    ,indemnity_entitlement                = p_rec.indemnity_entitlement
    ,indemnity_amount                     = p_rec.indemnity_amount
    ,type_of_payment                      = p_rec.type_of_payment
    ,information_category                 = p_rec.information_category
    ,information1                         = p_rec.information1
    ,information2                         = p_rec.information2
    ,information3                         = p_rec.information3
    ,information4                         = p_rec.information4
    ,information5                         = p_rec.information5
    ,information6                         = p_rec.information6
    ,information7                         = p_rec.information7
    ,information8                         = p_rec.information8
    ,information9                         = p_rec.information9
    ,information10                        = p_rec.information10
    ,information11                        = p_rec.information11
    ,information12                        = p_rec.information12
    ,information13                        = p_rec.information13
    ,information14                        = p_rec.information14
    ,information15                        = p_rec.information15
    ,information16                        = p_rec.information16
    ,information17                        = p_rec.information17
    ,information18                        = p_rec.information18
    ,information19                        = p_rec.information19
    ,information20                        = p_rec.information20
    ,information21                        = p_rec.information21
    ,information22                        = p_rec.information22
    ,information23                        = p_rec.information23
    ,information24                        = p_rec.information24
    ,information25                        = p_rec.information25
    ,information26                        = p_rec.information26
    ,information27                        = p_rec.information27
    ,information28                        = p_rec.information28
    ,information29                        = p_rec.information29
    ,information30                        = p_rec.information30
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
    ,attribute21                          = p_rec.attribute21
    ,attribute22                          = p_rec.attribute22
    ,attribute23                          = p_rec.attribute23
    ,attribute24                          = p_rec.attribute24
    ,attribute25                          = p_rec.attribute25
    ,attribute26                          = p_rec.attribute26
    ,attribute27                          = p_rec.attribute27
    ,attribute28                          = p_rec.attribute28
    ,attribute29                          = p_rec.attribute29
    ,attribute30                          = p_rec.attribute30
    ,object_version_number                = p_rec.object_version_number
    ,reason_for_no_acco                   = p_rec.reason_for_no_acco
    ,indemnity_currency                   = p_rec.indemnity_currency
    where   assignment_acco_id = p_rec.assignment_acco_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --
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
    --
    pqh_asa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_asa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec                      in out nocopy pqh_asa_shd.g_rec_type
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
  pqh_asa_upd.dt_update_dml
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
  (p_rec                     in out nocopy     pqh_asa_shd.g_rec_type
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
    pqh_asa_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.assignment_acco_id
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
      pqh_asa_del.delete_dml
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
    pqh_asa_ins.insert_dml
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
  (p_rec                   in out nocopy pqh_asa_shd.g_rec_type
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
  (p_rec                   in pqh_asa_shd.g_rec_type
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
    pqh_asa_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_assignment_acco_id
      => p_rec.assignment_acco_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_accommodation_given
      => p_rec.accommodation_given
      ,p_temporary_assignment
      => p_rec.temporary_assignment
      ,p_accommodation_id
      => p_rec.accommodation_id
      ,p_acceptance_date
      => p_rec.acceptance_date
      ,p_moving_date
      => p_rec.moving_date
      ,p_refusal_date
      => p_rec.refusal_date
      ,p_comments
      => p_rec.comments
      ,p_indemnity_entitlement
      => p_rec.indemnity_entitlement
      ,p_indemnity_amount
      => p_rec.indemnity_amount
      ,p_type_of_payment
      => p_rec.type_of_payment
      ,p_information_category
      => p_rec.information_category
      ,p_information1
      => p_rec.information1
      ,p_information2
      => p_rec.information2
      ,p_information3
      => p_rec.information3
      ,p_information4
      => p_rec.information4
      ,p_information5
      => p_rec.information5
      ,p_information6
      => p_rec.information6
      ,p_information7
      => p_rec.information7
      ,p_information8
      => p_rec.information8
      ,p_information9
      => p_rec.information9
      ,p_information10
      => p_rec.information10
      ,p_information11
      => p_rec.information11
      ,p_information12
      => p_rec.information12
      ,p_information13
      => p_rec.information13
      ,p_information14
      => p_rec.information14
      ,p_information15
      => p_rec.information15
      ,p_information16
      => p_rec.information16
      ,p_information17
      => p_rec.information17
      ,p_information18
      => p_rec.information18
      ,p_information19
      => p_rec.information19
      ,p_information20
      => p_rec.information20
      ,p_information21
      => p_rec.information21
      ,p_information22
      => p_rec.information22
      ,p_information23
      => p_rec.information23
      ,p_information24
      => p_rec.information24
      ,p_information25
      => p_rec.information25
      ,p_information26
      => p_rec.information26
      ,p_information27
      => p_rec.information27
      ,p_information28
      => p_rec.information28
      ,p_information29
      => p_rec.information29
      ,p_information30
      => p_rec.information30
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
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_reason_for_no_acco
      => p_rec.reason_for_no_acco
      ,p_indemnity_currency
      => p_rec.indemnity_currency
      ,p_effective_start_date_o
      => pqh_asa_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pqh_asa_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => pqh_asa_shd.g_old_rec.business_group_id
      ,p_assignment_id_o
      => pqh_asa_shd.g_old_rec.assignment_id
      ,p_accommodation_given_o
      => pqh_asa_shd.g_old_rec.accommodation_given
      ,p_temporary_assignment_o
      => pqh_asa_shd.g_old_rec.temporary_assignment
      ,p_accommodation_id_o
      => pqh_asa_shd.g_old_rec.accommodation_id
      ,p_acceptance_date_o
      => pqh_asa_shd.g_old_rec.acceptance_date
      ,p_moving_date_o
      => pqh_asa_shd.g_old_rec.moving_date
      ,p_refusal_date_o
      => pqh_asa_shd.g_old_rec.refusal_date
      ,p_comments_o
      => pqh_asa_shd.g_old_rec.comments
      ,p_indemnity_entitlement_o
      => pqh_asa_shd.g_old_rec.indemnity_entitlement
      ,p_indemnity_amount_o
      => pqh_asa_shd.g_old_rec.indemnity_amount
      ,p_type_of_payment_o
      => pqh_asa_shd.g_old_rec.type_of_payment
      ,p_information_category_o
      => pqh_asa_shd.g_old_rec.information_category
      ,p_information1_o
      => pqh_asa_shd.g_old_rec.information1
      ,p_information2_o
      => pqh_asa_shd.g_old_rec.information2
      ,p_information3_o
      => pqh_asa_shd.g_old_rec.information3
      ,p_information4_o
      => pqh_asa_shd.g_old_rec.information4
      ,p_information5_o
      => pqh_asa_shd.g_old_rec.information5
      ,p_information6_o
      => pqh_asa_shd.g_old_rec.information6
      ,p_information7_o
      => pqh_asa_shd.g_old_rec.information7
      ,p_information8_o
      => pqh_asa_shd.g_old_rec.information8
      ,p_information9_o
      => pqh_asa_shd.g_old_rec.information9
      ,p_information10_o
      => pqh_asa_shd.g_old_rec.information10
      ,p_information11_o
      => pqh_asa_shd.g_old_rec.information11
      ,p_information12_o
      => pqh_asa_shd.g_old_rec.information12
      ,p_information13_o
      => pqh_asa_shd.g_old_rec.information13
      ,p_information14_o
      => pqh_asa_shd.g_old_rec.information14
      ,p_information15_o
      => pqh_asa_shd.g_old_rec.information15
      ,p_information16_o
      => pqh_asa_shd.g_old_rec.information16
      ,p_information17_o
      => pqh_asa_shd.g_old_rec.information17
      ,p_information18_o
      => pqh_asa_shd.g_old_rec.information18
      ,p_information19_o
      => pqh_asa_shd.g_old_rec.information19
      ,p_information20_o
      => pqh_asa_shd.g_old_rec.information20
      ,p_information21_o
      => pqh_asa_shd.g_old_rec.information21
      ,p_information22_o
      => pqh_asa_shd.g_old_rec.information22
      ,p_information23_o
      => pqh_asa_shd.g_old_rec.information23
      ,p_information24_o
      => pqh_asa_shd.g_old_rec.information24
      ,p_information25_o
      => pqh_asa_shd.g_old_rec.information25
      ,p_information26_o
      => pqh_asa_shd.g_old_rec.information26
      ,p_information27_o
      => pqh_asa_shd.g_old_rec.information27
      ,p_information28_o
      => pqh_asa_shd.g_old_rec.information28
      ,p_information29_o
      => pqh_asa_shd.g_old_rec.information29
      ,p_information30_o
      => pqh_asa_shd.g_old_rec.information30
      ,p_attribute_category_o
      => pqh_asa_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pqh_asa_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pqh_asa_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pqh_asa_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pqh_asa_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pqh_asa_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pqh_asa_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pqh_asa_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pqh_asa_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pqh_asa_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pqh_asa_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pqh_asa_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pqh_asa_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pqh_asa_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pqh_asa_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pqh_asa_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pqh_asa_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pqh_asa_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pqh_asa_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pqh_asa_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pqh_asa_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pqh_asa_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pqh_asa_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pqh_asa_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pqh_asa_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pqh_asa_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pqh_asa_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pqh_asa_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pqh_asa_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pqh_asa_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pqh_asa_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => pqh_asa_shd.g_old_rec.object_version_number
      ,p_reason_for_no_acco_o
      => pqh_asa_shd.g_old_rec.reason_for_no_acco
      ,p_indemnity_currency_o
      => pqh_asa_shd.g_old_rec.indemnity_currency
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ASSIGN_ACCOMMODATIONS_F'
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
  (p_rec in out nocopy pqh_asa_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_asa_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqh_asa_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.accommodation_given = hr_api.g_varchar2) then
    p_rec.accommodation_given :=
    pqh_asa_shd.g_old_rec.accommodation_given;
  End If;
  If (p_rec.temporary_assignment = hr_api.g_varchar2) then
    p_rec.temporary_assignment :=
    pqh_asa_shd.g_old_rec.temporary_assignment;
  End If;
  If (p_rec.accommodation_id = hr_api.g_number) then
    p_rec.accommodation_id :=
    pqh_asa_shd.g_old_rec.accommodation_id;
  End If;
  If (p_rec.acceptance_date = hr_api.g_date) then
    p_rec.acceptance_date :=
    pqh_asa_shd.g_old_rec.acceptance_date;
  End If;
  If (p_rec.moving_date = hr_api.g_date) then
    p_rec.moving_date :=
    pqh_asa_shd.g_old_rec.moving_date;
  End If;
  If (p_rec.refusal_date = hr_api.g_date) then
    p_rec.refusal_date :=
    pqh_asa_shd.g_old_rec.refusal_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pqh_asa_shd.g_old_rec.comments;
  End If;
  If (p_rec.indemnity_entitlement = hr_api.g_varchar2) then
    p_rec.indemnity_entitlement :=
    pqh_asa_shd.g_old_rec.indemnity_entitlement;
  End If;
  If (p_rec.indemnity_amount = hr_api.g_number) then
    p_rec.indemnity_amount :=
    pqh_asa_shd.g_old_rec.indemnity_amount;
  End If;
  If (p_rec.type_of_payment = hr_api.g_varchar2) then
    p_rec.type_of_payment :=
    pqh_asa_shd.g_old_rec.type_of_payment;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    pqh_asa_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pqh_asa_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pqh_asa_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pqh_asa_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pqh_asa_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pqh_asa_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pqh_asa_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pqh_asa_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pqh_asa_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pqh_asa_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pqh_asa_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pqh_asa_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pqh_asa_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pqh_asa_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pqh_asa_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pqh_asa_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pqh_asa_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pqh_asa_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pqh_asa_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pqh_asa_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pqh_asa_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pqh_asa_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pqh_asa_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pqh_asa_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pqh_asa_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pqh_asa_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pqh_asa_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pqh_asa_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pqh_asa_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pqh_asa_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pqh_asa_shd.g_old_rec.information30;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pqh_asa_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pqh_asa_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pqh_asa_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pqh_asa_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pqh_asa_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pqh_asa_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pqh_asa_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pqh_asa_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pqh_asa_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pqh_asa_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pqh_asa_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pqh_asa_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pqh_asa_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pqh_asa_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pqh_asa_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pqh_asa_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pqh_asa_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pqh_asa_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pqh_asa_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pqh_asa_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pqh_asa_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    pqh_asa_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    pqh_asa_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    pqh_asa_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    pqh_asa_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    pqh_asa_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    pqh_asa_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    pqh_asa_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    pqh_asa_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    pqh_asa_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    pqh_asa_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.reason_for_no_acco = hr_api.g_varchar2) then
    p_rec.reason_for_no_acco :=
    pqh_asa_shd.g_old_rec.reason_for_no_acco;
  End If;
  If (p_rec.indemnity_currency = hr_api.g_varchar2) then
    p_rec.indemnity_currency :=
    pqh_asa_shd.g_old_rec.indemnity_currency;
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
  ,p_rec            in out nocopy pqh_asa_shd.g_rec_type
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
  pqh_asa_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_assignment_acco_id               => p_rec.assignment_acco_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pqh_asa_upd.convert_defs(p_rec);
  --
  pqh_asa_bus.update_validate
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
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_assignment_acco_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_accommodation_given          in     varchar2  default hr_api.g_varchar2
  ,p_temporary_assignment         in     varchar2  default hr_api.g_varchar2
  ,p_accommodation_id             in     number    default hr_api.g_number
  ,p_acceptance_date              in     date      default hr_api.g_date
  ,p_moving_date                  in     date      default hr_api.g_date
  ,p_refusal_date                 in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_entitlement        in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_amount             in     number    default hr_api.g_number
  ,p_type_of_payment              in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_no_acco           in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_currency           in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec         pqh_asa_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_asa_shd.convert_args
    (p_assignment_acco_id
    ,null
    ,null
    ,p_business_group_id
    ,p_assignment_id
    ,p_accommodation_given
    ,p_temporary_assignment
    ,p_accommodation_id
    ,p_acceptance_date
    ,p_moving_date
    ,p_refusal_date
    ,p_comments
    ,p_indemnity_entitlement
    ,p_indemnity_amount
    ,p_type_of_payment
    ,p_information_category
    ,p_information1
    ,p_information2
    ,p_information3
    ,p_information4
    ,p_information5
    ,p_information6
    ,p_information7
    ,p_information8
    ,p_information9
    ,p_information10
    ,p_information11
    ,p_information12
    ,p_information13
    ,p_information14
    ,p_information15
    ,p_information16
    ,p_information17
    ,p_information18
    ,p_information19
    ,p_information20
    ,p_information21
    ,p_information22
    ,p_information23
    ,p_information24
    ,p_information25
    ,p_information26
    ,p_information27
    ,p_information28
    ,p_information29
    ,p_information30
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
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,p_object_version_number
    ,p_reason_for_no_acco
    ,p_indemnity_currency
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_asa_upd.upd
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_asa_upd;

/
