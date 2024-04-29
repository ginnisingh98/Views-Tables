--------------------------------------------------------
--  DDL for Package Body IRC_IRF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRF_UPD" as
/* $Header: irirfrhi.pkb 120.1 2008/04/16 07:34:32 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irf_upd.';  -- Global package name
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
  (p_rec                   in out nocopy irc_irf_shd.g_rec_type
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
     irc_irf_shd.get_object_version_number
        (p_referral_info_id =>  p_rec.referral_info_id
      );
    --
    --
    --
    -- Update the irc_referral_info Row
    --
    update  irc_referral_info
    set
     referral_info_id               = p_rec.referral_info_id
    ,start_date                     = p_rec.start_date
    ,end_date            	        = p_rec.end_date
    ,source_type            		= p_rec.source_type
    ,source_name            		= p_rec.source_name
    ,source_criteria1               = p_rec.source_criteria1
    ,source_value1            	    = p_rec.source_value1
    ,source_criteria2               = p_rec.source_criteria2
    ,source_value2            	    = p_rec.source_value2
    ,source_criteria3               = p_rec.source_criteria3
    ,source_value3                  = p_rec.source_value3
    ,source_criteria4               = p_rec.source_criteria4
    ,source_value4                  = p_rec.source_value4
    ,source_criteria5               = p_rec.source_criteria5
    ,source_value5                  = p_rec.source_value5
    ,source_person_id               = p_rec.source_person_id
    ,candidate_comment              = p_rec.candidate_comment
    ,employee_comment               = p_rec.employee_comment
    ,irf_attribute_category         = p_rec.irf_attribute_category
    ,irf_attribute1                 = p_rec.irf_attribute1
    ,irf_attribute2                 = p_rec.irf_attribute2
    ,irf_attribute3                 = p_rec.irf_attribute3
    ,irf_attribute4                 = p_rec.irf_attribute4
    ,irf_attribute5                 = p_rec.irf_attribute5
    ,irf_attribute6                 = p_rec.irf_attribute6
    ,irf_attribute7                 = p_rec.irf_attribute7
    ,irf_attribute8                 = p_rec.irf_attribute8
    ,irf_attribute9                 = p_rec.irf_attribute9
    ,irf_attribute10                = p_rec.irf_attribute10
    ,irf_information_category       = p_rec.irf_information_category
    ,irf_information1               = p_rec.irf_information1
    ,irf_information2               = p_rec.irf_information2
    ,irf_information3               = p_rec.irf_information3
    ,irf_information4               = p_rec.irf_information4
    ,irf_information5               = p_rec.irf_information5
    ,irf_information6               = p_rec.irf_information6
    ,irf_information7               = p_rec.irf_information7
    ,irf_information8               = p_rec.irf_information8
    ,irf_information9               = p_rec.irf_information9
    ,irf_information10              = p_rec.irf_information10
    ,object_created_by              = p_rec.object_created_by
    ,object_version_number          = p_rec.object_version_number
    where   referral_info_id  =   p_rec.referral_info_id
    and     start_date = p_validation_start_date
    and     ((p_validation_end_date is null and end_date is null) or
              (end_date  = p_validation_end_date));
    --
    --
    --
    -- Set the effective start and end dates
    --
    p_rec.start_date := p_validation_start_date;
    p_rec.end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_irf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_irf_shd.constraint_error
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
  (p_rec                      in out nocopy irc_irf_shd.g_rec_type
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
  irc_irf_upd.dt_update_dml
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
  (p_rec                     in out  nocopy   irc_irf_shd.g_rec_type
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
    irc_irf_shd.upd_end_date
      (p_effective_date         => p_effective_date
      ,p_referral_info_id =>  p_rec.referral_info_id
      ,p_new_end_date           => p_validation_start_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      irc_irf_del.delete_dml
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
    irc_irf_ins.insert_dml
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
  (p_rec                   in out nocopy irc_irf_shd.g_rec_type
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
  (p_rec                   in irc_irf_shd.g_rec_type
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
    irc_irf_rku.after_update
      (p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      ,p_referral_info_id             => p_rec.referral_info_id
	  ,p_start_date                   => p_rec.start_date
      ,p_end_date            	      => p_rec.end_date
	  ,p_source_type            	  => p_rec.source_type
      ,p_source_name            	  => p_rec.source_name
      ,p_source_criteria1             => p_rec.source_criteria1
      ,p_source_value1            	  => p_rec.source_value1
      ,p_source_criteria2             => p_rec.source_criteria2
      ,p_source_value2            	  => p_rec.source_value2
      ,p_source_criteria3             => p_rec.source_criteria3
      ,p_source_value3                => p_rec.source_value3
      ,p_source_criteria4             => p_rec.source_criteria4
      ,p_source_value4                => p_rec.source_value4
      ,p_source_criteria5             => p_rec.source_criteria5
      ,p_source_value5                => p_rec.source_value5
      ,p_source_person_id             => p_rec.source_person_id
      ,p_candidate_comment            => p_rec.candidate_comment
      ,p_employee_comment             => p_rec.employee_comment
      ,p_irf_attribute_category       => p_rec.irf_attribute_category
      ,p_irf_attribute1               => p_rec.irf_attribute1
      ,p_irf_attribute2               => p_rec.irf_attribute2
      ,p_irf_attribute3               => p_rec.irf_attribute3
      ,p_irf_attribute4               => p_rec.irf_attribute4
      ,p_irf_attribute5               => p_rec.irf_attribute5
      ,p_irf_attribute6               => p_rec.irf_attribute6
      ,p_irf_attribute7               => p_rec.irf_attribute7
      ,p_irf_attribute8               => p_rec.irf_attribute8
      ,p_irf_attribute9               => p_rec.irf_attribute9
      ,p_irf_attribute10              => p_rec.irf_attribute10
      ,p_irf_information_category     => p_rec.irf_information_category
      ,p_irf_information1             => p_rec.irf_information1
      ,p_irf_information2             => p_rec.irf_information2
      ,p_irf_information3             => p_rec.irf_information3
      ,p_irf_information4             => p_rec.irf_information4
      ,p_irf_information5             => p_rec.irf_information5
      ,p_irf_information6             => p_rec.irf_information6
      ,p_irf_information7             => p_rec.irf_information7
      ,p_irf_information8             => p_rec.irf_information8
      ,p_irf_information9             => p_rec.irf_information9
      ,p_irf_information10            => p_rec.irf_information10
      ,p_object_created_by            => p_rec.object_created_by
      ,p_created_by                   => p_rec.created_by
      ,p_object_version_number        => p_rec.object_version_number
      ,p_start_date_o			      => irc_irf_shd.g_old_rec.start_date
      ,p_end_date_o			          => irc_irf_shd.g_old_rec.end_date
      ,p_source_type_o			      => irc_irf_shd.g_old_rec.source_type
      ,p_source_name_o			      => irc_irf_shd.g_old_rec.source_name
      ,p_source_criteria1_o	  		  => irc_irf_shd.g_old_rec.source_criteria1
      ,p_source_value1_o			  => irc_irf_shd.g_old_rec.source_value1
      ,p_source_criteria2_o			  => irc_irf_shd.g_old_rec.source_criteria2
      ,p_source_value2_o			  => irc_irf_shd.g_old_rec.source_value2
      ,p_source_criteria3_o			  => irc_irf_shd.g_old_rec.source_criteria3
      ,p_source_value3_o			  => irc_irf_shd.g_old_rec.source_value3
      ,p_source_criteria4_o			  => irc_irf_shd.g_old_rec.source_criteria4
      ,p_source_value4_o			  => irc_irf_shd.g_old_rec.source_value4
      ,p_source_criteria5_o			  => irc_irf_shd.g_old_rec.source_criteria5
      ,p_source_value5_o			  => irc_irf_shd.g_old_rec.source_value5
      ,p_source_person_id_o			  => irc_irf_shd.g_old_rec.source_person_id
      ,p_candidate_comment_o		  => irc_irf_shd.g_old_rec.candidate_comment
      ,p_employee_comment_o			  => irc_irf_shd.g_old_rec.employee_comment
      ,p_irf_attribute_category_o     => irc_irf_shd.g_old_rec.irf_attribute_category
      ,p_irf_attribute1_o			  => irc_irf_shd.g_old_rec.irf_attribute1
      ,p_irf_attribute2_o		 	  => irc_irf_shd.g_old_rec.irf_attribute2
      ,p_irf_attribute3_o			  => irc_irf_shd.g_old_rec.irf_attribute3
      ,p_irf_attribute4_o			  => irc_irf_shd.g_old_rec.irf_attribute4
      ,p_irf_attribute5_o			  => irc_irf_shd.g_old_rec.irf_attribute5
      ,p_irf_attribute6_o		 	  => irc_irf_shd.g_old_rec.irf_attribute6
      ,p_irf_attribute7_o			  => irc_irf_shd.g_old_rec.irf_attribute7
      ,p_irf_attribute8_o			  => irc_irf_shd.g_old_rec.irf_attribute8
      ,p_irf_attribute9_o			  => irc_irf_shd.g_old_rec.irf_attribute9
      ,p_irf_attribute10_o			  => irc_irf_shd.g_old_rec.irf_attribute10
      ,p_irf_information_category_o	  => irc_irf_shd.g_old_rec.irf_information_category
      ,p_irf_information1_o			  => irc_irf_shd.g_old_rec.irf_information1
      ,p_irf_information2_o			  => irc_irf_shd.g_old_rec.irf_information2
      ,p_irf_information3_o			  => irc_irf_shd.g_old_rec.irf_information3
      ,p_irf_information4_o			  => irc_irf_shd.g_old_rec.irf_information4
      ,p_irf_information5_o			  => irc_irf_shd.g_old_rec.irf_information5
      ,p_irf_information6_o			  => irc_irf_shd.g_old_rec.irf_information6
      ,p_irf_information7_o			  => irc_irf_shd.g_old_rec.irf_information7
      ,p_irf_information8_o			  => irc_irf_shd.g_old_rec.irf_information8
      ,p_irf_information9_o			  => irc_irf_shd.g_old_rec.irf_information9
      ,p_irf_information10_o		  => irc_irf_shd.g_old_rec.irf_information10
      ,p_object_created_by_o		  => irc_irf_shd.g_old_rec.object_created_by
      ,p_created_by_o			      => irc_irf_shd.g_old_rec.created_by
      ,p_object_version_number_o	  => irc_irf_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_REFERRAL_INFO'
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
  (p_rec in out nocopy irc_irf_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.object_id = hr_api.g_number) then
    p_rec.object_id :=
    irc_irf_shd.g_old_rec.object_id;
  End If;
  If (p_rec.object_type = hr_api.g_varchar2) then
    p_rec.object_type :=
    irc_irf_shd.g_old_rec.object_type;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    irc_irf_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    irc_irf_shd.g_old_rec.end_date;
  End If;
  If (p_rec.source_type = hr_api.g_varchar2) then
    p_rec.source_type :=
    irc_irf_shd.g_old_rec.source_type;
  End If;
  If (p_rec.source_name = hr_api.g_varchar2) then
    p_rec.source_name :=
    irc_irf_shd.g_old_rec.source_name;
  End If;
  If (p_rec.source_criteria1 = hr_api.g_varchar2) then
    p_rec.source_criteria1 :=
    irc_irf_shd.g_old_rec.source_criteria1;
  End If;
  If (p_rec.source_value1 = hr_api.g_varchar2) then
    p_rec.source_value1 :=
    irc_irf_shd.g_old_rec.source_value1;
  End If;
  If (p_rec.source_criteria2 = hr_api.g_varchar2) then
    p_rec.source_criteria2 :=
    irc_irf_shd.g_old_rec.source_criteria2;
  End If;
  If (p_rec.source_value2 = hr_api.g_varchar2) then
    p_rec.source_value2 :=
    irc_irf_shd.g_old_rec.source_value2;
  End If;
  If (p_rec.source_criteria3 = hr_api.g_varchar2) then
    p_rec.source_criteria3 :=
    irc_irf_shd.g_old_rec.source_criteria3;
  End If;
  If (p_rec.source_value3 = hr_api.g_varchar2) then
    p_rec.source_value3 :=
    irc_irf_shd.g_old_rec.source_value3;
  End If;
  If (p_rec.source_criteria4 = hr_api.g_varchar2) then
    p_rec.source_criteria4 :=
    irc_irf_shd.g_old_rec.source_criteria4;
  End If;
  If (p_rec.source_value4 = hr_api.g_varchar2) then
    p_rec.source_value4 :=
    irc_irf_shd.g_old_rec.source_value4;
  End If;
  If (p_rec.source_criteria5 = hr_api.g_varchar2) then
    p_rec.source_criteria5 :=
    irc_irf_shd.g_old_rec.source_criteria5;
  End If;
  If (p_rec.source_value5 = hr_api.g_varchar2) then
    p_rec.source_value5 :=
    irc_irf_shd.g_old_rec.source_value5;
  End If;
  If (p_rec.source_person_id = hr_api.g_number) then
    p_rec.source_person_id :=
    irc_irf_shd.g_old_rec.source_person_id;
  End If;
  If (p_rec.candidate_comment = hr_api.g_varchar2) then
    p_rec.candidate_comment :=
    irc_irf_shd.g_old_rec.candidate_comment;
  End If;
  If (p_rec.employee_comment = hr_api.g_varchar2) then
    p_rec.employee_comment :=
    irc_irf_shd.g_old_rec.employee_comment;
  End If;
  If (p_rec.irf_attribute_category = hr_api.g_varchar2) then
    p_rec.irf_attribute_category :=
    irc_irf_shd.g_old_rec.irf_attribute_category;
  End If;
  If (p_rec.irf_attribute1 = hr_api.g_varchar2) then
    p_rec.irf_attribute1 :=
    irc_irf_shd.g_old_rec.irf_attribute1;
  End If;
  If (p_rec.irf_attribute2 = hr_api.g_varchar2) then
    p_rec.irf_attribute2 :=
    irc_irf_shd.g_old_rec.irf_attribute2;
  End If;
  If (p_rec.irf_attribute3 = hr_api.g_varchar2) then
    p_rec.irf_attribute3 :=
    irc_irf_shd.g_old_rec.irf_attribute3;
  End If;
  If (p_rec.irf_attribute4 = hr_api.g_varchar2) then
    p_rec.irf_attribute4 :=
    irc_irf_shd.g_old_rec.irf_attribute4;
  End If;
  If (p_rec.irf_attribute5 = hr_api.g_varchar2) then
    p_rec.irf_attribute5 :=
    irc_irf_shd.g_old_rec.irf_attribute5;
  End If;
  If (p_rec.irf_attribute6 = hr_api.g_varchar2) then
    p_rec.irf_attribute6 :=
    irc_irf_shd.g_old_rec.irf_attribute6;
  End If;
  If (p_rec.irf_attribute7 = hr_api.g_varchar2) then
    p_rec.irf_attribute7 :=
    irc_irf_shd.g_old_rec.irf_attribute7;
  End If;
  If (p_rec.irf_attribute8 = hr_api.g_varchar2) then
    p_rec.irf_attribute8 :=
    irc_irf_shd.g_old_rec.irf_attribute8;
  End If;
  If (p_rec.irf_attribute9 = hr_api.g_varchar2) then
    p_rec.irf_attribute9 :=
    irc_irf_shd.g_old_rec.irf_attribute9;
  End If;
  If (p_rec.irf_attribute10 = hr_api.g_varchar2) then
    p_rec.irf_attribute10 :=
    irc_irf_shd.g_old_rec.irf_attribute10;
  End If;
  If (p_rec.irf_information_category = hr_api.g_varchar2) then
    p_rec.irf_information_category :=
    irc_irf_shd.g_old_rec.irf_information_category;
  End If;
  If (p_rec.irf_information1 = hr_api.g_varchar2) then
    p_rec.irf_information1 :=
    irc_irf_shd.g_old_rec.irf_information1;
  End If;
  If (p_rec.irf_information2 = hr_api.g_varchar2) then
    p_rec.irf_information2 :=
    irc_irf_shd.g_old_rec.irf_information2;
  End If;
  If (p_rec.irf_information3 = hr_api.g_varchar2) then
    p_rec.irf_information3 :=
    irc_irf_shd.g_old_rec.irf_information3;
  End If;
  If (p_rec.irf_information4 = hr_api.g_varchar2) then
    p_rec.irf_information4 :=
    irc_irf_shd.g_old_rec.irf_information4;
  End If;
  If (p_rec.irf_information5 = hr_api.g_varchar2) then
    p_rec.irf_information5 :=
    irc_irf_shd.g_old_rec.irf_information5;
  End If;
  If (p_rec.irf_information6 = hr_api.g_varchar2) then
    p_rec.irf_information6 :=
    irc_irf_shd.g_old_rec.irf_information6;
  End If;
  If (p_rec.irf_information7 = hr_api.g_varchar2) then
    p_rec.irf_information7 :=
    irc_irf_shd.g_old_rec.irf_information7;
  End If;
  If (p_rec.irf_information8 = hr_api.g_varchar2) then
    p_rec.irf_information8 :=
    irc_irf_shd.g_old_rec.irf_information8;
  End If;
  If (p_rec.irf_information9 = hr_api.g_varchar2) then
    p_rec.irf_information9 :=
    irc_irf_shd.g_old_rec.irf_information9;
  End If;
  If (p_rec.irf_information10 = hr_api.g_varchar2) then
    p_rec.irf_information10 :=
    irc_irf_shd.g_old_rec.irf_information10;
  End If;
  If (p_rec.object_created_by = hr_api.g_varchar2) then
    p_rec.object_created_by :=
    irc_irf_shd.g_old_rec.object_created_by;
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
  ,p_rec            in out nocopy irc_irf_shd.g_rec_type
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
  irc_irf_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_referral_info_id                 =>  p_rec.referral_info_id
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
  irc_irf_upd.convert_defs(p_rec);
  --
  irc_irf_bus.update_validate
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
    ,p_validation_end_date              => l_validation_end_date
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
  ,p_referral_info_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_source_type            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_name            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria1               in 	     varchar2 default hr_api.g_varchar2
  ,p_source_value1            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria2               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value2            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria3               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value3                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria4               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value4                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria5               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value5                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_person_id               in 		 number   default hr_api.g_number
  ,p_candidate_comment              in 		 varchar2 default hr_api.g_varchar2
  ,p_employee_comment               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute_category         in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute1                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute2                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute3                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute4                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute5                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute6                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute7                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute8                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute9                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute10                in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information_category       in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information1               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information2               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information3               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information4               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information5               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information6               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information7               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information8               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information9               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information10              in 		 varchar2 default hr_api.g_varchar2
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
--
  l_rec         irc_irf_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_irf_shd.convert_args
  (p_referral_info_id
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,p_start_date
  ,p_end_date
  ,p_source_type
  ,p_source_name
  ,p_source_criteria1
  ,p_source_value1
  ,p_source_criteria2
  ,p_source_value2
  ,p_source_criteria3
  ,p_source_value3
  ,p_source_criteria4
  ,p_source_value4
  ,p_source_criteria5
  ,p_source_value5
  ,p_source_person_id
  ,p_candidate_comment
  ,p_employee_comment
  ,p_irf_attribute_category
  ,p_irf_attribute1
  ,p_irf_attribute2
  ,p_irf_attribute3
  ,p_irf_attribute4
  ,p_irf_attribute5
  ,p_irf_attribute6
  ,p_irf_attribute7
  ,p_irf_attribute8
  ,p_irf_attribute9
  ,p_irf_attribute10
  ,p_irf_information_category
  ,p_irf_information1
  ,p_irf_information2
  ,p_irf_information3
  ,p_irf_information4
  ,p_irf_information5
  ,p_irf_information6
  ,p_irf_information7
  ,p_irf_information8
  ,p_irf_information9
  ,p_irf_information10
  ,hr_api.g_varchar2
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_irf_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number  := l_rec.object_version_number;
  p_start_date             := l_rec.start_date;
  p_end_date               := l_rec.end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_irf_upd;

/
