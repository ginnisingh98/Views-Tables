--------------------------------------------------------
--  DDL for Package Body PQP_VAL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_INS" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_val_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_vehicle_allocation_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_vehicle_allocation_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_val_ins.g_vehicle_allocation_id_i := p_vehicle_allocation_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec                     in out nocopy pqp_val_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor  C_Sel1 Is
   SELECT t.created_by,
          t.creation_date
    FROM  pqp_vehicle_allocations_f t
    WHERE t.vehicle_allocation_id       = p_rec.vehicle_allocation_id
      AND t.effective_start_date =
          pqp_val_shd.g_old_rec.effective_start_date
      AND t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pqp_vehicle_allocations_f.created_by%TYPE;
  l_creation_date       pqp_vehicle_allocations_f.creation_date%TYPE;
  l_last_update_date    pqp_vehicle_allocations_f.last_update_date%TYPE;
  l_last_updated_by     pqp_vehicle_allocations_f.last_updated_by%TYPE;
  l_last_update_login   pqp_vehicle_allocations_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pqp_vehicle_allocations_f'
      ,p_base_key_column => 'vehicle_allocation_id'
      ,p_base_key_value  => p_rec.vehicle_allocation_id
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
  --
  --
  -- Insert the row into: pqp_vehicle_allocations_f
  --
  insert into pqp_vehicle_allocations_f
      (vehicle_allocation_id
      ,effective_start_date
      ,effective_end_date
      ,assignment_id
      ,business_group_id
      ,across_assignments
      ,vehicle_repository_id
      ,usage_type
      ,capital_contribution
      ,private_contribution
      ,default_vehicle
      ,fuel_card
      ,fuel_card_number
      ,calculation_method
      ,rates_table_id
      ,element_type_id
      ,private_use_flag
      ,insurance_number
      ,insurance_expiry_date
      ,val_attribute_category
      ,val_attribute1
      ,val_attribute2
      ,val_attribute3
      ,val_attribute4
      ,val_attribute5
      ,val_attribute6
      ,val_attribute7
      ,val_attribute8
      ,val_attribute9
      ,val_attribute10
      ,val_attribute11
      ,val_attribute12
      ,val_attribute13
      ,val_attribute14
      ,val_attribute15
      ,val_attribute16
      ,val_attribute17
      ,val_attribute18
      ,val_attribute19
      ,val_attribute20
      ,val_information_category
      ,val_information1
      ,val_information2
      ,val_information3
      ,val_information4
      ,val_information5
      ,val_information6
      ,val_information7
      ,val_information8
      ,val_information9
      ,val_information10
      ,val_information11
      ,val_information12
      ,val_information13
      ,val_information14
      ,val_information15
      ,val_information16
      ,val_information17
      ,val_information18
      ,val_information19
      ,val_information20
      ,object_version_number
      ,fuel_benefit
      ,sliding_rates_info
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.vehicle_allocation_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.assignment_id
    ,p_rec.business_group_id
    ,p_rec.across_assignments
    ,p_rec.vehicle_repository_id
    ,p_rec.usage_type
    ,p_rec.capital_contribution
    ,p_rec.private_contribution
    ,p_rec.default_vehicle
    ,p_rec.fuel_card
    ,p_rec.fuel_card_number
    ,p_rec.calculation_method
    ,p_rec.rates_table_id
    ,p_rec.element_type_id
    ,p_rec.private_use_flag
    ,p_rec.insurance_number
    ,p_rec.insurance_expiry_date
    ,p_rec.val_attribute_category
    ,p_rec.val_attribute1
    ,p_rec.val_attribute2
    ,p_rec.val_attribute3
    ,p_rec.val_attribute4
    ,p_rec.val_attribute5
    ,p_rec.val_attribute6
    ,p_rec.val_attribute7
    ,p_rec.val_attribute8
    ,p_rec.val_attribute9
    ,p_rec.val_attribute10
    ,p_rec.val_attribute11
    ,p_rec.val_attribute12
    ,p_rec.val_attribute13
    ,p_rec.val_attribute14
    ,p_rec.val_attribute15
    ,p_rec.val_attribute16
    ,p_rec.val_attribute17
    ,p_rec.val_attribute18
    ,p_rec.val_attribute19
    ,p_rec.val_attribute20
    ,p_rec.val_information_category
    ,p_rec.val_information1
    ,p_rec.val_information2
    ,p_rec.val_information3
    ,p_rec.val_information4
    ,p_rec.val_information5
    ,p_rec.val_information6
    ,p_rec.val_information7
    ,p_rec.val_information8
    ,p_rec.val_information9
    ,p_rec.val_information10
    ,p_rec.val_information11
    ,p_rec.val_information12
    ,p_rec.val_information13
    ,p_rec.val_information14
    ,p_rec.val_information15
    ,p_rec.val_information16
    ,p_rec.val_information17
    ,p_rec.val_information18
    ,p_rec.val_information19
    ,p_rec.val_information20
    ,p_rec.object_version_number
    ,p_rec.fuel_benefit
    ,p_rec.sliding_rates_info
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_val_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_val_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pqp_val_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_val_ins.dt_insert_dml
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
  (p_rec                   in out nocopy pqp_val_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pqp_vehicle_allocations_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pqp_vehicle_allocations_f
     where vehicle_allocation_id =
             pqp_val_ins.g_vehicle_allocation_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pqp_val_ins.g_vehicle_allocation_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pqp_vehicle_allocations_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.vehicle_allocation_id :=
      pqp_val_ins.g_vehicle_allocation_id_i;
    pqp_val_ins.g_vehicle_allocation_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.vehicle_allocation_id;
    Close C_Sel1;
  End If;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
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
  (p_rec                   in pqp_val_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_val_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_vehicle_allocation_id
      => p_rec.vehicle_allocation_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_across_assignments
      => p_rec.across_assignments
      ,p_vehicle_repository_id
      => p_rec.vehicle_repository_id
      ,p_usage_type
      => p_rec.usage_type
      ,p_capital_contribution
      => p_rec.capital_contribution
      ,p_private_contribution
      => p_rec.private_contribution
      ,p_default_vehicle
      => p_rec.default_vehicle
      ,p_fuel_card
      => p_rec.fuel_card
      ,p_fuel_card_number
      => p_rec.fuel_card_number
      ,p_calculation_method
      => p_rec.calculation_method
      ,p_rates_table_id
      => p_rec.rates_table_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_private_use_flag
      => p_rec.private_use_flag
      ,p_insurance_number
      => p_rec.insurance_number
      ,p_insurance_expiry_date
      => p_rec.insurance_expiry_date
      ,p_val_attribute_category
      => p_rec.val_attribute_category
      ,p_val_attribute1
      => p_rec.val_attribute1
      ,p_val_attribute2
      => p_rec.val_attribute2
      ,p_val_attribute3
      => p_rec.val_attribute3
      ,p_val_attribute4
      => p_rec.val_attribute4
      ,p_val_attribute5
      => p_rec.val_attribute5
      ,p_val_attribute6
      => p_rec.val_attribute6
      ,p_val_attribute7
      => p_rec.val_attribute7
      ,p_val_attribute8
      => p_rec.val_attribute8
      ,p_val_attribute9
      => p_rec.val_attribute9
      ,p_val_attribute10
      => p_rec.val_attribute10
      ,p_val_attribute11
      => p_rec.val_attribute11
      ,p_val_attribute12
      => p_rec.val_attribute12
      ,p_val_attribute13
      => p_rec.val_attribute13
      ,p_val_attribute14
      => p_rec.val_attribute14
      ,p_val_attribute15
      => p_rec.val_attribute15
      ,p_val_attribute16
      => p_rec.val_attribute16
      ,p_val_attribute17
      => p_rec.val_attribute17
      ,p_val_attribute18
      => p_rec.val_attribute18
      ,p_val_attribute19
      => p_rec.val_attribute19
      ,p_val_attribute20
      => p_rec.val_attribute20
      ,p_val_information_category
      => p_rec.val_information_category
      ,p_val_information1
      => p_rec.val_information1
      ,p_val_information2
      => p_rec.val_information2
      ,p_val_information3
      => p_rec.val_information3
      ,p_val_information4
      => p_rec.val_information4
      ,p_val_information5
      => p_rec.val_information5
      ,p_val_information6
      => p_rec.val_information6
      ,p_val_information7
      => p_rec.val_information7
      ,p_val_information8
      => p_rec.val_information8
      ,p_val_information9
      => p_rec.val_information9
      ,p_val_information10
      => p_rec.val_information10
      ,p_val_information11
      => p_rec.val_information11
      ,p_val_information12
      => p_rec.val_information12
      ,p_val_information13
      => p_rec.val_information13
      ,p_val_information14
      => p_rec.val_information14
      ,p_val_information15
      => p_rec.val_information15
      ,p_val_information16
      => p_rec.val_information16
      ,p_val_information17
      => p_rec.val_information17
      ,p_val_information18
      => p_rec.val_information18
      ,p_val_information19
      => p_rec.val_information19
      ,p_val_information20
      => p_rec.val_information20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_fuel_benefit
      => p_rec.fuel_benefit
      ,p_sliding_rates_info
      => p_rec.sliding_rates_info
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  ,p_rec                   in pqp_val_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'pqp_vehicle_allocations_f'
    ,p_base_key_column         => 'vehicle_allocation_id'
    ,p_base_key_value          => p_rec.vehicle_allocation_id
    ,p_parent_table_name1      =>'pqp_vehicle_repository_f'
    ,p_parent_key_column1      =>'vehicle_repository_id'
    ,p_parent_key_value1       =>p_rec.vehicle_repository_id
    ,p_parent_table_name2      =>'per_all_assignments_f'
    ,p_parent_key_column2      =>'assignment_id'
    ,p_parent_key_value2       =>p_rec.assignment_id
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
  ,p_rec            in out nocopy pqp_val_shd.g_rec_type
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
  pqp_val_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pqp_val_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_val_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pqp_val_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pqp_val_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
  ,p_business_group_id              in     number
  ,p_vehicle_repository_id          in     number
  ,p_across_assignments             in     varchar2
  ,p_usage_type                     in     varchar2
  ,p_capital_contribution           in     number
  ,p_private_contribution           in     number
  ,p_default_vehicle                in     varchar2
  ,p_fuel_card                      in     varchar2
  ,p_fuel_card_number               in     varchar2
  ,p_calculation_method             in     varchar2
  ,p_rates_table_id                 in     number
  ,p_element_type_id                in     number
  ,p_private_use_flag               in     varchar2
  ,p_insurance_number               in     varchar2
  ,p_insurance_expiry_date          in    date
  ,p_val_attribute_category         in     varchar2
  ,p_val_attribute1                 in     varchar2
  ,p_val_attribute2                 in     varchar2
  ,p_val_attribute3                 in     varchar2
  ,p_val_attribute4                 in     varchar2
  ,p_val_attribute5                 in     varchar2
  ,p_val_attribute6                 in     varchar2
  ,p_val_attribute7                 in     varchar2
  ,p_val_attribute8                 in     varchar2
  ,p_val_attribute9                 in     varchar2
  ,p_val_attribute10                in     varchar2
  ,p_val_attribute11                in     varchar2
  ,p_val_attribute12                in     varchar2
  ,p_val_attribute13                in     varchar2
  ,p_val_attribute14                in     varchar2
  ,p_val_attribute15                in     varchar2
  ,p_val_attribute16                in     varchar2
  ,p_val_attribute17                in     varchar2
  ,p_val_attribute18                in     varchar2
  ,p_val_attribute19                in     varchar2
  ,p_val_attribute20                in     varchar2
  ,p_val_information_category       in     varchar2
  ,p_val_information1               in     varchar2
  ,p_val_information2               in     varchar2
  ,p_val_information3               in     varchar2
  ,p_val_information4               in     varchar2
  ,p_val_information5               in     varchar2
  ,p_val_information6               in     varchar2
  ,p_val_information7               in     varchar2
  ,p_val_information8               in     varchar2
  ,p_val_information9               in     varchar2
  ,p_val_information10              in     varchar2
  ,p_val_information11              in     varchar2
  ,p_val_information12              in     varchar2
  ,p_val_information13              in     varchar2
  ,p_val_information14              in     varchar2
  ,p_val_information15              in     varchar2
  ,p_val_information16              in     varchar2
  ,p_val_information17              in     varchar2
  ,p_val_information18              in     varchar2
  ,p_val_information19              in     varchar2
  ,p_val_information20              in     varchar2
  ,p_fuel_benefit                   in     varchar2
  ,p_sliding_rates_info                  in varchar2
  ,p_vehicle_allocation_id          out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is
--
  l_rec         pqp_val_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_val_shd.convert_args
    (null
    ,null
    ,null
    ,p_assignment_id
    ,p_business_group_id
    ,p_across_assignments
    ,p_vehicle_repository_id
    ,p_usage_type
    ,p_capital_contribution
    ,p_private_contribution
    ,p_default_vehicle
    ,p_fuel_card
    ,p_fuel_card_number
    ,p_calculation_method
    ,p_rates_table_id
    ,p_element_type_id
    ,p_private_use_flag
    ,p_insurance_number
    ,p_insurance_expiry_date
    ,p_val_attribute_category
    ,p_val_attribute1
    ,p_val_attribute2
    ,p_val_attribute3
    ,p_val_attribute4
    ,p_val_attribute5
    ,p_val_attribute6
    ,p_val_attribute7
    ,p_val_attribute8
    ,p_val_attribute9
    ,p_val_attribute10
    ,p_val_attribute11
    ,p_val_attribute12
    ,p_val_attribute13
    ,p_val_attribute14
    ,p_val_attribute15
    ,p_val_attribute16
    ,p_val_attribute17
    ,p_val_attribute18
    ,p_val_attribute19
    ,p_val_attribute20
    ,p_val_information_category
    ,p_val_information1
    ,p_val_information2
    ,p_val_information3
    ,p_val_information4
    ,p_val_information5
    ,p_val_information6
    ,p_val_information7
    ,p_val_information8
    ,p_val_information9
    ,p_val_information10
    ,p_val_information11
    ,p_val_information12
    ,p_val_information13
    ,p_val_information14
    ,p_val_information15
    ,p_val_information16
    ,p_val_information17
    ,p_val_information18
    ,p_val_information19
    ,p_val_information20
    ,null
    ,p_fuel_benefit
    ,p_sliding_rates_info
    );
  --
  -- Having converted the arguments into the pqp_val_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_val_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_vehicle_allocation_id            := l_rec.vehicle_allocation_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_val_ins;

/
