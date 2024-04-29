--------------------------------------------------------
--  DDL for Package Body IRC_IID_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IID_UPD" as
/* $Header: iriidrhi.pkb 120.3.12010000.2 2008/11/06 13:49:47 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iid_upd.';  -- Global package name
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
  (p_rec                   in out nocopy irc_iid_shd.g_rec_type
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
     irc_iid_shd.get_object_version_number
        (p_interview_details_id =>  p_rec.interview_details_id
      );
    --
    --
    --
    -- Update the irc_interview_details Row
    --
    update  irc_interview_details
    set
     interview_details_id                 = p_rec.interview_details_id
    ,status                               = p_rec.status
    ,feedback                             = p_rec.feedback
    ,notes                                = p_rec.notes
    ,notes_to_candidate                   = p_rec.notes_to_candidate
    ,category                             = p_rec.category
    ,result                               = p_rec.result
    ,iid_information_category             = p_rec.iid_information_category
    ,iid_information1                     = p_rec.iid_information1
    ,iid_information2                     = p_rec.iid_information2
    ,iid_information3                     = p_rec.iid_information3
    ,iid_information4                     = p_rec.iid_information4
    ,iid_information5                     = p_rec.iid_information5
    ,iid_information6                     = p_rec.iid_information6
    ,iid_information7                     = p_rec.iid_information7
    ,iid_information8                     = p_rec.iid_information8
    ,iid_information9                     = p_rec.iid_information9
    ,iid_information10                    = p_rec.iid_information10
    ,iid_information11                    = p_rec.iid_information11
    ,iid_information12                    = p_rec.iid_information12
    ,iid_information13                    = p_rec.iid_information13
    ,iid_information14                    = p_rec.iid_information14
    ,iid_information15                    = p_rec.iid_information15
    ,iid_information16                    = p_rec.iid_information16
    ,iid_information17                    = p_rec.iid_information17
    ,iid_information18                    = p_rec.iid_information18
    ,iid_information19                    = p_rec.iid_information19
    ,iid_information20                    = p_rec.iid_information20
    ,start_date                           = p_rec.start_date
    ,end_date                             = p_rec.end_date
    ,event_id                             = p_rec.event_id
    ,object_version_number                = p_rec.object_version_number
    where   interview_details_id  =   p_rec.interview_details_id
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
    irc_iid_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_iid_shd.constraint_error
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
  (p_rec                      in out nocopy irc_iid_shd.g_rec_type
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
  irc_iid_upd.dt_update_dml
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
  (p_rec                     in out  nocopy   irc_iid_shd.g_rec_type
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
    irc_iid_shd.upd_end_date
      (p_effective_date         => p_effective_date
      ,p_interview_details_id =>  p_rec.interview_details_id
      ,p_new_end_date           => p_validation_start_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      irc_iid_del.delete_dml
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
    irc_iid_ins.insert_dml
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
  (p_rec                   in out nocopy irc_iid_shd.g_rec_type
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
  (p_rec                   in irc_iid_shd.g_rec_type
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
    irc_iid_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_interview_details_id
      => p_rec.interview_details_id
      ,p_status
      => p_rec.status
      ,p_feedback
      => p_rec.feedback
      ,p_notes
      => p_rec.notes
      ,p_notes_to_candidate
      => p_rec.notes_to_candidate
      ,p_category
      => p_rec.category
      ,p_result
      => p_rec.result
      ,p_start_date
      => p_rec.start_date
      ,p_iid_information_category
      => p_rec.iid_information_category
      ,p_iid_information1
      => p_rec.iid_information1
      ,p_iid_information2
      => p_rec.iid_information2
      ,p_iid_information3
      => p_rec.iid_information3
      ,p_iid_information4
      => p_rec.iid_information4
      ,p_iid_information5
      => p_rec.iid_information5
      ,p_iid_information6
      => p_rec.iid_information6
      ,p_iid_information7
      => p_rec.iid_information7
      ,p_iid_information8
      => p_rec.iid_information8
      ,p_iid_information9
      => p_rec.iid_information9
      ,p_iid_information10
      => p_rec.iid_information10
      ,p_iid_information11
      => p_rec.iid_information11
      ,p_iid_information12
      => p_rec.iid_information12
      ,p_iid_information13
      => p_rec.iid_information13
      ,p_iid_information14
      => p_rec.iid_information14
      ,p_iid_information15
      => p_rec.iid_information15
      ,p_iid_information16
      => p_rec.iid_information16
      ,p_iid_information17
      => p_rec.iid_information17
      ,p_iid_information18
      => p_rec.iid_information18
      ,p_iid_information19
      => p_rec.iid_information19
      ,p_iid_information20
      => p_rec.iid_information20
      ,p_end_date
      => p_rec.end_date
      ,p_event_id
      => p_rec.event_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_status_o
      => irc_iid_shd.g_old_rec.status
      ,p_feedback_o
      => irc_iid_shd.g_old_rec.feedback
      ,p_notes_o
      => irc_iid_shd.g_old_rec.notes
      ,p_notes_to_candidate_o
      => irc_iid_shd.g_old_rec.notes_to_candidate
      ,p_category_o
      => irc_iid_shd.g_old_rec.category
      ,p_result_o
      => irc_iid_shd.g_old_rec.result
      ,p_iid_information_category_o
      => irc_iid_shd.g_old_rec.iid_information_category
      ,p_iid_information1_o
      => irc_iid_shd.g_old_rec.iid_information1
      ,p_iid_information2_o
      => irc_iid_shd.g_old_rec.iid_information2
      ,p_iid_information3_o
      => irc_iid_shd.g_old_rec.iid_information3
      ,p_iid_information4_o
      => irc_iid_shd.g_old_rec.iid_information4
      ,p_iid_information5_o
      => irc_iid_shd.g_old_rec.iid_information5
      ,p_iid_information6_o
      => irc_iid_shd.g_old_rec.iid_information6
      ,p_iid_information7_o
      => irc_iid_shd.g_old_rec.iid_information7
      ,p_iid_information8_o
      => irc_iid_shd.g_old_rec.iid_information8
      ,p_iid_information9_o
      => irc_iid_shd.g_old_rec.iid_information9
      ,p_iid_information10_o
      => irc_iid_shd.g_old_rec.iid_information10
      ,p_iid_information11_o
      => irc_iid_shd.g_old_rec.iid_information11
      ,p_iid_information12_o
      => irc_iid_shd.g_old_rec.iid_information12
      ,p_iid_information13_o
      => irc_iid_shd.g_old_rec.iid_information13
      ,p_iid_information14_o
      => irc_iid_shd.g_old_rec.iid_information14
      ,p_iid_information15_o
      => irc_iid_shd.g_old_rec.iid_information15
      ,p_iid_information16_o
      => irc_iid_shd.g_old_rec.iid_information16
      ,p_iid_information17_o
      => irc_iid_shd.g_old_rec.iid_information17
      ,p_iid_information18_o
      => irc_iid_shd.g_old_rec.iid_information18
      ,p_iid_information19_o
      => irc_iid_shd.g_old_rec.iid_information19
      ,p_iid_information20_o
      => irc_iid_shd.g_old_rec.iid_information20
      ,p_start_date_o
      => irc_iid_shd.g_old_rec.start_date
      ,p_end_date_o
      => irc_iid_shd.g_old_rec.end_date
      ,p_event_id_o
      => irc_iid_shd.g_old_rec.event_id
      ,p_object_version_number_o
      => irc_iid_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_INTERVIEW_DETAILS'
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
  (p_rec in out nocopy irc_iid_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    irc_iid_shd.g_old_rec.status;
  End If;
  If (p_rec.feedback = hr_api.g_varchar2) then
    p_rec.feedback :=
    irc_iid_shd.g_old_rec.feedback;
  End If;
  If (p_rec.notes = hr_api.g_varchar2) then
    p_rec.notes :=
    irc_iid_shd.g_old_rec.notes;
  End If;
  If (p_rec.notes_to_candidate = hr_api.g_varchar2) then
    p_rec.notes_to_candidate :=
    irc_iid_shd.g_old_rec.notes_to_candidate;
  End If;
  If (p_rec.category = hr_api.g_varchar2) then
    p_rec.category :=
    irc_iid_shd.g_old_rec.category;
  End If;
  If (p_rec.result = hr_api.g_varchar2) then
    p_rec.result :=
    irc_iid_shd.g_old_rec.result;
  End If;
  If (p_rec.iid_information_category = hr_api.g_varchar2) then
    p_rec.iid_information_category :=
    irc_iid_shd.g_old_rec.iid_information_category;
  End If;
  If (p_rec.iid_information1 = hr_api.g_varchar2) then
    p_rec.iid_information1 :=
    irc_iid_shd.g_old_rec.iid_information1;
  End If;
  If (p_rec.iid_information2 = hr_api.g_varchar2) then
    p_rec.iid_information2 :=
    irc_iid_shd.g_old_rec.iid_information2;
  End If;
  If (p_rec.iid_information3 = hr_api.g_varchar2) then
    p_rec.iid_information3 :=
    irc_iid_shd.g_old_rec.iid_information3;
  End If;
  If (p_rec.iid_information4 = hr_api.g_varchar2) then
    p_rec.iid_information4 :=
    irc_iid_shd.g_old_rec.iid_information4;
  End If;
  If (p_rec.iid_information5 = hr_api.g_varchar2) then
    p_rec.iid_information5 :=
    irc_iid_shd.g_old_rec.iid_information5;
  End If;
  If (p_rec.iid_information6 = hr_api.g_varchar2) then
    p_rec.iid_information6 :=
    irc_iid_shd.g_old_rec.iid_information6;
  End If;
  If (p_rec.iid_information7 = hr_api.g_varchar2) then
    p_rec.iid_information7 :=
    irc_iid_shd.g_old_rec.iid_information7;
  End If;
  If (p_rec.iid_information8 = hr_api.g_varchar2) then
    p_rec.iid_information8 :=
    irc_iid_shd.g_old_rec.iid_information8;
  End If;
  If (p_rec.iid_information9 = hr_api.g_varchar2) then
    p_rec.iid_information9 :=
    irc_iid_shd.g_old_rec.iid_information9;
  End If;
  If (p_rec.iid_information10 = hr_api.g_varchar2) then
    p_rec.iid_information10 :=
    irc_iid_shd.g_old_rec.iid_information10;
  End If;
  If (p_rec.iid_information11 = hr_api.g_varchar2) then
    p_rec.iid_information11 :=
    irc_iid_shd.g_old_rec.iid_information11;
  End If;
  If (p_rec.iid_information12 = hr_api.g_varchar2) then
    p_rec.iid_information12 :=
    irc_iid_shd.g_old_rec.iid_information12;
  End If;
  If (p_rec.iid_information13 = hr_api.g_varchar2) then
    p_rec.iid_information13 :=
    irc_iid_shd.g_old_rec.iid_information13;
  End If;
  If (p_rec.iid_information14 = hr_api.g_varchar2) then
    p_rec.iid_information14 :=
    irc_iid_shd.g_old_rec.iid_information14;
  End If;
  If (p_rec.iid_information15 = hr_api.g_varchar2) then
    p_rec.iid_information15 :=
    irc_iid_shd.g_old_rec.iid_information15;
  End If;
  If (p_rec.iid_information16 = hr_api.g_varchar2) then
    p_rec.iid_information16 :=
    irc_iid_shd.g_old_rec.iid_information16;
  End If;
  If (p_rec.iid_information17 = hr_api.g_varchar2) then
    p_rec.iid_information17 :=
    irc_iid_shd.g_old_rec.iid_information17;
  End If;
  If (p_rec.iid_information18 = hr_api.g_varchar2) then
    p_rec.iid_information18 :=
    irc_iid_shd.g_old_rec.iid_information18;
  End If;
  If (p_rec.iid_information19 = hr_api.g_varchar2) then
    p_rec.iid_information19 :=
    irc_iid_shd.g_old_rec.iid_information19;
  End If;
  If (p_rec.iid_information20 = hr_api.g_varchar2) then
    p_rec.iid_information20 :=
    irc_iid_shd.g_old_rec.iid_information20;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    irc_iid_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    irc_iid_shd.g_old_rec.end_date;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id :=
    irc_iid_shd.g_old_rec.event_id;
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
  ,p_rec            in out nocopy irc_iid_shd.g_rec_type
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
  irc_iid_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_interview_details_id =>  p_rec.interview_details_id
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
  irc_iid_upd.convert_defs(p_rec);
  --
  irc_iid_bus.update_validate
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
  ,p_interview_details_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_feedback                     in     varchar2  default hr_api.g_varchar2
  ,p_notes                        in     varchar2  default hr_api.g_varchar2
  ,p_notes_to_candidate           in     varchar2  default hr_api.g_varchar2
  ,p_category                     in     varchar2  default hr_api.g_varchar2
  ,p_result                       in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19            in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20            in     varchar2  default hr_api.g_varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ) is
--
  l_rec         irc_iid_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_iid_shd.convert_args
  (p_interview_details_id
  ,p_status
  ,p_feedback
  ,p_notes
  ,p_notes_to_candidate
  ,p_category
  ,p_result
  ,p_iid_information_category
  ,p_iid_information1
  ,p_iid_information2
  ,p_iid_information3
  ,p_iid_information4
  ,p_iid_information5
  ,p_iid_information6
  ,p_iid_information7
  ,p_iid_information8
  ,p_iid_information9
  ,p_iid_information10
  ,p_iid_information11
  ,p_iid_information12
  ,p_iid_information13
  ,p_iid_information14
  ,p_iid_information15
  ,p_iid_information16
  ,p_iid_information17
  ,p_iid_information18
  ,p_iid_information19
  ,p_iid_information20
  ,p_start_date
  ,p_end_date
  ,p_event_id
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_iid_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_start_date             := l_rec.start_date;
  p_end_date               := l_rec.end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_iid_upd;

/
