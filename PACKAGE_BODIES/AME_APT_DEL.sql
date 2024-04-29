--------------------------------------------------------
--  DDL for Package Body AME_APT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APT_DEL" as
/* $Header: amaptrhi.pkb 120.1 2006/04/21 08:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_apt_del.';  -- Global package name
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
  (p_rec                     in out nocopy      ame_apt_shd.g_rec_type
  ,p_effective_date          in                 date
  ,p_datetrack_mode          in                 varchar2
  ,p_validation_start_date   in                 date
  ,p_validation_end_date     in                 date
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
    delete from ame_approver_types
    where       approver_type_id  =   p_rec.approver_type_id
    and   start_date = p_validation_start_date;
    --
    --
  /*Else
    --
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ame_approver_types
    where        approver_type_id  =   p_rec.approver_type_id
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
  (p_rec                     in out nocopy      ame_apt_shd.g_rec_type
  ,p_effective_date          in                 date
  ,p_datetrack_mode          in                 varchar2
  ,p_validation_start_date   in                 date
  ,p_validation_end_date     in                 date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ame_apt_del.dt_delete_dml
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
  (p_rec                     in out nocopy       ame_apt_shd.g_rec_type
  ,p_effective_date          in                  date
  ,p_datetrack_mode          in                  varchar2
  ,p_validation_start_date   in                  date
  ,p_validation_end_date     in                  date
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
      := ame_apt_shd.g_old_rec.start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.end_date := p_validation_start_date;
    Else
      p_rec.end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ame_apt_shd.upd_effective_end_date
      (p_effective_date            => p_effective_date
      ,p_approver_type_id          => p_rec.approver_type_id
      ,p_new_effective_end_date    => p_rec.end_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      ,p_object_version_number     => p_rec.object_version_number
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
  (p_rec                   in out nocopy  ame_apt_shd.g_rec_type
  ,p_effective_date        in             date
  ,p_datetrack_mode        in             varchar2
  ,p_validation_start_date in             date
  ,p_validation_end_date   in             date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ame_apt_del.dt_pre_delete
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
  (p_rec                   in ame_apt_shd.g_rec_type
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
    ame_apt_rkd.after_delete
      (p_effective_date                    => p_effective_date
      ,p_datetrack_mode                    => p_datetrack_mode
      ,p_validation_start_date             => p_validation_start_date
      ,p_validation_end_date               => p_validation_end_date
      ,p_approver_type_id                  => p_rec.approver_type_id
      ,p_start_date                        => p_rec.start_date
      ,p_end_date                          => p_rec.end_date
      ,p_orig_system_o                     => ame_apt_shd.g_old_rec.orig_system
      ,p_query_variable_1_label_o          => ame_apt_shd.g_old_rec.query_variable_1_label
      ,p_query_variable_2_label_o          => ame_apt_shd.g_old_rec.query_variable_2_label
      ,p_query_variable_3_label_o          => ame_apt_shd.g_old_rec.query_variable_3_label
      ,p_query_variable_4_label_o          => ame_apt_shd.g_old_rec.query_variable_4_label
      ,p_query_variable_5_label_o          => ame_apt_shd.g_old_rec.query_variable_5_label
      ,p_variable_1_lov_query_o            => ame_apt_shd.g_old_rec.variable_1_lov_query
      ,p_variable_2_lov_query_o            => ame_apt_shd.g_old_rec.variable_2_lov_query
      ,p_variable_3_lov_query_o            => ame_apt_shd.g_old_rec.variable_3_lov_query
      ,p_variable_4_lov_query_o            => ame_apt_shd.g_old_rec.variable_4_lov_query
      ,p_variable_5_lov_query_o            => ame_apt_shd.g_old_rec.variable_5_lov_query
      ,p_query_procedure_o                 => ame_apt_shd.g_old_rec.query_procedure
      ,p_start_date_o                      => ame_apt_shd.g_old_rec.start_date
      ,p_end_date_o                        => ame_apt_shd.g_old_rec.end_date
      ,p_object_version_number_o           => ame_apt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ame_approver_types'
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
  (p_effective_date in                   date
  ,p_datetrack_mode in                   varchar2
  ,p_rec            in out nocopy        ame_apt_shd.g_rec_type
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
  ame_apt_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_approver_type_id                 => p_rec.approver_type_id
    ,p_orig_system                      => p_rec.orig_system
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  ame_apt_bus.delete_validate
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
  -- Call the supporting pre-delete operation
  --
  ame_apt_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  ame_apt_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  ame_apt_del.post_delete
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
  (p_effective_date                   in                date
  ,p_datetrack_mode                   in                varchar2
  ,p_approver_type_id                 in                number
  ,p_object_version_number            in out nocopy     number
  ,p_start_date                          out nocopy     date
  ,p_end_date                            out nocopy     date
  ) is
--
  l_rec         ame_apt_shd.g_rec_type;
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
 l_rec.approver_type_id       := p_approver_type_id;
 l_rec.start_date             := p_start_date;
 l_rec.end_date               := p_end_date;
 l_rec.object_version_number  := p_object_version_number;
  -- Having converted the arguments into the ame_apt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ame_apt_del.del
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
end ame_apt_del;

/
