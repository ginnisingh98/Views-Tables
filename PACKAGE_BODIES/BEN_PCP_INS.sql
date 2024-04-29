--------------------------------------------------------
--  DDL for Package Body BEN_PCP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_INS" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 vsethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcp_ins.';  -- Global package name
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
Procedure insert_dml
  (p_rec in out nocopy ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_pcp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pl_pcp
  --
  insert into ben_pl_pcp
      (pl_pcp_id
      ,pl_id
      ,business_group_id
      ,pcp_strt_dt_cd
      ,pcp_dsgn_cd
      ,pcp_dpnt_dsgn_cd
      ,pcp_rpstry_flag
      ,pcp_can_keep_flag
      ,pcp_radius
      ,pcp_radius_uom
      ,pcp_radius_warn_flag
      ,pcp_num_chgs
      ,pcp_num_chgs_uom
      ,pcp_attribute_category
      ,pcp_attribute1
      ,pcp_attribute2
      ,pcp_attribute3
      ,pcp_attribute4
      ,pcp_attribute5
      ,pcp_attribute6
      ,pcp_attribute7
      ,pcp_attribute8
      ,pcp_attribute9
      ,pcp_attribute10
      ,pcp_attribute11
      ,pcp_attribute12
      ,pcp_attribute13
      ,pcp_attribute14
      ,pcp_attribute15
      ,pcp_attribute16
      ,pcp_attribute17
      ,pcp_attribute18
      ,pcp_attribute19
      ,pcp_attribute20
      ,pcp_attribute21
      ,pcp_attribute22
      ,pcp_attribute23
      ,pcp_attribute24
      ,pcp_attribute25
      ,pcp_attribute26
      ,pcp_attribute27
      ,pcp_attribute28
      ,pcp_attribute29
      ,pcp_attribute30
      ,object_version_number
      )
  Values
    (p_rec.pl_pcp_id
    ,p_rec.pl_id
    ,p_rec.business_group_id
    ,p_rec.pcp_strt_dt_cd
    ,p_rec.pcp_dsgn_cd
    ,p_rec.pcp_dpnt_dsgn_cd
    ,p_rec.pcp_rpstry_flag
    ,p_rec.pcp_can_keep_flag
    ,p_rec.pcp_radius
    ,p_rec.pcp_radius_uom
    ,p_rec.pcp_radius_warn_flag
    ,p_rec.pcp_num_chgs
    ,p_rec.pcp_num_chgs_uom
    ,p_rec.pcp_attribute_category
    ,p_rec.pcp_attribute1
    ,p_rec.pcp_attribute2
    ,p_rec.pcp_attribute3
    ,p_rec.pcp_attribute4
    ,p_rec.pcp_attribute5
    ,p_rec.pcp_attribute6
    ,p_rec.pcp_attribute7
    ,p_rec.pcp_attribute8
    ,p_rec.pcp_attribute9
    ,p_rec.pcp_attribute10
    ,p_rec.pcp_attribute11
    ,p_rec.pcp_attribute12
    ,p_rec.pcp_attribute13
    ,p_rec.pcp_attribute14
    ,p_rec.pcp_attribute15
    ,p_rec.pcp_attribute16
    ,p_rec.pcp_attribute17
    ,p_rec.pcp_attribute18
    ,p_rec.pcp_attribute19
    ,p_rec.pcp_attribute20
    ,p_rec.pcp_attribute21
    ,p_rec.pcp_attribute22
    ,p_rec.pcp_attribute23
    ,p_rec.pcp_attribute24
    ,p_rec.pcp_attribute25
    ,p_rec.pcp_attribute26
    ,p_rec.pcp_attribute27
    ,p_rec.pcp_attribute28
    ,p_rec.pcp_attribute29
    ,p_rec.pcp_attribute30
    ,p_rec.object_version_number
    );
  --
  ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert
  (p_rec  in out nocopy ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pl_pcp_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pl_pcp_id;
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
Procedure post_insert
  (p_rec                          in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pcp_rki.after_insert
      (p_pl_pcp_id
      => p_rec.pl_pcp_id
      ,p_pl_id
      => p_rec.pl_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pcp_strt_dt_cd
      => p_rec.pcp_strt_dt_cd
      ,p_pcp_dsgn_cd
      => p_rec.pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd
      => p_rec.pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag
      => p_rec.pcp_rpstry_flag
      ,p_pcp_can_keep_flag
      => p_rec.pcp_can_keep_flag
      ,p_pcp_radius
      => p_rec.pcp_radius
      ,p_pcp_radius_uom
      => p_rec.pcp_radius_uom
      ,p_pcp_radius_warn_flag
      => p_rec.pcp_radius_warn_flag
      ,p_pcp_num_chgs
      => p_rec.pcp_num_chgs
      ,p_pcp_num_chgs_uom
      => p_rec.pcp_num_chgs_uom
      ,p_pcp_attribute_category
      => p_rec.pcp_attribute_category
      ,p_pcp_attribute1
      => p_rec.pcp_attribute1
      ,p_pcp_attribute2
      => p_rec.pcp_attribute2
      ,p_pcp_attribute3
      => p_rec.pcp_attribute3
      ,p_pcp_attribute4
      => p_rec.pcp_attribute4
      ,p_pcp_attribute5
      => p_rec.pcp_attribute5
      ,p_pcp_attribute6
      => p_rec.pcp_attribute6
      ,p_pcp_attribute7
      => p_rec.pcp_attribute7
      ,p_pcp_attribute8
      => p_rec.pcp_attribute8
      ,p_pcp_attribute9
      => p_rec.pcp_attribute9
      ,p_pcp_attribute10
      => p_rec.pcp_attribute10
      ,p_pcp_attribute11
      => p_rec.pcp_attribute11
      ,p_pcp_attribute12
      => p_rec.pcp_attribute12
      ,p_pcp_attribute13
      => p_rec.pcp_attribute13
      ,p_pcp_attribute14
      => p_rec.pcp_attribute14
      ,p_pcp_attribute15
      => p_rec.pcp_attribute15
      ,p_pcp_attribute16
      => p_rec.pcp_attribute16
      ,p_pcp_attribute17
      => p_rec.pcp_attribute17
      ,p_pcp_attribute18
      => p_rec.pcp_attribute18
      ,p_pcp_attribute19
      => p_rec.pcp_attribute19
      ,p_pcp_attribute20
      => p_rec.pcp_attribute20
      ,p_pcp_attribute21
      => p_rec.pcp_attribute21
      ,p_pcp_attribute22
      => p_rec.pcp_attribute22
      ,p_pcp_attribute23
      => p_rec.pcp_attribute23
      ,p_pcp_attribute24
      => p_rec.pcp_attribute24
      ,p_pcp_attribute25
      => p_rec.pcp_attribute25
      ,p_pcp_attribute26
      => p_rec.pcp_attribute26
      ,p_pcp_attribute27
      => p_rec.pcp_attribute27
      ,p_pcp_attribute28
      => p_rec.pcp_attribute28
      ,p_pcp_attribute29
      => p_rec.pcp_attribute29
      ,p_pcp_attribute30
      => p_rec.pcp_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PL_PCP'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in date,
   p_rec                          in out nocopy ben_pcp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_pcp_bus.insert_validate
     (p_rec
     ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  ben_pcp_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_pcp_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_pcp_ins.post_insert
     (p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (  p_effective_date in date
  ,p_pl_id                          in     number
  ,p_business_group_id              in     number
  ,p_pcp_rpstry_flag                in     varchar2
  ,p_pcp_can_keep_flag              in     varchar2
  ,p_pcp_radius_warn_flag           in     varchar2
  ,p_pcp_strt_dt_cd                 in     varchar2 default null
  ,p_pcp_dsgn_cd                    in     varchar2 default null
  ,p_pcp_dpnt_dsgn_cd               in     varchar2 default null
  ,p_pcp_radius                     in     number   default null
  ,p_pcp_radius_uom                 in     varchar2 default null
  ,p_pcp_num_chgs                   in     number   default null
  ,p_pcp_num_chgs_uom               in     varchar2 default null
  ,p_pcp_attribute_category         in     varchar2 default null
  ,p_pcp_attribute1                 in     varchar2 default null
  ,p_pcp_attribute2                 in     varchar2 default null
  ,p_pcp_attribute3                 in     varchar2 default null
  ,p_pcp_attribute4                 in     varchar2 default null
  ,p_pcp_attribute5                 in     varchar2 default null
  ,p_pcp_attribute6                 in     varchar2 default null
  ,p_pcp_attribute7                 in     varchar2 default null
  ,p_pcp_attribute8                 in     varchar2 default null
  ,p_pcp_attribute9                 in     varchar2 default null
  ,p_pcp_attribute10                in     varchar2 default null
  ,p_pcp_attribute11                in     varchar2 default null
  ,p_pcp_attribute12                in     varchar2 default null
  ,p_pcp_attribute13                in     varchar2 default null
  ,p_pcp_attribute14                in     varchar2 default null
  ,p_pcp_attribute15                in     varchar2 default null
  ,p_pcp_attribute16                in     varchar2 default null
  ,p_pcp_attribute17                in     varchar2 default null
  ,p_pcp_attribute18                in     varchar2 default null
  ,p_pcp_attribute19                in     varchar2 default null
  ,p_pcp_attribute20                in     varchar2 default null
  ,p_pcp_attribute21                in     varchar2 default null
  ,p_pcp_attribute22                in     varchar2 default null
  ,p_pcp_attribute23                in     varchar2 default null
  ,p_pcp_attribute24                in     varchar2 default null
  ,p_pcp_attribute25                in     varchar2 default null
  ,p_pcp_attribute26                in     varchar2 default null
  ,p_pcp_attribute27                in     varchar2 default null
  ,p_pcp_attribute28                in     varchar2 default null
  ,p_pcp_attribute29                in     varchar2 default null
  ,p_pcp_attribute30                in     varchar2 default null
  ,p_pl_pcp_id                         out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  ben_pcp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pcp_shd.convert_args
    (null
    ,p_pl_id
    ,p_business_group_id
    ,p_pcp_strt_dt_cd
    ,p_pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd
    ,p_pcp_rpstry_flag
    ,p_pcp_can_keep_flag
    ,p_pcp_radius
    ,p_pcp_radius_uom
    ,p_pcp_radius_warn_flag
    ,p_pcp_num_chgs
    ,p_pcp_num_chgs_uom
    ,p_pcp_attribute_category
    ,p_pcp_attribute1
    ,p_pcp_attribute2
    ,p_pcp_attribute3
    ,p_pcp_attribute4
    ,p_pcp_attribute5
    ,p_pcp_attribute6
    ,p_pcp_attribute7
    ,p_pcp_attribute8
    ,p_pcp_attribute9
    ,p_pcp_attribute10
    ,p_pcp_attribute11
    ,p_pcp_attribute12
    ,p_pcp_attribute13
    ,p_pcp_attribute14
    ,p_pcp_attribute15
    ,p_pcp_attribute16
    ,p_pcp_attribute17
    ,p_pcp_attribute18
    ,p_pcp_attribute19
    ,p_pcp_attribute20
    ,p_pcp_attribute21
    ,p_pcp_attribute22
    ,p_pcp_attribute23
    ,p_pcp_attribute24
    ,p_pcp_attribute25
    ,p_pcp_attribute26
    ,p_pcp_attribute27
    ,p_pcp_attribute28
    ,p_pcp_attribute29
    ,p_pcp_attribute30
    ,null
    );
  --
  -- Having converted the arguments into the ben_pcp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_pcp_ins.ins
     (p_effective_date, l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pl_pcp_id := l_rec.pl_pcp_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pcp_ins;

/
