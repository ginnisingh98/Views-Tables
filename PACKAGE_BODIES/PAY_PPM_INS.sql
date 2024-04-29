--------------------------------------------------------
--  DDL for Package Body PAY_PPM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPM_INS" as
/* $Header: pyppmrhi.pkb 120.3.12010000.5 2010/03/30 06:46:19 priupadh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ppm_ins.';  -- Global package name
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
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Arguments:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pay_personal_payment_methods_f t
    where  t.personal_payment_method_id       = p_rec.personal_payment_method_id

    and    t.effective_start_date =
             pay_ppm_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_personal_payment_methods_f.created_by%TYPE;
  l_creation_date       pay_personal_payment_methods_f.creation_date%TYPE;
  l_last_update_date   	pay_personal_payment_methods_f.last_update_date%TYPE;
  l_last_updated_by     pay_personal_payment_methods_f.last_updated_by%TYPE;
  l_last_update_login   pay_personal_payment_methods_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'pay_personal_payment_methods_f',
	 p_base_key_column => 'personal_payment_method_id',
	 p_base_key_value  => p_rec.personal_payment_method_id);
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
  If (p_datetrack_mode <> 'INSERT') then
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
      hr_utility.set_message(801, 'HR_51456_PPM_RETURN_DATE_NULL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
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
  pay_ppm_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_personal_payment_methods_f
  --
  insert into pay_personal_payment_methods_f
  (	personal_payment_method_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	external_account_id,
	assignment_id,
	run_type_id,
	org_payment_method_id,
	amount,
	comment_id,
	percentage,
	priority,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
	object_version_number,
	payee_type,
	payee_id,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login,
        ppm_information_category,
        ppm_information1,
        ppm_information2,
        ppm_information3,
        ppm_information4,
        ppm_information5,
        ppm_information6,
        ppm_information7,
        ppm_information8,
        ppm_information9,
        ppm_information10,
        ppm_information11,
        ppm_information12,
        ppm_information13,
        ppm_information14,
        ppm_information15,
        ppm_information16,
        ppm_information17,
        ppm_information18,
        ppm_information19,
        ppm_information20,
        ppm_information21,
        ppm_information22,
        ppm_information23,
        ppm_information24,
        ppm_information25,
        ppm_information26,
        ppm_information27,
        ppm_information28,
        ppm_information29,
        ppm_information30
  )
  Values
  (	p_rec.personal_payment_method_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.business_group_id,
	p_rec.external_account_id,
	p_rec.assignment_id,
	p_rec.run_type_id,
	p_rec.org_payment_method_id,
	p_rec.amount,
	p_rec.comment_id,
	p_rec.percentage,
	p_rec.priority,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,
	p_rec.object_version_number,
	p_rec.payee_type,
	p_rec.payee_id,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login,
        p_rec.ppm_information_category,
        p_rec.ppm_information1,
        p_rec.ppm_information2,
        p_rec.ppm_information3,
        p_rec.ppm_information4,
        p_rec.ppm_information5,
        p_rec.ppm_information6,
        p_rec.ppm_information7,
        p_rec.ppm_information8,
        p_rec.ppm_information9,
        p_rec.ppm_information10,
        p_rec.ppm_information11,
        p_rec.ppm_information12,
        p_rec.ppm_information13,
        p_rec.ppm_information14,
        p_rec.ppm_information15,
        p_rec.ppm_information16,
        p_rec.ppm_information17,
        p_rec.ppm_information18,
        p_rec.ppm_information19,
        p_rec.ppm_information20,
        p_rec.ppm_information21,
        p_rec.ppm_information22,
        p_rec.ppm_information23,
        p_rec.ppm_information24,
        p_rec.ppm_information25,
        p_rec.ppm_information26,
        p_rec.ppm_information27,
        p_rec.ppm_information28,
        p_rec.ppm_information29,
        p_rec.ppm_information30
  );
  --
  pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
	(p_rec  			in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_personal_payment_methods_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.personal_payment_method_id;
  Close C_Sel1;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                    p_comment_text      => p_rec.comments);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  begin
    pay_ppm_rki.after_insert
      (p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_personal_payment_method_id     => p_rec.personal_payment_method_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_business_group_id              => p_rec.business_group_id
      ,p_external_account_id            => p_rec.external_account_id
      ,p_assignment_id                  => p_rec.assignment_id
      ,p_org_payment_method_id          => p_rec.org_payment_method_id
      ,p_amount                         => p_rec.amount
      ,p_comment_id                     => p_rec.comment_id
      ,p_percentage                     => p_rec.percentage
      ,p_priority                       => p_rec.priority
      ,p_attribute_category             => p_rec.attribute_category
      ,p_attribute1                     => p_rec.attribute1
      ,p_attribute2                     => p_rec.attribute2
      ,p_attribute3                     => p_rec.attribute3
      ,p_attribute4                     => p_rec.attribute4
      ,p_attribute5                     => p_rec.attribute5
      ,p_attribute6                     => p_rec.attribute6
      ,p_attribute7                     => p_rec.attribute7
      ,p_attribute8                     => p_rec.attribute8
      ,p_attribute9                     => p_rec.attribute9
      ,p_attribute10                    => p_rec.attribute10
      ,p_attribute11                    => p_rec.attribute11
      ,p_attribute12                    => p_rec.attribute12
      ,p_attribute13                    => p_rec.attribute13
      ,p_attribute14                    => p_rec.attribute14
      ,p_attribute15                    => p_rec.attribute15
      ,p_attribute16                    => p_rec.attribute16
      ,p_attribute17                    => p_rec.attribute17
      ,p_attribute18                    => p_rec.attribute18
      ,p_attribute19                    => p_rec.attribute19
      ,p_attribute20                    => p_rec.attribute20
      ,p_object_version_number          => p_rec.object_version_number
      ,p_payee_type                     => p_rec.payee_type
      ,p_payee_id                       => p_rec.payee_id
      ,p_ppm_information_category       => p_rec.ppm_information_category
      ,p_ppm_information1               => p_rec.ppm_information1
      ,p_ppm_information2               => p_rec.ppm_information2
      ,p_ppm_information3               => p_rec.ppm_information3
      ,p_ppm_information4               => p_rec.ppm_information4
      ,p_ppm_information5               => p_rec.ppm_information5
      ,p_ppm_information6               => p_rec.ppm_information6
      ,p_ppm_information7               => p_rec.ppm_information7
      ,p_ppm_information8               => p_rec.ppm_information8
      ,p_ppm_information9               => p_rec.ppm_information9
      ,p_ppm_information10              => p_rec.ppm_information10
      ,p_ppm_information11              => p_rec.ppm_information11
      ,p_ppm_information12              => p_rec.ppm_information12
      ,p_ppm_information13              => p_rec.ppm_information13
      ,p_ppm_information14              => p_rec.ppm_information14
      ,p_ppm_information15              => p_rec.ppm_information15
      ,p_ppm_information16              => p_rec.ppm_information16
      ,p_ppm_information17              => p_rec.ppm_information17
      ,p_ppm_information18              => p_rec.ppm_information18
      ,p_ppm_information19              => p_rec.ppm_information19
      ,p_ppm_information20              => p_rec.ppm_information20
      ,p_ppm_information21              => p_rec.ppm_information21
      ,p_ppm_information22              => p_rec.ppm_information22
      ,p_ppm_information23              => p_rec.ppm_information23
      ,p_ppm_information24              => p_rec.ppm_information24
      ,p_ppm_information25              => p_rec.ppm_information25
      ,p_ppm_information26              => p_rec.ppm_information26
      ,p_ppm_information27              => p_rec.ppm_information27
      ,p_ppm_information28              => p_rec.ppm_information28
      ,p_ppm_information29              => p_rec.ppm_information29
      ,p_ppm_information30              => p_rec.ppm_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_PERSONAL_PAYMENT_METHODS_F'
        ,p_hook_type   => 'AI'
        );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  pay_ppm_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_lock_table            varchar2(30);
  l_validation_start_date1 date;
  l_validation_end_date1   date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Need to validate against PAY_ORG_PAYMENT_METHODS_F and
    -- PAY_ORG_PAY_METHOD_USAGES_F so lock in SHARE mode. This is because the
    -- data is infrequently updated, but is referenced by many pay methods.
    -- SELECT ... FOR UPDATE NOWAIT causes too many failures for concurrent
    -- API usage cases such as self-service or data pump.
    --
    l_lock_table := 'pay_org_payment_methods_f';
    lock table pay_org_payment_methods_f in share mode nowait;
    --
    l_lock_table := 'pay_org_pay_method_usages_f';
    lock table pay_org_pay_method_usages_f in share mode nowait;
  exception
    When HR_Api.Object_Locked then
      --
      -- The object is locked therefore we need to supply a meaningful
      -- error message.
      --
      hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
      hr_utility.set_message_token('TABLE_NAME', l_lock_table);
      hr_utility.raise_error;
  end;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  --
  -- First do the datetrack locking/validation for PER_ALL_ASSIGNMENTS_F.
  -- PER_ALL_ASSIGNMENTS_F cannot be locked in TABLE SHARE mode because
  -- of the nature of updates to ASSIGNMENT information.
  --
  dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'pay_personal_payment_methods_f',
         p_base_key_column         => 'personal_payment_method_id',
         p_base_key_value          => p_rec.personal_payment_method_id,
         p_parent_table_name1      => 'per_all_assignments_f',
         p_parent_key_column1      => 'assignment_id',
         p_parent_key_value1       => p_rec.assignment_id,
         p_enforce_foreign_locking => true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  --
  -- Without relocking, do the datetrack validation for the parent tables
  -- locked in shared mode.
  --
  dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'pay_personal_payment_methods_f',
         p_base_key_column         => 'personal_payment_method_id',
         p_base_key_value          => p_rec.personal_payment_method_id,
         p_parent_table_name1      => 'pay_org_payment_methods_f',
         p_parent_key_column1      => 'org_payment_method_id',
         p_parent_key_value1       => p_rec.org_payment_method_id,
         p_enforce_foreign_locking => false,
         p_validation_start_date   => l_validation_start_date1,
         p_validation_end_date     => l_validation_end_date1);
  --
  -- Set the validation start and end date OUT arguments by getting the most
  -- restrictive validation date range.
  --
  p_validation_start_date :=
  greatest(l_validation_start_date, l_validation_start_date1);
  p_validation_end_date   :=
  least(l_validation_end_date, l_validation_end_date1);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec		   in out nocopy pay_ppm_shd.g_rec_type,
  p_effective_date in     date,
  p_validate	   in     boolean default false
  ) IS
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
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
    SAVEPOINT ins_pay_ppm;
  End If;
  --
  -- Call the lock operation
  --
  ins_lck
	(p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_rec	 		 => p_rec,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Ensure that the assignment is for an employee
  --
  l_validation_end_date := pay_ppm_bus.return_effective_end_date
        (p_datetrack_mode              =>  l_datetrack_mode
        ,p_effective_date              =>  p_effective_date
        ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
        ,p_business_group_id           =>  p_rec.business_group_id
        ,p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
        ,p_assignment_id               =>  p_rec.assignment_id
        ,p_run_type_id                 =>  p_rec.run_type_id
        ,p_priority                    =>  p_rec.priority
        ,p_validation_start_date       =>  l_validation_start_date
        ,p_validation_end_date         =>  l_validation_end_date
        );
  --
  -- Call the supporting insert validate operations
  --
  pay_ppm_bus.insert_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
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
    ROLLBACK TO ins_pay_ppm;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_personal_payment_method_id   out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_external_account_id          in number           default null,
  p_assignment_id                in number,
  p_run_type_id                  in number           default null,
  p_org_payment_method_id        in number,
  p_amount                       in number           default null,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_percentage                   in number           default null,
  p_priority                     in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_payee_type                   in varchar2         default null,
  p_payee_id                     in number           default null,
  p_effective_date		 in date,
  p_validate			 in boolean          default false,
  p_ppm_information_category     in varchar2         default null,
  p_ppm_information1             in varchar2         default null,
  p_ppm_information2             in varchar2         default null,
  p_ppm_information3             in varchar2         default null,
  p_ppm_information4             in varchar2         default null,
  p_ppm_information5             in varchar2         default null,
  p_ppm_information6             in varchar2         default null,
  p_ppm_information7             in varchar2         default null,
  p_ppm_information8             in varchar2         default null,
  p_ppm_information9             in varchar2         default null,
  p_ppm_information10            in varchar2         default null,
  p_ppm_information11            in varchar2         default null,
  p_ppm_information12            in varchar2         default null,
  p_ppm_information13            in varchar2         default null,
  p_ppm_information14            in varchar2         default null,
  p_ppm_information15            in varchar2         default null,
  p_ppm_information16            in varchar2         default null,
  p_ppm_information17            in varchar2         default null,
  p_ppm_information18            in varchar2         default null,
  p_ppm_information19            in varchar2         default null,
  p_ppm_information20            in varchar2         default null,
  p_ppm_information21            in varchar2         default null,
  p_ppm_information22            in varchar2         default null,
  p_ppm_information23            in varchar2         default null,
  p_ppm_information24            in varchar2         default null,
  p_ppm_information25            in varchar2         default null,
  p_ppm_information26            in varchar2         default null,
  p_ppm_information27            in varchar2         default null,
  p_ppm_information28            in varchar2         default null,
  p_ppm_information29            in varchar2         default null,
  p_ppm_information30            in varchar2         default null
  ) is
--
  l_rec		pay_ppm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_ppm_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_external_account_id,
  p_assignment_id,
  p_run_type_id,
  p_org_payment_method_id,
  p_amount,
  null,
  p_comments,
  p_percentage,
  p_priority,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  null,
  p_payee_type,
  p_payee_id,
  p_ppm_information_category,
  p_ppm_information1,
  p_ppm_information2,
  p_ppm_information3,
  p_ppm_information4,
  p_ppm_information5,
  p_ppm_information6,
  p_ppm_information7,
  p_ppm_information8,
  p_ppm_information9,
  p_ppm_information10,
  p_ppm_information11,
  p_ppm_information12,
  p_ppm_information13,
  p_ppm_information14,
  p_ppm_information15,
  p_ppm_information16,
  p_ppm_information17,
  p_ppm_information18,
  p_ppm_information19,
  p_ppm_information20,
  p_ppm_information21,
  p_ppm_information22,
  p_ppm_information23,
  p_ppm_information24,
  p_ppm_information25,
  p_ppm_information26,
  p_ppm_information27,
  p_ppm_information28,
  p_ppm_information29,
  p_ppm_information30
  );
  --
  -- Having converted the arguments into the pay_ppm_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date, p_validate);
  --
  -- Set the OUT arguments.
  --
  p_personal_payment_method_id  := l_rec.personal_payment_method_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  p_comment_id                  := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_ppm_ins;

/
