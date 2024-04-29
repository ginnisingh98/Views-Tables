--------------------------------------------------------
--  DDL for Package Body PAY_PPR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPR_INS" as
/* $Header: pypprrhi.pkb 115.3 2004/02/25 21:33 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ppr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_status_processing_rule_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_status_processing_rule_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_ppr_ins.g_status_processing_rule_id_i := p_status_processing_rule_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
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
  (p_rec                     in out nocopy pay_ppr_shd.g_rec_type
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
    from   pay_status_processing_rules_f t
    where  t.status_processing_rule_id       = p_rec.status_processing_rule_id
    and    t.effective_start_date =
             pay_ppr_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_status_processing_rules_f.created_by%TYPE;
  l_creation_date       pay_status_processing_rules_f.creation_date%TYPE;
  l_last_update_date    pay_status_processing_rules_f.last_update_date%TYPE;
  l_last_updated_by     pay_status_processing_rules_f.last_updated_by%TYPE;
  l_last_update_login   pay_status_processing_rules_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
      -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_status_processing_rules_f'
      ,p_base_key_column => 'status_processing_rule_id'
      ,p_base_key_value  => p_rec.status_processing_rule_id
      );
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
  Else
    p_rec.object_version_number := 1;  -- Initialise the object version
  End If;
  --
  pay_ppr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_status_processing_rules_f
  --
  insert into pay_status_processing_rules_f
      (status_processing_rule_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,element_type_id
      ,assignment_status_type_id
      ,formula_id
      ,processing_rule
      ,comment_id
      ,legislation_subgroup
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.status_processing_rule_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.element_type_id
    ,p_rec.assignment_status_type_id
    ,p_rec.formula_id
    ,p_rec.processing_rule
    ,p_rec.comment_id
    ,p_rec.legislation_subgroup
    ,p_rec.object_version_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  pay_ppr_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_ppr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_ppr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_ppr_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = hr_startup_data_api_support.g_session_id;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
     --
     FOR c1 IN csr_definition LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy pay_ppr_shd.g_rec_type
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
  pay_ppr_ins.dt_insert_dml
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
  (p_rec                   in out nocopy pay_ppr_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pay_status_processing_rules_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pay_status_processing_rules_f
     where status_processing_rule_id =
             pay_ppr_ins.g_status_processing_rule_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pay_ppr_ins.g_status_processing_rule_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_status_processing_rules_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.status_processing_rule_id :=
      pay_ppr_ins.g_status_processing_rule_id_i;
    pay_ppr_ins.g_status_processing_rule_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.status_processing_rule_id;
    Close C_Sel1;
  End If;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_comm_api.ins
      (p_comment_id        => p_rec.comment_id
      ,p_source_table_name => 'PAY_STATUS_PROCESSING_RULES_F'
      ,p_comment_text      => p_rec.comments
      );
  End If;

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
  (p_rec                   in pay_ppr_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_formula_mismatch_warning in boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
      --
    -- insert ownerships if applicable
    create_app_ownerships
      ('STATUS_PROCESSING_RULE_ID', p_rec.status_processing_rule_id
      );
    --
    --
    pay_ppr_rki.after_insert
      (p_effective_date             => p_effective_date
      ,p_validation_start_date      => p_validation_start_date
      ,p_validation_end_date        => p_validation_end_date
      ,p_status_processing_rule_id  => p_rec.status_processing_rule_id
      ,p_effective_start_date       => p_rec.effective_start_date
      ,p_effective_end_date         => p_rec.effective_end_date
      ,p_business_group_id          => p_rec.business_group_id
      ,p_legislation_code           => p_rec.legislation_code
      ,p_element_type_id            => p_rec.element_type_id
      ,p_assignment_status_type_id  => p_rec.assignment_status_type_id
      ,p_formula_id                 => p_rec.formula_id
      ,p_comment_id                 => p_rec.comment_id
      ,p_comments                   => p_rec.comments
      ,p_legislation_subgroup       => p_rec.legislation_subgroup
      ,p_object_version_number      => p_rec.object_version_number
      ,p_formula_mismatch_warning   => p_formula_mismatch_warning
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_STATUS_PROCESSING_RULES_F'
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
  ,p_rec                   in pay_ppr_shd.g_rec_type
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
    ,p_base_table_name         => 'pay_status_processing_rules_f'
    ,p_base_key_column         => 'status_processing_rule_id'
    ,p_base_key_value          => p_rec.status_processing_rule_id
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
  ,p_rec            in out nocopy pay_ppr_shd.g_rec_type
  ,p_formula_mismatch_warning out nocopy boolean
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
  l_processing_rule             varchar2(1);
  l_formula_mismatch_warning    boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pay_ppr_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );

  --
  -- Call the supporting insert validate operations
  --
  pay_ppr_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    ,p_processing_rule       => l_processing_rule
    ,p_formula_mismatch_warning => l_formula_mismatch_warning
    );
  --

      p_rec.processing_rule          := l_processing_rule;
      p_formula_mismatch_warning := l_formula_mismatch_warning;
  --
  pay_ppr_bus.set_effective_end_date
	  (p_effective_date             => p_effective_date
 	  ,p_status_processing_rule_id  => null
	  ,p_element_type_id		=> p_rec.element_type_id
	  ,p_formula_id			=> p_rec.formula_id
	  ,p_assignment_status_type_id  => p_rec.assignment_status_type_id
	  ,p_processing_rule            => p_rec.processing_rule
	  ,p_business_group_id          => p_rec.business_group_id
	  ,p_legislation_code           => p_rec.legislation_code
	  ,p_datetrack_mode             => null
	  ,p_validation_start_date      => l_validation_start_date
          ,p_validation_end_date        => l_validation_end_date
  );

  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_ppr_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pay_ppr_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_ppr_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    ,p_formula_mismatch_warning =>l_formula_mismatch_warning
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
  ,p_element_type_id                in     number
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_formula_id                     in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_legislation_subgroup           in     varchar2 default null
  ,p_status_processing_rule_id         out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_comment_id                        out nocopy number
  ,p_formula_mismatch_warning	       out nocopy boolean
  ) is
--
  l_rec         pay_ppr_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
  l_formula_mismatch_warning    boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_ppr_shd.convert_args
    (null
    ,null
    ,null
    ,p_business_group_id
    ,p_legislation_code
    ,p_element_type_id
    ,p_assignment_status_type_id
    ,p_formula_id
    ,null
    ,null
    ,p_comments
    ,p_legislation_subgroup
    ,null
    );
  --
  -- Having converted the arguments into the pay_ppr_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_ppr_ins.ins
    (p_effective_date
    ,l_rec
    ,l_formula_mismatch_warning
    );
  --
  -- Set the OUT arguments.
  --
  p_status_processing_rule_id        := l_rec.status_processing_rule_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  p_comment_id                       := l_rec.comment_id;
  p_formula_mismatch_warning         := l_formula_mismatch_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_ppr_ins;

/
