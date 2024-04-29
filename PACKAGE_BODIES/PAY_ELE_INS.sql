--------------------------------------------------------
--  DDL for Package Body PAY_ELE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELE_INS" as
/* $Header: pyelerhi.pkb 120.1 2005/05/30 05:19:19 rajeesha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ele_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pay_element_entries_f t
    where  t.element_entry_id       = p_rec.element_entry_id
    and    t.effective_start_date =
             pay_ele_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_element_entries_f.created_by%TYPE;
  l_creation_date       pay_element_entries_f.creation_date%TYPE;
  l_last_update_date   	pay_element_entries_f.last_update_date%TYPE;
  l_last_updated_by     pay_element_entries_f.last_updated_by%TYPE;
  l_last_update_login   pay_element_entries_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_element_entries_f'
      ,p_base_key_column => 'element_entry_id'
      ,p_base_key_value  => p_rec.element_entry_id
      );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  pay_ele_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_element_entries_f
  --
  insert into pay_element_entries_f
      (element_entry_id
      ,effective_start_date
      ,effective_end_date
      ,cost_allocation_keyflex_id
      ,assignment_id
      ,updating_action_id
      ,updating_action_type
      ,element_link_id
      ,original_entry_id
      ,creator_type
      ,entry_type
      ,comment_id
      ,creator_id
      ,reason
      ,target_entry_id
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,subpriority
      ,personal_payment_method_id
      ,date_earned
      ,object_version_number
      ,source_id
      ,balance_adj_cost_flag
      ,element_type_id
      ,all_entry_values_null
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.element_entry_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.cost_allocation_keyflex_id
    ,p_rec.assignment_id
    ,p_rec.updating_action_id
    ,p_rec.updating_action_type
    ,p_rec.element_link_id
    ,p_rec.original_entry_id
    ,p_rec.creator_type
    ,p_rec.entry_type
    ,p_rec.comment_id
    ,p_rec.creator_id
    ,p_rec.reason
    ,p_rec.target_entry_id
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.subpriority
    ,p_rec.personal_payment_method_id
    ,p_rec.date_earned
    ,p_rec.object_version_number
    ,p_rec.source_id
    ,p_rec.balance_adj_cost_flag
    ,p_rec.element_type_id
    ,p_rec.all_entry_values_null
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ele_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ele_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_ele_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy pay_ele_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_element_entries_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.element_entry_id;
  Close C_Sel1;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_comm_api.ins
      (p_comment_id        => p_rec.comment_id
      ,p_source_table_name => 'PAY_ELEMENT_ENTRIES_F'
      ,p_comment_text      => p_rec.comments
      );
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in pay_ele_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_ele_rki.after_insert
      (p_effective_date
      => p_effective_date
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
      ,p_cost_allocation_keyflex_id
      => p_rec.cost_allocation_keyflex_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_updating_action_id
      => p_rec.updating_action_id
      ,p_updating_action_type
      => p_rec.updating_action_type
      ,p_element_link_id
      => p_rec.element_link_id
      ,p_original_entry_id
      => p_rec.original_entry_id
      ,p_creator_type
      => p_rec.creator_type
      ,p_entry_type
      => p_rec.entry_type
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_creator_id
      => p_rec.creator_id
      ,p_reason
      => p_rec.reason
      ,p_target_entry_id
      => p_rec.target_entry_id
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
-- --
  ,
  p_entry_information_category => p_rec.entry_information_category,
  p_entry_information1 => p_rec.entry_information1,
  p_entry_information2 => p_rec.entry_information2,
  p_entry_information3 => p_rec.entry_information3,
  p_entry_information4 => p_rec.entry_information4,
  p_entry_information5 => p_rec.entry_information5,
  p_entry_information6 => p_rec.entry_information6,
  p_entry_information7 => p_rec.entry_information7,
  p_entry_information8 => p_rec.entry_information8,
  p_entry_information9 => p_rec.entry_information9,
  p_entry_information10 => p_rec.entry_information10,
  p_entry_information11 => p_rec.entry_information11,
  p_entry_information12 => p_rec.entry_information12,
  p_entry_information13 => p_rec.entry_information13,
  p_entry_information14 => p_rec.entry_information14,
  p_entry_information15 => p_rec.entry_information15,
  p_entry_information16 => p_rec.entry_information16,
  p_entry_information17 => p_rec.entry_information17,
  p_entry_information18 => p_rec.entry_information18,
  p_entry_information19 => p_rec.entry_information19,
  p_entry_information20 => p_rec.entry_information20,
  p_entry_information21 => p_rec.entry_information21,
  p_entry_information22 => p_rec.entry_information22,
  p_entry_information23 => p_rec.entry_information23,
  p_entry_information24 => p_rec.entry_information24,
  p_entry_information25 => p_rec.entry_information25,
  p_entry_information26 => p_rec.entry_information26,
  p_entry_information27 => p_rec.entry_information27,
  p_entry_information28 => p_rec.entry_information28,
  p_entry_information29 => p_rec.entry_information29,
  p_entry_information30 => p_rec.entry_information30
      ,p_subpriority
      => p_rec.subpriority
      ,p_personal_payment_method_id
      => p_rec.personal_payment_method_id
      ,p_date_earned
      => p_rec.date_earned
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_source_id
      => p_rec.source_id
      ,p_balance_adj_cost_flag => p_rec.balance_adj_cost_flag
      ,p_element_type_id => p_rec.element_type_id
      ,p_all_entry_values_null => p_rec.all_entry_values_null
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- 11-NOV-03
  -- Hard calls to DYT_PKG removed, perfomed in pyentapi.pkb

  hr_utility.set_location('Leaving:'||l_proc, 900);
  --
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in pay_ele_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date	       => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'pay_element_entries_f'
    ,p_base_key_column         => 'element_entry_id'
    ,p_base_key_value          => p_rec.element_entry_id
    ,p_parent_table_name1      => 'per_all_assignments_f'
    ,p_parent_key_column1      => 'assignment_id'
    ,p_parent_key_value1       => p_rec.assignment_id
    ,p_parent_table_name2      => 'pay_element_links_f'
    ,p_parent_key_column2      => 'element_link_id'
    ,p_parent_key_value2       => p_rec.element_link_id
    ,p_enforce_foreign_locking => true
    ,p_validation_start_date   => l_validation_start_date
    ,p_validation_end_date     => l_validation_end_date
    );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pay_ele_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pay_ele_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pay_ele_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting pre-insert operation
  --
  pay_ele_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pay_ele_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_ele_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_assignment_id                  in     number
  ,p_element_link_id                in     number
  ,p_creator_type                   in     varchar2
  ,p_entry_type                     in     varchar2
  ,p_cost_allocation_keyflex_id     in     number   default null
  ,p_updating_action_id             in     number   default null
  ,p_updating_action_type           in     varchar2 default null
  ,p_original_entry_id              in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_creator_id                     in     number   default null
  ,p_reason                         in     varchar2 default null
  ,p_target_entry_id                in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_subpriority                    in     number   default null
  ,p_personal_payment_method_id     in     number   default null
  ,p_date_earned                    in     date     default null
  ,p_source_id                      in     number   default null
  ,p_balance_adj_cost_flag          in     varchar2 default null
  ,p_element_entry_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_comment_id                        out nocopy number
  ) is
--
  l_rec         pay_ele_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
  l_ele_type_id pay_element_types_f.element_type_id%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- First derive the element_type_id
  --
    l_ele_type_id := pay_ele_bus.derive_element_type_id
                     (p_element_link_id => p_element_link_id
                     ,p_effective_date  => p_effective_date);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_ele_shd.convert_args
    (null
    ,null
    ,null
    ,p_cost_allocation_keyflex_id
    ,p_assignment_id
    ,p_updating_action_id
    ,p_updating_action_type
    ,p_element_link_id
    ,p_original_entry_id
    ,p_creator_type
    ,p_entry_type
    ,null
    ,p_comments
    ,p_creator_id
    ,p_reason
    ,p_target_entry_id
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_subpriority
    ,p_personal_payment_method_id
    ,p_date_earned
    ,null
    ,p_source_id
    ,p_balance_adj_cost_flag
    ,l_ele_type_id
    ,null -- p_all_entry_values_null
    );
  --
  -- Having converted the arguments into the pay_ele_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_ele_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_element_entry_id                 := l_rec.element_entry_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  p_comment_id                       := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_ele_ins;

/
