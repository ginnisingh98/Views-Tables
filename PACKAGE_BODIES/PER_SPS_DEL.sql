--------------------------------------------------------
--  DDL for Package Body PER_SPS_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPS_DEL" as
/* $Header: pespsrhi.pkb 120.5.12000000.1 2007/01/22 04:39:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sps_del.';  -- Global package name
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
  (p_rec                     in out nocopy per_sps_shd.g_rec_type
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
    per_sps_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_spinal_point_steps_f
    where       step_id = p_rec.step_id
    and   effective_start_date = p_validation_start_date;
    --
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    per_sps_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_spinal_point_steps_f
    where        step_id = p_rec.step_id
    and   effective_start_date >= p_validation_start_date;
    --
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy per_sps_shd.g_rec_type
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
  per_sps_del.dt_delete_dml
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
  (p_rec                     in out nocopy per_sps_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
  l_return      varchar2(30);
  l_grade_id    number;
  l_spinal_point_id number;
  l_message     varchar2(2000) := null;
 --
  cursor csr_get_grade_id is
        select spine.grade_id
              ,step.spinal_point_id
        from per_grade_spines_f spine
            ,per_spinal_point_steps_f step
        where step.step_id = p_rec.step_id
        and   p_effective_date between
              step.effective_start_date and step.effective_end_date
        and   step.grade_spine_id = spine.grade_spine_id
        and   p_effective_date between
              spine.effective_start_date and spine.effective_end_date;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Call pqh_gsp_sync_compensation_obj.delete_oipl_for_step
  --
  --
  open csr_get_grade_id;
  fetch csr_get_grade_id into l_grade_id,l_spinal_point_id;
  if csr_get_grade_id%notfound then
    close csr_get_grade_id;
    hr_utility.set_location(l_proc, 40);
  else
    close csr_get_grade_id;
    l_return := pqh_gsp_sync_compensation_obj.delete_oipl_for_step
      (p_grade_id                => l_grade_id
      ,p_spinal_point_id         => l_spinal_point_id
      ,p_step_id                 => p_rec.step_id
      ,p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      );
    --
    hr_utility.trace('pqh_gsp_sync_compensation_obj.delete_oipl_for_step : '
                  || l_return);
    if l_return <> 'SUCCESS' Then
       l_message := fnd_message.get;
       hr_utility.trace('error message : ' || l_message);
       fnd_message.set_name('PER','HR_289570_DEL_OPTION_IN_PLAN');
       if l_message is not null then
         fnd_message.set_token('ERR_CODE',l_message);
       else
         fnd_message.set_token('ERR_CODE','-1');
       end if;
       --
       fnd_message.raise_error;
    End if;
  end if;
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := per_sps_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    per_sps_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.step_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number            => p_rec.object_version_number
      );
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
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
  (p_rec                   in out nocopy per_sps_shd.g_rec_type
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
  per_sps_del.dt_pre_delete
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
  (p_rec                   in per_sps_shd.g_rec_type
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
    per_sps_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_step_id
      => p_rec.step_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_effective_start_date_o
      => per_sps_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => per_sps_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => per_sps_shd.g_old_rec.business_group_id
      ,p_spinal_point_id_o
      => per_sps_shd.g_old_rec.spinal_point_id
      ,p_grade_spine_id_o
      => per_sps_shd.g_old_rec.grade_spine_id
      ,p_sequence_o
      => per_sps_shd.g_old_rec.sequence
      ,p_request_id_o
      => per_sps_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_sps_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_sps_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_sps_shd.g_old_rec.program_update_date
      ,p_information1_o
      => per_sps_shd.g_old_rec.information1
      ,p_information2_o
      => per_sps_shd.g_old_rec.information2
      ,p_information3_o
      => per_sps_shd.g_old_rec.information3
      ,p_information4_o
      => per_sps_shd.g_old_rec.information4
      ,p_information5_o
      => per_sps_shd.g_old_rec.information5
      ,p_information6_o
      => per_sps_shd.g_old_rec.information6
      ,p_information7_o
      => per_sps_shd.g_old_rec.information7
      ,p_information8_o
      => per_sps_shd.g_old_rec.information8
      ,p_information9_o
      => per_sps_shd.g_old_rec.information9
      ,p_information10_o
      => per_sps_shd.g_old_rec.information10
      ,p_information11_o
      => per_sps_shd.g_old_rec.information11
      ,p_information12_o
      => per_sps_shd.g_old_rec.information12
      ,p_information13_o
      => per_sps_shd.g_old_rec.information13
      ,p_information14_o
      => per_sps_shd.g_old_rec.information14
      ,p_information15_o
      => per_sps_shd.g_old_rec.information15
      ,p_information16_o
      => per_sps_shd.g_old_rec.information16
      ,p_information17_o
      => per_sps_shd.g_old_rec.information17
      ,p_information18_o
      => per_sps_shd.g_old_rec.information18
      ,p_information19_o
      => per_sps_shd.g_old_rec.information19
      ,p_information20_o
      => per_sps_shd.g_old_rec.information20
      ,p_information21_o
      => per_sps_shd.g_old_rec.information21
      ,p_information22_o
      => per_sps_shd.g_old_rec.information22
      ,p_information23_o
      => per_sps_shd.g_old_rec.information23
      ,p_information24_o
      => per_sps_shd.g_old_rec.information24
      ,p_information25_o
      => per_sps_shd.g_old_rec.information25
      ,p_information26_o
      => per_sps_shd.g_old_rec.information26
      ,p_information27_o
      => per_sps_shd.g_old_rec.information27
      ,p_information28_o
      => per_sps_shd.g_old_rec.information28
      ,p_information29_o
      => per_sps_shd.g_old_rec.information29
      ,p_information30_o
      => per_sps_shd.g_old_rec.information30
      ,p_information_category_o
      => per_sps_shd.g_old_rec.information_category
      ,p_object_version_number_o
      => per_sps_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SPINAL_POINT_STEPS_F'
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
  ,p_rec            in out nocopy per_sps_shd.g_rec_type
  ,p_called_from_del_grd_scale       in   boolean --bug 4096238
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  per_sps_bus.chk_delete
    (p_step_id              => p_rec.step_id
    ,p_spinal_point_id      => p_rec.spinal_point_id
    ,p_grade_spine_id       => p_rec.grade_spine_id
    ,p_effective_date       => p_effective_date
    ,p_datetrack_mode       => p_datetrack_mode
    ,p_called_from_del_grd_scale  => p_called_from_del_grd_scale -- bug 4096238
    );
  -- We must lock the row which we need to delete.
  --
  per_sps_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_step_id                          => p_rec.step_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  per_sps_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    ,p_called_from_del_grd_scale        => p_called_from_del_grd_scale --bug 4096238
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_sps_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  per_sps_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  per_sps_del.post_delete
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
  hr_utility.set_location(' Leaving:' || l_proc, 20);
End del;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< del >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_step_id                          in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  ,p_called_from_del_grd_scale       in   boolean --bug 4096238
  ) is
--
  l_rec         per_sps_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:' || l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.step_id                   := p_step_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the per_sps_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_sps_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     ,p_called_from_del_grd_scale   --bug 4096238
     );
  --
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 10);
End del;
--
end per_sps_del;

/
