--------------------------------------------------------
--  DDL for Package Body PQP_SHP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_UPD" as
/* $Header: pqshprhi.pkb 115.8 2003/02/17 22:14:48 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_shp_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_shp_shd.g_rec_type
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
  pqp_shp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_service_history_periods Row
  --
  update pqp_service_history_periods
    set
     service_history_period_id       = p_rec.service_history_period_id
    ,business_group_id               = p_rec.business_group_id
    ,assignment_id                   = p_rec.assignment_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,employer_name                   = p_rec.employer_name
    ,employer_address                = p_rec.employer_address
    ,employer_type                   = p_rec.employer_type
    ,employer_subtype                = p_rec.employer_subtype
    ,period_years                    = p_rec.period_years
    ,period_days                     = p_rec.period_days
    ,description                     = p_rec.description
    ,continuous_service              = p_rec.continuous_service
    ,all_assignments                 = p_rec.all_assignments
    ,object_version_number           = p_rec.object_version_number
    ,shp_attribute_category          = p_rec.shp_attribute_category
    ,shp_attribute1                  = p_rec.shp_attribute1
    ,shp_attribute2                  = p_rec.shp_attribute2
    ,shp_attribute3                  = p_rec.shp_attribute3
    ,shp_attribute4                  = p_rec.shp_attribute4
    ,shp_attribute5                  = p_rec.shp_attribute5
    ,shp_attribute6                  = p_rec.shp_attribute6
    ,shp_attribute7                  = p_rec.shp_attribute7
    ,shp_attribute8                  = p_rec.shp_attribute8
    ,shp_attribute9                  = p_rec.shp_attribute9
    ,shp_attribute10                 = p_rec.shp_attribute10
    ,shp_attribute11                 = p_rec.shp_attribute11
    ,shp_attribute12                 = p_rec.shp_attribute12
    ,shp_attribute13                 = p_rec.shp_attribute13
    ,shp_attribute14                 = p_rec.shp_attribute14
    ,shp_attribute15                 = p_rec.shp_attribute15
    ,shp_attribute16                 = p_rec.shp_attribute16
    ,shp_attribute17                 = p_rec.shp_attribute17
    ,shp_attribute18                 = p_rec.shp_attribute18
    ,shp_attribute19                 = p_rec.shp_attribute19
    ,shp_attribute20                 = p_rec.shp_attribute20
    ,shp_information_category        = p_rec.shp_information_category
    ,shp_information1                = p_rec.shp_information1
    ,shp_information2                = p_rec.shp_information2
    ,shp_information3                = p_rec.shp_information3
    ,shp_information4                = p_rec.shp_information4
    ,shp_information5                = p_rec.shp_information5
    ,shp_information6                = p_rec.shp_information6
    ,shp_information7                = p_rec.shp_information7
    ,shp_information8                = p_rec.shp_information8
    ,shp_information9                = p_rec.shp_information9
    ,shp_information10               = p_rec.shp_information10
    ,shp_information11               = p_rec.shp_information11
    ,shp_information12               = p_rec.shp_information12
    ,shp_information13               = p_rec.shp_information13
    ,shp_information14               = p_rec.shp_information14
    ,shp_information15               = p_rec.shp_information15
    ,shp_information16               = p_rec.shp_information16
    ,shp_information17               = p_rec.shp_information17
    ,shp_information18               = p_rec.shp_information18
    ,shp_information19               = p_rec.shp_information19
    ,shp_information20               = p_rec.shp_information20
    where service_history_period_id = p_rec.service_history_period_id;
  --
  pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_shp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_shp_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqp_shp_shd.g_rec_type
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
  (
  p_rec                          in pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_shp_rku.after_update
      (p_service_history_period_id
      => p_rec.service_history_period_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_employer_name
      => p_rec.employer_name
      ,p_employer_address
      => p_rec.employer_address
      ,p_employer_type
      => p_rec.employer_type
      ,p_employer_subtype
      => p_rec.employer_subtype
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_description
      => p_rec.description
      ,p_continuous_service
      => p_rec.continuous_service
      ,p_all_assignments
      => p_rec.all_assignments
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_shp_attribute_category
      => p_rec.shp_attribute_category
      ,p_shp_attribute1
      => p_rec.shp_attribute1
      ,p_shp_attribute2
      => p_rec.shp_attribute2
      ,p_shp_attribute3
      => p_rec.shp_attribute3
      ,p_shp_attribute4
      => p_rec.shp_attribute4
      ,p_shp_attribute5
      => p_rec.shp_attribute5
      ,p_shp_attribute6
      => p_rec.shp_attribute6
      ,p_shp_attribute7
      => p_rec.shp_attribute7
      ,p_shp_attribute8
      => p_rec.shp_attribute8
      ,p_shp_attribute9
      => p_rec.shp_attribute9
      ,p_shp_attribute10
      => p_rec.shp_attribute10
      ,p_shp_attribute11
      => p_rec.shp_attribute11
      ,p_shp_attribute12
      => p_rec.shp_attribute12
      ,p_shp_attribute13
      => p_rec.shp_attribute13
      ,p_shp_attribute14
      => p_rec.shp_attribute14
      ,p_shp_attribute15
      => p_rec.shp_attribute15
      ,p_shp_attribute16
      => p_rec.shp_attribute16
      ,p_shp_attribute17
      => p_rec.shp_attribute17
      ,p_shp_attribute18
      => p_rec.shp_attribute18
      ,p_shp_attribute19
      => p_rec.shp_attribute19
      ,p_shp_attribute20
      => p_rec.shp_attribute20
      ,p_shp_information_category
      => p_rec.shp_information_category
      ,p_shp_information1
      => p_rec.shp_information1
      ,p_shp_information2
      => p_rec.shp_information2
      ,p_shp_information3
      => p_rec.shp_information3
      ,p_shp_information4
      => p_rec.shp_information4
      ,p_shp_information5
      => p_rec.shp_information5
      ,p_shp_information6
      => p_rec.shp_information6
      ,p_shp_information7
      => p_rec.shp_information7
      ,p_shp_information8
      => p_rec.shp_information8
      ,p_shp_information9
      => p_rec.shp_information9
      ,p_shp_information10
      => p_rec.shp_information10
      ,p_shp_information11
      => p_rec.shp_information11
      ,p_shp_information12
      => p_rec.shp_information12
      ,p_shp_information13
      => p_rec.shp_information13
      ,p_shp_information14
      => p_rec.shp_information14
      ,p_shp_information15
      => p_rec.shp_information15
      ,p_shp_information16
      => p_rec.shp_information16
      ,p_shp_information17
      => p_rec.shp_information17
      ,p_shp_information18
      => p_rec.shp_information18
      ,p_shp_information19
      => p_rec.shp_information19
      ,p_shp_information20
      => p_rec.shp_information20
      ,p_business_group_id_o
      => pqp_shp_shd.g_old_rec.business_group_id
      ,p_assignment_id_o
      => pqp_shp_shd.g_old_rec.assignment_id
      ,p_start_date_o
      => pqp_shp_shd.g_old_rec.start_date
      ,p_end_date_o
      => pqp_shp_shd.g_old_rec.end_date
      ,p_employer_name_o
      => pqp_shp_shd.g_old_rec.employer_name
      ,p_employer_address_o
      => pqp_shp_shd.g_old_rec.employer_address
      ,p_employer_type_o
      => pqp_shp_shd.g_old_rec.employer_type
      ,p_employer_subtype_o
      => pqp_shp_shd.g_old_rec.employer_subtype
      ,p_period_years_o
      => pqp_shp_shd.g_old_rec.period_years
      ,p_period_days_o
      => pqp_shp_shd.g_old_rec.period_days
      ,p_description_o
      => pqp_shp_shd.g_old_rec.description
      ,p_continuous_service_o
      => pqp_shp_shd.g_old_rec.continuous_service
      ,p_all_assignments_o
      => pqp_shp_shd.g_old_rec.all_assignments
      ,p_object_version_number_o
      => pqp_shp_shd.g_old_rec.object_version_number
      ,p_shp_attribute_category_o
      => pqp_shp_shd.g_old_rec.shp_attribute_category
      ,p_shp_attribute1_o
      => pqp_shp_shd.g_old_rec.shp_attribute1
      ,p_shp_attribute2_o
      => pqp_shp_shd.g_old_rec.shp_attribute2
      ,p_shp_attribute3_o
      => pqp_shp_shd.g_old_rec.shp_attribute3
      ,p_shp_attribute4_o
      => pqp_shp_shd.g_old_rec.shp_attribute4
      ,p_shp_attribute5_o
      => pqp_shp_shd.g_old_rec.shp_attribute5
      ,p_shp_attribute6_o
      => pqp_shp_shd.g_old_rec.shp_attribute6
      ,p_shp_attribute7_o
      => pqp_shp_shd.g_old_rec.shp_attribute7
      ,p_shp_attribute8_o
      => pqp_shp_shd.g_old_rec.shp_attribute8
      ,p_shp_attribute9_o
      => pqp_shp_shd.g_old_rec.shp_attribute9
      ,p_shp_attribute10_o
      => pqp_shp_shd.g_old_rec.shp_attribute10
      ,p_shp_attribute11_o
      => pqp_shp_shd.g_old_rec.shp_attribute11
      ,p_shp_attribute12_o
      => pqp_shp_shd.g_old_rec.shp_attribute12
      ,p_shp_attribute13_o
      => pqp_shp_shd.g_old_rec.shp_attribute13
      ,p_shp_attribute14_o
      => pqp_shp_shd.g_old_rec.shp_attribute14
      ,p_shp_attribute15_o
      => pqp_shp_shd.g_old_rec.shp_attribute15
      ,p_shp_attribute16_o
      => pqp_shp_shd.g_old_rec.shp_attribute16
      ,p_shp_attribute17_o
      => pqp_shp_shd.g_old_rec.shp_attribute17
      ,p_shp_attribute18_o
      => pqp_shp_shd.g_old_rec.shp_attribute18
      ,p_shp_attribute19_o
      => pqp_shp_shd.g_old_rec.shp_attribute19
      ,p_shp_attribute20_o
      => pqp_shp_shd.g_old_rec.shp_attribute20
      ,p_shp_information_category_o
      => pqp_shp_shd.g_old_rec.shp_information_category
      ,p_shp_information1_o
      => pqp_shp_shd.g_old_rec.shp_information1
      ,p_shp_information2_o
      => pqp_shp_shd.g_old_rec.shp_information2
      ,p_shp_information3_o
      => pqp_shp_shd.g_old_rec.shp_information3
      ,p_shp_information4_o
      => pqp_shp_shd.g_old_rec.shp_information4
      ,p_shp_information5_o
      => pqp_shp_shd.g_old_rec.shp_information5
      ,p_shp_information6_o
      => pqp_shp_shd.g_old_rec.shp_information6
      ,p_shp_information7_o
      => pqp_shp_shd.g_old_rec.shp_information7
      ,p_shp_information8_o
      => pqp_shp_shd.g_old_rec.shp_information8
      ,p_shp_information9_o
      => pqp_shp_shd.g_old_rec.shp_information9
      ,p_shp_information10_o
      => pqp_shp_shd.g_old_rec.shp_information10
      ,p_shp_information11_o
      => pqp_shp_shd.g_old_rec.shp_information11
      ,p_shp_information12_o
      => pqp_shp_shd.g_old_rec.shp_information12
      ,p_shp_information13_o
      => pqp_shp_shd.g_old_rec.shp_information13
      ,p_shp_information14_o
      => pqp_shp_shd.g_old_rec.shp_information14
      ,p_shp_information15_o
      => pqp_shp_shd.g_old_rec.shp_information15
      ,p_shp_information16_o
      => pqp_shp_shd.g_old_rec.shp_information16
      ,p_shp_information17_o
      => pqp_shp_shd.g_old_rec.shp_information17
      ,p_shp_information18_o
      => pqp_shp_shd.g_old_rec.shp_information18
      ,p_shp_information19_o
      => pqp_shp_shd.g_old_rec.shp_information19
      ,p_shp_information20_o
      => pqp_shp_shd.g_old_rec.shp_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_SERVICE_HISTORY_PERIODS'
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
  (p_rec in out nocopy pqp_shp_shd.g_rec_type
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
    pqp_shp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_shp_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    pqp_shp_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    pqp_shp_shd.g_old_rec.end_date;
  End If;
  If (p_rec.employer_name = hr_api.g_varchar2) then
    p_rec.employer_name :=
    pqp_shp_shd.g_old_rec.employer_name;
  End If;
  If (p_rec.employer_address = hr_api.g_varchar2) then
    p_rec.employer_address :=
    pqp_shp_shd.g_old_rec.employer_address;
  End If;
  If (p_rec.employer_type = hr_api.g_varchar2) then
    p_rec.employer_type :=
    pqp_shp_shd.g_old_rec.employer_type;
  End If;
  If (p_rec.employer_subtype = hr_api.g_varchar2) then
    p_rec.employer_subtype :=
    pqp_shp_shd.g_old_rec.employer_subtype;
  End If;
  If (p_rec.period_years = hr_api.g_number) then
    p_rec.period_years :=
    pqp_shp_shd.g_old_rec.period_years;
  End If;
  If (p_rec.period_days = hr_api.g_number) then
    p_rec.period_days :=
    pqp_shp_shd.g_old_rec.period_days;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pqp_shp_shd.g_old_rec.description;
  End If;
  If (p_rec.continuous_service = hr_api.g_varchar2) then
    p_rec.continuous_service :=
    pqp_shp_shd.g_old_rec.continuous_service;
  End If;
  If (p_rec.all_assignments = hr_api.g_varchar2) then
    p_rec.all_assignments :=
    pqp_shp_shd.g_old_rec.all_assignments;
  End If;
  If (p_rec.shp_attribute_category = hr_api.g_varchar2) then
    p_rec.shp_attribute_category :=
    pqp_shp_shd.g_old_rec.shp_attribute_category;
  End If;
  If (p_rec.shp_attribute1 = hr_api.g_varchar2) then
    p_rec.shp_attribute1 :=
    pqp_shp_shd.g_old_rec.shp_attribute1;
  End If;
  If (p_rec.shp_attribute2 = hr_api.g_varchar2) then
    p_rec.shp_attribute2 :=
    pqp_shp_shd.g_old_rec.shp_attribute2;
  End If;
  If (p_rec.shp_attribute3 = hr_api.g_varchar2) then
    p_rec.shp_attribute3 :=
    pqp_shp_shd.g_old_rec.shp_attribute3;
  End If;
  If (p_rec.shp_attribute4 = hr_api.g_varchar2) then
    p_rec.shp_attribute4 :=
    pqp_shp_shd.g_old_rec.shp_attribute4;
  End If;
  If (p_rec.shp_attribute5 = hr_api.g_varchar2) then
    p_rec.shp_attribute5 :=
    pqp_shp_shd.g_old_rec.shp_attribute5;
  End If;
  If (p_rec.shp_attribute6 = hr_api.g_varchar2) then
    p_rec.shp_attribute6 :=
    pqp_shp_shd.g_old_rec.shp_attribute6;
  End If;
  If (p_rec.shp_attribute7 = hr_api.g_varchar2) then
    p_rec.shp_attribute7 :=
    pqp_shp_shd.g_old_rec.shp_attribute7;
  End If;
  If (p_rec.shp_attribute8 = hr_api.g_varchar2) then
    p_rec.shp_attribute8 :=
    pqp_shp_shd.g_old_rec.shp_attribute8;
  End If;
  If (p_rec.shp_attribute9 = hr_api.g_varchar2) then
    p_rec.shp_attribute9 :=
    pqp_shp_shd.g_old_rec.shp_attribute9;
  End If;
  If (p_rec.shp_attribute10 = hr_api.g_varchar2) then
    p_rec.shp_attribute10 :=
    pqp_shp_shd.g_old_rec.shp_attribute10;
  End If;
  If (p_rec.shp_attribute11 = hr_api.g_varchar2) then
    p_rec.shp_attribute11 :=
    pqp_shp_shd.g_old_rec.shp_attribute11;
  End If;
  If (p_rec.shp_attribute12 = hr_api.g_varchar2) then
    p_rec.shp_attribute12 :=
    pqp_shp_shd.g_old_rec.shp_attribute12;
  End If;
  If (p_rec.shp_attribute13 = hr_api.g_varchar2) then
    p_rec.shp_attribute13 :=
    pqp_shp_shd.g_old_rec.shp_attribute13;
  End If;
  If (p_rec.shp_attribute14 = hr_api.g_varchar2) then
    p_rec.shp_attribute14 :=
    pqp_shp_shd.g_old_rec.shp_attribute14;
  End If;
  If (p_rec.shp_attribute15 = hr_api.g_varchar2) then
    p_rec.shp_attribute15 :=
    pqp_shp_shd.g_old_rec.shp_attribute15;
  End If;
  If (p_rec.shp_attribute16 = hr_api.g_varchar2) then
    p_rec.shp_attribute16 :=
    pqp_shp_shd.g_old_rec.shp_attribute16;
  End If;
  If (p_rec.shp_attribute17 = hr_api.g_varchar2) then
    p_rec.shp_attribute17 :=
    pqp_shp_shd.g_old_rec.shp_attribute17;
  End If;
  If (p_rec.shp_attribute18 = hr_api.g_varchar2) then
    p_rec.shp_attribute18 :=
    pqp_shp_shd.g_old_rec.shp_attribute18;
  End If;
  If (p_rec.shp_attribute19 = hr_api.g_varchar2) then
    p_rec.shp_attribute19 :=
    pqp_shp_shd.g_old_rec.shp_attribute19;
  End If;
  If (p_rec.shp_attribute20 = hr_api.g_varchar2) then
    p_rec.shp_attribute20 :=
    pqp_shp_shd.g_old_rec.shp_attribute20;
  End If;
  If (p_rec.shp_information_category = hr_api.g_varchar2) then
    p_rec.shp_information_category :=
    pqp_shp_shd.g_old_rec.shp_information_category;
  End If;
  If (p_rec.shp_information1 = hr_api.g_varchar2) then
    p_rec.shp_information1 :=
    pqp_shp_shd.g_old_rec.shp_information1;
  End If;
  If (p_rec.shp_information2 = hr_api.g_varchar2) then
    p_rec.shp_information2 :=
    pqp_shp_shd.g_old_rec.shp_information2;
  End If;
  If (p_rec.shp_information3 = hr_api.g_varchar2) then
    p_rec.shp_information3 :=
    pqp_shp_shd.g_old_rec.shp_information3;
  End If;
  If (p_rec.shp_information4 = hr_api.g_varchar2) then
    p_rec.shp_information4 :=
    pqp_shp_shd.g_old_rec.shp_information4;
  End If;
  If (p_rec.shp_information5 = hr_api.g_varchar2) then
    p_rec.shp_information5 :=
    pqp_shp_shd.g_old_rec.shp_information5;
  End If;
  If (p_rec.shp_information6 = hr_api.g_varchar2) then
    p_rec.shp_information6 :=
    pqp_shp_shd.g_old_rec.shp_information6;
  End If;
  If (p_rec.shp_information7 = hr_api.g_varchar2) then
    p_rec.shp_information7 :=
    pqp_shp_shd.g_old_rec.shp_information7;
  End If;
  If (p_rec.shp_information8 = hr_api.g_varchar2) then
    p_rec.shp_information8 :=
    pqp_shp_shd.g_old_rec.shp_information8;
  End If;
  If (p_rec.shp_information9 = hr_api.g_varchar2) then
    p_rec.shp_information9 :=
    pqp_shp_shd.g_old_rec.shp_information9;
  End If;
  If (p_rec.shp_information10 = hr_api.g_varchar2) then
    p_rec.shp_information10 :=
    pqp_shp_shd.g_old_rec.shp_information10;
  End If;
  If (p_rec.shp_information11 = hr_api.g_varchar2) then
    p_rec.shp_information11 :=
    pqp_shp_shd.g_old_rec.shp_information11;
  End If;
  If (p_rec.shp_information12 = hr_api.g_varchar2) then
    p_rec.shp_information12 :=
    pqp_shp_shd.g_old_rec.shp_information12;
  End If;
  If (p_rec.shp_information13 = hr_api.g_varchar2) then
    p_rec.shp_information13 :=
    pqp_shp_shd.g_old_rec.shp_information13;
  End If;
  If (p_rec.shp_information14 = hr_api.g_varchar2) then
    p_rec.shp_information14 :=
    pqp_shp_shd.g_old_rec.shp_information14;
  End If;
  If (p_rec.shp_information15 = hr_api.g_varchar2) then
    p_rec.shp_information15 :=
    pqp_shp_shd.g_old_rec.shp_information15;
  End If;
  If (p_rec.shp_information16 = hr_api.g_varchar2) then
    p_rec.shp_information16 :=
    pqp_shp_shd.g_old_rec.shp_information16;
  End If;
  If (p_rec.shp_information17 = hr_api.g_varchar2) then
    p_rec.shp_information17 :=
    pqp_shp_shd.g_old_rec.shp_information17;
  End If;
  If (p_rec.shp_information18 = hr_api.g_varchar2) then
    p_rec.shp_information18 :=
    pqp_shp_shd.g_old_rec.shp_information18;
  End If;
  If (p_rec.shp_information19 = hr_api.g_varchar2) then
    p_rec.shp_information19 :=
    pqp_shp_shd.g_old_rec.shp_information19;
  End If;
  If (p_rec.shp_information20 = hr_api.g_varchar2) then
    p_rec.shp_information20 :=
    pqp_shp_shd.g_old_rec.shp_information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec                          in out nocopy pqp_shp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_shp_shd.lck
    (p_rec.service_history_period_id
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
  pqp_shp_bus.update_validate
     (
     p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pqp_shp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_shp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_shp_upd.post_update
     (
      p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_service_history_period_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_employer_name                in     varchar2  default hr_api.g_varchar2
  ,p_employer_address             in     varchar2  default hr_api.g_varchar2
  ,p_employer_type                in     varchar2  default hr_api.g_varchar2
  ,p_employer_subtype             in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_continuous_service           in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_shp_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_shp_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_shp_information1             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information2             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information3             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information4             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information5             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information6             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information7             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information8             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information9             in     varchar2  default hr_api.g_varchar2
  ,p_shp_information10            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information11            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information12            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information13            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information14            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information15            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information16            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information17            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information18            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information19            in     varchar2  default hr_api.g_varchar2
  ,p_shp_information20            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pqp_shp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_shp_shd.convert_args
  (p_service_history_period_id
  ,p_business_group_id
  ,p_assignment_id
  ,p_start_date
  ,p_end_date
  ,p_employer_name
  ,p_employer_address
  ,p_employer_type
  ,p_employer_subtype
  ,p_period_years
  ,p_period_days
  ,p_description
  ,p_continuous_service
  ,p_all_assignments
  ,p_object_version_number
  ,p_shp_attribute_category
  ,p_shp_attribute1
  ,p_shp_attribute2
  ,p_shp_attribute3
  ,p_shp_attribute4
  ,p_shp_attribute5
  ,p_shp_attribute6
  ,p_shp_attribute7
  ,p_shp_attribute8
  ,p_shp_attribute9
  ,p_shp_attribute10
  ,p_shp_attribute11
  ,p_shp_attribute12
  ,p_shp_attribute13
  ,p_shp_attribute14
  ,p_shp_attribute15
  ,p_shp_attribute16
  ,p_shp_attribute17
  ,p_shp_attribute18
  ,p_shp_attribute19
  ,p_shp_attribute20
  ,p_shp_information_category
  ,p_shp_information1
  ,p_shp_information2
  ,p_shp_information3
  ,p_shp_information4
  ,p_shp_information5
  ,p_shp_information6
  ,p_shp_information7
  ,p_shp_information8
  ,p_shp_information9
  ,p_shp_information10
  ,p_shp_information11
  ,p_shp_information12
  ,p_shp_information13
  ,p_shp_information14
  ,p_shp_information15
  ,p_shp_information16
  ,p_shp_information17
  ,p_shp_information18
  ,p_shp_information19
  ,p_shp_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_shp_upd.upd
     (
     l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_shp_upd;

/
