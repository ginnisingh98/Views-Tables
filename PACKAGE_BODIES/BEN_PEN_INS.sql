--------------------------------------------------------
--  DDL for Package Body BEN_PEN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEN_INS" as
/* $Header: bepenrhi.pkb 120.21.12010000.2 2008/08/05 15:11:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pen_ins.';  -- Global package name
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
    (p_rec 			 in out nocopy ben_pen_shd.g_rec_type,
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
    from   ben_prtt_enrt_rslt_f t
    where  t.prtt_enrt_rslt_id       = p_rec.prtt_enrt_rslt_id
    and    t.effective_start_date =
             ben_pen_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_prtt_enrt_rslt_f.created_by%TYPE;
  l_creation_date       ben_prtt_enrt_rslt_f.creation_date%TYPE;
  l_last_update_date   	ben_prtt_enrt_rslt_f.last_update_date%TYPE;
  l_last_updated_by     ben_prtt_enrt_rslt_f.last_updated_by%TYPE;
  l_last_update_login   ben_prtt_enrt_rslt_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
    (p_base_table_name => 'ben_prtt_enrt_rslt_f',
     p_base_key_column => 'prtt_enrt_rslt_id',
     p_base_key_value  => p_rec.prtt_enrt_rslt_id);
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
  ben_pen_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_prtt_enrt_rslt_f
  --
  insert into ben_prtt_enrt_rslt_f
  (	prtt_enrt_rslt_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    oipl_id,
    person_id,
    assignment_id,
    pgm_id,
    pl_id,
    rplcs_sspndd_rslt_id,
    ptip_id,
    pl_typ_id,
    ler_id,
    sspndd_flag,
    prtt_is_cvrd_flag,
    bnft_amt,
    uom     ,
    orgnl_enrt_dt,
    enrt_mthd_cd,
        no_lngr_elig_flag,
    enrt_ovridn_flag,
    enrt_ovrid_rsn_cd,
    erlst_deenrt_dt,
    enrt_cvg_strt_dt,
    enrt_cvg_thru_dt,
    enrt_ovrid_thru_dt,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
    pen_attribute_category,
    pen_attribute1,
    pen_attribute2,
    pen_attribute3,
    pen_attribute4,
    pen_attribute5,
    pen_attribute6,
    pen_attribute7,
    pen_attribute8,
    pen_attribute9,
    pen_attribute10,
    pen_attribute11,
    pen_attribute12,
    pen_attribute13,
    pen_attribute14,
    pen_attribute15,
    pen_attribute16,
    pen_attribute17,
    pen_attribute18,
    pen_attribute19,
    pen_attribute20,
    pen_attribute21,
    pen_attribute22,
    pen_attribute23,
    pen_attribute24,
    pen_attribute25,
    pen_attribute26,
    pen_attribute27,
    pen_attribute28,
    pen_attribute29,
    pen_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    per_in_ler_id,
    bnft_typ_cd,
      bnft_ordr_num,
      prtt_enrt_rslt_stat_cd,
    bnft_nnmntry_uom,
      comp_lvl_cd,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login
  )
  Values
  (	p_rec.prtt_enrt_rslt_id,
    p_rec.effective_start_date,
    p_rec.effective_end_date,
    p_rec.business_group_id,
    p_rec.oipl_id,
    p_rec.person_id,
    p_rec.assignment_id,
    p_rec.pgm_id,
    p_rec.pl_id,
    p_rec.rplcs_sspndd_rslt_id,
    p_rec.ptip_id,
    p_rec.pl_typ_id,
    p_rec.ler_id,
    p_rec.sspndd_flag,
    p_rec.prtt_is_cvrd_flag,
    p_rec.bnft_amt,
    p_rec.uom     ,
    p_rec.orgnl_enrt_dt,
    p_rec.enrt_mthd_cd,
        p_rec.no_lngr_elig_flag,
    p_rec.enrt_ovridn_flag,
    p_rec.enrt_ovrid_rsn_cd,
    p_rec.erlst_deenrt_dt,
    p_rec.enrt_cvg_strt_dt,
    p_rec.enrt_cvg_thru_dt,
    p_rec.enrt_ovrid_thru_dt,
        p_rec.pl_ordr_num,
        p_rec.plip_ordr_num,
        p_rec.ptip_ordr_num,
        p_rec.oipl_ordr_num,
    p_rec.pen_attribute_category,
    p_rec.pen_attribute1,
    p_rec.pen_attribute2,
    p_rec.pen_attribute3,
    p_rec.pen_attribute4,
    p_rec.pen_attribute5,
    p_rec.pen_attribute6,
    p_rec.pen_attribute7,
    p_rec.pen_attribute8,
    p_rec.pen_attribute9,
    p_rec.pen_attribute10,
    p_rec.pen_attribute11,
    p_rec.pen_attribute12,
    p_rec.pen_attribute13,
    p_rec.pen_attribute14,
    p_rec.pen_attribute15,
    p_rec.pen_attribute16,
    p_rec.pen_attribute17,
    p_rec.pen_attribute18,
    p_rec.pen_attribute19,
    p_rec.pen_attribute20,
    p_rec.pen_attribute21,
    p_rec.pen_attribute22,
    p_rec.pen_attribute23,
    p_rec.pen_attribute24,
    p_rec.pen_attribute25,
    p_rec.pen_attribute26,
    p_rec.pen_attribute27,
    p_rec.pen_attribute28,
    p_rec.pen_attribute29,
    p_rec.pen_attribute30,
    p_rec.request_id,
    p_rec.program_application_id,
    p_rec.program_id,
    p_rec.program_update_date,
    p_rec.object_version_number,
    p_rec.per_in_ler_id,
    p_rec.bnft_typ_cd,
      p_rec.bnft_ordr_num,
      p_rec.prtt_enrt_rslt_stat_cd,
    p_rec.bnft_nnmntry_uom,
    p_rec.comp_lvl_cd,
    l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login
  );
  --
  ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pen_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pen_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
    (p_rec 			         in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date	     in	    date,
     p_datetrack_mode	     in     varchar2,
     p_validation_start_date in	    date,
     p_validation_end_date	 in	    date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
        p_effective_date	    => p_effective_date,
        p_datetrack_mode	    => p_datetrack_mode,
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
    (p_rec  			     in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date		 in     date,
     p_datetrack_mode		 in     varchar2,
     p_validation_start_date in     date,
     p_validation_end_date	 in     date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
  Cursor C_Sel1 is
    select ben_prtt_enrt_rslt_f_s.nextval from sys.dual;
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.prtt_enrt_rslt_id;
  Close C_Sel1;

  if p_rec.enrt_cvg_strt_dt >
     nvl(p_rec.enrt_cvg_thru_dt, p_rec.enrt_cvg_strt_dt) then
     p_rec.prtt_enrt_rslt_stat_cd := 'VOIDD';
  end if;

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
    (p_rec 			         in     ben_pen_shd.g_rec_type,
     p_effective_date	     in     date,
     p_datetrack_mode	     in     varchar2,
     p_validation_start_date in     date,
     p_validation_end_date	 in     date) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
 ben_dt_trgr_handle.prtt_enrt_rslt
    (p_rowid                 => null
    ,p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_person_id             => p_rec.person_id
    ,p_enrt_cvg_strt_dt      => p_rec.enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt      => p_rec.enrt_cvg_thru_dt
    ,p_bnft_amt              => p_rec.bnft_amt
    ,p_effective_start_date  => p_rec.effective_start_date
    ,p_effective_end_date    => p_rec.effective_end_date
    );
  --
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_pen_rki.after_insert
      (p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
      ,p_effective_start_date          =>p_rec.effective_start_date
      ,p_effective_end_date            =>p_rec.effective_end_date
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_oipl_id                       =>p_rec.oipl_id
      ,p_person_id                     =>p_rec.person_id
      ,p_assignment_id                 =>p_rec.assignment_id
      ,p_pgm_id                        =>p_rec.pgm_id
      ,p_pl_id                         =>p_rec.pl_id
      ,p_rplcs_sspndd_rslt_id          =>p_rec.rplcs_sspndd_rslt_id
      ,p_ptip_id                       =>p_rec.ptip_id
      ,p_pl_typ_id                     =>p_rec.pl_typ_id
      ,p_ler_id                        =>p_rec.ler_id
      ,p_sspndd_flag                   =>p_rec.sspndd_flag
      ,p_prtt_is_cvrd_flag             =>p_rec.prtt_is_cvrd_flag
      ,p_bnft_amt                      =>p_rec.bnft_amt
      ,p_uom                           =>p_rec.uom
      ,p_orgnl_enrt_dt                 =>p_rec.orgnl_enrt_dt
      ,p_enrt_mthd_cd                  =>p_rec.enrt_mthd_cd
      ,p_no_lngr_elig_flag             =>p_rec.no_lngr_elig_flag
      ,p_enrt_ovridn_flag              =>p_rec.enrt_ovridn_flag
      ,p_enrt_ovrid_rsn_cd             =>p_rec.enrt_ovrid_rsn_cd
      ,p_erlst_deenrt_dt               =>p_rec.erlst_deenrt_dt
      ,p_enrt_cvg_strt_dt              =>p_rec.enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt              =>p_rec.enrt_cvg_thru_dt
      ,p_enrt_ovrid_thru_dt            =>p_rec.enrt_ovrid_thru_dt
      ,p_pl_ordr_num                     =>p_rec.pl_ordr_num
      ,p_plip_ordr_num                   =>p_rec.plip_ordr_num
      ,p_ptip_ordr_num                   =>p_rec.ptip_ordr_num
      ,p_oipl_ordr_num                   =>p_rec.oipl_ordr_num
      ,p_pen_attribute_category        =>p_rec.pen_attribute_category
      ,p_pen_attribute1                =>p_rec.pen_attribute1
      ,p_pen_attribute2                =>p_rec.pen_attribute2
      ,p_pen_attribute3                =>p_rec.pen_attribute3
      ,p_pen_attribute4                =>p_rec.pen_attribute4
      ,p_pen_attribute5                =>p_rec.pen_attribute5
      ,p_pen_attribute6                =>p_rec.pen_attribute6
      ,p_pen_attribute7                =>p_rec.pen_attribute7
      ,p_pen_attribute8                =>p_rec.pen_attribute8
      ,p_pen_attribute9                =>p_rec.pen_attribute9
      ,p_pen_attribute10               =>p_rec.pen_attribute10
      ,p_pen_attribute11               =>p_rec.pen_attribute11
      ,p_pen_attribute12               =>p_rec.pen_attribute12
      ,p_pen_attribute13               =>p_rec.pen_attribute13
      ,p_pen_attribute14               =>p_rec.pen_attribute14
      ,p_pen_attribute15               =>p_rec.pen_attribute15
      ,p_pen_attribute16               =>p_rec.pen_attribute16
      ,p_pen_attribute17               =>p_rec.pen_attribute17
      ,p_pen_attribute18               =>p_rec.pen_attribute18
      ,p_pen_attribute19               =>p_rec.pen_attribute19
      ,p_pen_attribute20               =>p_rec.pen_attribute20
      ,p_pen_attribute21               =>p_rec.pen_attribute21
      ,p_pen_attribute22               =>p_rec.pen_attribute22
      ,p_pen_attribute23               =>p_rec.pen_attribute23
      ,p_pen_attribute24               =>p_rec.pen_attribute24
      ,p_pen_attribute25               =>p_rec.pen_attribute25
      ,p_pen_attribute26               =>p_rec.pen_attribute26
      ,p_pen_attribute27               =>p_rec.pen_attribute27
      ,p_pen_attribute28               =>p_rec.pen_attribute28
      ,p_pen_attribute29               =>p_rec.pen_attribute29
      ,p_pen_attribute30               =>p_rec.pen_attribute30
      ,p_request_id                    =>p_rec.request_id
      ,p_program_application_id        =>p_rec.program_application_id
      ,p_program_id                    =>p_rec.program_id
      ,p_program_update_date           =>p_rec.program_update_date
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
      ,p_bnft_typ_cd                   =>p_rec.bnft_typ_cd
      ,p_bnft_ordr_num                 =>p_rec.bnft_ordr_num
      ,p_prtt_enrt_rslt_stat_cd        =>p_rec.prtt_enrt_rslt_stat_cd
      ,p_bnft_nnmntry_uom              =>p_rec.bnft_nnmntry_uom
      ,p_comp_lvl_cd                   =>p_rec.comp_lvl_cd
      ,p_effective_date                =>p_effective_date
      ,p_validation_start_date         =>p_validation_start_date
      ,p_validation_end_date           =>p_validation_end_date
      );
  Exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_enrt_rslt_f'
        ,p_hook_type   => 'AI');
  End;
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
     p_rec	 		 in  ben_pen_shd.g_rec_type,
     p_validation_start_date out nocopy date,
     p_validation_end_date	 out nocopy date) is
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
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_base_table_name         => 'ben_prtt_enrt_rslt_f',
     p_base_key_column         => 'prtt_enrt_rslt_id',
     p_base_key_value          => p_rec.prtt_enrt_rslt_id,
     p_parent_table_name1      => 'ben_pgm_f',
     p_parent_key_column1      => 'pgm_id',
     p_parent_key_value1       => p_rec.pgm_id,
     p_parent_table_name2      => 'ben_oipl_f',
     p_parent_key_column2      => 'oipl_id',
     p_parent_key_value2       => p_rec.oipl_id,
     p_parent_table_name3      => 'ben_pl_f',
     p_parent_key_column3      => 'pl_id',
     p_parent_key_value3       => p_rec.pl_id,
     p_parent_table_name4      => 'ben_pl_typ_f',
     p_parent_key_column4      => 'pl_typ_id',
     p_parent_key_value4       => p_rec.pl_typ_id,
     p_parent_table_name5      => 'ben_prtt_enrt_rslt_f',
     p_parent_key_column5      => 'prtt_enrt_rslt_id',
     p_parent_key_value5       => p_rec.prtt_enrt_rslt_id,
     p_parent_table_name6      => 'ben_ptip_f',
     p_parent_key_column6      => 'ptip_id',
     p_parent_key_value6       => p_rec.ptip_id,
     p_parent_table_name7      => 'ben_ler_f',
     p_parent_key_column7      => 'ler_id',
     p_parent_key_value7       => p_rec.ler_id,
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
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy ben_pen_shd.g_rec_type,
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
    (p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => l_datetrack_mode,
     p_rec	 		         => p_rec,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  ben_pen_bus.insert_validate
    (p_rec			         => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
 	(p_rec			         => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
 	(p_rec			         => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Multi_rows_Edit validation
  --
  if (ben_prtt_enrt_result_api.g_multi_rows_validate) then
        ben_pen_bus.multi_rows_edit
          (p_person_id          => p_rec.person_id,
           p_effective_date     => p_effective_date,
           p_business_group_id 	=> p_rec.business_group_id,
           p_pgm_id 		    => p_rec.pgm_id
          );
  end if;
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
    -- DBI - Added DBI Event Logging Hooks
  /* Commented. Need to uncomment when DBI goes into mainline
  5554590 : Enabled DBI logging into mainline */
    if HRI_BPL_BEN_UTIL.enable_ben_col_evt_que then
      hr_utility.set_location('Logging PEN insert event'|| l_proc, 5);
      hri_opl_ben_elig_enrl_eq.insert_event (
                 p_rec              => p_rec ,
                 p_effective_date   => p_effective_date,
                 p_datetrack_mode   => l_datetrack_mode );
    end if;
  --
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_prtt_enrt_rslt_id            out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_oipl_id                      in number           default null,
  p_person_id                    in number,
  p_assignment_id                in number           default null,
  p_pgm_id                       in number           default null,
  p_pl_id                        in number,
  p_rplcs_sspndd_rslt_id         in number           default null,
  p_ptip_id                      in number           default null,
  p_pl_typ_id                    in number           default null,
  p_ler_id                       in number,
  p_sspndd_flag                  in varchar2,
  p_prtt_is_cvrd_flag            in varchar2,
  p_bnft_amt                     in number           default null,
  p_uom                          in varchar2         default null,
  p_orgnl_enrt_dt                in date             default null,
  p_enrt_mthd_cd                 in varchar2,
  p_no_lngr_elig_flag            in varchar2,
  p_enrt_ovridn_flag             in varchar2,
  p_enrt_ovrid_rsn_cd            in varchar2         default null,
  p_erlst_deenrt_dt              in date             default null,
  p_enrt_cvg_strt_dt             in date             default null,
  p_enrt_cvg_thru_dt             in date             default null,
  p_enrt_ovrid_thru_dt           in date             default null,
  p_pl_ordr_num                  in number           default null,
  p_plip_ordr_num                in number           default null,
  p_ptip_ordr_num                in number           default null,
  p_oipl_ordr_num                in number           default null,
  p_pen_attribute_category       in varchar2         default null,
  p_pen_attribute1               in varchar2         default null,
  p_pen_attribute2               in varchar2         default null,
  p_pen_attribute3               in varchar2         default null,
  p_pen_attribute4               in varchar2         default null,
  p_pen_attribute5               in varchar2         default null,
  p_pen_attribute6               in varchar2         default null,
  p_pen_attribute7               in varchar2         default null,
  p_pen_attribute8               in varchar2         default null,
  p_pen_attribute9               in varchar2         default null,
  p_pen_attribute10              in varchar2         default null,
  p_pen_attribute11              in varchar2         default null,
  p_pen_attribute12              in varchar2         default null,
  p_pen_attribute13              in varchar2         default null,
  p_pen_attribute14              in varchar2         default null,
  p_pen_attribute15              in varchar2         default null,
  p_pen_attribute16              in varchar2         default null,
  p_pen_attribute17              in varchar2         default null,
  p_pen_attribute18              in varchar2         default null,
  p_pen_attribute19              in varchar2         default null,
  p_pen_attribute20              in varchar2         default null,
  p_pen_attribute21              in varchar2         default null,
  p_pen_attribute22              in varchar2         default null,
  p_pen_attribute23              in varchar2         default null,
  p_pen_attribute24              in varchar2         default null,
  p_pen_attribute25              in varchar2         default null,
  p_pen_attribute26              in varchar2         default null,
  p_pen_attribute27              in varchar2         default null,
  p_pen_attribute28              in varchar2         default null,
  p_pen_attribute29              in varchar2         default null,
  p_pen_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_per_in_ler_id                in number           default null,
  p_bnft_typ_cd                  in varchar2         default null,
  p_bnft_ordr_num                in number           default null,
  p_prtt_enrt_rslt_stat_cd       in varchar2         default null,
  p_bnft_nnmntry_uom             in varchar2         default null,
  p_comp_lvl_cd                  in varchar2         default null,
  p_effective_date		 in date
  ) is
