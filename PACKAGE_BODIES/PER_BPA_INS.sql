--------------------------------------------------------
--  DDL for Package Body PER_BPA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPA_INS" as
/* $Header: pebparhi.pkb 115.6 2002/12/02 13:36:46 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpa_ins.';  -- Global package name
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
  (p_rec in out nocopy per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_bf_processed_assignments
  --
  insert into per_bf_processed_assignments
      (processed_assignment_id,
      payroll_run_id,
      assignment_id,
      object_version_number,
      bpa_attribute_category,
      bpa_attribute1,
      bpa_attribute2,
      bpa_attribute3,
      bpa_attribute4,
      bpa_attribute5,
      bpa_attribute6,
      bpa_attribute7,
      bpa_attribute8,
      bpa_attribute9,
      bpa_attribute10,
      bpa_attribute11,
      bpa_attribute12,
      bpa_attribute13,
      bpa_attribute14,
      bpa_attribute15,
      bpa_attribute16,
      bpa_attribute17,
      bpa_attribute18,
      bpa_attribute19,
      bpa_attribute20,
      bpa_attribute21,
      bpa_attribute22,
      bpa_attribute23,
      bpa_attribute24,
      bpa_attribute25,
      bpa_attribute26,
      bpa_attribute27,
      bpa_attribute28,
      bpa_attribute29,
      bpa_attribute30
      )
  Values
    (p_rec.processed_assignment_id,
    p_rec.payroll_run_id,
    p_rec.assignment_id,
    p_rec.object_version_number,
    p_rec.bpa_attribute_category,
    p_rec.bpa_attribute1,
    p_rec.bpa_attribute2,
    p_rec.bpa_attribute3,
    p_rec.bpa_attribute4,
    p_rec.bpa_attribute5,
    p_rec.bpa_attribute6,
    p_rec.bpa_attribute7,
    p_rec.bpa_attribute8,
    p_rec.bpa_attribute9,
    p_rec.bpa_attribute10,
    p_rec.bpa_attribute11,
    p_rec.bpa_attribute12,
    p_rec.bpa_attribute13,
    p_rec.bpa_attribute14,
    p_rec.bpa_attribute15,
    p_rec.bpa_attribute16,
    p_rec.bpa_attribute17,
    p_rec.bpa_attribute18,
    p_rec.bpa_attribute19,
    p_rec.bpa_attribute20,
    p_rec.bpa_attribute21,
    p_rec.bpa_attribute22,
    p_rec.bpa_attribute23,
    p_rec.bpa_attribute24,
    p_rec.bpa_attribute25,
    p_rec.bpa_attribute26,
    p_rec.bpa_attribute27,
    p_rec.bpa_attribute28,
    p_rec.bpa_attribute29,
    p_rec.bpa_attribute30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_bpa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_bpa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_bpa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_bf_processed_assignments_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.processed_assignment_id;
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
  (p_effective_date               in date
  ,p_rec                          in per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bpa_rki.after_insert
      (p_effective_date              => p_effective_date,
      p_processed_assignment_id       => p_rec.processed_assignment_id,
      p_payroll_run_id               => p_rec.payroll_run_id,
      p_assignment_id                => p_rec.assignment_id,
      p_object_version_number        => p_rec.object_version_number,
      p_bpa_attribute_category         => p_rec.bpa_attribute_category,
      p_bpa_attribute1                 => p_rec.bpa_attribute1,
      p_bpa_attribute2                 => p_rec.bpa_attribute2,
      p_bpa_attribute3                 => p_rec.bpa_attribute3,
      p_bpa_attribute4                 => p_rec.bpa_attribute4,
      p_bpa_attribute5                 => p_rec.bpa_attribute5,
      p_bpa_attribute6                 => p_rec.bpa_attribute6,
      p_bpa_attribute7                 => p_rec.bpa_attribute7,
      p_bpa_attribute8                 => p_rec.bpa_attribute8,
      p_bpa_attribute9                 => p_rec.bpa_attribute9,
      p_bpa_attribute10                => p_rec.bpa_attribute10,
      p_bpa_attribute11                => p_rec.bpa_attribute11,
      p_bpa_attribute12                => p_rec.bpa_attribute12,
      p_bpa_attribute13                => p_rec.bpa_attribute13,
      p_bpa_attribute14                => p_rec.bpa_attribute14,
      p_bpa_attribute15                => p_rec.bpa_attribute15,
      p_bpa_attribute16                => p_rec.bpa_attribute16,
      p_bpa_attribute17                => p_rec.bpa_attribute17,
      p_bpa_attribute18                => p_rec.bpa_attribute18,
      p_bpa_attribute19                => p_rec.bpa_attribute19,
      p_bpa_attribute20                => p_rec.bpa_attribute20,
      p_bpa_attribute21                => p_rec.bpa_attribute21,
      p_bpa_attribute22                => p_rec.bpa_attribute22,
      p_bpa_attribute23                => p_rec.bpa_attribute23,
      p_bpa_attribute24                => p_rec.bpa_attribute24,
      p_bpa_attribute25                => p_rec.bpa_attribute25,
      p_bpa_attribute26                => p_rec.bpa_attribute26,
      p_bpa_attribute27                => p_rec.bpa_attribute27,
      p_bpa_attribute28                => p_rec.bpa_attribute28,
      p_bpa_attribute29                => p_rec.bpa_attribute29,
      p_bpa_attribute30                => p_rec.bpa_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PROCESSED_ASSIGNMENTS'
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
  (p_effective_date             in date,
  p_rec                         in out nocopy per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_bpa_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
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
  post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date              in date,
  p_processed_assignment_id      out nocopy number,
  p_payroll_run_id               in number,
  p_assignment_id                in number,
  p_object_version_number        out nocopy number,
  p_bpa_attribute_category           in varchar2         default null,
  p_bpa_attribute1                  in varchar2         default null,
  p_bpa_attribute2                  in varchar2         default null,
  p_bpa_attribute3                  in varchar2         default null,
  p_bpa_attribute4                  in varchar2         default null,
  p_bpa_attribute5                  in varchar2         default null,
  p_bpa_attribute6                  in varchar2         default null,
  p_bpa_attribute7                  in varchar2         default null,
  p_bpa_attribute8                  in varchar2         default null,
  p_bpa_attribute9                  in varchar2         default null,
  p_bpa_attribute10                 in varchar2         default null,
  p_bpa_attribute11                 in varchar2         default null,
  p_bpa_attribute12                 in varchar2         default null,
  p_bpa_attribute13                 in varchar2         default null,
  p_bpa_attribute14                 in varchar2         default null,
  p_bpa_attribute15                 in varchar2         default null,
  p_bpa_attribute16                 in varchar2         default null,
  p_bpa_attribute17                 in varchar2         default null,
  p_bpa_attribute18                 in varchar2         default null,
  p_bpa_attribute19                 in varchar2         default null,
  p_bpa_attribute20                 in varchar2         default null,
  p_bpa_attribute21                 in varchar2         default null,
  p_bpa_attribute22                 in varchar2         default null,
  p_bpa_attribute23                 in varchar2         default null,
  p_bpa_attribute24                 in varchar2         default null,
  p_bpa_attribute25                 in varchar2         default null,
  p_bpa_attribute26                 in varchar2         default null,
  p_bpa_attribute27                 in varchar2         default null,
  p_bpa_attribute28                 in varchar2         default null,
  p_bpa_attribute29                 in varchar2         default null,
  p_bpa_attribute30                 in varchar2         default null
  ) is
--
  l_rec	  per_bpa_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_bpa_shd.convert_args
    (null,
    p_payroll_run_id,
    p_assignment_id,
    null,
    p_bpa_attribute_category,
    p_bpa_attribute1,
    p_bpa_attribute2,
    p_bpa_attribute3,
    p_bpa_attribute4,
    p_bpa_attribute5,
    p_bpa_attribute6,
    p_bpa_attribute7,
    p_bpa_attribute8,
    p_bpa_attribute9,
    p_bpa_attribute10,
    p_bpa_attribute11,
    p_bpa_attribute12,
    p_bpa_attribute13,
    p_bpa_attribute14,
    p_bpa_attribute15,
    p_bpa_attribute16,
    p_bpa_attribute17,
    p_bpa_attribute18,
    p_bpa_attribute19,
    p_bpa_attribute20,
    p_bpa_attribute21,
    p_bpa_attribute22,
    p_bpa_attribute23,
    p_bpa_attribute24,
    p_bpa_attribute25,
    p_bpa_attribute26,
    p_bpa_attribute27,
    p_bpa_attribute28,
    p_bpa_attribute29,
    p_bpa_attribute30
    );
  --
  -- Having converted the arguments into the per_bpa_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_processed_assignment_id := l_rec.processed_assignment_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_bpa_ins;

/
