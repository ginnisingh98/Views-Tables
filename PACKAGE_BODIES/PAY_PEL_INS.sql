--------------------------------------------------------
--  DDL for Package Body PAY_PEL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEL_INS" as
/* $Header: pypelrhi.pkb 120.7.12010000.3 2008/10/03 08:41:56 ankagarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pel_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_element_link_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_element_link_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_pel_ins.g_element_link_id_i := p_element_link_id;
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
  (p_rec                     in out nocopy pay_pel_shd.g_rec_type
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
    from   pay_element_links_f t
    where  t.element_link_id       = p_rec.element_link_id
    and    t.effective_start_date =
             pay_pel_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_element_links_f.created_by%TYPE;
  l_creation_date       pay_element_links_f.creation_date%TYPE;
  l_last_update_date    pay_element_links_f.last_update_date%TYPE;
  l_last_updated_by     pay_element_links_f.last_updated_by%TYPE;
  l_last_update_login   pay_element_links_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_element_links_f'
      ,p_base_key_column => 'element_link_id'
      ,p_base_key_value  => p_rec.element_link_id
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
  pay_pel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_element_links_f
  --
  insert into pay_element_links_f
      (element_link_id
      ,effective_start_date
      ,effective_end_date
      ,payroll_id
      ,job_id
      ,position_id
      ,people_group_id
      ,cost_allocation_keyflex_id
      ,organization_id
      ,element_type_id
      ,location_id
      ,grade_id
      ,balancing_keyflex_id
      ,business_group_id
      ,element_set_id
      ,pay_basis_id
      ,costable_type
      ,link_to_all_payrolls_flag
      ,multiply_value_flag
      ,standard_link_flag
      ,transfer_to_gl_flag
      ,comment_id
      ,employment_category
      ,qualifying_age
      ,qualifying_length_of_service
      ,qualifying_units
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
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.element_link_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.payroll_id
    ,p_rec.job_id
    ,p_rec.position_id
    ,p_rec.people_group_id
    ,p_rec.cost_allocation_keyflex_id
    ,p_rec.organization_id
    ,p_rec.element_type_id
    ,p_rec.location_id
    ,p_rec.grade_id
    ,p_rec.balancing_keyflex_id
    ,p_rec.business_group_id
    ,p_rec.element_set_id
    ,p_rec.pay_basis_id
    ,p_rec.costable_type
    ,p_rec.link_to_all_payrolls_flag
    ,p_rec.multiply_value_flag
    ,p_rec.standard_link_flag
    ,p_rec.transfer_to_gl_flag
    ,p_rec.comment_id
    ,p_rec.employment_category
    ,p_rec.qualifying_age
    ,p_rec.qualifying_length_of_service
    ,p_rec.qualifying_units
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
    ,p_rec.object_version_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pay_pel_shd.g_rec_type
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
  pay_pel_ins.dt_insert_dml
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
  (p_rec                   in out nocopy pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pay_element_links_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pay_element_links_f
     where element_link_id =
             pay_pel_ins.g_element_link_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pay_pel_ins.g_element_link_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_element_links_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.element_link_id :=
      pay_pel_ins.g_element_link_id_i;
    pay_pel_ins.g_element_link_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.element_link_id;
    Close C_Sel1;
  End If;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_comm_api.ins
      (p_comment_id        => p_rec.comment_id
      ,p_source_table_name => 'PAY_ELEMENT_LINKS_F'
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
  (p_rec                   in pay_pel_shd.g_rec_type
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
    pay_pel_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_element_link_id
      => p_rec.element_link_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_payroll_id
      => p_rec.payroll_id
      ,p_job_id
      => p_rec.job_id
      ,p_position_id
      => p_rec.position_id
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_cost_allocation_keyflex_id
      => p_rec.cost_allocation_keyflex_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_location_id
      => p_rec.location_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_balancing_keyflex_id
      => p_rec.balancing_keyflex_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_element_set_id
      => p_rec.element_set_id
      ,p_pay_basis_id
      => p_rec.pay_basis_id
      ,p_costable_type
      => p_rec.costable_type
      ,p_link_to_all_payrolls_flag
      => p_rec.link_to_all_payrolls_flag
      ,p_multiply_value_flag
      => p_rec.multiply_value_flag
      ,p_standard_link_flag
      => p_rec.standard_link_flag
      ,p_transfer_to_gl_flag
      => p_rec.transfer_to_gl_flag
      ,p_comment_id
      => p_rec.comment_id
      ,p_comments
      => p_rec.comments
      ,p_employment_category
      => p_rec.employment_category
      ,p_qualifying_age
      => p_rec.qualifying_age
      ,p_qualifying_length_of_service
      => p_rec.qualifying_length_of_service
      ,p_qualifying_units
      => p_rec.qualifying_units
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
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ELEMENT_LINKS_F'
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
  ,p_rec                   in pay_pel_shd.g_rec_type
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
    ,p_base_table_name         => 'pay_element_links_f'
    ,p_base_key_column         => 'element_link_id'
    ,p_base_key_value          => p_rec.element_link_id
    ,p_parent_table_name1      => 'pay_all_payrolls_f'
    ,p_parent_key_column1      => 'payroll_id'
    ,p_parent_key_value1       => p_rec.payroll_id
    ,p_parent_table_name2      => 'pay_element_types_f'
    ,p_parent_key_column2      => 'element_type_id'
    ,p_parent_key_value2       => p_rec.element_type_id
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
  ,p_rec            in out nocopy pay_pel_shd.g_rec_type
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
  pay_pel_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );


  -- The end date is set by the following procedure.
  -- Called here in order to overide the date setting by the lck procedure

  -- Bug 4138645. Changed the value passed to the p_effective_start_date
  -- parameter in the call to chk_end_date from p_rec.effective_start_date
  -- to l_validation_start_date. This is because p_rec.effective_start_date
  -- will be set to null at this point.

  pay_pel_bus.chk_end_date
  (p_rec.element_type_id ,
   null ,
   l_validation_start_date,
   l_validation_end_date ,
   p_rec.organization_id ,
   p_rec.people_group_id ,
   p_rec.job_id ,
   p_rec.position_id ,
   p_rec.grade_id ,
   p_rec.location_id ,
   p_rec.link_to_all_payrolls_flag ,
   p_rec.payroll_id ,
   p_rec.employment_category ,
   p_rec.pay_basis_id ,
   p_rec.business_group_id
  );
  --
  -- Call the supporting insert validate operations
  --
  pay_pel_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );

  --
  -- Bug 6010954. We cannot populate the location during the process as this
  -- does not allow the user to set null to location, hence commented out
  -- the following. The organization unit validation has been moved to
  -- insert_validate.
  --
  -- validation for organization outside insert validate to default
  -- location id in p_rec
  -- if p_rec.organization_id is not null then
  --    pay_pel_bus.chk_org_unit
  --    (p_business_group_id  =>	p_rec.business_group_id
  --    ,p_organization_id 	  =>    p_rec.organization_id
  --    ,p_effective_date     =>    p_effective_date
  --    ,p_location_id        =>    p_rec.location_id
  --    );
  --  end if;

  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_pel_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  if p_rec.costable_type = 'D' then
    p_rec.transfer_to_gl_flag := 'Y';
  elsif p_rec.costable_type in ('N','F') then
    p_rec.transfer_to_gl_flag := nvl(p_rec.transfer_to_gl_flag,'Y');
  end if;

  pay_pel_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_pel_ins.post_insert
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
  (p_effective_date                in     date
  ,p_element_type_id               in     number
  ,p_business_group_id             in     number
  ,p_costable_type                 in     varchar2
  ,p_link_to_all_payrolls_flag     in     varchar2
  ,p_multiply_value_flag           in     varchar2
  ,p_standard_link_flag            in     varchar2
  ,p_transfer_to_gl_flag           in     varchar2
  ,p_payroll_id                    in     number   default null
  ,p_job_id                        in     number   default null
  ,p_position_id                   in     number   default null
  ,p_people_group_id               in     number   default null
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_organization_id               in     number   default null
  ,p_location_id                   in     number   default null
  ,p_grade_id                      in     number   default null
  ,p_balancing_keyflex_id          in     number   default null
  ,p_element_set_id                in     number   default null
  ,p_pay_basis_id                  in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_employment_category           in     varchar2 default null
  ,p_qualifying_age                in     number   default null
  ,p_qualifying_length_of_service  in     number   default null
  ,p_qualifying_units              in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_element_link_id                  out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_comment_id			      out nocopy number
  ) is
--
  l_rec         pay_pel_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pel_shd.convert_args
    (null
    ,null
    ,null
    ,p_payroll_id
    ,p_job_id
    ,p_position_id
    ,p_people_group_id
    ,p_cost_allocation_keyflex_id
    ,p_organization_id
    ,p_element_type_id
    ,p_location_id
    ,p_grade_id
    ,p_balancing_keyflex_id
    ,p_business_group_id
    ,p_element_set_id
    ,p_pay_basis_id
    ,p_costable_type
    ,p_link_to_all_payrolls_flag
    ,p_multiply_value_flag
    ,p_standard_link_flag
    ,p_transfer_to_gl_flag
    ,null
    ,p_comment_id
    ,p_employment_category
    ,p_qualifying_age
    ,p_qualifying_length_of_service
    ,p_qualifying_units
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
    ,null
    );
  --
  -- Having converted the arguments into the pay_pel_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pel_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_element_link_id                  := l_rec.element_link_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  p_comment_id                       := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_pel_ins;

/
