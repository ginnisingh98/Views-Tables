--------------------------------------------------------
--  DDL for Package Body BEN_PRC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRC_INS" as
/* $Header: beprcrhi.pkb 120.7.12010000.2 2008/08/05 15:19:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prc_ins.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
    from   ben_prtt_reimbmt_rqst_f t
    where  t.prtt_reimbmt_rqst_id       = p_rec.prtt_reimbmt_rqst_id
    and    t.effective_start_date =
             ben_prc_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_prtt_reimbmt_rqst_f.created_by%TYPE;
  l_creation_date       ben_prtt_reimbmt_rqst_f.creation_date%TYPE;
  l_last_update_date   	ben_prtt_reimbmt_rqst_f.last_update_date%TYPE;
  l_last_updated_by     ben_prtt_reimbmt_rqst_f.last_updated_by%TYPE;
  l_last_update_login   ben_prtt_reimbmt_rqst_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column => 'prtt_reimbmt_rqst_id',
	 p_base_key_value  => p_rec.prtt_reimbmt_rqst_id);
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
  ben_prc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_prtt_reimbmt_rqst_f
  --
  insert into ben_prtt_reimbmt_rqst_f
  (	prtt_reimbmt_rqst_id,
	effective_start_date,
	effective_end_date,
	incrd_from_dt,
	incrd_to_dt,
	rqst_num,
	rqst_amt,
	rqst_amt_uom,
	rqst_btch_num,
	prtt_reimbmt_rqst_stat_cd,
	reimbmt_ctfn_typ_prvdd_cd,
	rcrrg_cd,
	submitter_person_id,
	recipient_person_id,
	provider_person_id,
	provider_ssn_person_id,
	pl_id,
	gd_or_svc_typ_id,
	contact_relationship_id,
	business_group_id,
        opt_id,
        popl_yr_perd_id_1 ,
        popl_yr_perd_id_2 ,
        amt_year1         ,
        amt_year2      ,
	prc_attribute_category,
	prc_attribute1,
	prc_attribute2,
	prc_attribute3,
	prc_attribute4,
	prc_attribute5,
	prc_attribute6,
	prc_attribute7,
	prc_attribute8,
	prc_attribute9,
	prc_attribute10,
	prc_attribute11,
	prc_attribute12,
	prc_attribute13,
	prc_attribute14,
	prc_attribute15,
	prc_attribute16,
	prc_attribute17,
	prc_attribute18,
	prc_attribute19,
	prc_attribute20,
	prc_attribute21,
	prc_attribute22,
	prc_attribute23,
	prc_attribute24,
	prc_attribute25,
	prc_attribute26,
	prc_attribute27,
	prc_attribute28,
	prc_attribute29,
	prc_attribute30,
	object_version_number ,
        prtt_enrt_rslt_id,
        comment_id ,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login ,
        stat_rsn_cd,
        pymt_stat_cd,
        pymt_stat_rsn_cd,
        stat_ovrdn_flag,
        stat_ovrdn_rsn_cd,
        stat_prr_to_ovrd,
        pymt_stat_ovrdn_flag,
        pymt_stat_ovrdn_rsn_cd,
        pymt_stat_prr_to_ovrd,
        adjmt_flag,
        submtd_dt,
        ttl_rqst_amt,
        aprvd_for_pymt_amt,
        exp_incurd_dt
  )
  Values
  (	p_rec.prtt_reimbmt_rqst_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.incrd_from_dt,
	p_rec.incrd_to_dt,
	p_rec.rqst_num,
	p_rec.rqst_amt,
	p_rec.rqst_amt_uom,
	p_rec.rqst_btch_num,
	p_rec.prtt_reimbmt_rqst_stat_cd,
	p_rec.reimbmt_ctfn_typ_prvdd_cd,
	p_rec.rcrrg_cd,
	p_rec.submitter_person_id,
	p_rec.recipient_person_id,
	p_rec.provider_person_id,
	p_rec.provider_ssn_person_id,
	p_rec.pl_id,
	p_rec.gd_or_svc_typ_id,
	p_rec.contact_relationship_id,
	p_rec.business_group_id,
        p_rec.opt_id,
        p_rec.popl_yr_perd_id_1 ,
        p_rec.popl_yr_perd_id_2 ,
        p_rec.amt_year1         ,
        p_rec.amt_year2      ,
	p_rec.prc_attribute_category,
	p_rec.prc_attribute1,
	p_rec.prc_attribute2,
	p_rec.prc_attribute3,
	p_rec.prc_attribute4,
	p_rec.prc_attribute5,
	p_rec.prc_attribute6,
	p_rec.prc_attribute7,
	p_rec.prc_attribute8,
	p_rec.prc_attribute9,
	p_rec.prc_attribute10,
	p_rec.prc_attribute11,
	p_rec.prc_attribute12,
	p_rec.prc_attribute13,
	p_rec.prc_attribute14,
	p_rec.prc_attribute15,
	p_rec.prc_attribute16,
	p_rec.prc_attribute17,
	p_rec.prc_attribute18,
	p_rec.prc_attribute19,
	p_rec.prc_attribute20,
	p_rec.prc_attribute21,
	p_rec.prc_attribute22,
	p_rec.prc_attribute23,
	p_rec.prc_attribute24,
	p_rec.prc_attribute25,
	p_rec.prc_attribute26,
	p_rec.prc_attribute27,
	p_rec.prc_attribute28,
	p_rec.prc_attribute29,
	p_rec.prc_attribute30,
	p_rec.object_version_number ,
        p_rec.prtt_enrt_rslt_id ,
        p_rec.comment_id  ,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login  ,
        p_rec.stat_rsn_cd,
        p_rec.pymt_stat_cd,
        p_rec.pymt_stat_rsn_cd,
        p_rec.stat_ovrdn_flag,
        p_rec.stat_ovrdn_rsn_cd,
        p_rec.stat_prr_to_ovrd,
        p_rec.pymt_stat_ovrdn_flag,
        p_rec.pymt_stat_ovrdn_rsn_cd,
        p_rec.pymt_stat_prr_to_ovrd,
        p_rec.adjmt_flag,
        p_rec.submtd_dt,
        p_rec.ttl_rqst_amt,
        p_rec.aprvd_for_pymt_amt,
        p_rec.exp_incurd_dt
  );
  --
  ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_prc_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
--   This procedure will also use a sequence generator to automatically
--   populate a value for the RQST_AMT field.
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
	(p_rec  			in out nocopy ben_prc_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
cursor c1 is
      select ben_prc_rqst_num_s.nextval
      from sys.dual;
--
cursor c2 is
       select ben_prc_rqst_num_s.nextval
       from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      open c1;
      fetch c1 into p_rec.prtt_reimbmt_rqst_id;
      close c1;
      --
      open c2;
      fetch c2 into p_rec.rqst_num;
      close c2;
  --
  --
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
	(p_rec 			 in ben_prc_shd.g_rec_type,
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
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_prc_rki.after_insert
      (
  p_prtt_reimbmt_rqst_id          =>p_rec.prtt_reimbmt_rqst_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_incrd_from_dt                 =>p_rec.incrd_from_dt
 ,p_incrd_to_dt                   =>p_rec.incrd_to_dt
 ,p_rqst_num                      =>p_rec.rqst_num
 ,p_rqst_amt                      =>p_rec.rqst_amt
 ,p_rqst_amt_uom                  =>p_rec.rqst_amt_uom
 ,p_rqst_btch_num                 =>p_rec.rqst_btch_num
 ,p_prtt_reimbmt_rqst_stat_cd     =>p_rec.prtt_reimbmt_rqst_stat_cd
 ,p_reimbmt_ctfn_typ_prvdd_cd     =>p_rec.reimbmt_ctfn_typ_prvdd_cd
 ,p_rcrrg_cd                      =>p_rec.rcrrg_cd
 ,p_submitter_person_id           =>p_rec.submitter_person_id
 ,p_recipient_person_id           =>p_rec.recipient_person_id
 ,p_provider_person_id            =>p_rec.provider_person_id
 ,p_provider_ssn_person_id        =>p_rec.provider_ssn_person_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_gd_or_svc_typ_id              =>p_rec.gd_or_svc_typ_id
 ,p_contact_relationship_id       =>p_rec.contact_relationship_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_opt_id                        =>p_rec.opt_id
 ,p_popl_yr_perd_id_1             =>p_rec.popl_yr_perd_id_1
 ,p_popl_yr_perd_id_2             =>p_rec.popl_yr_perd_id_2
 ,p_amt_year1                     =>p_rec.amt_year1
 ,p_amt_year2                     =>p_rec.amt_year2
 ,p_prc_attribute_category        =>p_rec.prc_attribute_category
 ,p_prc_attribute1                =>p_rec.prc_attribute1
 ,p_prc_attribute2                =>p_rec.prc_attribute2
 ,p_prc_attribute3                =>p_rec.prc_attribute3
 ,p_prc_attribute4                =>p_rec.prc_attribute4
 ,p_prc_attribute5                =>p_rec.prc_attribute5
 ,p_prc_attribute6                =>p_rec.prc_attribute6
 ,p_prc_attribute7                =>p_rec.prc_attribute7
 ,p_prc_attribute8                =>p_rec.prc_attribute8
 ,p_prc_attribute9                =>p_rec.prc_attribute9
 ,p_prc_attribute10               =>p_rec.prc_attribute10
 ,p_prc_attribute11               =>p_rec.prc_attribute11
 ,p_prc_attribute12               =>p_rec.prc_attribute12
 ,p_prc_attribute13               =>p_rec.prc_attribute13
 ,p_prc_attribute14               =>p_rec.prc_attribute14
 ,p_prc_attribute15               =>p_rec.prc_attribute15
 ,p_prc_attribute16               =>p_rec.prc_attribute16
 ,p_prc_attribute17               =>p_rec.prc_attribute17
 ,p_prc_attribute18               =>p_rec.prc_attribute18
 ,p_prc_attribute19               =>p_rec.prc_attribute19
 ,p_prc_attribute20               =>p_rec.prc_attribute20
 ,p_prc_attribute21               =>p_rec.prc_attribute21
 ,p_prc_attribute22               =>p_rec.prc_attribute22
 ,p_prc_attribute23               =>p_rec.prc_attribute23
 ,p_prc_attribute24               =>p_rec.prc_attribute24
 ,p_prc_attribute25               =>p_rec.prc_attribute25
 ,p_prc_attribute26               =>p_rec.prc_attribute26
 ,p_prc_attribute27               =>p_rec.prc_attribute27
 ,p_prc_attribute28               =>p_rec.prc_attribute28
 ,p_prc_attribute29               =>p_rec.prc_attribute29
 ,p_prc_attribute30               =>p_rec.prc_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
 ,p_comment_id                    =>p_rec.comment_id
 ,p_stat_rsn_cd                   => p_rec.stat_rsn_cd
 ,p_pymt_stat_cd                  => p_rec.pymt_stat_cd
 ,p_pymt_stat_rsn_cd              => p_rec.pymt_stat_rsn_cd
 ,p_stat_ovrdn_flag               => p_rec.stat_ovrdn_flag
 ,p_stat_ovrdn_rsn_cd             => p_rec.stat_ovrdn_rsn_cd
 ,p_stat_prr_to_ovrd              => p_rec.stat_prr_to_ovrd
 ,p_pymt_stat_ovrdn_flag          => p_rec.pymt_stat_ovrdn_flag
 ,p_pymt_stat_ovrdn_rsn_cd        => p_rec.pymt_stat_ovrdn_rsn_cd
 ,p_pymt_stat_prr_to_ovrd         => p_rec.pymt_stat_prr_to_ovrd
 ,p_adjmt_flag                    => p_rec.adjmt_flag
 ,p_submtd_dt                     => p_rec.submtd_dt
 ,p_ttl_rqst_amt                  => p_rec.ttl_rqst_amt
 ,p_aprvd_for_pymt_amt            => p_rec.aprvd_for_pymt_amt
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_exp_incurd_dt		  =>p_rec.exp_incurd_dt
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_reimbmt_rqst_f'
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
	 p_rec	 		 in  ben_prc_shd.g_rec_type,
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
	 p_base_table_name	   => 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column	   => 'prtt_reimbmt_rqst_id',
	 p_base_key_value 	   => p_rec.prtt_reimbmt_rqst_id,
	 p_parent_table_name1      => 'ben_pl_f',
	 p_parent_key_column1      => 'pl_id',
	 p_parent_key_value1       => p_rec.pl_id,
         p_enforce_foreign_locking => true,
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
  p_rec		   in out nocopy ben_prc_shd.g_rec_type,
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
  ben_prc_bus.insert_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);

 hr_utility.set_location('after date  check ' || p_rec.prtt_reimbmt_rqst_stat_cd, 110);
 hr_utility.set_location('after date  check ' || p_rec.stat_rsn_cd, 110);
 hr_utility.set_location('after date  check ' || p_rec.Pymt_stat_cd, 110);
 hr_utility.set_location('after date  check ' || p_rec.pymt_stat_rsn_cd, 110);

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
  p_prtt_reimbmt_rqst_id         out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_incrd_from_dt                in date             ,
  p_incrd_to_dt                  in date             ,
  p_rqst_num                     in out nocopy number       ,
  p_rqst_amt                     in number           ,
  p_rqst_amt_uom                 in varchar2         ,
  p_rqst_btch_num                in number           ,
  p_prtt_reimbmt_rqst_stat_cd    in out nocopy varchar2     ,
  p_reimbmt_ctfn_typ_prvdd_cd    in varchar2         ,
  p_rcrrg_cd                     in varchar2         ,
  p_submitter_person_id          in number           ,
  p_recipient_person_id          in number           ,
  p_provider_person_id           in number           ,
  p_provider_ssn_person_id       in number           ,
  p_pl_id                        in number,
  p_gd_or_svc_typ_id             in number           ,
  p_contact_relationship_id      in number           ,
  p_business_group_id            in number
 ,p_opt_id                         in  number
 ,p_popl_yr_perd_id_1              in  number
 ,p_popl_yr_perd_id_2              in  number
 ,p_amt_year1                      in  number
 ,p_amt_year2                      in  number,
  p_prc_attribute_category       in varchar2         ,
  p_prc_attribute1               in varchar2         ,
  p_prc_attribute2               in varchar2         ,
  p_prc_attribute3               in varchar2         ,
  p_prc_attribute4               in varchar2         ,
  p_prc_attribute5               in varchar2         ,
  p_prc_attribute6               in varchar2         ,
  p_prc_attribute7               in varchar2         ,
  p_prc_attribute8               in varchar2         ,
  p_prc_attribute9               in varchar2         ,
  p_prc_attribute10              in varchar2         ,
  p_prc_attribute11              in varchar2         ,
  p_prc_attribute12              in varchar2         ,
  p_prc_attribute13              in varchar2         ,
  p_prc_attribute14              in varchar2         ,
  p_prc_attribute15              in varchar2         ,
  p_prc_attribute16              in varchar2         ,
  p_prc_attribute17              in varchar2         ,
  p_prc_attribute18              in varchar2         ,
  p_prc_attribute19              in varchar2         ,
  p_prc_attribute20              in varchar2         ,
  p_prc_attribute21              in varchar2         ,
  p_prc_attribute22              in varchar2         ,
  p_prc_attribute23              in varchar2         ,
  p_prc_attribute24              in varchar2         ,
  p_prc_attribute25              in varchar2         ,
  p_prc_attribute26              in varchar2         ,
  p_prc_attribute27              in varchar2         ,
  p_prc_attribute28              in varchar2         ,
  p_prc_attribute29              in varchar2         ,
  p_prc_attribute30              in varchar2         ,
  p_prtt_enrt_rslt_id            in number           ,
  p_comment_id                   in number           ,
  p_object_version_number        out nocopy number,
  -- Fide enh
  p_stat_rsn_cd                  in out nocopy varchar2 ,
  p_pymt_stat_cd                 in out nocopy varchar2 ,
  p_pymt_stat_rsn_cd             in out nocopy varchar2 ,
  p_stat_ovrdn_flag              in varchar2  ,
  p_stat_ovrdn_rsn_cd            in varchar2  ,
  p_stat_prr_to_ovrd             in varchar2  ,
  p_pymt_stat_ovrdn_flag         in varchar2  ,
  p_pymt_stat_ovrdn_rsn_cd       in varchar2  ,
  p_pymt_stat_prr_to_ovrd        in varchar2  ,
  p_adjmt_flag                   in varchar2  ,
  p_submtd_dt                    in date  ,
  p_ttl_rqst_amt                 in  number    ,
  p_aprvd_for_pymt_amt           in  out nocopy number,
  p_pymt_amount                  out nocopy number ,
  p_exp_incurd_dt		 in date      ,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_prc_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_prc_shd.convert_args
  (
  null,
  null,
  null,
  p_incrd_from_dt,
  p_incrd_to_dt,
  p_rqst_num,
  p_rqst_amt,
  p_rqst_amt_uom,
  p_rqst_btch_num,
  p_prtt_reimbmt_rqst_stat_cd,
  p_reimbmt_ctfn_typ_prvdd_cd,
  p_rcrrg_cd,
  p_submitter_person_id,
  p_recipient_person_id,
  p_provider_person_id,
  p_provider_ssn_person_id,
  p_pl_id,
  p_gd_or_svc_typ_id,
  p_contact_relationship_id,
  p_business_group_id,
  p_opt_id,
  p_popl_yr_perd_id_1,
  p_popl_yr_perd_id_2,
  p_amt_year1,
  p_amt_year2 ,
  p_prc_attribute_category,
  p_prc_attribute1,
  p_prc_attribute2,
  p_prc_attribute3,
  p_prc_attribute4,
  p_prc_attribute5,
  p_prc_attribute6,
  p_prc_attribute7,
  p_prc_attribute8,
  p_prc_attribute9,
  p_prc_attribute10,
  p_prc_attribute11,
  p_prc_attribute12,
  p_prc_attribute13,
  p_prc_attribute14,
  p_prc_attribute15,
  p_prc_attribute16,
  p_prc_attribute17,
  p_prc_attribute18,
  p_prc_attribute19,
  p_prc_attribute20,
  p_prc_attribute21,
  p_prc_attribute22,
  p_prc_attribute23,
  p_prc_attribute24,
  p_prc_attribute25,
  p_prc_attribute26,
  p_prc_attribute27,
  p_prc_attribute28,
  p_prc_attribute29,
  p_prc_attribute30,
  p_prtt_enrt_rslt_id ,
  p_comment_id        ,
  null ,
  p_stat_rsn_cd,
  p_pymt_stat_cd,
  p_pymt_stat_rsn_cd,
  p_stat_ovrdn_flag,
  p_stat_ovrdn_rsn_cd,
  p_stat_prr_to_ovrd,
  p_pymt_stat_ovrdn_flag,
  p_pymt_stat_ovrdn_rsn_cd,
  p_pymt_stat_prr_to_ovrd,
  p_adjmt_flag,
  p_submtd_dt,
  p_ttl_rqst_amt,
  p_aprvd_for_pymt_amt,
  null ,
  p_exp_incurd_dt
  );
  --
  -- Having converted the arguments into the ben_prc_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_prtt_reimbmt_rqst_id      	:= l_rec.prtt_reimbmt_rqst_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  p_rqst_num                    := l_rec.rqst_num ;
  p_prtt_reimbmt_rqst_Stat_cd   := l_rec.prtt_reimbmt_rqst_Stat_cd;
  p_stat_rsn_cd                 := l_rec.stat_rsn_cd ;
  p_pymt_stat_rsn_cd            := l_rec.pymt_stat_rsn_cd;
  p_pymt_stat_cd                := l_rec.pymt_stat_cd ;
  p_pymt_amount                 := l_rec.pymt_amount ;
  p_aprvd_for_pymt_amt          := l_rec.aprvd_for_pymt_amt ;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_prc_ins;

/
