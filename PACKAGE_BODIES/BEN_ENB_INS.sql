--------------------------------------------------------
--  DDL for Package Body BEN_ENB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENB_INS" as
/* $Header: beenbrhi.pkb 115.15 2002/12/16 07:02:08 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enb_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_enb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_enb_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_enrt_bnft
  --
  insert into ben_enrt_bnft
  (	 enrt_bnft_id
	,dflt_flag
	,val_has_bn_prortd_flag
	,bndry_perd_cd
	,val
	,nnmntry_uom
	,bnft_typ_cd
	,entr_val_at_enrt_flag
	,mn_val
	,mx_val
	,incrmt_val
        ,dflt_val
	,rt_typ_cd
	,cvg_mlt_cd
	,ctfn_rqd_flag
	,ordr_num
	,crntly_enrld_flag
	,elig_per_elctbl_chc_id
	,prtt_enrt_rslt_id
	,comp_lvl_fctr_id
	,business_group_id
	,enb_attribute_category
	,enb_attribute1
	,enb_attribute2
	,enb_attribute3
	,enb_attribute4
	,enb_attribute5
	,enb_attribute6
	,enb_attribute7
	,enb_attribute8
	,enb_attribute9
	,enb_attribute10
	,enb_attribute11
	,enb_attribute12
	,enb_attribute13
	,enb_attribute14
	,enb_attribute15
	,enb_attribute16
	,enb_attribute17
	,enb_attribute18
	,enb_attribute19
	,enb_attribute20
	,enb_attribute21
	,enb_attribute22
	,enb_attribute23
	,enb_attribute24
	,enb_attribute25
	,enb_attribute26
	,enb_attribute27
	,enb_attribute28
	,enb_attribute29
    ,enb_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,mx_wout_ctfn_val
    ,mx_wo_ctfn_flag
    ,program_update_date
    ,object_version_number
  )
  Values
  (	p_rec.enrt_bnft_id           ,
	p_rec.dflt_flag              ,
	p_rec.val_has_bn_prortd_flag ,
	p_rec.bndry_perd_cd          ,
	p_rec.val                    ,
	p_rec.nnmntry_uom            ,
	p_rec.bnft_typ_cd            ,
	p_rec.entr_val_at_enrt_flag  ,
	p_rec.mn_val                 ,
	p_rec.mx_val                 ,
	p_rec.incrmt_val             ,
        p_rec.dflt_val               ,
	p_rec.rt_typ_cd              ,
	p_rec.cvg_mlt_cd             ,
	p_rec.ctfn_rqd_flag          ,
	p_rec.ordr_num               ,
	p_rec.crntly_enrld_flag      ,
	p_rec.elig_per_elctbl_chc_id ,
	p_rec.prtt_enrt_rslt_id      ,
	p_rec.comp_lvl_fctr_id       ,
	p_rec.business_group_id      ,
	p_rec.enb_attribute_category ,
	p_rec.enb_attribute1         ,
	p_rec.enb_attribute2         ,
	p_rec.enb_attribute3         ,
	p_rec.enb_attribute4         ,
	p_rec.enb_attribute5         ,
	p_rec.enb_attribute6         ,
	p_rec.enb_attribute7         ,
	p_rec.enb_attribute8         ,
	p_rec.enb_attribute9         ,
	p_rec.enb_attribute10        ,
	p_rec.enb_attribute11        ,
	p_rec.enb_attribute12        ,
	p_rec.enb_attribute13        ,
	p_rec.enb_attribute14        ,
	p_rec.enb_attribute15        ,
	p_rec.enb_attribute16        ,
	p_rec.enb_attribute17        ,
	p_rec.enb_attribute18        ,
	p_rec.enb_attribute19        ,
	p_rec.enb_attribute20        ,
	p_rec.enb_attribute21        ,
	p_rec.enb_attribute22        ,
	p_rec.enb_attribute23        ,
	p_rec.enb_attribute24        ,
	p_rec.enb_attribute25        ,
	p_rec.enb_attribute26        ,
	p_rec.enb_attribute27        ,
	p_rec.enb_attribute28        ,
	p_rec.enb_attribute29        ,
    p_rec.enb_attribute30        ,
    p_rec.request_id             ,
    p_rec.program_application_id ,
    p_rec.program_id             ,
    p_rec.mx_wout_ctfn_val       ,
    p_rec.mx_wo_ctfn_flag        ,
    p_rec.program_update_date    ,
    p_rec.object_version_number
  );
  --
  ben_enb_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_enb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_enb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_enb_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enb_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_enb_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
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
Procedure pre_insert(p_rec  in out nocopy ben_enb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_enrt_bnft_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.enrt_bnft_id;
  Close C_Sel1;
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
Procedure post_insert(
p_effective_date in date,p_rec in ben_enb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_enb_rki.after_insert
(
  p_enrt_bnft_id                =>p_rec.enrt_bnft_id
 ,p_dflt_flag                   =>p_rec.dflt_flag
 ,p_val_has_bn_prortd_flag      =>p_rec.val_has_bn_prortd_flag
 ,p_bndry_perd_cd               =>p_rec.bndry_perd_cd
 ,p_val                         =>p_rec.val
 ,p_nnmntry_uom                 =>p_rec.nnmntry_uom
 ,p_bnft_typ_cd                 =>p_rec.bnft_typ_cd
 ,p_entr_val_at_enrt_flag       =>p_rec.entr_val_at_enrt_flag
 ,p_mn_val                      =>p_rec.mn_val
 ,p_mx_val                      =>p_rec.mx_val
 ,p_incrmt_val                  =>p_rec.incrmt_val
 ,p_dflt_val                    =>p_rec.dflt_val
 ,p_rt_typ_cd                   =>p_rec.rt_typ_cd
 ,p_cvg_mlt_cd                  =>p_rec.cvg_mlt_cd
 ,p_ctfn_rqd_flag               =>p_rec.ctfn_rqd_flag
 ,p_ordr_num                    =>p_rec.ordr_num
 ,p_crntly_enrld_flag           =>p_rec.crntly_enrld_flag
 ,p_elig_per_elctbl_chc_id      =>p_rec.elig_per_elctbl_chc_id
 ,p_prtt_enrt_rslt_id           =>p_rec.prtt_enrt_rslt_id
 ,p_comp_lvl_fctr_id            =>p_rec.comp_lvl_fctr_id
 ,p_business_group_id           =>p_rec.business_group_id
 ,p_enb_attribute_category      =>p_rec.enb_attribute_category
 ,p_enb_attribute1              =>p_rec.enb_attribute1
 ,p_enb_attribute2              =>p_rec.enb_attribute2
 ,p_enb_attribute3              =>p_rec.enb_attribute3
 ,p_enb_attribute4              =>p_rec.enb_attribute4
 ,p_enb_attribute5              =>p_rec.enb_attribute5
 ,p_enb_attribute6              =>p_rec.enb_attribute6
 ,p_enb_attribute7              =>p_rec.enb_attribute7
 ,p_enb_attribute8              =>p_rec.enb_attribute8
 ,p_enb_attribute9              =>p_rec.enb_attribute9
 ,p_enb_attribute10             =>p_rec.enb_attribute10
 ,p_enb_attribute11             =>p_rec.enb_attribute11
 ,p_enb_attribute12             =>p_rec.enb_attribute12
 ,p_enb_attribute13             =>p_rec.enb_attribute13
 ,p_enb_attribute14             =>p_rec.enb_attribute14
 ,p_enb_attribute15             =>p_rec.enb_attribute15
 ,p_enb_attribute16             =>p_rec.enb_attribute16
 ,p_enb_attribute17             =>p_rec.enb_attribute17
 ,p_enb_attribute18             =>p_rec.enb_attribute18
 ,p_enb_attribute19             =>p_rec.enb_attribute19
 ,p_enb_attribute20             =>p_rec.enb_attribute20
 ,p_enb_attribute21             =>p_rec.enb_attribute21
 ,p_enb_attribute22             =>p_rec.enb_attribute22
 ,p_enb_attribute23             =>p_rec.enb_attribute23
 ,p_enb_attribute24             =>p_rec.enb_attribute24
 ,p_enb_attribute25             =>p_rec.enb_attribute25
 ,p_enb_attribute26             =>p_rec.enb_attribute26
 ,p_enb_attribute27             =>p_rec.enb_attribute27
 ,p_enb_attribute28             =>p_rec.enb_attribute28
 ,p_enb_attribute29             =>p_rec.enb_attribute29
 ,p_enb_attribute30             =>p_rec.enb_attribute30
 ,p_request_id                  =>p_rec.request_id
 ,p_program_application_id      =>p_rec.program_application_id
 ,p_program_id                  =>p_rec.program_id
 ,p_mx_wout_ctfn_val            =>p_rec.mx_wout_ctfn_val
 ,p_mx_wo_ctfn_flag             =>p_rec.mx_wo_ctfn_flag
 ,p_program_update_date         =>p_rec.program_update_date
 ,p_object_version_number       =>p_rec.object_version_number
 ,p_effective_date              =>p_effective_date
);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_bnft'
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
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy ben_enb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_enb_bus.insert_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
   p_effective_date                 in date
  ,p_enrt_bnft_id                   out nocopy number
  ,p_dflt_flag                      in  varchar2  default null
  ,p_val_has_bn_prortd_flag         in  varchar2  default null
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default null
  ,p_mn_val                         in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_incrmt_val                     in  number    default null
  ,p_dflt_val                       in  number    default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_cvg_mlt_cd                     in  varchar2  default null
  ,p_ctfn_rqd_flag                  in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_crntly_enrld_flag              in  varchar2  default null
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_enb_attribute_category         in  varchar2  default null
  ,p_enb_attribute1                 in  varchar2  default null
  ,p_enb_attribute2                 in  varchar2  default null
  ,p_enb_attribute3                 in  varchar2  default null
  ,p_enb_attribute4                 in  varchar2  default null
  ,p_enb_attribute5                 in  varchar2  default null
  ,p_enb_attribute6                 in  varchar2  default null
  ,p_enb_attribute7                 in  varchar2  default null
  ,p_enb_attribute8                 in  varchar2  default null
  ,p_enb_attribute9                 in  varchar2  default null
  ,p_enb_attribute10                in  varchar2  default null
  ,p_enb_attribute11                in  varchar2  default null
  ,p_enb_attribute12                in  varchar2  default null
  ,p_enb_attribute13                in  varchar2  default null
  ,p_enb_attribute14                in  varchar2  default null
  ,p_enb_attribute15                in  varchar2  default null
  ,p_enb_attribute16                in  varchar2  default null
  ,p_enb_attribute17                in  varchar2  default null
  ,p_enb_attribute18                in  varchar2  default null
  ,p_enb_attribute19                in  varchar2  default null
  ,p_enb_attribute20                in  varchar2  default null
  ,p_enb_attribute21                in  varchar2  default null
  ,p_enb_attribute22                in  varchar2  default null
  ,p_enb_attribute23                in  varchar2  default null
  ,p_enb_attribute24                in  varchar2  default null
  ,p_enb_attribute25                in  varchar2  default null
  ,p_enb_attribute26                in  varchar2  default null
  ,p_enb_attribute27                in  varchar2  default null
  ,p_enb_attribute28                in  varchar2  default null
  ,p_enb_attribute29                in  varchar2  default null
  ,p_enb_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_mx_wout_ctfn_val               in  number    default null
  ,p_mx_wo_ctfn_flag                in  varchar2  default 'N'
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ) is
--
  l_rec	  ben_enb_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_enb_shd.convert_args
  (
   null
  ,p_dflt_flag
  ,p_val_has_bn_prortd_flag
  ,p_bndry_perd_cd
  ,p_val
  ,p_nnmntry_uom
  ,p_bnft_typ_cd
  ,p_entr_val_at_enrt_flag
  ,p_mn_val
  ,p_mx_val
  ,p_incrmt_val
  ,p_dflt_val
  ,p_rt_typ_cd
  ,p_cvg_mlt_cd
  ,p_ctfn_rqd_flag
  ,p_ordr_num
  ,p_crntly_enrld_flag
  ,p_elig_per_elctbl_chc_id
  ,p_prtt_enrt_rslt_id
  ,p_comp_lvl_fctr_id
  ,p_business_group_id
  ,p_enb_attribute_category
  ,p_enb_attribute1
  ,p_enb_attribute2
  ,p_enb_attribute3
  ,p_enb_attribute4
  ,p_enb_attribute5
  ,p_enb_attribute6
  ,p_enb_attribute7
  ,p_enb_attribute8
  ,p_enb_attribute9
  ,p_enb_attribute10
  ,p_enb_attribute11
  ,p_enb_attribute12
  ,p_enb_attribute13
  ,p_enb_attribute14
  ,p_enb_attribute15
  ,p_enb_attribute16
  ,p_enb_attribute17
  ,p_enb_attribute18
  ,p_enb_attribute19
  ,p_enb_attribute20
  ,p_enb_attribute21
  ,p_enb_attribute22
  ,p_enb_attribute23
  ,p_enb_attribute24
  ,p_enb_attribute25
  ,p_enb_attribute26
  ,p_enb_attribute27
  ,p_enb_attribute28
  ,p_enb_attribute29
  ,p_enb_attribute30
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_mx_wout_ctfn_val
  ,p_mx_wo_ctfn_flag
  ,p_program_update_date
  ,null
  );
  --
  -- Having converted the arguments into the ben_enb_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_enrt_bnft_id := l_rec.enrt_bnft_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_enb_ins;


/
