--------------------------------------------------------
--  DDL for Package Body HR_LEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_UPD" as
/* $Header: hrleirhi.pkb 120.1.12010000.2 2009/01/28 09:08:21 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lei_upd.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy hr_lei_shd.g_rec_type) is
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
  -- hr_lei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the hr_location_extra_info Row
  --
  update hr_location_extra_info
  set
  location_extra_info_id            = p_rec.location_extra_info_id,
  information_type                  = p_rec.information_type,
  location_id                       = p_rec.location_id,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  lei_attribute_category            = p_rec.lei_attribute_category,
  lei_attribute1                    = p_rec.lei_attribute1,
  lei_attribute2                    = p_rec.lei_attribute2,
  lei_attribute3                    = p_rec.lei_attribute3,
  lei_attribute4                    = p_rec.lei_attribute4,
  lei_attribute5                    = p_rec.lei_attribute5,
  lei_attribute6                    = p_rec.lei_attribute6,
  lei_attribute7                    = p_rec.lei_attribute7,
  lei_attribute8                    = p_rec.lei_attribute8,
  lei_attribute9                    = p_rec.lei_attribute9,
  lei_attribute10                   = p_rec.lei_attribute10,
  lei_attribute11                   = p_rec.lei_attribute11,
  lei_attribute12                   = p_rec.lei_attribute12,
  lei_attribute13                   = p_rec.lei_attribute13,
  lei_attribute14                   = p_rec.lei_attribute14,
  lei_attribute15                   = p_rec.lei_attribute15,
  lei_attribute16                   = p_rec.lei_attribute16,
  lei_attribute17                   = p_rec.lei_attribute17,
  lei_attribute18                   = p_rec.lei_attribute18,
  lei_attribute19                   = p_rec.lei_attribute19,
  lei_attribute20                   = p_rec.lei_attribute20,
  lei_information_category          = p_rec.lei_information_category,
  lei_information1                  = p_rec.lei_information1,
  lei_information2                  = p_rec.lei_information2,
  lei_information3                  = p_rec.lei_information3,
  lei_information4                  = p_rec.lei_information4,
  lei_information5                  = p_rec.lei_information5,
  lei_information6                  = p_rec.lei_information6,
  lei_information7                  = p_rec.lei_information7,
  lei_information8                  = p_rec.lei_information8,
  lei_information9                  = p_rec.lei_information9,
  lei_information10                 = p_rec.lei_information10,
  lei_information11                 = p_rec.lei_information11,
  lei_information12                 = p_rec.lei_information12,
  lei_information13                 = p_rec.lei_information13,
  lei_information14                 = p_rec.lei_information14,
  lei_information15                 = p_rec.lei_information15,
  lei_information16                 = p_rec.lei_information16,
  lei_information17                 = p_rec.lei_information17,
  lei_information18                 = p_rec.lei_information18,
  lei_information19                 = p_rec.lei_information19,
  lei_information20                 = p_rec.lei_information20,
  lei_information21                 = p_rec.lei_information21,
  lei_information22                 = p_rec.lei_information22,
  lei_information23                 = p_rec.lei_information23,
  lei_information24                 = p_rec.lei_information24,
  lei_information25                 = p_rec.lei_information25,
  lei_information26                 = p_rec.lei_information26,
  lei_information27                 = p_rec.lei_information27,
  lei_information28                 = p_rec.lei_information28,
  lei_information29                 = p_rec.lei_information29,
  lei_information30                 = p_rec.lei_information30,
  object_version_number             = p_rec.object_version_number
  where location_extra_info_id = p_rec.location_extra_info_id;
  --
  -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in hr_lei_shd.g_rec_type) is
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     hr_lei_rku.after_update	(
	p_location_extra_info_id	=>	p_rec.location_extra_info_id,
	p_information_type		=>	p_rec.information_type,
	p_location_id			=>	p_rec.location_id,
	p_request_id			=>	p_rec.request_id,
	p_program_application_id	=>	p_rec.program_application_id,
	p_program_id			=>	p_rec.program_id,
	p_program_update_date		=>	p_rec.program_update_date,
	p_lei_attribute_category	=>	p_rec.lei_attribute_category,
	p_lei_attribute1		=>	p_rec.lei_attribute1,
	p_lei_attribute2		=>	p_rec.lei_attribute2,
	p_lei_attribute3		=>	p_rec.lei_attribute3,
	p_lei_attribute4		=>	p_rec.lei_attribute4,
	p_lei_attribute5		=>	p_rec.lei_attribute5,
	p_lei_attribute6		=>	p_rec.lei_attribute6,
	p_lei_attribute7		=>	p_rec.lei_attribute7,
	p_lei_attribute8		=>	p_rec.lei_attribute8,
	p_lei_attribute9		=>	p_rec.lei_attribute9,
	p_lei_attribute10		=>	p_rec.lei_attribute10,
	p_lei_attribute11		=>	p_rec.lei_attribute11,
	p_lei_attribute12		=>	p_rec.lei_attribute12,
	p_lei_attribute13		=>	p_rec.lei_attribute13,
	p_lei_attribute14		=>	p_rec.lei_attribute14,
	p_lei_attribute15		=>	p_rec.lei_attribute15,
	p_lei_attribute16		=>	p_rec.lei_attribute16,
	p_lei_attribute17		=>	p_rec.lei_attribute17,
	p_lei_attribute18		=>	p_rec.lei_attribute18,
	p_lei_attribute19		=>	p_rec.lei_attribute19,
	p_lei_attribute20		=>	p_rec.lei_attribute20,
	p_lei_information_category	=>	p_rec.lei_information_category,
	p_lei_information1		=>	p_rec.lei_information1,
	p_lei_information2		=>	p_rec.lei_information2,
	p_lei_information3		=>	p_rec.lei_information3,
	p_lei_information4		=>	p_rec.lei_information4,
	p_lei_information5		=>	p_rec.lei_information5,
	p_lei_information6		=>	p_rec.lei_information6,
	p_lei_information7		=>	p_rec.lei_information7,
	p_lei_information8		=>	p_rec.lei_information8,
	p_lei_information9		=>	p_rec.lei_information9,
	p_lei_information10		=>	p_rec.lei_information10,
	p_lei_information11		=>	p_rec.lei_information11,
	p_lei_information12		=>	p_rec.lei_information12,
	p_lei_information13		=>	p_rec.lei_information13,
	p_lei_information14		=>	p_rec.lei_information14,
	p_lei_information15		=>	p_rec.lei_information15,
	p_lei_information16		=>	p_rec.lei_information16,
	p_lei_information17		=>	p_rec.lei_information17,
	p_lei_information18		=>	p_rec.lei_information18,
	p_lei_information19		=>	p_rec.lei_information19,
	p_lei_information20		=>	p_rec.lei_information20,
	p_lei_information21		=>	p_rec.lei_information21,
	p_lei_information22		=>	p_rec.lei_information22,
	p_lei_information23		=>	p_rec.lei_information23,
	p_lei_information24		=>	p_rec.lei_information24,
	p_lei_information25		=>	p_rec.lei_information25,
	p_lei_information26		=>	p_rec.lei_information26,
	p_lei_information27		=>	p_rec.lei_information27,
	p_lei_information28		=>	p_rec.lei_information28,
	p_lei_information29		=>	p_rec.lei_information29,
	p_lei_information30		=>	p_rec.lei_information30,
	p_information_type_o		=>	hr_lei_shd.g_old_rec.information_type,
	p_location_id_o			=>	hr_lei_shd.g_old_rec.location_id,
	p_request_id_o			=>	hr_lei_shd.g_old_rec.request_id,
	p_program_application_id_o	=>	hr_lei_shd.g_old_rec.program_application_id,
	p_program_id_o			=>	hr_lei_shd.g_old_rec.program_id,
	p_program_update_date_o		=>	hr_lei_shd.g_old_rec.program_update_date,
	p_lei_attribute_category_o	=>	hr_lei_shd.g_old_rec.lei_attribute_category,
	p_lei_attribute1_o		=>	hr_lei_shd.g_old_rec.lei_attribute1,
	p_lei_attribute2_o		=>	hr_lei_shd.g_old_rec.lei_attribute2,
	p_lei_attribute3_o		=>	hr_lei_shd.g_old_rec.lei_attribute3,
	p_lei_attribute4_o		=>	hr_lei_shd.g_old_rec.lei_attribute4,
	p_lei_attribute5_o		=>	hr_lei_shd.g_old_rec.lei_attribute5,
	p_lei_attribute6_o		=>	hr_lei_shd.g_old_rec.lei_attribute6,
	p_lei_attribute7_o		=>	hr_lei_shd.g_old_rec.lei_attribute7,
	p_lei_attribute8_o		=>	hr_lei_shd.g_old_rec.lei_attribute8,
	p_lei_attribute9_o		=>	hr_lei_shd.g_old_rec.lei_attribute9,
	p_lei_attribute10_o		=>	hr_lei_shd.g_old_rec.lei_attribute10,
	p_lei_attribute11_o		=>	hr_lei_shd.g_old_rec.lei_attribute11,
	p_lei_attribute12_o		=>	hr_lei_shd.g_old_rec.lei_attribute12,
	p_lei_attribute13_o		=>	hr_lei_shd.g_old_rec.lei_attribute13,
	p_lei_attribute14_o		=>	hr_lei_shd.g_old_rec.lei_attribute14,
	p_lei_attribute15_o		=>	hr_lei_shd.g_old_rec.lei_attribute15,
	p_lei_attribute16_o		=>	hr_lei_shd.g_old_rec.lei_attribute16,
	p_lei_attribute17_o		=>	hr_lei_shd.g_old_rec.lei_attribute17,
	p_lei_attribute18_o		=>	hr_lei_shd.g_old_rec.lei_attribute18,
	p_lei_attribute19_o		=>	hr_lei_shd.g_old_rec.lei_attribute19,
	p_lei_attribute20_o		=>	hr_lei_shd.g_old_rec.lei_attribute20,
	p_lei_information_category_o	=>	hr_lei_shd.g_old_rec.lei_information_category,
	p_lei_information1_o		=>	hr_lei_shd.g_old_rec.lei_information1,
	p_lei_information2_o		=>	hr_lei_shd.g_old_rec.lei_information2,
	p_lei_information3_o		=>	hr_lei_shd.g_old_rec.lei_information3,
	p_lei_information4_o		=>	hr_lei_shd.g_old_rec.lei_information4,
	p_lei_information5_o		=>	hr_lei_shd.g_old_rec.lei_information5,
	p_lei_information6_o		=>	hr_lei_shd.g_old_rec.lei_information6,
	p_lei_information7_o		=>	hr_lei_shd.g_old_rec.lei_information7,
	p_lei_information8_o		=>	hr_lei_shd.g_old_rec.lei_information8,
	p_lei_information9_o		=>	hr_lei_shd.g_old_rec.lei_information9,
	p_lei_information10_o		=>	hr_lei_shd.g_old_rec.lei_information10,
	p_lei_information11_o		=>	hr_lei_shd.g_old_rec.lei_information11,
	p_lei_information12_o		=>	hr_lei_shd.g_old_rec.lei_information12,
	p_lei_information13_o		=>	hr_lei_shd.g_old_rec.lei_information13,
	p_lei_information14_o		=>	hr_lei_shd.g_old_rec.lei_information14,
	p_lei_information15_o		=>	hr_lei_shd.g_old_rec.lei_information15,
	p_lei_information16_o		=>	hr_lei_shd.g_old_rec.lei_information16,
	p_lei_information17_o		=>	hr_lei_shd.g_old_rec.lei_information17,
	p_lei_information18_o		=>	hr_lei_shd.g_old_rec.lei_information18,
	p_lei_information19_o		=>	hr_lei_shd.g_old_rec.lei_information19,
	p_lei_information20_o		=>	hr_lei_shd.g_old_rec.lei_information20,
	p_lei_information21_o		=>	hr_lei_shd.g_old_rec.lei_information21,
	p_lei_information22_o		=>	hr_lei_shd.g_old_rec.lei_information22,
	p_lei_information23_o		=>	hr_lei_shd.g_old_rec.lei_information23,
	p_lei_information24_o		=>	hr_lei_shd.g_old_rec.lei_information24,
	p_lei_information25_o		=>	hr_lei_shd.g_old_rec.lei_information25,
	p_lei_information26_o		=>	hr_lei_shd.g_old_rec.lei_information26,
	p_lei_information27_o		=>	hr_lei_shd.g_old_rec.lei_information27,
	p_lei_information28_o		=>	hr_lei_shd.g_old_rec.lei_information28,
	p_lei_information29_o		=>	hr_lei_shd.g_old_rec.lei_information29,
	p_lei_information30_o		=>	hr_lei_shd.g_old_rec.lei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'HR_LOCATION_EXTRA_INFO'
			,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy hr_lei_shd.g_rec_type) is
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
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    hr_lei_shd.g_old_rec.information_type;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    hr_lei_shd.g_old_rec.location_id;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    hr_lei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    hr_lei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    hr_lei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    hr_lei_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.lei_attribute_category = hr_api.g_varchar2) then
    p_rec.lei_attribute_category :=
    hr_lei_shd.g_old_rec.lei_attribute_category;
  End If;
  If (p_rec.lei_attribute1 = hr_api.g_varchar2) then
    p_rec.lei_attribute1 :=
    hr_lei_shd.g_old_rec.lei_attribute1;
  End If;
  If (p_rec.lei_attribute2 = hr_api.g_varchar2) then
    p_rec.lei_attribute2 :=
    hr_lei_shd.g_old_rec.lei_attribute2;
  End If;
  If (p_rec.lei_attribute3 = hr_api.g_varchar2) then
    p_rec.lei_attribute3 :=
    hr_lei_shd.g_old_rec.lei_attribute3;
  End If;
  If (p_rec.lei_attribute4 = hr_api.g_varchar2) then
    p_rec.lei_attribute4 :=
    hr_lei_shd.g_old_rec.lei_attribute4;
  End If;
  If (p_rec.lei_attribute5 = hr_api.g_varchar2) then
    p_rec.lei_attribute5 :=
    hr_lei_shd.g_old_rec.lei_attribute5;
  End If;
  If (p_rec.lei_attribute6 = hr_api.g_varchar2) then
    p_rec.lei_attribute6 :=
    hr_lei_shd.g_old_rec.lei_attribute6;
  End If;
  If (p_rec.lei_attribute7 = hr_api.g_varchar2) then
    p_rec.lei_attribute7 :=
    hr_lei_shd.g_old_rec.lei_attribute7;
  End If;
  If (p_rec.lei_attribute8 = hr_api.g_varchar2) then
    p_rec.lei_attribute8 :=
    hr_lei_shd.g_old_rec.lei_attribute8;
  End If;
  If (p_rec.lei_attribute9 = hr_api.g_varchar2) then
    p_rec.lei_attribute9 :=
    hr_lei_shd.g_old_rec.lei_attribute9;
  End If;
  If (p_rec.lei_attribute10 = hr_api.g_varchar2) then
    p_rec.lei_attribute10 :=
    hr_lei_shd.g_old_rec.lei_attribute10;
  End If;
  If (p_rec.lei_attribute11 = hr_api.g_varchar2) then
    p_rec.lei_attribute11 :=
    hr_lei_shd.g_old_rec.lei_attribute11;
  End If;
  If (p_rec.lei_attribute12 = hr_api.g_varchar2) then
    p_rec.lei_attribute12 :=
    hr_lei_shd.g_old_rec.lei_attribute12;
  End If;
  If (p_rec.lei_attribute13 = hr_api.g_varchar2) then
    p_rec.lei_attribute13 :=
    hr_lei_shd.g_old_rec.lei_attribute13;
  End If;
  If (p_rec.lei_attribute14 = hr_api.g_varchar2) then
    p_rec.lei_attribute14 :=
    hr_lei_shd.g_old_rec.lei_attribute14;
  End If;
  If (p_rec.lei_attribute15 = hr_api.g_varchar2) then
    p_rec.lei_attribute15 :=
    hr_lei_shd.g_old_rec.lei_attribute15;
  End If;
  If (p_rec.lei_attribute16 = hr_api.g_varchar2) then
    p_rec.lei_attribute16 :=
    hr_lei_shd.g_old_rec.lei_attribute16;
  End If;
  If (p_rec.lei_attribute17 = hr_api.g_varchar2) then
    p_rec.lei_attribute17 :=
    hr_lei_shd.g_old_rec.lei_attribute17;
  End If;
  If (p_rec.lei_attribute18 = hr_api.g_varchar2) then
    p_rec.lei_attribute18 :=
    hr_lei_shd.g_old_rec.lei_attribute18;
  End If;
  If (p_rec.lei_attribute19 = hr_api.g_varchar2) then
    p_rec.lei_attribute19 :=
    hr_lei_shd.g_old_rec.lei_attribute19;
  End If;
  If (p_rec.lei_attribute20 = hr_api.g_varchar2) then
    p_rec.lei_attribute20 :=
    hr_lei_shd.g_old_rec.lei_attribute20;
  End If;
  If (p_rec.lei_information_category = hr_api.g_varchar2) then
    p_rec.lei_information_category :=
    hr_lei_shd.g_old_rec.lei_information_category;
  End If;
  If (p_rec.lei_information1 = hr_api.g_varchar2) then
    p_rec.lei_information1 :=
    hr_lei_shd.g_old_rec.lei_information1;
  End If;
  If (p_rec.lei_information2 = hr_api.g_varchar2) then
    p_rec.lei_information2 :=
    hr_lei_shd.g_old_rec.lei_information2;
  End If;
  If (p_rec.lei_information3 = hr_api.g_varchar2) then
    p_rec.lei_information3 :=
    hr_lei_shd.g_old_rec.lei_information3;
  End If;
  If (p_rec.lei_information4 = hr_api.g_varchar2) then
    p_rec.lei_information4 :=
    hr_lei_shd.g_old_rec.lei_information4;
  End If;
  If (p_rec.lei_information5 = hr_api.g_varchar2) then
    p_rec.lei_information5 :=
    hr_lei_shd.g_old_rec.lei_information5;
  End If;
  If (p_rec.lei_information6 = hr_api.g_varchar2) then
    p_rec.lei_information6 :=
    hr_lei_shd.g_old_rec.lei_information6;
  End If;
  If (p_rec.lei_information7 = hr_api.g_varchar2) then
    p_rec.lei_information7 :=
    hr_lei_shd.g_old_rec.lei_information7;
  End If;
  If (p_rec.lei_information8 = hr_api.g_varchar2) then
    p_rec.lei_information8 :=
    hr_lei_shd.g_old_rec.lei_information8;
  End If;
  If (p_rec.lei_information9 = hr_api.g_varchar2) then
    p_rec.lei_information9 :=
    hr_lei_shd.g_old_rec.lei_information9;
  End If;
  If (p_rec.lei_information10 = hr_api.g_varchar2) then
    p_rec.lei_information10 :=
    hr_lei_shd.g_old_rec.lei_information10;
  End If;
  If (p_rec.lei_information11 = hr_api.g_varchar2) then
    p_rec.lei_information11 :=
    hr_lei_shd.g_old_rec.lei_information11;
  End If;
  If (p_rec.lei_information12 = hr_api.g_varchar2) then
    p_rec.lei_information12 :=
    hr_lei_shd.g_old_rec.lei_information12;
  End If;
  If (p_rec.lei_information13 = hr_api.g_varchar2) then
    p_rec.lei_information13 :=
    hr_lei_shd.g_old_rec.lei_information13;
  End If;
  If (p_rec.lei_information14 = hr_api.g_varchar2) then
    p_rec.lei_information14 :=
    hr_lei_shd.g_old_rec.lei_information14;
  End If;
  If (p_rec.lei_information15 = hr_api.g_varchar2) then
    p_rec.lei_information15 :=
    hr_lei_shd.g_old_rec.lei_information15;
  End If;
  If (p_rec.lei_information16 = hr_api.g_varchar2) then
    p_rec.lei_information16 :=
    hr_lei_shd.g_old_rec.lei_information16;
  End If;
  If (p_rec.lei_information17 = hr_api.g_varchar2) then
    p_rec.lei_information17 :=
    hr_lei_shd.g_old_rec.lei_information17;
  End If;
  If (p_rec.lei_information18 = hr_api.g_varchar2) then
    p_rec.lei_information18 :=
    hr_lei_shd.g_old_rec.lei_information18;
  End If;
  If (p_rec.lei_information19 = hr_api.g_varchar2) then
    p_rec.lei_information19 :=
    hr_lei_shd.g_old_rec.lei_information19;
  End If;
  If (p_rec.lei_information20 = hr_api.g_varchar2) then
    p_rec.lei_information20 :=
    hr_lei_shd.g_old_rec.lei_information20;
  End If;
  If (p_rec.lei_information21 = hr_api.g_varchar2) then
    p_rec.lei_information21 :=
    hr_lei_shd.g_old_rec.lei_information21;
  End If;
  If (p_rec.lei_information22 = hr_api.g_varchar2) then
    p_rec.lei_information22 :=
    hr_lei_shd.g_old_rec.lei_information22;
  End If;
  If (p_rec.lei_information23 = hr_api.g_varchar2) then
    p_rec.lei_information23 :=
    hr_lei_shd.g_old_rec.lei_information23;
  End If;
  If (p_rec.lei_information24 = hr_api.g_varchar2) then
    p_rec.lei_information24 :=
    hr_lei_shd.g_old_rec.lei_information24;
  End If;
  If (p_rec.lei_information25 = hr_api.g_varchar2) then
    p_rec.lei_information25 :=
    hr_lei_shd.g_old_rec.lei_information25;
  End If;
  If (p_rec.lei_information26 = hr_api.g_varchar2) then
    p_rec.lei_information26 :=
    hr_lei_shd.g_old_rec.lei_information26;
  End If;
  If (p_rec.lei_information27 = hr_api.g_varchar2) then
    p_rec.lei_information27 :=
    hr_lei_shd.g_old_rec.lei_information27;
  End If;
  If (p_rec.lei_information28 = hr_api.g_varchar2) then
    p_rec.lei_information28 :=
    hr_lei_shd.g_old_rec.lei_information28;
  End If;
  If (p_rec.lei_information29 = hr_api.g_varchar2) then
    p_rec.lei_information29 :=
    hr_lei_shd.g_old_rec.lei_information29;
  End If;
  If (p_rec.lei_information30 = hr_api.g_varchar2) then
    p_rec.lei_information30 :=
    hr_lei_shd.g_old_rec.lei_information30;
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
  p_rec        in out nocopy hr_lei_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_hr_lei;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  hr_lei_shd.lck
	(
	p_rec.location_extra_info_id,
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
  hr_lei_bus.update_validate(p_rec);
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
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_hr_lei;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_location_extra_info_id       in number,
  p_information_type             in varchar2         default hr_api.g_varchar2,
  p_location_id                  in number           default hr_api.g_number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_lei_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_lei_attribute1               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute2               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute3               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute4               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute5               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute6               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute7               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute8               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute9               in varchar2         default hr_api.g_varchar2,
  p_lei_attribute10              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute11              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute12              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute13              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute14              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute15              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute16              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute17              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute18              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute19              in varchar2         default hr_api.g_varchar2,
  p_lei_attribute20              in varchar2         default hr_api.g_varchar2,
  p_lei_information_category     in varchar2         default hr_api.g_varchar2,
  p_lei_information1             in varchar2         default hr_api.g_varchar2,
  p_lei_information2             in varchar2         default hr_api.g_varchar2,
  p_lei_information3             in varchar2         default hr_api.g_varchar2,
  p_lei_information4             in varchar2         default hr_api.g_varchar2,
  p_lei_information5             in varchar2         default hr_api.g_varchar2,
  p_lei_information6             in varchar2         default hr_api.g_varchar2,
  p_lei_information7             in varchar2         default hr_api.g_varchar2,
  p_lei_information8             in varchar2         default hr_api.g_varchar2,
  p_lei_information9             in varchar2         default hr_api.g_varchar2,
  p_lei_information10            in varchar2         default hr_api.g_varchar2,
  p_lei_information11            in varchar2         default hr_api.g_varchar2,
  p_lei_information12            in varchar2         default hr_api.g_varchar2,
  p_lei_information13            in varchar2         default hr_api.g_varchar2,
  p_lei_information14            in varchar2         default hr_api.g_varchar2,
  p_lei_information15            in varchar2         default hr_api.g_varchar2,
  p_lei_information16            in varchar2         default hr_api.g_varchar2,
  p_lei_information17            in varchar2         default hr_api.g_varchar2,
  p_lei_information18            in varchar2         default hr_api.g_varchar2,
  p_lei_information19            in varchar2         default hr_api.g_varchar2,
  p_lei_information20            in varchar2         default hr_api.g_varchar2,
  p_lei_information21            in varchar2         default hr_api.g_varchar2,
  p_lei_information22            in varchar2         default hr_api.g_varchar2,
  p_lei_information23            in varchar2         default hr_api.g_varchar2,
  p_lei_information24            in varchar2         default hr_api.g_varchar2,
  p_lei_information25            in varchar2         default hr_api.g_varchar2,
  p_lei_information26            in varchar2         default hr_api.g_varchar2,
  p_lei_information27            in varchar2         default hr_api.g_varchar2,
  p_lei_information28            in varchar2         default hr_api.g_varchar2,
  p_lei_information29            in varchar2         default hr_api.g_varchar2,
  p_lei_information30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  hr_lei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_lei_shd.convert_args
  (
  p_location_extra_info_id,
  p_information_type,
  p_location_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_lei_attribute_category,
  p_lei_attribute1,
  p_lei_attribute2,
  p_lei_attribute3,
  p_lei_attribute4,
  p_lei_attribute5,
  p_lei_attribute6,
  p_lei_attribute7,
  p_lei_attribute8,
  p_lei_attribute9,
  p_lei_attribute10,
  p_lei_attribute11,
  p_lei_attribute12,
  p_lei_attribute13,
  p_lei_attribute14,
  p_lei_attribute15,
  p_lei_attribute16,
  p_lei_attribute17,
  p_lei_attribute18,
  p_lei_attribute19,
  p_lei_attribute20,
  p_lei_information_category,
  p_lei_information1,
  p_lei_information2,
  p_lei_information3,
  p_lei_information4,
  p_lei_information5,
  p_lei_information6,
  p_lei_information7,
  p_lei_information8,
  p_lei_information9,
  p_lei_information10,
  p_lei_information11,
  p_lei_information12,
  p_lei_information13,
  p_lei_information14,
  p_lei_information15,
  p_lei_information16,
  p_lei_information17,
  p_lei_information18,
  p_lei_information19,
  p_lei_information20,
  p_lei_information21,
  p_lei_information22,
  p_lei_information23,
  p_lei_information24,
  p_lei_information25,
  p_lei_information26,
  p_lei_information27,
  p_lei_information28,
  p_lei_information29,
  p_lei_information30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_lei_upd;

/
