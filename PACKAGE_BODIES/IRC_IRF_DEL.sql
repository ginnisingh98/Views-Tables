--------------------------------------------------------
--  DDL for Package Body IRC_IRF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRF_DEL" as
/* $Header: irirfrhi.pkb 120.1 2008/04/16 07:34:32 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irf_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
  (p_rec                     in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    --
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from irc_referral_info
    where       referral_info_id  =   p_rec.referral_info_id
    and   start_date = p_validation_start_date;
    --
    --
  /*Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from irc_referral_info
    where        referral_info_id  =   p_rec.referral_info_id
    and   start_date >= p_validation_start_date;*/
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  irc_irf_del.dt_delete_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
  (p_rec                     in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.start_date
      := irc_irf_shd.g_old_rec.start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.end_date := p_validation_start_date;
    Else
      p_rec.end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    irc_irf_shd.upd_end_date
      (p_effective_date         => p_effective_date
      ,p_referral_info_id =>  p_rec.referral_info_id
      ,p_new_end_date           => p_rec.end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  Else
    p_rec.start_date := null;
    p_rec.end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
  (p_rec                   in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
  --
  irc_irf_del.dt_pre_delete
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
  (p_rec                   in irc_irf_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
    --
    irc_irf_rkd.after_delete
      (p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      ,p_referral_info_id             => p_rec.referral_info_id
      ,p_start_date                   => p_rec.start_date
      ,p_end_date                     => p_rec.end_date
      ,p_object_id_o			      => irc_irf_shd.g_old_rec.object_id
      ,p_object_type_o			      => irc_irf_shd.g_old_rec.object_type
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy irc_irf_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  irc_irf_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_referral_info_id =>  p_rec.referral_info_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  irc_irf_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  irc_irf_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  irc_irf_del.post_delete
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
  hr_utility.set_location(' Leaving:'||l_proc, 5);
End del;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< del >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_referral_info_id                     in number
  ,p_object_version_number            in out nocopy number
  ,p_start_date                          out nocopy date
  ,p_end_date                            out nocopy date
  ) is
--
  l_rec         irc_irf_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
 l_rec.referral_info_id := p_referral_info_id;
 l_rec.start_date := p_start_date;
 l_rec.end_date := p_end_date;
 l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the irc_irf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  irc_irf_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
  --
  -- Set the out arguments
  --
  p_object_version_number  := l_rec.object_version_number;
  p_start_date             := l_rec.start_date;
  p_end_date               := l_rec.end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end irc_irf_del;

/
