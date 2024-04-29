--------------------------------------------------------
--  DDL for Package Body PER_BPR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_INS" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpr_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  hr_utility.set_location(to_char(p_rec.payroll_run_id),99);
  -- Insert the row into: per_bf_payroll_runs
  --
  insert into per_bf_payroll_runs
  (   payroll_run_id,
      payroll_id,
      business_group_id,
      payroll_identifier,
      period_start_date,
      period_end_date,
      processing_date,
      object_version_number,
      bpr_attribute_category,
      bpr_attribute1,
      bpr_attribute2,
      bpr_attribute3,
      bpr_attribute4,
      bpr_attribute5,
      bpr_attribute6,
      bpr_attribute7,
      bpr_attribute8,
      bpr_attribute9,
      bpr_attribute10,
      bpr_attribute11,
      bpr_attribute12,
      bpr_attribute13,
      bpr_attribute14,
      bpr_attribute15,
      bpr_attribute16,
      bpr_attribute17,
      bpr_attribute18,
      bpr_attribute19,
      bpr_attribute20,
      bpr_attribute21,
      bpr_attribute22,
      bpr_attribute23,
      bpr_attribute24,
      bpr_attribute25,
      bpr_attribute26,
      bpr_attribute27,
      bpr_attribute28,
      bpr_attribute29,
      bpr_attribute30
  )
  Values
  (      p_rec.payroll_run_id,
      p_rec.payroll_id,
      p_rec.business_group_id,
      p_rec.payroll_identifier,
      p_rec.period_start_date,
      p_rec.period_end_date,
      p_rec.processing_date,
      p_rec.object_version_number,
      p_rec.bpr_attribute_category,
      p_rec.bpr_attribute1,
      p_rec.bpr_attribute2,
      p_rec.bpr_attribute3,
      p_rec.bpr_attribute4,
      p_rec.bpr_attribute5,
      p_rec.bpr_attribute6,
      p_rec.bpr_attribute7,
      p_rec.bpr_attribute8,
      p_rec.bpr_attribute9,
      p_rec.bpr_attribute10,
      p_rec.bpr_attribute11,
      p_rec.bpr_attribute12,
      p_rec.bpr_attribute13,
      p_rec.bpr_attribute14,
      p_rec.bpr_attribute15,
      p_rec.bpr_attribute16,
      p_rec.bpr_attribute17,
      p_rec.bpr_attribute18,
      p_rec.bpr_attribute19,
      p_rec.bpr_attribute20,
      p_rec.bpr_attribute21,
      p_rec.bpr_attribute22,
      p_rec.bpr_attribute23,
      p_rec.bpr_attribute24,
      p_rec.bpr_attribute25,
      p_rec.bpr_attribute26,
      p_rec.bpr_attribute27,
      p_rec.bpr_attribute28,
      p_rec.bpr_attribute29,
      p_rec.bpr_attribute30
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_bpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_bpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_bpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
Cursor C_Sel1 is select per_bf_payroll_runs_s.nextval from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.payroll_run_id;
  Close C_Sel1;
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
Procedure post_insert(p_effective_date   in  date,
                      p_rec in per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bpr_rki.after_insert
      (p_effective_date              => p_effective_date,
      p_payroll_run_id             => p_rec.payroll_run_id,
      p_payroll_id                 => p_rec.payroll_id,
      p_business_group_id          => p_rec.business_group_id,
      p_payroll_identifier         => p_rec.payroll_identifier,
      p_period_start_date          => p_rec.period_start_date,
      p_period_end_date            => p_rec.period_end_date,
      p_processing_date            => p_rec.processing_date,
      p_object_version_number      => p_rec.object_version_number,
      p_bpr_attribute_category         => p_rec.bpr_attribute_category,
      p_bpr_attribute1                 => p_rec.bpr_attribute1,
      p_bpr_attribute2                 => p_rec.bpr_attribute2,
      p_bpr_attribute3                 => p_rec.bpr_attribute3,
      p_bpr_attribute4                 => p_rec.bpr_attribute4,
      p_bpr_attribute5                 => p_rec.bpr_attribute5,
      p_bpr_attribute6                 => p_rec.bpr_attribute6,
      p_bpr_attribute7                 => p_rec.bpr_attribute7,
      p_bpr_attribute8                 => p_rec.bpr_attribute8,
      p_bpr_attribute9                 => p_rec.bpr_attribute9,
      p_bpr_attribute10                => p_rec.bpr_attribute10,
      p_bpr_attribute11                => p_rec.bpr_attribute11,
      p_bpr_attribute12                => p_rec.bpr_attribute12,
      p_bpr_attribute13                => p_rec.bpr_attribute13,
      p_bpr_attribute14                => p_rec.bpr_attribute14,
      p_bpr_attribute15                => p_rec.bpr_attribute15,
      p_bpr_attribute16                => p_rec.bpr_attribute16,
      p_bpr_attribute17                => p_rec.bpr_attribute17,
      p_bpr_attribute18                => p_rec.bpr_attribute18,
      p_bpr_attribute19                => p_rec.bpr_attribute19,
      p_bpr_attribute20                => p_rec.bpr_attribute20,
      p_bpr_attribute21                => p_rec.bpr_attribute21,
      p_bpr_attribute22                => p_rec.bpr_attribute22,
      p_bpr_attribute23                => p_rec.bpr_attribute23,
      p_bpr_attribute24                => p_rec.bpr_attribute24,
      p_bpr_attribute25                => p_rec.bpr_attribute25,
      p_bpr_attribute26                => p_rec.bpr_attribute26,
      p_bpr_attribute27                => p_rec.bpr_attribute27,
      p_bpr_attribute28                => p_rec.bpr_attribute28,
      p_bpr_attribute29                => p_rec.bpr_attribute29,
      p_bpr_attribute30                => p_rec.bpr_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PAYROLL_RUNS'
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
  (
  p_effective_date   in  date,
  p_rec        in out nocopy per_bpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_bpr_bus.insert_validate(p_effective_date,
                             p_rec
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
  post_insert(p_effective_date
	     ,p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date   in  date,
  p_payroll_run_id               out nocopy number,
  p_payroll_id                   in number,
  p_business_group_id            in number,
  p_payroll_identifier           in varchar2,
  p_period_start_date            in date             default null,
  p_period_end_date              in date             default null,
  p_processing_date              in date             default null,
  p_object_version_number        out nocopy number,
  p_bpr_attribute_category           in varchar2         default null,
  p_bpr_attribute1                  in varchar2         default null,
  p_bpr_attribute2                  in varchar2         default null,
  p_bpr_attribute3                  in varchar2         default null,
  p_bpr_attribute4                  in varchar2         default null,
  p_bpr_attribute5                  in varchar2         default null,
  p_bpr_attribute6                  in varchar2         default null,
  p_bpr_attribute7                  in varchar2         default null,
  p_bpr_attribute8                  in varchar2         default null,
  p_bpr_attribute9                  in varchar2         default null,
  p_bpr_attribute10                 in varchar2         default null,
  p_bpr_attribute11                 in varchar2         default null,
  p_bpr_attribute12                 in varchar2         default null,
  p_bpr_attribute13                 in varchar2         default null,
  p_bpr_attribute14                 in varchar2         default null,
  p_bpr_attribute15                 in varchar2         default null,
  p_bpr_attribute16                 in varchar2         default null,
  p_bpr_attribute17                 in varchar2         default null,
  p_bpr_attribute18                 in varchar2         default null,
  p_bpr_attribute19                 in varchar2         default null,
  p_bpr_attribute20                 in varchar2         default null,
  p_bpr_attribute21                 in varchar2         default null,
  p_bpr_attribute22                 in varchar2         default null,
  p_bpr_attribute23                 in varchar2         default null,
  p_bpr_attribute24                 in varchar2         default null,
  p_bpr_attribute25                 in varchar2         default null,
  p_bpr_attribute26                 in varchar2         default null,
  p_bpr_attribute27                 in varchar2         default null,
  p_bpr_attribute28                 in varchar2         default null,
  p_bpr_attribute29                 in varchar2         default null,
  p_bpr_attribute30                 in varchar2         default null
  ) is
--
  l_rec	  per_bpr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_bpr_shd.convert_args
  (
  null,
  p_payroll_id,
  p_business_group_id,
  p_payroll_identifier,
  p_period_start_date,
  p_period_end_date,
  p_processing_date,
  null,
  p_bpr_attribute_category,
  p_bpr_attribute1,
  p_bpr_attribute2,
  p_bpr_attribute3,
  p_bpr_attribute4,
  p_bpr_attribute5,
  p_bpr_attribute6,
  p_bpr_attribute7,
  p_bpr_attribute8,
  p_bpr_attribute9,
  p_bpr_attribute10,
  p_bpr_attribute11,
  p_bpr_attribute12,
  p_bpr_attribute13,
  p_bpr_attribute14,
  p_bpr_attribute15,
  p_bpr_attribute16,
  p_bpr_attribute17,
  p_bpr_attribute18,
  p_bpr_attribute19,
  p_bpr_attribute20,
  p_bpr_attribute21,
  p_bpr_attribute22,
  p_bpr_attribute23,
  p_bpr_attribute24,
  p_bpr_attribute25,
  p_bpr_attribute26,
  p_bpr_attribute27,
  p_bpr_attribute28,
  p_bpr_attribute29,
  p_bpr_attribute30
  );
  --
  -- Having converted the arguments into the per_bpr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,
      l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_payroll_run_id := l_rec.payroll_run_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_bpr_ins;

/
