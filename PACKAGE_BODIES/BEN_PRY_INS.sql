--------------------------------------------------------
--  DDL for Package Body BEN_PRY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRY_INS" as
/* $Header: bepryrhi.pkb 120.5.12010000.3 2008/08/05 15:23:35 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pry_ins.';  -- Global package name
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
  (p_rec                     in out nocopy ben_pry_shd.g_rec_type
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
    from   ben_prtt_rmt_aprvd_fr_pymt_f t
    where  t.prtt_rmt_aprvd_fr_pymt_id       = p_rec.prtt_rmt_aprvd_fr_pymt_id
    and    t.effective_start_date =
             ben_pry_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_prtt_rmt_aprvd_fr_pymt_f.created_by%TYPE;
  l_creation_date       ben_prtt_rmt_aprvd_fr_pymt_f.creation_date%TYPE;
  l_last_update_date    ben_prtt_rmt_aprvd_fr_pymt_f.last_update_date%TYPE;
  l_last_updated_by     ben_prtt_rmt_aprvd_fr_pymt_f.last_updated_by%TYPE;
  l_last_update_login   ben_prtt_rmt_aprvd_fr_pymt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'ben_prtt_rmt_aprvd_fr_pymt_f'
      ,p_base_key_column => 'prtt_rmt_aprvd_fr_pymt_id'
      ,p_base_key_value  => p_rec.prtt_rmt_aprvd_fr_pymt_id
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
  ben_pry_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_prtt_rmt_aprvd_fr_pymt_f
  --
  insert into ben_prtt_rmt_aprvd_fr_pymt_f
      (prtt_rmt_aprvd_fr_pymt_id
      ,prtt_reimbmt_rqst_id
      ,effective_start_date
      ,effective_end_date
      ,apprvd_fr_pymt_num
      ,adjmt_flag
      ,aprvd_fr_pymt_amt
      ,pymt_stat_cd
      ,pymt_stat_rsn_cd
      ,pymt_stat_ovrdn_rsn_cd
      ,pymt_stat_prr_to_ovrd_cd
      ,business_group_id
      ,element_entry_value_id
      ,pry_attribute_category
      ,pry_attribute1
      ,pry_attribute2
      ,pry_attribute3
      ,pry_attribute4
      ,pry_attribute5
      ,pry_attribute6
      ,pry_attribute7
      ,pry_attribute8
      ,pry_attribute9
      ,pry_attribute10
      ,pry_attribute11
      ,pry_attribute12
      ,pry_attribute13
      ,pry_attribute14
      ,pry_attribute15
      ,pry_attribute16
      ,pry_attribute17
      ,pry_attribute18
      ,pry_attribute19
      ,pry_attribute20
      ,pry_attribute21
      ,pry_attribute22
      ,pry_attribute23
      ,pry_attribute24
      ,pry_attribute25
      ,pry_attribute26
      ,pry_attribute27
      ,pry_attribute28
      ,pry_attribute29
      ,pry_attribute30
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.prtt_rmt_aprvd_fr_pymt_id
    ,p_rec.prtt_reimbmt_rqst_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.apprvd_fr_pymt_num
    ,p_rec.adjmt_flag
    ,p_rec.aprvd_fr_pymt_amt
    ,p_rec.pymt_stat_cd
    ,p_rec.pymt_stat_rsn_cd
    ,p_rec.pymt_stat_ovrdn_rsn_cd
    ,p_rec.pymt_stat_prr_to_ovrd_cd
    ,p_rec.business_group_id
    ,p_rec.element_entry_value_id
    ,p_rec.pry_attribute_category
    ,p_rec.pry_attribute1
    ,p_rec.pry_attribute2
    ,p_rec.pry_attribute3
    ,p_rec.pry_attribute4
    ,p_rec.pry_attribute5
    ,p_rec.pry_attribute6
    ,p_rec.pry_attribute7
    ,p_rec.pry_attribute8
    ,p_rec.pry_attribute9
    ,p_rec.pry_attribute10
    ,p_rec.pry_attribute11
    ,p_rec.pry_attribute12
    ,p_rec.pry_attribute13
    ,p_rec.pry_attribute14
    ,p_rec.pry_attribute15
    ,p_rec.pry_attribute16
    ,p_rec.pry_attribute17
    ,p_rec.pry_attribute18
    ,p_rec.pry_attribute19
    ,p_rec.pry_attribute20
    ,p_rec.pry_attribute21
    ,p_rec.pry_attribute22
    ,p_rec.pry_attribute23
    ,p_rec.pry_attribute24
    ,p_rec.pry_attribute25
    ,p_rec.pry_attribute26
    ,p_rec.pry_attribute27
    ,p_rec.pry_attribute28
    ,p_rec.pry_attribute29
    ,p_rec.pry_attribute30
    ,p_rec.object_version_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pry_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pry_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pry_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy ben_pry_shd.g_rec_type
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
  ben_pry_ins.dt_insert_dml
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
  (p_rec                   in out nocopy ben_pry_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_prtt_rmt_aprvd_fr_pymt_s.nextval from sys.dual;
  Cursor C_num is
  select nvl(max(apprvd_fr_pymt_num),0) + 1
      from ben_prtt_rmt_aprvd_fr_pymt_f
      where prtt_reimbmt_rqst_id = p_rec.prtt_reimbmt_rqst_id ;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.prtt_rmt_aprvd_fr_pymt_id;
  Close C_Sel1;
  --
  open c_num ;
  fetch c_num into p_rec.apprvd_fr_pymt_num ;
  close c_num ;
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
  (p_rec                   in ben_pry_shd.g_rec_type
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
    ben_pry_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_prtt_rmt_aprvd_fr_pymt_id
      => p_rec.prtt_rmt_aprvd_fr_pymt_id
      ,p_prtt_reimbmt_rqst_id
      => p_rec.prtt_reimbmt_rqst_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_apprvd_fr_pymt_num
      => p_rec.apprvd_fr_pymt_num
      ,p_adjmt_flag
      => p_rec.adjmt_flag
      ,p_aprvd_fr_pymt_amt
      => p_rec.aprvd_fr_pymt_amt
      ,p_pymt_stat_cd
      => p_rec.pymt_stat_cd
      ,p_pymt_stat_rsn_cd
      => p_rec.pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd
      => p_rec.pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd
      => p_rec.pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_element_entry_value_id => p_rec.element_entry_value_id
      ,p_pry_attribute_category
      => p_rec.pry_attribute_category
      ,p_pry_attribute1
      => p_rec.pry_attribute1
      ,p_pry_attribute2
      => p_rec.pry_attribute2
      ,p_pry_attribute3
      => p_rec.pry_attribute3
      ,p_pry_attribute4
      => p_rec.pry_attribute4
      ,p_pry_attribute5
      => p_rec.pry_attribute5
      ,p_pry_attribute6
      => p_rec.pry_attribute6
      ,p_pry_attribute7
      => p_rec.pry_attribute7
      ,p_pry_attribute8
      => p_rec.pry_attribute8
      ,p_pry_attribute9
      => p_rec.pry_attribute9
      ,p_pry_attribute10
      => p_rec.pry_attribute10
      ,p_pry_attribute11
      => p_rec.pry_attribute11
      ,p_pry_attribute12
      => p_rec.pry_attribute12
      ,p_pry_attribute13
      => p_rec.pry_attribute13
      ,p_pry_attribute14
      => p_rec.pry_attribute14
      ,p_pry_attribute15
      => p_rec.pry_attribute15
      ,p_pry_attribute16
      => p_rec.pry_attribute16
      ,p_pry_attribute17
      => p_rec.pry_attribute17
      ,p_pry_attribute18
      => p_rec.pry_attribute18
      ,p_pry_attribute19
      => p_rec.pry_attribute19
      ,p_pry_attribute20
      => p_rec.pry_attribute20
      ,p_pry_attribute21
      => p_rec.pry_attribute21
      ,p_pry_attribute22
      => p_rec.pry_attribute22
      ,p_pry_attribute23
      => p_rec.pry_attribute23
      ,p_pry_attribute24
      => p_rec.pry_attribute24
      ,p_pry_attribute25
      => p_rec.pry_attribute25
      ,p_pry_attribute26
      => p_rec.pry_attribute26
      ,p_pry_attribute27
      => p_rec.pry_attribute27
      ,p_pry_attribute28
      => p_rec.pry_attribute28
      ,p_pry_attribute29
      => p_rec.pry_attribute29
      ,p_pry_attribute30
      => p_rec.pry_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PRTT_RMT_APRVD_FR_PYMT_F'
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
  ,p_rec                   in ben_pry_shd.g_rec_type
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
    ,p_base_table_name         => 'ben_prtt_rmt_aprvd_fr_pymt_f'
    ,p_base_key_column         => 'prtt_rmt_aprvd_fr_pymt_id'
    ,p_base_key_value          => p_rec.prtt_rmt_aprvd_fr_pymt_id
    ,p_parent_table_name1      => 'ben_prtt_reimbmt_rqst_f'
    ,p_parent_key_column1      => 'prtt_reimbmt_rqst_id'
    ,p_parent_key_value1       => p_rec.prtt_reimbmt_rqst_id
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
  ,p_rec            in out nocopy ben_pry_shd.g_rec_type
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
  ben_pry_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  ben_pry_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting pre-insert operation
  --
  ben_pry_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  ben_pry_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  ben_pry_ins.post_insert
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
  ,p_prtt_reimbmt_rqst_id           in     number
  ,p_apprvd_fr_pymt_num             in     number   default null
  ,p_adjmt_flag                     in     varchar2 default null
  ,p_aprvd_fr_pymt_amt              in     number   default null
  ,p_pymt_stat_cd                   in     varchar2 default null
  ,p_pymt_stat_rsn_cd               in     varchar2 default null
  ,p_pymt_stat_ovrdn_rsn_cd         in     varchar2 default null
  ,p_pymt_stat_prr_to_ovrd_cd       in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_element_entry_value_id         in     number   default null
  ,p_pry_attribute_category         in     varchar2 default null
  ,p_pry_attribute1                 in     varchar2 default null
  ,p_pry_attribute2                 in     varchar2 default null
  ,p_pry_attribute3                 in     varchar2 default null
  ,p_pry_attribute4                 in     varchar2 default null
  ,p_pry_attribute5                 in     varchar2 default null
  ,p_pry_attribute6                 in     varchar2 default null
  ,p_pry_attribute7                 in     varchar2 default null
  ,p_pry_attribute8                 in     varchar2 default null
  ,p_pry_attribute9                 in     varchar2 default null
  ,p_pry_attribute10                in     varchar2 default null
  ,p_pry_attribute11                in     varchar2 default null
  ,p_pry_attribute12                in     varchar2 default null
  ,p_pry_attribute13                in     varchar2 default null
  ,p_pry_attribute14                in     varchar2 default null
  ,p_pry_attribute15                in     varchar2 default null
  ,p_pry_attribute16                in     varchar2 default null
  ,p_pry_attribute17                in     varchar2 default null
  ,p_pry_attribute18                in     varchar2 default null
  ,p_pry_attribute19                in     varchar2 default null
  ,p_pry_attribute20                in     varchar2 default null
  ,p_pry_attribute21                in     varchar2 default null
  ,p_pry_attribute22                in     varchar2 default null
  ,p_pry_attribute23                in     varchar2 default null
  ,p_pry_attribute24                in     varchar2 default null
  ,p_pry_attribute25                in     varchar2 default null
  ,p_pry_attribute26                in     varchar2 default null
  ,p_pry_attribute27                in     varchar2 default null
  ,p_pry_attribute28                in     varchar2 default null
  ,p_pry_attribute29                in     varchar2 default null
  ,p_pry_attribute30                in     varchar2 default null
  ,p_prtt_rmt_aprvd_fr_pymt_id         out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         ben_pry_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pry_shd.convert_args
    (null
    ,p_prtt_reimbmt_rqst_id
    ,null
    ,null
    ,p_apprvd_fr_pymt_num
    ,p_adjmt_flag
    ,p_aprvd_fr_pymt_amt
    ,p_pymt_stat_cd
    ,p_pymt_stat_rsn_cd
    ,p_pymt_stat_ovrdn_rsn_cd
    ,p_pymt_stat_prr_to_ovrd_cd
    ,p_business_group_id
    ,p_element_entry_value_id
    ,p_pry_attribute_category
    ,p_pry_attribute1
    ,p_pry_attribute2
    ,p_pry_attribute3
    ,p_pry_attribute4
    ,p_pry_attribute5
    ,p_pry_attribute6
    ,p_pry_attribute7
    ,p_pry_attribute8
    ,p_pry_attribute9
    ,p_pry_attribute10
    ,p_pry_attribute11
    ,p_pry_attribute12
    ,p_pry_attribute13
    ,p_pry_attribute14
    ,p_pry_attribute15
    ,p_pry_attribute16
    ,p_pry_attribute17
    ,p_pry_attribute18
    ,p_pry_attribute19
    ,p_pry_attribute20
    ,p_pry_attribute21
    ,p_pry_attribute22
    ,p_pry_attribute23
    ,p_pry_attribute24
    ,p_pry_attribute25
    ,p_pry_attribute26
    ,p_pry_attribute27
    ,p_pry_attribute28
    ,p_pry_attribute29
    ,p_pry_attribute30
    ,null
    );
  --
  -- Having converted the arguments into the ben_pry_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_pry_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_prtt_rmt_aprvd_fr_pymt_id        := l_rec.prtt_rmt_aprvd_fr_pymt_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pry_ins;

/
