--------------------------------------------------------
--  DDL for Package Body BEN_PTY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTY_INS" as
/* $Header: beptyrhi.pkb 115.7 2002/12/10 15:22:41 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pty_ins.';  -- Global package name
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
  (p_rec in out nocopy ben_pty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_pty_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pl_pcp_typ
  --
  insert into ben_pl_pcp_typ
      (pl_pcp_typ_id
      ,pl_pcp_id
      ,business_group_id
      ,pcp_typ_cd
      ,min_age
      ,max_age
      ,gndr_alwd_cd
      ,pty_attribute_category
      ,pty_attribute1
      ,pty_attribute2
      ,pty_attribute3
      ,pty_attribute4
      ,pty_attribute5
      ,pty_attribute6
      ,pty_attribute7
      ,pty_attribute8
      ,pty_attribute9
      ,pty_attribute10
      ,pty_attribute11
      ,pty_attribute12
      ,pty_attribute13
      ,pty_attribute14
      ,pty_attribute15
      ,pty_attribute16
      ,pty_attribute17
      ,pty_attribute18
      ,pty_attribute19
      ,pty_attribute20
      ,pty_attribute21
      ,pty_attribute22
      ,pty_attribute23
      ,pty_attribute24
      ,pty_attribute25
      ,pty_attribute26
      ,pty_attribute27
      ,pty_attribute28
      ,pty_attribute29
      ,pty_attribute30
      ,object_version_number
      )
  Values
    (p_rec.pl_pcp_typ_id
    ,p_rec.pl_pcp_id
    ,p_rec.business_group_id
    ,p_rec.pcp_typ_cd
    ,p_rec.min_age
    ,p_rec.max_age
    ,p_rec.gndr_alwd_cd
    ,p_rec.pty_attribute_category
    ,p_rec.pty_attribute1
    ,p_rec.pty_attribute2
    ,p_rec.pty_attribute3
    ,p_rec.pty_attribute4
    ,p_rec.pty_attribute5
    ,p_rec.pty_attribute6
    ,p_rec.pty_attribute7
    ,p_rec.pty_attribute8
    ,p_rec.pty_attribute9
    ,p_rec.pty_attribute10
    ,p_rec.pty_attribute11
    ,p_rec.pty_attribute12
    ,p_rec.pty_attribute13
    ,p_rec.pty_attribute14
    ,p_rec.pty_attribute15
    ,p_rec.pty_attribute16
    ,p_rec.pty_attribute17
    ,p_rec.pty_attribute18
    ,p_rec.pty_attribute19
    ,p_rec.pty_attribute20
    ,p_rec.pty_attribute21
    ,p_rec.pty_attribute22
    ,p_rec.pty_attribute23
    ,p_rec.pty_attribute24
    ,p_rec.pty_attribute25
    ,p_rec.pty_attribute26
    ,p_rec.pty_attribute27
    ,p_rec.pty_attribute28
    ,p_rec.pty_attribute29
    ,p_rec.pty_attribute30
    ,p_rec.object_version_number
    );
  --
  ben_pty_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pty_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pty_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pty_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pty_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pty_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy ben_pty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pl_pcp_typ_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pl_pcp_typ_id;
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
  (p_rec                          in ben_pty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pty_rki.after_insert
      (p_pl_pcp_typ_id
      => p_rec.pl_pcp_typ_id
      ,p_pl_pcp_id
      => p_rec.pl_pcp_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pcp_typ_cd
      => p_rec.pcp_typ_cd
      ,p_min_age
      => p_rec.min_age
      ,p_max_age
      => p_rec.max_age
      ,p_gndr_alwd_cd
      => p_rec.gndr_alwd_cd
      ,p_pty_attribute_category
      => p_rec.pty_attribute_category
      ,p_pty_attribute1
      => p_rec.pty_attribute1
      ,p_pty_attribute2
      => p_rec.pty_attribute2
      ,p_pty_attribute3
      => p_rec.pty_attribute3
      ,p_pty_attribute4
      => p_rec.pty_attribute4
      ,p_pty_attribute5
      => p_rec.pty_attribute5
      ,p_pty_attribute6
      => p_rec.pty_attribute6
      ,p_pty_attribute7
      => p_rec.pty_attribute7
      ,p_pty_attribute8
      => p_rec.pty_attribute8
      ,p_pty_attribute9
      => p_rec.pty_attribute9
      ,p_pty_attribute10
      => p_rec.pty_attribute10
      ,p_pty_attribute11
      => p_rec.pty_attribute11
      ,p_pty_attribute12
      => p_rec.pty_attribute12
      ,p_pty_attribute13
      => p_rec.pty_attribute13
      ,p_pty_attribute14
      => p_rec.pty_attribute14
      ,p_pty_attribute15
      => p_rec.pty_attribute15
      ,p_pty_attribute16
      => p_rec.pty_attribute16
      ,p_pty_attribute17
      => p_rec.pty_attribute17
      ,p_pty_attribute18
      => p_rec.pty_attribute18
      ,p_pty_attribute19
      => p_rec.pty_attribute19
      ,p_pty_attribute20
      => p_rec.pty_attribute20
      ,p_pty_attribute21
      => p_rec.pty_attribute21
      ,p_pty_attribute22
      => p_rec.pty_attribute22
      ,p_pty_attribute23
      => p_rec.pty_attribute23
      ,p_pty_attribute24
      => p_rec.pty_attribute24
      ,p_pty_attribute25
      => p_rec.pty_attribute25
      ,p_pty_attribute26
      => p_rec.pty_attribute26
      ,p_pty_attribute27
      => p_rec.pty_attribute27
      ,p_pty_attribute28
      => p_rec.pty_attribute28
      ,p_pty_attribute29
      => p_rec.pty_attribute29
      ,p_pty_attribute30
      => p_rec.pty_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PL_PCP_TYP'
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
   p_rec                          in out nocopy ben_pty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_pty_bus.insert_validate
     (p_rec,
   p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  ben_pty_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_pty_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_pty_ins.post_insert
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
  ,p_pl_pcp_id                      in     number
  ,p_business_group_id              in     number
  ,p_pcp_typ_cd                     in     varchar2 default null
  ,p_min_age                        in     number   default null
  ,p_max_age                        in     number   default null
  ,p_gndr_alwd_cd                   in     varchar2 default null
  ,p_pty_attribute_category         in     varchar2 default null
  ,p_pty_attribute1                 in     varchar2 default null
  ,p_pty_attribute2                 in     varchar2 default null
  ,p_pty_attribute3                 in     varchar2 default null
  ,p_pty_attribute4                 in     varchar2 default null
  ,p_pty_attribute5                 in     varchar2 default null
  ,p_pty_attribute6                 in     varchar2 default null
  ,p_pty_attribute7                 in     varchar2 default null
  ,p_pty_attribute8                 in     varchar2 default null
  ,p_pty_attribute9                 in     varchar2 default null
  ,p_pty_attribute10                in     varchar2 default null
  ,p_pty_attribute11                in     varchar2 default null
  ,p_pty_attribute12                in     varchar2 default null
  ,p_pty_attribute13                in     varchar2 default null
  ,p_pty_attribute14                in     varchar2 default null
  ,p_pty_attribute15                in     varchar2 default null
  ,p_pty_attribute16                in     varchar2 default null
  ,p_pty_attribute17                in     varchar2 default null
  ,p_pty_attribute18                in     varchar2 default null
  ,p_pty_attribute19                in     varchar2 default null
  ,p_pty_attribute20                in     varchar2 default null
  ,p_pty_attribute21                in     varchar2 default null
  ,p_pty_attribute22                in     varchar2 default null
  ,p_pty_attribute23                in     varchar2 default null
  ,p_pty_attribute24                in     varchar2 default null
  ,p_pty_attribute25                in     varchar2 default null
  ,p_pty_attribute26                in     varchar2 default null
  ,p_pty_attribute27                in     varchar2 default null
  ,p_pty_attribute28                in     varchar2 default null
  ,p_pty_attribute29                in     varchar2 default null
  ,p_pty_attribute30                in     varchar2 default null
  ,p_pl_pcp_typ_id                     out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  ben_pty_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pty_shd.convert_args
    (null
    ,p_pl_pcp_id
    ,p_business_group_id
    ,p_pcp_typ_cd
    ,p_min_age
    ,p_max_age
    ,p_gndr_alwd_cd
    ,p_pty_attribute_category
    ,p_pty_attribute1
    ,p_pty_attribute2
    ,p_pty_attribute3
    ,p_pty_attribute4
    ,p_pty_attribute5
    ,p_pty_attribute6
    ,p_pty_attribute7
    ,p_pty_attribute8
    ,p_pty_attribute9
    ,p_pty_attribute10
    ,p_pty_attribute11
    ,p_pty_attribute12
    ,p_pty_attribute13
    ,p_pty_attribute14
    ,p_pty_attribute15
    ,p_pty_attribute16
    ,p_pty_attribute17
    ,p_pty_attribute18
    ,p_pty_attribute19
    ,p_pty_attribute20
    ,p_pty_attribute21
    ,p_pty_attribute22
    ,p_pty_attribute23
    ,p_pty_attribute24
    ,p_pty_attribute25
    ,p_pty_attribute26
    ,p_pty_attribute27
    ,p_pty_attribute28
    ,p_pty_attribute29
    ,p_pty_attribute30
    ,null
    );
  --
  -- Having converted the arguments into the ben_pty_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_pty_ins.ins
     (p_effective_date, l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pl_pcp_typ_id := l_rec.pl_pcp_typ_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pty_ins;

/