--
  l_rec		ben_pen_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pen_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_oipl_id,
  p_person_id,
  p_assignment_id,
  p_pgm_id,
  p_pl_id,
  p_rplcs_sspndd_rslt_id,
  p_ptip_id,
  p_pl_typ_id,
  p_ler_id,
  p_sspndd_flag,
  p_prtt_is_cvrd_flag,
  p_bnft_amt,
  p_uom     ,
  p_orgnl_enrt_dt,
  p_enrt_mthd_cd,
  p_no_lngr_elig_flag,
  p_enrt_ovridn_flag,
  p_enrt_ovrid_rsn_cd,
  p_erlst_deenrt_dt,
  p_enrt_cvg_strt_dt,
  p_enrt_cvg_thru_dt,
  p_enrt_ovrid_thru_dt,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_oipl_ordr_num,
  p_pen_attribute_category,
  p_pen_attribute1,
  p_pen_attribute2,
  p_pen_attribute3,
  p_pen_attribute4,
  p_pen_attribute5,
  p_pen_attribute6,
  p_pen_attribute7,
  p_pen_attribute8,
  p_pen_attribute9,
  p_pen_attribute10,
  p_pen_attribute11,
  p_pen_attribute12,
  p_pen_attribute13,
  p_pen_attribute14,
  p_pen_attribute15,
  p_pen_attribute16,
  p_pen_attribute17,
  p_pen_attribute18,
  p_pen_attribute19,
  p_pen_attribute20,
  p_pen_attribute21,
  p_pen_attribute22,
  p_pen_attribute23,
  p_pen_attribute24,
  p_pen_attribute25,
  p_pen_attribute26,
  p_pen_attribute27,
  p_pen_attribute28,
  p_pen_attribute29,
  p_pen_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null,
  p_per_in_ler_id,
  p_bnft_typ_cd,
  p_bnft_ordr_num,
  p_prtt_enrt_rslt_stat_cd,
  p_bnft_nnmntry_uom,
  p_comp_lvl_cd
   );
  --
  -- Having converted the arguments into the ben_pen_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_prtt_enrt_rslt_id       := l_rec.prtt_enrt_rslt_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pen_ins;

/
