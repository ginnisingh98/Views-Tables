--------------------------------------------------------
--  DDL for Package Body PER_SPS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPS_INS" as
/* $Header: pespsrhi.pkb 120.5.12000000.1 2007/01/22 04:39:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sps_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_step_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_step_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_sps_ins.g_step_id_i := p_step_id;
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
  (p_rec                     in out nocopy per_sps_shd.g_rec_type
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
    from   per_spinal_point_steps_f t
    where  t.step_id       = p_rec.step_id
    and    t.effective_start_date =
             per_sps_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          per_spinal_point_steps_f.created_by%TYPE;
  l_creation_date       per_spinal_point_steps_f.creation_date%TYPE;
  l_last_update_date    per_spinal_point_steps_f.last_update_date%TYPE;
  l_last_updated_by     per_spinal_point_steps_f.last_updated_by%TYPE;
  l_last_update_login   per_spinal_point_steps_f.last_update_login%TYPE;
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
      (p_base_table_name => 'per_spinal_point_steps_f'
      ,p_base_key_column => 'step_id'
      ,p_base_key_value  => p_rec.step_id
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
  per_sps_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_spinal_point_steps_f
  --
  insert into per_spinal_point_steps_f
      (step_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,spinal_point_id
      ,grade_spine_id
      ,sequence
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,information_category
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.step_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.spinal_point_id
    ,p_rec.grade_spine_id
    ,p_rec.sequence
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.information1
    ,p_rec.information2
    ,p_rec.information3
    ,p_rec.information4
    ,p_rec.information5
    ,p_rec.information6
    ,p_rec.information7
    ,p_rec.information8
    ,p_rec.information9
    ,p_rec.information10
    ,p_rec.information11
    ,p_rec.information12
    ,p_rec.information13
    ,p_rec.information14
    ,p_rec.information15
    ,p_rec.information16
    ,p_rec.information17
    ,p_rec.information18
    ,p_rec.information19
    ,p_rec.information20
    ,p_rec.information21
    ,p_rec.information22
    ,p_rec.information23
    ,p_rec.information24
    ,p_rec.information25
    ,p_rec.information26
    ,p_rec.information27
    ,p_rec.information28
    ,p_rec.information29
    ,p_rec.information30
    ,p_rec.information_category
    ,p_rec.object_version_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  per_sps_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
    per_sps_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
    per_sps_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_sps_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy per_sps_shd.g_rec_type
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
  per_sps_ins.dt_insert_dml
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
  (p_rec                   in out nocopy per_sps_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select per_spinal_point_steps_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from per_spinal_point_steps_f
     where step_id =
             per_sps_ins.g_step_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (per_sps_ins.g_step_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_spinal_point_steps_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.step_id :=
      per_sps_ins.g_step_id_i;
    per_sps_ins.g_step_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.step_id;
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
  (p_rec                   in per_sps_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc              varchar2(72) := g_package||'post_insert';
  l_pay_scale_name    varchar2(30);
  l_spinal_point_name varchar2(30);
  l_grade_id          number;
  l_return            varchar2(20);
  l_message           varchar2(2000) := null;
  --
  cursor csr_get_names is
    select pps.name
          ,psp.spinal_point
          ,pgs.grade_id
    from   per_parent_spines pps
          ,per_grade_spines_f pgs
          ,per_spinal_points psp
    where  pgs.grade_spine_id = p_rec.grade_spine_id
    and    p_effective_date between
           pgs.effective_start_date and pgs.effective_end_date
    and    pps.parent_spine_id = pgs.parent_spine_id
    and    psp.spinal_point_id = p_rec.spinal_point_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Need to create option and option in plan for Benefit
  --
  --
  open csr_get_names;
  fetch csr_get_names into l_pay_scale_name,l_spinal_point_name,l_grade_id;
  if csr_get_names%notfound then
    close csr_get_names;
    hr_utility.set_location(l_proc, 10);
  else
  /* comment out BUG3179239
    l_return := pqh_gsp_sync_compensation_obj.create_option_for_point
      (p_spinal_point_id         => p_rec.spinal_point_id
      ,p_pay_scale_name          => l_pay_scale_name
      ,p_spinal_point_name       => l_spinal_point_name
      );
    --
    hr_utility.trace('pqh_gsp_sync_compensation_obj.create_option_for_point : '
                  || l_return);
    --
    if l_return <> 'SUCCESS' Then
       l_message := fnd_message.get;
       hr_utility.trace('error message : ' || l_message);
       fnd_message.set_name('PER','HR_289527_CRE_OPTION_FOR_POINT');
       if l_message is not null then
         fnd_message.set_token('ERR_CODE',l_message);
       else
         fnd_message.set_token('ERR_CODE','-1');
       end if;
       --
       fnd_message.raise_error;
    End if;

  */ -- End of BUG3179239

    l_return := pqh_gsp_sync_compensation_obj.create_oipl_for_step
      (p_grade_id                => l_grade_id
      ,p_spinal_point_id         => p_rec.spinal_point_id
      ,p_step_id                 => p_rec.step_id
      ,p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      );
    --
    hr_utility.trace('pqh_gsp_sync_compensation_obj.oipl_for_step           : '
                  || l_return);
    --
    if l_return <> 'SUCCESS' Then
       l_message := fnd_message.get;
       hr_utility.trace('error message : ' || l_message);
       fnd_message.set_name('PER','HR_289528_CRE_OPTION_IN_PLAN');
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
  hr_utility.set_location(l_proc, 20);
  --
  begin
    --
    per_sps_rki.after_insert
      (p_effective_date
      => p_effective_date
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
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_spinal_point_id
      => p_rec.spinal_point_id
      ,p_grade_spine_id
      => p_rec.grade_spine_id
      ,p_sequence
      => p_rec.sequence
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_information1
      => p_rec.information1
      ,p_information2
      => p_rec.information2
      ,p_information3
      => p_rec.information3
      ,p_information4
      => p_rec.information4
      ,p_information5
      => p_rec.information5
      ,p_information6
      => p_rec.information6
      ,p_information7
      => p_rec.information7
      ,p_information8
      => p_rec.information8
      ,p_information9
      => p_rec.information9
      ,p_information10
      => p_rec.information10
      ,p_information11
      => p_rec.information11
      ,p_information12
      => p_rec.information12
      ,p_information13
      => p_rec.information13
      ,p_information14
      => p_rec.information14
      ,p_information15
      => p_rec.information15
      ,p_information16
      => p_rec.information16
      ,p_information17
      => p_rec.information17
      ,p_information18
      => p_rec.information18
      ,p_information19
      => p_rec.information19
      ,p_information20
      => p_rec.information20
      ,p_information21
      => p_rec.information21
      ,p_information22
      => p_rec.information22
      ,p_information23
      => p_rec.information23
      ,p_information24
      => p_rec.information24
      ,p_information25
      => p_rec.information25
      ,p_information26
      => p_rec.information26
      ,p_information27
      => p_rec.information27
      ,p_information28
      => p_rec.information28
      ,p_information29
      => p_rec.information29
      ,p_information30
      => p_rec.information30
      ,p_information_category
      => p_rec.information_category
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SPINAL_POINT_STEPS_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
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
  ,p_rec                   in per_sps_shd.g_rec_type
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
    ,p_base_table_name         => 'per_spinal_point_steps_f'
    ,p_base_key_column         => 'step_id'
    ,p_base_key_value          => p_rec.step_id
    ,p_parent_table_name1      => 'per_grade_spines_f'
    ,p_parent_key_column1      => 'grade_spine_id'
    ,p_parent_key_value1       => p_rec.grade_spine_id
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
  ,p_rec            in out nocopy per_sps_shd.g_rec_type
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
  per_sps_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  per_sps_bus.insert_validate
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
  per_sps_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  per_sps_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  per_sps_ins.post_insert
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
  ,p_business_group_id              in     number
  ,p_spinal_point_id                in     number
  ,p_grade_spine_id                 in     number
  ,p_sequence                       in     number
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_step_id                        in out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         per_sps_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_sps_shd.convert_args
    (p_step_id
    ,null
    ,null
    ,p_business_group_id
    ,p_spinal_point_id
    ,p_grade_spine_id
    ,p_sequence
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_information1
    ,p_information2
    ,p_information3
    ,p_information4
    ,p_information5
    ,p_information6
    ,p_information7
    ,p_information8
    ,p_information9
    ,p_information10
    ,p_information11
    ,p_information12
    ,p_information13
    ,p_information14
    ,p_information15
    ,p_information16
    ,p_information17
    ,p_information18
    ,p_information19
    ,p_information20
    ,p_information21
    ,p_information22
    ,p_information23
    ,p_information24
    ,p_information25
    ,p_information26
    ,p_information27
    ,p_information28
    ,p_information29
    ,p_information30
    ,p_information_category
    ,null
    );
  --
  -- Having converted the arguments into the per_sps_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_sps_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_step_id                          := l_rec.step_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_sps_ins;

/
