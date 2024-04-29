--------------------------------------------------------
--  DDL for Package Body AME_APT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APT_INS" as
/* $Header: amaptrhi.pkb 120.1 2006/04/21 08:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ame_apt_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_approver_type_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_approver_type_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ame_apt_ins.g_approver_type_id_i := p_approver_type_id;
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
  (p_rec                     in out nocopy      ame_apt_shd.g_rec_type
  ,p_effective_date          in                 date
  ,p_datetrack_mode          in                 varchar2
  ,p_validation_start_date   in                 date
  ,p_validation_end_date     in                 date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.creation_date
    from ame_approver_types t
     where t.approver_type_id = p_rec.approver_type_id
       and t.start_date       = ame_apt_shd.g_old_rec.start_date
       and t.end_date         = p_validation_start_date;
--
  Cursor C_Sel2 Is
    select created_by
      from ame_approver_types t
     where t.approver_type_id = p_rec.approver_type_id
       and ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById
       and rownum < 2;
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ame_approver_types.created_by%TYPE;
  l_creation_date       ame_approver_types.creation_date%TYPE;
  l_last_update_date    ame_approver_types.last_update_date%TYPE;
  l_last_updated_by     ame_approver_types.last_updated_by%TYPE;
  l_last_update_login   ame_approver_types.last_update_login%TYPE;
  l_current_user_id     integer;
  l_temp_count          integer;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.start_date  := p_validation_start_date;
  p_rec.end_date    := p_validation_end_date;
  l_current_user_id := fnd_global.user_id;
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
   ame_apt_shd.get_object_version_number
      (p_approver_type_id =>  p_rec.approver_type_id
      );
  --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_creation_date;
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
    Open C_Sel2;
    Fetch C_Sel2 Into l_temp_count;
    if C_Sel2%found then
      l_created_by := l_temp_count;
    else
      l_created_by := l_current_user_id;
    end if;
    Close C_Sel2;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := l_current_user_id;
    l_last_update_login  := l_current_user_id;
  Else
    p_rec.object_version_number := 1;  -- Initialise the object version
    --
    -- If the current user logged in using AME Developer responsibility
    -- then the created_by value should be ame_util.seededDataCreatedById
    --
    if fnd_global.resp_name = 'AME Developer' then
      l_created_by         := ame_util.seededDataCreatedById;
    else
      l_created_by         := l_current_user_id;
    end if;
    l_creation_date      := sysdate;
    l_last_update_date   := sysdate;
    l_last_updated_by    := l_current_user_id;
    l_last_update_login  := l_current_user_id;
  End If;
  --
  -- Insert the row into: ame_approver_types
  --
  insert into ame_approver_types
      (approver_type_id
      ,orig_system
      ,query_variable_1_label
      ,query_variable_2_label
      ,query_variable_3_label
      ,query_variable_4_label
      ,query_variable_5_label
      ,variable_1_lov_query
      ,variable_2_lov_query
      ,variable_3_lov_query
      ,variable_4_lov_query
      ,variable_5_lov_query
      ,query_procedure
      ,start_date
      ,end_date
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.approver_type_id
    ,p_rec.orig_system
    ,p_rec.query_variable_1_label
    ,p_rec.query_variable_2_label
    ,p_rec.query_variable_3_label
    ,p_rec.query_variable_4_label
    ,p_rec.query_variable_5_label
    ,p_rec.variable_1_lov_query
    ,p_rec.variable_2_lov_query
    ,p_rec.variable_3_lov_query
    ,p_rec.variable_4_lov_query
    ,p_rec.variable_5_lov_query
    ,p_rec.query_procedure
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.object_version_number
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
    ame_apt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ame_apt_shd.constraint_error
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
  (p_rec                   in out nocopy ame_apt_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc   varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ame_apt_ins.dt_insert_dml
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
  (p_rec                   in out nocopy   ame_apt_shd.g_rec_type
  ,p_effective_date        in              date
  ,p_datetrack_mode        in              varchar2
  ,p_validation_start_date in              date
  ,p_validation_end_date   in              date
  ) is
--
Cursor C_Sel1 is
    Select ame_approver_types_s.nextval from dual;
--
Cursor C_Sel2 is
    Select null
      from ame_approver_types
      where approver_type_id =
      ame_apt_ins.g_approver_type_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (ame_apt_ins.g_approver_type_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ame_approver_types');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.approver_type_id :=
      ame_apt_ins.g_approver_type_id_i;
    ame_apt_ins.g_approver_type_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.approver_type_id;
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
  (p_rec                   in ame_apt_shd.g_rec_type
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
    ame_apt_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_approver_type_id            => p_rec.approver_type_id
      ,p_orig_system                 => p_rec.orig_system
      ,p_query_variable_1_label      => p_rec.query_variable_1_label
      ,p_query_variable_2_label      => p_rec.query_variable_2_label
      ,p_query_variable_3_label      => p_rec.query_variable_3_label
      ,p_query_variable_4_label      => p_rec.query_variable_4_label
      ,p_query_variable_5_label      => p_rec.query_variable_5_label
      ,p_variable_1_lov_query        => p_rec.variable_1_lov_query
      ,p_variable_2_lov_query        => p_rec.variable_2_lov_query
      ,p_variable_3_lov_query        => p_rec.variable_3_lov_query
      ,p_variable_4_lov_query        => p_rec.variable_4_lov_query
      ,p_variable_5_lov_query        => p_rec.variable_5_lov_query
      ,p_query_procedure             => p_rec.query_procedure
      ,p_start_date                  => p_rec.start_date
      ,p_end_date                    => p_rec.end_date
      ,p_object_version_number       => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'AME_APPROVER_TYPES'
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
  (p_effective_date        in         date
  ,p_datetrack_mode        in         varchar2
  ,p_rec                   in         ame_apt_shd.g_rec_type
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
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := sysdate;
  p_validation_end_date   := ame_utility_pkg.endOfTime;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in             date
  ,p_rec            in out nocopy  ame_apt_shd.g_rec_type
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
  ame_apt_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  ame_apt_bus.insert_validate
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
  ame_apt_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  ame_apt_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  ame_apt_ins.post_insert
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
  (p_effective_date               in            date
  ,p_orig_system                  in            varchar2
  ,p_query_variable_1_label       in            varchar2 default null
  ,p_query_variable_2_label       in            varchar2 default null
  ,p_query_variable_3_label       in            varchar2 default null
  ,p_query_variable_4_label       in            varchar2 default null
  ,p_query_variable_5_label       in            varchar2 default null
  ,p_variable_1_lov_query         in            varchar2 default null
  ,p_variable_2_lov_query         in            varchar2 default null
  ,p_variable_3_lov_query         in            varchar2 default null
  ,p_variable_4_lov_query         in            varchar2 default null
  ,p_variable_5_lov_query         in            varchar2 default null
  ,p_query_procedure              in            varchar2 default null
  ,p_approver_type_id             out nocopy    number
  ,p_start_date                   out nocopy    date
  ,p_end_date                     out nocopy    date
  ,p_object_version_number        out nocopy    number
  ) is
--
  l_rec         ame_apt_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ame_apt_shd.convert_args
    (null
    ,p_orig_system
    ,p_query_variable_1_label
    ,p_query_variable_2_label
    ,p_query_variable_3_label
    ,p_query_variable_4_label
    ,p_query_variable_5_label
    ,p_variable_1_lov_query
    ,p_variable_2_lov_query
    ,p_variable_3_lov_query
    ,p_variable_4_lov_query
    ,p_variable_5_lov_query
    ,p_query_procedure
    ,null
    ,null
    ,null
    );
  --
  -- Having converted the arguments into the ame_apt_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ame_apt_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_approver_type_id          := l_rec.approver_type_id;
  p_start_date                := l_rec.start_date;
  p_end_date                  := l_rec.end_date;
  p_object_version_number     := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ame_apt_ins;

/
