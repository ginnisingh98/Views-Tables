--------------------------------------------------------
--  DDL for Package Body PAY_PRT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRT_INS" as
/* $Header: pyprtrhi.pkb 115.13 2003/02/28 15:52:21 alogue noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prt_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_run_type_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_run_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_prt_ins.g_run_type_id_i := p_run_type_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------------<dt_insert_dml >-----------------------------|
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
  (p_rec                     in out nocopy pay_prt_shd.g_rec_type
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
    from   pay_run_types_f t
    where  t.run_type_id       = p_rec.run_type_id
    and    t.effective_start_date =
             pay_prt_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_run_types_f.created_by%TYPE;
  l_creation_date       pay_run_types_f.creation_date%TYPE;
  l_last_update_date    pay_run_types_f.last_update_date%TYPE;
  l_last_updated_by     pay_run_types_f.last_updated_by%TYPE;
  l_last_update_login   pay_run_types_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_run_types_f'
      ,p_base_key_column => 'run_type_id'
      ,p_base_key_value  => p_rec.run_type_id
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
  -- Insert the row into: pay_run_types_f
  --
  insert into pay_run_types_f
      (run_type_id
      ,run_type_name
      ,run_method
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,legislation_code
      ,shortname
      ,srs_flag
      ,run_information_category
      ,run_information1
      ,run_information2
      ,run_information3
      ,run_information4
      ,run_information5
      ,run_information6
      ,run_information7
      ,run_information8
      ,run_information9
      ,run_information10
      ,run_information11
      ,run_information12
      ,run_information13
      ,run_information14
      ,run_information15
      ,run_information16
      ,run_information17
      ,run_information18
      ,run_information19
      ,run_information20
      ,run_information21
      ,run_information22
      ,run_information23
      ,run_information24
      ,run_information25
      ,run_information26
      ,run_information27
      ,run_information28
      ,run_information29
      ,run_information30
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.run_type_id
    ,p_rec.run_type_name
    ,p_rec.run_method
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.shortname
    ,p_rec.srs_flag
    ,p_rec.run_information_category
    ,p_rec.run_information1
    ,p_rec.run_information2
    ,p_rec.run_information3
    ,p_rec.run_information4
    ,p_rec.run_information5
    ,p_rec.run_information6
    ,p_rec.run_information7
    ,p_rec.run_information8
    ,p_rec.run_information9
    ,p_rec.run_information10
    ,p_rec.run_information11
    ,p_rec.run_information12
    ,p_rec.run_information13
    ,p_rec.run_information14
    ,p_rec.run_information15
    ,p_rec.run_information16
    ,p_rec.run_information17
    ,p_rec.run_information18
    ,p_rec.run_information19
    ,p_rec.run_information20
    ,p_rec.run_information21
    ,p_rec.run_information22
    ,p_rec.run_information23
    ,p_rec.run_information24
    ,p_rec.run_information25
    ,p_rec.run_information26
    ,p_rec.run_information27
    ,p_rec.run_information28
    ,p_rec.run_information29
    ,p_rec.run_information30
    ,p_rec.object_version_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_prt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
  --
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
CURSOR csr_definition (p_session_id number) IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = p_session_id;
--
l_session_id number;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
  --
    l_session_id := nvl(hr_startup_data_api_support.g_startup_session_id
                       ,hr_startup_data_api_support.g_session_id);
     --
     FOR c1 IN csr_definition(l_session_id) LOOP
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
  (p_rec                   in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_prt_ins.dt_insert_dml
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
  (p_rec                   in out nocopy pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select pay_run_types_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from pay_run_types_f
     where run_type_id =
             pay_prt_ins.g_run_type_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (pay_prt_ins.g_run_type_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_run_types_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.run_type_id :=
      pay_prt_ins.g_run_type_id_i;
    pay_prt_ins.g_run_type_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.run_type_id;
    Close C_Sel1;
    --
  end if;
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
  (p_rec                   in pay_prt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc    varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
  -- RET added call to create_app_ownerships
  --
  -- insert ownerships if applicable
  --
    create_app_ownerships('RUN_TYPE_ID', p_rec.run_type_id);
    --
    pay_prt_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_run_type_id
      => p_rec.run_type_id
      ,p_run_type_name
      => p_rec.run_type_name
      ,p_run_method
      => p_rec.run_method
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_shortname
      => p_rec.shortname
      ,p_srs_flag
      => p_rec.srs_flag
      ,p_run_information_category
      => p_rec.run_information_category
      ,p_run_information1
      => p_rec.run_information1
      ,p_run_information2
      => p_rec.run_information2
      ,p_run_information3
      => p_rec.run_information3
      ,p_run_information4
      => p_rec.run_information4
      ,p_run_information5
      => p_rec.run_information5
      ,p_run_information6
      => p_rec.run_information6
      ,p_run_information7
      => p_rec.run_information7
      ,p_run_information8
      => p_rec.run_information8
      ,p_run_information9
      => p_rec.run_information9
      ,p_run_information10
      => p_rec.run_information10
      ,p_run_information11
      => p_rec.run_information11
      ,p_run_information12
      => p_rec.run_information12
      ,p_run_information13
      => p_rec.run_information13
      ,p_run_information14
      => p_rec.run_information14
      ,p_run_information15
      => p_rec.run_information15
      ,p_run_information16
      => p_rec.run_information16
      ,p_run_information17
      => p_rec.run_information17
      ,p_run_information18
      => p_rec.run_information18
      ,p_run_information19
      => p_rec.run_information19
      ,p_run_information20
      => p_rec.run_information20
      ,p_run_information21
      => p_rec.run_information21
      ,p_run_information22
      => p_rec.run_information22
      ,p_run_information23
      => p_rec.run_information23
      ,p_run_information24
      => p_rec.run_information24
      ,p_run_information25
      => p_rec.run_information25
      ,p_run_information26
      => p_rec.run_information26
      ,p_run_information27
      => p_rec.run_information27
      ,p_run_information28
      => p_rec.run_information28
      ,p_run_information29
      => p_rec.run_information29
      ,p_run_information30
      => p_rec.run_information30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RUN_TYPES_F'
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
  ,p_rec                   in pay_prt_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc          varchar2(72) := g_package||'ins_lck';
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
    ,p_base_table_name         => 'pay_run_types_f'
    ,p_base_key_column         => 'run_type_id'
    ,p_base_key_value          => p_rec.run_type_id
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
  ,p_rec            in out nocopy pay_prt_shd.g_rec_type
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
  pay_prt_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pay_prt_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting pre-insert operation
  --
  pay_prt_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pay_prt_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pay_prt_ins.post_insert
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
  ,p_run_type_name                  in     varchar2
  ,p_run_method                     in     varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_shortname                      in     varchar2 default null
  ,p_srs_flag                       in     varchar2 default null
  ,p_run_information_category	    in     varchar2 default null
  ,p_run_information1		    in     varchar2 default null
  ,p_run_information2		    in     varchar2 default null
  ,p_run_information3		    in     varchar2 default null
  ,p_run_information4		    in     varchar2 default null
  ,p_run_information5		    in     varchar2 default null
  ,p_run_information6		    in     varchar2 default null
  ,p_run_information7		    in     varchar2 default null
  ,p_run_information8		    in     varchar2 default null
  ,p_run_information9		    in     varchar2 default null
  ,p_run_information10		    in     varchar2 default null
  ,p_run_information11		    in     varchar2 default null
  ,p_run_information12		    in     varchar2 default null
  ,p_run_information13		    in     varchar2 default null
  ,p_run_information14		    in     varchar2 default null
  ,p_run_information15		    in     varchar2 default null
  ,p_run_information16		    in     varchar2 default null
  ,p_run_information17		    in     varchar2 default null
  ,p_run_information18		    in     varchar2 default null
  ,p_run_information19		    in     varchar2 default null
  ,p_run_information20		    in     varchar2 default null
  ,p_run_information21		    in     varchar2 default null
  ,p_run_information22		    in     varchar2 default null
  ,p_run_information23		    in     varchar2 default null
  ,p_run_information24		    in     varchar2 default null
  ,p_run_information25		    in     varchar2 default null
  ,p_run_information26		    in     varchar2 default null
  ,p_run_information27		    in     varchar2 default null
  ,p_run_information28		    in     varchar2 default null
  ,p_run_information29		    in     varchar2 default null
  ,p_run_information30		    in     varchar2 default null
  ,p_run_type_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         pay_prt_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_prt_shd.convert_args
    (null
    ,p_run_type_name
    ,p_run_method
    ,null
    ,null
    ,p_business_group_id
    ,p_legislation_code
    ,p_shortname
    ,p_srs_flag
    ,p_run_information_category
    ,p_run_information1
    ,p_run_information2
    ,p_run_information3
    ,p_run_information4
    ,p_run_information5
    ,p_run_information6
    ,p_run_information7
    ,p_run_information8
    ,p_run_information9
    ,p_run_information10
    ,p_run_information11
    ,p_run_information12
    ,p_run_information13
    ,p_run_information14
    ,p_run_information15
    ,p_run_information16
    ,p_run_information17
    ,p_run_information18
    ,p_run_information19
    ,p_run_information20
    ,p_run_information21
    ,p_run_information22
    ,p_run_information23
    ,p_run_information24
    ,p_run_information25
    ,p_run_information26
    ,p_run_information27
    ,p_run_information28
    ,p_run_information29
    ,p_run_information30
    ,null
    );
  --
  -- Having converted the arguments into the pay_prt_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_prt_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_run_type_id                      := l_rec.run_type_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_prt_ins;

/
