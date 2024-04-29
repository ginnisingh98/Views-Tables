--------------------------------------------------------
--  DDL for Package Body PAY_ELE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELE_DEL" as
/* $Header: pyelerhi.pkb 120.1 2005/05/30 05:19:19 rajeesha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ele_del.';  -- Global package name
g_counter  number;
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
  (p_rec                     in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = hr_api.g_delete_next_change) then
    pay_ele_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from pay_element_entries_f
    where       element_entry_id = p_rec.element_entry_id
    and	  effective_start_date = p_validation_start_date;
    --
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    pay_ele_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from pay_element_entries_f
    where        element_entry_id = p_rec.element_entry_id
    and	  effective_start_date >= p_validation_start_date;
    --
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec                     in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_ele_del.dt_delete_dml
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
  (p_rec                     in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> hr_api.g_zap) then
    --
    p_rec.effective_start_date
      := pay_ele_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = hr_api.g_delete) then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    pay_ele_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date
      ,p_base_key_value	        => p_rec.element_entry_id
      ,p_new_effective_end_date => p_rec.effective_end_date
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date	=> p_validation_end_date
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
  (p_rec                   in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
-- Cursor C_Sel1 select comments to be deleted
--
  Cursor C_Sel1 is
    select t1.comment_id
    from   pay_element_entries_f t1
    where  t1.comment_id is not null
    and    t1.element_entry_id = p_rec.element_entry_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   pay_element_entries_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.element_entry_id = t1.element_entry_id
            and   (t2.effective_start_date > p_validation_end_date
            or    t2.effective_end_date   < p_validation_start_date));
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete any possible comments
  --
  For Comm_Del In C_Sel1 Loop
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  --
  pay_ele_del.dt_pre_delete
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
--   This private procedure contains any processing which is required after the
--   delete dml.
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
  (p_rec                   in pay_ele_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   begin
    --
    pay_ele_rkd.after_delete
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_element_entry_id
      => p_rec.element_entry_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_effective_start_date_o
      => pay_ele_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_ele_shd.g_old_rec.effective_end_date
      ,p_cost_allocation_keyflex_id_o
      => pay_ele_shd.g_old_rec.cost_allocation_keyflex_id
      ,p_assignment_id_o
      => pay_ele_shd.g_old_rec.assignment_id
      ,p_updating_action_id_o
      => pay_ele_shd.g_old_rec.updating_action_id
      ,p_updating_action_type_o
      => pay_ele_shd.g_old_rec.updating_action_type
      ,p_element_link_id_o
      => pay_ele_shd.g_old_rec.element_link_id
      ,p_original_entry_id_o
      => pay_ele_shd.g_old_rec.original_entry_id
      ,p_creator_type_o
      => pay_ele_shd.g_old_rec.creator_type
      ,p_entry_type_o
      => pay_ele_shd.g_old_rec.entry_type
      ,p_comment_id_o
      => pay_ele_shd.g_old_rec.comment_id
      ,p_comments_o
      => pay_ele_shd.g_old_rec.comments
      ,p_creator_id_o
      => pay_ele_shd.g_old_rec.creator_id
      ,p_reason_o
      => pay_ele_shd.g_old_rec.reason
      ,p_target_entry_id_o
      => pay_ele_shd.g_old_rec.target_entry_id
      ,p_attribute_category_o
      => pay_ele_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_ele_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_ele_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_ele_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_ele_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_ele_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_ele_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_ele_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_ele_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_ele_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_ele_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_ele_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_ele_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_ele_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_ele_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_ele_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_ele_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_ele_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_ele_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_ele_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_ele_shd.g_old_rec.attribute20
-- --
  ,--Altered next 30 lines, 20-FEB-03 changed p_rec -> pay_ele_shd.g_old_rec
   --as looked like a cut-n-paste accident
  p_entry_information_category_o => pay_ele_shd.g_old_rec.entry_information_category,
  p_entry_information1_o => pay_ele_shd.g_old_rec.entry_information1,
  p_entry_information2_o => pay_ele_shd.g_old_rec.entry_information2,
  p_entry_information3_o => pay_ele_shd.g_old_rec.entry_information3,
  p_entry_information4_o => pay_ele_shd.g_old_rec.entry_information4,
  p_entry_information5_o => pay_ele_shd.g_old_rec.entry_information5,
  p_entry_information6_o => pay_ele_shd.g_old_rec.entry_information6,
  p_entry_information7_o => pay_ele_shd.g_old_rec.entry_information7,
  p_entry_information8_o => pay_ele_shd.g_old_rec.entry_information8,
  p_entry_information9_o => pay_ele_shd.g_old_rec.entry_information9,
  p_entry_information10_o => pay_ele_shd.g_old_rec.entry_information10,
  p_entry_information11_o => pay_ele_shd.g_old_rec.entry_information11,
  p_entry_information12_o => pay_ele_shd.g_old_rec.entry_information12,
  p_entry_information13_o => pay_ele_shd.g_old_rec.entry_information13,
  p_entry_information14_o => pay_ele_shd.g_old_rec.entry_information14,
  p_entry_information15_o => pay_ele_shd.g_old_rec.entry_information15,
  p_entry_information16_o => pay_ele_shd.g_old_rec.entry_information16,
  p_entry_information17_o => pay_ele_shd.g_old_rec.entry_information17,
  p_entry_information18_o => pay_ele_shd.g_old_rec.entry_information18,
  p_entry_information19_o => pay_ele_shd.g_old_rec.entry_information19,
  p_entry_information20_o => pay_ele_shd.g_old_rec.entry_information20,
  p_entry_information21_o => pay_ele_shd.g_old_rec.entry_information21,
  p_entry_information22_o => pay_ele_shd.g_old_rec.entry_information22,
  p_entry_information23_o => pay_ele_shd.g_old_rec.entry_information23,
  p_entry_information24_o => pay_ele_shd.g_old_rec.entry_information24,
  p_entry_information25_o => pay_ele_shd.g_old_rec.entry_information25,
  p_entry_information26_o => pay_ele_shd.g_old_rec.entry_information26,
  p_entry_information27_o => pay_ele_shd.g_old_rec.entry_information27,
  p_entry_information28_o => pay_ele_shd.g_old_rec.entry_information28,
  p_entry_information29_o => pay_ele_shd.g_old_rec.entry_information29,
  p_entry_information30_o => pay_ele_shd.g_old_rec.entry_information30
      ,p_subpriority_o
      => pay_ele_shd.g_old_rec.subpriority
      ,p_personal_payment_method_id_o
      => pay_ele_shd.g_old_rec.personal_payment_method_id
      ,p_date_earned_o
      => pay_ele_shd.g_old_rec.date_earned
      ,p_object_version_number_o
      => pay_ele_shd.g_old_rec.object_version_number
      ,p_source_id_o
      => pay_ele_shd.g_old_rec.source_id
      ,p_balance_adj_cost_flag_o
      => pay_ele_shd.g_old_rec.balance_adj_cost_flag
      ,p_element_type_id_o => pay_ele_shd.g_old_rec.element_type_id
      ,p_all_entry_values_null_o
      => pay_ele_shd.g_old_rec.all_entry_values_null
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- 11-NOV-03
  -- Hard calls to DYT_PKG removed, perfomed in pyentapi.pkb

  hr_utility.set_location('Leaving:'||l_proc, 900);
  --
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pay_ele_shd.g_rec_type
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
  pay_ele_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_element_entry_id                 => p_rec.element_entry_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_ele_bus.delete_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-delete operation
  --
  pay_ele_del.pre_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Delete the row.
  --
  pay_ele_del.delete_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  -- Call the supporting post-delete operation
  --
  pay_ele_del.post_delete
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
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
  ,p_element_entry_id                 in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date	                 out nocopy date
  ) is
--
  l_rec		pay_ele_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.element_entry_id		:= p_element_entry_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the pay_ele_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_ele_del.del
     (p_effective_date
     ,p_datetrack_mode
     ,l_rec
     );
  --
  -- Set the out arguments
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_ele_del;

/
