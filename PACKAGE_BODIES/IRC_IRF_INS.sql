--------------------------------------------------------
--  DDL for Package Body IRC_IRF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRF_INS" as
/* $Header: irirfrhi.pkb 120.1 2008/04/16 07:34:32 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irf_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_referral_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_referral_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_irf_ins.g_referral_info_id_i := p_referral_info_id;
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
  (p_rec                     in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.creation_date
    from   irc_referral_info t
    where t.referral_info_id = p_rec.referral_info_id
    and    t.start_date =
             irc_irf_shd.g_old_rec.start_date
    and    t.end_date   = p_validation_start_date;
--
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_creation_date       irc_referral_info.creation_date%TYPE;
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
   irc_irf_shd.get_object_version_number
      (p_referral_info_id =>  p_rec.referral_info_id
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
    --
    -- Set the AOL updated WHO values
    --
  Else
    p_rec.object_version_number := 1;  -- Initialise the object version
  End If;
  --
  --
  --
  -- Insert the row into: irc_referral_info
  --
  insert into irc_referral_info
      (referral_info_id
      ,object_id
      ,object_type
      ,start_date
      ,end_date
      ,source_type
      ,source_name
      ,source_criteria1
      ,source_value1
      ,source_criteria2
      ,source_value2
      ,source_criteria3
      ,source_value3
      ,source_criteria4
      ,source_value4
      ,source_criteria5
      ,source_value5
      ,source_person_id
      ,candidate_comment
      ,employee_comment
      ,irf_attribute_category
      ,irf_attribute1
      ,irf_attribute2
      ,irf_attribute3
      ,irf_attribute4
      ,irf_attribute5
      ,irf_attribute6
      ,irf_attribute7
      ,irf_attribute8
      ,irf_attribute9
      ,irf_attribute10
      ,irf_information_category
      ,irf_information1
      ,irf_information2
      ,irf_information3
      ,irf_information4
      ,irf_information5
      ,irf_information6
      ,irf_information7
      ,irf_information8
      ,irf_information9
      ,irf_information10
      ,object_created_by
      ,created_by
      ,object_version_number
      )
  Values
    (p_rec.referral_info_id
    ,p_rec.object_id
    ,p_rec.object_type
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.source_type
    ,p_rec.source_name
    ,p_rec.source_criteria1
    ,p_rec.source_value1
    ,p_rec.source_criteria2
    ,p_rec.source_value2
    ,p_rec.source_criteria3
    ,p_rec.source_value3
    ,p_rec.source_criteria4
    ,p_rec.source_value4
    ,p_rec.source_criteria5
    ,p_rec.source_value5
    ,p_rec.source_person_id
    ,p_rec.candidate_comment
    ,p_rec.employee_comment
    ,p_rec.irf_attribute_category
    ,p_rec.irf_attribute1
    ,p_rec.irf_attribute2
    ,p_rec.irf_attribute3
    ,p_rec.irf_attribute4
    ,p_rec.irf_attribute5
    ,p_rec.irf_attribute6
    ,p_rec.irf_attribute7
    ,p_rec.irf_attribute8
    ,p_rec.irf_attribute9
    ,p_rec.irf_attribute10
    ,p_rec.irf_information_category
    ,p_rec.irf_information1
    ,p_rec.irf_information2
    ,p_rec.irf_information3
    ,p_rec.irf_information4
    ,p_rec.irf_information5
    ,p_rec.irf_information6
    ,p_rec.irf_information7
    ,p_rec.irf_information8
    ,p_rec.irf_information9
    ,p_rec.irf_information10
    ,p_rec.object_created_by
    ,p_rec.created_by
    ,p_rec.object_version_number
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_irf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_irf_shd.constraint_error
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
  (p_rec                   in out nocopy irc_irf_shd.g_rec_type
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
  irc_irf_ins.dt_insert_dml
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
  (p_rec                   in out nocopy irc_irf_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select irc_referral_info_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from irc_referral_info
     where object_id = p_rec.object_id
       and object_type = p_rec.object_type
       and p_effective_date between start_date
             and end_date;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
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
     fnd_message.set_token('TABLE_NAME','irc_referral_info');
     fnd_message.raise_error;
  End If;
  Close C_Sel2;
  If (irc_irf_ins.g_referral_info_id_i is not null) Then
    --
    -- Use registered key values and clear globals
    --
    p_rec.referral_info_id :=
      irc_irf_ins.g_referral_info_id_i;
    irc_irf_ins.g_referral_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.referral_info_id;
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
  (p_rec                   in irc_irf_shd.g_rec_type
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
    irc_irf_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_validation_start_date       => p_validation_start_date
      ,p_validation_end_date         => p_validation_end_date
      ,p_referral_info_id             => p_rec.referral_info_id
	  ,p_object_id                    => p_rec.object_id
	  ,p_object_type                  => p_rec.object_type
	  ,p_start_date                   => p_rec.start_date
	  ,p_end_date            	      => p_rec.end_date
	  ,p_source_type            	  => p_rec.source_type
	  ,p_source_name            	  => p_rec.source_name
	  ,p_source_criteria1             => p_rec.source_criteria1
	  ,p_source_value1            	  => p_rec.source_value1
	  ,p_source_criteria2             => p_rec.source_criteria2
	  ,p_source_value2            	  => p_rec.source_value2
	  ,p_source_criteria3             => p_rec.source_criteria3
	  ,p_source_value3                => p_rec.source_value3
	  ,p_source_criteria4             => p_rec.source_criteria4
	  ,p_source_value4                => p_rec.source_value4
	  ,p_source_criteria5             => p_rec.source_criteria5
	  ,p_source_value5                => p_rec.source_value5
	  ,p_source_person_id             => p_rec.source_person_id
	  ,p_candidate_comment            => p_rec.candidate_comment
	  ,p_employee_comment             => p_rec.employee_comment
	  ,p_irf_attribute_category       => p_rec.irf_attribute_category
	  ,p_irf_attribute1               => p_rec.irf_attribute1
	  ,p_irf_attribute2               => p_rec.irf_attribute2
	  ,p_irf_attribute3               => p_rec.irf_attribute3
	  ,p_irf_attribute4               => p_rec.irf_attribute4
	  ,p_irf_attribute5               => p_rec.irf_attribute5
	  ,p_irf_attribute6               => p_rec.irf_attribute6
	  ,p_irf_attribute7               => p_rec.irf_attribute7
	  ,p_irf_attribute8               => p_rec.irf_attribute8
	  ,p_irf_attribute9               => p_rec.irf_attribute9
	  ,p_irf_attribute10              => p_rec.irf_attribute10
	  ,p_irf_information_category     => p_rec.irf_information_category
	  ,p_irf_information1             => p_rec.irf_information1
	  ,p_irf_information2             => p_rec.irf_information2
	  ,p_irf_information3             => p_rec.irf_information3
	  ,p_irf_information4             => p_rec.irf_information4
	  ,p_irf_information5             => p_rec.irf_information5
	  ,p_irf_information6             => p_rec.irf_information6
	  ,p_irf_information7             => p_rec.irf_information7
	  ,p_irf_information8             => p_rec.irf_information8
	  ,p_irf_information9             => p_rec.irf_information9
	  ,p_irf_information10            => p_rec.irf_information10
	  ,p_object_created_by            => p_rec.object_created_by
	  ,p_created_by                   => p_rec.created_by
	  ,p_object_version_number        => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_REFERRAL_INFO'
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
  ,p_rec                   in irc_irf_shd.g_rec_type
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
--  p_validation_start_date := l_validation_start_date;
--  p_validation_end_date   := l_validation_end_date;
  p_validation_start_date := sysdate;
  p_validation_end_date   := hr_general.end_of_time;
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
  ,p_rec            in out nocopy irc_irf_shd.g_rec_type
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
  irc_irf_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
    irc_irf_bus.insert_validate
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
  irc_irf_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  irc_irf_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  irc_irf_ins.post_insert
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
  (p_effective_date                 in 		 date
  ,p_object_id                   	in 		 number
  ,p_object_type                    in 		 varchar2
  ,p_source_type            		in 		 varchar2
  ,p_source_name            		in 		 varchar2
  ,p_source_criteria1               in 	     varchar2
  ,p_source_value1            	    in 		 varchar2
  ,p_source_criteria2               in 		 varchar2
  ,p_source_value2            	    in 		 varchar2
  ,p_source_criteria3               in 		 varchar2
  ,p_source_value3                  in 		 varchar2
  ,p_source_criteria4               in 		 varchar2
  ,p_source_value4                  in 		 varchar2
  ,p_source_criteria5               in 		 varchar2
  ,p_source_value5                  in 		 varchar2
  ,p_source_person_id               in 		 number
  ,p_candidate_comment              in 		 varchar2
  ,p_employee_comment               in 		 varchar2
  ,p_irf_attribute_category         in 		 varchar2
  ,p_irf_attribute1                 in 		 varchar2
  ,p_irf_attribute2                 in 		 varchar2
  ,p_irf_attribute3                 in 		 varchar2
  ,p_irf_attribute4                 in 		 varchar2
  ,p_irf_attribute5                 in 		 varchar2
  ,p_irf_attribute6                 in 		 varchar2
  ,p_irf_attribute7                 in 		 varchar2
  ,p_irf_attribute8                 in 		 varchar2
  ,p_irf_attribute9                 in 		 varchar2
  ,p_irf_attribute10                in 		 varchar2
  ,p_irf_information_category       in 		 varchar2
  ,p_irf_information1               in 		 varchar2
  ,p_irf_information2               in 		 varchar2
  ,p_irf_information3               in 		 varchar2
  ,p_irf_information4               in 		 varchar2
  ,p_irf_information5               in 		 varchar2
  ,p_irf_information6               in 		 varchar2
  ,p_irf_information7               in 		 varchar2
  ,p_irf_information8               in 		 varchar2
  ,p_irf_information9               in 		 varchar2
  ,p_irf_information10              in 		 varchar2
  ,p_object_created_by              in 		 varchar2
  ,p_referral_info_id               out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
--
  l_rec         irc_irf_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_irf_shd.convert_args
    (null
    ,p_object_id
    ,p_object_type
    ,p_start_date
    ,p_end_date
    ,p_source_type
    ,p_source_name
    ,p_source_criteria1
    ,p_source_value1
    ,p_source_criteria2
    ,p_source_value2
    ,p_source_criteria3
    ,p_source_value3
    ,p_source_criteria4
    ,p_source_value4
    ,p_source_criteria5
    ,p_source_value5
    ,p_source_person_id
    ,p_candidate_comment
    ,p_employee_comment
    ,p_irf_attribute_category
    ,p_irf_attribute1
    ,p_irf_attribute2
    ,p_irf_attribute3
    ,p_irf_attribute4
    ,p_irf_attribute5
    ,p_irf_attribute6
    ,p_irf_attribute7
    ,p_irf_attribute8
    ,p_irf_attribute9
    ,p_irf_attribute10
    ,p_irf_information_category
    ,p_irf_information1
    ,p_irf_information2
    ,p_irf_information3
    ,p_irf_information4
    ,p_irf_information5
    ,p_irf_information6
    ,p_irf_information7
    ,p_irf_information8
    ,p_irf_information9
    ,p_irf_information10
    ,p_object_created_by
    ,null
    );
  --
  -- Having converted the arguments into the irc_irf_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_irf_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_referral_info_id := l_rec.referral_info_id;
  p_start_date             := l_rec.start_date;
  p_end_date               := l_rec.end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_irf_ins;

/
