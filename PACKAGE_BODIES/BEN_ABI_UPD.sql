--------------------------------------------------------
--  DDL for Package Body BEN_ABI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABI_UPD" as
/* $Header: beabirhi.pkb 115.0 2003/09/23 10:13:59 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abi_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A abr/Sql record structre.
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
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ben_abi_shd.g_rec_type) is
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
  --
  -- Update the ben_abr_extra_info Row
  --
  update ben_abr_extra_info
  set
  abr_extra_info_id                 = p_rec.abr_extra_info_id,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  abi_attribute_category            = p_rec.abi_attribute_category,
  abi_attribute1                    = p_rec.abi_attribute1,
  abi_attribute2                    = p_rec.abi_attribute2,
  abi_attribute3                    = p_rec.abi_attribute3,
  abi_attribute4                    = p_rec.abi_attribute4,
  abi_attribute5                    = p_rec.abi_attribute5,
  abi_attribute6                    = p_rec.abi_attribute6,
  abi_attribute7                    = p_rec.abi_attribute7,
  abi_attribute8                    = p_rec.abi_attribute8,
  abi_attribute9                    = p_rec.abi_attribute9,
  abi_attribute10                   = p_rec.abi_attribute10,
  abi_attribute11                   = p_rec.abi_attribute11,
  abi_attribute12                   = p_rec.abi_attribute12,
  abi_attribute13                   = p_rec.abi_attribute13,
  abi_attribute14                   = p_rec.abi_attribute14,
  abi_attribute15                   = p_rec.abi_attribute15,
  abi_attribute16                   = p_rec.abi_attribute16,
  abi_attribute17                   = p_rec.abi_attribute17,
  abi_attribute18                   = p_rec.abi_attribute18,
  abi_attribute19                   = p_rec.abi_attribute19,
  abi_attribute20                   = p_rec.abi_attribute20,
  abi_information_category          = p_rec.abi_information_category,
  abi_information1                  = p_rec.abi_information1,
  abi_information2                  = p_rec.abi_information2,
  abi_information3                  = p_rec.abi_information3,
  abi_information4                  = p_rec.abi_information4,
  abi_information5                  = p_rec.abi_information5,
  abi_information6                  = p_rec.abi_information6,
  abi_information7                  = p_rec.abi_information7,
  abi_information8                  = p_rec.abi_information8,
  abi_information9                  = p_rec.abi_information9,
  abi_information10                 = p_rec.abi_information10,
  abi_information11                 = p_rec.abi_information11,
  abi_information12                 = p_rec.abi_information12,
  abi_information13                 = p_rec.abi_information13,
  abi_information14                 = p_rec.abi_information14,
  abi_information15                 = p_rec.abi_information15,
  abi_information16                 = p_rec.abi_information16,
  abi_information17                 = p_rec.abi_information17,
  abi_information18                 = p_rec.abi_information18,
  abi_information19                 = p_rec.abi_information19,
  abi_information20                 = p_rec.abi_information20,
  abi_information21                 = p_rec.abi_information21,
  abi_information22                 = p_rec.abi_information22,
  abi_information23                 = p_rec.abi_information23,
  abi_information24                 = p_rec.abi_information24,
  abi_information25                 = p_rec.abi_information25,
  abi_information26                 = p_rec.abi_information26,
  abi_information27                 = p_rec.abi_information27,
  abi_information28                 = p_rec.abi_information28,
  abi_information29                 = p_rec.abi_information29,
  abi_information30                 = p_rec.abi_information30,
  object_version_number             = p_rec.object_version_number
  where abr_extra_info_id = p_rec.abr_extra_info_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_abi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_abi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_abi_shd.constraint_error
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
--   A abr/Sql record structre.
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
--   maintenance should be reviewed before abracing in this procedure.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_abi_shd.g_rec_type) is
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
--   A abr/Sql record structre.
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
--   maintenance should be reviewed before abracing in this procedure.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ben_abi_rku.after_update	(
	p_abr_extra_info_id		=>	p_rec.abr_extra_info_id		,
	p_information_type		=>	p_rec.information_type		,
	p_acty_base_rt_id				=>	p_rec.acty_base_rt_id			,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_abi_attribute_category	=>	p_rec.abi_attribute_category	,
	p_abi_attribute1			=>	p_rec.abi_attribute1		,
	p_abi_attribute2			=>	p_rec.abi_attribute2		,
	p_abi_attribute3			=>	p_rec.abi_attribute3		,
	p_abi_attribute4			=>	p_rec.abi_attribute4		,
	p_abi_attribute5			=>	p_rec.abi_attribute5		,
	p_abi_attribute6			=>	p_rec.abi_attribute6		,
	p_abi_attribute7			=>	p_rec.abi_attribute7		,
	p_abi_attribute8			=>	p_rec.abi_attribute8		,
	p_abi_attribute9			=>	p_rec.abi_attribute9		,
	p_abi_attribute10			=>	p_rec.abi_attribute10		,
	p_abi_attribute11			=>	p_rec.abi_attribute11		,
	p_abi_attribute12			=>	p_rec.abi_attribute12		,
	p_abi_attribute13			=>	p_rec.abi_attribute13		,
	p_abi_attribute14			=>	p_rec.abi_attribute14		,
	p_abi_attribute15			=>	p_rec.abi_attribute15		,
	p_abi_attribute16			=>	p_rec.abi_attribute16		,
	p_abi_attribute17			=>	p_rec.abi_attribute17		,
	p_abi_attribute18			=>	p_rec.abi_attribute18		,
	p_abi_attribute19			=>	p_rec.abi_attribute19		,
	p_abi_attribute20			=>	p_rec.abi_attribute20		,
	p_abi_information_category	=>	p_rec.abi_information_category,
	p_abi_information1		=>	p_rec.abi_information1		,
	p_abi_information2		=>	p_rec.abi_information2		,
	p_abi_information3		=>	p_rec.abi_information3		,
	p_abi_information4		=>	p_rec.abi_information4		,
	p_abi_information5		=>	p_rec.abi_information5		,
	p_abi_information6		=>	p_rec.abi_information6		,
	p_abi_information7		=>	p_rec.abi_information7		,
	p_abi_information8		=>	p_rec.abi_information8		,
	p_abi_information9		=>	p_rec.abi_information9		,
	p_abi_information10		=>	p_rec.abi_information10		,
	p_abi_information11		=>	p_rec.abi_information11		,
	p_abi_information12		=>	p_rec.abi_information12		,
	p_abi_information13		=>	p_rec.abi_information13		,
	p_abi_information14		=>	p_rec.abi_information14		,
	p_abi_information15		=>	p_rec.abi_information15		,
	p_abi_information16		=>	p_rec.abi_information16		,
	p_abi_information17		=>	p_rec.abi_information17		,
	p_abi_information18		=>	p_rec.abi_information18		,
	p_abi_information19		=>	p_rec.abi_information19		,
	p_abi_information20		=>	p_rec.abi_information20		,
	p_abi_information21		=>	p_rec.abi_information21		,
	p_abi_information22		=>	p_rec.abi_information22		,
	p_abi_information23		=>	p_rec.abi_information23		,
	p_abi_information24		=>	p_rec.abi_information24		,
	p_abi_information25		=>	p_rec.abi_information25		,
	p_abi_information26		=>	p_rec.abi_information26		,
	p_abi_information27		=>	p_rec.abi_information27		,
	p_abi_information28		=>	p_rec.abi_information28		,
	p_abi_information29		=>	p_rec.abi_information29		,
	p_abi_information30		=>	p_rec.abi_information30		,
	p_information_type_o		=>	ben_abi_shd.g_old_rec.information_type		,
	p_acty_base_rt_id_o				=>	ben_abi_shd.g_old_rec.acty_base_rt_id				,
	p_request_id_o			=>	ben_abi_shd.g_old_rec.request_id			,
	p_program_application_id_o	=>	ben_abi_shd.g_old_rec.program_application_id	,
	p_program_id_o			=>	ben_abi_shd.g_old_rec.program_id			,
	p_program_update_date_o		=>	ben_abi_shd.g_old_rec.program_update_date		,
	p_abi_attribute_category_o	=>	ben_abi_shd.g_old_rec.abi_attribute_category	,
	p_abi_attribute1_o		=>	ben_abi_shd.g_old_rec.abi_attribute1			,
	p_abi_attribute2_o		=>	ben_abi_shd.g_old_rec.abi_attribute2			,
	p_abi_attribute3_o		=>	ben_abi_shd.g_old_rec.abi_attribute3			,
	p_abi_attribute4_o		=>	ben_abi_shd.g_old_rec.abi_attribute4			,
	p_abi_attribute5_o		=>	ben_abi_shd.g_old_rec.abi_attribute5			,
	p_abi_attribute6_o		=>	ben_abi_shd.g_old_rec.abi_attribute6			,
	p_abi_attribute7_o		=>	ben_abi_shd.g_old_rec.abi_attribute7			,
	p_abi_attribute8_o		=>	ben_abi_shd.g_old_rec.abi_attribute8			,
	p_abi_attribute9_o		=>	ben_abi_shd.g_old_rec.abi_attribute9			,
	p_abi_attribute10_o		=>	ben_abi_shd.g_old_rec.abi_attribute10		,
	p_abi_attribute11_o		=>	ben_abi_shd.g_old_rec.abi_attribute11		,
	p_abi_attribute12_o		=>	ben_abi_shd.g_old_rec.abi_attribute12		,
	p_abi_attribute13_o		=>	ben_abi_shd.g_old_rec.abi_attribute13		,
	p_abi_attribute14_o		=>	ben_abi_shd.g_old_rec.abi_attribute14		,
	p_abi_attribute15_o		=>	ben_abi_shd.g_old_rec.abi_attribute15		,
	p_abi_attribute16_o		=>	ben_abi_shd.g_old_rec.abi_attribute16		,
	p_abi_attribute17_o		=>	ben_abi_shd.g_old_rec.abi_attribute17		,
	p_abi_attribute18_o		=>	ben_abi_shd.g_old_rec.abi_attribute18		,
	p_abi_attribute19_o		=>	ben_abi_shd.g_old_rec.abi_attribute19		,
	p_abi_attribute20_o		=>	ben_abi_shd.g_old_rec.abi_attribute20		,
	p_abi_information_category_o	=>	ben_abi_shd.g_old_rec.abi_information_category	,
	p_abi_information1_o		=>	ben_abi_shd.g_old_rec.abi_information1		,
	p_abi_information2_o		=>	ben_abi_shd.g_old_rec.abi_information2		,
	p_abi_information3_o		=>	ben_abi_shd.g_old_rec.abi_information3		,
	p_abi_information4_o		=>	ben_abi_shd.g_old_rec.abi_information4		,
	p_abi_information5_o		=>	ben_abi_shd.g_old_rec.abi_information5		,
	p_abi_information6_o		=>	ben_abi_shd.g_old_rec.abi_information6		,
	p_abi_information7_o		=>	ben_abi_shd.g_old_rec.abi_information7		,
	p_abi_information8_o		=>	ben_abi_shd.g_old_rec.abi_information8		,
	p_abi_information9_o		=>	ben_abi_shd.g_old_rec.abi_information9		,
	p_abi_information10_o		=>	ben_abi_shd.g_old_rec.abi_information10		,
	p_abi_information11_o		=>	ben_abi_shd.g_old_rec.abi_information11		,
	p_abi_information12_o		=>	ben_abi_shd.g_old_rec.abi_information12		,
	p_abi_information13_o		=>	ben_abi_shd.g_old_rec.abi_information13		,
	p_abi_information14_o		=>	ben_abi_shd.g_old_rec.abi_information14		,
	p_abi_information15_o		=>	ben_abi_shd.g_old_rec.abi_information15		,
	p_abi_information16_o		=>	ben_abi_shd.g_old_rec.abi_information16		,
	p_abi_information17_o		=>	ben_abi_shd.g_old_rec.abi_information17		,
	p_abi_information18_o		=>	ben_abi_shd.g_old_rec.abi_information18		,
	p_abi_information19_o		=>	ben_abi_shd.g_old_rec.abi_information19		,
	p_abi_information20_o		=>	ben_abi_shd.g_old_rec.abi_information20		,
	p_abi_information21_o		=>	ben_abi_shd.g_old_rec.abi_information21		,
	p_abi_information22_o		=>	ben_abi_shd.g_old_rec.abi_information22		,
	p_abi_information23_o		=>	ben_abi_shd.g_old_rec.abi_information23		,
	p_abi_information24_o		=>	ben_abi_shd.g_old_rec.abi_information24		,
	p_abi_information25_o		=>	ben_abi_shd.g_old_rec.abi_information25		,
	p_abi_information26_o		=>	ben_abi_shd.g_old_rec.abi_information26		,
	p_abi_information27_o		=>	ben_abi_shd.g_old_rec.abi_information27		,
	p_abi_information28_o		=>	ben_abi_shd.g_old_rec.abi_information28		,
	p_abi_information29_o		=>	ben_abi_shd.g_old_rec.abi_information29		,
	p_abi_information30_o		=>	ben_abi_shd.g_old_rec.abi_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'ben_abr_EXTRA_INFO'
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
--   A abr/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a abr/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec abrsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    ben_abi_shd.g_old_rec.information_type;
  End If;
  If (p_rec.acty_base_rt_id = hr_api.g_number) then
    p_rec.acty_base_rt_id :=
    ben_abi_shd.g_old_rec.acty_base_rt_id;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_abi_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_abi_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_abi_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_abi_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.abi_attribute_category = hr_api.g_varchar2) then
    p_rec.abi_attribute_category :=
    ben_abi_shd.g_old_rec.abi_attribute_category;
  End If;
  If (p_rec.abi_attribute1 = hr_api.g_varchar2) then
    p_rec.abi_attribute1 :=
    ben_abi_shd.g_old_rec.abi_attribute1;
  End If;
  If (p_rec.abi_attribute2 = hr_api.g_varchar2) then
    p_rec.abi_attribute2 :=
    ben_abi_shd.g_old_rec.abi_attribute2;
  End If;
  If (p_rec.abi_attribute3 = hr_api.g_varchar2) then
    p_rec.abi_attribute3 :=
    ben_abi_shd.g_old_rec.abi_attribute3;
  End If;
  If (p_rec.abi_attribute4 = hr_api.g_varchar2) then
    p_rec.abi_attribute4 :=
    ben_abi_shd.g_old_rec.abi_attribute4;
  End If;
  If (p_rec.abi_attribute5 = hr_api.g_varchar2) then
    p_rec.abi_attribute5 :=
    ben_abi_shd.g_old_rec.abi_attribute5;
  End If;
  If (p_rec.abi_attribute6 = hr_api.g_varchar2) then
    p_rec.abi_attribute6 :=
    ben_abi_shd.g_old_rec.abi_attribute6;
  End If;
  If (p_rec.abi_attribute7 = hr_api.g_varchar2) then
    p_rec.abi_attribute7 :=
    ben_abi_shd.g_old_rec.abi_attribute7;
  End If;
  If (p_rec.abi_attribute8 = hr_api.g_varchar2) then
    p_rec.abi_attribute8 :=
    ben_abi_shd.g_old_rec.abi_attribute8;
  End If;
  If (p_rec.abi_attribute9 = hr_api.g_varchar2) then
    p_rec.abi_attribute9 :=
    ben_abi_shd.g_old_rec.abi_attribute9;
  End If;
  If (p_rec.abi_attribute10 = hr_api.g_varchar2) then
    p_rec.abi_attribute10 :=
    ben_abi_shd.g_old_rec.abi_attribute10;
  End If;
  If (p_rec.abi_attribute11 = hr_api.g_varchar2) then
    p_rec.abi_attribute11 :=
    ben_abi_shd.g_old_rec.abi_attribute11;
  End If;
  If (p_rec.abi_attribute12 = hr_api.g_varchar2) then
    p_rec.abi_attribute12 :=
    ben_abi_shd.g_old_rec.abi_attribute12;
  End If;
  If (p_rec.abi_attribute13 = hr_api.g_varchar2) then
    p_rec.abi_attribute13 :=
    ben_abi_shd.g_old_rec.abi_attribute13;
  End If;
  If (p_rec.abi_attribute14 = hr_api.g_varchar2) then
    p_rec.abi_attribute14 :=
    ben_abi_shd.g_old_rec.abi_attribute14;
  End If;
  If (p_rec.abi_attribute15 = hr_api.g_varchar2) then
    p_rec.abi_attribute15 :=
    ben_abi_shd.g_old_rec.abi_attribute15;
  End If;
  If (p_rec.abi_attribute16 = hr_api.g_varchar2) then
    p_rec.abi_attribute16 :=
    ben_abi_shd.g_old_rec.abi_attribute16;
  End If;
  If (p_rec.abi_attribute17 = hr_api.g_varchar2) then
    p_rec.abi_attribute17 :=
    ben_abi_shd.g_old_rec.abi_attribute17;
  End If;
  If (p_rec.abi_attribute18 = hr_api.g_varchar2) then
    p_rec.abi_attribute18 :=
    ben_abi_shd.g_old_rec.abi_attribute18;
  End If;
  If (p_rec.abi_attribute19 = hr_api.g_varchar2) then
    p_rec.abi_attribute19 :=
    ben_abi_shd.g_old_rec.abi_attribute19;
  End If;
  If (p_rec.abi_attribute20 = hr_api.g_varchar2) then
    p_rec.abi_attribute20 :=
    ben_abi_shd.g_old_rec.abi_attribute20;
  End If;
  If (p_rec.abi_information_category = hr_api.g_varchar2) then
    p_rec.abi_information_category :=
    ben_abi_shd.g_old_rec.abi_information_category;
  End If;
  If (p_rec.abi_information1 = hr_api.g_varchar2) then
    p_rec.abi_information1 :=
    ben_abi_shd.g_old_rec.abi_information1;
  End If;
  If (p_rec.abi_information2 = hr_api.g_varchar2) then
    p_rec.abi_information2 :=
    ben_abi_shd.g_old_rec.abi_information2;
  End If;
  If (p_rec.abi_information3 = hr_api.g_varchar2) then
    p_rec.abi_information3 :=
    ben_abi_shd.g_old_rec.abi_information3;
  End If;
  If (p_rec.abi_information4 = hr_api.g_varchar2) then
    p_rec.abi_information4 :=
    ben_abi_shd.g_old_rec.abi_information4;
  End If;
  If (p_rec.abi_information5 = hr_api.g_varchar2) then
    p_rec.abi_information5 :=
    ben_abi_shd.g_old_rec.abi_information5;
  End If;
  If (p_rec.abi_information6 = hr_api.g_varchar2) then
    p_rec.abi_information6 :=
    ben_abi_shd.g_old_rec.abi_information6;
  End If;
  If (p_rec.abi_information7 = hr_api.g_varchar2) then
    p_rec.abi_information7 :=
    ben_abi_shd.g_old_rec.abi_information7;
  End If;
  If (p_rec.abi_information8 = hr_api.g_varchar2) then
    p_rec.abi_information8 :=
    ben_abi_shd.g_old_rec.abi_information8;
  End If;
  If (p_rec.abi_information9 = hr_api.g_varchar2) then
    p_rec.abi_information9 :=
    ben_abi_shd.g_old_rec.abi_information9;
  End If;
  If (p_rec.abi_information10 = hr_api.g_varchar2) then
    p_rec.abi_information10 :=
    ben_abi_shd.g_old_rec.abi_information10;
  End If;
  If (p_rec.abi_information11 = hr_api.g_varchar2) then
    p_rec.abi_information11 :=
    ben_abi_shd.g_old_rec.abi_information11;
  End If;
  If (p_rec.abi_information12 = hr_api.g_varchar2) then
    p_rec.abi_information12 :=
    ben_abi_shd.g_old_rec.abi_information12;
  End If;
  If (p_rec.abi_information13 = hr_api.g_varchar2) then
    p_rec.abi_information13 :=
    ben_abi_shd.g_old_rec.abi_information13;
  End If;
  If (p_rec.abi_information14 = hr_api.g_varchar2) then
    p_rec.abi_information14 :=
    ben_abi_shd.g_old_rec.abi_information14;
  End If;
  If (p_rec.abi_information15 = hr_api.g_varchar2) then
    p_rec.abi_information15 :=
    ben_abi_shd.g_old_rec.abi_information15;
  End If;
  If (p_rec.abi_information16 = hr_api.g_varchar2) then
    p_rec.abi_information16 :=
    ben_abi_shd.g_old_rec.abi_information16;
  End If;
  If (p_rec.abi_information17 = hr_api.g_varchar2) then
    p_rec.abi_information17 :=
    ben_abi_shd.g_old_rec.abi_information17;
  End If;
  If (p_rec.abi_information18 = hr_api.g_varchar2) then
    p_rec.abi_information18 :=
    ben_abi_shd.g_old_rec.abi_information18;
  End If;
  If (p_rec.abi_information19 = hr_api.g_varchar2) then
    p_rec.abi_information19 :=
    ben_abi_shd.g_old_rec.abi_information19;
  End If;
  If (p_rec.abi_information20 = hr_api.g_varchar2) then
    p_rec.abi_information20 :=
    ben_abi_shd.g_old_rec.abi_information20;
  End If;
  If (p_rec.abi_information21 = hr_api.g_varchar2) then
    p_rec.abi_information21 :=
    ben_abi_shd.g_old_rec.abi_information21;
  End If;
  If (p_rec.abi_information22 = hr_api.g_varchar2) then
    p_rec.abi_information22 :=
    ben_abi_shd.g_old_rec.abi_information22;
  End If;
  If (p_rec.abi_information23 = hr_api.g_varchar2) then
    p_rec.abi_information23 :=
    ben_abi_shd.g_old_rec.abi_information23;
  End If;
  If (p_rec.abi_information24 = hr_api.g_varchar2) then
    p_rec.abi_information24 :=
    ben_abi_shd.g_old_rec.abi_information24;
  End If;
  If (p_rec.abi_information25 = hr_api.g_varchar2) then
    p_rec.abi_information25 :=
    ben_abi_shd.g_old_rec.abi_information25;
  End If;
  If (p_rec.abi_information26 = hr_api.g_varchar2) then
    p_rec.abi_information26 :=
    ben_abi_shd.g_old_rec.abi_information26;
  End If;
  If (p_rec.abi_information27 = hr_api.g_varchar2) then
    p_rec.abi_information27 :=
    ben_abi_shd.g_old_rec.abi_information27;
  End If;
  If (p_rec.abi_information28 = hr_api.g_varchar2) then
    p_rec.abi_information28 :=
    ben_abi_shd.g_old_rec.abi_information28;
  End If;
  If (p_rec.abi_information29 = hr_api.g_varchar2) then
    p_rec.abi_information29 :=
    ben_abi_shd.g_old_rec.abi_information29;
  End If;
  If (p_rec.abi_information30 = hr_api.g_varchar2) then
    p_rec.abi_information30 :=
    ben_abi_shd.g_old_rec.abi_information30;
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
  p_rec        in out nocopy ben_abi_shd.g_rec_type,
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
    SAVEPOINT upd_ben_abi;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ben_abi_shd.lck
	(
	p_rec.abr_extra_info_id,
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
  ben_abi_bus.update_validate(p_rec);
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
    ROLLBACK TO upd_ben_abi;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_abr_extra_info_id            in number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_abi_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_abi_attribute1               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute2               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute3               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute4               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute5               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute6               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute7               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute8               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute9               in varchar2         default hr_api.g_varchar2,
  p_abi_attribute10              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute11              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute12              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute13              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute14              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute15              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute16              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute17              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute18              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute19              in varchar2         default hr_api.g_varchar2,
  p_abi_attribute20              in varchar2         default hr_api.g_varchar2,
  p_abi_information_category     in varchar2         default hr_api.g_varchar2,
  p_abi_information1             in varchar2         default hr_api.g_varchar2,
  p_abi_information2             in varchar2         default hr_api.g_varchar2,
  p_abi_information3             in varchar2         default hr_api.g_varchar2,
  p_abi_information4             in varchar2         default hr_api.g_varchar2,
  p_abi_information5             in varchar2         default hr_api.g_varchar2,
  p_abi_information6             in varchar2         default hr_api.g_varchar2,
  p_abi_information7             in varchar2         default hr_api.g_varchar2,
  p_abi_information8             in varchar2         default hr_api.g_varchar2,
  p_abi_information9             in varchar2         default hr_api.g_varchar2,
  p_abi_information10            in varchar2         default hr_api.g_varchar2,
  p_abi_information11            in varchar2         default hr_api.g_varchar2,
  p_abi_information12            in varchar2         default hr_api.g_varchar2,
  p_abi_information13            in varchar2         default hr_api.g_varchar2,
  p_abi_information14            in varchar2         default hr_api.g_varchar2,
  p_abi_information15            in varchar2         default hr_api.g_varchar2,
  p_abi_information16            in varchar2         default hr_api.g_varchar2,
  p_abi_information17            in varchar2         default hr_api.g_varchar2,
  p_abi_information18            in varchar2         default hr_api.g_varchar2,
  p_abi_information19            in varchar2         default hr_api.g_varchar2,
  p_abi_information20            in varchar2         default hr_api.g_varchar2,
  p_abi_information21            in varchar2         default hr_api.g_varchar2,
  p_abi_information22            in varchar2         default hr_api.g_varchar2,
  p_abi_information23            in varchar2         default hr_api.g_varchar2,
  p_abi_information24            in varchar2         default hr_api.g_varchar2,
  p_abi_information25            in varchar2         default hr_api.g_varchar2,
  p_abi_information26            in varchar2         default hr_api.g_varchar2,
  p_abi_information27            in varchar2         default hr_api.g_varchar2,
  p_abi_information28            in varchar2         default hr_api.g_varchar2,
  p_abi_information29            in varchar2         default hr_api.g_varchar2,
  p_abi_information30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  ben_abi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_abi_shd.convert_args
  (
  p_abr_extra_info_id,
  hr_api.g_varchar2,						--p_information_type,
  hr_api.g_number,						--p_acty_base_rt_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_abi_attribute_category,
  p_abi_attribute1,
  p_abi_attribute2,
  p_abi_attribute3,
  p_abi_attribute4,
  p_abi_attribute5,
  p_abi_attribute6,
  p_abi_attribute7,
  p_abi_attribute8,
  p_abi_attribute9,
  p_abi_attribute10,
  p_abi_attribute11,
  p_abi_attribute12,
  p_abi_attribute13,
  p_abi_attribute14,
  p_abi_attribute15,
  p_abi_attribute16,
  p_abi_attribute17,
  p_abi_attribute18,
  p_abi_attribute19,
  p_abi_attribute20,
  p_abi_information_category,
  p_abi_information1,
  p_abi_information2,
  p_abi_information3,
  p_abi_information4,
  p_abi_information5,
  p_abi_information6,
  p_abi_information7,
  p_abi_information8,
  p_abi_information9,
  p_abi_information10,
  p_abi_information11,
  p_abi_information12,
  p_abi_information13,
  p_abi_information14,
  p_abi_information15,
  p_abi_information16,
  p_abi_information17,
  p_abi_information18,
  p_abi_information19,
  p_abi_information20,
  p_abi_information21,
  p_abi_information22,
  p_abi_information23,
  p_abi_information24,
  p_abi_information25,
  p_abi_information26,
  p_abi_information27,
  p_abi_information28,
  p_abi_information29,
  p_abi_information30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- abrsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_abi_upd;

/
