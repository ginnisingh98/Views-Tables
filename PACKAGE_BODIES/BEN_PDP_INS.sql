--------------------------------------------------------
--  DDL for Package Body BEN_PDP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDP_INS" as
/* $Header: bepdprhi.pkb 120.10.12010000.4 2008/08/05 15:08:01 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pdp_ins.';  -- Global package name
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
	(p_rec 			 in out nocopy ben_pdp_shd.g_rec_type,
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
    from   ben_elig_cvrd_dpnt_f t
    where  t.elig_cvrd_dpnt_id       = p_rec.elig_cvrd_dpnt_id
    and    t.effective_start_date =
             ben_pdp_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_elig_cvrd_dpnt_f.created_by%TYPE;
  l_creation_date       ben_elig_cvrd_dpnt_f.creation_date%TYPE;
  l_last_update_date   	ben_elig_cvrd_dpnt_f.last_update_date%TYPE;
  l_last_updated_by     ben_elig_cvrd_dpnt_f.last_updated_by%TYPE;
  l_last_update_login   ben_elig_cvrd_dpnt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_elig_cvrd_dpnt_f',
	 p_base_key_column => 'elig_cvrd_dpnt_id',
	 p_base_key_value  => p_rec.elig_cvrd_dpnt_id);
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
  ben_pdp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_elig_cvrd_dpnt_f
  --
  insert into ben_elig_cvrd_dpnt_f
  (	elig_cvrd_dpnt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	prtt_enrt_rslt_id,
	dpnt_person_id,
	cvg_strt_dt,
	cvg_thru_dt,
      cvg_pndg_flag,
	pdp_attribute_category,
	pdp_attribute1,
	pdp_attribute2,
	pdp_attribute3,
	pdp_attribute4,
	pdp_attribute5,
	pdp_attribute6,
	pdp_attribute7,
	pdp_attribute8,
	pdp_attribute9,
	pdp_attribute10,
	pdp_attribute11,
	pdp_attribute12,
	pdp_attribute13,
	pdp_attribute14,
	pdp_attribute15,
	pdp_attribute16,
	pdp_attribute17,
	pdp_attribute18,
	pdp_attribute19,
	pdp_attribute20,
	pdp_attribute21,
	pdp_attribute22,
	pdp_attribute23,
	pdp_attribute24,
	pdp_attribute25,
	pdp_attribute26,
	pdp_attribute27,
	pdp_attribute28,
	pdp_attribute29,
	pdp_attribute30,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
	object_version_number,
        ovrdn_flag,
        per_in_ler_id,
        ovrdn_thru_dt,
      created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.elig_cvrd_dpnt_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.business_group_id,
	p_rec.prtt_enrt_rslt_id,
	p_rec.dpnt_person_id,
	p_rec.cvg_strt_dt,
	p_rec.cvg_thru_dt,
      p_rec.cvg_pndg_flag,
	p_rec.pdp_attribute_category,
	p_rec.pdp_attribute1,
	p_rec.pdp_attribute2,
	p_rec.pdp_attribute3,
	p_rec.pdp_attribute4,
	p_rec.pdp_attribute5,
	p_rec.pdp_attribute6,
	p_rec.pdp_attribute7,
	p_rec.pdp_attribute8,
	p_rec.pdp_attribute9,
	p_rec.pdp_attribute10,
	p_rec.pdp_attribute11,
	p_rec.pdp_attribute12,
	p_rec.pdp_attribute13,
	p_rec.pdp_attribute14,
	p_rec.pdp_attribute15,
	p_rec.pdp_attribute16,
	p_rec.pdp_attribute17,
	p_rec.pdp_attribute18,
	p_rec.pdp_attribute19,
	p_rec.pdp_attribute20,
	p_rec.pdp_attribute21,
	p_rec.pdp_attribute22,
	p_rec.pdp_attribute23,
	p_rec.pdp_attribute24,
	p_rec.pdp_attribute25,
	p_rec.pdp_attribute26,
	p_rec.pdp_attribute27,
	p_rec.pdp_attribute28,
	p_rec.pdp_attribute29,
	p_rec.pdp_attribute30,
      p_rec.request_id,
      p_rec.program_application_id,
      p_rec.program_id,
      p_rec.program_update_date,
	p_rec.object_version_number,
        p_rec.ovrdn_flag,
        p_rec.per_in_ler_id,
        p_rec.ovrdn_thru_dt
	, l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_pdp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pdp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pdp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pdp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pdp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pdp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_pdp_shd.g_rec_type,
	 p_effective_date	       in	date,
	 p_datetrack_mode	       in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
		p_effective_date	      => p_effective_date,
		p_datetrack_mode	      => p_datetrack_mode,
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
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
	(p_rec  			      in out nocopy ben_pdp_shd.g_rec_type,
	 p_effective_date		      in date,
	 p_datetrack_mode		      in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
--
  cursor c1 is
    select ben_elig_cvrd_dpnt_f_s.nextval
    from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into p_rec.elig_cvrd_dpnt_id;
  close c1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
	(p_rec 			 in ben_pdp_shd.g_rec_type,
	 p_effective_date	       in date,
	 p_datetrack_mode	       in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
 --Bug 4390330 fix
 --
 ben_dt_trgr_handle.elig_cvrd_dpnt
    (p_rowid                 => null
    ,p_ELIG_CVRD_DPNT_ID     => p_rec.ELIG_CVRD_DPNT_ID
    ,p_dpnt_person_id        => p_rec.dpnt_person_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id
    ,p_effective_start_date  => p_rec.effective_start_date
    ,p_effective_end_date    => p_rec.effective_end_date
    ,p_cvg_strt_dt           => p_rec.cvg_strt_dt
    ,p_cvg_thru_dt           => p_rec.cvg_thru_dt
    ,p_ovrdn_flag            => p_rec.ovrdn_flag
    ,p_ovrdn_thru_dt         => p_rec.ovrdn_thru_dt
    );

  --
  -- Bug : 3756863 : Moved here from INSERT_VALIDATE
  ben_pdp_bus.crt_ordr_warning
     (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
      p_effective_date        => p_effective_date,
      p_business_group_id     => p_rec.business_group_id);
  --
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_pdp_rki.after_insert
      (
  p_elig_cvrd_dpnt_id             =>p_rec.elig_cvrd_dpnt_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
 ,p_dpnt_person_id                =>p_rec.dpnt_person_id
 ,p_cvg_strt_dt                   =>p_rec.cvg_strt_dt
 ,p_cvg_thru_dt                   =>p_rec.cvg_thru_dt
 ,p_cvg_pndg_flag                 =>p_rec.cvg_pndg_flag
 ,p_pdp_attribute_category        =>p_rec.pdp_attribute_category
 ,p_pdp_attribute1                =>p_rec.pdp_attribute1
 ,p_pdp_attribute2                =>p_rec.pdp_attribute2
 ,p_pdp_attribute3                =>p_rec.pdp_attribute3
 ,p_pdp_attribute4                =>p_rec.pdp_attribute4
 ,p_pdp_attribute5                =>p_rec.pdp_attribute5
 ,p_pdp_attribute6                =>p_rec.pdp_attribute6
 ,p_pdp_attribute7                =>p_rec.pdp_attribute7
 ,p_pdp_attribute8                =>p_rec.pdp_attribute8
 ,p_pdp_attribute9                =>p_rec.pdp_attribute9
 ,p_pdp_attribute10               =>p_rec.pdp_attribute10
 ,p_pdp_attribute11               =>p_rec.pdp_attribute11
 ,p_pdp_attribute12               =>p_rec.pdp_attribute12
 ,p_pdp_attribute13               =>p_rec.pdp_attribute13
 ,p_pdp_attribute14               =>p_rec.pdp_attribute14
 ,p_pdp_attribute15               =>p_rec.pdp_attribute15
 ,p_pdp_attribute16               =>p_rec.pdp_attribute16
 ,p_pdp_attribute17               =>p_rec.pdp_attribute17
 ,p_pdp_attribute18               =>p_rec.pdp_attribute18
 ,p_pdp_attribute19               =>p_rec.pdp_attribute19
 ,p_pdp_attribute20               =>p_rec.pdp_attribute20
 ,p_pdp_attribute21               =>p_rec.pdp_attribute21
 ,p_pdp_attribute22               =>p_rec.pdp_attribute22
 ,p_pdp_attribute23               =>p_rec.pdp_attribute23
 ,p_pdp_attribute24               =>p_rec.pdp_attribute24
 ,p_pdp_attribute25               =>p_rec.pdp_attribute25
 ,p_pdp_attribute26               =>p_rec.pdp_attribute26
 ,p_pdp_attribute27               =>p_rec.pdp_attribute27
 ,p_pdp_attribute28               =>p_rec.pdp_attribute28
 ,p_pdp_attribute29               =>p_rec.pdp_attribute29
 ,p_pdp_attribute30               =>p_rec.pdp_attribute30
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_ovrdn_flag                    =>p_rec.ovrdn_flag
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_ovrdn_thru_dt                 =>p_rec.ovrdn_thru_dt
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_elig_cvrd_dpnt_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
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
--   be manipulated.
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
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  ben_pdp_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
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
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_elig_cvrd_dpnt_f',
	 p_base_key_column	   => 'elig_cvrd_dpnt_id',
	 p_base_key_value 	   => p_rec.elig_cvrd_dpnt_id,
       p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
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
  (
  p_rec		   in out nocopy ben_pdp_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
  -- Call the supporting insert validate operations
  --
  ben_pdp_bus.insert_validate
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
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_elig_cvrd_dpnt_id            out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_prtt_enrt_rslt_id            in number           default null,
  p_dpnt_person_id               in number,
  p_cvg_strt_dt                  in date             default null,
  p_cvg_thru_dt                  in date             default null,
  p_cvg_pndg_flag                in varchar2,
  p_pdp_attribute_category       in varchar2         default null,
  p_pdp_attribute1               in varchar2         default null,
  p_pdp_attribute2               in varchar2         default null,
  p_pdp_attribute3               in varchar2         default null,
  p_pdp_attribute4               in varchar2         default null,
  p_pdp_attribute5               in varchar2         default null,
  p_pdp_attribute6               in varchar2         default null,
  p_pdp_attribute7               in varchar2         default null,
  p_pdp_attribute8               in varchar2         default null,
  p_pdp_attribute9               in varchar2         default null,
  p_pdp_attribute10              in varchar2         default null,
  p_pdp_attribute11              in varchar2         default null,
  p_pdp_attribute12              in varchar2         default null,
  p_pdp_attribute13              in varchar2         default null,
  p_pdp_attribute14              in varchar2         default null,
  p_pdp_attribute15              in varchar2         default null,
  p_pdp_attribute16              in varchar2         default null,
  p_pdp_attribute17              in varchar2         default null,
  p_pdp_attribute18              in varchar2         default null,
  p_pdp_attribute19              in varchar2         default null,
  p_pdp_attribute20              in varchar2         default null,
  p_pdp_attribute21              in varchar2         default null,
  p_pdp_attribute22              in varchar2         default null,
  p_pdp_attribute23              in varchar2         default null,
  p_pdp_attribute24              in varchar2         default null,
  p_pdp_attribute25              in varchar2         default null,
  p_pdp_attribute26              in varchar2         default null,
  p_pdp_attribute27              in varchar2         default null,
  p_pdp_attribute28              in varchar2         default null,
  p_pdp_attribute29              in varchar2         default null,
  p_pdp_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_ovrdn_flag                   in varchar2,
  p_per_in_ler_id                in number           default null,
  p_ovrdn_thru_dt                in date             default null,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_pdp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pdp_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_prtt_enrt_rslt_id,
  p_dpnt_person_id,
  p_cvg_strt_dt,
  p_cvg_thru_dt,
  p_cvg_pndg_flag,
  p_pdp_attribute_category,
  p_pdp_attribute1,
  p_pdp_attribute2,
  p_pdp_attribute3,
  p_pdp_attribute4,
  p_pdp_attribute5,
  p_pdp_attribute6,
  p_pdp_attribute7,
  p_pdp_attribute8,
  p_pdp_attribute9,
  p_pdp_attribute10,
  p_pdp_attribute11,
  p_pdp_attribute12,
  p_pdp_attribute13,
  p_pdp_attribute14,
  p_pdp_attribute15,
  p_pdp_attribute16,
  p_pdp_attribute17,
  p_pdp_attribute18,
  p_pdp_attribute19,
  p_pdp_attribute20,
  p_pdp_attribute21,
  p_pdp_attribute22,
  p_pdp_attribute23,
  p_pdp_attribute24,
  p_pdp_attribute25,
  p_pdp_attribute26,
  p_pdp_attribute27,
  p_pdp_attribute28,
  p_pdp_attribute29,
  p_pdp_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null,
  p_ovrdn_flag,
  p_per_in_ler_id,
  p_ovrdn_thru_dt
  );
  --
  -- Having converted the arguments into the ben_pdp_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_elig_cvrd_dpnt_id        	:= l_rec.elig_cvrd_dpnt_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pdp_ins;

/
