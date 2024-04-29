--------------------------------------------------------
--  DDL for Package Body GHR_REI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_UPD" as
/* $Header: ghreirhi.pkb 120.2.12010000.2 2008/09/02 07:19:59 vmididho ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_rei_upd.';  -- Global package name
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
--      perform dml). Not Required Changed by DARORA
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy  ghr_rei_shd.g_rec_type) is
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
  -- Update the ghr_pa_request_extra_info Row
  --
  update ghr_pa_request_extra_info
  set
  pa_request_extra_info_id          = p_rec.pa_request_extra_info_id,
  pa_request_id                     = p_rec.pa_request_id,
  information_type                  = p_rec.information_type,
  rei_attribute_category            = p_rec.rei_attribute_category,
  rei_attribute1                    = p_rec.rei_attribute1,
  rei_attribute2                    = p_rec.rei_attribute2,
  rei_attribute3                    = p_rec.rei_attribute3,
  rei_attribute4                    = p_rec.rei_attribute4,
  rei_attribute5                    = p_rec.rei_attribute5,
  rei_attribute6                    = p_rec.rei_attribute6,
  rei_attribute7                    = p_rec.rei_attribute7,
  rei_attribute8                    = p_rec.rei_attribute8,
  rei_attribute9                    = p_rec.rei_attribute9,
  rei_attribute10                   = p_rec.rei_attribute10,
  rei_attribute11                   = p_rec.rei_attribute11,
  rei_attribute12                   = p_rec.rei_attribute12,
  rei_attribute13                   = p_rec.rei_attribute13,
  rei_attribute14                   = p_rec.rei_attribute14,
  rei_attribute15                   = p_rec.rei_attribute15,
  rei_attribute16                   = p_rec.rei_attribute16,
  rei_attribute17                   = p_rec.rei_attribute17,
  rei_attribute18                   = p_rec.rei_attribute18,
  rei_attribute19                   = p_rec.rei_attribute19,
  rei_attribute20                   = p_rec.rei_attribute20,
  rei_information_category          = p_rec.rei_information_category,
  rei_information1                  = p_rec.rei_information1,
  rei_information2                  = p_rec.rei_information2,
  rei_information3                  = p_rec.rei_information3,
  rei_information4                  = p_rec.rei_information4,
  rei_information5                  = p_rec.rei_information5,
  rei_information6                  = p_rec.rei_information6,
  rei_information7                  = p_rec.rei_information7,
  rei_information8                  = p_rec.rei_information8,
  rei_information9                  = p_rec.rei_information9,
  rei_information10                 = p_rec.rei_information10,
  rei_information11                 = p_rec.rei_information11,
  rei_information12                 = p_rec.rei_information12,
  rei_information13                 = p_rec.rei_information13,
  rei_information14                 = p_rec.rei_information14,
  rei_information15                 = p_rec.rei_information15,
  rei_information16                 = p_rec.rei_information16,
  rei_information17                 = p_rec.rei_information17,
  rei_information18                 = p_rec.rei_information18,
  rei_information19                 = p_rec.rei_information19,
  rei_information20                 = p_rec.rei_information20,
  rei_information21                 = p_rec.rei_information21,
  rei_information22                 = p_rec.rei_information22,
  rei_information28                 = p_rec.rei_information28,
  rei_information29                 = p_rec.rei_information29,
  rei_information23                 = p_rec.rei_information23,
  rei_information24                 = p_rec.rei_information24,
  rei_information25                 = p_rec.rei_information25,
  rei_information26                 = p_rec.rei_information26,
  rei_information27                 = p_rec.rei_information27,
  rei_information30                 = p_rec.rei_information30,
  object_version_number             = p_rec.object_version_number,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date
  where pa_request_extra_info_id = p_rec.pa_request_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ghr_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ghr_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ghr_rei_shd.constraint_error
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
Procedure pre_update(p_rec in ghr_rei_shd.g_rec_type) is
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
Procedure post_update(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_rei_rku.after_update	(
		p_pa_request_extra_info_id 	=>	p_rec.pa_request_extra_info_id,
		p_pa_request_id 			=>	p_rec.pa_request_id 		,
		p_information_type 		=>	p_rec.information_type 		,
		p_rei_attribute_category	=>	p_rec.rei_attribute_category 	,
		p_rei_attribute1 			=>	p_rec.rei_attribute1	 	,
		p_rei_attribute2 			=>	p_rec.rei_attribute2 		,
		p_rei_attribute3 			=>	p_rec.rei_attribute3 		,
		p_rei_attribute4 			=>	p_rec.rei_attribute4 		,
		p_rei_attribute5 			=>	p_rec.rei_attribute5 		,
		p_rei_attribute6 			=>	p_rec.rei_attribute6 		,
		p_rei_attribute7 			=>	p_rec.rei_attribute7 		,
		p_rei_attribute8 			=>	p_rec.rei_attribute8 		,
		p_rei_attribute9 			=>	p_rec.rei_attribute9 		,
		p_rei_attribute10 		=>	p_rec.rei_attribute10 		,
		p_rei_attribute11 		=>	p_rec.rei_attribute11 		,
		p_rei_attribute12 		=>	p_rec.rei_attribute12 		,
		p_rei_attribute13 		=>	p_rec.rei_attribute13 		,
		p_rei_attribute14 		=>	p_rec.rei_attribute14 		,
		p_rei_attribute15 		=>	p_rec.rei_attribute15 		,
		p_rei_attribute16 		=>	p_rec.rei_attribute16 		,
		p_rei_attribute17 		=>	p_rec.rei_attribute17 		,
		p_rei_attribute18 		=>	p_rec.rei_attribute18 		,
		p_rei_attribute19		 	=>	p_rec.rei_attribute19 		,
		p_rei_attribute20	 		=>	p_rec.rei_attribute20 		,
		p_rei_information_category 	=>	p_rec.rei_information_category,
		p_rei_information1	 	=>	p_rec.rei_information1 		,
		p_rei_information2 		=>	p_rec.rei_information2 		,
		p_rei_information3 		=>	p_rec.rei_information3 		,
		p_rei_information4 		=>	p_rec.rei_information4 		,
		p_rei_information5 		=>	p_rec.rei_information5 		,
		p_rei_information6 		=>	p_rec.rei_information6 		,
		p_rei_information7 		=>	p_rec.rei_information7 		,
		p_rei_information8 		=>	p_rec.rei_information8 		,
		p_rei_information9 		=>	p_rec.rei_information9 		,
		p_rei_information10 		=>	p_rec.rei_information10 	,
		p_rei_information11 		=>	p_rec.rei_information11 	,
		p_rei_information12 		=>	p_rec.rei_information12 	,
		p_rei_information13 		=>	p_rec.rei_information13 	,
		p_rei_information14 		=>	p_rec.rei_information14 	,
		p_rei_information15	 	=>	p_rec.rei_information15 	,
		p_rei_information16 		=>	p_rec.rei_information16 	,
		p_rei_information17	 	=>	p_rec.rei_information17 	,
		p_rei_information18 		=>	p_rec.rei_information18 	,
		p_rei_information19 		=>	p_rec.rei_information19 	,
		p_rei_information20 		=>	p_rec.rei_information20 	,
		p_rei_information21 		=>	p_rec.rei_information21 	,
		p_rei_information22 		=>	p_rec.rei_information22 	,
		p_rei_information28 		=>	p_rec.rei_information28 	,
		p_rei_information29 		=>	p_rec.rei_information29 	,
		p_rei_information23 		=>	p_rec.rei_information23 	,
		p_rei_information24 		=>	p_rec.rei_information24 	,
		p_rei_information25 		=>	p_rec.rei_information25 	,
		p_rei_information26 		=>	p_rec.rei_information26 	,
		p_rei_information27 		=>	p_rec.rei_information27 	,
		p_rei_information30 		=>	p_rec.rei_information30 	,
		p_request_id 			=>	p_rec.request_id 			,
		p_program_application_id 	=>	p_rec.program_application_id 	,
		p_program_id 			=>	p_rec.program_id 			,
		p_program_update_date 		=>	p_rec.program_update_date 	,
		p_pa_request_id_o		 	=>	ghr_rei_shd.g_old_rec.pa_request_id 		,
		p_information_type_o 		=>	ghr_rei_shd.g_old_rec.information_type		,
		p_rei_attribute_category_o	=>	ghr_rei_shd.g_old_rec.rei_attribute_category	,
		p_rei_attribute1_o	 	=>	ghr_rei_shd.g_old_rec.rei_attribute1		,
		p_rei_attribute2_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute2 		,
		p_rei_attribute3_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute3 		,
		p_rei_attribute4_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute4 		,
		p_rei_attribute5_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute5 		,
		p_rei_attribute6_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute6 		,
		p_rei_attribute7_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute7 		,
		p_rei_attribute8_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute8 		,
		p_rei_attribute9_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute9 		,
		p_rei_attribute10_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute10 		,
		p_rei_attribute11_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute11 		,
		p_rei_attribute12_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute12 		,
		p_rei_attribute13_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute13 		,
		p_rei_attribute14_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute14 		,
		p_rei_attribute15_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute15 		,
		p_rei_attribute16_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute16 		,
		p_rei_attribute17_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute17 		,
		p_rei_attribute18_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute18 		,
		p_rei_attribute19_o		=>	ghr_rei_shd.g_old_rec.rei_attribute19		,
		p_rei_attribute20_o		=>	ghr_rei_shd.g_old_rec.rei_attribute20		,
		p_rei_information_category_o 	=>	ghr_rei_shd.g_old_rec.rei_information_category	,
		p_rei_information1_o		=>	ghr_rei_shd.g_old_rec.rei_information1 		,
		p_rei_information2_o 		=>	ghr_rei_shd.g_old_rec.rei_information2 		,
		p_rei_information3_o 		=>	ghr_rei_shd.g_old_rec.rei_information3 		,
		p_rei_information4_o 		=>	ghr_rei_shd.g_old_rec.rei_information4 		,
		p_rei_information5_o 		=>	ghr_rei_shd.g_old_rec.rei_information5 		,
		p_rei_information6_o 		=>	ghr_rei_shd.g_old_rec.rei_information6 		,
		p_rei_information7_o 		=>	ghr_rei_shd.g_old_rec.rei_information7 		,
		p_rei_information8_o 		=>	ghr_rei_shd.g_old_rec.rei_information8 		,
		p_rei_information9_o 		=>	ghr_rei_shd.g_old_rec.rei_information9 		,
		p_rei_information10_o 		=>	ghr_rei_shd.g_old_rec.rei_information10 		,
		p_rei_information11_o 		=>	ghr_rei_shd.g_old_rec.rei_information11 		,
		p_rei_information12_o 		=>	ghr_rei_shd.g_old_rec.rei_information12 		,
		p_rei_information13_o 		=>	ghr_rei_shd.g_old_rec.rei_information13 		,
		p_rei_information14_o 		=>	ghr_rei_shd.g_old_rec.rei_information14 		,
		p_rei_information15_o		=>	ghr_rei_shd.g_old_rec.rei_information15 		,
		p_rei_information16_o 		=>	ghr_rei_shd.g_old_rec.rei_information16 		,
		p_rei_information17_o		=>	ghr_rei_shd.g_old_rec.rei_information17 		,
		p_rei_information18_o 		=>	ghr_rei_shd.g_old_rec.rei_information18 		,
		p_rei_information19_o 		=>	ghr_rei_shd.g_old_rec.rei_information19 		,
		p_rei_information20_o 		=>	ghr_rei_shd.g_old_rec.rei_information20 		,
		p_rei_information21_o 		=>	ghr_rei_shd.g_old_rec.rei_information21 		,
		p_rei_information22_o 		=>	ghr_rei_shd.g_old_rec.rei_information22 		,
		p_rei_information28_o 		=>	ghr_rei_shd.g_old_rec.rei_information28 		,
		p_rei_information29_o 		=>	ghr_rei_shd.g_old_rec.rei_information29 		,
		p_rei_information23_o 		=>	ghr_rei_shd.g_old_rec.rei_information23 		,
		p_rei_information24_o 		=>	ghr_rei_shd.g_old_rec.rei_information24 		,
		p_rei_information25_o 		=>	ghr_rei_shd.g_old_rec.rei_information25 		,
		p_rei_information26_o 		=>	ghr_rei_shd.g_old_rec.rei_information26 		,
		p_rei_information27_o 		=>	ghr_rei_shd.g_old_rec.rei_information27 		,
		p_rei_information30_o 		=>	ghr_rei_shd.g_old_rec.rei_information30 		,
		p_request_id_o			=>	ghr_rei_shd.g_old_rec.request_id			,
		p_program_application_id_o 	=>	ghr_rei_shd.g_old_rec.program_application_id	,
		p_program_id_o 			=>	ghr_rei_shd.g_old_rec.program_id			,
		p_program_update_date_o 	=>	ghr_rei_shd.g_old_rec.program_update_date
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_REQUEST_EXTRA_INFO'
			,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
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
Procedure convert_defs(p_rec in out nocopy  ghr_rei_shd.g_rec_type) is
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
  If (p_rec.pa_request_id = hr_api.g_number) then
    p_rec.pa_request_id :=
    ghr_rei_shd.g_old_rec.pa_request_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    ghr_rei_shd.g_old_rec.information_type;
  End If;
  If (p_rec.rei_attribute_category = hr_api.g_varchar2) then
    p_rec.rei_attribute_category :=
    ghr_rei_shd.g_old_rec.rei_attribute_category;
  End If;
  If (p_rec.rei_attribute1 = hr_api.g_varchar2) then
    p_rec.rei_attribute1 :=
    ghr_rei_shd.g_old_rec.rei_attribute1;
  End If;
  If (p_rec.rei_attribute2 = hr_api.g_varchar2) then
    p_rec.rei_attribute2 :=
    ghr_rei_shd.g_old_rec.rei_attribute2;
  End If;
  If (p_rec.rei_attribute3 = hr_api.g_varchar2) then
    p_rec.rei_attribute3 :=
    ghr_rei_shd.g_old_rec.rei_attribute3;
  End If;
  If (p_rec.rei_attribute4 = hr_api.g_varchar2) then
    p_rec.rei_attribute4 :=
    ghr_rei_shd.g_old_rec.rei_attribute4;
  End If;
  If (p_rec.rei_attribute5 = hr_api.g_varchar2) then
    p_rec.rei_attribute5 :=
    ghr_rei_shd.g_old_rec.rei_attribute5;
  End If;
  If (p_rec.rei_attribute6 = hr_api.g_varchar2) then
    p_rec.rei_attribute6 :=
    ghr_rei_shd.g_old_rec.rei_attribute6;
  End If;
  If (p_rec.rei_attribute7 = hr_api.g_varchar2) then
    p_rec.rei_attribute7 :=
    ghr_rei_shd.g_old_rec.rei_attribute7;
  End If;
  If (p_rec.rei_attribute8 = hr_api.g_varchar2) then
    p_rec.rei_attribute8 :=
    ghr_rei_shd.g_old_rec.rei_attribute8;
  End If;
  If (p_rec.rei_attribute9 = hr_api.g_varchar2) then
    p_rec.rei_attribute9 :=
    ghr_rei_shd.g_old_rec.rei_attribute9;
  End If;
  If (p_rec.rei_attribute10 = hr_api.g_varchar2) then
    p_rec.rei_attribute10 :=
    ghr_rei_shd.g_old_rec.rei_attribute10;
  End If;
  If (p_rec.rei_attribute11 = hr_api.g_varchar2) then
    p_rec.rei_attribute11 :=
    ghr_rei_shd.g_old_rec.rei_attribute11;
  End If;
  If (p_rec.rei_attribute12 = hr_api.g_varchar2) then
    p_rec.rei_attribute12 :=
    ghr_rei_shd.g_old_rec.rei_attribute12;
  End If;
  If (p_rec.rei_attribute13 = hr_api.g_varchar2) then
    p_rec.rei_attribute13 :=
    ghr_rei_shd.g_old_rec.rei_attribute13;
  End If;
  If (p_rec.rei_attribute14 = hr_api.g_varchar2) then
    p_rec.rei_attribute14 :=
    ghr_rei_shd.g_old_rec.rei_attribute14;
  End If;
  If (p_rec.rei_attribute15 = hr_api.g_varchar2) then
    p_rec.rei_attribute15 :=
    ghr_rei_shd.g_old_rec.rei_attribute15;
  End If;
  If (p_rec.rei_attribute16 = hr_api.g_varchar2) then
    p_rec.rei_attribute16 :=
    ghr_rei_shd.g_old_rec.rei_attribute16;
  End If;
  If (p_rec.rei_attribute17 = hr_api.g_varchar2) then
    p_rec.rei_attribute17 :=
    ghr_rei_shd.g_old_rec.rei_attribute17;
  End If;
  If (p_rec.rei_attribute18 = hr_api.g_varchar2) then
    p_rec.rei_attribute18 :=
    ghr_rei_shd.g_old_rec.rei_attribute18;
  End If;
  If (p_rec.rei_attribute19 = hr_api.g_varchar2) then
    p_rec.rei_attribute19 :=
    ghr_rei_shd.g_old_rec.rei_attribute19;
  End If;
  If (p_rec.rei_attribute20 = hr_api.g_varchar2) then
    p_rec.rei_attribute20 :=
    ghr_rei_shd.g_old_rec.rei_attribute20;
  End If;
  If (p_rec.rei_information_category = hr_api.g_varchar2) then
    p_rec.rei_information_category :=
    ghr_rei_shd.g_old_rec.rei_information_category;
  End If;
  If (p_rec.rei_information1 = hr_api.g_varchar2) then
    p_rec.rei_information1 :=
    ghr_rei_shd.g_old_rec.rei_information1;
  End If;
  If (p_rec.rei_information2 = hr_api.g_varchar2) then
    p_rec.rei_information2 :=
    ghr_rei_shd.g_old_rec.rei_information2;
  End If;
  If (p_rec.rei_information3 = hr_api.g_varchar2) then
    p_rec.rei_information3 :=
    ghr_rei_shd.g_old_rec.rei_information3;
  End If;
  If (p_rec.rei_information4 = hr_api.g_varchar2) then
    p_rec.rei_information4 :=
    ghr_rei_shd.g_old_rec.rei_information4;
  End If;
  If (p_rec.rei_information5 = hr_api.g_varchar2) then
    p_rec.rei_information5 :=
    ghr_rei_shd.g_old_rec.rei_information5;
  End If;
  If (p_rec.rei_information6 = hr_api.g_varchar2) then
    p_rec.rei_information6 :=
    ghr_rei_shd.g_old_rec.rei_information6;
  End If;
  If (p_rec.rei_information7 = hr_api.g_varchar2) then
    p_rec.rei_information7 :=
    ghr_rei_shd.g_old_rec.rei_information7;
  End If;
  If (p_rec.rei_information8 = hr_api.g_varchar2) then
    p_rec.rei_information8 :=
    ghr_rei_shd.g_old_rec.rei_information8;
  End If;
  If (p_rec.rei_information9 = hr_api.g_varchar2) then
    p_rec.rei_information9 :=
    ghr_rei_shd.g_old_rec.rei_information9;
  End If;
  If (p_rec.rei_information10 = hr_api.g_varchar2) then
    p_rec.rei_information10 :=
    ghr_rei_shd.g_old_rec.rei_information10;
  End If;
  If (p_rec.rei_information11 = hr_api.g_varchar2) then
    p_rec.rei_information11 :=
    ghr_rei_shd.g_old_rec.rei_information11;
  End If;
  If (p_rec.rei_information12 = hr_api.g_varchar2) then
    p_rec.rei_information12 :=
    ghr_rei_shd.g_old_rec.rei_information12;
  End If;
  If (p_rec.rei_information13 = hr_api.g_varchar2) then
    p_rec.rei_information13 :=
    ghr_rei_shd.g_old_rec.rei_information13;
  End If;
  If (p_rec.rei_information14 = hr_api.g_varchar2) then
    p_rec.rei_information14 :=
    ghr_rei_shd.g_old_rec.rei_information14;
  End If;
  If (p_rec.rei_information15 = hr_api.g_varchar2) then
    p_rec.rei_information15 :=
    ghr_rei_shd.g_old_rec.rei_information15;
  End If;
  If (p_rec.rei_information16 = hr_api.g_varchar2) then
    p_rec.rei_information16 :=
    ghr_rei_shd.g_old_rec.rei_information16;
  End If;
  If (p_rec.rei_information17 = hr_api.g_varchar2) then
    p_rec.rei_information17 :=
    ghr_rei_shd.g_old_rec.rei_information17;
  End If;
  If (p_rec.rei_information18 = hr_api.g_varchar2) then
    p_rec.rei_information18 :=
    ghr_rei_shd.g_old_rec.rei_information18;
  End If;
  If (p_rec.rei_information19 = hr_api.g_varchar2) then
    p_rec.rei_information19 :=
    ghr_rei_shd.g_old_rec.rei_information19;
  End If;
  If (p_rec.rei_information20 = hr_api.g_varchar2) then
    p_rec.rei_information20 :=
    ghr_rei_shd.g_old_rec.rei_information20;
  End If;
  If (p_rec.rei_information21 = hr_api.g_varchar2) then
    p_rec.rei_information21 :=
    ghr_rei_shd.g_old_rec.rei_information21;
  End If;
  If (p_rec.rei_information22 = hr_api.g_varchar2) then
    p_rec.rei_information22 :=
    ghr_rei_shd.g_old_rec.rei_information22;
  End If;
  If (p_rec.rei_information28 = hr_api.g_varchar2) then
    p_rec.rei_information28 :=
    ghr_rei_shd.g_old_rec.rei_information28;
  End If;
  If (p_rec.rei_information29 = hr_api.g_varchar2) then
    p_rec.rei_information29 :=
    ghr_rei_shd.g_old_rec.rei_information29;
  End If;
  If (p_rec.rei_information23 = hr_api.g_varchar2) then
    p_rec.rei_information23 :=
    ghr_rei_shd.g_old_rec.rei_information23;
  End If;
  If (p_rec.rei_information24 = hr_api.g_varchar2) then
    p_rec.rei_information24 :=
    ghr_rei_shd.g_old_rec.rei_information24;
  End If;
  If (p_rec.rei_information25 = hr_api.g_varchar2) then
    p_rec.rei_information25 :=
    ghr_rei_shd.g_old_rec.rei_information25;
  End If;
  If (p_rec.rei_information26 = hr_api.g_varchar2) then
    p_rec.rei_information26 :=
    ghr_rei_shd.g_old_rec.rei_information26;
  End If;
  If (p_rec.rei_information27 = hr_api.g_varchar2) then
    p_rec.rei_information27 :=
    ghr_rei_shd.g_old_rec.rei_information27;
  End If;
  If (p_rec.rei_information30 = hr_api.g_varchar2) then
    p_rec.rei_information30 :=
    ghr_rei_shd.g_old_rec.rei_information30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ghr_rei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ghr_rei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ghr_rei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ghr_rei_shd.g_old_rec.program_update_date;
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
  p_rec        in out nocopy  ghr_rei_shd.g_rec_type,
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
    SAVEPOINT upd_ghr_rei;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ghr_rei_shd.lck
	(
	p_rec.pa_request_extra_info_id,
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
  ghr_rei_bus.update_validate(p_rec);
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
    ROLLBACK TO upd_ghr_rei;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_request_extra_info_id     in number,
  p_pa_request_id                in number           default hr_api.g_number,
  p_information_type             in varchar2         default hr_api.g_varchar2,
  p_rei_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_rei_attribute1               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute2               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute3               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute4               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute5               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute6               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute7               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute8               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute9               in varchar2         default hr_api.g_varchar2,
  p_rei_attribute10              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute11              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute12              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute13              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute14              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute15              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute16              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute17              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute18              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute19              in varchar2         default hr_api.g_varchar2,
  p_rei_attribute20              in varchar2         default hr_api.g_varchar2,
  p_rei_information_category     in varchar2         default hr_api.g_varchar2,
  p_rei_information1             in varchar2         default hr_api.g_varchar2,
  p_rei_information2             in varchar2         default hr_api.g_varchar2,
  p_rei_information3             in varchar2         default hr_api.g_varchar2,
  p_rei_information4             in varchar2         default hr_api.g_varchar2,
  p_rei_information5             in varchar2         default hr_api.g_varchar2,
  p_rei_information6             in varchar2         default hr_api.g_varchar2,
  p_rei_information7             in varchar2         default hr_api.g_varchar2,
  p_rei_information8             in varchar2         default hr_api.g_varchar2,
  p_rei_information9             in varchar2         default hr_api.g_varchar2,
  p_rei_information10            in varchar2         default hr_api.g_varchar2,
  p_rei_information11            in varchar2         default hr_api.g_varchar2,
  p_rei_information12            in varchar2         default hr_api.g_varchar2,
  p_rei_information13            in varchar2         default hr_api.g_varchar2,
  p_rei_information14            in varchar2         default hr_api.g_varchar2,
  p_rei_information15            in varchar2         default hr_api.g_varchar2,
  p_rei_information16            in varchar2         default hr_api.g_varchar2,
  p_rei_information17            in varchar2         default hr_api.g_varchar2,
  p_rei_information18            in varchar2         default hr_api.g_varchar2,
  p_rei_information19            in varchar2         default hr_api.g_varchar2,
  p_rei_information20            in varchar2         default hr_api.g_varchar2,
  p_rei_information21            in varchar2         default hr_api.g_varchar2,
  p_rei_information22            in varchar2         default hr_api.g_varchar2,
  p_rei_information28            in varchar2         default hr_api.g_varchar2,
  p_rei_information29            in varchar2         default hr_api.g_varchar2,
  p_rei_information23            in varchar2         default hr_api.g_varchar2,
  p_rei_information24            in varchar2         default hr_api.g_varchar2,
  p_rei_information25            in varchar2         default hr_api.g_varchar2,
  p_rei_information26            in varchar2         default hr_api.g_varchar2,
  p_rei_information27            in varchar2         default hr_api.g_varchar2,
  p_rei_information30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy  number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  ghr_rei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_rei_shd.convert_args
  (
  p_pa_request_extra_info_id,
  p_pa_request_id,
  p_information_type,
  p_rei_attribute_category,
  p_rei_attribute1,
  p_rei_attribute2,
  p_rei_attribute3,
  p_rei_attribute4,
  p_rei_attribute5,
  p_rei_attribute6,
  p_rei_attribute7,
  p_rei_attribute8,
  p_rei_attribute9,
  p_rei_attribute10,
  p_rei_attribute11,
  p_rei_attribute12,
  p_rei_attribute13,
  p_rei_attribute14,
  p_rei_attribute15,
  p_rei_attribute16,
  p_rei_attribute17,
  p_rei_attribute18,
  p_rei_attribute19,
  p_rei_attribute20,
  p_rei_information_category,
  p_rei_information1,
  p_rei_information2,
  p_rei_information3,
  p_rei_information4,
  p_rei_information5,
  p_rei_information6,
  p_rei_information7,
  p_rei_information8,
  p_rei_information9,
  p_rei_information10,
  p_rei_information11,
  p_rei_information12,
  p_rei_information13,
  p_rei_information14,
  p_rei_information15,
  p_rei_information16,
  p_rei_information17,
  p_rei_information18,
  p_rei_information19,
  p_rei_information20,
  p_rei_information21,
  p_rei_information22,
  p_rei_information28,
  p_rei_information29,
  p_rei_information23,
  p_rei_information24,
  p_rei_information25,
  p_rei_information26,
  p_rei_information27,
  p_rei_information30,
  p_object_version_number,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date
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
end ghr_rei_upd;

/
